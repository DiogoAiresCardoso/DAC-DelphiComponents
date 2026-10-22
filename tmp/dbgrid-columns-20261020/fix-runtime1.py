from pathlib import Path
def edit(name, f):
 p=Path('Source/Controls/DAC.Components.Controls.DBGrid'+name+'.pas');s=p.read_bytes().decode('cp1252').replace('\r\n','\n');p.write_bytes(f(s).replace('\n','\r\n').encode('cp1252'))
def adapter(s):
 return s.replace("IndexName := 'DAC_GRID_' + StringReplace(GUIDToString(Id), '-', '', [rfReplaceAll]);", "// MIDAS index names are limited to 31 characters.\n        IndexName := 'DAC_GRID_' + Copy(StringReplace(Copy(GUIDToString(Id), 2, 36),\n          '-', '', [rfReplaceAll]), 1, 22);")
edit('.ClientDataSetSort',adapter)
def grid(s):
 s=s.replace('  if not FActionMouse then inherited;\n  if (FHeaderKey', '''  if not FActionMouse then
  begin
    // Native fixed-cell tracking invalidates on every move, even inside the
    // same header. Chrome tracking is owned here; retain native drag/resize.
    if FGridState <> gsNormal then inherited
    else if Assigned(OnMouseMove) then OnMouseMove(Self, Shift, X, Y);
  end;
  if (FHeaderKey''')
 s=s.replace('        Text := TDACDBGridFieldTextResolver.Resolve(Column.Field);','''        if (Column.Field <> nil) and Column.Field.IsBlob then Text := Column.Field.AsString
        else Text := TDACDBGridFieldTextResolver.Resolve(Column.Field);''')
 needle='            FZebraEnabled, LTokens, FTextItems, EffectivePPI);\n      end;'
 assert s.count(needle)==1
 s=s.replace(needle,'''            FZebraEnabled, LTokens, FTextItems, EffectivePPI);
        if Focused and not FActionMode and (LRawColumn = Col) and (LRawRow = Row) then
          FCellPainter.DrawFocus(FSurfaceBuffer.Surface.Canvas, TRectF.Create(LRect),
            LTokens, EffectivePPI);
      end;''')
 return s
edit('',grid)
def painter(s):
 s=s.replace('    procedure Draw(const','''    procedure DrawFocus(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ATokens: TDACControlTokens; const APPI: Integer);
    procedure Draw(const''',1)
 at=s.index('procedure TDACDBGridCellPainter.DrawCheckBox',s.index('implementation'))
 s=s[:at]+'''procedure TDACDBGridCellPainter.DrawFocus(const ACanvas: ISkCanvas;
  const ARect: TRectF; const ATokens: TDACControlTokens; const APPI: Integer);
var Inset: Single;
begin
  Inset := Max(1, APPI / 96);
  FRenderer.StrokeRoundRect(ACanvas, TRectF.Create(ARect.Left + Inset,
    ARect.Top + Inset, ARect.Right - Inset, ARect.Bottom - Inset),
    ATokens.DataGridFocus, 0, Inset);
end;

'''+s[at:]
 return s
edit('.CellPainter',painter)
