unit MaxxRural.Components.Controls.SummaryCard;

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
  TMaxxRuralSummaryCardStatus = (
    mcsNeutral,
    mcsSuccess,
    mcsWarning,
    mcsDanger
  );

  TMaxxRuralSummaryCard = class(TCustomControl)
  private
    FAccentColor: TAlphaColor;
    FCornerRadius: Integer;
    FFooterText: string;
    FIconKind: TMaxxRuralIconKind;
    FIconPainter: TMaxxRuralSkiaIconPainter;
    FPaintBox: TSkPaintBox;
    FRenderer: TMaxxRuralSkiaRenderer;
    FStatus: TMaxxRuralSummaryCardStatus;
    FTitle: string;
    FValue: string;
    procedure CMEnabledChanged(var AMessage: TMessage); message CM_ENABLEDCHANGED;
    function EffectiveAccentColor: TAlphaColor;
    function FooterColor: TAlphaColor;
    function ParentSurfaceColor: TAlphaColor;
    procedure PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    function ScaleFactor: Single;
    function ScaleMetric(const AValue: Integer): Integer;
    procedure SetAccentColor(const AValue: TAlphaColor);
    procedure SetCornerRadius(const AValue: Integer);
    procedure SetFooterText(const AValue: string);
    procedure SetIconKind(const AValue: TMaxxRuralIconKind);
    procedure SetStatus(const AValue: TMaxxRuralSummaryCardStatus);
    procedure SetTitle(const AValue: string);
    procedure SetValue(const AValue: string);
    procedure UpdatePaintBoxBounds;
    procedure WMEraseBkgnd(var AMessage: TWMEraseBkgnd); message WM_ERASEBKGND;
  protected
    procedure ChangeScale(M, D: Integer); override;
    procedure CreateWnd; override;
    procedure Loaded; override;
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Redraw;
  published
    property Align;
    property Anchors;
    property Constraints;
    property AccentColor: TAlphaColor read FAccentColor write SetAccentColor;
    property CornerRadius: Integer read FCornerRadius write SetCornerRadius default 10;
    property Enabled;
    property FooterText: string read FFooterText write SetFooterText;
    property Hint;
    property IconKind: TMaxxRuralIconKind read FIconKind write SetIconKind default mikMoneyCircle;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property Status: TMaxxRuralSummaryCardStatus read FStatus write SetStatus default mcsSuccess;
    property TabOrder;
    property TabStop default False;
    property Title: string read FTitle write SetTitle;
    property Value: string read FValue write SetValue;
    property Visible;
    property OnClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
  end;

implementation

uses
  MaxxRural.Components.DesignSystem.ColorTokens,
  MaxxRural.Components.DesignSystem.Fonts;

constructor TMaxxRuralSummaryCard.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque, csReplicatable];
  Width := 150;
  Height := 116;
  TabStop := False;

  FAccentColor := TMaxxRuralComponentColors.PrimaryDark;
  FCornerRadius := 10;
  FFooterText := '+0,0% vs. mes anterior';
  FIconKind := mikMoneyCircle;
  FStatus := mcsSuccess;
  FTitle := 'Receita';
  FValue := 'R$ 0,00';

  FRenderer := TMaxxRuralSkiaRenderer.Create;
  FIconPainter := TMaxxRuralSkiaIconPainter.Create(FRenderer);

  FPaintBox := TSkPaintBox.Create(Self);
  FPaintBox.Parent := Self;
  FPaintBox.OnDraw := PaintBoxDraw;
  UpdatePaintBoxBounds;
end;

destructor TMaxxRuralSummaryCard.Destroy;
begin
  FIconPainter.Free;
  FRenderer.Free;
  inherited;
end;

procedure TMaxxRuralSummaryCard.ChangeScale(M, D: Integer);
begin
  inherited;
  UpdatePaintBoxBounds;
  Redraw;
end;

procedure TMaxxRuralSummaryCard.CMEnabledChanged(var AMessage: TMessage);
begin
  inherited;
  Redraw;
end;

procedure TMaxxRuralSummaryCard.CreateWnd;
begin
  inherited;
  UpdatePaintBoxBounds;
  Redraw;
