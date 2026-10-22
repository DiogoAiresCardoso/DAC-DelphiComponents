from pathlib import Path
import json,hashlib,shutil,difflib,datetime
c=Path(r'M:\Delphi Componentes\DAC-DelphiComponents')
r=Path(r'M:\MaxxSoft\MaxxRural\Desktop\maxxrural')
tmp=c/'tmp/dbgrid-pinned-20261021'; tests=r/'MaxxRural/src/Tests'; out=tests/'Resultados/20261021-grid-pinned'
out.mkdir(exist_ok=True)
for n in ['build-runtime.log','build-design.log','build-package.log','component-tests.log','qa-mouse.log','qa-mouse.xml','audit.json']:
    shutil.copyfile(tmp/n,out/n)
shutil.copyfile(tmp/'colunas.log',out/'colunas-direcionado-56.log')
shutil.copyfile(tmp/'colunas.xml',out/'colunas-direcionado-56.xml')
pairs=[('grid.before.pas',c/'Source/Controls/DAC.Components.Controls.DBGrid.pas'),
 ('column.before.pas',c/'Source/Controls/DAC.Components.Controls.DBGrid.Column.pas'),
 ('types.before.pas',c/'Source/Controls/DAC.Components.Controls.DBGrid.Types.pas'),
 ('native-text.before.pas',c/'Source/Controls/DAC.Components.Controls.DBGrid.NativeText.pas'),
 ('cell-painter.before.pas',c/'Source/Controls/DAC.Components.Controls.DBGrid.CellPainter.pas'),
 ('view.before.dfm',r/'source/view/View.MovimentoBancario.dfm'),
 ('tests.before.pas',tests/'Teste.MovimentoBancario.ColunasGrid.pas')]
diff=''; checks={}
for before,p in pairs:
    a=(tmp/before).read_bytes(); b=p.read_bytes()
    diff+=''.join(difflib.unified_diff(a.decode('cp1252').splitlines(True),b.decode('cp1252').splitlines(True),str(tmp/before),str(p)))
    checks[str(p)]={'utf8_bom':b.startswith(b'\xef\xbb\xbf'),'bare_lf':b.replace(b'\r\n',b'').count(b'\n')}
    assert not checks[str(p)]['utf8_bom'] and checks[str(p)]['bare_lf']==0
dfm=(r/'source/view/View.MovimentoBancario.dfm').read_bytes()
assert dfm.count(b'PinPosition = dgpRight')==3
assert dfm.replace(b'              PinPosition = dgpRight\r\n',b'')==(tmp/'view.before.dfm').read_bytes()
checks['DFM_delta']={'novas_linhas_PinPosition_dgpRight':3,'restante_identico':True}
(out/'format-checks.json').write_text(json.dumps(checks,indent=2),encoding='utf8')
(out/'scoped-changes.diff').write_text(diff,encoding='utf8')
paths=[p for _,p in pairs]+[c/'docs/dbgrid/columns.md']
(out/'source-sha256.json').write_text(json.dumps({str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in paths},indent=2),encoding='utf8')
bins=[]
for n in ['MaxxRural.exe','ApiTestes.exe']:
    p=r/'EXE'/n
    bins.append({'path':str(p),'size':p.stat().st_size,'modified':datetime.datetime.fromtimestamp(p.stat().st_mtime).isoformat(),'sha256':hashlib.sha256(p.read_bytes()).hexdigest()})
