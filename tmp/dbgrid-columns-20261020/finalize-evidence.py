from pathlib import Path
import difflib,hashlib,json,shutil,xml.etree.ElementTree as ET
r=Path.cwd();t=r/'tmp/dbgrid-columns-20261020';b=t/'before'
c=Path(r'M:/MaxxSoft/MaxxRural/Desktop/maxxrural');e=c/'MaxxRural/src/Tests/Resultados/20261020-grid-colunas'
# Final test outcome, parsed from the runner's artifact.
x=ET.parse(e/'apitestes-todos.xml').getroot()
assert x.attrib['total']=='231' and x.attrib['failures']=='0' and x.attrib['errors']=='0',x.attrib
for f in ['build-runtime.log','build-design.log','build-package.log','build-existing-tests.log','build-desktop.log']:
 data=(t/f).read_text(errors='replace');assert 'error E' not in data and 'error F' not in data,f
assert 'DACDBGridTests: PASS' in (t/'build-existing-tests.log').read_text()
for f in ['build-runtime.log','build-design.log','build-package.log','build-existing-tests.log',
 'build-runtime.cmd','build-design.cmd','build-package.cmd','build-existing-tests.cmd',
 'static-audit-final.json','static-audit-final.log']:
 shutil.copy2(t/f,e/f)
for p in (c/'EXE').glob('dbgrid-columns-*.png'):shutil.copy2(p,e/p.name)
report=(t/'README-evidencias.md').read_text(encoding='utf-8')
report+='''

A auditoria estática complementar terminou com saída zero: 32 pares de hooks e
15/15 famílias. Os oito avisos são TODOs preexistentes, incluindo uma cópia do
snapshot anterior em tmp. `validate_skill.py` e `verify_starter.py` também
concluíram. Essas verificações estruturais são separadas dos testes em execução.

Para reproduzir: execute `compilar.cmd` e depois `executar-testes.ps1` desta
pasta. `compilar-desktop.cmd` faz o Rebuild do consumidor. Execute os scripts
`build-runtime.cmd`, `build-design.cmd`, `build-package.cmd` e
`build-existing-tests.cmd` tendo a raiz do repositório do componente como
working directory; eles usam apenas propriedades na linha de comando. O script
do teste existente acrescenta EXE ao PATH do próprio processo para localizar
sk4d.dll. Não modifica o PATH persistido do Windows.

`scoped-changes.diff` compara os arquivos que tinham snapshot com o estado no
início desta revisão e inclui as units novas. Não é um diff de todo o checkout.
`source-sha256.json` identifica os arquivos finais e os executáveis resultantes.
'''
(e/'README.md').write_text(report,encoding='utf-8',newline='\n')
paths=[]
for p in (r/'Source/Controls').glob('DAC.Components.Controls.DBGrid*.pas'):
 if not (b/p.name).exists() or p.read_bytes()!=(b/p.name).read_bytes():paths.append(p)
paths += [c/'source/view/View.MovimentoBancario.pas',c/'source/view/View.MovimentoBancario.dfm',
 c/'MaxxRural/src/Tests/ApiTestes.dpr',c/'MaxxRural/src/Tests/TestSupport.DACDBGridActions.pas',
 c/'MaxxRural/src/Tests/Teste.MovimentoBancario.ColunasGrid.pas']
diff=[]
for p in paths:
 old=b/p.name
 a=old.read_bytes().decode('cp1252').replace('\r\n','\n').splitlines(True) if old.exists() else []
 now=p.read_bytes().decode('cp1252').replace('\r\n','\n').splitlines(True)
 diff.extend(difflib.unified_diff(a,now,fromfile='before/'+p.name,tofile=str(p)))
(e/'scoped-changes.diff').write_bytes(''.join(diff).encode('utf-8'))
paths += [r/'Tests/DACDBGridTests.dpr',r/'docs/dbgrid/columns.md',r/'docs/dbgrid/actions.md',c/'source/README.md',c/'EXE/ApiTestes.exe',c/'EXE/MaxxRural.exe']
manifest={str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in paths}
(e/'source-sha256.json').write_text(json.dumps(manifest,indent=2,ensure_ascii=False),encoding='utf-8')
print(json.dumps({'total':x.attrib['total'],'failures':x.attrib['failures'],'errors':x.attrib['errors'],'captures':len(list(e.glob('dbgrid-columns-*.png'))),'evidence':str(e),'hashes':len(manifest)}))
