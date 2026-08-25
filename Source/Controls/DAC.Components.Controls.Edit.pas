unit DAC.Components.Controls.Edit;

interface

uses
  System.Classes,
  System.Skia,
  System.Types,
  System.UITypes,
  Winapi.Messages,
  System.SysUtils,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Graphics,
  Vcl.Mask,
  Vcl.Skia,
  Vcl.StdCtrls,
  DAC.Components.Controls.FieldSupport,
  DAC.Components.DesignSystem.Fonts,
  DAC.Components.DesignSystem.ComponentStyle,
  DAC.Components.DesignSystem.ControlTokens,
  DAC.Components.DesignSystem.OpacityTokens,
  DAC.Components.DesignSystem.Theme,
  DAC.Components.DesignSystem.IconAssets,
  DAC.Components.Skia.BackgroundPainter,
  DAC.Components.Skia.BorderPainter,
  DAC.Components.Skia.IconPainter,
  DAC.Components.Skia.Renderer;

type
  TDACEditStatus = (
    mesNormal,
    mesSuccess,
    mesWarning,
    mesDanger
  );

  TDACEditKind = (
    mekText,
    mekMasked,
    mekPassword,
    mekSearch,
    mekNumeric,
    mekDate,
    mekTime
  );

  TDACInputSize = (
    misSmall,
    misMedium,
    misLarge
  );

  TDACInputVariant = (
    mivOutlined,
    mivUnderlined,
    mivCompact
  );


type
  TDACEdit = class(TCustomControl)
  private
    FBackgroundPainter: TDACSkiaBackgroundPainter;
    FBindingCanModify: Boolean;
    FBorderPainter: TDACSkiaBorderPainter;
    FCornerRadius: Integer;
    FEdit: TMaskEdit;
    FEditKind: TDACEditKind;
    FEditMask: string;
    FCounterText: string;
    FDesignValueLabel: TLabel;
    FErrorText: string;
    FFieldText: TDACFieldTextSupport;
    FHelperText: string;
    FIconPainter: TDACSkiaIconPainter;
    FNativeLabel: TLabel;
    FInputSize: TDACInputSize;
    FLabelText: string;
    FMouseInside: Boolean;
    FOnChange: TNotifyEvent;
    FPaintBox: TSkPaintBox;
    FPlaceholder: string;
    FRenderer: TDACSkiaRenderer;
    FRequired: Boolean;
    FLoading: Boolean;
    FLoadingTabStopCaptured: Boolean;
    FReadOnly: Boolean;
    FRightContentReserve: Integer;
    FStatus: TDACEditStatus;
    FThemeMode: TDACThemeMode;
    FTabStopBeforeLoading: Boolean;
    FVariant: TDACInputVariant;
    function BorderAlpha: Byte;
    function BorderColor: TAlphaColor;
    function ControlHeight: Integer;
    procedure CMEnabledChanged(var AMessage: TMessage); message CM_ENABLEDCHANGED;
    procedure CMParentColorChanged(var AMessage: TMessage); message CM_PARENTCOLORCHANGED;
    procedure CMParentFontChanged(var AMessage: TMessage); message CM_PARENTFONTCHANGED;
    procedure DoEditChange(Sender: TObject);
    procedure DoEditEnter(Sender: TObject);
    procedure DoEditExit(Sender: TObject);
    procedure DoMouseEnter(Sender: TObject);
    procedure DoMouseLeave(Sender: TObject);
    function GetCharCase: TEditCharCase;
    function GetEffectivePasswordChar: Char;
    function GetMaxLength: Integer;
    function GetPasswordChar: Char;
    function GetReadOnly: Boolean;
    function GetText: string;
    function EffectiveEditMask: string;
    function RightIconKind: TDACIconKind;
    function HasRightIcon: Boolean;
    function HasLabel: Boolean;
    function HasSupportText: Boolean;
    function ResolvedFieldState: TDACResolvedFieldState;
    function InputFontSize: Integer;
    function ResolvedTokens: TDACControlTokens;
    function ChromeTop: Integer;
    function ParentSurfaceColor: TAlphaColor;
    procedure InvalidateChrome;
    procedure InvalidateParentRegion(const ABounds: TRect);
    procedure PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    function Pixels(const AValue: Integer): Integer;
    procedure SetCharCase(const AValue: TEditCharCase);
    procedure SetCornerRadius(const AValue: Integer);
    procedure SetCounterText(const AValue: string);
    procedure SetEditKind(const AValue: TDACEditKind);
    procedure SetEditMask(const AValue: string);
    procedure SetErrorText(const AValue: string);
    procedure SetHelperText(const AValue: string);
    procedure SetInputSize(const AValue: TDACInputSize);
    procedure SetLabelText(const AValue: string);
    procedure SetLoading(const AValue: Boolean);
    procedure SetMaxLength(const AValue: Integer);
    procedure SetPasswordChar(const AValue: Char);
    procedure SetPlaceholder(const AValue: string);
    procedure SetReadOnly(const AValue: Boolean);
    procedure SetRequired(const AValue: Boolean);
    procedure SetRightContentReserve(const AValue: Integer);
    procedure SetStatus(const AValue: TDACEditStatus);
    procedure SetText(const AValue: string);
    procedure SetThemeMode(const AValue: TDACThemeMode);
    procedure SetVariant(const AValue: TDACInputVariant);
    procedure ThemeChanged(Sender: TObject);
    procedure UpdateChildBounds;
    procedure UpdateEditStyle;
    procedure UpdateDesignValuePreview;
    procedure UpdateNativeLabel;
    procedure UpdatePaintBoxBounds;
    procedure UpdateZOrder;
    procedure WMSetFocus(var AMessage: TWMSetFocus); message WM_SETFOCUS;
    procedure WMEraseBkgnd(var AMessage: TWMEraseBkgnd); message WM_ERASEBKGND;
  protected
    procedure CreateWnd; override;
    procedure Loaded; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Resize; override;
    procedure SetBindingCanModify(const AValue: Boolean);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ResolvedChromeColor: TAlphaColor;
    function ResolvedInputSurfaceColor: TAlphaColor;
    function InputChromeTop: Integer;
    function InputChromeHeight: Integer;
    function LabelFontSize: Integer;
    procedure Redraw;
    procedure SetFocus; reintroduce;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
    property EditControl: TMaskEdit read FEdit;
    property NativeLabel: TLabel read FNativeLabel;
    property RightContentReserve: Integer read FRightContentReserve
      write SetRightContentReserve;
  published
    property Align;
    property Anchors;
    property CharCase: TEditCharCase read GetCharCase write SetCharCase default ecNormal;
    property Constraints;
    property CornerRadius: Integer read FCornerRadius write SetCornerRadius
      default DACEditDefaultCornerRadius;
    property CounterText: string read FCounterText write SetCounterText;
    property EditKind: TDACEditKind read FEditKind write SetEditKind default mekText;
    property EditMask: string read FEditMask write SetEditMask;
    property Enabled;
    property ErrorText: string read FErrorText write SetErrorText;
    property Font;
    property HelperText: string read FHelperText write SetHelperText;
    property InputSize: TDACInputSize read FInputSize write SetInputSize default misSmall;
    property LabelText: string read FLabelText write SetLabelText;
    property Loading: Boolean read FLoading write SetLoading default False;
    property MaxLength: Integer read GetMaxLength write SetMaxLength default 0;
    property ParentFont;
    property ParentShowHint;
    property PasswordChar: Char read GetPasswordChar write SetPasswordChar default #0;
    property Placeholder: string read FPlaceholder write SetPlaceholder;
    property PopupMenu;
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly default False;
    property Required: Boolean read FRequired write SetRequired default False;
    property ShowHint;
    property Status: TDACEditStatus read FStatus write SetStatus default mesNormal;
    property TabOrder;
    property TabStop default True;
    property Text: string read GetText write SetText;
    property ThemeMode: TDACThemeMode read FThemeMode write SetThemeMode default dtmInherit;
    property Variant: TDACInputVariant read FVariant write SetVariant default mivOutlined;
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

