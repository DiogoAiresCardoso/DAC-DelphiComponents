# Catálogo extraído da API

[Índice](../README.md) · [Semântica e limites](03-configuracao-dados.md)

Gerado por `../tools/build_catalog.py`. Declarações estáticas, sem RTTI, compilação ou prova de efeito visual.
Propriedades herdadas republicadas são resolvidas apenas entre as classes locais extraídas.

## Propriedades published

### TDACChartMeasure

Fonte: [Source/Core/DAC.Components.Charts.Types.pas](../../../Source/Core/DAC.Components.Charts.Types.pas), linha 65.

| Propriedade | Declaração / origem | Getter |
| --- | --- | --- |
| `Mode` | `property Mode: TDACChartMeasureMode read GetMode write SetMode stored False;` | `TDACChartMeasure.GetMode` |
| `Value` | `property Value: Double read GetValue write SetValue stored False;` | `TDACChartMeasure.GetValue` |

### TDACChartAxisLimit

Fonte: [Source/Core/DAC.Components.Charts.Types.pas](../../../Source/Core/DAC.Components.Charts.Types.pas), linha 78.

| Propriedade | Declaração / origem | Getter |
| --- | --- | --- |
| `Mode` | `property Mode: TDACChartLimitMode read GetMode write SetMode stored False;` | `TDACChartAxisLimit.GetMode` |
| `Value` | `property Value: Double read GetValue write SetValue stored False;` | `TDACChartAxisLimit.GetValue` |

### TDACChartFill

Fonte: [Source/Core/DAC.Components.Charts.Types.pas](../../../Source/Core/DAC.Components.Charts.Types.pas), linha 88.

| Propriedade | Declaração / origem | Getter |
| --- | --- | --- |
| `Kind` | `property Kind: TDACChartFillKind read GetKind write SetKind stored False;` | `TDACChartFill.GetKind` |
| `Color` | `property Color: TAlphaColor read GetColor write SetColor stored False;` | `TDACChartFill.GetColor` |
| `StartColor` | `property StartColor: TAlphaColor read GetStartColor write SetStartColor stored False;` | `TDACChartFill.GetStartColor` |
| `EndColor` | `property EndColor: TAlphaColor read GetEndColor write SetEndColor stored False;` | `TDACChartFill.GetEndColor` |
| `X` | `property X: Double index 0 read GetCoordinate write SetCoordinate stored False;` | `TDACChartFill.GetCoordinate` |
| `Y` | `property Y: Double index 1 read GetCoordinate write SetCoordinate stored False;` | `TDACChartFill.GetCoordinate` |
| `X2` | `property X2: Double index 2 read GetCoordinate write SetCoordinate stored False;` | `TDACChartFill.GetCoordinate` |
| `Y2` | `property Y2: Double index 3 read GetCoordinate write SetCoordinate stored False;` | `TDACChartFill.GetCoordinate` |
| `Radius` | `property Radius: Double index 4 read GetCoordinate write SetCoordinate stored False;` | `TDACChartFill.GetCoordinate` |

### TDACChartOptionNode

Fonte: [Source/Controls/DAC.Components.Charts.Options.pas](../../../Source/Controls/DAC.Components.Charts.Options.pas), linha 10.

| Propriedade | Declaração / origem | Getter |
| --- | --- | --- |
| `JSON` | `property JSON: string read GetJSON write SetJSON;` | `TDACChartOptionNode.GetJSON` |

### TDACChartTitleOptions

Fonte: [Source/Controls/DAC.Components.Charts.Options.pas](../../../Source/Controls/DAC.Components.Charts.Options.pas), linha 86.

| Propriedade | Declaração / origem | Getter |
| --- | --- | --- |
| `Show` | `property Show: Boolean read GetShow write SetShow stored False;` | `TDACChartTextOptions.GetShow` |
| `Text` | `property Text: string read GetText write SetText stored False;` | `TDACChartTextOptions.GetText` |
| `Subtext` | `property Subtext: string read GetSubtext write SetSubtext stored False;` | `TDACChartTextOptions.GetSubtext` |
| `FontFamily` | `property FontFamily: string read GetFontFamily write SetFontFamily stored False;` | `TDACChartTextOptions.GetFontFamily` |
| `FontWeight` | `property FontWeight: Integer read GetFontWeight write SetFontWeight stored False;` | `TDACChartTextOptions.GetFontWeight` |
| `FontSize` | `property FontSize: Double read GetFontSize write SetFontSize stored False;` | `TDACChartTextOptions.GetFontSize` |
| `Color` | `property Color: TDACChartFill read GetColor write SetColor stored False;` | `TDACChartTextOptions.GetColor` |
| `Left` | `property Left: TDACChartMeasure read GetLeft write SetLeft stored False;` | `TDACChartTextOptions.GetLeft` |
| `Top` | `property Top: TDACChartMeasure read GetTop write SetTop stored False;` | `TDACChartTextOptions.GetTop` |

### TDACChartLabelOptions

Fonte: [Source/Controls/DAC.Components.Charts.Options.pas](../../../Source/Controls/DAC.Components.Charts.Options.pas), linha 98.

