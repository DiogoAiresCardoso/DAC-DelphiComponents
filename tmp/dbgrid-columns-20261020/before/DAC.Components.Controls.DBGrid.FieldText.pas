unit DAC.Components.Controls.DBGrid.FieldText;

interface

uses
  Data.DB;

type
  TDACDBGridFieldTextResolver = class sealed
  private
    class function IsNumericField(const AField: TField): Boolean; static;
    class function IsTextualBlob(const AField: TField): Boolean; static;
    class function NormalizeNegativeSign(const AField: TField;
      const AValue: string): string; static;
    class function NormalizeSingleLine(const AValue: string): string; static;
  public
    class function Resolve(const AField: TField): string; static;
  end;

implementation

uses
  System.SysUtils;

class function TDACDBGridFieldTextResolver.IsNumericField(
  const AField: TField): Boolean;
begin
  Result := (AField <> nil) and (AField.DataType in
    [ftSmallint, ftInteger, ftWord, ftFloat, ftCurrency, ftBCD, ftAutoInc,
     ftLargeint, ftFMTBcd, ftLongWord, ftShortint, ftByte, ftExtended,
     ftSingle]);
end;

class function TDACDBGridFieldTextResolver.IsTextualBlob(
  const AField: TField): Boolean;
begin
  Result := (AField <> nil) and (AField.DataType in
    [ftMemo, ftFmtMemo, ftWideMemo, ftOraClob]);
end;

class function TDACDBGridFieldTextResolver.NormalizeSingleLine(
  const AValue: string): string;
begin
  Result := StringReplace(AValue, #13#10, ' ', [rfReplaceAll]);
  Result := StringReplace(Result, #13, ' ', [rfReplaceAll]);
  Result := StringReplace(Result, #10, ' ', [rfReplaceAll]);
  Result := StringReplace(Result, #9, ' ', [rfReplaceAll]);
  Result := Trim(Result);
end;

class function TDACDBGridFieldTextResolver.NormalizeNegativeSign(
  const AField: TField; const AValue: string): string;
var
  LUnsignedText: string;
begin
  Result := AValue;
  if not IsNumericField(AField) or (Length(AValue) < 2) or
     (AValue[Length(AValue)] <> '-') or (AValue[1] = '-') then
    Exit;

  { Some regional numeric formats place the negative sign after the value.
    Normalize only the grid presentation; the field value and DisplayFormat
    remain untouched. }
  LUnsignedText := TrimRight(Copy(AValue, 1, Length(AValue) - 1));
  if LUnsignedText <> '' then
    Result := '-' + LUnsignedText;
end;

class function TDACDBGridFieldTextResolver.Resolve(
  const AField: TField): string;
begin
  Result := '';
  if (AField = nil) or AField.IsNull then
    Exit;

  if IsTextualBlob(AField) then
  begin
    { TBlobField.DisplayText intentionally returns markers such as "(MEMO)".
      Preserve an explicit OnGetText formatter; otherwise read the textual
      value from the active DBGrid buffer record. }
    if Assigned(AField.OnGetText) then
      Result := AField.DisplayText
    else
      Result := AField.AsString;
  end
  else
    Result := AField.DisplayText;

  Result := NormalizeSingleLine(Result);
  Result := NormalizeNegativeSign(AField, Result);
end;

end.
