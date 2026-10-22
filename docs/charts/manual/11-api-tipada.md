# 11 — API tipada e conversão centralizada

[Índice](../README.md) · [Types.pas](../../../Source/Core/DAC.Components.Charts.Types.pas)
· [Testes](../../../Tests/DACComponentsCharts.TypesTests.pas)

Esta evolução substitui as propriedades string de domínio fechado e as medidas,
limites e cores textuais descritas na consolidação inicial. Os capítulos 02/03
foram sincronizados com esse contrato na consolidação de 23/09/2026.
Não representam aprovação adicional de fidelidade visual ou flicker físico.

## Responsabilidades

`DAC.Components.Charts.Types` fica em `Source/Core`, usa RTL e define enums, sets,
objetos TPersistent vinculados ao store, codecs e validação da configuração. Não
depende de VCL Controls, Skia, dataset, demo ou classes da unit Options.

`TDACChartTypes` é a fronteira de conversão. Cada domínio enum possui leitor e
serializador JSON próprios. O JSON mantém os nomes ECharts; Pascal e Inspector usam
tipos Delphi. O renderer consome esses leitores para séries/eixos, legendas,
tooltip, labels, símbolos, estados, linha e animação. Marcas de interação possuem
tipo próprio e são convertidas para texto apenas na exportação diagnóstica.

`EDACChartOptionError` reside em Types; a unit Options mantém um alias para os
consumidores existentes. Erros identificam caminho e expectativa, por exemplo
`option.legend.orient: esperado horizontal|vertical`.

## API pública

```pascal
uses DAC.Components.Charts.Types;

Chart.Options.Legend.Orient := dcoVertical;
Chart.Options.Legend.LegendType := dclScroll;
Chart.Options.Legend.SelectedMode := dcseSingle;
Chart.Options.Legend.Left.Mode := dcmmRight;
Chart.Options.Legend.Top.SetPixels(12);

Chart.Options.Tooltip.Trigger := dctAxis;
Chart.Options.Tooltip.TriggerOn := [dcteMouseMove, dcteClick];
Chart.Options.Tooltip.PointerType := dcptShadow;

Chart.Options.XAxis.AxisType := dcaCategory;
Chart.Options.YAxis.Min.Value := 0;
Chart.Options.YAxis.Max.Value := 100;
Chart.Options.Grid.Left.SetPercent(10);
Chart.Options.Grid.OuterBoundsMode := dcbNone;

Chart.Options.Series[0].Kind := dcsLine;
Chart.Options.Series[0].Step := dcstMiddle;
Chart.Options.Series[0].Symbol := dcsyDiamond;
Chart.Options.Series[0].LineStyle.LineType := dcliDashed;
Chart.Options.Series[0].LabelStyle.Position := dcpTop;
Chart.Options.Title.Color.Color := $FF123456;
Chart.Options.AnimationMode := dcswFalse;
```

Os exemplos pressupõem uma série existente. `Series.Add` cria uma série padrão.
Propriedades numéricas/booleanas já tipadas permanecem. Texto, nomes, IDs, campos,
stack, fontFamily, formatter e o documento JSON continuam strings por representarem
conteúdo aberto, não uma lista fechada.

## Domínios enumerados

| Domínio | Valores JSON concretos |
| --- | --- |
| Orientation | horizontal, vertical |
| LegendType | plain, scroll |
| SeriesType | bar, line, pie |
| AxisType | category, value, time |
| LabelPosition | top, bottom, left, right, inside, insideTop, insideBottom, outside |
| TooltipTrigger | item, axis, none |
| OuterBoundsMode | none |
| SeriesLayout | column, row |
| Step | false, start, middle, end; true importa como end |
| Monotone | none, x, y |
| Symbol | none, circle, emptyCircle, rect, roundRect, triangle, diamond |
| Selection | false, single, multiple; true importa como multiple |
| Easing | linear, cubicIn, cubicOut, cubicInOut |
| LineType | solid, dashed, dotted |
| PointerType | none, line, shadow |
| Focus | none, series |
| FontStyle | normal, italic |
| TextAlign / VerticalAlign | left/center/right; top/middle/bottom |
| Overflow | truncate |
| RenderMode | richText |
| StackStrategy | samesign |
| Switch | auto, false, true |

São 23 famílias de codecs, além de enums de medidas, limites, preenchimentos,
estados e marcas. Aceitar o valor tipado não amplia a fidelidade do recurso: limites
anteriores de rich text, alinhamento vertical, colisão e layout continuam no aceite.
Não adicionar um literal ao enum para simular que um recurso ainda ausente existe.

`TriggerOn` é `TDACChartTooltipEvents`. Conjunto vazio exporta `none`; combinações
válidas exportam mousemove/click. Tokens desconhecidos ou repetidos são rejeitados.

## Ausência e defaults

Enums têm um membro `...Default`, que representa chave ausente. Atribuí-lo remove
o override. O getter não materializa o default do renderer no JSON. O Inspector
pode assim distinguir orientação herdada de horizontal explicitamente configurada.

Medidas, limites e preenchimentos oferecem `Reset` e `IsSpecified`. Ler um subobjeto
não muda JSON. Reset de uma cor ausente não cria `areaStyle` vazio e, portanto, não
ativa uma área acidentalmente. O set de eventos mostra o default efetivo quando a
chave está ausente; não grava nada até receber uma atribuição.

