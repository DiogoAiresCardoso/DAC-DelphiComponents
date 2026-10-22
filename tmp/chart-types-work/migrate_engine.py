from pathlib import Path
import re
R=Path(__file__).resolve().parents[2]
def write(p,t): (R/p).write_bytes(t.replace('\r\n','\n').replace('\n','\r\n').encode('cp1252'))
p='Source/Core/DAC.Components.Charts.Types.pas'; t=(R/p).read_text(encoding='cp1252')
t=t.replace('System.UITypes;', 'System.UITypes, System.Generics.Collections;')
t=t.replace('  TDACChartTooltipEvent =', '  TDACChartMarkKind = (dcmkNone, dcmkBar, dcmkLine, dcmkPie, dcmkLegend, dcmkPrevious, dcmkNext);\n  TDACChartTooltipEvent =')
t=t.replace('K,Q,S: string;', 'K,Q: string;')
t=t.replace("'name');\n            if not (J(A.Items[I],'name')", "'name|type');\n            if J(A.Items[I],'type')<>nil then Choice(J(A.Items[I],'type'),Format('%s[%d].type',[Q,I]),'ordinal|float|int|number|time',0);\n            if not (J(A.Items[I],'name')")
write(p,t)
p='Source/Skia/DAC.Components.Charts.Engine.pas'; t=(R/p).read_text(encoding='cp1252')
t=t.replace('DAC.Components.Charts.Options,', 'DAC.Components.Charts.Options, DAC.Components.Charts.Types,')
t=t.replace('Name,Kind,Stack: string;', 'Name,Stack: string;\n    Kind: TDACChartSeriesType;')
t=t.replace('Kind,Name: string;', 'Name: string;\n    Kind: TDACChartMarkKind;')
t=t.replace("FSeries[S].Kind:=CS(CJ(Item,'type'),'bar')", "FSeries[S].Kind:=TDACChartTypes.SeriesType(CJ(Item,'type'),'series.type',dcsBar)")
mark={'bar':'dcmkBar','line':'dcmkLine','pie':'dcmkPie','legend':'dcmkLegend','legend-prev':'dcmkPrevious','legend-next':'dcmkNext'}
def kind(m):
 obj,op,val=m.groups(); e='dcs'+val.title() if obj.startswith('FSeries') or obj=='S.Kind' else mark[val]
 return obj+op+e
