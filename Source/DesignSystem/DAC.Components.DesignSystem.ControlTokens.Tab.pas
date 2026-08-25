unit DAC.Components.DesignSystem.ControlTokens.Tab;

{ Responsabilidade: tokens de design system para tabs. }

interface

uses
  System.UITypes,
  DAC.Components.DesignSystem.ControlTokens;

type
  TDACTabTokens = record
    TabsDefaultWidth: Single;
    TabsDefaultHeight: Single;
    TabsSmall: TDACControlSizeTokens;
    TabsMedium: TDACControlSizeTokens;
    TabsLarge: TDACControlSizeTokens;
    TabsHeaderRadius: Single;
    TabsPillRadius: Single;
    TabsUnderlineRadius: Single;
    TabsUnderlineThickness: Single;
    TabsCaptionInset: Single;
    TabsFocusRadius: Single;
    TabsHeaderInset: Single;
    TabsHeaderCrossInset: Single;
    TabsUnderlineInset: Single;
    TabsVerticalMinItem: Single;
    TabsHorizontalMinItem: Single;
    TabsVerticalExtent: Single;
    TabsHorizontalExtent: Single;
    TabsItemGap: Single;
    TabsDividerWidth: Single;
    TabsIndicatorWidth: Single;
    TabsFocusWidth: Single;
    TabsContentGutter: Single;
    TabsContentInset: Single;
    TabsContentRadius: Single;
    TabsSurface: TAlphaColor;
    TabsDivider: TAlphaColor;
    TabsTextDefault: TAlphaColor;
    TabsTextHover: TAlphaColor;
    TabsTextActive: TAlphaColor;
    TabsTextDisabled: TAlphaColor;
    TabsHoverBackground: TAlphaColor;
    TabsActiveBackground: TAlphaColor;
    TabsIndicator: TAlphaColor;
    TabsFocus: TAlphaColor;
  end;

implementation

end.
