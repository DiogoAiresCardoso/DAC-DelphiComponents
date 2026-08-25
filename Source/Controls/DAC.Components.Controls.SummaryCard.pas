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
  DAC.Components.Controls.SystemText,
  DAC.Components.DesignSystem.ControlTokens,
  DAC.Components.DesignSystem.IconAssets,
  DAC.Components.DesignSystem.Theme,
  DAC.Components.Skia.IconPainter,
  DAC.Components.Skia.Renderer;

type
  TDACSummaryCardStatus = (
    mcsNeutral,
    mcsSuccess,
    mcsWarning,
    mcsDanger
  );

  TDACSummaryCardAppearance = (
    mcsaDefault,
    mcsaDashboard,
    mcsaCustom
  );

  TDACSummaryCard = class(TCustomControl)
  private
    FAppearance: TDACSummaryCardAppearance;
    FBaseAppearance: TDACSummaryCardAppearance;
    FAccentColor: TAlphaColor;
    FBackgroundColor: TAlphaColor;
    FBorderColor: TAlphaColor;
    FCustomBackgroundColor: Boolean;
    FCustomBorderColor: Boolean;
    FCustomAccentColor: Boolean;
    FCustomCornerRadius: Boolean;
    FCornerRadius: Integer;
    FFooterText: string;
    FIconKind: TDACIconKind;
    FIconPainter: TDACSkiaIconPainter;
    FPaintBox: TSkPaintBox;
    FRenderer: TDACSkiaRenderer;
    FTextOverlay: TDACSystemTextOverlay;
    FStatus: TDACSummaryCardStatus;
    FTitle: string;
    FThemeMode: TDACThemeMode;
    FValue: string;
    procedure CMEnabledChanged(var AMessage: TMessage); message CM_ENABLEDCHANGED;
    function EffectiveAccentColor: TAlphaColor;
    function FooterColor: TAlphaColor;
    procedure ApplyAppearance;
    function IsAccentColorStored: Boolean;
    function IsBackgroundColorStored: Boolean;
    function IsBorderColorStored: Boolean;
    function IsCornerRadiusStored: Boolean;
    function ParentSurfaceColor: TAlphaColor;
    procedure PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    function Pixels(const AValue: Integer): Integer;
    procedure SetAccentColor(const AValue: TAlphaColor);
    procedure SetAppearance(const AValue: TDACSummaryCardAppearance);
    procedure SetBackgroundColor(const AValue: TAlphaColor);
    procedure SetBorderColor(const AValue: TAlphaColor);
    procedure SetCornerRadius(const AValue: Integer);
    procedure SetFooterText(const AValue: string);
    procedure SetIconKind(const AValue: TDACIconKind);
    procedure SetStatus(const AValue: TDACSummaryCardStatus);
    procedure SetThemeMode(const AValue: TDACThemeMode);
    procedure SetTitle(const AValue: string);
    procedure SetValue(const AValue: string);
    procedure UpdatePaintBoxBounds;
    procedure ThemeChanged(Sender: TObject);
    procedure WMEraseBkgnd(var AMessage: TWMEraseBkgnd); message WM_ERASEBKGND;
  protected
    procedure CreateWnd; override;
    procedure Loaded; override;
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ResolvedBackgroundColor: TAlphaColor;
    procedure Redraw;
  published
    property Align;
    property Anchors;
    property Appearance: TDACSummaryCardAppearance read FAppearance
      write SetAppearance default mcsaDefault;
    property Constraints;
    property AccentColor: TAlphaColor read FAccentColor write SetAccentColor
      stored IsAccentColorStored;
    property BackgroundColor: TAlphaColor read FBackgroundColor
      write SetBackgroundColor stored IsBackgroundColorStored;
    property HasCustomBackgroundColor: Boolean read FCustomBackgroundColor stored False;
    property BorderColor: TAlphaColor read FBorderColor write SetBorderColor
      stored IsBorderColorStored;
    property CornerRadius: Integer read FCornerRadius write SetCornerRadius
      stored IsCornerRadiusStored;
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
    property ThemeMode: TDACThemeMode read FThemeMode write SetThemeMode default dtmInherit;
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
  System.Math,
  DAC.Components.DesignSystem.ColorTokens,
  DAC.Components.DesignSystem.Fonts,
  DAC.Components.DesignSystem.ComponentStyle;

