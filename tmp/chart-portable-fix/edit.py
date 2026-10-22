from pathlib import Path
root=Path(__file__).resolve().parents[2]
p=root/'demo-charts/DACChartsDemo.Main.pas'
s=p.read_bytes().decode('cp1252').replace('\r\n','\n')
s=s.replace('  private\n    FFixtures:', '  protected\n    function HandleCreateException: Boolean; override;\n  private\n    FFixtures:')
s=s.replace('    FAutomatic: Boolean;', '    FAutomatic: Boolean;\n    FFailed: Boolean;\n    procedure RuntimeException(Sender: TObject; E: Exception);')
s=s.replace('var ChartsDemoForm: TChartsDemoForm;', 'procedure RunChartsDemo;\n\nvar ChartsDemoForm: TChartsDemoForm;')
s=s.replace('  DACChartsDemo.ClientDataSetAdapter;', '  MidasLib, DACChartsDemo.ClientDataSetAdapter;')
anchor='{$R *.dfm}\n'
startup='''

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

procedure RunChartsDemo;
var LibraryPath: string; SkiaModule: HMODULE; Symbol: AnsiString; ErrorCode: DWORD;
begin
  SkiaModule:=0;
  try
    try
      { Resolve the distributed DLL before the first lazy Skia initialization.
        Keep it loaded so Skia cannot resolve a different copy through PATH. }
      LibraryPath:=TPath.Combine(ExtractFilePath(ParamStr(0)),'sk4d.dll');
      if not TFile.Exists(LibraryPath) then
        raise Exception.Create('sk4d.dll nao encontrada ao lado do executavel: '+LibraryPath);
      SkiaModule:=LoadLibraryEx(PChar(LibraryPath),0,LOAD_WITH_ALTERED_SEARCH_PATH);
      if SkiaModule=0 then begin
        ErrorCode:=GetLastError;
        raise Exception.CreateFmt('Falha ao carregar %s (Windows %d: %s). Use a DLL da mesma distribuicao e arquitetura do EXE.',
          [LibraryPath,ErrorCode,SysErrorMessage(ErrorCode)]);
      end;
      for Symbol in TArray<AnsiString>.Create('sk4d_surface_make_raster_direct','sk4d_paint_create','sk4d_canvas_clear') do
        if GetProcAddress(SkiaModule,PAnsiChar(Symbol))=nil then
          raise Exception.Create('sk4d.dll incompativel: funcao ausente '+string(Symbol));
      Application.Initialize;
      Application.MainFormOnTaskbar:=True;
      Application.CreateForm(TChartsDemoForm,ChartsDemoForm);
      Application.OnException:=ChartsDemoForm.RuntimeException;
      Application.Run;
    except on E: Exception do ReportDemoFailure(E); end;
  finally
    Application.OnException:=nil;
    if SkiaModule<>0 then FreeLibrary(SkiaModule);
  end;
end;

function TChartsDemoForm.HandleCreateException: Boolean;
begin
  { The VCL default consumes OnCreate errors and leaves a partial blank form. }
  Result:=False;
end;

procedure TChartsDemoForm.RuntimeException(Sender: TObject; E: Exception);
begin
  if FFailed then Exit;
  FFailed:=True; MetricsTimer.Enabled:=False;
  ReportDemoFailure(E); Application.Terminate;
end;
'''
assert anchor in s
s=s.replace(anchor,anchor+startup)
start=s.index('function TChartsDemoForm.FixturePath: string;')
end=s.index('procedure TChartsDemoForm.FormCreate',start)
s=s[:start]+'''function TChartsDemoForm.FixturePath: string;
begin
  Result:=Arg('--fixtures','');
  if Result<>'' then Result:=ExpandFileName(Result)
  else Result:=TPath.Combine(ExtractFilePath(Application.ExeName),'reference-cases.json');
  if not TFile.Exists(Result) then
    raise Exception.Create('Arquivo de cenarios nao encontrado: '+Result+'. Distribua reference-cases.json junto ao EXE ou use --fixtures caminho.');
end;
'''+s[end:]
s=s.replace('var A: TJSONArray; I: Integer;\nbegin\n  FFixtures:=TJSONObject.ParseJSONValue(TFile.ReadAllText(FixturePath,TEncoding.UTF8)) as TJSONObject;\n  A:=TJSONArray(CJ(FFixtures,\'cases\'));', '''var A: TJSONArray; I: Integer; Parsed,Item: TJSONValue; FileName,Id: string;
  Ids: TStringList;
begin
  FileName:=FixturePath;
  Parsed:=TJSONObject.ParseJSONValue(TFile.ReadAllText(FileName,TEncoding.UTF8));
  if not (Parsed is TJSONObject) then begin
    Parsed.Free;
    raise Exception.Create(FileName+': esperado documento JSON com objeto raiz e array cases');
  end;
  FFixtures:=TJSONObject(Parsed);
  if not (CJ(FFixtures,'cases') is TJSONArray) then
    raise Exception.Create(FileName+': cases deve ser um array');
  A:=TJSONArray(CJ(FFixtures,'cases'));
  if A.Count=0 then raise Exception.Create(FileName+': cases nao pode estar vazio');
  Ids:=TStringList.Create;
  try
    Ids.CaseSensitive:=True;
    for I:=0 to A.Count-1 do begin
      Item:=A.Items[I];
      if not (Item is TJSONObject) or not (CJ(Item,'id') is TJSONString) or
        not (CJ(Item,'title') is TJSONString) or not (CJ(Item,'option') is TJSONObject) then
        raise Exception.CreateFmt('%s: cases[%d] exige id/title textuais e option objeto',[FileName,I]);
      Id:=CS(CJ(Item,'id'));
      if (Id='') or (Ids.IndexOf(Id)>=0) or (Id='.') or (Id='..') or
        (Id.IndexOfAny(TPath.GetInvalidFileNameChars)>=0) then
        raise Exception.CreateFmt('%s: cases[%d].id vazio, repetido ou invalido',[FileName,I]);
      Ids.Add(Id);
      try ValidateChartOptions(TJSONObject(CJ(Item,'option')));
      except on E: Exception do
        raise Exception.CreateFmt('%s: cases[%d] (%s): %s',[FileName,I,Id,E.Message]); end;
    end;
  finally Ids.Free; end;''')
