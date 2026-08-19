unit DAC.Components.Controls.DateTimePicker;

interface

uses
  System.Classes,
  System.Math,
  System.Skia,
  System.SysUtils,
  System.Types,
  System.UITypes,
  Winapi.Messages,
  Vcl.ComCtrls,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.Skia,
  Vcl.StdCtrls,
  DAC.Components.Controls.Edit,
  DAC.Components.Controls.FieldSupport,
  DAC.Components.Controls.DateTimePickerPopup,
  DAC.Components.DesignSystem.ControlTokens,
  DAC.Components.DesignSystem.IconAssets,
  DAC.Components.DesignSystem.Theme,
  DAC.Components.Skia.BackgroundPainter,
  DAC.Components.Skia.BorderPainter,
  DAC.Components.Skia.IconPainter,
  DAC.Components.Skia.Renderer;

const
  WM_DAC_ACTIVATE_NATIVE_PICKER = WM_APP + 91;

type
{$IFDEF DAC_TESTING}
  TDACNativeDateTimePickerPaintMetrics = record
    BufferAllocations: Cardinal;
    BufferResizes: Cardinal;
    HandleGenerations: Cardinal;
    NativeRenders: Cardinal;
    Paints: Cardinal;
    Presents: Cardinal;
    MaxMicroseconds: Int64;
    P95Microseconds: Int64;
  end;
{$ENDIF}

  TDACDateTimePicker = class(TCustomControl)
  private
    FBackgroundPainter: TDACSkiaBackgroundPainter;
    FBindingCanModify: Boolean;
    FBindingDisplayNull: Boolean;
    FBorderPainter: TDACSkiaBorderPainter;
    FCornerRadius: Integer;
    FErrorText: string;
    FFieldText: TDACFieldTextSupport;
    FFormatString: string;
    FHelperText: string;
    FIconPainter: TDACSkiaIconPainter;
    FLabelText: string;
    FNativeLabel: TLabel;
    FLoading: Boolean;
    FLoadingTabStopCaptured: Boolean;
    FMouseInside: Boolean;
    FOnChange: TNotifyEvent;
    FPaintBox: TSkPaintBox;
    FPicker: TDateTimePicker;
    FPickerActivationPending: Boolean;
    FNativeHostReady: Boolean;
    FPopupActive: Boolean;
    FPopup: TDACDateTimePickerPopup;
    FPreparingNative: Boolean;
    FRenderer: TDACSkiaRenderer;
    FReadOnly: Boolean;
    FRequired: Boolean;
    FStatus: TDACEditStatus;
    FThemeMode: TDACThemeMode;
    FTabStopBeforeLoading: Boolean;
    FTimeStepMinutes: Integer;
    function BorderAlpha: Byte;
    function BorderColor: TAlphaColor;
    function CanModifyValue: Boolean;
    procedure AttachChildrenToHost;
    procedure AttachPickerToHost;
    procedure ClosePopup;
    procedure ClosePopupForHiddenHost;
    procedure CreatePaintBox;
    procedure CMEnabledChanged(var AMessage: TMessage); message CM_ENABLEDCHANGED;
    procedure CMParentColorChanged(var AMessage: TMessage); message CM_PARENTCOLORCHANGED;
    procedure CMParentFontChanged(var AMessage: TMessage); message CM_PARENTFONTCHANGED;
    procedure CMShowingChanged(var AMessage: TMessage); message CM_SHOWINGCHANGED;
    function ChromeTop: Integer;
    procedure DoPickerChange(Sender: TObject);
    procedure DoPickerEnter(Sender: TObject);
    procedure DoPickerExit(Sender: TObject);
    procedure DoMouseEnter(Sender: TObject);
    procedure DoMouseLeave(Sender: TObject);
    function DisplayText: string;
    procedure PaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure NativeRequestPopup(Sender: TObject);
    function GetDateTime: TDateTime;
    function GetFormatString: string;
    function IconRect: TRect;
    function GetPickerKind: TDateTimeKind;
    function HasLabel: Boolean;
    function HasSupportText: Boolean;
    function NativeHostShowing: Boolean;
    procedure PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    function ParentSurfaceColor: TAlphaColor;
    function Pixels(const AValue: Integer): Integer;
    function ResolvedTokens: TDACControlTokens;
    function ResolvedFieldState: TDACResolvedFieldState;
    function ResolvedPopupThemeMode: TDACThemeMode;
    procedure SetCornerRadius(const AValue: Integer);
    procedure SetDateTime(const AValue: TDateTime);
    procedure SetErrorText(const AValue: string);
    procedure SetFormatString(const AValue: string);
    procedure SetHelperText(const AValue: string);
    procedure SetLabelText(const AValue: string);
    procedure SetLoading(const AValue: Boolean);
    procedure SetPickerKind(const AValue: TDateTimeKind);
    procedure ShowCalendarPopup;
    procedure SetReadOnly(const AValue: Boolean);
    procedure SetRequired(const AValue: Boolean);
    procedure SetStatus(const AValue: TDACEditStatus);
    procedure SetThemeMode(const AValue: TDACThemeMode);
    procedure SetTimeStepMinutes(const AValue: Integer);
    procedure PopupAccept(Sender: TObject);
    procedure PopupClear(Sender: TObject);
    procedure PopupHide(Sender: TObject);
    function PrepareNativePicker(const AShowAndFocus: Boolean): Boolean;
    procedure ThemeChanged(Sender: TObject);
    procedure UpdateChildBounds;
    procedure UpdatePaintBoxBounds;
    procedure UpdatePickerStyle;
    procedure UpdateNativeLabel;
    procedure UpdateNativeClip;
    procedure UpdateNativeVisibility;
    procedure UpdateZOrder;
    procedure WMDACActivateNativePicker(var AMessage: TMessage); message WM_DAC_ACTIVATE_NATIVE_PICKER;
    procedure WMEraseBkgnd(var AMessage: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMSetFocus(var AMessage: TWMSetFocus); message WM_SETFOCUS;
  protected
    procedure CreateWnd; override;
    procedure DoAcceptValue(const AValue: TDateTime); virtual;
    procedure DoClearValue; virtual;
    procedure Loaded; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
    procedure Resize; override;
    procedure SetBindingCanModify(const AValue: Boolean);
    procedure SetBindingDisplayNull(const AValue: Boolean);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function LabelFontSize: Integer;
    function PopupSelectedDateTime: TDateTime;
    function PopupDisplayMonth: TDateTime;
    function ResolvedPopupBackground: TAlphaColor;
    function PopupVisible: Boolean;
    procedure OpenPopup;
    procedure SimulatePopupDayClick(const ADay: Integer);
    procedure SimulatePopupKey(const AKey: Word);
    procedure SimulatePopupFooter(const AAction: Integer);
    procedure SimulatePopupExternalDeactivate;
    procedure Redraw;
    procedure RequestNativePickerActivation;
    procedure SetFocus; reintroduce;
    property PickerControl: TDateTimePicker read FPicker;
    property NativeLabel: TLabel read FNativeLabel;
  published
    property Align;
    property Anchors;
    property Constraints;
    property CornerRadius: Integer read FCornerRadius write SetCornerRadius
      default DACDateTimeDefaultCornerRadius;
    property DateTime: TDateTime read GetDateTime write SetDateTime;
    property Enabled;
    property ErrorText: string read FErrorText write SetErrorText;
    property Font;
    property FormatString: string read GetFormatString write SetFormatString;
    property HelperText: string read FHelperText write SetHelperText;
    property LabelText: string read FLabelText write SetLabelText;
    property Loading: Boolean read FLoading write SetLoading default False;
    property ParentFont;
    property ParentShowHint;
    property PickerKind: TDateTimeKind read GetPickerKind write SetPickerKind default dtkDate;
    property PopupMenu;
    property ReadOnly: Boolean read FReadOnly write SetReadOnly default False;
    property Required: Boolean read FRequired write SetRequired default False;
    property ShowHint;
    property Status: TDACEditStatus read FStatus write SetStatus default mesNormal;
    property TabOrder;
    property TabStop default True;
    property ThemeMode: TDACThemeMode read FThemeMode write SetThemeMode default dtmInherit;
    property TimeStepMinutes: Integer read FTimeStepMinutes write SetTimeStepMinutes default 5;
    property Visible;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnClick;
    property OnDblClick;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
  end;

function DACNativeDateTimePickerClass: TWinControlClass;
{$IFDEF DAC_TESTING}
procedure DACNativeDateTimePickerCapturePipeline(
  const AControl: TDateTimePicker; const APreRemap, APostRemap,
  AFinal: Vcl.Graphics.TBitmap);
function DACNativeDateTimePickerFocusedPaintDelegations(
  const AControl: TDateTimePicker): Cardinal;
function DACNativeDateTimePickerPaintMetrics(
  const AControl: TDateTimePicker): TDACNativeDateTimePickerPaintMetrics;
procedure DACNativeDateTimePickerResetPaintMetrics(
  const AControl: TDateTimePicker);
{$ENDIF}

implementation

uses
  System.DateUtils,
  Winapi.Windows,
  Winapi.CommCtrl,
  Winapi.UxTheme,
  Vcl.Forms,
  DAC.Components.DesignSystem.ColorTokens,
  DAC.Components.DesignSystem.Fonts,
  DAC.Components.DesignSystem.ComponentStyle;

type
  // The public contract remains TDateTimePicker, but its native non-client
  // border is removed so only the Skia chrome is visible.
  TDACNativeDateTimePicker = class(TDateTimePicker)
  private
{$IFDEF DAC_TESTING}
    FBufferAllocations: Cardinal;
    FDiagnosticFinal: Vcl.Graphics.TBitmap;
    FDiagnosticPostRemap: Vcl.Graphics.TBitmap;
    FDiagnosticPreRemap: Vcl.Graphics.TBitmap;
{$ENDIF}
    FBufferHeight: Integer;
{$IFDEF DAC_TESTING}
    FBufferResizes: Cardinal;
{$ENDIF}
    FBufferWidth: Integer;
    FDarkNativeTheme: Boolean;
    FDropdownClipWidth: Integer;
    FVerticalClipInset: Integer;
{$IFDEF DAC_TESTING}
    FFocusedPaintDelegations: Cardinal;
    FHandleGenerations: Cardinal;
{$ENDIF}
    FInteractionLocked: Boolean;
{$IFDEF DAC_TESTING}
    FMaxPaintMicroseconds: Int64;
    FNativeRenders: Cardinal;
{$ENDIF}
    FOnRequestPopup: TNotifyEvent;
{$IFDEF DAC_TESTING}
    FPaintDurationCount: Integer;
    FPaintDurationIndex: Integer;
    FPaintDurations: array[0..127] of Int64;
    FPaintFrequency: Int64;
{$ENDIF}
    FPaintInProgress: Boolean;
{$IFDEF DAC_TESTING}
    FPaints: Cardinal;
{$ENDIF}
    FPaletteBuffer: Vcl.Graphics.TBitmap;
{$IFDEF DAC_TESTING}
    FPresents: Cardinal;
{$ENDIF}
    procedure ApplyClip;
    procedure ApplyNativeTheme;
    procedure ClearPaletteBuffer;
    procedure EnsurePaletteBuffer;
    function PaintDarkBuffered(var Message: TMessage): Boolean;
{$IFDEF DAC_TESTING}
    procedure CapturePipeline(const APreRemap, APostRemap,
      AFinal: Vcl.Graphics.TBitmap);
    procedure CopyDiagnosticFrame(const ASource: HDC;
      const ADestination: Vcl.Graphics.TBitmap);
    function PaintMetrics: TDACNativeDateTimePickerPaintMetrics;
    function PaintP95Microseconds: Int64;
    procedure RecordPaintDuration(const AStarted: Int64);
{$ENDIF}
    procedure RemapDarkNativePalette;
{$IFDEF DAC_TESTING}
    procedure ResetPaintMetrics;
{$ENDIF}
    procedure SetDarkNativeTheme(const AValue: Boolean);
    procedure SetDropdownClipWidth(const AValue: Integer);
    procedure SetVerticalClipInset(const AValue: Integer);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure DestroyWnd; override;
    procedure Resize; override;
    procedure WndProc(var Message: TMessage); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property DropdownClipWidth: Integer read FDropdownClipWidth
      write SetDropdownClipWidth;
    property VerticalClipInset: Integer read FVerticalClipInset
      write SetVerticalClipInset;
    property DarkNativeTheme: Boolean read FDarkNativeTheme
      write SetDarkNativeTheme;
    property InteractionLocked: Boolean read FInteractionLocked
      write FInteractionLocked;
    property OnRequestPopup: TNotifyEvent read FOnRequestPopup
      write FOnRequestPopup;
  end;

  TRGBQuadArray = array[0..(MaxInt div SizeOf(TRGBQuad)) - 1] of TRGBQuad;
  PRGBQuadArray = ^TRGBQuadArray;

function DACNativeDateTimePickerClass: TWinControlClass;
begin
  Result := TDACNativeDateTimePicker;
end;

{$IFDEF DAC_TESTING}
procedure DACNativeDateTimePickerCapturePipeline(
  const AControl: TDateTimePicker; const APreRemap, APostRemap,
  AFinal: Vcl.Graphics.TBitmap);
begin
  if AControl is TDACNativeDateTimePicker then
    TDACNativeDateTimePicker(AControl).CapturePipeline(
      APreRemap, APostRemap, AFinal);
end;

function DACNativeDateTimePickerFocusedPaintDelegations(
  const AControl: TDateTimePicker): Cardinal;
begin
  if AControl is TDACNativeDateTimePicker then
    Result := TDACNativeDateTimePicker(AControl).FFocusedPaintDelegations
  else
    Result := 0;
end;

function DACNativeDateTimePickerPaintMetrics(
  const AControl: TDateTimePicker): TDACNativeDateTimePickerPaintMetrics;
begin
  if AControl is TDACNativeDateTimePicker then
    Result := TDACNativeDateTimePicker(AControl).PaintMetrics
  else
    FillChar(Result, SizeOf(Result), 0);
end;

procedure DACNativeDateTimePickerResetPaintMetrics(
  const AControl: TDateTimePicker);
begin
  if AControl is TDACNativeDateTimePicker then
    TDACNativeDateTimePicker(AControl).ResetPaintMetrics;
end;
{$ENDIF}

{$IFDEF DAC_TESTING}
procedure TDACNativeDateTimePicker.CapturePipeline(
  const APreRemap, APostRemap, AFinal: Vcl.Graphics.TBitmap);
begin
  if (APreRemap = nil) or (APostRemap = nil) or (AFinal = nil) then
    raise EArgumentNilException.Create(
      'Pipeline diagnostic bitmaps must be assigned.');
  if (APreRemap.Width <> FBufferWidth) or
    (APreRemap.Height <> FBufferHeight) or
    (APostRemap.Width <> FBufferWidth) or
    (APostRemap.Height <> FBufferHeight) or
    (AFinal.Width <> FBufferWidth) or
    (AFinal.Height <> FBufferHeight) then
    raise EArgumentException.Create(
      'Pipeline diagnostic bitmaps must match the native client.');
  FDiagnosticPreRemap := APreRemap;
  FDiagnosticPostRemap := APostRemap;
  FDiagnosticFinal := AFinal;
  try
    InvalidateRect(Handle, nil, False);
    UpdateWindow(Handle);
  finally
    FDiagnosticFinal := nil;
    FDiagnosticPostRemap := nil;
    FDiagnosticPreRemap := nil;
  end;
end;

procedure TDACNativeDateTimePicker.CopyDiagnosticFrame(
  const ASource: HDC; const ADestination: Vcl.Graphics.TBitmap);
begin
  if (ASource = 0) or (ADestination = nil) then
    Exit;
  BitBlt(ADestination.Canvas.Handle, 0, 0, FBufferWidth, FBufferHeight,
    ASource, 0, 0, SRCCOPY);
end;
{$ENDIF}

procedure TDACNativeDateTimePicker.ApplyClip;
var
  LClipWidth: Integer;
  LInset: Integer;
  LRegion: HRGN;
begin
  if not HandleAllocated or (Width <= 0) or (Height <= 0) then
    Exit;
  LClipWidth := Max(1, Width - FDropdownClipWidth);
  LInset := Min(Max(0, FVerticalClipInset), Max(0, (Height - 1) div 2));
  LRegion := CreateRectRgn(0, LInset, LClipWidth, Height - LInset);
  if SetWindowRgn(Handle, LRegion, True) = 0 then
    DeleteObject(LRegion);
end;

procedure TDACNativeDateTimePicker.ApplyNativeTheme;
begin
  if not HandleAllocated then
    Exit;
  if FDarkNativeTheme then
    { Both localized native dark classes keep clWindow on the supported target
      OS. Use its stable unthemed palette as input to the post-delegation
      palette mapping. }
    SetWindowTheme(Handle, '', '')
  else
    SetWindowTheme(Handle, 'Explorer', nil);
end;

procedure TDACNativeDateTimePicker.ClearPaletteBuffer;
var
  LBase: TColor;
  LBlue: Byte;
  LGreen: Byte;
  LRed: Byte;
  LRow: PRGBQuadArray;
  X: Integer;
  Y: Integer;
begin
  if (FPaletteBuffer = nil) or
    (FBufferWidth <= 0) or (FBufferHeight <= 0) then
    Exit;
  LBase := ColorToRGB(Color);
  LRed := GetRValue(LBase);
  LGreen := GetGValue(LBase);
  LBlue := GetBValue(LBase);
  for Y := 0 to FBufferHeight - 1 do
  begin
    LRow := PRGBQuadArray(FPaletteBuffer.ScanLine[Y]);
    for X := 0 to FBufferWidth - 1 do
    begin
      LRow^[X].rgbRed := LRed;
      LRow^[X].rgbGreen := LGreen;
      LRow^[X].rgbBlue := LBlue;
      LRow^[X].rgbReserved := 0;
    end;
  end;
end;

procedure TDACNativeDateTimePicker.EnsurePaletteBuffer;
var
  LCanvasHandle: HDC;
  LHeight: Integer;
  LWidth: Integer;
begin
  if FPaletteBuffer = nil then
    Exit;
  LWidth := ClientWidth;
  LHeight := ClientHeight;
  if (LWidth <= 0) or (LHeight <= 0) then
    Exit;
  if (FBufferWidth = LWidth) and (FBufferHeight = LHeight) then
    Exit;
  FPaletteBuffer.SetSize(LWidth, LHeight);
  FBufferWidth := LWidth;
  FBufferHeight := LHeight;
{$IFDEF DAC_TESTING}
  Inc(FBufferResizes);
{$ENDIF}
  { Prime the bitmap canvas and its stable brush outside WM_PAINT. }
  LCanvasHandle := FPaletteBuffer.Canvas.Handle;
  if LCanvasHandle <> 0 then
    ClearPaletteBuffer;
end;

function TDACNativeDateTimePicker.PaintDarkBuffered(
  var Message: TMessage): Boolean;
var
  LNativePaintMessage: TMessage;
  LOwnPaintDC: Boolean;
  LPaintDC: HDC;
  LPaintStruct: TPaintStruct;
{$IFDEF DAC_TESTING}
  LFinalDC: HDC;
  LStarted: Int64;
{$ENDIF}
begin
  Result := False;
  if not FDarkNativeTheme or FPaintInProgress or
    (FPaletteBuffer = nil) or
    (FBufferWidth <> ClientWidth) or (FBufferHeight <> ClientHeight) or
    (FBufferWidth <= 0) or (FBufferHeight <= 0) then
    Exit;

{$IFDEF DAC_TESTING}
  QueryPerformanceCounter(LStarted);
{$ENDIF}
  LOwnPaintDC := Message.WParam = 0;
  if LOwnPaintDC then
    LPaintDC := BeginPaint(Handle, LPaintStruct)
  else
    LPaintDC := HDC(Message.WParam);
  if LPaintDC = 0 then
    Exit;
  try
    { Render the common control once through its original window procedure.
      Passing the persistent DIB as WM_PAINT's HDC preserves the native glyph
      rasterization without re-entering this style hook or presenting a
      second frame to the HWND. }
    ClearPaletteBuffer;
    FPaintInProgress := True;
    try
{$IFDEF DAC_TESTING}
      Inc(FNativeRenders);
      if Focused then
        Inc(FFocusedPaintDelegations);
{$ENDIF}
      FillChar(LNativePaintMessage, SizeOf(LNativePaintMessage), 0);
      LNativePaintMessage.Msg := WM_PAINT;
      LNativePaintMessage.WParam := WPARAM(FPaletteBuffer.Canvas.Handle);
      DefaultHandler(LNativePaintMessage);
{$IFDEF DAC_TESTING}
      CopyDiagnosticFrame(FPaletteBuffer.Canvas.Handle,
        FDiagnosticPreRemap);
{$ENDIF}
    finally
      FPaintInProgress := False;
    end;
    RemapDarkNativePalette;
{$IFDEF DAC_TESTING}
    CopyDiagnosticFrame(FPaletteBuffer.Canvas.Handle,
      FDiagnosticPostRemap);
{$ENDIF}
    if BitBlt(LPaintDC, 0, 0, FBufferWidth, FBufferHeight,
      FPaletteBuffer.Canvas.Handle, 0, 0, SRCCOPY) then
    begin
{$IFDEF DAC_TESTING}
      Inc(FPresents);
{$ENDIF}
    end
    else
      Exit;
{$IFDEF DAC_TESTING}
    Inc(FPaints);
{$ENDIF}
    Message.Result := 0;
    Result := True;
  finally
    if LOwnPaintDC then
      EndPaint(Handle, LPaintStruct);
{$IFDEF DAC_TESTING}
    if Result and (FDiagnosticFinal <> nil) then
    begin
      if LOwnPaintDC then
        LFinalDC := GetDC(Handle)
      else
        LFinalDC := LPaintDC;
      try
        CopyDiagnosticFrame(LFinalDC, FDiagnosticFinal);
      finally
        if LOwnPaintDC and (LFinalDC <> 0) then
          ReleaseDC(Handle, LFinalDC);
      end;
    end;
    RecordPaintDuration(LStarted);
{$ENDIF}
  end;
end;

{$IFDEF DAC_TESTING}
function TDACNativeDateTimePicker.PaintMetrics:
  TDACNativeDateTimePickerPaintMetrics;
begin
  Result.BufferAllocations := FBufferAllocations;
  Result.BufferResizes := FBufferResizes;
  Result.HandleGenerations := FHandleGenerations;
  Result.NativeRenders := FNativeRenders;
  Result.Paints := FPaints;
  Result.Presents := FPresents;
  Result.MaxMicroseconds := FMaxPaintMicroseconds;
  Result.P95Microseconds := PaintP95Microseconds;
end;

function TDACNativeDateTimePicker.PaintP95Microseconds: Int64;
var
  I: Integer;
  J: Integer;
  LCount: Integer;
  LSorted: array[0..127] of Int64;
  LValue: Int64;
begin
  LCount := FPaintDurationCount;
  if LCount <= 0 then
    Exit(0);
  for I := 0 to LCount - 1 do
    LSorted[I] := FPaintDurations[I];
  for I := 1 to LCount - 1 do
  begin
    LValue := LSorted[I];
    J := I - 1;
    while (J >= 0) and (LSorted[J] > LValue) do
    begin
      LSorted[J + 1] := LSorted[J];
      Dec(J);
    end;
    LSorted[J + 1] := LValue;
  end;
  Result := LSorted[
    Max(0, Min(LCount - 1, ((LCount * 95) + 99) div 100 - 1))];
end;

procedure TDACNativeDateTimePicker.RecordPaintDuration(
  const AStarted: Int64);
var
  LFinished: Int64;
  LMicroseconds: Int64;
begin
  QueryPerformanceCounter(LFinished);
  if FPaintFrequency <= 0 then
    Exit;
  LMicroseconds := ((LFinished - AStarted) * 1000000) div
    FPaintFrequency;
  if LMicroseconds > FMaxPaintMicroseconds then
    FMaxPaintMicroseconds := LMicroseconds;
  FPaintDurations[FPaintDurationIndex] := LMicroseconds;
  FPaintDurationIndex := (FPaintDurationIndex + 1) mod
    Length(FPaintDurations);
  if FPaintDurationCount < Length(FPaintDurations) then
    Inc(FPaintDurationCount);
end;

procedure TDACNativeDateTimePicker.ResetPaintMetrics;
begin
  FMaxPaintMicroseconds := 0;
  FNativeRenders := 0;
  FPaintDurationCount := 0;
  FPaintDurationIndex := 0;
  FillChar(FPaintDurations, SizeOf(FPaintDurations), 0);
  FPaints := 0;
  FPresents := 0;
end;
{$ENDIF}

procedure TDACNativeDateTimePicker.RemapDarkNativePalette;
const
  HighlightTolerance = 16;
var
  LBaseBin: Integer;
  LBaseBlue: Integer;
  LBaseCount: Integer;
  LBaseGreen: Integer;
  LBaseRed: Integer;
  LBaseSamples: Integer;
  LBaseSumBlue: Integer;
  LBaseSumGreen: Integer;
  LBaseSumRed: Integer;
  LBackground: TColor;
  LBackgroundBlue: Byte;
  LBackgroundGreen: Byte;
  LBackgroundRed: Byte;
  LHistogram: array[0..4095] of Integer;
  LHeight: Integer;
  LMappedPixel: TColor;
  LPixel: TColor;
  LRow: PRGBQuadArray;
  LText: TColor;
  LTextBlue: Byte;
  LTextGreen: Byte;
  LTextRed: Byte;
  LNativeTextBlue: Integer;
  LNativeTextDistance: Integer;
  LNativeTextGreen: Integer;
  LNativeTextRed: Integer;
  LHighlight: TColor;
  LHighlightBlue: Integer;
  LHighlightCount: Integer;
  LHighlightGreen: Integer;
  LHighlightRed: Integer;
  LSelectionBottom: Integer;
  LSelectionLeft: Integer;
  LSelectionRight: Integer;
  LSelectionTop: Integer;
  LWidth: Integer;
  X: Integer;
  Y: Integer;
  function PixelBin(const APixel: TColor): Integer;
  begin
    Result := ((GetRValue(APixel) shr 4) shl 8) or
      ((GetGValue(APixel) shr 4) shl 4) or
      (GetBValue(APixel) shr 4);
  end;
  function ChannelAlpha(const APixel, ABase,
    ANativeText: Integer): Integer;
  var
    LDenominator: Integer;
  begin
    LDenominator := ANativeText - ABase;
    if LDenominator = 0 then
      Exit(0);
    Result := EnsureRange(
      ((APixel - ABase) * 255) div LDenominator, 0, 255);
  end;
  function RemapNativePixel(const APixel: TColor;
    const APixelX, APixelY: Integer): TColor;
  var
    LAlphaBlue: Integer;
    LAlphaGreen: Integer;
    LAlphaRed: Integer;
    LBlue: Integer;
    LGreen: Integer;
    LRed: Integer;
  begin
    Result := APixel;
    if (LHighlightCount >= 8) and
      (APixelX >= LSelectionLeft) and (APixelX <= LSelectionRight) and
      (APixelY >= LSelectionTop) and (APixelY <= LSelectionBottom) then
      Exit;
    LRed := GetRValue(APixel);
    LGreen := GetGValue(APixel);
    LBlue := GetBValue(APixel);
    { ClearType carries a separate coverage value in each color channel.
      Project and recolor each channel independently so the native subpixel
      glyph geometry survives on the dark token background. }
    LAlphaRed := ChannelAlpha(LRed, LBaseRed, LNativeTextRed);
    LAlphaGreen := ChannelAlpha(LGreen, LBaseGreen, LNativeTextGreen);
    LAlphaBlue := ChannelAlpha(LBlue, LBaseBlue, LNativeTextBlue);
    Result := RGB(
      ((LTextRed * LAlphaRed) +
       (LBackgroundRed * (255 - LAlphaRed))) div 255,
      ((LTextGreen * LAlphaGreen) +
       (LBackgroundGreen * (255 - LAlphaGreen))) div 255,
      ((LTextBlue * LAlphaBlue) +
       (LBackgroundBlue * (255 - LAlphaBlue))) div 255);
  end;
begin
  if not FDarkNativeTheme or (FPaletteBuffer = nil) or
    (FBufferWidth <= 0) or (FBufferHeight <= 0) then
    Exit;

  LWidth := FBufferWidth;
  LHeight := FBufferHeight;
  LBackground := ColorToRGB(Color);
  LBackgroundRed := GetRValue(LBackground);
  LBackgroundGreen := GetGValue(LBackground);
  LBackgroundBlue := GetBValue(LBackground);
  LText := ColorToRGB(Font.Color);
  LTextRed := GetRValue(LText);
  LTextGreen := GetGValue(LText);
  LTextBlue := GetBValue(LText);

  { Derive the common control's actual base palette from the whitespace after
    the short value text. Quantization remains stable across OS palettes. }
  FillChar(LHistogram, SizeOf(LHistogram), 0);
  for Y := LHeight div 4 to (LHeight * 3) div 4 do
  begin
    LRow := PRGBQuadArray(FPaletteBuffer.ScanLine[Y]);
    for X := LWidth div 3 to (LWidth * 3) div 4 do
    begin
      LPixel := RGB(LRow^[X].rgbRed, LRow^[X].rgbGreen,
        LRow^[X].rgbBlue);
      Inc(LHistogram[PixelBin(LPixel)]);
    end;
  end;
  LBaseBin := 0;
  LBaseCount := -1;
  for X := Low(LHistogram) to High(LHistogram) do
    if LHistogram[X] > LBaseCount then
    begin
      LBaseCount := LHistogram[X];
      LBaseBin := X;
    end;
  { Refine the quantized dominant bin to the exact native background color.
    This keeps alpha zero on untouched background pixels. }
  LBaseSamples := 0;
  LBaseSumRed := 0;
  LBaseSumGreen := 0;
  LBaseSumBlue := 0;
  for Y := LHeight div 4 to (LHeight * 3) div 4 do
  begin
    LRow := PRGBQuadArray(FPaletteBuffer.ScanLine[Y]);
    for X := LWidth div 3 to (LWidth * 3) div 4 do
    begin
      LPixel := RGB(LRow^[X].rgbRed, LRow^[X].rgbGreen,
        LRow^[X].rgbBlue);
      if PixelBin(LPixel) = LBaseBin then
      begin
        Inc(LBaseSamples);
        Inc(LBaseSumRed, LRow^[X].rgbRed);
        Inc(LBaseSumGreen, LRow^[X].rgbGreen);
        Inc(LBaseSumBlue, LRow^[X].rgbBlue);
      end;
    end;
  end;
  if LBaseSamples <= 0 then
    Exit;
  LBaseRed := LBaseSumRed div LBaseSamples;
  LBaseGreen := LBaseSumGreen div LBaseSamples;
  LBaseBlue := LBaseSumBlue div LBaseSamples;

  { The farthest pixel is the native foreground endpoint. A solid glyph,
    border or arrow supplies the common control's text-side channel values. }
  LNativeTextDistance := -1;
  LNativeTextRed := LBaseRed;
  LNativeTextGreen := LBaseGreen;
  LNativeTextBlue := LBaseBlue;
  for Y := 0 to LHeight - 1 do
  begin
    LRow := PRGBQuadArray(FPaletteBuffer.ScanLine[Y]);
    for X := 0 to LWidth - 1 do
    begin
      LBaseCount := Sqr(Integer(LRow^[X].rgbRed) - LBaseRed) +
        Sqr(Integer(LRow^[X].rgbGreen) - LBaseGreen) +
        Sqr(Integer(LRow^[X].rgbBlue) - LBaseBlue);
      if LBaseCount > LNativeTextDistance then
      begin
        LNativeTextDistance := LBaseCount;
        LNativeTextRed := LRow^[X].rgbRed;
        LNativeTextGreen := LRow^[X].rgbGreen;
        LNativeTextBlue := LRow^[X].rgbBlue;
      end;
    end;
  end;

  { Preserve only a real native selection region. ClearType fringes can also
    be saturated, so saturation alone must never classify them as selection. }
  LHighlight := ColorToRGB(GetSysColor(COLOR_HIGHLIGHT));
  LHighlightRed := GetRValue(LHighlight);
  LHighlightGreen := GetGValue(LHighlight);
  LHighlightBlue := GetBValue(LHighlight);
  LHighlightCount := 0;
  LSelectionLeft := LWidth;
  LSelectionTop := LHeight;
  LSelectionRight := -1;
  LSelectionBottom := -1;
  for Y := 0 to LHeight - 1 do
  begin
    LRow := PRGBQuadArray(FPaletteBuffer.ScanLine[Y]);
    for X := 0 to LWidth - 1 do
      if (Abs(Integer(LRow^[X].rgbRed) - LHighlightRed) <=
          HighlightTolerance) and
        (Abs(Integer(LRow^[X].rgbGreen) - LHighlightGreen) <=
          HighlightTolerance) and
        (Abs(Integer(LRow^[X].rgbBlue) - LHighlightBlue) <=
          HighlightTolerance) then
      begin
        Inc(LHighlightCount);
        LSelectionLeft := Min(LSelectionLeft, X);
        LSelectionTop := Min(LSelectionTop, Y);
        LSelectionRight := Max(LSelectionRight, X);
        LSelectionBottom := Max(LSelectionBottom, Y);
      end;
  end;
  if (LSelectionRight <= LSelectionLeft) or
    (LSelectionBottom <= LSelectionTop) then
    LHighlightCount := 0;

  for Y := 0 to LHeight - 1 do
  begin
    LRow := PRGBQuadArray(FPaletteBuffer.ScanLine[Y]);
    for X := 0 to LWidth - 1 do
    begin
      LPixel := RGB(LRow^[X].rgbRed, LRow^[X].rgbGreen,
        LRow^[X].rgbBlue);
      LMappedPixel := RemapNativePixel(LPixel, X, Y);
      LRow^[X].rgbRed := GetRValue(LMappedPixel);
      LRow^[X].rgbGreen := GetGValue(LMappedPixel);
      LRow^[X].rgbBlue := GetBValue(LMappedPixel);
    end;
  end;
end;

constructor TDACNativeDateTimePicker.Create(AOwner: TComponent);
begin
  inherited;
  FPaletteBuffer := Vcl.Graphics.TBitmap.Create;
{$IFDEF DAC_TESTING}
  Inc(FBufferAllocations);
{$ENDIF}
  FPaletteBuffer.PixelFormat := pf32bit;
{$IFDEF DAC_TESTING}
  QueryPerformanceFrequency(FPaintFrequency);
{$ENDIF}
end;

destructor TDACNativeDateTimePicker.Destroy;
begin
  FPaletteBuffer.Free;
  FPaletteBuffer := nil;
  inherited;
end;

procedure TDACNativeDateTimePicker.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.Style := Params.Style and not WS_BORDER;
  Params.ExStyle := Params.ExStyle and not
    (WS_EX_CLIENTEDGE or WS_EX_STATICEDGE);
end;

procedure TDACNativeDateTimePicker.CreateWnd;
begin
  inherited;
{$IFDEF DAC_TESTING}
  Inc(FHandleGenerations);
{$ENDIF}
  { Theme selection remains local to the suite-owned SysDateTimePick32 HWND.
    The common control keeps segment selection, keyboard editing and
    accessibility; the outer border and dropdown chrome remain Skia-owned. }
  ApplyNativeTheme;
  SetWindowLong(Handle, GWL_STYLE,
    GetWindowLong(Handle, GWL_STYLE) and not WS_BORDER);
  SetWindowLong(Handle, GWL_EXSTYLE,
    GetWindowLong(Handle, GWL_EXSTYLE) and not
      (WS_EX_CLIENTEDGE or WS_EX_STATICEDGE));
  SetWindowPos(Handle, 0, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or
    SWP_NOZORDER or SWP_NOACTIVATE or SWP_FRAMECHANGED);
  SendMessage(Handle, WM_CHANGEUISTATE,
    MakeLong(UIS_SET, UISF_HIDEFOCUS or UISF_HIDEACCEL), 0);
  ApplyClip;
  EnsurePaletteBuffer;
end;

procedure TDACNativeDateTimePicker.DestroyWnd;
begin
  FPaintInProgress := False;
  inherited;
end;

procedure TDACNativeDateTimePicker.SetDarkNativeTheme(
  const AValue: Boolean);
begin
  if FDarkNativeTheme = AValue then
    Exit;
  FDarkNativeTheme := AValue;
  if HandleAllocated then
  begin
    ApplyNativeTheme;
    EnsurePaletteBuffer;
    InvalidateRect(Handle, nil, True);
  end;
end;

procedure TDACNativeDateTimePicker.Resize;
begin
  inherited;
  ApplyClip;
  EnsurePaletteBuffer;
end;

procedure TDACNativeDateTimePicker.SetDropdownClipWidth(
  const AValue: Integer);
begin
  if FDropdownClipWidth = Max(0, AValue) then
    Exit;
  FDropdownClipWidth := Max(0, AValue);
  ApplyClip;
end;

procedure TDACNativeDateTimePicker.SetVerticalClipInset(
  const AValue: Integer);
begin
  if FVerticalClipInset = Max(0, AValue) then
    Exit;
  FVerticalClipInset := Max(0, AValue);
  ApplyClip;
end;

procedure TDACNativeDateTimePicker.WndProc(var Message: TMessage);
begin
  if FPaintInProgress and (Message.Msg = WM_PRINTCLIENT) then
  begin
{$IFDEF DAC_TESTING}
    if Focused then
      Inc(FFocusedPaintDelegations);
{$ENDIF}
    inherited;
    Exit;
  end;
  if ((Message.Msg = WM_KEYDOWN) and (Message.WParam = VK_F4)) or
    ((Message.Msg = WM_SYSKEYDOWN) and (Message.WParam = VK_DOWN)) then
  begin
    if Assigned(FOnRequestPopup) and not FInteractionLocked then
      FOnRequestPopup(Self);
    Message.Result := 0;
    Exit;
  end;
  if FInteractionLocked then
    case Message.Msg of
      WM_CHAR, WM_MOUSEWHEEL:
        begin
          Message.Result := 0;
          Exit;
        end;
      WM_KEYDOWN:
        if Message.WParam in [VK_UP, VK_DOWN, VK_LEFT, VK_RIGHT, VK_HOME,
          VK_END, VK_PRIOR, VK_NEXT, VK_ADD, VK_SUBTRACT] then
        begin
          Message.Result := 0;
          Exit;
        end;
    end;
  if FDarkNativeTheme and (Message.Msg = WM_ERASEBKGND) then
  begin
    { The buffered paint covers the full client in one presentation. }
    Message.Result := 1;
    Exit;
  end;
  if FDarkNativeTheme and (Message.Msg = WM_PAINT) and
    PaintDarkBuffered(Message) then
    Exit;
{$IFDEF DAC_TESTING}
  if (Message.Msg = WM_PAINT) and Focused then
    Inc(FFocusedPaintDelegations);
{$ENDIF}
  inherited;
end;

function DateTimeVclColor(const AColor: TAlphaColor): TColor;
begin
  Result := TColor(((AColor and $00FF0000) shr 16) or
    (AColor and $0000FF00) or ((AColor and $000000FF) shl 16));
end;

constructor TDACDateTimePicker.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque, csClickEvents, csCaptureMouse];
  FBindingCanModify := True;
  FThemeMode := dtmInherit;
  Width := Round(ResolvedTokens.DateTimeDefaultWidth);
  Height := Round(ResolvedTokens.DateTimeDefaultHeight);
  TabStop := True;
  ParentColor := False;
  StyleElements := [];
  Cursor := crDefault;
  Color := DateTimeVclColor(ResolvedTokens.DateTimeChromeBackground);
  FCornerRadius := Round(ResolvedTokens.DateTimeDefaultCornerRadius);
  FStatus := mesNormal;
  FTimeStepMinutes := ResolvedTokens.DateTimeTimeStepMinutes;
  TDACThemeManager.RegisterListener(Self, ThemeChanged);

  FRenderer := TDACSkiaRenderer.Create;
  FBackgroundPainter := TDACSkiaBackgroundPainter.Create(FRenderer);
  FBorderPainter := TDACSkiaBorderPainter.Create(FRenderer);
  FIconPainter := TDACSkiaIconPainter.Create(FRenderer);

  FPicker := TDACNativeDateTimePicker.Create(Self);
  { TDateTimePicker is a native windowed control. Parenting it here forces the
    host handle while TDACDateTimePicker still has no Parent, which raises
    "Control '' has no parent window" in the VCL designer. Keep it detached
    until CreateWnd confirms the complete native host chain. }
  FPicker.DateTime := EncodeDate(2025, 5, 24) + EncodeTime(14, 35, 0, 0);
  FPicker.Kind := dtkDate;
  { seBorder keeps the exact localized TDateTimePickerStyleHook active for
    chrome/invalidation, while absence of seClient makes the specialized hook
    delegate both focused and unfocused client content to SysDateTimePick32. }
  FPicker.StyleElements := [seBorder];
  FPicker.Visible := False;
  FPicker.TabStop := True;
  FPicker.OnChange := DoPickerChange;
  FPicker.OnEnter := DoPickerEnter;
  FPicker.OnExit := DoPickerExit;
  FPicker.OnMouseEnter := DoMouseEnter;
  FPicker.OnMouseLeave := DoMouseLeave;
  TDACNativeDateTimePicker(FPicker).OnRequestPopup := NativeRequestPopup;

  FFieldText := TDACFieldTextSupport.Create(Self, Self);
  FNativeLabel := FFieldText.CaptionLabel;
  FFieldText.SetFocusControl(FPicker);

  CreatePaintBox;

  UpdatePaintBoxBounds;
  UpdateChildBounds;
  UpdatePickerStyle;
end;

procedure TDACDateTimePicker.CreatePaintBox;
begin
  if FPaintBox <> nil then
    Exit;
  FPaintBox := TSkPaintBox.Create(Self);
  FPaintBox.Parent := Self;
  FPaintBox.SetSubComponent(True);
  FPaintBox.StyleElements := [];
  FPaintBox.OnDraw := PaintBoxDraw;
  FPaintBox.OnMouseDown := PaintBoxMouseDown;
  FPaintBox.OnMouseEnter := DoMouseEnter;
  FPaintBox.OnMouseLeave := DoMouseLeave;
end;

procedure TDACDateTimePicker.PaintBoxMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  MouseDown(Button, Shift, X, Y);
end;

procedure TDACDateTimePicker.AttachChildrenToHost;
begin
  if csDestroying in ComponentState then
    Exit;
  if (Parent = nil) or not HandleAllocated or not Parent.HandleAllocated then
    Exit;

  if (FPaintBox <> nil) and (FPaintBox.Parent <> Self) then
    FPaintBox.Parent := Self;
end;

procedure TDACDateTimePicker.AttachPickerToHost;
begin
  if (FPicker = nil) or (FPicker.Parent = Self) or
    not FNativeHostReady or (csLoading in ComponentState) or
    (csDesigning in ComponentState) or
    (csDestroying in ComponentState) or (Parent = nil) or
    not HandleAllocated or not Parent.HandleAllocated then
    Exit;
  FPicker.Parent := Self;
  if FFormatString <> '' then
    FPicker.Format := FFormatString;
  UpdateNativeVisibility;
end;

destructor TDACDateTimePicker.Destroy;
begin
  TDACThemeManager.UnregisterListener(Self);
  if FPopup <> nil then
  begin
    FPopup.OnAccept := nil;
    FPopup.OnClear := nil;
    FPopup.OnHide := nil;
    FPopup.RemoveFreeNotification(Self);
    FreeAndNil(FPopup);
  end;
  FPaintBox.Free;
  FPicker.Free;
  FFieldText.Free;
  FIconPainter.Free;
  FBorderPainter.Free;
  FBackgroundPainter.Free;
  FRenderer.Free;
  inherited;
end;

function TDACDateTimePicker.BorderAlpha: Byte;
var
  LTokens: TDACControlTokens;
begin
  LTokens := ResolvedTokens;
  Result := LTokens.DateTimeBorderAlphaNormal;
  if FPicker.Focused or FPopupActive or FMouseInside then
    Result := LTokens.DateTimeBorderAlphaFocus;
  if not Enabled or FLoading then
    Result := LTokens.DateTimeBorderAlphaDisabled;
end;

function TDACDateTimePicker.BorderColor: TAlphaColor;
var
  LTokens: TDACControlTokens;
begin
  LTokens := ResolvedTokens;
  case FStatus of
    mesSuccess:
      Result := LTokens.DateTimeSuccessBorder;
    mesWarning:
      Result := LTokens.DateTimeWarningBorder;
    mesDanger:
      Result := LTokens.DateTimeDangerBorder;
  else
    if FPicker.Focused or FPopupActive then
      Result := LTokens.DateTimeFocusBorder
    else if FMouseInside then
      Result := LTokens.DateTimeBorderHover
    else
      Result := LTokens.DateTimeBorder;
  end;
end;

function TDACDateTimePicker.CanModifyValue: Boolean;
begin
  Result := Enabled and not FLoading and not FReadOnly and FBindingCanModify;
end;

function TDACDateTimePicker.ChromeTop: Integer;
begin
  Result := DACFieldChromeTop(HasLabel, ResolvedTokens);
end;

procedure TDACDateTimePicker.CMEnabledChanged(var AMessage: TMessage);
begin
  inherited;
  if not Enabled then
  begin
    ClosePopup;
    DACFieldRelinquishFocus(Self, FPicker);
  end;
  UpdatePickerStyle;
  UpdateNativeVisibility;
  Redraw;
end;

procedure TDACDateTimePicker.CMParentColorChanged(var AMessage: TMessage);
begin
  inherited;
  UpdatePickerStyle;
  Redraw;
end;

procedure TDACDateTimePicker.CMParentFontChanged(var AMessage: TMessage);
begin
  inherited;
  UpdatePickerStyle;
  Redraw;
end;

procedure TDACDateTimePicker.CMShowingChanged(var AMessage: TMessage);
begin
  inherited;
  if FPicker = nil then
    Exit;
  if not Showing then
  begin
    ClosePopupForHiddenHost;
    Exit;
  end;
  AttachPickerToHost;
  UpdatePickerStyle;
  UpdateChildBounds;
  UpdateNativeVisibility;
  UpdateZOrder;
  FPickerActivationPending := False;
  RequestNativePickerActivation;
end;

procedure TDACDateTimePicker.ClosePopup;
begin
  if (FPopup <> nil) and FPopup.Visible then
    FPopup.Hide;
  FPopupActive := (FPopup <> nil) and FPopup.Visible;
  UpdateNativeVisibility;
  Redraw;
end;

procedure TDACDateTimePicker.ClosePopupForHiddenHost;
begin
  ClosePopup;
  if (FPicker <> nil) and not Showing then
    FPicker.Visible := False;
  FPickerActivationPending := False;
  Redraw;
end;

procedure TDACDateTimePicker.CreateWnd;
begin
  inherited;
  if not (csLoading in ComponentState) and
    not (csDesigning in ComponentState) then
    FNativeHostReady := True;
  AttachChildrenToHost;
  AttachPickerToHost;
  UpdateZOrder;
  UpdatePaintBoxBounds;
  UpdateChildBounds;
  UpdatePickerStyle;
  Redraw;
  RequestNativePickerActivation;
end;

procedure TDACDateTimePicker.DoMouseEnter(Sender: TObject);
begin
  if FMouseInside then
    Exit;
  FMouseInside := True;
  Redraw;
  if Assigned(OnMouseEnter) then
    OnMouseEnter(Self);
end;

procedure TDACDateTimePicker.DoMouseLeave(Sender: TObject);
var
  LPoint: TPoint;
begin
  if not GetCursorPos(LPoint) then
    Exit;
  LPoint := ScreenToClient(LPoint);
  if PtInRect(ClientRect, LPoint) then
    Exit;

  if not FMouseInside then
    Exit;
  FMouseInside := False;
  Redraw;
  if Assigned(OnMouseLeave) then
    OnMouseLeave(Self);
end;

procedure TDACDateTimePicker.DoPickerChange(Sender: TObject);
begin
  Redraw;
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TDACDateTimePicker.DoAcceptValue(const AValue: TDateTime);
begin
  DateTime := AValue;
end;

procedure TDACDateTimePicker.DoClearValue;
begin
  DateTime := 0;
end;

procedure TDACDateTimePicker.DoPickerEnter(Sender: TObject);
begin
  Redraw;
  if Assigned(OnEnter) then
    OnEnter(Self);
end;

procedure TDACDateTimePicker.DoPickerExit(Sender: TObject);
begin
  Redraw;
  if Assigned(OnExit) then
    OnExit(Self);
end;

procedure TDACDateTimePicker.NativeRequestPopup(Sender: TObject);
begin
  ShowCalendarPopup;
end;

procedure TDACDateTimePicker.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FPopup) then
  begin
    FPopup := nil;
    FPopupActive := False;
  end;
