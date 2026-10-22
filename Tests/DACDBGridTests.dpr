program DACDBGridTests;

{$APPTYPE CONSOLE}

uses
  System.Classes,
  System.IOUtils,
  System.SysUtils,
  Data.DB,
  Datasnap.DBClient,
  MidasLib,
  Winapi.Messages,
  Winapi.Windows,
  Vcl.Forms,
  Vcl.DBGrids,
  Vcl.Graphics,
  DAC.Components.Controls.DBGrid in '..\Source\Controls\DAC.Components.Controls.DBGrid.pas',
  DAC.Components.Controls.DBGrid.Column in '..\Source\Controls\DAC.Components.Controls.DBGrid.Column.pas',
  DAC.Components.Controls.DBGrid.LayoutFileStore in '..\Source\Controls\DAC.Components.Controls.DBGrid.LayoutFileStore.pas',
  DAC.Components.Controls.DBGrid.LayoutSerializer in '..\Source\Controls\DAC.Components.Controls.DBGrid.LayoutSerializer.pas',
  DAC.Components.Controls.DBGrid.SelectionController in '..\Source\Controls\DAC.Components.Controls.DBGrid.SelectionController.pas',
  DAC.Components.Controls.DBGrid.SelectionOptions in '..\Source\Controls\DAC.Components.Controls.DBGrid.SelectionOptions.pas',
  DAC.Components.Controls.DBGrid.SortController in '..\Source\Controls\DAC.Components.Controls.DBGrid.SortController.pas',
  DAC.Components.Controls.DBGrid.Types in '..\Source\Controls\DAC.Components.Controls.DBGrid.Types.pas';

type
  TTestDACDBGrid = class(TDACDBGrid)
  public
    function IsReadOnly: Boolean;
    function NativeOptions: TDBGridOptions;
    function NativeFontSize: Integer;
    function NativeTitleFontSize: Integer;
  end;

  TSelectionProbe = class
  public
    Count: Integer;
    LastChecked: Boolean;
    procedure SelectionChanged(Sender: TObject; AField: TField;
      const AChecked: Boolean);
  end;

procedure TSelectionProbe.SelectionChanged(Sender: TObject; AField: TField;
  const AChecked: Boolean);
begin
  Inc(Count);
  LastChecked := AChecked;
end;

function TTestDACDBGrid.IsReadOnly: Boolean;
begin
  Result := ReadOnly;
end;

function TTestDACDBGrid.NativeFontSize: Integer;
begin
  Result := Font.Size;
end;

function TTestDACDBGrid.NativeOptions: TDBGridOptions;
begin
  Result := Options;
end;

function TTestDACDBGrid.NativeTitleFontSize: Integer;
begin
  Result := TitleFont.Size;
end;

