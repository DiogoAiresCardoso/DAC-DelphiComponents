unit DAC.Components.Controls.Selectors;
{ Agregador de compatibilidade. Importe diretamente os units especificos:
  DAC.Components.Controls.CheckBox
  DAC.Components.Controls.RadioButton
  DAC.Components.Controls.ToggleSwitch
  DAC.Components.Controls.Slider }

interface

uses
  DAC.Components.Controls.CheckBox,
  DAC.Components.Controls.RadioButton,
  DAC.Components.Controls.ToggleSwitch,
  DAC.Components.Controls.Slider;

type
  TDACSelectorKind = DAC.Components.Controls.CheckBox.TDACSelectorKind;
  TDACSelector = DAC.Components.Controls.CheckBox.TDACSelector;
  TDACCheckBox = DAC.Components.Controls.CheckBox.TDACCheckBox;
  TDACRadioButton = DAC.Components.Controls.RadioButton.TDACRadioButton;
  TDACToggleSwitch = DAC.Components.Controls.ToggleSwitch.TDACToggleSwitch;
  TDACSlider = DAC.Components.Controls.Slider.TDACSlider;

implementation

end.
