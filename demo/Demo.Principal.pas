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
  Vcl.Skia,
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
  DAC.Components.Controls.SystemText,
  DAC.Components.Controls.Tabs,
  DAC.Components.DesignSystem.SpacingTokens;

const
  WM_DEMO_APPLY_LAYOUT = WM_APP + 73;

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
    FDemoNavigation: TDACScrollContainer;
    FDemoNavigationButtons: array of TDACButton;
    FDemoNavigationTitle: TDACSystemText;
    function CanApplyRuntimeLayout: Boolean;
    procedure BuildDemoNavigation;
    procedure ConfigureDemoLayout;
    procedure ConfigureResponsiveButtons;
    procedure DemoNavigationClick(Sender: TObject);
    procedure FitToWorkArea;
    procedure GalleryTabsChange(Sender: TObject);
    function NavigationCanRemainExpanded: Boolean;
    procedure RefreshDemoNavigation;
  protected
    procedure CreateWnd; override;
    procedure Loaded; override;
    procedure Resize; override;
    procedure CMShowingChanged(var AMessage: TMessage); message CM_SHOWINGCHANGED;
    procedure WMDemoApplyLayout(var AMessage: TMessage); message WM_DEMO_APPLY_LAYOUT;
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

procedure TForm1.BuildDemoNavigation;
const
  NavigationWidth = 208;
  NavigationPadding = 16;
  NavigationButtonHeight = 36;
  NavigationGutter = 8;
var
  I: Integer;
  LButton: TDACButton;
  LPage: TTabSheet;
begin
  if (csDesigning in ComponentState) or (FDemoNavigation <> nil) or
    (GalleryTabs = nil) then
    Exit;

  FDemoNavigation := TDACScrollContainer.Create(Self);
  FDemoNavigation.Name := 'demoNavigation';
  FDemoNavigation.Parent := Self;
  FDemoNavigation.Align := alNone;
  FDemoNavigation.Width := NavigationWidth;
  FDemoNavigation.AutoScroll := True;
  FDemoNavigation.BorderStyle := bsNone;
  FDemoNavigation.CornerRadius := 0;
  FDemoNavigation.ScrollBarMode := msbmVertical;
  FDemoNavigation.TabStop := True;

  FDemoNavigationTitle := TDACSystemText.Create(Self);
  FDemoNavigationTitle.Name := 'demoNavigationTitle';
  FDemoNavigationTitle.Parent := FDemoNavigation;
  FDemoNavigationTitle.SetBounds(NavigationPadding, NavigationPadding,
    NavigationWidth - (NavigationPadding * 2), 24);
  FDemoNavigationTitle.Text := 'Suite DAC';
  FDemoNavigationTitle.FontSize := 12;
  FDemoNavigationTitle.Bold := True;
  FDemoNavigationTitle.MaxLines := 1;

  SetLength(FDemoNavigationButtons, GalleryTabs.PageCount);
  for I := 0 to GalleryTabs.PageCount - 1 do
  begin
    LPage := GalleryTabs.Pages[I];
    LButton := TDACButton.Create(Self);
    LButton.Name := 'demoNav' + Copy(LPage.Name, 3, MaxInt);
    LButton.Parent := FDemoNavigation;
    LButton.SetBounds(NavigationPadding,
      52 + (I * (NavigationButtonHeight + NavigationGutter)),
      NavigationWidth - (NavigationPadding * 2), NavigationButtonHeight);
    LButton.Caption := LPage.Caption;
    LButton.Kind := mbkGhost;
    LButton.TabStop := True;
    LButton.Tag := I;
    LButton.OnClick := DemoNavigationClick;
    FDemoNavigationButtons[I] := LButton;
  end;
end;

procedure TForm1.ConfigureResponsiveButtons;
const
  HorizontalMargin = 24;
