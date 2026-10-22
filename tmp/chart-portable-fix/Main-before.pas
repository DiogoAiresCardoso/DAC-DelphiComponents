unit DACChartsDemo.Main;

interface
uses System.Classes, System.SysUtils, System.Types, System.JSON,
  Winapi.Windows, Winapi.Messages, Data.DB, Datasnap.DBClient, Vcl.Forms, Vcl.Controls, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Dialogs, Vcl.Graphics, Vcl.Clipbrd,
  DAC.Components.Controls.Charts, DAC.Components.Charts.Options, DAC.Components.Charts.Types;
type
  TChartsDemoForm = class(TForm)
    Pages: TPageControl;
    GalleryTab, ConfigTab, VisualTab, CompareTab, StabilityTab: TTabSheet;
    Gallery: TScrollBox;
    ConfigBar: TPanel;
    Cases: TComboBox;
    ApplyButton,ResetButton,ImportButton,ExportButton,CopyButton: TButton;
    Editor: TMemo;
    ChartHost: TPanel;
    VisualBar: TPanel;
    TitleEdit: TEdit;
    LabelsCheck,LegendCheck,TooltipCheck: TCheckBox;
    ThemeBox: TComboBox;
    LegendOrientation: TComboBox;
    VisualHost: TPanel;
    CompareBar: TPanel;
    ReferenceDir,ActualDir: TEdit;
    CompareButton: TButton;
    CompareScroll: TScrollBox;
    RefImage,DACImage,OverlayImage,DiffImage: TImage;
    RefCaption,DACCaption,OverlayCaption,DiffCaption,UnavailableLabel: TLabel;
    StabilityBar: TPanel;
    UpdateButton,ReplayButton,StopButton,CaptureButton,StressButton: TButton;
    StabilityHost: TPanel;
    Metrics: TMemo;
    MetricsTimer: TTimer;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    Status: TLabel;
    FilterButton: TButton;
    DemoData: TClientDataSet;
    DemoSource: TDataSource;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure CaseChanged(Sender: TObject);
    procedure ApplyClick(Sender: TObject);
    procedure ResetClick(Sender: TObject);
    procedure ImportClick(Sender: TObject);
    procedure ExportClick(Sender: TObject);
    procedure CopyClick(Sender: TObject);
    procedure VisualChanged(Sender: TObject);
    procedure CompareClick(Sender: TObject);
    procedure UpdateClick(Sender: TObject);
    procedure ReplayClick(Sender: TObject);
    procedure StopClick(Sender: TObject);
    procedure CaptureClick(Sender: TObject);
    procedure StressClick(Sender: TObject);
    procedure MetricsTick(Sender: TObject);
    procedure PageChanged(Sender: TObject);
    procedure FilterClick(Sender: TObject);
  private
    FFixtures: TJSONObject;
    FChart,FVisual,FStress,FDataChart: TDACChart;
    FIteration: Integer;
    FAutomatic: Boolean;
    function Arg(const Name,Default: string): string;
    function FixturePath: string;
    function SelectedOption: string;
    procedure BuildGallery;
    procedure RunAutomatic(var Message: TMessage); message WM_APP+$510;
    procedure RunStress;
  end;
var ChartsDemoForm: TChartsDemoForm;
implementation
uses System.IOUtils, System.Math, System.Diagnostics, System.Variants, Vcl.Imaging.pngimage,
  DACChartsDemo.ClientDataSetAdapter;
{$R *.dfm}

function TChartsDemoForm.Arg(const Name,Default: string): string;
var I: Integer;
begin
  Result:=Default;
  for I:=1 to ParamCount do if SameText(ParamStr(I),Name) then begin
    if (I<ParamCount) and not ParamStr(I+1).StartsWith('--') then Result:=ParamStr(I+1) else Result:='true'; Exit;
  end;
