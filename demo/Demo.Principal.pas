unit Demo.Principal;

interface

uses
  System.Classes,
  System.Math,
  System.SysUtils,
  System.Types,
  Winapi.Messages,
  Winapi.Windows,
  Vcl.ComCtrls,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Skia,
  Vcl.StdCtrls,
  DAC.Components.Controls.Badges,
  DAC.Components.Controls.Button,
  DAC.Components.Controls.ButtonEdit,
  DAC.Components.Controls.Charts,
  DAC.Components.Controls.ComboBox,
  DAC.Components.Controls.Container,
  DAC.Components.Controls.DateTimePicker,
  DAC.Components.Controls.Edit,
  DAC.Components.Controls.Feedback,
  DAC.Components.Controls.GridContainer,
  DAC.Components.DesignSystem.IconAssets,
  DAC.Components.Controls.Loading,
  DAC.Components.Controls.Pagination,
  DAC.Components.Controls.Progress,
  DAC.Components.Controls.Register,
  DAC.Components.Controls.ReportViewer,
  DAC.Components.Controls.ScrollContainer,
  DAC.Components.Controls.Selectors,
  DAC.Components.Controls.StatusBar,
  DAC.Components.Controls.StatusTimelineChart,
  DAC.Components.Controls.SummaryCard,
  DAC.Components.Controls.SystemText,
  DAC.Components.Controls.Tabs,
  DAC.Components.DesignSystem.ControlTokens,
  DAC.Components.DesignSystem.DashboardTokens,
  DAC.Components.DesignSystem.DemoTokens,
  DAC.Components.DesignSystem.SpacingTokens,
  DAC.Components.DesignSystem.ColorTokens,
  DAC.Components.DesignSystem.ComponentStyle,
  DAC.Components.DesignSystem.Theme;

const
  WM_DEMO_APPLY_LAYOUT = WM_APP + 73;
  WM_DEMO_APPLY_THEME = WM_APP + 74;
type
  TForm1 = class(TForm)
    GalleryTabs: TDACTabs;
    tsDashboard: TTabSheet;
    tsButtons: TTabSheet;
    tsInputs: TTabSheet;
    tsSelectors: TTabSheet;
    tsControls: TTabSheet;
    tsTabs: TTabSheet;
    tsCards: TTabSheet;
    tsStatus: TTabSheet;
    tsProgress: TTabSheet;
    tsPills: TTabSheet;
    tsFeedback: TTabSheet;
    tsPagination: TTabSheet;
    tsLoading: TTabSheet;
    tsCharts: TTabSheet;
    tsReport: TTabSheet;
    demoStatusTimeline: TDACStatusTimelineChart;
    scrButtons: TDACScrollContainer;
    lblButtonsTitle: TDACSystemText;
    lblButtonsSubtitle: TDACSystemText;
    lblButtonKinds: TDACSystemText;
    gcButtonKinds: TDACGridContainer;
    btnKindPrimary: TDACButton;
    btnKindSecondary: TDACButton;
    btnKindGhost: TDACButton;
    btnKindWarning: TDACButton;
    btnKindDanger: TDACButton;
    btnKindTransparent: TDACButton;
    btnKindInputAction: TDACButton;
    lblButtonSizes: TDACSystemText;
    gcButtonSizes: TDACGridContainer;
    btnSizeSmall: TDACButton;
    btnSizeMedium: TDACButton;
    btnSizeLarge: TDACButton;
    btnRadiusSoft: TDACButton;
    btnRadiusPill: TDACButton;
    btnNoTabStop: TDACButton;
    lblButtonIcons: TDACSystemText;
    gcButtonIcons: TDACGridContainer;
    btnIconLeft: TDACButton;
    btnIconRight: TDACButton;
    btnIconOnlyAdd: TDACButton;
    btnIconOnlyMore: TDACButton;
    btnIconCustomSize: TDACButton;
    btnIconDanger: TDACButton;
    lblButtonStates: TDACSystemText;
    gcButtonStates: TDACGridContainer;
    btnStateNormal: TDACButton;
    btnStateHover: TDACButton;
    btnStateFocus: TDACButton;
    btnStatePressed: TDACButton;
    btnStateLoading: TDACButton;
    btnStateDisabled: TDACButton;
    lblButtonSpecials: TDACSystemText;
    gcButtonSpecials: TDACGridContainer;
    btnSplitMain: TDACButton;
    btnSplitMenu: TDACButton;
    btnSearchAction: TDACButton;
    btnSaveAction: TDACButton;
    btnDeleteAction: TDACButton;
    btnUploadAction: TDACButton;
  private
    FDashboardActivity: TDACContainer;
    FDashboardAgenda: TDACContainer;
    FDashboardCards: array[0..4] of TDACSummaryCard;
    FDashboardChart: TDACChart;
    FDashboardDate: TDACContainer;
    FDashboardModules: TDACContainer;
    FDashboardPage: TTabSheet;
    FDashboardProductivity: TDACContainer;
    FDashboardQuickActions: TDACContainer;
    FDashboardScroll: TDACScrollContainer;
    FDashboardStatus: TDACContainer;
    FDemoNavigation: TDACScrollContainer;
    FDemoNavigationButtons: array of TDACButton;
    FDemoNavigationTitle: TDACSystemText;
    FThemeToggle: TDACButton;
    FLayoutApplying: Boolean;
    FLayoutRevision: Cardinal;
    FSelectorPreferredWidth: Integer;
    procedure ApplyDemoLayout;
    function CanApplyRuntimeLayout: Boolean;
    procedure BuildDemoNavigation;
    procedure BuildDashboard;
    procedure BuildThemeToggle;
    procedure ConfigureDemoLayout;
    procedure ConfigureDashboardLayout;
    procedure ConfigureResponsiveButtons;
    procedure ConfigureTabsLayout;
    procedure DemoNavigationClick(Sender: TObject);
    procedure FitToWorkArea;
    procedure GalleryTabsChange(Sender: TObject);
    procedure LayoutThemeToggle;
    procedure ThemeChanged(Sender: TObject);
    procedure ThemeToggleClick(Sender: TObject);
    function NavigationCanRemainExpanded: Boolean;
    procedure RefreshDemoNavigation;
    procedure RequestDemoLayout;
  protected
    procedure CreateWnd; override;
    procedure Loaded; override;
    procedure Resize; override;
    procedure CMShowingChanged(var AMessage: TMessage); message CM_SHOWINGCHANGED;
    procedure WMDemoApplyLayout(var AMessage: TMessage); message WM_DEMO_APPLY_LAYOUT;
    procedure WMDemoApplyTheme(var AMessage: TMessage); message WM_DEMO_APPLY_THEME;
  public
    destructor Destroy; override;
    property LayoutRevision: Cardinal read FLayoutRevision;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

const
  DACFORM_DIAG_EXTERNAL_CLIENT = 'DAC.DB030.ExternalClient';
  DACFORM_DIAG_EXTERNAL_SEARCH = 'DAC.DB030.ExternalSearch';
  DACFORM_DIAG_EXTERNAL_DATE = 'DAC.DB030.ExternalDate';
  DACFORM_DIAG_EXTERNAL_SLIDER = 'DAC.DB030.ExternalSlider';
  DACGRID_PROBE_ACTIVE = 'DAC.DB033.Active';
  DACGRID_PROBE_CAPTURE = 'DAC.DB033.Capture';
  DACGRID_PROBE_CELL_CLICK_COUNT = 'DAC.DB033.CellClickCount';
  DACGRID_PROBE_CLICK_COUNT = 'DAC.DB033.ClickCount';
  DACGRID_PROBE_DOWN_COUNT = 'DAC.DB033.DownCount';
  DACGRID_PROBE_DOWN_NESTED_COUNT = 'DAC.DB033.DownNestedCount';
  DACGRID_PROBE_DOWN_OTHER_COUNT = 'DAC.DB033.DownOtherCount';
  DACGRID_PROBE_DOWN_TIME = 'DAC.DB033.DownTime';
  DACGRID_PROBE_DOWN_WPARAM = 'DAC.DB033.DownWParam';
  DACGRID_PROBE_DOWN_X = 'DAC.DB033.DownX';
  DACGRID_PROBE_DOWN_Y = 'DAC.DB033.DownY';
  DACGRID_PROBE_FOCUS = 'DAC.DB033.Focus';
  DACGRID_PROBE_FOREGROUND = 'DAC.DB033.Foreground';
  DACGRID_PROBE_MOVE_COUNT = 'DAC.DB033.MoveCount';
  DACGRID_PROBE_MOVE_NESTED_COUNT = 'DAC.DB033.MoveNestedCount';
  DACGRID_PROBE_MOVE_OTHER_COUNT = 'DAC.DB033.MoveOtherCount';
  DACGRID_PROBE_MOVE_TIME = 'DAC.DB033.MoveTime';
  DACGRID_PROBE_MOVE_WPARAM = 'DAC.DB033.MoveWParam';
  DACGRID_PROBE_MOVE_X = 'DAC.DB033.MoveX';
  DACGRID_PROBE_MOVE_Y = 'DAC.DB033.MoveY';
  DACGRID_PROBE_THREAD = 'DAC.DB033.Thread';
  DACGRID_PROBE_UP_COUNT = 'DAC.DB033.UpCount';
  DACGRID_PROBE_UP_NESTED_COUNT = 'DAC.DB033.UpNestedCount';
  DACGRID_PROBE_UP_OTHER_COUNT = 'DAC.DB033.UpOtherCount';
  DACGRID_PROBE_UP_DATASET_ID = 'DAC.DB033.UpDataSetId';
  DACGRID_PROBE_UP_DATASET_RECNO = 'DAC.DB033.UpDataSetRecNo';
  DACGRID_PROBE_UP_TIME = 'DAC.DB033.UpTime';
  DACGRID_PROBE_UP_WPARAM = 'DAC.DB033.UpWParam';
  DACGRID_PROBE_UP_X = 'DAC.DB033.UpX';
  DACGRID_PROBE_UP_Y = 'DAC.DB033.UpY';

