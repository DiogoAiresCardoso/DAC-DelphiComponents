from pathlib import Path
root=Path(__file__).resolve().parents[2]
p=root/'Source/Controls/DAC.Components.Controls.DBGrid.pas'
s=p.read_bytes().decode('cp1252').replace('\r\n','\n')
def rep(a,b):
 global s
 assert s.count(a)==1,(a[:100],s.count(a))
 s=s.replace(a,b)
rep('    FBadgePainter: TDACDBGridBadgePainter;','''    FClampingColumns, FSorting, FRestoringSort: Boolean;
    FHeaderKey: string;
    FHeaderDown: TPoint;
    FHeaderDragged, FHeaderSizing, FHeaderCancelled, FHeaderReleasing, FAllowTitleClick: Boolean;
    FPendingSortKey, FPendingSortField: string;
    FPendingSortDirection: TDACDBGridSortDirection;
    FObservedDataSet: TDataSet;
    FBadgePainter: TDACDBGridBadgePainter;''')
rep('    procedure ApplyDensityMetrics;','''    procedure ApplyDensityMetrics;
    procedure InvalidateHoverCell(const ACell: TGridCoord);
    procedure ClearHover;
    procedure UpdateHover(const X, Y: Integer);
    procedure ClampColumnWidths;
    procedure ColumnsChanged(Sender: TObject);
    function CanSortColumn(AColumn: TDACDBGridColumn): Boolean;
    function GetSortKey: string;
    function GetSortDirection: TDACDBGridSortDirection;
    procedure ValidateSort;
    procedure RestoreLayoutSort(const AKey, AFieldName: string;
      const ADirection: TDACDBGridSortDirection);
    procedure TryPendingSort;''')
rep('    function EffectivePPI: Integer;\n','')
rep('  protected\n','  protected\n    function EffectivePPI: Integer; virtual;\n    procedure Notification(AComponent: TComponent; Operation: TOperation); override;\n    procedure TopLeftChanged; override;\n')
rep('    procedure LoadLayout;','''    function RequestSort(const AColumnIndex: Integer;
      const ADirection: TDACDBGridSortDirection): Boolean;
    property SortKey: string read GetSortKey;
    property SortDirection: TDACDBGridSortDirection read GetSortDirection;
    procedure LoadLayout;''')
rep('  FLayoutManager.OnError := LayoutError;','  FLayoutManager.OnError := LayoutError;\n  FLayoutManager.OnRestoreSort := RestoreLayoutSort;\n  GetColumns.OnChange := ColumnsChanged;')
rep('  FOnActionState := nil;','  GetColumns.OnChange := nil;\n  if FObservedDataSet <> nil then FObservedDataSet.RemoveFreeNotification(Self);\n  FObservedDataSet := nil;\n  FOnActionState := nil;')
rep('  CancelActionInteraction(True);\n  inherited;\n  ApplyDACNativeScrollBarTheme(Self, FThemeMode);','  CancelActionInteraction(True);\n  ClearHover;\n  FHeaderCancelled := True;\n  inherited;\n  ApplyDACNativeScrollBarTheme(Self, FThemeMode);')
a=s.index('procedure TDACDBGrid.CMMouseLeave(');z=s.index('procedure TDACDBGrid.CMParentColorChanged',a)
s=s[:a]+'''procedure TDACDBGrid.CMMouseLeave(var AMessage: TMessage);
begin
  CancelActionInteraction;
  ClearHover;
  inherited;
end;

'''+s[z:]
rep('  CancelActionInteraction(True);\n  inherited;\n  FLayoutManager.ScheduleSave;','  CancelActionInteraction(True);\n  ClearHover;\n  if FHeaderKey <> \'\' then FHeaderDragged := True;\n  inherited;\n  FLayoutManager.ScheduleSave;')
rep('procedure TDACDBGrid.ColWidthsChanged;\nbegin\n  CancelActionInteraction;','procedure TDACDBGrid.ColWidthsChanged;\nbegin\n  CancelActionInteraction;\n  ClearHover;\n  ClampColumnWidths;')
rep('procedure TDACDBGrid.DataLinkChanged(Sender: TObject; AField: TField);\nbegin','procedure TDACDBGrid.DataLinkChanged(Sender: TObject; AField: TField);\nvar Current: TDataSet;\nbegin')
rep('  Inc(FDataRevision);\n  CancelActionInteraction;','''  Inc(FDataRevision);
  CancelActionInteraction;
  ClearHover;
  Current := DataLink.DataSet;
  if Current <> FObservedDataSet then
  begin
    if FObservedDataSet <> nil then
    begin
      FObservedDataSet.RemoveFreeNotification(Self);
      FPendingSortKey := '';
    end;
    FObservedDataSet := Current;
    if Current <> nil then Current.FreeNotification(Self);
    FSortController.Clear;
  end;
  if not DataLink.Active then FSortController.Clear else ValidateSort;''')