(out/'executaveis.json').write_text(json.dumps(bins,indent=2),encoding='utf8')
readme='''# TDACDBGrid: colunas fixas — 21/10/2026

## Entrega

- `TDACDBGridColumn.PinPosition`: dgpNone (padrão compatível com DFMs existentes), dgpLeft, dgpRight. Configurável no Object Inspector e por código. Assign e streaming preservam a propriedade.
- Seleção interna Boolean, quando habilitada, permanece à esquerda. Colunas fixas à esquerda aparecem depois dela. Colunas fixas à direita ficam antes da barra vertical. A ordem dentro de cada grupo segue a coleção, mesmo quando o Index da coluna muda ou um layout antigo é carregado.
- As três grids do DFM de Movimento Bancário receberam PinPosition=dgpRight em LayoutKey=OPCOES. Este é o único delta do DFM nesta entrega: três linhas. Não se adicionou checkbox/novo campo à View consumidora nem se alteraram operações financeiras.
- O marcador verde de seleção da linha fica na borda esquerda, independente da primeira coluna de dados e de sua posição horizontal. A inspeção pelo mouse mostrou que esse marcador antes desaparecia ao rolar a primeira coluna para fora; esse caso ganhou uma regressão própria.
- Cabeçalhos, textos Windows, badges, hover, foco e ações têm recorte por faixa. O hit test e as dicas usam os limites visíveis; conteúdo central encoberto não responde. Ações precisam caber inteiras para serem desenhadas/ativadas. F2 acessa ações fixas sem rolar o centro.
- Largura insuficiente é tratada com recorte, preservando as larguras configuradas e priorizando seleção/faixa esquerda. Não há controles por registro.

## Decisões técnicas

A VCL mantém a interação e a barra nativa. O viewport lógico reserva as faixas fixas; suas colunas mantêm Width real e extensão nativa rolável zero. GetClientRect/ClientWidth representam esse viewport lógico. FullClientRect expõe os limites físicos e ScrollableRect a faixa central. A pintura Skia continua completa e o texto continua na infraestrutura Windows existente, agora com clips por item.

Redimensionamento e arraste com colunas fixas usam a geometria exibida e identidades estáveis. Cabeçalhos só se movem dentro do mesmo grupo. Teclado segue a ordem visual dos grupos. Coluna central maior que o viewport pode rolar por pixels; limites/range da barra são atualizados sem acessar campos privados da VCL.

As larguras fixas recebem a escala VCL explicitamente, pois sua extensão nativa é zero. O cálculo de tri-state e a marcação de seleção preservam a posição horizontal. Estado transitório de interação é cancelado em rolagem, troca de registro, perda de captura/foco e desabilitação. O buffer auxiliar de clips pertence à grid e é liberado na destruição. PinPosition é uma configuração do componente; não é sobrescrito pelo layout de usuário (ordem, largura e visibilidade).

Documentação de uso: `DAC-DelphiComponents/docs/dbgrid/columns.md`.

## Testes automatizados efetivamente executados

ApiTestes oficial: **276 aprovados**, zero falhas/erros/ignorados/vazamentos reportados (`apitestes-todos.log/xml`). A execução completa usou banco Firebird novo e isolado via executar-testes.ps1; testes de UI usam datasets locais. Nenhum projeto avulso foi criado.

Foram acrescentados 14 casos ao fixture de colunas (agora 57 casos na suíte final):

- seis comparações pixel a pixel das duas faixas fixas antes/depois da rolagem central, com texto longo, seleção e ações; temas claro/escuro e 96/144/192 PPI;
- ações por clique após scroll e mudança de índice, hover/dicas, desabilitada/oculta, cancelamento ao rolar, F2/Enter e contexto de COD_EMP/MOV_COD;
- Assign, DFM antigo/novo, largura, layout, ocultar/restaurar e recriar handle;
- clique/alternância do cabeçalho, Opções sem ordenar, arraste e redimensionamento da coluna fixa;
- checkbox Boolean à esquerda: selecionar outro registro depois da rolagem, marcar, selecionar todos e preservar viewport;
- janela estreita, dataset vazio/fechado, botões sem espaço sem hit area;
- navegação por teclado respeitando a ordem física mesmo com Index alterado;
- rolagem até o final de uma coluna central de 2000 pixels e dica integral para conteúdo recortado;
- marcador da linha selecionada fixo à esquerda mesmo com Opções no índice zero e conteúdo central rolado.

Os testes existentes verificam a leitura dos três blocos DFM reais, eventos, ordenação, hover, foco, estado das grids e quantidade de controles independente da quantidade de registros. A leitura dos três blocos reais agora também exige PinPosition=dgpRight em OPCOES. O fixture direcionado intermediário passou 56/56 (`colunas-direcionado-56.*`); a suíte final de 276 inclui também o novo caso do marcador e a asserção final da dica recortada.

O projeto existente DACDBGridTests também passou por Rebuild e execução (`component-tests.log`: PASS, incluindo streaming com 11 colunas, ciclo de vida e persistência).

## Compilações efetivamente executadas

MSBuild /t:Rebuild, Debug/Win32, Delphi 10.2 / dcc32 32.0:

- ApiTestes.dproj: aprovado (`build.log`).
- MaxxRural/MaxxADM/MaxxRural.dproj: aprovado (`build-desktop.log`), com warnings/hints existentes do projeto, sem erros.
- DACSkiaComponentsRuntime.dpk, DACSkiaComponentsDesign.dpk e DACSkiaComponents.dpk: aprovados (`build-runtime.log`, `build-design.log`, `build-package.log`).

Sem alterar IDE ou dproj. Os scripts dos pacotes e do teste do componente estão em `DAC-DelphiComponents/tmp/dbgrid-columns-20261020/build-{runtime,design,package,existing-tests}.cmd`; saídas isoladas em tmp. Os scripts do consumidor ficam nesta pasta. Executáveis oficiais preservados em EXE (executaveis.json). O pacote design-time foi compilado; a IDE aberta ainda precisa recarregar o pacote atualizado para reconhecer a nova propriedade.

## Inspeção visual efetivamente executada

Computer Use, janela TDACGridHostForm do ApiTestes, com o subtree real TDACTabs/TDACDBGrid do DFM. Dois registros locais em Prontos, tema claro na escala do desktop. Capturas exibidas na conversa.

1. Estado inicial: Opções aparece à direita com os três botões.
2. Arraste do thumb horizontal até o fim: Tipo/Dt.Conc./Cheque/Complemento aparecem no centro, Opções permanece na mesma posição e o marcador verde permanece na esquerda. Sem texto sobre os botões e sem linhas residuais na área vazia.
3. Clique em Detalhes da segunda linha: registro 0000000002, foco=True, acoes=1. A posição da faixa fixa foi preservada.
4. Retorno do thumb ao início: colunas iniciais reaparecem, segundo registro continua selecionado e os botões ficam no mesmo lugar.
5. F2 não moveu o centro; Enter mudou o contador somente para acoes=2, mantendo o registro 0000000002.
6. Janela sintética encerrada pelo X. `qa-mouse.log/xml`: 4/4; no caso Prontos o ramo manual substitui as asserções automáticas durante a pausa, que foram executadas na suíte completa. As outras páginas executam normalmente.

O checkbox de seleção foi validado por testes automatizados com campo Boolean; o DFM real não habilita esse checkbox. A inspeção manual da tela real confirmou o marcador de seleção da linha. Não se declara inspeção manual do tema escuro nem de DPI diferentes do desktop.

## Limites e rastreabilidade

A tela operacional autenticada e serviços reais não foram homologados. As evidências visuais são do fixture com DFM real e dados locais. Reinstalação/recarregamento do pacote na IDE não foi executado. Não houve commit.

Fontes Delphi e DFM preservados em CP1252/CRLF. format-checks.json confirma delta exclusivo de três linhas no DFM. scoped-changes.diff compara os snapshots desta entrega; source-sha256.json identifica os fontes finais; executaveis.json identifica os binários oficiais.

Auditoria estática da skill: 268 arquivos, 32 registros/desregistros de hooks e 15 famílias. Oito avisos TODO preexistentes em outros trechos/snapshots; isso não substitui homologação funcional. Relatório audit.json. Alterações anteriores foram preservadas. Componentes em main; consumidor em feature/movimentobancario-api.
'''
(out/'README.md').write_text(readme,encoding='utf8')
p=r/'source/README.md'; b=p.read_bytes(); key=b'## Colunas fixas da TDACDBGrid'
if key not in b:
    entry='''

## Colunas fixas da TDACDBGrid — 21/10/2026

TDACDBGridColumn.PinPosition permite fixar colunas à esquerda/direita, com
recorte de cabeçalhos, textos e ações. A seleção interna, quando habilitada,
fica à esquerda; o marcador de seleção da linha também permanece nessa borda.
As três colunas OPCOES do Movimento Bancário usam dgpRight. O conteúdo central
rola entre as faixas fixas, sem sobreposição ou hit areas encobertas.

Assign, DFM antigo/novo, layout, escala, mouse, teclado, checkbox Boolean,
coluna larga e janela estreita foram exercitados no ApiTestes oficial.
Suíte completa: 276 testes aprovados. Rebuilds do ApiTestes, MaxxADM e pacotes
runtime/design/compatibilidade aprovados. Executáveis em EXE.
Mouse real no fixture com DFM real confirmou Opções fixa, marcador à esquerda,
arraste de ida/volta e ativação única por clique/F2+Enter. Homologação da tela
operacional autenticada e recarregamento do pacote na IDE permanecem pendentes.
Evidências: `MaxxRural/src/Tests/Resultados/20261021-grid-pinned/README.md`.
'''
    try: b.decode('utf8'); enc='utf8'
    except UnicodeDecodeError: enc='cp1252'
    p.write_bytes(b+entry.replace('\n','\r\n' if b'\r\n' in b else '\n').encode(enc))
print(out)
