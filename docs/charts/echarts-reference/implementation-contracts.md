# Contratos de implementação — padrão ECharts 6.1.0

[Índice](README.md) · [Matriz](property-matrix.md) · [Aceite](acceptance.md)

As regras de dados/opções seguem o ECharts. A organização interna abaixo é uma proposta para implementá-las em Delphi/Skia. Não é um porte literal da arquitetura TypeScript e não representa código já implementado.

## 1. Modelo canônico de opções

Organizar a API persistente em torno da árvore oficial:

```text
Chart
  Dataset[]: Source, Dimensions, SourceHeader, Transform
  Grid[]
  XAxis[], YAxis[]
  Series[]
    Id, Name, Type, DatasetIndex, SeriesLayoutBy, Encode, Data
    ItemStyle, LineStyle, AreaStyle, Label
    Emphasis, Blur, Select
    opções específicas de bar / line / pie
  Title, Legend, Tooltip, AxisPointer
  Animation e opções de atualização
  DataZoom, VisualMap: etapas posteriores
```

Essa notação é conceitual, não uma declaração Pascal pronta. Reservar os nomes oficiais nos contratos/serialização; quando `Type` conflitar com a linguagem, usar identificador Delphi adequado com correspondência documentada. Arrays de componentes podem ser implementados por coleções persistentes.

**Ausente, automático, zero e falso são estados diferentes.** Não modelar `min` automático como `Min=0`, nem desligar uma opção porque seu valor numérico é zero. Valores que no ECharts aceitam número ou percentual precisam de representação tipada de unidade. Cada setter deve produzir efeito observável e streaming deve preservar presença explícita.

O designer pode oferecer presets de “Área” e “Rosca”, mas deve produzir `line + areaStyle` e `pie + radius`. Presets não criam tipos divergentes. Nenhuma camada de compatibilidade com `ctArea`, `ctDoughnut` ou DFMs anteriores é exigida.

## 2. Defaults: registrar origem e resolver overrides

Os valores abaixo foram conferidos em fontes da tag 6.1.0. São defaults de seus respectivos níveis; não aplicar o global por cima de uma especialização de série ou de opção explicitamente configurada.

