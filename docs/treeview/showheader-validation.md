# ShowHeader: TDACDBTreeView e TDACTreeView

Ajuste executado em 31/10/2026 no projeto oficial DAC-DelphiComponents,
branch `codex/treeview`, para Delphi 10.2 Tokyo/Win32.

## Contrato e implementacao

As duas classes publicam `ShowHeader: Boolean`, com `default True` e
inicializacao correspondente no construtor. `False` e gravado/restaurado pelo
DFM; `True` pode ser omitido. Exemplo no consumidor:

```delphi
arvPlanos.ShowHeader := False;
```

A opcao pertence a cada instancia e e propagada ao painter compartilhado.
Nao modifica `TDACDBTreeTokens.HeaderHeight`: esse token continua definindo
a altura nominal de um cabecalho visivel.

Com `False`, o layout fornece `HeaderRect.Height = 0` e `ContentRect.Top`
imediatamente apos a borda. O bloco inteiro de pintura do cabecalho e omitido,
incluindo fundo, texto e divisor inferior. Layout, pintura, hit-test, hints,
selecao, pagina e barras de rolagem usam a mesma geometria.

O setter recalcula limites de rolagem e visibilidade da linha atual, sem
reconstruir hierarquia/projecao, navegar ou reler o dataset. Selecao, marcas,
expansao e busca sao preservadas. `TitleHint` so e aplicavel com o cabecalho
visivel; os hints das celulas permanecem disponiveis.

Os exemplos independentes e as duas paginas da galeria oficial oferecem
**Exibir titulos** para alternar a propriedade. A configuracao inicial continua
com o cabecalho visivel.

## Compilacao

`./tools/test-treeview.ps1` compila as dependencias Skia localmente, pacotes
runtime, design-time e combinado, as duas arvores e seus painters, testes,
exemplos independentes e a galeria oficial. Artefatos ficam sob `Build`.

Foram compilados os tres pacotes e todos os executaveis citados. O compilador
utilizado foi o dcc32 32.0 do Delphi 10.2 Tokyo. O componente e o painter nao
receberam dependencias de dominio financeiro nem do MaxxRural.

## Testes automatizados

| Executavel | Verificacoes | Falhas |
| --- | ---: | ---: |
| DACTreeViewHeaderTests | 365 | 0 |
| DACDBTreeViewTests | 202 | 0 |
| DACDBTreeViewPainterTests | 116 | 0 |
| DACTreeViewTests | 224 | 0 |
| DACTreeViewPainterTests | 140 | 0 |
| Total | 1.047 | 0 |

O teste especifico cobre ambos os controles e painters:

- Default `True` e geometria anterior; `False` e omissao de `True` no DFM.
- Recarga sem Parent e primeiro paint do controle efetivamente desserializado,
  com pixel sem fundo de cabecalho e primeira linha junto a borda.
- Hit-test da primeira linha, expansor, checkbox e corpo; ultima linha nos
  limites de rolagem; alinhamento das colunas com deslocamento horizontal.
- Pagina, limites e posicao dos thumbs com ambos os valores, inclusive
  controles menores que uma linha/cabecalho.
- Hints de titulo apenas quando visiveis e hints de celulas nos dois modos.
- Marcacao, expansao, selecao, setas, espaco, Enter e comportamento anterior
  de duplo clique sem alteracoes.
- Selecao fora da busca, marcacoes, expansao e SearchText preservados na
  alternancia; ultima linha atual completamente visivel apos mudar a pagina.
- `DataReadCount` e `LoadCount` constantes durante alternancia, pintura e
  recriacao de handle.
- Instancias simultaneas com valores opostos, csDesigning sem Parent,
  criacao/liberacao repetida e recriacao de handles.
- Renderizacao nos temas claro/escuro e DPI logico 96/144/192, com texto longo.

Tambem passaram as regressoes existentes de smoke, interacao e ciclo de vida,
e a inicializacao da galeria. Esta ultima confere a ligacao dos dois novos
checkboxes de exemplo com a propriedade.

Logs: `Build/TreeView/HeaderTests/build.log` e `results.log`; os demais alvos
usam subpastas equivalentes. O teste especifico gera 24 PNGs em
`Build/TreeView/HeaderTests/Evidence`.

## Conferencia visual e entrada nativa

O teste `DACTreeViewPhysical` foi estendido para executar a mesma sequencia
com `ShowHeader=True` e `False` na pagina TreeView da galeria oficial. Resultado:
**138 verificacoes, zero falhas**. Verificou foco Windows efetivo, setas,
espaco, Enter sem duplicacao, Tab/Shift+Tab, clique real no checkbox e evento
que atualiza o objeto do consumidor.

O sandbox recusou SendInput com erro 5. A execucao autorizada fora dele passou,
com todas as entradas limitadas a janela do proprio executavel de teste.

Capturas inspecionadas:

- `Build/TreeView/Physical/official-tree-header-true.png`.
- `Build/TreeView/Physical/official-tree-header-false.png`.
- Imagens offscreen dos dois painters, em particular as amostras sem
  cabecalho em tema escuro/192 DPI e claro/144 DPI.

A captura sem cabecalho mostra a primeira linha imediatamente apos a borda,
sem faixa vazia nem sobreposicao. Os titulos voltam ao reabilitar a opcao.
Colunas, indentacao, checkboxes, foco e texto permanecem alinhados.

## Limites da validacao

O sistema estava em 144 DPI, mas a galeria renderizou em 96 DPI, segundo a
politica existente do processo hospedeiro. Os cenarios 144/192 DPI foram
executados como renderizacao offscreen, sem validacao fisica nessas escalas.
A entrada nativa estendida cobriu a pagina TDACTreeView; TDACDBTreeView foi
coberto por testes automatizados de controle/painter e por suas regressoes.

Nao foi instalada manualmente uma nova versao do BPL na IDE. A seguranca do
setter em csDesigning/sem Parent e o streaming foram executados por testes.
As alteracoes pendentes do DateTimePicker e do projeto do pacote foram
preservadas.

Integracao e testes do consumidor MaxxRural pertencem ao **ApiTestes oficial**
e nao foram executados neste ajuste. Estes resultados nao constituem
homologacao da tela de distribuicao financeira.
