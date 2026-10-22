# TDACDBGrid — colunas, hover, ordenação e ações

Data: 20/10/2026. Componente em `M:\Delphi Componentes\DAC-DelphiComponents`;
consumidor em `M:\MaxxSoft\MaxxRural\Desktop\maxxrural`.

Foram lidas as instruções aplicáveis e as skills de componentes VCL e MaxxRural.
Não foram encontrados AGENTS.md nos caminhos aplicáveis. A implementação anterior
foi examinada antes das alterações e foram preservadas as alterações existentes.
Fontes Delphi mantêm Windows-1252/CRLF. Não houve commit, instalação de BPL na IDE
ou alteração de configuração persistida de projeto/IDE.

## Problemas encontrados e correções

Os problemas iniciais abaixo foram identificados na implementação; os testes
automatizados verificam o comportamento final, não uma execução retrospectiva
da versão anterior.

| Área | Problema | Correção e evidência final |
| --- | --- | --- |
| Hover | A pintura usava apenas a linha do mouse, destacando outras colunas. | Coordenadas de linha e coluna; comparação de pixels comprova que a coluna adjacente mantém sua cor. |
| Hover | Cursor/hover podiam sobreviver a scroll, ocultação, desabilitação e mudanças de estado sob o mesmo ponto. | Limpeza nos eventos de ciclo de vida e atualização do cursor mesmo sem mudar de célula; testes de mensagens, estado e cursor. |
| Repintura | O tracking nativo de células fixas invalidava até movimentos dentro do mesmo cabeçalho. | Tracking visual próprio, preservando os gestos nativos; contador de Paint não cresce ao repetir o mesmo ponto. |
| Seleção/foco | O hover não distinguia adequadamente célula selecionada e não havia contorno próprio para foco por célula. | Fundo de seleção preservado, contorno de hover e contorno de foco; testes de pixels e capturas nativas. |
| Dicas | Existia dica de ação, mas não uma política completa de dicas por coluna/cabeçalho. | `Hint`, `TitleHint` e dica automática de texto truncado; memo integral com quebras de linha. |
| Ordenação | As três grids não tinham `OnSortRequest`; o clique não ordenava seus buffers. | `GridOrdenar` configurado nos três DFMs, usando o adaptador opcional de índices tipados. |
| Ordenação | O ciclo incluía um terceiro estado sem ordenação; faltavam proteções próprias para arrastar/soltar. | Alternância crescente/decrescente; identidade estável no pressionar/soltar, cancelamento em arrasto, dimensionamento e duplo clique. |
| Ordenação/layout | O layout aceitava uma direção visual sem solicitar ordenação real; o campo associado não era registrado. | Restauração passa por `OnSortRequest`; aceitação exige chave/campo elegíveis. `sortFieldName` opcional preserva leitura de JSON antigo. |
| Persistência | Recarregar podia salvar o layout transitório antes da leitura; opções podiam redefinir o snapshot inicial. | Descarte do autosave pendente, reload sem perder o snapshot e Reset que preserva a ordenação inicial aceita. |
| Estrutura | Chaves removidas podiam interferir no posicionamento de colunas novas; faltava mínimo por coluna. | Restauração só conta chaves existentes e únicas; colunas novas ao final; `MinWidth` escalado. |
| Dataset | Indicador podia continuar ligado a campo/dataset anterior. | Limpeza ao fechar/substituir/destruir dataset, remover coluna ou alterar seu campo. |
| Escala | Pintores de célula/cabeçalho usavam medidas fixas enquanto outras partes escalavam. | Chrome e texto recebem a mesma escala da VCL; larguras persistem em unidades lógicas. |

Os testes do adaptador recém-introduzido também expuseram o limite de nomes de
índice do MIDAS e a perda de índices temporários no Close/Open. O adaptador limita
os nomes a 31 caracteres, reutiliza índices e cria um único datasource auxiliar
por buffer para limpar sua referência temporária ao fechar. Esse objeto pertence
ao dataset e não substitui os eventos/datasources da aplicação.

## Integração no Movimento Bancário

- As três grids usam `GridOrdenar`, `ActionKeyFields='COD_EMP;MOV_COD'` e o mesmo
  fluxo visual de ações anterior.
- `OPCOES`: largura 196, `MinWidth=176`, `Sortable=False`. O mínimo inclui margem
  para arredondamento em escalas fracionárias e foi testado com os três botões.
- `MOV_HISTCOMPL` é memo e tem `Sortable=False`.
- A ordenação é local, tipada e síncrona. A View continua encaminhando intenções
  de ação ao Controller; não foram implementadas consultas de detalhes, edição,
  exclusão nem novas operações financeiras/DAO.

## Testes automatizados efetivamente executados

Projeto oficial: `MaxxRural/src/Tests/ApiTestes.dproj`.
**231 testes aprovados, zero falhas, erros, ignorados ou vazamentos reportados
pelo executor.** São 34 casos novos de colunas, além dos 197 casos anteriores.
O resultado de vazamentos é o informado pelo DUnitX, não uma auditoria completa
de todos os recursos GDI ou memória do sistema.

Arquivos: `Teste.MovimentoBancario.ColunasGrid.pas`,
`Teste.MovimentoBancario.AcoesGrid.pas` e `TestSupport.DACDBGridActions.pas`.
Não foi criado projeto de teste avulso.

