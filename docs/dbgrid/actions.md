# Ações por célula na TDACDBGrid

Cada `TDACDBGridColumn` possui uma coleção `Actions`, disponível no Object
Inspector e por código. Ela funciona em colunas sem `FieldName`, identificadas
por `LayoutKey`, e também pode substituir a apresentação de uma coluna vinculada.
Uma coleção vazia preserva a pintura anterior de campos e badges e a leitura de
DFMs existentes.

```pascal
Grid.ActionKeyFields := 'COD_EMP;MOV_COD';
Column.LayoutKey := 'OPCOES';
Column.Sortable := False;
Column.MinWidth := 176;
Column.Width := 196;
with Column.Actions.Add do
begin
  ActionId := 'detalhes';
  Caption := 'Detalhes';
  Hint := 'Detalhes do registro';
  Width := 80;
end;
with Column.Actions.Add do
begin
  ActionId := 'editar';
  IconKind := mikEdit;
  Hint := 'Editar registro';
end;
with Column.Actions.Add do
begin
  ActionId := 'excluir';
  IconKind := mikTrash;
  Hint := 'Excluir registro';
  Appearance := daaDanger;
end;
```

Os identificadores acima são configuração da aplicação. O componente não conhece
campos obrigatórios, empresas, permissões, serviços ou operações financeiras.

| Propriedade da ação | Contrato |
| --- | --- |
| `ActionId` | Identificador estável, não vazio e único na coluna, sem distinguir maiúsculas. Ao adicionar, recebe um GUID; pode ser substituído por uma chave legível. |
| `Caption` | Texto do botão. Vazio permite botão somente com ícone. |
| `IconKind` | Ícone do catálogo existente `TDACIconKind`; padrão `mikNone`. |
| `Hint` | Dica individual, com área de permanência correspondente ao botão. Use `Grid.ShowHint=True`. |
| `Width` | Largura em pixels lógicos a 96 PPI; padrão 32, mínimo 16. |
| `Visible`, `Enabled` | Ambos inicialmente verdadeiros. Funcionam como limites para o evento por registro. |
| `Appearance` | `daaDefault` ou `daaDanger`. Cores vêm dos tokens do tema. |

## Eventos e contexto

Os tipos de evento são declarados na unit da grid:

```pascal
procedure EstadoAcao(Sender: TObject; AColumn: TDACDBGridColumn;
  AAction: TDACDBGridAction; const AContext: TDACDBGridActionContext;
  var AVisible, AEnabled: Boolean);

procedure ExecutarAcao(Sender: TObject; AColumn: TDACDBGridColumn;
  AAction: TDACDBGridAction; const AContext: TDACDBGridActionContext);
```

Atribua a `OnActionState` e `OnActionExecute`, respectivamente.

`OnActionState` recebe os valores padrão da ação e pode restringir sua exibição
ou habilitação. Uma ação com `Visible=False` ou `Enabled=False` na coleção não
pode ser reativada pelo evento. O callback é síncrono e pode ocorrer várias vezes
durante pintura, hit test, dicas e teclado. Deve apenas consultar o contexto e
estado de apresentação já disponível: sem navegar/editar o dataset, alterar a
coleção, consultar rede ou abrir diálogos. Navegação detectada durante o callback
é rejeitada. Após mudar um estado externo, chame `Grid.Redraw`.

`AContext` contém cópias de valores:

- `ColumnKey` e `ActionId` identificam a coluna e a ação;
- `Values` contém nome/valor dos campos do registro visível;
- `ValueOf('CAMPO')` devolve o valor ou `Null` se ausente;
- `Keys` contém os campos declarados em `ActionKeyFields`, separados por `;`
  ou `,`, na ordem configurada;
- `HasCompleteKey` exige uma chave configurada, com todos os campos presentes
  e não nulos. Regras para strings vazias pertencem à aplicação.

O contexto não contém `RecNo`, bookmark, `TField`, dataset nem ponteiro para buffer
de registro. Valores podem ser copiados para um comando da aplicação, inclusive
com chave composta. `AAction` e `AColumn` pertencem à grid e só devem ser usados
durante a chamada; não retenha essas referências para execução posterior.

Ao clicar, a grid seleciona o registro pelo mecanismo nativo, revalida o hit test
e o estado ao soltar e emite um único `OnActionExecute`, com o contexto atual.
O clique de ação é consumido: não emite também `OnCellClick`, `OnClick` ou
`OnDblClick`. O segundo clique de um duplo clique sobre o botão não o reativa.
Cabeçalhos, linhas inexistentes, carregamento, designer e grid desabilitada não
ativam ações. Teclado e mouse usam a mesma consulta de estado.

## Layout, estados e teclado

