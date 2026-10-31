# TDACDBTreeView

Componente VCL data-aware para apresentar um catálogo local completo como árvore
com colunas, expansão, busca e marcação independente da linha atual. A hierarquia
é montada por chave/pai, sem interpretar o código exibido nem seu prefixo.

O runtime depende de RTL, VCL, Data.DB e Skia4Delphi. Não conhece planos
financeiros, empresas, permissões de negócio, serviços ou persistência. Não
cria conexão, executa SQL, acessa rede nem altera `Filter`, índices ou ordenação
do dataset. Não propaga marcações entre pais e descendentes.

## Instalação e compilação

O alvo inicial é Delphi 10.2 Tokyo/Win32. Use a mesma versão de Skia4Delphi dos
demais componentes. Os novos fontes seguem as pastas `Source/Controls`,
`Source/DesignSystem` e `Source/Skia`; o registro de classes fica no runtime,
o registro de paleta no design-time e o hook localizado no registro central.

Na raiz do checkout, execute:

```powershell
.\tools\test-dbtreeview.ps1 `
  -BdsRoot 'C:\Program Files (x86)\Embarcadero\Studio\19.0' `
  -SkiaRoot 'M:\Delphi Componentes\Skia4Delphi'
```

O script reconstrói as dependências Skia, os pacotes runtime, design-time e
combinado, testes, exemplo e regressões aplicáveis. As saídas ficam em
`Build/DBTreeView`, com logs por alvo. Os parâmetros `-SkipPackages` e
`-SkipRegression` permitem uma execução dirigida; um resultado obtido com esses
parâmetros não comprova os alvos omitidos. O checkout instalado do Skia e a
configuração da IDE não são alterados pelo script.

Para usar a paleta, instale `DACSkiaComponentsDesign` depois de compilar o
runtime; `TDACDBTreeView` aparece em **DAC Skia**. O pacote combinado continua
disponível para o fluxo já existente da biblioteca. Não instale simultaneamente
as duas alternativas de registro na mesma IDE. Disponibilize as dependências
runtime e `sk4d.dll` Win32 conforme a instalação Skia utilizada.

O exemplo está em `demo-db-treeview/DACDBTreeViewDemo.dproj`. Seu dataset e os
campos de apresentação são locais; abrir o exemplo não integra nem homologa uma
tela do MaxxRural.

## Propriedades e métodos

| Membro | Contrato |
| --- | --- |
| `DataSource: TDataSource` | Referência externa, sem transferência de propriedade. |
| `KeyField`, `ParentField: string` | Campos de identidade e relacionamento; tipos devem ser compatíveis. |
| `Columns: TDACDBTreeColumns` | Coleção persistente, na ordem de exibição. |
| `RootValues: TDACDBTreeRoots` | Coleção persistente de critérios explícitos de raiz. |
| `CheckField: string` | Campo `ftBoolean` opcional usado como fonte da marcação. Vazio habilita marcação local por chave. |
| `CheckableField: string` | Campo `ftBoolean` opcional de elegibilidade. Vazio permite todos os nós; configurado exige `True`, e nulo equivale a `False`. |
| `ReadOnly: Boolean` | Padrão `False`. Bloqueia alteração da marcação; permite navegação, busca e expansão. |
| `SearchFields: TStrings` | Campos pesquisados. Vazio usa os textos das colunas configuradas. |
| `SearchText: string` | Substring visual, sem distinguir maiúsculas/minúsculas e sem remover acentos. |
| `ThemeMode` | `dtmInherit` por padrão; também aceita `dtmDark` e `dtmLight`. |
| `SelectedKey: Variant` | Propriedade runtime. Atribuir uma chave navega para o registro; nulo limpa a seleção visual sem mover o dataset. |
| `CheckedKeys: TArray<Variant>` | Cópia das chaves marcadas do catálogo válido inteiro, inclusive fora da busca e em ramos recolhidos. |
| `TrySetChecked(Key, Checked, Reason)` | Retorna `False` em bloqueio, veto ou falha. O motivo padrão é `tcrProgrammatic`; não dispara alteração quando o estado já é o solicitado. |
| `Expand(Key)`, `Collapse(Key)` | Alteram a expansão visual por chave. |
| `ExpandAll`, `CollapseAll` | Alteram a expansão do catálogo inteiro. Inicialmente os nós ficam recolhidos. |
| `Refresh` | Solicita leitura e validação completa do catálogo, preservando estado por chave quando possível. Não é uma chamada a `DataSet.Refresh`. |
| `BeginUpdate`, `EndUpdate` | Agrupam mudanças, com suporte a chamadas aninhadas. Sempre balancear em `try/finally`. |

