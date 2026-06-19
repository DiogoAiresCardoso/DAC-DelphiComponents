unit MaxxRural.Components.Controls.Badges;

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
  MaxxRural.Components.DesignSystem.IconAssets,
  MaxxRural.Components.Skia.IconPainter,
  MaxxRural.Components.Skia.Renderer;

type
  TMaxxRuralBadgeKind = (
    mbkBadge,
    mbkChip,
    mbkTag,
    mbkPill
  );

  TMaxxRuralBadgeAppearance = (
    mbaFilled,
    mbaSoft,
    mbaOutline
  );

  TMaxxRuralBadgeStatus = (
    mbsNeutral,
    mbsSuccess,
    mbsWarning,
    mbsDanger,
    mbsInfo
  );

  TMaxxRuralBadge = class(TCustomControl)
  private
    FAppearance: TMaxxRuralBadgeAppearance;
    FCloseMouseInside: Boolean;
    FClosePressed: Boolean;
    FCornerRadius: Integer;
    FIconKind: TMaxxRuralIconKind;
    FIconPainter: TMaxxRuralSkiaIconPainter;
    FKind: TMaxxRuralBadgeKind;
    FMouseInside: Boolean;
    FOnCloseClick: TNotifyEvent;
    FPaintBox: TSkPaintBox;
    FRenderer: TMaxxRuralSkiaRenderer;
    FShowClose: Boolean;
    FShowIcon: Boolean;
    FStatus: TMaxxRuralBadgeStatus;
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
    procedure SetAppearance(const AValue: TMaxxRuralBadgeAppearance);
    procedure SetCornerRadius(const AValue: Integer);
    procedure SetIconKind(const AValue: TMaxxRuralIconKind);
    procedure SetKind(const AValue: TMaxxRuralBadgeKind);
    procedure SetShowClose(const AValue: Boolean);
    procedure SetShowIcon(const AValue: Boolean);
    procedure SetStatus(const AValue: TMaxxRuralBadgeStatus);
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
    property Appearance: TMaxxRuralBadgeAppearance read FAppearance write SetAppearance default mbaSoft;
    property Caption;
    property Constraints;
    property CornerRadius: Integer read FCornerRadius write SetCornerRadius default 10;
    property Enabled;
    property Hint;
    property IconKind: TMaxxRuralIconKind read FIconKind write SetIconKind default mikTag;
    property Kind: TMaxxRuralBadgeKind read FKind write SetKind default mbkChip;
    property ParentShowHint;
    property PopupMenu;
    property ShowClose: Boolean read FShowClose write SetShowClose default False;
    property ShowHint;
    property ShowIcon: Boolean read FShowIcon write SetShowIcon default False;
    property Status: TMaxxRuralBadgeStatus read FStatus write SetStatus default mbsSuccess;
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
  MaxxRural.Components.DesignSystem.ColorTokens,
  MaxxRural.Components.DesignSystem.Fonts;

constructor TMaxxRuralBadge.Create(AOwner: TComponent);
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

  FRenderer := TMaxxRuralSkiaRenderer.Create;
  FIconPainter := TMaxxRuralSkiaIconPainter.Create(FRenderer);

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

destructor TMaxxRuralBadge.Destroy;
begin
  FPaintBox.Free;
  FIconPainter.Free;
  FRenderer.Free;
  inherited;
end;

function TMaxxRuralBadge.AccentColor: TAlphaColor;
begin
  case FStatus of
    mbsWarning:
      Result := TMaxxRuralComponentColors.Warning;
    mbsDanger:
      Result := TMaxxRuralComponentColors.Danger;
    mbsInfo:
      Result := TMaxxRuralComponentColors.Alpha(43, 125, 233);
    mbsNeutral:
      Result := TMaxxRuralComponentColors.Alpha(71, 85, 105);
  else
    Result := TMaxxRuralComponentColors.Primary;
  end;
end;

