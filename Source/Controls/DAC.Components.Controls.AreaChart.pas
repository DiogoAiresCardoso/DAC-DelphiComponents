unit DAC.Components.Controls.AreaChart;

interface

uses
  System.Types,
  System.UITypes,
  System.Skia,
  DAC.Components.DesignSystem.Theme,
  DAC.Components.Skia.ChartPainter;

type
  TDACAreaChartPainter = class(TDACSkiaChartPainter)
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

{ TDACAreaChartPainter }

procedure TDACAreaChartPainter.Draw(const ACanvas: ISkCanvas; const ARect: TRectF;
  const ASeries: array of TDACChartSeries; const AOptions: TDACChartDisplayOptions;
  const ATheme: IDACComponentsTheme);
var
  LPlotRect: TRectF;
  I, J: Integer;
  LMaxY: Double;
  LStepX: Single;
  LColor: TAlphaColor;
  LLabels: array of string;
  LPath: ISkPath;
  LPathBuilder: ISkPathBuilder;
  LPaint: ISkPaint;
  LPtX, LPtY: Single;
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
      
      if Length(ASeries[I].Points) > 0 then
      begin
        LPathBuilder := TSkPathBuilder.Create;
        
        LPtX := LPlotRect.Left + (LStepX / 2);
        LPtY := LPlotRect.Bottom - (LPlotRect.Height * (ASeries[I].Points[0].Value / LMaxY) * AOptions.AnimationPhase);
        LPathBuilder.MoveTo(LPtX, LPlotRect.Bottom);
        LPathBuilder.LineTo(LPtX, LPtY);
        
        for J := 1 to High(ASeries[I].Points) do
        begin
          LPtX := LPlotRect.Left + J * LStepX + (LStepX / 2);
          LPtY := LPlotRect.Bottom - (LPlotRect.Height * (ASeries[I].Points[J].Value / LMaxY) * AOptions.AnimationPhase);
          LPathBuilder.LineTo(LPtX, LPtY);
        end;
        
        LPathBuilder.LineTo(LPtX, LPlotRect.Bottom);
        LPathBuilder.Close;
        
        LPath := LPathBuilder.Detach;
        
        LPaint := TSkPaint.Create;
        LPaint.Style := TSkPaintStyle.Fill;
        LPaint.Color := LColor;
        LPaint.Alpha := 128; // Semi-transparent for area
        ACanvas.DrawPath(LPath, LPaint);
        
        // Draw the line on top
        for J := 0 to High(ASeries[I].Points) - 1 do
        begin
          FRenderer.StrokeLine(ACanvas,
            TPointF.Create(LPlotRect.Left + J * LStepX + (LStepX / 2), LPlotRect.Bottom - (LPlotRect.Height * (ASeries[I].Points[J].Value / LMaxY) * AOptions.AnimationPhase)),
            TPointF.Create(LPlotRect.Left + (J + 1) * LStepX + (LStepX / 2), LPlotRect.Bottom - (LPlotRect.Height * (ASeries[I].Points[J + 1].Value / LMaxY) * AOptions.AnimationPhase)),
            LColor, 2);
        end;
      end;
    end;
    
    if AOptions.ShowLabels then
      DrawXLabels(ACanvas, LPlotRect, LLabels, ATheme);
  end;
end;

end.