Cobertura executada:

- Inteiros 2/10/100, negativos, repetidos e nulos; datas em meses diferentes;
  FMTBCD de 20 dígitos/5 casas, inclusive valores grandes que diferem apenas na
  quinta casa; textos acentuados e códigos string com zeros à esquerda.
- Bookmark preserva o registro durante a ordenação; chaves compostas identificam
  ações após scroll e reorganização. Não há identidade persistente por RecNo.
- Um pedido por clique, crescente/decrescente/crescente; Opções/memo não pedem
  ordenação; recusa do handler não altera o estado aceito.
- Mouse com mensagens VCL/Windows: clique, arrasto nativo, redimensionamento,
  scroll, duplo clique, captura/foco/cancelamento e saída da grid.
- Teclado: navegação nativa, F2, setas/Tab, Enter/Espaço/Esc, repetição e
  Ctrl+Enter; `WM_GETDLGCODE` verificado com estado de Ctrl local à thread.
- Ações ocultas/desabilitadas não ativam; revalidação entre pressionar e soltar;
  limites da célula e viewport estreito; nenhum controle por registro. A regressão
  anterior compara a quantidade de controles com 80 e 1000 registros.
- Layout em arquivo: largura mínima, ocultação e UserHideable, reordenação,
  colunas novas/removidas, leitura antiga sem `sortFieldName`, campo alterado,
  autosave pendente, reset, ordenação inicial e larguras entre escalas.
- Dataset vazio, fechado, substituído, destruído e carregamento.
- Assign e streaming de configuração antiga sem novas propriedades. Os três
  blocos reais de grid do DFM foram lidos, gravados e relidos em execução e
  exercitados com buffers locais de teste e handlers compatíveis. A referência
  externa ao DataSource é removida só no fixture; o formulário completo não é
  instanciado por esse teste. Os testes anteriores também carregam os três
  blocos reais de dataset separadamente.
- Renderização nativa com temas claro/escuro, métricas de 96/120/144/192 PPI,
  largura normal e estreita, foco, seleção, hover e indicadores de direção.

`apitestes-todos.xml` e `apitestes-todos.log` contêm o resultado final.
`compilar.cmd` faz Rebuild com os diretórios do componente passados somente na
linha de comando. `executar-testes.ps1` cria um banco Firebird novo e isolado
para os fixtures preexistentes, sem usar a base operacional.

O projeto já existente `Tests/DACDBGridTests.dproj` do componente também foi
recompilado e executado: PASS para sort controller, seleção, serializer/store,
streaming DFM, ciclo de vida/pintura e persistência. Sua expectativa antiga de
terceiro clique sem ordenação foi atualizada para o ciclo crescente/decrescente.
A primeira tentativa fora do diretório da aplicação terminou com Runtime 217
por não encontrar a DLL Skia; a execução final passou com o diretório EXE no
PATH somente do processo, sem copiar ou instalar bibliotecas.

## Compilações

Rebuild Debug/Win32 por linha de comando, Delphi 10.2:

| Alvo | Resultado |
| --- | --- |
| ApiTestes oficial | Sucesso; suíte executada após o Rebuild. |
| MaxxADM / MaxxRural | Sucesso; `EXE/MaxxRural.exe`. |
| DACSkiaComponentsRuntime.dpk | Sucesso. |
| DACSkiaComponentsDesign.dpk | Sucesso. |
| DACSkiaComponents.dproj (pacote de compatibilidade) | Sucesso. |
| Tests/DACDBGridTests.dproj já existente | Sucesso; executado com PASS. |

Os pacotes runtime/design usam o dproj existente com MainSource e diretórios de
saída passados por propriedades do MSBuild. Nenhum dproj/dpk foi reconfigurado
para esta revisão. Os avisos legados de ACBr, RTTI, variáveis/inline e recurso
duplicado continuam visíveis nos logs; compilar com avisos não equivale a erro.
Executáveis do consumidor permanecem em
`M:\MaxxSoft\MaxxRural\Desktop\maxxrural\EXE`.

## Renderização revisada e homologação pendente

Os PNGs foram produzidos por `PaintTo` de uma TDACDBGrid real, com a camada Skia
e texto nativo. Foram inspecionadas capturas de temas claro/escuro, hover de
cabeçalho/célula/ação, foco, seleção e indicadores crescente/decrescente. Não são
mockups. Os dados sintéticos incluem deliberadamente valores longos/truncados.

As métricas de 96/120/144/192 PPI foram aplicadas por subclasse de teste e
ChangeScale. Isso valida geometria/renderização exercitadas pelo teste; não
comprova troca entre monitores físicos com escalas diferentes.

Continuam para homologação manual: formulário completo no MaxxRural com dados
operacionais, Object Inspector/designer, interação contínua para avaliar eventual
cintilação/percepção de desempenho e transição real entre monitores. Nenhuma
dessas verificações é declarada aprovada apenas pela compilação, leitura do
código ou captura isolada.

Documentação reutilizável: `docs/dbgrid/columns.md` e `docs/dbgrid/actions.md`
no repositório do componente. `source/README.md` registra a configuração atual
do consumidor.