implementation

uses
  System.Math,
  Winapi.Windows,
  DAC.Components.DesignSystem.ColorTokens;

function EditVclColor(const AColor: TAlphaColor): TColor;
begin
  Result := TColor(((AColor and $00FF0000) shr 16) or
    (AColor and $0000FF00) or ((AColor and $000000FF) shl 16));
end;

constructor TDACEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  { Only the Skia child paints the input chrome. The wrapper itself must stay
    transparent so label/support rows inherit the actual parent surface. }
  ControlStyle := (ControlStyle + [csClickEvents, csCaptureMouse]) - [csOpaque];
  FThemeMode := dtmInherit;
  FRightContentReserve := 0;
  Width := Round(ResolvedTokens.InputDefaultWidth);
  Height := Round(ResolvedTokens.InputDefaultHeight);
  TabStop := True;
  ParentColor := True;
  FBindingCanModify := True;
  StyleElements := [];
  Cursor := crIBeam;
  FCornerRadius := Round(ResolvedTokens.InputRadius);
  FEditKind := mekText;
  FInputSize := misSmall;
  FStatus := mesNormal;
  FVariant := mivOutlined;
  TDACThemeManager.RegisterListener(Self, ThemeChanged);

  FRenderer := TDACSkiaRenderer.Create;
  FBackgroundPainter := TDACSkiaBackgroundPainter.Create(FRenderer);
  FBorderPainter := TDACSkiaBorderPainter.Create(FRenderer);
  FIconPainter := TDACSkiaIconPainter.Create(FRenderer);

  FPaintBox := TSkPaintBox.Create(Self);
  FPaintBox.Parent := Self;
  FPaintBox.SetSubComponent(True);
  FPaintBox.StyleElements := [];
  FPaintBox.Cursor := crIBeam;
  FPaintBox.OnDraw := PaintBoxDraw;
  FPaintBox.OnMouseEnter := DoMouseEnter;
  FPaintBox.OnMouseLeave := DoMouseLeave;

  FEdit := TMaskEdit.Create(Self);
  FEdit.Parent := Self;
  FEdit.SetSubComponent(True);
  FEdit.BorderStyle := bsNone;
  FEdit.StyleElements := [];
  FEdit.ParentFont := False;
  FEdit.OnChange := DoEditChange;
  FEdit.OnEnter := DoEditEnter;
  FEdit.OnExit := DoEditExit;
  FEdit.OnMouseEnter := DoMouseEnter;
  FEdit.OnMouseLeave := DoMouseLeave;

  { This is only the non-windowed designer presenter. Runtime values remain
    in the real TMaskEdit, so caret, IME and accessibility are untouched. }
  FDesignValueLabel := TLabel.Create(Self);
  FDesignValueLabel.Parent := Self;
  FDesignValueLabel.SetSubComponent(True);
  FDesignValueLabel.AutoSize := False;
  FDesignValueLabel.Transparent := True;
  FDesignValueLabel.ParentFont := False;
  FDesignValueLabel.Visible := False;

  FFieldText := TDACFieldTextSupport.Create(Self, Self);
  FNativeLabel := FFieldText.CaptionLabel;
  FFieldText.SetFocusControl(FEdit);

  UpdateEditStyle;
  Resize;
