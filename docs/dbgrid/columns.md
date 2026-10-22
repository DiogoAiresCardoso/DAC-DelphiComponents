# Colunas, hover e ordenação da TDACDBGrid

## Configuração

| Propriedade | Comportamento |
| --- | --- |
| `LayoutKey` | Identidade estável para ordem, largura, visibilidade e ordenação. Use chaves únicas; `FieldName` é o fallback. |
| `Sortable` | Autoriza pedidos de ordenação. Uma coluna sem campo, memo/blob ou campo calculado não gera pedidos. |
| `AllowFocus` | Padrão `True`. Com `False`, a coluna não recebe o foco individual de célula nem seu contorno. A navegação por células ignora colunas bloqueadas; a seleção da linha, o hover, a ordenação e os botões de ação continuam disponíveis. |
| `PinPosition` | `dgpNone` (padrão), `dgpLeft` ou `dgpRight`. Reserva uma faixa fixa para a coluna no lado escolhido. As demais colunas rolam somente na faixa central. |
| `MinWidth` | Largura mínima lógica a 96 PPI, padrão 16. Aplica-se ao código, ao gesto de redimensionar e à restauração do layout. `Width` continua sendo a largura física nativa da VCL. |
| `Alignment`, `Title.Alignment` | Alinhamentos independentes do conteúdo e do título. |
| `Hint`, `TitleHint` | Dicas da célula e do cabeçalho. Com `Hint` vazio, conteúdo truncado tem dica automática; memos mantêm o texto integral e suas quebras. Com `TitleHint` vazio, a dica usa o título. Requer `ShowHint=True`. |
| `UserHideable` | Restringe ocultação pela API `SetColumnVisible` e pelo layout salvo. Não impede o desenvolvedor de configurar `Visible` diretamente. A API preserva ao menos uma coluna visível. |

DFMs existentes sem as novas propriedades continuam carregáveis. `Column.Assign`
e `Columns.Assign` copiam as propriedades adicionais, badges e ações.

O texto das células continua no renderer nativo Windows/VCL. Conteúdo longo
recebe reticências, sem reduzir a fonte. A dica permite ler seu conteúdo integral.
As superfícies, bordas, indicadores e ícones usam Skia e os tokens do tema.
Métricas visuais e larguras persistidas seguem a escala aplicada pela VCL.

## Colunas fixas

Configure `PinPosition` no editor de `Columns` do Object Inspector ou por código:

```pascal
ColunaOpcoes.PinPosition := dgpRight;
ColunaOpcoes.Sortable := False;
ColunaOpcoes.AllowFocus := False;
```

A coluna interna `Selection`, quando habilitada com um campo Boolean, fica
sempre na borda esquerda. Colunas com `dgpLeft` vêm depois dela; `dgpRight` ocupa
a borda direita, antes da barra vertical. A ordem dentro de cada grupo segue a
coleção. Movimentar `Index` ou restaurar um layout não muda o lado configurado.
O marcador verde da linha selecionada também fica na borda esquerda da grid,
mesmo quando a primeira coluna de dados está fora da área visível.
O fundo e o separador horizontal de cada linha preenchem toda a área cliente,
incluindo a sobra entre a última coluna rolável e a faixa fixa. Seleção, zebra
e estado desabilitado permanecem contínuos. Essa sobra mantém o cursor padrão
e não acrescenta botões ou amplia as áreas de ação das células.
O arraste de cabeçalhos move colunas dentro do mesmo grupo. Nas três grids do
Movimento Bancário, a coluna `LayoutKey='OPCOES'` usa `dgpRight`.

Cabeçalhos, textos nativos, badges, foco, hover e botões são recortados na faixa
da própria coluna. O mesmo retângulo visível determina cliques e dicas: conteúdo
central encoberto não recebe interação. `F2` pode acessar ações fixas sem mudar
a posição horizontal do conteúdo. A navegação por células segue a ordem visual
dos grupos. As colunas fixas são redimensionáveis pelo separador interno; na
borda esquerda de uma coluna fixa à direita, arraste para a esquerda para alargá-la.

