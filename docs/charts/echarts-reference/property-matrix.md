# Matriz ECharts → TDACChart

[Voltar ao índice](README.md). **ECharts 6.1.0 é o contrato oficial; a API DAC atual não limita o desenho futuro e não exige compatibilidade.** Estado local considerado: auditoria de 22/09/2026. **Existente** significa caminho identificado, não aprovação integral. **Parcial** indica pendência de conformidade. **Proposto** identifica trabalho futuro, não API disponível.

## Dados

Fonte: [Dataset / encode](https://echarts.apache.org/handbook/en/concepts/dataset/).

| ECharts | DAC atual | Estado e contrato a construir |
| --- | --- | --- |
| `dataset.source` / `series.data` | `DataSource` / `Series.Points`, escolhidos por `DataMode` | Reconstruir modelo oficial; adapter VCL fornece source e dados explícitos seguem a precedência ECharts |
| `dataset.dimensions` com nome/tipo | `DatasetOptions.Dimensions` textual | Parcial; propor metadados tipados e validar campos |
| `seriesLayoutBy: column/row` | `cslColumns/cslRows` | Substituir pela orientação oficial da matriz, default column |
| `encode.x`, `encode.y` | `EncodeX`, `EncodeY` | Parcial; X do dataset ainda vira índice |
| `encode.value` | `EncodeValue` | Parcial; corrigir prioridade para pizza/rosca |
| `encode.itemName` | `Category` / campo X | Aproximação; separar identidade, categoria e texto |
| `encode.label`, `encode.tooltip` | Um campo em `EncodeLabel` / `EncodeTooltip` | Subconjunto; múltiplas dimensões são extensão |
| `encode.seriesName` | `EncodeSeries` | Remover fallback de valor e implementar nome de série por dimensão |
| `encode.itemId` / identificação de itens | Sem chave publicada dedicada | Proposto: chave estável para atualização, seleção e hover |
| `dataset.transform` | Preparação externa/adapters | Proposto: transformar snapshot sem modificar dataset original |

Não converter automaticamente categorias numéricas em eixo numérico. Um código de produto `0012` pode ser categoria textual. A escolha pertence ao contrato do eixo/dimensão.

## Eixos e layout

Fontes: [Axis](https://echarts.apache.org/handbook/en/concepts/axis/), [opções comuns](https://github.com/apache/echarts-doc/blob/master/en/option/component/axis-common.md), [Grid](https://github.com/apache/echarts-doc/blob/master/en/option/component/grid.md).

| ECharts | DAC atual | Estado e contrato a construir |
| --- | --- | --- |
| `xAxis.type`, `yAxis.type` | `AxisType` | Categoria/valor/tempo publicados; geometria precisa ser coerente com o tipo |
| `type: log`, `logBase` | Ausente | Proposto para etapa posterior; domínio positivo explícito |
| `min`, `max` | `Min`, `Max`, `AutoScale` | Parcial: X sem efeito geométrico; Y manual recebe margem indevida |
| `boundaryGap` | Ausente | Proposto: bandas para categorias, margens para eixos contínuos |
| `inverse` | Ausente | Proposto; a mesma transformação deve atender desenho e interação |
| `splitNumber` | `Ticks` | Substituir por preferência de divisões, com semântica ECharts |
| `minInterval`, `maxInterval`, `interval` | Ausentes | Propostos; separar cadência temporal de passo numérico |
| `axisLine`, `axisTick`, `axisLabel` | Visibilidade, fontes e cores em `XAxis/YAxis` | Existente parcialmente; rotação/colisão exigem contrato |
| `splitLine` | `GridLines`, `GridColor`, `ChartGrid.LineStyle` | Parcial; usar as mesmas coordenadas dos ticks |
| `axisLabel.formatter` | `LabelFormat` | Adaptação: máscaras Delphi não são templates JavaScript |
| `name`, `nameTextStyle` | `Title`, `TitleFont`, `TitleColor` | Existente parcialmente; medir espaço reservado |
| `grid.left/right/top/bottom` | `ChartGrid.Margins`, `Padding` | Aproximação; documentar pixels lógicos, percentuais e área de referência |
| `grid.outerBoundsMode` | Reserva de layout própria | Proposto: restringir área externa depois de medir texto |
| Múltiplos `grid`, `xAxisIndex`, `yAxisIndex` | Um par `XAxis/YAxis` | Ausente; só adicionar coleções com necessidade definida |

No ECharts v6, `containLabel` é legado e `outerBoundsMode` trata contenção. No DAC a decisão inicial pode ser mais simples: medir título, legenda e eixos, reservar suas áreas e só então calcular a plotagem. Essa é uma adaptação proposta, não equivalência de todas as opções.

## Séries

### Barras

Fontes: [API de barras](https://github.com/apache/echarts-doc/blob/master/en/option/series/bar.md), [barGrid](https://github.com/apache/echarts-doc/blob/master/en/option/partial/barGrid.md), [empilhamento](https://echarts.apache.org/handbook/en/how-to/chart-types/bar/stacked-bar/).

| ECharts | DAC atual | Evolução |
| --- | --- | --- |
| `type: bar` | `ctBar` | Corrigir centro da categoria e alinhamento misto |
| Categoria em Y, valor em X | Barras verticais | Proposto: orientação horizontal pela transformação dos eixos |
| `barWidth`, `barMinWidth`, `barMaxWidth` | Cálculo interno | Propor opções; não impor mínimo que cause sobreposição silenciosa |
| `barGap`, `barCategoryGap` | Constantes internas | Expor separadamente espaço entre séries e entre categorias |
| `barMinHeight` | Altura mínima interna | Explicitar distorção visual; zero não pode virar valor positivo |
| `stack` | Ausente | Propor grupo e acumulação por sinal |
| `itemStyle`, `label`, `showBackground` | Cor/gradiente; sem modelo completo | Propor preenchimento, contorno, rótulo e fundo independentes |

### Linhas e áreas

Fontes: [API de linha](https://github.com/apache/echarts-doc/blob/master/en/option/series/line.md), [área](https://echarts.apache.org/handbook/en/how-to/chart-types/line/area-line/).

| ECharts | DAC atual | Evolução |
| --- | --- | --- |
| `type: line` | `ctLine` | Corrigir coordenadas numéricas/temporais |
| `areaStyle` | `ctArea` | Substituir enum por configuração da série line |
| `lineStyle` / `areaStyle` / `itemStyle` | Parte controlada por `FillMode` e cores | Propor estilos independentes de traço, preenchimento e marcador |
| `connectNulls` | NULL interrompe segmento | Manter falso como comportamento inicial; opção futura explícita |
| `smooth`, `smoothMonotone` | Ausentes | Propostos; validar overshoot e X repetido |
| `step` | Ausente | Proposto com início/meio/fim |
| `symbol`, `symbolSize`, `showSymbol` | Círculos/tamanhos internos | Propor configuração e redução de marcadores por densidade |
| `sampling` | Ausente | Proposto para grandes séries, preservando dados originais |

### Pizza e rosca

Fontes: [API de pizza](https://github.com/apache/echarts-doc/blob/master/en/option/series/pie.md), [rosca](https://echarts.apache.org/handbook/en/how-to/chart-types/pie/doughnut/).

| ECharts | DAC atual | Evolução |
| --- | --- | --- |
| `type: pie` | `ctPie` | Manter total, nulos e porcentagens coerentes |
| `radius: [interno, externo]` | `ctDoughnut`, proporção interna fixa | Substituir enum por configuração da série pie |
| `center`, `startAngle`, `clockwise` | Cálculo interno | Propor posição e orientação |
| `padAngle`, `minAngle` | Ausentes | Propostos; distinguir ângulo visual e participação real |
| `label`, `labelLine`, `avoidLabelOverlap` | Sem modelo completo | Propor rótulos externos e controle de colisão |
| `selectedMode`, `selectedOffset` | Sem seleção de fatia equivalente | Proposto: estado por identidade do item |
| `stillShowZeroSum`, `showEmptyCircle` | Mensagem para total sem positivos | Substituir pelo comportamento e defaults oficiais |
| Múltiplas séries pizza | Uma série visível permitida | Remover restrição do modelo alvo; múltiplos centros/anéis exigem implementação própria |

## Interação, apresentação e atualização

| ECharts e fonte | DAC atual | Correspondência e proposta |
| --- | --- | --- |
| [`title.text/subtext`](https://echarts.apache.org/en/option.html#title) | `Title.Text/SubText` | Correspondência nominal; posicionamento não é toda a API ECharts |
| [`legend.orient/itemGap`](https://github.com/apache/echarts-doc/blob/master/en/option/component/legend.md) | `Orientation/ItemSpacing` | Existente; medir e tratar overflow |
| `legend.selectedMode/selected` | `AllowToggleSeries` e `Series.Visible` | Parcial; pizza precisa alternar item, e modos single/multiple são distintos |
| `legend.type: scroll` | Ausente | Proposto: paginação interna quando não cabe |
| [`tooltip.trigger: item/axis/none`](https://github.com/apache/echarts-doc/blob/master/en/option/partial/tooltip-common.md) | `ctmNearest/ctmAxis/ctmSeries`, `Enabled` | Substituir modos pelos gatilhos oficiais; retirar ctmSeries |
| `tooltip.axisPointer` | Ausente como configuração completa | Proposto: linha, faixa e crosshair |
| [`triggerOn`, `confine`, `position`](https://github.com/apache/echarts-doc/blob/master/en/option/component/tooltip.md) | Movimento, `FollowMouse` e layout próprio | Propor gatilho explícito e contenção dentro do chart |
| `formatter` | Template próprio e `OnTooltipFormat` | Adapter de contrato; não executar expressões JavaScript |
| [`emphasis/blur/select`](https://echarts.apache.org/handbook/en/concepts/style/) | Hover parcial | Propor estados independentes, incluindo teclado |
| [`visualMap`](https://echarts.apache.org/handbook/en/concepts/visual-map/) | Gradientes geométricos | Recurso diferente; propor regra por dimensão/valor |
| [`animationDuration/animationDurationUpdate`](https://echarts.apache.org/handbook/en/how-to/animation/transition/) | `Animation.Duration` único | Substituir por opções oficiais de entrada/atualização e implementar saída conforme referência |
| [`dispatchAction` e eventos](https://echarts.apache.org/handbook/en/concepts/event/) | Eventos Delphi e métodos existentes | Propor ações de seleção/zoom com notificação sem duplicação |
| [`dataZoom`](https://github.com/apache/echarts-doc/blob/master/en/option/component/data-zoom.md) | Ausente | Extensão com janela, navegação e política de filtro |
| [`aria` e padrões](https://echarts.apache.org/handbook/en/best-practices/aria/) | Sem equivalência demonstrada | Propor descrição/lista de dados, teclado e padrões nativos |

Novas propriedades devem ter defaults oficiais resolvidos, setters com invalidação apropriada, `Assign`, streaming DFM e testes de efeito real. Nenhum nome proposto nesta matriz deve ser usado como se já compilasse no consumidor. Preferir a árvore oficial `Encode`, `ItemStyle`, `LineStyle`, `AreaStyle`, `Label`, `AxisLabel`, `AxisTick`, `SplitLine`, `Trigger` à manutenção dos atalhos ambíguos da API antiga.
