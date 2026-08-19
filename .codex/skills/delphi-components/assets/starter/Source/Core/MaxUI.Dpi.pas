unit MaxUI.Dpi;

{$CODEPAGE 65001}

interface

uses
  System.Types;

const
  MaxUIDefaultPPI = 96;

function MaxNormalizePPI(const APPI: Integer): Integer;
function MaxScale(const AValue, APPI: Integer): Integer;
function MaxScaleF(const AValue: Single; const APPI: Integer): Single;
function MaxScalePoint(const APoint: TPoint; const APPI: Integer): TPoint;
function MaxScaleRect(const ARect: TRect; const APPI: Integer): TRect;

implementation

uses
  Winapi.Windows;

function MaxNormalizePPI(const APPI: Integer): Integer;
begin
  if APPI > 0 then
    Result := APPI
  else
    Result := MaxUIDefaultPPI;
end;

function MaxScale(const AValue, APPI: Integer): Integer;
begin
  Result := MulDiv(AValue, MaxNormalizePPI(APPI), MaxUIDefaultPPI);
end;

function MaxScaleF(const AValue: Single; const APPI: Integer): Single;
begin
  Result := AValue * MaxNormalizePPI(APPI) / MaxUIDefaultPPI;
end;

function MaxScalePoint(const APoint: TPoint; const APPI: Integer): TPoint;
begin
  Result := Point(MaxScale(APoint.X, APPI), MaxScale(APoint.Y, APPI));
end;

function MaxScaleRect(const ARect: TRect; const APPI: Integer): TRect;
begin
  Result := Rect(
    MaxScale(ARect.Left, APPI),
    MaxScale(ARect.Top, APPI),
    MaxScale(ARect.Right, APPI),
    MaxScale(ARect.Bottom, APPI)
  );
end;

end.
