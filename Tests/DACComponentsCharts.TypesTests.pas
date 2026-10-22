unit DACComponentsCharts.TypesTests;

interface

procedure TestChartTypes;

implementation

uses System.SysUtils, System.Classes, System.JSON, System.TypInfo,
  System.Math, DAC.Components.Charts.Types, DAC.Components.Charts.Options,
  DAC.Components.Controls.Charts;

procedure Check(B: Boolean; const Message: string);
begin if not B then raise Exception.Create('Chart types: '+Message); end;

procedure Reject(O: TDACChartOptions; const JSON,Path: string);
var Before: string; Failed: Boolean;
begin
  Before:=O.JSON; Failed:=False;
  try O.JSON:=JSON;
  except on E: EDACChartOptionError do begin
    Failed:=True; Check(Pos(Path,E.Message)>0,'missing error path '+Path+': '+E.Message);
  end; end;
  Check(Failed,'invalid configuration accepted: '+JSON);
  Check(O.JSON=Before,'failed import modified configuration');
end;

procedure TestEnumCodecs;
var I: Integer; V: TJSONValue; Failed: Boolean;
begin
  for I:=Ord(Low(TDACChartOrientation)) to Ord(High(TDACChartOrientation)) do begin
    V:=TDACChartTypes.OrientationJSON(TDACChartOrientation(I));
    try Check(Ord(TDACChartTypes.Orientation(V,'Orientation'))=I,'Orientation codec roundtrip'); finally V.Free; end;
  end;
  V:=TJSONString.Create('invalid_value'); Failed:=False;
  try
    try TDACChartTypes.Orientation(V,'Orientation'); except on E: EDACChartOptionError do Failed:=True; end;
  finally V.Free; end;
  Check(Failed,'Orientation accepted unknown literal');
  for I:=Ord(Low(TDACChartLegendType)) to Ord(High(TDACChartLegendType)) do begin
    V:=TDACChartTypes.LegendTypeJSON(TDACChartLegendType(I));
    try Check(Ord(TDACChartTypes.LegendType(V,'LegendType'))=I,'LegendType codec roundtrip'); finally V.Free; end;
  end;
  V:=TJSONString.Create('invalid_value'); Failed:=False;
  try
    try TDACChartTypes.LegendType(V,'LegendType'); except on E: EDACChartOptionError do Failed:=True; end;
  finally V.Free; end;
  Check(Failed,'LegendType accepted unknown literal');
  for I:=Ord(Low(TDACChartSeriesType)) to Ord(High(TDACChartSeriesType)) do begin
    V:=TDACChartTypes.SeriesTypeJSON(TDACChartSeriesType(I));
    try Check(Ord(TDACChartTypes.SeriesType(V,'SeriesType'))=I,'SeriesType codec roundtrip'); finally V.Free; end;
  end;
  V:=TJSONString.Create('invalid_value'); Failed:=False;
  try
    try TDACChartTypes.SeriesType(V,'SeriesType'); except on E: EDACChartOptionError do Failed:=True; end;
  finally V.Free; end;
  Check(Failed,'SeriesType accepted unknown literal');
  for I:=Ord(Low(TDACChartAxisType)) to Ord(High(TDACChartAxisType)) do begin
    V:=TDACChartTypes.AxisTypeJSON(TDACChartAxisType(I));
    try Check(Ord(TDACChartTypes.AxisType(V,'AxisType'))=I,'AxisType codec roundtrip'); finally V.Free; end;
  end;
  V:=TJSONString.Create('invalid_value'); Failed:=False;
  try
    try TDACChartTypes.AxisType(V,'AxisType'); except on E: EDACChartOptionError do Failed:=True; end;
  finally V.Free; end;
  Check(Failed,'AxisType accepted unknown literal');
  for I:=Ord(Low(TDACChartLabelPosition)) to Ord(High(TDACChartLabelPosition)) do begin
    V:=TDACChartTypes.LabelPositionJSON(TDACChartLabelPosition(I));
    try Check(Ord(TDACChartTypes.LabelPosition(V,'LabelPosition'))=I,'LabelPosition codec roundtrip'); finally V.Free; end;
  end;
  V:=TJSONString.Create('invalid_value'); Failed:=False;
  try
    try TDACChartTypes.LabelPosition(V,'LabelPosition'); except on E: EDACChartOptionError do Failed:=True; end;
  finally V.Free; end;
  Check(Failed,'LabelPosition accepted unknown literal');
  for I:=Ord(Low(TDACChartTooltipTrigger)) to Ord(High(TDACChartTooltipTrigger)) do begin
    V:=TDACChartTypes.TooltipTriggerJSON(TDACChartTooltipTrigger(I));
    try Check(Ord(TDACChartTypes.TooltipTrigger(V,'TooltipTrigger'))=I,'TooltipTrigger codec roundtrip'); finally V.Free; end;
  end;
  V:=TJSONString.Create('invalid_value'); Failed:=False;
  try
    try TDACChartTypes.TooltipTrigger(V,'TooltipTrigger'); except on E: EDACChartOptionError do Failed:=True; end;
  finally V.Free; end;
  Check(Failed,'TooltipTrigger accepted unknown literal');
  for I:=Ord(Low(TDACChartOuterBoundsMode)) to Ord(High(TDACChartOuterBoundsMode)) do begin
    V:=TDACChartTypes.OuterBoundsModeJSON(TDACChartOuterBoundsMode(I));
    try Check(Ord(TDACChartTypes.OuterBoundsMode(V,'OuterBoundsMode'))=I,'OuterBoundsMode codec roundtrip'); finally V.Free; end;
  end;
  V:=TJSONString.Create('invalid_value'); Failed:=False;
  try
    try TDACChartTypes.OuterBoundsMode(V,'OuterBoundsMode'); except on E: EDACChartOptionError do Failed:=True; end;
  finally V.Free; end;
  Check(Failed,'OuterBoundsMode accepted unknown literal');
  for I:=Ord(Low(TDACChartSeriesLayout)) to Ord(High(TDACChartSeriesLayout)) do begin
    V:=TDACChartTypes.SeriesLayoutJSON(TDACChartSeriesLayout(I));
    try Check(Ord(TDACChartTypes.SeriesLayout(V,'SeriesLayout'))=I,'SeriesLayout codec roundtrip'); finally V.Free; end;
  end;
  V:=TJSONString.Create('invalid_value'); Failed:=False;
  try
    try TDACChartTypes.SeriesLayout(V,'SeriesLayout'); except on E: EDACChartOptionError do Failed:=True; end;
  finally V.Free; end;
  Check(Failed,'SeriesLayout accepted unknown literal');
  for I:=Ord(Low(TDACChartStep)) to Ord(High(TDACChartStep)) do begin
    V:=TDACChartTypes.StepJSON(TDACChartStep(I));
    try Check(Ord(TDACChartTypes.Step(V,'series.step'))=I,'Step codec roundtrip'); finally V.Free; end;
  end;
  V:=TJSONString.Create('invalid_value'); Failed:=False;
  try
    try TDACChartTypes.Step(V,'series.step'); except on E: EDACChartOptionError do Failed:=True; end;
  finally V.Free; end;
  Check(Failed,'Step accepted unknown literal');
  for I:=Ord(Low(TDACChartMonotone)) to Ord(High(TDACChartMonotone)) do begin
    V:=TDACChartTypes.MonotoneJSON(TDACChartMonotone(I));
    try Check(Ord(TDACChartTypes.Monotone(V,'Monotone'))=I,'Monotone codec roundtrip'); finally V.Free; end;
  end;
  V:=TJSONString.Create('invalid_value'); Failed:=False;
  try
    try TDACChartTypes.Monotone(V,'Monotone'); except on E: EDACChartOptionError do Failed:=True; end;
  finally V.Free; end;
  Check(Failed,'Monotone accepted unknown literal');
  for I:=Ord(Low(TDACChartSymbol)) to Ord(High(TDACChartSymbol)) do begin
    V:=TDACChartTypes.SymbolJSON(TDACChartSymbol(I));
    try Check(Ord(TDACChartTypes.Symbol(V,'Symbol'))=I,'Symbol codec roundtrip'); finally V.Free; end;
  end;
  V:=TJSONString.Create('invalid_value'); Failed:=False;
  try
    try TDACChartTypes.Symbol(V,'Symbol'); except on E: EDACChartOptionError do Failed:=True; end;
  finally V.Free; end;
  Check(Failed,'Symbol accepted unknown literal');
  for I:=Ord(Low(TDACChartSelection)) to Ord(High(TDACChartSelection)) do begin
    V:=TDACChartTypes.SelectionJSON(TDACChartSelection(I));
    try Check(Ord(TDACChartTypes.Selection(V,'series.selectedMode'))=I,'Selection codec roundtrip'); finally V.Free; end;
  end;
  V:=TJSONString.Create('invalid_value'); Failed:=False;
  try
    try TDACChartTypes.Selection(V,'series.selectedMode'); except on E: EDACChartOptionError do Failed:=True; end;
  finally V.Free; end;
  Check(Failed,'Selection accepted unknown literal');
  for I:=Ord(Low(TDACChartEasing)) to Ord(High(TDACChartEasing)) do begin
    V:=TDACChartTypes.EasingJSON(TDACChartEasing(I));
    try Check(Ord(TDACChartTypes.Easing(V,'Easing'))=I,'Easing codec roundtrip'); finally V.Free; end;
  end;
  V:=TJSONString.Create('invalid_value'); Failed:=False;
  try
    try TDACChartTypes.Easing(V,'Easing'); except on E: EDACChartOptionError do Failed:=True; end;
  finally V.Free; end;
  Check(Failed,'Easing accepted unknown literal');
  for I:=Ord(Low(TDACChartLineType)) to Ord(High(TDACChartLineType)) do begin
    V:=TDACChartTypes.LineTypeJSON(TDACChartLineType(I));
    try Check(Ord(TDACChartTypes.LineType(V,'LineType'))=I,'LineType codec roundtrip'); finally V.Free; end;
  end;
  V:=TJSONString.Create('invalid_value'); Failed:=False;
  try
    try TDACChartTypes.LineType(V,'LineType'); except on E: EDACChartOptionError do Failed:=True; end;
  finally V.Free; end;
  Check(Failed,'LineType accepted unknown literal');
  for I:=Ord(Low(TDACChartPointerType)) to Ord(High(TDACChartPointerType)) do begin
    V:=TDACChartTypes.PointerTypeJSON(TDACChartPointerType(I));
    try Check(Ord(TDACChartTypes.PointerType(V,'PointerType'))=I,'PointerType codec roundtrip'); finally V.Free; end;
  end;
  V:=TJSONString.Create('invalid_value'); Failed:=False;
  try
    try TDACChartTypes.PointerType(V,'PointerType'); except on E: EDACChartOptionError do Failed:=True; end;
  finally V.Free; end;
  Check(Failed,'PointerType accepted unknown literal');
  for I:=Ord(Low(TDACChartFocus)) to Ord(High(TDACChartFocus)) do begin
    V:=TDACChartTypes.FocusJSON(TDACChartFocus(I));
    try Check(Ord(TDACChartTypes.Focus(V,'Focus'))=I,'Focus codec roundtrip'); finally V.Free; end;
  end;
  V:=TJSONString.Create('invalid_value'); Failed:=False;
  try
    try TDACChartTypes.Focus(V,'Focus'); except on E: EDACChartOptionError do Failed:=True; end;
  finally V.Free; end;
  Check(Failed,'Focus accepted unknown literal');
  for I:=Ord(Low(TDACChartFontStyle)) to Ord(High(TDACChartFontStyle)) do begin
    V:=TDACChartTypes.FontStyleJSON(TDACChartFontStyle(I));
    try Check(Ord(TDACChartTypes.FontStyle(V,'FontStyle'))=I,'FontStyle codec roundtrip'); finally V.Free; end;
  end;
  V:=TJSONString.Create('invalid_value'); Failed:=False;
  try
    try TDACChartTypes.FontStyle(V,'FontStyle'); except on E: EDACChartOptionError do Failed:=True; end;
  finally V.Free; end;
  Check(Failed,'FontStyle accepted unknown literal');
  for I:=Ord(Low(TDACChartTextAlign)) to Ord(High(TDACChartTextAlign)) do begin
    V:=TDACChartTypes.TextAlignJSON(TDACChartTextAlign(I));
    try Check(Ord(TDACChartTypes.TextAlign(V,'TextAlign'))=I,'TextAlign codec roundtrip'); finally V.Free; end;
  end;
  V:=TJSONString.Create('invalid_value'); Failed:=False;
  try
    try TDACChartTypes.TextAlign(V,'TextAlign'); except on E: EDACChartOptionError do Failed:=True; end;
  finally V.Free; end;
  Check(Failed,'TextAlign accepted unknown literal');
  for I:=Ord(Low(TDACChartVerticalAlign)) to Ord(High(TDACChartVerticalAlign)) do begin
    V:=TDACChartTypes.VerticalAlignJSON(TDACChartVerticalAlign(I));
    try Check(Ord(TDACChartTypes.VerticalAlign(V,'VerticalAlign'))=I,'VerticalAlign codec roundtrip'); finally V.Free; end;
  end;
  V:=TJSONString.Create('invalid_value'); Failed:=False;
  try
    try TDACChartTypes.VerticalAlign(V,'VerticalAlign'); except on E: EDACChartOptionError do Failed:=True; end;
  finally V.Free; end;
  Check(Failed,'VerticalAlign accepted unknown literal');
  for I:=Ord(Low(TDACChartOverflow)) to Ord(High(TDACChartOverflow)) do begin
    V:=TDACChartTypes.OverflowJSON(TDACChartOverflow(I));
    try Check(Ord(TDACChartTypes.Overflow(V,'Overflow'))=I,'Overflow codec roundtrip'); finally V.Free; end;
  end;
  V:=TJSONString.Create('invalid_value'); Failed:=False;
  try
    try TDACChartTypes.Overflow(V,'Overflow'); except on E: EDACChartOptionError do Failed:=True; end;
  finally V.Free; end;
  Check(Failed,'Overflow accepted unknown literal');
  for I:=Ord(Low(TDACChartRenderMode)) to Ord(High(TDACChartRenderMode)) do begin
    V:=TDACChartTypes.RenderModeJSON(TDACChartRenderMode(I));
    try Check(Ord(TDACChartTypes.RenderMode(V,'RenderMode'))=I,'RenderMode codec roundtrip'); finally V.Free; end;
  end;
  V:=TJSONString.Create('invalid_value'); Failed:=False;
  try
    try TDACChartTypes.RenderMode(V,'RenderMode'); except on E: EDACChartOptionError do Failed:=True; end;
  finally V.Free; end;
  Check(Failed,'RenderMode accepted unknown literal');
  for I:=Ord(Low(TDACChartStackStrategy)) to Ord(High(TDACChartStackStrategy)) do begin
    V:=TDACChartTypes.StackStrategyJSON(TDACChartStackStrategy(I));
    try Check(Ord(TDACChartTypes.StackStrategy(V,'StackStrategy'))=I,'StackStrategy codec roundtrip'); finally V.Free; end;
  end;
  V:=TJSONString.Create('invalid_value'); Failed:=False;
  try
    try TDACChartTypes.StackStrategy(V,'StackStrategy'); except on E: EDACChartOptionError do Failed:=True; end;
  finally V.Free; end;
  Check(Failed,'StackStrategy accepted unknown literal');
  for I:=Ord(Low(TDACChartSwitch)) to Ord(High(TDACChartSwitch)) do begin
    V:=TDACChartTypes.SwitchJSON(TDACChartSwitch(I));
    try Check(Ord(TDACChartTypes.Switch(V,'Switch'))=I,'Switch codec roundtrip'); finally V.Free; end;
  end;
  V:=TJSONString.Create('invalid_value'); Failed:=False;
  try
    try TDACChartTypes.Switch(V,'Switch'); except on E: EDACChartOptionError do Failed:=True; end;
  finally V.Free; end;
  Check(Failed,'Switch accepted unknown literal');
