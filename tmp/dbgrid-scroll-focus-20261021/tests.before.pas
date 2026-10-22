unit Teste.MovimentoBancario.ColunasGrid;

interface

uses System.Classes, System.Types, Vcl.Forms, Data.DB, Datasnap.DBClient,
  DUnitX.TestFramework, TestSupport.DACDBGridActions,
  DAC.Components.Controls.DBGrid.Column;

type
  [TestFixture]
  TMovimentoBancarioColunasGridTests = class
  private
    FForm: TForm;
    G: TDACActionTestGrid;
    D: TClientDataSet;
    S: TDataSource;
    LayoutFile: string;
    procedure Pump;
    function C(const Key: string): TDACDBGridColumn;
    function Sequence(const Field: string): string;
    procedure EnableLayout;
    procedure ReadRealDFM(const Aba: string);
  public
    [Setup] procedure Setup;
    [TearDown] procedure TearDown;
    [Test] procedure NumerosNulosNegativosRepetidosEIdentidade;
    [Test] procedure DatasOrdenadasPorValor;
    [Test] procedure DecimaisMantemPrecisao;
    [Test] procedure TextosAcentuadosECodigosComZeros;
    [Test] procedure CabecalhoAlternaUmaVezEIgnoraOpcoes;
    [Test] procedure ArrastarERedimensionarNaoOrdenam;
    [Test] procedure ArrastarColunaMantemCampoOrdenado;
    [Test] procedure OrdenacaoPorTecladoEPedidoRecusado;
    [Test] procedure DatasetFechadoVazioSubstituidoELoading;
    [Test] procedure AlterarCampoOuRemoverColunaLimpaIndicador;
    [Test] procedure LayoutRestauraDadosEIdentidade;
    [Test] procedure ResetPreservaOrdenacaoInicial;
    [Test] procedure CarregarNaoSobrescreveComAutosavePendente;
    [Test] procedure LayoutAntigoEStruturaComNovasColunas;
    [Test] procedure LayoutNaoReutilizaOrdenacaoDeOutroCampo;
    [Test] procedure OcultacaoMinimoERestauracao;
    [Test] procedure LayoutMantemLarguraLogicaEntreEscalas;
    [Test] procedure FocoPorCelulaPermaneceDuranteHover;
    [Test] procedure AssignEStreamingAntigoENovo;
    [Test] procedure DicasDeCabecalhoCelulaEBotao;
    [Test] procedure HoverNaoRepintaNoMesmoPontoELimpaCursor;
    [Test] procedure HoverAcompanhaMovimentoLarguraERolagem;
    [Test] procedure AcoesDepoisDeOrdenarMoverERolar;
    [TestCase('claro96','96,1')]
    [TestCase('escuro96','96,0')]
    [TestCase('claro120','120,1')]
    [TestCase('escuro120','120,0')]
    [TestCase('claro144','144,1')]
    [TestCase('escuro144','144,0')]
    [TestCase('claro192','192,1')]
    [TestCase('escuro192','192,0')]
    procedure RenderizaHoverSelecaoEFoco(const PPI, Tema: Integer);
    [TestCase('Prontos','Prontos')]
    [TestCase('Conciliar','Conciliar')]
    [TestCase('Importados','Importados')]
    procedure TresGridsDFMOrdenamEAcionam(const Aba: string);
  end;

implementation

uses System.SysUtils, System.Variants, System.IOUtils, System.RegularExpressions,
  Data.FmtBcd, Winapi.Windows, Winapi.Messages, Vcl.Controls, Vcl.Graphics,
  Vcl.Imaging.pngimage, DAC.Components.Controls.DBGrid,
  DAC.Components.Controls.DBGrid.Types, DAC.Components.Controls.DBGrid.Action,
  DAC.Components.Controls.DBGrid.ActionTypes,
  DAC.Components.DesignSystem.IconAssets, DAC.Components.DesignSystem.Theme;

procedure TMovimentoBancarioColunasGridTests.Pump;
var I: Integer;
begin for I := 1 to 3 do Application.ProcessMessages; end;

procedure TMovimentoBancarioColunasGridTests.Setup;
const N: array[0..6] of Integer = (10, 2, 100, -3, 2, 0, 10);
  B: array[0..6] of string = ('9999999999999.00002','9999999999999.00001',
    '-0.00001','2.12345','10.00001','0','2.12345');
  T: array[0..6] of string = ('Sao','Zebra','Agua','acao','Acao','arvore','sao');
