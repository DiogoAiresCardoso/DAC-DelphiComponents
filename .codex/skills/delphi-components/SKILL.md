---
name: delphi-vcl-stylehook-design-system
description: Implemente, complete, modernize ou audite uma suíte Delphi VCL desenhada sempre com Skia4Delphi, TStyleHook localizado, identidade visual do NovoMaxxRural/Ancoragem, componentes compostos e galeria de 15 famílias. Use para projetos VCL que precisam de botões, inputs, seletores, controles, tabs, cards, grids, status, feedback, charts e report viewer. TreeView/menu lateral e Toolbar/topbar estão explicitamente fora do escopo.
---

# Missão

Entregar uma biblioteca de componentes Delphi VCL realmente utilizável, com aparência coerente, comportamento nativo preservado e implementação revisável. A suíte usa o design system já aplicado no NovoMaxxRural/Ancoragem, desenha a camada visual sempre com Skia4Delphi e deve usar `TStyleHook` localizado em classes próprias (`TDAC...`/`TMax...`) sempre que o controle permitir essa estratégia sem quebrar semântica nativa, streaming DFM, teclado, foco ou acessibilidade. O pacote de referência desta skill contém uma implementação inicial ampla das 15 famílias do escopo; não trate o trabalho como concluído se apenas o botão canônico existir.

## Escopo funcional obrigatório

A galeria e o runtime devem cobrir estas 15 famílias:

1. botões;
2. campos de entrada;
3. seletores;
4. checkbox, radio, toggle e slider;
5. tabs horizontais e verticais;
6. cards de resumo;
7. tabela/data grid;
8. status bar;
9. progresso linear e circular;
10. badges, chips, tags e pills;
11. toast, tooltip e modal;
12. paginação;
13. loading, spinner, dots e skeleton;
14. charts de barra, linha, área e donut;
15. report viewer.

## Fora do escopo

Não implemente, não registre e não adicione à galeria:

- `TMaxTreeView`, menu lateral ou navegação em árvore;
- `TMaxToolBar`, toolbar, topbar ou barra de ações genérica.

O report viewer pode ter controles internos mínimos de página/zoom, mas não deve expor uma toolbar reutilizável como componente da suíte.

# Fontes visuais

Use, nesta ordem:

1. `Ancoragem/design system.png` e `Ancoragem/assets/maxxrural_design_system.svg`, quando disponíveis no checkout, como fonte primária de paleta, tipografia, bordas, raios, ícones e densidade visual;
2. `Ancoragem/dashboard.png`, `Ancoragem/suite-componentes.png`, `Ancoragem/grid.png`, `Ancoragem/opcaousuario.png` e `Ancoragem/paleta cores gráficos.png`, quando disponíveis, para cards, gráficos, grid, popups, estados e composição;
3. `assets/reference/maxxrural-design-system.png` para fallback da paleta, tipografia, bordas, raios e ícones;
4. `assets/reference/maxxrural-dashboard.png` para fallback de proporções de cards e densidade informacional;
5. `assets/reference/component-gallery-white-original.png` apenas como referência estrutural geral. Ignore completamente as áreas de menu em árvore e barra de ferramentas presentes na imagem original.

A galeria deve evidenciar os tokens reais do NovoMaxxRural: verdes `#2F9E22`, `#3DB82A` e `#74D64A`, superfícies escuras `#07130C`, `#08140D` e `#102417`, neutros `#E8EEE8` e `#B8C4B8`, warning `#F5C842` e danger `#D94A3A`. Use `Inter` como fonte quando o projeto fornecer o asset. Não use fotografia como fundo da galeria.

# Comece sempre assim

1. Leia `AGENTS.md` e as instruções locais do repositório.
2. Localize `.dproj`, `.groupproj`, `.dpk`, `.pas`, `.dfm`, configurações Win32/Win64 e dependências.
3. Execute, quando Python estiver disponível:

   ```bash
   python <skill-dir>/scripts/audit.py --root . --output .codex/maxui-audit.json
   ```

