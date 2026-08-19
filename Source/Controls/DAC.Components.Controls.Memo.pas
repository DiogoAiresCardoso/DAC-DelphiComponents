unit DAC.Components.Controls.Memo;

interface

uses
  System.Classes,
  System.Skia,
  System.Types,
  System.UITypes,
  System.SysUtils,
  Winapi.Messages,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Graphics,
  Vcl.Skia,
  Vcl.StdCtrls,
  DAC.Components.Controls.Edit,
  DAC.Components.Controls.FieldSupport,
  DAC.Components.DesignSystem.Fonts,
  DAC.Components.DesignSystem.ComponentStyle,
  DAC.Components.DesignSystem.ControlTokens,
  DAC.Components.DesignSystem.Theme,
  DAC.Components.Skia.BackgroundPainter,
  DAC.Components.Skia.BorderPainter,
  DAC.Components.Skia.Renderer;

{$IFDEF DAC_COMPONENTS_TESTS}
type
  TDACMemoWheelScrollLinesQuery = function(
    out AScrollLines: Cardinal): Boolean;

procedure DACMemoSetWheelScrollLinesQueryForTests(
  const AQuery: TDACMemoWheelScrollLinesQuery);
{$ENDIF}

type
  TDACMemo = class(TCustomControl)
  private
    FBackgroundPainter: TDACSkiaBackgroundPainter;
    FBindingCanModify: Boolean;
    FBorderPainter: TDACSkiaBorderPainter;
    FCornerRadius: Integer;
    FErrorText: string;
    FFieldText: TDACFieldTextSupport;
    FHelperText: string;
    FLabelText: string;
    FLines: TStringList;
    FMemo: TMemo;
    FMouseInside: Boolean;
    FOnChange: TNotifyEvent;
    FPaintBox: TSkPaintBox;
    FNativeLabel: TLabel;
    FLoading: Boolean;
    FLoadingTabStopCaptured: Boolean;
    FReadOnly: Boolean;
    FRenderer: TDACSkiaRenderer;
    FRequired: Boolean;
    FStatus: TDACEditStatus;
    FThemeMode: TDACThemeMode;
    FTabStopBeforeLoading: Boolean;
    FText: string;
    FUpdatingLines: Boolean;
    procedure ApplyTextToMemo;
    function BorderAlpha: Byte;
    function BorderColor: TAlphaColor;
    function CanUpdateChildren: Boolean;
    procedure CMEnabledChanged(var AMessage: TMessage); message CM_ENABLEDCHANGED;
    procedure CMParentColorChanged(var AMessage: TMessage); message CM_PARENTCOLORCHANGED;
    procedure CMParentFontChanged(var AMessage: TMessage); message CM_PARENTFONTCHANGED;
    procedure DoMemoChange(Sender: TObject);
    procedure DoMemoEnter(Sender: TObject);
    procedure DoMemoExit(Sender: TObject);
    procedure DoMouseEnter(Sender: TObject);
    procedure DoMouseLeave(Sender: TObject);
    function GetLines: TStrings;
    function GetReadOnly: Boolean;
    function GetScrollBars: System.UITypes.TScrollStyle;
    function GetText: string;
    function GetWordWrap: Boolean;
    function HasLabel: Boolean;
    function HasSupportText: Boolean;
    function ChromeTop: Integer;
    function ChromeHeight: Integer;
    function ResolvedFieldState: TDACResolvedFieldState;
    procedure InvalidateParentRegion(const ABounds: TRect);
    procedure LinesChanged(Sender: TObject);
    procedure PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    function Pixels(const AValue: Integer): Integer;
    function ResolvedTokens: TDACControlTokens;
    procedure SetCornerRadius(const AValue: Integer);
    procedure SetErrorText(const AValue: string);
    procedure SetHelperText(const AValue: string);
    procedure SetLabelText(const AValue: string);
    procedure SetLines(const AValue: TStrings);
    procedure SetLoading(const AValue: Boolean);
    procedure SetReadOnly(const AValue: Boolean);
    procedure SetScrollBars(const AValue: System.UITypes.TScrollStyle);
    procedure SetRequired(const AValue: Boolean);
    procedure SetStatus(const AValue: TDACEditStatus);
    procedure SetText(const AValue: string);
    procedure SetThemeMode(const AValue: TDACThemeMode);
    procedure SetWordWrap(const AValue: Boolean);
    procedure ThemeChanged(Sender: TObject);
    procedure UpdateChildBounds;
    procedure UpdateMemoStyle;
    procedure UpdatePaintBoxBounds;
    procedure UpdateZOrder;
    procedure WMEraseBkgnd(var AMessage: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMSetFocus(var AMessage: TWMSetFocus); message WM_SETFOCUS;
  protected
    procedure CreateWnd; override;
    procedure Loaded; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Resize; override;
    procedure SetBindingCanModify(const AValue: Boolean);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function LabelFontSize: Integer;
    procedure Redraw;
    procedure SetFocus; reintroduce;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
    property MemoControl: TMemo read FMemo;
    property NativeLabel: TLabel read FNativeLabel;
  published
    property Align;
    property Anchors;
    property Constraints;
    property CornerRadius: Integer read FCornerRadius write SetCornerRadius
      default DACMemoDefaultCornerRadius;
    property Enabled;
    property ErrorText: string read FErrorText write SetErrorText;
    property Font;
    property HelperText: string read FHelperText write SetHelperText;
    property LabelText: string read FLabelText write SetLabelText;
    property Loading: Boolean read FLoading write SetLoading default False;
    property Lines: TStrings read GetLines write SetLines;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly default False;
    property Required: Boolean read FRequired write SetRequired default False;
    property ScrollBars: System.UITypes.TScrollStyle read GetScrollBars write SetScrollBars default ssNone;
    property ShowHint;
    property Status: TDACEditStatus read FStatus write SetStatus default mesNormal;
    property TabOrder;
    property TabStop default True;
    property Text: string read GetText write SetText;
    property ThemeMode: TDACThemeMode read FThemeMode write SetThemeMode default dtmInherit;
    property Visible;
    property WordWrap: Boolean read GetWordWrap write SetWordWrap default True;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
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

implementation

uses
  System.Math,
  Winapi.Windows,
  DAC.Components.Controls.ScrollContainer;

{$IFNDEF DAC_COMPONENTS_TESTS}
type
  TDACMemoWheelScrollLinesQuery = function(
    out AScrollLines: Cardinal): Boolean;
{$ENDIF}

type
  TDACNativeMemo = class(TMemo)
  private
    FWheelDeltaRemainder: Integer;
    function CanScrollInDirection(const AWheelDelta: SmallInt): Boolean;
    function HasRuntimeScrollAncestor: Boolean;
    function NativeLineHeight: Integer;
    function ResolveLinesPerDetent: Integer;
    function ShouldOwnWheel(const APoint: TPoint): Boolean;
  public
    procedure MouseWheelHandler(var AMessage: TMessage); override;
  end;

var
  GWheelScrollLinesQuery: TDACMemoWheelScrollLinesQuery;

function QuerySystemWheelScrollLines(out AScrollLines: Cardinal): Boolean;
begin
  Result := SystemParametersInfo(SPI_GETWHEELSCROLLLINES, 0,
    @AScrollLines, 0);
end;

{$IFDEF DAC_COMPONENTS_TESTS}
procedure DACMemoSetWheelScrollLinesQueryForTests(
  const AQuery: TDACMemoWheelScrollLinesQuery);
begin
  GWheelScrollLinesQuery := AQuery;
end;
{$ENDIF}

function TDACNativeMemo.CanScrollInDirection(
  const AWheelDelta: SmallInt): Boolean;
var
  LFormatRect: TRect;
  LLastLineIndex: LRESULT;
  LLastLinePosition: LRESULT;
  LLastLineTop: SmallInt;
  LLineCount: Integer;
begin
  Result := False;
  if (AWheelDelta = 0) or not HandleAllocated or not IsWindow(Handle) then
    Exit;
  if AWheelDelta > 0 then
  begin
    Result := SendMessage(Handle, EM_GETFIRSTVISIBLELINE, 0, 0) > 0;
    Exit;
  end;

  LLineCount := SendMessage(Handle, EM_GETLINECOUNT, 0, 0);
  if LLineCount <= 0 then
    Exit;
  LLastLineIndex := SendMessage(Handle, EM_LINEINDEX, LLineCount - 1, 0);
  if LLastLineIndex < 0 then
    Exit;
  LLastLinePosition := SendMessage(Handle, EM_POSFROMCHAR,
    LLastLineIndex, 0);
  if LLastLinePosition = -1 then
    Exit;
  LLastLineTop := SmallInt(HiWord(DWORD(LLastLinePosition)));
  FillChar(LFormatRect, SizeOf(LFormatRect), 0);
  SendMessage(Handle, EM_GETRECT, 0, LPARAM(@LFormatRect));
  Result := LLastLineTop + NativeLineHeight > LFormatRect.Bottom;
end;

function TDACNativeMemo.HasRuntimeScrollAncestor: Boolean;
var
  LAncestor: TWinControl;
  LScroll: TDACScrollContainer;
begin
  Result := False;
  LAncestor := Parent;
  while LAncestor <> nil do
  begin
    if LAncestor is TDACScrollContainer then
    begin
      LScroll := TDACScrollContainer(LAncestor);
      Result := not (csDesigning in LScroll.ComponentState) and
        not (csLoading in LScroll.ComponentState) and
        not (csDestroying in LScroll.ComponentState) and
        LScroll.HandleAllocated and IsWindow(LScroll.Handle) and
        IsChild(LScroll.Handle, Handle);
      Exit;
    end;
    LAncestor := LAncestor.Parent;
  end;
end;

function TDACNativeMemo.ResolveLinesPerDetent: Integer;
var
  LFormatRect: TRect;
  LScrollLines: Cardinal;
begin
  if Assigned(GWheelScrollLinesQuery) then
  begin
    if not GWheelScrollLinesQuery(LScrollLines) then
      LScrollLines := 3;
  end
  else if not QuerySystemWheelScrollLines(LScrollLines) then
    LScrollLines := 3;

  if LScrollLines = 0 then
    Exit(0);
  if LScrollLines = WHEEL_PAGESCROLL then
  begin
    FillChar(LFormatRect, SizeOf(LFormatRect), 0);
    SendMessage(Handle, EM_GETRECT, 0, LPARAM(@LFormatRect));
    Result := Max(1, ((LFormatRect.Bottom - LFormatRect.Top) div
      NativeLineHeight) - 1);
    Exit;
  end;
  Result := Min(Integer(LScrollLines), 100);
end;

procedure TDACNativeMemo.MouseWheelHandler(var AMessage: TMessage);
var
  LLineDelta: Int64;
  LLinesPerDetent: Integer;
  LNativeNotches: Integer;
  LPoint: TPoint;
  LWheelDelta: SmallInt;
begin
  LPoint := SmallPointToPoint(TCMMouseWheel(AMessage).Pos);
  LWheelDelta := TCMMouseWheel(AMessage).WheelDelta;
  if not ShouldOwnWheel(LPoint) or
    not CanScrollInDirection(LWheelDelta) then
  begin
    FWheelDeltaRemainder := 0;
    inherited;
    Exit;
  end;

  if DoMouseWheel(TCMMouseWheel(AMessage).ShiftState, LWheelDelta,
    LPoint) then
  begin
    FWheelDeltaRemainder := 0;
    AMessage.Result := 1;
    Exit;
  end;

  if ((FWheelDeltaRemainder > 0) and (LWheelDelta < 0)) or
    ((FWheelDeltaRemainder < 0) and (LWheelDelta > 0)) then
    FWheelDeltaRemainder := 0;
  Inc(FWheelDeltaRemainder, LWheelDelta);
  if Abs(FWheelDeltaRemainder) < WHEEL_DELTA then
  begin
    // Keep this partial delta exclusively in the native editor. Returning a
    // handled result prevents it from feeding the outer accumulator too.
    AMessage.Result := 1;
    Exit;
  end;

  LNativeNotches := FWheelDeltaRemainder div WHEEL_DELTA;
  FWheelDeltaRemainder := FWheelDeltaRemainder -
    (LNativeNotches * WHEEL_DELTA);
  LLinesPerDetent := ResolveLinesPerDetent;
  LLineDelta := -Int64(Sign(LNativeNotches)) *
    LLinesPerDetent * Abs(LNativeNotches);
  LLineDelta := EnsureRange(LLineDelta, Low(Integer), High(Integer));
  if LLineDelta <> 0 then
    SendMessage(Handle, EM_LINESCROLL, 0, LPARAM(Integer(LLineDelta)));
  // The Memo owned this detent before delivery. An SPI setting of zero, or
  // an unexpected no-op from EDIT, cannot leak the same input to the outer.
  AMessage.Result := 1;
end;

function TDACNativeMemo.NativeLineHeight: Integer;
var
  LDC: HDC;
  LFont: HFONT;
  LOldFont: HGDIOBJ;
  LTextMetric: TTextMetric;
begin
  Result := 1;
  if not HandleAllocated or not IsWindow(Handle) then
    Exit;
  LDC := GetDC(Handle);
  if LDC = 0 then
    Exit;
  LOldFont := 0;
  try
    LFont := HFONT(SendMessage(Handle, WM_GETFONT, 0, 0));
    if LFont <> 0 then
      LOldFont := SelectObject(LDC, LFont);
    if GetTextMetrics(LDC, LTextMetric) then
      Result := Max(1, LTextMetric.tmHeight + LTextMetric.tmExternalLeading);
  finally
    if LOldFont <> 0 then
      SelectObject(LDC, LOldFont);
    ReleaseDC(Handle, LDC);
  end;
end;

function TDACNativeMemo.ShouldOwnWheel(const APoint: TPoint): Boolean;
begin
  Result := not (csDesigning in ComponentState) and
    not (csLoading in ComponentState) and
    not (csDestroying in ComponentState) and
    Visible and Enabled and HandleAllocated and IsWindow(Handle) and
    (WindowFromPoint(APoint) = Handle) and HasRuntimeScrollAncestor;
end;

function MemoVclColor(const AColor: TAlphaColor): TColor;
begin
  Result := TColor(((AColor and $00FF0000) shr 16) or
    (AColor and $0000FF00) or ((AColor and $000000FF) shl 16));
end;

constructor TDACMemo.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque, csClickEvents, csCaptureMouse];
  Width := Round(ResolvedTokens.MemoDefaultWidth);
  Height := Round(ResolvedTokens.MemoDefaultHeight);
  TabStop := True;
  ParentColor := False;
  FBindingCanModify := True;
  StyleElements := [];
  Cursor := crIBeam;
  Color := MemoVclColor(ResolvedTokens.MemoChromeBackground);
  FCornerRadius := Round(ResolvedTokens.MemoCornerRadius);
  FStatus := mesNormal;
  FThemeMode := dtmInherit;
  TDACThemeManager.RegisterListener(Self, ThemeChanged);

  FRenderer := TDACSkiaRenderer.Create;
  FBackgroundPainter := TDACSkiaBackgroundPainter.Create(FRenderer);
  FBorderPainter := TDACSkiaBorderPainter.Create(FRenderer);

  FLines := TStringList.Create;
  FLines.OnChange := LinesChanged;

  FPaintBox := TSkPaintBox.Create(Self);
  FPaintBox.Parent := Self;
  FPaintBox.SetSubComponent(True);
  FPaintBox.StyleElements := [];
  FPaintBox.Cursor := crIBeam;
  FPaintBox.OnDraw := PaintBoxDraw;
  FPaintBox.OnMouseEnter := DoMouseEnter;
  FPaintBox.OnMouseLeave := DoMouseLeave;

  FMemo := TDACNativeMemo.Create(Self);
  FMemo.Parent := Self;
  FMemo.SetSubComponent(True);
  FMemo.BorderStyle := bsNone;
  FMemo.StyleElements := [];
  FMemo.ParentFont := False;
  FMemo.WordWrap := True;
  FMemo.OnChange := DoMemoChange;
  FMemo.OnEnter := DoMemoEnter;
  FMemo.OnExit := DoMemoExit;
  FMemo.OnMouseEnter := DoMouseEnter;
  FMemo.OnMouseLeave := DoMouseLeave;

  FFieldText := TDACFieldTextSupport.Create(Self, Self);
  FNativeLabel := FFieldText.CaptionLabel;
  FFieldText.SetFocusControl(FMemo);

  UpdateMemoStyle;
  Resize;