assert 'var A: TJSONArray; I: Integer; Parsed' in s
# A headless startup test must not pretend a window DC was captured.
s=s.replace("      FChart.CaptureWindowPNG(TPath.Combine(OutDir,Id+'-window.png'));", "      if Arg('--buffer-only','')='' then\n        FChart.CaptureWindowPNG(TPath.Combine(OutDir,Id+'-window.png'));")
p.write_bytes(s.replace('\n','\r\n').encode('cp1252'))
for name in ('DACChartsDemo','DACChartsHighDpi','DACChartsNoHighDpi'):
    resource='\n{$R *.res}\n' if name=='DACChartsDemo' else ''
    body=f'''program {name};

uses DACChartsDemo.Main in 'DACChartsDemo.Main.pas' {{ChartsDemoForm}};
{resource}
begin
  RunChartsDemo;
end.
'''
    (root/f'demo-charts/{name}.dpr').write_bytes(body.replace('\n','\r\n').encode('cp1252'))
for name,project in [('demo','DACChartsDemo'),('hidpi','DACChartsHighDpi'),('nodpi','DACChartsNoHighDpi')]:
    template=(root/'tmp/chart-title-spacing/build-demo.cmd').read_text()
    template=template.replace('chart-title-spacing','chart-portable-fix').replace('DACChartsDemo.dproj',project+'.dproj').replace('demo-dcu',name+'-dcu').replace('demo-exe',name+'-exe')
    (root/f'tmp/chart-portable-fix/build-{name}.cmd').write_text(template)
