unit DAC.Components.DesignSystem.Tokens;

interface

uses
  DAC.Components.DesignSystem.CardTokens,
  DAC.Components.DesignSystem.ColorTokens,
  DAC.Components.DesignSystem.ControlTokens,
  DAC.Components.DesignSystem.DashboardTokens,
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
    Controls: TDACControlTokens;
    Dashboard: TDACDashboardTokens;
    class function Default: TDACDesignTokens; static;
    class function Dark: TDACDesignTokens; static;
    class function Light: TDACDesignTokens; static;
  end;

implementation

class function TDACDesignTokens.Default: TDACDesignTokens;
begin
  Result := Dark;
end;

class function TDACDesignTokens.Dark: TDACDesignTokens;
begin
  Result.Colors := TDACColorTokens.Default;
  Result.Opacities := TDACOpacityTokens.Default;
  Result.Typography := TDACTypographyTokens.Default;
  Result.Spacing := TDACSpacingTokens.Default;
  Result.Radius := TDACRadiusTokens.Default;
  Result.Interactions := TDACInteractionTokens.Default;
  Result.Card := TDACCardTokens.Default;
  Result.Controls := TDACControlTokens.Dark;
  Result.Dashboard := TDACDashboardTokens.Dark;
  Result.Colors.ControlBackground := Result.Controls.InputBackground;
  Result.Colors.ControlBackgroundDisabled := Result.Controls.InputDisabledBackground;
  Result.Colors.ControlBorder := Result.Controls.InputBorder;
  Result.Colors.ControlBorderHover := Result.Controls.InputBorderHover;
  Result.Colors.ControlText := Result.Controls.InputText;
  Result.Colors.ControlTextDisabled := Result.Controls.InputDisabledText;
  Result.Colors.Primary := Result.Controls.ButtonPrimary;
  Result.Colors.PrimaryDark := Result.Controls.ButtonPrimaryPressed;
  Result.Colors.PrimaryFocus := Result.Controls.InputFocus;
  Result.Colors.Danger := Result.Controls.ButtonDanger;
end;

class function TDACDesignTokens.Light: TDACDesignTokens;
begin
  Result := Dark;
  Result.Controls := TDACControlTokens.Light;
  Result.Dashboard := TDACDashboardTokens.Light;
  Result.Colors.ControlBackground := Result.Controls.InputBackground;
  Result.Colors.ControlBackgroundDisabled := Result.Controls.InputDisabledBackground;
  Result.Colors.ControlBorder := Result.Controls.InputBorder;
  Result.Colors.ControlBorderHover := Result.Controls.InputBorderHover;
  Result.Colors.ControlText := Result.Controls.InputText;
  Result.Colors.ControlTextDisabled := Result.Controls.InputDisabledText;
end;

end.

