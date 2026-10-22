unit Teste.MovimentoBancario.AcoesGrid;

interface

uses
  System.Classes, System.Types,
  Vcl.Forms, Datasnap.DBClient, Data.DB,
  DUnitX.TestFramework,
  TestSupport.DACDBGridActions,
  DAC.Components.Controls.DBGrid;

type
  [TestFixture]
  TMovimentoBancarioAcoesGridTests = class
  private
    FForm: TForm;
    FGrid: TDACActionTestGrid;
    FData: TClientDataSet;
    FSource: TDataSource;
    function ButtonPoint(const AAction: Integer; const ARow: Integer = 0): TPoint;
    procedure Pump;
    procedure LoadGridDFM(const AAba: string);
  public
    [Setup] procedure Setup;
    [TearDown] procedure TearDown;
    [Test] procedure TresBotoesDisparamExatamenteUmaAcao;
    [Test] procedure RegistroCorretoDepoisDeRolagemEOrdenacao;
    [Test] procedure SelecaoPorLinhaPreservaRolagemHorizontalEAcessoPorF2;
    [Test] procedure ChavesCompostasDistinguemMovimentosIguais;
    [Test] procedure OcultosEDesabilitadosNaoDisparam;
    [Test] procedure RevalidaEstadoEntrePressionarESoltar;
    [Test] procedure CabecalhoVazioELoadingNaoDisparam;
    [Test] procedure CancelaComRolagemMudancaDeRegistroECaptura;
    [Test] procedure ArrastarEDuploCliqueNaoDuplicamAcao;
    [Test] procedure TecladoRespeitaEstadoESuprimeRepeticao;
    [Test] procedure AcoesPreservamSelecaoComIndicadorENavegacaoPorCelula;
    [Test] procedure RedimensionarRespeitaCelulaERecriarHandleCancela;
    [Test] procedure QuantidadeDeControlesIndependeDeRegistros;
    [Test] procedure DestruirDataSourceComBotaoPressionadoNaoDispara;
    [Test] procedure IdentificadoresVaziosOuDuplicadosSaoRejeitados;
    [Test] procedure AssignEStreamingPreservamAcoes;
    [Test] procedure LayoutNaoSobrescreveDefinicoesDeAcoes;
    [Test] procedure RenderizaTemasEEstados;
    [TestCase('Prontos','Prontos')]
    [TestCase('Conciliar','Conciliar')]
    [TestCase('Importados','Importados')]
    procedure DFMRealDasGridsPodeSerLidoEGravado(const AAba: string);
  end;

implementation

uses
  System.SysUtils, System.Variants, System.IOUtils, System.RegularExpressions,
  Winapi.Windows, Winapi.Messages, Vcl.Controls, Vcl.Graphics, Vcl.Imaging.pngimage,
  DAC.Components.Controls.DBGrid.Action,
  DAC.Components.Controls.DBGrid.ActionTypes,
  DAC.Components.DesignSystem.IconAssets,
  DAC.Components.DesignSystem.Theme;

procedure TMovimentoBancarioAcoesGridTests.Pump;
var I: Integer;
begin for I := 1 to 4 do Application.ProcessMessages; end;

