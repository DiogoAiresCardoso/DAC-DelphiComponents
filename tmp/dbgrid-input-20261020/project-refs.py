from pathlib import Path
import re,shutil,json
r=Path(r'M:/MaxxSoft/MaxxRural/Desktop/maxxrural');t=Path('tmp/dbgrid-input-20261020');changed=[]
master=(r/'Geral/ufrmMaster.pas').resolve()
for p in r.rglob('*.dpr'):
 if 'modules' in p.parts:continue
 raw=p.read_bytes()
 try:s=raw.decode('cp1252').replace('\r\n','\n')
 except UnicodeError:continue
 m=re.search(r"(?im)^([ \t]*)ufrmMaster in '([^']+)'",s)
 if not m:continue
 target=(p.parent/m.group(2)).resolve()
 if str(target).lower()!=str(master).lower():continue
 if re.search(r'(?i)\buGridInteracao\b',s):continue
 helper=m.group(2).replace('ufrmMaster.pas','uGridInteracao.pas')
 backup=t/'dpr-before'/p.relative_to(r);backup.parent.mkdir(parents=True,exist_ok=True);shutil.copy2(p,backup)
 s=s[:m.start()]+m.group(1)+"uGridInteracao in '"+helper+"',\n"+s[m.start():]
 p.write_bytes(s.replace('\n','\r\n').encode('cp1252'));changed.append(str(p.relative_to(r)))
(t/'project-references.json').write_text(json.dumps(changed,indent=2),encoding='utf-8');print(json.dumps(changed))
p=r/'MaxxRural/src/Tests/Teste.MovimentoBancario.InputGrid.pas';s=p.read_bytes().decode('cp1252').replace('\r\n','\n');s=s.replace('    F.SetBounds(30, 30, 1000, 600); F.Show;', '    F.FormStyle := fsStayOnTop;\n    F.SetBounds(30, 30, 1000, 600); F.Show;');p.write_bytes(s.replace('\n','\r\n').encode('cp1252'))