Os botões são desenhados em Skia na superfície existente; textos entram na mesma
fila `TDACDBGridTextItem` e no renderer nativo Windows/VCL usado pelas células.
Não existem controles ou janelas por botão/registro. O painter e o cache de
ícones são únicos por grid.

Larguras, ícones, espaçamento, altura e raio são escalados a partir de 96 PPI.
O botão cabe na altura da linha e respeita os limites da célula. Ações invisíveis
não ocupam espaço; ações que não cabem integralmente na largura disponível,
assim como as seguintes, não são desenhadas nem ativadas. Redimensionar a coluna
não reduz a fonte para simular que o conteúdo cabe.

Há apresentação normal, hover, pressionada, desabilitada e foco. A aparência
destrutiva usa contorno/ícone semântico e preenchimento de perigo no hover ou
pressionamento. O texto/ícone sobre esse preenchimento usa `ButtonDangerText`.

- F2 entra nas ações da coluna selecionada ou da primeira coluna elegível,
  trazendo a coluna para o viewport quando necessário.
- Esquerda/direita e Tab/Shift+Tab percorrem as ações habilitadas que cabem,
  circulando na coluna atual.
- Enter ou Espaço ativa uma vez por pressionamento; repetição de tecla é ignorada.
- Esc sai desse modo. As demais teclas retornam à navegação nativa da grid.
- Fora do modo de ações, Espaço mantém seu comportamento de seleção existente.

O modo de ações solicita as teclas de diálogo à VCL, evitando que Enter também
ative o botão padrão do formulário. Rolagem, mudança/alteração de registro,
redimensionamento, perda de captura/foco e recriação do handle cancelam um clique
armado. Soltar fora do botão ou arrastar para outro botão também cancela.

`ActionRect(ColumnIndex, VisibleRowIndex, ActionIndex)` informa a geometria usada
na pintura e na interação. A primeira linha do viewport tem índice zero; uma
ação oculta, sem registro ou que não cabe retorna `TRect.Empty`. É uma coordenada
efêmera da apresentação, sem valor como identidade de registro.

## Ownership e persistência

A coluna cria, possui e libera `TDACDBGridActions`; a coleção possui os itens.
`Column.Actions := OutraColecao` e `Column.Assign` copiam a configuração, sem
transferir propriedade. O DFM preserva identificadores, texto, ícones, dicas,
larguras e estados; os eventos e `ActionKeyFields` pertencem à grid.

O JSON de layout mantém o contrato anterior: ordem, largura, visibilidade de
colunas e ordenação. Não grava ações, regras por registro nem permissões. Carregar
um layout não substitui as definições das ações no DFM/código. Layouts antigos
que deixem a coluna estreita continuam legíveis; o usuário pode alargá-la ou
restaurar o layout para tornar os três botões visíveis.
Defina `Column.MinWidth` quando a aplicação precisar garantir a largura mínima
do conjunto também ao restaurar layouts antigos. O Movimento Bancário usa 176
pixels lógicos para esse mínimo. Veja [colunas e ordenação](columns.md).

Na destruição, callbacks da grid são desassociados, listeners existentes são
removidos e painter/cache são liberados. Estado de interação guarda somente
identificadores/índices/revisão, sem reter registros ou componentes externos.
O `TDataSource` continua sob o mecanismo nativo de notificação da VCL.

## Validação desta entrega

Os testes de integração estão no projeto oficial `ApiTestes` do MaxxRural, em
`Teste.MovimentoBancario.AcoesGrid.pas`, com suporte em
`TestSupport.DACDBGridActions.pas`. Incluem mensagens reais de mouse, rolagem e
ordenação, seleção de linha não atual, chaves compostas, estado por registro,
revalidação ao soltar, teclado, cancelamento, recriação de handle, destruição de
DataSource, `Assign`, identificadores, persistência e quantidade de controles de
80 para 1000 registros. A cobertura também inclui rolagem horizontal com
seleção por linha, clique em outra linha nesse viewport e uso do indicador de
seleção junto da navegação por célula.

Os três blocos reais de grid do DFM do movimento bancário são convertidos para
binário, carregados, gravados e relidos em execução. A referência externa ao
DataSource é removida apenas desse fixture isolado e os nomes de eventos são
resolvidos por handlers compatíveis do suporte de teste. Isso valida streaming
das propriedades/coleções/eventos; não equivale à abertura do formulário completo.

Os testes produzem PNGs nativos nos temas claro e escuro e verificam contraste do
ícone de lixeira e mudança de superfície no pressionamento. A revisão dessas
capturas foi separada da homologação visual no MaxxRural. DPI físico diferente
do ambiente de execução e interação manual no formulário completo permanecem
para homologação.