procedure Require(const ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create(AMessage);
end;

procedure PopulateDataSet(ADataSet: TClientDataSet);
var
  I: Integer;
begin
  ADataSet.FieldDefs.Add('ID', ftInteger);
  ADataSet.FieldDefs.Add('SELECTED', ftBoolean);
  ADataSet.FieldDefs.Add('NAME', ftString, 40);
  ADataSet.CreateDataSet;
  for I := 1 to 3 do
  begin
    ADataSet.Append;
    ADataSet.FieldByName('ID').AsInteger := I;
    ADataSet.FieldByName('SELECTED').AsBoolean := False;
    ADataSet.FieldByName('NAME').AsString := 'Item ' + IntToStr(I);
    ADataSet.Post;
  end;
  ADataSet.First;
end;

procedure TestSortController;
var
  LController: TDACDBGridSortController;
begin
  LController := TDACDBGridSortController.Create;
  try
    Require(LController.NextDirection('name') = dgsAscending,
      'Primeiro ciclo de ordenação deve ser ascendente.');
    LController.Accept('name', dgsAscending);
    Require(LController.NextDirection('name') = dgsDescending,
      'Segundo ciclo de ordenação deve ser descendente.');
    LController.Accept('name', dgsDescending);
    Require(LController.NextDirection('name') = dgsAscending,
      'Terceiro ciclo de ordenacao deve voltar ao sentido ascendente.');
    LController.Accept('name', dgsNone);
    Require((LController.Key = '') and
      (LController.Direction = dgsNone),
      'Ordenação removida não pode deixar estado visual residual.');
  finally
    LController.Free;
  end;
end;

procedure TestSelectionController;
var
  LChecked: Boolean;
  LController: TDACDBGridSelectionController;
  LDataSet: TClientDataSet;
  LField: TField;
  LOptions: TDACDBGridSelectionOptions;
  LRaised: Boolean;
begin
  LDataSet := TClientDataSet.Create(nil);
  LOptions := TDACDBGridSelectionOptions.Create;
  LController := TDACDBGridSelectionController.Create;
  try
    PopulateDataSet(LDataSet);
    LOptions.Enabled := True;
    LOptions.FieldName := 'SELECTED';
    Require(LController.CalculateState(LDataSet, LOptions) = dgssUnchecked,
      'Estado inicial da seleção deve ser vazio.');
    Require(LController.ToggleCurrent(LDataSet, LOptions, LField, LChecked),
      'Seleção individual não foi executada.');
    Require(LChecked and (LField = LDataSet.FieldByName('SELECTED')),
      'Seleção individual não atualizou o Boolean configurado.');
    Require(LController.CalculateState(LDataSet, LOptions) = dgssMixed,
      'Seleção parcial deve produzir estado tri-state.');
    LController.SetAll(LDataSet, LOptions, True);
    Require(LController.CalculateState(LDataSet, LOptions) = dgssChecked,
      'Selecionar todos não marcou todos os registros.');

    LDataSet.Edit;
    LDataSet.FieldByName('NAME').AsString := 'Edição preservada';
    LRaised := False;
    try
      LController.SetAll(LDataSet, LOptions, False);
    except
      on E: EDatabaseError do
        LRaised := True;
    end;
    Require(LRaised and (LDataSet.State = dsEdit),
      'Seleção em massa não pode confirmar uma edição preexistente.');
    Require(LDataSet.FieldByName('NAME').AsString = 'Edição preservada',
      'Seleção em massa alterou o buffer de edição preexistente.');
    LDataSet.Cancel;
  finally
    LController.Free;
    LOptions.Free;
    LDataSet.Free;
  end;
end;

procedure TestSerializerAndStore;
var
  LCatalog: TDACDBGridLayoutCatalog;
  LFileName: string;
  LJSON: string;
  LLoaded: TDACDBGridLayoutCatalog;
  LStore: TDACDBGridLayoutFileStore;
begin
  LCatalog.Version := DACDBGridLayoutVersion;
  SetLength(LCatalog.Entries, 1);
  LCatalog.Entries[0].Identity := 'usuario|form|grid';
  LCatalog.Entries[0].Snapshot.Version := DACDBGridLayoutVersion;
  LCatalog.Entries[0].Snapshot.SortKey := 'name';
  LCatalog.Entries[0].Snapshot.SortDirection := dgsDescending;
  SetLength(LCatalog.Entries[0].Snapshot.Columns, 1);
  LCatalog.Entries[0].Snapshot.Columns[0].Key := 'name';
  LCatalog.Entries[0].Snapshot.Columns[0].DisplayIndex := 0;
  LCatalog.Entries[0].Snapshot.Columns[0].LogicalWidth := 180;
  LCatalog.Entries[0].Snapshot.Columns[0].Visible := True;
  LJSON := TDACDBGridLayoutSerializer.Serialize(LCatalog);
  Require(TDACDBGridLayoutSerializer.Deserialize(LJSON, LLoaded),
    'Round-trip JSON do layout falhou.');
  Require((Length(LLoaded.Entries) = 1) and
    (LLoaded.Entries[0].Snapshot.SortDirection = dgsDescending) and
    (LLoaded.Entries[0].Snapshot.Columns[0].LogicalWidth = 180),
    'Round-trip JSON alterou dados do layout.');
  Require(TDACDBGridLayoutSerializer.Deserialize(
    '{"version":1,"entries":[{"identity":"x","sortDirection":99}]}',
    LLoaded) and
    (LLoaded.Entries[0].Snapshot.SortDirection = dgsNone),
    'JSON inválido deve normalizar a direção de ordenação.');

  LStore := TDACDBGridLayoutFileStore.Create;
  LFileName := TPath.Combine(TPath.GetTempPath,
    'dac-dbgrid-layout-test-' + IntToStr(GetCurrentProcessId) + '.json');
  try
    LStore.SaveText(LFileName, LJSON);
    Require(LStore.LoadText(LFileName) = LJSON,
      'File store não preservou o JSON salvo atomicamente.');
  finally
    if TFile.Exists(LFileName) then
      TFile.Delete(LFileName);
    LStore.Free;
  end;
end;

procedure TestGridLifecycle;
var
  LColumn: TDACDBGridColumn;
  LBitmap: TBitmap;
  LDataSet: TClientDataSet;
  LDataSource: TDataSource;
  LDC: HDC;
  LForm: TForm;
  LGrid: TTestDACDBGrid;
  LProbe: TSelectionProbe;
  LSmokeDirectory: string;
  LSmokeFile: string;
begin
  Require(TDACDBGrid.InheritsFrom(TCustomDBGrid),
    'TDACDBGrid deve herdar diretamente da infraestrutura do TCustomDBGrid.');
  LForm := TForm.Create(nil);
  LDataSet := TClientDataSet.Create(LForm);
  LDataSource := TDataSource.Create(LForm);
  LGrid := TTestDACDBGrid.Create(LForm);
  LProbe := TSelectionProbe.Create;
  try
    PopulateDataSet(LDataSet);
    LDataSource.DataSet := LDataSet;
    LGrid.Name := 'TestGrid';
    LGrid.Parent := LForm;
    LGrid.SetBounds(8, 8, 520, 220);
    LGrid.Layout.Enabled := False;
    LGrid.DataSource := LDataSource;
    LColumn := LGrid.Columns.Add;
    LColumn.FieldName := 'ID';
    LColumn.LayoutKey := 'id';
    LColumn.Width := 80;
    LColumn := LGrid.Columns.Add;
    LColumn.FieldName := 'SELECTED';
    LColumn.LayoutKey := 'selected';
    LColumn.BadgeMode := dbmBooleanPreset;
    LColumn.Width := 120;
    LColumn := LGrid.Columns.Add;
    LColumn.FieldName := 'NAME';
    LColumn.LayoutKey := 'name';
    LColumn.Width := 220;
    LGrid.Selection.FieldName := 'SELECTED';
    LGrid.Selection.Enabled := True;
    LGrid.OnSelectionChanged := LProbe.SelectionChanged;
    Require(LGrid.IsReadOnly,
      'TDACDBGrid deve ser estruturalmente read-only.');
    Require(not (dgEditing in LGrid.NativeOptions) and
      not (dgAlwaysShowEditor in LGrid.NativeOptions),
      'TDACDBGrid não pode habilitar editor nativo.');
    Require((LGrid.NativeFontSize = DACDBGridDefaultFontSize) and
      (LGrid.NativeTitleFontSize = DACDBGridDefaultFontSize),
      'Grid e header devem usar fonte VCL tamanho 8.');
    Require(LGrid.Columns[0] is TDACDBGridColumn,
      'Streaming de colunas deve criar TDACDBGridColumn.');
    LForm.Show;
    Application.ProcessMessages;
    LGrid.Update;
    Require(LGrid.HandleAllocated and LGrid.Visible,
      'Grid não concluiu o lifecycle de runtime.');
    LBitmap := TBitmap.Create;
    try
      LBitmap.PixelFormat := pf32bit;
      LBitmap.SetSize(LGrid.Width, LGrid.Height);
      LDC := GetDC(LGrid.Handle);
      try
        Require(LDC <> 0, 'Não foi possível capturar o HWND da grid.');
        BitBlt(LBitmap.Canvas.Handle, 0, 0, LGrid.Width, LGrid.Height,
          LDC, 0, 0, SRCCOPY);
      finally
        if LDC <> 0 then
          ReleaseDC(LGrid.Handle, LDC);
      end;
      Require(LBitmap.Canvas.Pixels[0, 0] <>
        LBitmap.Canvas.Pixels[LGrid.Width div 2, 12],
        'Smoke visual não encontrou separação entre parent e header.');
      LSmokeDirectory := TPath.Combine(GetEnvironmentVariable('TEMP'),
        'DACDBGrid-Tests');
      if LSmokeDirectory = 'DACDBGrid-Tests' then
        LSmokeDirectory := TPath.Combine(GetCurrentDir, 'DACDBGrid-Tests');
      TDirectory.CreateDirectory(LSmokeDirectory);
      LSmokeFile := TPath.Combine(LSmokeDirectory,
        'DACDBGrid-visual-smoke.bmp');
      LBitmap.SaveToFile(LSmokeFile);
    finally
      LBitmap.Free;
    end;
    LGrid.SetFocus;
    SendMessage(LGrid.Handle, WM_KEYDOWN, VK_SPACE, 0);
    SendMessage(LGrid.Handle, WM_KEYUP, VK_SPACE, 0);
    Application.ProcessMessages;
    Require(LDataSet.FieldByName('SELECTED').AsBoolean and
      (LProbe.Count = 1) and LProbe.LastChecked,
      'Space deve alternar a seleção e emitir um único evento.');
    SendMessage(LGrid.Handle, WM_LBUTTONDOWN, MK_LBUTTON,
      MakeLong(10, 10));
    SendMessage(LGrid.Handle, WM_LBUTTONUP, 0, MakeLong(10, 10));
    Application.ProcessMessages;
    Require((LProbe.Count = 2) and LProbe.LastChecked,
      'Checkbox físico do header deve emitir um único evento agregado.');
    Require(LDataSet.FieldByName('SELECTED').AsBoolean,
      'Selecionar todos deve preservar o registro corrente marcado.');
    SendMessage(LGrid.Handle, WM_CHAR, Ord('X'), 0);
    Application.ProcessMessages;
    Require((LDataSet.State = dsBrowse) and
      SameText(LDataSet.FieldByName('NAME').AsString, 'Item 1'),
      'Digitação em célula comum não pode iniciar edição.');
    LForm.Hide;
  finally
    LProbe.Free;
    LForm.Free;
  end;
end;

procedure TestStreaming;
var
  I: Integer;
  LColumn: TDACDBGridColumn;
  LGrid: TDACDBGrid;
  LLoadedForm: TForm;
  LRuleCount: Integer;
  LSourceForm: TForm;
  LStream: TMemoryStream;
begin
  if System.Classes.GetClass('TDACDBGrid') = nil then
    System.Classes.RegisterClass(TDACDBGrid);
  LSourceForm := TForm.CreateNew(nil);
  LStream := TMemoryStream.Create;
  try
    LSourceForm.Name := 'StreamingForm';
    LGrid := TDACDBGrid.Create(LSourceForm);
    LGrid.Name := 'DACGrid';
    LGrid.Parent := LSourceForm;
    LGrid.Selection.Enabled := True;
    LGrid.Selection.FieldName := 'SELECTED';
    LGrid.Layout.Enabled := False;
    LColumn := LGrid.Columns.Add;
    LColumn.FieldName := 'NAME';
    LColumn.LayoutKey := 'name';
    LColumn.BadgeMode := dbmRules;
    with LColumn.BadgeRules.Add do
    begin
      Value := 'Ativo';
      Caption := 'Ativo';
    end;
    for I := 1 to 10 do
    begin
      LColumn := LGrid.Columns.Add;
      LColumn.FieldName := 'FIELD_' + IntToStr(I);
      LColumn.LayoutKey := 'field_' + IntToStr(I);
      LColumn.Width := 80 + I;
    end;
    LStream.WriteComponent(LSourceForm);
    LSourceForm.Free;
    LSourceForm := nil;
    LStream.Position := 0;
    LLoadedForm := TForm.CreateNew(nil);
    LStream.ReadComponent(LLoadedForm);
    try
      Require(LLoadedForm.FindComponent('DACGrid') is TDACDBGrid,
        'Streaming não recriou o TDACDBGrid.');
      LGrid := TDACDBGrid(LLoadedForm.FindComponent('DACGrid'));
      Require(LGrid.Selection.Enabled and
        SameText(LGrid.Selection.FieldName, 'SELECTED'),
        'Streaming perdeu as opções de seleção.');
      Require((LGrid.Columns.Count = 11) and
        (LGrid.Columns[0] is TDACDBGridColumn),
        'Streaming perdeu colunas persistentes ou sua classe especializada.');
      LRuleCount := LGrid.Columns[0].BadgeRules.Count;
      Require((LGrid.Columns[0].BadgeMode = dbmRules) and (LRuleCount = 1),
        'Streaming perdeu as regras publicadas de badge.');
    finally
      LLoadedForm.Free;
    end;
  finally
    LSourceForm.Free;
    LStream.Free;
  end;
end;

procedure TestLayoutPersistence;
var
  LFileName: string;
  LForm: TForm;
  LGrid: TDACDBGrid;
begin
  LFileName := TPath.Combine(GetEnvironmentVariable('TEMP'),
    'dac-dbgrid-layout-manager-' + IntToStr(GetCurrentProcessId) + '.json');
  if TFile.Exists(LFileName) then
    TFile.Delete(LFileName);
  LForm := TForm.CreateNew(nil);
  try
    LForm.Name := 'LayoutForm';
    LGrid := TDACDBGrid.Create(LForm);
    LGrid.Name := 'LayoutGrid';
    LGrid.Parent := LForm;
    LGrid.Layout.StorageFileName := LFileName;
    LGrid.Layout.AutoSave := False;
    with LGrid.Columns.Add do
    begin
      FieldName := 'ID';
      LayoutKey := 'id';
      Width := 90;
    end;
    with LGrid.Columns.Add do
    begin
      FieldName := 'NAME';
      LayoutKey := 'name';
      Width := 210;
    end;
    LGrid.SaveLayout;
    Require(TFile.Exists(LFileName),
      'Layout manager não gravou o arquivo configurado.');

    LGrid.Columns[0].Width := 32;
    LGrid.Columns[1].Index := 0;
    LGrid.SetColumnVisible('name', False);
    LGrid.LoadLayout;
    Require((LGrid.Columns[0].EffectiveLayoutKey = 'id') and
      (LGrid.Columns[0].Width = 90),
      'LoadLayout não restaurou ordem e largura lógicas.');
    Require(LGrid.Columns[1].Visible,
      'LoadLayout não restaurou a visibilidade da coluna.');
    LGrid.ResetLayout;
    Require(not TFile.Exists(LFileName) or
      (Pos('layoutgrid', LowerCase(TFile.ReadAllText(LFileName))) = 0),
      'ResetLayout não removeu a entrada persistida.');
  finally
    LForm.Free;
    if TFile.Exists(LFileName) then
      TFile.Delete(LFileName);
  end;
end;

begin
  try
    Application.Initialize;
    TestSortController;
    Writeln('OK sort controller');
    TestSelectionController;
    Writeln('OK selection controller');
    TestSerializerAndStore;
    Writeln('OK serializer and file store');
    TestStreaming;
    Writeln('OK DFM streaming contract with 11 persistent columns');
    TestGridLifecycle;
    Writeln('OK grid lifecycle and paint');
    TestLayoutPersistence;
    Writeln('OK layout persistence contract');
    Writeln('DACDBGridTests: PASS');
  except
    on E: Exception do
    begin
      Writeln('DACDBGridTests: FAIL - ' + E.ClassName + ': ' + E.Message);
      Halt(1);
    end;
  end;
end.
