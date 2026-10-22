from pathlib import Path
r=Path(r'M:/MaxxSoft/MaxxRural/Desktop/maxxrural/MaxxRural/src/Tests')
s=Path('tmp/dbgrid-columns-20261020/Teste.MovimentoBancario.ColunasGrid.pas').read_text()
s=s.replace('2026-02-06|2026-03-04|2026-06-02|2026-07-07|2026-11-03','2026-04-04|2026-06-02|2026-07-07|2026-09-05|2026-11-03')
s=s.replace('2026-11-03|2026-07-07|2026-06-02|2026-03-04|2026-02-06|2026-01-01','2026-11-03|2026-09-05|2026-07-07|2026-06-02|2026-04-04|2026-01-01')
s=s.replace('TFile.GetSize(FileName)', 'Length(TFile.ReadAllBytes(FileName))')
(r/'Teste.MovimentoBancario.ColunasGrid.pas').write_bytes(s.replace('\n','\r\n').encode('cp1252'))
p=r/'ApiTestes.dpr';s=p.read_bytes().decode('cp1252').replace('\r\n','\n');line="  Teste.MovimentoBancario.ColunasGrid in 'Teste.MovimentoBancario.ColunasGrid.pas',\n";s=s.replace("  Teste.MovimentoBancario.AcoesGrid in",line+"  Teste.MovimentoBancario.AcoesGrid in");p.write_bytes(s.replace('\n','\r\n').encode('cp1252'))
