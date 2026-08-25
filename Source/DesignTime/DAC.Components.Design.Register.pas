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
  DAC.Components.Controls.CheckBox,
  DAC.Components.Controls.RadioButton,
  DAC.Components.Controls.ToggleSwitch,
  DAC.Components.Controls.Slider,
  DAC.Components.Controls.Selectors,
  DAC.Components.Controls.StatusBar,
  DAC.Components.Controls.StatusTimelineChart,
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
    TDACStatusTimelineChart,
    TDACBadge,
    TDACProgress,
    TDACPagination,
    TDACLoading,
    TDACToast,
    TDACModalDialog,
    TDACTooltip,
    TDACStatusBar,
    TDACReportViewer
  ]);
end;

end.

