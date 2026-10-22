from pathlib import Path
import shutil

c = Path(r'M:\Delphi Componentes\DAC-DelphiComponents')
r = Path(r'M:\MaxxSoft\MaxxRural\Desktop\maxxrural')
t = r / 'MaxxRural/src/Tests'
tmp = c / 'tmp/dbgrid-hover-flicker-20261021'
out = t / 'Resultados/20261021-grid-hover-flicker'
out.mkdir(parents=True, exist_ok=True)
for source, name in [(c/'Source/Controls/DAC.Components.Controls.DBGrid.pas','grid.before.pas'),
                     (c/'Source/Controls/DAC.Components.Controls.DBGrid.SurfaceBuffer.pas','surface.before.pas'),
                     (t/'Teste.MovimentoBancario.ColunasGrid.pas','tests.before.pas')]:
    if not (tmp/name).exists(): shutil.copy2(source, tmp/name)
for name in ['compilar.cmd','executar-testes.ps1']:
    shutil.copy2(t/'Resultados/20261021-grid-performance'/name, out/name)
shutil.copy2(t/'Resultados/20261021-grid-gaps/compilar-desktop.cmd', out/'compilar-desktop.cmd')
p = t / 'Teste.MovimentoBancario.ColunasGrid.pas'
s = p.read_bytes().decode('cp1252').replace('\r\n','\n')
signature = '    procedure HoverApresentaTextoSemQuadroIntermediario(const PPI, Tema, Fixada: Integer);'
assert signature not in s
s = s.replace('    [Test] procedure HoverNaoRepintaNoMesmoPontoELimpaCursor;', '''    [TestCase('fixaClaro96','96,1,1')]
    [TestCase('fixaEscuro96','96,0,1')]
    [TestCase('fixaClaro144','144,1,1')]
    [TestCase('fixaEscuro144','144,0,1')]
    [TestCase('fixaClaro192','192,1,1')]
    [TestCase('fixaEscuro192','192,0,1')]
    [TestCase('semBufferVCLClaro','96,1,0')]
    [TestCase('semBufferVCLEscuro','96,0,0')]
''' + signature + '\n    [Test] procedure HoverNaoRepintaNoMesmoPontoELimpaCursor;')
s = s.replace('uses System.SysUtils, System.Variants,', 'uses System.SyncObjs, System.SysUtils, System.Variants,', 1)
method = r'''
procedure TMovimentoBancarioColunasGridTests.HoverApresentaTextoSemQuadroIntermediario(
  const PPI, Tema, Fixada: Integer);
var R: TRect; Probe: TPoint; Background, Color: COLORREF; DC: HDC;
  X, Y, I, Monitoring, Captures, Blanks, InvalidPixels, Paints: Integer;
  Ready: TEvent; Monitor: TThread; Found: Boolean; ReportDir: string;
  function Distance(const A, B: COLORREF): Integer;
  begin
    Result := Max(Abs(Integer(GetRValue(A)) - GetRValue(B)),
      Max(Abs(Integer(GetGValue(A)) - GetGValue(B)),
          Abs(Integer(GetBValue(A)) - GetBValue(B))));
  end;
begin
  G.SetTestPPI(PPI);
  if Tema = 1 then G.ThemeMode := dtmLight else G.ThemeMode := dtmDark;
  if Fixada = 1 then C('OPCOES').PinPosition := dgpRight
  else G.DoubleBuffered := False;
  G.SetBounds(8, 8, 980, 390);
  FForm.FormStyle := fsStayOnTop;
  G.Perform(CM_MOUSELEAVE, 0, 0); G.Invalidate; G.Update; Pump;
  Assert.IsFalse(G.DoubleBuffered, 'Cenario exige o caminho sem buffer da VCL.');
  R := G.BoundsOf(C('N').Index, -1); Probe := Point(-1, -1); Found := False;
  DC := GetDC(G.Handle);
  try
    Background := GetPixel(DC, R.Left + 4, R.Top + 4);
    // Find a solid title glyph from the actual window; no assumed font raster.
    for Y := R.Top + 5 to R.Bottom - 6 do
    begin
      for X := R.Left + 5 to R.Right - 6 do
      begin
        Color := GetPixel(DC, X, Y);
        if (Color <> CLR_INVALID) and (Distance(Color, Background) > 120) then
        begin Probe := Point(X,Y); Found := True; Break; end;
      end;
      if Found then Break;
    end;
  finally ReleaseDC(G.Handle, DC); end;
  Assert.IsTrue(Found, 'Nao foi encontrado um pixel de texto no HWND.');
  Monitoring := 1; Captures := 0; Blanks := 0; InvalidPixels := 0;
  Ready := TEvent.Create(nil, True, False, ''); Monitor := nil;
  try
    Monitor := TThread.CreateAnonymousThread(
      procedure
      var SampleDC: HDC; Sample: COLORREF;
      begin
        SampleDC := GetDC(G.Handle);
        try
          while TInterlocked.CompareExchange(Monitoring, 1, 1) = 1 do
          begin
            Sample := GetPixel(SampleDC, Probe.X, Probe.Y);
            Inc(Captures);
            if Sample = CLR_INVALID then Inc(InvalidPixels)
            else if Distance(Sample, Background) <= 2 then Inc(Blanks);
            Ready.SetEvent;
            Sleep(0);
          end;
        finally ReleaseDC(G.Handle, SampleDC); end;
      end);
    Monitor.FreeOnTerminate := False; Monitor.Start;
    Assert.AreEqual(Integer(wrSignaled), Integer(Ready.WaitFor(5000)));
    Paints := G.PaintCount;
    for I := 0 to 99 do
    begin
      G.MoveAt(G.BoundsOf(C('N').Index, I mod 4).CenterPoint);
      G.Update;
    end;
  finally
    TInterlocked.Exchange(Monitoring, 0);
    if Monitor <> nil then begin Monitor.WaitFor; Monitor.Free; end;
    Ready.Free;
  end;
  ReportDir := GetEnvironmentVariable('DAC_GRID_FLICKER_OUTPUT_DIR');
  if ReportDir <> '' then
  begin
    ForceDirectories(ReportDir);
    TFile.WriteAllText(TPath.Combine(ReportDir,
      Format('probe-%d-%d-%d.txt', [PPI,Tema,Fixada])),
      Format('captures=%d blanks=%d invalid=%d paints=%d',
      [Captures, Blanks, InvalidPixels, G.PaintCount - Paints]));
  end;
  Assert.IsTrue(G.PaintCount - Paints >= 90, 'Hover nao provocou as pinturas esperadas.');
  Assert.IsTrue(Captures >= 20, 'Amostragem concorrente insuficiente.');
  Assert.AreEqual(0, InvalidPixels, 'Falha de leitura do HWND.');
  Assert.AreEqual(0, Blanks, Format('Texto sumiu em %d/%d leituras durante hover.', [Blanks,Captures]));
end;
'''
s = s.replace('procedure TMovimentoBancarioColunasGridTests.HoverNaoRepintaNoMesmoPontoELimpaCursor;', method + '\nprocedure TMovimentoBancarioColunasGridTests.HoverNaoRepintaNoMesmoPontoELimpaCursor;', 1)
p.write_bytes(s.replace('\n','\r\n').encode('cp1252'))
print('Added eight real-window hover probes to official fixture:', out)
