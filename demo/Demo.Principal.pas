unit Demo.Principal;

interface

uses
  System.Classes,
  System.Math,
  System.Types,
  Winapi.Messages,
  Winapi.Windows,
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
  private
    function CanApplyRuntimeLayout: Boolean;
    procedure ConfigureResponsiveButtons;
    procedure FitToWorkArea;
  protected
    procedure CreateWnd; override;
    procedure Resize; override;
    procedure CMShowingChanged(var AMessage: TMessage); message CM_SHOWINGCHANGED;
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

function TForm1.CanApplyRuntimeLayout: Boolean;
begin
  Result := not (csDesigning in ComponentState) and (scrButtons <> nil) and
    (scrButtons.Parent <> nil);
end;

procedure TForm1.ConfigureResponsiveButtons;
const
  HorizontalMargin = 24;
var
  LAvailableWidth: Integer;
  LMargin: Integer;
  LMonitor: TMonitor;
  LRuntimePPI: Integer;
  LViewportRect: TRect;
  LViewportWidth: Integer;
begin
  if not CanApplyRuntimeLayout then
    Exit;

  if not Winapi.Windows.GetClientRect(scrButtons.Handle, LViewportRect) then
    Exit;
  LRuntimePPI := PixelsPerInch;
  LMonitor := Monitor;
  if LMonitor <> nil then
    LRuntimePPI := Max(96, LMonitor.PixelsPerInch);
  LMargin := MulDiv(HorizontalMargin, LRuntimePPI, 96);
  LViewportWidth := LViewportRect.Right - LViewportRect.Left;
  LAvailableWidth := Max(0, LViewportWidth - (LMargin * 2));
  // At high DPI, show two complete 3-column action spans per row rather than
  // risking a third action at the physical viewport edge.
  if LRuntimePPI > 96 then
    LAvailableWidth := Min(LAvailableWidth, (LViewportWidth * 2) div 3);
  lblButtonsSubtitle.AutoSize := False;
  lblButtonsSubtitle.Left := LMargin;
  lblButtonsSubtitle.Width := LAvailableWidth;

  gcButtonKinds.Anchors := [akLeft, akTop, akRight];
  gcButtonSizes.Anchors := [akLeft, akTop, akRight];
  gcButtonIcons.Anchors := [akLeft, akTop, akRight];
  gcButtonStates.Anchors := [akLeft, akTop, akRight];
  gcButtonSpecials.Anchors := [akLeft, akTop, akRight];
  gcButtonKinds.SetBounds(LMargin, gcButtonKinds.Top, LAvailableWidth,
    gcButtonKinds.Height);
  gcButtonSizes.SetBounds(LMargin, gcButtonSizes.Top, LAvailableWidth,
    gcButtonSizes.Height);
  gcButtonIcons.SetBounds(LMargin, gcButtonIcons.Top, LAvailableWidth,
    gcButtonIcons.Height);
  gcButtonStates.SetBounds(LMargin, gcButtonStates.Top, LAvailableWidth,
    gcButtonStates.Height);
  gcButtonSpecials.SetBounds(LMargin, gcButtonSpecials.Top, LAvailableWidth,
    gcButtonSpecials.Height);
end;

procedure TForm1.CMShowingChanged(var AMessage: TMessage);
begin
  inherited;
  FitToWorkArea;
  ConfigureResponsiveButtons;
end;

procedure TForm1.CreateWnd;
begin
  inherited;
  if csDesigning in ComponentState then
    Exit;
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

procedure TForm1.Resize;
begin
  inherited;
  if csDesigning in ComponentState then
    Exit;
  ConfigureResponsiveButtons;
end;

end.
