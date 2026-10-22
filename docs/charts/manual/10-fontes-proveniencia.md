# 10 — Fontes oficiais, código de referência e proveniência

[Índice](../README.md) · [Inventário local com SHA-256](catalogo-fontes.json)

Pesquisa de referência de 22/09/2026; documentação local reconsolidada em 23/09/2026,
sem nova consulta externa nem mudança da versão ECharts. “Fontes” inclui referências técnicas e
código-fonte quanto arquivos tipográficos. São inventários distintos: citar um
algoritmo não instala uma fonte; ter uma fonte em disco não prova seu uso pelo GDI.

## Hierarquia de evidência

1. Decisões explícitas do projeto: ECharts 6.1.0, Skia + texto Windows, demo próprio,
   configuração ampla e aceite separado de flicker/compilação/geometria/aparência.
2. Código oficial na tag fixada e execução do bundle com hash conhecido.
3. Documentação oficial de conceitos/opções, identificando que é conteúdo vivo.
4. Código local, símbolos e hashes para descrever o que foi implementado.
5. Imagens, geometria, logs e métricas para descrever o que foi observado.

Não resolver divergência entre documentação viva e versão fixa por suposição.
Reproduzir com uma fixture mínima e registrar a opção resolvida. Não confundir
instrumentação do próprio renderer com uma medição independente da tela.

## ECharts — conceitos e API