end;
function TChartsDemoForm.FixturePath: string;
var P,C: string; I: Integer;
begin
  Result:=Arg('--fixtures',''); if Result<>'' then Exit;
  P:=ExtractFilePath(Application.ExeName);
  for I:=0 to 8 do begin
    C:=TPath.Combine(P,'reference-cases.json'); if TFile.Exists(C) then Exit(C);
    C:=TPath.Combine(P,'Tests\Charts.Visual\fixtures.json'); if TFile.Exists(C) then Exit(C);
    P:=TPath.GetDirectoryName(ExcludeTrailingPathDelimiter(P));
  end;
  raise Exception.Create('reference-cases.json nao encontrado; use --fixtures caminho');
end;
procedure TChartsDemoForm.FormCreate(Sender: TObject);
var A: TJSONArray; I: Integer;
begin
  FFixtures:=TJSONObject.ParseJSONValue(TFile.ReadAllText(FixturePath,TEncoding.UTF8)) as TJSONObject;
  A:=TJSONArray(CJ(FFixtures,'cases'));
  for I:=0 to A.Count-1 do Cases.Items.Add(CS(CJ(A.Items[I],'id'))+' - '+CS(CJ(A.Items[I],'title')));
  FChart:=TDACChart.Create(Self); FChart.Parent:=ChartHost; FChart.Align:=alClient;
  FVisual:=TDACChart.Create(Self); FVisual.Parent:=VisualHost; FVisual.Align:=alClient;
  FStress:=TDACChart.Create(Self); FStress.Parent:=StabilityHost; FStress.Align:=alClient;
  DemoData.FieldDefs.Add('MES',ftString,12); DemoData.FieldDefs.Add('VALOR',ftFloat);
  DemoData.CreateDataSet; DemoData.AppendRecord(['Jan',10]); DemoData.AppendRecord(['Fev',20]);
  DemoData.AppendRecord(['Mar',Null]); DemoData.AppendRecord(['Abr',30]);
  DemoData.Filter:='VALOR >= 20';
  Cases.ItemIndex:=0; CaseChanged(nil); BuildGallery; Pages.ActivePage:=GalleryTab;
  FAutomatic:=Arg('--out','')<>'';
end;
procedure TChartsDemoForm.FormDestroy(Sender: TObject);
begin FFixtures.Free; end;
procedure TChartsDemoForm.FormShow(Sender: TObject);
begin if FAutomatic then PostMessage(Handle,WM_APP+$510,0,0); end;
procedure TChartsDemoForm.BuildGallery;
var I: Integer; A: TJSONArray; C: TDACChart; L: TLabel;
begin
  A:=TJSONArray(CJ(FFixtures,'cases'));
  for I:=0 to A.Count-1 do begin
    L:=TLabel.Create(Self); L.Parent:=Gallery; L.SetBounds(12+(I mod 2)*530,12+(I div 2)*340,510,24);
    L.Caption:=CS(CJ(A.Items[I],'id'))+' - '+CS(CJ(A.Items[I],'title'));
    C:=TDACChart.Create(Self); C.Parent:=Gallery; C.SetBounds(L.Left,L.Top+28,510,290);
    C.LoadJSON(CJ(A.Items[I],'option').ToJSON);
  end;
  FDataChart:=TDACChart.Create(Self); FDataChart.Parent:=Gallery;
  FDataChart.SetBounds(12,(A.Count div 2+1)*340,1030,290);
  FDataChart.LoadJSON('{"animation":false,"title":{"text":"Data-aware: filtro e NULL"},"dataset":{"dimensions":["MES","VALOR"]},"xAxis":{"type":"category"},"yAxis":{"type":"value"},"tooltip":{"trigger":"axis"},' +
    '"series":[{"type":"bar","name":"Dataset local","encode":{"x":"MES","y":"VALOR"}}]}');
  FDataChart.DataSource:=DemoSource;
