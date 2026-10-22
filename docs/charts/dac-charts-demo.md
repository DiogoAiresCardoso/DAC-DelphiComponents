> **Estado atual — 23/09/2026:** consulte a [consolidação atual](consolidation-2026-09-23.md) para API tipada, validação transacional, espaço do título e evidências posteriores. O conteúdo abaixo preserva sua etapa histórica.

# DAC Charts Demo

> Histórico do demo anterior à galeria reconstruída. Para desenvolvimento e uso
> atuais, consulte o [manual consolidado](README.md), o [capítulo de operação](manual/07-demo-operacao.md)
> e o [README do executável](../../demo-charts/README.md). Os cenários e a API descritos
> abaixo não devem substituir as fixtures e a API Options atuais.

`demo-charts\DACChartsDemo.dproj` e um aplicativo VCL exclusivo para a
validacao visual de `TDACChart`. Ele nao referencia o Demo principal e nao
possui BPL proprio. O executavel e gerado em
`Build\Exe\Win32\<Config>\Charts` e as DCUs em
`Build\Dcu\Win32\<Config>\DACChartsDemo`.

## Cenários

1. barras solidas;
2. barras com gradiente linear de 0 graus;
3. barras com gradiente linear de 90 graus;
4. barras com gradiente radial;
5. linha com uma lacuna nula;
6. area com valores negativos e zero;
7. composicao de barra, linha e area com tooltip por eixo exibindo as tres series;
8. pie com legenda individual por fatia e tooltip;
9. doughnut radial com legenda individual por fatia;
10. barras, linha e area data-aware via `TClientDataSet` com tooltip por eixo;
11. linha data-aware;
12. area data-aware contendo campo nulo;
13. categorias longas e margens configuradas;
14. eixo temporal;
15. estado vazio manual;
16. alternancia explicita entre `cdmManual`, `cdmDataSource` e `cdmAuto`;
17. barras com gradiente linear de 180 graus;
18. doughnut sem valores positivos.

O cabecalho oferece `Atualizar valores`, que altera simultaneamente pontos
manuais e um registro do `TClientDataSet`, a chave `Animacao` e listas para
duracao (180, 360 ou 600 ms) e easing. Todos os cenarios demonstram a
atualizacao automatica pelo mesmo cache do chart, incluindo fontes manual e
data-aware.

O botao de modo opera somente o grafico 16 e permite validar que as colecoes
manuais e a origem `TClientDataSet` permanecem separadas para cada `DataMode`.
O botao de tema permite revisar todas as superfícies em claro e escuro.
