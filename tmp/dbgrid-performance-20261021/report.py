from pathlib import Path
import json, xml.etree.ElementTree as ET

root = Path(r'M:\MaxxSoft\MaxxRural\Desktop\maxxrural')
tests = root / 'MaxxRural/src/Tests'
out = tests / 'Resultados/20261021-grid-performance'
summary = json.loads((out / 'summary.json').read_text('utf8'))
suite = ET.parse(out / 'apitestes-todos.xml').getroot()
assert suite.attrib['total'] == '298', suite.attrib
assert suite.attrib['errors'] == suite.attrib['failures'] == '0', suite.attrib

table = '| Registros | Carga local (ms) | Associar + pintar (ms) | Pintura p95 (ms) | Scroll vertical p95 (ms) | Scroll horizontal p95 (ms) |\n|---:|---:|---:|---:|---:|---:|\n'
for row in summary:
    if row['checkbox']: continue
    interval = lambda key: f"{row[key]['min']:.1f}–{row[key]['max']:.1f}"
    table += f"| {row['rows']:,} | {interval('dataset_load_ms')} | {interval('attach_first_paint_ms')} | {row['paint']['worst_p95_ms']:.2f} | {row['vertical_scroll']['worst_p95_ms']:.2f} | {row['horizontal_scroll']['worst_p95_ms']:.2f} |\n"