end;

destructor TDACMemo.Destroy;
begin
  TDACThemeManager.UnregisterListener(Self);
  FLines.OnChange := nil;
  FFieldText.Free;
  FMemo.Free;
  FPaintBox.Free;
  FLines.Free;
  FBorderPainter.Free;
  FBackgroundPainter.Free;
  FRenderer.Free;
  inherited;
end;

procedure TDACMemo.ApplyTextToMemo;
begin
  if (FMemo = nil) or not CanUpdateChildren or not FMemo.HandleAllocated then
    Exit;

  FUpdatingLines := True;
  try
    FMemo.Text := FText;
  finally
    FUpdatingLines := False;
  end;
end;

function TDACMemo.BorderAlpha: Byte;
var
  LTokens: TDACControlTokens;
begin
  LTokens := ResolvedTokens;
  if not Enabled or FLoading then
    Result := LTokens.MemoBorderAlphaDisabled
  else if FMemo.Focused then
    Result := LTokens.MemoBorderAlphaFocus
  else if FStatus <> mesNormal then
    Result := LTokens.MemoBorderAlphaStatus
  else if FMouseInside then
    Result := LTokens.MemoBorderAlphaHover
  else
    Result := LTokens.MemoBorderAlphaNormal;
end;

function TDACMemo.BorderColor: TAlphaColor;
var
  LTokens: TDACControlTokens;
