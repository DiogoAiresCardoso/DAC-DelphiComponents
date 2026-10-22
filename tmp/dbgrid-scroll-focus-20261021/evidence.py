from pathlib import Path
import hashlib,json,shutil,difflib,datetime
c=Path(r'M:\Delphi Componentes\DAC-DelphiComponents')
r=Path(r'M:\MaxxSoft\MaxxRural\Desktop\maxxrural')
t=r/'MaxxRural/src/Tests'
out=t/'Resultados/20261021-grid-scroll-focus'
tmp=c/'tmp/dbgrid-scroll-focus-20261021'
for a,b in [('scroll-before.log','colunas-antes.log'),('scroll-before.xml','colunas-antes.xml'),
            ('scroll-after.log','colunas-depois.log'),('scroll-after.xml','colunas-depois.xml'),
            ('qa-mouse.log','qa-mouse.log'),('qa-mouse.xml','qa-mouse.xml'),
            ('build-runtime.log','build-runtime.log'),('build-design.log','build-design.log'),
            ('build-package.log','build-package.log'),('component-tests.log','component-tests.log')]:
    shutil.copyfile(tmp/a,out/b)
for n in ['scroll-before.bmp','scroll-reference.bmp']:
    if (r/'EXE'/n).exists(): shutil.copyfile(r/'EXE'/n,out/n)
pairs=[(tmp/'grid.before.pas',c/'Source/Controls/DAC.Components.Controls.DBGrid.pas'),
       (tmp/'column.before.pas',c/'Source/Controls/DAC.Components.Controls.DBGrid.Column.pas'),
       (tmp/'view.before.dfm',r/'source/view/View.MovimentoBancario.dfm'),
       (tmp/'tests.before.pas',t/'Teste.MovimentoBancario.ColunasGrid.pas')]
diff=''
for before,after in pairs:
    diff+=''.join(difflib.unified_diff(before.read_bytes().decode('cp1252').splitlines(True),
      after.read_bytes().decode('cp1252').splitlines(True),str(before),str(after)))
(out/'scoped-changes.diff').write_text(diff,encoding='utf8')
paths=[p for _,p in pairs]+[t/'Teste.MovimentoBancario.InputGrid.pas',c/'docs/dbgrid/columns.md']
hashes={str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in paths}
(out/'source-sha256.json').write_text(json.dumps(hashes,indent=2),encoding='utf8')
formats={}
for p in paths:
    if p.suffix not in ['.pas','.dfm']: continue
    b=p.read_bytes()
    formats[str(p)]={'utf8_bom':b.startswith(b'\xef\xbb\xbf'),'bare_lf':b.replace(b'\r\n',b'').count(b'\n')}
    assert not formats[str(p)]['utf8_bom'] and formats[str(p)]['bare_lf']==0
before=(tmp/'view.before.dfm').read_bytes()
after=(r/'source/view/View.MovimentoBancario.dfm').read_bytes()
assert after.replace(b'              AllowFocus = False\r\n',b'')==before
assert after.count(b'AllowFocus = False')==36
formats['DFM']={'AllowFocusFalse':36,'somente_propriedade_solicitada':True}
(out/'format-checks.json').write_text(json.dumps(formats,indent=2),encoding='utf8')
bins=[]
for n in ['MaxxRural.exe','ApiTestes.exe']:
    p=r/'EXE'/n
    bins.append({'path':str(p),'size':p.stat().st_size,'modified':datetime.datetime.fromtimestamp(p.stat().st_mtime).isoformat(),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()})
