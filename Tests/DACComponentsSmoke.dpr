program DACComponentsSmoke;

{$APPTYPE CONSOLE}

uses
  System.Classes,
  System.SysUtils,
  Data.DB,
  Datasnap.DBClient,
  Vcl.DBGrids,
  DAC.Components.Controls.DataAware in '..\Source\Controls\DataAware\DAC.Components.Controls.DataAware.pas',
  DAC.Components.Controls.DataAware.Lookup in '..\Source\Controls\DataAware\DAC.Components.Controls.DataAware.Lookup.pas',
  DAC.Components.Controls.DataAware.Navigator in '..\Source\Controls\DataAware\DAC.Components.Controls.DataAware.Navigator.pas',
  DAC.Components.Controls.DataGridColumns in '..\Source\Controls\DAC.Components.Controls.DataGridColumns.pas',
  DAC.Components.Controls.StatusTimelineChart in '..\Source\Controls\DAC.Components.Controls.StatusTimelineChart.pas',
  DAC.Components.Controls.Register in '..\Source\Controls\DAC.Components.Controls.Register.pas';

procedure Require(const ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create(AMessage);
end;

function FindScrollContainerSource: string;
const
  CRelativePath = 'Source\Controls\DAC.Components.Controls.ScrollContainer.pas';
var
  LCandidate: string;
  LDirectory: string;
  LParent: string;
  I: Integer;
begin
  Result := '';
  LDirectory := GetCurrentDir;
  for I := 0 to 1 do
  begin
    LCandidate := IncludeTrailingPathDelimiter(LDirectory) + CRelativePath;
    if FileExists(LCandidate) then
    begin
      Result := LCandidate;
      Exit;
    end;
    LDirectory := ExtractFileDir(ParamStr(0));
  end;

  for I := 0 to 6 do
  begin
    LCandidate := IncludeTrailingPathDelimiter(LDirectory) + CRelativePath;
    if FileExists(LCandidate) then
    begin
      Result := LCandidate;
      Exit;
    end;
    LParent := ExtractFileDir(LDirectory);
    if SameText(LParent, LDirectory) then
      Break;
    LDirectory := LParent;
  end;
end;

function ExtractSourceSection(const ASource, AStartMarker,
  AEndMarker: string): string;
var
  LEnd: Integer;
  LStart: Integer;
begin
  LStart := Pos(UpperCase(AStartMarker), UpperCase(ASource));
  Require(LStart > 0, 'Marcador inicial ausente: ' + AStartMarker);
  LEnd := Pos(UpperCase(AEndMarker), UpperCase(Copy(ASource, LStart,
    MaxInt)));
  Require(LEnd > 0, 'Marcador final ausente: ' + AEndMarker);
  Result := Copy(ASource, LStart, LEnd - 1);
end;

procedure RequireLocalizedScrollContainerInvalidation;
var
  LApplyTheme: string;
  LFile: TStringList;
  LPath: string;
  LRedrawChrome: string;
  LSource: string;

  procedure RequireLocalizedFlags(const AMethodName, ASection: string);
  var
    LUpperSection: string;
  begin
    LUpperSection := UpperCase(ASection);
    Require(Pos('RDW_INVALIDATE', LUpperSection) > 0,
      AMethodName + ' deve invalidar a janela.');
    Require(Pos('RDW_FRAME', LUpperSection) > 0,
      AMethodName + ' deve invalidar o frame.');
    Require(Pos('RDW_ERASE', LUpperSection) = 0,
      AMethodName + ' nao pode apagar a subtree.');
    Require(Pos('RDW_ALLCHILDREN', LUpperSection) = 0,
      AMethodName + ' nao pode invalidar toda a subtree.');
  end;

begin
  LPath := FindScrollContainerSource;
  Require(LPath <> '',
    'Fonte do TDACScrollContainer nao localizado para regressao de repaint.');
  LFile := TStringList.Create;
  try
    LFile.LoadFromFile(LPath);
    LSource := LFile.Text;
  finally
    LFile.Free;
  end;
  LApplyTheme := ExtractSourceSection(LSource,
    'procedure TDACScrollContainer.ApplyTheme;',
    'procedure TDACScrollContainer.SetAppearance');
  LRedrawChrome := ExtractSourceSection(LSource,
    'procedure TDACScrollContainer.RedrawChrome;',
    'procedure TDACScrollContainer.Resize;');
  RequireLocalizedFlags('ApplyTheme', LApplyTheme);
  RequireLocalizedFlags('RedrawChrome', LRedrawChrome);
end;

procedure RunSmoke;
var
  LDataSet: TClientDataSet;
  LDataSource: TDataSource;
  LGrid: TDBGrid;
  I: Integer;
begin
  RequireLocalizedScrollContainerInvalidation;
  Require(GetClass('TDACDBEdit') = TDACDBEdit,
    'Registry nao disponibilizou TDACDBEdit.');
  Require(GetClass('TDACDBMemo') = TDACDBMemo,
    'Registry nao disponibilizou TDACDBMemo.');
  Require(GetClass('TDACDBButtonEdit') = TDACDBButtonEdit,
    'Registry nao disponibilizou TDACDBButtonEdit.');
  Require(GetClass('TDACDBComboBox') = TDACDBComboBox,
    'Registry nao disponibilizou TDACDBComboBox.');
  Require(GetClass('TDACDBDateTimePicker') = TDACDBDateTimePicker,
    'Registry nao disponibilizou TDACDBDateTimePicker.');
  Require(GetClass('TDACDBCheckBox') = TDACDBCheckBox,
    'Registry nao disponibilizou TDACDBCheckBox.');
  Require(GetClass('TDACDBRadioButton') = TDACDBRadioButton,
    'Registry nao disponibilizou TDACDBRadioButton.');
  Require(GetClass('TDACDBToggleSwitch') = TDACDBToggleSwitch,
    'Registry nao disponibilizou TDACDBToggleSwitch.');
  Require(GetClass('TDACDBSlider') = TDACDBSlider,
    'Registry nao disponibilizou TDACDBSlider.');
  Require(GetClass('TDACDBText') = TDACDBText,
    'Registry nao disponibilizou TDACDBText.');
  Require(GetClass('TDACDBLookupComboBox') = TDACDBLookupComboBox,
    'Registry nao disponibilizou TDACDBLookupComboBox.');
  Require(GetClass('TDACDBNavigator') = TDACDBNavigator,
    'Registry nao disponibilizou TDACDBNavigator.');
  Require(GetClass('TDACStatusTimelineChart') = TDACStatusTimelineChart,
    'Registry nao disponibilizou TDACStatusTimelineChart.');

  LDataSet := TClientDataSet.Create(nil);
  LDataSource := TDataSource.Create(nil);
  LGrid := TDBGrid.Create(nil);
  try
    LDataSet.FieldDefs.Add('ID', ftInteger);
    LDataSet.FieldDefs.Add('STATUS', ftString, 16);
    LDataSet.FieldDefs.Add('ACTIONS', ftString, 16);
    LDataSet.CreateDataSet;
    for I := 1 to 30 do
      LDataSet.AppendRecord([I, 'Ativo', '...']);
    LDataSource.DataSet := LDataSet;
    LGrid.DataSource := LDataSource;
    Require(LGrid.Columns.Count = 3,
      'O TDBGrid nao gerou as colunas automaticas esperadas.');
    Require(TDACDataGridColumnResolver.Count(LGrid) = 3,
      'Campos automaticos visiveis nao foram enumerados.');
    Require(TDACDataGridColumnResolver.FieldAt(LGrid, 0) = LDataSet.Fields[0],
      'A primeira coluna automatica nao corresponde ao campo ID.');
    Require(TDACDataGridColumnResolver.FieldAt(LGrid, 1) = LDataSet.Fields[1],
      'A segunda coluna automatica nao corresponde ao campo STATUS.');
    Require(TDACDataGridColumnResolver.FieldAt(LGrid, 2) = LDataSet.Fields[2],
      'A terceira coluna automatica nao corresponde ao campo ACTIONS.');

    LDataSet.Fields[1].Visible := False;
    Require(TDACDataGridColumnResolver.Count(LGrid) = 2,
      'Campo automatico invisivel nao foi excluido da grade.');
    Require(TDACDataGridColumnResolver.FieldAt(LGrid, 1) = LDataSet.Fields[2],
      'A ordem das colunas automaticas visiveis nao foi preservada.');
  finally
    LGrid.Free;
    LDataSource.Free;
    LDataSet.Free;
  end;
end;

var
  LExitCode: Integer;

begin
  LExitCode := 0;
  try
    RunSmoke;
    Writeln('DACComponentsSmoke: PASS');
  except
    on E: Exception do
    begin
      Writeln(E.ClassName + ': ' + E.Message);
      LExitCode := 1;
    end;
  end;
  ExitCode := LExitCode;
end.
