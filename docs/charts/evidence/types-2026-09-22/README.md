# Evidências da API tipada — 22/09/2026

[Contrato e migração](../../manual/11-api-tipada.md) · [Manifesto](manifest.json)

Execução local em Windows, Delphi Tokyo 10.2, Win32 Debug. Builds com saídas
isoladas em `tmp/chart-types-work`. As referências ECharts 6.1.0 e imagens DAC
anteriores permanecem no [arquivo histórico](../2026-09-22/README.md).

| Verificação | Resultado |
| --- | --- |
| Compilação | Testes, package principal, demo principal e três perfis do demo de gráficos: sucesso |
| Testes tipados | 23 famílias de codecs, conjuntos, medidas, cores, gradientes, rejeição, rollback, Assign, RTTI e DFM: sucesso |
| Asserts existentes | C01–C14: sucesso; V01–V15 capturados para comparação |
| Demo exclusivo | Executado com `--case all`, resultado OK |
| Comparação geométrica | 29/29 casos passaram nos landmarks verificados |
| Conteúdo textual | 28/29; V15 mantém a divergência preexistente de truncamento |
| Regressão DAC anterior → atual | 29/29 imagens idênticas em pixels RGB |
| Fidelidade visual completa | Não aprovada; revisão por elemento continua necessária |
| Flicker físico | Não reensaiado; captura contínua independente continua inconclusiva |

Os builds podem emitir hints de variáveis não utilizadas; sucesso não significa
ausência de hints. Demo principal e perfis HighDPI/sem HighDPI foram compilados,
mas não executados nesta alteração. Não houve instalação no IDE para QA manual
do Object Inspector; os tipos publicados e streaming foram verificados por código.

## Artefatos

- `logs/`: seis logs de build, testes e resultado do demo.
- `commands/`: comandos de build utilizados, com caminhos locais do ambiente.
- `dac/`: novas imagens, geometria, overlays e mapas de diferenças dos 29 casos.
- [comparison.json](dac/comparison.json): resultado por cenário contra ECharts.
- [pixel-regression.json](pixel-regression.json): comparação com o DAC histórico.
- [manifest.json](manifest.json): hashes dos artefatos, fontes e executáveis gerados.

O comparador retorna código 1 devido ao V15. O relatório preserva esse resultado;
nenhuma baseline foi alterada para converter a divergência em aprovação. Imagens
de janela pontuais não constituem uma sequência temporal de prova de flicker.

## Reprodução

Na raiz do repositório, em ambiente com Delphi e Skia configurados:

```powershell
cmd /c tmp\chart-types-work\build-tests.cmd
.\tmp\chart-types-work\tests-exe\DACComponentsCharts.exe Tests/Charts.Visual/fixtures.json tmp/chart-types-work/captures-final
cmd /c tmp\chart-types-work\build-demo.cmd
.\tmp\chart-types-work\demo-exe\DACChartsDemo.exe --fixtures .\Tests\Charts.Visual\fixtures.json --out .\tmp\chart-types-work\demo-captures --case all
python Tests/Charts.Visual/compare.py docs/charts/evidence/2026-09-22/reference tmp/chart-types-work/demo-captures
```

Os scripts em `commands/` preservam as invocações exatas da execução e podem ser
usados no lugar dos scripts temporários. Ajuste os caminhos absolutos ao reproduzir
em outra máquina; não direcione DCUs/BPLs para as saídas do IDE.