end;

function TMaxxRuralSummaryCard.EffectiveAccentColor: TAlphaColor;
begin
  case FStatus of
    mcsWarning:
      Result := TMaxxRuralComponentColors.WarningDark;
    mcsDanger:
      Result := TMaxxRuralComponentColors.Danger;
    mcsNeutral:
      Result := TMaxxRuralComponentColors.TextSecondary;
  else
    Result := FAccentColor;
  end;
  Result := TMaxxRuralComponentColors.Normalize(Result);
end;

function TMaxxRuralSummaryCard.FooterColor: TAlphaColor;
begin
  case FStatus of
    mcsWarning:
      Result := TMaxxRuralComponentColors.WarningDark;
    mcsDanger:
      Result := TMaxxRuralComponentColors.Danger;
    mcsNeutral:
      Result := TMaxxRuralComponentColors.SuiteSectionSubtitle;
  else
    Result := TMaxxRuralComponentColors.PrimaryDark;
  end;
end;

procedure TMaxxRuralSummaryCard.Loaded;
begin
  inherited;
  UpdatePaintBoxBounds;
  Redraw;
end;

function TMaxxRuralSummaryCard.ParentSurfaceColor: TAlphaColor;
begin
  Result := TMaxxRuralComponentColors.ResolveParentSurface(Self);
end;

procedure TMaxxRuralSummaryCard.PaintBoxDraw(Sender: TObject;
  const ACanvas: ISkCanvas; const ADest: TRectF; const AOpacity: Single);
var
  LAccent: TAlphaColor;
  LAlpha: Byte;
  LBadgeRect: TRectF;
  LCardBackground: TAlphaColor;
  LCardBorder: TAlphaColor;
  LCardRect: TRectF;
  LFooterY: Single;
  LIconRect: TRectF;
  LIconStyle: TMaxxRuralIconStyle;
  LPadding: Single;
  LRadius: Single;
  LScale: Single;
  LSurface: TAlphaColor;
  LTextColor: TAlphaColor;
  LTitleColor: TAlphaColor;
  LTextLeft: Single;
begin
  if ACanvas = nil then
    Exit;

  LScale := ScaleFactor;
  LSurface := ParentSurfaceColor;
  ACanvas.Clear(LSurface);

  LCardRect := FRenderer.SnapRect(TRectF.Create(0, 0, ADest.Width, ADest.Height), LScale);
  LCardRect.Inflate(-0.5 / LScale, -0.5 / LScale);
  LRadius := ScaleMetric(FCornerRadius);
  LCardBackground := TMaxxRuralComponentColors.ControlBackgroundForSurface(LSurface);
  LCardBorder := TMaxxRuralComponentColors.ControlBorderForSurface(LSurface);
  LAlpha := 255;
  if not Enabled then
    LAlpha := 130;

  FRenderer.FillRoundRect(ACanvas, LCardRect, LCardBackground, LRadius, LAlpha);
  FRenderer.StrokeRoundRect(ACanvas, LCardRect, LCardBorder, LRadius,
    ScaleMetric(1), 210);

  LAccent := EffectiveAccentColor;
  LPadding := ScaleMetric(12);
  LBadgeRect := TRectF.Create(LCardRect.Left + LPadding, LCardRect.Top + LPadding,
    LCardRect.Left + LPadding + ScaleMetric(32), LCardRect.Top + LPadding + ScaleMetric(32));
  FRenderer.FillRoundRect(ACanvas, LBadgeRect, LAccent, LBadgeRect.Height / 2, 34);

  LIconStyle.Color := LAccent;
  LIconStyle.Alpha := LAlpha;
  LIconRect := LBadgeRect;
  LIconRect.Inflate(-ScaleMetric(8), -ScaleMetric(8));
  FIconPainter.Draw(ACanvas, LIconRect, FIconKind, LIconStyle);

  LTextLeft := LBadgeRect.Right + ScaleMetric(8);
  LTitleColor := TMaxxRuralComponentColors.ControlTextDisabledForSurface(LSurface);
  LTextColor := TMaxxRuralComponentColors.ControlTextForSurface(LSurface);
  FRenderer.Text(ACanvas, FTitle, TMaxxRuralComponentFontInstaller.FontFamily,
    LTextLeft, LCardRect.Top + ScaleMetric(25), 12, LTitleColor, False,
    LCardRect.Right - LTextLeft - ScaleMetric(8));
  FRenderer.Text(ACanvas, FValue, TMaxxRuralComponentFontInstaller.FontFamily,
    LTextLeft, LCardRect.Top + ScaleMetric(50), 16, LTextColor, True,
    LCardRect.Right - LTextLeft - ScaleMetric(8));

  LFooterY := LCardRect.Bottom - ScaleMetric(20);
  FRenderer.Text(ACanvas, FFooterText, TMaxxRuralComponentFontInstaller.FontFamily,
    LCardRect.Left + LPadding, LFooterY, 12, FooterColor, True,
    LCardRect.Width - (LPadding * 2));
