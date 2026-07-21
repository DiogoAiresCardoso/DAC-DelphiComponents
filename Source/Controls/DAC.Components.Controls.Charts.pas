unit DAC.Components.Controls.Charts;

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
  DAC.Components.Skia.Renderer;

type
  TDACChartKind = (
    mckBar,
    mckLine,
    mckArea,
    mckDoughnut
  );

  TDACChart = class(TCustomControl)
  private
    FCategoriesText: string;
    FKind: TDACChartKind;
    FPaintBox: TSkPaintBox;
    FRenderer: TDACSkiaRenderer;
    FShowFrame: Boolean;
    FShowGrid: Boolean;
    FShowValue: Boolean;
    FValuesText: string;
    function ChartRect(const ADest: TRectF): TRectF;
    function ParseValues: TArray<Single>;
    procedure DrawAreaChart(const ACanvas: ISkCanvas; const ARect: TRectF;
      const AValues: TArray<Single>);
    procedure DrawBarChart(const ACanvas: ISkCanvas; const ARect: TRectF;
      const AValues: TArray<Single>);
    procedure DrawDoughnutChart(const ACanvas: ISkCanvas; const ARect: TRectF;
      const AValues: TArray<Single>);
    procedure DrawFrame(const ACanvas: ISkCanvas; const ADest: TRectF);
    procedure DrawGrid(const ACanvas: ISkCanvas; const ARect: TRectF);
    procedure DrawLineChart(const ACanvas: ISkCanvas; const ARect: TRectF;
      const AValues: TArray<Single>);
    procedure PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    function ScaleFactor: Single;
    function ScaleMetric(const AValue: Integer): Integer;
    procedure SetCategoriesText(const AValue: string);
    procedure SetKind(const AValue: TDACChartKind);
    procedure SetShowFrame(const AValue: Boolean);
    procedure SetShowGrid(const AValue: Boolean);
    procedure SetShowValue(const AValue: Boolean);
    procedure SetValuesText(const AValue: string);
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
    property CategoriesText: string read FCategoriesText write SetCategoriesText;
    property Constraints;
    property Enabled;
    property Font;
    property Kind: TDACChartKind read FKind write SetKind default mckBar;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowFrame: Boolean read FShowFrame write SetShowFrame default True;
    property ShowGrid: Boolean read FShowGrid write SetShowGrid default True;
    property ShowHint;
    property ShowValue: Boolean read FShowValue write SetShowValue default True;
    property TabOrder;
    property TabStop default False;
    property ValuesText: string read FValuesText write SetValuesText;
    property Visible;
  end;

  TDACBarChart = class(TDACChart)
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Kind default mckBar;
  end;

  TDACLineChart = class(TDACChart)
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Kind default mckLine;
  end;

  TDACAreaChart = class(TDACChart)
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Kind default mckArea;
  end;

  TDACDoughnutChart = class(TDACChart)
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Kind default mckDoughnut;
  end;

implementation

uses
  System.Math,
  System.SysUtils,
  DAC.Components.DesignSystem.ColorTokens;

constructor TDACChart.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  Width := 260;
  Height := 170;
  TabStop := False;
  ParentColor := False;
  Color := clWhite;
  StyleElements := [];
  Font.Name := 'Segoe UI';
  Font.Size := 9;

  FKind := mckBar;
  FShowFrame := True;
  FShowGrid := True;
  FShowValue := True;
  FCategoriesText := 'Jan;Fev;Mar;Abr;Mai;Jun';
  FValuesText := '52;68;74;82;94;60';
  FRenderer := TDACSkiaRenderer.Create;

  FPaintBox := TSkPaintBox.Create(Self);
  FPaintBox.Parent := Self;
  FPaintBox.SetSubComponent(True);
  FPaintBox.StyleElements := [];
  FPaintBox.OnDraw := PaintBoxDraw;
  UpdatePaintBoxBounds;
end;

destructor TDACChart.Destroy;
begin
  FPaintBox.Free;
  FRenderer.Free;
  inherited;
end;

function TDACChart.ChartRect(const ADest: TRectF): TRectF;
begin
  Result := TRectF.Create(ScaleMetric(18), ScaleMetric(16),
    ADest.Width - ScaleMetric(16), ADest.Height - ScaleMetric(22));
  if Result.Right <= Result.Left then
    Result.Right := Result.Left + 1;
  if Result.Bottom <= Result.Top then
    Result.Bottom := Result.Top + 1;
end;

