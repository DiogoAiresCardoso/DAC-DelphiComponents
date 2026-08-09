unit DACChartsDemo.Main;

interface

uses
  System.Classes,
  System.SysUtils,
  System.UITypes,
  Data.DB,
  Datasnap.DBClient,
  Vcl.Controls,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.Graphics,
  Vcl.StdCtrls,
  DAC.Components.Controls.Charts,
  DAC.Components.DesignSystem.Theme;

type
  TChartsDemoForm = class(TForm)
    pnlHeader: TPanel;
    lblTitle: TLabel;
    lblDescription: TLabel;
    btnTheme: TButton;
    btnDataMode: TButton;
    sbCharts: TScrollBox;
    procedure btnThemeClick(Sender: TObject);
    procedure btnDataModeClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    FDataSet: TClientDataSet;
    FDataSource: TDataSource;
    FDark: Boolean;
    FDataModeIndex: Integer;
    FModeChart: TDACChart;
    FAnimationEnabled: Boolean;
    btnUpdateValues: TButton;
    btnToggleAnimation: TButton;
    cbDuration: TComboBox;
    cbEasing: TComboBox;
    procedure AddManual(const ASeries: TDACChartSeries;
      const ACategories: array of string; const AValues: array of Double;
      const ANullIndex: Integer = -1);
    procedure BuildCharts;
    procedure BuildDataSet;
    function CreateChart(const ATitle: string; const AColumn, ARow: Integer): TDACChart;
    function NewSeries(const AChart: TDACChart; const AName: string;
      const AType: TDACChartType; const AFill: TDACChartFillMode = cfSolid): TDACChartSeries;
    procedure ApplyTheme;
    procedure ApplyAnimationOptions;
    procedure btnToggleAnimationClick(Sender: TObject);
    procedure btnUpdateValuesClick(Sender: TObject);
    procedure cbAnimationOptionChange(Sender: TObject);
    procedure CreateAnimationControls;
  end;

var
  ChartsDemoForm: TChartsDemoForm;

implementation

{$R *.dfm}

const
  { The gallery deliberately uses the same minimum visual size as the
    component.  It may scroll horizontally on smaller displays, rather than
    compressing chart text, axes or the reserved legend panel. }
  ChartWidth = 500;
  ChartHeight = 320;
  ChartGap = 24;

procedure TChartsDemoForm.AddManual(const ASeries: TDACChartSeries;
  const ACategories: array of string; const AValues: array of Double;
  const ANullIndex: Integer);
var
  I: Integer;
  LPoint: TDACChartPoint;
begin
  if Length(ACategories) <> Length(AValues) then
    raise EArgumentException.Create('Categorias e valores devem ter o mesmo tamanho.');
  for I := Low(AValues) to High(AValues) do
  begin
    LPoint := ASeries.Points.Add;
    LPoint.Category := ACategories[I];
    LPoint.XValue := I;
    LPoint.Value := AValues[I];
    LPoint.IsNull := I = ANullIndex;
    LPoint.LabelText := FormatFloat('0.##', AValues[I]);
    LPoint.TooltipText := ASeries.Name + ' em ' + ACategories[I];
  end;
end;

procedure TChartsDemoForm.ApplyTheme;
begin
  { ResolveForSurface honors the physical parent surface for ThemeMode=Inherit.
    Apply that surface before notifying TDACThemeManager; otherwise charts use
    the previous scrollbox color and the palette is inverted one toggle late. }
  if FDark then
  begin
    Color := TColor($00140D08);
    pnlHeader.Color := TColor($001E140D);
    lblTitle.Font.Color := clWhite;
    lblDescription.Font.Color := TColor($00D0D0D0);
    btnTheme.Caption := 'Usar tema claro';
  end
  else
  begin
    Color := clWhite;
    pnlHeader.Color := TColor($00F5F8F4);
    lblTitle.Font.Color := TColor($0017221A);
    lblDescription.Font.Color := TColor($00526158);
    btnTheme.Caption := 'Usar tema escuro';
  end;
  sbCharts.Color := Color;
  if FDark then
    TDACThemeManager.SetApplicationMode(dtmDark)
  else
    TDACThemeManager.SetApplicationMode(dtmLight);
end;

