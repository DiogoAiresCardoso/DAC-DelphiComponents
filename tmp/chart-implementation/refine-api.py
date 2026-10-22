from pathlib import Path
p=Path('Source/Controls/DAC.Components.Charts.Options.pas');s=p.read_bytes().decode('cp1252').replace('\r\n','\n')
a=s.index('  TDACChartTextOptions =');b=s.index('  TDACChartAxisOptions =',a)
block=s[a:b].replace('  private\n','  protected\n',1).replace('  published\n','  public\n',1)
block+='''  TDACChartTitleOptions = class(TDACChartTextOptions)
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

'''
s=s[:a]+block+s[b:]
s=s.replace('FTitle: TDACChartTextOptions','FTitle: TDACChartTitleOptions').replace('Title(V: TDACChartTextOptions)','Title(V: TDACChartTitleOptions)').replace('Title: TDACChartTextOptions','Title: TDACChartTitleOptions').replace("FTitle := TDACChartTextOptions.Create", "FTitle := TDACChartTitleOptions.Create")
s=s.replace('FLabel: TDACChartTextOptions','FLabel: TDACChartLabelOptions').replace('Label(V: TDACChartTextOptions)','Label(V: TDACChartLabelOptions)').replace('LabelStyle: TDACChartTextOptions','LabelStyle: TDACChartLabelOptions').replace('FLabel := TDACChartTextOptions.Create', 'FLabel := TDACChartLabelOptions.Create')
s=s.replace('    FTitle: TDACChartTitleOptions;', '    FTitle: TDACChartTitleOptions;\n    FDataset: TDACChartOptionNode;')
s=s.replace('    procedure SetTitle(V:', '    procedure SetDataset(V: TDACChartOptionNode);\n    procedure SetTitle(V:')
s=s.replace('    property Title: TDACChartTitleOptions', '    property Dataset: TDACChartOptionNode read FDataset write SetDataset stored False;\n    property Title: TDACChartTitleOptions')
s=s.replace("  FTitle := TDACChartTitleOptions.Create(FStore,'title');", "  FTitle := TDACChartTitleOptions.Create(FStore,'title');\n  FDataset := TDACChartOptionNode.Create(FStore,'dataset');")
s=s.replace('FSeries.Free; FStore.Free; inherited;', 'FDataset.Free; FSeries.Free; FStore.Free; inherited;')
s=s.replace('procedure TDACChartOptions.SetTitle', 'procedure TDACChartOptions.SetDataset(V: TDACChartOptionNode);\nbegin FDataset.Assign(V); end;\nprocedure TDACChartOptions.SetTitle')
# Explicitly reject future outer-bound modes instead of silently treating them as none.
s=s.replace("  Keys(CJ(O,'title')", "  if (CJ(CJ(O,'grid'),'outerBoundsMode')<>nil) and (CS(CJ(CJ(O,'grid'),'outerBoundsMode'))<>'none') then\n    raise EDACChartOptionError.Create('grid.outerBoundsMode: somente none nesta etapa');\n  Keys(CJ(O,'title')")
p.write_bytes(s.replace('\n','\r\n').encode('cp1252'))
p=Path('Source/Skia/DAC.Components.Charts.Engine.pas');s=p.read_bytes().decode('cp1252').replace('\r\n','\n')
s=s.replace("CS(CJ(FSeries[S].Options,'id'),IntToStr(S))", "CS(CJ(FSeries[S].Options,'id'),CS(CJ(FSeries[S].Options,'name'),IntToStr(S)))")
s=s.replace('Old.Free;\n  V:=', 'Old.Free; FHidden.Clear;\n  V:=')
s=s.replace('else FHidden.AddOrSetValue(Pair.JsonString.Value,True);\nend;', 'else FHidden.AddOrSetValue(Pair.JsonString.Value,True);\n  LoadData;\nend;')
s=s.replace('XV:=Arr(Arr(Source,0),P+StartRow); YV:=Arr(Arr(Source,S+1),P+StartRow);', 'XV:=Arr(Arr(Source,XCol),P+StartRow); YV:=Arr(Arr(Source,YCol),P+StartRow);')
s=s.replace("FSeries[S].Values[P].Id:=CS(CJ(FSeries[S].Values[P].Item,'id'),FSeries[S].Values[P].Name);", "FSeries[S].Values[P].Id:=CS(CJ(FSeries[S].Values[P].Item,'id'),FSeries[S].Values[P].Name+'|'+IntToStr(P));")
s=s.replace('IsInfinite(FSeries[S].Values[P].Y);', 'IsInfinite(FSeries[S].Values[P].Y) or IsNan(FSeries[S].Values[P].X) or IsInfinite(FSeries[S].Values[P].X);')
s=s.replace("  State:='';", "  State:='';")
s=s.replace("FormatFloat('0.##',Total,TFormatSettings.Invariant)", "FormatFloat('0.'+StringOfChar('#',EnsureRange(Round(CN(CJ(FSeries[M.SeriesIndex].Options,'percentPrecision'),2)),0,15)),Total,TFormatSettings.Invariant)")
p.write_bytes(s.replace('\n','\r\n').encode('cp1252'))