end;

destructor TDACEdit.Destroy;
begin
  TDACThemeManager.UnregisterListener(Self);
  FDesignValueLabel.Free;
  FEdit.Free;
  FFieldText.Free;
  FPaintBox.Free;
  FIconPainter.Free;
  FBorderPainter.Free;
  FBackgroundPainter.Free;
  FRenderer.Free;
  inherited;
end;

function TDACEdit.BorderAlpha: Byte;
var
  LTokens: TDACControlTokens;
begin
  LTokens := ResolvedTokens;
  if FVariant = mivUnderlined then
  begin
    if FEdit.Focused or (FStatus <> mesNormal) then
      Exit(LTokens.InputUnderlinedBorderAlphaFocus);
    if FMouseInside then
      Exit(LTokens.InputUnderlinedBorderAlphaHover);
    Exit(LTokens.InputUnderlinedBorderAlphaNormal);
  end;

  if not Enabled or FLoading then
    Result := LTokens.InputBorderAlphaDisabled
  else if FEdit.Focused then
    Result := LTokens.InputBorderAlphaFocus
  else if FStatus <> mesNormal then
    Result := LTokens.InputBorderAlphaStatus
  else if FMouseInside then
    Result := LTokens.InputBorderAlphaHover
  else
    Result := LTokens.InputBorderAlphaNormal;
end;

function TDACEdit.BorderColor: TAlphaColor;
var
  LTokens: TDACControlTokens;
begin
  LTokens := ResolvedTokens;
  case FStatus of
    mesSuccess:
      Result := LTokens.InputSuccessBorder;
    mesWarning:
      Result := LTokens.InputWarningBorder;
    mesDanger:
      Result := LTokens.InputDangerBorder;
  else
    if FEdit.Focused then
      Result := LTokens.InputFocus
    else if FMouseInside then
      Result := LTokens.InputBorderHover
    else
      Result := LTokens.InputBorder;
  end;
end;

function TDACEdit.ControlHeight: Integer;
var
  LTokens: TDACControlTokens;
begin
  LTokens := ResolvedTokens;
  if FVariant = mivCompact then
    Exit(Round(LTokens.InputCompactChromeHeight));
  case FInputSize of
    misSmall: Result := Round(LTokens.InputSmallChromeHeight);
    misLarge: Result := Round(LTokens.InputLargeChromeHeight);
  else
    Result := Round(LTokens.InputMediumChromeHeight);
  end;
end;

procedure TDACEdit.CMEnabledChanged(var AMessage: TMessage);
begin
  inherited;
  if not Enabled then
    DACFieldRelinquishFocus(Self, FEdit);
  UpdateEditStyle;
  Redraw;
end;

procedure TDACEdit.CMParentColorChanged(var AMessage: TMessage);
begin
  inherited;
  UpdateEditStyle;
  Redraw;
end;

procedure TDACEdit.CMParentFontChanged(var AMessage: TMessage);
begin
  inherited;
  UpdateEditStyle;
  Redraw;
end;

procedure TDACEdit.CreateWnd;
begin
  inherited;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    Exit;
  if csDesigning in ComponentState then
  begin
    UpdatePaintBoxBounds;
    UpdateChildBounds;
    Exit;
  end;
  if (Parent = nil) or not HandleAllocated or
    not Parent.HandleAllocated then
    Exit;
  UpdateZOrder;
  UpdateChildBounds;
  UpdateEditStyle;
  Redraw;
end;

procedure TDACEdit.DoEditChange(Sender: TObject);
begin
  Redraw;
  if Assigned(OnChange) then
    OnChange(Self);
end;

procedure TDACEdit.DoEditEnter(Sender: TObject);
begin
  Redraw;
  if Assigned(OnEnter) then
    OnEnter(Self);
end;

procedure TDACEdit.DoEditExit(Sender: TObject);
begin
  Redraw;
  if Assigned(OnExit) then
    OnExit(Self);
end;

procedure TDACEdit.DoMouseEnter(Sender: TObject);
begin
  if FMouseInside then
    Exit;
  FMouseInside := True;
  Redraw;
  if Assigned(OnMouseEnter) then
    OnMouseEnter(Self);
end;

procedure TDACEdit.DoMouseLeave(Sender: TObject);
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

procedure TDACEdit.Loaded;
begin
  inherited;
  if FLoading then
  begin
    DACFieldBeginLoadingTabPolicy(Self, FTabStopBeforeLoading,
      FLoadingTabStopCaptured, True);
    DACFieldRelinquishFocus(Self, FEdit);
  end;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    Exit;
  if csDesigning in ComponentState then
  begin
    UpdatePaintBoxBounds;
    UpdateChildBounds;
    Exit;
  end;
  if (Parent = nil) or not HandleAllocated or
    not Parent.HandleAllocated then
    Exit;
  UpdatePaintBoxBounds;
  UpdateZOrder;
  UpdateChildBounds;
  UpdateEditStyle;
  Redraw;
