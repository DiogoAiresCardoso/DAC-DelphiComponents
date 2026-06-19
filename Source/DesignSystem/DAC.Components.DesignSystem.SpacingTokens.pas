unit DAC.Components.DesignSystem.SpacingTokens;

interface

type
  TDACSpacingTokens = record
    S4: Single;
    S8: Single;
    S12: Single;
    S16: Single;
    S24: Single;
    S32: Single;
    S40: Single;
    S48: Single;
    S64: Single;
    class function Default: TDACSpacingTokens; static;
  end;

implementation

class function TDACSpacingTokens.Default: TDACSpacingTokens;
begin
  Result.S4 := 4;
  Result.S8 := 8;
  Result.S12 := 12;
  Result.S16 := 16;
  Result.S24 := 24;
  Result.S32 := 32;
  Result.S40 := 40;
  Result.S48 := 48;
  Result.S64 := 64;
end;

end.