{$IFDEF DAC_LEGACY_DATAAWARE_DEMO}
procedure TDACDemoInputProbeGrid.ProbeCellClick(Column: TColumn);
begin
  if not FProbeEnabled then
    Exit;
  Inc(FProbeCellClickCount);
  PublishInputProbe;
end;

procedure TDACDemoInputProbeGrid.ProbeClick(Sender: TObject);
begin
  if not FProbeEnabled then
    Exit;
  Inc(FProbeClickCount);
  PublishInputProbe;
end;

procedure TDACDemoInputProbeGrid.DisarmInputProbe;
begin
  FProbeEnabled := False;
  OnClick := nil;
  OnCellClick := nil;
end;

procedure TDACDemoInputProbeGrid.PublishInputProbe;
begin
  if not HandleAllocated then
    Exit;
  SetProp(Handle, DACGRID_PROBE_ACTIVE, THandle(GetActiveWindow));
  SetProp(Handle, DACGRID_PROBE_CAPTURE, THandle(GetCapture));
  SetProp(Handle, DACGRID_PROBE_CELL_CLICK_COUNT,
    THandle(FProbeCellClickCount));
  SetProp(Handle, DACGRID_PROBE_CLICK_COUNT, THandle(FProbeClickCount));
  SetProp(Handle, DACGRID_PROBE_DOWN_COUNT, THandle(FProbeDownCount));
  SetProp(Handle, DACGRID_PROBE_DOWN_NESTED_COUNT,
    THandle(FProbeDownNestedCount));
  SetProp(Handle, DACGRID_PROBE_DOWN_OTHER_COUNT,
    THandle(FProbeDownOtherCount));
  SetProp(Handle, DACGRID_PROBE_DOWN_TIME, THandle(FProbeDownTime));
  SetProp(Handle, DACGRID_PROBE_DOWN_WPARAM, THandle(FProbeDownWParam));
  SetProp(Handle, DACGRID_PROBE_DOWN_X, THandle(FProbeDownX));
  SetProp(Handle, DACGRID_PROBE_DOWN_Y, THandle(FProbeDownY));
  SetProp(Handle, DACGRID_PROBE_FOCUS, THandle(GetFocus));
  SetProp(Handle, DACGRID_PROBE_FOREGROUND, THandle(GetForegroundWindow));
  SetProp(Handle, DACGRID_PROBE_MOVE_COUNT, THandle(FProbeMoveCount));
  SetProp(Handle, DACGRID_PROBE_MOVE_NESTED_COUNT,
    THandle(FProbeMoveNestedCount));
  SetProp(Handle, DACGRID_PROBE_MOVE_OTHER_COUNT,
    THandle(FProbeMoveOtherCount));
  SetProp(Handle, DACGRID_PROBE_MOVE_TIME, THandle(FProbeMoveTime));
  SetProp(Handle, DACGRID_PROBE_MOVE_WPARAM, THandle(FProbeMoveWParam));
  SetProp(Handle, DACGRID_PROBE_MOVE_X, THandle(FProbeMoveX));
  SetProp(Handle, DACGRID_PROBE_MOVE_Y, THandle(FProbeMoveY));
  SetProp(Handle, DACGRID_PROBE_THREAD, THandle(GetCurrentThreadId));
  SetProp(Handle, DACGRID_PROBE_UP_COUNT, THandle(FProbeUpCount));
  SetProp(Handle, DACGRID_PROBE_UP_NESTED_COUNT,
    THandle(FProbeUpNestedCount));
  SetProp(Handle, DACGRID_PROBE_UP_OTHER_COUNT,
    THandle(FProbeUpOtherCount));
  SetProp(Handle, DACGRID_PROBE_UP_DATASET_ID,
    THandle(FProbeUpDataSetId));
  SetProp(Handle, DACGRID_PROBE_UP_DATASET_RECNO,
    THandle(FProbeUpDataSetRecNo));
  SetProp(Handle, DACGRID_PROBE_UP_TIME, THandle(FProbeUpTime));
  SetProp(Handle, DACGRID_PROBE_UP_WPARAM, THandle(FProbeUpWParam));
  SetProp(Handle, DACGRID_PROBE_UP_X, THandle(FProbeUpX));
  SetProp(Handle, DACGRID_PROBE_UP_Y, THandle(FProbeUpY));
end;

procedure TDACDemoInputProbeGrid.ResetInputProbe;
begin
  FProbeEnabled := True;
  OnClick := ProbeClick;
  OnCellClick := ProbeCellClick;
  FProbeCellClickCount := 0;
  FProbeClickCount := 0;
  FProbeDownCount := 0;
  FProbeDownNestedCount := 0;
  FProbeDownOtherCount := 0;
  FProbeDownTime := 0;
  FProbeDownWParam := 0;
  FProbeDownX := 0;
  FProbeDownY := 0;
  FProbeMoveCount := 0;
  FProbeMoveNestedCount := 0;
  FProbeMoveOtherCount := 0;
  FProbeMoveTime := 0;
  FProbeMoveWParam := 0;
  FProbeMoveX := 0;
  FProbeMoveY := 0;
  FProbeUpCount := 0;
  FProbeUpNestedCount := 0;
  FProbeUpOtherCount := 0;
  FProbeUpDataSetId := -1;
  FProbeUpDataSetRecNo := -1;
  FProbeUpTime := 0;
  FProbeUpWParam := 0;
  FProbeUpX := 0;
  FProbeUpY := 0;
  PublishInputProbe;
end;

procedure TDACDemoInputProbeGrid.WndProc(var Message: TMessage);
var
  LIsInputMessage: Boolean;
  LMarkedInput: Boolean;
  LOuterDispatch: Boolean;
begin
  if Message.Msg = WM_DEMO_GRID_RESET_INPUT_PROBE then
  begin
    ResetInputProbe;
    Message.Result := 0;
    Exit;
  end;
  if Message.Msg = WM_DEMO_GRID_DISARM_INPUT_PROBE then
  begin
    DisarmInputProbe;
    Message.Result := 0;
    Exit;
  end;
  if not FProbeEnabled then
  begin
    inherited;
    Exit;
  end;
  LIsInputMessage := (Message.Msg = WM_MOUSEMOVE) or
    (Message.Msg = WM_LBUTTONDOWN) or (Message.Msg = WM_LBUTTONUP);
  LMarkedInput := NativeUInt(GetMessageExtraInfo) =
    NativeUInt(DAC_DB033_INPUT_MARKER);
  LOuterDispatch := FProbeDispatchDepth = 0;
  if LIsInputMessage then
  begin
    case Message.Msg of
      WM_MOUSEMOVE:
        if LOuterDispatch and LMarkedInput then
        begin
          Inc(FProbeMoveCount);
          FProbeMoveTime := GetMessageTime;
          FProbeMoveWParam := Message.WParam;
          FProbeMoveX := SmallInt(LOWORD(Message.LParam));
          FProbeMoveY := SmallInt(HIWORD(Message.LParam));
        end
        else if LOuterDispatch then
          Inc(FProbeMoveOtherCount)
        else
          Inc(FProbeMoveNestedCount);
      WM_LBUTTONDOWN:
        if LOuterDispatch and LMarkedInput then
        begin
          Inc(FProbeDownCount);
          FProbeDownTime := GetMessageTime;
          FProbeDownWParam := Message.WParam;
          FProbeDownX := SmallInt(LOWORD(Message.LParam));
          FProbeDownY := SmallInt(HIWORD(Message.LParam));
        end
        else if LOuterDispatch then
          Inc(FProbeDownOtherCount)
        else
          Inc(FProbeDownNestedCount);
      WM_LBUTTONUP:
        if LOuterDispatch and LMarkedInput then
        begin
          Inc(FProbeUpCount);
          FProbeUpTime := GetMessageTime;
          FProbeUpWParam := Message.WParam;
          FProbeUpX := SmallInt(LOWORD(Message.LParam));
          FProbeUpY := SmallInt(HIWORD(Message.LParam));
        end
        else if LOuterDispatch then
          Inc(FProbeUpOtherCount)
        else
          Inc(FProbeUpNestedCount);
    end;
  end;
  Inc(FProbeDispatchDepth);
  try
    inherited;
  finally
    Dec(FProbeDispatchDepth);
  end;
  if LOuterDispatch and LMarkedInput and
    (Message.Msg = WM_LBUTTONUP) and
    (DataSource <> nil) and (DataSource.DataSet <> nil) and
    DataSource.DataSet.Active and not DataSource.DataSet.IsEmpty then
  begin
    FProbeUpDataSetRecNo := DataSource.DataSet.RecNo;
    FProbeUpDataSetId := DataSource.DataSet.FieldByName('ID').AsInteger;
  end;
  if LIsInputMessage and LOuterDispatch then
    PublishInputProbe;