var I: Integer; F: TFieldDef; A: TDACDBGridAction;
begin
  Application.Initialize;
  FForm := TForm.Create(nil); FForm.SetBounds(0, 0, 1040, 470);
  D := TClientDataSet.Create(FForm);
  D.FieldDefs.Add('COD_EMP', ftString, 10); D.FieldDefs.Add('MOV_COD', ftString, 10);
  D.FieldDefs.Add('N', ftInteger); D.FieldDefs.Add('DT', ftDate);
  F := D.FieldDefs.AddFieldDef; F.Name := 'VAL'; F.DataType := ftFMTBcd;
  F.Precision := 20; F.Size := 5;
  D.FieldDefs.Add('TXT', ftString, 150); D.FieldDefs.Add('CODE', ftString, 10);
  D.FieldDefs.Add('LONG', ftMemo);
  D.CreateDataSet;
  for I := 0 to 6 do
  begin
    D.Append; D.FieldByName('COD_EMP').AsString := '0000000007';
    D.FieldByName('MOV_COD').AsString := Format('%.10d', [I + 1]);
    if I <> 5 then D.FieldByName('N').AsInteger := N[I];
    if I <> 5 then D.FieldByName('VAL').AsBCD := StrToBcd(B[I], TFormatSettings.Invariant);
    if I <> 5 then D.FieldByName('DT').AsDateTime := EncodeDate(2026, ((I * 5) mod 12) + 1, I + 1);
    D.FieldByName('TXT').AsString := T[I];
    D.FieldByName('CODE').AsString := Copy('0001002', I + 1, 1) + IntToStr(I);
    D.FieldByName('LONG').AsString := 'Texto longo em multiplas linhas'#13#10'Segunda linha integral';
    D.Post;
  end;
  // Real accents must survive the legacy source encoding.
  D.First; D.Edit; D.FieldByName('TXT').AsString := 'S' + #$00E3 + 'o'; D.Post;
  D.Next; D.Edit; D.FieldByName('TXT').AsString := #$00C1 + 'gua'; D.Post;
  D.First;
  S := TDataSource.Create(FForm); S.DataSet := D;
  G := TDACActionTestGrid.Create(FForm); G.Name := 'GridColunas';
  G.Layout.Enabled := False; G.Parent := FForm; G.SetBounds(8, 8, 980, 390);
  for I := 2 to D.FieldCount - 1 do
  begin
    G.Columns.Add.FieldName := D.Fields[I].FieldName;
    G.Columns[I - 2].Width := 108;
    G.Columns[I - 2].LayoutKey := D.Fields[I].FieldName;
  end;
  G.Columns.Add.LayoutKey := 'OPCOES';
  C('OPCOES').Title.Caption := 'Opcoes'; C('OPCOES').Sortable := False; C('OPCOES').Width := 196;
  A := C('OPCOES').Actions.Add; A.ActionId := 'detalhes'; A.Caption := 'Detalhes'; A.Width := 80; A.Hint := 'Detalhes';
  A := C('OPCOES').Actions.Add; A.ActionId := 'editar'; A.IconKind := mikEdit; A.Hint := 'Editar';
  A := C('OPCOES').Actions.Add; A.ActionId := 'excluir'; A.IconKind := mikTrash; A.Appearance := daaDanger; A.Hint := 'Excluir';
  G.ActionKeyFields := 'COD_EMP;MOV_COD'; G.ShowHint := True;
  G.OnSortRequest := G.SortRequested; G.OnActionState := G.GridAcaoEstado;
  G.OnActionExecute := G.GridAcaoExecutar; G.DataSource := S;
  FForm.Show; G.SetFocus; Pump;
  LayoutFile := TPath.Combine(TPath.GetTempPath, TPath.GetRandomFileName + '.json');
end;

procedure TMovimentoBancarioColunasGridTests.TearDown;
begin
  G.Layout.AutoSave := False; FForm.Free;
  if TFile.Exists(LayoutFile) then TFile.Delete(LayoutFile);
end;

function TMovimentoBancarioColunasGridTests.C(const Key: string): TDACDBGridColumn;
var I: Integer;
begin
  for I := 0 to G.Columns.Count - 1 do
    if G.Columns[I].EffectiveLayoutKey = Key then Exit(G.Columns[I]);
  raise Exception.Create('Coluna ausente: ' + Key);
end;

function TMovimentoBancarioColunasGridTests.Sequence(const Field: string): string;
var Bookmark: TBookmark; F: TField;
begin
  Result := ''; Bookmark := D.GetBookmark; D.DisableControls;
  try
    D.First;
    while not D.Eof do
    begin
      F := D.FieldByName(Field);
      if Result <> '' then Result := Result + '|';
      if F.IsNull then Result := Result + 'NULL'
      else if F.DataType = ftDate then Result := Result + FormatDateTime('yyyy-mm-dd', F.AsDateTime)
      else if F.DataType = ftFMTBcd then Result := Result + BcdToStr(F.AsBCD, TFormatSettings.Invariant)
      else Result := Result + F.AsString;
      D.Next;
    end;
  finally D.GotoBookmark(Bookmark); D.FreeBookmark(Bookmark); D.EnableControls; end;
end;

