unit DACChartsDemo.Startup;

interface

uses System.SysUtils;

procedure ReportDemoFailure(E: Exception);

implementation

uses Winapi.Windows, System.IOUtils;

var SkiaModule: HMODULE;

procedure ReportDemoFailure(E: Exception);
var I: Integer; OutDir,LogPath,Details: string;
begin
  ExitCode:=1; OutDir:='';
  for I:=1 to ParamCount-1 do if SameText(ParamStr(I),'--out') then OutDir:=ExpandFileName(ParamStr(I+1));
  Details:=E.ClassName+': '+E.Message+sLineBreak+'Executable: '+ParamStr(0)+
    sLineBreak+'Working directory: '+GetCurrentDir;
  if OutDir<>'' then LogPath:=TPath.Combine(OutDir,'error.txt')
  else LogPath:=TPath.Combine(TPath.GetTempPath,'DACChartsDemo-startup-error.txt');
  try
    ForceDirectories(ExtractFilePath(LogPath));
    TFile.WriteAllText(LogPath,Details,TEncoding.UTF8);
  except LogPath:=''; end;
  if OutDir='' then begin
    if LogPath<>'' then Details:=Details+sLineBreak+sLineBreak+'Diagnostico: '+LogPath;
    MessageBox(0,PChar(Details),'DAC Charts - falha na inicializacao',MB_OK or MB_ICONERROR);
  end;
end;

procedure PrepareRuntime;
var LibraryPath: string; Symbol: AnsiString; ErrorCode,OldMode: DWORD;
begin
  LibraryPath:=TPath.Combine(ExtractFilePath(ParamStr(0)),'sk4d.dll');
  if not TFile.Exists(LibraryPath) then
    raise Exception.Create('sk4d.dll nao encontrada ao lado do executavel: '+LibraryPath);
  OldMode:=SetErrorMode(SEM_FAILCRITICALERRORS or SEM_NOOPENFILEERRORBOX);
  try
    SkiaModule:=LoadLibraryEx(PChar(LibraryPath),0,LOAD_WITH_ALTERED_SEARCH_PATH);
    ErrorCode:=GetLastError;
  finally SetErrorMode(OldMode); end;
  if SkiaModule=0 then
    raise Exception.CreateFmt('Falha ao carregar %s (Windows %d: %s). Use a DLL da mesma distribuicao e arquitetura do EXE.',
      [LibraryPath,ErrorCode,SysErrorMessage(ErrorCode)]);
  for Symbol in TArray<AnsiString>.Create('sk4d_surface_make_raster_direct','sk4d_paint_create','sk4d_canvas_clear',
    'sk4d_streamadapter_set_procs','sk4d_wstreamadapter_set_procs') do
    if GetProcAddress(SkiaModule,PAnsiChar(Symbol))=nil then
      raise Exception.Create('sk4d.dll incompativel: funcao ausente '+string(Symbol));
end;

initialization
  { This unit MUST precede Main/Skia in every DPR. Skia class constructors can
    run during unit initialization, before the program's begin/except block. }
  try PrepareRuntime;
  except on E: Exception do begin ReportDemoFailure(E); Halt(1); end; end;
finalization
  if SkiaModule<>0 then FreeLibrary(SkiaModule);
end.
