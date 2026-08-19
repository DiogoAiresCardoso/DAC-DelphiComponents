# Fontes de dados do TDACChart

## Escolha explicita

`TDACChart.DataMode` impede mistura acidental entre valores persistidos e dados
data-aware.

```pascal
Chart1.DataMode := cdmManual;       // somente Series.Points
Chart1.DataMode := cdmDataSource;   // somente DataSource
Chart1.DataMode := cdmAuto;         // DataSource quando presente, senao Points
```

Trocar o modo invalida o snapshot inteiro por uma mensagem VCL coalescida. Nenhum
modo faz `Post` automaticamente.

## Valores manuais

Use pontos quando a serie pertence ao formulario, a um dashboard estatico ou a
uma visualizacao que ainda nao possui dataset. `BeginUpdate/EndUpdate` na colecao
de series agrupa alteracoes e produz uma unica revisao visual.

```pascal
Chart1.Series.BeginUpdate;
try
  LSerie := Chart1.Series.Add;
  LSerie.Name := 'Chuva';
  LSerie.ChartType := ctArea;
  LSerie.FillMode := cfLinearGradient;
  LSerie.GradientAngle := 90;
  LSerie.Points.Add.Category := 'Jan';
  LSerie.Points[0].Value := 80;
  LSerie.Points.Add.Category := 'Fev';
  LSerie.Points[1].IsNull := True;
finally
  Chart1.Series.EndUpdate;
end;
```

Para `catTime`, grave o `TDateTime` em `XValue`. Para `catValue`, grave a
coordenada numerica. Em `catCategory`, `Category` e a legenda do eixo.

## TClientDataSet

O adapter oficial usa um `TClientDataSet` clone. O chart nao chama `First`,
`Next`, `Prior`, `Locate` ou `GotoBookmark` no dataset entregue pelo usuario.

```pascal
Chart1.DataMode := cdmDataSource;
Chart1.DataSource := dsSafra;
Chart1.DatasetOptions.Dimensions := 'MES;TONELADAS';
LSerie := Chart1.Series.Add;
LSerie.Name := 'Safra';
LSerie.EncodeX := 'MES';
LSerie.EncodeY := 'TONELADAS';
LSerie.EncodeLabel := 'OBSERVACAO';
LSerie.EncodeTooltip := 'DETALHE';
```

Um `DataSource=nil`, dataset inativo ou dataset vazio produz o estado vazio. Um
dataset cuja classe nao tenha adapter registrado chama `OnDataError`; o controle
mantem a ultima geometria valida e nao toca no cursor original.

## Encodes e validacao

- Bar, line e area podem coexistir somente se as series visiveis tiverem as mesmas
  categorias/X, na mesma ordem.
- Pie e doughnut aceitam uma unica serie visivel, nao aceitam negativo e ignoram
  nulos/zeros ao criar fatias.
- `IsNull` nao e convertido para zero; ele cria lacuna em line/area e remove barra,
  fatia e hit area.
- Falha de conversao e campo ausente sao erros controlados por `OnDataError`.