procedure TMovimentoBancarioColunasGridTests.NumerosNulosNegativosRepetidosEIdentidade;
var Key: string; Count: Integer;
begin
  D.MoveBy(2); Key := D.FieldByName('MOV_COD').AsString;
  Assert.IsTrue(G.RequestSort(C('N').Index, dgsAscending));
  Assert.AreEqual('NULL|-3|2|2|10|10|100', Sequence('N'));
  Assert.AreEqual(Key, D.FieldByName('MOV_COD').AsString);
  Assert.IsTrue(G.RequestSort(C('N').Index, dgsDescending));
  Assert.AreEqual('100|10|10|2|2|-3|NULL', Sequence('N'));
  Assert.AreEqual(Key, D.FieldByName('MOV_COD').AsString);
  D.IndexDefs.Update; Count := D.IndexDefs.Count;
  G.RequestSort(C('N').Index, dgsAscending); G.RequestSort(C('N').Index, dgsDescending); D.IndexDefs.Update;
  Assert.AreEqual(Count, D.IndexDefs.Count, 'Indices repetidos acumulados.');
end;

procedure TMovimentoBancarioColunasGridTests.DatasOrdenadasPorValor;
begin
  G.RequestSort(C('DT').Index, dgsAscending);
  Assert.AreEqual('NULL|2026-01-01|2026-04-04|2026-06-02|2026-07-07|2026-09-05|2026-11-03', Sequence('DT'));
  G.RequestSort(C('DT').Index, dgsDescending);
  Assert.AreEqual('2026-11-03|2026-09-05|2026-07-07|2026-06-02|2026-04-04|2026-01-01|NULL', Sequence('DT'));
end;

procedure TMovimentoBancarioColunasGridTests.DecimaisMantemPrecisao;
begin
  G.RequestSort(C('VAL').Index, dgsAscending);
  Assert.AreEqual('NULL|-0.00001|2.12345|2.12345|10.00001|9999999999999.00001|9999999999999.00002', Sequence('VAL'));
  G.RequestSort(C('VAL').Index, dgsDescending);
  Assert.AreEqual('9999999999999.00002|9999999999999.00001|10.00001|2.12345|2.12345|-0.00001|NULL', Sequence('VAL'));
end;

procedure TMovimentoBancarioColunasGridTests.TextosAcentuadosECodigosComZeros;
var Previous, Current: string; I: Integer;
const Codes: array[0..6] of string = ('2','10','100','002','0002','010','01');
begin
  G.RequestSort(C('TXT').Index, dgsAscending); D.First; Previous := D.FieldByName('TXT').AsString;
  D.Next;
  while not D.Eof do
  begin
    Current := D.FieldByName('TXT').AsString;
    Assert.IsTrue(AnsiCompareText(Previous, Current) <= 0, Previous + ' > ' + Current);
    Previous := Current; D.Next;
  end;
  G.RequestSort(C('TXT').Index, dgsNone);
  D.First;
  for I := 0 to High(Codes) do
  begin D.Edit; D.FieldByName('CODE').AsString := Codes[I]; D.Post; D.Next; end;
  G.RequestSort(C('CODE').Index, dgsAscending);
  Assert.AreEqual('0002|002|01|010|10|100|2', Sequence('CODE'));
end;

procedure TMovimentoBancarioColunasGridTests.CabecalhoAlternaUmaVezEIgnoraOpcoes;
var Asc, Desc: TBitmap; Png: TPngImage; X, Y, Differences: Integer; R: TRect;
  procedure Capture(B: TBitmap; const Name: string);
  begin
    B.SetSize(G.Width, G.Height); G.PaintTo(B.Canvas.Handle, 0, 0);
    Png.Assign(B); Png.SaveToFile(ExtractFilePath(ParamStr(0)) + Name);
  end;
begin
  Asc := TBitmap.Create; Desc := TBitmap.Create; Png := TPngImage.Create;
  try
  G.ClickAt(G.HeaderPoint(C('N').Index));
  Assert.AreEqual(1, G.SortRequests); Assert.AreEqual(dgsAscending, G.SortDirection);
  Capture(Asc, 'dbgrid-columns-sort-asc.png');
  G.ClickAt(G.HeaderPoint(C('N').Index));
  Assert.AreEqual(2, G.SortRequests); Assert.AreEqual(dgsDescending, G.SortDirection);
  Capture(Desc, 'dbgrid-columns-sort-desc.png'); R := G.BoundsOf(C('N').Index);
  Differences := 0;
  for Y := R.Top to R.Bottom - 1 do
    for X := R.Left to R.Right - 1 do
      if Asc.Canvas.Pixels[X,Y] <> Desc.Canvas.Pixels[X,Y] then Inc(Differences);
  Assert.IsTrue(Differences > 2, 'Indicador visual nao mudou de direcao.');
  G.ClickAt(G.HeaderPoint(C('N').Index));
  Assert.AreEqual(3, G.SortRequests); Assert.AreEqual(dgsAscending, G.SortDirection);
  G.DoubleAt(G.HeaderPoint(C('N').Index)); Assert.AreEqual(3, G.SortRequests);
  G.ClickAt(G.HeaderPoint(C('OPCOES').Index));
  G.ClickAt(G.HeaderPoint(C('LONG').Index));
  Assert.AreEqual(3, G.SortRequests);
  finally Png.Free; Desc.Free; Asc.Free; end;
