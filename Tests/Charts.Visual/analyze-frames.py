"""Checks complete captured buffers; desktop continuity remains a separate gate."""
import argparse,json,hashlib
from pathlib import Path
from PIL import Image
import numpy as np
p=argparse.ArgumentParser()
p.add_argument('directory',type=Path)
a=p.parse_args(); log=a.directory/'frames.jsonl'
frames=[json.loads(s.lstrip('\ufeff')) for s in log.read_text(encoding='utf-8-sig').splitlines() if s.strip()]
failures=[]; previous=None; intervals=[]; hashes=set()
for f in frames:
    file=a.directory/f"frame-{f['frame']:06}.png"
    if previous:
        if f['frame']!=previous['frame']+1: failures.append(f"Missing frame after {previous['frame']}")
        intervals.append(f['tick']-previous['tick'])
    previous=f
    if not file.exists():failures.append(f'Missing {file.name}');continue
    image=Image.open(file).convert('RGB');pixels=np.array(image)
    if image.size!=(f['width'],f['height']):failures.append(f'{file.name}: wrong size')
    if np.max(pixels.max(axis=(0,1))-pixels.min(axis=(0,1)))<3:failures.append(f'{file.name}: blank')
    hashes.add(hashlib.sha256(pixels.tobytes()).hexdigest())
metrics_path=a.directory.parent/'metrics.json'
metrics=json.loads(metrics_path.read_text(encoding='utf-8-sig')) if metrics_path.exists() else {}
screen_count=sum(bool(f.get('screenCaptured')) for f in frames)
benchmark_valid=metrics.get('dataCount')==metrics.get('visibleMarks') and metrics.get('dataCount',0)>0
reference_load=benchmark_valid and metrics.get('dataCount')<=1000 and metrics.get('dpi')==144
production_ok=metrics.get('p95Ms',999)<=33.3 and metrics.get('maxMs',999)<=100
result={'capturedFrames':len(frames),'uniqueBuffers':len(hashes),'bufferCompleteness':'pass' if frames and not failures else 'fail',
 'bufferErrors':failures,'maxCapturedIntervalMs':max(intervals,default=0),
 'screenFrames':screen_count,'benchmarkDataValid':benchmark_valid,
 'productionPerformance':('pass' if production_ok else 'fail') if reference_load else 'outside_reference_profile',
 'desktopContinuity':'inconclusive','reason':'Screen snapshots after presentation are diagnostic; independent temporal capture is required to detect transients between presentations.',
 'metrics':metrics}
(a.directory.parent/'temporal.json').write_text(json.dumps(result,indent=2),encoding='utf-8')
print(json.dumps(result))
raise SystemExit(bool(failures) or not frames)
