unit DAC.Components.Skia.Renderer;

interface

uses
  System.Generics.Collections,
  System.Skia,
  System.Types,
  System.UITypes;

type
  TDACSkiaRenderer = class
  private
    FFillPaintCache: TDictionary<string, ISkPaint>;
    FFontCache: TDictionary<string, ISkFont>;
    FStrokePaintCache: TDictionary<string, ISkPaint>;
    function BuildFillPaintKey(const AColor: TAlphaColor; const AAlpha: Byte): string;
    function BuildFontKey(const AFamily: string; const ASize: Single; const ABold: Boolean): string;
    function BuildStrokePaintKey(const AColor: TAlphaColor; const AWidth: Single;
      const AAlpha: Byte): string;
    function GetFillPaint(const AColor: TAlphaColor; const AAlpha: Byte): ISkPaint;
    function GetFont(const AFamily: string; const ASize: Single; const ABold: Boolean): ISkFont;
    function GetStrokePaint(const AColor: TAlphaColor; const AWidth: Single;
      const AAlpha: Byte): ISkPaint;
  public
    constructor Create;
    destructor Destroy; override;
    function FitTextWithEllipsis(const AText: string; const AFont: ISkFont;
      const AMaxWidth: Single): string;
    function MeasureText(const AText, AFamily: string; const ASize: Single;
      const ABold: Boolean = False): Single;
    function SnapRect(const ARect: TRectF; const AScale: Single = 1): TRectF;
    procedure FillRoundRect(const ACanvas: ISkCanvas; const ARect: TRectF;
      const AColor: TAlphaColor; const ARadius: Single; const AAlpha: Byte = 255);
    procedure StrokeRoundRect(const ACanvas: ISkCanvas; const ARect: TRectF;
      const AColor: TAlphaColor; const ARadius, AStrokeWidth: Single;
      const AAlpha: Byte = 255);
    procedure Svg(const ACanvas: ISkCanvas; const AIcon: ISkSVGDOM; const ARect: TRectF);
    procedure Text(const ACanvas: ISkCanvas; const AText, AFamily: string;
      const AX, AY, ASize: Single; const AColor: TAlphaColor;
      const ABold: Boolean = False; const AMaxWidth: Single = 0);
    procedure TextCentered(const ACanvas: ISkCanvas; const AText, AFamily: string;
      const ARect: TRectF; const ASize: Single; const AColor: TAlphaColor;
      const ABold: Boolean = False; const AMaxWidth: Single = 0);
  end;

implementation

uses
  System.Math,
  System.SysUtils,
  DAC.Components.DesignSystem.Fonts;

constructor TDACSkiaRenderer.Create;
begin
  inherited Create;
  FFillPaintCache := TDictionary<string, ISkPaint>.Create;
  FFontCache := TDictionary<string, ISkFont>.Create;
  FStrokePaintCache := TDictionary<string, ISkPaint>.Create;
end;

destructor TDACSkiaRenderer.Destroy;
begin
  FStrokePaintCache.Free;
  FFontCache.Free;
  FFillPaintCache.Free;
  inherited;
end;

function TDACSkiaRenderer.BuildFillPaintKey(const AColor: TAlphaColor;
  const AAlpha: Byte): string;
begin
  Result := Format('fill|%s|%d', [IntToHex(AColor, 8), AAlpha]);
end;

function TDACSkiaRenderer.BuildFontKey(const AFamily: string;
  const ASize: Single; const ABold: Boolean): string;
begin
  Result := Format('font|%s|%s|%s', [AFamily, FloatToStr(ASize), BoolToStr(ABold, True)]);
end;

function TDACSkiaRenderer.BuildStrokePaintKey(const AColor: TAlphaColor;
  const AWidth: Single; const AAlpha: Byte): string;
begin
  Result := Format('stroke|%s|%s|%d', [IntToHex(AColor, 8), FloatToStr(AWidth), AAlpha]);
end;

function TDACSkiaRenderer.FitTextWithEllipsis(const AText: string;
  const AFont: ISkFont; const AMaxWidth: Single): string;
var
  LBest: Integer;
  LHigh: Integer;
  LLow: Integer;
  LMid: Integer;
  LSource: string;
begin
  Result := AText.Trim;
  if (AMaxWidth <= 0) or (Length(Result) <= 3) or (AFont = nil) then
    Exit;

  if AFont.MeasureText(Result) <= AMaxWidth then
    Exit;

  LSource := Result;
  LLow := 3;
  LHigh := Length(LSource);
  LBest := 3;
  while LLow <= LHigh do
  begin
    LMid := (LLow + LHigh) div 2;
    if AFont.MeasureText(Copy(LSource, 1, LMid) + '...') <= AMaxWidth then
    begin
      LBest := LMid;
      LLow := LMid + 1;
    end
    else
      LHigh := LMid - 1;
  end;

  Result := Copy(LSource, 1, LBest) + '...';
end;

procedure TDACSkiaRenderer.FillRoundRect(const ACanvas: ISkCanvas;
  const ARect: TRectF; const AColor: TAlphaColor; const ARadius: Single;
  const AAlpha: Byte);
begin
  if ACanvas = nil then
    Exit;
  if ARadius > 0 then
    ACanvas.DrawRoundRect(ARect, ARadius, ARadius, GetFillPaint(AColor, AAlpha))
  else
    ACanvas.DrawRect(ARect, GetFillPaint(AColor, AAlpha));
end;

function TDACSkiaRenderer.GetFillPaint(const AColor: TAlphaColor;
  const AAlpha: Byte): ISkPaint;
var
  LKey: string;
