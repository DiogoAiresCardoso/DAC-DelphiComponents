# TDACChart — base técnica consolidada

Última consolidação: **23/09/2026**. Este é o ponto de entrada da documentação de
desenvolvimento, desenho, tipografia, fontes de referência e validação dos gráficos.

**Atualização da API:** opções fechadas agora usam enums/sets; medidas, limites e
cores usam objetos tipados. A validação central e transacional está em
`DAC.Components.Charts.Types`. Consulte o [capítulo 11](manual/11-api-tipada.md)
para migrar os exemplos antigos com strings.

**Distribuição portátil:** o demo incorpora MIDAS para o dataset local, valida os
arquivos antes de criar a galeria e encerra com diagnóstico quando a inicialização
falha. [Correção e testes de 23/09](portable-startup-2026-09-23.md).

**Atualização de layout:** o título/subtítulo reserva altura medida com fonte
Windows e mais **12 DIP** antes da área cartesiana. O espaço acompanha o DPI;
margens maiores são preservadas e título vazio/oculto não ocupa área.
Veja o [contrato de desenho](manual/04-geometria-desenho.md) e as
[evidências do ajuste](evidence/title-spacing-2026-09-22/README.md).

**Contrato oficial:** Apache ECharts **6.1.0**. Runtime Delphi/VCL, geometrias e
efeitos Skia, texto Windows nativo. O tema DAC é uma escolha explícita. O componente
não executa JavaScript, não incorpora navegador e não é uma implementação completa
do catálogo ECharts.

**Estado de aceite:** implementação parcial. A última comparação arquivada contra
ECharts, na etapa da API tipada, passou em 29/29 landmarks geométricos e 28/29
conteúdos textuais. Depois dela, o espaçamento do título passou nos testes Delphi
específicos e o demo foi executado, sem nova comparação integral com ECharts.
V15, pintura completa, baseline Windows e continuidade física continuam pendentes.
Esta consolidação documental relê esses resultados; não recompila o renderer.
O [registro de 23/09](consolidation-2026-09-23.md) separa as etapas e seus limites.

## Roteiro de leitura

| Necessidade | Documento |
| --- | --- |
| Entender decisões, escopo e precedência | [01 — Decisões e contratos](manual/01-decisoes.md) |
| Encontrar responsabilidades e fluxo do código | [02 — Arquitetura e ciclo de vida](manual/02-arquitetura.md) |
| Usar opções, DFM, JSON, dados e callbacks | [03 — Configuração e dados](manual/03-configuracao-dados.md) |
| Implementar ou revisar coordenadas e pintura | [04 — Geometria e desenho](manual/04-geometria-desenho.md) |
| Trabalhar com fontes, texto, rich text e DPI | [05 — Tipografia e DPI](manual/05-tipografia-dpi.md) |
| Entender buffers, animação, tooltip e estabilidade | [06 — Composição e interação](manual/06-composicao-interacao.md) |
| Reproduzir demo, builds, comparação e benchmark | [07 — Demo e operação](manual/07-demo-operacao.md) |
| Interpretar testes e planejar o aceite completo | [08 — Testes e evidências](manual/08-testes-evidencias.md) |
| Continuar a implementação sem perder decisões | [09 — Pendências e manutenção](manual/09-pendencias-manutencao.md) |
| Consultar referências oficiais e atribuições | [10 — Fontes e proveniência](manual/10-fontes-proveniencia.md) |
| Usar enums, medidas/cores tipadas e validação estrita | [11 — API tipada](manual/11-api-tipada.md) |
| Ver propriedades publicadas e getters reais | [Catálogo da API](manual/catalogo-api.md) |
| Ver as 29 fixtures e a cobertura por opção | [Catálogo de cenários](manual/catalogo-cenarios.md) |
| Consultar inventários para automação | [Opções aceitas](manual/catalogo-opcoes.json), [símbolos e hashes](manual/catalogo-fontes.json) |

## Regras de interpretação

Os capítulos usam quatro classificações:

- **Contrato:** comportamento exigido pelo plano e pela referência oficial.
- **Implementado:** comportamento encontrado no código local; não implica aprovação.
- **Evidência:** observação ligada a um teste/artefato e ao ambiente registrado.
- **Pendente:** implementação, verificação ou decisão ainda necessária.

Uma chave presente em uma whitelist não prova suporte completo aos valores dessa
opção. Uma propriedade publicada não prova efeito visual. Um teste passando não
aprova recursos fora daquilo que ele mede. Um arquivo em `evidence/` é uma evidência
arquivada, não uma baseline aprovada.

## Fontes internas e histórico

O [guia curto da API](tdacchart-options-api.md) e o [README do demo](../../demo-charts/README.md)
servem para iniciar rapidamente. O [relatório da implementação](implementation-2026-09-22.md)
registra o estado da primeira entrega. A [auditoria anterior](validation-2026-09-22.md)
descreve a API substituída e suas sete falhas; números de linha dela são históricos.

O [estudo ECharts](echarts-reference/README.md), sua [matriz](echarts-reference/property-matrix.md),
os [contratos normativos](echarts-reference/implementation-contracts.md) e o
[roteiro de aceite](echarts-reference/acceptance.md) continuam como especificação.
O arquivo de casos usado na execução é
[`Tests/Charts.Visual/fixtures.json`](../../Tests/Charts.Visual/fixtures.json), com
os 14 casos originais e 15 extensões. `echarts-reference/reference-cases.json`
preserva os 14 casos da pesquisa inicial.

As páginas antigas `dac-chart-api.md`, `dac-chart-data-sources.md`,
`dac-chart-single-component-plan.md`, `echarts-property-map.md` e
`dac-charts-demo.md` não devem orientar código novo quando conflitarem com esta base.

## Conservação do conhecimento

O inventário pode ser reconstruído com
[`tools/build_catalog.py`](tools/build_catalog.py). Ele extrai declarações, getters,
whitelists, símbolos e cenários; não compila Pascal nem substitui RTTI/testes de efeito.
Os capítulos explicativos exigem revisão humana quando o código mudar.

Use `python docs/charts/tools/build_catalog.py --check` para conferir os catálogos e
`python docs/charts/tools/verify_documentation.py` para verificar links locais,
JSON, hashes e mapeamento das sequências arquivadas. Esses comandos não executam o
renderer nem alteram o aceite dos gráficos.

As evidências estão separadas por alteração, com hashes e origem:

| Etapa | Arquivo |
| --- | --- |
| Reconstrução inicial, comparação ECharts e sequências | [Execução inicial](evidence/2026-09-22/README.md) |
| API tipada, rollback e regressão das 29 imagens | [Tipos](evidence/types-2026-09-22/README.md) |
| Medição do título, margem automática e demo | [Espaçamento](evidence/title-spacing-2026-09-22/README.md) |

Nenhum resultado foi promovido a aprovação durante a consolidação documental.
O [registro atual](consolidation-2026-09-23.md) descreve a integração das alterações;
o [registro inicial](consolidation-2026-09-22.md) permanece como histórico.