end;

function TDACDateTimePicker.DisplayText: string;
begin
  if FBindingDisplayNull then
    Exit('');
  if FPicker = nil then
    Exit('');
  if FFormatString <> '' then
    Exit(FormatDateTime(FFormatString, FPicker.DateTime));
  if FPicker.Kind = dtkTime then
    Result := TimeToStr(FPicker.DateTime)
  else
    Result := DateToStr(FPicker.DateTime);
end;

function TDACDateTimePicker.IconRect: TRect;
var
  LIconSize: Integer;
  LTop: Integer;
  LBottom: Integer;
begin
  LIconSize := Pixels(Round(ResolvedTokens.DateTimeIconSize));
  LTop := ChromeTop + (Min(Pixels(Round(ResolvedTokens.DateTimeChromeHeight)), Height - ChromeTop) - LIconSize) div 2;
  LBottom := LTop + LIconSize;
  Result := Rect(Width - Pixels(Round(ResolvedTokens.DateTimeIconColumnWidth)),
    LTop, Width - Pixels(Round(ResolvedTokens.DateTimeIconRightInset)), LBottom);
end;

function TDACDateTimePicker.GetDateTime: TDateTime;
begin
  Result := FPicker.DateTime;
end;

function TDACDateTimePicker.GetFormatString: string;
begin
  Result := FFormatString;
