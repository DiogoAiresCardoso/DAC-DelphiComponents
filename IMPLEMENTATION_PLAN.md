# Plano de Implementacao - Skia Components

Atualizado em 2026-06-18.

Este plano consolida o pente fino arquitetural do pacote de componentes VCL + Skia. A validacao desta etapa foi estatica; os pacotes Delphi nao foram compilados.

## Premissas atuais

- Skia4Delphi e obrigatorio para desenhar o chrome visual dos componentes.
- Textos de formulario, labels, helpers, captions e conteudo de inputs devem usar a API nativa do Windows/VCL quando isso entregar maior nitidez.
- Cores devem ser centralizadas e expostas como `TAlphaColor`.
- Componentes compostos precisam ser seguros em design-time e runtime quando ainda nao possuem `Parent` ou janela criada.
- Nao chamar `ClientWidth`, `ClientHeight`, `ClientRect`, `Handle`, `HandleNeeded`, `BringToFront`, `SendToBack` ou `SetZOrder` antes de validar `Parent`, `HandleAllocated` e o estado de design-time.
- Inputs e controles devem ter variantes normais e data-aware, mantendo classes separadas.

## Achados do pente fino

### 1. Base visual Skia subutilizada

Existe uma base em `Source/Controls/MaxxRural.Components.Controls.SkiaControl.pas` com renderer, painters, paintbox e eventos de mouse. Mesmo assim varios controles repetem o mesmo ciclo de `FPaintBox`, `FRenderer`, `FBackgroundPainter`, `FBorderPainter`, `FIconPainter`, `PaintBoxDraw`, `ScaleMetric`, `ChangeScale`, `UpdatePaintBoxBounds` e `WMEraseBkgnd`.

Acao proposta:
- Criar uma base mais explicita para superficie Skia, por exemplo `TMaxxRuralCustomSkiaSurface`.
- Centralizar nela renderer, painters, invalidacao, DPI, cor de superficie do parent, limpeza de fundo e regras seguras de design-time.
- Migrar gradualmente controles puramente desenhados para essa base.

Resultado esperado:
- Menos duplicidade.
- Menos risco de regressao em High DPI.
- Menos risco de erro `Control '' has no parent window`.

### 2. Inputs repetem label, helper, required e status

`Edit`, `Memo`, `ComboBox`, `DateTimePicker` e `ButtonEdit` repetem conceitos de label, required, helper text, status visual, borda, foco, hover, tamanho e cor de parent.

Acao proposta:
- Criar uma base para inputs com chrome nativo/Skia, por exemplo `TMaxxRuralCustomInputChrome`.
- Extrair um record/classe de appearance, por exemplo `TMaxxRuralInputAppearance`.
- Centralizar metricas de altura, raio, padding, label, helper, status e foco.
- Manter o texto do input em controle nativo/VCL quando aplicavel.

Resultado esperado:
- `Edit`, `Memo`, `ComboBox`, `DateTimePicker` e `ButtonEdit` passam a compartilhar comportamento visual.
- Ajustes de fonte, foco, helper e required passam a ser feitos em um unico ponto.

### 3. Status semantico duplicado

Ha enums e funcoes de cor parecidas para status em inputs, badges, progress, summary cards e grid.

Acao proposta:
- Criar um status semantico comum no Core ou DesignSystem, por exemplo `TMaxxRuralSemanticStatus`.
- Criar um resolver central, por exemplo `TMaxxRuralSemanticColors`, retornando `Accent`, `Background`, `Text`, `Border` e `SupportText` como `TAlphaColor`.
- Manter aliases especificos apenas quando forem importantes para a API publica de um componente.

Resultado esperado:
- Sucesso, alerta, perigo, informacao e normal ficam consistentes em toda a suite.
- Badges, chips, progress, cards e inputs deixam de duplicar regras de cor.

### 4. Parent surface color repetido

