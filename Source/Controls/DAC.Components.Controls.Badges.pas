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
  DAC.Components.DesignSystem.IconAssets,
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
    FShowClose: Boolean;
    FShowIcon: Boolean;
    FStatus: TDACBadgeStatus;
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
    function ScaleFactor: Single;
    function ScaleMetric(const AValue: Integer): Integer;
    procedure SetAppearance(const AValue: TDACBadgeAppearance);
    procedure SetCornerRadius(const AValue: Integer);
    procedure SetIconKind(const AValue: TDACIconKind);
    procedure SetKind(const AValue: TDACBadgeKind);
    procedure SetShowClose(const AValue: Boolean);
    procedure SetShowIcon(const AValue: Boolean);
    procedure SetStatus(const AValue: TDACBadgeStatus);
    function TextColor: TAlphaColor;
    procedure UpdateCursor;
    procedure UpdatePaintBoxBounds;
    procedure WMEraseBkgnd(var AMessage: TWMEraseBkgnd); message WM_ERASEBKGND;
  protected
    procedure ChangeScale(M, D: Integer); override;
    procedure CreateWnd; override;
    procedure Loaded; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Redraw;
  published
    property Align;
    property Anchors;
    property Appearance: TDACBadgeAppearance read FAppearance write SetAppearance default mbaSoft;
    property Caption;
    property Constraints;
    property CornerRadius: Integer read FCornerRadius write SetCornerRadius default 10;
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
  DAC.Components.DesignSystem.Fonts;

constructor TDACBadge.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque, csClickEvents, csCaptureMouse];
  Width := 92;
  Height := 28;
  TabStop := False;
  ParentColor := False;
  StyleElements := [];
  Cursor := crDefault;
  Caption := 'Ativo';

  FAppearance := mbaSoft;
  FCornerRadius := 10;
  FIconKind := mikTag;
  FKind := mbkChip;
  FShowClose := False;
  FShowIcon := False;
  FStatus := mbsSuccess;

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

  UpdatePaintBoxBounds;
end;

destructor TDACBadge.Destroy;
begin
  FPaintBox.Free;
  FIconPainter.Free;
  FRenderer.Free;
  inherited;
end;

function TDACBadge.AccentColor: TAlphaColor;
begin
  case FStatus of
    mbsWarning:
      Result := TDACComponentColors.Warning;
    mbsDanger:
      Result := TDACComponentColors.Danger;
    mbsInfo:
      Result := TDACComponentColors.Alpha(43, 125, 233);
    mbsNeutral:
      Result := TDACComponentColors.Alpha(71, 85, 105);
  else
    Result := TDACComponentColors.Primary;
  end;
end;

function TDACBadge.BackgroundColor: TAlphaColor;
var
  LAccent: TAlphaColor;
  LSurface: TAlphaColor;
begin
  LAccent := AccentColor;
  LSurface := ParentSurfaceColor;
  case FAppearance of
    mbaFilled:
      Result := LAccent;
    mbaOutline:
      Result := TDACComponentColors.ControlBackgroundForSurface(LSurface);
  else
    if TDACComponentColors.IsDarkSurface(LSurface) then
      Exit(TDACComponentColors.Alpha(18, 36, 24));
    case FStatus of
      mbsWarning:
        Result := TDACComponentColors.Alpha(255, 246, 214);
      mbsDanger:
        Result := TDACComponentColors.Alpha(255, 232, 229);
      mbsInfo:
        Result := TDACComponentColors.Alpha(229, 241, 255);
      mbsNeutral:
        Result := TDACComponentColors.Alpha(241, 245, 249);
    else
      Result := TDACComponentColors.Alpha(230, 246, 227);
    end;
  end;
end;

function TDACBadge.BorderAlpha: Byte;
begin
  case FAppearance of
    mbaFilled:
      Result := 0;
    mbaOutline:
      Result := 230;
  else
    Result := 170;
  end;
  if not Enabled then
    Result := 110;
end;

function TDACBadge.BorderColor: TAlphaColor;
begin
  if FAppearance = mbaFilled then
    Exit(AccentColor);
  if FMouseInside and Enabled then
    Exit(AccentColor);
  Result := TDACComponentColors.ControlBorderForSurface(ParentSurfaceColor);
end;

procedure TDACBadge.ChangeScale(M, D: Integer);
begin
  inherited;
  UpdatePaintBoxBounds;
  InvalidateBadge;
end;

function TDACBadge.CloseRect: TRect;
var
  LSize: Integer;