procedure TMovimentoBancarioAcoesGridTests.Setup;
var I: Integer; A: TDACDBGridAction;
begin
  Application.Initialize;
  FForm := TForm.Create(nil);
  FForm.SetBounds(0, 0, 700, 430);
  FData := TClientDataSet.Create(FForm);
  FData.FieldDefs.Add('COD_EMP', ftString, 10);
  FData.FieldDefs.Add('MOV_COD', ftString, 10);
  FData.FieldDefs.Add('SELECIONADO', ftBoolean);
  FData.CreateDataSet;
  for I := 1 to 80 do
    FData.AppendRecord(['0000000007', Format('%.10d', [I])]);
  FData.First;
  FSource := TDataSource.Create(FForm);
  FSource.DataSet := FData;
  FGrid := TDACActionTestGrid.Create(FForm);
  FGrid.Name := 'GridAcoesTeste';
  FGrid.Layout.Enabled := False;
  FGrid.SetBounds(12, 12, 640, 340);
  FGrid.Parent := FForm;
  FGrid.ActionKeyFields := 'COD_EMP;MOV_COD';
  FGrid.Columns.Add.FieldName := 'MOV_COD';
  FGrid.Columns[0].Width := 150;
  FGrid.Columns.Add.LayoutKey := 'OPCOES';
  FGrid.Columns[1].Title.Caption := 'Opcoes';
  FGrid.Columns[1].Sortable := False;
  FGrid.Columns[1].Width := 196;
  A := FGrid.Columns[1].Actions.Add;
  A.ActionId := 'detalhes'; A.Caption := 'Detalhes'; A.Width := 80;
  A.Hint := 'Detalhes do lancamento';
  A := FGrid.Columns[1].Actions.Add;
  A.ActionId := 'editar'; A.IconKind := mikEdit; A.Hint := 'Editar';
  A := FGrid.Columns[1].Actions.Add;
  A.ActionId := 'excluir'; A.IconKind := mikTrash;
  A.Appearance := daaDanger; A.Hint := 'Excluir';
  FGrid.DataSource := FSource;
  FGrid.ShowHint := True;
  FGrid.OnActionState := FGrid.GridAcaoEstado;
  FGrid.OnActionExecute := FGrid.GridAcaoExecutar;
  FGrid.OnCellClick := FGrid.CellClicked;
  FGrid.OnDblClick := FGrid.DoubleClicked;
  FGrid.OnSortRequest := FGrid.SortRequested;
  FForm.Show;
  FGrid.SetFocus;
  Pump;
end;

procedure TMovimentoBancarioAcoesGridTests.TearDown;
begin FForm.Free; end;

function TMovimentoBancarioAcoesGridTests.ButtonPoint(const AAction, ARow: Integer): TPoint;
var R: TRect;
begin
  R := FGrid.ActionRect(1, ARow, AAction);
  Assert.IsFalse(R.IsEmpty, 'Botao esperado nao possui area visivel.');
  Result := R.CenterPoint;
end;

procedure TMovimentoBancarioAcoesGridTests.TresBotoesDisparamExatamenteUmaAcao;
const Ids: array[0..2] of string = ('detalhes', 'editar', 'excluir');
var I: Integer;
begin
  for I := 0 to 2 do
  begin
    FGrid.ClickAt(ButtonPoint(I));
    Assert.AreEqual(I + 1, FGrid.Activations);
    Assert.AreEqual(Ids[I], FGrid.LastContext.ActionId);
    Assert.AreEqual('OPCOES', FGrid.LastContext.ColumnKey);
    Assert.IsTrue(FGrid.LastContext.HasCompleteKey);
    Assert.AreEqual('0000000001', VarToStr(FGrid.LastContext.ValueOf('MOV_COD')));
  end;
  Assert.AreEqual(0, FGrid.CellClicks);
end;

procedure TMovimentoBancarioAcoesGridTests.RegistroCorretoDepoisDeRolagemEOrdenacao;
var Expected: string;
begin
  FData.Last; Pump;
  Expected := FData.FieldByName('MOV_COD').AsString;
  FGrid.ClickAt(ButtonPoint(0, FGrid.CurrentVisibleRow));
  Assert.AreEqual(Expected, VarToStr(FGrid.LastContext.ValueOf('MOV_COD')));
  FGrid.ClickAt(FGrid.HeaderPoint(0));
  FGrid.ClickAt(FGrid.HeaderPoint(0)); Pump;
  FData.First; FData.MoveBy(25); Pump;
  Expected := FData.FieldByName('MOV_COD').AsString;
  FGrid.ClickAt(ButtonPoint(2, FGrid.CurrentVisibleRow));
  Assert.AreEqual(Expected, VarToStr(FGrid.LastContext.ValueOf('MOV_COD')));
  FData.First; Pump;
  // Click a visible row that is not selected, checking the buffered-record path.
  FGrid.ClickAt(ButtonPoint(0, 2));
  Assert.AreEqual(FData.FieldByName('MOV_COD').AsString,
    VarToStr(FGrid.LastContext.ValueOf('MOV_COD')));
  Assert.AreEqual(3, FGrid.Activations);
