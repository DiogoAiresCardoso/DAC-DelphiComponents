from pathlib import Path

def read(p):
    return Path(p).read_bytes().decode('cp1252').replace('\r\n', '\n')

def write(p, s):
    Path(p).write_bytes(s.replace('\n', '\r\n').encode('cp1252'))

p = 'Source/Skia/DAC.Components.Charts.Engine.pas'
s = read(p)
s = s.replace('    procedure DrawTitle;', '    function LayoutTitle(Draw: Boolean): Double;')
s = s.replace('    function TextWidth(const S: string; Style: TJSONValue): Double;',
              '    function TextWidth(const S: string; Style: TJSONValue): Double;\n    function TextHeight(const S: string; Style: TJSONValue): Double;')
start = s.index('procedure TDACChartEngine.Text(')
s = s[:start] + '''function TDACChartEngine.TextHeight(const S: string; Style: TJSONValue): Double;
var Old: HGDIOBJ; Size: TSize; Start,P,Q,Sep: Integer; Token: string;
  Rich,Fragment: TJSONValue; Merged: TJSONObject; Pair: TJSONPair;
  Y,LineHeight: Double;
begin
  Result:=0; if S='' then Exit;
  Rich:=CJ(Style,'rich');
  if (Rich is TJSONObject) and (Pos('{',S)>0) then begin
    Start:=1;
    while Start<=Length(S) do begin
      P:=PosEx('{',S,Start); Fragment:=nil;
      if P=Start then begin
        Q:=PosEx('}',S,P+1); Sep:=PosEx('|',S,P+1);
        if (Q>P) and (Sep>P) and (Sep<Q) then begin
          Fragment:=CJ(Rich,Copy(S,P+1,Sep-P-1)); Token:=Copy(S,Sep+1,Q-Sep-1); Start:=Q+1;
        end else begin Token:=Copy(S,Start,1); Inc(Start); end;
      end else begin
        if P=0 then P:=Length(S)+1; Token:=Copy(S,Start,P-Start); Start:=P;
      end;
      Merged:=TJSONObject.Create;
      try
        if Style is TJSONObject then for Pair in TJSONObject(Style) do
          if Pair.JsonString.Value<>'rich' then CSet(Merged,Pair.JsonString.Value,TJSONValue(Pair.JsonValue.Clone));
        if Fragment is TJSONObject then for Pair in TJSONObject(Fragment) do
          CSet(Merged,Pair.JsonString.Value,TJSONValue(Pair.JsonValue.Clone));
        Result:=Max(Result,TextHeight(Token,Merged));
      finally Merged.Free; end;
    end;
    Exit;
  end;
  if Pos(#10,S)>0 then begin
    Start:=1; Y:=0; LineHeight:=CN(CJ(Style,'lineHeight'),CN(CJ(Style,'fontSize'),12)*1.2)*FScale;
    repeat
      P:=PosEx(#10,S,Start); if P=0 then P:=Length(S)+1;
      Result:=Max(Result,Y+TextHeight(TrimRight(Copy(S,Start,P-Start)),Style));
      Start:=P+1; Y:=Y+LineHeight;
    until Start>Length(S);
    Exit;
  end;
  Old:=SelectObject(FSurface.DC,NativeFont(Style));
  try
    GetTextExtentPoint32(FSurface.DC,PChar(S),Length(S),Size);
    Result:=Max(Size.cy,CN(CJ(Style,'lineHeight'),CN(CJ(Style,'fontSize'),12)*1.2)*FScale)
      +CN(CJ(Style,'padding'))*FScale;
  finally SelectObject(FSurface.DC,Old); end;
end;
''' + s[start:]
s = s.replace("  if FPlot.Width<1 then FPlot.Right:=FPlot.Left+1; if FPlot.Height<1 then FPlot.Bottom:=FPlot.Top+1;",
'''  { The title is measured on the same native DC/font used by the final frame.
    An explicit larger grid margin wins; a smaller one cannot overlap the title. }
  Y:=LayoutTitle(False);
  if Y>0 then FPlot.Top:=Max(FPlot.Top,Y+12*FScale);
  if FPlot.Width<1 then FPlot.Right:=FPlot.Left+1; if FPlot.Height<1 then FPlot.Bottom:=FPlot.Top+1;''')
s = s.replace('  DrawTitle; DrawLegend;', '  LayoutTitle(True); DrawLegend;')
start = s.index('procedure TDACChartEngine.DrawTitle;')
end = s.index('procedure TDACChartEngine.DrawLegend;', start)
s = s[:start] + '''function TDACChartEngine.LayoutTitle(Draw: Boolean): Double;
var V,Style,SubStyle: TJSONValue; X,Y,MainHeight,SubY: Double;
  Align: TDACChartTextAlign; Resolved: TJSONObject; Pair: TJSONPair; MainText,SubText: string;
begin
  Result:=0;
  V:=CJ(FOptions,'title'); if (V=nil) or not CB(CJ(V,'show'),True) then Exit;
  MainText:=CS(CJ(V,'text')); SubText:=CS(CJ(V,'subtext'));
  if (MainText='') and (SubText='') then Exit;
  X:=LengthValue(CJ(V,'left'),FSurface.Width,5); Y:=LengthValue(CJ(V,'top'),FSurface.Height,15)+5*FScale; Align:=dctaLeft;
  if CS(CJ(V,'left'),'center')='center' then begin X:=FSurface.Width/2; Align:=dctaCenter; end;
  if CS(CJ(V,'left'))='right' then begin X:=FSurface.Width-5*FScale; Align:=dctaRight; end;
  Style:=CJ(V,'textStyle'); SubStyle:=CJ(V,'subtextStyle');
  Resolved:=TJSONObject.Create;
  try
    Resolved.AddPair('fontSize',TJSONNumber.Create(18)); Resolved.AddPair('fontWeight','bold'); Resolved.AddPair('color','#3c3c41');
    if Style is TJSONObject then for Pair in TJSONObject(Style) do CSet(Resolved,Pair.JsonString.Value,TJSONValue(Pair.JsonValue.Clone));
    MainHeight:=TextHeight(MainText,Resolved); Result:=Y+MainHeight;
    if Draw then Text(MainText,X,Y,Resolved,Align);
    if SubText<>'' then begin
      SubY:=Y;
      if MainText<>'' then SubY:=Y+MainHeight+CN(CJ(V,'itemGap'),10)*FScale;
      Result:=Max(Result,SubY+TextHeight(SubText,SubStyle));
      if Draw then Text(SubText,X,SubY,SubStyle,Align);
    end;
  finally Resolved.Free; end;
end;
''' + s[end:]
write(p, s)

