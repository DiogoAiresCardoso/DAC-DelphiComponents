unit View.MovimentoBancario;

interface

uses
  System.Classes,
  Datasnap.DBClient,
  DAC.Components.Controls.DBGrid.Column,
  DAC.Components.Controls.DBGrid.Action,
  DAC.Components.Controls.DBGrid.ActionTypes,
  ufrmMaster,
  Controller.MovimentoBancario, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters, Vcl.StdCtrls,
  Vcl.Buttons, dxStatusBar, Vcl.Controls, Vcl.ExtCtrls, DAC.Components.Controls.Container,
  DAC.Components.Controls.Button, RzPanel, DAC.Components.Controls.Edit, DAC.Components.Controls.ButtonEdit,
  DAC.Components.Controls.DateTimePicker, DAC.Components.Controls.SummaryCard, Data.DB, Vcl.Grids,
  Vcl.DBGrids, DAC.Components.Controls.DBGrid, Vcl.ComCtrls, DAC.Components.Controls.Tabs;

type
  TfrmMovimentoBancarioView = class(TfrmMaster)
    pnlAcoes: TRzPanel;
    btnImportarOFX: TDACButton;
    btnTransferir: TDACButton;
    btnNovaMovimentacao: TDACButton;
    flpFiltros: TFlowPanel;
    edtCodigoConta: TDACButtonEdit;
    edtDescricaoConta: TDACEdit;
    edtAgencia: TDACEdit;
    edtNumeroConta: TDACEdit;
    edtBanco: TDACEdit;
    edtDescricaoBanco: TDACEdit;
    edtCodigoBanco: TDACEdit;
    edtTipoConta: TDACEdit;
    pnlPeriodo: TPanel;
    dtpDataInicial: TDACDateTimePicker;
    dtpDataFinal: TDACDateTimePicker;
    btnAplicar: TDACButton;
    pnlSaldos: TPanel;
    cntSaldosConta: TDACContainer;
    crdSaldoInicial: TDACSummaryCard;
    crdEntradas: TDACSummaryCard;
    crdSaidas: TDACSummaryCard;
    crdSaldoSistema: TDACSummaryCard;
    DACTabs1: TDACTabs;
    TabSheet1: TTabSheet;
    TabSheet2: TTabSheet;
    TabSheet3: TTabSheet;
    grdMovimentosProntos: TDACDBGrid;
    grdMovimentosConciliar: TDACDBGrid;
    grdMovimentosImportados: TDACDBGrid;
    cdsMovimentosProntos: TClientDataSet;
    dtsMovimentosProntos: TDataSource;
    cdsMovimentosProntosMOV_COD: TStringField;
    cdsMovimentosProntosCOD_EMP: TStringField;
    cdsMovimentosProntosMOV_CONTA: TStringField;
    cdsMovimentosProntosMOV_DATA: TDateField;
    cdsMovimentosProntosMOV_VALOR: TFMTBCDField;
    cdsMovimentosProntosMOV_TIPO: TStringField;
    cdsMovimentosProntosMOV_CONS: TStringField;
    cdsMovimentosProntosMOV_DTCONS: TDateField;
    cdsMovimentosProntosMOV_HIST: TStringField;
    cdsMovimentosProntosHIST_DESC: TStringField;
    cdsMovimentosProntosMOV_TIPG: TStringField;
    cdsMovimentosProntosTPGTO_DESC: TStringField;
    cdsMovimentosProntosMOV_SIT: TStringField;
    cdsMovimentosProntosMOV_RELRP: TStringField;
    cdsMovimentosProntosMOV_RELTIPO: TStringField;
    cdsMovimentosProntosMOV_HISTCOMPL: TMemoField;
    cdsMovimentosProntosDUMANUT: TSQLTimeStampField;
    cdsMovimentosProntosCOD_USU: TStringField;
    cdsMovimentosProntosMOV_CICLO: TStringField;
    cdsMovimentosProntosMOV_BAIXADOC: TStringField;
    cdsMovimentosProntosMOV_TRANSF: TStringField;
    cdsMovimentosProntosMOV_TRANSFCOD: TStringField;
    cdsMovimentosProntosTPGTO_ABRE: TStringField;
    cdsMovimentosProntosCHEQUE_NUM: TStringField;
    cdsMovimentosProntosMOVIMENTOFECHADO: TStringField;
    cdsMovimentosConciliar: TClientDataSet;
    dtsMovimentosConciliar: TDataSource;
    cdsMovimentosConciliarMOV_COD: TStringField;
    cdsMovimentosConciliarCOD_EMP: TStringField;
    cdsMovimentosConciliarMOV_CONTA: TStringField;
    cdsMovimentosConciliarMOV_DATA: TDateField;
    cdsMovimentosConciliarMOV_VALOR: TFMTBCDField;
    cdsMovimentosConciliarMOV_TIPO: TStringField;
    cdsMovimentosConciliarMOV_CONS: TStringField;
    cdsMovimentosConciliarMOV_DTCONS: TDateField;
    cdsMovimentosConciliarMOV_HIST: TStringField;
    cdsMovimentosConciliarHIST_DESC: TStringField;
    cdsMovimentosConciliarMOV_TIPG: TStringField;
    cdsMovimentosConciliarTPGTO_DESC: TStringField;
    cdsMovimentosConciliarMOV_SIT: TStringField;
    cdsMovimentosConciliarMOV_RELRP: TStringField;
    cdsMovimentosConciliarMOV_RELTIPO: TStringField;
    cdsMovimentosConciliarMOV_HISTCOMPL: TMemoField;
    cdsMovimentosConciliarDUMANUT: TSQLTimeStampField;
    cdsMovimentosConciliarCOD_USU: TStringField;
    cdsMovimentosConciliarMOV_CICLO: TStringField;
    cdsMovimentosConciliarMOV_BAIXADOC: TStringField;
    cdsMovimentosConciliarMOV_TRANSF: TStringField;
    cdsMovimentosConciliarMOV_TRANSFCOD: TStringField;
    cdsMovimentosConciliarTPGTO_ABRE: TStringField;
    cdsMovimentosConciliarCHEQUE_NUM: TStringField;
    cdsMovimentosConciliarMOVIMENTOFECHADO: TStringField;
    cdsMovimentosImportados: TClientDataSet;
    dtsMovimentosImportados: TDataSource;
    cdsMovimentosImportadosMOV_COD: TStringField;
    cdsMovimentosImportadosCOD_EMP: TStringField;
    cdsMovimentosImportadosMOV_CONTA: TStringField;
    cdsMovimentosImportadosMOV_DATA: TDateField;
    cdsMovimentosImportadosMOV_VALOR: TFMTBCDField;
    cdsMovimentosImportadosMOV_TIPO: TStringField;
    cdsMovimentosImportadosMOV_CONS: TStringField;
    cdsMovimentosImportadosMOV_DTCONS: TDateField;
    cdsMovimentosImportadosMOV_HIST: TStringField;
    cdsMovimentosImportadosHIST_DESC: TStringField;
    cdsMovimentosImportadosMOV_TIPG: TStringField;
    cdsMovimentosImportadosTPGTO_DESC: TStringField;
    cdsMovimentosImportadosMOV_SIT: TStringField;
    cdsMovimentosImportadosMOV_RELRP: TStringField;
    cdsMovimentosImportadosMOV_RELTIPO: TStringField;
    cdsMovimentosImportadosMOV_HISTCOMPL: TMemoField;
    cdsMovimentosImportadosDUMANUT: TSQLTimeStampField;
    cdsMovimentosImportadosCOD_USU: TStringField;
    cdsMovimentosImportadosMOV_CICLO: TStringField;
    cdsMovimentosImportadosMOV_BAIXADOC: TStringField;
    cdsMovimentosImportadosMOV_TRANSF: TStringField;
    cdsMovimentosImportadosMOV_TRANSFCOD: TStringField;
    cdsMovimentosImportadosTPGTO_ABRE: TStringField;
    cdsMovimentosImportadosCHEQUE_NUM: TStringField;
    cdsMovimentosImportadosMOVIMENTOFECHADO: TStringField;
    procedure GridAcaoEstado(Sender: TObject; AColumn: TDACDBGridColumn;
      AAction: TDACDBGridAction; const AContext: TDACDBGridActionContext;
      var AVisible, AEnabled: Boolean);
    procedure GridAcaoExecutar(Sender: TObject; AColumn: TDACDBGridColumn;
      AAction: TDACDBGridAction; const AContext: TDACDBGridActionContext);
    procedure btnAplicarClick(Sender: TObject);
    procedure PeriodoChange(Sender: TObject);
    procedure edtCodigoContaChange(Sender: TObject);
    procedure edtCodigoContaExit(Sender: TObject);
    procedure edtCodigoContaButtonClick(Sender: TObject);
  private
    FController: TMovimentoBancarioController;
    FAtualizandoConta: Boolean;
    FSelecionandoConta: Boolean;
    procedure AtualizarConta;
    procedure AtualizarCards;
    procedure AplicarEstadoCard(ACard: TDACSummaryCard; const AValor: string;
      ATom: TMovimentoBancarioTomCard);
    procedure TemaCardsAlterado(Sender: TObject);
    procedure ExibirMensagem;
  protected
    procedure DoShow; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    // Recebe a propriedade do Controller; deve ser chamado antes de exibir a tela.
    procedure DefinirController(AController: TMovimentoBancarioController);
  end;