var
  LAvailableWidth: Integer;
  LContentTop: Integer;
  LMargin: Integer;
  LMonitor: TMonitor;
  LRuntimePPI: Integer;
  LSectionGap: Integer;
  LSectionLabelGap: Integer;
  LViewportRect: TRect;
  LViewportWidth: Integer;
  LVerticalSpacing: Integer;
  function LayoutLabel(const ALabel: TLabel; const ATop: Integer): Integer;
  var
    LTextRect: TRect;
    LTextHeight: Integer;
  begin
    ALabel.AutoSize := False;
    ALabel.WordWrap := True;
    ALabel.Canvas.Font.Assign(ALabel.Font);
    LTextRect := Rect(0, 0, LAvailableWidth, 0);
    LTextHeight := DrawText(ALabel.Canvas.Handle, PChar(ALabel.Caption),
      Length(ALabel.Caption), LTextRect, DT_CALCRECT or DT_WORDBREAK);
    LTextHeight := Max(ALabel.Canvas.TextHeight('Ag'), LTextHeight);
    ALabel.SetBounds(LMargin, ATop, LAvailableWidth, LTextHeight);
    Result := ATop + LTextHeight;
  end;
  function RequiredGridHeight(const AGrid: TDACGridContainer): Integer;
  var
    I: Integer;
    LChild: TControl;
    LChildBottom: Integer;
    LContentBottom: Integer;
    LGridContentTop: Integer;
  begin
    LGridContentTop := MaxInt;
    LContentBottom := 0;
    for I := 0 to AGrid.ControlCount - 1 do
    begin
      LChild := AGrid.Controls[I];
      if not LChild.Visible or (LChild is TSkPaintBox) then
        Continue;
      LGridContentTop := Min(LGridContentTop, LChild.Top);
      LChildBottom := LChild.Top + LChild.Height;
      LContentBottom := Max(LContentBottom, LChildBottom);
    end;
    if LGridContentTop = MaxInt then
      Exit(AGrid.Height);
    Result := Max(AGrid.RowHeight + (LGridContentTop * 2),
      LContentBottom + LGridContentTop);
  end;
  procedure LayoutSection(const ALabel: TLabel; const AGrid: TDACGridContainer;
    var ATop: Integer);
  begin
    ATop := LayoutLabel(ALabel, ATop);
    Inc(ATop, LSectionLabelGap);
    AGrid.SetBounds(LMargin, ATop, LAvailableWidth, AGrid.Height);
    AGrid.Realign;
    AGrid.Height := RequiredGridHeight(AGrid);
    Inc(ATop, AGrid.Height + LSectionGap);
  end;
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
  LVerticalSpacing := MulDiv(Round(TDACSpacingTokens.Default.S8),
    LRuntimePPI, 96);
  LSectionLabelGap := LVerticalSpacing;
  LSectionGap := MulDiv(Round(TDACSpacingTokens.Default.S24),
    LRuntimePPI, 96);
  LViewportWidth := LViewportRect.Right - LViewportRect.Left;
  // The scroll container is the only authoritative viewport after the tabs
  // and the runtime navigation have been laid out.  Do not cap this with a
  // form- or DPI-specific width: a resize must use every available pixel and
  // let each grid recompute its columns from that real client rectangle.
  LAvailableWidth := Max(0, LViewportWidth - (LMargin * 2));
  LContentTop := LayoutLabel(lblButtonsTitle, LMargin);
  Inc(LContentTop, LVerticalSpacing);
  LContentTop := LayoutLabel(lblButtonsSubtitle, LContentTop);
  Inc(LContentTop, LSectionGap);
  LayoutSection(lblButtonKinds, gcButtonKinds, LContentTop);
  LayoutSection(lblButtonSizes, gcButtonSizes, LContentTop);
  LayoutSection(lblButtonIcons, gcButtonIcons, LContentTop);
  LayoutSection(lblButtonStates, gcButtonStates, LContentTop);
  LayoutSection(lblButtonSpecials, gcButtonSpecials, LContentTop);
end;

procedure TForm1.ConfigureDemoLayout;
const
  NavigationWidth = 208;
var
  LNavigationWidth: Integer;
begin
  if (csDesigning in ComponentState) or (FDemoNavigation = nil) or
    (GalleryTabs = nil) then
    Exit;
  FDemoNavigation.Visible := NavigationCanRemainExpanded;
  if FDemoNavigation.Visible then
    LNavigationWidth := NavigationWidth
  else
    LNavigationWidth := 0;
  FDemoNavigation.SetBounds(0, 0, LNavigationWidth, ClientHeight);
  GalleryTabs.Align := alNone;
  GalleryTabs.SetBounds(LNavigationWidth, 0,
    Max(0, ClientWidth - LNavigationWidth), ClientHeight);
end;

procedure TForm1.CMShowingChanged(var AMessage: TMessage);
begin
  inherited;
  FitToWorkArea;
  ConfigureDemoLayout;
  ConfigureResponsiveButtons;
  PostMessage(Handle, WM_DEMO_APPLY_LAYOUT, 0, 0);
end;

