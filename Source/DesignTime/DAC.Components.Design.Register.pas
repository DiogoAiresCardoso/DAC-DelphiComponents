unit DAC.Components.Design.Register;

interface

procedure Register;

implementation

uses
  System.Classes,
  DesignIntf,
  DAC.Components.Controls.Badges,
  DAC.Components.Controls.Button,
  DAC.Components.Controls.ButtonEdit,
  DAC.Components.Controls.Charts,
  DAC.Components.Controls.ComboBox,
  DAC.Components.Controls.Container,
  DAC.Components.Controls.DataAware,
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

procedure Register;
begin
  RegisterComponents('DAC Skia', [
    TDACContainer,
    TDACScrollContainer,
    TDACGridContainer,
    TDACButton,
    TDACEdit,
    TDACButtonEdit,
    TDACDateTimePicker,
    TDACComboBox,
    TDACMemo,
    TDACCheckBox,
    TDACRadioButton,
    TDACToggleSwitch,
    TDACSlider,
    TDACTabs,
    TDACSummaryCard,
    TDACChart,
    TDACBarChart,
    TDACLineChart,
    TDACAreaChart,
    TDACDoughnutChart,
    TDACBadge,
    TDACProgress,
    TDACPagination,
    TDACLoading,
    TDACToast,
    TDACModalDialog,
    TDACStatusBar,
    TDACReportViewer,
    TDACDataGrid
  ]);

  RegisterComponents('DAC Skia DB', [
    TDACDBEdit,
    TDACDBMemo,
    TDACDBComboBox,
    TDACDBDateTimePicker,
    TDACDBCheckBox,
    TDACDBRadioButton,
    TDACDBToggleSwitch,
    TDACDBSlider
  ]);
end;

end.