end;

procedure TestChartTypes;
var O,Other: TDACChartOptions; Chart,Restored: TDACChart; V: TJSONValue;
  Before: string; Failed: Boolean; Stream: TMemoryStream; Info: PPropInfo;
  Stops: TDACChartGradientStops; I: Integer;
begin
  TestEnumCodecs;
  O:=TDACChartOptions.Create; Other:=TDACChartOptions.Create;
  try
    Before:=O.JSON;
    Check(O.Legend.Orient=dcoDefault,'absent orientation is not inherited');
    Check(O.Grid.OuterBoundsMode=dcbDefault,'outer bounds getter materialized auto');
    Check(O.Legend.Left.Mode=dcmmDefault,'absent measure lost');
    Check(not O.Title.Color.IsSpecified,'absent color materialized');
    O.Series.Add;
    O.Series[0].AreaStyle.Color.Reset;
    Check(CJ(O.Series[0].Store.Root,'areaStyle')=nil,'reset absent color enabled area');
    O.JSON:=Before;
    Check(O.JSON=Before,'read-only getters changed JSON');
    O.Legend.Orient:=dcoVertical;
    O.Legend.LegendType:=dclScroll;
    O.Legend.SelectedMode:=dcseSingle;
    O.Tooltip.Trigger:=dctAxis;
    O.Tooltip.TriggerOn:=[dcteClick];
    O.Tooltip.PointerType:=dcptShadow;
    O.Tooltip.RenderMode:=dcrmRichText;
    O.Grid.OuterBoundsMode:=dcbNone;
    O.XAxis.AxisType:=dcaCategory;
    O.YAxis.AxisType:=dcaValue;
    O.YAxis.Min.Value:=-10;
    O.YAxis.Max.Value:=100;
    O.Legend.Left.Mode:=dcmmRight;
    O.Legend.Top.SetPercent(25);
    O.Grid.Left.SetPixels(70);
    O.Title.Color.Color:=$FF123456;
    O.Title.FontWeight:=700;
    O.Dataset.SourceHeader:=dcswFalse;
    O.AnimationMode:=dcswFalse;
    O.AnimationEasing:=dceCubicOut;
    O.Series.Add.Kind:=dcsLine;
    O.Series[0].Step:=dcstMiddle;
    O.Series[0].SmoothMonotone:=dcmX;
    O.Series[0].Symbol:=dcsyDiamond;
    O.Series[0].LayoutBy:=dcslColumn;
    O.Series[0].StackStrategy:=dcssSamesign;
    O.Series[0].Focus:=dcfSeries;
    O.Series[0].LabelStyle.Position:=dcpInsideTop;
    O.Series[0].LabelStyle.FontStyle:=dcfsItalic;
    O.Series[0].LineStyle.LineType:=dcliDashed;
    O.Series[0].ItemStyle.Color.Kind:=dcfkLinear;
    SetLength(Stops,3);
    Stops[0].Offset:=0; Stops[0].Color:=$FF102030;
    Stops[1].Offset:=0.5; Stops[1].Color:=$80102030;
    Stops[2].Offset:=1; Stops[2].Color:=$FFABCDEF;
    O.Series[0].ItemStyle.Color.SetStops(Stops);
    Other.Assign(O);
    Check(Other.JSON=O.JSON,'Assign did not preserve typed settings');
    Check(Other.Legend.Orient=dcoVertical,'enum import');
    Check(Other.Tooltip.TriggerOn=[dcteClick],'set import');
    Check(Other.Legend.Top.Value=25,'percent value import');
    Check(Other.Legend.Top.Mode=dcmmPercent,'percent unit import');
    Check(Other.YAxis.Min.Value=-10,'numeric limit import');
    Check(Other.Title.Color.Color=$FF123456,'solid color import');
    Check(Other.Series[0].ItemStyle.Color.GetStops[1].Color=$80102030,'gradient alpha import');
    Other.Legend.Orient:=dcoDefault;
    Check(Other.Legend.Orient=dcoDefault,'reset enum');
    V:=Other.Clone;
    try Check(CJ(CJ(V,'legend'),'orient')=nil,'default serialized as literal'); finally V.Free; end;
    Before:=O.JSON;
    Failed:=False;
    try O.Legend.JSON:='{"orient":"vertcal"}';
    except on E: EDACChartOptionError do begin Failed:=True; Check(Pos('legend.orient',E.Message)>0,'nested path'); end; end;
    Check(Failed and (O.JSON=Before),'subobject import is not transactional');
    Failed:=False;
    try O.Series[0].JSON:='{"type":"line","step":"middl"}';
    except on E: EDACChartOptionError do Failed:=True; end;
    Check(Failed and (O.JSON=Before),'series import is not transactional');
    Failed:=False;
    try O.Series[0].ItemStyle.Opacity:=1.5;
    except on E: EDACChartOptionError do Failed:=True; end;
    Check(Failed and (O.JSON=Before),'numeric setter is not transactional');
    Failed:=False;
    try O.YAxis.Max.Value:=-20;
    except on E: EDACChartOptionError do Failed:=True; end;
    Check(Failed and (O.JSON=Before),'inverted limits accepted');
    Failed:=False;
    try O.Grid.Left.Value:=NaN;
    except on E: EDACChartOptionError do Failed:=True; end;
    Check(Failed and (O.JSON=Before),'nonfinite measure accepted');
    Stops[1].Offset:=2;
    Failed:=False;
    try O.Series[0].ItemStyle.Color.SetStops(Stops);
    except on E: EDACChartOptionError do Failed:=True; end;
    Check(Failed and (O.JSON=Before),'invalid gradient changed configuration');
    Reject(O,'{"legend":{"orient":"vertcal"}}','legend.orient');
    Reject(O,'{"legend":{"type":"scrol"}}','legend.type');
    Reject(O,'{"legend":{"orient":true}}','legend.orient');
    Reject(O,'{"legend":{"show":"false"}}','legend.show');
    Reject(O,'{"legend":{"show":null}}','legend.show');
    Reject(O,'{"legend":{"show":true,"show":false}}','legend.show');
    Reject(O,'{"tooltip":{"triggerOn":"click|garbage"}}','tooltip.triggerOn');
    Reject(O,'{"tooltip":{"triggerOn":"click|click"}}','tooltip.triggerOn');
    Reject(O,'{"tooltip":{"trigger":"axes"}}','tooltip.trigger');
    Reject(O,'{"tooltip":{"confine":false}}','tooltip.confine');
    Reject(O,'{"tooltip":{"renderMode":"html"}}','tooltip.renderMode');
    Reject(O,'{"tooltip":{"axisPointer":{"type":"cross"}}}','axisPointer.type');
    Reject(O,'{"xAxis":{"type":"log"}}','xAxis.type');
    Reject(O,'{"xAxis":{"min":"ten"}}','xAxis.min');
    Reject(O,'{"xAxis":{"min":20,"max":10}}','xAxis.max');
    Reject(O,'{"xAxis":{"splitNumber":0}}','splitNumber');
    Reject(O,'{"grid":{"outerBoundsMode":"auto"}}','outerBoundsMode');
    Reject(O,'{"grid":{"left":"ten%"}}','grid.left');
    Reject(O,'{"grid":{"left":"right"}}','grid.left');
    Reject(O,'{"title":{"left":"bottom"}}','title.left');
    Reject(O,'{"title":{"textStyle":{"fontSize":"18"}}}','fontSize');
    Reject(O,'{"title":{"textStyle":{"fontWeight":"bolder"}}}','fontWeight');
    Reject(O,'{"title":{"textStyle":{"fontStyle":"italik"}}}','fontStyle');
    Reject(O,'{"title":{"textStyle":{"rich":{"a":{"typo":1}}}}}','rich.a.typo');
    Reject(O,'{"backgroundColor":"#xyz"}','backgroundColor');
    Reject(O,'{"backgroundColor":"rgba(0,0,0,2)"}','backgroundColor');
    Reject(O,'{"backgroundColor":"rgb(-1,0,0)"}','backgroundColor');
    Reject(O,'{"color":[]}','color');
    Reject(O,'{"animationEasing":"cubik"}','animationEasing');
    Reject(O,'{"animation":"false"}','animation');
    Reject(O,'{"series":[{"type":"radar"}]}','series[0].type');
    Reject(O,'{"series":[{"type":"bar","symbol":"star"}]}','symbol');
    Reject(O,'{"series":[{"step":"middl"}]}','step');
    Reject(O,'{"series":[{"smooth":2}]}','smooth');
    Reject(O,'{"series":[{"smoothMonotone":"z"}]}','smoothMonotone');
    Reject(O,'{"series":[{"seriesLayoutBy":"columns"}]}','seriesLayoutBy');
    Reject(O,'{"series":[{"selectedMode":"all"}]}','selectedMode');
    Reject(O,'{"series":[{"emphasis":{"focus":"self"}}]}','focus');
    Reject(O,'{"series":[{"itemStyle":{"color":{"type":"linear","colorStops":[]}}}]}','colorStops');
    Reject(O,'{"series":[{"lineStyle":{"type":"dottd"}}]}','lineStyle.type');
    Reject(O,'{"series":[{"label":{"position":"insideLeft"}}]}','position');
    Reject(O,'{"series":[{"label":{"overflow":"break"}}]}','overflow');
    Reject(O,'{"series":[{"encode":{"y":[1,2]}}]}','encode.y');
    Reject(O,'{"series":[{"itemStyle":{"borderRadius":[1,2,3,4]}}]}','borderRadius');
    Reject(O,'{"series":[{"labelLine":{"unknown":true}}]}','labelLine.unknown');
    Info:=GetPropInfo(O.Legend.ClassInfo,'Orient'); Check(Info^.PropType^.Kind=tkEnumeration,'Inspector orientation is not enum');
    Info:=GetPropInfo(O.Tooltip.ClassInfo,'TriggerOn'); Check(Info^.PropType^.Kind=tkSet,'Inspector triggers are not a set');
    Info:=GetPropInfo(O.Legend.ClassInfo,'Left'); Check(Info^.PropType^.Kind=tkClass,'Inspector position is not an object');
    System.Classes.RegisterClass(TDACChart);
    Chart:=TDACChart.Create(nil); Stream:=TMemoryStream.Create;
    try
      Chart.Name:='TypedChart'; Chart.Options.Assign(O);
      Stream.WriteComponent(Chart); Stream.Position:=0;
      Restored:=TDACChart(Stream.ReadComponent(nil));
      try
        Check(Restored.SaveJSON=Chart.SaveJSON,'DFM lost typed configuration');
        Check(Restored.Options.Legend.Orient=dcoVertical,'DFM orientation');
      finally Restored.Free; end;
    finally Stream.Free; Chart.Free; end;
    for I:=0 to 100 do begin
      Other.Assign(O); Other.Legend.Orient:=dcoHorizontal; Other.Legend.Left.SetPixels(I);
      Other.Series[0].ItemStyle.Color.Kind:=dcfkRadial;
      Other.Series[0].ItemStyle.Color.Radius:=0.6;
    end;
    Writeln('Chart types: enums, sets, measures, colors, gradients, validation, rollback and DFM OK');
  finally Other.Free; O.Free; end;
end;

end.
