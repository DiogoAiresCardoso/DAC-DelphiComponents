unit DAC.Components.DesignSystem.Metrics;

interface

type
  TDACComponentMetrics = record
    MinTouchTarget: Single;
    BorderWidth: Single;
    FocusStrokeWidth: Single;
    DefaultControlHeight: Single;
    DefaultCardWidth: Single;
    DefaultCardHeight: Single;
    ButtonSmallHeight: Single;
    ButtonMediumHeight: Single;
    ButtonLargeHeight: Single;
    class function Default: TDACComponentMetrics; static;
  end;

implementation

class function TDACComponentMetrics.Default: TDACComponentMetrics;
begin
  Result.MinTouchTarget := 32;
  Result.BorderWidth := 1;
  Result.FocusStrokeWidth := 2;
  Result.DefaultControlHeight := 36;
  Result.DefaultCardWidth := 280;
  Result.DefaultCardHeight := 160;
  Result.ButtonSmallHeight := 32;
  Result.ButtonMediumHeight := 40;
  Result.ButtonLargeHeight := 48;
end;

end.

