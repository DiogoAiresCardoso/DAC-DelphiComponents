# MaxUI starter completo — 15 famílias

Esta pasta contém uma implementação de referência ampla para Delphi VCL. As famílias de árvore/menu lateral e barra de ferramentas/topbar não fazem parte do código.

## Conteúdo

- Core: types, DPI, tema, ícones, renderer/painter e integração obrigatória Skia;
- Controls: base, botões, inputs, seletores, choices, tabs, cards, grid/status, feedback, charts e report;
- Hooks: botão, inputs, combo, checkbox e radio;
- packages runtime/design-time de exemplo;
- galeria sem DFM com 15 seções;
- smoke test console/VCL.

## Ordem recomendada

1. ajuste `requires` e nomes dos packages à versão do RAD Studio;
2. compile `MaxUI.Runtime.dpk`;
3. compile/instale `MaxUI.Design.dpk` apenas na IDE;
4. compile `Demo/MaxUIDemo.dpr`;
5. compile/execute `Tests/MaxUI.Smoke.dpr`;
6. valide DPI, teclado, IME, VCL Styles e recursos GDI no ambiente real.

## Compatibilidade

O código visa Delphi VCL moderno. Classes e assinaturas auxiliares de `TStyleHook` podem variar entre versões; adapte as classes-base conforme o source da VCL instalada. Os `.dpk` são modelos, não devem ser considerados universais.

Skia4Delphi deve estar disponível no search path do projeto. O starter não deve ser usado como fallback GDI para desenho visual da suíte.