| Propriedade | Declaração / origem | Getter |
| --- | --- | --- |
| `FontStyle` | `property FontStyle: TDACChartFontStyle read GetFontStyle write SetFontStyle stored False;` | `TDACChartLabelOptions.GetFontStyle` |
| `TextAlign` | `property TextAlign: TDACChartTextAlign read GetTextAlign write SetTextAlign stored False;` | `TDACChartLabelOptions.GetTextAlign` |
| `VerticalAlign` | `property VerticalAlign: TDACChartVerticalAlign read GetVerticalAlign write SetVerticalAlign stored False;` | `TDACChartLabelOptions.GetVerticalAlign` |
| `Overflow` | `property Overflow: TDACChartOverflow read GetOverflow write SetOverflow stored False;` | `TDACChartLabelOptions.GetOverflow` |
| `Show` | `property Show: Boolean read GetShow write SetShow stored False;` | `TDACChartTextOptions.GetShow` |
| `FontFamily` | `property FontFamily: string read GetFontFamily write SetFontFamily stored False;` | `TDACChartTextOptions.GetFontFamily` |
| `FontWeight` | `property FontWeight: Integer read GetFontWeight write SetFontWeight stored False;` | `TDACChartTextOptions.GetFontWeight` |
| `FontSize` | `property FontSize: Double read GetFontSize write SetFontSize stored False;` | `TDACChartTextOptions.GetFontSize` |
| `Color` | `property Color: TDACChartFill read GetColor write SetColor stored False;` | `TDACChartTextOptions.GetColor` |
| `Position` | `property Position: TDACChartLabelPosition read GetPosition write SetPosition stored False;` | `TDACChartTextOptions.GetPosition` |
| `Formatter` | `property Formatter: string read GetFormatter write SetFormatter stored False;` | `TDACChartTextOptions.GetFormatter` |
| `Rotate` | `property Rotate: Double read GetRotate write SetRotate stored False;` | `TDACChartTextOptions.GetRotate` |
| `Distance` | `property Distance: Double read GetDistance write SetDistance stored False;` | `TDACChartTextOptions.GetDistance` |

### TDACChartAxisOptions

Fonte: [Source/Controls/DAC.Components.Charts.Options.pas](../../../Source/Controls/DAC.Components.Charts.Options.pas), linha 124.

| Propriedade | Declaração / origem | Getter |
| --- | --- | --- |
| `Show` | `property Show: Boolean read GetShow write SetShow stored False;` | `TDACChartAxisOptions.GetShow` |
| `AxisType` | `property AxisType: TDACChartAxisType read GetAxisType write SetAxisType stored False;` | `TDACChartAxisOptions.GetAxisType` |
| `Min` | `property Min: TDACChartAxisLimit read GetMin write SetMin stored False;` | `TDACChartAxisOptions.GetMin` |
| `Max` | `property Max: TDACChartAxisLimit read GetMax write SetMax stored False;` | `TDACChartAxisOptions.GetMax` |
| `Inverse` | `property Inverse: Boolean read GetInverse write SetInverse stored False;` | `TDACChartAxisOptions.GetInverse` |
| `BoundaryGap` | `property BoundaryGap: Boolean read GetBoundaryGap write SetBoundaryGap stored False;` | `TDACChartAxisOptions.GetBoundaryGap` |
| `SplitNumber` | `property SplitNumber: Double read GetSplitNumber write SetSplitNumber stored False;` | `TDACChartAxisOptions.GetSplitNumber` |
| `Name` | `property Name: string read GetName write SetName stored False;` | `TDACChartAxisOptions.GetName` |

### TDACChartStyleOptions

Fonte: [Source/Controls/DAC.Components.Charts.Options.pas](../../../Source/Controls/DAC.Components.Charts.Options.pas), linha 153.

| Propriedade | Declaração / origem | Getter |
| --- | --- | --- |
| `LineType` | `property LineType: TDACChartLineType read GetLineType write SetLineType stored False;` | `TDACChartStyleOptions.GetLineType` |
| `Color` | `property Color: TDACChartFill read GetColor write SetColor stored False;` | `TDACChartStyleOptions.GetColor` |
| `Opacity` | `property Opacity: Double read GetOpacity write SetOpacity stored False;` | `TDACChartStyleOptions.GetOpacity` |
| `Width` | `property Width: Double read GetWidth write SetWidth stored False;` | `TDACChartStyleOptions.GetWidth` |
| `BorderColor` | `property BorderColor: TDACChartFill read GetBorderColor write SetBorderColor stored False;` | `TDACChartStyleOptions.GetBorderColor` |
| `BorderWidth` | `property BorderWidth: Double read GetBorderWidth write SetBorderWidth stored False;` | `TDACChartStyleOptions.GetBorderWidth` |
| `BorderRadius` | `property BorderRadius: Double read GetBorderRadius write SetBorderRadius stored False;` | `TDACChartStyleOptions.GetBorderRadius` |
| `ShadowBlur` | `property ShadowBlur: Double read GetShadowBlur write SetShadowBlur stored False;` | `TDACChartStyleOptions.GetShadowBlur` |
| `ShadowColor` | `property ShadowColor: TDACChartFill read GetShadowColor write SetShadowColor stored False;` | `TDACChartStyleOptions.GetShadowColor` |
| `ShadowOffsetX` | `property ShadowOffsetX: Double read GetShadowOffsetX write SetShadowOffsetX stored False;` | `TDACChartStyleOptions.GetShadowOffsetX` |
| `ShadowOffsetY` | `property ShadowOffsetY: Double read GetShadowOffsetY write SetShadowOffsetY stored False;` | `TDACChartStyleOptions.GetShadowOffsetY` |

### TDACChartLegendOptions

Fonte: [Source/Controls/DAC.Components.Charts.Options.pas](../../../Source/Controls/DAC.Components.Charts.Options.pas), linha 192.

