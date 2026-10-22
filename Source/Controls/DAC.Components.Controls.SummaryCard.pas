unit DAC.Components.Controls.SummaryCard;

interface

uses
  System.Classes,
  System.Skia,
  System.Types,
  System.UITypes,
  Winapi.Messages,
  Winapi.Windows,
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

  TDACSummaryCardTextLayout = record
    TitleBounds, ValueBounds, FooterBounds: TRect;
    TitleText, ValueText, FooterText: string;
    RequiredHeight: Integer;
  end;

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
    FTextOverlay: TGraphicControl;
    FTitleFont, FValueFont, FFooterFont: TFont;
    FCustomTitleFont, FCustomValueFont, FCustomFooterFont: Boolean;
    FUpdatingFonts, FAdjustingTextHeight: Boolean;
    FAutoTextHeight: Boolean;
    FMeasureBitmap: TBitmap;
    FStatus: TDACSummaryCardStatus;
    FTitle: string;
    FThemeMode: TDACThemeMode;
    FValue: string;
    procedure CMEnabledChanged(var AMessage: TMessage); message CM_ENABLEDCHANGED;
    procedure CMParentColorChanged(var AMessage: TMessage); message CM_PARENTCOLORCHANGED;
    function EffectiveAccentColor: TAlphaColor;
    function FooterColor: TAlphaColor;
    procedure InitializeTextFont(const AFont: TFont; const ASize: Single;
      const ABold: Boolean);
    procedure TextFontChanged(Sender: TObject);
    procedure SetTitleFont(const AValue: TFont);
    procedure SetValueFont(const AValue: TFont);
    procedure SetFooterFont(const AValue: TFont);
    procedure SetAutoTextHeight(const AValue: Boolean);
    function WrappedText(const AText: string; const AFont: TFont;
      const AWidth: Integer): string;
    function MeasureText(const AText: string; const AFont: TFont;
      const AWidth: Integer; out ADisplayText: string): Integer;
    function CalculateTextLayout(const AWidth, AHeight: Integer): TDACSummaryCardTextLayout;
    procedure DrawNativeText(const ACanvas: TCanvas);
    procedure UpdateTextHeight;
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
    procedure GetChildren(Proc: TGetChildProc; Root: TComponent); override;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ResolvedBackgroundColor: TAlphaColor;
    procedure Redraw;
    function TextLayout: TDACSummaryCardTextLayout;
    procedure ResetTitleFont;
    procedure ResetValueFont;
    procedure ResetFooterFont;
    procedure ResetTextFonts;
  published
    property Align;
    property Anchors;
    property Appearance: TDACSummaryCardAppearance read FAppearance
      write SetAppearance default mcsaDefault;
    property Constraints;
    property AutoTextHeight: Boolean read FAutoTextHeight write SetAutoTextHeight default True;
    property TitleFont: TFont read FTitleFont write SetTitleFont stored FCustomTitleFont;
    property ValueFont: TFont read FValueFont write SetValueFont stored FCustomValueFont;
    property FooterFont: TFont read FFooterFont write SetFooterFont stored FCustomFooterFont;
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
  System.SysUtils,
  DAC.Components.DesignSystem.ColorTokens,
  DAC.Components.DesignSystem.Fonts,
  DAC.Components.DesignSystem.ComponentStyle;

type
  { The card owns this native text layer. Measuring and painting consume the
    same TFont, including italic/underline/strikeout; Skia owns only chrome. }
  TDACSummaryCardTextOverlay = class(TGraphicControl)
  private
    FCard: TDACSummaryCard;
  protected
    procedure Paint; override;
  public
    constructor CreateForCard(ACard: TDACSummaryCard);
  end;

constructor TDACSummaryCardTextOverlay.CreateForCard(ACard: TDACSummaryCard);
begin
  inherited Create(ACard);
  FCard := ACard;
  Enabled := False;
  SetSubComponent(True);
end;

procedure TDACSummaryCardTextOverlay.Paint;
begin
  FCard.DrawNativeText(Canvas);
