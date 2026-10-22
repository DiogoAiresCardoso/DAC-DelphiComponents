program MaxxCORG;

uses
  ExceptionLog,
  Forms,
  Windows,
  ShellApi,
  SysUtils,
  IwSystem,
  IniFiles,
  ufrmPrincipal in 'ufrmPrincipal.pas' {frmPrincipal},
  Base64 in '..\..\Geral\Base64.pas',
  DCPconst in '..\..\Geral\DCPconst.pas',
  DCPcrypt in '..\..\Geral\DCPcrypt.pas',
  IDEA in '..\..\Geral\IDEA.pas',
  Md5 in '..\..\Geral\Md5.pas',
  Sha1 in '..\..\Geral\Sha1.pas',
  U_Cipher in '..\..\Geral\U_Cipher.pas',
  udmMaxxLocal in '..\..\Geral\udmMaxxLocal.pas' {dmMaxxLocal: TDataModule},
  ufrmAguarde in '..\..\Geral\ufrmAguarde.pas' {frmAguarde},
  ufrmBolMaxx in '..\..\Geral\ufrmBolMaxx.pas' {frmBolMaxx},
  ufrmFerPermissoes in '..\..\Geral\ufrmFerPermissoes.pas' {frmFerPermissoes},
  ufrmInformacoes in '..\..\Geral\ufrmInformacoes.pas' {frmInformacoes},
  ufrmMaster in '..\..\Geral\ufrmMaster.pas' {frmMaster},
  ufrmMasterCad in '..\..\Geral\ufrmMasterCad.pas' {frmMasterCad},
  ufrmMasterConsulta in '..\..\Geral\ufrmMasterConsulta.pas' {frmMasterConsulta},
  ufrmMasterDet in '..\..\Geral\ufrmMasterDet.pas' {frmMasterDet},
  ufrmMasterGraf in '..\..\Geral\ufrmMasterGraf.pas' {frmMasterGraf},
  ufrmMasterGrafVis in '..\..\Geral\ufrmMasterGrafVis.pas' {frmMasterGrafVis},
  ufrmMasterMaps in '..\..\Geral\ufrmMasterMaps.pas' {frmMasterMaps},
  ufrmMasterMov in '..\..\Geral\ufrmMasterMov.pas' {frmMasterMov},
  ufrmMasterPes in '..\..\Geral\ufrmMasterPes.pas' {frmMasterPes},
  ufrmMasterRel in '..\..\Geral\ufrmMasterRel.pas' {frmMasterRel},
  ufrmProtecao in '..\..\Geral\ufrmProtecao.pas' {frmProtecao},
  ufrmProtecSYS in '..\..\Geral\ufrmProtecSYS.pas' {frmProtecSYS},
  ufrmSobre in '..\..\Geral\ufrmSobre.pas' {frmSobre},
  uLib in '..\..\Geral\uLib.pas',
  uPlacaVeiculo in '..\..\Geral\uPlacaVeiculo.pas',
  uMensagens in '..\..\Geral\uMensagens.pas' {frmMensagens},
  uModulos in '..\..\Geral\uModulos.pas',
  uRecError in '..\..\Geral\uRecError.pas' {ReconcileErrorForm},
  ufrmCadHistorico in '..\..\Cadastros\ufrmCadHistorico.pas' {frmCadHistorico},
  ufrmAterarSenha in '..\..\Geral\ufrmAterarSenha.pas' {frmAterarSenha},
  ufrmCadParceiro in '..\..\Cadastros\ufrmCadParceiro.pas' {frmCadParceiro},
  ufrmCadParceiroBan in '..\..\Cadastros\ufrmCadParceiroBan.pas' {frmCadParceiroBan},
  ufrmCadParceiroFaz in '..\..\Cadastros\ufrmCadParceiroFaz.pas' {frmCadParceiroFaz},
  ufrmCadParceiroImo in '..\..\Cadastros\ufrmCadParceiroImo.pas' {frmCadParceiroImo},
  ufrmCadParceiroMov in '..\..\Cadastros\ufrmCadParceiroMov.pas' {frmCadParceiroMov},
  ufrmCadParceiroRef in '..\..\Cadastros\ufrmCadParceiroRef.pas' {frmCadParceiroRef},
  ufrmCadParceiroTel in '..\..\Cadastros\ufrmCadParceiroTel.pas' {frmCadParceiroTel},
  ufrmCadParceiroVin in '..\..\Cadastros\ufrmCadParceiroVin.pas' {frmCadParceiroVin},
  ufrmCadCFOP in '..\..\Cadastros\ufrmCadCFOP.pas' {frmCadCFOP},
  ufrmCadProdutos in '..\..\Cadastros\ufrmCadProdutos.pas' {frmCadProdutos},
  ufrmCadCulturas in '..\..\Cadastros\ufrmCadCulturas.pas' {frmCadCulturas},
  ufrmCadTipoDoc in '..\..\Cadastros\ufrmCadTipoDoc.pas' {frmCadTipoDoc},
  ufrmCadTipoOperacao in '..\..\Cadastros\ufrmCadTipoOperacao.pas' {frmCadTipoOperacao},
  ufrmCadTipoOperacaoAcao in '..\..\Cadastros\ufrmCadTipoOperacaoAcao.pas' {frmCadTipoOperacaoAcao},
  ufrmCadCFOPsOrigem in '..\..\Cadastros\ufrmCadCFOPsOrigem.pas' {frmCadCFOPsOrigem},
  ufrmCadVariedadesI in '..\..\Cadastros\ufrmCadVariedadesI.pas' {frmCadVariedadesI},
  ufrmCadGrupoSubGrupos in '..\..\Cadastros\ufrmCadGrupoSubGrupos.pas' {frmCadGrupoSubGrupos},
  ufrmCadGrupoSubGruposDet in '..\..\Cadastros\ufrmCadGrupoSubGruposDet.pas' {frmCadGrupoSubGruposDet},
  ufrmCadGrupoSubGruposTipo in '..\..\Cadastros\ufrmCadGrupoSubGruposTipo.pas' {frmCadGrupoSubGruposTipo},
  ufrmPedVendaCORG in 'ufrmPedVendaCORG.pas' {frmPedVendaCORG},
  ufrmConsPosEstoque in '..\MaxxCOM\ufrmConsPosEstoque.pas' {frmConsPosEstoque},
  ufrmAlterarSkin in '..\..\Geral\ufrmAlterarSkin.pas' {frmAlterarSkin},
  ufrmCadDetGerarRec in '..\MaxxFIN\ufrmCadDetGerarRec.pas' {frmCadDetGerarRec},
  ufrmCadTipoPgto in '..\..\Cadastros\ufrmCadTipoPgto.pas' {frmCadTipoPgto},
  ufrmCadCondPgto in '..\..\Cadastros\ufrmCadCondPgto.pas' {frmCadCondPgto},
  ufrmRelPosicaoEstoque in '..\..\Relatorios\ufrmRelPosicaoEstoque.pas' {frmRelPosicaoEstoque},
  ufrmRelKardex in '..\..\Relatorios\ufrmRelKardex.pas' {frmRelKardex},
  ufrmFerRecalculoEstoque in '..\MaxxCOM\ufrmFerRecalculoEstoque.pas' {frmFerRecalculoEstoque},
  ufrmRelParceiro in '..\..\Relatorios\ufrmRelParceiro.pas' {frmRelParceiro},
  ufrmPedCompraCORG in 'ufrmPedCompraCORG.pas' {frmPedCompraCORG},
  ufrmMovPedidoItens in 'ufrmMovPedidoItens.pas' {frmMovPedidoItens},
  ufrmMovPedidoFin in 'ufrmMovPedidoFin.pas' {frmMovPedidoFin},
  uAdicionarTituloPagar in '..\MaxxFIN\uAdicionarTituloPagar.pas',
  uAdicionarTitutoReceber in '..\MaxxFIN\uAdicionarTitutoReceber.pas',
  uAlterarTituloPagar in '..\MaxxFIN\uAlterarTituloPagar.pas',
  uAlterarTituloReceber in '..\MaxxFIN\uAlterarTituloReceber.pas',
  uGerarTitulosPagar in '..\MaxxFIN\uGerarTitulosPagar.pas',
  ufrmPagarTitulo in '..\MaxxFIN\ufrmPagarTitulo.pas' {frmPagarTitulo},
  ufrmGerarPagamentos in '..\MaxxFIN\ufrmGerarPagamentos.pas' {frmGerarPagamentos},
  ufrmRateioPlanoFinanceiro in '..\MaxxFIN\ufrmRateioPlanoFinanceiro.pas' {frmRateioPlanoFinanceiro},
  ufrmBaixaPedVendaFin in 'ufrmBaixaPedVendaFin.pas' {frmBaixaPedVendFin},
  ufrmRateioCiclo in '..\MaxxFIN\ufrmRateioCiclo.pas' {frmRateioCiclo},
  ufrmReceberTitulo in '..\MaxxFIN\ufrmReceberTitulo.pas' {frmReceberTitulo},
  uControlaEstoque in '..\..\Geral\uControlaEstoque.pas',
  uConsultarEstoque in '..\..\Geral\uConsultarEstoque.pas',
  uConsultarEstoqueFisico in '..\..\Geral\uConsultarEstoqueFisico.pas',
  ufrmCadTipoContrato in '..\..\Cadastros\ufrmCadTipoContrato.pas' {frmCadTipoContrato},
  ufrmRateioTalhao in '..\MaxxFIN\ufrmRateioTalhao.pas' {frmRateioTalhao},
  ufrmRelPedCompraCORG in 'ufrmRelPedCompraCORG.pas' {frmRelPedCompraCORG},
  ufrmBaixaPedVendaCORG in 'ufrmBaixaPedVendaCORG.pas' {frmBaixaPedVendaCorg},
  ufrmRelBXPedidosVenda in 'ufrmRelBXPedidosVenda.pas' {frmRelBXPedidosVenda},
  ufrmRelPedidosVendaCORG in 'ufrmRelPedidosVendaCORG.pas' {frmRelPedidosVendaCORG},
  ufrmAgenda in '..\..\Geral\ufrmAgenda.pas' {frmAgenda},
  ufrmRelSaldoFornecedor in 'ufrmRelSaldoFornecedor.pas' {frmRelSaldoFornecedor},
  ufrmCadParceiroFazCulturas in '..\..\Cadastros\ufrmCadParceiroFazCulturas.pas' {frmCadParceiroFazCulturas},
  ufrmCtrCompVenda in 'ufrmCtrCompVenda.pas' {frmCtrCompVen},
  ufrmCadParceiroProdutividade in '..\..\Cadastros\ufrmCadParceiroProdutividade.pas' {frmCadParceiroProdutividade},
  ufrmRelSaldoFazenda in 'ufrmRelSaldoFazenda.pas' {frmRelSaldoFazenda},
  ufrmCadProdutosForn in '..\..\Cadastros\ufrmCadProdutosForn.pas' {frmCadProdutosForn},
  ufrmCadParceiroContatos in '..\..\Cadastros\ufrmCadParceiroContatos.pas' {frmCadParceiroContatos};

