# 03 — Configuração, persistência e dados

[Índice](../README.md) · [Declarações e getters](catalogo-api.md) · [Whitelist real](catalogo-opcoes.json)

A API foi tipada depois da consolidação inicial. Enums/sets e objetos de medidas,
limites/cores substituem as propriedades string; veja o [capítulo 11](11-api-tipada.md).

## Uma representação, várias formas de edição

`TDACChartOptions` mantém um `TJSONObject` para as opções gerais. Cada item de
`Series` possui seu próprio store. `Clone` monta o documento completo, substituindo
o array `series` pelos stores da coleção. Não se deve manter referências a nós
internos depois de uma importação: a árvore e os itens podem ser substituídos.

`TDACChartOptionNode` representa um caminho na árvore. As propriedades Delphi leem
e escrevem nesse caminho. `Title.FontSize`, por exemplo, atua em
`title.textStyle.fontSize`; `Series[i].Kind` corresponde a `series[i].type`.
O nome Delphi `LabelStyle` evita conflitos de linguagem e representa `label`.

`Options.JSON` é a representação canônica persistida no DFM. Os grupos tipados usam
`stored False` para evitar duas representações independentes do mesmo estado.
Subobjetos herdam `JSON`; opções sem propriedade dedicada podem ser editadas nele.
Animação expõe `AnimationMode`, `AnimationEasing` e `AnimationEasingUpdate`;
`Dataset.SourceHeader` também é tipado. Durações, dados e demais opções sem
propriedade dedicada continuam disponíveis pelo JSON validado.

```pascal
Chart.LoadJSON('{"animation":false,"xAxis":{"type":"category",' +
  '"data":["Jan","Fev","Mar"]},"yAxis":{"type":"value"},' +
  '"tooltip":{"trigger":"axis","confine":true},' +
  '"series":[{"id":"producao","name":"Producao","type":"bar",' +
  '"data":[10,20,null]}]}');
Chart.BeginUpdate;
try
  Chart.Options.Title.Text := 'Producao mensal';
  Chart.Options.Series[0].LabelStyle.Show := True;
finally
  Chart.EndUpdate;
end;
Configuracao := Chart.SaveJSON;
```

`BeginUpdate/EndUpdate` admite aninhamento e coalesce notificações. Não constitui
transação com rollback: uma exceção no meio de setters deixa os setters anteriores
aplicados. `EndUpdate` sem par gera `EInvalidOperation`. `Assign` copia conteúdo;
não transfere ownership do objeto de origem.

## Ausência e valores explícitos

| Entrada | Intenção | Cuidado na implementação atual |
| --- | --- | --- |
| Chave ausente | Resolver default contextual | Getter do Inspector e renderer podem divergir |
| `false` | Desabilitar explicitamente | Não remover a chave como otimização |
| `0` | Zero numérico | Não interpretar como automático |
| `"0"` | Texto numérico | Permitido em medidas; opções numéricas comuns exigem número JSON |
| `"25%"` | Percentual da dimensão de referência | A dimensão depende da propriedade |
| `25` / `"25"` em comprimento | Pixels lógicos | Multiplicados por DPI/96 no desenho |
| `"auto"` | Automático onde implementado | Não é valor universal para toda opção |
| `null` em dado | Lacuna | Não converter em zero |
| `null` em opção | Não é um override válido | Remover a chave ou usar Reset/enum Default |

Para restaurar um default, use o membro `...Default` do enum, `Reset` no objeto de
valor ou remova a chave do JSON. Não use `0`, string vazia ou `false` como
substitutos. O modelo preserva valores JSON, mas a interpretação de
todos os tipos/uniões do ECharts ainda não foi implementada.

## Três níveis de validação

1. `Options.JSON := ...`: parse, schema aninhado, tipos e valores validados por
   `TDACChartTypes.Validate` antes da aplicação.
2. `Chart.LoadJSON(...)`: acrescenta configuração de um engine temporário, capaz de
   rejeitar erros de dados inline/encode antes da troca da configuração do host.