end;

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
  FAutoTextHeight := True;
  FMeasureBitmap := TBitmap.Create;
  FTitleFont := TFont.Create;
  FValueFont := TFont.Create;
  FFooterFont := TFont.Create;
  ResetTextFonts;
  FTitleFont.OnChange := TextFontChanged;
  FValueFont.OnChange := TextFontChanged;
  FFooterFont.OnChange := TextFontChanged;
  ApplyAppearance;
  FTitle := 'Receita';
  FValue := 'R$ 0,00';

  FRenderer := TDACSkiaRenderer.Create;
  FIconPainter := TDACSkiaIconPainter.Create(FRenderer);

  FPaintBox := TSkPaintBox.Create(Self);
  FPaintBox.Parent := Self;
  FPaintBox.OnDraw := PaintBoxDraw;
  FTextOverlay := TDACSummaryCardTextOverlay.CreateForCard(Self);
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
  { Publish the already-composited opaque surface so native descendants use
    the same background that Skia paints inside the card. }
  Color := TDACComponentColors.ToVclColor(ResolvedBackgroundColor);
end;

destructor TDACSummaryCard.Destroy;
begin
  TDACThemeManager.UnregisterListener(Self);
  FTextOverlay.Free;
  FIconPainter.Free;
  FRenderer.Free;
  FTitleFont.Free;
  FValueFont.Free;
  FFooterFont.Free;
  FMeasureBitmap.Free;
  inherited;
end;
procedure TDACSummaryCard.CMEnabledChanged(var AMessage: TMessage);
begin
  inherited;
  Redraw;
end;

procedure TDACSummaryCard.CMParentColorChanged(var AMessage: TMessage);
begin
  inherited;
  ApplyAppearance;
  Redraw;
end;

procedure TDACSummaryCard.GetChildren(Proc: TGetChildProc; Root: TComponent);
var
  I: Integer;
begin
  for I := 0 to ControlCount - 1 do
    if (Controls[I] <> FPaintBox) and (Controls[I] <> FTextOverlay) and
      (Controls[I].Owner = Root) then Proc(Controls[I]);
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
  Result := TDACComponentColors.ResolveParentSurface(Self);
end;

function TDACSummaryCard.ResolvedBackgroundColor: TAlphaColor;
var
  LAppearance: TDACSummaryCardAppearance;
  LBackground: TAlphaColor;
  LTokens: TDACControlTokens;
begin
  if (FAppearance = mcsaCustom) and FCustomBackgroundColor then
    LBackground := FBackgroundColor
  else
  begin
    LAppearance := FAppearance;
    if LAppearance = mcsaCustom then
      LAppearance := FBaseAppearance;
    LTokens := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls;
    if LAppearance = mcsaDashboard then
      LBackground := LTokens.SummaryCardDashboardBackground
    else
      LBackground := LTokens.SummaryCardBackground;
  end;
  Result := TDACComponentColors.CompositeOver(LBackground,
    ParentSurfaceColor);
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
  LIconRect: TRectF;
  LIconStyle: TDACIconStyle;
  LPadding: Single;
  LRadius: Single;
  LScale: Single;
  LSurface: TAlphaColor;
  LTokens: TDACControlTokens;
begin
  if ACanvas = nil then
    Exit;

  LTokens := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls;
  LScale := LTokens.BorderWidth;
  LSurface := ParentSurfaceColor;
  ACanvas.Clear(LSurface);

  LCardRect := FRenderer.SnapRect(TRectF.Create(0, 0, ADest.Width, ADest.Height), LScale);
  LCardRect.Inflate(-(LTokens.BorderWidth / 2) / LScale,
    -(LTokens.BorderWidth / 2) / LScale);
  LRadius := Pixels(FCornerRadius);
  LCardBackground := ResolvedBackgroundColor;
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

  FTextOverlay.Invalidate;
end;

procedure TDACSummaryCard.InitializeTextFont(const AFont: TFont;
  const ASize: Single; const ABold: Boolean);
begin
  FUpdatingFonts := True;
  try
    AFont.Name := TDACComponentStyle.FontFamily;
    AFont.Height := -Max(1, Round(ASize));
    AFont.Charset := DEFAULT_CHARSET;
    AFont.Pitch := fpDefault;
    AFont.Quality := fqClearType;
    AFont.Color := clDefault;
    if ABold then AFont.Style := [fsBold] else AFont.Style := [];
  finally
    FUpdatingFonts := False;
  end;
end;

procedure TDACSummaryCard.ResetTitleFont;
begin
  InitializeTextFont(FTitleFont,
    TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls.SummaryCardTitleTextSize, False);
  FCustomTitleFont := False;
  Redraw;
