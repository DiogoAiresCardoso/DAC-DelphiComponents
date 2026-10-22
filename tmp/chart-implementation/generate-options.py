from pathlib import Path
p=Path('Source/Controls/DAC.Components.Charts.Options.pas')
groups={
'Text': [('Show','show','Boolean','True'),('Text','text','string',"''"),('Subtext','subtext','string',"''"),('FontFamily','fontFamily','string',"'Arial'"),('FontSize','fontSize','Double','12'),('Color','color','string',"'#333333'"),('Left','left','string',"'auto'"),('Top','top','string',"'auto'"),('Position','position','string',"'top'"),('Formatter','formatter','string',"''"),('Rotate','rotate','Double','0'),('Distance','distance','Double','5')],
'Axis':[('Show','show','Boolean','True'),('AxisType','type','string',"'value'"),('Min','min','string',"'auto'"),('Max','max','string',"'auto'"),('Inverse','inverse','Boolean','False'),('BoundaryGap','boundaryGap','Boolean','True'),('SplitNumber','splitNumber','Double','5'),('Name','name','string',"''")],
'Style':[('Color','color','string',"''"),('Opacity','opacity','Double','1'),('Width','width','Double','2'),('BorderColor','borderColor','string',"''"),('BorderWidth','borderWidth','Double','0'),('BorderRadius','borderRadius','Double','0'),('ShadowBlur','shadowBlur','Double','0'),('ShadowColor','shadowColor','string',"'transparent'"),('ShadowOffsetX','shadowOffsetX','Double','0'),('ShadowOffsetY','shadowOffsetY','Double','0')],
'Legend':[('Show','show','Boolean','True'),('LegendType','type','string',"'plain'"),('Orient','orient','string',"'horizontal'"),('Left','left','string',"'center'"),('Top','top','string',"'0'"),('ItemGap','itemGap','Double','10'),('ItemWidth','itemWidth','Double','25'),('ItemHeight','itemHeight','Double','14')],
'Tooltip':[('Show','show','Boolean','True'),('Trigger','trigger','string',"'item'"),('TriggerOn','triggerOn','string',"'mousemove|click'"),('Confine','confine','Boolean','True'),('Formatter','formatter','string',"''"),('ShowDelay','showDelay','Double','0'),('HideDelay','hideDelay','Double','100'),('BackgroundColor','backgroundColor','string',"'#ffffff'"),('BorderColor','borderColor','string',"'#cccccc'"),('Padding','padding','Double','10')],
'Grid':[('Left','left','string',"'10%'"),('Right','right','string',"'10%'"),('Top','top','string',"'60'"),('Bottom','bottom','string',"'70'"),('OuterBoundsMode','outerBoundsMode','string',"'auto'")]
}
s='''unit DAC.Components.Charts.Options;

interface

uses System.Classes, System.SysUtils, System.JSON, System.Generics.Collections;

type
  EDACChartOptionError = class(Exception);
  TDACChartOptionStore = class;
  TDACChartOptionNode = class(TPersistent)
  protected
    FStore: TDACChartOptionStore;
    FPath: string;
    function Path(const AKey: string): string;
    function GetJSON: string;
    procedure SetJSON(const AValue: string);
  public
    constructor Create(AStore: TDACChartOptionStore; const APath: string);
    procedure Assign(Source: TPersistent); override;
  published
    property JSON: string read GetJSON write SetJSON;
  end;

  TDACChartOptionStore = class
  private
    FRoot: TJSONObject;
    FOnChange: TNotifyEvent;
  public
    constructor Create;
    destructor Destroy; override;
    function Read(const APath: string): TJSONValue;
    procedure Write(const APath: string; AValue: TJSONValue);
    procedure Load(const AJSON: string);
    function Clone: TJSONObject;
    property Root: TJSONObject read FRoot;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;
'''
for name,props in groups.items():
 s+=f'  TDACChart{name}Options = class(TDACChartOptionNode)\n  private\n'
 for n,k,t,d in props:s+=f'    function Get{n}: {t};\n    procedure Set{n}(const AValue: {t});\n'
 s+='  published\n'
 for n,k,t,d in props:s+=f'    property {n}: {t} read Get{n} write Set{n} stored False;\n'
 s+='  end;\n\n'