procedure TChartsDemoForm.ApplyAnimationOptions;
var
  I: Integer;
  LChart: TDACChart;
  LDuration: Integer;
begin
  LDuration := StrToIntDef(cbDuration.Text, 360);
  for I := 0 to sbCharts.ControlCount - 1 do
    if sbCharts.Controls[I] is TDACChart then
    begin
      LChart := TDACChart(sbCharts.Controls[I]);
      LChart.Animation.Enabled := FAnimationEnabled;
      LChart.Animation.Duration := LDuration;
      LChart.Animation.Easing := TDACChartAnimationEasing(cbEasing.ItemIndex);
    end;
  if FAnimationEnabled then
    btnToggleAnimation.Caption := 'Animacao: ativa'
  else
    btnToggleAnimation.Caption := 'Animacao: desativada';
end;

procedure TChartsDemoForm.BuildCharts;
var
  LChart: TDACChart;
  LSeries: TDACChartSeries;
begin
  LChart := CreateChart('1. Barras solidas', 0, 0);
  LSeries := NewSeries(LChart, 'Producao', ctBar);
  LSeries.Color := TAlphaColor($FF2F9E22);
  AddManual(LSeries, ['Jan', 'Fev', 'Mar', 'Abr', 'Mai'], [42, 68, 57, 75, 54]);
  LSeries := NewSeries(LChart, 'Meta', ctBar);
  LSeries.Color := TAlphaColor($FF4C8DFF);
  AddManual(LSeries, ['Jan', 'Fev', 'Mar', 'Abr', 'Mai'], [48, 62, 64, 70, 60]);

  LChart := CreateChart('2. Barras - gradiente 0 graus', 1, 0);
  LSeries := NewSeries(LChart, 'Colheita', ctBar, cfLinearGradient);
  LSeries.GradientAngle := 0;
  LSeries.GradientStartColor := TAlphaColor($FF1B7F3A);
  LSeries.GradientEndColor := TAlphaColor($FF8BE25A);
  AddManual(LSeries, ['A', 'B', 'C', 'D'], [28, 44, 31, 60]);
  LSeries := NewSeries(LChart, 'Planejado', ctBar, cfLinearGradient);
  LSeries.Color := TAlphaColor($FF4C8DFF);
  LSeries.GradientAngle := 0;
  AddManual(LSeries, ['A', 'B', 'C', 'D'], [34, 39, 42, 53]);

  LChart := CreateChart('3. Barras - gradiente 90 graus', 2, 0);
  LSeries := NewSeries(LChart, 'Estoque', ctBar, cfLinearGradient);
  LSeries.GradientAngle := 90;
  AddManual(LSeries, ['S1', 'S2', 'S3', 'S4'], [14, 33, 50, 26]);
  LSeries := NewSeries(LChart, 'Referencia', ctBar, cfLinearGradient);
  LSeries.Color := TAlphaColor($FFF5C842);
  LSeries.GradientAngle := 90;
  AddManual(LSeries, ['S1', 'S2', 'S3', 'S4'], [20, 30, 44, 32]);

  LChart := CreateChart('4. Barras - gradiente radial', 0, 1);
  LSeries := NewSeries(LChart, 'Indice', ctBar, cfRadialGradient);
  AddManual(LSeries, ['Norte', 'Sul', 'Leste', 'Oeste'], [20, 48, 35, 55]);
  LSeries := NewSeries(LChart, 'Meta regional', ctBar, cfRadialGradient);
  LSeries.Color := TAlphaColor($FF4C8DFF);
  AddManual(LSeries, ['Norte', 'Sul', 'Leste', 'Oeste'], [28, 42, 40, 50]);

  LChart := CreateChart('5. Linha com lacuna nula', 1, 1);
  LSeries := NewSeries(LChart, 'Umidade', ctLine);
  AddManual(LSeries, ['Jan', 'Fev', 'Mar', 'Abr', 'Mai'], [16, 22, 0, 18, 24], 2);

  LChart := CreateChart('6. Area com negativos e zero', 2, 1);
  LSeries := NewSeries(LChart, 'Resultado', ctArea, cfLinearGradient);
  LSeries.GradientAngle := 90;
  AddManual(LSeries, ['Jan', 'Fev', 'Mar', 'Abr', 'Mai'], [-10, 18, 0, 27, -4]);

  LChart := CreateChart('7. Misto: tooltip com 3 series', 0, 2);
  LChart.Tooltip.Mode := ctmAxis;
  LChart.Tooltip.Formatter := '{series}: {value}  {tooltip}';
  LSeries := NewSeries(LChart, 'Realizado', ctBar, cfLinearGradient);
  AddManual(LSeries, ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago'],
    [20, 34, 29, 45, 38, 52, 47, 61]);
  LSeries := NewSeries(LChart, 'Meta', ctLine);
  AddManual(LSeries, ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago'],
    [26, 31, 36, 40, 43, 47, 51, 56]);
  LSeries := NewSeries(LChart, 'Tendencia', ctArea, cfRadialGradient);
  AddManual(LSeries, ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun', 'Jul', 'Ago'],
    [12, 18, 22, 28, 26, 33, 37, 42]);

  LChart := CreateChart('8. Pie com tooltip e legenda', 1, 2);
  LSeries := NewSeries(LChart, 'Culturas', ctPie, cfSolid);
  AddManual(LSeries, ['Soja', 'Milho', 'Feijao', 'Outros'], [55, 25, 15, 5]);

  LChart := CreateChart('9. Doughnut radial', 2, 2);
  LSeries := NewSeries(LChart, 'Status', ctDoughnut, cfRadialGradient);
  AddManual(LSeries, ['Ativo', 'Pendente', 'Pausado'], [62, 28, 10]);

  LChart := CreateChart('10. Data-aware: tooltip com 3 series', 0, 3);
  LChart.DataSource := FDataSource;
  LChart.DataMode := cdmDataSource;
  LChart.Tooltip.Mode := ctmAxis;
  LChart.Tooltip.Formatter := '{series}: {value}';
  LSeries := NewSeries(LChart, 'Producao CDS', ctBar, cfLinearGradient);
  LSeries.EncodeX := 'MES';
  LSeries.EncodeY := 'PRODUCAO';
  LSeries.EncodeLabel := 'ROTULO';
  LSeries.EncodeTooltip := 'DETALHE';
  LSeries := NewSeries(LChart, 'Chuva CDS', ctLine, cfSolid);
  LSeries.EncodeX := 'MES';
  LSeries.EncodeY := 'CHUVA';
  LSeries := NewSeries(LChart, 'Custo CDS', ctArea, cfLinearGradient);
  LSeries.EncodeX := 'MES';
  LSeries.EncodeY := 'CUSTO';

  LChart := CreateChart('11. Data-aware: linha', 1, 3);
  LChart.DataSource := FDataSource;
  LChart.DataMode := cdmDataSource;
  LSeries := NewSeries(LChart, 'Chuva CDS', ctLine, cfSolid);
  LSeries.EncodeX := 'MES';
  LSeries.EncodeY := 'CHUVA';

  LChart := CreateChart('12. Data-aware: area', 2, 3);
  LChart.DataSource := FDataSource;
  LChart.DataMode := cdmDataSource;
  LSeries := NewSeries(LChart, 'Custo CDS', ctArea, cfLinearGradient);
  LSeries.EncodeX := 'MES';
  LSeries.EncodeY := 'CUSTO';

  LChart := CreateChart('13. Categorias longas e margens', 0, 4);
  LChart.Title.Visible := True;
  LChart.Title.Text := 'Qualidade por fazenda';
  LChart.Title.SubText := 'Titulo configuravel: fonte, cor, alinhamento e posicao';
  LChart.Title.Font.Size := 14;
  LChart.Title.TextColor := TAlphaColor($FF176B2C);
  LChart.Title.SubTextColor := TAlphaColor($FF5A6A60);
  LChart.Legend.Position := cpLeft;
  LChart.Legend.Orientation := coVertical;
  LChart.Legend.BackgroundVisible := True;
  LChart.Legend.Padding := 6;
  LChart.XAxis.Title := 'Fazendas';
  LChart.XAxis.TitleVisible := True;
  LChart.YAxis.Title := 'Indice';
  LChart.YAxis.TitleVisible := True;
  LChart.YAxis.GridColor := TAlphaColor($FFD5E5D7);
  LChart.ChartGrid.Margins.Left := 12;
  LChart.ChartGrid.Margins.Bottom := 12;
  LSeries := NewSeries(LChart, 'Qualidade', ctLine);
  AddManual(LSeries, ['Fazenda Boa Vista', 'Fazenda Horizonte',
    'Fazenda Santa Clara', 'Fazenda Campo Verde'], [72, 64, 81, 77]);

  LChart := CreateChart('14. X temporal', 1, 4);
  LChart.Title.Visible := True;
  LChart.Title.Position := cpBottom;
  LChart.Title.Alignment := taCenter;
  LChart.Title.Text := 'Temperatura diaria';
  LChart.Legend.Position := cpRight;
  LChart.Legend.Orientation := coVertical;
  LChart.Legend.BorderVisible := True;
  LChart.Legend.MarkersVisible := True;
  LChart.XAxis.TickMarksVisible := False;
  LChart.XAxis.AxisType := catTime;
  LChart.XAxis.LabelFormat := 'dd/mm';
  LSeries := NewSeries(LChart, 'Temperatura', ctLine);
  AddManual(LSeries, ['Dia 1', 'Dia 2', 'Dia 3', 'Dia 4'], [22, 24, 21, 27]);
  LSeries.Points[0].XValue := EncodeDate(2025, 5, 1);
  LSeries.Points[1].XValue := EncodeDate(2025, 5, 2);
  LSeries.Points[2].XValue := EncodeDate(2025, 5, 3);
  LSeries.Points[3].XValue := EncodeDate(2025, 5, 4);

  LChart := CreateChart('15. Estado vazio manual', 2, 4);
  LChart.DataMode := cdmManual;
  LChart.Legend.Visible := False;

  LChart := CreateChart('16. Alternancia de DataMode', 0, 5);
  FModeChart := LChart;
  LChart.DataSource := FDataSource;
  LSeries := NewSeries(LChart, 'Producao comparavel', ctBar, cfLinearGradient);
  LSeries.EncodeX := 'MES';
  LSeries.EncodeY := 'PRODUCAO';
  AddManual(LSeries, ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun'],
    [38, 62, 51, 71, 49, 77]);
  LSeries := NewSeries(LChart, 'Meta comparavel', ctBar);
  LSeries.Color := TAlphaColor($FF4C8DFF);
  AddManual(LSeries, ['Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun'],
    [44, 58, 59, 68, 56, 74]);
  LChart.DataMode := cdmManual;

  LChart := CreateChart('17. Barras - gradiente 180 graus', 1, 5);
  LChart.Title.Visible := True;
  LChart.Title.Position := cpLeft;
  LChart.Title.Text := 'Volume';
  LChart.Legend.LabelsVisible := False;
  LChart.Legend.MarkersVisible := True;
  LChart.YAxis.LabelsVisible := False;
  LChart.YAxis.LineVisible := False;
  LSeries := NewSeries(LChart, 'Volume', ctBar, cfLinearGradient);
  LSeries.GradientAngle := 180;
  LSeries.GradientStartColor := TAlphaColor($FF3A5FD0);
  LSeries.GradientEndColor := TAlphaColor($FF9DC8FF);
  AddManual(LSeries, ['Q1', 'Q2', 'Q3', 'Q4'], [31, 48, 39, 66]);
  LSeries := NewSeries(LChart, 'Meta trimestral', ctBar, cfLinearGradient);
  LSeries.GradientAngle := 180;
  LSeries.GradientStartColor := TAlphaColor($FFF5C842);
  LSeries.GradientEndColor := TAlphaColor($FFFAD77A);
  AddManual(LSeries, ['Q1', 'Q2', 'Q3', 'Q4'], [38, 45, 46, 60]);

  LChart := CreateChart('18. Doughnut sem valores positivos', 2, 5);
  LSeries := NewSeries(LChart, 'Sem valores', ctDoughnut, cfSolid);
  AddManual(LSeries, ['A', 'B', 'C'], [0, 0, 0]);
