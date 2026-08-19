program MaxxRuralUpdatePackager;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  System.Classes,
  System.Types,
  System.IOUtils,
  System.IniFiles,
  System.Zip,
  System.RegularExpressions,
  IdFTP,
  IdFTPCommon,
  uMaxxRuralUpdateConsole;

type
  EEmpacotamento = class(Exception);

function Obrigatorio(const Config: TCustomIniFile; const Secao, Chave: string): string;
begin
  Result := Trim(Config.ReadString(Secao, Chave, ''));
  if Result = '' then
    raise EEmpacotamento.CreateFmt('Configuração obrigatória ausente: [%s] %s.', [Secao, Chave]);
end;

procedure RegistrarLog(const Log: TStrings; const Mensagem: string);
begin
  Log.Add(FormatDateTime('yyyy-mm-dd hh:nn:ss.zzz', Now) + ' | ' + Mensagem);
end;

procedure RegistrarEtapa(const Log: TStrings; const Progresso: TConsoleProgress;
  const Mensagem: string);
begin
  RegistrarLog(Log, Mensagem);
  Progresso.Exibir(Mensagem);
end;

function LerBooleano(const Config: TCustomIniFile; const Secao, Chave: string;
  const Padrao: Boolean): Boolean;
var
  Valor: string;
begin
  Valor := LowerCase(Trim(Config.ReadString(Secao, Chave, '')));
  if Valor = '' then
    Exit(Padrao);
  if (Valor = 'true') or (Valor = '1') or (Valor = 'sim') or (Valor = 'yes') then
    Exit(True);
  if (Valor = 'false') or (Valor = '0') or (Valor = 'nao') or (Valor = 'não') or
     (Valor = 'no') then
    Exit(False);
  raise EEmpacotamento.CreateFmt('Valor booleano inválido em [%s] %s: %s.',
    [Secao, Chave, Valor]);
end;

function CaminhoArquivoNoZip(const PastaBase, NomeArquivo: string): string;
var
  BaseAbsoluta, ArquivoAbsoluto, Relativo: string;
