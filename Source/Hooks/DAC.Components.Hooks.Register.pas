unit DAC.Components.Hooks.Register;

interface

procedure RegisterDACComponentStyleHooks;
procedure UnregisterDACComponentStyleHooks;

implementation

uses
  Vcl.Forms,
  Vcl.Themes,
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
  DAC.Components.Controls.Tabs,
  DAC.Components.Hooks.SkiaControls,
  DAC.Components.Hooks.Tabs;

var
  GHooksRegistered: Boolean;

procedure RegisterDACComponentStyleHooks;
begin
  if GHooksRegistered then
    Exit;

  TCustomStyleEngine.RegisterStyleHook(TDACTabs, TDACPageControlStyleHook);
  TCustomStyleEngine.RegisterStyleHook(TDACScrollContainer, TScrollBoxStyleHook);
  TCustomStyleEngine.RegisterStyleHook(TDACDataGrid, TScrollingStyleHook);
  TCustomStyleEngine.RegisterStyleHook(TDACContainer, TDACSkiaControlStyleHook);
  TCustomStyleEngine.RegisterStyleHook(TDACGridContainer, TDACSkiaControlStyleHook);
  TCustomStyleEngine.RegisterStyleHook(TDACButton, TDACSkiaControlStyleHook);
  TCustomStyleEngine.RegisterStyleHook(TDACEdit, TDACSkiaControlStyleHook);
  TCustomStyleEngine.RegisterStyleHook(TDACButtonEdit, TDACSkiaControlStyleHook);
  TCustomStyleEngine.RegisterStyleHook(TDACDateTimePicker, TDACSkiaControlStyleHook);
  TCustomStyleEngine.RegisterStyleHook(TDACComboBox, TDACSkiaControlStyleHook);
  TCustomStyleEngine.RegisterStyleHook(TDACMemo, TDACSkiaControlStyleHook);
  TCustomStyleEngine.RegisterStyleHook(TDACCheckBox, TDACSkiaControlStyleHook);
  TCustomStyleEngine.RegisterStyleHook(TDACRadioButton, TDACSkiaControlStyleHook);
  TCustomStyleEngine.RegisterStyleHook(TDACToggleSwitch, TDACSkiaControlStyleHook);
  TCustomStyleEngine.RegisterStyleHook(TDACSlider, TDACSkiaControlStyleHook);
  TCustomStyleEngine.RegisterStyleHook(TDACSummaryCard, TDACSkiaControlStyleHook);
  TCustomStyleEngine.RegisterStyleHook(TDACChart, TDACSkiaControlStyleHook);
  TCustomStyleEngine.RegisterStyleHook(TDACBarChart, TDACSkiaControlStyleHook);
  TCustomStyleEngine.RegisterStyleHook(TDACLineChart, TDACSkiaControlStyleHook);
  TCustomStyleEngine.RegisterStyleHook(TDACAreaChart, TDACSkiaControlStyleHook);
  TCustomStyleEngine.RegisterStyleHook(TDACDoughnutChart, TDACSkiaControlStyleHook);
  TCustomStyleEngine.RegisterStyleHook(TDACBadge, TDACSkiaControlStyleHook);
  TCustomStyleEngine.RegisterStyleHook(TDACProgress, TDACSkiaControlStyleHook);
  TCustomStyleEngine.RegisterStyleHook(TDACPagination, TDACSkiaControlStyleHook);
  TCustomStyleEngine.RegisterStyleHook(TDACLoading, TDACSkiaControlStyleHook);
  TCustomStyleEngine.RegisterStyleHook(TDACToast, TDACSkiaControlStyleHook);
  TCustomStyleEngine.RegisterStyleHook(TDACModalDialog, TDACSkiaControlStyleHook);
  TCustomStyleEngine.RegisterStyleHook(TDACStatusBar, TDACSkiaControlStyleHook);
  TCustomStyleEngine.RegisterStyleHook(TDACReportViewer, TDACSkiaControlStyleHook);

  GHooksRegistered := True;
