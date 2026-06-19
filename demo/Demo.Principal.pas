unit Demo.Principal;

interface

uses
  System.Classes,
  System.Types,
  Winapi.Messages,
  Winapi.Windows,
  Vcl.Controls,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.Graphics,
  Vcl.StdCtrls,
  DAC.Components.Controls.Badges,
  DAC.Components.Controls.Button,
  DAC.Components.Controls.ButtonEdit,
  DAC.Components.Controls.Charts,
  DAC.Components.Controls.ComboBox,
  DAC.Components.Controls.Container,
  DAC.Components.Controls.DataGrid,
  DAC.Components.Controls.DateTimePicker,
  DAC.Components.Controls.Edit,
  DAC.Components.Controls.Feedback,
  DAC.Components.Controls.GridContainer,
  DAC.Components.Controls.Loading,
  DAC.Components.Controls.Memo,
  DAC.Components.Controls.Pagination,
  DAC.Components.Controls.Progress,
  DAC.Components.Controls.ReportViewer,
  DAC.Components.Controls.ScrollContainer,
  DAC.Components.Controls.Selectors,
  DAC.Components.Controls.StatusBar,
  DAC.Components.Controls.SummaryCard,
  DAC.Components.Controls.Tabs;

type
  TForm1 = class(TForm)
    SystemBar: TDACContainer;
    SystemIcon: TDACButton;
    SystemTitle: TLabel;
    WindowMinimizeButton: TDACButton;
    WindowMaximizeButton: TDACButton;
    WindowCloseButton: TDACButton;
    MainTabs: TDACTabs;
    PageButtons: TDACScrollContainer;
    SectionButtons: TDACContainer;
    ButtonPrimary: TDACButton;
    ButtonSecondary: TDACButton;
    ButtonWarning: TDACButton;
    ButtonDanger: TDACButton;
    ButtonGhost: TDACButton;
    ButtonTransparent: TDACButton;
    ButtonIconAdd: TDACButton;
    ButtonIconEdit: TDACButton;
    ButtonIconDelete: TDACButton;
    PageInputs: TDACScrollContainer;
    SectionInputs: TDACContainer;
    InputText: TDACEdit;
    InputRequired: TDACEdit;
    InputMasked: TDACEdit;
    InputPassword: TDACEdit;
    InputSearch: TDACEdit;
    InputCombo: TDACComboBox;
    InputNumeric: TDACEdit;
    InputDate: TDACEdit;
    InputTime: TDACEdit;
    InputDateTimePicker: TDACDateTimePicker;
    InputMemo: TDACMemo;
    InputButtonEditDefault: TDACButtonEdit;
    InputButtonEditCalendar: TDACButtonEdit;
    InputButtonEditMore: TDACButtonEdit;
    InputButtonEditOk: TDACButtonEdit;
    InputButtonEditDropDown: TDACButtonEdit;
    InputButtonEditClear: TDACButtonEdit;
    PageControls: TDACScrollContainer;
    SectionControls: TDACContainer;
    DemoCheckMarked: TDACCheckBox;
    DemoCheckUnmarked: TDACCheckBox;
    DemoRadioSelected: TDACRadioButton;
    DemoRadioUnselected: TDACRadioButton;
    DemoToggleOn: TDACToggleSwitch;
    DemoToggleOff: TDACToggleSwitch;
    DemoSlider: TDACSlider;
    PageContainers: TDACScrollContainer;
    SectionContainers: TDACContainer;
    ContainerSuiteSection: TDACContainer;
    ContainerDarkPanel: TDACContainer;
    ContainerTransparent: TDACContainer;
    ButtonInsideContainer: TDACButton;
    DACEdit1: TDACEdit;
    DACMemo1: TDACMemo;
    DACComboBox1: TDACComboBox;
    DemoScrollContainer: TDACScrollContainer;
    DemoGridContainer: TDACGridContainer;
    PageTabs: TDACScrollContainer;
    SectionTabs: TDACContainer;
    DemoHorizontalTabs: TDACTabs;
    DemoHorizontalContent: TDACContainer;
    DemoVerticalTabs: TDACTabs;
    DemoVerticalContent: TDACContainer;
    DemoPillTabs: TDACTabs;
    DemoPillContent: TDACContainer;
    PageCards: TDACScrollContainer;
    SectionCards: TDACContainer;
    CardRevenue: TDACSummaryCard;
    CardOrders: TDACSummaryCard;
    CardClients: TDACSummaryCard;
    CardProducts: TDACSummaryCard;
    PageGrid: TDACScrollContainer;
    SectionGrid: TDACContainer;
    DemoDataGrid: TDACDataGrid;
    PageStatus: TDACScrollContainer;
    SectionStatus: TDACContainer;
    DemoStatusBar: TDACStatusBar;
    PageBadges: TDACScrollContainer;
    SectionBadges: TDACContainer;
    BadgeCount: TDACBadge;
    BadgePending: TDACBadge;
    BadgeDanger: TDACBadge;
    BadgeChipActive: TDACBadge;
    BadgeChipFilter: TDACBadge;
    BadgeTagNew: TDACBadge;
    BadgeTagPromo: TDACBadge;
    BadgePillOpen: TDACBadge;
    BadgePillDone: TDACBadge;
    PageProgress: TDACScrollContainer;
    SectionProgress: TDACContainer;
    ProgressLinear: TDACProgress;
    ProgressWarning: TDACProgress;
    ProgressCircular: TDACProgress;
    ProgressCircularDanger: TDACProgress;
    PagePagination: TDACScrollContainer;
    SectionPagination: TDACContainer;
    PaginationMain: TDACPagination;
    PaginationCompact: TDACPagination;
    PageLoading: TDACScrollContainer;
    SectionLoading: TDACContainer;
    LoadingSpinner: TDACLoading;
    LoadingDots: TDACLoading;
    LoadingSkeleton: TDACLoading;
    PageFeedback: TDACScrollContainer;
    SectionFeedback: TDACContainer;
    ToastSuccess: TDACToast;
    ToastWarning: TDACToast;
    ToastDanger: TDACToast;
    ModalPreview: TDACModalDialog;
    PageCharts: TDACScrollContainer;
    SectionCharts: TDACContainer;
    ChartBars: TDACBarChart;
    ChartLine: TDACLineChart;
    ChartArea: TDACAreaChart;
    ChartDoughnut: TDACDoughnutChart;
    PageReport: TDACScrollContainer;
    SectionReport: TDACContainer;
    ReportPreview: TDACReportViewer;
    procedure WindowCloseButtonClick(Sender: TObject);
    procedure WindowMaximizeButtonClick(Sender: TObject);
    procedure WindowMinimizeButtonClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure MainTabsChange(Sender: TObject);
  private
    procedure WMNCHitTest(var AMessage: TWMNCHitTest); message WM_NCHITTEST;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

