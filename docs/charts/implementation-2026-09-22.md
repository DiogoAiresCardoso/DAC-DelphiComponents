> **Estado atual — 23/09/2026:** consulte a [consolidação atual](consolidation-2026-09-23.md) para API tipada, validação transacional, espaço do título e evidências posteriores. O conteúdo abaixo preserva sua etapa histórica.

# TDACChart — implementação e evidências de 22/09/2026

Conhecimento técnico detalhado: [manual consolidado](README.md). As imagens,
geometrias, logs e sequências citadas neste relatório foram preservadas no
[arquivo de evidências](evidence/2026-09-22/README.md), sem nova execução ou promoção de baseline.

**A execução integral do plano ainda não está concluída.** A nova API, o renderer,
o demo exclusivo e a bancada estão implementados e foram compilados/executados.
O aceite de fidelidade visual e ausência de cintilação permanece aberto. Não usar
este relatório como aprovação de produção ou como declaração de paridade completa.

## Código entregue

| Responsabilidade | Fonte |
| --- | --- |
| Host VCL, DataLink, timers, apresentação e métricas | `Source/Controls/DAC.Components.Controls.Charts.pas` |
| Opções persistentes, coleções, JSON, validação e Assign | `Source/Controls/DAC.Components.Charts.Options.pas` |
| Dados, escalas, geometria, Skia, texto Windows e hit-test | `Source/Skia/DAC.Components.Charts.Engine.pas` |
| DIB 32 bits, Skia raster direto, GDI, PNG e BitBlt | `Source/Skia/DAC.Components.Charts.Surface.pas` |
| Formulário independente, fixo em DFM | `demo-charts/DACChartsDemo.Main.pas/.dfm` |
| Fixtures e comparação com Canvas ECharts | `Tests/Charts.Visual/` |
| Asserções Delphi e ciclo de vida | `Tests/DACComponentsCharts.dpr` |

A antiga API de ChartType/DataMode/Appearance foi substituída por `Options`.
Área usa `line` + `areaStyle`; rosca usa `pie` + dois raios. Foram migrados os
gráficos do DFM do demo principal e as referências da suíte histórica de interação.
Os packages incluem as novas units. Não houve commit, instalação de package na IDE
nem alteração deliberada dos componentes fora do escopo de gráficos.

O host compõe em duas superfícies persistentes. Skia e GDI escrevem no DIB de
composição; o quadro completo troca com o frontal antes de um único BitBlt. O texto
e o tooltip não são desenhados na janela depois dessa apresentação. O timer usa
33 ms e o avanço usa TStopwatch. Recriação/destruição de handle cancela o timer.
Os testes distinguem captura do buffer, captura do DC da janela e captura da tela.

## Escopo funcional presente

- Séries cartesianas bar/line, áreas, empilhamento por sinal, orientação horizontal,
  eixos category/value/time, limites explícitos e inversão; pie e raios de rosca.
- Dados inline e dataset, dimensões/encode, orientação por linhas/colunas, NULL,
  adapter de TClientDataSet com cursor independente e filtro preservado.
- Título/subtítulo; labels, formatter, fontes nativas, rotação, rich text básico,
  truncamento e tentativa de evitar colisões; legendas e paginação.
- Tooltip item/axis/none confinado, marcadores, ponteiro de eixo, atrasos e eventos Delphi.
- Paleta ECharts 6.1.0, cores/opacidade, gradientes, sombras, bordas, traços,
  smooth/step/símbolos; estilos de estados e seleção de setores.
- JSON exportável; importação pelo host validada antes da substituição; caminhos
  de opções desconhecidas; TPersistent/Assign, BeginUpdate/EndUpdate e round-trip DFM.
- Demo com Galeria, Configuração, Elementos visuais, Comparação e Animação/estabilidade.
  Inclui dataset local, controles de propriedades, editor JSON e modo automatizado.

