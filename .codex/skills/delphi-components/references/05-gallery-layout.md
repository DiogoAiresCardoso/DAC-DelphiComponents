# Galeria de 15 seções

## Hierarquia

```text
TfrmComponentGallery
├── hdrMain: painel branco
│   ├── título
│   └── subtítulo
└── scrMain: TScrollBox
    └── pnlCanvas: superfície branca
        ├── row01
        │   ├── 1 Botões
        │   ├── 2 Inputs
        │   ├── 3 Seletores
        │   └── 4 Controles
        ├── row02
        │   ├── 5 Tabs
        │   ├── 6 Cards
        │   └── 7 Grid
        ├── row03
        │   ├── 8 Status
        │   ├── 9 Progresso
        │   ├── 10 Pills
        │   └── 11 Feedback
        ├── row04
        │   ├── 12 Paginação
        │   ├── 13 Loading
        │   └── 14 Charts
        └── row05
            └── 15 Report viewer
```

Não deixe colunas vazias para componentes removidos.

## Métricas a 96 PPI

| Item | Valor lógico |
|---|---:|
| canvas alvo | 1440 |
| margem externa | 16 |
| gap | 12 |
| padding | 12–16 |
| raio de section | 10 |
| header | 72 |
| botão/input | 36 |

## Conteúdo mínimo

### 1 Botões
Primário, secundário, sucesso, alerta, perigo, icon-only, split e disabled.

### 2 Inputs
Texto, password, search, masked e memo.

### 3 Seletores
Combo, date, time e spin.

### 4 Controles
Check checked/unchecked, radio selected/unselected, toggle on/off e slider 75%.

### 5 Tabs
Uma horizontal e outra com `TabPosition=tpLeft`.

### 6 Cards
Quatro métricas com acentos distintos.

### 7 Grid
Cinco linhas, status ativo/pendente/cancelado, ações e total.

### 8 Status
Conectado, usuário, perfil, data, hora e segurança.

### 9 Progresso
Linear e circular em 68%.

### 10 Pills
Badges numéricos, chips com close, tags semânticas e pills selecionáveis.

### 11 Feedback
Toasts success/warning/error, tooltip e modal de confirmação.

### 12 Paginação
Primeira, anterior, páginas, próxima, última e page size.

### 13 Loading
Ring, dots e skeleton.

### 14 Charts
Barra, linha, área e donut.

### 15 Report
Página branca, título, período, tabela, total, zoom e página.

## Resize

`TScrollBox` ocupa o client. O canvas tem largura lógica mínima e altura suficiente; prefira scroll vertical. Em 125%/150% DPI, aumente alturas ou faça wrap, nunca sobreponha controles.

## QA visual

- fundo geral branco;
- bordas leves;
- verde disciplinado;
- tipografia hierárquica;
- nenhuma seção cortada;
- nenhum bloco de menu em árvore ou barra de ações;
- modal/tooltip escuro apenas localmente.
