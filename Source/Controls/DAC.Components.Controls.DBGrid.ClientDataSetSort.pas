unit DAC.Components.Controls.DBGrid.ClientDataSetSort;

interface

uses
  Data.DB, Datasnap.DBClient, DAC.Components.Controls.DBGrid.Types;

type
  // Optional local-buffer adapter. The grid runtime remains dataset-agnostic.
  TDACDBGridClientDataSetSort = class
  public
    class function Apply(ADataSet: TClientDataSet; const AFieldName: string;
      const ADirection: TDACDBGridSortDirection;
      const AKeyFields: string = ''): Boolean; static;
  end;

implementation

uses System.Classes, System.SysUtils,
  DAC.Components.Controls.DBGrid.ClientDataSetSortSource;

class function TDACDBGridClientDataSetSort.Apply(ADataSet: TClientDataSet;
  const AFieldName: string; const ADirection: TDACDBGridSortDirection;
  const AKeyFields: string): Boolean;
var
  Field, KeyField: TField;
  Names: TStringList;
  Name, Fields, DescFields, CaseFields, IndexName: string;
  Bookmark: TBookmark;
  I: Integer;
  Id: TGUID;
  Index: TIndexDef;
  HasSource: Boolean;
begin
  Result := False;
  if (ADataSet = nil) or not ADataSet.Active or
    (ADataSet.State <> dsBrowse) then Exit;
  Field := ADataSet.FindField(AFieldName);
  if (Field = nil) or Field.IsBlob or (Field.FieldKind <> fkData) then Exit;
  HasSource := False;
  for I := 0 to ADataSet.ComponentCount - 1 do
    if ADataSet.Components[I] is TDACDBGridClientDataSetSortSource then
    begin HasSource := True; Break; end;
  if not HasSource then TDACDBGridClientDataSetSortSource.Create(ADataSet);
  Fields := Field.FieldName;
  DescFields := '';
  CaseFields := '';
  if ADirection = dgsDescending then DescFields := Fields;
  if Field.DataType in [ftString, ftWideString, ftFixedChar, ftFixedWideChar] then
    CaseFields := Fields;
  Names := TStringList.Create;
  try
    Names.CaseSensitive := False;
    ExtractStrings([';', ','], [' '], PChar(AKeyFields), Names);
    for Name in Names do
    begin
      KeyField := ADataSet.FindField(Name);
      if (KeyField <> nil) and not KeyField.IsBlob and
        (KeyField.FieldKind = fkData) and
        (Pos(';' + UpperCase(KeyField.FieldName) + ';', ';' + UpperCase(Fields) + ';') = 0) then
        Fields := Fields + ';' + KeyField.FieldName;
    end;
  finally Names.Free; end;
  Bookmark := nil;
  if not ADataSet.IsEmpty then Bookmark := ADataSet.GetBookmark;
  ADataSet.DisableControls;
  try
    if ADirection = dgsNone then ADataSet.IndexName := ''
    else
    begin
      ADataSet.IndexDefs.Update;
      IndexName := '';
      for I := 0 to ADataSet.IndexDefs.Count - 1 do
      begin
        Index := ADataSet.IndexDefs[I];
        if (Copy(Index.Name, 1, 9) = 'DAC_GRID_') and
          SameText(Index.Fields, Fields) and SameText(Index.DescFields, DescFields) and
          SameText(Index.CaseInsFields, CaseFields) then
        begin IndexName := Index.Name; Break; end;
      end;
      if IndexName = '' then
      begin
        CreateGUID(Id);
        // MIDAS index names are limited to 31 characters.
        IndexName := 'DAC_GRID_' + Copy(StringReplace(Copy(GUIDToString(Id), 2, 36),
          '-', '', [rfReplaceAll]), 1, 22);
        ADataSet.AddIndex(IndexName, Fields, [], DescFields, CaseFields);
      end;
      ADataSet.IndexName := IndexName;
    end;
    if (Length(Bookmark) > 0) and ADataSet.BookmarkValid(Bookmark) then
      ADataSet.GotoBookmark(Bookmark);
    Result := True;
  finally
    if Length(Bookmark) > 0 then ADataSet.FreeBookmark(Bookmark);
    ADataSet.EnableControls;
  end;
end;

end.