large = next(x for x in summary if x['rows'] == 10000 and not x['checkbox'])
selection = next(x for x in summary if x['rows'] == 10000 and x['checkbox'])
readme = f'''# TDACDBGrid: performance com mais de 1.000 registros — 21/10/2026

## Resultado observado

**36 execuções do benchmark aprovadas**: 12 cenários por rodada, três rodadas em processos novos. As três configurações reais de grid (Prontos, Conciliar e Importados) foram exercitadas com 1.001, 5.000 e 10.000 registros. A referência de 100 registros e os cenários extras de checkbox foram executados em Prontos.

{table}
Valores com ponto decimal em milissegundos. Carga/associação apresentam mínimo–máximo entre as rodadas/abas. Cada p95 da tabela é o **maior p95 individual** entre as rodadas/abas correspondentes, não o percentil de uma amostra agregada. Para cada volume principal existem nove medições de cenário (três abas × três rodadas) e 540 amostras por operação repetida. Referência de 100 registros: três cenários, 180 amostras por operação. Os resultados de checkbox estão separados.

Com 10.000 registros, hover teve pior p95 de {large['hover']['worst_p95_ms']:.2f} ms; clique em Detalhes, {large['action']['worst_p95_ms']:.2f} ms; após ordenar, {large['action_after_sort']['worst_p95_ms']:.2f} ms. A primeira ordenação crescente de MOV_VALOR, incluindo sua pintura, levou {large['sort_cold_ms']['min']:.2f}–{large['sort_cold_ms']['max']:.2f} ms. Saltos ao meio/fim ficaram até {large['jump_middle_ms']['max']:.2f}/{large['jump_last_ms']['max']:.2f} ms.

Não houve falha de navegação, exceção ou ativação duplicada nos cenários. A pintura consultou exatamente **27 estados de ação por frame medido** (nove linhas × três ações), tanto com 100 quanto com 10.000 registros. `ControlCount` e `ComponentCount` da grid permaneceram em **0 → 0**. Objetos do processo carregado ficaram em 51 GDI/33 USER em todos os volumes e retornaram a 35/26 após destruir o host de cada cenário. Isso evidencia custo de controles/handles independente da quantidade de registros neste ensaio; não constitui auditoria geral de vazamentos.

O working set do processo com 10.000 registros ficou entre {large['working_set_loaded_bytes']['min']/1048576:.2f} e {large['working_set_loaded_bytes']['max']/1048576:.2f} MiB. Esse é o processo ApiTestes inteiro, com bibliotecas, caches e dataset; não é o consumo isolado do componente, nem pico de memória. Working set antes/carga/depois da liberação constam nos JSONs; o alocador pode reter memória para reutilização.

## Pontos de atenção medidos

1. A alternância entre os extremos horizontais foi a operação mais cara: pior p95 até {max(x['horizontal_scroll']['worst_p95_ms'] for x in summary if not x['checkbox']):.2f} ms. Seu tempo variou pouco entre volumes, indicando que a quantidade de registros não dominou esse custo. Não se conclui sustentação de 60 FPS; seriam necessárias medições de apresentação e profiling para localizar e reduzir repinturas nessa interação.
2. Com checkbox habilitado e todos os registros desmarcados, 10.000 registros elevaram a mediana de navegação vertical de {large['vertical_scroll']['median_of_medians_ms']:.2f} para {selection['vertical_scroll']['median_of_medians_ms']:.2f} ms; o pior p95 passou de {large['vertical_scroll']['worst_p95_ms']:.2f} para {selection['vertical_scroll']['worst_p95_ms']:.2f} ms. A análise do caminho confirma `SelectionController.CalculateState` percorrendo o dataset para resolver o estado global uniforme. Esse é um ponto de otimização para volumes maiores; não houve alteração do runtime nesta entrega. O DFM atual do Movimento Bancário mantém esse checkbox desligado.

## Método e ambiente

- ApiTestes oficial, nova unit `Teste.MovimentoBancario.PerformanceGrid.pas`, registrada no DPR existente. Nenhum projeto avulso e nenhuma alteração de dproj/IDE.
- MSBuild `/t:Rebuild`, Debug/Win32, Delphi 10.2 (dcc32 32.0). ApiTestes.exe permanece em `EXE`. Avisos H2219 anteriores do consumidor permanecem; nenhum erro de compilação.
- Intel Core i7-13700H, 14 núcleos/20 processadores lógicos, aproximadamente 16 GB de RAM, Windows 11. Detalhes em environment.json.
- Um host VCL visível por cenário; leitura do bloco correspondente do **DFM real em execução**. 12 colunas, três ações, Opções fixa à direita. View/Controller/Service e formulário operacional não são instanciados. Layout persistido é desligado no fixture para obter geometrias iguais.
- Viewport cliente físico 963 × 373 px, métricas de 96 PPI, tema herdado padrão da sessão (claro). Não houve ensaio de performance em tema escuro ou outras escalas nesta entrega.
- TClientDataSet local com 13 campos: chaves COD_EMP/MOV_COD, datas, valores Currency positivos/negativos/nulos, textos e memo com mais de 400 caracteres; sem acesso à API ou operações financeiras. Carga em lote com controles do dataset desativados, antes de associar à grid.
- `TStopwatch`/QPC mede processamento síncrono desde a entrada ou invalidação até retornar de `UpdateWindow` do HWND. Janela já exibida para medir associação + primeira pintura dos dados; oito pinturas de aquecimento antes das amostras repetidas. Asserções e consulta de recursos ficam fora dos intervalos cronometrados.
- 60 amostras para cada operação: pintura, passo vertical, scroll horizontal alternando extremos (SB_RIGHT/SB_LEFT), hover, clique em Detalhes, clique após ordenar. Seis ordenações alternadas crescente/decrescente; índices locais são reaproveitados nas repetições aquecidas. Saltos ao meio/fim são medições individuais por cenário.
- Os cliques verificam uma única ativação, identidade composta correta no último registro e após ordenação. A navegação vertical verifica mudança efetiva de registro. Estado por pintura e contagens de controles também têm asserções.
- Os eventos da grid são resolvidos no helper de teste, que usa o mesmo adaptador local de ordenação. Não há chamada a Controller/Service, nem ações financeiras reais.

## Validações distintas

**Benchmark automatizado executado:** run01/run02/run03.log e XML: 12/12 cada, zero erros/falhas/ignorados/vazamentos reportados pelo DUnitX. JSONs por cenário, measurements.csv e summary.json contêm as medições. As estatísticas não são asserções de SLA; não há limiar de tempo artificial para aprovar o teste.

**Regressão automatizada executada:** suíte completa oficial com **298/298 aprovados**, zero erros/falhas/ignorados/vazamentos reportados, em {suite.attrib.get('time', '?')} s (apitestes-todos.log/xml), com banco Firebird novo e isolado. Inclui os 286 testes anteriores. Os JSONs dessa execução ficam em suite-performance, separados das três rodadas usadas na tabela.

**Compilação executada:** Rebuild do ApiTestes aprovado (build.log). O runtime e o desktop não foram alterados nesta entrega; nenhuma recompilação nova do MaxxRural/pacotes é declarada. Os Rebuilds da correção anterior de gaps estão em `../20261021-grid-gaps/`.

**Homologação visual/manual:** não executada novamente com esses volumes. As janelas foram efetivamente criadas e pintadas pelos testes automatizados, porém não se declara inspeção humana da tela operacional, arraste físico contínuo do thumb, medição de FPS/GPU, performance de rede/banco remoto, tema escuro ou DPI diferentes. A entrega anterior documenta sua própria conferência visual de gaps, com outro volume de dados.

## Reproduzir

1. Execute `compilar.cmd` nesta pasta para Rebuild do ApiTestes.
2. Execute `executar-performance.ps1`: três rodadas sequenciais, um processo por rodada, sem executar outros fixtures de UI em paralelo.
3. Execute `consolidar.py` com Python para conferir os XMLs/hashes e gerar CSV/summary.json.
4. `executar-testes.ps1` executa a suíte completa contra um arquivo Firebird novo, restaurando as variáveis de ambiente ao sair.

O fixture pode ser filtrado por `--run:Teste.MovimentoBancario.PerformanceGrid.TMovimentoBancarioPerformanceGridTests`. A variável `DAC_GRID_PERF_OUTPUT_DIR` define o destino dos JSONs; o runner a restaura. Feche aplicações pesadas/overlays para comparar números e conserve viewport/build iguais.

## Escopo e rastreabilidade

Alterados nesta etapa: nova unit de benchmark, um include no DPR, scripts/evidências, seção de performance em columns.md e atualização de source/README.md. Não houve alteração do componente em produção, dos handlers da View ou do DFM. Codificação CP1252/CRLF dos fontes preservada. Alterações anteriores dos repositórios preservadas; nenhum commit.

format-checks.json registra formatos e hashes iguais do runtime/DFM/fixture anterior. source-sha256.json identifica os fontes; executaveis.json identifica os binários em EXE. A auditoria estática (audit.json) mantém 272 arquivos, 32 pares de hooks e 15 famílias, com oito avisos TODO anteriores fora desta entrega; ela não foi usada como evidência de performance.
'''
(out / 'README.md').write_text(readme, encoding='utf8')
p = root / 'source/README.md'
current = p.read_bytes().decode('cp1252').replace('\r\n','\n')
heading = '## Performance da TDACDBGrid com 1.001 a 10.000 registros — 21/10/2026'
assert heading not in current
current += f'''\n\n{heading}

Benchmark integrado ao ApiTestes oficial, usando em execucao as configuracoes
das tres grids do DFM real. Tres rodadas de 12 cenarios aprovadas; suite
completa final: 298 testes aprovados. Rebuild do ApiTestes aprovado, EXE no
diretorio oficial. Pintura e scroll vertical mantiveram tempos proximos entre
1.001 e 10.000 registros, sem aumento de controles/handles por registro.
Scroll horizontal foi o maior custo; selecao global por checkbox uniforme
acrescenta custo de varredura. Runtime e DFM nao foram alterados nesta etapa.
Medições locais automatizadas, sem homologacao manual da tela operacional,
API remota ou FPS de apresentacao. Relatorio, ambiente, CSV/JSON e logs em:
`MaxxRural/src/Tests/Resultados/20261021-grid-performance/README.md`.
'''
p.write_bytes(current.replace('\n','\r\n').encode('cp1252'))
print('Evidence README and consumer current-state updated. Suite:', suite.attrib['total'])
