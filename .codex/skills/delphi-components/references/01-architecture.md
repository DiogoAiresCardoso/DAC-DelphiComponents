# Arquitetura da suíte

## Camadas

```text
Design tokens
    ↓
Renderer Skia, assets e ícones
    ↓
Controles VCL primitivos
    ↓
StyleHooks localizados
    ↓
Componentes compostos
    ↓
Galeria, packages e testes
```

## Dependências permitidas

```text
Core        → RTL, VCL.Graphics, System.Skia, Vcl.Skia
Controls    → Core, RTL, VCL, System.Skia, Vcl.Skia
Hooks       → Core, Controls, VCL.Themes
DesignTime  → Runtime, DesignIntf
Demo/Tests  → Runtime
```

`Core` não conhece controls. `Controls` não conhece hooks. O registro central dos hooks fica em `Hooks` e é puxado pelo package/runtime ou pelo projeto. Skia é dependência obrigatória do runtime visual; se a versão alvo não fornecer `System.Skia`/`Vcl.Skia`, a implementação deve parar e relatar o bloqueio.

## Estrutura de units

```text
Source/Core
├── MaxUI.Types.pas
├── MaxUI.Dpi.pas
├── MaxUI.Theme.pas
├── MaxUI.Icons.pas
├── MaxUI.Painter.pas
└── MaxUI.Skia.pas

Source/Controls
├── MaxUI.Controls.Base.pas
├── MaxUI.Controls.Buttons.pas
├── MaxUI.Controls.Inputs.pas
├── MaxUI.Controls.Selectors.pas
├── MaxUI.Controls.Choices.pas
├── MaxUI.Controls.Tabs.pas
├── MaxUI.Controls.Cards.pas
├── MaxUI.Controls.Data.pas
├── MaxUI.Controls.Feedback.pas
├── MaxUI.Controls.Charts.pas
└── MaxUI.Controls.Report.pas

Source/Hooks
├── MaxUI.Hooks.Buttons.pas
├── MaxUI.Hooks.Inputs.pas
├── MaxUI.Hooks.Selectors.pas
├── MaxUI.Hooks.Choices.pas
└── MaxUI.Hooks.Register.pas
```

## Hierarquia de classes

```text
TGraphicControl
├── TMaxPill
│   ├── TMaxBadge
│   ├── TMaxChip
│   └── TMaxTag
├── TMaxLinearProgress
├── TMaxCircularProgress
├── TMaxSpinner
└── TMaxChart

TCustomControl
├── TMaxSurface
│   ├── TMaxSection
│   ├── TMaxCard
│   │   └── TMaxSummaryCard
│   └── TMaxReportViewer
├── TMaxToggleSwitch
├── TMaxSlider
├── TMaxStatusBar
├── TMaxToast
├── TMaxTooltip
├── TMaxModalPanel
├── TMaxPagination
└── TMaxSpinField

TButton
└── TMaxButton
    ├── TMaxIconButton
    └── TMaxSplitButton

TEdit
└── TMaxEdit
    ├── TMaxSearchEdit
    └── TMaxPasswordEdit

TMaskEdit
└── TMaxMaskedEdit

TMemo
└── TMaxMemo

TComboBox
└── TMaxComboBox

TDateTimePicker
├── TMaxDatePicker
└── TMaxTimePicker

TCheckBox
└── TMaxCheckBox

TRadioButton
└── TMaxRadioButton

TPageControl
└── TMaxPageControl

TStringGrid
└── TMaxStringGrid

TDBGrid
└── TMaxDBGrid
```

## Serviços centrais

### `TMaxTheme`

Mantém a paleta e métricas. Controles consultam `TMaxTheme.Palette` e `TMaxTheme.Metrics`, nunca repetem cores. Uma revisão incremental permite invalidar caches.

### `TMaxPainter`

Desenha superfícies, foco, botões, campos, glyphs, toggles, sliders, pills e progresso usando Skia. Ele não acessa forms, banco de dados ou estado de negócio. Prefira separar um renderer Skia no estilo `TMaxxRuralSkiaRenderer`: cache de fontes, paints e SVGs, primitivas como `FillRoundRect`, `StrokeRoundRect`, texto, texto centralizado, SVG e ellipsis eficiente.

### `TMaxIconPainter`

Desenha ou resolve ícones lineares/SVG para o renderer Skia, preservando IDs semânticos. Aplicações podem substituir por asset resolver central, mas não por caminhos hardcoded dentro de componentes.

### `TMaxThemeManager`

Componente não visual que aplica tema/tokens e propaga revisão de tema. Não exponha `UseSkia` como desligamento visual: Skia é sempre ativo.

### `TMaxSkiaVisualComponent`

Baseie componentes compostos no padrão da Ancoragem: `Measure`, `Arrange`, `Draw`, `HitTest`, eventos de mouse/wheel/teclado, `Visible`, `Enabled`, foco, estados visuais, acessibilidade, `NeedsLayout`, `NeedsPaint` e `Theme` injetável.

### `TMaxSkiaContainer`

Containeriza componentes por camadas, aplica tema, desenha em ordem, faz hit-test em ordem inversa, roteia hover, pressed, captura, foco, teclado, cursor e invalidação. Forms não devem manter campos soltos de `HoveredIndex`, `PressedButton` ou equivalentes.

## Estratégia de StyleHook

Use hooks apenas quando o comportamento nativo do controle vale ser preservado. O controle guarda propriedades semânticas; o hook resolve o estado e delega ao painter.

```text
WM_PAINT / WM_NCPAINT
        ↓
TStyleHook.WndProc
        ↓
ResolveVisualState
        ↓
TMaxPainter/TMaxSkiaRenderer
        ↓
ISkCanvas
```

Controles inteiramente customizados — cards, progress, toast, charts, paginação — pintam em `Paint` e não precisam de hook.

Use hooks apenas para preservar semântica nativa de controles como edit, memo, combo, checkbox, radio e grids. Mesmo nesses casos, bordas, ícones, foco, hover/pressed e chrome visual devem delegar para Skia.

## Design system Ancoragem

O design system de referência é o aplicado no NovoMaxxRural/Ancoragem:

- `DesignSystem.Tokens` para cores, opacidades, tipografia, spacing, radius, interação e estados de card;
- `DesignSystem.Theme` com interface de tema e tema padrão;
- métricas especializadas por domínio, como shell, menu, popup e dashboard;
- `ChartPalette` como fonte oficial de cores de gráficos;
- `AssetResolver` para imagem/SVG/fontes.

Forms/hosts VCL devem usar `ParentBackground := False` e preservar `StyleElements` somente onde não conflitar com a superfície desenhada via Skia.

## Escopo deliberadamente reduzido

A suíte não possui componente de árvore/menu lateral nem barra de ferramentas/topbar. Não reintroduza essas famílias por meio de classes genéricas. Isso reduz complexidade, superfície de testes e diferenças entre versões do VCL.