O componente reserva as larguras fixas no viewport lógico usado pela VCL, sem
incluir essas larguras na extensão rolável. `Width` da coluna continua sendo sua
largura física real, escalada pelo DPI. Para consultar os limites físicos da
janela cliente use `Grid.FullClientRect`; `Grid.ScrollableRect` retorna a faixa
central. Com colunas fixas, `ClientWidth` representa o viewport lógico nativo.
O tratamento de coluna central mais larga que o viewport permite rolagem por
pixels até o final do conteúdo sem deslocar as colunas fixas.

Se a janela não comportar as larguras configuradas, as faixas são recortadas sem
se sobrepor; seleção e colunas fixas da esquerda têm prioridade. Botões sem
espaço para aparecer inteiros não são desenhados nem ativados. O componente
preserva as larguras configuradas e não cria controles por registro.

`Assign` e streaming DFM preservam `PinPosition`. DFMs anteriores assumem
`dgpNone`. O arquivo de layout do usuário continua armazenando ordem, largura e
visibilidade; o lado fixo é uma configuração do componente e não é sobrescrito
por layouts antigos.

## Hover, seleção e interação

Cabeçalho, célula e botão têm hit tests distintos. O hover de uma célula não
destaca as demais colunas da linha. Seleção e foco continuam visíveis: a seleção
mantém seu fundo e recebe contorno no hover; a célula focada tem contorno próprio.

A pintura compõe superfícies/ícones Skia e os textos nativos em um mesmo DIB
persistente fora da tela. O texto continua usando o renderer Windows existente,
com as mesmas fontes, alinhamentos e recortes. Só depois de concluir ambas as
camadas, o buffer apresenta a imagem completa ao destino em uma transferência;
o fundo sem texto não é exposto entre mudanças de hover. Isso também vale quando
o buffer da VCL está desligado, como nas colunas fixas cujo viewport lógico é
menor que a área física a pintar. Não é necessário configurar outra propriedade.
O buffer pertence à grid, reutiliza seu DC/bitmap, recria-os ao mudar de tamanho
e libera os recursos na destruição, depois da superfície Skia.

O fixture oficial de colunas inclui leitura concorrente de pixels do HWND durante
100 mudanças de hover em cada cenário: temas claro/escuro, 96/144/192 PPI com
Opções fixa e também sem buffer VCL/sem colunas fixas a 96 PPI. Verifica que um
pixel real do título não desaparece enquanto a célula muda de hover. Há ainda
verificação de contagem GDI ao redimensionar o buffer 100 vezes e destruí-lo.
Evidências da reprodução e correção em
`MaxxRural/src/Tests/Resultados/20261021-grid-hover-flicker/` no consumidor.

Para selecionar apenas a linha, configure `RowSelectionEnabled=True` na grid e
`AllowFocus=False` nas colunas. O controle mantém o foco de teclado e uma coluna
interna como âncora para navegar pelos registros; essa âncora não representa foco
individual em uma coluna bloqueada. Todas as colunas podem ter `AllowFocus=False`.
As setas verticais continuam navegando pelos registros. Em navegação por células
(`RowSelectionEnabled=False`), setas horizontais, Home/End e Tab, quando entregue
à grid pela VCL, ignoram colunas ocultas ou bloqueadas. Tab/Shift+Tab avançam ou
recuam um registro ao cruzar as extremidades. O comportamento de Tab entre
controles do formulário continua sujeito às opções nativas da VCL.

```pascal
Grid.RowSelectionEnabled := True;
for I := 0 to Grid.Columns.Count - 1 do
  Grid.Columns[I].AllowFocus := False;
```

`AllowFocus` é configuração do componente, copiada por `Assign` e gravada no DFM;
não é uma preferência sobrescrita pelo arquivo de layout do usuário. Botões em
colunas bloqueadas continuam acessíveis por clique e pelo modo de ações (`F2`),
com indicação própria de foco. DFMs antigos mantêm `AllowFocus=True`.

O cabeçalho ordenável e a ação habilitada usam cursor de mão; a borda de
redimensionamento usa o cursor de dimensionamento. Ações desabilitadas mantêm
cursor padrão. O estado é recalculado mesmo quando a habilitação muda sob o
mesmo ponto do mouse.

Movimentação, redimensionamento, rolagem, mudança de registro, ocultação,
desabilitação, saída do mouse e perda de interação limpam o hover anterior.
Apenas transições de célula/ação invalidam as regiões de hover. A VCL continua
responsável pelos gestos de movimentação e dimensionamento das colunas.