end;

function TForm1.CanApplyRuntimeLayout: Boolean;
begin
  Result := not (csDesigning in ComponentState) and (scrButtons <> nil) and
    (scrButtons.Parent <> nil);
end;

destructor TForm1.Destroy;
begin
  TDACThemeManager.UnregisterListener(Self);
  inherited;
end;

procedure TForm1.BuildDashboard;
var
  I: Integer;
begin
  if (csDesigning in ComponentState) then
    Exit;
  FDashboardPage := tsDashboard;
  FDashboardScroll := FindComponent('scrDashboard') as TDACScrollContainer;
  FDashboardDate := FindComponent('dashDateSummary') as TDACContainer;
  FDashboardQuickActions := FindComponent('dashQuickActions') as TDACContainer;
  FDashboardAgenda := FindComponent('dashAgenda') as TDACContainer;
  FDashboardActivity := FindComponent('dashRecentActivity') as TDACContainer;
  FDashboardProductivity := FindComponent('dashProductivity') as TDACContainer;
  FDashboardModules := FindComponent('dashModules') as TDACContainer;
  FDashboardStatus := FindComponent('dashStatus') as TDACContainer;
  FDashboardChart := FindComponent('dashProductivityChart') as TDACChart;
  if (FDashboardPage = nil) or (FDashboardScroll = nil) then
    Exit;
  for I := Low(FDashboardCards) to High(FDashboardCards) do
    FDashboardCards[I] := FindComponent('dashKpi' + IntToStr(I + 1)) as TDACSummaryCard;
  ConfigureDashboardLayout;
end;

procedure TForm1.BuildDemoNavigation;
var
  I: Integer;
  LButton: TDACButton;
  LDemoTokens: TDACDemoTokens;
  LPage: TTabSheet;
begin
  if (csDesigning in ComponentState) or (FDemoNavigation <> nil) or
    (GalleryTabs = nil) then
    Exit;

  LDemoTokens := TDACDemoTokens.Default;

  FDemoNavigation := TDACScrollContainer.Create(Self);
  FDemoNavigation.Name := 'demoNavigation';
  FDemoNavigation.Parent := Self;
  FDemoNavigation.Align := alNone;
  FDemoNavigation.Width := LDemoTokens.NavigationWidth;
  FDemoNavigation.AutoScroll := True;
  FDemoNavigation.BorderStyle := bsNone;
  FDemoNavigation.Appearance := mscaViewport;
  FDemoNavigation.ScrollBarMode := msbmVertical;
  FDemoNavigation.TabStop := True;

  FDemoNavigationTitle := TDACSystemText.Create(Self);
  FDemoNavigationTitle.Name := 'demoNavigationTitle';
  FDemoNavigationTitle.Parent := FDemoNavigation;
  FDemoNavigationTitle.SetBounds(LDemoTokens.NavigationPadding,
    LDemoTokens.NavigationTitleTop, LDemoTokens.NavigationWidth -
    (LDemoTokens.NavigationPadding * 2), LDemoTokens.NavigationTitleHeight);
  FDemoNavigationTitle.Text := 'Suite DAC';
  FDemoNavigationTitle.Role := mtrBody;
  FDemoNavigationTitle.Bold := True;
  FDemoNavigationTitle.MaxLines := 1;

  SetLength(FDemoNavigationButtons, GalleryTabs.PageCount);
  for I := 0 to GalleryTabs.PageCount - 1 do
  begin
    LPage := GalleryTabs.Pages[I];
    LButton := TDACButton.Create(Self);
    LButton.Name := 'demoNav' + Copy(LPage.Name, 3, MaxInt);
    LButton.Parent := FDemoNavigation;
    LButton.SetBounds(LDemoTokens.NavigationPadding,
      LDemoTokens.NavigationFirstButtonTop + (I *
        (LDemoTokens.NavigationButtonHeight + LDemoTokens.NavigationGutter)),
      LDemoTokens.NavigationWidth - (LDemoTokens.NavigationPadding * 2),
      LDemoTokens.NavigationButtonHeight);
    LButton.Caption := LPage.Caption;
    LButton.Kind := mbkGhost;
    LButton.TabStop := True;
    LButton.Tag := I;
    LButton.OnClick := DemoNavigationClick;
    FDemoNavigationButtons[I] := LButton;
  end;
end;

procedure TForm1.BuildThemeToggle;
begin
  if (csDesigning in ComponentState) or (FThemeToggle <> nil) then
    Exit;
  FThemeToggle := TDACButton.Create(Self);
  FThemeToggle.Name := 'demoThemeToggle';
  FThemeToggle.Parent := Self;
  FThemeToggle.Anchors := [akTop, akRight];
  FThemeToggle.Caption := 'Tema claro';
  FThemeToggle.Kind := mbkSecondary;
  FThemeToggle.ShowIcon := True;
  FThemeToggle.IconKind := mikThemeSun;
  FThemeToggle.OnClick := ThemeToggleClick;
  LayoutThemeToggle;
end;

procedure TForm1.BuildDemoGridData;
var
  I: Integer;
  LGrid: TDACDataGrid;
  LBooleanValue: string;
  LStatus: string;
  LDemoTokens: TDACDemoTokens;
begin
  if ([csLoading, csDestroying] * ComponentState <> []) or
    (csDesigning in ComponentState) then
    Exit;
  LGrid := FindComponent('demoDataGrid') as TDACDataGrid;
  if (LGrid = nil) or (demoGridDataSet = nil) or
    (demoGridDataSource = nil) or (demoLookupDataSet = nil) or
    (demoLookupDataSource = nil) then
    Exit;
  LDemoTokens := TDACDemoTokens.Default;

  FDemoGridDataSet := demoGridDataSet;
  FDemoGridDataSource := demoGridDataSource;
  if not FDemoGridDataSet.Active then
  begin
    FDemoGridDataSet.FieldDefs.Add('ID', ftInteger);
    FDemoGridDataSet.FieldDefs.Add('CLIENTE', ftString, 48);
    FDemoGridDataSet.FieldDefs.Add('CIDADE', ftString, 48);
    FDemoGridDataSet.FieldDefs.Add('STATUS', ftString, 16);
    FDemoGridDataSet.FieldDefs.Add('VALOR', ftCurrency);
    FDemoGridDataSet.FieldDefs.Add('DATA', ftDate);
    FDemoGridDataSet.FieldDefs.Add('ACTIONS', ftString, 16);
    FDemoGridDataSet.FieldDefs.Add('NOTES', ftMemo);
    FDemoGridDataSet.FieldDefs.Add('SEARCH', ftString, 48);
    FDemoGridDataSet.FieldDefs.Add('CHECKVALUE', ftString, 1);
    FDemoGridDataSet.FieldDefs.Add('BOOL_VALUE', ftBoolean);
    FDemoGridDataSet.FieldDefs.Add('RADIOVALUE', ftString, 16);
    FDemoGridDataSet.FieldDefs.Add('TOGGLEVALUE', ftString, 1);
    FDemoGridDataSet.FieldDefs.Add('SCORE', ftFloat);
    FDemoGridDataSet.FieldDefs.Add('LOOKUP_ID', ftInteger);
    FDemoGridDataSet.CreateDataSet;
  end;
  for I := 1 to 30 do
  begin
    if (I mod 3) = 0 then
      LStatus := 'Pendente'
    else
      LStatus := 'Ativo';
    if (I mod 2) = 0 then
      LBooleanValue := 'S'
    else
      LBooleanValue := 'N';
    FDemoGridDataSet.AppendRecord([1000 + I, 'Cliente demonstracao ' +
      IntToStr(I), 'Cidade ' + IntToStr(I) + ' - SP', LStatus, I * 125.75,
      EncodeDate(2025, 5, ((I - 1) mod 28) + 1), '...',
      'Observacao vinculada ao registro ' + IntToStr(I),
      'Busca ' + IntToStr(I), LBooleanValue, (I mod 2) = 0, LStatus,
      LBooleanValue, (I mod 10) / 10, (I mod 3) + 1]);
  end;
  FDemoGridDataSet.First;
  demoGridDataSource.OnDataChange := DataAwareDataChange;

  if not demoLookupDataSet.Active then
  begin
    demoLookupDataSet.FieldDefs.Add('ID', ftInteger);
    demoLookupDataSet.FieldDefs.Add('NAME', ftString, 32);
    demoLookupDataSet.CreateDataSet;
    demoLookupDataSet.AppendRecord([1, 'Sementes']);
    demoLookupDataSet.AppendRecord([2, 'Fertilizantes']);
    demoLookupDataSet.AppendRecord([3, 'Maquinas']);
    demoLookupDataSet.First;
  end;

  LGrid.DataSource := FDemoGridDataSource;
  LGrid.FooterText := 'Total: 30 registros';
  LGrid.FooterValue := '30';
  LGrid.Columns.Clear;
  with LGrid.Columns.Add do
  begin
    FieldName := 'ID';
    Title.Caption := 'Codigo';
    Width := LDemoTokens.GridCodeColumnWidth;
  end;
  with LGrid.Columns.Add do
  begin
    FieldName := 'CLIENTE';
    Title.Caption := 'Cliente';
    Width := LDemoTokens.GridClientColumnWidth;
  end;
  with LGrid.Columns.Add do
  begin
    FieldName := 'CIDADE';
    Title.Caption := 'Cidade';
    Width := LDemoTokens.GridCityColumnWidth;
  end;
  with LGrid.Columns.Add do
  begin
    FieldName := 'STATUS';
    Title.Caption := 'Status';
    Width := LDemoTokens.GridStatusColumnWidth;
  end;
  with LGrid.Columns.Add do
  begin
    FieldName := 'VALOR';
    Title.Caption := 'Valor';
    Width := LDemoTokens.GridValueColumnWidth;
  end;
  with LGrid.Columns.Add do
  begin
    FieldName := 'DATA';
    Title.Caption := 'Data';
    Width := LDemoTokens.GridDateColumnWidth;
  end;
  with LGrid.Columns.Add do
  begin
    FieldName := 'ACTIONS';
    Title.Caption := 'Acoes';
    Width := LDemoTokens.GridActionsColumnWidth;
  end;
  LGrid.Redraw;
  DataAwareStateChange(demoGridDataSource);