begin
  LTokens := ResolvedTokens;
  case FStatus of
    mesSuccess:
      Result := LTokens.MemoSuccessBorder;
    mesWarning:
      Result := LTokens.MemoWarningBorder;
    mesDanger:
      Result := LTokens.MemoDangerBorder;
  else
    if FMemo.Focused then
      Result := LTokens.MemoFocusBorder
    else if FMouseInside then
      Result := LTokens.MemoBorderHover
    else
      Result := LTokens.MemoBorder;
  end;
end;
procedure TDACMemo.CMEnabledChanged(var AMessage: TMessage);
begin
  inherited;
  if not Enabled then
    DACFieldRelinquishFocus(Self, FMemo);
  UpdateMemoStyle;
  Redraw;
end;

function TDACMemo.CanUpdateChildren: Boolean;
begin
  Result := not (csDestroying in ComponentState) and (Parent <> nil) and
    HandleAllocated and Parent.HandleAllocated;
end;

procedure TDACMemo.CMParentColorChanged(var AMessage: TMessage);
begin
  inherited;
  UpdateMemoStyle;
  Redraw;
end;

procedure TDACMemo.CMParentFontChanged(var AMessage: TMessage);
begin
  inherited;
  UpdateMemoStyle;
  Redraw;
end;

procedure TDACMemo.CreateWnd;
begin
  inherited;
  ApplyTextToMemo;
  UpdateZOrder;
  UpdateChildBounds;
  UpdateMemoStyle;
  Redraw;