end;

function TDACEdit.GetCharCase: TEditCharCase;
begin
  Result := FEdit.CharCase;
end;

function TDACEdit.GetEffectivePasswordChar: Char;
begin
  Result := #0;
  if FEditKind = mekPassword then
  begin
    Result := FEdit.PasswordChar;
    if Result = #0 then
      Result := '*';
  end;
end;

function TDACEdit.EffectiveEditMask: string;
begin
  Result := FEditMask;
  if Result <> '' then
    Exit;

  case FEditKind of
    mekNumeric:
      Result := '999.999.999,99;0;_';
    mekDate:
      Result := '!99/99/9999;1;_';
    mekTime:
      Result := '!99:99;1;_';
  end;
end;

function TDACEdit.GetMaxLength: Integer;
begin
  Result := FEdit.MaxLength;
end;

function TDACEdit.GetPasswordChar: Char;
begin
  Result := FEdit.PasswordChar;
end;

function TDACEdit.GetReadOnly: Boolean;
begin
  Result := FReadOnly;
end;

function TDACEdit.GetText: string;
begin
  Result := FEdit.Text;
end;

function TDACEdit.HasRightIcon: Boolean;
begin
  Result := RightIconKind <> mikNone;
end;

function TDACEdit.RightIconKind: TDACIconKind;
begin
  if FLoading then
    Exit(mikRefresh);
  case FEditKind of
    mekPassword:
      Result := mikEye;
    mekSearch:
      Result := mikSearch;
    mekDate:
      Result := mikCalendar;
    mekTime:
      Result := mikClock;
  else
    Result := mikNone;
  end;
end;

procedure TDACEdit.InvalidateChrome;
begin
  UpdateChildBounds;
  Redraw;
  Invalidate;
end;

procedure TDACEdit.InvalidateParentRegion(const ABounds: TRect);
var
  LBounds: TRect;
begin
  // The Skia paintbox is a graphic child. When its windowed host moves, VCL
  // needs both regions invalidated or an old chrome/label frame can persist.
  if (Parent = nil) or not Parent.HandleAllocated or
    (csLoading in ComponentState) or (csDestroying in ComponentState) then
    Exit;
  LBounds := ABounds;
  InflateRect(LBounds, 1, 1);
  Winapi.Windows.InvalidateRect(Parent.Handle, @LBounds, True);
end;

procedure TDACEdit.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  if (Button = mbLeft) and Enabled and not FLoading and (FEdit <> nil) then
    FEdit.SetFocus;
end;

procedure TDACEdit.PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
  const ADest: TRectF; const AOpacity: Single);
var
  LBackground: TDACBackgroundStyle;
  LBorder: TDACBorderStyle;
  LIconRect: TRectF;
  LIconStyle: TDACIconStyle;
  LBorderRect: TRectF;
  LControlBottom: Single;
  LRect: TRectF;
  LSurface: TAlphaColor;
  LTokens: TDACControlTokens;
  LTop: Single;
begin
  if (ACanvas = nil) or (ADest.Width <= 0) or (ADest.Height <= 0) then
    Exit;

  LTop := 0;
  LControlBottom := Min(ADest.Height, ControlHeight);
  LTokens := ResolvedTokens;
  LBorderRect := FRenderer.SnapRect(TRectF.Create(0, LTop, ADest.Width,
    LControlBottom), 1);
  LRect := LBorderRect;
  LRect.Inflate(-LTokens.InputBorderInset, -LTokens.InputBorderInset);

  LSurface := ResolvedInputSurfaceColor;
  { The paint box owns only the chrome row.  Its transparent corners must
    reveal the real VCL parent surface, not a rectangular copy of the input
    background. }
  ACanvas.Clear(ParentSurfaceColor);

  LBorder.Color := BorderColor;
  LBorder.Radius := FCornerRadius;
  LBorder.Width := LTokens.InputBorderWidth;
  if FEdit.Focused then
    LBorder.Width := LTokens.InputFocusBorderWidth;
  LBorder.Alpha := BorderAlpha;
  if csDesigning in ComponentState then
  begin
    { A normal light-theme stroke intentionally has low contrast at runtime.
      The Delphi form canvas is white as well, so use the token hover stroke
      only for the non-interactive design preview to make the chrome legible. }
    LBorder.Color := LTokens.InputBorderHover;
    LBorder.Alpha := DACOpacityOpaque;
  end;
  if FVariant = mivUnderlined then
  begin
    FRenderer.StrokeRoundRect(ACanvas,
      TRectF.Create(LRect.Left, LRect.Bottom - Pixels(Round(LTokens.InputUnderlineHeight)), LRect.Right,
        LRect.Bottom), LBorder.Color, 0, LBorder.Width, LBorder.Alpha);
  end
  else
  begin
    LBackground.Color := LSurface;
    LBackground.Radius := FCornerRadius;
    LBackground.Alpha := LTokens.InputBackgroundAlpha;
    FBackgroundPainter.Draw(ACanvas, LRect, LBackground);
    FBorderPainter.Draw(ACanvas, LBorderRect, LBorder);
  end;

  if HasRightIcon then
  begin
    LIconRect := TRectF.Create(ADest.Width - Pixels(Round(LTokens.InputIconColumnWidth)),
      LRect.Top + (LRect.Height - Pixels(Round(LTokens.InputIconSize))) / 2,
      ADest.Width - Pixels(Round(LTokens.InputIconRightInset)),
      LRect.Top + (LRect.Height + Pixels(Round(LTokens.InputIconSize))) / 2);
    LIconStyle.Color := LTokens.InputIcon;
    LIconStyle.Alpha := LTokens.InputIconAlpha;
    if not Enabled or FLoading then
      LIconStyle.Color := LTokens.InputIconDisabled;

    FIconPainter.Draw(ACanvas, LIconRect, RightIconKind, LIconStyle);
  end;

