from pathlib import Path
def edit(suffix, fn):
 p=Path('Source/Controls/DAC.Components.Controls.DBGrid'+suffix+'.pas');s=p.read_bytes().decode('cp1252').replace('\r\n','\n');p.write_bytes(fn(s).replace('\n','\r\n').encode('cp1252'))
def layout(s):
 s=s.replace('  Applied: TStringList;','  Applied: TStringList;\n  RestoreKey, RestoreField: string;')
 s=s.replace('  FApplying := True;\n  Applied', '''  RestoreKey := ASnapshot.SortKey; RestoreField := ASnapshot.SortFieldName;
  if ASnapshot.SortDirection = dgsNone then
  begin RestoreKey := FSortController.Key; RestoreField := FSortController.FieldName; end;
  FApplying := True;
  Applied''')
 s=s.replace('FOnRestoreSort(ASnapshot.SortKey, ASnapshot.SortFieldName, ASnapshot.SortDirection)', 'FOnRestoreSort(RestoreKey, RestoreField, ASnapshot.SortDirection)')
 return s
edit('.LayoutManager',layout)
def grid(s):
 s=s.replace('  if Direction = dgsNone then Exit;\n','')
 s=s.replace('procedure TDACDBGrid.ColumnsChanged(Sender: TObject);\nbegin\n  CancelActionInteraction;', 'procedure TDACDBGrid.ColumnsChanged(Sender: TObject);\nbegin\n  FHeaderCancelled := True;\n  FPressedTitleColumn := -1;\n  CancelActionInteraction;')
 s=s.replace('procedure TDACDBGrid.CMMouseLeave(var AMessage: TMessage);\nbegin\n', 'procedure TDACDBGrid.CMMouseLeave(var AMessage: TMessage);\nbegin\n  FHeaderCancelled := True;\n  FPressedTitleColumn := -1;\n')
 s=s.replace('        if not FHeaderReleasing then FHeaderCancelled := True;', '''        if not FHeaderReleasing then
        begin
          if FPressedTitleColumn >= 0 then InvalidateHoverCell(MakeGridCoord(FPressedTitleColumn, 0));
          FHeaderCancelled := True;
          FPressedTitleColumn := -1;
        end;''')
 return s
edit('',grid)
for suffix in ['.CellPainter','.HeaderPainter']:
 def tidy(s):
  start=s.index('  try\n',s.index('procedure TDACDBGrid'+suffix[1:]+'.Draw('))+len('  try\n');end=s.index('  finally ACanvas.Restore; end;', start)
  s=s[:start]+''.join('  '+line if line.strip() else line for line in s[start:end].splitlines(True))+s[end:]
  return s
 edit(suffix,tidy)
edit('.LayoutSerializer',lambda s:s.replace("    LEntry.AddPair('sortFieldName'", "      LEntry.AddPair('sortFieldName'"))
