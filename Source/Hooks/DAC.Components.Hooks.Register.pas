unit MaxxRural.Components.Hooks.Register;

interface

procedure RegisterMaxxRuralComponentStyleHooks;
procedure UnregisterMaxxRuralComponentStyleHooks;

implementation

var
  GHooksRegistered: Boolean;

procedure RegisterMaxxRuralComponentStyleHooks;
begin
  if GHooksRegistered then
    Exit;
  GHooksRegistered := True;
end;

procedure UnregisterMaxxRuralComponentStyleHooks;
begin
  if not GHooksRegistered then
    Exit;
  GHooksRegistered := False;
end;

end.
