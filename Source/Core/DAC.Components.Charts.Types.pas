unit DAC.Components.Charts.Types;

interface

uses System.Classes, System.SysUtils, System.JSON, System.UITypes, System.Generics.Collections;

type
  EDACChartOptionError = class(Exception);
  TDACChartOrientation = (dcoDefault, dcoHorizontal, dcoVertical);
  TDACChartLegendType = (dclDefault, dclPlain, dclScroll);
  TDACChartSeriesType = (dcsDefault, dcsBar, dcsLine, dcsPie);
  TDACChartAxisType = (dcaDefault, dcaCategory, dcaValue, dcaTime);
  TDACChartLabelPosition = (dcpDefault, dcpTop, dcpBottom, dcpLeft, dcpRight, dcpInside, dcpInsideTop, dcpInsideBottom, dcpOutside);
  TDACChartTooltipTrigger = (dctDefault, dctItem, dctAxis, dctNone);
  TDACChartOuterBoundsMode = (dcbDefault, dcbNone);
  TDACChartSeriesLayout = (dcslDefault, dcslColumn, dcslRow);
  TDACChartStep = (dcstDefault, dcstFalse, dcstStart, dcstMiddle, dcstEnd);
  TDACChartMonotone = (dcmDefault, dcmNone, dcmX, dcmY);
  TDACChartSymbol = (dcsyDefault, dcsyNone, dcsyCircle, dcsyEmptyCircle, dcsyRect, dcsyRoundRect, dcsyTriangle, dcsyDiamond);
  TDACChartSelection = (dcseDefault, dcseFalse, dcseSingle, dcseMultiple);
  TDACChartEasing = (dceDefault, dceLinear, dceCubicIn, dceCubicOut, dceCubicInOut);
  TDACChartLineType = (dcliDefault, dcliSolid, dcliDashed, dcliDotted);
  TDACChartPointerType = (dcptDefault, dcptNone, dcptLine, dcptShadow);
  TDACChartFocus = (dcfDefault, dcfNone, dcfSeries);
  TDACChartFontStyle = (dcfsDefault, dcfsNormal, dcfsItalic);
  TDACChartTextAlign = (dctaDefault, dctaLeft, dctaCenter, dctaRight);
  TDACChartVerticalAlign = (dcvaDefault, dcvaTop, dcvaMiddle, dcvaBottom);
  TDACChartOverflow = (dcovDefault, dcovTruncate);
  TDACChartRenderMode = (dcrmDefault, dcrmRichText);
  TDACChartStackStrategy = (dcssDefault, dcssSamesign);
  TDACChartSwitch = (dcswDefault, dcswAuto, dcswFalse, dcswTrue);
  TDACChartRenderState = (dcrsNormal, dcrsEmphasis, dcrsBlur, dcrsSelect);
  TDACChartMarkKind = (dcmkNone, dcmkBar, dcmkLine, dcmkPie, dcmkLegend, dcmkPrevious, dcmkNext);
  TDACChartTooltipEvent = (dcteMouseMove, dcteClick);
  TDACChartTooltipEvents = set of TDACChartTooltipEvent;
  TDACChartMeasureMode = (dcmmDefault, dcmmPixels, dcmmPercent, dcmmAuto,
    dcmmLeft, dcmmCenter, dcmmRight, dcmmTop, dcmmBottom);
  TDACChartLimitMode = (dclmDefault, dclmAuto, dclmValue, dclmDataMin, dclmDataMax);
  TDACChartFillKind = (dcfkDefault, dcfkSolid, dcfkLinear, dcfkRadial);
  TDACChartGradientStop = record
    Offset: Double;
    Color: TAlphaColor;
  end;
  TDACChartGradientStops = TArray<TDACChartGradientStop>;

  { A bound value writes through the same transactional store as JSON/DFM. }
  TDACChartValueAccess = class abstract
  public
    function Read(const APath: string): TJSONValue; virtual; abstract;
    procedure Write(const APath: string; AValue: TJSONValue); virtual; abstract;
  end;
  TDACChartBoundValue = class(TPersistent)
  protected
    FAccess: TDACChartValueAccess;
    FPath: string;
    function ReadValue: TJSONValue;
    procedure WriteValue(V: TJSONValue);
  public
    constructor Create(Access: TDACChartValueAccess; const Path: string);
    procedure Assign(Source: TPersistent); override;
    procedure Reset;
    function IsSpecified: Boolean;
  end;
  TDACChartBoundValueClass = class of TDACChartBoundValue;
  TDACChartMeasure = class(TDACChartBoundValue)
  private
    function GetMode: TDACChartMeasureMode;
    procedure SetMode(V: TDACChartMeasureMode);
    function GetValue: Double;
    procedure SetValue(V: Double);
  public
    procedure SetPixels(V: Double);
    procedure SetPercent(V: Double);
  published
    property Mode: TDACChartMeasureMode read GetMode write SetMode stored False;
    property Value: Double read GetValue write SetValue stored False;
  end;
  TDACChartAxisLimit = class(TDACChartBoundValue)
  private
    function GetMode: TDACChartLimitMode;
    procedure SetMode(V: TDACChartLimitMode);
    function GetValue: Double;
    procedure SetValue(V: Double);
  published
    property Mode: TDACChartLimitMode read GetMode write SetMode stored False;
    property Value: Double read GetValue write SetValue stored False;
  end;
  TDACChartFill = class(TDACChartBoundValue)
  private
    function GetKind: TDACChartFillKind;
    procedure SetKind(V: TDACChartFillKind);
    function GetColor: TAlphaColor;
    procedure SetColor(V: TAlphaColor);
    function GetStartColor: TAlphaColor;
    procedure SetStartColor(V: TAlphaColor);
    function GetEndColor: TAlphaColor;
    procedure SetEndColor(V: TAlphaColor);
    function GetCoordinate(Index: Integer): Double;
    procedure SetCoordinate(Index: Integer; V: Double);
    function Gradient: TJSONObject;
  public
    function GetStops: TDACChartGradientStops;
    procedure SetStops(const Stops: TDACChartGradientStops);
  published
    property Kind: TDACChartFillKind read GetKind write SetKind stored False;
    property Color: TAlphaColor read GetColor write SetColor stored False;
    property StartColor: TAlphaColor read GetStartColor write SetStartColor stored False;
    property EndColor: TAlphaColor read GetEndColor write SetEndColor stored False;
    property X: Double index 0 read GetCoordinate write SetCoordinate stored False;
    property Y: Double index 1 read GetCoordinate write SetCoordinate stored False;
    property X2: Double index 2 read GetCoordinate write SetCoordinate stored False;
    property Y2: Double index 3 read GetCoordinate write SetCoordinate stored False;
    property Radius: Double index 4 read GetCoordinate write SetCoordinate stored False;
  end;
  TDACChartTypes = class sealed
  public
    class function Orientation(V: TJSONValue; const Path: string; Default: TDACChartOrientation = dcoDefault): TDACChartOrientation; static;
    class function OrientationJSON(V: TDACChartOrientation): TJSONValue; static;
    class function LegendType(V: TJSONValue; const Path: string; Default: TDACChartLegendType = dclDefault): TDACChartLegendType; static;
    class function LegendTypeJSON(V: TDACChartLegendType): TJSONValue; static;
    class function SeriesType(V: TJSONValue; const Path: string; Default: TDACChartSeriesType = dcsDefault): TDACChartSeriesType; static;
    class function SeriesTypeJSON(V: TDACChartSeriesType): TJSONValue; static;
    class function AxisType(V: TJSONValue; const Path: string; Default: TDACChartAxisType = dcaDefault): TDACChartAxisType; static;
    class function AxisTypeJSON(V: TDACChartAxisType): TJSONValue; static;
    class function LabelPosition(V: TJSONValue; const Path: string; Default: TDACChartLabelPosition = dcpDefault): TDACChartLabelPosition; static;
    class function LabelPositionJSON(V: TDACChartLabelPosition): TJSONValue; static;
    class function TooltipTrigger(V: TJSONValue; const Path: string; Default: TDACChartTooltipTrigger = dctDefault): TDACChartTooltipTrigger; static;
    class function TooltipTriggerJSON(V: TDACChartTooltipTrigger): TJSONValue; static;
    class function OuterBoundsMode(V: TJSONValue; const Path: string; Default: TDACChartOuterBoundsMode = dcbDefault): TDACChartOuterBoundsMode; static;
    class function OuterBoundsModeJSON(V: TDACChartOuterBoundsMode): TJSONValue; static;
    class function SeriesLayout(V: TJSONValue; const Path: string; Default: TDACChartSeriesLayout = dcslDefault): TDACChartSeriesLayout; static;
    class function SeriesLayoutJSON(V: TDACChartSeriesLayout): TJSONValue; static;
    class function Step(V: TJSONValue; const Path: string; Default: TDACChartStep = dcstDefault): TDACChartStep; static;
    class function StepJSON(V: TDACChartStep): TJSONValue; static;
    class function Monotone(V: TJSONValue; const Path: string; Default: TDACChartMonotone = dcmDefault): TDACChartMonotone; static;
    class function MonotoneJSON(V: TDACChartMonotone): TJSONValue; static;
    class function Symbol(V: TJSONValue; const Path: string; Default: TDACChartSymbol = dcsyDefault): TDACChartSymbol; static;
    class function SymbolJSON(V: TDACChartSymbol): TJSONValue; static;
    class function Selection(V: TJSONValue; const Path: string; Default: TDACChartSelection = dcseDefault): TDACChartSelection; static;
    class function SelectionJSON(V: TDACChartSelection): TJSONValue; static;
    class function Easing(V: TJSONValue; const Path: string; Default: TDACChartEasing = dceDefault): TDACChartEasing; static;
    class function EasingJSON(V: TDACChartEasing): TJSONValue; static;
    class function LineType(V: TJSONValue; const Path: string; Default: TDACChartLineType = dcliDefault): TDACChartLineType; static;
    class function LineTypeJSON(V: TDACChartLineType): TJSONValue; static;
    class function PointerType(V: TJSONValue; const Path: string; Default: TDACChartPointerType = dcptDefault): TDACChartPointerType; static;
    class function PointerTypeJSON(V: TDACChartPointerType): TJSONValue; static;
    class function Focus(V: TJSONValue; const Path: string; Default: TDACChartFocus = dcfDefault): TDACChartFocus; static;
    class function FocusJSON(V: TDACChartFocus): TJSONValue; static;
    class function FontStyle(V: TJSONValue; const Path: string; Default: TDACChartFontStyle = dcfsDefault): TDACChartFontStyle; static;
    class function FontStyleJSON(V: TDACChartFontStyle): TJSONValue; static;
    class function TextAlign(V: TJSONValue; const Path: string; Default: TDACChartTextAlign = dctaDefault): TDACChartTextAlign; static;
    class function TextAlignJSON(V: TDACChartTextAlign): TJSONValue; static;
    class function VerticalAlign(V: TJSONValue; const Path: string; Default: TDACChartVerticalAlign = dcvaDefault): TDACChartVerticalAlign; static;
    class function VerticalAlignJSON(V: TDACChartVerticalAlign): TJSONValue; static;
    class function Overflow(V: TJSONValue; const Path: string; Default: TDACChartOverflow = dcovDefault): TDACChartOverflow; static;
    class function OverflowJSON(V: TDACChartOverflow): TJSONValue; static;
    class function RenderMode(V: TJSONValue; const Path: string; Default: TDACChartRenderMode = dcrmDefault): TDACChartRenderMode; static;
    class function RenderModeJSON(V: TDACChartRenderMode): TJSONValue; static;
    class function StackStrategy(V: TJSONValue; const Path: string; Default: TDACChartStackStrategy = dcssDefault): TDACChartStackStrategy; static;
    class function StackStrategyJSON(V: TDACChartStackStrategy): TJSONValue; static;
    class function Switch(V: TJSONValue; const Path: string; Default: TDACChartSwitch = dcswDefault): TDACChartSwitch; static;
    class function SwitchJSON(V: TDACChartSwitch): TJSONValue; static;
    class function TooltipEvents(V: TJSONValue; const Path: string;
      Default: TDACChartTooltipEvents = [dcteMouseMove,dcteClick]): TDACChartTooltipEvents; static;
    class function TooltipEventsJSON(V: TDACChartTooltipEvents): TJSONValue; static;
    class function Number(V: TJSONValue; const Path: string): Double; static;
    class function BooleanValue(V: TJSONValue; const Path: string): Boolean; static;
    class function FillKind(V: TJSONValue; const Path: string): TDACChartFillKind; static;
    class function Color(V: TJSONValue; const Path: string): TAlphaColor; static;
    class function ColorJSON(V: TAlphaColor): TJSONValue; static;
    class function Measure(V: TJSONValue; const Path: string; out Value: Double): TDACChartMeasureMode; static;
    class function MeasureJSON(Mode: TDACChartMeasureMode; Value: Double): TJSONValue; static;
    class procedure Validate(O: TJSONObject; SeriesOnly: Boolean = False); static;
  end;