end;

procedure TMovimentoBancarioAcoesGridTests.SelecaoPorLinhaPreservaRolagemHorizontalEAcessoPorF2;
var P: TPoint; R: TRect;
begin
  FGrid.Columns[0].Width := 900;
  FGrid.PressKey(VK_F2);
  R := FGrid.ActionRect(1, 0, 0);
  Assert.IsFalse(R.IsEmpty, 'F2 nao trouxe a coluna de acoes para o viewport.');
  Assert.IsTrue((R.Left >= 0) and (R.Right <= FGrid.ClientWidth));
  P := R.CenterPoint;
  FGrid.PressKey(VK_ESCAPE);
  FGrid.DownAt(P);
  Assert.AreEqual(R.Left, FGrid.ActionRect(1, 0, 0).Left, 'Pressionar deslocou a coluna.');
  FGrid.UpAt(P);
  Assert.AreEqual(1, FGrid.Activations, 'Clique deslocou o viewport antes de soltar.');
  FGrid.ClickAt(ButtonPoint(1, 2));
  Assert.AreEqual(2, FGrid.Activations);
  Assert.AreEqual(FData.FieldByName('MOV_COD').AsString, VarToStr(FGrid.LastContext.ValueOf('MOV_COD')));
  FData.Last; Pump;
  FGrid.PressKey(VK_F2);
  FGrid.ClickAt(ButtonPoint(2, FGrid.CurrentVisibleRow));
  Assert.AreEqual(3, FGrid.Activations);
  Assert.AreEqual('0000000080', VarToStr(FGrid.LastContext.ValueOf('MOV_COD')));
end;

procedure TMovimentoBancarioAcoesGridTests.ChavesCompostasDistinguemMovimentosIguais;
var Saved: TDACDBGridActionContext;
begin
  FData.AppendRecord(['0000000008', '0000000001']); Pump;
  FGrid.ClickAt(ButtonPoint(0, FGrid.CurrentVisibleRow));
  Saved := FGrid.LastContext;
  Assert.AreEqual('0000000008', VarToStr(Saved.Keys[0].Value));
  FGrid.ClickAt(ButtonPoint(1, FGrid.CurrentVisibleRow));
  Assert.AreEqual(1, FGrid.Activations, 'Estado por registro ignorado.');
  FData.First; Pump;
  FGrid.ClickAt(ButtonPoint(1));
  Assert.AreEqual(2, FGrid.Activations);
  Assert.AreEqual('0000000007', VarToStr(FGrid.LastContext.Keys[0].Value));
  Assert.AreEqual('0000000008', VarToStr(Saved.Keys[0].Value), 'Snapshot alterado pela navegacao.');
end;

procedure TMovimentoBancarioAcoesGridTests.OcultosEDesabilitadosNaoDisparam;
var Old: TPoint;
begin
  Old := ButtonPoint(2);
  FGrid.HiddenAction := 'excluir';
  Assert.IsTrue(FGrid.ActionRect(1, 0, 2).IsEmpty);
  FGrid.ClickAt(Old);
  FGrid.DisabledAction := 'editar';
  FGrid.ClickAt(ButtonPoint(1));
  Assert.AreEqual(0, FGrid.Activations);
  FGrid.Columns[1].Actions[0].Enabled := False;
  FGrid.ClickAt(ButtonPoint(0));
  Assert.AreEqual(0, FGrid.Activations);
end;

procedure TMovimentoBancarioAcoesGridTests.RevalidaEstadoEntrePressionarESoltar;
var P: TPoint;
begin
  P := ButtonPoint(1); FGrid.DownAt(P);
  FGrid.DisabledAction := 'editar'; FGrid.UpAt(P);
  Assert.AreEqual(0, FGrid.Activations);
  FGrid.DisabledAction := '';
  P := ButtonPoint(2); FGrid.DownAt(P);
  FGrid.HiddenAction := 'excluir'; FGrid.UpAt(P);
  Assert.AreEqual(0, FGrid.Activations);