constructor TDACSummaryCard.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque, csReplicatable];
  Width := Round(TDACComponentStyle.Resolve(dtmInherit).Tokens.Controls.SummaryCardDefaultWidth);
  Height := Round(TDACComponentStyle.Resolve(dtmInherit).Tokens.Controls.SummaryCardDefaultHeight);
  TabStop := False;

  FThemeMode := dtmInherit;
  FAppearance := mcsaDefault;
  FBaseAppearance := mcsaDefault;
  FCustomBackgroundColor := False;
  FCustomBorderColor := False;
  FFooterText := '+0,0% vs. mes anterior';
  FIconKind := mikMoneyCircle;
  FStatus := mcsSuccess;
  ApplyAppearance;
  FTitle := 'Receita';
  FValue := 'R$ 0,00';

  FRenderer := TDACSkiaRenderer.Create;
  FIconPainter := TDACSkiaIconPainter.Create(FRenderer);

  FPaintBox := TSkPaintBox.Create(Self);
  FPaintBox.Parent := Self;
  FPaintBox.OnDraw := PaintBoxDraw;
  FTextOverlay := TDACSystemTextOverlay.Create(Self);
  FTextOverlay.Parent := Self;
  FTextOverlay.SetSubComponent(True);
  FTextOverlay.Align := alClient;
  TDACThemeManager.RegisterListener(Self, ThemeChanged);
  UpdatePaintBoxBounds;
end;

procedure TDACSummaryCard.ApplyAppearance;
var
  LAppearance: TDACSummaryCardAppearance;
  LTokens: TDACControlTokens;
begin
  LTokens := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls;
  LAppearance := FAppearance;
  if LAppearance = mcsaCustom then
    LAppearance := FBaseAppearance;
  case LAppearance of
    mcsaDefault:
      begin
        if (FAppearance <> mcsaCustom) or not FCustomBackgroundColor then
          FBackgroundColor := LTokens.SummaryCardBackground;
        if (FAppearance <> mcsaCustom) or not FCustomBorderColor then
          FBorderColor := LTokens.SummaryCardBorder;
        if (FAppearance <> mcsaCustom) or not FCustomCornerRadius then
          FCornerRadius := Round(LTokens.SummaryCardRadius);
      end;
    mcsaDashboard:
      begin
        if (FAppearance <> mcsaCustom) or not FCustomBackgroundColor then
          FBackgroundColor := LTokens.SummaryCardDashboardBackground;
        if (FAppearance <> mcsaCustom) or not FCustomBorderColor then
          FBorderColor := LTokens.SummaryCardDashboardBorder;
        if (FAppearance <> mcsaCustom) or not FCustomCornerRadius then
          FCornerRadius := Round(LTokens.SummaryCardDashboardRadius);
      end;
  end;
  if FAppearance <> mcsaCustom then
  begin
    FCustomBackgroundColor := False;
    FCustomBorderColor := False;
    FCustomCornerRadius := False;
  end;
  if not FCustomAccentColor then
    FAccentColor := LTokens.SummaryCardSuccess;
end;

destructor TDACSummaryCard.Destroy;
begin
  TDACThemeManager.UnregisterListener(Self);
  FTextOverlay.Free;
  FIconPainter.Free;
  FRenderer.Free;
  inherited;
end;
procedure TDACSummaryCard.CMEnabledChanged(var AMessage: TMessage);
begin
  inherited;
  Redraw;
end;

procedure TDACSummaryCard.CreateWnd;
begin
  inherited;
  ApplyAppearance;
  UpdatePaintBoxBounds;
  Redraw;
end;

function TDACSummaryCard.EffectiveAccentColor: TAlphaColor;
var
  LTokens: TDACControlTokens;
begin
  LTokens := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls;
  case FStatus of
    mcsWarning:
      Result := LTokens.SummaryCardWarning;
    mcsDanger:
      Result := LTokens.SummaryCardDanger;
    mcsNeutral:
      Result := LTokens.SummaryCardFooterNeutral;
  else
    if FCustomAccentColor then
      Result := FAccentColor
    else
      Result := LTokens.SummaryCardSuccess;
  end;
  Result := TDACComponentColors.Normalize(Result);