end;

procedure TDACSummaryCard.ResetValueFont;
begin
  InitializeTextFont(FValueFont,
    TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls.SummaryCardValueTextSize, True);
  FCustomValueFont := False;
  Redraw;
end;

procedure TDACSummaryCard.ResetFooterFont;
begin
  InitializeTextFont(FFooterFont,
    TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls.SummaryCardFooterTextSize, True);
  FCustomFooterFont := False;
  Redraw;
end;

procedure TDACSummaryCard.ResetTextFonts;
begin
  ResetTitleFont;
  ResetValueFont;
  ResetFooterFont;
end;

procedure TDACSummaryCard.TextFontChanged(Sender: TObject);
begin
  if FUpdatingFonts or (csDestroying in ComponentState) then Exit;
  if Sender = FTitleFont then FCustomTitleFont := True
  else if Sender = FValueFont then FCustomValueFont := True
  else if Sender = FFooterFont then FCustomFooterFont := True;
  Redraw;
end;

procedure TDACSummaryCard.SetTitleFont(const AValue: TFont);
begin
  FTitleFont.Assign(AValue);
end;

procedure TDACSummaryCard.SetValueFont(const AValue: TFont);
begin
  FValueFont.Assign(AValue);
end;

procedure TDACSummaryCard.SetFooterFont(const AValue: TFont);
begin
  FFooterFont.Assign(AValue);
end;

procedure TDACSummaryCard.SetAutoTextHeight(const AValue: Boolean);
begin
  if FAutoTextHeight = AValue then Exit;
  FAutoTextHeight := AValue;
  Redraw;
end;

function TDACSummaryCard.WrappedText(const AText: string; const AFont: TFont;
  const AWidth: Integer): string;
var
  I, Count: Integer;
  Word, Glyph: string;
begin
  FMeasureBitmap.Canvas.Font.Assign(AFont);
  Result := '';
  Word := '';
  I := 1;
  while I <= Length(AText) do
  begin
    Count := 1;
    if (Ord(AText[I]) >= $D800) and (Ord(AText[I]) <= $DBFF) and
      (I < Length(AText)) and (Ord(AText[I + 1]) >= $DC00) and
      (Ord(AText[I + 1]) <= $DFFF) then Count := 2;
    Glyph := Copy(AText, I, Count);
    if AText[I] <= ' ' then
    begin
      Result := Result + Word + Glyph;
      Word := '';
    end
    else
    begin
      if (Word <> '') and (FMeasureBitmap.Canvas.TextWidth(Word + Glyph) > AWidth) then
      begin
        Result := Result + Word + sLineBreak;
        Word := '';
      end;
      Word := Word + Glyph;
    end;
    Inc(I, Count);
  end;
  Result := Result + Word;
end;

function TDACSummaryCard.MeasureText(const AText: string; const AFont: TFont;
  const AWidth: Integer; out ADisplayText: string): Integer;
var
  R: TRect;
begin
  ADisplayText := WrappedText(AText, AFont, Max(1, AWidth));
  if ADisplayText = '' then Exit(0);
  R := Rect(0, 0, Max(1, AWidth), 0);
  DrawText(FMeasureBitmap.Canvas.Handle, PChar(ADisplayText), Length(ADisplayText), R,
    DT_CALCRECT or DT_WORDBREAK or DT_NOPREFIX);
  Result := R.Height;
end;

function TDACSummaryCard.CalculateTextLayout(const AWidth,
  AHeight: Integer): TDACSummaryCardTextLayout;
var
  Tokens: TDACControlTokens;
  Padding, Gap, Left, Right, Top, H, FooterH, FooterOffset: Integer;
