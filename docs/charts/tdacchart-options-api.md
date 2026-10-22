# API Options do TDACChart

Guia rápido. A referência detalhada está na [base técnica consolidada](README.md),
especialmente [configuração e dados](manual/03-configuracao-dados.md).

Opções fechadas usam enums/sets de `DAC.Components.Charts.Types`; cores, medidas e
limites são objetos persistentes. [Exemplos da API tipada](manual/11-api-tipada.md).

Esta API substitui ChartType, DataMode, Appearance e a coleção antiga de pontos.
O estado de aceite e os limites estão no [registro atual](consolidation-2026-09-23.md).

```pascal
uses DAC.Components.Charts.Types;

Chart.LoadJSON('{"animation":false,"xAxis":{"type":"category",' +
  '"data":["Jan","Fev","Mar"]},"yAxis":{"type":"value"},' +
  '"tooltip":{"trigger":"axis","confine":true},' +
  '"series":[{"id":"producao","name":"Producao","type":"bar",' +
  '"data":[10,20,null]}]}');

Chart.BeginUpdate;
try
  Chart.Options.Title.Text := 'Producao mensal';
  Chart.Options.Legend.Show := True;
  Chart.Options.Legend.Orient := dcoVertical;
  Chart.Options.Legend.Left.Mode := dcmmRight;
  Chart.Options.Tooltip.Trigger := dctAxis;
  Chart.Options.Series[0].LabelStyle.Show := True;
finally
  Chart.EndUpdate;
end;
JSON := Chart.SaveJSON;
```

O título/subtítulo reserva sua altura nativa mais 12 DIP antes da área cartesiana.
`Grid.Top.SetPixels(100)` mantém uma margem maior; um valor menor que o espaço
necessário é elevado somente no layout, sem reescrever o JSON. A regra não altera
o centro/raio de pizza. [Detalhes](manual/04-geometria-desenho.md).

`Options.JSON` é a representação persistida no DFM; os grupos publicados editam o
mesmo estado. `Assign` e importação/exportação copiam o estado JSON. A validação da
raiz e de subobjetos recusa chaves e valores fora do schema antes da troca do estado.
Chave aceita não significa fidelidade visual completa.
Use `LoadJSON` no host para obter a validação transacional adicional de dados/encode.
Subobjetos possuem `JSON` para configuração ainda sem propriedade Delphi dedicada.

Ausência mantém o default; `0`, `false`, strings em pixels e percentuais são valores
distintos. Para remover um override, use o enum `...Default`, `Reset` no objeto de
valor ou retire a chave no JSON; não substitua por zero.
Eventos `OnFormat`, `OnPointHover`, `OnPointClick` e `OnDataError` são callbacks Delphi.
Não há execução de JavaScript ou HTML.

Dados locais:

```pascal
Chart.LoadJSON('{"animation":false,"dataset":{"dimensions":["MES","VALOR"]},' +
  '"xAxis":{"type":"category"},"yAxis":{"type":"value"},' +
  '"series":[{"type":"bar","encode":{"x":"MES","y":"VALOR"}}]}');
Chart.DataSource := Source;
```

Registre um `TDACChartDataSetAdapter` capaz de fornecer um cursor independente.
O demo inclui adapter TClientDataSet. Outros datasets não são percorridos por
fallback movendo o cursor da aplicação. Campo ausente causa erro; NULL não vira zero.
Alterações da fonte invalidam o snapshot; hover e configuração visual não o releem.

O tema DAC é explícito: aplique `color`, `backgroundColor` e estilos desejados ao
JSON. O TDACChart não acompanha silenciosamente o tema global da suíte.

`CapturePNG` captura o estado final do buffer; `CaptureWindowPNG` lê o DC do controle;
`CaptureScreenPNG` tenta ler seu retângulo no desktop. `CaptureDirectory` registra
quadros apresentados. `MetricsJSON` e `GeometryJSON` são diagnósticos. Esses métodos
não transformam uma captura pontual em comprovação de ausência de cintilação.
