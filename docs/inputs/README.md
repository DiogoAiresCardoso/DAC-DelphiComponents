# Campos de entrada DAC e validação em runtime

Use este guia para configurar os campos VCL da suíte DAC em um formulário Delphi. Defina a regra de negócio em `OnValidate`, use `Validate` no fluxo de gravação e configure a apresentação no Object Inspector, no DFM ou por código. A galeria oficial reúne os exemplos nas abas **Inputs** e **Seletores**.

## Escolher o componente

| Componente | Uso | Unit para o `uses` |
| --- | --- | --- |
| `TDACEdit` | Texto em uma linha, senha, busca visual e máscaras VCL. | `DAC.Components.Controls.Edit` |
| `TDACButtonEdit` | Texto ou código com botão de ação, por exemplo para abrir uma pesquisa. Herda a configuração de `TDACEdit`. | `DAC.Components.Controls.ButtonEdit` |
| `TDACNumericEdit` | Inteiro, decimal, moeda ou peso. Expõe `Value` e um bloco de texto opcional à esquerda ou à direita. | `DAC.Components.Controls.NumericEdit` |
| `TDACDateTimePicker` | Campo mascarado com seletor de data ou hora. Expõe `DateTime` e `IsNull`. | `DAC.Components.Controls.DateTimePicker` |
| `TDACMemo` | Texto de várias linhas com `Text`, `Lines`, `WordWrap` e `ScrollBars`. | `DAC.Components.Controls.Memo` |
| `TDACComboBox` | Seleção em lista ou entrada editável. Expõe `Items`, `ItemIndex`, `Text` e `Style`. | `DAC.Components.Controls.ComboBox` |

Todos os componentes da tabela expõem `OnValidate` e `Validate`. O tipo `TDACFieldValidateEvent` fica em `DAC.Components.Controls.FieldSupport`. Os estados `mesNormal`, `mesSuccess`, `mesWarning` e `mesDanger` são declarados em `DAC.Components.Controls.Edit`.

## Configurar a apresentação

| Propriedade | Comportamento |
| --- | --- |
| `LabelText` | Rótulo acima do campo. |
| `Required` | Mostra um asterisco quando há rótulo. Para exigir preenchimento, trate o texto vazio na regra de `OnValidate`. |
| `HelperText` | Texto de orientação abaixo do campo. Reservar essa linha no layout acomoda a mensagem de validação. |
| `ErrorText` | Mensagem exibida no lugar da ajuda quando `Status = mesDanger` e há texto de erro. Com `ErrorText` vazio, a ajuda é exibida na cor de erro. |
| `Status` | Estado visual. A validação aplica `mesDanger` e preenche `ErrorText` ao rejeitar um valor. Quando a correção é aceita, o estado volta a `mesNormal` e a mensagem de erro é limpa. |
| `Enabled`, `ReadOnly`, `Loading` | Controlam a disponibilidade para edição. A validação automática roda em campos editáveis. Ao chamar `Validate` na gravação, escolha quais campos devem participar da regra, inclusive os indisponíveis quando fizerem parte dos dados a gravar. |
| `ThemeMode` | `dtmInherit` acompanha o tema resolvido pelo contêiner. `dtmLight` e `dtmDark` selecionam um tema explicitamente. |
| `Variant` | Disponível em `TDACEdit` e descendentes e em `TDACComboBox`. Use `mivOutlined`, `mivUnderlined` ou `mivCompact`. Para a densidade dos campos de uma linha, use `InputSize = misSmall`. |
| `Placeholder`, `MaxLength`, `CharCase` | Configurações de `TDACEdit` e dos descendentes. O placeholder é uma dica visual. |
| `CounterText` | Texto de contador configurado pela aplicação em `TDACEdit` e descendentes e em `TDACComboBox`. Para um contador dinâmico, atualize a propriedade em `OnChange`. |

