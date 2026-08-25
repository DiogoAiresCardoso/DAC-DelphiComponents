program DACDemoStartup;

{$APPTYPE CONSOLE}

uses
  System.Classes,
  System.IOUtils,
  System.Math,
  System.SysUtils,
  System.Types,
  System.UITypes,
  System.Variants,
  Data.DB,
  Winapi.CommCtrl,
  Winapi.Messages,
  Winapi.Windows,
  Vcl.ComCtrls,
  Vcl.Controls,
  Vcl.DBCtrls,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.Graphics,
  Vcl.Styles,
  Vcl.StdCtrls,
  Vcl.Themes,
  DAC.Components.Controls.ComboBox,
  DAC.Components.Controls.DataAware,
  DAC.Components.Controls.DataAware.Lookup,
  DAC.Components.Controls.DataAware.Navigator,
  DAC.Components.Controls.DateTimePicker,
  DAC.Components.Controls.ScrollContainer,
  DAC.Components.Controls.SystemText,
  DAC.Components.Controls.Tabs,
  DAC.Components.DesignSystem.ColorTokens,
  DAC.Components.DesignSystem.ComponentStyle,
  DAC.Components.DesignSystem.ControlTokens,
  DAC.Components.DesignSystem.DemoTokens,
  DAC.Components.DesignSystem.Theme,
  DAC.Components.Hooks.Register,
  Demo.Principal in '..\demo\Demo.Principal.pas' {Form1};

{$R '..\demo\Demo.res'}

const
  WM_DAC_STARTUP_TEARDOWN_PROBE = WM_APP + 181;
  DACFORM_DIAG_EXTERNAL_DATE = 'DAC.DB030.ExternalDate';

type
  TDACRGBQuadArray = array[0..(MaxInt div SizeOf(TRGBQuad)) - 1] of TRGBQuad;
  PDACRGBQuadArray = ^TDACRGBQuadArray;
  TTabSheetAccess = class(TTabSheet);
  TWinControlAccess = class(TWinControl);

  TStartupExceptionProbe = class
  public
    CaptureCount: Integer;
    MessageText: string;
    procedure CaptureException(const AContext: string; E: Exception);
    procedure OnApplicationException(Sender: TObject; E: Exception);
  end;

  TLookupTabEventProbe = class
  public
    ClickCount: Integer;
    FieldChangeCount: Integer;
    PreviousFieldChange: TFieldNotifyEvent;
    PreviousLookupClick: TNotifyEvent;
    procedure FieldChanged(Sender: TField);
    procedure LookupClicked(Sender: TObject);
  end;

  EPostedTeardownProbe = class(Exception);

  TPostedTeardownExceptionForm = class(TForm)
  private
    FRaiseOnDestroy: Boolean;
  protected
    procedure WMPostedTeardownException(var AMessage: TMessage);
      message WM_DAC_STARTUP_TEARDOWN_PROBE;
  public
    destructor Destroy; override;
    property RaiseOnDestroy: Boolean read FRaiseOnDestroy
      write FRaiseOnDestroy;
  end;

  EPostedTeardownFreeProbe = class(Exception);

var
  GWorstDateMaxMicroseconds: Int64;
  GWorstDateP95Microseconds: Int64;
  GPostedTeardownDestroyAttempts: Integer;
  GStage: string;
  GUnexpectedWindowSnapshot: string;

procedure TraceStartupStage(const AStage: string);
var
  LPath: string;
begin
  LPath := TPath.Combine(GetCurrentDir,
    'Build\Diagnostics\dac-demo-startup-stage.log');
  ForceDirectories(ExtractFilePath(LPath));
  TFile.AppendAllText(LPath, FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now) +
    ' ' + AStage + sLineBreak, TEncoding.UTF8);
end;

procedure TStartupExceptionProbe.CaptureException(const AContext: string;
  E: Exception);
begin
  Inc(CaptureCount);
  if MessageText <> '' then
    MessageText := MessageText + ' | ';
  MessageText := MessageText + AContext + ' ' + E.ClassName + ': ' +
    E.Message;
end;

procedure TStartupExceptionProbe.OnApplicationException(Sender: TObject;
  E: Exception);
begin
  CaptureException(GStage, E);
end;

procedure TLookupTabEventProbe.FieldChanged(Sender: TField);
begin
  Inc(FieldChangeCount);
  if Assigned(PreviousFieldChange) then
    PreviousFieldChange(Sender);
end;

procedure TLookupTabEventProbe.LookupClicked(Sender: TObject);
begin
  Inc(ClickCount);
  if Assigned(PreviousLookupClick) then
    PreviousLookupClick(Sender);
end;

procedure TPostedTeardownExceptionForm.WMPostedTeardownException(
  var AMessage: TMessage);
begin
  AMessage.Result := 0;
  raise EPostedTeardownProbe.Create(
    'excecao postada intencionalmente durante drain');
end;

destructor TPostedTeardownExceptionForm.Destroy;
var
  LRaiseOnDestroy: Boolean;
begin
  Inc(GPostedTeardownDestroyAttempts);
  LRaiseOnDestroy := FRaiseOnDestroy;
  inherited;
  if LRaiseOnDestroy then
    raise EPostedTeardownFreeProbe.Create(
      'excecao intencional depois de destruir o host');
end;

