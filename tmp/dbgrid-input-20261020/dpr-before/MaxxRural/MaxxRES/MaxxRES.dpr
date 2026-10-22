program MaxxRES;

uses
  Forms,
  Windows,
  ShellApi,
  SysUtils,
  IWSystem,
  IniFiles,
  ufrmPrincipal in 'ufrmPrincipal.pas' {frmPrincipal},
  udmMaxxLocal in '..\..\Geral\udmMaxxLocal.pas' {dmMaxxLocal: TDataModule},
  ufrmMaster in '..\..\Geral\ufrmMaster.pas' {frmMaster},
  ufrmMasterCad in '..\..\Geral\ufrmMasterCad.pas' {frmMasterCad},
  ufrmMasterDet in '..\..\Geral\ufrmMasterDet.pas' {frmMasterDet},
  ufrmMasterMov in '..\..\Geral\ufrmMasterMov.pas' {frmMasterMov},
  ufrmMasterPes in '..\..\Geral\ufrmMasterPes.pas' {frmMasterPes},
  ufrmMasterRel in '..\..\Geral\ufrmMasterRel.pas' {frmMasterRel},
  uRelatorioExportadorDados in '..\..\Geral\uRelatorioExportadorDados.pas',
  ufrmSobre in '..\..\Geral\ufrmSobre.pas' {frmSobre},
  uMensagens in '..\..\Geral\uMensagens.pas' {frmMensagens},
  uRecError in '..\..\Geral\uRecError.pas' {ReconcileErrorForm},
  ufrmAterarSenha in '..\..\Geral\ufrmAterarSenha.pas' {frmAterarSenha},
  ufrmProtecSYS in '..\..\Geral\ufrmProtecSYS.pas' {frmProtecSYS},
  ufrmProtecao in '..\..\Geral\ufrmProtecao.pas' {frmProtecao},
  uModulos in '..\..\Geral\uModulos.pas',
  uLib in '..\..\Geral\uLib.pas',
  ufrmRelCustoProducao in 'ufrmRelCustoProducao.pas' {frmRelCustoProducao},
  ufrmRelProdutividade in 'ufrmRelProdutividade.pas' {frmRelProdutividade},
  ufrmRelManutMaquina in 'ufrmRelManutMaquina.pas' {frmRelManutMaquina},
  ufrmRelAnaliseInsumosGrupoProduto in 'ufrmRelAnaliseInsumosGrupoProduto.pas' {frmRelAnaliseInsumosGrupoProduto},
  ufrmRelReposicaoEstoque in 'ufrmRelReposicaoEstoque.pas' {frmRelReposicaoEstoque},
  ufrmInformacoes in '..\..\Geral\ufrmInformacoes.pas' {frmInformacoes},
  ufrmRelVariacaoIndexador in 'ufrmRelVariacaoIndexador.pas' {frmRelVariacaoIndexador},
  ufrmRelCurvaABCFornecedores in 'ufrmRelCurvaABCFornecedores.pas' {frmRelCurvaABCFornecedores},
  ufrmRelCurvaABCInsumos in 'ufrmRelCurvaABCInsumos.pas' {frmRelCurvaABCInsumos},
  ufrmRelPosicaoEstoque in '..\..\Relatorios\ufrmRelPosicaoEstoque.pas' {frmRelPosicaoEstoque},
  ufrmRelAnaliseTalhao in 'ufrmRelAnaliseTalhao.pas' {frmRelAnaliseTalhao},
  ufrmRelComercializacao in 'ufrmRelComercializacao.pas' {frmRelComercializacao},
  ufrmRelProdutividadeVariedade in 'ufrmRelProdutividadeVariedade.pas' {frmRelProdutividadeVariedade},
  ufrmMasterGraf in '..\..\Geral\ufrmMasterGraf.pas' {frmMasterGraf},
  ufrmGrafAprovArea in 'ufrmGrafAprovArea.pas' {frmGrafAprovArea},
  ufrmMasterGrafVis in '..\..\Geral\ufrmMasterGrafVis.pas' {frmMasterGrafVis},
  ufrmGrafVariacao in 'ufrmGrafVariacao.pas' {frmGrafVariacao},
  ufrmGrafProducao in 'ufrmGrafProducao.pas' {frmGrafProducao},
  ufrmGrafProducaoArmazem in 'ufrmGrafProducaoArmazem.pas' {frmGrafProducaoArmazem},
  ufrmGrafPlanFinRes in 'ufrmGrafPlanFinRes.pas' {frmGrafPlanFinRes},
  ufrmGrafPlanoFinDesp in 'ufrmGrafPlanoFinDesp.pas' {frmGrafPlanoFinDesp},
  ufrmGrafCustoVariavel in 'ufrmGrafCustoVariavel.pas' {frmGrafCustoVariavel},
  ufrmRelFluxoFinanceiro in 'ufrmRelFluxoFinanceiro.pas' {frmRelFluxoFinanceiro},
  ufrmGrafManutMaq in 'ufrmGrafManutMaq.pas' {frmGrafManutMaq},
  ufrmGrafPlanoFinRec in 'ufrmGrafPlanoFinRec.pas' {frmGrafPlanoFinRec},
  ufrmRelFluxoFinanceiroAnual in 'ufrmRelFluxoFinanceiroAnual.pas' {frmRelFluxoFinanceiroAnual},
  ufrmRelHoraMaquina in 'ufrmRelHoraMaquina.pas' {frmRelHoraMaquina},
  uConsultarHoraMaquina in '..\..\Geral\uConsultarHoraMaquina.pas',
  ufrmRelFluxoMovimento in 'ufrmRelFluxoMovimento.pas' {frmRelFluxoMovimento},
  ufrmRelMovimentoFinanc in 'ufrmRelMovimentoFinanc.pas' {frmRelMovimentoFinanc},
  ufrmRelAnaliseMaquinas in 'ufrmRelAnaliseMaquinas.pas' {frmRelAnaliseMaquinas},
  ufrmRelFluxoFinPrevMensal in '..\..\Relatorios\ufrmRelFluxoFinPrevMensal.pas' {frmRelFluxoFinPrevMensal},
  ufrmRelFluxoFinPrevAnual in '..\MaxxFIN\ufrmRelFluxoFinPrevAnual.pas' {frmRelFluxoFinPrevAnual},
  ufrmMasterConsulta in '..\..\Geral\ufrmMasterConsulta.pas' {frmMasterConsulta},
  ufrmConsPosEstoque in '..\MaxxCOM\ufrmConsPosEstoque.pas' {frmConsPosEstoque},
  ufrmAguarde in '..\..\Geral\ufrmAguarde.pas' {frmAguarde},
  ufrmRelPlanoFinPrevisto in '..\..\Relatorios\ufrmRelPlanoFinPrevisto.pas' {frmRelPlanoFinPrevisto},
  ufrmRelCheques in '..\..\Relatorios\ufrmRelCheques.pas' {frmRelCheques},
  ufrmRelResumoFinanc in '..\..\Relatorios\ufrmRelResumoFinanc.pas' {frmRelResumoFinanc},
  ufrmRelMovimento in '..\..\Relatorios\ufrmRelMovimento.pas' {frmRelMovimento},
  ufrmRelContaPagar in '..\..\Relatorios\ufrmRelContaPagar.pas' {frmRelContaPagar},
  ufrmRelContaReceber in '..\..\Relatorios\ufrmRelContaReceber.pas' {frmRelContaReceber},
  ufrmRelContasMovimento in '..\..\Relatorios\ufrmRelContasMovimento.pas' {frmRelContasMovimento},
  ufrmRelContasPagas in '..\..\Relatorios\ufrmRelContasPagas.pas' {frmRelContasPagas},
  ufrmRelContasRecebidas in '..\..\Relatorios\ufrmRelContasRecebidas.pas' {frmRelContasRecebidas},
  ufrmRelPedidos in '..\MaxxGRP\ufrmRelPedidos.pas' {frmRelPedidos},
  ufrmRelDemonstrativoGeral in '..\..\Relatorios\ufrmRelDemonstrativoGeral.pas' {frmRelDemonstrativoGeral},
  ufrmRelNotaEntrada in '..\..\Relatorios\ufrmRelNotaEntrada.pas' {frmRelNotaEntrada},
  ufrmRelNotaSaida in '..\..\Relatorios\ufrmRelNotaSaida.pas' {frmRelNotaSaida},
  ufrmRelKardex in '..\..\Relatorios\ufrmRelKardex.pas' {frmRelKardex},
  ufrmRelNotaEntradaProdutos in '..\..\Relatorios\ufrmRelNotaEntradaProdutos.pas' {frmRelNotaEntradaProdutos},
  ufrmRelPedVenda in '..\..\Relatorios\ufrmRelPedVenda.pas' {frmRelPedVenda},
  ufrmRelSaldoNFOrigem in '..\..\Relatorios\ufrmRelSaldoNFOrigem.pas' {frmRelSaldoNFOrigem},
  ufrmGerarPagamentos in '..\MaxxFIN\ufrmGerarPagamentos.pas' {frmGerarPagamentos},
  ufrmRelAbastecimentos in '..\..\Relatorios\ufrmRelAbastecimentos.pas' {frmRelAbastecimentos},
  uFrmRelBenfeitorias in '..\..\Relatorios\uFrmRelBenfeitorias.pas' {frmRelBenfeitorias},
  ufrmRelIndPluviometrico in '..\..\Relatorios\ufrmRelIndPluviometrico.pas' {frmRelIndPluviometrico},
  ufrmRelAnaliseSolo in '..\..\Relatorios\ufrmRelAnaliseSolo.pas' {frmRelAnaliseSolo},
  ufrmRelRomaneios in '..\..\Relatorios\ufrmRelRomaneios.pas' {frmRelRomaneios},
  ufrmRelApontAtividades in '..\..\Relatorios\ufrmRelApontAtividades.pas' {frmRelApontAtividades},
  ufrmRelEmprestimos in '..\..\Relatorios\ufrmRelEmprestimos.pas' {frmRelEmprestimos},
  ufrmRelHistoricoAtividade in '..\..\Relatorios\ufrmRelHistoricoAtividade.pas' {frmRelHistoricoAtividade},
  ufrmRelPontoPluviometrico in '..\..\Relatorios\ufrmRelPontoPluviometrico.pas' {frmRelPontoPluviometrico},
  ufrmRelControleManut in '..\..\Relatorios\ufrmRelControleManut.pas' {frmRelControleManut},
  ufrmRelHistManutMaq in '..\..\Relatorios\ufrmRelHistManutMaq.pas' {frmRelHistManutMaq},
  ufrmRelFretes in '..\..\Relatorios\ufrmRelFretes.pas' {frmRelFretes},
  ufrmBolMaxx in '..\..\Geral\ufrmBolMaxx.pas' {frmBolMaxx},
  ufrmCadHistorico in '..\..\Cadastros\ufrmCadHistorico.pas' {frmCadHistorico},
  ufrmCadTipoDoc in '..\..\Cadastros\ufrmCadTipoDoc.pas' {frmCadTipoDoc},
  ufrmCadTipoPgto in '..\..\Cadastros\ufrmCadTipoPgto.pas' {frmCadTipoPgto},
  ufrmRelAnaliseInsumos in 'ufrmRelAnaliseInsumos.pas' {frmRelAnaliseInsumos},
  ufrmCadParceiro in '..\..\Cadastros\ufrmCadParceiro.pas' {frmCadParceiro},
  ufrmCadParceiroBan in '..\..\Cadastros\ufrmCadParceiroBan.pas' {frmCadParceiroBan},
  ufrmCadParceiroFaz in '..\..\Cadastros\ufrmCadParceiroFaz.pas' {frmCadParceiroFaz},
  ufrmCadParceiroFazCulturas in '..\..\Cadastros\ufrmCadParceiroFazCulturas.pas' {frmCadParceiroFazCulturas},
  ufrmCadParceiroImo in '..\..\Cadastros\ufrmCadParceiroImo.pas' {frmCadParceiroImo},
  ufrmCadParceiroMov in '..\..\Cadastros\ufrmCadParceiroMov.pas' {frmCadParceiroMov},
  ufrmCadParceiroProdutividade in '..\..\Cadastros\ufrmCadParceiroProdutividade.pas' {frmCadParceiroProdutividade},
  ufrmCadParceiroRef in '..\..\Cadastros\ufrmCadParceiroRef.pas' {frmCadParceiroRef},
  ufrmCadParceiroTel in '..\..\Cadastros\ufrmCadParceiroTel.pas' {frmCadParceiroTel},
  ufrmCadParceiroVin in '..\..\Cadastros\ufrmCadParceiroVin.pas' {frmCadParceiroVin},
  ufrmRelEstoqueAcerto in '..\..\Relatorios\ufrmRelEstoqueAcerto.pas' {frmRelEstoqueAcerto},
  ufrmGrafIndicePluv in 'ufrmGrafIndicePluv.pas' {frmGrafIndicePluv},
  ufrmGrafVisIndicePluv in 'ufrmGrafVisIndicePluv.pas' {frmGrafVisIndicePluv},
  ufrmRelRomaneiosARM in '..\..\Relatorios\ufrmRelRomaneiosARM.pas' {frmRelRomaneiosARM},
  ufrmCadParceiroContatos in '..\..\Cadastros\ufrmCadParceiroContatos.pas' {frmCadParceiroContatos},
  ufrmRelContratoPagar in '..\..\Relatorios\ufrmRelContratoPagar.pas' {frmRelContratoPagar},
  ufrmRelContratoReceber in '..\..\Relatorios\ufrmRelContratoReceber.pas' {frmRelContratoReceber},
  ufrmRelTransfEstoque in '..\..\Relatorios\ufrmRelTransfEstoque.pas' {frmRelTransfEstoque},
  ufrmConConfeFiscal in '..\MaxxCFiscal\ufrmConConfeFiscal.pas' {frmConConfeFiscal},
  ufrmConConfeFiscalImp in '..\MaxxCFiscal\ufrmConConfeFiscalImp.pas' {frmConConfeFiscalImp},
  ufrmRelMovimentoTransf in '..\MaxxFIN\ufrmRelMovimentoTransf.pas' {frmRelMovimentoTransf},
  ufrmRelOutrasAtividades in '..\..\Relatorios\ufrmRelOutrasAtividades.pas' {frmRelOutrasAtividades},
  ufrmRelManutencaoBenf in '..\MaxxGCI\ufrmRelManutencaoBenf.pas' {frmRelManutencaoBenf},
  ufrmRelLocacaoTalhao in '..\..\Relatorios\ufrmRelLocacaoTalhao.pas' {frmRelLocacaoTalhao},
  ufrmRelIndPluvAno in '..\..\Relatorios\ufrmRelIndPluvAno.pas' {frmRelIndPluvAno},
  ufrmRelEstoqueArmazemProduto in '..\MaxxGCI\ufrmRelEstoqueArmazemProduto.pas' {frmRelEstoqueArmazemProduto},
  ufrmRelEmprestimoEPI in '..\MaxxGCI\ufrmRelEmprestimoEPI.pas' {frmRelEmprestimoEPI},
  ufrmRelAtividades in '..\..\Relatorios\ufrmRelAtividades.pas' {frmRelAtividades},
  ufrmRelCiclos in '..\..\Relatorios\ufrmRelCiclos.pas' {frmRelCiclos},
  ufrmRelCulturas in '..\..\Relatorios\ufrmRelCulturas.pas' {frmRelCulturas},
  ufrmRelItemAnaliseSolo in '..\..\Relatorios\ufrmRelItemAnaliseSolo.pas' {frmRelItemAnaliseSolo},
  uFrmRelTalhoes in '..\..\Relatorios\uFrmRelTalhoes.pas' {frmRelTalhoes},
  ufrmRelEstoqueArmazemARM in '..\..\Relatorios\ufrmRelEstoqueArmazemARM.pas' {frmRelEstoqueArmazemARM},
  ufrmRelEstoqueArmazem in '..\..\Relatorios\ufrmRelEstoqueArmazem.pas' {frmRelEstoqueArmazem},
  UFSistConsultaCNPJ in '..\..\Geral\UFSistConsultaCNPJ.pas',
  uConsultaCNPJAcBR in '..\..\Geral\uConsultaCNPJAcBR.pas' {frmConsultaCNPJAcBR},
  ufrmMasterGrafVisao in '..\..\Geral\ufrmMasterGrafVisao.pas' {frmMasterGrafVisao},
  ufrmGrafVisaoManutMaq in 'ufrmGrafVisaoManutMaq.pas' {frmGrafVisaoManutMaq},
  ufrmGrafVisaoAprovArea in 'ufrmGrafVisaoAprovArea.pas' {frmGrafVisaoAprovArea},
  ufrmGrafVisaoCustoVariavel in 'ufrmGrafVisaoCustoVariavel.pas' {frmGrafVisaoCustoVariavel},
  ufrmGrafVisaoPlanoFinDesp in 'ufrmGrafVisaoPlanoFinDesp.pas' {frmGrafVisaoPlanoFinDesp},
  ufrmGrafVisaoPlanoFinRec in 'ufrmGrafVisaoPlanoFinRec.pas' {frmGrafVisaoPlanoFinRec},
  ufrmGrafVisaoProducaoArmazem in 'ufrmGrafVisaoProducaoArmazem.pas' {frmGrafVisaoProducaoArmazem},
  ufrmGrafVisaoProducao in 'ufrmGrafVisaoProducao.pas' {frmGrafVisaoProducao},
  ufrmGrafVisaoPlanFinRes in 'ufrmGrafVisaoPlanFinRes.pas' {frmGrafVisaoPlanFinRes},
  ufrmGrafVisaoVariacao in 'ufrmGrafVisaoVariacao.pas' {frmGrafVisaoVariacao},
  ufrmCadProdutos in '..\..\Cadastros\ufrmCadProdutos.pas' {frmCadProdutos},
  ufrmCadProdutosForn in '..\..\Cadastros\ufrmCadProdutosForn.pas' {frmCadProdutosForn},
  ufrmRelRomaneiosTerceiros in '..\..\Relatorios\ufrmRelRomaneiosTerceiros.pas' {frmRelRomaneiosTerceiros},
  ufrmCadProdutosLotes in '..\..\Cadastros\ufrmCadProdutosLotes.pas' {frmCadProdutosLotes},
  ufrmCadProdutosLotesAnexos in '..\..\Cadastros\ufrmCadProdutosLotesAnexos.pas' {frmCadProdutosLotesAnexos},
  ufrmCadProdutosLotesSaldo in '..\..\Cadastros\ufrmCadProdutosLotesSaldo.pas' {frmCadProdutosLotesSaldo},
  ufrmConsSaldoLotes in '..\MaxxCOM\ufrmConsSaldoLotes.pas' {frmConsSaldoLotes},
  ufrmRelKardexLotes in '..\..\Relatorios\ufrmRelKardexLotes.pas' {frmRelKardexLotes},
  ufrmRelPlanoFinRealizado in '..\..\Relatorios\ufrmRelPlanoFinRealizado.pas' {frmRelPlanoFinRealizado},
  ufrmGrafContaPagar in 'ufrmGrafContaPagar.pas' {frmGrafContaPagar},
  ufrmGrafVisaoContaPagar in 'ufrmGrafVisaoContaPagar.pas' {frmGrafVisaoContaPagar},
  ufrmRelDespesaAdministrativa in '..\..\Relatorios\ufrmRelDespesaAdministrativa.pas' {frmRelDespesaAdministrativa},
  uPesquisarRel in 'uPesquisarRel.pas',
  Vcl.Themes,
  Vcl.Styles,
  uConstantes in '..\..\Geral\uConstantes.pas',
  ufrmConConfeFiscalRegCaixa in '..\MaxxCFiscal\ufrmConConfeFiscalRegCaixa.pas' {frmConConfeFiscalRegCaixa},
  ufrmConConfeFiscalRegCaixaImp in '..\MaxxCFiscal\ufrmConConfeFiscalRegCaixaImp.pas' {frmConConfeFiscalRegCaixaImp},
  ufrmRelPlanoFinPrevistoxRealizado in '..\..\Relatorios\ufrmRelPlanoFinPrevistoxRealizado.pas' {frmRelPlanoFinPrevistoxRealizado},
  ufrmRelDescRomaneios in '..\..\Relatorios\ufrmRelDescRomaneios.pas' {frmRelDescRomaneios},
  ufrmRelTicket in '..\..\Relatorios\ufrmRelTicket.pas' {frmRelTicket},
  ufrmRelNotaSaidaProduto in '..\..\Relatorios\ufrmRelNotaSaidaProduto.pas' {frmRelNotaSaidaProduto},
  ufrmConConfeFiscalRegCaixaMensal in '..\MaxxCFiscal\ufrmConConfeFiscalRegCaixaMensal.pas' {frmConConfeFiscalRegCaixaMensal},
  uConsultarEstoqueFisico in '..\..\Geral\uConsultarEstoqueFisico.pas',
  ufrmCadParceiroFazMatricula in '..\..\Cadastros\ufrmCadParceiroFazMatricula.pas' {frmCadParceiroFazMatricula},
  ufrmCadParceiroFazMatriculaHipoteca in '..\..\Cadastros\ufrmCadParceiroFazMatriculaHipoteca.pas' {frmCadParceiroFazMatriculaHipoteca},
  ufrmCadParceiroFazVinculos in '..\..\Cadastros\ufrmCadParceiroFazVinculos.pas' {frmCadParceiroFazVinculos},
  uConsultaCNPJ in '..\..\Geral\uConsultaCNPJ.pas' {frmConsultaCNPJ},
  ufrmRelSiloEstoque in '..\..\Relatorios\ufrmRelSiloEstoque.pas' {frmRelSiloEstoque},
  ufrmVinculoPlanoContas in '..\..\Geral\ufrmVinculoPlanoContas.pas' {frmVinculoPlanoContas},
  uConversoes in '..\..\Geral\uConversoes.pas',
  uLayoutFormulario in '..\..\Geral\uLayoutFormulario.pas',
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

      Application.Title := 'Resultados';
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
         //Se usuario é ADMIN e a conexão com o servidor foi realizada
         if (dmMaxxLocal.loginUsuarioUSER_ADMIN.AsString = 'T') and (dmMaxxLocal.dbConn.Connected)
            and (not dmMaxxLocal.cdsVerificarPermissoes.IsEmpty) then
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
