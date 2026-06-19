unit MaxxRural.Components.Design.Register;

interface

procedure Register;

implementation

uses
  System.Classes,
  DesignIntf,
  MaxxRural.Components.Controls.Badges,
  MaxxRural.Components.Controls.Button,
  MaxxRural.Components.Controls.ButtonEdit,
  MaxxRural.Components.Controls.Charts,
  MaxxRural.Components.Controls.ComboBox,
  MaxxRural.Components.Controls.Container,
  MaxxRural.Components.Controls.DataAware,
  MaxxRural.Components.Controls.DataGrid,
  MaxxRural.Components.Controls.DateTimePicker,
  MaxxRural.Components.Controls.Edit,
  MaxxRural.Components.Controls.Feedback,
  MaxxRural.Components.Controls.GridContainer,
  MaxxRural.Components.Controls.Loading,
  MaxxRural.Components.Controls.Memo,
  MaxxRural.Components.Controls.Pagination,
  MaxxRural.Components.Controls.Progress,
  MaxxRural.Components.Controls.ReportViewer,
  MaxxRural.Components.Controls.ScrollContainer,
  MaxxRural.Components.Controls.Selectors,
  MaxxRural.Components.Controls.StatusBar,
  MaxxRural.Components.Controls.SummaryCard,
  MaxxRural.Components.Controls.Tabs;

procedure Register;
begin
  RegisterComponents('MaxxRural Skia', [
    TMaxxRuralContainer,
    TMaxxRuralScrollContainer,
    TMaxxRuralGridContainer,
    TMaxxRuralButton,
    TMaxxRuralEdit,
    TMaxxRuralButtonEdit,
    TMaxxRuralDateTimePicker,
    TMaxxRuralComboBox,
    TMaxxRuralMemo,
    TMaxxRuralCheckBox,
    TMaxxRuralRadioButton,
    TMaxxRuralToggleSwitch,
    TMaxxRuralSlider,
    TMaxxRuralTabs,
    TMaxxRuralSummaryCard,
    TMaxxRuralChart,
    TMaxxRuralBarChart,
    TMaxxRuralLineChart,
    TMaxxRuralAreaChart,
    TMaxxRuralDoughnutChart,
    TMaxxRuralBadge,
    TMaxxRuralProgress,
    TMaxxRuralPagination,
    TMaxxRuralLoading,
    TMaxxRuralToast,
    TMaxxRuralModalDialog,
    TMaxxRuralStatusBar,
    TMaxxRuralReportViewer,
    TMaxxRuralDataGrid
  ]);

  RegisterComponents('MaxxRural Skia DB', [
    TMaxxRuralDBEdit,
    TMaxxRuralDBMemo,
    TMaxxRuralDBComboBox,
    TMaxxRuralDBDateTimePicker,
    TMaxxRuralDBCheckBox,
    TMaxxRuralDBRadioButton,
    TMaxxRuralDBToggleSwitch,
    TMaxxRuralDBSlider
  ]);
end;

end.
