# 04 — Geometria, layout e desenho

[Índice](../README.md) · [Engine local](../../../Source/Skia/DAC.Components.Charts.Engine.pas)

Este capítulo descreve o algoritmo local, incluindo aproximações. O contrato de
paridade permanece o ECharts 6.1.0; fórmulas locais não redefinem o padrão oficial.

## Sistemas de coordenadas

Seja `s = DPI / 96`. Tamanhos numéricos de estilo são pixels lógicos e tornam-se
pixels físicos pela multiplicação por `s`. O viewport recebido pelo engine já tem
largura/altura físicas. Percentuais usam a dimensão física de referência diretamente.

O grid cartesiano é `(L,T,R,B)`, com largura `W=R-L` e altura `H=B-T`. Defaults
locais: left/right 10%, top 60 px lógicos, bottom 70 px lógicos. Cada dimensão útil
é protegida contra valores menores que 1; isso evita divisão por zero, mas não
garante layout utilizável em viewport muito pequeno.

Para eixo de valor com intervalo `[min,max]`:

```text
u = (valor - min) / (max - min)
u_inverso = 1 - u                quando inverse=true
x = L + u * W
y = B - u * H                    Y da janela cresce para baixo
```

Não limitar `u` a `[0,1]` antes de construir segmentos: pontos fora do intervalo
podem cruzar a região visível. O clipping limita a pintura da série ao plot.
Essa mesma transformação deve servir a eixos, marcas, labels e hit-test.

Para categoria de índice `i`, entre `N` categorias:

```text
boundaryGap=true:   u = (i + 0.5) / N
boundaryGap=false:  u = i / (N - 1), com tratamento especial de N=1
```

Exemplo C01 a 96 DPI, viewport 720×420, margens 80/40/40/60:
plot X=80..680, Y=40..360. Três categorias com gap têm centros 180, 380 e 580.
No eixo Y=0..40, valores 10/20/30 ficam em Y=280/200/120. Barras de largura 40
ocupam X do centro−20 ao centro+20; linha e barra compartilham o mesmo centro.
É a regressão concreta para o desalinhamento da implementação anterior.

X numérico `0,1,100` em intervalo 0..200 deve produzir `u=0,0.005,0.5`, nunca
posições ordinais `0,0.5,1`. Eixo temporal usa milissegundos como dimensão numérica;
a escolha de ticks de calendário é uma responsabilidade adicional.

## Limites e ticks

A rotina local `Bounds`, aninhada em `Render`, inclui zero salvo `scale`/limites explícitos. Intervalo degenerado
recebe expansão; limites impossíveis (`max <= min` depois da resolução) geram erro.
`dataMin/dataMax` usam extremos dos dados. Limites numéricos fixos não recebem
margem posterior. Limites ausentes/automáticos podem arredondar para fora.

O passo local divide a amplitude pelo splitNumber e escolhe mantissa 1, 2, 3, 5
ou 10, usando limiares 1.5, 2.5, 4 e 7 e uma potência de dez. `interval` pode
sobrescrever o passo; há limite de 1.000 ticks. Esse algoritmo é aproximado em
relação à escala oficial e precisa de regressões adicionais de extremos e precisão.

Eixo de tempo ainda usa limites numéricos e formatação simplificada de ano/dia/hora.
Meses, viradas de ano, horário de verão, múltiplas granularidades e o comportamento
completo do `TimeScale` oficial não estão aprovados. Incluir zero automaticamente
em tempo pode criar amplitude inadequada: fixar limites nas fixtures não testa esse
default.

Rótulos categóricos em `interval:auto` usam largura medida + 8 px como estimativa
de espaçamento. Rotação não participa de um solver completo de colisão. Há suporte
básico a linhas, ticks, splitLine, nomes e axisLine.onZero, mas ticks ainda podem
permanecer na borda do plot quando a linha do eixo se desloca para zero. A espessura
da linha de eixo é forçada a 1×scale em um caminho, limitando a opção de estilo.

## Barras e empilhamento