A composição Skia e os textos nativos formam um quadro completo. Antes do
`BeginPaint` de uma pintura normal, a grid amplia a região invalidada para toda
a área cliente, sem apagar o fundo. Isso recompõe também os pixels reaproveitados
pelo `ScrollWindowEx` da VCL, inclusive ao rolar dentro de uma coluna maior que a
janela. A pintura continua usando o buffer e não cria controles por registro.

O pedido de ordenação exige pressionar e soltar no mesmo cabeçalho estável,
sem arrasto, dimensionamento ou cancelamento. O segundo clique de um duplo
clique não gera outro pedido. Colunas de ações não ordenam quando configuradas
com `Sortable=False`; cliques dos botões são consumidos pelo fluxo de ações.

## Ordenação tipada

A grid não converte textos exibidos nem conhece consultas da aplicação. Ela
solicita a ordenação e só mostra a direção após a aceitação do handler:

```pascal
procedure TMinhaView.Ordenar(Sender: TObject; AColumn: TColumn;
  const AFieldName: string; ADirection: TDACDBGridSortDirection;
  var AAccepted: Boolean);
begin
  AAccepted := TDACDBGridClientDataSetSort.Apply(MeuBuffer,
    AFieldName, ADirection, 'EMPRESA;CODIGO');
end;
```

Atribua esse método a `OnSortRequest`. O tipo do evento está em
`DAC.Components.Controls.DBGrid.Types`. O adaptador opcional está em
`DAC.Components.Controls.DBGrid.ClientDataSetSort`: aplicações que não usam
`TClientDataSet` podem implementar outro handler. A dependência de DBClient
fica no adaptador, sem adicioná-la ao pacote runtime da grid.

O adaptador usa índices nativos MIDAS, preservando tipos de datas, inteiros,
strings e BCD/FMTBCD. Não passa por `DisplayText`, `Float` ou conversão de códigos
para inteiros. Nulos ficam no início em ordem crescente e no fim em decrescente.
Strings usam comparação sem distinguir caixa, com a colação do MIDAS/locale do
buffer; códigos com zeros à esquerda continuam strings. Não se promete ignorar
acentos nem impor uma colação diferente à aplicação.

Os campos de chave são desempates ascendentes. A posição é preservada por
bookmark local, usado e liberado dentro da chamada. Não se usa `RecNo` como
identidade e nenhum registro fica retido para execução posterior. Os índices
gerados são reutilizados para o mesmo campo/sentido/chave.

Um `TDACDBGridClientDataSetSortSource` auxiliar pertence ao dataset e limpa apenas
o nome de índice temporário do adaptador quando o buffer fecha. Isso permite
reabrir o pacote de dados sem apontar para um índice que deixou de existir.
Esse datasource não cria controles, não substitui eventos da aplicação e é
liberado pelo ownership do dataset.

O ciclo do cabeçalho é crescente → decrescente → crescente. `Ctrl+Enter` ordena a
coluna selecionada pelo mesmo fluxo; a grid solicita essa tecla ao gerenciador
de diálogo. `RequestSort(ColumnIndex, Direction)` permite o pedido por código;
devolve `False` se não houver handler, a coluna não for elegível, o dataset
estiver fechado/editando, a grid estiver desabilitada/carregando ou o handler
recusar. `dgsNone` permite remover o índice no adaptador. `SortKey` e
`SortDirection` expõem somente o estado aceito.

## Persistência e mudanças de estrutura

O JSON conserva o formato anterior e acrescenta `sortFieldName`, opcional na
leitura. A ordenação é associada à chave **e** ao campo: trocar o campo de uma
coluna não transfere silenciosamente a ordenação anterior. Trocar/fechar/destruir
o dataset também limpa o indicador antigo.

`LoadLayout` descarta o autosave pendente antes da leitura. Ele não grava o
layout transitório por cima do que deveria carregar. A restauração solicita a
ordenação real pelo mesmo evento; sem aceitação não há indicador fictício.
Quando carregado com dataset fechado, o pedido pode aguardar sua ativação.

