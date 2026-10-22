program MaxxOFFLINE;

uses
  Forms,
  Windows,
  ShellApi,
  SysUtils,
  IwSystem,
  IniFiles,
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
  uMensagens in '..\..\Geral\uMensagens.pas' {frmMensagens},
  uModulos in '..\..\Geral\uModulos.pas',
  uRecError in '..\..\Geral\uRecError.pas' {ReconcileErrorForm},
  ufrmAguarde in '..\..\Geral\ufrmAguarde.pas' {frmAguarde},
  ufrmConsPosEstoque in '..\MaxxCOM\ufrmConsPosEstoque.pas' {frmConsPosEstoque},
  ufrmCadHistorico in '..\..\Cadastros\ufrmCadHistorico.pas' {frmCadHistorico},
  ufrmCadTipoDoc in '..\..\Cadastros\ufrmCadTipoDoc.pas' {frmCadTipoDoc},
  ufrmCadTipoPgto in '..\..\Cadastros\ufrmCadTipoPgto.pas' {frmCadTipoPgto},
  Base64 in '..\..\Geral\Base64.pas',
  DCPconst in '..\..\Geral\DCPconst.pas',
  DCPcrypt in '..\..\Geral\DCPcrypt.pas',
  IDEA in '..\..\Geral\IDEA.pas',
  Md5 in '..\..\Geral\Md5.pas',
  Sha1 in '..\..\Geral\Sha1.pas',
  U_Cipher in '..\..\Geral\U_Cipher.pas',
  ufrmAterarSenha in '..\..\Geral\ufrmAterarSenha.pas' {frmAterarSenha},
  uPesquisarRel in '..\MaxxRES\uPesquisarRel.pas',
  ufrmCadParceiro in '..\..\Cadastros\ufrmCadParceiro.pas' {frmCadParceiro},
  ufrmCadParceiroBan in '..\..\Cadastros\ufrmCadParceiroBan.pas' {frmCadParceiroBan},
  ufrmCadParceiroContatos in '..\..\Cadastros\ufrmCadParceiroContatos.pas' {frmCadParceiroContatos},
  ufrmCadParceiroFaz in '..\..\Cadastros\ufrmCadParceiroFaz.pas' {frmCadParceiroFaz},
  ufrmCadParceiroFazCulturas in '..\..\Cadastros\ufrmCadParceiroFazCulturas.pas' {frmCadParceiroFazCulturas},
  ufrmCadParceiroImo in '..\..\Cadastros\ufrmCadParceiroImo.pas' {frmCadParceiroImo},
  ufrmCadParceiroMov in '..\..\Cadastros\ufrmCadParceiroMov.pas' {frmCadParceiroMov},
  ufrmCadParceiroProdutividade in '..\..\Cadastros\ufrmCadParceiroProdutividade.pas' {frmCadParceiroProdutividade},
  ufrmCadParceiroRef in '..\..\Cadastros\ufrmCadParceiroRef.pas' {frmCadParceiroRef},
  ufrmCadParceiroTel in '..\..\Cadastros\ufrmCadParceiroTel.pas' {frmCadParceiroTel},
  ufrmCadParceiroVin in '..\..\Cadastros\ufrmCadParceiroVin.pas' {frmCadParceiroVin},
  ufrmCadProdutos in '..\..\Cadastros\ufrmCadProdutos.pas' {frmCadProdutos},
  ufrmCadProdutosForn in '..\..\Cadastros\ufrmCadProdutosForn.pas' {frmCadProdutosForn},
  ufrmCadProdutosLotes in '..\..\Cadastros\ufrmCadProdutosLotes.pas' {frmCadProdutosLotes},
  ufrmCadProdutosLotesAnexos in '..\..\Cadastros\ufrmCadProdutosLotesAnexos.pas' {frmCadProdutosLotesAnexos},
  ufrmCadProdutosLotesSaldo in '..\..\Cadastros\ufrmCadProdutosLotesSaldo.pas' {frmCadProdutosLotesSaldo},
  uConsultaCNPJAcBR in '..\..\Geral\uConsultaCNPJAcBR.pas' {frmConsultaCNPJAcBR},
  UFSistConsultaCNPJ in '..\..\Geral\UFSistConsultaCNPJ.pas',
  uConstantes in '..\..\Geral\uConstantes.pas',
  udmMaxxLocal in '..\..\Geral\udmMaxxLocal.pas' {dmMaxxLocal: TDataModule},
  ufrmMovNromaneio in '..\MaxxARM\ufrmMovNromaneio.pas' {frmMovNromaneio},
  uControlaEstoque in '..\..\Geral\uControlaEstoque.pas',
  ufrmMovRomaneioBxContrato in '..\MaxxARM\ufrmMovRomaneioBxContrato.pas' {frmMovRomaneioBxContrato},
  ufrmMovRomaneioBxContratoIte in '..\MaxxARM\ufrmMovRomaneioBxContratoIte.pas' {frmMovRomaneioBxContratoIte},
  uTabelaDescontoRepositorio in '..\..\Repositorio\uTabelaDescontoRepositorio.pas',
  ufrmNFe in '..\MaxxCOM\ufrmNFe.pas' {frmNFe},
  uNFeClass in '..\MaxxCOM\uNFeClass.pas',
  uNFeUtils in '..\MaxxCOM\uNFeUtils.pas',
  uUtilsNotaSaida in '..\..\Geral\uUtilsNotaSaida.pas',
  ufrmMovNotaSaida in '..\MaxxCOM\ufrmMovNotaSaida.pas' {frmMovNotaSaida},
  ufrmMovNotaSaidaFinanceiro in '..\MaxxCOM\ufrmMovNotaSaidaFinanceiro.pas' {frmMovNotaSaidaFinanceiro},
  ufrmMovNotaSaidaGerarParcelas in '..\MaxxCOM\ufrmMovNotaSaidaGerarParcelas.pas' {frmMovNotaSaidaGerarParcelas},
  ufrmMovNotaSaidaInf in '..\MaxxCOM\ufrmMovNotaSaidaInf.pas' {frmMovNotaSaidaInf},
  ufrmMovNotaSaidaIte in '..\MaxxCOM\ufrmMovNotaSaidaIte.pas' {frmMovNotaSaidaIte},
  ufrmMovNotaSaidaNFReferencia in '..\MaxxCOM\ufrmMovNotaSaidaNFReferencia.pas' {frmMovNotaSaidaNFReferencia},
  ufrmMovNotaSaidaPedOrigem in '..\MaxxCOM\ufrmMovNotaSaidaPedOrigem.pas' {frmMovNotaSaidaPedOrigem},
  uConsultarEstoqueFisico in '..\..\Geral\uConsultarEstoqueFisico.pas',
  uTributacao in '..\..\Geral\uTributacao.pas',
  uConsultarEstoque in '..\..\Geral\uConsultarEstoque.pas',
  ufrmReceberTitulo in '..\MaxxFIN\ufrmReceberTitulo.pas' {frmReceberTitulo},
  uAdicionarTitutoReceber in '..\MaxxFIN\uAdicionarTitutoReceber.pas',
  uAlterarTituloReceber in '..\MaxxFIN\uAlterarTituloReceber.pas',
  ufrmAlterarTituloReceber in '..\MaxxFIN\ufrmAlterarTituloReceber.pas',
  ufrmCadDetGerarRec in '..\MaxxFIN\ufrmCadDetGerarRec.pas' {frmCadDetGerarRec},
  ufrmRateioPlanoFinanceiro in '..\MaxxFIN\ufrmRateioPlanoFinanceiro.pas' {frmRateioPlanoFinanceiro},
  ufrmGerarPagamentos in '..\MaxxFIN\ufrmGerarPagamentos.pas' {frmGerarPagamentos},
  ufrmMovDocAvulsoEnt in '..\MaxxCOM\ufrmMovDocAvulsoEnt.pas' {frmMovDocAvulsoEnt},
  ufrmMovNotaEntrada in '..\MaxxCOM\ufrmMovNotaEntrada.pas' {frmMovNotaEntrada},
  ufrmMovNotaEntradaFin in '..\MaxxCOM\ufrmMovNotaEntradaFin.pas' {frmMovNotaEntradaFin},
  ufrmMovNotaEntradaIte in '..\MaxxCOM\ufrmMovNotaEntradaIte.pas' {frmMovNotaEntradaIte},
  ufrmMovNotaEntradaNFe in '..\MaxxCOM\ufrmMovNotaEntradaNFe.pas' {frmMovNotaEntradaNFe},
  ufrmMovNotaEntradaNFePedOrigem in '..\MaxxCOM\ufrmMovNotaEntradaNFePedOrigem.pas' {frmMovNotaEntradaNFePedOrigem},
  ufrmMovNotaEntradaNFeVinculoProd in '..\MaxxCOM\ufrmMovNotaEntradaNFeVinculoProd.pas' {frmMovNotaEntradaNFeVinculoProd},
  ufrmMovNotaEntradaNFOrigem in '..\MaxxCOM\ufrmMovNotaEntradaNFOrigem.pas' {frmMovNotaEntradaNFOrigem},
  ufrmMovNotaEntradaNFOrigemArmazenagem in '..\MaxxCOM\ufrmMovNotaEntradaNFOrigemArmazenagem.pas' {frmMovNotaEntradaNFOrigemArmazenagem},
  ufrmMovNotaEntradaPed in '..\MaxxCOM\ufrmMovNotaEntradaPed.pas' {frmMovNotaEntradaPed},
  ufrmMovNotaEntradaPedDetalhar in '..\MaxxCOM\ufrmMovNotaEntradaPedDetalhar.pas' {frmMovNotaEntradaPedDetalhar},
  ufrmMovNotaEntradaPedOrigem in '..\MaxxCOM\ufrmMovNotaEntradaPedOrigem.pas' {frmMovNotaEntradaPedOrigem},
  ufrmMovNotaEntradaSer in '..\MaxxCOM\ufrmMovNotaEntradaSer.pas' {frmMovNotaEntradaSer},
  uAdicionarTituloPagar in '..\MaxxFIN\uAdicionarTituloPagar.pas',
  uAlterarTituloPagar in '..\MaxxFIN\uAlterarTituloPagar.pas',
  uGerarTitulosPagar in '..\MaxxFIN\uGerarTitulosPagar.pas',
  ufrmPagarTitulo in '..\MaxxFIN\ufrmPagarTitulo.pas' {frmPagarTitulo},
  ufrmCadDetCiclos in '..\MaxxFIN\ufrmCadDetCiclos.pas' {frmCadDetCiclos},
  ufrmMovPagarTalhoes in '..\MaxxFIN\ufrmMovPagarTalhoes.pas' {frmMovPagarTalhoes},
  ufrmCadDetPlanoFinanceiro in '..\MaxxFIN\ufrmCadDetPlanoFinanceiro.pas' {frmCadDetPlanoFinanceiro},
  ufrmRateioCiclo in '..\MaxxFIN\ufrmRateioCiclo.pas' {frmRateioCiclo},
  ufrmRateioTalhao in '..\MaxxFIN\ufrmRateioTalhao.pas' {frmRateioTalhao},
  ufrmRelNotaEntrada in '..\..\Relatorios\ufrmRelNotaEntrada.pas' {frmRelNotaEntrada},
  UDownloadXMLNFeDLL in '..\..\Geral\UDownloadXMLNFeDLL.pas',
  UTDownloadXMLNFeDLL in '..\..\Geral\UTDownloadXMLNFeDLL.pas',
  utils in '..\..\Geral\utils.pas',
  ufrmMaxxSincronizar in 'ufrmMaxxSincronizar.pas' {frmMaxxSincronizar},
  udmRomaneio in 'udmRomaneio.pas' {dmRomaneio: TDataModule},
  ufrmControlePesagem in '..\MaxxARM\ufrmControlePesagem.pas' {frmControlePesagem},
  ufrmMovPesagemInicial in '..\MaxxARM\ufrmMovPesagemInicial.pas' {frmMovPesagemInicial},
  udmNotas in 'udmNotas.pas' {dmNotas: TDataModule},
  uConsultarHoraMaquina in '..\..\Geral\uConsultarHoraMaquina.pas',
  ufrmMovAbastecimento in '..\MaxxGCI\ufrmMovAbastecimento.pas' {frmMovAbastecimento},
  ufrmMovAbastecimentoHis in '..\MaxxGCI\ufrmMovAbastecimentoHis.pas' {frmMovAbastecimentoHis},
  ufrmControlaTrocaVis in '..\MaxxGCI\ufrmControlaTrocaVis.pas' {frmControlaTrocaVis},
  udmApontamentos in 'udmApontamentos.pas' {dmApontamentos: TDataModule},
  udmAbastecimentos in 'udmAbastecimentos.pas' {dmAbastecimentos: TDataModule},
  ufrmRelAbastecimentos in '..\..\Relatorios\ufrmRelAbastecimentos.pas' {frmRelAbastecimentos},
  ufrmRelApontAtividades in '..\..\Relatorios\ufrmRelApontAtividades.pas' {frmRelApontAtividades},
  ufrmRelNotaSaida in '..\..\Relatorios\ufrmRelNotaSaida.pas' {frmRelNotaSaida},
  ufrmRelRomaneiosARM in '..\..\Relatorios\ufrmRelRomaneiosARM.pas' {frmRelRomaneiosARM},
  ufrmMovManutencaoSer in '..\MaxxGCI\ufrmMovManutencaoSer.pas' {frmMovManutencaoSer},
  ufrmMovNotaSaidaPedOrigemLOG in '..\MaxxCOM\ufrmMovNotaSaidaPedOrigemLOG.pas' {frmMovNotaSaidaPedOrigemLOG},
  ufrmMovManutencaoBenf in '..\MaxxGCI\ufrmMovManutencaoBenf.pas' {frmMovManutencaoBenf},
  ufrmMovManutencaoBenfFinan in '..\MaxxGCI\ufrmMovManutencaoBenfFinan.pas' {frmMovManutencaoBenfFinan},
  ufrmMovManutencaoBenfItem in '..\MaxxGCI\ufrmMovManutencaoBenfItem.pas' {frmMovManutencaoBenfItem},
  ufrmCarregarItemNFEntrada in '..\..\Geral\ufrmCarregarItemNFEntrada.pas' {frmCarregarItemNFEntrada},
  ufrmPesagemAvulsa in '..\MaxxARM\ufrmPesagemAvulsa.pas' {frmPesagemAvulsa},
  ufrmMovRomaneioTerceiro in '..\MaxxARM\ufrmMovRomaneioTerceiro.pas' {frmMovRomaneioTerceiro},
  uCamposPesquisa in '..\..\Geral\uCamposPesquisa.pas',
  uLeituraBalanca in '..\..\Geral\uLeituraBalanca.pas',
  udmLeituraBalanca in '..\..\Geral\udmLeituraBalanca.pas' {dmLeituraBalanca: TDataModule},
  uPesquisas in '..\..\Geral\uPesquisas.pas',
  ufrmRelRomaneiosTerceiros in '..\..\Relatorios\ufrmRelRomaneiosTerceiros.pas' {frmRelRomaneiosTerceiros},
  ufrmRelPesagemAvulsa in '..\..\Relatorios\ufrmRelPesagemAvulsa.pas' {frmRelPesagemAvulsa},
  ufrmCadParceiroFazMatricula in '..\..\Cadastros\ufrmCadParceiroFazMatricula.pas' {frmCadParceiroFazMatricula},
  ufrmCadParceiroFazMatriculaHipoteca in '..\..\Cadastros\ufrmCadParceiroFazMatriculaHipoteca.pas' {frmCadParceiroFazMatriculaHipoteca},
  ufrmCadParceiroFazVinculos in '..\..\Cadastros\ufrmCadParceiroFazVinculos.pas' {frmCadParceiroFazVinculos},
  ufrmMovApontamento in '..\MaxxGCI\ufrmMovApontamento.pas' {frmMovApontamento},
  ufrmMovApontamentoFinanceiro in '..\MaxxGCI\ufrmMovApontamentoFinanceiro.pas' {frmMovApontamentoFinanceiro},
  ufrmMovApontamentoMaquina in '..\MaxxGCI\ufrmMovApontamentoMaquina.pas' {frmMovApontamentoMaquina},
  ufrmMovApontamentoMultiMaq in '..\MaxxGCI\ufrmMovApontamentoMultiMaq.pas' {frmMovApontamentoMultiMaq},
  ufrmMovApontamentoMultiplus in '..\MaxxGCI\ufrmMovApontamentoMultiplus.pas' {frmMovApontamentoMultiplus},
  ufrmMovApontamentoMultiplusDelete in '..\MaxxGCI\ufrmMovApontamentoMultiplusDelete.pas' {frmMovApontamentoMultiplusDelete},
  ufrmMovApontamentoMultiProd in '..\MaxxGCI\ufrmMovApontamentoMultiProd.pas' {frmMovApontamentoMultiProd},
  ufrmMovApontamentoMultiServ in '..\MaxxGCI\ufrmMovApontamentoMultiServ.pas' {frmMovApontamentoMultiServ},
  ufrmMovApontamentoProduto in '..\MaxxGCI\ufrmMovApontamentoProduto.pas' {frmMovApontamentoProduto},
  ufrmMovApontamentoServico in '..\MaxxGCI\ufrmMovApontamentoServico.pas' {frmMovApontamentoServico},
  ufrmMovApontamentoVisFinanceiro in '..\MaxxGCI\ufrmMovApontamentoVisFinanceiro.pas' {frmMovApontamentoVisFinanceiro},
  ufrmMovContratoReceber in '..\MaxxCOM\ufrmMovContratoReceber.pas' {frmMovContratoReceber},
  ufrmMovContratoRecEntregas in '..\MaxxCOM\ufrmMovContratoRecEntregas.pas' {frmMovContratoRecEntregas},
  ufrmRelContratoReceber in '..\..\Relatorios\ufrmRelContratoReceber.pas' {frmRelContratoReceber},
  ufrmRelKardex in '..\..\Relatorios\ufrmRelKardex.pas' {frmRelKardex},
  ufrmRelDescRomaneios in '..\..\Relatorios\ufrmRelDescRomaneios.pas' {frmRelDescRomaneios},
  ufrmRelEstoqueArmazemARM in '..\..\Relatorios\ufrmRelEstoqueArmazemARM.pas' {frmRelEstoqueArmazemARM},
  ufrmRelPosicaoEstoque in '..\..\Relatorios\ufrmRelPosicaoEstoque.pas' {frmRelPosicaoEstoque},
  ufrmRelManutMaquina in '..\MaxxRES\ufrmRelManutMaquina.pas' {frmRelManutMaquina},
  ufrmMovManutencao in '..\MaxxGCI\ufrmMovManutencao.pas' {frmMovManutencao},
  ufrmMovManutencaoFinanceiro in '..\MaxxGCI\ufrmMovManutencaoFinanceiro.pas' {frmMovManutencaoFinanceiro},
  ufrmMovManutencaoIte in '..\MaxxGCI\ufrmMovManutencaoIte.pas' {frmMovManutencaoIte},
  ufrmMovManutencaoMultiIte in '..\MaxxGCI\ufrmMovManutencaoMultiIte.pas' {frmMovManutencaoMultiIte},
  ufrmMovManutencaoNFEntrada in '..\MaxxGCI\ufrmMovManutencaoNFEntrada.pas' {frmMovManutencaoNFEntrada},
  ufrmMovManutencaoNFEntradaErro in '..\MaxxGCI\ufrmMovManutencaoNFEntradaErro.pas' {frmMovManutencaoNFEntradaErro},
  udmManutencaoMaq in 'udmManutencaoMaq.pas' {dmManutencaoMaq: TDataModule},
  uConsultaCNPJ in '..\..\Geral\uConsultaCNPJ.pas' {frmConsultaCNPJ},
  ufrmVinculoPlanoContas in '..\..\Geral\ufrmVinculoPlanoContas.pas' {frmVinculoPlanoContas},
  uConversoes in '..\..\Geral\uConversoes.pas',
  uLayoutFormulario in '..\..\Geral\uLayoutFormulario.pas',
  ufrmUsoCPUMEM in '..\..\Geral\ufrmUsoCPUMEM.pas' {frmUsoCPUMEM},
  ufrmGerarFinanceiro in '..\..\Geral\ufrmGerarFinanceiro.pas' {frmGerarFinanceiro},
  ufrmGerarFinanceiroRateios in '..\..\Geral\ufrmGerarFinanceiroRateios.pas' {frmGerarFinanceiroRateios},
  ufrmGerarFinanceiroTitulos in '..\..\Geral\ufrmGerarFinanceiroTitulos.pas' {frmGerarFinanceiroTitulos},
  uFuncoesBalToledoDLL in '..\..\Geral\uFuncoesBalToledoDLL.pas',
  ufrmMenu in 'ufrmMenu.pas' {frmMenu},
  ufrmPrincipal in 'ufrmPrincipal.pas' {frmPrincipal},
  frm12C in '..\Calc12C\frm12C.pas' {form12c},
  uAniThread in '..\..\Geral\uAniThread.pas',
  udmMaxxSincronizar in 'udmMaxxSincronizar.pas' {dmMaxxSincronizar: TDataModule},
  ufrmMovNotaEntradaNFeSite in '..\MaxxCOM\ufrmMovNotaEntradaNFeSite.pas' {frmMovNotaEntradaNFeSite},
  uDebugHelper in '..\..\Geral\uDebugHelper.pas',
  ufrmAguarde3 in '..\..\Geral\ufrmAguarde3.pas' {frmAguarde3},
  uEmail in '..\..\Geral\uEmail.pas',
  ufrmMovPesagemFinal in '..\MaxxARM\ufrmMovPesagemFinal.pas' {frmMovPesagemFinal},
  ufrmBaixasContratoReceber in '..\MaxxCOM\ufrmBaixasContratoReceber.pas' {frmBaixasContratoReceber},
  ufrmBaixasContratoReceberIte in '..\MaxxCOM\ufrmBaixasContratoReceberIte.pas' {frmBaixasContratosReceberIte},
  uCustoMedio in '..\..\Geral\uCustoMedio.pas',
  ufrmMovManutencaoBenfServ in '..\MaxxGCI\ufrmMovManutencaoBenfServ.pas' {frmMovManutencaoBenfServ},
  ufrmCadProdutosClassificacao in '..\..\Cadastros\ufrmCadProdutosClassificacao.pas' {frmCadProdutosClassificacao},
  ufrmCadProdutosCustoMedioDetalhes in '..\..\Cadastros\ufrmCadProdutosCustoMedioDetalhes.pas' {frmCadProdutosCustoMedioDetalhes},
  ufrmImportacaoNFe in '..\MaxxCOM\ufrmImportacaoNFe.pas' {frmImportacaoNFe},
  ufrmImportacaoNFeAjustes in '..\MaxxCOM\ufrmImportacaoNFeAjustes.pas' {frmImportacaoNFeAjustes},
  ufrmMovNotaEntradaPedServ in '..\MaxxCOM\ufrmMovNotaEntradaPedServ.pas' {frmMovNotaEntradaPedServ},
  uPlacaVeiculo in '..\..\Geral\uPlacaVeiculo.pas';

