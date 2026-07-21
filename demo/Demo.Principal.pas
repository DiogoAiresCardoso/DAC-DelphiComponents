unit Demo.Principal;

interface

uses
  System.Classes,
  Vcl.ComCtrls,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.StdCtrls,
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
  DAC.Components.Controls.Pagination,
  DAC.Components.Controls.Progress,
  DAC.Components.Controls.Register,
  DAC.Components.Controls.ReportViewer,
  DAC.Components.Controls.ScrollContainer,
  DAC.Components.Controls.Selectors,
  DAC.Components.Controls.StatusBar,
  DAC.Components.Controls.SummaryCard,
  DAC.Components.Controls.Tabs;

type
  TForm1 = class(TForm)
    GalleryTabs: TDACTabs;
    tsButtons: TTabSheet;
    tsInputs: TTabSheet;
    tsSelectors: TTabSheet;
    tsControls: TTabSheet;
    tsTabs: TTabSheet;
    tsCards: TTabSheet;
    tsGrid: TTabSheet;
    tsStatus: TTabSheet;
    tsProgress: TTabSheet;
    tsPills: TTabSheet;
    tsFeedback: TTabSheet;
    tsPagination: TTabSheet;
    tsLoading: TTabSheet;
    tsCharts: TTabSheet;
    tsReport: TTabSheet;
    scrButtons: TDACScrollContainer;
    lblButtonsTitle: TLabel;
    lblButtonsSubtitle: TLabel;
    lblButtonKinds: TLabel;
    gcButtonKinds: TDACGridContainer;
    btnKindPrimary: TDACButton;
    btnKindSecondary: TDACButton;
    btnKindGhost: TDACButton;
    btnKindWarning: TDACButton;
    btnKindDanger: TDACButton;
    btnKindTransparent: TDACButton;
    btnKindInputAction: TDACButton;
    lblButtonSizes: TLabel;
    gcButtonSizes: TDACGridContainer;
    btnSizeSmall: TDACButton;
    btnSizeMedium: TDACButton;
    btnSizeLarge: TDACButton;
    btnRadiusSoft: TDACButton;
    btnRadiusPill: TDACButton;
    btnNoTabStop: TDACButton;
    lblButtonIcons: TLabel;
    gcButtonIcons: TDACGridContainer;
    btnIconLeft: TDACButton;
    btnIconRight: TDACButton;
    btnIconOnlyAdd: TDACButton;
    btnIconOnlyMore: TDACButton;
    btnIconCustomSize: TDACButton;
    btnIconDanger: TDACButton;
    lblButtonStates: TLabel;
    gcButtonStates: TDACGridContainer;
    btnStateNormal: TDACButton;
    btnStateHover: TDACButton;
    btnStateFocus: TDACButton;
    btnStatePressed: TDACButton;
    btnStateLoading: TDACButton;
    btnStateDisabled: TDACButton;
    lblButtonSpecials: TLabel;
    gcButtonSpecials: TDACGridContainer;
    btnSplitMain: TDACButton;
    btnSplitMenu: TDACButton;
    btnSearchAction: TDACButton;
    btnSaveAction: TDACButton;
    btnDeleteAction: TDACButton;
    btnUploadAction: TDACButton;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

end.
