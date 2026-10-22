from pathlib import Path
root=Path(r'M:\Delphi Componentes\DAC-DelphiComponents')
p=root/'Source/Controls/DAC.Components.Controls.SummaryCard.pas'
raw=p.read_bytes()
(root/'tmp/cards-fonts-20261020/SummaryCard.before.pas').write_bytes(raw)
s=raw.decode('utf-8-sig').replace('\r\n','\n')
def rep(a,b):
    global s
    assert a in s,a[:80]
    s=s.replace(a,b,1)

rep('  TDACSummaryCard = class(TCustomControl)', '''  TDACSummaryCardTextLayout = record
    TitleBounds, ValueBounds, FooterBounds: TRect;
    TitleText, ValueText, FooterText: string;
    RequiredHeight: Integer;
  end;

  TDACSummaryCard = class(TCustomControl)''')
rep('    FTextOverlay: TDACSystemTextOverlay;', '''    FTextOverlay: TGraphicControl;
    FTitleFont, FValueFont, FFooterFont: TFont;
    FCustomTitleFont, FCustomValueFont, FCustomFooterFont: Boolean;
    FUpdatingFonts, FAdjustingTextHeight: Boolean;
    FAutoTextHeight: Boolean;
    FMeasureBitmap: TBitmap;''')
rep('    function FooterColor: TAlphaColor;', '''    function FooterColor: TAlphaColor;
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
    procedure UpdateTextHeight;''')
rep('    procedure Redraw;\n  published', '''    procedure Redraw;
    function TextLayout: TDACSummaryCardTextLayout;
    procedure ResetTitleFont;
    procedure ResetValueFont;
    procedure ResetFooterFont;
    procedure ResetTextFonts;
  published''')
rep('    property Constraints;', '''    property Constraints;
    property AutoTextHeight: Boolean read FAutoTextHeight write SetAutoTextHeight default True;
    property TitleFont: TFont read FTitleFont write SetTitleFont stored FCustomTitleFont;
    property ValueFont: TFont read FValueFont write SetValueFont stored FCustomValueFont;
    property FooterFont: TFont read FFooterFont write SetFooterFont stored FCustomFooterFont;''')
rep('  System.Math,', '  System.Math,\n  System.SysUtils,')
at=s.index('constructor TDACSummaryCard.Create(')
s=s[:at]+'''type
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

'''+s[at:]
rep('  FStatus := mcsSuccess;\n  ApplyAppearance;', '''  FStatus := mcsSuccess;
  FAutoTextHeight := True;
  FMeasureBitmap := TBitmap.Create;
  FTitleFont := TFont.Create;
  FValueFont := TFont.Create;
  FFooterFont := TFont.Create;
  ResetTextFonts;
  FTitleFont.OnChange := TextFontChanged;
  FValueFont.OnChange := TextFontChanged;
  FFooterFont.OnChange := TextFontChanged;
  ApplyAppearance;''')
rep('  FTextOverlay := TDACSystemTextOverlay.Create(Self);', '  FTextOverlay := TDACSummaryCardTextOverlay.CreateForCard(Self);')
rep('  FIconPainter.Free;\n  FRenderer.Free;', '''  FIconPainter.Free;
  FRenderer.Free;
  FTitleFont.Free;
  FValueFont.Free;
  FFooterFont.Free;
  FMeasureBitmap.Free;''')
# Replace the text portion only; retain existing surface/alpha/theme work.
rep('  LFooterY: Single;\n','')
rep('  LTextColor: TAlphaColor;\n  LTitleColor: TAlphaColor;\n  LTextLeft: Single;\n','')
rep('  FRenderer.BeginNativeText(FTextOverlay);\n  try\n\n','')
a=s.index('  LTextLeft := LBadgeRect.Right')
b=s.index('\nend;\n\nprocedure TDACSummaryCard.Redraw;',a)
s=s[:a]+'''  FTextOverlay.Invalidate;'''+s[b:]
a=s.index('procedure TDACSummaryCard.Redraw;')
b=s.index('procedure TDACSummaryCard.Resize;',a)
s=s[:a]+'''procedure TDACSummaryCard.InitializeTextFont(const AFont: TFont;
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
    Max(1, AWidth - 2 * Padding), Result.FooterText);
  if FooterH > 0 then
  begin
    Inc(Top, Gap);
    FooterOffset := Max(FooterH, Abs(FFooterFont.Height) + Round(Tokens.SummaryCardFooterInset));
    Result.RequiredHeight := Top + FooterOffset;
    Top := Max(Top, AHeight - FooterOffset);
  end
  else Result.RequiredHeight := Top + Padding;
  Result.FooterBounds := Rect(Padding, Top, Max(Padding + 1, AWidth - Padding), Top + FooterH);
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

'''+s[b:]
p.write_bytes(s.replace('\n','\r\n').encode('utf-8'))
