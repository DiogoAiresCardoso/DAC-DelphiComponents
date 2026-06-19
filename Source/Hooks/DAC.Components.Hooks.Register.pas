unit DAC.Components.Hooks.Register;

interface

procedure RegisterDACComponentStyleHooks;
procedure UnregisterDACComponentStyleHooks;

implementation

var
  GHooksRegistered: Boolean;

procedure RegisterDACComponentStyleHooks;
begin
  if GHooksRegistered then
    Exit;
  GHooksRegistered := True;
end;

procedure UnregisterDACComponentStyleHooks;
begin
  if not GHooksRegistered then
    Exit;
  GHooksRegistered := False;
end;

end.

