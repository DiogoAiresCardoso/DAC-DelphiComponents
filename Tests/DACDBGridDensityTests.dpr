program DACDBGridDensityTests;

{$APPTYPE CONSOLE}

uses
  System.Classes,
  System.SysUtils,
  System.Types,
  System.TypInfo,
  Data.DB,
  Datasnap.DBClient,
  MidasLib,
  Winapi.Windows,
  Vcl.Forms,
  DAC.Components.Controls.DBGrid in '..\Source\Controls\DAC.Components.Controls.DBGrid.pas',
  DAC.Components.Controls.DBGrid.NativeText in '..\Source\Controls\DAC.Components.Controls.DBGrid.NativeText.pas',
  DAC.Components.Controls.DBGrid.Types in '..\Source\Controls\DAC.Components.Controls.DBGrid.Types.pas',
  DAC.Components.DesignSystem.ComponentStyle in '..\Source\DesignSystem\DAC.Components.DesignSystem.ComponentStyle.pas';

type
  TDACDBGridDensityAccess = class(TDACDBGrid)
  public
    function NativeDefaultRowHeight: Integer;
    function NativeHeaderHeight: Integer;
    procedure RecreateNativeHandle;
    procedure ScaleForTest(const M, D: Integer);
    procedure SetNativeColumnWidth(const AIndex, AWidth: Integer);
  end;

function TDACDBGridDensityAccess.NativeDefaultRowHeight: Integer;
begin
  Result := DefaultRowHeight;
end;

function TDACDBGridDensityAccess.NativeHeaderHeight: Integer;
begin
  if (FixedRows > 0) and (RowCount > 0) then
    Result := RowHeights[0]
  else
    Result := 0;
end;

procedure TDACDBGridDensityAccess.RecreateNativeHandle;
begin
  RecreateWnd;
end;

procedure TDACDBGridDensityAccess.ScaleForTest(const M, D: Integer);
begin
  ChangeScale(M, D, True);
end;

procedure TDACDBGridDensityAccess.SetNativeColumnWidth(const AIndex,
  AWidth: Integer);
begin
  ColWidths[AIndex] := AWidth;
end;