t=re.sub(r"((?:FSeries\[[^\]\n]+\]|FMarks\[[^\]\n]+\]|S|M|N)\.Kind)\s*(:=|=|<>)\s*'(bar|line|pie|legend|legend-prev|legend-next)'",kind,t)
t=t.replace('M.Kind:=S.Kind;', 'if S.Kind=dcsBar then M.Kind:=dcmkBar else M.Kind:=dcmkLine;')
t=t.replace("J.AddPair('kind',M.Kind);", "J.AddPair('kind',MarkNames[M.Kind]);")
t=t.replace('function TDACChartEngine.GeometryJSON: string;', "function TDACChartEngine.GeometryJSON: string;\nconst MarkNames: array[TDACChartMarkKind] of string=('none','bar','line','pie','legend','legend-prev','legend-next');")
# Use the same strict color parser in validation, public properties and renderer.
start=t.index('function TDACChartEngine.Color('); end=t.index('function TDACChartEngine.Palette(',start)
t=t[:start]+'''function TDACChartEngine.Color(V: TJSONValue; Default: TAlphaColor): TAlphaColor;
begin
  if (V=nil) or (V is TJSONObject) then Exit(Default);
  Result:=TDACChartTypes.Color(V,'color');
end;
'''+t[end:]
start=t.index('function TDACChartEngine.LengthValue(');end=t.index('function TDACChartEngine.Color(',start)
t=t[:start]+'''function TDACChartEngine.LengthValue(V: TJSONValue; Total,Default: Double): Double;
var N: Double; M: TDACChartMeasureMode;
begin
  M:=TDACChartTypes.Measure(V,'measure',N);
  case M of
    dcmmPixels: Result:=N*FScale;
    dcmmPercent: Result:=N*Total/100;
  else Result:=Default*FScale; end;
end;
'''+t[end:]
replacements={
"CS(CJ(CJ(FOptions,'xAxis'),'type'),'value')='category'":"TDACChartTypes.AxisType(CJ(CJ(FOptions,'xAxis'),'type'),'xAxis.type',dcaValue)=dcaCategory",
"CS(CJ(CJ(FOptions,'yAxis'),'type'),'value')='category'":"TDACChartTypes.AxisType(CJ(CJ(FOptions,'yAxis'),'type'),'yAxis.type',dcaValue)=dcaCategory",
"CS(CJ(Item,'seriesLayoutBy'),'column')='row'":"TDACChartTypes.SeriesLayout(CJ(Item,'seriesLayoutBy'),'seriesLayoutBy',dcslColumn)=dcslRow",
"HasHeader:=CB(CJ(D,'sourceHeader'),(Dims=nil) and (Arr(Arr(Source,0),0) is TJSONString));":"HasHeader:=(Dims=nil) and (Arr(Arr(Source,0),0) is TJSONString);\n  if TDACChartTypes.Switch(CJ(D,'sourceHeader'),'dataset.sourceHeader')=dcswTrue then HasHeader:=True\n  else if TDACChartTypes.Switch(CJ(D,'sourceHeader'),'dataset.sourceHeader')=dcswFalse then HasHeader:=False;",
"CS(CJ(Axis,'type'))='time'":"TDACChartTypes.AxisType(CJ(Axis,'type'),'axis.type')=dcaTime",
"CS(CJ(V,'orient'),'horizontal')='vertical'":"TDACChartTypes.Orientation(CJ(V,'orient'),'legend.orient',dcoHorizontal)=dcoVertical",
"CS(CJ(V,'type'),'plain')='scroll'":"TDACChartTypes.LegendType(CJ(V,'type'),'legend.type',dclPlain)=dclScroll",
"CS(CJ(V,'trigger'))='axis'":"TDACChartTypes.TooltipTrigger(CJ(V,'trigger'),'tooltip.trigger',dctItem)=dctAxis",
"CS(CJ(V,'trigger'),'item')='axis'":"TDACChartTypes.TooltipTrigger(CJ(V,'trigger'),'tooltip.trigger',dctItem)=dctAxis",
"CS(CJ(V,'trigger'))='none'":"TDACChartTypes.TooltipTrigger(CJ(V,'trigger'),'tooltip.trigger',dctItem)=dctNone",
"CS(CJ(PointerOptions,'type'),'line')='shadow'":"TDACChartTypes.PointerType(CJ(PointerOptions,'type'),'tooltip.axisPointer.type',dcptLine)=dcptShadow",
"CS(CJ(PointerOptions,'type'),'line')='line'":"TDACChartTypes.PointerType(CJ(PointerOptions,'type'),'tooltip.axisPointer.type',dcptLine)=dcptLine",
"CS(CJ(V,'type'))='dotted'":"TDACChartTypes.LineType(CJ(V,'type'),'style.type',dcliSolid)=dcliDotted",
"CS(CJ(V,'type'))='dashed'":"TDACChartTypes.LineType(CJ(V,'type'),'style.type',dcliSolid)=dcliDashed",
"CS(CJ(Style,'fontStyle'))='italic'":"TDACChartTypes.FontStyle(CJ(Style,'fontStyle'),'fontStyle',dcfsNormal)=dcfsItalic",
"CS(CJ(CJ(FSeries[FHoveredSeries].Options,'emphasis'),'focus'))='series'":"TDACChartTypes.Focus(CJ(CJ(FSeries[FHoveredSeries].Options,'emphasis'),'focus'),'emphasis.focus')=dcfSeries",
}
for old,new in replacements.items():
 if old not in t: print('not found',old)
 t=t.replace(old,new)
t=t.replace('Easing: string;', 'Easing: TDACChartEasing;')
t=t.replace("CS(CJ(FOptions,'animationEasingUpdate'),'cubicInOut')", "TDACChartTypes.Easing(CJ(FOptions,'animationEasingUpdate'),'animationEasingUpdate',dceCubicInOut)")
t=t.replace("CS(CJ(FOptions,'animationEasing'),'cubicInOut')", "TDACChartTypes.Easing(CJ(FOptions,'animationEasing'),'animationEasing',dceCubicInOut)")
for v in ['linear','cubicIn','cubicOut','cubicInOut']:
 t=t.replace("Easing:='"+v+"'",'Easing:=dce'+v[0].upper()+v[1:]).replace("Easing='"+v+"'",'Easing=dce'+v[0].upper()+v[1:])