end;

procedure TChartsDemoForm.BuildDataSet;
const
  Months: array[0..11] of string = ('Jan', 'Fev', 'Mar', 'Abr', 'Mai', 'Jun',
    'Jul', 'Ago', 'Set', 'Out', 'Nov', 'Dez');
  Production: array[0..11] of Double = (42, 68, 57, 75, 54, 80, 73, 91, 66, 84, 97, 105);
  Rain: array[0..11] of Double = (120, 95, 140, 110, 90, 65, 72, 58, 102, 118, 86, 77);
  Cost: array[0..11] of Double = (18, 21, 19, 25, 22, 29, 27, 31, 24, 33, 30, 36);
var
  I: Integer;
begin
  FDataSet := TClientDataSet.Create(Self);
  FDataSet.FieldDefs.Add('MES', ftString, 12);
  FDataSet.FieldDefs.Add('PRODUCAO', ftFloat);
  FDataSet.FieldDefs.Add('CHUVA', ftFloat);
  FDataSet.FieldDefs.Add('CUSTO', ftFloat);
  FDataSet.FieldDefs.Add('ROTULO', ftString, 32);
  FDataSet.FieldDefs.Add('DETALHE', ftString, 80);
  FDataSet.CreateDataSet;
  for I := Low(Months) to High(Months) do
  begin
    FDataSet.Append;
    FDataSet.FieldByName('MES').AsString := Months[I];
    FDataSet.FieldByName('PRODUCAO').AsFloat := Production[I];
    FDataSet.FieldByName('CHUVA').AsFloat := Rain[I];
    if I <> 3 then
      FDataSet.FieldByName('CUSTO').AsFloat := Cost[I];
    FDataSet.FieldByName('ROTULO').AsString := FormatFloat('0.## t', Production[I]);
    FDataSet.FieldByName('DETALHE').AsString := 'Registro de ' + Months[I];
    FDataSet.Post;
  end;
  FDataSource := TDataSource.Create(Self);
  FDataSource.DataSet := FDataSet;