`TMaxxRuralComponentColors.ResolveParentSurface` ja centraliza a leitura segura da superficie do parent. Entretanto varios controles ainda criam wrappers locais para esse calculo.

Acao proposta:
- Subir `ParentSurfaceColor` para a base visual comum.
- Todos os componentes devem usar esse ponto unico para apagar excessos de borda e respeitar containers claros ou escuros.

Resultado esperado:
- Menos divergencia entre inputs, containers, tabs, cards e controles.
- Melhor comportamento em containers escuros.

### 5. Selectors agrupam varias classes concretas

`Source/Controls/MaxxRural.Components.Controls.Selectors.pas` concentra checkbox, radio, toggle e slider. Isso contraria a diretriz do pacote de manter classes concretas em arquivos especificos.

Acao proposta:
- Dividir em unidades especificas:
  - `MaxxRural.Components.Controls.CheckBox.pas`
  - `MaxxRural.Components.Controls.RadioButton.pas`
  - `MaxxRural.Components.Controls.ToggleSwitch.pas`
  - `MaxxRural.Components.Controls.Slider.pas`
- Manter uma unidade agregadora somente se for util para compatibilidade.

Resultado esperado:
- Melhor navegabilidade.
- Menos conflitos ao evoluir cada componente.
- Menos risco de alterar um controle e quebrar outro.

### 6. Hooks registrados sem implementacao

`Source/Hooks/MaxxRural.Components.Hooks.Register.pas` existe e e idempotente, mas nao ha hooks concretos registrados.

Acao proposta:
- Manter o arquivo como ponto oficial de registro.
- Quando hooks forem criados, limitar a classes `TMaxxRural...` ou wrappers especificos.
- Registrar e desregistrar em pares.
- Evitar hook global em classe VCL base.

Resultado esperado:
- Arquitetura preparada para hooks sem efeitos colaterais globais.

### 7. Classe base registrada no design-time

`TMaxxRuralSkiaControl` aparece no registro de design-time junto dos componentes de uso final.

Acao proposta:
- Avaliar se essa classe deve ser removida da paleta.
- Registrar apenas componentes finais ou bases realmente utilizaveis pelo usuario.

Resultado esperado:
- Paleta mais limpa.
- Menos risco de usuario arrastar uma classe de infraestrutura para o formulario.

### 8. Grid/Scroll Container devem seguir os PNGs de referencia

Os componentes `GridContainer` e `ScrollContainer` devem ser implementados com base visual nos arquivos PNG de assets:

- `assets/Grid Container.png`
- `assets/Scroll Container.png`

O arquivo `maxui-grid-scroll-container-spec.md` nao deve ser usado como contrato de implementacao. Ele pode conter premissas divergentes do design system atual, especialmente sobre Skia opcional. A referencia valida e a imagem, traduzida para componentes VCL desenhados com Skia.

Acao proposta:
- Levantar, diretamente dos PNGs, as variantes, estados, metricas visuais e composicoes esperadas.
- Implementar todo chrome visual com Skia: background, bordas, scrollbars, grids, gutters, linhas-guia, estados e indicadores.
- Usar tokens do `DesignSystem` para cores, raios, spacing, bordas e foco.
- Manter `GridContainer` como container de layout responsivo por linhas, colunas, spans, gutters e areas.
- Manter `ScrollContainer` como container com conteudo rolavel e barras customizadas em Skia.
- Garantir comportamento seguro em design-time quando ainda nao houver `Parent` ou janela criada.

Resultado esperado:
- Novos containers nascem alinhados com os assets visuais oficiais.
- Nenhum fallback visual sem Skia e nenhuma dependencia do arquivo `.md` antigo.

### 9. Data-aware ainda precisa de familia propria

Inputs e controles devem existir em variantes normais e data-aware.

