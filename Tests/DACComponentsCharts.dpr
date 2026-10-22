program DACComponentsCharts;
{$APPTYPE CONSOLE}
uses System.Classes, System.SysUtils, System.IOUtils, System.JSON,
  System.Math, System.Types, System.Variants, Winapi.Windows, Winapi.Messages,
  Vcl.Forms, Vcl.Controls, Data.DB, Datasnap.DBClient,
  DAC.Components.Charts.Options, DACComponentsCharts.TypesTests,
  DAC.Components.Charts.Engine, DAC.Components.Charts.Surface,
  DAC.Components.Controls.Charts in '..\Source\Controls\DAC.Components.Controls.Charts.pas',
  DACComponentsCharts.ClientDataSetAdapter in 'DACComponentsCharts.ClientDataSetAdapter.pas';

type
  TChartAccess = class(TDACChart)
  public
    procedure RecreateForTest;
  end;
procedure TChartAccess.RecreateForTest;
begin RecreateWnd; end;

procedure Require(B: Boolean; const S: string);
begin if not B then raise Exception.Create(S); end;
procedure Near(A,B: Double; const S: string);
begin Require(Abs(A-B)<0.5,S+Format(' %.4f <> %.4f',[A,B])); end;

procedure TestTitleSpacing(const Output: string);
const Titles: array[0..5] of string = (
  '{"text":"Titulo configuravel"}',
  '{"text":"Titulo grande\nSegunda linha","textStyle":{"fontSize":28},"subtext":"Subtitulo\nMais detalhes","subtextStyle":{"fontSize":16}}',
  '{"text":"{large|Titulo}","textStyle":{"rich":{"large":{"fontSize":42,"padding":3}}}}',
  '{"subtext":"Apenas subtitulo"}',
  '{"text":"Oculto","show":false}',
  '{"text":""}');
var Engine: TDACChartEngine; Surface: TDACChartSurface; Evidence: TJSONValue;
  Texts: TJSONArray; I,J,DPI,W: Integer; Scale,Bottom,PlotTop: Double; Prefix: string;
begin
  Engine:=TDACChartEngine.Create; Surface:=TDACChartSurface.Create;
  try
    for DPI in TArray<Integer>.Create(96,120,144,192) do
      for W in TArray<Integer>.Create(320,720,1280) do
        for I:=0 to High(Titles) do begin
          Scale:=DPI/96;
          Engine.Configure('{"animation":false,"title":'+Titles[I]+
            ',"grid":{"top":40},"xAxis":{"type":"category","data":["A"],"axisLabel":{"show":false}},'+
            '"yAxis":{"min":0,"max":40,"axisLabel":{"show":false}},"series":[{"type":"bar","data":[40]}]}');
          Engine.Render(Surface,Round(W*Scale),Round(Max(240,W*420/720)*Scale),DPI,PointF(-1,-1));
          PlotTop:=Engine.Marks[0].Y;
          Evidence:=TJSONObject.ParseJSONValue(Engine.GeometryJSON);
          try
            Texts:=TJSONArray(CJ(Evidence,'texts')); Bottom:=0;
            for J:=0 to Texts.Count-1 do
              Bottom:=Max(Bottom,CN(CJ(Texts.Items[J],'y'))+CN(CJ(Texts.Items[J],'height')));
            Prefix:=Format('title-%d-%d-%d',[I,DPI,W]);
            if I<4 then begin
              Require(Texts.Count>0,Prefix+': titulo ausente');
              Require(PlotTop>=Bottom+12*Scale-0.5,Prefix+': grafico invade espaco do titulo');
            end else Near(PlotTop,40*Scale,Prefix+': titulo vazio/oculto reservou espaco');
            if W=720 then Surface.SavePNG(TPath.Combine(Output,Prefix+'.png'));
          finally Evidence.Free; end;
          { Removing the title on the same engine must restore the original grid. }
          Engine.Configure('{"animation":false,"grid":{"top":40},"xAxis":{"data":["A"]},'+
            '"yAxis":{"min":0,"max":40},"series":[{"type":"bar","data":[40]}]}');
          Engine.Render(Surface,Round(W*Scale),Round(Max(240,W*420/720)*Scale),DPI,PointF(-1,-1));
          Near(Engine.Marks[0].Y,40*Scale,'Remover titulo deve restaurar margem');
        end;
    Engine.Configure('{"animation":false,"title":{"text":"Titulo"},"grid":{"top":120},'+
      '"xAxis":{"data":["A"]},"yAxis":{"min":0,"max":40},"series":[{"type":"bar","data":[40]}]}');
    Engine.Render(Surface,720,420,96,PointF(-1,-1));
    Near(Engine.Marks[0].Y,120,'Margem maior deve ser preservada');
    Writeln('Title spacing: native metrics, multiline, subtitle, rich text, hidden/empty, resize and four DPIs OK');
  finally Surface.Free; Engine.Free; end;
