unit DAC.Components.Controls.Badges;

interface

uses
  System.Classes,
  System.Skia,
  System.Types,
  System.UITypes,
  Winapi.Messages,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.Skia,
  DAC.Components.DesignSystem.ControlTokens,
  DAC.Components.DesignSystem.IconAssets,
  DAC.Components.DesignSystem.Theme,
  DAC.Components.Controls.SystemText,
  DAC.Components.Skia.IconPainter,
  DAC.Components.Skia.Renderer;

type
  TDACBadgeKind = (
    mbkBadge,
    mbkChip,
    mbkTag,
    mbkPill
  );

  TDACBadgeAppearance = (
    mbaFilled,
    mbaSoft,
    mbaOutline
  );

  TDACBadgeStatus = (
    mbsNeutral,
    mbsSuccess,
    mbsWarning,
    mbsDanger,
    mbsInfo
  );

  TDACBadge = class(TCustomControl)
  private
    FAppearance: TDACBadgeAppearance;
    FCloseMouseInside: Boolean;
    FClosePressed: Boolean;
    FCornerRadius: Integer;
    FIconKind: TDACIconKind;
    FIconPainter: TDACSkiaIconPainter;
    FKind: TDACBadgeKind;
    FMouseInside: Boolean;
    FOnCloseClick: TNotifyEvent;
    FPaintBox: TSkPaintBox;
    FRenderer: TDACSkiaRenderer;
    FTextOverlay: TDACSystemTextOverlay;
    FShowClose: Boolean;
    FShowIcon: Boolean;
    FStatus: TDACBadgeStatus;
    FThemeMode: TDACThemeMode;
    procedure CMEnabledChanged(var AMessage: TMessage); message CM_ENABLEDCHANGED;
    procedure CMTextChanged(var AMessage: TMessage); message CM_TEXTCHANGED;
    function AccentColor: TAlphaColor;
    function BackgroundColor: TAlphaColor;
    function BorderAlpha: Byte;
    function BorderColor: TAlphaColor;
    function CloseRect: TRect;
    function ContentPadding: Integer;
    function FontSize: Single;
    function IconSize: Integer;
    procedure InvalidateBadge;
    function IsClosePoint(const X, Y: Integer): Boolean;
    procedure PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    procedure PaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxMouseEnter(Sender: TObject);
    procedure PaintBoxMouseLeave(Sender: TObject);
    procedure PaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    function ParentSurfaceColor: TAlphaColor;
    function Pixels(const AValue: Integer): Integer;
    procedure SetAppearance(const AValue: TDACBadgeAppearance);
    procedure SetCornerRadius(const AValue: Integer);
    procedure SetIconKind(const AValue: TDACIconKind);
    procedure SetKind(const AValue: TDACBadgeKind);
    procedure SetShowClose(const AValue: Boolean);
    procedure SetShowIcon(const AValue: Boolean);
    procedure SetStatus(const AValue: TDACBadgeStatus);
    procedure SetThemeMode(const AValue: TDACThemeMode);
    function TextColor: TAlphaColor;
    procedure UpdateCursor;
    procedure UpdatePaintBoxBounds;
    procedure ThemeChanged(Sender: TObject);
    procedure WMEraseBkgnd(var AMessage: TWMEraseBkgnd); message WM_ERASEBKGND;
  protected
    procedure CreateWnd; override;
    procedure Loaded; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ResolvedBackgroundColor: TAlphaColor;
    procedure Redraw;
  published
    property Align;
    property Anchors;
    property Appearance: TDACBadgeAppearance read FAppearance write SetAppearance default mbaSoft;
    property Caption;
    property Constraints;
    property CornerRadius: Integer read FCornerRadius write SetCornerRadius
      default DACBadgeDefaultCornerRadius;
    property Enabled;
    property Hint;
    property IconKind: TDACIconKind read FIconKind write SetIconKind default mikTag;
    property Kind: TDACBadgeKind read FKind write SetKind default mbkChip;
    property ParentShowHint;
    property PopupMenu;
    property ShowClose: Boolean read FShowClose write SetShowClose default False;
    property ShowHint;
    property ShowIcon: Boolean read FShowIcon write SetShowIcon default False;
    property Status: TDACBadgeStatus read FStatus write SetStatus default mbsSuccess;
    property TabOrder;
    property TabStop default False;
    property ThemeMode: TDACThemeMode read FThemeMode write SetThemeMode default dtmInherit;
    property Visible;
    property OnClick;
    property OnCloseClick: TNotifyEvent read FOnCloseClick write FOnCloseClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
  end;