As propriedades de configuração e os eventos são publicados e suportam DFM.
`SelectedKey`, `CheckedKeys` e os diagnósticos são runtime; o estado de registros
não é persistido como configuração do formulário.

Cada `TDACDBTreeColumn` publica `FieldName`, `Caption`, `Width`, `Alignment`,
`Hint` e `TitleHint`. A largura inicial é 160 unidades lógicas, com mínimo de 16;
a largura acompanha a escala de DPI. O alinhamento inicial é `taLeftJustify`.
Caption vazio usa o nome do campo. A primeira coluna reserva indentação,
expansor e checkbox; as demais apresentam os textos dos campos. O componente
não contém editor de células. O cabeçalho permanece fixo verticalmente e
acompanha a rolagem horizontal das colunas.

## Identidade, raízes e dados inválidos

São aceitos campos textuais (`ftString`, `ftFixedChar`, `ftWideString`,
`ftFixedWideChar`), inteiros (`ftSmallint`, `ftInteger`, `ftWord`, `ftAutoInc`,
`ftLargeint`, `ftLongWord`, `ftShortint`, `ftByte`) e `ftGuid`.

- Chaves de texto são comparadas pelo conteúdo exato, distinguindo maiúsculas e
  minúsculas, sem trim e sem conversão numérica: `'001'`, `'1'` e `'A'`/`'a'`
  permanecem identidades diferentes.
- Inteiros são normalizados sem perda para `Int64` com sinal. Chamadas runtime
  devem fornecer um Variant inteiro, sem texto ou ponto flutuante; valores
  `UInt64` acima de `High(Int64)` são rejeitados para evitar alias com negativos.
- GUIDs são normalizados pelo valor do GUID. Chamadas runtime usam uma string
  GUID válida. Um campo textual contendo um GUID continua sendo texto, não
  recebe automaticamente a semântica de `ftGuid`.
- Chave nula é inválida. `RecNo`, ponteiros e posição visual não identificam
  registros. Bookmarks são auxiliares de navegação e pertencem à carga atual.

Cada item de `RootValues` tem `Kind` e `Value`:

| `Kind` | Interpretação |
| --- | --- |
| `trkNull` | Pai nulo. `Value` não participa. |
| `trkEmptyString` | Pai textual exatamente vazio; não converte vazio em zero. |
| `trkValue` | Pai igual à sentinela `Value`, respeitando o tipo da chave. |

A coleção inicial contém `trkNull` e `trkEmptyString`. Zero não é raiz por
convenção: configure uma sentinela inteira `0` quando esse for o contrato do
consumidor. Os critérios de raiz são aplicados antes da procura de um pai;
escolha sentinelas que não representem relacionamentos reais do catálogo.

Exemplo de configuração DFM para raízes nulas ou com pai inteiro zero:

```text
object Tree: TDACDBTreeView
  DataSource = dsCatalogo
  KeyField = 'ID'
  ParentField = 'PARENT_ID'
  Columns = <
    item
      FieldName = 'CODE'
      Caption = 'Código'
      Width = 220
    end
    item
      FieldName = 'DESCRIPTION'
      Caption = 'Descrição'
      Width = 420
    end>
  RootValues = <
    item
      Kind = trkNull
    end
    item
      Kind = trkValue
      Value = 0
    end>
end
```