end;

procedure TMovimentoBancarioAcoesGridTests.CabecalhoVazioELoadingNaoDisparam;
var P: TPoint; Queries: Integer;
begin
  P := ButtonPoint(0);
  FGrid.ClickAt(FGrid.HeaderPoint(1));
  FGrid.Loading := True; Queries := FGrid.StateQueries;
  FGrid.ClickAt(P); FGrid.PressKey(VK_F2); FGrid.PressKey(VK_RETURN);
  Assert.AreEqual(Queries, FGrid.StateQueries);
  FGrid.Loading := False;
  FData.EmptyDataSet; Pump;
  FGrid.ClickAt(P); FGrid.PressKey(VK_F2); FGrid.PressKey(VK_RETURN);
  Assert.AreEqual(0, FGrid.Activations);
  Assert.IsTrue(FGrid.ActionRect(1, 0, 0).IsEmpty);
end;

procedure TMovimentoBancarioAcoesGridTests.CancelaComRolagemMudancaDeRegistroECaptura;
var P: TPoint;
begin
  P := ButtonPoint(0); FGrid.DownAt(P); FData.Next; FGrid.UpAt(P);
  Assert.AreEqual(0, FGrid.Activations);
  FData.First; Pump;
  P := ButtonPoint(0); FGrid.DownAt(P);
  FGrid.Perform(WM_VSCROLL, SB_LINEDOWN, 0); FGrid.UpAt(P);
  Assert.AreEqual(0, FGrid.Activations);
  FData.First; Pump;
  P := ButtonPoint(0); FGrid.DownAt(P); ReleaseCapture; FGrid.UpAt(P);
  Assert.AreEqual(0, FGrid.Activations);
  P := ButtonPoint(0); FGrid.DownAt(P);
  FGrid.Perform(WM_KILLFOCUS, 0, 0); FGrid.UpAt(P);
  Assert.AreEqual(0, FGrid.Activations);
end;

procedure TMovimentoBancarioAcoesGridTests.ArrastarEDuploCliqueNaoDuplicamAcao;
var P: TPoint;
begin
  P := ButtonPoint(0); FGrid.DownAt(P); FGrid.MoveAt(ButtonPoint(1)); FGrid.UpAt(P);
  Assert.AreEqual(0, FGrid.Activations);
  FGrid.ClickAt(P); FGrid.DoubleAt(P);
  Assert.AreEqual(1, FGrid.Activations);
  Assert.AreEqual(0, FGrid.DoubleClicks);
end;

procedure TMovimentoBancarioAcoesGridTests.TecladoRespeitaEstadoESuprimeRepeticao;
begin
  FGrid.DisabledAction := 'editar';
  FGrid.PressKey(VK_F2);
  Assert.IsTrue((FGrid.Perform(WM_GETDLGCODE, VK_RETURN, 0) and DLGC_WANTALLKEYS) <> 0,
    'Enter pode ser capturado pelo botao padrao do formulario.');
  FGrid.PressKey(VK_RETURN); FGrid.PressKey(VK_RETURN);
  Assert.AreEqual(1, FGrid.Activations);
  FGrid.ReleaseKey(VK_RETURN);
  FGrid.PressKey(VK_RIGHT);
  FGrid.PressKey(VK_SPACE); FGrid.ReleaseKey(VK_SPACE);
  Assert.AreEqual(2, FGrid.Activations);
  Assert.AreEqual('excluir', FGrid.LastContext.ActionId);
  FGrid.PressKey(VK_TAB, [ssShift]);
  FGrid.PressKey(VK_RETURN); FGrid.ReleaseKey(VK_RETURN);
  Assert.AreEqual('detalhes', FGrid.LastContext.ActionId);
  FGrid.PressKey(VK_ESCAPE); FGrid.PressKey(VK_RETURN);
  Assert.AreEqual(3, FGrid.Activations);
end;

