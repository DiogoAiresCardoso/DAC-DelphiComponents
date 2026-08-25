unit MaxUI.Controls.Charts;

{$CODEPAGE 65001}

interface

uses
  System.Classes,
  Vcl.Controls,
  MaxUI.Types;

type
  TMaxChart = class(TGraphicControl)
  private
    FChartKind: TMaxChartKind;
    FData: TStringList;
    FShowLegend: Boolean;
    FShowAxes: Boolean;
    FTitle: string;
    procedure SetChartKind(const Value: TMaxChartKind);
    procedure SetData(const Value: TStrings);
    procedure SetShowLegend(const Value: Boolean);
    procedure SetShowAxes(const Value: Boolean);
    procedure SetTitle(const Value: string);
    procedure DataChanged(Sender: TObject);
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property Align;
    property Anchors;
    property Font;
    property ParentFont;
    property ChartKind: TMaxChartKind read FChartKind write SetChartKind default mckBar;
    property Data: TStrings read FData write SetData;
    property ShowLegend: Boolean read FShowLegend write SetShowLegend default True;
    property ShowAxes: Boolean read FShowAxes write SetShowAxes default True;
    property Title: string read FTitle write SetTitle;
  end;

implementation

uses
  System.Math,
  System.SysUtils,
  System.Types,
  Winapi.Windows,
  Vcl.Graphics,
  MaxUI.Dpi,
  MaxUI.Painter,
  MaxUI.Theme;

type
  TChartValues = array of Double;
  TChartLabels = array of string;

function ChartColor(const Index: Integer): TColor;
begin
  case Index mod 5 of
    1: Result := TMaxTheme.Palette.Info;
    2: Result := TMaxTheme.Palette.Warning;
    3: Result := TMaxTheme.Palette.AccentPurple;
    4: Result := TMaxTheme.Palette.BorderStrong;
  else
    Result := TMaxTheme.Palette.Primary;
  end;
end;

procedure ParseData(const Lines: TStrings; out Labels: TChartLabels;
  out Values: TChartValues);
var
  I: Integer;
  P: Integer;
  S: string;
  NumberText: string;
  V: Double;
begin
  SetLength(Labels, Lines.Count);
  SetLength(Values, Lines.Count);
  for I := 0 to Lines.Count - 1 do
  begin
    S := Lines[I];
    P := Pos('=', S);
    if P = 0 then P := Pos(';', S);
    if P = 0 then
    begin
      Labels[I] := IntToStr(I + 1);
      NumberText := S;
    end
    else
    begin
      Labels[I] := Trim(Copy(S, 1, P - 1));
      NumberText := Trim(Copy(S, P + 1, MaxInt));
    end;
    if not TryStrToFloat(NumberText, V) then V := 0;
    Values[I] := V;
  end;
end;

constructor TMaxChart.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FChartKind := mckBar;
  FShowLegend := True;
  FShowAxes := True;
  FTitle := 'Gráfico';
  Font.Name := 'Inter';
  Font.Size := 8;
  Width := 320;
  Height := 190;
  FData := TStringList.Create;
  FData.OnChange := DataChanged;
  FData.Add('Jan=40');
  FData.Add('Fev=55');
  FData.Add('Mar=68');
  FData.Add('Abr=62');
  FData.Add('Mai=80');
  FData.Add('Jun=52');
end;

destructor TMaxChart.Destroy;
begin
  FData.Free;
  inherited;
end;

procedure TMaxChart.DataChanged(Sender: TObject);
begin
  Invalidate;
end;

procedure TMaxChart.Paint;
var
  Labels: TChartLabels;
  Values: TChartValues;
  Plot: TRect;
  LegendRect: TRect;
  I: Integer;
  Count: Integer;
  MinValue: Double;
  MaxValue: Double;
  RangeValue: Double;
  ZeroY: Integer;
  X: Integer;
  Y: Integer;
  PrevX: Integer;
  PrevY: Integer;
  BarWidth: Integer;
  BarRect: TRect;
  Points: array of TPoint;
  Save: Integer;
  S: string;
  Total: Double;
  Angle: Double;
  NextAngle: Double;
  CenterX: Integer;
  CenterY: Integer;
  Radius: Integer;
  StartX: Integer;
  StartY: Integer;
  EndX: Integer;
  EndY: Integer;
  InnerRect: TRect;
  LegendY: Integer;

  function ValueY(const V: Double): Integer;
  begin
    Result := Plot.Bottom - Round((V - MinValue) / RangeValue * Plot.Height);
  end;

