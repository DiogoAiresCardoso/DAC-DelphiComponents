program MaxxCOM;

uses
  Forms,
  Windows,
  ShellApi,
  SysUtils,
  IwSystem,
  ufrmPrincipal in 'ufrmPrincipal.pas' {frmPrincipal},
  ufrmCadProdutos in '..\..\Cadastros\ufrmCadProdutos.pas' {frmCadProdutos},
  ufrmCadParceiro in '..\..\Cadastros\ufrmCadParceiro.pas' {frmCadParceiro},
  ufrmCadParceiroBan in '..\..\Cadastros\ufrmCadParceiroBan.pas' {frmCadParceiroBan},
  ufrmCadParceiroFaz in '..\..\Cadastros\ufrmCadParceiroFaz.pas' {frmCadParceiroFaz},
  ufrmCadParceiroImo in '..\..\Cadastros\ufrmCadParceiroImo.pas' {frmCadParceiroImo},
  ufrmCadParceiroMov in '..\..\Cadastros\ufrmCadParceiroMov.pas' {frmCadParceiroMov},
  ufrmCadParceiroRef in '..\..\Cadastros\ufrmCadParceiroRef.pas' {frmCadParceiroRef},
  ufrmCadParceiroTel in '..\..\Cadastros\ufrmCadParceiroTel.pas' {frmCadParceiroTel},
  ufrmCadParceiroVin in '..\..\Cadastros\ufrmCadParceiroVin.pas' {frmCadParceiroVin},
  udmMaxxLocal in '..\..\Geral\udmMaxxLocal.pas' {dmMaxxLocal: TDataModule},
  ufrmProtecSYS in '..\..\Geral\ufrmProtecSYS.pas' {frmProtecSYS},
  ufrmSobre in '..\..\Geral\ufrmSobre.pas' {frmSobre},
  uFuncServ in '..\..\Geral\uFuncServ.pas',
  uLib in '..\..\Geral\uLib.pas',
  uPlacaVeiculo in '..\..\Geral\uPlacaVeiculo.pas',
  ufrmMaster in '..\..\Geral\ufrmMaster.pas' {frmMaster},
  ufrmMasterCad in '..\..\Geral\ufrmMasterCad.pas' {frmMasterCad},
  ufrmMasterDet in '..\..\Geral\ufrmMasterDet.pas' {frmMasterDet},
  ufrmMasterMov in '..\..\Geral\ufrmMasterMov.pas' {frmMasterMov},
  ufrmMasterPes in '..\..\Geral\ufrmMasterPes.pas' {frmMasterPes},
  ufrmMasterRel in '..\..\Geral\ufrmMasterRel.pas' {frmMasterRel},
  ufrmProtecao in '..\..\Geral\ufrmProtecao.pas' {frmProtecao},
  ufrmMovTransEstoque in 'ufrmMovTransEstoque.pas' {frmMovTransEstoque},
  uModulos in '..\..\Geral\uModulos.pas',
  ufrmMovInventario in 'ufrmMovInventario.pas' {frmMovInventario},
  ufrmMovNotaEntrada in 'ufrmMovNotaEntrada.pas' {frmMovNotaEntrada},
  ufrmMovContrato in 'ufrmMovContrato.pas' {frmMovContrato},
  ufrmMovPedidoItens in '..\MaxxGRP\ufrmMovPedidoItens.pas' {frmMovPedidoItens},
  ufrmMovPedido in '..\MaxxGRP\ufrmMovPedido.pas' {frmMovPedido},
  ufrmMovAnalisarCotacao in 'ufrmMovAnalisarCotacao.pas' {frmMovAnalisarCotacao},
  ufrmMovNotaSaidaIte in 'ufrmMovNotaSaidaIte.pas' {frmMovNotaSaidaIte},
  ufrmMovNotaEntradaIte in 'ufrmMovNotaEntradaIte.pas' {frmMovNotaEntradaIte},
  ufrmMovCotacao in 'ufrmMovCotacao.pas' {frmMovCotacao},
  ufrmMovPedidoIte in '..\MaxxGRP\ufrmMovPedidoIte.pas' {frmMovPedidoIte},
  ufrmMovAnalisarCotacaoIte in 'ufrmMovAnalisarCotacaoIte.pas' {frmMovAnalisarCotacaoIte},
  ufrmMovAnalisarCotacaoPro in 'ufrmMovAnalisarCotacaoPro.pas' {frmMovAnalisarCotacaoPro},
  ufrmMovCotacaoPro in 'ufrmMovCotacaoPro.pas' {frmMovCotacaoPro},
  ufrmMovGerirCotacao in 'ufrmMovGerirCotacao.pas' {frmMovGerirCotacao},
  ufrmMovGerirCotacaoIte in 'ufrmMovGerirCotacaoIte.pas' {frmMovGerirCotacaoIte},
  uRecError in '..\..\Geral\uRecError.pas' {ReconcileErrorForm},
  ufrmMovNotaEntradaSer in 'ufrmMovNotaEntradaSer.pas' {frmMovNotaEntradaSer},
  ufrmMovNotaEntradaFin in 'ufrmMovNotaEntradaFin.pas' {frmMovNotaEntradaFin},
  uGerarTitulosPagar in '..\MaxxFIN\uGerarTitulosPagar.pas',
  ufrmGerarPagamentos in '..\MaxxFIN\ufrmGerarPagamentos.pas' {frmGerarPagamentos},
  ufrmPagarTitulo in '..\MaxxFIN\ufrmPagarTitulo.pas' {frmPagarTitulo},
  uAdicionarTituloPagar in '..\MaxxFIN\uAdicionarTituloPagar.pas',
  uAlterarTituloPagar in '..\MaxxFIN\uAlterarTituloPagar.pas',
  ufrmCadDetCiclos in '..\MaxxFIN\ufrmCadDetCiclos.pas' {frmCadDetCiclos},
  ufrmMovPagarTalhoes in '..\MaxxFIN\ufrmMovPagarTalhoes.pas' {frmMovPagarTalhoes},
  uControlaEstoque in '..\..\Geral\uControlaEstoque.pas',
  uConsultarEstoque in '..\..\Geral\uConsultarEstoque.pas',
  ufrmRelPosicaoEstoque in '..\..\Relatorios\ufrmRelPosicaoEstoque.pas' {frmRelPosicaoEstoque},
  ufrmCadDetPlanoFinanceiro in '..\MaxxFIN\ufrmCadDetPlanoFinanceiro.pas' {frmCadDetPlanoFinanceiro},
  ufrmRelDemonstrativoGeral in '..\..\Relatorios\ufrmRelDemonstrativoGeral.pas' {frmRelDemonstrativoGeral},
  ufrmRelPedidos in '..\MaxxGRP\ufrmRelPedidos.pas' {frmRelPedidos},
  uConsultarEstoqueFisico in '..\..\Geral\uConsultarEstoqueFisico.pas',
  ufrmRateioCiclo in '..\MaxxFIN\ufrmRateioCiclo.pas' {frmRateioCiclo},
  ufrmRateioPlanoFinanceiro in '..\MaxxFIN\ufrmRateioPlanoFinanceiro.pas' {frmRateioPlanoFinanceiro},
  ufrmRateioTalhao in '..\MaxxFIN\ufrmRateioTalhao.pas' {frmRateioTalhao},
  ufrmCadCFOP in '..\..\Cadastros\ufrmCadCFOP.pas' {frmCadCFOP},
  ufrmCadCondPgto in '..\..\Cadastros\ufrmCadCondPgto.pas' {frmCadCondPgto},
  ufrmCadMoeda in '..\..\Cadastros\ufrmCadMoeda.pas' {frmCadMoeda},
  ufrmCadCFOPsOrigem in '..\..\Cadastros\ufrmCadCFOPsOrigem.pas' {frmCadCFOPsOrigem},
  ufrmCadMoedaCotacao in '..\..\Cadastros\ufrmCadMoedaCotacao.pas' {frmCadMoedaCotacao},
  ufrmMovNotaSaidaFinanceiro in 'ufrmMovNotaSaidaFinanceiro.pas' {frmMovNotaSaidaFinanceiro},
  ufrmReceberTitulo in '..\MaxxFIN\ufrmReceberTitulo.pas' {frmReceberTitulo},
  uAdicionarTitutoReceber in '..\MaxxFIN\uAdicionarTitutoReceber.pas',
  uAlterarTituloReceber in '..\MaxxFIN\uAlterarTituloReceber.pas',
  ufrmCadDetGerarRec in '..\MaxxFIN\ufrmCadDetGerarRec.pas' {frmCadDetGerarRec},
  ufrmRelNotaEntrada in '..\..\Relatorios\ufrmRelNotaEntrada.pas' {frmRelNotaEntrada},
  ufrmRelNotaSaida in '..\..\Relatorios\ufrmRelNotaSaida.pas' {frmRelNotaSaida},
  ufrmMovContratoReceber in 'ufrmMovContratoReceber.pas' {frmMovContratoReceber},
  ufrmRelContratoPagar in '..\..\Relatorios\ufrmRelContratoPagar.pas' {frmRelContratoPagar},
  ufrmRelContratoReceber in '..\..\Relatorios\ufrmRelContratoReceber.pas' {frmRelContratoReceber},
  ufrmInformacoes in '..\..\Geral\ufrmInformacoes.pas' {frmInformacoes},
  ufrmRelKardex in '..\..\Relatorios\ufrmRelKardex.pas' {frmRelKardex},
  ufrmMovNotaEntradaNFOrigem in 'ufrmMovNotaEntradaNFOrigem.pas' {frmMovNotaEntradaNFOrigem},
  ufrmCadTipoOperacao in '..\..\Cadastros\ufrmCadTipoOperacao.pas' {frmCadTipoOperacao},
  ufrmCadTipoOperacaoAcao in '..\..\Cadastros\ufrmCadTipoOperacaoAcao.pas' {frmCadTipoOperacaoAcao},
  ufrmCadUnidade in '..\..\Cadastros\ufrmCadUnidade.pas' {frmCadUnidade},
  uAtualizaPrecoProd in '..\..\Geral\uAtualizaPrecoProd.pas',
  ufrmFerAtualizaPrecoProd in 'ufrmFerAtualizaPrecoProd.pas' {frmFerAtualizaPrecoProd},
  ufrmRelNotaEntradaProdutos in '..\..\Relatorios\ufrmRelNotaEntradaProdutos.pas' {frmRelNotaEntradaProdutos},
  ufrmRelSaldoNFOrigem in '..\..\Relatorios\ufrmRelSaldoNFOrigem.pas' {frmRelSaldoNFOrigem},
  ufrmMasterConsulta in '..\..\Geral\ufrmMasterConsulta.pas' {frmMasterConsulta},
  ufrmConsPosEstoque in 'ufrmConsPosEstoque.pas' {frmConsPosEstoque},
  ufrmFerRecalculoEstoque in 'ufrmFerRecalculoEstoque.pas' {frmFerRecalculoEstoque},
  ufrmAguarde in '..\..\Geral\ufrmAguarde.pas' {frmAguarde},
  ufrmMovPedVenda in 'ufrmMovPedVenda.pas' {frmMovPedVenda},
  ufrmMovPedVendItens in 'ufrmMovPedVendItens.pas' {frmMovPedVendItens},
  ufrmCadUBS in '..\..\Cadastros\ufrmCadUBS.pas' {frmCadUBS},
  ufrmMovPedVendaFin in 'ufrmMovPedVendaFin.pas' {frmMovPedVendaFin},
  ufrmRelPedVenda in '..\..\Relatorios\ufrmRelPedVenda.pas' {frmRelPedVenda},
  ufrmMovContratoRecEntregas in 'ufrmMovContratoRecEntregas.pas' {frmMovContratoRecEntregas},
  ufrmMovNotaSaida in 'ufrmMovNotaSaida.pas' {frmMovNotaSaida},
  ufrmMovTransEstoqueItens in 'ufrmMovTransEstoqueItens.pas' {frmMovTransEstoqueItens},
  ufrmRelTransfEstoque in '..\..\Relatorios\ufrmRelTransfEstoque.pas' {frmRelTransfEstoque},
  ufrmBolMaxx in '..\..\Geral\ufrmBolMaxx.pas' {frmBolMaxx},
  ufrmCadTipoDoc in '..\..\Cadastros\ufrmCadTipoDoc.pas' {frmCadTipoDoc},
  ufrmCadHistorico in '..\..\Cadastros\ufrmCadHistorico.pas' {frmCadHistorico},
  ufrmMovNotaEntradaPedOrigem in 'ufrmMovNotaEntradaPedOrigem.pas' {frmMovNotaEntradaPedOrigem},
  ufrmCadArmazem in '..\..\Cadastros\ufrmCadArmazem.pas' {frmCadArmazem},
  ufrmCadGrupoSubGrupos in '..\..\Cadastros\ufrmCadGrupoSubGrupos.pas' {frmCadGrupoSubGrupos},
  ufrmCadGrupoSubGruposDet in '..\..\Cadastros\ufrmCadGrupoSubGruposDet.pas' {frmCadGrupoSubGruposDet},
  ufrmCadGrupoSubGruposTipo in '..\..\Cadastros\ufrmCadGrupoSubGruposTipo.pas' {frmCadGrupoSubGruposTipo},
  ufrmMovNotaSaidaGerarParcelas in 'ufrmMovNotaSaidaGerarParcelas.pas' {frmMovNotaSaidaGerarParcelas},
  ufrmCadTipoPgto in '..\..\Cadastros\ufrmCadTipoPgto.pas' {frmCadTipoPgto},
  ufrmMovPedidoFin in '..\MaxxGRP\ufrmMovPedidoFin.pas' {frmMovPedidoFin},
  ufrmMovEmbarquePedidoVenda in 'ufrmMovEmbarquePedidoVenda.pas' {frmMovEmbarquePedidoVenda},
  ufrmMovEmbarquePedidoVendaI in 'ufrmMovEmbarquePedidoVendaI.pas' {frmMovEmbarquePedidoVendaI},
  ufrmCadParceiroFazCulturas in '..\..\Cadastros\ufrmCadParceiroFazCulturas.pas' {frmCadParceiroFazCulturas},
  ufrmEstoqueAcerto in 'ufrmEstoqueAcerto.pas' {frmEstoqueAcerto},
  ufrmEstoqueAcertoIte in 'ufrmEstoqueAcertoIte.pas' {frmEstoqueAcertoIte},
  ufrmRelEstoqueAcerto in '..\..\Relatorios\ufrmRelEstoqueAcerto.pas' {frmRelEstoqueAcerto},
  ufrmCadParceiroProdutividade in '..\..\Cadastros\ufrmCadParceiroProdutividade.pas' {frmCadParceiroProdutividade},
  ufrmBaixasContratoReceber in 'ufrmBaixasContratoReceber.pas' {frmBaixasContratoReceber},
  ufrmBaixasContratoReceberIte in 'ufrmBaixasContratoReceberIte.pas' {frmBaixasContratosReceberIte},
  ufrmMovPedidoPerd in 'ufrmMovPedidoPerd.pas' {frmMovPedidoPerd},
  ufrmCadTipoContrato in '..\..\Cadastros\ufrmCadTipoContrato.pas' {frmCadTipoContrato},
  ufrmMovNotaEntradaNFe in 'ufrmMovNotaEntradaNFe.pas' {frmMovNotaEntradaNFe},
  UDownloadXMLNFeDLL in '..\..\Geral\UDownloadXMLNFeDLL.pas',
  UTDownloadXMLNFeDLL in '..\..\Geral\UTDownloadXMLNFeDLL.pas',
  utils in '..\..\Geral\utils.pas',
  ufrmCadProdutosForn in '..\..\Cadastros\ufrmCadProdutosForn.pas' {frmCadProdutosForn},
  ufrmCadParceiroContatos in '..\..\Cadastros\ufrmCadParceiroContatos.pas' {frmCadParceiroContatos},
  ufrmCadConfImpNF in 'ufrmCadConfImpNF.pas' {frmCadConfImpNF},
  ufrmRelApuracaoImpostoMT in '..\..\Relatorios\ufrmRelApuracaoImpostoMT.pas' {frmRelApuracaoImpostoMT},
  ufrmCadDepositos in '..\..\Cadastros\ufrmCadDepositos.pas' {frmCadDepositos},
  ufrmRelEstoqueDeposito in '..\..\Relatorios\ufrmRelEstoqueDeposito.pas' {frmRelEstoqueDeposito},
  ufrmMovInventarioDeposito in 'ufrmMovInventarioDeposito.pas' {frmMovInventarioDeposito},
  ufrmMovInventarioDepositoItem in 'ufrmMovInventarioDepositoItem.pas' {frmMovInventarioDepositoItem},
  ufrmMovNotaEntradaNFePedOrigem in 'ufrmMovNotaEntradaNFePedOrigem.pas' {frmMovNotaEntradaNFePedOrigem},
  UFSistConsultaCNPJ in '..\..\Geral\UFSistConsultaCNPJ.pas',
  uConsultaCNPJAcBR in '..\..\Geral\uConsultaCNPJAcBR.pas' {frmConsultaCNPJAcBR},
  ufrmRelMapaAquisicao in '..\..\Relatorios\ufrmRelMapaAquisicao.pas' {frmRelMapaAquisicao},
  ufrmCadBaseCalculo in '..\..\Cadastros\ufrmCadBaseCalculo.pas' {frmCadBaseCalculo},
  ufrmCadBaseCalculoItem in '..\..\Cadastros\ufrmCadBaseCalculoItem.pas' {frmCadBaseCalculoItem},
  ufrmMovAnaliseCotacao in 'ufrmMovAnaliseCotacao.pas' {frmMovAnaliseCotacao},
  ufrmCadPauta in '..\..\Cadastros\ufrmCadPauta.pas' {frmCadPauta},
  ufrmCadPautaIte in '..\..\Cadastros\ufrmCadPautaIte.pas' {frmCadPautaIte},
  uTributacao in '..\..\Geral\uTributacao.pas',
  ufrmMovAnaliseCotacaoCab in 'ufrmMovAnaliseCotacaoCab.pas' {frmMovAnaliseCotacaoCab},
  ufrmMovAnaliseCotacaoProd in 'ufrmMovAnaliseCotacaoProd.pas' {frmMovAnaliseCotacaoProd},
  ufrmCadProdutosLotes in '..\..\Cadastros\ufrmCadProdutosLotes.pas' {frmCadProdutosLotes},
  ufrmCadProdutosLotesSaldo in '..\..\Cadastros\ufrmCadProdutosLotesSaldo.pas' {frmCadProdutosLotesSaldo},
  ufrmCadProdutosLotesAnexos in '..\..\Cadastros\ufrmCadProdutosLotesAnexos.pas' {frmCadProdutosLotesAnexos},
  ufrmMovNotaSaidaPedOrigem in 'ufrmMovNotaSaidaPedOrigem.pas' {frmMovNotaSaidaPedOrigem},
  ufrmRelKardexLotes in '..\..\Relatorios\ufrmRelKardexLotes.pas' {frmRelKardexLotes},
  ufrmConsSaldoLotes in 'ufrmConsSaldoLotes.pas' {frmConsSaldoLotes},
  uNFeClass in 'uNFeClass.pas',
  ufrmNFe in 'ufrmNFe.pas' {frmNFe},
  uNFeUtils in 'uNFeUtils.pas',
  ufrmConsNFe in 'ufrmConsNFe.pas' {frmConsNFe},
  ufrmNFeOutrasSolicitacoes in 'ufrmNFeOutrasSolicitacoes.pas' {frmNFeOutrasSolicitacoes},
  ufrmConsultaInutilizacao in 'ufrmConsultaInutilizacao.pas' {frmConsultaInutilizacao},
  ufrmCadTipoContribuinte in '..\..\Geral\ufrmCadTipoContribuinte.pas' {frmCadTipoContribuinte},
  ufrmRelMapaVenda in '..\..\Relatorios\ufrmRelMapaVenda.pas' {frmRelMapaVenda},
  uMensagens in '..\..\Geral\uMensagens.pas' {frmMensagens},
  uPesquisarRel in '..\MaxxRES\uPesquisarRel.pas',
  ufrmMovNotaEntradaPedDetalhar in 'ufrmMovNotaEntradaPedDetalhar.pas' {frmMovNotaEntradaPedDetalhar},
  ufrmMovNotaEntradaNFeVinculoProd in 'ufrmMovNotaEntradaNFeVinculoProd.pas' {frmMovNotaEntradaNFeVinculoProd},
  ufrmMovNotaEntradaNFOrigemArmazenagem in 'ufrmMovNotaEntradaNFOrigemArmazenagem.pas' {frmMovNotaEntradaNFOrigemArmazenagem},
  ufrmRelSaldoNFOrigemArmazenagem in '..\..\Relatorios\ufrmRelSaldoNFOrigemArmazenagem.pas' {frmRelSaldoNFOrigemArmazenagem},
  uConstantes in '..\..\Geral\uConstantes.pas',
  ufrmMovNotaSaidaNFReferencia in 'ufrmMovNotaSaidaNFReferencia.pas' {frmMovNotaSaidaNFReferencia},
  ufrmConsNFeXML in 'ufrmConsNFeXML.pas' {frmConsNFeXML},
  ufrmConsSaldoDepositos in 'ufrmConsSaldoDepositos.pas' {frmConsSaldoDepositos},
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
  ufrmMovManutencaoBenf in '..\MaxxGCI\ufrmMovManutencaoBenf.pas' {frmMovManutencaoBenf},
  ufrmMovManutencaoBenfServ in '..\MaxxGCI\ufrmMovManutencaoBenfServ.pas' {frmMovManutencaoBenfServ},
  ufrmMovManutencaoBenfItem in '..\MaxxGCI\ufrmMovManutencaoBenfItem.pas' {frmMovManutencaoBenfItem},
  ufrmMovManutencaoBenfFinan in '..\MaxxGCI\ufrmMovManutencaoBenfFinan.pas' {frmMovManutencaoBenfFinan},
  ufrmCarregarItemNFEntrada in '..\..\Geral\ufrmCarregarItemNFEntrada.pas' {frmCarregarItemNFEntrada},
  ufrmConsSaldoLotesPeneira in 'ufrmConsSaldoLotesPeneira.pas' {frmConsSaldoLotesPeneira},
  ufrmCadCategoriaSemente in '..\..\Geral\ufrmCadCategoriaSemente.pas' {frmCadCategoriaSemente},
  ufrmCadPeneira in '..\..\Cadastros\ufrmCadPeneira.pas' {frmCadPeneira},
  ufrmReplicarParaLotesProdutos in 'ufrmReplicarParaLotesProdutos.pas' {frmReplicarParaLotesProdutos},
  ufrmRelNotaSaidaProduto in '..\..\Relatorios\ufrmRelNotaSaidaProduto.pas' {frmRelNotaSaidaProduto},
  ufrmMasterMultiProd in '..\..\Geral\ufrmMasterMultiProd.pas' {frmMasterMultiProd},
  ufrmMovPedidoMultiIte in '..\MaxxGRP\ufrmMovPedidoMultiIte.pas' {frmMovPedidoMultiIte},
  ufrmMovPedVendaMultiIte in 'ufrmMovPedVendaMultiIte.pas' {frmMovPedVendaMultiIte},
  ufrmCadParceiroFazMatricula in '..\..\Cadastros\ufrmCadParceiroFazMatricula.pas' {frmCadParceiroFazMatricula},
  ufrmCadParceiroFazMatriculaHipoteca in '..\..\Cadastros\ufrmCadParceiroFazMatriculaHipoteca.pas' {frmCadParceiroFazMatriculaHipoteca},
  ufrmCadParceiroFazVinculos in '..\..\Cadastros\ufrmCadParceiroFazVinculos.pas' {frmCadParceiroFazVinculos},
  uConsultaCNPJ in '..\..\Geral\uConsultaCNPJ.pas' {frmConsultaCNPJ},
  ufrmVinculoPlanoContas in '..\..\Geral\ufrmVinculoPlanoContas.pas' {frmVinculoPlanoContas},
  uConversoes in '..\..\Geral\uConversoes.pas',
  uLayoutFormulario in '..\..\Geral\uLayoutFormulario.pas',
  ufrmUsoCPUMEM in '..\..\Geral\ufrmUsoCPUMEM.pas' {frmUsoCPUMEM},
  ufrmGerarFinanceiro in '..\..\Geral\ufrmGerarFinanceiro.pas' {frmGerarFinanceiro},
  ufrmGerarFinanceiroRateios in '..\..\Geral\ufrmGerarFinanceiroRateios.pas' {frmGerarFinanceiroRateios},
  ufrmGerarFinanceiroTitulos in '..\..\Geral\ufrmGerarFinanceiroTitulos.pas' {frmGerarFinanceiroTitulos};

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

       Application.Title := 'Comercialização';

      // Se a diferença entre a hora atual e a hora do executável for maior que 2 minutos é solicitado o login
      FileAge(Application.ExeName, fileDateTime);
//      TfrmMensagens.Mensagem('Data: ' + DateTimeToStr(fileDateTime),'I', IdSistema, [mbOk]);
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
         else if (dmMaxxLocal.cdsVerificarPermissoes.IsEmpty) then
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
