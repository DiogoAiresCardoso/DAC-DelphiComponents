from pathlib import Path
root=Path(r'M:\Delphi Componentes\DAC-DelphiComponents')
def read(p): return p.read_bytes().decode('cp1252').replace('\r\n','\n')
def write(p,s): p.write_bytes(s.replace('\n','\r\n').encode('cp1252'))
p=root/'Source/Controls/DAC.Components.Controls.DBGrid.Column.pas'
s=read(p).replace('    FActions: TDACDBGridActions;', '    FAllowFocus: Boolean;\n    FActions: TDACDBGridActions;',1)
s=s.replace('    procedure SetHint(', '    procedure SetAllowFocus(const AValue: Boolean);\n    procedure SetHint(',1)
s=s.replace('  published\n', '  published\n    property AllowFocus: Boolean read FAllowFocus write SetAllowFocus default True;\n',1)
s=s.replace('  FMinWidth := 16;', '  FAllowFocus := True;\n  FMinWidth := 16;',1)
s=s.replace('    FMinWidth := LSource.MinWidth;', '    FAllowFocus := LSource.AllowFocus;\n    FMinWidth := LSource.MinWidth;',1)
at=s.index('procedure TDACDBGridColumn.SetHint')
s=s[:at]+'''procedure TDACDBGridColumn.SetAllowFocus(const AValue: Boolean);
begin
  if FAllowFocus = AValue then Exit;
  FAllowFocus := AValue;
  Changed(False);
end;

'''+s[at:]
write(p,s)
p=root/'Source/Controls/DAC.Components.Controls.DBGrid.pas'
s=read(p).replace('    function CanEditAcceptKey(', '''    function SelectCell(ACol, ARow: Longint): Boolean; override;
    function CanGridAcceptKey(Key: Word; Shift: TShiftState): Boolean; override;
    function CanEditAcceptKey(''',1)
s=s.replace('if Focused and not FActionMode and (LRawColumn = Col)', 'if Focused and LColumn.AllowFocus and not FActionMode and (LRawColumn = Col)',1)
s=s.replace('  ClearHover;\n  inherited;\nend;\n\nprocedure TDACDBGrid.CMHintShow', '  ClearHover;\n  inherited;\n  Invalidate;\nend;\n\nprocedure TDACDBGrid.CMHintShow',1)
at=s.index('procedure TDACDBGrid.TopLeftChanged;')
s=s[:at]+'''function TDACDBGrid.SelectCell(ACol, ARow: Longint): Boolean;
var Index: Integer;
begin
  Result := inherited SelectCell(ACol, ARow);
  if not Result or FRowSelectionEnabled or (ACol = Col) then Exit;
  Index := RawToDataColumn(ACol);
  if (Index >= 0) and (Index < Columns.Count) then
    Result := Columns[Index].AllowFocus;
end;

function TDACDBGrid.CanGridAcceptKey(Key: Word; Shift: TShiftState): Boolean;
var I, Step, Target, NavKey: Integer; Restricted, WrapRow: Boolean;
begin
  Result := inherited CanGridAcceptKey(Key, Shift);
  if not Result or FRowSelectionEnabled or not DataLink.Active or
    (ssAlt in Shift) then Exit;
  if not (Key in [VK_LEFT, VK_RIGHT, VK_HOME, VK_END, VK_TAB]) then Exit;
  if (ssCtrl in Shift) and (Key in [VK_HOME, VK_END, VK_TAB]) then Exit;
  Restricted := False;
  for I := 0 to Columns.Count - 1 do
    if Columns[I].Visible and not Columns[I].AllowFocus then Restricted := True;
  if not Restricted then Exit;
  // Called by native KeyDown after OnKeyDown, so the consumer still sees one event.
  Result := False;
  NavKey := Key;
  if UseRightToLeftAlignment then
    if Key = VK_LEFT then NavKey := VK_RIGHT
    else if Key = VK_RIGHT then NavKey := VK_LEFT;
  Step := 1;
  if (NavKey = VK_LEFT) or (NavKey = VK_END) or
    ((NavKey = VK_TAB) and (ssShift in Shift)) then Step := -1;
  Target := SelectedIndex + Step;
  if (NavKey = VK_HOME) or ((NavKey = VK_RIGHT) and (ssCtrl in Shift)) then
  begin Target := 0; Step := 1; end;
  if (NavKey = VK_END) or ((NavKey = VK_LEFT) and (ssCtrl in Shift)) then
  begin Target := Columns.Count - 1; Step := -1; end;
  // Ctrl+Left/Right use the native first/last-column semantics.
  if (ssCtrl in Shift) and (NavKey = VK_LEFT) then begin Target := 0; Step := 1; end;
  if (ssCtrl in Shift) and (NavKey = VK_RIGHT) then begin Target := Columns.Count - 1; Step := -1; end;
  WrapRow := False;
  for I := 0 to Columns.Count * 2 - 1 do
  begin
    if (Target < 0) or (Target >= Columns.Count) then
    begin
      if (NavKey <> VK_TAB) or WrapRow then Exit;
      WrapRow := True;
      if Step > 0 then Target := 0 else Target := Columns.Count - 1;
    end;
    if Columns[Target].Visible and Columns[Target].AllowFocus then
    begin
      CancelActionInteraction(True);
      if WrapRow then
        if Step > 0 then DataLink.DataSet.Next else DataLink.DataSet.Prior;
      SelectedIndex := Target;
      Exit;
    end;
    Inc(Target, Step);
  end;
end;

'''+s[at:]
s=s.replace('  inherited;\n\n  if (Message.Msg = WM_GETDLGCODE)', '''  // The Skia surface and native text form one complete frame. ScrollWindowEx
  // can leave copied pixels outside its exposed strip (also with FColOffset).
  // Expand the update region before BeginPaint, without erasing the background.
  if (Message.Msg = WM_PAINT) and (Message.WParam = 0) and HandleAllocated then
    Winapi.Windows.InvalidateRect(Handle, nil, False);
  inherited;

  if (Message.Msg = WM_GETDLGCODE)''',1)
write(p,s)