| Propriedade | Declaração / origem | Getter |
| --- | --- | --- |
| `SelectedMode` | `property SelectedMode: TDACChartSelection read GetSelectedMode write SetSelectedMode stored False;` | `TDACChartLegendOptions.GetSelectedMode` |
| `Show` | `property Show: Boolean read GetShow write SetShow stored False;` | `TDACChartLegendOptions.GetShow` |
| `LegendType` | `property LegendType: TDACChartLegendType read GetLegendType write SetLegendType stored False;` | `TDACChartLegendOptions.GetLegendType` |
| `Orient` | `property Orient: TDACChartOrientation read GetOrient write SetOrient stored False;` | `TDACChartLegendOptions.GetOrient` |
| `Left` | `property Left: TDACChartMeasure read GetLeft write SetLeft stored False;` | `TDACChartLegendOptions.GetLeft` |
| `Top` | `property Top: TDACChartMeasure read GetTop write SetTop stored False;` | `TDACChartLegendOptions.GetTop` |
| `ItemGap` | `property ItemGap: Double read GetItemGap write SetItemGap stored False;` | `TDACChartLegendOptions.GetItemGap` |
| `ItemWidth` | `property ItemWidth: Double read GetItemWidth write SetItemWidth stored False;` | `TDACChartLegendOptions.GetItemWidth` |
| `ItemHeight` | `property ItemHeight: Double read GetItemHeight write SetItemHeight stored False;` | `TDACChartLegendOptions.GetItemHeight` |

### TDACChartTooltipOptions

Fonte: [Source/Controls/DAC.Components.Charts.Options.pas](../../../Source/Controls/DAC.Components.Charts.Options.pas), linha 225.

| Propriedade | Declaração / origem | Getter |
| --- | --- | --- |
| `RenderMode` | `property RenderMode: TDACChartRenderMode read GetRenderMode write SetRenderMode stored False;` | `TDACChartTooltipOptions.GetRenderMode` |
| `PointerType` | `property PointerType: TDACChartPointerType read GetPointerType write SetPointerType stored False;` | `TDACChartTooltipOptions.GetPointerType` |
| `Show` | `property Show: Boolean read GetShow write SetShow stored False;` | `TDACChartTooltipOptions.GetShow` |
| `Trigger` | `property Trigger: TDACChartTooltipTrigger read GetTrigger write SetTrigger stored False;` | `TDACChartTooltipOptions.GetTrigger` |
| `TriggerOn` | `property TriggerOn: TDACChartTooltipEvents read GetTriggerOn write SetTriggerOn stored False;` | `TDACChartTooltipOptions.GetTriggerOn` |
| `Confine` | `property Confine: Boolean read GetConfine write SetConfine stored False;` | `TDACChartTooltipOptions.GetConfine` |
| `Formatter` | `property Formatter: string read GetFormatter write SetFormatter stored False;` | `TDACChartTooltipOptions.GetFormatter` |
| `ShowDelay` | `property ShowDelay: Double read GetShowDelay write SetShowDelay stored False;` | `TDACChartTooltipOptions.GetShowDelay` |
| `HideDelay` | `property HideDelay: Double read GetHideDelay write SetHideDelay stored False;` | `TDACChartTooltipOptions.GetHideDelay` |
| `BackgroundColor` | `property BackgroundColor: TDACChartFill read GetBackgroundColor write SetBackgroundColor stored False;` | `TDACChartTooltipOptions.GetBackgroundColor` |
| `BorderColor` | `property BorderColor: TDACChartFill read GetBorderColor write SetBorderColor stored False;` | `TDACChartTooltipOptions.GetBorderColor` |
| `Padding` | `property Padding: Double read GetPadding write SetPadding stored False;` | `TDACChartTooltipOptions.GetPadding` |

### TDACChartGridOptions

Fonte: [Source/Controls/DAC.Components.Charts.Options.pas](../../../Source/Controls/DAC.Components.Charts.Options.pas), linha 267.

| Propriedade | Declaração / origem | Getter |
| --- | --- | --- |
| `Left` | `property Left: TDACChartMeasure read GetLeft write SetLeft stored False;` | `TDACChartGridOptions.GetLeft` |
| `Right` | `property Right: TDACChartMeasure read GetRight write SetRight stored False;` | `TDACChartGridOptions.GetRight` |
| `Top` | `property Top: TDACChartMeasure read GetTop write SetTop stored False;` | `TDACChartGridOptions.GetTop` |
| `Bottom` | `property Bottom: TDACChartMeasure read GetBottom write SetBottom stored False;` | `TDACChartGridOptions.GetBottom` |
| `OuterBoundsMode` | `property OuterBoundsMode: TDACChartOuterBoundsMode read GetOuterBoundsMode write SetOuterBoundsMode stored False;` | `TDACChartGridOptions.GetOuterBoundsMode` |

### TDACChartOptionSeries

Fonte: [Source/Controls/DAC.Components.Charts.Options.pas](../../../Source/Controls/DAC.Components.Charts.Options.pas), linha 287.

