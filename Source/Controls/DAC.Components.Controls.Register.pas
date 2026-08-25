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
  DAC.Components.Controls.CheckBox,
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
  DAC.Components.Controls.RadioButton,
  DAC.Components.Controls.ReportViewer,
  DAC.Components.Controls.ScrollContainer,
  DAC.Components.Controls.Selectors,
  DAC.Components.Controls.SkiaControl,
  DAC.Components.Controls.Slider,
  DAC.Components.Controls.StatusBar,
  DAC.Components.Controls.StatusTimelineChart,
  DAC.Components.Controls.SummaryCard,
  DAC.Components.Controls.SystemText,
  DAC.Components.Controls.Tabs,
  DAC.Components.Controls.ToggleSwitch;

procedure RegisterDACComponentClasses;
begin
  RegisterClass(TDACBadge);
  RegisterClass(TDACButton);
  RegisterClass(TDACButtonEdit);
  RegisterClass(TDACCheckBox);
  RegisterClass(TDACComboBox);
  RegisterClass(TDACContainer);
  RegisterClass(TDACChart);
  RegisterClass(TDACDateTimePicker);
  RegisterClass(TDACEdit);
  RegisterClass(TDACGridContainer);
  RegisterClass(TDACLoading);
  RegisterClass(TDACMemo);
  RegisterClass(TDACModalDialog);
  RegisterClass(TDACPagination);
  RegisterClass(TDACProgress);
  RegisterClass(TDACRadioButton);
  RegisterClass(TDACReportViewer);
  RegisterClass(TDACScrollContainer);
  RegisterClass(TDACSelector);
  RegisterClass(TDACSlider);
  { TDACSkiaControl nao e registrado: e a base abstrata dos componentes.
    Registrar a base na paleta expoe internos e viola o principio de
    minima superficie publica (SOLID - ISP). }
  RegisterClass(TDACStatusBar);
  RegisterClass(TDACStatusTimelineChart);
  RegisterClass(TDACSummaryCard);
  RegisterClass(TDACSystemText);
  RegisterClass(TDACTabs);
  RegisterClass(TDACToast);
  RegisterClass(TDACToggleSwitch);
  RegisterClass(TDACTooltip);
end;

initialization
  RegisterDACComponentClasses;

end.