procedure TDACChart.ChangeScale(M, D: Integer);
begin
  inherited;
  Redraw;
end;

procedure TDACChart.CreateWnd;
begin
  inherited;
  UpdatePaintBoxBounds;
  Redraw;
end;

procedure TDACChart.DrawAreaChart(const ACanvas: ISkCanvas;
  const ARect: TRectF; const AValues: TArray<Single>);
var
  I: Integer;
  LBase: Single;
  LFill: ISkPaint;
  LLine: ISkPaint;
  LMax: Single;
  LPath: ISkPath;
  LPathBuilder: ISkPathBuilder;
  LStep: Single;
  LX: Single;
  LY: Single;
begin
  if Length(AValues) = 0 then
    Exit;
  LMax := MaxValue(AValues);
  if LMax <= 0 then
    LMax := 1;
  LStep := ARect.Width / Max(1, Length(AValues) - 1);
  LBase := ARect.Bottom;

  LPathBuilder := TSkPathBuilder.Create;
  LPathBuilder.MoveTo(ARect.Left, LBase);
  for I := 0 to High(AValues) do
  begin
    LX := ARect.Left + (I * LStep);
    LY := ARect.Bottom - (AValues[I] / LMax * ARect.Height);
    LPathBuilder.LineTo(LX, LY);
  end;
  LPathBuilder.LineTo(ARect.Right, LBase);
  LPathBuilder.Close;
  LPath := LPathBuilder.Snapshot;

  LFill := TSkPaint.Create(TSkPaintStyle.Fill);
  LFill.AntiAlias := True;
  LFill.Color := TDACComponentColors.Primary;
  LFill.Alpha := 70;
  ACanvas.DrawPath(LPath, LFill);

  LLine := TSkPaint.Create(TSkPaintStyle.Stroke);
  LLine.AntiAlias := True;
  LLine.Color := TDACComponentColors.PrimaryDark;
  LLine.StrokeWidth := ScaleMetric(2);
  LLine.StrokeCap := TSkStrokeCap.Round;
  LLine.StrokeJoin := TSkStrokeJoin.Round;
  for I := 1 to High(AValues) do
    ACanvas.DrawLine(
      PointF(ARect.Left + ((I - 1) * LStep), ARect.Bottom - (AValues[I - 1] / LMax * ARect.Height)),
      PointF(ARect.Left + (I * LStep), ARect.Bottom - (AValues[I] / LMax * ARect.Height)),
      LLine);
end;

procedure TDACChart.DrawBarChart(const ACanvas: ISkCanvas;
  const ARect: TRectF; const AValues: TArray<Single>);
var
  I: Integer;
  LBar: TRectF;
  LBarPaint: ISkPaint;
  LBarWidth: Single;
  LGap: Single;
  LMax: Single;
begin
  if Length(AValues) = 0 then
    Exit;
  LMax := MaxValue(AValues);
  if LMax <= 0 then
    LMax := 1;
  LGap := ScaleMetric(8);
  LBarWidth := Max(ScaleMetric(8), (ARect.Width - (LGap * (Length(AValues) - 1))) /
    Max(1, Length(AValues)));
  LBarPaint := TSkPaint.Create(TSkPaintStyle.Fill);
  LBarPaint.AntiAlias := True;
  LBarPaint.Color := TDACComponentColors.Primary;

  for I := 0 to High(AValues) do
  begin
    LBar := TRectF.Create(
      ARect.Left + I * (LBarWidth + LGap),
      ARect.Bottom - (AValues[I] / LMax * ARect.Height),
      ARect.Left + I * (LBarWidth + LGap) + LBarWidth,
      ARect.Bottom);
    ACanvas.DrawRoundRect(LBar, ScaleMetric(3), ScaleMetric(3), LBarPaint);
  end;
end;

procedure TDACChart.DrawDoughnutChart(const ACanvas: ISkCanvas;
  const ARect: TRectF; const AValues: TArray<Single>);
var
  I: Integer;
  LArcPaint: ISkPaint;
  LColor: TAlphaColor;
  LRect: TRectF;
  LStart: Single;
  LSum: Single;
  LSweep: Single;
  LThickness: Single;