Acao proposta:
- Criar uma pasta ou grupo de unidades data-aware, por exemplo `Source/Controls/DataAware`.
- Implementar descendentes/wrappers com `TFieldDataLink`:
  - `TMaxxRuralDBEdit`
  - `TMaxxRuralDBMemo`
  - `TMaxxRuralDBComboBox`
  - `TMaxxRuralDBDateTimePicker`
  - `TMaxxRuralDBCheckBox`
  - `TMaxxRuralDBRadioButton` ou grupo equivalente
  - `TMaxxRuralDBToggleSwitch`
- Manter a logica de dados fora dos painters.

Resultado esperado:
- API clara para uso com dataset.
- Componentes visuais permanecem reutilizaveis sem dependencia de dados.

### 10. DataGrid deve continuar baseado em TDBGrid

A grid precisa ser implementada sobre `TDBGrid`, com coluna de acoes selecionavel. A unidade atual tende a concentrar estilo, desenho, hit-test e acoes em um unico arquivo.

Acao proposta:
- Manter a base `TDBGrid`.
- Separar responsabilidades em unidades auxiliares:
  - tipos e colunas
  - desenho de status
  - desenho e hit-test de acoes
  - tokens visuais da grid
- Garantir que a coluna de acoes tenha area clicavel/selecionavel clara e acessivel por mouse e teclado.

Resultado esperado:
- Grid evolui sem virar um componente monolitico.
- Acoes de linha ficam testaveis e reutilizaveis.

### 11. Charts devem seguir os componentes visuais da Ancoragem

A implementacao visual dos charts da suite deve usar como base os componentes ja existentes em `Ancoragem\View\Components\Charts`.

Arquivos de referencia:
- `MaxxRural.View.Component.Chart.pas`
- `MaxxRural.View.Component.Chart.Types.pas`
- `MaxxRural.View.Component.ChartAxis.pas`
- `MaxxRural.View.Component.ChartGrid.pas`
- `MaxxRural.View.Component.ChartLegend.pas`
- `MaxxRural.View.Component.ChartSideLegend.pas`
- `MaxxRural.View.Component.ChartFactory.pas`
- `MaxxRural.View.Component.BarChart.pas`
- `MaxxRural.View.Component.LineChart.pas`
- `MaxxRural.View.Component.DoughnutChart.pas`

Acao proposta:
- Levantar a arquitetura visual atual desses charts antes de criar componentes novos no pacote.
- Reaproveitar a linguagem visual: eixos, grid, legenda, cores, espessuras, preenchimentos, labels e densidade.
- Traduzir a implementacao para a arquitetura do pacote `SkiaComponents`, mantendo units separadas por responsabilidade.
- Usar o renderer/tokens compartilhados da suite e evitar duplicar paleta, calculo de escala, desenho de legenda ou grid.
- Preservar Skia como mecanismo visual dos charts.
- Expor componentes finais para barra, linha, area e donut, alinhados ao escopo da suite.

Resultado esperado:
- Charts do pacote ficam visualmente iguais aos charts usados na Ancoragem.
- Evolucoes futuras em legenda, eixos e grid podem ser centralizadas.
- A demo passa a demonstrar charts sem criar uma segunda identidade visual.

### 12. Systembar do form deve seguir o layout de referencia

O form de demonstracao/host deve ter a area superior ajustada para se aproximar do layout de referencia enviado pelo usuario, apenas na systembar.

Escopo visual:
- faixa superior escura com tons verdes do design system;
- icone da aplicacao a esquerda;
- titulo do form em destaque;
- botoes de janela a direita: minimizar, maximizar/restaurar e fechar;
- altura, espacamentos, raio externo e estados de hover coerentes com a imagem;
- restante do formulario nao deve ser redesenhado por esta tarefa.

Fora do escopo:
- nao criar `Toolbar`, `Topbar`, menu lateral ou componente reutilizavel de barra de acoes;
- nao alterar as tabs, formularios, inputs ou conteudo interno por causa da systembar;
- nao registrar essa systembar como componente da suite, salvo decisao futura explicita.

