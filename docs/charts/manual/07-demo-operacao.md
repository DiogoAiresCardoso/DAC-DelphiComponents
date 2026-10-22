# 07 — Demo, builds e reprodução

[Índice](../README.md) · [README operacional](../../../demo-charts/README.md)

## Projetos e distribuição

`demo-charts/DACChartsDemo.dproj` é o executável exclusivo. Os projetos
`DACChartsHighDpi.dproj` e `DACChartsNoHighDpi.dproj` usam o mesmo formulário e lógica.
A estrutura fixa está em `DACChartsDemo.Main.dfm`; criação dinâmica restringe-se
a gráficos/cenários e elementos associados da galeria.

Distribuição do demo: EXE, `sk4d.dll` da arquitetura correspondente e
`reference-cases.json`, copiados pelo build. Esse último é a cópia operacional de
`Tests/Charts.Visual/fixtures.json`, hoje com 29 casos, apesar do nome histórico.
Não depende do demo geral, banco remoto, browser embarcado ou rede em execução.
Instalação de dependências da bancada é uma operação separada.

O runtime MIDAS está incorporado via `MidasLib`. A unit `DACChartsDemo.Startup`
precisa ser a primeira no uses dos três DPRs para validar/carregar a DLL antes
das classes Skia. Fixtures padrão vêm exclusivamente da pasta do EXE; caminhos
externos exigem `--fixtures`. Veja o [relatório de portabilidade](../portable-startup-2026-09-23.md)
para os testes fora do workspace, diagnóstico e limites do ensaio.

## Páginas e fluxo de uso

| Página | Uso | Observação de manutenção |
| --- | --- | --- |
| Galeria | Abrir normalmente e escolher família/cenário | Não iniciar em diagnósticos |
| Configuração | Editar JSON/propriedades; aplicar, restaurar, importar, exportar, copiar | Aplicação JSON passa pela API pública |
| Elementos visuais | Explorar labels, títulos, legenda, tooltip e estilos | Presença do controle não prova todas as combinações |
| Comparação | Abrir referência, DAC, overlay e diff | Exibe arquivos da bancada; não executa ECharts |
| Animação e estabilidade | Atualizar dados, replay, métricas e capturas | Operações de captura podem forçar estado final |

O dataset local contém Jan=10, Fev=20, Mar=NULL, Abr=30. O filtro de demonstração
usa valor >=20; NULL deve permanecer distinto de zero. O adapter preserva o cursor
da origem. Para reproduzir um problema, exporte JSON e registre também estado do
filtro, versão do adapter e dados externos, pois `SaveJSON` não serializa a fonte
TDataSource viva nem toda seleção interativa.

Zoom, múltiplos eixos, tooltip externo/HTML e famílias posteriores devem permanecer
identificados como indisponíveis. Opção parcialmente implementada precisa de
indicação de limite, não de um controle que sugira suporte completo.

## Linha de comando

A página Elementos visuais aplica orientação de legenda por enum (padrão,
horizontal ou vertical). A alteração de título usa o layout do próprio componente:
reserva espaço acima da área cartesiana, sem margem calculada no formulário.
Para reproduzir o caso corrigido, use a
[fixture arquivada](../evidence/title-spacing-2026-09-22/fixture.json)
com `--case all`. As capturas desse ensaio estão no mesmo diretório de evidências.

O modo automatizado é ativado por `--out`. O OnShow agenda a execução após a janela
ser criada. Diretório de saída deve ser novo para preservar evidência.

| Argumento | Significado |
| --- | --- |
| `--fixtures caminho` | JSON compartilhado com a bancada |
| `--case all` ou ID | Todos os casos ou caso específico; ID desconhecido falha |
| `--out diretório` | Capturar, produzir resultado e encerrar |
| `--width`, `--height` | Dimensões físicas, mínimo local 80 |
| `--dpi` | DPI sintético; não muda awareness real do processo |
| `--stress` | Seis séries para carga; DPI default 144 nesse modo |
| `--points` | Pontos totais da carga, default 996, mínimo 6 |
| `--frames` | Iterações de captura solicitadas, default 120, mínimo 1 |
| `--animate` | Atualizações periódicas durante a carga |
| `--screen` | Tentar também recorte físico de desktop |

Exemplos a partir da pasta do EXE compilado:

```powershell
& '.\DACChartsDemo.exe' --fixtures '.\reference-cases.json' --out '.\ensaio-c01' --case C01 | Out-Null
& '.\DACChartsDemo.exe' --out '.\ensaio-estatico' --case all --stress --points 996 --frames 120 --dpi 144 | Out-Null
& '.\DACChartsDemo.exe' --out '.\ensaio-animado' --case V11 --stress --animate --frames 120 --screen | Out-Null
if ($LASTEXITCODE -ne 0) { throw 'Demo falhou; consultar error.txt.' }
```

O pipeline `Out-Null` faz PowerShell aguardar o EXE GUI. Não interpretar retorno
imediato do shell como fim da captura. `result.txt` registra sucesso; `error.txt`
e exit code 1 registram erro. Wrappers DPR tratam falhas automatizadas sem depender
de fechar um diálogo modal de erro.

