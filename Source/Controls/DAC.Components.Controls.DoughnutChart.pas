unit DAC.Components.Controls.DoughnutChart;

interface

uses
  System.Types,
  System.UITypes,
  System.Skia,
  DAC.Components.DesignSystem.Theme,
  DAC.Components.Skia.ChartPainter;

type
  TDACDoughnutChartPainter = class(TDACSkiaChartPainter)
  public
    procedure Draw(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ASeries: array of TDACChartSeries;
      const AOptions: TDACChartDisplayOptions;
      const ATheme: IDACComponentsTheme); override;
  end;

implementation

uses
  System.Math,
  DAC.Components.DesignSystem.ControlTokens;

{ TDACDoughnutChartPainter }

procedure TDACDoughnutChartPainter.Draw(const ACanvas: ISkCanvas; const ARect: TRectF;
  const ASeries: array of TDACChartSeries; const AOptions: TDACChartDisplayOptions;
  const ATheme: IDACComponentsTheme);
var
  LPlotRect: TRectF;
  J: Integer;
  LTotal: Double;
  LStartAngle, LSweepAngle: Single;
  LCenter: TPointF;
  LRadius, LThickness: Single;
  LColor: TAlphaColor;
  LPaint: ISkPaint;
  LPath: ISkPath;
  LPathBuilder: ISkPathBuilder;
begin
  LPlotRect := PlotRect(ARect, AOptions, ATheme);

  // Doughnut chart doesn't use Grid or XLabels typically
  
  if Length(ASeries) = 0 then
    Exit;

  // Considering only the first series for a Doughnut chart
  LTotal := 0;
  for J := 0 to High(ASeries[0].Points) do
    LTotal := LTotal + ASeries[0].Points[J].Value;

  if LTotal = 0 then
    Exit;

  LCenter := TPointF.Create(LPlotRect.Left + LPlotRect.Width / 2, LPlotRect.Top + LPlotRect.Height / 2);
  LRadius := Min(LPlotRect.Width, LPlotRect.Height) / 2;
  LThickness := LRadius * 0.4; // 40% of radius
  
  LStartAngle := -90; // Start at top
  
  for J := 0 to High(ASeries[0].Points) do
  begin
    LSweepAngle := (ASeries[0].Points[J].Value / LTotal) * 360 * AOptions.AnimationPhase;
    LColor := ASeries[0].Points[J].Color;
    if LColor = TAlphaColors.Null then
      LColor := SeriesColor(ASeries[0], J, ATheme); // Use index as color index
      
    LPaint := TSkPaint.Create;
    LPaint.Style := TSkPaintStyle.Stroke;
    LPaint.Color := LColor;
    LPaint.StrokeWidth := LThickness;
    LPaint.AntiAlias := True;
    
    LPathBuilder := TSkPathBuilder.Create;
    LPathBuilder.AddArc(TRectF.Create(LCenter.X - LRadius + LThickness / 2, LCenter.Y - LRadius + LThickness / 2,
                                      LCenter.X + LRadius - LThickness / 2, LCenter.Y + LRadius - LThickness / 2),
                        LStartAngle, LSweepAngle);
    LPath := LPathBuilder.Detach;
    
    ACanvas.DrawPath(LPath, LPaint);
    
    LStartAngle := LStartAngle + LSweepAngle;
  end;
end;

end.