Séries visíveis são agrupadas por stack ou individualmente. Cada categoria reserva
uma banda. A largura automática considera a quantidade de grupos e o gap; o
default local de barCategoryGap deriva de `max(35 - grupos*4, 15)%`, e barGap de 0.1.
`barWidth`, `barMinWidth` e `barMaxWidth` ajustam essa largura. Misturar grupos com
larguras diferentes ainda não reproduz toda a distribuição do ECharts.

Empilhamento soma separadamente valores positivos e negativos no mesmo índice:

```text
positivo: base = soma dos positivos anteriores; topo = base + valor
negativo: base = soma dos negativos anteriores; topo = base + valor
exemplo [10,-4,7,-3]: acumulados positivos 10,17; negativos -4,-7
```

Uma série oculta não contribui. NULL não cria uma barra zero. Barra horizontal
troca o papel dos eixos, preservando a mesma regra por sinal. `barMinHeight` amplia
o retângulo visual de valores pequenos, portanto sua extremidade visual pode não
coincidir com a transformação linear pura; o teste deve considerar a opção.

Retângulos aceitam preenchimento, contorno e raio escalar. Raio por canto em array
não tem implementação equivalente. Labels nativos são desenhados depois das formas
e não herdam automaticamente o clip Skia do plot.

## Linhas, áreas e lacunas

`ChartPolyline` cria segmentos entre pontos válidos. `connectNulls=false` interrompe
o caminho; verdadeiro conecta os vizinhos válidos. A ausência deve permanecer na
identidade dos dados, sem compactar índices e deslocar categorias.