end;

function TDACDateTimePicker.GetPickerKind: TDateTimeKind;
begin
  Result := FPicker.Kind;
end;

function TDACDateTimePicker.LabelFontSize: Integer;
begin
  Result := Round(ResolvedTokens.FieldLabelTextSize);
end;

function TDACDateTimePicker.PopupVisible: Boolean;
begin
  Result := (FPopup <> nil) and FPopup.Visible;
end;

function TDACDateTimePicker.PopupSelectedDateTime: TDateTime;
begin
  if FPopup <> nil then
    Result := FPopup.SelectedDateTime
  else
    Result := FPicker.DateTime;
end;

function TDACDateTimePicker.PopupDisplayMonth: TDateTime;
begin
  if FPopup <> nil then
    Result := FPopup.DisplayMonth
  else
    Result := StartOfTheMonth(FPicker.DateTime);
end;

function TDACDateTimePicker.ResolvedPopupBackground: TAlphaColor;
begin
  if FPopup <> nil then
    Result := FPopup.ResolvedBackground
  else
    Result := ResolvedTokens.DateTimePopupBackground;
end;

procedure TDACDateTimePicker.OpenPopup;
begin
  ShowCalendarPopup;
end;

procedure TDACDateTimePicker.SimulatePopupKey(const AKey: Word);
begin
  if FPopup <> nil then
    FPopup.SimulateKey(AKey);