3. Setters tipados e `Subgrupo.JSON`: escrita em cópia, com validação central antes
   da troca. Stores de série usam o schema da série. Falha preserva o estado anterior.

A importação pelo host é o caminho recomendado para editor JSON. Os testes cobrem
rollback de enums, setters numéricos, medidas, gradientes, subobjetos/séries JSON,
limites invertidos e dados/encode inválidos. Não provam rollback de falhas de
alocação ou callbacks após commit, nem homologação manual de todo o Inspector.
Dados de `DataSource` são lidos/configurados posteriormente: a simulação com dados
inline não homologa antecipadamente a fonte que será conectada.

O validador usa listas de chaves por grupo, com mensagens que identificam caminhos
como `series[0]`. Rejeita grupos múltiplos de eixos/grid/dataset, séries fora de
`bar/line/pie`, datasetIndex diferente de zero, `stackStrategy` diferente de
`samesign`, tooltip HTML e tooltip não confinado. `outerBoundsMode`, quando explícito,
admite somente `none`.

Types agora valida também `encode`, estados, `labelLayout`, `labelLine`, rich text,
gradientes e estilos aninhados, incluindo tipos e domínios. **Aceitar uma chave não
comprova fidelidade do desenho.** `xAxisIndex/yAxisIndex` continuam fora do subconjunto.

## Defaults e histórico de divergências

Enums agora expõem `Default` para ausência. Medidas/cores/limites expõem modo e
`IsSpecified`, sem materializar valores do renderer no getter. A tabela registra
as divergências anteriores e o que permanece fora dessa correção de tipos.

| Local | Getter/edição | Consumo pelo desenho |
| --- | --- | --- |
| Cor de título ausente | Agora `Kind=dcfkDefault` | Renderer usa `#3c3c41` |
| `LabelStyle.Show` ausente | Getter compartilhado retorna verdadeiro | Cartesiano oculta; pizza mostra |
| Posição de label ausente | Agora `dcpDefault` | Renderer resolve por família; barra usa inside |
| `Legend.ItemGap` ausente | Getter e renderer usam 10 | Referência 6.1.0 capturada resolve 8; V04 explicita 8 |
| Borda de tooltip ausente | Agora `Kind=dcfkDefault` | Renderer pode escolher cor da série sob o mouse |
| Tipo de série ausente | Agora `dcsDefault` | Renderer usa fallback bar |

O Inspector não deve futuramente materializar um fallback divergente apenas porque
o usuário abriu uma propriedade. A solução deve unificar resolução de defaults,
preservando a distinção entre valor ausente e explícito. Não alterar fixtures para
esconder a diferença.

## Dados inline e dataset JSON

As séries aceitam valores escalares, pares e objetos com `value`, `name` e `id`.
O caminho cartesiano interpreta pares como X/Y; barras horizontais ajustam o papel
da dimensão de categoria. `null` e `"-"` representam ausência. Datas textuais
ISO-8601 são convertidas para milissegundos Unix no caminho temporal.

`dataset.source` aceita matrizes e linhas objeto. `dimensions` admite nomes e
objetos com nome. A detecção automática de cabeçalho é uma heurística: sem dimensões,
primeira célula textual da matriz indica cabeçalho. Use `sourceHeader` e dimensões
explícitos quando a primeira linha de dados também contém texto.

`seriesLayoutBy` seleciona linhas/colunas. O encode pode nomear dimensões ou usar
índices. Encodes em array são limitados a uma dimensão pela validação atual;
não existe composição multidimensional completa. Na ausência de encode, o padrão
parte da dimensão 0 para categoria/X e da dimensão `seriesIndex + 1` para valor.
Pizza resolve `encode.value` antes do encode cartesiano Y.

Exemplo deliberadamente explícito:

