# Mapa da implementação de referência

O starter desta skill cobre todas as famílias restantes. Ele deve ser adaptado ao toolchain, mas não é um exemplo de um único botão.

| Família | Unit principal | Estratégia |
|---|---|---|
| Botões | `MaxUI.Controls.Buttons` | classe própria + hook localizado quando precisar preservar semântica; chrome/estados via Skia |
| Inputs | `MaxUI.Controls.Inputs` | editores nativos preservados + borda/ícones/estado/margens via Skia |
| Seletores | `MaxUI.Controls.Selectors` | combo/date/time nativos preservados; dropdown/chrome/spin via Skia |
| Check/radio/toggle/slider | `MaxUI.Controls.Choices` | semântica nativa quando útil; desenho e estados via Skia |
| Tabs | `MaxUI.Controls.Tabs` | tabs desenhadas via Skia com hit-test e foco |
| Cards | `MaxUI.Controls.Cards` | container visual Skia, sem desenhar conteúdo específico como chart |
| Grid | `MaxUI.Controls.Data` | headers, zebra, seleção, hover, ações e chrome via Skia; `TDBGrid` preserva datasource |
| Status | `MaxUI.Controls.Data` | componente Skia |
| Progress | `MaxUI.Controls.Feedback` | linear/circular via Skia |
| Pills | `MaxUI.Controls.Feedback` | badges/chips/tags/pills via Skia |
| Toast/tooltip/modal | `MaxUI.Controls.Feedback` | popup/overlay Skia com host windowed quando necessário |
| Paginação | `MaxUI.Controls.Feedback` | componente Skia + hit test |
| Loading | `MaxUI.Controls.Feedback` | spinner/dots/skeleton via Skia + timer controlado |
| Charts | `MaxUI.Controls.Charts` | line/area/bar/donut via Skia e paleta oficial |
| Report | `MaxUI.Controls.Report` | surface Skia, preview/zoom, sem toolbar pública |

## Hooks registrados

```text
TMaxButton       → TMaxButtonStyleHook
TMaxEdit         → TMaxEditStyleHook
TMaxMaskedEdit   → TMaxMaskedEditStyleHook
TMaxComboBox     → TMaxComboBoxStyleHook
TMaxCheckBox     → TMaxCheckBoxStyleHook
TMaxRadioButton  → TMaxRadioButtonStyleHook
```

Subclasses herdam o hook do ancestral registrado. Não registre `TMaxSearchEdit` e `TMaxPasswordEdit` novamente.

## Ordem de compilação sugerida

```text
Types → Dpi → Theme/Tokens → Metrics → Assets → Icons
→ Skia Renderer → Skia VisualComponent → Skia Container
→ Base → Buttons → Inputs → Selectors → Choices → Tabs
→ Cards → Data → Feedback → Charts → Report
→ Hooks → Runtime package → DesignTime → Demo → Tests
```

## Adaptações esperadas

- revisar nomes de hooks disponíveis na versão Delphi;
- ajustar package `requires`;
- adicionar namespaces do projeto;
- substituir ícones GDI por SVG/assets resolvidos centralmente;
- ligar todos os componentes visuais ao renderer Skia obrigatório;
- integrar datasource real sem mover lógica de negócio para painters.
