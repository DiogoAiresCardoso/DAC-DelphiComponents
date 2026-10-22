program MaxxARM;

uses
  Forms,
  Windows,
  ShellApi,
  SysUtils,
  IwSystem,
  IniFiles,
  ufrmPrincipal in 'ufrmPrincipal.pas' {frmPrincipal},
  uConsultarEstoque in '..\..\Geral\uConsultarEstoque.pas',
  uConsultarEstoqueFisico in '..\..\Geral\uConsultarEstoqueFisico.pas',
  uControlaEstoque in '..\..\Geral\uControlaEstoque.pas',
  udmMaxxLocal in '..\..\Geral\udmMaxxLocal.pas' {dmMaxxLocal: TDataModule},
  ufrmAterarSenha in '..\..\Geral\ufrmAterarSenha.pas' {frmAterarSenha},
  ufrmFerLog in '..\..\Geral\ufrmFerLog.pas' {frmFerLog},
  ufrmInformacoes in '..\..\Geral\ufrmInformacoes.pas' {frmInformacoes},
  ufrmMaster in '..\..\Geral\ufrmMaster.pas' {frmMaster},
  ufrmMasterCad in '..\..\Geral\ufrmMasterCad.pas' {frmMasterCad},
  ufrmMasterDet in '..\..\Geral\ufrmMasterDet.pas' {frmMasterDet},
  ufrmMasterGraf in '..\..\Geral\ufrmMasterGraf.pas' {frmMasterGraf},
  ufrmMasterGrafVis in '..\..\Geral\ufrmMasterGrafVis.pas' {frmMasterGrafVis},
  ufrmMasterMov in '..\..\Geral\ufrmMasterMov.pas' {frmMasterMov},
  ufrmMasterPes in '..\..\Geral\ufrmMasterPes.pas' {frmMasterPes},
  ufrmMasterRel in '..\..\Geral\ufrmMasterRel.pas' {frmMasterRel},
  ufrmProtecao in '..\..\Geral\ufrmProtecao.pas' {frmProtecao},
  ufrmProtecSYS in '..\..\Geral\ufrmProtecSYS.pas' {frmProtecSYS},
  ufrmSobre in '..\..\Geral\ufrmSobre.pas' {frmSobre},
  uFuncServ in '..\..\Geral\uFuncServ.pas',
  uLib in '..\..\Geral\uLib.pas',
  uPlacaVeiculo in '..\..\Geral\uPlacaVeiculo.pas',
  uMensagens in '..\..\Geral\uMensagens.pas' {frmMensagens},
  uModulos in '..\..\Geral\uModulos.pas',
  uRecError in '..\..\Geral\uRecError.pas' {ReconcileErrorForm},
  uLog in '..\MaxxService\uLog.pas',
  ufrmConsPosEstoque in '..\MaxxCOM\ufrmConsPosEstoque.pas' {frmConsPosEstoque},
  ufrmMasterConsulta in '..\..\Geral\ufrmMasterConsulta.pas' {frmMasterConsulta},
  ufrmAguarde in '..\..\Geral\ufrmAguarde.pas' {frmAguarde},
  ufrmBalanca in 'ufrmBalanca.pas' {frmBalanca},
  ufrmControlePesagem in 'ufrmControlePesagem.pas' {frmControlePesagem},
  ufrmImportarRomaneio in 'ufrmImportarRomaneio.pas' {frmImportarRomaneio},
  ufrmMovNromaneio in 'ufrmMovNromaneio.pas' {frmMovNromaneio},
  ufrmMovPesagemFinal in 'ufrmMovPesagemFinal.pas' {frmMovPesagemFinal},
  ufrmMovPesagemInicial in 'ufrmMovPesagemInicial.pas' {frmMovPesagemInicial},
  ufrmCadTabDesc in '..\..\Cadastros\ufrmCadTabDesc.pas' {frmCadTabDesc},
  ufrmCadTabDescItens in '..\..\Cadastros\ufrmCadTabDescItens.pas' {frmCadTabDescItens},
  ufrmCadDescClass in '..\..\Cadastros\ufrmCadDescClass.pas' {frmCadDescClass},
  ufrmRelTicket in '..\..\Relatorios\ufrmRelTicket.pas' {frmRelTicket},
  ufrmRelDescRomaneios in '..\..\Relatorios\ufrmRelDescRomaneios.pas' {frmRelDescRomaneios},
  ufrmRelRomaneiosARM in '..\..\Relatorios\ufrmRelRomaneiosARM.pas' {frmRelRomaneiosARM},
  ufrmCadHistorico in '..\..\Cadastros\ufrmCadHistorico.pas' {frmCadHistorico},
  ufrmCadTipoDoc in '..\..\Cadastros\ufrmCadTipoDoc.pas' {frmCadTipoDoc},
  ufrmCadTipoPgto in '..\..\Cadastros\ufrmCadTipoPgto.pas' {frmCadTipoPgto},
  ufrmCadParceiroBan in '..\..\Cadastros\ufrmCadParceiroBan.pas' {frmCadParceiroBan},
  ufrmCadParceiroFaz in '..\..\Cadastros\ufrmCadParceiroFaz.pas' {frmCadParceiroFaz},
  ufrmCadParceiroFazCulturas in '..\..\Cadastros\ufrmCadParceiroFazCulturas.pas' {frmCadParceiroFazCulturas},
  ufrmCadParceiroImo in '..\..\Cadastros\ufrmCadParceiroImo.pas' {frmCadParceiroImo},
  ufrmCadParceiroMov in '..\..\Cadastros\ufrmCadParceiroMov.pas' {frmCadParceiroMov},
  ufrmCadParceiroProdutividade in '..\..\Cadastros\ufrmCadParceiroProdutividade.pas' {frmCadParceiroProdutividade},
  ufrmCadParceiroRef in '..\..\Cadastros\ufrmCadParceiroRef.pas' {frmCadParceiroRef},
  ufrmCadParceiroTel in '..\..\Cadastros\ufrmCadParceiroTel.pas' {frmCadParceiroTel},
  ufrmCadParceiroVin in '..\..\Cadastros\ufrmCadParceiroVin.pas' {frmCadParceiroVin},
  ufrmPesagemAvulsa in 'ufrmPesagemAvulsa.pas' {frmPesagemAvulsa},
  ufrmRelFretes in '..\..\Relatorios\ufrmRelFretes.pas' {frmRelFretes},
  ufrmCadParceiroContatos in '..\..\Cadastros\ufrmCadParceiroContatos.pas' {frmCadParceiroContatos},
  ufrmMovRomaneioBxContrato in 'ufrmMovRomaneioBxContrato.pas' {frmMovRomaneioBxContrato},
  ufrmMovRomaneioBxContratoIte in 'ufrmMovRomaneioBxContratoIte.pas' {frmMovRomaneioBxContratoIte},
  ufrmCadParceiro in '..\..\Cadastros\ufrmCadParceiro.pas' {frmCadParceiro},
  ufrmRelPesagemAvulsa in '..\..\Relatorios\ufrmRelPesagemAvulsa.pas' {frmRelPesagemAvulsa},
  ufrmCadSilos in '..\..\Cadastros\ufrmCadSilos.pas' {frmCadSilos},
  ufrmCadPendao in '..\..\Cadastros\ufrmCadPendao.pas' {frmCadPendao},
  ufrmCadLeituraTermometria in '..\..\Cadastros\ufrmCadLeituraTermometria.pas' {frmCadLeituraTermometria},
  ufrmCadProdutos in '..\..\Cadastros\ufrmCadProdutos.pas' {frmCadProdutos},
  ufrmCadProdutosForn in '..\..\Cadastros\ufrmCadProdutosForn.pas' {frmCadProdutosForn},
  ufrmMovTermometria in '..\MaxxGCI\ufrmMovTermometria.pas' {frmMovTermometria},
  ufrmCadSensor in '..\..\Cadastros\ufrmCadSensor.pas' {frmCadSensor},
  UFSistConsultaCNPJ in '..\..\Geral\UFSistConsultaCNPJ.pas',
  ufrmCadKit in '..\MaxxGCI\ufrmCadKit.pas' {frmCadKit},
  ufrmCadKitProduto in '..\..\Cadastros\ufrmCadKitProduto.pas' {frmCadKitProduto},
  uTabelaDescontoRepositorio in '..\..\Repositorio\uTabelaDescontoRepositorio.pas',
  uCamposPesquisa in '..\..\Geral\uCamposPesquisa.pas',
  uLeituraBalanca in '..\..\Geral\uLeituraBalanca.pas',
  udmLeituraBalanca in '..\..\Geral\udmLeituraBalanca.pas' {dmLeituraBalanca: TDataModule},
  uPesquisas in '..\..\Geral\uPesquisas.pas',
  ufrmRelRomaneiosTerceiros in '..\..\Relatorios\ufrmRelRomaneiosTerceiros.pas' {frmRelRomaneiosTerceiros},
  ufrmMovRomaneioTerceiro in 'ufrmMovRomaneioTerceiro.pas' {frmMovRomaneioTerceiro},
  uFuncoesBackup in '..\MaxxBKP\uFuncoesBackup.pas',
  ufrmRelEstoqueArmazem in '..\..\Relatorios\ufrmRelEstoqueArmazem.pas' {frmRelEstoqueArmazem},
  ufrmRelEstoqueArmazemARM in '..\..\Relatorios\ufrmRelEstoqueArmazemARM.pas' {frmRelEstoqueArmazemARM},
  ufrmRelEstoqueArmazemProduto in '..\MaxxGCI\ufrmRelEstoqueArmazemProduto.pas' {frmRelEstoqueArmazemProduto},
  ufrmRelProdutividade in '..\MaxxRES\ufrmRelProdutividade.pas' {frmRelProdutividade},
  ufrmRelProdutividadeVariedade in '..\MaxxRES\ufrmRelProdutividadeVariedade.pas' {frmRelProdutividadeVariedade},
  ufrmCadArmazem in '..\..\Cadastros\ufrmCadArmazem.pas' {frmCadArmazem},
  ufrmCadProdutosLotes in '..\..\Cadastros\ufrmCadProdutosLotes.pas' {frmCadProdutosLotes},
  ufrmCadProdutosLotesAnexos in '..\..\Cadastros\ufrmCadProdutosLotesAnexos.pas' {frmCadProdutosLotesAnexos},
  ufrmCadProdutosLotesSaldo in '..\..\Cadastros\ufrmCadProdutosLotesSaldo.pas' {frmCadProdutosLotesSaldo},
  ufrmMovNotaSaida in '..\MaxxCOM\ufrmMovNotaSaida.pas' {frmMovNotaSaida},
  ufrmMovNotaSaidaFinanceiro in '..\MaxxCOM\ufrmMovNotaSaidaFinanceiro.pas' {frmMovNotaSaidaFinanceiro},
  ufrmMovNotaSaidaGerarParcelas in '..\MaxxCOM\ufrmMovNotaSaidaGerarParcelas.pas' {frmMovNotaSaidaGerarParcelas},
  ufrmMovNotaSaidaIte in '..\MaxxCOM\ufrmMovNotaSaidaIte.pas' {frmMovNotaSaidaIte},
  ufrmMovNotaSaidaPedOrigem in '..\MaxxCOM\ufrmMovNotaSaidaPedOrigem.pas' {frmMovNotaSaidaPedOrigem},
  ufrmReceberTitulo in '..\MaxxFIN\ufrmReceberTitulo.pas' {frmReceberTitulo},
  uAdicionarTitutoReceber in '..\MaxxFIN\uAdicionarTitutoReceber.pas',
  uAlterarTituloReceber in '..\MaxxFIN\uAlterarTituloReceber.pas',
  ufrmCadDetGerarRec in '..\MaxxFIN\ufrmCadDetGerarRec.pas' {frmCadDetGerarRec},
  ufrmRateioPlanoFinanceiro in '..\MaxxFIN\ufrmRateioPlanoFinanceiro.pas' {frmRateioPlanoFinanceiro},
  ufrmRelNotaSaida in '..\..\Relatorios\ufrmRelNotaSaida.pas' {frmRelNotaSaida},
  ufrmGerarPagamentos in '..\MaxxFIN\ufrmGerarPagamentos.pas' {frmGerarPagamentos},
  ufrmMovDocAvulsoEnt in '..\MaxxCOM\ufrmMovDocAvulsoEnt.pas' {frmMovDocAvulsoEnt},
  ufrmMovNotaEntrada in '..\MaxxCOM\ufrmMovNotaEntrada.pas' {frmMovNotaEntrada},
  ufrmMovNotaEntradaFin in '..\MaxxCOM\ufrmMovNotaEntradaFin.pas' {frmMovNotaEntradaFin},
  ufrmMovNotaEntradaIte in '..\MaxxCOM\ufrmMovNotaEntradaIte.pas' {frmMovNotaEntradaIte},
  ufrmMovNotaEntradaNFe in '..\MaxxCOM\ufrmMovNotaEntradaNFe.pas' {frmMovNotaEntradaNFe},
  ufrmMovNotaEntradaNFePedOrigem in '..\MaxxCOM\ufrmMovNotaEntradaNFePedOrigem.pas' {frmMovNotaEntradaNFePedOrigem},
  ufrmMovNotaEntradaNFOrigem in '..\MaxxCOM\ufrmMovNotaEntradaNFOrigem.pas' {frmMovNotaEntradaNFOrigem},
  ufrmMovNotaEntradaPed in '..\MaxxCOM\ufrmMovNotaEntradaPed.pas' {frmMovNotaEntradaPed},
  ufrmMovNotaEntradaPedOrigem in '..\MaxxCOM\ufrmMovNotaEntradaPedOrigem.pas' {frmMovNotaEntradaPedOrigem},
  ufrmMovNotaEntradaSer in '..\MaxxCOM\ufrmMovNotaEntradaSer.pas' {frmMovNotaEntradaSer},
  uAdicionarTituloPagar in '..\MaxxFIN\uAdicionarTituloPagar.pas',
  uAlterarTituloPagar in '..\MaxxFIN\uAlterarTituloPagar.pas',
  ufrmPagarTitulo in '..\MaxxFIN\ufrmPagarTitulo.pas' {frmPagarTitulo},
  ufrmRateioCiclo in '..\MaxxFIN\ufrmRateioCiclo.pas' {frmRateioCiclo},
  ufrmRateioTalhao in '..\MaxxFIN\ufrmRateioTalhao.pas' {frmRateioTalhao},
  uGerarTitulosPagar in '..\MaxxFIN\uGerarTitulosPagar.pas',
  ufrmCadDetCiclos in '..\MaxxFIN\ufrmCadDetCiclos.pas' {frmCadDetCiclos},
  ufrmMovPagarTalhoes in '..\MaxxFIN\ufrmMovPagarTalhoes.pas' {frmMovPagarTalhoes},
  ufrmCadDetPlanoFinanceiro in '..\MaxxFIN\ufrmCadDetPlanoFinanceiro.pas' {frmCadDetPlanoFinanceiro},
  ufrmRelNotaEntrada in '..\..\Relatorios\ufrmRelNotaEntrada.pas' {frmRelNotaEntrada},
  UDownloadXMLNFeDLL in '..\..\Geral\UDownloadXMLNFeDLL.pas',
  UTDownloadXMLNFeDLL in '..\..\Geral\UTDownloadXMLNFeDLL.pas',
  utils in '..\..\Geral\utils.pas',
  uUtilsNotaSaida in '..\..\Geral\uUtilsNotaSaida.pas',
  ufrmMovNotaSaidaInf in '..\MaxxCOM\ufrmMovNotaSaidaInf.pas' {frmMovNotaSaidaInf},
  ufrmMovNotaEntradaPedDetalhar in '..\MaxxCOM\ufrmMovNotaEntradaPedDetalhar.pas' {frmMovNotaEntradaPedDetalhar},
  uPesquisarRel in '..\MaxxRES\uPesquisarRel.pas',
  ufrmMovNotaEntradaNFeVinculoProd in '..\MaxxCOM\ufrmMovNotaEntradaNFeVinculoProd.pas' {frmMovNotaEntradaNFeVinculoProd},
  uTributacao in '..\..\Geral\uTributacao.pas',
  ufrmNFe in '..\MaxxCOM\ufrmNFe.pas' {frmNFe},
  uNFeClass in '..\MaxxCOM\uNFeClass.pas',
  uNFeUtils in '..\MaxxCOM\uNFeUtils.pas',
  ufrmMovNotaEntradaNFOrigemArmazenagem in '..\MaxxCOM\ufrmMovNotaEntradaNFOrigemArmazenagem.pas' {frmMovNotaEntradaNFOrigemArmazenagem},
  uConstantes in '..\..\Geral\uConstantes.pas',
  ufrmMovNotaSaidaNFReferencia in '..\MaxxCOM\ufrmMovNotaSaidaNFReferencia.pas' {frmMovNotaSaidaNFReferencia},
  ufrmMovAbastecimento in '..\MaxxGCI\ufrmMovAbastecimento.pas' {frmMovAbastecimento},
  uConsultarHoraMaquina in '..\..\Geral\uConsultarHoraMaquina.pas',
  ufrmMovAbastecimentoHis in '..\MaxxGCI\ufrmMovAbastecimentoHis.pas' {frmMovAbastecimentoHis},
  ufrmControlaTrocaVis in '..\MaxxGCI\ufrmControlaTrocaVis.pas' {frmControlaTrocaVis},
  ufrmMovManutencao in '..\MaxxGCI\ufrmMovManutencao.pas' {frmMovManutencao},
  ufrmMovManutencaoSer in '..\MaxxGCI\ufrmMovManutencaoSer.pas' {frmMovManutencaoSer},
  ufrmMovManutencaoIte in '..\MaxxGCI\ufrmMovManutencaoIte.pas' {frmMovManutencaoIte},
  ufrmMovManutencaoFinanceiro in '..\MaxxGCI\ufrmMovManutencaoFinanceiro.pas' {frmMovManutencaoFinanceiro},
  ufrmMovManutencaoMultiIte in '..\MaxxGCI\ufrmMovManutencaoMultiIte.pas' {frmMovManutencaoMultiIte},
  ufrmMovManutencaoNFEntrada in '..\MaxxGCI\ufrmMovManutencaoNFEntrada.pas' {frmMovManutencaoNFEntrada},
  ufrmMovManutencaoNFEntradaErro in '..\MaxxGCI\ufrmMovManutencaoNFEntradaErro.pas' {frmMovManutencaoNFEntradaErro},
  ufrmMovNotaSaidaPedOrigemLOG in '..\MaxxCOM\ufrmMovNotaSaidaPedOrigemLOG.pas' {frmMovNotaSaidaPedOrigemLOG},
  ufrmMovManutencaoBenf in '..\MaxxGCI\ufrmMovManutencaoBenf.pas' {frmMovManutencaoBenf},
  ufrmMovManutencaoBenfFinan in '..\MaxxGCI\ufrmMovManutencaoBenfFinan.pas' {frmMovManutencaoBenfFinan},
  ufrmMovManutencaoBenfItem in '..\MaxxGCI\ufrmMovManutencaoBenfItem.pas' {frmMovManutencaoBenfItem},
  ufrmMovManutencaoBenfServ in '..\MaxxGCI\ufrmMovManutencaoBenfServ.pas' {frmMovManutencaoBenfServ},
  ufrmCarregarItemNFEntrada in '..\..\Geral\ufrmCarregarItemNFEntrada.pas' {frmCarregarItemNFEntrada},
  ufrmBaixasContratoReceber in '..\MaxxCOM\ufrmBaixasContratoReceber.pas' {frmBaixasContratoReceber},
  ufrmBaixasContratoReceberIte in '..\MaxxCOM\ufrmBaixasContratoReceberIte.pas' {frmBaixasContratosReceberIte},
  ufrmCadParceiroFazMatricula in '..\..\Cadastros\ufrmCadParceiroFazMatricula.pas' {frmCadParceiroFazMatricula},
  ufrmCadParceiroFazMatriculaHipoteca in '..\..\Cadastros\ufrmCadParceiroFazMatriculaHipoteca.pas' {frmCadParceiroFazMatriculaHipoteca},
  ufrmCadParceiroFazVinculos in '..\..\Cadastros\ufrmCadParceiroFazVinculos.pas' {frmCadParceiroFazVinculos},
  ufrmMovContratoReceber in '..\MaxxCOM\ufrmMovContratoReceber.pas' {frmMovContratoReceber},
  ufrmMovContratoRecEntregas in '..\MaxxCOM\ufrmMovContratoRecEntregas.pas' {frmMovContratoRecEntregas},
  uConsultaCNPJAcBR in '..\..\Geral\uConsultaCNPJAcBR.pas' {frmConsultaCNPJAcBR},
  uConsultaCNPJ in '..\..\Geral\uConsultaCNPJ.pas' {frmConsultaCNPJ},
  uImpressaoBematech in '..\..\Geral\uImpressaoBematech.pas',
  ufrmRelSiloEstoque in '..\..\Relatorios\ufrmRelSiloEstoque.pas' {frmRelSiloEstoque},
  ufrmVinculoPlanoContas in '..\..\Geral\ufrmVinculoPlanoContas.pas' {frmVinculoPlanoContas},
  uConversoes in '..\..\Geral\uConversoes.pas',
  uLayoutFormulario in '..\..\Geral\uLayoutFormulario.pas',
  ufrmUsoCPUMEM in '..\..\Geral\ufrmUsoCPUMEM.pas' {frmUsoCPUMEM},
  ufrmGerarFinanceiro in '..\..\Geral\ufrmGerarFinanceiro.pas' {frmGerarFinanceiro},
  ufrmGerarFinanceiroRateios in '..\..\Geral\ufrmGerarFinanceiroRateios.pas' {frmGerarFinanceiroRateios},
  ufrmGerarFinanceiroTitulos in '..\..\Geral\ufrmGerarFinanceiroTitulos.pas' {frmGerarFinanceiroTitulos},
  uFuncoesBalToledoDLL in '..\..\Geral\uFuncoesBalToledoDLL.pas',
  ufrmRelContratoReceber in '..\..\Relatorios\ufrmRelContratoReceber.pas' {frmRelContratoReceber},
  ufrmCadMaquinas in '..\..\Cadastros\ufrmCadMaquinas.pas' {frmCadMaquinas},
  ufrmCadMaquinasSeguros in '..\..\Cadastros\ufrmCadMaquinasSeguros.pas' {frmCadMaquinasSeguros},
  ufrmCadMaquinasSegurosAnexos in '..\..\Cadastros\ufrmCadMaquinasSegurosAnexos.pas' {frmCadMaquinasSegurosAnexos};

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

      Application.Title := 'Armazém';

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
