# TDACTreeView

Árvore VCL sem dataset, com criação manual de itens ou carga de uma
`TObjectList<T>` de classes do consumidor. Mantém as colunas, busca visual,
expansão, seleção, hints, checkbox opcional e interação do padrão DAC.

O componente não depende de `Data.DB`, não acessa rede e não persiste objetos.
A pintura e os algoritmos de hierarquia/projeção são compartilhados com o
DBTreeView por contratos neutros; campos, DataLink e bookmarks permanecem
exclusivamente no componente data-aware.

## Uso na galeria oficial

Abra `demo/Demo.dproj` e selecione **TreeView**. O exemplo inicia no modo de
objetos do consumidor. **Criar itens manuais** demonstra `Add` e `AddChild`;
**Carregar objetos** volta ao catálogo plano, com filhos deliberadamente
fornecidos antes dos pais.

O formulário compartilhado está em `demo-treeview/TreeView.Demo.Main.pas` e seu
DFM. Seus objetos pertencem ao formulário, que limpa os itens antes de liberá-los.
Não há regras financeiras no componente nem no exemplo.

Também há um executável independente em `demo-treeview/DACTreeViewDemo.dproj`,
com o mesmo formulário. O script gera `Build/TreeView/PlainDemo/DACTreeViewDemo.exe`.
Seu manifest define consciência de DPI somente nesse processo; o componente
não modifica a política de DPI da aplicação hospedeira.

## Criação manual no estilo VCL

```delphi
Tree.BeginUpdate;
try
  Tree.Items.Clear;
  Root := Tree.Items.Add(nil, 'Equipamentos');
  Root.Checkable := False;
  Root.SubItems.Add('Grupo principal');

  Child := Tree.Items.AddChild(Root, 'Teclados');
  Child.SubItems.Add('Primeiro filho');

  Sibling := Tree.Items.Add(Child, 'Monitores');
  Sibling.SubItems.Add('Irmao de Teclados, com o mesmo pai');
finally
  Tree.EndUpdate;
end;
Tree.ExpandAll;
```

`Add(nil, Texto)` cria uma raiz. `Add(Item, Texto)` cria um **irmão** do item
informado; `AddChild(Pai, Texto)` cria um descendente. Os itens recebem chave
automática estável enquanto existirem. `Items.Delete(Item)` remove a subárvore;
`Items.Clear` remove todos os itens internos. Nenhuma dessas operações libera
o `DataObject` associado.

Cada item oferece chave/pai, `Text`, `SubItems`, `Checked`, `Checkable`,
`Expanded` e a referência runtime `DataObject: TObject`. A primeira coluna
apresenta `Text`; as demais usam `SubItems` na mesma ordem.

Os tipos são próprios DAC. O estilo das chamadas acompanha a VCL, mas não há
compatibilidade direta com variáveis `TTreeNode` ou `TTreeNodes`.

## Carga de TObjectList de uma classe do consumidor

O método é genérico no próprio controle, compatível com Delphi 10.2:

```delphi
Tree.LoadObjects<TCatalogEntry>(Entries,
  function(Entry: TCatalogEntry): TDACTreeItemData
  begin
    Result := TDACTreeItemData.Create(Entry.Id, Entry.ParentId,
      Entry.Description, Entry.Selectable);
    Result.SubItems := TArray<string>.Create(Entry.Detail);
    Result.Checked := Entry.Selected;
  end);
```

O mapper fornece `Key`, `ParentKey`, `Text`, `SubItems`, `Checked` e
`Checkable`. A carga associa automaticamente cada item ao objeto original em
`DataObject`. O mapper apenas lê dados; não deve liberar objetos ou modificar
a lista durante a enumeração.

A lista é plana: a hierarquia usa chave e pai, e não o prefixo do texto nem a
posição do objeto na lista. Filhos podem vir antes dos pais. A ordem dos irmãos
segue a ordem de entrada. Chaves textuais preservam conteúdo e zeros à esquerda;
chaves inteiras não se confundem com texto de aparência numérica.

Nulo e texto vazio são raízes por padrão. Outras sentinelas, como o inteiro
zero, devem ser configuradas explicitamente em `RootValues` ou convertidas pelo
mapper para nulo. A comparação respeita os tipos das chaves.

Duplicatas, pais ausentes, autorreferências, ciclos e falhas do mapper rejeitam
a carga inteira. O retorno é `False`, a apresentação é esvaziada e o erro fica
disponível em `LastError`/`OnDataError`. Não há publicação de uma árvore parcial
nem escolha arbitrária de pai.

### Atualização e preservação de estado

`LoadObjects` substitui o catálogo completo. `PreserveState=True`, padrão,
mantém seleção, expansão e marcação das chaves que continuam presentes; itens
novos usam os estados mapeados. Os objetos associados são os objetos da **nova**
carga, mesmo quando as chaves coincidem com a carga anterior.

Com `PreserveState=False`, aplicam-se os estados fornecidos pelo mapper. Uma
chave removida deixa de participar da seleção e das chaves marcadas.

Não existe observação automática da lista ou das propriedades dos objetos.
Depois de alterar os objetos, chame novamente `LoadObjects`. `Refresh` atualiza
a representação dos itens internos; não executa o mapper novamente sobre uma
lista externa.

## Propriedade e vida dos objetos

