# Changelog

## 2.1 — Skia obrigatório e design system Ancoragem

- Skia4Delphi passa a ser obrigatório para desenhar componentes visuais;
- adicionada a tela de Ancoragem/NovoMaxxRural como referência primária de tokens, tema, métricas, renderer, container, interação e overlays;
- removida a orientação de fallback GDI/`MAXUI_SKIA` para desenho visual da suíte;
- mantida a regra de preservar comportamento nativo de editores por composição/hook localizado.

## 2.0 — revisão reduzida e completa

- removidos TreeView/menu lateral e Toolbar/topbar do escopo, starter, demo, packages e registro design-time;
- reorganizada a galeria em 15 famílias;
- adicionadas implementações de referência para inputs, seletores, choices, tabs, cards, grids, status, progresso, feedback, paginação, loaders, charts e report viewer;
- adicionados hooks localizados para botões, edits, masked edit, memo, combo, checkbox e radio;
- adicionados packages runtime/design-time, demo sem DFM e smoke test;
- adicionados scaffold, auditoria e validação estrutural;
- preservado, naquela revisão, o modelo branco original e o antigo suporte condicionado por diretiva; a revisão 2.1 substitui essa orientação.