procedure TForm1.WindowCloseButtonClick(Sender: TObject);
begin
  Close;
end;

procedure TForm1.WindowMaximizeButtonClick(Sender: TObject);
begin
  if WindowState = wsMaximized then
    WindowState := wsNormal
  else
    WindowState := wsMaximized;
end;

procedure TForm1.WindowMinimizeButtonClick(Sender: TObject);
begin
  WindowState := wsMinimized;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  MainTabsChange(MainTabs);
end;

procedure TForm1.MainTabsChange(Sender: TObject);
  procedure SetPageVisible(const AControl: TControl; const AVisible: Boolean);
  begin
    if AControl.Visible <> AVisible then
      AControl.Visible := AVisible;

    if AVisible and (AControl is TWinControl) then
      TWinControl(AControl).BringToFront;
  end;
begin
  MainTabs.DisableAlign;
  try
    SetPageVisible(PageButtons, MainTabs.ActiveIndex = 0);
    SetPageVisible(PageInputs, MainTabs.ActiveIndex = 1);
    SetPageVisible(PageControls, MainTabs.ActiveIndex = 2);
    SetPageVisible(PageContainers, MainTabs.ActiveIndex = 3);
    SetPageVisible(PageTabs, MainTabs.ActiveIndex = 4);
    SetPageVisible(PageCards, MainTabs.ActiveIndex = 5);
    SetPageVisible(PageGrid, MainTabs.ActiveIndex = 6);
    SetPageVisible(PageStatus, MainTabs.ActiveIndex = 7);
    SetPageVisible(PageBadges, MainTabs.ActiveIndex = 8);
    SetPageVisible(PageProgress, MainTabs.ActiveIndex = 9);
    SetPageVisible(PagePagination, MainTabs.ActiveIndex = 10);
    SetPageVisible(PageLoading, MainTabs.ActiveIndex = 11);
    SetPageVisible(PageFeedback, MainTabs.ActiveIndex = 12);
    SetPageVisible(PageCharts, MainTabs.ActiveIndex = 13);
    SetPageVisible(PageReport, MainTabs.ActiveIndex = 14);

    if MainTabs.ActiveIndex = 10 then
    begin
      PaginationMain.Redraw;
      PaginationCompact.Redraw;
    end;
  finally
    MainTabs.EnableAlign;
  end;
end;

procedure TForm1.WMNCHitTest(var AMessage: TWMNCHitTest);
const
  ResizeBorder = 6;
  SystemBarHeight = 56;
var
  LPoint: TPoint;
begin
  inherited;

  if WindowState = wsMaximized then
    Exit;

  LPoint := ScreenToClient(Point(AMessage.XPos, AMessage.YPos));

  if LPoint.Y < ResizeBorder then
  begin
    if LPoint.X < ResizeBorder then
      AMessage.Result := HTTOPLEFT
    else if LPoint.X > ClientWidth - ResizeBorder then
      AMessage.Result := HTTOPRIGHT
    else
      AMessage.Result := HTTOP;
    Exit;
  end;

  if LPoint.Y > ClientHeight - ResizeBorder then
  begin
    if LPoint.X < ResizeBorder then
      AMessage.Result := HTBOTTOMLEFT
    else if LPoint.X > ClientWidth - ResizeBorder then
      AMessage.Result := HTBOTTOMRIGHT
    else
      AMessage.Result := HTBOTTOM;
    Exit;
  end;

  if LPoint.X < ResizeBorder then
  begin
    AMessage.Result := HTLEFT;
    Exit;
  end;

  if LPoint.X > ClientWidth - ResizeBorder then
  begin
    AMessage.Result := HTRIGHT;
    Exit;
  end;

  if (WindowMinimizeButton <> nil) and (LPoint.Y < SystemBarHeight) and
    (LPoint.X < WindowMinimizeButton.Left - 12) then
    AMessage.Result := HTCAPTION;
end;

end.