s+='''  TDACChartOptionSeries = class(TCollectionItem)
  private
    FStore: TDACChartOptionStore;
    FItemStyle, FLineStyle, FAreaStyle: TDACChartStyleOptions;
    FLabel: TDACChartTextOptions;
    function GetJSON: string;
    procedure SetJSON(const V: string);
    function GetName: string;
    procedure SetName(const V: string);
    function GetKind: string;
    procedure SetKind(const V: string);
    function GetStack: string;
    procedure SetStack(const V: string);
    procedure StoreChanged(Sender: TObject);
    procedure SetItemStyle(V: TDACChartStyleOptions);
    procedure SetLineStyle(V: TDACChartStyleOptions);
    procedure SetAreaStyle(V: TDACChartStyleOptions);
    procedure SetLabel(V: TDACChartTextOptions);
  protected
    function GetDisplayName: string; override;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    property Store: TDACChartOptionStore read FStore;
  published
    property JSON: string read GetJSON write SetJSON;
    property Name: string read GetName write SetName stored False;
    property Kind: string read GetKind write SetKind stored False;
    property Stack: string read GetStack write SetStack stored False;
    property ItemStyle: TDACChartStyleOptions read FItemStyle write SetItemStyle stored False;
    property LineStyle: TDACChartStyleOptions read FLineStyle write SetLineStyle stored False;
    property AreaStyle: TDACChartStyleOptions read FAreaStyle write SetAreaStyle stored False;
    property LabelStyle: TDACChartTextOptions read FLabel write SetLabel stored False;
  end;
  TDACChartOptionSeriesCollection = class(TOwnedCollection)
  private
    FOnChange: TNotifyEvent;
    function GetItem(I: Integer): TDACChartOptionSeries;
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent);
    function Add: TDACChartOptionSeries;
    property Items[I: Integer]: TDACChartOptionSeries read GetItem; default;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;
  TDACChartOptions = class(TPersistent)
  private
    FStore: TDACChartOptionStore;
    FSeries: TDACChartOptionSeriesCollection;
    FTitle: TDACChartTextOptions;
    FXAxis, FYAxis: TDACChartAxisOptions;
    FGrid: TDACChartGridOptions;
    FLegend: TDACChartLegendOptions;
    FTooltip: TDACChartTooltipOptions;
    FOnChange: TNotifyEvent;
    FUpdateCount: Integer;
    FDirty: Boolean;
    procedure Changed(Sender: TObject);
    function GetJSON: string;
    procedure SetJSON(const V: string);
    procedure SetSeries(V: TDACChartOptionSeriesCollection);
'''
for n,t in [('Title','Text'),('XAxis','Axis'),('YAxis','Axis'),('Grid','Grid'),('Legend','Legend'),('Tooltip','Tooltip')]:s+=f'    procedure Set{n}(V: TDACChart{t}Options);\n'
s+='''  public
    constructor Create;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    procedure BeginUpdate;
    procedure EndUpdate;
    function Clone: TJSONObject;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  published
    property JSON: string read GetJSON write SetJSON;
    property Series: TDACChartOptionSeriesCollection read FSeries write SetSeries stored False;
'''
for n,t in [('Title','Text'),('XAxis','Axis'),('YAxis','Axis'),('Grid','Grid'),('Legend','Legend'),('Tooltip','Tooltip')]:s+=f'    property {n}: TDACChart{t}Options read F{n} write Set{n} stored False;\n'
s+='''  end;

function CJ(const V: TJSONValue; const Key: string): TJSONValue;
function CS(const V: TJSONValue; const Default: string = ''): string;
function CN(const V: TJSONValue; const Default: Double = 0): Double;
function CB(const V: TJSONValue; const Default: Boolean = False): Boolean;
procedure CSet(O: TJSONObject; const K: string; V: TJSONValue);
procedure ValidateChartOptions(O: TJSONObject);

implementation

function CJ(const V: TJSONValue; const Key: string): TJSONValue;
begin
  Result := nil;
  if V is TJSONObject then Result := TJSONObject(V).GetValue(Key);
end;
function CS(const V: TJSONValue; const Default: string): string;
begin
  Result := Default;
  if (V <> nil) and not (V is TJSONNull) then Result := V.Value;
end;
function CN(const V: TJSONValue; const Default: Double): Double;
begin
  Result := StrToFloatDef(CS(V), Default, TFormatSettings.Invariant);
end;
function CB(const V: TJSONValue; const Default: Boolean): Boolean;
begin
  Result := Default;
  if V <> nil then Result := SameText(V.Value, 'true');
end;
procedure CSet(O: TJSONObject; const K: string; V: TJSONValue);
var P: TJSONPair;
begin
  P := O.RemovePair(K); P.Free;
  O.AddPair(K,V);
end;
procedure ValidateChartOptions(O: TJSONObject);
var A: TJSONArray; I: Integer; V: TJSONValue; K: string;
begin
  for K in ['dataZoom','visualMap','geo','polar','radar','toolbox'] do
    if CJ(O,K) <> nil then raise EDACChartOptionError.Create(K + ': recurso ainda nao suportado');
  for K in ['xAxis','yAxis','grid','dataset','title','legend','tooltip'] do
    if (CJ(O,K) <> nil) and not (CJ(O,K) is TJSONObject) then
      raise EDACChartOptionError.Create(K + ': esperado objeto unico');
  V := CJ(O,'series');
  if V = nil then Exit;
  if not (V is TJSONArray) then raise EDACChartOptionError.Create('series: esperado array');
  A := TJSONArray(V);
  for I := 0 to A.Count-1 do begin
    if not (A.Items[I] is TJSONObject) then raise EDACChartOptionError.CreateFmt('series[%d]: esperado objeto',[I]);
    K := CS(CJ(A.Items[I],'type'),'bar');
    if (K <> 'bar') and (K <> 'line') and (K <> 'pie') then
      raise EDACChartOptionError.CreateFmt('series[%d].type: %s nao suportado',[I,K]);
    if (CN(CJ(A.Items[I],'xAxisIndex')) <> 0) or (CN(CJ(A.Items[I],'yAxisIndex')) <> 0) then
      raise EDACChartOptionError.CreateFmt('series[%d]: multiplos eixos nao suportados',[I]);
  end;
end;
constructor TDACChartOptionStore.Create;
begin inherited; FRoot := TJSONObject.Create; end;
destructor TDACChartOptionStore.Destroy;
begin FRoot.Free; inherited; end;
function TDACChartOptionStore.Read(const APath: string): TJSONValue;
var K: string;
begin
  Result := FRoot;
  if APath <> '' then for K in APath.Split(['.']) do Result := CJ(Result,K);
end;
procedure TDACChartOptionStore.Write(const APath: string; AValue: TJSONValue);
var Parts: TArray<string>; I: Integer; O,N: TJSONObject;
begin
  if APath = '' then begin
    if not (AValue is TJSONObject) then begin AValue.Free; raise EDACChartOptionError.Create('Esperado objeto'); end;
    FRoot.Free; FRoot := TJSONObject(AValue);
  end else begin
    Parts := APath.Split(['.']); O := FRoot;
    for I := 0 to High(Parts)-1 do begin
      if not (CJ(O,Parts[I]) is TJSONObject) then begin
        N := TJSONObject.Create; CSet(O,Parts[I],N);
      end;
      O := TJSONObject(CJ(O,Parts[I]));
    end;
    CSet(O,Parts[High(Parts)],AValue);
  end;
  if Assigned(FOnChange) then FOnChange(Self);
end;
procedure TDACChartOptionStore.Load(const AJSON: string);
var V: TJSONValue;
begin
  V := TJSONObject.ParseJSONValue(AJSON);
  if not (V is TJSONObject) then begin V.Free; raise EDACChartOptionError.Create('JSON: esperado objeto valido'); end;
  Write('',V);
end;
function TDACChartOptionStore.Clone: TJSONObject;
begin Result := TJSONObject(FRoot.Clone); end;
constructor TDACChartOptionNode.Create(AStore: TDACChartOptionStore; const APath: string);
begin inherited Create; FStore := AStore; FPath := APath; end;
function TDACChartOptionNode.Path(const AKey: string): string;
begin if FPath = '' then Result := AKey else Result := FPath+'.'+AKey; end;
function TDACChartOptionNode.GetJSON: string;
var V: TJSONValue;
begin V := FStore.Read(FPath); if V = nil then Result := '{}' else Result := V.ToJSON; end;
procedure TDACChartOptionNode.SetJSON(const AValue: string);
var V: TJSONValue;
begin
  V := TJSONObject.ParseJSONValue(AValue);
  if not (V is TJSONObject) then begin V.Free; raise EDACChartOptionError.Create(FPath+': esperado objeto'); end;
  FStore.Write(FPath,V);
end;
procedure TDACChartOptionNode.Assign(Source: TPersistent);
begin if Source is TDACChartOptionNode then SetJSON(TDACChartOptionNode(Source).JSON) else inherited; end;
'''
for name,props in groups.items():
 for n,k,t,d in props:
  conv={'string':'CS','Double':'CN','Boolean':'CB'}[t]
  typ={'string':'TJSONString','Double':'TJSONNumber','Boolean':'TJSONBool'}[t]
  s+=f'''function TDACChart{name}Options.Get{n}: {t};
begin Result := {conv}(FStore.Read(Path('{k}')), {d}); end;
procedure TDACChart{name}Options.Set{n}(const AValue: {t});
begin FStore.Write(Path('{k}'), {typ}.Create(AValue)); end;
'''
s+='''constructor TDACChartOptionSeries.Create(Collection: TCollection);
begin
  inherited; FStore := TDACChartOptionStore.Create;
  FItemStyle := TDACChartStyleOptions.Create(FStore,'itemStyle');
  FLineStyle := TDACChartStyleOptions.Create(FStore,'lineStyle');
  FAreaStyle := TDACChartStyleOptions.Create(FStore,'areaStyle');
  FLabel := TDACChartTextOptions.Create(FStore,'label');
  FStore.Load('{"type":"bar","data":[]}'); FStore.OnChange := StoreChanged;
end;
destructor TDACChartOptionSeries.Destroy;
begin FLabel.Free; FAreaStyle.Free; FLineStyle.Free; FItemStyle.Free; FStore.Free; inherited; end;
procedure TDACChartOptionSeries.StoreChanged(Sender: TObject);
begin Changed(False); end;
function TDACChartOptionSeries.GetJSON: string;
begin Result := FStore.Root.ToJSON; end;
procedure TDACChartOptionSeries.SetJSON(const V: string);
begin FStore.Load(V); end;
function TDACChartOptionSeries.GetDisplayName: string;
begin Result := GetName; if Result = '' then Result := GetKind; end;
procedure TDACChartOptionSeries.Assign(Source: TPersistent);
begin if Source is TDACChartOptionSeries then SetJSON(TDACChartOptionSeries(Source).JSON) else inherited; end;
'''
for n,k in [('Name','name'),('Kind','type'),('Stack','stack')]:s+=f'''function TDACChartOptionSeries.Get{n}: string;
begin Result := CS(FStore.Read('{k}')); end;
procedure TDACChartOptionSeries.Set{n}(const V: string);
begin FStore.Write('{k}',TJSONString.Create(V)); end;
'''
for n,t,f in [('ItemStyle','Style','ItemStyle'),('LineStyle','Style','LineStyle'),('AreaStyle','Style','AreaStyle'),('Label','Text','Label')]:s+=f'procedure TDACChartOptionSeries.Set{n}(V: TDACChart{t}Options);\nbegin F{f}.Assign(V); end;\n'
s+='''constructor TDACChartOptionSeriesCollection.Create(AOwner: TPersistent);
begin inherited Create(AOwner,TDACChartOptionSeries); end;
function TDACChartOptionSeriesCollection.Add: TDACChartOptionSeries;
begin Result := TDACChartOptionSeries(inherited Add); end;
function TDACChartOptionSeriesCollection.GetItem(I: Integer): TDACChartOptionSeries;
begin Result := TDACChartOptionSeries(inherited Items[I]); end;
procedure TDACChartOptionSeriesCollection.Update(Item: TCollectionItem);
begin inherited; if Assigned(FOnChange) then FOnChange(Self); end;
constructor TDACChartOptions.Create;
begin
  inherited; FStore := TDACChartOptionStore.Create; FStore.OnChange := Changed;
  FSeries := TDACChartOptionSeriesCollection.Create(Self); FSeries.OnChange := Changed;
'''
for n,t in [('Title','Text'),('XAxis','Axis'),('YAxis','Axis'),('Grid','Grid'),('Legend','Legend'),('Tooltip','Tooltip')]:s+=f"  F{n} := TDACChart{t}Options.Create(FStore,'{n[0].lower()+n[1:]}');\n"
s+='''end;
destructor TDACChartOptions.Destroy;
begin
  FOnChange := nil; FSeries.OnChange := nil;
  FTooltip.Free; FLegend.Free; FGrid.Free; FYAxis.Free; FXAxis.Free; FTitle.Free;
  FSeries.Free; FStore.Free; inherited;
end;
procedure TDACChartOptions.BeginUpdate;
begin Inc(FUpdateCount); end;
procedure TDACChartOptions.EndUpdate;
begin
  if FUpdateCount = 0 then raise EInvalidOperation.Create('EndUpdate sem BeginUpdate');
  Dec(FUpdateCount); if (FUpdateCount = 0) and FDirty then Changed(Self);
end;
procedure TDACChartOptions.Changed(Sender: TObject);
begin
  FDirty := True;
  if FUpdateCount > 0 then Exit;
  FDirty := False; if Assigned(FOnChange) then FOnChange(Self);
end;
function TDACChartOptions.Clone: TJSONObject;
var A: TJSONArray; I: Integer;
begin
  Result := FStore.Clone; A := TJSONArray.Create;
  for I := 0 to FSeries.Count-1 do A.AddElement(FSeries[I].Store.Clone);
  CSet(Result,'series',A);
end;
function TDACChartOptions.GetJSON: string;
var O: TJSONObject;
begin O := Clone; try Result := O.ToJSON; finally O.Free; end; end;
procedure TDACChartOptions.SetJSON(const V: string);
var O: TJSONValue; A: TJSONArray; I: Integer;
begin
  O := TJSONObject.ParseJSONValue(V);
  try
    if not (O is TJSONObject) then raise EDACChartOptionError.Create('JSON: esperado objeto valido');
    ValidateChartOptions(TJSONObject(O));
    BeginUpdate;
    try
      FStore.Load(V); FSeries.Clear;
      A := TJSONArray(CJ(O,'series'));
      if A <> nil then for I := 0 to A.Count-1 do FSeries.Add.JSON := A.Items[I].ToJSON;
    finally EndUpdate; end;
  finally O.Free; end;
end;
procedure TDACChartOptions.Assign(Source: TPersistent);
begin if Source is TDACChartOptions then JSON := TDACChartOptions(Source).JSON else inherited; end;
procedure TDACChartOptions.SetSeries(V: TDACChartOptionSeriesCollection);
begin FSeries.Assign(V); end;
'''
for n,t in [('Title','Text'),('XAxis','Axis'),('YAxis','Axis'),('Grid','Grid'),('Legend','Legend'),('Tooltip','Tooltip')]:s+=f'procedure TDACChartOptions.Set{n}(V: TDACChart{t}Options);\nbegin F{n}.Assign(V); end;\n'
s+='end.\n'
p.write_bytes(s.replace('\n','\r\n').encode('cp1252'))
