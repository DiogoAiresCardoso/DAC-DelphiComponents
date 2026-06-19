unit DAC.Components.DesignSystem.DefaultTheme;

interface

uses
  DAC.Components.DesignSystem.ChartPalette,
  DAC.Components.DesignSystem.Metrics,
  DAC.Components.DesignSystem.Theme,
  DAC.Components.DesignSystem.Tokens;

type
  TDACDefaultComponentsTheme = class(TInterfacedObject, IDACComponentsTheme)
  private
    FChartPalette: TDACChartPalette;
    FMetrics: TDACComponentMetrics;
    FTokens: TDACDesignTokens;
  public
    constructor Create;
    class function New: IDACComponentsTheme; static;
    function DisplayName: string;
    function Tokens: TDACDesignTokens;
    function Metrics: TDACComponentMetrics;
    function ChartPalette: TDACChartPalette;
  end;

implementation

constructor TDACDefaultComponentsTheme.Create;
begin
  inherited Create;
  FTokens := TDACDesignTokens.Default;
  FMetrics := TDACComponentMetrics.Default;
  FChartPalette := TDACChartPalette.Default;
end;

function TDACDefaultComponentsTheme.ChartPalette: TDACChartPalette;
begin
  Result := FChartPalette;
end;

function TDACDefaultComponentsTheme.DisplayName: string;
begin
  Result := 'NovoDAC Ancoragem';
end;

function TDACDefaultComponentsTheme.Metrics: TDACComponentMetrics;
begin
  Result := FMetrics;
end;

class function TDACDefaultComponentsTheme.New: IDACComponentsTheme;
begin
  Result := TDACDefaultComponentsTheme.Create;
end;

function TDACDefaultComponentsTheme.Tokens: TDACDesignTokens;
begin
  Result := FTokens;
end;

end.

