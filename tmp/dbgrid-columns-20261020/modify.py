from pathlib import Path

root=Path(__file__).resolve().parents[2]
def read(name): return (root/name).read_bytes().decode('cp1252').replace('\r\n','\n')
def write(name,s): (root/name).write_bytes(s.replace('\n','\r\n').encode('cp1252'))
def replace(s,a,b):
    assert s.count(a)==1,(a[:100],s.count(a))
    return s.replace(a,b)

p='Source/Controls/DAC.Components.Controls.DBGrid.Column.pas';s=read(p)
s=replace(s,'    FActions: TDACDBGridActions;','    FActions: TDACDBGridActions;\n    FHint, FTitleHint: string;\n    FMinWidth: Integer;\n    procedure SetHint(const AValue: string);\n    procedure SetTitleHint(const AValue: string);\n    procedure SetMinWidth(const AValue: Integer);')
s=replace(s,'  published\n','  published\n    property Hint: string read FHint write SetHint;\n    property TitleHint: string read FTitleHint write SetTitleHint;\n    property MinWidth: Integer read FMinWidth write SetMinWidth default 16;\n')
s=replace(s,'implementation\n','implementation\n\nuses System.Math;\n')
s=replace(s,'  inherited Create(Collection);','  inherited Create(Collection);\n  FMinWidth := 16;')
s=replace(s,'    FActions.Assign(LSource.FActions);','    FActions.Assign(LSource.FActions);\n    FMinWidth := LSource.MinWidth;\n    FHint := LSource.Hint;\n    FTitleHint := LSource.TitleHint;')
s=replace(s,'function TDACDBGridColumn.EffectiveLayoutKey: string;','''procedure TDACDBGridColumn.SetHint(const AValue: string);
begin
  if FHint = AValue then Exit;
  FHint := AValue; Changed(False);
end;

procedure TDACDBGridColumn.SetTitleHint(const AValue: string);
begin
  if FTitleHint = AValue then Exit;
  FTitleHint := AValue; Changed(False);
end;

procedure TDACDBGridColumn.SetMinWidth(const AValue: Integer);
begin
  if FMinWidth = Max(16, AValue) then Exit;
  FMinWidth := Max(16, AValue); Changed(True);
end;

function TDACDBGridColumn.EffectiveLayoutKey: string;''');write(p,s)

p='Source/Controls/DAC.Components.Controls.DBGrid.Columns.pas';s=read(p)
s=replace(s,'  private\n','  private\n    FOnChange: TNotifyEvent;\n    FNotifying: Boolean;\n')
s=replace(s,'  Vcl.DBGrids,','  System.Classes,\n  Vcl.DBGrids,')
s=replace(s,'  public\n','  protected\n    procedure Update(Item: TCollectionItem); override;\n  public\n')
s=replace(s,'    constructor Create(AGrid: TCustomDBGrid);','    property OnChange: TNotifyEvent read FOnChange write FOnChange;\n    constructor Create(AGrid: TCustomDBGrid);')
s=replace(s,'constructor TDACDBGridColumns.Create','''procedure TDACDBGridColumns.Update(Item: TCollectionItem);
begin
  inherited;
  if FNotifying then Exit;
  FNotifying := True;
  try
    if Assigned(FOnChange) then FOnChange(Self);
  finally FNotifying := False; end;
end;

constructor TDACDBGridColumns.Create''');write(p,s)

p='Source/Controls/DAC.Components.Controls.DBGrid.SortController.pas';s=read(p)
s=replace(s,'    FKey: string;','    FKey: string;\n    FFieldName: string;')
s=s.replace('const ADirection: TDACDBGridSortDirection);','const ADirection: TDACDBGridSortDirection; const AFieldName: string = \'\');',1)
s=replace(s,'    property Key: string read FKey;','    property Key: string read FKey;\n    property FieldName: string read FFieldName;')
s=replace(s,'implementation\n','implementation\n\nuses System.SysUtils;\n')
s=s.replace('const ADirection: TDACDBGridSortDirection);','const ADirection: TDACDBGridSortDirection; const AFieldName: string);',1)
s=replace(s,'  FKey := AKey;','  FKey := AKey;\n  FFieldName := AFieldName;')
s=replace(s,"  FKey := '';","  FKey := '';\n  FFieldName := '';")
s=replace(s,"  if (FKey <> AKey) or (FDirection = dgsNone) then","  if not SameText(FKey, AKey) or (FDirection = dgsNone) then")
s=s.replace('    dgsDescending: Result := dgsNone;','    dgsDescending: Result := dgsAscending;');write(p,s)

