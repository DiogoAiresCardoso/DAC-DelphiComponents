> **Estado atual — 23/09/2026:** consulte a [consolidação atual](consolidation-2026-09-23.md) para API tipada, validação transacional, espaço do título e evidências posteriores. O conteúdo abaixo preserva sua etapa histórica.

# Validação do TDACChart — 22/09/2026

> Histórico: esta auditoria precede a reconstrução da API Options. Código, linhas e
> resultados abaixo pertencem à implementação antiga. Para o estado reconstruído,
> consulte a [base técnica consolidada](README.md) e o [relatório de implementação](implementation-2026-09-22.md).

O componente compila e passa na suíte existente, mas há falhas confirmadas na representação dos dados. Não está aprovado para uso analítico geral sem corrigir coordenadas, categorias e leitura data-aware.

## Escopo e método

- Estado atual do checkout, incluindo alterações locais preexistentes; não é uma comparação de branches.
- Foco no componente registrado `TDACChart`, em `Source/Controls/DAC.Components.Controls.Charts.pas`, seus contratos, adapters, testes e demo exclusivo. `TDACStatusTimelineChart` foi identificado como componente separado e não recebeu validação funcional completa nesta auditoria.
- Fontes do componente, adapters e testes existentes não foram alterados. Foram criados este relatório e artefatos de diagnóstico em `tmp/chart-validation-20260922`.
- SHA-256 da unit analisada: `8754C08DEFB40540A4E1A8E8BAA7ED34441B61284EC0D920886AF335D85CB6B2`.
- O diagnóstico adicional compila uma cópia local da unit, com a única transformação de visibilidade `private` → `public`, para inspecionar snapshots, textos e áreas de interação. Os corpos dos métodos permanecem intactos. Isso permite reproduzir cálculos internos, mas não substitui testes pela API pública e QA visual.

## Resultados executados

| Verificação | Resultado |
| --- | --- |
| `Tests/DACComponentsCharts.dproj`, Build Win32 Debug, Delphi 10.2 Tokyo / compilador 32.0 | Sucesso; log sem warnings ou erros |
| Executável recém-compilado `DACComponentsCharts.exe` | `DACComponentsCharts: OK` |
| `demo-charts/DACChartsDemo.dproj`, Build Win32 Debug | Sucesso; log sem warnings ou erros |
| Diagnóstico adicional Delphi | Executado; falhas abaixo reproduzidas |
| Vazio, um ponto, valores iguais e ponto nulo | Geometria criada sem exceção; respectivamente 0, 1, 3 e 2 áreas de dados nos cenários pertinentes |
| Rosca com total zero e interação no centro vazado | Zero áreas para total zero; centro não responde ao hit-test |

Todas as saídas de compilação foram isoladas em `tmp/chart-validation-20260922`. Logs: `build-tests.log`, `build-demo.log`, `build-diagnostic.log` e `diagnostic-results.txt`.

A suíte original executa oito rotinas: DPI sintético, animação, refresh data-aware, layout por colunas, propriedades visuais, streaming/lifecycle, tipos e composição, tipografia padrão. Vários cenários verificam ausência de exceção, estado do cursor ou propriedades; não verificam as coordenadas e rótulos resultantes. Por isso seu sucesso é compatível com as falhas encontradas.

O auditor genérico da skill foi executado sobre `Source`: registros/desregistros de hooks 25/25. A detecção de famílias procura nomes `TMax...` e produz falsos negativos nesta suíte `TDAC...`; não serve como reprovação das famílias DAC. Seus avisos fora dos gráficos não foram usados como achados desta auditoria.

## Falhas confirmadas

### 1. Alta — eixo X numérico/temporal usa posição ordinal

Em `Charts.pas:4110` e `:4132`, linha/área usam o índice do ponto para calcular X. `AxisType` muda o texto, mas não fornece uma transformação numérica/temporal para a geometria. `XAxis.AutoScale`, `Min` e `Max` não são consumidos no cálculo de coordenadas.

Reprodução: valores X `0, 1, 100` geraram posições normalizadas `0, 0.5, 1`, em vez de `0, 0.01, 1`. Fixar o eixo em `0..200` manteve X=100 na extremidade direita, em vez do centro. O mesmo caminho ordinal é usado quando `AxisType=catTime`.