end;

procedure TDACMemo.DoMemoChange(Sender: TObject);
begin
  if not FUpdatingLines and (FMemo <> nil) and FMemo.HandleAllocated then
  begin
    FUpdatingLines := True;
    try
  FText := FMemo.Text;
  FLines.Text := FText;
  Redraw;
    finally
      FUpdatingLines := False;
    end;
  end;
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TDACMemo.DoMemoEnter(Sender: TObject);
begin
  Redraw;
  if Assigned(OnEnter) then
    OnEnter(Self);
end;

procedure TDACMemo.DoMemoExit(Sender: TObject);
begin
  Redraw;
  if Assigned(OnExit) then
    OnExit(Self);
end;

procedure TDACMemo.DoMouseEnter(Sender: TObject);
begin
  if FMouseInside then
    Exit;
  FMouseInside := True;
  Redraw;
  if Assigned(OnMouseEnter) then
    OnMouseEnter(Self);
end;

procedure TDACMemo.DoMouseLeave(Sender: TObject);
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

procedure TDACMemo.Loaded;
begin
  inherited;
  if FLoading then
  begin
    DACFieldBeginLoadingTabPolicy(Self, FTabStopBeforeLoading,
      FLoadingTabStopCaptured, True);
    DACFieldRelinquishFocus(Self, FMemo);
  end;
  UpdatePaintBoxBounds;
  UpdateZOrder;
  UpdateChildBounds;
  UpdateMemoStyle;
  Redraw;
