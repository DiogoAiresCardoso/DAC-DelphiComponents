# Base ECharts para os gráficos DAC

Levantamento realizado em **22/09/2026**. **Decisão do projeto: ECharts é o padrão oficial para a biblioteca de gráficos.** Como ela ainda não possui consumidores, a API e os DFMs atuais podem ser substituídos sem camada de compatibilidade. A implementação permanece Delphi/VCL/Skia.

Este material é uma especificação de referência. **Não significa que as capacidades catalogadas já estejam implementadas no DAC.** O diagnóstico local está em [validation-2026-09-22.md](../validation-2026-09-22.md).

## Implementação atual

O [registro de 23/09/2026](../consolidation-2026-09-23.md) consolida as alterações
posteriores: API Delphi tipada e proteção local de espaço para título. O contrato
ECharts abaixo permanece fixado; a adaptação local de grid está explicitada no manual.

A implementação e a execução da bancada estão registradas em [implementation-2026-09-22.md](../implementation-2026-09-22.md). A especificação abaixo permanece normativa; não é uma lista de recursos aprovados.

O conhecimento de desenvolvimento, algoritmos, fontes, API, testes e pendências foi
consolidado no [manual técnico central](../README.md). A observação abaixo de que
não houve execução ECharts refere-se à etapa inicial deste levantamento; a bancada
posterior executou os 29 casos e suas [evidências estão preservadas](../evidence/2026-09-22/README.md).

## Como utilizar

1. Consultar a [matriz ECharts → DAC](property-matrix.md) antes de definir propriedades.
2. Seguir os [contratos de geometria e interação](implementation-contracts.md) para implementar os comportamentos.
3. Usar os [casos de referência](reference-cases.json) e o [roteiro de aceite](acceptance.md) para verificar resultados.
4. Consultar as fontes oficiais abaixo quando houver dúvida. Um exemplo visual não substitui o contrato de dados ou de escala.

### Versão e rastreabilidade