A leitura data-aware agrava isso: `Charts.pas:2460` atribui `XValue := LIndex`. Campos X `10` e `100` geraram `XValue=0` e `1`; `EncodeX` alimentou somente o texto da categoria.

Correção indicada: preservar X tipado no snapshot e aplicar uma transformação de eixo compartilhada por linhas, áreas, barras, rótulos, grid e hit-test, distinguindo categoria, número e data.

### 2. Alta — barras e linhas da mesma categoria ficam desalinhadas

`Charts.pas:3463` distribui barras em N faixas; linha/área usam N−1 intervalos (`:4110`). Os eixos usam outra distribuição baseada nos extremos (`:3414`).

Reprodução com três categorias: a primeira barra ficou em aproximadamente 14.41% da largura útil; o primeiro ponto da linha, em 0%. As duas marcas representam a mesma categoria A. Isso compromete a comparação de realizado/meta e a correspondência com o eixo.

Correção indicada: definir uma única posição central por categoria e derivar dela agrupamento de barras, pontos e ticks.

### 3. Média — rótulos repetidos e categorias finais ausentes

`Charts.pas:3395` divide sempre por 4, mesmo quando o laço desenha menos de cinco rótulos.

Reprodução: categorias `A, B` produziram `A, A`; categorias `A, B, C` produziram `A, A, B`. A última categoria não aparece nesses casos.

Correção indicada: calcular o denominador pela quantidade efetiva de intervalos e tratar explicitamente um único ponto. `XAxis.Ticks` atualmente controla as linhas de grid, mas não esse laço de rótulos.

### 4. Alta — adapter de ClientDataSet ignora o filtro da origem

Os adapters em `demo-charts/DACChartsDemo.ClientDataSetAdapter.pas:38` e `Tests/DACComponentsCharts.ClientDataSetAdapter.pas:38` usam `CloneCursor(Source, True, True)`.

Reprodução: origem com filtro `Y=10` e um registro visível gerou snapshot com dois registros. O cursor original foi preservado, mas o recorte dos dados não.