end;

function TDACEdit.HasLabel: Boolean;
begin
  Result := FLabelText.Trim <> '';
end;

function TDACEdit.HasSupportText: Boolean;
begin
  Result := (FHelperText.Trim <> '') or (FErrorText.Trim <> '') or
    (FCounterText.Trim <> '');
end;

function TDACEdit.InputFontSize: Integer;
var
  LTokens: TDACControlTokens;
begin
  LTokens := ResolvedTokens;
  case FInputSize of
    misSmall:
      Result := Round(LTokens.InputSmallTextSize);
    misLarge:
      Result := Round(LTokens.InputLargeTextSize);
  else
    Result := Round(LTokens.InputMediumTextSize);
  end;
end;

function TDACEdit.ChromeTop: Integer;
begin
  Result := DACFieldChromeTop(HasLabel, ResolvedTokens);
end;

function TDACEdit.InputChromeHeight: Integer;
begin
  Result := ControlHeight;
end;

function TDACEdit.InputChromeTop: Integer;
begin
  Result := ChromeTop;
end;

function TDACEdit.LabelFontSize: Integer;
begin
  Result := Round(ResolvedTokens.FieldLabelTextSize);
end;

function TDACEdit.ResolvedFieldState: TDACResolvedFieldState;
begin
  Result := TDACFieldStateResolver.Resolve(Enabled, FLoading, FReadOnly,
    (FEdit <> nil) and FEdit.Focused, FMouseInside,
    (FEdit <> nil) and (FEdit.Text <> ''),
    TDACFieldValidation(Ord(FStatus)));
end;

function TDACEdit.ResolvedChromeColor: TAlphaColor;
begin
  Result := ResolvedTokens.InputChromeBackground;
end;

function TDACEdit.ResolvedInputSurfaceColor: TAlphaColor;
var
  LTokens: TDACControlTokens;
begin
  LTokens := ResolvedTokens;
  if not Enabled or FLoading then
    Exit(LTokens.InputDisabledBackground);
  if FVariant = mivUnderlined then
    Exit(LTokens.InputUnderlinedBackground);
  Result := LTokens.InputBackground;
end;

function TDACEdit.ParentSurfaceColor: TAlphaColor;
begin
  Result := TDACComponentColors.ResolveParentSurface(Self);
end;

procedure TDACEdit.Redraw;
begin
  if csDesigning in ComponentState then
    UpdateChildBounds;
  UpdateNativeLabel;
  UpdatePaintBoxBounds;
  if (FPaintBox <> nil) and (csDesigning in ComponentState) then
  begin
    { Invalidate preserves TSkPaintBox's raster cache. A theme inherited from
      a parent container therefore needs Redraw to discard the old light/dark
      chrome while keeping the native text preview untouched. }
    FPaintBox.Redraw;
    Invalidate;
    Exit;
  end;
  if (FPaintBox <> nil) and not (csDesigning in ComponentState) and
    not (csDestroying in ComponentState) and (Parent <> nil) and
    HandleAllocated and Parent.HandleAllocated then
    FPaintBox.Redraw;
end;

procedure TDACEdit.Resize;
begin
  inherited;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    Exit;
  if csDesigning in ComponentState then
  begin
    UpdatePaintBoxBounds;
    UpdateChildBounds;
    Exit;
  end;
  if (Parent = nil) or not HandleAllocated or
    not Parent.HandleAllocated then
    Exit;
  UpdatePaintBoxBounds;
  UpdateZOrder;
  UpdateChildBounds;
  Redraw;
end;

function TDACEdit.Pixels(const AValue: Integer): Integer;
begin
  Result := AValue;
end;

procedure TDACEdit.SetCharCase(const AValue: TEditCharCase);
begin
  FEdit.CharCase := AValue;
end;

procedure TDACEdit.SetCornerRadius(const AValue: Integer);
begin
  if FCornerRadius = AValue then
    Exit;
  FCornerRadius := Max(0, AValue);
  InvalidateChrome;
end;

procedure TDACEdit.SetCounterText(const AValue: string);
var
  LHadSupport: Boolean;
begin
  if FCounterText = AValue then
    Exit;

  LHadSupport := HasSupportText;
  FCounterText := AValue;
  if (not LHadSupport) and HasSupportText and (Height <= ChromeTop + ControlHeight) then
    Height := DACFieldTotalHeight(HasLabel, HasSupportText, ControlHeight,
      ResolvedTokens);
  InvalidateChrome;
end;

procedure TDACEdit.SetEditKind(const AValue: TDACEditKind);
begin
  if FEditKind = AValue then
    Exit;
  FEditKind := AValue;
  UpdateEditStyle;
  InvalidateChrome;
end;