end;

procedure TMovimentoBancarioColunasGridTests.ArrastarERedimensionarNaoOrdenam;
var P: TPoint; OldWidth: Integer;
begin
  OldWidth := C('N').Width;
  P := G.BoundsOf(C('N').Index).BottomRight; Dec(P.X); P.Y := 10;
  G.DownAt(P); G.DragAt(Point(P.X + 40, P.Y)); G.UpAt(Point(P.X + 40, P.Y));
  Assert.AreEqual(0, G.SortRequests);
  Assert.IsTrue(C('N').Width > OldWidth, 'O gesto nao redimensionou a coluna.');
  P := G.HeaderPoint(C('N').Index);
  G.DownAt(P); G.DragAt(Point(P.X + 12, P.Y)); G.UpAt(Point(P.X + 12, P.Y));
  Assert.AreEqual(0, G.SortRequests);
end;

procedure TMovimentoBancarioColunasGridTests.ArrastarColunaMantemCampoOrdenado;
var P, Target: TPoint;
begin
  G.RequestSort(C('N').Index, dgsAscending);
  P := G.HeaderPoint(C('N').Index); Target := G.HeaderPoint(C('VAL').Index);
  G.DownAt(P); G.DragAt(Point(Target.X, G.BoundsOf(0, 0).Top + 5)); G.UpAt(Target);
  Assert.AreEqual(1, G.SortRequests); Assert.IsTrue(C('N').Index > 0);
  Assert.AreEqual('N', G.SortKey);
  G.ClickAt(G.HeaderPoint(C('N').Index));
  Assert.AreEqual(dgsDescending, G.SortDirection);
  Assert.AreEqual('100|10|10|2|2|-3|NULL', Sequence('N'));
end;

procedure TMovimentoBancarioColunasGridTests.OrdenacaoPorTecladoEPedidoRecusado;
var Saved, Pressed: TKeyboardState;
begin
  GetKeyboardState(Saved); Pressed := Saved; Pressed[VK_CONTROL] := $80;
  try
    SetKeyboardState(Pressed);
    Assert.IsTrue((G.Perform(WM_GETDLGCODE, VK_RETURN, 0) and DLGC_WANTALLKEYS) <> 0,
      'Ctrl+Enter pode ser consumido pelo botao padrao do formulario.');
  finally SetKeyboardState(Saved); end;
  G.RowSelectionEnabled := False; G.SelectedIndex := C('N').Index;
  G.PressKey(VK_RETURN, [ssCtrl]); Assert.AreEqual(1, G.SortRequests);
  Assert.AreEqual(dgsAscending, G.SortDirection);
  G.RejectSort := True; G.PressKey(VK_RETURN, [ssCtrl]);
  Assert.AreEqual(2, G.SortRequests); Assert.AreEqual(dgsAscending, G.SortDirection);
  Assert.AreEqual('NULL|-3|2|2|10|10|100', Sequence('N'));
end;

procedure TMovimentoBancarioColunasGridTests.DatasetFechadoVazioSubstituidoELoading;
var Other: TClientDataSet;
begin
  G.RequestSort(C('N').Index, dgsAscending);
  G.Loading := True; Assert.IsFalse(G.RequestSort(0, dgsDescending)); G.Loading := False;
  D.Close; Assert.AreEqual(dgsNone, G.SortDirection);
  Assert.IsFalse(G.RequestSort(0, dgsAscending));
  D.Open; D.EmptyDataSet; Assert.IsTrue(G.RequestSort(0, dgsAscending));
  Assert.IsTrue(G.ActionRect(C('OPCOES').Index, 0, 0).IsEmpty);
  Other := TClientDataSet.Create(nil);
  try
    Other.FieldDefs.Add('N', ftInteger); Other.CreateDataSet;
    S.DataSet := Other; Assert.AreEqual(dgsNone, G.SortDirection);
    G.MoveAt(G.HeaderPoint(0)); Other.Free; Other := nil;
    Assert.AreEqual(dgsNone, G.SortDirection);
    Assert.IsFalse(G.RequestSort(0, dgsAscending));
  finally Other.Free; end;
end;

procedure TMovimentoBancarioColunasGridTests.AlterarCampoOuRemoverColunaLimpaIndicador;
begin
  G.RequestSort(C('N').Index, dgsAscending);
  C('N').FieldName := 'DT'; Assert.AreEqual(dgsNone, G.SortDirection);
  G.RequestSort(C('DT').Index, dgsAscending);
  C('DT').Free; Assert.AreEqual(dgsNone, G.SortDirection);
end;

procedure TMovimentoBancarioColunasGridTests.EnableLayout;
begin
  G.Layout.AutoSave := False; G.Layout.StorageFileName := LayoutFile;
  G.Layout.Enabled := True; G.LoadLayout;