No estado `mesDanger`, a borda, o rótulo, o asterisco e o texto de apoio usam as cores de erro do tema. No `TDACNumericEdit`, o texto e o divisor do sufixo também acompanham o estado. A camada de texto compartilhada mantém essas cores sob o estilo VCL `Windows10` usado pelo demo. [Apresentação e tokens dos campos](../../Source/Controls/DAC.Components.Controls.FieldSupport.pas)

## Implementar a regra do campo

Crie um método no formulário com a assinatura abaixo. No Object Inspector, selecione o método em `OnValidate`. No DFM, use `OnValidate = NomeDoMetodo`. Para um campo criado em runtime, atribua `Campo.OnValidate := NomeDoMetodo` depois de criá-lo.

```pascal
procedure ValidarCampo(Sender: TObject; const AText: string;
  var AErrorText: string);
```

`Sender` é o componente DAC. `AText` contém o texto atual entregue à regra e pode representar uma entrada parcial. Para campos com máscara, o componente entrega uma string vazia quando restam apenas literais e posições em branco. A regra começa com `AErrorText = ''`. Preencha a variável com uma mensagem para rejeitar o valor. Uma mensagem composta apenas de espaços conta como vazia.

Mantenha a regra síncrona e rápida. Use `AErrorText` para apresentar a falha e deixe as mudanças de foco e de estilo a cargo do componente. Mantenha persistência, consultas remotas e diálogos no fluxo da aplicação. Ao carregar ou preencher campos por código, chame `Validate` explicitamente quando precisar do resultado, pois os setters de `Text`, `Value`, `DateTime` e `ItemIndex` seguem os eventos de cada componente.

### Digitação, saída e gravação

| Ação | Resultado |
| --- | --- |
| Digitar antes de o campo exibir um erro | A regra roda durante a edição. O primeiro erro de digitação permanece sem mensagem até a tentativa de saída ou a validação explícita. |
| Tentar sair do campo com valor preenchido e inválido | O campo exibe a mensagem e retém o foco ao navegar para outro controle do formulário. |
| Editar após exibir um erro | A mensagem acompanha a digitação. Corrigir o valor limpa o erro. Se o valor voltar a ser inválido na mesma edição, a mensagem reaparece imediatamente. |
| Limpar o campo | A validação automática limpa o erro e permite a troca de foco. A validação explícita ainda pode exigir o preenchimento. |
| Chamar `Validate` | Executa a regra, atualiza a apresentação e retorna `False` quando a regra fornece uma mensagem. A aplicação decide se deve focar o campo inválido. |
| Deixar `OnValidate` vazio | `TDACDateTimePicker` e `TDACNumericEdit` em `nvmExactBcd` aplicam a validação intrínseca. Os demais mantêm a apresentação configurada e `Validate` retorna `True`. |

No handler de salvar, verifique `Validate` antes de ler ou persistir os valores tipados. Se houver vários campos, trate cada retorno e foque o primeiro campo inválido quando ele estiver visível e puder receber foco. [Política compartilhada de validação](../../Source/Controls/DAC.Components.Controls.FieldSupport.pas)

### Matriz de eventos