p='Source/Controls/DAC.Components.Controls.DBGrid.Types.pas';s=read(p)
s=replace(s,'    SortKey: string;','    SortKey: string;\n    SortFieldName: string;')
s=replace(s,'  TDACDBGridErrorEvent = procedure','  TDACDBGridRestoreSortEvent = procedure(const AKey, AFieldName: string;\n    const ADirection: TDACDBGridSortDirection) of object;\n  TDACDBGridErrorEvent = procedure');write(p,s)

p='Source/Controls/DAC.Components.Controls.DBGrid.LayoutSerializer.pas';s=read(p)
s=replace(s,"      LSortDirection := JSONInteger(LEntry, 'sortDirection', Ord(dgsNone));","      ACatalog.Entries[I].Snapshot.SortFieldName := JSONString(LEntry, 'sortFieldName');\n      LSortDirection := JSONInteger(LEntry, 'sortDirection', Ord(dgsNone));")
needle="    LEntry.AddPair('sortKey', ACatalog.Entries[I].Snapshot.SortKey);"
assert needle in s
s=replace(s,needle,needle+"\n    LEntry.AddPair('sortFieldName', ACatalog.Entries[I].Snapshot.SortFieldName);");write(p,s)

p='Source/Controls/DAC.Components.Controls.DBGrid.LayoutManager.pas';s=read(p)
s=replace(s,'    FOnError: TDACDBGridErrorEvent;','    FOnError: TDACDBGridErrorEvent;\n    FOnRestoreSort: TDACDBGridRestoreSortEvent;')
s=replace(s,'    procedure Load;','    procedure Load;\n    procedure Reload;\n    procedure DiscardPendingSave;')
s=replace(s,'    property Applying: Boolean read FApplying;','    property Applying: Boolean read FApplying;\n    property OnRestoreSort: TDACDBGridRestoreSortEvent read FOnRestoreSort write FOnRestoreSort;')
s=replace(s,'  LVisibleCount: Integer;','  LVisibleCount, TargetIndex: Integer;\n  Applied: TStringList;')
s=replace(s,'  FApplying := True;\n  try','  FApplying := True;\n  Applied := TStringList.Create;\n  Applied.CaseSensitive := False;\n  TargetIndex := 0;\n  try')
s=replace(s,'      if LColumnIndex < 0 then','      if (LColumnIndex < 0) or (Applied.IndexOf(LLayout.Key) >= 0) then')
s=replace(s,'      FColumns[LColumnIndex].Width := Max(16, MulDiv(LLayout.LogicalWidth,','      FColumns[LColumnIndex].Width := Max(MulDiv(FColumns[LColumnIndex].MinWidth,\n        Max(96, GridPPI(FGrid)), 96), MulDiv(LLayout.LogicalWidth,')
s=replace(s,'      FColumns[LColumnIndex].Index := Min(I, FColumns.Count - 1);','      FColumns[LColumnIndex].Index := TargetIndex;\n      Inc(TargetIndex);\n      Applied.Add(LLayout.Key);')
s=replace(s,'    FSortController.Accept(ASnapshot.SortKey, ASnapshot.SortDirection);','    FSortController.Clear;')
s=replace(s,'    FApplying := False;\n  end;\nend;','    Applied.Free;\n    FApplying := False;\n  end;\n  if Assigned(FOnRestoreSort) then\n    FOnRestoreSort(ASnapshot.SortKey, ASnapshot.SortFieldName, ASnapshot.SortDirection);\nend;')
s=replace(s,'  Result.SortKey := FSortController.Key;','  Result.SortKey := FSortController.Key;\n  Result.SortFieldName := FSortController.FieldName;')
s=s.replace('(csDesigning in FGrid.ComponentState) then','([csDesigning, csLoading, csDestroying] * FGrid.ComponentState <> []) then')
s=replace(s,'procedure TDACDBGridLayoutManager.Load;','''procedure TDACDBGridLayoutManager.DiscardPendingSave;
begin
  FTimer.Enabled := False;
end;

procedure TDACDBGridLayoutManager.Reload;
begin
  DiscardPendingSave;
  FLoaded := False;
  Load;
end;

procedure TDACDBGridLayoutManager.Load;''');write(p,s)
print('Column metadata, invalidation hook, two-state sorting and compatible layout serialization updated.')