end;

procedure TForm1.DataAwareButtonEditClick(Sender: TObject);
begin
  Caption := 'DAC Componentes - acao independente do campo';
end;

procedure TForm1.DataAwareCancelClick(Sender: TObject);
begin
  if demoGridDataSet.State in dsEditModes then
    demoGridDataSet.Cancel;
  DataAwareStateChange(demoGridDataSource);
end;

procedure TForm1.DataAwareDataChange(Sender: TObject; Field: TField);
begin
  DataAwareStateChange(Sender);
end;

procedure TForm1.DataAwareEditClick(Sender: TObject);
begin
  demoGridDataSet.Edit;
  DataAwareStateChange(demoGridDataSource);
end;

procedure TForm1.DataAwareInsertClick(Sender: TObject);
begin
  demoGridDataSet.Insert;
  DataAwareStateChange(demoGridDataSource);
end;

procedure TForm1.DataAwarePostClick(Sender: TObject);
begin
  if demoGridDataSet.State in dsEditModes then
    demoGridDataSet.Post;
  DataAwareStateChange(demoGridDataSource);
end;

procedure TForm1.DataAwareStateChange(Sender: TObject);
var
  LDateField: TField;
  LDateMatches: Boolean;
  LRecordNumber: Integer;
  LState: TDataSetState;
begin
  if (demoDBStateText = nil) or
    (csDestroying in demoDBStateText.ComponentState) then
    Exit;
  LState := dsInactive;
  if (Sender is TDataSource) and
    (TDataSource(Sender).DataSet <> nil) then
    LState := TDataSource(Sender).DataSet.State;
  case LState of
    dsEdit: demoDBStateText.Text := 'Estado: Edit';
    dsInsert: demoDBStateText.Text := 'Estado: Insert';
    dsBrowse: demoDBStateText.Text := 'Estado: Browse';
    dsInactive: demoDBStateText.Text := 'Estado: Inactive';
  else
    demoDBStateText.Text := 'Estado: ' + IntToStr(Ord(LState));
  end;
  if HandleAllocated and (demoGridDataSet <> nil) and
    demoGridDataSet.Active and not demoGridDataSet.IsEmpty then
  begin
    LRecordNumber := demoGridDataSet.RecNo;
    if LRecordNumber <= 0 then
    begin
      SetProp(Handle, DACFORM_DIAG_EXTERNAL_CLIENT, THandle(-1));
      SetProp(Handle, DACFORM_DIAG_EXTERNAL_SEARCH, THandle(-1));
      SetProp(Handle, DACFORM_DIAG_EXTERNAL_DATE, THandle(-1));
      SetProp(Handle, DACFORM_DIAG_EXTERNAL_SLIDER, THandle(-1));
      Exit;
    end;
    LDateField := demoGridDataSet.FieldByName('DATA');
    LDateMatches := (LDateField <> nil) and not LDateField.IsNull and
      not demoDBDate.IsNull and
      (Trunc(demoDBDate.DateTime) = Trunc(LDateField.AsDateTime));
    if demoDBEdit.Text =
      'Cliente demonstracao ' + IntToStr(LRecordNumber) then
      SetProp(Handle, DACFORM_DIAG_EXTERNAL_CLIENT,
        THandle(LRecordNumber))
    else
      SetProp(Handle, DACFORM_DIAG_EXTERNAL_CLIENT, THandle(-1));
    if demoDBButtonEdit.Text = 'Busca ' + IntToStr(LRecordNumber) then
      SetProp(Handle, DACFORM_DIAG_EXTERNAL_SEARCH,
        THandle(LRecordNumber))
    else
      SetProp(Handle, DACFORM_DIAG_EXTERNAL_SEARCH, THandle(-1));
    if LDateMatches then
      SetProp(Handle, DACFORM_DIAG_EXTERNAL_DATE,
        THandle(LRecordNumber))
    else
      SetProp(Handle, DACFORM_DIAG_EXTERNAL_DATE, THandle(-1));
    if demoDBSlider.Position = (LRecordNumber mod 10) * 10 then
      SetProp(Handle, DACFORM_DIAG_EXTERNAL_SLIDER,
        THandle(LRecordNumber))
    else
      SetProp(Handle, DACFORM_DIAG_EXTERNAL_SLIDER, THandle(-1));
  end;
end;
{$ENDIF}

{$ENDIF DAC_LEGACY_DATAAWARE_DEMO}

procedure TForm1.ConfigureResponsiveButtons;
var
  LAvailableWidth: Integer;
  LContentTop: Integer;
  LDemoTokens: TDACDemoTokens;
  LMargin: Integer;
  LSectionGap: Integer;
  LSectionLabelGap: Integer;
  LViewportRect: TRect;
  LViewportWidth: Integer;
  LVerticalSpacing: Integer;
  function LayoutLabel(const ALabel: TDACSystemText;
    const ATop: Integer): Integer;
  var
    LTextHeight: Integer;
  begin
    LTextHeight := Max(ALabel.Height,
      ALabel.MeasureTextHeight(ALabel.Text, LAvailableWidth));
    ALabel.SetBounds(LMargin, ATop, LAvailableWidth, LTextHeight);
    Result := ATop + LTextHeight;
  end;
  function RequiredGridHeight(const AGrid: TDACGridContainer): Integer;
  var
    I: Integer;
    LChild: TControl;
    LChildBottom: Integer;
    LContentBottom: Integer;
    LGridContentTop: Integer;
  begin
    LGridContentTop := MaxInt;
    LContentBottom := 0;
    for I := 0 to AGrid.ControlCount - 1 do
    begin
      LChild := AGrid.Controls[I];
      if not LChild.Visible or (LChild is TSkPaintBox) then
        Continue;
      LGridContentTop := Min(LGridContentTop, LChild.Top);
      LChildBottom := LChild.Top + LChild.Height;
      LContentBottom := Max(LContentBottom, LChildBottom);
    end;
    if LGridContentTop = MaxInt then
      Exit(AGrid.Height);
    Result := Max(AGrid.RowHeight + (LGridContentTop * 2),
      LContentBottom + LGridContentTop);
  end;
  procedure LayoutSection(const ALabel: TDACSystemText;
    const AGrid: TDACGridContainer; var ATop: Integer);
  var
    LGridWidth: Integer;
  begin
    ATop := LayoutLabel(ALabel, ATop);
    Inc(ATop, LSectionLabelGap);
    LGridWidth := LAvailableWidth;
    if AGrid = gcButtonSpecials then
      LGridWidth := Max(LGridWidth, Max(btnSplitMain.MinimumContentWidth,
        btnUploadAction.MinimumContentWidth) +
        (gcButtonSpecials.ContentPadding * 2) + 16);
    AGrid.SetBounds(LMargin, ATop, LGridWidth, AGrid.Height);
    AGrid.Realign;
    AGrid.Height := RequiredGridHeight(AGrid);
    Inc(ATop, AGrid.Height + LSectionGap);
  end;