begin
  if Length(AValues) = 0 then
    Exit;

  LSum := 0;
  for I := 0 to High(AValues) do
    LSum := LSum + Max(0, AValues[I]);
  if LSum <= 0 then
    LSum := 1;

  LThickness := ScaleMetric(16);
  LRect := ARect;
  if LRect.Width > LRect.Height then
  begin
    LRect.Left := LRect.Left + ((LRect.Width - LRect.Height) / 2);
    LRect.Right := LRect.Left + LRect.Height;
  end
  else
  begin
    LRect.Top := LRect.Top + ((LRect.Height - LRect.Width) / 2);
    LRect.Bottom := LRect.Top + LRect.Width;
  end;
  LRect.Inflate(-LThickness, -LThickness);

  LArcPaint := TSkPaint.Create(TSkPaintStyle.Stroke);
  LArcPaint.AntiAlias := True;
  LArcPaint.StrokeWidth := LThickness;
  LArcPaint.StrokeCap := TSkStrokeCap.Round;
  LStart := -90;
  for I := 0 to High(AValues) do
  begin
    case I mod 4 of
      0: LColor := TDACComponentColors.Primary;
      1: LColor := TDACComponentColors.Alpha(37, 99, 235);
      2: LColor := TDACComponentColors.Warning;
    else
      LColor := TDACComponentColors.TextSecondary;
    end;
    LSweep := (Max(0, AValues[I]) / LSum * 360) - 2;
    LArcPaint.Color := LColor;
    if LSweep > 0 then
      ACanvas.DrawArc(LRect, LStart, LSweep, False, LArcPaint);
    LStart := LStart + LSweep + 2;
  end;
end;

procedure TDACChart.DrawFrame(const ACanvas: ISkCanvas; const ADest: TRectF);
var
  LRect: TRectF;
begin
  LRect := TRectF.Create(0.5, 0.5, ADest.Width - 0.5, ADest.Height - 0.5);
  FRenderer.FillRoundRect(ACanvas, LRect, TDACComponentColors.White, ScaleMetric(8), 255);
  FRenderer.StrokeRoundRect(ACanvas, LRect, TDACComponentColors.ControlBorder,
    ScaleMetric(8), 1, 255);
end;

procedure TDACChart.DrawGrid(const ACanvas: ISkCanvas; const ARect: TRectF);
var
  I: Integer;
  LPaint: ISkPaint;
  LY: Single;
begin
  LPaint := TSkPaint.Create(TSkPaintStyle.Stroke);
  LPaint.AntiAlias := True;
  LPaint.Color := TDACComponentColors.ControlBorder;
  LPaint.Alpha := 130;
  LPaint.StrokeWidth := 1;
  for I := 0 to 4 do
  begin
    LY := ARect.Top + (ARect.Height / 4 * I);
    ACanvas.DrawLine(PointF(ARect.Left, LY), PointF(ARect.Right, LY), LPaint);
  end;
end;

procedure TDACChart.DrawLineChart(const ACanvas: ISkCanvas;
  const ARect: TRectF; const AValues: TArray<Single>);
var
  I: Integer;
  LLine: ISkPaint;
  LMax: Single;
  LPoint: ISkPaint;
  LStep: Single;
begin
  if Length(AValues) = 0 then
    Exit;
  LMax := MaxValue(AValues);
  if LMax <= 0 then
    LMax := 1;
  LStep := ARect.Width / Max(1, Length(AValues) - 1);

  LLine := TSkPaint.Create(TSkPaintStyle.Stroke);
  LLine.AntiAlias := True;
  LLine.Color := TDACComponentColors.PrimaryDark;
  LLine.StrokeWidth := ScaleMetric(2);
  LLine.StrokeCap := TSkStrokeCap.Round;
  LLine.StrokeJoin := TSkStrokeJoin.Round;
  LPoint := TSkPaint.Create(TSkPaintStyle.Fill);
  LPoint.AntiAlias := True;
  LPoint.Color := TDACComponentColors.Primary;

  for I := 1 to High(AValues) do
    ACanvas.DrawLine(
      PointF(ARect.Left + ((I - 1) * LStep), ARect.Bottom - (AValues[I - 1] / LMax * ARect.Height)),
      PointF(ARect.Left + (I * LStep), ARect.Bottom - (AValues[I] / LMax * ARect.Height)),
      LLine);
  for I := 0 to High(AValues) do
    ACanvas.DrawCircle(ARect.Left + (I * LStep),
      ARect.Bottom - (AValues[I] / LMax * ARect.Height), ScaleMetric(3), LPoint);
end;

procedure TDACChart.Loaded;
begin
  inherited;
  UpdatePaintBoxBounds;
  Redraw;
end;

procedure TDACChart.PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
  const ADest: TRectF; const AOpacity: Single);
