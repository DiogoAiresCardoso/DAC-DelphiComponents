from pathlib import Path
r=Path(r'M:\Delphi Componentes\DAC-DelphiComponents')
def rd(p): return p.read_bytes().decode('cp1252').replace('\r\n','\n')
def wr(p,s): p.write_bytes(s.replace('\n','\r\n').encode('cp1252'))
p=r/'Source/Controls/DAC.Components.Controls.DBGrid.CellPainter.pas'
s=rd(p).replace('    procedure DrawFocus(', '    procedure DrawRowMarker(const ACanvas: ISkCanvas; const ARect: TRectF;\n      const ATokens: TDACControlTokens; const APPI: Integer);\n    procedure DrawFocus(',1)
i=s.index('procedure TDACDBGridCellPainter.DrawFocus')
s=s[:i]+'''procedure TDACDBGridCellPainter.DrawRowMarker(const ACanvas: ISkCanvas;
  const ARect: TRectF; const ATokens: TDACControlTokens; const APPI: Integer);
begin
  FRenderer.FillRoundRect(ACanvas, TRectF.Create(ARect.Left, ARect.Top,
    ARect.Left + 4 * Max(1, APPI / 96), ARect.Bottom), ATokens.DataGridFocus, 0);
end;

'''+s[i:]
wr(p,s)
p=r/'Source/Controls/DAC.Components.Controls.DBGrid.pas'
s=rd(p)
a=s.index('procedure TDACDBGrid.DrawDataRows;'); b=s.index('procedure TDACDBGrid.DrawHeaders;',a)
part=s[a:b]
part=part.replace(', LRawColumn = 0, FZebraEnabled',', False, FZebraEnabled')
part=part.replace(', LRawColumn = 0,\n',', False,\n')
part=part.replace('True, LChecked, True, FZebraEnabled', 'True, LChecked, False, FZebraEnabled')
part=part.replace('      end;\n    end;\n  finally\n    DataLink.ActiveRecord', '''      end;
      if LSelected then
      begin
        // The row marker belongs to the grid edge, independent of raw column 0.
        LRect := CellRect(LeftCol, LRawRow);
        LRect.Left := 0; LRect.Right := FullClientRect.Right;
        FCellPainter.DrawRowMarker(FSurfaceBuffer.Surface.Canvas,
          TRectF.Create(LRect), LTokens, EffectivePPI);
      end;
    end;
  finally
    DataLink.ActiveRecord''',1)
s=s[:a]+part+s[b:]
wr(p,s)
p=Path(r'M:\MaxxSoft\MaxxRural\Desktop\maxxrural\MaxxRural\src\Tests\Teste.MovimentoBancario.ColunasGrid.pas')
s=rd(p).replace('    [Test] procedure FixasTecladoSegueOrdemVisual;', '    [Test] procedure IndicadorDeLinhaSelecionadaFixoAEsquerda;\n    [Test] procedure FixasTecladoSegueOrdemVisual;',1)
i=s.index('initialization')
s=s[:i]+'''procedure TMovimentoBancarioColunasGridTests.IndicadorDeLinhaSelecionadaFixoAEsquerda;
var B: TBitmap; Expected: TColor; I, Y: Integer;
begin
  G.Width := 650; C('OPCOES').PinPosition := dgpRight;
  Y := G.ActionRect(C('OPCOES').Index,0,0).CenterPoint.Y;
  B := TBitmap.Create;
  try
    B.SetSize(G.Width,G.Height); G.PaintTo(B.Canvas.Handle,0,0);
    Expected := B.Canvas.Pixels[1,Y];
    C('OPCOES').Index := 0;
    for I := 0 to 5 do
    begin
      G.Perform(WM_HSCROLL,SB_LINERIGHT,0); G.PaintTo(B.Canvas.Handle,0,0);
      Assert.AreEqual(Expected,B.Canvas.Pixels[1,Y], 'Marcador da selecao acompanha a borda, nao a primeira coluna de dados.');
    end;
  finally B.Free; end;
end;

'''+s[i:]
wr(p,s)