end;

function TDACMemo.GetLines: TStrings;
begin
  Result := FLines;
end;

function TDACMemo.GetReadOnly: Boolean;
begin
  Result := FReadOnly;
end;

function TDACMemo.GetScrollBars: System.UITypes.TScrollStyle;
begin
  Result := FMemo.ScrollBars;
end;

function TDACMemo.GetText: string;
begin
  if CanUpdateChildren and (FMemo <> nil) and FMemo.HandleAllocated then
    Result := FMemo.Text
  else
    Result := FText;
end;

function TDACMemo.GetWordWrap: Boolean;
begin
  Result := FMemo.WordWrap;
end;

function TDACMemo.HasLabel: Boolean;
begin
  Result := FLabelText.Trim <> '';
end;

procedure TDACMemo.LinesChanged(Sender: TObject);
begin
  if FUpdatingLines then
    Exit;
  FText := FLines.Text;
  ApplyTextToMemo;
end;

function TDACMemo.LabelFontSize: Integer;
begin
  Result := Round(ResolvedTokens.FieldLabelTextSize);
end;

procedure TDACMemo.InvalidateParentRegion(const ABounds: TRect);
var
  LBounds: TRect;
begin
  // A TSkPaintBox is a graphic child.  When this windowed host moves, VCL can
  // leave the former graphic surface visible until its parent next erases that
  // rectangle.  Explicitly invalidate both the old and new parent regions.
  if (Parent = nil) or not Parent.HandleAllocated or
    (csLoading in ComponentState) or (csDestroying in ComponentState) then
    Exit;
  LBounds := ABounds;
  InflateRect(LBounds, 1, 1);
  Winapi.Windows.InvalidateRect(Parent.Handle, @LBounds, True);
