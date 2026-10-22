from pathlib import Path
R=Path(__file__).resolve().parents[2]
def write(p,t): (R/p).write_bytes(t.replace('\r\n','\n').replace('\n','\r\n').encode('cp1252'))
# Literal tables are the only enum <-> JSON translation boundary.
enums={
'Orientation':('dco','horizontal|vertical'),
'LegendType':('dcl','plain|scroll'),
'SeriesType':('dcs','bar|line|pie'),
'AxisType':('dca','category|value|time'),
'LabelPosition':('dcp','top|bottom|left|right|inside|insideTop|insideBottom|outside'),
'TooltipTrigger':('dct','item|axis|none'),
'OuterBoundsMode':('dcb','none'),
'SeriesLayout':('dcsl','column|row'),
'Step':('dcst','false|start|middle|end'),
'Monotone':('dcm','none|x|y'),
'Symbol':('dcsy','none|circle|emptyCircle|rect|roundRect|triangle|diamond'),
'Selection':('dcse','false|single|multiple'),
'Easing':('dce','linear|cubicIn|cubicOut|cubicInOut'),
'LineType':('dcli','solid|dashed|dotted'),
'PointerType':('dcpt','none|line|shadow'),
'Focus':('dcf','none|series'),
'FontStyle':('dcfs','normal|italic'),
'TextAlign':('dcta','left|center|right'),
'VerticalAlign':('dcva','top|middle|bottom'),
'Overflow':('dcov','truncate'),
'RenderMode':('dcrm','richText'),
'StackStrategy':('dcss','samesign'),
'Switch':('dcsw','auto|false|true'),
}
head='''unit DAC.Components.Charts.Types;

interface

uses System.Classes, System.SysUtils, System.JSON, System.UITypes;

type
  EDACChartOptionError = class(Exception);
'''
for n,(prefix,tokens) in enums.items():
 head+=f'  TDACChart{n} = ({prefix}Default, '+', '.join(prefix+t[0].upper()+t[1:] for t in tokens.split('|'))+');\n'
head+='''  TDACChartTooltipEvent = (dcteMouseMove, dcteClick);
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
'''
for n,(prefix,tokens) in enums.items():
 head+=f'    class function {n}(V: TJSONValue; const Path: string; Default: TDACChart{n} = {prefix}Default): TDACChart{n}; static;\n'
 head+=f'    class function {n}JSON(V: TDACChart{n}): TJSONValue; static;\n'
head+='''    class function TooltipEvents(V: TJSONValue; const Path: string;
      Default: TDACChartTooltipEvents = [dcteMouseMove,dcteClick]): TDACChartTooltipEvents; static;
    class function TooltipEventsJSON(V: TDACChartTooltipEvents): TJSONValue; static;
    class function Number(V: TJSONValue; const Path: string): Double; static;
    class function BooleanValue(V: TJSONValue; const Path: string): Boolean; static;
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
'''
for n,(prefix,tokens) in enums.items():
 head+=f'''class function TDACChartTypes.{n}(V: TJSONValue; const Path: string; Default: TDACChart{n}): TDACChart{n};
begin Result:=TDACChart{n}(Choice(V,Path,'{tokens}',Ord(Default))); end;
class function TDACChartTypes.{n}JSON(V: TDACChart{n}): TJSONValue;
begin Result:=ChoiceJSON(Ord(V),'{tokens}'); end;
'''
head+='''class function TDACChartTypes.TooltipEvents(V: TJSONValue; const Path: string;
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
var V: TJSONValue;
begin
  V:=ReadValue; if V=nil then Exit(dcfkDefault); if V is TJSONString then Exit(dcfkSolid);
  if J(V,'type').Value='radial' then Result:=dcfkRadial else Result:=dcfkLinear;
end;
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
begin O:=Gradient; Put(O,Keys[Index],TJSONNumber.Create(V)); WriteValue(O); end;
'''
write('Source/Core/DAC.Components.Charts.Types.pas',head+'\n{VALIDATOR}\nend.\n')
