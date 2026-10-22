unit DAC.Components.Charts.Options;

interface

uses System.Classes, System.SysUtils, System.JSON, System.Generics.Collections, DAC.Components.Charts.Types;

type
  EDACChartOptionError = DAC.Components.Charts.Types.EDACChartOptionError;
  TDACChartOptionStore = class;
  TDACChartOptionNode = class(TPersistent)
  protected
    FStore: TDACChartOptionStore;
    FPath: string;
    FValues: TObjectDictionary<string,TDACChartBoundValue>;
    function Bound(const Key: string; ValueClass: TDACChartBoundValueClass): TDACChartBoundValue;
    function Path(const AKey: string): string;
    function GetJSON: string;
    procedure SetJSON(const AValue: string);
  public
    constructor Create(AStore: TDACChartOptionStore; const APath: string);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property JSON: string read GetJSON write SetJSON;
  end;

  TDACChartOptionStore = class(TDACChartValueAccess)
  private
    FRoot: TJSONObject;
    FSeriesOnly: Boolean;
    FOnChange: TNotifyEvent;
  public
    constructor Create(SeriesOnly: Boolean = False);
    destructor Destroy; override;
    function Read(const APath: string): TJSONValue; override;
    procedure Write(const APath: string; AValue: TJSONValue); override;
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
    function GetFontWeight: Integer;
    procedure SetFontWeight(V: Integer);
    function GetFontFamily: string;
    procedure SetFontFamily(const AValue: string);
    function GetFontSize: Double;
    procedure SetFontSize(const AValue: Double);
    function GetColor: TDACChartFill;
    procedure SetColor(const AValue: TDACChartFill);
    function GetLeft: TDACChartMeasure;
    procedure SetLeft(const AValue: TDACChartMeasure);
    function GetTop: TDACChartMeasure;
    procedure SetTop(const AValue: TDACChartMeasure);
    function GetPosition: TDACChartLabelPosition;
    procedure SetPosition(const AValue: TDACChartLabelPosition);
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
    property FontWeight: Integer read GetFontWeight write SetFontWeight stored False;
    property FontFamily: string read GetFontFamily write SetFontFamily stored False;
    property FontSize: Double read GetFontSize write SetFontSize stored False;
    property Color: TDACChartFill read GetColor write SetColor stored False;
    property Left: TDACChartMeasure read GetLeft write SetLeft stored False;
    property Top: TDACChartMeasure read GetTop write SetTop stored False;
    property Position: TDACChartLabelPosition read GetPosition write SetPosition stored False;
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
    property FontWeight;
    property FontSize;
    property Color;
    property Left;
    property Top;
  end;
  TDACChartLabelOptions = class(TDACChartTextOptions)
  private
    function GetFontStyle: TDACChartFontStyle;
    procedure SetFontStyle(V: TDACChartFontStyle);
    function GetTextAlign: TDACChartTextAlign;
    procedure SetTextAlign(V: TDACChartTextAlign);
    function GetVerticalAlign: TDACChartVerticalAlign;
    procedure SetVerticalAlign(V: TDACChartVerticalAlign);
    function GetOverflow: TDACChartOverflow;
    procedure SetOverflow(V: TDACChartOverflow);
  published
    property FontStyle: TDACChartFontStyle read GetFontStyle write SetFontStyle stored False;
    property TextAlign: TDACChartTextAlign read GetTextAlign write SetTextAlign stored False;
    property VerticalAlign: TDACChartVerticalAlign read GetVerticalAlign write SetVerticalAlign stored False;
    property Overflow: TDACChartOverflow read GetOverflow write SetOverflow stored False;
    property Show;
    property FontFamily;
    property FontWeight;
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
    function GetAxisType: TDACChartAxisType;
    procedure SetAxisType(const AValue: TDACChartAxisType);
    function GetMin: TDACChartAxisLimit;
    procedure SetMin(const AValue: TDACChartAxisLimit);
    function GetMax: TDACChartAxisLimit;
    procedure SetMax(const AValue: TDACChartAxisLimit);
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
    property AxisType: TDACChartAxisType read GetAxisType write SetAxisType stored False;
    property Min: TDACChartAxisLimit read GetMin write SetMin stored False;
    property Max: TDACChartAxisLimit read GetMax write SetMax stored False;
    property Inverse: Boolean read GetInverse write SetInverse stored False;
    property BoundaryGap: Boolean read GetBoundaryGap write SetBoundaryGap stored False;
    property SplitNumber: Double read GetSplitNumber write SetSplitNumber stored False;
    property Name: string read GetName write SetName stored False;
  end;

  TDACChartStyleOptions = class(TDACChartOptionNode)
  private
    function GetColor: TDACChartFill;
    procedure SetColor(const AValue: TDACChartFill);
    function GetOpacity: Double;
    procedure SetOpacity(const AValue: Double);
    function GetWidth: Double;
    procedure SetWidth(const AValue: Double);
    function GetBorderColor: TDACChartFill;
    procedure SetBorderColor(const AValue: TDACChartFill);
    function GetBorderWidth: Double;
    procedure SetBorderWidth(const AValue: Double);
    function GetBorderRadius: Double;
    procedure SetBorderRadius(const AValue: Double);
    function GetShadowBlur: Double;
    procedure SetShadowBlur(const AValue: Double);
    function GetShadowColor: TDACChartFill;
    procedure SetShadowColor(const AValue: TDACChartFill);
    function GetShadowOffsetX: Double;
    procedure SetShadowOffsetX(const AValue: Double);
    function GetShadowOffsetY: Double;
    procedure SetShadowOffsetY(const AValue: Double);
  private
    function GetLineType: TDACChartLineType;
    procedure SetLineType(V: TDACChartLineType);
  published
    property LineType: TDACChartLineType read GetLineType write SetLineType stored False;
    property Color: TDACChartFill read GetColor write SetColor stored False;
    property Opacity: Double read GetOpacity write SetOpacity stored False;
    property Width: Double read GetWidth write SetWidth stored False;
    property BorderColor: TDACChartFill read GetBorderColor write SetBorderColor stored False;
    property BorderWidth: Double read GetBorderWidth write SetBorderWidth stored False;
    property BorderRadius: Double read GetBorderRadius write SetBorderRadius stored False;
    property ShadowBlur: Double read GetShadowBlur write SetShadowBlur stored False;
    property ShadowColor: TDACChartFill read GetShadowColor write SetShadowColor stored False;
    property ShadowOffsetX: Double read GetShadowOffsetX write SetShadowOffsetX stored False;
    property ShadowOffsetY: Double read GetShadowOffsetY write SetShadowOffsetY stored False;
  end;

  TDACChartLegendOptions = class(TDACChartOptionNode)
  private
    function GetShow: Boolean;
    procedure SetShow(const AValue: Boolean);
    function GetLegendType: TDACChartLegendType;
    procedure SetLegendType(const AValue: TDACChartLegendType);
    function GetOrient: TDACChartOrientation;
    procedure SetOrient(const AValue: TDACChartOrientation);
    function GetLeft: TDACChartMeasure;
    procedure SetLeft(const AValue: TDACChartMeasure);
    function GetTop: TDACChartMeasure;
    procedure SetTop(const AValue: TDACChartMeasure);
    function GetItemGap: Double;
    procedure SetItemGap(const AValue: Double);
    function GetItemWidth: Double;
    procedure SetItemWidth(const AValue: Double);
    function GetItemHeight: Double;
    procedure SetItemHeight(const AValue: Double);
  private
    function GetSelectedMode: TDACChartSelection;
    procedure SetSelectedMode(V: TDACChartSelection);
  published
    property SelectedMode: TDACChartSelection read GetSelectedMode write SetSelectedMode stored False;
    property Show: Boolean read GetShow write SetShow stored False;
    property LegendType: TDACChartLegendType read GetLegendType write SetLegendType stored False;
    property Orient: TDACChartOrientation read GetOrient write SetOrient stored False;
    property Left: TDACChartMeasure read GetLeft write SetLeft stored False;
    property Top: TDACChartMeasure read GetTop write SetTop stored False;
    property ItemGap: Double read GetItemGap write SetItemGap stored False;
    property ItemWidth: Double read GetItemWidth write SetItemWidth stored False;
    property ItemHeight: Double read GetItemHeight write SetItemHeight stored False;
  end;

  TDACChartTooltipOptions = class(TDACChartOptionNode)
  private
    function GetShow: Boolean;
    procedure SetShow(const AValue: Boolean);
    function GetTrigger: TDACChartTooltipTrigger;
    procedure SetTrigger(const AValue: TDACChartTooltipTrigger);
    function GetTriggerOn: TDACChartTooltipEvents;
    procedure SetTriggerOn(const AValue: TDACChartTooltipEvents);
    function GetConfine: Boolean;
    procedure SetConfine(const AValue: Boolean);
    function GetFormatter: string;
    procedure SetFormatter(const AValue: string);
    function GetShowDelay: Double;
    procedure SetShowDelay(const AValue: Double);
    function GetHideDelay: Double;
    procedure SetHideDelay(const AValue: Double);
    function GetBackgroundColor: TDACChartFill;
    procedure SetBackgroundColor(const AValue: TDACChartFill);
    function GetBorderColor: TDACChartFill;
    procedure SetBorderColor(const AValue: TDACChartFill);
    function GetPadding: Double;
    procedure SetPadding(const AValue: Double);
  private
    function GetRenderMode: TDACChartRenderMode;
    procedure SetRenderMode(V: TDACChartRenderMode);
    function GetPointerType: TDACChartPointerType;
    procedure SetPointerType(V: TDACChartPointerType);
  published
    property RenderMode: TDACChartRenderMode read GetRenderMode write SetRenderMode stored False;
    property PointerType: TDACChartPointerType read GetPointerType write SetPointerType stored False;
    property Show: Boolean read GetShow write SetShow stored False;
    property Trigger: TDACChartTooltipTrigger read GetTrigger write SetTrigger stored False;
    property TriggerOn: TDACChartTooltipEvents read GetTriggerOn write SetTriggerOn stored False;
    property Confine: Boolean read GetConfine write SetConfine stored False;
    property Formatter: string read GetFormatter write SetFormatter stored False;
    property ShowDelay: Double read GetShowDelay write SetShowDelay stored False;
    property HideDelay: Double read GetHideDelay write SetHideDelay stored False;
    property BackgroundColor: TDACChartFill read GetBackgroundColor write SetBackgroundColor stored False;
    property BorderColor: TDACChartFill read GetBorderColor write SetBorderColor stored False;
    property Padding: Double read GetPadding write SetPadding stored False;
  end;

  TDACChartGridOptions = class(TDACChartOptionNode)
  private
    function GetLeft: TDACChartMeasure;
    procedure SetLeft(const AValue: TDACChartMeasure);
    function GetRight: TDACChartMeasure;
    procedure SetRight(const AValue: TDACChartMeasure);
    function GetTop: TDACChartMeasure;
    procedure SetTop(const AValue: TDACChartMeasure);
    function GetBottom: TDACChartMeasure;
    procedure SetBottom(const AValue: TDACChartMeasure);
    function GetOuterBoundsMode: TDACChartOuterBoundsMode;
    procedure SetOuterBoundsMode(const AValue: TDACChartOuterBoundsMode);
  published
    property Left: TDACChartMeasure read GetLeft write SetLeft stored False;
    property Right: TDACChartMeasure read GetRight write SetRight stored False;
    property Top: TDACChartMeasure read GetTop write SetTop stored False;
    property Bottom: TDACChartMeasure read GetBottom write SetBottom stored False;
    property OuterBoundsMode: TDACChartOuterBoundsMode read GetOuterBoundsMode write SetOuterBoundsMode stored False;
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
    function GetKind: TDACChartSeriesType;
    procedure SetKind(const V: TDACChartSeriesType);
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
  private
    function GetLayoutBy: TDACChartSeriesLayout;
    procedure SetLayoutBy(V: TDACChartSeriesLayout);
    function GetStep: TDACChartStep;
    procedure SetStep(V: TDACChartStep);
    function GetSmoothMonotone: TDACChartMonotone;
    procedure SetSmoothMonotone(V: TDACChartMonotone);
    function GetSymbol: TDACChartSymbol;
    procedure SetSymbol(V: TDACChartSymbol);
    function GetSelectedMode: TDACChartSelection;
    procedure SetSelectedMode(V: TDACChartSelection);
    function GetStackStrategy: TDACChartStackStrategy;
    procedure SetStackStrategy(V: TDACChartStackStrategy);
    function GetFocus: TDACChartFocus;
    procedure SetFocus(V: TDACChartFocus);
  published
    property LayoutBy: TDACChartSeriesLayout read GetLayoutBy write SetLayoutBy stored False;
    property Step: TDACChartStep read GetStep write SetStep stored False;
    property SmoothMonotone: TDACChartMonotone read GetSmoothMonotone write SetSmoothMonotone stored False;
    property Symbol: TDACChartSymbol read GetSymbol write SetSymbol stored False;
    property SelectedMode: TDACChartSelection read GetSelectedMode write SetSelectedMode stored False;
    property StackStrategy: TDACChartStackStrategy read GetStackStrategy write SetStackStrategy stored False;
    property Focus: TDACChartFocus read GetFocus write SetFocus stored False;
    property JSON: string read GetJSON write SetJSON;
    property Name: string read GetName write SetName stored False;
    property Kind: TDACChartSeriesType read GetKind write SetKind stored False;
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
  TDACChartDatasetOptions = class(TDACChartOptionNode)
  private
    function GetSourceHeader: TDACChartSwitch;
    procedure SetSourceHeader(V: TDACChartSwitch);
  published
    property SourceHeader: TDACChartSwitch read GetSourceHeader write SetSourceHeader stored False;
  end;
  TDACChartOptions = class(TPersistent)
  private
    FStore: TDACChartOptionStore;
    FSeries: TDACChartOptionSeriesCollection;
    FTitle: TDACChartTitleOptions;
    FDataset: TDACChartDatasetOptions;
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
    procedure SetDataset(V: TDACChartDatasetOptions);
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
  private
    function GetAnimationMode: TDACChartSwitch;
    procedure SetAnimationMode(V: TDACChartSwitch);
    function GetAnimationEasing: TDACChartEasing;
    procedure SetAnimationEasing(V: TDACChartEasing);
    function GetAnimationEasingUpdate: TDACChartEasing;
    procedure SetAnimationEasingUpdate(V: TDACChartEasing);
  published
    property AnimationMode: TDACChartSwitch read GetAnimationMode write SetAnimationMode stored False;
    property AnimationEasing: TDACChartEasing read GetAnimationEasing write SetAnimationEasing stored False;
    property AnimationEasingUpdate: TDACChartEasing read GetAnimationEasingUpdate write SetAnimationEasingUpdate stored False;
    property JSON: string read GetJSON write SetJSON;
    property Series: TDACChartOptionSeriesCollection read FSeries write SetSeries stored False;
    property Dataset: TDACChartDatasetOptions read FDataset write SetDataset stored False;
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
  if V<>nil then O.AddPair(K,V);