implementation

uses System.Math;

function J(V: TJSONValue; const K: string): TJSONValue;
begin Result:=nil; if V is TJSONObject then Result:=TJSONObject(V).GetValue(K); end;
procedure Put(O: TJSONObject; const K: string; V: TJSONValue);
begin O.RemovePair(K).Free; if V<>nil then O.AddPair(K,V); end;
procedure Bad(const Path,Expected: string);
begin raise EDACChartOptionError.Create(Path+': esperado '+Expected); end;
function Choice(V: TJSONValue; const Path,Tokens: string; Default: Integer): Integer;
var A: TArray<string>; I: Integer; S: string;
begin
  if V=nil then Exit(Default);
  if not ((V is TJSONString) or (V is TJSONBool)) then Bad(Path,'opcao enumerada');
  S:=V.Value;
  if (Path.EndsWith('.step') or (Path='step')) and (V is TJSONBool) and (S='true') then S:='end';
  if Path.EndsWith('selectedMode') and (V is TJSONBool) and (S='true') then S:='multiple';
  if (V is TJSONString) and ((S='true') or (S='false')) then Bad(Path,'boolean JSON, nao texto');
  A:=Tokens.Split(['|']);
  for I:=0 to High(A) do if S=A[I] then Exit(I+1);
  Bad(Path,Tokens); Result:=0;