Acao proposta:
- Criar ou ajustar apenas a camada de systembar do form demo/host.
- Desenhar o chrome visual com Skia e tokens do `DesignSystem`.
- Preservar comportamento de janela: arrastar, duplo clique para maximizar/restaurar, minimizar, maximizar/restaurar, fechar, estados ativo/inativo e DPI.
- Se o form for borderless/custom caption, tratar `WM_NCHITTEST` e areas dos botoes de forma segura.
- Manter o codigo isolado do runtime dos componentes, para nao transformar a systembar em dependencia dos controles.

Resultado esperado:
- Demo/host fica visualmente alinhado ao layout moderno apresentado.
- Ajuste permanece limitado a systembar.
- A suite continua sem toolbar/topbar reutilizavel, conforme escopo.

## Plano priorizado

### P0 - Estabilizacao e seguranca de design-time

- Centralizar regra segura de parent/handle em uma base comum.
- Remover qualquer chamada antecipada a handle, client rect ou z-order em construtores, setters, `Resize`, `Loaded` e leitura de DFM.
- Tratar `assets/Grid Container.png` e `assets/Scroll Container.png` como contrato visual dos novos containers.

### P1 - Base visual e base de inputs

- Criar `TMaxxRuralCustomSkiaSurface`.
- Criar `TMaxxRuralCustomInputChrome`.
- Migrar primeiro `Edit`, `Memo`, `ComboBox`, `DateTimePicker` e `ButtonEdit`.
- Preservar textos com API nativa Windows/VCL.

### P2 - Tokens semanticos e appearance

- Criar status semantico comum.
- Criar resolver de cores semanticas.
- Consolidar appearance de inputs.
- Revisar badges, chips, progress e cards para usar o mesmo resolver.

### P3 - Organizacao de unidades

- Dividir `Selectors.pas`.
- Avaliar remocao de `TMaxxRuralSkiaControl` da paleta de design-time.
- Criar unidades auxiliares para `DataGrid`.

### P4 - Data-aware

- Implementar familia DB-aware para inputs e controles.
- Registrar componentes data-aware no design-time.
- Criar exemplos no demo usando dataset em memoria.

### P5 - Novos containers

- Implementar `TMaxxRuralScrollContainer`.
- Implementar `TMaxxRuralGridContainer`.
- Implementar row/column/area/gutter/span conforme assets.
- Validar com conteudo claro, escuro, scroll vertical, horizontal e ambos.

### P6 - Suite restante

- Continuar componentes do suite:
  - seletores e controles data-aware
  - tabela/data grid
  - toast, tooltip e modal
  - toolbar/status bar quando aplicavel ao escopo atual
  - charts baseados em `Ancoragem\View\Components\Charts`
  - report viewer
- Atualizar demo em design-time, mantendo uma tab por familia.

### P7 - Host/demo visual

- Ajustar somente a systembar do form para seguir o layout de referencia.
- Manter a systembar fora do escopo de componentes reutilizaveis da suite.
- Preservar comportamento nativo de janela e compatibilidade com DPI.

## Validacao executada neste pente fino

- Estrutura do pacote, runtime, design-time, controls, design system, hooks, assets e demo foi revisada estaticamente.
- Foram buscadas duplicidades de renderer, painters, paintbox, DPI, z-order, parent surface, status e labels.
- Nao houve compilacao de pacote Delphi nesta etapa.

## Execucao 2026-06-19

### Implementado

- Base visual segura:
  - `TMaxxRuralSkiaControl` passou a validar `Parent`, `csLoading`, `csDesigning`, `HandleAllocated` e existencia do `PaintBox` antes de redraw/foco/cursor.
  - A classe base deixou de ser registrada na paleta de design-time.
- Tokens semanticos:
  - Criado `MaxxRural.Components.DesignSystem.SemanticColors.pas` com status comum e resolver central de cores em `TAlphaColor`.