function TMaxxRuralBadge.BackgroundColor: TAlphaColor;
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
      Result := TMaxxRuralComponentColors.ControlBackgroundForSurface(LSurface);
  else
    if TMaxxRuralComponentColors.IsDarkSurface(LSurface) then
      Exit(TMaxxRuralComponentColors.Alpha(18, 36, 24));
    case FStatus of
      mbsWarning:
        Result := TMaxxRuralComponentColors.Alpha(255, 246, 214);
      mbsDanger:
        Result := TMaxxRuralComponentColors.Alpha(255, 232, 229);
      mbsInfo:
        Result := TMaxxRuralComponentColors.Alpha(229, 241, 255);
      mbsNeutral:
        Result := TMaxxRuralComponentColors.Alpha(241, 245, 249);
    else
      Result := TMaxxRuralComponentColors.Alpha(230, 246, 227);
    end;
  end;
end;

function TMaxxRuralBadge.BorderAlpha: Byte;
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

function TMaxxRuralBadge.BorderColor: TAlphaColor;
begin
  if FAppearance = mbaFilled then
    Exit(AccentColor);
  if FMouseInside and Enabled then
    Exit(AccentColor);
  Result := TMaxxRuralComponentColors.ControlBorderForSurface(ParentSurfaceColor);
end;

procedure TMaxxRuralBadge.ChangeScale(M, D: Integer);
begin
  inherited;
  UpdatePaintBoxBounds;
  InvalidateBadge;
end;

function TMaxxRuralBadge.CloseRect: TRect;
var
  LSize: Integer;
begin
  LSize := ScaleMetric(IconSize);
  Result := Rect(Width - ScaleMetric(ContentPadding) - LSize,
    (Height - LSize) div 2,
    Width - ScaleMetric(ContentPadding),
    (Height + LSize) div 2);
end;

procedure TMaxxRuralBadge.CMEnabledChanged(var AMessage: TMessage);
begin
  inherited;
  UpdateCursor;
  InvalidateBadge;
end;

procedure TMaxxRuralBadge.CMTextChanged(var AMessage: TMessage);
begin
  inherited;
  InvalidateBadge;
end;

function TMaxxRuralBadge.ContentPadding: Integer;
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

procedure TMaxxRuralBadge.CreateWnd;
begin
  inherited;
  UpdatePaintBoxBounds;
  InvalidateBadge;
end;

function TMaxxRuralBadge.FontSize: Single;
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

function TMaxxRuralBadge.IconSize: Integer;
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

procedure TMaxxRuralBadge.InvalidateBadge;
begin
  UpdatePaintBoxBounds;
  if (FPaintBox <> nil) and HandleAllocated then
    FPaintBox.Redraw;
end;

procedure TMaxxRuralBadge.Loaded;
begin
  inherited;
  UpdatePaintBoxBounds;
  InvalidateBadge;
end;

function TMaxxRuralBadge.IsClosePoint(const X, Y: Integer): Boolean;
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

procedure TMaxxRuralBadge.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  if Button = mbLeft then
  begin
    FClosePressed := IsClosePoint(X, Y);
    InvalidateBadge;
  end;
end;

procedure TMaxxRuralBadge.MouseMove(Shift: TShiftState; X, Y: Integer);
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

procedure TMaxxRuralBadge.MouseUp(Button: TMouseButton; Shift: TShiftState;
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

procedure TMaxxRuralBadge.PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
  const ADest: TRectF; const AOpacity: Single);
