unit DAC.Components.Controls.BarChart;

interface

uses
  System.Types,
  System.UITypes,
  System.Skia,
  DAC.Components.DesignSystem.Theme,
  DAC.Components.Skia.ChartPainter;

type
  TDACBarChartPainter = class(TDACSkiaChartPainter)
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

{ TDACBarChartPainter }

procedure TDACBarChartPainter.Draw(const ACanvas: ISkCanvas; const ARect: TRectF;
  const ASeries: array of TDACChartSeries; const AOptions: TDACChartDisplayOptions;
  const ATheme: IDACComponentsTheme);
var
  LPlotRect: TRectF;
  I, J: Integer;
  LMaxY: Double;
  LBarWidth: Single;
  LStepX: Single;
  LBarRect: TRectF;
  LColor: TAlphaColor;
  LLabels: array of string;
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
    LBarWidth := (LStepX * 0.8) / Max(1, Length(ASeries));
    
    SetLength(LLabels, Length(ASeries[0].Points));
    for J := 0 to High(ASeries[0].Points) do
      LLabels[J] := ASeries[0].Points[J].Label_;
      
    for I := 0 to High(ASeries) do
    begin
      LColor := SeriesColor(ASeries[I], I, ATheme);
      for J := 0 to High(ASeries[I].Points) do
      begin
        LBarRect.Left := LPlotRect.Left + J * LStepX + (LStepX * 0.1) + I * LBarWidth;
        LBarRect.Right := LBarRect.Left + LBarWidth;
        LBarRect.Bottom := LPlotRect.Bottom;
        LBarRect.Top := LPlotRect.Bottom - (LPlotRect.Height * (ASeries[I].Points[J].Value / LMaxY) * AOptions.AnimationPhase);
        
        FRenderer.FillRoundRect(ACanvas, LBarRect, LColor, 4);
      end;
    end;
    
    if AOptions.ShowLabels then
      DrawXLabels(ACanvas, LPlotRect, LLabels, ATheme);
  end;
end;

end.
