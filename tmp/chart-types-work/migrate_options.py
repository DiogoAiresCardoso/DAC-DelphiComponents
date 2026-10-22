exec((__import__('pathlib').Path(__file__).parent/'create_types.py').read_text().split("head='''")[0])
import re
p='Source/Controls/DAC.Components.Charts.Options.pas'
t=(R/'tmp/chart-types-work'/Path(p).name).read_text(encoding='cp1252')
t=t.replace('System.Generics.Collections;', 'System.Generics.Collections, DAC.Components.Charts.Types;')
t=t.replace('EDACChartOptionError = class(Exception);','EDACChartOptionError = DAC.Components.Charts.Types.EDACChartOptionError;')
t=t.replace('TDACChartOptionStore = class\n','TDACChartOptionStore = class(TDACChartValueAccess)\n')
t=t.replace('    FRoot: TJSONObject;', '    FRoot: TJSONObject;\n    FSeriesOnly: Boolean;')
t=t.replace('    constructor Create;\n    destructor Destroy; override;\n    function Read', '    constructor Create(SeriesOnly: Boolean = False);\n    destructor Destroy; override;\n    function Read',1)
t=t.replace('function Read(const APath: string): TJSONValue;', 'function Read(const APath: string): TJSONValue; override;')
t=t.replace('procedure Write(const APath: string; AValue: TJSONValue);', 'procedure Write(const APath: string; AValue: TJSONValue); override;')
t=t.replace('    FPath: string;','    FPath: string;\n    FValues: TObjectDictionary<string,TDACChartBoundValue>;\n    function Bound(const Key: string; ValueClass: TDACChartBoundValueClass): TDACChartBoundValue;')
t=t.replace('    constructor Create(AStore: TDACChartOptionStore; const APath: string);','    constructor Create(AStore: TDACChartOptionStore; const APath: string);\n    destructor Destroy; override;')
start=t.index('procedure ValidateChartOptions(O: TJSONObject);',t.index('implementation'))
end=t.index('constructor TDACChartOptionStore.Create;',start)
t=t[:start]+'''procedure ValidateChartOptions(O: TJSONObject);
begin TDACChartTypes.Validate(O); end;
'''+t[end:]
t=t.replace('constructor TDACChartOptionStore.Create;\nbegin inherited; FRoot := TJSONObject.Create; end;', 'constructor TDACChartOptionStore.Create(SeriesOnly: Boolean);\nbegin inherited Create; FSeriesOnly:=SeriesOnly; FRoot := TJSONObject.Create; end;')
start=t.index('procedure TDACChartOptionStore.Write(')
end=t.index('procedure TDACChartOptionStore.Load(',start)
t=t[:start]+'''procedure TDACChartOptionStore.Write(const APath: string; AValue: TJSONValue);
var Parts: TArray<string>; I: Integer; Candidate,O,N,Old: TJSONObject;
begin
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
'''+t[end:]
t=t.replace('  O.AddPair(K,V);','  if V<>nil then O.AddPair(K,V);')
t=t.replace('begin inherited Create; FStore := AStore; FPath := APath; end;', '''begin
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
end;''')
t=t.replace('inherited; FStore := TDACChartOptionStore.Create;\n  FItemStyle', 'inherited; FStore := TDACChartOptionStore.Create(True);\n  FItemStyle')
# Replace existing string APIs, declarations and bodies together.
enumprops={'TextOptions':{'Position':('LabelPosition','position')},
 'AxisOptions':{'AxisType':('AxisType','type')},
 'LegendOptions':{'Orient':('Orientation','orient'),'LegendType':('LegendType','type')},
 'TooltipOptions':{'Trigger':('TooltipTrigger','trigger'),'TriggerOn':('TooltipEvents','triggerOn')},
 'GridOptions':{'OuterBoundsMode':('OuterBoundsMode','outerBoundsMode')},
 'OptionSeries':{'Kind':('SeriesType','type')}}
structured={'TextOptions':{'Left':('Measure','left'),'Top':('Measure','top'),'Color':('Fill','color')},
 'AxisOptions':{'Min':('AxisLimit','min'),'Max':('AxisLimit','max')},
 'LegendOptions':{'Left':('Measure','left'),'Top':('Measure','top')},
 'GridOptions':{n:('Measure',n.lower()) for n in ('Left','Right','Top','Bottom')},
 'TooltipOptions':{n:('Fill',n[0].lower()+n[1:]) for n in ('BackgroundColor','BorderColor')},
 'StyleOptions':{n:('Fill',n[0].lower()+n[1:]) for n in ('Color','BorderColor','ShadowColor')}}
