# Ações por célula — evidências de 20/10/2026

Implementação na biblioteca DAC e integração nas três grids do movimento
bancário na branch `feature/movimentobancario-api`. Alterações preexistentes
foram preservadas; não houve commit nem alteração de configuração de projeto/IDE.

## Resultado automatizado

- `ApiTestes`: Rebuild Debug/Win32 e suíte completa com **195 aprovados**, zero
  falhas, erros e vazamentos reportados pelo executor.
- Casos novos: 19 da fixture `TMovimentoBancarioAcoesGridTests` e dois da fixture
  `TMovimentoBancarioMVCTests`, que comprovam disponibilidade/registro de intenção
  e ausência de consulta ao DAO.
- MaxxADM: Rebuild Debug/Win32 concluído. Executáveis atualizados em
  `EXE/ApiTestes.exe` e `EXE/MaxxRural.exe`.
- Pacotes `DACSkiaComponentsRuntime`, `DACSkiaComponentsDesign` e combinado
  `DACSkiaComponents`: Rebuild Win32 concluído em saídas isoladas da biblioteca.
- Verificadores da skill e auditoria estática passaram: 32 pares de hooks e 15
  famílias. Os sete avisos de TODO preexistentes são externos ao recurso.
- Warnings legados de compilação permanecem nos logs; nenhuma nova configuração
  persistente de build foi introduzida.

## Arquivos de evidência

| Arquivo | Conteúdo |
| --- | --- |
| `build.log` | Rebuild final do ApiTestes oficial. |
| `build-desktop.log` | Rebuild final do MaxxADM. |
| `apitestes-todos.log`, `apitestes-todos.xml` | Execução final da suíte completa. |
| `build-runtime.log`, `build-design.log`, `build-package.log` | Rebuilds dos pacotes DAC. |
| `static-audit.json` | Auditoria estrutural da biblioteca. |
| `verification.json` | Contagem do XML, lista de arquivos e hashes dos executáveis/capturas. |
| `dbgrid-actions-1.png`, `dbgrid-actions-2.png` | Capturas nativas: escuro e claro, com foco, hover, botões desabilitados e linhas normais. |
| `dbgrid-actions-pressed-1.png`, `dbgrid-actions-pressed-2.png` | Capturas do estado pressionado, escuro e claro. |

As capturas foram produzidas por `PaintTo` do controle VCL real, sem simular o
layout em HTML ou criar botões por registro. O contraste da lixeira e a mudança
da superfície pressionada também têm asserts sobre os pixels renderizados.

## Reprodução

Na raiz do consumidor:

```powershell
cmd /c MaxxRural\src\Tests\Resultados\20261020-grid-acoes\compilar.cmd
powershell -NoProfile -File MaxxRural\src\Tests\Resultados\20261020-grid-acoes\executar-testes.ps1
cmd /c MaxxRural\src\Tests\Resultados\20261020-grid-acoes\compilar-desktop.cmd
```

O script de execução fornece `MOVIMENTACAO_BANCARIA_TEST_DB` com um nome novo e
restaura a variável ao terminar. Os fixtures existentes criam arquivos Firebird
isolados no diretório das evidências. Uma primeira execução sem essa variável
identificou a pré-condição; o resultado final acima usa o ambiente correto.

Os builds dos pacotes usam o `.dproj` existente da biblioteca com `/t:Rebuild`.
Para os DPKs runtime/design sem `.dproj` próprio, `MainSource` e o nome do pacote
são informados somente na linha de comando. Seus scripts estão em
`M:/Delphi Componentes/DAC-DelphiComponents/tmp/dbgrid-actions-20261020/`.

## Limites e homologação visual

Os testes enviam mensagens de mouse para o controle real e percorrem os métodos
de teclado, incluindo os códigos de diálogo da VCL. Carregam/gravam/releem os
blocos reais das três grids do DFM, isolando a referência externa a DataSource
e resolvendo os nomes dos eventos com handlers compatíveis de teste.

Isso não representa a abertura do formulário completo nem homologação manual.
Permanecem para homologação: formulário real com dados carregados, interação pelo
teclado físico/mouse, Object Inspector com o BPL instalado, layouts antigos do
usuário, múltiplos monitores e DPI físico diferente. Os PNGs claro/escuro foram
inspecionados e não substituem essa etapa.

Não foram implementadas consulta de detalhes, edição, exclusão ou permissão de
operação financeira. A ativação apenas encaminha a intenção View → Controller →
Service e apresenta uma mensagem; os testes verificam que esse caminho não
acessa o DAO.
