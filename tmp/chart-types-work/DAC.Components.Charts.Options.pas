unit DAC.Components.Charts.Options;

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
  TDACChartTextOptions = class(TDACChartOptionNode)
  protected
    function GetShow: Boolean;
    procedure SetShow(const AValue: Boolean);
    function GetText: string;
    procedure SetText(const AValue: string);
    function GetSubtext: string;
    procedure SetSubtext(const AValue: string);
    function GetFontFamily: string;
    procedure SetFontFamily(const AValue: string);
    function GetFontSize: Double;
    procedure SetFontSize(const AValue: Double);
    function GetColor: string;
    procedure SetColor(const AValue: string);
    function GetLeft: string;
    procedure SetLeft(const AValue: string);
    function GetTop: string;
    procedure SetTop(const AValue: string);
    function GetPosition: string;
    procedure SetPosition(const AValue: string);
    function GetFormatter: string;
    procedure SetFormatter(const AValue: string);
    function GetRotate: Double;
    procedure SetRotate(const AValue: Double);
    function GetDistance: Double;
    procedure SetDistance(const AValue: Double);
  public
    property Show: Boolean read GetShow write SetShow stored False;
    property Text: string read GetText write SetText stored False;
    property Subtext: string read GetSubtext write SetSubtext stored False;
    property FontFamily: string read GetFontFamily write SetFontFamily stored False;
    property FontSize: Double read GetFontSize write SetFontSize stored False;
    property Color: string read GetColor write SetColor stored False;
    property Left: string read GetLeft write SetLeft stored False;
    property Top: string read GetTop write SetTop stored False;
    property Position: string read GetPosition write SetPosition stored False;
    property Formatter: string read GetFormatter write SetFormatter stored False;
    property Rotate: Double read GetRotate write SetRotate stored False;
    property Distance: Double read GetDistance write SetDistance stored False;
  end;

  TDACChartTitleOptions = class(TDACChartTextOptions)
  published
    property Show;
    property Text;
    property Subtext;
    property FontFamily;
    property FontSize;
    property Color;
    property Left;
    property Top;
  end;
  TDACChartLabelOptions = class(TDACChartTextOptions)
  published
    property Show;
    property FontFamily;
    property FontSize;
    property Color;
    property Position;
    property Formatter;
    property Rotate;
    property Distance;
  end;

  TDACChartAxisOptions = class(TDACChartOptionNode)
  private
    function GetShow: Boolean;
    procedure SetShow(const AValue: Boolean);
    function GetAxisType: string;
    procedure SetAxisType(const AValue: string);
    function GetMin: string;
    procedure SetMin(const AValue: string);
    function GetMax: string;
    procedure SetMax(const AValue: string);
    function GetInverse: Boolean;
    procedure SetInverse(const AValue: Boolean);
    function GetBoundaryGap: Boolean;
    procedure SetBoundaryGap(const AValue: Boolean);
    function GetSplitNumber: Double;
    procedure SetSplitNumber(const AValue: Double);
    function GetName: string;
    procedure SetName(const AValue: string);
  published
    property Show: Boolean read GetShow write SetShow stored False;
    property AxisType: string read GetAxisType write SetAxisType stored False;
    property Min: string read GetMin write SetMin stored False;
    property Max: string read GetMax write SetMax stored False;
    property Inverse: Boolean read GetInverse write SetInverse stored False;
    property BoundaryGap: Boolean read GetBoundaryGap write SetBoundaryGap stored False;
    property SplitNumber: Double read GetSplitNumber write SetSplitNumber stored False;
    property Name: string read GetName write SetName stored False;
  end;

  TDACChartStyleOptions = class(TDACChartOptionNode)
  private
    function GetColor: string;
    procedure SetColor(const AValue: string);
    function GetOpacity: Double;
    procedure SetOpacity(const AValue: Double);
    function GetWidth: Double;
    procedure SetWidth(const AValue: Double);
    function GetBorderColor: string;
    procedure SetBorderColor(const AValue: string);
    function GetBorderWidth: Double;
    procedure SetBorderWidth(const AValue: Double);
    function GetBorderRadius: Double;
    procedure SetBorderRadius(const AValue: Double);
    function GetShadowBlur: Double;
    procedure SetShadowBlur(const AValue: Double);
    function GetShadowColor: string;
    procedure SetShadowColor(const AValue: string);
    function GetShadowOffsetX: Double;
    procedure SetShadowOffsetX(const AValue: Double);
    function GetShadowOffsetY: Double;
    procedure SetShadowOffsetY(const AValue: Double);
  published
    property Color: string read GetColor write SetColor stored False;
    property Opacity: Double read GetOpacity write SetOpacity stored False;
    property Width: Double read GetWidth write SetWidth stored False;
    property BorderColor: string read GetBorderColor write SetBorderColor stored False;
    property BorderWidth: Double read GetBorderWidth write SetBorderWidth stored False;
    property BorderRadius: Double read GetBorderRadius write SetBorderRadius stored False;
    property ShadowBlur: Double read GetShadowBlur write SetShadowBlur stored False;
    property ShadowColor: string read GetShadowColor write SetShadowColor stored False;
    property ShadowOffsetX: Double read GetShadowOffsetX write SetShadowOffsetX stored False;
    property ShadowOffsetY: Double read GetShadowOffsetY write SetShadowOffsetY stored False;
  end;

  TDACChartLegendOptions = class(TDACChartOptionNode)
  private
    function GetShow: Boolean;
    procedure SetShow(const AValue: Boolean);
    function GetLegendType: string;
    procedure SetLegendType(const AValue: string);
    function GetOrient: string;
    procedure SetOrient(const AValue: string);
    function GetLeft: string;
    procedure SetLeft(const AValue: string);
    function GetTop: string;
    procedure SetTop(const AValue: string);
    function GetItemGap: Double;
    procedure SetItemGap(const AValue: Double);
    function GetItemWidth: Double;
    procedure SetItemWidth(const AValue: Double);
    function GetItemHeight: Double;
    procedure SetItemHeight(const AValue: Double);
  published
    property Show: Boolean read GetShow write SetShow stored False;
    property LegendType: string read GetLegendType write SetLegendType stored False;
    property Orient: string read GetOrient write SetOrient stored False;
    property Left: string read GetLeft write SetLeft stored False;
    property Top: string read GetTop write SetTop stored False;
    property ItemGap: Double read GetItemGap write SetItemGap stored False;
    property ItemWidth: Double read GetItemWidth write SetItemWidth stored False;
    property ItemHeight: Double read GetItemHeight write SetItemHeight stored False;
  end;

  TDACChartTooltipOptions = class(TDACChartOptionNode)
  private
    function GetShow: Boolean;
    procedure SetShow(const AValue: Boolean);
    function GetTrigger: string;
    procedure SetTrigger(const AValue: string);
    function GetTriggerOn: string;
    procedure SetTriggerOn(const AValue: string);
    function GetConfine: Boolean;
    procedure SetConfine(const AValue: Boolean);
    function GetFormatter: string;
    procedure SetFormatter(const AValue: string);
    function GetShowDelay: Double;
    procedure SetShowDelay(const AValue: Double);
    function GetHideDelay: Double;
    procedure SetHideDelay(const AValue: Double);
    function GetBackgroundColor: string;
    procedure SetBackgroundColor(const AValue: string);
    function GetBorderColor: string;
    procedure SetBorderColor(const AValue: string);
    function GetPadding: Double;
    procedure SetPadding(const AValue: Double);
  published
    property Show: Boolean read GetShow write SetShow stored False;
    property Trigger: string read GetTrigger write SetTrigger stored False;
    property TriggerOn: string read GetTriggerOn write SetTriggerOn stored False;
    property Confine: Boolean read GetConfine write SetConfine stored False;
    property Formatter: string read GetFormatter write SetFormatter stored False;
    property ShowDelay: Double read GetShowDelay write SetShowDelay stored False;
    property HideDelay: Double read GetHideDelay write SetHideDelay stored False;
    property BackgroundColor: string read GetBackgroundColor write SetBackgroundColor stored False;
    property BorderColor: string read GetBorderColor write SetBorderColor stored False;
    property Padding: Double read GetPadding write SetPadding stored False;
  end;

  TDACChartGridOptions = class(TDACChartOptionNode)
  private
    function GetLeft: string;
    procedure SetLeft(const AValue: string);
    function GetRight: string;
    procedure SetRight(const AValue: string);
    function GetTop: string;
    procedure SetTop(const AValue: string);
    function GetBottom: string;
    procedure SetBottom(const AValue: string);
    function GetOuterBoundsMode: string;
    procedure SetOuterBoundsMode(const AValue: string);
  published
    property Left: string read GetLeft write SetLeft stored False;
    property Right: string read GetRight write SetRight stored False;
    property Top: string read GetTop write SetTop stored False;
    property Bottom: string read GetBottom write SetBottom stored False;
    property OuterBoundsMode: string read GetOuterBoundsMode write SetOuterBoundsMode stored False;
  end;

  TDACChartOptionSeries = class(TCollectionItem)
  private
    FStore: TDACChartOptionStore;
    FItemStyle, FLineStyle, FAreaStyle: TDACChartStyleOptions;
    FLabel: TDACChartLabelOptions;
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
    procedure SetLabel(V: TDACChartLabelOptions);
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
    property LabelStyle: TDACChartLabelOptions read FLabel write SetLabel stored False;
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
    FTitle: TDACChartTitleOptions;
    FDataset: TDACChartOptionNode;
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
    procedure SetDataset(V: TDACChartOptionNode);
    procedure SetTitle(V: TDACChartTitleOptions);
    procedure SetXAxis(V: TDACChartAxisOptions);
    procedure SetYAxis(V: TDACChartAxisOptions);
    procedure SetGrid(V: TDACChartGridOptions);
    procedure SetLegend(V: TDACChartLegendOptions);
    procedure SetTooltip(V: TDACChartTooltipOptions);
  public
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
    property Dataset: TDACChartOptionNode read FDataset write SetDataset stored False;
    property Title: TDACChartTitleOptions read FTitle write SetTitle stored False;
    property XAxis: TDACChartAxisOptions read FXAxis write SetXAxis stored False;
    property YAxis: TDACChartAxisOptions read FYAxis write SetYAxis stored False;
    property Grid: TDACChartGridOptions read FGrid write SetGrid stored False;
    property Legend: TDACChartLegendOptions read FLegend write SetLegend stored False;
    property Tooltip: TDACChartTooltipOptions read FTooltip write SetTooltip stored False;
  end;

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
  if V is TJSONNumber then Exit(TJSONNumber(V).AsDouble);
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
  procedure Keys(Value: TJSONValue; const Location,Allowed: string);
  var P: TJSONPair;
  begin
    if Value=nil then Exit;
    if not (Value is TJSONObject) then raise EDACChartOptionError.Create(Location+': esperado objeto');
    for P in TJSONObject(Value) do
      if Pos('|'+P.JsonString.Value+'|','|'+Allowed+'|')=0 then
        raise EDACChartOptionError.Create(Location+'.'+P.JsonString.Value+': opcao ainda nao suportada');
  end;
  procedure Style(Value: TJSONValue; const Location: string);
  begin
    Keys(Value,Location,'color|opacity|width|type|borderColor|borderWidth|borderRadius|shadowBlur|shadowColor|shadowOffsetX|shadowOffsetY');
    if (CJ(Value,'opacity')<>nil) and ((CN(CJ(Value,'opacity'))<0) or (CN(CJ(Value,'opacity'))>1)) then
      raise EDACChartOptionError.Create(Location+'.opacity: esperado 0..1');
  end;
  procedure LabelOptions(Value: TJSONValue; const Location: string);
  var P: TJSONPair;
  begin
    Keys(Value,Location,'show|position|distance|formatter|rotate|color|fontFamily|fontSize|fontWeight|fontStyle|lineHeight|width|height|padding|align|verticalAlign|overflow|backgroundColor|borderColor|borderWidth|'+
      'borderRadius|shadowBlur|shadowColor|shadowOffsetX|shadowOffsetY|rich|interval|margin');
    if CJ(Value,'rich') is TJSONObject then for P in TJSONObject(CJ(Value,'rich')) do
      LabelOptions(P.JsonValue,Location+'.rich.'+P.JsonString.Value);
  end;
