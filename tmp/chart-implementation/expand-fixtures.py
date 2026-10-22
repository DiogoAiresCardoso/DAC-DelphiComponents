from pathlib import Path
import json, copy
p=Path('docs/charts/echarts-reference/reference-cases.json')
d=json.loads(p.read_text(encoding='utf-8'))
base=copy.deepcopy(d['cases'][0]['option'])
def add(id,title,option): d['cases'].append({'id':id,'title':title,'phase':'visual','option':option,'expected':{'visualReviewRequired':True}})
o=copy.deepcopy(base)
o['title']={'text':'Producao por periodo','subtext':'Titulos, labels e legendas configuraveis','left':'center','top':4,'textStyle':{'fontSize':18,'fontFamily':'Arial','color':'#333333'}}
o['grid']['top']=85
o['legend']={'top':'bottom','left':'center'}
o['series'][0]['label']={'show':True,'position':'inside','color':'#ffffff','formatter':'{c} t'}
o['series'][1]['label']={'show':True,'position':'top','color':'#505372','formatter':'{c}'}
add('V01','Titulos e labels',o)
o=copy.deepcopy(base);o['series']=o['series'][:1]
o['series'][0]['label']={'show':True,'position':'top','formatter':'{name|{b}} {value|{c}}','rich':{'name':{'fontWeight':'bold','color':'#333333'},'value':{'fontSize':16,'color':'#ffffff','backgroundColor':'#5070dd','borderRadius':3,'padding':2}}}
add('V02','Rich text nativo',o)
o=copy.deepcopy(base);o['series']=o['series'][:1]
o['series'][0]['itemStyle']={'color':{'type':'linear','x':0,'y':0,'x2':0,'y2':1,'colorStops':[{'offset':0,'color':'#74D64A'},{'offset':1,'color':'#2F9E22'}]},'borderRadius':4,'shadowBlur':8,'shadowColor':'rgba(0,0,0,0.3)','shadowOffsetX':3,'shadowOffsetY':4}
add('V03','Gradiente e sombra',o)
o=copy.deepcopy(base);o['series']=[{'name':'Serie '+str(i),'type':'bar','data':[5+i,10+i,15+i]} for i in range(12)]
o['legend']={'type':'scroll','top':'bottom','left':20,'itemWidth':18,'itemGap':8}
add('V04','Legenda paginada',o)
o=copy.deepcopy(d['cases'][5]['option']);o['series'][0].update(smooth=True,label={'show':True})
add('V05','Area suave com lacuna',o)
o=copy.deepcopy(d['cases'][7]['option']);o['series'][0]['label']={'show':True,'position':'outside','formatter':'{b}: {d}%'}
o['series'][0]['labelLine']={'show':True}
add('V06','Rosca com labels externos',o)
o=copy.deepcopy(base);o['xAxis']['axisLabel']={'interval':0,'rotate':45,'fontSize':14};o['xAxis']['data']=['Categoria A','Categoria B','Categoria C'];o['grid']['bottom']=90
add('V07','Texto rotacionado',o)
Path('Tests/Charts.Visual/fixtures.json').write_text(json.dumps(d,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
