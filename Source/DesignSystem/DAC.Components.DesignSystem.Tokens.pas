unit DAC.Components.DesignSystem.Tokens;

interface

uses
  DAC.Components.DesignSystem.CardTokens,
  DAC.Components.DesignSystem.ColorTokens,
  DAC.Components.DesignSystem.InteractionTokens,
  DAC.Components.DesignSystem.OpacityTokens,
  DAC.Components.DesignSystem.RadiusTokens,
  DAC.Components.DesignSystem.SpacingTokens,
  DAC.Components.DesignSystem.TypographyTokens;

type
  TDACDesignTokens = record
    Colors: TDACColorTokens;
    Opacities: TDACOpacityTokens;
    Typography: TDACTypographyTokens;
    Spacing: TDACSpacingTokens;
    Radius: TDACRadiusTokens;
    Interactions: TDACInteractionTokens;
    Card: TDACCardTokens;
    class function Default: TDACDesignTokens; static;
  end;

implementation

class function TDACDesignTokens.Default: TDACDesignTokens;
begin
  Result.Colors := TDACColorTokens.Default;
  Result.Opacities := TDACOpacityTokens.Default;
  Result.Typography := TDACTypographyTokens.Default;
  Result.Spacing := TDACSpacingTokens.Default;
  Result.Radius := TDACRadiusTokens.Default;
  Result.Interactions := TDACInteractionTokens.Default;
  Result.Card := TDACCardTokens.Default;
end;

end.