implementation

uses
  System.Math,
  DAC.Components.DesignSystem.ColorTokens,
  DAC.Components.DesignSystem.Fonts,
  DAC.Components.DesignSystem.ComponentStyle;

constructor TDACBadge.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque, csClickEvents, csCaptureMouse];
  Width := Round(TDACComponentStyle.Resolve(dtmInherit).Tokens.Controls.BadgeDefaultWidth);
  Height := Round(TDACComponentStyle.Resolve(dtmInherit).Tokens.Controls.BadgeDefaultHeight);
  TabStop := False;
  ParentColor := False;
  StyleElements := [];
  Cursor := crDefault;
  Caption := 'Ativo';

  FAppearance := mbaSoft;
  FCornerRadius := Round(TDACComponentStyle.Resolve(dtmInherit).Tokens.Controls.BadgeRadius);
  FIconKind := mikTag;
  FKind := mbkChip;
  FShowClose := False;
  FShowIcon := False;
  FStatus := mbsSuccess;
  FThemeMode := dtmInherit;

  FRenderer := TDACSkiaRenderer.Create;
  FIconPainter := TDACSkiaIconPainter.Create(FRenderer);

  FPaintBox := TSkPaintBox.Create(Self);
  FPaintBox.Parent := Self;
  FPaintBox.SetSubComponent(True);
  FPaintBox.StyleElements := [];
  FPaintBox.OnDraw := PaintBoxDraw;
  FPaintBox.OnMouseDown := PaintBoxMouseDown;
  FPaintBox.OnMouseEnter := PaintBoxMouseEnter;
  FPaintBox.OnMouseLeave := PaintBoxMouseLeave;
  FPaintBox.OnMouseMove := PaintBoxMouseMove;
  FPaintBox.OnMouseUp := PaintBoxMouseUp;
  FTextOverlay := TDACSystemTextOverlay.Create(Self);
  FTextOverlay.Parent := Self;
  FTextOverlay.SetSubComponent(True);
  FTextOverlay.Align := alClient;
  TDACThemeManager.RegisterListener(Self, ThemeChanged);

  UpdatePaintBoxBounds;
end;

destructor TDACBadge.Destroy;
begin
  TDACThemeManager.UnregisterListener(Self);
  FTextOverlay.Free;
  FPaintBox.Free;
  FIconPainter.Free;
  FRenderer.Free;
  inherited;
end;

function TDACBadge.AccentColor: TAlphaColor;
var
  LTokens: TDACControlTokens;
begin
  LTokens := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls;
  case FStatus of
    mbsWarning: Result := LTokens.ProgressWarning;
    mbsDanger: Result := LTokens.ProgressDanger;
    mbsInfo: Result := LTokens.ProgressInfo;
    mbsNeutral: Result := LTokens.ProgressNeutral;
  else
    Result := LTokens.Success;
  end;
end;

function TDACBadge.BackgroundColor: TAlphaColor;
var
  LAccent: TAlphaColor;
begin
  LAccent := AccentColor;
  case FAppearance of
    mbaFilled:
      Result := LAccent;
    mbaOutline:
      Result := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls.BadgeOutlineBackground;
  else
    Result := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls.BadgeSoftBackground;
  end;
end;

function TDACBadge.BorderAlpha: Byte;
begin
  case FAppearance of
    mbaFilled:
      Result := 0;
    mbaOutline:
      Result := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls.BadgeOutlineBorderAlpha;
  else
    Result := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls.BadgeBorderAlpha;
  end;
  if not Enabled then
    Result := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls.BadgeDisabledAlpha;