| Propriedade | Declaração / origem | Getter |
| --- | --- | --- |
| `LayoutBy` | `property LayoutBy: TDACChartSeriesLayout read GetLayoutBy write SetLayoutBy stored False;` | `TDACChartOptionSeries.GetLayoutBy` |
| `Step` | `property Step: TDACChartStep read GetStep write SetStep stored False;` | `TDACChartOptionSeries.GetStep` |
| `SmoothMonotone` | `property SmoothMonotone: TDACChartMonotone read GetSmoothMonotone write SetSmoothMonotone stored False;` | `TDACChartOptionSeries.GetSmoothMonotone` |
| `Symbol` | `property Symbol: TDACChartSymbol read GetSymbol write SetSymbol stored False;` | `TDACChartOptionSeries.GetSymbol` |
| `SelectedMode` | `property SelectedMode: TDACChartSelection read GetSelectedMode write SetSelectedMode stored False;` | `TDACChartOptionSeries.GetSelectedMode` |
| `StackStrategy` | `property StackStrategy: TDACChartStackStrategy read GetStackStrategy write SetStackStrategy stored False;` | `TDACChartOptionSeries.GetStackStrategy` |
| `Focus` | `property Focus: TDACChartFocus read GetFocus write SetFocus stored False;` | `TDACChartOptionSeries.GetFocus` |
| `JSON` | `property JSON: string read GetJSON write SetJSON;` | `TDACChartOptionSeries.GetJSON` |
| `Name` | `property Name: string read GetName write SetName stored False;` | `TDACChartOptionSeries.GetName` |
| `Kind` | `property Kind: TDACChartSeriesType read GetKind write SetKind stored False;` | `TDACChartOptionSeries.GetKind` |
| `Stack` | `property Stack: string read GetStack write SetStack stored False;` | `TDACChartOptionSeries.GetStack` |
| `ItemStyle` | `property ItemStyle: TDACChartStyleOptions read FItemStyle write SetItemStyle stored False;` | `TDACChartOptionSeries.FItemStyle` |
| `LineStyle` | `property LineStyle: TDACChartStyleOptions read FLineStyle write SetLineStyle stored False;` | `TDACChartOptionSeries.FLineStyle` |
| `AreaStyle` | `property AreaStyle: TDACChartStyleOptions read FAreaStyle write SetAreaStyle stored False;` | `TDACChartOptionSeries.FAreaStyle` |
| `LabelStyle` | `property LabelStyle: TDACChartLabelOptions read FLabel write SetLabel stored False;` | `TDACChartOptionSeries.FLabel` |

### TDACChartDatasetOptions

Fonte: [Source/Controls/DAC.Components.Charts.Options.pas](../../../Source/Controls/DAC.Components.Charts.Options.pas), linha 356.

| Propriedade | Declaração / origem | Getter |
| --- | --- | --- |
| `SourceHeader` | `property SourceHeader: TDACChartSwitch read GetSourceHeader write SetSourceHeader stored False;` | `TDACChartDatasetOptions.GetSourceHeader` |

### TDACChartOptions

Fonte: [Source/Controls/DAC.Components.Charts.Options.pas](../../../Source/Controls/DAC.Components.Charts.Options.pas), linha 363.

| Propriedade | Declaração / origem | Getter |
| --- | --- | --- |
| `AnimationMode` | `property AnimationMode: TDACChartSwitch read GetAnimationMode write SetAnimationMode stored False;` | `TDACChartOptions.GetAnimationMode` |
| `AnimationEasing` | `property AnimationEasing: TDACChartEasing read GetAnimationEasing write SetAnimationEasing stored False;` | `TDACChartOptions.GetAnimationEasing` |
| `AnimationEasingUpdate` | `property AnimationEasingUpdate: TDACChartEasing read GetAnimationEasingUpdate write SetAnimationEasingUpdate stored False;` | `TDACChartOptions.GetAnimationEasingUpdate` |
| `JSON` | `property JSON: string read GetJSON write SetJSON;` | `TDACChartOptions.GetJSON` |
| `Series` | `property Series: TDACChartOptionSeriesCollection read FSeries write SetSeries stored False;` | `TDACChartOptions.FSeries` |
| `Dataset` | `property Dataset: TDACChartDatasetOptions read FDataset write SetDataset stored False;` | `TDACChartOptions.FDataset` |
| `Title` | `property Title: TDACChartTitleOptions read FTitle write SetTitle stored False;` | `TDACChartOptions.FTitle` |
| `XAxis` | `property XAxis: TDACChartAxisOptions read FXAxis write SetXAxis stored False;` | `TDACChartOptions.FXAxis` |
| `YAxis` | `property YAxis: TDACChartAxisOptions read FYAxis write SetYAxis stored False;` | `TDACChartOptions.FYAxis` |
| `Grid` | `property Grid: TDACChartGridOptions read FGrid write SetGrid stored False;` | `TDACChartOptions.FGrid` |
| `Legend` | `property Legend: TDACChartLegendOptions read FLegend write SetLegend stored False;` | `TDACChartOptions.FLegend` |
| `Tooltip` | `property Tooltip: TDACChartTooltipOptions read FTooltip write SetTooltip stored False;` | `TDACChartOptions.FTooltip` |

### TDACChart

Fonte: [Source/Controls/DAC.Components.Controls.Charts.pas](../../../Source/Controls/DAC.Components.Controls.Charts.pas), linha 32.

| Propriedade | Declaração / origem | Getter |
| --- | --- | --- |
| `Align` | `property Align;` | `herdado VCL / não extraído` |
| `Anchors` | `property Anchors;` | `herdado VCL / não extraído` |
| `Constraints` | `property Constraints;` | `herdado VCL / não extraído` |
| `Enabled` | `property Enabled;` | `herdado VCL / não extraído` |
| `Visible` | `property Visible;` | `herdado VCL / não extraído` |
| `TabOrder` | `property TabOrder;` | `herdado VCL / não extraído` |
| `TabStop` | `property TabStop default True;` | `herdado VCL / não extraído` |
| `Options` | `property Options: TDACChartOptions read FOptions write SetOptions;` | `TDACChart.FOptions` |
| `DataSource` | `property DataSource: TDataSource read FDataSource write SetDataSource;` | `TDACChart.FDataSource` |
| `OnClick` | `property OnClick;` | `herdado VCL / não extraído` |
| `OnPointHover` | `property OnPointHover: TDACChartPointEvent read FOnPointHover write FOnPointHover;` | `TDACChart.FOnPointHover` |
| `OnPointClick` | `property OnPointClick: TDACChartPointEvent read FOnPointClick write FOnPointClick;` | `TDACChart.FOnPointClick` |
| `OnFormat` | `property OnFormat: TDACChartFormatEvent read FOnFormat write FOnFormat;` | `TDACChart.FOnFormat` |
| `OnDataError` | `property OnDataError: TDACChartDataErrorEvent read FOnDataError write FOnDataError;` | `TDACChart.FOnDataError` |

