# MaxUI Icons — 120 × 120

Pacote vetorial para a suíte Delphi + VCL + StyleHook com identidade visual MaxxRural.

## Conteúdo

- **106 ícones individuais** em SVG;
- todos com `width="120"`, `height="120"` e `viewBox="0 0 120 120"`;
- traço linear, `stroke-width="6"`, pontas e junções arredondadas;
- cor padrão `#2F9E22`;
- uso de `currentColor`, permitindo recoloração sem alterar as geometrias;
- catálogo PNG, catálogo HTML, sprite SVG, manifesto JSON/CSV e constantes Delphi.

## Categorias

- `actions`: 18 ícones
- `agriculture`: 15 ícones
- `controls`: 12 ícones
- `data`: 15 ícones
- `interface`: 24 ícones
- `navigation`: 16 ícones
- `report-viewer`: 6 ícones

## Estrutura

- `svg/`: arquivos mestres usando `currentColor`;
- `svg-green/`: cópias com cor explícita `#2F9E22` para renderizadores que não interpretam `currentColor`;
- `preview/`: catálogo visual e página HTML;
- `delphi/MaxUI.IconNames.pas`: constantes com caminhos relativos;
- `manifest.json` e `manifest.csv`: inventário completo;
- `sprite/maxui-icons.svg`: símbolos SVG agrupados;
- `tools/recolor_icons.py`: criação de uma variante de cor.

## Recolorir

```bash
python tools/recolor_icons.py --source svg --target svg-white --color "#FFFFFF"
python tools/recolor_icons.py --source svg --target svg-danger --color "#D94A3A"
```

Os arquivos foram desenhados para permanecer legíveis em botões, grids, cards, feedbacks, formulários e no report viewer. O tamanho nominal de cada SVG é sempre 120 × 120; redimensione apenas na etapa de renderização.

## Ampliação — Arquivos e sistema

Adicionados **63 SVGs** nas categorias `files`, `folders-paths`, `system`, mantendo os **106 ícones originais**.

- Nomes constantes Delphi: `delphi/MaxUI.SystemIconNames.pas`
- Sprite adicional: `sprite/maxui-system-icons.svg`
- `manifest.json` e `manifest.csv` atualizados
- Ícones individuais: `svg/<categoria>/<nome>.svg` e `svg-green/<categoria>/<nome>.svg`
