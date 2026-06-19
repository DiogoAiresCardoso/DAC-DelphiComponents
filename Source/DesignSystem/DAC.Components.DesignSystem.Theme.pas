unit MaxxRural.Components.DesignSystem.Theme;

interface

uses
  MaxxRural.Components.DesignSystem.ChartPalette,
  MaxxRural.Components.DesignSystem.Metrics,
  MaxxRural.Components.DesignSystem.Tokens;

type
  IMaxxRuralComponentsTheme = interface
    ['{216C6F89-4EBE-4C7C-B521-50B9B9D47337}']
    function DisplayName: string;
    function Tokens: TMaxxRuralDesignTokens;
    function Metrics: TMaxxRuralComponentMetrics;
    function ChartPalette: TMaxxRuralChartPalette;
  end;

implementation

end.
