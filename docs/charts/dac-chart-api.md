# API do TDACChart

`TDACChart` e o unico componente analitico visual da Suite DAC. Ele herda de
`TCustomControl`, desenha o frame inteiro com Skia e preserva a semantica VCL
para foco, eventos e streaming DFM. `TDACStatusTimelineChart` continua sendo um
componente independente de status.

## Tipos e dados

`ChartType` aceita `ctBar`, `ctLine`, `ctArea`, `ctPie` e `ctDoughnut`.
Bar, line e area podem ser misturados; pie e doughnut exigem exatamente uma
serie visivel e nunca podem ser combinados com uma serie cartesiana.

`DataMode` e persistente no DFM e define uma fonte exclusiva:

| Valor | Default | Efeito |
|---|---:|---|
| `cdmAuto` | sim | Usa `DataSource` quando atribuido; caso contrario usa `Series.Points`. |
| `cdmDataSource` | nao | Usa somente `DataSource`; nil, inativo ou vazio mostra estado vazio. |
| `cdmManual` | nao | Ignora `DataSource` e usa somente pontos persistidos. |

Em modo manual cada `TDACChartSeries.Points` e uma colecao persistente de
`TDACChartPoint`. `Category`, `XValue`, `Value`, `IsNull`, `LabelText` e
`TooltipText` sao gravados no DFM. `IsNull=True` vence `Value`, quebra paths de
line/area e nao cria barra ou fatia.

```pascal
Chart1.DataMode := cdmManual;
LSeries := Chart1.Series.Add;
LSeries.Name := 'Producao';
LSeries.ChartType := ctBar;
LPoint := LSeries.Points.Add;
LPoint.Category := 'Jan';
LPoint.Value := 42;
```

```pascal
object Chart1: TDACChart
  DataMode = cdmManual
  Series = <
    item
      Name = 'Producao'
      ChartType = ctBar
      Points = <
        item
          Category = 'Jan'
          Value = 42.000000000000000000
        end>
    end>
end
```

## Fonte data-aware

O adapter oficial e `TCustomClientDataSet`. O chart abre um clone com
`CloneCursor` e navega somente esse clone, portanto nao altera cursor, bookmark,
estado, foco ou controles do dataset original. Outro dataset sem adapter gera
`OnDataError`; ele nunca e navegado silenciosamente. O chart nao executa `Post`,
`ApplyUpdates` nem depende de FireDAC.

`DatasetOptions.Dimensions` usa `;` para separar dimensoes. Em `cslRows`, cada
registro vira ponto; cada item de `Series` resolve os encodes `EncodeX`,
`EncodeY`, `EncodeValue`, `EncodeLabel` e `EncodeTooltip`. `EncodeY` precede
`EncodeValue` para cartesianos; para pie/doughnut a prioridade e
`EncodeValue`, depois `EncodeY`.

```pascal
Chart1.DataMode := cdmDataSource;
Chart1.DataSource := dsSafra;
LSeries := Chart1.Series.Add;
LSeries.Name := 'Soja';
LSeries.EncodeX := 'MES';
LSeries.EncodeY := 'TONELADAS';
```

## Configuracao visual

| Propriedade | Default | Efeito e invalidacao | Equivalente ECharts |
|---|---:|---|---|
| `Title.Text`, `SubText`, `Font`, `SubFont`, `Position`, `Alignment` | vazio | reserva layout e recria geometria | `title` |
| `Legend.Visible`, `Position`, `Orientation`, `ItemSpacing` | visivel | relayout; item pode alternar serie | `legend` |
| `ChartGrid.Visible`, `Padding`, `Margins`, `LineStyle` | visivel, 16 | muda plotagem e linhas Skia | `grid` |
| `XAxis` e `YAxis` | auto | eixo, ticks, grid, titulo e formato | `xAxis`, `yAxis` |
| `Series.FillMode` | `cfSolid` | shader e geometria | `series.itemStyle` |
| `GradientStartColor`, `GradientEndColor`, `GradientAngle` | paleta, 90 | solido, linear ou radial real | `visualMap`/`itemStyle.color` |
| `Tooltip.Mode`, `Formatter`, `FollowMouse`, `ShowMarker` | nearest | apenas paint/hover | `tooltip` |

## Visibilidade e estilo de cada camada

Nenhuma camada visual do chart depende de um valor implÃ­cito fixo. Todas as
opÃ§Ãµes abaixo sÃ£o persistentes em DFM e invalidam somente layout/geometria/pintura,
sem reler o dataset.

- `Title`: `Visible`, `TextVisible`, `SubTextVisible`, `Position`, `Alignment`,
  `Font`, `SubFont`, `TextColor` e `SubTextColor`.
- `Legend`: `Visible`, `Position`, `Orientation`, `LabelsVisible`,
  `MarkersVisible`, `MarkerSize`, `Font`, `TextColor`, `BackgroundVisible`,
  `BackgroundColor`, `BorderVisible`, `BorderColor`, `Padding`, `ItemSpacing` e
  `AllowToggleSeries`.