end;

procedure TDACDateTimePicker.SimulatePopupFooter(const AAction: Integer);
begin
  if FPopup <> nil then
    FPopup.SimulateFooterAction(AAction);
end;

procedure TDACDateTimePicker.SimulatePopupExternalDeactivate;
begin
  if FPopup <> nil then FPopup.SimulateExternalDeactivate;
end;

procedure TDACDateTimePicker.SimulatePopupDayClick(const ADay: Integer);
begin
  if FPopup <> nil then
    FPopup.SimulateDayClick(ADay);
end;

function TDACDateTimePicker.HasLabel: Boolean;
begin
  Result := FLabelText.Trim <> '';
end;

function TDACDateTimePicker.HasSupportText: Boolean;
begin
  Result := (FHelperText.Trim <> '') or (FErrorText.Trim <> '');
end;

function TDACDateTimePicker.NativeHostShowing: Boolean;
begin
  Result := Showing;
  // TPageControl can hide an ancestor HWND before the cached FShowing state
  // reaches every descendant. The native visibility is authoritative once
  // this host has a real handle.
  if Result and HandleAllocated and
    not (csDesigning in ComponentState) and
    not (csLoading in ComponentState) then
    Result := IsWindowVisible(Handle);
end;

procedure TDACDateTimePicker.Loaded;
begin
  inherited;
  if FLoading then
  begin
    DACFieldBeginLoadingTabPolicy(Self, FTabStopBeforeLoading,
      FLoadingTabStopCaptured, True);
    DACFieldRelinquishFocus(Self, FPicker);
  end;
  FNativeHostReady := not (csDesigning in ComponentState);
  AttachPickerToHost;
  UpdatePaintBoxBounds;
  UpdateZOrder;
  UpdatePickerStyle;
  UpdateChildBounds;
  Redraw;
  RequestNativePickerActivation;