end;

function TDACBadge.BorderColor: TAlphaColor;
begin
  if FAppearance = mbaFilled then
    Exit(AccentColor);
  if FMouseInside and Enabled then
    Exit(AccentColor);
  Result := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls.BadgeBorder;
end;
function TDACBadge.CloseRect: TRect;
var
  LSize: Integer;
begin
  LSize := Pixels(IconSize);
  Result := Rect(Width - Pixels(ContentPadding) - LSize,
    (Height - LSize) div 2,
    Width - Pixels(ContentPadding),
    (Height + LSize) div 2);
end;

procedure TDACBadge.CMEnabledChanged(var AMessage: TMessage);
begin
  inherited;
  UpdateCursor;
  InvalidateBadge;
end;

procedure TDACBadge.CMTextChanged(var AMessage: TMessage);
begin
  inherited;
  InvalidateBadge;
end;

function TDACBadge.ContentPadding: Integer;
begin
  case FKind of
    mbkBadge:
      Result := Round(TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls.BadgePadding);
    mbkPill:
      Result := Round(TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls.BadgePillPadding);
  else
    Result := Round(TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls.BadgePadding);
  end;
end;

procedure TDACBadge.CreateWnd;
begin
  inherited;
  UpdatePaintBoxBounds;
  InvalidateBadge;
end;

function TDACBadge.FontSize: Single;
begin
  case FKind of
    mbkBadge:
      Result := TDACComponentStyle.TabTextSize;
    mbkPill:
      Result := TDACComponentStyle.TabTextSize;
  else
    Result := TDACComponentStyle.TabTextSize;
  end;
end;

function TDACBadge.IconSize: Integer;
begin
  case FKind of
    mbkBadge:
      Result := Round(TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls.BadgeIconSize);
    mbkPill:
      Result := Round(TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls.BadgePillIconSize);
  else
    Result := Round(TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls.BadgeIconSize);
  end;
end;

procedure TDACBadge.InvalidateBadge;
begin
  UpdatePaintBoxBounds;
  if (FPaintBox = nil) or (csDestroying in ComponentState) then
    Exit;
  if csDesigning in ComponentState then
  begin
    if Parent <> nil then
      FPaintBox.Redraw;
    Invalidate;
    Exit;
  end;
  if (Parent <> nil) and HandleAllocated and Parent.HandleAllocated then
    FPaintBox.Redraw;
end;

procedure TDACBadge.Loaded;
begin
  inherited;
  UpdatePaintBoxBounds;
  InvalidateBadge;
end;

function TDACBadge.IsClosePoint(const X, Y: Integer): Boolean;
var
  LRect: TRect;
begin
  if not FShowClose then
  begin
    Result := False;
    Exit;
  end;
  LRect := CloseRect;
  Result := (X >= LRect.Left) and (X < LRect.Right) and
    (Y >= LRect.Top) and (Y < LRect.Bottom);
end;

procedure TDACBadge.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  if Button = mbLeft then
  begin
    FClosePressed := IsClosePoint(X, Y);
    InvalidateBadge;
  end;
end;

procedure TDACBadge.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LWasInside: Boolean;
begin
  inherited;
  LWasInside := FCloseMouseInside;
  FCloseMouseInside := IsClosePoint(X, Y);
  if LWasInside <> FCloseMouseInside then
  begin
    UpdateCursor;
    InvalidateBadge;
  end;
end;

procedure TDACBadge.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  LClickClose: Boolean;
begin
  inherited;
  LClickClose := FClosePressed and IsClosePoint(X, Y);
  FClosePressed := False;
  InvalidateBadge;
  if LClickClose and Assigned(FOnCloseClick) then
    FOnCloseClick(Self);
end;

procedure TDACBadge.PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
  const ADest: TRectF; const AOpacity: Single);