| Campo | Digitação e mudança | Atribuição por código | Popup | Tentativa de saída e `Validate` |
| --- | --- | --- | --- | --- |
| `TDACEdit` e `TDACButtonEdit` | A alteração nativa dispara `OnChange` e, com o campo visível, avalia `OnValidate`. | `Text` usa o editor nativo e pode disparar a sequência de mudança. Para validar uma carga, chame `Validate`. | `TDACButtonEdit` usa `OnButtonClick` para a pesquisa. A aplicação atribui o resultado ao campo. | Usa a regra de `OnValidate`, quando configurada. |
| `TDACNumericEdit` | Em modo legado, a normalização precede `OnChange` e `OnValidate`. Em modo exato, os eventos recebem o texto que está no editor. | `Value` no modo legado e `SetValueBcd` no exato preenchem o editor sem a sequência de digitação. `Text` segue o caminho de mudança do modo ativo. | Sufixo visual. | No modo exato aplica a regra BCD e formata após uma saída aceita. No legado mantém a regra atribuída e a formatação convencional. |
| `TDACDateTimePicker` | `OnValidate` pode receber texto parcial. `OnChange` informa uma alteração confirmada do valor tipado. | `DateTime` e `IsNull` configuram o valor e a apresentação. Use `Validate` para verificar o texto resultante. | A confirmação pode alterar o valor e disparar `OnChange`. Abrir ou cancelar preserva a possibilidade de corrigir o campo. | Verifica a completude da máscara e a validade da data ou hora. Aplica também a regra atribuída. |
| `TDACMemo` | Alterações no editor atualizam `Text` e `Lines` e passam pela sequência de mudança. | `Text` e `Lines` atualizam a apresentação. Chame `Validate` quando precisar avaliar o resultado. | Sem seleção própria. | Usa a regra atribuída ao texto completo. |
| `TDACComboBox` | A edição em `csDropDown` e a seleção do usuário seguem a sequência de mudança. | `Text` e `ItemIndex` atualizam o estado. Chame `Validate` para avaliar uma atribuição. | A seleção pelo popup passa pela sequência de mudança. O popup faz parte da edição do campo. | Usa a regra atribuída ao texto ou ao item selecionado. |

Em data e no modo BCD, `OnValidate` recebe inicialmente uma mensagem vazia. Se o callback preencher `AErrorText`, sua mensagem tem precedência. Se deixar a mensagem vazia, o componente mantém o resultado da validação intrínseca.

## Configurar os tipos de campo

### Texto, máscara, senha e pesquisa

| `TDACEdit.EditKind` | Configuração |
| --- | --- |
| `mekText` | Padrão para texto livre. Use `MaxLength` e `CharCase` conforme o dado. |
| `mekMasked` | Defina `EditMask` com a sintaxe VCL. Por exemplo, `000.000.000\-00;1;_` fornece a apresentação de CPF. Valide os dígitos e a regra de negócio em `OnValidate`. |
| `mekPassword` | Use `PasswordChar` para escolher o caractere de ocultação. O componente usa `*` quando a propriedade está no padrão. |
| `mekSearch` | Mostra o ícone de busca. Para abrir uma tela de pesquisa por botão ou F3, use `TDACButtonEdit`. |
| `mekNumeric`, `mekDate`, `mekTime` | Oferecem máscaras padrão e aceitam substituição por `EditMask`. Para ler um número ou uma data como valor tipado, escolha `TDACNumericEdit` ou `TDACDateTimePicker`. |

Em `TDACButtonEdit`, configure `ButtonCaption`, `ButtonIconKind`, `ShowButtonIcon`, `ButtonWidth` e `ButtonKind` conforme a ação. Os padrões do botão são `mikSearch` e `mbkInputAction`. Atribua a pesquisa a `OnButtonClick`. O clique e F3 sem modificadores usam esse mesmo evento quando a ação está disponível. Se o formulário ou o campo tratar F3 em `OnKeyDown`, atribua `Key := 0` no handler para consumir a tecla. [API do campo com botão](../../Source/Controls/DAC.Components.Controls.ButtonEdit.pas)

### Números e sufixos

