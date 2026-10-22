from pathlib import Path
import json,hashlib,shutil,difflib,datetime
c=Path(r'M:\Delphi Componentes\DAC-DelphiComponents'); r=Path(r'M:\MaxxSoft\MaxxRural\Desktop\maxxrural')
tmp=c/'tmp/dbgrid-gaps-20261021'; t=r/'MaxxRural/src/Tests'; out=t/'Resultados/20261021-grid-gaps'
for n in ['before.log','before.xml','qa-mouse.log','qa-mouse.xml','build-runtime.log','build-design.log','build-package.log','component-tests.log','audit.json']:
    shutil.copyfile(tmp/n,out/n)
pairs=[(tmp/'grid.before.pas',c/'Source/Controls/DAC.Components.Controls.DBGrid.pas'),
 (tmp/'cell-painter.before.pas',c/'Source/Controls/DAC.Components.Controls.DBGrid.CellPainter.pas'),
 (tmp/'tests.before.pas',t/'Teste.MovimentoBancario.ColunasGrid.pas')]
diff=''; checks={}
for a,p in pairs:
    b=p.read_bytes(); checks[str(p)]={'utf8_bom':b.startswith(b'\xef\xbb\xbf'),'bare_lf':b.replace(b'\r\n',b'').count(b'\n')}
    assert not checks[str(p)]['utf8_bom'] and checks[str(p)]['bare_lf']==0
    diff+=''.join(difflib.unified_diff(a.read_bytes().decode('cp1252').splitlines(True),b.decode('cp1252').splitlines(True),str(a),str(p)))
p=r/'source/view/View.MovimentoBancario.dfm'
previous=json.loads((t/'Resultados/20261021-grid-pinned/source-sha256.json').read_text('utf8'))
assert hashlib.sha256(p.read_bytes()).hexdigest()==previous[str(p)]
checks['DFM_inalterado']=True
(out/'format-checks.json').write_text(json.dumps(checks,indent=2),encoding='utf8')
(out/'scoped-changes.diff').write_text(diff,encoding='utf8')
paths=[p for _,p in pairs]+[c/'docs/dbgrid/columns.md']
(out/'source-sha256.json').write_text(json.dumps({str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in paths},indent=2),encoding='utf8')
bins=[]
for n in ['MaxxRural.exe','ApiTestes.exe']:
    p=r/'EXE'/n
    bins.append({'path':str(p),'size':p.stat().st_size,'modified':datetime.datetime.fromtimestamp(p.stat().st_mtime).isoformat(),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()})
