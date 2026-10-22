program MaxxRDNBarter;

uses
  Vcl.Forms,
  ufrmPrincipal in 'ufrmPrincipal.pas' {frmPrincipal},
  udmMaxxLocal in 'udmMaxxLocal.pas' {dmMaxxLocal: TDataModule},
  ufrmAguarde in '..\Geral\ufrmAguarde.pas' {frmAguarde},
  uMensagens in '..\Geral\uMensagens.pas' {frmMensagens},
  uPlacaVeiculo in '..\Geral\uPlacaVeiculo.pas',
  Windows,
  ShellApi,
  SysUtils,
  IwSystem,
  IniFiles,
  ufrmFerPermissoes in 'ufrmFerPermissoes.pas' {frmFerPermissoes},
  ufrmMaster in '..\Geral\ufrmMaster.pas' {frmMaster},
  ufrmMasterPes in 'ufrmMasterPes.pas' {frmMasterPes},
  uRecError in 'uRecError.pas' {ReconcileErrorForm},
  uModulos in 'uModulos.pas',
  uLib in 'uLib.pas',
  Base64 in 'Base64.pas',
  DCPconst in 'DCPconst.pas',
  DCPcrypt in 'DCPcrypt.pas',
  IDEA in 'IDEA.pas',
  Md5 in 'Md5.pas',
  Sha1 in 'Sha1.pas',
  U_Cipher in 'U_Cipher.pas',
  ufrmMasterCad in 'ufrmMasterCad.pas' {frmMasterCad},
  ufrmCadDesc in 'ufrmCadDesc.pas' {frmCadDesc},
  ufrmCadCulturas in 'ufrmCadCulturas.pas' {frmCadCulturas},
  ufrmMetas in 'ufrmMetas.pas' {frmMetas},
  ufrmConsPedidos in 'ufrmConsPedidos.pas' {frmConsPedidos},
  ufrmConsPedidosResumo in 'ufrmConsPedidosResumo.pas' {frmConsPedidosResumo},
  ufrmConsVisitaTecDetalhes in 'ufrmConsVisitaTecDetalhes.pas' {frmConsVisitaTecDetalhes},
  ufrmConsVisitaTecDetalhesFotoZoom in 'ufrmConsVisitaTecDetalhesFotoZoom.pas' {frmConsVisitaTecDetalhesFotoZoom},
  ufrmCadAtividade in 'ufrmCadAtividade.pas' {frmCadAtividade},
  ufrmMasterDet in 'ufrmMasterDet.pas' {frmMasterDet},
  ufrmCadAtividadeOpe in 'ufrmCadAtividadeOpe.pas' {frmCadAtividadeOpe},
  ufrmCadVendedor in 'ufrmCadVendedor.pas' {frmCadVendedor},
  ufrmCadGrupoProd in 'ufrmCadGrupoProd.pas' {frmCadGrupoProd},
  ufrmCadProduto in 'ufrmCadProduto.pas' {frmCadProduto},
  ufrmCadMargem in 'ufrmCadMargem.pas' {frmCadMargem},
  ufrmCadTabPreco in 'ufrmCadTabPreco.pas' {frmCadTabPreco},
  ufrmCadTabPrecoItens in 'ufrmCadTabPrecoItens.pas' {frmCadTabPrecoItens},
  ufrmCadTabPrecoCommotidy in 'ufrmCadTabPrecoCommotidy.pas' {frmCadTabPrecoCommotidy},
  ufrmPosVendedor in 'ufrmPosVendedor.pas' {frmPosVendedor},
  ufrmProcessaPed in 'ufrmProcessaPed.pas' {frmProcessaPed},
  ufrmCadMotNaoVenda in 'ufrmCadMotNaoVenda.pas' {frmCadMotNaoVenda},
  ufrmCadMotNaoVisita in 'ufrmCadMotNaoVisita.pas' {frmCadMotNaoVisita},
  ufrmRelProdutos in 'ufrmRelProdutos.pas' {frmRelProdutos},
  ufrmMasterRel in 'ufrmMasterRel.pas' {frmMasterRel},
  ufrmRelKMVendedores in 'ufrmRelKMVendedores.pas' {frmRelKMVendedores},
  ufrmCadTipoDesp in 'ufrmCadTipoDesp.pas' {frmCadTipoDesp},
  ufrmCadUsuario in 'ufrmCadUsuario.pas' {frmCadUsuario},
  ufrmCadTipoOper in 'ufrmCadTipoOper.pas' {frmCadTipoOper},
  ufrmConsTipoOper in 'ufrmConsTipoOper.pas' {frmConsTipoOper},
  ufrmCadCampanha in 'MaxxCRM\ufrmCadCampanha.pas' {frmCadCampanha},
  ufrmCadCampanhaItens in 'MaxxCRM\ufrmCadCampanhaItens.pas' {frmCadCampanhaItens},
  ufrmMasterConsulta in 'ufrmMasterConsulta.pas' {frmMasterConsulta},
  ufrmConsultaVendasNova in 'MaxxCRM\ufrmConsultaVendasNova.pas' {frmConsultaVendasNova},
  ufrmConsultaDespesas in 'MaxxCRM\ufrmConsultaDespesas.pas' {frmConsultaDespesas},
  ufrmGraficoDespesas in 'MaxxCRM\ufrmGraficoDespesas.pas' {frmGraficoDespesas},
  ufrmMovMetaCiclo in 'MaxxCRM\ufrmMovMetaCiclo.pas' {frmMovMetaCiclo},
  ufrmMovMetaEmp in 'MaxxCRM\ufrmMovMetaEmp.pas' {frmMovMetaEmp},
  ufrmMovMetaEmpItens in 'MaxxCRM\ufrmMovMetaEmpItens.pas' {frmMovMetaEmpItens},
  ufrmMovMetaVend in 'MaxxCRM\ufrmMovMetaVend.pas' {frmMovMetaVend},
  ufrmMovMetaVendItens in 'MaxxCRM\ufrmMovMetaVendItens.pas' {frmMovMetaVendItens},
  GMConstants in 'GMConstants.pas',
  ufrmMovAgenda in 'ufrmMovAgenda.pas' {frmMovAgenda},
  ufrmRelDespesas in 'Relatorios\ufrmRelDespesas.pas' {frmRelDespesas},
  ufrmRelVisitasXDespesas in 'Relatorios\ufrmRelVisitasXDespesas.pas' {frmRelVisitasXDespesas},
  ufrmConsultaVendasClientes in 'MaxxCRM\ufrmConsultaVendasClientes.pas' {frmConsultaVendasClientes},
  ufrmMovPotencialCliente in 'MaxxCRM\ufrmMovPotencialCliente.pas' {frmMovPotencialCliente},
  ufrmMovPotencialClienteItens in 'MaxxCRM\ufrmMovPotencialClienteItens.pas' {frmMovPotencialClienteItens},
  ufrmConsultaVendasPotencial in 'MaxxCRM\ufrmConsultaVendasPotencial.pas' {frmConsultaVendasPotencial},
  ufrmConsDespesas in 'MaxxCRM\ufrmConsDespesas.pas' {frmConsDespesas},
  ufrmParametros in 'ufrmParametros.pas' {frmParametros},
  ufrmRelEstoqueCiclo in 'ufrmRelEstoqueCiclo.pas' {frmRelEstoqueCiclo},
  ufrmAgenda in 'ufrmAgenda.pas' {frmConsAgenda},
  ufrmRelVisitas in 'ufrmRelVisitas.pas' {frmRelVisitas},
  ufrmCadTransac in 'Cadastros\ufrmCadTransac.pas' {frmCadTransac},
  ufrmFazendasDet in 'ufrmFazendasDet.pas' {frmFazendasDet},
  ufrmCadCiclo in 'ufrmCadCiclo.pas' {frmCadCiclo},
  ufrmConsPedBlq in 'ufrmConsPedBlq.pas' {frmConsPedBlq},
  ufrmVendedorCli in 'ufrmVendedorCli.pas' {frmVendedorCli},
  ufrmVendedorCad in 'ufrmVendedorCad.pas' {frmVendedorCad},
  ufrmMotivoLib in 'ufrmMotivoLib.pas' {frmMotivoLib},
  ufrmCadCondPag in 'ufrmCadCondPag.pas' {frmCadCondPag},
  ufrmCadPeneira in 'ufrmCadPeneira.pas' {frmCadPeneira},
  ufrmCadTratSem in 'ufrmCadTratSem.pas' {frmCadTratSem},
  ufrmCadVariedade in 'ufrmCadVariedade.pas' {frmCadVariedade},
  uEmail in '..\Geral\uEmail.pas',
  ufrmCadTalhaoDet in 'ufrmCadTalhaoDet.pas' {frmCadTalhaoDet},
  ufrmConsultaClassCliente in 'MaxxCRM\ufrmConsultaClassCliente.pas' {frmConsultaClassCliente},
  uCustoProduto in 'uCustoProduto.pas',
  ufrmDetPedido in 'ufrmDetPedido.pas' {frmDetPedido},
  ufrmRelDespesasVendedor in 'ufrmRelDespesasVendedor.pas' {frmRelDespesaAcerto},
  ufrmCadTipoUsuario in 'MaxxCRM\ufrmCadTipoUsuario.pas' {frmCadTipoUsuario},
  ufrmCadPlanejamento in 'MaxxCRM\ufrmCadPlanejamento.pas' {frmCadPlanejamento},
  ufrmConsPlanejamento in 'MaxxCRM\ufrmConsPlanejamento.pas' {frmConsPlanejamento},
  ufrmConsPlanejamentoProduto in 'MaxxCRM\ufrmConsPlanejamentoProduto.pas' {frmConsPlanejamentoProduto},
  ufrmCadPlanejamentoItens in 'MaxxCRM\ufrmCadPlanejamentoItens.pas' {frmCadPlanejamentoItens},
  ufrmCadAnoAgricola in 'MaxxCRM\ufrmCadAnoAgricola.pas' {frmCadAnoAgricola},
  ufrmCadAnoAgricolaCiclo in 'MaxxCRM\ufrmCadAnoAgricolaCiclo.pas' {frmCadAnoAgricolaCiclo},
  ufrmConsPerfilCliente in 'ufrmConsPerfilCliente.pas' {frmConsPerfilCliente},
  ufrmConsultaVendasProdutos in 'MaxxCRM\ufrmConsultaVendasProdutos.pas' {frmConsultaVendasProdutos},
  ufrmConsVisitas in 'ufrmConsVisitas.pas' {frmConsVisitas},
  ufrmGraficoDespesasEmpresa in 'MaxxCRM\ufrmGraficoDespesasEmpresa.pas' {frmGraficoDespesasEmpresa},
  ufrmCadUsuarioEmpresa in 'ufrmCadUsuarioEmpresa.pas' {frmCadUsuarioEmpresa},
  ufrmConsDespesaAcerto in 'ufrmConsDespesaAcerto.pas' {frmConsDespesaAcerto},
  ufrmConsDespesaAcertoIte in 'ufrmConsDespesaAcertoIte.pas' {frmConsDespesaAcertoIte},
  ufrmRelItensTabPreco in 'ufrmRelItensTabPreco.pas' {frmItensTabPreco},
  ufrmPedidoIDet in 'ufrmPedidoIDet.pas' {frmPedidoIDet},
  ufrmAguardeAnt in '..\Geral\ufrmAguardeAnt.pas' {frmAguardeAnt},
  ufrmConsPed in 'MaxxCRM\ufrmConsPed.pas' {frmConsPed},
  ufrmConsVisitaTec in 'ufrmConsVisitaTec.pas' {frmConsVisitaTec},
  ufrmFotoVisTec in 'ufrmFotoVisTec.pas' {frmFotoVisTec},
  ufrmRelProdNCad in 'ufrmRelProdNCad.pas' {frmRelProdNCad};

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
      PastaGPS   := StringReplace(PastaEXE, '\EXE\', '\GPS\', []);
      ArquivoLog := StringReplace(UpperCase(gsAppPath), '\EXE\', '\CFG\MAXX.LOG', []);

      // Identificação do Módulo
      IdSistema := ExtractFileName(Application.ExeName);
      IdSistema := Copy(IdSistema, 1, (Length(Idsistema) - 4));

      Application.Title := 'Gerenciador mobile';
//      CreateMutex(nil, False, PChar(IdSistema));

      { verifica se houve erro na criação }
{      if (GetLastError = ERROR_ALREADY_EXISTS) then
      begin
         TfrmMensagens.Mensagem('O programa já está em execução!' + #13 +
                                'Essa instância será fechada!', 'I', IdSistema, [mbOk]);
         Halt(0);
      end;
 }
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
//            Finaliza o programa
            Application.Terminate;
            Application.Run;
         end;
      end;
   except
      on e: exception do
         Application.MessageBox(pChar(e.message), 'Erro', mb_ok);
   end;
end.