begin
  Result := Default(TDACSummaryCardTextLayout);
  if (FMeasureBitmap = nil) or (FTitleFont = nil) or (FValueFont = nil) or
    (FFooterFont = nil) then Exit;
  Tokens := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls;
  Padding := Round(Tokens.SummaryCardPadding);
  Gap := Max(1, Round(Tokens.SummaryCardTextGap / 2));
  Left := Padding + Round(Tokens.SummaryCardBadgeSize + Tokens.SummaryCardTextGap);
  Right := Max(Left + 1, AWidth - Padding);
  Top := Max(Padding, Round(Tokens.SummaryCardTitleBaseline - Tokens.SummaryCardTitleTextSize));
  H := MeasureText(FTitle, FTitleFont, Right - Left, Result.TitleText);
  Result.TitleBounds := Rect(Left, Top, Right, Top + H);
  if H > 0 then Inc(Top, H + Gap);
  if FTitle <> '' then Top := Max(Top,
    Round(Tokens.SummaryCardValueBaseline - Tokens.SummaryCardValueTextSize));
  H := MeasureText(FValue, FValueFont, Right - Left, Result.ValueText);
  Result.ValueBounds := Rect(Left, Top, Right, Top + H);
  Inc(Top, H);
  FooterH := MeasureText(FFooterText, FFooterFont,
    Right - Left, Result.FooterText);
  if FooterH > 0 then
  begin
    Inc(Top, Gap);
    FooterOffset := Max(FooterH, Abs(FFooterFont.Height) + Round(Tokens.SummaryCardFooterInset));
    Result.RequiredHeight := Top + FooterOffset;
    Top := Max(Top, AHeight - FooterOffset);
  end
  else Result.RequiredHeight := Top + Padding;
  Result.FooterBounds := Rect(Left, Top, Right, Top + FooterH);
  Result.RequiredHeight := Max(Result.RequiredHeight,
    2 * Padding + Round(Tokens.SummaryCardBadgeSize));
end;

function TDACSummaryCard.TextLayout: TDACSummaryCardTextLayout;
begin
  Result := CalculateTextLayout(Width, Height);
end;

procedure TDACSummaryCard.UpdateTextHeight;
var
  Layout: TDACSummaryCardTextLayout;
begin
  if not FAutoTextHeight or FAdjustingTextHeight or (Width <= 0) or
    (csLoading in ComponentState) or (csDestroying in ComponentState) then Exit;
  Layout := TextLayout;
  if Layout.RequiredHeight <= Height then Exit;
  FAdjustingTextHeight := True;
  try
    Height := Layout.RequiredHeight;
  finally
    FAdjustingTextHeight := False;
  end;
end;

procedure TDACSummaryCard.DrawNativeText(const ACanvas: TCanvas);
var
  Layout: TDACSummaryCardTextLayout;
  Tokens: TDACControlTokens;
  procedure Draw(const AText: string; const AFont: TFont; R: TRect;
    const ADefaultColor: TAlphaColor);
  begin
    if AText = '' then Exit;
    ACanvas.Font.Assign(AFont);
    if AFont.Color = clDefault then
      ACanvas.Font.Color := TDACComponentColors.ToVclColor(ADefaultColor);
    SetBkMode(ACanvas.Handle, TRANSPARENT);
    DrawText(ACanvas.Handle, PChar(AText), Length(AText), R,
      DT_WORDBREAK or DT_NOPREFIX);
  end;
begin
  Layout := TextLayout;
  Tokens := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls;
  Draw(Layout.TitleText, FTitleFont, Layout.TitleBounds, Tokens.SummaryCardTitle);
  Draw(Layout.ValueText, FValueFont, Layout.ValueBounds, Tokens.SummaryCardText);
  Draw(Layout.FooterText, FFooterFont, Layout.FooterBounds, FooterColor);
end;

procedure TDACSummaryCard.Redraw;
begin
  if (FPaintBox = nil) or (csDestroying in ComponentState) then Exit;
  UpdateTextHeight;
  UpdatePaintBoxBounds;
  if (Parent <> nil) and HandleAllocated and Parent.HandleAllocated then
    FPaintBox.Redraw
  else FPaintBox.Invalidate;
  if FTextOverlay <> nil then FTextOverlay.Invalidate;
  Invalidate;
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
  begin
    ThemeChanged(Self);
    Exit;
  end;
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
  Color := TDACComponentColors.ToVclColor(ResolvedBackgroundColor);
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
var
  LBrush: HBRUSH;
begin
  LBrush := CreateSolidBrush(ColorToRGB(
    TDACComponentColors.ToVclColor(ParentSurfaceColor)));
  try
    Winapi.Windows.FillRect(AMessage.DC, ClientRect, LBrush);
  finally
    DeleteObject(LBrush);
  end;
  AMessage.Result := 1;
end;

end.