end;

procedure UnregisterDACComponentStyleHooks;
begin
  if not GHooksRegistered then
    Exit;

  TCustomStyleEngine.UnRegisterStyleHook(TDACDataGrid, TScrollingStyleHook);
  TCustomStyleEngine.UnRegisterStyleHook(TDACScrollContainer, TScrollBoxStyleHook);
  TCustomStyleEngine.UnRegisterStyleHook(TDACTabs, TDACPageControlStyleHook);
  TCustomStyleEngine.UnRegisterStyleHook(TDACReportViewer, TDACSkiaControlStyleHook);
  TCustomStyleEngine.UnRegisterStyleHook(TDACStatusBar, TDACSkiaControlStyleHook);
  TCustomStyleEngine.UnRegisterStyleHook(TDACModalDialog, TDACSkiaControlStyleHook);
  TCustomStyleEngine.UnRegisterStyleHook(TDACToast, TDACSkiaControlStyleHook);
  TCustomStyleEngine.UnRegisterStyleHook(TDACLoading, TDACSkiaControlStyleHook);
  TCustomStyleEngine.UnRegisterStyleHook(TDACPagination, TDACSkiaControlStyleHook);
  TCustomStyleEngine.UnRegisterStyleHook(TDACProgress, TDACSkiaControlStyleHook);
  TCustomStyleEngine.UnRegisterStyleHook(TDACBadge, TDACSkiaControlStyleHook);
  TCustomStyleEngine.UnRegisterStyleHook(TDACDoughnutChart, TDACSkiaControlStyleHook);
  TCustomStyleEngine.UnRegisterStyleHook(TDACAreaChart, TDACSkiaControlStyleHook);
  TCustomStyleEngine.UnRegisterStyleHook(TDACLineChart, TDACSkiaControlStyleHook);
  TCustomStyleEngine.UnRegisterStyleHook(TDACBarChart, TDACSkiaControlStyleHook);
  TCustomStyleEngine.UnRegisterStyleHook(TDACChart, TDACSkiaControlStyleHook);
  TCustomStyleEngine.UnRegisterStyleHook(TDACSummaryCard, TDACSkiaControlStyleHook);
  TCustomStyleEngine.UnRegisterStyleHook(TDACSlider, TDACSkiaControlStyleHook);
  TCustomStyleEngine.UnRegisterStyleHook(TDACToggleSwitch, TDACSkiaControlStyleHook);
  TCustomStyleEngine.UnRegisterStyleHook(TDACRadioButton, TDACSkiaControlStyleHook);
  TCustomStyleEngine.UnRegisterStyleHook(TDACCheckBox, TDACSkiaControlStyleHook);
  TCustomStyleEngine.UnRegisterStyleHook(TDACMemo, TDACSkiaControlStyleHook);
  TCustomStyleEngine.UnRegisterStyleHook(TDACComboBox, TDACSkiaControlStyleHook);
  TCustomStyleEngine.UnRegisterStyleHook(TDACDateTimePicker, TDACSkiaControlStyleHook);
  TCustomStyleEngine.UnRegisterStyleHook(TDACButtonEdit, TDACSkiaControlStyleHook);
  TCustomStyleEngine.UnRegisterStyleHook(TDACEdit, TDACSkiaControlStyleHook);
  TCustomStyleEngine.UnRegisterStyleHook(TDACButton, TDACSkiaControlStyleHook);
  TCustomStyleEngine.UnRegisterStyleHook(TDACGridContainer, TDACSkiaControlStyleHook);
  TCustomStyleEngine.UnRegisterStyleHook(TDACContainer, TDACSkiaControlStyleHook);

  GHooksRegistered := False;
end;

initialization
  RegisterDACComponentStyleHooks;

finalization
  UnregisterDACComponentStyleHooks;

end.

