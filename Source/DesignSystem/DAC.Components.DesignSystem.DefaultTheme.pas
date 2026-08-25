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
    constructor Create(const AMode: TDACThemeMode);
    class function New: IDACComponentsTheme; static;
    class function NewForMode(const AMode: TDACThemeMode): IDACComponentsTheme; static;
    function DisplayName: string;
    function Tokens: TDACDesignTokens;
    function Metrics: TDACComponentMetrics;
    function ChartPalette: TDACChartPalette;
  end;

implementation

constructor TDACDefaultComponentsTheme.Create(const AMode: TDACThemeMode);
begin
  inherited Create;
  if AMode = dtmLight then
    FTokens := TDACDesignTokens.Light
  else
    FTokens := TDACDesignTokens.Dark;
  FMetrics := TDACComponentMetrics.Default;
  if AMode = dtmLight then
    FChartPalette := TDACChartPalette.Light
  else
    FChartPalette := TDACChartPalette.Dark;
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
  Result := NewForMode(dtmDark);
end;

class function TDACDefaultComponentsTheme.NewForMode(
  const AMode: TDACThemeMode): IDACComponentsTheme;
begin
  Result := TDACDefaultComponentsTheme.Create(AMode);
end;

function TDACDefaultComponentsTheme.Tokens: TDACDesignTokens;
begin
  Result := FTokens;
end;

end.