Esses recursos possuem níveis diferentes de cobertura. A presença de um campo na
API ou de uma demonstração **não equivale a fidelidade aprovada**.

## Execuções verificadas

Saídas isoladas em `tmp/chart-implementation/` e `tmp/chart-validation-final/`.
Delphi 10.2 Tokyo, compilador Win32 32.0; Skia4Delphi instalado no workspace.

| Verificação | Resultado |
| --- | --- |
| Package `DACSkiaComponents.dproj` | Compilou |
| Demo principal `demo/Demo.dproj` | Compilou |
| Inicialização/streaming do demo principal | `DACDemoStartup: PASS` |
| Demo exclusivo `DACChartsDemo.dproj` | Compilou e executou |
| Perfis `DACChartsHighDpi` e `DACChartsNoHighDpi` | Compilaram e executaram C01 com resultado OK |
| Testes Delphi de gráficos | Passaram, incluindo os 14 casos analíticos originais |
| Geometria contra ECharts | **29/29** casos dentro de 0,5 pixel nos landmarks verificados |
| Conteúdo de texto contra ECharts | **28/29**; V15 reprovado por truncamento diferente |
| Clipping de texto registrado | Nenhum corte de viewport detectado nos 29 casos; rotação/rich text ainda exigem inspeção |
| Captura do DC da janela versus buffer | Iguais nos 29 casos estáticos |
| Pintura por elemento / baseline Windows aprovada | Pendente |
| Continuidade física da tela | **Inconclusiva** |

Os testes Delphi exercitaram criação sem Parent/sem HWND, JSON inválido sem perda
da configuração anterior, campo ausente, números decimais, DFM, setter do designer,
filtro, NULL, atualização, posição do cursor original e ausência de releitura de
dataset em alteração visual. Também executaram resize com comparação byte a byte
do PNG antes/depois, DPI sintético 96/120/144/192, hover repetido, estabilização de
objetos GDI após aquecimento, término da animação, recriação do handle e
minimizar/restaurar. DPI sintético não é passagem física entre monitores.

A suíte histórica `DACComponentsInteraction.dpr` não compilou por ausência da unit
preexistente `DAC.Components.Controls.DataGrid.pas`. O projeto atual aponta para
outro entrypoint, `DACComponentsInteraction.Current.dpr`, que não cobre gráficos.
Não se apresenta esse teste histórico como aprovado.

## Referência congelada

- ECharts **6.1.0**, renderer Canvas, fundo branco.
- SHA-256 do bundle: `b66b25aeb4df84e33199dc21694014d336d222cbd9deb0e5a7c14bd6aa0d0fd0`.
- Playwright **1.62.1**, Chromium **151.0.7922.34**.
- Arial, en-US, UTC, DPR 1, viewport 720×420.
- Fonte Arial explicitamente fixada no tema da bancada; demais opções vêm das fixtures.

O runner verifica versão do ECharts, hash do bundle, versão do Playwright e versão
do Chromium. Não incorpora navegador ao runtime Delphi. Atribuições e licença
estão em `echarts-reference/NOTICE.md` e nos arquivos oficiais adjacentes.

## Desempenho e sequências

| Execução | Pontos realmente desenhados | DPI / dimensão | p95 produção | Máximo produção | Observação |
| --- | ---: | --- | ---: | ---: | --- |
| `tmp/chart-validation-final/demo-captures` | 996 / 6 séries | 144 / 720×420 físicos | 16,976 ms | 21,7541 ms | 121 buffers registrados, 78 ms entre capturas no pior intervalo |
| `tmp/chart-animation-run-02` | 996 / 6 séries | 144 / 720×420 físicos | 18,4645 ms | 23,9607 ms | 98 buffers; 92 distintos; atualizações interrompem animações |
| `tmp/chart-load-10000` | 10.000 / 6 séries | 144 / 720×420 físicos | 119,5739 ms | 135,4148 ms | Fora da meta de 30 fps; carga adicional, acima do perfil de aceite |