Busca padrão das fixtures: cópia ao lado do EXE e, depois, procura limitada em
diretórios ancestrais por `Tests/Charts.Visual/fixtures.json`. Para reprodução
controlada sempre passe o caminho explicitamente e registre seu hash.

## Conteúdo dos artefatos

- Por cenário: PNG do buffer, PNG do DC da janela e JSON de geometria/textos/opções.
- Referência: PNG Canvas, layouts/ticks/textos/opções resolvidas e manifest de versão.
- Comparação: overlay 50%, mapa vermelho de diferenças e `comparison.json`.
- Carga: opção utilizada, geometria final, métricas, PNGs sequenciais e `frames.jsonl`.
- Execução: logs de compilação, testes, resultado/erro e dados do ambiente.

No benchmark, a divisão dos pontos entre seis séries usa `(points+5-serieIndex) div 6`.
O ensaio 996 produz 166 por série. A carga usa coordenadas numéricas e valores
variáveis; `--animate` altera valores a cada 15 iterações e espera finalização por
tempo mínimo e estado da animação. Quantidade de iterações, Paints e quadros
capturados não precisa ser idêntica.

## Bancada completa

Pré-requisitos: Delphi Win32 com Skia4Delphi/Skia DLL local, .NET Framework MSBuild,
Node com ECharts e Playwright nas versões fixadas, Chromium correspondente,
Python com Pillow e numpy. O Node pode resolver módulos via NODE_PATH já configurado
na máquina; não presumir que qualquer instalação global tenha a versão correta.

`Tests/Charts.Visual/package.json` fixa ECharts 6.1.0 e Playwright 1.62.1. Fixtures
fixam Chromium 151.0.7922.34 e o SHA-256 do bundle ECharts. A falta de lockfile
completo é uma pendência de reprodução da árvore de dependências.

```powershell
.\Tests\Charts.Visual\run.ps1 -Output 'tmp\charts-nova-execucao' `
  -EChartsScript 'C:\dependencias\echarts\dist\echarts.min.js' `
  -Python 'C:\dependencias\python\python.exe' `
  -Node 'C:\dependencias\node\node.exe' `
  -Delphi 'C:\Program Files (x86)\Embarcadero\Studio\19.0'
```

Os caminhos de dependências acima são exemplos e precisam apontar para instalações
reais. O runner carrega `rsvars.bat` e usa
`C:\Windows\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe` com Build/Debug/Win32.
Define `DCC_DcuOutput` e `DCC_ExeOutput` em subpastas isoladas. Não compilar essa
bancada por cima dos DCUs usados pelo IDE ou por outros componentes.

Ordem: build testes/demo → asserts Delphi → referência Chromium → demo automático
→ comparação → análise de quadros. `run.ps1` recusa saída que já contenha
`demo-captures`. No estado documentado, V15 faz a comparação reprovar; o relatório
deve continuar visível mesmo quando o processo retorna erro.

## Executar etapas isoladas

```powershell
node .\Tests\Charts.Visual\capture-reference.cjs `
  .\Tests\Charts.Visual\fixtures.json C:\dependencias\echarts\dist\echarts.min.js .\tmp\referencia-nova
python .\Tests\Charts.Visual\compare.py .\tmp\referencia-nova .\tmp\dac-novo
python .\Tests\Charts.Visual\analyze-frames.py .\tmp\dac-novo\frames
```

A captura de referência cria uma página local em memória e injeta o bundle local;
usa Canvas, DPR 1, viewport 720×420, locale en-US, timezone UTC e Arial. Aguarda
fontes e requestAnimationFrame. As fixtures estáticas desligam animação. Esse
runner não é um capturador completo de transições ECharts.

O extrator usa APIs internas do ECharts/zrender para pontos/layout/display list.
Ao atualizar a versão, revalidar essas APIs, textos invisíveis, clip paths e
semântica do `getOption`; não basta mudar o número e aceitar um hash novo.

## Troubleshooting baseado em ocorrências

| Sintoma | Investigar |
| --- | --- |
| Tempos NaN | Inicialização de TStopwatch/frequência em Tokyo |
| Carga rápida demais e poucos pontos | Conversão decimal dependente de locale; conferir dataCount/visibleMarks |
| DLL ausente/arquitetura errada | sk4d.dll Win32 ao lado do EXE e dependência usada no build |
| DataSource sem adapter | Unit de registro incluída e Supports correto |
| JSON aceita algo sem efeito | Whitelist vs caminho efetivamente consumido no engine |
| PNG da janela igual ao buffer | Isso não comprova ausência de flicker no desktop |
| `screenFrames=0` | Foreground, minimização/oclusão e elegibilidade da captura |
| Build de suíte ampla falha em DataGrid | Separar dependência preexistente do chart; registrar projeto/erro exatos |
| V15 falha | Divergência conhecida de substring truncada; não atualizar baseline automaticamente |

Os números de benchmark anteriores à correção de `TJSONNumber.AsDouble` foram
descartados: o parsing com locale inadequado podia eliminar a maior parte da carga.
Todo novo ensaio deve comprovar a cardinalidade efetivamente desenhada antes de
comparar tempos.
