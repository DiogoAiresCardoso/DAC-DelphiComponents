unit DAC.Components.DesignSystem.ControlTokens.Button;

{ Responsabilidade: tokens de design system para buttons. }

interface

uses
  System.UITypes,
  DAC.Components.DesignSystem.ControlTokens;

type
  TDACButtonTokens = record
    ButtonSmall: TDACControlSizeTokens;
    ButtonMedium: TDACControlSizeTokens;
    ButtonLarge: TDACControlSizeTokens;
    ButtonDefaultWidth: Single;
    ButtonDefaultHeight: Single;
    ButtonDefaultCornerRadius: Single;
    ButtonCompactCornerRadius: Single;
    ButtonRoundedCornerRadius: Single;
    ButtonMaximumIconSize: Integer;
    ButtonContentGap: Single;
    ButtonMinimumWidth: Single;
    ButtonPainterSnapScale: Single;
    ButtonPainterInset: Single;
    ButtonBorderWidth: Single;
    ButtonInputActionDividerWidth: Single;
    ButtonInputActionDividerVerticalInset: Single;
    ButtonInputActionCaptionTextSize: Single;
    ButtonInputActionCaptionRightInset: Single;
    ButtonCaptionBold: Boolean;
    ButtonCaptionMaxLines: Integer;
    ButtonAlphaOpaque: Byte;
    ButtonBorderAlphaNone: Byte;
    ButtonBorderAlphaGhostNormal: Byte;
    ButtonBorderAlphaGhostActive: Byte;
    ButtonBorderAlphaFull: Byte;
    ButtonFallbackBackground: TAlphaColor;
    ButtonCanvasBackground: TAlphaColor;
    ButtonInputActionCanvasBackground: TAlphaColor;
    ButtonTransparent: TAlphaColor;
    ButtonPrimaryBackground: TAlphaColor;
    ButtonPrimaryHoverBackground: TAlphaColor;
    ButtonPrimaryPressedBackground: TAlphaColor;
    ButtonPrimaryText: TAlphaColor;
    ButtonSecondaryBackground: TAlphaColor;
    ButtonSecondaryHoverBackground: TAlphaColor;
    ButtonSecondaryPressedBackground: TAlphaColor;
    ButtonSecondaryBorder: TAlphaColor;
    ButtonSecondaryHoverBorder: TAlphaColor;
    ButtonSecondaryText: TAlphaColor;
    ButtonInputActionText: TAlphaColor;
    ButtonInputActionDivider: TAlphaColor;
    ButtonTransparentText: TAlphaColor;
    ButtonGhostBackground: TAlphaColor;
    ButtonGhostActiveBackground: TAlphaColor;
    ButtonGhostBorder: TAlphaColor;
    ButtonGhostText: TAlphaColor;
    ButtonDangerBackground: TAlphaColor;
    ButtonDangerText: TAlphaColor;
    ButtonWarningBackground: TAlphaColor;
    ButtonWarningHoverBackground: TAlphaColor;
    ButtonWarningPressedBackground: TAlphaColor;
    ButtonWarningText: TAlphaColor;
    ButtonDisabledBackground: TAlphaColor;
    ButtonDisabledBorder: TAlphaColor;
    ButtonDisabledText: TAlphaColor;
    ButtonLoadingBackground: TAlphaColor;
    ButtonLoadingBorder: TAlphaColor;
    ButtonLoadingText: TAlphaColor;
    ButtonPrimary: TAlphaColor;
    ButtonPrimaryHover: TAlphaColor;
    ButtonPrimaryPressed: TAlphaColor;
    ButtonSecondary: TAlphaColor;
    ButtonGhostHover: TAlphaColor;
    ButtonTonal: TAlphaColor;
    ButtonTonalText: TAlphaColor;
    ButtonDanger: TAlphaColor;
    ButtonSuccess: TAlphaColor;
  end;

implementation

end.
