from pathlib import Path
p=Path(r'M:/MaxxSoft/MaxxRural/Desktop/maxxrural/MaxxRural/src/Tests/Teste.MovimentoBancario.ColunasGrid.pas');s=p.read_bytes().decode('cp1252').replace('\r\n','\n');s=s.replace('    [Test] procedure LayoutRestauraDadosEIdentidade;', '    [Test] procedure LayoutRestauraDadosEIdentidade;\n    [Test] procedure ResetPreservaOrdenacaoInicial;')
a=s.index('procedure TMovimentoBancarioColunasGridTests.CarregarNaoSobrescreveComAutosavePendente;');s=s[:a]+'''procedure TMovimentoBancarioColunasGridTests.ResetPreservaOrdenacaoInicial;
begin
  G.RequestSort(C('N').Index, dgsAscending); EnableLayout;
  G.RequestSort(C('DT').Index, dgsDescending); G.ResetLayout;
  Assert.AreEqual('N', G.SortKey); Assert.AreEqual(dgsAscending, G.SortDirection);
  Assert.AreEqual('NULL|-3|2|2|10|10|100', Sequence('N'));
end;

'''+s[a:];s=s.replace('  Assert.AreEqual(Saved, TFile.ReadAllText(LayoutFile));', "  Assert.AreEqual(Saved, TFile.ReadAllText(LayoutFile));\n  G.ResetLayout; Assert.AreEqual(108, C('N').Width);")
p.write_bytes(s.replace('\n','\r\n').encode('cp1252'))
