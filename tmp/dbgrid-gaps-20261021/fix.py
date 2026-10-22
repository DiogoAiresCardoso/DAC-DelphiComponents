from pathlib import Path
r=Path(r'M:\Delphi Componentes\DAC-DelphiComponents\Source\Controls')
def rd(p): return p.read_bytes().decode('cp1252').replace('\r\n','\n')
def wr(p,s): p.write_bytes(s.replace('\n','\r\n').encode('cp1252'))
p=r/'DAC.Components.Controls.DBGrid.CellPainter.pas'
s=rd(p)
s=s.replace('    FRenderer: TDACSkiaRenderer;', '''    FRenderer: TDACSkiaRenderer;
    function BackgroundColor(const ARowIndex: Integer;
      const ASelected, AHot, AEnabled, AZebraEnabled: Boolean;
      const ATokens: TDACControlTokens): TAlphaColor;''',1)
s=s.replace('    procedure DrawRowMarker(', '''    procedure DrawRowBackground(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ARowIndex: Integer; const ASelected, AEnabled, AZebraEnabled: Boolean;
      const ATokens: TDACControlTokens; const APPI: Integer);
    procedure DrawRowMarker(''',1)
a=s.index('    LBackground := ATokens.DataGridBackground;')
b=s.index('\n    FRenderer.FillRoundRect',a)
s=s[:a]+'''    LBackground := BackgroundColor(ARowIndex, ASelected, AHot, AEnabled,
      AZebraEnabled, ATokens);
'''+s[b:]
i=s.index('procedure TDACDBGridCellPainter.DrawRowMarker')
s=s[:i]+'''function TDACDBGridCellPainter.BackgroundColor(const ARowIndex: Integer;
  const ASelected, AHot, AEnabled, AZebraEnabled: Boolean;
  const ATokens: TDACControlTokens): TAlphaColor;
begin
  Result := ATokens.DataGridBackground;
  if not AEnabled then Result := ATokens.DataGridEmpty
  else if ASelected then Result := ATokens.DataGridSelection
  else if AHot then Result := ATokens.DataGridHover
  else if AZebraEnabled and Odd(ARowIndex) then Result := ATokens.DataGridRowAlternate;
end;

procedure TDACDBGridCellPainter.DrawRowBackground(const ACanvas: ISkCanvas;
  const ARect: TRectF; const ARowIndex: Integer;
  const ASelected, AEnabled, AZebraEnabled: Boolean;
  const ATokens: TDACControlTokens; const APPI: Integer);
var R: TRectF; Scale: Single;
begin
  Scale := Max(1, APPI / 96);
  R := TRectF.Create(ARect.Left / Scale, ARect.Top / Scale,
    ARect.Right / Scale, ARect.Bottom / Scale);
  ACanvas.Save;
  ACanvas.Scale(Scale, Scale);
  try
    FRenderer.FillRoundRect(ACanvas, R, BackgroundColor(ARowIndex, ASelected,
      False, AEnabled, AZebraEnabled, ATokens), 0);
    FRenderer.DrawLine(ACanvas, PointF(R.Left, R.Bottom - 0.5),
      PointF(R.Right, R.Bottom - 0.5), ATokens.DataGridBorder, 1);
  finally ACanvas.Restore; end;
end;

'''+s[i:]
wr(p,s)
p=r/'DAC.Components.Controls.DBGrid.pas'
s=rd(p).replace('      LSelected := FRowSelectionEnabled and (LRawRow = Row);', '''      LSelected := FRowSelectionEnabled and (LRawRow = Row);
      // The last scrollable column need not end at the fixed band. Paint the
      // entire row first so selection, zebra and separators remain continuous.
      LRect := CellRect(LeftCol, LRawRow);
      LRect.Left := 0; LRect.Right := FullClientRect.Right;
      FCellPainter.DrawRowBackground(FSurfaceBuffer.Surface.Canvas,
        TRectF.Create(LRect), LDataRow, LSelected, Enabled and not FLoading,
        FZebraEnabled, LTokens, EffectivePPI);''',1)
wr(p,s)
