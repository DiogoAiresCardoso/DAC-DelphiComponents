# 05 — Fontes, tipografia, rich text e DPI

[Índice](../README.md) · [Inventário de arquivos/fontes](catalogo-fontes.json)

## Três contextos de fonte distintos

| Contexto | Fonte usada na configuração atual | Consequência |
| --- | --- | --- |
| Texto do gráfico Delphi | Arial por default do engine | Medida e pintura por GDI |
| Referência automatizada ECharts | Arial forçada pelo tema do harness | Evita comparar famílias diferentes por acaso |
| Interface do demo | Segoe UI; editor JSON Consolas | Não define a fonte dos gráficos |

A fonte padrão global do ECharts não deve ser inferida a partir da Arial que o
harness injeta. O perfil de comparação altera deliberadamente a família para
comparar layout com texto nativo. A referência completa continua disponível no
`option` resolvido de cada captura.

O repositório contém `assets/fonts/Inter.ttf`, sua licença `Inter.OFL.txt`, e
`DAC/Fonts/DAC-Components-Inter.ttf`. O catálogo registra hash/tamanho desses
arquivos; presença em disco não comprova instalação ou uso. O engine do chart não
registra Inter automaticamente. O tema DAC de cores também não troca a fonte.
Não distribuir uma fonte sob outro nome sem conferir licença, nomes reservados e
metadados da versão concreta.

## Criação, cache e medição

`NativeFont` monta `LOGFONT` com altura negativa `-round(fontSize * DPI/96)`.
Altura negativa pede altura de caracteres, distinta de uma altura de célula com
leading. FontSize do JSON é pixel lógico, não ponto tipográfico VCL. `Font.Height`
do formulário não deve ser copiado diretamente para `fontSize` sem conversão.

Peso é bold se string `bold` ou valor numérico >=600; italic depende de fontStyle.
Rotação alimenta escapement/orientation em décimos de grau. `CLEARTYPE_QUALITY`
solicita ClearType; o resultado efetivo depende do Windows, da fonte e do destino.
Nome de face é limitado ao espaço de `LOGFONT`, usualmente 31 caracteres úteis.

A chave do cache contém família, altura, peso, italic e rotação. Ao alcançar 256
fontes, o cache é limpo; o limite evita crescimento indefinido, mas não equivale a
LRU. A medição seleciona a fonte no mesmo DC de memória do desenho e restaura a
fonte anterior antes de liberar recursos. Mudança de DPI resulta em chave diferente.

`GetTextExtentPoint32` mede texto com a fonte selecionada; `DrawText` pinta no
mesmo HDC. Isso evita a divergência de usar Skia para medir e GDI para desenhar.
Mesmo assim, extent, box de layout e pixels ocupados por glifos são métricas
distintas. [Medição GDI](https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-gettextextentpoint32w),
[criação de fonte](https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-createfontindirectw).

Font fallback é decidido pelo Windows quando a família ou um glifo não existe.
O nome solicitado no log não prova qual arquivo realmente forneceu cada glifo.
Uma baseline rigorosa precisa registrar arquivos instalados, versão do sistema,
configuração de suavização, locale e DPI. O inventário atual não prova toda a cadeia
de fallback por glifo.

## Layout textual implementado

Títulos usam `TextHeight` para medir a altura com `NativeFont` no DC da superfície.
O cálculo considera extent nativo, lineHeight, padding, quebras explícitas e estilos
dos fragmentos rich text. `LayoutTitle` usa a mesma resolução de estilo na medição
e na pintura, posiciona o subtítulo após a altura medida e reserva mais 12 DIP antes
do grid. Isso corrige a proximidade entre título e primeira linha do gráfico.
Não acrescenta quebra automática por largura nem um solver de colisões de legenda.
[Contrato e limites](04-geometria-desenho.md) · [Capturas](../evidence/title-spacing-2026-09-22/README.md).

O método `Text` trata quebras explícitas de linha e fragmentos rich text. Não há
solver geral de parágrafos. `DT_NOPREFIX` mantém `&` literal; `DT_TOP` alinha ao topo.
Não se usa `DT_WORDBREAK` para quebra automática geral. Largura explícita aciona
redução e reticências; `height`, `align`, `verticalAlign` e `overflow` não possuem
todos os efeitos correspondentes apenas por serem aceitos no JSON.

Posicionamento horizontal deriva do alinhamento solicitado pelo chamador e da
medida do texto. O log registra texto, X/Y, width/height, rotate, font, fontSize e
um indicador aproximado de clipping. Com rotação, o extent não representa sozinho
a caixa transformada. Italic, acentos e descendentes podem ocupar pixels além de
uma estimativa simples. O teste atual não examina esses pixels de forma independente.

`DrawText` possui regras próprias de reticências, retorno e clipping; a presença
de `DT_END_ELLIPSIS` não substitui o contrato ECharts de truncamento.
[Referência DrawText](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-drawtextw).

## Truncamento: divergência V15