(out/'executaveis.json').write_text(json.dumps(bins,indent=2),encoding='utf8')
readme='''# TDACDBGrid: rolagem e foco por coluna — 21/10/2026

## Correções

- O cliente Skia e os textos Windows representam um quadro completo. O scroll nativo da VCL usa ScrollWindowEx e invalida só faixas expostas; reaproveitar pixels da composição anterior deixava resíduos. A região do WM_PAINT normal agora é ampliada antes do BeginPaint, sem apagar o fundo. TopLeftChanged também solicita a recomposição. Não há controles adicionais por registro e a infraestrutura de texto foi preservada.
- TDACDBGridColumn.AllowFocus, publicada no Object Inspector, padrão True. False bloqueia foco individual e seu contorno, com navegação que ignora colunas bloqueadas/ocultas. Seleção de linha, hover, ordenação e ações permanecem independentes. A âncora nativa de navegação pode existir sem foco visual de célula. Assign/streaming mantêm a propriedade; DFMs antigos assumem True.
- As 36 colunas das três grids do Movimento Bancário receberam AllowFocus=False. O DFM difere do snapshot inicial somente por essas 36 linhas. Nenhuma operação financeira foi implementada.
- Documentação do componente: docs/dbgrid/columns.md.

## Testes automatizados efetivamente executados

ApiTestes oficial, sem projeto avulso. A suíte completa terminou com **262 testes aprovados**, zero falhas/erros/ignorados/vazamentos reportados pelo executor (`apitestes-todos.log/xml`). Usa banco Firebird novo e isolado, criado pelo script executar-testes.ps1; os testes de UI usam TClientDataSet local.

Nove casos adicionais no fixture de colunas: seis de comparação de pixels após scroll e três de foco. A suíte existente também cobre ordenação, ações, hover, layout e leitura dos três blocos DFM reais. Novas asserções verificam AllowFocus=False nas três grids carregadas em execução. O teste AssignEStreamingAntigoENovo verifica o padrão True em DFM antigo e False após Assign/streaming novo.

ScrollRecompoeCliente captura o DC cliente real depois de WM_HSCROLL e compara com uma repintura completa na mesma posição, nos dois sentidos. Usa dois registros, temas claro/escuro, 96/144 PPI e coluna de 1000 pixels maior que o viewport. Depois: zero pixels divergentes nos seis casos. O tamanho físico da janela de teste em 144 PPI é limitado à área visível para não comparar regiões recortadas pelo formulário.

O ensaio inicial registrou seis falhas (`colunas-antes.*`); a 96 PPI foram 265 pixels residuais ao voltar para a esquerda, tanto em coluna normal quanto maior que o viewport, nos dois temas. Os dois ensaios iniciais em 144 PPI ainda usavam bounds que excediam o formulário e não são usados isoladamente como evidência do defeito; os bounds foram corrigidos antes da confirmação final. O primeiro teste de contorno amostrava o indicador verde da linha e foi corrigido para amostrar o topo da célula.

Os testes de foco exercitam mouse em coluna bloqueada, setas, Home/End, Ctrl+Left/Right, Tab/Shift+Tab com troca de registro, coluna movida/oculta, todas as colunas bloqueadas, seleção de linha, F2/Enter e ações por clique, com identidade do registro. Tab é testado quando entregue ao KeyDown nativo; não se altera o roteamento de Tab entre controles do formulário.

`colunas-depois.*`: fixture direcionado 43/43. A suíte completa final inclui também as asserções adicionais de Ctrl+Left/Right, troca de registro no Tab e F2 com todas as células bloqueadas.

O projeto de testes existente do componente também passou por Rebuild e execução: `DACDBGridTests: PASS` (`component-tests.log`).

## Compilações efetivamente executadas

MSBuild /t:Rebuild, Debug/Win32, Delphi 10.2 (dcc32 32.0):

- ApiTestes.dproj: aprovado (`build.log`).
- MaxxRural/MaxxADM/MaxxRural.dproj: aprovado, 0 erros (`build-desktop.log`); há warnings/hints do projeto, inclusive recurso duplicado já existente.
- DACSkiaComponentsRuntime.dpk, DACSkiaComponentsDesign.dpk e pacote de compatibilidade DACSkiaComponents.dpk: aprovados (`build-runtime.log`, `build-design.log`, `build-package.log`). O dproj existente foi usado com MainSource/SanitizedProjectName e diretórios de saída por parâmetro, sem editar configurações.

Os comandos do consumidor estão nesta pasta. Os comandos dos pacotes e do teste existente estão em `DAC-DelphiComponents/tmp/dbgrid-columns-20261020/build-{runtime,design,package,existing-tests}.cmd`; saídas isoladas em tmp. O primeiro build de pacote dentro do sandbox falhou por leitura do Registro da instalação Delphi; a repetição com acesso autorizado passou. Não foram alteradas configurações da IDE nem instalados pacotes.

MaxxRural.exe e ApiTestes.exe permanecem em EXE; hashes e timestamps em executaveis.json. Código/DFM Delphi mantidos em CP1252/CRLF; ver format-checks.json. Componentes: branch main. Consumidor: feature/movimentobancario-api. Alterações anteriores foram preservadas; nenhum commit foi criado.

## Validação visual efetivamente executada

Computer Use, janela TDACGridHostForm no ApiTestes oficial carregando o subtree real TDACTabs/TDACDBGrid do DFM. Dados locais, dois registros, tema claro e escala física do desktop. Capturas foram exibidas na conversa.

1. Arraste do thumb horizontal do início até o meio e até Opções, seguido de retorno ao início: área vazia limpa, sem linhas verticais residuais.
2. Clique em Detalhes da segunda linha: título do fixture passou para registro 0000000002, foco=True, acoes=1.
3. Clique na célula Histórico da primeira linha: registro 0000000001 selecionado, sem contorno verde individual de célula. O contorno de hover é independente e continua visível.
4. F2 trouxe a coluna Opções à área visível e marcou o botão; Enter mudou somente o contador de ações de 1 para 2, mantendo o registro 0000000001.
5. Ensaio final repetiu arraste completo direita/esquerda e encerrou a janela sintética pelo X. Os quatro casos do fixture terminaram aprovados (`qa-mouse.log/xml`). O ramo pausado substitui as asserções automáticas da página Prontos durante essa execução; essas asserções foram executadas na suíte completa.

O primeiro ensaio manual aplicava o limite de dois registros também às outras páginas; seus testes tentavam avançar além da última linha e falharam. A configuração do fixture foi corrigida para restringir esse limite ao caso pausado; não exigiu alteração adicional no componente. Registro inicial mantido em tmp/dbgrid-scroll-focus-20261021/qa-mouse-initial.*.

## Limites

A homologação visual foi feita no fixture com DFM real e dados locais. A tela operacional completa, autenticação e serviços reais não foram homologados. Claro/escuro e 96/144 PPI foram verificados por comparação automatizada de pixels; não se declara inspeção visual manual do tema escuro nem de múltiplos monitores/DPI. O pacote design-time foi compilado, mas não reinstalado na IDE aberta.

## Rastreabilidade

- scoped-changes.diff: delta dos snapshots capturados ao iniciar esta entrega.
- source-sha256.json: hashes dos arquivos finais de código, DFM e documentação.
- format-checks.json: CRLF, ausência de BOM UTF-8 nos fontes Delphi e delta exato do DFM.
- executaveis.json: artefatos no diretório EXE oficial.
'''
(out/'README.md').write_text(readme,encoding='utf8')
p=r/'source/README.md'
b=p.read_bytes()
entry='''

## Rolagem e foco por coluna da TDACDBGrid — 21/10/2026

A composição da grid agora recompõe o cliente inteiro antes do BeginPaint normal,
evitando resíduos de pixels copiados pela rolagem nativa. Cada coluna publica
AllowFocus (padrão True); as 36 colunas das três grids de Movimento Bancário usam
False, mantendo seleção da linha, hover e ações, sem contorno individual de foco.
DFMs antigos e Assign/streaming foram verificados em execução.

Rebuild Debug/Win32 do ApiTestes, MaxxADM e pacotes runtime/design/compatibilidade
aprovados. Suíte completa: 262 testes aprovados, zero falhas/erros/ignorados.
Comparação de pixels em claro/escuro e 96/144 PPI, incluindo coluna maior que o
viewport. Inspeção pelo mouse no fixture com DFM real confirmou arraste nos dois
sentidos sem linhas residuais, seleção e acionamento único por clique/F2+Enter.
Executáveis em EXE. Homologação da tela operacional autenticada e reinstalação do
pacote na IDE continuam pendentes. Evidências e limites:
`MaxxRural/src/Tests/Resultados/20261021-grid-scroll-focus/README.md`.
'''
try: b.decode('utf8'); enc='utf8'
except UnicodeDecodeError: enc='cp1252'
newline='\r\n' if b'\r\n' in b else '\n'
if b'## Rolagem e foco por coluna da TDACDBGrid' not in b:
    p.write_bytes(b+entry.replace('\n',newline).encode(enc))
print('Evidencias gravadas:',out)