begin
  Keys(O,'option','animation|animationDuration|animationDurationUpdate|animationEasing|animationEasingUpdate|animationThreshold|backgroundColor|color|useUTC|dataset|series|xAxis|yAxis|grid|title|legend|tooltip');
  for K in TArray<string>.Create('dataZoom','visualMap','geo','polar','radar','toolbox') do
    if CJ(O,K) <> nil then raise EDACChartOptionError.Create(K + ': recurso ainda nao suportado');
  for K in TArray<string>.Create('xAxis','yAxis','grid','dataset','title','legend','tooltip') do
    if (CJ(O,K) <> nil) and not (CJ(O,K) is TJSONObject) then
      raise EDACChartOptionError.Create(K + ': esperado objeto unico');
  Keys(CJ(O,'dataset'),'dataset','source|dimensions|sourceHeader');
  Keys(CJ(O,'grid'),'grid','left|right|top|bottom|outerBoundsMode');
  if (CJ(CJ(O,'grid'),'outerBoundsMode')<>nil) and (CS(CJ(CJ(O,'grid'),'outerBoundsMode'))<>'none') then
    raise EDACChartOptionError.Create('grid.outerBoundsMode: somente none nesta etapa');
  Keys(CJ(O,'title'),'title','show|text|subtext|left|top|itemGap|textStyle|subtextStyle');
  LabelOptions(CJ(CJ(O,'title'),'textStyle'),'title.textStyle');
  LabelOptions(CJ(CJ(O,'title'),'subtextStyle'),'title.subtextStyle');
  Keys(CJ(O,'legend'),'legend','show|type|orient|left|top|itemGap|itemWidth|itemHeight|textStyle|selected|selectedMode');
  Keys(CJ(O,'tooltip'),'tooltip','show|trigger|triggerOn|confine|renderMode|formatter|showDelay|hideDelay|backgroundColor|borderColor|padding|textStyle|axisPointer');
  if (CJ(CJ(O,'tooltip'),'confine')<>nil) and not CB(CJ(CJ(O,'tooltip'),'confine')) then
    raise EDACChartOptionError.Create('tooltip.confine: perfil nativo exige true');
  if (CJ(CJ(O,'tooltip'),'renderMode')<>nil) and (CS(CJ(CJ(O,'tooltip'),'renderMode'))<>'richText') then
    raise EDACChartOptionError.Create('tooltip.renderMode: somente richText nativo');
  for K in TArray<string>.Create('xAxis','yAxis') do begin
    V:=CJ(O,K);
    Keys(V,K,'type|data|min|max|inverse|boundaryGap|splitNumber|interval|scale|show|name|nameTextStyle|axisLine|axisLabel|axisTick|splitLine');
    if (CJ(V,'type')<>nil) and (CS(CJ(V,'type'))<>'category') and (CS(CJ(V,'type'))<>'value') and (CS(CJ(V,'type'))<>'time') then
      raise EDACChartOptionError.Create(K+'.type: somente category/value/time');
    LabelOptions(CJ(V,'axisLabel'),K+'.axisLabel');
    Style(CJ(CJ(V,'axisLine'),'lineStyle'),K+'.axisLine.lineStyle');
    Style(CJ(CJ(V,'splitLine'),'lineStyle'),K+'.splitLine.lineStyle');
  end;
  V := CJ(O,'series');
  if V = nil then Exit;
  if not (V is TJSONArray) then raise EDACChartOptionError.Create('series: esperado array');
  A := TJSONArray(V);
  for I := 0 to A.Count-1 do begin
    if not (A.Items[I] is TJSONObject) then raise EDACChartOptionError.CreateFmt('series[%d]: esperado objeto',[I]);
    Keys(A.Items[I],Format('series[%d]',[I]),'id|name|type|data|datasetIndex|seriesLayoutBy|encode|itemStyle|lineStyle|areaStyle|label|labelLine|labelLayout|emphasis|blur|select|selectedMode|selectedOffset|smooth|smoothMonotone|step|connectNulls|symbol|symbolSize|'+
      'showSymbol|barWidth|barMinWidth|barMaxWidth|barMinHeight|barGap|barCategoryGap|stack|stackStrategy|center|radius|startAngle|clockwise|'+
      'stillShowZeroSum|showEmptyCircle|emptyCircleStyle|percentPrecision|avoidLabelOverlap');
    Style(CJ(A.Items[I],'itemStyle'),Format('series[%d].itemStyle',[I]));
    Style(CJ(A.Items[I],'lineStyle'),Format('series[%d].lineStyle',[I]));
    Style(CJ(A.Items[I],'areaStyle'),Format('series[%d].areaStyle',[I]));
    LabelOptions(CJ(A.Items[I],'label'),Format('series[%d].label',[I]));
    if CN(CJ(A.Items[I],'datasetIndex'))<>0 then raise EDACChartOptionError.Create('series.datasetIndex: somente dataset 0');
    if (CJ(A.Items[I],'stackStrategy')<>nil) and (CS(CJ(A.Items[I],'stackStrategy'))<>'samesign') then
      raise EDACChartOptionError.Create('series.stackStrategy: somente samesign');
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
begin
  if FPath = '' then Result := AKey else Result := FPath+'.'+AKey;
  if (FPath='title') and ((AKey='fontFamily') or (AKey='fontSize') or (AKey='color')) then Result:='title.textStyle.'+AKey;
