unit DAC.Components.DesignSystem.ControlTokens.Selector;

{ Responsabilidade: tokens de design system para selectors. }

interface

uses
  System.UITypes,
  DAC.Components.DesignSystem.ControlTokens;

type
  TDACSelectorTokens = record
    SelectorDefaultWidth: Single;
    SelectorDefaultHeight: Single;
    ToggleDefaultWidth: Single;
    ToggleDefaultHeight: Single;
    SliderDefaultWidth: Single;
    SliderDefaultHeight: Single;
    SelectorToggleWidth: Single;
    SelectorToggleHeight: Single;
    SelectorToggleKnobOffset: Single;
    SelectorToggleKnobRadius: Single;
    SelectorRadioCenter: Single;
    SelectorRadioRadius: Single;
    SelectorRadioDotRadius: Single;
    SelectorCheckSize: Single;
    SelectorCheckRadius: Single;
    SelectorCheckInset: Single;
    SelectorTextOffset: Single;
    SelectorTextBaselineOffset: Single;
    SelectorTextSize: Single;
    SelectorStrokeWidth: Single;
    SelectorCheckedBorderWidth: Single;
    SelectorDisabledAlpha: Byte;
    SelectorHoverAlpha: Byte;
    SliderTrackLeft: Single;
    SliderTrackRightWithValue: Single;
    SliderTrackRightWithoutValue: Single;
    SliderTrackThickness: Single;
    SliderKnobRadius: Single;
    SliderValueRight: Single;
    SliderValueWidth: Single;
    SliderValueBaselineOffset: Single;
    SliderValueTextSize: Single;
    SliderTrackAlpha: Byte;
    SliderDisabledTrackAlpha: Byte;
    SliderDisabledAlpha: Byte;
    SliderHoverAlpha: Byte;
    SelectorTrack: TAlphaColor;
    SelectorTrackHover: TAlphaColor;
    SelectorControlBackground: TAlphaColor;
    SelectorBorder: TAlphaColor;
    SelectorText: TAlphaColor;
    SelectorDisabledText: TAlphaColor;
    SelectorKnob: TAlphaColor;
    SliderTrack: TAlphaColor;
    SliderText: TAlphaColor;
  end;

implementation

end.