```json
{
  "animation": false,
  "dataset": {
    "dimensions": ["MES", "VALOR"],
    "source": [{"MES":"Jan","VALOR":10},{"MES":"Fev","VALOR":null}]
  },
  "xAxis": {"type":"category"},
  "yAxis": {"type":"value"},
  "series": [{"id":"mensal","name":"Mensal","type":"bar",
              "encode":{"x":"MES","y":"VALOR"}}]
}
```

Categorias usam um vetor compartilhado e alinhamento por posição. Não há join
geral por nome entre séries independentes. Reordenar categorias requer atualizar
coerentemente os arrays; nomes iguais não substituem identidades estáveis.

Campo ausente em linha objeto gera erro. Uma posição fora de uma linha matriz pode
resultar em ausência, portanto a validação de matrizes irregulares ainda precisa
ser fortalecida. NULL válido e erro de schema não devem se tornar equivalentes.

## Integração com TDataSource

O runtime fornece o contrato `TDACChartDataSetAdapter` e seu registro. Procura o
primeiro adapter cujo `Supports` aceite a fonte. Sem adapter, gera erro controlado;
não navega silenciosamente o dataset da aplicação.

O adapter deve retornar um cursor independente, que o componente libera depois da
leitura. Os exemplos de [demo](../../../demo-charts/DACChartsDemo.ClientDataSetAdapter.pas)
e [testes](../../../Tests/DACComponentsCharts.ClientDataSetAdapter.pas) usam
`CloneCursor(Source, False, False)` para ClientDataSet. Registram na inicialização,
desregistram e liberam o adapter na finalização. Aplicações consumidoras precisam
incluir/implementar seu adapter; não há registro universal implícito.

A leitura inicia em `First`, percorre campos e constrói snapshot JSON:

| Tipo de campo | Conversão |
| --- | --- |
| NULL | `TJSONNull` |
| Inteiros, float, currency, BCD/FMTBcd | Número via `AsFloat` |
| Date/DateTime/TimeStamp | Unix em milissegundos, caminho marcado como UTC |
| Boolean | Boolean JSON |
| Demais tipos | `AsString` |

Conversão por double não promete precisão decimal financeira arbitrária. Inteiros
acima da precisão exata IEEE-754 e BCD de alta precisão exigem política específica.
`ftTime` isolado não está nesse grupo temporal. O parâmetro UTC pressupõe que a
origem já tenha essa semântica; não descobre automaticamente o fuso do dado.

O snapshot novo substitui o anterior somente após completar a leitura. Eventos de
atividade, mudança de dataset e mudança de registro invalidam os dados. Alterar
aparência ou mover mouse não marca a fonte para nova navegação, mas pode reconstruir
layout/desenho a partir do JSON em memória.

`DataSource` não pertence ao chart; `FreeNotification` limpa a referência quando a
origem é destruída. Filtro, NULL, atualização e preservação do cursor têm testes.
Master/detail, índices complexos e outros provedores não foram homologados por isso.

## Identidade, estado e callbacks

Animação utiliza chave composta pela identidade da série e do ponto. Sem `id`, o
fallback depende de nome/índice. Informe IDs estáveis para atualizações e
reordenações; isso ainda não comprova transições completas de entrada/saída.
Seleção usa outra chave interna dependente de índice/nome, um ponto de manutenção.

`OnPointHover` e `OnPointClick` recebem sender, índices de série/ponto, categoria e
valor double. `OnFormat` recebe nome/valor e texto por referência. Pode ser chamado
mais de uma vez por quadro; mantenha-o puro, rápido e sem navegação de datasets.
`OnDataError` recebe a exceção; não assuma ownership dela. O tratamento atual da
pintura tenta preservar o último front buffer em caso de erro.

Formatadores string suportam substituições locais como `{a}`, `{b}`, `{c}`, `{d}`.
Não executam JavaScript. Estados interativos de legenda/seleção ficam no engine e
não são necessariamente refletidos em `SaveJSON`; exportar configuração não é
exportar uma sessão interativa completa.
