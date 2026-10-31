# DAC Skia Components

Package base para a nova suite de componentes VCL desenhada com Skia4Delphi.

## Documentacao da DBGrid

- [TDACDBGrid: multiplas acoes por celula, eventos e teclado](docs/dbgrid/actions.md).

## Documentacao dos cards

- [TDACSummaryCard: fontes, cores e layout em runtime](docs/cards/README.md).

## Documentacao dos graficos

- [TDACChart: manual tecnico consolidado](docs/charts/README.md) — arquitetura,
  API/DFM/JSON, desenho Skia, texto Windows, fontes, demo e testes.
- [Demo exclusivo de graficos](demo-charts/README.md).
- [Evidencias e comparacoes preservadas](docs/charts/evidence/2026-09-22/README.md).
- [Consolidacao atual — 23/09/2026](docs/charts/consolidation-2026-09-23.md): API tipada,
  validacao transacional, espaco do titulo e evidencias por etapa.

## Estrutura

```text
Package/
  DACSkiaComponentsRuntime.dpk/.dproj
  DACSkiaComponentsDesign.dpk/.dproj

Source/Core/
  Tipos compartilhados, DPI e geometria.

Source/DesignSystem/
  Tokens separados por assunto, tema, metricas, paleta de graficos e assets.

Source/Skia/
  Renderer compartilhado, painters especializados, elemento visual base e container de interacao.
  BackgroundPainter desenha application, panel, card, control e overlay.
  BorderPainter desenha panel, card, control, focus, danger e warning.
  IconPainter desenha icones SVG lineares e semanticos.

Source/Controls/
  Controles VCL que hospedam a superficie Skia.
  Container e o section/card host reutilizavel da galeria, com cantos arredondados,
  header, padding de conteudo, fundo e borda desenhados com Skia.

Source/Hooks/
  Registro centralizado e idempotente de style hooks.

Source/DesignTime/
  Registro de componentes na IDE.
```

## Regras

- Skia4Delphi e obrigatorio para desenho visual.
- Runtime nao depende de `DesignIntf`.
- Design-time depende do runtime e registra componentes na IDE.
- TDACDBTreeView oferece arvore data-aware de dados com colunas. Menu lateral e toolbar/topbar continuam fora do escopo.
- Cada classe concreta fica em sua propria unit.


## Arvore data-aware

- [TDACDBTreeView: API, exemplo e validacao](docs/dbtreeview/README.md).
