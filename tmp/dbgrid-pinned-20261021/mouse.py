exec((__import__('pathlib').Path(__file__).with_name('implement.py')).read_text().split("prefix='Source/")[0])
prefix='Source/Controls/DAC.Components.Controls.DBGrid'
s=rd(prefix+'.pas')
s=s.replace('    FOverlayMouse: Boolean;', '    FOverlayMouse: Boolean;\n    FOverlayDown: TGridCoord;\n    FOverlayRevision: Cardinal;',1)
# Action views have exactly the same clipped bounds for painting, hints and activation.
s=s.replace('  Revision: Cardinal;\nbegin\n  Result := nil;', '  Revision: Cardinal;\n  Clip: TRect;\nbegin\n  Result := nil;',1)
s=s.replace('  X := ARect.Left + Inset;', '  Clip := ColumnClip(DataToRawColumn(AColumn.Index));\n  X := ARect.Left + Inset;',1)
s=s.replace('    if X + W > ARect.Right - Inset then Break;', '''    if (X + W > ARect.Right - Inset) or (X + W > Clip.Right - Inset) then Break;
    if X < Clip.Left + Inset then begin Inc(X, W + Gap); Continue; end;''',1)
# Native hint state is mapped from the actual displayed column, not an obscured cell.
s=s.replace('  Hot: Integer; NewCursor: TCursor; Hit: Boolean;', '  Hot, Direction: Integer; NewCursor: TCursor; Hit: Boolean;',1)
s=s.replace('if (Cell.Y = 0) and Sizing(X, Y) then', 'if (Cell.Y = 0) and (ResizeColumnAt(X, Y, Direction) >= 0) then',1)
# MouseDown handles fixed surfaces before forwarding center gestures to VCL.
s=s.replace('  ViewportColumn: Integer;\n  Context:', '  ViewportColumn, ResizeIndex, Direction, DataIndex: Integer;\n  Context:',1)
s=s.replace("  FHeaderKey := ''; FHeaderDragged := False;", "  FOverlayMouse := False; FResizeKey := '';\n  FHeaderKey := ''; FHeaderDragged := False;",1)
needle='  FActionMode := False;\n  if (Button = mbLeft) and (Cell.Y = 0)'
s=s.replace(needle,'''  FActionMode := False;
  if (Button = mbLeft) and (PinnedWidth(dgpLeft) + PinnedWidth(dgpRight) > 0) then
  begin
    ResizeIndex := ResizeColumnAt(X, Y, Direction);
    if ResizeIndex >= 0 then
    begin
      FResizeKey := Columns[ResizeIndex].EffectiveLayoutKey;
      FResizeX := X; FResizeWidth := Columns[ResizeIndex].Width;
      FResizeDirection := Direction;
      if CanFocus then SetFocus;
      MouseCapture := True;
      Exit;
    end;
  end;
  DataIndex := RawToDataColumn(Cell.X);
  if ((Cell.Y = 0) and (PinnedWidth(dgpLeft) + PinnedWidth(dgpRight) > 0)) or
    ((Cell.X = 0) and (SelectionWidth > 0)) or
    ((DataIndex >= 0) and (DataIndex < Columns.Count) and
      (Columns[DataIndex].PinPosition <> dgpNone)) then
  begin
    if not Enabled or FLoading or not CanFocus then Exit;
    if not Focused then SetFocus;
    if Cell.Y >= FixedRows then
    begin
      if not DataLink.Active or (DataLink.DataSet.State <> dsBrowse) or
        (Cell.Y - FixedRows >= DataLink.RecordCount) then Exit;
      ViewportColumn := LeftCol;
      if Cell.Y <> Row then TDACDBGridDataLink(DataLink).MoveViewport(Cell.Y - Row);
      if LeftCol <> ViewportColumn then LeftCol := ViewportColumn;
      if not FRowSelectionEnabled and (DataIndex >= 0) then SelectDisplayColumn(DataIndex);
    end;
    FOverlayMouse := Button = mbLeft;
    FOverlayDown := Cell;
    FOverlayRevision := FDataRevision;
    if (Cell.Y = 0) and (DataIndex >= 0) and (DataIndex < Columns.Count) then
    begin
      FHeaderKey := Columns[DataIndex].EffectiveLayoutKey;
      FHeaderDown := Point(X,Y); FPressedTitleColumn := Cell.X;
    end;
    if FOverlayMouse then MouseCapture := True;
    Redraw;
    Exit;
  end;
  if (Button = mbLeft) and (Cell.Y = 0)''',1)
