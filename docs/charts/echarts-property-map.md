# Mapa conceitual ECharts → TDACChart

Este documento registra a origem conceitual das propriedades do `TDACChart`.
O Apache ECharts é usado somente como referência de modelagem de opções; a Suite DAC não usa JavaScript, WebView nem engine externa de gráficos.

## Referências consultadas

- Dataset: <https://echarts.apache.org/handbook/en/concepts/dataset/>
- Get Started / option básica: <https://echarts.apache.org/handbook/en/get-started/>
- Legend: <https://echarts.apache.org/handbook/en/concepts/legend/>
- Axis: <https://echarts.apache.org/handbook/en/concepts/axis/>

## Mapeamento de propriedades

| Conceito ECharts | Propriedade DAC | Observação |
| --- | --- | --- |
| `dataset` | `TDACChart.DataSource` + `DatasetOptions` | A origem de dados é um `TDataSource`; o controle copia os dados para snapshot interno. |
| `dataset.dimensions` | `DatasetOptions.Dimensions` | Campo documental/persistente para declarar dimensões esperadas. |
| `seriesLayoutBy` | `DatasetOptions.SeriesLayoutBy` | Mantém o vocabulário de layout por linha/coluna para evolução futura. |
| `series` | `TDACChart.Series` | Coleção persistente de séries Delphi. |
| `series.type` | `ChartType` do gráfico ou de cada série | O tipo é configuração, não uma classe pública separada. |
| `series.name` | `Series[i].Name` | Usado em legenda e tooltip. |
| `series.encode` | `EncodeX`, `EncodeY`, `EncodeValue`, `EncodeLabel`, `EncodeTooltip`, `EncodeSeries` | Mapeia campos do dataset para categoria, valor e textos auxiliares. |
| `itemStyle.color` | `Series[i].Color` | Cor sólida da série. |
| Gradientes de item | `FillMode`, `GradientStartColor`, `GradientEndColor`, `GradientAngle` | Gradiente é renderizado por Skia no próprio controle. |
| `title` | `Title.Visible`, `Title.Text`, `Title.SubText`, `Title.Alignment`, `Title.Position` | Objeto persistente do chart. |
| `legend` | `Legend.Visible`, `Legend.Position`, `Legend.Orientation`, `Legend.AllowToggleSeries`, `Legend.ItemSpacing` | Configura presença e layout da legenda. |
| `tooltip` | `Tooltip.Enabled`, `Tooltip.Mode`, `Tooltip.FollowMouse`, `Tooltip.ShowMarker` | O texto final pode ser customizado por `OnTooltipFormat`. |
| `animation`, `animationDuration`, `animationDelay`, `animationEasing` | `Animation.Enabled`, `Duration`, `Delay`, `Easing` | Persistente por instancia; o timer somente interpola caches Skia ja formados. |
| `xAxis` | `XAxis` | Eixo de categorias/tempo. |
| `yAxis` | `YAxis` | Eixo numérico com escala automática ou manual. |
| `grid` | `ChartGrid.Visible`, `ChartGrid.Padding`, `ChartGrid.LineStyle` | Área interna de plotagem, não `TGrid`. |

## Decisões fixadas

- `TDACChart` é o único componente público de gráfico analítico.
- `TDACBarChart`, `TDACLineChart`, `TDACAreaChart` e `TDACDoughnutChart` não fazem parte do novo contrato.
- `TDACStatusTimelineChart` continua separado porque representa timeline/status, não gráfico analítico baseado em `dataset/series`.
- `Paint` consome apenas snapshot/layout/geometria cacheados; não navega no dataset durante desenho.
- O texto, o chrome, os eixos, as séries e os tooltips são renderizados com Skia no próprio controle.