end;
procedure TChartsDemoForm.FilterClick(Sender: TObject);
begin DemoData.Filtered:=not DemoData.Filtered; Status.Caption:='Filtro do dataset: '+BoolToStr(DemoData.Filtered,True); end;
function TChartsDemoForm.SelectedOption: string;
begin Result:=CJ(TJSONArray(CJ(FFixtures,'cases')).Items[Max(0,Cases.ItemIndex)],'option').ToJSON; end;
procedure TChartsDemoForm.CaseChanged(Sender: TObject);
begin
  Editor.Text:=SelectedOption; ApplyClick(nil);
  FVisual.LoadJSON(SelectedOption); FStress.LoadJSON(SelectedOption);
end;
procedure TChartsDemoForm.ApplyClick(Sender: TObject);
begin
  try FChart.LoadJSON(Editor.Text); Status.Caption:='Configuracao aplicada';
  except on E: Exception do Status.Caption:=E.Message; end;
end;
procedure TChartsDemoForm.ResetClick(Sender: TObject);
begin CaseChanged(nil); end;
procedure TChartsDemoForm.ImportClick(Sender: TObject);
begin if OpenDialog.Execute then begin Editor.Text:=TFile.ReadAllText(OpenDialog.FileName,TEncoding.UTF8); ApplyClick(nil); end; end;
procedure TChartsDemoForm.ExportClick(Sender: TObject);
begin if SaveDialog.Execute then TFile.WriteAllText(SaveDialog.FileName,FChart.SaveJSON,TEncoding.UTF8); end;
procedure TChartsDemoForm.CopyClick(Sender: TObject);
begin Clipboard.AsText:=FChart.SaveJSON; end;
procedure TChartsDemoForm.VisualChanged(Sender: TObject);
var O: TJSONObject; I: Integer;
begin
  FVisual.BeginUpdate;
  try
    FVisual.Options.Title.Text:=TitleEdit.Text;
    FVisual.Options.Legend.Show:=LegendCheck.Checked;
    case LegendOrientation.ItemIndex of
      1: FVisual.Options.Legend.Orient:=dcoHorizontal;
      2: FVisual.Options.Legend.Orient:=dcoVertical;
    else FVisual.Options.Legend.Orient:=dcoDefault; end;
    FVisual.Options.Tooltip.Show:=TooltipCheck.Checked;
    for I:=0 to FVisual.Options.Series.Count-1 do FVisual.Options.Series[I].LabelStyle.Show:=LabelsCheck.Checked;
  finally FVisual.EndUpdate; end;
  O:=FVisual.Options.Clone;
  try
    if ThemeBox.ItemIndex=1 then begin
      CSet(O,'color',TJSONArray.Create.Add('#2F9E22').Add('#3DB82A').Add('#74D64A').Add('#F5C842').Add('#D94A3A'));
      CSet(O,'backgroundColor',TJSONString.Create('#E8EEE8'));
    end else begin
      O.RemovePair('color').Free; O.RemovePair('backgroundColor').Free;
    end;
    FVisual.LoadJSON(O.ToJSON);
  finally O.Free; end;
end;
procedure TChartsDemoForm.CompareClick(Sender: TObject);
var I: Integer; Image: TImage; FileName,Id: string;
begin
  Id:=CS(CJ(TJSONArray(CJ(FFixtures,'cases')).Items[Cases.ItemIndex],'id'));
  for I:=0 to 3 do begin
    case I of 0: Image:=RefImage; 1: Image:=DACImage; 2: Image:=OverlayImage; else Image:=DiffImage; end;
    if I=0 then FileName:=TPath.Combine(ReferenceDir.Text,Id+'.png')
    else if I=1 then FileName:=TPath.Combine(ActualDir.Text,Id+'.png')
    else if I=2 then FileName:=TPath.Combine(ActualDir.Text,Id+'-overlay.png')
    else FileName:=TPath.Combine(ActualDir.Text,Id+'-diff.png');
    if TFile.Exists(FileName) then Image.Picture.LoadFromFile(FileName)
    else begin Image.Picture.Assign(nil); Image.Hint:='Arquivo ainda nao gerado: '+FileName; Image.ShowHint:=True; end;
  end;
