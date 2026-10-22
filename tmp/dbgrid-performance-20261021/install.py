from pathlib import Path
import shutil

root = Path(r'M:\MaxxSoft\MaxxRural\Desktop\maxxrural')
tests = root / 'MaxxRural/src/Tests'
evidence = tests / 'Resultados/20261021-grid-performance'
evidence.mkdir(parents=True, exist_ok=True)
for name in ['compilar.cmd', 'executar-testes.ps1']:
    shutil.copy2(tests / 'Resultados/20261021-grid-gaps' / name, evidence / name)

def write_ansi(path, text):
    path.write_bytes(text.replace('\r\n', '\n').replace('\n', '\r\n').encode('cp1252'))

source = r'''unit Teste.MovimentoBancario.PerformanceGrid;

interface

uses DUnitX.TestFramework;

type
  [TestFixture]
  TMovimentoBancarioPerformanceGridTests = class
  public
    [TestCase('Prontos100', 'Prontos,100,0')]
    [TestCase('Prontos1001', 'Prontos,1001,0')]
    [TestCase('Prontos5000', 'Prontos,5000,0')]
    [TestCase('Prontos10000', 'Prontos,10000,0')]
    [TestCase('Conciliar1001', 'Conciliar,1001,0')]
    [TestCase('Conciliar5000', 'Conciliar,5000,0')]
    [TestCase('Conciliar10000', 'Conciliar,10000,0')]
    [TestCase('Importados1001', 'Importados,1001,0')]
    [TestCase('Importados5000', 'Importados,5000,0')]
    [TestCase('Importados10000', 'Importados,10000,0')]
    [TestCase('SelecaoUniforme1001', 'Prontos,1001,1')]
    [TestCase('SelecaoUniforme10000', 'Prontos,10000,1')]
    procedure MedirDatasetLocal(const Aba: string; const Quantidade, Checkbox: Integer);
  end;

implementation

uses System.Classes, System.SysUtils, System.Types, System.IOUtils,
  System.RegularExpressions, System.Diagnostics, System.JSON, System.Math,
  System.Generics.Collections, System.Variants, System.DateUtils,
  Winapi.Windows, Winapi.Messages, Winapi.PsAPI, Vcl.Forms, Vcl.Controls,
  Data.DB, Datasnap.DBClient, TestSupport.DACDBGridActions,
  DAC.Components.Controls.DBGrid.Column, DAC.Components.Controls.DBGrid.Types;

function WorkingSetBytes: UInt64;
var Counters: TProcessMemoryCounters;
begin
  FillChar(Counters, SizeOf(Counters), 0); Counters.cb := SizeOf(Counters);
  if not GetProcessMemoryInfo(GetCurrentProcess, @Counters, SizeOf(Counters)) then
    RaiseLastOSError;
  Result := Counters.WorkingSetSize;
end;

function Statistics(const Samples: TArray<Double>): TJSONObject;
var Sorted: TArray<Double>; I: Integer; Total: Double;
begin
  Sorted := Copy(Samples); TArray.Sort<Double>(Sorted); Total := 0;
  for I := 0 to High(Sorted) do Total := Total + Sorted[I];
  Result := TJSONObject.Create;
  Result.AddPair('samples', TJSONNumber.Create(Length(Sorted)));
  Result.AddPair('median_ms', TJSONNumber.Create((Sorted[(Length(Sorted) - 1) div 2] + Sorted[Length(Sorted) div 2]) / 2));
  Result.AddPair('p95_ms', TJSONNumber.Create(Sorted[Ceil(Length(Sorted) * 0.95) - 1]));
  Result.AddPair('max_ms', TJSONNumber.Create(Sorted[High(Sorted)]));
  Result.AddPair('mean_ms', TJSONNumber.Create(Total / Length(Sorted)));
end;

procedure TMovimentoBancarioPerformanceGridTests.MedirDatasetLocal(
  const Aba: string; const Quantidade, Checkbox: Integer);
const SamplesCount = 60;
var F: TForm; G: TDACActionTestGrid; D: TClientDataSet; S: TDataSource;
  Report, Sort: TJSONObject; Sorts: TJSONArray;
  Input: TStringStream; Binary: TMemoryStream;
  Text, Block, OutputDirectory, Key, FileName: string; Match: TMatch;
  Watch: TStopwatch; Samples: TArray<Double>;
  I, J, OptionsIndex, ValueIndex, ControlCount, ComponentCount, Paints, Queries: Integer;
  HandlesBefore, GDIAtStart, UserAtStart: DWORD;
  Bounds: TRect; Accepted: Boolean; Direction: TDACDBGridSortDirection;
  procedure FlushPaint;
  begin
    G.Invalidate; UpdateWindow(G.Handle);
  end;
  procedure Measure(const Kind: string);
  var K, PaintsBefore, ActionsBefore: Integer; P: TPoint; ExpectedKey: string;
  begin
    SetLength(Samples, SamplesCount);
    for K := 0 to High(Samples) do
    begin
      PaintsBefore := G.PaintCount; ActionsBefore := G.Activations;
      ExpectedKey := D.FieldByName('MOV_COD').AsString;
      Bounds := G.ActionRect(OptionsIndex, G.CurrentVisibleRow, 0);
      P := Bounds.CenterPoint;
      Watch := TStopwatch.StartNew;
      if Kind = 'paint' then G.Invalidate
      else if Kind = 'vertical_scroll' then
        SendMessage(G.Handle, WM_VSCROLL, SB_LINEDOWN, 0)
      else if Kind = 'horizontal_scroll' then
      begin
        if K mod 2 = 0 then SendMessage(G.Handle, WM_HSCROLL, SB_RIGHT, 0)
        else SendMessage(G.Handle, WM_HSCROLL, SB_LEFT, 0);
      end
      else if Kind = 'hover' then
      begin
        if K mod 2 = 0 then G.MoveAt(P)
        else G.Perform(CM_MOUSELEAVE, 0, 0);
      end
      else if Kind = 'action' then G.ClickAt(P);
      UpdateWindow(G.Handle); Watch.Stop;
      Samples[K] := Watch.ElapsedTicks * 1000.0 / TStopwatch.Frequency;
      // Assertions run outside the measured interval.
      if Kind = 'action' then
      begin
        Assert.IsFalse(Bounds.IsEmpty);
        Assert.AreEqual(ActionsBefore + 1, G.Activations);
        Assert.AreEqual(ExpectedKey, VarToStr(G.LastContext.ValueOf('MOV_COD')));
        Assert.AreEqual('0000000007', VarToStr(G.LastContext.ValueOf('COD_EMP')));
        Assert.IsTrue(G.LastContext.HasCompleteKey);
      end
      else if Kind = 'vertical_scroll' then
        Assert.AreNotEqual(ExpectedKey, D.FieldByName('MOV_COD').AsString);
      if Kind = 'paint' then Assert.IsTrue(G.PaintCount > PaintsBefore);
    end;
    Report.AddPair(Kind, Statistics(Samples));
  end;
begin
  Application.Initialize;
  Report := TJSONObject.Create; F := nil; G := nil; D := nil;
  Input := nil; Binary := nil;
  try
    Report.AddPair('page', Aba);
    Report.AddPair('rows', TJSONNumber.Create(Quantidade));
    Report.AddPair('checkbox_uniform_false', TJSONBool.Create(Checkbox <> 0));
    Report.AddPair('timestamp_local', DateToISO8601(Now, False));
    Report.AddPair('build', 'Debug Win32 / Rebuild / Delphi 10.2');
    Report.AddPair('timing', 'QPC: synchronous input or invalidation through native UpdateWindow; no API or database');
    F := TForm.CreateNew(nil); F.SetBounds(30, 30, 1010, 460);
    F.Caption := Format('Performance TDACDBGrid - %s - %d registros', [Aba, Quantidade]);
    F.FormStyle := fsStayOnTop;
    G := TDACActionTestGrid.Create(F); G.Parent := F;
    Text := TFile.ReadAllText(TPath.GetFullPath(ExtractFilePath(ParamStr(0)) +
      '..\source\view\View.MovimentoBancario.dfm'), TEncoding.GetEncoding(1252));
    Match := TRegEx.Match(Text, '(?ms)^        object grdMovimentos' + Aba + ': TDACDBGrid\r?\n.*?^        end\r?$');
    Assert.IsTrue(Match.Success, 'Grid nao localizada no DFM real.');
    Block := TRegEx.Replace(Match.Value, '(?m)^\s*DataSource = [^\r\n]+\r?\n', '');
    Input := TStringStream.Create(Block, TEncoding.UTF8); Binary := TMemoryStream.Create;
    ObjectTextToBinary(Input, Binary); Binary.Position := 0; Binary.ReadComponent(G);
    // Layout persistence is disabled only in this isolated benchmark.
    G.Layout.Enabled := False; G.Align := alNone; G.SetBounds(8, 8, 980, 390);
    G.SetTestPPI(96);
    Assert.AreEqual(12, G.Columns.Count);
    OptionsIndex := -1; ValueIndex := -1;
    for I := 0 to G.Columns.Count - 1 do
    begin
      if G.Columns[I].LayoutKey = 'OPCOES' then OptionsIndex := I;
      if G.Columns[I].FieldName = 'MOV_VALOR' then ValueIndex := I;
    end;
    Assert.IsTrue((OptionsIndex >= 0) and (ValueIndex >= 0));
    Assert.AreEqual(dgpRight, G.Columns[OptionsIndex].PinPosition);
    Assert.AreEqual(3, G.Columns[OptionsIndex].Actions.Count);
    Assert.IsFalse(G.Columns[OptionsIndex].Sortable);
    ControlCount := G.ControlCount; ComponentCount := G.ComponentCount;
    GDIAtStart := GetGuiResources(GetCurrentProcess, GR_GDIOBJECTS);
    UserAtStart := GetGuiResources(GetCurrentProcess, GR_USEROBJECTS);
    Report.AddPair('working_set_before_dataset_bytes', TJSONNumber.Create(WorkingSetBytes));
    Watch := TStopwatch.StartNew;
    D := TClientDataSet.Create(F);
    D.FieldDefs.Add('COD_EMP', ftString, 10);
    D.FieldDefs.Add('MOV_COD', ftString, 10);
    D.FieldDefs.Add('MOVIMENTOFECHADO', ftString, 20);
    D.FieldDefs.Add('MOV_CONS', ftString, 3);
    D.FieldDefs.Add('MOV_DATA', ftDate);
    D.FieldDefs.Add('HIST_DESC', ftString, 150);
    D.FieldDefs.Add('TPGTO_ABRE', ftString, 8);
    D.FieldDefs.Add('MOV_VALOR', ftCurrency);
    D.FieldDefs.Add('MOV_TIPO', ftString, 12);
    D.FieldDefs.Add('MOV_DTCONS', ftDate);
    D.FieldDefs.Add('CHEQUE_NUM', ftString, 12);
    D.FieldDefs.Add('MOV_HISTCOMPL', ftMemo);
    D.FieldDefs.Add('SELECIONADO', ftBoolean);
    D.CreateDataSet; D.DisableControls;
    try
      for I := 1 to Quantidade do
      begin
        D.Append;
        D.FieldByName('COD_EMP').AsString := '0000000007';
        D.FieldByName('MOV_COD').AsString := Format('%.10d', [I]);
        D.FieldByName('MOVIMENTOFECHADO').AsString := 'ABERTO';
        D.FieldByName('MOV_CONS').AsString := 'SIM';
        D.FieldByName('MOV_DATA').AsDateTime := EncodeDate(2025, 1, 1) + I mod 600;
        D.FieldByName('HIST_DESC').AsString := Format('Transferencia %d - conciliacao e movimentacao bancaria', [I]);
        D.FieldByName('TPGTO_ABRE').AsString := 'TC';
        if I mod 17 <> 0 then
          D.FieldByName('MOV_VALOR').AsCurrency := ((I * 7919) mod 100000 - 50000) / 100;
        D.FieldByName('MOV_TIPO').AsString := 'CREDITO';
        if I mod 3 = 0 then D.FieldByName('MOV_DTCONS').AsDateTime := EncodeDate(2026, 1, 1) + I mod 300;
        D.FieldByName('CHEQUE_NUM').AsString := Format('%.10d', [I mod 90]);
        D.FieldByName('MOV_HISTCOMPL').AsString := Format('Registro %d. ', [I]) + StringOfChar('x', 400);
        D.FieldByName('SELECIONADO').AsBoolean := False;
        D.Post;
      end;
      D.First;
    finally D.EnableControls; end;
    Watch.Stop;
    Report.AddPair('dataset_load_ms', TJSONNumber.Create(Watch.ElapsedTicks * 1000.0 / TStopwatch.Frequency));
    Assert.AreEqual(Quantidade, D.RecordCount);
    if Checkbox <> 0 then
    begin G.Selection.FieldName := 'SELECIONADO'; G.Selection.Enabled := True; end;
    S := TDataSource.Create(F); S.DataSet := D;
    F.Show; G.SetFocus; Application.ProcessMessages;
    Watch := TStopwatch.StartNew;
    G.DataSource := S; FlushPaint;
    Watch.Stop;
    Report.AddPair('attach_first_paint_ms', TJSONNumber.Create(Watch.ElapsedTicks * 1000.0 / TStopwatch.Frequency));
    for I := 1 to 8 do FlushPaint;
    Paints := G.PaintCount; Queries := G.StateQueries;
    FlushPaint;
    Report.AddPair('action_state_queries_one_paint', TJSONNumber.Create(G.StateQueries - Queries));
    Assert.AreEqual(Paints + 1, G.PaintCount);
    Assert.IsTrue(G.StateQueries - Queries < 100, 'Uma pintura consultou mais que o viewport.');
    Measure('paint');
    D.First; FlushPaint; Measure('vertical_scroll');
    Measure('horizontal_scroll');
    Measure('hover');
    Watch := TStopwatch.StartNew;
    D.First; D.MoveBy(Quantidade div 2); UpdateWindow(G.Handle); Watch.Stop;
    Report.AddPair('jump_middle_ms', TJSONNumber.Create(Watch.ElapsedTicks * 1000.0 / TStopwatch.Frequency));
    Watch := TStopwatch.StartNew;
    D.Last; UpdateWindow(G.Handle); Watch.Stop;
    Report.AddPair('jump_last_ms', TJSONNumber.Create(Watch.ElapsedTicks * 1000.0 / TStopwatch.Frequency));
    Assert.AreEqual(Format('%.10d', [Quantidade]), D.FieldByName('MOV_COD').AsString);
    Measure('action');
    Assert.AreEqual(0, G.SortRequests, 'Scroll, hover ou acao disparou ordenacao.');
    Key := D.FieldByName('MOV_COD').AsString;
    Sorts := TJSONArray.Create; Report.AddPair('sort', Sorts);
    for J := 0 to 5 do
    begin
      if J mod 2 = 0 then Direction := dgsAscending else Direction := dgsDescending;
      Watch := TStopwatch.StartNew;
      Accepted := G.RequestSort(ValueIndex, Direction); UpdateWindow(G.Handle);
      Watch.Stop;
      Sort := TJSONObject.Create; Sorts.AddElement(Sort);
      Sort.AddPair('iteration', TJSONNumber.Create(J + 1));
      Sort.AddPair('ms', TJSONNumber.Create(Watch.ElapsedTicks * 1000.0 / TStopwatch.Frequency));
      Assert.IsTrue(Accepted);
      Assert.AreEqual(J + 1, G.SortRequests);
      Assert.AreEqual(Key, D.FieldByName('MOV_COD').AsString, 'Ordenacao perdeu identidade.');
    end;
    Measure('action'); // Also exercise actions after reordering, under a distinct metric key below.
    Report.RemovePair('action').Free;
    Report.AddPair('action_before_sort', Statistics(Samples));
    // The surviving action metric is from before sort; rename accurately.
    // Both action workloads have the same functional assertions.
    Report.AddPair('grid_controls_before', TJSONNumber.Create(ControlCount));
    Report.AddPair('grid_controls_after', TJSONNumber.Create(G.ControlCount));
    Report.AddPair('grid_components_before', TJSONNumber.Create(ComponentCount));
    Report.AddPair('grid_components_after', TJSONNumber.Create(G.ComponentCount));
    Assert.AreEqual(ControlCount, G.ControlCount, 'Controles cresceram por registro.');
    Assert.AreEqual(ComponentCount, G.ComponentCount, 'Componentes cresceram por registro.');
    Report.AddPair('working_set_loaded_bytes', TJSONNumber.Create(WorkingSetBytes));
    HandlesBefore := GetGuiResources(GetCurrentProcess, GR_GDIOBJECTS);
    Report.AddPair('gdi_objects_before', TJSONNumber.Create(GDIAtStart));
    Report.AddPair('gdi_objects_loaded', TJSONNumber.Create(HandlesBefore));
    Report.AddPair('user_objects_before', TJSONNumber.Create(UserAtStart));
    Report.AddPair('user_objects_loaded', TJSONNumber.Create(GetGuiResources(GetCurrentProcess, GR_USEROBJECTS)));
    Report.AddPair('viewport_width_px', TJSONNumber.Create(G.FullClientRect.Width));
    Report.AddPair('viewport_height_px', TJSONNumber.Create(G.FullClientRect.Height));
    Report.AddPair('ppi', TJSONNumber.Create(96));
    Report.AddPair('assertions_passed', TJSONBool.Create(True));
    F.Free; F := nil;
    Report.AddPair('working_set_after_free_bytes', TJSONNumber.Create(WorkingSetBytes));
    Report.AddPair('gdi_objects_after_free', TJSONNumber.Create(GetGuiResources(GetCurrentProcess, GR_GDIOBJECTS)));
    Report.AddPair('user_objects_after_free', TJSONNumber.Create(GetGuiResources(GetCurrentProcess, GR_USEROBJECTS)));
    OutputDirectory := GetEnvironmentVariable('DAC_GRID_PERF_OUTPUT_DIR');
    if OutputDirectory = '' then OutputDirectory := TPath.GetFullPath(ExtractFilePath(ParamStr(0)) +
      '..\MaxxRural\src\Tests\Resultados\grid-performance');
    ForceDirectories(OutputDirectory);
    FileName := TPath.Combine(OutputDirectory, Format('%s-%d-checkbox%d.json', [Aba, Quantidade, Checkbox]));
    TFile.WriteAllText(FileName, Report.ToJSON, TEncoding.UTF8);
  finally Binary.Free; Input.Free; F.Free; Report.Free; end;
end;

initialization
  TDUnitX.RegisterTestFixture(TMovimentoBancarioPerformanceGridTests);
end.
'''
# Separate the two action measurements so no duplicate JSON keys are emitted.
source = source.replace("else if Kind = 'action' then", "else if (Kind = 'action') or (Kind = 'action_after_sort') then")
source = source.replace("if Kind = 'action' then", "if (Kind = 'action') or (Kind = 'action_after_sort') then")
start = source.index("    Measure('action'); // Also")
end = source.index("    Report.AddPair('grid_controls_before'", start)
source = source[:start] + "    Measure('action_after_sort');\n" + source[end:]
write_ansi(tests / 'Teste.MovimentoBancario.PerformanceGrid.pas', source)
dpr = tests / 'ApiTestes.dpr'
text = dpr.read_bytes().decode('cp1252')
entry = "  Teste.MovimentoBancario.PerformanceGrid in 'Teste.MovimentoBancario.PerformanceGrid.pas',"
if entry not in text:
    text = text.replace("  Teste.MovimentoBancario.ColunasGrid in", entry + '\r\n' + "  Teste.MovimentoBancario.ColunasGrid in")
    write_ansi(dpr, text)
