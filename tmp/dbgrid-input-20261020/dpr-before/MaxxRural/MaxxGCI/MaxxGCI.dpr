program MaxxGCI;

uses
  Forms,
  Windows,
  ShellApi,
  SysUtils,
  IwSystem,
  IniFiles,
  ufrmProtecSYS in '..\..\Geral\ufrmProtecSYS.pas' {frmProtecSYS},
  ufrmSobre in '..\..\Geral\ufrmSobre.pas' {frmSobre},
  uLib in '..\..\Geral\uLib.pas',
  uPlacaVeiculo in '..\..\Geral\uPlacaVeiculo.pas',
  uMensagens in '..\..\Geral\uMensagens.pas' {frmMensagens},
  uRecError in '..\..\Geral\uRecError.pas' {ReconcileErrorForm},
  udmMaxxLocal in '..\..\Geral\udmMaxxLocal.pas' {dmMaxxLocal: TDataModule},
  ufrmMaster in '..\..\Geral\ufrmMaster.pas' {frmMaster},
  ufrmMasterCad in '..\..\Geral\ufrmMasterCad.pas' {frmMasterCad},
  ufrmMasterDet in '..\..\Geral\ufrmMasterDet.pas' {frmMasterDet},
  ufrmMasterMov in '..\..\Geral\ufrmMasterMov.pas' {frmMasterMov},
  ufrmMasterRel in '..\..\Geral\ufrmMasterRel.pas' {frmMasterRel},
  ufrmAterarSenha in '..\..\Geral\ufrmAterarSenha.pas' {frmAterarSenha},
  ufrmCadCiclos in '..\..\Cadastros\ufrmCadCiclos.pas' {frmCadCiclos},
  ufrmCadCulturas in '..\..\Cadastros\ufrmCadCulturas.pas' {frmCadCulturas},
  ufrmCadVariedadesI in '..\..\Cadastros\ufrmCadVariedadesI.pas' {frmCadVariedadesI},
  ufrmCadTalhao in '..\..\Cadastros\ufrmCadTalhao.pas' {frmCadTalhoes},
  ufrmCadAtividade in '..\..\Cadastros\ufrmCadAtividade.pas' {frmCadAtividade},
  ufrmRelCiclos in '..\..\Relatorios\ufrmRelCiclos.pas' {frmRelCiclos},
  ufrmMasterPes in '..\..\Geral\ufrmMasterPes.pas' {frmMasterPes},
  uFrmRelTalhoes in '..\..\Relatorios\uFrmRelTalhoes.pas' {frmRelTalhoes},
  ufrmRelDiagnosticos in '..\..\Relatorios\ufrmRelDiagnosticos.pas' {frmRelDiagnosticos},
  ufrmRelAtividades in '..\..\Relatorios\ufrmRelAtividades.pas' {frmRelAtividades},
  ufrmRelCulturas in '..\..\Relatorios\ufrmRelCulturas.pas' {frmRelCulturas},
  uFrmCadItemAnaliseSolo in '..\..\Cadastros\uFrmCadItemAnaliseSolo.pas' {frmCadItemAnaliseSolo},
  ufrmRelItemAnaliseSolo in '..\..\Relatorios\ufrmRelItemAnaliseSolo.pas' {frmRelItemAnaliseSolo},
  ufrmCadLocTalhao in '..\..\Cadastros\ufrmCadLocTalhao.pas' {frmCadLocTalhao},
  ufrmCadVariedadesLocI in '..\..\Cadastros\ufrmCadVariedadesLocI.pas' {frmCadVariedadesLocI},
  ufrmPrincipal in 'ufrmPrincipal.pas' {frmPrincipal},
  ufrmRelLocacaoTalhao in '..\..\Relatorios\ufrmRelLocacaoTalhao.pas' {frmRelLocacaoTalhao},
  ufrmProtecao in '..\..\Geral\ufrmProtecao.pas' {frmProtecao},
  ufrmMovAtividadesMaq in 'ufrmMovAtividadesMaq.pas' {frmMovAtividadesMaq},
  ufrmCadAtividadeOpe in 'ufrmCadAtividadeOpe.pas' {frmCadAtividadeOpe},
  ufrmMovAtividades in 'ufrmMovAtividades.pas' {frmMovAtividades},
  ufrmConAtividades in 'ufrmConAtividades.pas' {frmConAtividades},
  ufrmCadAnaSolo in 'ufrmCadAnaSolo.pas' {frmCadAnaSolo},
  ufrmCadPontoPluviometrico in 'ufrmCadPontoPluviometrico.pas' {frmCadPontoPluviometrico},
  ufrmMovIndPluviometrico in 'ufrmMovIndPluviometrico.pas' {frmMovIndPluviometrico},
  ufrmCadMaquinas in '..\..\Cadastros\ufrmCadMaquinas.pas' {frmCadMaquinas},
  ufrmCadGrupoEquip in '..\..\Cadastros\ufrmCadGrupoEquip.pas' {frmCadGrupoEquip},
  uFrmCadServicos in '..\..\Cadastros\uFrmCadServicos.pas' {frmCadServicos},
  ufrmMovRomaneio in 'ufrmMovRomaneio.pas' {frmMovRomaneio},
  ufrmMovEmprestimo in 'ufrmMovEmprestimo.pas' {frmMovEmprestimo},
  ufrmMovBaixaEmpr in 'ufrmMovBaixaEmpr.pas' {frmMovBaixaEmpr},
  ufrmMovAtividadesPro in 'ufrmMovAtividadesPro.pas' {frmMovAtividadesPro},
  ufrmMovAtividadesSer in 'ufrmMovAtividadesSer.pas' {frmMovAtividadesSer},
  ufrmMovBaixaEmprProd in 'ufrmMovBaixaEmprProd.pas' {frmMovBaixaEmprProd},
  ufrmMovRomaneioDes in 'ufrmMovRomaneioDes.pas' {frmMovRomaneioDes},
  ufrmMovManutencao in 'ufrmMovManutencao.pas' {frmMovManutencao},
  ufrmMovManutencaoIte in 'ufrmMovManutencaoIte.pas' {frmMovManutencaoIte},
  ufrmMovManutencaoSer in 'ufrmMovManutencaoSer.pas' {frmMovManutencaoSer},
  uModulos in '..\..\Geral\uModulos.pas',
  ufrmCadBenfeitoria in 'ufrmCadBenfeitoria.pas' {frmCadBenfeitoria},
  ufrmMovAtividadesMaqAbas in 'ufrmMovAtividadesMaqAbas.pas' {frmMovAtividadesMaqAbas},
  ufrmMovBeneficiamento in 'ufrmMovBeneficiamento.pas' {frmMovBeneficiamento},
  ufrmMovBeneficiamentoRom in 'ufrmMovBeneficiamentoRom.pas' {frmMovBeneficiamentoRom},
  ufrmMovBeneficiamentoPro in 'ufrmMovBeneficiamentoPro.pas' {frmMovBeneficiamentoPro},
  uFrmRelBenfeitorias in '..\..\Relatorios\uFrmRelBenfeitorias.pas' {frmRelBenfeitorias},
  ufrmRelIndPluviometrico in '..\..\Relatorios\ufrmRelIndPluviometrico.pas' {frmRelIndPluviometrico},
  ufrmRelAbastecimentos in '..\..\Relatorios\ufrmRelAbastecimentos.pas' {frmRelAbastecimentos},
  ufrmCadAnaliseSoloI in 'ufrmCadAnaliseSoloI.pas' {frmCadAnaliseSoloI},
  ufrmMovAtividadeInfo in 'ufrmMovAtividadeInfo.pas' {frmMovAtividadeInfo},
  ufrmCadDetCiclos in '..\MaxxFIN\ufrmCadDetCiclos.pas' {frmCadDetCiclos},
  ufrmMovAtividadesFinanceiro in 'ufrmMovAtividadesFinanceiro.pas' {frmMovAtividadesFinanceiro},
  ufrmRelAnaliseSolo in '..\..\Relatorios\ufrmRelAnaliseSolo.pas' {frmRelAnaliseSolo},
  ufrmGerarPagamentos in '..\MaxxFIN\ufrmGerarPagamentos.pas' {frmGerarPagamentos},
  ufrmPagarTitulo in '..\MaxxFIN\ufrmPagarTitulo.pas' {frmPagarTitulo},
  uGerarTitulosPagar in '..\MaxxFIN\uGerarTitulosPagar.pas',
  uAdicionarTituloPagar in '..\MaxxFIN\uAdicionarTituloPagar.pas',
  uAlterarTituloPagar in '..\MaxxFIN\uAlterarTituloPagar.pas',
  uControlaEstoque in '..\..\Geral\uControlaEstoque.pas',
  ufrmCadDetPlanoFinanceiro in '..\MaxxFIN\ufrmCadDetPlanoFinanceiro.pas' {frmCadDetPlanoFinanceiro},
  ufrmMovAbastecimento in 'ufrmMovAbastecimento.pas' {frmMovAbastecimento},
  ufrmMovAbastecimentoHis in 'ufrmMovAbastecimentoHis.pas' {frmMovAbastecimentoHis},
  ufrmRateioCiclo in '..\MaxxFIN\ufrmRateioCiclo.pas' {frmRateioCiclo},
  ufrmRateioTalhao in '..\MaxxFIN\ufrmRateioTalhao.pas' {frmRateioTalhao},
  ufrmMovManutencaoFinanceiro in 'ufrmMovManutencaoFinanceiro.pas' {frmMovManutencaoFinanceiro},
  ufrmMovRomaneioFinanceiro in 'ufrmMovRomaneioFinanceiro.pas' {frmMovRomaneioFinanceiro},
  ufrmRelRomaneios in '..\..\Relatorios\ufrmRelRomaneios.pas' {frmRelRomaneios},
  ufrmRelApontAtividades in '..\..\Relatorios\ufrmRelApontAtividades.pas' {frmRelApontAtividades},
  uAlterarTituloReceber in '..\MaxxFIN\uAlterarTituloReceber.pas',
  uAdicionarTitutoReceber in '..\MaxxFIN\uAdicionarTitutoReceber.pas',
  ufrmReceberTitulo in '..\MaxxFIN\ufrmReceberTitulo.pas' {frmReceberTitulo},
  ufrmRateioPlanoFinanceiro in '..\MaxxFIN\ufrmRateioPlanoFinanceiro.pas' {frmRateioPlanoFinanceiro},
  ufrmRelEmprestimos in '..\..\Relatorios\ufrmRelEmprestimos.pas' {frmRelEmprestimos},
  uConsultarHoraMaquina in '..\..\Geral\uConsultarHoraMaquina.pas',
  ufrmInformacoes in '..\..\Geral\ufrmInformacoes.pas' {frmInformacoes},
  ufrmRelPosicaoEstoque in '..\..\Relatorios\ufrmRelPosicaoEstoque.pas' {frmRelPosicaoEstoque},
  ufrmRelHistoricoAtividade in '..\..\Relatorios\ufrmRelHistoricoAtividade.pas' {frmRelHistoricoAtividade},
  ufrmRelKardex in '..\..\Relatorios\ufrmRelKardex.pas' {frmRelKardex},
  ufrmMovOutrasAtividades in 'ufrmMovOutrasAtividades.pas' {frmMovOutrasAtividades},
  ufrmMovOutrasAtividadesMaq in 'ufrmMovOutrasAtividadesMaq.pas' {frmMovOutrasAtividadesMaq},
  ufrmMovOutrasAtividadesPro in 'ufrmMovOutrasAtividadesPro.pas' {frmMovOutrasAtividadesPro},
  ufrmMovOutrasAtividadesSer in 'ufrmMovOutrasAtividadesSer.pas' {frmMovOutrasAtividadesSer},
  ufrmRelOutrasAtividades in '..\..\Relatorios\ufrmRelOutrasAtividades.pas' {frmRelOutrasAtividades},
  ufrmCadArmazem in '..\..\Cadastros\ufrmCadArmazem.pas' {frmCadArmazem},
  ufrmCadGrupoSubGrupos in '..\..\Cadastros\ufrmCadGrupoSubGrupos.pas' {frmCadGrupoSubGrupos},
  ufrmCadGrupoSubGruposDet in '..\..\Cadastros\ufrmCadGrupoSubGruposDet.pas' {frmCadGrupoSubGruposDet},
  ufrmCadGrupoSubGruposTipo in '..\..\Cadastros\ufrmCadGrupoSubGruposTipo.pas' {frmCadGrupoSubGruposTipo},
  ufrmCadParceiro in '..\..\Cadastros\ufrmCadParceiro.pas' {frmCadParceiro},
  ufrmCadParceiroBan in '..\..\Cadastros\ufrmCadParceiroBan.pas' {frmCadParceiroBan},
  ufrmCadParceiroFaz in '..\..\Cadastros\ufrmCadParceiroFaz.pas' {frmCadParceiroFaz},
  ufrmCadParceiroImo in '..\..\Cadastros\ufrmCadParceiroImo.pas' {frmCadParceiroImo},
  ufrmCadParceiroMov in '..\..\Cadastros\ufrmCadParceiroMov.pas' {frmCadParceiroMov},
  ufrmCadParceiroRef in '..\..\Cadastros\ufrmCadParceiroRef.pas' {frmCadParceiroRef},
  ufrmCadParceiroTel in '..\..\Cadastros\ufrmCadParceiroTel.pas' {frmCadParceiroTel},
  ufrmCadParceiroVin in '..\..\Cadastros\ufrmCadParceiroVin.pas' {frmCadParceiroVin},
  ufrmCadProdutos in '..\..\Cadastros\ufrmCadProdutos.pas' {frmCadProdutos},
  ufrmCadTipoOperacao in '..\..\Cadastros\ufrmCadTipoOperacao.pas' {frmCadTipoOperacao},
  ufrmCadTipoOperacaoAcao in '..\..\Cadastros\ufrmCadTipoOperacaoAcao.pas' {frmCadTipoOperacaoAcao},
  ufrmCadUnidade in '..\..\Cadastros\ufrmCadUnidade.pas' {frmCadUnidade},
  ufrmMovOutrasAtividadesMaqAbas in 'ufrmMovOutrasAtividadesMaqAbas.pas' {frmMovOutrasAtividadesMaqAbas},
  ufrmConsPosEstoque in '..\MaxxCOM\ufrmConsPosEstoque.pas' {frmConsPosEstoque},
  ufrmMasterConsulta in '..\..\Geral\ufrmMasterConsulta.pas' {frmMasterConsulta},
  ufrmAguarde in '..\..\Geral\ufrmAguarde.pas' {frmAguarde},
  ufrmRelPontoPluviometrico in '..\..\Relatorios\ufrmRelPontoPluviometrico.pas' {frmRelPontoPluviometrico},
  ufrmMovDiagnosticos in 'ufrmMovDiagnosticos.pas' {frmMovDiagnosticos},
  ufrmRelControleManut in '..\..\Relatorios\ufrmRelControleManut.pas' {frmRelControleManut},
  ufrmRelHistManutMaq in '..\..\Relatorios\ufrmRelHistManutMaq.pas' {frmRelHistManutMaq},
  ufrmMovEmprestimoProduto in 'ufrmMovEmprestimoProduto.pas' {frmMovEmprestimoProduto},
  ufrmMovEmprestimoMaquina in 'ufrmMovEmprestimoMaquina.pas' {frmMovEmprestimoMaquina},
  ufrmRelFretes in '..\..\Relatorios\ufrmRelFretes.pas' {frmRelFretes},
  ufrmCadDetGerarRec in '..\MaxxFIN\ufrmCadDetGerarRec.pas' {frmCadDetGerarRec},
  ufrmBolMaxx in '..\..\Geral\ufrmBolMaxx.pas' {frmBolMaxx},
  ufrmCadHistorico in '..\..\Cadastros\ufrmCadHistorico.pas' {frmCadHistorico},
  ufrmCadTipoDoc in '..\..\Cadastros\ufrmCadTipoDoc.pas' {frmCadTipoDoc},
  ufrmCadTipoPgto in '..\..\Cadastros\ufrmCadTipoPgto.pas' {frmCadTipoPgto},
  ufrmMovManutencaoBenf in 'ufrmMovManutencaoBenf.pas' {frmMovManutencaoBenf},
  ufrmMovManutencaoBenfItem in 'ufrmMovManutencaoBenfItem.pas' {frmMovManutencaoBenfItem},
  ufrmMovManutencaoBenfServ in 'ufrmMovManutencaoBenfServ.pas' {frmMovManutencaoBenfServ},
  ufrmMovManutencaoBenfFinan in 'ufrmMovManutencaoBenfFinan.pas' {frmMovManutencaoBenfFinan},
  ufrmRelManutencaoBenf in 'ufrmRelManutencaoBenf.pas' {frmRelManutencaoBenf},
  ufrmRelManutMaquina in '..\MaxxRES\ufrmRelManutMaquina.pas' {frmRelManutMaquina},
  ufrmRelIndPluvAno in '..\..\Relatorios\ufrmRelIndPluvAno.pas' {frmRelIndPluvAno},
  ufrmMovManutencaoAgro in 'ufrmMovManutencaoAgro.pas' {frmMovManutencaoAgro},
  ufrmMovManutAgroItens in 'ufrmMovManutAgroItens.pas' {frmMovManutAgroItens},
  ufrmMovManutAgroProd in 'ufrmMovManutAgroProd.pas' {frmMovManutAgroProd},
  ufrmMovManutencaoAgroAplic in 'ufrmMovManutencaoAgroAplic.pas' {frmMovManutAgroAplic},
  ufrmMovManutAgroRec in 'ufrmMovManutAgroRec.pas' {frmMovManutAgroRec},
  ufrmMovManutAgroRecProd in 'ufrmMovManutAgroRecProd.pas' {frmMovManutAgroRecProd},
  ufrmCadDiagnosticos in '..\..\Cadastros\ufrmCadDiagnosticos.pas' {frmCadDiagnosticos},
  ufrmControlaTrocaVis in 'ufrmControlaTrocaVis.pas' {frmControlaTrocaVis},
  ufrmReplicaLocTalhao in 'ufrmReplicaLocTalhao.pas' {frmReplicaLocTalhao},
  ufrmReplicaMovAtividades in 'ufrmReplicaMovAtividades.pas' {frmReplicaMovAtividades},
  ufrmMovNromaneio in '..\MaxxARM\ufrmMovNromaneio.pas' {frmMovNromaneio},
  ufrmRelRomaneiosARM in '..\..\Relatorios\ufrmRelRomaneiosARM.pas' {frmRelRomaneiosARM},
  ufrmCadParceiroFazCulturas in '..\..\Cadastros\ufrmCadParceiroFazCulturas.pas' {frmCadParceiroFazCulturas},
  ufrmEstoqueAcerto in '..\MaxxCOM\ufrmEstoqueAcerto.pas' {frmEstoqueAcerto},
  ufrmRelEstoqueAcerto in '..\..\Relatorios\ufrmRelEstoqueAcerto.pas' {frmRelEstoqueAcerto},
  ufrmEstoqueAcertoIte in '..\MaxxCOM\ufrmEstoqueAcertoIte.pas' {frmEstoqueAcertoIte},
  ufrmCadParceiroProdutividade in '..\..\Cadastros\ufrmCadParceiroProdutividade.pas' {frmCadParceiroProdutividade},
  ufrmRelEstoqueArmazemProduto in 'ufrmRelEstoqueArmazemProduto.pas' {frmRelEstoqueArmazemProduto},
  ufrmMovKitIte in 'ufrmMovKitIte.pas' {frmMovKitIte},
  ufrmRelEmprestimoEPI in 'ufrmRelEmprestimoEPI.pas' {frmRelEmprestimoEPI},
  ufrmCadProdutosForn in '..\..\Cadastros\ufrmCadProdutosForn.pas' {frmCadProdutosForn},
  ufrmCadParceiroContatos in '..\..\Cadastros\ufrmCadParceiroContatos.pas' {frmCadParceiroContatos},
  ufrmMovRomaneioBxContrato in '..\MaxxARM\ufrmMovRomaneioBxContrato.pas' {frmMovRomaneioBxContrato},
  ufrmMovRomaneioBxContratoIte in '..\MaxxARM\ufrmMovRomaneioBxContratoIte.pas' {frmMovRomaneioBxContratoIte},
  ufrmMovAgrPrecisao in 'ufrmMovAgrPrecisao.pas' {frmMovAgrPrecisao},
  ufrmMovAgrPrecisaoImg in 'ufrmMovAgrPrecisaoImg.pas' {frmMovAgrPrecisaoImg},
  ufrmRelMaquinasEquipamentos in '..\..\Relatorios\ufrmRelMaquinasEquipamentos.pas' {frmRelMaquinasEquipamentos},
  uFrmRelServicos in '..\..\Relatorios\uFrmRelServicos.pas' {frmRelServicos},
  ufrmMovManutAgroFotos in 'ufrmMovManutAgroFotos.pas' {frmMovManutAgroFotos},
  ufrmMovTermometria in 'ufrmMovTermometria.pas' {frmMovTermometria},
  ufrmCadLeituraTermometria in '..\..\Cadastros\ufrmCadLeituraTermometria.pas' {frmCadLeituraTermometria},
  ufrmRelTermometria in '..\..\Relatorios\ufrmRelTermometria.pas' {frmRelTermometria},
  ufrmCadKit in 'ufrmCadKit.pas' {frmCadKit},
  ufrmCadKitProduto in '..\..\Cadastros\ufrmCadKitProduto.pas' {frmCadKitProduto},
  ufrmMovEPI in 'ufrmMovEPI.pas' {frmMovEPI},
  ufrmCadDepositos in '..\..\Cadastros\ufrmCadDepositos.pas' {frmCadDepositos},
  ufrmRelEstoqueDeposito in '..\..\Relatorios\ufrmRelEstoqueDeposito.pas' {frmRelEstoqueDeposito},
  UFSistConsultaCNPJ in '..\..\Geral\UFSistConsultaCNPJ.pas',
  uConsultaCNPJAcBR in '..\..\Geral\uConsultaCNPJAcBR.pas' {frmConsultaCNPJAcBR},
  ufrmRelEstoqueArmazem in '..\..\Relatorios\ufrmRelEstoqueArmazem.pas' {frmRelEstoqueArmazem},
  ufrmRelEstoqueArmazemARM in '..\..\Relatorios\ufrmRelEstoqueArmazemARM.pas' {frmRelEstoqueArmazemARM},
  ufrmMovRomaneioTerceiro in '..\MaxxARM\ufrmMovRomaneioTerceiro.pas' {frmMovRomaneioTerceiro},
  ufrmRelRomaneiosTerceiros in '..\..\Relatorios\ufrmRelRomaneiosTerceiros.pas' {frmRelRomaneiosTerceiros},
  uCamposPesquisa in '..\..\Geral\uCamposPesquisa.pas',
  udmLeituraBalanca in '..\..\Geral\udmLeituraBalanca.pas' {dmLeituraBalanca: TDataModule},
  uLeituraBalanca in '..\..\Geral\uLeituraBalanca.pas',
  uPesquisas in '..\..\Geral\uPesquisas.pas',
  uTabelaDescontoRepositorio in '..\..\Repositorio\uTabelaDescontoRepositorio.pas',
  ufrmCarregarItemNFEntrada in '..\..\Geral\ufrmCarregarItemNFEntrada.pas' {frmCarregarItemNFEntrada},
  ufrmMovManutencaoNFEntrada in 'ufrmMovManutencaoNFEntrada.pas' {frmMovManutencaoNFEntrada},
  ufrmRelDescRomaneios in '..\..\Relatorios\ufrmRelDescRomaneios.pas' {frmRelDescRomaneios},
  ufrmCadProdutosLotes in '..\..\Cadastros\ufrmCadProdutosLotes.pas' {frmCadProdutosLotes},
  ufrmCadProdutosLotesAnexos in '..\..\Cadastros\ufrmCadProdutosLotesAnexos.pas' {frmCadProdutosLotesAnexos},
  ufrmCadProdutosLotesSaldo in '..\..\Cadastros\ufrmCadProdutosLotesSaldo.pas' {frmCadProdutosLotesSaldo},
  ufrmConsSaldoLotes in '..\MaxxCOM\ufrmConsSaldoLotes.pas' {frmConsSaldoLotes},
  ufrmRelKardexLotes in '..\..\Relatorios\ufrmRelKardexLotes.pas' {frmRelKardexLotes},
  ufrmMovManutencaoNFEntradaErro in 'ufrmMovManutencaoNFEntradaErro.pas' {frmMovManutencaoNFEntradaErro},
  ufrmMovNotaSaida in '..\MaxxCOM\ufrmMovNotaSaida.pas' {frmMovNotaSaida},
  uUtilsNotaSaida in '..\..\Geral\uUtilsNotaSaida.pas',
  ufrmMovNotaSaidaIte in '..\MaxxCOM\ufrmMovNotaSaidaIte.pas' {frmMovNotaSaidaIte},
  ufrmMovNotaSaidaFinanceiro in '..\MaxxCOM\ufrmMovNotaSaidaFinanceiro.pas' {frmMovNotaSaidaFinanceiro},
  ufrmRelNotaSaida in '..\..\Relatorios\ufrmRelNotaSaida.pas' {frmRelNotaSaida},
  uTributacao in '..\..\Geral\uTributacao.pas',
  uConsultarEstoque in '..\..\Geral\uConsultarEstoque.pas',
  uConsultarEstoqueFisico in '..\..\Geral\uConsultarEstoqueFisico.pas',
  ufrmMovNotaSaidaGerarParcelas in '..\MaxxCOM\ufrmMovNotaSaidaGerarParcelas.pas' {frmMovNotaSaidaGerarParcelas},
  ufrmMovNotaSaidaPedOrigem in '..\MaxxCOM\ufrmMovNotaSaidaPedOrigem.pas' {frmMovNotaSaidaPedOrigem},
  ufrmMovDocAvulsoEnt in '..\MaxxCOM\ufrmMovDocAvulsoEnt.pas' {frmMovDocAvulsoEnt},
  ufrmMovNotaEntrada in '..\MaxxCOM\ufrmMovNotaEntrada.pas' {frmMovNotaEntrada},
  ufrmMovNotaEntradaIte in '..\MaxxCOM\ufrmMovNotaEntradaIte.pas' {frmMovNotaEntradaIte},
  ufrmMovNotaEntradaPed in '..\MaxxCOM\ufrmMovNotaEntradaPed.pas' {frmMovNotaEntradaPed},
  ufrmMovNotaEntradaSer in '..\MaxxCOM\ufrmMovNotaEntradaSer.pas' {frmMovNotaEntradaSer},
  ufrmMovNotaEntradaFin in '..\MaxxCOM\ufrmMovNotaEntradaFin.pas' {frmMovNotaEntradaFin},
  ufrmRelNotaEntrada in '..\..\Relatorios\ufrmRelNotaEntrada.pas' {frmRelNotaEntrada},
  ufrmMovNotaEntradaNFOrigem in '..\MaxxCOM\ufrmMovNotaEntradaNFOrigem.pas' {frmMovNotaEntradaNFOrigem},
  ufrmMovNotaEntradaPedOrigem in '..\MaxxCOM\ufrmMovNotaEntradaPedOrigem.pas' {frmMovNotaEntradaPedOrigem},
  ufrmMovNotaEntradaNFe in '..\MaxxCOM\ufrmMovNotaEntradaNFe.pas' {frmMovNotaEntradaNFe},
  ufrmMovPagarTalhoes in '..\MaxxFIN\ufrmMovPagarTalhoes.pas' {frmMovPagarTalhoes},
  UDownloadXMLNFeDLL in '..\..\Geral\UDownloadXMLNFeDLL.pas',
  UTDownloadXMLNFeDLL in '..\..\Geral\UTDownloadXMLNFeDLL.pas',
  ufrmMovNotaEntradaNFePedOrigem in '..\MaxxCOM\ufrmMovNotaEntradaNFePedOrigem.pas' {frmMovNotaEntradaNFePedOrigem},
  utils in '..\..\Geral\utils.pas',
  ufrmMovNotaSaidaInf in '..\MaxxCOM\ufrmMovNotaSaidaInf.pas' {frmMovNotaSaidaInf},
  ufrmMovNotaEntradaPedDetalhar in '..\MaxxCOM\ufrmMovNotaEntradaPedDetalhar.pas' {frmMovNotaEntradaPedDetalhar},
  uPesquisarRel in '..\MaxxRES\uPesquisarRel.pas',
  ufrmMovNotaEntradaNFeVinculoProd in '..\MaxxCOM\ufrmMovNotaEntradaNFeVinculoProd.pas' {frmMovNotaEntradaNFeVinculoProd},
  ufrmNFe in '..\MaxxCOM\ufrmNFe.pas' {frmNFe},
  uNFeClass in '..\MaxxCOM\uNFeClass.pas',
  uNFeUtils in '..\MaxxCOM\uNFeUtils.pas',
  ufrmRelMapaVenda in '..\..\Relatorios\ufrmRelMapaVenda.pas' {frmRelMapaVenda},
  ufrmMovNotaEntradaNFOrigemArmazenagem in '..\MaxxCOM\ufrmMovNotaEntradaNFOrigemArmazenagem.pas' {frmMovNotaEntradaNFOrigemArmazenagem},
  ufrmMovManutencaoMultiIte in 'ufrmMovManutencaoMultiIte.pas' {frmMovManutencaoMultiIte},
  uConstantes in '..\..\Geral\uConstantes.pas',
  ufrmMovNotaSaidaNFReferencia in '..\MaxxCOM\ufrmMovNotaSaidaNFReferencia.pas' {frmMovNotaSaidaNFReferencia},
  ufrmCadSilos in '..\..\Cadastros\ufrmCadSilos.pas' {frmCadSilos},
  ufrmCadPendao in '..\..\Cadastros\ufrmCadPendao.pas' {frmCadPendao},
  ufrmCadSensor in '..\..\Cadastros\ufrmCadSensor.pas' {frmCadSensor},
  ufrmMovEPIIte in 'ufrmMovEPIIte.pas' {frmMovEPIIte},
  ufrmMovNotaSaidaPedOrigemLOG in '..\MaxxCOM\ufrmMovNotaSaidaPedOrigemLOG.pas' {frmMovNotaSaidaPedOrigemLOG},
  ufrmMovApontamento in 'ufrmMovApontamento.pas' {frmMovApontamento},
  ufrmMovApontamentoMultiProd in 'ufrmMovApontamentoMultiProd.pas' {frmMovApontamentoMultiProd},
  ufrmMovApontamentoProduto in 'ufrmMovApontamentoProduto.pas' {frmMovApontamentoProduto},
  ufrmMovApontamentoMultiMaq in 'ufrmMovApontamentoMultiMaq.pas' {frmMovApontamentoMultiMaq},
  ufrmMovApontamentoMaquina in 'ufrmMovApontamentoMaquina.pas' {frmMovApontamentoMaquina},
  ufrmMovApontamentoMultiServ in 'ufrmMovApontamentoMultiServ.pas' {frmMovApontamentoMultiServ},
  ufrmMovApontamentoFinanceiro in 'ufrmMovApontamentoFinanceiro.pas' {frmMovApontamentoFinanceiro},
  ufrmMovApontamentoServico in 'ufrmMovApontamentoServico.pas' {frmMovApontamentoServico},
  ufrmMovApontamentoVisFinanceiro in 'ufrmMovApontamentoVisFinanceiro.pas' {frmMovApontamentoVisFinanceiro},
  ufrmMovApontamentoMultiplus in 'ufrmMovApontamentoMultiplus.pas' {frmMovApontamentoMultiplus},
  ufrmMovApontamentoMultiplusDelete in 'ufrmMovApontamentoMultiplusDelete.pas' {frmMovApontamentoMultiplusDelete},
  ufrmCadLocTalhaoImportaAtividades in '..\..\Cadastros\ufrmCadLocTalhaoImportaAtividades.pas' {frmCadLocTalhaoImportaAtividades},
  ufrmCadLocTalhaoAtividades in '..\..\Cadastros\ufrmCadLocTalhaoAtividades.pas' {frmCadLocTalhaoAtividades},
  ufrmCadMaquinasSeguros in '..\..\Cadastros\ufrmCadMaquinasSeguros.pas' {frmCadMaquinasSeguros},
  ufrmCadMaquinasSegurosAnexos in '..\..\Cadastros\ufrmCadMaquinasSegurosAnexos.pas' {frmCadMaquinasSegurosAnexos},
  ufrmCadParceiroFazMatricula in '..\..\Cadastros\ufrmCadParceiroFazMatricula.pas' {frmCadParceiroFazMatricula},
  ufrmCadParceiroFazMatriculaHipoteca in '..\..\Cadastros\ufrmCadParceiroFazMatriculaHipoteca.pas' {frmCadParceiroFazMatriculaHipoteca},
  ufrmCadParceiroFazVinculos in '..\..\Cadastros\ufrmCadParceiroFazVinculos.pas' {frmCadParceiroFazVinculos},
  ufrmMovContratoReceber in '..\MaxxCOM\ufrmMovContratoReceber.pas' {frmMovContratoReceber},
  ufrmMovContratoRecEntregas in '..\MaxxCOM\ufrmMovContratoRecEntregas.pas' {frmMovContratoRecEntregas},
  ufrmRelContratoReceber in '..\..\Relatorios\ufrmRelContratoReceber.pas' {frmRelContratoReceber},
  uConsultaCNPJ in '..\..\Geral\uConsultaCNPJ.pas' {frmConsultaCNPJ},
  ufrmRelSiloEstoque in '..\..\Relatorios\ufrmRelSiloEstoque.pas' {frmRelSiloEstoque},
  ufrmVinculoPlanoContas in '..\..\Geral\ufrmVinculoPlanoContas.pas' {frmVinculoPlanoContas},
  uConversoes in '..\..\Geral\uConversoes.pas',
  uLayoutFormulario in '..\..\Geral\uLayoutFormulario.pas',
  ufrmUsoCPUMEM in '..\..\Geral\ufrmUsoCPUMEM.pas' {frmUsoCPUMEM},
  ufrmGerarFinanceiro in '..\..\Geral\ufrmGerarFinanceiro.pas' {frmGerarFinanceiro},
  ufrmGerarFinanceiroRateios in '..\..\Geral\ufrmGerarFinanceiroRateios.pas' {frmGerarFinanceiroRateios},
  ufrmGerarFinanceiroTitulos in '..\..\Geral\ufrmGerarFinanceiroTitulos.pas' {frmGerarFinanceiroTitulos},
  uFuncoesBalToledoDLL in '..\..\Geral\uFuncoesBalToledoDLL.pas',
  ufrmConsSaldoDepositos in '..\MaxxCOM\ufrmConsSaldoDepositos.pas' {frmConsSaldoDepositos},
  ufrmConsSaldoLotesPeneira in '..\MaxxCOM\ufrmConsSaldoLotesPeneira.pas' {frmConsSaldoLotesPeneira},
  ufrmCadTabDesc in '..\..\Cadastros\ufrmCadTabDesc.pas' {frmCadTabDesc},
  ufrmCadTabDescItens in '..\..\Cadastros\ufrmCadTabDescItens.pas' {frmCadTabDescItens};

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

//      Application.Title := '.:MaxxSoft - ' + IdSistema;
      Application.Title := 'Gerenciador de ciclo';
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
