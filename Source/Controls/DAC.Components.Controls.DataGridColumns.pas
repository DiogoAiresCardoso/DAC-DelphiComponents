unit DAC.Components.Controls.DataGridColumns;

interface

uses
  System.Classes,
  Data.DB,
  Vcl.DBGrids;

type
  { Keeps the data-grid's visual column enumeration aligned with TDBGrid.
    A TDBGrid only creates TColumn instances when columns are persisted; when
    it is in automatic-column mode, its visible TField list is the source of
    truth. }
  TDACDataGridColumnResolver = class
  public
    class function Count(const AGrid: TCustomDBGrid): Integer; static;
    class function ColumnAt(const AGrid: TCustomDBGrid;
      const AIndex: Integer): TColumn; static;
    class function FieldAt(const AGrid: TCustomDBGrid;
      const AIndex: Integer): TField; static;
  end;

implementation

type
  TCustomDBGridAccess = class(TCustomDBGrid)
  public
    function PersistentColumnCount: Integer;
    function PersistentColumnAt(const AIndex: Integer): TColumn;
    function VisibleFieldCount: Integer;
    function VisibleFieldAt(const AIndex: Integer): TField;
  end;

function TCustomDBGridAccess.VisibleFieldCount: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to FieldCount - 1 do
    if Fields[I].Visible then
      Inc(Result);
end;

function TCustomDBGridAccess.PersistentColumnCount: Integer;
begin
  Result := Columns.Count;
end;

function TCustomDBGridAccess.PersistentColumnAt(const AIndex: Integer): TColumn;
begin
  Result := nil;
  if (AIndex >= 0) and (AIndex < Columns.Count) then
    Result := Columns[AIndex];
end;

function TCustomDBGridAccess.VisibleFieldAt(const AIndex: Integer): TField;
var
  I: Integer;
  LVisibleIndex: Integer;
begin
  Result := nil;
  LVisibleIndex := 0;
  for I := 0 to FieldCount - 1 do
    if Fields[I].Visible then
    begin
      if LVisibleIndex = AIndex then
        Exit(Fields[I]);
      Inc(LVisibleIndex);
    end;
end;

class function TDACDataGridColumnResolver.ColumnAt(const AGrid: TCustomDBGrid;
  const AIndex: Integer): TColumn;
begin
  Result := nil;
  if AGrid <> nil then
    Result := TCustomDBGridAccess(AGrid).PersistentColumnAt(AIndex);
end;

class function TDACDataGridColumnResolver.Count(const AGrid: TCustomDBGrid): Integer;
begin
  if AGrid = nil then
    Exit(0);
  if TCustomDBGridAccess(AGrid).PersistentColumnCount > 0 then
    Exit(TCustomDBGridAccess(AGrid).PersistentColumnCount);
  Result := TCustomDBGridAccess(AGrid).VisibleFieldCount;
end;

class function TDACDataGridColumnResolver.FieldAt(const AGrid: TCustomDBGrid;
  const AIndex: Integer): TField;
var
  LColumn: TColumn;
begin
  Result := nil;
  if (AGrid = nil) or (AIndex < 0) then
    Exit;
  LColumn := ColumnAt(AGrid, AIndex);
  if LColumn <> nil then
    Exit(LColumn.Field);
  Result := TCustomDBGridAccess(AGrid).VisibleFieldAt(AIndex);
end;

end.