4. Determine:
   - versão alvo do Delphi/RAD Studio;
   - uso atual de VCL Styles;
   - versão/localização de Skia4Delphi e disponibilidade de `System.Skia`/`Vcl.Skia`;
   - convenção de namespace/prefixo;
   - packages runtime/design-time;
   - comandos reais de build/teste.
5. Leia apenas as referências necessárias:
   - `references/01-architecture.md`;
   - `references/02-design-system.md`;
   - `references/03-component-contracts.md`;
   - `references/04-stylehook-recipes.md`;
   - `references/05-gallery-layout.md`;
   - `references/06-skia-integration.md`;
   - `references/07-testing-and-acceptance.md`;
   - `references/08-delivery-checklist.md`;
   - `references/09-implementation-map.md`.

Não pare para pedir detalhes que podem ser inferidos com segurança. Pergunte somente quando a decisão alterar compatibilidade binária, versão mínima do Delphi, licença/dependência ou comportamento funcional relevante.

# Regras não negociáveis

## Arquitetura

- `Core` não depende de `Controls`, `Hooks`, `DesignTime` ou `Demo`.
- `Controls` depende apenas de `Core`, RTL e VCL.
- `Hooks` pode depender de `Core` e `Controls`.
- `DesignTime` depende do runtime; o runtime nunca depende de `DesignIntf`.
- `Demo` demonstra a biblioteca e não contém lógica essencial.
- Tokens, pintura, controles, hooks e registro ficam em units separadas.
- Não crie as duas famílias removidas sob nomes alternativos.
- Skia4Delphi é dependência obrigatória da suíte. Se `System.Skia`/`Vcl.Skia` não estiverem no toolchain alvo, registre o bloqueio em vez de criar fallback GDI para componentes visuais.
- Espelhe a arquitetura da Ancoragem: `DesignSystem.Tokens`, `DesignSystem.Theme`, métricas por domínio, `Skia.Renderer`, `Skia.VisualComponent`, `Skia.Container`, contratos/DTOs e roteadores de interação separados.

## StyleHooks

- A preferência arquitetural da suíte é usar `TStyleHook` localizado em todos os componentes onde isso for tecnicamente viável.
- Registre hooks somente para classes da suíte, como `TMaxButton`, `TMaxEdit`, `TMaxComboBox`, `TMaxCheckBox` e `TMaxRadioButton`.
- Nunca registre diretamente em `TButton`, `TEdit`, `TComboBox`, `TCheckBox`, `TRadioButton` ou classes-base globais sem solicitação explícita.
- Todo `RegisterStyleHook` possui `UnRegisterStyleHook` correspondente.
- O registro é idempotente e centralizado.
- Preserve caret, seleção, IME, clipboard, undo/redo, atalhos e tecnologia assistiva nos editores nativos.
- Quando o hook especializado da VCL existir e for compatível com a versão alvo, herde dele.
- Quando o hook nativo for instável entre versões, inexistente ou insuficiente para um componente composto, use owner draw ou controle composto documentado e registre a justificativa técnica.
- Não deixe um componente primitivo apenas com owner draw se houver caminho estável por `TStyleHook`; refatore para hook antes de considerar o comportamento pronto.
- Não use acesso a campos `strict private` da VCL.

## Visual

- Siga os tokens e proporções da tela de Ancoragem/NovoMaxxRural.
- Fundos, cards, sections e popups devem usar tokens de tema; não force branco quando o tema da Ancoragem pedir superfície escura.
- Verde principal, cinzas neutros, amarelo para warning e vermelho para danger.
- Foco sempre visível.
- Estado não depende somente de cor.
- Todas as métricas passam pelo helper de DPI.
- Evite flicker com buffer, `csOpaque`, invalidação seletiva e tratamento de `WM_ERASEBKGND` quando apropriado.
- Literais de cor, opacidade, tipografia, spacing e raio ficam no tema/tokens; não espalhe tokens pelas units.
- Top-bar, menu lateral e shell da Ancoragem podem ser usados como referência visual, mas continuam fora do escopo como componentes reutilizáveis da suíte.

