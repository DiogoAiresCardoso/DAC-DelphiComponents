unit MaxxRural.Components.Dpi;

interface

function MaxxRuralScale(const AValue, ACurrentPPI: Integer): Integer;
function MaxxRuralScaleF(const AValue, ACurrentPPI: Single): Single;
function MaxxRuralNormalizePPI(const APPI: Integer): Integer;

implementation

uses
  System.Math;

const
  MaxxRuralDefaultPPI = 96;

function MaxxRuralNormalizePPI(const APPI: Integer): Integer;
begin
  Result := APPI;
  if Result <= 0 then
    Result := MaxxRuralDefaultPPI;
end;

function MaxxRuralScale(const AValue, ACurrentPPI: Integer): Integer;
begin
  Result := Round(AValue * MaxxRuralNormalizePPI(ACurrentPPI) / MaxxRuralDefaultPPI);
end;

function MaxxRuralScaleF(const AValue, ACurrentPPI: Single): Single;
begin
  Result := AValue * Max(ACurrentPPI, MaxxRuralDefaultPPI) / MaxxRuralDefaultPPI;
end;

end.
