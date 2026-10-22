from pathlib import Path
root=Path(__file__).resolve().parents[2]
def read(p): return p.read_bytes().decode('cp1252').replace('\r\n','\n')
def write(p,s): p.write_bytes(s.replace('\n','\r\n').encode('cp1252'))
p=root/'demo-charts/DACChartsDemo.Main.pas'
s=read(p)
a=s.index('procedure ReportDemoFailure(E: Exception);')
b=s.index('function TChartsDemoForm.HandleCreateException:',a)
report=s[a:s.index('procedure RunChartsDemo;',a)]
write(root/'demo-charts/DACChartsDemo.Startup.pas','''unit DACChartsDemo.Startup;

interface

uses System.SysUtils;

procedure ReportDemoFailure(E: Exception);

implementation

uses Winapi.Windows, System.IOUtils;

var SkiaModule: HMODULE;

'''+report+'''procedure PrepareRuntime;
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
''')
s=s[:a]+'''procedure RunChartsDemo;
begin
  try
    try
      Application.Initialize;
      Application.MainFormOnTaskbar:=True;
      Application.CreateForm(TChartsDemoForm,ChartsDemoForm);
      Application.OnException:=ChartsDemoForm.RuntimeException;
      Application.Run;
    except on E: Exception do ReportDemoFailure(E); end;
  finally Application.OnException:=nil; end;
end;

'''+s[b:]
s=s.replace('  MidasLib, DACChartsDemo.ClientDataSetAdapter;', '  MidasLib, DACChartsDemo.Startup, DACChartsDemo.ClientDataSetAdapter;')
write(p,s)
for name in ('DACChartsDemo','DACChartsHighDpi','DACChartsNoHighDpi'):
    p=root/f'demo-charts/{name}.dpr'
    s=read(p).replace("uses DACChartsDemo.Main", "uses DACChartsDemo.Startup in 'DACChartsDemo.Startup.pas',\n  DACChartsDemo.Main")
    write(p,s)
    p=root/f'demo-charts/{name}.dproj'
    s=p.read_text(encoding='utf-8-sig')
    s=s.replace('    <DCCReference Include="DACChartsDemo.Main.pas">', '    <DCCReference Include="DACChartsDemo.Startup.pas"/>\n    <DCCReference Include="DACChartsDemo.Main.pas">')
    p.write_bytes(s.replace('\n','\r\n').encode('utf-8'))