end;
function ChoiceJSON(V: Integer; const Tokens: string): TJSONValue;
var A: TArray<string>; S: string;
begin
  if V=0 then Exit(nil); A:=Tokens.Split(['|']);
  if (V<1) or (V>Length(A)) then Bad('enum','valor valido');
  S:=A[V-1];
  if (S='false') or (S='true') then Result:=TJSONBool.Create(S='true')
  else Result:=TJSONString.Create(S);
end;
class function TDACChartTypes.Orientation(V: TJSONValue; const Path: string; Default: TDACChartOrientation): TDACChartOrientation;
begin Result:=TDACChartOrientation(Choice(V,Path,'horizontal|vertical',Ord(Default))); end;
class function TDACChartTypes.OrientationJSON(V: TDACChartOrientation): TJSONValue;
begin Result:=ChoiceJSON(Ord(V),'horizontal|vertical'); end;
class function TDACChartTypes.LegendType(V: TJSONValue; const Path: string; Default: TDACChartLegendType): TDACChartLegendType;
begin Result:=TDACChartLegendType(Choice(V,Path,'plain|scroll',Ord(Default))); end;
class function TDACChartTypes.LegendTypeJSON(V: TDACChartLegendType): TJSONValue;
begin Result:=ChoiceJSON(Ord(V),'plain|scroll'); end;
class function TDACChartTypes.SeriesType(V: TJSONValue; const Path: string; Default: TDACChartSeriesType): TDACChartSeriesType;
begin Result:=TDACChartSeriesType(Choice(V,Path,'bar|line|pie',Ord(Default))); end;
class function TDACChartTypes.SeriesTypeJSON(V: TDACChartSeriesType): TJSONValue;
begin Result:=ChoiceJSON(Ord(V),'bar|line|pie'); end;
class function TDACChartTypes.AxisType(V: TJSONValue; const Path: string; Default: TDACChartAxisType): TDACChartAxisType;
begin Result:=TDACChartAxisType(Choice(V,Path,'category|value|time',Ord(Default))); end;
class function TDACChartTypes.AxisTypeJSON(V: TDACChartAxisType): TJSONValue;
begin Result:=ChoiceJSON(Ord(V),'category|value|time'); end;
class function TDACChartTypes.LabelPosition(V: TJSONValue; const Path: string; Default: TDACChartLabelPosition): TDACChartLabelPosition;
begin Result:=TDACChartLabelPosition(Choice(V,Path,'top|bottom|left|right|inside|insideTop|insideBottom|outside',Ord(Default))); end;
class function TDACChartTypes.LabelPositionJSON(V: TDACChartLabelPosition): TJSONValue;
begin Result:=ChoiceJSON(Ord(V),'top|bottom|left|right|inside|insideTop|insideBottom|outside'); end;
class function TDACChartTypes.TooltipTrigger(V: TJSONValue; const Path: string; Default: TDACChartTooltipTrigger): TDACChartTooltipTrigger;
begin Result:=TDACChartTooltipTrigger(Choice(V,Path,'item|axis|none',Ord(Default))); end;
class function TDACChartTypes.TooltipTriggerJSON(V: TDACChartTooltipTrigger): TJSONValue;
begin Result:=ChoiceJSON(Ord(V),'item|axis|none'); end;
class function TDACChartTypes.OuterBoundsMode(V: TJSONValue; const Path: string; Default: TDACChartOuterBoundsMode): TDACChartOuterBoundsMode;
begin Result:=TDACChartOuterBoundsMode(Choice(V,Path,'none',Ord(Default))); end;
class function TDACChartTypes.OuterBoundsModeJSON(V: TDACChartOuterBoundsMode): TJSONValue;
begin Result:=ChoiceJSON(Ord(V),'none'); end;
class function TDACChartTypes.SeriesLayout(V: TJSONValue; const Path: string; Default: TDACChartSeriesLayout): TDACChartSeriesLayout;
begin Result:=TDACChartSeriesLayout(Choice(V,Path,'column|row',Ord(Default))); end;
class function TDACChartTypes.SeriesLayoutJSON(V: TDACChartSeriesLayout): TJSONValue;
begin Result:=ChoiceJSON(Ord(V),'column|row'); end;
class function TDACChartTypes.Step(V: TJSONValue; const Path: string; Default: TDACChartStep): TDACChartStep;
begin Result:=TDACChartStep(Choice(V,Path,'false|start|middle|end',Ord(Default))); end;
class function TDACChartTypes.StepJSON(V: TDACChartStep): TJSONValue;
begin Result:=ChoiceJSON(Ord(V),'false|start|middle|end'); end;
class function TDACChartTypes.Monotone(V: TJSONValue; const Path: string; Default: TDACChartMonotone): TDACChartMonotone;
begin Result:=TDACChartMonotone(Choice(V,Path,'none|x|y',Ord(Default))); end;
class function TDACChartTypes.MonotoneJSON(V: TDACChartMonotone): TJSONValue;
begin Result:=ChoiceJSON(Ord(V),'none|x|y'); end;
class function TDACChartTypes.Symbol(V: TJSONValue; const Path: string; Default: TDACChartSymbol): TDACChartSymbol;
begin Result:=TDACChartSymbol(Choice(V,Path,'none|circle|emptyCircle|rect|roundRect|triangle|diamond',Ord(Default))); end;
class function TDACChartTypes.SymbolJSON(V: TDACChartSymbol): TJSONValue;
begin Result:=ChoiceJSON(Ord(V),'none|circle|emptyCircle|rect|roundRect|triangle|diamond'); end;
class function TDACChartTypes.Selection(V: TJSONValue; const Path: string; Default: TDACChartSelection): TDACChartSelection;
begin Result:=TDACChartSelection(Choice(V,Path,'false|single|multiple',Ord(Default))); end;
class function TDACChartTypes.SelectionJSON(V: TDACChartSelection): TJSONValue;
begin Result:=ChoiceJSON(Ord(V),'false|single|multiple'); end;
class function TDACChartTypes.Easing(V: TJSONValue; const Path: string; Default: TDACChartEasing): TDACChartEasing;
begin Result:=TDACChartEasing(Choice(V,Path,'linear|cubicIn|cubicOut|cubicInOut',Ord(Default))); end;
class function TDACChartTypes.EasingJSON(V: TDACChartEasing): TJSONValue;
begin Result:=ChoiceJSON(Ord(V),'linear|cubicIn|cubicOut|cubicInOut'); end;
class function TDACChartTypes.LineType(V: TJSONValue; const Path: string; Default: TDACChartLineType): TDACChartLineType;
begin Result:=TDACChartLineType(Choice(V,Path,'solid|dashed|dotted',Ord(Default))); end;
class function TDACChartTypes.LineTypeJSON(V: TDACChartLineType): TJSONValue;
begin Result:=ChoiceJSON(Ord(V),'solid|dashed|dotted'); end;
class function TDACChartTypes.PointerType(V: TJSONValue; const Path: string; Default: TDACChartPointerType): TDACChartPointerType;
begin Result:=TDACChartPointerType(Choice(V,Path,'none|line|shadow',Ord(Default))); end;
class function TDACChartTypes.PointerTypeJSON(V: TDACChartPointerType): TJSONValue;
begin Result:=ChoiceJSON(Ord(V),'none|line|shadow'); end;
class function TDACChartTypes.Focus(V: TJSONValue; const Path: string; Default: TDACChartFocus): TDACChartFocus;
begin Result:=TDACChartFocus(Choice(V,Path,'none|series',Ord(Default))); end;
class function TDACChartTypes.FocusJSON(V: TDACChartFocus): TJSONValue;
begin Result:=ChoiceJSON(Ord(V),'none|series'); end;
class function TDACChartTypes.FontStyle(V: TJSONValue; const Path: string; Default: TDACChartFontStyle): TDACChartFontStyle;
begin Result:=TDACChartFontStyle(Choice(V,Path,'normal|italic',Ord(Default))); end;
class function TDACChartTypes.FontStyleJSON(V: TDACChartFontStyle): TJSONValue;
begin Result:=ChoiceJSON(Ord(V),'normal|italic'); end;
class function TDACChartTypes.TextAlign(V: TJSONValue; const Path: string; Default: TDACChartTextAlign): TDACChartTextAlign;
begin Result:=TDACChartTextAlign(Choice(V,Path,'left|center|right',Ord(Default))); end;
class function TDACChartTypes.TextAlignJSON(V: TDACChartTextAlign): TJSONValue;
begin Result:=ChoiceJSON(Ord(V),'left|center|right'); end;
class function TDACChartTypes.VerticalAlign(V: TJSONValue; const Path: string; Default: TDACChartVerticalAlign): TDACChartVerticalAlign;
begin Result:=TDACChartVerticalAlign(Choice(V,Path,'top|middle|bottom',Ord(Default))); end;
class function TDACChartTypes.VerticalAlignJSON(V: TDACChartVerticalAlign): TJSONValue;
begin Result:=ChoiceJSON(Ord(V),'top|middle|bottom'); end;
class function TDACChartTypes.Overflow(V: TJSONValue; const Path: string; Default: TDACChartOverflow): TDACChartOverflow;
begin Result:=TDACChartOverflow(Choice(V,Path,'truncate',Ord(Default))); end;
class function TDACChartTypes.OverflowJSON(V: TDACChartOverflow): TJSONValue;
begin Result:=ChoiceJSON(Ord(V),'truncate'); end;
class function TDACChartTypes.RenderMode(V: TJSONValue; const Path: string; Default: TDACChartRenderMode): TDACChartRenderMode;
begin Result:=TDACChartRenderMode(Choice(V,Path,'richText',Ord(Default))); end;
class function TDACChartTypes.RenderModeJSON(V: TDACChartRenderMode): TJSONValue;
begin Result:=ChoiceJSON(Ord(V),'richText'); end;
class function TDACChartTypes.StackStrategy(V: TJSONValue; const Path: string; Default: TDACChartStackStrategy): TDACChartStackStrategy;
begin Result:=TDACChartStackStrategy(Choice(V,Path,'samesign',Ord(Default))); end;
class function TDACChartTypes.StackStrategyJSON(V: TDACChartStackStrategy): TJSONValue;
begin Result:=ChoiceJSON(Ord(V),'samesign'); end;
class function TDACChartTypes.Switch(V: TJSONValue; const Path: string; Default: TDACChartSwitch): TDACChartSwitch;
begin Result:=TDACChartSwitch(Choice(V,Path,'auto|false|true',Ord(Default))); end;
class function TDACChartTypes.SwitchJSON(V: TDACChartSwitch): TJSONValue;
begin Result:=ChoiceJSON(Ord(V),'auto|false|true'); end;
class function TDACChartTypes.TooltipEvents(V: TJSONValue; const Path: string;
  Default: TDACChartTooltipEvents): TDACChartTooltipEvents;
