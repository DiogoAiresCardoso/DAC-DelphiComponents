from pathlib import Path
import shutil
r=Path(r'M:\MaxxSoft\MaxxRural\Desktop\maxxrural')
t=r/'MaxxRural/src/Tests'; out=t/'Resultados/20261021-grid-gaps'
out.mkdir(exist_ok=True)
for n in ['compilar.cmd','compilar-desktop.cmd','executar-testes.ps1']:
    shutil.copyfile(t/'Resultados/20261021-grid-pinned'/n,out/n)
p=t/'Teste.MovimentoBancario.ColunasGrid.pas'
s=p.read_bytes().decode('cp1252').replace('\r\n','\n')
at=s.index('    [Test] procedure IndicadorDeLinhaSelecionadaFixoAEsquerda;')
s=s[:at]+'''    [TestCase('claro96','96,1,1')]
    [TestCase('escuro96','96,0,1')]
    [TestCase('claro120','120,1,1')]
    [TestCase('escuro120','120,0,1')]
    [TestCase('claro144','144,1,1')]
    [TestCase('escuro144','144,0,1')]
    [TestCase('claro192','192,1,1')]
    [TestCase('escuro192','192,0,1')]
    [TestCase('desabilitadoClaro','96,1,0')]
    [TestCase('desabilitadoEscuro','96,0,0')]
    procedure FundoDaLinhaContinuaAteOpcoes(const PPI, Tema, Habilitado: Integer);
'''+s[at:]
at=s.index('initialization')
s=s[:at]+'''procedure TMovimentoBancarioColunasGridTests.FundoDaLinhaContinuaAteOpcoes(
  const PPI, Tema, Habilitado: Integer);
var B: TBitmap; I, X, LastRight, GapX, RIndex: Integer;
  RightCell, R: TRect; Expected, Line: TColor;
begin
  for I := 0 to G.Columns.Count - 1 do G.Columns[I].Width := 180;
  C('OPCOES').Width := 196; C('OPCOES').PinPosition := dgpRight;
  G.SetTestPPI(PPI); G.SetBounds(8,8,980,390);
  if Tema = 1 then G.ThemeMode := dtmLight else G.ThemeMode := dtmDark;
  G.Enabled := Habilitado = 1;
  G.Perform(WM_HSCROLL,SB_RIGHT,0); G.Perform(CM_MOUSELEAVE,0,0); G.Update;
  RightCell := G.BoundsOf(C('OPCOES').Index,0); LastRight := 0;
  for I := 0 to G.Columns.Count - 1 do
    if G.Columns[I].PinPosition = dgpNone then
    begin
      R := G.BoundsOf(I,0);
      if not R.IsEmpty then LastRight := Max(LastRight,R.Right);
    end;
  Assert.IsTrue(RightCell.Left - LastRight > 8,'Cenario deve conter espaco livre entre centro e coluna fixa.');
  B := TBitmap.Create;
  try
    B.SetSize(G.Width,G.Height); G.PaintTo(B.Canvas.Handle,0,0);
    // Selected row and zebra row must both continue across the unused center.
    for RIndex := 0 to 1 do
    begin
      RightCell := G.BoundsOf(C('OPCOES').Index,RIndex);
      Expected := B.Canvas.Pixels[RightCell.Right-3,RightCell.CenterPoint.Y];
      Line := B.Canvas.Pixels[RightCell.Right-3,RightCell.Bottom-1];
      for X := LastRight+1 to RightCell.Left-1 do
      begin
        Assert.AreEqual(Expected,B.Canvas.Pixels[X,RightCell.CenterPoint.Y],
          Format('Fundo interrompido: linha=%d x=%d PPI=%d tema=%d',[RIndex,X,PPI,Tema]));
        Assert.AreEqual(Line,B.Canvas.Pixels[X,RightCell.Bottom-1],
          Format('Separador interrompido: linha=%d x=%d',[RIndex,X]));
      end;
    end;
    RightCell := G.BoundsOf(C('OPCOES').Index,0); GapX := (LastRight+RightCell.Left) div 2;
    G.MoveAt(Point(GapX,RightCell.CenterPoint.Y));
    Assert.AreEqual(Integer(crDefault),Integer(G.Cursor),'Fundo preenchido nao deve virar botao.');
    G.ClickAt(Point(GapX,RightCell.CenterPoint.Y)); Assert.AreEqual(0,G.Activations);
    G.PaintTo(B.Canvas.Handle,0,0);
    Expected := B.Canvas.Pixels[RightCell.Right-3,RightCell.CenterPoint.Y];
    Assert.AreEqual(Expected,B.Canvas.Pixels[GapX,RightCell.CenterPoint.Y]);
  finally B.Free; end;
end;

'''+s[at:]
s=s.replace('uses System.SysUtils, System.Variants, System.IOUtils, System.RegularExpressions,','uses System.SysUtils, System.Variants, System.IOUtils, System.RegularExpressions, System.Math,',1)
p.write_bytes(s.replace('\n','\r\n').encode('cp1252'))
