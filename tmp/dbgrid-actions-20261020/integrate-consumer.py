from pathlib import Path

root = Path(r'M:\MaxxSoft\MaxxRural\Desktop\maxxrural')

def change(relative, replacements):
    p = root / relative
    original = p.read_bytes()
    text = original.decode('cp1252').replace('\r\n', '\n')
    for before, after in replacements:
        assert text.count(before) == 1, (relative, before[:90], text.count(before))
        text = text.replace(before, after)
    p.write_bytes(text.replace('\n', '\r\n').encode('cp1252'))

change('source/model/service/Service.MovimentoBancario.pas', [
('  EContaCadastroRegra = class', '''  TMovimentoBancarioAcaoEstado = record
    Identificador: string;
    Visivel, Habilitada: Boolean;
  end;

  EContaCadastroRegra = class'''),
('    function DescricaoTipoConta(const ATipo: string): string;', '''    function DescricaoTipoConta(const ATipo: string): string;
    function AcoesDisponiveis(const AEmpresa, AMovimento: string): TArray<TMovimentoBancarioAcaoEstado>;
    function ValidarIntencaoAcao(const AAcao, AEmpresa, AMovimento: string): Boolean;'''),
('function TMovimentoBancarioService.ConsultarConta(', '''function TMovimentoBancarioService.AcoesDisponiveis(const AEmpresa,
  AMovimento: string): TArray<TMovimentoBancarioAcaoEstado>;
const Ids: array[0..2] of string = ('detalhes', 'editar', 'excluir');
var I: Integer;
begin
  SetLength(Result, Length(Ids));
  for I := 0 to High(Ids) do
  begin
    Result[I].Identificador := Ids[I];
    Result[I].Visivel := True;
    // Somente disponibilidade da intencao visual. Nao autoriza operacoes financeiras.
    Result[I].Habilitada := (AEmpresa = FEmpresa) and (Trim(AMovimento) <> '');
  end;
end;

function TMovimentoBancarioService.ValidarIntencaoAcao(const AAcao,
  AEmpresa, AMovimento: string): Boolean;
var Estado: TMovimentoBancarioAcaoEstado;
begin
  Result := False;
  for Estado in AcoesDisponiveis(AEmpresa, AMovimento) do
    if SameText(Estado.Identificador, AAcao) then
      Exit(Estado.Visivel and Estado.Habilitada);
end;

function TMovimentoBancarioService.ConsultarConta(''')])

change('source/controller/Controller.MovimentoBancario.pas', [
('  TMovimentoBancarioTomCard =', '''  TMovimentoBancarioAcaoEstado = Service.MovimentoBancario.TMovimentoBancarioAcaoEstado;
  TMovimentoBancarioIntencao = record
    Acao, Empresa, Movimento: string;
  end;
  TMovimentoBancarioTomCard ='''),
('    FService: TMovimentoBancarioService;', '    FService: TMovimentoBancarioService;\n    FUltimaIntencao: TMovimentoBancarioIntencao;'),
('    property Estado: TMovimentoBancarioEstado read FEstado;', '''    function AcoesDisponiveis(const AEmpresa, AMovimento: string): TArray<TMovimentoBancarioAcaoEstado>;
    function SolicitarAcao(const AAcao, AEmpresa, AMovimento: string): Boolean;
    property UltimaIntencao: TMovimentoBancarioIntencao read FUltimaIntencao;
    property Estado: TMovimentoBancarioEstado read FEstado;'''),
('procedure TMovimentoBancarioController.AlterarCodigoConta(', '''function TMovimentoBancarioController.AcoesDisponiveis(const AEmpresa,
  AMovimento: string): TArray<TMovimentoBancarioAcaoEstado>;
begin
  Result := FService.AcoesDisponiveis(AEmpresa, AMovimento);
end;

function TMovimentoBancarioController.SolicitarAcao(const AAcao,
  AEmpresa, AMovimento: string): Boolean;
begin
  FUltimaIntencao := Default(TMovimentoBancarioIntencao);
  Result := FService.ValidarIntencaoAcao(AAcao, AEmpresa, AMovimento);
  if not Result then
  begin
    FEstado.Mensagem := 'Acao indisponivel para este registro.';
    FEstado.TipoMensagem := mbmInformacao;
    Exit;
  end;
  FUltimaIntencao.Acao := AAcao;
  FUltimaIntencao.Empresa := AEmpresa;
  FUltimaIntencao.Movimento := AMovimento;
  FEstado.Mensagem := 'Intencao "' + AAcao + '" recebida para o movimento ' +
    AMovimento + '. Operacao financeira nao executada nesta etapa.';
  FEstado.TipoMensagem := mbmInformacao;
end;

procedure TMovimentoBancarioController.AlterarCodigoConta(''')])

change('source/view/View.MovimentoBancario.pas', [
('  Datasnap.DBClient,', '''  Datasnap.DBClient,
  DAC.Components.Controls.DBGrid.Column,
  DAC.Components.Controls.DBGrid.Action,
  DAC.Components.Controls.DBGrid.ActionTypes,'''),
('    procedure btnAplicarClick(Sender: TObject);', '''    procedure GridAcaoEstado(Sender: TObject; AColumn: TDACDBGridColumn;
      AAction: TDACDBGridAction; const AContext: TDACDBGridActionContext;
      var AVisible, AEnabled: Boolean);
    procedure GridAcaoExecutar(Sender: TObject; AColumn: TDACDBGridColumn;
      AAction: TDACDBGridAction; const AContext: TDACDBGridActionContext);
    procedure btnAplicarClick(Sender: TObject);'''),
('  System.SysUtils,', '  System.SysUtils,\n  System.Variants,'),
('  FController := AController;', '''  FController := AController;
  grdMovimentosProntos.Redraw;
  grdMovimentosConciliar.Redraw;
  grdMovimentosImportados.Redraw;'''),
('procedure TfrmMovimentoBancarioView.AtualizarConta;', '''procedure TfrmMovimentoBancarioView.GridAcaoEstado(Sender: TObject;
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

procedure TfrmMovimentoBancarioView.AtualizarConta;''')])

p = root / 'source/view/View.MovimentoBancario.dfm'
b = p.read_bytes()
marker = b"              Width = 110\r\n              Visible = True\r\n              LayoutKey = 'OPCOES'"
assert b.count(marker) == 3
actions = '''              Width = 196
              Visible = True
              LayoutKey = 'OPCOES'
              Actions = <
                item
                  ActionId = 'detalhes'
                  Caption = 'Detalhes'
                  Hint = 'Detalhes do lancamento'
                  Width = 80
                end
                item
                  ActionId = 'editar'
                  IconKind = mikEdit
                  Hint = 'Editar lancamento'
                end
                item
                  ActionId = 'excluir'
                  IconKind = mikTrash
                  Hint = 'Excluir lancamento'
                  Appearance = daaDanger
                end>'''.replace('\n', '\r\n').encode('ascii')
b = b.replace(marker, actions)
for name in ['Prontos', 'Conciliar', 'Importados']:
    marker = ('        object grdMovimentos' + name + ': TDACDBGrid\r\n').encode('ascii')
    assert b.count(marker) == 1
    events = '''          ActionKeyFields = 'COD_EMP;MOV_COD'
          ShowHint = True
          OnActionState = GridAcaoEstado
          OnActionExecute = GridAcaoExecutar
'''.replace('\n', '\r\n').encode('ascii')
    b = b.replace(marker, marker + events)
p.write_bytes(b)
print('Consumer: three DFM action columns, View forwarding, Controller and Service intent-only path.')
