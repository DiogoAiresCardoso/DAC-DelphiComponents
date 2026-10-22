program MaxxBarter;

uses
  ExceptionLog,
  Forms,
  Windows,
  ShellApi,
  SysUtils,
  IwSystem,
  IniFiles,
  udmMaxxLocal in '..\..\Geral\udmMaxxLocal.pas' {dmMaxxLocal: TDataModule},
  ufrmAguarde in '..\..\Geral\ufrmAguarde.pas' {frmAguarde},
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
  ufrmSobre in '..\..\Geral\ufrmSobre.pas' {frmSobre},
  uLib in '..\..\Geral\uLib.pas',
  uMensagens in '..\..\Geral\uMensagens.pas' {frmMensagens},
  uModulos in '..\..\Geral\uModulos.pas',
  uRecError in '..\..\Geral\uRecError.pas' {ReconcileErrorForm},
  ufrmPrincipal in 'ufrmPrincipal.pas' {frmPrincipal},
  ufrmInformacoes in '..\..\Geral\ufrmInformacoes.pas' {frmInformacoes},
  ufrmAterarSenha in '..\..\Geral\ufrmAterarSenha.pas' {frmAterarSenha},
  ufrmProtecSYS in '..\..\Geral\ufrmProtecSYS.pas' {frmProtecSYS},
  Base64 in '..\..\Geral\Base64.pas',
  DCPconst in '..\..\Geral\DCPconst.pas',
  DCPcrypt in '..\..\Geral\DCPcrypt.pas',
  IDEA in '..\..\Geral\IDEA.pas',
  Md5 in '..\..\Geral\Md5.pas',
  Sha1 in '..\..\Geral\Sha1.pas',
  U_Cipher in '..\..\Geral\U_Cipher.pas',
  ufrmProtecao in '..\..\Geral\ufrmProtecao.pas' {frmProtecao},
  ufrmConsPosEstoque in '..\MaxxCOM\ufrmConsPosEstoque.pas' {frmConsPosEstoque},
  ufrmCadProdutosBarter in 'ufrmCadProdutosBarter.pas' {frmCadProdutosBarter};

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

      Application.Title := 'Barter';
      CreateMutex(nil, False, PChar(IdSistema));

      { verifica se houve erro na criação }
      if (GetLastError = ERROR_ALREADY_EXISTS) then
      begin
         TfrmMensagens.Mensagem('O programa já está em execução!' + #13 +
                                'Essa instância será fechada!', 'I', IdSistema, [mbOk]);
         Halt(0);
      end;


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
         if (not dmMaxxLocal.cdsVerificarPermissoes.IsEmpty) and (dmMaxxLocal.dbConn.Connected) then
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
