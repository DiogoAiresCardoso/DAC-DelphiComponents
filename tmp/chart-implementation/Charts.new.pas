unit DAC.Components.Controls.Charts;

interface

uses System.Classes, System.SysUtils, System.Types, System.JSON,
  System.Generics.Collections, System.Diagnostics, Data.DB,
  Winapi.Windows, Winapi.Messages, Vcl.Controls, Vcl.Graphics,
  DAC.Components.Charts.Options, DAC.Components.Charts.Engine,
  DAC.Components.Charts.Surface;

type
  EDACChartDataError = class(Exception);
  TDACChartDataSetAdapter = class
  public
    function Supports(const ADataSet: TDataSet): Boolean; virtual; abstract;
    function CreateReadCursor(const ADataSet: TDataSet): TDataSet; virtual; abstract;
  end;
  TDACChart = class;
  TDACChartDataLink = class(TDataLink)
  private
    FChart: TDACChart;
  protected
    procedure ActiveChanged; override;
    procedure DataSetChanged; override;
    procedure RecordChanged(Field: TField); override;
  public
    constructor Create(AChart: TDACChart);
  end;
  TDACChartPointEvent = procedure(Sender: TObject; const SeriesIndex,
    PointIndex: Integer; const Category: string; const Value: Double) of object;
  TDACChartDataErrorEvent = procedure(Sender: TObject; const Error: Exception) of object;
  TDACChart = class(TCustomControl)
  private
    FOptions: TDACChartOptions;
    FEngine: TDACChartEngine;
    FFront,FBack: TDACChartSurface;
    FDataLink: TDACChartDataLink;
    FDataSource: TDataSource;
    FDataCache: TJSONArray;
    FDirty,FDataDirty,FConfigured,FPosted,FRunning: Boolean;
    FMouse: TPointF;
    FEffectiveDpi: Integer;
    FStart: Int64;
    FDuration: Double;
    FFrames,FReads,FAllocations: Integer;
    FLastFrameMs: Double;
    FFrameTimes: TList<Double>;
    FCaptureDirectory: string;
    FOnPointHover,FOnPointClick: TDACChartPointEvent;
    FOnDataError: TDACChartDataErrorEvent;
    FOnFormat: TDACChartFormatEvent;
    procedure OptionsChanged(Sender: TObject);
    procedure SetOptions(V: TDACChartOptions);
    procedure SetDataSource(V: TDataSource);
    procedure ReadData;
    procedure Configure;
    procedure RenderFrame(const FixedProgress: Double = -1);
    procedure NotifyFormat(Sender: TObject; const S,P: Integer;
      const Name: string; const Value: Double; var Text: string);
    procedure WMEraseBkgnd(var M: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMTimer(var M: TWMTimer); message WM_TIMER;
    procedure WMDpiChanged(var M: TMessage); message WM_DPICHANGED;
    procedure WMRefresh(var M: TMessage); message WM_APP+$461;
    procedure CMMouseLeave(var M: TMessage); message CM_MOUSELEAVE;
  protected
    procedure Paint; override;
    procedure Resize; override;
    procedure CreateWnd; override;
    procedure DestroyWnd; override;
    procedure Loaded; override;
    procedure MouseMove(Shift: TShiftState; X,Y: Integer); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X,Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure BeginUpdate;
    procedure EndUpdate;
    procedure LoadJSON(const JSON: string);
    function SaveJSON: string;
    procedure RequeryData;
    procedure Replay;
    procedure Stop;
    procedure CapturePNG(const FileName: string; Progress: Double = 1);
    procedure CaptureWindowPNG(const FileName: string);
    function GeometryJSON: string;
    function MetricsJSON: string;
    property EffectiveDpi: Integer read FEffectiveDpi;
    property Engine: TDACChartEngine read FEngine;
    property CaptureDirectory: string read FCaptureDirectory write FCaptureDirectory;
    property AnimationRunning: Boolean read FRunning;
  published
    property Align;
    property Anchors;
    property Constraints;
    property Enabled;
    property Visible;
    property TabOrder;
    property TabStop default True;
    property Options: TDACChartOptions read FOptions write SetOptions;
    property DataSource: TDataSource read FDataSource write SetDataSource;
    property OnClick;
    property OnPointHover: TDACChartPointEvent read FOnPointHover write FOnPointHover;
    property OnPointClick: TDACChartPointEvent read FOnPointClick write FOnPointClick;
    property OnFormat: TDACChartFormatEvent read FOnFormat write FOnFormat;
    property OnDataError: TDACChartDataErrorEvent read FOnDataError write FOnDataError;
  end;

procedure RegisterDACChartDataSetAdapter(const Adapter: TDACChartDataSetAdapter);
procedure UnregisterDACChartDataSetAdapter(const Adapter: TDACChartDataSetAdapter);

implementation

uses System.Math, System.DateUtils, System.IOUtils, Vcl.Imaging.pngimage;

var Adapters: TList<TDACChartDataSetAdapter>;
const ChartTimer = $DACA;

procedure RegisterDACChartDataSetAdapter(const Adapter: TDACChartDataSetAdapter);
begin if Adapters.IndexOf(Adapter)<0 then Adapters.Add(Adapter); end;
procedure UnregisterDACChartDataSetAdapter(const Adapter: TDACChartDataSetAdapter);
begin Adapters.Remove(Adapter); end;
constructor TDACChartDataLink.Create(AChart: TDACChart);
begin inherited Create; FChart:=AChart; VisualControl:=False; end;
procedure TDACChartDataLink.ActiveChanged;
begin FChart.RequeryData; end;
procedure TDACChartDataLink.DataSetChanged;
begin FChart.RequeryData; end;
procedure TDACChartDataLink.RecordChanged(Field: TField);
begin FChart.RequeryData; end;
constructor TDACChart.Create(AOwner: TComponent);
begin
  inherited;
  ControlStyle:=ControlStyle+[csOpaque]; DoubleBuffered:=False;
  Width:=720; Height:=420; TabStop:=True;
  FEffectiveDpi:=96; FMouse:=PointF(-1,-1);
  FFront:=TDACChartSurface.Create; FBack:=TDACChartSurface.Create;
  FFrameTimes:=TList<Double>.Create;
  FOptions:=TDACChartOptions.Create; FOptions.OnChange:=OptionsChanged;
  FEngine:=TDACChartEngine.Create; FEngine.OnFormat:=NotifyFormat;
  FDataLink:=TDACChartDataLink.Create(Self);
  FDirty:=True;
end;
destructor TDACChart.Destroy;
begin
  if HandleAllocated then KillTimer(Handle,ChartTimer);
  FOptions.OnChange:=nil; FDataLink.Free; FDataCache.Free;
  FEngine.Free; FOptions.Free; FFront.Free; FBack.Free; FFrameTimes.Free;
  inherited;
end;
procedure TDACChart.SetOptions(V: TDACChartOptions);
begin FOptions.Assign(V); end;
procedure TDACChart.BeginUpdate;
begin FOptions.BeginUpdate; end;
procedure TDACChart.EndUpdate;
begin FOptions.EndUpdate; end;
procedure TDACChart.LoadJSON(const JSON: string);
var Probe: TDACChartEngine;
begin
  { Validate data/encodes before committing the persistent option model. }
  Probe:=TDACChartEngine.Create;
  try Probe.Configure(JSON); finally Probe.Free; end;
  FOptions.JSON:=JSON;
end;
function TDACChart.SaveJSON: string;
begin Result:=FOptions.JSON; end;
procedure TDACChart.OptionsChanged(Sender: TObject);
begin
  FConfigured:=False; FDirty:=True;
  if HandleAllocated and not FPosted then begin FPosted:=True; PostMessage(Handle,WM_APP+$461,0,0); end;
end;
procedure TDACChart.SetDataSource(V: TDataSource);
begin
  if FDataSource=V then Exit;
  if FDataSource<>nil then FDataSource.RemoveFreeNotification(Self);
  FDataSource:=V; FDataLink.DataSource:=V;
  if V<>nil then V.FreeNotification(Self);
  RequeryData;
end;
procedure TDACChart.RequeryData;
begin FDataDirty:=True; OptionsChanged(Self); end;
procedure TDACChart.ReadData;
var A: TDACChartDataSetAdapter; Cursor: TDataSet; Row: TJSONObject;
  Rows: TJSONArray; Field: TField; V: TJSONValue;
begin
  Cursor:=nil; Rows:=TJSONArray.Create;
  try
    if (FDataSource<>nil) and (FDataSource.DataSet<>nil) and FDataSource.DataSet.Active then begin
      for A in Adapters do if A.Supports(FDataSource.DataSet) then begin Cursor:=A.CreateReadCursor(FDataSource.DataSet); Break; end;
      if Cursor=nil then raise EDACChartDataError.Create('DataSource sem adapter independente registrado');
      Cursor.First;
      while not Cursor.Eof do begin
        Row:=TJSONObject.Create; Rows.AddElement(Row);
        for Field in Cursor.Fields do begin
          if Field.IsNull then V:=TJSONNull.Create
          else case Field.DataType of
            ftSmallint,ftInteger,ftWord,ftLargeint,ftAutoInc,ftFloat,ftCurrency,ftBCD,ftFMTBcd:
              V:=TJSONNumber.Create(Field.AsFloat);
            ftDate,ftDateTime,ftTimeStamp: V:=TJSONNumber.Create(DateTimeToUnix(Field.AsDateTime,True)*1000);
            ftBoolean: V:=TJSONBool.Create(Field.AsBoolean);
          else V:=TJSONString.Create(Field.AsString); end;
          Row.AddPair(Field.FieldName,V);
        end;
        Cursor.Next;
      end;
    end;
    FDataCache.Free; FDataCache:=Rows; Rows:=nil; FDataDirty:=False; Inc(FReads);
  finally Cursor.Free; Rows.Free; end;
end;
procedure TDACChart.Configure;
var O,D: TJSONObject; V: TJSONValue;
begin
  if FDataDirty then ReadData;
  O:=FOptions.Clone;
  try
    if FDataSource<>nil then begin
      D:=TJSONObject(CJ(O,'dataset'));
      if D=nil then begin D:=TJSONObject.Create; O.AddPair('dataset',D); end;
      if FDataCache<>nil then CSet(D,'source',TJSONValue(FDataCache.Clone));
    end;
    FEngine.Configure(O.ToJSON); FConfigured:=True;
    V:=CJ(O,'animation');
    FRunning:=((V=nil) or CB(V,True) or (CS(V)='auto')) and not (csDesigning in ComponentState) and HandleAllocated;
    FDuration:=CN(CJ(O,'animationDurationUpdate'),500);
    if FFrames=0 then FDuration:=CN(CJ(O,'animationDuration'),1000);
    FStart:=TStopwatch.GetTimeStamp;
    if FDuration<=0 then FRunning:=False;
    if FRunning then SetTimer(Handle,ChartTimer,33,nil);
  finally O.Free; end;
end;
procedure TDACChart.RenderFrame(const FixedProgress: Double);
var Started: Int64; Progress: Double; Temp: TDACChartSurface; W,H: Integer;
begin
  Started:=TStopwatch.GetTimeStamp;
  if not FConfigured then Configure;
  Progress:=FixedProgress;
  if Progress<0 then begin
    Progress:=1;
    if FRunning then Progress:=Min(1,(TStopwatch.GetTimeStamp-FStart)*1000/TStopwatch.Frequency/FDuration);
    { ECharts global cubicInOut; line entry specialization is applied by series. }
    if Progress<0.5 then Progress:=4*Progress*Progress*Progress else Progress:=1-Power(-2*Progress+2,3)/2;
  end;
  W:=Max(1,Width); H:=Max(1,Height);
  if (FBack.Width<>W) or (FBack.Height<>H) then Inc(FAllocations);
  FEngine.Render(FBack,W,H,FEffectiveDpi,FMouse,Progress);
  Temp:=FFront; FFront:=FBack; FBack:=Temp; FDirty:=False;
  FLastFrameMs:=(TStopwatch.GetTimeStamp-Started)*1000/TStopwatch.Frequency;
  FFrameTimes.Add(FLastFrameMs);
  if FFrameTimes.Count>10000 then FFrameTimes.Delete(0);
  if (Progress>=1) and FRunning then begin FRunning:=False; if HandleAllocated then KillTimer(Handle,ChartTimer); end;
end;
procedure TDACChart.Paint;
begin
  try
    if FDirty or (FFront.Width<>Width) or (FFront.Height<>Height) then RenderFrame;
    if FFront.Width>0 then begin
      FFront.Present(Canvas.Handle); Inc(FFrames);
      if FCaptureDirectory<>'' then begin
        ForceDirectories(FCaptureDirectory);
        FFront.SavePNG(TPath.Combine(FCaptureDirectory,Format('frame-%.6d.png',[FFrames])));
      end;
    end;
  except
    on E: Exception do begin
      if FFront.Width>0 then FFront.Present(Canvas.Handle);
      if Assigned(FOnDataError) then FOnDataError(Self,E) else raise;
    end;
  end;
end;
procedure TDACChart.Resize;
begin inherited; FDirty:=True; if HandleAllocated then Invalidate; end;
procedure TDACChart.CreateWnd;
type TGetDpi = function(W: HWND): UINT; stdcall;
var Proc: TGetDpi;
begin
  inherited; @Proc:=GetProcAddress(GetModuleHandle('user32.dll'),'GetDpiForWindow');
  if Assigned(Proc) then FEffectiveDpi:=Proc(Handle);
  OptionsChanged(Self);
end;
procedure TDACChart.DestroyWnd;
begin KillTimer(Handle,ChartTimer); FRunning:=False; FPosted:=False; inherited; end;
procedure TDACChart.Loaded;
begin inherited; OptionsChanged(Self); end;
procedure TDACChart.WMEraseBkgnd(var M: TWMEraseBkgnd);
begin M.Result:=1; end;
procedure TDACChart.WMTimer(var M: TWMTimer);
begin
  if M.TimerID=ChartTimer then begin FDirty:=True; Invalidate; end else inherited;
end;
procedure TDACChart.WMDpiChanged(var M: TMessage);
begin FEffectiveDpi:=Max(96,LoWord(M.WParam)); FDirty:=True; Invalidate; end;
procedure TDACChart.WMRefresh(var M: TMessage);
begin FPosted:=False; FDirty:=True; Invalidate; end;
procedure TDACChart.CMMouseLeave(var M: TMessage);
begin FMouse:=PointF(-1,-1); FDirty:=True; Invalidate; end;
procedure TDACChart.MouseMove(Shift: TShiftState; X,Y: Integer);
var I: Integer; Mark: TDACChartMark;
begin
  inherited; FMouse:=PointF(X,Y); FDirty:=True; Invalidate;
  I:=FEngine.HitTest(FMouse);
  if (I>=0) and Assigned(FOnPointHover) then begin Mark:=FEngine.Marks[I]; if Mark.SeriesIndex>=0 then FOnPointHover(Self,Mark.SeriesIndex,Mark.DataIndex,Mark.Name,Mark.Value); end;
end;
procedure TDACChart.MouseDown(Button: TMouseButton; Shift: TShiftState; X,Y: Integer);
var I: Integer; Mark: TDACChartMark;
begin
  inherited;
  if Button<>mbLeft then Exit;
  if CanFocus then SetFocus;
  I:=FEngine.HitTest(PointF(X,Y));
  if (I>=0) and Assigned(FOnPointClick) then begin Mark:=FEngine.Marks[I]; if Mark.SeriesIndex>=0 then FOnPointClick(Self,Mark.SeriesIndex,Mark.DataIndex,Mark.Name,Mark.Value); end;
  FEngine.Activate(PointF(X,Y)); FDirty:=True; Invalidate;
end;
procedure TDACChart.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited;
  if Key=VK_ESCAPE then begin FMouse:=PointF(-1,-1); FDirty:=True; Invalidate; Key:=0; end;
end;
procedure TDACChart.Notification(AComponent: TComponent; Operation: TOperation);
begin inherited; if (Operation=opRemove) and (AComponent=FDataSource) then SetDataSource(nil); end;
procedure TDACChart.Replay;
begin FConfigured:=False; OptionsChanged(Self); end;
procedure TDACChart.Stop;
begin FRunning:=False; if HandleAllocated then KillTimer(Handle,ChartTimer); FDirty:=True; if HandleAllocated then Invalidate; end;
procedure TDACChart.CapturePNG(const FileName: string; Progress: Double);
begin RenderFrame(Progress); FFront.SavePNG(FileName); end;
procedure TDACChart.CaptureWindowPNG(const FileName: string);
var B: TBitmap; P: TPngImage; DC: HDC;
begin
  if not HandleAllocated or not IsWindowVisible(Handle) then raise EInvalidOperation.Create('Captura fisica exige janela visivel');
  Update; DC:=GetDC(Handle); B:=TBitmap.Create; P:=TPngImage.Create;
  try
    B.PixelFormat:=pf24bit; B.SetSize(Width,Height);
    BitBlt(B.Canvas.Handle,0,0,Width,Height,DC,0,0,SRCCOPY);
    P.Assign(B); P.SaveToFile(FileName);
  finally P.Free; B.Free; ReleaseDC(Handle,DC); end;
end;
function TDACChart.GeometryJSON: string;
begin if FDirty or not FConfigured then RenderFrame(1); Result:=FEngine.GeometryJSON; end;
function TDACChart.MetricsJSON: string;
var A: TArray<Double>; P95,MaxMs: Double; V: Double; O: TJSONObject;
begin
  A:=FFrameTimes.ToArray; TArray.Sort<Double>(A); P95:=0; MaxMs:=0;
  if Length(A)>0 then begin P95:=A[Min(High(A),Ceil(Length(A)*0.95)-1)]; MaxMs:=A[High(A)]; end;
  O:=TJSONObject.Create;
  try
    O.AddPair('presentations',TJSONNumber.Create(FFrames)); O.AddPair('dataReads',TJSONNumber.Create(FReads));
    O.AddPair('surfaceAllocations',TJSONNumber.Create(FAllocations)); O.AddPair('p95Ms',TJSONNumber.Create(P95));
    O.AddPair('maxMs',TJSONNumber.Create(MaxMs)); O.AddPair('animationRunning',TJSONBool.Create(FRunning));
    O.AddPair('dpi',TJSONNumber.Create(FEffectiveDpi)); O.AddPair('samples',TJSONNumber.Create(Length(A)));
    O.AddPair('gdiObjects',TJSONNumber.Create(GetGuiResources(GetCurrentProcess,0)));
    Result:=O.ToJSON;
  finally O.Free; end;
end;
procedure TDACChart.NotifyFormat(Sender: TObject; const S,P: Integer;
  const Name: string; const Value: Double; var Text: string);
begin if Assigned(FOnFormat) then FOnFormat(Self,S,P,Name,Value,Text); end;

initialization
  Adapters:=TList<TDACChartDataSetAdapter>.Create;
finalization
  Adapters.Free;
end.
