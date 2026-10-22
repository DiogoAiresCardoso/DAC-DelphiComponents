program MaxxFIN;

uses
  Forms,
  Windows,
  ShellApi,
  SysUtils,
  IwSystem,
  IniFiles,
  Data.db,
  ufrmPrincipal in 'ufrmPrincipal.pas' {frmPrincipal},
  ufrmAterarSenha in '..\..\Geral\ufrmAterarSenha.pas' {frmAterarSenha},
  ufrmMaster in '..\..\Geral\ufrmMaster.pas' {frmMaster},
  ufrmMasterCad in '..\..\Geral\ufrmMasterCad.pas' {frmMasterCad},
  ufrmMasterDet in '..\..\Geral\ufrmMasterDet.pas' {frmMasterDet},
  ufrmMasterMov in '..\..\Geral\ufrmMasterMov.pas' {frmMasterMov},
  ufrmMasterPes in '..\..\Geral\ufrmMasterPes.pas' {frmMasterPes},
  ufrmMasterRel in '..\..\Geral\ufrmMasterRel.pas' {frmMasterRel},
  uRelatorioExportadorDados in '..\..\Geral\uRelatorioExportadorDados.pas',
  ufrmProtecSYS in '..\..\Geral\ufrmProtecSYS.pas' {frmProtecSYS},
  ufrmSobre in '..\..\Geral\ufrmSobre.pas' {frmSobre},
  uLib in '..\..\Geral\uLib.pas',
  uMensagens in '..\..\Geral\uMensagens.pas' {frmMensagens},
  uRecError in '..\..\Geral\uRecError.pas' {ReconcileErrorForm},
  udmMaxxLocal in '..\..\Geral\udmMaxxLocal.pas' {dmMaxxLocal: TDataModule},
  ufrmRelParceiro in '..\..\Relatorios\ufrmRelParceiro.pas' {frmRelParceiro},
  ufrmRelCondPagamento in '..\..\Relatorios\ufrmRelCondPagamento.pas' {frmRelCondPagamento},
  ufrmMovMovimBanc in 'ufrmMovMovimBanc.pas' {frmMovMovimBanc},
  uMovimentacaoBancariaApi in 'uMovimentacaoBancariaApi.pas',
  uMovimentacaoBancariaDataSet in 'uMovimentacaoBancariaDataSet.pas',
  ufrmMovMovimBancLanc in 'ufrmMovMovimBancLanc.pas' {frmMovMovimBancLanc},
  ufrmMovMovimReceber in 'ufrmMovMovimReceber.pas' {frmMovMovimReceber},
  ufrmMovMovimPagar in 'ufrmMovMovimPagar.pas' {frmMovMovimPagar},
  uFuncServ in '..\..\Geral\uFuncServ.pas',
  ufrmCadDetGerarRec in 'ufrmCadDetGerarRec.pas' {frmCadDetGerarRec},
  ufrmProtecao in '..\..\Geral\ufrmProtecao.pas' {frmProtecao},
  ufrmRelReceberConsolidado in '..\..\Relatorios\ufrmRelReceberConsolidado.pas' {frmRelReceberConsolidado},
  ufrmRelPagarConsolidado in '..\..\Relatorios\ufrmRelPagarConsolidado.pas' {frmRelPagarConsolidado},
  ufrmRelFluxoCCusto in '..\..\Relatorios\ufrmRelFluxoCCusto.pas' {frmRelFluxoCCusto},
  uModulos in '..\..\Geral\uModulos.pas',
  ufrmMovAtividadeInfo in '..\MaxxGCI\ufrmMovAtividadeInfo.pas' {frmMovAtividadeInfo},
  ufrmPagarTitulo in 'ufrmPagarTitulo.pas' {frmPagarTitulo},
  uAlterarTituloPagar in 'uAlterarTituloPagar.pas',
  uAdicionarTituloPagar in 'uAdicionarTituloPagar.pas',
  ufrmGerarPagamentos in 'ufrmGerarPagamentos.pas' {frmGerarPagamentos},
  uControlaEstoque in '..\..\Geral\uControlaEstoque.pas',
  uGerarTitulosPagar in 'uGerarTitulosPagar.pas',
  uAdicionarTitutoReceber in 'uAdicionarTitutoReceber.pas',
  ufrmReceberTitulo in 'ufrmReceberTitulo.pas' {frmReceberTitulo},
  uAlterarTituloReceber in 'uAlterarTituloReceber.pas',
  ufrmRateioPlanoFinanceiro in 'ufrmRateioPlanoFinanceiro.pas' {frmRateioPlanoFinanceiro},
  ufrmRateioCiclo in 'ufrmRateioCiclo.pas' {frmRateioCiclo},
  ufrmRateioTalhao in 'ufrmRateioTalhao.pas' {frmRateioTalhao},
  ufrmRelPlanoFinPrevisto in '..\..\Relatorios\ufrmRelPlanoFinPrevisto.pas' {frmRelPlanoFinPrevisto},
  ufrmMovContrato in '..\MaxxCOM\ufrmMovContrato.pas' {frmMovContrato},
  ufrmRelPlanoFinRealizado in '..\..\Relatorios\ufrmRelPlanoFinRealizado.pas' {frmRelPlanoFinRealizado},
  ufrmRelContratoPagar in '..\..\Relatorios\ufrmRelContratoPagar.pas' {frmRelContratoPagar},
  uConsultarHoraMaquina in '..\..\Geral\uConsultarHoraMaquina.pas',
  ufrmMovPagarVinculos in 'ufrmMovPagarVinculos.pas' {frmMovPagarVinculos},
  ufrmMovDetCheques in 'ufrmMovDetCheques.pas' {frmMovDetCheques},
  ufrmRelCheques in '..\..\Relatorios\ufrmRelCheques.pas' {frmRelCheques},
  ufrmInformacoes in '..\..\Geral\ufrmInformacoes.pas' {frmInformacoes},
  ufrmRelContasMovimento in '..\..\Relatorios\ufrmRelContasMovimento.pas' {frmRelContasMovimento},
  ufrmRelMovimentoFinanc in '..\MaxxRES\ufrmRelMovimentoFinanc.pas' {frmRelMovimentoFinanc},
  ufrmRelFluxoFinanceiro in '..\MaxxRES\ufrmRelFluxoFinanceiro.pas' {frmRelFluxoFinanceiro},
  ufrmRelFluxoFinanceiroAnual in '..\MaxxRES\ufrmRelFluxoFinanceiroAnual.pas' {frmRelFluxoFinanceiroAnual},
  ufrmRelFluxoMovimento in '..\MaxxRES\ufrmRelFluxoMovimento.pas' {frmRelFluxoMovimento},
  ufrmRelFluxoFinPrevMensal in '..\..\Relatorios\ufrmRelFluxoFinPrevMensal.pas' {frmRelFluxoFinPrevMensal},
  ufrmRelFluxoFinPrevAnual in 'ufrmRelFluxoFinPrevAnual.pas' {frmRelFluxoFinPrevAnual},
  ufrmCadDetCheques in 'ufrmCadDetCheques.pas' {frmCadDetCheques},
  ufrmCadDetChequesCancelar in 'ufrmCadDetChequesCancelar.pas' {frmCadDetChequesCancelar},
  ufrmMasterConsulta in '..\..\Geral\ufrmMasterConsulta.pas' {frmMasterConsulta},
  ufrmAguarde in '..\..\Geral\ufrmAguarde.pas' {frmAguarde},
  ufrmRelResumoFinanc in '..\..\Relatorios\ufrmRelResumoFinanc.pas' {frmRelResumoFinanc},
  Vcl.Themes,
  Vcl.Styles,
  ufrmRelMovimento in '..\..\Relatorios\ufrmRelMovimento.pas' {frmRelMovimento},
  ufrmRelContaReceber in '..\..\Relatorios\ufrmRelContaReceber.pas' {frmRelContaReceber},
  ufrmRelContasRecebidas in '..\..\Relatorios\ufrmRelContasRecebidas.pas' {frmRelContasRecebidas},
  ufrmRelContaPagar in '..\..\Relatorios\ufrmRelContaPagar.pas' {frmRelContaPagar},
  ufrmRelContasPagas in '..\..\Relatorios\ufrmRelContasPagas.pas' {frmRelContasPagas},
  ufrmCadBanco in '..\..\Cadastros\ufrmCadBanco.pas' {frmCadBanco},
  ufrmCadCartorio in '..\..\Cadastros\ufrmCadCartorio.pas' {frmCadCartorio},
  ufrmCadCategoria in '..\..\Cadastros\ufrmCadCategoria.pas' {frmCadCategoria},
  ufrmCadCCusto in '..\..\Cadastros\ufrmCadCCusto.pas' {frmCadCCusto},
  ufrmCadCondPgto in '..\..\Cadastros\ufrmCadCondPgto.pas' {frmCadCondPgto},
  ufrmCadConta in '..\..\Cadastros\ufrmCadConta.pas' {frmCadConta},
  ufrmCadDespesaRecepcao in '..\..\Cadastros\ufrmCadDespesaRecepcao.pas' {frmCadDespesaRecepcao},
  ufrmCadDetCustoLan in '..\..\Cadastros\ufrmCadDetCustoLan.pas' {frmCadDetCustoLan},
  ufrmCadDocFinanceiro in '..\..\Cadastros\ufrmCadDocFinanceiro.pas' {frmCadDocFinanceiro},
  ufrmCadEmpresa in '..\..\Cadastros\ufrmCadEmpresa.pas' {frmCadEmpresa},
  ufrmCadHistorico in '..\..\Cadastros\ufrmCadHistorico.pas' {frmCadHistorico},
  ufrmCadMoeda in '..\..\Cadastros\ufrmCadMoeda.pas' {frmCadMoeda},
  ufrmCadMoedaCotacao in '..\..\Cadastros\ufrmCadMoedaCotacao.pas' {frmCadMoedaCotacao},
  ufrmCadMovimento_fechado in '..\..\Cadastros\ufrmCadMovimento_fechado.pas' {frmCadMovimento_fechado},
  ufrmCadMunicipio in '..\..\Cadastros\ufrmCadMunicipio.pas' {frmCadMunicipio},
  ufrmCadParceiro in '..\..\Cadastros\ufrmCadParceiro.pas' {frmCadParceiro},
  ufrmCadParceiroBan in '..\..\Cadastros\ufrmCadParceiroBan.pas' {frmCadParceiroBan},
  ufrmCadParceiroFaz in '..\..\Cadastros\ufrmCadParceiroFaz.pas' {frmCadParceiroFaz},
  ufrmCadParceiroImo in '..\..\Cadastros\ufrmCadParceiroImo.pas' {frmCadParceiroImo},
  ufrmCadParceiroMov in '..\..\Cadastros\ufrmCadParceiroMov.pas' {frmCadParceiroMov},
  ufrmCadParceiroRef in '..\..\Cadastros\ufrmCadParceiroRef.pas' {frmCadParceiroRef},
  ufrmCadParceiroTel in '..\..\Cadastros\ufrmCadParceiroTel.pas' {frmCadParceiroTel},
  ufrmCadParceiroVin in '..\..\Cadastros\ufrmCadParceiroVin.pas' {frmCadParceiroVin},
  ufrmCadPrincipioAtivo in '..\..\Cadastros\ufrmCadPrincipioAtivo.pas' {frmCadPrincipioAtivo},
  ufrmCadRecibo in '..\..\Cadastros\ufrmCadRecibo.pas' {frmCadRecibo},
  ufrmCadTipoContrato in '..\..\Cadastros\ufrmCadTipoContrato.pas' {frmCadTipoContrato},
  ufrmCadTipoDoc in '..\..\Cadastros\ufrmCadTipoDoc.pas' {frmCadTipoDoc},
  ufrmCadTipoPgto in '..\..\Cadastros\ufrmCadTipoPgto.pas' {frmCadTipoPgto},
  ufrmCadUnidade in '..\..\Cadastros\ufrmCadUnidade.pas' {frmCadUnidade},
  ufrmCadUsuario in '..\..\Cadastros\ufrmCadUsuario.pas' {frmCadUsuario},
  ufrmBolMaxx in '..\..\Geral\ufrmBolMaxx.pas' {frmBolMaxx},
  ufrmMovMovimTransConta in 'ufrmMovMovimTransConta.pas' {frmMovMovimTransConta},
  ufrmMovMovimBancVis in 'ufrmMovMovimBancVis.pas' {frmMovMovimBancVis},
  ufrmMovMovimTransContaVIS in 'ufrmMovMovimTransContaVIS.pas' {frmMovMovimTransContaVIS},
  ufrmControlaTrocaVis in '..\MaxxGCI\ufrmControlaTrocaVis.pas' {frmControlaTrocaVis},
  ufrmCadParceiroFazCulturas in '..\..\Cadastros\ufrmCadParceiroFazCulturas.pas' {frmCadParceiroFazCulturas},
  ufrmCadParceiroProdutividade in '..\..\Cadastros\ufrmCadParceiroProdutividade.pas' {frmCadParceiroProdutividade},
  ufrmRelMovimentoTransf in 'ufrmRelMovimentoTransf.pas' {frmRelMovimentoTransf},
  ufrmCadParceiroContatos in '..\..\Cadastros\ufrmCadParceiroContatos.pas' {frmCadParceiroContatos},
  ufrmMovMovimBancLancCredPagar in 'ufrmMovMovimBancLancCredPagar.pas' {frmMovMovimBancLancCredPagar},
  ufrmCadImpressaoCheque in '..\..\Cadastros\ufrmCadImpressaoCheque.pas' {frmCadImpressaoCheque},
  uImpCheque in '..\..\Geral\uImpCheque.pas',
  ufrmFerRecalculoFinanceiro in 'ufrmFerRecalculoFinanceiro.pas' {frmFerRecalculoFinanceiro},
  ufrmMovMovimBancConc in 'ufrmMovMovimBancConc.pas' {frmMovMovimBancConc},
  UFSistConsultaCNPJ in '..\..\Geral\UFSistConsultaCNPJ.pas',
  uConsultaCNPJAcBR in '..\..\Geral\uConsultaCNPJAcBR.pas' {frmConsultaCNPJAcBR},
  ufrmCadProdutos in '..\..\Cadastros\ufrmCadProdutos.pas' {frmCadProdutos},
  ufrmCadProdutosForn in '..\..\Cadastros\ufrmCadProdutosForn.pas' {frmCadProdutosForn},
  ufrmCadProdutosLotes in '..\..\Cadastros\ufrmCadProdutosLotes.pas' {frmCadProdutosLotes},
  ufrmCadProdutosLotesAnexos in '..\..\Cadastros\ufrmCadProdutosLotesAnexos.pas' {frmCadProdutosLotesAnexos},
  ufrmCadProdutosLotesSaldo in '..\..\Cadastros\ufrmCadProdutosLotesSaldo.pas' {frmCadProdutosLotesSaldo},
  ufrmMovMovimBancLancCredReceber in 'ufrmMovMovimBancLancCredReceber.pas' {frmMovMovimBancLancCredReceber},
  ufrmGrafContaPagar in '..\MaxxRES\ufrmGrafContaPagar.pas' {frmGrafContaPagar},
  ufrmGrafVisaoContaPagar in '..\MaxxRES\ufrmGrafVisaoContaPagar.pas' {frmGrafVisaoContaPagar},
  ufrmMasterGraf in '..\..\Geral\ufrmMasterGraf.pas' {frmMasterGraf},
  ufrmMasterGrafVis in '..\..\Geral\ufrmMasterGrafVis.pas' {frmMasterGrafVis},
  ufrmMasterGrafVisao in '..\..\Geral\ufrmMasterGrafVisao.pas' {frmMasterGrafVisao},
  ufrmRelContratoReceber in '..\..\Relatorios\ufrmRelContratoReceber.pas' {frmRelContratoReceber},
  ufrmMovContratoReceber in '..\MaxxCOM\ufrmMovContratoReceber.pas' {frmMovContratoReceber},
  ufrmMovContratoRecEntregas in '..\MaxxCOM\ufrmMovContratoRecEntregas.pas' {frmMovContratoRecEntregas},
  uConsultarEstoque in '..\..\Geral\uConsultarEstoque.pas',
  uConsultarEstoqueFisico in '..\..\Geral\uConsultarEstoqueFisico.pas',
  uPesquisarRel in '..\MaxxRES\uPesquisarRel.pas',
  uConstantes in '..\..\Geral\uConstantes.pas',
  ufrmAgenda in '..\..\Geral\ufrmAgenda.pas' {frmAgenda},
  ufrmMovMovimMultiPagar in 'ufrmMovMovimMultiPagar.pas' {frmMovMovimMultiPagar},
  ufrmMovMovimMultiReceber in 'ufrmMovMovimMultiReceber.pas' {frmMovMovimMultiReceber},
  ufrmMovPagar in 'ufrmMovPagar.pas' {frmMovPagar},
  ufrmMovReceber in 'ufrmMovReceber.pas' {frmMovReceber},
  ufrmRelPlanoFinPrevistoxRealizado in '..\..\Relatorios\ufrmRelPlanoFinPrevistoxRealizado.pas' {frmRelPlanoFinPrevistoxRealizado},
  ufrmCadParceiroFazMatricula in '..\..\Cadastros\ufrmCadParceiroFazMatricula.pas' {frmCadParceiroFazMatricula},
  ufrmCadParceiroFazMatriculaHipoteca in '..\..\Cadastros\ufrmCadParceiroFazMatriculaHipoteca.pas' {frmCadParceiroFazMatriculaHipoteca},
  ufrmCadParceiroFazVinculos in '..\..\Cadastros\ufrmCadParceiroFazVinculos.pas' {frmCadParceiroFazVinculos},
  uConsultaCNPJ in '..\..\Geral\uConsultaCNPJ.pas' {frmConsultaCNPJ},
  ufrmMovMovimBancLancPlanFinan in 'ufrmMovMovimBancLancPlanFinan.pas' {frmMovMovimBancLancPlanFinan},
  ufrmMovImportarFolha in 'ufrmMovImportarFolha.pas' {frmMovImportarFolha},
  ufrmMovImportarFolhaRateioPlanoFin in 'ufrmMovImportarFolhaRateioPlanoFin.pas' {frmMovImportarFolhaRateioPlanoFin},
  ufrmMovImportarFolhaRateioCiclo in 'ufrmMovImportarFolhaRateioCiclo.pas' {frmMovImportarFolhaRateioCiclo},
  ufrmVinculoPlanoContas in '..\..\Geral\ufrmVinculoPlanoContas.pas' {frmVinculoPlanoContas},
  uConversoes in '..\..\Geral\uConversoes.pas',
  ufrmGerarFinanceiro in '..\..\Geral\ufrmGerarFinanceiro.pas' {frmGerarFinanceiro},
  ufrmGerarFinanceiroTitulos in '..\..\Geral\ufrmGerarFinanceiroTitulos.pas' {frmGerarFinanceiroTitulos},
  ufrmGerarFinanceiroRateios in '..\..\Geral\ufrmGerarFinanceiroRateios.pas' {frmGerarFinanceiroRateios},
  uLayoutFormulario in '..\..\Geral\uLayoutFormulario.pas',
  ufrmCadPlanoContas in '..\..\Cadastros\ufrmCadPlanoContas.pas' {frmCadPlanoContas},
  ufrmCadPlanoContasItens in '..\..\Cadastros\ufrmCadPlanoContasItens.pas' {frmCadPlanoContasItens},
  ufrmExportarContabilidade in '..\..\Geral\ufrmExportarContabilidade.pas' {frmExportarContabilidade},
  uLayoutContabilidade in '..\..\Geral\uLayoutContabilidade.pas',
  ufrmUsoCPUMEM in '..\..\Geral\ufrmUsoCPUMEM.pas' {frmUsoCPUMEM};

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

      Application.Title := 'Financeiro';
