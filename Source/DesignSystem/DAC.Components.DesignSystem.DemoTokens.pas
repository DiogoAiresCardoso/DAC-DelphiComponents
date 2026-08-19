unit DAC.Components.DesignSystem.DemoTokens;

interface

type
  { Declarative geometry used exclusively by the runtime demonstration shell.
    Component rendering dimensions stay in ControlTokens; this record prevents
    the demo composition from introducing a second, scattered scale. }
  TDACDemoTokens = record
  public
    NavigationWidth: Integer;
    NavigationCompactWidth: Integer;
    NavigationCompactBreakpoint: Integer;
    NavigationPadding: Integer;
    NavigationTitleTop: Integer;
    NavigationTitleHeight: Integer;
    NavigationFirstButtonTop: Integer;
    NavigationButtonHeight: Integer;
    NavigationGutter: Integer;
    ContentHorizontalMargin: Integer;
    InputTitleToFieldGap: Integer;
    InputFieldToFieldGap: Integer;
    GridCodeColumnWidth: Integer;
    GridClientColumnWidth: Integer;
    GridCityColumnWidth: Integer;
    GridStatusColumnWidth: Integer;
    GridValueColumnWidth: Integer;
    GridDateColumnWidth: Integer;
    GridActionsColumnWidth: Integer;
    GridDensityFirstLeft: Integer;
    GridDensityStep: Integer;
    GridDensityButtonWidth: Integer;
    class function Default: TDACDemoTokens; static;
  end;

implementation

class function TDACDemoTokens.Default: TDACDemoTokens;
begin
  Result.NavigationWidth := 208;
  Result.NavigationCompactWidth := 96;
  Result.NavigationCompactBreakpoint := 760;
  Result.NavigationPadding := 16;
  Result.NavigationTitleTop := 12;
  Result.NavigationTitleHeight := 32;
  Result.NavigationFirstButtonTop := 56;
  Result.NavigationButtonHeight := 38;
  Result.NavigationGutter := 8;
  Result.ContentHorizontalMargin := 24;
  Result.InputTitleToFieldGap := 48;
  Result.InputFieldToFieldGap := 56;
  Result.GridCodeColumnWidth := 76;
  Result.GridClientColumnWidth := 210;
  Result.GridCityColumnWidth := 170;
  Result.GridStatusColumnWidth := 108;
  Result.GridValueColumnWidth := 108;
  Result.GridDateColumnWidth := 104;
  Result.GridActionsColumnWidth := 132;
  Result.GridDensityFirstLeft := 704;
  Result.GridDensityStep := 76;
  Result.GridDensityButtonWidth := 68;
end;

end.
