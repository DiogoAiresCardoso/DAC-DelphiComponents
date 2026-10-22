from pathlib import Path
p=Path(r'M:\Delphi Componentes\DAC-DelphiComponents\Source\Controls\DAC.Components.Controls.DBGrid.pas')
s=p.read_bytes().decode('cp1252').replace('\r\n','\n')
s=s.replace('    FApplyingPinnedLayout: Boolean;', '    FWideOffset: Integer;\n    FWideKey: string;\n    FApplyingPinnedLayout: Boolean;',1)
s=s.replace('    function PinnedWidth(', '    function HandleWideScroll(var Message: TMessage): Boolean;\n    procedure SyncWideScroll;\n    function PinnedWidth(',1)
i=s.index('function TDACDBGrid.FullClientRect:')
s=s[:i]+'''procedure TDACDBGrid.SyncWideScroll;
var I: Integer; Info: TScrollInfo;
begin
  if not HandleAllocated or (FWideKey = '') then Exit;
  for I := 0 to Columns.Count - 1 do
    if Columns[I].Visible and (Columns[I].PinPosition = dgpNone) and
      (Columns[I].EffectiveLayoutKey = FWideKey) then
    begin
      FWideOffset := EnsureRange(FWideOffset, 0, Max(0, Columns[I].Width - ScrollableRect.Width));
      Info := Default(TScrollInfo); Info.cbSize := SizeOf(Info);
      Info.fMask := SIF_RANGE or SIF_PAGE or SIF_POS;
      Info.nMax := Max(0, Columns[I].Width - 1);
      Info.nPage := Max(1, ScrollableRect.Width); Info.nPos := FWideOffset;
      SetScrollInfo(Handle, SB_HORZ, Info, True);
      Exit;
    end;
  FWideKey := ''; FWideOffset := 0;
end;

function TDACDBGrid.HandleWideScroll(var Message: TMessage): Boolean;
var I, Index, Code, Pos, Maximum, Direction: Integer; Info: TScrollInfo;
begin
  Result := False;
  if PinnedWidth(dgpLeft) + PinnedWidth(dgpRight) = 0 then Exit;
  Index := -1;
  for I := 0 to Columns.Count - 1 do
    if Columns[I].Visible and (Columns[I].PinPosition = dgpNone) and
      (DataToRawColumn(I) >= LeftCol) then begin Index := I; Break; end;
  if (Index < 0) or (ScrollableRect.Width <= 0) or
    (Columns[Index].Width <= ScrollableRect.Width) then Exit;
  Code := LoWord(Message.WParam); Direction := 1;
  if UseRightToLeftAlignment then Direction := -1;
  if FWideKey <> Columns[Index].EffectiveLayoutKey then
  begin FWideKey := Columns[Index].EffectiveLayoutKey; FWideOffset := 0; end;
  Maximum := Columns[Index].Width - ScrollableRect.Width;
  Pos := FWideOffset;
  case Code of
    SB_LINELEFT: Dec(Pos, Pixels(16) * Direction);
    SB_LINERIGHT: Inc(Pos, Pixels(16) * Direction);
    SB_PAGELEFT: Dec(Pos, ScrollableRect.Width * Direction);
    SB_PAGERIGHT: Inc(Pos, ScrollableRect.Width * Direction);
    SB_LEFT: Pos := 0;
    SB_RIGHT: Pos := Maximum;
    SB_THUMBPOSITION, SB_THUMBTRACK:
      begin
        Info := Default(TScrollInfo); Info.cbSize := SizeOf(Info); Info.fMask := SIF_TRACKPOS;
        if GetScrollInfo(Handle, SB_HORZ, Info) then Pos := Info.nTrackPos
        else Pos := HiWord(Message.WParam);
      end;
  end;
  // Once the pixel edge is reached, native navigation can reach another column.
  if ((Pos < 0) or (Pos > Maximum)) then
    for I := 0 to Columns.Count - 1 do
      if Columns[I].Visible and (Columns[I].PinPosition = dgpNone) and
        (((Pos < 0) and (I < Index)) or ((Pos > Maximum) and (I > Index))) then
      begin FWideKey := ''; FWideOffset := 0; Exit; end;
  FWideOffset := EnsureRange(Pos,0,Maximum);
  SyncWideScroll; Redraw; PaintNativeScrollBars; QueueNativeScrollPaint;
  Message.Result := 0; Result := True;
end;

'''+s[i:]
# Apply the offset to all scrollable geometry; headers, contents and hit tests share it.
s=s.replace('    Inc(X, PinnedWidth(dgpLeft) + SelectionWidth);', '    Inc(X, PinnedWidth(dgpLeft) + SelectionWidth + FWideOffset);',1)
s=s.replace('  Inc(X, PinnedWidth(dgpLeft));\n  Result := Rect', '  Inc(X, PinnedWidth(dgpLeft) - FWideOffset);\n  Result := Rect',1)
s=s.replace('  CancelActionInteraction;\n  ClearHover;\n  inherited;\n  Invalidate;\nend;\n\nprocedure TDACDBGrid.CMHintShow', "  FWideKey := ''; FWideOffset := 0;\n  CancelActionInteraction;\n  ClearHover;\n  inherited;\n  Invalidate;\nend;\n\nprocedure TDACDBGrid.CMHintShow",1)
s=s.replace('  if Message.Msg = WM_DAC_DBGRID_PAINT_NATIVE_SCROLL then', '  if (Message.Msg = WM_HSCROLL) and HandleWideScroll(Message) then Exit;\n  if Message.Msg = WM_DAC_DBGRID_PAINT_NATIVE_SCROLL then',1)
s=s.replace('  ApplyDensityMetrics;\nend;\n\nprocedure TDACDBGrid.SetColumns', '  ApplyDensityMetrics;\n  SyncWideScroll;\nend;\n\nprocedure TDACDBGrid.SetColumns',1)
s=s.replace('procedure TDACDBGrid.Resize;\nbegin\n  inherited;', 'procedure TDACDBGrid.Resize;\nbegin\n  inherited;\n  SyncWideScroll;',1)
# Calculating tri-state and writing checkboxes must not reset the horizontal viewport.
s=s.replace('procedure TDACDBGrid.RecalculateSelectionState;\nbegin', 'procedure TDACDBGrid.RecalculateSelectionState;\nvar Viewport: Integer;\nbegin',1)
s=s.replace('  FRecalculatingSelection := True;\n  try', '  FRecalculatingSelection := True;\n  Viewport := LeftCol;\n  try',1)
s=s.replace('    FRecalculatingSelection := False;\n  end;', '    FRecalculatingSelection := False;\n    if (Viewport >= FixedCols) and (Viewport < ColCount) and (LeftCol <> Viewport) then LeftCol := Viewport;\n    SyncWideScroll;\n  end;',1)
for marker in ['procedure TDACDBGrid.ToggleCurrentSelection;', 'procedure TDACDBGrid.ToggleSelectAll;']:
    a=s.index(marker); b=s.index('\nend;',a)+len('\nend;')
    part=s[a:b].replace('  LChecked: Boolean;', '  Viewport: Integer;\n  LChecked: Boolean;',1)
    part=part.replace('  try\n', '  Viewport := LeftCol;\n  try\n',1)
    part=part[:-len('\nend;')]+'''\n  if (Viewport >= FixedCols) and (Viewport < ColCount) and (LeftCol <> Viewport) then LeftCol := Viewport;
  SyncWideScroll;
end;'''
    s=s[:a]+part+s[b:]
p.write_bytes(s.replace('\n','\r\n').encode('cp1252'))
