from pathlib import Path
r=Path(r'M:\Delphi Componentes\DAC-DelphiComponents')
def rd(n): return (r/n).read_bytes().decode('cp1252').replace('\r\n','\n')
def wr(n,s): (r/n).write_bytes(s.replace('\n','\r\n').encode('cp1252'))
prefix='Source/Controls/DAC.Components.Controls.DBGrid'
s=rd(prefix+'.Types.pas').replace('  TDACDBGridDensity = (','  TDACDBGridPinPosition = (dgpNone, dgpLeft, dgpRight);\n\n  TDACDBGridDensity = (',1)
wr(prefix+'.Types.pas',s)
s=rd(prefix+'.Column.pas').replace('    FAllowFocus: Boolean;', '    FPinPosition: TDACDBGridPinPosition;\n    procedure SetPinPosition(const AValue: TDACDBGridPinPosition);\n    FAllowFocus: Boolean;',1)
s=s.replace('  published\n','  published\n    property PinPosition: TDACDBGridPinPosition read FPinPosition write SetPinPosition default dgpNone;\n',1)
s=s.replace('    FAllowFocus := LSource.AllowFocus;', '    FPinPosition := LSource.PinPosition;\n    FAllowFocus := LSource.AllowFocus;',1)
i=s.index('procedure TDACDBGridColumn.SetAllowFocus')
s=s[:i]+'''procedure TDACDBGridColumn.SetPinPosition(const AValue: TDACDBGridPinPosition);
begin
  if FPinPosition = AValue then Exit;
  FPinPosition := AValue;
  Changed(True);
end;

'''+s[i:]
wr(prefix+'.Column.pas',s)
s=rd(prefix+'.NativeText.pas')
s=s.replace('const APPI: Integer; const AItems: TList<TDACDBGridTextItem>);', 'const APPI: Integer; const AItems: TList<TDACDBGridTextItem>;\n  const AClips: TList<TRect> = nil);',1)
s=s.replace('const APPI: Integer; const AItems: TList<TDACDBGridTextItem>);', 'const APPI: Integer; const AItems: TList<TDACDBGridTextItem>;\n  const AClips: TList<TRect>);',1)
s=s.replace('  I: Integer;', '  I, SavedDC: Integer;',1)
s=s.replace('    LOldFont := SelectObject(ADC, LFont);\n    try', '''    SavedDC := SaveDC(ADC);
    LOldFont := SelectObject(ADC, LFont);
    try
      if (AClips <> nil) and (I < AClips.Count) then
        with AClips[I] do IntersectClipRect(ADC, Left, Top, Right, Bottom);''',1)
s=s.replace('      DeleteObject(LFont);\n    end;', '      RestoreDC(ADC, SavedDC);\n      DeleteObject(LFont);\n    end;',1)
wr(prefix+'.NativeText.pas',s)
s=rd(prefix+'.pas')
s=s.replace('    FActionPainter: TDACDBGridActionPainter;', '''    FApplyingPinnedLayout: Boolean;
    FOverlayMouse: Boolean;
    FResizeKey: string;
    FResizeX, FResizeWidth, FResizeDirection: Integer;
    FTextClips: TList<TRect>;
    function PinnedWidth(const Side: TDACDBGridPinPosition): Integer;
    function SelectionWidth: Integer;
    function NativeMouseX(const X: Integer): Integer;
    function ColumnClip(const RawColumn: Integer): TRect;
    function DisplayMouseCoord(const X, Y: Integer): TGridCoord;
    function ResizeColumnAt(const X, Y: Integer; out Direction: Integer): Integer;
    procedure FinishColumnPaint(const TextStart: Integer; const Clip: TRect);
    procedure SelectDisplayColumn(const Index: Integer);
    FActionPainter: TDACDBGridActionPainter;''',1)
s=s.replace('    function DisplayCellRect(', '''    function GetClientRect: TRect; override;
    function FullClientRect: TRect;
    function ScrollableRect: TRect;
    function DisplayCellRect(''',1)