end;

procedure TestWindowLifecycle(const Output: string);
var Host: TForm; Chart: TDACChart; DPI,I,J: Integer; First,Second: TBytes;
  Start: Cardinal; BaseGDI: DWORD;
begin
  Host:=TForm.Create(nil);
  try
    Host.ClientWidth:=900; Host.ClientHeight:=620;
    Chart:=TDACChart.Create(Host); Chart.Parent:=Host; Chart.SetBounds(0,0,720,420);
    Chart.LoadJSON('{"animation":false,"xAxis":{"type":"category","data":["A","B"]},"yAxis":{"type":"value"},"tooltip":{"trigger":"axis"},"series":[{"type":"bar","data":[10,20]}]}');
    Host.Show; Application.ProcessMessages;
    for DPI in TArray<Integer>.Create(96,120,144,192) do begin
      SendMessage(Chart.Handle,WM_DPICHANGED,MakeWParam(DPI,DPI),0);
      Chart.SetBounds(0,0,Round(720*DPI/96),Round(420*DPI/96));
      Chart.CapturePNG(TPath.Combine(Output,'dpi-'+IntToStr(DPI)+'.png'));
      Require(Chart.EffectiveDpi=DPI,'DPI interno incorreto');
    end;
    SendMessage(Chart.Handle,WM_DPICHANGED,MakeWParam(96,96),0); Chart.SetBounds(0,0,720,420);
    Chart.CapturePNG(TPath.Combine(Output,'stable-a.png')); First:=TFile.ReadAllBytes(TPath.Combine(Output,'stable-a.png'));
    for I:=0 to 40 do Chart.SetBounds(0,0,320+I*10,240+I*4);
    Chart.SetBounds(0,0,720,420); Chart.CapturePNG(TPath.Combine(Output,'stable-b.png'));
    Second:=TFile.ReadAllBytes(TPath.Combine(Output,'stable-b.png'));
    Require((Length(First)=Length(Second)) and CompareMem(@First[0],@Second[0],Length(First)),'Resize deixou artefatos');
    for J:=1 to 5 do begin
      for I:=0 to 79 do begin SendMessage(Chart.Handle,WM_MOUSEMOVE,0,MakeLParam(100+I,200)); Chart.Update; end;
      Application.ProcessMessages;
    end;
    Application.ProcessMessages; GdiFlush;
    BaseGDI:=GetGuiResources(GetCurrentProcess,0);
    for I:=0 to 80 do begin
      SendMessage(Chart.Handle,WM_MOUSEMOVE,0,MakeLParam(100+I,200)); Chart.Update;
    end;
    Application.ProcessMessages; GdiFlush;
    Require(GetGuiResources(GetCurrentProcess,0)<=BaseGDI+4,Format('Crescimento de objetos GDI: %d -> %d',[BaseGDI,GetGuiResources(GetCurrentProcess,0)]));
    Chart.CaptureDirectory:=TPath.Combine(Output,'animation-frames');
    Chart.LoadJSON('{"animation":true,"animationDuration":80,"animationDurationUpdate":80,"xAxis":{"type":"category","data":["A","B"]},"yAxis":{"type":"value"},"series":[{"type":"bar","data":[20,40]}]}');
    Start:=GetTickCount;
    repeat Application.ProcessMessages; Sleep(1); until GetTickCount-Start>=240;
    Require(not Chart.AnimationRunning,'Animacao nao terminou');
    Chart.CaptureDirectory:='';
    TChartAccess(Chart).RecreateForTest; Start:=GetTickCount;
    repeat Application.ProcessMessages; Sleep(1); until GetTickCount-Start>=240;
    Require(not Chart.AnimationRunning,'Recriacao ativou timer residual');
    Host.WindowState:=wsMinimized; Application.ProcessMessages;
    Host.WindowState:=wsNormal; Host.Hide; Host.Show; Chart.Update;
    Chart.CaptureWindowPNG(TPath.Combine(Output,'window-lifecycle.png'));
    TFile.WriteAllText(TPath.Combine(Output,'window-metrics.json'),Chart.MetricsJSON,TEncoding.UTF8);
    TFile.WriteAllText(TPath.Combine(Output,'monitors.txt'),IntToStr(Screen.MonitorCount)+
      ' monitor(es); mudanca de monitor real nao automatizada',TEncoding.UTF8);
  finally Host.Free; end;