procedure Require(const ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create(AMessage);
end;

procedure TrackNativeDatePerformance(
  const AMetrics: TDACNativeDateTimePickerPaintMetrics);
begin
  GWorstDateMaxMicroseconds := Max(GWorstDateMaxMicroseconds,
    AMetrics.MaxMicroseconds);
  GWorstDateP95Microseconds := Max(GWorstDateP95Microseconds,
    AMetrics.P95Microseconds);
end;

procedure PumpMessages(const AMilliseconds: Cardinal);
var
  LStarted: Cardinal;
begin
  LStarted := GetTickCount;
  repeat
    Application.ProcessMessages;
  until Cardinal(GetTickCount - LStarted) >= AMilliseconds;
end;

procedure RequireNativeTokenSurface(const AControl: TWinControl;
  const AExpected: TAlphaColor; const AScenario: string;
  const AExpectedText: TAlphaColor = 0);
const
  ColorTolerance = 12;
  PaintTimeoutMs = 1000;
var
  LBitmap: TBitmap;
  LControlDC: HDC;
  LExpected: TColor;
  LMatchCount: Integer;
  LMessageResult: DWORD_PTR;
  LPixel: TColor;
  LRequiredCount: Integer;
  LSampleCount: Integer;
  LTextExpected: TColor;
  LTextMatchCount: Integer;
  X: Integer;
  Y: Integer;
  function MatchesExpected(const AColor: TColor): Boolean;
  begin
    Result :=
      (Abs(Integer(GetRValue(AColor)) - Integer(GetRValue(LExpected))) <=
        ColorTolerance) and
      (Abs(Integer(GetGValue(AColor)) - Integer(GetGValue(LExpected))) <=
        ColorTolerance) and
      (Abs(Integer(GetBValue(AColor)) - Integer(GetBValue(LExpected))) <=
        ColorTolerance);
  end;
  function MatchesText(const AColor: TColor): Boolean;
  const
    TextTolerance = 40;
  begin
    Result :=
      (Abs(Integer(GetRValue(AColor)) -
        Integer(GetRValue(LTextExpected))) <= TextTolerance) and
      (Abs(Integer(GetGValue(AColor)) -
        Integer(GetGValue(LTextExpected))) <= TextTolerance) and
      (Abs(Integer(GetBValue(AColor)) -
        Integer(GetBValue(LTextExpected))) <= TextTolerance);
  end;
begin
  Require((AControl <> nil) and AControl.HandleAllocated and
    (AControl.ClientWidth >= 8) and (AControl.ClientHeight >= 6),
    'Surface nativa indisponivel em ' + AScenario + '.');
  LBitmap := TBitmap.Create;
  try
    LBitmap.PixelFormat := pf32bit;
    LBitmap.SetSize(AControl.ClientWidth, AControl.ClientHeight);
    LBitmap.Canvas.Brush.Color := clFuchsia;
    LBitmap.Canvas.FillRect(Rect(0, 0, LBitmap.Width, LBitmap.Height));
    LMessageResult := 0;
    InvalidateRect(AControl.Handle, nil, False);
    Require(SendMessageTimeout(AControl.Handle, WM_PAINT,
      0, 0, SMTO_ABORTIFHUNG or SMTO_BLOCK,
      PaintTimeoutMs, @LMessageResult) <> 0,
      'Timeout no paint localizado em ' + AScenario + '.');
    LControlDC := GetDC(AControl.Handle);
    Require(LControlDC <> 0,
      'DC nativo indisponivel em ' + AScenario + '.');
    try
      Require(BitBlt(LBitmap.Canvas.Handle, 0, 0, LBitmap.Width,
        LBitmap.Height, LControlDC, 0, 0, SRCCOPY),
        'Falha ao capturar surface nativa em ' + AScenario + '.');
    finally
      ReleaseDC(AControl.Handle, LControlDC);
    end;
    LExpected := ColorToRGB(TDACComponentColors.ToVclColor(
      TDACComponentColors.Normalize(AExpected)));
    LTextExpected := ColorToRGB(TDACComponentColors.ToVclColor(
      TDACComponentColors.Normalize(AExpectedText)));
    LMatchCount := 0;
    LTextMatchCount := 0;
    LSampleCount := 0;
    for Y := 2 to LBitmap.Height - 3 do
      for X := 2 to LBitmap.Width - 3 do
      begin
        LPixel := ColorToRGB(LBitmap.Canvas.Pixels[X, Y]);
        Inc(LSampleCount);
        if MatchesExpected(LPixel) then
          Inc(LMatchCount);
        if (AExpectedText <> 0) and MatchesText(LPixel) then
          Inc(LTextMatchCount);
      end;
    LRequiredCount := Max(8, LSampleCount div 20);
    Require(LMatchCount >= LRequiredCount,
      Format('%s nao pintou a surface efetiva do token (%d/%d pixels; minimo=%d).',
        [AScenario, LMatchCount, LSampleCount, LRequiredCount]));
    if AExpectedText <> 0 then
      Require(LTextMatchCount >= 3,
        Format('%s nao pintou texto nativo com o token (%d pixels).',
          [AScenario, LTextMatchCount]));
  finally
    LBitmap.Free;
  end;
end;

procedure RequireNativeDateCentralSurface(const AControl: TWinControl;
  const AExpectedBackground, AExpectedText: TAlphaColor;
  const AScenario: string; const AExpectNativeSelection: Boolean = False);
const
  BackgroundTolerance = 18;
  PaintTimeoutMs = 1000;
  TextTolerance = 40;
  WindowTolerance = 12;
var
  LBackground: TColor;
  LBackgroundCount: Integer;
  LBitmap: TBitmap;
  LCenterPixel: TColor;
  LCentralRect: TRect;
  LControlDC: HDC;
  LDateInfo: TDateTimePickerInfo;
  LExpectDark: Boolean;
  LMessageResult: DWORD_PTR;
  LPixel: TColor;
  LSampleCount: Integer;
  LSaturatedCount: Integer;
  LText: TColor;
  LTextCount: Integer;
  LWindow: TColor;
  LWindowCount: Integer;
  X: Integer;
  Y: Integer;
  function MatchesColor(const AColor, AExpected: TColor;
    const ATolerance: Integer): Boolean;
  begin
    Result :=
      (Abs(Integer(GetRValue(AColor)) - Integer(GetRValue(AExpected))) <=
        ATolerance) and
      (Abs(Integer(GetGValue(AColor)) - Integer(GetGValue(AExpected))) <=
        ATolerance) and
      (Abs(Integer(GetBValue(AColor)) - Integer(GetBValue(AExpected))) <=
        ATolerance);
  end;
begin
  Require((AControl <> nil) and AControl.HandleAllocated and
    (AControl.ClientWidth >= 24) and (AControl.ClientHeight >= 12),
    'Client central nativo indisponivel em ' + AScenario + '.');
  LBitmap := TBitmap.Create;
  try
    ZeroMemory(@LDateInfo, SizeOf(LDateInfo));
    LDateInfo.cbSize := SizeOf(LDateInfo);
    DateTime_GetDateTimePickerInfo(AControl.Handle, LDateInfo);
    LBitmap.PixelFormat := pf32bit;
    LBitmap.SetSize(AControl.ClientWidth, AControl.ClientHeight);
    LBitmap.Canvas.Brush.Color := clFuchsia;
    LBitmap.Canvas.FillRect(Rect(0, 0, LBitmap.Width, LBitmap.Height));
    LMessageResult := 0;
    InvalidateRect(AControl.Handle, nil, False);
    Require(SendMessageTimeout(AControl.Handle, WM_PAINT,
      0, 0, SMTO_ABORTIFHUNG or SMTO_BLOCK,
      PaintTimeoutMs, @LMessageResult) <> 0,
      'Timeout no paint central localizado em ' + AScenario + '.');
    LControlDC := GetDC(AControl.Handle);
    Require(LControlDC <> 0,
      'DC nativo central indisponivel em ' + AScenario + '.');
    try
      Require(BitBlt(LBitmap.Canvas.Handle, 0, 0, LBitmap.Width,
        LBitmap.Height, LControlDC, 0, 0, SRCCOPY),
        'Falha ao capturar client central nativo em ' + AScenario + '.');
    finally
      ReleaseDC(AControl.Handle, LControlDC);
    end;

    { The physical P2 was in the value client itself ("01/05/2025"), while
      the former whole-HWND probe could pass on the Skia-adjacent edge. Keep
      the sample inside the left/central value band and away from all borders
      and the clipped native dropdown button. }
    LCentralRect := Rect(
      Max(4, LBitmap.Width div 10),
      Max(3, LBitmap.Height div 4),
      Min(LBitmap.Width - 8, (LBitmap.Width * 4) div 5),
      Min(LBitmap.Height - 3, (LBitmap.Height * 3) div 4));
    Require((LCentralRect.Right > LCentralRect.Left) and
      (LCentralRect.Bottom > LCentralRect.Top),
      'Retangulo central invalido em ' + AScenario + '.');
    LCenterPixel := ColorToRGB(LBitmap.Canvas.Pixels[
      (LCentralRect.Left + LCentralRect.Right) div 2,
      (LCentralRect.Top + LCentralRect.Bottom) div 2]);

    LBackground := ColorToRGB(TDACComponentColors.ToVclColor(
      TDACComponentColors.Normalize(AExpectedBackground)));
    LText := ColorToRGB(TDACComponentColors.ToVclColor(
      TDACComponentColors.Normalize(AExpectedText)));
    LWindow := ColorToRGB(clWindow);
    LExpectDark := TDACComponentColors.IsDarkSurface(AExpectedBackground);
    LBackgroundCount := 0;
    LTextCount := 0;
    LWindowCount := 0;
    LSampleCount := 0;
    LSaturatedCount := 0;
    for Y := LCentralRect.Top to LCentralRect.Bottom - 1 do
      for X := LCentralRect.Left to LCentralRect.Right - 1 do
      begin
        LPixel := ColorToRGB(LBitmap.Canvas.Pixels[X, Y]);
        Inc(LSampleCount);
        if MatchesColor(LPixel, LBackground, BackgroundTolerance) then
          Inc(LBackgroundCount);
        if MatchesColor(LPixel, LText, TextTolerance) then
          Inc(LTextCount);
        if MatchesColor(LPixel, LWindow, WindowTolerance) then
          Inc(LWindowCount);
        if (Max(GetRValue(LPixel),
          Max(GetGValue(LPixel), GetBValue(LPixel))) -
          Min(GetRValue(LPixel),
          Min(GetGValue(LPixel), GetBValue(LPixel)))) > 80 then
          Inc(LSaturatedCount);
      end;

    Require((LBackgroundCount * 100) >= (LSampleCount * 45),
      Format('%s: DateTimeBackground nao predomina no client central ' +
        '(%d/%d pixels; hwndEdit=%d; center=$%.6x).',
        [AScenario, LBackgroundCount, LSampleCount, LDateInfo.hwndEdit,
         LCenterPixel]));
    if LExpectDark then
      Require((LWindowCount * 100) <= (LSampleCount * 10),
        Format('%s: client central ainda usa clWindow/branco no Dark ' +
          '(%d/%d pixels).', [AScenario, LWindowCount, LSampleCount]));
    Require(LTextCount >= 3,
      Format('%s: texto nativo nao usa DateTimeText no client central ' +
        '(%d pixels).', [AScenario, LTextCount]));
    if AExpectNativeSelection then
      Require(LSaturatedCount >= 6,
        Format('%s: selecao segmentada nativa desapareceu do client central ' +
          '(%d pixels saturados).', [AScenario, LSaturatedCount]));
  finally
    LBitmap.Free;
  end;
end;

procedure CaptureNativeDateClient(const AControl: TDateTimePicker;
  const ABitmap: TBitmap; const AScenario: string);
var
  LControlDC: HDC;
begin
  LControlDC := GetDC(AControl.Handle);
  Require(LControlDC <> 0,
    AScenario + ': DC indisponivel para captura anti-acumulo.');
  try
    Require(BitBlt(ABitmap.Canvas.Handle, 0, 0, ABitmap.Width,
      ABitmap.Height, LControlDC, 0, 0, SRCCOPY),
      AScenario + ': BitBlt falhou na captura anti-acumulo.');
  finally
    ReleaseDC(AControl.Handle, LControlDC);
  end;
end;

function NativeDateSaturatedBounds(const ABitmap: TBitmap): TRect;
const
  SaturationThreshold = 80;
var
  LBottom: Integer;
  LFound: Boolean;
  LLeft: Integer;
  LMaximum: Integer;
  LMinimum: Integer;
  LPixel: TRGBQuad;
  LRight: Integer;
  LRow: PDACRGBQuadArray;
  LTop: Integer;
  X: Integer;
  Y: Integer;
begin
  LBottom := -1;
  LFound := False;
  LLeft := ABitmap.Width;
  LRight := -1;
  LTop := ABitmap.Height;
  for Y := 0 to ABitmap.Height - 1 do
  begin
    LRow := PDACRGBQuadArray(ABitmap.ScanLine[Y]);
    for X := 0 to ABitmap.Width - 1 do
    begin
      LPixel := LRow^[X];
      LMaximum := Max(LPixel.rgbRed,
        Max(LPixel.rgbGreen, LPixel.rgbBlue));
      LMinimum := Min(LPixel.rgbRed,
        Min(LPixel.rgbGreen, LPixel.rgbBlue));
      if (LMaximum - LMinimum) <= SaturationThreshold then
        Continue;
      LFound := True;
      LLeft := Min(LLeft, X);
      LTop := Min(LTop, Y);
      LRight := Max(LRight, X);
      LBottom := Max(LBottom, Y);
    end;
  end;
  if not LFound then
    Exit(Rect(0, 0, 0, 0));
  Result := Rect(Max(0, LLeft - 2), Max(0, LTop - 2),
    Min(ABitmap.Width, LRight + 3), Min(ABitmap.Height, LBottom + 3));
end;

function NativeDateFrameDifferenceCount(const ABaseline, ACurrent: TBitmap;
  const AMask: TRect): Integer;
var
  LBaselinePixel: TRGBQuad;
  LBaselineRow: PDACRGBQuadArray;
  LCurrentPixel: TRGBQuad;
  LCurrentRow: PDACRGBQuadArray;
  X: Integer;
  Y: Integer;
begin
  Result := 0;
  for Y := 0 to ABaseline.Height - 1 do
  begin
    LBaselineRow := PDACRGBQuadArray(ABaseline.ScanLine[Y]);
    LCurrentRow := PDACRGBQuadArray(ACurrent.ScanLine[Y]);
    for X := 0 to ABaseline.Width - 1 do
    begin
      if PtInRect(AMask, Point(X, Y)) then
        Continue;
      LBaselinePixel := LBaselineRow^[X];
      LCurrentPixel := LCurrentRow^[X];
      if (LBaselinePixel.rgbRed <> LCurrentPixel.rgbRed) or
        (LBaselinePixel.rgbGreen <> LCurrentPixel.rgbGreen) or
        (LBaselinePixel.rgbBlue <> LCurrentPixel.rgbBlue) then
        Inc(Result);
    end;
  end;
end;

procedure CaptureNativeDatePipelineArtifacts(
  const ADate: TDACDBDateTimePicker; const APrefix: string);
var
  LDirectory: string;
  LFinal: TBitmap;
  LPostRemap: TBitmap;
  LPreRemap: TBitmap;
  procedure PrepareBitmap(const ABitmap: TBitmap);
  begin
    ABitmap.PixelFormat := pf32bit;
    ABitmap.SetSize(ADate.PickerControl.ClientWidth,
      ADate.PickerControl.ClientHeight);
  end;
  procedure RequireGeometryPreserved(const APreRemap,
    APostRemap: TBitmap);
  var
    LPostBackground: TRGBQuad;
    LPostForeground: Boolean;
    LPostRow: PDACRGBQuadArray;
    LPreBackground: TRGBQuad;
    LPreForeground: Boolean;
    LPreRow: PDACRGBQuadArray;
    LStructuralPixels: Integer;
    X: Integer;
    Y: Integer;
    function SamePixel(const ALeft, ARight: TRGBQuad): Boolean;
    begin
      Result := (ALeft.rgbRed = ARight.rgbRed) and
        (ALeft.rgbGreen = ARight.rgbGreen) and
        (ALeft.rgbBlue = ARight.rgbBlue);
    end;
  begin
    LPreRow := PDACRGBQuadArray(
      APreRemap.ScanLine[ApreRemap.Height div 2]);
    LPostRow := PDACRGBQuadArray(
      APostRemap.ScanLine[APostRemap.Height div 2]);
    LPreBackground := LPreRow^[APreRemap.Width div 2];
    LPostBackground := LPostRow^[APostRemap.Width div 2];
    LStructuralPixels := 0;
    for Y := 0 to APreRemap.Height - 1 do
    begin
      LPreRow := PDACRGBQuadArray(APreRemap.ScanLine[Y]);
      LPostRow := PDACRGBQuadArray(APostRemap.ScanLine[Y]);
      for X := 0 to APreRemap.Width - 1 do
      begin
        LPreForeground := not SamePixel(LPreRow^[X], LPreBackground);
        LPostForeground := not SamePixel(LPostRow^[X], LPostBackground);
        Require(LPreForeground = LPostForeground,
          Format('Remap alterou geometria nativa em (%d,%d): ' +
            'pixel duplicado, removido ou ghost.', [X, Y]));
        if LPreForeground then
          Inc(LStructuralPixels);
      end;
    end;
    Require(LStructuralPixels >= 32,
      'Frame nativo sem estrutura suficiente para validar glyph/bordas.');
  end;
  procedure RequirePresentedValuePreserved(const APostRemap,
    AFinal: TBitmap);
  var
    LFinalRow: PDACRGBQuadArray;
    LPostRow: PDACRGBQuadArray;
    X: Integer;
    Y: Integer;
  begin
    { The suite-owned calendar chrome legitimately replaces the clipped
      native dropdown at the right. The value band itself must arrive at the
      final HWND DC byte-for-byte after the single presentation. }
    for Y := 2 to APostRemap.Height - 3 do
    begin
      LPostRow := PDACRGBQuadArray(APostRemap.ScanLine[Y]);
      LFinalRow := PDACRGBQuadArray(AFinal.ScanLine[Y]);
      for X := 0 to Min(100, APostRemap.Width div 2) - 1 do
        Require((LPostRow^[X].rgbRed = LFinalRow^[X].rgbRed) and
          (LPostRow^[X].rgbGreen = LFinalRow^[X].rgbGreen) and
          (LPostRow^[X].rgbBlue = LFinalRow^[X].rgbBlue),
          Format('Apresentacao final alterou glyph em (%d,%d).', [X, Y]));
    end;
  end;
begin
  LDirectory := IncludeTrailingPathDelimiter(
    'Build\Tests\Evidence\MEM-DEL-DB-011\pipeline');
  ForceDirectories(LDirectory);
  LPreRemap := TBitmap.Create;
  LPostRemap := TBitmap.Create;
  LFinal := TBitmap.Create;
  try
    PrepareBitmap(LPreRemap);
    PrepareBitmap(LPostRemap);
    PrepareBitmap(LFinal);
    DACNativeDateTimePickerCapturePipeline(ADate.PickerControl,
      LPreRemap, LPostRemap, LFinal);
    RequireGeometryPreserved(LPreRemap, LPostRemap);
    RequirePresentedValuePreserved(LPostRemap, LFinal);
    LPreRemap.SaveToFile(LDirectory + APrefix + '-a-pre-remap.bmp');
    LPostRemap.SaveToFile(LDirectory + APrefix + '-b-post-remap.bmp');
    LFinal.SaveToFile(LDirectory + APrefix + '-c-final.bmp');
  finally
    LFinal.Free;
    LPostRemap.Free;
    LPreRemap.Free;
  end;
end;

procedure RequireNativeDatePaintStability(
  const ADate: TDACDBDateTimePicker; const AFocused: Boolean;
  const AScenario: string);
const
  PaintCount = 32;
  PaintTimeoutMs = 1000;
  WarmupCount = 4;
var
  LBaseline: TBitmap;
  LBefore: TDACNativeDateTimePickerPaintMetrics;
  LCurrent: TBitmap;
  LDifferences: Integer;
  LMask: TRect;
  LMessageResult: DWORD_PTR;
  LMetrics: TDACNativeDateTimePickerPaintMetrics;
  LPaint: Integer;
begin
  Require((ADate <> nil) and (ADate.PickerControl <> nil) and
    ADate.PickerControl.HandleAllocated,
    AScenario + ': Date indisponivel para gate anti-acumulo.');
  Require(ADate.PickerControl.Focused = AFocused,
    AScenario + ': estado de foco inesperado no gate anti-acumulo.');

  LBaseline := TBitmap.Create;
  LCurrent := TBitmap.Create;
  try
    LBaseline.PixelFormat := pf32bit;
    LCurrent.PixelFormat := pf32bit;
    LBaseline.SetSize(ADate.PickerControl.ClientWidth,
      ADate.PickerControl.ClientHeight);
    LCurrent.SetSize(LBaseline.Width, LBaseline.Height);

    for LPaint := 1 to WarmupCount do
    begin
      LMessageResult := 0;
      InvalidateRect(ADate.PickerControl.Handle, nil, False);
      Require(SendMessageTimeout(ADate.PickerControl.Handle, WM_PAINT,
        0, 0, SMTO_ABORTIFHUNG or SMTO_BLOCK,
        PaintTimeoutMs, @LMessageResult) <> 0,
        AScenario + ': timeout no warmup anti-acumulo.');
    end;

    LMask := Rect(0, 0, 0, 0);
    DACNativeDateTimePickerResetPaintMetrics(ADate.PickerControl);
    LBefore := DACNativeDateTimePickerPaintMetrics(ADate.PickerControl);
    for LPaint := 1 to PaintCount do
    begin
      LMessageResult := 0;
      InvalidateRect(ADate.PickerControl.Handle, nil, False);
      Require(SendMessageTimeout(ADate.PickerControl.Handle, WM_PAINT,
        0, 0, SMTO_ABORTIFHUNG or SMTO_BLOCK,
        PaintTimeoutMs, @LMessageResult) <> 0,
        Format('%s: timeout no frame anti-acumulo %d.',
          [AScenario, LPaint]));
      CaptureNativeDateClient(ADate.PickerControl, LCurrent, AScenario);
      if LPaint = 1 then
      begin
        Require(BitBlt(LBaseline.Canvas.Handle, 0, 0, LBaseline.Width,
          LBaseline.Height, LCurrent.Canvas.Handle, 0, 0, SRCCOPY),
          AScenario + ': falha ao armazenar baseline anti-acumulo.');
        if AFocused then
        begin
          LMask := NativeDateSaturatedBounds(LBaseline);
          Require(not IsRectEmpty(LMask),
            AScenario + ': selecao/caret focado nao gerou mascara.');
        end;
      end
      else
      begin
        LDifferences := NativeDateFrameDifferenceCount(
          LBaseline, LCurrent, LMask);
        Require(LDifferences = 0,
          Format('%s: frame %d acumulou/alterou %d pixels fora da ' +
            'selecao/caret.', [AScenario, LPaint, LDifferences]));
      end;
    end;

    LMetrics := DACNativeDateTimePickerPaintMetrics(
      ADate.PickerControl);
    TrackNativeDatePerformance(LMetrics);
    Require((LMetrics.BufferAllocations = LBefore.BufferAllocations) and
      (LMetrics.BufferResizes = LBefore.BufferResizes),
      Format('%s: gate anti-acumulo alocou/redimensionou buffer ' +
        '(alloc %d->%d; resize %d->%d).',
        [AScenario, LBefore.BufferAllocations, LMetrics.BufferAllocations,
         LBefore.BufferResizes, LMetrics.BufferResizes]));
    Require((LMetrics.NativeRenders = PaintCount) and
      (LMetrics.Paints = PaintCount) and
      (LMetrics.Presents = PaintCount),
      Format('%s: gate anti-acumulo perdeu 1:1:1 (%d/%d/%d).',
        [AScenario, LMetrics.NativeRenders, LMetrics.Paints,
         LMetrics.Presents]));
    Require((LMetrics.MaxMicroseconds < 5000) and
      (LMetrics.P95Microseconds < 5000),
      Format('%s: gate anti-acumulo excedeu 5 ms ' +
        '(max=%d us; p95=%d us).',
        [AScenario, LMetrics.MaxMicroseconds,
         LMetrics.P95Microseconds]));
  finally
    LCurrent.Free;
    LBaseline.Free;
  end;
end;

procedure RequireNativeDateFocusTransitionStability(
  const ADate: TDACDBDateTimePicker; const ABlurTarget: TWinControl;
  const AScenario: string);
const
  TransitionCount = 16;
  PaintTimeoutMs = 1000;
var
  LBaseline: TBitmap;
  LCurrent: TBitmap;
  LDifferences: Integer;
  LMessageResult: DWORD_PTR;
  LTransition: Integer;
  procedure PaintNativeDate;
  begin
    LMessageResult := 0;
    InvalidateRect(ADate.PickerControl.Handle, nil, False);
    Require(SendMessageTimeout(ADate.PickerControl.Handle, WM_PAINT,
      0, 0, SMTO_ABORTIFHUNG or SMTO_BLOCK,
      PaintTimeoutMs, @LMessageResult) <> 0,
      AScenario + ': timeout no paint de transicao de foco.');
  end;
begin
  Require((ADate <> nil) and (ADate.PickerControl <> nil) and
    ADate.PickerControl.HandleAllocated and (ABlurTarget <> nil) and
    ABlurTarget.HandleAllocated,
    AScenario + ': controles indisponiveis para transicao de foco.');
  Require(not ADate.PickerControl.Focused,
    AScenario + ': Date deveria iniciar desfocado.');

  LBaseline := TBitmap.Create;
  LCurrent := TBitmap.Create;
  try
    LBaseline.PixelFormat := pf32bit;
    LCurrent.PixelFormat := pf32bit;
    LBaseline.SetSize(ADate.PickerControl.ClientWidth,
      ADate.PickerControl.ClientHeight);
    LCurrent.SetSize(LBaseline.Width, LBaseline.Height);
    PaintNativeDate;
    CaptureNativeDateClient(ADate.PickerControl, LBaseline, AScenario);

    for LTransition := 1 to TransitionCount do
    begin
      ADate.PickerControl.SetFocus;
      Require(ADate.PickerControl.Focused,
        AScenario + ': Date nao recebeu foco na transicao.');
      PaintNativeDate;
      ABlurTarget.SetFocus;
      Require(not ADate.PickerControl.Focused,
        AScenario + ': Date nao perdeu foco na transicao.');
      PaintNativeDate;
      CaptureNativeDateClient(ADate.PickerControl, LCurrent, AScenario);
      LDifferences := NativeDateFrameDifferenceCount(
        LBaseline, LCurrent, Rect(0, 0, 0, 0));
      Require(LDifferences = 0,
        Format('%s: transicao %d deixou %d pixels residuais no frame ' +
          'desfocado.', [AScenario, LTransition, LDifferences]));
    end;
  finally
    LCurrent.Free;
    LBaseline.Free;
  end;
end;

procedure RequireNativeDateContentDelegation(
  const ADate: TDACDBDateTimePicker; const AExpected: TAlphaColor;
  const AScenario: string);
var
  LBefore: Cardinal;
  LHandle: HWND;
  LValue: TDateTime;
begin
  Require((ADate <> nil) and (ADate.PickerControl <> nil) and
    ADate.PickerControl.HandleAllocated,
    AScenario + ': SysDateTimePick32 indisponivel.');
  ADate.PickerControl.SetFocus;
  PumpMessages(30);
  Require(ADate.PickerControl.Focused,
    AScenario + ': SysDateTimePick32 nao recebeu foco/segmento nativo.');
  ADate.PickerControl.Perform(WM_KEYDOWN, VK_RIGHT, 0);
  ADate.PickerControl.Perform(WM_KEYUP, VK_RIGHT, 0);
  LHandle := ADate.PickerControl.Handle;
  LValue := ADate.DateTime;
  LBefore := DACNativeDateTimePickerFocusedPaintDelegations(
    ADate.PickerControl);
  RequireNativeDateCentralSurface(ADate.PickerControl, AExpected,
    TDACComponentStyle.ResolveForSurface(
      ADate, dtmInherit).Tokens.Controls.DateTimeText,
    AScenario + ' focado', True);
  Require(DACNativeDateTimePickerFocusedPaintDelegations(
      ADate.PickerControl) > LBefore,
    AScenario + ': hook nao delegou o conteudo focado ao common control.');
  Require((ADate.PickerControl.Handle = LHandle) and
    ADate.PickerControl.Focused and (ADate.DateTime = LValue),
    AScenario +
      ': paint recriou o HWND ou alterou foco/segmento/valor nativo.');
  ADate.PickerControl.Perform(WM_KEYDOWN, VK_F4, 0);
  ADate.PickerControl.Perform(WM_KEYUP, VK_F4, 0);
  PumpMessages(30);
  Require(ADate.DroppedDown,
    AScenario + ': F4 deixou de abrir o popup apos o paint focado.');
  PostMessage(ADate.Handle, WM_KEYDOWN, VK_ESCAPE, 0);
  PostMessage(ADate.Handle, WM_KEYUP, VK_ESCAPE, 0);
  PumpMessages(50);
  Require(not ADate.DroppedDown,
    AScenario + ': Escape deixou de fechar o popup apos o paint focado.');
end;

procedure RequireNativeDateStablePaintStress(
  const ADate: TDACDBDateTimePicker; const AScenario: string);
const
  PaintsPerRound = 32;
  PaintTimeoutMs = 1000;
  StressRounds = 3;
var
  LBefore: TDACNativeDateTimePickerPaintMetrics;
  LMessageResult: DWORD_PTR;
  LMetrics: TDACNativeDateTimePickerPaintMetrics;
  LPaint: Integer;
  LRound: Integer;
begin
  Require((ADate <> nil) and (ADate.PickerControl <> nil) and
    ADate.PickerControl.HandleAllocated,
    AScenario + ': Date indisponivel para stress de paint.');
  Require(TDACComponentColors.IsDarkSurface(
      TDACComponentStyle.ResolveForSurface(
        ADate, dtmInherit).Tokens.Controls.DateTimeBackground),
    AScenario + ': stress buffered deve executar somente no Dark.');

  { Warm-up primes every stable VCL/GDI object before counters are reset. }
  for LPaint := 1 to 4 do
  begin
    LMessageResult := 0;
    InvalidateRect(ADate.PickerControl.Handle, nil, False);
    Require(SendMessageTimeout(ADate.PickerControl.Handle, WM_PAINT,
      0, 0, SMTO_ABORTIFHUNG or SMTO_BLOCK,
      PaintTimeoutMs, @LMessageResult) <> 0,
      AScenario + ': timeout no warm-up do paint buffered.');
  end;

  for LRound := 1 to StressRounds do
  begin
    DACNativeDateTimePickerResetPaintMetrics(ADate.PickerControl);
    LBefore := DACNativeDateTimePickerPaintMetrics(ADate.PickerControl);
    for LPaint := 1 to PaintsPerRound do
    begin
      LMessageResult := 0;
      InvalidateRect(ADate.PickerControl.Handle, nil, False);
      Require(SendMessageTimeout(ADate.PickerControl.Handle, WM_PAINT,
        0, 0, SMTO_ABORTIFHUNG or SMTO_BLOCK,
        PaintTimeoutMs, @LMessageResult) <> 0,
        Format('%s: timeout no paint buffered %d/%d.',
          [AScenario, LRound, LPaint]));
    end;
    LMetrics := DACNativeDateTimePickerPaintMetrics(
      ADate.PickerControl);
    TrackNativeDatePerformance(LMetrics);
    Require((LMetrics.BufferAllocations = LBefore.BufferAllocations) and
      (LMetrics.BufferResizes = LBefore.BufferResizes),
      Format('%s: hot path alocou/redimensionou buffer no round %d ' +
        '(alloc %d->%d; resize %d->%d).',
        [AScenario, LRound,
         LBefore.BufferAllocations, LMetrics.BufferAllocations,
         LBefore.BufferResizes, LMetrics.BufferResizes]));
    Require((LMetrics.Paints = PaintsPerRound) and
      (LMetrics.NativeRenders = PaintsPerRound) and
      (LMetrics.Presents = PaintsPerRound),
      Format('%s: round %d nao manteve render/paint/present 1:1 ' +
        '(%d/%d/%d; esperado=%d).',
        [AScenario, LRound, LMetrics.NativeRenders, LMetrics.Paints,
         LMetrics.Presents, PaintsPerRound]));
    Require((LMetrics.MaxMicroseconds < 5000) and
      (LMetrics.P95Microseconds < 5000),
      Format('%s: round %d excedeu 5 ms (max=%d us; p95=%d us).',
        [AScenario, LRound, LMetrics.MaxMicroseconds,
         LMetrics.P95Microseconds]));
  end;
end;

procedure RequireNativeDateResizeCache(
  const ADate: TDACDBDateTimePicker; const AScenario: string);
var
  LAfter: TDACNativeDateTimePickerPaintMetrics;
  LBefore: TDACNativeDateTimePickerPaintMetrics;
  LOriginalWidth: Integer;
begin
  LOriginalWidth := ADate.Width;
  LBefore := DACNativeDateTimePickerPaintMetrics(ADate.PickerControl);
  ADate.Width := LOriginalWidth + 17;
  PumpMessages(30);
  LAfter := DACNativeDateTimePickerPaintMetrics(ADate.PickerControl);
  Require((LAfter.BufferAllocations = LBefore.BufferAllocations) and
    (LAfter.BufferResizes = LBefore.BufferResizes + 1),
    Format('%s: resize crescente nao ajustou cache exatamente uma vez ' +
      '(alloc %d->%d; resize %d->%d).',
      [AScenario, LBefore.BufferAllocations, LAfter.BufferAllocations,
       LBefore.BufferResizes, LAfter.BufferResizes]));
  LBefore := LAfter;
  ADate.Width := LOriginalWidth;
  PumpMessages(30);
  LAfter := DACNativeDateTimePickerPaintMetrics(ADate.PickerControl);
  Require((LAfter.BufferAllocations = LBefore.BufferAllocations) and
    (LAfter.BufferResizes = LBefore.BufferResizes + 1),
    Format('%s: resize de restauracao nao ajustou cache exatamente uma vez ' +
      '(alloc %d->%d; resize %d->%d).',
      [AScenario, LBefore.BufferAllocations, LAfter.BufferAllocations,
       LBefore.BufferResizes, LAfter.BufferResizes]));
end;

procedure RequireNativeDateRecreateWnd(
  const ADate: TDACDBDateTimePicker;
  const AExpectedBackground, AExpectedText: TAlphaColor;
  const AScenario: string);
var
  LAfter: TDACNativeDateTimePickerPaintMetrics;
  LBefore: TDACNativeDateTimePickerPaintMetrics;
  LOldHandle: HWND;
  LValue: TDateTime;
begin
  LOldHandle := ADate.PickerControl.Handle;
  LValue := ADate.DateTime;
  LBefore := DACNativeDateTimePickerPaintMetrics(ADate.PickerControl);
  TWinControlAccess(ADate.PickerControl).RecreateWnd;
  PumpMessages(30);
  Require(ADate.PickerControl.HandleAllocated and
    (ADate.PickerControl.Handle <> LOldHandle),
    AScenario + ': RecreateWnd nao produziu novo HWND Date.');
  LAfter := DACNativeDateTimePickerPaintMetrics(ADate.PickerControl);
  Require((LAfter.BufferAllocations = LBefore.BufferAllocations) and
    (LAfter.BufferResizes = LBefore.BufferResizes) and
    (LAfter.HandleGenerations = LBefore.HandleGenerations + 1),
    Format('%s: cache nao foi rebindado ao novo HWND sem alloc/resize ' +
      '(alloc %d->%d; resize %d->%d; generation %d->%d).',
      [AScenario, LBefore.BufferAllocations, LAfter.BufferAllocations,
       LBefore.BufferResizes, LAfter.BufferResizes,
       LBefore.HandleGenerations, LAfter.HandleGenerations]));
  Require(ADate.DateTime = LValue,
    AScenario + ': RecreateWnd alterou valor DateTime.');
  RequireNativeDateCentralSurface(ADate.PickerControl,
    AExpectedBackground, AExpectedText,
    AScenario + ' recriado desfocado');
  RequireNativeDateContentDelegation(ADate, AExpectedBackground,
    AScenario + ' recriado');
end;

procedure RequireEditableComboContentDelegation(
  const AParent: TWinControl; const AScenario: string);
const
  PaintTimeoutMs = 1000;
var
  LBefore: Cardinal;
  LCombo: TDACComboBox;
  LHandle: HWND;
  LMessageResult: DWORD_PTR;
  LSelLength: Integer;
  LSelStart: Integer;
  LText: string;
begin
  LCombo := TDACComboBox.Create(Form1);
  try
    LCombo.Parent := AParent;
    LCombo.SetBounds(8, 8, 220, 64);
    LCombo.Style := csDropDown;
    LCombo.Text := 'conteudo editavel nativo';
    LCombo.SetFocus;
    PumpMessages(30);
    LCombo.ComboControl.SelStart := 3;
    LCombo.ComboControl.SelLength := 8;
    LHandle := LCombo.ComboControl.Handle;
    LText := LCombo.Text;
    LSelStart := LCombo.ComboControl.SelStart;
    LSelLength := LCombo.ComboControl.SelLength;
    LBefore := DACNativeComboBoxEditablePaintDelegations(
      LCombo.ComboControl);
    LMessageResult := 0;
    InvalidateRect(LHandle, nil, False);
    Require(SendMessageTimeout(LHandle, WM_PAINT, 0, 0,
      SMTO_ABORTIFHUNG or SMTO_BLOCK, PaintTimeoutMs,
      @LMessageResult) <> 0,
      AScenario + ': timeout no paint do ComboBox editavel.');
    Require(DACNativeComboBoxEditablePaintDelegations(
        LCombo.ComboControl) > LBefore,
      AScenario + ': ComboBox editavel nao delegou paint ao HWND nativo.');
    Require((LCombo.ComboControl.Handle = LHandle) and
      LCombo.ComboControl.Focused and (LCombo.Text = LText) and
      (LCombo.ComboControl.SelStart = LSelStart) and
      (LCombo.ComboControl.SelLength = LSelLength),
      AScenario +
        ': paint alterou HWND, foco, texto, selecao ou caret editavel.');
  finally
    LCombo.Free;
  end;
end;

procedure RequireLookupPopupTabNavigation(
  const ATemplate: TDACDBLookupComboBox; const AScenario: string);
var
  LAfter: TButton;
  LHost: TPanel;
  LOriginalKey: Variant;
  LProbe: TDACDBLookupComboBox;
begin
  Require((ATemplate <> nil) and (ATemplate.DataSource <> nil) and
    (ATemplate.DataSource.DataSet <> nil) and
    ATemplate.DataSource.DataSet.Active and
    (ATemplate.ListSource <> nil) and
    (ATemplate.ListSource.DataSet <> nil) and
    ATemplate.ListSource.DataSet.Active,
    AScenario + ': fixture nativa do Lookup indisponivel.');
  LHost := TPanel.Create(Form1);
  LProbe := nil;
  try
    LHost.Parent := Form1;
    LHost.SetBounds(0, 0, 560, 44);
    LHost.BevelOuter := bvNone;
    LHost.TabStop := False;
    LHost.BringToFront;

    LProbe := TDACDBLookupComboBox.Create(LHost);
    LProbe.Parent := LHost;
    LProbe.SetBounds(130, 2, 220, 36);
    LProbe.TabOrder := 1;
    LProbe.ThemeMode := ATemplate.ThemeMode;
    LProbe.DataSource := ATemplate.DataSource;
    LProbe.DataField := ATemplate.DataField;
    LProbe.ListSource := ATemplate.ListSource;
    LProbe.KeyField := ATemplate.KeyField;
    LProbe.ListField := ATemplate.ListField;
    LOriginalKey := LProbe.KeyValue;

    LAfter := TButton.Create(LHost);
    LAfter.Parent := LHost;
    LAfter.SetBounds(360, 4, 120, 32);
    LAfter.Caption := 'Seguinte';
    LAfter.TabOrder := 2;

    LProbe.SetFocus;
    PumpMessages(20);
    Require(GetFocus = LProbe.Handle,
      AScenario + ': Lookup direto nao recebeu foco HWND.');
    LProbe.Perform(WM_KEYDOWN, VK_F4, 0);
    PumpMessages(30);
    Require(LProbe.ListVisible,
      AScenario + ': F4 nao abriu o popup nativo.');
    LProbe.Perform(WM_KEYDOWN, VK_ESCAPE, 0);
    PumpMessages(20);
    Require(not LProbe.ListVisible and
      VarSameValue(LProbe.KeyValue, LOriginalKey),
      AScenario + ': Escape nao cancelou o popup nativo.');

    LAfter.SetFocus;
    LProbe.SetFocus;
    PumpMessages(20);
    LHost.Perform(CM_DIALOGKEY, VK_TAB, 0);
    PumpMessages(20);
    Require(GetFocus = LAfter.Handle,
      AScenario + ': Tab fechado nao seguiu a ordem VCL nativa.');
    Require(VarSameValue(LProbe.KeyValue, LOriginalKey),
      AScenario + ': Tab fechado alterou KeyValue.');
  finally
    if (LProbe <> nil) and LProbe.ListVisible then
      LProbe.CloseUp(False);
    if (ATemplate.DataSource <> nil) and
      (ATemplate.DataSource.DataSet <> nil) and
      (ATemplate.DataSource.DataSet.State in dsEditModes) then
      ATemplate.DataSource.DataSet.Cancel;
    LHost.Free;
  end;
end;
procedure RequireDemoLookupPopupTabNavigation(
  const ALookup: TDACDBLookupComboBox; const AScenario: string);
var
  LAncestor: TWinControl;
  LFoundGrid: Boolean;
  LFoundScroll: Boolean;
begin
  Require((ALookup <> nil) and (GetParentForm(ALookup) = Form1),
    AScenario + ': Lookup nao pertence ao Form real do Demo.');
  LFoundGrid := False;
  LFoundScroll := False;
  LAncestor := ALookup.Parent;
  while LAncestor <> nil do
  begin
    LFoundGrid := LFoundGrid or SameText(LAncestor.ClassName,
      'TDACGridContainer');
    LFoundScroll := LFoundScroll or SameText(LAncestor.ClassName,
      'TDACScrollContainer');
    LAncestor := LAncestor.Parent;
  end;
  Require(LFoundGrid and LFoundScroll and (ALookup.Parent <> Form1),
    AScenario + ': gate nao atravessou grid/scroll/nesting real do DFM.');
  RequireLookupPopupTabNavigation(ALookup,
    AScenario + ' Lookup direto');
end;
procedure RequireLookupPopupSurface(
  const ALookup: TDACDBLookupComboBox;
  const ATokens: TDACControlTokens; const AScenario: string);
var
  LOriginalHandle: HWND;
  LOriginalKey: Variant;
begin
  Require((ALookup <> nil) and ALookup.HandleAllocated and
    (ALookup.ListSource <> nil) and
    (ALookup.ListSource.DataSet <> nil) and
    ALookup.ListSource.DataSet.Active,
    AScenario + ': Lookup direto indisponivel.');
  LOriginalHandle := ALookup.Handle;
  LOriginalKey := ALookup.KeyValue;
  ALookup.SetFocus;
  PumpMessages(20);

  ALookup.Perform(WM_KEYDOWN, VK_F4, 0);
  PumpMessages(30);
  Require(ALookup.ListVisible,
    AScenario + ': F4 nao abriu o popup nativo.');
  ALookup.Perform(WM_KEYDOWN, VK_ESCAPE, 0);
  PumpMessages(20);
  Require(not ALookup.ListVisible and
    VarSameValue(ALookup.KeyValue, LOriginalKey),
    AScenario + ': Escape nao cancelou o popup nativo.');

  ALookup.Perform(WM_KEYDOWN, VK_F4, 0);
  PumpMessages(30);
  Require(ALookup.ListVisible,
    AScenario + ': segundo F4 nao reabriu o popup nativo.');
  ALookup.Perform(WM_KEYDOWN, VK_DOWN, 0);
  ALookup.Perform(WM_KEYDOWN, VK_RETURN, 0);
  PumpMessages(20);
  Require(not ALookup.ListVisible and
    (ALookup.Handle = LOriginalHandle),
    AScenario + ': Enter nao fechou popup ou recriou HWND.');
  ALookup.KeyValue := LOriginalKey;
end;
procedure RequireDataAwareNativeSurfaces(const AContext: string);
var
  LCombo: TDACDBComboBox;
  LComboHandle: HWND;
  LDate: TDACDBDateTimePicker;
  LDateHandle: HWND;
  LLookup: TDACDBLookupComboBox;
  LLookupHandle: HWND;
begin
  Form1.GalleryTabs.ActivePage :=
    Form1.FindComponent('tsDataAware') as TTabSheet;
  PumpMessages(100);
  LCombo := Form1.FindComponent('demoDBComboBox') as TDACDBComboBox;
  LDate := Form1.FindComponent('demoDBDate') as TDACDBDateTimePicker;
  LLookup := Form1.FindComponent('demoDBLookup') as TDACDBLookupComboBox;
  Require((LCombo <> nil) and (LDate <> nil) and (LLookup <> nil),
    AContext + ': controles nativos Data-Aware ausentes.');
  LComboHandle := LCombo.Handle;
  LDateHandle := LDate.Handle;
  LLookupHandle := LLookup.Handle;
  Require((LCombo.Style = csDropDownList) and
    (LCombo.ClassParent = TDBComboBox) and
    (LDate.ClassParent = TDateTimePicker) and
    (LLookup.ClassParent = TDBLookupComboBox),
    AContext + ': ancestral nativo direto divergiu.');

  LCombo.SetFocus;
  PumpMessages(20);
  Require(GetFocus = LComboHandle,
    AContext + ': DB Combo nao recebeu foco nativo.');
  LDate.SetFocus;
  PumpMessages(20);
  Require(GetFocus = LDateHandle,
    AContext + ': DB Date nao recebeu foco nativo.');
  LDate.Perform(WM_KEYDOWN, VK_F4, 0);
  PumpMessages(30);
  Require(LDate.DroppedDown,
    AContext + ': F4 nao abriu calendario nativo.');
  PostMessage(LDate.Handle, WM_KEYDOWN, VK_ESCAPE, 0);
  PostMessage(LDate.Handle, WM_KEYUP, VK_ESCAPE, 0);
  PumpMessages(50);
  Require(not LDate.DroppedDown,
    AContext + ': Escape nao fechou calendario nativo.');

  LLookup.SetFocus;
  PumpMessages(20);
  Require(GetFocus = LLookupHandle,
    AContext + ': DB Lookup nao recebeu foco nativo.');
  LLookup.Perform(WM_KEYDOWN, VK_F4, 0);
  PumpMessages(30);
  Require(LLookup.ListVisible,
    AContext + ': F4 nao abriu lookup nativo.');
  LLookup.Perform(WM_KEYDOWN, VK_ESCAPE, 0);
  PumpMessages(20);
  Require(not LLookup.ListVisible and
    (LCombo.Handle = LComboHandle) and
    (LDate.Handle = LDateHandle) and
    (LLookup.Handle = LLookupHandle),
    AContext + ': Escape falhou ou algum HWND foi recriado.');
end;
procedure RequireNoUnexpectedVisibleWindow(
  const AContext: string); forward;

procedure ClickNavigatorButton(const ANavigator: TDACDBNavigator;
  const AButton: TNavigateBtn);
var
  LBounds: TRect;
  LPoint: TPoint;
begin
  LBounds := ANavigator.ButtonBounds(AButton);
  LPoint := Point((LBounds.Left + LBounds.Right) div 2,
    (LBounds.Top + LBounds.Bottom) div 2);
  ANavigator.Perform(WM_MOUSEMOVE, 0,
    MakeLParam(LPoint.X, LPoint.Y));
  ANavigator.Perform(WM_LBUTTONDOWN, MK_LBUTTON,
    MakeLParam(LPoint.X, LPoint.Y));
  ANavigator.Perform(WM_LBUTTONUP, 0,
    MakeLParam(LPoint.X, LPoint.Y));
  PumpMessages(30);
end;

procedure RequireDataAwareInsertNullContract;
const
  TestRecordId = 2034;
var
  I: Integer;
  LDataSet: TDataSet;
  LDate: TDACDBDateTimePicker;
  LDateField: TField;
  LNavigator: TDACDBNavigator;
  LOriginalDateRequired: Boolean;
  LOriginalLastId: Integer;
  LPostRaised: Boolean;
begin
  GStage := 'DataAwareInsertNull.Setup';
  Form1.GalleryTabs.ActivePage :=
    Form1.FindComponent('tsDataAware') as TTabSheet;
  PumpMessages(100);
  LDataSet := (Form1.FindComponent('demoGridDataSet') as TDataSet);
  LDate := Form1.FindComponent('demoDBDate') as TDACDBDateTimePicker;
  LNavigator := Form1.FindComponent('demoDBNavigator') as TDACDBNavigator;
  Require((LDataSet <> nil) and LDataSet.Active and
    (LDate <> nil) and LDate.HandleAllocated and
    (LNavigator <> nil) and LNavigator.HandleAllocated,
    'Insert null: arvore Data-Aware materializada incompleta.');
  LDateField := LDataSet.FieldByName('DATA');
  LOriginalDateRequired := LDateField.Required;
  ClickNavigatorButton(LNavigator, nbLast);
  LOriginalLastId := LDataSet.FieldByName('ID').AsInteger;
  try
    GStage := 'DataAwareInsertNull.Insert';
    LDateField.Required := True;
    ClickNavigatorButton(LNavigator, nbInsert);
    Require(LDataSet.State = dsInsert,
      'Navigator Insert nao abriu buffer dsInsert.');
    for I := 0 to LDataSet.FieldCount - 1 do
      Require(LDataSet.Fields[I].IsNull,
        'Insert nao iniciou field null: ' +
        LDataSet.Fields[I].FieldName + '.');
    Require(LDate.IsNull and LDate.PickerControl.Visible,
      'Picker nativo direto nao preservou null/visibilidade no Insert.');
    Require(NativeInt(GetProp(Form1.Handle,
      PChar(DACFORM_DIAG_EXTERNAL_DATE))) = -1,
      'DataAwareStateChange sintetizou data para Insert/RecNo=0.');
    RequireNoUnexpectedVisibleWindow('DataAwareInsertNull.DataChange');

    GStage := 'DataAwareInsertNull.RequiredPost';
    LPostRaised := False;
    try
      ClickNavigatorButton(LNavigator, nbPost);
    except
      on E: EDatabaseError do
        LPostRaised := True;
    end;
    Require(LPostRaised and (LDataSet.State = dsInsert) and LDate.IsNull,
      'Field.Required nao falhou exclusivamente no Post null.');
    RequireNoUnexpectedVisibleWindow('DataAwareInsertNull.RequiredPost');

    GStage := 'DataAwareInsertNull.FillPost';
    LDataSet.FieldByName('ID').AsInteger := TestRecordId;
    LDate.SetFocus;
    LDate.Perform(WM_KEYDOWN, VK_DOWN, 0);
    LDate.Perform(WM_KEYUP, VK_DOWN, 0);
    PumpMessages(30);
    Require(not LDate.IsNull,
      'Seta nativa nao materializou data a partir de null.');
    LDate.Perform(CM_EXIT, 0, 0);
    ClickNavigatorButton(LNavigator, nbPost);
    Require((LDataSet.State = dsBrowse) and
      (LDataSet.FieldByName('ID').AsInteger = TestRecordId) and
      not LDateField.IsNull,
      'Fill/Post do Insert null nao persistiu a data.');

    GStage := 'DataAwareInsertNull.ClearPost';
    LDateField.Required := False;
    ClickNavigatorButton(LNavigator, nbEdit);
    LDate.SetFocus;
    LDate.Perform(WM_KEYDOWN, VK_DELETE, 0);
    LDate.Perform(WM_KEYUP, VK_DELETE, 0);
    Require(LDate.IsNull,
      'Delete nao limpou o picker nullable.');
    LDate.Perform(CM_EXIT, 0, 0);
    ClickNavigatorButton(LNavigator, nbPost);
    Require((LDataSet.State = dsBrowse) and LDateField.IsNull and
      LDate.IsNull,
      'Clear/Post nao persistiu null sem sentinel.');

    GStage := 'DataAwareInsertNull.Cancel';
    ClickNavigatorButton(LNavigator, nbEdit);
    LDate.SetFocus;
    LDate.Perform(WM_KEYDOWN, VK_DOWN, 0);
    LDate.Perform(WM_KEYUP, VK_DOWN, 0);
    LDate.Perform(CM_EXIT, 0, 0);
    Require(not LDate.IsNull and not LDateField.IsNull,
      'Edicao previa ao Cancel nao materializou data.');
    ClickNavigatorButton(LNavigator, nbCancel);
    Require((LDataSet.State = dsBrowse) and LDateField.IsNull and
      LDate.IsNull,
      'Cancel nao restaurou o valor null confirmado.');
  finally
    LDateField.Required := LOriginalDateRequired;
    if LDataSet.State in dsEditModes then
      LDataSet.Cancel;
    if LDataSet.Locate('ID', TestRecordId, []) then
      LDataSet.Delete;
    LDataSet.Last;
    Require(LDataSet.FieldByName('ID').AsInteger = LOriginalLastId,
      'Cleanup do gate Insert null nao restaurou o ultimo registro original.');
  end;
end;

function CollectUnexpectedVisibleWindow(AWindow: HWND;
  AParameter: LPARAM): BOOL; stdcall;
var
  LClassName: array[0..255] of Char;
  LTitle: array[0..255] of Char;
begin
  Result := True;
  if not IsWindowVisible(AWindow) or (AWindow = Application.Handle) or
    ((Form1 <> nil) and (AWindow = Form1.Handle)) then
    Exit;
  LClassName[0] := #0;
  LTitle[0] := #0;
  GetClassName(AWindow, LClassName, Length(LClassName));
  GetWindowText(AWindow, LTitle, Length(LTitle));
  if GUnexpectedWindowSnapshot <> '' then
    GUnexpectedWindowSnapshot := GUnexpectedWindowSnapshot + ',';
  GUnexpectedWindowSnapshot := GUnexpectedWindowSnapshot +
    string(LClassName) + '{Title=' + string(LTitle) + ';Owner=' +
    IntToStr(GetWindow(AWindow, GW_OWNER)) + '}';
end;

function UnexpectedVisibleWindowSnapshot: string;
begin
  GUnexpectedWindowSnapshot := '';
  EnumThreadWindows(GetCurrentThreadId, @CollectUnexpectedVisibleWindow, 0);
  Result := GUnexpectedWindowSnapshot;
end;

procedure RequireNoUnexpectedVisibleWindow(const AContext: string);
var
  LSnapshot: string;
begin
  LSnapshot := UnexpectedVisibleWindowSnapshot;
  if LSnapshot <> '' then
  begin
    raise Exception.Create(AContext +
      ': modal/top-level inesperado: ' + LSnapshot);
  end;
end;

procedure AppendFailure(var AFailure: string; const AMessage: string);
begin
  if AMessage = '' then
    Exit;
  if AFailure <> '' then
    AFailure := AFailure + ' | ';
  AFailure := AFailure + AMessage;
end;

function SameExceptionHandler(const ALeft,
  ARight: TExceptionEvent): Boolean;
begin
  Result := (TMethod(ALeft).Code = TMethod(ARight).Code) and
    (TMethod(ALeft).Data = TMethod(ARight).Data);
end;

procedure ReleasePostedTeardownHostOnce(
  var AHost: TPostedTeardownExceptionForm;
  const AProbe: TStartupExceptionProbe; const AContext: string);
var
  LReleasingHost: TPostedTeardownExceptionForm;
begin
  LReleasingHost := AHost;
  AHost := nil;
  if LReleasingHost = nil then
    Exit;
  try
    LReleasingHost.Free;
  except
    on E: Exception do
      AProbe.CaptureException(AContext, E);
  end;
end;

procedure RequireGalleryState(const AContext: string);
var
  I: Integer;
  LExpectedColor: TColor;
  LNavigation: TControl;
  LThemeToggle: TControl;
  LTitle: TDACSystemText;
  LTokens: TDACControlTokens;
begin
  Require(Form1 <> nil, AContext + ': Form1=nil.');
  Require(Form1.GalleryTabs <> nil, AContext + ': GalleryTabs=nil.');
  Require(Form1.GalleryTabs.PageCount = 17,
    AContext + ': PageCount=' + IntToStr(Form1.GalleryTabs.PageCount) +
      ', esperado=17.');
  Require(Form1.GalleryTabs.ActivePageHeaderOnly,
    AContext + ': header principal voltou a comprimir as 17 legendas.');
  LNavigation := Form1.FindComponent('demoNavigation') as TControl;
  LThemeToggle := Form1.FindComponent('demoThemeToggle') as TControl;
  LTitle := Form1.FindComponent('demoNavigationTitle') as TDACSystemText;
  Require((LNavigation <> nil) and (LThemeToggle <> nil) and (LTitle <> nil),
    AContext + ': shell principal incompleto.');
  Require(LThemeToggle.Left >= LNavigation.Left + LNavigation.Width,
    AContext + ': toggle de tema sobrepos a navegacao lateral.');
  LTokens := TDACComponentStyle.Resolve(
    TDACThemeManager.ApplicationMode).Tokens.Controls;
  Require(LTitle.ResolvedTextColor = LTokens.InputText,
    Format('%s: titulo Suite DAC stale (real=%u esperado=%u).',
      [AContext, LTitle.ResolvedTextColor, LTokens.InputText]));
  Require(TDACComponentColors.ContrastRatio(LTitle.ResolvedTextColor,
      TDACComponentColors.ResolveParentSurface(LTitle)) >= 4.5,
    Format('%s: titulo Suite DAC sem contraste AA (ratio=%.3f text=%u '
      + 'surface=%u).', [AContext,
      TDACComponentColors.ContrastRatio(LTitle.ResolvedTextColor,
        TDACComponentColors.ResolveParentSurface(LTitle)),
      LTitle.ResolvedTextColor,
      TDACComponentColors.ResolveParentSurface(LTitle)]));
  Require(Form1.FindComponent('tsDataAware') <> nil,
    AContext + ': pagina Data-Aware ausente.');
  Require(Form1.FindComponent('demoGridDataSet') <> nil,
    AContext + ': dataset declarativo principal ausente.');
  Require(Form1.FindComponent('demoLookupDataSet') <> nil,
    AContext + ': dataset declarativo de lookup ausente.');
  Require((Form1.GalleryTabs.ActivePage <> nil) and
    (Form1.GalleryTabs.ActivePage.PageControl = Form1.GalleryTabs) and
    (Form1.GalleryTabs.ActivePage.PageIndex >= 0) and
    (Form1.GalleryTabs.ActivePage.PageIndex <
      Form1.GalleryTabs.PageCount),
    AContext + ': ActivePage invalida.');
  Require(SendMessage(Form1.GalleryTabs.Handle, TCM_GETITEMCOUNT, 0, 0) =
    Form1.GalleryTabs.PageCount,
    AContext + ': native tab count divergiu de PageCount.');
  LExpectedColor := TDACComponentColors.ToVclColor(
    TDACComponentStyle.Resolve(TDACThemeManager.ApplicationMode).
      Tokens.Controls.ContainerSuiteBackground);
  for I := 0 to Form1.GalleryTabs.PageCount - 1 do
  begin
    Require(not TTabSheetAccess(Form1.GalleryTabs.Pages[I]).ParentColor and
      not TTabSheetAccess(Form1.GalleryTabs.Pages[I]).ParentBackground and
      (TTabSheetAccess(Form1.GalleryTabs.Pages[I]).StyleElements = []),
      AContext + ': pagina ' + IntToStr(I) +
        ' nao confirmou a fronteira VCL no host real.');
    Require(TTabSheetAccess(Form1.GalleryTabs.Pages[I]).Color =
      LExpectedColor,
      AContext + ': pagina ' + IntToStr(I) +
        ' nao preservou a surface do tema.');
  end;
end;

procedure RequireCompactShell;
var
  LHeight: Integer;
  LNavigation: TControl;
  LPage: TTabSheet;
  LScroll: TDACScrollContainer;
  LThemeToggle: TControl;
  LWidth: Integer;
begin
  LWidth := Form1.Width;
  LHeight := Form1.Height;
  LPage := Form1.GalleryTabs.ActivePage;
  try
    Form1.SetBounds(Form1.Left, Form1.Top, 520, 560);
    Form1.GalleryTabs.ActivePage :=
      Form1.FindComponent('tsDataAware') as TTabSheet;
    PumpMessages(120);
    LNavigation := Form1.FindComponent('demoNavigation') as TControl;
    LThemeToggle := Form1.FindComponent('demoThemeToggle') as TControl;
    LScroll := Form1.FindComponent('scrDataAware') as TDACScrollContainer;
    Require((LNavigation <> nil) and LNavigation.Visible and
      (LNavigation.Width = TDACDemoTokens.Default.NavigationCompactWidth) and
      (Form1.GalleryTabs.Left = LNavigation.Left + LNavigation.Width),
      'Compact 520x560 nao aplicou a rail tokenizada.');
    Require((LThemeToggle <> nil) and
      (LThemeToggle.Left >= LNavigation.Left + LNavigation.Width) and
      (LThemeToggle.Width = LThemeToggle.Height),
      'Compact 520x560 sobrepos toggle/sidebar/header.');
    Require((LScroll <> nil) and
      (LScroll.HorzScrollBar.Range > LScroll.ClientWidth) and
      (LScroll.VertScrollBar.Range > LScroll.ClientHeight),
      'Compact 520x560 cortou o Data-Aware sem scroll nos dois eixos.');
  finally
    Form1.SetBounds(Form1.Left, Form1.Top, LWidth, LHeight);
    Form1.GalleryTabs.ActivePage := LPage;
    PumpMessages(120);
  end;
end;

procedure RunNegativeTeardownExceptionGate;
var
  LFinalCaptureCount: Integer;
  LFinalMessageText: string;
  LFormWindow: HWND;
  LHost: TPostedTeardownExceptionForm;
  LPreviousOnException: TExceptionEvent;
  LProbe: TStartupExceptionProbe;
begin
  LHost := nil;
  GPostedTeardownDestroyAttempts := 0;
  LPreviousOnException := Application.OnException;
  LProbe := TStartupExceptionProbe.Create;
  Application.OnException := LProbe.OnApplicationException;
  try
    GStage := 'NegativeTeardown.CreateHost';
    LHost := TPostedTeardownExceptionForm.CreateNew(nil);
    LFormWindow := LHost.Handle;
    Require(not IsWindowVisible(LFormWindow),
      'Host negativo de teardown ficou visivel.');
    GStage := 'NegativeTeardown.PostedDrain';
    Require(PostMessage(LFormWindow, WM_DAC_STARTUP_TEARDOWN_PROBE, 0, 0),
      'Nao foi possivel postar a excecao negativa de teardown.');
    PumpMessages(50);
    Require((LProbe.CaptureCount = 1) and
      (Pos('NegativeTeardown.PostedDrain EPostedTeardownProbe:',
        LProbe.MessageText) > 0),
      'OnException nao capturou exatamente uma excecao postada no drain: ' +
        LProbe.MessageText);
    RequireNoUnexpectedVisibleWindow('NegativeTeardown.PostedDrain');

    GStage := 'NegativeTeardown.Free';
    LHost.RaiseOnDestroy := True;
    ReleasePostedTeardownHostOnce(LHost, LProbe, GStage);
    Require(LHost = nil,
      'Release single-shot nao invalidou o host antes do Free.');
    Require((LProbe.CaptureCount = 2) and
      (Pos('NegativeTeardown.Free EPostedTeardownFreeProbe:',
        LProbe.MessageText) > 0),
      'Primeiro Free excepcional nao foi agregado ao probe: ' +
        LProbe.MessageText);
    Require(GPostedTeardownDestroyAttempts = 1,
      'Primeiro Free nao executou exatamente uma tentativa de Destroy.');
    GStage := 'NegativeTeardown.FinalDrain';
    PumpMessages(50);
    Require(LProbe.CaptureCount = 2,
      'Drain negativo capturou excecao adicional: ' + LProbe.MessageText);
    Require(GPostedTeardownDestroyAttempts = 1,
      'Drain tentou destruir novamente o host ja invalidado.');
    Require(not IsWindow(LFormWindow),
      'HWND do host negativo sobreviveu ao teardown.');
    RequireNoUnexpectedVisibleWindow('NegativeTeardown.FinalDrain');
  finally
    try
      ReleasePostedTeardownHostOnce(LHost, LProbe,
        'NegativeTeardown.FinallyFree');
    finally
      LFinalCaptureCount := LProbe.CaptureCount;
      LFinalMessageText := LProbe.MessageText;
      Application.OnException := LPreviousOnException;
      LProbe.Free;
    end;
  end;
  Require(LFinalCaptureCount = 2,
    'Cleanup normal capturou excecao adicional: ' + LFinalMessageText);
  Require(GPostedTeardownDestroyAttempts = 1,
    'Finally tentou executar um segundo Free/Destroy no caminho nominal.');
  Require(SameExceptionHandler(Application.OnException,
    LPreviousOnException),
    'Handler anterior nao foi restaurado apos o gate negativo normal.');
end;

procedure RunStartupGate;
var
  LFailure: string;
  LFormWindow: HWND;
  LPreviousOnException: TExceptionEvent;
  LProbe: TStartupExceptionProbe;
  LWindowSnapshot: string;
begin
  LFailure := '';
  LFormWindow := 0;
  LPreviousOnException := Application.OnException;
  LProbe := TStartupExceptionProbe.Create;
  Form1 := nil;
  Application.OnException := LProbe.OnApplicationException;
  try
    try
      GStage := 'TrySetStyle';
      Require(TStyleManager.TrySetStyle('Windows10'),
        'Windows10 style nao foi carregado do recurso real da Demo.');
      Require(TStyleManager.IsCustomStyleActive,
        'Windows10 nao ficou ativo.');
      GStage := 'CreateForm';
      TraceStartupStage('CreateForm enter');
      Writeln('DACDemoStartup stage=CreateForm enter');
      Flush(Output);
      Application.CreateForm(TForm1, Form1);
      TraceStartupStage('CreateForm exit');
      Writeln('DACDemoStartup stage=CreateForm exit');
      Flush(Output);
      GStage := 'Show';
      Form1.Show;
      PumpMessages(500);
      TraceStartupStage('Show stable');
      Writeln('DACDemoStartup stage=Show stable');
      Flush(Output);
      Require(LProbe.MessageText = '',
        'Excecao assincrona: ' + LProbe.MessageText);
      Require(IsWindowVisible(Form1.Handle),
        'Janela principal nao ficou visivel.');
      RequireNoUnexpectedVisibleWindow('Startup');
      Require(TDACThemeManager.ApplicationMode = dtmDark,
        'Demo nao iniciou no boundary Dark esperado.');
      RequireGalleryState('Dark inicial');
      RequireCompactShell;
      TraceStartupStage('Compact stable');
      Writeln('DACDemoStartup stage=Compact stable');
      Flush(Output);
      RequireDataAwareNativeSurfaces('Dark inicial');

      GStage := 'DarkToLight';
      TDACThemeManager.SetApplicationMode(dtmLight);
      PumpMessages(250);
      Require(LProbe.MessageText = '',
        'Excecao assincrona: ' + LProbe.MessageText);
      RequireGalleryState('Light');
      RequireDataAwareNativeSurfaces('Light');

      GStage := 'LightToDark';
      TDACThemeManager.SetApplicationMode(dtmDark);
      PumpMessages(250);
      Require(LProbe.MessageText = '',
        'Excecao assincrona: ' + LProbe.MessageText);
      RequireGalleryState('Dark final');
      RequireDataAwareNativeSurfaces('Dark final');
      RequireDataAwareInsertNullContract;
    except
      on E: Exception do
        AppendFailure(LFailure, GStage + ' ' + E.ClassName + ': ' +
          E.Message);
    end;

    if (Form1 <> nil) and Form1.HandleAllocated then
      LFormWindow := Form1.Handle;
    GStage := 'Teardown.Free';
    try
      Form1.Free;
    except
      on E: Exception do
        LProbe.CaptureException(GStage, E);
    end;
    Form1 := nil;

    GStage := 'Teardown.Drain';
    try
      PumpMessages(100);
    except
      on E: Exception do
        LProbe.CaptureException(GStage, E);
    end;

    GStage := 'Teardown.Validate';
    if LProbe.MessageText <> '' then
      AppendFailure(LFailure, 'Excecao sync/async capturada: ' +
        LProbe.MessageText);
    if (LFormWindow <> 0) and IsWindow(LFormWindow) then
      AppendFailure(LFailure,
        'HWND principal sobreviveu ao Free/drain: ' +
          IntToStr(LFormWindow));
    LWindowSnapshot := UnexpectedVisibleWindowSnapshot;
    if LWindowSnapshot <> '' then
      AppendFailure(LFailure,
        'modal/top-level inesperado apos teardown: ' + LWindowSnapshot);
    if LFailure <> '' then
      raise Exception.Create(LFailure);
  finally
    Application.OnException := LPreviousOnException;
    LProbe.Free;
  end;
end;

begin
  ExitCode := 1;
  GStage := 'Initialize';
  TraceStartupStage('program enter');
  Writeln('DACDemoStartup stage=Initialize enter');
  Flush(Output);
  Application.Initialize;
  TraceStartupStage('Initialize exit');
  Writeln('DACDemoStartup stage=Initialize exit');
  Flush(Output);
  Application.MainFormOnTaskbar := True;
  try
    TraceStartupStage('NegativeTeardown enter');
    Writeln('DACDemoStartup stage=NegativeTeardown enter');
    Flush(Output);
    RunNegativeTeardownExceptionGate;
    TraceStartupStage('NegativeTeardown exit');
    Writeln('DACDemoStartup stage=NegativeTeardown exit');
    Flush(Output);
    RunStartupGate;
    TraceStartupStage('RunStartupGate exit');
    Writeln(Format('DACDemoStartup: PASS max=%d us p95=%d us',
      [GWorstDateMaxMicroseconds, GWorstDateP95Microseconds]));
    ExitCode := 0;
  except
    on E: Exception do
    begin
      Writeln('DACDemoStartup: FAIL stage=' + GStage + ' ' +
        E.ClassName + ': ' + E.Message + ' ExceptAddr=' +
        IntToHex(NativeUInt(ExceptAddr), SizeOf(Pointer) * 2));
      ExitCode := 1;
    end;
  end;
end.
