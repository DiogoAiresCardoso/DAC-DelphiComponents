program MaxxAGRO;

uses
  Vcl.Forms,
  ShellApi,
  SysUtils,
  IwSystem,
  IniFiles,
  Windows,
  ufrmPrincipal in 'ufrmPrincipal.pas' {frmPrincipal},
  Base64 in '..\Base64.pas',
  DCPconst in '..\DCPconst.pas',
  DCPcrypt in '..\DCPcrypt.pas',
  IDEA in '..\IDEA.pas',
  Md5 in '..\Md5.pas',
  Sha1 in '..\Sha1.pas',
  U_Cipher in '..\U_Cipher.pas',
  udmMaxxLocal in '..\udmMaxxLocal.pas' {dmMaxxLocal: TDataModule},
  uLib in '..\uLib.pas',
  ufrmAguarde in '..\..\Geral\ufrmAguarde.pas' {frmAguarde},
  ufrmMaster in '..\..\Geral\ufrmMaster.pas' {frmMaster},
  uMensagens in '..\..\Geral\uMensagens.pas' {frmMensagens},
  uPlacaVeiculo in '..\..\Geral\uPlacaVeiculo.pas',
  ufrmMasterCad in '..\ufrmMasterCad.pas' {frmMasterCad},
  ufrmMasterDet in '..\ufrmMasterDet.pas' {frmMasterDet},
  ufrmMasterPes in '..\ufrmMasterPes.pas' {frmMasterPes},
  ufrmMasterRel in '..\ufrmMasterRel.pas' {frmMasterRel},
  uModulos in '..\uModulos.pas',
  uRecError in '..\uRecError.pas' {ReconcileErrorForm},
  ufrmFazendasDet in '..\ufrmFazendasDet.pas' {frmFazendasDet},
  ufrmVendedorCli in '..\ufrmVendedorCli.pas' {frmVendedorCli},
  ufrmConsultaClassCliente in '..\MaxxCRM\ufrmConsultaClassCliente.pas' {frmConsultaClassCliente},
  ufrmMasterConsulta in '..\ufrmMasterConsulta.pas' {frmMasterConsulta},
  ufrmCadUsuario in '..\ufrmCadUsuario.pas' {frmCadUsuario},
  ufrmFerPermissoes in '..\ufrmFerPermissoes.pas' {frmFerPermissoes},
  ufrmAgenda in '..\ufrmAgenda.pas' {frmConsAgenda},
  ufrmAgendaDet in '..\ufrmAgendaDet.pas' {frmAgendaDet},
  ufrmCadAtividade in '..\ufrmCadAtividade.pas' {frmCadAtividade},
  ufrmCadAtividadeOpe in '..\ufrmCadAtividadeOpe.pas' {frmCadAtividadeOpe},
  ufrmCadCiclo in '..\ufrmCadCiclo.pas' {frmCadCiclo},
  ufrmCadCulturas in '..\ufrmCadCulturas.pas' {frmCadCulturas},
  ufrmCadTalhaoDet in '..\ufrmCadTalhaoDet.pas' {frmCadTalhaoDet},
  ufrmCadTipoDesp in '..\ufrmCadTipoDesp.pas' {frmCadTipoDesp},
  ufrmCadVendedor in '..\ufrmCadVendedor.pas' {frmCadVendedor},
  ufrmConsVisitas in '..\ufrmConsVisitas.pas' {frmConsVisitas},
  ufrmConsVisitaTec in '..\ufrmConsVisitaTec.pas' {frmConsVisitaTec},
  ufrmConsVisitaTecDetalhes in '..\ufrmConsVisitaTecDetalhes.pas' {frmConsVisitaTecDetalhes},
  ufrmConsTipoOper in '..\ufrmConsTipoOper.pas' {frmConsTipoOper},
  ufrmConsVisitaTecDetalhesFotoZoom in '..\ufrmConsVisitaTecDetalhesFotoZoom.pas' {frmConsVisitaTecDetalhesFotoZoom},
  ufrmCadTransac in '..\Cadastros\ufrmCadTransac.pas' {frmCadTransac},
  ufrmVendedorCad in '..\ufrmVendedorCad.pas' {frmVendedorCad},
  ufrmConsDespesas in '..\MaxxCRM\ufrmConsDespesas.pas' {frmConsDespesas},
  ufrmConsultaDespesas in '..\MaxxCRM\ufrmConsultaDespesas.pas' {frmConsultaDespesas},
  ufrmParametros in '..\ufrmParametros.pas' {frmParametros},
  ufrmPosVendedor in '..\ufrmPosVendedor.pas' {frmPosVendedor},
  ufrmRelKMVendedores in '..\ufrmRelKMVendedores.pas' {frmRelKMVendedores},
  ufrmRelVisitas in '..\ufrmRelVisitas.pas' {frmRelVisitas},
  ufrmRelDespesas in '..\Relatorios\ufrmRelDespesas.pas' {frmRelDespesas},
  ufrmRelVisitasXDespesas in '..\Relatorios\ufrmRelVisitasXDespesas.pas' {frmRelVisitasXDespesas},
  ufrmMovAgenda in '..\ufrmMovAgenda.pas' {frmMovAgenda};

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

      Application.Title := 'MaxxAGRO';
//      CreateMutex(nil, False, PChar(IdSistema));

      { verifica se houve erro na criação }
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