begin
  Canvas.Brush.Color := TMaxTheme.Palette.Surface;
  Canvas.FillRect(ClientRect);
  ParseData(FData, Labels, Values);
  Count := Length(Values);

  Save := SaveDC(Canvas.Handle);
  try
    Canvas.Font.Assign(Font);
    Canvas.Font.Color := TMaxTheme.Palette.Text;
    SetBkMode(Canvas.Handle, TRANSPARENT);
    S := FTitle;
    DrawText(Canvas.Handle, PChar(S), Length(S), Rect(8, 4, Width - 8, 26),
      DT_LEFT or DT_VCENTER or DT_SINGLELINE or DT_END_ELLIPSIS);
  finally
    RestoreDC(Canvas.Handle, Save);
  end;

  Plot := Rect(MaxScale(30, CurrentPPI), MaxScale(32, CurrentPPI),
    Width - MaxScale(12, CurrentPPI), Height - MaxScale(28, CurrentPPI));
  if FShowLegend and (FChartKind = mckDonut) then
    Dec(Plot.Right, MaxScale(100, CurrentPPI));

  if Count = 0 then
  begin
    Save := SaveDC(Canvas.Handle);
    try
      Canvas.Font.Assign(Font);
      Canvas.Font.Color := TMaxTheme.Palette.TextDisabled;
      DrawText(Canvas.Handle, 'Sem dados', -1, Plot,
        DT_CENTER or DT_VCENTER or DT_SINGLELINE);
    finally
      RestoreDC(Canvas.Handle, Save);
    end;
    Exit;
  end;

  MinValue := Values[0];
  MaxValue := Values[0];
  for I := 1 to Count - 1 do
  begin
    MinValue := Min(MinValue, Values[I]);
    MaxValue := Max(MaxValue, Values[I]);
  end;
  MinValue := Min(MinValue, 0);
  MaxValue := Max(MaxValue, 0);
  RangeValue := MaxValue - MinValue;
  if SameValue(RangeValue, 0) then RangeValue := 1;
  ZeroY := ValueY(0);

  if FChartKind <> mckDonut then
  begin
    if FShowAxes then
    begin
      Canvas.Pen.Color := TMaxTheme.Palette.Border;
      Canvas.Pen.Width := 1;
      Canvas.MoveTo(Plot.Left, Plot.Top);
      Canvas.LineTo(Plot.Left, Plot.Bottom);
      Canvas.LineTo(Plot.Right, Plot.Bottom);
      Canvas.Pen.Color := TMaxTheme.Palette.BorderStrong;
      Canvas.MoveTo(Plot.Left, ZeroY);
      Canvas.LineTo(Plot.Right, ZeroY);
    end;

    case FChartKind of
      mckBar:
        begin
          BarWidth := Max(4, Plot.Width div Max(1, Count * 2));
          for I := 0 to Count - 1 do
          begin
            X := Plot.Left + MulDiv((I * 2 + 1), Plot.Width, Count * 2);
            Y := ValueY(Values[I]);
            BarRect := Rect(X - BarWidth div 2, Min(Y, ZeroY),
              X + BarWidth div 2, Max(Y, ZeroY));
            if BarRect.Bottom = BarRect.Top then Inc(BarRect.Bottom);
            TMaxPainter.DrawSurface(Canvas, BarRect,
              TMaxPainter.BlendColor(TMaxTheme.Palette.Primary,
                TMaxTheme.Palette.PrimaryLight, Byte(Min(220, I * 28))),
              TMaxTheme.Palette.Primary, MaxScale(3, CurrentPPI), 1);
          end;
        end;

      mckLine:
        begin
          Canvas.Pen.Color := TMaxTheme.Palette.Primary;
          Canvas.Pen.Width := MaxScale(2, CurrentPPI);
          PrevX := 0;
          PrevY := 0;
          for I := 0 to Count - 1 do
          begin
            X := Plot.Left + MulDiv(I, Plot.Width, Max(1, Count - 1));
            Y := ValueY(Values[I]);
            if I > 0 then
            begin
              Canvas.MoveTo(PrevX, PrevY);
              Canvas.LineTo(X, Y);
            end;
            Canvas.Brush.Color := TMaxTheme.Palette.Surface;
            Canvas.Ellipse(X - 3, Y - 3, X + 4, Y + 4);
            PrevX := X;
            PrevY := Y;
          end;
        end;

      mckArea:
        begin
          SetLength(Points, Count + 2);
          Points[0] := Point(Plot.Left, ZeroY);
          for I := 0 to Count - 1 do
          begin
            X := Plot.Left + MulDiv(I, Plot.Width, Max(1, Count - 1));
            Y := ValueY(Values[I]);
            Points[I + 1] := Point(X, Y);
          end;
          Points[Count + 1] := Point(Plot.Right, ZeroY);
          Canvas.Brush.Color := TMaxPainter.BlendColor(
            TMaxTheme.Palette.Primary, clWhite, 125);
          Canvas.Pen.Color := TMaxTheme.Palette.Primary;
          Canvas.Pen.Width := MaxScale(2, CurrentPPI);
          Canvas.Polygon(Points);
        end;
    end;

    Save := SaveDC(Canvas.Handle);
    try
      Canvas.Font.Assign(Font);
      Canvas.Font.Size := 7;
      Canvas.Font.Color := TMaxTheme.Palette.TextSecondary;
      SetBkMode(Canvas.Handle, TRANSPARENT);
      for I := 0 to Count - 1 do
      begin
        X := Plot.Left + MulDiv(I, Plot.Width, Max(1, Count - 1));
        BarRect := Rect(X - MaxScale(24, CurrentPPI), Plot.Bottom + 3,
          X + MaxScale(24, CurrentPPI), Height - 2);
        DrawText(Canvas.Handle, PChar(Labels[I]), Length(Labels[I]), BarRect,
          DT_CENTER or DT_TOP or DT_SINGLELINE or DT_END_ELLIPSIS);
      end;
    finally
      RestoreDC(Canvas.Handle, Save);
    end;
  end
  else
  begin
    Total := 0;
    for I := 0 to Count - 1 do
      Total := Total + Max(0, Values[I]);
    CenterX := (Plot.Left + Plot.Right) div 2;
    CenterY := (Plot.Top + Plot.Bottom) div 2;
    Radius := Min(Plot.Width, Plot.Height) div 2 - MaxScale(4, CurrentPPI);
    BarRect := Rect(CenterX - Radius, CenterY - Radius,
      CenterX + Radius, CenterY + Radius);
    if Total <= 0 then
    begin
      Canvas.Brush.Color := TMaxTheme.Palette.Border;
      Canvas.Pen.Color := TMaxTheme.Palette.Border;
      Canvas.Ellipse(BarRect);
    end
    else
    begin
      Angle := -Pi / 2;
      for I := 0 to Count - 1 do
      begin
        NextAngle := Angle + 2 * Pi * Max(0, Values[I]) / Total;
        StartX := CenterX + Round(Cos(Angle) * Radius);
        StartY := CenterY + Round(Sin(Angle) * Radius);
        EndX := CenterX + Round(Cos(NextAngle) * Radius);
        EndY := CenterY + Round(Sin(NextAngle) * Radius);
        Canvas.Brush.Color := ChartColor(I);
        Canvas.Pen.Color := clWhite;
        Canvas.Pie(BarRect.Left, BarRect.Top, BarRect.Right, BarRect.Bottom,
          StartX, StartY, EndX, EndY);
        Angle := NextAngle;
      end;
    end;
    InnerRect := BarRect;
    InflateRect(InnerRect, -Radius div 2, -Radius div 2);
    Canvas.Brush.Color := TMaxTheme.Palette.Surface;
    Canvas.Pen.Color := TMaxTheme.Palette.Surface;
    Canvas.Ellipse(InnerRect);

    if FShowLegend then
    begin
      LegendRect := Rect(Plot.Right + MaxScale(10, CurrentPPI), Plot.Top,
        Width - MaxScale(4, CurrentPPI), Plot.Bottom);
      LegendY := LegendRect.Top;
      Save := SaveDC(Canvas.Handle);
      try
        Canvas.Font.Assign(Font);
        Canvas.Font.Size := 7;
        SetBkMode(Canvas.Handle, TRANSPARENT);
        for I := 0 to Count - 1 do
        begin
          Canvas.Brush.Color := ChartColor(I);
          Canvas.Pen.Color := ChartColor(I);
          Canvas.Rectangle(LegendRect.Left, LegendY + 3,
            LegendRect.Left + 8, LegendY + 11);
          S := Labels[I] + ' ' + FormatFloat('0.#', Values[I]);
          BarRect := Rect(LegendRect.Left + 12, LegendY,
            LegendRect.Right, LegendY + 16);
          Canvas.Font.Color := TMaxTheme.Palette.TextSecondary;
          DrawText(Canvas.Handle, PChar(S), Length(S), BarRect,
            DT_LEFT or DT_VCENTER or DT_SINGLELINE or DT_END_ELLIPSIS);
          Inc(LegendY, 18);
        end;
      finally
        RestoreDC(Canvas.Handle, Save);
      end;
    end;
  end;
end;

procedure TMaxChart.SetChartKind(const Value: TMaxChartKind);
begin
  if FChartKind = Value then Exit;
  FChartKind := Value;
  Invalidate;
end;

procedure TMaxChart.SetData(const Value: TStrings);
begin
  FData.Assign(Value);
end;

procedure TMaxChart.SetShowAxes(const Value: Boolean);
begin
  if FShowAxes = Value then Exit;
  FShowAxes := Value;
  Invalidate;
end;

procedure TMaxChart.SetShowLegend(const Value: Boolean);
begin
  if FShowLegend = Value then Exit;
  FShowLegend := Value;
  Invalidate;
end;

procedure TMaxChart.SetTitle(const Value: string);
begin
  if FTitle = Value then Exit;
  FTitle := Value;
  Invalidate;
end;

end.