- Containers:
  - Criado `TMaxxRuralScrollContainer`, com chrome Skia, cor de parent e barras preparadas para customizacao visual.
  - Criado `TMaxxRuralGridContainer`, com layout em colunas, gutter, padding, spans via `Tag` e chrome Skia.
  - Demo recebeu exemplos de ambos na aba `Containers`.
- Data-aware:
  - Criada familia `Source/Controls/DataAware` com `TFieldDataLink`:
    - `TMaxxRuralDBEdit`
    - `TMaxxRuralDBMemo`
    - `TMaxxRuralDBComboBox`
    - `TMaxxRuralDBDateTimePicker`
    - `TMaxxRuralDBCheckBox`
    - `TMaxxRuralDBRadioButton`
    - `TMaxxRuralDBToggleSwitch`
    - `TMaxxRuralDBSlider`
  - Componentes registrados na paleta `MaxxRural Skia DB`.
- DataGrid:
  - `TMaxxRuralDataGrid` permanece baseado em `TDBGrid`.
  - `Columns stored False` evita serializacao de `TColumn.Alignment` no DFM do demo.
  - Demo passou a instanciar a grid em design-time, dentro de `SectionGrid`.
- Componentes restantes:
  - Criados componentes iniciais para charts: barra, linha, area e doughnut.
  - Criados componentes iniciais para toast/modal.
  - Criados componentes iniciais para status bar.
  - Criado componente inicial para report viewer.
  - Todos foram adicionados ao runtime package e ao registro design-time.
- Demo:
  - Reorganizado para uma tab principal por familia.
  - A primeira tab e renderizada sempre na inicializacao.
  - A troca de tabs deixou de forcar visibilidade recursiva em todos os descendentes, evitando filhos windowed vazando para paginas erradas.
  - Adicionadas tabs: `Status`, `Feedback`, `Charts` e `Report`.
  - Pagina `Paginacao` mantem os filhos dentro do parent correto.
  - Criada systembar visual no form demo, fora do runtime da suite e sem registrar toolbar/topbar reutilizavel.

### Decisoes preservadas

- Chrome visual segue com Skia4Delphi obrigatorio.
- Texto de formulario, labels, helpers, placeholders, captions e conteudo editavel segue preferencialmente pela API nativa Windows/VCL para casar nitidez, fonte e hinting do NovoMaxxRural.
- `assets/Grid Container.png` e `assets/Scroll Container.png` sao a referencia visual dos novos containers; o arquivo `.md` antigo nao deve guiar a implementacao.
- Charts devem continuar evoluindo com base nos componentes de `Ancoragem\View\Components\Charts`.

### Evolucoes arquiteturais ainda positivas

- Extrair uma base comum de input chrome para reduzir duplicidade entre edit, memo, combobox, datetimepicker e buttonedit.
- Dividir `Selectors.pas` em unidades especificas de checkbox, radio, toggle e slider.
- Dividir a grid em units auxiliares:
  - tipos/colunas
  - status cell painter
  - action cell hit-test/painter
  - tokens visuais da grid
- Evoluir `ScrollContainer` com barra customizada completa em Skia e eventos de scroll horizontal/vertical conforme os PNGs.
- Evoluir `GridContainer` com rows/areas nomeadas e breakpoints responsivos.
- Fazer demo DB-aware com dataset em memoria em uma etapa que possa ser compilada e validada no Delphi.

### Validacao desta execucao

- Validacao estatica de registros, DFM e units.
- Confirmado que o demo nao serializa `TDBGrid.Columns`/`TColumn.Alignment`; a ocorrencia de `Columns = 3` pertence ao `TMaxxRuralGridContainer`.
- Confirmado que `DesignIntf` permanece restrito ao design-time.
- Confirmado que as novas units estao no runtime package e registradas no design-time.
- A pedido do usuario, os pacotes Delphi nao foram compilados.