var
  LAlpha: Byte;
  LBackground: TAlphaColor;
  LBorder: TAlphaColor;
  LCloseControlRect: TRect;
  LCloseRect: TRectF;
  LIconRect: TRectF;
  LIconStyle: TDACIconStyle;
  LPadding: Single;
  LRadius: Single;
  LRect: TRectF;
  LScale: Single;
  LTextColor: TAlphaColor;
  LTextLeft: Single;
  LTextRight: Single;
  LTokens: TDACControlTokens;
begin
  if ACanvas = nil then
    Exit;

  FRenderer.BeginNativeText(FTextOverlay);
  try

  LTokens := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls;
  LScale := LTokens.BorderWidth;
  ACanvas.Clear(ParentSurfaceColor);
  LRect := FRenderer.SnapRect(TRectF.Create(0, 0, ADest.Width, ADest.Height), LScale);
  LRect.Inflate(-(LTokens.BorderWidth / 2) / LScale,
    -(LTokens.BorderWidth / 2) / LScale);
  LRadius := Pixels(FCornerRadius);
  if FKind = mbkPill then
    LRadius := LRect.Height / 2;

  LAlpha := LTokens.AlphaOpaque;
  if not Enabled then
    LAlpha := LTokens.BadgeDisabledAlpha;

  LBackground := BackgroundColor;
  LBorder := BorderColor;
  FRenderer.FillRoundRect(ACanvas, LRect, LBackground, LRadius, LAlpha);
  if BorderAlpha > 0 then
    FRenderer.StrokeRoundRect(ACanvas, LRect, LBorder, LRadius,
      Pixels(Round(LTokens.BorderWidth)), BorderAlpha);

  LPadding := Pixels(ContentPadding);
  LTextLeft := LRect.Left + LPadding;
  LTextRight := LRect.Right - LPadding;
  LTextColor := TextColor;

  if FShowIcon and (FIconKind <> mikNone) then
  begin
    LIconRect := TRectF.Create(LTextLeft, (LRect.Height - Pixels(IconSize)) / 2,
      LTextLeft + Pixels(IconSize), (LRect.Height + Pixels(IconSize)) / 2);
    LIconStyle.Color := LTextColor;
    LIconStyle.Alpha := LAlpha;
    FIconPainter.Draw(ACanvas, LIconRect, FIconKind, LIconStyle);
    LTextLeft := LIconRect.Right + Pixels(Round(LTokens.BadgeIconGap));
  end;

  if FShowClose then
    LTextRight := CloseRect.Left - Pixels(Round(LTokens.BadgeIconGap));

  FRenderer.TextCentered(ACanvas, Caption, TDACComponentStyle.FontFamily,
    TRectF.Create(LTextLeft, LRect.Top, LTextRight, LRect.Bottom), FontSize,
    LTextColor, True, Max(0, LTextRight - LTextLeft));

  if FShowClose then
  begin
    LCloseControlRect := CloseRect;
    LCloseRect := TRectF.Create(LCloseControlRect.Left, LCloseControlRect.Top,
      LCloseControlRect.Right, LCloseControlRect.Bottom);
    if FCloseMouseInside and Enabled then
      FRenderer.FillRoundRect(ACanvas, LCloseRect, LTextColor, LCloseRect.Height / 2,
        LTokens.BadgeCloseHoverAlpha);
    LCloseRect.Inflate(-Pixels(Round(LTokens.BadgeCloseInset)),
      -Pixels(Round(LTokens.BadgeCloseInset)));
    LIconStyle.Color := LTextColor;
    LIconStyle.Alpha := LAlpha;
    FIconPainter.Draw(ACanvas, LCloseRect, mikClose, LIconStyle);
  end;
  finally
    FRenderer.EndNativeText;
  end;
end;

procedure TDACBadge.PaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  MouseDown(Button, Shift, X, Y);
end;

procedure TDACBadge.PaintBoxMouseEnter(Sender: TObject);
begin
  FMouseInside := True;
  InvalidateBadge;
end;

procedure TDACBadge.PaintBoxMouseLeave(Sender: TObject);
begin
  FMouseInside := False;
  FCloseMouseInside := False;
  FClosePressed := False;
  UpdateCursor;
  InvalidateBadge;