A carga é transacional: valida todas as chaves e relações antes de publicar os
nós. Duplicatas, pai ausente, autorreferência, ciclos, tipos incompatíveis e
campos inexistentes rejeitam a carga inteira. Não há política de transformar
órfãos em raízes ou escolher um pai arbitrário. A árvore fica vazia, a seleção
é limpa e o erro fica disponível em `LastError` e `OnDataError`.

O estado anterior é guardado internamente por chave para restaurar expansão e
marcação local após uma carga válida da mesma instância de dataset. Um fechamento
esvazia a apresentação; reabrir a mesma instância permite essa restauração.
Trocar a instância reinicializa o estado. Após atualização válida, chaves que
desapareceram são removidas dos estados guardados; marcas removidas geram
notificação. A seleção acompanha o registro atual válido ou fica nula.

## Ciclo de edição e eventos

O componente não chama `Edit`, `Post`, `Cancel` nem `ApplyUpdates`. Com
`CheckField`, o consumidor precisa fornecer campo booleano gravável e deixar o
registro em `dsEdit`/`dsInsert` antes da escrita. `CanModify`, `ReadOnly`, a
elegibilidade e o veto continuam sendo respeitados. O evento anterior permite
que o consumidor inicie a edição depois de identificar a chave solicitada.

A navegação mantém a semântica VCL: mover para outro registro pode provocar
`Post` ou `Cancel` implícito pelo próprio dataset. Isso se aplica ao dataset
local e é uma decisão explícita deste contrato. O consumidor controla seus
eventos de persistência e o encerramento da edição; não deve conectar uma
operação remota de gravação sem considerar esse comportamento.

Falha de escrita não ativa marcação local como alternativa. O componente lê o
resultado autoritativo do campo quando possível. Sem `CheckField`, as marcas
ficam exclusivamente no estado local por chave, com os mesmos eventos de veto
e mudança; não há escrita no dataset.

| Evento | Assinatura e uso |
| --- | --- |
| `OnCurrentChanged` | `(Sender; const OldKey, NewKey: Variant; Reason)`; mudança da linha atual, com nulo representando ausência. |
| `OnBeforeCheckChange` | `(Sender; const Key: Variant; const Checked: Boolean; var Allow: Boolean)`; `Checked` é o estado solicitado e `Allow := False` veta a solicitação. |
| `OnCheckChanged` | `(Sender; const Key: Variant; Checked: Boolean; Reason)`; alteração efetiva, inclusive mudanças externas observadas e remoção de marcação. |
| `OnActivateRecord` | `(Sender; const Key: Variant)`; ativação por Enter, sem regra de negócio associada. |
| `OnDataError` | `(Sender; const Key: Variant; const MessageText: string)`; diagnóstico de carga/operação; chave nula para erro global. |

`Reason` usa `TDACDBTreeChangeReason`: `tcrUser`, `tcrProgrammatic`,
`tcrDataSet`, `tcrRemoved` e `tcrReset`. O veto se aplica aos pedidos feitos pelo
componente; mudanças externas já ocorridas são notificadas, não vetadas.
Carregar um campo inicialmente marcado pode gerar `OnCheckChanged` com
`tcrDataSet`; esse evento não deve ser tratado como ordem de persistência.
Pedidos de marcação reentrantes dentro de um pedido em andamento são recusados.

Configuração mínima do consumidor, supondo um `TClientDataSet` local já aberto
e completo e um `TDataSource` ligado a ele:

