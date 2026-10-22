from pathlib import Path
R=Path(__file__).resolve().parents[2]
def write(p,t): (R/p).write_bytes(t.replace('\r\n','\n').replace('\n','\r\n').encode('cp1252'))
p='Source/Core/DAC.Components.Charts.Types.pas'; t=(R/p).read_text(encoding='cp1252')
t=t.replace('var Pair: TJSONPair;\n  begin\n    if not (V is TJSONObject)', 'var Pair: TJSONPair; Seen: TStringList;\n  begin\n    if not (V is TJSONObject)')
t=t.replace("    for Pair in TJSONObject(V) do\n      if not InList(Pair.JsonString.Value,Allowed) then Bad(P+'.'+Pair.JsonString.Value,'opcao suportada');", """    Seen:=TStringList.Create;
    try
      Seen.CaseSensitive:=True;
      for Pair in TJSONObject(V) do begin
        if Seen.IndexOf(Pair.JsonString.Value)>=0 then Bad(P+'.'+Pair.JsonString.Value,'chave sem duplicacao');
        Seen.Add(Pair.JsonString.Value);
        if not InList(Pair.JsonString.Value,Allowed) then Bad(P+'.'+Pair.JsonString.Value,'opcao suportada');
      end;
    finally Seen.Free; end;""")
# A dynamic gradient cannot be smuggled into a scalar color property.
t=t.replace("begin O:=Gradient; Put(O,Keys[Index],TJSONNumber.Create(V)); WriteValue(O); end;", "begin\n  if IsNan(V) or IsInfinite(V) then Bad(FPath+'.'+Keys[Index],'numero finito');\n  O:=Gradient; Put(O,Keys[Index],TJSONNumber.Create(V)); WriteValue(O);\nend;")
write(p,t)
p='Source/Controls/DAC.Components.Charts.Options.pas'; t=(R/p).read_text(encoding='cp1252')
t=t.replace('  Candidate:=nil;\n  try', '  if (AValue=nil) and (Read(APath)=nil) then Exit;\n  Candidate:=nil;\n  try',1)
# Typed dataset source-header, leaving actual row data as JSON because values are heterogeneous.
decl='''  TDACChartDatasetOptions = class(TDACChartOptionNode)
  private
    function GetSourceHeader: TDACChartSwitch;
    procedure SetSourceHeader(V: TDACChartSwitch);
  published
    property SourceHeader: TDACChartSwitch read GetSourceHeader write SetSourceHeader stored False;
  end;
'''
t=t.replace('  TDACChartOptions = class(TPersistent)',decl+'  TDACChartOptions = class(TPersistent)')
t=t.replace('FDataset: TDACChartOptionNode;', 'FDataset: TDACChartDatasetOptions;')
t=t.replace('SetDataset(V: TDACChartOptionNode)', 'SetDataset(V: TDACChartDatasetOptions)')
t=t.replace('property Dataset: TDACChartOptionNode', 'property Dataset: TDACChartDatasetOptions')
t=t.replace("FDataset := TDACChartOptionNode.Create(FStore,'dataset')", "FDataset := TDACChartDatasetOptions.Create(FStore,'dataset')")
t=t[:-5]+'''function TDACChartDatasetOptions.GetSourceHeader: TDACChartSwitch;
begin Result:=TDACChartTypes.Switch(FStore.Read(Path('sourceHeader')),Path('sourceHeader')); end;
procedure TDACChartDatasetOptions.SetSourceHeader(V: TDACChartSwitch);
begin FStore.Write(Path('sourceHeader'),TDACChartTypes.SwitchJSON(V)); end;
end.
'''
# Numeric weight is intentionally not a binary Bold flag.
t=t.replace('    function GetFontFamily: string;', '    function GetFontWeight: Integer;\n    procedure SetFontWeight(V: Integer);\n    function GetFontFamily: string;',1)
t=t.replace('    property FontFamily: string', '    property FontWeight: Integer read GetFontWeight write SetFontWeight stored False;\n    property FontFamily: string',1)
t=t.replace('    property FontFamily;', '    property FontFamily;\n    property FontWeight;')
t=t.replace("(AKey='fontFamily') or (AKey='fontSize') or (AKey='color')", "(AKey='fontFamily') or (AKey='fontSize') or (AKey='fontWeight') or (AKey='color')")
t=t[:-5]+'''function TDACChartTextOptions.GetFontWeight: Integer;
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
'''
write(p,t)
