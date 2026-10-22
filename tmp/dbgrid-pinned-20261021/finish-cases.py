from pathlib import Path
base=Path(r'M:\MaxxSoft\MaxxRural\Desktop\maxxrural\MaxxRural\src\Tests')
p=base/'Teste.MovimentoBancario.ColunasGrid.pas'
s=p.read_bytes().decode('cp1252').replace('\r\n','\n')
s=s.replace('    [Test] procedure FixasMantemAcoesMouseTecladoEIdentidade;', '''    [Test] procedure FixasTecladoSegueOrdemVisual;
    [Test] procedure FixasColunaCentralMaiorQueViewport;
    [Test] procedure FixasMantemAcoesMouseTecladoEIdentidade;''',1)
s=s.replace("    Assert.AreEqual(176, C('OPCOES').MinWidth);", "    Assert.AreEqual(176, C('OPCOES').MinWidth);\n    Assert.AreEqual(Integer(dgpRight),Integer(C('OPCOES').PinPosition), 'DFM real fixa acoes a direita.');",1)
s=s.replace("  R := G.BoundsOf(C('N').Index,1); P := Point(G.Selection.Width div 2,R.CenterPoint.Y);", "  R := G.ActionRect(C('OPCOES').Index,1,0); Assert.IsFalse(R.IsEmpty);\n  P := Point(G.Selection.Width div 2,R.CenterPoint.Y);")
idx=s.index('initialization')
s=s[:idx]+'''procedure TMovimentoBancarioColunasGridTests.FixasTecladoSegueOrdemVisual;
begin
  C('N').PinPosition := dgpLeft; C('OPCOES').PinPosition := dgpRight;
  C('OPCOES').Index := 0; C('N').Index := 3;
  G.RowSelectionEnabled := False;
  G.PressKey(VK_HOME); Assert.AreEqual(C('N').Index,G.SelectedIndex);
  G.PressKey(VK_END); Assert.AreEqual(C('OPCOES').Index,G.SelectedIndex);
  G.PressKey(VK_LEFT); Assert.AreEqual(C('LONG').Index,G.SelectedIndex);
  G.PressKey(VK_RIGHT); Assert.AreEqual(C('OPCOES').Index,G.SelectedIndex);
  G.ClickAt(G.BoundsOf(C('N').Index,1).CenterPoint);
  Assert.AreEqual(C('N').Index,G.SelectedIndex);
  Assert.AreEqual('0000000002',D.FieldByName('MOV_COD').AsString);
end;

procedure TMovimentoBancarioColunasGridTests.FixasColunaCentralMaiorQueViewport;
var I: Integer; R, Full: TRect;
begin
  C('N').PinPosition := dgpLeft; C('OPCOES').PinPosition := dgpRight;
  G.Width := 650;
  for I := 0 to G.Columns.Count - 1 do
    if (G.Columns[I].PinPosition = dgpNone) and (G.Columns[I].FieldName <> 'DT') then G.Columns[I].Visible := False;
  C('DT').Width := 2000;
  G.Perform(WM_HSCROLL,SB_RIGHT,0); G.Update;
  Winapi.Windows.GetClientRect(G.Handle,Full);
  R := G.BoundsOf(C('DT').Index,0);
  Assert.IsTrue(R.Right <= Full.Right - C('OPCOES').Width + 1,
    Format('Fim da coluna central nao alcancavel: right=%d max=%d',[R.Right,Full.Right-C('OPCOES').Width]));
  Assert.AreEqual(Full.Right,G.BoundsOf(C('OPCOES').Index,0).Right);
end;

'''+s[idx:]
p.write_bytes(s.replace('\n','\r\n').encode('cp1252'))