```pascal
Tree.BeginUpdate;
try
  Tree.KeyField := 'PLANOFINANCE_CODIGO';
  Tree.ParentField := 'PLANOFINANCE_CODIGOPAI';
  Tree.Columns.Clear;
  with Tree.Columns.Add do
  begin
    FieldName := 'PLANOFINANCE_CODIGOPLANO';
    Caption := 'Código';
    Width := 220;
  end;
  with Tree.Columns.Add do
  begin
    FieldName := 'PLANOFINANCE_DESCRICAO';
    Caption := 'Descrição';
    Width := 420;
  end;
  Tree.CheckField := 'SELECIONADO';
  Tree.CheckableField := 'SELECIONAVEL';
  Tree.OnBeforeCheckChange := TreeBeforeCheckChange;
  Tree.OnCheckChanged := TreeCheckChanged;
  Tree.DataSource := dsCatalogo;
finally
  Tree.EndUpdate;
end;
```

Os nomes acima pertencem ao exemplo consumidor e não existem como convenção no
componente. A elegibilidade deve ser calculada pelo consumidor em `SELECIONAVEL`.
Um consumidor que conclui cada edição local pode usar:

```pascal
procedure TMeuForm.TreeBeforeCheckChange(Sender: TObject;
  const Key: Variant; const Checked: Boolean; var Allow: Boolean);
begin
  { A regra de veto, se houver, pertence ao consumidor. }
  if Allow and not (cdsCatalogo.State in [dsEdit, dsInsert]) then
    cdsCatalogo.Edit;
end;

procedure TMeuForm.TreeCheckChanged(Sender: TObject;
  const Key: Variant; Checked: Boolean; Reason: TDACDBTreeChangeReason);
begin
  if (Reason in [tcrUser, tcrProgrammatic]) and
    (cdsCatalogo.State in [dsEdit, dsInsert]) then
    cdsCatalogo.Post;  { Post local realizado pelo consumidor. }
end;
```

Inclua `Data.DB`, `System.Variants`, `DAC.Components.Controls.DBTreeView` e
`DAC.Components.Controls.DBTreeView.Types` nas units consumidoras. Em aplicação
que carrega DFM, inclua os registros runtime e de hooks da biblioteca conforme
o exemplo. `OnDataError` não executa `Cancel`; erros e vetos não transferem ao
componente o controle da transação do consumidor.

## Atualização, busca e limites do DataLink

A árvore mantém um cache indexado por chave e uma projeção de linhas visíveis.
Pintura não navega nem lê campos do dataset. Rolagem comum sincroniza a seleção;
alterações de campos do registro atual atualizam o cache desse registro. Mudanças
de chave/pai, inserções, exclusões, layout ou carga exigem validação estrutural.
`BeginUpdate`/`EndUpdate` permite agrupá-las sem reconstrução por registro.

Leituras completas ocorrem em `dsBrowse`, preservam a posição com bookmark e
balanceiam `DisableControls` em `finally`. Datasets unidirecionais ou sem
bookmark seguro para reposicionamento são rejeitados. O catálogo deve estar
completo e local; o componente não busca páginas remotas nem completa uma
hierarquia parcial. A ordem dos irmãos segue a ordem fornecida pelo dataset.
O consumidor não deve alterar registros ou mover seu cursor dentro de
`OnGetText` dos campos usados na apresentação.

Há uma limitação do contrato genérico VCL no Tokyo: `First`, `Last` e
`DataSet.Refresh` podem produzir o mesmo `deDataSetChange`, sem informar a causa
ao DataLink. O componente distingue navegação quando a quantidade continua
igual, a chave atual já pertence ao catálogo e houve mudança de linha,
notificação de fim de edição ou condição de limite `BOF`/`EOF`. Nesses casos
atualiza o registro atual e a seleção. Uma notificação com a mesma chave atual,
fora desses casos de edição/limite, permite recarga por refresh.