procedure TForm1.CreateWnd;
begin
  inherited;
  if csDesigning in ComponentState then
    Exit;
  ConfigureDemoLayout;
  ConfigureResponsiveButtons;
  if HandleAllocated then
    PostMessage(Handle, WM_DEMO_APPLY_LAYOUT, 0, 0);
end;

procedure TForm1.DemoNavigationClick(Sender: TObject);
var
  LButton: TDACButton;
begin
  if not (Sender is TDACButton) or (GalleryTabs = nil) then
    Exit;
  LButton := TDACButton(Sender);
  if (LButton.Tag < 0) or (LButton.Tag >= GalleryTabs.PageCount) then
    Exit;
  GalleryTabs.ActivePage := GalleryTabs.Pages[LButton.Tag];
  RefreshDemoNavigation;
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

procedure TForm1.GalleryTabsChange(Sender: TObject);
begin
  RefreshDemoNavigation;
end;

procedure TForm1.Loaded;
begin
  inherited;
  BuildDemoNavigation;
  if GalleryTabs <> nil then
    GalleryTabs.OnChange := GalleryTabsChange;
  RefreshDemoNavigation;
  ConfigureDemoLayout;
  ConfigureResponsiveButtons;
end;

function TForm1.NavigationCanRemainExpanded: Boolean;
const
  NavigationWidth = 208;
  HorizontalMargin = 24;
var
  I: Integer;
  J: Integer;
  LButton: TDACButton;
  LGrid: TDACGridContainer;
  LMargin: Integer;
  LMonitor: TMonitor;
  LRequiredContentWidth: Integer;
  LRuntimePPI: Integer;
  LTitleWidth: Integer;
  LGrids: array[0..4] of TDACGridContainer;
begin
  if lblButtonsTitle = nil then
    Exit(True);
  LRuntimePPI := PixelsPerInch;
  LMonitor := Monitor;
  if LMonitor <> nil then
    LRuntimePPI := Max(96, LMonitor.PixelsPerInch);
  LMargin := MulDiv(HorizontalMargin, LRuntimePPI, 96);
  lblButtonsTitle.Canvas.Font.Assign(lblButtonsTitle.Font);
  LTitleWidth := lblButtonsTitle.Canvas.TextWidth(lblButtonsTitle.Caption);
  LRequiredContentWidth := LTitleWidth;
  LGrids[0] := gcButtonKinds;
  LGrids[1] := gcButtonSizes;
  LGrids[2] := gcButtonIcons;
  LGrids[3] := gcButtonStates;
  LGrids[4] := gcButtonSpecials;
  for I := Low(LGrids) to High(LGrids) do
  begin
    LGrid := LGrids[I];
    if LGrid = nil then
      Continue;
    for J := 0 to LGrid.ControlCount - 1 do
      if LGrid.Controls[J] is TDACButton then
      begin
        LButton := TDACButton(LGrid.Controls[J]);
        if LButton.Visible then
          LRequiredContentWidth := Max(LRequiredContentWidth,
            LButton.MinimumContentWidth);
      end;
  end;
  Result := ClientWidth - NavigationWidth >=
    LRequiredContentWidth + (LMargin * 2);
end;

procedure TForm1.RefreshDemoNavigation;
var
  I: Integer;
begin
  if (GalleryTabs = nil) or (Length(FDemoNavigationButtons) <>
    GalleryTabs.PageCount) then
    Exit;
  for I := 0 to High(FDemoNavigationButtons) do
    if FDemoNavigationButtons[I] <> nil then
      if GalleryTabs.ActivePage = GalleryTabs.Pages[I] then
        FDemoNavigationButtons[I].Kind := mbkPrimary
      else
        FDemoNavigationButtons[I].Kind := mbkGhost;
end;

procedure TForm1.Resize;
begin
  inherited;
  if csDesigning in ComponentState then
    Exit;
  ConfigureDemoLayout;
  // Child pages receive their final client rectangles after this resize
  // notification. Apply the content reflow in a posted message so the value
  // measured from scrButtons is the physical, post-align viewport.
  if HandleAllocated then
    PostMessage(Handle, WM_DEMO_APPLY_LAYOUT, 0, 0);
end;

procedure TForm1.WMDemoApplyLayout(var AMessage: TMessage);
begin
  if (csDesigning in ComponentState) or not HandleAllocated then
    Exit;
  ConfigureDemoLayout;
  GalleryTabs.Realign;
  if GalleryTabs.ActivePage <> nil then
    GalleryTabs.ActivePage.Realign;
  scrButtons.Realign;
  ConfigureResponsiveButtons;
end;

end.
