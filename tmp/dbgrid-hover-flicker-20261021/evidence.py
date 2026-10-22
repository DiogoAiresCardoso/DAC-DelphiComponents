from pathlib import Path
import json, re, shutil, difflib, hashlib, datetime, xml.etree.ElementTree as ET

c = Path(r'M:\Delphi Componentes\DAC-DelphiComponents')
r = Path(r'M:\MaxxSoft\MaxxRural\Desktop\maxxrural')
t = r/'MaxxRural/src/Tests'
tmp = c/'tmp/dbgrid-hover-flicker-20261021'
out = t/'Resultados/20261021-grid-hover-flicker'

suite = ET.parse(out/'apitestes-todos.xml').getroot()
assert suite.attrib['total'] == '307'
assert suite.attrib['errors'] == suite.attrib['failures'] == '0'
before = ET.parse(out/'before.xml').getroot()
assert before.attrib['total'] == '75' and before.attrib['failures'] == '5'
after = ET.parse(out/'after.xml').getroot()
assert after.attrib['total'] == '75' and after.attrib['errors'] == after.attrib['failures'] == '0'
qa = ET.parse(out/'qa-native.xml').getroot()
assert qa.attrib['total'] == '4' and qa.attrib['errors'] == qa.attrib['failures'] == '0'

probes = {}
for phase in ['before-probes','after-probes','suite-probes']:
    probes[phase] = {}
    for path in sorted((out/phase).glob('*.txt')):
        probes[phase][path.stem] = {key:int(value) for key,value in re.findall(r'(\w+)=(\d+)',path.read_text('utf8'))}
    assert len(probes[phase]) == 8
    if phase != 'before-probes':
        assert all(x['blanks'] == x['invalid'] == 0 and x['paints'] == 100 and x['captures'] >= 20 for x in probes[phase].values())
(out/'probe-summary.json').write_text(json.dumps(probes,indent=2),encoding='utf8')

pairs=[(tmp/'grid.before.pas',c/'Source/Controls/DAC.Components.Controls.DBGrid.pas'),
       (tmp/'surface.before.pas',c/'Source/Controls/DAC.Components.Controls.DBGrid.SurfaceBuffer.pas'),
       (tmp/'tests.before.pas',t/'Teste.MovimentoBancario.ColunasGrid.pas')]
changes=''; formats={}
for a,p in pairs:
    data=p.read_bytes()
    formats[str(p)]={'utf8_bom':data.startswith(b'\xef\xbb\xbf'),'bare_lf':data.replace(b'\r\n',b'').count(b'\n')}
    assert not formats[str(p)]['utf8_bom'] and formats[str(p)]['bare_lf']==0
    changes+=''.join(difflib.unified_diff(a.read_bytes().decode('cp1252').splitlines(True),data.decode('cp1252').splitlines(True),str(a),str(p)))
(out/'scoped-changes.diff').write_text(changes,encoding='utf8')
dfm=r/'source/view/View.MovimentoBancario.dfm'
previous=json.loads((t/'Resultados/20261021-grid-performance/source-sha256.json').read_text('utf8'))
assert hashlib.sha256(dfm.read_bytes()).hexdigest()==previous[str(dfm)]
formats['production_dfm_unchanged']=True
(out/'format-checks.json').write_text(json.dumps(formats,indent=2),encoding='utf8')
paths=[p for _,p in pairs]+[dfm,c/'docs/dbgrid/columns.md']
(out/'source-sha256.json').write_text(json.dumps({str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in paths},indent=2),encoding='utf8')

for name in ['build-runtime.log','build-design.log','build-package.log','component-tests.log','audit.json']:
    shutil.copy2(tmp/name,out/name)
shutil.copy2(t/'Resultados/20261021-grid-performance/environment.json',out/'environment.json')
bins=[]
for name in ['MaxxRural.exe','ApiTestes.exe']:
    p=r/'EXE'/name
    bins.append({'path':str(p),'size':p.stat().st_size,'modified':datetime.datetime.fromtimestamp(p.stat().st_mtime).isoformat(),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()})
(out/'executaveis.json').write_text(json.dumps(bins,indent=2),encoding='utf8')
project=r/'MaxxRural/MaxxADM/MaxxRural.dproj'
project_text=project.read_text('utf8')
uses_packages=';'.join(re.findall(r'<DCC_UsePackage[^>]*>(.*?)</DCC_UsePackage>',project_text))
print('MaxxRural explicit DAC runtime package reference:', 'DACSkia' in uses_packages)

perf=[]
for path in (out/'suite-performance').glob('*-10000-checkbox0.json'):
    data=json.loads(path.read_text('utf-8-sig'))
    assert data['assertions_passed'] and data['grid_controls_after']==0
    perf.append(data)
