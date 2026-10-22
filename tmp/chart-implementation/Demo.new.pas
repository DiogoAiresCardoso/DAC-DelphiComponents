unit DACChartsDemo.Main;

interface
uses System.Classes, System.SysUtils, System.Types, System.JSON,
  Winapi.Windows, Winapi.Messages, Vcl.Forms, Vcl.Controls, Vcl.StdCtrls,
  Vcl.ExtCtrls, Vcl.ComCtrls, Vcl.Dialogs, Vcl.Graphics, Vcl.Clipbrd,
  DAC.Components.Controls.Charts, DAC.Components.Charts.Options;
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
    VisualHost: TPanel;
    CompareBar: TPanel;
    ReferenceDir,ActualDir: TEdit;
    CompareButton: TButton;
    CompareScroll: TScrollBox;
    StabilityBar: TPanel;
    UpdateButton,ReplayButton,StopButton,CaptureButton,StressButton: TButton;
    StabilityHost: TPanel;
    Metrics: TMemo;
    MetricsTimer: TTimer;
    OpenDialog: TOpenDialog;
    SaveDialog: TSaveDialog;
    Status: TLabel;
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
  private
    FFixtures: TJSONObject;
    FChart,FVisual,FStress: TDACChart;
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
uses System.IOUtils, System.Math, System.Diagnostics, Vcl.Imaging.pngimage,
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
    C:=TPath.Combine(P,'docs\charts\echarts-reference\reference-cases.json'); if TFile.Exists(C) then Exit(C);
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
end;
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
var O: TJSONObject; A: TJSONArray; I: Integer; S: TDACChartOptionSeries;
begin
  FVisual.BeginUpdate;
  try
    FVisual.Options.Title.Text:=TitleEdit.Text;
    FVisual.Options.Legend.Show:=LegendCheck.Checked;
    FVisual.Options.Tooltip.Show:=TooltipCheck.Checked;
    for I:=0 to FVisual.Options.Series.Count-1 do FVisual.Options.Series[I].LabelStyle.Show:=LabelsCheck.Checked;
  finally FVisual.EndUpdate; end;
  O:=FVisual.Options.Clone;
  try
    if ThemeBox.ItemIndex=1 then begin
      CSet(O,'color',TJSONArray.Create('#2F9E22','#3DB82A','#74D64A','#F5C842','#D94A3A'));
      CSet(O,'backgroundColor',TJSONString.Create('#E8EEE8'));
    end else begin
      O.RemovePair('color').Free; O.RemovePair('backgroundColor').Free;
    end;
    FVisual.LoadJSON(O.ToJSON);
  finally O.Free; end;
end;
procedure TChartsDemoForm.CompareClick(Sender: TObject);
const Names: array[0..3] of string=('ECharts','DAC','Sobreposicao','Diferencas');
var I: Integer; Image: TImage; LabelControl: TLabel; FileName,Id: string;
begin
  while CompareScroll.ControlCount>0 do CompareScroll.Controls[0].Free;
  Id:=CS(CJ(TJSONArray(CJ(FFixtures,'cases')).Items[Cases.ItemIndex],'id'));
  for I:=0 to 3 do begin
    LabelControl:=TLabel.Create(Self); LabelControl.Parent:=CompareScroll;
    LabelControl.SetBounds((I mod 2)*730+8,(I div 2)*455+8,710,24); LabelControl.Caption:=Names[I];
    Image:=TImage.Create(Self); Image.Parent:=CompareScroll;
    Image.SetBounds(LabelControl.Left,LabelControl.Top+26,720,420);
    if I=0 then FileName:=TPath.Combine(ReferenceDir.Text,Id+'.png')
    else if I=1 then FileName:=TPath.Combine(ActualDir.Text,Id+'.png')
    else if I=2 then FileName:=TPath.Combine(ActualDir.Text,Id+'-overlay.png')
    else FileName:=TPath.Combine(ActualDir.Text,Id+'-diff.png');
    if TFile.Exists(FileName) then Image.Picture.LoadFromFile(FileName)
    else LabelControl.Caption:=Names[I]+' - arquivo ainda nao gerado';
  end;
end;
procedure TChartsDemoForm.UpdateClick(Sender: TObject);
var O: TJSONObject; A,D: TJSONArray; I,J: Integer; V: TJSONValue;
begin
  O:=FStress.Options.Clone; Inc(FIteration);
  try
    A:=TJSONArray(CJ(O,'series'));
    for I:=0 to A.Count-1 do begin
      D:=TJSONArray(CJ(A.Items[I],'data')); if D=nil then Continue;
      for J:=0 to D.Count-1 do begin
        V:=D.Items[J];
        if V is TJSONNumber then begin V:=D.Remove(J); V.Free; D.Insert(J,TJSONNumber.Create(5+(J*7+FIteration*3) mod 35)); end;
      end;
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
var O: TJSONObject; A,D: TJSONArray; S,P,I: Integer; Series: TJSONObject; Start: Cardinal;
begin
  O:=TJSONObject.Create; A:=TJSONArray.Create;
  try
    O.AddPair('animation',TJSONBool.Create(False));
    O.AddPair('xAxis',TJSONObject.Create.AddPair('type','value'));
    O.AddPair('yAxis',TJSONObject.Create.AddPair('type','value'));
    O.AddPair('series',A);
    for S:=0 to 5 do begin
      Series:=TJSONObject.Create; A.AddElement(Series); Series.AddPair('type','line');
      Series.AddPair('showSymbol',TJSONBool.Create(False)); D:=TJSONArray.Create; Series.AddPair('data',D);
      for P:=0 to 165 do D.AddElement(TJSONArray.Create(P,Sin(P/12+S)*20+S*10));
    end;
    FStress.LoadJSON(O.ToJSON); Start:=GetTickCount;
    for I:=0 to 119 do begin
      SendMessage(FStress.Handle,WM_MOUSEMOVE,0,MakeLParam(100+I*3,150));
      FStress.Update; Application.ProcessMessages;
      while GetTickCount-Start<Cardinal((I+1)*33) do begin Application.ProcessMessages; Sleep(1); end;
    end;
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
var OutDir,Id,CaseId: string; A: TJSONArray; I: Integer;
begin
  try
    OutDir:=ExpandFileName(Arg('--out','captures')); ForceDirectories(OutDir);
    Pages.ActivePage:=ConfigTab; FChart.Align:=alNone; FChart.SetBounds(0,0,720,420);
    A:=TJSONArray(CJ(FFixtures,'cases')); CaseId:=Arg('--case','all');
    for I:=0 to A.Count-1 do begin
      Id:=CS(CJ(A.Items[I],'id')); if (CaseId<>'all') and (CaseId<>Id) then Continue;
      FChart.LoadJSON(CJ(A.Items[I],'option').ToJSON);
      FChart.CapturePNG(TPath.Combine(OutDir,Id+'.png')); FChart.Invalidate; FChart.Update;
      FChart.CaptureWindowPNG(TPath.Combine(OutDir,Id+'-window.png'));
      TFile.WriteAllText(TPath.Combine(OutDir,Id+'.json'),FChart.GeometryJSON,TEncoding.UTF8);
    end;
    if Arg('--stress','')<>'' then begin
      Pages.ActivePage:=StabilityTab; FStress.Align:=alNone; FStress.SetBounds(0,0,720,420);
      FStress.CaptureDirectory:=TPath.Combine(OutDir,'frames'); RunStress;
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