## Corpos dos getters de opções

Os fallbacks abaixo pertencem aos getters. Defaults contextuais do renderer podem divergir; ver capítulo 03.

### TDACChartOptionNode.GetJSON

Linha 515 de Options.pas.

```pascal
function TDACChartOptionNode.GetJSON: string;
var V: TJSONValue;
begin V := FStore.Read(FPath); if V = nil then Result := '{}' else Result := V.ToJSON; end;
```

### TDACChartTextOptions.GetShow

Linha 527 de Options.pas.

```pascal
function TDACChartTextOptions.GetShow: Boolean;
begin Result := CB(FStore.Read(Path('show')), True); end;
```

### TDACChartTextOptions.GetText

Linha 531 de Options.pas.

```pascal
function TDACChartTextOptions.GetText: string;
begin Result := CS(FStore.Read(Path('text')), ''); end;
```

### TDACChartTextOptions.GetSubtext

Linha 535 de Options.pas.

```pascal
function TDACChartTextOptions.GetSubtext: string;
begin Result := CS(FStore.Read(Path('subtext')), ''); end;
```

### TDACChartTextOptions.GetFontFamily

Linha 539 de Options.pas.

```pascal
function TDACChartTextOptions.GetFontFamily: string;
begin Result := CS(FStore.Read(Path('fontFamily')), 'Arial'); end;
```

### TDACChartTextOptions.GetFontSize

Linha 543 de Options.pas.

```pascal
function TDACChartTextOptions.GetFontSize: Double;
begin if FPath='title' then Result := CN(FStore.Read(Path('fontSize')), 18)
  else Result := CN(FStore.Read(Path('fontSize')), 12); end;
```

### TDACChartTextOptions.GetColor

Linha 548 de Options.pas.

```pascal
function TDACChartTextOptions.GetColor: TDACChartFill;
begin Result := TDACChartFill(Bound('color',TDACChartFill)); end;
```

### TDACChartTextOptions.GetLeft

Linha 552 de Options.pas.

```pascal
function TDACChartTextOptions.GetLeft: TDACChartMeasure;
begin Result := TDACChartMeasure(Bound('left',TDACChartMeasure)); end;
```

### TDACChartTextOptions.GetTop

Linha 556 de Options.pas.

```pascal
function TDACChartTextOptions.GetTop: TDACChartMeasure;
begin Result := TDACChartMeasure(Bound('top',TDACChartMeasure)); end;
```

### TDACChartTextOptions.GetPosition

Linha 560 de Options.pas.

```pascal
function TDACChartTextOptions.GetPosition: TDACChartLabelPosition;
begin Result := TDACChartTypes.LabelPosition(FStore.Read(Path('position')),Path('position')); end;
```

### TDACChartTextOptions.GetFormatter

Linha 564 de Options.pas.

```pascal
function TDACChartTextOptions.GetFormatter: string;
begin Result := CS(FStore.Read(Path('formatter')), ''); end;
```

### TDACChartTextOptions.GetRotate

Linha 568 de Options.pas.

```pascal
function TDACChartTextOptions.GetRotate: Double;
begin Result := CN(FStore.Read(Path('rotate')), 0); end;
```

### TDACChartTextOptions.GetDistance

Linha 572 de Options.pas.

```pascal
function TDACChartTextOptions.GetDistance: Double;
begin Result := CN(FStore.Read(Path('distance')), 5); end;
```

### TDACChartAxisOptions.GetShow

Linha 576 de Options.pas.

```pascal
function TDACChartAxisOptions.GetShow: Boolean;
begin Result := CB(FStore.Read(Path('show')), True); end;
```

### TDACChartAxisOptions.GetAxisType

Linha 580 de Options.pas.

```pascal
function TDACChartAxisOptions.GetAxisType: TDACChartAxisType;
begin Result := TDACChartTypes.AxisType(FStore.Read(Path('type')),Path('type')); end;
```

### TDACChartAxisOptions.GetMin

Linha 584 de Options.pas.

```pascal
function TDACChartAxisOptions.GetMin: TDACChartAxisLimit;
begin Result := TDACChartAxisLimit(Bound('min',TDACChartAxisLimit)); end;
```

### TDACChartAxisOptions.GetMax

Linha 588 de Options.pas.

```pascal
function TDACChartAxisOptions.GetMax: TDACChartAxisLimit;
begin Result := TDACChartAxisLimit(Bound('max',TDACChartAxisLimit)); end;
```

### TDACChartAxisOptions.GetInverse

Linha 592 de Options.pas.

```pascal
function TDACChartAxisOptions.GetInverse: Boolean;
begin Result := CB(FStore.Read(Path('inverse')), False); end;
```

### TDACChartAxisOptions.GetBoundaryGap

Linha 596 de Options.pas.

```pascal
function TDACChartAxisOptions.GetBoundaryGap: Boolean;
begin Result := CB(FStore.Read(Path('boundaryGap')), True); end;
```

### TDACChartAxisOptions.GetSplitNumber

Linha 600 de Options.pas.

```pascal
function TDACChartAxisOptions.GetSplitNumber: Double;
begin Result := CN(FStore.Read(Path('splitNumber')), 5); end;
```