begin
  LKey := BuildFillPaintKey(AColor, AAlpha);
  if not FFillPaintCache.TryGetValue(LKey, Result) then
  begin
    Result := TSkPaint.Create(TSkPaintStyle.Fill);
    Result.AntiAlias := True;
    Result.Color := AColor;
    Result.Alpha := AAlpha;
    FFillPaintCache.Add(LKey, Result);
  end;
end;

function TDACSkiaRenderer.GetFont(const AFamily: string;
  const ASize: Single; const ABold: Boolean): ISkFont;
var
  LKey: string;
  LStyle: TSkFontStyle;
  LTypeface: ISkTypeface;
begin
  LKey := BuildFontKey(AFamily, ASize, ABold);
  if not FFontCache.TryGetValue(LKey, Result) then
  begin
    if ABold then
      LStyle := TSkFontStyle.Bold
    else
      LStyle := TSkFontStyle.Normal;
    LTypeface := nil;
    if SameText(AFamily, DACComponentFontFamily) then
      LTypeface := TDACComponentFontInstaller.InterTypeface;
    if LTypeface = nil then
      LTypeface := TSkTypeface.MakeFromName(AFamily, LStyle);
    Result := TSkFont.Create(LTypeface, ASize, 1, 0);
    Result.Subpixel := True;
    FFontCache.Add(LKey, Result);
  end;
end;

function TDACSkiaRenderer.GetStrokePaint(const AColor: TAlphaColor;
  const AWidth: Single; const AAlpha: Byte): ISkPaint;
var
  LKey: string;
begin
  LKey := BuildStrokePaintKey(AColor, AWidth, AAlpha);
  if not FStrokePaintCache.TryGetValue(LKey, Result) then
  begin
    Result := TSkPaint.Create(TSkPaintStyle.Stroke);
    Result.AntiAlias := True;
    Result.Color := AColor;
    Result.StrokeWidth := AWidth;
    Result.Alpha := AAlpha;
    FStrokePaintCache.Add(LKey, Result);
  end;
end;

function TDACSkiaRenderer.MeasureText(const AText, AFamily: string;
  const ASize: Single; const ABold: Boolean): Single;
var
  LFont: ISkFont;
begin
  Result := 0;
  if AText = '' then
    Exit;

  LFont := GetFont(AFamily, ASize, ABold);
  if LFont <> nil then
    Result := LFont.MeasureText(AText);
end;

function TDACSkiaRenderer.SnapRect(const ARect: TRectF;
  const AScale: Single): TRectF;
var
  LScale: Single;
begin
  LScale := AScale;
  if LScale <= 0 then
    LScale := 1;

  Result := TRectF.Create(Round(ARect.Left * LScale) / LScale,
    Round(ARect.Top * LScale) / LScale,
    Round(ARect.Right * LScale) / LScale,
    Round(ARect.Bottom * LScale) / LScale);
end;

procedure TDACSkiaRenderer.StrokeRoundRect(const ACanvas: ISkCanvas;
  const ARect: TRectF; const AColor: TAlphaColor; const ARadius,
  AStrokeWidth: Single; const AAlpha: Byte);
begin
  if ACanvas = nil then
    Exit;
  if ARadius > 0 then
    ACanvas.DrawRoundRect(ARect, ARadius, ARadius, GetStrokePaint(AColor, AStrokeWidth, AAlpha))
  else
    ACanvas.DrawRect(ARect, GetStrokePaint(AColor, AStrokeWidth, AAlpha));
end;

procedure TDACSkiaRenderer.Svg(const ACanvas: ISkCanvas;
  const AIcon: ISkSVGDOM; const ARect: TRectF);
begin
  if (ACanvas = nil) or (AIcon = nil) then
    Exit;

  AIcon.SetContainerSize(TSizeF.Create(ARect.Width, ARect.Height));
  ACanvas.Save;
  try
    ACanvas.Translate(ARect.Left, ARect.Top);
    AIcon.Render(ACanvas);
  finally
    ACanvas.Restore;
  end;
end;

procedure TDACSkiaRenderer.Text(const ACanvas: ISkCanvas; const AText,
  AFamily: string; const AX, AY, ASize: Single; const AColor: TAlphaColor;
  const ABold: Boolean; const AMaxWidth: Single);
var
  LFont: ISkFont;
  LPaint: ISkPaint;
  LText: string;
begin
  if ACanvas = nil then
    Exit;

  LFont := GetFont(AFamily, ASize, ABold);
  LText := FitTextWithEllipsis(AText, LFont, AMaxWidth);
  LPaint := GetFillPaint(AColor, 255);
  ACanvas.DrawSimpleText(LText, AX, AY, LFont, LPaint);
end;

procedure TDACSkiaRenderer.TextCentered(const ACanvas: ISkCanvas;
  const AText, AFamily: string; const ARect: TRectF; const ASize: Single;
  const AColor: TAlphaColor; const ABold: Boolean; const AMaxWidth: Single);
var
  LBaseline: Single;
  LFont: ISkFont;
  LMaxWidth: Single;
  LPaint: ISkPaint;
  LText: string;
  LX: Single;
begin
  if ACanvas = nil then
    Exit;

  LFont := GetFont(AFamily, ASize, ABold);
  LMaxWidth := AMaxWidth;
  if LMaxWidth <= 0 then
    LMaxWidth := ARect.Width;
  LText := FitTextWithEllipsis(AText, LFont, LMaxWidth);
  LX := ARect.Left + (ARect.Width - LFont.MeasureText(LText)) / 2;
  LBaseline := ARect.Top + (ARect.Height / 2) + (ASize * 0.36);
  LPaint := GetFillPaint(AColor, 255);
  ACanvas.DrawSimpleText(LText, LX, LBaseline, LFont, LPaint);
end;

end.