var
  LAlpha: Byte;
  LBackground: TAlphaColor;
  LBorder: TAlphaColor;
  LCloseControlRect: TRect;
  LCloseRect: TRectF;
  LIconRect: TRectF;
  LIconStyle: TMaxxRuralIconStyle;
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

  FRenderer.TextCentered(ACanvas, Caption, TMaxxRuralComponentFontInstaller.FontFamily,
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

procedure TMaxxRuralBadge.PaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  MouseDown(Button, Shift, X, Y);
end;

procedure TMaxxRuralBadge.PaintBoxMouseEnter(Sender: TObject);
begin
  FMouseInside := True;
  InvalidateBadge;
end;

procedure TMaxxRuralBadge.PaintBoxMouseLeave(Sender: TObject);
begin
  FMouseInside := False;
  FCloseMouseInside := False;
  FClosePressed := False;
  UpdateCursor;
  InvalidateBadge;
end;

procedure TMaxxRuralBadge.PaintBoxMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  MouseMove(Shift, X, Y);
end;

procedure TMaxxRuralBadge.PaintBoxMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  MouseUp(Button, Shift, X, Y);
end;

function TMaxxRuralBadge.ParentSurfaceColor: TAlphaColor;
begin
  Result := TMaxxRuralComponentColors.ResolveParentSurface(Self);
end;

procedure TMaxxRuralBadge.Redraw;
begin
  InvalidateBadge;
end;

procedure TMaxxRuralBadge.Resize;
begin
  inherited;
  UpdatePaintBoxBounds;
  InvalidateBadge;
end;

function TMaxxRuralBadge.ScaleFactor: Single;
begin
  Result := 1;
  if FPaintBox <> nil then
    Result := FPaintBox.ScaleFactor;
end;

function TMaxxRuralBadge.ScaleMetric(const AValue: Integer): Integer;
begin
  if AValue <= 0 then
    Exit(0);
  Result := Max(1, Round(AValue * ScaleFactor));
end;

procedure TMaxxRuralBadge.SetAppearance(const AValue: TMaxxRuralBadgeAppearance);
begin
  if FAppearance = AValue then
    Exit;
  FAppearance := AValue;
  InvalidateBadge;
end;

procedure TMaxxRuralBadge.SetCornerRadius(const AValue: Integer);
begin
  if FCornerRadius = AValue then
    Exit;
  FCornerRadius := Max(0, AValue);
  InvalidateBadge;
end;

procedure TMaxxRuralBadge.SetIconKind(const AValue: TMaxxRuralIconKind);
begin
  if FIconKind = AValue then
    Exit;
  FIconKind := AValue;
  InvalidateBadge;
end;

procedure TMaxxRuralBadge.SetKind(const AValue: TMaxxRuralBadgeKind);
begin
  if FKind = AValue then
    Exit;
  FKind := AValue;
  InvalidateBadge;
end;

procedure TMaxxRuralBadge.SetShowClose(const AValue: Boolean);
begin
  if FShowClose = AValue then
    Exit;
  FShowClose := AValue;
  UpdateCursor;
  InvalidateBadge;
end;

procedure TMaxxRuralBadge.SetShowIcon(const AValue: Boolean);
begin
  if FShowIcon = AValue then
    Exit;
  FShowIcon := AValue;
  InvalidateBadge;
end;

procedure TMaxxRuralBadge.SetStatus(const AValue: TMaxxRuralBadgeStatus);
begin
  if FStatus = AValue then
    Exit;
  FStatus := AValue;
  InvalidateBadge;
end;

function TMaxxRuralBadge.TextColor: TAlphaColor;
begin
  if FAppearance = mbaFilled then
    Exit(TMaxxRuralComponentColors.White);

  case FStatus of
    mbsWarning:
      Result := TMaxxRuralComponentColors.WarningDark;
    mbsDanger:
      Result := TMaxxRuralComponentColors.DangerDark;
    mbsInfo:
      Result := TMaxxRuralComponentColors.Alpha(28, 94, 168);
    mbsNeutral:
      Result := TMaxxRuralComponentColors.Alpha(51, 65, 85);
  else
    Result := TMaxxRuralComponentColors.Primary;
  end;
end;

procedure TMaxxRuralBadge.UpdateCursor;
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

procedure TMaxxRuralBadge.UpdatePaintBoxBounds;
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

procedure TMaxxRuralBadge.WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
begin
  AMessage.Result := 1;
end;

end.