begin
  BaseAbsoluta := IncludeTrailingPathDelimiter(ExpandFileName(PastaBase));
  ArquivoAbsoluto := ExpandFileName(NomeArquivo);
  if not SameText(Copy(ArquivoAbsoluto, 1, Length(BaseAbsoluta)), BaseAbsoluta) then
    raise EEmpacotamento.CreateFmt('Arquivo fora da pasta configurada: %s', [NomeArquivo]);

  Relativo := Copy(ArquivoAbsoluto, Length(BaseAbsoluta) + 1, MaxInt);
  Result := StringReplace(Relativo, '\', '/', [rfReplaceAll]);
end;

function LerVersao(const ArquivoConstantes, NomeConstante: string): string;
var
  Texto: string;
  Correspondencia: TMatch;
begin
  if not TFile.Exists(ArquivoConstantes) then
    raise EEmpacotamento.CreateFmt('Arquivo de constantes não encontrado: %s', [ArquivoConstantes]);

  Texto := TFile.ReadAllText(ArquivoConstantes, TEncoding.Default);
  Correspondencia := TRegEx.Match(Texto,
    '(?im)^\s*' + TRegEx.Escape(NomeConstante) + '\s*=\s*''([^'']+)''\s*;');
  if not Correspondencia.Success then
    raise EEmpacotamento.CreateFmt('Constante %s não encontrada em %s.', [NomeConstante, ArquivoConstantes]);

  Result := Trim(Correspondencia.Groups[1].Value);
  if Result = '' then
    raise EEmpacotamento.CreateFmt('Constante %s está vazia.', [NomeConstante]);
end;

procedure ExigirDestinoLivre(const Arquivo: string; const Sobrescrever: Boolean);
begin
  if TFile.Exists(Arquivo) and not Sobrescrever then
    raise EEmpacotamento.CreateFmt(
      'O arquivo de destino já existe: %s. Use --sobrescrever para substituí-lo.', [Arquivo]);
end;

procedure CriarZipRelatorios(const PastaRelatorios, ArquivoZip: string;
  const Sobrescrever: Boolean);
var
  Arquivos: TStringDynArray;
  Arquivo: string;
  Zip: TZipFile;
begin
  if not TDirectory.Exists(PastaRelatorios) then
    raise EEmpacotamento.CreateFmt('Pasta de relatórios não encontrada: %s', [PastaRelatorios]);

  ExigirDestinoLivre(ArquivoZip, Sobrescrever);
  Arquivos := TDirectory.GetFiles(PastaRelatorios, '*.fr3', TSearchOption.soAllDirectories);
  if Length(Arquivos) = 0 then
    raise EEmpacotamento.Create('Nenhum arquivo .fr3 foi encontrado na pasta de relatórios.');

  Writeln('Gerando Relatorios.zip com ', Length(Arquivos), ' arquivo(s)...');
  Zip := TZipFile.Create;
  try
    Zip.Open(ArquivoZip, TZipMode.zmWrite);
    for Arquivo in Arquivos do
      Zip.Add(Arquivo, CaminhoArquivoNoZip(PastaRelatorios, Arquivo));
    Zip.Close;
  finally
    Zip.Free;
  end;
end;

function SepararLista(const Valor: string): TStringList;
var
  I: Integer;
begin
  Result := TStringList.Create;
  Result.StrictDelimiter := True;
  Result.Delimiter := ';';
  Result.DelimitedText := Valor;
  for I := 0 to Result.Count - 1 do
  begin
    Result[I] := Trim(Result[I]);
    if Result[I] = '' then
      raise EEmpacotamento.Create('A lista de executáveis contém um item vazio.');
  end;
end;

function SepararDiretoriosFtp(const Caminho: string): TStringList;
var
  I: Integer;
begin
  Result := TStringList.Create;
  Result.StrictDelimiter := True;
  Result.Delimiter := '/';
  Result.DelimitedText := StringReplace(Trim(Caminho), '\', '/', [rfReplaceAll]);
  for I := Result.Count - 1 downto 0 do
  begin
    Result[I] := Trim(Result[I]);
    if (Result[I] = '') or (Result[I] = '.') then
      Result.Delete(I);
  end;
end;

function DiretorioAtualEh(const CaminhoAtual, Diretorio: string): Boolean;
var
  Atual, Alvo: string;
begin
  Atual := Trim(StringReplace(CaminhoAtual, '\', '/', [rfReplaceAll]));
  Alvo := Trim(StringReplace(Diretorio, '\', '/', [rfReplaceAll]));
  while (Atual <> '') and (Atual[1] = '/') do
    Delete(Atual, 1, 1);
  while (Atual <> '') and (Atual[Length(Atual)] = '/') do
    Delete(Atual, Length(Atual), 1);
  while (Alvo <> '') and (Alvo[1] = '/') do
    Delete(Alvo, 1, 1);
  while (Alvo <> '') and (Alvo[Length(Alvo)] = '/') do
    Delete(Alvo, Length(Alvo), 1);
  Result := SameText(Atual, Alvo);
  if Result or (Alvo = '') or (Length(Atual) <= Length(Alvo)) then
    Exit;
  Result := SameText(Copy(Atual, Length(Atual) - Length(Alvo) + 1, MaxInt), Alvo) and
    (Atual[Length(Atual) - Length(Alvo)] = '/');
end;

procedure RegistrarConteudoDiretorio(const Ftp: TIdFTP; const Log: TStrings;
  const Progresso: TConsoleProgress);
var
  Listagem: TStringList;
  I, QuantidadeParaLog: Integer;
begin
  Listagem := TStringList.Create;
  try
    RegistrarEtapa(Log, Progresso, 'Listando diretório remoto atual.');
    Ftp.List(Listagem, '', False);
    RegistrarLog(Log, Format('Diretório remoto localizado com %d item(ns).', [Listagem.Count]));
    Progresso.Exibir(Format('Diretório remoto localizado com %d item(ns).', [Listagem.Count]));
    QuantidadeParaLog := Listagem.Count;
    if QuantidadeParaLog > 100 then
      QuantidadeParaLog := 100;
    for I := 0 to QuantidadeParaLog - 1 do
      RegistrarLog(Log, 'Item remoto: ' + Listagem[I]);
    if Listagem.Count > QuantidadeParaLog then
      RegistrarLog(Log, Format('Listagem limitada aos primeiros %d itens.', [QuantidadeParaLog]));
  finally
    Listagem.Free;
  end;
end;

procedure CriarPacoteVersao(const PastaExe, ArquivoRelatorios, ArquivoPacote: string;
  const Executaveis: TStringList; const Sobrescrever: Boolean);
var
  Zip: TZipFile;
  Executavel, CaminhoExecutavel: string;
begin
  if not TDirectory.Exists(PastaExe) then
    raise EEmpacotamento.CreateFmt('Pasta de executáveis não encontrada: %s', [PastaExe]);
  ExigirDestinoLivre(ArquivoPacote, Sobrescrever);

  Zip := TZipFile.Create;
  try
    Zip.Open(ArquivoPacote, TZipMode.zmWrite);
    Zip.Add(ArquivoRelatorios, 'Relatorios.zip');
    for Executavel in Executaveis do
    begin
      CaminhoExecutavel := TPath.Combine(PastaExe, Executavel);
      if not TFile.Exists(CaminhoExecutavel) then
        raise EEmpacotamento.CreateFmt('Executável obrigatório não encontrado: %s', [CaminhoExecutavel]);
      Writeln('Incluindo: ', Executavel);
      Zip.Add(CaminhoExecutavel, Executavel);
    end;
    Zip.Close;
  finally
    Zip.Free;
  end;
end;

procedure EnviarFtpSeHabilitado(const Config: TCustomIniFile; const ArquivoPacote: string;
  const Log: TStrings; const Progresso: TConsoleProgress; const ApenasDiagnostico: Boolean);
var
  Ftp: TIdFTP;
  Senha, VariavelSenha, PastaRemota, PastaInicial: string;
  Diretorios: TStringList;
  I: Integer;
begin
  if not LerBooleano(Config, 'ftp', 'enabled', False) then
  begin
    RegistrarEtapa(Log, Progresso, 'FTP desabilitado na configuração.');
    Writeln('FTP desabilitado na configuração. Pacote não enviado.');
    Exit;
  end;

  VariavelSenha := Obrigatorio(Config, 'ftp', 'password_env');
  Senha := GetEnvironmentVariable(VariavelSenha);
  if Senha = '' then
    raise EEmpacotamento.CreateFmt('A variável de ambiente %s não foi definida.', [VariavelSenha]);

  Ftp := TIdFTP.Create(nil);
  Diretorios := nil;
  try
    Ftp.Host := Obrigatorio(Config, 'ftp', 'host');
    Ftp.Port := Config.ReadInteger('ftp', 'port', 21);
    Ftp.Username := Obrigatorio(Config, 'ftp', 'username');
    Ftp.Password := Senha;
    Ftp.Passive := LerBooleano(Config, 'ftp', 'passive', True);
    Ftp.TransferType := ftBinary;
    Ftp.ConnectTimeout := Config.ReadInteger('ftp', 'connect_timeout_ms', 30000);
    Ftp.ReadTimeout := Config.ReadInteger('ftp', 'read_timeout_ms', 120000);
    Ftp.OnStatus := Progresso.Status;
    Ftp.OnWorkBegin := Progresso.WorkBegin;
    Ftp.OnWork := Progresso.Work;
    Ftp.OnWorkEnd := Progresso.WorkEnd;
    RegistrarEtapa(Log, Progresso, Format('Conectando ao FTP %s:%d (passivo=%s).',
      [Ftp.Host, Ftp.Port, BoolToStr(Ftp.Passive, True)]));
    Ftp.Connect;
    RegistrarEtapa(Log, Progresso, 'Conexão e autenticação FTP concluídas.');
      RegistrarEtapa(Log, Progresso, 'Diretório inicial informado pelo servidor: ' + Ftp.RetrieveCurrentDir);
      PastaInicial := Trim(Config.ReadString('ftp', 'start_dir', 'www'));
      if PastaInicial <> '' then
      begin
        if DiretorioAtualEh(Ftp.RetrieveCurrentDir, PastaInicial) then
          RegistrarEtapa(Log, Progresso, 'Diretório inicial já selecionado pelo servidor: ' + Ftp.RetrieveCurrentDir)
        else
        begin
          RegistrarEtapa(Log, Progresso, 'Navegando para o diretório inicial: ' + PastaInicial);
          Ftp.ChangeDir(PastaInicial);
          RegistrarEtapa(Log, Progresso, 'Diretório inicial confirmado: ' + Ftp.RetrieveCurrentDir);
        end;
        RegistrarConteudoDiretorio(Ftp, Log, Progresso);
      end;

      PastaRemota := Trim(Config.ReadString('ftp', 'remote_dir', ''));
      Diretorios := SepararDiretoriosFtp(PastaRemota);
      for I := 0 to Diretorios.Count - 1 do
      begin
        if SameText(Diretorios[I], PastaInicial) then
          Continue;
        RegistrarEtapa(Log, Progresso, 'Navegando para o próximo diretório: ' + Diretorios[I]);
        Ftp.ChangeDir(Diretorios[I]);
        RegistrarEtapa(Log, Progresso, 'Diretório confirmado pelo servidor: ' + Ftp.RetrieveCurrentDir);
        RegistrarConteudoDiretorio(Ftp, Log, Progresso);
      end;

    if ApenasDiagnostico then
    begin
      RegistrarEtapa(Log, Progresso, 'Diagnóstico FTP concluído. Nenhum arquivo foi enviado.');
      Writeln('Diagnóstico FTP concluído. Nenhum arquivo foi enviado.');
      Exit;
    end;

    Writeln('Enviando via FTP: ', TPath.GetFileName(ArquivoPacote));
    RegistrarEtapa(Log, Progresso, 'Enviando arquivo: ' + TPath.GetFileName(ArquivoPacote));
    Ftp.Put(ArquivoPacote, TPath.GetFileName(ArquivoPacote), False);
    RegistrarEtapa(Log, Progresso, 'Envio FTP concluído sem erro pelo servidor.');
    finally
      if Ftp.Connected then
      begin
        RegistrarEtapa(Log, Progresso, 'Encerrando conexão FTP.');
        Ftp.Disconnect;
      end;
    Diretorios.Free;
    Ftp.Free;
  end;
end;

function TemParametro(const Nome: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 1 to ParamCount do
    if SameText(ParamStr(I), Nome) then
      Exit(True);
end;

function ValorParametro(const Nome: string): string;
var
  I: Integer;
begin
  Result := '';
  for I := 1 to ParamCount - 1 do
    if SameText(ParamStr(I), Nome) then
      Exit(ParamStr(I + 1));
end;

procedure Executar;
var
  ArquivoConfig, PastaSaida, Versao, NomePacote, ArquivoRelatorios, ArquivoPacote: string;
  ArquivoLog: string;
  Config: TMemIniFile;
  Executaveis, Log: TStringList;
  Progresso: TConsoleProgress;
  Sobrescrever, ExcluirZipRelatorios, ApenasDiagnostico: Boolean;
begin
  ArquivoLog := TPath.Combine(ExtractFilePath(ExpandFileName(ParamStr(0))),
    'MaxxRuralUpdatePackager.log');
  Log := TStringList.Create;
  Progresso := TConsoleProgress.Create;
  RegistrarLog(Log, 'Início do empacotador MaxxRural.');
  ArquivoConfig := ValorParametro('--config');
  if ArquivoConfig = '' then
    ArquivoConfig := TPath.Combine(ExtractFileDir(ExpandFileName(ParamStr(0))),
      'maxxrural-update.ini');
  if not TFile.Exists(ArquivoConfig) then
    raise EEmpacotamento.CreateFmt('Arquivo de configuração não encontrado: %s', [ArquivoConfig]);

  Sobrescrever := TemParametro('--sobrescrever');
  ApenasDiagnostico := TemParametro('--diagnostico');
  Config := TMemIniFile.Create(ArquivoConfig, TEncoding.UTF8);
  Executaveis := nil;
  try
    RegistrarLog(Log, 'Configuração carregada: ' + ArquivoConfig);
    RegistrarLog(Log, 'Valor FTP enabled: ' + Config.ReadString('ftp', 'enabled', '<ausente>'));
    if ApenasDiagnostico then
    begin
      RegistrarLog(Log, 'Modo diagnóstico solicitado; empacotamento e upload serão ignorados.');
      EnviarFtpSeHabilitado(Config, '', Log, Progresso, True);
      Exit;
    end;
    PastaSaida := Obrigatorio(Config, 'package', 'output_dir');
    ForceDirectories(PastaSaida);
    Versao := LerVersao(Obrigatorio(Config, 'package', 'version_source'),
      Config.ReadString('package', 'version_constant', 'VERSAO'));
    NomePacote := StringReplace(Config.ReadString('package', 'archive_name', '{version}.zip'),
      '{version}', Versao, [rfReplaceAll]);
    if not SameText(ExtractFileExt(NomePacote), '.zip') then
      NomePacote := NomePacote + '.zip';

    ArquivoRelatorios := TPath.Combine(PastaSaida, Config.ReadString('reports', 'archive_name', 'Relatorios.zip'));
    ArquivoPacote := TPath.Combine(PastaSaida, NomePacote);
    Executaveis := SepararLista(Obrigatorio(Config, 'executables', 'files'));
    ExcluirZipRelatorios := LerBooleano(Config, 'reports', 'delete_after_packaging', True);

    ExigirDestinoLivre(ArquivoRelatorios, Sobrescrever);
    ExigirDestinoLivre(ArquivoPacote, Sobrescrever);

    Writeln('Versão encontrada: ', Versao);
    RegistrarLog(Log, 'Versão localizada em uConstantes: ' + Versao);
    CriarZipRelatorios(Obrigatorio(Config, 'reports', 'source_dir'), ArquivoRelatorios, Sobrescrever);
    CriarPacoteVersao(Obrigatorio(Config, 'executables', 'source_dir'), ArquivoRelatorios,
      ArquivoPacote, Executaveis, Sobrescrever);
    Writeln('Pacote gerado: ', ArquivoPacote);
    RegistrarLog(Log, 'Pacote local gerado: ' + ArquivoPacote);
    if ExcluirZipRelatorios then
    begin
      TFile.Delete(ArquivoRelatorios);
      Writeln('Arquivo intermediário removido: ', ArquivoRelatorios);
    end;
    EnviarFtpSeHabilitado(Config, ArquivoPacote, Log, Progresso, False);
    RegistrarLog(Log, 'Processo concluído com sucesso.');
  finally
    Log.SaveToFile(ArquivoLog, TEncoding.UTF8);
    Progresso.Free;
    Log.Free;
    Executaveis.Free;
    Config.Free;
  end;
end;

begin
  try
    Executar;
  except
    on E: Exception do
    begin
      Writeln(ErrOutput, 'ERRO: ', E.Message);
      Halt(1);
    end;
  end;
end.