| Configuração de `TDACNumericEdit` | Comportamento |
| --- | --- |
| `NumericKind = dnkNumber` | Número geral. Começa com zero casas decimais. |
| `NumericKind = dnkCurrency` | Moeda. Usa o símbolo regional fora da edição quando `SuffixText` está vazio. Ao selecionar esse modo sem casas configuradas explicitamente, assume duas casas. |
| `NumericKind = dnkWeight` | Peso. Usa `WeightUnit`, inicialmente `kg`, no valor formatado quando `SuffixText` está vazio. Ao selecionar esse modo sem casas configuradas explicitamente, assume três casas. |
| `DecimalPlaces` e `NumericMask` | `DecimalPlaces` aceita de 0 a 8. `nmkInteger` ajusta para zero casas e `nmkDecimal` restaura uma precisão decimal se a precisão atual for zero. Configure `NumericKind` primeiro e escolha uma dessas propriedades para determinar a precisão. |
| `UseGrouping` | Ativa o agrupamento de milhares no formato numérico do componente. A moeda regional, sem sufixo externo, usa o formato de moeda da RTL. |
| `AllowNegative` | Permite negativos por padrão. No modo legado, `False` filtra o sinal negativo e atribuir um `Value` negativo resulta em zero. No modo exato, `False` rejeita a entrada negativa na validação. |
| `Value` | Valor `Double` do modo legado. Leia-o depois de validar o texto. Durante uma entrada parcial, como apenas `-`, o componente pode conservar o último valor que conseguiu interpretar. |
| `SuffixText` e `SuffixWidth` | Definem o texto fixo e sua largura reservada. Um texto vazio remove o bloco. O texto fixo fica separado do conteúdo editável. |
| `SuffixPosition` | `nspRight` é o padrão e coloca o bloco depois do valor. `nspLeft` coloca o mesmo bloco antes do valor, como um prefixo. A propriedade pode mudar durante a edição. |

Use `SuffixText = '%'` para uma unidade visual em um campo percentual. O número `5` continua armazenado como `5`. Converta para `0,05` na aplicação se esse for o contrato de persistência. Em moeda ou peso, o bloco externo assume a apresentação do símbolo ou da unidade quando `SuffixText` recebe um valor. Para mostrar uma libra fixa antes do valor, configure `NumericKind = dnkCurrency`, `SuffixPosition = nspLeft` e `SuffixText = #163`.

No modo legado, valide o texto corrente antes de usar `Value`. `TryStrToFloat` serve para entradas numéricas simples usando o formato regional. Para usar o parser também fora do foco, configure `UseGrouping = False` e mantenha o símbolo ou a unidade no bloco externo. O sinal `-` isolado permanece durante a digitação com `AllowNegative = True`. Se a saída for aceita enquanto resta só o sinal, o campo é limpo. [API e formatação do campo numérico](../../Source/Controls/DAC.Components.Controls.NumericEdit.pas)

### Valores monetários exatos em TBcd

Com o campo vazio, configure `ValueMode = nvmExactBcd`. Esse modo usa vírgula decimal e ponto de milhar em grupos de três, independentemente da região do Windows. `1.234` representa `1234`. Entradas como `10.50`, `10,` e frações acima de `DecimalPlaces` ficam visíveis durante a edição e são rejeitadas na validação. `AllowNegative` determina se o sinal é aceito. `UseGrouping` afeta a formatação após uma saída aceita. Para moeda e peso, configure o símbolo ou a unidade com `SuffixText`.

O limite de precisão considera os dígitos inteiros mais as casas configuradas em `DecimalPlaces`, incluindo os zeros acrescentados na formatação. Para limites de negócio mais restritos, como os de uma coluna do banco, acrescente a regra em `OnValidate`.

O DFM grava a configuração do modo. Inicialize o valor exato no carregamento do formulário por `SetValueBcd`. Passe um `TBcd` de origem decimal, por exemplo usando `StrToBcd` com `TFormatSettings.Invariant`. Atribuições tipadas fora dos limites do campo são rejeitadas antes de alterar o texto. No código do formulário, use a API BCD para leitura e escrita. `Value` em runtime é reservado ao modo legado.

```pascal
// Uses Data.FmtBcd, System.SysUtils e DAC.Components.Controls.NumericEdit.
edtValor.ValueMode := nvmExactBcd;
edtValor.NumericKind := dnkCurrency;
edtValor.DecimalPlaces := 5;
edtValor.SuffixText := 'R$';
edtValor.SuffixPosition := nspLeft;
edtValor.SetValueBcd(StrToBcd('1234567890123.12345', TFormatSettings.Invariant));
```

Na gravação, `Validate` avalia o texto e as regras da aplicação. `TryGetEditedValueBcd` fornece o valor tipado quando há um número completo e válido. Para integrar o lançamento do MaxxRural, configure cinco casas e reaproveite em `OnValidate` a regra do formulário que limita a 13 dígitos inteiros. Serialize o `TBcd` com `BcdToStr` e formato invariável na fronteira de persistência.