begin
  if not CanApplyRuntimeLayout then
    Exit;

  if not Winapi.Windows.GetClientRect(scrButtons.Handle, LViewportRect) then
    Exit;
  LDemoTokens := TDACDemoTokens.Default;
  LMargin := LDemoTokens.ContentHorizontalMargin;
  LVerticalSpacing := Round(TDACSpacingTokens.Default.S8);
  LSectionLabelGap := LVerticalSpacing;
  LSectionGap := Round(TDACSpacingTokens.Default.S24);
  LViewportWidth := LViewportRect.Right - LViewportRect.Left;
  // The scroll container is the only authoritative viewport after the tabs
  // and the runtime navigation have been laid out.  Do not cap this with a
  // form-specific width: a resize must use every available pixel and
  // let each grid recompute its columns from that real client rectangle.
  LAvailableWidth := Max(0, LViewportWidth - (LMargin * 2));
  LContentTop := LayoutLabel(lblButtonsTitle, LMargin);
  Inc(LContentTop, LVerticalSpacing);
  LContentTop := LayoutLabel(lblButtonsSubtitle, LContentTop);
  Inc(LContentTop, LSectionGap);
  LayoutSection(lblButtonKinds, gcButtonKinds, LContentTop);
  LayoutSection(lblButtonSizes, gcButtonSizes, LContentTop);
  LayoutSection(lblButtonIcons, gcButtonIcons, LContentTop);
  LayoutSection(lblButtonStates, gcButtonStates, LContentTop);
  LayoutSection(lblButtonSpecials, gcButtonSpecials, LContentTop);
end;

procedure TForm1.ConfigureDemoLayout;
var
  I: Integer;
  LDemoTokens: TDACDemoTokens;
  LNavigationWidth: Integer;
  LPadding: Integer;
begin
  if (csDesigning in ComponentState) or (FDemoNavigation = nil) or
    (GalleryTabs = nil) then
    Exit;
  LDemoTokens := TDACDemoTokens.Default;
  if NavigationCanRemainExpanded then
  begin
    FDemoNavigation.Visible := True;
    LNavigationWidth := LDemoTokens.NavigationWidth
  end
  else
  begin
    FDemoNavigation.Visible := True;
    LNavigationWidth := LDemoTokens.NavigationCompactWidth;
  end;
  FDemoNavigation.SetBounds(0, 0, LNavigationWidth, ClientHeight);
  LPadding := LDemoTokens.NavigationPadding;
  if LNavigationWidth = LDemoTokens.NavigationCompactWidth then
    LPadding := Max(8, LPadding div 2);
  if FDemoNavigationTitle <> nil then
  begin
    if LNavigationWidth = LDemoTokens.NavigationCompactWidth then
      FDemoNavigationTitle.Text := 'DAC'
    else
      FDemoNavigationTitle.Text := 'Suite DAC';
    FDemoNavigationTitle.SetBounds(LPadding,
      LDemoTokens.NavigationTitleTop, Max(0, LNavigationWidth -
      (LPadding * 2)), LDemoTokens.NavigationTitleHeight);
  end;
  for I := 0 to High(FDemoNavigationButtons) do
    if FDemoNavigationButtons[I] <> nil then
      FDemoNavigationButtons[I].SetBounds(LPadding,
        LDemoTokens.NavigationFirstButtonTop + (I *
        (LDemoTokens.NavigationButtonHeight + LDemoTokens.NavigationGutter)),
        Max(0, LNavigationWidth - (LPadding * 2)),
        LDemoTokens.NavigationButtonHeight);
  GalleryTabs.Align := alNone;
  GalleryTabs.SetBounds(LNavigationWidth, 0,
    Max(0, ClientWidth - LNavigationWidth), ClientHeight);
  GalleryTabs.RefreshContentLayout;
  ConfigureTabsLayout;
  ConfigureDashboardLayout;
  LayoutThemeToggle;
end;

procedure TForm1.ApplyDemoLayout;
var
  LActivePage: TTabSheet;
begin
  if FLayoutApplying or
    ([csLoading, csDestroying] * ComponentState <> []) or
    (csDesigning in ComponentState) or
    not HandleAllocated then
    Exit;
  FLayoutApplying := True;
  DisableAlign;
  Perform(WM_SETREDRAW, 0, 0);
  try
    ConfigureDemoLayout;
    if GalleryTabs <> nil then
    begin
      GalleryTabs.Realign;
      if GalleryTabs.ActivePage <> nil then
        GalleryTabs.ActivePage.Realign;
    end;
    if scrButtons <> nil then
      scrButtons.Realign;
    ConfigureResponsiveButtons;
    ConfigureDashboardLayout;
  finally
    Perform(WM_SETREDRAW, 1, 0);
    EnableAlign;
    FLayoutApplying := False;
    LActivePage := nil;
    if GalleryTabs <> nil then
      LActivePage := GalleryTabs.ActivePage;
    // The page hosts native edit/memo HWNDs as well as Skia graphic children.
    // WM_SETREDRAW on the form can otherwise leave the old child pixels until
    // a later erase. Commit the active page first, including every child,
    // then redraw the form chrome around that fully-clean page.
    if (LActivePage <> nil) and LActivePage.HandleAllocated then
      RedrawWindow(LActivePage.Handle, nil, 0,
        RDW_INVALIDATE or RDW_ERASE or RDW_FRAME or RDW_ALLCHILDREN or
        RDW_ERASENOW or RDW_UPDATENOW);
    RedrawWindow(Handle, nil, 0,
      RDW_INVALIDATE or RDW_ERASE or RDW_ALLCHILDREN or RDW_UPDATENOW);
    { The tabs header is a sibling HWND and refreshes its own z-order. Commit
      the global theme action last so it remains mouse-accessible above that
      header after every responsive layout pass. }
    LayoutThemeToggle;
  end;
end;

procedure TForm1.LayoutThemeToggle;
var
  LControlTokens: TDACControlTokens;
  LHeight: Integer;
  LRightInset: Integer;
  LSpacing: TDACSpacingTokens;
  LTopInset: Integer;
  LWidth: Integer;
begin
  if FThemeToggle = nil then
    Exit;
  LSpacing := TDACSpacingTokens.Default;
  LControlTokens := TDACComponentStyle.Resolve(
    TDACThemeManager.ApplicationMode).Tokens.Controls;
  LRightInset := Round(LSpacing.S12);
  LTopInset := Round(LSpacing.S8);
  LWidth := Round(LControlTokens.ButtonDefaultWidth + LSpacing.S8);
  LHeight := Round(LControlTokens.ButtonMedium.Height);
  if not NavigationCanRemainExpanded then
  begin
    LWidth := LHeight;
    FThemeToggle.Caption := '';
  end
  else if TDACThemeManager.ApplicationMode = dtmLight then
    FThemeToggle.Caption := 'Tema escuro'
  else
    FThemeToggle.Caption := 'Tema claro';
  FThemeToggle.SetBounds(Max(0, ClientWidth - LRightInset - LWidth),
    LTopInset, LWidth, LHeight);
  if GalleryTabs <> nil then
    GalleryTabs.HeaderTrailingReserve :=
      LWidth + LRightInset + Round(LSpacing.S8);
  FThemeToggle.BringToFront;
end;

procedure TForm1.RequestDemoLayout;
begin
  if csDesigning in ComponentState then
    Exit;
  Inc(FLayoutRevision);
  if HandleAllocated then
    PostMessage(Handle, WM_DEMO_APPLY_LAYOUT, FLayoutRevision, 0);
end;

procedure TForm1.ConfigureTabsLayout;
var
  LActualPoint: TPoint;
  LDesiredLeft: Integer;
  LPage: TTabSheet;
  LRight: Integer;
  LTabs: TDACTabs;
  LText: TDACSystemText;
  procedure LayoutSelectors;
  var
    LAvailableWidth: Integer;
    LCombo: TControl;
    LDateTime: TControl;
    LRightInset: Integer;
  begin
    if (GalleryTabs.ActivePage <> tsSelectors) or
      not tsSelectors.HandleAllocated then
      Exit;
    LRightInset := Round(TDACSpacingTokens.Default.S24);
    LCombo := FindComponent('demoCombo') as TControl;
    LDateTime := FindComponent('demoDateTime') as TControl;
    if LCombo <> nil then
    begin
      LAvailableWidth := Max(0, tsSelectors.ClientWidth -
        LCombo.Left - LRightInset);
      LCombo.SetBounds(LCombo.Left, LCombo.Top,
        Min(FSelectorPreferredWidth, LAvailableWidth), LCombo.Height);
    end;
    if LDateTime <> nil then
    begin
      LAvailableWidth := Max(0, tsSelectors.ClientWidth -
        LDateTime.Left - LRightInset);
      LDateTime.SetBounds(LDateTime.Left, LDateTime.Top,
        Min(FSelectorPreferredWidth, LAvailableWidth), LDateTime.Height);
    end;
  end;
  procedure LayoutPageCaptions(const APage: TTabSheet);
  var
    I: Integer;
    LCaption: TLabel;
    LRightInset: Integer;
  begin
    if (APage = nil) or not APage.HandleAllocated then
      Exit;
    LRightInset := Round(TDACSpacingTokens.Default.S24);
    for I := 0 to APage.ControlCount - 1 do
      if APage.Controls[I] is TLabel then
      begin
        LCaption := TLabel(APage.Controls[I]);
        LCaption.AutoSize := False;
        LCaption.WordWrap := False;
        LCaption.EllipsisPosition := epEndEllipsis;
        LCaption.Width := Max(0, APage.ClientWidth - LCaption.Left - LRightInset);
      end;
  end;
  procedure LayoutActiveVerticalText(const AName: string);
  begin
    LText := FindComponent(AName) as TDACSystemText;
    if (LText = nil) or not (LText.Parent is TTabSheet) then
      Exit;
    LPage := TTabSheet(LText.Parent);
    if LPage <> LTabs.ActivePage then
      Exit;
    // The native TPageControl can add an orientation-dependent page offset.
    // Reconcile the real screen/client coordinates after that offset instead
    // of reusing a DFM-specific left value.
    LDesiredLeft := LTabs.ClientToScreen(Point(LTabs.ContentInset, 0)).X;
    LRight := LTabs.ClientToScreen(Point(Max(0, LTabs.ClientWidth - 24), 0)).X;
    LActualPoint := LText.ClientToScreen(Point(0, 0));
    LText.SetBounds(LText.Left + (LDesiredLeft - LActualPoint.X), LText.Top,
      Min(LText.Width, Max(0, LRight - LDesiredLeft)), LText.Height);
  end;