end;

function TDACMemo.ChromeTop: Integer;
begin
  Result := DACFieldChromeTop(HasLabel, ResolvedTokens);
end;

function TDACMemo.ChromeHeight: Integer;
begin
  Result := Max(0, Height - ChromeTop);
  if HasSupportText then
    Result := Max(0, Result - Round(ResolvedTokens.FieldSupportGap +
      ResolvedTokens.FieldSupportRowHeight));
end;

function TDACMemo.HasSupportText: Boolean;
begin
  Result := (FHelperText.Trim <> '') or (FErrorText.Trim <> '');
end;

procedure TDACMemo.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  if (Button = mbLeft) and Enabled and not FLoading and (FMemo <> nil) then
    FMemo.SetFocus;
end;

procedure TDACMemo.PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
  const ADest: TRectF; const AOpacity: Single);
var
  LBackground: TDACBackgroundStyle;
  LBorder: TDACBorderStyle;
  LBorderRect: TRectF;
  LRect: TRectF;
  LScale: Single;
  LTokens: TDACControlTokens;
  LTop: Single;
begin
  if (ACanvas = nil) or (ADest.Width <= 0) or (ADest.Height <= 0) then
    Exit;

  LScale := 1;
  LTop := ChromeTop;
  LBorderRect := FRenderer.SnapRect(TRectF.Create(0, LTop, ADest.Width,
    Min(ADest.Height, LTop + ChromeHeight)), LScale);
  LRect := LBorderRect;
  LTokens := ResolvedTokens;
  LRect.Inflate(-LTokens.MemoBorderInset / LScale,
    -LTokens.MemoBorderInset / LScale);

  ACanvas.Clear(LTokens.MemoChromeBackground);

  LBackground.Color := LTokens.MemoBackground;
  if not Enabled or FLoading then
    LBackground.Color := LTokens.MemoDisabledBackground
  else if FMemo.ReadOnly then
    LBackground.Color := LTokens.MemoReadOnlyBackground;
  LBackground.Radius := FCornerRadius;
  LBackground.Alpha := LTokens.MemoBackgroundAlpha;
  FBackgroundPainter.Draw(ACanvas, LRect, LBackground);

  LBorder.Color := BorderColor;
  LBorder.Radius := FCornerRadius;
  LBorder.Width := LTokens.MemoBorderWidth;
  if FMemo.Focused then
    LBorder.Width := LTokens.MemoFocusBorderWidth;
  LBorder.Alpha := BorderAlpha;
  FBorderPainter.Draw(ACanvas, LBorderRect, LBorder);
end;

procedure TDACMemo.Redraw;
begin
  { Native labels are designer-visible TLabel controls. Their token-backed
    layout must be refreshed even while the embedded memo HWND is deliberately
    detached in design-time. }
  if FFieldText <> nil then
    FFieldText.Update(FLabelText, FHelperText, FErrorText, '', FRequired,
      ResolvedFieldState, Width, ChromeTop, ChromeHeight, ResolvedTokens);
  if not CanUpdateChildren then
  begin
    if csDesigning in ComponentState then
    begin
      if FPaintBox <> nil then
        FPaintBox.Redraw;
      Invalidate;
    end;
    Exit;
  end;
  UpdatePaintBoxBounds;
  if FPaintBox <> nil then
  begin
    FPaintBox.Invalidate;
    if not (csDesigning in ComponentState) and
      not (csDestroying in ComponentState) and (Parent <> nil) and
      HandleAllocated and Parent.HandleAllocated then
      FPaintBox.Redraw;
  end;
  if HandleAllocated then
    Invalidate;
end;

procedure TDACMemo.Resize;
begin
  inherited;
  UpdatePaintBoxBounds;
  UpdateZOrder;
  UpdateChildBounds;
  Redraw;
end;

function TDACMemo.Pixels(const AValue: Integer): Integer;
begin
  Result := AValue;
  if (AValue > 0) and (Result < 1) then
    Result := 1;
end;

function TDACMemo.ResolvedTokens: TDACControlTokens;
begin
  Result := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls;
end;

function TDACMemo.ResolvedFieldState: TDACResolvedFieldState;
begin
  Result := TDACFieldStateResolver.Resolve(Enabled, FLoading, FReadOnly,
    (FMemo <> nil) and FMemo.Focused, FMouseInside, GetText <> '',
    TDACFieldValidation(Ord(FStatus)));