end;
procedure ValidateChartOptions(O: TJSONObject);
begin TDACChartTypes.Validate(O); end;
constructor TDACChartOptionStore.Create(SeriesOnly: Boolean);
begin inherited Create; FSeriesOnly:=SeriesOnly; FRoot := TJSONObject.Create; end;
destructor TDACChartOptionStore.Destroy;
begin FRoot.Free; inherited; end;
function TDACChartOptionStore.Read(const APath: string): TJSONValue;
var K: string;
begin
  Result := FRoot;
  if APath <> '' then for K in APath.Split(['.']) do Result := CJ(Result,K);
end;
procedure TDACChartOptionStore.Write(const APath: string; AValue: TJSONValue);
var Parts: TArray<string>; I: Integer; Candidate,O,N,Old: TJSONObject;
begin
  if (AValue=nil) and (Read(APath)=nil) then Exit;
  Candidate:=nil;
  try
    if APath='' then begin
      if not (AValue is TJSONObject) then raise EDACChartOptionError.Create('option: esperado objeto');
      Candidate:=TJSONObject(AValue); AValue:=nil;
    end else begin
      Candidate:=Clone; Parts:=APath.Split(['.']); O:=Candidate;
      for I:=0 to High(Parts)-1 do begin
        if not (CJ(O,Parts[I]) is TJSONObject) then begin
          N:=TJSONObject.Create; CSet(O,Parts[I],N);
        end;
        O:=TJSONObject(CJ(O,Parts[I]));
      end;
      CSet(O,Parts[High(Parts)],AValue); AValue:=nil;
    end;
    TDACChartTypes.Validate(Candidate,FSeriesOnly);
    Old:=FRoot; FRoot:=Candidate; Candidate:=nil; Old.Free;
  finally AValue.Free; Candidate.Free; end;
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
begin
  inherited Create; FStore:=AStore; FPath:=APath;
  FValues:=TObjectDictionary<string,TDACChartBoundValue>.Create([doOwnsValues]);