begin
  if csDesigning in ComponentState then
    Exit;
  if GalleryTabs <> nil then
    LayoutPageCaptions(GalleryTabs.ActivePage);
  LTabs := FindComponent('demoTabs') as TDACTabs;
  if LTabs <> nil then
    LTabs.RefreshContentLayout;
  { Input/selector state matrices are authored declaratively in the DFM.
    Runtime interaction only produces real hover/focus; it does not fabricate
    visual state or reposition those samples. }
  LTabs := FindComponent('demoVerticalTabs') as TDACTabs;
  if LTabs <> nil then
  begin
    LTabs.RefreshContentLayout;
    LayoutActiveVerticalText('demoVerticalTabsFirstText');
    LayoutActiveVerticalText('demoVerticalTabsSecondText');
    LayoutActiveVerticalText('demoVerticalTabsThirdText');
  end;
end;

procedure TForm1.ConfigureDashboardLayout;
var
  LControlTokens: TDACControlTokens;
  LDashboardTokens: TDACDashboardTokens;
  LSpacing: TDACSpacingTokens;
  I: Integer;
  LActivityTop: Integer;
  LAvailable: Integer;
  LCardWidth: Integer;
  LColumns: Integer;
  LDateWidth: Integer;
  LMiddleWidth: Integer;
  LModule: TDACContainer;
  LModuleColumns: Integer;
  LModuleWidth: Integer;
  LProductivityWidth: Integer;
  LQuickActionsHeight: Integer;
  LQuickActionsGrid: TDACGridContainer;
  LRows: Integer;
  LSubtitleHeight: Integer;
  LSubtitleTop: Integer;
  LText: TDACSystemText;
  LTop: Integer;
  LWelcomeHeight: Integer;
  function Metric(const AValue: Single): Integer;
  begin
    Result := Round(AValue);
  end;
  procedure SetTextWidth(const AName: string; const AWidth: Integer);
  begin
    LText := FindComponent(AName) as TDACSystemText;
    if LText <> nil then
      LText.Width := Max(0, AWidth);
  end;
  procedure SetTextBounds(const AName: string; const ALeft, ATop, AWidth,
    AHeight: Integer);
  begin
    LText := FindComponent(AName) as TDACSystemText;
    if LText <> nil then
      LText.SetBounds(ALeft, ATop, Max(0, AWidth), AHeight);
  end;
  function RequiredTextHeight(const AName: string; const AWidth,
    AMinimum: Integer): Integer;
  begin
    Result := AMinimum;
    LText := FindComponent(AName) as TDACSystemText;
    if LText <> nil then
      Result := Max(Result, LText.MeasureTextHeight(LText.Text,
        Max(1, AWidth)));
  end;
