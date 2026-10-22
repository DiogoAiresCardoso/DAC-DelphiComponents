program DACComponentsCharts;
{$APPTYPE CONSOLE}
uses System.Classes, System.SysUtils, System.IOUtils, System.JSON,
  System.Math, System.Types, Winapi.Windows, Winapi.Messages,
  Vcl.Forms, Data.DB, Datasnap.DBClient,
  DAC.Components.Charts.Options,
  DAC.Components.Controls.Charts in '..\Source\Controls\DAC.Components.Controls.Charts.pas',
  DACComponentsCharts.ClientDataSetAdapter in 'DACComponentsCharts.ClientDataSetAdapter.pas';

procedure Require(B: Boolean; const S: string);
begin if not B then raise Exception.Create(S); end;
procedure Near(A,B: Double; const S: string);
begin Require(Abs(A-B)<0.5,S+Format(' %.4f <> %.4f',[A,B])); end;

var Chart,Restored: TDACChart; Fixtures,V,C,Options: TJSONValue;
  Cases: TJSONArray; I: Integer; OutDir,Id,Before: string;
  Stream: TMemoryStream; DS: TClientDataSet; Source: TDataSource;
begin
  try
    Application.Initialize;
    if ParamCount<2 then raise Exception.Create('Uso: DACComponentsCharts fixtures.json output');
    OutDir:=ExpandFileName(ParamStr(2)); ForceDirectories(OutDir);
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
        Writeln(Id,': OK');
      end;
      Before:=Chart.SaveJSON;
      try Chart.LoadJSON('{"series":[{"type":"radar"}]}'); raise Exception.Create('Tipo invalido aceito');
      except on E: EDACChartOptionError do ; end;
      Require(Chart.SaveJSON=Before,'Importacao nao transacional');
      RegisterClass(TDACChart);
      Stream:=TMemoryStream.Create;
      try
        Chart.Name:='RoundTrip'; Stream.WriteComponent(Chart); Stream.Position:=0;
        Restored:=TDACChart(Stream.ReadComponent(nil));
        try Require(Restored.SaveJSON=Chart.SaveJSON,'DFM roundtrip'); finally Restored.Free; end;
      finally Stream.Free; end;
      Chart.Options.Title.Text:='Designer'; Require(Pos('Designer',Chart.SaveJSON)>0,'Setter designer sem efeito');
      DS:=TClientDataSet.Create(nil); Source:=TDataSource.Create(nil);
      try
        DS.FieldDefs.Add('MES',ftString,10); DS.FieldDefs.Add('VALOR',ftFloat); DS.CreateDataSet;
        DS.AppendRecord(['A',10]); DS.AppendRecord(['B',20]); DS.Filter:='VALOR > 15'; DS.Filtered:=True;
        Source.DataSet:=DS;
        Chart.LoadJSON('{"animation":false,"dataset":{"dimensions":["MES","VALOR"]},"xAxis":{"type":"category"},"yAxis":{"type":"value"},"series":[{"type":"bar","encode":{"x":"MES","y":"VALOR"}}]}');
        Chart.DataSource:=Source; Chart.CapturePNG(TPath.Combine(OutDir,'filtered.png'));
        Require(Chart.Engine.Marks.Count=1,'Filtro ignorado'); Require(Chart.Engine.Marks[0].Name='B','Filtro categoria');
        Chart.Options.Title.Text:='Outra cor'; Chart.CapturePNG(TPath.Combine(OutDir,'filtered-title.png'));
        V:=TJSONObject.ParseJSONValue(Chart.MetricsJSON);
        try Near(CN(CJ(V,'dataReads')),1,'Mudanca visual releu dataset'); finally V.Free; end;
      finally Source.Free; DS.Free; end;
    finally Chart.Free; Fixtures.Free; end;
    Writeln('DACComponentsCharts: OK');
  except on E: Exception do begin Writeln(E.ClassName,': ',E.Message); Halt(1); end; end;
end.
