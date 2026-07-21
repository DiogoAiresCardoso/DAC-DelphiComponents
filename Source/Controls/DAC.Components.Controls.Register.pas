unit DAC.Components.Controls.Register;

interface

procedure RegisterDACComponentClasses;

implementation

uses
  System.Classes,
  DAC.Components.Controls.Badges,
  DAC.Components.Controls.Button,
  DAC.Components.Controls.ButtonEdit,
  DAC.Components.Controls.Charts,
  DAC.Components.Controls.ComboBox,
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

procedure RegisterDACComponentClasses;
begin
  RegisterClass(TDACBadge);
  RegisterClass(TDACBarChart);
  RegisterClass(TDACButton);
  RegisterClass(TDACButtonEdit);
  RegisterClass(TDACCheckBox);
  RegisterClass(TDACComboBox);
  RegisterClass(TDACDataGrid);
  RegisterClass(TDACDateTimePicker);
  RegisterClass(TDACDoughnutChart);
  RegisterClass(TDACEdit);
  RegisterClass(TDACGridContainer);
  RegisterClass(TDACLoading);
  RegisterClass(TDACMemo);
  RegisterClass(TDACPagination);
  RegisterClass(TDACProgress);
  RegisterClass(TDACRadioButton);
  RegisterClass(TDACReportViewer);
  RegisterClass(TDACScrollContainer);
  RegisterClass(TDACSlider);
  RegisterClass(TDACStatusBar);
  RegisterClass(TDACSummaryCard);
  RegisterClass(TDACTabs);
  RegisterClass(TDACToast);
  RegisterClass(TDACToggleSwitch);
  RegisterClass(TDACTooltip);
end;

initialization
  RegisterDACComponentClasses;

end.