end;

procedure TDACDateTimePicker.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  if (Button = mbLeft) and CanModifyValue and
    (FPicker <> nil) then
  begin
    if PtInRect(IconRect, Point(X, Y)) then
      ShowCalendarPopup
    else
      SetFocus;
  end;
end;

procedure TDACDateTimePicker.ShowCalendarPopup;
begin
  if (FPicker = nil) or not CanModifyValue or FPopupActive or
    not NativeHostShowing then
    Exit;
  // Guard before hiding the focused native picker. Its OnExit path is allowed
  // to call application code, which must not reenter popup creation.
  FPopupActive := True;
  try
    if FPopup = nil then
    begin
      FPopup := TDACDateTimePickerPopup.Create(Self);
      FPopup.FreeNotification(Self);
      FPopup.OnAccept := PopupAccept;
      FPopup.OnClear := PopupClear;
      FPopup.OnHide := PopupHide;
    end;
    FPopup.ShowFor(Self, ResolvedPopupThemeMode, FPicker.Kind, FPicker.DateTime,
      FTimeStepMinutes);
  finally
    if (FPopup = nil) or not FPopup.Visible then
    begin
      FPopupActive := False;
      Redraw;
    end;
  end;
end;

procedure TDACDateTimePicker.PopupAccept(Sender: TObject);
begin
  if (FPopup <> nil) and CanModifyValue then
    DoAcceptValue(FPopup.SelectedDateTime);
