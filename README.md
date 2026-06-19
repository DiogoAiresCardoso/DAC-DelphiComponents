# DAC Skia Components

Package base para a nova suite de componentes VCL desenhada com Skia4Delphi.

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
- TreeView/menu lateral e toolbar/topbar continuam fora do escopo da suite.
- Cada classe concreta fica em sua propria unit.