print('Installed benchmark in official ApiTestes:', evidence)

runner = r'''param([int]$Inicio = 1, [int]$Fim = 3)
$ErrorActionPreference = 'Stop'
if ($Inicio -lt 1 -or $Fim -lt $Inicio) { throw 'Intervalo de execucoes invalido.' }
$previousOutput = [Environment]::GetEnvironmentVariable('DAC_GRID_PERF_OUTPUT_DIR', 'Process')
try {
  for ($iteration = $Inicio; $iteration -le $Fim; $iteration++) {
    $runName = 'run{0:d2}' -f $iteration
    $env:DAC_GRID_PERF_OUTPUT_DIR = Join-Path $PSScriptRoot $runName
    & 'M:\MaxxSoft\MaxxRural\Desktop\maxxrural\EXE\ApiTestes.exe' '--run:Teste.MovimentoBancario.PerformanceGrid.TMovimentoBancarioPerformanceGridTests' '--exit:Continue' "--xml:$PSScriptRoot\$runName.xml" *> "$PSScriptRoot\$runName.log"
    $runExit = $LASTEXITCODE
    Get-Content -LiteralPath "$PSScriptRoot\$runName.log" -Tail 8
    if ($runExit -ne 0) { exit $runExit }
  }
} finally {
  [Environment]::SetEnvironmentVariable('DAC_GRID_PERF_OUTPUT_DIR', $previousOutput, 'Process')
}
exit 0
'''
write_ansi(evidence / 'executar-performance.ps1', runner)
suite = (evidence / 'executar-testes.ps1').read_bytes().decode('cp1252')
suite = suite.replace('try {', "$previousOutput = [Environment]::GetEnvironmentVariable('DAC_GRID_PERF_OUTPUT_DIR', 'Process')\r\ntry {", 1)
suite = suite.replace('    $env:MOVIMENTACAO_BANCARIA_TEST_DB = $testDatabase', "    $env:DAC_GRID_PERF_OUTPUT_DIR = Join-Path $PSScriptRoot 'suite-performance'\r\n    $env:MOVIMENTACAO_BANCARIA_TEST_DB = $testDatabase")
suite = suite.replace('} finally {', "} finally {\r\n    [Environment]::SetEnvironmentVariable('DAC_GRID_PERF_OUTPUT_DIR', $previousOutput, 'Process')")
write_ansi(evidence / 'executar-testes.ps1', suite)