- `XAxis` e `YAxis`: `Visible`, `LineVisible`, `LabelsVisible`,
  `TickMarksVisible`, `TitleVisible`, `GridLines`, `AutoScale`, `Ticks`,
  `LabelFont`, `TitleFont`, `LabelColor`, `TitleColor`, `LineColor` e
  `GridColor`.
- `ChartGrid`: `Visible`, `Margins`, `Padding` e `LineStyle`.

```pascal
Chart1.Title.Visible := True;
Chart1.Title.Position := cpTop;
Chart1.Title.Font.Name := 'Inter';
Chart1.Title.Font.Size := 18;
Chart1.Title.TextColor := $FF176B2C;

Chart1.Legend.Position := cpRight;
Chart1.Legend.Orientation := coVertical;
Chart1.Legend.BackgroundVisible := True;
Chart1.YAxis.LabelsVisible := False;
Chart1.YAxis.GridLines := True;
```

`Formatter` aceita `{series}`, `{category}`, `{x}`, `{value}`, `{percent}`,
`{label}` e `{tooltip}`. `OnTooltipFormat` recebe o resultado do template e pode
altera-lo uma unica vez quando o datum de hover muda.

## Interacao e desempenho

Hit-test usa retangulo para barras, distancia para pontos e teste polar para
pie/doughnut; o furo do doughnut e a area externa nao respondem. A legenda so
altera `Series.Visible` com `AllowToggleSeries=True`. Eventos de ponto nao
dependem de `Tooltip.Enabled`.

O pipeline e `SnapshotData -> CalculateLayout -> BuildGeometry -> Render`.
Leitura data-aware e colecoes postam uma mensagem coalescida; `Paint` apenas
reapresenta o cache Skia, sem referencia a `TDataSet`, `TField`, `First` ou
`Next`. Resize invalida layout/geometria, nunca a fonte de dados.

## Animacao

Cada instancia possui `Animation: TDACChartAnimation`, tambem persistente no
DFM. O padrao e `Enabled=True`, `AutoStartOnUpdate=True`, `Duration=360`,
`Delay=0`, `Easing=caeCubicOut` e `HoverDuration=120` milissegundos.

| Propriedade ou metodo | Efeito |
|---|---|
| `Enabled` | Ativa a interpolacao local; ao desligar, apresenta o cache alvo imediatamente. |
| `AutoStartOnUpdate` | Anima atualizacao manual, data-aware, visual ou estrutural. |
| `Duration`, `Delay`, `Easing` | Definem a progressao: linear, cubica de entrada, saida ou entrada/saida. |
| `HoverDuration` | Transicao curta da camada de hover e tooltip, sem reiniciar dados. |
| `Running` | Estado somente leitura, nunca serializado. |
| `Replay` e `Stop` | Reinicia a partir da geometria colapsada ou encerra no cache alvo. |

```pascal
Chart1.Animation.Duration := 600;
Chart1.Animation.Easing := caeCubicInOut;
Chart1.Animation.Replay;
```

O refresh constroi primeiro o snapshot, layout e geometria final. Um unico
`WM_TIMER` por chart interpola somente valores e cores em memoria e pede
`Invalidate`; o `Paint` continua a apresentar o frame Skia pronto. Uma nova
atualizacao toma o frame atual como origem, evitando salto visual. O timer e
cancelado em `Stop`, destruicao do handle, destruicao do componente e quando
nao ha transicao de dados ou hover.

## Dataset e layouts de serie

`DatasetOptions.SeriesLayoutBy` e `Series.EncodeSeries` participam da leitura
data-aware. Em `cslRows`, cada registro acrescenta um ponto para cada serie;
`EncodeY`, `EncodeValue`, `EncodeSeries` e finalmente `Name` sao as opcoes de
campo de valor, nesta ordem. Em `cslColumns`, a primeira dimensao e a categoria
e cada dimensao seguinte gera uma serie quando a colecao `Series` estiver vazia.
Com series configuradas, seus encodes continuam tendo prioridade.

```pascal
Chart1.DataMode := cdmDataSource;
Chart1.DatasetOptions.SeriesLayoutBy := cslColumns;
Chart1.DatasetOptions.Dimensions := 'MES;PRODUCAO;META';
```

O leitor padrao usa `CloneCursor` para `TCustomClientDataSet`, preservando o
cursor e o estado do dataset original. Outros datasets podem ser habilitados
sem dependencias adicionais do runtime por `RegisterDACChartDataSetAdapter`.

## Designer e restricoes

- Pode ser criado com `Parent=nil`; colecoes nao acessam handle nem parent.
- Nao ha `TBitmap`, `TSkPaintBox`, fallback de desenho GDI, WebView ou JavaScript.
- A superficie raster e `TSkSurface.MakeRasterDirect`; a unica operacao WinAPI e
  a transferencia final dos pixels ao HDC.
- Nao ha API High DPI, `CurrentPPI`, `ScaleForPPI` ou escala manual.
- Sem `ValuesText`, `CategoriesText` ou classes publicas especializadas antigas.