s=s.replace('    FHeaderSizing := Sizing(X, Y);', '    FHeaderSizing := Sizing(NativeMouseX(X), Y);',1)
s=s.replace('  inherited;\n  FHeaderSizing := FHeaderSizing or', '  ViewportColumn := LeftCol;\n  inherited MouseDown(Button, Shift, NativeMouseX(X), Y);\n  if FRowSelectionEnabled and (Cell.Y >= FixedRows) and (LeftCol <> ViewportColumn) then\n    LeftCol := ViewportColumn;\n  FHeaderSizing := FHeaderSizing or',1)
# Resize uses stable keys, not a collection index retained across mutations.
s=s.replace('procedure TDACDBGrid.MouseMove(Shift: TShiftState; X, Y: Integer);\nbegin', '''procedure TDACDBGrid.MouseMove(Shift: TShiftState; X, Y: Integer);
var I: Integer;
begin
  if FResizeKey <> '' then
  begin
    for I := 0 to Columns.Count - 1 do
      if Columns[I].EffectiveLayoutKey = FResizeKey then
      begin
        Columns[I].Width := Max(Pixels(Columns[I].MinWidth),
          FResizeWidth + FResizeDirection * (X - FResizeX));
        Break;
      end;
    Exit;
  end;''',1)
s=s.replace('  if not FActionMouse then\n  begin\n    // Native fixed-cell', '  if not FActionMouse and not FOverlayMouse then\n  begin\n    // Native fixed-cell',1)
s=s.replace('if FGridState <> gsNormal then inherited\n', 'if FGridState <> gsNormal then inherited MouseMove(Shift, NativeMouseX(X), Y)\n',1)
# Release of custom fixed surfaces is exclusive, so it never reaches an obscured native column.
s=s.replace('  Context: TDACDBGridActionContext; Execute: Boolean;\nbegin\n  if FActionMouse', '  Context: TDACDBGridActionContext; Execute: Boolean;\n  I, Target, Source: Integer;\nbegin\n  if FResizeKey <> \'\' then\n  begin\n    FResizeKey := \'\'; MouseCapture := False;\n    FLayoutManager.ScheduleSave; Redraw; Exit;\n  end;\n  if FOverlayMouse then\n  begin\n    Cell := DisplayMouseCoord(X,Y);\n    FOverlayMouse := False;\n    FHeaderReleasing := True;\n    try\n      MouseCapture := False;\n      if Button = mbLeft then\n      begin\n        if (FOverlayDown.Y = 0) and (Cell.Y = 0) and not FHeaderCancelled then\n        begin\n          Source := -1;\n          for I := 0 to Columns.Count - 1 do\n            if Columns[I].EffectiveLayoutKey = FHeaderKey then Source := I;\n          Target := RawToDataColumn(Cell.X);\n          if (Source >= 0) and (Target >= 0) and (Target < Columns.Count) then\n            if FHeaderDragged then\n            begin\n              if Columns[Source].PinPosition = Columns[Target].PinPosition then\n                ColumnMoved(DataToRawColumn(Source), DataToRawColumn(Target));\n            end\n            else if Source = Target then\n            begin FAllowTitleClick := True; TitleClick(Columns[Source]); end;\n        end;\n        if (Cell.X = FOverlayDown.X) and (FOverlayRevision = FDataRevision) then\n          if (Cell.X = 0) and (SelectionWidth > 0) then\n          begin\n            if (Cell.Y = 0) and FSelectionOptions.AllowSelectAll then ToggleSelectAll\n            else if (Cell.Y = Row) and DataLink.Active then ToggleCurrentSelection;\n          end\n          else if (Cell.Y = Row) and (Cell.Y = FOverlayDown.Y) and DataLink.Active then\n          begin\n            I := RawToDataColumn(Cell.X);\n            if (I >= 0) and (I < Columns.Count) then CellClick(Columns[I]);\n          end;\n      end;\n    finally\n      FHeaderReleasing := False; FAllowTitleClick := False;\n      FHeaderKey := \'\'; FPressedTitleColumn := -1; FHeaderDragged := False;\n    end;\n    UpdateHover(X,Y); Redraw; Exit;\n  end;\n  if FActionMouse',1)
s=s.replace('    inherited;\n  finally\n    FHeaderReleasing', '    inherited MouseUp(Button, Shift, NativeMouseX(X), Y);\n  finally\n    FHeaderReleasing',1)
# Capture routing and cancellation also cover fixed headers and resizing.
s=s.replace('(FActionMouse or (FHeaderKey <> \'\')) then', '(FActionMouse or FOverlayMouse or (FResizeKey <> \'\') or (FHeaderKey <> \'\')) then',1)
s=s.replace('        ClearHover;\n        if not FHeaderReleasing then', "        ClearHover;\n        if not FHeaderReleasing then\n        begin FOverlayMouse := False; FResizeKey := ''; end;\n        if not FHeaderReleasing then",1)
# Selection column double clicks may select but cannot toggle a second time.
s=s.replace('FOverlayMouse := Button = mbLeft;', 'FOverlayMouse := (Button = mbLeft) and not (ssDouble in Shift);',1)
wr(prefix+'.pas',s)