end;

procedure TMovimentoBancarioColunasGridTests.LayoutRestauraDadosEIdentidade;
begin
  EnableLayout; G.RequestSort(C('N').Index, dgsDescending);
  C('N').Width := 180; C('N').Index := 2; G.SaveLayout;
  G.RequestSort(C('DT').Index, dgsAscending); C('N').Width := 90;
  G.LoadLayout;
  Assert.AreEqual('N', G.SortKey); Assert.AreEqual(dgsDescending, G.SortDirection);
  Assert.AreEqual('100|10|10|2|2|-3|NULL', Sequence('N'));
  Assert.AreEqual(180, C('N').Width); Assert.AreEqual(2, C('N').Index);
  G.ResetLayout; Assert.AreEqual(0, C('N').Index); Assert.AreEqual(108, C('N').Width);
  Assert.AreEqual(dgsNone, G.SortDirection); Assert.AreEqual('', D.IndexName);
end;

procedure TMovimentoBancarioColunasGridTests.ResetPreservaOrdenacaoInicial;
begin
  G.RequestSort(C('N').Index, dgsAscending); EnableLayout;
  G.RequestSort(C('DT').Index, dgsDescending); G.ResetLayout;
  Assert.AreEqual('N', G.SortKey); Assert.AreEqual(dgsAscending, G.SortDirection);
  Assert.AreEqual('NULL|-3|2|2|10|10|100', Sequence('N'));
end;

procedure TMovimentoBancarioColunasGridTests.CarregarNaoSobrescreveComAutosavePendente;
var Saved: string;
begin
  EnableLayout; C('N').Width := 181; G.SaveLayout;
  G.Layout.AutoSave := True; Saved := TFile.ReadAllText(LayoutFile);
  C('N').Width := 222; G.LoadLayout;
  Assert.AreEqual(181, C('N').Width);
  Assert.AreEqual(Saved, TFile.ReadAllText(LayoutFile));
  G.ResetLayout; Assert.AreEqual(108, C('N').Width);
end;

procedure TMovimentoBancarioColunasGridTests.LayoutAntigoEStruturaComNovasColunas;
var Json: string;
begin
  EnableLayout; C('DT').Index := 0; G.RequestSort(C('N').Index, dgsAscending); G.SaveLayout;
  Json := TFile.ReadAllText(LayoutFile);
  Json := TRegEx.Replace(Json, ',"sortFieldName":"[^"]*"', ''); TFile.WriteAllText(LayoutFile, Json);
  C('DT').Free; G.Columns.Add.LayoutKey := 'NOVA'; C('NOVA').Index := 0;
  G.LoadLayout;
  Assert.AreEqual('N', G.Columns[0].LayoutKey);
  Assert.AreEqual('NOVA', G.Columns[G.Columns.Count - 1].LayoutKey);
  Assert.AreEqual(dgsAscending, G.SortDirection);
end;

procedure TMovimentoBancarioColunasGridTests.LayoutNaoReutilizaOrdenacaoDeOutroCampo;
begin
  EnableLayout; G.RequestSort(C('N').Index, dgsAscending); G.SaveLayout;
  C('N').FieldName := 'DT'; G.LoadLayout;
  Assert.AreEqual(dgsNone, G.SortDirection);
end;

procedure TMovimentoBancarioColunasGridTests.OcultacaoMinimoERestauracao;
begin
  C('N').MinWidth := 80; C('N').Width := 1; Assert.AreEqual(80, C('N').Width);
  C('N').UserHideable := False;
  G.SetColumnVisible('N', False); Assert.IsTrue(C('N').Visible);
  C('N').Visible := False; G.SetColumnVisible('N', True); Assert.IsTrue(C('N').Visible);
  EnableLayout; G.SaveLayout; G.SetColumnVisible('DT', False); G.LoadLayout;
  Assert.IsTrue(C('DT').Visible);
  G.SetColumnVisible('DT', False); Assert.IsFalse(C('DT').Visible);
end;

procedure TMovimentoBancarioColunasGridTests.LayoutMantemLarguraLogicaEntreEscalas;
begin
  EnableLayout; G.SetTestPPI(144); C('N').Width := 180; G.SaveLayout;
  G.SetTestPPI(192); G.LoadLayout; Assert.AreEqual(240, C('N').Width);
  G.SetTestPPI(96); G.LoadLayout; Assert.AreEqual(120, C('N').Width);
end;