### TDACChartAxisOptions.GetName

Linha 604 de Options.pas.

```pascal
function TDACChartAxisOptions.GetName: string;
begin Result := CS(FStore.Read(Path('name')), ''); end;
```

### TDACChartStyleOptions.GetColor

Linha 608 de Options.pas.

```pascal
function TDACChartStyleOptions.GetColor: TDACChartFill;
begin Result := TDACChartFill(Bound('color',TDACChartFill)); end;
```

### TDACChartStyleOptions.GetOpacity

Linha 612 de Options.pas.

```pascal
function TDACChartStyleOptions.GetOpacity: Double;
begin Result := CN(FStore.Read(Path('opacity')), 1); end;
```

### TDACChartStyleOptions.GetWidth

Linha 616 de Options.pas.

```pascal
function TDACChartStyleOptions.GetWidth: Double;
begin Result := CN(FStore.Read(Path('width')), 2); end;
```

### TDACChartStyleOptions.GetBorderColor

Linha 620 de Options.pas.

```pascal
function TDACChartStyleOptions.GetBorderColor: TDACChartFill;
begin Result := TDACChartFill(Bound('borderColor',TDACChartFill)); end;
```

### TDACChartStyleOptions.GetBorderWidth

Linha 624 de Options.pas.

```pascal
function TDACChartStyleOptions.GetBorderWidth: Double;
begin Result := CN(FStore.Read(Path('borderWidth')), 0); end;
```

### TDACChartStyleOptions.GetBorderRadius

Linha 628 de Options.pas.

```pascal
function TDACChartStyleOptions.GetBorderRadius: Double;
begin Result := CN(FStore.Read(Path('borderRadius')), 0); end;
```

### TDACChartStyleOptions.GetShadowBlur

Linha 632 de Options.pas.

```pascal
function TDACChartStyleOptions.GetShadowBlur: Double;
begin Result := CN(FStore.Read(Path('shadowBlur')), 0); end;
```

### TDACChartStyleOptions.GetShadowColor

Linha 636 de Options.pas.

```pascal
function TDACChartStyleOptions.GetShadowColor: TDACChartFill;
begin Result := TDACChartFill(Bound('shadowColor',TDACChartFill)); end;
```

### TDACChartStyleOptions.GetShadowOffsetX

Linha 640 de Options.pas.

```pascal
function TDACChartStyleOptions.GetShadowOffsetX: Double;
begin Result := CN(FStore.Read(Path('shadowOffsetX')), 0); end;
```

### TDACChartStyleOptions.GetShadowOffsetY

Linha 644 de Options.pas.

```pascal
function TDACChartStyleOptions.GetShadowOffsetY: Double;
begin Result := CN(FStore.Read(Path('shadowOffsetY')), 0); end;
```

### TDACChartLegendOptions.GetShow

Linha 648 de Options.pas.

```pascal
function TDACChartLegendOptions.GetShow: Boolean;
begin Result := CB(FStore.Read(Path('show')), True); end;
```

### TDACChartLegendOptions.GetLegendType

Linha 652 de Options.pas.

```pascal
function TDACChartLegendOptions.GetLegendType: TDACChartLegendType;
begin Result := TDACChartTypes.LegendType(FStore.Read(Path('type')),Path('type')); end;
```

### TDACChartLegendOptions.GetOrient

Linha 656 de Options.pas.

```pascal
function TDACChartLegendOptions.GetOrient: TDACChartOrientation;
begin Result := TDACChartTypes.Orientation(FStore.Read(Path('orient')),Path('orient')); end;
```

### TDACChartLegendOptions.GetLeft

Linha 660 de Options.pas.

```pascal
function TDACChartLegendOptions.GetLeft: TDACChartMeasure;
begin Result := TDACChartMeasure(Bound('left',TDACChartMeasure)); end;
```

### TDACChartLegendOptions.GetTop

Linha 664 de Options.pas.

```pascal
function TDACChartLegendOptions.GetTop: TDACChartMeasure;
begin Result := TDACChartMeasure(Bound('top',TDACChartMeasure)); end;
```

### TDACChartLegendOptions.GetItemGap

Linha 668 de Options.pas.

```pascal
function TDACChartLegendOptions.GetItemGap: Double;
begin Result := CN(FStore.Read(Path('itemGap')), 10); end;
```

### TDACChartLegendOptions.GetItemWidth

Linha 672 de Options.pas.

```pascal
function TDACChartLegendOptions.GetItemWidth: Double;
begin Result := CN(FStore.Read(Path('itemWidth')), 25); end;
```

### TDACChartLegendOptions.GetItemHeight

Linha 676 de Options.pas.

```pascal
function TDACChartLegendOptions.GetItemHeight: Double;
begin Result := CN(FStore.Read(Path('itemHeight')), 14); end;
```

### TDACChartTooltipOptions.GetShow

Linha 680 de Options.pas.

```pascal
function TDACChartTooltipOptions.GetShow: Boolean;
begin Result := CB(FStore.Read(Path('show')), True); end;
```

### TDACChartTooltipOptions.GetTrigger

Linha 684 de Options.pas.

```pascal
function TDACChartTooltipOptions.GetTrigger: TDACChartTooltipTrigger;
begin Result := TDACChartTypes.TooltipTrigger(FStore.Read(Path('trigger')),Path('trigger')); end;
```

### TDACChartTooltipOptions.GetTriggerOn

Linha 688 de Options.pas.

```pascal
function TDACChartTooltipOptions.GetTriggerOn: TDACChartTooltipEvents;
begin Result := TDACChartTypes.TooltipEvents(FStore.Read(Path('triggerOn')),Path('triggerOn')); end;
```