var S: string; Parts: TArray<string>; P: string;
begin
  if V=nil then Exit(Default);
  if not (V is TJSONString) then Bad(Path,'mousemove, click, mousemove|click ou none');
  S:=V.Value; Result:=[]; if S='none' then Exit;
  Parts:=S.Split(['|']);
  for P in Parts do
    if (P='mousemove') and not (dcteMouseMove in Result) then Include(Result,dcteMouseMove)
    else if (P='click') and not (dcteClick in Result) then Include(Result,dcteClick)
    else Bad(Path,'eventos validos sem repeticao');
end;
class function TDACChartTypes.TooltipEventsJSON(V: TDACChartTooltipEvents): TJSONValue;
var S: string;
begin
  S:='none'; if dcteMouseMove in V then S:='mousemove';
  if dcteClick in V then if S='mousemove' then S:=S+'|click' else S:='click';
  Result:=TJSONString.Create(S);
end;
class function TDACChartTypes.Number(V: TJSONValue; const Path: string): Double;
begin
  if not (V is TJSONNumber) then Bad(Path,'numero JSON');
  Result:=TJSONNumber(V).AsDouble;
  if IsNan(Result) or IsInfinite(Result) then Bad(Path,'numero finito');
end;
class function TDACChartTypes.BooleanValue(V: TJSONValue; const Path: string): Boolean;
begin
  if not (V is TJSONBool) then Bad(Path,'boolean JSON');
  Result:=V.Value='true';
end;
class function TDACChartTypes.FillKind(V: TJSONValue; const Path: string): TDACChartFillKind;
begin
  if V=nil then Exit(dcfkDefault);
  if V is TJSONString then begin Color(V,Path); Exit(dcfkSolid); end;
  if (J(V,'type') is TJSONString) and (J(V,'type').Value='linear') then Exit(dcfkLinear);
  if (J(V,'type') is TJSONString) and (J(V,'type').Value='radial') then Exit(dcfkRadial);
  Bad(Path,'cor solida ou gradiente linear/radial'); Result:=dcfkDefault;
end;
class function TDACChartTypes.Color(V: TJSONValue; const Path: string): TAlphaColor;
var S: string; N: Int64; P: TArray<string>; C: array[0..3] of Integer;
  I: Integer; D: Double; Alpha: Boolean;