implementation

uses
  System.SysUtils,
  System.Variants,
  Vcl.Forms,
  Vcl.Graphics,
  DAC.Components.DesignSystem.ColorTokens,
  DAC.Components.DesignSystem.ComponentStyle,
  DAC.Components.DesignSystem.ControlTokens,
  DAC.Components.DesignSystem.Theme,
  uMensagens;

{$R *.dfm}

constructor TfrmMovimentoBancarioView.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  // Buffers locais e vazios; a carga e a classificação dos lançamentos serão feitas em outra etapa.
  cdsMovimentosProntos.CreateDataSet;
  cdsMovimentosProntos.LogChanges := False;
  cdsMovimentosConciliar.CreateDataSet;
  cdsMovimentosConciliar.LogChanges := False;
  cdsMovimentosImportados.CreateDataSet;
  cdsMovimentosImportados.LogChanges := False;
  Foco := edtCodigoConta;
  TDACThemeManager.RegisterListener(Self, TemaCardsAlterado);
end;

destructor TfrmMovimentoBancarioView.Destroy;
begin
  try
    TDACThemeManager.UnregisterListener(Self);
    FreeAndNil(FController);
    // Libera também no Free direto, que não dispara o OnClose do Master.
    FreeAndNil(ListaComponentesPermitidos);
    FreeAndNil(ListaObrigatorios);
  finally
    inherited Destroy;
  end;