Zero, falso, alpha zero e ausência são valores distintos. `Grid.OuterBoundsMode`
ausente retorna `dcbDefault`; o getter não retorna mais o literal `auto` rejeitado
pelo importador. `FontWeight=0` no setter Delphi remove o override; peso JSON concreto
admite inteiro 1..1000 ou normal/bold.

## Objetos de valor

`TDACChartMeasure` possui `Mode` e `Value`, com `SetPixels`/`SetPercent` atômicos.
Alinhamentos são validados por contexto: `Legend.Left` admite right; `Grid.Left`
não admite esse literal. `Title.Top` não aceita bottom apenas porque Legend.Top
o aceita. A unidade não é inferida de uma string arbitrária no Inspector.

`TDACChartAxisLimit` separa default, auto, valor fixo, dataMin e dataMax. Min/Max
numéricos explícitos devem satisfazer max>min. Para substituir ambos por um intervalo
que conflita temporariamente com o anterior, aplique o JSON do eixo de uma vez;
BeginUpdate agrupa notificações, mas não suspende validação de cada setter.

`TDACChartFill` representa ausência, sólido, gradiente linear ou radial. `Color`,
`StartColor` e `EndColor` são TAlphaColor; X/Y/X2/Y2/Radius são doubles. Paradas
arbitrárias usam `TDACChartGradientStops` com offset e cor, por `GetStops/SetStops`.
`GetStops` retorna uma cópia; altere e envie o conjunto para validar antes de gravar.

```pascal
Chart.Options.Series[0].ItemStyle.Color.Kind := dcfkLinear;
Chart.Options.Series[0].ItemStyle.Color.StartColor := $FF5070DD;
Chart.Options.Series[0].ItemStyle.Color.EndColor := $805070DD;
Chart.Options.Series[0].ItemStyle.Color.Y2 := 1;
```

O prefixo alpha Delphi é ARGB; o codec exporta CSS `#RRGGBBAA`. Gradientes exigem
ao menos duas paradas, offsets ordenados em 0..1 e cores válidas. Campos de gradiente
incompatíveis com o tipo são recusados. Propriedades que só aceitam cor sólida
(por exemplo borda) rejeitam tentativa de configurar gradiente pelo objeto.

## Escrita transacional

Todas as escritas no store seguem: clonar → aplicar à cópia → validar → substituir
a raiz → notificar. Uma exceção de validação libera a cópia e preserva a raiz antiga.
Isso cobre setters publicados, medidas/cores/limites, JSON de subgrupo, JSON de
série e importação completa. Stores de série usam schema de série, não schema raiz.

`LoadJSON` do host ainda acrescenta a prova de dados/encode pelo engine. A validação
de Types é de schema/valores; não abre uma fonte externa nem renderiza para provar
layout. Exceções arbitrárias em callbacks depois de uma alteração válida não são
rollback de configuração. `BeginUpdate/EndUpdate` continua agrupamento, não transação.

O validador verifica objetos aninhados de estilos, estados, eixos, tooltip, rich
text, encode, gradientes e itens. Rejeita chaves duplicadas nos objetos do schema,
tipos JSON incorretos, bool escrito como string, números não finitos, intervalos
inválidos, cores malformadas, enum desconhecido e combinações fora do subconjunto.

Não há fallback para orientação digitada incorretamente. Importar `vertcal` falha.
Uma cor `#xyz` falha. Opacidade 1.5 falha antes de alterar o estado. Valores NULL
continuam válidos nos dados; não representam um override válido para qualquer opção.

## Compatibilidade e migração

A mudança da API Pascal é intencional: substituir literais por enums ou pelos
objetos de valor. O JSON ECharts suportado continua sendo o formato persistido no
DFM. Setters publicados permanecem `stored False` para evitar estados duplicados.

Configurações antes aceitas por falta de validação agora podem ser rejeitadas.
Exemplos: HTML, cross pointer, símbolo não implementado, overflow break, arrays de
padding/raio não suportados, encode com várias dimensões, enum com erro de grafia,
tipo numérico fornecido como texto onde o schema exige número. A mensagem indica
o campo; não remover silenciosamente a configuração inválida.

O demo usa um ComboBox fixo no DFM para orientação da legenda. O evento converte
a seleção da interface para enum; não atribui strings à propriedade. A escolha
padrão mantém o override ausente.

## Validação desta alteração

Os resultados abaixo pertencem à etapa de tipos, anterior ao ajuste de espaço do
título. Não são uma nova medição do renderer após esse ajuste; a cronologia está
no [capítulo 08](08-testes-evidencias.md).

- Build Win32 Debug: testes, package principal, demo principal e os três projetos
  do demo de gráficos, em `tmp/chart-types-work`, sem misturar DCUs do IDE.
- Testes de todos os valores das 23 famílias de codecs, rejeição de tokens desconhecidos,
  setters/subobjetos transacionais, medidas, alpha, gradientes, RTTI do Inspector,
  Assign e round-trip DFM.
- Asserts e capturas dos 29 cenários existentes; demo exclusivo compilado e executado.
- Comparação com referência preservada: 29/29 landmarks geométricos, 28/29 conteúdos
  textuais, mantendo a divergência preexistente de V15.
- Os 29 PNGs DAC resultantes são idênticos em pixels aos PNGs DAC históricos usados
  na regressão. Isso cobre essas fixtures, não toda combinação de propriedades.

O ensaio não substitui captura física contínua nem instala o package no IDE para
QA manual do Inspector. RTTI e DFM foram verificados por código. Logs, relatório e
hashes da alteração estão em [evidence/types-2026-09-22](../evidence/types-2026-09-22/README.md).