`step` suporta start/middle/end. `smooth=true` usa fator 0.5; números usam o fator
fornecido. Pontos de controle consideram distância entre vizinhos e limites locais;
`smoothMonotone` restringe o eixo relevante. A adaptação foi baseada no caminho
oficial de [line/poly.ts](https://github.com/apache/echarts/blob/6.1.0/src/chart/line/poly.ts).

Área é `line + areaStyle`. O contorno superior compartilha o caminho da linha;
o inferior percorre bases em ordem inversa para fechar o polígono. O caminho
inferior não implementa todas as combinações de suavização/empilhamento da referência.
Comparar apenas coordenadas de amostras não prova equivalência das curvas Bézier,
da área entre amostras nem do fechamento nas lacunas.

Símbolos têm tamanho e estilo próprios. O hit-test atual de linha é centrado nas
marcas, com tolerância mínima, não um cálculo completo de distância aos segmentos.
`showSymbol=false` não elimina a necessidade de posição de interação por ponto.

## Pizza e rosca

Pizza e rosca são a mesma família. `radius` escalar determina raio externo; par
`[interno,externo]` cria anel. Percentuais têm como base metade da menor dimensão
do viewport. Centro percentual usa largura/altura totais, não o grid cartesiano.

```text
Rbase = min(viewportWidth, viewportHeight) / 2
R = percentualExterno * Rbase; r = percentualInterno * Rbase
theta0 local = -startAngle       default -90 graus
sweep_i = 360 * max(valor_i,0) / somaDosValoresNaoNegativos
```

O sentido positivo visual acompanha Y crescente da tela. `clockwise` altera o
sentido; não mudar sinais em um lugar sem atualizar hit-test e labels. A fatia
selecionada desloca o centro na bissetriz, com `selectedOffset` padrão local 10.

`stillShowZeroSum` distribui setores quando o total é zero. É necessário aprofundar
o caso de NULL/ocultação nessa contagem. `showEmptyCircle` trata ausência de pontos,
mas a preservação do furo em rosca vazia ainda não foi homologada. Valores negativos
são limitados a zero nesse caminho; não declarar semântica universal de pizza com
sinais mistos.

Hit-test de anel precisa satisfazer `r <= distânciaAoCentro <= R` e intervalo
angular. O centro vazado não deve responder. A comparação automatizada atual mede
raios e módulo do sweep, **não** centro, ângulo inicial e orientação completos.

## Estilos e efeitos

Paleta local padrão: `#5070dd`, `#b6d634`, `#505372`, `#ff994d`, `#0ca8df`,
`#ffd10a`, `#fb628b`, `#785db0`, `#3fbe95`. `color` explícito substitui a paleta.
O tema DAC é outra configuração explícita, sem subscrição automática ao tema global.

O parser de cores reconhece transparent, white, black, red, green, blue, hex curto,
hex RGB/RGBA e rgb/rgba com vírgulas. Não implementa todos os nomes/gramáticas CSS.
Cor inválida agora gera erro no codec central, antes de alterar a configuração.

SkPaint usa antialias. Opacidade multiplica alpha da cor. Tracejado local utiliza
intervalos 4/3; pontilhado 1/2, escalados. Sombra converte blur para sigma aproximado
`blur/2`; offsets são escalados. Gradientes usam coordenadas relativas ao retângulo
da forma; radial usa a menor dimensão para o raio. Gradientes globais, combinações
de alpha e todas as interpolações não têm paridade comprovada.

Estados normal/emphasis/blur/select mesclam estilos no engine. O catálogo de estados
aceito não equivale ao completo modelo de foco/blurScope/transições do ECharts.
Não validar estado apenas lendo JSON: capturar a marca sob hover e suas vizinhas.

## Labels, título, legenda e tooltip como geometria

Labels substituem tokens e chamam `OnFormat`. Pizza usa `{d}` para percentual,
com precisão limitada a 0..15, default 2. Barra usa inside/branco no default local;
demais cartesianos partem de top. Pizza inside usa fator 0.65 e outside 1.16 do
vetor de raio; isso não modela corretamente toda espessura possível de anel.

`hideOverlap` usa retângulos alinhados aos eixos. Deslocamento vertical de labels
de pizza é simplificado. A linha-guia pode ser criada antes desse deslocamento,
ficando desconectada do texto. Validar conjuntamente setor, conector e rótulo.

Título local parte de centro/top 15 e padding 5, fonte 18 bold. O layout mede o
texto com a mesma fonte/DC Windows usados na pintura, incluindo múltiplas linhas,
fragmentos rich text e subtítulo. O subtítulo começa após a altura medida do título
mais `itemGap`. Antes de desenhar eixos e séries cartesianas, o topo útil passa a
ser `max(grid.top resolvido, fim do título/subtítulo + 12 DIP)`; a distância é
escalada pelo DPI. Margens maiores são preservadas; título vazio ou oculto não
reserva espaço. O cálculo é refeito no resize e na alteração do texto/fonte.
Os 12 DIP são uma constante do layout atual, não uma propriedade publicada;
`title.itemGap` no JSON é somente a distância entre título e subtítulo. Para mais espaço
antes da área cartesiana, configure `Grid.Top` maior que o mínimo calculado.

Essa proteção contra sobreposição é uma decisão local solicitada para o componente:
um `grid.top` explicitamente menor também é ajustado, sem reescrever o JSON.
Não equivale ao posicionamento independente de título/grid no ECharts. Pizza/rosca
continuam usando seu centro/raio no viewport, conforme a seção anterior. Não há
layout completo de caixa de título com todos os acabamentos/right/bottom oficiais.
`TestTitleSpacing` cobre texto simples, várias linhas, subtítulo, rich text,
remoção/ocultação, margens maiores e tamanhos 320/720/1280 em DPI 96/120/144/192.

Legenda mede texto, símbolo e gap; suporta orientação, paginação e seleção básica.
Paginação depende de largura variável e do tamanho estimado da página; seleção
single entre páginas precisa de revisão. Alinhamento à direita usa aproximação
fixa em um caminho. Tooltip calcula caixa pela medida das linhas, confina ao
viewport e desenha marcador e axisPointer. Padding, offsets internos e rotação
precisam de revisão combinada. Detalhes de interação no [capítulo 06](06-composicao-interacao.md).

## Invariantes para revisão de desenho

- Um único centro por categoria em todas as séries, eixos e interação.
- Limites fixos preservados; zero só participa quando o contrato exige.
- Todos os comprimentos em unidade conhecida; não aplicar DPI duas vezes.
- NULL não vira valor; ocultação e seleção não trocam identidade.
- Geometria de interação corresponde ao quadro visível, inclusive animação.
- A ordem de pintura e o clipping devem constar dos testes, não só os landmarks.
- Uma mudança de fórmula precisa de exemplo analítico e referência visual própria.
