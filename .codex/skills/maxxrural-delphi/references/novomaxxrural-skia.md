# NovoMaxxRural Skia Architecture

Use this reference when changing `Ancoragem`, `NovoMaxxRural`, or any Skia-based component used by the new shell/dashboard.

## Core Rules

- Reusable Skia components must not hardcode user, company, dashboard, menu, chart, coordinate, color, text, icon, or metric decisions that belong to DTOs, theme tokens, metrics, or asset resolvers.
- Split rendering, layout, state, and input events. A form should orchestrate components, not hold per-component hover/pressed fields.
- Preserve Delphi Windows-1252/ANSI encoding for `.pas`, `.dfm`, `.dpr`, and `.dproj` files.
- Keep one concrete Delphi class per unit. Related interfaces and DTO records may live together in a contract unit.

## Shared Skia Layer

- `View\Skia\MaxxRural.View.Skia.Types.pas`
  - Owns pointer events, hit-test result, visual states, accessible roles, and interaction state.
- `View\Skia\MaxxRural.View.Skia.Renderer.pas`
  - Central place for Skia primitives: fill, stroke, text, centered text, SVG, SVG icon.
  - Text ellipsis should use bounded search through `FitTextWithEllipsis`; avoid character-by-character `MeasureText` loops in reusable render paths.
- `View\Skia\MaxxRural.View.Skia.VisualComponent.pas`
  - Base component contract: `Measure`, `Arrange`, `Draw`, `HitTest`, mouse events, wheel, keyboard, invalidation, focusable state, accessible name/role, visual state, and injectable `Theme`.
- `View\Skia\MaxxRural.View.Skia.Container.pas`
  - Routes hit-test, hover, pressed, captured pointer, focus, keyboard navigation/activation, cursor, invalidation checks, and central theme application via `Theme`/`ApplyTheme`.

## Shell Contracts

- `View\Shell\MaxxRural.View.Shell.Branding.pas`
  - Owns `TMaxxRuralShellBranding` for shell logo, partner logo, caption, partner lines, and partner icon.
- `View\Shell\MaxxRural.View.Shell.Layout.pas`
  - Calculates shell regions such as sidebar, top bar, content, footer, and drag area.
- `View\Shell\MaxxRural.View.Shell.Surface.pas`
  - Encapsulates the VCL `TSkPaintBox` lifecycle for the shell surface.
- User-session popups that extend into the dashboard content area must use a real translucent backdrop above `TMaxxRuralDashboardView`, not a captured image/snapshot. Use a separate alpha-blended window for the backdrop and an opaque popup window for the focused content, so the app remains visible/live behind the modal while pointer focus stays in the overlay. The popup window must use the exact card bounds and a rounded window region matching the card radius; leaving padded rectangular window area around the card creates visible black background. A partial/non-windowed paintbox can update state while the popup stays hidden behind the dashboard child form, while an opaque or heavy backdrop suppresses the whole screen instead of preserving transparency.
- `View\Shell\MaxxRural.View.Shell.OverlayManager.pas`
  - Centralizes popup visibility, outside-click closing, and Esc closing for user options and footer context.
- `View\Shell\MaxxRural.View.Shell.ActionDispatcher.pas`
  - Converts shell press and pressed/released hit states into shell actions, keeping click dispatch for system bar, top bar, footer context, menu navigation, user session, and user options out of the form.
- `View\Shell\MaxxRural.View.Shell.InteractionRouter.pas`
  - Centralizes shell hit-test order, hover reset, pressed reset, cursor resolution, pressed hit capture, and wheel routing for legacy shell components.
- `View\Shell\MaxxRural.View.Shell.SearchController.pas`
  - Owns shell search activation, text editing, keyboard handling, and top-bar search state sync. The form should apply filtered menu data, not mutate search text directly.
- `View\Shell\MaxxRural.View.Shell.MenuFilter.pas`
  - Owns menu search normalization and DTO filtering. The form should pass search text and apply the returned DTO to `MenuNav`.
- `View\Shell\MaxxRural.View.Shell.ElementMapper.pas`
  - Owns shell `ElementId` parsing for menu, footer selector/items, system buttons, and user-menu actions.
- `View\Components\MaxxRural.View.Component.Types.pas`
  - Owns shared shell enums and `TMaxxRuralUserSessionViewModel`.
- `View\Components\MenuNav\MaxxRural.View.Component.MenuNav.Types.pas`
  - Owns menu navigation item, menu item view model, display mode, item events, icon-key resolver, visible item, and `TMaxxRuralMenuNavState`.
- `View\Components\MenuNav\MaxxRural.View.Component.MenuNav.Layout.pas`
  - Owns menu navigation expanded, collapsed, compact bounds, and content-height calculations.
- `View\Components\MenuNav\MaxxRural.View.Component.MenuNav.Renderer.pas`
  - Owns menu navigation rendering for collapsed items, modules, groups, routines, and scrollbar.
- `View\Components\MenuNav\MaxxRural.View.Component.MenuNav.Registry.pas`
  - Owns visible item registration and hit-test for menu navigation items.