{$R *.res}

begin
   try
      Application.Initialize;
      Application.MainFormOnTaskbar := True;

      PastaEXE     := UpperCase(ExtractFilePath(Application.ExeName));
      PastaREL     := StringReplace(PastaEXE, '\EXE\', '\RELATORIOS\', []);
      PastaDAT     := StringReplace(PastaEXE, '\EXE\', '\DADOS\', []);
      PastaCFG     := StringReplace(PastaEXE, '\EXE\', '\CFG\', []);
      PastaIMA     := StringReplace(PastaEXE, '\EXE\', '\IMAGENS\', []);
      ArquivoLog   := StringReplace(UpperCase(gsAppPath), '\EXE\', '\CFG\MAXX.LOG', []);

      // Identificação do Módulo
      IdSistema := ExtractFileName(Application.ExeName);
      IdSistema := Copy(IdSistema, 1, (Length(Idsistema) - 4));

      Application.Title := 'MaxxSoft OFFLINE';

//      CreateMutex(nil, False, PChar(IdSistema));

//      { verifica se houve erro na criação }
//      if (GetLastError = ERROR_ALREADY_EXISTS) then
//      begin
//         TfrmMensagens.Mensagem('O programa já está em execução!' + #13 +
//                                'Essa instância será fechada!', 'I', IdSistema, [mbOk]);
//         Halt(0);
//      end;

      // Se a diferença entre a hora atual e a hora do executável for maior que 2 minutos é solicitado o login
      programaLiberado := not (DateTimeToStr(Now - FileDateToDateTime(FileAge(ParamStr(0)))) > '30/12/1899 01:00:00');


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
         //Se tiver permissão de acesso ao modulo e a conexão com o servidor foi realizada

         if (dmMaxxLocal.dbConn.Connected) then
         begin
            Application.CreateForm(TfrmPrincipal, frmPrincipal);
            Application.Run;
         end
         // Se não tem permissão de acesso ou deu erro de conexão com o servidor encerra o módulo
         else if (not dmMaxxLocal.dbConn.Connected) then
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

