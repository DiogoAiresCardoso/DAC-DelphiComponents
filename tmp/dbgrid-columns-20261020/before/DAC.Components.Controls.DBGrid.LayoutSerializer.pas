unit DAC.Components.Controls.DBGrid.LayoutSerializer;

interface

uses
  DAC.Components.Controls.DBGrid.Types;

type
  TDACDBGridLayoutSerializer = class
  public
    class function Deserialize(const AJSON: string;
      out ACatalog: TDACDBGridLayoutCatalog): Boolean; static;
    class function Serialize(const ACatalog: TDACDBGridLayoutCatalog): string;
      static;
  end;

implementation

uses
  System.JSON,
  System.SysUtils;

function JSONString(const AObject: TJSONObject; const AName: string): string;
var
  LValue: TJSONValue;
begin
  Result := '';
  LValue := AObject.GetValue(AName);
  if LValue <> nil then
    Result := LValue.Value;
end;

function JSONInteger(const AObject: TJSONObject; const AName: string;
  const ADefault: Integer): Integer;
begin
  Result := StrToIntDef(JSONString(AObject, AName), ADefault);
end;

function JSONBoolean(const AObject: TJSONObject; const AName: string;
  const ADefault: Boolean): Boolean;
var
  LValue: string;
begin
  LValue := JSONString(AObject, AName);
  if LValue = '' then
    Exit(ADefault);
  Result := SameText(LValue, 'true') or (LValue = '1');
end;

class function TDACDBGridLayoutSerializer.Deserialize(const AJSON: string;
  out ACatalog: TDACDBGridLayoutCatalog): Boolean;
var
  I: Integer;
  J: Integer;
  LColumn: TJSONObject;
  LColumns: TJSONArray;
  LEntries: TJSONArray;
  LEntry: TJSONObject;
  LRoot: TJSONValue;
  LRootObject: TJSONObject;
  LSortDirection: Integer;
begin
  ACatalog.Version := DACDBGridLayoutVersion;
  SetLength(ACatalog.Entries, 0);
  Result := False;
  if Trim(AJSON) = '' then
    Exit(True);
  LRoot := TJSONObject.ParseJSONValue(AJSON);
  try
    if not (LRoot is TJSONObject) then
      Exit;
    LRootObject := TJSONObject(LRoot);
    ACatalog.Version := JSONInteger(LRootObject, 'version',
      DACDBGridLayoutVersion);
    LEntries := LRootObject.GetValue('entries') as TJSONArray;
    if LEntries = nil then
      Exit(True);
    SetLength(ACatalog.Entries, LEntries.Count);
    for I := 0 to LEntries.Count - 1 do
    begin
      if not (LEntries.Items[I] is TJSONObject) then
        Exit(False);
      LEntry := TJSONObject(LEntries.Items[I]);
      ACatalog.Entries[I].Identity := JSONString(LEntry, 'identity');
      ACatalog.Entries[I].Snapshot.Version := JSONInteger(LEntry,
        'layoutVersion', DACDBGridLayoutVersion);
      ACatalog.Entries[I].Snapshot.SortKey := JSONString(LEntry, 'sortKey');
      LSortDirection := JSONInteger(LEntry, 'sortDirection', Ord(dgsNone));
      if (LSortDirection < Ord(Low(TDACDBGridSortDirection))) or
        (LSortDirection > Ord(High(TDACDBGridSortDirection))) then
        LSortDirection := Ord(dgsNone);
      ACatalog.Entries[I].Snapshot.SortDirection :=
        TDACDBGridSortDirection(LSortDirection);
      LColumns := LEntry.GetValue('columns') as TJSONArray;
      if LColumns = nil then
        Continue;
      SetLength(ACatalog.Entries[I].Snapshot.Columns, LColumns.Count);
      for J := 0 to LColumns.Count - 1 do
      begin
        if not (LColumns.Items[J] is TJSONObject) then
          Exit(False);
        LColumn := TJSONObject(LColumns.Items[J]);
        ACatalog.Entries[I].Snapshot.Columns[J].Key :=
          JSONString(LColumn, 'key');
        ACatalog.Entries[I].Snapshot.Columns[J].DisplayIndex :=
          JSONInteger(LColumn, 'index', J);
        ACatalog.Entries[I].Snapshot.Columns[J].LogicalWidth :=
          JSONInteger(LColumn, 'width', 64);
        ACatalog.Entries[I].Snapshot.Columns[J].Visible :=
          JSONBoolean(LColumn, 'visible', True);
      end;
    end;
    Result := True;
  finally
    LRoot.Free;
  end;
end;

class function TDACDBGridLayoutSerializer.Serialize(
  const ACatalog: TDACDBGridLayoutCatalog): string;
var
  I: Integer;
  J: Integer;
  LColumn: TJSONObject;
  LColumns: TJSONArray;
  LEntries: TJSONArray;
  LEntry: TJSONObject;
  LRoot: TJSONObject;
begin
  LRoot := TJSONObject.Create;
  try
    LRoot.AddPair('version', TJSONNumber.Create(DACDBGridLayoutVersion));
    LEntries := TJSONArray.Create;
    LRoot.AddPair('entries', LEntries);
    for I := 0 to Length(ACatalog.Entries) - 1 do
    begin
      LEntry := TJSONObject.Create;
      LEntries.AddElement(LEntry);
      LEntry.AddPair('identity', ACatalog.Entries[I].Identity);
      LEntry.AddPair('layoutVersion', TJSONNumber.Create(
        ACatalog.Entries[I].Snapshot.Version));
      LEntry.AddPair('sortKey', ACatalog.Entries[I].Snapshot.SortKey);
      LEntry.AddPair('sortDirection', TJSONNumber.Create(Ord(
        ACatalog.Entries[I].Snapshot.SortDirection)));
      LColumns := TJSONArray.Create;
      LEntry.AddPair('columns', LColumns);
      for J := 0 to Length(ACatalog.Entries[I].Snapshot.Columns) - 1 do
      begin
        LColumn := TJSONObject.Create;
        LColumns.AddElement(LColumn);
        LColumn.AddPair('key',
          ACatalog.Entries[I].Snapshot.Columns[J].Key);
        LColumn.AddPair('index', TJSONNumber.Create(
          ACatalog.Entries[I].Snapshot.Columns[J].DisplayIndex));
        LColumn.AddPair('width', TJSONNumber.Create(
          ACatalog.Entries[I].Snapshot.Columns[J].LogicalWidth));
        LColumn.AddPair('visible', TJSONBool.Create(
          ACatalog.Entries[I].Snapshot.Columns[J].Visible));
      end;
    end;
    Result := LRoot.ToJSON;
  finally
    LRoot.Free;
  end;
end;

end.