- `View\Components\MaxxRural.View.Component.MenuNav.pas`
  - Orchestrates menu data, mode selection, rendering delegation, hit-test registry, external item events, configurable module icon keys, and public item selection without exposing pressed-state mutation to forms.
- `View\Components\Popups\MaxxRural.View.Component.Popup.Types.pas`
  - Owns reusable popup item state and popup menu item contracts.
- `View\Components\Popups\MaxxRural.View.Component.Popup.Renderer.pas`
  - Owns shared popup rendering for surfaces, dividers, menu items, and scrollbars.
- `View\Components\Popups\MaxxRural.View.Component.Popup.pas`
  - Base visual popup component for Skia popup surfaces.
- `View\Components\Popups\MaxxRural.View.Component.MenuPopup.pas`
  - Reusable visual menu popup component backed by popup item contracts.
- `View\Components\Popups\MaxxRural.View.Component.SelectionDropdown.pas`
  - Reusable selection dropdown component specialized from menu popup with selected element tracking.
- `View\Components\MaxxRural.View.Component.UserOptions.pas`
  - Builds reusable `TMaxxRuralPopupMenuItem` arrays and delegates menu-list rendering/hit-test to `TMaxxRuralSkiaMenuPopup`.
- `View\Components\MaxxRural.View.Component.FooterContext.pas`
  - Builds reusable dropdown item arrays and delegates list rendering/hit-test to `TMaxxRuralSkiaSelectionDropdown`; the footer context stays responsible only for its host surface and trigger state.

## Design Metrics

- `View\DesignSystem\MaxxRural.View.DesignSystem.Tokens.pas`
  - Owns reusable design token records for colors, opacities, typography, spacing, radius, interactions, and card states.
- `View\DesignSystem\MaxxRural.View.DesignSystem.Theme.pas`
  - Owns `IMaxxRuralTheme` and `TMaxxRuralDefaultTheme`; visual components receive a theme through `TMaxxRuralSkiaVisualComponent.Theme`.
- `View\DesignSystem\MaxxRural.View.DesignSystem.AssetResolver.pas`
  - Centralizes runtime asset file lookup and typed loading for image/SVG assets used by Skia components.
- `View\DesignSystem\MaxxRural.View.DesignSystem.DashboardMetrics.pas`
  - Dashboard rows, cards, chart layout, legend, metric content, panel content, header, and footer dimensions.
- `View\DesignSystem\MaxxRural.View.DesignSystem.ShellMetrics.pas`
  - Shell/sidebar/topbar/footer/window metrics.
- `View\DesignSystem\MaxxRural.View.DesignSystem.MenuMetrics.pas`
  - Sidebar branding and menu metrics.
- `View\DesignSystem\MaxxRural.View.DesignSystem.PopupMetrics.pas`
  - User-menu and footer-context popup metrics.

## Hover, Pressed, Focus

- Components return `TMaxxRuralHitTestResult` with `ComponentId`, `ElementId`, `Cursor`, and `Handled`.
- `ElementId` identifies internal clickable/hoverable regions inside a component.
- The container owns pointer state transitions:
  - `MouseMove` updates hover and fires enter/leave.
  - `MouseDown` sets pressed and captured component/element.
  - `MouseUp` releases pressed/capture.
- Keyboard events go to the focused component.
- `Tab`, `Shift+Tab`, arrow keys, `Home`, `End`, `Enter`, `Space`, and `Esc` are handled by `TMaxxRuralSkiaContainer` before falling through to the focused component.
- Use `AccessibleName`, `AccessibleRole`, and `Focusable` on reusable visual components that participate in canvas keyboard/focus flow.
- Component-specific fields such as `HoveredIndex`, `FHoveredButton`, or `FPressedItem` should be migrated behind the common contract instead of expanding ad hoc state.
- Public component APIs should not expose mutable hover/pressed properties; shell components should use `GetHoveredElement`, `SetHoveredElement`, `GetPressedElement`, `SetPressedElement`, and `ClearInteractionState`.
- The top-bar menu button hover should visually match the system window buttons: interaction fill only, no extra stroke. Keep minimize/maximize/close hover as the reference behavior.
- Shell selectors that open overlays, such as user session, farm, and cycle/safra selectors, should execute the toggle on press and avoid toggling again on release.

## Card And Chart Separation

