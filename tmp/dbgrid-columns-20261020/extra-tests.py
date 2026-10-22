from pathlib import Path
p=Path(r'M:/MaxxSoft/MaxxRural/Desktop/maxxrural/MaxxRural/src/Tests/Teste.MovimentoBancario.ColunasGrid.pas');s=p.read_bytes().decode('cp1252').replace('\r\n','\n');s=s.replace('    [Test] procedure AssignEStreamingAntigoENovo;', '    [Test] procedure LayoutMantemLarguraLogicaEntreEscalas;\n    [Test] procedure FocoPorCelulaPermaneceDuranteHover;\n    [Test] procedure AssignEStreamingAntigoENovo;');at=s.index('procedure TMovimentoBancarioColunasGridTests.AssignEStreamingAntigoENovo;');s=s[:at]+'''procedure TMovimentoBancarioColunasGridTests.LayoutMantemLarguraLogicaEntreEscalas;
begin
  EnableLayout; G.SetTestPPI(144); C('N').Width := 180; G.SaveLayout;
  G.SetTestPPI(192); G.LoadLayout; Assert.AreEqual(240, C('N').Width);
  G.SetTestPPI(96); G.LoadLayout; Assert.AreEqual(120, C('N').Width);
end;

procedure TMovimentoBancarioColunasGridTests.FocoPorCelulaPermaneceDuranteHover;
var B: TBitmap; R: TRect; Color: TColor;
begin
  G.RowSelectionEnabled := False; G.SelectedIndex := C('DT').Index;
  B := TBitmap.Create;
  try
    B.SetSize(G.Width, G.Height); G.PaintTo(B.Canvas.Handle, 0, 0);
    R := G.BoundsOf(C('DT').Index, 0);
    Color := B.Canvas.Pixels[R.Left + 1, R.CenterPoint.Y];
    G.MoveAt(G.BoundsOf(C('VAL').Index, 0).CenterPoint); G.PaintTo(B.Canvas.Handle, 0, 0);
    Assert.AreEqual(Color, B.Canvas.Pixels[R.Left + 1, R.CenterPoint.Y]);
    G.MoveAt(R.CenterPoint); G.PaintTo(B.Canvas.Handle, 0, 0);
    Assert.AreEqual(Color, B.Canvas.Pixels[R.Left + 1, R.CenterPoint.Y]);
    Assert.IsTrue(Color <> B.Canvas.Pixels[R.Left + 5, R.Top + 5]);
  finally B.Free; end;
end;

'''+s[at:];p.write_bytes(s.replace('\n','\r\n').encode('cp1252'))