end;
destructor TDACChartOptionNode.Destroy;
begin FValues.Free; inherited; end;
function TDACChartOptionNode.Bound(const Key: string; ValueClass: TDACChartBoundValueClass): TDACChartBoundValue;
var P: string;
begin
  P:=Path(Key);
  if not FValues.TryGetValue(P,Result) then begin Result:=ValueClass.Create(FStore,P); FValues.Add(P,Result); end;
end;
function TDACChartOptionNode.Path(const AKey: string): string;
begin
  if FPath = '' then Result := AKey else Result := FPath+'.'+AKey;
  if (FPath='title') and ((AKey='fontFamily') or (AKey='fontSize') or (AKey='fontWeight') or (AKey='color')) then Result:='title.textStyle.'+AKey;
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
function TDACChartTextOptions.GetColor: TDACChartFill;
begin Result := TDACChartFill(Bound('color',TDACChartFill)); end;
procedure TDACChartTextOptions.SetColor(const AValue: TDACChartFill);
begin GetColor.Assign(AValue); end;
function TDACChartTextOptions.GetLeft: TDACChartMeasure;
begin Result := TDACChartMeasure(Bound('left',TDACChartMeasure)); end;
procedure TDACChartTextOptions.SetLeft(const AValue: TDACChartMeasure);
begin GetLeft.Assign(AValue); end;
function TDACChartTextOptions.GetTop: TDACChartMeasure;
begin Result := TDACChartMeasure(Bound('top',TDACChartMeasure)); end;
procedure TDACChartTextOptions.SetTop(const AValue: TDACChartMeasure);
begin GetTop.Assign(AValue); end;
function TDACChartTextOptions.GetPosition: TDACChartLabelPosition;
begin Result := TDACChartTypes.LabelPosition(FStore.Read(Path('position')),Path('position')); end;
procedure TDACChartTextOptions.SetPosition(const AValue: TDACChartLabelPosition);
begin FStore.Write(Path('position'),TDACChartTypes.LabelPositionJSON(AValue)); end;
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
function TDACChartAxisOptions.GetAxisType: TDACChartAxisType;
begin Result := TDACChartTypes.AxisType(FStore.Read(Path('type')),Path('type')); end;
procedure TDACChartAxisOptions.SetAxisType(const AValue: TDACChartAxisType);
begin FStore.Write(Path('type'),TDACChartTypes.AxisTypeJSON(AValue)); end;
function TDACChartAxisOptions.GetMin: TDACChartAxisLimit;
begin Result := TDACChartAxisLimit(Bound('min',TDACChartAxisLimit)); end;
procedure TDACChartAxisOptions.SetMin(const AValue: TDACChartAxisLimit);
begin GetMin.Assign(AValue); end;
function TDACChartAxisOptions.GetMax: TDACChartAxisLimit;
begin Result := TDACChartAxisLimit(Bound('max',TDACChartAxisLimit)); end;
procedure TDACChartAxisOptions.SetMax(const AValue: TDACChartAxisLimit);
begin GetMax.Assign(AValue); end;
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
function TDACChartStyleOptions.GetColor: TDACChartFill;
begin Result := TDACChartFill(Bound('color',TDACChartFill)); end;
procedure TDACChartStyleOptions.SetColor(const AValue: TDACChartFill);
begin GetColor.Assign(AValue); end;
function TDACChartStyleOptions.GetOpacity: Double;
begin Result := CN(FStore.Read(Path('opacity')), 1); end;
procedure TDACChartStyleOptions.SetOpacity(const AValue: Double);
begin FStore.Write(Path('opacity'), TJSONNumber.Create(AValue)); end;
function TDACChartStyleOptions.GetWidth: Double;
begin Result := CN(FStore.Read(Path('width')), 2); end;
procedure TDACChartStyleOptions.SetWidth(const AValue: Double);
begin FStore.Write(Path('width'), TJSONNumber.Create(AValue)); end;
function TDACChartStyleOptions.GetBorderColor: TDACChartFill;
begin Result := TDACChartFill(Bound('borderColor',TDACChartFill)); end;
procedure TDACChartStyleOptions.SetBorderColor(const AValue: TDACChartFill);
begin GetBorderColor.Assign(AValue); end;
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
function TDACChartStyleOptions.GetShadowColor: TDACChartFill;
begin Result := TDACChartFill(Bound('shadowColor',TDACChartFill)); end;
procedure TDACChartStyleOptions.SetShadowColor(const AValue: TDACChartFill);
begin GetShadowColor.Assign(AValue); end;
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
function TDACChartLegendOptions.GetLegendType: TDACChartLegendType;
begin Result := TDACChartTypes.LegendType(FStore.Read(Path('type')),Path('type')); end;
procedure TDACChartLegendOptions.SetLegendType(const AValue: TDACChartLegendType);
begin FStore.Write(Path('type'),TDACChartTypes.LegendTypeJSON(AValue)); end;
function TDACChartLegendOptions.GetOrient: TDACChartOrientation;
begin Result := TDACChartTypes.Orientation(FStore.Read(Path('orient')),Path('orient')); end;
procedure TDACChartLegendOptions.SetOrient(const AValue: TDACChartOrientation);
begin FStore.Write(Path('orient'),TDACChartTypes.OrientationJSON(AValue)); end;
function TDACChartLegendOptions.GetLeft: TDACChartMeasure;
begin Result := TDACChartMeasure(Bound('left',TDACChartMeasure)); end;
procedure TDACChartLegendOptions.SetLeft(const AValue: TDACChartMeasure);
begin GetLeft.Assign(AValue); end;
function TDACChartLegendOptions.GetTop: TDACChartMeasure;
begin Result := TDACChartMeasure(Bound('top',TDACChartMeasure)); end;
procedure TDACChartLegendOptions.SetTop(const AValue: TDACChartMeasure);
begin GetTop.Assign(AValue); end;
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
function TDACChartTooltipOptions.GetTrigger: TDACChartTooltipTrigger;
begin Result := TDACChartTypes.TooltipTrigger(FStore.Read(Path('trigger')),Path('trigger')); end;
procedure TDACChartTooltipOptions.SetTrigger(const AValue: TDACChartTooltipTrigger);
begin FStore.Write(Path('trigger'),TDACChartTypes.TooltipTriggerJSON(AValue)); end;
function TDACChartTooltipOptions.GetTriggerOn: TDACChartTooltipEvents;
begin Result := TDACChartTypes.TooltipEvents(FStore.Read(Path('triggerOn')),Path('triggerOn')); end;
procedure TDACChartTooltipOptions.SetTriggerOn(const AValue: TDACChartTooltipEvents);
begin FStore.Write(Path('triggerOn'),TDACChartTypes.TooltipEventsJSON(AValue)); end;
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
function TDACChartTooltipOptions.GetBackgroundColor: TDACChartFill;
begin Result := TDACChartFill(Bound('backgroundColor',TDACChartFill)); end;
procedure TDACChartTooltipOptions.SetBackgroundColor(const AValue: TDACChartFill);
begin GetBackgroundColor.Assign(AValue); end;
function TDACChartTooltipOptions.GetBorderColor: TDACChartFill;
begin Result := TDACChartFill(Bound('borderColor',TDACChartFill)); end;
procedure TDACChartTooltipOptions.SetBorderColor(const AValue: TDACChartFill);
begin GetBorderColor.Assign(AValue); end;
function TDACChartTooltipOptions.GetPadding: Double;
begin Result := CN(FStore.Read(Path('padding')), 10); end;
procedure TDACChartTooltipOptions.SetPadding(const AValue: Double);
begin FStore.Write(Path('padding'), TJSONNumber.Create(AValue)); end;
function TDACChartGridOptions.GetLeft: TDACChartMeasure;
begin Result := TDACChartMeasure(Bound('left',TDACChartMeasure)); end;
procedure TDACChartGridOptions.SetLeft(const AValue: TDACChartMeasure);
begin GetLeft.Assign(AValue); end;
function TDACChartGridOptions.GetRight: TDACChartMeasure;
begin Result := TDACChartMeasure(Bound('right',TDACChartMeasure)); end;
procedure TDACChartGridOptions.SetRight(const AValue: TDACChartMeasure);
begin GetRight.Assign(AValue); end;
function TDACChartGridOptions.GetTop: TDACChartMeasure;
begin Result := TDACChartMeasure(Bound('top',TDACChartMeasure)); end;
procedure TDACChartGridOptions.SetTop(const AValue: TDACChartMeasure);
begin GetTop.Assign(AValue); end;
function TDACChartGridOptions.GetBottom: TDACChartMeasure;
begin Result := TDACChartMeasure(Bound('bottom',TDACChartMeasure)); end;
procedure TDACChartGridOptions.SetBottom(const AValue: TDACChartMeasure);
begin GetBottom.Assign(AValue); end;
function TDACChartGridOptions.GetOuterBoundsMode: TDACChartOuterBoundsMode;
begin Result := TDACChartTypes.OuterBoundsMode(FStore.Read(Path('outerBoundsMode')),Path('outerBoundsMode')); end;
procedure TDACChartGridOptions.SetOuterBoundsMode(const AValue: TDACChartOuterBoundsMode);
begin FStore.Write(Path('outerBoundsMode'),TDACChartTypes.OuterBoundsModeJSON(AValue)); end;
constructor TDACChartOptionSeries.Create(Collection: TCollection);
begin
  inherited; FStore := TDACChartOptionStore.Create(True);
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
var V: TJSONValue;
begin
  Result:=GetName;
  if Result='' then begin
    V:=TDACChartTypes.SeriesTypeJSON(GetKind);
    try if V=nil then Result:='Series' else Result:=V.Value; finally V.Free; end;
  end;