O TreeView é dono dos itens e caches internos. A lista e os objetos externos
continuam pertencendo ao consumidor. O controle não altera `OwnsObjects` e não
libera objetos na substituição, exclusão ou destruição dos itens.

Os objetos associados devem permanecer vivos enquanto houver itens que os
referenciem. Antes de liberar uma lista com `OwnsObjects=True`, remova esses
itens ou limpe a árvore:

```delphi
Tree.Items.Clear;
Entries.Free;
```

Liberar somente o contêiner de uma lista com `OwnsObjects=False` não libera
seus objetos. Ainda assim, os objetos precisam continuar vivos até a remoção
das referências na árvore. `TObject` não oferece notificação universal de
destruição; o controle não pode detectar um objeto já liberado pelo consumidor.

Mantenha os objetos vivos até a conclusão da operação e de todos os seus eventos.
Por exemplo, libere a lista depois que `Items.Clear` retornar, não no meio de
um callback disparado pela limpeza.

`SelectedObject` e os objetos recebidos nos eventos são referências externas,
sem transferência de propriedade. Não guarde ponteiros para itens internos
entre limpezas ou novas cargas: use a chave estável e o objeto do catálogo atual.

## Checkbox e eventos

`ShowCheckBoxes` é opcional e vem desabilitado. Quando habilitado, apenas itens
com `Checkable=True` oferecem marcação. `ReadOnly` bloqueia marcação e mantém
navegação, busca e expansão.

`OnBeforeCheckChange` recebe chave, objeto e estado solicitado, com veto por
`Allow`. `OnCheckChanged` recebe o estado efetivo e a origem da mudança. A
alteração do objeto original pertence ao consumidor:

```delphi
procedure TMyForm.TreeCheckChanged(Sender: TObject; const Key: Variant;
  DataObject: TObject; Checked: Boolean; Reason: TDACTreeChangeReason);
begin
  if (Reason in [tcrUser, tcrProgrammatic]) and
    (DataObject is TCatalogEntry) then
    TCatalogEntry(DataObject).Selected := Checked;
end;
```

O veto vale para pedidos via interface ou `TrySetChecked`. A atribuição direta
a `Item.Checked` é uma configuração feita pelo consumidor: atualiza o estado e
notifica a mudança, sem passar pelo evento de pedido.

Não há propagação automática de marcação para filhos ou pais. Os eventos de
linha atual e ativação também disponibilizam a identidade estável e o objeto
associado. Itens manuais podem ter `DataObject=nil`.

## Busca, desenho e DFM

`ShowHeader: Boolean` controla os titulos de colunas por instancia, com padrao
`True`. Para apresentar apenas as linhas, use `Tree.ShowHeader := False`.
O valor `False` persiste no DFM; `True` pode ser omitido. Ocultar o cabecalho
remove tambem o espaco reservado, o fundo, os titulos e seu divisor inferior.
As colunas, indentacao e rolagem horizontal continuam funcionando.

A alternancia em runtime recalcula somente geometria, limites de rolagem e
visibilidade da linha atual. Selecao, marcacoes, expansao e busca permanecem;
os itens nao sao recarregados. `TitleHint` vale apenas com cabecalho visivel;
hints de celulas continuam disponiveis. O exemplo da galeria permite alternar
a propriedade no checkbox **Exibir titulos**.

A busca é visual: preserva resultados e ancestrais, expande temporariamente os
caminhos e conserva marcações e seleção fora do filtro. Limpar a busca restaura
a expansão manual. A linha atual, foco, hover e marcação são estados distintos.

O expansor não marca o item. Setas navegam; esquerda/direita recolhem/expandem;
espaço solicita marcação; Enter ativa uma vez. Tab e Shift+Tab saem normalmente
para os controles vizinhos. Textos longos oferecem hints e clipping por coluna.

Skia desenha superfícies, ícones e estados; texto Windows usa o mesmo buffer.
O painter apresenta somente o viewport, sem criar controles individuais para
os nós. Tokens, fonte e geometria seguem tema e DPI da biblioteca.

Itens, colunas, raízes e propriedades de configuração são publicados e suportam
DFM. Referências de objetos externos não são serializadas. A paleta permanece
**DAC Skia**, com registro runtime e design-time nos pacotes oficiais.

## Compilação e evidências

Use `tools/test-treeview.ps1` para compilar e executar a bateria do novo
componente, as regressões do DBTreeView e os alvos oficiais previstos pelo
script. As saídas ficam sob `Build/TreeView`; os fontes instalados de Skia e as
configurações do Windows/IDE não precisam ser alterados.

O parâmetro `-Physical` acrescenta o teste de interface com `SendInput` na
janela criada pelo próprio executável de teste. Ele verifica o primeiro plano
antes de enviar entradas e requer uma sessão interativa que permita injeção de
entrada; caso contrário, falha explicitamente, sem substituir por mensagens
simuladas. O teste padrão permanece automatizado/offscreen.

Os resultados executados devem distinguir testes automatizados, renderização
offscreen em 96/144/192 DPI lógico, interação física e instalação manual na IDE.
Uma imagem offscreen não comprova teclado físico nem DPI real de monitor.

Veja [a validação executada](validation.md) para números, comandos e limites.

O ajuste de cabecalho possui [relatorio proprio](showheader-validation.md),
com os resultados de ambas as classes de arvore.