end;

procedure TDACBadge.PaintBoxMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  MouseMove(Shift, X, Y);
end;

procedure TDACBadge.PaintBoxMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  MouseUp(Button, Shift, X, Y);
end;

function TDACBadge.ParentSurfaceColor: TAlphaColor;
begin
  Result := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls.PopupBackground;
end;

function TDACBadge.ResolvedBackgroundColor: TAlphaColor;
begin
  Result := BackgroundColor;
end;

procedure TDACBadge.Redraw;
begin
  InvalidateBadge;
end;

procedure TDACBadge.Resize;
begin
  inherited;
  UpdatePaintBoxBounds;
  InvalidateBadge;
end;

function TDACBadge.Pixels(const AValue: Integer): Integer;
begin
  if AValue <= 0 then
    Exit(0);
  Result := Max(1, Round(AValue * 1));
end;

procedure TDACBadge.SetAppearance(const AValue: TDACBadgeAppearance);
begin
  if FAppearance = AValue then
    Exit;
  FAppearance := AValue;
  InvalidateBadge;
end;

procedure TDACBadge.SetCornerRadius(const AValue: Integer);
begin
  if FCornerRadius = AValue then
    Exit;
  FCornerRadius := Max(0, AValue);
  InvalidateBadge;
end;

procedure TDACBadge.SetIconKind(const AValue: TDACIconKind);
begin
  if FIconKind = AValue then
    Exit;
  FIconKind := AValue;
  InvalidateBadge;
end;

procedure TDACBadge.SetKind(const AValue: TDACBadgeKind);
begin
  if FKind = AValue then
    Exit;
  FKind := AValue;
  InvalidateBadge;
end;

procedure TDACBadge.SetShowClose(const AValue: Boolean);
begin
  if FShowClose = AValue then
    Exit;
  FShowClose := AValue;
  UpdateCursor;
  InvalidateBadge;
end;

procedure TDACBadge.SetShowIcon(const AValue: Boolean);
begin
  if FShowIcon = AValue then
    Exit;
  FShowIcon := AValue;
  InvalidateBadge;
end;

procedure TDACBadge.SetStatus(const AValue: TDACBadgeStatus);
begin
  if FStatus = AValue then
    Exit;
  FStatus := AValue;
  InvalidateBadge;
end;

procedure TDACBadge.SetThemeMode(const AValue: TDACThemeMode);
begin
  if FThemeMode = AValue then
    Exit;
  FThemeMode := AValue;
  ThemeChanged(Self);
end;

function TDACBadge.TextColor: TAlphaColor;
begin
  if FAppearance = mbaFilled then
    Exit(TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls.FeedbackText);

  Result := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls.BadgeText;
end;

procedure TDACBadge.ThemeChanged(Sender: TObject);
begin
  InvalidateBadge;
end;

procedure TDACBadge.UpdateCursor;
var
  LCursor: TCursor;
begin
  if Enabled and FShowClose and FCloseMouseInside then
    LCursor := crHandPoint
  else
    LCursor := crDefault;

  Cursor := LCursor;
  if FPaintBox <> nil then
    FPaintBox.Cursor := LCursor;
end;

procedure TDACBadge.UpdatePaintBoxBounds;
var
  LHeight: Integer;
  LWidth: Integer;
begin
  if (FPaintBox = nil) or (csLoading in ComponentState) or
    (csDestroying in ComponentState) then
    Exit;

  LWidth := Width;
  LHeight := Height;
  if not (csDesigning in ComponentState) and HandleAllocated then
  begin
    LWidth := ClientWidth;
    LHeight := ClientHeight;
  end;

  if (FPaintBox.Left <> 0) or (FPaintBox.Top <> 0) or
    (FPaintBox.Width <> LWidth) or (FPaintBox.Height <> LHeight) then
    FPaintBox.SetBounds(0, 0, LWidth, LHeight);
end;

procedure TDACBadge.WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
begin
  AMessage.Result := 1;
end;

end.

