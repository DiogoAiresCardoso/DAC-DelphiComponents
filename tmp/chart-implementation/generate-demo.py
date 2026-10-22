from pathlib import Path
lines=[]
def obj(name,typ,props,children=()):
 return [f'object {name}: {typ}']+['  '+v for v in props]+['  '+line for child in children for line in child]+['end']
def button(n,c,x,event,w=110):return obj(n,'TButton',[f'Left = {x}','Top = 10',f'Width = {w}','Height = 28',f"Caption = '{c}'",f'OnClick = {event}'])
tabs=[]
tabs.append(obj('GalleryTab','TTabSheet',["Caption = 'Galeria'"],[obj('Gallery','TScrollBox',['Align = alClient','BorderStyle = bsNone'])]))
bar=obj('ConfigBar','TPanel',['Align = alTop','Height = 90'],[
 obj('Cases','TComboBox',['Left = 10','Top = 10','Width = 560','Height = 25','Style = csDropDownList','OnChange = CaseChanged']),
 obj('Status','TLabel',['Left = 10','Top = 70','Width = 1000','Height = 16',"Caption = 'Configuracao ECharts 6.1.0'"]),
 *[obj(n,'TButton',[f'Left = {10+i*125}','Top = 39','Width = 115','Height = 26',f"Caption = '{c}'",f'OnClick = {e}']) for i,(n,c,e) in enumerate([('ApplyButton','Aplicar JSON','ApplyClick'),('ResetButton','Restaurar','ResetClick'),('ImportButton','Importar','ImportClick'),('ExportButton','Exportar','ExportClick'),('CopyButton','Copiar JSON','CopyClick')])]])
tabs.append(obj('ConfigTab','TTabSheet',["Caption = 'Configuracao'"],[bar,obj('Editor','TMemo',['Align = alBottom','Height = 170','ScrollBars = ssBoth','WordWrap = False',"Font.Name = 'Consolas'",'Font.Height = -13']),obj('ChartHost','TPanel',['Align = alClient','BevelOuter = bvNone'])]))
visual_controls=[obj('TitleEdit','TEdit',['Left = 10','Top = 10','Width = 380',"Text = 'Titulo configuravel'",'OnChange = VisualChanged'])]
for i,(n,c) in enumerate([('LabelsCheck','Labels'),('LegendCheck','Legenda'),('TooltipCheck','Tooltip')]):
 visual_controls.append(obj(n,'TCheckBox',[f'Left = {10+i*140}','Top = 45','Width = 130',f"Caption = '{c}'",'OnClick = VisualChanged']))
visual_controls.append(obj('ThemeBox','TComboBox',['Left = 420','Top = 10','Width = 180','Style = csDropDownList','Items.Strings = (',"  'ECharts'","  'DAC')",'ItemIndex = 0','OnChange = VisualChanged']))
tabs.append(obj('VisualTab','TTabSheet',["Caption = 'Elementos visuais'"],[obj('VisualBar','TPanel',['Align = alTop','Height = 80'],visual_controls),obj('VisualHost','TPanel',['Align = alClient','BevelOuter = bvNone'])]))
tabs.append(obj('CompareTab','TTabSheet',["Caption = 'Comparacao'"],[obj('CompareBar','TPanel',['Align = alTop','Height = 80'],[
obj('ReferenceDir','TEdit',['Left = 10','Top = 10','Width = 440',"Text = 'tmp\\chart-implementation\\reference'"]),obj('ActualDir','TEdit',['Left = 10','Top = 43','Width = 440',"Text = 'tmp\\chart-implementation\\dac'"]),button('CompareButton','Carregar imagens',470,'CompareClick',150)]),obj('CompareScroll','TScrollBox',['Align = alClient'])]))
tabs.append(obj('StabilityTab','TTabSheet',["Caption = 'Animacao e estabilidade'"],[obj('StabilityBar','TPanel',['Align = alTop','Height = 52'],[button(n,c,10+i*150,e,140) for i,(n,c,e) in enumerate([('UpdateButton','Atualizar valores','UpdateClick'),('ReplayButton','Reiniciar animacao','ReplayClick'),('StopButton','Parar','StopClick'),('CaptureButton','Capturar PNG','CaptureClick'),('StressButton','Carga 1.000 pontos','StressClick')])]),obj('Metrics','TMemo',['Align = alBottom','Height = 110','ReadOnly = True','ScrollBars = ssVertical']),obj('StabilityHost','TPanel',['Align = alClient','BevelOuter = bvNone'])]))
root=obj('ChartsDemoForm','TChartsDemoForm',["Caption = 'DAC Charts - ECharts / Skia'",'ClientWidth = 1200','ClientHeight = 800','Position = poScreenCenter',"Font.Name = 'Segoe UI'",'Font.Height = -13','OnCreate = FormCreate','OnDestroy = FormDestroy','OnShow = FormShow'],[
obj('Pages','TPageControl',['Align = alClient','OnChange = PageChanged'],tabs),obj('MetricsTimer','TTimer',['Enabled = False','Interval = 250','OnTimer = MetricsTick']),obj('OpenDialog','TOpenDialog',["Filter = 'JSON|*.json'"]),obj('SaveDialog','TSaveDialog',["Filter = 'JSON|*.json'","DefaultExt = 'json'"])])
Path('demo-charts/DACChartsDemo.Main.dfm').write_bytes(('\r\n'.join(root)+'\r\n').encode('cp1252'))
text=Path('tmp/chart-implementation/Demo.new.pas').read_text(encoding='utf-8')
Path('demo-charts/DACChartsDemo.Main.pas').write_bytes(text.replace('\n','\r\n').encode('cp1252'))
build=Path('tmp/chart-implementation/build-tests.cmd').read_text()
build=build.replace('Tests\\DACComponentsCharts.dproj','demo-charts\\DACChartsDemo.dproj').replace('\\dcu"','\\demo-dcu"').replace('\\exe"','\\demo-exe"')
Path('tmp/chart-implementation/build-demo.cmd').write_text(build)
