unit DAC.Components.Controls.RadioButton;

interface

uses
  System.Classes,
  DAC.Components.Controls.CheckBox;

type
  TDACRadioButton = class(TDACSelector)
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Kind default mskRadioButton;
  end;

implementation

constructor TDACRadioButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Kind := mskRadioButton;
  Caption := 'RadioButton';
end;

end.