end;

var Chart,Restored: TDACChart; Fixtures,V,C,Options: TJSONValue;
  Cases: TJSONArray; I: Integer; OutDir,Id,Before: string;
  Stream: TMemoryStream; DS: TClientDataSet; Source: TDataSource;
begin
  try
    Application.Initialize;
    TestChartTypes;
    if ParamCount<2 then raise Exception.Create('Uso: DACComponentsCharts fixtures.json output');
    OutDir:=ExpandFileName(ParamStr(2)); ForceDirectories(OutDir);
    TestTitleSpacing(OutDir);
    Fixtures:=TJSONObject.ParseJSONValue(TFile.ReadAllText(ParamStr(1),TEncoding.UTF8));
    Chart:=TDACChart.Create(nil);
    try
      Chart.SetBounds(0,0,720,420);
      Require(not Chart.HandleAllocated,'Parent=nil criou HWND');
      Cases:=TJSONArray(CJ(Fixtures,'cases'));
      for I:=0 to Cases.Count-1 do begin
        C:=Cases.Items[I]; Id:=CS(CJ(C,'id')); Options:=CJ(C,'option');
        Chart.LoadJSON(Options.ToJSON);
        Chart.CapturePNG(TPath.Combine(OutDir,Id+'.png'));
        TFile.WriteAllText(TPath.Combine(OutDir,Id+'.json'),Chart.GeometryJSON,TEncoding.UTF8);
        if Id='C01' then begin Near(Chart.Engine.Marks[0].X,180,'C01 barra A'); Near(Chart.Engine.Marks[3].X,180,'C01 linha A'); end;
        if Id='C02' then begin Near(Chart.Engine.Marks[1].X,86,'C02 X=1'); Near(Chart.Engine.Marks[2].X,680,'C02 X=100'); end;
        if Id='C03' then Near(Chart.Engine.Marks[1].X,140,'C03 tempo');
        if Id='C04' then Near(Chart.Engine.Marks[0].Y,296,'C04 limite fixo');
        if Id='C05' then begin Require(Chart.Engine.Marks[0].Name='A','C05 A'); Require(Chart.Engine.Marks[1].Name='B','C05 B'); end;
        if Id='C06' then Require(Chart.Engine.Marks.Count=3,'C06 NULL');
        if Id='C07' then Near(Chart.Engine.Marks[0].Y,360-320/7,'C07 negativo');
        if Id='C08' then begin Near(Chart.Engine.Marks[0].Sweep,90,'C08 angulo'); Require(Chart.Engine.HitTest(PointF(360,210))=-1,'C08 centro vazado'); end;
        if Id='C09' then Near(Chart.Engine.Marks[0].Sweep,180,'C09 soma zero');
        if Id='C10' then Require(Chart.Engine.Marks.Count=0,'C10 sem setores');
        if (Id='C11') or (Id='C12') then begin Require(Chart.Engine.Marks[0].Name='Jan',Id+' categoria'); Near(Chart.Engine.Marks[4].Value,25,Id+' encode'); end;
        if Id='C13' then Near(Chart.Engine.Marks[3].Base,-4,'C13 base negativa');
        if Id='C14' then Near(Chart.Engine.Marks[0].X,230,'C14 horizontal');
        if Id.StartsWith('C') then Writeln(Id,': assertions OK') else Writeln(Id,': captured for visual review');
      end;
      Chart.LoadJSON('{"animation":false,"xAxis":{"type":"value"},"yAxis":{"type":"value"},"series":[{"type":"line","data":[[0.5,1.25],[1.5,-2.75]]}]}');
      Chart.CapturePNG(TPath.Combine(OutDir,'decimals.png'));
      Require(Chart.Engine.Marks.Count=2,'Decimais descartados pela configuracao regional');
      Near(Chart.Engine.Marks[1].Value,-2.75,'Valor decimal alterado');
      Before:=Chart.SaveJSON;
      try Chart.LoadJSON('{"series":[{"type":"radar"}]}'); raise Exception.Create('Tipo invalido aceito');
      except on E: EDACChartOptionError do ; end;
      Require(Chart.SaveJSON=Before,'Importacao nao transacional');
      System.Classes.RegisterClass(TDACChart);
      Stream:=TMemoryStream.Create;
      try
        Chart.Name:='RoundTrip'; Stream.WriteComponent(Chart); Stream.Position:=0;
        Restored:=TDACChart(Stream.ReadComponent(nil));
        try Require(Restored.SaveJSON=Chart.SaveJSON,'DFM roundtrip'); finally Restored.Free; end;
      finally Stream.Free; end;
      try Chart.LoadJSON('{"dataset":{"dimensions":["MES","VALOR"],"source":[{"MES":"A"}]},"series":[{"type":"bar","encode":{"y":"VALOR"}}]}');
        raise Exception.Create('Campo inexistente aceito como NULL');
      except on E: EDACChartOptionError do ; end;
      Require(Chart.SaveJSON=Before,'Erro de dataset mudou configuracao');
      Chart.Options.Title.Text:='Designer'; Require(Pos('Designer',Chart.SaveJSON)>0,'Setter designer sem efeito');
      DS:=TClientDataSet.Create(nil); Source:=TDataSource.Create(nil);
      try
        DS.FieldDefs.Add('MES',ftString,10); DS.FieldDefs.Add('VALOR',ftFloat); DS.CreateDataSet;
        DS.AppendRecord(['A',10]); DS.AppendRecord(['B',20]); DS.AppendRecord(['C',Null]); DS.Filter:='VALOR > 15'; DS.Filtered:=True;
        Source.DataSet:=DS;
        Chart.LoadJSON('{"animation":false,"dataset":{"dimensions":["MES","VALOR"]},"xAxis":{"type":"category"},"yAxis":{"type":"value"},"series":[{"type":"bar","encode":{"x":"MES","y":"VALOR"}}]}');
        Chart.DataSource:=Source; Chart.CapturePNG(TPath.Combine(OutDir,'filtered.png'));
        Require(Chart.Engine.Marks.Count=1,'Filtro ignorado'); Require(Chart.Engine.Marks[0].Name='B','Filtro categoria');
        Chart.Options.Title.Text:='Outra cor'; Chart.CapturePNG(TPath.Combine(OutDir,'filtered-title.png'));
        V:=TJSONObject.ParseJSONValue(Chart.MetricsJSON);
        try Near(CN(CJ(V,'dataReads')),1,'Mudanca visual releu dataset'); finally V.Free; end;
        DS.Filtered:=False; DS.Locate('MES','B',[]); DS.Edit; DS.FieldByName('VALOR').AsFloat:=25; DS.Post;
        Chart.CapturePNG(TPath.Combine(OutDir,'dataset-update.png'));
        Require(DS.FieldByName('MES').AsString='B','Leitura moveu cursor original');
        Require(Chart.Engine.Marks.Count=2,'NULL virou ponto numerico');
        Near(Chart.Engine.Marks[1].Value,25,'Atualizacao nao chegou ao chart');
      finally Source.Free; DS.Free; end;
    finally Chart.Free; Fixtures.Free; end;
    TestWindowLifecycle(OutDir);
    Writeln('DACComponentsCharts: OK');
  except on E: Exception do begin Writeln(E.ClassName,': ',E.Message); Halt(1); end; end;
end.