## Código

- Siga convenções do repositório.
- Skia4Delphi é obrigatório. Não use `MAXUI_SKIA` como chave de fallback visual.
- Todo componente visual novo deve desenhar por `System.Skia`/`Vcl.Skia`, por um renderer compartilhado e por tokens de tema.
- Controles nativos como edit, memo, combo, date/time, checkbox, radio e grid podem preservar janela nativa, caret, IME e acessibilidade; ainda assim, a borda, chrome, ícones, estados, overlays e componentes compostos da suíte devem ser desenhados com Skia.
- Para textos de inputs, labels, valores editáveis, placeholders, helper text e captions que precisam casar com a nitidez VCL/Windows, preferir a renderização nativa do Windows/VCL (`DrawText`, `TLabel`, fonte do controle nativo ou janela editável) em vez de `SkLabel`/texto Skia. A premissa atual da suíte é: Skia desenha o chrome visual (background, borda, foco, hover, ícones, separadores e superfícies), enquanto texto de formulário deve usar a API nativa quando isso entrega a mesma fonte, hinting e nitidez do NovoMaxxRural.
- Componentes compostos usados no designer VCL devem ser seguros antes de receber `Parent`: no `Create`, `Resize`, `Loaded` e setters chamados por streaming não use `ClientWidth`, `ClientHeight`, `ClientRect`, `Handle`, `HandleNeeded`, `BringToFront`, `SendToBack`, `SetZOrder`, `Redraw` de filhos Skia ou qualquer API que force `CreateWnd` quando `Parent = nil` ou quando estiver em `csDesigning`. Nessa fase, calcule bounds por `Width`/`Height`, faça z-order apenas em runtime com `HandleAllocated` e `Parent.HandleAllocated`, e trate o erro `Control '' has no parent window` como sinal de criação/parenting prematuro.
- Não acesse propriedades protegidas por uma referência base como `TControl.Color` ou `TControl.ParentColor`; use propriedade do próprio descendente, helper central com RTTI para propriedades publicadas ou API pública específica.
- Não deixe `TODO`, método vazio, evento sem efeito ou propriedade publicada sem implementação na entrega final.
- Não declare que compilou se o compilador Delphi não foi executado.
- Não altere search paths, packages ou recursos de forma destrutiva.

# Fluxo de implementação

## 1. Auditar e planejar

Produza um plano curto, orientado a arquivos, com ordem de build e riscos. Em projeto novo, o scaffold completo pode ser copiado com:

```bash
python <skill-dir>/scripts/scaffold.py --target . --prefix MaxUI --with-demo --with-tests
```

O starter desta versão contém units para todas as 15 famílias, packages de exemplo, demo sem DFM e smoke test. Adapte-o ao projeto; não copie cegamente sobre arquivos existentes.

## 2. Construir a fundação

Implemente/valide nesta ordem:

1. enums e records de estado;
2. paleta, tipografia e métricas;
3. DPI e geometria;
4. ícones lineares;
5. renderer Skia com cache de fontes, paints e SVG;
6. contrato base de componente visual Skia (`Measure`, `Arrange`, `Draw`, `HitTest`, mouse, wheel, teclado, foco, acessibilidade e invalidação);
7. container Skia com camadas, tema central, hit-test, hover, pressed, captura, foco, teclado, cursor e invalidação;
8. surfaces, sections e cards;
9. botão canônico + hook localizado quando viável;
10. registro central.

Compile após o botão canônico para validar a estratégia de hooks.

## 3. Implementar as famílias primitivas