s=s.replace('  FTextItems.Free;', '  FTextClips.Free;\n  FTextItems.Free;',1)
s=s.replace('  FTextItems := TList<TDACDBGridTextItem>.Create;', '  FTextItems := TList<TDACDBGridTextItem>.Create;\n  FTextClips := TList<TRect>.Create;',1)
start=s.index('function TDACDBGrid.DisplayCellRect(')
end=s.index('function TDACDBGrid.EffectivePPI:',start)
s=s[:start]+'''function TDACDBGrid.FullClientRect: TRect;
begin
  if HandleAllocated then Winapi.Windows.GetClientRect(Handle, Result)
  else Result := Rect(0, 0, Width, Height);
end;

function TDACDBGrid.PinnedWidth(const Side: TDACDBGridPinPosition): Integer;
var I: Integer;
begin
  Result := 0;
  if GetColumns = nil then Exit;
  for I := 0 to Columns.Count - 1 do
    if Columns[I].Visible and (Columns[I].PinPosition = Side) then
      Inc(Result, Columns[I].Width);
end;

function TDACDBGrid.SelectionWidth: Integer;
begin
  Result := 0;
  if (FSelectionOptions <> nil) and FSelectionOptions.Enabled then
    Result := Pixels(FSelectionOptions.Width);
end;

function TDACDBGrid.GetClientRect: TRect;
begin
  Result := inherited GetClientRect;
  // Reserve fixed bands in the native grid's logical viewport. The OS client
  // and non-client scrollbars retain their real bounds (FullClientRect).
  Result.Right := Max(Result.Left + 1, Result.Right -
    PinnedWidth(dgpLeft) - PinnedWidth(dgpRight));
end;

function TDACDBGrid.ScrollableRect: TRect;
begin
  Result := FullClientRect;
  Result.Left := Min(Result.Right, SelectionWidth + PinnedWidth(dgpLeft));
  Result.Right := Max(Result.Left, Result.Right - PinnedWidth(dgpRight));
end;

function TDACDBGrid.NativeMouseX(const X: Integer): Integer;
begin
  Result := X - PinnedWidth(dgpLeft);
  if UseRightToLeftAlignment then Dec(Result, SelectionWidth);
end;

function TDACDBGrid.ColumnClip(const RawColumn: Integer): TRect;
var Index, LeftEnd: Integer;
begin
  Result := FullClientRect;
  if (SelectionWidth > 0) and (RawColumn = 0) then
  begin Result.Right := Min(Result.Right, SelectionWidth); Exit; end;
  Index := RawToDataColumn(RawColumn);
  if (Index < 0) or (Index >= Columns.Count) then Exit(TRect.Empty);
  LeftEnd := Min(Result.Right, SelectionWidth + PinnedWidth(dgpLeft));
  case Columns[Index].PinPosition of
    dgpLeft:
      begin Result.Left := Min(Result.Right, SelectionWidth); Result.Right := LeftEnd; end;
    dgpRight: Result.Left := Max(LeftEnd, Result.Right - PinnedWidth(dgpRight));
  else Result := ScrollableRect;
  end;
end;

function TDACDBGrid.DisplayCellRect(const ACol, ARow: Integer): TRect;
var I, X, Index, LineWidth: Integer; Origin: TRect; Side: TDACDBGridPinPosition;
begin
  Result := TRect.Empty;
  if (ACol < 0) or (ACol >= ColCount) or (ARow < 0) or (ARow >= RowCount) then Exit;
  Origin := CellRect(0, ARow);
  if (SelectionWidth > 0) and (ACol = 0) then
    Exit(Rect(0, Origin.Top, SelectionWidth, Origin.Bottom));
  Index := RawToDataColumn(ACol);
  if (Index < 0) or (Index >= Columns.Count) or not Columns[Index].Visible then Exit;
  Side := Columns[Index].PinPosition;
  if Side <> dgpNone then
  begin
    if Side = dgpLeft then X := SelectionWidth
    else X := FullClientRect.Right - PinnedWidth(dgpRight);
    for I := 0 to Index - 1 do
      if Columns[I].Visible and (Columns[I].PinPosition = Side) then Inc(X, Columns[I].Width);
    Exit(Rect(X, Origin.Top, X + Columns[Index].Width, Origin.Bottom));
  end;
  if ACol < LeftCol then Exit;
  Origin := CellRect(LeftCol, ARow);
  LineWidth := 0;
  if dgColLines in Options then LineWidth := GridLineWidth;
  if UseRightToLeftAlignment then
  begin
    X := Origin.Right;
    for I := LeftCol to ACol - 1 do Dec(X, Max(0, ColWidths[I] + LineWidth));
    Inc(X, PinnedWidth(dgpLeft) + SelectionWidth);
    Exit(Rect(X - Max(0, ColWidths[ACol]), Origin.Top, X, Origin.Bottom));
  end;
  X := Origin.Left;
  for I := LeftCol to ACol - 1 do Inc(X, Max(0, ColWidths[I] + LineWidth));
  Inc(X, PinnedWidth(dgpLeft));
  Result := Rect(X, Origin.Top, X + Max(0, ColWidths[ACol]), Origin.Bottom);
end;

function TDACDBGrid.DisplayMouseCoord(const X, Y: Integer): TGridCoord;
var I, R: Integer; Bounds, Clipped: TRect;
begin
  Result := MakeGridCoord(-1, -1);
  if not FullClientRect.Contains(Point(X,Y)) then Exit;
  R := inherited MouseCoord(0, Y).Y;
  if (R < 0) or (R >= RowCount) then Exit;
  for I := 0 to ColCount - 1 do
  begin
    Bounds := DisplayCellRect(I, R);
    IntersectRect(Clipped, Bounds, ColumnClip(I));
    if Clipped.Contains(Point(X,Y)) then Exit(MakeGridCoord(I,R));
  end;
end;

function TDACDBGrid.ResizeColumnAt(const X, Y: Integer; out Direction: Integer): Integer;
var I: Integer; R, Clip: TRect;
begin
  Result := -1; Direction := 1;
  if (Y < 0) or (Y >= EffectiveHeaderHeight) then Exit;
  for I := 0 to Columns.Count - 1 do
  begin
    if not Columns[I].Visible then Continue;
    R := DisplayCellRect(DataToRawColumn(I), 0); Clip := ColumnClip(DataToRawColumn(I));
    if R.IsEmpty then Continue;
    if Columns[I].PinPosition = dgpRight then
    begin
      if (R.Left >= Clip.Left) and (Abs(X - R.Left) <= Pixels(3)) then
      begin Direction := -1; Exit(I); end;
    end
    else if (R.Right <= Clip.Right) and (Abs(X - R.Right) <= Pixels(3)) then Exit(I);
  end;
end;

procedure TDACDBGrid.FinishColumnPaint(const TextStart: Integer; const Clip: TRect);
begin
  while FTextClips.Count < FTextItems.Count do FTextClips.Add(Clip);
  FSurfaceBuffer.Surface.Canvas.Restore;
end;

procedure TDACDBGrid.SelectDisplayColumn(const Index: Integer);
begin
  if (Index < 0) or (Index >= Columns.Count) or not Columns[Index].AllowFocus then Exit;
  if Columns[Index].PinPosition = dgpNone then SelectedIndex := Index
  else if SelectedIndex <> Index then
  begin
    ColExit;
    MoveColRow(DataToRawColumn(Index), Row, True, False);
    ColEnter;
  end;
end;

'''+s[end:]
# Own geometry for every custom hit test. Base mouse handlers get native coordinates.
s=s.replace('MouseCoord(X, Y)', 'DisplayMouseCoord(X, Y)')
s=s.replace('MouseCoord(AMessage.HintInfo^.CursorPos.X, AMessage.HintInfo^.CursorPos.Y)', 'DisplayMouseCoord(AMessage.HintInfo^.CursorPos.X, AMessage.HintInfo^.CursorPos.Y)')
# Full physical bounds are used for input, not the logical native viewport.
s=s.replace('(X >= ClientWidth)', '(X >= FullClientRect.Right)')
s=s.replace('(X < ClientWidth)', '(X < FullClientRect.Right)')
# Paint clips both chrome and the queued native text per column.
for marker in ['procedure TDACDBGrid.DrawDataRows;', 'procedure TDACDBGrid.DrawHeaders;']:
    a=s.index(marker); b=s.index('\nend;',a)+len('\nend;')
    part=s[a:b]
    part=part.replace('  LRect: TRect;', '  LRect, Clip: TRect;\n  TextStart: Integer;',1)
    needle='        if FSelectionOptions.Enabled and (LRawColumn = 0) then' if 'DrawDataRows' in marker else '    if FSelectionOptions.Enabled and (LRawColumn = 0) then'
    indent='        ' if 'DrawDataRows' in marker else '    '
    part=part.replace(needle,indent+'''Clip := ColumnClip(LRawColumn);
'''+indent+'''if not IntersectRect(Clip, Clip, LRect) then Continue;
'''+indent+'''TextStart := FTextItems.Count;
'''+indent+'''FSurfaceBuffer.Surface.Canvas.Save;
'''+indent+'''FSurfaceBuffer.Surface.Canvas.ClipRect(TRectF.Create(Clip));
'''+indent+'''try
'''+needle,1)
    if 'DrawDataRows' in marker:
        part=part.replace('            LTokens, EffectivePPI);\n      end;', '            LTokens, EffectivePPI);\n        finally FinishColumnPaint(TextStart, Clip); end;\n      end;',1)
    else:
        part=part.replace('      LTokens, FTextItems, EffectivePPI);\n  end;', '      LTokens, FTextItems, EffectivePPI);\n    finally FinishColumnPaint(TextStart, Clip); end;\n  end;',1)
    s=s[:a]+part+s[b:]