end;

procedure TMaxxRuralSummaryCard.Redraw;
begin
  if (FPaintBox <> nil) and HandleAllocated then
    FPaintBox.Redraw;
end;

procedure TMaxxRuralSummaryCard.Resize;
begin
  inherited;
  UpdatePaintBoxBounds;
  Redraw;
end;

function TMaxxRuralSummaryCard.ScaleFactor: Single;
begin
  Result := 1;
  if FPaintBox <> nil then
    Result := FPaintBox.ScaleFactor;
  if Result <= 0 then
    Result := 1;
end;

function TMaxxRuralSummaryCard.ScaleMetric(const AValue: Integer): Integer;
begin
  Result := Round(AValue * ScaleFactor);
  if (AValue > 0) and (Result < 1) then
    Result := 1;
end;

procedure TMaxxRuralSummaryCard.SetAccentColor(const AValue: TAlphaColor);
var
  LValue: TAlphaColor;
begin
  LValue := TMaxxRuralComponentColors.Normalize(AValue);
  if FAccentColor = LValue then
    Exit;

  FAccentColor := LValue;
  Redraw;
end;

procedure TMaxxRuralSummaryCard.SetCornerRadius(const AValue: Integer);
begin
  if FCornerRadius = AValue then
    Exit;

  FCornerRadius := AValue;
  if FCornerRadius < 0 then
    FCornerRadius := 0;
  Redraw;
end;

procedure TMaxxRuralSummaryCard.SetFooterText(const AValue: string);
begin
  if FFooterText = AValue then
    Exit;

  FFooterText := AValue;
  Redraw;
end;

procedure TMaxxRuralSummaryCard.SetIconKind(const AValue: TMaxxRuralIconKind);
begin
  if FIconKind = AValue then
    Exit;

  FIconKind := AValue;
  Redraw;
end;

procedure TMaxxRuralSummaryCard.SetStatus(
  const AValue: TMaxxRuralSummaryCardStatus);
begin
  if FStatus = AValue then
    Exit;

  FStatus := AValue;
  Redraw;
end;

procedure TMaxxRuralSummaryCard.SetTitle(const AValue: string);
begin
  if FTitle = AValue then
    Exit;

  FTitle := AValue;
  Redraw;
end;

procedure TMaxxRuralSummaryCard.SetValue(const AValue: string);
begin
  if FValue = AValue then
    Exit;

  FValue := AValue;
  Redraw;
end;

procedure TMaxxRuralSummaryCard.UpdatePaintBoxBounds;
var
  LHeight: Integer;
  LWidth: Integer;
begin
  if FPaintBox = nil then
    Exit;

  if HandleAllocated then
  begin
    LWidth := ClientWidth;
    LHeight := ClientHeight;
  end
  else
  begin
    LWidth := Width;
    LHeight := Height;
  end;

  if LWidth < 0 then
    LWidth := 0;
  if LHeight < 0 then
    LHeight := 0;

  if (FPaintBox.Left <> 0) or (FPaintBox.Top <> 0) or
    (FPaintBox.Width <> LWidth) or (FPaintBox.Height <> LHeight) then
    FPaintBox.SetBounds(0, 0, LWidth, LHeight);
end;

procedure TMaxxRuralSummaryCard.WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
begin
  AMessage.Result := 1;
end;

end.