- Documentação: Handbook e fontes Markdown oficiais de `apache/echarts-doc`, consultados na data acima. São documentos vivos.
- Versão normativa deste levantamento: **ECharts 6.1.0**, identificada como estável mais recente na [página oficial de releases](https://github.com/apache/echarts/releases/tag/6.1.0). Código de referência fixado nessa tag. A referência 6.0.0 usada inicialmente na auditoria local é histórica.
- A documentação viva pode evoluir além da tag. Em divergências, confrontar a opção com a implementação e os defaults da versão normativa. Upgrades exigem atualização explícita da matriz e dos casos.
- O catálogo `option.html` depende de JavaScript. O índice oficial [llms.txt](https://echarts.apache.org/en/llms.txt) foi consultado, mas os documentos `llms-documents` não ficaram acessíveis pela ferramenta de pesquisa. Para a API detalhada, foram lidos os arquivos Markdown do repositório oficial. Eles contêm inclusões `partial`; os arquivos parciais relevantes também foram consultados.
- Não foi feita comparação visual automatizada executando o ECharts nesta etapa. Os exemplos locais são autorais; as expectativas geométricas são derivadas dos contratos descritos.

## Contrato oficial para a suíte

Manter o host público `TDACChart`, mas reconstruir seu modelo de opções segundo `dataset`, `series`, `grid`, `xAxis`, `yAxis`, `title`, `legend`, `tooltip`, estilos e animação ECharts. Os nomes PascalCase e tipos Delphi podem representar o mesmo contrato; não devem mudar sua semântica. Propriedades ainda sem implementação ficam explicitamente fora do subconjunto suportado, em vez de aceitar valores sem efeito.

Área será `series.type=line` com `areaStyle`; rosca será `series.type=pie` com raio interno/externo. `ctArea`, `ctDoughnut`, tipo global do gráfico, fallback de campo por nome de série e tooltip `ctmSeries` não precisam ser preservados. Migrar demos/testes/DFMs internos junto da implementação futura.

Defaults funcionais seguem o ECharts 6.1.0. A identidade visual DAC será um **tema explícito**, com overrides de paleta, fonte e métricas identificados como tema; não deve alterar silenciosamente escalas, dados ou regras de interação. Callbacks JavaScript viram callbacks/eventos Delphi com o mesmo significado. DOM/HTML são detalhes da plataforma web e recebem implementação nativa equivalente quando aplicável.

O objetivo é reproduzir propriedades, defaults resolvidos, posições, proporções, lacunas, seleção, atualização e regras de layout. Diferenças de rasterização/fontes entre navegador e Windows não justificam diferenças nos dados ou na geometria. Não há obrigação de implementar todo o catálogo ECharts na primeira entrega; há obrigação de fidelidade no subconjunto declarado.

Este documento substitui as decisões conflitantes do mapeamento conceitual e do plano anterior. [echarts-property-map.md](../echarts-property-map.md) e as páginas da API atual descrevem o estado legado, não o contrato futuro.

## Documentação essencial e resultado esperado da leitura

| Tema | Fonte oficial consultada | Aplicação DAC |
| --- | --- | --- |
| Dados e dimensões | [Dataset](https://echarts.apache.org/handbook/en/concepts/dataset/) | Dimensões tipadas, séries, encodes e identidade de itens |
| Transformações | [Data Transform](https://echarts.apache.org/handbook/en/concepts/data-transform/) | Filtrar/ordenar dados antes da geometria; manter origem separada |
| Eixos | [Axis](https://echarts.apache.org/handbook/en/concepts/axis/) e [API comum](https://github.com/apache/echarts-doc/blob/master/en/option/component/axis-common.md) | Categoria, número, tempo, limites, ticks e margens |
| Área de plotagem | [Grid](https://github.com/apache/echarts-doc/blob/master/en/option/component/grid.md) | Reservar espaço para títulos/rótulos e evitar transbordamento |
| Legenda | [Legend](https://github.com/apache/echarts-doc/blob/master/en/option/component/legend.md) | Orientação, seleção, estado inativo e paginação |
| Tooltip | [Tooltip](https://github.com/apache/echarts-doc/blob/master/en/option/component/tooltip.md) e [contrato comum](https://github.com/apache/echarts-doc/blob/master/en/option/partial/tooltip-common.md) | Distinguir item/eixo, gatilho e posicionamento |
| Estilo | [Style](https://echarts.apache.org/handbook/en/concepts/style/) | Tema, paleta, estilos por série/item e estados |
| Codificação visual | [Visual Map](https://echarts.apache.org/handbook/en/concepts/visual-map/) | Mapear dados a cor/tamanho; não confundir com simples gradiente |
| Eventos | [Event and Action](https://echarts.apache.org/handbook/en/concepts/event/) | Separar ação, mudança de estado e notificação |
| Animação | [Data Transition](https://echarts.apache.org/handbook/en/how-to/animation/transition/) | Entrada, atualização e saída com correspondência entre itens |
| Resize | [Chart Container](https://echarts.apache.org/handbook/en/concepts/chart-size/) | Recalcular layout quando a área muda e tratar descarte |
| Acessibilidade | [Aria](https://echarts.apache.org/handbook/en/best-practices/aria/) | Descrição textual e diferenciação além de cor; adaptação nativa necessária |
| Zoom | [DataZoom](https://github.com/apache/echarts-doc/blob/master/en/option/component/data-zoom.md) | Janela de dados independente da fonte, percentuais/valores e política de filtro |

### Séries a reproduzir primeiro

| Forma na API DAC atual (a substituir) | Referência ECharts | Núcleo do comportamento |
| --- | --- | --- |
| `ctBar` | [Basic Bar](https://echarts.apache.org/handbook/en/how-to/chart-types/bar/basic-bar/), [API](https://github.com/apache/echarts-doc/blob/master/en/option/series/bar.md), [larguras/espaços](https://github.com/apache/echarts-doc/blob/master/en/option/partial/barGrid.md) | Barras agrupadas, orientação, base zero, largura e espaçamento |
| `ctLine` | [Basic Line](https://echarts.apache.org/handbook/en/how-to/chart-types/line/basic-line/), [API](https://github.com/apache/echarts-doc/blob/master/en/option/series/line.md) | Pontos em coordenadas reais, lacunas, símbolos e traço |
| `ctArea` | [Area Chart](https://echarts.apache.org/handbook/en/how-to/chart-types/line/area-line/) | ECharts usa `type: 'line'` com `areaStyle`; compartilhar pontos/path |
| `ctPie` | [Basic Pie](https://echarts.apache.org/handbook/en/how-to/chart-types/pie/basic-pie/), [API](https://github.com/apache/echarts-doc/blob/master/en/option/series/pie.md) | Setores proporcionais, rótulos, seleção e estado vazio |
| `ctDoughnut` | [Doughnut](https://echarts.apache.org/handbook/en/how-to/chart-types/pie/doughnut/) | ECharts usa `type: 'pie'` com dois raios; centro sem hit |
| Mistos | [Axis](https://echarts.apache.org/handbook/en/concepts/axis/) | Mesmo eixo transforma todas as séries; eixos adicionais exigem associação explícita |
| Empilhados | [Stacked Bar](https://echarts.apache.org/handbook/en/how-to/chart-types/bar/stacked-bar/) | Séries do mesmo grupo contribuem para a pilha; ainda é extensão DAC |

## Diferenças que precisam ficar explícitas

1. **Área e rosca são configurações.** O contrato alvo deve usar linha + preenchimento e pizza + raios; os enums dedicados da API antiga serão substituídos.
2. **`grid` não significa linhas de grade.** No ECharts organiza o sistema cartesiano; `axis.splitLine` configura suas linhas. O atual `ChartGrid.Visible` DAC não deve ser descrito como equivalente exato de `grid.show`.
3. **`splitNumber` é uma preferência de legibilidade.** Substituir o contrato ambíguo de `Ticks` e tratar passo fixo por opção própria, conforme ECharts.
4. **`tooltip.trigger` tem `item`, `axis`, `none`.** Substituir `ctmSeries`. Agregar várias séries após acertar um ponto não implementa, sozinho, ativação por eixo em qualquer posição da área útil.
5. **`seriesLayoutBy` é orientação da matriz.** Implementar a semântica row/column oficial e substituir os modos ambíguos atuais.
6. **`encode.seriesName` não é um campo Y alternativo.** Remover esse fallback de `EncodeSeries` ao construir os encodes oficiais.
7. **Gradiente de preenchimento não equivale a `visualMap`.** O primeiro depende da posição no desenho; o segundo deriva uma propriedade visual do valor de uma dimensão.
8. **Pizza de soma zero tem política configurável no ECharts.** Adotar `stillShowZeroSum` e `showEmptyCircle` com defaults oficiais; a mensagem atual não substitui esses comportamentos.
9. **`grid.containLabel` está depreciado na documentação v6 em favor de `outerBoundsMode`.** Novos contratos devem representar a intenção de conter rótulos, evitando copiar uma opção antiga sem avaliar sua evolução.

As fontes de cada diferença estão na tabela de documentação e na [matriz detalhada](property-matrix.md).

## Escopo de expansão catalogado

O [índice oficial](https://echarts.apache.org/en/llms.txt) também lista scatter/effectScatter, radar, gauge, funnel, heatmap, boxplot, candlestick, treemap, sunburst, sankey, graph, mapas, custom e outras séries. Foram identificadas como possibilidades, não estudadas com a mesma profundidade do núcleo atual.

Proposta: depois de estabilizar barras/linhas/áreas/pizza/rosca, considerar scatter, empilhamento, barras horizontais, linhas em degrau, múltiplos eixos e zoom conforme demanda real. Radar, gauge e heatmap exigem contratos próprios. Mapas, redes, 3D e custom series ficam para estudo separado. Tree/treemap nesse catálogo são visualizações de dados; não autorizam componentes de menu lateral ou TreeView VCL.

## Ordem de construção proposta

| Etapa | Entrega verificável | Dependência |
| --- | --- | --- |
| 1. Fidelidade dos dados | X tipado, NULL, campo ausente, filtro e ordem preservados | Adapter e snapshot |
| 2. Geometria correta | Escalas X/Y, categoria compartilhada, rótulos e limites manuais | Etapa 1 |
| 3. Apresentação previsível | Medição de texto, layout, estilos e legendas coerentes | Etapa 2 |
| 4. Interação equivalente | Item/eixo, legenda por série/fatia, seleção, eventos e teclado | Geometria e identidade |
| 5. Atualização eficiente | Invalidação por domínio, animação por identidade e cenários grandes | Etapas 1–4 |
| 6. Ampliação | Empilhamento, horizontal, smooth/step, eixos adicionais e zoom | Núcleo aprovado |

Essa ordem organiza a execução local. Cada etapa precisa dos testes correspondentes de [acceptance.md](acceptance.md). Recursos adiados são pendências de escopo, não autorização para alterar a semântica oficial. A implementação dos gráficos não foi iniciada nesta tarefa documental.

## Código de referência e uso

Os arquivos selecionados e as responsabilidades que podem orientar Delphi estão em [implementation-contracts.md](implementation-contracts.md). Os fontes consultados identificam licença Apache 2.0; o [LICENSE da referência](https://github.com/apache/echarts/blob/6.1.0/LICENSE) deve acompanhar qualquer avaliação futura de incorporação de código. Este levantamento contém síntese própria, links e exemplos autorais; não incorpora trechos da engine ao runtime.