procedure TDACEdit.SetEditMask(const AValue: string);
begin
  if FEditMask = AValue then
    Exit;
  FEditMask := AValue;
  UpdateEditStyle;
end;

procedure TDACEdit.SetErrorText(const AValue: string);
var
  LHadSupport: Boolean;
begin
  if FErrorText = AValue then
    Exit;
  LHadSupport := HasSupportText;
  FErrorText := AValue;
  if (not LHadSupport) and HasSupportText and
    (Height <= ChromeTop + ControlHeight) then
    Height := DACFieldTotalHeight(HasLabel, True, ControlHeight,
      ResolvedTokens);
  InvalidateChrome;
end;

procedure TDACEdit.SetHelperText(const AValue: string);
var
  LHadSupport: Boolean;
begin
  if FHelperText = AValue then
    Exit;

  LHadSupport := HasSupportText;
  FHelperText := AValue;
  if (not LHadSupport) and HasSupportText and (Height <= ChromeTop + ControlHeight) then
    Height := DACFieldTotalHeight(HasLabel, HasSupportText, ControlHeight,
      ResolvedTokens);
  InvalidateChrome;
end;

procedure TDACEdit.SetInputSize(const AValue: TDACInputSize);
begin
  { Single-line DAC inputs have one compact density. Keep the published enum
    readable by old DFMs, but normalize any legacy medium/large value to the
    Small contract. }
  if FInputSize = misSmall then
    Exit;

  FInputSize := misSmall;
  if not HasLabel and not HasSupportText then
    Height := ControlHeight
  else
    Height := DACFieldTotalHeight(HasLabel, HasSupportText, ControlHeight,
      ResolvedTokens);
  UpdateEditStyle;
  InvalidateChrome;
end;

procedure TDACEdit.SetLabelText(const AValue: string);
var
  LHadLabel: Boolean;
begin
  if FLabelText = AValue then
    Exit;

  LHadLabel := HasLabel;
  FLabelText := AValue;
  if (not LHadLabel) and HasLabel and (Height <= ControlHeight) then
    Height := DACFieldTotalHeight(HasLabel, HasSupportText, ControlHeight,
      ResolvedTokens);
  InvalidateChrome;
end;

procedure TDACEdit.SetFocus;
begin
  if FLoading or not Enabled then
    Exit;
  if (FEdit <> nil) and FEdit.CanFocus then
    FEdit.SetFocus;
end;

procedure TDACEdit.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
var
  LCanLayout: Boolean;
  LChanged: Boolean;
  LMinimumHeight: Integer;
  LPreviousBounds: TRect;
begin
  { A field with native caption/support must never accept a geometry smaller
    than those rows.  DFM streaming can set Height after LabelText/HelperText,
    so enforce the final layout contract here rather than clipping the text. }
  LMinimumHeight := DACFieldTotalHeight(HasLabel, HasSupportText,
    ControlHeight, ResolvedTokens);
  AHeight := Max(AHeight, LMinimumHeight);
  LPreviousBounds := BoundsRect;
  LChanged := (LPreviousBounds.Left <> ALeft) or (LPreviousBounds.Top <> ATop) or
    (LPreviousBounds.Width <> AWidth) or (LPreviousBounds.Height <> AHeight);
  LCanLayout := not (csLoading in ComponentState) and
    not (csDestroying in ComponentState) and not (csDesigning in ComponentState) and
    (Parent <> nil) and HandleAllocated and Parent.HandleAllocated;
  if LChanged and LCanLayout then
  begin
    Perform(WM_SETREDRAW, 0, 0);
    SetWindowPos(Handle, 0, ALeft, ATop, AWidth, AHeight,
      SWP_NOZORDER or SWP_NOACTIVATE or SWP_NOCOPYBITS or SWP_NOREDRAW);
  end;
  try
    inherited;
  finally
    if LChanged and LCanLayout then
      Perform(WM_SETREDRAW, 1, 0);
  end;
  if LChanged and LCanLayout then
  begin
    InvalidateParentRegion(LPreviousBounds);
    InvalidateParentRegion(BoundsRect);
    if HandleAllocated then
      RedrawWindow(Handle, nil, 0,
        RDW_INVALIDATE or RDW_ERASE or RDW_FRAME or RDW_ALLCHILDREN or RDW_UPDATENOW);
  end;
  if LChanged and (csDesigning in ComponentState) then
  begin
    UpdatePaintBoxBounds;
    UpdateChildBounds;
    Invalidate;
  end;
end;

procedure TDACEdit.SetMaxLength(const AValue: Integer);
begin
  FEdit.MaxLength := Max(0, AValue);
end;

procedure TDACEdit.SetLoading(const AValue: Boolean);
begin
  if FLoading = AValue then
    Exit;
  FLoading := AValue;
  if FLoading then
  begin
    DACFieldBeginLoadingTabPolicy(Self, FTabStopBeforeLoading,
      FLoadingTabStopCaptured);
    DACFieldRelinquishFocus(Self, FEdit);
  end;
  UpdateEditStyle;
  if not FLoading then
    DACFieldEndLoadingTabPolicy(Self, FTabStopBeforeLoading,
      FLoadingTabStopCaptured);
  InvalidateChrome;
end;

procedure TDACEdit.SetPasswordChar(const AValue: Char);
begin
  FEdit.PasswordChar := AValue;
end;