begin
  if not (V is TJSONString) then Bad(Path,'cor CSS suportada'); S:=LowerCase(V.Value);
  if S='transparent' then Exit(0);
  if S='white' then Exit($FFFFFFFF); if S='black' then Exit($FF000000);
  if S='red' then Exit($FFFF0000); if S='green' then Exit($FF008000); if S='blue' then Exit($FF0000FF);
  if S.StartsWith('#') then begin
    S:=Copy(S,2,MaxInt);
    if Length(S)=3 then S:=S[1]+S[1]+S[2]+S[2]+S[3]+S[3];
    if not ((Length(S)=6) or (Length(S)=8)) then Bad(Path,'#RGB, #RRGGBB ou #RRGGBBAA');
    for I:=1 to Length(S) do if not CharInSet(S[I],['0'..'9','a'..'f']) then Bad(Path,'hexadecimal de cor');
    if not TryStrToInt64('$'+S,N) then Bad(Path,'hexadecimal de cor');
    if Length(S)=6 then Exit($FF000000 or Cardinal(N));
    Exit((Cardinal(N) shr 8) or ((Cardinal(N) and $FF) shl 24));
  end;
  Alpha:=S.StartsWith('rgba(');
  if (Alpha or S.StartsWith('rgb(')) and S.EndsWith(')') then begin
    S:=Copy(S,Pos('(',S)+1,Length(S)-Pos('(',S)-1); P:=S.Split([',']);
    if Length(P)<>3+Ord(Alpha) then Bad(Path,'canais RGB/RGBA');
    for I:=0 to 2 do begin
      if not TryStrToInt(Trim(P[I]),C[I]) then Bad(Path,'canal RGB inteiro');
      if (C[I]<0) or (C[I]>255) then Bad(Path,'canal RGB 0..255');
    end;
    C[3]:=255;
    if Alpha then begin
      if not TryStrToFloat(Trim(P[3]),D,TFormatSettings.Invariant) then Bad(Path,'alpha numerico');
      if IsNan(D) or IsInfinite(D) or (D<0) or (D>1) then Bad(Path,'alpha 0..1'); C[3]:=Round(D*255);
    end;
    Exit((Cardinal(C[3]) shl 24) or (Cardinal(C[0]) shl 16) or (Cardinal(C[1]) shl 8) or Cardinal(C[2]));
  end;
  Bad(Path,'cor suportada (#RGB/#RRGGBB/#RRGGBBAA/rgb/rgba)'); Result:=0;
end;
class function TDACChartTypes.ColorJSON(V: TAlphaColor): TJSONValue;
begin Result:=TJSONString.Create('#'+IntToHex((V shl 8) or (V shr 24),8)); end;
class function TDACChartTypes.Measure(V: TJSONValue; const Path: string; out Value: Double): TDACChartMeasureMode;
var S: string;
begin
  Value:=0; if V=nil then Exit(dcmmDefault);
  if V is TJSONNumber then begin Value:=Number(V,Path); Exit(dcmmPixels); end;
  if not (V is TJSONString) then Bad(Path,'medida ou alinhamento');
  S:=V.Value;
  if S='auto' then Exit(dcmmAuto); if S='left' then Exit(dcmmLeft);
  if S='center' then Exit(dcmmCenter); if S='right' then Exit(dcmmRight);
  if S='top' then Exit(dcmmTop); if S='bottom' then Exit(dcmmBottom);
  Result:=dcmmPixels;
  if S.EndsWith('%') then begin Result:=dcmmPercent; Delete(S,Length(S),1); end;
  if not TryStrToFloat(S,Value,TFormatSettings.Invariant) then Bad(Path,'numero ou percentual');
  if IsNan(Value) or IsInfinite(Value) then Bad(Path,'medida finita');
end;
class function TDACChartTypes.MeasureJSON(Mode: TDACChartMeasureMode; Value: Double): TJSONValue;
const Names: array[dcmmAuto..dcmmBottom] of string=('auto','left','center','right','top','bottom');
begin
  if IsNan(Value) or IsInfinite(Value) then Bad('measure','numero finito');
  case Mode of
    dcmmDefault: Result:=nil;
    dcmmPixels: Result:=TJSONNumber.Create(Value);
    dcmmPercent: Result:=TJSONString.Create(FloatToStr(Value,TFormatSettings.Invariant)+'%');
    dcmmAuto..dcmmBottom: Result:=TJSONString.Create(Names[Mode]);
  else Bad('measure.mode','modo valido'); Result:=nil; end;
end;

constructor TDACChartBoundValue.Create(Access: TDACChartValueAccess; const Path: string);
begin inherited Create; FAccess:=Access; FPath:=Path; end;
function TDACChartBoundValue.ReadValue: TJSONValue;
begin Result:=FAccess.Read(FPath); end;
procedure TDACChartBoundValue.WriteValue(V: TJSONValue);
begin FAccess.Write(FPath,V); end;
procedure TDACChartBoundValue.Assign(Source: TPersistent);
var V: TJSONValue;
begin
  if Source is TDACChartBoundValue then begin
    V:=TDACChartBoundValue(Source).ReadValue;
    if V=nil then Reset else WriteValue(TJSONValue(V.Clone));
  end else inherited;
end;
procedure TDACChartBoundValue.Reset;
begin WriteValue(nil); end;
function TDACChartBoundValue.IsSpecified: Boolean;
begin Result:=ReadValue<>nil; end;
function TDACChartMeasure.GetMode: TDACChartMeasureMode;
var D: Double;
begin Result:=TDACChartTypes.Measure(ReadValue,FPath,D); end;
function TDACChartMeasure.GetValue: Double;
begin TDACChartTypes.Measure(ReadValue,FPath,Result); end;
procedure TDACChartMeasure.SetMode(V: TDACChartMeasureMode);
begin WriteValue(TDACChartTypes.MeasureJSON(V,GetValue)); end;
procedure TDACChartMeasure.SetValue(V: Double);
var M: TDACChartMeasureMode;
begin M:=GetMode; if not (M in [dcmmPixels,dcmmPercent]) then M:=dcmmPixels; WriteValue(TDACChartTypes.MeasureJSON(M,V)); end;
procedure TDACChartMeasure.SetPixels(V: Double);
begin WriteValue(TDACChartTypes.MeasureJSON(dcmmPixels,V)); end;
procedure TDACChartMeasure.SetPercent(V: Double);
begin WriteValue(TDACChartTypes.MeasureJSON(dcmmPercent,V)); end;
function TDACChartAxisLimit.GetMode: TDACChartLimitMode;
var V: TJSONValue;
begin
  V:=ReadValue; if V=nil then Exit(dclmDefault); if V is TJSONNumber then Exit(dclmValue);
  if V.Value='auto' then Exit(dclmAuto); if V.Value='dataMin' then Exit(dclmDataMin);
  if V.Value='dataMax' then Exit(dclmDataMax); Bad(FPath,'limite tipado'); Result:=dclmDefault;