end;
procedure TChartsDemoForm.UpdateClick(Sender: TObject);
var O: TJSONObject; A,D,NewData: TJSONArray; I,J: Integer; V: TJSONValue;
begin
  O:=FStress.Options.Clone; Inc(FIteration);
  try
    A:=TJSONArray(CJ(O,'series'));
    for I:=0 to A.Count-1 do begin
      D:=TJSONArray(CJ(A.Items[I],'data')); if D=nil then Continue;
      NewData:=TJSONArray.Create;
      for J:=0 to D.Count-1 do begin
        V:=D.Items[J];
        if V is TJSONNumber then NewData.Add(5+(J*7+FIteration*3) mod 35)
        else NewData.AddElement(TJSONValue(V.Clone));
      end;
      CSet(TJSONObject(A.Items[I]),'data',NewData);
    end;
    CSet(O,'animation',TJSONBool.Create(True)); FStress.LoadJSON(O.ToJSON);
  finally O.Free; end;
end;
procedure TChartsDemoForm.ReplayClick(Sender: TObject);
begin FStress.Replay; end;
procedure TChartsDemoForm.StopClick(Sender: TObject);
begin FStress.Stop; end;
procedure TChartsDemoForm.CaptureClick(Sender: TObject);
begin
  SaveDialog.Filter:='PNG|*.png';
  if SaveDialog.Execute then FStress.CapturePNG(SaveDialog.FileName);
  SaveDialog.Filter:='JSON|*.json';
end;
procedure TChartsDemoForm.RunStress;
var O: TJSONObject; A,D: TJSONArray; S,P,I,Points,Frames,DPI: Integer; Series: TJSONObject; Start,Finish: Cardinal; Animate: Boolean;
begin
  Points:=Max(6,StrToIntDef(Arg('--points','996'),996));
  Frames:=Max(1,StrToIntDef(Arg('--frames','120'),120));
  DPI:=StrToIntDef(Arg('--dpi','144'),144);
  SendMessage(FStress.Handle,WM_DPICHANGED,MakeWParam(DPI,DPI),0);
  O:=TJSONObject.Create; A:=TJSONArray.Create;
  try
    O.AddPair('animation',TJSONBool.Create(False));
    O.AddPair('xAxis',TJSONObject.Create.AddPair('type','value'));
    O.AddPair('yAxis',TJSONObject.Create.AddPair('type','value'));
    O.AddPair('series',A);
    for S:=0 to 5 do begin
      Series:=TJSONObject.Create; A.AddElement(Series); Series.AddPair('type','line');
      Series.AddPair('showSymbol',TJSONBool.Create(False)); D:=TJSONArray.Create; Series.AddPair('data',D);
      for P:=0 to ((Points+5-S) div 6)-1 do D.AddElement(TJSONArray.Create.Add(P).Add(Sin(P/12+S)*20+S*10));
    end;
    Animate:=Arg('--animate','')<>'';
    FStress.LoadJSON(O.ToJSON); Start:=GetTickCount;
    for I:=0 to Frames-1 do begin
      if Animate and ((I mod 15)=0) then begin
        for S:=0 to A.Count-1 do begin
          Series:=TJSONObject(A.Items[S]); D:=TJSONArray.Create;
          for P:=0 to ((Points+5-S) div 6)-1 do D.AddElement(TJSONArray.Create.Add(P).Add(Sin((P+I)/12+S)*20+S*10));
          CSet(Series,'data',D);
        end;
        CSet(O,'animation',TJSONBool.Create(True)); FStress.LoadJSON(O.ToJSON);
      end;
      SendMessage(FStress.Handle,WM_MOUSEMOVE,0,MakeLParam(100+(I*3 mod 500),150));
      FStress.Update; Application.ProcessMessages;
      while GetTickCount-Start<Cardinal((I+1)*33) do begin Application.ProcessMessages; Sleep(1); end;
    end;
    if Animate then begin
      Finish:=GetTickCount;
      repeat Application.ProcessMessages; Sleep(1); until (GetTickCount-Finish>750) and not FStress.AnimationRunning;
    end;
    if FStress.Engine.Marks.Count<>Points then raise Exception.CreateFmt(
      'Carga invalida: %d pontos desenhados, esperado %d',[FStress.Engine.Marks.Count,Points]);
    Metrics.Text:=FStress.MetricsJSON;
  finally O.Free; end;