O caminho local retira caracteres até `TextWidth(prefixo + '...')` caber. O caminho
de texto do zrender tem estratégia diferente, com estimativa de largura e iterações
limitadas. Igualdade de fonte nominal não força igualdade da substring final.
[Código de truncamento zrender 6.1.0](https://github.com/ecomfe/zrender/blob/6.1.0/src/graphic/helper/parseText.ts).

Na execução preservada, ECharts apresenta `Produção ag...` e DAC apresenta
`Produção agrí...`. A bancada reprova conteúdo textual de V15, mesmo com landmarks
geométricos corretos. Não trocar a string esperada só para passar o teste. A decisão
pendente é reproduzir o contrato de truncamento com métricas nativas ou formalizar
uma adaptação nativa revisada; até isso ocorrer, o caso permanece reprovado.

Unicode deve ser considerado por grafemas, não apenas cortes arbitrários de
unidades UTF-16: pares substitutos, marcas combinantes e emojis exigem novos casos.
O teste atual de acentos portugueses não comprova todo esse domínio.

## Rich text

A sintaxe `{estilo|conteúdo}` seleciona um estilo em `rich`. O engine mede
fragmentos, mescla estilo e os desenha sequencialmente. Há suporte básico a cor,
fonte, padding escalar, background, contorno e sombra. O parser local não é o
modelo completo de caixas e linhas do ECharts.

Pendências explícitas: alinhamento vertical entre fragmentos de tamanhos diferentes,
width/height por fragmento, padding de quatro lados, alinhamento dentro de linhas,
combinação de quebra e truncamento, escaping, fragmentos vazios e rotação composta.
Linhas-guia/label collision precisam usar a caixa resultante inteira.

A documentação oficial separa estilos do bloco e dos fragmentos e mostra recursos
que o subconjunto nativo ainda não reproduz. Ela é a referência normativa, não uma
lista de recursos automaticamente disponíveis.
[Rich text oficial](https://echarts.apache.org/handbook/en/how-to/label/rich-text/).

## Skia e GDI no mesmo quadro

Antes de texto GDI, a superfície Skia precisa estar sincronizada. Depois do texto,
`GdiFlush` conclui comandos e `OpaqueRect` força alpha FF na região correspondente.
Isso é necessário porque GDI tradicional não preserva o canal alpha de um DIB da
mesma forma que o renderer Skia.

A correção atual atua numa região retangular ampla, não apenas nos pixels do glifo.
Ela pressupõe composição final opaca. Não prova transparência correta sobre fundos
externos, nem autoriza tratar o PNG exportado como RGBA fiel: o exportador atual
converte para bitmap 24 bits antes de gravar PNG.

Fundos, bordas e sombras de caixa são desenhados por Skia; glifos por Windows.
Texto e tooltip permanecem no buffer antes do BitBlt final. Pintar texto diretamente
na janela após o BitBlt quebraria essa composição e a prova temporal.

## DPI real e DPI sintético

No CreateWnd, o host tenta `GetDpiForWindow`. `WM_DPICHANGED` atualiza o DPI efetivo,
com mínimo 96, e invalida o quadro. A API/CLI de diagnóstico injeta DPI sintético;
isso verifica escalas matemáticas e fontes, mas não valida os eventos reais de
troca de monitor ou o awareness do processo.

| DPI | Escala | Fonte 12 px lógicos | Margem 60 px lógicos |
| --- | --- | --- | --- |
| 96 | 1 | 12 px físicos | 60 px |
| 120 | 1,25 | 15 px | 75 px |
| 144 | 1,5 | 18 px | 90 px |
| 192 | 2 | 24 px | 120 px |

O arredondamento da fonte é inteiro; a geometria Skia pode permanecer fracionária.
Não arredondar todas as coordenadas cedo para tentar eliminar borramento: isso pode
violar o limite geométrico de 0,5 pixel físico. Linhas de 1 px e suas âncoras exigem
verificação específica de antialias e alinhamento ao pixel.

Os projetos HighDPI e NoHighDPI compartilham formulário; `AppEnableHighDPI` diferente
não prova sozinho PerMonitorV2. A execução registrada encontrou um monitor. Passagem
real entre monitores 96/120/144/192 continua pendente, inclusive mensagens de DPI
de janelas filhas e reaquisição de métricas depois de recriar handle.

## Baseline Windows a construir

Cada amostra deve registrar: string original e exibida, fonte solicitada/resolvida,
arquivo/hash quando identificável, tamanho, peso, estilo, DPI, rotação, âncora,
caixa esperada e efetiva, fundo, suavização, versão Windows e imagem sem máscara.

A avaliação deve separar conteúdo, âncora, largura/altura, baseline, clipping,
sobreposição e rasterização. Máscara de tolerância de glifo não pode esconder
deslocamento do bloco, texto ausente ou sobreposição. Baseline nova exige revisão
da imagem e do diff; não copiar automaticamente a saída que acabou de falhar.
