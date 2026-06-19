unit DAC.Components.DesignSystem.Theme;

interface

uses
  DAC.Components.DesignSystem.ChartPalette,
  DAC.Components.DesignSystem.Metrics,
  DAC.Components.DesignSystem.Tokens;

type
  IDACComponentsTheme = interface
    ['{216C6F89-4EBE-4C7C-B521-50B9B9D47337}']
    function DisplayName: string;
    function Tokens: TDACDesignTokens;
    function Metrics: TDACComponentMetrics;
    function ChartPalette: TDACChartPalette;
  end;

implementation

end.