end;
procedure TChartsDemoForm.StressClick(Sender: TObject);
begin RunStress; end;
procedure TChartsDemoForm.MetricsTick(Sender: TObject);
begin Metrics.Text:=FStress.MetricsJSON; end;
procedure TChartsDemoForm.PageChanged(Sender: TObject);
begin MetricsTimer.Enabled:=Pages.ActivePage=StabilityTab; end;
procedure TChartsDemoForm.RunAutomatic(var Message: TMessage);
var OutDir,Id,CaseId: string; A: TJSONArray; I,Matches: Integer; Bitmap: TBitmap; PNG: TPngImage;
begin
  try
    OutDir:=ExpandFileName(Arg('--out','captures')); ForceDirectories(OutDir);
    Pages.ActivePage:=GalleryTab; Update; Application.ProcessMessages;
    Bitmap:=TBitmap.Create; PNG:=TPngImage.Create;
    try Bitmap.SetSize(ClientWidth,ClientHeight); PaintTo(Bitmap.Canvas.Handle,0,0);
      PNG.Assign(Bitmap); PNG.SaveToFile(TPath.Combine(OutDir,'gallery.png'));
    finally PNG.Free; Bitmap.Free; end;
    Matches:=0;
    Pages.ActivePage:=ConfigTab; FChart.Align:=alNone; FChart.SetBounds(0,0,Max(80,StrToIntDef(Arg('--width','720'),720)),Max(80,StrToIntDef(Arg('--height','420'),420)));
    if Arg('--dpi','')<>'' then SendMessage(FChart.Handle,WM_DPICHANGED,MakeWParam(StrToIntDef(Arg('--dpi','96'),96),0),0);
    A:=TJSONArray(CJ(FFixtures,'cases')); CaseId:=Arg('--case','all');
    for I:=0 to A.Count-1 do begin
      Id:=CS(CJ(A.Items[I],'id')); if (CaseId<>'all') and (CaseId<>Id) then Continue;
      Inc(Matches); FChart.LoadJSON(CJ(A.Items[I],'option').ToJSON);
      FChart.CapturePNG(TPath.Combine(OutDir,Id+'.png')); FChart.Invalidate; FChart.Update;
      FChart.CaptureWindowPNG(TPath.Combine(OutDir,Id+'-window.png'));
      TFile.WriteAllText(TPath.Combine(OutDir,Id+'.json'),FChart.GeometryJSON,TEncoding.UTF8);
    end;
    if Matches=0 then raise Exception.Create('Cenario nao encontrado: '+CaseId);
    if Arg('--stress','')<>'' then begin
      Pages.ActivePage:=StabilityTab; FStress.Align:=alNone; FStress.SetBounds(0,0,720,420);
      FStress.CaptureDirectory:=TPath.Combine(OutDir,'frames');
      FStress.CaptureScreenFrames:=Arg('--screen','')<>'';
      if FStress.CaptureScreenFrames then begin BringToFront; SetForegroundWindow(Handle); end;
      RunStress;
      TFile.WriteAllText(TPath.Combine(OutDir,'stress-option.json'),FStress.SaveJSON,TEncoding.UTF8);
      TFile.WriteAllText(TPath.Combine(OutDir,'stress-geometry.json'),FStress.GeometryJSON,TEncoding.UTF8);
      TFile.WriteAllText(TPath.Combine(OutDir,'metrics.json'),FStress.MetricsJSON,TEncoding.UTF8);
    end;
    TFile.WriteAllText(TPath.Combine(OutDir,'result.txt'),'OK',TEncoding.UTF8);
    Application.Terminate;
  except on E: Exception do begin
    TFile.WriteAllText(TPath.Combine(OutDir,'error.txt'),E.ClassName+': '+E.Message,TEncoding.UTF8);
    ExitCode:=1; Application.Terminate;
  end; end;
end;
end.