(out/'executaveis.json').write_text(json.dumps(bins,indent=2),encoding='utf8')
(out/'README.md').write_text('''# Continuidade visual das linhas da TDACDBGrid — 21/10/2026

## Problema e correção

Ao rolar até as últimas colunas, o final da última coluna central podia ficar antes da faixa fixa de Opções. A grid pintava apenas as células existentes, deixando a sobra com o fundo geral: seleção, zebra e separadores ficavam interrompidos.

DrawDataRows agora pinta a superfície da linha inteira, até o limite físico cliente, antes de pintar as células e ações. O renderer compartilha a resolução das cores entre o fundo da linha e das células. Seleção, zebra, estado desabilitado e linha horizontal ficam contínuos. Hover, textos, foco e botões conservam seus clips e hit tests; a sobra permanece sem cursor de ação e não ativa botões.

Alterados: DBGrid.pas, DBGrid.CellPainter.pas, fixture oficial Teste.MovimentoBancario.ColunasGrid.pas e documentação columns.md. O DFM da View não mudou (hash comparado com a entrega anterior). Fontes CP1252/CRLF preservados; nenhum projeto avulso criado, nenhuma configuração da IDE/dproj alterada, nenhum commit.

## Testes automatizados efetivamente executados

- Antes da correção, os dez cenários novos falharam e os 57 anteriores do fixture passaram: before.log/xml. Em claro/96 PPI, a linha selecionada esperava 14872799 e encontrava branco 16777215 no primeiro pixel da sobra; temas escuros e outras escalas também reproduziram. No estado desabilitado, o separador era interrompido.
- Suíte completa final do ApiTestes: **286 aprovados**, zero falhas/erros/ignorados/vazamentos reportados (apitestes-todos.log/xml). Executada com banco Firebird novo e isolado; testes visuais usam dataset local.
- FundoDaLinhaContinuaAteOpcoes compara cada pixel horizontal da sobra com o fundo e o separador da faixa fixa. Cobre linha selecionada e zebra, temas claro/escuro, 96/120/144/192 PPI, estado desabilitado, cursor e ausência de ativação ao clicar na sobra. O cenário exige uma sobra real maior que oito pixels.
- Os demais testes da suíte continuam cobrindo as três grids carregadas do DFM real, ações, teclado, seleção, ordenação, persistência e quantidade de controles independente dos registros.
- Projeto existente DACDBGridTests: Rebuild e execução aprovados, incluindo streaming DFM, ciclo de vida e layout (component-tests.log).

## Compilações efetivamente executadas

MSBuild /t:Rebuild, Debug/Win32, Delphi 10.2 / dcc32 32.0: ApiTestes, MaxxRural/MaxxADM, DACSkiaComponentsRuntime, DACSkiaComponentsDesign e pacote de compatibilidade DACSkiaComponents aprovados. Logs nesta pasta: build.log, build-desktop.log e build-{runtime,design,package}.log. O desktop continua com warnings/hints existentes do projeto, sem erros.

Scripts do consumidor nesta pasta. Scripts dos pacotes e teste existente em DAC-DelphiComponents/tmp/dbgrid-columns-20261020/build-{runtime,design,package,existing-tests}.cmd. Saídas dos pacotes isoladas em tmp, sem instalação na IDE. MaxxRural.exe e ApiTestes.exe permanecem em EXE; hashes/timestamps em executaveis.json.

## Conferência visual efetivamente executada

Computer Use no fixture TDACGridHostForm do ApiTestes, carregando o subtree TDACTabs/TDACDBGrid do DFM real, com dois registros locais em Prontos. Tema claro, escala do desktop. Capturas exibidas na conversa.

1. Arraste do thumb horizontal até o fim: o fundo verde e a zebra passaram a atravessar a sobra entre Complemento e Opções, com separadores contínuos. Opções permaneceu fixa.
2. Clique na segunda linha na área de Complemento: título passou para registro 0000000002, foco=True, ações=0. A nova linha selecionada também manteve fundo contínuo.
3. Retorno do thumb ao início: sem reaparecimento da faixa branca; seleção do segundo registro preservada.
4. Janela sintética encerrada pelo X. qa-mouse.log/xml: 4/4; a pausa visual substitui as asserções automáticas de Prontos nessa execução, que foram exercitadas na suíte completa. Outras abas executaram normalmente.

Não se declara homologação da tela operacional autenticada, nem inspeção manual em tema escuro/DPI diferentes. Essas variações de tema/escala foram comparadas automaticamente por pixels. A auditoria estática manteve 32 pares de hooks e 15 famílias, com oito avisos TODO preexistentes fora deste ajuste (audit.json).

## Rastreabilidade

scoped-changes.diff registra o delta desta entrega. source-sha256.json identifica fontes finais, format-checks.json verifica CRLF/ausência de BOM e DFM inalterado; executaveis.json identifica os binários oficiais. Alterações anteriores foram preservadas.
''',encoding='utf8')
p=r/'source/README.md'; b=p.read_bytes()
if b'## Continuidade visual das linhas da TDACDBGrid' not in b:
    entry='''

## Continuidade visual das linhas da TDACDBGrid — 21/10/2026

O fundo das linhas agora preenche toda a largura cliente antes das células,
mantendo seleção, zebra e separadores contínuos quando sobra espaço entre a
última coluna rolável e Opções fixa. A sobra mantém os hit tests existentes.
DFM inalterado. Dez regressões novas reproduziram o defeito antes da correção;
suíte completa final: 286 testes aprovados. Rebuilds de ApiTestes, MaxxADM e
pacotes aprovados. Mouse no fixture com DFM real confirmou ida/volta do scroll
e mudança de seleção sem faixa branca. Executáveis em EXE; homologação da
tela operacional autenticada permanece pendente. Evidências:
`MaxxRural/src/Tests/Resultados/20261021-grid-gaps/README.md`.
'''
    try: b.decode('utf8'); enc='utf8'
    except UnicodeDecodeError: enc='cp1252'
    p.write_bytes(b+entry.replace('\n','\r\n' if b'\r\n' in b else '\n').encode(enc))
print(out)
