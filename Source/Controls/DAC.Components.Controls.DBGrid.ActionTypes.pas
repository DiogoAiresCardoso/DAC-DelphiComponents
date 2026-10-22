unit DAC.Components.Controls.DBGrid.ActionTypes;

interface

uses
  System.Types, System.Variants, Data.DB;

type
  TDACDBGridActionAppearance = (daaDefault, daaDanger);

  TDACDBGridRecordValue = record
    Name: string;
    Value: Variant;
  end;

  // Value snapshots only: no dataset, bookmark, field or record-buffer references.
  TDACDBGridActionContext = record
    ColumnKey: string;
    ActionId: string;
    Values: TArray<TDACDBGridRecordValue>;
    Keys: TArray<TDACDBGridRecordValue>;
    function ValueOf(const AName: string): Variant;
    function HasCompleteKey: Boolean;
    class function Capture(ADataSet: TDataSet; const AKeyFields,
      AColumnKey: string): TDACDBGridActionContext; static;
  end;

  TDACDBGridActionView = record
    ActionIndex: Integer;
    Bounds: TRect;
    Enabled: Boolean;
  end;

implementation

uses
  System.Classes, System.SysUtils;

function TDACDBGridActionContext.ValueOf(const AName: string): Variant;
var V: TDACDBGridRecordValue;
begin
  for V in Values do
    if SameText(V.Name, AName) then Exit(V.Value);
  Result := Null;
end;

function TDACDBGridActionContext.HasCompleteKey: Boolean;
var V: TDACDBGridRecordValue;
begin
  Result := Length(Keys) > 0;
  for V in Keys do
    if VarIsNull(V.Value) or VarIsEmpty(V.Value) then Exit(False);
end;

class function TDACDBGridActionContext.Capture(ADataSet: TDataSet;
  const AKeyFields, AColumnKey: string): TDACDBGridActionContext;
var I: Integer; Names: TStringList; Field: TField;
begin
  Result := Default(TDACDBGridActionContext);
  Result.ColumnKey := AColumnKey;
  if (ADataSet = nil) or not ADataSet.Active or ADataSet.IsEmpty then Exit;
  SetLength(Result.Values, ADataSet.FieldCount);
  for I := 0 to ADataSet.FieldCount - 1 do
  begin
    Result.Values[I].Name := ADataSet.Fields[I].FieldName;
    Result.Values[I].Value := ADataSet.Fields[I].Value;
  end;
  Names := TStringList.Create;
  try
    ExtractStrings([';', ','], [' '], PChar(AKeyFields), Names);
    SetLength(Result.Keys, Names.Count);
    for I := 0 to Names.Count - 1 do
    begin
      Result.Keys[I].Name := Names[I];
      Field := ADataSet.FindField(Names[I]);
      if Field = nil then Result.Keys[I].Value := Null
      else Result.Keys[I].Value := Field.Value;
    end;
  finally Names.Free; end;
end;

end.
