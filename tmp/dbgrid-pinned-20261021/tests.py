from pathlib import Path
import shutil
r=Path(r'M:\MaxxSoft\MaxxRural\Desktop\maxxrural')
t=r/'MaxxRural/src/Tests'
ev=t/'Resultados/20261021-grid-pinned'
ev.mkdir(exist_ok=True)
for n in ['compilar.cmd','compilar-desktop.cmd','executar-testes.ps1']:
    shutil.copyfile(t/'Resultados/20261021-grid-scroll-focus'/n,ev/n)
def rd(p): return p.read_bytes().decode('cp1252').replace('\r\n','\n')
def wr(p,s): p.write_bytes(s.replace('\n','\r\n').encode('cp1252'))
p=r/'source/view/View.MovimentoBancario.dfm'
s=rd(p).replace("              LayoutKey = 'OPCOES'", "              PinPosition = dgpRight\n              LayoutKey = 'OPCOES'")
assert s.count('PinPosition = dgpRight')==3
wr(p,s)
p=t/'Teste.MovimentoBancario.ColunasGrid.pas'
s=rd(p)
needle='    [Test] procedure AllowFocusNavegacaoMouseETeclado;'
s=s.replace(needle,'''    [TestCase('claro96','96,1')]
    [TestCase('escuro96','96,0')]
    [TestCase('claro144','144,1')]
    [TestCase('escuro144','144,0')]
    [TestCase('claro192','192,1')]
    [TestCase('escuro192','192,0')]
    procedure FixasNaoMovemNemRecebemPixelsDoCentro(const PPI, Tema: Integer);
    [Test] procedure FixasMantemAcoesMouseTecladoEIdentidade;
    [Test] procedure FixasMantemLarguraLayoutAssignEStreaming;
    [Test] procedure FixasCabecalhoOrdenaMoveERedimensiona;
    [Test] procedure FixasSelecaoCheckboxEsquerda;
    [Test] procedure FixasJanelaEstreitaDatasetVazioEFechado;
'''+needle,1)
s=s.replace("    Assert.IsTrue(Other.Columns[0].AllowFocus, 'DFM antigo preserva foco.');", "    Assert.IsTrue(Other.Columns[0].AllowFocus, 'DFM antigo preserva foco.');\n    Assert.AreEqual(Integer(dgpNone), Integer(Other.Columns[0].PinPosition));",1)
idx=s.index('initialization')
s=s[:idx]+'''procedure TMovimentoBancarioColunasGridTests.FixasNaoMovemNemRecebemPixelsDoCentro(const PPI, Tema: Integer);
var A, B: TBitmap; L, R, L2, R2, Client: TRect; X, Y, I, Different: Integer;
begin
  C('N').PinPosition := dgpLeft; C('OPCOES').PinPosition := dgpRight;
  G.Selection.Enabled := True;
  G.SetTestPPI(PPI); G.SetBounds(8,8,980,390);
  if Tema = 0 then G.ThemeMode := dtmDark else G.ThemeMode := dtmLight;
  D.Edit; D.FieldByName('TXT').AsString := StringOfChar('W',140); D.Post;
  G.Perform(CM_MOUSELEAVE,0,0); Pump;
  Winapi.Windows.GetClientRect(G.Handle, Client);
  L := G.BoundsOf(C('N').Index,0); R := G.BoundsOf(C('OPCOES').Index,0);
  Assert.AreEqual(MulDiv(G.Selection.Width,PPI,96), L.Left);
  Assert.AreEqual(Client.Right, R.Right);
  Assert.AreEqual(MulDiv(196,PPI,96), R.Width);
  A := TBitmap.Create; B := TBitmap.Create;
  try
    A.PixelFormat := pf32bit; A.SetSize(G.Width,G.Height);
    B.PixelFormat := pf32bit; B.SetSize(G.Width,G.Height);
    G.PaintTo(A.Canvas.Handle,0,0);
    for I := 0 to 5 do
    begin
      G.Perform(WM_HSCROLL,SB_LINERIGHT,0); G.Update;
      L2 := G.BoundsOf(C('N').Index,0); R2 := G.BoundsOf(C('OPCOES').Index,0);
      Assert.IsTrue(EqualRect(L,L2)); Assert.IsTrue(EqualRect(R,R2));
      Assert.AreEqual(MulDiv(196,PPI,96), C('OPCOES').Width, 'Extensao nativa zero nao deve apagar Width.');
      G.PaintTo(B.Canvas.Handle,0,0); Different := 0;
      for Y := 1 to Client.Bottom - 2 do
        for X := 1 to Client.Right - 2 do
          if (X < L.Right) or (X >= R.Left) then
            if PCardinal(NativeUInt(A.ScanLine[Y])+NativeUInt(X)*4)^ <>
               PCardinal(NativeUInt(B.ScanLine[Y])+NativeUInt(X)*4)^ then Inc(Different);
      Assert.AreEqual(0,Different,'Centro nao pode desenhar sobre selecao, dados fixos ou acoes.');
    end;
  finally B.Free; A.Free; end;
end;

procedure TMovimentoBancarioColunasGridTests.FixasMantemAcoesMouseTecladoEIdentidade;
var R: TRect; Key: string; Pos, I: Integer;
begin
  G.Width := 650; C('OPCOES').PinPosition := dgpRight;
  C('OPCOES').Index := 0; // Pin is independent of collection/display order.
  for I := 0 to 3 do G.Perform(WM_HSCROLL,SB_LINERIGHT,0);
  Pos := GetScrollPos(G.Handle,SB_HORZ); Key := D.FieldByName('MOV_COD').AsString;
  R := G.ActionRect(0,1,0); Assert.IsFalse(R.IsEmpty);
  G.MoveAt(R.CenterPoint); Assert.AreEqual(Integer(crHandPoint),Integer(G.Cursor));
  G.ClickAt(R.CenterPoint); Assert.AreEqual(1,G.Activations);
  Assert.AreEqual('0000000002',VarToStr(G.LastContext.ValueOf('MOV_COD')));
  Assert.AreNotEqual(Key,VarToStr(G.LastContext.ValueOf('MOV_COD')));
  Assert.AreEqual(0,G.SortRequests); Assert.AreEqual(Pos,GetScrollPos(G.Handle,SB_HORZ));
  Key := D.FieldByName('MOV_COD').AsString;
  G.PressKey(VK_ESCAPE); G.PressKey(VK_F2); G.PressKey(VK_RETURN); G.ReleaseKey(VK_RETURN);
  Assert.AreEqual(2,G.Activations); Assert.AreEqual(Key,VarToStr(G.LastContext.ValueOf('MOV_COD')));
  Assert.AreEqual(Pos,GetScrollPos(G.Handle,SB_HORZ),'F2 em coluna fixa nao deve rolar.');
  G.DisabledAction := 'detalhes'; G.ClickAt(R.CenterPoint); Assert.AreEqual(2,G.Activations);
  G.HiddenAction := 'detalhes'; Assert.AreEqual('Editar',G.HintAt(R.CenterPoint));
  G.DisabledAction := ''; G.HiddenAction := '';
  R := G.ActionRect(0,G.CurrentVisibleRow,0);
  G.DownAt(R.CenterPoint); G.Perform(WM_HSCROLL,SB_LINELEFT,0); G.UpAt(R.CenterPoint);
  Assert.AreEqual(2,G.Activations,'Rolagem cancela acao pendente.');
end;

procedure TMovimentoBancarioColunasGridTests.FixasMantemLarguraLayoutAssignEStreaming;
var Other: TDACActionTestGrid; Stream: TMemoryStream; R: TRect;
begin
  C('OPCOES').PinPosition := dgpRight; C('N').PinPosition := dgpLeft;
  C('OPCOES').Width := 210; EnableLayout; G.SaveLayout;
  C('OPCOES').Index := 0; C('OPCOES').Width := 300; G.LoadLayout;
  Assert.AreEqual(210,C('OPCOES').Width);
  Assert.AreEqual(Integer(dgpRight),Integer(C('OPCOES').PinPosition));
  Other := TDACActionTestGrid.Create(FForm); Stream := TMemoryStream.Create;
  try
    Other.Parent := FForm; Other.Columns.Assign(G.Columns);
    Assert.AreEqual(Integer(dgpLeft),Integer(Other.Columns[0].PinPosition));
    Stream.WriteComponent(Other); Stream.Position := 0; Stream.ReadComponent(Other);
    Assert.AreEqual(Integer(dgpRight),Integer(Other.Columns[6].PinPosition));
    Assert.AreEqual(210,Other.Columns[6].Width);
  finally Stream.Free; Other.Free; end;
  G.SetColumnVisible('N',False); G.SetColumnVisible('N',True);
  R := G.BoundsOf(C('N').Index,0); Assert.AreEqual(0,R.Left);
  G.Recreate; R := G.BoundsOf(C('OPCOES').Index,0);
  Assert.AreEqual(210,R.Width); Assert.AreEqual(210,C('OPCOES').Width);
end;

procedure TMovimentoBancarioColunasGridTests.FixasCabecalhoOrdenaMoveERedimensiona;
var P, Q: TPoint; R: TRect; W: Integer;
begin
  C('OPCOES').PinPosition := dgpRight; C('N').PinPosition := dgpLeft;
  G.ClickAt(G.HeaderPoint(C('N').Index)); Assert.AreEqual(1,G.SortRequests);
  G.ClickAt(G.HeaderPoint(C('OPCOES').Index)); Assert.AreEqual(1,G.SortRequests);
  R := G.BoundsOf(C('OPCOES').Index); W := C('OPCOES').Width;
  P := Point(R.Left,R.CenterPoint.Y); Q := Point(P.X-28,P.Y);
  G.DownAt(P); G.DragAt(Q); G.UpAt(Q);
  Assert.AreEqual(W+28,C('OPCOES').Width); Assert.AreEqual(1,G.SortRequests);
  P := G.HeaderPoint(C('DT').Index); Q := G.HeaderPoint(C('TXT').Index);
  G.DownAt(P); G.DragAt(Q); G.UpAt(Q);
  Assert.AreEqual(3,C('DT').Index); Assert.AreEqual(1,G.SortRequests);
  R := G.BoundsOf(C('OPCOES').Index); Winapi.Windows.GetClientRect(G.Handle,R);
  Assert.AreEqual(R.Right,G.BoundsOf(C('OPCOES').Index).Right);
end;

procedure TMovimentoBancarioColunasGridTests.FixasSelecaoCheckboxEsquerda;
var Buffer: TClientDataSet; R: TRect; P: TPoint; I: Integer; Pos: Integer;
begin
  Buffer := TClientDataSet.Create(FForm);
  Buffer.FieldDefs.Add('COD_EMP',ftString,10); Buffer.FieldDefs.Add('MOV_COD',ftString,10);
  Buffer.FieldDefs.Add('SEL',ftBoolean); Buffer.FieldDefs.Add('N',ftInteger); Buffer.CreateDataSet;
  Buffer.AppendRecord(['0000000007','0000000001',False,2]);
  Buffer.AppendRecord(['0000000007','0000000002',False,10]); Buffer.First;
  S.DataSet := Buffer; G.Selection.FieldName := 'SEL'; G.Selection.Enabled := True;
  C('OPCOES').PinPosition := dgpRight; G.Width := 600;
  for I := 0 to 4 do G.Perform(WM_HSCROLL,SB_LINERIGHT,0);
  Pos := GetScrollPos(G.Handle,SB_HORZ);
  R := G.BoundsOf(C('N').Index,1); P := Point(G.Selection.Width div 2,R.CenterPoint.Y);
  G.ClickAt(P); Assert.AreEqual('0000000002',Buffer.FieldByName('MOV_COD').AsString);
  Assert.IsTrue(Buffer.FieldByName('SEL').AsBoolean);
  Assert.AreEqual(Pos,GetScrollPos(G.Handle,SB_HORZ)); Assert.AreEqual(0,G.Activations);
  G.ClickAt(Point(P.X,10)); Buffer.First; Assert.IsTrue(Buffer.FieldByName('SEL').AsBoolean);
  Buffer.Next; Assert.IsTrue(Buffer.FieldByName('SEL').AsBoolean);
end;

procedure TMovimentoBancarioColunasGridTests.FixasJanelaEstreitaDatasetVazioEFechado;
var I: Integer; R: TRect; B: TBitmap;
begin
  C('N').PinPosition := dgpLeft; C('OPCOES').PinPosition := dgpRight;
  G.Selection.Enabled := True; G.Width := 130;
  for I := 0 to 2 do begin R := G.ActionRect(C('OPCOES').Index,0,I); Assert.IsTrue(R.IsEmpty); end;
  G.ClickAt(Point(100,75)); Assert.AreEqual(0,G.Activations);
  B := TBitmap.Create;
  try
    B.SetSize(G.Width,G.Height); G.PaintTo(B.Canvas.Handle,0,0);
    D.EmptyDataSet; G.PaintTo(B.Canvas.Handle,0,0);
    D.Close; G.PaintTo(B.Canvas.Handle,0,0);
    Assert.AreEqual(0,G.Activations);
  finally B.Free; end;
end;

'''+s[idx:]
wr(p,s)
