from pathlib import Path
import json,re
def read(p): return Path(p).read_bytes().decode('cp1252')
def write(p,s): Path(p).write_bytes(s.replace('\r\n','\n').replace('\n','\r\n').encode('cp1252'))
p='demo/Demo.Principal.dfm';s=read(p)
cats=['Jan','Fev','Mar','Abr']
opts={
'demoBarChart': {'title':{'text':'Manual: barras e linha','textStyle':{'fontSize':12}},'grid':{'top':40,'bottom':25},'xAxis':{'type':'category','data':cats},'yAxis':{'type':'value'},'series':[{'type':'bar','name':'Producao','data':[20,35,27,46]},{'type':'line','name':'Meta','data':[28,30,33,39]}]},
'demoDoughnutChart': {'series':[{'type':'pie','name':'Culturas','radius':['35%','65%'],'label':{'show':False},'data':[{'name':'Soja','value':55},{'name':'Milho','value':30},{'name':'Feijao','value':15}]}]},
'demoLineChart': {'grid':{'top':20,'bottom':25},'xAxis':{'type':'category','data':cats},'yAxis':{'type':'value'},'series':[{'type':'line','name':'Umidade','data':[16,22,None,18]}]},
'demoAreaChart': {'grid':{'top':20,'bottom':25},'xAxis':{'type':'category','data':cats},'yAxis':{'type':'value'},'series':[{'type':'line','name':'Precipitacao','areaStyle':{},'data':[12,30,24,40]}]}}
for name,opt in opts.items():
 opt['animation']=False
 a=s.index('      object '+name+': TDACChart'); b=s.index('\n      end',a)
 block=s[a:b]; tab=re.search(r'        TabOrder = \d+',block)[0]
 head=block[:block.index('\n        Height =')];head+=re.search(r'\n        Height = \d+',block)[0]
 js=json.dumps(opt,separators=(',',':'),ensure_ascii=True)
 chunks=[js[i:i+180].replace("'","''") for i in range(0,len(js),180)]
 s=s[:a]+head+'\n        Options.JSON =\n          '+" +\n          ".join("'"+c+"'" for c in chunks)+'\n'+tab+s[b:]
write(p,s)
p='Tests/DACComponentsInteraction.dpr';s=read(p)
Path('tmp/chart-implementation/Interaction.before-migration.dpr').write_bytes(Path(p).read_bytes())
s=s.replace('RequireGeometry(TDACChart.Create(nil), LControls.ChartDefaultWidth,\r\n    LControls.ChartDefaultHeight,', 'RequireGeometry(TDACChart.Create(nil), 720,\r\n    420,')
s=s.replace("    LChart.BackgroundColor := LSurface;\r\n    LChart.BorderColor := TAlphaColor($00000000);\r\n    LChart.ChartGrid.Visible := False;", "    LChart.LoadJSON('{\"animation\":false,\"backgroundColor\":\"#0E1F15\",\"series\":[]}');")
s=s.replace("    RequireBlendAt(LChart,", "    LExpected := RGB($0E, $1F, $15);\r\n    RequireBlendAt(LChart,")
s=s.replace('LSemanticChart.Appearance := mchaDashboard;', "LSemanticChart.LoadJSON('{\"backgroundColor\":\"#102417\",\"series\":[]}');")
s=s.replace('LStreamedChart.Appearance = mchaDashboard','LStreamedChart.SaveJSON = LSemanticChart.SaveJSON').replace('Round-trip do Chart perdeu Appearance Dashboard.','Round-trip do Chart perdeu as opcoes JSON.')
s=s.replace('(LDashboardChart.Appearance = mchaDashboard)',"(Pos('#102417', LDashboardChart.SaveJSON) > 0)")
s=re.sub(r'\(LDashboardChart.BackgroundColor =\s+TDACComponentStyle.Resolve\(dtm(?:Light|Dark)\).Tokens.Controls.\s+ChartDashboardBackground\)',"(Pos('#102417', LDashboardChart.SaveJSON) > 0)",s)
s=s.replace('IntToHex(Cardinal(LDashboardChart.BackgroundColor), 8)',"LDashboardChart.SaveJSON")
a=s.index('  LThemeChart.ThemeMode := dtmDark;'); b=s.index('  Require((TDACComponentStyle.Resolve',a)
s=s[:a]+'''  Require(Pos('backgroundColor', LThemeChart.SaveJSON) = 0,
    'Chart deve iniciar com os defaults ECharts.');
  LThemeChart.LoadJSON('{"backgroundColor":"#102417","color":["#3DB82A"],"series":[]}');
  TDACThemeManager.SetApplicationMode(dtmDark);
  Require(Pos('#102417', LThemeChart.SaveJSON) > 0,
    'Tema explicito do Chart foi alterado pelo tema global.');
  TDACThemeManager.SetApplicationMode(dtmLight);
'''+s[b:]
a=s.index('  LThemeDoughnut.ChartType :='); b=s.index('  LThemeReport :=',a)
s=s[:a]+'''  LThemeDoughnut.LoadJSON('{"color":["#5070dd"],"series":[{"type":"pie",' +
    '"radius":["40%","70%"],"data":[55,30,15]}]}');
  LThemeDoughnut.SetBounds(Max(0, Form1.ClientWidth - 2), Max(0, Form1.ClientHeight - 2), 1, 1);
  TDACThemeManager.SetApplicationMode(dtmDark);
  Require(Pos('#5070dd', LThemeDoughnut.SaveJSON) > 0,
    'Paleta ECharts explicita foi substituida pelo tema global.');

'''+s[b:]
a=s.index("  LBody := SourceProcedureBody(LSource, 'procedure tdacchart.drawpieseries');");b=s.index('  LPalettePath :=',a)
s=s[:a]+'''  Require(Pos('dac.components.charts.engine', LSource) > 0,
    'Chart deve delegar a pintura ao engine ECharts/Skia.');
'''+s[b:]
write(p,s)
p='Package/DACSkiaComponents.dproj';s=read(p)
anchor='        <DCCReference Include="..\\Source\\Controls\\DAC.Components.Controls.Charts.pas"/>'
for d,u in [('Controls','Options'),('Skia','Engine'),('Skia','Surface')]:
 line=f'        <DCCReference Include="..\\Source\\{d}\\DAC.Components.Charts.{u}.pas"/>'
 if line not in s:s=s.replace(anchor,line+'\r\n'+anchor)
write(p,s)
