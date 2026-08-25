unit DAC.Components.Controls.ToggleSwitch;

interface

uses
  System.Classes,
  DAC.Components.Controls.CheckBox;

type
  TDACToggleSwitch = class(TDACSelector)
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Kind default mskToggleSwitch;
  end;

implementation

uses
  DAC.Components.DesignSystem.ComponentStyle,
  DAC.Components.DesignSystem.Theme;

constructor TDACToggleSwitch.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Kind := mskToggleSwitch;
  Caption := 'Toggle Switch';
  Width := Round(TDACComponentStyle.Resolve(dtmInherit).Tokens.Controls.ToggleDefaultWidth);
  Height := Round(TDACComponentStyle.Resolve(dtmInherit).Tokens.Controls.ToggleDefaultHeight);
end;

end.