Chaves removidas do layout são ignoradas; colunas conhecidas mantêm sua ordem
salva e colunas novas ficam ao final. Larguras respeitam `MinWidth`, a escala e
as regras de ocultação. `ResetLayout` conserva o snapshot inicial e remove a
ordenação pelo handler quando aplicável. Configurações de ações continuam no
DFM/código e não são substituídas pelo JSON.

No MaxxRural, `GridOrdenar` atende os três buffers de Movimento Bancário com o
adaptador local. `OPCOES` tem largura 196, mínimo lógico 176 e `Sortable=False`;
`MOV_HISTCOMPL` também não ordena por ser memo. Não há consulta ou operação
financeira nesse fluxo de apresentação.

No formulário base legado do MaxxRural, a inicialização fora do modo de edição
deve preservar a navegação de todos os descendentes de `TCustomDBGrid`. A regra
compartilhada `TGridInteracao.RestaurarNavegacao`, em `Geral/uGridInteracao.pas`,
faz essa distinção depois do estado genérico dos editores. Isso evita deixar
uma `TDACDBGrid` visível, mas desabilitada para foco, clique e scroll. Essa é
uma política da aplicação; o componente continua respeitando `Enabled=False`.

## Evidência e limites

Os testes de integração estão no ApiTestes oficial do MaxxRural:
`Teste.MovimentoBancario.ColunasGrid.pas`, com o helper compartilhado
`TestSupport.DACDBGridActions.pas`. Casos anteriores de ações continuam ativos.
Há mensagens nativas de mouse, métodos de teclado da VCL, verificação de
`WM_GETDLGCODE`, índices reais, layout em arquivo e streaming DFM em execução.

Os PNGs são capturas `PaintTo` da grid real, com Skia e texto nativo, em temas
claro/escuro. As métricas de 96/120/144/192 PPI são exercitadas por uma subclasse de
teste e `ChangeScale`; não representam três monitores físicos. Os três blocos
reais de grid do DFM são lidos, gravados e relidos; o formulário completo e suas
dependências externas não são instanciados nesses fixtures.

Os resultados reproduzíveis e os Rebuilds ficam em
`MaxxRural/src/Tests/Resultados/20261020-grid-colunas/` no repositório consumidor.
Homologação manual do formulário completo, designer/Object Inspector e mudança
entre monitores físicos continuam separadas desses testes automatizados.

## Performance com muitos registros

O ApiTestes oficial também contém `Teste.MovimentoBancario.PerformanceGrid.pas`.
O benchmark lê em execução cada bloco de grid do DFM de Movimento Bancário,
conserva as 12 colunas e as três ações fixas à direita e associa um
`TClientDataSet` local com 1.001, 5.000 ou 10.000 registros. Há referência com
100 registros e cenários adicionais com checkbox de seleção uniforme.

São medidas separadamente a carga do dataset, associação com primeira pintura,
pintura aquecida, rolagem vertical, alternância entre os extremos horizontais,
hover, saltos ao meio/fim, clique em Detalhes e ordenação de valores monetários.
Cada operação repetida tem 60 amostras; a medição usa `TStopwatch` até o retorno
de `UpdateWindow` do HWND real. As asserções de identidade da chave composta,
ativação única e quantidade de controles ficam fora do intervalo cronometrado.
O teste também registra consultas de estado por pintura, working set e objetos
GDI/USER. Não aplica limites de milissegundos dependentes da máquina como
asserções funcionais.

No consumidor, `MaxxRural/src/Tests/Resultados/20261021-grid-performance/`
contém os scripts `compilar.cmd` (Rebuild), `executar-performance.ps1` (três
rodadas) e `consolidar.py`, além dos JSONs, CSV, XMLs e relatório com o ambiente
medido. `DAC_GRID_PERF_OUTPUT_DIR` permite escolher a saída dos JSONs ao executar
o fixture pelo ApiTestes. O runner restaura a variável ao terminar.

Essas medições cobrem processamento síncrono da grid em tema claro/96 PPI e
viewport fixo. Não medem FPS de apresentação do desktop, latência da API ou
homologação manual da tela operacional. Com seleção por checkbox, o cálculo
atual do estado global pode percorrer todos os registros quando os valores
são uniformes; os cenários adicionais permitem acompanhar esse custo.
