from pathlib import Path
p=Path(r'M:\Delphi Componentes\DAC-DelphiComponents\Source\Controls\DAC.Components.Controls.DBGrid.pas')
s=p.read_bytes().decode('cp1252').replace('\r\n','\n')
s=s.replace('    procedure FinishColumnPaint(const TextStart: Integer; const Clip: TRect);','    procedure FinishColumnPaint(const Clip: TRect);\n    procedure CancelPinnedInteraction;')
s=s.replace('procedure TDACDBGrid.FinishColumnPaint(const TextStart: Integer; const Clip: TRect);','procedure TDACDBGrid.FinishColumnPaint(const Clip: TRect);')
s=s.replace('  TextStart: Integer;\n','').replace('        TextStart := FTextItems.Count;\n','').replace('    TextStart := FTextItems.Count;\n','').replace('FinishColumnPaint(TextStart, Clip)','FinishColumnPaint(Clip)')
s=s.replace('    function FullClientRect: TRect;\n    function ScrollableRect: TRect;\n','',1)
s=s.replace('  public\n    constructor Create(AOwner:', '  public\n    function FullClientRect: TRect;\n    function ScrollableRect: TRect;\n    constructor Create(AOwner:',1)
i=s.index('procedure TDACDBGrid.SyncWideScroll;')
s=s[:i]+'''procedure TDACDBGrid.CancelPinnedInteraction;
var Captured: Boolean;
begin
  Captured := FOverlayMouse or (FResizeKey <> '');
  FOverlayMouse := False; FResizeKey := '';
  if Captured and HandleAllocated and (GetCapture = Handle) then MouseCapture := False;
end;

'''+s[i:]
s=s.replace("      FWideOffset := EnsureRange(FWideOffset, 0, Max(0, Columns[I].Width - ScrollableRect.Width));", "      if Columns[I].Width <= ScrollableRect.Width then\n      begin FWideKey := ''; FWideOffset := 0; Exit; end;\n      FWideOffset := EnsureRange(FWideOffset, 0, Max(0, Columns[I].Width - ScrollableRect.Width));",1)
s=s.replace('procedure TDACDBGrid.CMEnabledChanged(var AMessage: TMessage);\nbegin', 'procedure TDACDBGrid.CMEnabledChanged(var AMessage: TMessage);\nbegin\n  CancelPinnedInteraction;',1)
s=s.replace('  LPendingMessage: TMsg;\n  LTrack: TTrackMouseEvent;\nbegin', '  LPendingMessage: TMsg;\n  LTrack: TTrackMouseEvent;\nbegin\n  CancelPinnedInteraction;',1)
s=s.replace('  Inc(FDataRevision);\n  CancelActionInteraction;', '  Inc(FDataRevision);\n  CancelPinnedInteraction;\n  CancelActionInteraction;',1)
s=s.replace("begin FOverlayMouse := False; FResizeKey := ''; end;", 'CancelPinnedInteraction;',1)
# Do not let a double-click become a second fixed-header sort/checkbox toggle.
s=s.replace('    if not Focused then SetFocus;\n    if Cell.Y >= FixedRows then', '''    if not Focused then SetFocus;
    if ssDouble in Shift then
    begin
      if Cell.Y >= FixedRows then DblClick;
      FOverlayMouse := True; FOverlayDown := MakeGridCoord(-1,-1);
      MouseCapture := True;
      Exit;
    end;
    if Cell.Y >= FixedRows then''',1)
# Center empty/loading text in the scrollable band too.
s=s.replace('    FFramePainter.DrawState(FSurfaceBuffer.Surface.Canvas, LBounds,', '    FFramePainter.DrawState(FSurfaceBuffer.Surface.Canvas, TRectF.Create(ScrollableRect),',1)
p.write_bytes(s.replace('\n','\r\n').encode('cp1252'))
