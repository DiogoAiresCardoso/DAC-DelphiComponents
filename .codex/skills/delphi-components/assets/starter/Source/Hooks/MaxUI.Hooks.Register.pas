unit MaxUI.Hooks.Register;

{$CODEPAGE 65001}

interface

procedure RegisterMaxUIHooks;
procedure UnregisterMaxUIHooks;
function MaxUIHooksRegistered: Boolean;

implementation

uses
  Vcl.Themes,
  MaxUI.Controls.Buttons,
  MaxUI.Controls.Inputs,
  MaxUI.Controls.Selectors,
  MaxUI.Controls.Choices,
  MaxUI.Hooks.Buttons,
  MaxUI.Hooks.Inputs,
  MaxUI.Hooks.Selectors,
  MaxUI.Hooks.Choices;

var
  GRegistered: Boolean;

procedure RegisterMaxUIHooks;
begin
  if GRegistered then Exit;
  TCustomStyleEngine.RegisterStyleHook(TMaxButton, TMaxButtonStyleHook);
  TCustomStyleEngine.RegisterStyleHook(TMaxEdit, TMaxEditStyleHook);
  TCustomStyleEngine.RegisterStyleHook(TMaxMaskedEdit, TMaxMaskedEditStyleHook);
  TCustomStyleEngine.RegisterStyleHook(TMaxMemo, TMaxMemoStyleHook);
  TCustomStyleEngine.RegisterStyleHook(TMaxComboBox, TMaxComboBoxStyleHook);
  TCustomStyleEngine.RegisterStyleHook(TMaxCheckBox, TMaxCheckBoxStyleHook);
  TCustomStyleEngine.RegisterStyleHook(TMaxRadioButton, TMaxRadioButtonStyleHook);
  GRegistered := True;
end;

procedure UnregisterMaxUIHooks;
begin
  if not GRegistered then Exit;
  TCustomStyleEngine.UnRegisterStyleHook(TMaxRadioButton, TMaxRadioButtonStyleHook);
  TCustomStyleEngine.UnRegisterStyleHook(TMaxCheckBox, TMaxCheckBoxStyleHook);
  TCustomStyleEngine.UnRegisterStyleHook(TMaxComboBox, TMaxComboBoxStyleHook);
  TCustomStyleEngine.UnRegisterStyleHook(TMaxMemo, TMaxMemoStyleHook);
  TCustomStyleEngine.UnRegisterStyleHook(TMaxMaskedEdit, TMaxMaskedEditStyleHook);
  TCustomStyleEngine.UnRegisterStyleHook(TMaxEdit, TMaxEditStyleHook);
  TCustomStyleEngine.UnRegisterStyleHook(TMaxButton, TMaxButtonStyleHook);
  GRegistered := False;
end;

function MaxUIHooksRegistered: Boolean;
begin
  Result := GRegistered;
end;

initialization
  RegisterMaxUIHooks;

finalization
  UnregisterMaxUIHooks;

end.
