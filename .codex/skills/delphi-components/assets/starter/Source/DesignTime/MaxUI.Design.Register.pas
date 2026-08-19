unit MaxUI.Design.Register;

{$CODEPAGE 65001}

interface

procedure Register;

implementation

uses
  System.Classes,
  DesignIntf,
  MaxUI.Theme,
  MaxUI.Controls.Base,
  MaxUI.Controls.Buttons,
  MaxUI.Controls.Inputs,
  MaxUI.Controls.Selectors,
  MaxUI.Controls.Choices,
  MaxUI.Controls.Tabs,
  MaxUI.Controls.Cards,
  MaxUI.Controls.Data,
  MaxUI.Controls.Feedback,
  MaxUI.Controls.Charts,
  MaxUI.Controls.Report;

procedure Register;
begin
  RegisterComponents('MaxUI', [
    TMaxThemeManager,
    TMaxSurface,
    TMaxSection,
    TMaxCard,
    TMaxButton,
    TMaxIconButton,
    TMaxSplitButton,
    TMaxEdit,
    TMaxSearchEdit,
    TMaxPasswordEdit,
    TMaxMaskedEdit,
    TMaxMemo,
    TMaxComboBox,
    TMaxDatePicker,
    TMaxTimePicker,
    TMaxSpinField,
    TMaxCheckBox,
    TMaxRadioButton,
    TMaxToggleSwitch,
    TMaxSlider,
    TMaxPageControl,
    TMaxSummaryCard,
    TMaxStringGrid,
    TMaxDBGrid,
    TMaxStatusBar,
    TMaxBadge,
    TMaxChip,
    TMaxTag,
    TMaxLinearProgress,
    TMaxCircularProgress,
    TMaxToast,
    TMaxTooltip,
    TMaxModalPanel,
    TMaxPagination,
    TMaxSpinner,
    TMaxChart,
    TMaxReportViewer
  ]);
end;

end.