t=t.replace('const Step,Monotone: string;', 'Step: TDACChartStep; Monotone: TDACChartMonotone;')
t=t.replace("Step<>''", 'not (Step in [dcstDefault,dcstFalse])').replace("Step='middle'",'Step=dcstMiddle').replace("Step='start'",'Step=dcstStart')
t=t.replace("Monotone='x'",'Monotone=dcmX').replace("Monotone='y'",'Monotone=dcmY')
t=t.replace('Rev: TArray<TPointF>; Step: string;', 'Rev: TArray<TPointF>; Step: TDACChartStep;')
t=t.replace("CS(CJ(S.Options,'smoothMonotone'))", "TDACChartTypes.Monotone(CJ(S.Options,'smoothMonotone'),'smoothMonotone')")
t=t.replace("ChartPolyline(Area,Rev,0,Step,'',False)", 'ChartPolyline(Area,Rev,0,Step,dcmNone,False)')
t=t.replace("Step:=CS(CJ(S.Options,'step')); if Step='false' then Step:=''; if Step='true' then Step:='end';", "Step:=TDACChartTypes.Step(CJ(S.Options,'step'),'series.step');")
t=t.replace('S,Position,Align: string;', 'S,Align: string; Position: TDACChartLabelPosition;')
t=t.replace("CS(CJ(V,'position'),'inside')", "TDACChartTypes.LabelPosition(CJ(V,'position'),'label.position',dcpInside)")
t=t.replace("CS(CJ(V,'position'),'top')", "TDACChartTypes.LabelPosition(CJ(V,'position'),'label.position',dcpTop)")
for v in ['inside','bottom','left','right','insideTop','insideBottom']:
 t=t.replace("Position='"+v+"'",'Position=dcp'+v[0].upper()+v[1:])
t=t.replace("Position.StartsWith('inside')",'(Position in [dcpInside,dcpInsideTop,dcpInsideBottom])')
t=t.replace('K,Mode: string;', 'K: string; Mode: TDACChartSelection;')
t=t.replace("CS(CJ(CJ(FOptions,'legend'),'selectedMode'),'true')", "TDACChartTypes.Selection(CJ(CJ(FOptions,'legend'),'selectedMode'),'legend.selectedMode',dcseMultiple)")
t=t.replace("CS(CJ(FSeries[M.SeriesIndex].Options,'selectedMode'),'false')", "TDACChartTypes.Selection(CJ(FSeries[M.SeriesIndex].Options,'selectedMode'),'series.selectedMode',dcseFalse)")
t=t.replace("Mode='false'",'Mode=dcseFalse').replace("Mode='single'",'Mode=dcseSingle')
# Symbols are validated and decoded centrally.
for v in ['none','emptyCircle','rect','roundRect','triangle','diamond']:
 for op in ['=','<>']:
  for default in ["",",'emptyCircle'"]:
   t=t.replace("CS(CJ(S.Options,'symbol')"+default+")"+op+"'"+v+"'", "TDACChartTypes.Symbol(CJ(S.Options,'symbol'),'symbol',dcsyEmptyCircle)"+op+'dcsy'+v[0].upper()+v[1:])
write(p,t)
p='Source/Controls/DAC.Components.Controls.Charts.pas';t=(R/p).read_text(encoding='cp1252')
t=t.replace('DAC.Components.Charts.Options,', 'DAC.Components.Charts.Options, DAC.Components.Charts.Types,')
t=t.replace('Trigger: string;', 'Trigger: TDACChartTooltipEvents;')
t=t.replace("CS(CJ(CJ(FEngine.Options,'tooltip'),'triggerOn'),'mousemove|click')", "TDACChartTypes.TooltipEvents(CJ(CJ(FEngine.Options,'tooltip'),'triggerOn'),'tooltip.triggerOn')")
t=t.replace("Pos('mousemove',Trigger)=0", 'not (dcteMouseMove in Trigger)').replace("Pos('mousemove',Trigger)>0", 'dcteMouseMove in Trigger')
t=t.replace("Pos('click',TDACChartTypes.TooltipEvents(CJ(CJ(FEngine.Options,'tooltip'),'triggerOn'),'tooltip.triggerOn'))>0", "dcteClick in TDACChartTypes.TooltipEvents(CJ(CJ(FEngine.Options,'tooltip'),'triggerOn'),'tooltip.triggerOn')")
t=t.replace("((V=nil) or CB(V,True) or (CS(V)='auto'))", "(TDACChartTypes.Switch(V,'animation') in [dcswDefault,dcswAuto,dcswTrue])")
write(p,t)