### TDACChartTooltipOptions.GetConfine

Linha 692 de Options.pas.

```pascal
function TDACChartTooltipOptions.GetConfine: Boolean;
begin Result := CB(FStore.Read(Path('confine')), True); end;
```

### TDACChartTooltipOptions.GetFormatter

Linha 696 de Options.pas.

```pascal
function TDACChartTooltipOptions.GetFormatter: string;
begin Result := CS(FStore.Read(Path('formatter')), ''); end;
```

### TDACChartTooltipOptions.GetShowDelay

Linha 700 de Options.pas.

```pascal
function TDACChartTooltipOptions.GetShowDelay: Double;
begin Result := CN(FStore.Read(Path('showDelay')), 0); end;
```

### TDACChartTooltipOptions.GetHideDelay

Linha 704 de Options.pas.

```pascal
function TDACChartTooltipOptions.GetHideDelay: Double;
begin Result := CN(FStore.Read(Path('hideDelay')), 100); end;
```

### TDACChartTooltipOptions.GetBackgroundColor

Linha 708 de Options.pas.

```pascal
function TDACChartTooltipOptions.GetBackgroundColor: TDACChartFill;
begin Result := TDACChartFill(Bound('backgroundColor',TDACChartFill)); end;
```

### TDACChartTooltipOptions.GetBorderColor

Linha 712 de Options.pas.

```pascal
function TDACChartTooltipOptions.GetBorderColor: TDACChartFill;
begin Result := TDACChartFill(Bound('borderColor',TDACChartFill)); end;
```

### TDACChartTooltipOptions.GetPadding

Linha 716 de Options.pas.

```pascal
function TDACChartTooltipOptions.GetPadding: Double;
begin Result := CN(FStore.Read(Path('padding')), 10); end;
```

### TDACChartGridOptions.GetLeft

Linha 720 de Options.pas.

```pascal
function TDACChartGridOptions.GetLeft: TDACChartMeasure;
begin Result := TDACChartMeasure(Bound('left',TDACChartMeasure)); end;
```

### TDACChartGridOptions.GetRight

Linha 724 de Options.pas.

```pascal
function TDACChartGridOptions.GetRight: TDACChartMeasure;
begin Result := TDACChartMeasure(Bound('right',TDACChartMeasure)); end;
```

### TDACChartGridOptions.GetTop

Linha 728 de Options.pas.

```pascal
function TDACChartGridOptions.GetTop: TDACChartMeasure;
begin Result := TDACChartMeasure(Bound('top',TDACChartMeasure)); end;
```

### TDACChartGridOptions.GetBottom

Linha 732 de Options.pas.

```pascal
function TDACChartGridOptions.GetBottom: TDACChartMeasure;
begin Result := TDACChartMeasure(Bound('bottom',TDACChartMeasure)); end;
```

### TDACChartGridOptions.GetOuterBoundsMode

Linha 736 de Options.pas.

```pascal
function TDACChartGridOptions.GetOuterBoundsMode: TDACChartOuterBoundsMode;
begin Result := TDACChartTypes.OuterBoundsMode(FStore.Read(Path('outerBoundsMode')),Path('outerBoundsMode')); end;
```

### TDACChartOptionSeries.GetJSON

Linha 753 de Options.pas.

```pascal
function TDACChartOptionSeries.GetJSON: string;
begin Result := FStore.Root.ToJSON; end;
```

### TDACChartOptionSeries.GetDisplayName

Linha 757 de Options.pas.

```pascal
function TDACChartOptionSeries.GetDisplayName: string;
var V: TJSONValue;
begin
  Result:=GetName;
  if Result='' then begin
    V:=TDACChartTypes.SeriesTypeJSON(GetKind);
    try if V=nil then Result:='Series' else Result:=V.Value; finally V.Free; end;
  end;
end;
```

### TDACChartOptionSeries.GetName

Linha 768 de Options.pas.

```pascal
function TDACChartOptionSeries.GetName: string;
begin Result := CS(FStore.Read('name')); end;
```

### TDACChartOptionSeries.GetKind

Linha 772 de Options.pas.

```pascal
function TDACChartOptionSeries.GetKind: TDACChartSeriesType;
begin Result := TDACChartTypes.SeriesType(FStore.Read('type'),'type'); end;
```

### TDACChartOptionSeries.GetStack

Linha 776 de Options.pas.

```pascal
function TDACChartOptionSeries.GetStack: string;
begin Result := CS(FStore.Read('stack')); end;
```

### TDACChartOptionSeriesCollection.GetItem

Linha 792 de Options.pas.

```pascal
function TDACChartOptionSeriesCollection.GetItem(I: Integer): TDACChartOptionSeries;
begin Result := TDACChartOptionSeries(inherited Items[I]); end;
```

### TDACChartOptions.GetJSON

Linha 834 de Options.pas.

```pascal
function TDACChartOptions.GetJSON: string;
var O: TJSONObject;
begin O := Clone; try Result := O.ToJSON; finally O.Free; end; end;
```

### TDACChartStyleOptions.GetLineType

Linha 870 de Options.pas.

```pascal
function TDACChartStyleOptions.GetLineType: TDACChartLineType;
begin Result:=TDACChartTypes.LineType(FStore.Read(Path('type')),Path('type')); end;
```

### TDACChartLegendOptions.GetSelectedMode

Linha 874 de Options.pas.

```pascal
function TDACChartLegendOptions.GetSelectedMode: TDACChartSelection;
begin Result:=TDACChartTypes.Selection(FStore.Read(Path('selectedMode')),Path('selectedMode')); end;
```

### TDACChartTooltipOptions.GetRenderMode

