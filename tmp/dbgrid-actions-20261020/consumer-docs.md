## Ações nas grids — 20/10/2026

As três colunas `OPCOES` têm largura 196 e uma coleção `Actions` no DFM:
`detalhes` com texto e largura 80; `editar` com `mikEdit`; `excluir` com
`mikTrash` e aparência `daaDanger`. As dicas são individuais e `ShowHint=True`.
Cada grid declara `ActionKeyFields='COD_EMP;MOV_COD'` e os eventos
`GridAcaoEstado`/`GridAcaoExecutar`.

A grid fornece um snapshot dos valores e da chave composta, sem `RecNo`,
bookmark ou referência a buffer/registro. A View consulta as disponibilidades
fornecidas pelo Controller e encaminha a intenção de ativação. O Controller
consulta o Service, que limita a intenção à empresa correspondente e a um código
de movimento preenchido. O Controller guarda somente valores da última intenção
e devolve uma mensagem informativa à View. Nenhum DAO é chamado nesse percurso.

Esta entrega habilita a **intenção visual**. Não representa autorização para
operações financeiras: não consulta detalhes, não edita e não exclui lançamentos.
As regras e permissões dessas operações continuam fora desta etapa e deverão
ser aplicadas no Service quando implementadas. A grid não conhece essas regras,
API, DataSnap ou autenticação.

F2 entra nas ações; setas e Tab/Shift+Tab percorrem as ações habilitadas; Enter
ou Espaço ativa uma vez por pressionamento; Esc retorna à navegação da grid.
O botão padrão do formulário não recebe Enter enquanto a grid está nesse modo.
Os botões respeitam o tema, a altura da linha e a largura da célula. Se um layout
antigo deixar a coluna estreita, ações que não cabem integralmente ficam fora da
apresentação e da interação; alargar/restaurar o layout as disponibiliza novamente.

Rebuilds Debug/Win32 do `ApiTestes` oficial e do MaxxADM concluídos, sem alterar
configurações dos projetos ou da IDE. O script dos testes acrescenta os diretórios
de fontes do componente apenas à invocação do MSBuild. Executáveis permanecem em
`EXE/ApiTestes.exe` e `EXE/MaxxRural.exe`.

Suíte completa: **195 testes aprovados**, zero falhas, erros ou vazamentos
reportados pelo executor. Foram acrescentados 19 casos para ações da grid e dois
para Controller/Service sem acesso ao DAO. Incluem rolagem, ordenação, clique em
linha não selecionada, chave composta, visibilidade/habilitação por registro,
carregamento/vazio/cabeçalho, teclado, repetição, duplo clique, cancelamento,
redimensionamento, recriação de handle, destruição de DataSource, `Assign`,
identificadores estáveis, layout JSON e quantidade de controles de 80 a 1000
registros. Os fixtures de banco preexistentes usam arquivos Firebird novos e
isolados, criados pelo script de execução, sem usar a base operacional.

Os blocos reais das três grids do DFM foram carregados, gravados e relidos em
execução. A referência externa ao DataSource é removida somente nesse fixture
isolado; handlers compatíveis resolvem os nomes de eventos. Compilação e esse
teste não equivalem à abertura do formulário completo.

Evidências e scripts reproduzíveis:
`MaxxRural/src/Tests/Resultados/20261020-grid-acoes/README.md`.
As capturas nativas nos temas claro/escuro foram inspecionadas. A homologação
visual do formulário completo, do Object Inspector e de DPI físico diferente
do ambiente de execução permanece pendente. Não houve instalação/troca do BPL
da IDE nem execução de operações financeiras.