procedure Require(const ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create(AMessage);
end;

procedure PopulateDataSet(ADataSet: TClientDataSet);
begin
  ADataSet.FieldDefs.Add('STATUS', ftString, 20);
  ADataSet.FieldDefs.Add('CONCILIADO', ftString, 3);
  ADataSet.FieldDefs.Add('DESCRICAO', ftString, 80);
  ADataSet.CreateDataSet;
  ADataSet.AppendRecord(['ABERTO', 'NAO', 'Movimento de teste']);
  ADataSet.AppendRecord(['FECHADO', 'SIM', 'Outro movimento']);
  ADataSet.First;
end;

procedure RequireStableMetrics(AGrid: TDACDBGridDensityAccess;
  const AExpectedRow, AExpectedHeader: Integer; const AContext: string);
begin
  Require(AGrid.NativeDefaultRowHeight = AExpectedRow,
    AContext + ': resize alterou DefaultRowHeight.');
  Require(AGrid.NativeHeaderHeight = AExpectedHeader,
    AContext + ': resize alterou a altura do header.');
end;

procedure ExerciseColumnLayout(AGrid: TDACDBGridDensityAccess;
  const AContext: string);
var
  LExpectedHeader: Integer;
  LExpectedRow: Integer;
begin
  LExpectedRow := AGrid.NativeDefaultRowHeight;
  LExpectedHeader := AGrid.NativeHeaderHeight;
  Require((LExpectedRow > 0) and (LExpectedHeader > 0),
    AContext + ': metricas iniciais invalidas.');

  AGrid.SetNativeColumnWidth(0, 92);
  RequireStableMetrics(AGrid, LExpectedRow, LExpectedHeader,
    AContext + '/ColWidths');
  AGrid.Columns[0].Width := 116;
  RequireStableMetrics(AGrid, LExpectedRow, LExpectedHeader,
    AContext + '/Column.Width');
  AGrid.Columns[2].Index := 1;
  RequireStableMetrics(AGrid, LExpectedRow, LExpectedHeader,
    AContext + '/Column.Index');
  AGrid.Columns[1].Visible := False;
  RequireStableMetrics(AGrid, LExpectedRow, LExpectedHeader,
    AContext + '/Visible=False');
  AGrid.Columns[1].Visible := True;
  RequireStableMetrics(AGrid, LExpectedRow, LExpectedHeader,
    AContext + '/Visible=True');
end;

procedure TestDensitySurvivesColumnLayout(const ALayoutEnabled: Boolean);
var
  LDataSet: TClientDataSet;
  LDataSource: TDataSource;
  LDensity: TDACDBGridDensity;
  LForm: TForm;
  LGrid: TDACDBGridDensityAccess;
begin
  LForm := TForm.CreateNew(nil);
  try
    LDataSet := TClientDataSet.Create(LForm);
    LDataSource := TDataSource.Create(LForm);
    LGrid := TDACDBGridDensityAccess.Create(LForm);
    PopulateDataSet(LDataSet);
    LDataSource.DataSet := LDataSet;
    LGrid.Parent := LForm;
    LGrid.SetBounds(8, 8, 640, 260);
    LGrid.Layout.AutoLoad := False;
    LGrid.Layout.AutoSave := False;
    LGrid.Layout.Enabled := ALayoutEnabled;
    LGrid.DataSource := LDataSource;
    with LGrid.Columns.Add do
    begin
      FieldName := 'STATUS';
      Width := 96;
    end;
    with LGrid.Columns.Add do
    begin
      FieldName := 'CONCILIADO';
      Width := 72;
    end;
    with LGrid.Columns.Add do
    begin
      FieldName := 'DESCRICAO';
      Width := 280;
    end;
    LForm.Show;
    Application.ProcessMessages;

    for LDensity := Low(TDACDBGridDensity) to High(TDACDBGridDensity) do
    begin
      LGrid.Density := LDensity;
      Application.ProcessMessages;
      ExerciseColumnLayout(LGrid, GetEnumName(TypeInfo(TDACDBGridDensity),
        Ord(LDensity)));
    end;

    LGrid.RecreateNativeHandle;
    Application.ProcessMessages;
    ExerciseColumnLayout(LGrid, 'RecreateWnd');
    LGrid.ScaleForTest(144, 96);
    Application.ProcessMessages;
    ExerciseColumnLayout(LGrid, 'DPI 144');
    LGrid.ScaleForTest(192, 144);
    Application.ProcessMessages;
    ExerciseColumnLayout(LGrid, 'DPI 192');
  finally
    LForm.Free;
  end;
end;

procedure TestNativeBadgeTextMeasurement;
const
  Captions: array[0..3] of string = ('Aberto', 'Fechado', 'Sim', 'Nao');
var
  I: Integer;
  LDC: HDC;
  LSize144: TSize;
  LSize192: TSize;
  LSize96: TSize;
begin
  LDC := GetDC(0);
  try
    Require(LDC <> 0, 'Nao foi possivel obter DC para medir badges.');
    for I := Low(Captions) to High(Captions) do
    begin
      LSize96 := DACMeasureDBGridText(LDC,
        TDACComponentStyle.FontFamily, Captions[I], DACDBGridDefaultFontSize,
        True, 96);
      LSize144 := DACMeasureDBGridText(LDC,
        TDACComponentStyle.FontFamily, Captions[I], DACDBGridDefaultFontSize,
        True, 144);
      LSize192 := DACMeasureDBGridText(LDC,
        TDACComponentStyle.FontFamily, Captions[I], DACDBGridDefaultFontSize,
        True, 192);
      Require((LSize96.cx > 0) and (LSize96.cy > 0),
        Captions[I] + ': medicao nativa invalida.');
      Require((LSize144.cx > LSize96.cx) and (LSize192.cx > LSize144.cx),
        Captions[I] + ': largura nao acompanhou o DPI.');
      Require((LSize144.cy > LSize96.cy) and (LSize192.cy > LSize144.cy),
        Captions[I] + ': altura nao acompanhou o DPI.');
    end;
  finally
    if LDC <> 0 then
      ReleaseDC(0, LDC);
  end;
end;

begin
  try
    Application.Initialize;
    TestDensitySurvivesColumnLayout(False);
    Writeln('OK density with layout disabled');
    TestDensitySurvivesColumnLayout(True);
    Writeln('OK density with layout enabled');
    TestNativeBadgeTextMeasurement;
    Writeln('OK native badge text measurement');
    Writeln('DACDBGridDensityTests: PASS');
  except
    on E: Exception do
    begin
      Writeln('DACDBGridDensityTests: FAIL - ' + E.ClassName + ': ' + E.Message);
      Halt(1);
    end;
  end;
end.
