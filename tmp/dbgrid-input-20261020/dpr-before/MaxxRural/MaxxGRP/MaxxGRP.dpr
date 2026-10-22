program MaxxGRP;

uses
  Forms,
  Windows,
  ShellApi,
  SysUtils,
  IwSystem,
  IniFiles,
  ufrmPrincipal in 'ufrmPrincipal.pas' {frmPrincipal},
  uMensagens in '..\..\Geral\uMensagens.pas' {frmMensagens},
  udmMaxxLocal in '..\..\Geral\udmMaxxLocal.pas' {dmMaxxLocal: TDataModule},
  uLib in '..\..\Geral\uLib.pas',
  uPlacaVeiculo in '..\..\Geral\uPlacaVeiculo.pas',
  ufrmMaster in '..\..\Geral\ufrmMaster.pas' {frmMaster},
  ufrmMasterCad in '..\..\Geral\ufrmMasterCad.pas' {frmMasterCad},
  ufrmMasterDet in '..\..\Geral\ufrmMasterDet.pas' {frmMasterDet},
  ufrmMasterMov in '..\..\Geral\ufrmMasterMov.pas' {frmMasterMov},
  ufrmMasterPes in '..\..\Geral\ufrmMasterPes.pas' {frmMasterPes},
  ufrmMasterRel in '..\..\Geral\ufrmMasterRel.pas' {frmMasterRel},
  uRelatorioFiltroMultiplo in '..\..\Geral\uRelatorioFiltroMultiplo.pas',
  uRelatorioFiltroDependencia in '..\..\Geral\uRelatorioFiltroDependencia.pas',
  uRelatorioFiltroDependenciaLegado in '..\..\Geral\uRelatorioFiltroDependenciaLegado.pas',
  uRelatorioFiltroDependenciaDataSnap in '..\..\Geral\uRelatorioFiltroDependenciaDataSnap.pas',
  uRecError in '..\..\Geral\uRecError.pas' {ReconcileErrorForm},
  ufrmCadParceiro in '..\..\Cadastros\ufrmCadParceiro.pas' {frmCadParceiro},
  ufrmCadRecibo in '..\..\Cadastros\ufrmCadRecibo.pas' {frmCadRecibo},
  ufrmCadMoeda in '..\..\Cadastros\ufrmCadMoeda.pas' {frmCadMoeda},
  ufrmCadMoedaCotacao in '..\..\Cadastros\ufrmCadMoedaCotacao.pas' {frmCadMoedaCotacao},
  ufrmCadGrupoSubGrupos in '..\..\Cadastros\ufrmCadGrupoSubGrupos.pas' {frmCadGrupoSubGrupos},
  ufrmCadUnidade in '..\..\Cadastros\ufrmCadUnidade.pas' {frmCadUnidade},
  ufrmCadPrincipioAtivo in '..\..\Cadastros\ufrmCadPrincipioAtivo.pas' {frmCadPrincipioAtivo},
  ufrmCadProdutos in '..\..\Cadastros\ufrmCadProdutos.pas' {frmCadProdutos},
  ufrmCadGrupoSubGruposDet in '..\..\Cadastros\ufrmCadGrupoSubGruposDet.pas' {frmCadGrupoSubGruposDet},
  ufrmCadCiclos in '..\..\Cadastros\ufrmCadCiclos.pas' {frmCadCiclos},
  ufrmCadCulturas in '..\..\Cadastros\ufrmCadCulturas.pas' {frmCadCulturas},
  ufrmCadIntenCompra in '..\..\Cadastros\ufrmCadIntenCompra.pas' {frmCadIntenCompra},
  ufrmCadIntenCompraItens in '..\..\Cadastros\ufrmCadIntenCompraItens.pas' {frmCadIntenCompraItens},
  ufrmMovPedido in 'ufrmMovPedido.pas' {frmMovPedido},
  ufrmMovPedidoItens in 'ufrmMovPedidoItens.pas' {frmMovPedidoItens},
  ufrmRelParceiro in '..\..\Relatorios\ufrmRelParceiro.pas' {frmRelParceiro},
  ufrmRelDemonstrativoGeral in '..\..\Relatorios\ufrmRelDemonstrativoGeral.pas' {frmRelDemonstrativoGeral},
  ufrmRelIntenCompra in '..\..\Relatorios\ufrmRelIntenCompra.pas' {frmRelIntenCompra},
  ufrmRelFazendas in '..\..\Relatorios\ufrmRelFazendas.pas' {frmRelFazendas},
  ufrmSobre in '..\..\Geral\ufrmSobre.pas' {frmSobre},
  ufrmAterarSenha in '..\..\Geral\ufrmAterarSenha.pas' {frmAterarSenha},
  U_Cipher in '..\..\Geral\U_Cipher.pas',
  Md5 in '..\..\Geral\Md5.pas',
  DCPcrypt in '..\..\Geral\DCPcrypt.pas',
  DCPconst in '..\..\Geral\DCPconst.pas',
  Base64 in '..\..\Geral\Base64.pas',
  Sha1 in '..\..\Geral\Sha1.pas',
  IDEA in '..\..\Geral\IDEA.pas',
  ufrmProtecSYS in '..\..\Geral\ufrmProtecSYS.pas' {frmProtecSYS},
  ufrmCadSolicitaEntrega in '..\..\Cadastros\ufrmCadSolicitaEntrega.pas' {frmCadSolicitaEntrega},
  ufrmCadSolicitaEntregaDetalhe in '..\..\Cadastros\ufrmCadSolicitaEntregaDetalhe.pas' {frmCadSolicitaEntregaDetalhe},
  ufrmCadGerarSolicitacaoEntr in '..\..\Cadastros\ufrmCadGerarSolicitacaoEntr.pas' {frmCadGerarSolicitacaoEntr},
  ufrmCadGerarSolicitacaoEntrDetalhe in '..\..\Cadastros\ufrmCadGerarSolicitacaoEntrDetalhe.pas' {frmCadGerarSolicitacaoEntrDetalhe},
  ufrmCadParceiroTel in '..\..\Cadastros\ufrmCadParceiroTel.pas' {frmCadParceiroTel},
  ufrmCadParceiroRef in '..\..\Cadastros\ufrmCadParceiroRef.pas' {frmCadParceiroRef},
  ufrmCadParceiroImo in '..\..\Cadastros\ufrmCadParceiroImo.pas' {frmCadParceiroImo},
  ufrmCadParceiroMov in '..\..\Cadastros\ufrmCadParceiroMov.pas' {frmCadParceiroMov},
  ufrmCadParceiroBan in '..\..\Cadastros\ufrmCadParceiroBan.pas' {frmCadParceiroBan},
  ufrmRelProdutos in '..\..\Relatorios\ufrmRelProdutos.pas' {frmRelProdutos},
  ufrmRelEstPedido in '..\..\Relatorios\ufrmRelEstPedido.pas' {frmRelEstPedido},
  ufrmRelPrincipiosAtivos in '..\..\Relatorios\ufrmRelPrincipiosAtivos.pas' {frmRelPrincipiosAtivos},
  uFuncServ in '..\..\Geral\uFuncServ.pas',
  ufrmCadMaquinas in '..\..\Cadastros\ufrmCadMaquinas.pas' {frmCadMaquinas},
  ufrmCadParceiroVin in '..\..\Cadastros\ufrmCadParceiroVin.pas' {frmCadParceiroVin},
  ufrmFerLog in '..\..\Geral\ufrmFerLog.pas' {frmFerLog},
  uLog in '..\MaxxService\uLog.pas',
  ufrmCadParceiroFaz in '..\..\Cadastros\ufrmCadParceiroFaz.pas' {frmCadParceiroFaz},
  ufrmCadGrupoSubGruposTipo in '..\..\Cadastros\ufrmCadGrupoSubGruposTipo.pas' {frmCadGrupoSubGruposTipo},
  ufrmCadVariedadesI in '..\..\Cadastros\ufrmCadVariedadesI.pas' {frmCadVariedadesI},
  ufrmProtecao in '..\..\Geral\ufrmProtecao.pas' {frmProtecao},
  ufrmRelProdComercializados in '..\..\Relatorios\ufrmRelProdComercializados.pas' {frmRelProdComercializados},
  uModulos in '..\..\Geral\uModulos.pas',
  ufrmRelPedidos in 'ufrmRelPedidos.pas' {frmRelPedidos},
  ufrmPagarTitulo in '..\MaxxFIN\ufrmPagarTitulo.pas' {frmPagarTitulo},
  uGerarTitulosPagar in '..\MaxxFIN\uGerarTitulosPagar.pas',
  ufrmRateioCiclo in '..\MaxxFIN\ufrmRateioCiclo.pas' {frmRateioCiclo},
  ufrmRateioPlanoFinanceiro in '..\MaxxFIN\ufrmRateioPlanoFinanceiro.pas' {frmRateioPlanoFinanceiro},
  ufrmRateioTalhao in '..\MaxxFIN\ufrmRateioTalhao.pas' {frmRateioTalhao},
  ufrmRelApontAtividades in '..\..\Relatorios\ufrmRelApontAtividades.pas' {frmRelApontAtividades},
  ufrmInformacoes in '..\..\Geral\ufrmInformacoes.pas' {frmInformacoes},
  ufrmRelVariacaoIndexador in '..\MaxxRES\ufrmRelVariacaoIndexador.pas' {frmRelVariacaoIndexador},
  ufrmConsPosEstoque in '..\MaxxCOM\ufrmConsPosEstoque.pas' {frmConsPosEstoque},
  ufrmMasterConsulta in '..\..\Geral\ufrmMasterConsulta.pas' {frmMasterConsulta},
  ufrmAgenda in '..\..\Geral\ufrmAgenda.pas' {frmAgenda},
  ufrmAguarde in '..\..\Geral\ufrmAguarde.pas' {frmAguarde},
  ufrmBolMaxx in '..\..\Geral\ufrmBolMaxx.pas' {frmBolMaxx},
  ufrmCadHistorico in '..\..\Cadastros\ufrmCadHistorico.pas' {frmCadHistorico},
  ufrmCadTipoDoc in '..\..\Cadastros\ufrmCadTipoDoc.pas' {frmCadTipoDoc},
  ufrmCadTipoPgto in '..\..\Cadastros\ufrmCadTipoPgto.pas' {frmCadTipoPgto},
  ufrmCadParceiroFazCulturas in '..\..\Cadastros\ufrmCadParceiroFazCulturas.pas' {frmCadParceiroFazCulturas},
  ufrmCadParceiroProdutividade in '..\..\Cadastros\ufrmCadParceiroProdutividade.pas' {frmCadParceiroProdutividade},
  ufrmMovPedidoPerd in '..\MaxxCOM\ufrmMovPedidoPerd.pas' {frmMovPedidoPerd},
  ufrmCadParceiroContatos in '..\..\Cadastros\ufrmCadParceiroContatos.pas' {frmCadParceiroContatos},
  uLayoutFormulario in '..\..\Geral\uLayoutFormulario.pas',
  uConstantes in '..\..\Geral\uConstantes.pas',
  uPesquisarRel in '..\MaxxRES\uPesquisarRel.pas',
  ufrmVinculoPlanoContas in '..\..\Geral\ufrmVinculoPlanoContas.pas' {frmVinculoPlanoContas},
  uConversoes in '..\..\Geral\uConversoes.pas',
  ufrmCadParceiroFazMatricula in '..\..\Cadastros\ufrmCadParceiroFazMatricula.pas' {frmCadParceiroFazMatricula},
  ufrmCadParceiroFazMatriculaHipoteca in '..\..\Cadastros\ufrmCadParceiroFazMatriculaHipoteca.pas' {frmCadParceiroFazMatriculaHipoteca},
  ufrmCadParceiroFazVinculos in '..\..\Cadastros\ufrmCadParceiroFazVinculos.pas' {frmCadParceiroFazVinculos},
  uConsultaCNPJ in '..\..\Geral\uConsultaCNPJ.pas' {frmConsultaCNPJ},
  uConsultaCNPJAcBR in '..\..\Geral\uConsultaCNPJAcBR.pas' {frmConsultaCNPJAcBR},
  ufrmMenu in 'ufrmMenu.pas' {frmMenu},
  UFSistConsultaCNPJ in '..\..\Geral\UFSistConsultaCNPJ.pas',
  ufrmCadProdutosClassificacao in '..\..\Cadastros\ufrmCadProdutosClassificacao.pas' {frmCadProdutosClassificacao},
  ufrmCadProdutosCustoMedioDetalhes in '..\..\Cadastros\ufrmCadProdutosCustoMedioDetalhes.pas' {frmCadProdutosCustoMedioDetalhes},
  ufrmCadProdutosForn in '..\..\Cadastros\ufrmCadProdutosForn.pas' {frmCadProdutosForn},
  ufrmCadProdutosLotes in '..\..\Cadastros\ufrmCadProdutosLotes.pas' {frmCadProdutosLotes},
  ufrmCadProdutosLotesAnexos in '..\..\Cadastros\ufrmCadProdutosLotesAnexos.pas' {frmCadProdutosLotesAnexos},
  ufrmCadProdutosLotesSaldo in '..\..\Cadastros\ufrmCadProdutosLotesSaldo.pas' {frmCadProdutosLotesSaldo},
  ufrmUsoCPUMEM in '..\..\Geral\ufrmUsoCPUMEM.pas' {frmUsoCPUMEM},
  ufrmAguarde3 in '..\..\Geral\ufrmAguarde3.pas' {frmAguarde3},
  ufrmCadReciboOpcoes in '..\..\Cadastros\ufrmCadReciboOpcoes.pas' {frmCadRecidoOpcoes},
  ufrmMasterMultiProd in '..\..\Geral\ufrmMasterMultiProd.pas' {frmMasterMultiProd},
  ufrmGerarFinanceiro in '..\..\Geral\ufrmGerarFinanceiro.pas' {frmGerarFinanceiro},
  ufrmGerarFinanceiroRateios in '..\..\Geral\ufrmGerarFinanceiroRateios.pas' {frmGerarFinanceiroRateios},
  ufrmGerarFinanceiroTitulos in '..\..\Geral\ufrmGerarFinanceiroTitulos.pas' {frmGerarFinanceiroTitulos},
  uAdicionarTituloPagar in '..\MaxxFIN\uAdicionarTituloPagar.pas',
  uAdicionarTitutoReceber in '..\MaxxFIN\uAdicionarTitutoReceber.pas',
  uAlterarTituloPagar in '..\MaxxFIN\uAlterarTituloPagar.pas',
  uAlterarTituloReceber in '..\MaxxFIN\uAlterarTituloReceber.pas',
  ufrmAlterarTituloReceber in '..\MaxxFIN\ufrmAlterarTituloReceber.pas',
  ufrmGerarPagamentos in '..\MaxxFIN\ufrmGerarPagamentos.pas' {frmGerarPagamentos},
  ufrmCadDetCiclos in '..\MaxxFIN\ufrmCadDetCiclos.pas' {frmCadDetCiclos},
  ufrmCadDetGerarRec in '..\MaxxFIN\ufrmCadDetGerarRec.pas' {frmCadDetGerarRec},
  ufrmCadDetPlanoFinanceiro in '..\MaxxFIN\ufrmCadDetPlanoFinanceiro.pas' {frmCadDetPlanoFinanceiro},
  ufrmImportacaoNFe in '..\MaxxCOM\ufrmImportacaoNFe.pas' {frmImportacaoNFe},
  ufrmImportacaoNFeAjustes in '..\MaxxCOM\ufrmImportacaoNFeAjustes.pas' {frmImportacaoNFeAjustes},
  ufrmImportarRequisicao in '..\MaxxCOM\ufrmImportarRequisicao.pas' {frmImportarRequisicao},
  ufrmCadMaquinasSeguros in '..\..\Cadastros\ufrmCadMaquinasSeguros.pas' {frmCadMaquinasSeguros},
  ufrmCadMaquinasSegurosAnexos in '..\..\Cadastros\ufrmCadMaquinasSegurosAnexos.pas' {frmCadMaquinasSegurosAnexos},
  ufrmMovNotaEntrada in '..\MaxxCOM\ufrmMovNotaEntrada.pas' {frmMovNotaEntrada},
  ufrmMovNotaEntradaFin in '..\MaxxCOM\ufrmMovNotaEntradaFin.pas' {frmMovNotaEntradaFin},
  ufrmMovNotaEntradaIte in '..\MaxxCOM\ufrmMovNotaEntradaIte.pas' {frmMovNotaEntradaIte},
  ufrmMovNotaEntradaNFe in '..\MaxxCOM\ufrmMovNotaEntradaNFe.pas' {frmMovNotaEntradaNFe},
  ufrmMovNotaEntradaNFePedOrigem in '..\MaxxCOM\ufrmMovNotaEntradaNFePedOrigem.pas' {frmMovNotaEntradaNFePedOrigem},
  ufrmMovNotaEntradaNFeSite in '..\MaxxCOM\ufrmMovNotaEntradaNFeSite.pas' {frmMovNotaEntradaNFeSite},
  ufrmMovNotaEntradaNFeVinculoProd in '..\MaxxCOM\ufrmMovNotaEntradaNFeVinculoProd.pas' {frmMovNotaEntradaNFeVinculoProd},
  ufrmMovNotaEntradaNFOrigem in '..\MaxxCOM\ufrmMovNotaEntradaNFOrigem.pas' {frmMovNotaEntradaNFOrigem},
  ufrmMovNotaEntradaNFOrigemArmazenagem in '..\MaxxCOM\ufrmMovNotaEntradaNFOrigemArmazenagem.pas' {frmMovNotaEntradaNFOrigemArmazenagem},
  ufrmMovNotaEntradaPed in '..\MaxxCOM\ufrmMovNotaEntradaPed.pas' {frmMovNotaEntradaPed},
  ufrmMovNotaEntradaPedDetalhar in '..\MaxxCOM\ufrmMovNotaEntradaPedDetalhar.pas' {frmMovNotaEntradaPedDetalhar},
  ufrmMovNotaEntradaPedOrigem in '..\MaxxCOM\ufrmMovNotaEntradaPedOrigem.pas' {frmMovNotaEntradaPedOrigem},
  ufrmMovNotaEntradaPedServ in '..\MaxxCOM\ufrmMovNotaEntradaPedServ.pas' {frmMovNotaEntradaPedServ},
  ufrmMovNotaEntradaSer in '..\MaxxCOM\ufrmMovNotaEntradaSer.pas' {frmMovNotaEntradaSer},
  ufrmRelNotaEntrada in '..\..\Relatorios\ufrmRelNotaEntrada.pas' {frmRelNotaEntrada},
  ufrmMovDocAvulsoEnt in '..\MaxxCOM\ufrmMovDocAvulsoEnt.pas' {frmMovDocAvulsoEnt},
  ufrmMovNotaSaida in '..\MaxxCOM\ufrmMovNotaSaida.pas' {frmMovNotaSaida},
  ufrmMovNotaSaidaFinanceiro in '..\MaxxCOM\ufrmMovNotaSaidaFinanceiro.pas' {frmMovNotaSaidaFinanceiro},
  ufrmMovNotaSaidaGerarParcelas in '..\MaxxCOM\ufrmMovNotaSaidaGerarParcelas.pas' {frmMovNotaSaidaGerarParcelas},
  ufrmMovNotaSaidaInf in '..\MaxxCOM\ufrmMovNotaSaidaInf.pas' {frmMovNotaSaidaInf},
  ufrmMovNotaSaidaIte in '..\MaxxCOM\ufrmMovNotaSaidaIte.pas' {frmMovNotaSaidaIte},
  ufrmMovNotaSaidaNFReferencia in '..\MaxxCOM\ufrmMovNotaSaidaNFReferencia.pas' {frmMovNotaSaidaNFReferencia},
  ufrmMovNotaSaidaPedOrigem in '..\MaxxCOM\ufrmMovNotaSaidaPedOrigem.pas' {frmMovNotaSaidaPedOrigem},
  ufrmMovNotaSaidaPedOrigemLOG in '..\MaxxCOM\ufrmMovNotaSaidaPedOrigemLOG.pas' {frmMovNotaSaidaPedOrigemLOG},
  ufrmNFe in '..\MaxxCOM\ufrmNFe.pas' {frmNFe},
  ufrmNFeOutrasSolicitacoes in '..\MaxxCOM\ufrmNFeOutrasSolicitacoes.pas' {frmNFeOutrasSolicitacoes},
  uNFeClass in '..\MaxxCOM\uNFeClass.pas',
  uNFeUtils in '..\MaxxCOM\uNFeUtils.pas',
  uTributacao in '..\..\Geral\uTributacao.pas',
  uUtilsNotaSaida in '..\..\Geral\uUtilsNotaSaida.pas',
  uConsultarEstoque in '..\..\Geral\uConsultarEstoque.pas',
  uConsultarEstoqueFisico in '..\..\Geral\uConsultarEstoqueFisico.pas',
  uConsultarHoraMaquina in '..\..\Geral\uConsultarHoraMaquina.pas',
  uControlaEstoque in '..\..\Geral\uControlaEstoque.pas',
  uControlaEstoqueServidor in '..\..\Geral\uControlaEstoqueServidor.pas',
  ufrmReceberTitulo in '..\MaxxFIN\ufrmReceberTitulo.pas' {frmReceberTitulo},
  ufrmRelNotaSaida in '..\..\Relatorios\ufrmRelNotaSaida.pas' {frmRelNotaSaida},
  ufrmMovRomaneioBxContrato in '..\MaxxARM\ufrmMovRomaneioBxContrato.pas' {frmMovRomaneioBxContrato},
  ufrmMovRomaneioBxContratoIte in '..\MaxxARM\ufrmMovRomaneioBxContratoIte.pas' {frmMovRomaneioBxContratoIte},
  ufrmMovContratoReceber in '..\MaxxCOM\ufrmMovContratoReceber.pas' {frmMovContratoReceber},
  ufrmMovContratoRecEntregas in '..\MaxxCOM\ufrmMovContratoRecEntregas.pas' {frmMovContratoRecEntregas},
  ufrmRelContratoReceber in '..\..\Relatorios\ufrmRelContratoReceber.pas' {frmRelContratoReceber},
  ufrmBaixasContratoReceber in '..\MaxxCOM\ufrmBaixasContratoReceber.pas' {frmBaixasContratoReceber},
  ufrmBaixasContratoReceberIte in '..\MaxxCOM\ufrmBaixasContratoReceberIte.pas' {frmBaixasContratosReceberIte},
  utils in '..\..\Geral\utils.pas',
  ufrmMovAbastecimento in '..\MaxxGCI\ufrmMovAbastecimento.pas' {frmMovAbastecimento},
  ufrmMovAbastecimentoHis in '..\MaxxGCI\ufrmMovAbastecimentoHis.pas' {frmMovAbastecimentoHis},
  ufrmControlaTrocaVis in '..\MaxxGCI\ufrmControlaTrocaVis.pas' {frmControlaTrocaVis},
  uCustoMedio in '..\..\Geral\uCustoMedio.pas',
  ufrmMovManutencao in '..\MaxxGCI\ufrmMovManutencao.pas' {frmMovManutencao},
  ufrmMovManutencaoBenf in '..\MaxxGCI\ufrmMovManutencaoBenf.pas' {frmMovManutencaoBenf},
  ufrmMovManutencaoBenfFinan in '..\MaxxGCI\ufrmMovManutencaoBenfFinan.pas' {frmMovManutencaoBenfFinan},
  ufrmMovManutencaoBenfItem in '..\MaxxGCI\ufrmMovManutencaoBenfItem.pas' {frmMovManutencaoBenfItem},
  ufrmMovManutencaoBenfServ in '..\MaxxGCI\ufrmMovManutencaoBenfServ.pas' {frmMovManutencaoBenfServ},
  ufrmMovManutencaoFinanceiro in '..\MaxxGCI\ufrmMovManutencaoFinanceiro.pas' {frmMovManutencaoFinanceiro},
  ufrmMovManutencaoIte in '..\MaxxGCI\ufrmMovManutencaoIte.pas' {frmMovManutencaoIte},
  ufrmMovManutencaoMultiIte in '..\MaxxGCI\ufrmMovManutencaoMultiIte.pas' {frmMovManutencaoMultiIte},
  ufrmMovManutencaoNFEntrada in '..\MaxxGCI\ufrmMovManutencaoNFEntrada.pas' {frmMovManutencaoNFEntrada},
  ufrmMovManutencaoNFEntradaErro in '..\MaxxGCI\ufrmMovManutencaoNFEntradaErro.pas' {frmMovManutencaoNFEntradaErro},
  ufrmMovManutencaoSer in '..\MaxxGCI\ufrmMovManutencaoSer.pas' {frmMovManutencaoSer},
  ufrmCarregarItemNFEntrada in '..\..\Geral\ufrmCarregarItemNFEntrada.pas' {frmCarregarItemNFEntrada},
  ufrmMovPagarTalhoes in '..\MaxxFIN\ufrmMovPagarTalhoes.pas' {frmMovPagarTalhoes},
  uMyIP in '..\..\Geral\uMyIP.pas',
  ufrmFerAtualizaPrecoProd in '..\MaxxCOM\ufrmFerAtualizaPrecoProd.pas' {frmFerAtualizaPrecoProd},
  ufrmFerRecalculoEstoque in '..\MaxxCOM\ufrmFerRecalculoEstoque.pas' {frmFerRecalculoEstoque},
  ufrmFerCustoMedio in '..\..\Geral\ufrmFerCustoMedio.pas' {frmFerCustoMedio},
  ufrmEstoqueAcerto in '..\MaxxCOM\ufrmEstoqueAcerto.pas' {frmEstoqueAcerto},
  ufrmEstoqueAcertoIte in '..\MaxxCOM\ufrmEstoqueAcertoIte.pas' {frmEstoqueAcertoIte},
  uAtualizaPrecoProd in '..\..\Geral\uAtualizaPrecoProd.pas',
  ufrmAgroLegiaoAutorizacao in '..\..\Geral\ufrmAgroLegiaoAutorizacao.pas' {frmAgroLegiaoAutorizacao},
  ufrmAgroLegiaoAutorizacaoDet in '..\..\Geral\ufrmAgroLegiaoAutorizacaoDet.pas' {frmAgroLegiaoAutorizacaoDet};

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

      Application.Title := 'Gerenciador de grupo';
      CreateMutex(nil, False, PChar(IdSistema));

      { verifica se houve erro na criação }
      if (GetLastError = ERROR_ALREADY_EXISTS) then
      begin
         TfrmMensagens.Mensagem('O programa já está em execução!' + #13 +
                                'Essa instância será fechada!', 'I', IdSistema, [mbOk]);
         Halt(0);
      end;

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