end;
function TDACChartAxisLimit.GetValue: Double;
begin Result:=0; if GetMode=dclmValue then Result:=TDACChartTypes.Number(ReadValue,FPath); end;
procedure TDACChartAxisLimit.SetMode(V: TDACChartLimitMode);
begin
  case V of
    dclmDefault: Reset; dclmAuto: WriteValue(TJSONString.Create('auto'));
    dclmValue: SetValue(GetValue); dclmDataMin: WriteValue(TJSONString.Create('dataMin'));
    dclmDataMax: WriteValue(TJSONString.Create('dataMax'));
  else Bad(FPath,'modo de limite valido'); end;
end;
procedure TDACChartAxisLimit.SetValue(V: Double);
begin if IsNan(V) or IsInfinite(V) then Bad(FPath,'limite finito'); WriteValue(TJSONNumber.Create(V)); end;
function TDACChartFill.GetKind: TDACChartFillKind;
begin Result:=TDACChartTypes.FillKind(ReadValue,FPath); end;
function TDACChartFill.Gradient: TJSONObject;
begin
  if ReadValue is TJSONObject then Exit(TJSONObject(ReadValue.Clone));
  Result:=TJSONObject.ParseJSONValue('{"type":"linear","x":0,"y":0,"x2":0,"y2":1,"colorStops":[{"offset":0,"color":"#000000"},{"offset":1,"color":"#ffffff"}]}') as TJSONObject;
end;
procedure TDACChartFill.SetKind(V: TDACChartFillKind);
var O: TJSONObject;
begin
  case V of
    dcfkDefault: Reset;
    dcfkSolid: SetColor(GetColor);
    dcfkLinear,dcfkRadial: begin
      O:=Gradient;
      if V=dcfkLinear then begin Put(O,'type',TJSONString.Create('linear')); O.RemovePair('r').Free; end
      else begin Put(O,'type',TJSONString.Create('radial')); O.RemovePair('x2').Free; O.RemovePair('y2').Free; end;
      WriteValue(O);
    end;
  else Bad(FPath,'preenchimento valido'); end;
end;
function TDACChartFill.GetColor: TAlphaColor;
begin Result:=$FF000000; if ReadValue is TJSONString then Result:=TDACChartTypes.Color(ReadValue,FPath); end;
procedure TDACChartFill.SetColor(V: TAlphaColor);
begin WriteValue(TDACChartTypes.ColorJSON(V)); end;
function TDACChartFill.GetStops: TDACChartGradientStops;
var O: TJSONObject; A: TJSONArray; I: Integer;
begin
  O:=Gradient;
  try
    A:=TJSONArray(J(O,'colorStops')); SetLength(Result,A.Count);
    for I:=0 to A.Count-1 do begin Result[I].Offset:=TDACChartTypes.Number(J(A.Items[I],'offset'),FPath); Result[I].Color:=TDACChartTypes.Color(J(A.Items[I],'color'),FPath); end;
  finally O.Free; end;
end;
procedure TDACChartFill.SetStops(const Stops: TDACChartGradientStops);
var O: TJSONObject; A: TJSONArray; Stop: TDACChartGradientStop;
begin
  O:=Gradient;
  try
    A:=TJSONArray.Create; Put(O,'colorStops',A);
    for Stop in Stops do A.AddElement(TJSONObject.Create.AddPair('offset',TJSONNumber.Create(Stop.Offset)).AddPair('color',TDACChartTypes.ColorJSON(Stop.Color)));
  except O.Free; raise; end;
  WriteValue(O);
end;
function TDACChartFill.GetStartColor: TAlphaColor;
var S: TDACChartGradientStops;
begin S:=GetStops; Result:=S[0].Color; end;
function TDACChartFill.GetEndColor: TAlphaColor;
var S: TDACChartGradientStops;
begin S:=GetStops; Result:=S[High(S)].Color; end;
procedure TDACChartFill.SetStartColor(V: TAlphaColor);
var S: TDACChartGradientStops;
begin S:=GetStops; S[0].Color:=V; SetStops(S); end;
procedure TDACChartFill.SetEndColor(V: TAlphaColor);
var S: TDACChartGradientStops;
begin S:=GetStops; S[High(S)].Color:=V; SetStops(S); end;
function TDACChartFill.GetCoordinate(Index: Integer): Double;
const Keys: array[0..4] of string=('x','y','x2','y2','r');
var V: TJSONValue;
begin
  Result:=0; if Index=3 then Result:=1 else if Index=4 then Result:=0.5;
  V:=J(ReadValue,Keys[Index]); if V<>nil then Result:=TDACChartTypes.Number(V,FPath+'.'+Keys[Index]);
end;
procedure TDACChartFill.SetCoordinate(Index: Integer; V: Double);
const Keys: array[0..4] of string=('x','y','x2','y2','r');
var O: TJSONObject;
begin
  if IsNan(V) or IsInfinite(V) then Bad(FPath+'.'+Keys[Index],'numero finito');
  O:=Gradient; Put(O,Keys[Index],TJSONNumber.Create(V)); WriteValue(O);
end;