O perfil de 996 pontos atendeu à meta nesta máquina e nessa execução. A captura PNG
e sua gravação não estão incluídas no tempo de produção do quadro; o intervalo entre
capturas é registrado separadamente. Métricas do início da implementação foram
**descartadas**: a conversão regional de decimais descartava pontos. A leitura foi
corrigida com `TJSONNumber.AsDouble`, recebeu teste de regressão e o benchmark agora
exige que todos os pontos esperados tenham marcas de desenho.

Em repouso a animação encerrou; houve zero leituras de dataset nos benchmarks de
dados manuais. Não se inferem ausência de vazamentos em execução prolongada ou
desempenho de múltiplos gráficos animados a partir desses ensaios curtos.

O modo `--screen` tenta capturar o retângulo real da tela, somente quando a janela
está visível, em primeiro plano e sem outra janela sobre seus cantos. Nesta sessão
nenhum quadro foi elegível. Mesmo capturas após cada apresentação não bastariam
para excluir transientes entre apresentações. É necessária gravação temporal
independente em uma sessão desktop controlada. Foi detectado apenas um monitor;
passagem real entre monitores não foi executada.

## Diferenças e trabalho ainda necessário

1. **V15:** o truncamento nativo mostra `Produção agrí...`; a referência mostra
   `Produção ag...`. A comparação reprova esse conteúdo; não foi criada máscara ou
   baseline para esconder a diferença.
2. Layout de rich text, alinhamento vertical, padding composto, quebra automática,
   colisões de labels/linhas-guia e todas as combinações de legenda ainda não têm
   paridade completa. Há diferenças de pintura/âncoras nas sobreposições.
3. O modelo publica os grupos centrais, mas a cobertura propriedade a propriedade
   do Object Inspector ainda é incompleta. Algumas opções aninhadas precisam de
   validação mais estrita e não têm todos os valores ECharts implementados.
4. Eixo temporal tem formatação básica, sem a hierarquia completa de calendário do
   ECharts. Larguras diferentes entre grupos de barras, setores com padAngle/minAngle,
   todos os estados e layouts automáticos de limites ainda precisam ser completados.
5. Entrada e atualização numérica existem; saída, mudança de X, reordenação sem ids
   estáveis e transições universais ainda precisam de implementação/testes dedicados.
6. A comparação analítica mede barras, pontos e setores. Ainda faltam gates de todas
   as âncoras de texto, paths Bézier, clipping e ordem de pintura por elemento,
   acompanhados de baseline Windows revisada. O percentual global é apenas diagnóstico.
7. Faltam a matriz completa de tamanhos/DPI/temas/combinações, interação automatizada
   de todos os recursos, execução prolongada, múltiplos gráficos animados e captura
   física contínua com passagem entre monitores.

Zoom, múltiplos eixos, tooltip externo/HTML e demais famílias continuam explicitamente
fora desta etapa. O demo informa essas indisponibilidades.

## Evidências para revisão

- `tmp/chart-validation-final/demo-captures/gallery.png`: galeria efetivamente renderizada.
- `tmp/chart-validation-final/reference/*.png` e `*.json`: imagens, opções e layouts ECharts.
- `tmp/chart-validation-final/demo-captures/*-overlay.png` / `*-diff.png`: sobreposição e diferenças.
- `tmp/chart-validation-final/demo-captures/comparison.json`: resultados separados por cenário.
- `tmp/chart-validation-final/demo-captures/temporal.json`: sequência, ambiente e métricas.
- `tmp/chart-animation-run-02/frames/`: sequência com atualização animada.
- `tmp/chart-load-10000/temporal.json`: carga adicional.

Esses diretórios são artefatos locais de execução, não baselines aprovadas. O runner
recusa reutilizar um diretório de evidências e nunca promove capturas automaticamente.