procedure TMovimentoBancarioColunasGridTests.FocoPorCelulaPermaneceDuranteHover;
var B: TBitmap; R: TRect; Color: TColor;
begin
  G.RowSelectionEnabled := False; G.SelectedIndex := C('DT').Index;
  B := TBitmap.Create;
  try
    B.SetSize(G.Width, G.Height); G.PaintTo(B.Canvas.Handle, 0, 0);
    R := G.BoundsOf(C('DT').Index, 0);
    Color := B.Canvas.Pixels[R.Left + 1, R.CenterPoint.Y];
    G.MoveAt(G.BoundsOf(C('VAL').Index, 0).CenterPoint); G.PaintTo(B.Canvas.Handle, 0, 0);
    Assert.AreEqual(Color, B.Canvas.Pixels[R.Left + 1, R.CenterPoint.Y]);
    G.MoveAt(R.CenterPoint); G.PaintTo(B.Canvas.Handle, 0, 0);
    Assert.AreEqual(Color, B.Canvas.Pixels[R.Left + 1, R.CenterPoint.Y]);
    Assert.IsTrue(Color <> B.Canvas.Pixels[R.Left + 5, R.Top + 5]);
  finally B.Free; end;
end;

procedure TMovimentoBancarioColunasGridTests.AssignEStreamingAntigoENovo;
var Stream: TMemoryStream; Text: TStringStream; Other: TDACActionTestGrid;
begin
  C('N').Hint := 'Numero completo'; C('N').TitleHint := 'Ordenar numero'; C('N').MinWidth := 82;
  Other := TDACActionTestGrid.Create(FForm); Stream := TMemoryStream.Create;
  Text := TStringStream.Create('object Antiga: TDACActionTestGrid'#13#10 +
    'Columns = < item FieldName = ''N'' Width = 90 end >'#13#10'end', TEncoding.UTF8);
  try
    ObjectTextToBinary(Text, Stream); Stream.Position := 0; Stream.ReadComponent(Other);
    Assert.AreEqual(16, Other.Columns[0].MinWidth); Assert.AreEqual(0, Other.Columns[0].Actions.Count);
    Other.Columns.Assign(G.Columns);
    Assert.AreEqual('Numero completo', Other.Columns[0].Hint);
    Assert.AreEqual(82, Other.Columns[0].MinWidth);
    Stream.Clear; Stream.WriteComponent(Other); Stream.Position := 0; Stream.ReadComponent(Other);
    Assert.AreEqual('Ordenar numero', Other.Columns[0].TitleHint);
    Assert.AreEqual(3, Other.Columns[6].Actions.Count);
  finally Text.Free; Stream.Free; Other.Free; end;
end;

procedure TMovimentoBancarioColunasGridTests.DicasDeCabecalhoCelulaEBotao;
begin
  C('N').TitleHint := 'Ordenar numero'; C('N').Hint := 'Dica do valor';
  Assert.AreEqual('Ordenar numero', G.HintAt(G.HeaderPoint(C('N').Index)));
  Assert.AreEqual('Dica do valor', G.HintAt(G.BoundsOf(C('N').Index, 0).CenterPoint));
  Assert.AreEqual(D.FieldByName('LONG').AsString, G.HintAt(G.BoundsOf(C('LONG').Index, 0).CenterPoint));
  Assert.AreEqual('Excluir', G.HintAt(G.ActionRect(C('OPCOES').Index, 0, 2).CenterPoint));
  G.Loading := True; Assert.AreEqual('', G.HintAt(G.HeaderPoint(0)));
end;

procedure TMovimentoBancarioColunasGridTests.HoverNaoRepintaNoMesmoPontoELimpaCursor;
var Count: Integer; P: TPoint; B: TBitmap; Normal: TColor;
begin
  B := TBitmap.Create;
  try
    B.SetSize(G.Width, G.Height); G.Perform(CM_MOUSELEAVE, 0, 0);
    G.PaintTo(B.Canvas.Handle, 0, 0); Normal := B.Canvas.Pixels[10,10];
    P := G.HeaderPoint(0); G.DownAt(P); G.Enabled := False;
    G.PaintTo(B.Canvas.Handle, 0, 0); Assert.AreEqual(Normal, B.Canvas.Pixels[10,10]);
    G.Enabled := True; G.UpAt(P); Assert.AreEqual(0, G.SortRequests);
    G.Perform(CM_MOUSELEAVE, 0, 0); G.DownAt(P); G.Loading := True;
    G.PaintTo(B.Canvas.Handle, 0, 0); Assert.AreEqual(Normal, B.Canvas.Pixels[10,10]);
    G.Loading := False; G.UpAt(P); Assert.AreEqual(0, G.SortRequests);
  finally B.Free; end;
  P := G.HeaderPoint(0); G.MoveAt(P); G.Update;
  Assert.AreEqual(Integer(crHandPoint), Integer(G.Cursor)); Count := G.PaintCount;
  G.MoveAt(P); G.Update; Assert.AreEqual(Count, G.PaintCount);
  G.Perform(CM_MOUSELEAVE, 0, 0); Assert.AreEqual(Integer(crDefault), Integer(G.Cursor));
  P := G.ActionRect(C('OPCOES').Index, 0, 1).CenterPoint;
  G.MoveAt(P); Assert.AreEqual(Integer(crHandPoint), Integer(G.Cursor));
  G.DisabledAction := 'editar'; G.MoveAt(P); Assert.AreEqual(Integer(crDefault), Integer(G.Cursor));
  G.DisabledAction := ''; G.MoveAt(P); G.Enabled := False;
  Assert.AreEqual(Integer(crDefault), Integer(G.Cursor));
  G.Enabled := True; G.MoveAt(P); C('OPCOES').Visible := False;
  Assert.AreEqual(Integer(crDefault), Integer(G.Cursor));
end;

procedure TMovimentoBancarioColunasGridTests.HoverAcompanhaMovimentoLarguraERolagem;
begin
  G.MoveAt(G.HeaderPoint(0)); C('N').Index := 2;
  Assert.AreEqual(Integer(crDefault), Integer(G.Cursor));
  G.MoveAt(G.HeaderPoint(C('N').Index)); C('N').Width := 140;
  Assert.AreEqual(Integer(crDefault), Integer(G.Cursor));
  G.MoveAt(G.HeaderPoint(0)); G.Perform(WM_HSCROLL, SB_LINERIGHT, 0);
  Assert.AreEqual(Integer(crDefault), Integer(G.Cursor));
  G.MoveAt(G.HeaderPoint(1)); G.Perform(WM_VSCROLL, SB_LINEDOWN, 0);
  Assert.AreEqual(Integer(crDefault), Integer(G.Cursor));
end;

procedure TMovimentoBancarioColunasGridTests.AcoesDepoisDeOrdenarMoverERolar;
var R: TRect; P: TPoint; Key: string; I: Integer;
begin
  G.RequestSort(C('N').Index, dgsDescending); C('OPCOES').Index := 0;
  D.First; D.MoveBy(3); Key := D.FieldByName('MOV_COD').AsString;
  R := G.ActionRect(0, G.CurrentVisibleRow, 2); Assert.IsFalse(R.IsEmpty);
  G.ClickAt(R.CenterPoint);
  Assert.AreEqual(1, G.Activations); Assert.AreEqual(1, G.SortRequests);
  Assert.AreEqual(Key, VarToStr(G.LastContext.ValueOf('MOV_COD')));
  P := G.ActionRect(0, G.CurrentVisibleRow, 1).CenterPoint;
  G.DownAt(P); G.Perform(WM_KILLFOCUS, 0, 0); G.UpAt(P);
  Assert.AreEqual(1, G.Activations);
  C('OPCOES').Width := 100;
  for I := 0 to 2 do
  begin R := G.ActionRect(0, G.CurrentVisibleRow, I); Assert.IsTrue(R.IsEmpty or G.BoundsOf(0, G.CurrentVisibleRow).Contains(R)); end;
end;

procedure TMovimentoBancarioColunasGridTests.RenderizaHoverSelecaoEFoco(const PPI, Tema: Integer);
var B: TBitmap; Png: TPngImage; R, Other: TRect; Normal, Adjacent, Selected: TColor;
  I: Integer; FileName: string;
  function Pixel(const Bounds: TRect): TColor;
  begin Result := B.Canvas.Pixels[Bounds.Left + MulDiv(4, PPI, 96), Bounds.Top + MulDiv(4, PPI, 96)]; end;
begin
  G.SetTestPPI(PPI); if Tema = 1 then G.ThemeMode := dtmLight else G.ThemeMode := dtmDark;
  G.SetBounds(8, 8, MulDiv(980, PPI, 96), MulDiv(390, PPI, 96));
  for I := 0 to G.Columns.Count - 1 do G.Columns[I].Width := MulDiv(108, PPI, 96);
  C('OPCOES').MinWidth := 176; C('OPCOES').Width := 1;
  for I := 0 to 2 do Assert.IsFalse(G.ActionRect(C('OPCOES').Index, 0, I).IsEmpty,
    'Acao nao cabe na largura minima escalada.');
  C('OPCOES').Width := MulDiv(196, PPI, 96);
  C('N').MinWidth := 80; C('N').Width := 1; Assert.AreEqual(MulDiv(80, PPI, 96), C('N').Width);
  B := TBitmap.Create; Png := TPngImage.Create;
  try
    B.SetSize(G.Width, G.Height); G.Perform(CM_MOUSELEAVE, 0, 0); G.PaintTo(B.Canvas.Handle, 0, 0);
    R := G.BoundsOf(0, 1); Other := G.BoundsOf(1, 1); Normal := Pixel(R); Adjacent := Pixel(Other);
    Selected := Pixel(G.BoundsOf(0, 0));
    G.MoveAt(R.CenterPoint); G.PaintTo(B.Canvas.Handle, 0, 0);
    Assert.IsTrue(Normal <> Pixel(R), 'Hover de celula invisivel.');
    Assert.AreEqual(Adjacent, Pixel(Other), 'Hover destacou outra coluna.');
    Assert.AreEqual(Selected, Pixel(G.BoundsOf(0, 0)), 'Selecao apagada por hover.');
    G.MoveAt(G.HeaderPoint(1)); G.PaintTo(B.Canvas.Handle, 0, 0);
    Assert.AreEqual(Normal, Pixel(R), 'Hover de cabecalho deixou celula marcada.');
    G.MoveAt(G.ActionRect(C('OPCOES').Index, 0, 2).CenterPoint);
    G.PressKey(VK_F2); G.PaintTo(B.Canvas.Handle, 0, 0);
    Png.Assign(B); FileName := ExtractFilePath(ParamStr(0)) + Format('dbgrid-columns-%d-%d.png', [PPI, Tema]);
    Png.SaveToFile(FileName); Assert.IsTrue(Length(TFile.ReadAllBytes(FileName)) > 1000);
    G.PressKey(VK_ESCAPE);
    G.RequestSort(C('N').Index, dgsAscending); D.First;
    G.MoveAt(G.HeaderPoint(C('N').Index)); G.PaintTo(B.Canvas.Handle, 0, 0);
    Png.Assign(B); Png.SaveToFile(ExtractFilePath(ParamStr(0)) + Format('dbgrid-columns-header-%d-%d.png', [PPI, Tema]));
    G.MoveAt(G.BoundsOf(C('DT').Index, 1).CenterPoint); G.PaintTo(B.Canvas.Handle, 0, 0);
    Png.Assign(B); Png.SaveToFile(ExtractFilePath(ParamStr(0)) + Format('dbgrid-columns-cell-%d-%d.png', [PPI, Tema]));
    // Narrow viewport: incomplete actions must never escape their cell/viewport.
    G.Width := MulDiv(300, PPI, 96); G.PressKey(VK_ESCAPE); G.PressKey(VK_F2);
    for I := 0 to 2 do
    begin R := G.ActionRect(C('OPCOES').Index, 0, I); Assert.IsTrue(R.IsEmpty or ((R.Left >= 0) and (R.Right <= G.ClientWidth))); end;
  finally Png.Free; B.Free; end;
end;

procedure TMovimentoBancarioColunasGridTests.ReadRealDFM(const Aba: string);
var Text, Block: string; Match: TMatch; Input: TStringStream; Binary: TMemoryStream;
begin
  Text := TFile.ReadAllText(TPath.GetFullPath(ExtractFilePath(ParamStr(0)) + '..\source\view\View.MovimentoBancario.dfm'), TEncoding.GetEncoding(1252));
  Match := TRegEx.Match(Text, '(?ms)^        object grdMovimentos' + Aba + ': TDACDBGrid\r?\n.*?^        end\r?$');
  Assert.IsTrue(Match.Success);
  Block := TRegEx.Replace(Match.Value, '(?m)^\s*DataSource = [^\r\n]+\r?\n', '');
  G.DataSource := nil; Input := TStringStream.Create(Block, TEncoding.UTF8); Binary := TMemoryStream.Create;
  try
    ObjectTextToBinary(Input, Binary); Binary.Position := 0; Binary.ReadComponent(G);
    Assert.IsTrue(Assigned(G.OnSortRequest)); Assert.IsFalse(C('OPCOES').Sortable);
    Assert.AreEqual(176, C('OPCOES').MinWidth);
    Binary.Clear; Binary.WriteComponent(G); Binary.Position := 0; Binary.ReadComponent(G);
  finally Binary.Free; Input.Free; end;
end;

procedure TMovimentoBancarioColunasGridTests.TresGridsDFMOrdenamEAcionam(const Aba: string);
var I: Integer; P: TPoint; Key: string;
begin
  ReadRealDFM(Aba); G.Layout.Enabled := False;
  // Names map to the real buffer fields; no financial API/operations are invoked.
  D.Close; D.FieldDefs.Clear;
  D.FieldDefs.Add('COD_EMP', ftString, 10); D.FieldDefs.Add('MOV_COD', ftString, 10);
  D.FieldDefs.Add('MOV_VALOR', ftCurrency); D.CreateDataSet;
  for I := 1 to 40 do D.AppendRecord(['0000000007', Format('%.10d', [I]), (41 - I) * 1.25]);
  D.First; G.DataSource := S; G.SetBounds(8, 8, 980, 390);
  G.RequestSort(C('MOV_VALOR').Index, dgsAscending);
  Assert.AreEqual(dgsAscending, G.SortDirection);
  C('OPCOES').Index := 0; D.First; D.MoveBy(20); Key := D.FieldByName('MOV_COD').AsString;
  P := G.ActionRect(0, G.CurrentVisibleRow, 0).CenterPoint; G.ClickAt(P);
  Assert.AreEqual(1, G.Activations); Assert.AreEqual(Key, VarToStr(G.LastContext.ValueOf('MOV_COD')));
  Assert.AreEqual(1, G.SortRequests); Assert.AreEqual(0, G.ControlCount);
end;

initialization
  TDUnitX.RegisterTestFixture(TMovimentoBancarioColunasGridTests);
end.
