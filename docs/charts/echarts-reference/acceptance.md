# Casos de referência e critérios de conformidade

[Índice](README.md) · [Opções em JSON](reference-cases.json)

Os casos JSON são **exemplos autorais para a futura implementação**, com opções ECharts e expectativas declaradas. A validação desta tarefa verifica estrutura, links locais e consistência matemática; não executa ECharts nem comprova que o DAC já os atende.

## Execução futura

1. Usar ECharts **6.1.0**, tema padrão, locale/fuso controlados e o viewport indicado.
2. Para cada caso, passar somente `option` a `chart.setOption(option, {notMerge: true})`; o envelope JSON contém metadados e não é uma opção ECharts.
3. No DAC reconstruído, fornecer dados/opções equivalentes. Não usar `ctArea` ou `ctDoughnut` como tipos canônicos.
4. Comparar primeiro coordenadas e domínios, depois rótulos e interação, por fim imagem. Fixar fontes e desativar animação nos casos geométricos.
5. Expectativas numéricas referem-se à transformação do domínio do caso, não ao antialiasing da imagem. Para comparar centros em pixels, usar o retângulo útil calculado por cada engine ou forçá-lo igualmente.
6. Registrar versão, opções resolvidas, tamanho/DPI, fonte, dados, captura e resultado. Repetir com tema DAC explícito para separar falha de engine e estilo.

## Casos fornecidos

| ID | Cenário | Critério principal |
| --- | --- | --- |
| C01 | Barra + linha em três categorias | Mesma coordenada X por categoria |
| C02 | Eixo numérico irregular | X `0,1,100` em `0..100`: `0,0.01,1` |
| C03 | Eixo temporal irregular UTC | Distâncias proporcionais a dias, não índice |
| C04 | Escala manual | Y `0..100` preservado sem margem automática |
| C05 | Duas categorias | A e B presentes, sem repetição artificial |
| C06 | Área com nulo | Segmentos separados; preenchimento não atravessa a lacuna |
| C07 | Positivos e negativos | Valores em lados opostos da base zero |
| C08 | Rosca com valores positivos | Ângulos proporcionais e centro sem hit |
| C09 | Pizza com soma zero, defaults | Setores iguais conforme `stillShowZeroSum=true` |
| C10 | Pizza com soma zero, opção desligada | Não desenhar setores de proporção fictícia |
| C11 | Dataset por colunas | Encodes explícitos e séries independentes |
| C12 | Dataset por linhas | Transposição real de categorias/séries |
| C13 | Empilhamento por sinal | Acumuladores positivos e negativos independentes |
| C14 | Barra horizontal | Valor em X e categoria em Y |

Os casos C13/C14 são alvo de expansão; não pressupõem suporte no componente atual. C09 testa dados existentes de valor zero; dataset vazio exige teste separado de `showEmptyCircle`.

## Regressões específicas da integração Delphi

- Campo configurado ausente versus NULL real; erro do adapter não deve ser confundido com série válida vazia.
- Dataset filtrado/ordenado, master/detail, origem em edição, origem destruída e datasource trocado.
- `Parent=nil`, streaming DFM completo, recriação de handle e ausência de timers após destruição.
- Atribuir apenas cor/título/fonte/tamanho não provoca nova leitura da fonte quando dados/encodes não mudaram.
- DataSource é adapter de entrada; seleção/zoom do gráfico não executam `Post`, `ApplyUpdates` ou navegação implícita na origem.

## Testes adicionais para declarar o núcleo conforme

| Área | Casos |
| --- | --- |
| Defaults | Ausente versus false/0; configuração global, por série, tema e usuário; round-trip |
| Escalas | Vazio, um ponto, iguais, apenas negativos, valores pequenos/grandes, limites fixos e inverse |
| Tempo | UTC/local, datas civis, hora fracionária, fevereiro, ano novo e fuso explícito |
| Categoria | 1, 2, 3, 4, 5 e muitas categorias; nomes repetidos; rótulos longos; mudanças de ordem |
| Line/area | Null no início/meio/fim, X repetido, smooth, step, símbolos e clipping |
| Pie | Vazio, todos nulos, todos zero, negativos, não finitos, uma fatia, muitas fatias, padAngle e seleção |
| Tooltip | item/axis/none; posição entre marcadores; atualização dos valores sem mover mouse |
| Legenda | Ocultar/mostrar série, fatia, seleção single/multiple e overflow |
| Animação | Entrada, alteração, remoção, reordenação por identidade, interrupção e desativação |
| Layout | Pequeno/grande, resize contínuo, tema claro/escuro, DPI 96/120/144/192 |
| Acessibilidade | Foco, teclado, descrição/listagem dos dados e distinção além de cor |
| Desempenho | 100, 1.000 e 10.000 pontos; medir tempo/memória e leituras da origem antes de fixar metas |

Negativos/não finitos em pizza e casos de domínio inválido precisam de comportamento observado na engine normativa, inclusive etapas de processamento. Nenhum caso pendente deve ser “resolvido” copiando a decisão antiga DAC sem comparação.

## Critério de entrega

Para cada recurso: nome e semântica oficiais, default de origem identificado, efeito implementado, teste matemático quando aplicável, teste de integração e comparação visual/interativa. Recurso não implementado deve aparecer como não suportado; não como opção aceita e ignorada.

Compilar Delphi prova compilação. Aprovar geometria exige asserções de coordenadas/dados. Aprovar aparência exige inspeção renderizada. Aprovar uso no consumidor exige homologação própria. O levantamento documental não equivale a nenhuma dessas aprovações futuras.

## Verificação deste levantamento — 22/09/2026

- JSON carregado com sucesso, 14 IDs únicos e correspondentes à tabela; somente tipos canônicos `bar`, `line` e `pie`, todos com animação desativada.
- Conferidos por cálculo independente: posições X numéricas/temporais, centros de categorias, proporções da rosca, base/extremos das barras com sinal e somas do exemplo empilhado.
- Os 15 links locais dos quatro documentos desta pasta resolvem para arquivos existentes; verificação de whitespace sem ocorrências.
- O fonte `DAC.Components.Controls.Charts.pas` permanece com o SHA256 registrado na auditoria anterior: `8754C08DEFB40540A4E1A8E8BAA7ED34441B61284EC0D920886AF335D85CB6B2`.
- Não houve execução destes casos no ECharts ou DAC, nova compilação Delphi nem alteração do runtime nesta etapa documental.
