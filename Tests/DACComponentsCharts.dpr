program DACComponentsCharts;

{$APPTYPE CONSOLE}

uses
  System.Classes,
  System.SysUtils,
  System.UITypes,
  Data.DB,
  Datasnap.DBClient,
  Winapi.Messages,
  Winapi.Windows,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Graphics,
  DAC.Components.Controls.Charts in '..\Source\Controls\DAC.Components.Controls.Charts.pas',
  DACComponentsCharts.ClientDataSetAdapter in 'DACComponentsCharts.ClientDataSetAdapter.pas';

type
  TAnimationProbe = class
  public
    Started: Integer;
    Finished: Integer;
    procedure AnimationStarted(Sender: TObject);
    procedure AnimationFinished(Sender: TObject);
  end;

procedure Require(const ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create(AMessage);
end;

procedure TAnimationProbe.AnimationStarted(Sender: TObject);
begin
  Inc(Started);
end;

procedure TAnimationProbe.AnimationFinished(Sender: TObject);
begin
  Inc(Finished);
end;

procedure Pump(const AMilliseconds: Cardinal);
var
  LStarted: Cardinal;
begin
  LStarted := GetTickCount;
  repeat
    Application.ProcessMessages;
    Sleep(1);
  until (GetTickCount - LStarted) >= AMilliseconds;
  Application.ProcessMessages;
end;

procedure AddPoint(const ASeries: TDACChartSeries; const ACategory: string;
  const AValue: Double; const AIsNull: Boolean = False);
var
  LPoint: TDACChartPoint;
begin
  LPoint := ASeries.Points.Add;
  LPoint.Category := ACategory;
  LPoint.XValue := ASeries.Points.Count - 1;
  LPoint.Value := AValue;
  LPoint.IsNull := AIsNull;
end;

procedure TestDpiContract;
var
  LChart: TDACChart;
  LForm: TForm;
begin
  LChart := TDACChart.Create(nil);
  try
    Require((LChart.EffectiveDpi = 96) and (LChart.DpiScale = 1),
      'Chart sem Parent deve preservar as metricas de 96 PPI.');
    Require(not LChart.HandleAllocated,
      'A consulta de DPI nao pode criar HWND para um chart sem Parent.');
  finally
    LChart.Free;
  end;

  LForm := TForm.Create(nil);
  try
    LChart := TDACChart.Create(LForm);
    LChart.Parent := LForm;
    LChart.SetBounds(0, 0, 360, 220);
    LForm.Show;
    Pump(20);
    SendMessage(LChart.Handle, WM_DPICHANGED, WPARAM($00900090), 0);
    Require((LChart.EffectiveDpi = 144) and (LChart.DpiScale > 1.49) and
      (LChart.DpiScale < 1.51),
      'WM_DPICHANGED deve atualizar somente as metricas internas do chart.');
    Require((LChart.Width = 360) and (LChart.Height = 220),
      'O chart nao deve redimensionar o host ao receber nova escala DPI.');
    SendMessage(LChart.Handle, WM_DPICHANGED, WPARAM($00600060), 0);
    Require((LChart.EffectiveDpi = 96) and (LChart.DpiScale = 1),
      'O retorno para 96 PPI deve restaurar as metricas originais.');
  finally
    LForm.Free;
  end;
end;

procedure TestAnimationContract;
var
  LChart: TDACChart;
  LForm: TForm;
  LProbe: TAnimationProbe;
  LSeries: TDACChartSeries;
begin
  LChart := TDACChart.Create(nil);
  try
    Require(not LChart.HandleAllocated,
      'TDACChart com Parent=nil nao pode criar HWND no construtor.');
    Require(LChart.Animation.Enabled and LChart.Animation.AutoStartOnUpdate and
      (LChart.Animation.Duration = 360) and
      (LChart.Animation.Easing = caeCubicOut),
      'Defaults de Animation divergentes do contrato.');
  finally
    LChart.Free;
  end;

  LForm := TForm.Create(nil);
  LProbe := TAnimationProbe.Create;
  try
    LChart := TDACChart.Create(LForm);
    LChart.Parent := LForm;
    LChart.SetBounds(0, 0, 360, 220);
    LChart.Animation.Duration := 80;
    LChart.OnAnimationStart := LProbe.AnimationStarted;
    LChart.OnAnimationFinish := LProbe.AnimationFinished;
    LSeries := LChart.Series.Add;
    LSeries.Name := 'Manual';
    AddPoint(LSeries, 'A', 10);
    AddPoint(LSeries, 'B', 20);
    LForm.Show;
    Pump(20);
    LSeries.Points[0].Value := 60;
    Pump(20);
    Require(LProbe.Started > 0,
      'Atualizacao manual nao iniciou animacao automatica.');
    Pump(120);
    Require(not LChart.Animation.Running and (LProbe.Finished > 0),
      'Animacao manual nao terminou ou manteve timer ativo.');
    LChart.Animation.Replay;
    Pump(20);
    Require(LChart.Animation.Running,
      'Replay deve iniciar a animacao quando o chart possui handle.');
    LChart.Animation.Stop;
    Require(not LChart.Animation.Running,
      'Stop deve encerrar a animacao de forma idempotente.');
  finally
    LProbe.Free;
    LForm.Free;
  end;
end;

procedure TestDataAwareRefresh;
var
  LChart: TDACChart;
  LDataSet: TClientDataSet;
  LDataSource: TDataSource;
  LForm: TForm;
  LRecNo: Integer;
  LSeries: TDACChartSeries;
begin
  LForm := TForm.Create(nil);
  LDataSet := TClientDataSet.Create(nil);
  LDataSource := TDataSource.Create(nil);
  try
    LDataSet.FieldDefs.Add('MES', ftString, 8);
    LDataSet.FieldDefs.Add('VALOR', ftFloat);
    LDataSet.CreateDataSet;
    LDataSet.Append;
    LDataSet.FieldByName('MES').AsString := 'Jan';
    LDataSet.FieldByName('VALOR').AsFloat := 10;
    LDataSet.Post;
    LDataSet.Append;
    LDataSet.FieldByName('MES').AsString := 'Fev';
    LDataSet.FieldByName('VALOR').AsFloat := 20;
    LDataSet.Post;
    LDataSet.Last;
    LRecNo := LDataSet.RecNo;
    LDataSource.DataSet := LDataSet;

    LChart := TDACChart.Create(LForm);
    LChart.Parent := LForm;
    LChart.SetBounds(0, 0, 360, 220);
    LChart.DataSource := LDataSource;
    LChart.DataMode := cdmDataSource;
    LSeries := LChart.Series.Add;
    LSeries.Name := 'Valor';
    LSeries.EncodeX := 'MES';
    LSeries.EncodeY := 'VALOR';
    LForm.Show;
    Pump(30);
    Require((LDataSet.RecNo = LRecNo) and (LDataSet.State = dsBrowse),
      'Refresh data-aware alterou cursor ou estado do ClientDataSet original.');
    LDataSet.Edit;
    LDataSet.FieldByName('VALOR').AsFloat := 35;
    LDataSet.Post;
    Pump(120);
    Require((LDataSet.RecNo = LRecNo) and (LDataSet.State = dsBrowse),
      'Notificacao data-aware alterou cursor ou estado do ClientDataSet original.');
  finally
    LDataSource.Free;
    LDataSet.Free;
    LForm.Free;
  end;
end;

procedure TestDataAwareColumns;
var
  LChart: TDACChart;
  LDataSet: TClientDataSet;
  LDataSource: TDataSource;
  LForm: TForm;
  LRecNo: Integer;
begin
  LForm := TForm.Create(nil);
  LDataSet := TClientDataSet.Create(nil);
  LDataSource := TDataSource.Create(nil);
  try
    LDataSet.FieldDefs.Add('MES', ftString, 8);
    LDataSet.FieldDefs.Add('PRODUCAO', ftFloat);
    LDataSet.FieldDefs.Add('META', ftFloat);
    LDataSet.CreateDataSet;
    LDataSet.Append;
    LDataSet.FieldByName('MES').AsString := 'Jan';
    LDataSet.FieldByName('PRODUCAO').AsFloat := 12;
    LDataSet.FieldByName('META').AsFloat := 15;
    LDataSet.Post;
    LDataSet.Append;
    LDataSet.FieldByName('MES').AsString := 'Fev';
    LDataSet.FieldByName('PRODUCAO').AsFloat := 18;
    LDataSet.FieldByName('META').AsFloat := 16;
    LDataSet.Post;
    LDataSet.Last;
    LRecNo := LDataSet.RecNo;
    LDataSource.DataSet := LDataSet;
    LChart := TDACChart.Create(LForm);
    LChart.Parent := LForm;
    LChart.SetBounds(0, 0, 360, 220);
    LChart.DataSource := LDataSource;
    LChart.DataMode := cdmDataSource;
    LChart.DatasetOptions.SeriesLayoutBy := cslColumns;
    LChart.DatasetOptions.Dimensions := 'MES;PRODUCAO;META';
    LForm.Show;
    Pump(40);
    Require((LDataSet.RecNo = LRecNo) and (LDataSet.State = dsBrowse),
      'cslColumns alterou o cursor ou o estado do ClientDataSet original.');
    LDataSource.Free;
    LDataSource := nil;
    Pump(20);
  finally
    LDataSource.Free;
    LDataSet.Free;
    LForm.Free;
  end;
end;

procedure TestConfigurableLayers;
var
  LChart: TDACChart;
begin
  LChart := TDACChart.Create(nil);
  try
    LChart.Title.Visible := True;
    LChart.Title.TextVisible := False;
    LChart.Title.SubTextVisible := True;
    LChart.Title.Position := cpRight;
    LChart.Title.Font.Name := 'Arial';
    LChart.Title.Font.Size := 17;
    LChart.Title.TextColor := TAlphaColor($FF1A6F35);
    LChart.Legend.Position := cpLeft;
    LChart.Legend.Orientation := coVertical;
    LChart.Legend.LabelsVisible := False;
    LChart.Legend.MarkersVisible := True;
    LChart.Legend.BackgroundVisible := True;
    LChart.Legend.BorderVisible := True;
    LChart.Legend.MarkerSize := 14;
    LChart.XAxis.LineVisible := False;
    LChart.XAxis.LabelsVisible := False;
    LChart.XAxis.TickMarksVisible := False;
    LChart.XAxis.TitleVisible := False;
    LChart.YAxis.GridColor := TAlphaColor($FFAACCAA);
    LChart.YAxis.LabelFont.Size := 11;
    LChart.YAxis.TitleFont.Size := 13;
    Require((LChart.Title.Position = cpRight) and
      (LChart.Legend.Position = cpLeft) and
      (LChart.Legend.Orientation = coVertical) and
      (LChart.Legend.MarkerSize = 14) and not LChart.XAxis.LineVisible and
      not LChart.XAxis.LabelsVisible and not LChart.XAxis.TickMarksVisible and
      not LChart.XAxis.TitleVisible,
      'As propriedades configuraveis de titulo, legenda e eixo nao persistiram.');
  finally
    LChart.Free;
  end;
end;

procedure TestStreamingAndLifecycle;
var
  I: Integer;
  LChart: TDACChart;
  LLoaded: TDACChart;
  LStream: TMemoryStream;
begin
  System.Classes.RegisterClass(TDACChart);
  LChart := TDACChart.Create(nil);
  try
    LChart.Name := 'ChartStreaming';
    LChart.DataMode := cdmManual;
    LChart.Title.Text := 'Titulo';
    LChart.Title.Visible := True;
    LChart.Legend.Position := cpRight;
    LChart.DatasetOptions.SeriesLayoutBy := cslColumns;
    LChart.DatasetOptions.Dimensions := 'MES;REALIZADO;META';
    LChart.Tooltip.Mode := ctmAxis;
    LChart.Tooltip.Padding := 16;
    LChart.Tooltip.Font.Size := 12;
    LChart.Tooltip.TitleFont.Size := 13;
    LChart.Tooltip.TextColor := TAlphaColor($FF243A2A);
    LChart.Series.Add.Name := 'Realizado';
    LStream := TMemoryStream.Create;
    try
      LStream.WriteComponent(LChart);
      LStream.Position := 0;
      LLoaded := TDACChart(LStream.ReadComponent(nil));
      try
        Require((LLoaded.DataMode = cdmManual) and
          (LLoaded.Legend.Position = cpRight) and
          (LLoaded.DatasetOptions.SeriesLayoutBy = cslColumns) and
          (LLoaded.Tooltip.Mode = ctmAxis) and
          (LLoaded.Tooltip.Padding = 16) and
          (LLoaded.Tooltip.Font.Size = 12) and
          (LLoaded.Tooltip.TitleFont.Size = 13) and
          (LLoaded.Tooltip.TextColor = TAlphaColor($FF243A2A)) and
          (LLoaded.Series.Count = 1),
          'Round-trip DFM do TDACChart nao preservou propriedades persistentes.');
      finally
        LLoaded.Free;
      end;
    finally
      LStream.Free;
    end;
  finally
    LChart.Free;
  end;
  for I := 1 to 3 do
  begin
    LChart := TDACChart.Create(nil);
    try
      Require(not LChart.HandleAllocated,
        'Ciclo lifecycle criou HWND para TDACChart sem Parent.');
    finally
      LChart.Free;
    end;
  end;
end;

procedure TestChartKindsAndMixedSeries;
var
  LChart: TDACChart;
  LForm: TForm;
  LIndex: Integer;
  LSeries: TDACChartSeries;
  LType: TDACChartType;
begin
  LForm := TForm.Create(nil);
  try
    LForm.Show;
    for LIndex := Ord(Low(TDACChartType)) to Ord(High(TDACChartType)) do
    begin
      LType := TDACChartType(LIndex);
      LChart := TDACChart.Create(LForm);
      try
        LChart.Parent := LForm;
        LChart.SetBounds(0, 0, 360, 220);
        LChart.Animation.Enabled := False;
        LChart.ChartType := LType;
        LSeries := LChart.Series.Add;
        LSeries.ChartType := LType;
        LSeries.Name := 'Serie';
        AddPoint(LSeries, 'A', 10);
        AddPoint(LSeries, 'B', 20);
        AddPoint(LSeries, 'C', 15);
        Pump(15);
      finally
        LChart.Free;
      end;
    end;
    LChart := TDACChart.Create(LForm);
    try
      LChart.Parent := LForm;
      LChart.SetBounds(0, 0, 360, 220);
      LChart.Animation.Enabled := False;
      LSeries := LChart.Series.Add;
      LSeries.ChartType := ctBar;
      LSeries.Name := 'Realizado';
      AddPoint(LSeries, 'A', 12);
      AddPoint(LSeries, 'B', 18);
      LSeries := LChart.Series.Add;
      LSeries.ChartType := ctLine;
      LSeries.Name := 'Meta';
      AddPoint(LSeries, 'A', 15);
      AddPoint(LSeries, 'B', 16);
      Pump(15);
    finally
      LChart.Free;
    end;
  finally
    LForm.Free;
  end;
end;

procedure TestReadableTypographyDefaults;
var
  LChart: TDACChart;
begin
  LChart := TDACChart.Create(nil);
  try
    Require(LChart.Title.Font.Size >= 14,
      'O titulo padrao do grafico deve manter tamanho legivel.');
    Require(LChart.Legend.Font.Size >= 10,
      'A legenda padrao do grafico deve manter tamanho legivel.');
    Require(LChart.XAxis.LabelFont.Size >= 10,
      'Os rotulos do eixo X devem manter tamanho legivel.');
    Require(LChart.YAxis.LabelFont.Size >= 10,
      'Os rotulos do eixo Y devem manter tamanho legivel.');
    Require(LChart.Tooltip.Font.Size >= 12,
      'O texto do tooltip deve manter tamanho legivel.');
    Require((LChart.Tooltip.TitleFont.Size >= 14) and
      (LChart.Tooltip.TitleFont.Size > LChart.Tooltip.Font.Size) and
      (fsBold in LChart.Tooltip.TitleFont.Style),
      'O titulo do tooltip deve ser mais destacado que as series.');
    Require(LChart.Tooltip.Padding >= 14,
      'O tooltip deve manter espaco interno suficiente para leitura.');
  finally
    LChart.Free;
  end;
end;

begin
  Application.Initialize;
  try
    TestDpiContract;
    TestAnimationContract;
    TestDataAwareRefresh;
    TestDataAwareColumns;
    TestConfigurableLayers;
    TestStreamingAndLifecycle;
    TestChartKindsAndMixedSeries;
    TestReadableTypographyDefaults;
    Writeln('DACComponentsCharts: OK');
  except
    on E: Exception do
    begin
      Writeln('DACComponentsCharts: FALHOU - ' + E.Message);
      Halt(1);
    end;
  end;
end.