for groups,is_struct in [(enumprops,False),(structured,True)]:
 for short,props in groups.items():
  cls='TDACChart'+short
  cm=re.search(r'  '+cls+r' = class\([^)]*\).*?\n  end;',t,re.S); block=cm.group()
  for name,(kind,key) in props.items():
   typ='TDACChart'+kind
   block=re.sub(r'(Get'+name+r': )string;',r'\g<1>'+typ+';',block)
   block=re.sub(r'(Set'+name+r'\(const (?:AValue|V): )string',r'\g<1>'+typ,block)
   block=re.sub(r'(property '+name+r': )string',r'\g<1>'+typ,block)
   path="'"+key+"'" if short=='OptionSeries' else "Path('"+key+"')"
   impl=re.search(r'function '+cls+r'\.Get'+name+r': string;.*?(?=\n(?:function|procedure|constructor|destructor) )',t,re.S)
   body=f"{typ}(Bound('{key}',{typ}))" if is_struct else f"TDACChartTypes.{kind}(FStore.Read({path}),{path})"
   replacement=f'function {cls}.Get{name}: {typ};\nbegin Result := {body}; end;'
   t=t[:impl.start()]+replacement+t[impl.end():]
   impl=re.search(r'procedure '+cls+r'\.Set'+name+r'\(const (AValue|V): string\);.*?(?=\n(?:function|procedure|constructor|destructor) )',t,re.S)
   arg=impl.group(1)
   body=f'Get{name}.Assign({arg})' if is_struct else f'FStore.Write({path},TDACChartTypes.{kind}JSON({arg}))'
   replacement=f'procedure {cls}.Set{name}(const {arg}: {typ});\nbegin {body}; end;'
   t=t[:impl.start()]+replacement+t[impl.end():]
  # Class declaration offsets changed when method bodies were changed: locate again.
  t=re.sub(r'  '+cls+r' = class\([^)]*\).*?\n  end;',lambda _:block,t,count=1,flags=re.S)
t=t.replace("if Result = '' then Result := GetKind", "if Result = '' then Result := GetJSON")
# Additional strongly typed properties for formerly JSON-only settings.
extra={'StyleOptions':{'LineType':('LineType','type')},
'LegendOptions':{'SelectedMode':('Selection','selectedMode')},
'TooltipOptions':{'RenderMode':('RenderMode','renderMode'),'PointerType':('PointerType','axisPointer.type')},
'LabelOptions':{'FontStyle':('FontStyle','fontStyle'),'TextAlign':('TextAlign','align'),'VerticalAlign':('VerticalAlign','verticalAlign'),'Overflow':('Overflow','overflow')},
'OptionSeries':{'LayoutBy':('SeriesLayout','seriesLayoutBy'),'Step':('Step','step'),'SmoothMonotone':('Monotone','smoothMonotone'),'Symbol':('Symbol','symbol'),'SelectedMode':('Selection','selectedMode'),'StackStrategy':('StackStrategy','stackStrategy'),'Focus':('Focus','emphasis.focus')},
'Options':{'AnimationMode':('Switch','animation'),'AnimationEasing':('Easing','animationEasing'),'AnimationEasingUpdate':('Easing','animationEasingUpdate')}}
for short,props in extra.items():
 cls='TDACChart'+short
 cm=re.search(r'  '+cls+r' = class\([^)]*\).*?\n  end;',t,re.S); block=cm.group(); decl='\n  private\n'; published=''
 for name,(kind,key) in props.items():
  typ='TDACChart'+kind
  decl+=f'    function Get{name}: {typ};\n    procedure Set{name}(V: {typ});\n'
  published+=f'    property {name}: {typ} read Get{name} write Set{name} stored False;\n'
  path="'"+key+"'" if short in ('OptionSeries','Options') else "Path('"+key+"')"
  methods=f'''function {cls}.Get{name}: {typ};
begin Result:=TDACChartTypes.{kind}(FStore.Read({path}),{path}); end;
procedure {cls}.Set{name}(V: {typ});
begin FStore.Write({path},TDACChartTypes.{kind}JSON(V)); end;
'''
  t=t[:-5]+methods+'end.\n'
 block=block.replace('\n  published\n',decl+'  published\n'+published,1)
 t=re.sub(r'  '+cls+r' = class\([^)]*\).*?\n  end;',lambda _:block,t,count=1,flags=re.S)
write(p,t)
# Value class constructor is inherited, no separate ownership of stores.
p='Source/Core/DAC.Components.Charts.Types.pas'; v=(R/p).read_text(encoding='cp1252')
v=v.replace('  TDACChartMeasure = class(TDACChartBoundValue)','  TDACChartBoundValueClass = class of TDACChartBoundValue;\n  TDACChartMeasure = class(TDACChartBoundValue)')
write(p,v)