end;

function TDACSummaryCard.FooterColor: TAlphaColor;
var
  LTokens: TDACControlTokens;
begin
  LTokens := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls;
  case FStatus of
    mcsWarning:
      Result := LTokens.SummaryCardWarning;
    mcsDanger:
      Result := LTokens.SummaryCardDanger;
    mcsNeutral:
      Result := LTokens.SummaryCardFooterNeutral;
  else
    Result := LTokens.SummaryCardSuccess;
  end;
end;

procedure TDACSummaryCard.Loaded;
begin
  inherited;
  ApplyAppearance;
  UpdatePaintBoxBounds;
  Redraw;
end;

function TDACSummaryCard.ParentSurfaceColor: TAlphaColor;
begin
  Result := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls.PopupBackground;
end;

function TDACSummaryCard.ResolvedBackgroundColor: TAlphaColor;
var
  LAppearance: TDACSummaryCardAppearance;
  LTokens: TDACControlTokens;
begin
  if (FAppearance = mcsaCustom) and FCustomBackgroundColor then
    Exit(FBackgroundColor);
  LAppearance := FAppearance;
  if LAppearance = mcsaCustom then
    LAppearance := FBaseAppearance;
  LTokens := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls;
  if LAppearance = mcsaDashboard then
    Result := LTokens.SummaryCardDashboardBackground
  else
    Result := LTokens.SummaryCardBackground;
end;

function TDACSummaryCard.IsAccentColorStored: Boolean;
begin
  Result := FCustomAccentColor;
end;

function TDACSummaryCard.IsBackgroundColorStored: Boolean;
begin
  Result := (FAppearance = mcsaCustom) and FCustomBackgroundColor;
end;

function TDACSummaryCard.IsBorderColorStored: Boolean;
begin
  Result := (FAppearance = mcsaCustom) and FCustomBorderColor;
end;

function TDACSummaryCard.IsCornerRadiusStored: Boolean;
begin
  Result := (FAppearance = mcsaCustom) and FCustomCornerRadius;
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
  LTokens: TDACControlTokens;
begin
  if ACanvas = nil then
    Exit;

  FRenderer.BeginNativeText(FTextOverlay);
  try

  LTokens := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls;
  LScale := LTokens.BorderWidth;
  LSurface := ParentSurfaceColor;
  ACanvas.Clear(LSurface);

  LCardRect := FRenderer.SnapRect(TRectF.Create(0, 0, ADest.Width, ADest.Height), LScale);
  LCardRect.Inflate(-(LTokens.BorderWidth / 2) / LScale,
    -(LTokens.BorderWidth / 2) / LScale);
  LRadius := Pixels(FCornerRadius);
  if FCustomBackgroundColor then
    LCardBackground := FBackgroundColor
  else
    LCardBackground := LTokens.SummaryCardBackground;
  if FCustomBorderColor then
    LCardBorder := FBorderColor
  else
    LCardBorder := LTokens.SummaryCardBorder;
  LAlpha := LTokens.AlphaOpaque;
  if not Enabled then
    LAlpha := LTokens.SummaryCardDisabledAlpha;

  FRenderer.FillRoundRect(ACanvas, LCardRect, LCardBackground, LRadius, LAlpha);
  FRenderer.StrokeRoundRect(ACanvas, LCardRect, LCardBorder, LRadius,
    Pixels(Round(LTokens.BorderWidth)), LTokens.SummaryCardBorderAlpha);

  LAccent := EffectiveAccentColor;
  LPadding := Pixels(Round(LTokens.SummaryCardPadding));
  LBadgeRect := TRectF.Create(LCardRect.Left + LPadding, LCardRect.Top + LPadding,
    LCardRect.Left + LPadding + Pixels(Round(LTokens.SummaryCardBadgeSize)),
    LCardRect.Top + LPadding + Pixels(Round(LTokens.SummaryCardBadgeSize)));
  FRenderer.FillRoundRect(ACanvas, LBadgeRect, LAccent, LBadgeRect.Height / 2,
    LTokens.SummaryCardBadgeAlpha);

  LIconStyle.Color := LAccent;
  LIconStyle.Alpha := LAlpha;
  LIconRect := LBadgeRect;
  LIconRect.Inflate(-Pixels(Round(LTokens.SummaryCardIconInset)), -Pixels(Round(LTokens.SummaryCardIconInset)));
  FIconPainter.Draw(ACanvas, LIconRect, FIconKind, LIconStyle);

  LTextLeft := LBadgeRect.Right + Pixels(Round(LTokens.SummaryCardTextGap));
  LTitleColor := LTokens.SummaryCardTitle;
  LTextColor := LTokens.SummaryCardText;
  FRenderer.Text(ACanvas, FTitle, TDACComponentStyle.FontFamily,
    LTextLeft, LCardRect.Top + Pixels(Round(LTokens.SummaryCardTitleBaseline)),
    LTokens.SummaryCardTitleTextSize, LTitleColor, False,
    LCardRect.Right - LTextLeft - Pixels(Round(LTokens.SummaryCardTextGap)));
  FRenderer.Text(ACanvas, FValue, TDACComponentStyle.FontFamily,
    LTextLeft, LCardRect.Top + Pixels(Round(LTokens.SummaryCardValueBaseline)),
    LTokens.SummaryCardValueTextSize, LTextColor, True,
    LCardRect.Right - LTextLeft - Pixels(Round(LTokens.SummaryCardTextGap)));

  LFooterY := LCardRect.Bottom - Pixels(Round(LTokens.SummaryCardFooterInset));
  FRenderer.Text(ACanvas, FFooterText, TDACComponentStyle.FontFamily,
    LCardRect.Left + LPadding, LFooterY, LTokens.SummaryCardFooterTextSize, FooterColor, True,
    LCardRect.Width - (LPadding * 2));
  finally
    FRenderer.EndNativeText;
  end;