procedure TMovimentoBancarioAcoesGridTests.AcoesPreservamSelecaoComIndicadorENavegacaoPorCelula;
begin
  FGrid.Selection.FieldName := 'SELECIONADO';
  FGrid.Selection.Enabled := True;
  FGrid.RowSelectionEnabled := False;
  FGrid.ClickAt(ButtonPoint(0));
  Assert.AreEqual(1, FGrid.Activations);
  Assert.IsFalse(FData.FieldByName('SELECIONADO').AsBoolean);
  FGrid.PressKey(VK_ESCAPE);
  FGrid.PressKey(VK_SPACE); FGrid.ReleaseKey(VK_SPACE);
  Assert.IsTrue(FData.FieldByName('SELECIONADO').AsBoolean);
  Assert.AreEqual(1, FGrid.Activations);
  FGrid.PressKey(VK_F2);
  FGrid.PressKey(VK_RIGHT);
  FGrid.PressKey(VK_RETURN); FGrid.ReleaseKey(VK_RETURN);
  Assert.AreEqual(2, FGrid.Activations);
  Assert.AreEqual('editar', FGrid.LastContext.ActionId);
end;

procedure TMovimentoBancarioAcoesGridTests.RedimensionarRespeitaCelulaERecriarHandleCancela;
var P: TPoint;
begin
  P := ButtonPoint(2); FGrid.DownAt(P); FGrid.Columns[1].Width := 100; FGrid.UpAt(P);
  Assert.AreEqual(0, FGrid.Activations);
  Assert.IsTrue(FGrid.ActionRect(1, 0, 1).IsEmpty);
  Assert.IsTrue(FGrid.ActionRect(1, 0, 2).IsEmpty);
  FGrid.Columns[1].Width := 196;
  P := ButtonPoint(0); FGrid.DownAt(P); FGrid.Recreate; FGrid.UpAt(P);
  Assert.AreEqual(0, FGrid.Activations);
  FGrid.ClickAt(ButtonPoint(0));
  Assert.AreEqual(1, FGrid.Activations);
end;

procedure TMovimentoBancarioAcoesGridTests.QuantidadeDeControlesIndependeDeRegistros;
var I, Controls, Components: Integer;
begin
  Controls := FGrid.ControlCount; Components := FGrid.ComponentCount;
  FData.DisableControls;
  try
    for I := 81 to 1000 do FData.AppendRecord(['0000000007', Format('%.10d', [I])]);
  finally FData.EnableControls; end;
  Pump;
  Assert.AreEqual(Controls, FGrid.ControlCount);
  Assert.AreEqual(Components, FGrid.ComponentCount);
end;

procedure TMovimentoBancarioAcoesGridTests.DestruirDataSourceComBotaoPressionadoNaoDispara;
var P: TPoint;
begin
  P := ButtonPoint(0);
  FGrid.DownAt(P);
  FreeAndNil(FSource);
  FGrid.UpAt(P);
  Assert.AreEqual(0, FGrid.Activations);
  Assert.IsTrue(FGrid.DataSource = nil);
  Assert.IsTrue(FGrid.ActionRect(1, 0, 0).IsEmpty);
end;

procedure TMovimentoBancarioAcoesGridTests.IdentificadoresVaziosOuDuplicadosSaoRejeitados;
begin
  Assert.WillRaise(procedure
    begin FGrid.Columns[1].Actions[1].ActionId := 'DETALHES'; end, EArgumentException);
  Assert.WillRaise(procedure
    begin FGrid.Columns[1].Actions[1].ActionId := ''; end, EArgumentException);
  Assert.AreEqual('editar', FGrid.Columns[1].Actions[1].ActionId);
end;