end;

procedure TChartsDemoForm.btnThemeClick(Sender: TObject);
begin
  FDark := not FDark;
  ApplyTheme;
end;

procedure TChartsDemoForm.btnDataModeClick(Sender: TObject);
const
  Captions: array[TDACChartDataMode] of string = (
    'Modo: manual', 'Modo: data-aware', 'Modo: automatico');
begin
  if FModeChart = nil then
    Exit;
  FDataModeIndex := (FDataModeIndex + 1) mod 3;
  FModeChart.DataMode := TDACChartDataMode(FDataModeIndex);
  btnDataMode.Caption := Captions[FModeChart.DataMode];
end;

procedure TChartsDemoForm.btnToggleAnimationClick(Sender: TObject);
begin
  FAnimationEnabled := not FAnimationEnabled;
  ApplyAnimationOptions;
end;

procedure TChartsDemoForm.btnUpdateValuesClick(Sender: TObject);
var
  I: Integer;
  J: Integer;
  LChart: TDACChart;
  LPoint: TDACChartPoint;
  LRecNo: Integer;
begin
  { Manual values and the ClientDataSet are changed independently. The chart
    receives both paths through the same coalesced refresh pipeline. }
  for I := 0 to sbCharts.ControlCount - 1 do
    if sbCharts.Controls[I] is TDACChart then
    begin
      LChart := TDACChart(sbCharts.Controls[I]);
      if LChart.DataMode <> cdmDataSource then
      begin
        for J := 0 to LChart.Series.Count - 1 do
          if LChart.Series[J].Points.Count > 0 then
          begin
            LPoint := LChart.Series[J].Points[Random(LChart.Series[J].Points.Count)];
            if not LPoint.IsNull then
              LPoint.Value := 12 + Random(108);
          end;
      end;
    end;
  if (FDataSet <> nil) and FDataSet.Active and not FDataSet.IsEmpty then
  begin
    LRecNo := FDataSet.RecNo;
    FDataSet.First;
    while not FDataSet.Eof do
    begin
      FDataSet.Edit;
      FDataSet.FieldByName('PRODUCAO').AsFloat := 20 + Random(110);
      FDataSet.FieldByName('CHUVA').AsFloat := 20 + Random(130);
      if not FDataSet.FieldByName('CUSTO').IsNull then
        FDataSet.FieldByName('CUSTO').AsFloat := 10 + Random(45);
      FDataSet.Post;
      FDataSet.Next;
    end;
    if LRecNo > 0 then
      FDataSet.RecNo := LRecNo;
  end;
  for I := 0 to sbCharts.ControlCount - 1 do
    if sbCharts.Controls[I] is TDACChart then
      TDACChart(sbCharts.Controls[I]).RequeryData;
  btnUpdateValues.Caption := 'Valores atualizados';