p = 'Tests/DACComponentsCharts.dpr'
s = read(p)
s = s.replace('  DAC.Components.Charts.Options, DACComponentsCharts.TypesTests,',
'''  DAC.Components.Charts.Options, DACComponentsCharts.TypesTests,
  DAC.Components.Charts.Engine, DAC.Components.Charts.Surface,''')
start = s.index('procedure TestWindowLifecycle(')
s = s[:start] + '''procedure TestTitleSpacing(const Output: string);
const Titles: array[0..5] of string = (
  '{"text":"Titulo configuravel"}',
  '{"text":"Titulo grande\\nSegunda linha","textStyle":{"fontSize":28},"subtext":"Subtitulo\\nMais detalhes","subtextStyle":{"fontSize":16}}',
  '{"text":"{large|Titulo}","textStyle":{"rich":{"large":{"fontSize":42,"padding":3}}}}',
  '{"subtext":"Apenas subtitulo"}',
  '{"text":"Oculto","show":false}',
  '{"text":""}');
var Engine: TDACChartEngine; Surface: TDACChartSurface; Evidence: TJSONValue;
  Texts: TJSONArray; I,J,DPI,W: Integer; Scale,Bottom,PlotTop: Double; Prefix: string;
begin
  Engine:=TDACChartEngine.Create; Surface:=TDACChartSurface.Create;
  try
    for DPI in TArray<Integer>.Create(96,120,144,192) do
      for W in TArray<Integer>.Create(320,720,1280) do
        for I:=0 to High(Titles) do begin
          Scale:=DPI/96;
          Engine.Configure('{"animation":false,"title":'+Titles[I]+
            ',"grid":{"top":40},"xAxis":{"type":"category","data":["A"],"axisLabel":{"show":false}},'+
            '"yAxis":{"min":0,"max":40,"axisLabel":{"show":false}},"series":[{"type":"bar","data":[40]}]}');
          Engine.Render(Surface,Round(W*Scale),Round(Max(240,W*420/720)*Scale),DPI,PointF(-1,-1));
          PlotTop:=Engine.Marks[0].Y;
          Evidence:=TJSONObject.ParseJSONValue(Engine.GeometryJSON);
          try
            Texts:=TJSONArray(CJ(Evidence,'texts')); Bottom:=0;
            for J:=0 to Texts.Count-1 do
              Bottom:=Max(Bottom,CN(CJ(Texts.Items[J],'y'))+CN(CJ(Texts.Items[J],'height')));
            Prefix:=Format('title-%d-%d-%d',[I,DPI,W]);
            if I<4 then begin
              Require(Texts.Count>0,Prefix+': titulo ausente');
              Require(PlotTop>=Bottom+12*Scale-0.5,Prefix+': grafico invade espaco do titulo');
            end else Near(PlotTop,40*Scale,Prefix+': titulo vazio/oculto reservou espaco');
            if W=720 then Surface.SavePNG(TPath.Combine(Output,Prefix+'.png'));
          finally Evidence.Free; end;
          { Removing the title on the same engine must restore the original grid. }
          Engine.Configure('{"animation":false,"grid":{"top":40},"xAxis":{"data":["A"]},'+
            '"yAxis":{"min":0,"max":40},"series":[{"type":"bar","data":[40]}]}');
          Engine.Render(Surface,Round(W*Scale),Round(Max(240,W*420/720)*Scale),DPI,PointF(-1,-1));
          Near(Engine.Marks[0].Y,40*Scale,'Remover titulo deve restaurar margem');
        end;
    Engine.Configure('{"animation":false,"title":{"text":"Titulo"},"grid":{"top":120},'+
      '"xAxis":{"data":["A"]},"yAxis":{"min":0,"max":40},"series":[{"type":"bar","data":[40]}]}');
    Engine.Render(Surface,720,420,96,PointF(-1,-1));
    Near(Engine.Marks[0].Y,120,'Margem maior deve ser preservada');
    Writeln('Title spacing: native metrics, multiline, subtitle, rich text, hidden/empty, resize and four DPIs OK');
  finally Surface.Free; Engine.Free; end;
end;

''' + s[start:]
s = s.replace("    OutDir:=ExpandFileName(ParamStr(2)); ForceDirectories(OutDir);",
              "    OutDir:=ExpandFileName(ParamStr(2)); ForceDirectories(OutDir);\n    TestTitleSpacing(OutDir);")
write(p, s)

for name in ('tests','demo'):
    src = Path(f'tmp/chart-types-work/build-{name}.cmd').read_text()
    Path(f'tmp/chart-title-spacing/build-{name}.cmd').write_text(src.replace('chart-types-work','chart-title-spacing'))
