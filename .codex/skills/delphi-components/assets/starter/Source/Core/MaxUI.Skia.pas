unit MaxUI.Skia;

{$CODEPAGE 65001}

interface

function MaxUISkiaCompiled: Boolean;

implementation

uses
  System.Skia,
  Vcl.Skia;

function MaxUISkiaCompiled: Boolean;
begin
  Result := True;
end;

end.