var
  LRect: TRectF;
  LValues: TArray<Single>;
begin
  // The rounded frame intentionally leaves its extreme corner pixels
  // uncovered. Clear the whole Skia destination first so those pixels keep
  // the chart surface color rather than the default black backing store.
  ACanvas.Clear(TDACComponentColors.White);
  LRect := ChartRect(ADest);
  LValues := ParseValues;
  if FShowFrame then
    DrawFrame(ACanvas, ADest);
  if FShowGrid and (FKind <> mckDoughnut) then
    DrawGrid(ACanvas, LRect);

  case FKind of
    mckLine:
      DrawLineChart(ACanvas, LRect, LValues);
    mckArea:
      DrawAreaChart(ACanvas, LRect, LValues);
    mckDoughnut:
      DrawDoughnutChart(ACanvas, LRect, LValues);
  else
    DrawBarChart(ACanvas, LRect, LValues);
  end;
end;

function TDACChart.ParseValues: TArray<Single>;
var
  I: Integer;
  LParts: TArray<string>;
  LText: string;
  LValue: Single;
begin
  LParts := FValuesText.Split([';', ',', '|']);
  SetLength(Result, Length(LParts));
  for I := 0 to High(LParts) do
  begin
    LText := Trim(LParts[I]);
    if not TryStrToFloat(LText, LValue) then
      if FormatSettings.DecimalSeparator <> '.' then
        LText := StringReplace(LText, '.', FormatSettings.DecimalSeparator, [rfReplaceAll])
      else
        LText := StringReplace(LText, ',', FormatSettings.DecimalSeparator, [rfReplaceAll]);
    if not TryStrToFloat(LText, LValue) then
      LValue := 0;
    Result[I] := LValue;
  end;
end;

procedure TDACChart.Redraw;
begin
  if (FPaintBox <> nil) and not (csDestroying in ComponentState) and
    ((Parent <> nil) or not (csDesigning in ComponentState)) then
    FPaintBox.Redraw;
  Invalidate;
end;

procedure TDACChart.Resize;
begin
  inherited;
  UpdatePaintBoxBounds;
  Redraw;
end;

function TDACChart.ScaleFactor: Single;
begin
  Result := 1;
  if FPaintBox <> nil then
    Result := FPaintBox.ScaleFactor;
  if Result <= 0 then
    Result := 1;
end;

function TDACChart.ScaleMetric(const AValue: Integer): Integer;
begin
  Result := Round(AValue * ScaleFactor);
  if (AValue > 0) and (Result < 1) then
    Result := 1;
end;

procedure TDACChart.SetCategoriesText(const AValue: string);
begin
  if FCategoriesText = AValue then
    Exit;
  FCategoriesText := AValue;
  Redraw;
end;

procedure TDACChart.SetKind(const AValue: TDACChartKind);
begin
  if FKind = AValue then
    Exit;
  FKind := AValue;
  Redraw;
end;

procedure TDACChart.SetShowFrame(const AValue: Boolean);
begin
  if FShowFrame = AValue then
    Exit;
  FShowFrame := AValue;
  Redraw;
end;

procedure TDACChart.SetShowGrid(const AValue: Boolean);
begin
  if FShowGrid = AValue then
    Exit;
  FShowGrid := AValue;
  Redraw;
end;

procedure TDACChart.SetShowValue(const AValue: Boolean);
begin
  if FShowValue = AValue then
    Exit;
  FShowValue := AValue;
  Redraw;
end;

procedure TDACChart.SetValuesText(const AValue: string);
begin
  if FValuesText = AValue then
    Exit;
  FValuesText := AValue;
  Redraw;
end;

procedure TDACChart.UpdatePaintBoxBounds;
begin
  if FPaintBox = nil then
    Exit;
  FPaintBox.SetBounds(0, 0, Width, Height);
end;

procedure TDACChart.WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
var
  LBrush: HBRUSH;
begin
  LBrush := CreateSolidBrush(ColorToRGB(Color));
  try
    Winapi.Windows.FillRect(AMessage.DC, ClientRect, LBrush);
  finally
    DeleteObject(LBrush);
  end;
  AMessage.Result := 1;
end;

constructor TDACBarChart.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Kind := mckBar;
end;

constructor TDACLineChart.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Kind := mckLine;
end;

constructor TDACAreaChart.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Kind := mckArea;
end;

constructor TDACDoughnutChart.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Kind := mckDoughnut;
end;

end.

