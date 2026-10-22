"""Geometry gates and visual evidence. Never promotes reference baselines."""
import argparse, json, math
from collections import Counter
from pathlib import Path
import numpy as np
from PIL import Image

p=argparse.ArgumentParser()
p.add_argument('reference',type=Path)
p.add_argument('actual',type=Path)
args=p.parse_args()
report=[]
for ref_file in sorted(list(args.reference.glob('C*.json'))+list(args.reference.glob('V*.json'))):
    stem=ref_file.stem
    actual_file=args.actual/(stem+'.json')
    if not actual_file.exists():
        report.append({'id':stem,'geometry':'missing','visual':'missing'})
        continue
    reference=json.loads(ref_file.read_text(encoding='utf-8-sig'))
    actual=json.loads(actual_file.read_text(encoding='utf-8-sig'))
    marks={(m['series'],m['dataIndex']):m for m in actual['marks'] if m['series']>=0}
    errors=[]
    def check(value,target,name):
        if abs(value-target)>0.5:
            errors.append({'property':name,'actual':value,'expected':target})
    for si,series in enumerate(reference['series']):
        for di,item in enumerate(series['items']):
            layout=item.get('layout') or {}
            point=item.get('point')
            if point and any(v is None for v in point):
                if (si,di) in marks: errors.append({'property':f'{si}/{di}:null has geometry'})
                continue
            if series['type']=='pie' and not layout.get('angle',0):
                continue
            m=marks.get((si,di))
            if m is None:
                errors.append({'property':f'{si}/{di}:missing mark'})
                continue
            if series['type']=='bar':
                x,y,w,h=(layout[k] for k in ('x','y','width','height'))
                for key,target in [('left',min(x,x+w)),('right',max(x,x+w)),('top',min(y,y+h)),('bottom',max(y,y+h))]:
                    check(m[key],target,f'{si}/{di}:{key}')
            elif series['type']=='line' and point:
                check(m['x'],point[0],f'{si}/{di}:x');check(m['y'],point[1],f'{si}/{di}:y')
            elif series['type']=='pie':
                check(m['radius'],layout['r'],f'{si}/{di}:r')
                check(m['innerRadius'],layout['r0'],f'{si}/{di}:r0')
                check(abs(m['sweep']),math.degrees(layout['angle']),f'{si}/{di}:sweep')
    a=Image.open(args.actual/(stem+'.png')).convert('RGB')
    r=Image.open(args.reference/(stem+'.png')).convert('RGB')
    if a.size!=r.size: raise ValueError(f'{stem}: unequal viewports')
    aa=np.array(a).astype(np.int16);rr=np.array(r).astype(np.int16)
    delta=np.max(np.abs(aa-rr),axis=2)
    overlay=Image.blend(r,a,0.5);overlay.save(args.actual/(stem+'-overlay.png'))
    heat=np.zeros_like(aa,dtype=np.uint8);heat[:,:,0]=np.minimum(delta*4,255).astype(np.uint8)
    Image.fromarray(heat).save(args.actual/(stem+'-diff.png'))
    window=args.actual/(stem+'-window.png')
    physical=None
    if window.exists():physical=bool(np.array_equal(np.array(Image.open(window).convert('RGB')),np.array(a)))
    # Native glyph rasterization has its own baseline. Missing text is always a
    # failure even when it represents a tiny fraction of the canvas.
    expected_text=Counter(str(t['text']).strip() for t in reference.get('texts',[]) if str(t['text']).strip())
    actual_text=Counter(str(t['text']).strip() for t in actual.get('texts',[]) if str(t['text']).strip())
    missing_text=list((expected_text-actual_text).elements())
    clipped=[t for t in actual.get('texts',[]) if t.get('clipped')]
    report.append({'id':stem,'geometry':'pass' if not errors else 'fail','errors':errors,
      'visual':'review_required','changedPixelFraction':float(np.mean(delta>8)),
      'textContent':'fail' if missing_text else 'pass','missingText':missing_text,
      'textClipping':'fail' if clipped else 'pass','clippedText':clipped,
      'textLayout':'review_required','nativeWindowMatchesBuffer':physical})
out={'referenceVersion':'6.1.0','automaticVisualApproval':False,'cases':report}
(args.actual/'comparison.json').write_text(json.dumps(out,indent=2),encoding='utf-8')
print(json.dumps({'geometryPassed':sum(c['geometry']=='pass' for c in report),
 'textContentPassed':sum(c.get('textContent')=='pass' for c in report),'total':len(report),'visual':'review_required'}))
raise SystemExit(0 if all(c['geometry']=='pass' and c.get('textContent')=='pass' and c.get('textClipping')=='pass' for c in report) else 1)
