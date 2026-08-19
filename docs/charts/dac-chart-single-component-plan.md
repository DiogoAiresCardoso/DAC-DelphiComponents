# Plano — Gráficos DAC com um único componente configurável

## Resumo

A família de gráficos da Suite DAC deve usar um único componente público principal: `TDACChart`.

Dentro dele, as especializações serão configuradas por propriedades e por série. Esse modelo evita classes públicas duplicadas, permite gráficos mistos no mesmo canvas e aproxima a API do padrão de configuração do Apache ECharts, onde `dataset`, `series`, `axis`, `legend` e `tooltip` são opções persistentes e combináveis.

A implementação substituirá os charts atuais da suíte, sem manter compatibilidade com a API antiga (`ValuesText`, `CategoriesText`, `TDACBarChart`, `TDACLineChart`, `TDACAreaChart`, `TDACDoughnutChart` etc.).

O desenho será feito diretamente em Skia no próprio controle, sem `TSkPaintBox`, WebView, JavaScript ou outro componente de renderização.

## API pública nova

- Criar `TDACChart = class(TCustomControl)` como o único componente de gráfico da família.
- Expor especializações por configuração:
  - `ChartType: TDACChartType` para o caso simples.
  - `Series: TDACChartSeriesCollection`, onde cada série também terá `ChartType`.
  - Tipos MVP: `ctBar`, `ctLine`, `ctArea`, `ctPie`, `ctDoughnut`.
  - Permitir séries mistas quando fizer sentido: barra + linha + área no mesmo eixo cartesiano.
- Remover da paleta e do contrato público os descendentes especializados antigos.
- Aceitar quebra de DFM antigo, porque a premissa fixada é evoluir os gráficos sem manter compatibilidade.
- Manter `TDACStatusTimelineChart` fora do novo contrato `TDACChart`: ele será tratado como componente de timeline/status já existente, não como gráfico analítico baseado em `dataset/series`.

## Configuração no estilo ECharts, mas 100% Delphi/VCL

Documentar e implementar propriedades persistentes inspiradas no modelo do ECharts, usando ECharts apenas como referência conceitual:

### Dataset

- `DataSource`
- `DatasetOptions`
- Snapshot via `TDataLink`.
- Nunca navegar o dataset durante `Paint`.
- Separar dados de configuração, conforme a ideia de `dataset` do ECharts.
- Referência conceitual: <https://echarts.apache.org/handbook/en/concepts/dataset/>

### Series

- `Name`
- `ChartType`
- `EncodeX`
- `EncodeY`
- `EncodeValue`
- `EncodeLabel`
- `EncodeTooltip`
- `FillMode: cfSolid | cfLinearGradient | cfRadialGradient`
- `Color`
- `GradientStartColor`
- `GradientEndColor`
- `GradientAngle`

A série é o ponto principal de especialização, como `series.type` no ECharts.

### Title

- `Visible`
- `Text`
- `SubText`
- `Alignment`
- `Position`
- `Font`
- `SubFont`

### Legend

- `Visible`
- `Position`
- `Orientation`
- `AllowToggleSeries`
- `ItemSpacing`
- Referência conceitual: <https://echarts.apache.org/handbook/en/concepts/legend/>

### Axes

- `XAxis`
- `YAxis`
- `Visible`
- `AxisType`
- `Title`
- `Min`
- `Max`
- `AutoScale`
- `LabelFormat`
- `GridLines`
- `Ticks`
- Referência conceitual: <https://echarts.apache.org/handbook/en/concepts/axis/>

### Tooltip

- `Enabled`
- `Mode: nearest | axis | series`
- `FollowMouse`
- `ShowMarker`
- `Formatter`

### ChartGrid

- `Visible`
- `Margins`
- `LineStyle`
- `Padding`

## Documentação obrigatória

- Criar `docs/charts/echarts-property-map.md`, provando a origem conceitual das propriedades e o mapeamento para Delphi.
- Criar `docs/charts/dac-chart-api.md`, com exemplos DFM e Pascal usando `TClientDataSet`.
- Explicitar que não há dependência de ECharts, JavaScript ou WebView.
- Referência geral: <https://echarts.apache.org/handbook/en/get-started/>

## Implementação

- Reescrever a família de charts atual para um pipeline único:

  ```text
  SnapshotData -> CalculateLayout -> BuildGeometry -> Render
  ```

- Renderização:
  - Usar `System.Skia`/`Vcl.Skia` diretamente no `Paint` do `TDACChart`.
  - Não criar `TSkPaintBox`, `TImage`, bitmap intermediário persistente ou componente filho para desenhar o gráfico.
  - Cachear snapshot, layout, geometria e hit areas.
  - Recalcular layout apenas quando dados, tamanho ou opções mudarem.

- Data-aware:
  - `DataSource: TDataSource`.
  - `TDataLink` interno.
  - Suportar dataset `nil`, inativo, vazio, com `null`, valores negativos, categorias longas e múltiplas séries.
  - Não executar `Post`, `ApplyUpdates` ou navegação no dataset.

- Interação:
  - Hover por geometria cacheada.
  - Tooltip próprio do gráfico.
  - Eventos `OnPointHover`, `OnPointClick`, `OnTooltipFormat`, `OnDataError`.
  - Cursor, foco e teclado básicos sem quebrar VCL/designer.

- Visual:
  - Usar tokens atuais da suíte para cores, fontes, raios, espaçamentos e tema.
  - Light/Dark completos.
  - Gradiente por série, incluindo barras, áreas e fatias de pie/doughnut.
  - Sem High DPI, `CurrentPPI`, `ScaleForPPI` ou escala manual.

- Package/Demo:
  - Registrar apenas `TDACChart` na paleta de gráficos.
  - Atualizar a página `Charts` do Demo para demonstrar todos os tipos por configuração do mesmo componente.
  - Remover DFMs e usos antigos das classes especializadas.

## Testes e aceite

- Build Delphi 10.2/Win32 do package único, Demo e testes, com todas as saídas em `M:\Delphi Componentes\DAC-DelphiComponents\Build`.
- Testes automatizados:
  - Dataset nil/inativo/vazio.
  - `TClientDataSet` com string, inteiro, decimal, data e null.
  - Séries múltiplas e séries mistas.
  - `ctBar`, `ctLine`, `ctArea`, `ctPie`, `ctDoughnut`.
  - Cores sólidas e gradientes por série.
  - Troca/destruição de `DataSource`.
  - Hover, hit-test, tooltip e click sem acessar dataset.
  - DFM round-trip de `TDACChart` e objetos persistentes.
  - Criação com `Parent=nil` sem erro de designer.
- QA visual:
  - Light/Dark.
  - Resize pequeno/médio/grande.
  - Sem flicker, clipping, textos sobrepostos ou fundo incompatível.
  - Legenda, título, eixos, tooltip e gradientes proporcionais aos assets da suíte.

## Premissas fixadas

- Haverá um único componente de gráfico público: `TDACChart`.
- O tipo do gráfico será configuração, não classe pública separada.
- Não haverá compatibilidade com a API antiga dos charts.
- ECharts é referência conceitual/documental, não dependência runtime.
- Renderização será Skia direta no componente.
- `TDACStatusTimelineChart` permanece separado por ser timeline/status, não gráfico analítico `dataset/series`.