end;

procedure TDACDateTimePicker.PopupClear(Sender: TObject);
begin
  if CanModifyValue then
    DoClearValue;
end;

procedure TDACDateTimePicker.PopupHide(Sender: TObject);
begin
  FPopupActive := False;
  UpdateNativeVisibility;
  Redraw;
end;

procedure TDACDateTimePicker.PaintBoxDraw(Sender: TObject;
  const ACanvas: ISkCanvas; const ADest: TRectF; const AOpacity: Single);
var
  LBackground: TDACBackgroundStyle;
  LBorder: TDACBorderStyle;
  LBorderRect: TRectF;
  LIconRect: TRectF;
  LIconStyle: TDACIconStyle;
  LRect: TRectF;
  LSurface: TAlphaColor;
  LTop: Single;
  LTokens: TDACControlTokens;
begin
  if (ACanvas = nil) or (ADest.Width <= 0) or (ADest.Height <= 0) then
    Exit;
  LTop := ChromeTop;
  LBorderRect := FRenderer.SnapRect(TRectF.Create(0, LTop, ADest.Width,
    Min(ADest.Height, LTop +
      Round(ResolvedTokens.DateTimeChromeHeight))),
    ResolvedTokens.DateTimeBorderSnapScale);
  LRect := LBorderRect;
  LRect.Inflate(-ResolvedTokens.DateTimeBorderInset,
    -ResolvedTokens.DateTimeBorderInset);

  LSurface := ParentSurfaceColor;
  LTokens := ResolvedTokens;
  ACanvas.Clear(LSurface);

  LBackground.Color := LTokens.DateTimeBackground;
  if not Enabled or FLoading then
    LBackground.Color := LTokens.DateTimeDisabledBackground;
  LBackground.Radius := FCornerRadius;
  LBackground.Alpha := LTokens.DateTimeBackgroundAlpha;
  FBackgroundPainter.Draw(ACanvas, LRect, LBackground);

  LBorder.Color := BorderColor;
  LBorder.Radius := FCornerRadius;
  LBorder.Width := LTokens.DateTimeBorderWidth;
  if FPicker.Focused or FPopupActive then
    LBorder.Width := LTokens.DateTimeFocusBorderWidth;
  LBorder.Alpha := BorderAlpha;
  FBorderPainter.Draw(ACanvas, LBorderRect, LBorder);

  LIconRect := TRectF.Create(ADest.Width - Pixels(Round(LTokens.DateTimeIconColumnWidth)),
    LRect.Top + (LRect.Height - Pixels(Round(LTokens.DateTimeIconSize))) / 2,
    ADest.Width - Pixels(Round(LTokens.DateTimeIconRightInset)),
    LRect.Top + (LRect.Height + Pixels(Round(LTokens.DateTimeIconSize))) / 2);
  LIconStyle.Color := LTokens.DateTimeIcon;
  LIconStyle.Alpha := LTokens.DateTimeIconAlpha;
  if not Enabled or FLoading then
    LIconStyle.Color := LTokens.DateTimeIconDisabled;
  if FLoading then
    FIconPainter.Draw(ACanvas, LIconRect, mikRefresh, LIconStyle)
  else if FPicker.Kind = dtkTime then
    FIconPainter.Draw(ACanvas, LIconRect, mikClock, LIconStyle)
  else
    FIconPainter.Draw(ACanvas, LIconRect, mikCalendar, LIconStyle);