rep('  FLayoutManager.Load;\n  Redraw;\nend;\n\nprocedure TDACDBGrid.DrawCell','  FLayoutManager.Load;\n  TryPendingSort;\n  Redraw;\nend;\n\nprocedure TDACDBGrid.DrawCell')
s=s.replace('FHoverEnabled and (FHotCell.Y = LRawRow)','FHoverEnabled and SameGridCoord(FHotCell, MakeGridCoord(LRawColumn, LRawRow))')
rep('procedure TDACDBGrid.SetColumnAttributes;\nbegin\n  CancelActionInteraction;','procedure TDACDBGrid.SetColumnAttributes;\nbegin\n  CancelActionInteraction;\n  ClearHover;')
rep('  if FSelectionOptions.Enabled and (dgIndicator in Options) and','  ClampColumnWidths;\n  if (FSelectionOptions <> nil) and FSelectionOptions.Enabled and (dgIndicator in Options) and')
rep('procedure TDACDBGrid.SetColumns(const AValue: TDACDBGridColumns);\nbegin\n  GetColumns.Assign(AValue);','procedure TDACDBGrid.SetColumns(const AValue: TDACDBGridColumns);\nbegin\n  FLayoutManager.DiscardPendingSave;\n  GetColumns.Assign(AValue);')
rep('  if not GetColumns[LTargetIndex].UserHideable then','  if not AVisible and not GetColumns[LTargetIndex].UserHideable then')
rep('  FHoverEnabled := AValue;','  FHoverEnabled := AValue;\n  ClearHover;')
rep('  FLoading := AValue;\n  CancelActionInteraction(True);','  FLoading := AValue;\n  CancelActionInteraction(True);\n  ClearHover;\n  FHeaderCancelled := True;')
rep('  LOptions := [dgTitles, dgColumnResize, dgRowSelect, dgAlwaysShowSelection,','  LOptions := [dgTitles, dgColumnResize, dgColumnMove, dgRowSelect, dgAlwaysShowSelection,')
a=s.index('procedure TDACDBGrid.CMHintShow(');z=s.index('function TDACDBGrid.FocusAction(',a)
methods=(root/'tmp/dbgrid-columns-20261020/grid-methods.txt').read_text(encoding='utf-8')
s=s[:a]+methods+'\n'+s[z:]
rep('procedure TDACDBGrid.LoadLayout;\nbegin\n  FLayoutManager.SetIdentity(\'\');\n  UpdateLayoutIdentity;\n  FLayoutManager.Load;','procedure TDACDBGrid.LoadLayout;\nbegin\n  ClearHover;\n  CancelActionInteraction(True);\n  UpdateLayoutIdentity;\n  FLayoutManager.Reload;')
rep('procedure TDACDBGrid.KeyDown(var Key: Word; Shift: TShiftState);\nvar Direction: Integer;\nbegin','''procedure TDACDBGrid.KeyDown(var Key: Word; Shift: TShiftState);
var Direction: Integer;
begin
  if not FActionMode and (Key = VK_RETURN) and (Shift = [ssCtrl]) and
    (SelectedIndex >= 0) and (SelectedIndex < GetColumns.Count) then
  begin
    RequestSort(SelectedIndex, FSortController.NextDirection(GetColumns[SelectedIndex].EffectiveLayoutKey));
    Key := 0; Exit;
  end;''')
rep('  FActionMouse := False;\n  Cell := MouseCoord(X, Y);','''  FActionMouse := False;
  FHeaderKey := ''; FHeaderDragged := False; FHeaderSizing := False;
  FHeaderCancelled := False;
  Cell := MouseCoord(X, Y);''')