end;

procedure TChartsDemoForm.cbAnimationOptionChange(Sender: TObject);
begin
  ApplyAnimationOptions;
end;

procedure TChartsDemoForm.CreateAnimationControls;
begin
  pnlHeader.Height := 94;
  lblDescription.Caption :=
    'Manual, data-aware, mixed, gradientes, nulos, eixos, interacao e animacoes';
  btnDataMode.SetBounds(20, 54, 150, 28);

  btnUpdateValues := TButton.Create(Self);
  btnUpdateValues.Parent := pnlHeader;
  btnUpdateValues.SetBounds(180, 54, 150, 28);
  btnUpdateValues.Caption := 'Atualizar valores';
  btnUpdateValues.OnClick := btnUpdateValuesClick;

  btnToggleAnimation := TButton.Create(Self);
  btnToggleAnimation.Parent := pnlHeader;
  btnToggleAnimation.SetBounds(340, 54, 165, 28);
  btnToggleAnimation.OnClick := btnToggleAnimationClick;

  cbDuration := TComboBox.Create(Self);
  cbDuration.Parent := pnlHeader;
  cbDuration.SetBounds(515, 55, 105, 24);
  cbDuration.Style := csDropDownList;
  cbDuration.Items.Add('180');
  cbDuration.Items.Add('360');
  cbDuration.Items.Add('600');
  cbDuration.ItemIndex := 1;
  cbDuration.OnChange := cbAnimationOptionChange;

  cbEasing := TComboBox.Create(Self);
  cbEasing.Parent := pnlHeader;
  cbEasing.SetBounds(630, 55, 150, 24);
  cbEasing.Style := csDropDownList;
  cbEasing.Items.Add('Linear');
  cbEasing.Items.Add('Cubica entrada');
  cbEasing.Items.Add('Cubica saida');
  cbEasing.Items.Add('Cubica entrada/saida');
  cbEasing.ItemIndex := Ord(caeCubicOut);
  cbEasing.OnChange := cbAnimationOptionChange;

  btnTheme.SetBounds(800, 54, 160, 28);