- A card is a visual container only. It may draw chrome such as background, border, radius, padding, header/footer areas, and host bounds.
- A card must not render chart series, chart axis, grid, labels, or legend.
- Chart, metric, panel, list, form summary, and future content are embedded child components.
- Reference chart images are used to identify layout anatomy, label placement, legend behavior, and interaction patterns. Do not copy colors from those images; chart colors must continue to come from `TMaxxRuralChartPalette`, theme tokens, or explicit DTO color overrides only when a data contract requires it.
- Dashboard views should receive card data through DTOs. Keep temporary mock data outside the form/component assembly code.
- `TMaxxRuralChartSeriesDTO`, `TMaxxRuralDoughnutSegmentDTO`, and `TMaxxRuralDoughnutCenterDTO` source of truth is `View\Components\Charts\MaxxRural.View.Component.Chart.Types.pas`; do not recreate chart DTOs in dashboard or card units.
- Chart configuration is also owned by `View\Components\Charts\MaxxRural.View.Component.Chart.Types.pas` through `TMaxxRuralChartOptionsDTO` and `TMaxxRuralChartStyleDTO`, covering chart kind, value format, legend mode/position, scale mode/min/max, value labels, axis titles, frame, grid, axis, label, line, marker, area fill, bar, doughnut, side legend, and legend geometry.
- `TMaxxRuralChartLegendComponent` receives `TMaxxRuralChartStyleDTO` from the chart base. Do not make the legend read dashboard metrics directly; legend width, fallback width, item height, marker size, padding, text offset, and text size belong to chart style.
- Current dashboard DTO/mock units:
  - `View\Dashboard\MaxxRural.View.Dashboard.Types.pas`
  - `View\Dashboard\MaxxRural.View.Dashboard.MockData.pas`
  - `View\Dashboard\MaxxRural.View.Dashboard.Provider.pas`
  - `View\Dashboard\MaxxRural.View.Dashboard.Service.pas`
- `View\Dashboard\MaxxRural.View.Dashboard.Layout.pas`
  - Owns configurable dashboard card layout calculation and keeps responsive row/column math outside `TMaxxRuralDashboardView`.
- `TMaxxRuralDashboardView` should receive dashboard cards through `IMaxxRuralDashboardService` at shell/application boundaries. `IMaxxRuralDashboardDataProvider` remains a lower-level source/fallback and compatibility bridge.
- `View\Dashboard\MaxxRural.View.Dashboard.ComponentSmokeTest.pas`
  - Compile-time smoke test for reusable card/chart composition outside `TMaxxRuralPrincipalView`: card with metric, panel, embedded line chart, and standalone line/bar charts.
- Current base units:
  - `View\Components\Cards\MaxxRural.View.Component.Card.Types.pas`
  - `View\Components\Cards\MaxxRural.View.Component.CardContainer.pas`
  - `View\Components\Cards\MaxxRural.View.Component.CardContentHost.pas`
  - `View\Components\Cards\MaxxRural.View.Component.CardHeader.pas`
  - `View\Components\Cards\MaxxRural.View.Component.CardFooter.pas`
  - `View\Components\Cards\MaxxRural.View.Component.MetricContent.pas`
  - `View\Components\Cards\MaxxRural.View.Component.PanelContent.pas`
- Card container and card content components should consume colors, interaction colors, opacity, typography, spacing, and radius through `Theme.Tokens`; keep `DashboardMetrics` only for dashboard-specific geometry.
- Current chart base units:
  - `View\Components\Charts\MaxxRural.View.Component.Chart.Types.pas`
  - `View\Components\Charts\MaxxRural.View.Component.Chart.pas`
  - `View\Components\Charts\MaxxRural.View.Component.LineChart.pas`
  - `View\Components\Charts\MaxxRural.View.Component.BarChart.pas`
  - `View\Components\Charts\MaxxRural.View.Component.DoughnutChart.pas`
  - `View\Components\Charts\MaxxRural.View.Component.ChartSideLegend.pas`
- Supported chart variants now include line, area-line, grouped bar, and doughnut. Line/area-line and grouped bar are cartesian variants; doughnut is a composition chart and must not reuse cartesian axis/grid rendering.

## Official Chart Palette

Source of truth: `View\DesignSystem\MaxxRural.View.DesignSystem.ChartPalette.pas`.

Series colors:

- `VerdePrincipal`: `#74D64A`
- `VerdeMedio`: `#3DBB2A`
- `AmareloAgricola`: `#F5C842`
- `AzulInformativo`: `#4C8DFF`
- `LaranjaAtencao`: `#F39C3D`
- `VermelhoQueda`: `#E85C4A`
- `CianoComplementar`: `#39C6D6`
- `VerdeClaroSuave`: `#A7E36A`

Support colors:

- `FundoGrafico`: `#0B1A11`
- `Card`: `#102417`
- `GradePrincipal`: `#284133`
- `GradeSecundaria`: `#1B2E23`
- `TextoPrincipal`: `#E8EEE8`
- `TextoSecundario`: `#B8C4B8`
- `LinhaEixo`: `#355241`

Semantic colors:

- `Positivo`: `#74D64A`
- `Neutro`: `#B8C4B8`
- `Atencao`: `#F5C842`
- `Negativo`: `#E85C4A`

Use `TMaxxRuralChartPalette.Default`, `ColorByIndex`, `ColorByRole` for graph elements. Do not repeat chart hex values in cards, dashboard views, or chart renderers.

## Validation

- Search for hardcoded chart colors outside `ChartPalette` before finishing chart work.
- Confirm `.dpr` and `.dproj` include newly added units.
- Build `Ancoragem\NovoMaxxRural.dproj` when allowed and practical.