//      CreateMutex(nil, False, PChar(IdSistema));
//
//      { verifica se houve erro na criação }
//      if (GetLastError = ERROR_ALREADY_EXISTS) then
//      begin
//         TfrmMensagens.Mensagem('O programa já está em execução!' + #13 +
//                                'Essa instância será fechada!', 'I', IdSistema, [mbOk]);
//         Halt(0);
//      end;

      FileAge(Application.ExeName, fileDateTime);
      programaLiberado := not (Now - fileDateTime >  StrToDateTime('30/12/1899 01:00:00'));

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

//         while not Terminou do  sleep(1000);
         //Se usuario é ADMIN e a conexão com o servidor foi realizada
         if (dmMaxxLocal.loginUsuarioUSER_ADMIN.AsString = 'T') and (dmMaxxLocal.dbConn.Connected)
               and (not dmMaxxLocal.cdsVerificarPermissoes.IsEmpty) then
         begin
            Application.CreateForm(TfrmPrincipal, frmPrincipal);
            Application.Run;
            LimpaMemoriaAPP;
         end
         //Se tiver permissão de acesso ao modulo e a conexão com o servidor foi realizada
         else if (not dmMaxxLocal.cdsVerificarPermissoes.IsEmpty) and (dmMaxxLocal.dbConn.Connected) then
         begin
            Application.CreateForm(TfrmPrincipal, frmPrincipal);
            Application.Run;
            LimpaMemoriaAPP;
         end
         // Se não tem permissão de acesso ou deu erro de conexão com o servidor encerra o módulo
         else if (dmMaxxLocal.cdsVerificarPermissoes.IsEmpty) or (not dmMaxxLocal.dbConn.Connected) then
         begin
            //Finaliza o programa
            Application.Terminate;
            Application.Run;
            LimpaMemoriaAPP;
         end;
      end;
   except
      on e: exception do
         Application.MessageBox(pChar(e.message), 'Erro', mb_ok);
   end;
end.
