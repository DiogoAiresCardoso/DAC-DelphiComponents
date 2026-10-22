from pathlib import Path
root=Path(r'M:\MaxxSoft\MaxxRural\Desktop\maxxrural')
p=root/'MaxxRural/src/Tests/Teste.MovimentoBancario.ColunasGrid.pas'
s=p.read_bytes().decode('cp1252').replace('\r\n','\n')
s=s.replace('    [Test] procedure NumerosNulos', '''    [TestCase('claro96','96,1,0')]
    [TestCase('escuro96','96,0,0')]
    [TestCase('claro144','144,1,0')]
    [TestCase('escuro144','144,0,0')]
    [TestCase('colunaMaiorClaro','96,1,1')]
    [TestCase('colunaMaiorEscuro','96,0,1')]
    procedure ScrollRecompoeCliente(const PPI, Tema, ColunaMaior: Integer);
    [Test] procedure NumerosNulos''',1)
idx=s.index('initialization')
s=s[:idx]+'''procedure TMovimentoBancarioColunasGridTests.ScrollRecompoeCliente(
  const PPI, Tema, ColunaMaior: Integer);
var Before, After: TBitmap; DC: HDC; I, X, Y, Different, Code: Integer;
  procedure Capture(B: TBitmap);
  begin
    B.PixelFormat := pf32bit; B.SetSize(G.ClientWidth, G.ClientHeight);
    DC := GetDC(G.Handle);
    try BitBlt(B.Canvas.Handle, 0, 0, B.Width, B.Height, DC, 0, 0, SRCCOPY);
    finally ReleaseDC(G.Handle, DC); end;
  end;
begin
  FForm.FormStyle := fsStayOnTop;
  G.SetBounds(8, 8, 660, 360);
  D.Last; while D.RecordCount > 2 do D.Delete; D.First;
  for I := 0 to G.Columns.Count - 1 do G.Columns[I].Width := 160;
  if ColunaMaior = 1 then G.Columns[0].Width := 1000;
  G.SetTestPPI(PPI);
  if Tema = 0 then G.ThemeMode := dtmDark else G.ThemeMode := dtmLight;
  Pump; G.Invalidate; G.Update;
  Before := TBitmap.Create; After := TBitmap.Create;
  try
    for I := 0 to 11 do
    begin
      if I < 6 then Code := SB_LINERIGHT else Code := SB_LINELEFT;
      G.Perform(WM_HSCROLL, Code, 0); G.Update;
      Capture(Before);
      G.Invalidate; G.Update; Capture(After);
      Different := 0;
      for Y := 1 to Before.Height - 2 do
        for X := 1 to Before.Width - 2 do
          if PCardinal(NativeUInt(Before.ScanLine[Y]) + X * 4)^ <>
             PCardinal(NativeUInt(After.ScanLine[Y]) + X * 4)^ then Inc(Different);
      if Different > 0 then
      begin
        Before.SaveToFile(TPath.Combine(ExtractFilePath(ParamStr(0)), 'scroll-before.bmp'));
        After.SaveToFile(TPath.Combine(ExtractFilePath(ParamStr(0)), 'scroll-reference.bmp'));
      end;
      Assert.AreEqual(0, Different, Format('Pixels residuais apos scroll passo %d PPI %d tema %d maior %d',
        [I, PPI, Tema, ColunaMaior]));
    end;
  finally After.Free; Before.Free; end;
end;

'''+s[idx:]
p.write_bytes(s.replace('\n','\r\n').encode('cp1252'))