Implemente botões, edits/memo/masked/password/search, combo/date/time/spin, checkbox/radio/toggle/slider, tabs, grids e status bar. Para cada controle:

- propriedades publicadas com defaults estáveis;
- estado visual resolvido em uma função;
- desenho compartilhado por renderer Skia;
- foco, mouse, teclado, disabled e DPI;
- streaming DFM correto;
- `Notification`/`FreeNotification` para referências externas;
- smoke case na galeria.

## 4. Implementar componentes compostos

Implemente cards de resumo, badges/chips/tags/pills, toast/tooltip/modal, progress, paginação, loaders, charts e report viewer. Use `TCustomControl`/`TGraphicControl` quando isso for mais seguro do que um hook.

Para componentes compostos, siga a separação aplicada na Ancoragem: componente recebe tema, métricas, assets, dados e estado por contrato; renderer desenha; container roteia interação; form apenas orquestra ciclo de vida e integra serviços. Cards são containers visuais e não desenham gráficos internamente; charts, métricas, painéis, listas ou futuros conteúdos são filhos hospedados.

## 5. Montar a galeria de 15 seções

Use `references/05-gallery-layout.md`. A galeria deve demonstrar estados normal, hot/focus, pressed/selected, disabled, success, warning e danger quando pertinentes. Não reserve espaços vazios para as famílias removidas; redistribua status/progress/feedback no grid.

## 6. Packages e design-time

- Separe runtime e design-time.
- Registre componentes apenas no package design-time.
- Mantenha hooks no runtime.
- Ajuste os `requires` à versão detectada do Delphi.
- Não invente sufixos de package sem conhecer o toolchain.

## 7. Verificar

Execute:

```bash
python <skill-dir>/scripts/validate_skill.py
python <skill-dir>/scripts/verify_starter.py
python <skill-dir>/scripts/audit.py --root . --output .codex/maxui-audit-after.json --strict
```

Depois execute builds reais disponíveis. Na ausência do compilador Delphi, faça validação estática e declare essa limitação.

Confirme:

- nenhum hook global acidental;
- registros/desregistros pareados;
- nenhuma unit FMX no runtime VCL;
- nenhuma classe da árvore/menu lateral ou barra de ferramentas;
- todas as 15 famílias presentes;
- design system da Ancoragem aplicado por tokens e tema;
- foco/teclado funcionais;
- DPI documentado/testado;
- Skia obrigatório, integrado e sem fallback GDI para desenho visual da suíte.

# Estratégia de leitura progressiva

- projeto completo: leia todas as referências;
- botão/input: `01`, `02`, `03`, `04` e `09`;
- galeria: `02`, `05` e `09`;
- Skia/design system Ancoragem: `01`, `02`, `06` e `09`;
- auditoria/review: `04`, `07`, `08` e `09`;
- flicker/DPI: `02`, `04`, `06` e `07`.

# Contrato de saída do Codex

Ao concluir, informe:

1. o que foi implementado;
2. arquivos criados/alterados;
3. decisões de arquitetura;
4. comandos executados e resultados reais;
5. limitações não verificadas;
6. próxima ação apenas quando indispensável.

Quando o usuário pedir implementação, não responda apenas com pseudocódigo. Edite o repositório, execute as verificações possíveis e entregue diff revisável.

# Definição de pronto

A tarefa só está pronta quando os critérios aplicáveis forem atendidos:

- camadas sem dependência cíclica;
- tokens centralizados;
- renderer Skia compartilhado;
- hooks localizados e pareados;
- controles nativos preservam comportamento;
- 15 famílias implementadas e demonstradas;
- classes removidas ausentes;
- design system Ancoragem consistente por tokens;
- estados visuais completos;
- DPI, teclado e foco tratados;
- Skia4Delphi obrigatório e corretamente integrado;
- runtime/design-time separados;
- demo executável no toolchain alvo;
- smoke test ou testes existentes atualizados;
- build real executado ou limitação declarada.