```pascal
var
  LValor: TBcd;
begin
  if not edtValor.Validate then
    Exit;
  if not edtValor.TryGetEditedValueBcd(LValor) then
    Exit;
  FController.Alterar('MOV_VALOR', BcdToStr(LValor, TFormatSettings.Invariant));
end;
```

### Data, hora, memo e seleção

- Em `TDACDateTimePicker`, escolha `PickerKind = dtkDate` ou `dtkTime` e inicialize `DateTime` com o valor da aplicação. Para representar ausência de valor, configure `AllowNull = True` antes de atribuir `IsNull = True`. `FormatString` configura a apresentação e a máscara. A conversão segue os parsers regionais de data e hora. Ao trocar `PickerKind`, ajuste `FormatString` para o novo tipo ou esvazie a propriedade para usar o formato regional curto. `TimeStepMinutes` ajusta o passo do seletor de hora. [API de data e hora](../../Source/Controls/DAC.Components.Controls.DateTimePicker.pas)
- Em `TDACMemo`, use `Text` para tratar o conteúdo inteiro ou `Lines` para manipular linhas. Configure `WordWrap` e `ScrollBars` conforme o espaço do formulário. A regra recebe o texto inteiro. [API do memo](../../Source/Controls/DAC.Components.Controls.Memo.pas)
- Em `TDACComboBox`, use `Style = csDropDownList` para seleção e `Style = csDropDown` para permitir digitação. Preencha `Items` e use `ItemIndex` para identificar o item, com `-1` quando não há seleção. O texto livre de um combo editável pode ter `ItemIndex = -1`. Valide `AText` ou consulte `TDACComboBox(Sender).ItemIndex` conforme a regra. [API do combo](../../Source/Controls/DAC.Components.Controls.ComboBox.pas)

### Leitura segura de data e hora

O picker valida a entrada por padrão. Um texto preenchido e inválido retém o foco. Limpar o campo permite navegar. Ao salvar, `Validate` só aceita vazio quando `AllowNull = True` e a regra da aplicação aceita. `TryGetEditedDateTime` retorna `False` para vazio, máscara incompleta ou valor inválido, enquanto `DateTime` pode manter o último valor confirmado. Ao confirmar pelo texto, o modo data conserva a hora anterior e o modo hora conserva a data anterior.

Para um lançamento com data obrigatória, configure `AllowNull = False` e use o valor devolvido pela leitura segura ao gravar. Para um campo opcional, trate o vazio aceito por `Validate` como ausência de valor.

```pascal
var
  LData: TDateTime;
begin
  if not dtpDataLancamento.Validate then
    Exit;
  if not dtpDataLancamento.TryGetEditedDateTime(LData) then
    Exit;
  FController.Alterar('MOV_DATA', FormatDateTime('yyyy-mm-dd', LData));
end;
```

## Exemplo completo em Delphi e DFM

Adicione os dois arquivos a um projeto VCL que já tenha a suíte DAC e Skia4Delphi no caminho de compilação. Abra o formulário `TFrmCampos` a partir do projeto. O exemplo usa a regra de faixa para percentual e mostra a diferença entre `%` à direita e `£` à esquerda.

### FrmCampos.pas

