unit DAC.Components.DesignSystem.RadiusTokens;

interface

type
  TDACRadiusTokens = record
    R4: Single;
    R8: Single;
    R10: Single;
    R16: Single;
    CardBorderWidth: Single;
    class function Default: TDACRadiusTokens; static;
  end;

implementation

class function TDACRadiusTokens.Default: TDACRadiusTokens;
begin
  Result.R4 := 4;
  Result.R8 := 8;
  Result.R10 := 10;
  Result.R16 := 16;
  Result.CardBorderWidth := 1.2;
end;

end.