{$R *.res}

begin
   try
      Application.Initialize;
      Application.MainFormOnTaskbar := True;

      PastaEXE   := UpperCase(ExtractFilePath(Application.ExeName));
      PastaREL   := StringReplace(PastaEXE, '\EXE\', '\RELATORIOS\', []);
      PastaDAT   := StringReplace(PastaEXE, '\EXE\', '\DADOS\', []);
      PastaCFG   := StringReplace(PastaEXE, '\EXE\', '\CFG\', []);
      PastaIMA   := StringReplace(PastaEXE, '\EXE\', '\IMAGENS\', []);
      ArquivoLog := StringReplace(UpperCase(gsAppPath), '\EXE\', '\CFG\MAXX.LOG', []);

      // Identificação do Módulo
      IdSistema := ExtractFileName(Application.ExeName);
      IdSistema := Copy(IdSistema, 1, (Length(Idsistema) - 4));

      Application.Title := 'Corretora de grãos';

//      CreateMutex(nil, False, PChar(IdSistema));
//
//      { verifica se houve erro na criação }
//      if (GetLastError = ERROR_ALREADY_EXISTS) then
//      begin
//         TfrmMensagens.Mensagem('O programa já está em execução!' + #13 +
//                                'Essa instância será fechada!', 'I', IdSistema, [mbOk]);
//         Halt(0);
//      end;

      // Se a diferença entre a hora atual e a hora do executável for maior que 2 minutos é solicitado o login
      programaLiberado := not (Now - FileDateToDateTime(FileAge(ParamStr(0))) >  StrToDateTime('30/12/1899 01:00:00'));


      //Se programa não estiver liberado (total, para desenvolvedor) chama o login
      if (ParamCount <> 2) and (not programaLiberado) then
      begin
         Application.CreateHandle;
         Application.ProcessMessages;
         ShellExecute(Application.Handle, 'open', 'MaxxLogin.exe', nil, Pchar(PastaEXE), SW_NORMAL);
         Application.Terminate;
         Application.Run;
      end;

      if (ParamCount >= 2) or (programaLiberado) then
      begin
         Application.CreateForm(TdmMaxxLocal, dmMaxxLocal);
         //Se usuario é ADMIN e a conexão com o servidor foi realizada
         if (dmMaxxLocal.loginUsuarioUSER_ADMIN.AsString = 'T') and (dmMaxxLocal.dbConn.Connected) then
         begin
            Application.CreateForm(TfrmPrincipal, frmPrincipal);
            Application.Run;
         end
         //Se tiver permissão de acesso ao modulo e a conexão com o servidor foi realizada
         else if (not dmMaxxLocal.cdsVerificarPermissoes.IsEmpty) and (dmMaxxLocal.dbConn.Connected) then
         begin
            Application.CreateForm(TfrmPrincipal, frmPrincipal);
            Application.Run;
         end
         // Se não tem permissão de acesso ou deu erro de conexão com o servidor encerra o módulo
         else if (dmMaxxLocal.cdsVerificarPermissoes.IsEmpty) or (not dmMaxxLocal.dbConn.Connected) then
         begin
            //Finaliza o programa
            Application.Terminate;
            Application.Run;
         end;
      end;
   except
      on e: exception do
         Application.MessageBox(pChar(e.message), 'Erro', mb_ok);
   end;
end.
