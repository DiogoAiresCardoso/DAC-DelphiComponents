# NovoMaxxRural Skia Context

Use this memory for future work in `Ancoragem` and the `NovoMaxxRural` shell/dashboard.

- Reusable Skia components must receive data, theme, metrics, assets, and state by contract. Avoid user/company/dashboard/menu/chart hardcodes inside reusable components.
- `TMaxxRuralPrincipalView` should orchestrate VCL lifecycle and shell controllers. Hit-test, hover, pressed, scroll, click dispatch, popup closing, and search text editing belong to shell helper units.
- Card and chart are separate components. `TMaxxRuralSkiaCardContainer` is only visual chrome/container; metric, panel, line chart, bar chart, legend, axis, and grid are child/specialized components.
- Dashboard cards flow through `IMaxxRuralDashboardService`; lower-level providers can supply fallback/mock data while real data sources evolve.
- Chart series/options/style contracts live in `View\Components\Charts\MaxxRural.View.Component.Chart.Types.pas`; do not recreate chart DTOs in dashboard/card units.
- Chart colors come from `TMaxxRuralChartPalette`/theme. Do not repeat chart hex values in cards, dashboard views, or chart renderers.
- Reference images for charts define anatomy, spacing, labels, legends, and behavior only. Do not copy their palette; keep colors from the existing design system and chart palette unless a typed DTO explicitly overrides a series/segment color.
- Chart variants should remain reusable and specialized by contract: line, area-line, grouped bar, and doughnut. Doughnut uses segment DTOs, center text, external labels, and optional side legend; it must not depend on cartesian grid/axis behavior.
- Text ellipsis in reusable render paths uses bounded search through `FitTextWithEllipsis`; avoid character-by-character `MeasureText` loops.
- Preserve Windows-1252/ANSI encoding and CRLF when editing Delphi project/source files in this workspace.
- In the shell, the menu button hover must follow the system window-button visual language: interaction fill only, without the extra green stroke.
- User, farm, and cycle/safra overlay selectors should toggle on press and should not toggle again on release.
- The user-options popup extends into the dashboard content area, so it needs a real translucent backdrop above `TMaxxRuralDashboardView`, not a captured image/snapshot. Use a separate alpha-blended window for the backdrop and an opaque popup window for focused content, so the app stays visible/live behind the modal while pointer focus stays in the overlay. The popup window must use the exact card bounds and a rounded window region matching the card radius; leaving padded rectangular window area around the card creates visible black background. Changing only `FUserOptionsComponent.Visible` or using a partial/non-windowed paintbox can leave the popup hidden behind the dashboard; using an opaque or heavy backdrop suppresses the whole screen instead of preserving transparency.