end;

procedure TfrmMovimentoBancarioView.DefinirController(
  AController: TMovimentoBancarioController);
begin
  if not Assigned(AController) then
    raise EArgumentNilException.Create('AController');
  if Assigned(FController) then
    raise EArgumentException.Create('O Controller já foi definido para esta tela.');
  FController := AController;
  grdMovimentosProntos.Redraw;
  grdMovimentosConciliar.Redraw;
  grdMovimentosImportados.Redraw;
end;

procedure TfrmMovimentoBancarioView.GridAcaoEstado(Sender: TObject;
  AColumn: TDACDBGridColumn; AAction: TDACDBGridAction;
  const AContext: TDACDBGridActionContext; var AVisible, AEnabled: Boolean);
var Estado: TMovimentoBancarioAcaoEstado;
begin
  AEnabled := False;
  if not Assigned(FController) or not AContext.HasCompleteKey then Exit;
  AVisible := False;
  for Estado in FController.AcoesDisponiveis(VarToStr(AContext.ValueOf('COD_EMP')),
    VarToStr(AContext.ValueOf('MOV_COD'))) do
    if SameText(Estado.Identificador, AContext.ActionId) then
    begin
      AVisible := Estado.Visivel;
      AEnabled := Estado.Habilitada;
      Exit;
    end;