end;
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
function TDACChartTextOptions.GetShow: Boolean;
begin Result := CB(FStore.Read(Path('show')), True); end;
procedure TDACChartTextOptions.SetShow(const AValue: Boolean);
begin FStore.Write(Path('show'), TJSONBool.Create(AValue)); end;
function TDACChartTextOptions.GetText: string;
begin Result := CS(FStore.Read(Path('text')), ''); end;
procedure TDACChartTextOptions.SetText(const AValue: string);
begin FStore.Write(Path('text'), TJSONString.Create(AValue)); end;
function TDACChartTextOptions.GetSubtext: string;
begin Result := CS(FStore.Read(Path('subtext')), ''); end;
procedure TDACChartTextOptions.SetSubtext(const AValue: string);
begin FStore.Write(Path('subtext'), TJSONString.Create(AValue)); end;
function TDACChartTextOptions.GetFontFamily: string;
begin Result := CS(FStore.Read(Path('fontFamily')), 'Arial'); end;
procedure TDACChartTextOptions.SetFontFamily(const AValue: string);
begin FStore.Write(Path('fontFamily'), TJSONString.Create(AValue)); end;
function TDACChartTextOptions.GetFontSize: Double;
begin if FPath='title' then Result := CN(FStore.Read(Path('fontSize')), 18)
  else Result := CN(FStore.Read(Path('fontSize')), 12); end;
