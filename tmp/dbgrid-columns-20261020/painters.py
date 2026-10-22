from pathlib import Path
r=Path.cwd()
for name in ['CellPainter','HeaderPainter']:
 p=r/('Source/Controls/DAC.Components.Controls.DBGrid.'+name+'.pas')
 s=p.read_bytes().decode('cp1252').replace('\r\n','\n')
 sig='const ATextItems: TList<TDACDBGridTextItem>);'
 s=s.replace(sig,'const ATextItems: TList<TDACDBGridTextItem>; const APPI: Integer = 96);',1)
 s=s.replace(sig,'const ATextItems: TList<TDACDBGridTextItem>; const APPI: Integer);',1)
 start=s.index('procedure TDACDBGrid'+name+'.Draw(')
 end=s.index('procedure TDACDBGrid'+name+'.DrawCheckBox',start)
 b=s[start:end]
 b=b.replace('  LItem: TDACDBGridTextItem;','  LItem: TDACDBGridTextItem;\n  R: TRectF;\n  Scale: Single;')
 b=b.replace('begin\n','begin\n  Scale := Max(1, APPI / 96);\n  R := TRectF.Create(ARect.Left / Scale, ARect.Top / Scale,\n    ARect.Right / Scale, ARect.Bottom / Scale);\n  ACanvas.Save;\n  ACanvas.Scale(Scale, Scale);\n  try\n',1)
 # after signature, logical drawing coordinates
 body=b.index('  LBackground :=') if name=='CellPainter' else b.index('  if APressed then')
 b=b[:body]+b[body:].replace('ARect','R')
 b=b.replace('Round(R.Left + 12), Round(R.Top),','Round((R.Left + 12) * Scale), Round(R.Top * Scale),').replace('Round(R.Right - 12), Round(R.Bottom)','Round((R.Right - 12) * Scale), Round(R.Bottom * Scale)').replace('Round(LTextRight), Round(R.Bottom)','Round(LTextRight * Scale), Round(R.Bottom * Scale)')
 b=b.replace('  ATextItems.Add(LItem);\nend;','  ATextItems.Add(LItem);\n  finally ACanvas.Restore; end;\nend;')
 if name=='CellPainter':
  b=b.replace('  if AIndicator then','  if AHot and ASelected and AEnabled then\n    FRenderer.StrokeRoundRect(ACanvas, TRectF.Create(R.Left + 1, R.Top + 1,\n      R.Right - 1, R.Bottom - 1), ATokens.DataGridHoverBorder, 0, 1);\n\n  if AIndicator then',1)
 s=s[:start]+b+s[end:]
 p.write_bytes(s.replace('\n','\r\n').encode('cp1252'))
# Make geometry available to derived grids, just like native CellRect.
p=r/'Source/Controls/DAC.Components.Controls.DBGrid.pas'
s=p.read_bytes().decode('cp1252').replace('\r\n','\n')
sig='    function DisplayCellRect(const ARawColumn, ARawRow: Integer): TRect;\n'
assert s.count(sig)==1
s=s.replace(sig,'').replace('  protected\n','  protected\n'+sig,1)
p.write_bytes(s.replace('\n','\r\n').encode('cp1252'))
p=r/'tmp/dbgrid-columns-20261020/build-runtime.cmd'
s=(r/'tmp/dbgrid-actions-20261020/build-runtime.cmd').read_text().replace('dbgrid-actions-20261020','dbgrid-columns-20261020')
p.write_text(s)
