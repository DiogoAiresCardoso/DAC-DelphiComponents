unit DAC.Components.Dpi;

interface

function DACScale(const AValue, ACurrentPPI: Integer): Integer;
function DACScaleF(const AValue, ACurrentPPI: Single): Single;
function DACNormalizePPI(const APPI: Integer): Integer;

implementation

uses
  System.Math;

const
  DACDefaultPPI = 96;

function DACNormalizePPI(const APPI: Integer): Integer;
begin
  Result := APPI;
  if Result <= 0 then
    Result := DACDefaultPPI;
end;

function DACScale(const AValue, ACurrentPPI: Integer): Integer;
begin
  Result := Round(AValue * DACNormalizePPI(ACurrentPPI) / DACDefaultPPI);
end;

function DACScaleF(const AValue, ACurrentPPI: Single): Single;
begin
  Result := AValue * Max(ACurrentPPI, DACDefaultPPI) / DACDefaultPPI;
end;

end.