class procedure TDACChartTypes.Validate(O: TJSONObject; SeriesOnly: Boolean);
  function InList(const S,List: string): Boolean;
  begin Result:=Pos('|'+S+'|','|'+List+'|')>0; end;
  procedure Keys(V: TJSONValue; const P,Allowed: string);
  var Pair: TJSONPair; Seen: TStringList;
  begin
    if not (V is TJSONObject) then Bad(P,'objeto');
    Seen:=TStringList.Create;
    try
      Seen.CaseSensitive:=True;
      for Pair in TJSONObject(V) do begin
        if Seen.IndexOf(Pair.JsonString.Value)>=0 then Bad(P+'.'+Pair.JsonString.Value,'chave sem duplicacao');
        Seen.Add(Pair.JsonString.Value);
        if not InList(Pair.JsonString.Value,Allowed) then Bad(P+'.'+Pair.JsonString.Value,'opcao suportada');
      end;
    finally Seen.Free; end;
  end;
  procedure Walk(V: TJSONValue; const P,C: string); forward;
  procedure Numeric(V: TJSONValue; const P,K: string);
  var N: Double;
  begin
    N:=Number(V,P);
    if InList(K,'opacity|smooth|offset') and ((N<0) or (N>1)) then Bad(P,'numero 0..1');
    if InList(K,'width|height|fontSize|lineHeight|padding|borderWidth|borderRadius|shadowBlur|distance|itemGap|itemWidth|itemHeight|showDelay|hideDelay|animationDuration|animationDurationUpdate|animationThreshold|barMinWidth|barMaxWidth|' +
      'barMinHeight|symbolSize|selectedOffset|percentPrecision|margin|length|length2|r') and (N<0) then Bad(P,'numero nao negativo');
    if InList(K,'splitNumber|interval') and (N<=0) then Bad(P,'numero positivo');
    if InList(K,'animationThreshold|percentPrecision|datasetIndex') and (Frac(N)<>0) then Bad(P,'numero inteiro');
    if (K='percentPrecision') and (N>15) then Bad(P,'precisao 0..15');
    if (K='datasetIndex') and (N<>0) then Bad(P,'datasetIndex 0');
  end;
  procedure MeasureAt(V: TJSONValue; const P,K,C: string);
  var N: Double; M: TDACChartMeasureMode; Allowed: set of TDACChartMeasureMode;
  begin
    M:=Measure(V,P,N); Allowed:=[dcmmPixels,dcmmPercent];
    if ((C='title') or (C='legend')) and (K='left') then Allowed:=Allowed+[dcmmLeft,dcmmCenter,dcmmRight];
    if (C='legend') and (K='top') then Allowed:=Allowed+[dcmmTop,dcmmBottom];
    if (C='title') and (K='top') then Allowed:=Allowed+[dcmmTop];
    if not (M in Allowed) then Bad(P,'medida/alinhamento suportado neste contexto');
    if InList(K,'radius|barWidth|barCategoryGap') and (N<0) then Bad(P,'medida nao negativa');
  end;
  procedure Fill(V: TJSONValue; const P: string; GradientAllowed: Boolean);
  var A: TJSONArray; I: Integer; Last,Offset: Double; Kind: string;
  begin
    if V is TJSONString then begin Color(V,P); Exit; end;
    if not GradientAllowed then Bad(P,'cor solida');
    Keys(V,P,'type|x|y|x2|y2|r|colorStops');
    if not (J(V,'type') is TJSONString) then Bad(P+'.type','linear ou radial');
    Kind:=J(V,'type').Value;
    if not InList(Kind,'linear|radial') then Bad(P+'.type','linear ou radial');
    if (Kind='linear') and (J(V,'r')<>nil) then Bad(P+'.r','raio apenas em radial');
    if (Kind='radial') and ((J(V,'x2')<>nil) or (J(V,'y2')<>nil)) then Bad(P,'radial sem x2/y2');
    for I:=0 to 4 do
      case I of
        0: if J(V,'x')<>nil then Number(J(V,'x'),P+'.x');
        1: if J(V,'y')<>nil then Number(J(V,'y'),P+'.y');
        2: if J(V,'x2')<>nil then Number(J(V,'x2'),P+'.x2');
        3: if J(V,'y2')<>nil then Number(J(V,'y2'),P+'.y2');
        4: if J(V,'r')<>nil then Numeric(J(V,'r'),P+'.r','r');
      end;
    if not (J(V,'colorStops') is TJSONArray) then Bad(P+'.colorStops','array de paradas');
    A:=TJSONArray(J(V,'colorStops')); if A.Count<2 then Bad(P+'.colorStops','ao menos duas paradas');
    Last:=-1;
    for I:=0 to A.Count-1 do begin
      Keys(A.Items[I],Format('%s.colorStops[%d]',[P,I]),'offset|color');
      Offset:=Number(J(A.Items[I],'offset'),Format('%s.colorStops[%d].offset',[P,I]));
      if (Offset<0) or (Offset>1) or (Offset<Last) then Bad(P+'.colorStops','offsets crescentes em 0..1');
      Last:=Offset; Color(J(A.Items[I],'color'),Format('%s.colorStops[%d].color',[P,I]));
    end;
  end;
  procedure Walk(V: TJSONValue; const P,C: string);
  var Pair,Sub: TJSONPair; K,Q: string; W: TJSONValue; A: TJSONArray;
    I: Integer; N: Double;
  begin
    if C='root' then Keys(V,P,'animation|animationDuration|animationDurationUpdate|animationEasing|animationEasingUpdate|animationThreshold|backgroundColor|color|useUTC|dataset|series|xAxis|yAxis|grid|title|legend|tooltip')
    else if C='series' then Keys(V,P,'id|name|type|data|datasetIndex|seriesLayoutBy|encode|itemStyle|lineStyle|areaStyle|label|labelLine|labelLayout|emphasis|blur|select|selectedMode|selectedOffset|smooth|smoothMonotone|step|connectNulls|symbol|symbolSize|sh' +
      'owSymbol|barWidth|barMinWidth|barMaxWidth|barMinHeight|barGap|barCategoryGap|stack|stackStrategy|center|radius|startAngle|clockwise|stillShowZeroSum|showEmptyCircle|emptyCircleStyle|percentPrecision|avoidLabelOverlap')
    else if C='axis' then Keys(V,P,'type|data|min|max|inverse|boundaryGap|splitNumber|interval|scale|show|name|nameTextStyle|axisLine|axisLabel|axisTick|splitLine')
    else if C='title' then Keys(V,P,'show|text|subtext|left|top|itemGap|textStyle|subtextStyle')
    else if C='legend' then Keys(V,P,'show|type|orient|left|top|itemGap|itemWidth|itemHeight|textStyle|selected|selectedMode')
    else if C='tooltip' then Keys(V,P,'show|trigger|triggerOn|confine|renderMode|formatter|showDelay|hideDelay|backgroundColor|borderColor|padding|textStyle|axisPointer')
    else if C='grid' then Keys(V,P,'left|right|top|bottom|outerBoundsMode')
    else if C='dataset' then Keys(V,P,'source|dimensions|sourceHeader')
    else if C='style' then Keys(V,P,'color|opacity|width|type|borderColor|borderWidth|borderRadius|shadowBlur|shadowColor|shadowOffsetX|shadowOffsetY')
    else if C='label' then Keys(V,P,'show|position|distance|formatter|rotate|color|fontFamily|fontSize|fontWeight|fontStyle|lineHeight|width|height|padding|align|verticalAlign|overflow|backgroundColor|borderColor|borderWidth|borderRadius|shadowBlur|shadowCo' +
      'lor|shadowOffsetX|shadowOffsetY|rich|interval|margin')
    else if C='state' then Keys(V,P,'itemStyle|focus')
    else if C='axisLine' then Keys(V,P,'show|onZero|lineStyle')
    else if C='axisTick' then Keys(V,P,'show|length|lineStyle')
    else if C='splitLine' then Keys(V,P,'show|lineStyle')
    else if C='labelLine' then Keys(V,P,'show|lineStyle')
    else if C='labelLayout' then Keys(V,P,'hideOverlap')
    else if C='axisPointer' then Keys(V,P,'type|lineStyle|shadowStyle')
    else if C='encode' then Keys(V,P,'x|y|value')
    else if C='datum' then Keys(V,P,'id|name|value|itemStyle|label|emphasis|blur|select')
    else Bad(P,'grupo conhecido');
    for Pair in TJSONObject(V) do begin
      K:=Pair.JsonString.Value; W:=Pair.JsonValue; Q:=P+'.'+K;
      if W is TJSONNull then begin
        if (C='datum') and (K='value') then Continue;
        Bad(Q,'valor explicito valido; remova a chave para herdar o default');
      end;
      if InList(K,'xAxis|yAxis') then Walk(W,Q,'axis')
      else if InList(K,'dataset|grid|title|legend|tooltip|axisLine|axisTick|splitLine|labelLine|labelLayout|axisPointer|encode') then Walk(W,Q,K)
      else if InList(K,'itemStyle|lineStyle|areaStyle|shadowStyle|emptyCircleStyle') then Walk(W,Q,'style')
      else if InList(K,'label|axisLabel|textStyle|subtextStyle|nameTextStyle') then Walk(W,Q,'label')
      else if InList(K,'emphasis|blur|select') then Walk(W,Q,'state')
      else if K='rich' then begin
        if not (W is TJSONObject) then Bad(Q,'objeto de estilos');
        for Sub in TJSONObject(W) do Walk(Sub.JsonValue,Q+'.'+Sub.JsonString.Value,'label');
      end
      else if K='series' then begin
        if not (W is TJSONArray) then Bad(Q,'array de series');
        A:=TJSONArray(W); for I:=0 to A.Count-1 do Walk(A.Items[I],Format('%s[%d]',[Q,I]),'series');
      end
      else if K='type' then begin
        if C='series' then SeriesType(W,Q)
        else if C='axis' then AxisType(W,Q)
        else if C='legend' then LegendType(W,Q)
        else if C='axisPointer' then PointerType(W,Q)
        else if C='style' then LineType(W,Q)
        else Bad(Q,'tipo contextual');
      end
      else if K='orient' then Orientation(W,Q)
      else if K='position' then LabelPosition(W,Q)
      else if K='trigger' then TooltipTrigger(W,Q)
      else if K='triggerOn' then TooltipEvents(W,Q)
      else if K='outerBoundsMode' then OuterBoundsMode(W,Q)
      else if K='seriesLayoutBy' then SeriesLayout(W,Q)
      else if K='step' then Step(W,Q)
      else if K='smoothMonotone' then Monotone(W,Q)
      else if K='symbol' then Symbol(W,Q)
      else if K='selectedMode' then Selection(W,Q)
      else if InList(K,'animationEasing|animationEasingUpdate') then Easing(W,Q)
      else if K='focus' then Focus(W,Q)
      else if K='fontStyle' then FontStyle(W,Q)
      else if K='align' then TextAlign(W,Q)
      else if K='verticalAlign' then VerticalAlign(W,Q)
      else if K='overflow' then Overflow(W,Q)
      else if K='renderMode' then RenderMode(W,Q)
      else if K='stackStrategy' then StackStrategy(W,Q)
      else if InList(K,'animation|sourceHeader') then Switch(W,Q)
      else if InList(K,'left|right|top|bottom|barWidth|barGap|barCategoryGap') then MeasureAt(W,Q,K,C)
      else if InList(K,'min|max') then begin
        if W is TJSONNumber then Number(W,Q)
        else if not ((W is TJSONString) and InList(W.Value,'auto|dataMin|dataMax')) then Bad(Q,'numero, auto, dataMin ou dataMax');
      end
      else if InList(K,'color|backgroundColor|borderColor|shadowColor') then begin
        if (C='root') and (K='color') then begin
          if not (W is TJSONArray) then Bad(Q,'array de cores');
          A:=TJSONArray(W); if A.Count=0 then Bad(Q,'paleta nao vazia');
          for I:=0 to A.Count-1 do Fill(A.Items[I],Format('%s[%d]',[Q,I]),False);
        end else Fill(W,Q,(K='color') and (C='style'));
      end
      else if K='fontWeight' then begin
        if W is TJSONNumber then begin N:=Number(W,Q); if (Frac(N)<>0) or (N<1) or (N>1000) then Bad(Q,'peso inteiro 1..1000'); end
        else if not ((W is TJSONString) and InList(W.Value,'normal|bold')) then Bad(Q,'normal, bold ou peso numerico');
      end
      else if K='smooth' then begin if W is TJSONBool then BooleanValue(W,Q) else Numeric(W,Q,K); end
      else if (K='interval') and (C='label') then begin
        if (W is TJSONString) and (W.Value='auto') then Continue;
        N:=Number(W,Q); if (N<0) or (Frac(N)<>0) then Bad(Q,'auto ou inteiro nao negativo');
      end
      else if InList(K,'radius|center') then begin
        if W is TJSONArray then begin
          A:=TJSONArray(W); if A.Count<>2 then Bad(Q,'par de medidas');
          for I:=0 to 1 do MeasureAt(A.Items[I],Format('%s[%d]',[Q,I]),K,C);
        end else if K='radius' then MeasureAt(W,Q,K,C) else Bad(Q,'par de medidas');
      end
      else if K='selected' then begin
        if not (W is TJSONObject) then Bad(Q,'mapa nome/boolean');
        for Sub in TJSONObject(W) do BooleanValue(Sub.JsonValue,Q+'.'+Sub.JsonString.Value);
      end
      else if C='encode' then begin
        if W is TJSONArray then begin
          A:=TJSONArray(W); if A.Count<>1 then Bad(Q,'uma dimensao por encode neste perfil'); W:=A.Items[0];
        end;
        if W is TJSONNumber then begin N:=Number(W,Q); if (N<0) or (Frac(N)<>0) then Bad(Q,'indice inteiro nao negativo'); end
        else if not ((W is TJSONString) and (W.Value<>'')) then Bad(Q,'nome ou indice de dimensao');
      end
      else if InList(K,'data|source|dimensions') then begin
        if not (W is TJSONArray) then Bad(Q,'array'); A:=TJSONArray(W);
        if (K='data') and (C='series') then for I:=0 to A.Count-1 do
          if A.Items[I] is TJSONObject then Walk(A.Items[I],Format('%s[%d]',[Q,I]),'datum');
        if K='dimensions' then for I:=0 to A.Count-1 do begin
          if A.Items[I] is TJSONObject then begin
            Keys(A.Items[I],Format('%s[%d]',[Q,I]),'name|type');
            if J(A.Items[I],'type')<>nil then Choice(J(A.Items[I],'type'),Format('%s[%d].type',[Q,I]),'ordinal|float|int|number|time',0);
            if not (J(A.Items[I],'name') is TJSONString) then Bad(Q,'nome de dimensao');
          end else if not (A.Items[I] is TJSONString) then Bad(Q,'nomes de dimensoes');
        end;
      end
      else if (C='datum') and (K='value') then Continue
      else if InList(K,'id|name|text|subtext|fontFamily|formatter|stack') then begin
        if not (W is TJSONString) then Bad(Q,'texto');
      end
      else if InList(K,'show|inverse|boundaryGap|scale|onZero|confine|connectNulls|showSymbol|clockwise|stillShowZeroSum|showEmptyCircle|avoidLabelOverlap|hideOverlap|useUTC') then begin
        if (K='confine') and not BooleanValue(W,Q) then Bad(Q,'true no perfil nativo');
        BooleanValue(W,Q);
      end else Numeric(W,Q,K);
    end;
    if (C='axis') and (J(V,'min') is TJSONNumber) and (J(V,'max') is TJSONNumber) then
      if Number(J(V,'min'),P+'.min')>=Number(J(V,'max'),P+'.max') then Bad(P+'.max','max maior que min');
  end;
begin
  if SeriesOnly then Walk(O,'series','series') else Walk(O,'option','root');
end;

end.
