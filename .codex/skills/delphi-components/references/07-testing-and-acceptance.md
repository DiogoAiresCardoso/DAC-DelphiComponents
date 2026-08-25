# Testes e aceitação

## Níveis

1. testes puros de tokens/DPI;
2. testes de componentes/registro;
3. smoke test VCL;
4. QA visual e interação.

## Tokens/DPI

- tokens/tema Ancoragem retornam cores esperadas;
- métricas são positivas;
- `MaxScale(36, 144)=54`;
- zero/PPIs inválidos usam 96.

## Hooks

- registro idempotente;
- unregister idempotente;
- nenhum registro em classes VCL globais;
- quantidade de register/unregister pareada;
- foco/disabled/hover invalidam controle.

## Inputs

- texto, seleção, clipboard, undo/redo;
- password preserva caret ao alternar visibilidade;
- masked respeita máscara;
- search dispara evento;
- memo scroll/seleção.

## Seletores/controles

- combo navega por teclado;
- date/time preservam valor;
- spin clampa min/max;
- Space alterna check/radio/toggle;
- slider responde a setas e mouse.

## Grid

- header, zebra, hover e seleção;
- dataset vazio;
- scroll com muitas linhas sem criação por célula;
- status e ações não quebram hit test.

## Feedback

- toast fecha;
- modal confirma/cancela e trata Escape;
- paginação nunca sai de 1..PageCount;
- spinner para timer quando inativo/destruído.

## Charts/report

- dataset vazio, um ponto e valores iguais;
- donut com total zero;
- report sem itens;
- zoom/page clamped.

## QA visual

Testar 96/120/144/192 PPI, teclado, high contrast quando aplicável, resize e rolagem. O fundo e as superfícies seguem o tema/tokens da Ancoragem. Não deve existir área reservada para famílias removidas.

## Critério de honestidade

Sem `dcc32`, `dcc64` ou MSBuild/RAD Studio disponível, reporte “validação estática executada; compilação Delphi não executada”. Não transforme parser Python em prova de compilação.
