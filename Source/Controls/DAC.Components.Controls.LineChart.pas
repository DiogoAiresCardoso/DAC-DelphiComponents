unit DAC.Components.Controls.LineChart;

interface

uses
  System.Types,
  System.UITypes,
  System.Skia,
  DAC.Components.DesignSystem.Theme,
  DAC.Components.Skia.ChartPainter;

type
  TDACLineChartPainter = class(TDACSkiaChartPainter)
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

{ TDACLineChartPainter }

procedure TDACLineChartPainter.Draw(const ACanvas: ISkCanvas; const ARect: TRectF;
  const ASeries: array of TDACChartSeries; const AOptions: TDACChartDisplayOptions;
  const ATheme: IDACComponentsTheme);
var
  LPlotRect: TRectF;
  I, J: Integer;
  LMaxY: Double;
  LStepX: Single;
  LColor: TAlphaColor;
  LLabels: array of string;
  LPt1, LPt2: TPointF;
begin
  LPlotRect := PlotRect(ARect, AOptions, ATheme);

  if AOptions.ShowGrid then
    DrawGrid(ACanvas, LPlotRect, ATheme);

  LMaxY := 0;
  for I := 0 to High(ASeries) do
    for J := 0 to High(ASeries[I].Points) do
      if ASeries[I].Points[J].Value > LMaxY then
        LMaxY := ASeries[I].Points[J].Value;

  if LMaxY = 0 then
    LMaxY := 1;

  if Length(ASeries) > 0 then
  begin
    LStepX := LPlotRect.Width / Max(1, Length(ASeries[0].Points));
    
    SetLength(LLabels, Length(ASeries[0].Points));
    for J := 0 to High(ASeries[0].Points) do
      LLabels[J] := ASeries[0].Points[J].Label_;
      
    for I := 0 to High(ASeries) do
    begin
      LColor := SeriesColor(ASeries[I], I, ATheme);
      for J := 0 to High(ASeries[I].Points) - 1 do
      begin
        LPt1.X := LPlotRect.Left + J * LStepX + (LStepX / 2);
        LPt1.Y := LPlotRect.Bottom - (LPlotRect.Height * (ASeries[I].Points[J].Value / LMaxY) * AOptions.AnimationPhase);
        
        LPt2.X := LPlotRect.Left + (J + 1) * LStepX + (LStepX / 2);
        LPt2.Y := LPlotRect.Bottom - (LPlotRect.Height * (ASeries[I].Points[J + 1].Value / LMaxY) * AOptions.AnimationPhase);
        
        FRenderer.StrokeLine(ACanvas, LPt1, LPt2, LColor, 2);
      end;
    end;
    
    if AOptions.ShowLabels then
      DrawXLabels(ACanvas, LPlotRect, LLabels, ATheme);
  end;
end;

end.
