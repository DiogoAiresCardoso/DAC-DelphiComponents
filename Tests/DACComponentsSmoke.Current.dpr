program DACComponentsSmokeCurrent;

{$APPTYPE CONSOLE}
{$MINSTACKSIZE $00200000}

uses
  System.Classes,
  System.SysUtils,
  Vcl.Controls,
  DAC.Components.Controls.ButtonEdit,
  DAC.Components.Controls.CheckBox,
  DAC.Components.Controls.ComboBox,
  DAC.Components.Controls.Container,
  DAC.Components.Controls.DateTimePicker,
  DAC.Components.Controls.Edit,
  DAC.Components.Controls.NumericEdit,
  DAC.Components.Controls.Memo,
  DAC.Components.Controls.RadioButton,
  DAC.Components.Controls.Register,
  DAC.Components.Controls.Slider,
  DAC.Components.Controls.ToggleSwitch;

procedure Require(const ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create(AMessage);
end;

procedure SmokeClass(const AClass: TComponentClass);
var
  LComponent: TComponent;
begin
  Writeln('SmokeClass: ', AClass.ClassName);
  LComponent := AClass.Create(nil);
  try
    Require(LComponent <> nil, AClass.ClassName + ' nao foi criado.');
    if LComponent is TWinControl then
      Require(not TWinControl(LComponent).HandleAllocated,
        AClass.ClassName + ' criou HWND com Parent=nil.');
  finally
    LComponent.Free;
  end;
end;

begin
  try
    RegisterDACComponentClasses;
    Require(GetClass('TDACEdit') = TDACEdit, 'TDACEdit ausente do registry.');
    Require(GetClass('TDACNumericEdit') = TDACNumericEdit,
      'TDACNumericEdit ausente do registry.');
    Require(GetClass('TDACDateTimePicker') = TDACDateTimePicker,
      'TDACDateTimePicker ausente do registry.');
    Require(GetClass('TDACCheckBox') = TDACCheckBox,
      'TDACCheckBox ausente do registry.');
    SmokeClass(TDACContainer);
    SmokeClass(TDACEdit);
    SmokeClass(TDACNumericEdit);
    SmokeClass(TDACMemo);
    SmokeClass(TDACComboBox);
    SmokeClass(TDACButtonEdit);
    SmokeClass(TDACDateTimePicker);
    SmokeClass(TDACCheckBox);
    SmokeClass(TDACRadioButton);
    SmokeClass(TDACToggleSwitch);
    SmokeClass(TDACSlider);
    Writeln('DACComponentsSmoke: PASS');
    ExitCode := 0;
  except
    on E: Exception do
    begin
      Writeln('DACComponentsSmoke: FAIL: ', E.ClassName, ': ', E.Message);
      ExitCode := 1;
    end;
  end;
end.
