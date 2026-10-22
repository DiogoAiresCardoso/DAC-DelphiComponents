from pathlib import Path
import difflib, hashlib, json
r=Path.cwd();t=r/'tmp/dbgrid-columns-20261020';b=t/'before'
consumer=Path(r'M:/MaxxSoft/MaxxRural/Desktop/maxxrural')
paths=list((r/'Source/Controls').glob('DAC.Components.Controls.DBGrid*.pas'))
paths += [consumer/'source/view/View.MovimentoBancario.pas',consumer/'source/view/View.MovimentoBancario.dfm',consumer/'MaxxRural/src/Tests/ApiTestes.dpr',consumer/'MaxxRural/src/Tests/TestSupport.DACDBGridActions.pas',consumer/'MaxxRural/src/Tests/Teste.MovimentoBancario.AcoesGrid.pas']
diffs=[];changed=[]
for p in paths:
 old=b/p.name
 now=p.read_bytes()
 if old.exists() and now==old.read_bytes():continue
 changed.append(str(p));a=old.read_bytes().decode('cp1252').splitlines(True) if old.exists() else []
 diffs.extend(difflib.unified_diff(a,now.decode('cp1252').splitlines(True),fromfile='before/'+p.name,tofile=str(p)))
(t/'scoped-changes.diff').write_text(''.join(diffs),encoding='utf-8')
print('\n'.join(changed))
for p in paths:
 if str(p) not in changed:continue
 raw=p.read_bytes()
 assert b'\n' not in raw.replace(b'\r\n',b''),str(p)
 assert all(not l.endswith((' ','\t')) for l in raw.decode('cp1252').splitlines()),str(p)
for name in ['DACSkiaComponents.dpk','DACSkiaComponentsRuntime.dpk']:
 assert (b/name).read_bytes()==(r/'Package'/name).read_bytes(),name+' changed'
print('CP1252/CRLF sem espacos finais nas fontes alteradas; DPKs iguais ao inicio da revisao.')
