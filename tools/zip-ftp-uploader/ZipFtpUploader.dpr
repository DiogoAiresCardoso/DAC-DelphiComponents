program ZipFtpUploader;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  System.Classes,
  System.Types,
  System.IOUtils,
  System.IniFiles,
  System.Zip,
  IdFTP,
  IdFTPCommon,
  IdComponent,
  IdGlobal;

type
  EConfigurationError = class(Exception);

procedure ShowUsage;
begin
  Writeln('Usage: ZipFtpUploader.exe --config <file.ini> [--dry-run] [--delete-local-zip]');
  Writeln('');
  Writeln('Creates one ZIP from the configured source folders and uploads it through FTP.');
end;

function RequireValue(const Config: TCustomIniFile; const Section, Key: string): string;
begin
  Result := Trim(Config.ReadString(Section, Key, ''));
  if Result = '' then
    raise EConfigurationError.CreateFmt('Missing required setting [%s] %s.', [Section, Key]);
end;

function SplitSemicolonList(const Value: string): TStringList;
var
  I: Integer;
begin
  Result := TStringList.Create;
  Result.StrictDelimiter := True;
  Result.Delimiter := ';';
  Result.DelimitedText := Value;

  for I := 0 to Result.Count - 1 do
  begin
    Result[I] := Trim(Result[I]);
    if Result[I] = '' then
      raise EConfigurationError.Create('Lists cannot contain empty items.');
  end;
end;

function ArchivePath(const SourceDirectory, FileName: string): string;
var
  RootName, AbsoluteSourceDirectory, AbsoluteFileName, RelativeFileName: string;
