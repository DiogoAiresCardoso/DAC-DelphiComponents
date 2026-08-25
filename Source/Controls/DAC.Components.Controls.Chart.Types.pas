unit DAC.Components.Controls.Chart.Types;

interface

uses
  System.UITypes,
  System.Types;

{$SCOPEDENUMS ON}

type
  TDACChartPoint = record
    X: Double;
    Y: Double;
    Label_: string;
  end;

  TDACChartSeriesData = record
    Name: string;
    Points: array of TDACChartPoint;
    Color: TAlphaColor;
  end;

  TDACChartOrientation = (Horizontal, Vertical);

  TDACChartLegendPosition = (Bottom, Right, Top, None);

  TDACChartAnimationMode = (None, Linear, EaseOut);

{$SCOPEDENUMS OFF}

implementation

end.
