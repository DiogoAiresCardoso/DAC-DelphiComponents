from pathlib import Path
import shutil
r=Path(r'M:/MaxxSoft/MaxxRural/Desktop/maxxrural/MaxxRural/src/Tests');t=Path('tmp/dbgrid-input-20261020')
for name in ['TestSupport.DACGridHostForm.pas','Teste.MovimentoBancario.InputGrid.pas']:
 s=(t/name).read_text(encoding='utf-8');(r/name).write_bytes(s.replace('\n','\r\n').encode('cp1252'))
p=r/'ApiTestes.dpr';s=p.read_bytes().decode('cp1252').replace('\r\n','\n');shutil.copy2(p,t/'ApiTestes.before.dpr')
for name in ['TestSupport.DACGridHostForm','Teste.MovimentoBancario.InputGrid']:
 s=s.replace('  TestSupport.DACDBGridActions in',f"  {name} in '{name}.pas',\n  TestSupport.DACDBGridActions in",1)
p.write_bytes(s.replace('\n','\r\n').encode('cp1252'))
e=r/'Resultados/20261020-grid-input';e.mkdir(exist_ok=True)
for name in ['compilar.cmd','compilar-desktop.cmd','executar-testes.ps1']:shutil.copy2(r/'Resultados/20261020-grid-colunas'/name,e/name)