Atualizações opacas que substituem registros mantendo a quantidade ou mudam a
ordem sem `LayoutChanged` não podem ser identificadas com certeza por essa
heurística, especialmente nos limites ou quando também movem o cursor. Após
essas operações, chame **`Tree.Refresh` explicitamente**, ou envolva a atualização
do consumidor em **`Tree.BeginUpdate`/`Tree.EndUpdate`**. Esse é o contrato
recomendado após qualquer atualização em lote; não dependa somente de
`DataSet.Refresh` para invalidar todo o cache visual.

A busca é exclusivamente visual: mantém no catálogo nós ocultos e suas marcas,
mostra resultados e ancestrais e expande temporariamente os caminhos encontrados.
Limpar a busca restaura a expansão anterior. Uma seleção fora do resultado
permanece em `SelectedKey`; a busca não navega automaticamente para outro
registro. Não há ordenação visual configurável nesta versão.

## Interação, diagnóstico e validação

Expansor altera apenas expansão; checkbox altera apenas marcação; corpo da
linha seleciona o registro. Setas e Home/End/PageUp/PageDown navegam pelas linhas
visíveis; esquerda/direita recolhem/expandem e navegam na hierarquia; espaço
solicita marcação e Enter ativa. Tab e Shift+Tab saem pelo fluxo normal do
formulário. Atalhos com modificadores permanecem disponíveis ao formulário.

Foco, hover, seleção e marcação são estados distintos. A pintura usa Skia para
superfícies, bordas e ícones, texto Windows no mesmo buffer e somente as linhas
do viewport. Fontes, cores, métricas e escala seguem o design system; não são
criados controles VCL individuais por nó.

`IsDataValid` informa se há catálogo válido. `LastError` e `OnDataError` também
podem indicar uma falha operacional sobre catálogo ainda válido, como uma
marcação recusada por campo não gravável. Esses erros operacionais não apagam
as linhas válidas nem equivalem a rejeição estrutural. O consumidor deve usar
os dois estados ao decidir o que apresentar ou permitir.

`Model`, `LoadCount` e `DataReadCount` são diagnósticos runtime:

- `LoadCount` conta cargas completas publicadas com sucesso.
- `DataReadCount` conta leituras de registros para o cache, incluindo atualizações
  pontuais; não é um contador de comandos SQL ou chamadas de API.
- `Model` expõe a estrutura atual para inspeção. **Não modifique seus nós,
  coleções ou campos e não guarde seus ponteiros entre eventos/atualizações.**
  Use chaves e a API do componente. O objeto pode ser substituído em um refresh.

Os testes de dados/DFM/ciclo de vida ficam em `Tests/DACDBTreeViewTests.dpr`;
os testes do painter em `Tests/DACDBTreeViewPainterTests.dpr`. O script de build
registra seus resultados e permite reproduzir a verificação. Leia as evidências
de validação entregues junto ao componente para os resultados efetivamente
executados.

As categorias de evidência permanecem separadas: testes automatizados e tempo de
carga; renderização offscreen em DPI lógico 96/144/192; interação física e
apresentação em monitores com DPI real; instalação/uso do designer; integração
no MaxxRural. Imagens offscreen não comprovam teclado físico nem DPI real.
Compilação e testes da biblioteca não aprovam a tela financeira consumidora.

O exemplo inclui manifest de consciência de DPI do sistema desde a inicialização
do processo. O componente não altera a política de DPI da aplicação hospedeira.
A fonte padrão é definida na base de 96 DPI e a VCL a escala uma vez; o painter
usa a altura nativa já escalada. O recurso do manifest é gerado em `Build` pelo
script ou pelo target do `.dproj`, sem modificar configurações do Windows/IDE.

Veja [os resultados executados](validation.md).

## Uso na galeria oficial

Abra o projeto `demo/Demo.dproj`. A página **DBTreeView**, também listada no
menu lateral, contém o exemplo com busca, expansão, marcação e dataset local.
O formulário de `demo-db-treeview` é compartilhado com essa página; o exemplo
independente continua disponível. O script de testes também compila a demo
oficial e atualiza `Build/Exe/Win32/Debug/Demo.exe`.