end;

function TDACDateTimePicker.ParentSurfaceColor: TAlphaColor;
begin
  Result := ResolvedTokens.DateTimeChromeBackground;
end;

procedure TDACDateTimePicker.Redraw;
begin
  UpdateNativeLabel;
  UpdatePaintBoxBounds;
  if csDesigning in ComponentState then
  begin
    if FPaintBox <> nil then
      FPaintBox.Redraw;
    Invalidate;
    Exit;
  end;
  if (FPaintBox <> nil) and not (csDestroying in ComponentState) and
    not (csDesigning in ComponentState) and (Parent <> nil) and
    HandleAllocated and Parent.HandleAllocated then
    FPaintBox.Redraw;
end;

procedure TDACDateTimePicker.RequestNativePickerActivation;
begin
  if FPickerActivationPending or (FPicker = nil) or
    (csDestroying in ComponentState) or (csDesigning in ComponentState) or
    (csLoading in ComponentState) or
    (Parent = nil) or not HandleAllocated or
    not Parent.HandleAllocated then
    Exit;
  FPickerActivationPending := True;
  PostMessage(Handle, WM_DAC_ACTIVATE_NATIVE_PICKER, 0, 0);
end;

function TDACDateTimePicker.PrepareNativePicker(
  const AShowAndFocus: Boolean): Boolean;
begin
  Result := False;
  if FPreparingNative or (FPicker = nil) or
    not FNativeHostReady or
    (csDestroying in ComponentState) or (csDesigning in ComponentState) or
    (csLoading in ComponentState) or (Parent = nil) or not HandleAllocated or
    not Parent.HandleAllocated then
    Exit;

  FPreparingNative := True;
  try
    AttachPickerToHost;
    if FPicker.Parent <> Self then
      Exit;
    UpdatePickerStyle;
    UpdateChildBounds;
    UpdateNativeClip;
    UpdateNativeVisibility;
    Result := True;
    if AShowAndFocus then
    begin
      FPopupActive := False;
      UpdateZOrder;
      if Enabled and not FLoading and FPicker.CanFocus then
        FPicker.SetFocus
      else
        Result := False;
    end;
  finally
    FPreparingNative := False;
  end;
  Redraw;
end;

procedure TDACDateTimePicker.Resize;
begin
  inherited;
  UpdatePaintBoxBounds;
  UpdateZOrder;
  UpdateChildBounds;
  Redraw;
end;

function TDACDateTimePicker.Pixels(const AValue: Integer): Integer;
begin
  Result := AValue;
end;

function TDACDateTimePicker.ResolvedTokens: TDACControlTokens;
begin
  Result := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls;
end;

function TDACDateTimePicker.ResolvedFieldState: TDACResolvedFieldState;
begin
  Result := TDACFieldStateResolver.Resolve(Enabled, FLoading,
    FReadOnly or not FBindingCanModify,
    (FPicker <> nil) and FPicker.Focused, FMouseInside, DisplayText <> '',
    TDACFieldValidation(Ord(FStatus)));
end;

function TDACDateTimePicker.ResolvedPopupThemeMode: TDACThemeMode;
begin
  if FThemeMode <> dtmInherit then
    Exit(FThemeMode);
  if ResolvedTokens.DateTimePopupBackground =
    TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.DateTimePopupBackground then
    Result := dtmLight
  else
    Result := dtmDark;
end;

procedure TDACDateTimePicker.SetCornerRadius(const AValue: Integer);
begin
  if FCornerRadius = AValue then
    Exit;
  FCornerRadius := Max(0, AValue);
  Redraw;
end;

procedure TDACDateTimePicker.SetDateTime(const AValue: TDateTime);
begin
  if SameValue(FPicker.DateTime, AValue) then
    Exit;
  FPicker.DateTime := AValue;
  Redraw;
end;

procedure TDACDateTimePicker.SetErrorText(const AValue: string);
begin
  if FErrorText = AValue then
    Exit;
  FErrorText := AValue;
  if HasSupportText and (Height <= ChromeTop +
    Round(ResolvedTokens.DateTimeChromeHeight)) then
    Height := DACFieldTotalHeight(HasLabel, True,
      Round(ResolvedTokens.DateTimeChromeHeight), ResolvedTokens);
  Redraw;
end;

procedure TDACDateTimePicker.SetFocus;
begin
  if (FPicker = nil) or not Enabled or FLoading then
    Exit;
  PrepareNativePicker(True);
end;

procedure TDACDateTimePicker.SetFormatString(const AValue: string);
begin
  if FFormatString = AValue then
    Exit;
  FFormatString := AValue;
  if (FPicker <> nil) and (FPicker.Parent = Self) and
    (Parent <> nil) and HandleAllocated and Parent.HandleAllocated and
    FPicker.HandleAllocated then
    FPicker.Format := AValue;
  UpdatePickerStyle;
end;

procedure TDACDateTimePicker.SetHelperText(const AValue: string);
begin
  if FHelperText = AValue then
    Exit;
  FHelperText := AValue;
  if HasSupportText and (Height <= ChromeTop +
    Round(ResolvedTokens.DateTimeChromeHeight)) then
    Height := DACFieldTotalHeight(HasLabel, True,
      Round(ResolvedTokens.DateTimeChromeHeight), ResolvedTokens);
  Redraw;
end;

procedure TDACDateTimePicker.SetLabelText(const AValue: string);
var
  LHadLabel: Boolean;
begin
  if FLabelText = AValue then
    Exit;

  LHadLabel := HasLabel;
  FLabelText := AValue;
  if (not LHadLabel) and HasLabel and
    (Height <= Pixels(Round(ResolvedTokens.DateTimeChromeHeight))) then
    Height := DACFieldTotalHeight(HasLabel, HasSupportText,
      Round(ResolvedTokens.DateTimeChromeHeight), ResolvedTokens);
  Redraw;
end;

procedure TDACDateTimePicker.SetLoading(const AValue: Boolean);
begin
  if FLoading = AValue then
    Exit;
  FLoading := AValue;
  if FLoading then
  begin
    DACFieldBeginLoadingTabPolicy(Self, FTabStopBeforeLoading,
      FLoadingTabStopCaptured);
    ClosePopup;
    DACFieldRelinquishFocus(Self, FPicker);
  end;
  UpdatePickerStyle;
  if not FLoading then
    DACFieldEndLoadingTabPolicy(Self, FTabStopBeforeLoading,
      FLoadingTabStopCaptured);
  UpdateNativeVisibility;
  Redraw;
end;

procedure TDACDateTimePicker.SetPickerKind(const AValue: TDateTimeKind);
begin
  if FPicker.Kind = AValue then
    Exit;
  FPicker.Kind := AValue;
  UpdatePickerStyle;
  Redraw;
end;

procedure TDACDateTimePicker.SetReadOnly(const AValue: Boolean);
begin
  if FReadOnly = AValue then
    Exit;
  FReadOnly := AValue;
  if FReadOnly then
    ClosePopup;
  UpdatePickerStyle;
  UpdateNativeVisibility;
  Redraw;
end;

procedure TDACDateTimePicker.SetBindingCanModify(const AValue: Boolean);
begin
  if FBindingCanModify = AValue then
    Exit;
  FBindingCanModify := AValue;
  if not FBindingCanModify then
    ClosePopup;
  UpdatePickerStyle;
  UpdateNativeVisibility;
  Redraw;
end;

procedure TDACDateTimePicker.SetBindingDisplayNull(const AValue: Boolean);
begin
  if FBindingDisplayNull = AValue then
    Exit;
  FBindingDisplayNull := AValue;
  UpdateNativeVisibility;
  Redraw;
end;

procedure TDACDateTimePicker.SetRequired(const AValue: Boolean);
begin
  if FRequired = AValue then
    Exit;
  FRequired := AValue;
  Redraw;
end;

procedure TDACDateTimePicker.SetStatus(const AValue: TDACEditStatus);
begin
  if FStatus = AValue then
    Exit;
  FStatus := AValue;
  Redraw;
end;

procedure TDACDateTimePicker.SetThemeMode(const AValue: TDACThemeMode);
begin
  if FThemeMode = AValue then
  begin
    ThemeChanged(Self);
    Exit;
  end;
  FThemeMode := AValue;
  ThemeChanged(Self);
end;

procedure TDACDateTimePicker.SetTimeStepMinutes(const AValue: Integer);
begin
  FTimeStepMinutes := Max(1, AValue);