end;

procedure TfrmMovimentoBancarioView.GridAcaoExecutar(Sender: TObject;
  AColumn: TDACDBGridColumn; AAction: TDACDBGridAction;
  const AContext: TDACDBGridActionContext);
begin
  if not Assigned(FController) or not AContext.HasCompleteKey then Exit;
  FController.SolicitarAcao(AContext.ActionId, VarToStr(AContext.ValueOf('COD_EMP')),
    VarToStr(AContext.ValueOf('MOV_COD')));
  ExibirMensagem;
end;

procedure TfrmMovimentoBancarioView.AtualizarConta;
var
  LEstado: TMovimentoBancarioEstado;
begin
  if not Assigned(FController) then Exit;
  LEstado := FController.Estado;
  FAtualizandoConta := True;
  try
    edtCodigoConta.Text := LEstado.CodigoConta;
    edtDescricaoConta.Text := LEstado.DescricaoConta;
    edtAgencia.Text := LEstado.Agencia;
    edtNumeroConta.Text := LEstado.NumeroConta;
    edtBanco.Text := LEstado.Banco;
    edtDescricaoBanco.Text := LEstado.DescricaoBanco;
    edtCodigoBanco.Text := LEstado.CodigoBanco;
    edtTipoConta.Text := LEstado.TipoConta;
    btnAplicar.Enabled := LEstado.PodeAplicar;
    AtualizarCards;
  finally
    FAtualizandoConta := False;
  end;
end;

procedure TfrmMovimentoBancarioView.ExibirMensagem;
var
  LEstado: TMovimentoBancarioEstado;
begin
  LEstado := FController.Estado;
  case LEstado.TipoMensagem of
    mbmInformacao: TfrmMensagens.Mensagem(LEstado.Mensagem, 'I', Caption, [mbOk]);
    mbmErro: TfrmMensagens.Mensagem(LEstado.Mensagem, 'E', Caption, [mbOk]);
  end;
end;

procedure TfrmMovimentoBancarioView.edtCodigoContaChange(Sender: TObject);
begin
  if FAtualizandoConta or not Assigned(FController) or
    (csLoading in ComponentState) or (csDestroying in ComponentState) then Exit;
  FController.AlterarCodigoConta(edtCodigoConta.Text);
  AtualizarConta;
end;

procedure TfrmMovimentoBancarioView.edtCodigoContaExit(Sender: TObject);
var
  LCursorAnterior: TCursor;
begin
  if FSelecionandoConta or not Assigned(FController) or
    (csDestroying in ComponentState) then Exit;
  LCursorAnterior := Screen.Cursor;
  Screen.Cursor := crHourGlass;
  try
    FController.ConsultarConta(edtCodigoConta.Text);
    AtualizarConta;
  finally
    Screen.Cursor := LCursorAnterior;
  end;
  ExibirMensagem;
end;

procedure TfrmMovimentoBancarioView.edtCodigoContaButtonClick(Sender: TObject);
begin
  if FSelecionandoConta or not Assigned(FController) then Exit;
  FSelecionandoConta := True;
  try
    FController.PesquisarConta;
    AtualizarConta;
    ExibirMensagem;
  finally
    FSelecionandoConta := False;
  end;
end;