end;

procedure TDACSummaryCard.Redraw;
begin
  if (FPaintBox = nil) or (csDestroying in ComponentState) then
    Exit;
  UpdatePaintBoxBounds;
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

procedure TDACSummaryCard.Resize;
begin
  inherited;
  UpdatePaintBoxBounds;
  Redraw;
end;

function TDACSummaryCard.Pixels(const AValue: Integer): Integer;
begin
  Result := AValue;
  if (AValue > 0) and (Result < 1) then
    Result := 1;
end;

procedure TDACSummaryCard.SetAccentColor(const AValue: TAlphaColor);
var
  LValue: TAlphaColor;
begin
  LValue := TDACComponentColors.Normalize(AValue);
  FCustomAccentColor := True;
  if FAccentColor = LValue then
    Exit;

  FAccentColor := LValue;
  Redraw;
end;

procedure TDACSummaryCard.SetAppearance(
  const AValue: TDACSummaryCardAppearance);
begin
  if FAppearance = AValue then
  begin
    if AValue <> mcsaCustom then
      ApplyAppearance;
    Exit;
  end;
  FAppearance := AValue;
  if AValue <> mcsaCustom then
    FBaseAppearance := AValue
  else
  begin
    FCustomBackgroundColor := True;
    FCustomBorderColor := True;
    FCustomCornerRadius := True;
  end;
  ApplyAppearance;
  Redraw;
end;

procedure TDACSummaryCard.SetThemeMode(const AValue: TDACThemeMode);
begin
  if FThemeMode = AValue then
    Exit;
  FThemeMode := AValue;
  ThemeChanged(Self);
end;

procedure TDACSummaryCard.ThemeChanged(Sender: TObject);
begin
  ApplyAppearance;
  Redraw;
end;

procedure TDACSummaryCard.SetBackgroundColor(const AValue: TAlphaColor);
begin
  FAppearance := mcsaCustom;
  FCustomBackgroundColor := True;
  if FBackgroundColor = AValue then
    Exit;
  FBackgroundColor := AValue;
  Redraw;
end;

procedure TDACSummaryCard.SetBorderColor(const AValue: TAlphaColor);
begin
  FAppearance := mcsaCustom;
  FCustomBorderColor := True;
  if FBorderColor = AValue then
    Exit;
  FBorderColor := AValue;
  Redraw;
end;

procedure TDACSummaryCard.SetCornerRadius(const AValue: Integer);
begin
  FAppearance := mcsaCustom;
  FCustomCornerRadius := True;
  if FCornerRadius = Max(0, AValue) then
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

