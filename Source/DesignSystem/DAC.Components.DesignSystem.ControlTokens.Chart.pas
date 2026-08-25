unit DAC.Components.DesignSystem.ControlTokens.Chart;

{ Responsabilidade: tokens de design system para charts. }

interface

uses
  System.UITypes,
  DAC.Components.DesignSystem.ControlTokens;

type
  TDACChartTokens = record
    ChartDefaultWidth: Single;
    ChartDefaultHeight: Single;
    ChartRadius: Single;
    ChartBorderWidth: Single;
    ChartInsetLeft: Single;
    ChartInsetTop: Single;
    ChartInsetRight: Single;
    ChartInsetBottom: Single;
    ChartGridLines: Integer;
    ChartGridAlpha: Byte;
    ChartLineWidth: Single;
    ChartPointRadius: Single;
    ChartBarGap: Single;
    ChartBarMinWidth: Single;
    ChartBarRadius: Single;
    ChartAreaAlpha: Byte;
    ChartDoughnutThickness: Single;
    ChartDoughnutGap: Single;
    ChartDoughnutStartAngle: Single;
    ChartFullCircleDegrees: Single;
    ChartAccent: TAlphaColor;
    ChartAccentStrong: TAlphaColor;
    ChartGrid: TAlphaColor;
    ChartDashboardBackground: TAlphaColor;
    ChartDashboardBorder: TAlphaColor;
  end;

implementation

end.