assert len(perf)==3
paint=max(x['paint']['p95_ms'] for x in perf)
hover=max(x['hover']['p95_ms'] for x in perf)
vertical=max(x['vertical_scroll']['p95_ms'] for x in perf)
horizontal=max(x['horizontal_scroll']['p95_ms'] for x in perf)
print('10k worst p95 paint/hover/vertical/horizontal:',paint,hover,vertical,horizontal)
before_blanks=sum(x['blanks'] for x in probes['before-probes'].values())
before_reads=sum(x['captures'] for x in probes['before-probes'].values())
after_reads=sum(x['captures'] for x in probes['after-probes'].values())
suite_reads=sum(x['captures'] for x in probes['suite-probes'].values())

readme=f'''# TDACDBGrid: cintilação no hover — 21/10/2026

## Causa reproduzida e correção

Com colunas fixas, SetColumnAttributes desliga o DoubleBuffered da VCL: o buffer nativo usa o viewport lógico reduzido e recortaria a faixa física de Opções. O renderer próprio apresentava a imagem Skia no HWND e, depois, desenhava os textos nativos diretamente nesse HWND. Cada mudança de hover podia, portanto, expor uma pintura sem texto até terminar a segunda camada.

A grid agora compõe chrome/ícones Skia e texto Windows no mesmo DIB top-down de 32 bits fora da tela. BeginNativeText conclui Skia e devolve o DC desse DIB ao renderer de texto existente. Present transfere a pintura pronta por um BitBlt, depois de concluir o texto; também conclui a transferência antes de reutilizar os pixels na próxima pintura. Fontes, alinhamento, reticências, recortes e hit tests continuam nos mecanismos existentes. Não há propriedade nova para ativar a correção.

O buffer mantém um DC e um bitmap por instância, reutilizados; redimensionar libera os anteriores. Destruição libera primeiro a superfície Skia, restaura o bitmap original no DC e libera DIB/DC. Não há referência a HWND no buffer, permitindo recriação do handle sem pendências. Foram preservados o recorte das faixas fixas, a composição completa após scroll, a continuidade das linhas e as regras de seleção/ações. DFM da View não mudou.

## Reprodução automatizada antes da correção

Teste acrescentado ao ApiTestes oficial, em Teste.MovimentoBancario.ColunasGrid.pas. O fixture localiza um pixel sólido de título lendo o próprio HWND (sem presumir raster de fonte) e o observa em uma thread enquanto o hover percorre quatro células, forçando 100 pinturas. O cabeçalho monitorado não muda de hover; esse pixel não deve virar fundo durante a pintura.

Oito cenários: temas claro/escuro em 96/144/192 PPI com Opções fixa, e temas claro/escuro sem colunas fixas e sem buffer VCL a 96 PPI. O teste verifica leitura válida, amostragem efetiva e número de pinturas, além da ausência de texto apagado.

**Antes: 70 aprovados e cinco falhas entre 75 casos** (67 anteriores + oito novos). Houve {before_blanks} leituras de fundo no lugar de texto em {before_reads} leituras totais. Em fixaClaro96 foram 323/16.414. Três cenários novos não flagraram o intervalo nessa execução; não se afirma que ele apareça em toda amostragem. before.log/xml e before-probes registram os dados.

## Resultados automatizados depois da correção

- Fixture de colunas: **75/75**, zero falhas/erros/ignorados/vazamentos reportados; **zero** leituras de texto apagado nas {after_reads} leituras dos oito cenários (after.log/xml e after-probes). Cada caso executou 100 pinturas.
- Acrescentada uma nona regressão, BufferNaoAcumulaHandlesAoRedimensionar: 100 tamanhos diferentes, exatamente um bitmap + um DC por instância, retorno à contagem GDI inicial depois de destruir o buffer.
- Suíte completa oficial: **307/307 aprovados**, zero falhas/erros/ignorados/vazamentos reportados pelo DUnitX, em {suite.attrib.get('time','?')} s. Inclui os 298 testes anteriores e as nove regressões desta entrega. Banco Firebird novo e isolado, sem apontar para base operacional. Na segunda amostragem dos oito cenários, zero leituras de texto apagado em {suite_reads} leituras (suite-probes).
- Testes existentes do componente: DACDBGridTests Rebuild + execução PASS, cobrindo ordenação, seleção, layout, ciclo de vida, pintura e streaming DFM com 11 colunas persistentes. A suíte oficial também mantém a leitura/gravação dos blocos reais da View.
- O benchmark local voltou a executar seus 12 cenários, com até 10.000 registros e as três configurações reais de grid. Com 10.000, pior p95 entre as três abas: pintura {paint:.2f} ms, hover {hover:.2f} ms, scroll vertical {vertical:.2f} ms, horizontal {horizontal:.2f} ms; nenhuma criação de controles por registro ou falha de identidade/ativação. JSONs em suite-performance. É uma rodada adicional de regressão, não uma repetição das três rodadas comparativas anteriores nem medição de FPS. Ambiente da mesma sessão registrado em environment.json.

O monitor de pixels é uma verificação temporal automatizada de um glifo representativo. Não é prova de ausência de qualquer artefato em todos os pixels/monitores/cargas, nem auditoria geral de vazamentos. As escalas dos testes usam ChangeScale/EffectivePPI do helper existente.

## Compilações executadas

MSBuild /t:Rebuild, Debug/Win32, Delphi 10.2: ApiTestes, MaxxRural/MaxxADM, DACSkiaComponentsRuntime, DACSkiaComponentsDesign, pacote DACSkiaComponents e projeto existente DACDBGridTests aprovados. Logs nesta pasta: build.log, build-desktop.log, build-desktop-console.log, build-runtime.log, build-design.log, build-package.log, component-tests.log. Há warnings/hints anteriores dos projetos, sem erro final.

MaxxRural.exe e ApiTestes.exe atualizados no diretório oficial EXE. Não houve mudança de configuração de projeto/IDE nem instalação ou recarga de pacote na IDE. Saídas dos pacotes ficaram isoladas em tmp; hashes/timestamps dos executáveis em executaveis.json.

## Conferência visual efetivamente executada

Computer Use no fixture TDACGridHostForm do ApiTestes, que carrega as tabs e as três grids do DFM real, com 80 registros locais por aba, tema claro e escala do desktop. Capturas foram exibidas na conversa.

1. Pintura inicial: cabeçalhos, textos, linha selecionada e três ações visíveis.
2. Clique em Histórico na terceira linha: título do host passou a registro 0000000003, foco=True, ações=0. Textos e seleção foram preservados.
3. Arraste do thumb horizontal até o fim: Opções permaneceu fixa, fundo/separadores da linha selecionada contínuos e cabeçalhos legíveis.
4. Clique em Detalhes da terceira linha: título manteve registro 0000000003 e passou a ações=1. Dica e foco do botão apareceram, sem operação financeira.
5. Host encerrado pelo X; qa-native.log/xml: 4/4. A pausa visual substitui as asserções automáticas de Prontos apenas nessa execução; elas foram exercitadas na suíte completa. Conciliar/Importados seguiram suas asserções normais.

Essa conferência é de estados finais e interação no fixture. A evidência temporal do hover é a amostragem automatizada antes/depois; screenshots isolados não provam ausência de cintilação. Não houve homologação da tela operacional autenticada, mudança física de monitor ou validação visual manual em tema escuro.

## Escopo, reprodução e rastreabilidade

Alterados: DBGrid.pas, DBGrid.SurfaceBuffer.pas, fixture oficial ColunasGrid.pas, docs/dbgrid/columns.md e atualização de source/README.md. Preservados CP1252/CRLF, DFM, ações anteriores e alterações existentes dos repositórios. Nenhum projeto de teste avulso ou commit.

Nesta pasta, compilar.cmd executa Rebuild do ApiTestes e executar-testes.ps1 executa a suíte inteira em banco isolado. Para repetir somente as colunas: ApiTestes.exe --run:Teste.MovimentoBancario.ColunasGrid.TMovimentoBancarioColunasGridTests --exit:Continue --xml:<arquivo>. DAC_GRID_FLICKER_OUTPUT_DIR escolhe a pasta dos arquivos probe-*.txt. Não execute outro fixture de UI em paralelo.

Scripts dos pacotes/teste existente: DAC-DelphiComponents/tmp/dbgrid-columns-20261020/build-{{runtime,design,package,existing-tests}}.cmd. compilar-desktop.cmd nesta pasta recompila o MaxxRural mantendo o EXE oficial.

scoped-changes.diff contém o delta desta correção. probe-summary.json agrega as amostragens. source-sha256.json, format-checks.json e executaveis.json identificam os fontes, formatos, DFM inalterado e binários. Auditoria estática: 275 arquivos, 32 pares de hooks/15 famílias, oito avisos TODO preexistentes fora da correção (audit.json); ela não comprova a ausência de cintilação.
'''
(out/'README.md').write_text(readme,encoding='utf8')