Linha 878 de Options.pas.

```pascal
function TDACChartTooltipOptions.GetRenderMode: TDACChartRenderMode;
begin Result:=TDACChartTypes.RenderMode(FStore.Read(Path('renderMode')),Path('renderMode')); end;
```

### TDACChartTooltipOptions.GetPointerType

Linha 882 de Options.pas.

```pascal
function TDACChartTooltipOptions.GetPointerType: TDACChartPointerType;
begin Result:=TDACChartTypes.PointerType(FStore.Read(Path('axisPointer.type')),Path('axisPointer.type')); end;
```

### TDACChartLabelOptions.GetFontStyle

Linha 886 de Options.pas.

```pascal
function TDACChartLabelOptions.GetFontStyle: TDACChartFontStyle;
begin Result:=TDACChartTypes.FontStyle(FStore.Read(Path('fontStyle')),Path('fontStyle')); end;
```

### TDACChartLabelOptions.GetTextAlign

Linha 890 de Options.pas.

```pascal
function TDACChartLabelOptions.GetTextAlign: TDACChartTextAlign;
begin Result:=TDACChartTypes.TextAlign(FStore.Read(Path('align')),Path('align')); end;
```

### TDACChartLabelOptions.GetVerticalAlign

Linha 894 de Options.pas.

```pascal
function TDACChartLabelOptions.GetVerticalAlign: TDACChartVerticalAlign;
begin Result:=TDACChartTypes.VerticalAlign(FStore.Read(Path('verticalAlign')),Path('verticalAlign')); end;
```

### TDACChartLabelOptions.GetOverflow

Linha 898 de Options.pas.

```pascal
function TDACChartLabelOptions.GetOverflow: TDACChartOverflow;
begin Result:=TDACChartTypes.Overflow(FStore.Read(Path('overflow')),Path('overflow')); end;
```

### TDACChartOptionSeries.GetLayoutBy

Linha 902 de Options.pas.

```pascal
function TDACChartOptionSeries.GetLayoutBy: TDACChartSeriesLayout;
begin Result:=TDACChartTypes.SeriesLayout(FStore.Read('seriesLayoutBy'),'seriesLayoutBy'); end;
```

### TDACChartOptionSeries.GetStep

Linha 906 de Options.pas.

```pascal
function TDACChartOptionSeries.GetStep: TDACChartStep;
begin Result:=TDACChartTypes.Step(FStore.Read('step'),'step'); end;
```

### TDACChartOptionSeries.GetSmoothMonotone

Linha 910 de Options.pas.

```pascal
function TDACChartOptionSeries.GetSmoothMonotone: TDACChartMonotone;
begin Result:=TDACChartTypes.Monotone(FStore.Read('smoothMonotone'),'smoothMonotone'); end;
```

### TDACChartOptionSeries.GetSymbol

Linha 914 de Options.pas.

```pascal
function TDACChartOptionSeries.GetSymbol: TDACChartSymbol;
begin Result:=TDACChartTypes.Symbol(FStore.Read('symbol'),'symbol'); end;
```

### TDACChartOptionSeries.GetSelectedMode

Linha 918 de Options.pas.

```pascal
function TDACChartOptionSeries.GetSelectedMode: TDACChartSelection;
begin Result:=TDACChartTypes.Selection(FStore.Read('selectedMode'),'selectedMode'); end;
```

### TDACChartOptionSeries.GetStackStrategy

Linha 922 de Options.pas.

```pascal
function TDACChartOptionSeries.GetStackStrategy: TDACChartStackStrategy;
begin Result:=TDACChartTypes.StackStrategy(FStore.Read('stackStrategy'),'stackStrategy'); end;
```

### TDACChartOptionSeries.GetFocus

Linha 926 de Options.pas.

```pascal
function TDACChartOptionSeries.GetFocus: TDACChartFocus;
begin Result:=TDACChartTypes.Focus(FStore.Read('emphasis.focus'),'emphasis.focus'); end;
```

### TDACChartOptions.GetAnimationMode

Linha 930 de Options.pas.

```pascal
function TDACChartOptions.GetAnimationMode: TDACChartSwitch;
begin Result:=TDACChartTypes.Switch(FStore.Read('animation'),'animation'); end;
```

### TDACChartOptions.GetAnimationEasing

Linha 934 de Options.pas.

```pascal
function TDACChartOptions.GetAnimationEasing: TDACChartEasing;
begin Result:=TDACChartTypes.Easing(FStore.Read('animationEasing'),'animationEasing'); end;
```

### TDACChartOptions.GetAnimationEasingUpdate

Linha 938 de Options.pas.

```pascal
function TDACChartOptions.GetAnimationEasingUpdate: TDACChartEasing;
begin Result:=TDACChartTypes.Easing(FStore.Read('animationEasingUpdate'),'animationEasingUpdate'); end;
```

### TDACChartDatasetOptions.GetSourceHeader

Linha 942 de Options.pas.

```pascal
function TDACChartDatasetOptions.GetSourceHeader: TDACChartSwitch;
begin Result:=TDACChartTypes.Switch(FStore.Read(Path('sourceHeader')),Path('sourceHeader')); end;
```

### TDACChartTextOptions.GetFontWeight

Linha 946 de Options.pas.

```pascal
function TDACChartTextOptions.GetFontWeight: Integer;
var V: TJSONValue;
begin
  V:=FStore.Read(Path('fontWeight')); if V=nil then Exit(0);
  if V is TJSONNumber then Exit(Round(TDACChartTypes.Number(V,Path('fontWeight'))));
  if V.Value='bold' then Result:=700 else Result:=400;
end;
```
