program DACComponentsSmoke;

{$APPTYPE CONSOLE}

uses
  System.Classes,
  System.SysUtils,
  Data.DB,
  Datasnap.DBClient,
  Vcl.DBGrids,
  DAC.Components.Dpi in '..\Source\Core\DAC.Components.Dpi.pas',
  DAC.Components.Controls.DataGridColumns in '..\Source\Controls\DAC.Components.Controls.DataGridColumns.pas';

procedure Require(const ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create(AMessage);
end;

procedure RunSmoke;
var
  LDataSet: TClientDataSet;
  LDataSource: TDataSource;
  LGrid: TDBGrid;
  I: Integer;
begin
  Require(DACScale(36, 144) = 54, 'DACScale 144 PPI invalido.');
  Require(DACScale(36, 0) = 36, 'DACScale deve normalizar PPI invalido.');
  Require(Abs(DACScaleF(36, 120) - 45) < 0.01,
    'DACScaleF 120 PPI invalido.');

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