end;

procedure TDACMemo.SetCornerRadius(const AValue: Integer);
begin
  if FCornerRadius = AValue then
    Exit;
  FCornerRadius := Max(0, AValue);
  Redraw;
end;

procedure TDACMemo.SetErrorText(const AValue: string);
begin
  if FErrorText = AValue then
    Exit;
  FErrorText := AValue;
  UpdateChildBounds;
  Redraw;
end;

procedure TDACMemo.SetFocus;
begin
  if FLoading or not Enabled then
    Exit;
  if (FMemo <> nil) and FMemo.CanFocus then
    FMemo.SetFocus;
end;

procedure TDACMemo.SetHelperText(const AValue: string);
begin
  if FHelperText = AValue then
    Exit;
  FHelperText := AValue;
  UpdateChildBounds;
  Redraw;
end;

procedure TDACMemo.SetLabelText(const AValue: string);
var
  LHadLabel: Boolean;
begin
  if FLabelText = AValue then
    Exit;

  LHadLabel := HasLabel;
  FLabelText := AValue;
  if (not LHadLabel) and HasLabel and
    (Height <= Pixels(Round(ResolvedTokens.MemoDefaultHeight))) then
    Height := Pixels(Round(ResolvedTokens.MemoLabeledMinimumHeight));
  UpdateChildBounds;
  Redraw;
end;

procedure TDACMemo.SetLines(const AValue: TStrings);
begin
  FLines.Assign(AValue);
end;

procedure TDACMemo.SetLoading(const AValue: Boolean);
begin
  if FLoading = AValue then
    Exit;
  FLoading := AValue;
  if FLoading then
  begin
    DACFieldBeginLoadingTabPolicy(Self, FTabStopBeforeLoading,
      FLoadingTabStopCaptured);
    DACFieldRelinquishFocus(Self, FMemo);
  end;
  UpdateMemoStyle;
  if not FLoading then
    DACFieldEndLoadingTabPolicy(Self, FTabStopBeforeLoading,
      FLoadingTabStopCaptured);
  Redraw;
end;

procedure TDACMemo.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
var
  LChanged: Boolean;
  LPreviousBounds: TRect;
begin
  LPreviousBounds := BoundsRect;
  LChanged := (LPreviousBounds.Left <> ALeft) or (LPreviousBounds.Top <> ATop) or
    (LPreviousBounds.Width <> AWidth) or (LPreviousBounds.Height <> AHeight);
  if LChanged and HandleAllocated then
  begin
    Perform(WM_SETREDRAW, 0, 0);
    SetWindowPos(Handle, 0, ALeft, ATop, AWidth, AHeight,
      SWP_NOZORDER or SWP_NOACTIVATE or SWP_NOCOPYBITS or SWP_NOREDRAW);
  end;
  try
    inherited;
  finally
    if LChanged and HandleAllocated then
      Perform(WM_SETREDRAW, 1, 0);
  end;
  if LChanged then
  begin
    InvalidateParentRegion(LPreviousBounds);
    InvalidateParentRegion(BoundsRect);
    if HandleAllocated then
      RedrawWindow(Handle, nil, 0,
        RDW_INVALIDATE or RDW_ERASE or RDW_FRAME or RDW_ALLCHILDREN or RDW_UPDATENOW);
  end;
end;

procedure TDACMemo.SetReadOnly(const AValue: Boolean);
begin
  if FReadOnly = AValue then
    Exit;
  FReadOnly := AValue;
  UpdateMemoStyle;
  Redraw;
end;

procedure TDACMemo.SetBindingCanModify(const AValue: Boolean);
begin
  if FBindingCanModify = AValue then
    Exit;
  FBindingCanModify := AValue;
  UpdateMemoStyle;
  Redraw;
end;

procedure TDACMemo.SetScrollBars(const AValue: System.UITypes.TScrollStyle);
begin
  FMemo.ScrollBars := AValue;
end;

procedure TDACMemo.SetRequired(const AValue: Boolean);
begin
  if FRequired = AValue then
    Exit;
  FRequired := AValue;
  Redraw;
end;

procedure TDACMemo.SetStatus(const AValue: TDACEditStatus);
begin
  if FStatus = AValue then
    Exit;
  FStatus := AValue;
  Redraw;
end;

procedure TDACMemo.SetText(const AValue: string);
begin
  if FText = AValue then
    Exit;
  FUpdatingLines := True;
  try
    FLines.Text := AValue;
    FText := AValue;
  finally
    FUpdatingLines := False;
  end;
  ApplyTextToMemo;
  Redraw;