end;

procedure TDACDateTimePicker.ThemeChanged(Sender: TObject);
begin
  AttachPickerToHost;
  Color := DateTimeVclColor(ResolvedTokens.DateTimeChromeBackground);
  UpdatePickerStyle;
  if FPopup <> nil then
    FPopup.ApplyThemeMode(ResolvedPopupThemeMode);
  Redraw;
end;

procedure TDACDateTimePicker.UpdateChildBounds;
var
  LChromeHeight: Integer;
  LHorizontalPadding: Integer;
  LInnerHeight: Integer;
  LInnerTop: Integer;
  LRightPadding: Integer;
  LTop: Integer;
  LInputHeight: Integer;
  LInputLeft: Integer;
  LInputWidth: Integer;
  LTokens: TDACControlTokens;
begin
  if FPicker = nil then
    Exit;

  { Bounds and label updates invalidate child controls. Defer them until the
    composed control has a real native host. }
  if (FPicker.Parent <> Self) or (Parent = nil) or
    not HandleAllocated or not Parent.HandleAllocated then
    Exit;

  LTokens := ResolvedTokens;
  LHorizontalPadding := Pixels(Round(LTokens.DateTimeNativeHorizontalPadding));
  LRightPadding := Pixels(Round(LTokens.DateTimeNativeRightPadding));
  LInputLeft := LHorizontalPadding + Pixels(Round(LTokens.DateTimeNativeLeftInset));
  LChromeHeight := Min(Max(0, Height - ChromeTop),
    Round(LTokens.DateTimeChromeHeight));
  { Keep the native DateTime HWND inside the same physical border safe area
    as TDACEdit and TDACComboBox. This prevents the native window from
    covering the lower Skia border when the compact 30 px field is used. }
  LInnerTop := ChromeTop + Max(1, Ceil(LTokens.DateTimeBorderWidth));
  LInnerHeight := Max(0, LChromeHeight -
    (Max(1, Ceil(LTokens.DateTimeBorderWidth)) * 2));
  LInputHeight := Min(LInnerHeight,
    Round(LTokens.DateTimeEditorHeight));
  LTop := LInnerTop + Max(0, (LInnerHeight - LInputHeight) div 2) +
    Pixels(Round(LTokens.InputNativeVerticalOffset));
  LTop := Min(LInnerTop + Max(0, LInnerHeight - LInputHeight), LTop);
  LInputWidth := Max(0, Width - LInputLeft - LRightPadding);
  { The HWND extends under its clipped native dropdown column; the assigned
    region exposes exactly the text viewport and does not reduce editable
    segment width. }
  FPicker.SetBounds(LInputLeft, LTop,
    LInputWidth + Round(LTokens.DateTimeNativeDropdownClipWidth),
    LInputHeight);
  { SysDateTimePick32 may enforce an OS-specific minimum HWND height. Recenter
    the height Windows actually accepted inside the safe inner row so the
    native viewport stays optically aligned without covering the Skia border. }
  LTop := LInnerTop + Max(0, (LInnerHeight - FPicker.Height) div 2) +
    Pixels(Round(LTokens.InputNativeVerticalOffset));
  LTop := Min(LInnerTop + Max(0, LInnerHeight - FPicker.Height), LTop);
  if FPicker.Top <> LTop then
    FPicker.Top := LTop;
  UpdateNativeClip;
  UpdateNativeLabel;
end;

procedure TDACDateTimePicker.UpdateNativeClip;
begin
  if not (FPicker is TDACNativeDateTimePicker) then
    Exit;

  // The native dropdown glyph is deliberately clipped. The value/caret remain
  // native while the trigger visible to the user is the Skia calendar/clock.
  TDACNativeDateTimePicker(FPicker).DropdownClipWidth :=
    Round(ResolvedTokens.DateTimeNativeDropdownClipWidth);
  TDACNativeDateTimePicker(FPicker).VerticalClipInset :=
    Round(ResolvedTokens.DateTimeNativeVerticalClipInset);
end;

procedure TDACDateTimePicker.UpdateNativeLabel;
begin
  if FFieldText = nil then
    Exit;
  FFieldText.Update(FLabelText, FHelperText, FErrorText, '', FRequired,
    ResolvedFieldState, Width, ChromeTop,
    Round(ResolvedTokens.DateTimeChromeHeight), ResolvedTokens);
end;

procedure TDACDateTimePicker.UpdatePaintBoxBounds;
var
  LHeight: Integer;
  LWidth: Integer;
  LTop: Integer;
begin
  if FPaintBox = nil then
    Exit;

  LWidth := Width;
  LHeight := Height;
  if HandleAllocated then
  begin
    LWidth := ClientWidth;
    LHeight := ClientHeight;
  end;

  LTop := 0;
  if (FPaintBox.Left <> 0) or (FPaintBox.Top <> LTop) or
    (FPaintBox.Width <> LWidth) or (FPaintBox.Height <> LHeight) then
    FPaintBox.SetBounds(0, LTop, LWidth, LHeight);
end;

procedure TDACDateTimePicker.UpdatePickerStyle;
var
  LBackgroundToken: TAlphaColor;
  LBackgroundColor: TColor;
  LTokens: TDACControlTokens;
  LTextColor: TColor;
begin
  if FPicker = nil then
    Exit;

  { Delphi 10.2's TDateTimePicker CM_COLORCHANGED/CM_FONTCHANGED handlers call
    InvalidateRect(Handle, ...) unconditionally. Styling a detached picker
    would therefore create its HWND before the host has a parent window. }
  if (FPicker.Parent <> Self) or (Parent = nil) or
    not HandleAllocated or not Parent.HandleAllocated then
    Exit;

  LTokens := ResolvedTokens;
  FPicker.Enabled := Enabled and not FLoading;
  TDACNativeDateTimePicker(FPicker).InteractionLocked :=
    not CanModifyValue;
  LBackgroundToken := LTokens.DateTimeBackground;
  if not Enabled or FLoading then
    LBackgroundToken := LTokens.DateTimeDisabledBackground;
  LBackgroundColor := DateTimeVclColor(LBackgroundToken);
  TDACNativeDateTimePicker(FPicker).DarkNativeTheme :=
    TDACComponentColors.IsDarkSurface(LBackgroundToken);
  FPicker.Color := LBackgroundColor;
  FPicker.Font.Name := TDACComponentFontInstaller.FontFamily;
  FPicker.Font.Size := Round(LTokens.DateTimeTextSize);
  FPicker.Font.Style := [];
  LTextColor := DateTimeVclColor(LTokens.DateTimeText);
  if not Enabled or FLoading then
    LTextColor := DateTimeVclColor(LTokens.DateTimeDisabledText);
  FPicker.Font.Color := LTextColor;
  { Font changes can make the native class renegotiate its fixed HWND height. }
  UpdateChildBounds;
  UpdateNativeLabel;
  Cursor := crDefault;
  FPaintBox.Cursor := crDefault;
  FPicker.Cursor := crDefault;
end;

procedure TDACDateTimePicker.UpdateNativeVisibility;
begin
  if (FPicker = nil) or (FPicker.Parent <> Self) then
    Exit;
  { The VCL Visible flag represents the field contract; ancestor HWND
    visibility is evaluated separately by NativeHostShowing. Using Showing
    here avoids losing the child during the brief CM_SHOWING phase before
    IsWindowVisible has caught up. }
  FPicker.Visible := Showing and
    not FBindingDisplayNull and
    not (csDestroying in ComponentState) and
    not (csDesigning in ComponentState);
end;

procedure TDACDateTimePicker.UpdateZOrder;
begin
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    Exit;
  if csDesigning in ComponentState then
    Exit;
  if (Parent = nil) or not HandleAllocated or not Parent.HandleAllocated or
    not Showing then
    Exit;

  if FPaintBox <> nil then
    FPaintBox.SendToBack;
  if FPicker <> nil then
    FPicker.BringToFront;
end;

procedure TDACDateTimePicker.WMDACActivateNativePicker(var AMessage: TMessage);
begin
  if (FPicker = nil) or (csDestroying in ComponentState) or
    (csDesigning in ComponentState) or (Parent = nil) or not HandleAllocated or
    not Parent.HandleAllocated or not NativeHostShowing then
  begin
    { CM_SHOWINGCHANGED is the authoritative hide path. A delayed activation
      posted by the previous page state must never hide a picker that a newer
      showing transition is about to materialize. }
    FPickerActivationPending := False;
    Exit;
  end;
  // The child can receive CreateWnd/CM_SHOWING while a parent TPageControl is
  // still at its streamed coordinates. One extra queued phase lets the form
  // and Tabs commit their posted reflow before this native HWND ever becomes
  // visible, avoiding a persistent first-frame imprint at the old position.
  if AMessage.WParam = 0 then
  begin
    PostMessage(Handle, WM_DAC_ACTIVATE_NATIVE_PICKER, 1, 0);
    Exit;
  end;
  FPickerActivationPending := False;
  PrepareNativePicker(False);
end;

procedure TDACDateTimePicker.WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
begin
  AMessage.Result := 1;
end;

procedure TDACDateTimePicker.WMSetFocus(var AMessage: TWMSetFocus);
begin
  inherited;
  if FLoading or not Enabled then
  begin
    DACFieldRelinquishFocus(Self, FPicker);
    Exit;
  end;
  // Dialog navigation focuses the composite HWND, not the reintroduced
  // SetFocus method. Transfer that focus to the native picker so Tab exposes
  // the same selection/caret behavior as a direct mouse activation.
  if (FPicker <> nil) and
    not FPopupActive and
    not FPreparingNative and not FPicker.Focused then
    SetFocus;
end;

end.