procedure TMovimentoBancarioAcoesGridTests.AssignEStreamingPreservamAcoes;
var Other: TDACDBGrid; S: TMemoryStream;
begin
  Other := TDACDBGrid.Create(nil); S := TMemoryStream.Create;
  try
    Other.Layout.Enabled := False;
    Other.Columns.Assign(FGrid.Columns);
    Assert.AreEqual(3, Other.Columns[1].Actions.Count);
    Assert.AreEqual('excluir', Other.Columns[1].Actions[2].ActionId);
    Other.Columns[1].Actions[0].Caption := 'Outro';
    Assert.AreEqual('Detalhes', FGrid.Columns[1].Actions[0].Caption);
    Other.Columns[1].Actions[1].Visible := False;
    Other.Columns[1].Actions[2].Enabled := False;
    Other.ActionKeyFields := FGrid.ActionKeyFields;
    S.WriteComponent(Other); S.Position := 0;
    Other.Free; Other := nil;
    System.Classes.RegisterClass(TDACDBGrid);
    Other := S.ReadComponent(nil) as TDACDBGrid;
    Assert.AreEqual('COD_EMP;MOV_COD', Other.ActionKeyFields);
    Assert.AreEqual(3, Other.Columns[1].Actions.Count);
    Assert.AreEqual(daaDanger, Other.Columns[1].Actions[2].Appearance);
    Assert.IsFalse(Other.Columns[1].Actions[1].Visible);
    Assert.IsFalse(Other.Columns[1].Actions[2].Enabled);
    Assert.IsFalse(Other.HandleAllocated);
  finally Other.Free; S.Free; end;
end;

procedure TMovimentoBancarioAcoesGridTests.LayoutNaoSobrescreveDefinicoesDeAcoes;
var FileName: string;
begin
  FileName := TPath.Combine(TPath.GetTempPath, TPath.GetRandomFileName + '.json');
  FGrid.Layout.AutoSave := False;
  FGrid.Layout.StorageFileName := FileName;
  FGrid.Layout.Enabled := True;
  try
    FGrid.SaveLayout;
    FGrid.Columns[1].Width := 250;
    FGrid.Columns[1].Actions[0].Caption := 'Atualizado';
    FGrid.LoadLayout;
    Assert.AreEqual(196, FGrid.Columns[1].Width);
    Assert.AreEqual('Atualizado', FGrid.Columns[1].Actions[0].Caption);
    Assert.AreEqual(3, FGrid.Columns[1].Actions.Count);
  finally
    FGrid.Layout.Enabled := False;
    if TFile.Exists(FileName) then TFile.Delete(FileName);
  end;
end;

procedure TMovimentoBancarioAcoesGridTests.RenderizaTemasEEstados;
var B: TBitmap; P: TPngImage; FileName: string; Theme: TDACThemeMode;
  PressPoint: TPoint; NormalColor: TColor;
  function ContrastingIconPixels(const Bounds: TRect): Integer;
  var X, Y: Integer; Background, Pixel: TColor; Icon: TRect;
  begin
    Result := 0;
    Background := ColorToRGB(B.Canvas.Pixels[Bounds.Left + 4, Bounds.CenterPoint.Y]);
    Icon := Rect(Bounds.CenterPoint.X - 8, Bounds.CenterPoint.Y - 8,
      Bounds.CenterPoint.X + 8, Bounds.CenterPoint.Y + 8);
    for Y := Icon.Top to Icon.Bottom - 1 do
      for X := Icon.Left to Icon.Right - 1 do
      begin
        Pixel := ColorToRGB(B.Canvas.Pixels[X, Y]);
        if Abs(GetRValue(Pixel) - GetRValue(Background)) +
          Abs(GetGValue(Pixel) - GetGValue(Background)) +
          Abs(GetBValue(Pixel) - GetBValue(Background)) > 48 then Inc(Result);
      end;
  end;