begin
  if (csDesigning in ComponentState) or (FDashboardScroll = nil) then
    Exit;

  LDashboardTokens := TDACComponentStyle.ResolveForSurface(FDashboardScroll,
    dtmInherit).Tokens.Dashboard;
  LControlTokens := TDACComponentStyle.ResolveForSurface(FDashboardScroll,
    dtmInherit).Tokens.Controls;
  LSpacing := TDACComponentStyle.ResolveForSurface(FDashboardScroll,
    dtmInherit).Tokens.Spacing;
  LAvailable := Max(Metric(LDashboardTokens.ContentMinimumWidth),
    FDashboardScroll.ClientWidth - (Metric(LSpacing.S24) * 2));
  if LAvailable >= Metric(LDashboardTokens.FiveKpiBreakpoint) then
    LColumns := 5
  else if LAvailable >= Metric(LDashboardTokens.ThreeKpiBreakpoint) then
    LColumns := 3
  else if LAvailable >= Metric(LDashboardTokens.TwoKpiBreakpoint) then
    LColumns := 2
  else
    LColumns := 1;
  LCardWidth := Max(Metric(LDashboardTokens.KpiMinimumWidth), (LAvailable -
    (Metric(LSpacing.S16) * (LColumns - 1))) div LColumns);

  if LAvailable >= Metric(LDashboardTokens.DateAndGreetingBreakpoint) then
  begin
    LDateWidth := Min(Metric(LDashboardTokens.DateSummaryMaximumWidth),
      Max(Metric(LDashboardTokens.DateSummaryMinimumWidth), LAvailable div 4));
    FDashboardDate.SetBounds(Metric(LSpacing.S24) + LAvailable - LDateWidth,
      Metric(LSpacing.S24), LDateWidth,
      Metric(LDashboardTokens.DateSummaryHeight));
    LWelcomeHeight := Max(RequiredTextHeight('dashWelcomeTitle',
      Metric(LDashboardTokens.GreetingTitleWidth),
      Metric(LDashboardTokens.GreetingMinimumHeight)),
      RequiredTextHeight('dashWelcomeName',
        Max(0, LAvailable - LDateWidth -
          Metric(LDashboardTokens.GreetingDateReservedWidth)),
        Metric(LDashboardTokens.GreetingMinimumHeight)));
    SetTextBounds('dashWelcomeTitle', Metric(LSpacing.S24),
      Metric(LSpacing.S24), Metric(LDashboardTokens.GreetingTitleWidth), LWelcomeHeight);
    SetTextBounds('dashWelcomeName', Metric(LSpacing.S24 +
      LDashboardTokens.GreetingNameLeftOffset), Metric(LSpacing.S24),
      Max(0, LAvailable - LDateWidth -
        Metric(LDashboardTokens.GreetingDateReservedWidth)), LWelcomeHeight);
    LSubtitleTop := Metric(LSpacing.S24) + LWelcomeHeight +
      Metric(LDashboardTokens.GreetingTextGap);
    LSubtitleHeight := RequiredTextHeight('dashWelcomeSubtitle',
      Max(Metric(LDashboardTokens.GreetingSubtitleMinimumWidth),
        LAvailable - LDateWidth - Metric(LSpacing.S24)),
      Metric(LDashboardTokens.GreetingSubtitleMinimumHeight));
    SetTextBounds('dashWelcomeSubtitle', Metric(LSpacing.S24), LSubtitleTop,
      Max(Metric(LDashboardTokens.GreetingSubtitleMinimumWidth),
        LAvailable - LDateWidth - Metric(LSpacing.S24)), LSubtitleHeight);
    LTop := Max(Metric(LDashboardTokens.GreetingMinimumContentTop),
      LSubtitleTop + LSubtitleHeight +
      Metric(LDashboardTokens.GreetingContentBottomGap));
  end
  else
  begin
    // A data leaves the greeting line on compact widths; otherwise the green
    // user name and the date compete for the same physical pixels.
    LWelcomeHeight := Max(RequiredTextHeight('dashWelcomeTitle', LAvailable,
      Metric(LDashboardTokens.GreetingMinimumHeight)),
      RequiredTextHeight('dashWelcomeName', LAvailable,
        Metric(LDashboardTokens.GreetingMinimumHeight)));
    SetTextBounds('dashWelcomeTitle', Metric(LSpacing.S24), Metric(LSpacing.S24), LAvailable,
      LWelcomeHeight);
    SetTextBounds('dashWelcomeName', Metric(LSpacing.S24),
      Metric(LSpacing.S24) + LWelcomeHeight +
      Metric(LDashboardTokens.GreetingTextGap), LAvailable, LWelcomeHeight);
    LSubtitleTop := Metric(LSpacing.S24) + (LWelcomeHeight * 2) +
      Metric(LSpacing.S4);
    LSubtitleHeight := RequiredTextHeight('dashWelcomeSubtitle', LAvailable,
      Metric(LDashboardTokens.GreetingSubtitleMinimumHeight));
    SetTextBounds('dashWelcomeSubtitle', Metric(LSpacing.S24), LSubtitleTop, LAvailable,
      LSubtitleHeight);
    LDateWidth := LAvailable;
    FDashboardDate.SetBounds(Metric(LSpacing.S24),
      LSubtitleTop + LSubtitleHeight + Metric(LSpacing.S8), LDateWidth,
      Metric(LDashboardTokens.DateSummaryHeight));
    LTop := FDashboardDate.Top + FDashboardDate.Height + Metric(LSpacing.S20);
  end;
  SetTextWidth('dashDateValue', LDateWidth - Metric(LSpacing.S32));
  SetTextWidth('dashDateWeekday', LDateWidth - Metric(LSpacing.S32));
  for I := Low(FDashboardCards) to High(FDashboardCards) do
    FDashboardCards[I].SetBounds(Metric(LSpacing.S24) + ((I mod LColumns) *
      (LCardWidth + Metric(LSpacing.S16))), LTop + ((I div LColumns) *
      (Metric(LDashboardTokens.KpiHeight) + Metric(LSpacing.S16))), LCardWidth,
      Metric(LDashboardTokens.KpiHeight));
  LRows := (Length(FDashboardCards) + LColumns - 1) div LColumns;
  Inc(LTop, LRows * Metric(LDashboardTokens.KpiHeight) + (LRows - 1) *
    Metric(LSpacing.S16) + Metric(LSpacing.S24));

  LQuickActionsGrid := FindComponent('dashQuickActionsGrid') as TDACGridContainer;
  if LAvailable < Metric(LDashboardTokens.QuickActionsSingleColumnBreakpoint) then
  begin
    LQuickActionsHeight := Metric(LDashboardTokens.QuickActionsSingleColumnHeight);
    if LQuickActionsGrid <> nil then
      LQuickActionsGrid.Columns := 1;
  end
  else
  begin
    LQuickActionsHeight := Metric(LDashboardTokens.KpiHeight * 2 + LSpacing.S8);
    if LQuickActionsGrid <> nil then
      LQuickActionsGrid.Columns := 2;
  end;

  if LAvailable >= Metric(LDashboardTokens.ThreeColumnBreakpoint) then
  begin
    LMiddleWidth := (LAvailable - (Metric(LSpacing.S16) * 2)) div 3;
    FDashboardQuickActions.SetBounds(Metric(LSpacing.S24), LTop, LMiddleWidth, LQuickActionsHeight);
    FDashboardAgenda.SetBounds(Metric(LSpacing.S24) + LMiddleWidth + Metric(LSpacing.S16), LTop, LMiddleWidth, Metric(LDashboardTokens.KpiHeight * 2 + LSpacing.S8));
    FDashboardActivity.SetBounds(Metric(LSpacing.S24) + ((LMiddleWidth + Metric(LSpacing.S16)) * 2), LTop,
      LMiddleWidth, Metric(LDashboardTokens.KpiHeight * 2 + LSpacing.S8));
    Inc(LTop, Max(Metric(LDashboardTokens.KpiHeight * 2 + LSpacing.S8), LQuickActionsHeight) + Metric(LSpacing.S24));
  end
  else if LAvailable >= Metric(LDashboardTokens.TwoColumnBreakpoint) then
  begin
    LMiddleWidth := (LAvailable - Metric(LSpacing.S16)) div 2;
    FDashboardQuickActions.SetBounds(Metric(LSpacing.S24), LTop, LMiddleWidth, LQuickActionsHeight);
    FDashboardAgenda.SetBounds(Metric(LSpacing.S24) + LMiddleWidth + Metric(LSpacing.S16), LTop, LMiddleWidth, Metric(LDashboardTokens.KpiHeight * 2 + LSpacing.S8));
    LActivityTop := LTop + Max(Metric(LDashboardTokens.KpiHeight * 2 + LSpacing.S8), LQuickActionsHeight) + Metric(LSpacing.S16);
    FDashboardActivity.SetBounds(Metric(LSpacing.S24), LActivityTop, LAvailable, Metric(LDashboardTokens.KpiHeight * 2 + LSpacing.S8));
    LTop := LActivityTop + Metric(LDashboardTokens.KpiHeight * 2 + LSpacing.S8) + Metric(LSpacing.S24);
  end
  else
  begin
    FDashboardQuickActions.SetBounds(Metric(LSpacing.S24), LTop, LAvailable, LQuickActionsHeight);
    Inc(LTop, LQuickActionsHeight + Metric(LSpacing.S16));
    FDashboardAgenda.SetBounds(Metric(LSpacing.S24), LTop, LAvailable, Metric(LDashboardTokens.KpiHeight * 2 + LSpacing.S8));
    Inc(LTop, Metric(LDashboardTokens.KpiHeight * 2 + LSpacing.S8) + Metric(LSpacing.S16));
    FDashboardActivity.SetBounds(Metric(LSpacing.S24), LTop, LAvailable, Metric(LDashboardTokens.KpiHeight * 2 + LSpacing.S8));
    Inc(LTop, Metric(LDashboardTokens.KpiHeight * 2 + LSpacing.S8) + Metric(LSpacing.S24));
  end;

  if LAvailable >= Metric(LDashboardTokens.AnalyticsTwoColumnBreakpoint) then
  begin
    LProductivityWidth := (LAvailable - Metric(LSpacing.S16)) div 2;
    FDashboardProductivity.SetBounds(Metric(LSpacing.S24), LTop, LProductivityWidth, Metric(LDashboardTokens.AnalyticsPanelHeight));
    FDashboardModules.SetBounds(Metric(LSpacing.S24) + LProductivityWidth + Metric(LSpacing.S16), LTop,
      LProductivityWidth, Metric(LDashboardTokens.AnalyticsPanelHeight));
    Inc(LTop, Metric(LDashboardTokens.AnalyticsPanelHeight + LSpacing.S24));
  end
  else
  begin
    FDashboardProductivity.SetBounds(Metric(LSpacing.S24), LTop, LAvailable, Metric(LDashboardTokens.AnalyticsPanelHeight));
    Inc(LTop, Metric(LDashboardTokens.AnalyticsPanelHeight + LSpacing.S16));
    FDashboardModules.SetBounds(Metric(LSpacing.S24), LTop, LAvailable, Metric(LDashboardTokens.AnalyticsPanelHeight));
    Inc(LTop, Metric(LDashboardTokens.AnalyticsPanelHeight + LSpacing.S24));
  end;

  if FDashboardModules.Width >= Metric(LDashboardTokens.ModuleFourColumnBreakpoint) then
    LModuleColumns := 4
  else if FDashboardModules.Width >= Metric(LDashboardTokens.ModuleTwoColumnBreakpoint) then
    LModuleColumns := 2
  else
    LModuleColumns := 1;
  LModuleWidth := Max(Metric(LDashboardTokens.ModuleMinimumWidth),
    (FDashboardModules.Width - (Metric(LSpacing.S24) * 2) -
    ((LModuleColumns - 1) * Metric(LSpacing.S12))) div LModuleColumns);
  for I := 0 to 3 do
  begin
    LModule := FindComponent('dashModule' + IntToStr(I + 1)) as TDACContainer;
    if LModule <> nil then
      LModule.SetBounds(Metric(LSpacing.S20) + ((I mod LModuleColumns) *
        (LModuleWidth + Metric(LSpacing.S12))), Metric(LDashboardTokens.ModuleContentTop) +
        ((I div LModuleColumns) * Metric(LDashboardTokens.ModuleRowStride)),
        LModuleWidth, Metric(LDashboardTokens.ModuleHeight));
    SetTextWidth('dashModule' + IntToStr(I + 1) + 'Text',
      LModuleWidth - Metric(LSpacing.S24));
  end;

  FDashboardStatus.SetBounds(Metric(LSpacing.S24), LTop, LAvailable,
    Metric(LDashboardTokens.StatusHeight));
  LText := FindComponent('dashStatusConnection') as TDACSystemText;
  if LText <> nil then
    LText.SetBounds(Metric(LSpacing.S20), Metric(LDashboardTokens.StatusTextTop),
      Metric(LDashboardTokens.StatusConnectionWidth),
      Metric(LDashboardTokens.StatusTextHeight));
  LText := FindComponent('dashStatusFarm') as TDACSystemText;
  if LText <> nil then
    LText.SetBounds(Max(Metric(LDashboardTokens.StatusFarmMinimumLeft),
      LAvailable div 2 - Metric(LDashboardTokens.StatusFarmCenterOffset)),
      Metric(LDashboardTokens.StatusTextTop), Metric(LDashboardTokens.StatusFarmWidth),
      Metric(LDashboardTokens.StatusTextHeight));
  LText := FindComponent('dashStatusSeason') as TDACSystemText;
  if LText <> nil then
    LText.SetBounds(Max(Metric(LDashboardTokens.StatusSeasonMinimumLeft),
      LAvailable - Metric(LDashboardTokens.StatusSeasonRightInset)),
      Metric(LDashboardTokens.StatusTextTop), Metric(LDashboardTokens.StatusSeasonWidth),
      Metric(LDashboardTokens.StatusTextHeight));
  SetTextWidth('dashAgendaLine1', FDashboardAgenda.Width - Metric(LSpacing.S24 * 2));
  SetTextWidth('dashAgendaLine2', FDashboardAgenda.Width - Metric(LSpacing.S24 * 2));
  SetTextWidth('dashAgendaLine3', FDashboardAgenda.Width - Metric(LSpacing.S24 * 2));
  SetTextWidth('dashAgendaFooter', FDashboardAgenda.Width - Metric(LSpacing.S24 * 2));
  SetTextWidth('dashActivityLine1', FDashboardActivity.Width - Metric(LSpacing.S24 * 2));
  SetTextWidth('dashActivityLine2', FDashboardActivity.Width - Metric(LSpacing.S24 * 2));
  SetTextWidth('dashActivityLine3', FDashboardActivity.Width - Metric(LSpacing.S24 * 2));
  SetTextWidth('dashActivityFooter', FDashboardActivity.Width - Metric(LSpacing.S24 * 2));
  if FDashboardChart <> nil then
    FDashboardChart.SetBounds(Metric(LSpacing.S20),
      Metric(LDashboardTokens.ChartTop), Max(Metric(LDashboardTokens.ChartMinimumWidth),
      FDashboardProductivity.Width - Metric(LSpacing.S40)),
      Max(Metric(LDashboardTokens.ChartMinimumHeight), FDashboardProductivity.Height -
      Metric(LDashboardTokens.ChartTop + LSpacing.S20)));
  // The selector is a native TDACButton; sizing it declaratively keeps the
  // component composable while the chart receives only the remaining canvas.
  if FindComponent('dashProductivitySelect') is TDACButton then
    TDACButton(FindComponent('dashProductivitySelect')).SetBounds(
      Max(Metric(LSpacing.S20), FDashboardProductivity.Width -
        Metric(LDashboardTokens.ProductivitySelectRightInset)), Metric(LSpacing.S16),
      Metric(LDashboardTokens.ProductivitySelectWidth),
      Metric(LControlTokens.ButtonSmall.Height));
  FDashboardQuickActions.Realign;
  FDashboardModules.Realign;