begin
  RootName := TPath.GetFileName(ExcludeTrailingPathDelimiter(SourceDirectory));
  if RootName = '' then
    RootName := 'files';
  AbsoluteSourceDirectory := IncludeTrailingPathDelimiter(ExpandFileName(SourceDirectory));
  AbsoluteFileName := ExpandFileName(FileName);
  if SameText(Copy(AbsoluteFileName, 1, Length(AbsoluteSourceDirectory)), AbsoluteSourceDirectory) then
    RelativeFileName := Copy(AbsoluteFileName, Length(AbsoluteSourceDirectory) + 1, MaxInt)
  else
    RelativeFileName := TPath.GetFileName(FileName);
  Result := RootName + '/' + RelativeFileName;
  Result := StringReplace(Result, '\', '/', [rfReplaceAll]);
end;

procedure CollectFiles(const SourceDirectories, Patterns: TStringList;
  const Recursive: Boolean; const Files, ArchiveNames: TStringList);
var
  SourceDirectory, Pattern, FileName, NameInArchive: string;
  SearchOption: TSearchOption;
  Matches: TStringDynArray;
  SeenArchiveNames: TStringList;
begin
  if Recursive then
    SearchOption := TSearchOption.soAllDirectories
  else
    SearchOption := TSearchOption.soTopDirectoryOnly;

  SeenArchiveNames := TStringList.Create;
  try
    SeenArchiveNames.Sorted := True;
    SeenArchiveNames.CaseSensitive := False;
    for SourceDirectory in SourceDirectories do
    begin
      if not TDirectory.Exists(SourceDirectory) then
        raise EConfigurationError.CreateFmt('Source directory does not exist: %s', [SourceDirectory]);

      for Pattern in Patterns do
      begin
        Matches := TDirectory.GetFiles(SourceDirectory, Pattern, SearchOption);
        for FileName in Matches do
        begin
          NameInArchive := ArchivePath(SourceDirectory, FileName);
          if SeenArchiveNames.IndexOf(NameInArchive) >= 0 then
            raise EConfigurationError.CreateFmt('Duplicate entry in ZIP: %s', [NameInArchive]);
          SeenArchiveNames.Add(NameInArchive);
          ArchiveNames.Add(NameInArchive);
          Files.Add(FileName);
        end;
      end;
    end;
  finally
    SeenArchiveNames.Free;
  end;
end;

procedure CreateZip(const ZipFileName: string; const Files, ArchiveNames: TStringList);
var
  Zip: TZipFile;
  I: Integer;
begin
  ForceDirectories(ExtractFileDir(ZipFileName));
  Zip := TZipFile.Create;
  try
    Zip.Open(ZipFileName, TZipMode.zmWrite);
    for I := 0 to Files.Count - 1 do
    begin
      Writeln('Adding: ', Files[I]);
      Zip.Add(Files[I], ArchiveNames[I]);
    end;
    Zip.Close;
  finally
    Zip.Free;
  end;
end;

procedure UploadFtp(const Config: TCustomIniFile; const ZipFileName: string);
var
  Ftp: TIdFTP;
  PasswordEnvironment, Password, RemoteDirectory: string;
begin
  PasswordEnvironment := RequireValue(Config, 'ftp', 'password_env');
  Password := GetEnvironmentVariable(PasswordEnvironment);
  if Password = '' then
    raise EConfigurationError.CreateFmt(
      'The environment variable %s is empty or was not found.', [PasswordEnvironment]);

  Ftp := TIdFTP.Create(nil);
  try
    Ftp.Host := RequireValue(Config, 'ftp', 'host');
    Ftp.Port := Config.ReadInteger('ftp', 'port', 21);
    Ftp.Username := RequireValue(Config, 'ftp', 'username');
    Ftp.Password := Password;
    Ftp.Passive := Config.ReadBool('ftp', 'passive', True);
    Ftp.TransferType := ftBinary;
    Ftp.ConnectTimeout := Config.ReadInteger('ftp', 'connect_timeout_ms', 30000);
    Ftp.ReadTimeout := Config.ReadInteger('ftp', 'read_timeout_ms', 120000);

    Writeln('Connecting to FTP server ', Ftp.Host, ':', Ftp.Port, '...');
    Ftp.Connect;
    try
      RemoteDirectory := Trim(Config.ReadString('ftp', 'remote_dir', ''));
      if RemoteDirectory <> '' then
        Ftp.ChangeDir(RemoteDirectory);

      Writeln('Uploading: ', TPath.GetFileName(ZipFileName));
      Ftp.Put(ZipFileName, TPath.GetFileName(ZipFileName), False);
    finally
      if Ftp.Connected then
        Ftp.Disconnect;
    end;
  finally
    Ftp.Free;
  end;
end;

function GetArgumentValue(const Name: string): string;
var
  I: Integer;
begin
  Result := '';
  for I := 1 to ParamCount - 1 do
    if SameText(ParamStr(I), Name) then
      Exit(ParamStr(I + 1));
end;

function HasArgument(const Name: string): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 1 to ParamCount do
    if SameText(ParamStr(I), Name) then
      Exit(True);
end;

procedure Run;
var
  ConfigFileName, ZipDirectory, ZipName, ZipFileName: string;
  Config: TMemIniFile;
  SourceDirectories, Patterns, Files, ArchiveNames: TStringList;
  Recursive, DryRun, DeleteLocalZip: Boolean;
begin
  if HasArgument('--help') or HasArgument('-h') then
  begin
    ShowUsage;
    Exit;
  end;

  ConfigFileName := GetArgumentValue('--config');
  if ConfigFileName = '' then
    raise EConfigurationError.Create('Use --config <file.ini>.');
  if not TFile.Exists(ConfigFileName) then
    raise EConfigurationError.CreateFmt('Configuration file does not exist: %s', [ConfigFileName]);

  DryRun := HasArgument('--dry-run');
  DeleteLocalZip := HasArgument('--delete-local-zip');
  Config := TMemIniFile.Create(ConfigFileName, TEncoding.UTF8);
  SourceDirectories := nil;
  Patterns := nil;
  Files := nil;
  ArchiveNames := nil;
  try
    SourceDirectories := SplitSemicolonList(RequireValue(Config, 'package', 'source_dirs'));
    Patterns := SplitSemicolonList(Config.ReadString('package', 'include', '*.*'));
    Recursive := Config.ReadBool('package', 'recursive', True);
    ZipDirectory := Config.ReadString('package', 'zip_dir', 'out');
    if not TPath.IsPathRooted(ZipDirectory) then
      ZipDirectory := TPath.Combine(ExtractFileDir(ExpandFileName(ConfigFileName)), ZipDirectory);
    ZipName := Config.ReadString('package', 'zip_name', 'package_{timestamp}.zip');
    ZipName := StringReplace(ZipName, '{timestamp}', FormatDateTime('yyyymmdd_hhnnss', Now), [rfReplaceAll]);
    if not SameText(ExtractFileExt(ZipName), '.zip') then
      ZipName := ZipName + '.zip';
    ZipFileName := TPath.Combine(ZipDirectory, ZipName);

    Files := TStringList.Create;
    ArchiveNames := TStringList.Create;
    CollectFiles(SourceDirectories, Patterns, Recursive, Files, ArchiveNames);
    if Files.Count = 0 then
      raise EConfigurationError.Create('No files matched the configured source_dirs and include patterns.');

    Writeln('Packaging ', Files.Count, ' file(s) into ', ZipFileName);
    CreateZip(ZipFileName, Files, ArchiveNames);
    if DryRun then
      Writeln('Dry run complete. ZIP was created but not uploaded.')
    else
    begin
      UploadFtp(Config, ZipFileName);
      Writeln('Upload completed successfully.');
    end;

    if DeleteLocalZip and not DryRun then
    begin
      TFile.Delete(ZipFileName);
      Writeln('Local ZIP removed: ', ZipFileName);
    end;
  finally
    ArchiveNames.Free;
    Files.Free;
    Patterns.Free;
    SourceDirectories.Free;
    Config.Free;
  end;
end;

begin
  try
    Run;
  except
    on E: Exception do
    begin
      Writeln(ErrOutput, 'ERROR: ', E.Message);
      Halt(1);
    end;
  end;
end.