rep('  if (Button = mbLeft) and (Cell.Y = 0) then FPressedTitleColumn := Cell.X;\n  inherited;\n  Redraw;','''  if (Button = mbLeft) and (Cell.Y = 0) and not (ssDouble in Shift) and
    (RawToDataColumn(Cell.X) >= 0) and (RawToDataColumn(Cell.X) < GetColumns.Count) then
  begin
    FHeaderKey := GetColumns[RawToDataColumn(Cell.X)].EffectiveLayoutKey;
    FHeaderDown := Point(X, Y);
    FHeaderSizing := Sizing(X, Y);
    if not FHeaderSizing then FPressedTitleColumn := Cell.X;
  end;
  inherited;
  FHeaderSizing := FHeaderSizing or (FGridState = gsColSizing);
  Redraw;''')
a=s.index('procedure TDACDBGrid.MouseMove(');z=s.index('procedure TDACDBGrid.MouseUp(',a)
s=s[:a]+'''procedure TDACDBGrid.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  if not FActionMouse then inherited;
  if (FHeaderKey <> '') and ((Abs(X - FHeaderDown.X) > GetSystemMetrics(SM_CXDRAG)) or
    (Abs(Y - FHeaderDown.Y) > GetSystemMetrics(SM_CYDRAG))) then
  begin
    FHeaderDragged := True;
    FPressedTitleColumn := -1;
  end;
  UpdateHover(X, Y);
end;

'''+s[z:]
rep('    FActionMouse := False;\n    Redraw;','    FActionMouse := False;\n    UpdateHover(X, Y);\n    Redraw;')
rep('  Cell := MouseCoord(X, Y);\n  inherited;\n  if (Button = mbLeft) and FSelectionOptions.Enabled','''  Cell := MouseCoord(X, Y);
  FAllowTitleClick := (Button = mbLeft) and (FHeaderKey <> '') and
    not FHeaderDragged and not FHeaderSizing and not FHeaderCancelled and (Cell.Y = 0) and
    (RawToDataColumn(Cell.X) >= 0) and (RawToDataColumn(Cell.X) < GetColumns.Count) and
    SameText(GetColumns[RawToDataColumn(Cell.X)].EffectiveLayoutKey, FHeaderKey);
  FHeaderReleasing := True;
  try
    if MouseCapture then MouseCapture := False;
    inherited;
  finally
    FHeaderReleasing := False; FAllowTitleClick := False; FHeaderKey := '';
    FHeaderSizing := False; FHeaderDragged := False;
  end;
  if (Button = mbLeft) and FSelectionOptions.Enabled''')
a=s.index('procedure TDACDBGrid.TitleClick(');z=s.index('procedure TDACDBGrid.ToggleCurrentSelection;',a)
s=s[:a]+'''procedure TDACDBGrid.TitleClick(Column: TColumn);
begin
  if not FAllowTitleClick then Exit;
  FAllowTitleClick := False;
  inherited;
  if not (Column is TDACDBGridColumn) then Exit;
  RequestSort(Column.Index, FSortController.NextDirection(TDACDBGridColumn(Column).EffectiveLayoutKey));
end;

'''+s[z:]
rep('if (Message.Msg = WM_LBUTTONUP) and FActionMouse then','if (Message.Msg = WM_LBUTTONUP) and (FActionMouse or (FHeaderKey <> \'\')) then')
rep('        CancelActionInteraction((Message.Msg = WM_KILLFOCUS) or (Message.Msg = CM_DEACTIVATE));\n        if not (csDestroying in ComponentState) then Invalidate;','''        CancelActionInteraction((Message.Msg = WM_KILLFOCUS) or (Message.Msg = CM_DEACTIVATE));
        ClearHover;
        if not FHeaderReleasing then FHeaderCancelled := True;''')
# Scale both painters at the same PPI used by native text and action geometry.
for callee in ['FCellPainter.Draw(', 'FHeaderPainter.Draw(']:
 pos=0
 while True:
  start=s.find(callee,pos)
  if start<0: break
  end=start+len(callee);level=1
  while level:
   if s[end]=='(':level+=1
   if s[end]==')':level-=1
   end+=1
  call=s[start:end]
  assert call.endswith('FTextItems)')
  new=call[:-1]+', EffectivePPI)'
  s=s[:start]+new+s[end:];pos=start+len(new)
p.write_bytes(s.replace('\n','\r\n').encode('cp1252'))
print('Grid hover routing, header gesture guards, sort restoration and lifecycle updated.')