end;

procedure TForm1.CMShowingChanged(var AMessage: TMessage);
begin
  inherited;
  FitToWorkArea;
  RequestDemoLayout;
end;

procedure TForm1.CreateWnd;
begin
  inherited;
  if csDesigning in ComponentState then
    Exit;
  RequestDemoLayout;
end;

procedure TForm1.DemoNavigationClick(Sender: TObject);
var
  LButton: TDACButton;
begin
  if not (Sender is TDACButton) or (GalleryTabs = nil) then
    Exit;
  LButton := TDACButton(Sender);
  if (LButton.Tag < 0) or (LButton.Tag >= GalleryTabs.PageCount) then
    Exit;
  GalleryTabs.ActiveIndex := LButton.Tag;
end;

procedure TForm1.FitToWorkArea;
var
  LHeight: Integer;
  LWidth: Integer;
  LMonitor: TMonitor;
  LWorkArea: TRect;
begin
  if (csDesigning in ComponentState) or not HandleAllocated or
    (Width <= 0) or (Height <= 0) then
    Exit;
  if (Parent <> nil) and not Parent.HandleAllocated then
    Exit;
  LMonitor := Monitor;
  if LMonitor = nil then
    Exit;
  LWorkArea := LMonitor.WorkareaRect;

  LWidth := Min(Width, LWorkArea.Width);
  LHeight := Min(Height, LWorkArea.Height);
  SetBounds(LWorkArea.Left + (LWorkArea.Width - LWidth) div 2,
    LWorkArea.Top + (LWorkArea.Height - LHeight) div 2, LWidth, LHeight);
end;

procedure TForm1.GalleryTabsChange(Sender: TObject);
begin
  RefreshDemoNavigation;
  RequestDemoLayout;
end;

procedure TForm1.ThemeToggleClick(Sender: TObject);
var
  LMode: TDACThemeMode;
begin
  LMode := TDACThemeManager.ApplicationMode;
  if LMode = dtmDark then
    LMode := dtmLight
  else
    LMode := dtmDark;
  TDACThemeManager.SetApplicationMode(LMode);
end;

procedure TForm1.ThemeChanged(Sender: TObject);
var
  LControlTokens: TDACControlTokens;
  LMode: TDACThemeMode;
begin
  LMode := TDACThemeManager.ApplicationMode;
  LControlTokens := TDACComponentStyle.Resolve(LMode).Tokens.Controls;
  Color := TDACComponentColors.ToVclColor(
    LControlTokens.ScrollContainerViewportBackground);
  if FThemeToggle <> nil then
  begin
    if LMode = dtmLight then
    begin
      FThemeToggle.Caption := 'Tema escuro';
      FThemeToggle.IconKind := mikThemeMoon;
    end
    else
    begin
      FThemeToggle.Caption := 'Tema claro';
      FThemeToggle.IconKind := mikThemeSun;
    end;
    FThemeToggle.Redraw;
    LayoutThemeToggle;
  end;
  Invalidate;
  if HandleAllocated then
    PostMessage(Handle, WM_DEMO_APPLY_THEME, 0, 0);
end;

procedure TForm1.Loaded;
begin
  inherited;
  BuildDashboard;
  BuildDemoNavigation;
  BuildThemeToggle;
  FSelectorPreferredWidth := (FindComponent('demoCombo') as TControl).Width;
  TDACThemeManager.RegisterListener(Self, ThemeChanged);
  TDACThemeManager.SetApplicationMode(dtmDark);
  ThemeChanged(Self);
  if GalleryTabs <> nil then
    GalleryTabs.OnChange := GalleryTabsChange;
  RefreshDemoNavigation;
  RequestDemoLayout;
end;

function TForm1.NavigationCanRemainExpanded: Boolean;
var
  I: Integer;
  J: Integer;
  LButton: TDACButton;
  LDemoTokens: TDACDemoTokens;
  LGrid: TDACGridContainer;
  LMargin: Integer;
  LRequiredContentWidth: Integer;
  LTitleWidth: Integer;
  LGrids: array[0..4] of TDACGridContainer;
begin
  if lblButtonsTitle = nil then
    Exit(True);
  LDemoTokens := TDACDemoTokens.Default;
  if ClientWidth < LDemoTokens.NavigationCompactBreakpoint then
    Exit(False);
  LMargin := LDemoTokens.ContentHorizontalMargin;
  LTitleWidth := lblButtonsTitle.MeasureTextWidth(lblButtonsTitle.Text,
    lblButtonsTitle.FontFamily, lblButtonsTitle.FontSize,
    lblButtonsTitle.Bold);
  LRequiredContentWidth := LTitleWidth;
  LGrids[0] := gcButtonKinds;
  LGrids[1] := gcButtonSizes;
  LGrids[2] := gcButtonIcons;
  LGrids[3] := gcButtonStates;
  LGrids[4] := gcButtonSpecials;
  for I := Low(LGrids) to High(LGrids) do
  begin
    LGrid := LGrids[I];
    if LGrid = nil then
      Continue;
    for J := 0 to LGrid.ControlCount - 1 do
      if LGrid.Controls[J] is TDACButton then
      begin
        LButton := TDACButton(LGrid.Controls[J]);
        if LButton.Visible then
          LRequiredContentWidth := Max(LRequiredContentWidth,
            LButton.MinimumContentWidth);
      end;
  end;
  Result := ClientWidth - LDemoTokens.NavigationWidth >=
    LRequiredContentWidth + (LMargin * 2);
end;

procedure TForm1.RefreshDemoNavigation;
var
  I: Integer;
begin
  if (GalleryTabs = nil) or (Length(FDemoNavigationButtons) <>
    GalleryTabs.PageCount) then
    Exit;
  for I := 0 to High(FDemoNavigationButtons) do
    if FDemoNavigationButtons[I] <> nil then
      if GalleryTabs.ActivePage = GalleryTabs.Pages[I] then
        FDemoNavigationButtons[I].Kind := mbkPrimary
      else
        FDemoNavigationButtons[I].Kind := mbkGhost;
end;

procedure TForm1.Resize;
begin
  inherited;
  if csDesigning in ComponentState then
    Exit;
  RequestDemoLayout;
end;

procedure TForm1.WMDemoApplyLayout(var AMessage: TMessage);
begin
  if (csDesigning in ComponentState) or not HandleAllocated or
    (Cardinal(AMessage.WParam) <> FLayoutRevision) then
    Exit;
  ApplyDemoLayout;
end;

procedure TForm1.WMDemoApplyTheme(var AMessage: TMessage);
var
  I: Integer;
begin
  if (csDesigning in ComponentState) or not HandleAllocated then
    Exit;
  { GalleryTabs is the single theme boundary for Dashboard and every one of
    the declarative family pages. Its listener commits PageControl,
    TabSheets and descendant listeners roots-to-leaves without page-specific
    color traversal in the Demo. }
  if GalleryTabs <> nil then
    TDACThemeManager.RefreshListener(GalleryTabs);
  if FDemoNavigation <> nil then
    TDACThemeManager.RefreshListener(FDemoNavigation);
  if FDemoNavigationTitle <> nil then
    TDACThemeManager.RefreshListener(FDemoNavigationTitle);
  for I := 0 to High(FDemoNavigationButtons) do
    if FDemoNavigationButtons[I] <> nil then
      TDACThemeManager.RefreshListener(FDemoNavigationButtons[I]);
  if FThemeToggle <> nil then
    TDACThemeManager.RefreshListener(FThemeToggle);
  LayoutThemeToggle;
end;

initialization
  System.Classes.RegisterClass(TLabel);

end.
