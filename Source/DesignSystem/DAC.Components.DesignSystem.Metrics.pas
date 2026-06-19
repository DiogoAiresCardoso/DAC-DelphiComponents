unit MaxxRural.Components.DesignSystem.Metrics;

interface

type
  TMaxxRuralComponentMetrics = record
    MinTouchTarget: Single;
    BorderWidth: Single;
    FocusStrokeWidth: Single;
    DefaultControlHeight: Single;
    DefaultCardWidth: Single;
    DefaultCardHeight: Single;
    class function Default: TMaxxRuralComponentMetrics; static;
  end;

implementation

class function TMaxxRuralComponentMetrics.Default: TMaxxRuralComponentMetrics;
begin
  Result.MinTouchTarget := 32;
  Result.BorderWidth := 1;
  Result.FocusStrokeWidth := 2;
  Result.DefaultControlHeight := 36;
  Result.DefaultCardWidth := 280;
  Result.DefaultCardHeight := 160;
end;

end.