end;

function TChartsDemoForm.CreateChart(const ATitle: string; const AColumn,
  ARow: Integer): TDACChart;
begin
  Result := TDACChart.Create(Self);
  Result.Parent := sbCharts;
  Result.SetBounds(20 + AColumn * (ChartWidth + ChartGap),
    16 + ARow * (ChartHeight + ChartGap), ChartWidth, ChartHeight);
  Result.DataMode := cdmManual;
  Result.Title.Visible := True;
  Result.Title.Text := ATitle;
  Result.Title.Font.Size := 14;
  Result.Legend.Visible := True;
  Result.Legend.AllowToggleSeries := True;
  Result.Tooltip.Enabled := True;
  Result.Tooltip.Mode := ctmAxis;
  Result.Tooltip.Formatter := '{series}: {value}';
  Result.Tooltip.Font.Size := 12;
  Result.Tooltip.TitleFont.Size := 14;
  Result.Tooltip.Padding := 14;
  Result.TabStop := True;
end;

procedure TChartsDemoForm.FormCreate(Sender: TObject);
begin
  Randomize;
  FDark := False;
  FAnimationEnabled := True;
  FDataModeIndex := Ord(cdmManual);
  BuildDataSet;
  BuildCharts;
  CreateAnimationControls;
  ApplyAnimationOptions;
  btnDataMode.Caption := 'Modo: manual';
  ApplyTheme;
end;

function TChartsDemoForm.NewSeries(const AChart: TDACChart;
  const AName: string; const AType: TDACChartType;
  const AFill: TDACChartFillMode): TDACChartSeries;
begin
  Result := AChart.Series.Add;
  Result.Name := AName;
  Result.ChartType := AType;
  Result.FillMode := AFill;
  Result.GradientAngle := 90;
end;

end.
