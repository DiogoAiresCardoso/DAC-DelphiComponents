# Design system

## Paleta Ancoragem

| Token | Hex | Uso |
|---|---|---|
| Background | `#07130C` | fundo principal da shell/dashboard |
| SurfaceDark | `#08140D` | superfície escura profunda |
| Panel | `#102417` | cards, painéis e popups |
| Border | `#2B3D31` | borda padrão |
| Text | `#E8EEE8` | texto principal |
| TextSecondary | `#B8C4B8` | apoio |
| White | `#FFFFFF` | texto/ícones sobre superfícies escuras |
| PrimaryDark | `#2F9E22` | ação/sucesso |
| Primary | `#3DB82A` | ação principal e pressed |
| PrimaryLight | `#74D64A` | foco, destaque e série principal |
| InteractionHover | `#1F3B23` | hover |
| Warning | `#F5C842` | alerta |
| Orange | `#D98B28` | atenção complementar |
| Danger | `#D94A3A` | erro/perigo |
| UserMenuHighlight | `#123F18` | destaque de item em popup |
| UserMenuDanger | `#FF8A8A` | ação destrutiva em popup |

Galerias destinadas a comparar com a referência branca antiga podem expor variações claras, mas o token source-of-truth passa a ser o tema da Ancoragem.

## Tipografia

Fonte padrão: `Inter` quando o asset estiver disponível. Use fallback do sistema apenas quando a fonte não existir no projeto.

| Papel | Tamanho lógico | Estilo |
|---|---:|---|
| título da tela | 22 | semibold/bold |
| título de seção | 12–13 | bold |
| título de card | 11 | semibold |
| texto | 9 | regular |
| texto secundário | 8–9 | regular |
| métrica | 16–20 | semibold |

Não reduza a fonte para encaixar conteúdo em DPI alto. Aumente altura ou habilite scroll.

## Escala de espaçamento

Base 4/8 px:

```text
4, 8, 12, 16, 24, 32, 40, 48, 64
```

## Raios

```text
4  → pequenos badges
8  → inputs e botões
10 → cards e sections
16 → modal e cards grandes
```

## Bordas e sombras

- borda padrão: 1 px lógico;
- foco: 2 px lógico em verde;
- sombra: discreta, sem grandes halos;
- use Skia para sombras, cantos e antialiasing; não introduza fallback GDI para componentes visuais.

## Estados

Todo controle interativo possui:

```text
normal → hot → pressed → focused → disabled
```

Selected/checked/error são estados ortogonais quando aplicáveis. Foco não pode ser removido apenas por estética.

## Contraste e semântica

- sucesso: check + verde;
- warning: triângulo/ícone + amarelo;
- danger: x/ícone + vermelho;
- disabled: contraste reduzido, mas estado ainda legível;
- delta de card: seta + texto, não somente cor.

## DPI

Tokens são lógicos a 96 PPI. Use `MaxScale`/`MaxScaleF`. Ícones devem manter proporção e hit area mínima de 28–32 px lógicos.

## Estados e interação da Ancoragem

- hover, pressed, focused, selected, active e disabled são estados comuns.
- componentes retornam hit-test com `ComponentId`, `ElementId`, `Cursor` e `Handled`.
- o container centraliza troca de hover, captura de pressed, foco, teclado e cursor.
- top-bar/seletores da Ancoragem servem como referência de estado visual: hover dos botões de janela usa preenchimento de interação, sem stroke verde extra; seletores que abrem overlay alternam no press e não no release.

## Paleta oficial de gráficos

Use `ChartPalette`/tema para gráficos:

```text
#74D64A, #3DBB2A, #F5C842, #4C8DFF,
#F39C3D, #E85C4A, #39C6D6, #A7E36A
```

Não repita esses hex em cards, dashboard views ou renderers de chart.