procedure TfrmMovimentoBancarioView.DoShow;
var LEstado: TMovimentoBancarioEstado;
begin
  if Assigned(FController) then
  begin
    LEstado := FController.Estado;
    FAtualizandoConta := True;
    try
      dtpDataInicial.DateTime := LEstado.DataInicial;
      dtpDataFinal.DateTime := LEstado.DataFinal;
    finally
      FAtualizandoConta := False;
    end;
    AtualizarConta;
  end;
  inherited DoShow;
end;

procedure TfrmMovimentoBancarioView.PeriodoChange(Sender: TObject);
begin
  if FAtualizandoConta or not Assigned(FController) or
    (csLoading in ComponentState) or (csDestroying in ComponentState) then Exit;
  FController.AlterarPeriodo(dtpDataInicial.DateTime, dtpDataFinal.DateTime);
  AtualizarConta;
end;

procedure TfrmMovimentoBancarioView.btnAplicarClick(Sender: TObject);
var LCursor: TCursor;
begin
  if not Assigned(FController) then Exit;
  LCursor := Screen.Cursor;
  Screen.Cursor := crHourGlass;
  btnAplicar.Enabled := False;
  try
    FController.AlterarPeriodo(dtpDataInicial.DateTime, dtpDataFinal.DateTime);
    FController.ConsultarSaldos;
  finally
    Screen.Cursor := LCursor;
    AtualizarConta;
  end;
  ExibirMensagem;
end;

procedure TfrmMovimentoBancarioView.AplicarEstadoCard(ACard: TDACSummaryCard;
  const AValor: string; ATom: TMovimentoBancarioTomCard);
var LTokens: TDACControlTokens;
begin
  LTokens := TDACComponentStyle.ResolveForSurface(ACard, ACard.ThemeMode).Tokens.Controls;
  // As fontes pertencem ao componente; não criamos TFont externos.
  ACard.TitleFont.Color := clDefault;
  ACard.FooterFont.Color := clDefault;
  case ATom of
    mbcPositivo:
      begin
        ACard.Status := mcsSuccess;
        ACard.ValueFont.Color := TDACComponentColors.ToVclColor(LTokens.SummaryCardSuccess);
      end;
    mbcNegativo:
      begin
        ACard.Status := mcsDanger;
        ACard.ValueFont.Color := TDACComponentColors.ToVclColor(LTokens.SummaryCardDanger);
      end;
    mbcNeutro:
      begin
        ACard.Status := mcsNeutral;
        ACard.ValueFont.Color := clDefault;
      end;
  else
    ACard.Status := mcsNeutral;
    ACard.ValueFont.Color := TDACComponentColors.ToVclColor(LTokens.SummaryCardFooterNeutral);
  end;
  ACard.Value := AValor;
end;

procedure TfrmMovimentoBancarioView.AtualizarCards;
var
  LEstado: TMovimentoBancarioEstado;
  LAltura: Integer;
  LCard: TDACSummaryCard;
begin
  if not Assigned(FController) then Exit;
  LEstado := FController.Estado;
  AplicarEstadoCard(crdSaldoInicial, LEstado.SaldoInicial, LEstado.TomSaldoInicial);
  AplicarEstadoCard(crdEntradas, LEstado.Entradas, LEstado.TomEntradas);
  AplicarEstadoCard(crdSaidas, LEstado.Saidas, LEstado.TomSaidas);
  AplicarEstadoCard(crdSaldoSistema, LEstado.SaldoTotal, LEstado.TomSaldoTotal);
  LAltura := 152;
  for LCard in TArray<TDACSummaryCard>.Create(crdSaldoInicial, crdEntradas, crdSaidas, crdSaldoSistema) do
    if LCard.Top + LCard.Height + 12 > LAltura then
      LAltura := LCard.Top + LCard.Height + 12;
  pnlSaldos.Height := LAltura;
end;

procedure TfrmMovimentoBancarioView.TemaCardsAlterado(Sender: TObject);
begin
  if not (csDestroying in ComponentState) then AtualizarCards;
end;

end.
