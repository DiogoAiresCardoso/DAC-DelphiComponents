from pathlib import Path
import shutil
r=Path(r'M:\Delphi Componentes\DAC-DelphiComponents')
tmp=r/'tmp/button-caption-20261022';tmp.mkdir(parents=True,exist_ok=True)
for path,name in [(r/'Source/Controls/DAC.Components.Controls.Button.pas','button.before.pas'),(r/'Tests/DACComponentsInteraction.Current.dpr','interaction.before.dpr')]:
    if not (tmp/name).exists():shutil.copy2(path,tmp/name)
p=r/'Tests/DACComponentsInteraction.Current.dpr'
s=p.read_bytes().decode('cp1252').replace('\r\n','\n')
s=s.replace('  DACComponentsIcons.Tests in', "  DACComponentsButtonLayout.Tests in 'DACComponentsButtonLayout.Tests.pas',\n  DACComponentsIcons.Tests in",1)
s=s.replace('  TDACComponentsIconTests.Run;', '  TDACButtonLayoutTests.Run;\n  TDACComponentsIconTests.Run;',1)
p.write_bytes(s.replace('\n','\r\n').encode('cp1252'))
p=r/'Tests/DACComponentsButtonLayout.Tests.pas';p.write_bytes(p.read_text('utf8').replace('\r\n','\n').replace('\n','\r\n').encode('cp1252'))
for name in ['build-tests.cmd','build-demo.cmd','build-startup.cmd']:
    s=(r/'tmp/icons-expanded-20261021'/name).read_text('utf8').replace('icons-expanded-20261021','button-caption-20261022')
    (tmp/name).write_text(s,encoding='utf8')
