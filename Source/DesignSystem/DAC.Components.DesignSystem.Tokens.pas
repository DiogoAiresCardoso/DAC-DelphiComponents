unit MaxxRural.Components.DesignSystem.Tokens;

interface

uses
  MaxxRural.Components.DesignSystem.CardTokens,
  MaxxRural.Components.DesignSystem.ColorTokens,
  MaxxRural.Components.DesignSystem.InteractionTokens,
  MaxxRural.Components.DesignSystem.OpacityTokens,
  MaxxRural.Components.DesignSystem.RadiusTokens,
  MaxxRural.Components.DesignSystem.SpacingTokens,
  MaxxRural.Components.DesignSystem.TypographyTokens;

type
  TMaxxRuralDesignTokens = record
    Colors: TMaxxRuralColorTokens;
    Opacities: TMaxxRuralOpacityTokens;
    Typography: TMaxxRuralTypographyTokens;
    Spacing: TMaxxRuralSpacingTokens;
    Radius: TMaxxRuralRadiusTokens;
    Interactions: TMaxxRuralInteractionTokens;
    Card: TMaxxRuralCardTokens;
    class function Default: TMaxxRuralDesignTokens; static;
  end;

implementation

class function TMaxxRuralDesignTokens.Default: TMaxxRuralDesignTokens;
begin
  Result.Colors := TMaxxRuralColorTokens.Default;
  Result.Opacities := TMaxxRuralOpacityTokens.Default;
  Result.Typography := TMaxxRuralTypographyTokens.Default;
  Result.Spacing := TMaxxRuralSpacingTokens.Default;
  Result.Radius := TMaxxRuralRadiusTokens.Default;
  Result.Interactions := TMaxxRuralInteractionTokens.Default;
  Result.Card := TMaxxRuralCardTokens.Default;
end;

end.