procedure TDACEdit.SetPlaceholder(const AValue: string);
begin
  if FPlaceholder = AValue then
    Exit;
  FPlaceholder := AValue;
  FEdit.TextHint := FPlaceholder;
end;

procedure TDACEdit.SetReadOnly(const AValue: Boolean);
begin
  if FReadOnly = AValue then
    Exit;
  FReadOnly := AValue;
  UpdateEditStyle;
  InvalidateChrome;
end;

procedure TDACEdit.SetBindingCanModify(const AValue: Boolean);
begin
  if FBindingCanModify = AValue then
    Exit;
  FBindingCanModify := AValue;
  UpdateEditStyle;
  InvalidateChrome;
end;

procedure TDACEdit.SetRequired(const AValue: Boolean);
begin
  if FRequired = AValue then
    Exit;
  FRequired := AValue;
  InvalidateChrome;
end;

procedure TDACEdit.SetRightContentReserve(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(0, AValue);
  if FRightContentReserve = LValue then
    Exit;
  FRightContentReserve := LValue;
  UpdateChildBounds;
  Invalidate;
end;

procedure TDACEdit.SetStatus(const AValue: TDACEditStatus);
begin
  if FStatus = AValue then
    Exit;
  FStatus := AValue;
  InvalidateChrome;
end;

procedure TDACEdit.SetText(const AValue: string);
begin
  FEdit.Text := AValue;
  UpdateNativeLabel;
end;

procedure TDACEdit.SetThemeMode(const AValue: TDACThemeMode);
begin
  if FThemeMode = AValue then
  begin
    // A designer can reapply an identical streamed value after rebuilding the
    // parent surface.  Re-resolve the inherited palette in that case too.
    ThemeChanged(Self);
    Exit;
  end;
  FThemeMode := AValue;
  ThemeChanged(Self);
end;

procedure TDACEdit.ThemeChanged(Sender: TObject);
begin
  UpdateEditStyle;
  Redraw;
end;

procedure TDACEdit.SetVariant(const AValue: TDACInputVariant);
begin
  if FVariant = AValue then
    Exit;

  FVariant := AValue;
  UpdateEditStyle;
  InvalidateChrome;
end;

function TDACEdit.ResolvedTokens: TDACControlTokens;
begin
  Result := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls;
end;

procedure TDACEdit.UpdateChildBounds;
var
  LHorizontalPadding: Integer;
  LInputHeight: Integer;
  LRightPadding: Integer;
  LTextHeight: Integer;
  LTop: Integer;
  LTokens: TDACControlTokens;
begin
  if (FEdit = nil) or (csLoading in ComponentState) or
    (csDestroying in ComponentState) then
    Exit;

  if csDesigning in ComponentState then
  begin
    { The transient windowed editor must not remain a child of the streamed
      component preview. In Delphi 10.2 a hidden TMaskEdit may still receive a
      design-surface paint with its old HWND bounds. Detaching it eliminates
      that stale dark rectangle; runtime construction attaches a fresh native
      editor before it needs focus, text, caret or IME. }
    FEdit.Visible := False;
    if FEdit.Parent <> nil then
      FEdit.Parent := nil;
    UpdateDesignValuePreview;
    UpdateNativeLabel;
    Exit;
  end;

  if (Parent = nil) or not HandleAllocated or not Parent.HandleAllocated then
    Exit;

  if FEdit.Parent <> Self then
    FEdit.Parent := Self;
  FEdit.Visible := True;
  if FDesignValueLabel <> nil then
    FDesignValueLabel.Visible := False;

  LTokens := ResolvedTokens;
  LHorizontalPadding := Pixels(Round(LTokens.InputNativeHorizontalPadding));
  LRightPadding := LHorizontalPadding;
  if HasRightIcon then
    LRightPadding := Pixels(Round(LTokens.InputNativeRightReserveWithIcon));
  Inc(LRightPadding, FRightContentReserve);
  LInputHeight := Min(ControlHeight, Max(0, Height - ChromeTop));
  case FInputSize of
    misSmall: LTextHeight := Pixels(Round(LTokens.InputSmallEditorHeight));
    misLarge: LTextHeight := Pixels(Round(LTokens.InputLargeEditorHeight));
  else
    LTextHeight := Pixels(Round(LTokens.InputMediumEditorHeight));
  end;
  LTextHeight := Min(LInputHeight, LTextHeight);
  { The native editor remains inside the chrome's safe inset so it never
    covers the Skia rounded border. The optical offset is tokenized and can be
    tuned without changing the composition or native input behavior. }
  LTop := ChromeTop + Max(0, (LInputHeight - LTextHeight) div 2) +
    Pixels(Round(LTokens.InputNativeVerticalOffset));
  LTop := Min(ChromeTop + Max(0, LInputHeight - LTextHeight), LTop);
  FEdit.SetBounds(LHorizontalPadding, LTop,
    Max(0, Width - LHorizontalPadding - LRightPadding), LTextHeight);
  UpdateNativeLabel;
end;

procedure TDACEdit.UpdateNativeLabel;
begin
  if FFieldText = nil then
    Exit;
  FFieldText.Update(FLabelText, FHelperText, FErrorText, FCounterText,
    FRequired, ResolvedFieldState, Width, ChromeTop, ControlHeight,
    ResolvedTokens);
end;

procedure TDACEdit.UpdateDesignValuePreview;
var
  LHorizontalPadding: Integer;
  LInputHeight: Integer;
  LRightPadding: Integer;
  LText: string;
  LTextHeight: Integer;
  LTokens: TDACControlTokens;
  LTop: Integer;
begin
  if FDesignValueLabel = nil then
    Exit;
  if not (csDesigning in ComponentState) then
  begin
    FDesignValueLabel.Visible := False;
    Exit;
  end;

  LTokens := ResolvedTokens;
  LText := FEdit.Text;
  if LText = '' then
    LText := FPlaceholder;
  FDesignValueLabel.Caption := LText;
  FDesignValueLabel.Font.Name := TDACComponentStyle.FontFamily;
  FDesignValueLabel.Font.Size := InputFontSize;
  FDesignValueLabel.Font.Style := [];
  if FEdit.Text = '' then
    FDesignValueLabel.Font.Color := EditVclColor(LTokens.InputPlaceholder)
  else
    FDesignValueLabel.Font.Color := EditVclColor(LTokens.InputText);
  FDesignValueLabel.Visible := LText <> '';

  LHorizontalPadding := Pixels(Round(LTokens.InputNativeHorizontalPadding));
  LRightPadding := LHorizontalPadding;
  if HasRightIcon then
    LRightPadding := Pixels(Round(LTokens.InputNativeRightReserveWithIcon));
  Inc(LRightPadding, FRightContentReserve);
  LInputHeight := Min(ControlHeight, Max(0, Height - ChromeTop));
  case FInputSize of
    misSmall: LTextHeight := Pixels(Round(LTokens.InputSmallEditorHeight));
    misLarge: LTextHeight := Pixels(Round(LTokens.InputLargeEditorHeight));
  else
    LTextHeight := Pixels(Round(LTokens.InputMediumEditorHeight));
  end;
  LTextHeight := Min(LInputHeight, LTextHeight);
  LTop := ChromeTop + Max(0, (LInputHeight - LTextHeight) div 2) +
    Pixels(Round(LTokens.InputNativeVerticalOffset));
  LTop := Min(ChromeTop + Max(0, LInputHeight - LTextHeight), LTop);
  FDesignValueLabel.SetBounds(LHorizontalPadding, LTop,
    Max(0, Width - LHorizontalPadding - LRightPadding), LTextHeight);
end;

procedure TDACEdit.UpdatePaintBoxBounds;
var
  LWidth: Integer;
  LHeight: Integer;
  LTop: Integer;
begin
  if (FPaintBox = nil) or (csLoading in ComponentState) or
    (csDestroying in ComponentState) then
    Exit;

  { Width/Height are safe while Delphi streams a component into the form
    designer. ClientRect and a HWND are deliberately not required here. }
  LWidth := Width;
  LHeight := Height;
  if not (csDesigning in ComponentState) and HandleAllocated then
  begin
    LWidth := ClientWidth;
    LHeight := ClientHeight;
  end;

  LTop := ChromeTop;
  { Label and support rows are native transparent controls.  Keeping the
    Skia child within the chrome prevents a field-sized white rectangle from
    being cleared behind those rows at runtime. }
  LHeight := Min(ControlHeight, Max(0, LHeight - LTop));
  if (FPaintBox.Left <> 0) or (FPaintBox.Top <> LTop) or
    (FPaintBox.Width <> LWidth) or (FPaintBox.Height <> LHeight) then
    FPaintBox.SetBounds(0, LTop, LWidth, LHeight);

end;

procedure TDACEdit.UpdateZOrder;
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
  if FEdit <> nil then
    FEdit.BringToFront;
end;

procedure TDACEdit.UpdateEditStyle;
var
  LTokens: TDACControlTokens;
  LTextColor: TColor;
begin
  if FEdit = nil then
    Exit;

  LTokens := ResolvedTokens;
  FEdit.Enabled := Enabled and not FLoading;
  FEdit.ReadOnly := FReadOnly or FLoading or not FBindingCanModify;
  FEdit.Color := EditVclColor(ResolvedInputSurfaceColor);
  FEdit.Font.Name := TDACComponentStyle.FontFamily;
  FEdit.Font.Size := InputFontSize;
  FEdit.Font.Style := [];
  LTextColor := EditVclColor(LTokens.InputText);
  if not Enabled or FLoading then
    LTextColor := EditVclColor(LTokens.InputDisabledText);
  FEdit.Font.Color := LTextColor;
  UpdateNativeLabel;
  FEdit.TextHint := FPlaceholder;
  if FEditKind in [mekMasked, mekNumeric, mekDate, mekTime] then
    FEdit.EditMask := EffectiveEditMask
  else
    FEdit.EditMask := '';
  FEdit.PasswordChar := GetEffectivePasswordChar;
  Cursor := crIBeam;
  FPaintBox.Cursor := crIBeam;
  FEdit.Cursor := crIBeam;
  if not Enabled or FLoading then
  begin
    Cursor := crDefault;
    FPaintBox.Cursor := crDefault;
    FEdit.Cursor := crDefault;
  end;
end;

procedure TDACEdit.WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
begin
  inherited;
end;

procedure TDACEdit.WMSetFocus(var AMessage: TWMSetFocus);
begin
  inherited;
  if FLoading or not Enabled then
  begin
    DACFieldRelinquishFocus(Self, FEdit);
    Exit;
  end;
  if (FEdit <> nil) and not FEdit.Focused and FEdit.CanFocus then
    FEdit.SetFocus;
end;

end.

