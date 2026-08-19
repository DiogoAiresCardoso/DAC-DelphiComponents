# Skia4Delphi obrigatório

## Objetivo

Skia4Delphi é o backend obrigatório de desenho visual da suíte. Ele garante antialiasing, curvas, sombras, SVG, charts, report preview e consistência com o design system já aplicado no NovoMaxxRural/Ancoragem.

Se o toolchain alvo não expõe `System.Skia` e `Vcl.Skia`, trate como bloqueio de compatibilidade e relate a limitação. Não implemente fallback GDI para componentes visuais novos.

## Imports

```pascal
uses
  System.Skia,
  Vcl.Skia;
```

O starter inclui `MaxUI.Skia.pas` como ponto de integração obrigatório. Não use `MAXUI_SKIA` como chave para desabilitar o backend visual.

## Onde usar

Use Skia em todo desenho visual da suíte:

- botões, cards, sections, inputs e seletores;
- bordas, foco, hover, pressed, selected, active e disabled;
- sombras/gradientes;
- circular progress;
- charts;
- ícones SVG;
- popups, modal, tooltip e toast;
- report preview em zoom fracionário.

Não sacrifique semântica nativa. `TEdit`, `TMemo`, combo, date/time, check/radio e grids podem preservar janela nativa, caret, seleção, IME, clipboard, undo/redo e acessibilidade; a camada visual da suíte ao redor desses controles ainda deve ser desenhada via Skia, com hook localizado ou composição documentada.

## Contrato inspirado na Ancoragem

- `Renderer`: centraliza `FillRoundRect`, `StrokeRoundRect`, texto, texto centralizado, SVG, cache de fontes/paints/SVG e truncamento com ellipsis eficiente.
- `VisualComponent`: define `Measure`, `Arrange`, `Draw`, `HitTest`, eventos de mouse/wheel/teclado, foco, acessibilidade, `Visible`, `Enabled`, `NeedsLayout`, `NeedsPaint` e `Theme`.
- `Container`: organiza camadas, aplica tema, desenha em ordem, faz hit-test em ordem inversa, roteia hover/pressed/capture/focus/keyboard/cursor e centraliza invalidação.
- `Theme/Tokens`: fornece cores, opacidades, tipografia, spacing, radius, interação e estados de card.
- Métricas específicas ficam em units de domínio, como `ShellMetrics`, `MenuMetrics`, `PopupMetrics` e `DashboardMetrics`; não espalhe dimensões locais.
- Assets e SVGs passam por resolver central, não por caminhos hardcoded em componentes.

## Overlays e popups

Popups que cruzam a área de `TMaxxRuralDashboardView` precisam de host windowed acima do dashboard. Um `TSkPaintBox` parcial ou não windowed pode atualizar estado enquanto o popup fica escondido atrás do child form. Use overlay/host dedicado, backdrop dim, captura de foco, fechamento por clique fora/Esc e roteamento de eventos somente para o popup ativo.

## Recursos

- não crie `TSkSurface` a cada `Paint` sem necessidade;
- libere snapshots/images determinísticamente;
- invalide somente a área alterada;
- cacheie fontes, paints e SVGs;
- teste resize, DPI e consumo de CPU ao mover o mouse sobre a superfície;
- confira que não restou desenho visual novo por `TCanvas`/GDI em componentes da suíte.
