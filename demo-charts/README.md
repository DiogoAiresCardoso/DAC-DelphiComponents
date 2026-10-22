# Demo exclusivo de gráficos

Manual completo: [base técnica TDACChart](../docs/charts/README.md), incluindo
arquitetura, desenho, fontes, limites de suporte e evidências preservadas.

A página Elementos visuais inclui orientação de legenda com padrão/horizontal/vertical,
aplicada por enum Delphi. Consulte a [API tipada](../docs/charts/manual/11-api-tipada.md).

O título/subtítulo reserva automaticamente sua altura mais 12 DIP antes da área
cartesiana. A regra acompanha fonte, texto e DPI; título oculto/vazio não reserva
área. [Fixture e imagens do ajuste](../docs/charts/evidence/title-spacing-2026-09-22/README.md).

`DACChartsDemo.dproj` usa o mesmo formulário dos perfis `DACChartsHighDpi.dproj` e
`DACChartsNoHighDpi.dproj`. O executável precisa apenas de `sk4d.dll` e
`reference-cases.json`, copiados pelo build. Não usa banco externo nem rede.

Distribua **os três arquivos do mesmo build**, preservando o nome `sk4d.dll` e sua
arquitetura. O dataset local usa `MidasLib` estático: não precisa de `midas.dll` nem
de Delphi instalado. O arquivo de cenários é procurado ao lado do EXE; para outro
local use `--fixtures`. Erro de inicialização encerra o demo e grava diagnóstico
em `%TEMP%\DACChartsDemo-startup-error.txt` (ou `error.txt` quando houver `--out`).
[Correção e testes de portabilidade](../docs/charts/portable-startup-2026-09-23.md).

A abertura normal apresenta a galeria. A configuração do cenário selecionado pode
ser aplicada/restaurada/importada/exportada/copiada na página Configuração. Elementos
visuais demonstra opções públicas. Comparação abre as imagens produzidas pela
bancada; não executa ECharts dentro do componente. Animação e estabilidade concentra
as métricas, replay, atualização e captura.

Exemplo de execução automatizada:

```powershell
& '.\DACChartsDemo.exe' --fixtures '.\reference-cases.json' --out '.\capturas' --case all | Out-Null
```

Use o pipeline `| Out-Null` em PowerShell para aguardar o executável GUI terminar.
`result.txt` indica sucesso; `error.txt` e código de saída diferente de zero indicam
erro. `--case C01` seleciona um cenário. `--width`, `--height` e `--dpi` configuram
a captura; o DPI aplicado por argumento é sintético.

`--buffer-only` permite teste automatizado com janela oculta, omitindo a captura
do DC visível. Não usar esse modo como prova de apresentação física ou flicker.

Laboratório de carga:

```powershell
& '.\DACChartsDemo.exe' --out '.\carga' --case C01 --stress --points 996 --frames 120 --dpi 144 | Out-Null
& '.\DACChartsDemo.exe' --out '.\animacao' --case V11 --stress --animate --frames 120 --screen | Out-Null
```

`--screen` registra amostras do desktop somente quando a janela está em primeiro
plano e seu retângulo pode ser capturado. Zero amostras é inconclusivo. Capturas de
buffer ou do DC da janela não aprovam ausência de flicker. Use diretório novo em
cada execução.

Bancada completa (Delphi, Node/Playwright e Python com Pillow/numpy):

```powershell
.\Tests\Charts.Visual\run.ps1 -Output tmp\nova-execucao `
  -EChartsScript caminho\echarts-6.1.0.min.js -Python caminho\python.exe
```

A versão/hash do ECharts e o Chromium exigidos estão em `Tests/Charts.Visual/fixtures.json`.
A bancada falha quando geometria ou conteúdo/clipping de texto diverge. No estado
registrado existe uma reprovação de truncamento em V15; confira o
[registro atual](../docs/charts/consolidation-2026-09-23.md). A comparação de 29 casos
é anterior ao ajuste do título; o ensaio deste ajuste é documentado separadamente.
