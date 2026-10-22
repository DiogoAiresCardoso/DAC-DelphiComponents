from pathlib import Path
r=Path(r'M:/MaxxSoft/MaxxRural/Desktop/maxxrural');p=r/'source/README.md';s=p.read_text(encoding='utf-8')
s=s.replace('As três colunas `OPCOES` têm largura 196 e uma coleção `Actions` no DFM:', 'As três colunas `OPCOES` têm largura 196, mínimo lógico 176 e uma coleção `Actions` no DFM:')
s=s.replace('Os botões respeitam o tema, a altura da linha e a largura da célula. Se um layout\nantigo deixar a coluna estreita, ações que não cabem integralmente ficam fora da\napresentação e da interação; alargar/restaurar o layout as disponibiliza novamente.', 'Os botões respeitam o tema, a altura da linha e a largura da célula. A revisão de colunas aplica o mínimo lógico 176 também aos layouts antigos, com espaço para os três botões e arredondamento em escalas fracionárias.')
s+='''

## Colunas, hover e ordenação — 20/10/2026

As três grids declaram `OnSortRequest=GridOrdenar`. Esse handler da View ordena
somente seus buffers locais por índices tipados do adaptador opcional
`TDACDBGridClientDataSetSort`; o fluxo de consulta/carga continua pertencendo ao
Controller/Service. Não há operação financeira nova nessa ordenação visual.
O bookmark local preserva o registro selecionado. As chaves de desempate são
`COD_EMP;MOV_COD`; códigos continuam strings e `MOV_VALOR` mantém FMTBCD.
`OPCOES` e o memo `MOV_HISTCOMPL` têm `Sortable=False`.

O clique alterna crescente/decrescente; Ctrl+Enter ordena a coluna selecionada.
Arrasto e redimensionamento não ordenam, e os botões mantêm o fluxo exclusivo de
ações. Hover de cabeçalho, célula e botão é independente; seleção e foco continuam
identificáveis. Dicas permitem ler textos truncados, incluindo memos com quebras.
Layouts conservam chaves estáveis, mínimo escalado e configuração de ações do DFM.
A restauração só exibe uma direção após ordenar de fato pelo handler.

A suíte oficial ApiTestes executou **231 testes aprovados**, incluindo 34 casos
novos de colunas, sem falhas, erros ou ignorados. Casos anteriores de ações,
streaming dos datasets e Controller/Service continuam ativos. Os três blocos
reais de grid do DFM foram lidos, gravados e relidos em execução, com handlers
compatíveis e buffers de teste. Não houve projeto de teste avulso.

Rebuilds Debug/Win32 do ApiTestes, MaxxADM e pacotes do componente concluídos por
linha de comando. Os executáveis do consumidor permanecem em `EXE`. Fontes
Delphi preservadas em Windows-1252/CRLF; configurações de projeto/IDE preservadas.

Foram revisadas capturas nativas da grid nos temas claro/escuro, com métricas de
96/120/144/192 PPI. As métricas são aplicadas pelo fixture; não equivalem a troca
real entre monitores. A homologação manual do formulário completo, do designer e
da interação contínua permanece pendente. Não houve consulta de detalhes,
edição, exclusão ou novas chamadas ao DAO.

Relatório, logs, XML, scripts e capturas:
`MaxxRural/src/Tests/Resultados/20261020-grid-colunas/README.md`.
Documentação do componente: `docs/dbgrid/columns.md` e `docs/dbgrid/actions.md`.
'''
p.write_text(s,encoding='utf-8',newline='\n')
print('Estado atual documentado em source/README.md.')