end;
procedure TDACChartOptionSeries.Assign(Source: TPersistent);
begin if Source is TDACChartOptionSeries then SetJSON(TDACChartOptionSeries(Source).JSON) else inherited; end;
function TDACChartOptionSeries.GetName: string;
begin Result := CS(FStore.Read('name')); end;
procedure TDACChartOptionSeries.SetName(const V: string);
begin FStore.Write('name',TJSONString.Create(V)); end;
function TDACChartOptionSeries.GetKind: TDACChartSeriesType;
begin Result := TDACChartTypes.SeriesType(FStore.Read('type'),'type'); end;
procedure TDACChartOptionSeries.SetKind(const V: TDACChartSeriesType);
begin FStore.Write('type',TDACChartTypes.SeriesTypeJSON(V)); end;
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
  FDataset := TDACChartDatasetOptions.Create(FStore,'dataset');
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
procedure TDACChartOptions.SetDataset(V: TDACChartDatasetOptions);
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
function TDACChartStyleOptions.GetLineType: TDACChartLineType;
begin Result:=TDACChartTypes.LineType(FStore.Read(Path('type')),Path('type')); end;
procedure TDACChartStyleOptions.SetLineType(V: TDACChartLineType);
begin FStore.Write(Path('type'),TDACChartTypes.LineTypeJSON(V)); end;
function TDACChartLegendOptions.GetSelectedMode: TDACChartSelection;
begin Result:=TDACChartTypes.Selection(FStore.Read(Path('selectedMode')),Path('selectedMode')); end;
procedure TDACChartLegendOptions.SetSelectedMode(V: TDACChartSelection);
begin FStore.Write(Path('selectedMode'),TDACChartTypes.SelectionJSON(V)); end;
function TDACChartTooltipOptions.GetRenderMode: TDACChartRenderMode;
begin Result:=TDACChartTypes.RenderMode(FStore.Read(Path('renderMode')),Path('renderMode')); end;
procedure TDACChartTooltipOptions.SetRenderMode(V: TDACChartRenderMode);
begin FStore.Write(Path('renderMode'),TDACChartTypes.RenderModeJSON(V)); end;
function TDACChartTooltipOptions.GetPointerType: TDACChartPointerType;
begin Result:=TDACChartTypes.PointerType(FStore.Read(Path('axisPointer.type')),Path('axisPointer.type')); end;
procedure TDACChartTooltipOptions.SetPointerType(V: TDACChartPointerType);
begin FStore.Write(Path('axisPointer.type'),TDACChartTypes.PointerTypeJSON(V)); end;
function TDACChartLabelOptions.GetFontStyle: TDACChartFontStyle;
begin Result:=TDACChartTypes.FontStyle(FStore.Read(Path('fontStyle')),Path('fontStyle')); end;
procedure TDACChartLabelOptions.SetFontStyle(V: TDACChartFontStyle);
begin FStore.Write(Path('fontStyle'),TDACChartTypes.FontStyleJSON(V)); end;
function TDACChartLabelOptions.GetTextAlign: TDACChartTextAlign;
begin Result:=TDACChartTypes.TextAlign(FStore.Read(Path('align')),Path('align')); end;
procedure TDACChartLabelOptions.SetTextAlign(V: TDACChartTextAlign);
begin FStore.Write(Path('align'),TDACChartTypes.TextAlignJSON(V)); end;
function TDACChartLabelOptions.GetVerticalAlign: TDACChartVerticalAlign;
begin Result:=TDACChartTypes.VerticalAlign(FStore.Read(Path('verticalAlign')),Path('verticalAlign')); end;
procedure TDACChartLabelOptions.SetVerticalAlign(V: TDACChartVerticalAlign);
begin FStore.Write(Path('verticalAlign'),TDACChartTypes.VerticalAlignJSON(V)); end;
function TDACChartLabelOptions.GetOverflow: TDACChartOverflow;
begin Result:=TDACChartTypes.Overflow(FStore.Read(Path('overflow')),Path('overflow')); end;
procedure TDACChartLabelOptions.SetOverflow(V: TDACChartOverflow);
begin FStore.Write(Path('overflow'),TDACChartTypes.OverflowJSON(V)); end;
function TDACChartOptionSeries.GetLayoutBy: TDACChartSeriesLayout;
begin Result:=TDACChartTypes.SeriesLayout(FStore.Read('seriesLayoutBy'),'seriesLayoutBy'); end;
procedure TDACChartOptionSeries.SetLayoutBy(V: TDACChartSeriesLayout);
begin FStore.Write('seriesLayoutBy',TDACChartTypes.SeriesLayoutJSON(V)); end;
function TDACChartOptionSeries.GetStep: TDACChartStep;
begin Result:=TDACChartTypes.Step(FStore.Read('step'),'step'); end;
procedure TDACChartOptionSeries.SetStep(V: TDACChartStep);
begin FStore.Write('step',TDACChartTypes.StepJSON(V)); end;
function TDACChartOptionSeries.GetSmoothMonotone: TDACChartMonotone;
begin Result:=TDACChartTypes.Monotone(FStore.Read('smoothMonotone'),'smoothMonotone'); end;
procedure TDACChartOptionSeries.SetSmoothMonotone(V: TDACChartMonotone);
begin FStore.Write('smoothMonotone',TDACChartTypes.MonotoneJSON(V)); end;
function TDACChartOptionSeries.GetSymbol: TDACChartSymbol;
begin Result:=TDACChartTypes.Symbol(FStore.Read('symbol'),'symbol'); end;
procedure TDACChartOptionSeries.SetSymbol(V: TDACChartSymbol);
begin FStore.Write('symbol',TDACChartTypes.SymbolJSON(V)); end;
function TDACChartOptionSeries.GetSelectedMode: TDACChartSelection;
begin Result:=TDACChartTypes.Selection(FStore.Read('selectedMode'),'selectedMode'); end;
procedure TDACChartOptionSeries.SetSelectedMode(V: TDACChartSelection);
begin FStore.Write('selectedMode',TDACChartTypes.SelectionJSON(V)); end;
function TDACChartOptionSeries.GetStackStrategy: TDACChartStackStrategy;
begin Result:=TDACChartTypes.StackStrategy(FStore.Read('stackStrategy'),'stackStrategy'); end;
procedure TDACChartOptionSeries.SetStackStrategy(V: TDACChartStackStrategy);
begin FStore.Write('stackStrategy',TDACChartTypes.StackStrategyJSON(V)); end;
function TDACChartOptionSeries.GetFocus: TDACChartFocus;
begin Result:=TDACChartTypes.Focus(FStore.Read('emphasis.focus'),'emphasis.focus'); end;
procedure TDACChartOptionSeries.SetFocus(V: TDACChartFocus);
begin FStore.Write('emphasis.focus',TDACChartTypes.FocusJSON(V)); end;
function TDACChartOptions.GetAnimationMode: TDACChartSwitch;
begin Result:=TDACChartTypes.Switch(FStore.Read('animation'),'animation'); end;
procedure TDACChartOptions.SetAnimationMode(V: TDACChartSwitch);
begin FStore.Write('animation',TDACChartTypes.SwitchJSON(V)); end;
function TDACChartOptions.GetAnimationEasing: TDACChartEasing;
begin Result:=TDACChartTypes.Easing(FStore.Read('animationEasing'),'animationEasing'); end;
procedure TDACChartOptions.SetAnimationEasing(V: TDACChartEasing);
begin FStore.Write('animationEasing',TDACChartTypes.EasingJSON(V)); end;
function TDACChartOptions.GetAnimationEasingUpdate: TDACChartEasing;
begin Result:=TDACChartTypes.Easing(FStore.Read('animationEasingUpdate'),'animationEasingUpdate'); end;
procedure TDACChartOptions.SetAnimationEasingUpdate(V: TDACChartEasing);
begin FStore.Write('animationEasingUpdate',TDACChartTypes.EasingJSON(V)); end;
function TDACChartDatasetOptions.GetSourceHeader: TDACChartSwitch;
begin Result:=TDACChartTypes.Switch(FStore.Read(Path('sourceHeader')),Path('sourceHeader')); end;
procedure TDACChartDatasetOptions.SetSourceHeader(V: TDACChartSwitch);
begin FStore.Write(Path('sourceHeader'),TDACChartTypes.SwitchJSON(V)); end;
function TDACChartTextOptions.GetFontWeight: Integer;
var V: TJSONValue;
begin
  V:=FStore.Read(Path('fontWeight')); if V=nil then Exit(0);
  if V is TJSONNumber then Exit(Round(TDACChartTypes.Number(V,Path('fontWeight'))));
  if V.Value='bold' then Result:=700 else Result:=400;
end;
procedure TDACChartTextOptions.SetFontWeight(V: Integer);
begin
  if V=0 then FStore.Write(Path('fontWeight'),nil)
  else FStore.Write(Path('fontWeight'),TJSONNumber.Create(V));
end;
end.
