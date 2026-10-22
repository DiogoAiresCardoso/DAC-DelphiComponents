program MaxxCFiscal;

uses
  Forms,
  Windows,
  ShellApi,
  SysUtils,
  IwSystem,
  IniFiles,
  udmMaxxLocal in '..\..\Geral\udmMaxxLocal.pas' {dmMaxxLocal: TDataModule},
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
  ufrmCadTipoPgto in '..\..\Cadastros\ufrmCadTipoPgto.pas' {frmCadTipoPgto},
  ufrmPrincipal in 'ufrmPrincipal.pas' {frmPrincipal},
  ufrmAterarSenha in '..\..\Geral\ufrmAterarSenha.pas' {frmAterarSenha},
  ufrmMovDocAvulso in 'ufrmMovDocAvulso.pas' {frmMovDocAvulso},
  ufrmMovConsoliDocFiscal in 'ufrmMovConsoliDocFiscal.pas' {frmMovConsoliDocFiscal},
  ufrmConConfeFiscal in 'ufrmConConfeFiscal.pas' {frmConConfeFiscal},
  ufrmCadTipoDoc in '..\..\Cadastros\ufrmCadTipoDoc.pas' {frmCadTipoDoc},
  ufrmConConfeFiscalImp in 'ufrmConConfeFiscalImp.pas' {frmConConfeFiscalImp},
  ufrmRelResumoFiscal in '..\..\Relatorios\ufrmRelResumoFiscal.pas' {frmRelResumoFiscal},
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
  ufrmCadParceiroContatos in '..\..\Cadastros\ufrmCadParceiroContatos.pas' {frmCadParceiroContatos},
  UFSistConsultaCNPJ in '..\..\Geral\UFSistConsultaCNPJ.pas',
  uConsultaCNPJAcBR in '..\..\Geral\uConsultaCNPJAcBR.pas' {frmConsultaCNPJAcBR},
  ufrmCadProdutos in '..\..\Cadastros\ufrmCadProdutos.pas' {frmCadProdutos},
  ufrmCadProdutosForn in '..\..\Cadastros\ufrmCadProdutosForn.pas' {frmCadProdutosForn},
  ufrmCadProdutosLotes in '..\..\Cadastros\ufrmCadProdutosLotes.pas' {frmCadProdutosLotes},
  ufrmCadProdutosLotesAnexos in '..\..\Cadastros\ufrmCadProdutosLotesAnexos.pas' {frmCadProdutosLotesAnexos},
  ufrmCadProdutosLotesSaldo in '..\..\Cadastros\ufrmCadProdutosLotesSaldo.pas' {frmCadProdutosLotesSaldo},
  ufrmConConfeFiscalRegCaixa in 'ufrmConConfeFiscalRegCaixa.pas' {frmConConfeFiscalRegCaixa},
  ufrmConConfeFiscalRegCaixaImp in 'ufrmConConfeFiscalRegCaixaImp.pas' {frmConConfeFiscalRegCaixaImp},
  uPesquisarRel in '..\MaxxRES\uPesquisarRel.pas',
  uConstantes in '..\..\Geral\uConstantes.pas',
  ufrmConConfeFiscalRegCaixaMensal in 'ufrmConConfeFiscalRegCaixaMensal.pas' {frmConConfeFiscalRegCaixaMensal},
  uConsultarEstoqueFisico in '..\..\Geral\uConsultarEstoqueFisico.pas',
  ufrmCadParceiroFazMatricula in '..\..\Cadastros\ufrmCadParceiroFazMatricula.pas' {frmCadParceiroFazMatricula},
  ufrmCadParceiroFazMatriculaHipoteca in '..\..\Cadastros\ufrmCadParceiroFazMatriculaHipoteca.pas' {frmCadParceiroFazMatriculaHipoteca},
  ufrmCadParceiroFazVinculos in '..\..\Cadastros\ufrmCadParceiroFazVinculos.pas' {frmCadParceiroFazVinculos},
  uConsultaCNPJ in '..\..\Geral\uConsultaCNPJ.pas' {frmConsultaCNPJ},
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

      Application.Title := 'Conferência fiscal';

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

