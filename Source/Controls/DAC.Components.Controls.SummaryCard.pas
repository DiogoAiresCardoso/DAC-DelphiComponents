unit DAC.Components.Controls.SummaryCard;

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
  TDACSummaryCardStatus = (
    mcsNeutral,
    mcsSuccess,
    mcsWarning,
    mcsDanger
  );

  TDACSummaryCard = class(TCustomControl)
  private
    FAccentColor: TAlphaColor;
    FBackgroundColor: TAlphaColor;
    FBorderColor: TAlphaColor;
    FCustomBackgroundColor: Boolean;
    FCustomBorderColor: Boolean;
    FCornerRadius: Integer;
    FFooterText: string;
    FIconKind: TDACIconKind;
    FIconPainter: TDACSkiaIconPainter;
    FPaintBox: TSkPaintBox;
    FRenderer: TDACSkiaRenderer;
    FStatus: TDACSummaryCardStatus;
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
    procedure SetBackgroundColor(const AValue: TAlphaColor);
    procedure SetBorderColor(const AValue: TAlphaColor);
    procedure SetCornerRadius(const AValue: Integer);
    procedure SetFooterText(const AValue: string);
    procedure SetIconKind(const AValue: TDACIconKind);
    procedure SetStatus(const AValue: TDACSummaryCardStatus);
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
    property BackgroundColor: TAlphaColor read FBackgroundColor write SetBackgroundColor;
    property BorderColor: TAlphaColor read FBorderColor write SetBorderColor;
    property CornerRadius: Integer read FCornerRadius write SetCornerRadius default 10;
    property Enabled;
    property FooterText: string read FFooterText write SetFooterText;
    property Hint;
    property IconKind: TDACIconKind read FIconKind write SetIconKind default mikMoneyCircle;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property Status: TDACSummaryCardStatus read FStatus write SetStatus default mcsSuccess;
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
  DAC.Components.DesignSystem.ColorTokens,
  DAC.Components.DesignSystem.Fonts;

constructor TDACSummaryCard.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque, csReplicatable];
  Width := 150;
  Height := 116;
  TabStop := False;

  FAccentColor := TDACComponentColors.PrimaryDark;
  FBackgroundColor := TDACComponentColors.ControlBackground;
  FBorderColor := TDACComponentColors.ControlBorder;
  FCustomBackgroundColor := False;
  FCustomBorderColor := False;
  FCornerRadius := 10;
  FFooterText := '+0,0% vs. mes anterior';
  FIconKind := mikMoneyCircle;
  FStatus := mcsSuccess;
  FTitle := 'Receita';
  FValue := 'R$ 0,00';

  FRenderer := TDACSkiaRenderer.Create;
  FIconPainter := TDACSkiaIconPainter.Create(FRenderer);

  FPaintBox := TSkPaintBox.Create(Self);
  FPaintBox.Parent := Self;
  FPaintBox.OnDraw := PaintBoxDraw;
  UpdatePaintBoxBounds;
end;

destructor TDACSummaryCard.Destroy;
begin
  FIconPainter.Free;
  FRenderer.Free;
  inherited;
end;

procedure TDACSummaryCard.ChangeScale(M, D: Integer);
begin
  inherited;
  UpdatePaintBoxBounds;
  Redraw;
end;

procedure TDACSummaryCard.CMEnabledChanged(var AMessage: TMessage);
begin
  inherited;
  Redraw;
end;

procedure TDACSummaryCard.CreateWnd;
begin
  inherited;
  UpdatePaintBoxBounds;
  Redraw;
end;

function TDACSummaryCard.EffectiveAccentColor: TAlphaColor;
begin
  case FStatus of
    mcsWarning:
      Result := TDACComponentColors.WarningDark;
    mcsDanger:
      Result := TDACComponentColors.Danger;
    mcsNeutral:
      Result := TDACComponentColors.TextSecondary;
  else
    Result := FAccentColor;
  end;
  Result := TDACComponentColors.Normalize(Result);
end;

function TDACSummaryCard.FooterColor: TAlphaColor;
begin
  case FStatus of
    mcsWarning:
      Result := TDACComponentColors.WarningDark;
    mcsDanger:
      Result := TDACComponentColors.Danger;
    mcsNeutral:
      Result := TDACComponentColors.SuiteSectionSubtitle;
  else
    Result := TDACComponentColors.PrimaryDark;
  end;
end;

procedure TDACSummaryCard.Loaded;
begin
  inherited;
  UpdatePaintBoxBounds;
  Redraw;
end;

function TDACSummaryCard.ParentSurfaceColor: TAlphaColor;
begin
  Result := TDACComponentColors.ResolveParentSurface(Self);