```pascal
unit FrmCampos;

interface

uses
  System.Classes,
  Vcl.Forms,
  Vcl.StdCtrls,
  DAC.Components.Controls.NumericEdit;

type
  TFrmCampos = class(TForm)
    edtPercentual: TDACNumericEdit;
    edtPreco: TDACNumericEdit;
    btnSalvar: TButton;
    procedure PercentualValidate(Sender: TObject; const AText: string;
      var AErrorText: string);
    procedure btnSalvarClick(Sender: TObject);
  end;

implementation

uses
  System.SysUtils,
  Vcl.Dialogs,
  DAC.Components.Controls.Register;

{$R *.dfm}

procedure TFrmCampos.PercentualValidate(Sender: TObject; const AText: string;
  var AErrorText: string);
var
  LPercentual: Double;
begin
  if Trim(AText) = '' then
  begin
    AErrorText := 'Informe o percentual.';
    Exit;
  end;

  if not TryStrToFloat(Trim(AText), LPercentual) then
  begin
    AErrorText := 'Informe um numero valido.';
    Exit;
  end;

  if (LPercentual < 0) or (LPercentual > 100) then
    AErrorText := 'Informe um valor de 0 a 100.';
end;

procedure TFrmCampos.btnSalvarClick(Sender: TObject);
begin
  if not edtPercentual.Validate then
  begin
    edtPercentual.SetFocus;
    Exit;
  end;

  ShowMessage(Format('Percentual validado %.2f%%', [edtPercentual.Value]));
end;

end.
```

### FrmCampos.dfm

```dfm
object FormCampos: TFrmCampos
  Caption = 'Campos DAC'
  ClientHeight = 154
  ClientWidth = 440
  object edtPercentual: TDACNumericEdit
    Left = 16
    Top = 16
    Width = 196
    Height = 88
    DecimalPlaces = 2
    HelperText = 'Informe um valor de 0 a 100.'
    LabelText = 'Percentual'
    Required = True
    SuffixPosition = nspRight
    SuffixText = '%'
    SuffixWidth = 32
    TabOrder = 0
    UseGrouping = False
    Value = 125.000000000000000000
    OnValidate = PercentualValidate
  end
  object edtPreco: TDACNumericEdit
    Left = 228
    Top = 16
    Width = 196
    Height = 64
    LabelText = 'Preco'
    NumericKind = dnkCurrency
    SuffixPosition = nspLeft
    SuffixText = #163
    SuffixWidth = 40
    TabOrder = 1
    Value = 5.000000000000000000
  end
  object btnSalvar: TButton
    Left = 16
    Top = 112
    Width = 96
    Height = 28
    Caption = 'Salvar'
    TabOrder = 2
    OnClick = btnSalvarClick
  end
end
```

Ao pressionar Tab a partir de `125`, o campo mostra a faixa válida e mantém o foco. Digitar `50` limpa o erro e libera a saída. Limpar o campo também permite navegar. Ao acionar **Salvar** com o campo vazio, a regra exibe a mensagem de preenchimento. O botão do exemplo exibe o resultado após a validação, deixando a gravação a cargo da aplicação.

## Verificação para alterações futuras

1. Use `demoNumericPercentError` para conferir a validação, `demoNumericCurrencyLeft` para conferir o símbolo à esquerda e `demoNumericExactBcd` para testar moeda exata em pt-BR. O handler `ValidatePercent` e a carga inicial BCD estão no formulário principal. [DFM da galeria](../../demo/Demo.Principal.dfm) · [Código da galeria](../../demo/Demo.Principal.pas)
2. Compile `demo/Demo.dpr` em **Win32** com Delphi 10.2 Tokyo ou com o toolchain do projeto consumidor. Use o `sk4d.dll` de Win32 junto ao executável quando usar a distribuição dinâmica do Skia. Atualize o pacote de design correspondente para inspecionar propriedades novas no Object Inspector. [Projeto do demo](../../demo/Demo.dproj) · [Grupo de projetos](../../demo/DemoComponentes.groupproj)
3. Rode os testes atuais de interação e de inicialização. Eles cobrem Tab, retenção de foco, correção, limpeza de texto mascarado, validação explícita de vazio, seleção em popup, troca de lado do sufixo e renderização do vermelho com o estilo VCL ativo. Rode também o teste de ciclo de vida ao mexer em propriedades consumidas pelo designer. [Interação](../../Tests/DACComponentsInteraction.Current.dpr) · [Inicialização do demo](../../Tests/DACDemoStartup.Current.dpr) · [Ciclo de vida](../../Tests/DACComponentsDesignLifecycle.Current.dpr)