procedure TDACChartTextOptions.SetFontSize(const AValue: Double);
begin FStore.Write(Path('fontSize'), TJSONNumber.Create(AValue)); end;
function TDACChartTextOptions.GetColor: string;
begin Result := CS(FStore.Read(Path('color')), '#333333'); end;
procedure TDACChartTextOptions.SetColor(const AValue: string);
begin FStore.Write(Path('color'), TJSONString.Create(AValue)); end;
function TDACChartTextOptions.GetLeft: string;
begin Result := CS(FStore.Read(Path('left')), 'center'); end;
procedure TDACChartTextOptions.SetLeft(const AValue: string);
begin FStore.Write(Path('left'), TJSONString.Create(AValue)); end;
function TDACChartTextOptions.GetTop: string;
begin Result := CS(FStore.Read(Path('top')), '15'); end;
procedure TDACChartTextOptions.SetTop(const AValue: string);
begin FStore.Write(Path('top'), TJSONString.Create(AValue)); end;
function TDACChartTextOptions.GetPosition: string;
begin Result := CS(FStore.Read(Path('position')), 'top'); end;
procedure TDACChartTextOptions.SetPosition(const AValue: string);
begin FStore.Write(Path('position'), TJSONString.Create(AValue)); end;
function TDACChartTextOptions.GetFormatter: string;
begin Result := CS(FStore.Read(Path('formatter')), ''); end;
procedure TDACChartTextOptions.SetFormatter(const AValue: string);
begin FStore.Write(Path('formatter'), TJSONString.Create(AValue)); end;
function TDACChartTextOptions.GetRotate: Double;
begin Result := CN(FStore.Read(Path('rotate')), 0); end;
procedure TDACChartTextOptions.SetRotate(const AValue: Double);
begin FStore.Write(Path('rotate'), TJSONNumber.Create(AValue)); end;
function TDACChartTextOptions.GetDistance: Double;
begin Result := CN(FStore.Read(Path('distance')), 5); end;
procedure TDACChartTextOptions.SetDistance(const AValue: Double);
begin FStore.Write(Path('distance'), TJSONNumber.Create(AValue)); end;
function TDACChartAxisOptions.GetShow: Boolean;
begin Result := CB(FStore.Read(Path('show')), True); end;
procedure TDACChartAxisOptions.SetShow(const AValue: Boolean);
begin FStore.Write(Path('show'), TJSONBool.Create(AValue)); end;
function TDACChartAxisOptions.GetAxisType: string;
begin Result := CS(FStore.Read(Path('type')), 'value'); end;
procedure TDACChartAxisOptions.SetAxisType(const AValue: string);
begin FStore.Write(Path('type'), TJSONString.Create(AValue)); end;
function TDACChartAxisOptions.GetMin: string;
begin Result := CS(FStore.Read(Path('min')), 'auto'); end;
procedure TDACChartAxisOptions.SetMin(const AValue: string);
begin FStore.Write(Path('min'), TJSONString.Create(AValue)); end;
function TDACChartAxisOptions.GetMax: string;
begin Result := CS(FStore.Read(Path('max')), 'auto'); end;
procedure TDACChartAxisOptions.SetMax(const AValue: string);
begin FStore.Write(Path('max'), TJSONString.Create(AValue)); end;
function TDACChartAxisOptions.GetInverse: Boolean;
begin Result := CB(FStore.Read(Path('inverse')), False); end;
procedure TDACChartAxisOptions.SetInverse(const AValue: Boolean);
begin FStore.Write(Path('inverse'), TJSONBool.Create(AValue)); end;
function TDACChartAxisOptions.GetBoundaryGap: Boolean;
begin Result := CB(FStore.Read(Path('boundaryGap')), True); end;
procedure TDACChartAxisOptions.SetBoundaryGap(const AValue: Boolean);
begin FStore.Write(Path('boundaryGap'), TJSONBool.Create(AValue)); end;
function TDACChartAxisOptions.GetSplitNumber: Double;
begin Result := CN(FStore.Read(Path('splitNumber')), 5); end;
procedure TDACChartAxisOptions.SetSplitNumber(const AValue: Double);
begin FStore.Write(Path('splitNumber'), TJSONNumber.Create(AValue)); end;
function TDACChartAxisOptions.GetName: string;
begin Result := CS(FStore.Read(Path('name')), ''); end;
procedure TDACChartAxisOptions.SetName(const AValue: string);
begin FStore.Write(Path('name'), TJSONString.Create(AValue)); end;
function TDACChartStyleOptions.GetColor: string;
begin Result := CS(FStore.Read(Path('color')), ''); end;
procedure TDACChartStyleOptions.SetColor(const AValue: string);
begin FStore.Write(Path('color'), TJSONString.Create(AValue)); end;
function TDACChartStyleOptions.GetOpacity: Double;
begin Result := CN(FStore.Read(Path('opacity')), 1); end;
procedure TDACChartStyleOptions.SetOpacity(const AValue: Double);
begin FStore.Write(Path('opacity'), TJSONNumber.Create(AValue)); end;
function TDACChartStyleOptions.GetWidth: Double;
begin Result := CN(FStore.Read(Path('width')), 2); end;
procedure TDACChartStyleOptions.SetWidth(const AValue: Double);
begin FStore.Write(Path('width'), TJSONNumber.Create(AValue)); end;
function TDACChartStyleOptions.GetBorderColor: string;
begin Result := CS(FStore.Read(Path('borderColor')), ''); end;
procedure TDACChartStyleOptions.SetBorderColor(const AValue: string);
begin FStore.Write(Path('borderColor'), TJSONString.Create(AValue)); end;
function TDACChartStyleOptions.GetBorderWidth: Double;
begin Result := CN(FStore.Read(Path('borderWidth')), 0); end;
procedure TDACChartStyleOptions.SetBorderWidth(const AValue: Double);
begin FStore.Write(Path('borderWidth'), TJSONNumber.Create(AValue)); end;
function TDACChartStyleOptions.GetBorderRadius: Double;
begin Result := CN(FStore.Read(Path('borderRadius')), 0); end;
procedure TDACChartStyleOptions.SetBorderRadius(const AValue: Double);
begin FStore.Write(Path('borderRadius'), TJSONNumber.Create(AValue)); end;
function TDACChartStyleOptions.GetShadowBlur: Double;
begin Result := CN(FStore.Read(Path('shadowBlur')), 0); end;
procedure TDACChartStyleOptions.SetShadowBlur(const AValue: Double);
begin FStore.Write(Path('shadowBlur'), TJSONNumber.Create(AValue)); end;
function TDACChartStyleOptions.GetShadowColor: string;
begin Result := CS(FStore.Read(Path('shadowColor')), 'transparent'); end;
procedure TDACChartStyleOptions.SetShadowColor(const AValue: string);
begin FStore.Write(Path('shadowColor'), TJSONString.Create(AValue)); end;
function TDACChartStyleOptions.GetShadowOffsetX: Double;
begin Result := CN(FStore.Read(Path('shadowOffsetX')), 0); end;
procedure TDACChartStyleOptions.SetShadowOffsetX(const AValue: Double);
begin FStore.Write(Path('shadowOffsetX'), TJSONNumber.Create(AValue)); end;
function TDACChartStyleOptions.GetShadowOffsetY: Double;
begin Result := CN(FStore.Read(Path('shadowOffsetY')), 0); end;
procedure TDACChartStyleOptions.SetShadowOffsetY(const AValue: Double);
begin FStore.Write(Path('shadowOffsetY'), TJSONNumber.Create(AValue)); end;
function TDACChartLegendOptions.GetShow: Boolean;
begin Result := CB(FStore.Read(Path('show')), True); end;
procedure TDACChartLegendOptions.SetShow(const AValue: Boolean);
begin FStore.Write(Path('show'), TJSONBool.Create(AValue)); end;
function TDACChartLegendOptions.GetLegendType: string;
begin Result := CS(FStore.Read(Path('type')), 'plain'); end;
procedure TDACChartLegendOptions.SetLegendType(const AValue: string);
begin FStore.Write(Path('type'), TJSONString.Create(AValue)); end;
function TDACChartLegendOptions.GetOrient: string;
begin Result := CS(FStore.Read(Path('orient')), 'horizontal'); end;
procedure TDACChartLegendOptions.SetOrient(const AValue: string);
begin FStore.Write(Path('orient'), TJSONString.Create(AValue)); end;
function TDACChartLegendOptions.GetLeft: string;
begin Result := CS(FStore.Read(Path('left')), 'center'); end;
procedure TDACChartLegendOptions.SetLeft(const AValue: string);
begin FStore.Write(Path('left'), TJSONString.Create(AValue)); end;
function TDACChartLegendOptions.GetTop: string;
begin Result := CS(FStore.Read(Path('top')), '0'); end;
procedure TDACChartLegendOptions.SetTop(const AValue: string);
begin FStore.Write(Path('top'), TJSONString.Create(AValue)); end;
function TDACChartLegendOptions.GetItemGap: Double;
begin Result := CN(FStore.Read(Path('itemGap')), 10); end;
procedure TDACChartLegendOptions.SetItemGap(const AValue: Double);
begin FStore.Write(Path('itemGap'), TJSONNumber.Create(AValue)); end;
function TDACChartLegendOptions.GetItemWidth: Double;
begin Result := CN(FStore.Read(Path('itemWidth')), 25); end;
procedure TDACChartLegendOptions.SetItemWidth(const AValue: Double);
begin FStore.Write(Path('itemWidth'), TJSONNumber.Create(AValue)); end;
function TDACChartLegendOptions.GetItemHeight: Double;
begin Result := CN(FStore.Read(Path('itemHeight')), 14); end;
procedure TDACChartLegendOptions.SetItemHeight(const AValue: Double);
begin FStore.Write(Path('itemHeight'), TJSONNumber.Create(AValue)); end;
function TDACChartTooltipOptions.GetShow: Boolean;
begin Result := CB(FStore.Read(Path('show')), True); end;
procedure TDACChartTooltipOptions.SetShow(const AValue: Boolean);
begin FStore.Write(Path('show'), TJSONBool.Create(AValue)); end;
function TDACChartTooltipOptions.GetTrigger: string;
begin Result := CS(FStore.Read(Path('trigger')), 'item'); end;
procedure TDACChartTooltipOptions.SetTrigger(const AValue: string);
begin FStore.Write(Path('trigger'), TJSONString.Create(AValue)); end;
function TDACChartTooltipOptions.GetTriggerOn: string;
begin Result := CS(FStore.Read(Path('triggerOn')), 'mousemove|click'); end;
procedure TDACChartTooltipOptions.SetTriggerOn(const AValue: string);
begin FStore.Write(Path('triggerOn'), TJSONString.Create(AValue)); end;
function TDACChartTooltipOptions.GetConfine: Boolean;
begin Result := CB(FStore.Read(Path('confine')), True); end;
procedure TDACChartTooltipOptions.SetConfine(const AValue: Boolean);
begin FStore.Write(Path('confine'), TJSONBool.Create(AValue)); end;
function TDACChartTooltipOptions.GetFormatter: string;
begin Result := CS(FStore.Read(Path('formatter')), ''); end;
procedure TDACChartTooltipOptions.SetFormatter(const AValue: string);
begin FStore.Write(Path('formatter'), TJSONString.Create(AValue)); end;
function TDACChartTooltipOptions.GetShowDelay: Double;
begin Result := CN(FStore.Read(Path('showDelay')), 0); end;
procedure TDACChartTooltipOptions.SetShowDelay(const AValue: Double);
begin FStore.Write(Path('showDelay'), TJSONNumber.Create(AValue)); end;
function TDACChartTooltipOptions.GetHideDelay: Double;
begin Result := CN(FStore.Read(Path('hideDelay')), 100); end;
procedure TDACChartTooltipOptions.SetHideDelay(const AValue: Double);
begin FStore.Write(Path('hideDelay'), TJSONNumber.Create(AValue)); end;
function TDACChartTooltipOptions.GetBackgroundColor: string;
begin Result := CS(FStore.Read(Path('backgroundColor')), '#ffffff'); end;
procedure TDACChartTooltipOptions.SetBackgroundColor(const AValue: string);
begin FStore.Write(Path('backgroundColor'), TJSONString.Create(AValue)); end;
function TDACChartTooltipOptions.GetBorderColor: string;
begin Result := CS(FStore.Read(Path('borderColor')), '#cccccc'); end;
procedure TDACChartTooltipOptions.SetBorderColor(const AValue: string);
begin FStore.Write(Path('borderColor'), TJSONString.Create(AValue)); end;
function TDACChartTooltipOptions.GetPadding: Double;
begin Result := CN(FStore.Read(Path('padding')), 10); end;
procedure TDACChartTooltipOptions.SetPadding(const AValue: Double);
begin FStore.Write(Path('padding'), TJSONNumber.Create(AValue)); end;
function TDACChartGridOptions.GetLeft: string;
begin Result := CS(FStore.Read(Path('left')), '10%'); end;
procedure TDACChartGridOptions.SetLeft(const AValue: string);
begin FStore.Write(Path('left'), TJSONString.Create(AValue)); end;
function TDACChartGridOptions.GetRight: string;
begin Result := CS(FStore.Read(Path('right')), '10%'); end;
procedure TDACChartGridOptions.SetRight(const AValue: string);
begin FStore.Write(Path('right'), TJSONString.Create(AValue)); end;
function TDACChartGridOptions.GetTop: string;
begin Result := CS(FStore.Read(Path('top')), '60'); end;
procedure TDACChartGridOptions.SetTop(const AValue: string);
begin FStore.Write(Path('top'), TJSONString.Create(AValue)); end;
function TDACChartGridOptions.GetBottom: string;
begin Result := CS(FStore.Read(Path('bottom')), '70'); end;
procedure TDACChartGridOptions.SetBottom(const AValue: string);
begin FStore.Write(Path('bottom'), TJSONString.Create(AValue)); end;
function TDACChartGridOptions.GetOuterBoundsMode: string;
begin Result := CS(FStore.Read(Path('outerBoundsMode')), 'auto'); end;
procedure TDACChartGridOptions.SetOuterBoundsMode(const AValue: string);
begin FStore.Write(Path('outerBoundsMode'), TJSONString.Create(AValue)); end;
constructor TDACChartOptionSeries.Create(Collection: TCollection);
begin
  inherited; FStore := TDACChartOptionStore.Create;
  FItemStyle := TDACChartStyleOptions.Create(FStore,'itemStyle');
  FLineStyle := TDACChartStyleOptions.Create(FStore,'lineStyle');
  FAreaStyle := TDACChartStyleOptions.Create(FStore,'areaStyle');
  FLabel := TDACChartLabelOptions.Create(FStore,'label');
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
function TDACChartOptionSeries.GetName: string;
begin Result := CS(FStore.Read('name')); end;
procedure TDACChartOptionSeries.SetName(const V: string);
begin FStore.Write('name',TJSONString.Create(V)); end;
function TDACChartOptionSeries.GetKind: string;
begin Result := CS(FStore.Read('type')); end;
procedure TDACChartOptionSeries.SetKind(const V: string);
begin FStore.Write('type',TJSONString.Create(V)); end;
function TDACChartOptionSeries.GetStack: string;
begin Result := CS(FStore.Read('stack')); end;
procedure TDACChartOptionSeries.SetStack(const V: string);
begin FStore.Write('stack',TJSONString.Create(V)); end;
procedure TDACChartOptionSeries.SetItemStyle(V: TDACChartStyleOptions);
begin FItemStyle.Assign(V); end;
procedure TDACChartOptionSeries.SetLineStyle(V: TDACChartStyleOptions);
begin FLineStyle.Assign(V); end;
procedure TDACChartOptionSeries.SetAreaStyle(V: TDACChartStyleOptions);
begin FAreaStyle.Assign(V); end;
procedure TDACChartOptionSeries.SetLabel(V: TDACChartLabelOptions);
begin FLabel.Assign(V); end;
constructor TDACChartOptionSeriesCollection.Create(AOwner: TPersistent);
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
  FTitle := TDACChartTitleOptions.Create(FStore,'title');
  FDataset := TDACChartOptionNode.Create(FStore,'dataset');
  FXAxis := TDACChartAxisOptions.Create(FStore,'xAxis');
  FYAxis := TDACChartAxisOptions.Create(FStore,'yAxis');
  FGrid := TDACChartGridOptions.Create(FStore,'grid');
  FLegend := TDACChartLegendOptions.Create(FStore,'legend');
  FTooltip := TDACChartTooltipOptions.Create(FStore,'tooltip');
end;
destructor TDACChartOptions.Destroy;
begin
  FOnChange := nil; FSeries.OnChange := nil;
  FTooltip.Free; FLegend.Free; FGrid.Free; FYAxis.Free; FXAxis.Free; FTitle.Free;
  FDataset.Free; FSeries.Free; FStore.Free; inherited;
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
procedure TDACChartOptions.SetDataset(V: TDACChartOptionNode);
begin FDataset.Assign(V); end;
procedure TDACChartOptions.SetTitle(V: TDACChartTitleOptions);
begin FTitle.Assign(V); end;
procedure TDACChartOptions.SetXAxis(V: TDACChartAxisOptions);
begin FXAxis.Assign(V); end;
procedure TDACChartOptions.SetYAxis(V: TDACChartAxisOptions);
begin FYAxis.Assign(V); end;
procedure TDACChartOptions.SetGrid(V: TDACChartGridOptions);
begin FGrid.Assign(V); end;
procedure TDACChartOptions.SetLegend(V: TDACChartLegendOptions);
begin FLegend.Assign(V); end;
procedure TDACChartOptions.SetTooltip(V: TDACChartTooltipOptions);
begin FTooltip.Assign(V); end;
end.