end;

procedure TDACSummaryCard.PaintBoxDraw(Sender: TObject;
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
  LIconStyle: TDACIconStyle;
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
  if FCustomBackgroundColor then
    LCardBackground := FBackgroundColor
  else
    LCardBackground := TDACComponentColors.ControlBackgroundForSurface(LSurface);
  if FCustomBorderColor then
    LCardBorder := FBorderColor
  else
    LCardBorder := TDACComponentColors.ControlBorderForSurface(LSurface);
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
  LTitleColor := TDACComponentColors.ControlTextDisabledForSurface(LSurface);
  LTextColor := TDACComponentColors.ControlTextForSurface(LSurface);
  FRenderer.Text(ACanvas, FTitle, TDACComponentFontInstaller.FontFamily,
    LTextLeft, LCardRect.Top + ScaleMetric(25), 12, LTitleColor, False,
    LCardRect.Right - LTextLeft - ScaleMetric(8));
  FRenderer.Text(ACanvas, FValue, TDACComponentFontInstaller.FontFamily,
    LTextLeft, LCardRect.Top + ScaleMetric(50), 16, LTextColor, True,
    LCardRect.Right - LTextLeft - ScaleMetric(8));

  LFooterY := LCardRect.Bottom - ScaleMetric(20);
  FRenderer.Text(ACanvas, FFooterText, TDACComponentFontInstaller.FontFamily,
    LCardRect.Left + LPadding, LFooterY, 12, FooterColor, True,
    LCardRect.Width - (LPadding * 2));
end;

procedure TDACSummaryCard.Redraw;
begin
  if (FPaintBox <> nil) and HandleAllocated then
    FPaintBox.Redraw;
end;

procedure TDACSummaryCard.Resize;
begin
  inherited;
  UpdatePaintBoxBounds;
  Redraw;
end;

function TDACSummaryCard.ScaleFactor: Single;
begin
  Result := 1;
  if FPaintBox <> nil then
    Result := FPaintBox.ScaleFactor;
  if Result <= 0 then
    Result := 1;
end;

function TDACSummaryCard.ScaleMetric(const AValue: Integer): Integer;
begin
  Result := Round(AValue * ScaleFactor);
  if (AValue > 0) and (Result < 1) then
    Result := 1;
end;

procedure TDACSummaryCard.SetAccentColor(const AValue: TAlphaColor);
var
  LValue: TAlphaColor;
begin
  LValue := TDACComponentColors.Normalize(AValue);
  if FAccentColor = LValue then
    Exit;

  FAccentColor := LValue;
  Redraw;
end;

procedure TDACSummaryCard.SetBackgroundColor(const AValue: TAlphaColor);
begin
  if FBackgroundColor = AValue then
  begin
    FCustomBackgroundColor := True;
    Redraw;
    Exit;
  end;
  FBackgroundColor := AValue;
  FCustomBackgroundColor := True;
  Redraw;
end;

procedure TDACSummaryCard.SetBorderColor(const AValue: TAlphaColor);
begin
  if FBorderColor = AValue then
  begin
    FCustomBorderColor := True;
    Redraw;
    Exit;
  end;
  FBorderColor := AValue;
  FCustomBorderColor := True;
  Redraw;
end;

procedure TDACSummaryCard.SetCornerRadius(const AValue: Integer);
begin
  if FCornerRadius = AValue then
    Exit;

  FCornerRadius := AValue;
  if FCornerRadius < 0 then
    FCornerRadius := 0;
  Redraw;
end;

procedure TDACSummaryCard.SetFooterText(const AValue: string);
begin
  if FFooterText = AValue then
    Exit;

  FFooterText := AValue;
  Redraw;
end;

procedure TDACSummaryCard.SetIconKind(const AValue: TDACIconKind);
begin
  if FIconKind = AValue then
    Exit;

  FIconKind := AValue;
  Redraw;
end;

procedure TDACSummaryCard.SetStatus(
  const AValue: TDACSummaryCardStatus);
begin
  if FStatus = AValue then
    Exit;

  FStatus := AValue;
  Redraw;
end;

procedure TDACSummaryCard.SetTitle(const AValue: string);
begin
  if FTitle = AValue then
    Exit;

  FTitle := AValue;
  Redraw;
end;

procedure TDACSummaryCard.SetValue(const AValue: string);
begin
  if FValue = AValue then
    Exit;

  FValue := AValue;
  Redraw;
end;

procedure TDACSummaryCard.UpdatePaintBoxBounds;
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

procedure TDACSummaryCard.WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
begin
  AMessage.Result := 1;
end;

end.