p=r/'source/README.md'
text=p.read_bytes().decode('cp1252').replace('\r\n','\n')
heading='## Cintilacao da TDACDBGrid durante hover — 21/10/2026'
if heading not in text:
    text+=f'''\n\n{heading}

Chrome Skia e texto Windows agora sao compostos no mesmo DIB fora da tela,
apresentado completo por uma transferencia. Isso remove o intervalo em que
colunas fixas exibiam fundo sem texto a cada mudanca de hover, preservando o
renderer nativo e os recortes. O buffer possui e libera seu DC/bitmap.
Reproducao: cinco falhas novas antes da correcao; oito cenarios de hover sem
texto apagado depois. Nova regressao de recursos GDI/resize tambem aprovada.
Suite oficial final: 307/307; benchmark ate 10.000 registros novamente
executado. Rebuilds do desktop, ApiTestes e pacotes aprovados, EXEs no local
oficial. Conferencia visual no fixture confirmou selecao, scroll e acao unica;
tela operacional autenticada nao homologada nesta etapa. Evidencias:
`MaxxRural/src/Tests/Resultados/20261021-grid-hover-flicker/README.md`.
'''
    p.write_bytes(text.replace('\n','\r\n').encode('cp1252'))
print('Reproduced blanks:',before_blanks,'Post-fix blanks: 0. Final suite:',suite.attrib['total'])