s=s.replace('  FTextItems.Clear;', '  FTextItems.Clear;\n  FTextClips.Clear;',1)
s=s.replace('    EffectivePPI, FTextItems);', '    EffectivePPI, FTextItems, FTextClips);',1)
# Empty/loading text is also restricted to the central band.
s=s.replace('  FFramePainter.DrawBorder(FSurfaceBuffer.Surface.Canvas', '  while FTextClips.Count < FTextItems.Count do FTextClips.Add(ScrollableRect);\n  FFramePainter.DrawBorder(FSurfaceBuffer.Surface.Canvas',1)
# Pinned action keys do not scroll the native viewport.
s=s.replace('      if AEnterMode then\n      begin\n        CellBounds', '      if AEnterMode and (GetColumns[I].PinPosition = dgpNone) then\n      begin\n        CellBounds',1)
s=s.replace('if not FRowSelectionEnabled then SelectedIndex := I;', 'if not FRowSelectionEnabled then SelectDisplayColumn(I);',1)
s=s.replace('if not FRowSelectionEnabled then SelectedIndex := Column.Index;', 'if not FRowSelectionEnabled then SelectDisplayColumn(Column.Index);',1)
s=s.replace('if Columns[I].Visible and not Columns[I].AllowFocus then Restricted := True;', 'if Columns[I].Visible and (not Columns[I].AllowFocus or\n      (Columns[I].PinPosition <> dgpNone)) then Restricted := True;',1)
s=s.replace('      SelectedIndex := Target;', '      SelectDisplayColumn(Target);',1)
# Pin columns are logical columns with zero native scroll extent. Preserve their real Width.
a=s.index('procedure TDACDBGrid.SetColumnAttributes;'); b=s.index('procedure TDACDBGrid.SetColumns',a)
s=s[:a]+'''procedure TDACDBGrid.SetColumnAttributes;
var I: Integer;
begin
  if FApplyingPinnedLayout or ([csLoading, csDestroying] * ComponentState <> []) then Exit;
  CancelActionInteraction;
  ClearHover;
  FApplyingPinnedLayout := True;
  try
    inherited;
    ClampColumnWidths;
    for I := 0 to Columns.Count - 1 do
      if Columns[I].PinPosition <> dgpNone then ColWidths[DataToRawColumn(I)] := 0;
    if (SelectionWidth > 0) and (ColCount > 0) then ColWidths[0] := SelectionWidth;
    if PinnedWidth(dgpLeft) + PinnedWidth(dgpRight) > 0 then DoubleBuffered := False;
  finally FApplyingPinnedLayout := False; end;
  // The base row-metrics hook refreshes native ranges/editor bounds without
  // copying the zero scroll extents back into persistent column Width values.
  inherited RowHeightsChanged;
  ApplyDensityMetrics;
end;

'''+s[b:]
s=s.replace('procedure TDACDBGrid.ColWidthsChanged;\nbegin', 'procedure TDACDBGrid.ColWidthsChanged;\nvar I: Integer;\nbegin\n  if FApplyingPinnedLayout then Exit;',1)
a=s.index('procedure TDACDBGrid.ColWidthsChanged;');b=s.index('function TDACDBGrid.CreateColumns',a)
part=s[a:b].replace('  inherited;','''  if PinnedWidth(dgpLeft) + PinnedWidth(dgpRight) = 0 then inherited
  else
  begin
    Columns.BeginUpdate;
    try
      for I := 0 to Columns.Count - 1 do
        if (Columns[I].PinPosition = dgpNone) and Columns[I].Visible then
          Columns[I].Width := ColWidths[DataToRawColumn(I)];
    finally Columns.EndUpdate; end;
    inherited RowHeightsChanged;
  end;''',1)
s=s[:a]+part+s[b:]
# Column geometry can change without a dataset layout callback (Assign, DFM, visibility).
s=s.replace('  ClampColumnWidths;\n  if (FLayoutManager', '  ClampColumnWidths;\n  SetColumnAttributes;\n  Redraw;\n  if (FLayoutManager',1)
# Additional mouse behaviour is patched separately below.
wr(prefix+'.pas',s)
