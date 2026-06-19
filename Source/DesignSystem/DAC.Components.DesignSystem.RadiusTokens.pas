unit MaxxRural.Components.DesignSystem.RadiusTokens;

interface

type
  TMaxxRuralRadiusTokens = record
    R4: Single;
    R8: Single;
    R10: Single;
    R16: Single;
    CardBorderWidth: Single;
    class function Default: TMaxxRuralRadiusTokens; static;
  end;

implementation

class function TMaxxRuralRadiusTokens.Default: TMaxxRuralRadiusTokens;
begin
  Result.R4 := 4;
  Result.R8 := 8;
  Result.R10 := 10;
  Result.R16 := 16;
  Result.CardBorderWidth := 1.2;
end;

end.
