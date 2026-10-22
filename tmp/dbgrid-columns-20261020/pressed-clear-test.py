from pathlib import Path
p=Path(r'M:/MaxxSoft/MaxxRural/Desktop/maxxrural/MaxxRural/src/Tests/Teste.MovimentoBancario.ColunasGrid.pas');s=p.read_bytes().decode('cp1252').replace('\r\n','\n');a='procedure TMovimentoBancarioColunasGridTests.HoverNaoRepintaNoMesmoPontoELimpaCursor;\nvar Count: Integer; P: TPoint;\nbegin';b='''procedure TMovimentoBancarioColunasGridTests.HoverNaoRepintaNoMesmoPontoELimpaCursor;
var Count: Integer; P: TPoint; B: TBitmap; Normal: TColor;
begin
  B := TBitmap.Create;
  try
    B.SetSize(G.Width, G.Height); G.Perform(CM_MOUSELEAVE, 0, 0);
    G.PaintTo(B.Canvas.Handle, 0, 0); Normal := B.Canvas.Pixels[10,10];
    P := G.HeaderPoint(0); G.DownAt(P); G.Enabled := False;
    G.PaintTo(B.Canvas.Handle, 0, 0); Assert.AreEqual(Normal, B.Canvas.Pixels[10,10]);
    G.Enabled := True; G.UpAt(P); Assert.AreEqual(0, G.SortRequests);
    G.Perform(CM_MOUSELEAVE, 0, 0); G.DownAt(P); G.Loading := True;
    G.PaintTo(B.Canvas.Handle, 0, 0); Assert.AreEqual(Normal, B.Canvas.Pixels[10,10]);
    G.Loading := False; G.UpAt(P); Assert.AreEqual(0, G.SortRequests);
  finally B.Free; end;''';assert a in s;s=s.replace(a,b);p.write_bytes(s.replace('\n','\r\n').encode('cp1252'))