| Escopo | Default confirmado | Fonte |
| --- | --- | --- |
| Global | `animation: 'auto'`; entrada 1000 ms; atualização 500 ms | [globalDefault.ts](https://github.com/apache/echarts/blob/6.1.0/src/model/globalDefault.ts) |
| Global | easing de entrada/atualização `cubicInOut`; `animationThreshold=2000` | Mesmo arquivo |
| Global | `stateAnimation.duration=300`, easing `cubicOut`; `useUTC=false` | Mesmo arquivo |
| Line | `lineStyle.width=2`, `type='solid'`; `symbol='emptyCircle'`, tamanho 6 | [LineSeries.ts](https://github.com/apache/echarts/blob/6.1.0/src/chart/line/LineSeries.ts) |
| Line | `smooth=false`, `step=false`, `connectNulls=false`, `showSymbol=true` | Mesmo arquivo |
| Line | entrada com easing `linear`, `sampling='none'`, `progressive=0` | Mesmo arquivo |
| Pie | centro `['50%','50%']`, raio `[0,'50%']`, sentido horário, início 90° | [PieSeries.ts](https://github.com/apache/echarts/blob/6.1.0/src/chart/pie/PieSeries.ts) |
| Pie | `stillShowZeroSum=true`, `showEmptyCircle=true`, precisão percentual 2 | Mesmo arquivo |
| Tooltip | `trigger='item'`; `triggerOn='mousemove|click'`; `confine=false` | [contrato comum](https://github.com/apache/echarts-doc/blob/master/en/option/partial/tooltip-common.md) e [Tooltip](https://github.com/apache/echarts-doc/blob/master/en/option/component/tooltip.md) |
| Legend | tipo `plain`; seleção habilitada | [Legend](https://github.com/apache/echarts-doc/blob/master/en/option/component/legend.md) |

Antes de implementar cada grupo, completar seu registro de defaults com os modelos específicos da mesma tag. Esta tabela é um conjunto inicial conferido, não o inventário completo de todas as opções ECharts. Separar explicitamente: default da biblioteca, default do tipo, override de tema e opção do usuário. Para casos de precedência ambígua, o resultado resolvido pela engine de referência é o critério de comparação.

## 3. Dados, identidade e adapters VCL

O modelo distingue dimensão, item, série e canais de encode. `seriesLayoutBy=column` e `row` mudam a interpretação da matriz; não significam apenas criar séries automaticamente. Referência: [Dataset](https://echarts.apache.org/handbook/en/concepts/dataset/).

Contrato proposto para a ponte VCL:

- Adapter fornece uma tabela tipada à camada equivalente a `dataset.source`, preservando filtro e ordem contratados, sem mover cursor ou chamar `Post`/`ApplyUpdates` na origem.
- `Encode.X/Y/Value` resolve dimensão; `Series.Name` identifica a série e não substitui nome de campo de valor.
- Preservar valor bruto, identidade e índice original além do índice de apresentação. Tooltip/seleção devem continuar apontando ao item correto depois de filtro, ordenação ou zoom.
- Falha de configuração de campo no adapter é erro de integração, distinto de campo existente com NULL. A representação de dado ausente segue o contrato da série.
- Tempo deve ter uma unidade definida no núcleo. Na fronteira Delphi, converter `TDateTime` para a representação temporal canônica; nunca substituir data por índice ou texto formatado. Preservar a distinção entre data civil e instante com fuso.
- Transformações operam em dados derivados. Não transformar um zoom/seleção em alteração da query ou do dataset original por efeito implícito.

Fontes: [Data Transform](https://echarts.apache.org/handbook/en/concepts/data-transform/) e [Time.ts](https://github.com/apache/echarts/blob/6.1.0/src/scale/Time.ts). As garantias sobre cursor pertencem ao adapter Delphi, não à API web do ECharts.

## 4. Uma transformação por eixo

Para o subconjunto linear sem quebras de eixo, com domínio `[min,max]`, retângulo útil `(L,T,R,B)` e `max>min`:

```text
normalizado(v) = (v - min) / (max - min)
x(v) = L + normalizado(v) * (R - L)
y(v) = B - normalizado(v) * (B - T)
```

São relações matemáticas de referência, não implementação completa de log, quebras, inverse ou layout automático. Dados fora do domínio não devem ser convertidos silenciosamente em valores de fronteira: manter os dados e aplicar clipping apropriado à geometria.

Categoria com N bandas: `x(i) = L + (i + 0.5) * (R-L)/N`. Sem bandas e com N>1: `x(i) = L + i * (R-L)/(N-1)`. Um ponto e domínio degenerado precisam de tratamento explícito, conforme a referência. Barras, linha, área, rótulos e interação devem consumir a mesma transformação, escolhida pelo eixo.

Fontes: [Axis.dataToCoord](https://github.com/apache/echarts/blob/6.1.0/src/coord/Axis.ts) e [Cartesian2D.dataToPoint](https://github.com/apache/echarts/blob/6.1.0/src/coord/cartesian/Cartesian2D.ts). O ECharts normaliza pela escala e converte para a extensão visual; a política de bandas pertence ao eixo.

**Aceite numérico:** X `0,1,100` em domínio `0..100` ocupa `0%,1%,100%`. Com domínio `0..200`, X=100 ocupa 50%. Para tempos irregulares, a distância depende do intervalo temporal, não da posição do registro.

## 5. Limites, ticks e texto

Tratar limites explícitos separadamente dos calculados. Respeitar `splitNumber` como sugestão e `interval` como opção de passo nas escalas em que é suportado. Não reutilizar quatro divisões fixas para qualquer quantidade de categorias. Referências: [opções de eixo](https://github.com/apache/echarts-doc/blob/master/en/option/component/axis-common.md) e [Interval.ts](https://github.com/apache/echarts/blob/6.1.0/src/scale/Interval.ts).

O código 6.1 separa configuração da escala e geração de ticks. Não transportar chamadas antigas de 6.0 sem conferir o módulo responsável na tag oficial. Conferir precisão decimal, limites muito próximos e prevenção de ticks duplicados.

Para tempo, ticks devem respeitar unidades de calendário quando essa cadência for escolhida; um mês não equivale sempre a trinta dias. Testar UTC/local, fevereiro e mudanças de ano. [Time.ts](https://github.com/apache/echarts/blob/6.1.0/src/scale/Time.ts).

Proposta de pipeline de layout local: medir título/legenda/eixos, reservar retângulos, calcular ticks, medir rótulos e resolver colisões. Repetir o ajuste de forma limitada se a área útil mudar. Aplicar as opções oficiais de contenção/intervalo/rotação suportadas. [Grid](https://github.com/apache/echarts-doc/blob/master/en/option/component/grid.md) e [labelLayoutHelper.ts](https://github.com/apache/echarts/blob/6.1.0/src/label/labelLayoutHelper.ts).

Skia desenha geometrias e superfícies. Texto nativo pode ser mantido como detalhe da plataforma, mas a medida usada no layout deve corresponder à fonte e ao DPI realmente usados na pintura. Tema DAC deve ser um conjunto de overrides explícitos.

## 6. Geometria por família

### Bar

Calcular banda por eixo e largura/deslocamento por série ou grupo empilhado. A base e a extremidade vêm da transformação do eixo de valores. Na composição de uma barra e uma linha, o centro da barra e o ponto da linha coincidem quando representam a mesma categoria. Barras agrupadas ocupam deslocamentos em torno desse centro.

Não arredondar coordenadas antes de terminar o cálculo do grupo. Aplicar arredondamento visual no renderer, preservando a geometria de referência para hit-test. `barMinHeight` não altera o valor do tooltip. Na orientação horizontal, trocar os papéis dos eixos, sem duplicar regras de valor.

Fonte: [barGrid.ts](https://github.com/apache/echarts/blob/6.1.0/src/layout/barGrid.ts). Para empilhamento, resolver categorias e acumular conforme `stackStrategy`; o default interno consultado é `samesign`. Positivos e negativos não devem se cancelar por acidente. [dataStack.ts](https://github.com/apache/echarts/blob/6.1.0/src/processor/dataStack.ts).

### Line e areaStyle

Transformar cada par X/Y; construir segmentos conforme presença/ausência e `connectNulls`. Área usa os mesmos segmentos e sua origem configurada. Um NULL não é zero e não deve criar uma região preenchida artificial até a base.

Smooth/step são opções distintas; não ativar curva apenas para “melhorar” aparência. Ao implementar smooth, validar extrema, monotonicidade e X repetido. Ao implementar sampling, preservar a fonte original para dados e eventos. Fonte: [poly.ts](https://github.com/apache/echarts/blob/6.1.0/src/chart/line/poly.ts) e [API de linha](https://github.com/apache/echarts-doc/blob/master/en/option/series/line.md).

### Pie e radius interno

No caso básico positivo, sem `minAngle/padAngle`, a amplitude de cada setor é `360 * valor / soma`. Implementar normalização angular, direção e raios com a mesma geometria para desenho e interação. Centro de rosca e exterior do raio não pertencem à fatia.

`stillShowZeroSum` controla o caso de soma zero; `showEmptyCircle` trata o conjunto vazio. Testar separadamente, sem substituir os dois por mensagem única. Ângulo mínimo/espaçamento alteram layout visual e exigem os ajustes da referência. A porcentagem exibida deve seguir também a política de precisão oficial. Fontes: [pieLayout.ts](https://github.com/apache/echarts/blob/6.1.0/src/chart/pie/pieLayout.ts) e [PieSeries.ts](https://github.com/apache/echarts/blob/6.1.0/src/chart/pie/PieSeries.ts).

Dados negativos e não finitos precisam de comparação com a cadeia de processamento da referência antes de fixar o contrato; não preservar automaticamente a rejeição antiga DAC nem inferir o comportamento apenas do método que desenha setores.

## 7. Interação e atualização

`trigger=item` seleciona item geométrico. `trigger=axis` resolve a coordenada do eixo e reúne séries pertinentes; não exige acertar um pequeno marcador. Formatar a partir dos dados resolvidos e separar `triggerOn` de `trigger`. Fontes: [tooltip comum](https://github.com/apache/echarts-doc/blob/master/en/option/partial/tooltip-common.md) e [TooltipView.ts](https://github.com/apache/echarts/blob/6.1.0/src/component/tooltip/TooltipView.ts).

Legenda controla séries ou itens conforme o tipo; em pizza, cada entrada representa dado/fatia. Diferenciar item ocultado por legenda de item selecionado. Os dois estados têm impactos distintos. [LegendView.ts](https://github.com/apache/echarts/blob/6.1.0/src/component/legend/LegendView.ts).

Eventos Delphi devem carregar identidade, índice original, índice apresentado, série e valor suficientes para o consumidor interpretar o item. A ação altera o estado; o evento comunica o resultado sem reentrância duplicada. [Event and Action](https://echarts.apache.org/handbook/en/concepts/event/).

Proposta de invalidação interna:

| Mudança | Trabalho necessário |
| --- | --- |
| Fonte, encodes ou transformação | Snapshot, domínio, layout e geometria |
| Tamanho, fonte, posição de legenda ou eixo | Layout e geometria, sem reler dataset |
| Cor/estado visual sem mudança de medida | Paint/cache visual |
| Mouse ou seleção | Hit-test e camada de estado; reprocessar apenas o que o estado afetar |

Animação deve distinguir entrada, atualização e saída; relacionar itens por identidade; interromper/recomeçar a partir do estado visível. Um timer local interpola memória; não consulta dataset. Destruição do handle deve cancelar timers. Fontes: [Data Transition](https://echarts.apache.org/handbook/en/how-to/animation/transition/) e [basicTransition.ts](https://github.com/apache/echarts/blob/6.1.0/src/animation/basicTransition.ts).

## 8. Extensões posteriores

- **DataZoom:** implementar janela e `filterMode`; `filter`, `empty` e `none` não têm o mesmo efeito no domínio dos outros eixos. [Contrato oficial](https://github.com/apache/echarts-doc/blob/master/en/option/component/data-zoom.md).
- **VisualMap:** transformar uma dimensão em cor/tamanho/opacidade; um shader linear da barra não cumpre esse contrato. [Conceito oficial](https://echarts.apache.org/handbook/en/concepts/visual-map/).
- **Acessibilidade:** adaptar descrição, padrões e representação dos dados à plataforma Windows; não declarar acessibilidade resolvida apenas porque existe `TabStop`. [Aria](https://echarts.apache.org/handbook/en/best-practices/aria/).

Não publicar opções dessas extensões com setters vazios. Registrar suporte por recurso e versão na documentação do runtime futuro.