begin
  LSize := ScaleMetric(IconSize);
  Result := Rect(Width - ScaleMetric(ContentPadding) - LSize,
    (Height - LSize) div 2,
    Width - ScaleMetric(ContentPadding),
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
      Result := 10;
    mbkPill:
      Result := 16;
  else
    Result := 12;
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
      Result := 12;
    mbkPill:
      Result := 12;
  else
    Result := 12;
  end;
end;

function TDACBadge.IconSize: Integer;
begin
  case FKind of
    mbkBadge:
      Result := 12;
    mbkPill:
      Result := 14;
  else
    Result := 13;
  end;
end;

procedure TDACBadge.InvalidateBadge;
begin
  UpdatePaintBoxBounds;
  if (FPaintBox <> nil) and HandleAllocated then
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
begin
  if ACanvas = nil then
    Exit;

  LScale := ScaleFactor;
  ACanvas.Clear(ParentSurfaceColor);
  LRect := FRenderer.SnapRect(TRectF.Create(0, 0, ADest.Width, ADest.Height), LScale);
  LRect.Inflate(-0.5 / LScale, -0.5 / LScale);
  LRadius := ScaleMetric(FCornerRadius);
  if FKind = mbkPill then
    LRadius := LRect.Height / 2;

  LAlpha := 255;
  if not Enabled then
    LAlpha := 120;

  LBackground := BackgroundColor;
  LBorder := BorderColor;
  FRenderer.FillRoundRect(ACanvas, LRect, LBackground, LRadius, LAlpha);
  if BorderAlpha > 0 then
    FRenderer.StrokeRoundRect(ACanvas, LRect, LBorder, LRadius, ScaleMetric(1), BorderAlpha);

  LPadding := ScaleMetric(ContentPadding);
  LTextLeft := LRect.Left + LPadding;
  LTextRight := LRect.Right - LPadding;
  LTextColor := TextColor;

  if FShowIcon and (FIconKind <> mikNone) then
  begin
    LIconRect := TRectF.Create(LTextLeft, (LRect.Height - ScaleMetric(IconSize)) / 2,
      LTextLeft + ScaleMetric(IconSize), (LRect.Height + ScaleMetric(IconSize)) / 2);
    LIconStyle.Color := LTextColor;
    LIconStyle.Alpha := LAlpha;
    FIconPainter.Draw(ACanvas, LIconRect, FIconKind, LIconStyle);
    LTextLeft := LIconRect.Right + ScaleMetric(6);
  end;

  if FShowClose then
    LTextRight := CloseRect.Left - ScaleMetric(6);

  FRenderer.TextCentered(ACanvas, Caption, TDACComponentFontInstaller.FontFamily,
    TRectF.Create(LTextLeft, LRect.Top, LTextRight, LRect.Bottom), FontSize,
    LTextColor, True, Max(0, LTextRight - LTextLeft));

  if FShowClose then
  begin
    LCloseControlRect := CloseRect;
    LCloseRect := TRectF.Create(LCloseControlRect.Left, LCloseControlRect.Top,
      LCloseControlRect.Right, LCloseControlRect.Bottom);
    if FCloseMouseInside and Enabled then
      FRenderer.FillRoundRect(ACanvas, LCloseRect, LTextColor, LCloseRect.Height / 2, 24);
    LCloseRect.Inflate(-ScaleMetric(2), -ScaleMetric(2));
    LIconStyle.Color := LTextColor;
    LIconStyle.Alpha := LAlpha;
    FIconPainter.Draw(ACanvas, LCloseRect, mikClose, LIconStyle);
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
  Result := TDACComponentColors.ResolveParentSurface(Self);
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

function TDACBadge.ScaleFactor: Single;
begin
  Result := 1;
  if FPaintBox <> nil then
    Result := FPaintBox.ScaleFactor;
end;

function TDACBadge.ScaleMetric(const AValue: Integer): Integer;
begin
  if AValue <= 0 then
    Exit(0);
  Result := Max(1, Round(AValue * ScaleFactor));
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

function TDACBadge.TextColor: TAlphaColor;
begin
  if FAppearance = mbaFilled then
    Exit(TDACComponentColors.White);

  case FStatus of
    mbsWarning:
      Result := TDACComponentColors.WarningDark;
    mbsDanger:
      Result := TDACComponentColors.DangerDark;
    mbsInfo:
      Result := TDACComponentColors.Alpha(28, 94, 168);
    mbsNeutral:
      Result := TDACComponentColors.Alpha(51, 65, 85);
  else
    Result := TDACComponentColors.Primary;
  end;
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
  if FPaintBox = nil then
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

procedure TDACBadge.WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
begin
  AMessage.Result := 1;
end;

end.

