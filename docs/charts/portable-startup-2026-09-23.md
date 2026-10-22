# Inicialização portátil do demo — 23/09/2026

[Manual](README.md) · [Operação](manual/07-demo-operacao.md)

## Problema e diagnóstico

Foi relatada access violation e janela em branco ao copiar o EXE, `sk4d.dll` e
`reference-cases.json` para fora do workspace. O nome correto da DLL foi confirmado.
Com os três arquivos da compilação local, o gráfico foi gerado fora do workspace;
a falha exata da máquina de destino não foi reproduzida com esses arquivos.

O diagnóstico identificou dois defeitos concretos. O demo anterior carregava
`midas.dll` de `C:\Program Files (x86)\Embarcadero\Studio\19.0\bin` para seu
TClientDataSet, embora essa dependência não estivesse na distribuição documentada.
Além disso, a VCL consumia erros de `OnCreate` por `HandleCreateException`, deixando
o formulário parcialmente inicializado. O leitor de fixtures usava `cases` e
`option` sem verificar tipos/presença, permitindo access violation para JSON inválido.

## Correções

- `MidasLib` vinculado estaticamente ao demo: dataset local sem MIDAS externo.
- `DACChartsDemo.Startup` primeiro nos três DPRs: carrega `sk4d.dll` pelo caminho
  absoluto junto ao EXE antes da inicialização das classes Skia, verifica carga e
  exports essenciais e mantém a referência até o encerramento. Isso não prova
  compatibilidade ABI completa de qualquer DLL; distribua a DLL do mesmo build.
- `reference-cases.json` é resolvido junto ao EXE, independentemente do diretório
  de trabalho. `--fixtures` permite outro arquivo explícito. A busca por pastas
  ancestrais/workspace foi removida para não mascarar uma distribuição incompleta.
- Documento de fixtures validado antes da galeria: objeto raiz, array não vazio,
  id/título/opções tipados, IDs únicos e válidos como nomes de arquivos, schema das
  opções. Não usar a configuração isolada de um gráfico como arquivo de cenários.
- Erro de criação é propagado ao ponto de entrada compartilhado. Exceções não
  tratadas no loop do demo são registradas uma vez e encerram a aplicação; não
  manter a janela vazia como se a inicialização tivesse terminado.

Em uso normal, o erro gera mensagem e diagnóstico em
`%TEMP%\DACChartsDemo-startup-error.txt`. Com `--out`, gera `error.txt` na pasta de
saída e código 1, sem diálogo bloqueante. Problemas ao salvar o log não substituem
a mensagem original. Esses handlers são do demo, não da API do componente.

## Verificação

Os três projetos do demo compilaram em Win32 Debug com saídas isoladas. O perfil
principal foi executado em `%TEMP%`, fora do workspace, com diretório de trabalho
diferente do EXE e PATH contendo somente diretórios Windows.

O teste [test-portable-demo.ps1](../../Tests/Charts.Visual/test-portable-demo.ps1)
passou em dez condições: arquivos válidos; DLL ausente; DLL inválida; fixtures
ausentes; JSON malformado; cases ausente; cases com tipo errado; array vazio; option
ausente; opção com enum inválido. O caso válido produziu PNG/JSON dos 29 cenários.
As 29 imagens são idênticas em pixels RGB à compilação do ajuste de título.

Uma inicialização normal adicional, oculta para inspeção, confirmou `sk4d.dll` da
pasta distribuída e nenhuma `midas.dll` carregada. O processo desse ensaio foi
encerrado pelo teste após coletar os módulos. Não foi uma sessão de QA interativo.
A máquina de teste ainda tem Delphi instalado; ele não foi desinstalado para o
ensaio. Vínculo estático e inspeção de módulos comprovam a remoção dessa dependência.

O modo `--buffer-only` omite a captura de DC visível para permitir o teste oculto.
Não fornece evidência de flicker. O modo normal de captura de janela permanece.
Não foram reexecutados benchmark, comparação integral ECharts ou passagem física
entre monitores. As pendências visuais anteriores permanecem.

Builds/logs/resultados: `tmp/chart-portable-fix/`. Distribuição pronta:
`Build/Distribution/DACChartsDemo-portable-2026-09-23.zip`. O manifesto ao lado do
ZIP registra hashes dos três arquivos, pacote e fontes desta correção.