end;

procedure TDACMemo.SetThemeMode(const AValue: TDACThemeMode);
begin
  if FThemeMode = AValue then
  begin
    ThemeChanged(Self);
    Exit;
  end;
  FThemeMode := AValue;
  ThemeChanged(Self);
end;

procedure TDACMemo.SetWordWrap(const AValue: Boolean);
begin
  FMemo.WordWrap := AValue;
end;

procedure TDACMemo.ThemeChanged(Sender: TObject);
begin
  if (FThemeMode <> dtmInherit) and (Sender <> Self) then
    Exit;
  if ResolvedTokens.MemoBorderWidth <= 0 then
    Exit;
  UpdateMemoStyle;
  Redraw;
end;

procedure TDACMemo.UpdateChildBounds;
var
  LPadding: Integer;
  LTop: Integer;
begin
  if (FMemo = nil) or not CanUpdateChildren then
    Exit;

  LPadding := Pixels(Round(ResolvedTokens.MemoPadding));
  LTop := ChromeTop + LPadding;
  FMemo.SetBounds(LPadding, LTop,
    Max(0, Width - (LPadding * 2)),
    Max(0, ChromeTop + ChromeHeight - LTop - LPadding));
end;

procedure TDACMemo.UpdatePaintBoxBounds;
var
  LWidth: Integer;
  LHeight: Integer;
begin
  if (FPaintBox = nil) or not CanUpdateChildren then
    Exit;

  LWidth := Width;
  LHeight := Height;
  if HandleAllocated then
  begin
    LWidth := ClientWidth;
    LHeight := ClientHeight;
  end;

  if (FPaintBox.Left <> 0) or (FPaintBox.Top <> 0) or
    (FPaintBox.Width <> LWidth) or (FPaintBox.Height <> LHeight) then
    FPaintBox.SetBounds(0, 0, LWidth, LHeight);

end;

procedure TDACMemo.UpdateZOrder;
begin
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    Exit;
  if csDesigning in ComponentState then
    Exit;
  if not HandleAllocated then
    Exit;
  if (Parent = nil) or not Parent.HandleAllocated or not Showing then
    Exit;

  if FPaintBox <> nil then
    FPaintBox.SendToBack;
  if FMemo <> nil then
    FMemo.BringToFront;
end;

procedure TDACMemo.UpdateMemoStyle;
var
  LTokens: TDACControlTokens;
  LTextColor: TColor;
begin
  if (FMemo = nil) or not CanUpdateChildren then
    Exit;

  LTokens := ResolvedTokens;
  FMemo.Enabled := Enabled and not FLoading;
  FMemo.ReadOnly := FReadOnly or FLoading or not FBindingCanModify;
  FMemo.Color := MemoVclColor(LTokens.MemoBackground);
  LTextColor := MemoVclColor(LTokens.MemoText);
  if not Enabled or FLoading then
  begin
    FMemo.Color := MemoVclColor(LTokens.MemoDisabledBackground);
    LTextColor := MemoVclColor(LTokens.MemoDisabledText);
  end
  else if FReadOnly or not FBindingCanModify then
  begin
    FMemo.Color := MemoVclColor(LTokens.MemoReadOnlyBackground);
    LTextColor := MemoVclColor(LTokens.MemoReadOnlyText);
  end;
  FMemo.Font.Name := TDACComponentStyle.FontFamily;
  FMemo.Font.Size := Round(LTokens.MemoTextSize);
  FMemo.Font.Style := [];
  FMemo.Font.Color := LTextColor;
  Cursor := crIBeam;
  FPaintBox.Cursor := crIBeam;
  FMemo.Cursor := crIBeam;
  if not Enabled or FLoading then
  begin
    Cursor := crDefault;
    FPaintBox.Cursor := crDefault;
    FMemo.Cursor := crDefault;
  end;
end;

procedure TDACMemo.WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
begin
  inherited;
end;

procedure TDACMemo.WMSetFocus(var AMessage: TWMSetFocus);
begin
  inherited;
  if FLoading or not Enabled then
  begin
    DACFieldRelinquishFocus(Self, FMemo);
    Exit;
  end;
  // TWinControl.SetFocus is non-virtual. Dialog navigation first lands on
  // this host, therefore explicitly transfer it to the native memo child.
  if (FMemo <> nil) and FMemo.CanFocus then
    FMemo.SetFocus;
end;

initialization
  System.Classes.RegisterClass(TDACNativeMemo);

finalization
  System.Classes.UnregisterClass(TDACNativeMemo);

end.

