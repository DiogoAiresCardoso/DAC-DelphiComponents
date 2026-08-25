# Contratos das 15 famílias

## Convenções comuns

Todos os componentes consideram `CurrentPPI`, `Enabled`, foco/TabStop, `BiDiMode`, streaming DFM, invalidação seletiva e `FreeNotification` para referências externas.

## 1. Botões

Classes: `TMaxButton`, `TMaxIconButton`, `TMaxSplitButton`.

Propriedades mínimas:

```pascal
Kind: TMaxButtonKind;
ControlSize: TMaxControlSize;
CornerRadius: Integer;
IconKind: TMaxIconKind;
IconPosition: TMaxIconPosition;
Loading: Boolean;
DropDownMenu: TPopupMenu;       // split
DropDownWidth: Integer;
```

Space/Enter acionam; loading bloqueia clique duplicado; split separa ação principal e menu; icon-only exige `Hint`.

## 2. Campos de entrada

Classes: `TMaxEdit`, `TMaxSearchEdit`, `TMaxPasswordEdit`, `TMaxMaskedEdit`, `TMaxMemo`.

Propriedades visuais:

```pascal
FieldState: TMaxFieldState;
CornerRadius: Integer;
LeadingIcon: TMaxIconKind;
TrailingIcon: TMaxIconKind;
Placeholder: string;
ErrorText: string;
```

Preservar caret, seleção, clipboard, IME e undo/redo. Search dispara `OnSearch`; password alterna visibilidade sem perder caret; masked usa semântica nativa; memo mantém scrollbars.

## 3. Seletores

Classes: `TMaxComboBox`, `TMaxDatePicker`, `TMaxTimePicker`, `TMaxSpinField`.

Combo preserva navegação/busca incremental. Date/time usam `TDateTimePicker` nativo. Spin respeita min/max/incremento e não altera com wheel sem foco por padrão.

## 4. Controles

Classes: `TMaxCheckBox`, `TMaxRadioButton`, `TMaxToggleSwitch`, `TMaxSlider`.

- Space alterna check/radio/toggle;
- setas/PageUp/PageDown alteram slider;
- foco inclui glyph e texto;
- toggle expõe `Checked`, `OnText`, `OffText`, `ShowStateText`;
- slider expõe `Minimum`, `Maximum`, `Position`, `ShowValue`.

## 5. Tabs

Classe: `TMaxPageControl`.

Usar owner draw para tabs; preservar Ctrl+Tab e seleção. `TabPosition` suporta horizontal/vertical. Tab ativa usa indicador verde, conteúdo permanece branco.

## 6. Cards de resumo

Classe: `TMaxSummaryCard`.

```pascal
Title: string;
ValueText: string;
DeltaText: string;
DeltaKind: TMaxDeltaKind;
IconKind: TMaxIconKind;
AccentColor: TColor;
Clickable: Boolean;
```

Métrica domina; delta usa seta + texto; card clicável tem hot/focus/pressed.

## 7. Tabela/data grid

Classes: `TMaxStringGrid`, `TMaxDBGrid`.

```pascal
ZebraRows: Boolean;
ShowRowHover: Boolean;
SelectedRowColor: TColor;
HeaderHeightLogical: Integer;
RowHeightLogical: Integer;
StatusColumn: Integer;
ActionColumn: Integer;
```

Owner draw pinta header, zebra, hover, seleção e badges. Não criar objetos por célula. Manter navegação e seleção nativas.

## 8. Status bar

Classe: `TMaxStatusBar` customizada.

Campos: conexão, usuário, perfil, texto flexível, data, hora e segurança. Fundo claro, divisores finos, indicador verde. Não derivar de barra de ferramentas.

## 9. Progresso

Classes: `TMaxLinearProgress`, `TMaxCircularProgress`.

```pascal
Minimum, Maximum, Position: Integer;
ShowValue: Boolean;
ValueFormat: string;
```

Clampar posição; zero-range não divide por zero; circular preserva espessura em DPI.

## 10. Badges, chips, tags e pills

Base: `TMaxPill`; derivados: `TMaxBadge`, `TMaxChip`, `TMaxTag`.

```pascal
Text: string;
Kind: TMaxPillKind;
CloseButton: Boolean;
Selected: Boolean;
OnClose: TNotifyEvent;
```

AutoSize opcional; close tem hit test; selected/focus visíveis.

## 11. Toast, tooltip e modal

Classes: `TMaxToast`, `TMaxTooltip`, `TMaxModalPanel`.

Toast possui kind, título, mensagem e fechar. Tooltip não rouba foco. Modal possui título/mensagem, confirmar/cancelar, Escape cancela e Enter confirma quando apropriado.

## 12. Paginação

Classe: `TMaxPagination`.

```pascal
CurrentPage, PageCount, PageSize: Integer;
OnPageChanged: TNotifyEvent;
```

Primeira/anterior/páginas/próxima/última; valores sempre válidos; teclado opcional.

## 13. Loading

Classe: `TMaxSpinner`.

```pascal
SpinnerStyle: TMaxSpinnerStyle; // ring, dots, skeleton
Active: Boolean;
Interval: Cardinal;
```

Timer só roda quando ativo e visível. Destruição libera timer. Skeleton não depende de animação para ser legível.

## 14. Charts

Classe: `TMaxChart`.

```pascal
ChartKind: TMaxChartKind;
Data: TStrings;                 // Label=Value
ShowLegend: Boolean;
ShowAxes: Boolean;
```

Suporta barra, linha, área e donut. Dataset vazio não falha. Escala resolve valores negativos/zero. Painter não contém regra de negócio.

## 15. Report viewer

Classe: `TMaxReportViewer`.

```pascal
ReportTitle: string;
PeriodText: string;
PageIndex, PageCount, Zoom: Integer;
Items: TStrings;                // colunas separadas por | ou ;
```

Desenha página branca, cabeçalho, tabela, totais e indicador de página. Não expõe componente de toolbar. Impressão/exportação pertencem a serviços externos ou callbacks opcionais.