| Fonte primária | Utilidade no projeto | Limite da consulta |
| --- | --- | --- |
| [Release 6.1.0](https://github.com/apache/echarts/releases/tag/6.1.0) | Identificar revisão normativa | Não atualizar implicitamente para uma release posterior |
| [Árvore 6.1.0](https://github.com/apache/echarts/tree/6.1.0) | Defaults e implementação versionada | Leitura pontual não equivale a port completo |
| [Catálogo de opções](https://echarts.apache.org/en/option.html) | Descoberta de propriedades | Página depende de JavaScript; resposta textual não contém todo o catálogo |
| [Repositório de documentação](https://github.com/apache/echarts-doc) | Markdown e includes das opções | Branch viva; conferir contra a tag do código |
| [Dataset](https://echarts.apache.org/handbook/en/concepts/dataset/) | Dimensões, cabeçalho, encode e orientação | Adapter Delphi e cursor são contratos locais adicionais |
| [Axis](https://echarts.apache.org/handbook/en/concepts/axis/) | Categoria/valor/tempo e configuração visual | Paridade exige também cálculos e casos executáveis |
| [Rich text](https://echarts.apache.org/handbook/en/how-to/label/rich-text/) | Estilo de blocos/fragmentos e layout | Apenas subconjunto implementado nativamente |
| [Transições](https://echarts.apache.org/handbook/en/how-to/animation/transition/) | Identidade e mudanças de dados | Não prova transição universal no DAC |
| [Canvas e SVG](https://echarts.apache.org/handbook/en/best-practices/canvas-vs-svg/) | Escolha explícita de renderer na referência | Runtime DAC usa Skia, não os renderers JS |

A pesquisa inicial e sua matriz detalhada estão em
[echarts-reference](../echarts-reference/README.md). Referências 6.0.0 presentes na
auditoria antiga documentam a investigação inicial; não são a revisão normativa
da reconstrução. O estudo inicial não executou o browser; a etapa de implementação
posterior produziu as 29 comparações agora arquivadas.

## Mapa de código oficial para responsabilidade local

| Responsabilidade | Fonte oficial fixada | Entrada local para manutenção |
| --- | --- | --- |
| Coordenadas cartesianas | [Cartesian2D.ts](https://github.com/apache/echarts/blob/6.1.0/src/coord/cartesian/Cartesian2D.ts) | `TDACChartEngine.Coord` |
| Escala de intervalo | [Interval.ts](https://github.com/apache/echarts/blob/6.1.0/src/scale/Interval.ts) | `NiceStep`, `Render.Bounds`, `DrawAxes` |
| Calendário/tempo | [Time.ts](https://github.com/apache/echarts/blob/6.1.0/src/scale/Time.ts) | Caminho temporal ainda simplificado |
| Grupos/largura de barras | [barGrid.ts](https://github.com/apache/echarts/blob/6.1.0/src/layout/barGrid.ts) | `DrawSeries`, largura/gaps/stacks |
| Curvas e áreas | [line/poly.ts](https://github.com/apache/echarts/blob/6.1.0/src/chart/line/poly.ts) | `ChartPolyline`, `DrawSeries` |
| Setores e raios | [pieLayout.ts](https://github.com/apache/echarts/blob/6.1.0/src/chart/pie/pieLayout.ts) | `DrawPie`, hit-test angular |
| Truncamento e rich text | [zrender 6.1.0 parseText.ts](https://github.com/ecomfe/zrender/blob/6.1.0/src/graphic/helper/parseText.ts) | `Text`, V15, baseline nativa |
| Dependências exatas | [ECharts package.json 6.1.0](https://github.com/apache/echarts/blob/6.1.0/package.json) | Pinning da bancada e revisão de upgrades |

O package oficial 6.1.0 declara zrender 6.1.0 e tslib 2.3.0. A leitura preliminar
de `parseText.ts` 6.0.0 foi complementada nesta consolidação pela revisão 6.1.0.
O truncamento consultado reserva margem, estima caracteres e limita iterações;
não é o mesmo procedimento local de reduzir um caractere até caber. Essa diferença
explica uma hipótese de implementação para V15; a causa final deve ser confirmada
por teste controlado das métricas, não só por semelhança de código.

## Windows, Delphi e Skia

| Fonte | Conhecimento incorporado |
| --- | --- |
| [Skia4Delphi oficial](https://github.com/skia4delphi/skia4delphi) | Superfícies raster, paths, shaders e integração Delphi |
| [CreateDIBSection](https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-createdibsection) | Bitmap compartilhado, pixels, DC e sincronização |
| [GdiFlush](https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-gdiflush) | Concluir o lote GDI antes de consumir memória |
| [CreateFontIndirectW](https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-createfontindirectw) | LOGFONT, seleção de fonte e métricas |
| [GetTextExtentPoint32W](https://learn.microsoft.com/en-us/windows/win32/api/wingdi/nf-wingdi-gettextextentpoint32w) | Medição com a fonte selecionada |
| [DrawTextW](https://learn.microsoft.com/en-us/windows/win32/api/winuser/nf-winuser-drawtextw) | Formatação, flags e clipping do texto |
| [Relógio de alta resolução](https://learn.microsoft.com/en-us/windows/win32/sysinfo/acquiring-high-resolution-time-stamps) | Tempo monotônico para progresso e benchmark |
| [CloneCursor, documentação Sydney](https://docwiki.embarcadero.com/Libraries/Sydney/en/Datasnap.DBClient.TCustomClientDataSet.CloneCursor) | Efeito de Reset/KeepSettings; verificar no compilador utilizado |

A documentação CloneCursor acessível é de Sydney, enquanto o build é Tokyo.
A prova prática relevante no ambiente local é o teste de filtro/cursor do adapter.
A tentativa de abrir a página Athens não forneceu conteúdo; ela não foi usada como
prova adicional. API de versões posteriores de Delphi não deve ser copiada para
Tokyo sem compilação e execução.

Skia4Delphi do projeto é a dependência efetivamente compilada; a página pública do
repositório é orientação conceitual, não prova de versão binária instalada. O hash
do DLL/executável usado deve acompanhar novas medições. O arquivo de evidência
registra hashes dos binários originais quando disponíveis, sem duplicar os EXEs.

## Fontes tipográficas concretas

Leitura do cabeçalho SFNT dos arquivos locais na consolidação:

| Arquivo | Família/versão | SHA-256 |
| --- | --- | --- |
| `assets/fonts/Inter.ttf` | Inter 4.001; git-66647c0bb | `29160a80ff49ddcab2c97711247e08b1fab27a484a329ce8b813d820dc559031` |
| `DAC/Fonts/DAC-Components-Inter.ttf` | Mesmo binário Inter | `29160a80ff49ddcab2c97711247e08b1fab27a484a329ce8b813d820dc559031` |
| `C:/Windows/Fonts/arial.ttf` | Arial 7.06 | `b3658eadae55e682b5f69eb64c439c1ecc8f196c0bb8d4756d145d13bc86476a` |
| `C:/Windows/Fonts/arialbd.ttf` | Arial Bold 7.06 | `e8f4e3baf6cc35fed6fcce3a540e8b39e8f6cda1d22a28f2ec8f526fef7a43f5` |

Arquivos italic/bold italic e demais Arial encontrados constam no catálogo JSON.
Esses hashes foram observados na consolidação; não existe medição histórica por
glifo que prove que todos os renders anteriores resolveram exatamente esses arquivos.
Os binários Windows não foram copiados para a documentação.

A licença Inter local está em [Inter.OFL.txt](../../../assets/fonts/Inter.OFL.txt).
O nome de arquivo DAC não altera o nome interno da família: ambos continuam Inter.
Não usar a existência dessa cópia como evidência de que o TDACChart adotou Inter.

## Licenças e atribuição

Defaults, espaçamento de barras e controles de suavização foram baseados no ECharts.
A adaptação Pascal é modificada para Skia e texto Windows; não é produto Apache nem
implementação endossada. A atribuição e os textos preservados estão em:

- [NOTICE da adaptação](../echarts-reference/NOTICE.md).
- [LICENSE Apache ECharts](../echarts-reference/APACHE-ECHARTS-LICENSE.txt).
- [NOTICE original](../echarts-reference/APACHE-ECHARTS-NOTICE.txt).

O bundle de referência mantém seus avisos e pertence apenas à bancada. O runtime
Delphi não o incorpora. Ao copiar/adaptar novos trechos, registrar origem, revisão,
modificações e avisos aplicáveis junto à mudança; não remover cabeçalhos existentes.

## Como manter rastreabilidade

`catalogo-fontes.json` guarda caminhos, tamanhos, hashes e símbolos/linhas do código
local. `catalogo-opcoes.json` guarda declarações/getters/whitelists e cobertura
explícita de fixtures. Linhas ajudam navegação, mas o hash define qual conteúdo foi
inventariado. Fontes Windows são inventário da máquina que executa o gerador.

```powershell
python .\docs\charts\tools\build_catalog.py
python .\docs\charts\tools\build_catalog.py --check
```

`--check` não escreve; compara o inventário calculado com os quatro arquivos gerados.
Uma diferença de fonte instalada também torna o catálogo diferente, sem significar
erro de renderer. O script usa biblioteca padrão Python e extrai o estilo atual de
declaração Pascal; não interpreta toda a gramática nem substitui Object Inspector.

Os capítulos são explicações revisadas manualmente. Regenerar JSON não atualiza
automaticamente fórmulas, limites, conclusões nem evidências históricas.
