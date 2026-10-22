from pathlib import Path
p=Path(r'M:/MaxxSoft/MaxxRural/Desktop/maxxrural/MaxxRural/src/Tests/Teste.MovimentoBancario.ColunasGrid.pas');s=p.read_bytes().decode('cp1252').replace('\r\n','\n');needle='procedure TMovimentoBancarioColunasGridTests.CabecalhoAlternaUmaVezEIgnoraOpcoes;\nbegin';repl='''procedure TMovimentoBancarioColunasGridTests.CabecalhoAlternaUmaVezEIgnoraOpcoes;
var Asc, Desc: TBitmap; Png: TPngImage; X, Y, Differences: Integer; R: TRect;
  procedure Capture(B: TBitmap; const Name: string);
  begin
    B.SetSize(G.Width, G.Height); G.PaintTo(B.Canvas.Handle, 0, 0);
    Png.Assign(B); Png.SaveToFile(ExtractFilePath(ParamStr(0)) + Name);
  end;
begin
  Asc := TBitmap.Create; Desc := TBitmap.Create; Png := TPngImage.Create;
  try''';assert needle in s;s=s.replace(needle,repl)
s=s.replace('  Assert.AreEqual(1, G.SortRequests); Assert.AreEqual(dgsAscending, G.SortDirection);\n  G.ClickAt', "  Assert.AreEqual(1, G.SortRequests); Assert.AreEqual(dgsAscending, G.SortDirection);\n  Capture(Asc, 'dbgrid-columns-sort-asc.png');\n  G.ClickAt",1)
s=s.replace('  Assert.AreEqual(2, G.SortRequests); Assert.AreEqual(dgsDescending, G.SortDirection);\n  G.ClickAt', '''  Assert.AreEqual(2, G.SortRequests); Assert.AreEqual(dgsDescending, G.SortDirection);
  Capture(Desc, 'dbgrid-columns-sort-desc.png'); R := G.BoundsOf(C('N').Index);
  Differences := 0;
  for Y := R.Top to R.Bottom - 1 do
    for X := R.Left to R.Right - 1 do
      if Asc.Canvas.Pixels[X,Y] <> Desc.Canvas.Pixels[X,Y] then Inc(Differences);
  Assert.IsTrue(Differences > 2, 'Indicador visual nao mudou de direcao.');
  G.ClickAt''',1)
needle='  Assert.AreEqual(3, G.SortRequests);\nend;\n\nprocedure TMovimentoBancarioColunasGridTests.ArrastarERedimensionar'
s=s.replace(needle, '  Assert.AreEqual(3, G.SortRequests);\n  finally Png.Free; Desc.Free; Asc.Free; end;\nend;\n\nprocedure TMovimentoBancarioColunasGridTests.ArrastarERedimensionar')
s=s.replace('procedure TMovimentoBancarioColunasGridTests.OrdenacaoPorTecladoEPedidoRecusado;\nbegin', '''procedure TMovimentoBancarioColunasGridTests.OrdenacaoPorTecladoEPedidoRecusado;
var Saved, Pressed: TKeyboardState;
begin
  GetKeyboardState(Saved); Pressed := Saved; Pressed[VK_CONTROL] := $80;
  try
    SetKeyboardState(Pressed);
    Assert.IsTrue((G.Perform(WM_GETDLGCODE, VK_RETURN, 0) and DLGC_WANTALLKEYS) <> 0,
      'Ctrl+Enter pode ser consumido pelo botao padrao do formulario.');
  finally SetKeyboardState(Saved); end;''')
p.write_bytes(s.replace('\n','\r\n').encode('cp1252'))
