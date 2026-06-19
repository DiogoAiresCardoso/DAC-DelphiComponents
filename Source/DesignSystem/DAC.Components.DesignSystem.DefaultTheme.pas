unit MaxxRural.Components.DesignSystem.DefaultTheme;

interface

uses
  MaxxRural.Components.DesignSystem.ChartPalette,
  MaxxRural.Components.DesignSystem.Metrics,
  MaxxRural.Components.DesignSystem.Theme,
  MaxxRural.Components.DesignSystem.Tokens;

type
  TMaxxRuralDefaultComponentsTheme = class(TInterfacedObject, IMaxxRuralComponentsTheme)
  private
    FChartPalette: TMaxxRuralChartPalette;
    FMetrics: TMaxxRuralComponentMetrics;
    FTokens: TMaxxRuralDesignTokens;
  public
    constructor Create;
    class function New: IMaxxRuralComponentsTheme; static;
    function DisplayName: string;
    function Tokens: TMaxxRuralDesignTokens;
    function Metrics: TMaxxRuralComponentMetrics;
    function ChartPalette: TMaxxRuralChartPalette;
  end;

implementation

constructor TMaxxRuralDefaultComponentsTheme.Create;
begin
  inherited Create;
  FTokens := TMaxxRuralDesignTokens.Default;
  FMetrics := TMaxxRuralComponentMetrics.Default;
  FChartPalette := TMaxxRuralChartPalette.Default;
end;

function TMaxxRuralDefaultComponentsTheme.ChartPalette: TMaxxRuralChartPalette;
begin
  Result := FChartPalette;
end;

function TMaxxRuralDefaultComponentsTheme.DisplayName: string;
begin
  Result := 'NovoMaxxRural Ancoragem';
end;

function TMaxxRuralDefaultComponentsTheme.Metrics: TMaxxRuralComponentMetrics;
begin
  Result := FMetrics;
end;

class function TMaxxRuralDefaultComponentsTheme.New: IMaxxRuralComponentsTheme;
begin
  Result := TMaxxRuralDefaultComponentsTheme.Create;
end;

function TMaxxRuralDefaultComponentsTheme.Tokens: TMaxxRuralDesignTokens;
begin
  Result := FTokens;
end;

end.
