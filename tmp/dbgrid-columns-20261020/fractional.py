from pathlib import Path
r=Path(r'M:/MaxxSoft/MaxxRural/Desktop/maxxrural')
for rel in ['source/view/View.MovimentoBancario.dfm', 'MaxxRural/src/Tests/Teste.MovimentoBancario.ColunasGrid.pas']:
 p=r/rel;s=p.read_bytes().decode('cp1252').replace('\r\n','\n');s=s.replace('MinWidth = 172','MinWidth = 176').replace('Assert.AreEqual(172,', 'Assert.AreEqual(176,')
 if rel.endswith('.pas'):
  s=s.replace("    [TestCase('claro144'", "    [TestCase('claro120','120,1')]\n    [TestCase('escuro120','120,0')]\n    [TestCase('claro144'",1)
  s=s.replace("  C('OPCOES').Width := MulDiv(196, PPI, 96);", """  C('OPCOES').MinWidth := 176; C('OPCOES').Width := 1;
  for I := 0 to 2 do Assert.IsFalse(G.ActionRect(C('OPCOES').Index, 0, I).IsEmpty,
    'Acao nao cabe na largura minima escalada.');
  C('OPCOES').Width := MulDiv(196, PPI, 96);""")
 p.write_bytes(s.replace('\n','\r\n').encode('cp1252'))