A documentação oficial informa que `Reset=True` limpa filtros, índice e relacionamentos do clone. A perda do filtro foi reproduzida; master/detail e ordenação precisam de casos específicos antes de afirmar o comportamento completo. [Documentação de CloneCursor](https://docwiki.embarcadero.com/Libraries/Sydney/en/Datasnap.DBClient.TCustomClientDataSet.CloneCursor).

Correção indicada: definir o contrato de leitura da visão filtrada/ordenada e configurar o clone de acordo com ele, preservando também a independência do cursor. O defeito está nos adapters fornecidos como exemplos, não em todos os adapters possíveis.

### 5. Média — campo ausente vira nulo silenciosamente

`Charts.pas:2461`–`:2463` equipara campo inexistente a valor nulo. `FieldText` também retorna fallback para campos ausentes. O contrato em `dac-chart-data-sources.md` promete erro controlado para campo ausente.

Reprodução: `EncodeY='MISSING'` retornou snapshot com `IsNull=True`, sem exceção. Consequentemente, essa condição não chega a `OnDataError` pelo fluxo normal de refresh.

Correção indicada: validar encodes antes de navegar, diferenciando campo obrigatório ausente, valor SQL NULL e texto auxiliar opcional.

### 6. Média — escala Y manual é expandida em gráficos de linha

Após aplicar `YAxis.Min/Max`, `Charts.pas:3639` ainda aplica margem de 5% quando não há barra/área.

Reprodução: linha com `AutoScale=False`, `Min=0`, `Max=100` gerou rótulos extremos `-5` e `105`.

Correção indicada: aplicar margem somente à escala automática; preservar exatamente os limites explícitos.

### 7. Média — prioridade dos encodes de pizza/rosca diverge do contrato

`Charts.pas:2560` prefere `EncodeY` antes de `EncodeValue` para todos os tipos. A API documenta prioridade inversa para pizza/rosca.

Reprodução: pizza com `EncodeY=10` e `EncodeValue=90` recebeu valor 10.

Correção indicada: resolver o campo de valor conforme o tipo da série e testar quando os dois encodes estão preenchidos.

## Contratos e arquitetura que precisam ser atualizados

- **Integração data-aware:** o runtime fornece o registro de adapters, mas não registra automaticamente um adapter de `TClientDataSet`. As implementações concretas encontradas estão em demo/testes. A documentação apresenta um leitor padrão e exemplos sem o passo de registro, que não funcionam isoladamente em uma aplicação consumidora.
- **DPI e texto:** a documentação afirma ausência de API DPI e desenho integral Skia. O código usa `GetDpiForWindow`, `WM_DPICHANGED`, métricas escaladas e texto nativo via `CreateFont`/`DrawText`. Isso é uma divergência documental; texto nativo é compatível com a orientação atual de nitidez da suíte.
- **Invalidação:** `TDACChartPersistent.Changed` chama `ChartChanged`, que faz `QueueRefresh(True)`. Alterar título, legenda, tooltip ou eixos marca dados como sujos e pode reler o dataset. Contradiz a promessa de alterações visuais sem nova leitura. Confirmado por inspeção do fluxo, sem benchmark.
- **Separação de responsabilidades:** a unit principal tem 5.375 linhas, incluindo persistência, leitura, layout, desenho, animação e interação. Existem painters separados nos packages, mas o `TDACChart` atual implementa diretamente seus próprios métodos de desenho. Consolidar essa responsabilidade é uma melhoria de manutenção posterior às correções funcionais.
- **ECharts:** o mapa é conceitual. `SeriesLayoutBy` DAC não implementa toda a semântica de transposição de linhas/colunas do ECharts; a documentação deve deixar o subconjunto explícito.

## Documentação e código de referência consultados

| Referência primária | Aplicação ao componente |
| --- | --- |
| [Apache ECharts — Axis](https://echarts.apache.org/handbook/en/concepts/axis/) | Distinguir categoria, valor e tempo; alinhar ticks, rótulos e coordenadas |
| [Apache ECharts — Dataset](https://echarts.apache.org/handbook/en/concepts/dataset/) | Separar dados/configuração e definir precisamente dimensões e encodes |
| [Cartesian2D.ts, referência 6.0.0](https://github.com/apache/echarts/blob/6.0.0/src/coord/cartesian/Cartesian2D.ts) | `dataToPoint` transforma cada coordenada pelo eixo correspondente |
| [Interval.ts, referência 6.0.0](https://github.com/apache/echarts/blob/6.0.0/src/scale/Interval.ts) | Limites fixos, escala e geração de ticks; distinguir ajuste automático de limites explícitos |
| [line/poly.ts, referência 6.0.0](https://github.com/apache/echarts/blob/6.0.0/src/chart/line/poly.ts) | Separação de segmentos em pontos nulos e construção de linhas/áreas |
| [pie/pieLayout.ts, referência 6.0.0](https://github.com/apache/echarts/blob/6.0.0/src/chart/pie/pieLayout.ts) | Geometria de setores, soma e tratamento de dados degenerados |
| [Skia4Delphi — repositório oficial e exemplos](https://github.com/skia4delphi/skia4delphi) | API de superfícies, paths, shaders e integração Delphi; manter o desenho nativo da suíte |
| [Embarcadero — CloneCursor](https://docwiki.embarcadero.com/Libraries/Sydney/en/Datasnap.DBClient.TCustomClientDataSet.CloneCursor) | Contrato de filtros, índices, relacionamentos e cursor clonado |

As referências ECharts servem como base algorítmica e de contrato. Nenhum código externo foi incorporado ao componente e nenhuma engine JavaScript foi adicionada.

## Próxima etapa e limites da validação

Prioridade: corrigir transformação X/alinhamento e leitura filtrada; em seguida rótulos, campos ausentes, limites Y e prioridade dos encodes. Transformar as reproduções em testes de regressão sobre a implementação corrigida. Atualizar a documentação para o contrato realmente entregue.

Não executados: build Win64, benchmark com grandes datasets, inspeção visual completa da galeria, interação física, troca real de monitores/DPI, acessibilidade, homologação no sistema consumidor e validação funcional completa do timeline. A mensagem sintética de DPI da suíte não comprova per-monitor DPI em uso real. A compilação do demo não equivale a aprovação visual.