begin
  B := TBitmap.Create; P := TPngImage.Create;
  try
    B.SetSize(FGrid.Width, FGrid.Height);
    for Theme := dtmDark to dtmLight do
    begin
      FGrid.ThemeMode := Theme;
      FGrid.DisabledAction := 'editar';
      FGrid.MoveAt(ButtonPoint(2));
      FGrid.PressKey(VK_F2);
      Pump;
      FGrid.MoveAt(ButtonPoint(2));
      FGrid.PaintTo(B.Canvas.Handle, 0, 0);
      Assert.IsTrue(ContrastingIconPixels(FGrid.ActionRect(1, 1, 2)) > 8,
        'Lixeira normal sem contraste no tema.');
      Assert.IsTrue(ContrastingIconPixels(FGrid.ActionRect(1, 0, 2)) > 8,
        'Lixeira em hover sem contraste no tema.');
      P.Assign(B);
      FileName := ExtractFilePath(ParamStr(0)) + 'dbgrid-actions-' + IntToStr(Ord(Theme)) + '.png';
      P.SaveToFile(FileName);
      Assert.IsTrue(Length(TFile.ReadAllBytes(FileName)) > 1000);
      PressPoint := ButtonPoint(0);
      NormalColor := B.Canvas.Pixels[FGrid.ActionRect(1, 0, 0).Left + 4, PressPoint.Y];
      FGrid.DownAt(PressPoint);
      FGrid.PaintTo(B.Canvas.Handle, 0, 0);
      Assert.IsTrue(NormalColor <> B.Canvas.Pixels[FGrid.ActionRect(1, 0, 0).Left + 4, PressPoint.Y],
        'Estado pressionado nao alterou a superficie do botao.');
      P.Assign(B);
      P.SaveToFile(ExtractFilePath(ParamStr(0)) + 'dbgrid-actions-pressed-' + IntToStr(Ord(Theme)) + '.png');
      FGrid.Perform(WM_CANCELMODE, 0, 0);
      FGrid.UpAt(PressPoint);
      Assert.AreEqual(0, FGrid.Activations);
    end;
  finally P.Free; B.Free; end;
end;

procedure TMovimentoBancarioAcoesGridTests.LoadGridDFM(const AAba: string);
var FileName, Text, Block: string; Match: TMatch;
  Input: TStringStream; Binary: TMemoryStream;
begin
  FileName := TPath.GetFullPath(ExtractFilePath(ParamStr(0)) + '..\source\view\View.MovimentoBancario.dfm');
  Text := TFile.ReadAllText(FileName, TEncoding.GetEncoding(1252));
  Match := TRegEx.Match(Text, '(?ms)^        object grdMovimentos' + AAba +
    ': TDACDBGrid\r?\n.*?^        end\r?$');
  Assert.IsTrue(Match.Success);
  // External datasource belongs to the form, not to this standalone streaming fixture.
  Block := TRegEx.Replace(Match.Value, '(?m)^\s*DataSource = [^\r\n]+\r?\n', '');
  FGrid.DataSource := nil;
  Input := TStringStream.Create(Block, TEncoding.UTF8);
  Binary := TMemoryStream.Create;
  try
    ObjectTextToBinary(Input, Binary); Binary.Position := 0;
    Binary.ReadComponent(FGrid);
    Assert.AreEqual('COD_EMP;MOV_COD', FGrid.ActionKeyFields);
    Assert.AreEqual(12, FGrid.Columns.Count);
    Assert.AreEqual('OPCOES', FGrid.Columns[11].LayoutKey);
    Assert.AreEqual(196, FGrid.Columns[11].Width);
    Assert.AreEqual(3, FGrid.Columns[11].Actions.Count);
    Assert.AreEqual('detalhes', FGrid.Columns[11].Actions[0].ActionId);
    Assert.AreEqual('Detalhes', FGrid.Columns[11].Actions[0].Caption);
    Assert.AreEqual(mikEdit, FGrid.Columns[11].Actions[1].IconKind);
    Assert.AreEqual(mikTrash, FGrid.Columns[11].Actions[2].IconKind);
    Assert.AreEqual(daaDanger, FGrid.Columns[11].Actions[2].Appearance);
    Assert.IsTrue(Assigned(FGrid.OnActionState));
    Assert.IsTrue(Assigned(FGrid.OnActionExecute));
    Binary.Clear; Binary.WriteComponent(FGrid); Binary.Position := 0;
    Binary.ReadComponent(FGrid);
    Assert.AreEqual(3, FGrid.Columns[11].Actions.Count);
  finally Binary.Free; Input.Free; end;
end;

procedure TMovimentoBancarioAcoesGridTests.DFMRealDasGridsPodeSerLidoEGravado(const AAba: string);
begin LoadGridDFM(AAba); end;

initialization
  TDUnitX.RegisterTestFixture(TMovimentoBancarioAcoesGridTests);
end.
