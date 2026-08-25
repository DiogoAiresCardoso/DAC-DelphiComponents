program DACComponentsInteraction;

{$APPTYPE CONSOLE}
{$MINSTACKSIZE $00200000}

uses
  System.Classes,
  System.DateUtils,
  System.IOUtils,
  System.Math,
  System.Skia,
  System.StrUtils,
  System.SysUtils,
  System.TypInfo,
  System.Types,
  System.UITypes,
  Data.DB,
  Datasnap.DBClient,
  Winapi.Imm,
  Winapi.Messages,
  Winapi.MultiMon,
  Winapi.UxTheme,
  Winapi.Windows,
  Vcl.ComCtrls,
  Vcl.Clipbrd,
  Vcl.Controls,
  Vcl.DBGrids,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.Graphics,
  Vcl.Mask,
  Vcl.Skia,
  Vcl.StdCtrls,
  Vcl.Themes,
  DAC.Components.Controls.Badges in '..\Source\Controls\DAC.Components.Controls.Badges.pas',
  DAC.Components.Controls.Button in '..\Source\Controls\DAC.Components.Controls.Button.pas',
  DAC.Components.Controls.Charts in '..\Source\Controls\DAC.Components.Controls.Charts.pas',
  DAC.Components.Controls.Container in '..\Source\Controls\DAC.Components.Controls.Container.pas',
  DAC.Components.Controls.DataAware in '..\Source\Controls\DataAware\DAC.Components.Controls.DataAware.pas',
  DAC.Components.Controls.DataAware.Lookup in '..\Source\Controls\DataAware\DAC.Components.Controls.DataAware.Lookup.pas',
  DAC.Components.Controls.DataAware.Navigator in '..\Source\Controls\DataAware\DAC.Components.Controls.DataAware.Navigator.pas',
  DAC.Components.Controls.DataGrid in '..\Source\Controls\DAC.Components.Controls.DataGrid.pas',
  DAC.Components.Controls.DateTimePicker in '..\Source\Controls\DAC.Components.Controls.DateTimePicker.pas',
  DAC.Components.Controls.DateTimePickerPopup in '..\Source\Controls\DAC.Components.Controls.DateTimePickerPopup.pas',
  DAC.Components.Controls.Edit in '..\Source\Controls\DAC.Components.Controls.Edit.pas',
  DAC.Components.Controls.FieldSupport in '..\Source\Controls\DAC.Components.Controls.FieldSupport.pas',
  DAC.Components.Controls.ButtonEdit in '..\Source\Controls\DAC.Components.Controls.ButtonEdit.pas',
  DAC.Components.Controls.ComboBox in '..\Source\Controls\DAC.Components.Controls.ComboBox.pas',
  DAC.Components.Controls.Feedback in '..\Source\Controls\DAC.Components.Controls.Feedback.pas',
  DAC.Components.Controls.GridContainer in '..\Source\Controls\DAC.Components.Controls.GridContainer.pas',
  DAC.Components.Controls.Loading in '..\Source\Controls\DAC.Components.Controls.Loading.pas',
  DAC.Components.Controls.Memo in '..\Source\Controls\DAC.Components.Controls.Memo.pas',
  DAC.Components.Controls.NativeWindowTheme in '..\Source\Controls\DAC.Components.Controls.NativeWindowTheme.pas',
  DAC.Components.Controls.Pagination in '..\Source\Controls\DAC.Components.Controls.Pagination.pas',
  DAC.Components.Controls.Progress in '..\Source\Controls\DAC.Components.Controls.Progress.pas',
  DAC.Components.Controls.ReportViewer in '..\Source\Controls\DAC.Components.Controls.ReportViewer.pas',
  DAC.Components.Controls.Selectors in '..\Source\Controls\DAC.Components.Controls.Selectors.pas',
  DAC.Components.Controls.SkiaControl in '..\Source\Controls\DAC.Components.Controls.SkiaControl.pas',
  DAC.Components.Controls.ScrollContainer in '..\Source\Controls\DAC.Components.Controls.ScrollContainer.pas',
  DAC.Components.Controls.StatusBar in '..\Source\Controls\DAC.Components.Controls.StatusBar.pas',
  DAC.Components.Controls.StatusTimelineChart in '..\Source\Controls\DAC.Components.Controls.StatusTimelineChart.pas',
  DAC.Components.Controls.SummaryCard in '..\Source\Controls\DAC.Components.Controls.SummaryCard.pas',
  DAC.Components.Controls.SystemText in '..\Source\Controls\DAC.Components.Controls.SystemText.pas',
  DAC.Components.Controls.Tabs in '..\Source\Controls\DAC.Components.Controls.Tabs.pas',
  DAC.Components.DesignSystem.ChartPalette in '..\Source\DesignSystem\DAC.Components.DesignSystem.ChartPalette.pas',
  DAC.Components.DesignSystem.ColorTokens in '..\Source\DesignSystem\DAC.Components.DesignSystem.ColorTokens.pas',
  DAC.Components.DesignSystem.ComponentStyle in '..\Source\DesignSystem\DAC.Components.DesignSystem.ComponentStyle.pas',
  DAC.Components.DesignSystem.ControlTokens in '..\Source\DesignSystem\DAC.Components.DesignSystem.ControlTokens.pas',
  DAC.Components.DesignSystem.DemoTokens in '..\Source\DesignSystem\DAC.Components.DesignSystem.DemoTokens.pas',
  DAC.Components.DesignSystem.Fonts in '..\Source\DesignSystem\DAC.Components.DesignSystem.Fonts.pas',
  DAC.Components.DesignSystem.IconAssets in '..\Source\DesignSystem\DAC.Components.DesignSystem.IconAssets.pas',
  DAC.Components.DesignSystem.Metrics in '..\Source\DesignSystem\DAC.Components.DesignSystem.Metrics.pas',
  DAC.Components.DesignSystem.OpacityTokens in '..\Source\DesignSystem\DAC.Components.DesignSystem.OpacityTokens.pas',
  DAC.Components.DesignSystem.SemanticColors in '..\Source\DesignSystem\DAC.Components.DesignSystem.SemanticColors.pas',
  DAC.Components.DesignSystem.Tokens in '..\Source\DesignSystem\DAC.Components.DesignSystem.Tokens.pas',
  DAC.Components.DesignSystem.Theme in '..\Source\DesignSystem\DAC.Components.DesignSystem.Theme.pas',
  DAC.Components.Hooks.Register in '..\Source\Hooks\DAC.Components.Hooks.Register.pas',
  DAC.Components.Hooks.ScrollRenderer in '..\Source\Hooks\DAC.Components.Hooks.ScrollRenderer.pas',
  DAC.Components.Hooks.ScrollContainer in '..\Source\Hooks\DAC.Components.Hooks.ScrollContainer.pas',
  Demo.Principal in '..\demo\Demo.Principal.pas' {Form1};

type
  EDataGridGateInjectedFailure = class(Exception);
  EScrollHookAuthorityProbeFailure = class(Exception);

  TDataGridGateFailureStage = (
    dgfsNone,
    dgfsBeforePageSwitch,
    dgfsAfterPageSwitch,
    dgfsBeforeObserverInstall,
    dgfsAfterObserverInstall,
    dgfsBeforeHookConstruction,
    dgfsAfterHookConstruction,
    dgfsConfiguration,
    dgfsObserverCallback,
    dgfsReentrantCallback);

var
  UnexpectedException: string;
  ClickCount: Integer;
  ScrollHookTarget: HWND;
  ScrollHookHorizontalPaint: TDACScrollHookPaintInfo;
  ScrollHookVerticalPaint: TDACScrollHookPaintInfo;
  ScrollHookHorizontalPaintCount: Integer;
  ScrollHookVerticalPaintCount: Integer;
  ScrollHookStyleHookPaintCount: Integer;
  ScrollHookFallbackPaintCount: Integer;
  ScrollHookRepaintAttempted: Boolean;
  ScrollHookRepaintOnNextNotification: Boolean;
  ScrollHookSynchronousRepaint: TProc;
  DataGridGateFailureStage: TDataGridGateFailureStage;
  DataGridGateFailureRaised: Boolean;
  MemoWheelQueryMode: Integer;
  CaptureDiagnosticLines: TStringList;
  CaptureDiagnosticPoints: array[0..3] of TPoint;
  CaptureDiagnosticPointNames: array[0..3] of string;

function CaptureRectText(const ARect: TRect): string;
begin
  Result := Format('[%d,%d,%d,%d w=%d h=%d]', [ARect.Left, ARect.Top,
    ARect.Right, ARect.Bottom, ARect.Width, ARect.Height]);
end;

function CapturePointText(const APoint: TPoint): string;
begin
  Result := Format('[%d,%d]', [APoint.X, APoint.Y]);
end;

function CaptureWindowClass(const AWindow: HWND): string;
var
  LBuffer: array[0..255] of Char;
begin
  FillChar(LBuffer, SizeOf(LBuffer), 0);
  Winapi.Windows.GetClassName(AWindow, LBuffer, Length(LBuffer));
  Result := LBuffer;
end;

procedure AppendCaptureWindowDiagnostic(const AWindow: HWND;
  const ARole: string);
var
  LClientOrigin: TPoint;
  LClientRect: TRect;
  LClipBox: TRect;
  LControl: TWinControl;
  LDC: HDC;
  LDCOrigin: TPoint;
  LOwnerName: string;
  LPixel: COLORREF;
  LPointDC: TPoint;
  LViewportOrigin: TPoint;
  LWindowOrigin: TPoint;
  LWindowRect: TRect;
  I: Integer;
begin
  if (CaptureDiagnosticLines = nil) or (AWindow = 0) then
    Exit;
  GetWindowRect(AWindow, LWindowRect);
  GetClientRect(AWindow, LClientRect);
  LClientOrigin := Point(0, 0);
  ClientToScreen(AWindow, LClientOrigin);
  LControl := FindControl(AWindow);
  if LControl <> nil then
  begin
    if LControl.Owner <> nil then
      LOwnerName := LControl.Owner.ClassName + ':' + LControl.Owner.Name
    else
      LOwnerName := 'nil';
    CaptureDiagnosticLines.Add(Format(
      'WINDOW role=%s hwnd=%p class=%s vcl=%s:%s parent=%p owner=%p ' +
      'root=%p rootowner=%p component_owner=%s style=0x%s exstyle=0x%s ' +
      'window=%s client=%s client_origin_screen=%s',
      [ARole, Pointer(AWindow), CaptureWindowClass(AWindow),
       LControl.ClassName, LControl.Name, Pointer(GetParent(AWindow)),
       Pointer(GetWindow(AWindow, GW_OWNER)),
       Pointer(GetAncestor(AWindow, GA_ROOT)),
       Pointer(GetAncestor(AWindow, GA_ROOTOWNER)), LOwnerName,
       IntToHex(Cardinal(GetWindowLong(AWindow, GWL_STYLE)), 8),
       IntToHex(Cardinal(GetWindowLong(AWindow, GWL_EXSTYLE)), 8),
       CaptureRectText(LWindowRect), CaptureRectText(LClientRect),
       CapturePointText(LClientOrigin)]));
  end
  else
    CaptureDiagnosticLines.Add(Format(
      'WINDOW role=%s hwnd=%p class=%s vcl=nil parent=%p owner=%p root=%p ' +
      'rootowner=%p style=0x%s exstyle=0x%s window=%s client=%s ' +
      'client_origin_screen=%s',
      [ARole, Pointer(AWindow), CaptureWindowClass(AWindow),
       Pointer(GetParent(AWindow)), Pointer(GetWindow(AWindow, GW_OWNER)),
       Pointer(GetAncestor(AWindow, GA_ROOT)),
       Pointer(GetAncestor(AWindow, GA_ROOTOWNER)),
       IntToHex(Cardinal(GetWindowLong(AWindow, GWL_STYLE)), 8),
       IntToHex(Cardinal(GetWindowLong(AWindow, GWL_EXSTYLE)), 8),
       CaptureRectText(LWindowRect), CaptureRectText(LClientRect),
       CapturePointText(LClientOrigin)]));
  LDC := GetWindowDC(AWindow);
  if LDC = 0 then
  begin
    CaptureDiagnosticLines.Add('DC role=' + ARole + ' result=NULL');
    Exit;
  end;
  try
    FillChar(LClipBox, SizeOf(LClipBox), 0);
    FillChar(LDCOrigin, SizeOf(LDCOrigin), 0);
    FillChar(LWindowOrigin, SizeOf(LWindowOrigin), 0);
    FillChar(LViewportOrigin, SizeOf(LViewportOrigin), 0);
    GetClipBox(LDC, LClipBox);
    GetDCOrgEx(LDC, LDCOrigin);
    GetWindowOrgEx(LDC, LWindowOrigin);
    GetViewportOrgEx(LDC, LViewportOrigin);
    CaptureDiagnosticLines.Add(Format(
      'DC role=%s clip_type=%d clip=%s dc_origin_screen=%s ' +
      'window_origin=%s viewport_origin=%s', [ARole, GetClipBox(LDC,
      LClipBox), CaptureRectText(LClipBox), CapturePointText(LDCOrigin),
      CapturePointText(LWindowOrigin), CapturePointText(LViewportOrigin)]));
    for I := Low(CaptureDiagnosticPoints) to High(CaptureDiagnosticPoints) do
    begin
      LPointDC := Point(CaptureDiagnosticPoints[I].X - LDCOrigin.X,
        CaptureDiagnosticPoints[I].Y - LDCOrigin.Y);
      LPixel := GetPixel(LDC, LPointDC.X, LPointDC.Y);
      CaptureDiagnosticLines.Add(Format(
        'SAMPLE role=%s part=%s screen=%s dc=%s point_owner=%p ' +
        'point_owner_class=%s ptvisible=%d pixel=0x%s clr_invalid=%d',
        [ARole, CaptureDiagnosticPointNames[I],
         CapturePointText(CaptureDiagnosticPoints[I]),
         CapturePointText(LPointDC),
         Pointer(WindowFromPoint(CaptureDiagnosticPoints[I])),
         CaptureWindowClass(WindowFromPoint(CaptureDiagnosticPoints[I])),
         Ord(PtVisible(LDC, LPointDC.X, LPointDC.Y)),
         IntToHex(Cardinal(LPixel), 8), Ord(LPixel = CLR_INVALID)]));
    end;
  finally
    ReleaseDC(AWindow, LDC);
  end;
end;

function EnumCaptureScrollWindows(const AWindow: HWND;
  const AParam: LPARAM): BOOL; stdcall;
begin
  Result := True;
  if ContainsText(CaptureWindowClass(AWindow), 'ScrollWindow') then
    AppendCaptureWindowDiagnostic(AWindow, 'helper-TScrollWindow');
end;

function DataGridGateFailureStageName(
  const AStage: TDataGridGateFailureStage): string;
begin
  case AStage of
    dgfsNone:
      Result := 'none';
    dgfsBeforePageSwitch:
      Result := 'before-page-switch';
    dgfsAfterPageSwitch:
      Result := 'after-page-switch';
    dgfsBeforeObserverInstall:
      Result := 'before-observer-install';
    dgfsAfterObserverInstall:
      Result := 'after-observer-install';
    dgfsBeforeHookConstruction:
      Result := 'before-hook-construction';
    dgfsAfterHookConstruction:
      Result := 'after-hook-construction';
    dgfsConfiguration:
      Result := 'configuration';
    dgfsObserverCallback:
      Result := 'observer-callback';
    dgfsReentrantCallback:
      Result := 'reentrant-callback';
  else
    Result := 'unknown';
  end;
end;

procedure InjectDataGridGateFailure(
  const AStage: TDataGridGateFailureStage);
begin
  if (AStage <> dgfsNone) and
    (DataGridGateFailureStage = AStage) and
    not DataGridGateFailureRaised then
  begin
    DataGridGateFailureRaised := True;
    raise EDataGridGateInjectedFailure.Create(
      'MEM-DEL-DB-037 injected failure: ' +
      DataGridGateFailureStageName(AStage));
  end;
end;

function QueryMemoWheelScrollLinesForTests(
  out AScrollLines: Cardinal): Boolean;
begin
  case MemoWheelQueryMode of
    1:
      begin
        AScrollLines := 999;
        Result := False;
      end;
    2:
      begin
        AScrollLines := 0;
        Result := True;
      end;
    3:
      begin
        AScrollLines := WHEEL_PAGESCROLL;
        Result := True;
      end;
    4:
      begin
        AScrollLines := 101;
        Result := True;
      end;
  else
    AScrollLines := 3;
    Result := True;
  end;
end;

procedure CaptureScrollHookPaint(const AInfo: TDACScrollHookPaintInfo);
begin
  if (ScrollHookTarget = 0) or
    (AInfo.ControlHandle <> ScrollHookTarget) then
    Exit;
  if AInfo.Source = spsStyleHook then
    Inc(ScrollHookStyleHookPaintCount)
  else
    Inc(ScrollHookFallbackPaintCount);
  if AInfo.Axis = shaVertical then
  begin
    ScrollHookVerticalPaint := AInfo;
    Inc(ScrollHookVerticalPaintCount);
  end
  else
  begin
    ScrollHookHorizontalPaint := AInfo;
    Inc(ScrollHookHorizontalPaintCount);
  end;
  InjectDataGridGateFailure(dgfsObserverCallback);
  if ScrollHookRepaintOnNextNotification and
    not ScrollHookRepaintAttempted and
    Assigned(ScrollHookSynchronousRepaint) then
  begin
    ScrollHookRepaintAttempted := True;
    ScrollHookSynchronousRepaint();
  end;
end;

function NativePrintWindow(const AWindow: HWND; const ADC: HDC;
  const AFlags: UINT): BOOL; stdcall; external 'user32.dll' name 'PrintWindow';

type
  TAdversarialSurfaceFlag = (asfZero, asfOne);

  TControlClickAccess = class(TControl);
  TMemoWheelAccess = class(TMemo);
  TWinControlSelectAccess = class(TWinControl);

  TDACInt64SurfaceProbe = class(TCustomControl)
  private
    FBackgroundColor: Int64;
  published
    property BackgroundColor: Int64 read FBackgroundColor write FBackgroundColor;
  end;

  TAdversarialEnumSurfaceProbe = class(TCustomControl)
  private
    FParentColorFlag: TAdversarialSurfaceFlag;
    FTransparentFlag: TAdversarialSurfaceFlag;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Color;
    property ParentColor: TAdversarialSurfaceFlag read FParentColorFlag
      write FParentColorFlag;
    property Transparent: TAdversarialSurfaceFlag read FTransparentFlag
      write FTransparentFlag;
  end;

  TShowingCountEdit = class(TEdit)
  private
    FShowingChangeCount: Integer;
    procedure CMShowingChanged(var AMessage: TMessage);
      message CM_SHOWINGCHANGED;
  public
    procedure ResetShowingChangeCount;
    property ShowingChangeCount: Integer read FShowingChangeCount;
  end;

  TShowingMutationHost = class(TCustomControl)
  private
    FArmed: Boolean;
    FDestroyCompleted: Boolean;
    FDestroyTarget: TWinControl;
    FMutationCount: Integer;
    FNewParent: TWinControl;
    FReparentCompleted: Boolean;
    FReparentTarget: TWinControl;
    procedure CMShowingChanged(var AMessage: TMessage);
      message CM_SHOWINGCHANGED;
  public
    procedure Arm(const ADestroyTarget, AReparentTarget,
      ANewParent: TWinControl);
    property DestroyCompleted: Boolean read FDestroyCompleted;
    property MutationCount: Integer read FMutationCount;
    property ReparentCompleted: Boolean read FReparentCompleted;
  end;

  TDACTabsAccess = class(TDACTabs)
  public
    procedure SimulateKeyDown(const AKey: Word; const AShift: TShiftState);
    procedure SimulateCtrlTab;
  end;

  TInteractionProbe = class
  public
    ActionCount: Integer;
    ComboCloseCount: Integer;
    ComboDropDownCount: Integer;
    ComboReenter: Boolean;
    GridClickCount: Integer;
    GridDoubleClickCount: Integer;
    GridCellClickCount: Integer;
    LastAction: TDACDataGridActionKind;
    LastActionColumn: TColumn;
    procedure OnApplicationException(Sender: TObject; E: Exception);
    procedure OnDataGridAction(Sender: TObject; AAction: TDACDataGridActionKind;
      AColumn: TColumn);
    procedure OnButtonClick(Sender: TObject);
    procedure OnComboCloseUp(Sender: TObject);
    procedure OnComboDropDown(Sender: TObject);
    procedure OnGridClick(Sender: TObject);
    procedure OnGridDoubleClick(Sender: TObject);
    procedure OnGridCellClick(Column: TColumn);
  end;

procedure Require(const ACondition: Boolean; const AMessage: string); forward;
function CountText(const AText, APart: string): Integer; forward;

constructor TAdversarialEnumSurfaceProbe.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ParentBackground := False;
  FParentColorFlag := asfOne;
  FTransparentFlag := asfOne;
end;

procedure TShowingCountEdit.CMShowingChanged(var AMessage: TMessage);
begin
  inherited;
  Inc(FShowingChangeCount);
end;

procedure TDACTabsAccess.SimulateKeyDown(const AKey: Word;
  const AShift: TShiftState);
var
  LKey: Word;
begin
  LKey := AKey;
  KeyDown(LKey, AShift);
end;

procedure TDACTabsAccess.SimulateCtrlTab;
begin
  SimulateKeyDown(VK_TAB, [ssCtrl]);
end;

procedure TShowingCountEdit.ResetShowingChangeCount;
begin
  FShowingChangeCount := 0;
end;

procedure TShowingMutationHost.Arm(const ADestroyTarget, AReparentTarget,
  ANewParent: TWinControl);
begin
  FDestroyTarget := ADestroyTarget;
  FReparentTarget := AReparentTarget;
  FNewParent := ANewParent;
  FDestroyCompleted := False;
  FReparentCompleted := False;
  FMutationCount := 0;
  FArmed := True;
end;

procedure TShowingMutationHost.CMShowingChanged(var AMessage: TMessage);
var
  LDestroyTarget: TWinControl;
  LNewParent: TWinControl;
  LReparentTarget: TWinControl;
begin
  inherited;
  if not FArmed or Showing then
    Exit;
  FArmed := False;
  Inc(FMutationCount);
  LDestroyTarget := FDestroyTarget;
  FDestroyTarget := nil;
  if LDestroyTarget <> nil then
  begin
    LDestroyTarget.Free;
    FDestroyCompleted := True;
  end;
  LReparentTarget := FReparentTarget;
  LNewParent := FNewParent;
  FReparentTarget := nil;
  FNewParent := nil;
  if (LReparentTarget <> nil) and (LNewParent <> nil) then
  begin
    LReparentTarget.Parent := LNewParent;
    FReparentCompleted := True;
  end;
end;

procedure RequireAdversarialSurfaceRTTI(const AParent: TWinControl);
var
  LColor: TColor;
  LEnumProbe: TAdversarialEnumSurfaceProbe;
  LInt64Probe: TDACInt64SurfaceProbe;
  LMode: TDACThemeMode;
begin
  LInt64Probe := TDACInt64SurfaceProbe.Create(nil);
  LEnumProbe := TAdversarialEnumSurfaceProbe.Create(nil);
  try
    LInt64Probe.BackgroundColor := Int64($00000000FFF8FAF8);
    Require(TDACComponentStyle.TryResolveSurface(LInt64Probe, LMode, LColor) and
      (LMode = dtmLight) and
      (LColor = TDACComponentColors.ToVclColor(TAlphaColor($FFF8FAF8))),
      'BackgroundColor Int64 valido foi truncado ou classificado incorretamente.');
    LInt64Probe.BackgroundColor := Int64($00000001FFF8FAF8);
    Require(not TDACComponentStyle.TryResolveSurface(LInt64Probe, LMode, LColor),
      'BackgroundColor Int64 acima de 32 bits foi truncado silenciosamente.');

    LEnumProbe.Parent := AParent;
    LEnumProbe.Color := RGB($F8, $FA, $F8);
    Require(TDACComponentStyle.TryResolveSurface(LEnumProbe, LMode, LColor) and
      (LMode = dtmLight),
      'Enum valor 1 foi aceito indevidamente como Boolean de surface.');
  finally
    LEnumProbe.Free;
    LInt64Probe.Free;
  end;
end;

type
  TFormAccess = class(TForm)
  public
    procedure FocusNext(const AControl: TWinControl);
  end;

  TTabSheetAccess = class(TTabSheet)
  end;

  TTabsColorAccess = class(TDACTabs)
  end;

  TScrollContainerColorAccess = class(TDACScrollContainer)
  end;

  TNativeControlAccess = class(TControl)
  end;

  TScrollHookAccess = class(TDACScrollContainerStyleHook)
  public
    function EndButtonStateForAxis(
      const AVertical: Boolean): TThemedScrollBar;
    function InternalPreviousScrollPosition: Integer;
    function InternalScrollPosition: Single;
    function SliderStateForAxis(
      const AVertical: Boolean): TThemedScrollBar;
    function StartButtonStateForAxis(
      const AVertical: Boolean): TThemedScrollBar;
    function VerticalTrackHeight: Integer;
    function HorizontalTrackWidth: Integer;
    procedure SeedMouseDragDelta(const AVertical: Boolean;
      const ADelta: Integer);
    procedure PaintAxisNonClient(const AVertical: Boolean);
    procedure PaintNonClient;
    function ProcessHookMessage(const AMsg: Cardinal;
      const AWParam: WPARAM; const ALParam: LPARAM): LRESULT;
  end;

  TDataGridScrollHookAccess = class(TDACDataGridStyleHook)
  public
    function HorizontalTrackWidth: Integer;
    procedure PaintAxisNonClient(const AVertical: Boolean);
    function ProcessHookMessage(const AMsg: Cardinal;
      const AWParam: WPARAM; const ALParam: LPARAM): LRESULT;
    procedure SeedAxisStates(const AVertical: Boolean;
      const ASliderState, AStartState, AEndState: TThemedScrollBar);
    procedure SeedMouseDragDelta(const AVertical: Boolean;
      const ADelta: Integer);
    function VerticalTrackHeight: Integer;
  end;

  TFailingScrollHookAccess = class(TScrollHookAccess)
  public
    constructor Create(AControl: TWinControl); override;
  end;

  TFailingDataGridScrollHookAccess = class(TDataGridScrollHookAccess)
  public
    constructor Create(AControl: TWinControl); override;
  end;

  TStyleEngineAccess = class(TCustomStyleEngine)
  public
    class function HasExactStyleHook(const AControlClass: TClass;
      const AStyleHookClass: TStyleHookClass): Boolean; static;
  end;

  TGridContainerColorAccess = class(TDACGridContainer)
  end;

  TContainerColorAccess = class(TDACContainer)
  end;

  TButtonAccess = class(TDACButton)
  public
    procedure SimulateMouseMove(const X, Y: Integer);
    procedure SimulateMouseDown(const X, Y: Integer);
    procedure SimulateMouseUp(const X, Y: Integer);
  end;

  TDesignSystemTextAccess = class(TDACSystemText)
  public
    procedure SimulateDesignerLoaded;
  end;

  TDesignButtonAccess = class(TDACButton)
  public
    procedure SimulateDesignerLoaded;
  end;

  TDesignGridAccess = class(TDACGridContainer)
  public
    procedure SimulateDesignerLoaded;
  end;

  TDesignScrollAccess = class(TDACScrollContainer)
  public
    procedure SimulateDesignerLoaded;
  end;

  TDataGridHandleAccess = class(TDACDataGrid)
  public
    procedure RecreateNativeHandle;
    function GridBufferedRecordCount: Integer;
    function GridColumn: Integer;
    function GridCellRect(const ACol, ARow: Integer): TRect;
    function GridActionRect(const ACellRect: TRect;
      const AAction: TDACDataGridActionKind): TRect;
    function GridDefaultRowHeight: Integer;
    function GridFixedRows: Integer;
    function GridHeaderHeight: Integer;
    function GridLeftColumn: Integer;
    procedure SetGridLeftColumn(const AValue: Integer);
    function GridAcceptsDataCellRect(const ARect: TRect;
      const AViewportWidth, ADataTop, ADataBottom: Integer): Boolean;
    procedure GridGuardDataChromeRect(const ARect: TRectF;
      const ADataTop, ADataBottom: Single);
    function GridTryHitAction(const X, Y: Integer; out AColumn: TColumn;
      out AAction: TDACDataGridActionKind): Boolean;
    function GridRow: Integer;
    function GridTopRow: Integer;
    function GridEditorMode: Boolean;
    function GridEditorFocused: Boolean;
    function GridEditorVisible: Boolean;
    procedure GridEditorChar(const AChar: Char);
    procedure SetGridEvents(const AClick, ADoubleClick: TNotifyEvent;
      const ACellClick: TDBGridClickEvent);
  end;

  TDataGridPaintBoxAccess = class(TDACDataGridPaintBox)
  public
    procedure SimulateClick(const X, Y: Integer);
    function SimulateMouseWheel(const AWheelDelta: Integer): Boolean;
    function SimulateMouseWheelAt(const AWheelDelta, X, Y: Integer): Boolean;
  end;

  TThemeSkiaControl = class(TDACSkiaControl)
  private
    FDrawCount: Integer;
    FLastDrawBackground: TAlphaColor;
  protected
    procedure DrawContent(const ACanvas: ISkCanvas; const ADest: TRectF); override;
  public
    property DrawCount: Integer read FDrawCount;
    property LastDrawBackground: TAlphaColor read FLastDrawBackground;
  end;

procedure TThemeSkiaControl.DrawContent(const ACanvas: ISkCanvas;
  const ADest: TRectF);
begin
  Inc(FDrawCount);
  FLastDrawBackground := ResolvedTokens.ContainerSuiteBackground;
  inherited;
end;

procedure TDesignSystemTextAccess.SimulateDesignerLoaded;
begin
  SetDesigning(True);
  Loaded;
end;

procedure TDesignButtonAccess.SimulateDesignerLoaded;
begin
  SetDesigning(True);
  Loaded;
end;

procedure TDesignGridAccess.SimulateDesignerLoaded;
begin
  SetDesigning(True);
  Loaded;
end;

procedure TDesignScrollAccess.SimulateDesignerLoaded;
begin
  SetDesigning(True);
  Loaded;
end;

procedure TScrollHookAccess.PaintNonClient;
var
  LCanvas: TCanvas;
  LDC: HDC;
begin
  LDC := GetWindowDC(Control.Handle);
  Require(LDC <> 0, 'Nao foi possivel obter DC non-client para o StyleHook.');
  LCanvas := TCanvas.Create;
  try
    LCanvas.Handle := LDC;
    PaintNC(LCanvas);
    LCanvas.Handle := 0;
  finally
    LCanvas.Free;
    ReleaseDC(Control.Handle, LDC);
  end;
end;

procedure TScrollHookAccess.PaintAxisNonClient(const AVertical: Boolean);
var
  LDC: HDC;
begin
  LDC := GetWindowDC(Control.Handle);
  Require(LDC <> 0,
    'Nao foi possivel obter DC non-client para pintar um eixo do StyleHook.');
  try
    if AVertical then
      DrawVertScroll(LDC)
    else
      DrawHorzScroll(LDC);
  finally
    ReleaseDC(Control.Handle, LDC);
  end;
end;

function TScrollHookAccess.EndButtonStateForAxis(
  const AVertical: Boolean): TThemedScrollBar;
begin
  if AVertical then
    Result := VertDownState
  else
    Result := HorzDownState;
end;

function TScrollHookAccess.InternalPreviousScrollPosition: Integer;
begin
  Result := PrevScrollPos;
end;

function TScrollHookAccess.InternalScrollPosition: Single;
begin
  Result := ScrollPos;
end;

function TScrollHookAccess.SliderStateForAxis(
  const AVertical: Boolean): TThemedScrollBar;
begin
  if AVertical then
    Result := VertSliderState
  else
    Result := HorzSliderState;
end;

function TScrollHookAccess.StartButtonStateForAxis(
  const AVertical: Boolean): TThemedScrollBar;
begin
  if AVertical then
    Result := VertUpState
  else
    Result := HorzUpState;
end;

function TScrollHookAccess.VerticalTrackHeight: Integer;
begin
  Result := VertTrackRect.Height;
end;

function TScrollHookAccess.HorizontalTrackWidth: Integer;
begin
  Result := HorzTrackRect.Width;
end;

procedure TScrollHookAccess.SeedMouseDragDelta(const AVertical: Boolean;
  const ADelta: Integer);
begin
  if AVertical then
    PrevScrollPos := Mouse.CursorPos.Y - ADelta
  else
    PrevScrollPos := Mouse.CursorPos.X - ADelta;
end;

function TScrollHookAccess.ProcessHookMessage(const AMsg: Cardinal;
  const AWParam: WPARAM; const ALParam: LPARAM): LRESULT;
var
  LMessage: TMessage;
begin
  FillChar(LMessage, SizeOf(LMessage), 0);
  LMessage.Msg := AMsg;
  LMessage.WParam := AWParam;
  LMessage.LParam := ALParam;
  // TCustomStyleEngine resets this flag before dispatching every message.
  // The explicit test driver must reproduce that lifecycle, otherwise a
  // handled WM_NCLBUTTONDOWN suppresses the following WM_MOUSEMOVE.
  Handled := False;
  WndProc(LMessage);
  Result := LMessage.Result;
end;

procedure Require(const ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create(AMessage);
end;

function CountMaskEditDescendants(const AParent: TWinControl): Integer;
var
  I: Integer;
  LControl: TControl;
begin
  Result := 0;
  if AParent = nil then
    Exit;
  for I := 0 to AParent.ControlCount - 1 do
  begin
    LControl := AParent.Controls[I];
    if LControl is TMaskEdit then
      Inc(Result);
    if LControl is TWinControl then
      Inc(Result, CountMaskEditDescendants(TWinControl(LControl)));
  end;
end;

procedure RequireButtonEditNativeSeparation(
  const AButtonEdit: TDACButtonEdit; const AContext: string);
var
  LButtonScreen: TPoint;
  LEditScreenRight: TPoint;
begin
  Require((AButtonEdit <> nil) and
    (AButtonEdit.EditControl <> nil) and
    (AButtonEdit.ButtonControl <> nil),
    AContext + ': ButtonEdit incompleto.');
  LEditScreenRight := AButtonEdit.EditControl.ClientToScreen(
    Point(AButtonEdit.EditControl.ClientWidth, 0));
  LButtonScreen := AButtonEdit.ButtonControl.ClientToScreen(Point(0, 0));
  Require((AButtonEdit.EditControl.BoundsRect.Right <=
      AButtonEdit.ButtonControl.Left) and
    (LEditScreenRight.X <= LButtonScreen.X),
    Format('%s: TMaskEdit invadiu a coluna da acao (clientRight=%d buttonLeft=%d screenRight=%d buttonScreenLeft=%d).',
      [AContext, AButtonEdit.EditControl.BoundsRect.Right,
       AButtonEdit.ButtonControl.Left, LEditScreenRight.X,
       LButtonScreen.X]));
  Require(CountMaskEditDescendants(AButtonEdit) = 1,
    AContext + ': ButtonEdit deve manter exatamente um TMaskEdit recursivo.');
end;

procedure RequireButtonEditActionSurface(const AButtonEdit: TDACButtonEdit;
  const AExpected: TAlphaColor; const AContext: string);
var
  LTokens: TDACControlTokens;
begin
  Require((AButtonEdit <> nil) and (AButtonEdit.ButtonControl <> nil) and
    AButtonEdit.ButtonControl.HandleAllocated,
    AContext + ': action HWND ausente.');
  Require(RedrawWindow(AButtonEdit.ButtonControl.Handle, nil, 0,
    RDW_INVALIDATE or RDW_ERASE or RDW_FRAME or RDW_ALLCHILDREN or
    RDW_UPDATENOW), AContext + ': repaint real da action falhou.');
  LTokens := TDACComponentStyle.ResolveForSurface(
    AButtonEdit.ButtonControl,
    AButtonEdit.ButtonControl.ThemeMode).Tokens.Controls;
  Require((AButtonEdit.ButtonControl.ResolvedCanvasBackgroundColor =
      AExpected) and
    ((AButtonEdit.ButtonControl.ResolvedCanvasBackgroundColor and
      TAlphaColor($FF000000)) = TAlphaColor($FF000000)),
    AContext + ': action nao limpou com a surface opaca efetiva do host.');
  Require(AButtonEdit.ButtonControl.ResolvedBackgroundColor =
    LTokens.ButtonTransparent,
    AContext + ': palette semantica da action deixou de ser transparente.');
  Require(AButtonEdit.ButtonControl.Perform(WM_ERASEBKGND, 0, 0) = 1,
    AContext + ': WM_ERASEBKGND da action nao retornou 1.');
end;

procedure RequireRuntimeClass(const AName: string;
  const AClass: TPersistentClass);
begin
  Require(GetClass(AName) = AClass,
    'Registry runtime nao disponibilizou ' + AName + ' para streaming DFM.');
end;

procedure RequireRuntimeDfmClasses;
begin
  RequireRuntimeClass('TDACBadge', TDACBadge);
  RequireRuntimeClass('TDACButton', TDACButton);
  RequireRuntimeClass('TDACButtonEdit', TDACButtonEdit);
  RequireRuntimeClass('TDACChart', TDACChart);
  RequireRuntimeClass('TDACCheckBox', TDACCheckBox);
  RequireRuntimeClass('TDACComboBox', TDACComboBox);
  RequireRuntimeClass('TDACContainer', TDACContainer);
  RequireRuntimeClass('TDACDataGrid', TDACDataGrid);
  RequireRuntimeClass('TDACDateTimePicker', TDACDateTimePicker);
  RequireRuntimeClass('TDACDBCheckBox', TDACDBCheckBox);
  RequireRuntimeClass('TDACDBButtonEdit', TDACDBButtonEdit);
  RequireRuntimeClass('TDACDBComboBox', TDACDBComboBox);
  RequireRuntimeClass('TDACDBDateTimePicker', TDACDBDateTimePicker);
  RequireRuntimeClass('TDACDBEdit', TDACDBEdit);
  RequireRuntimeClass('TDACDBLookupComboBox', TDACDBLookupComboBox);
  RequireRuntimeClass('TDACDBMemo', TDACDBMemo);
  RequireRuntimeClass('TDACDBNavigator', TDACDBNavigator);
  RequireRuntimeClass('TDACDBRadioButton', TDACDBRadioButton);
  RequireRuntimeClass('TDACDBSlider', TDACDBSlider);
  RequireRuntimeClass('TDACDBText', TDACDBText);
  RequireRuntimeClass('TDACDBToggleSwitch', TDACDBToggleSwitch);
  RequireRuntimeClass('TDACEdit', TDACEdit);
  RequireRuntimeClass('TDACGridContainer', TDACGridContainer);
  RequireRuntimeClass('TDACLoading', TDACLoading);
  RequireRuntimeClass('TDACMemo', TDACMemo);
  RequireRuntimeClass('TDACModalDialog', TDACModalDialog);
  RequireRuntimeClass('TDACPagination', TDACPagination);
  RequireRuntimeClass('TDACProgress', TDACProgress);
  RequireRuntimeClass('TDACRadioButton', TDACRadioButton);
  RequireRuntimeClass('TDACReportViewer', TDACReportViewer);
  RequireRuntimeClass('TDACScrollContainer', TDACScrollContainer);
  RequireRuntimeClass('TDACSelector', TDACSelector);
  RequireRuntimeClass('TDACSkiaControl', TDACSkiaControl);
  RequireRuntimeClass('TDACSlider', TDACSlider);
  RequireRuntimeClass('TDACStatusBar', TDACStatusBar);
  RequireRuntimeClass('TDACSummaryCard', TDACSummaryCard);
  RequireRuntimeClass('TDACSystemText', TDACSystemText);
  RequireRuntimeClass('TDACTabs', TDACTabs);
  RequireRuntimeClass('TDACToast', TDACToast);
  RequireRuntimeClass('TDACToggleSwitch', TDACToggleSwitch);
  RequireRuntimeClass('TDACTooltip', TDACTooltip);
end;

procedure RequireLoteCSemanticDfm;
const
  ForbiddenLines: array[0..17] of string = (
    'fontsize =', 'textcolor =', 'backgroundcolor =', 'bordercolor =',
    'accentcolor =', 'titlecolor =', 'subtitlecolor =', 'cornerradius =',
    'contentpadding =', 'gutter =', 'rowheight =', 'font.color =',
    'font.height =', 'font.name =', 'color = clwhite', 'density = dgdmedium',
    'status = mbssuccess', 'appearance = mscacustom');
var
  I: Integer;
  LLine: string;
  LLines: TStringList;
  LPath: string;
  LSource: string;
begin
  LPath := ExpandFileName(TPath.Combine(ExtractFilePath(ParamStr(0)),
    '..\..\..\..\..\demo\Demo.Principal.dfm'));
  Require(TFile.Exists(LPath), 'DFM da Demo ausente para auditoria do Lote C.');
  LSource := LowerCase(TFile.ReadAllText(LPath));
  LLines := TStringList.Create;
  try
    LLines.Text := LSource;
    for I := 0 to LLines.Count - 1 do
    begin
      LLine := Trim(LLines[I]);
      Require(not StartsText('font.style =', LLine),
        'DFM ainda possui Font.Style cru na linha ' + IntToStr(I + 1) + '.');
      Require(not StartsText('appearance = mgcacustom', LLine) and
        not StartsText('appearance = mcsacustom', LLine) and
        not StartsText('appearance = mchacustom', LLine) and
        not StartsText('layout = mgclcustom', LLine) and
        not StartsText('shape = mbshcustom', LLine) and
        not StartsText('role = mtrcustom', LLine) and
        not StartsText('tone = mttcustom', LLine),
        'DFM da Demo nao pode usar preset Custom na linha ' +
          IntToStr(I + 1) + '.');
      for LLine in ForbiddenLines do
        Require(not StartsText(LLine, Trim(LLines[I])),
          'DFM ainda possui propriedade visual crua: ' + LLine +
            ' (linha ' + IntToStr(I + 1) + ').');
    end;
  finally
    LLines.Free;
  end;
  Require((CountText(LSource, ': tdacsystemtext') >= 20) and
    (CountText(LSource, 'role = mtrdisplay') = 2),
    'Auditoria de componentes/roles semanticos da Demo divergiu.');
  Require((CountText(LSource, 'appearance = mcsadashboard') = 5) and
    (CountText(LSource, 'appearance = mcadarkcard') = 4) and
    (CountText(LSource, 'layout = mgclcompact') = 4) and
    (CountText(LSource, 'layout = mgcldense') = 1) and
    (CountText(LSource, 'layout = mgclactiontiles') = 1),
    'Presets semanticos esperados nao foram materializados no DFM.');
end;

function FindTabHeader(const ATabs: TDACTabs): TDACTabHeaderControl;
var
  I: Integer;
begin
  Result := nil;
  if (ATabs = nil) or (ATabs.Parent = nil) then
    Exit;
  for I := 0 to ATabs.Parent.ControlCount - 1 do
    if (ATabs.Parent.Controls[I] is TDACTabHeaderControl) and
      (ATabs.Parent.Controls[I].Owner = ATabs) then
      Exit(TDACTabHeaderControl(ATabs.Parent.Controls[I]));
end;

function FindTabHeaderPaintBox(const AHeader: TDACTabHeaderControl): TSkPaintBox;
var
  I: Integer;
begin
  Result := nil;
  if AHeader = nil then
    Exit;
  for I := 0 to AHeader.ControlCount - 1 do
    if AHeader.Controls[I] is TSkPaintBox then
      Exit(TSkPaintBox(AHeader.Controls[I]));
end;

procedure RequireFixedPixelMetrics;
const
  SourceFiles: array[0..14] of string = (
    'Source\\Controls\\DAC.Components.Controls.DataGrid.pas',
    'Source\\Controls\\DAC.Components.Controls.Edit.pas',
    'Source\\Controls\\DAC.Components.Controls.ComboBox.pas',
    'Source\\Controls\\DAC.Components.Controls.ButtonEdit.pas',
    'Source\\Controls\\DAC.Components.Controls.DateTimePicker.pas',
    'Source\\Controls\\DAC.Components.Controls.Tabs.pas',
    'Source\\DesignSystem\\DAC.Components.DesignSystem.ComponentStyle.pas',
    'Source\\Core\\DAC.Components.Types.pas',
    'Source\\Core\\DAC.Components.Geometry.pas',
    'demo\\Demo.Principal.pas',
    'demo\\Demo.dproj',
    'Package\\DACSkiaComponents.dpk',
    'Package\\DACSkiaComponents.dproj',
    'Tests\\DACComponentsSmoke.dpr',
    'Tests\\DACComponentsInteraction.dpr');
  Forbidden: array[0..9] of string = (
    'screen.' + 'pixelsperinch', 'scale' + 'factor', 'scale' + 'metric',
    'current' + 'ppi', 'mul' + 'div', 'change' + 'scale',
    'app' + 'enablehighdpi', 'dac.components.' + 'dpi', 'dac' + 'scale',
    'dpi' + 'awareness');
var
  I: Integer;
  J: Integer;
  LPath: string;
  LRoot: string;
  LSource: string;
begin
  LRoot := ExpandFileName(TPath.Combine(ExtractFilePath(ParamStr(0)),
    '..\\..\\..\\..\\..'));
  Require(not TFile.Exists(TPath.Combine(LRoot,
    'Source\\Core\\DAC.Components.' + 'Dpi.pas')),
    'Modulo DPI legado nao pode integrar a versao sem DPI.');
  for I := Low(SourceFiles) to High(SourceFiles) do
  begin
    LPath := TPath.Combine(LRoot, SourceFiles[I]);
    Require(TFile.Exists(LPath), 'Fonte ausente para a auditoria de metricas: ' + LPath);
    LSource := LowerCase(TFile.ReadAllText(LPath));
    for J := Low(Forbidden) to High(Forbidden) do
      Require(Pos(Forbidden[J], LSource) = 0,
        'API de DPI nao permitida nesta versao: ' + Forbidden[J] + ' em ' + SourceFiles[I]);
  end;
end;

procedure RequireFullGalleryThemeBoundarySources;
var
  LApplyPageStyle: string;
  LApplyPageStyleEnd: Integer;
  LApplyPageStyleStart: Integer;
  LConstructor: string;
  LConstructorEnd: Integer;
  LConstructorStart: Integer;
  LDemo: string;
  LDemoDfm: string;
  LHooks: string;
  LRoot: string;
  LTabs: string;
begin
  LRoot := ExpandFileName(TPath.Combine(ExtractFilePath(ParamStr(0)),
    '..\..\..\..\..'));
  LTabs := LowerCase(TFile.ReadAllText(TPath.Combine(LRoot,
    'Source\Controls\DAC.Components.Controls.Tabs.pas')));
  LDemo := LowerCase(TFile.ReadAllText(TPath.Combine(LRoot,
    'demo\Demo.Principal.pas')));
  LDemoDfm := LowerCase(TFile.ReadAllText(TPath.Combine(LRoot,
    'demo\Demo.Principal.dfm')));
  LHooks := LowerCase(TFile.ReadAllText(TPath.Combine(LRoot,
    'Source\Hooks\DAC.Components.Hooks.Register.pas')));
  LConstructorStart := Pos('constructor tdactabs.create(', LTabs);
  LConstructorEnd := PosEx('procedure tdactabs.doenter;', LTabs,
    LConstructorStart);
  LApplyPageStyleStart := Pos('procedure tdactabs.applypagestyle;', LTabs);
  LApplyPageStyleEnd := PosEx('procedure tdactabs.change;', LTabs,
    LApplyPageStyleStart);
  Require((LConstructorStart > 0) and
    (LConstructorEnd > LConstructorStart) and
    (LApplyPageStyleStart > 0) and
    (LApplyPageStyleEnd > LApplyPageStyleStart),
    'Nao foi possivel auditar o ciclo de estilo de TDACTabs.');
  LConstructor := Copy(LTabs, LConstructorStart,
    LConstructorEnd - LConstructorStart);
  LApplyPageStyle := Copy(LTabs, LApplyPageStyleStart,
    LApplyPageStyleEnd - LApplyPageStyleStart);
  Require((Pos('parentbackground := false;', LConstructor) > 0) and
    (Pos('styleelements := [];', LConstructor) > 0),
    'TDACTabs deve fixar sua fronteira VCL antes de qualquer HWND.');
  Require(Pos(sLineBreak + '  styleelements := [];' + sLineBreak,
    LApplyPageStyle) = 0,
    'ApplyPageStyle nao pode alterar StyleElements do TDACTabs com HWND ativo.');
  Require((Pos('if lruntimehostready then', LApplyPageStyle) > 0) and
    (Pos('tdactabsheetaccess(pages[i]).parentbackground := false;',
      LApplyPageStyle) > 0) and
    (Pos('tdactabsheetaccess(pages[i]).styleelements := [];',
      LApplyPageStyle) > 0),
    'StyleElements/ParentBackground das paginas devem aguardar host real.');
  Require(Pos('tdaccomponentstyle.resolve(dtmlight)', LTabs) = 0,
    'ApplyPageStyle nao pode resolver dtmLight fixo.');
  Require((Pos('applydashboardtheme', LDemo) = 0) and
    (Pos('refreshthemetree', LDemo) = 0) and
    (Pos('tdacthememanager.refreshlistener(gallerytabs)', LDemo) > 0),
    'Demo deve atualizar uma unica raiz GalleryTabs, sem excecao scrDashboard.');
  Require((Pos('procedure layoutinputs', LDemo) = 0) and
    (Pos('finputpreferredwidth', LDemo) = 0) and
    (Pos('fmemopreferredwidth', LDemo) = 0),
    'Inputs nao pode manter layout imperativo/FindComponent legado.');
  Require((Pos('object scrinputs: tdacscrollcontainer', LDemoDfm) > 0) and
    (Pos('object gcinputstates: tdacgridcontainer', LDemoDfm) > 0) and
    (Pos('autocontentheight = true', LDemoDfm) > 0) and
    (Pos('minimumcolumnwidth = 180', LDemoDfm) > 0) and
    (Pos('sizerowstocontent = true', LDemoDfm) > 0),
    'Inputs deve permanecer composto declarativamente por Scroll + Grid.');
  Require((Pos('width = 120', Copy(LDemoDfm,
      Pos('object tsinputs: ttabsheet', LDemoDfm),
      Pos('object tsselectors: ttabsheet', LDemoDfm) -
        Pos('object tsinputs: ttabsheet', LDemoDfm))) = 0) and
    (Pos('top = 496', Copy(LDemoDfm,
      Pos('object tsinputs: ttabsheet', LDemoDfm),
      Pos('object tsselectors: ttabsheet', LDemoDfm) -
        Pos('object tsinputs: ttabsheet', LDemoDfm))) = 0),
    'Inputs reintroduziu Width=120 ou a colisao Top=496.');
  Require((Pos('tdacscrollcontainerstylehook', LHooks) > 0) and
    (CountText(LHooks, 'tdacscrollcontainerstylehook') = 2) and
    (CountText(LHooks,
      '.registerstylehook(tdacscrollcontainer') = 1) and
    (CountText(LHooks,
      '.unregisterstylehook(tdacscrollcontainer') = 1) and
    (CountText(LHooks, 'tdacdatagridstylehook') = 2) and
    (CountText(LHooks, '.registerstylehook(tdacdatagrid') = 1) and
    (CountText(LHooks, '.unregisterstylehook(tdacdatagrid') = 1) and
    (Pos('registerstylehook(tdbgrid', LHooks) = 0) and
    (Pos('tscrollboxstylehook', LHooks) = 0) and
    (Pos('registerstylehook(tscrollbox', LHooks) = 0) and
    (Pos('registerstylehook(tpagecontrol', LHooks) = 0) and
    (Pos('registerstylehook(ttabsheet', LHooks) = 0) and
    (Pos('registerstylehook(tpanel', LHooks) = 0) and
    (Pos('registerstylehook(tlabel', LHooks) = 0),
    'Hooks de scrollbar devem permanecer localizados em controles DAC.');
end;

constructor TFailingScrollHookAccess.Create(AControl: TWinControl);
begin
  inherited;
  raise EScrollHookAuthorityProbeFailure.Create(
    'injected ScrollContainer hook construction failure');
end;

constructor TFailingDataGridScrollHookAccess.Create(AControl: TWinControl);
begin
  inherited;
  raise EScrollHookAuthorityProbeFailure.Create(
    'injected DataGrid hook construction failure');
end;

procedure RequireControlTokenContractPresence;
const
  RequiredTokens: array[0..38] of string = (
    'alphaopaque', 'transparentsurfacefallback', 'badgecloseinset',
    'statusbarradius', 'tabscontentradius', 'buttoneditdefaultwidth',
    'buttoneditdefaultheight', 'buttoneditdefaultbuttonwidth',
    'buttoneditdefaultcornerradius', 'buttoneditbuttoncornerradius',
    'buttoneditbuttongap', 'buttoneditbuttoninset',
    'buttoneditlabeledminimumheight', 'datagridsmallrowheight',
    'datagridmediumrowheight', 'datagridlargerowheight',
    'datagridcellpaddinghorizontal', 'datagridcellpaddingvertical',
    'datagridhover', 'datagridfocus', 'datagridediting', 'datagridloading',
    'datagridempty', 'tabssurface', 'tabsdivider', 'tabstextdefault',
    'tabstexthover', 'tabstextactive', 'tabstextdisabled',
    'tabshoverbackground', 'tabsactivebackground', 'tabsindicator',
    'tabsfocus', 'scrollbartrack', 'scrollbarthumb',
    'scrollbarthumbhot', 'scrollbarthumbpressed', 'scrollbararrow',
    'scrollbarborder');
var
  I: Integer;
  LControls: TDACControlTokens;
  LPath: string;
  LRoot: string;
  LSource: string;
begin
  LRoot := ExpandFileName(TPath.Combine(ExtractFilePath(ParamStr(0)),
    '..\..\..\..\..'));
  LPath := TPath.Combine(LRoot,
    'Source\DesignSystem\DAC.Components.DesignSystem.ControlTokens.pas');
  Require(TFile.Exists(LPath), 'Fonte de ControlTokens ausente para auditoria MEM-095.');
  LSource := LowerCase(TFile.ReadAllText(LPath));
  for I := Low(RequiredTokens) to High(RequiredTokens) do
    Require(Pos(RequiredTokens[I], LSource) > 0,
      'ControlTokens nao declarou o contrato MEM-095: ' + RequiredTokens[I]);
  LControls := TDACComponentStyle.Resolve(dtmDark).Tokens.Controls;
  Require((LControls.AlphaOpaque = DACOpacityOpaque) and
    (LControls.TransparentSurfaceFallback = TAlphaColor($00000000)) and
    (LControls.BadgeCloseInset = 2) and (LControls.StatusBarRadius = 0) and
    (LControls.TabsContentRadius = DACTabsDefaultCornerRadius) and
    (LControls.ButtonEditDefaultWidth = 300) and
    (LControls.ButtonEditDefaultHeight = 40) and
    (LControls.ButtonEditDefaultButtonWidth = DACButtonEditDefaultButtonWidth) and
    (LControls.ButtonEditDefaultCornerRadius = DACButtonEditDefaultCornerRadius) and
    (LControls.ButtonEditButtonCornerRadius = 0) and
    (LControls.ButtonEditButtonGap = 0) and
    (LControls.ButtonEditButtonInset = 1) and
    (LControls.ButtonEditLabeledMinimumHeight = 64),
    'ControlTokens Dark nao preservou os valores existentes do MEM-095.');
  LControls := TDACComponentStyle.Resolve(dtmLight).Tokens.Controls;
  Require((LControls.AlphaOpaque = DACOpacityOpaque) and
    (LControls.TransparentSurfaceFallback = TAlphaColor($00000000)) and
    (LControls.BadgeCloseInset = 2) and (LControls.StatusBarRadius = 0) and
    (LControls.TabsContentRadius = DACTabsDefaultCornerRadius) and
    (LControls.ButtonEditDefaultWidth = 300) and
    (LControls.ButtonEditDefaultHeight = 40) and
    (LControls.ButtonEditDefaultButtonWidth = DACButtonEditDefaultButtonWidth) and
    (LControls.ButtonEditDefaultCornerRadius = DACButtonEditDefaultCornerRadius) and
    (LControls.ButtonEditButtonCornerRadius = 0) and
    (LControls.ButtonEditButtonGap = 0) and
    (LControls.ButtonEditButtonInset = 1) and
    (LControls.ButtonEditLabeledMinimumHeight = 64),
    'ControlTokens Light nao preservou os valores existentes do MEM-095.');
end;

procedure RequirePublishedDefault(const AClass: TClass;
  const APropertyName: string; const AExpected: Integer);
var
  LPropInfo: PPropInfo;
begin
  LPropInfo := GetPropInfo(AClass.ClassInfo, APropertyName);
  Require((LPropInfo <> nil) and (LPropInfo^.Default = AExpected),
    Format('%s.%s default RTTI divergiu: esperado %d.',
      [AClass.ClassName, APropertyName, AExpected]));
end;

procedure RequireDefaultGeometryTokens;
var
  LControls: TDACControlTokens;
  LDark: TDACControlTokens;

  procedure RequireGeometry(const AControl: TControl;
    const AWidth, AHeight: Single; const AName: string);
  begin
    try
      Require((AControl.Parent = nil) and
        (AControl.Width = Round(AWidth)) and
        (AControl.Height = Round(AHeight)),
        Format('%s nao preservou construcao sem Parent ou geometria default tokenizada.',
          [AName]));
    finally
      AControl.Free;
    end;
  end;

begin
  LControls := TDACComponentStyle.Resolve(dtmLight).Tokens.Controls;
  LDark := TDACComponentStyle.Resolve(dtmDark).Tokens.Controls;
  Require((LControls.AlphaOpaque = DACOpacityOpaque) and
    (DACOpacityTransparent = 0) and
    (LControls.BadgeDefaultWidth = LDark.BadgeDefaultWidth) and
    (LControls.ChartDefaultWidth = LDark.ChartDefaultWidth) and
    (LControls.ContainerDefaultWidth = LDark.ContainerDefaultWidth) and
    (LControls.DataGridDefaultWidth = LDark.DataGridDefaultWidth) and
    (LControls.GridContainerMinimumChildWidth =
      LDark.GridContainerMinimumChildWidth) and
    (LControls.GridContainerMinimumRowHeight =
      LDark.GridContainerMinimumRowHeight) and
    (LControls.TabsDefaultHeight = LDark.TabsDefaultHeight),
    'Metricas default do Lote B devem ser compartilhadas por Light/Dark.');

  RequireGeometry(TDACBadge.Create(nil), LControls.BadgeDefaultWidth,
    LControls.BadgeDefaultHeight, 'TDACBadge');
  RequireGeometry(TDACChart.Create(nil), LControls.ChartDefaultWidth,
    LControls.ChartDefaultHeight, 'TDACChart');
  RequireGeometry(TDACContainer.Create(nil), LControls.ContainerDefaultWidth,
    LControls.ContainerDefaultHeight, 'TDACContainer');
  RequireGeometry(TDACDataGrid.Create(nil), LControls.DataGridDefaultWidth,
    LControls.DataGridDefaultHeight, 'TDACDataGrid');
  RequireGeometry(TDACToast.Create(nil), LControls.ToastDefaultWidth,
    LControls.ToastDefaultHeight, 'TDACToast');
  RequireGeometry(TDACModalDialog.Create(nil), LControls.ModalDefaultWidth,
    LControls.ModalDefaultHeight, 'TDACModalDialog');
  RequireGeometry(TDACTooltip.Create(nil), LControls.TooltipDefaultWidth,
    LControls.TooltipDefaultHeight, 'TDACTooltip');
  RequireGeometry(TDACGridContainer.Create(nil),
    LControls.GridContainerDefaultWidth,
    LControls.GridContainerDefaultHeight, 'TDACGridContainer');
  RequireGeometry(TDACLoading.Create(nil), LControls.LoadingDefaultWidth,
    LControls.LoadingDefaultHeight, 'TDACLoading');
  RequireGeometry(TDACPagination.Create(nil),
    LControls.PaginationDefaultWidth,
    LControls.PaginationDefaultHeight, 'TDACPagination');
  RequireGeometry(TDACProgress.Create(nil), LControls.ProgressDefaultWidth,
    LControls.ProgressDefaultHeight, 'TDACProgress');
  RequireGeometry(TDACReportViewer.Create(nil),
    LControls.ReportViewerDefaultWidth,
    LControls.ReportViewerDefaultHeight, 'TDACReportViewer');
  RequireGeometry(TDACScrollContainer.Create(nil),
    LControls.ScrollContainerDefaultWidth,
    LControls.ScrollContainerDefaultHeight, 'TDACScrollContainer');
  RequireGeometry(TDACCheckBox.Create(nil), LControls.SelectorDefaultWidth,
    LControls.SelectorDefaultHeight, 'TDACCheckBox');
  RequireGeometry(TDACToggleSwitch.Create(nil), LControls.ToggleDefaultWidth,
    LControls.ToggleDefaultHeight, 'TDACToggleSwitch');
  RequireGeometry(TDACSlider.Create(nil), LControls.SliderDefaultWidth,
    LControls.SliderDefaultHeight, 'TDACSlider');
  RequireGeometry(TDACSkiaControl.Create(nil),
    LControls.SkiaControlDefaultWidth,
    LControls.SkiaControlDefaultHeight, 'TDACSkiaControl');
  RequireGeometry(TDACStatusBar.Create(nil), LControls.StatusBarDefaultWidth,
    LControls.StatusBarHeight, 'TDACStatusBar');
  RequireGeometry(TDACSummaryCard.Create(nil),
    LControls.SummaryCardDefaultWidth,
    LControls.SummaryCardDefaultHeight, 'TDACSummaryCard');
  RequireGeometry(TDACTabs.Create(nil), LControls.TabsDefaultWidth,
    LControls.TabsDefaultHeight, 'TDACTabs');

  RequirePublishedDefault(TDACDataGrid, 'CornerRadius',
    DACDataGridDefaultCornerRadius);
  RequirePublishedDefault(TDACButtonEdit, 'ButtonWidth',
    DACButtonEditDefaultButtonWidth);
  RequirePublishedDefault(TDACButtonEdit, 'CornerRadius',
    DACButtonEditDefaultCornerRadius);
  RequirePublishedDefault(TDACEdit, 'CornerRadius',
    DACEditDefaultCornerRadius);
  RequirePublishedDefault(TDACComboBox, 'CornerRadius',
    DACComboBoxDefaultCornerRadius);
  RequirePublishedDefault(TDACDateTimePicker, 'CornerRadius',
    DACDateTimeDefaultCornerRadius);
  RequirePublishedDefault(TDACMemo, 'CornerRadius',
    DACMemoDefaultCornerRadius);
  RequirePublishedDefault(TDACContainer, 'BorderWidth',
    DACContainerDefaultBorderWidth);
  RequirePublishedDefault(TDACContainer, 'HeaderHeight',
    DACContainerDefaultHeaderHeight);
  RequirePublishedDefault(TDACBadge, 'CornerRadius',
    DACBadgeDefaultCornerRadius);
  RequirePublishedDefault(TDACTabs, 'CornerRadius',
    DACTabsDefaultCornerRadius);
  RequirePublishedDefault(TDACTabs, 'Size', Ord(mtsMedium));
end;

procedure RequireDesignTimePresetConstruction;
var
  LButton: TDesignButtonAccess;
  LGrid: TDesignGridAccess;
  LScroll: TDesignScrollAccess;
  LText: TDesignSystemTextAccess;
begin
  LText := TDesignSystemTextAccess.Create(nil);
  LButton := TDesignButtonAccess.Create(nil);
  LGrid := TDesignGridAccess.Create(nil);
  LScroll := TDesignScrollAccess.Create(nil);
  try
    LText.Role := mtrDisplay;
    LText.Tone := mttPrimary;
    LButton.Shape := mbshRounded;
    LGrid.Layout := mgclActionTiles;
    LGrid.Appearance := mgcaTransparent;
    LScroll.Appearance := mscaViewport;
    LText.SimulateDesignerLoaded;
    LButton.SimulateDesignerLoaded;
    LGrid.SimulateDesignerLoaded;
    LScroll.SimulateDesignerLoaded;
    Require((LText.Parent = nil) and
      (LText.Role = mtrDisplay) and
      (LText.FontSize = Round(
        TDACComponentStyle.ResolveForSurface(LText, dtmInherit).
          Tokens.Typography.DisplaySize)),
      'SystemText falhou no Loaded de designer sem Parent/handle.');
    Require((LButton.Parent = nil) and not LButton.HandleAllocated and
      (LButton.Shape = mbshRounded) and
      (LButton.CornerRadius = Round(
        TDACComponentStyle.ResolveForSurface(LButton, dtmInherit).
          Tokens.Controls.ButtonRoundedCornerRadius)),
      'ButtonShape falhou no Loaded de designer sem Parent/handle.');
    Require((LGrid.Parent = nil) and not LGrid.HandleAllocated and
      (LGrid.Layout = mgclActionTiles) and
      (LGrid.Appearance = mgcaTransparent) and
      (LGrid.RowHeight = 70) and
      not LGrid.AutoContentHeight and
      (LGrid.MinimumColumnWidth = 0) and
      not LGrid.SizeRowsToContent,
      'GridContainer falhou no Loaded de designer sem Parent/handle.');
    Require((LScroll.Parent = nil) and not LScroll.HandleAllocated and
      (LScroll.Appearance = mscaViewport) and
      (LScroll.CornerRadius = 0),
      'ScrollContainer falhou no Loaded de designer sem Parent/handle.');
  finally
    LScroll.Free;
    LGrid.Free;
    LButton.Free;
    LText.Free;
  end;
end;

procedure RequireGridContainerMinimumTokens(const AParent: TWinControl);
var
  LChild: TPanel;
  LGrid: TDACGridContainer;
  LTokens: TDACControlTokens;
begin
  LTokens := TDACComponentStyle.Resolve(dtmLight).Tokens.Controls;
  LGrid := TDACGridContainer.Create(nil);
  try
    LGrid.Parent := AParent;
    LGrid.SetBounds(0, 0, Round(LTokens.GridContainerDefaultWidth),
      Round(LTokens.GridContainerDefaultHeight));
    LGrid.RowHeight := 0;
    Require(LGrid.RowHeight = Round(LTokens.GridContainerMinimumRowHeight),
      'GridContainer nao aplicou o minimo tokenizado de RowHeight.');
    LChild := TPanel.Create(LGrid);
    LChild.Parent := LGrid;
    LChild.Tag := 1;
    LChild.Visible := True;
    LGrid.Perform(WM_SIZE, 0, MakeLong(LGrid.Width, LGrid.Height));
    Application.ProcessMessages;
    Require(LChild.Width >= Round(LTokens.GridContainerMinimumChildWidth),
      'GridContainer nao aplicou a largura minima tokenizada ao filho.');
  finally
    LGrid.Free;
  end;
end;

procedure RequireCentralizedSemanticSources;
const
  SourceFiles: array[0..3] of string = (
    'Source\Controls\DAC.Components.Controls.DataGrid.pas',
    'Source\Controls\DAC.Components.Controls.Badges.pas',
    'Source\Controls\DAC.Components.Controls.Progress.pas',
    'Source\Controls\DAC.Components.Controls.Feedback.pas');
  Forbidden: array[0..3] of string = (
    '$ff111827', 'alpha(43, 125, 233)', 'alpha(71, 85, 105)',
    'tdacsemanticcolors.colorsfor');
var
  I: Integer;
  J: Integer;
  LPath: string;
  LRoot: string;
  LSource: string;
begin
  LRoot := ExpandFileName(TPath.Combine(ExtractFilePath(ParamStr(0)),
    '..\..\..\..\..'));
  for I := Low(SourceFiles) to High(SourceFiles) do
  begin
    LPath := TPath.Combine(LRoot, SourceFiles[I]);
    Require(TFile.Exists(LPath), 'Fonte ausente para a auditoria semantica: ' + LPath);
    LSource := LowerCase(TFile.ReadAllText(LPath));
    for J := Low(Forbidden) to High(Forbidden) do
      Require(Pos(Forbidden[J], LSource) = 0,
        'Papel semantico duplicado fora do ComponentStyle/ColorTokens: ' +
        Forbidden[J] + ' em ' + SourceFiles[I]);
  end;
end;

function SourceProcedureBody(const ASource, ASignature: string): string;
var
  LStart: Integer;
  LNextFunction: Integer;
  LNextProcedure: Integer;
  LStop: Integer;
begin
  LStart := Pos(ASignature, ASource);
  Require(LStart > 0, 'Procedimento ausente na auditoria de redraw: ' + ASignature);
  LNextProcedure := PosEx(#10 + 'procedure ', ASource, LStart + Length(ASignature));
  LNextFunction := PosEx(#10 + 'function ', ASource, LStart + Length(ASignature));
  LStop := Length(ASource) + 1;
  if (LNextProcedure > 0) and (LNextProcedure < LStop) then
    LStop := LNextProcedure;
  if (LNextFunction > 0) and (LNextFunction < LStop) then
    LStop := LNextFunction;
  Result := Copy(ASource, LStart, LStop - LStart);
end;

procedure RequireDataGridPreviewTokenization;
const
  RequiredTokens: array[0..40] of string = (
    'datagridpreviewframebackground', 'datagridpreviewframeborder',
    'datagridpreviewframeinset',
    'datagridpreviewframeborderwidth', 'datagridpreviewheaderinset',
    'datagridpreviewheaderheight', 'datagridpreviewheaderbackground',
    'datagridpreviewheaderradius', 'datagridpreviewheadertextinset',
    'datagridpreviewheadertextsize', 'datagridpreviewheadertext',
    'datagridpreviewrowinset', 'datagridpreviewrowheight',
    'datagridpreviewrowbackground', 'datagridpreviewrowradius',
    'datagridpreviewrowtextinset', 'datagridpreviewrowtextsize',
    'datagridpreviewrowtext', 'datagridpreviewstatusinset',
    'datagridpreviewstatustopinset', 'datagridpreviewstatusbottominset',
    'datagridpreviewstatusbackground', 'datagridpreviewstatusradius',
    'datagridpreviewstatustextsize', 'datagridpreviewstatustext',
    'datagridpreviewrowsstart', 'datagridpreviewfooterinset',
    'datagridpreviewfooterheight', 'datagridpreviewfooterbackground',
    'datagridpreviewfooterradius', 'datagridpreviewfootertextleftinset',
    'datagridpreviewfootertextbottominset', 'datagridpreviewfootertextsize',
    'datagridpreviewfootertext', 'datagridpreviewfootertextmaxwidthratio',
    'datagridpreviewfootervalueleftratio', 'datagridpreviewfootervaluetopoffset',
    'datagridpreviewfootervaluerightinset',
    'datagridpreviewfootervaluebottominset',
    'datagridpreviewfootervaluetextsize', 'datagridpreviewfootervaluetext');
var
  I: Integer;
  LBody: string;
  LPath: string;
  LRoot: string;
  LSource: string;
begin
  LRoot := ExpandFileName(TPath.Combine(ExtractFilePath(ParamStr(0)),
    '..\..\..\..\..'));
  LPath := TPath.Combine(LRoot,
    'Source\Controls\DAC.Components.Controls.DataGrid.pas');
  Require(TFile.Exists(LPath), 'Fonte do DataGrid ausente para auditoria do preview.');
  LSource := LowerCase(TFile.ReadAllText(LPath));
  LBody := SourceProcedureBody(LSource, 'procedure tdacdatagrid.drawpreview');
  Require(Pos('tdaccomponentcolors.', LBody) = 0,
    'DrawPreview nao pode manter cores globais fora dos tokens locais.');
  Require(Pos('alpha(', LBody) = 0,
    'DrawPreview nao pode manter alpha literal.');
  Require(Pos('paintcornerradius', LBody) > 0,
    'DrawPreview precisa consumir o CornerRadius publicado do DataGrid.');
  for I := Low(RequiredTokens) to High(RequiredTokens) do
    Require(Pos(RequiredTokens[I], LBody) > 0,
      'DrawPreview nao consumiu o token esperado: ' + RequiredTokens[I]);
end;

procedure RequireDataGridCornerRadiusContract;
const
  PainterSignatures: array[0..3] of string = (
    'procedure tdacdatagrid.drawdatasetchrome',
    'procedure tdacdatagrid.drawemptystate',
    'procedure tdacdatagrid.drawloadingstate',
    'procedure tdacdatagrid.drawpreview');
var
  I: Integer;
  LBody: string;
  LPath: string;
  LRoot: string;
  LSource: string;
begin
  LRoot := ExpandFileName(TPath.Combine(ExtractFilePath(ParamStr(0)),
    '..\..\..\..\..'));
  LPath := TPath.Combine(LRoot,
    'Source\Controls\DAC.Components.Controls.DataGrid.pas');
  LSource := LowerCase(TFile.ReadAllText(LPath));
  Require(Pos('result := pixels(fcornerradius)', LSource) > 0,
    'CornerRadius publicado nao alimenta a metrica efetiva do painter.');
  Require(Pos('default dacdatagriddefaultcornerradius', LSource) > 0,
    'Default publicado do CornerRadius nao esta ligado ao token estavel.');
  for I := Low(PainterSignatures) to High(PainterSignatures) do
  begin
    LBody := SourceProcedureBody(LSource, PainterSignatures[I]);
    Require(Pos('paintcornerradius', LBody) > 0,
      'Painter do DataGrid ignorou CornerRadius: ' + PainterSignatures[I]);
  end;
end;

procedure RequireAllFamilySurfaceConsumers;
const
  FamilySources: array[0..14] of string = (
    'DAC.Components.Controls.Button.pas',
    'DAC.Components.Controls.Edit.pas',
    'DAC.Components.Controls.ComboBox.pas',
    'DAC.Components.Controls.Selectors.pas',
    'DAC.Components.Controls.Tabs.pas',
    'DAC.Components.Controls.SummaryCard.pas',
    'DAC.Components.Controls.DataGrid.pas',
    'DAC.Components.Controls.StatusBar.pas',
    'DAC.Components.Controls.Progress.pas',
    'DAC.Components.Controls.Badges.pas',
    'DAC.Components.Controls.Feedback.pas',
    'DAC.Components.Controls.Pagination.pas',
    'DAC.Components.Controls.Loading.pas',
    'DAC.Components.Controls.Charts.pas',
    'DAC.Components.Controls.ReportViewer.pas');
  HostSources: array[0..4] of string = (
    'DAC.Components.Controls.Container.pas',
    'DAC.Components.Controls.ScrollContainer.pas',
    'DAC.Components.Controls.GridContainer.pas',
    'DAC.Components.Controls.SkiaControl.pas',
    'DAC.Components.Controls.SystemText.pas');
var
  I: Integer;
  LPath: string;
  LRoot: string;
  LSource: string;
  procedure RequireConsumer(const AFileName, AKind: string);
  begin
    LPath := TPath.Combine(LRoot, AFileName);
    Require(TFile.Exists(LPath), 'Fonte ausente na matriz de surface: ' + AFileName);
    LSource := LowerCase(TFile.ReadAllText(LPath));
    Require(Pos('resolveforsurface(self, fthememode)', LSource) > 0,
      AKind + ' nao consome ResolveForSurface: ' + AFileName);
    Require(Pos('resolve(fthememode)', LSource) = 0,
      AKind + ' ainda possui resolucao global direta: ' + AFileName);
  end;
begin
  LRoot := ExpandFileName(TPath.Combine(ExtractFilePath(ParamStr(0)),
    '..\..\..\..\..\Source\Controls'));
  for I := Low(FamilySources) to High(FamilySources) do
    RequireConsumer(FamilySources[I], 'Familia');
  for I := Low(HostSources) to High(HostSources) do
    RequireConsumer(HostSources[I], 'Host');
end;

procedure RequireAssetContractEnforcement;
const
  ControlSources: array[0..23] of string = (
    'DAC.Components.Controls.Badges.pas',
    'DAC.Components.Controls.Button.pas',
    'DAC.Components.Controls.ButtonEdit.pas',
    'DAC.Components.Controls.Charts.pas',
    'DAC.Components.Controls.ComboBox.pas',
    'DAC.Components.Controls.Container.pas',
    'DAC.Components.Controls.DataGrid.pas',
    'DAC.Components.Controls.DateTimePicker.pas',
    'DAC.Components.Controls.DateTimePickerPopup.pas',
    'DAC.Components.Controls.Edit.pas',
    'DAC.Components.Controls.Feedback.pas',
    'DAC.Components.Controls.GridContainer.pas',
    'DAC.Components.Controls.Loading.pas',
    'DAC.Components.Controls.Memo.pas',
    'DAC.Components.Controls.Pagination.pas',
    'DAC.Components.Controls.Progress.pas',
    'DAC.Components.Controls.ReportViewer.pas',
    'DAC.Components.Controls.ScrollContainer.pas',
    'DAC.Components.Controls.Selectors.pas',
    'DAC.Components.Controls.StatusBar.pas',
    'DAC.Components.Controls.SummaryCard.pas',
    'DAC.Components.Controls.SystemText.pas',
    'DAC.Components.Controls.Tabs.pas',
    'DAC.Components.Controls.SkiaControl.pas');
  ForbiddenFonts: array[0..4] of string = (
    'arial', 'segoe ui', 'roboto', 'tahoma', 'calibri');
var
  I: Integer;
  J: Integer;
  LControls: TDACControlTokens;
  LPath: string;
  LRoot: string;
  LSource: string;
begin
  LRoot := ExpandFileName(TPath.Combine(ExtractFilePath(ParamStr(0)),
    '..\..\..\..\..\Source\Controls'));
  for I := Low(ControlSources) to High(ControlSources) do
  begin
    LPath := TPath.Combine(LRoot, ControlSources[I]);
    Require(TFile.Exists(LPath),
      'Fonte ausente na auditoria de contrato visual: ' + ControlSources[I]);
    LSource := LowerCase(TFile.ReadAllText(LPath));
    Require(Pos('talphacolor($', LSource) = 0,
      'Cor de desenho nao pode ficar no controle: ' + ControlSources[I]);
    for J := Low(ForbiddenFonts) to High(ForbiddenFonts) do
      Require(Pos(ForbiddenFonts[J], LSource) = 0,
        'Fonte nao autorizada no controle: ' + ForbiddenFonts[J] +
        ' em ' + ControlSources[I]);
  end;
  LControls := TDACComponentStyle.Resolve(dtmDark).Tokens.Controls;
  Require((LControls.ChartDoughnutStartAngle = -90) and
    (LControls.ChartFullCircleDegrees = 360),
    'Orientacao e circulo do doughnut devem ser tokens do contrato visual.');
  LControls := TDACComponentStyle.Resolve(dtmLight).Tokens.Controls;
  Require((LControls.ChartDoughnutStartAngle = -90) and
    (LControls.ChartFullCircleDegrees = 360),
    'Tokens geometricos do doughnut devem ser identicos no modo claro.');
end;

procedure RequireSurfaceFamilyMatrix(const AParent: TWinControl);
var
  LControls: array[0..14] of TControl;
  LDarkHost: TPanel;
  LExplicitHost: TDACContainer;
  LLightHost: TPanel;
  LNeutralHost: TPanel;
  LTheme: IDACComponentsTheme;
  I: Integer;
  procedure RequireMode(const AControl: TControl; const AExpected: TDACThemeMode;
    const AStage: string);
  begin
    LTheme := TDACComponentStyle.ResolveForSurface(AControl, dtmInherit);
    Require(LTheme.Tokens.Controls.ButtonFallbackBackground =
      TDACComponentStyle.Resolve(AExpected).Tokens.Controls.ButtonFallbackBackground,
      AControl.ClassName + ' resolveu surface incorreta em ' + AStage + '.');
  end;
begin
  LDarkHost := TPanel.Create(nil);
  LLightHost := TPanel.Create(nil);
  LExplicitHost := TDACContainer.Create(nil);
  LNeutralHost := TPanel.Create(nil);
  for I := Low(LControls) to High(LControls) do
    LControls[I] := nil;
  try
    LDarkHost.Parent := AParent;
    LDarkHost.ParentBackground := False;
    LDarkHost.ParentColor := False;
    LDarkHost.Color := RGB($0F, $18, $13);
    LDarkHost.Visible := False;

    LLightHost.Parent := AParent;
    LLightHost.ParentBackground := False;
    LLightHost.ParentColor := False;
    LLightHost.Color := RGB($F8, $FA, $F8);
    LLightHost.Visible := False;

    LExplicitHost.Parent := AParent;
    LExplicitHost.ThemeMode := dtmDark;
    LExplicitHost.BackgroundColor := TAlphaColor($FF808080);
    LExplicitHost.Visible := False;
    LNeutralHost.Parent := LExplicitHost;
    LNeutralHost.ParentBackground := False;
    LNeutralHost.ParentColor := False;
    LNeutralHost.Color := RGB($80, $80, $80);
    LNeutralHost.Visible := False;

    LControls[0] := TDACButton.Create(nil);
    LControls[1] := TDACEdit.Create(nil);
    LControls[2] := TDACComboBox.Create(nil);
    LControls[3] := TDACCheckBox.Create(nil);
    LControls[4] := TDACTabs.Create(nil);
    LControls[5] := TDACSummaryCard.Create(nil);
    LControls[6] := TDACDataGrid.Create(nil);
    LControls[7] := TDACStatusBar.Create(nil);
    LControls[8] := TDACProgress.Create(nil);
    LControls[9] := TDACBadge.Create(nil);
    LControls[10] := TDACToast.Create(nil);
    LControls[11] := TDACPagination.Create(nil);
    LControls[12] := TDACLoading.Create(nil);
    LControls[13] := TDACChart.Create(nil);
    LControls[14] := TDACReportViewer.Create(nil);

    for I := Low(LControls) to High(LControls) do
    begin
      LControls[I].Parent := LDarkHost;
      RequireMode(LControls[I], dtmDark, 'host VCL dark');
      LControls[I].Parent := LLightHost;
      RequireMode(LControls[I], dtmLight, 'host VCL light');
      LControls[I].Parent := LNeutralHost;
      RequireMode(LControls[I], dtmDark,
        'host neutro sob ThemeMode ancestral explicito');
      LTheme := TDACComponentStyle.ResolveForSurface(LControls[I], dtmLight);
      Require(LTheme.Tokens.Controls.ButtonFallbackBackground =
        TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.ButtonFallbackBackground,
        LControls[I].ClassName + ' nao preservou override local explicito.');
    end;
  finally
    for I := High(LControls) downto Low(LControls) do
      LControls[I].Free;
    LNeutralHost.Free;
    LExplicitHost.Free;
    LLightHost.Free;
    LDarkHost.Free;
  end;
end;

procedure RequireDataGridPreviewThemeTokens(const AMode: TDACThemeMode;
  const AState: string);
var
  LControls: TDACControlTokens;
begin
  LControls := TDACComponentStyle.Resolve(AMode).Tokens.Controls;
  Require((LControls.DataGridPreviewFrameBackground = LControls.DataGridBackground) and
    (LControls.DataGridPreviewFrameBorder = LControls.DataGridBorder) and
    (LControls.DataGridPreviewHeaderBackground = LControls.DataGridHeader) and
    (LControls.DataGridPreviewHeaderText = LControls.DataGridHeaderText) and
    (LControls.DataGridPreviewRowBackground = LControls.DataGridRowAlternate) and
    (LControls.DataGridPreviewRowText = LControls.DataGridText) and
    (LControls.DataGridPreviewStatusBackground = LControls.DataGridStatusBackground) and
    (LControls.DataGridPreviewStatusText = LControls.DataGridStatusText) and
    (LControls.DataGridPreviewFooterBackground = LControls.DataGridFooterBackground) and
    (LControls.DataGridPreviewFooterText = LControls.DataGridFooterText) and
    (LControls.DataGridPreviewFooterValueText = LControls.DataGridFooterValueText),
    'Tokens de cor do preview do DataGrid nao resolveram para ' + AState + '.');
end;

procedure RequireMemoThemeTokenization;
var
  LBody: string;
  LPath: string;
  LRoot: string;
  LSource: string;
begin
  LRoot := ExpandFileName(TPath.Combine(ExtractFilePath(ParamStr(0)),
    '..\..\..\..\..'));
  LPath := TPath.Combine(LRoot,
    'Source\Controls\DAC.Components.Controls.Memo.pas');
  Require(TFile.Exists(LPath), 'Fonte do Memo ausente para auditoria de tema.');
  LSource := LowerCase(TFile.ReadAllText(LPath));
  LBody := SourceProcedureBody(LSource, 'procedure tdacmemo.paintboxdraw');
  Require((Pos('tdaccomponentcolors', LSource) = 0) and
    (Pos('resolveparentsurface', LSource) = 0) and
    (Pos('alpha(', LBody) = 0) and
    (Pos('resolvedtokens', LBody) > 0),
    'TDACMemo deve resolver o chrome por tokens locais, sem superficie global.');
end;

procedure RequireSystemTextInterOnly;
var
  LPath: string;
  LRoot: string;
  LSource: string;
begin
  LRoot := ExpandFileName(TPath.Combine(ExtractFilePath(ParamStr(0)),
    '..\..\..\..\..'));
  LPath := TPath.Combine(LRoot,
    'Source\Controls\DAC.Components.Controls.SystemText.pas');
  Require(TFile.Exists(LPath), 'Fonte do SystemText ausente para auditoria de Inter.');
  LSource := LowerCase(TFile.ReadAllText(LPath));
  Require((Pos('ffontfamily := tdaccomponentstyle.fontfamily', LSource) > 0) and
    (Pos('canvas.font.name := tdaccomponentstyle.fontfamily', LSource) > 0) and
    (Pos('fcustomfontfamily', LSource) = 0),
    'TDACSystemText nao pode aceitar uma familia diferente de Inter.');
end;

procedure RequireSkiaControlThemeResolution;
var
  LBody: string;
  LPath: string;
  LRoot: string;
  LSource: string;
begin
  LRoot := ExpandFileName(TPath.Combine(ExtractFilePath(ParamStr(0)),
    '..\..\..\..\..'));
  LPath := TPath.Combine(LRoot,
    'Source\Controls\DAC.Components.Controls.SkiaControl.pas');
  Require(TFile.Exists(LPath), 'Fonte do TDACSkiaControl ausente para auditoria de tema.');
  LSource := LowerCase(TFile.ReadAllText(LPath));
  LBody := SourceProcedureBody(LSource, 'procedure tdacskiacontrol.drawcontent');
  Require((Pos('fthememode: tdacthememode', LSource) > 0) and
    (Pos('registerlistener(self, themechanged)', LSource) > 0) and
    (Pos('unregisterlistener(self)', LSource) > 0) and
    (Pos('function tdacskiacontrol.resolvedtheme', LSource) > 0) and
    (Pos('tdaccomponentstyle.resolveforsurface(self, fthememode)', LSource) > 0) and
    (Pos('resolvedtheme', LBody) > 0) and
    (Pos('ftheme)', LBody) = 0),
    'TDACSkiaControl deve resolver DrawContent pelo ThemeMode efetivo.');
end;

procedure RequireDoughnutThemePaletteResolution;
var
  LBody: string;
  LPalettePath: string;
  LPath: string;
  LRoot: string;
  LSource: string;
begin
  LRoot := ExpandFileName(TPath.Combine(ExtractFilePath(ParamStr(0)),
    '..\..\..\..\..'));
  LPath := TPath.Combine(LRoot,
    'Source\Controls\DAC.Components.Controls.Charts.pas');
  Require(TFile.Exists(LPath), 'Fonte do DoughnutChart ausente para auditoria de paleta.');
  LSource := LowerCase(TFile.ReadAllText(LPath));
  LBody := SourceProcedureBody(LSource, 'procedure tdacchart.drawpieseries');
  Require((Pos('resolvedchartpalette.colorbyindex(i)', LBody) > 0) and
    (Pos('tdaccomponentstyle.chartpalette', LBody) = 0) and
    (Pos('tdaccomponentstyle.resolveforsurface(self, fthememode).chartpalette',
      LSource) > 0),
    'Doughnut deve resolver a paleta pela instancia, sem consultar o tema global.');
  LPalettePath := TPath.Combine(LRoot,
    'Source\DesignSystem\DAC.Components.DesignSystem.ChartPalette.pas');
  LSource := LowerCase(TFile.ReadAllText(LPalettePath));
  Require((Pos('class function tdacchartpalette.dark', LSource) > 0) and
    (Pos('class function tdacchartpalette.light', LSource) > 0),
    'ChartPalette precisa definir variantes Dark e Light.');
end;

procedure RequireEditThemeTokenization;
var
  LBody: string;
  LBorderWidthAt: Integer;
  LPath: string;
  LRoot: string;
  LSource: string;
begin
  LRoot := ExpandFileName(TPath.Combine(ExtractFilePath(ParamStr(0)),
    '..\..\..\..\..'));
  LPath := TPath.Combine(LRoot,
    'Source\Controls\DAC.Components.Controls.Edit.pas');
  Require(TFile.Exists(LPath), 'Fonte do TDACEdit ausente para auditoria de tokens.');
  LSource := LowerCase(TFile.ReadAllText(LPath));
  LBody := SourceProcedureBody(LSource, 'procedure tdacedit.paintboxdraw');
  LBorderWidthAt := Pos('inputborderwidth', LBody);
  Require((Pos('tdaccomponentcolors', LSource) = 0) and
    (Pos('tokens.colors', LSource) = 0) and
    (Pos('resolvedtokens', LBody) > 0) and
    (Pos('inputiconcolumnwidth', LBody) > 0) and
    (Pos('inputfocusborderwidth', LBody) > 0) and
    (Pos('lcontrolbottom), 1)', LBody) > 0) and
    (Pos('lborder.width := ltokens.inputborderwidth', LBody) > 0) and
    (LBorderWidthAt > 0) and
    (PosEx('inputborderwidth', LBody, LBorderWidthAt + 1) = 0),
    'TDACEdit deve resolver chrome e HWND pelos Input* locais.');
end;

procedure RequireComboBoxThemeTokenization;
var
  LDrawBody: string;
  LFieldDrawBody: string;
  LKeyBody: string;
  LPath: string;
  LRoot: string;
  LShowBody: string;
  LSource: string;
begin
  LRoot := ExpandFileName(TPath.Combine(ExtractFilePath(ParamStr(0)),
    '..\..\..\..\..'));
  LPath := TPath.Combine(LRoot,
    'Source\Controls\DAC.Components.Controls.ComboBox.pas');
  Require(TFile.Exists(LPath), 'Fonte do TDACComboBox ausente para auditoria de tokens.');
  LSource := LowerCase(TFile.ReadAllText(LPath));
  LFieldDrawBody := SourceProcedureBody(LSource,
    'procedure tdaccombobox.paintboxdraw');
  LDrawBody := SourceProcedureBody(LSource,
    'procedure tdaccombobox.dropdownpaintboxdraw');
  LShowBody := SourceProcedureBody(LSource,
    'procedure tdaccombobox.showdropdown');
  LKeyBody := SourceProcedureBody(LSource,
    'procedure tdaccombobox.dropdownkeydown');
  Require((Pos('tdaccomponentcolors', LDrawBody) = 0) and
    (Pos('tokens.colors', LSource) = 0) and
    (Pos('resolvedtokens', LDrawBody) > 0) and
    (Pos('comboboxpopupsnapscale', LDrawBody) > 0) and
    (Pos('comboboxpopupitemselected', LDrawBody) > 0) and
    (Pos('comboboxpopupcheck', LDrawBody) > 0) and
    (Pos('comboboxpopupseparator', LDrawBody) > 0) and
    (Pos('tdaccomponentfontinstaller.fontfamily', LDrawBody) > 0) and
    (Pos('comboboxpopupoffset', LShowBody) > 0) and
    (Pos('comboboxpopupbackground', LShowBody) > 0) and
    (Pos('csdestroying in componentstate', LShowBody) > 0) and
    (Pos('(parent = nil)', LShowBody) > 0) and
    (Pos('parent.handleallocated', LShowBody) > 0) and
    (Pos('vk_escape', LKeyBody) > 0) and (Pos('vk_down', LKeyBody) > 0) and
    (Pos('fonchange', LKeyBody) > 0) and (Pos('closedropdown', LKeyBody) > 0) and
    (Pos('frenderer.textcentered', LFieldDrawBody) = 0) and
    (Pos('tdacnativecombobox', LSource) > 0) and
    (Pos('cb_showdropdown', LSource) > 0) and
    (Pos('synchronizenative', LSource) > 0),
    'TDACComboBox deve resolver popup, teclado e selecao pelos ComboBox* locais.');
end;

procedure RequireButtonThemeTokenization;
var
  LCanvasBody: string;
  LDrawBody: string;
  LPaletteBody: string;
  LPath: string;
  LRoot: string;
  LSource: string;
begin
  LRoot := ExpandFileName(TPath.Combine(ExtractFilePath(ParamStr(0)),
    '..\..\..\..\..'));
  LPath := TPath.Combine(LRoot,
    'Source\Controls\DAC.Components.Controls.Button.pas');
  Require(TFile.Exists(LPath), 'Fonte do TDACButton ausente para auditoria de tokens.');
  LSource := LowerCase(TFile.ReadAllText(LPath));
  LPaletteBody := SourceProcedureBody(LSource, 'function buttonpalette');
  LCanvasBody := SourceProcedureBody(LSource,
    'function tdacbutton.canvasbackground');
  LDrawBody := SourceProcedureBody(LSource, 'procedure tdacbutton.paintboxdraw');
  Require((Pos('tdaccomponentcolors', LSource) = 0) and
    (Pos('tokens.colors', LSource) = 0) and
    (Pos('tdaccomponentstyle.fontfamily', LSource) = 0) and
    (Pos('resolvedtokens', LSource) > 0) and
    (Pos('buttonprimarybackground', LPaletteBody) > 0) and
    (Pos('buttonsecondarybackground', LPaletteBody) > 0) and
    (Pos('buttonghost', LPaletteBody) > 0) and
    (Pos('buttonwarning', LPaletteBody) > 0) and
    (Pos('buttondanger', LPaletteBody) > 0) and
    (Pos('buttondisabled', LPaletteBody) > 0) and
    (Pos('buttonloading', LPaletteBody) > 0) and
    (Pos('canvasbackground(ltokens)', LDrawBody) > 0) and
    (Pos('buttoncanvasbackground', LCanvasBody) > 0) and
    (Pos('buttoninputactioncanvasbackground', LCanvasBody) > 0) and
    (Pos('finputactionsurfaceprovider', LCanvasBody) > 0) and
    (Pos('buttoninputactiondivider', LDrawBody) > 0) and
    (Pos('buttoninputactioncaption', LDrawBody) > 0) and
    (Pos('tdaccomponentfontinstaller.fontfamily', LDrawBody) > 0) and
    (Pos('buttonmaximumiconsize', LSource) > 0) and
    (Pos('buttoncaptionbold', LSource) > 0) and
    (Pos('buttoncaptionmaxlines', LSource) > 0) and
    (Pos('default 12', LSource) = 0),
    'TDACButton deve resolver paleta, painter, divisor e caption por Button* locais.');
end;

procedure RequireDateTimePopupTokenization;
var
  LFieldDrawBody: string;
  LFieldSource: string;
  LDrawBody: string;
  LFooterBody: string;
  LPath: string;
  LRoot: string;
  LSimulateBody: string;
  LSource: string;
begin
  LRoot := ExpandFileName(TPath.Combine(ExtractFilePath(ParamStr(0)),
    '..\..\..\..\..'));
  LPath := TPath.Combine(LRoot,
    'Source\Controls\DAC.Components.Controls.DateTimePickerPopup.pas');
  Require(TFile.Exists(LPath), 'Fonte do popup DateTime ausente para auditoria de tokens.');
  LSource := LowerCase(TFile.ReadAllText(LPath));
  LDrawBody := SourceProcedureBody(LSource,
    'procedure tdacdatetimepickerpopup.paintboxdraw');
  LFooterBody := SourceProcedureBody(LSource,
    'function tdacdatetimepickerpopup.footeractionrect');
  LSimulateBody := SourceProcedureBody(LSource,
    'procedure tdacdatetimepickerpopup.simulatefooteraction');
  LFieldSource := LowerCase(TFile.ReadAllText(TPath.Combine(LRoot,
    'Source\Controls\DAC.Components.Controls.DateTimePicker.pas')));
  LFieldDrawBody := SourceProcedureBody(LFieldSource,
    'procedure tdacdatetimepicker.paintboxdraw');
  Require((Pos('tokens.colors', LSource) = 0) and
    (Pos('tdaccomponentstyle.fontfamily', LSource) = 0) and
    (Pos('datetimepopupbackground', LDrawBody) > 0) and
    (Pos('datetimepopupradius', LDrawBody) > 0) and
    (Pos('footeractionrect', LDrawBody) > 0) and
    (Pos('datetimepopupfooterheight', LFooterBody) > 0) and
    (Pos('datetimepopupfooteractionwidth', LFooterBody) > 0) and
    (Pos('datetimepopupfooteractiongap', LFooterBody) > 0) and
    (Pos('footeractionrect', LSimulateBody) > 0) and
    (Pos('datetimepopupaccept', LDrawBody) > 0) and
    (Pos('datetimepopupselected', LSource) > 0) and
    (Pos('datetimepopuptoday', LSource) > 0) and
    (Pos('datetimepopuptime', LSource) > 0) and
    (Pos('tdaccomponentfontinstaller.fontfamily', LSource) > 0) and
    (Pos('csdestroying in componentstate',
      SourceProcedureBody(LSource, 'procedure tdacdatetimepickerpopup.showfor')) > 0) and
    (Pos('acontrol.parent.handleallocated',
      SourceProcedureBody(LSource, 'procedure tdacdatetimepickerpopup.showfor')) > 0) and
    (Pos('applythememode(resolvedpopupthememode)', LFieldSource) > 0) and
    (Pos('frenderer.textcentered', LFieldDrawBody) = 0) and
    (Pos('updatenativevisibility', LFieldSource) > 0),
    'DateTimePicker deve manter texto no HWND e resolver popup pelo tema do dono.');
end;

procedure RequireEditThemeTokens(const AEdit: TDACEdit;
  const AMode: TDACThemeMode; const AState: string);
var
  LTokens: TDACControlTokens;
  LExpectedTop: Integer;
begin
  LTokens := TDACComponentStyle.Resolve(AMode).Tokens.Controls;
  LExpectedTop := AEdit.InputChromeTop +
    (Round(LTokens.InputMediumChromeHeight) -
      Round(LTokens.InputMediumEditorHeight)) div 2 +
    Round(LTokens.InputNativeVerticalOffset);
  Require((AEdit.ResolvedChromeColor = LTokens.InputChromeBackground) and
    (AEdit.EditControl.Color = TDACComponentColors.ToVclColor(LTokens.InputBackground)) and
    (AEdit.EditControl.Font.Color = TDACComponentColors.ToVclColor(LTokens.InputText)) and
    (AEdit.NativeLabel.Font.Color = TDACComponentColors.ToVclColor(LTokens.InputLabelText)) and
    SameText(AEdit.EditControl.Font.Name, TDACComponentStyle.FontFamily) and
    (AEdit.EditControl.Font.Size = Round(LTokens.InputMediumTextSize)) and
    (AEdit.NativeLabel.Font.Size = Round(LTokens.InputMediumTextSize)) and
    (AEdit.InputChromeTop = Round(LTokens.InputChromeTop)) and
    (AEdit.InputChromeHeight = Round(LTokens.InputMediumChromeHeight)) and
    (AEdit.EditControl.Left = Round(LTokens.InputNativeHorizontalPadding)) and
    (AEdit.EditControl.Top = LExpectedTop) and
    (AEdit.EditControl.Height = Round(LTokens.InputMediumEditorHeight)) and
    (AEdit.EditControl.Width = AEdit.Width -
      (Round(LTokens.InputNativeHorizontalPadding) * 2)),
    'TDACEdit nao aplicou tokens de chrome/HWND em ' + AState + '.');
end;

procedure RequireComboBoxThemeTokens(const ACombo: TDACComboBox;
  const AMode: TDACThemeMode; const AState: string);
var
  LRegion: HRGN;
  LRegionBox: TRect;
  LRegionResult: Integer;
  LTokens: TDACControlTokens;
begin
  LTokens := TDACComponentStyle.Resolve(AMode).Tokens.Controls;
  LRegion := CreateRectRgn(0, 0, 0, 0);
  try
    LRegionResult := GetWindowRgn(ACombo.ComboControl.Handle, LRegion);
    GetRgnBox(LRegion, LRegionBox);
  finally
    DeleteObject(LRegion);
  end;
  Require((ACombo.ResolvedChromeColor = LTokens.ComboBoxChromeBackground) and
    (ACombo.ResolvedPopupBackground = LTokens.ComboBoxPopupBackground) and
    (ACombo.ComboControl.Color = TDACComponentColors.ToVclColor(
      LTokens.ComboBoxBackground)) and
    (ACombo.ComboControl.Font.Color = TDACComponentColors.ToVclColor(
      LTokens.ComboBoxText)) and
    SameText(ACombo.ComboControl.Font.Name, TDACComponentFontInstaller.FontFamily) and
    (ACombo.ComboControl.Font.Size = Round(LTokens.ComboBoxMediumTextSize)) and
    (ACombo.NativeLabel.Font.Color = TDACComponentColors.ToVclColor(
      LTokens.ComboBoxLabelText)) and
    (ACombo.ComboControl.Left = Round(LTokens.ComboBoxNativeHorizontalPadding)) and
    (ACombo.ComboControl.Width = ACombo.Width -
      Round(LTokens.ComboBoxNativeHorizontalPadding)) and
    (LRegionResult = SIMPLEREGION) and
    (LRegionBox.Top =
      Round(LTokens.ComboBoxNativeVerticalClipInset)) and
    (LRegionBox.Right = ACombo.ComboControl.Width -
      Round(LTokens.ComboBoxNativeRightReserve)) and
    (LRegionBox.Bottom = ACombo.ComboControl.Height -
      Round(LTokens.ComboBoxNativeVerticalClipInset)),
    'TDACComboBox nao aplicou tokens locais em ' + AState + '.');
end;

function CountText(const AText, APart: string): Integer;
var
  LAt: Integer;
begin
  Result := 0;
  LAt := Pos(APart, AText);
  while LAt > 0 do
  begin
    Inc(Result);
    LAt := PosEx(APart, AText, LAt + Length(APart));
  end;
end;

procedure RequireSafeChildRedraw(const ASource, ASignature, ARedraw: string;
  const ARequireParentHandle: Boolean = True;
  const ARequireRuntimeGuard: Boolean = False);
var
  LBody: string;
  LGuard: Integer;
  LRedrawAt: Integer;
  LPrefix: string;
begin
  LBody := SourceProcedureBody(ASource, ASignature);
  Require(CountText(LBody, ARedraw) = 1,
    'Redraw deve ter uma unica ocorrencia no procedimento auditado: ' + ASignature);
  LRedrawAt := Pos(ARedraw, LBody);
  LPrefix := Copy(LBody, 1, LRedrawAt - 1);
  LGuard := Pos('not (csdesigning in componentstate)', LPrefix);
  Require((LGuard > 0) and (Pos('(parent <> nil)', LPrefix) > 0) and
    (Pos('handleallocated', LPrefix) > 0) and
    ((not ARequireParentHandle) or (Pos('parent.handleallocated', LPrefix) > 0)) and
    ((not ARequireRuntimeGuard) or
      ((Pos('csloading in componentstate', LPrefix) > 0) and
       (Pos('csdestroying in componentstate', LPrefix) > 0))),
    'Redraw Skia sem guard completo de designer/parent/handles: ' + ASignature);
end;

procedure RequireSafeTooltipPresentation(const ASource, AOperation: string;
  const ARequireCurrentParent: Boolean);
var
  LBody: string;
  LOperationAt: Integer;
  LPrefix: string;
begin
  LBody := SourceProcedureBody(ASource,
    'procedure tdactooltip.showfortargetinternal(');
  Require(CountText(LBody, AOperation) = 1,
    'Apresentacao do Tooltip deve ter uma unica operacao auditada: ' + AOperation);
  LOperationAt := Pos(AOperation, LBody);
  LPrefix := Copy(LBody, 1, LOperationAt - 1);
  Require((Pos('csloading in componentstate', LPrefix) > 0) and
    (Pos('csdestroying in componentstate', LPrefix) > 0) and
    (Pos('csdesigning in componentstate', LPrefix) > 0) and
    (Pos('handleallocated', LPrefix) > 0) and
    ((not ARequireCurrentParent) or
      (Pos('parent.handleallocated', LPrefix) > 0)) and
    (ARequireCurrentParent or (Pos('lparent.handleallocated', LPrefix) > 0)),
    'Apresentacao do Tooltip sem guard de lifecycle/parent/handles: ' + AOperation);
end;

procedure RequireSafeChildLayout(const ASource, ASignature, AOperation: string);
var
  LBody: string;
  LOperationAt: Integer;
  LPrefix: string;
begin
  LBody := SourceProcedureBody(ASource, ASignature);
  Require(CountText(LBody, AOperation) = 1,
    'Layout deve ter uma unica operacao auditada: ' + ASignature);
  LOperationAt := Pos(AOperation, LBody);
  LPrefix := Copy(LBody, 1, LOperationAt - 1);
  Require((Pos('csdesigning in componentstate', LPrefix) > 0) and
    (Pos('csdestroying in componentstate', LPrefix) > 0) and
    (Pos('parent', LPrefix) > 0) and (Pos('handleallocated', LPrefix) > 0) and
    (Pos('parent.handleallocated', LPrefix) > 0),
    'Layout Skia sem guard completo de designer/parent/handles: ' + ASignature);
end;

procedure RequireDesignSafeGraphicChildLayout(const ASource, ASignature,
  AOperation: string);
var
  LBody: string;
  LOperationAt: Integer;
  LPrefix: string;
begin
  LBody := SourceProcedureBody(ASource, ASignature);
  Require(CountText(LBody, AOperation) = 1,
    'Layout grafico deve ter uma unica operacao auditada: ' + ASignature);
  LOperationAt := Pos(AOperation, LBody);
  LPrefix := Copy(LBody, 1, LOperationAt - 1);
  Require((Pos('csloading in componentstate', LPrefix) > 0) and
    (Pos('csdestroying in componentstate', LPrefix) > 0) and
    (Pos('handleallocated', LBody) = 0) and
    (Pos('csdesigning in componentstate', LBody) = 0),
    'Layout de TGraphicControl nao permaneceu visivel e seguro no designer: ' +
      ASignature);
end;

procedure RequireSafeLayoutOperation(const ASource, ASignature, AOperation: string);
var
  LBody: string;
  LOperationAt: Integer;
  LPrefix: string;
begin
  LBody := SourceProcedureBody(ASource, ASignature);
  LOperationAt := Pos(AOperation, LBody);
  Require(LOperationAt > 0,
    'Operacao de layout ausente para auditoria: ' + ASignature);
  LPrefix := Copy(LBody, 1, LOperationAt - 1);
  Require((Pos('csloading in componentstate', LPrefix) > 0) and
    (Pos('csdestroying in componentstate', LPrefix) > 0) and
    (Pos('csdesigning in componentstate', LPrefix) > 0) and
    (Pos('parent', LPrefix) > 0) and (Pos('handleallocated', LPrefix) > 0) and
    (Pos('parent.handleallocated', LPrefix) > 0),
    'Layout Skia sem guard de runtime completo: ' + ASignature);
end;

procedure RequireL3PainterTokenization;
const
  PainterFiles: array[0..9] of string = (
    'Badges.pas', 'Charts.pas', 'DataGrid.pas', 'Loading.pas', 'Progress.pas',
    'ReportViewer.pas', 'Selectors.pas', 'StatusBar.pas', 'SummaryCard.pas',
    'Tabs.pas');
  LiteralVisuals: array[0..3] of string = ('255', '0.5', 'lscale := 1', 'clwhite');
var
  I: Integer;
  J: Integer;
  LPath: string;
  LRoot: string;
  LSource: string;
begin
  LRoot := ExpandFileName(TPath.Combine(ExtractFilePath(ParamStr(0)),
    '..\..\..\..\..\Source\Controls'));
  for I := Low(PainterFiles) to High(PainterFiles) do
  begin
    LPath := TPath.Combine(LRoot, 'DAC.Components.Controls.' + PainterFiles[I]);
    Require(TFile.Exists(LPath), 'Painter L3 ausente: ' + PainterFiles[I]);
    LSource := LowerCase(TFile.ReadAllText(LPath));
    for J := Low(LiteralVisuals) to High(LiteralVisuals) do
      Require(Pos(LiteralVisuals[J], LSource) = 0,
        'Painter L3 ainda contem literal visual: ' + PainterFiles[I] +
        ' / ' + LiteralVisuals[J]);
  end;
end;

procedure RequireDesignSafeSkiaRedraws;
var
  LRoot: string;
  LPath: string;
  LSource: string;
  LPagination: string;
begin
  RequireL3PainterTokenization;
  LRoot := ExpandFileName(TPath.Combine(ExtractFilePath(ParamStr(0)),
    '..\..\..\..\..'));
  LPath := TPath.Combine(LRoot, 'Source\Controls\DAC.Components.Controls.StatusBar.pas');
  Require(TFile.Exists(LPath), 'Fonte do StatusBar ausente para auditoria de designer.');
  LSource := LowerCase(TFile.ReadAllText(LPath));
  RequireSafeChildRedraw(LSource, 'procedure tdacstatusbar.redraw;', 'fpaintbox.redraw');
  RequireSafeChildLayout(LSource, 'procedure tdacstatusbar.updatepaintboxbounds;',
    'fpaintbox.setbounds');
  LPath := TPath.Combine(LRoot, 'Source\Controls\DAC.Components.Controls.Container.pas');
  LSource := LowerCase(TFile.ReadAllText(LPath));
  RequireSafeChildRedraw(LSource, 'procedure tdaccontainer.redraw;', 'fpaintbox.redraw');
  RequireDesignSafeGraphicChildLayout(LSource,
    'procedure tdaccontainer.updateheaderlabels;',
    'ftitlelabel.setbounds');
  RequireSafeChildLayout(LSource, 'procedure tdaccontainer.updatepaintboxbounds;',
    'fpaintbox.setbounds');
  LPath := TPath.Combine(LRoot, 'Source\Controls\DAC.Components.Controls.GridContainer.pas');
  LSource := LowerCase(TFile.ReadAllText(LPath));
  RequireSafeChildRedraw(LSource, 'procedure tdacgridcontainer.redrawchrome;', 'fpaintbox.redraw');
  RequireSafeChildLayout(LSource, 'procedure tdacgridcontainer.arrangechildren;',
    'lchild.setbounds');
  RequireSafeChildLayout(LSource, 'procedure tdacgridcontainer.updatechromebounds;',
    'fpaintbox.setbounds');
  LPath := TPath.Combine(LRoot, 'Source\Controls\DAC.Components.Controls.SummaryCard.pas');
  LSource := LowerCase(TFile.ReadAllText(LPath));
  RequireSafeChildRedraw(LSource, 'procedure tdacsummarycard.redraw;', 'fpaintbox.redraw');
  RequireSafeChildLayout(LSource, 'procedure tdacsummarycard.updatepaintboxbounds;',
    'fpaintbox.setbounds');
  LPath := TPath.Combine(LRoot, 'Source\Controls\DAC.Components.Controls.Badges.pas');
  LSource := LowerCase(TFile.ReadAllText(LPath));
  RequireSafeChildLayout(LSource, 'procedure tdacbadge.updatepaintboxbounds;',
    'fpaintbox.setbounds');
  RequireSafeChildRedraw(LSource, 'procedure tdacbadge.invalidatebadge;', 'fpaintbox.redraw');
  LPath := TPath.Combine(LRoot, 'Source\Controls\DAC.Components.Controls.Charts.pas');
  LSource := LowerCase(TFile.ReadAllText(LPath));
  Require((Pos('tskpaintbox', LSource) = 0) and (Pos('fpaintbox', LSource) = 0),
    'TDACChart deve desenhar no proprio controle, sem TSkPaintBox filho.');
  LPath := TPath.Combine(LRoot, 'Source\Controls\DAC.Components.Controls.Feedback.pas');
  LSource := LowerCase(TFile.ReadAllText(LPath));
  RequireSafeChildRedraw(LSource, 'procedure tdactoast.redraw;', 'fpaintbox.redraw');
  RequireSafeChildLayout(LSource, 'procedure tdactoast.updatepaintboxbounds;',
    'fpaintbox.setbounds');
  RequireSafeChildRedraw(LSource, 'procedure tdactooltip.resize;', 'fpaintbox.redraw',
    True, True);
  RequireSafeChildRedraw(LSource, 'procedure tdactooltip.settext(', 'fpaintbox.redraw',
    True, True);
  RequireSafeChildRedraw(LSource, 'procedure tdactooltip.showfortargetinternal(',
    'fpaintbox.redraw', True, True);
  RequireSafeChildRedraw(LSource, 'procedure tdactooltip.themechanged(',
    'fpaintbox.redraw', True, True);
  RequireSafeChildLayout(LSource, 'procedure tdactooltip.updatepaintboxbounds;',
    'fpaintbox.setbounds');
  Require(Pos('csloading in componentstate', SourceProcedureBody(LSource,
    'procedure tdactooltip.updatepaintboxbounds;')) > 0,
    'TDAC Tooltip deve bloquear SetBounds do paintbox durante loading.');
  RequireSafeTooltipPresentation(LSource, 'parent := lparent', False);
  RequireSafeTooltipPresentation(LSource, 'setbounds(', True);
  LPath := TPath.Combine(LRoot, 'Source\Controls\DAC.Components.Controls.Pagination.pas');
  LPagination := LowerCase(TFile.ReadAllText(LPath));
  RequireSafeChildRedraw(LPagination, 'procedure tdacpagination.redraw;', 'fpaintbox.redraw');
  RequireSafeChildRedraw(LPagination, 'procedure tdacpagination.redraw;', 'fbuttons[i].redraw');
  RequireSafeChildRedraw(LPagination, 'procedure tdacpagination.redraw;', 'fpagesizecombo.redraw');
  RequireSafeChildLayout(LPagination, 'procedure tdacpagination.updatelayout;',
    'fbuttons[i].setbounds');
  RequireSafeChildLayout(LPagination, 'procedure tdacpagination.updatepaintboxbounds;',
    'fpaintbox.setbounds');
  LPath := TPath.Combine(LRoot, 'Source\Controls\DAC.Components.Controls.ScrollContainer.pas');
  LSource := LowerCase(TFile.ReadAllText(LPath));
  RequireSafeChildRedraw(LSource, 'procedure tdacscrollcontainer.redrawchrome;',
    'fpaintbox.redraw');
  RequireSafeChildRedraw(LSource, 'procedure tdacscrollcontainer.redrawchrome;',
    'fpaintbox.update');
  RequireSafeChildLayout(LSource, 'procedure tdacscrollcontainer.updatechromebounds;',
    'fpaintbox.align :=');
  LPath := TPath.Combine(LRoot, 'Source\Controls\DAC.Components.Controls.Selectors.pas');
  LSource := LowerCase(TFile.ReadAllText(LPath));
  RequireSafeChildRedraw(LSource, 'procedure tdacselector.invalidateselector;', 'fpaintbox.redraw');
  RequireSafeChildRedraw(LSource, 'procedure tdacslider.invalidateslider;', 'fpaintbox.redraw');
  RequireSafeChildLayout(LSource, 'procedure tdacselector.updatepaintboxbounds;',
    'fpaintbox.setbounds');
  RequireSafeChildLayout(LSource, 'procedure tdacslider.updatepaintboxbounds;',
    'fpaintbox.setbounds');
  LPath := TPath.Combine(LRoot, 'Source\Controls\DAC.Components.Controls.DateTimePicker.pas');
  LSource := LowerCase(TFile.ReadAllText(LPath));
  RequireSafeChildRedraw(LSource, 'procedure tdacdatetimepicker.redraw;', 'fpaintbox.redraw');
  LPath := TPath.Combine(LRoot, 'Source\Controls\DAC.Components.Controls.Memo.pas');
  LSource := LowerCase(TFile.ReadAllText(LPath));
  RequireSafeChildRedraw(LSource, 'procedure tdacmemo.redraw;', 'fpaintbox.redraw');
  Require(Pos('csdestroying in componentstate',
    SourceProcedureBody(LSource, 'procedure tdacmemo.redraw;')) > 0,
    'TDACMemo.Redraw deve bloquear o filho Skia durante destruicao.');
  LPath := TPath.Combine(LRoot, 'Source\Controls\DAC.Components.Controls.Edit.pas');
  LSource := LowerCase(TFile.ReadAllText(LPath));
  RequireSafeChildRedraw(LSource, 'procedure tdacedit.redraw;', 'fpaintbox.redraw');
  RequireSafeChildLayout(LSource, 'procedure tdacedit.updatechildbounds;',
    'fedit.setbounds');
  RequireSafeChildLayout(LSource, 'procedure tdacedit.updatepaintboxbounds;',
    'fpaintbox.setbounds');
  Require(Pos('csdestroying in componentstate',
    SourceProcedureBody(LSource, 'procedure tdacedit.redraw;')) > 0,
    'TDACEdit.Redraw deve bloquear o filho Skia durante destruicao.');
  LPath := TPath.Combine(LRoot, 'Source\Controls\DAC.Components.Controls.ComboBox.pas');
  LSource := LowerCase(TFile.ReadAllText(LPath));
  RequireSafeChildRedraw(LSource, 'procedure tdaccombobox.redraw;', 'fpaintbox.redraw');
  Require(Pos('csdestroying in componentstate',
    SourceProcedureBody(LSource, 'procedure tdaccombobox.redraw;')) > 0,
    'TDACComboBox.Redraw deve bloquear o filho Skia durante destruicao.');
  LPath := TPath.Combine(LRoot, 'Source\Controls\DAC.Components.Controls.ButtonEdit.pas');
  LSource := LowerCase(TFile.ReadAllText(LPath));
  RequireSafeLayoutOperation(LSource, 'procedure tdacbuttonedit.updatechildbounds;',
    'fedit.setbounds');
  RequireSafeChildRedraw(LSource, 'procedure tdacbuttonedit.setbounds(',
    'fedit.redraw', True, True);
  Require((Pos('buttoneditdefaultwidth', LSource) > 0) and
    (Pos('inputfocusborderwidth', LSource) > 0) and
    (Pos('buttoneditdividerwidth', LSource) = 0) and
    (Pos('buttoneditbuttoncornerradius', LSource) > 0) and
    (Pos('fbutton.thememode := avalue', LSource) > 0),
    'ButtonEdit deve preservar o inset da borda externa sem misturar o divisor nos bounds.');
  LPath := TPath.Combine(LRoot, 'Source\Controls\DAC.Components.Controls.Button.pas');
  LSource := LowerCase(TFile.ReadAllText(LPath));
  RequireSafeChildRedraw(LSource, 'procedure tdacbutton.redraw;', 'fpaintbox.redraw');
  RequireSafeChildLayout(LSource, 'procedure tdacbutton.updatepaintboxbounds;',
    'fpaintbox.setbounds');
  Require(Pos('csdestroying in componentstate',
    SourceProcedureBody(LSource, 'procedure tdacbutton.redraw;')) > 0,
    'TDACButton.Redraw deve bloquear o filho Skia durante destruicao.');
  LPath := TPath.Combine(LRoot, 'Source\Controls\DAC.Components.Controls.DateTimePickerPopup.pas');
  LSource := LowerCase(TFile.ReadAllText(LPath));
  Require((Pos('csdesigning in componentstate',
    SourceProcedureBody(LSource, 'procedure tdacdatetimepickerpopup.applythememode')) > 0) and
    (Pos('csdestroying in componentstate',
    SourceProcedureBody(LSource, 'procedure tdacdatetimepickerpopup.keydown')) > 0) and
    (Pos('csdestroying in componentstate',
    SourceProcedureBody(LSource, 'procedure tdacdatetimepickerpopup.paintboxmouseup')) > 0) and
    (Pos('windowhandle <> 0', LSource) > 0),
    'Popup DateTime deve proteger redraw em designer/destruicao/handle.');
  LPath := TPath.Combine(LRoot, 'Source\Controls\DAC.Components.Controls.DataGrid.pas');
  LSource := LowerCase(TFile.ReadAllText(LPath));
  RequireSafeChildRedraw(LSource, 'procedure tdacdatagrid.invalidatepaintrect(',
    'fpaintbox.redraw', True, True);
  RequireSafeChildRedraw(LSource, 'procedure tdacdatagrid.redraw;',
    'fpaintbox.redraw', True, True);
  RequireSafeChildLayout(LSource, 'procedure tdacdatagrid.updatepaintboxbounds;',
    'fpaintbox.setbounds');
  LPath := TPath.Combine(LRoot, 'Source\Controls\DAC.Components.Controls.Loading.pas');
  LSource := LowerCase(TFile.ReadAllText(LPath));
  RequireSafeChildRedraw(LSource, 'procedure tdacloading.invalidateloading;',
    'fpaintbox.redraw', True, True);
  RequireSafeChildRedraw(LSource, 'procedure tdacloading.redraw;',
    'fpaintbox.redraw', True, True);
  RequireSafeChildLayout(LSource, 'procedure tdacloading.updatepaintboxbounds;',
    'fpaintbox.setbounds');
  LPath := TPath.Combine(LRoot, 'Source\Controls\DAC.Components.Controls.Progress.pas');
  LSource := LowerCase(TFile.ReadAllText(LPath));
  RequireSafeChildRedraw(LSource, 'procedure tdacprogress.invalidateprogress;',
    'fpaintbox.redraw', True, True);
  RequireSafeChildLayout(LSource, 'procedure tdacprogress.updatepaintboxbounds;',
    'fpaintbox.setbounds');
  LPath := TPath.Combine(LRoot, 'Source\Controls\DAC.Components.Controls.ReportViewer.pas');
  LSource := LowerCase(TFile.ReadAllText(LPath));
  RequireSafeChildLayout(LSource, 'procedure tdacreportviewer.updatepaintboxbounds;',
    'fpaintbox.setbounds');
  LPath := TPath.Combine(LRoot, 'Source\Controls\DAC.Components.Controls.Tabs.pas');
  LSource := LowerCase(TFile.ReadAllText(LPath));
  RequireSafeLayoutOperation(LSource, 'procedure tdactabs.layoutpagecontent;',
    'lcontrol.setbounds');
  RequireSafeLayoutOperation(LSource, 'procedure tdactabs.updateheaderbounds;',
    'fheader.setbounds');
  LPath := TPath.Combine(LRoot, 'Source\Controls\DAC.Components.Controls.SkiaControl.pas');
  LSource := LowerCase(TFile.ReadAllText(LPath));
  RequireSafeChildRedraw(LSource, 'procedure tdacskiacontrol.redraw;', 'fpaintbox.redraw');
end;

procedure PumpMessages(const AMilliseconds: Cardinal = 100);
var
  LStart: Cardinal;
begin
  LStart := GetTickCount;
  repeat
    Application.ProcessMessages;
  until Cardinal(GetTickCount - LStart) >= AMilliseconds;
end;

procedure RequireScrollStyleHookRuntime(const AForm: TForm1);
type
  TScrollTestZone = (
    stzOutsideBefore,
    stzArrowDecrement,
    stzPageBefore,
    stzThumb,
    stzPageAfter,
    stzArrowIncrement,
    stzOutsideAfter
  );
const
  WM_NCMOUSELEAVE_VALUE = $02A2;
  ScrollTestZoneNames: array[TScrollTestZone] of string = (
    'outside-before',
    'arrow-decrement',
    'page-before',
    'thumb',
    'page-after',
    'arrow-increment',
    'outside-after'
  );
var
  I: Integer;
  LBeforeHorizontal: TDACScrollHookPaintInfo;
  LBeforeVertical: TDACScrollHookPaintInfo;
  LContent: TPanel;
  LHorizontalIntermediate: Integer;
  LHorizontalStart: Integer;
  LHorizontalEnd: Integer;
  LHook: TScrollHookAccess;
  LOldCursor: TPoint;
  LScroll: TDACScrollContainer;
  LScrollHandle: HWND;
  LTokens: TDACControlTokens;
  LVerticalIntermediate: Integer;
  LVerticalStart: Integer;
  LVerticalEnd: Integer;
  LWheelPoint: TPoint;

  function CenterOf(const ARect: TRect): TPoint;
  begin
    Result := Point((ARect.Left + ARect.Right) div 2,
      (ARect.Top + ARect.Bottom) div 2);
  end;

  function ClientPointToScreen(const APoint: TPoint): TPoint;
  begin
    Result := APoint;
    Winapi.Windows.ClientToScreen(LScroll.Handle, Result);
  end;

  function MessagePoint(const APoint: TPoint): LPARAM;
  begin
    Result := LPARAM(MakeLong(Word(APoint.X), Word(APoint.Y)));
  end;

  procedure ResetObservedPaint;
  begin
    ScrollHookHorizontalPaintCount := 0;
    ScrollHookVerticalPaintCount := 0;
    FillChar(ScrollHookHorizontalPaint, SizeOf(ScrollHookHorizontalPaint), 0);
    FillChar(ScrollHookVerticalPaint, SizeOf(ScrollHookVerticalPaint), 0);
  end;

  procedure ForceHookPaint(const AContext: string);
  begin
    RedrawWindow(LScroll.Handle, nil, 0, RDW_INVALIDATE or RDW_ERASE or
      RDW_FRAME or RDW_ALLCHILDREN or RDW_ERASENOW or RDW_UPDATENOW);
    UpdateWindow(LScroll.Handle);
    LHook.PaintNonClient;
    PumpMessages(30);
    Require((ScrollHookVerticalPaintCount > 0) and
      (ScrollHookHorizontalPaintCount > 0),
      Format('%s: hook localizado nao apresentou ambos os eixos ' +
        '(vertPaint=%d horzPaint=%d vertRange=%d horzRange=%d client=%dx%d).',
        [AContext, ScrollHookVerticalPaintCount,
         ScrollHookHorizontalPaintCount, LScroll.VertScrollBar.Range,
         LScroll.HorzScrollBar.Range, LScroll.ClientWidth,
         LScroll.ClientHeight]));
    Require(ScrollHookVerticalPaint.RenderedWithSkia and
      ScrollHookVerticalPaint.PresentedWithBitBlt and
      ScrollHookHorizontalPaint.RenderedWithSkia and
      ScrollHookHorizontalPaint.PresentedWithBitBlt,
      AContext + ': paint runtime nao confirmou Skia + apresentacao BitBlt.');
  end;

  procedure RequireObserverReentrancy;
  var
    LNotificationsAfterReentry: Integer;
  begin
    ResetObservedPaint;
    ScrollHookRepaintAttempted := False;
    ScrollHookRepaintOnNextNotification := True;
    ScrollHookSynchronousRepaint :=
      procedure
      begin
        LHook.PaintAxisNonClient(True);
      end;
    try
      LHook.PaintAxisNonClient(True);
    finally
      ScrollHookRepaintOnNextNotification := False;
      ScrollHookSynchronousRepaint := nil;
    end;
    Require(ScrollHookRepaintAttempted,
      'Observer nao provocou o repaint sincrono planejado.');
    Require((ScrollHookVerticalPaintCount = 1) and
      (ScrollHookHorizontalPaintCount = 0),
      Format('Guarda reentrante permitiu notificacao recursiva ' +
        '(vertical=%d horizontal=%d).',
        [ScrollHookVerticalPaintCount, ScrollHookHorizontalPaintCount]));
    Require((ScrollHookVerticalPaint.ControlHandle = LScroll.Handle) and
      (ScrollHookVerticalPaint.Axis = shaVertical) and
      ScrollHookVerticalPaint.RenderedWithSkia and
      ScrollHookVerticalPaint.PresentedWithBitBlt,
      'Repaint reentrante sobrescreveu ou perdeu o estado externo observado.');
    LNotificationsAfterReentry := ScrollHookVerticalPaintCount;
    LHook.PaintAxisNonClient(True);
    Require(ScrollHookVerticalPaintCount =
      LNotificationsAfterReentry + 1,
      'Observer permaneceu bloqueado apos sair do repaint reentrante.');
  end;

  procedure RequireAxisGeometry(const AInfo: TDACScrollHookPaintInfo;
    const AVertical: Boolean; const AContext: string);
  var
    LPoint: TPoint;
    LExpectedHit: LRESULT;
  begin
    Require(not IsRectEmpty(AInfo.ScrollRect) and
      not IsRectEmpty(AInfo.SliderRect) and
      not IsRectEmpty(AInfo.StartButtonRect) and
      not IsRectEmpty(AInfo.EndButtonRect),
      AContext + ': geometria vazia.');
    Require(AInfo.ScrollRect.Contains(AInfo.SliderRect.TopLeft) and
      AInfo.ScrollRect.Contains(Point(AInfo.SliderRect.Right - 1,
        AInfo.SliderRect.Bottom - 1)) and
      AInfo.ScrollRect.Contains(AInfo.StartButtonRect.TopLeft) and
      AInfo.ScrollRect.Contains(Point(AInfo.EndButtonRect.Right - 1,
        AInfo.EndButtonRect.Bottom - 1)),
      AContext + ': thumb/arrows escaparam do scroll rect.');
    if AVertical then
    begin
      Require((AInfo.StartButtonRect.Bottom <= AInfo.SliderRect.Top) and
        (AInfo.SliderRect.Bottom <= AInfo.EndButtonRect.Top),
        AContext + ': ordem vertical track/thumb/arrows incoerente.');
      LExpectedHit := HTVSCROLL;
    end
    else
    begin
      Require((AInfo.StartButtonRect.Right <= AInfo.SliderRect.Left) and
        (AInfo.SliderRect.Right <= AInfo.EndButtonRect.Left),
        AContext + ': ordem horizontal track/thumb/arrows incoerente.');
      LExpectedHit := HTHSCROLL;
    end;
    LPoint := ClientPointToScreen(CenterOf(AInfo.StartButtonRect));
    Require(SendMessage(LScroll.Handle, WM_NCHITTEST, 0,
      MessagePoint(LPoint)) = LExpectedHit,
      AContext + ': hit-test falhou na arrow decrement.');
    LPoint := ClientPointToScreen(CenterOf(AInfo.SliderRect));
    Require(SendMessage(LScroll.Handle, WM_NCHITTEST, 0,
      MessagePoint(LPoint)) = LExpectedHit,
      AContext + ': hit-test falhou no thumb.');
    LPoint := ClientPointToScreen(CenterOf(AInfo.EndButtonRect));
    Require(SendMessage(LScroll.Handle, WM_NCHITTEST, 0,
      MessagePoint(LPoint)) = LExpectedHit,
      AContext + ': hit-test falhou na arrow increment.');
  end;

  procedure SendNonClientMouse(const AMessage: Cardinal;
    const AHitCode: WPARAM; const AClientPoint: TPoint);
  var
    LScreenPoint: TPoint;
  begin
    LScreenPoint := ClientPointToScreen(AClientPoint);
    SetCursorPos(LScreenPoint.X, LScreenPoint.Y);
    LHook.ProcessHookMessage(AMessage, AHitCode,
      MessagePoint(LScreenPoint));
    PumpMessages(20);
  end;

  procedure RequireSevenZones(const AInfo: TDACScrollHookPaintInfo;
    const AVertical, ARequireCompactPages: Boolean;
    const AContext: string);
  var
    LBeforeEndState: TThemedScrollBar;
    LBeforeHorizontalPosition: Integer;
    LBeforeSliderState: TThemedScrollBar;
    LBeforeStartState: TThemedScrollBar;
    LBeforeVerticalPosition: Integer;
    LExpectedHit: LRESULT;
    LHit: LRESULT;
    LPageAfter: TRect;
    LPageAfterLength: Integer;
    LPageBefore: TRect;
    LPageBeforeLength: Integer;
    LPoints: array[TScrollTestZone] of TPoint;
    LZone: TScrollTestZone;
    LOtherZone: TScrollTestZone;
  begin
    if AVertical then
    begin
      LPageBefore := Rect(AInfo.ScrollRect.Left,
        AInfo.StartButtonRect.Bottom, AInfo.ScrollRect.Right,
        AInfo.SliderRect.Top);
      LPageAfter := Rect(AInfo.ScrollRect.Left, AInfo.SliderRect.Bottom,
        AInfo.ScrollRect.Right, AInfo.EndButtonRect.Top);
      LPageBeforeLength := LPageBefore.Height;
      LPageAfterLength := LPageAfter.Height;
    end
    else
    begin
      LPageBefore := Rect(AInfo.StartButtonRect.Right,
        AInfo.ScrollRect.Top, AInfo.SliderRect.Left,
        AInfo.ScrollRect.Bottom);
      LPageAfter := Rect(AInfo.SliderRect.Right, AInfo.ScrollRect.Top,
        AInfo.EndButtonRect.Left, AInfo.ScrollRect.Bottom);
      LPageBeforeLength := LPageBefore.Width;
      LPageAfterLength := LPageAfter.Width;
    end;
    Require(not IsRectEmpty(LPageBefore) and not IsRectEmpty(LPageAfter),
      AContext + ': page-before/page-after precisam existir na posicao media.');
    if ARequireCompactPages then
      Require((LPageBeforeLength <= 16) and (LPageAfterLength <= 16),
        Format('%s: range curto nao produziu paginas minimas distintas ' +
          '(before=%d after=%d).',
          [AContext, LPageBeforeLength, LPageAfterLength]));

    LPoints[stzArrowDecrement] := CenterOf(AInfo.StartButtonRect);
    LPoints[stzPageBefore] := CenterOf(LPageBefore);
    LPoints[stzThumb] := CenterOf(AInfo.SliderRect);
    LPoints[stzPageAfter] := CenterOf(LPageAfter);
    LPoints[stzArrowIncrement] := CenterOf(AInfo.EndButtonRect);
    if AVertical then
    begin
      LPoints[stzOutsideBefore] := Point(
        (AInfo.ScrollRect.Left + AInfo.ScrollRect.Right) div 2,
        AInfo.ScrollRect.Top - AInfo.ScrollRect.Height - 8);
      LPoints[stzOutsideAfter] := Point(
        (AInfo.ScrollRect.Left + AInfo.ScrollRect.Right) div 2,
        AInfo.ScrollRect.Bottom + AInfo.ScrollRect.Height + 8);
    end
    else
    begin
      LPoints[stzOutsideBefore] := Point(
        AInfo.ScrollRect.Left - AInfo.ScrollRect.Width - 8,
        (AInfo.ScrollRect.Top + AInfo.ScrollRect.Bottom) div 2);
      LPoints[stzOutsideAfter] := Point(
        AInfo.ScrollRect.Right + AInfo.ScrollRect.Width + 8,
        (AInfo.ScrollRect.Top + AInfo.ScrollRect.Bottom) div 2);
    end;

    for LZone := Low(TScrollTestZone) to High(TScrollTestZone) do
      if LZone <> High(TScrollTestZone) then
        for LOtherZone := Succ(LZone) to High(TScrollTestZone) do
          Require((LPoints[LZone].X <> LPoints[LOtherZone].X) or
            (LPoints[LZone].Y <> LPoints[LOtherZone].Y),
            AContext + ': zonas duplicadas ' + ScrollTestZoneNames[LZone] +
              '/' + ScrollTestZoneNames[LOtherZone] + '.');

    for LZone := Low(TScrollTestZone) to High(TScrollTestZone) do
    begin
      LBeforeHorizontalPosition := LScroll.HorzScrollBar.Position;
      LBeforeVerticalPosition := LScroll.VertScrollBar.Position;
      LBeforeSliderState := LHook.SliderStateForAxis(AVertical);
      LBeforeStartState := LHook.StartButtonStateForAxis(AVertical);
      LBeforeEndState := LHook.EndButtonStateForAxis(AVertical);
      ScrollHookHorizontalPaintCount := 0;
      ScrollHookVerticalPaintCount := 0;
      LHit := SendMessage(LScroll.Handle, WM_NCHITTEST, 0,
        MessagePoint(ClientPointToScreen(LPoints[LZone])));
      if LZone in [stzOutsideBefore, stzOutsideAfter] then
        LExpectedHit := LRESULT(Winapi.Windows.HTNOWHERE)
      else if AVertical then
        LExpectedHit := LRESULT(Winapi.Windows.HTVSCROLL)
      else
        LExpectedHit := LRESULT(Winapi.Windows.HTHSCROLL);
      Require(LHit = LExpectedHit,
        Format('%s/%s: WM_NCHITTEST retornou %d, esperado %d.',
          [AContext, ScrollTestZoneNames[LZone], LHit, LExpectedHit]));
      if LZone in [stzOutsideBefore, stzOutsideAfter] then
      begin
        PumpMessages(10);
        Require((LScroll.HorzScrollBar.Position =
            LBeforeHorizontalPosition) and
          (LScroll.VertScrollBar.Position = LBeforeVerticalPosition),
          AContext + '/' + ScrollTestZoneNames[LZone] +
            ': outside alterou Position.');
        Require((LHook.SliderStateForAxis(AVertical) =
            LBeforeSliderState) and
          (LHook.StartButtonStateForAxis(AVertical) =
            LBeforeStartState) and
          (LHook.EndButtonStateForAxis(AVertical) =
            LBeforeEndState),
          AContext + '/' + ScrollTestZoneNames[LZone] +
            ': outside alterou estado do hook.');
        Require((ScrollHookHorizontalPaintCount = 0) and
          (ScrollHookVerticalPaintCount = 0),
          AContext + '/' + ScrollTestZoneNames[LZone] +
            ': outside provocou paint observado.');
      end;
    end;
  end;

  procedure DragVerticalThumb;
  var
    LDelta: Integer;
    LPoint: TPoint;
  begin
    LScroll.Perform(WM_VSCROLL, SB_TOP, 0);
    PumpMessages(20);
    ResetObservedPaint;
    ForceHookPaint('vertical normal');
    LTokens := TDACComponentStyle.Resolve(
      TDACThemeManager.ApplicationMode).Tokens.Controls;
    Require((ScrollHookVerticalPaint.SliderState =
        tsThumbBtnVertNormal) and
      (ScrollHookVerticalPaint.SliderColor = LTokens.ScrollBarThumb),
      'Thumb vertical normal nao resolveu ScrollBarThumb.');
    LPoint := CenterOf(ScrollHookVerticalPaint.SliderRect);
    SendNonClientMouse(WM_NCMOUSEMOVE, HTVSCROLL, LPoint);
    ResetObservedPaint;
    ForceHookPaint('vertical hot');
    Require((ScrollHookVerticalPaint.SliderState =
        tsThumbBtnVertHot) and
      (ScrollHookVerticalPaint.SliderColor = LTokens.ScrollBarThumbHot),
      'Thumb vertical hot nao resolveu ScrollBarThumbHot.');
    LVerticalStart := LScroll.VertScrollBar.Position;
    SendNonClientMouse(WM_NCLBUTTONDOWN, HTVSCROLL, LPoint);
    ResetObservedPaint;
    ForceHookPaint('vertical pressed');
    Require((ScrollHookVerticalPaint.SliderState =
        tsThumbBtnVertPressed) and
      (ScrollHookVerticalPaint.SliderColor =
        LTokens.ScrollBarThumbPressed) and
      (GetCapture = LScroll.Handle),
      'Thumb vertical pressed nao preservou token/capture.');

    // The CI desktop has no movable system cursor. Seed only the prior cursor
    // coordinate, then inject the real WM_MOUSEMOVE so TScrollingStyleHook
    // performs its production calculation, clamp and SB_THUMBTRACK path.
    LDelta := Max(8, ScrollHookVerticalPaint.ScrollRect.Height div 3);
    LHook.SeedMouseDragDelta(True, LDelta);
    LHook.ProcessHookMessage(WM_MOUSEMOVE, MK_LBUTTON,
      MakeLong(Word(LPoint.X), Word(LPoint.Y + LDelta)));
    PumpMessages(40);
    LVerticalIntermediate := LScroll.VertScrollBar.Position;
    Require(LVerticalIntermediate > LVerticalStart,
      Format('Drag vertical intermediario nao aumentou Position ' +
        '(start=%d intermediate=%d native=%d track=%d state=%d ' +
        'prev=%d internal=%.2f internalTrack=%d).',
        [LVerticalStart, LVerticalIntermediate,
         GetScrollPos(LScroll.Handle, SB_VERT),
         ScrollHookVerticalPaint.ScrollRect.Height,
         Ord(ScrollHookVerticalPaint.SliderState),
         LHook.InternalPreviousScrollPosition,
         LHook.InternalScrollPosition, LHook.VerticalTrackHeight]));

    LDelta := Max(LHook.VerticalTrackHeight * 2, 8);
    LHook.SeedMouseDragDelta(True, LDelta);
    LHook.ProcessHookMessage(WM_MOUSEMOVE, MK_LBUTTON,
      MakeLong(Word(LPoint.X), Word(LPoint.Y + LDelta)));
    PumpMessages(40);
    LVerticalEnd := LScroll.VertScrollBar.Position;
    Require((LVerticalEnd >= LVerticalIntermediate) and
      (LVerticalEnd <= LScroll.VertScrollBar.Range),
      'Drag vertical final nao foi monotono/clampado.');
    LHook.ProcessHookMessage(WM_LBUTTONUP, 0, 0);
    PumpMessages(40);
    Require((GetCapture <> LScroll.Handle) and
      (LContent.Top <= -LVerticalIntermediate),
      'Mouse up vertical nao liberou capture ou viewport nao acompanhou.');
  end;

  procedure DragHorizontalThumb;
  var
    LDelta: Integer;
    LPoint: TPoint;
  begin
    LScroll.Perform(WM_HSCROLL, SB_LEFT, 0);
    PumpMessages(20);
    ResetObservedPaint;
    ForceHookPaint('horizontal normal');
    Require((ScrollHookHorizontalPaint.SliderState =
        tsThumbBtnHorzNormal) and
      (ScrollHookHorizontalPaint.SliderColor = LTokens.ScrollBarThumb),
      'Thumb horizontal normal nao resolveu ScrollBarThumb.');
    LPoint := CenterOf(ScrollHookHorizontalPaint.SliderRect);
    SendNonClientMouse(WM_NCMOUSEMOVE, HTHSCROLL, LPoint);
    ResetObservedPaint;
    ForceHookPaint('horizontal hot');
    Require((ScrollHookHorizontalPaint.SliderState =
        tsThumbBtnHorzHot) and
      (ScrollHookHorizontalPaint.SliderColor = LTokens.ScrollBarThumbHot),
      'Thumb horizontal hot nao resolveu ScrollBarThumbHot.');
    LHorizontalStart := LScroll.HorzScrollBar.Position;
    SendNonClientMouse(WM_NCLBUTTONDOWN, HTHSCROLL, LPoint);
    ResetObservedPaint;
    ForceHookPaint('horizontal pressed');
    Require((ScrollHookHorizontalPaint.SliderState =
        tsThumbBtnHorzPressed) and
      (ScrollHookHorizontalPaint.SliderColor =
        LTokens.ScrollBarThumbPressed),
      'Thumb horizontal pressed nao resolveu ScrollBarThumbPressed.');
    LDelta := Max(8, ScrollHookHorizontalPaint.ScrollRect.Width div 3);
    LHook.SeedMouseDragDelta(False, LDelta);
    LHook.ProcessHookMessage(WM_MOUSEMOVE, MK_LBUTTON,
      MakeLong(Word(LPoint.X + LDelta), Word(LPoint.Y)));
    PumpMessages(40);
    LHorizontalIntermediate := LScroll.HorzScrollBar.Position;
    Require(LHorizontalIntermediate > LHorizontalStart,
      'Drag horizontal intermediario nao aumentou Position.');
    LDelta := Max(LHook.HorizontalTrackWidth * 2, 8);
    LHook.SeedMouseDragDelta(False, LDelta);
    LHook.ProcessHookMessage(WM_MOUSEMOVE, MK_LBUTTON,
      MakeLong(Word(LPoint.X + LDelta), Word(LPoint.Y)));
    PumpMessages(40);
    LHorizontalEnd := LScroll.HorzScrollBar.Position;
    Require((LHorizontalEnd >= LHorizontalIntermediate) and
      (LHorizontalEnd <= LScroll.HorzScrollBar.Range),
      'Drag horizontal final nao foi monotono/clampado.');
    LHook.ProcessHookMessage(WM_LBUTTONUP, 0, 0);
    PumpMessages(40);
    Require((GetCapture <> LScroll.Handle) and
      (LContent.Left <= -LHorizontalIntermediate),
      'Mouse up horizontal nao liberou capture ou viewport nao acompanhou.');
  end;

begin
  GetCursorPos(LOldCursor);
  LScroll := TDACScrollContainer.Create(AForm);
  LContent := TPanel.Create(LScroll);
  LHook := nil;
  LScrollHandle := 0;
  TDACScrollContainerStyleHook.SetPaintObserver(CaptureScrollHookPaint);
  try
    LScroll.Parent := AForm;
    { This probe is a direct form child. Keep it inside the responsive content
      column instead of underneath the demo's compact navigation rail. }
    LScroll.SetBounds(AForm.GalleryTabs.Left + 24, 88, 340, 230);
    LScroll.Appearance := mscaViewport;
    LScroll.HorzScrollBar.Visible := True;
    LScroll.VertScrollBar.Visible := True;
    Require(LScroll.HorzScrollBar.Tracking and
      LScroll.VertScrollBar.Tracking,
      'ScrollContainer deve acompanhar o thumb continuamente nos dois eixos.');
    LContent.Parent := LScroll;
    LContent.SetBounds(0, 0, 1200, 900);
    LContent.Caption := '';
    LContent.ParentColor := True;
    LScroll.BringToFront;
    PumpMessages(80);
    LScrollHandle := LScroll.Handle;
    LHook := TScrollHookAccess.Create(LScroll);
    ScrollHookTarget := LScrollHandle;
    ResetObservedPaint;
    ForceHookPaint('geometria inicial');
    RequireObserverReentrancy;
    ResetObservedPaint;
    ForceHookPaint('geometria apos observer reentrante');
    RequireAxisGeometry(ScrollHookVerticalPaint, True, 'vertical inicial');
    RequireAxisGeometry(ScrollHookHorizontalPaint, False,
      'horizontal inicial');

    LScroll.Perform(WM_VSCROLL,
      MakeLong(SB_THUMBPOSITION, LScroll.VertScrollBar.Range div 3), 0);
    LScroll.Perform(WM_HSCROLL,
      MakeLong(SB_THUMBPOSITION, LScroll.HorzScrollBar.Range div 3), 0);
    PumpMessages(50);
    ResetObservedPaint;
    ForceHookPaint('posicao media');
    RequireSevenZones(ScrollHookVerticalPaint, True, False,
      'vertical media');
    RequireSevenZones(ScrollHookHorizontalPaint, False, False,
      'horizontal media');

    DragVerticalThumb;
    DragHorizontalThumb;

    LScroll.Perform(WM_VSCROLL, SB_TOP, 0);
    LVerticalStart := LScroll.VertScrollBar.Position;
    Require(SetWindowPos(AForm.Handle, HWND_TOPMOST, 0, 0, 0, 0,
      SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE),
      'Nao foi possivel expor a janela real para o hit-test do wheel.');
    BringWindowToTop(AForm.Handle);
    SetForegroundWindow(AForm.Handle);
    LWheelPoint := ClientPointToScreen(Point(16, 16));
    SetCursorPos(LWheelPoint.X, LWheelPoint.Y);
    LScroll.SetFocus;
    PumpMessages(20);
    Require(GetFocus = LScroll.Handle,
      'ScrollContainer nao recebeu foco para a rota real de WM_MOUSEWHEEL.');
    LScroll.Perform(CM_MOUSEWHEEL, WPARAM($FF880000),
      MessagePoint(LWheelPoint));
    PumpMessages(30);
    Require(LScroll.VertScrollBar.Position > LVerticalStart,
      Format('Wheel real nao permaneceu funcional com o hook localizado (before=%d after=%d range=%d client=%d hit=%d scroll=%d child=%s foreground=%d form=%d).',
        [LVerticalStart, LScroll.VertScrollBar.Position,
         LScroll.VertScrollBar.Range, LScroll.ClientHeight,
         NativeInt(WindowFromPoint(LWheelPoint)),
         NativeInt(LScroll.Handle),
         BoolToStr(IsChild(LScroll.Handle, WindowFromPoint(LWheelPoint)), True),
         NativeInt(GetForegroundWindow), NativeInt(AForm.Handle)]));
    LVerticalStart := LScroll.VertScrollBar.Position;
    LHook.ProcessHookMessage(WM_VSCROLL, SB_PAGEDOWN, 0);
    PumpMessages(30);
    Require(LScroll.VertScrollBar.Position > LVerticalStart,
      'SB_PAGEDOWN nao permaneceu funcional com o hook localizado.');
    LScroll.Perform(WM_HSCROLL, SB_LEFT, 0);
    PumpMessages(20);
    LHorizontalStart := LScroll.HorzScrollBar.Position;
    LHook.ProcessHookMessage(WM_HSCROLL, SB_LINERIGHT, 0);
    PumpMessages(30);
    Require(LScroll.HorzScrollBar.Position > LHorizontalStart,
      'SB_LINERIGHT nao permaneceu funcional com o hook localizado.');

    LScroll.Perform(WM_VSCROLL, SB_TOP, 0);
    LScroll.Perform(WM_HSCROLL, SB_LEFT, 0);
    PumpMessages(20);
    LContent.SetBounds(0, 0, LScroll.ClientWidth + 32,
      LScroll.ClientHeight + 32);
    PumpMessages(80);
    LScroll.Perform(WM_VSCROLL, SB_BOTTOM, 0);
    LVerticalEnd := LScroll.VertScrollBar.Position;
    LScroll.Perform(WM_HSCROLL, SB_RIGHT, 0);
    LHorizontalEnd := LScroll.HorzScrollBar.Position;
    Require((LVerticalEnd >= 2) and (LHorizontalEnd >= 2),
      'Range curto nao criou deslocamento mensuravel nos dois eixos.');
    LScroll.Perform(WM_VSCROLL,
      MakeLong(SB_THUMBPOSITION, LVerticalEnd div 2), 0);
    LScroll.Perform(WM_HSCROLL,
      MakeLong(SB_THUMBPOSITION, LHorizontalEnd div 2), 0);
    PumpMessages(50);
    ResetObservedPaint;
    ForceHookPaint('range curto');
    RequireSevenZones(ScrollHookVerticalPaint, True, True,
      'vertical range curto');
    RequireSevenZones(ScrollHookHorizontalPaint, False, True,
      'horizontal range curto');

    LBeforeVertical := ScrollHookVerticalPaint;
    LBeforeHorizontal := ScrollHookHorizontalPaint;
    LContent.SetBounds(0, 0, 1800, 1500);
    LScroll.SetBounds(LScroll.Left, LScroll.Top, 420, 290);
    PumpMessages(80);
    ResetObservedPaint;
    ForceHookPaint('resize e ranges maiores');
    Require((ScrollHookVerticalPaint.ScrollRect.Height >
        LBeforeVertical.ScrollRect.Height) and
      (ScrollHookHorizontalPaint.ScrollRect.Width >
        LBeforeHorizontal.ScrollRect.Width) and
      (ScrollHookVerticalPaint.SliderRect.Height > 0) and
      (ScrollHookHorizontalPaint.SliderRect.Width > 0),
      'Resize/range nao recalculou bounds coerentes dos dois eixos.');
    RequireAxisGeometry(ScrollHookVerticalPaint, True, 'vertical resized');
    RequireAxisGeometry(ScrollHookHorizontalPaint, False,
      'horizontal resized');

    LScroll.Enabled := False;
    ResetObservedPaint;
    ForceHookPaint('disabled');
    LTokens := TDACComponentStyle.Resolve(
      TDACThemeManager.ApplicationMode).Tokens.Controls;
    Require((not ScrollHookVerticalPaint.Enabled) and
      (ScrollHookVerticalPaint.SliderState =
        tsThumbBtnVertDisabled) and
      (ScrollHookVerticalPaint.SliderColor = LTokens.TabsTextDisabled) and
      (ScrollHookVerticalPaint.ArrowColor = LTokens.TabsTextDisabled) and
      (ScrollHookHorizontalPaint.SliderState =
        tsThumbBtnHorzDisabled) and
      (ScrollHookHorizontalPaint.SliderColor =
        LTokens.TabsTextDisabled) and
      (ScrollHookHorizontalPaint.ArrowColor =
        LTokens.TabsTextDisabled),
      'Estado disabled nao resolveu tokens/estados do hook.');
    LScroll.Enabled := True;
    LHook.ProcessHookMessage(WM_NCMOUSELEAVE_VALUE, 0, 0);
    PumpMessages(20);

    for I := 1 to 10 do
    begin
      if Odd(I) then
        TDACThemeManager.SetApplicationMode(dtmLight)
      else
        TDACThemeManager.SetApplicationMode(dtmDark);
      PumpMessages(30);
      ResetObservedPaint;
      ForceHookPaint('ciclo de tema ' + IntToStr(I));
      LTokens := TDACComponentStyle.Resolve(
        TDACThemeManager.ApplicationMode).Tokens.Controls;
      Require((ScrollHookVerticalPaint.TrackColor =
          LTokens.ScrollBarTrack) and
        (ScrollHookHorizontalPaint.BorderColor =
          LTokens.ScrollBarBorder),
        'Ciclo de tema nao chegou aos tokens da scrollbar.');
    end;
    LScroll.Visible := False;
    TDACThemeManager.SetApplicationMode(dtmLight);
    PumpMessages(30);
    LScroll.Visible := True;
    PumpMessages(40);
    ResetObservedPaint;
    ForceHookPaint('oculta e reativada light');
    Require(ScrollHookVerticalPaint.TrackColor =
      TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.ScrollBarTrack,
      'Scrollbar oculta/reativada nao aplicou tema Light pendente.');
    TDACThemeManager.SetApplicationMode(dtmDark);
    PumpMessages(30);
  finally
    ScrollHookRepaintOnNextNotification := False;
    ScrollHookRepaintAttempted := False;
    ScrollHookSynchronousRepaint := nil;
    TDACScrollContainerStyleHook.SetPaintObserver(nil);
    ScrollHookTarget := 0;
    if GetCapture = LScrollHandle then
      ReleaseCapture;
    LHook.Free;
    LScroll.Free;
    SetWindowPos(AForm.Handle, HWND_NOTOPMOST, 0, 0, 0, 0,
      SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);
    SetCursorPos(LOldCursor.X, LOldCursor.Y);
    PumpMessages(40);
    Require((LScrollHandle = 0) or not IsWindow(LScrollHandle),
      'Teardown da prova do StyleHook preservou HWND do ScrollContainer.');
  end;
end;

procedure RequireDatePopupOwnership;
var
  I: Integer;
  LDate: TDACDateTimePicker;
  LForm: TForm;
  LPopup: TDACDateTimePickerPopup;
begin
  LForm := TForm.Create(nil);
  try
    LForm.SetBounds(-32000, -32000, 360, 180);
    LDate := TDACDateTimePicker.Create(LForm);
    LDate.Parent := LForm;
    LDate.SetBounds(24, 32, 240, 64);
    LForm.Show;
    PumpMessages(40);

    LDate.OpenPopup;
    PumpMessages(30);
    LPopup := nil;
    for I := 0 to LDate.ComponentCount - 1 do
      if LDate.Components[I] is TDACDateTimePickerPopup then
      begin
        LPopup := TDACDateTimePickerPopup(LDate.Components[I]);
        Break;
      end;
    Require((LPopup <> nil) and (LPopup.Owner = LDate) and LDate.PopupVisible,
      'Popup de data deve pertencer deterministicamente ao campo nativo.');

    LPopup.Free;
    PumpMessages(20);
    Require(not LDate.PopupVisible,
      'Notification nao limpou popup de data removido externamente.');

    LDate.OpenPopup;
    PumpMessages(30);
    Require(LDate.PopupVisible,
      'Campo de data nao recriou popup apos remocao externa.');
    LDate.Free;
    PumpMessages(20);
  finally
    LForm.Free;
  end;

  LForm := TForm.Create(nil);
  try
    LForm.SetBounds(-32000, -32000, 360, 180);
    LDate := TDACDateTimePicker.Create(LForm);
    LDate.Parent := LForm;
    LDate.SetBounds(24, 32, 240, 64);
    LForm.Show;
    PumpMessages(40);
    LDate.OpenPopup;
    PumpMessages(30);
    Require(LDate.PopupVisible,
      'Popup de data nao abriu para validar destruicao pelo formulario.');
  finally
    LForm.Free;
  end;
  PumpMessages(20);
end;

procedure RequireLoadingFocusPolicy;
var
  I: Integer;
  LAfter: TEdit;
  LBefore: TEdit;
  LButtonEdit: TDACButtonEdit;
  LCombo: TDACComboBox;
  LDate: TDACDateTimePicker;
  LEdit: TDACEdit;
  LEditors: array[0..4] of TWinControl;
  LForm: TForm;
  LHosts: array[0..4] of TWinControl;
  LLabels: array[0..4] of TLabel;
  LMemo: TDACMemo;

  function FieldName(const AIndex: Integer): string;
  begin
    case AIndex of
      0: Result := 'Edit';
      1: Result := 'ButtonEdit';
      2: Result := 'Memo';
      3: Result := 'ComboBox';
    else
      Result := 'DateTimePicker';
    end;
  end;

  function FieldFocused(const AIndex: Integer): Boolean;
  var
    LFocus: HWND;
  begin
    LFocus := Winapi.Windows.GetFocus;
    Result := LHosts[AIndex].Focused or LEditors[AIndex].Focused or
      ((LFocus <> 0) and LHosts[AIndex].HandleAllocated and
       IsChild(LHosts[AIndex].Handle, LFocus));
  end;

  procedure SetFieldLoading(const AIndex: Integer; const AValue: Boolean);
  begin
    case AIndex of
      0: LEdit.Loading := AValue;
      1: LButtonEdit.Loading := AValue;
      2: LMemo.Loading := AValue;
      3: LCombo.Loading := AValue;
      4: LDate.Loading := AValue;
    end;
  end;

  procedure InvokeFieldFocus(const AIndex: Integer);
  begin
    case AIndex of
      0: LEdit.SetFocus;
      1: LButtonEdit.SetFocus;
      2: LMemo.SetFocus;
      3: LCombo.SetFocus;
      4: LDate.SetFocus;
    end;
  end;

begin
  LForm := TForm.Create(nil);
  try
    LForm.SetBounds(-32000, -32000, 720, 480);
    LBefore := TEdit.Create(LForm);
    LBefore.Parent := LForm;
    LBefore.SetBounds(16, 16, 120, 24);
    LBefore.TabOrder := 0;

    LEdit := TDACEdit.Create(LForm);
    LEdit.Parent := LForm;
    LEdit.SetBounds(16, 56, 200, 64);
    LEdit.TabOrder := 1;
    LButtonEdit := TDACButtonEdit.Create(LForm);
    LButtonEdit.Parent := LForm;
    LButtonEdit.SetBounds(240, 56, 200, 64);
    LButtonEdit.TabOrder := 2;
    LMemo := TDACMemo.Create(LForm);
    LMemo.Parent := LForm;
    LMemo.SetBounds(16, 144, 200, 96);
    LMemo.TabOrder := 3;
    LCombo := TDACComboBox.Create(LForm);
    LCombo.Parent := LForm;
    LCombo.SetBounds(240, 144, 200, 64);
    LCombo.Items.Text := 'Alpha' + sLineBreak + 'Beta';
    LCombo.ItemIndex := 0;
    LCombo.TabOrder := 4;
    LDate := TDACDateTimePicker.Create(LForm);
    LDate.Parent := LForm;
    LDate.SetBounds(464, 144, 200, 64);
    LDate.TabOrder := 5;

    LAfter := TEdit.Create(LForm);
    LAfter.Parent := LForm;
    LAfter.SetBounds(16, 272, 120, 24);
    LAfter.TabOrder := 6;

    LHosts[0] := LEdit;
    LHosts[1] := LButtonEdit;
    LHosts[2] := LMemo;
    LHosts[3] := LCombo;
    LHosts[4] := LDate;
    LEditors[0] := LEdit.EditControl;
    LEditors[1] := LButtonEdit.EditControl;
    LEditors[2] := LMemo.MemoControl;
    LEditors[3] := LCombo.ComboControl;
    LEditors[4] := LDate.PickerControl;
    LLabels[0] := LEdit.NativeLabel;
    LLabels[1] := LButtonEdit.NativeLabel;
    LLabels[2] := LMemo.NativeLabel;
    LLabels[3] := LCombo.NativeLabel;
    LLabels[4] := LDate.NativeLabel;

    LForm.Show;
    PumpMessages(80);
    for I := Low(LHosts) to High(LHosts) do
    begin
      LHosts[I].TabStop := True;
      LEditors[I].SetFocus;
      PumpMessages(10);
      Require(LEditors[I].Focused,
        FieldName(I) + ' nao recebeu foco normal antes de Loading.');
      SetFieldLoading(I, True);
      PumpMessages(10);
      Require(not LHosts[I].TabStop and not FieldFocused(I),
        FieldName(I) + ' manteve TabStop/foco ao entrar Loading.');

      InvokeFieldFocus(I);
      PumpMessages(10);
      Require(not FieldFocused(I),
        FieldName(I) + '.SetFocus reteve foco durante Loading.');
      TWinControl(LHosts[I]).SetFocus;
      PumpMessages(10);
      Require(not FieldFocused(I),
        FieldName(I) + ' reteve WM_SETFOCUS no wrapper durante Loading.');
      LHosts[I].Perform(WM_SETFOCUS, 0, 0);
      PumpMessages(10);
      Require(not FieldFocused(I),
        FieldName(I) + ' reteve WM_SETFOCUS sintetico durante Loading.');
      TControlClickAccess(LLabels[I]).Click;
      PumpMessages(10);
      Require(not FieldFocused(I),
        FieldName(I) + ' recebeu foco pelo label durante Loading.');
    end;

    LBefore.SetFocus;
    TWinControlSelectAccess(LForm).SelectNext(LBefore, True, True);
    PumpMessages(10);
    Require(LAfter.Focused,
      'Tab nao pulou todas as cinco familias em Loading.');

    for I := Low(LHosts) to High(LHosts) do
    begin
      SetFieldLoading(I, False);
      Require(LHosts[I].TabStop,
        FieldName(I) + ' nao restaurou TabStop=True apos Loading.');
      InvokeFieldFocus(I);
      PumpMessages(10);
      Require(LEditors[I].Focused,
        FieldName(I) + ' nao restaurou foco normal apos Loading.');

      LHosts[I].TabStop := False;
      SetFieldLoading(I, True);
      SetFieldLoading(I, False);
      Require(not LHosts[I].TabStop,
        FieldName(I) + ' perdeu TabStop=False preexistente no ciclo Loading.');
      LHosts[I].TabStop := True;
      LHosts[I].Enabled := False;
      InvokeFieldFocus(I);
      LHosts[I].Perform(WM_SETFOCUS, 0, 0);
      TControlClickAccess(LLabels[I]).Click;
      PumpMessages(10);
      Require(not FieldFocused(I),
        FieldName(I) + ' recebeu foco programatico/label estando Disabled.');
    end;

    LBefore.SetFocus;
    TWinControlSelectAccess(LForm).SelectNext(LBefore, True, True);
    PumpMessages(10);
    Require(LAfter.Focused,
      'Tab nao pulou todas as cinco familias Disabled.');
    for I := Low(LHosts) to High(LHosts) do
      LHosts[I].Enabled := True;
  finally
    LForm.Free;
  end;
  PumpMessages(20);
end;

procedure RequireComboValueSemantics;
var
  LCombo: TDACComboBox;
  LForm: TForm;

  function NativeText: string;
  var
    LBuffer: array[0..255] of Char;
  begin
    LBuffer[0] := #0;
    Winapi.Windows.GetWindowText(LCombo.ComboControl.Handle, LBuffer,
      Length(LBuffer));
    Result := string(LBuffer);
  end;

  procedure RequireNativeState(const AIndex: Integer; const AText,
    AContext: string);
  begin
    Require((LCombo.ItemIndex = AIndex) and (LCombo.Text = AText) and
      (LCombo.ComboControl.ItemIndex = AIndex) and
      (SendMessage(LCombo.ComboControl.Handle, CB_GETCURSEL, 0, 0) = AIndex) and
      (NativeText = AText),
      AContext + ': getter, estado interno e HWND divergiram.');
  end;

begin
  LForm := TForm.Create(nil);
  try
    LForm.SetBounds(-32000, -32000, 360, 180);
    LCombo := TDACComboBox.Create(LForm);
    LCombo.Parent := LForm;
    LCombo.SetBounds(24, 32, 240, 64);
    LForm.Show;
    PumpMessages(50);

    LCombo.Items.Text := 'Alpha' + sLineBreak + 'Duplicate' + sLineBreak +
      'Duplicate' + sLineBreak + 'Beta';
    LCombo.Style := csDropDownList;
    LCombo.Text := 'Beta';
    RequireNativeState(3, 'Beta', 'DropDownList/existente');
    LCombo.Text := 'Custom';
    RequireNativeState(-1, '', 'DropDownList/inexistente');
    LCombo.ItemIndex := 2;
    RequireNativeState(2, 'Duplicate', 'DropDownList/indice duplicado');
    LCombo.ItemIndex := 3;
    LCombo.Items.Delete(3);
    RequireNativeState(-1, '', 'DropDownList/remocao selecionado');
    LCombo.Items.Clear;
    RequireNativeState(-1, '', 'DropDownList/clear');

    LCombo.Items.Text := 'Alpha' + sLineBreak + 'Duplicate' + sLineBreak +
      'Duplicate' + sLineBreak + 'Beta';
    LCombo.Style := csDropDown;
    LCombo.Text := 'Custom';
    RequireNativeState(-1, 'Custom', 'DropDown/custom');
    LCombo.Text := 'Duplicate';
    RequireNativeState(1, 'Duplicate', 'DropDown/existente duplicado');
    LCombo.ItemIndex := 2;
    RequireNativeState(2, 'Duplicate', 'DropDown/indice duplicado');
    LCombo.Text := 'Beta';
    RequireNativeState(3, 'Beta', 'DropDown/existente');
    LCombo.Items.Delete(3);
    RequireNativeState(-1, 'Beta', 'DropDown/remocao selecionado');
    LCombo.Items.Clear;
    RequireNativeState(-1, 'Beta', 'DropDown/clear preserva custom');

    LCombo.Style := csDropDownList;
    RequireNativeState(-1, '', 'Mudanca DropDown custom para DropDownList');
    LCombo.Style := csDropDown;
    LCombo.Text := 'Livre';
    RequireNativeState(-1, 'Livre', 'Mudanca para DropDown custom');
    LCombo.Items.Add('Livre');
    RequireNativeState(0, 'Livre', 'Items passa a conter texto custom');
  finally
    LForm.Free;
  end;
  PumpMessages(20);
end;

procedure RequireVisibleWithin(const AControl: TControl;
  const AExpected: Boolean; const ATimeout: Cardinal; const AMessage: string);
var
  LStart: Cardinal;
begin
  LStart := GetTickCount;
  repeat
    Application.ProcessMessages;
    if AControl.Visible = AExpected then
      Exit;
    Sleep(1);
  until Cardinal(GetTickCount - LStart) >= ATimeout;
  Require(AControl.Visible = AExpected, AMessage);
end;

procedure RequireNativeChildInside(const AHost, AChild: TWinControl;
  const AName: string);
var
  LChildRect: TRect;
  LHostRect: TRect;
begin
  Require((AHost <> nil) and AHost.HandleAllocated and (AChild <> nil) and
    AChild.HandleAllocated and Winapi.Windows.GetWindowRect(AHost.Handle, LHostRect) and
    Winapi.Windows.GetWindowRect(AChild.Handle, LChildRect),
    'Nao foi possivel obter HWNDs nativos: ' + AName);
  Require((LChildRect.Left >= LHostRect.Left) and (LChildRect.Top >= LHostRect.Top) and
    (LChildRect.Right <= LHostRect.Right) and (LChildRect.Bottom <= LHostRect.Bottom),
    Format('Editor nativo escapou do host apos layout: %s (child=%d,%d..%d,%d host=%d,%d..%d,%d).',
      [AName, LChildRect.Left, LChildRect.Top, LChildRect.Right, LChildRect.Bottom,
       LHostRect.Left, LHostRect.Top, LHostRect.Right, LHostRect.Bottom]));
end;

procedure TInteractionProbe.OnApplicationException(Sender: TObject; E: Exception);
begin
  UnexpectedException := E.ClassName + ': ' + E.Message;
end;

procedure TInteractionProbe.OnDataGridAction(Sender: TObject;
  AAction: TDACDataGridActionKind; AColumn: TColumn);
begin
  Inc(ActionCount);
  LastAction := AAction;
  LastActionColumn := AColumn;
end;

procedure TInteractionProbe.OnButtonClick(Sender: TObject);
begin
  Inc(ClickCount);
end;

procedure TInteractionProbe.OnComboCloseUp(Sender: TObject);
begin
  Inc(ComboCloseCount);
  if ComboReenter then
    TDACComboBox(Sender).CloseDropDown;
end;

procedure TInteractionProbe.OnComboDropDown(Sender: TObject);
begin
  Inc(ComboDropDownCount);
  if ComboReenter then
    TDACComboBox(Sender).OpenDropDown;
end;

procedure TFormAccess.FocusNext(const AControl: TWinControl);
begin
  SelectNext(AControl, True, True);
end;

procedure TButtonAccess.SimulateMouseMove(const X, Y: Integer);
begin
  MouseMove([], X, Y);
end;

procedure TButtonAccess.SimulateMouseDown(const X, Y: Integer);
begin
  MouseDown(mbLeft, [], X, Y);
end;

procedure TButtonAccess.SimulateMouseUp(const X, Y: Integer);
begin
  MouseUp(mbLeft, [], X, Y);
end;

procedure TDataGridHandleAccess.RecreateNativeHandle;
begin
  RecreateWnd;
end;

function TDataGridHandleAccess.GridBufferedRecordCount: Integer;
begin
  Result := DataLink.RecordCount;
end;

function TDataGridHandleAccess.GridColumn: Integer;
begin
  Result := Col;
end;

function TDataGridHandleAccess.GridCellRect(const ACol, ARow: Integer): TRect;
begin
  Result := CellRect(ACol, ARow);
end;

function TDataGridHandleAccess.GridActionRect(const ACellRect: TRect;
  const AAction: TDACDataGridActionKind): TRect;
begin
  Result := ActionRect(ACellRect, AAction);
end;

function TDataGridHandleAccess.GridDefaultRowHeight: Integer;
begin
  Result := DefaultRowHeight;
end;

function TDataGridHandleAccess.GridFixedRows: Integer;
begin
  Result := FixedRows;
end;

function TDataGridHandleAccess.GridHeaderHeight: Integer;
begin
  Result := RowHeights[0];
end;

procedure TDataGridScrollHookAccess.PaintAxisNonClient(
  const AVertical: Boolean);
var
  LDC: HDC;
begin
  LDC := GetWindowDC(Control.Handle);
  Require(LDC <> 0,
    'Nao foi possivel obter DC non-client da TDACDataGrid.');
  try
    if AVertical then
      DrawVertScroll(LDC)
    else
      DrawHorzScroll(LDC);
  finally
    ReleaseDC(Control.Handle, LDC);
  end;
end;

function TDataGridScrollHookAccess.HorizontalTrackWidth: Integer;
begin
  Result := HorzTrackRect.Width;
end;

function TDataGridScrollHookAccess.ProcessHookMessage(
  const AMsg: Cardinal; const AWParam: WPARAM;
  const ALParam: LPARAM): LRESULT;
var
  LMessage: TMessage;
begin
  FillChar(LMessage, SizeOf(LMessage), 0);
  LMessage.Msg := AMsg;
  LMessage.WParam := AWParam;
  LMessage.LParam := ALParam;
  Handled := False;
  WndProc(LMessage);
  Result := LMessage.Result;
end;

procedure TDataGridScrollHookAccess.SeedAxisStates(
  const AVertical: Boolean;
  const ASliderState, AStartState, AEndState: TThemedScrollBar);
begin
  if AVertical then
  begin
    VertSliderState := ASliderState;
    VertUpState := AStartState;
    VertDownState := AEndState;
  end
  else
  begin
    HorzSliderState := ASliderState;
    HorzUpState := AStartState;
    HorzDownState := AEndState;
  end;
end;

procedure TDataGridScrollHookAccess.SeedMouseDragDelta(
  const AVertical: Boolean; const ADelta: Integer);
begin
  if AVertical then
    PrevScrollPos := Mouse.CursorPos.Y - ADelta
  else
    PrevScrollPos := Mouse.CursorPos.X - ADelta;
end;

function TDataGridScrollHookAccess.VerticalTrackHeight: Integer;
begin
  Result := VertTrackRect.Height;
end;

class function TStyleEngineAccess.HasExactStyleHook(
  const AControlClass: TClass;
  const AStyleHookClass: TStyleHookClass): Boolean;
begin
  Result := (RegisteredStyleHooks <> nil) and
    RegisteredStyleHooks.ContainsKey(AControlClass) and
    (RegisteredStyleHooks[AControlClass].IndexOf(AStyleHookClass) >= 0);
end;

procedure TDataGridHandleAccess.SetGridEvents(
  const AClick, ADoubleClick: TNotifyEvent;
  const ACellClick: TDBGridClickEvent);
begin
  OnClick := AClick;
  OnDblClick := ADoubleClick;
  OnCellClick := ACellClick;
end;

procedure TInteractionProbe.OnGridClick(Sender: TObject);
begin
  Inc(GridClickCount);
end;

procedure TInteractionProbe.OnGridDoubleClick(Sender: TObject);
begin
  Inc(GridDoubleClickCount);
end;

procedure TInteractionProbe.OnGridCellClick(Column: TColumn);
begin
  Inc(GridCellClickCount);
end;

function TDataGridHandleAccess.GridLeftColumn: Integer;
begin
  Result := LeftCol;
end;

procedure TDataGridHandleAccess.SetGridLeftColumn(const AValue: Integer);
begin
  LeftCol := AValue;
end;

function TDataGridHandleAccess.GridAcceptsDataCellRect(
  const ARect: TRect; const AViewportWidth, ADataTop,
  ADataBottom: Integer): Boolean;
begin
  Result := IsDataCellRectFullyVisible(ARect, AViewportWidth,
    ADataTop, ADataBottom);
end;

procedure TDataGridHandleAccess.GridGuardDataChromeRect(
  const ARect: TRectF; const ADataTop, ADataBottom: Single);
begin
  GuardDataChromeRect(ARect, ADataTop, ADataBottom);
end;

function TDataGridHandleAccess.GridTryHitAction(const X, Y: Integer;
  out AColumn: TColumn; out AAction: TDACDataGridActionKind): Boolean;
begin
  Result := TryHitAction(X, Y, AColumn, AAction);
end;

function TDataGridHandleAccess.GridRow: Integer;
begin
  Result := Row;
end;

function TDataGridHandleAccess.GridTopRow: Integer;
begin
  Result := TopRow;
end;

function TDataGridHandleAccess.GridEditorMode: Boolean;
begin
  Result := EditorMode;
end;

function TDataGridHandleAccess.GridEditorFocused: Boolean;
begin
  Result := (InplaceEditor <> nil) and InplaceEditor.Focused;
end;

function TDataGridHandleAccess.GridEditorVisible: Boolean;
begin
  Result := (InplaceEditor <> nil) and InplaceEditor.Visible;
end;

procedure TDataGridHandleAccess.GridEditorChar(const AChar: Char);
begin
  if InplaceEditor <> nil then
    InplaceEditor.Perform(WM_CHAR, Ord(AChar), 0);
end;

procedure TDataGridPaintBoxAccess.SimulateClick(const X, Y: Integer);
begin
  MouseDown(mbLeft, [], X, Y);
  MouseUp(mbLeft, [], X, Y);
end;

function TDataGridPaintBoxAccess.SimulateMouseWheel(
  const AWheelDelta: Integer): Boolean;
begin
  Result := DoMouseWheel([], AWheelDelta, Point(0, 0));
end;

function TDataGridPaintBoxAccess.SimulateMouseWheelAt(
  const AWheelDelta, X, Y: Integer): Boolean;
begin
  Result := DoMouseWheel([], AWheelDelta, ClientToScreen(Point(X, Y)));
end;

procedure SendKey(const AControl: TControl; const AKey: Word);
begin
  TWinControl(AControl).SetFocus;
  PumpMessages(20);
  AControl.Perform(WM_KEYDOWN, AKey, 0);
  AControl.Perform(WM_KEYUP, AKey, 0);
  PumpMessages(30);
end;

procedure SendCtrlTab(const AControl: TControl);
begin
  TWinControl(AControl).SetFocus;
  PumpMessages(20);
  TDACTabsAccess(AControl).SimulateCtrlTab;
  PumpMessages(30);
end;

type
  TNestedWheelExpectedOwner = (
    nweChild,
    nweOuter,
    nweAccumulatorOnly
  );

  TNativeMemoViewportSnapshot = record
    FirstVisibleLine: Integer;
    LineCount: Integer;
    LastLineIndex: Integer;
    LastLineTop: Integer;
    FormatTop: Integer;
    FormatBottom: Integer;
    LineHeight: Integer;
    CanScrollDown: Boolean;
  end;

  TNativeMemoWheelProbe = class
  public
    Count: Integer;
    DownCount: Integer;
    LastDelta: Integer;
    UpCount: Integer;
    procedure Capture(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure CaptureDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure CaptureUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure Reset;
  end;

  TVerticalScrollSnapshot = record
    Minimum: Integer;
    Maximum: Integer;
    PageSize: Cardinal;
    Position: Integer;
  end;

function MaximumScrollPosition(
  const ASnapshot: TVerticalScrollSnapshot): Integer;
begin
  Result := ASnapshot.Maximum;
  if ASnapshot.PageSize > 0 then
    Dec(Result, Integer(ASnapshot.PageSize) - 1);
  Result := Max(ASnapshot.Minimum, Result);
end;

function ReadVerticalScrollSnapshot(const AHandle: HWND;
  const AContext: string): TVerticalScrollSnapshot;
var
  LInfo: TScrollInfo;
begin
  FillChar(LInfo, SizeOf(LInfo), 0);
  LInfo.cbSize := SizeOf(LInfo);
  LInfo.fMask := SIF_RANGE or SIF_PAGE or SIF_POS;
  Require((AHandle <> 0) and IsWindow(AHandle) and
    GetScrollInfo(AHandle, SB_VERT, LInfo),
    AContext + ': GetScrollInfo(SB_VERT) falhou.');
  Result.Minimum := LInfo.nMin;
  Result.Maximum := LInfo.nMax;
  Result.PageSize := LInfo.nPage;
  Result.Position := LInfo.nPos;
end;

procedure TNativeMemoWheelProbe.Capture(Sender: TObject; Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
begin
  Inc(Count);
  LastDelta := WheelDelta;
  Handled := False;
end;

procedure TNativeMemoWheelProbe.CaptureDown(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  Inc(DownCount);
  Handled := False;
end;

procedure TNativeMemoWheelProbe.CaptureUp(Sender: TObject;
  Shift: TShiftState; MousePos: TPoint; var Handled: Boolean);
begin
  Inc(UpCount);
  Handled := False;
end;

procedure TNativeMemoWheelProbe.Reset;
begin
  Count := 0;
  DownCount := 0;
  LastDelta := 0;
  UpCount := 0;
end;

function NativeMemoLineHeight(const AHandle: HWND): Integer;
var
  LDC: HDC;
  LFont: HFONT;
  LOldFont: HGDIOBJ;
  LTextMetric: TTextMetric;
begin
  LDC := GetDC(AHandle);
  Require(LDC <> 0, 'Nao foi possivel medir a fonte do Memo nativo.');
  LOldFont := 0;
  try
    LFont := HFONT(SendMessage(AHandle, WM_GETFONT, 0, 0));
    if LFont <> 0 then
      LOldFont := SelectObject(LDC, LFont);
    Require(GetTextMetrics(LDC, LTextMetric),
      'GetTextMetrics falhou para o Memo nativo.');
    Result := Max(1, LTextMetric.tmHeight + LTextMetric.tmExternalLeading);
  finally
    if LOldFont <> 0 then
      SelectObject(LDC, LOldFont);
    ReleaseDC(AHandle, LDC);
  end;
end;

function ReadNativeMemoViewport(const AHandle: HWND;
  const AContext: string): TNativeMemoViewportSnapshot;
var
  LFormatRect: TRect;
  LLastPosition: LRESULT;
begin
  Require((AHandle <> 0) and IsWindow(AHandle),
    AContext + ': HWND do Memo nao esta valido.');
  Result.FirstVisibleLine :=
    SendMessage(AHandle, EM_GETFIRSTVISIBLELINE, 0, 0);
  Result.LineCount := SendMessage(AHandle, EM_GETLINECOUNT, 0, 0);
  Require(Result.LineCount > 0,
    AContext + ': EM_GETLINECOUNT nao retornou linhas visuais.');
  Result.LastLineIndex := SendMessage(AHandle, EM_LINEINDEX,
    Result.LineCount - 1, 0);
  Require(Result.LastLineIndex >= 0,
    AContext + ': EM_LINEINDEX falhou para a ultima linha visual.');
  LLastPosition := SendMessage(AHandle, EM_POSFROMCHAR,
    Result.LastLineIndex, 0);
  Require(LLastPosition <> -1,
    AContext + ': EM_POSFROMCHAR falhou para a ultima linha visual.');
  Result.LastLineTop := SmallInt(HiWord(DWORD(LLastPosition)));
  FillChar(LFormatRect, SizeOf(LFormatRect), 0);
  SendMessage(AHandle, EM_GETRECT, 0, LPARAM(@LFormatRect));
  Result.FormatTop := LFormatRect.Top;
  Result.FormatBottom := LFormatRect.Bottom;
  Result.LineHeight := NativeMemoLineHeight(AHandle);
  Result.CanScrollDown :=
    Result.LastLineTop + Result.LineHeight > Result.FormatBottom;
end;

procedure ScrollNativeMemoLines(const AHandle: HWND;
  const ALineDelta: Integer);
begin
  SendMessage(AHandle, EM_LINESCROLL, 0, LPARAM(ALineDelta));
  PumpMessages(30);
end;

procedure RequirePhysicalNestedWheelRouting(const AForm: TForm;
  const AOuter: TDACScrollContainer; const AMemo: TDACMemo;
  const AFocusOutside: TWinControl);
var
  LBaselineOuterPosition: Integer;
  LBeforeOuter: TVerticalScrollSnapshot;
  LChildHandle: HWND;
  LChildPoint: TPoint;
  LClipboardExpected: string;
  LCursorBefore: TPoint;
  LFixtureText: string;
  LIndex: Integer;
  LNativeSnapshot: TNativeMemoViewportSnapshot;
  LOutsidePoint: TPoint;
  LOuterMaximum: Integer;
  LOuterSnapshot: TVerticalScrollSnapshot;
  LProbe: TNativeMemoWheelProbe;
  LSavedCaret: Integer;
  LSavedSelection: Integer;
  LVclWheelAccumulator: Integer;

  procedure PositionOuterAtBaseline;
  begin
    AOuter.VertScrollBar.Position := LBaselineOuterPosition;
    PumpMessages(40);
    Require(ReadVerticalScrollSnapshot(AOuter.Handle,
      'outer baseline').Position = LBaselineOuterPosition,
      'scrInputs nao aceitou a posicao baseline do teste de wheel.');
  end;

  procedure PositionMemoAtTop;
  var
    LSnapshot: TNativeMemoViewportSnapshot;
  begin
    ScrollNativeMemoLines(LChildHandle, -32767);
    LSnapshot := ReadNativeMemoViewport(LChildHandle, 'memo no top');
    Require(LSnapshot.FirstVisibleLine = 0,
      Format('Memo nao atingiu o top (first=%d).',
        [LSnapshot.FirstVisibleLine]));
  end;

  procedure PositionMemoAtBottom;
  var
    LSnapshot: TNativeMemoViewportSnapshot;
  begin
    ScrollNativeMemoLines(LChildHandle, 32767);
    LSnapshot := ReadNativeMemoViewport(LChildHandle, 'memo no bottom');
    Require((LSnapshot.FirstVisibleLine > 0) and
      not LSnapshot.CanScrollDown,
      Format('Memo nao atingiu o bottom (first=%d lastTop=%d bottom=%d lineHeight=%d).',
        [LSnapshot.FirstVisibleLine, LSnapshot.LastLineTop,
         LSnapshot.FormatBottom, LSnapshot.LineHeight]));
  end;

  procedure PositionMemoAtMiddle;
  var
    LSnapshot: TNativeMemoViewportSnapshot;
  begin
    PositionMemoAtTop;
    LSnapshot := ReadNativeMemoViewport(LChildHandle,
      'memo antes do middle');
    ScrollNativeMemoLines(LChildHandle, Max(1, LSnapshot.LineCount div 2));
    LSnapshot := ReadNativeMemoViewport(LChildHandle,
      'memo depois do middle');
    Require((LSnapshot.FirstVisibleLine > 0) and LSnapshot.CanScrollDown,
      Format('Memo nao atingiu posicao intermediaria (first=%d count=%d canDown=%s).',
        [LSnapshot.FirstVisibleLine, LSnapshot.LineCount,
         BoolToStr(LSnapshot.CanScrollDown, True)]));
  end;

  procedure SendRoutedWheel(const APoint: TPoint;
    const AWheelDelta: Integer; const AExpected: TNestedWheelExpectedOwner;
    const AContext: string; const APointOverMemo: Boolean = True;
    const AExpectedChildLineDelta: Integer = -1);
  var
    LAfterChild: TNativeMemoViewportSnapshot;
    LAfterIme: HIMC;
    LAfterOuter: TVerticalScrollSnapshot;
    LBeforeCaret: Integer;
    LBeforeChild: TNativeMemoViewportSnapshot;
    LBeforeFocus: HWND;
    LBeforeIme: HIMC;
    LBeforeSelection: Integer;
    LBeforeText: string;
    LChildChanged: Boolean;
    LHit: HWND;
    LOuterChanged: Boolean;
    LExpectedDirectionCount: Integer;
    LExpectedDownCount: Integer;
    LExpectedUpCount: Integer;
    LBeforeUndo: LRESULT;
    LAfterUndo: LRESULT;
  begin
    // TCMMouseWheel.Pos is the routing authority. Some non-interactive CI
    // desktops deny moving the global cursor, so SetCursorPos is best-effort;
    // WindowFromPoint below still proves the real screen-space HWND.
    SetCursorPos(APoint.X, APoint.Y);
    PumpMessages(20);
    LHit := WindowFromPoint(APoint);
    if APointOverMemo then
      Require(LHit = LChildHandle,
        Format('%s: hit-test nao encontrou o HWND do Memo (hit=%d memo=%d).',
          [AContext, NativeInt(LHit), NativeInt(LChildHandle)]))
    else
      Require((LHit <> 0) and (LHit <> LChildHandle) and
        ((LHit = AOuter.Handle) or IsChild(AOuter.Handle, LHit)),
        Format('%s: ponto externo nao pertence ao outer (hit=%d outer=%d memo=%d).',
          [AContext, NativeInt(LHit), NativeInt(AOuter.Handle),
           NativeInt(LChildHandle)]));

    LBeforeChild := ReadNativeMemoViewport(LChildHandle,
      AContext + ' child before');
    LBeforeOuter := ReadVerticalScrollSnapshot(AOuter.Handle,
      AContext + ' outer before');
    LBeforeFocus := GetFocus;
    LBeforeCaret := AMemo.MemoControl.SelStart;
    LBeforeSelection := AMemo.MemoControl.SelLength;
    LBeforeText := AMemo.MemoControl.Text;
    LBeforeUndo := SendMessage(LChildHandle, EM_CANUNDO, 0, 0);
    LBeforeIme := ImmGetContext(LChildHandle);
    if LBeforeIme <> 0 then
      ImmReleaseContext(LChildHandle, LBeforeIme);

    Require(LBeforeFocus <> 0,
      AContext + ': rota de wheel exige um HWND realmente focado.');
    Inc(LVclWheelAccumulator, AWheelDelta);
    LExpectedDirectionCount := Abs(LVclWheelAccumulator) div WHEEL_DELTA;
    LExpectedUpCount := 0;
    LExpectedDownCount := 0;
    if LExpectedDirectionCount > 0 then
    begin
      if LVclWheelAccumulator > 0 then
        LExpectedUpCount := LExpectedDirectionCount
      else
        LExpectedDownCount := LExpectedDirectionCount;
      if LVclWheelAccumulator < 0 then
        LVclWheelAccumulator := -(Abs(LVclWheelAccumulator) mod WHEEL_DELTA)
      else
        LVclWheelAccumulator := LVclWheelAccumulator mod WHEEL_DELTA;
    end;
    LProbe.Reset;
    SendMessage(LChildHandle, WM_MOUSEWHEEL,
      MakeWParam(0, Word(SmallInt(AWheelDelta))),
      MakeLong(Word(APoint.X), Word(APoint.Y)));
    PumpMessages(80);

    LAfterChild := ReadNativeMemoViewport(LChildHandle,
      AContext + ' child after');
    LAfterOuter := ReadVerticalScrollSnapshot(AOuter.Handle,
      AContext + ' outer after');
    LAfterIme := ImmGetContext(LChildHandle);
    if LAfterIme <> 0 then
      ImmReleaseContext(LChildHandle, LAfterIme);
    LAfterUndo := SendMessage(LChildHandle, EM_CANUNDO, 0, 0);
    LChildChanged :=
      LAfterChild.FirstVisibleLine <> LBeforeChild.FirstVisibleLine;
    LOuterChanged := LAfterOuter.Position <> LBeforeOuter.Position;
    Require((LProbe.Count = 1) and (LProbe.LastDelta = AWheelDelta),
      Format('%s: OnMouseWheel deveria ocorrer uma vez (count=%d delta=%d/%d).',
        [AContext, LProbe.Count, LProbe.LastDelta, AWheelDelta]));
    Require((LProbe.UpCount = LExpectedUpCount) and
      (LProbe.DownCount = LExpectedDownCount),
      Format('%s: eventos direcionais duplicados/incorretos (up=%d/%d down=%d/%d).',
        [AContext, LProbe.UpCount, LExpectedUpCount, LProbe.DownCount,
         LExpectedDownCount]));
    Require(not (LChildChanged and LOuterChanged),
      Format('%s: scroll duplo child %d->%d outer %d->%d.',
        [AContext, LBeforeChild.FirstVisibleLine,
         LAfterChild.FirstVisibleLine,
         LBeforeOuter.Position, LAfterOuter.Position]));

    case AExpected of
      nweChild:
        Require(LChildChanged and not LOuterChanged,
          Format('%s: owner esperado child; child %d->%d outer %d->%d.',
            [AContext, LBeforeChild.FirstVisibleLine,
             LAfterChild.FirstVisibleLine,
             LBeforeOuter.Position, LAfterOuter.Position]));
      nweOuter:
        Require(LOuterChanged and not LChildChanged,
          Format('%s: owner esperado outer; child %d->%d outer %d->%d.',
            [AContext, LBeforeChild.FirstVisibleLine,
             LAfterChild.FirstVisibleLine,
             LBeforeOuter.Position, LAfterOuter.Position]));
      nweAccumulatorOnly:
        Require(not LChildChanged and not LOuterChanged,
          Format('%s: delta parcial moveu viewport; child %d->%d outer %d->%d.',
            [AContext, LBeforeChild.FirstVisibleLine,
             LAfterChild.FirstVisibleLine,
             LBeforeOuter.Position, LAfterOuter.Position]));
    end;

    if LChildChanged then
      if AWheelDelta > 0 then
        Require(LAfterChild.FirstVisibleLine <
          LBeforeChild.FirstVisibleLine,
          AContext + ': child moveu na direcao oposta ao wheel-up.')
      else
        Require(LAfterChild.FirstVisibleLine >
          LBeforeChild.FirstVisibleLine,
          AContext + ': child moveu na direcao oposta ao wheel-down.');
    if AExpectedChildLineDelta >= 0 then
      Require(Abs(LAfterChild.FirstVisibleLine -
        LBeforeChild.FirstVisibleLine) = AExpectedChildLineDelta,
        Format('%s: deslocamento child %d, esperado %d linhas.',
          [AContext, Abs(LAfterChild.FirstVisibleLine -
           LBeforeChild.FirstVisibleLine), AExpectedChildLineDelta]));
    if LOuterChanged then
      if AWheelDelta > 0 then
        Require(LAfterOuter.Position < LBeforeOuter.Position,
          AContext + ': outer moveu na direcao oposta ao wheel-up.')
      else
        Require(LAfterOuter.Position > LBeforeOuter.Position,
          AContext + ': outer moveu na direcao oposta ao wheel-down.');

    Require((AMemo.MemoControl.Handle = LChildHandle) and
      IsWindow(LChildHandle) and (GetFocus = LBeforeFocus) and
      (AMemo.MemoControl.SelStart = LBeforeCaret) and
      (AMemo.MemoControl.SelLength = LBeforeSelection) and
      (AMemo.MemoControl.Text = LBeforeText) and
      (LAfterUndo = LBeforeUndo) and
      (LAfterIme = LBeforeIme),
      Format('%s: wheel alterou HWND/foco/caret/selecao/texto/undo/IME (handle=%d/%d focus=%d/%d caret=%d/%d selection=%d/%d undo=%d/%d ime=%d/%d).',
        [AContext, NativeInt(LChildHandle),
         NativeInt(AMemo.MemoControl.Handle), NativeInt(LBeforeFocus),
         NativeInt(GetFocus), LBeforeCaret, AMemo.MemoControl.SelStart,
         LBeforeSelection, AMemo.MemoControl.SelLength,
         NativeInt(LBeforeUndo), NativeInt(LAfterUndo),
         NativeInt(LBeforeIme), NativeInt(LAfterIme)]));
  end;

begin
  Require((AForm <> nil) and (AOuter <> nil) and (AMemo <> nil) and
    (AFocusOutside <> nil) and AForm.HandleAllocated and
    AOuter.HandleAllocated and AMemo.MemoControl.HandleAllocated,
    'Precondicao da matriz fisica de wheel nao foi materializada.');

  LFixtureText := '';
  for LIndex := 1 to 180 do
    LFixtureText := LFixtureText + Format(
      'trecho-%d da observacao extensa para validar quebra visual nativa ',
      [LIndex]);
  AMemo.ScrollBars := System.UITypes.TScrollStyle.ssNone;
  AMemo.MemoControl.BorderStyle := bsNone;
  AMemo.WordWrap := True;
  AMemo.MemoControl.Text := Trim(LFixtureText);
  PumpMessages(40);
  LChildHandle := AMemo.MemoControl.Handle;
  Require((LChildHandle <> 0) and IsWindow(LChildHandle) and
    ((GetWindowLongPtr(LChildHandle, GWL_STYLE) and WS_VSCROLL) = 0) and
    (AMemo.ScrollBars = System.UITypes.TScrollStyle.ssNone) and
    (AMemo.MemoControl.BorderStyle = bsNone) and AMemo.WordWrap,
    'Fixture do Memo divergiu do Demo ssNone/bsNone/WordWrap=True.');
  LOuterSnapshot := ReadVerticalScrollSnapshot(AOuter.Handle,
    'outer antes da capacidade oculta');
  PositionMemoAtTop;
  Require(ReadNativeMemoViewport(LChildHandle,
    'memo capacidade oculta').CanScrollDown,
    'Memo ssNone/WordWrap nao materializou capacidade real sem WS_VSCROLL.');

  LOuterSnapshot := ReadVerticalScrollSnapshot(AOuter.Handle,
    'outer da matriz fisica');
  LOuterMaximum := MaximumScrollPosition(LOuterSnapshot);
  Require(LOuterMaximum > LOuterSnapshot.Minimum + 4,
    'scrInputs precisa rolar nas duas direcoes para a matriz fisica.');
  LBaselineOuterPosition := LOuterSnapshot.Minimum +
    ((LOuterMaximum - LOuterSnapshot.Minimum) div 2);
  PositionOuterAtBaseline;

  LChildPoint := AMemo.MemoControl.ClientToScreen(
    Point(AMemo.MemoControl.ClientWidth div 2,
      AMemo.MemoControl.ClientHeight div 2));
  LOutsidePoint := AOuter.ClientToScreen(Point(12, 12));
  GetCursorPos(LCursorBefore);
  Require(SetWindowPos(AForm.Handle, HWND_TOPMOST, 0, 0, 0, 0,
    SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE),
    'A janela real do Interaction nao ficou exposta para WindowFromPoint.');
  BringWindowToTop(AForm.Handle);
  SetForegroundWindow(AForm.Handle);
  SetActiveWindow(AForm.Handle);
  PumpMessages(60);

  LProbe := TNativeMemoWheelProbe.Create;
  LVclWheelAccumulator := 0;
  try
    TMemoWheelAccess(AMemo.MemoControl).OnMouseWheel := LProbe.Capture;
    TMemoWheelAccess(AMemo.MemoControl).OnMouseWheelDown :=
      LProbe.CaptureDown;
    TMemoWheelAccess(AMemo.MemoControl).OnMouseWheelUp :=
      LProbe.CaptureUp;
    AMemo.MemoControl.SetFocus;
    AMemo.MemoControl.SelStart := 5;
    AMemo.MemoControl.SelLength := 0;
    PumpMessages(30);

    // Checkpoint fisico: os dois +60 formam um unico notch no editor e o
    // +120 isolado tambem pertence somente ao Memo, sem WS_VSCROLL.
    PositionMemoAtBottom;
    PositionOuterAtBaseline;
    SendRoutedWheel(LChildPoint, WHEEL_DELTA div 2, nweAccumulatorOnly,
      'memo real partial wheel-up first +60');
    SendRoutedWheel(LChildPoint, WHEEL_DELTA div 2, nweChild,
      'memo real partial wheel-up second +60');
    PositionMemoAtBottom;
    PositionOuterAtBaseline;
    SendRoutedWheel(LChildPoint, WHEEL_DELTA, nweChild,
      'memo real isolated wheel-up +120');

    PositionMemoAtTop;
    PositionOuterAtBaseline;
    SendRoutedWheel(LChildPoint, -WHEEL_DELTA, nweChild,
      'memo top wheel-down');
    PositionMemoAtMiddle;
    PositionOuterAtBaseline;
    SendRoutedWheel(LChildPoint, WHEEL_DELTA, nweChild,
      'memo middle wheel-up');
    PositionMemoAtMiddle;
    PositionOuterAtBaseline;
    SendRoutedWheel(LChildPoint, -WHEEL_DELTA, nweChild,
      'memo middle wheel-down');

    PositionMemoAtBottom;
    PositionOuterAtBaseline;
    SendRoutedWheel(LChildPoint, WHEEL_DELTA, nweChild,
      'memo bottom wheel-up');

    PositionMemoAtTop;
    PositionOuterAtBaseline;
    SendRoutedWheel(LChildPoint, WHEEL_DELTA, nweOuter,
      'memo top edge handoff wheel-up');
    PositionMemoAtBottom;
    PositionOuterAtBaseline;
    SendRoutedWheel(LChildPoint, -WHEEL_DELTA, nweOuter,
      'memo bottom edge handoff wheel-down');

    PositionMemoAtTop;
    ScrollNativeMemoLines(LChildHandle, 1);
    PositionOuterAtBaseline;
    SendRoutedWheel(LChildPoint, WHEEL_DELTA, nweChild,
      'memo reach-top remains child');
    Require(ReadNativeMemoViewport(LChildHandle,
      'memo reach-top').FirstVisibleLine = 0,
      'Primeiro wheel nao levou o Memo ao limite superior.');
    SendRoutedWheel(LChildPoint, WHEEL_DELTA, nweOuter,
      'memo next wheel after top belongs outer');

    PositionMemoAtBottom;
    ScrollNativeMemoLines(LChildHandle, -1);
    PositionOuterAtBaseline;
    SendRoutedWheel(LChildPoint, -WHEEL_DELTA, nweChild,
      'memo reach-bottom remains child');
    Require(not ReadNativeMemoViewport(LChildHandle,
      'memo reach-bottom').CanScrollDown,
      'Primeiro wheel nao levou o Memo ao limite inferior.');
    SendRoutedWheel(LChildPoint, -WHEEL_DELTA, nweOuter,
      'memo next wheel after bottom belongs outer');

    PositionMemoAtMiddle;
    PositionOuterAtBaseline;
    SendRoutedWheel(LChildPoint, WHEEL_DELTA div 2, nweAccumulatorOnly,
      'memo partial wheel-up first +60');
    SendRoutedWheel(LChildPoint, WHEEL_DELTA div 2, nweChild,
      'memo partial wheel-up second +60');
    PositionMemoAtMiddle;
    PositionOuterAtBaseline;
    SendRoutedWheel(LChildPoint, -(WHEEL_DELTA div 2), nweAccumulatorOnly,
      'memo partial wheel-down first -60');
    SendRoutedWheel(LChildPoint, -(WHEEL_DELTA div 2), nweChild,
      'memo partial wheel-down second -60');

    PositionMemoAtTop;
    PositionOuterAtBaseline;
    SendRoutedWheel(LChildPoint, WHEEL_DELTA div 2, nweAccumulatorOnly,
      'outer partial wheel-up first +60 at child edge');
    SendRoutedWheel(LChildPoint, WHEEL_DELTA div 2, nweOuter,
      'outer partial wheel-up second +60 at child edge');
    PositionMemoAtBottom;
    PositionOuterAtBaseline;
    SendRoutedWheel(LChildPoint, -(WHEEL_DELTA div 2), nweAccumulatorOnly,
      'outer partial wheel-down first -60 at child edge');
    SendRoutedWheel(LChildPoint, -(WHEEL_DELTA div 2), nweOuter,
      'outer partial wheel-down second -60 at child edge');

    PositionMemoAtMiddle;
    PositionOuterAtBaseline;
    SendRoutedWheel(LChildPoint, WHEEL_DELTA div 2, nweAccumulatorOnly,
      'memo partial reversal seed +60');
    SendRoutedWheel(LChildPoint, -(WHEEL_DELTA div 2), nweAccumulatorOnly,
      'memo partial reversal reset -60');
    SendRoutedWheel(LChildPoint, -(WHEEL_DELTA div 2), nweChild,
      'memo partial reversal second -60');

    PositionMemoAtTop;
    PositionOuterAtBaseline;
    SendRoutedWheel(LChildPoint, WHEEL_DELTA div 2, nweAccumulatorOnly,
      'outer partial reversal seed +60');
    PositionMemoAtBottom;
    SendRoutedWheel(LChildPoint, -(WHEEL_DELTA div 2), nweAccumulatorOnly,
      'outer partial reversal reset -60');
    SendRoutedWheel(LChildPoint, -(WHEEL_DELTA div 2), nweOuter,
      'outer partial reversal second -60');

    PositionMemoAtMiddle;
    PositionOuterAtBaseline;
    AFocusOutside.SetFocus;
    PumpMessages(30);
    SendRoutedWheel(LChildPoint, -WHEEL_DELTA, nweChild,
      'pointer over Memo with focus outside');

    PositionMemoAtMiddle;
    PositionOuterAtBaseline;
    AMemo.MemoControl.SetFocus;
    PumpMessages(30);
    SendRoutedWheel(LOutsidePoint, -WHEEL_DELTA, nweOuter,
      'focus on Memo with pointer outside', False);

    DACMemoSetWheelScrollLinesQueryForTests(
      QueryMemoWheelScrollLinesForTests);
    MemoWheelQueryMode := 2;
    PositionMemoAtMiddle;
    PositionOuterAtBaseline;
    SendRoutedWheel(LChildPoint, WHEEL_DELTA, nweAccumulatorOnly,
      'SPI zero consumes Memo detent');

    MemoWheelQueryMode := 1;
    PositionMemoAtBottom;
    PositionOuterAtBaseline;
    SendRoutedWheel(LChildPoint, WHEEL_DELTA, nweChild,
      'SPI failure falls back to three lines', True, 3);

    MemoWheelQueryMode := 3;
    PositionMemoAtBottom;
    PositionOuterAtBaseline;
    LNativeSnapshot := ReadNativeMemoViewport(LChildHandle,
      'memo before page injection');
    LIndex := Max(1, ((LNativeSnapshot.FormatBottom -
      LNativeSnapshot.FormatTop) div LNativeSnapshot.LineHeight) - 1);
    SendRoutedWheel(LChildPoint, WHEEL_DELTA, nweChild,
      'SPI page scroll uses visible page minus one', True, LIndex);

    MemoWheelQueryMode := 4;
    PositionMemoAtBottom;
    PositionOuterAtBaseline;
    SendRoutedWheel(LChildPoint, WHEEL_DELTA, nweChild,
      'SPI normal scroll lines clamps at one hundred', True, 100);

    DACMemoSetWheelScrollLinesQueryForTests(nil);
    AMemo.ScrollBars := System.UITypes.TScrollStyle.ssVertical;
    PumpMessages(50);
    LChildHandle := AMemo.MemoControl.Handle;
    Require((LChildHandle <> 0) and IsWindow(LChildHandle) and
      ((GetWindowLongPtr(LChildHandle, GWL_STYLE) and WS_VSCROLL) <> 0),
      'Fixture ssVertical nao materializou WS_VSCROLL.');
    LChildPoint := AMemo.MemoControl.ClientToScreen(
      Point(AMemo.MemoControl.ClientWidth div 2,
        AMemo.MemoControl.ClientHeight div 2));
    AMemo.MemoControl.SetFocus;
    PositionMemoAtBottom;
    PositionOuterAtBaseline;
    LOuterSnapshot := ReadVerticalScrollSnapshot(LChildHandle,
      'ssVertical child before wheel-up');
    SendRoutedWheel(LChildPoint, WHEEL_DELTA, nweChild,
      'ssVertical bottom wheel-up remains child');
    Require(ReadVerticalScrollSnapshot(LChildHandle,
      'ssVertical child after wheel-up').Position <
      LOuterSnapshot.Position,
      'ssVertical nao sincronizou a posicao da scrollbar nativa.');
    PositionMemoAtTop;
    PositionOuterAtBaseline;
    SendRoutedWheel(LChildPoint, WHEEL_DELTA, nweOuter,
      'ssVertical top wheel-up hands off outer');

    LSavedCaret := AMemo.MemoControl.SelStart;
    LSavedSelection := AMemo.MemoControl.SelLength;
    AMemo.MemoControl.SelStart := 0;
    AMemo.MemoControl.SelLength := Min(32,
      Length(AMemo.MemoControl.Text));
    LClipboardExpected := AMemo.MemoControl.SelText;
    try
      AMemo.MemoControl.CopyToClipboard;
      Require(Clipboard.AsText = LClipboardExpected,
        'Clipboard do Memo nativo nao preservou a selecao apos wheel.');
    except
      on E: EClipboardException do
      begin
        AMemo.MemoControl.Perform(WM_COPY, 0, 0);
        Require(AMemo.MemoControl.SelText = LClipboardExpected,
          'WM_COPY alterou a selecao do Memo com clipboard bloqueado.');
      end;
    end;
    AMemo.MemoControl.SelStart := LSavedCaret;
    AMemo.MemoControl.SelLength := LSavedSelection;
  finally
    DACMemoSetWheelScrollLinesQueryForTests(nil);
    TMemoWheelAccess(AMemo.MemoControl).OnMouseWheel := nil;
    TMemoWheelAccess(AMemo.MemoControl).OnMouseWheelDown := nil;
    TMemoWheelAccess(AMemo.MemoControl).OnMouseWheelUp := nil;
    LProbe.Free;
    SetCursorPos(LCursorBefore.X, LCursorBefore.Y);
    SetWindowPos(AForm.Handle, HWND_NOTOPMOST, 0, 0, 0, 0,
      SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);
    PositionOuterAtBaseline;
  end;
end;

procedure RequireComponent(const AForm: TForm; const AName: string;
  const AClass: TClass);
var
  LComponent: TComponent;
begin
  LComponent := AForm.FindComponent(AName);
  Require((LComponent <> nil) and LComponent.InheritsFrom(AClass),
    AName + ' nao foi instanciado como ' + AClass.ClassName + '.');
end;

function RectanglesOverlap(const AFirst, ASecond: TRect): Boolean;
begin
  Result := (AFirst.Left < ASecond.Right) and
    (AFirst.Right > ASecond.Left) and
    (AFirst.Top < ASecond.Bottom) and
    (AFirst.Bottom > ASecond.Top);
end;

function InputGalleryGeometrySignature(const AForm: TForm): string;
const
  ControlNames: array[0..20] of string = (
    'demoEdit', 'demoEditFilled', 'demoEditError', 'demoEditSuccess',
    'demoEditDisabled', 'demoEditReadOnly', 'demoEditLoading',
    'demoMemo', 'demoMemoFilled', 'demoMemoError', 'demoMemoSuccess',
    'demoMemoDisabled', 'demoMemoReadOnly', 'demoMemoLoading',
    'demoButtonEdit', 'demoButtonEditFilled', 'demoButtonEditError',
    'demoButtonEditSuccess', 'demoButtonEditDisabled',
    'demoButtonEditReadOnly', 'demoButtonEditLoading');
var
  I: Integer;
  LControl: TControl;
  LGrid: TDACGridContainer;
begin
  LGrid := AForm.FindComponent('gcInputStates') as TDACGridContainer;
  Result := Format('grid=%d,%d,%d,%d;',
    [LGrid.Left, LGrid.Top, LGrid.Width, LGrid.Height]);
  for I := Low(ControlNames) to High(ControlNames) do
  begin
    LControl := AForm.FindComponent(ControlNames[I]) as TControl;
    Result := Result + Format('%s=%d,%d,%d,%d;',
      [ControlNames[I], LControl.Left, LControl.Top, LControl.Width,
       LControl.Height]);
  end;
end;

procedure RequireInputGalleryGeometry(const AForm: TForm;
  const AContext: string; const ARequireScrollable: Boolean = True);
const
  ControlNames: array[0..20] of string = (
    'demoEdit', 'demoEditFilled', 'demoEditError', 'demoEditSuccess',
    'demoEditDisabled', 'demoEditReadOnly', 'demoEditLoading',
    'demoMemo', 'demoMemoFilled', 'demoMemoError', 'demoMemoSuccess',
    'demoMemoDisabled', 'demoMemoReadOnly', 'demoMemoLoading',
    'demoButtonEdit', 'demoButtonEditFilled', 'demoButtonEditError',
    'demoButtonEditSuccess', 'demoButtonEditDisabled',
    'demoButtonEditReadOnly', 'demoButtonEditLoading');
  TitleNames: array[0..3] of string = (
    'lblInputs', 'lblInputEditStates', 'lblInputMemoStates',
    'lblInputButtonEditStates');
var
  I: Integer;
  J: Integer;
  LAttempts: Integer;
  LAuthoredCount: Integer;
  LBottom: Integer;
  LControl: TControl;
  LControls: array[0..20] of TControl;
  LGrid: TDACGridContainer;
  LLabel: TLabel;
  LLast: TControl;
  LScroll: TDACScrollContainer;
  LTitle: TControl;
  LViewportBottom: Integer;
  LViewportTop: Integer;
begin
  LScroll := AForm.FindComponent('scrInputs') as TDACScrollContainer;
  LGrid := AForm.FindComponent('gcInputStates') as TDACGridContainer;
  Require((LScroll <> nil) and (LGrid <> nil) and
    (LGrid.Parent = LScroll) and (LGrid.Align = alTop) and
    LGrid.AutoContentHeight and LGrid.SizeRowsToContent and
    (LGrid.Columns = 7) and (LGrid.MinimumColumnWidth = 180),
    'Hierarquia/propriedades do layout de Inputs divergiram: ' + AContext);

  LAuthoredCount := 0;
  for I := 0 to LGrid.ControlCount - 1 do
    if not (LGrid.Controls[I] is TSkPaintBox) then
      Inc(LAuthoredCount);
  Require(LAuthoredCount = 25,
    Format('Grid de Inputs deve conter 21 estados + 4 titulos em %s; actual=%d.',
      [AContext, LAuthoredCount]));

  for I := Low(TitleNames) to High(TitleNames) do
  begin
    LTitle := AForm.FindComponent(TitleNames[I]) as TControl;
    Require((LTitle <> nil) and (LTitle.Parent = LGrid) and
      (LTitle.Tag = 12),
      'Titulo nao ocupa linha declarativa completa: ' + TitleNames[I] +
        ' / ' + AContext);
  end;

  LBottom := 0;
  for I := Low(ControlNames) to High(ControlNames) do
  begin
    LControls[I] := AForm.FindComponent(ControlNames[I]) as TControl;
    LControl := LControls[I];
    Require((LControl <> nil) and (LControl.Parent = LGrid) and
      (LControl is TWinControl) and (TWinControl(LControl).TabOrder = I),
      Format('Parent/TabOrder incorreto em %s (%s).',
        [ControlNames[I], AContext]));
    Require((LControl.Width >= LGrid.MinimumColumnWidth) and
      (LControl.Constraints.MinWidth = LGrid.MinimumColumnWidth),
      Format('%s ficou abaixo do token minimo em %s (width=%d min=%d).',
        [ControlNames[I], AContext, LControl.Width,
         LGrid.MinimumColumnWidth]));
    Require((LControl.Left >= LGrid.ContentPadding) and
      (LControl.BoundsRect.Right <=
        LGrid.ClientWidth - LGrid.ContentPadding),
      Format('%s escapou horizontalmente do grid em %s (left=%d right=%d client=%d padding=%d gridWidth=%d scrollClient=%d).',
        [ControlNames[I], AContext, LControl.Left,
         LControl.BoundsRect.Right, LGrid.ClientWidth,
         LGrid.ContentPadding, LGrid.Width, LScroll.ClientWidth]));

    LLabel := nil;
    if LControl is TDACEdit then
      LLabel := TDACEdit(LControl).NativeLabel
    else if LControl is TDACMemo then
      LLabel := TDACMemo(LControl).NativeLabel
    else if LControl is TDACButtonEdit then
      LLabel := TDACButtonEdit(LControl).NativeLabel;
    Require((LLabel <> nil) and LLabel.Visible and
      (LLabel.Canvas.TextWidth(LLabel.Caption) <= LLabel.ClientWidth),
      Format('Caption nativa truncada em %s (%s).',
        [ControlNames[I], AContext]));
    LBottom := Max(LBottom, LControl.BoundsRect.Bottom);
  end;

  for I := Low(LControls) to High(LControls) do
    for J := I + 1 to High(LControls) do
      Require(not RectanglesOverlap(LControls[I].BoundsRect,
        LControls[J].BoundsRect),
        Format('Sobreposicao visivel entre %s e %s (%s).',
          [ControlNames[I], ControlNames[J], AContext]));

  for I := Low(TitleNames) to High(TitleNames) do
  begin
    LTitle := AForm.FindComponent(TitleNames[I]) as TControl;
    for J := Low(LControls) to High(LControls) do
      Require(not RectanglesOverlap(LTitle.BoundsRect,
        LControls[J].BoundsRect),
        Format('Sobreposicao visivel entre %s e %s (%s).',
          [TitleNames[I], ControlNames[J], AContext]));
    for J := I + 1 to High(TitleNames) do
      Require(not RectanglesOverlap(LTitle.BoundsRect,
        (AForm.FindComponent(TitleNames[J]) as TControl).BoundsRect),
        Format('Sobreposicao visivel entre %s e %s (%s).',
          [TitleNames[I], TitleNames[J], AContext]));
    Require(LTitle.BoundsRect.Bottom <= LBottom,
      'Titulo ficou fora da altura de conteudo: ' + TitleNames[I] +
        ' / ' + AContext);
  end;
  Require(LGrid.Height = LBottom + LGrid.ContentPadding,
    Format('AutoContentHeight incorreto em %s (height=%d bottom=%d padding=%d).',
      [AContext, LGrid.Height, LBottom, LGrid.ContentPadding]));
  Require((LScroll.HorzScrollBar.Position = 0) and
    not LScroll.HorzScrollBar.Visible,
    'Inputs ativou scroll horizontal em ' + AContext + '.');
  if ARequireScrollable then
    Require(LScroll.VertScrollBar.Range > LScroll.ClientHeight,
      Format('Inputs compacto nao ativou scroll vertical em %s (range=%d viewport=%d).',
        [AContext, LScroll.VertScrollBar.Range, LScroll.ClientHeight]))
  else
    Require(LScroll.VertScrollBar.Range <= LScroll.ClientHeight,
      Format('Inputs desktop ativou scroll vertical desnecessario em %s (range=%d viewport=%d).',
        [AContext, LScroll.VertScrollBar.Range, LScroll.ClientHeight]));

  LLast := LControls[High(LControls)];
  LAttempts := 0;
  while (LLast.ClientToScreen(Point(0, LLast.Height)).Y >
    LScroll.ClientToScreen(Point(0, LScroll.ClientHeight)).Y) and
    (LAttempts < 20) do
  begin
    LScroll.Perform(WM_VSCROLL, SB_PAGEDOWN, 0);
    PumpMessages(15);
    Inc(LAttempts);
  end;
  LViewportTop := LScroll.ClientToScreen(Point(0, 0)).Y;
  LViewportBottom := LScroll.ClientToScreen(
    Point(0, LScroll.ClientHeight)).Y;
  Require((LLast.ClientToScreen(Point(0, 0)).Y < LViewportBottom) and
    (LLast.ClientToScreen(Point(0, LLast.Height)).Y > LViewportTop) and
    (LLast.ClientToScreen(Point(0, LLast.Height)).Y <= LViewportBottom),
    Format('Ultimo ButtonEdit nao ficou alcancavel pelo scroll em %s (top=%d bottom=%d viewport=%d..%d pos=%d range=%d).',
      [AContext, LLast.ClientToScreen(Point(0, 0)).Y,
       LLast.ClientToScreen(Point(0, LLast.Height)).Y, LViewportTop,
       LViewportBottom, LScroll.VertScrollBar.Position,
       LScroll.VertScrollBar.Range]));
  LScroll.Perform(WM_VSCROLL, SB_TOP, 0);
  PumpMessages(20);
end;

procedure RequireSvgIcon(const AKind: TDACIconKind);
var
  LSource: string;
  LDom: ISkSVGDOM;
begin
  LSource := TDACIconAssets.SvgSource(AKind, $FF1E5F2A);
  Require(LSource <> '', 'SVG ausente: ' + TDACIconAssets.Info(AKind).Name + '.');
  LDom := TSkSVGDOM.Make(LSource);
  Require(LDom <> nil, 'SVG invalido: ' + TDACIconAssets.Info(AKind).Name + '.');
end;

procedure RequireGridWithinViewport(const AGrid: TDACGridContainer;
  const AViewport: TDACScrollContainer; const AMargin: Integer);
var
  I: Integer;
  LChild: TControl;
  LViewportRect: TRect;
begin
  Require(Winapi.Windows.GetClientRect(AViewport.Handle, LViewportRect),
    'Nao foi possivel obter o viewport nativo do scroll.');
  Require((AGrid.Left >= AMargin) and
    (AGrid.Left + AGrid.Width <= LViewportRect.Right - AMargin),
    'A grade excedeu as margens do viewport.');
  for I := 0 to AGrid.ControlCount - 1 do
  begin
    LChild := AGrid.Controls[I];
    if not LChild.Visible or (LChild is TSkPaintBox) then
      Continue;
    Require((LChild.Left >= AGrid.ClientRect.Left) and
      (LChild.Left + LChild.Width <= AGrid.ClientRect.Right - 8) and
      (LChild.Top >= AGrid.ClientRect.Top) and
      (LChild.Top + LChild.Height <= AGrid.ClientRect.Bottom - 8),
      'Filho visivel da grade excedeu o viewport: ' + LChild.Name + '.');
  end;
end;

procedure RequireLongCaptionGridAtFixedWidth(const AOwner: TComponent);
const
  LongCaption = 'Acao longa sem truncamento para validar a grade';
var
  LFirst: TDACButton;
  LGrid: TDACGridContainer;
  LSecond: TDACButton;
  LWidth: Integer;
begin
  LGrid := TDACGridContainer.Create(AOwner);
  try
    LGrid.Parent := TWinControl(AOwner);
    LGrid.Columns := 12;
    LFirst := TDACButton.Create(LGrid);
    LFirst.Parent := LGrid;
    LFirst.Caption := LongCaption;
    LFirst.ShowIcon := True;
    LFirst.IconKind := mikSave;
    LFirst.Tag := 3;
    LSecond := TDACButton.Create(LGrid);
    LSecond.Parent := LGrid;
    LSecond.Caption := LongCaption;
    LSecond.ShowIcon := True;
    LSecond.IconKind := mikUpload;
    LSecond.Tag := 3;
    LWidth := LFirst.MinimumContentWidth + (LGrid.ContentPadding * 2);
    LGrid.SetBounds(8, 8, LWidth, 160);
    PumpMessages(30);
    Require((LFirst.Caption = LongCaption) and
      (LFirst.Width >= LFirst.MinimumContentWidth),
      'Caption longo foi truncado na largura fixa tokenizada.');
    Require((LSecond.Caption = LongCaption) and
      (LSecond.Width >= LSecond.MinimumContentWidth),
      'Segundo caption longo foi truncado na largura fixa tokenizada.');
  finally
    LGrid.Free;
  end;
end;

procedure RequireFormWithinMonitorWorkArea(const AForm: TForm);
var
  LMonitor: TMonitor;
  LWorkArea: TRect;
begin
  LMonitor := AForm.Monitor;
  Require(LMonitor <> nil, 'Nao foi possivel localizar o monitor da Demo.');
  LWorkArea := LMonitor.WorkareaRect;
  Require((AForm.Left >= LWorkArea.Left) and (AForm.Top >= LWorkArea.Top) and
    (AForm.Left + AForm.Width <= LWorkArea.Right) and
    (AForm.Top + AForm.Height <= LWorkArea.Bottom),
    'A Demo excedeu a area util do monitor efetivo.');
end;

procedure RequireThemeToggleHitTarget(const AForm: TForm1;
  const AExpectedHandle: HWND; const AExpectedRect: TRect;
  const AExpectedCaption, AContext: string);
var
  LClassName: array[0..127] of Char;
  LCurrentRect: TRect;
  LHeader: TDACTabHeaderControl;
  LHitTarget: HWND;
  LPoint: TPoint;
  LToggle: TDACButton;
begin
  LToggle := AForm.FindComponent('demoThemeToggle') as TDACButton;
  Require((LToggle <> nil) and LToggle.HandleAllocated and
    (LToggle.Handle = AExpectedHandle) and LToggle.Visible and
    IsWindowVisible(LToggle.Handle) and
    SameText(LToggle.Caption, AExpectedCaption),
    AContext + ': toggle perdeu handle, visibilidade ou texto.');
  if AExpectedCaption = '' then
    Require((LToggle.Width = LToggle.Height) and LToggle.ShowIcon and
      (((TDACThemeManager.ApplicationMode = dtmDark) and
        (LToggle.IconKind = mikThemeSun)) or
       ((TDACThemeManager.ApplicationMode = dtmLight) and
        (LToggle.IconKind = mikThemeMoon))),
      AContext + ': toggle compacto perdeu geometria ou icone semantico.');
  Require(GetWindowRect(LToggle.Handle, LCurrentRect) and
    EqualRect(LCurrentRect, AExpectedRect),
    AContext + ': toggle mudou de retangulo apos o tema.');
  LPoint := Point((LCurrentRect.Left + LCurrentRect.Right) div 2,
    (LCurrentRect.Top + LCurrentRect.Bottom) div 2);
  LHitTarget := WindowFromPoint(LPoint);
  FillChar(LClassName, SizeOf(LClassName), 0);
  if LHitTarget <> 0 then
    GetClassName(LHitTarget, LClassName, Length(LClassName));
  Require((LHitTarget = LToggle.Handle) or
    IsChild(LToggle.Handle, LHitTarget),
    Format('%s: centro do toggle nao pertence ao toggle/descendente ' +
      '(hit=%d expected=%d class=%s).',
      [AContext, LHitTarget, LToggle.Handle, string(LClassName)]));
  LHeader := FindTabHeader(AForm.GalleryTabs);
  if (LHeader <> nil) and LHeader.HandleAllocated then
    Require((LHitTarget <> LHeader.Handle) and
      not IsChild(LHeader.Handle, LHitTarget),
      AContext + ': header das tabs cobriu o centro do toggle.');
end;

procedure RequireScrollViewportSurface(const AViewport: TDACScrollContainer;
  const AStage: string);
const
  SampleMargin = 12;
  SampleStep = 4;
  ColorTolerance = 24;
var
  LClientRect: TRect;
  LDC: HDC;
  LExpected: COLORREF;
  LLeftMatchCount: Integer;
  LPixel: COLORREF;
  LRequiredMatchCount: Integer;
  LRightMatchCount: Integer;
  LSampleCount: Integer;
  LSampleY: Integer;
  function Component(const AColor: COLORREF; const AShift: Integer): Byte;
  begin
    Result := Byte((AColor shr AShift) and $FF);
  end;
  function MatchesSurface(const AColor: COLORREF): Boolean;
  begin
    Result := (Abs(Integer(Component(AColor, 0)) -
      Integer(Component(LExpected, 0))) <= ColorTolerance) and
      (Abs(Integer(Component(AColor, 8)) -
      Integer(Component(LExpected, 8))) <= ColorTolerance) and
      (Abs(Integer(Component(AColor, 16)) -
      Integer(Component(LExpected, 16))) <= ColorTolerance);
  end;
begin
  Require(Winapi.Windows.GetClientRect(AViewport.Handle, LClientRect),
    'Nao foi possivel obter o viewport para validar a surface: ' + AStage);
  Require((LClientRect.Right > SampleMargin * 2) and
    (LClientRect.Bottom > SampleMargin * 2),
    'Viewport insuficiente para validar a surface: ' + AStage);
  LExpected := ColorToRGB(TDACComponentColors.ToVclColor(
    TDACComponentColors.Normalize(AViewport.BackgroundColor)));
  LLeftMatchCount := 0;
  LRightMatchCount := 0;
  LSampleCount := 0;
  LDC := GetDC(AViewport.Handle);
  try
    Require(LDC <> 0, 'Nao foi possivel acessar pixels do viewport: ' + AStage);
    LSampleY := SampleMargin;
    while LSampleY <= LClientRect.Bottom - SampleMargin do
    begin
      Inc(LSampleCount);
      LPixel := GetPixel(LDC, SampleMargin, LSampleY);
      if (LPixel <> CLR_INVALID) and MatchesSurface(LPixel) then
        Inc(LLeftMatchCount);
      LPixel := GetPixel(LDC, LClientRect.Right - SampleMargin, LSampleY);
      if (LPixel <> CLR_INVALID) and MatchesSurface(LPixel) then
        Inc(LRightMatchCount);
      Inc(LSampleY, SampleStep);
    end;
    // Content controls may legitimately cross one of the sampled edge
    // coordinates (notably a long, horizontally scrollable action).  Verify
    // a continuous edge band instead of requiring three arbitrary pixels to
    // all be bare viewport.  A stale native white surface still yields no
    // meaningful coverage, while tokenized gaps remain observable.
    LRequiredMatchCount := Max(1, LSampleCount div 8);
    Require(LLeftMatchCount >= LRequiredMatchCount,
      Format('Faixa esquerda sem cobertura suficiente da surface/token ' +
        'apos scroll (%s): matches=%d/%d required=%d.',
        [AStage, LLeftMatchCount, LSampleCount, LRequiredMatchCount]));
    Require(LRightMatchCount >= LRequiredMatchCount,
      Format('Faixa direita sem cobertura suficiente da surface/token ' +
        'apos scroll (%s): matches=%d/%d required=%d.',
        [AStage, LRightMatchCount, LSampleCount, LRequiredMatchCount]));
  finally
    if LDC <> 0 then
      ReleaseDC(AViewport.Handle, LDC);
  end;
end;

procedure RequireScrollChromeViewport(const AViewport: TDACScrollContainer;
  const AExpectedRange: Integer; const AStage: string);
var
  I: Integer;
  LPaintBox: TSkPaintBox;
begin
  LPaintBox := nil;
  for I := 0 to AViewport.ControlCount - 1 do
    if AViewport.Controls[I] is TSkPaintBox then
    begin
      LPaintBox := TSkPaintBox(AViewport.Controls[I]);
      Break;
    end;
  Require(LPaintBox <> nil, 'Surface Skia do scroll ausente: ' + AStage);
  Require(LPaintBox.Align = alClient,
    'Surface Skia entrou na area rolavel: ' + AStage);
  Require(AViewport.VertScrollBar.Range = AExpectedRange,
    'A surface alterou o range vertical durante o scroll: ' + AStage);
end;

procedure RequireTabHeaderFrame(const AHeader: TDACTabHeaderControl;
  const AStage: string);
var
  I: Integer;
  LPaintBox: TSkPaintBox;
begin
  Require((AHeader <> nil) and AHeader.Showing and AHeader.HandleAllocated,
    'Header Skia ausente no frame: ' + AStage);
  Require((AHeader.Width > 0) and (AHeader.Height > 0),
    'Header Skia sem bounds no frame: ' + AStage);
  LPaintBox := nil;
  for I := 0 to AHeader.ControlCount - 1 do
    if AHeader.Controls[I] is TSkPaintBox then
    begin
      LPaintBox := TSkPaintBox(AHeader.Controls[I]);
      Break;
    end;
  Require((LPaintBox <> nil) and LPaintBox.Visible and
    (LPaintBox.Width = AHeader.ClientWidth) and
    (LPaintBox.Height = AHeader.ClientHeight),
    'Frame sem a superficie Skia ativa do header: ' + AStage);
  // The interaction process runs without a readable desktop framebuffer:
  // PrintWindow omits Vcl.Skia and BitBlt is denied. Physical PNG capture is
  // therefore delegated to the QA harness; this assertion is the honest
  // state/bounds sequence gate for transient header flicker.
end;

procedure RequireChartBottomRightSurface(const AForm: TForm;
  const AChart: TDACChart; const AName: string);
const
  SampleOffsets: array[0..1] of Integer = (3, 10);
var
  I: Integer;
  LBitmap: TBitmap;
  LChartRect: TRect;
  LFormRect: TRect;
  LPixel: TColor;
  LRed: Byte;
  LGreen: Byte;
  LBlue: Byte;
begin
  Require(Winapi.Windows.GetWindowRect(AForm.Handle, LFormRect) and
    Winapi.Windows.GetWindowRect(AChart.Handle, LChartRect),
    'Nao foi possivel obter bounds do chart: ' + AName);
  LBitmap := TBitmap.Create;
  try
    LBitmap.PixelFormat := pf32bit;
    LBitmap.SetSize(LFormRect.Width, LFormRect.Height);
    Require(NativePrintWindow(AForm.Handle, LBitmap.Canvas.Handle, 0),
      'PrintWindow falhou no chart: ' + AName);
    for I := Low(SampleOffsets) to High(SampleOffsets) do
    begin
      LPixel := ColorToRGB(LBitmap.Canvas.Pixels[
        LChartRect.Right - LFormRect.Left - SampleOffsets[I],
        LChartRect.Bottom - LFormRect.Top - SampleOffsets[I]]);
      LRed := GetRValue(LPixel);
      LGreen := GetGValue(LPixel);
      LBlue := GetBValue(LPixel);
      Require((LRed >= 180) and (LGreen >= 180) and (LBlue >= 180),
        'Canto inferior direito do chart contem artefato escuro: ' +
        AName + '.');
    end;
  finally
    LBitmap.Free;
  end;
end;

procedure RequireSemiTransparentRaster;
const
  ColorTolerance = 10;
var
  LBackground: TAlphaColor;
  LCard: TDACSummaryCard;
  LChart: TDACChart;
  LExpected: TColor;
  LForm: TForm;
  LPixel: TColor;
  LSurface: TAlphaColor;
  function Blend(const ABack, AFront, AAlpha: Byte): Byte;
  begin
    Result := (Integer(ABack) * (255 - Integer(AAlpha)) +
      Integer(AFront) * Integer(AAlpha) + 127) div 255;
  end;
  function BlendedColor(const ABack, AFront: TAlphaColor): TColor;
  var
    LAlpha: Byte;
    LBlue: Byte;
    LGreen: Byte;
    LRed: Byte;
  begin
    LAlpha := Byte((Cardinal(AFront) shr 24) and $FF);
    LRed := Blend(Byte((Cardinal(ABack) shr 16) and $FF),
      Byte((Cardinal(AFront) shr 16) and $FF), LAlpha);
    LGreen := Blend(Byte((Cardinal(ABack) shr 8) and $FF),
      Byte((Cardinal(AFront) shr 8) and $FF), LAlpha);
    LBlue := Blend(Byte(Cardinal(ABack) and $FF),
      Byte(Cardinal(AFront) and $FF), LAlpha);
    Result := RGB(LRed, LGreen, LBlue);
  end;
  procedure RequireBlendAt(const AControl: TControl; const AX, AY: Integer;
    const AName: string);
  var
    LActualBlue: Integer;
    LActualGreen: Integer;
    LActualRed: Integer;
    LExpectedBlue: Integer;
    LExpectedGreen: Integer;
    LExpectedRed: Integer;
    LBitmap: TBitmap;
  begin
    LBitmap := TBitmap.Create;
    try
      LBitmap.PixelFormat := pf32bit;
      LBitmap.SetSize(AControl.Width, AControl.Height);
      LBitmap.Canvas.Brush.Color := TDACComponentColors.ToVclColor(LBackground);
      LBitmap.Canvas.FillRect(Rect(0, 0, LBitmap.Width, LBitmap.Height));
      TWinControl(AControl).PaintTo(LBitmap.Canvas.Handle, 0, 0);
      LPixel := ColorToRGB(LBitmap.Canvas.Pixels[AX, AY]);
    finally
      LBitmap.Free;
    end;
    LActualRed := GetRValue(LPixel);
    LActualGreen := GetGValue(LPixel);
    LActualBlue := GetBValue(LPixel);
    LExpectedRed := GetRValue(LExpected);
    LExpectedGreen := GetGValue(LExpected);
    LExpectedBlue := GetBValue(LExpected);
    Require((Abs(LActualRed - LExpectedRed) <= ColorTolerance) and
      (Abs(LActualGreen - LExpectedGreen) <= ColorTolerance) and
      (Abs(LActualBlue - LExpectedBlue) <= ColorTolerance),
      Format('%s nao realizou blend raster (RGB atual %d,%d,%d; esperado %d,%d,%d).',
        [AName, LActualRed, LActualGreen, LActualBlue, LExpectedRed,
         LExpectedGreen, LExpectedBlue]));
  end;
begin
  LBackground := TDACComponentColors.Alpha($08, $13, $0D);
  LSurface := TDACComponentColors.Alpha($0E, $1F, $15, 128);
  LExpected := BlendedColor(LBackground, LSurface);
  LForm := TForm.Create(nil);
  try
    LForm.Color := TDACComponentColors.ToVclColor(LBackground);
    LForm.ClientWidth := 510;
    LForm.ClientHeight := 190;
    LForm.Position := poScreenCenter;
    LCard := TDACSummaryCard.Create(LForm);
    LCard.Parent := LForm;
    LCard.SetBounds(20, 24, 210, 116);
    LCard.BackgroundColor := LSurface;
    LCard.BorderColor := TAlphaColor($00000000);
    LCard.Title := 'Raster';
    LCard.Value := '128';
    LChart := TDACChart.Create(LForm);
    LChart.Parent := LForm;
    LChart.SetBounds(260, 24, 220, 116);
    LChart.BackgroundColor := LSurface;
    LChart.BorderColor := TAlphaColor($00000000);
    LChart.ChartGrid.Visible := False;
    LForm.Show;
    PumpMessages(120);
    RequireBlendAt(LCard, LCard.Width - 16, LCard.Height div 2, 'SummaryCard');
    RequireBlendAt(LChart, LChart.Width - 16, LChart.Height - 16, 'BarChart');
  finally
    LForm.Free;
  end;
end;

function ReadTextComponent(const AText: string): TComponent;
var
  LBinary: TMemoryStream;
  LText: TStringStream;
begin
  LBinary := TMemoryStream.Create;
  LText := TStringStream.Create(AText);
  try
    ObjectTextToBinary(LText, LBinary);
    LBinary.Position := 0;
    Result := LBinary.ReadComponent(nil);
  finally
    LText.Free;
    LBinary.Free;
  end;
end;

procedure RequireFieldStateAndStreaming;
var
  LButtonEdit: TDACButtonEdit;
  LCombo: TDACComboBox;
  LComponent: TComponent;
  LDate: TDACDateTimePicker;
  LEdit: TDACEdit;
  LMemo: TDACMemo;
  LState: TDACResolvedFieldState;
begin
  Require((Ord(mesNormal) = 0) and (Ord(mesSuccess) = 1) and
    (Ord(mesWarning) = 2) and (Ord(mesDanger) = 3),
    'TDACEditStatus alterou os ordinais publicos existentes.');

  LState := TDACFieldStateResolver.Resolve(False, True, True, True, True,
    True, mfvDanger);
  Require((LState.Availability = mfaDisabled) and
    (LState.Validation = mfvDanger) and
    (LState.Interaction = mfiFocused) and
    (LState.Content = mfcFilled),
    'Resolver de campo nao preservou Disabled > validacao/foco/conteudo.');
  LState := TDACFieldStateResolver.Resolve(True, True, True, False, True,
    False, mfvSuccess);
  Require((LState.Availability = mfaLoading) and
    (LState.Validation = mfvSuccess) and
    (LState.Interaction = mfiHover) and
    (LState.Content = mfcEmpty),
    'Resolver de campo nao preservou Loading > ReadOnly > Editable.');
  LState := TDACFieldStateResolver.Resolve(True, False, True, True, False,
    True, mfvWarning);
  Require((LState.Availability = mfaReadOnly) and
    (LState.Validation = mfvWarning) and
    (LState.Interaction = mfiFocused),
    'ReadOnly apagou validacao ou foco no estado ortogonal.');
  LState := TDACFieldStateResolver.Resolve(True, False, False, False, False,
    False, mfvNormal);
  Require(LState.Availability = mfaEditable,
    'Resolver de campo nao retornou Editable sem barreiras.');

  RequirePublishedDefault(TDACEdit, 'Loading', 0);
  RequirePublishedDefault(TDACEdit, 'ReadOnly', 0);
  RequirePublishedDefault(TDACButtonEdit, 'Loading', 0);
  RequirePublishedDefault(TDACButtonEdit, 'ReadOnly', 0);
  RequirePublishedDefault(TDACMemo, 'Loading', 0);
  RequirePublishedDefault(TDACMemo, 'ReadOnly', 0);
  RequirePublishedDefault(TDACComboBox, 'Loading', 0);
  RequirePublishedDefault(TDACComboBox, 'ReadOnly', 0);
  RequirePublishedDefault(TDACDateTimePicker, 'Loading', 0);
  RequirePublishedDefault(TDACDateTimePicker, 'ReadOnly', 0);

  System.Classes.RegisterClass(TDACEdit);
  System.Classes.RegisterClass(TDACButtonEdit);
  System.Classes.RegisterClass(TDACMemo);
  System.Classes.RegisterClass(TDACComboBox);
  System.Classes.RegisterClass(TDACDateTimePicker);

  LComponent := ReadTextComponent(
    'object Field: TDACEdit' + sLineBreak +
    '  ErrorText = ''Erro edit''' + sLineBreak +
    '  HelperText = ''Ajuda edit''' + sLineBreak +
    '  Loading = True' + sLineBreak +
    '  ReadOnly = True' + sLineBreak +
    'end');
  try
    LEdit := TDACEdit(LComponent);
    Require((LEdit.ErrorText = 'Erro edit') and
      (LEdit.HelperText = 'Ajuda edit') and LEdit.Loading and LEdit.ReadOnly,
      'Roundtrip DFM perdeu propriedades novas do Edit.');
    Require(not LEdit.TabStop,
      'Edit streamed em Loading permaneceu na ordem de Tab.');
    LEdit.Loading := False;
    Require(LEdit.TabStop,
      'Edit nao restaurou TabStop default apos Loading streamed.');
  finally
    LComponent.Free;
  end;

  LComponent := ReadTextComponent(
    'object Field: TDACButtonEdit' + sLineBreak +
    '  ErrorText = ''Erro button''' + sLineBreak +
    '  HelperText = ''Ajuda button''' + sLineBreak +
    '  Loading = True' + sLineBreak +
    '  ReadOnly = True' + sLineBreak +
    'end');
  try
    LButtonEdit := TDACButtonEdit(LComponent);
    Require((LButtonEdit.ErrorText = 'Erro button') and
      (LButtonEdit.HelperText = 'Ajuda button') and
      LButtonEdit.Loading and LButtonEdit.ReadOnly,
      'Roundtrip DFM perdeu proxies novos do ButtonEdit.');
    Require(not LButtonEdit.TabStop,
      'ButtonEdit streamed em Loading permaneceu na ordem de Tab.');
    LButtonEdit.Loading := False;
    Require(LButtonEdit.TabStop,
      'ButtonEdit nao restaurou TabStop default apos Loading streamed.');
  finally
    LComponent.Free;
  end;

  LComponent := ReadTextComponent(
    'object Field: TDACMemo' + sLineBreak +
    '  ErrorText = ''Erro memo''' + sLineBreak +
    '  HelperText = ''Ajuda memo''' + sLineBreak +
    '  Loading = True' + sLineBreak +
    '  ReadOnly = True' + sLineBreak +
    'end');
  try
    LMemo := TDACMemo(LComponent);
    Require((LMemo.ErrorText = 'Erro memo') and
      (LMemo.HelperText = 'Ajuda memo') and LMemo.Loading and LMemo.ReadOnly,
      'Roundtrip DFM perdeu propriedades novas do Memo.');
    Require(not LMemo.TabStop,
      'Memo streamed em Loading permaneceu na ordem de Tab.');
    LMemo.Loading := False;
    Require(LMemo.TabStop,
      'Memo nao restaurou TabStop default apos Loading streamed.');
  finally
    LComponent.Free;
  end;

  LComponent := ReadTextComponent(
    'object Field: TDACComboBox' + sLineBreak +
    '  ErrorText = ''Erro combo''' + sLineBreak +
    '  HelperText = ''Ajuda combo''' + sLineBreak +
    '  Items.Strings = (' + sLineBreak +
    '    ''Alpha''' + sLineBreak +
    '    ''Beta''' + sLineBreak +
    '    ''Charlie'')' + sLineBreak +
    '  ItemIndex = 1' + sLineBreak +
    '  Loading = True' + sLineBreak +
    '  ReadOnly = True' + sLineBreak +
    '  Text = ''Beta''' + sLineBreak +
    'end');
  try
    LCombo := TDACComboBox(LComponent);
    Require((LCombo.ErrorText = 'Erro combo') and
      (LCombo.HelperText = 'Ajuda combo') and LCombo.Loading and
      LCombo.ReadOnly and (LCombo.Items.Count = 3) and
      (LCombo.ItemIndex = 1) and (LCombo.Text = 'Beta'),
      'Roundtrip DFM perdeu estado, Items, ItemIndex ou Text do ComboBox.');
    Require(not LCombo.TabStop,
      'Combo streamed em Loading permaneceu na ordem de Tab.');
    LCombo.Loading := False;
    Require(LCombo.TabStop,
      'Combo nao restaurou TabStop default apos Loading streamed.');
  finally
    LComponent.Free;
  end;

  LComponent := ReadTextComponent(
    'object Field: TDACComboBox' + sLineBreak +
    '  Items.Strings = (' + sLineBreak +
    '    ''Alpha''' + sLineBreak +
    '    ''Beta'')' + sLineBreak +
    '  Style = csDropDown' + sLineBreak +
    '  Text = ''Custom''' + sLineBreak +
    'end');
  try
    LCombo := TDACComboBox(LComponent);
    Require((LCombo.Style = csDropDown) and (LCombo.ItemIndex = -1) and
      (LCombo.Text = 'Custom'),
      'Roundtrip DFM perdeu texto custom do Combo csDropDown.');
  finally
    LComponent.Free;
  end;

  LComponent := ReadTextComponent(
    'object Field: TDACComboBox' + sLineBreak +
    '  Items.Strings = (' + sLineBreak +
    '    ''Alpha''' + sLineBreak +
    '    ''Beta'')' + sLineBreak +
    '  Text = ''Custom''' + sLineBreak +
    'end');
  try
    LCombo := TDACComboBox(LComponent);
    Require((LCombo.Style = csDropDownList) and (LCombo.ItemIndex = -1) and
      (LCombo.Text = ''),
      'Roundtrip DFM manteve texto invalido no Combo csDropDownList.');
  finally
    LComponent.Free;
  end;

  LComponent := ReadTextComponent(
    'object Field: TDACDateTimePicker' + sLineBreak +
    '  ErrorText = ''Erro date''' + sLineBreak +
    '  HelperText = ''Ajuda date''' + sLineBreak +
    '  Loading = True' + sLineBreak +
    '  ReadOnly = True' + sLineBreak +
    'end');
  try
    LDate := TDACDateTimePicker(LComponent);
    Require((LDate.ErrorText = 'Erro date') and
      (LDate.HelperText = 'Ajuda date') and LDate.Loading and LDate.ReadOnly,
      'Roundtrip DFM perdeu propriedades novas do DateTimePicker.');
    Require(not LDate.TabStop,
      'Date streamed em Loading permaneceu na ordem de Tab.');
    LDate.Loading := False;
    Require(LDate.TabStop,
      'Date nao restaurou TabStop default apos Loading streamed.');
  finally
    LComponent.Free;
  end;
end;

procedure RequireDataAwareViewport(const AForm: TForm1;
  const AWidth, AHeight: Integer; const AMode: TDACThemeMode;
  const AScenario: string);
var
  LContent: TDACGridContainer;
  LActions: TDACGridContainer;
  LGrid: TDACDataGrid;
  LGridRect: TRect;
  LIntersection: TRect;
  LNavigator: TDACDBNavigator;
  LNavigation: TDACScrollContainer;
  LScroll: TDACScrollContainer;
  LScrollRect: TRect;
  LThemeToggle: TControl;
begin
  TDACThemeManager.SetApplicationMode(AMode);
  AForm.SetBounds(AForm.Left, AForm.Top, AWidth, AHeight);
  AForm.GalleryTabs.ActivePage :=
    AForm.FindComponent('tsDataAware') as TTabSheet;
  PumpMessages(80);
  LScroll := AForm.FindComponent('scrDataAware') as TDACScrollContainer;
  LContent := AForm.FindComponent('gcDataAwareContent') as TDACGridContainer;
  LActions := AForm.FindComponent('gcDataAwareActions') as TDACGridContainer;
  LNavigator := AForm.FindComponent('demoDBNavigator') as TDACDBNavigator;
  LGrid := AForm.FindComponent('demoDataAwareGrid') as TDACDataGrid;
  LNavigation := AForm.FindComponent('demoNavigation') as TDACScrollContainer;
  LThemeToggle := AForm.FindComponent('demoThemeToggle') as TControl;
  Require((LScroll <> nil) and (LContent <> nil) and
    (LActions <> nil) and (LNavigator <> nil) and (LGrid <> nil) and
    (LNavigation <> nil) and (LThemeToggle <> nil),
    'Data-Aware incompleto em ' + AScenario + '.');
  Require((LScroll.ScrollBarMode = msbmBoth) and
    (LContent.Parent = LScroll) and (LNavigator.Parent = LContent) and
    (LGrid.Parent = LContent),
    'Navigator/DataGrid escaparam do scroll/container declarativo em ' +
      AScenario + '.');
  Require((LContent.Width >= LGrid.Left + LGrid.Width + 24) and
    (LContent.Height >= LNavigator.Top + LNavigator.Height + 24),
    'Canvas Data-Aware corta Navigator/DataGrid em ' + AScenario + '.');
  if (AWidth <= 520) and (AHeight <= 560) then
  begin
    Require(LNavigation.Visible and
      (LNavigation.Width = TDACDemoTokens.Default.NavigationCompactWidth) and
      (AForm.GalleryTabs.Left = LNavigation.Left + LNavigation.Width) and
      (LThemeToggle.Left >= LNavigation.Left + LNavigation.Width) and
      (LThemeToggle.Width = LThemeToggle.Height) and
      AForm.GalleryTabs.ActivePageHeaderOnly,
      Format('Shell compacto sobrepos sidebar/header/toggle em %s '
        + '(nav visible=%s left=%d width=%d; tabs left=%d; toggle left=%d '
        + 'size=%dx%d; active-only=%s).', [AScenario,
        BoolToStr(LNavigation.Visible, True), LNavigation.Left,
        LNavigation.Width, AForm.GalleryTabs.Left, LThemeToggle.Left,
        LThemeToggle.Width, LThemeToggle.Height,
        BoolToStr(AForm.GalleryTabs.ActivePageHeaderOnly, True)]));
    Require((LScroll.HorzScrollBar.Range > LScroll.ClientWidth) and
      (LScroll.VertScrollBar.Range > LScroll.ClientHeight),
      'Viewport compacto nao materializou scroll horizontal/vertical em ' +
        AScenario + '.');
    LScroll.HorzScrollBar.Position :=
      Max(0, LGrid.Left + LGrid.Width - LScroll.ClientWidth);
    LScroll.VertScrollBar.Position :=
      Max(0, LGrid.Top + LGrid.Height - LScroll.ClientHeight);
    PumpMessages(40);
    Require((LScroll.HorzScrollBar.Position > 0) and
      (LScroll.VertScrollBar.Position > 0),
      'Scroll compacto nao alcancou o DataGrid em ' + AScenario + '.');
    LScrollRect.TopLeft := LScroll.ClientToScreen(Point(0, 0));
    LScrollRect.BottomRight := LScroll.ClientToScreen(
      Point(LScroll.ClientWidth, LScroll.ClientHeight));
    LGridRect.TopLeft := LGrid.ClientToScreen(Point(0, 0));
    LGridRect.BottomRight := LGrid.ClientToScreen(
      Point(LGrid.Width, LGrid.Height));
    Require(IntersectRect(LIntersection, LScrollRect, LGridRect),
      'DataGrid nao ficou acessivel pelo scroll em ' + AScenario + '.');
    LScroll.HorzScrollBar.Position := 0;
    LScroll.VertScrollBar.Position :=
      Max(0, LActions.Top + LActions.Height - LScroll.ClientHeight);
    PumpMessages(40);
    Require(LScroll.VertScrollBar.Position > 0,
      'Acoes Data-Aware nao ficaram acessiveis no viewport compacto em ' +
        AScenario + '.');
  end;
  LScroll.HorzScrollBar.Position := 0;
  LScroll.VertScrollBar.Position := 0;
  Require((LNavigator.DataSource =
    AForm.FindComponent('demoGridDataSource')) and
    (LGrid.DataSource = AForm.FindComponent('demoGridDataSource')),
    'Roundtrip de layout/tema perdeu binding em ' + AScenario + '.');
end;

procedure ExerciseDataAwareLayoutMatrix(const AForm: TForm1);
var
  LHeight: Integer;
  LMode: TDACThemeMode;
  LPage: TTabSheet;
  LWidth: Integer;
begin
  LWidth := AForm.Width;
  LHeight := AForm.Height;
  LMode := TDACThemeManager.ApplicationMode;
  LPage := AForm.GalleryTabs.ActivePage;
  try
    RequireDataAwareViewport(AForm, 1824, 1197, dtmLight,
      '1824x1197 light');
    RequireDataAwareViewport(AForm, 1824, 1197, dtmDark,
      '1824x1197 dark');
    RequireDataAwareViewport(AForm, 1200, 760, dtmLight,
      '1200x760 light');
    RequireDataAwareViewport(AForm, 1200, 760, dtmDark,
      '1200x760 dark');
    RequireDataAwareViewport(AForm, 520, 560, dtmLight,
      '520x560 light');
    RequireDataAwareViewport(AForm, 520, 560, dtmDark,
      '520x560 dark');
    RequireDataAwareViewport(AForm, 520, 560, dtmLight,
      '520x560 roundtrip dark-light');
  finally
    TDACThemeManager.SetApplicationMode(LMode);
    AForm.SetBounds(AForm.Left, AForm.Top, LWidth, LHeight);
    AForm.GalleryTabs.ActivePage := LPage;
    PumpMessages(80);
  end;
end;

procedure RequireDataAwareThemeSurfaces(const AForm: TForm1);
var
  LButtonEdit: TDACDBButtonEdit;
  LCheck: TDACDBCheckBox;
  LCombo: TDACDBComboBox;
  LDate: TDACDBDateTimePicker;
  LDBText: TDACDBText;
  LEdit: TDACDBEdit;
  LGrid: TDACDataGrid;
  LHeight: Integer;
  LLookup: TDACDBLookupComboBox;
  LMemo: TDACDBMemo;
  LMode: TDACThemeMode;
  LPage: TTabSheet;
  LGridCaptureStatus: string;
  LScroll: TDACScrollContainer;
  LScrollCaptureStatus: string;
  LScrollHorzBefore: Integer;
  LScrollPositionCaptured: Boolean;
  LScrollVertBefore: Integer;
  LSurface: TAlphaColor;
  LText: TDACSystemText;
  LToggle: TDACDBToggleSwitch;
  LTokens: TDACControlTokens;
  LWidth: Integer;
  function ColorDistance(const AActual, AExpected: COLORREF): Integer;
  begin
    Result := Abs(Integer(GetRValue(AActual)) - Integer(GetRValue(AExpected))) +
      Abs(Integer(GetGValue(AActual)) - Integer(GetGValue(AExpected))) +
      Abs(Integer(GetBValue(AActual)) - Integer(GetBValue(AExpected)));
  end;
  procedure RequireNativeClientSurface(const AControl: TWinControl;
    const AExpected: TAlphaColor; const AName, AScenario: string);
  const
    ColorTolerance = 18;
    SampleMargin = 5;
    SampleStepX = 17;
    SampleStepY = 9;
  var
    LBestDistance: Integer;
    LClientRect: TRect;
    LDC: HDC;
    LExpected: COLORREF;
    LMatchCount: Integer;
    LPixel: COLORREF;
    LSampleCount: Integer;
    LX: Integer;
    LY: Integer;
  begin
    Require((AControl <> nil) and AControl.HandleAllocated,
      AName + ' sem HWND real em ' + AScenario + '.');
    AControl.Update;
    GetClientRect(AControl.Handle, LClientRect);
    Require((LClientRect.Width > SampleMargin * 2) and
      (LClientRect.Height > SampleMargin * 2),
      AName + ' sem client area amostravel em ' + AScenario + '.');
    LExpected := ColorToRGB(TDACComponentColors.ToVclColor(AExpected));
    LBestDistance := MaxInt;
    LMatchCount := 0;
    LSampleCount := 0;
    LDC := GetDC(AControl.Handle);
    Require(LDC <> 0, AName + ' sem DC nativo em ' + AScenario + '.');
    try
      LY := SampleMargin;
      while LY < LClientRect.Bottom - SampleMargin do
      begin
        LX := SampleMargin;
        while LX < LClientRect.Right - SampleMargin do
        begin
          LPixel := GetPixel(LDC, LX, LY);
          if LPixel <> CLR_INVALID then
          begin
            Inc(LSampleCount);
            LBestDistance := Min(LBestDistance,
              ColorDistance(LPixel, LExpected));
            if ColorDistance(LPixel, LExpected) <= ColorTolerance then
              Inc(LMatchCount);
          end;
          Inc(LX, SampleStepX);
        end;
        Inc(LY, SampleStepY);
      end;
    finally
      ReleaseDC(AControl.Handle, LDC);
    end;
    Require((LSampleCount > 0) and
      (LMatchCount >= Max(2, LSampleCount div 4)),
      Format('%s nao exibiu surface nativa esperada em %s ' +
        '(matches=%d/%d best-distance=%d).',
        [AName, AScenario, LMatchCount, LSampleCount, LBestDistance]));
  end;
  function CaptureDarkNativeScrollBar(const AControl: TWinControl;
    const AName, AScenario: string): string;
  type
    TPartCapture = record
      Name: string;
      CanonicalRect: TRect;
      VisibleRect: TRect;
      PrimaryColor: COLORREF;
      AccentColor: COLORREF;
      RequireAccent: Boolean;
      Candidates: Integer;
      NoOwner: Integer;
      OwnerDCValid: Integer;
      ScreenDCValid: Integer;
      Invalid: Integer;
      Valid: Integer;
      Matched: Integer;
      AccentMatched: Integer;
      FirstOwner: HWND;
      OwnerChanges: Integer;
      Status: string;
    end;
  const
    ColorTolerance = 18;
    NativeObjectIdVScroll = -5;
  var
    LClientOrigin: TPoint;
    LMonitorInfo: TMonitorInfo;
    LMonitorRect: TRect;
    LRoot: HWND;
    LRootRect: TRect;
    LScrollInfo: TScrollBarInfo;
    LParts: array[0..3] of TPartCapture;
    LTrackAfter: TRect;
    LTrackBefore: TRect;
    I: Integer;
    function IntersectVisibleChain(const ARect: TRect;
      out AVisible: TRect): Boolean;
    var
      LAncestor: HWND;
      LBounds: TRect;
      LTopLeft: TPoint;
      LBottomRight: TPoint;
      LTemp: TRect;
    begin
      AVisible := ARect;
      if not IntersectRect(LTemp, AVisible, LRootRect) then
      begin
        AVisible := Rect(0, 0, 0, 0);
        Exit(False);
      end;
      AVisible := LTemp;
      if not IntersectRect(LTemp, AVisible, LMonitorRect) then
      begin
        AVisible := Rect(0, 0, 0, 0);
        Exit(False);
      end;
      AVisible := LTemp;
      LAncestor := GetParent(AControl.Handle);
      while LAncestor <> 0 do
      begin
        GetClientRect(LAncestor, LBounds);
        LTopLeft := LBounds.TopLeft;
        LBottomRight := LBounds.BottomRight;
        ClientToScreen(LAncestor, LTopLeft);
        ClientToScreen(LAncestor, LBottomRight);
        LBounds := Rect(LTopLeft.X, LTopLeft.Y,
          LBottomRight.X, LBottomRight.Y);
        if not IntersectRect(LTemp, AVisible, LBounds) then
        begin
          AVisible := Rect(0, 0, 0, 0);
          Exit(False);
        end;
        AVisible := LTemp;
        if LAncestor = LRoot then
          Break;
        LAncestor := GetParent(LAncestor);
      end;
      Result := not IsRectEmpty(AVisible);
    end;
    procedure CapturePart(var APart: TPartCapture);
    var
      LDC: HDC;
      LDCOrigin: TPoint;
      LOwner: HWND;
      LPixel: COLORREF;
      LPointDC: TPoint;
      LScreenDC: HDC;
      LX: Integer;
      LY: Integer;
      LMatched: Boolean;
    begin
      if not IntersectVisibleChain(APart.CanonicalRect, APart.VisibleRect) then
      begin
        APart.Status := 'CAPTURE_NOT_VISIBLE/CLIPPED';
        Exit;
      end;
      LScreenDC := GetDC(0);
      try
        for LY := APart.VisibleRect.Top to APart.VisibleRect.Bottom - 1 do
          for LX := APart.VisibleRect.Left to APart.VisibleRect.Right - 1 do
          begin
            Inc(APart.Candidates);
            LOwner := WindowFromPoint(Point(LX, LY));
            if LOwner = 0 then
            begin
              Inc(APart.NoOwner);
              Continue;
            end;
            if APart.FirstOwner = 0 then
              APart.FirstOwner := LOwner
            else if APart.FirstOwner <> LOwner then
              Inc(APart.OwnerChanges);
            LPixel := CLR_INVALID;
            LDC := GetWindowDC(LOwner);
            if LDC <> 0 then
            try
              LDCOrigin := Point(0, 0);
              GetDCOrgEx(LDC, LDCOrigin);
              LPointDC := Point(LX - LDCOrigin.X, LY - LDCOrigin.Y);
              if PtVisible(LDC, LPointDC.X, LPointDC.Y) then
                LPixel := GetPixel(LDC, LPointDC.X, LPointDC.Y);
              if LPixel <> CLR_INVALID then
                Inc(APart.OwnerDCValid);
            finally
              ReleaseDC(LOwner, LDC);
            end;
            if (LPixel = CLR_INVALID) and (LScreenDC <> 0) then
            begin
              LPixel := GetPixel(LScreenDC, LX, LY);
              if LPixel <> CLR_INVALID then
                Inc(APart.ScreenDCValid);
            end;
            if LPixel = CLR_INVALID then
            begin
              Inc(APart.Invalid);
              Continue;
            end;
            Inc(APart.Valid);
            LMatched := ColorDistance(LPixel, APart.PrimaryColor) <=
              ColorTolerance;
            if ColorDistance(LPixel, APart.AccentColor) <= ColorTolerance then
            begin
              Inc(APart.AccentMatched);
              LMatched := True;
            end;
            if LMatched then
              Inc(APart.Matched);
          end;
      finally
        if LScreenDC <> 0 then
          ReleaseDC(0, LScreenDC);
      end;
      if APart.Valid = 0 then
      begin
        if APart.NoOwner = APart.Candidates then
          APart.Status := 'CAPTURE_NOT_VISIBLE/CLIPPED'
        else
          APart.Status := 'CAPTURE_INVALID';
      end
      else if (APart.Matched * 2 < APart.Valid) or
        (APart.RequireAccent and (APart.AccentMatched = 0)) then
        APart.Status := 'COLOR_MISMATCH'
      else
        APart.Status := 'PASS';
    end;
  begin
    Result := 'CAPTURE_INVALID';
    if (AControl = nil) or not AControl.HandleAllocated then
    begin
      Writeln('CAPTURE_SUMMARY control=', AName,
        ' status=CAPTURE_INVALID reason=no-hwnd');
      Exit;
    end;
    FillChar(LScrollInfo, SizeOf(LScrollInfo), 0);
    LScrollInfo.cbSize := SizeOf(LScrollInfo);
    if not GetScrollBarInfo(AControl.Handle, NativeObjectIdVScroll,
      LScrollInfo) then
    begin
      Writeln('CAPTURE_SUMMARY control=', AName,
        ' status=CAPTURE_INVALID reason=GetScrollBarInfo');
      Exit;
    end;
    if (LScrollInfo.rgstate[0] and STATE_SYSTEM_INVISIBLE) <> 0 then
    begin
      Writeln('CAPTURE_SUMMARY control=', AName,
        ' status=CAPTURE_NOT_VISIBLE/CLIPPED reason=invisible');
      Exit('CAPTURE_NOT_VISIBLE/CLIPPED');
    end;
    LRoot := GetAncestor(AControl.Handle, GA_ROOT);
    GetWindowRect(LRoot, LRootRect);
    FillChar(LMonitorInfo, SizeOf(LMonitorInfo), 0);
    LMonitorInfo.cbSize := SizeOf(LMonitorInfo);
    GetMonitorInfo(MonitorFromWindow(AControl.Handle,
      MONITOR_DEFAULTTONEAREST), @LMonitorInfo);
    LMonitorRect := LMonitorInfo.rcMonitor;
    LClientOrigin := Point(0, 0);
    ClientToScreen(AControl.Handle, LClientOrigin);
    FillChar(LParts, SizeOf(LParts), 0);
    LParts[0].Name := 'track';
    LTrackBefore := Rect(LScrollInfo.rcScrollBar.Left,
      LScrollInfo.rcScrollBar.Top + LScrollInfo.dxyLineButton,
      LScrollInfo.rcScrollBar.Right,
      LClientOrigin.Y + LScrollInfo.xyThumbTop);
    LTrackAfter := Rect(LScrollInfo.rcScrollBar.Left,
      LClientOrigin.Y + LScrollInfo.xyThumbBottom,
      LScrollInfo.rcScrollBar.Right,
      LScrollInfo.rcScrollBar.Bottom - LScrollInfo.dxyLineButton);
    if LTrackBefore.Height >= LTrackAfter.Height then
      LParts[0].CanonicalRect := LTrackBefore
    else
      LParts[0].CanonicalRect := LTrackAfter;
    LParts[0].PrimaryColor := ColorToRGB(
      TDACComponentColors.ToVclColor(LTokens.ScrollBarTrack));
    LParts[0].AccentColor := LParts[0].PrimaryColor;
    LParts[1].Name := 'thumb';
    LParts[1].CanonicalRect := Rect(LScrollInfo.rcScrollBar.Left,
      LClientOrigin.Y + LScrollInfo.xyThumbTop,
      LScrollInfo.rcScrollBar.Right,
      LClientOrigin.Y + LScrollInfo.xyThumbBottom);
    LParts[1].PrimaryColor := ColorToRGB(
      TDACComponentColors.ToVclColor(LTokens.ScrollBarThumb));
    LParts[1].AccentColor := LParts[1].PrimaryColor;
    LParts[2].Name := 'start-arrow';
    LParts[2].CanonicalRect := Rect(LScrollInfo.rcScrollBar.Left,
      LScrollInfo.rcScrollBar.Top, LScrollInfo.rcScrollBar.Right,
      LScrollInfo.rcScrollBar.Top + LScrollInfo.dxyLineButton);
    LParts[2].PrimaryColor := LParts[1].PrimaryColor;
    LParts[2].AccentColor := ColorToRGB(
      TDACComponentColors.ToVclColor(LTokens.ScrollBarArrow));
    LParts[2].RequireAccent := True;
    LParts[3].Name := 'end-arrow';
    LParts[3].CanonicalRect := Rect(LScrollInfo.rcScrollBar.Left,
      LScrollInfo.rcScrollBar.Bottom - LScrollInfo.dxyLineButton,
      LScrollInfo.rcScrollBar.Right, LScrollInfo.rcScrollBar.Bottom);
    LParts[3].PrimaryColor := LParts[1].PrimaryColor;
    LParts[3].AccentColor := LParts[2].AccentColor;
    LParts[3].RequireAccent := True;
    Result := 'PASS';
    for I := Low(LParts) to High(LParts) do
    begin
      CapturePart(LParts[I]);
      Writeln(Format('CAPTURE_PART control=%s scenario=%s part=%s ' +
        'canonical=%s visible=%s owner=%p owner_class=%s owner_changes=%d ' +
        'candidates=%d no_owner=%d owner_dc=%d screen_dc=%d invalid=%d ' +
        'valid=%d matched=%d accent=%d status=%s',
        [AName, AScenario, LParts[I].Name,
         CaptureRectText(LParts[I].CanonicalRect),
         CaptureRectText(LParts[I].VisibleRect),
         Pointer(LParts[I].FirstOwner),
         CaptureWindowClass(LParts[I].FirstOwner),
         LParts[I].OwnerChanges, LParts[I].Candidates,
         LParts[I].NoOwner, LParts[I].OwnerDCValid,
         LParts[I].ScreenDCValid, LParts[I].Invalid, LParts[I].Valid,
         LParts[I].Matched, LParts[I].AccentMatched,
         LParts[I].Status]));
      if LParts[I].Status = 'CAPTURE_NOT_VISIBLE/CLIPPED' then
        Result := 'CAPTURE_NOT_VISIBLE/CLIPPED'
      else if (Result <> 'CAPTURE_NOT_VISIBLE/CLIPPED') and
        (LParts[I].Status = 'CAPTURE_INVALID') then
        Result := 'CAPTURE_INVALID'
      else if (Result = 'PASS') and
        (LParts[I].Status = 'COLOR_MISMATCH') then
        Result := 'COLOR_MISMATCH';
    end;
    Writeln(Format('CAPTURE_SUMMARY control=%s scenario=%s root=%s ' +
      'monitor=%s scrollbar=%s status=%s', [AName, AScenario,
      CaptureRectText(LRootRect), CaptureRectText(LMonitorRect),
      CaptureRectText(LScrollInfo.rcScrollBar), Result]));
  end;
  procedure PrepareGridScrollBarForCapture;
  const
    NativeObjectIdVScroll = -5;
  var
    I: Integer;
    LDelta: Integer;
    LNewPosition: Integer;
    LScrollInfo: TScrollBarInfo;
    LViewportRect: TRect;
  begin
    Require((LScroll <> nil) and (LGrid <> nil) and
      LScroll.HandleAllocated and LGrid.HandleAllocated,
      'Preparacao de captura sem HWND do viewport/grid.');
    for I := 0 to 4 do
    begin
      FillChar(LScrollInfo, SizeOf(LScrollInfo), 0);
      LScrollInfo.cbSize := SizeOf(LScrollInfo);
      Require(GetScrollBarInfo(LGrid.Handle, NativeObjectIdVScroll,
          LScrollInfo),
        'Preparacao de captura nao obteve scrollbar vertical da grid.');
      LViewportRect.TopLeft := LScroll.ClientToScreen(Point(0, 0));
      LViewportRect.BottomRight := LScroll.ClientToScreen(
        Point(LScroll.ClientWidth, LScroll.ClientHeight));
      if (LScrollInfo.rcScrollBar.Left >= LViewportRect.Left) and
        (LScrollInfo.rcScrollBar.Right <= LViewportRect.Right) and
        (LScrollInfo.rcScrollBar.Top >= LViewportRect.Top) and
        (LScrollInfo.rcScrollBar.Bottom <= LViewportRect.Bottom) then
        Break;
      LDelta := 0;
      if LScrollInfo.rcScrollBar.Right > LViewportRect.Right then
        LDelta := LScrollInfo.rcScrollBar.Right - LViewportRect.Right
      else if LScrollInfo.rcScrollBar.Left < LViewportRect.Left then
        LDelta := LScrollInfo.rcScrollBar.Left - LViewportRect.Left;
      Require(LDelta <> 0,
        Format('Scrollbar da grid fora do viewport apenas no eixo vertical ' +
          '(viewport=%s scrollbar=%s).', [CaptureRectText(LViewportRect),
           CaptureRectText(LScrollInfo.rcScrollBar)]));
      LNewPosition := LScroll.HorzScrollBar.Position + LDelta;
      LScroll.HorzScrollBar.Position := Max(0, LNewPosition);
      PumpMessages(60);
    end;
    FillChar(LScrollInfo, SizeOf(LScrollInfo), 0);
    LScrollInfo.cbSize := SizeOf(LScrollInfo);
    Require(GetScrollBarInfo(LGrid.Handle, NativeObjectIdVScroll,
        LScrollInfo),
      'Confirmacao de captura nao obteve scrollbar vertical da grid.');
    LViewportRect.TopLeft := LScroll.ClientToScreen(Point(0, 0));
    LViewportRect.BottomRight := LScroll.ClientToScreen(
      Point(LScroll.ClientWidth, LScroll.ClientHeight));
    Require((LScrollInfo.rcScrollBar.Left >= LViewportRect.Left) and
      (LScrollInfo.rcScrollBar.Right <= LViewportRect.Right) and
      (LScrollInfo.rcScrollBar.Top >= LViewportRect.Top) and
      (LScrollInfo.rcScrollBar.Bottom <= LViewportRect.Bottom),
      Format('Viewport nao trouxe scrollbar vertical da grid para a area ' +
        'visivel (position=%d viewport=%s scrollbar=%s).',
        [LScroll.HorzScrollBar.Position, CaptureRectText(LViewportRect),
         CaptureRectText(LScrollInfo.rcScrollBar)]));
    RedrawWindow(LScroll.Handle, nil, 0,
      RDW_INVALIDATE or RDW_ERASE or RDW_FRAME or RDW_ALLCHILDREN or
      RDW_UPDATENOW);
    RedrawWindow(LGrid.Handle, nil, 0,
      RDW_INVALIDATE or RDW_ERASE or RDW_FRAME or RDW_UPDATENOW);
    PumpMessages(60);
    Writeln(Format('MEM-DEL-DB-068 capture viewport PASS: position=%d ' +
      'viewport=%s scrollbar=%s', [LScroll.HorzScrollBar.Position,
       CaptureRectText(LViewportRect),
       CaptureRectText(LScrollInfo.rcScrollBar)]));
  end;
  procedure RequireMode(const AMode: TDACThemeMode;
    const AScenario: string);
  begin
    TDACThemeManager.SetApplicationMode(AMode);
    PumpMessages(80);
    LTokens := TDACComponentStyle.ResolveForSurface(
      LCombo, dtmInherit).Tokens.Controls;
    Require(LText.ResolvedTextColor = LTokens.SystemTextPrimary,
      'Titulo Data-Aware nao resolveu SystemTextPrimary em ' +
        AScenario + '.');
    LSurface := TDACComponentColors.ResolveParentSurface(LText);
    Require(TDACComponentColors.ContrastRatio(
      LText.ResolvedTextColor, LSurface) >= 4.5,
      'Titulo Data-Aware sem contraste AA em ' + AScenario + '.');
    Require(LCombo.StyleElements = [],
      'DB ComboBox manteve StyleElements em ' + AScenario + '.');
    Require(TNativeControlAccess(LCombo).Color =
      TDACComponentColors.ToVclColor(LTokens.ComboBoxBackground),
      Format('DB ComboBox background divergiu em %s (real=%d esperado=%d).',
        [AScenario, TNativeControlAccess(LCombo).Color,
         TDACComponentColors.ToVclColor(LTokens.ComboBoxBackground)]));
    Require(TNativeControlAccess(LCombo).Font.Color =
      TDACComponentColors.ToVclColor(LTokens.ComboBoxText),
      Format('DB ComboBox texto divergiu em %s (real=%d esperado=%d).',
        [AScenario, TNativeControlAccess(LCombo).Font.Color,
         TDACComponentColors.ToVclColor(LTokens.ComboBoxText)]));
    Require((LDate.PickerControl.StyleElements = []) and
      (TNativeControlAccess(LDate.PickerControl).Color =
        TDACComponentColors.ToVclColor(LTokens.DateTimeBackground)) and
      (TNativeControlAccess(LDate.PickerControl).Font.Color =
        TDACComponentColors.ToVclColor(LTokens.DateTimeText)),
      'DB DateTimePicker nao aplicou surface/texto nativos em ' +
        AScenario + '.');
    Require((LLookup.LookupControl.StyleElements = []) and
      (TNativeControlAccess(LLookup.LookupControl).Color =
        TDACComponentColors.ToVclColor(LTokens.ComboBoxBackground)) and
      (TNativeControlAccess(LLookup.LookupControl).Font.Color =
        TDACComponentColors.ToVclColor(LTokens.ComboBoxText)),
      'DB LookupComboBox nao aplicou surface/texto nativos em ' +
        AScenario + '.');
    Require(TNativeControlAccess(LDBText).Font.Color =
      TDACComponentColors.ToVclColor(LTokens.InputText),
      Format('DBText nao aplicou InputText em %s (real=%d esperado=%d).',
        [AScenario, TNativeControlAccess(LDBText).Font.Color,
         TDACComponentColors.ToVclColor(LTokens.InputText)]));
    Require(TNativeControlAccess(LCheck).Font.Color =
      TDACComponentColors.ToVclColor(LTokens.SelectorText),
      Format('DBCheck caption divergiu em %s (real=%d esperado=%d).',
        [AScenario, TNativeControlAccess(LCheck).Font.Color,
         TDACComponentColors.ToVclColor(LTokens.SelectorText)]));
    Require(TNativeControlAccess(LToggle).Font.Color =
      TDACComponentColors.ToVclColor(LTokens.SelectorText),
      Format('DBToggle caption divergiu em %s (real=%d esperado=%d).',
        [AScenario, TNativeControlAccess(LToggle).Font.Color,
         TDACComponentColors.ToVclColor(LTokens.SelectorText)]));
    RequireNativeClientSurface(LEdit, LTokens.InputBackground,
      'DB Edit', AScenario);
    RequireNativeClientSurface(LButtonEdit, LTokens.InputBackground,
      'DB ButtonEdit', AScenario);
    RequireNativeClientSurface(LMemo, LTokens.InputBackground,
      'DB Memo', AScenario);
    RequireNativeClientSurface(LCombo, LTokens.ComboBoxBackground,
      'DB ComboBox', AScenario);
    RequireNativeClientSurface(LLookup.LookupControl,
      LTokens.ComboBoxBackground, 'DB LookupComboBox', AScenario);
    RequireNativeClientSurface(LDate.PickerControl,
      LTokens.DateTimeBackground, 'DB DateTimePicker', AScenario);
    if AMode = dtmDark then
    begin
      Require((GetWindowTheme(LEdit.Handle) = 0) and
        (GetWindowTheme(LButtonEdit.Handle) = 0) and
        (GetWindowTheme(LMemo.Handle) = 0) and
        (GetWindowTheme(LCombo.Handle) = 0) and
        (GetWindowTheme(LLookup.Handle) = 0) and
        (GetWindowTheme(LDate.Handle) = 0),
        'Controles Data-Aware mantiveram tema do sistema sobre a palette Dark.');
    end;
  end;
begin
  LScroll := nil;
  LScrollHorzBefore := 0;
  LScrollPositionCaptured := False;
  LScrollVertBefore := 0;
  LWidth := AForm.Width;
  LHeight := AForm.Height;
  LMode := TDACThemeManager.ApplicationMode;
  LPage := AForm.GalleryTabs.ActivePage;
  try
    AForm.SetBounds(AForm.Left, AForm.Top, 1824, 1197);
    AForm.GalleryTabs.ActivePage :=
      AForm.FindComponent('tsDataAware') as TTabSheet;
    PumpMessages(80);
    LText := AForm.FindComponent('lblDataAware') as TDACSystemText;
    LDBText := AForm.FindComponent('demoDBText') as TDACDBText;
    LEdit := AForm.FindComponent('demoDBEdit') as TDACDBEdit;
    LButtonEdit := AForm.FindComponent('demoDBButtonEdit') as TDACDBButtonEdit;
    LMemo := AForm.FindComponent('demoDBMemo') as TDACDBMemo;
    LCheck := AForm.FindComponent('demoDBCheck') as TDACDBCheckBox;
    LCombo := AForm.FindComponent('demoDBComboBox') as TDACDBComboBox;
    LDate := AForm.FindComponent('demoDBDate') as TDACDBDateTimePicker;
    LLookup := AForm.FindComponent('demoDBLookup') as TDACDBLookupComboBox;
    LToggle := AForm.FindComponent('demoDBToggle') as TDACDBToggleSwitch;
    LGrid := AForm.FindComponent('demoDataAwareGrid') as TDACDataGrid;
    LScroll := AForm.FindComponent('scrDataAware') as TDACScrollContainer;
    Require((LText <> nil) and (LDBText <> nil) and (LEdit <> nil) and
      (LButtonEdit <> nil) and (LMemo <> nil) and (LCheck <> nil) and
      (LCombo <> nil) and (LDate <> nil) and (LLookup <> nil) and
      (LToggle <> nil) and (LGrid <> nil) and (LScroll <> nil),
      'Regressao visual Data-Aware sem todos os controles obrigatorios.');
    LScrollHorzBefore := LScroll.HorzScrollBar.Position;
    LScrollVertBefore := LScroll.VertScrollBar.Position;
    LScrollPositionCaptured := True;
    RequireMode(dtmDark, 'Dark 1824x1197');
    Require(not TDataGridHandleAccess(LGrid).GridAcceptsDataCellRect(
        Rect(0, -4, 80,
          TDataGridHandleAccess(LGrid).GridHeaderHeight + 8),
        LGrid.ClientWidth,
        TDataGridHandleAccess(LGrid).GridHeaderHeight,
        LGrid.ClientHeight - Round(
          LTokens.DataGridFooterHeight)),
      'DataGrid aceitou CellRect parcial com Top negativo.');
    Require(not TDataGridHandleAccess(LGrid).GridAcceptsDataCellRect(
        Rect(0, TDataGridHandleAccess(LGrid).GridHeaderHeight - 1,
          80, TDataGridHandleAccess(LGrid).GridHeaderHeight + 20),
        LGrid.ClientWidth,
        TDataGridHandleAccess(LGrid).GridHeaderHeight,
        LGrid.ClientHeight - Round(
          LTokens.DataGridFooterHeight)),
      'DataGrid aceitou CellRect que intersecta a faixa do header.');
    LGrid.Redraw;
    PumpMessages(80);
    Require(LGrid.LastRejectedCellBounds > 0,
      'DataGrid nao rejeitou CellRect fora do viewport antes do chrome.');
    Require((LGrid.LastDataChromeMinimumTop >=
        TDataGridHandleAccess(LGrid).GridHeaderHeight) and
      (LGrid.LastDataChromeMinimumTop < LGrid.ClientHeight),
      'DataGrid desenhou chrome de dados na faixa do header ou nao auditou os draws.');
    RequireMode(dtmLight, 'Light 1824x1197');
    AForm.SetBounds(AForm.Left, AForm.Top, 1200, 760);
    PumpMessages(80);
    RequireMode(dtmDark, 'Dark 1200x760');
    PrepareGridScrollBarForCapture;
    LScrollCaptureStatus := CaptureDarkNativeScrollBar(LScroll,
      'ScrollContainer Data-Aware', 'Dark 1200x760');
    LGridCaptureStatus := CaptureDarkNativeScrollBar(LGrid,
      'DataGrid Data-Aware', 'Dark 1200x760');
    Require((LScrollCaptureStatus = 'PASS') and
      (LGridCaptureStatus = 'PASS'),
      Format('CAPTURE_GATE_FAILED: ScrollContainer=%s DataGrid=%s.',
        [LScrollCaptureStatus, LGridCaptureStatus]));
  finally
    if LScrollPositionCaptured and (LScroll <> nil) then
    begin
      LScroll.HorzScrollBar.Position := LScrollHorzBefore;
      LScroll.VertScrollBar.Position := LScrollVertBefore;
      PumpMessages(60);
    end;
    TDACThemeManager.SetApplicationMode(LMode);
    AForm.SetBounds(AForm.Left, AForm.Top, LWidth, LHeight);
    AForm.GalleryTabs.ActivePage := LPage;
    PumpMessages(80);
  end;
end;

procedure ExecuteDataGridScrollStyleHookRuntime(const AForm: TForm1;
  const AFailureStage: TDataGridGateFailureStage);
var
  LGrid: TDACDataGrid;
  LHook: TDataGridScrollHookAccess;
  LCleanupComplete: Boolean;
  LGridStateCaptured: Boolean;
  LObserverInstalled: Boolean;
  LOriginalActiveControl: TWinControl;
  LOriginalActiveIndex: Integer;
  LOriginalApplicationMode: TDACThemeMode;
  LOriginalEnabled: Boolean;
  LOriginalGridHandle: HWND;
  LOriginalLoading: Boolean;
  LOriginalPage: TTabSheet;
  LOriginalReadOnly: Boolean;
  LOriginalThemeMode: TDACThemeMode;
  LOriginalVisible: Boolean;
  LSavedFailureRaised: Boolean;
  LSavedFailureStage: TDataGridGateFailureStage;
  LSavedHorizontalPaint: TDACScrollHookPaintInfo;
  LSavedHorizontalPaintCount: Integer;
  LSavedRepaintAttempted: Boolean;
  LSavedRepaintOnNextNotification: Boolean;
  LSavedScrollHookTarget: HWND;
  LSavedSynchronousRepaint: TProc;
  LSavedVerticalPaint: TDACScrollHookPaintInfo;
  LSavedVerticalPaintCount: Integer;
  LDarkTrack: TAlphaColor;
  LDarkThumb: TAlphaColor;
  procedure ResetObservedPaint;
  begin
    ScrollHookHorizontalPaintCount := 0;
    ScrollHookVerticalPaintCount := 0;
    FillChar(ScrollHookHorizontalPaint, SizeOf(ScrollHookHorizontalPaint), 0);
    FillChar(ScrollHookVerticalPaint, SizeOf(ScrollHookVerticalPaint), 0);
  end;
  procedure RequireAxisGeometry(const AInfo: TDACScrollHookPaintInfo;
    const AVertical: Boolean; const AContext: string);
  begin
    Require((AInfo.ControlHandle = LGrid.Handle) and
      (((AInfo.Axis = shaVertical) and AVertical) or
       ((AInfo.Axis = shaHorizontal) and not AVertical)),
      AContext + ': observer perdeu HWND/eixo da TDACDataGrid real.');
    Require(not IsRectEmpty(AInfo.ScrollRect) and
      not IsRectEmpty(AInfo.SliderRect) and
      not IsRectEmpty(AInfo.StartButtonRect) and
      not IsRectEmpty(AInfo.EndButtonRect),
      AContext + ': scroll/thumb/arrows devem possuir geometria real.');
    Require(AInfo.ScrollRect.Contains(AInfo.SliderRect.TopLeft) and
      AInfo.ScrollRect.Contains(Point(AInfo.SliderRect.Right - 1,
        AInfo.SliderRect.Bottom - 1)) and
      AInfo.ScrollRect.Contains(AInfo.StartButtonRect.TopLeft) and
      AInfo.ScrollRect.Contains(Point(AInfo.StartButtonRect.Right - 1,
        AInfo.StartButtonRect.Bottom - 1)) and
      AInfo.ScrollRect.Contains(AInfo.EndButtonRect.TopLeft) and
      AInfo.ScrollRect.Contains(Point(AInfo.EndButtonRect.Right - 1,
        AInfo.EndButtonRect.Bottom - 1)),
      AContext + ': partes escaparam do retangulo da scrollbar.');
    if AVertical then
      Require((AInfo.StartButtonRect.Bottom <= AInfo.SliderRect.Top) and
        (AInfo.SliderRect.Bottom <= AInfo.EndButtonRect.Top),
        AContext + ': ordem vertical arrow/thumb/arrow incoerente.')
    else
      Require((AInfo.StartButtonRect.Right <= AInfo.SliderRect.Left) and
        (AInfo.SliderRect.Right <= AInfo.EndButtonRect.Left),
        AContext + ': ordem horizontal arrow/thumb/arrow incoerente.');
  end;
  procedure RequireThemePaint(const AMode: TDACThemeMode;
    const AContext: string);
  var
    LTokens: TDACControlTokens;
  begin
    LGrid.Enabled := True;
    LGrid.ThemeMode := AMode;
    PumpMessages(50);
    LTokens := TDACComponentStyle.ResolveForSurface(LGrid,
      LGrid.ThemeMode).Tokens.Controls;

    ResetObservedPaint;
    LHook.SeedAxisStates(True, tsThumbBtnVertNormal,
      tsArrowBtnUpNormal, tsArrowBtnDownNormal);
    LHook.SeedAxisStates(False, tsThumbBtnHorzNormal,
      tsArrowBtnLeftNormal, tsArrowBtnRightNormal);
    LHook.PaintAxisNonClient(True);
    LHook.PaintAxisNonClient(False);
    Require((ScrollHookVerticalPaintCount = 1) and
      (ScrollHookHorizontalPaintCount = 1),
      Format('%s: cada paint V/H deve produzir exatamente uma notificacao ' +
        '(vertical=%d horizontal=%d).', [AContext,
        ScrollHookVerticalPaintCount, ScrollHookHorizontalPaintCount]));
    RequireAxisGeometry(ScrollHookVerticalPaint, True,
      AContext + ' vertical normal');
    RequireAxisGeometry(ScrollHookHorizontalPaint, False,
      AContext + ' horizontal normal');
    Require(ScrollHookVerticalPaint.RenderedWithSkia and
      ScrollHookVerticalPaint.PresentedWithBitBlt and
      ScrollHookHorizontalPaint.RenderedWithSkia and
      ScrollHookHorizontalPaint.PresentedWithBitBlt,
      AContext + ': observer nao confirmou Skia + BitBlt nos dois eixos.');
    Require(ScrollHookVerticalPaint.Enabled and
      ScrollHookHorizontalPaint.Enabled and
      (ScrollHookVerticalPaint.SliderState = tsThumbBtnVertNormal) and
      (ScrollHookVerticalPaint.StartButtonState = tsArrowBtnUpNormal) and
      (ScrollHookVerticalPaint.EndButtonState = tsArrowBtnDownNormal) and
      (ScrollHookHorizontalPaint.SliderState = tsThumbBtnHorzNormal) and
      (ScrollHookHorizontalPaint.StartButtonState =
        tsArrowBtnLeftNormal) and
      (ScrollHookHorizontalPaint.EndButtonState =
        tsArrowBtnRightNormal),
      AContext + ': estados normais observados nao correspondem ao eixo.');
    Require((ScrollHookVerticalPaint.TrackColor = LTokens.ScrollBarTrack) and
      (ScrollHookHorizontalPaint.TrackColor = LTokens.ScrollBarTrack) and
      (ScrollHookVerticalPaint.SliderColor = LTokens.ScrollBarThumb) and
      (ScrollHookHorizontalPaint.SliderColor = LTokens.ScrollBarThumb) and
      (ScrollHookVerticalPaint.StartButtonColor = LTokens.ScrollBarThumb) and
      (ScrollHookVerticalPaint.EndButtonColor = LTokens.ScrollBarThumb) and
      (ScrollHookHorizontalPaint.StartButtonColor =
        LTokens.ScrollBarThumb) and
      (ScrollHookHorizontalPaint.EndButtonColor =
        LTokens.ScrollBarThumb) and
      (ScrollHookVerticalPaint.ArrowColor = LTokens.ScrollBarArrow) and
      (ScrollHookHorizontalPaint.ArrowColor = LTokens.ScrollBarArrow) and
      (ScrollHookVerticalPaint.BorderColor = LTokens.ScrollBarBorder) and
      (ScrollHookHorizontalPaint.BorderColor = LTokens.ScrollBarBorder),
      AContext + ': paleta normal nao corresponde aos tokens resolvidos.');

    ResetObservedPaint;
    LHook.SeedAxisStates(True, tsThumbBtnVertHot,
      tsArrowBtnUpNormal, tsArrowBtnDownNormal);
    LHook.PaintAxisNonClient(True);
    Require((ScrollHookVerticalPaintCount = 1) and
      (ScrollHookHorizontalPaintCount = 0) and
      (ScrollHookVerticalPaint.SliderState = tsThumbBtnVertHot) and
      (ScrollHookVerticalPaint.SliderColor =
        LTokens.ScrollBarThumbHot),
      AContext + ': estado hot vertical nao resolveu ScrollBarThumbHot.');

    ResetObservedPaint;
    LHook.SeedAxisStates(False, tsThumbBtnHorzPressed,
      tsArrowBtnLeftNormal, tsArrowBtnRightNormal);
    LHook.PaintAxisNonClient(False);
    Require((ScrollHookHorizontalPaintCount = 1) and
      (ScrollHookVerticalPaintCount = 0) and
      (ScrollHookHorizontalPaint.SliderState =
        tsThumbBtnHorzPressed) and
      (ScrollHookHorizontalPaint.SliderColor =
        LTokens.ScrollBarThumbPressed),
      AContext +
        ': estado pressed horizontal nao resolveu ScrollBarThumbPressed.');

    LGrid.Enabled := False;
    ResetObservedPaint;
    LHook.SeedAxisStates(True, tsThumbBtnVertNormal,
      tsArrowBtnUpNormal, tsArrowBtnDownNormal);
    LHook.PaintAxisNonClient(True);
    Require((ScrollHookVerticalPaintCount = 1) and
      not ScrollHookVerticalPaint.Enabled and
      (ScrollHookVerticalPaint.SliderState = tsThumbBtnVertDisabled) and
      (ScrollHookVerticalPaint.StartButtonState =
        tsArrowBtnUpDisabled) and
      (ScrollHookVerticalPaint.EndButtonState =
        tsArrowBtnDownDisabled) and
      (ScrollHookVerticalPaint.SliderColor = LTokens.TabsTextDisabled) and
      (ScrollHookVerticalPaint.StartButtonColor =
        LTokens.TabsTextDisabled) and
      (ScrollHookVerticalPaint.EndButtonColor =
        LTokens.TabsTextDisabled) and
      (ScrollHookVerticalPaint.ArrowColor = LTokens.TabsTextDisabled) and
      (ScrollHookVerticalPaint.TrackColor = LTokens.ScrollBarTrack) and
      (ScrollHookVerticalPaint.BorderColor = LTokens.ScrollBarBorder),
      AContext + ': estado disabled nao preservou estados/cores tokenizados.');
    LGrid.Enabled := True;

    if AMode = dtmDark then
    begin
      LDarkTrack := LTokens.ScrollBarTrack;
      LDarkThumb := LTokens.ScrollBarThumb;
    end
    else
      Require((LTokens.ScrollBarTrack <> LDarkTrack) and
        (LTokens.ScrollBarThumb <> LDarkThumb),
        'Dark/Light devem produzir track e thumb fisicamente distintos.');
  end;
  procedure RequireObserverReentrancy;
  var
    LCountAfterNestedPaint: Integer;
  begin
    LGrid.Enabled := True;
    LGrid.ThemeMode := dtmDark;
    PumpMessages(30);
    ResetObservedPaint;
    ScrollHookRepaintAttempted := False;
    ScrollHookRepaintOnNextNotification := True;
    LHook.SeedAxisStates(True, tsThumbBtnVertNormal,
      tsArrowBtnUpNormal, tsArrowBtnDownNormal);
    ScrollHookSynchronousRepaint :=
      procedure
      begin
        InjectDataGridGateFailure(dgfsReentrantCallback);
        LHook.PaintAxisNonClient(True);
      end;
    try
      LHook.PaintAxisNonClient(True);
    finally
      ScrollHookRepaintOnNextNotification := False;
      ScrollHookSynchronousRepaint := nil;
    end;
    Require(ScrollHookRepaintAttempted,
      'Observer da grid nao executou o repaint reentrante planejado.');
    Require((ScrollHookVerticalPaintCount = 1) and
      (ScrollHookHorizontalPaintCount = 0),
      Format('Guarda da grid deixou escapar notificacao recursiva (%d/%d).',
        [ScrollHookVerticalPaintCount, ScrollHookHorizontalPaintCount]));
    LCountAfterNestedPaint := ScrollHookVerticalPaintCount;
    LHook.PaintAxisNonClient(True);
    Require(ScrollHookVerticalPaintCount = LCountAfterNestedPaint + 1,
      'Guarda da grid permaneceu bloqueado apos o callback reentrante.');
  end;
  procedure Cleanup;
  begin
    if LCleanupComplete then
      Exit;
    try
      if LObserverInstalled then
      begin
        TDACScrollContainerStyleHook.SetPaintObserver(nil);
        LObserverInstalled := False;
      end;
    finally
      try
        ScrollHookRepaintOnNextNotification := False;
        ScrollHookRepaintAttempted := False;
        ScrollHookSynchronousRepaint := nil;
      finally
        try
          FreeAndNil(LHook);
        finally
          try
            if LGridStateCaptured and (LGrid <> nil) then
            begin
              LGrid.Enabled := LOriginalEnabled;
              LGrid.ThemeMode := LOriginalThemeMode;
              LGrid.Loading := LOriginalLoading;
              LGrid.ReadOnly := LOriginalReadOnly;
              LGrid.Visible := LOriginalVisible;
            end;
          finally
            try
              if TDACThemeManager.ApplicationMode <>
                LOriginalApplicationMode then
                TDACThemeManager.SetApplicationMode(
                  LOriginalApplicationMode);
            finally
              try
                if AForm.GalleryTabs.ActivePage <> LOriginalPage then
                  AForm.GalleryTabs.ActivePage := LOriginalPage;
                if AForm.GalleryTabs.ActiveIndex <> LOriginalActiveIndex then
                  AForm.GalleryTabs.ActiveIndex := LOriginalActiveIndex;
                if (LOriginalActiveControl <> nil) and
                  LOriginalActiveControl.CanFocus then
                  LOriginalActiveControl.SetFocus;
                PumpMessages(50);
              finally
                ScrollHookTarget := LSavedScrollHookTarget;
                ScrollHookHorizontalPaint := LSavedHorizontalPaint;
                ScrollHookVerticalPaint := LSavedVerticalPaint;
                ScrollHookHorizontalPaintCount :=
                  LSavedHorizontalPaintCount;
                ScrollHookVerticalPaintCount := LSavedVerticalPaintCount;
                ScrollHookRepaintAttempted := LSavedRepaintAttempted;
                ScrollHookRepaintOnNextNotification :=
                  LSavedRepaintOnNextNotification;
                ScrollHookSynchronousRepaint := LSavedSynchronousRepaint;
                DataGridGateFailureStage := LSavedFailureStage;
                DataGridGateFailureRaised := LSavedFailureRaised;
                LCleanupComplete := True;
              end;
            end;
          end;
        end;
      end;
    end;
  end;
begin
  LGrid := nil;
  LHook := nil;
  LCleanupComplete := False;
  LGridStateCaptured := False;
  LObserverInstalled := False;
  LOriginalEnabled := False;
  LOriginalGridHandle := 0;
  LOriginalLoading := False;
  LOriginalReadOnly := False;
  LOriginalThemeMode := dtmInherit;
  LOriginalVisible := False;
  LOriginalActiveControl := AForm.ActiveControl;
  LOriginalActiveIndex := AForm.GalleryTabs.ActiveIndex;
  LOriginalApplicationMode := TDACThemeManager.ApplicationMode;
  LOriginalPage := AForm.GalleryTabs.ActivePage;
  LSavedScrollHookTarget := ScrollHookTarget;
  LSavedHorizontalPaint := ScrollHookHorizontalPaint;
  LSavedVerticalPaint := ScrollHookVerticalPaint;
  LSavedHorizontalPaintCount := ScrollHookHorizontalPaintCount;
  LSavedVerticalPaintCount := ScrollHookVerticalPaintCount;
  LSavedRepaintAttempted := ScrollHookRepaintAttempted;
  LSavedRepaintOnNextNotification := ScrollHookRepaintOnNextNotification;
  LSavedSynchronousRepaint := ScrollHookSynchronousRepaint;
  LSavedFailureStage := DataGridGateFailureStage;
  LSavedFailureRaised := DataGridGateFailureRaised;
  if AForm.FindComponent('demoDataAwareGrid') is TDACDataGrid then
  begin
    LGrid := TDACDataGrid(AForm.FindComponent('demoDataAwareGrid'));
    LOriginalEnabled := LGrid.Enabled;
    LOriginalThemeMode := LGrid.ThemeMode;
    LOriginalLoading := LGrid.Loading;
    LOriginalReadOnly := LGrid.ReadOnly;
    LOriginalVisible := LGrid.Visible;
    if LGrid.HandleAllocated then
      LOriginalGridHandle := LGrid.Handle
    else
      LOriginalGridHandle := 0;
    LGridStateCaptured := True;
  end;
  DataGridGateFailureStage := AFailureStage;
  DataGridGateFailureRaised := False;
  try
    InjectDataGridGateFailure(dgfsBeforePageSwitch);
    Require(TStyleEngineAccess.HasExactStyleHook(TDACDataGrid,
        TDACDataGridStyleHook),
      'Registry runtime nao contem TDACDataGrid -> TDACDataGridStyleHook.');
    Require(not TStyleEngineAccess.HasExactStyleHook(TDBGrid,
        TDACDataGridStyleHook),
      'TDACDataGridStyleHook foi registrado indevidamente na base TDBGrid.');
    AForm.GalleryTabs.ActivePage :=
      AForm.FindComponent('tsDataAware') as TTabSheet;
    PumpMessages(80);
    InjectDataGridGateFailure(dgfsAfterPageSwitch);
    Require((LGrid <> nil) and LGrid.HandleAllocated and
      IsWindow(LGrid.Handle),
      'Gate runtime nao encontrou o HWND real da TDACDataGrid.');
    if LOriginalGridHandle <> 0 then
      Require(LGrid.Handle = LOriginalGridHandle,
        'Gate runtime recriou indevidamente o HWND real da TDACDataGrid.');
    ScrollHookTarget := LGrid.Handle;
    InjectDataGridGateFailure(dgfsBeforeObserverInstall);
    TDACScrollContainerStyleHook.SetPaintObserver(CaptureScrollHookPaint);
    LObserverInstalled := True;
    InjectDataGridGateFailure(dgfsAfterObserverInstall);
    InjectDataGridGateFailure(dgfsBeforeHookConstruction);
    LHook := TDataGridScrollHookAccess.Create(LGrid);
    InjectDataGridGateFailure(dgfsAfterHookConstruction);
    InjectDataGridGateFailure(dgfsConfiguration);
    RequireThemePaint(dtmDark, 'TDACDataGridStyleHook Dark');
    RequireThemePaint(dtmLight, 'TDACDataGridStyleHook Light');
    RequireObserverReentrancy;
  finally
    Cleanup;
    Cleanup;
  end;
end;

procedure RequireDataGridScrollStyleHookRuntime(const AForm: TForm1);
type
  TResourceSnapshot = record
    GdiObjects: DWORD;
    ProcessHandles: DWORD;
    UserObjects: DWORD;
  end;
const
  FailureStages: array[0..8] of TDataGridGateFailureStage = (
    dgfsBeforePageSwitch,
    dgfsAfterPageSwitch,
    dgfsBeforeObserverInstall,
    dgfsAfterObserverInstall,
    dgfsBeforeHookConstruction,
    dgfsAfterHookConstruction,
    dgfsConfiguration,
    dgfsObserverCallback,
    dgfsReentrantCallback);
var
  I: Integer;
  LDrainStarted: Cardinal;
  LActiveControlBefore: TWinControl;
  LActiveIndexBefore: Integer;
  LApplicationModeBefore: TDACThemeMode;
  LExpectedMessage: string;
  LFailureRaised: Boolean;
  LGrid: TDACDataGrid;
  LGridEnabledBefore: Boolean;
  LGridHandleBefore: HWND;
  LGridLoadingBefore: Boolean;
  LGridReadOnlyBefore: Boolean;
  LGridThemeBefore: TDACThemeMode;
  LGridVisibleBefore: Boolean;
  LPageBefore: TTabSheet;
  LResourcesAfter: TResourceSnapshot;
  LResourcesBefore: TResourceSnapshot;
  LSavedFailureRaised: Boolean;
  LSavedFailureStage: TDataGridGateFailureStage;
  LSavedHorizontalPaint: TDACScrollHookPaintInfo;
  LSavedHorizontalPaintCount: Integer;
  LSavedRepaintAttempted: Boolean;
  LSavedRepaintOnNextNotification: Boolean;
  LSavedScrollHookTarget: HWND;
  LSavedSynchronousRepaintAssigned: Boolean;
  LSavedVerticalPaint: TDACScrollHookPaintInfo;
  LSavedVerticalPaintCount: Integer;
  LTokensBefore: TDACControlTokens;
  procedure ReadResources(out ASnapshot: TResourceSnapshot;
    const AContext: string);
  begin
    ASnapshot.GdiObjects := GetGuiResources(
      GetCurrentProcess, GR_GDIOBJECTS);
    ASnapshot.UserObjects := GetGuiResources(
      GetCurrentProcess, GR_USEROBJECTS);
    ASnapshot.ProcessHandles := 0;
    Require(GetProcessHandleCount(GetCurrentProcess,
        ASnapshot.ProcessHandles),
      AContext + ': GetProcessHandleCount falhou.');
  end;
  procedure RequireNoResourceGrowth(const ABefore, AAfter: TResourceSnapshot;
    const AContext: string);
  begin
    Require((AAfter.GdiObjects <= ABefore.GdiObjects) and
      (AAfter.UserObjects <= ABefore.UserObjects) and
      (AAfter.ProcessHandles <= ABefore.ProcessHandles),
      Format('%s: leak de recursos (GDI %d/%d; USER %d/%d; handles %d/%d).',
        [AContext, AAfter.GdiObjects, ABefore.GdiObjects,
         AAfter.UserObjects, ABefore.UserObjects,
         AAfter.ProcessHandles, ABefore.ProcessHandles]));
  end;
  procedure RequireObserverNilAndInactive(const AContext: string);
  var
    LHook: TDataGridScrollHookAccess;
    LObserverInstalled: Boolean;
    LSavedHorizontalPaint: TDACScrollHookPaintInfo;
    LSavedHorizontalPaintCount: Integer;
    LSavedRepaintAttempted: Boolean;
    LSavedRepaintOnNextNotification: Boolean;
    LSavedScrollHookTarget: HWND;
    LSavedSynchronousRepaint: TProc;
    LSavedVerticalPaint: TDACScrollHookPaintInfo;
    LSavedVerticalPaintCount: Integer;
  begin
    LHook := nil;
    LObserverInstalled := False;
    LSavedScrollHookTarget := ScrollHookTarget;
    LSavedHorizontalPaint := ScrollHookHorizontalPaint;
    LSavedVerticalPaint := ScrollHookVerticalPaint;
    LSavedHorizontalPaintCount := ScrollHookHorizontalPaintCount;
    LSavedVerticalPaintCount := ScrollHookVerticalPaintCount;
    LSavedRepaintAttempted := ScrollHookRepaintAttempted;
    LSavedRepaintOnNextNotification := ScrollHookRepaintOnNextNotification;
    LSavedSynchronousRepaint := ScrollHookSynchronousRepaint;
    try
      ScrollHookTarget := LGrid.Handle;
      ScrollHookHorizontalPaintCount := 0;
      ScrollHookVerticalPaintCount := 0;
      FillChar(ScrollHookHorizontalPaint,
        SizeOf(ScrollHookHorizontalPaint), 0);
      FillChar(ScrollHookVerticalPaint,
        SizeOf(ScrollHookVerticalPaint), 0);
      LHook := TDataGridScrollHookAccess.Create(LGrid);
      LHook.SeedAxisStates(True, tsThumbBtnVertNormal,
        tsArrowBtnUpNormal, tsArrowBtnDownNormal);
      LHook.PaintAxisNonClient(True);
      Require((ScrollHookVerticalPaintCount = 0) and
        (ScrollHookHorizontalPaintCount = 0),
        AContext + ': observer global permaneceu instalado apos cleanup.');

      TDACScrollContainerStyleHook.SetPaintObserver(CaptureScrollHookPaint);
      LObserverInstalled := True;
      LHook.PaintAxisNonClient(True);
      Require((ScrollHookVerticalPaintCount = 1) and
        (ScrollHookHorizontalPaintCount = 0),
        AContext + ': guarda global permaneceu ativa apos excecao.');
    finally
      if LObserverInstalled then
        TDACScrollContainerStyleHook.SetPaintObserver(nil);
      FreeAndNil(LHook);
      ScrollHookTarget := LSavedScrollHookTarget;
      ScrollHookHorizontalPaint := LSavedHorizontalPaint;
      ScrollHookVerticalPaint := LSavedVerticalPaint;
      ScrollHookHorizontalPaintCount := LSavedHorizontalPaintCount;
      ScrollHookVerticalPaintCount := LSavedVerticalPaintCount;
      ScrollHookRepaintAttempted := LSavedRepaintAttempted;
      ScrollHookRepaintOnNextNotification :=
        LSavedRepaintOnNextNotification;
      ScrollHookSynchronousRepaint := LSavedSynchronousRepaint;
    end;
  end;
  procedure RequireStateRestored(const AContext: string);
  var
    LTokensAfter: TDACControlTokens;
  begin
    LTokensAfter := TDACComponentStyle.Resolve(
      TDACThemeManager.ApplicationMode).Tokens.Controls;
    Require((AForm.GalleryTabs.ActivePage = LPageBefore) and
      (AForm.GalleryTabs.ActiveIndex = LActiveIndexBefore),
      AContext + ': ActivePage/ActiveIndex nao foram restaurados.');
    Require(TDACThemeManager.ApplicationMode = LApplicationModeBefore,
      AContext + ': ApplicationMode nao foi restaurado.');
    Require((LTokensAfter.ScrollBarTrack = LTokensBefore.ScrollBarTrack) and
      (LTokensAfter.ScrollBarThumb = LTokensBefore.ScrollBarThumb) and
      (LTokensAfter.ScrollBarArrow = LTokensBefore.ScrollBarArrow) and
      (LTokensAfter.ScrollBarBorder = LTokensBefore.ScrollBarBorder),
      AContext + ': tokens globais nao foram restaurados.');
    Require((LGrid.Handle = LGridHandleBefore) and
      (LGrid.Enabled = LGridEnabledBefore) and
      (LGrid.ThemeMode = LGridThemeBefore) and
      (LGrid.Loading = LGridLoadingBefore) and
      (LGrid.ReadOnly = LGridReadOnlyBefore) and
      (LGrid.Visible = LGridVisibleBefore),
      AContext + ': estado/handle da TDACDataGrid nao foi restaurado.');
    if LActiveControlBefore = nil then
      Require(AForm.ActiveControl = nil,
        AContext + ': ActiveControl nil nao foi restaurado.')
    else if LActiveControlBefore.CanFocus then
      Require(AForm.ActiveControl = LActiveControlBefore,
        AContext + ': foco/ActiveControl nao foi restaurado.');
    Require((ScrollHookTarget = LSavedScrollHookTarget) and
      (ScrollHookHorizontalPaintCount = LSavedHorizontalPaintCount) and
      (ScrollHookVerticalPaintCount = LSavedVerticalPaintCount) and
      CompareMem(@ScrollHookHorizontalPaint, @LSavedHorizontalPaint,
        SizeOf(ScrollHookHorizontalPaint)) and
      CompareMem(@ScrollHookVerticalPaint, @LSavedVerticalPaint,
        SizeOf(ScrollHookVerticalPaint)) and
      (ScrollHookRepaintAttempted = LSavedRepaintAttempted) and
      (ScrollHookRepaintOnNextNotification =
        LSavedRepaintOnNextNotification) and
      (Assigned(ScrollHookSynchronousRepaint) =
        LSavedSynchronousRepaintAssigned) and
      (DataGridGateFailureStage = LSavedFailureStage) and
      (DataGridGateFailureRaised = LSavedFailureRaised),
      AContext + ': probes globais do gate nao foram restaurados.');
  end;
begin
  LGrid := AForm.FindComponent('demoDataAwareGrid') as TDACDataGrid;
  Require(LGrid <> nil,
    'Matriz exception-safety nao encontrou demoDataAwareGrid.');

  ExecuteDataGridScrollStyleHookRuntime(AForm, dgfsNone);
  Writeln('MEM-DEL-DB-037 nominal-before-failures PASS');
  for I := Low(FailureStages) to High(FailureStages) do
  begin
    PumpMessages(50);
    LPageBefore := AForm.GalleryTabs.ActivePage;
    LActiveIndexBefore := AForm.GalleryTabs.ActiveIndex;
    LActiveControlBefore := AForm.ActiveControl;
    LApplicationModeBefore := TDACThemeManager.ApplicationMode;
    LGridHandleBefore := LGrid.Handle;
    LGridEnabledBefore := LGrid.Enabled;
    LGridThemeBefore := LGrid.ThemeMode;
    LGridLoadingBefore := LGrid.Loading;
    LGridReadOnlyBefore := LGrid.ReadOnly;
    LGridVisibleBefore := LGrid.Visible;
    LTokensBefore := TDACComponentStyle.Resolve(
      LApplicationModeBefore).Tokens.Controls;
    LSavedScrollHookTarget := ScrollHookTarget;
    LSavedHorizontalPaint := ScrollHookHorizontalPaint;
    LSavedVerticalPaint := ScrollHookVerticalPaint;
    LSavedHorizontalPaintCount := ScrollHookHorizontalPaintCount;
    LSavedVerticalPaintCount := ScrollHookVerticalPaintCount;
    LSavedRepaintAttempted := ScrollHookRepaintAttempted;
    LSavedRepaintOnNextNotification := ScrollHookRepaintOnNextNotification;
    LSavedSynchronousRepaintAssigned :=
      Assigned(ScrollHookSynchronousRepaint);
    LSavedFailureStage := DataGridGateFailureStage;
    LSavedFailureRaised := DataGridGateFailureRaised;
    ReadResources(LResourcesBefore,
      DataGridGateFailureStageName(FailureStages[I]) + ' before');

    LFailureRaised := False;
    LExpectedMessage := 'MEM-DEL-DB-037 injected failure: ' +
      DataGridGateFailureStageName(FailureStages[I]);
    try
      ExecuteDataGridScrollStyleHookRuntime(AForm, FailureStages[I]);
    except
      on E: EDataGridGateInjectedFailure do
      begin
        Require(E.Message = LExpectedMessage,
          DataGridGateFailureStageName(FailureStages[I]) +
            ': excecao injetada divergente: ' + E.Message);
        LFailureRaised := True;
      end;
    end;
    Require(LFailureRaised,
      DataGridGateFailureStageName(FailureStages[I]) +
        ': excecao esperada nao ocorreu.');
    RequireStateRestored(
      DataGridGateFailureStageName(FailureStages[I]));
    RequireObserverNilAndInactive(
      DataGridGateFailureStageName(FailureStages[I]));
    { Native style helper windows finish teardown on a later queue turn whose
      latency varies by the Windows visual-style host. Keep the zero-growth
      requirement exact, but wait boundedly for that real teardown. }
    LDrainStarted := GetTickCount;
    repeat
      PumpMessages(50);
      ReadResources(LResourcesAfter,
        DataGridGateFailureStageName(FailureStages[I]) + ' after');
      if (LResourcesAfter.GdiObjects <= LResourcesBefore.GdiObjects) and
        (LResourcesAfter.UserObjects <= LResourcesBefore.UserObjects) and
        (LResourcesAfter.ProcessHandles <= LResourcesBefore.ProcessHandles) then
        Break;
    until Cardinal(GetTickCount - LDrainStarted) >= 2000;
    RequireNoResourceGrowth(LResourcesBefore, LResourcesAfter,
      DataGridGateFailureStageName(FailureStages[I]));
    Writeln('MEM-DEL-DB-037 failure-stage PASS: ' +
      DataGridGateFailureStageName(FailureStages[I]));
  end;

  ExecuteDataGridScrollStyleHookRuntime(AForm, dgfsNone);
  Writeln('MEM-DEL-DB-037 nominal-after-failures PASS');
end;

procedure RequireDataGridNonClientFunctionalRegression(const AForm: TForm1);
var
  LDataSet: TDataSet;
  LGrid: TDACDataGrid;
  LGridHandle: HWND;
  LHook: TDataGridScrollHookAccess;
  LOriginalActiveControl: TWinControl;
  LOriginalApplicationMode: TDACThemeMode;
  LOriginalLeftColumn: Integer;
  LOriginalPage: TTabSheet;
  LOriginalRecNo: Integer;
  LOriginalThemeMode: TDACThemeMode;
  LOriginalTopRow: Integer;
  LSavedFallbackPaintCount: Integer;
  LSavedHorizontalPaint: TDACScrollHookPaintInfo;
  LSavedHorizontalPaintCount: Integer;
  LSavedScrollHookTarget: HWND;
  LSavedStyleHookPaintCount: Integer;
  LSavedVerticalPaint: TDACScrollHookPaintInfo;
  LSavedVerticalPaintCount: Integer;

  function CenterOf(const ARect: TRect): TPoint;
  begin
    Result := Point((ARect.Left + ARect.Right) div 2,
      (ARect.Top + ARect.Bottom) div 2);
  end;

  function ClientPointToScreen(const APoint: TPoint): TPoint;
  begin
    Result := APoint;
    Winapi.Windows.ClientToScreen(LGrid.Handle, Result);
  end;

  function MessagePoint(const APoint: TPoint): LPARAM;
  begin
    Result := LPARAM(MakeLong(Word(APoint.X), Word(APoint.Y)));
  end;

  function NativePosition(const ABar: Integer): Integer;
  var
    LInfo: TScrollInfo;
  begin
    FillChar(LInfo, SizeOf(LInfo), 0);
    LInfo.cbSize := SizeOf(LInfo);
    LInfo.fMask := SIF_POS;
    Require(GetScrollInfo(LGrid.Handle, ABar, LInfo),
      Format('MEM-DEL-DB-069 GetScrollInfo(%d) falhou.', [ABar]));
    Result := LInfo.nPos;
  end;

  procedure ResetObservedPaint;
  begin
    ScrollHookHorizontalPaintCount := 0;
    ScrollHookVerticalPaintCount := 0;
    ScrollHookStyleHookPaintCount := 0;
    ScrollHookFallbackPaintCount := 0;
    FillChar(ScrollHookHorizontalPaint,
      SizeOf(ScrollHookHorizontalPaint), 0);
    FillChar(ScrollHookVerticalPaint,
      SizeOf(ScrollHookVerticalPaint), 0);
  end;

  procedure PaintBothAxes(const AContext: string);
  begin
    ResetObservedPaint;
    LHook.SeedAxisStates(False, tsThumbBtnHorzNormal,
      tsArrowBtnLeftNormal, tsArrowBtnRightNormal);
    LHook.SeedAxisStates(True, tsThumbBtnVertNormal,
      tsArrowBtnUpNormal, tsArrowBtnDownNormal);
    LHook.PaintAxisNonClient(False);
    LHook.PaintAxisNonClient(True);
    Require((ScrollHookStyleHookPaintCount = 2) and
      (ScrollHookFallbackPaintCount = 0) and
      (ScrollHookHorizontalPaintCount = 1) and
      (ScrollHookVerticalPaintCount = 1),
      Format('%s: paint duplicado/fallback (style=%d fallback=%d H=%d V=%d).',
        [AContext, ScrollHookStyleHookPaintCount,
         ScrollHookFallbackPaintCount, ScrollHookHorizontalPaintCount,
         ScrollHookVerticalPaintCount]));
    Require(ScrollHookHorizontalPaint.RenderedWithSkia and
      ScrollHookHorizontalPaint.PresentedWithBitBlt and
      ScrollHookVerticalPaint.RenderedWithSkia and
      ScrollHookVerticalPaint.PresentedWithBitBlt,
      AContext + ': paint nao confirmou Skia + BitBlt nos dois eixos.');
  end;

  procedure SendNonClientMouse(const AMessage: Cardinal;
    const AHitCode: WPARAM; const AClientPoint: TPoint);
  var
    LScreenPoint: TPoint;
  begin
    LScreenPoint := ClientPointToScreen(AClientPoint);
    SetCursorPos(LScreenPoint.X, LScreenPoint.Y);
    LHook.ProcessHookMessage(AMessage, AHitCode,
      MessagePoint(LScreenPoint));
    PumpMessages(30);
  end;

  procedure ClickNonClient(const AHitCode: WPARAM;
    const AClientPoint: TPoint);
  var
    LScreenPoint: TPoint;
  begin
    { In Delphi 10.2, TScrollingStyleHook leaves arrows and page-track
      WM_NCLBUTTONDOWN unhandled so TCustomStyleEngine dispatches the real
      default window procedure.  A direct call to WndProc cannot emulate
      that outer dispatcher.  Queue the physical down/up pair to the real
      grid HWND; the native scrollbar tracking loop consumes the queued up. }
    LScreenPoint := ClientPointToScreen(AClientPoint);
    SetCursorPos(LScreenPoint.X, LScreenPoint.Y);
    Require(PostMessage(LGrid.Handle, WM_NCLBUTTONDOWN, AHitCode,
        MessagePoint(LScreenPoint)),
      'MEM-DEL-DB-069 nao enfileirou WM_NCLBUTTONDOWN fisico.');
    Require(PostMessage(LGrid.Handle, WM_LBUTTONUP, 0, 0),
      'MEM-DEL-DB-069 nao enfileirou WM_LBUTTONUP fisico.');
    PumpMessages(120);
    Require(GetCapture <> LGrid.Handle,
      'MEM-DEL-DB-069 click non-client reteve capture da grid.');
  end;

  procedure RequireThemeCycles;
  var
    LContext: string;
    LCycle: Integer;
    LDarkTrack: TAlphaColor;
    LDarkThumb: TAlphaColor;
    LMode: TDACThemeMode;
    LPhase: Integer;
    LTokens: TDACControlTokens;
  begin
    LDarkTrack := 0;
    LDarkThumb := 0;
    for LCycle := 1 to 10 do
      for LPhase := 0 to 1 do
      begin
        if LPhase = 0 then
          LMode := dtmDark
        else
          LMode := dtmLight;
        LGrid.ThemeMode := LMode;
        PumpMessages(35);
        Require((LGrid.Handle = LGridHandle) and IsWindow(LGridHandle),
          Format('MEM-DEL-DB-069 ciclo %d/%d recriou o HWND da grid.',
            [LCycle, LPhase + 1]));
        LContext := Format('MEM-DEL-DB-069 cycle=%d phase=%d',
          [LCycle, LPhase + 1]);
        PaintBothAxes(LContext);
        LTokens := TDACComponentStyle.ResolveForSurface(LGrid,
          LMode).Tokens.Controls;
        Require((ScrollHookHorizontalPaint.TrackColor =
            LTokens.ScrollBarTrack) and
          (ScrollHookVerticalPaint.TrackColor = LTokens.ScrollBarTrack) and
          (ScrollHookHorizontalPaint.SliderColor =
            LTokens.ScrollBarThumb) and
          (ScrollHookVerticalPaint.SliderColor = LTokens.ScrollBarThumb) and
          (ScrollHookHorizontalPaint.ArrowColor =
            LTokens.ScrollBarArrow) and
          (ScrollHookVerticalPaint.ArrowColor = LTokens.ScrollBarArrow),
          LContext + ': pixels observados conservaram tokens do tema anterior.');
        if LMode = dtmDark then
        begin
          LDarkTrack := LTokens.ScrollBarTrack;
          LDarkThumb := LTokens.ScrollBarThumb;
        end
        else
          Require((LTokens.ScrollBarTrack <> LDarkTrack) and
            (LTokens.ScrollBarThumb <> LDarkThumb),
            LContext + ': Dark/Light nao produziram pixels distintos.');
      end;
    Writeln(Format('MEM-DEL-DB-069 theme-cycles PASS cycles=10 ' +
      'phases=20 hwnd=%p stale=0 double-paint=0 fallback=0',
      [Pointer(LGridHandle)]));
  end;

  procedure RequireVerticalClicksAndDrag;
  var
    LBeforeNative: Integer;
    LBeforeRecNo: Integer;
    LBeforeTopRow: Integer;
    LDelta: Integer;
    LPagePoint: TPoint;
    LPoint: TPoint;
  begin
    LGrid.Perform(WM_VSCROLL, SB_TOP, 0);
    PumpMessages(60);
    PaintBothAxes('MEM-DEL-DB-069 vertical arrow increment geometry');
    LBeforeNative := NativePosition(SB_VERT);
    LBeforeTopRow := TDataGridHandleAccess(LGrid).GridTopRow;
    LBeforeRecNo := LDataSet.RecNo;
    ClickNonClient(HTVSCROLL,
      CenterOf(ScrollHookVerticalPaint.EndButtonRect));
    Require((NativePosition(SB_VERT) > LBeforeNative) or
      (TDataGridHandleAccess(LGrid).GridTopRow > LBeforeTopRow) or
      (LDataSet.RecNo > LBeforeRecNo),
      'MEM-DEL-DB-069 arrow vertical increment nao rolou/navegou.');

    LGrid.Perform(WM_VSCROLL, SB_BOTTOM, 0);
    PumpMessages(60);
    PaintBothAxes('MEM-DEL-DB-069 vertical arrow decrement geometry');
    LBeforeNative := NativePosition(SB_VERT);
    LBeforeTopRow := TDataGridHandleAccess(LGrid).GridTopRow;
    LBeforeRecNo := LDataSet.RecNo;
    ClickNonClient(HTVSCROLL,
      CenterOf(ScrollHookVerticalPaint.StartButtonRect));
    Require((NativePosition(SB_VERT) < LBeforeNative) or
      (TDataGridHandleAccess(LGrid).GridTopRow < LBeforeTopRow) or
      (LDataSet.RecNo < LBeforeRecNo),
      'MEM-DEL-DB-069 arrow vertical decrement nao rolou/navegou.');

    LGrid.Perform(WM_VSCROLL, SB_TOP, 0);
    PumpMessages(60);
    PaintBothAxes('MEM-DEL-DB-069 vertical page-after geometry');
    LPagePoint := Point(
      (ScrollHookVerticalPaint.ScrollRect.Left +
       ScrollHookVerticalPaint.ScrollRect.Right) div 2,
      (ScrollHookVerticalPaint.SliderRect.Bottom +
       ScrollHookVerticalPaint.EndButtonRect.Top) div 2);
    Require((LPagePoint.Y >= ScrollHookVerticalPaint.SliderRect.Bottom) and
      (LPagePoint.Y < ScrollHookVerticalPaint.EndButtonRect.Top),
      'MEM-DEL-DB-069 track vertical page-after vazio.');
    LBeforeNative := NativePosition(SB_VERT);
    LBeforeTopRow := TDataGridHandleAccess(LGrid).GridTopRow;
    LBeforeRecNo := LDataSet.RecNo;
    ClickNonClient(HTVSCROLL, LPagePoint);
    Require((NativePosition(SB_VERT) > LBeforeNative) or
      (TDataGridHandleAccess(LGrid).GridTopRow > LBeforeTopRow) or
      (LDataSet.RecNo > LBeforeRecNo),
      'MEM-DEL-DB-069 track vertical page-after nao rolou/navegou.');

    LGrid.Perform(WM_VSCROLL, SB_BOTTOM, 0);
    PumpMessages(60);
    PaintBothAxes('MEM-DEL-DB-069 vertical page-before geometry');
    LPagePoint := Point(
      (ScrollHookVerticalPaint.ScrollRect.Left +
       ScrollHookVerticalPaint.ScrollRect.Right) div 2,
      (ScrollHookVerticalPaint.StartButtonRect.Bottom +
       ScrollHookVerticalPaint.SliderRect.Top) div 2);
    Require((LPagePoint.Y >= ScrollHookVerticalPaint.StartButtonRect.Bottom) and
      (LPagePoint.Y < ScrollHookVerticalPaint.SliderRect.Top),
      'MEM-DEL-DB-069 track vertical page-before vazio.');
    LBeforeNative := NativePosition(SB_VERT);
    LBeforeTopRow := TDataGridHandleAccess(LGrid).GridTopRow;
    LBeforeRecNo := LDataSet.RecNo;
    ClickNonClient(HTVSCROLL, LPagePoint);
    Require((NativePosition(SB_VERT) < LBeforeNative) or
      (TDataGridHandleAccess(LGrid).GridTopRow < LBeforeTopRow) or
      (LDataSet.RecNo < LBeforeRecNo),
      'MEM-DEL-DB-069 track vertical page-before nao rolou/navegou.');

    LGrid.Perform(WM_VSCROLL, SB_TOP, 0);
    PumpMessages(60);
    PaintBothAxes('MEM-DEL-DB-069 vertical thumb geometry');
    LPoint := CenterOf(ScrollHookVerticalPaint.SliderRect);
    LBeforeNative := NativePosition(SB_VERT);
    LBeforeTopRow := TDataGridHandleAccess(LGrid).GridTopRow;
    LBeforeRecNo := LDataSet.RecNo;
    SendNonClientMouse(WM_NCLBUTTONDOWN, HTVSCROLL, LPoint);
    LDelta := Max(8, LHook.VerticalTrackHeight div 3);
    LHook.SeedMouseDragDelta(True, LDelta);
    LHook.ProcessHookMessage(WM_MOUSEMOVE, MK_LBUTTON,
      MakeLong(Word(LPoint.X), Word(LPoint.Y + LDelta)));
    PumpMessages(60);
    LHook.ProcessHookMessage(WM_LBUTTONUP, 0, 0);
    PumpMessages(40);
    Require((NativePosition(SB_VERT) > LBeforeNative) or
      (TDataGridHandleAccess(LGrid).GridTopRow > LBeforeTopRow) or
      (LDataSet.RecNo > LBeforeRecNo),
      'MEM-DEL-DB-069 drag vertical nao rolou/navegou.');
    Require(GetCapture <> LGrid.Handle,
      'MEM-DEL-DB-069 drag vertical reteve capture.');
  end;

  procedure RequireHorizontalClicksAndDrag;
  var
    LBeforeLeftColumn: Integer;
    LBeforeNative: Integer;
    LDelta: Integer;
    LPagePoint: TPoint;
    LPoint: TPoint;
  begin
    LGrid.Perform(WM_HSCROLL, SB_LEFT, 0);
    PumpMessages(60);
    PaintBothAxes('MEM-DEL-DB-069 horizontal arrow increment geometry');
    LBeforeNative := NativePosition(SB_HORZ);
    LBeforeLeftColumn := TDataGridHandleAccess(LGrid).GridLeftColumn;
    ClickNonClient(HTHSCROLL,
      CenterOf(ScrollHookHorizontalPaint.EndButtonRect));
    Require((NativePosition(SB_HORZ) > LBeforeNative) or
      (TDataGridHandleAccess(LGrid).GridLeftColumn > LBeforeLeftColumn),
      'MEM-DEL-DB-069 arrow horizontal increment nao rolou.');

    LGrid.Perform(WM_HSCROLL, SB_RIGHT, 0);
    PumpMessages(60);
    PaintBothAxes('MEM-DEL-DB-069 horizontal arrow decrement geometry');
    LBeforeNative := NativePosition(SB_HORZ);
    LBeforeLeftColumn := TDataGridHandleAccess(LGrid).GridLeftColumn;
    ClickNonClient(HTHSCROLL,
      CenterOf(ScrollHookHorizontalPaint.StartButtonRect));
    Require((NativePosition(SB_HORZ) < LBeforeNative) or
      (TDataGridHandleAccess(LGrid).GridLeftColumn < LBeforeLeftColumn),
      'MEM-DEL-DB-069 arrow horizontal decrement nao rolou.');

    LGrid.Perform(WM_HSCROLL, SB_LEFT, 0);
    PumpMessages(60);
    PaintBothAxes('MEM-DEL-DB-069 horizontal page-after geometry');
    LPagePoint := Point(
      (ScrollHookHorizontalPaint.SliderRect.Right +
       ScrollHookHorizontalPaint.EndButtonRect.Left) div 2,
      (ScrollHookHorizontalPaint.ScrollRect.Top +
       ScrollHookHorizontalPaint.ScrollRect.Bottom) div 2);
    Require((LPagePoint.X >= ScrollHookHorizontalPaint.SliderRect.Right) and
      (LPagePoint.X < ScrollHookHorizontalPaint.EndButtonRect.Left),
      'MEM-DEL-DB-069 track horizontal page-after vazio.');
    LBeforeNative := NativePosition(SB_HORZ);
    LBeforeLeftColumn := TDataGridHandleAccess(LGrid).GridLeftColumn;
    ClickNonClient(HTHSCROLL, LPagePoint);
    Require((NativePosition(SB_HORZ) > LBeforeNative) or
      (TDataGridHandleAccess(LGrid).GridLeftColumn > LBeforeLeftColumn),
      'MEM-DEL-DB-069 track horizontal page-after nao rolou.');

    LGrid.Perform(WM_HSCROLL, SB_RIGHT, 0);
    PumpMessages(60);
    PaintBothAxes('MEM-DEL-DB-069 horizontal page-before geometry');
    LPagePoint := Point(
      (ScrollHookHorizontalPaint.StartButtonRect.Right +
       ScrollHookHorizontalPaint.SliderRect.Left) div 2,
      (ScrollHookHorizontalPaint.ScrollRect.Top +
       ScrollHookHorizontalPaint.ScrollRect.Bottom) div 2);
    Require((LPagePoint.X >= ScrollHookHorizontalPaint.StartButtonRect.Right) and
      (LPagePoint.X < ScrollHookHorizontalPaint.SliderRect.Left),
      'MEM-DEL-DB-069 track horizontal page-before vazio.');
    LBeforeNative := NativePosition(SB_HORZ);
    LBeforeLeftColumn := TDataGridHandleAccess(LGrid).GridLeftColumn;
    ClickNonClient(HTHSCROLL, LPagePoint);
    Require((NativePosition(SB_HORZ) < LBeforeNative) or
      (TDataGridHandleAccess(LGrid).GridLeftColumn < LBeforeLeftColumn),
      'MEM-DEL-DB-069 track horizontal page-before nao rolou.');

    LGrid.Perform(WM_HSCROLL, SB_LEFT, 0);
    PumpMessages(60);
    PaintBothAxes('MEM-DEL-DB-069 horizontal thumb geometry');
    LPoint := CenterOf(ScrollHookHorizontalPaint.SliderRect);
    LBeforeNative := NativePosition(SB_HORZ);
    LBeforeLeftColumn := TDataGridHandleAccess(LGrid).GridLeftColumn;
    SendNonClientMouse(WM_NCLBUTTONDOWN, HTHSCROLL, LPoint);
    LDelta := Max(8, LHook.HorizontalTrackWidth div 3);
    LHook.SeedMouseDragDelta(False, LDelta);
    LHook.ProcessHookMessage(WM_MOUSEMOVE, MK_LBUTTON,
      MakeLong(Word(LPoint.X + LDelta), Word(LPoint.Y)));
    PumpMessages(60);
    LHook.ProcessHookMessage(WM_LBUTTONUP, 0, 0);
    PumpMessages(40);
    Require((NativePosition(SB_HORZ) > LBeforeNative) or
      (TDataGridHandleAccess(LGrid).GridLeftColumn > LBeforeLeftColumn),
      'MEM-DEL-DB-069 drag horizontal nao rolou.');
    Require(GetCapture <> LGrid.Handle,
      'MEM-DEL-DB-069 drag horizontal reteve capture.');
  end;

begin
  LGrid := AForm.FindComponent('demoDataAwareGrid') as TDACDataGrid;
  Require((LGrid <> nil) and (LGrid.DataSource <> nil) and
    (LGrid.DataSource.DataSet <> nil) and LGrid.DataSource.DataSet.Active,
    'MEM-DEL-DB-069 exige TDACDataGrid data-aware ativo.');
  LDataSet := LGrid.DataSource.DataSet;
  LHook := nil;
  LOriginalActiveControl := AForm.ActiveControl;
  LOriginalApplicationMode := TDACThemeManager.ApplicationMode;
  LOriginalPage := AForm.GalleryTabs.ActivePage;
  LOriginalRecNo := LDataSet.RecNo;
  LOriginalThemeMode := LGrid.ThemeMode;
  LOriginalLeftColumn := TDataGridHandleAccess(LGrid).GridLeftColumn;
  LOriginalTopRow := TDataGridHandleAccess(LGrid).GridTopRow;
  LSavedScrollHookTarget := ScrollHookTarget;
  LSavedHorizontalPaint := ScrollHookHorizontalPaint;
  LSavedVerticalPaint := ScrollHookVerticalPaint;
  LSavedHorizontalPaintCount := ScrollHookHorizontalPaintCount;
  LSavedVerticalPaintCount := ScrollHookVerticalPaintCount;
  LSavedStyleHookPaintCount := ScrollHookStyleHookPaintCount;
  LSavedFallbackPaintCount := ScrollHookFallbackPaintCount;
  try
    AForm.GalleryTabs.ActivePage :=
      AForm.FindComponent('tsDataAware') as TTabSheet;
    PumpMessages(100);
    LGridHandle := LGrid.Handle;
    Require(IsWindow(LGridHandle),
      'MEM-DEL-DB-069 nao encontrou HWND real da grid.');
    ScrollHookTarget := LGridHandle;
    TDACScrollContainerStyleHook.SetPaintObserver(CaptureScrollHookPaint);
    LHook := TDataGridScrollHookAccess.Create(LGrid);
    Require(DACNativeScrollBarHookAuthorityCount(LGridHandle) > 0,
      'MEM-DEL-DB-069 hook dirigido nao adquiriu autoridade.');
    LGrid.SetFocus;
    PumpMessages(40);

    RequireThemeCycles;
    RequireVerticalClicksAndDrag;
    RequireHorizontalClicksAndDrag;
    Require((LGrid.Handle = LGridHandle) and LGrid.Focused and
      (TDataGridHandleAccess(LGrid).GridRow >=
        TDataGridHandleAccess(LGrid).GridFixedRows) and
      (TDataGridHandleAccess(LGrid).GridColumn >= 0) and
      not TDataGridHandleAccess(LGrid).GridEditorMode and
      (LGrid.FooterReserveRows > 0) and
      (LDataSet.RecNo >= 1),
      'MEM-DEL-DB-069 interacao non-client corrompeu foco/selecao/editor/footer/RecNo.');
    Writeln(Format('MEM-DEL-DB-069 non-client PASS hwnd=%p ' +
      'arrows=H+V tracks=H+V thumbs=H+V focus=PASS selection=PASS ' +
      'toprow=%d recno=%d leftcol=%d editor=closed footer=PASS',
      [Pointer(LGridHandle), TDataGridHandleAccess(LGrid).GridTopRow,
       LDataSet.RecNo, TDataGridHandleAccess(LGrid).GridLeftColumn]));
  finally
    TDACScrollContainerStyleHook.SetPaintObserver(nil);
    FreeAndNil(LHook);
    if LDataSet.Active and (LOriginalRecNo > 0) then
      LDataSet.RecNo := LOriginalRecNo;
    TDataGridHandleAccess(LGrid).SetGridLeftColumn(LOriginalLeftColumn);
    LGrid.Perform(WM_VSCROLL,
      MakeLong(SB_THUMBPOSITION, Max(0, LOriginalTopRow - 1)), 0);
    LGrid.ThemeMode := LOriginalThemeMode;
    if TDACThemeManager.ApplicationMode <> LOriginalApplicationMode then
      TDACThemeManager.SetApplicationMode(LOriginalApplicationMode);
    if AForm.GalleryTabs.ActivePage <> LOriginalPage then
      AForm.GalleryTabs.ActivePage := LOriginalPage;
    if (LOriginalActiveControl <> nil) and
      LOriginalActiveControl.CanFocus then
      LOriginalActiveControl.SetFocus;
    PumpMessages(60);
    ScrollHookTarget := LSavedScrollHookTarget;
    ScrollHookHorizontalPaint := LSavedHorizontalPaint;
    ScrollHookVerticalPaint := LSavedVerticalPaint;
    ScrollHookHorizontalPaintCount := LSavedHorizontalPaintCount;
    ScrollHookVerticalPaintCount := LSavedVerticalPaintCount;
    ScrollHookStyleHookPaintCount := LSavedStyleHookPaintCount;
    ScrollHookFallbackPaintCount := LSavedFallbackPaintCount;
  end;
end;

procedure RequireNestedScrollHookAuthority(const AForm: TForm1);
var
  LGrid: TDACDataGrid;
  LScroll: TDACScrollContainer;
  procedure RequireScrollContainerAuthority;
  var
    LBaseline: Integer;
    LFailureRaised: Boolean;
    LFirst: TScrollHookAccess;
    LSecond: TScrollHookAccess;
  begin
    LFirst := nil;
    LSecond := nil;
    LBaseline := DACNativeScrollBarHookAuthorityCount(LScroll.Handle);
    Require(LBaseline <= MaxInt - 2,
      'ScrollContainer authority baseline nao comporta dois hooks.');
    try
      LFirst := TScrollHookAccess.Create(LScroll);
      Require(DACNativeScrollBarHookAuthorityCount(LScroll.Handle) =
        LBaseline + 1,
        'ScrollContainer hook manual nao elevou N para N+1.');
      FreeAndNil(LFirst);
      Require(DACNativeScrollBarHookAuthorityCount(LScroll.Handle) =
        LBaseline,
        'ScrollContainer hook manual nao retornou de N+1 para N.');

      LFirst := TScrollHookAccess.Create(LScroll);
      LSecond := TScrollHookAccess.Create(LScroll);
      Require(DACNativeScrollBarHookAuthorityCount(LScroll.Handle) =
        LBaseline + 2,
        'ScrollContainer segundo hook nao elevou N+1 para N+2.');
      FreeAndNil(LSecond);
      Require(DACNativeScrollBarHookAuthorityCount(LScroll.Handle) =
        LBaseline + 1,
        'ScrollContainer unwind do segundo hook nao retornou para N+1.');
      FreeAndNil(LFirst);
      Require(DACNativeScrollBarHookAuthorityCount(LScroll.Handle) =
        LBaseline,
        'ScrollContainer unwind final nao retornou para N.');

      LFailureRaised := False;
      try
        TFailingScrollHookAccess.Create(LScroll);
      except
        on E: EScrollHookAuthorityProbeFailure do
          LFailureRaised := True;
      end;
      Require(LFailureRaised and
        (DACNativeScrollBarHookAuthorityCount(LScroll.Handle) = LBaseline),
        'Falha de construcao do ScrollContainer vazou autoridade.');
      Writeln(Format(
        'MEM-DEL-DB-065 authority PASS: ScrollContainer baseline=%d ' +
        'manual=%d nested=%d final=%d construction_failure=clean',
        [LBaseline, LBaseline + 1, LBaseline + 2,
         DACNativeScrollBarHookAuthorityCount(LScroll.Handle)]));
    finally
      LSecond.Free;
      LFirst.Free;
      Require(DACNativeScrollBarHookAuthorityCount(LScroll.Handle) =
        LBaseline,
        'Cleanup defensivo do ScrollContainer alterou baseline N.');
    end;
  end;
  procedure RequireDataGridAuthority;
  var
    LBaseline: Integer;
    LFailureRaised: Boolean;
    LFirst: TDataGridScrollHookAccess;
    LSecond: TDataGridScrollHookAccess;
  begin
    LFirst := nil;
    LSecond := nil;
    LBaseline := DACNativeScrollBarHookAuthorityCount(LGrid.Handle);
    Require(LBaseline <= MaxInt - 2,
      'DataGrid authority baseline nao comporta dois hooks.');
    try
      LFirst := TDataGridScrollHookAccess.Create(LGrid);
      Require(DACNativeScrollBarHookAuthorityCount(LGrid.Handle) =
        LBaseline + 1,
        'DataGrid hook manual nao elevou N para N+1.');
      FreeAndNil(LFirst);
      Require(DACNativeScrollBarHookAuthorityCount(LGrid.Handle) =
        LBaseline,
        'DataGrid hook manual nao retornou de N+1 para N.');

      LFirst := TDataGridScrollHookAccess.Create(LGrid);
      LSecond := TDataGridScrollHookAccess.Create(LGrid);
      Require(DACNativeScrollBarHookAuthorityCount(LGrid.Handle) =
        LBaseline + 2,
        'DataGrid segundo hook nao elevou N+1 para N+2.');
      FreeAndNil(LSecond);
      Require(DACNativeScrollBarHookAuthorityCount(LGrid.Handle) =
        LBaseline + 1,
        'DataGrid unwind do segundo hook nao retornou para N+1.');
      FreeAndNil(LFirst);
      Require(DACNativeScrollBarHookAuthorityCount(LGrid.Handle) =
        LBaseline,
        'DataGrid unwind final nao retornou para N.');

      LFailureRaised := False;
      try
        TFailingDataGridScrollHookAccess.Create(LGrid);
      except
        on E: EScrollHookAuthorityProbeFailure do
          LFailureRaised := True;
      end;
      Require(LFailureRaised and
        (DACNativeScrollBarHookAuthorityCount(LGrid.Handle) = LBaseline),
        'Falha de construcao do DataGrid vazou autoridade.');
      Writeln(Format(
        'MEM-DEL-DB-065 authority PASS: DataGrid baseline=%d manual=%d ' +
        'nested=%d final=%d construction_failure=clean',
        [LBaseline, LBaseline + 1, LBaseline + 2,
         DACNativeScrollBarHookAuthorityCount(LGrid.Handle)]));
    finally
      LSecond.Free;
      LFirst.Free;
      Require(DACNativeScrollBarHookAuthorityCount(LGrid.Handle) =
        LBaseline,
        'Cleanup defensivo do DataGrid alterou baseline N.');
    end;
  end;
begin
  LScroll := AForm.FindComponent('demoNavigation') as TDACScrollContainer;
  LGrid := AForm.FindComponent('demoDataAwareGrid') as TDACDataGrid;
  Require((LScroll <> nil) and LScroll.HandleAllocated and
    IsWindow(LScroll.Handle),
    'Prova de autoridade nao encontrou ScrollContainer com HWND valido.');
  Require((LGrid <> nil) and LGrid.HandleAllocated and IsWindow(LGrid.Handle),
    'Prova de autoridade nao encontrou DataGrid com HWND valido.');
  RequireScrollContainerAuthority;
  RequireDataGridAuthority;
end;

procedure RequireNativeFallbackGeometry(const AForm: TForm1);
  function RectInside(const AInner, AOuter: TRect): Boolean;
  begin
    Result := (AInner.Left >= AOuter.Left) and
      (AInner.Top >= AOuter.Top) and
      (AInner.Right <= AOuter.Right) and
      (AInner.Bottom <= AOuter.Bottom);
  end;
  procedure RequireGeometry(const AGeometry: TDACNativeScrollGeometry;
    const AVertical: Boolean; const AContext: string);
  begin
    Require(RectInside(AGeometry.StartButtonRect, AGeometry.ScrollRect) and
      RectInside(AGeometry.SliderRect, AGeometry.ScrollRect) and
      RectInside(AGeometry.EndButtonRect, AGeometry.ScrollRect),
      AContext + ': parte escapou da scrollbar.');
    if AVertical then
      Require((AGeometry.StartButtonRect.Bottom <=
          AGeometry.SliderRect.Top) and
        (AGeometry.SliderRect.Bottom <= AGeometry.EndButtonRect.Top),
        AContext + ': ordem vertical arrow-thumb-arrow invalida.')
    else
      Require((AGeometry.StartButtonRect.Right <=
          AGeometry.SliderRect.Left) and
        (AGeometry.SliderRect.Right <= AGeometry.EndButtonRect.Left),
        AContext + ': ordem horizontal arrow-thumb-arrow invalida.');
  end;
  procedure RequirePureGeometry;
  var
    LGeometry: TDACNativeScrollGeometry;
    LInfo: TScrollBarInfo;
    LWindowRect: TRect;
    LClientOrigin: TPoint;
  begin
    LWindowRect := Rect(100, 100, 500, 500);
    LClientOrigin := Point(108, 130);
    Require(((LClientOrigin.X - LWindowRect.Left) = 8) and
      ((LClientOrigin.Y - LWindowRect.Top) = 30),
      'Fixture fallback perdeu delta client/window nao zero.');

    FillChar(LInfo, SizeOf(LInfo), 0);
    LInfo.cbSize := SizeOf(LInfo);
    LInfo.rcScrollBar := Rect(480, 130, 497, 430);
    LInfo.dxyLineButton := 17;
    LInfo.xyThumbTop := 70;
    LInfo.xyThumbBottom := 160;
    Require(ResolveDACNativeScrollGeometry(LInfo, LWindowRect,
        LClientOrigin, True, LGeometry),
      'Fallback vertical recusou geometria visivel.');
    Require(LGeometry.Available and
      EqualRect(LGeometry.ScrollRect, Rect(380, 30, 397, 330)) and
      EqualRect(LGeometry.SliderRect, Rect(380, 100, 397, 190)),
      'Fallback vertical nao converteu screen/client para window DC.');
    RequireGeometry(LGeometry, True, 'fallback vertical convertido');

    LInfo.xyThumbTop := -1000;
    LInfo.xyThumbBottom := 2000;
    Require(ResolveDACNativeScrollGeometry(LInfo, LWindowRect,
        LClientOrigin, True, LGeometry) and
      (LGeometry.SliderRect.Top = LGeometry.StartButtonRect.Bottom) and
      (LGeometry.SliderRect.Bottom = LGeometry.EndButtonRect.Top),
      'Fallback vertical nao clampou thumb entre os botoes.');
    RequireGeometry(LGeometry, True, 'fallback vertical clampado');

    FillChar(LInfo, SizeOf(LInfo), 0);
    LInfo.cbSize := SizeOf(LInfo);
    LInfo.rcScrollBar := Rect(108, 413, 480, 430);
    LInfo.dxyLineButton := 17;
    LInfo.xyThumbTop := 90;
    LInfo.xyThumbBottom := 200;
    Require(ResolveDACNativeScrollGeometry(LInfo, LWindowRect,
        LClientOrigin, False, LGeometry),
      'Fallback horizontal recusou geometria visivel.');
    Require(LGeometry.Available and
      EqualRect(LGeometry.ScrollRect, Rect(8, 313, 380, 330)) and
      EqualRect(LGeometry.SliderRect, Rect(98, 313, 208, 330)),
      'Fallback horizontal nao converteu screen/client para window DC.');
    RequireGeometry(LGeometry, False, 'fallback horizontal convertido');

    LInfo.xyThumbTop := -1000;
    LInfo.xyThumbBottom := 2000;
    Require(ResolveDACNativeScrollGeometry(LInfo, LWindowRect,
        LClientOrigin, False, LGeometry) and
      (LGeometry.SliderRect.Left = LGeometry.StartButtonRect.Right) and
      (LGeometry.SliderRect.Right = LGeometry.EndButtonRect.Left),
      'Fallback horizontal nao clampou thumb entre os botoes.');
    RequireGeometry(LGeometry, False, 'fallback horizontal clampado');

    LInfo.rgstate[0] := STATE_SYSTEM_UNAVAILABLE;
    Require(ResolveDACNativeScrollGeometry(LInfo, LWindowRect,
        LClientOrigin, False, LGeometry) and not LGeometry.Available and
      IsRectEmpty(LGeometry.SliderRect) and
      (LGeometry.SliderRect.Left = LGeometry.StartButtonRect.Right),
      'Fallback nao tratou STATE_SYSTEM_UNAVAILABLE de forma segura.');
    RequireGeometry(LGeometry, False, 'fallback horizontal unavailable');
    LInfo.rgstate[0] := STATE_SYSTEM_INVISIBLE;
    Require(not ResolveDACNativeScrollGeometry(LInfo, LWindowRect,
        LClientOrigin, False, LGeometry),
      'Fallback aceitou STATE_SYSTEM_INVISIBLE.');
    Writeln('MEM-DEL-DB-066 pure geometry PASS: V/H delta=8/30 ' +
      'clamp containment order invisible unavailable');
  end;
  procedure RequireFallbackPaint(const AControl: TWinControl;
    const AMode: TDACThemeMode; const AContext: string);
  var
    LClientOrigin: TPoint;
    LClipRect: TRect;
    LDC: HDC;
    LOldCursor: TPoint;
    LTokens: TDACControlTokens;
    LWindowRect: TRect;
  begin
    Require(AControl.HandleAllocated and IsWindow(AControl.Handle),
      AContext + ': HWND invalido.');
    Require(DACNativeScrollBarHookAuthorityCount(AControl.Handle) = 0,
      AContext + ': fallback deve ser exercitado somente com count=0.');
    if AControl is TDACScrollContainer then
      TDACScrollContainer(AControl).ThemeMode := AMode
    else if AControl is TDACDataGrid then
      TDACDataGrid(AControl).ThemeMode := AMode;
    PumpMessages(40);
    GetWindowRect(AControl.Handle, LWindowRect);
    LClientOrigin := Point(0, 0);
    Require(ClientToScreen(AControl.Handle, LClientOrigin),
      AContext + ': ClientToScreen falhou.');
    ScrollHookTarget := AControl.Handle;
    ScrollHookHorizontalPaintCount := 0;
    ScrollHookVerticalPaintCount := 0;
    ScrollHookStyleHookPaintCount := 0;
    ScrollHookFallbackPaintCount := 0;
    FillChar(ScrollHookHorizontalPaint, SizeOf(ScrollHookHorizontalPaint), 0);
    FillChar(ScrollHookVerticalPaint, SizeOf(ScrollHookVerticalPaint), 0);
    GetCursorPos(LOldCursor);
    SetCursorPos(0, 0);
    LDC := GetWindowDC(AControl.Handle);
    Require(LDC <> 0, AContext + ': GetWindowDC falhou.');
    try
      Require(GetClipBox(LDC, LClipRect) <> ERROR,
        AContext + ': GetClipBox falhou.');
      LTokens := TDACComponentStyle.ResolveForSurface(AControl,
        AMode).Tokens.Controls;
    finally
      ReleaseDC(AControl.Handle, LDC);
    end;
    TDACScrollContainerStyleHook.SetPaintObserver(CaptureScrollHookPaint);
    try
      { Exercise the product route. The TDAC WM_NCPAINT handler must call the
        normalized fallback only because authority count is exactly zero. }
      AControl.Perform(WM_NCPAINT, 1, 0);
      Require((ScrollHookHorizontalPaintCount = 1) and
        (ScrollHookVerticalPaintCount = 1),
        Format('%s: fallback V/H incompleto pela rota WM_NCPAINT (%d/%d).',
          [AContext, ScrollHookHorizontalPaintCount,
           ScrollHookVerticalPaintCount]));
      Require((ScrollHookStyleHookPaintCount = 0) and
        (ScrollHookFallbackPaintCount = 2) and
        (ScrollHookHorizontalPaint.Source = spsNativeFallback) and
        (ScrollHookVerticalPaint.Source = spsNativeFallback) and
        (ScrollHookHorizontalPaint.CoordinateSpace = scsControlWindowDC) and
        (ScrollHookVerticalPaint.CoordinateSpace = scsControlWindowDC),
        AContext + ': fonte/espaco do fallback divergente ou StyleHook pintou.');
      Require((ScrollHookHorizontalPaint.TargetWindow = AControl.Handle) and
        (ScrollHookVerticalPaint.TargetWindow = AControl.Handle) and
        IsWindow(ScrollHookHorizontalPaint.TargetWindow) and
        IsWindow(ScrollHookVerticalPaint.TargetWindow),
        AContext + ': observer nao registrou HWND destino real do fallback.');
      Require(ScrollHookHorizontalPaint.PresentedWithBitBlt and
        ScrollHookVerticalPaint.PresentedWithBitBlt and
        RectInside(ScrollHookHorizontalPaint.ScrollRect, LClipRect) and
        RectInside(ScrollHookVerticalPaint.ScrollRect, LClipRect),
        AContext + ': BitBlt escapou do clip do WindowDC.');
      Require((ScrollHookHorizontalPaint.TrackColor =
          LTokens.ScrollBarTrack) and
        (ScrollHookVerticalPaint.TrackColor = LTokens.ScrollBarTrack) and
        (ScrollHookHorizontalPaint.SliderColor = LTokens.ScrollBarThumb) and
        (ScrollHookVerticalPaint.SliderColor = LTokens.ScrollBarThumb) and
        (ScrollHookHorizontalPaint.StartButtonColor =
          LTokens.ScrollBarThumb) and
        (ScrollHookVerticalPaint.StartButtonColor =
          LTokens.ScrollBarThumb) and
        (ScrollHookHorizontalPaint.ArrowColor = LTokens.ScrollBarArrow) and
        (ScrollHookVerticalPaint.ArrowColor = LTokens.ScrollBarArrow),
        AContext + ': track/thumb/setas do fallback divergiram dos tokens.');
    finally
      TDACScrollContainerStyleHook.SetPaintObserver(nil);
      ScrollHookTarget := 0;
      SetCursorPos(LOldCursor.X, LOldCursor.Y);
    end;
    Require(RectInside(ScrollHookHorizontalPaint.SliderRect,
        ScrollHookHorizontalPaint.ScrollRect) and
      RectInside(ScrollHookHorizontalPaint.StartButtonRect,
        ScrollHookHorizontalPaint.ScrollRect) and
      RectInside(ScrollHookHorizontalPaint.EndButtonRect,
        ScrollHookHorizontalPaint.ScrollRect) and
      (ScrollHookHorizontalPaint.StartButtonRect.Right <=
        ScrollHookHorizontalPaint.SliderRect.Left) and
      (ScrollHookHorizontalPaint.SliderRect.Right <=
        ScrollHookHorizontalPaint.EndButtonRect.Left),
      AContext + ': geometria horizontal observada invalida.');
    Require(RectInside(ScrollHookVerticalPaint.SliderRect,
        ScrollHookVerticalPaint.ScrollRect) and
      RectInside(ScrollHookVerticalPaint.StartButtonRect,
        ScrollHookVerticalPaint.ScrollRect) and
      RectInside(ScrollHookVerticalPaint.EndButtonRect,
        ScrollHookVerticalPaint.ScrollRect) and
      (ScrollHookVerticalPaint.StartButtonRect.Bottom <=
        ScrollHookVerticalPaint.SliderRect.Top) and
      (ScrollHookVerticalPaint.SliderRect.Bottom <=
        ScrollHookVerticalPaint.EndButtonRect.Top),
      AContext + ': geometria vertical observada invalida.');
    Writeln(Format('MEM-DEL-DB-066 fallback paint PASS: %s delta=%d/%d ' +
      'clip=%s BitBlt=V/H', [AContext,
       LClientOrigin.X - LWindowRect.Left,
       LClientOrigin.Y - LWindowRect.Top, CaptureRectText(LClipRect)]));
  end;
var
  LColumn: TColumn;
  LContent: TPanel;
  LGrid: TDACDataGrid;
  LGridSource: TDataSource;
  LScroll: TDACScrollContainer;
begin
  RequirePureGeometry;
  LScroll := TDACScrollContainer.Create(AForm);
  LContent := TPanel.Create(LScroll);
  try
    LScroll.Parent := AForm;
    LScroll.BorderStyle := bsSingle;
    LScroll.ThemeMode := dtmDark;
    LScroll.SetBounds(AForm.GalleryTabs.Left + 32, 120, 420, 260);
    LContent.Parent := LScroll;
    LContent.SetBounds(0, 0, 1200, 900);
    LScroll.BringToFront;
    PumpMessages(100);
    RequireFallbackPaint(LScroll, dtmDark, 'ScrollContainer Dark');
    RequireFallbackPaint(LScroll, dtmLight, 'ScrollContainer Light');
  finally
    LScroll.Free;
  end;

  { Product fallback fixture: keep the TDACDataGrid borderless so its Skia
    chrome invariant is not perturbed merely to manufacture a client offset.
    Non-zero client/window delta is already proved by the pure V/H fixture and
    by the bordered TDACScrollContainer above. }
  LGrid := TDACDataGrid.Create(AForm);
  try
    LGrid.Parent := AForm;
    LGrid.BorderStyle := bsNone;
    LGrid.SetBounds(AForm.GalleryTabs.Left + 32, 120, 420, 260);
    LGridSource := (AForm.FindComponent('demoDataAwareGrid') as
      TDACDataGrid).DataSource;
    LGrid.DataSource := LGridSource;
    LGrid.Columns.Clear;
    LColumn := LGrid.Columns.Add;
    LColumn.FieldName := 'ID';
    LColumn.Width := 180;
    LColumn := LGrid.Columns.Add;
    LColumn.FieldName := 'CLIENTE';
    LColumn.Width := 260;
    LColumn := LGrid.Columns.Add;
    LColumn.FieldName := 'CIDADE';
    LColumn.Width := 240;
    LGrid.BringToFront;
    PumpMessages(120);
    RequireFallbackPaint(LGrid, dtmDark, 'TDACDataGrid fallback Dark');
    RequireFallbackPaint(LGrid, dtmLight, 'TDACDataGrid fallback Light');
    LGrid.DataSource := nil;
    PumpMessages(100);
  finally
    LGrid.Free;
  end;
  PumpMessages(50);
end;

procedure RequireRealStyleHookPaintSource(const AForm: TForm1);
  procedure ResetSourceProbe(const AControl: TWinControl);
  begin
    ScrollHookTarget := AControl.Handle;
    ScrollHookHorizontalPaintCount := 0;
    ScrollHookVerticalPaintCount := 0;
    ScrollHookStyleHookPaintCount := 0;
    ScrollHookFallbackPaintCount := 0;
    FillChar(ScrollHookHorizontalPaint, SizeOf(ScrollHookHorizontalPaint), 0);
    FillChar(ScrollHookVerticalPaint, SizeOf(ScrollHookVerticalPaint), 0);
  end;
  procedure RequireStyleHookPaintInfo(const AControl: TWinControl;
    const AMode: TDACThemeMode; const AContext: string);
  var
    LTokens: TDACControlTokens;
  begin
    LTokens := TDACComponentStyle.ResolveForSurface(AControl,
      AMode).Tokens.Controls;
    Require((ScrollHookStyleHookPaintCount = 2) and
      (ScrollHookFallbackPaintCount = 0) and
      (ScrollHookHorizontalPaintCount = 1) and
      (ScrollHookVerticalPaintCount = 1),
      Format('%s: StyleHook/fallback count divergente (%d/%d, H/V=%d/%d).',
        [AContext, ScrollHookStyleHookPaintCount,
         ScrollHookFallbackPaintCount, ScrollHookHorizontalPaintCount,
         ScrollHookVerticalPaintCount]));
    Require((ScrollHookHorizontalPaint.Source = spsStyleHook) and
      (ScrollHookVerticalPaint.Source = spsStyleHook) and
      (ScrollHookHorizontalPaint.CoordinateSpace =
        scsStyleHookWindowDC) and
      (ScrollHookVerticalPaint.CoordinateSpace = scsStyleHookWindowDC),
      AContext + ': fonte/espaco do StyleHook divergente.');
    Require((ScrollHookHorizontalPaint.TargetWindow = AControl.Handle) and
      (ScrollHookVerticalPaint.TargetWindow = AControl.Handle) and
      IsWindow(ScrollHookHorizontalPaint.TargetWindow) and
      IsWindow(ScrollHookVerticalPaint.TargetWindow),
      AContext + ': HWND destino real do StyleHook nao foi registrado.');
    Require(ScrollHookHorizontalPaint.RenderedWithSkia and
      ScrollHookVerticalPaint.RenderedWithSkia and
      ScrollHookHorizontalPaint.PresentedWithBitBlt and
      ScrollHookVerticalPaint.PresentedWithBitBlt,
      AContext + ': StyleHook nao preservou Skia + BitBlt em V/H.');
    Require((ScrollHookHorizontalPaint.TrackColor =
        LTokens.ScrollBarTrack) and
      (ScrollHookVerticalPaint.TrackColor = LTokens.ScrollBarTrack) and
      (ScrollHookHorizontalPaint.SliderColor = LTokens.ScrollBarThumb) and
      (ScrollHookVerticalPaint.SliderColor = LTokens.ScrollBarThumb) and
      (ScrollHookHorizontalPaint.StartButtonColor =
        LTokens.ScrollBarThumb) and
      (ScrollHookVerticalPaint.StartButtonColor = LTokens.ScrollBarThumb) and
      (ScrollHookHorizontalPaint.ArrowColor = LTokens.ScrollBarArrow) and
      (ScrollHookVerticalPaint.ArrowColor = LTokens.ScrollBarArrow),
      AContext + ': track/thumb/setas do StyleHook divergiram dos tokens.');
    Writeln(Format('MEM-DEL-DB-067 StyleHook paint PASS: %s ' +
      'source=StyleHook fallback=0 target=%p coord=StyleHookWindowDC',
      [AContext, Pointer(AControl.Handle)]));
  end;
  procedure ExerciseScrollContainer;
  const
    Modes: array[0..1] of TDACThemeMode = (dtmDark, dtmLight);
  var
    I: Integer;
    LContent: TPanel;
    LDC: HDC;
    LHook: TScrollHookAccess;
    LMode: TDACThemeMode;
    LScroll: TDACScrollContainer;
  begin
    LScroll := TDACScrollContainer.Create(AForm);
    LContent := TPanel.Create(LScroll);
    LHook := nil;
    try
      LScroll.Parent := AForm;
      LScroll.SetBounds(AForm.GalleryTabs.Left + 32, 120, 420, 260);
      LContent.Parent := LScroll;
      LContent.SetBounds(0, 0, 1200, 900);
      LScroll.BringToFront;
      PumpMessages(100);
      LHook := TScrollHookAccess.Create(LScroll);
      Require(DACNativeScrollBarHookAuthorityCount(LScroll.Handle) > 0,
        'ScrollContainer StyleHook ativo nao adquiriu autoridade.');
      LHook.ProcessHookMessage($02A2, 0, 0);
      for I := Low(Modes) to High(Modes) do
      begin
        LMode := Modes[I];
        LScroll.ThemeMode := LMode;
        PumpMessages(40);
        ResetSourceProbe(LScroll);
        TDACScrollContainerStyleHook.SetPaintObserver(CaptureScrollHookPaint);
        LDC := GetWindowDC(LScroll.Handle);
        Require(LDC <> 0, 'ScrollContainer StyleHook: GetWindowDC falhou.');
        try
          PaintDACNativeScrollBarTheme(LScroll, LMode, LDC);
        finally
          ReleaseDC(LScroll.Handle, LDC);
        end;
        LHook.PaintAxisNonClient(False);
        LHook.PaintAxisNonClient(True);
        TDACScrollContainerStyleHook.SetPaintObserver(nil);
        RequireStyleHookPaintInfo(LScroll, LMode,
          'ScrollContainer ' + GetEnumName(TypeInfo(TDACThemeMode), Ord(LMode)));
      end;
    finally
      TDACScrollContainerStyleHook.SetPaintObserver(nil);
      ScrollHookTarget := 0;
      LHook.Free;
      LScroll.Free;
    end;
  end;
  procedure ExerciseDataGrid;
  const
    Modes: array[0..1] of TDACThemeMode = (dtmDark, dtmLight);
  var
    I: Integer;
    LDC: HDC;
    LGrid: TDACDataGrid;
    LHook: TDataGridScrollHookAccess;
    LMode: TDACThemeMode;
    LOriginalMode: TDACThemeMode;
  begin
    LGrid := AForm.FindComponent('demoDataAwareGrid') as TDACDataGrid;
    LOriginalMode := LGrid.ThemeMode;
    LHook := TDataGridScrollHookAccess.Create(LGrid);
    try
      Require(DACNativeScrollBarHookAuthorityCount(LGrid.Handle) > 0,
        'DataGrid StyleHook ativo nao adquiriu autoridade.');
      for I := Low(Modes) to High(Modes) do
      begin
        LMode := Modes[I];
        LGrid.ThemeMode := LMode;
        PumpMessages(40);
        LHook.SeedAxisStates(False, tsThumbBtnHorzNormal,
          tsArrowBtnLeftNormal, tsArrowBtnRightNormal);
        LHook.SeedAxisStates(True, tsThumbBtnVertNormal,
          tsArrowBtnUpNormal, tsArrowBtnDownNormal);
        ResetSourceProbe(LGrid);
        TDACScrollContainerStyleHook.SetPaintObserver(CaptureScrollHookPaint);
        LDC := GetWindowDC(LGrid.Handle);
        Require(LDC <> 0, 'DataGrid StyleHook: GetWindowDC falhou.');
        try
          PaintDACNativeScrollBarTheme(LGrid, LMode, LDC);
        finally
          ReleaseDC(LGrid.Handle, LDC);
        end;
        LHook.PaintAxisNonClient(False);
        LHook.PaintAxisNonClient(True);
        TDACScrollContainerStyleHook.SetPaintObserver(nil);
        RequireStyleHookPaintInfo(LGrid, LMode,
          'DataGrid ' + GetEnumName(TypeInfo(TDACThemeMode), Ord(LMode)));
      end;
    finally
      TDACScrollContainerStyleHook.SetPaintObserver(nil);
      ScrollHookTarget := 0;
      LHook.Free;
      LGrid.ThemeMode := LOriginalMode;
      PumpMessages(60);
    end;
  end;
begin
  ExerciseScrollContainer;
  ExerciseDataGrid;
  Require(TStyleEngineAccess.HasExactStyleHook(TDACScrollContainer,
      TDACScrollContainerStyleHook) and
    TStyleEngineAccess.HasExactStyleHook(TDACDataGrid,
      TDACDataGridStyleHook),
    'Prova de fonte alterou o registro localizado dos StyleHooks DAC.');
end;

procedure RequireDataGridHorizontalChromeClipping(const AForm: TForm1);
var
  LAction: TDACDataGridActionKind;
  LActionCell: TRect;
  LActionColumn: TColumn;
  LActionRect: TRect;
  LAuthorityBefore: Integer;
  LCenter: Integer;
  LCityColumn: TColumn;
  LDataBottom: Integer;
  LDataSet: TDataSet;
  LGrid: TDACDataGrid;
  LGridHandle: HWND;
  LHitX: Integer;
  LHitY: Integer;
  I: Integer;
  LRecNoBefore: Integer;
  LUnexpectedBefore: string;
  LVerticalRejected: Boolean;
  LEmptyRejected: Boolean;
begin
  LGrid := TDACDataGrid.Create(AForm);
  LUnexpectedBefore := UnexpectedException;
  LAuthorityBefore := DACNativeScrollBarHookAuthorityTotalCount;
  try
    LGrid.Parent := AForm;
    LGrid.BorderStyle := bsNone;
    LGrid.SetBounds(AForm.GalleryTabs.Left + 32, 120, 420, 260);
    LGrid.DataSource := (AForm.FindComponent('demoDataAwareGrid') as
      TDACDataGrid).DataSource;
    LGrid.Columns.Clear;
    with LGrid.Columns.Add do
    begin
      FieldName := 'ID';
      Width := 120;
    end;
    with LGrid.Columns.Add do
    begin
      FieldName := 'CLIENTE';
      Width := 180;
    end;
    LCityColumn := LGrid.Columns.Add;
    LCityColumn.FieldName := 'CIDADE';
    LCityColumn.Width := 300;
    with LGrid.Columns.Add do
    begin
      FieldName := 'ACTIONS';
      Width := 220;
    end;
    LGrid.BringToFront;
    PumpMessages(100);
    LGridHandle := LGrid.Handle;
    TDataGridHandleAccess(LGrid).SetGridLeftColumn(2);
    PumpMessages(50);

    LActionCell := TDataGridHandleAccess(LGrid).GridCellRect(3,
      TDataGridHandleAccess(LGrid).GridFixedRows);
    LActionRect := TDataGridHandleAccess(LGrid).GridActionRect(LActionCell,
      mdgakEdit);
    for I := 0 to 4 do
    begin
      if (LActionRect.Left < LGrid.ClientWidth) and
        (LActionRect.Right > LGrid.ClientWidth) then
        Break;
      LCenter := (LActionRect.Left + LActionRect.Right) div 2;
      LCityColumn.Width := EnsureRange(LCityColumn.Width +
        (LGrid.ClientWidth - LCenter), 40, 800);
      TDataGridHandleAccess(LGrid).SetGridLeftColumn(2);
      PumpMessages(50);
      LActionCell := TDataGridHandleAccess(LGrid).GridCellRect(3,
        TDataGridHandleAccess(LGrid).GridFixedRows);
      LActionRect := TDataGridHandleAccess(LGrid).GridActionRect(LActionCell,
        mdgakEdit);
    end;
    Require((TDataGridHandleAccess(LGrid).GridLeftColumn > 0) and
      (LActionCell.Left < LGrid.ClientWidth) and
      (LActionCell.Width < LGrid.Columns[3].Width) and
      (LActionRect.Left < LGrid.ClientWidth) and
      (LActionRect.Right > LGrid.ClientWidth),
      Format('Fixture ACTIONS nao materializou clipping horizontal ' +
        '(leftcol=%d cell=%s edit=%s client=%d).',
        [TDataGridHandleAccess(LGrid).GridLeftColumn,
         CaptureRectText(LActionCell), CaptureRectText(LActionRect),
         LGrid.ClientWidth]));

    LDataSet := LGrid.DataSource.DataSet;
    LRecNoBefore := LDataSet.RecNo;
    LGrid.Redraw;
    PumpMessages(150);
    Require(UnexpectedException = LUnexpectedBefore,
      'Chrome horizontal parcialmente visivel gerou excecao assincrona.');
    Require(LDataSet.RecNo = LRecNoBefore,
      'Pintura horizontal do ACTIONS navegou o dataset.');

    LHitX := (Max(0, LActionRect.Left) + LGrid.ClientWidth - 1) div 2;
    LHitY := (LActionRect.Top + LActionRect.Bottom) div 2;
    Require(TDataGridHandleAccess(LGrid).GridTryHitAction(LHitX, LHitY,
        LActionColumn, LAction) and (LAction = mdgakEdit) and
      (LActionColumn = LGrid.Columns[3]),
      'Hit-test nao reconheceu a porcao visivel do botao ACTIONS/Edit.');
    Require(not TDataGridHandleAccess(LGrid).GridTryHitAction(
        LGrid.ClientWidth, LHitY, LActionColumn, LAction),
      'Hit-test aceitou ponto horizontal fora do client.');
    Require(LDataSet.RecNo = LRecNoBefore,
      'Hit-test horizontal navegou o dataset.');

    LDataBottom := LGrid.ClientHeight - Round(
      TDACComponentStyle.ResolveForSurface(LGrid,
        LGrid.ThemeMode).Tokens.Controls.DataGridFooterHeight);
    TDataGridHandleAccess(LGrid).GridGuardDataChromeRect(TRectF.Create(
      -80, TDataGridHandleAccess(LGrid).GridHeaderHeight,
      LGrid.ClientWidth + 80,
      TDataGridHandleAccess(LGrid).GridHeaderHeight + 16),
      TDataGridHandleAccess(LGrid).GridHeaderHeight, LDataBottom);
    LVerticalRejected := False;
    try
      TDataGridHandleAccess(LGrid).GridGuardDataChromeRect(TRectF.Create(
        0, TDataGridHandleAccess(LGrid).GridHeaderHeight - 1, 40,
        TDataGridHandleAccess(LGrid).GridHeaderHeight + 15),
        TDataGridHandleAccess(LGrid).GridHeaderHeight, LDataBottom);
    except
      on E: EInvalidOperation do
        LVerticalRejected := True;
    end;
    LEmptyRejected := False;
    try
      TDataGridHandleAccess(LGrid).GridGuardDataChromeRect(TRectF.Create(
        10, TDataGridHandleAccess(LGrid).GridHeaderHeight,
        10, TDataGridHandleAccess(LGrid).GridHeaderHeight + 15),
        TDataGridHandleAccess(LGrid).GridHeaderHeight, LDataBottom);
    except
      on E: EInvalidOperation do
        LEmptyRejected := True;
    end;
    Require(LVerticalRejected and LEmptyRejected,
      'GuardDataChromeRect deixou de bloquear escape vertical ou vazio.');
    Writeln(Format('MEM-DEL-DB-068 horizontal chrome PASS: leftcol=%d ' +
      'cell=%s edit=%s hit=%d/%d recno=%d vertical_guard=PASS ' +
      'empty_guard=PASS', [TDataGridHandleAccess(LGrid).GridLeftColumn,
       CaptureRectText(LActionCell), CaptureRectText(LActionRect),
       LHitX, LHitY, LRecNoBefore]));
    LGrid.DataSource := nil;
    PumpMessages(100);
  finally
    LGrid.Free;
    PumpMessages(100);
  end;
  Require((LGridHandle = 0) or not IsWindow(LGridHandle),
    'Fixture horizontal preservou HWND da TDACDataGrid.');
  Require(DACNativeScrollBarHookAuthorityTotalCount = LAuthorityBefore,
    'Fixture horizontal alterou autoridade global de scrollbar.');
  Require(UnexpectedException = LUnexpectedBefore,
    'Teardown da fixture horizontal gerou excecao assincrona.');
end;

function ReadHorizontalScrollPosition(const AHandle: HWND;
  const AContext: string): Integer;
var
  LInfo: TScrollInfo;
begin
  FillChar(LInfo, SizeOf(LInfo), 0);
  LInfo.cbSize := SizeOf(LInfo);
  LInfo.fMask := SIF_POS;
  Require((AHandle <> 0) and IsWindow(AHandle) and
    GetScrollInfo(AHandle, SB_HORZ, LInfo),
    AContext + ': GetScrollInfo(SB_HORZ) falhou.');
  Result := LInfo.nPos;
end;

procedure ExerciseDataAwareGridHorizontalSelection(const AForm: TForm1);
const
  ExpectedVisibleRows = 10;
  TestRecordId = 1008;
var
  LBarBefore: Integer;
  LBarAfter: Integer;
  LCell: TRect;
  LClientBefore: string;
  LCycle: Integer;
  LDataSet: TClientDataSet;
  LExpectedId: Integer;
  LExpectedRecNo: Integer;
  LGrid: TDACDataGrid;
  LLeftBefore: Integer;
  LLeftAfter: Integer;
  LPaintBox: TDACDataGridPaintBox;
  LRowBefore: Integer;
  LTopRowBefore: Integer;
  I: Integer;
  procedure RequirePaintedRows(const AContext: string);
  var
    LIdBeforePaint: Integer;
    LRecNoBeforePaint: Integer;
  begin
    LRecNoBeforePaint := LDataSet.RecNo;
    LIdBeforePaint := LDataSet.FieldByName('ID').AsInteger;
    LGrid.Redraw;
    PumpMessages(80);
    Require((LDataSet.RecNo = LRecNoBeforePaint) and
      (LDataSet.FieldByName('ID').AsInteger = LIdBeforePaint),
      AContext + ': repaint Skia navegou o dataset.');
    Require(LGrid.LastPaintedDataRowCount = ExpectedVisibleRows,
      Format('%s: esperado %d rows pintadas, obtido %d.',
        [AContext, ExpectedVisibleRows, LGrid.LastPaintedDataRowCount]));
    Require(LGrid.LastPaintedDataCellCount >=
      LGrid.LastPaintedDataRowCount,
      AContext + ': repaint nao materializou celulas para todas as rows.');
    Require(LGrid.LastPaintedDataPixelHeight >=
      LGrid.LastPaintedDataRowCount,
      AContext + ': rows pintadas nao produziram altura visual mensuravel.');
  end;
  procedure ClickDataCell(const AColumn: Integer;
    const AContext: string);
  begin
    LCell := TDataGridHandleAccess(LGrid).GridCellRect(AColumn,
      TDataGridHandleAccess(LGrid).GridRow);
    Require(TDataGridHandleAccess(LGrid).GridAcceptsDataCellRect(LCell,
        LGrid.ClientWidth, TDataGridHandleAccess(LGrid).GridHeaderHeight,
        LGrid.ClientHeight),
      AContext + ': celula alvo nao estava totalmente visivel.');
    TDataGridPaintBoxAccess(LPaintBox).SimulateClick(
      LCell.Left + Min(12, Max(1, (LCell.Right - LCell.Left) div 2)),
      LCell.Top + Min(12, Max(1, (LCell.Bottom - LCell.Top) div 2)));
    PumpMessages(80);
  end;
begin
  AForm.SetBounds(AForm.Left, AForm.Top, 1200, 760);
  AForm.GalleryTabs.ActivePage :=
    AForm.FindComponent('tsDataAware') as TTabSheet;
  PumpMessages(100);
  LGrid := AForm.FindComponent('demoDataAwareGrid') as TDACDataGrid;
  LDataSet := AForm.FindComponent('demoGridDataSet') as TClientDataSet;
  Require((LGrid <> nil) and (LDataSet <> nil) and LDataSet.Active,
    'Gate horizontal do Data-Aware nao encontrou grid/dataset ativos.');

  LPaintBox := nil;
  for I := 0 to LGrid.ComponentCount - 1 do
    if LGrid.Components[I] is TDACDataGridPaintBox then
    begin
      LPaintBox := TDACDataGridPaintBox(LGrid.Components[I]);
      Break;
    end;
  Require(LPaintBox <> nil,
    'Gate horizontal nao encontrou o paintbox Skia real da TDACDataGrid.');

  for LCycle := 1 to 3 do
  begin
    LGrid.Perform(WM_HSCROLL, SB_LEFT, 0);
    PumpMessages(80);
    Require(LDataSet.Locate('ID', TestRecordId, []),
      Format('Ciclo %d nao localizou o ID %d.', [LCycle, TestRecordId]));
    PumpMessages(80);
    Require(TDataGridHandleAccess(LGrid).GridBufferedRecordCount >=
      ExpectedVisibleRows,
      Format('Ciclo %d esperava buffer para ao menos %d rows no Demo real; obtido %d.',
        [LCycle, ExpectedVisibleRows,
         TDataGridHandleAccess(LGrid).GridBufferedRecordCount]));
    RequirePaintedRows(Format('Ciclo %d baseline', [LCycle]));

    LExpectedRecNo := LDataSet.RecNo;
    LExpectedId := LDataSet.FieldByName('ID').AsInteger;
    ClickDataCell(0, Format('Ciclo %d clique ID', [LCycle]));
    Require((TDataGridHandleAccess(LGrid).GridColumn = 0) and
      (LDataSet.RecNo = LExpectedRecNo) and
      (LDataSet.FieldByName('ID').AsInteger = LExpectedId),
      Format('Ciclo %d: clique ID alterou selecao/registro.', [LCycle]));
    RequirePaintedRows(Format('Ciclo %d apos ID', [LCycle]));

    LLeftBefore := TDataGridHandleAccess(LGrid).GridLeftColumn;
    LBarBefore := ReadHorizontalScrollPosition(LGrid.Handle,
      Format('Ciclo %d antes do CLIENTE', [LCycle]));
    ClickDataCell(1, Format('Ciclo %d clique CLIENTE', [LCycle]));
    LLeftAfter := TDataGridHandleAccess(LGrid).GridLeftColumn;
    LBarAfter := ReadHorizontalScrollPosition(LGrid.Handle,
      Format('Ciclo %d depois do CLIENTE', [LCycle]));
    Require((TDataGridHandleAccess(LGrid).GridColumn = 1) and
      (LDataSet.RecNo = LExpectedRecNo) and
      (LDataSet.FieldByName('ID').AsInteger = LExpectedId),
      Format('Ciclo %d: clique CLIENTE alterou registro/selecao.', [LCycle]));
    Require((LLeftAfter = LLeftBefore) and (LBarAfter = LBarBefore),
      Format('Ciclo %d: clique CLIENTE visivel rolou H inesperadamente (%d/%d -> %d/%d).',
        [LCycle, LLeftBefore, LBarBefore, LLeftAfter, LBarAfter]));
    RequirePaintedRows(Format('Ciclo %d apos CLIENTE', [LCycle]));

    LLeftBefore := TDataGridHandleAccess(LGrid).GridLeftColumn;
    LBarBefore := ReadHorizontalScrollPosition(LGrid.Handle,
      Format('Ciclo %d antes do H-scroll', [LCycle]));
    LGrid.Perform(WM_HSCROLL, SB_RIGHT, 0);
    PumpMessages(100);
    LLeftAfter := TDataGridHandleAccess(LGrid).GridLeftColumn;
    LBarAfter := ReadHorizontalScrollPosition(LGrid.Handle,
      Format('Ciclo %d H-scroll direita', [LCycle]));
    Require((LLeftAfter <> LLeftBefore) or (LBarAfter <> LBarBefore),
      Format('Ciclo %d: H-scroll proprio nao se moveu para a direita.',
        [LCycle]));
    Require((LDataSet.RecNo = LExpectedRecNo) and
      (LDataSet.FieldByName('ID').AsInteger = LExpectedId),
      Format('Ciclo %d: H-scroll direita navegou dataset.', [LCycle]));
    RequirePaintedRows(Format('Ciclo %d H-scroll direita', [LCycle]));

    LGrid.Perform(WM_HSCROLL, SB_LEFT, 0);
    PumpMessages(100);
    Require((TDataGridHandleAccess(LGrid).GridLeftColumn = LLeftBefore) and
      (ReadHorizontalScrollPosition(LGrid.Handle,
        Format('Ciclo %d H-scroll retorno', [LCycle])) = LBarBefore),
      Format('Ciclo %d: H-scroll nao retornou ao ponto inicial.', [LCycle]));
    RequirePaintedRows(Format('Ciclo %d H-scroll retorno', [LCycle]));

    LClientBefore := LDataSet.FieldByName('CLIENTE').AsString;
    LDataSet.Edit;
    ClickDataCell(1, Format('Ciclo %d edicao CLIENTE', [LCycle]));
    LGrid.SetFocus;
    SendKey(LGrid, VK_F2);
    PumpMessages(50);
    Require(TDataGridHandleAccess(LGrid).GridEditorMode and
      TDataGridHandleAccess(LGrid).GridEditorVisible and
      TDataGridHandleAccess(LGrid).GridEditorFocused,
      Format('Ciclo %d: F2 nao abriu editor nativo.', [LCycle]));
    TDataGridHandleAccess(LGrid).GridEditorChar('X');
    PumpMessages(50);
    LDataSet.UpdateRecord;
    Require(LDataSet.Modified and
      (LDataSet.FieldByName('CLIENTE').AsString <> LClientBefore),
      Format('Ciclo %d: edicao CLIENTE nao materializou alteracao.',
        [LCycle]));
    LDataSet.Cancel;
    PumpMessages(80);
    Require((LDataSet.State = dsBrowse) and
      (LDataSet.FieldByName('CLIENTE').AsString = LClientBefore),
      Format('Ciclo %d: Cancel nao restaurou CLIENTE.', [LCycle]));
    RequirePaintedRows(Format('Ciclo %d apos F2/Cancel', [LCycle]));

    LRowBefore := LDataSet.RecNo;
    LTopRowBefore := TDataGridHandleAccess(LGrid).GridTopRow;
    LGrid.Perform(WM_VSCROLL, SB_LINEDOWN, 0);
    PumpMessages(100);
    Require((LDataSet.RecNo <> LRowBefore) or
      (TDataGridHandleAccess(LGrid).GridTopRow <> LTopRowBefore),
      Format('Ciclo %d: V-scroll nao moveu cursor/viewport.', [LCycle]));
    RequirePaintedRows(Format('Ciclo %d apos V-scroll', [LCycle]));

    WriteLn(Format(
      'MEM-DEL-DB-027 ciclo=%d rows=%d cells=%d pixels=%d recno=%d leftcol=%d hpos=%d first=%s last=%s selected=%s top=%d active=%d',
      [LCycle, LGrid.LastPaintedDataRowCount,
       LGrid.LastPaintedDataCellCount, LGrid.LastPaintedDataPixelHeight,
       LDataSet.RecNo, TDataGridHandleAccess(LGrid).GridLeftColumn,
       ReadHorizontalScrollPosition(LGrid.Handle,
         Format('Ciclo %d evidencia final', [LCycle])),
       LGrid.LastPaintedFirstDataText, LGrid.LastPaintedLastDataText,
       LGrid.LastPaintedSelectedDataText, LGrid.LastPaintedGridTopRow,
       LGrid.LastPaintedDataLinkActiveRecord]));
  end;
end;

procedure ExerciseDataAwareGridVerticalSynchronization(const AForm: TForm1);
const
  StartRecordId = 1008;
  TargetRecordId = 1013;
  ExpectedVisibleRows = 10;
var
  LBookmark: TBookmark;
  LCycle: Integer;
  LDataSet: TClientDataSet;
  LDate: TDACDBDateTimePicker;
  LEdit: TDACDBEdit;
  LGrid: TDACDataGrid;
  LPaintBox: TDACDataGridPaintBox;
  LSlider: TDACDBSlider;
  LFirstBefore: string;
  LLastBefore: string;
  LTopBefore: Integer;
  I: Integer;
  procedure RequireCurrentFrame(const AContext: string;
    const AExpectedId: Integer);
  var
    LFirstId: Integer;
    LLastId: Integer;
    LRecNoBeforePaint: Integer;
  begin
    LRecNoBeforePaint := LDataSet.RecNo;
    LBookmark := LDataSet.Bookmark;
    LGrid.Redraw;
    PumpMessages(100);
    Require((LDataSet.RecNo = LRecNoBeforePaint) and
      (LDataSet.CompareBookmarks(LBookmark, LDataSet.Bookmark) = 0),
      AContext + ': repaint Skia navegou o dataset/bookmark.');
    LFirstId := StrToIntDef(LGrid.LastPaintedFirstDataText, -1);
    LLastId := StrToIntDef(LGrid.LastPaintedLastDataText, -1);
    Require((LGrid.LastPaintedDataRowCount = ExpectedVisibleRows) and
      (LGrid.LastPaintedDataCellCount >= ExpectedVisibleRows),
      Format('%s: frame incompleto rows=%d cells=%d.',
        [AContext, LGrid.LastPaintedDataRowCount,
         LGrid.LastPaintedDataCellCount]));
    Require((LFirstId <= AExpectedId) and (LLastId >= AExpectedId),
      Format('%s: ID %d fora da janela visivel %d..%d.',
        [AContext, AExpectedId, LFirstId, LLastId]));
    Require(LGrid.LastPaintedSelectedDataText = IntToStr(AExpectedId),
      Format('%s: highlight=%s, esperado=%d.',
        [AContext, LGrid.LastPaintedSelectedDataText, AExpectedId]));
    Require(LDataSet.FieldByName('ID').AsInteger = AExpectedId,
      Format('%s: dataset nao esta no ID %d.', [AContext, AExpectedId]));
  end;
  procedure RequireExternalControls(const AContext: string;
    const ARecordNumber: Integer);
  begin
    Require(LEdit.Text = 'Cliente demonstracao ' + IntToStr(ARecordNumber),
      AContext + ': TDACDBEdit nao acompanhou o dataset.');
    Require(Trunc(LDate.DateTime) =
      Trunc(EncodeDate(2025, 5, ARecordNumber)),
      AContext + ': TDACDBDateTimePicker nao acompanhou o dataset.');
    Require(LSlider.Position = (ARecordNumber mod 10) * 10,
      AContext + ': TDACDBSlider nao acompanhou o dataset.');
  end;
  procedure ScrollBarToRecord(const ARecordNumber: Integer;
    const AContext: string);
  var
    LInfo: TScrollInfo;
  begin
    FillChar(LInfo, SizeOf(LInfo), 0);
    LInfo.cbSize := SizeOf(LInfo);
    LInfo.fMask := SIF_POS;
    LInfo.nPos := ARecordNumber;
    Require(SetScrollInfo(LGrid.Handle, SB_VERT, LInfo, True) <> 0,
      AContext + ': SetScrollInfo(SB_VERT) falhou.');
    LGrid.Perform(WM_VSCROLL,
      MakeWParam(SB_THUMBPOSITION, ARecordNumber), 0);
  end;
begin
  AForm.SetBounds(AForm.Left, AForm.Top, 1200, 760);
  AForm.GalleryTabs.ActivePage :=
    AForm.FindComponent('tsDataAware') as TTabSheet;
  PumpMessages(100);
  LGrid := AForm.FindComponent('demoDataAwareGrid') as TDACDataGrid;
  LDataSet := AForm.FindComponent('demoGridDataSet') as TClientDataSet;
  LEdit := AForm.FindComponent('demoDBEdit') as TDACDBEdit;
  LDate := AForm.FindComponent('demoDBDate') as TDACDBDateTimePicker;
  LSlider := AForm.FindComponent('demoDBSlider') as TDACDBSlider;
  Require((LGrid <> nil) and (LDataSet <> nil) and LDataSet.Active and
    (LEdit <> nil) and (LDate <> nil) and (LSlider <> nil),
    'Gate vertical nao encontrou Grid/dataset/controles externos.');

  LPaintBox := nil;
  for I := 0 to LGrid.ComponentCount - 1 do
    if LGrid.Components[I] is TDACDataGridPaintBox then
    begin
      LPaintBox := TDACDataGridPaintBox(LGrid.Components[I]);
      Break;
    end;
  Require(LPaintBox <> nil,
    'Gate vertical nao encontrou o paintbox Skia real.');

  for LCycle := 1 to 3 do
  begin
    LDataSet.First;
    PumpMessages(120);
    Require(LDataSet.Locate('ID', StartRecordId, []),
      Format('Ciclo vertical %d nao localizou ID 1008.', [LCycle]));
    PumpMessages(180);
    RequireCurrentFrame(Format('Ciclo vertical %d baseline', [LCycle]),
      StartRecordId);
    RequireExternalControls(Format('Ciclo vertical %d baseline', [LCycle]),
      8);
    LTopBefore := LGrid.LastPaintedGridTopRow;
    LFirstBefore := LGrid.LastPaintedFirstDataText;
    LLastBefore := LGrid.LastPaintedLastDataText;

    // Reproduce a native vertical scrollbar thumb release at record 13.
    ScrollBarToRecord(13, Format('Ciclo vertical %d scrollbar', [LCycle]));
    PumpMessages(180);
    Require((LDataSet.RecNo = 13) and
      (LDataSet.FieldByName('ID').AsInteger = TargetRecordId),
      Format('Ciclo vertical %d nao chegou ao registro 13/ID1013; recno=%d id=%d top=%d active=%d.',
        [LCycle, LDataSet.RecNo, LDataSet.FieldByName('ID').AsInteger,
         TDataGridHandleAccess(LGrid).GridTopRow,
         LGrid.LastPaintedDataLinkActiveRecord]));
    RequireCurrentFrame(Format('Ciclo vertical %d scrollbar', [LCycle]),
      TargetRecordId);
    Require((LGrid.LastPaintedGridTopRow <> LTopBefore) or
      (LGrid.LastPaintedFirstDataText <> LFirstBefore) or
      (LGrid.LastPaintedLastDataText <> LLastBefore),
      Format('Ciclo vertical %d nao deslocou TopRow nem a janela do buffer.',
        [LCycle]));
    RequireExternalControls(Format('Ciclo vertical %d registro13', [LCycle]),
      13);

    // Reproduce the physical stability interval from MEM-QA-DB-016.
    PumpMessages(650);
    RequireCurrentFrame(Format('Ciclo vertical %d apos 650ms', [LCycle]),
      TargetRecordId);

    // Horizontal interaction must not detach the vertical buffer approved
    // here or regress MEM-DEL-DB-027.
    LGrid.Perform(WM_HSCROLL, SB_RIGHT, 0);
    PumpMessages(100);
    RequireCurrentFrame(Format('Ciclo vertical %d H-direita', [LCycle]),
      TargetRecordId);
    LGrid.Perform(WM_HSCROLL, SB_LEFT, 0);
    PumpMessages(100);
    RequireCurrentFrame(Format('Ciclo vertical %d H-retorno', [LCycle]),
      TargetRecordId);

    // Exercise the real overlay wheel route as well. Its distance follows
    // the Windows wheel-lines preference; the frame must follow whichever
    // record the native TDBGrid reaches.
    LGrid.Loading := True;
    LGrid.Loading := False;
    Require(TDataGridPaintBoxAccess(LPaintBox).SimulateMouseWheel(-120),
      Format('Ciclo vertical %d wheel nao foi consumido.', [LCycle]));
    PumpMessages(180);
    RequireCurrentFrame(Format('Ciclo vertical %d wheel', [LCycle]),
      LDataSet.FieldByName('ID').AsInteger);
    RequireExternalControls(Format('Ciclo vertical %d wheel', [LCycle]),
      LDataSet.RecNo);

    // External navigation back must realign grid, highlight and controls.
    LDataSet.RecNo := 8;
    PumpMessages(180);
    RequireCurrentFrame(Format('Ciclo vertical %d retorno externo', [LCycle]),
      StartRecordId);
    RequireExternalControls(Format('Ciclo vertical %d retorno externo',
      [LCycle]), 8);

    WriteLn(Format(
      'MEM-DEL-DB-028 ciclo=%d rows=%d first=%s last=%s selected=%s recno=%d top=%d active=%d buffer=%d',
      [LCycle, LGrid.LastPaintedDataRowCount,
       LGrid.LastPaintedFirstDataText, LGrid.LastPaintedLastDataText,
       LGrid.LastPaintedSelectedDataText, LDataSet.RecNo,
       LGrid.LastPaintedGridTopRow,
       LGrid.LastPaintedDataLinkActiveRecord,
       LGrid.LastPaintedDataLinkRecordCount]));
  end;
end;

procedure ExerciseDataAwareGridPhysicalWheelSynchronization(
  const AForm: TForm1);
const
  StartRecordId = 1008;
  TargetRecordId = 1013;
  ExpectedVisibleRows = 10;
var
  LBookmark: TBookmark;
  LCell: TRect;
  LChromeBefore: Cardinal;
  LCycle: Integer;
  LDataSet: TClientDataSet;
  LDate: TDACDBDateTimePicker;
  LEdit: TDACDBEdit;
  LGrid: TDACDataGrid;
  LGridRouteBefore: Integer;
  LHit: HWND;
  LMouseMessageBefore: Integer;
  LNativeScrollBefore: Integer;
  LPaintBoxRouteBefore: Integer;
  LPoint: TPoint;
  LRedrawBefore: Integer;
  LSlider: TDACDBSlider;
  LTopBefore: Integer;
  procedure RequireExternalControls(const AContext: string;
    const ARecordNumber: Integer);
  begin
    Require(LEdit.Text = 'Cliente demonstracao ' + IntToStr(ARecordNumber),
      AContext + ': TDACDBEdit nao acompanhou o dataset.');
    Require(Trunc(LDate.DateTime) =
      Trunc(EncodeDate(2025, 5, ARecordNumber)),
      AContext + ': TDACDBDateTimePicker nao acompanhou o dataset.');
    Require(LSlider.Position = (ARecordNumber mod 10) * 10,
      AContext + ': TDACDBSlider nao acompanhou o dataset.');
  end;
  procedure RequireCurrentFrame(const AContext: string;
    const AExpectedId: Integer);
  var
    LFirstId: Integer;
    LLastId: Integer;
    LRecNoBeforePaint: Integer;
  begin
    LRecNoBeforePaint := LDataSet.RecNo;
    LBookmark := LDataSet.Bookmark;
    LGrid.Redraw;
    PumpMessages(80);
    Require((LDataSet.RecNo = LRecNoBeforePaint) and
      (LDataSet.CompareBookmarks(LBookmark, LDataSet.Bookmark) = 0),
      AContext + ': paint/repaint navegou o dataset.');
    LFirstId := StrToIntDef(LGrid.LastPaintedFirstDataText, -1);
    LLastId := StrToIntDef(LGrid.LastPaintedLastDataText, -1);
    Require((LGrid.LastPaintedDataRowCount = ExpectedVisibleRows) and
      (LGrid.LastPaintedDataCellCount >= ExpectedVisibleRows),
      Format('%s: frame incompleto rows=%d cells=%d.',
        [AContext, LGrid.LastPaintedDataRowCount,
         LGrid.LastPaintedDataCellCount]));
    Require((LFirstId <= AExpectedId) and (LLastId >= AExpectedId),
      Format('%s: ID %d fora da janela %d..%d.',
        [AContext, AExpectedId, LFirstId, LLastId]));
    Require(LGrid.LastPaintedSelectedDataText = IntToStr(AExpectedId),
      Format('%s: highlight=%s, esperado=%d.',
        [AContext, LGrid.LastPaintedSelectedDataText, AExpectedId]));
  end;
begin
  AForm.SetBounds(AForm.Left, AForm.Top, 1200, 760);
  AForm.GalleryTabs.ActivePage :=
    AForm.FindComponent('tsDataAware') as TTabSheet;
  PumpMessages(100);
  LGrid := AForm.FindComponent('demoDataAwareGrid') as TDACDataGrid;
  LDataSet := AForm.FindComponent('demoGridDataSet') as TClientDataSet;
  LEdit := AForm.FindComponent('demoDBEdit') as TDACDBEdit;
  LDate := AForm.FindComponent('demoDBDate') as TDACDBDateTimePicker;
  LSlider := AForm.FindComponent('demoDBSlider') as TDACDBSlider;
  Require((LGrid <> nil) and LGrid.HandleAllocated and (LDataSet <> nil) and
    LDataSet.Active and (LEdit <> nil) and (LDate <> nil) and
    (LSlider <> nil),
    'Gate fisico DB029 nao encontrou grid/dataset/controles externos.');

  for LCycle := 1 to 3 do
  begin
    LGrid.Loading := True;
    LGrid.Loading := False;
    LDataSet.First;
    PumpMessages(100);
    Require(LDataSet.Locate('ID', StartRecordId, []),
      Format('Ciclo fisico %d nao localizou ID1008.', [LCycle]));
    PumpMessages(160);
    RequireCurrentFrame(Format('Ciclo fisico %d baseline', [LCycle]),
      StartRecordId);
    RequireExternalControls(Format('Ciclo fisico %d baseline', [LCycle]), 8);

    LCell := TDataGridHandleAccess(LGrid).GridCellRect(0,
      TDataGridHandleAccess(LGrid).GridRow);
    Require((LCell.Right > LCell.Left) and (LCell.Bottom > LCell.Top),
      Format('Ciclo fisico %d nao materializou celula ID1008.', [LCycle]));
    LPoint := LGrid.ClientToScreen(Point(
      (LCell.Left + LCell.Right) div 2,
      (LCell.Top + LCell.Bottom) div 2));
    SetCursorPos(LPoint.X, LPoint.Y);
    LHit := WindowFromPoint(LPoint);
    Require((LHit = LGrid.Handle) or IsChild(LGrid.Handle, LHit),
      Format('Ciclo fisico %d: cursor nao esta sobre grid/paintbox ' +
        '(hit=%d grid=%d).', [LCycle, NativeInt(LHit),
         NativeInt(LGrid.Handle)]));

    LGrid.SetFocus;
    Require(LGrid.Focused,
      Format('Ciclo fisico %d: grid nao recebeu foco.', [LCycle]));
    LMouseMessageBefore := LGrid.MouseWheelMessageCount;
    LGridRouteBefore := LGrid.GridWheelRouteCount;
    LPaintBoxRouteBefore := LGrid.PaintBoxWheelRouteCount;
    LNativeScrollBefore := LGrid.NativeWheelScrollMessageCount;
    LRedrawBefore := LGrid.WheelSynchronizedRedrawCount;
    LChromeBefore := LGrid.ChromeRevision;
    LTopBefore := TDataGridHandleAccess(LGrid).GridTopRow;

    // Same physical contract as QA017: screen coordinates over the Skia
    // body, focus on the native TDBGrid HWND and the five-detent gesture that
    // moved ID1008 to ID1013, delivered as one real WM_MOUSEWHEEL message
    // through that HWND's VCL queue. This must not call a protected handler.
    SendMessage(LGrid.Handle, WM_MOUSEWHEEL,
      MakeWParam(0, Word(SmallInt(-5 * WHEEL_DELTA))),
      MakeLong(Word(LPoint.X), Word(LPoint.Y)));
    Require((LDataSet.RecNo = 13) and
      (LDataSet.FieldByName('ID').AsInteger = TargetRecordId),
      Format('Ciclo fisico %d: wheel nao chegou ao registro13/ID1013 ' +
        '(recno=%d id=%d top=%d).', [LCycle, LDataSet.RecNo,
         LDataSet.FieldByName('ID').AsInteger,
         TDataGridHandleAccess(LGrid).GridTopRow]));
    Require((LGrid.MouseWheelMessageCount = LMouseMessageBefore + 1) and
      (LGrid.GridWheelRouteCount = LGridRouteBefore + 1) and
      (LGrid.PaintBoxWheelRouteCount = LPaintBoxRouteBefore) and
      (LGrid.NativeWheelScrollMessageCount = LNativeScrollBefore) and
      (LGrid.LastWheelRoute = dgwrGridWindow),
      Format('Ciclo fisico %d: rota divergente mouse=%d/%d grid=%d/%d ' +
        'overlay=%d/%d vscroll=%d/%d last=%d hit=%d.',
        [LCycle, LGrid.MouseWheelMessageCount, LMouseMessageBefore,
         LGrid.GridWheelRouteCount, LGridRouteBefore,
         LGrid.PaintBoxWheelRouteCount, LPaintBoxRouteBefore,
         LGrid.NativeWheelScrollMessageCount, LNativeScrollBefore,
         Ord(LGrid.LastWheelRoute), NativeInt(LHit)]));

    // The coalesced message must render only after SendMessage returned with
    // TDBGrid's final DataLink buffer and TopRow.
    PumpMessages(180);
    Require((LGrid.WheelSynchronizedRedrawCount = LRedrawBefore + 1) and
      (LGrid.ChromeRevision > LChromeBefore) and
      (TDataGridHandleAccess(LGrid).GridTopRow <> LTopBefore),
      Format('Ciclo fisico %d: sincronizacao pos-wheel ausente ' +
        '(redraw=%d/%d chrome=%d/%d top=%d/%d).',
        [LCycle, LGrid.WheelSynchronizedRedrawCount, LRedrawBefore,
         LGrid.ChromeRevision, LChromeBefore,
         TDataGridHandleAccess(LGrid).GridTopRow, LTopBefore]));
    RequireCurrentFrame(Format('Ciclo fisico %d registro13', [LCycle]),
      TargetRecordId);
    RequireExternalControls(Format('Ciclo fisico %d registro13', [LCycle]),
      13);

    PumpMessages(750);
    RequireCurrentFrame(Format('Ciclo fisico %d idle750/repaint', [LCycle]),
      TargetRecordId);
    RequireExternalControls(
      Format('Ciclo fisico %d idle750/repaint', [LCycle]), 13);
    WriteLn(Format(
      'MEM-DEL-DB-029 record13 ciclo=%d mouse=%d grid=%d overlay=%d ' +
      'vscroll=%d wheelRedraw=%d hit=%d rows=%d first=%s last=%s ' +
      'selected=%s recno=%d top=%d active=%d buffer=%d edit=%s ' +
      'date=%s slider=%d',
      [LCycle, LGrid.MouseWheelMessageCount, LGrid.GridWheelRouteCount,
       LGrid.PaintBoxWheelRouteCount, LGrid.NativeWheelScrollMessageCount,
       LGrid.WheelSynchronizedRedrawCount, NativeInt(LHit),
       LGrid.LastPaintedDataRowCount, LGrid.LastPaintedFirstDataText,
       LGrid.LastPaintedLastDataText, LGrid.LastPaintedSelectedDataText,
       LDataSet.RecNo, LGrid.LastPaintedGridTopRow,
       LGrid.LastPaintedDataLinkActiveRecord,
       LGrid.LastPaintedDataLinkRecordCount, LEdit.Text,
       DateToStr(LDate.DateTime), LSlider.Position]));

    LGrid.Perform(WM_HSCROLL, SB_RIGHT, 0);
    PumpMessages(80);
    RequireCurrentFrame(Format('Ciclo fisico %d H-direita', [LCycle]),
      TargetRecordId);
    LGrid.Perform(WM_HSCROLL, SB_LEFT, 0);
    PumpMessages(80);
    RequireCurrentFrame(Format('Ciclo fisico %d H-retorno', [LCycle]),
      TargetRecordId);

    LDataSet.Edit;
    LCell := TDataGridHandleAccess(LGrid).GridCellRect(1,
      TDataGridHandleAccess(LGrid).GridRow);
    LGrid.Perform(WM_LBUTTONDOWN, MK_LBUTTON,
      (LCell.Left + 12) or ((LCell.Top + 12) shl 16));
    LGrid.Perform(WM_LBUTTONUP, 0,
      (LCell.Left + 12) or ((LCell.Top + 12) shl 16));
    LGrid.SetFocus;
    SendKey(LGrid, VK_F2);
    PumpMessages(50);
    Require(TDataGridHandleAccess(LGrid).GridEditorMode and
      TDataGridHandleAccess(LGrid).GridEditorVisible and
      TDataGridHandleAccess(LGrid).GridEditorFocused,
      Format('Ciclo fisico %d: F2 nao preservado apos wheel/H.', [LCycle]));
    LDataSet.Cancel;
    PumpMessages(80);
    RequireCurrentFrame(Format('Ciclo fisico %d F2/Cancel', [LCycle]),
      TargetRecordId);

    LDataSet.RecNo := 8;
    PumpMessages(160);
    RequireCurrentFrame(Format('Ciclo fisico %d retorno1008', [LCycle]),
      StartRecordId);
    RequireExternalControls(
      Format('Ciclo fisico %d retorno1008', [LCycle]), 8);

    WriteLn(Format(
      'MEM-DEL-DB-029 ciclo=%d route=grid mouse=%d grid=%d overlay=%d ' +
      'vscroll=%d wheelRedraw=%d hit=%d rows=%d first=%s last=%s ' +
      'selected=%s recno=%d top=%d active=%d buffer=%d',
      [LCycle, LGrid.MouseWheelMessageCount, LGrid.GridWheelRouteCount,
       LGrid.PaintBoxWheelRouteCount, LGrid.NativeWheelScrollMessageCount,
       LGrid.WheelSynchronizedRedrawCount, NativeInt(LHit),
       LGrid.LastPaintedDataRowCount, LGrid.LastPaintedFirstDataText,
       LGrid.LastPaintedLastDataText, LGrid.LastPaintedSelectedDataText,
       LDataSet.RecNo, LGrid.LastPaintedGridTopRow,
       LGrid.LastPaintedDataLinkActiveRecord,
       LGrid.LastPaintedDataLinkRecordCount]));
  end;
end;

procedure ExerciseDataAwareGridViewportSourceTruth(const AForm: TForm1);
var
  LCompositionBefore: Integer;
  LDataSet: TClientDataSet;
  LGrid: TDACDataGrid;
  LOldHandle: HWND;
  LPaintBox: TDACDataGridPaintBox;
  LWheelRecNo: Integer;
  LRowBefore: Integer;
  LActiveBefore: Integer;
  LCell: TRect;
  LClickBefore: Integer;
  LDblBefore: Integer;
  LCellClickBefore: Integer;
  LEditorBefore: Boolean;
  LFooterScreenPoint: TPoint;
  LHit: HWND;
  LProbe: TInteractionProbe;
  I: Integer;
  procedure RequireFrame(const AContext: string;
    const AExpectedId, AExpectedRecNo: Integer);
  begin
    Require((LDataSet.RecNo = AExpectedRecNo) and
      (LGrid.LastPaintedSelectedDataText = IntToStr(AExpectedId)) and
      (StrToIntDef(LGrid.LastPaintedFirstDataText, -1) <= AExpectedId) and
      (StrToIntDef(LGrid.LastPaintedLastDataText, -1) >= AExpectedId),
      Format('%s: recno=%d frame=%s..%s selected=%s.',
        [AContext, LDataSet.RecNo, LGrid.LastPaintedFirstDataText,
         LGrid.LastPaintedLastDataText,
         LGrid.LastPaintedSelectedDataText]));
  end;
begin
  AForm.SetBounds(AForm.Left, AForm.Top, 1200, 760);
  AForm.GalleryTabs.ActivePage :=
    AForm.FindComponent('tsDataAware') as TTabSheet;
  PumpMessages(120);
  LGrid := AForm.FindComponent('demoDataAwareGrid') as TDACDataGrid;
  LDataSet := AForm.FindComponent('demoGridDataSet') as TClientDataSet;
  Require((LGrid <> nil) and (LDataSet <> nil) and LDataSet.Active,
    'DB030 nao encontrou grid/dataset.');
  LPaintBox := nil;
  for I := 0 to LGrid.ComponentCount - 1 do
    if LGrid.Components[I] is TDACDataGridPaintBox then
      LPaintBox := TDACDataGridPaintBox(LGrid.Components[I]);
  Require(LPaintBox <> nil, 'DB030 nao encontrou paintbox.');

  LDataSet.RecNo := 8;
  PumpMessages(180);
  RequireFrame('DB030 baseline', 1008, 8);
  LProbe := TInteractionProbe.Create;
  TDataGridHandleAccess(LGrid).SetGridEvents(LProbe.OnGridClick,
    LProbe.OnGridDoubleClick, LProbe.OnGridCellClick);
  LCell := TDataGridHandleAccess(LGrid).GridCellRect(0,
    TDataGridHandleAccess(LGrid).GridRow);
  SendMessage(LGrid.Handle, WM_MOUSEMOVE, 0,
    MakeLParam((LCell.Left + LCell.Right) div 2,
      (LCell.Top + LCell.Bottom) div 2));
  SendMessage(LGrid.Handle, WM_LBUTTONDOWN, MK_LBUTTON,
    MakeLParam((LCell.Left + LCell.Right) div 2,
      (LCell.Top + LCell.Bottom) div 2));
  SendMessage(LGrid.Handle, WM_LBUTTONUP, 0,
    MakeLParam((LCell.Left + LCell.Right) div 2,
      (LCell.Top + LCell.Bottom) div 2));
  SendMessage(LGrid.Handle, WM_LBUTTONDBLCLK, MK_LBUTTON,
    MakeLParam((LCell.Left + LCell.Right) div 2,
      (LCell.Top + LCell.Bottom) div 2));
  SendMessage(LGrid.Handle, WM_LBUTTONUP, 0,
    MakeLParam((LCell.Left + LCell.Right) div 2,
      (LCell.Top + LCell.Bottom) div 2));
  Require((LProbe.GridClickCount > 0) and
    (LProbe.GridDoubleClickCount > 0) and
    (LProbe.GridCellClickCount > 0) and (LGrid.HoverCellY >= 0),
    'DB032 eventos legitimos da celula nao foram preservados.');
  LClickBefore := LProbe.GridClickCount;
  LDblBefore := LProbe.GridDoubleClickCount;
  LCellClickBefore := LProbe.GridCellClickCount;
  LEditorBefore := TDataGridHandleAccess(LGrid).GridEditorMode;
  LRowBefore := TDataGridHandleAccess(LGrid).GridRow;
  LActiveBefore := LGrid.LastPaintedDataLinkActiveRecord;
  LFooterScreenPoint := LGrid.ClientToScreen(
    Point(30, LGrid.ClientHeight - 8));
  if SetCursorPos(LFooterScreenPoint.X, LFooterScreenPoint.Y) then
  begin
    PumpMessages(40);
    LHit := WindowFromPoint(LFooterScreenPoint);
  end
  else
  begin
    // Estacoes de janela nao interativas podem negar o cursor global. O
    // contrato funcional do footer continua verificavel pelo HWND real.
    SendMessage(LGrid.Handle, WM_MOUSEMOVE, 0,
      MakeLParam(30, LGrid.ClientHeight - 8));
    PumpMessages(40);
    LHit := LGrid.Handle;
  end;
  Require(((LHit = LGrid.Handle) or IsChild(LGrid.Handle, LHit)) and
    (LGrid.HoverCellX = -1) and (LGrid.HoverCellY = -1) and
    (LDataSet.RecNo = 8) and
    (TDataGridHandleAccess(LGrid).GridRow = LRowBefore) and
    (LGrid.LastPaintedDataLinkActiveRecord = LActiveBefore) and
    (LProbe.GridClickCount = LClickBefore) and
    (LProbe.GridDoubleClickCount = LDblBefore) and
    (LProbe.GridCellClickCount = LCellClickBefore),
    Format('DB031 cursor fisico nao atingiu footer isolado ' +
      '(hit=%d; grid=%d; hover=%d,%d; recno=%d; row=%d/%d; ' +
      'active=%d/%d; events=%d/%d,%d/%d,%d/%d).',
      [NativeInt(LHit), NativeInt(LGrid.Handle),
       LGrid.HoverCellX, LGrid.HoverCellY, LDataSet.RecNo,
       TDataGridHandleAccess(LGrid).GridRow, LRowBefore,
       LGrid.LastPaintedDataLinkActiveRecord, LActiveBefore,
       LProbe.GridClickCount, LClickBefore,
       LProbe.GridDoubleClickCount, LDblBefore,
       LProbe.GridCellClickCount, LCellClickBefore]));
  SendMessage(LGrid.Handle, WM_MOUSEMOVE, 0,
    MakeLParam(30, LGrid.ClientHeight - 8));
  SendMessage(LGrid.Handle, WM_LBUTTONDOWN, MK_LBUTTON,
    MakeLParam(30, LGrid.ClientHeight - 8));
  SendMessage(LGrid.Handle, WM_LBUTTONUP, 0,
    MakeLParam(30, LGrid.ClientHeight - 8));
  SendMessage(LGrid.Handle, WM_LBUTTONDBLCLK, MK_LBUTTON,
    MakeLParam(30, LGrid.ClientHeight - 8));
  SendMessage(LGrid.Handle, WM_LBUTTONUP, 0,
    MakeLParam(30, LGrid.ClientHeight - 8));
  TDataGridPaintBoxAccess(LPaintBox).SimulateClick(30,
    LGrid.ClientHeight - 8);
  Require(TDataGridPaintBoxAccess(LPaintBox).SimulateMouseWheelAt(
    -WHEEL_DELTA, 30, LGrid.ClientHeight - 8),
    'DB031 footer wheel nao foi consumido.');
  PumpMessages(120);
  Require((LDataSet.RecNo = 8) and
    (TDataGridHandleAccess(LGrid).GridRow = LRowBefore) and
    (LGrid.LastPaintedDataLinkActiveRecord = LActiveBefore) and
    (LProbe.GridClickCount = LClickBefore) and
    (LProbe.GridDoubleClickCount = LDblBefore) and
    (LProbe.GridCellClickCount = LCellClickBefore) and
    (TDataGridHandleAccess(LGrid).GridEditorMode = LEditorBefore) and
    (LGrid.HoverCellX = -1) and (LGrid.HoverCellY = -1) and
    (LGrid.FooterClickSuppressedCount > 0) and
    (LGrid.FooterDoubleClickSuppressedCount > 0) and
    (LGrid.FooterMoveSuppressedCount > 0) and
    (LGrid.FooterInputSuppressedCount >= 3),
    Format('DB031 footer encaminhou input ao TDBGrid ' +
      '(recno=%d; row=%d/%d; active=%d/%d; click=%d/%d; ' +
      'dbl=%d/%d; cell=%d/%d; editor=%s/%s; hover=%d,%d; ' +
      'suppressed=%d,%d,%d,%d).',
      [LDataSet.RecNo, TDataGridHandleAccess(LGrid).GridRow, LRowBefore,
       LGrid.LastPaintedDataLinkActiveRecord, LActiveBefore,
       LProbe.GridClickCount, LClickBefore,
       LProbe.GridDoubleClickCount, LDblBefore,
       LProbe.GridCellClickCount, LCellClickBefore,
       BoolToStr(TDataGridHandleAccess(LGrid).GridEditorMode, True),
       BoolToStr(LEditorBefore, True), LGrid.HoverCellX, LGrid.HoverCellY,
       LGrid.FooterClickSuppressedCount,
       LGrid.FooterDoubleClickSuppressedCount,
       LGrid.FooterMoveSuppressedCount,
       LGrid.FooterInputSuppressedCount]));
  if LDataSet.State in dsEditModes then
    LDataSet.Cancel;
  SendKey(LGrid, VK_ESCAPE);
  Require(LGrid.FooterReserveRows > 0,
    'DB031 footer visivel nao reservou linhas.');
  LGrid.ShowFooter := False;
  PumpMessages(120);
  Require(LGrid.FooterReserveRows = 0,
    'DB031 footer oculto reteve phantom rows.');
  LGrid.SetBounds(LGrid.Left, LGrid.Top, LGrid.Width, LGrid.Height - 36);
  LGrid.SetBounds(LGrid.Left, LGrid.Top, LGrid.Width, LGrid.Height + 36);
  LGrid.ShowFooter := True;
  PumpMessages(180);
  Require((LGrid.FooterReserveRows > 0) and (LDataSet.RecNo = 8),
    'DB031 toggle/resize nao recompôs reserva sem navegar.');

  // Five source changes before the UI queue drains must produce one frame
  // from the last real state.
  LCompositionBefore := LGrid.ViewportCompositionCount;
  for I := 9 to 13 do
    LDataSet.RecNo := I;
  PumpMessages(180);
  RequireFrame('DB030 external rapid', 1013, 13);
  Require(LGrid.ViewportCompositionCount = LCompositionBefore + 1,
    'DB030 external rapid nao foi coalescido em uma composicao.');
  PumpMessages(900);
  Require((LGrid.ViewportCompositionCount = LCompositionBefore + 1) and
    (LGrid.LastPaintedSelectedDataText = '1013'),
    'DB030 idle900 recompôs ou perdeu highlight.');

  LDataSet.RecNo := 8;
  PumpMessages(180);
  LCompositionBefore := LGrid.ViewportCompositionCount;
  for I := 1 to 5 do
    Require(TDataGridPaintBoxAccess(LPaintBox).SimulateMouseWheel(-120),
      'DB030 rapid wheel overlay nao foi consumido.');
  PumpMessages(180);
  LWheelRecNo := LDataSet.RecNo;
  RequireFrame('DB030 rapid wheel', 1000 + LWheelRecNo, LWheelRecNo);
  Require(LGrid.ViewportCompositionCount = LCompositionBefore + 1,
    'DB030 rapid wheel nao foi coalescido em uma composicao.');

  // A message queued for the old HWND may never suppress the new handle's
  // final source-of-truth frame.
  LDataSet.RecNo := 8;
  PumpMessages(180);
  LOldHandle := LGrid.Handle;
  LDataSet.RecNo := 9;
  TDataGridHandleAccess(LGrid).RecreateNativeHandle;
  LCompositionBefore := LGrid.ViewportCompositionCount;
  LDataSet.RecNo := 13;
  PumpMessages(220);
  Require((LGrid.Handle <> LOldHandle) and
    (LGrid.ViewportCompositionCount = LCompositionBefore + 1),
    'DB030 destroy/recreate perdeu lifetime ou duplicou composicao.');
  RequireFrame('DB030 recreate final', 1013, 13);
  TDataGridHandleAccess(LGrid).SetGridEvents(nil, nil, nil);
  LProbe.Free;

  WriteLn(Format(
    'MEM-DEL-DB-030 source-truth PASS composition=%d coalesced=%d ' +
    'invalidations=%d first=%s last=%s selected=%s recno=%d top=%d',
    [LGrid.ViewportCompositionCount, LGrid.ViewportCoalescedRequestCount,
     LGrid.ChromeWindowInvalidationCount, LGrid.LastPaintedFirstDataText,
     LGrid.LastPaintedLastDataText, LGrid.LastPaintedSelectedDataText,
     LDataSet.RecNo, LGrid.LastPaintedGridTopRow]));
end;

procedure ExerciseDataAwareGridNativeEditing(const AForm: TForm1);
var
  LCell: TRect;
  LDataSet: TClientDataSet;
  LGrid: TDACDataGrid;
  LOriginalValue: string;
begin
  AForm.SetBounds(AForm.Left, AForm.Top, 1200, 760);
  AForm.GalleryTabs.ActivePage :=
    AForm.FindComponent('tsDataAware') as TTabSheet;
  PumpMessages(100);
  LGrid := AForm.FindComponent('demoDataAwareGrid') as TDACDataGrid;
  LDataSet := AForm.FindComponent('demoGridDataSet') as TClientDataSet;
  Require((LGrid <> nil) and (LDataSet <> nil) and LDataSet.Active,
    'Gate F2 do Data-Aware nao encontrou grid/dataset ativos.');
  Require(not LGrid.ReadOnly and (dgEditing in LGrid.Options) and
    not (dgRowSelect in LGrid.Options),
    'Demo Data-Aware nao persistiu o contrato editavel do TDBGrid.');

  Require(LDataSet.Locate('ID', 1008, []),
    'Gate F2 nao localizou o registro fisico ID 1008.');
  LOriginalValue := LDataSet.FieldByName('CLIENTE').AsString;
  LDataSet.Edit;
  LCell := TDataGridHandleAccess(LGrid).GridCellRect(1,
    TDataGridHandleAccess(LGrid).GridRow);
  Require((LCell.Right > LCell.Left) and (LCell.Bottom > LCell.Top),
    'Gate F2 nao materializou a celula CLIENTE do ID 1008.');
  LGrid.Perform(WM_LBUTTONDOWN, MK_LBUTTON,
    (LCell.Left + 12) or ((LCell.Top + 12) shl 16));
  LGrid.Perform(WM_LBUTTONUP, 0,
    (LCell.Left + 12) or ((LCell.Top + 12) shl 16));
  LGrid.SetFocus;
  SendKey(LGrid, VK_F2);
  PumpMessages(50);
  Require(TDataGridHandleAccess(LGrid).GridEditorMode and
    TDataGridHandleAccess(LGrid).GridEditorVisible and
    TDataGridHandleAccess(LGrid).GridEditorFocused,
    'F2 nao abriu o InplaceEditor nativo visivel, focado e com caret.');

  TDataGridHandleAccess(LGrid).GridEditorChar('X');
  PumpMessages(50);
  Require(LDataSet.State = dsEdit,
    'Entrada nativa no grid abandonou dsEdit antes de UpdateRecord.');
  LDataSet.UpdateRecord;
  Require(LDataSet.Modified and
    (LDataSet.FieldByName('CLIENTE').AsString <> LOriginalValue),
    'InplaceEditor nao materializou Modified/UpdateRecord no CLIENTE.');
  LDataSet.Cancel;
  PumpMessages(50);
  Require((LDataSet.State = dsBrowse) and
    (LDataSet.FieldByName('CLIENTE').AsString = LOriginalValue),
    'Cancel nao restaurou atomicamente o CLIENTE original do ID 1008.');
end;

procedure TestStatusTimelineContract;
var
  LChart: TDACStatusTimelineChart;
  LStart: TDateTime;
begin
  LChart := TDACStatusTimelineChart.Create(nil);
  try
    LStart := EncodeDateTime(2026, 7, 31, 0, 0, 0, 0);
    LChart.WindowStart := LStart;
    LChart.WindowFinish := IncDay(LStart);
    LChart.AddSegment(IncHour(LStart, -1), IncHour(LStart, 6),
      stsOnline);
    LChart.AddSegment(IncHour(LStart, 5), IncHour(LStart, 8),
      stsOffline);
    LChart.AddSegment(IncHour(LStart, 10), IncHour(LStart, 9),
      stsUnstable);
    LChart.AddSegment(IncHour(LStart, 23), IncHour(LStart, 27),
      stsIndeterminate);
    Require(LChart.NormalizedSegmentCount = 3,
      'Timeline nao normalizou recorte, sobreposicao e segmento invalido.');
    Require(not LChart.HandleAllocated,
      'Timeline alocou HWND sem Parent durante o ciclo de design.');
  finally
    LChart.Free;
  end;
end;

procedure RunInteraction;
var
  LBadge: TDACBadge;
  LButton: TDACButton;
  LColumnFirst: TDACButton;
  LColumnSecond: TDACButton;
  LColumnThird: TDACButton;
  LColumnsGrid: TDACGridContainer;
  LCheck: TDACCheckBox;
  LRadio: TDACRadioButton;
  LToggle: TDACToggleSwitch;
  LThemeScroll: TDACScrollContainer;
  LThemeChart: TDACChart;
  LThemeDoughnut: TDACChart;
  LThemeReport: TDACReportViewer;
  LDataSet: TClientDataSet;
  LDataSource: TDataSource;
  LEmptyDataSet: TClientDataSet;
  LEmptyDataSource: TDataSource;
  LReplacementDataSet: TClientDataSet;
  LReplacementSource: TDataSource;
  LDateTime: TDACDateTimePicker;
  LDateTimeTokens: TDACControlTokens;
  LDateTimeRegion: TRect;
  LDateTimeRegionHandle: HRGN;
  LDateTimeRegionResult: Integer;
  LDateTimeRegionBoxResult: Integer;
  LDateTimeExpectedBottomRight: TPoint;
  LDateTimeExpectedTopLeft: TPoint;
  LDateTimeChildHwnd: HWND;
  LDateTimeChildClass: array[0..63] of Char;
  LDateTimePickerClass: array[0..63] of Char;
  LDateTimeNativeScreenRect: TRect;
  LDateTimeOriginalValue: TDateTime;
  LDateTimePickerCount: Integer;
  LDashboardButton: TDACButton;
  LDashboardCard: TDACSummaryCard;
  LDashboardChart: TDACChart;
  LDashboardModule: TDACContainer;
  LDashboardPanel: TDACContainer;
  LDashboardScroll: TDACScrollContainer;
  LDashboardText: TDACSystemText;
  LDashboardDateText: TDACSystemText;
  LDashboardNameText: TDACSystemText;
  LDashboardQuickGrid: TDACGridContainer;
  LDashboardQuickAction: TDACButton;
  LDashboardSubtitleText: TDACSystemText;
  LDashboardTitleText: TDACSystemText;
  LExplicitTextColor: TAlphaColor;
  LExplicitTextSize: Integer;
  LGrid: TDACDataGrid;
  LGridPaintBox: TDACDataGridPaintBox;
  LGridActionCell: TRect;
  LGridActionX: Integer;
  LGridActionY: Integer;
  LGridChromeRevision: Cardinal;
  LGridOriginalClient: string;
  LGridRecNo: Integer;
  LGridTopRow: Integer;
  LGridTokens: TDACControlTokens;
  LGalleryHeader: TDACTabHeaderControl;
  LGalleryHeaderPoint: TPoint;
  LHorizontalTabs: TDACTabs;
  LHorizontalText: TDACSystemText;
  LHorizontalContentPoint: TPoint;
  LHiddenTabProbe: TShowingCountEdit;
  LInputEdit: TDACEdit;
  LInputEditReadOnly: TDACEdit;
  LEditTokens: TDACControlTokens;
  LInputButtonEdit: TDACButtonEdit;
  LInputActionButton: TDACButton;
  LInputActionSurface: TPanel;
  LInputActionTokens: TDACControlTokens;
  LButtonEditTokens: TDACControlTokens;
  LButtonEditActionHandle: HWND;
  LButtonEditActionRect: TRect;
  LButtonEditCurrentActionRect: TRect;
  LButtonEditNativeHandle: HWND;
  LButtonEditNativeParent: HWND;
  LButtonEditCurrentRect: TRect;
  LButtonEditNativeRect: TRect;
  LButtonEditOriginalText: string;
  LButtonEditOriginalButtonCaption: string;
  LButtonEditOriginalShowIcon: Boolean;
  LButtonEditOriginalTheme: TDACThemeMode;
  LButtonEditOriginalVariant: TDACInputVariant;
  LInputCombo: TDACComboBox;
  LComboBeforeDate: TDACComboBox;
  LComboPaintBox: TSkPaintBox;
  LActiveShowingProbe: TShowingCountEdit;
  LDestroyShowingProbe: TEdit;
  LMutationShowingHost: TShowingMutationHost;
  LReparentShowingProbe: TShowingCountEdit;
  LShowingProbe: TEdit;
  LInputEditBounds: TRect;
  LInputMemo: TDACMemo;
  LInputMemoReadOnly: TDACMemo;
  LInputMemoBounds: TRect;
  LInputsScroll: TDACScrollContainer;
  LInputButtonEditBounds: TRect;
  LButtonEditRegion: HRGN;
  LButtonEditRegionResult: Integer;
  LInputLayoutRevision: Cardinal;
  LInputGeometryDark: string;
  LInputGeometryLight: string;
  LInputGeometrySizedDark: string;
  LInputGeometrySizedLight: string;
  LInputTabsOriginalBounds: TRect;
  LInterTextWidth: Integer;
  LButtonLabelPoint: TPoint;
  LClipboardText: string;
  LMemoTextPoint: TPoint;
  LPageContentPoint: TPoint;
  LModal: TDACModalDialog;
  LNavigationButton: TDACButton;
  LNavigation: TDACScrollContainer;
  LPagination: TDACPagination;
  LSlider: TDACSlider;
  LLoading: TDACLoading;
  LProgress: TDACProgress;
  LScroll: TDACScrollContainer;
  LScrollRange: Integer;
  LTabPage: TTabSheet;
  LTabs: TDACTabs;
  LTabHeader: TDACTabHeaderControl;
  LTabHeaderPaintBox: TSkPaintBox;
  LTabHeaderPoint: TPoint;
  LTabFocusRect: TRectF;
  LTabLayout: TDACTabLayout;
  LTabOriginalCaption: string;
  LTabSelectionRect: TRectF;
  LTabSecondaryRect: TRectF;
  LTabTertiaryRect: TRectF;
  LTitlePoint: TPoint;
  LVerticalContentPoint: TPoint;
  LVerticalText: TDACSystemText;
  LVisibleTabProbe: TShowingCountEdit;
  LToast: TDACToast;
  LTooltip: TDACTooltip;
  LWheelPosition: Integer;
  LWidthBefore: Integer;
  LLegacyTextWidth: Integer;
  LProbe: TInteractionProbe;
  LStyleMetrics: TDACComponentMetrics;
  LStyleTokens: TDACDesignTokens;
  LThemeBeforeOverrideCheck: TDACThemeMode;
  LThemeToggle: TDACButton;
  LThemeToggleHandle: HWND;
  LThemeToggleRect: TRect;
  LStreamedSystemText: TDACSystemText;
  LSemanticSystemText: TDACSystemText;
  LSemanticButton: TDACButton;
  LStreamedButton: TDACButton;
  LSemanticGrid: TDACGridContainer;
  LStreamedGrid: TDACGridContainer;
  LSemanticScroll: TDACScrollContainer;
  LStreamedScroll: TDACScrollContainer;
  LSemanticContainer: TDACContainer;
  LStreamedContainer: TDACContainer;
  LSemanticSummary: TDACSummaryCard;
  LStreamedSummary: TDACSummaryCard;
  LSemanticChart: TDACChart;
  LStreamedChart: TDACChart;
  LSystemTextBinary: TMemoryStream;
  LSystemTextDfm: TStringStream;
  LStatusBar: TDACStatusBar;
  LThemeContainer: TDACContainer;
  LThemeGrid: TDACGridContainer;
  LThemeSummary: TDACSummaryCard;
  LThemeSkia: TThemeSkiaControl;
  LThemeText: TDACSystemText;
  LInfoColors: TDACSemanticColorSet;
  LNeutralColors: TDACSemanticColorSet;
  LButtonClickBefore: Integer;
  I: Integer;
  LExpectedRecNo: Integer;

  procedure ExerciseThemeToggleCycles(const AWidth, AHeight: Integer;
    const APrimaryPage, ASecondaryPage: TTabSheet;
    const AExercisePopup: Boolean; const AContext: string);
  var
    J: Integer;
    LCaption: string;
    LMode: TDACThemeMode;
    LPoint: TPoint;
  begin
    Form1.SetBounds(Form1.Left, Form1.Top, AWidth, AHeight);
    Form1.GalleryTabs.ActivePage := APrimaryPage;
    PumpMessages(100);
    LThemeToggle := Form1.FindComponent('demoThemeToggle') as TDACButton;
    Require((LThemeToggle <> nil) and LThemeToggle.HandleAllocated and
      GetWindowRect(LThemeToggle.Handle, LThemeToggleRect),
      AContext + ': toggle nao foi materializado no layout.');
    LThemeToggleHandle := LThemeToggle.Handle;
    for J := 0 to 9 do
    begin
      if J = 1 then
      begin
        LThemeToggle.SetFocus;
        PumpMessages(20);
      end
      else if J = 2 then
      begin
        Form1.GalleryTabs.ActivePage := ASecondaryPage;
        PumpMessages(60);
      end
      else if J = 3 then
      begin
        Form1.GalleryTabs.ActivePage := APrimaryPage;
        PumpMessages(60);
      end
      else if AExercisePopup and (J = 4) then
      begin
        LInputCombo.SetFocus;
        LInputCombo.OpenDropDown;
        PumpMessages(40);
        Require(LInputCombo.PopupVisible,
          AContext + ': popup de preparacao nao abriu.');
      end;

      if TDACThemeManager.ApplicationMode = dtmDark then
        LMode := dtmLight
      else
        LMode := dtmDark;
      if Odd(J) then
      begin
        LPoint := Point(LThemeToggle.ClientWidth div 2,
          LThemeToggle.ClientHeight div 2);
        SendMessage(LThemeToggle.Handle, WM_LBUTTONDOWN, MK_LBUTTON,
          MakeLong(LPoint.X, LPoint.Y));
        SendMessage(LThemeToggle.Handle, WM_LBUTTONUP, 0,
          MakeLong(LPoint.X, LPoint.Y));
      end
      else
        TDACThemeManager.SetApplicationMode(LMode);
      PumpMessages(100);
      Require(TDACThemeManager.ApplicationMode = LMode,
        AContext + ': ciclo de tema nao aplicou o modo esperado.');
      if LMode = dtmLight then
        LCaption := 'Tema escuro'
      else
        LCaption := 'Tema claro';
      if AWidth <= TDACDemoTokens.Default.NavigationCompactBreakpoint then
        LCaption := '';
      RequireThemeToggleHitTarget(Form1, LThemeToggleHandle,
        LThemeToggleRect, LCaption,
        Format('%s ciclo %d', [AContext, J + 1]));
      if AExercisePopup and (J = 4) then
      begin
        LInputCombo.SimulateDropDownExternalDeactivate;
        PumpMessages(20);
      end;
    end;
  end;

  procedure RequireFieldLabelParity(const ATheme: TDACThemeMode;
    const AContext: string);
  var
    LTokens: TDACControlTokens;
    LExpectedColor: TColor;
  begin
    LInputEdit.ThemeMode := ATheme;
    LInputButtonEdit.ThemeMode := ATheme;
    LInputMemo.ThemeMode := ATheme;
    LInputCombo.ThemeMode := ATheme;
    LDateTime.ThemeMode := ATheme;
    PumpMessages(30);
    LTokens := TDACComponentStyle.Resolve(ATheme).Tokens.Controls;
    LExpectedColor := TDACComponentColors.ToVclColor(LTokens.FieldLabelText);
    Require(
      SameText(LInputEdit.NativeLabel.Font.Name, 'Inter') and
      SameText(LInputButtonEdit.NativeLabel.Font.Name, 'Inter') and
      SameText(LInputMemo.NativeLabel.Font.Name, 'Inter') and
      SameText(LInputCombo.NativeLabel.Font.Name, 'Inter') and
      SameText(LDateTime.NativeLabel.Font.Name, 'Inter') and
      (LInputEdit.NativeLabel.Font.Size = Round(LTokens.FieldLabelTextSize)) and
      (LInputButtonEdit.NativeLabel.Font.Size = Round(LTokens.FieldLabelTextSize)) and
      (LInputMemo.NativeLabel.Font.Size = Round(LTokens.FieldLabelTextSize)) and
      (LInputCombo.NativeLabel.Font.Size = Round(LTokens.FieldLabelTextSize)) and
      (LDateTime.NativeLabel.Font.Size = Round(LTokens.FieldLabelTextSize)) and
      (LInputEdit.NativeLabel.Font.Color = LExpectedColor) and
      (LInputButtonEdit.NativeLabel.Font.Color = LExpectedColor) and
      (LInputMemo.NativeLabel.Font.Color = LExpectedColor) and
      (LInputCombo.NativeLabel.Font.Color = LExpectedColor) and
      (LDateTime.NativeLabel.Font.Color = LExpectedColor) and
      (LInputEdit.NativeLabel.Height = Round(LTokens.FieldLabelRowHeight)) and
      (LInputMemo.NativeLabel.Height = Round(LTokens.FieldLabelRowHeight)),
      'Paridade de label nativo falhou em ' + AContext + '.');
  end;

  procedure RequireGalleryThemeMatrix(const AMode: TDACThemeMode;
    const AActivateHiddenPages: Boolean; const AContext: string);
  var
    I: Integer;
    LExpectedPageColor: TColor;
    LExpectedTextColor: TColor;
    LPage: TTabSheet;
    LSavedPage: TTabSheet;
    LTokens: TDACControlTokens;
    procedure CheckTree(const AControl: TControl; const APath: string);
    var
      J: Integer;
      LResolved: TAlphaColor;
    begin
      if AControl.ClassType = TLabel then
        Require((not TLabel(AControl).ParentFont) and
          TLabel(AControl).Transparent and
          (TLabel(AControl).Font.Color = LExpectedTextColor),
          AContext + ': label nativo nao herdou fonte/cor em ' + APath + '.')
      else if AControl is TDACScrollContainer then
        Require(TScrollContainerColorAccess(AControl).Color =
          TDACComponentColors.ToVclColor(
            TDACScrollContainer(AControl).ResolvedBackgroundColor),
          AContext + ': ScrollContainer nao publicou a surface em ' +
            APath + '.')
      else if AControl is TDACGridContainer then
      begin
        LResolved := TDACGridContainer(AControl).ResolvedBackgroundColor;
        if LResolved <>
          LTokens.TransparentSurfaceFallback then
          Require(TGridContainerColorAccess(AControl).Color =
            TDACComponentColors.ToVclColor(LResolved),
            AContext + ': GridContainer nao publicou a surface em ' +
              APath + '.');
      end
      else if AControl is TDACContainer then
      begin
        LResolved := TDACContainer(AControl).ResolvedBackgroundColor;
        if LResolved <>
          LTokens.TransparentSurfaceFallback then
          Require(TContainerColorAccess(AControl).Color =
            TDACComponentColors.ToVclColor(LResolved),
            AContext + ': Container nao publicou a surface em ' +
              APath + '.');
      end;
      if AControl is TWinControl then
        for J := 0 to TWinControl(AControl).ControlCount - 1 do
          CheckTree(TWinControl(AControl).Controls[J],
            APath + '/' + TWinControl(AControl).Controls[J].Name);
    end;
  begin
    LSavedPage := Form1.GalleryTabs.ActivePage;
    TDACThemeManager.SetApplicationMode(AMode);
    PumpMessages(120);
    LTokens := TDACComponentStyle.Resolve(AMode).Tokens.Controls;
    LExpectedPageColor := TDACComponentColors.ToVclColor(
      LTokens.ContainerSuiteBackground);
    LExpectedTextColor := TDACComponentColors.ToVclColor(
      LTokens.ContainerTitle);
    Require((TTabsColorAccess(Form1.GalleryTabs).Color =
        LExpectedPageColor) and
      (Form1.GalleryTabs.Font.Color = LExpectedTextColor),
      AContext + ': PageControl nao recebeu surface/fonte resolvida.');
    for I := 0 to Form1.GalleryTabs.PageCount - 1 do
    begin
      LPage := Form1.GalleryTabs.Pages[I];
      Require((not TTabSheetAccess(LPage).ParentColor) and
        (not TTabSheetAccess(LPage).ParentBackground) and
        (TTabSheetAccess(LPage).StyleElements = []) and
        (TTabSheetAccess(LPage).Color = LExpectedPageColor) and
        (not LPage.ParentFont) and
        SameText(LPage.Font.Name, TDACComponentStyle.FontFamily) and
        (LPage.Font.Size = TDACComponentStyle.TextSize) and
        (LPage.Font.Color = LExpectedTextColor),
        Format('%s: TabSheet %d/%s nao recebeu palette completa.',
          [AContext, I, LPage.Name]));
      CheckTree(LPage, LPage.Name);
    end;
    if AActivateHiddenPages then
      for I := 0 to Form1.GalleryTabs.PageCount - 1 do
      begin
        Form1.GalleryTabs.ActivePage := Form1.GalleryTabs.Pages[I];
        PumpMessages(25);
        Require((TTabSheetAccess(Form1.GalleryTabs.ActivePage).Color =
            LExpectedPageColor) and
          (Form1.GalleryTabs.ActivePage.Font.Color = LExpectedTextColor),
          Format('%s: pagina %d perdeu o tema ao ser ativada.',
            [AContext, I]));
      end;
    Form1.GalleryTabs.ActivePage := LSavedPage;
    PumpMessages(30);
  end;

  procedure RequireGalleryNavigationCoherence;
  var
    J: Integer;
    LActiveButton: TDACButton;
    LButton: TDACButton;
    LHeader: TDACTabHeaderControl;
    LPaintBox: TSkPaintBox;
    LPage: TTabSheet;
    LRect: TRectF;
    LSavedIndex: Integer;
    procedure RequireState(const AExpectedIndex: Integer;
      const APath: string);
    var
      K: Integer;
    begin
      Require((Form1.GalleryTabs.ActiveIndex = AExpectedIndex) and
        (Form1.GalleryTabs.ActivePage =
          Form1.GalleryTabs.Pages[AExpectedIndex]),
        Format('%s nao sincronizou conteudo/indice em %d.',
          [APath, AExpectedIndex]));
      LActiveButton := nil;
      for K := 0 to Form1.GalleryTabs.PageCount - 1 do
      begin
        LPage := Form1.GalleryTabs.Pages[K];
        LButton := Form1.FindComponent(
          'demoNav' + Copy(LPage.Name, 3, MaxInt)) as TDACButton;
        Require(LButton <> nil,
          Format('%s nao encontrou o item lateral da pagina %d/%s.',
            [APath, K, LPage.Name]));
        if K = AExpectedIndex then
        begin
          Require(LButton.Kind = mbkPrimary,
            Format('%s deixou o item lateral %d sem estado ativo.',
              [APath, K]));
          LActiveButton := LButton;
        end
        else
          Require(LButton.Kind = mbkGhost,
            Format('%s deixou dois itens laterais ativos (%d e %d).',
              [APath, AExpectedIndex, K]));
      end;
      Require(LActiveButton <> nil,
        Format('%s nao materializou item lateral ativo.', [APath]));
      Require(LHeader.ResolvedTextColorForPage(AExpectedIndex, False) =
        Form1.GalleryTabs.ResolvedTokens.TabsTextActive,
        Format('%s nao refletiu o mesmo indice no header Skia.', [APath]));
    end;
  begin
    Require(Form1.GalleryTabs.PageCount = 17,
      'Gate de navegacao requer exatamente as 17 paginas da galeria.');
    LHeader := FindTabHeader(Form1.GalleryTabs);
    LPaintBox := FindTabHeaderPaintBox(LHeader);
    Require((LHeader <> nil) and (LPaintBox <> nil) and
      LHeader.Showing and LPaintBox.Visible,
      'Header Skia principal indisponivel para o gate de navegacao.');
    LSavedIndex := Form1.GalleryTabs.ActiveIndex;
    try
      for J := 0 to Form1.GalleryTabs.PageCount - 1 do
      begin
        if Form1.GalleryTabs.ActivePageHeaderOnly then
        begin
          Form1.GalleryTabs.ActiveIndex := J;
          PumpMessages(10);
        end;
        LRect := LHeader.TabRectForPage(J);
        Require(not LRect.IsEmpty,
          Format('Header nao expos hit target para a pagina %d.', [J]));
        LPaintBox.Perform(WM_LBUTTONDOWN, MK_LBUTTON,
          MakeLong(Round((LRect.Left + LRect.Right) / 2),
            Round((LRect.Top + LRect.Bottom) / 2)));
        LPaintBox.Perform(WM_LBUTTONUP, 0,
          MakeLong(Round((LRect.Left + LRect.Right) / 2),
            Round((LRect.Top + LRect.Bottom) / 2)));
        PumpMessages(10);
        RequireState(J, 'Header');
      end;

      for J := 0 to Form1.GalleryTabs.PageCount - 1 do
      begin
        LPage := Form1.GalleryTabs.Pages[J];
        LButton := Form1.FindComponent(
          'demoNav' + Copy(LPage.Name, 3, MaxInt)) as TDACButton;
        Require(Assigned(LButton.OnClick),
          Format('Item lateral %d nao possui acao.', [J]));
        LButton.OnClick(LButton);
        PumpMessages(10);
        RequireState(J, 'Sidebar');
      end;

      Form1.GalleryTabs.ActiveIndex := 0;
      RequireState(0, 'Teclado/inicio');
      for J := 1 to Form1.GalleryTabs.PageCount - 1 do
      begin
        TDACTabsAccess(Form1.GalleryTabs).SimulateKeyDown(VK_RIGHT, []);
        PumpMessages(10);
        RequireState(J, 'Teclado');
      end;
      TDACTabsAccess(Form1.GalleryTabs).SimulateCtrlTab;
      PumpMessages(10);
      RequireState(0, 'Teclado/wrap');
    finally
      Form1.GalleryTabs.ActiveIndex := LSavedIndex;
      PumpMessages(20);
    end;
  end;
begin
  LProbe := TInteractionProbe.Create;
  try
  RequireFieldStateAndStreaming;
  RequireLoadingFocusPolicy;
  RequireComboValueSemantics;
  RequireDatePopupOwnership;
  RequireSvgIcon(mikSave);
  RequireSvgIcon(mikSearch);
  RequireSvgIcon(mikTrash);
  RequireSvgIcon(mikCheck);
  RequireSvgIcon(mikChevronLeft);
  RequireSvgIcon(mikChevronRight);
  RequireSvgIcon(mikChevronDown);
  RequireSvgIcon(mikSpinner);

  LStyleTokens := TDACComponentStyle.Tokens;
  LStyleMetrics := TDACComponentStyle.Metrics;
  LInfoColors := TDACComponentStyle.Semantic(mssInfo);
  LNeutralColors := TDACComponentStyle.Semantic(mssNeutral);
  Require(SameText(TDACComponentStyle.FontFamily, LStyleTokens.Typography.FontFamily) and
    (TDACComponentStyle.TextSize = Round(LStyleTokens.Typography.TextSize)) and
    (TDACComponentStyle.SmallTextSize = Round(LStyleTokens.Typography.SmallTextSize)) and
    (TDACComponentStyle.TabTextSize = Round(LStyleTokens.Typography.TabTextSize)) and
    (TDACComponentStyle.GridTextSize = Round(LStyleTokens.Typography.GridTextSize)),
    'Controles devem consumir a tipografia central do tema DAC.');
  Require((LStyleTokens.Colors.Primary = TDACComponentColors.Primary) and
    (LStyleTokens.Colors.Danger = TDACComponentColors.Danger) and
    (LStyleTokens.Colors.GridHeader = TDACComponentStyle.GridHeaderColor) and
    (LInfoColors.Accent = LStyleTokens.Colors.Info) and
    (LInfoColors.AccentDark = LStyleTokens.Colors.InfoDark) and
    (LNeutralColors.Accent = LStyleTokens.Colors.Neutral) and
    (LNeutralColors.AccentDark = LStyleTokens.Colors.NeutralDark) and
    (TDACComponentStyle.ChartPalette.ColorByIndex(0) = TDACComponentColors.PrimaryLight) and
    (LStyleMetrics.BorderWidth = 1) and (LStyleMetrics.FocusStrokeWidth = 2),
    'Tokens semanticos, paleta de charts ou metricas fixas divergiram do tema central.');
  Require(TDACComponentColors.ContrastRatio(
    TDACComponentStyle.ButtonLoadingText,
    TDACComponentStyle.ButtonLoadingBackground) >= 4.5,
    'O token de loading do botao precisa manter contraste de texto AA.');
  Require(TDACComponentColors.ContrastRatio(
    TDACComponentStyle.ButtonDisabledText,
    TDACComponentStyle.ButtonDisabledBackground) >= 4.5,
    'O token de desabilitado do botao precisa manter contraste de texto AA.');
  RequireFixedPixelMetrics;
  RequireFullGalleryThemeBoundarySources;
  RequireControlTokenContractPresence;
  RequireDefaultGeometryTokens;
  RequireLoteCSemanticDfm;
  RequireDesignTimePresetConstruction;
  Require((TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.ButtonMedium.Height = 40) and
    (TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.ButtonLarge.Height = 48) and
    (TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.InputMedium.PaddingHorizontal = 16) and
    (TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.FocusRingWidth = 2) and
    (TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.InputBackground = TAlphaColor($FF0F1813)) and
    (TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.InputBackground = TAlphaColor($FFFFFFFF)),
    'Contrato dark/light de tokens de componentes divergente da prancha MEM-DEL-071.');
  Require((TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.
      ButtonInputActionCanvasBackground =
      TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.InputBackground) and
    (TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.
      ButtonInputActionCanvasBackground =
      TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.InputBackground) and
    ((TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.
      ButtonInputActionCanvasBackground and TAlphaColor($FF000000)) =
      TAlphaColor($FF000000)) and
    ((TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.
      ButtonInputActionCanvasBackground and TAlphaColor($FF000000)) =
      TAlphaColor($FF000000)),
    'Canvas do mbkInputAction deve usar InputBackground opaco da paleta dark/light.');
  Require((TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.StatusBackground =
      TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.PopupBackground) and
    (TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.StatusBackground =
      TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.PopupBackground) and
    (TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.ProgressTrack <>
      TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.ProgressTrack) and
    (TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.LoadingSkeletonBase <>
      TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.LoadingSkeletonBase),
    'Primitivos de feedback devem possuir superfices dark/light no ControlTokens.');
  RequireCentralizedSemanticSources;
  RequireDataGridPreviewTokenization;
  RequireDataGridCornerRadiusContract;
  RequireAllFamilySurfaceConsumers;
  RequireAssetContractEnforcement;
  RequireMemoThemeTokenization;
  RequireSystemTextInterOnly;
  RequireSkiaControlThemeResolution;
  RequireDoughnutThemePaletteResolution;
  RequireEditThemeTokenization;
  RequireComboBoxThemeTokenization;
  RequireButtonThemeTokenization;
  RequireDateTimePopupTokenization;
  RequireDesignSafeSkiaRedraws;
  RequireRuntimeDfmClasses;

  try
    Application.CreateForm(TForm1, Form1);
  except
    on E: Exception do
      raise Exception.Create('Streaming DFM da Demo falhou: ' +
        E.ClassName + ': ' + E.Message);
  end;
  Form1.Show;
  PumpMessages(150);
  RequireScrollStyleHookRuntime(Form1);
  RequireDataGridScrollStyleHookRuntime(Form1);
  RequireDataGridNonClientFunctionalRegression(Form1);
  RequireNestedScrollHookAuthority(Form1);
  RequireNativeFallbackGeometry(Form1);
  RequireRealStyleHookPaintSource(Form1);
  RequireDataGridHorizontalChromeClipping(Form1);
  RequireGalleryThemeMatrix(dtmDark, False,
    'gallery dark com 15 paginas ainda ocultas');
  RequireGalleryThemeMatrix(dtmLight, False,
    'gallery light com 15 paginas ainda ocultas');
  RequireGalleryThemeMatrix(dtmDark, True,
    'gallery dark apos ativar as 16 paginas');
  RequireGalleryThemeMatrix(dtmLight, True,
    'gallery light apos ativar as 16 paginas');
  RequireGalleryThemeMatrix(dtmDark, False,
    'gallery retorno final ao dark');
  RequireAdversarialSurfaceRTTI(Form1);
  RequireGridContainerMinimumTokens(Form1);
  RequireSurfaceFamilyMatrix(Form1);
  LInputActionSurface := TPanel.Create(Form1);
  LInputActionButton := TDACButton.Create(Form1);
  try
    LInputActionSurface.Parent := Form1;
    LInputActionSurface.ParentColor := False;
    LInputActionSurface.ParentBackground := False;
    LInputActionSurface.Visible := False;
    LInputActionSurface.SetBounds(0, 0, 80, 40);
    LInputActionButton.Parent := LInputActionSurface;
    LInputActionButton.Kind := mbkInputAction;
    LInputActionButton.ThemeMode := dtmInherit;
    LInputActionSurface.Color := TDACComponentColors.ToVclColor(
      TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.InputBackground);
    LInputActionTokens := TDACComponentStyle.ResolveForSurface(
      LInputActionButton, dtmInherit).Tokens.Controls;
    Require((LInputActionTokens.ButtonInputActionCanvasBackground =
        LInputActionTokens.InputBackground) and
      ((LInputActionTokens.ButtonInputActionCanvasBackground and
        TAlphaColor($FF000000)) = TAlphaColor($FF000000)) and
      (LInputActionTokens.InputBackground =
        TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.InputBackground),
      'mbkInputAction inherit nao resolveu InputBackground opaco da surface dark.');
    LInputActionSurface.Color := TDACComponentColors.ToVclColor(
      TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.InputBackground);
    LInputActionTokens := TDACComponentStyle.ResolveForSurface(
      LInputActionButton, dtmInherit).Tokens.Controls;
    Require((LInputActionTokens.ButtonInputActionCanvasBackground =
        LInputActionTokens.InputBackground) and
      ((LInputActionTokens.ButtonInputActionCanvasBackground and
        TAlphaColor($FF000000)) = TAlphaColor($FF000000)) and
      (LInputActionTokens.InputBackground =
        TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.InputBackground),
      'mbkInputAction inherit nao resolveu InputBackground opaco da surface light.');
  finally
    LInputActionButton.Free;
    LInputActionSurface.Free;
  end;
  Require(UnexpectedException = '',
    'Excecao VCL durante a criacao da Demo: ' + UnexpectedException);
  RequireFormWithinMonitorWorkArea(Form1);
  RequireSemiTransparentRaster;

  RequireComponent(Form1, 'GalleryTabs', TDACTabs);
  Require(Form1.GalleryTabs.PageCount = 17,
    'A Demo deve manter as 15 familias, Dashboard e Data-Aware.');
  RequireComponent(Form1, 'demoEdit', TControl);
  RequireComponent(Form1, 'demoCombo', TControl);
  RequireComponent(Form1, 'demoButtonEdit', TDACButtonEdit);
  RequireComponent(Form1, 'demoButtonEditFilled', TDACButtonEdit);
  RequireComponent(Form1, 'demoButtonEditError', TDACButtonEdit);
  RequireComponent(Form1, 'demoButtonEditSuccess', TDACButtonEdit);
  RequireComponent(Form1, 'demoButtonEditDisabled', TDACButtonEdit);
  RequireComponent(Form1, 'demoButtonEditReadOnly', TDACButtonEdit);
  RequireComponent(Form1, 'demoButtonEditLoading', TDACButtonEdit);
  Require(
    ((Form1.FindComponent('demoButtonEditFilled') as TDACButtonEdit).Text <> '') and
    ((Form1.FindComponent('demoButtonEditError') as TDACButtonEdit).Status = mesDanger) and
    ((Form1.FindComponent('demoButtonEditError') as TDACButtonEdit).ErrorText <> '') and
    ((Form1.FindComponent('demoButtonEditSuccess') as TDACButtonEdit).Status = mesSuccess) and
    ((Form1.FindComponent('demoButtonEditSuccess') as TDACButtonEdit).HelperText <> '') and
    not (Form1.FindComponent('demoButtonEditDisabled') as TDACButtonEdit).Enabled and
    (Form1.FindComponent('demoButtonEditReadOnly') as TDACButtonEdit).ReadOnly and
    (Form1.FindComponent('demoButtonEditLoading') as TDACButtonEdit).Loading,
    'Matriz ButtonEdit da Demo perdeu seus sete estados declarativos.');
  RequireComponent(Form1, 'demoDateTime', TDACDateTimePicker);
  RequireComponent(Form1, 'demoDateTimeFilled', TDACDateTimePicker);
  Require(
    (Form1.FindComponent('demoDateTimeFilled') as TDACDateTimePicker).DateTime <>
      (Form1.FindComponent('demoDateTime') as TDACDateTimePicker).DateTime,
    'Date / Filled da Demo deve ser distinto de Date / Default.');
  RequireComponent(Form1, 'demoCheck', TDACCheckBox);
  RequireComponent(Form1, 'demoSlider', TDACSlider);
  RequireComponent(Form1, 'demoSummaryCard', TDACSummaryCard);
  RequireComponent(Form1, 'demoDataGrid', TDACDataGrid);
  RequireComponent(Form1, 'tsDataAware', TTabSheet);
  RequireComponent(Form1, 'lblDataAware', TDACSystemText);
  RequireComponent(Form1, 'demoDBEdit', TDACDBEdit);
  RequireComponent(Form1, 'demoDBMemo', TDACDBMemo);
  RequireComponent(Form1, 'demoDBButtonEdit', TDACDBButtonEdit);
  RequireComponent(Form1, 'demoDBComboBox', TDACDBComboBox);
  RequireComponent(Form1, 'demoDBDate', TDACDBDateTimePicker);
  RequireComponent(Form1, 'demoDBCheck', TDACDBCheckBox);
  RequireComponent(Form1, 'demoDBRadio', TDACDBRadioButton);
  RequireComponent(Form1, 'demoDBToggle', TDACDBToggleSwitch);
  RequireComponent(Form1, 'demoDBSlider', TDACDBSlider);
  RequireComponent(Form1, 'demoDBText', TDACDBText);
  RequireComponent(Form1, 'demoDBLookup', TDACDBLookupComboBox);
  RequireComponent(Form1, 'demoDBNavigator', TDACDBNavigator);
  RequireComponent(Form1, 'demoDataAwareGrid', TDACDataGrid);
  RequireComponent(Form1, 'demoGridDataSet', TClientDataSet);
  RequireComponent(Form1, 'demoGridDataSource', TDataSource);
  RequireComponent(Form1, 'demoLookupDataSet', TClientDataSet);
  RequireComponent(Form1, 'demoLookupDataSource', TDataSource);
  RequireComponent(Form1, 'gcDataAwareContent', TDACGridContainer);
  ExerciseDataAwareLayoutMatrix(Form1);
  RequireDataAwareThemeSurfaces(Form1);
  ExerciseDataAwareGridVerticalSynchronization(Form1);
  ExerciseDataAwareGridPhysicalWheelSynchronization(Form1);
  ExerciseDataAwareGridViewportSourceTruth(Form1);
  ExerciseDataAwareGridHorizontalSelection(Form1);
  ExerciseDataAwareGridNativeEditing(Form1);
  RequireComponent(Form1, 'demoStatusBar', TDACStatusBar);
  RequireComponent(Form1, 'demoProgress', TDACProgress);
  RequireComponent(Form1, 'demoBadge', TDACBadge);
  RequireComponent(Form1, 'demoToast', TDACToast);
  RequireComponent(Form1, 'demoTooltip', TDACTooltip);
  RequireComponent(Form1, 'demoPagination', TDACPagination);
  RequireComponent(Form1, 'demoLoading', TDACLoading);
  RequireComponent(Form1, 'demoBarChart', TDACChart);
  RequireComponent(Form1, 'demoLineChart', TDACChart);
  RequireComponent(Form1, 'demoAreaChart', TDACChart);
  RequireComponent(Form1, 'demoModal', TDACModalDialog);
  RequireComponent(Form1, 'demoReportViewer', TDACReportViewer);
  RequireComponent(Form1, 'demoNavigation', TDACScrollContainer);
  RequireComponent(Form1, 'demoNavigationTitle', TDACSystemText);
  RequireComponent(Form1, 'demoTabs', TDACTabs);
  RequireComponent(Form1, 'demoVerticalTabs', TDACTabs);
  RequireComponent(Form1, 'tsDashboard', TTabSheet);
  RequireComponent(Form1, 'scrDashboard', TDACScrollContainer);
  RequireComponent(Form1, 'dashKpi1', TDACSummaryCard);
  RequireComponent(Form1, 'dashAgendaTodayChip', TDACBadge);
  RequireComponent(Form1, 'dashActivityIcon1', TDACButton);
  RequireComponent(Form1, 'dashProductivitySelect', TDACButton);
  RequireComponent(Form1, 'dashQuickActionsGrid', TDACGridContainer);
  RequireComponent(Form1, 'dashProductivityChart', TDACChart);
  RequireComponent(Form1, 'demoNavDashboard', TDACButton);
  RequireComponent(Form1, 'demoNavButtons', TDACButton);
  RequireComponent(Form1, 'demoNavCharts', TDACButton);
  RequireComponent(Form1, 'lblButtonsTitle', TDACSystemText);
  RequireComponent(Form1, 'lblButtonsSubtitle', TDACSystemText);
  RequireComponent(Form1, 'lblButtonKinds', TDACSystemText);
  RequireComponent(Form1, 'lblButtonSizes', TDACSystemText);
  RequireComponent(Form1, 'lblButtonIcons', TDACSystemText);
  RequireComponent(Form1, 'lblButtonStates', TDACSystemText);
  RequireComponent(Form1, 'lblButtonSpecials', TDACSystemText);
  Require((Form1.lblButtonsTitle.Parent = Form1.scrButtons) and
    (Form1.lblButtonsSubtitle.Parent = Form1.scrButtons) and
    (Form1.gcButtonKinds.Parent = Form1.scrButtons) and
    (Form1.gcButtonKinds.TabOrder = 0) and
    (Form1.gcButtonSpecials.TabOrder = 4),
    'Arvore, nomes ou TabOrder da pagina Buttons divergiram na migracao.');

  LInputEdit := Form1.FindComponent('demoEdit') as TDACEdit;
  LInputEditReadOnly := Form1.FindComponent('demoEditReadOnly') as TDACEdit;
  LInputButtonEdit := Form1.FindComponent('demoButtonEdit') as TDACButtonEdit;
  LInputCombo := Form1.FindComponent('demoCombo') as TDACComboBox;
  LComboBeforeDate := Form1.FindComponent('demoComboReadOnly') as TDACComboBox;
  LInputMemo := Form1.FindComponent('demoMemo') as TDACMemo;
  LInputMemoReadOnly := Form1.FindComponent('demoMemoReadOnly') as TDACMemo;
  LInputsScroll := Form1.FindComponent('scrInputs') as TDACScrollContainer;
  LDateTime := Form1.FindComponent('demoDateTime') as TDACDateTimePicker;
  Form1.GalleryTabs.ActivePage := Form1.tsInputs;
  PumpMessages(100);
  LInputTabsOriginalBounds := Form1.GalleryTabs.BoundsRect;
  Form1.GalleryTabs.SetBounds(Form1.GalleryTabs.Left,
    Form1.GalleryTabs.Top, 1824, 1197);
  PumpMessages(100);
  Require((Form1.GalleryTabs.Width = 1824) and
    (Form1.GalleryTabs.Height = 1197),
    Format('Viewport solicitado 1824x1197 nao foi aplicado (actual=%dx%d).',
      [Form1.GalleryTabs.Width, Form1.GalleryTabs.Height]));
  TDACThemeManager.SetApplicationMode(dtmLight);
  PumpMessages(60);
  RequireInputGalleryGeometry(Form1, '1824x1197 light', False);
  Require(((Form1.FindComponent('demoEdit') as TControl).Top =
      (Form1.FindComponent('demoEditLoading') as TControl).Top) and
    ((Form1.FindComponent('demoMemo') as TControl).Top =
      (Form1.FindComponent('demoMemoLoading') as TControl).Top) and
    ((Form1.FindComponent('demoButtonEdit') as TControl).Top =
      (Form1.FindComponent('demoButtonEditLoading') as TControl).Top),
    'Viewport 1824 nao preservou as sete colunas de cada familia de Inputs.');
  LInputGeometryLight := InputGalleryGeometrySignature(Form1);
  TDACThemeManager.SetApplicationMode(dtmDark);
  PumpMessages(60);
  RequireInputGalleryGeometry(Form1, '1824x1197 dark', False);
  LInputGeometryDark := InputGalleryGeometrySignature(Form1);
  Require(LInputGeometryLight = LInputGeometryDark,
    'Light/Dark alterou a geometria declarativa em 1824x1197.');

  Form1.GalleryTabs.SetBounds(Form1.GalleryTabs.Left,
    Form1.GalleryTabs.Top, 1200, 760);
  PumpMessages(100);
  Require((Form1.GalleryTabs.Width = 1200) and
    (Form1.GalleryTabs.Height = 760),
    Format('Viewport solicitado 1200x760 nao foi aplicado (actual=%dx%d).',
      [Form1.GalleryTabs.Width, Form1.GalleryTabs.Height]));
  TDACThemeManager.SetApplicationMode(dtmLight);
  PumpMessages(60);
  RequireInputGalleryGeometry(Form1, '1200x760 light');
  LInputGeometrySizedLight := InputGalleryGeometrySignature(Form1);
  TDACThemeManager.SetApplicationMode(dtmDark);
  PumpMessages(60);
  RequireInputGalleryGeometry(Form1, '1200x760 dark');
  LInputGeometrySizedDark := InputGalleryGeometrySignature(Form1);
  Require(LInputGeometrySizedLight = LInputGeometrySizedDark,
    'Light/Dark alterou a geometria declarativa em 1200x760.');

  Form1.GalleryTabs.SetBounds(Form1.GalleryTabs.Left,
    Form1.GalleryTabs.Top, 520, 560);
  PumpMessages(100);
  Require((Form1.GalleryTabs.Width = 520) and
    (Form1.GalleryTabs.Height = 560),
    Format('Viewport solicitado 520x560 nao foi aplicado (actual=%dx%d).',
      [Form1.GalleryTabs.Width, Form1.GalleryTabs.Height]));
  TDACThemeManager.SetApplicationMode(dtmLight);
  PumpMessages(60);
  RequireInputGalleryGeometry(Form1, '520x560 light');
  LInputGeometrySizedLight := InputGalleryGeometrySignature(Form1);
  TDACThemeManager.SetApplicationMode(dtmDark);
  PumpMessages(60);
  RequireInputGalleryGeometry(Form1, '520x560 dark');
  LInputGeometrySizedDark := InputGalleryGeometrySignature(Form1);
  Require(LInputGeometrySizedLight = LInputGeometrySizedDark,
    'Light/Dark alterou a geometria declarativa em 520x560.');

  Form1.GalleryTabs.SetBounds(Form1.GalleryTabs.Left,
    Form1.GalleryTabs.Top, 1824, 1197);
  PumpMessages(100);
  Require((Form1.GalleryTabs.Width = 1824) and
    (Form1.GalleryTabs.Height = 1197),
    Format('Round-trip nao restaurou 1824x1197 (actual=%dx%d).',
      [Form1.GalleryTabs.Width, Form1.GalleryTabs.Height]));
  RequireInputGalleryGeometry(Form1, '1824x1197 dark apos round-trip', False);
  Require(InputGalleryGeometrySignature(Form1) = LInputGeometryDark,
    'Round-trip 1824 -> 1200 -> 520 -> 1824 nao restaurou a geometria dark.');
  TDACThemeManager.SetApplicationMode(dtmLight);
  PumpMessages(60);
  RequireInputGalleryGeometry(Form1, '1824x1197 light apos round-trip', False);
  Require(InputGalleryGeometrySignature(Form1) = LInputGeometryLight,
    'Round-trip 1824 -> 1200 -> 520 -> 1824 nao restaurou a geometria light.');
  TDACThemeManager.SetApplicationMode(dtmDark);
  PumpMessages(60);
  Form1.GalleryTabs.SetBounds(LInputTabsOriginalBounds.Left,
    LInputTabsOriginalBounds.Top, LInputTabsOriginalBounds.Width,
    LInputTabsOriginalBounds.Height);
  PumpMessages(80);
  LEditTokens := TDACComponentStyle.ResolveForSurface(
    LInputEdit, LInputEdit.ThemeMode).Tokens.Controls;
  LButtonEditTokens := TDACComponentStyle.ResolveForSurface(
    LInputButtonEdit, LInputButtonEdit.ThemeMode).Tokens.Controls;
  LDateTimeTokens := TDACComponentStyle.ResolveForSurface(
    LDateTime, LDateTime.ThemeMode).Tokens.Controls;
  LComboPaintBox := nil;
  for I := 0 to LInputCombo.ControlCount - 1 do
    if LInputCombo.Controls[I] is TSkPaintBox then
      LComboPaintBox := TSkPaintBox(LInputCombo.Controls[I]);
  Require(LComboPaintBox <> nil,
    'ComboBox nao materializou o paintbox da area clicavel.');
  RequireFieldLabelParity(dtmLight, 'tema light');
  RequireFieldLabelParity(dtmDark, 'tema dark');
  LInputEdit.ThemeMode := dtmInherit;
  LInputButtonEdit.ThemeMode := dtmInherit;
  LInputMemo.ThemeMode := dtmInherit;
  LInputCombo.ThemeMode := dtmInherit;
  LDateTime.ThemeMode := dtmInherit;
  LStatusBar := Form1.FindComponent('demoStatusBar') as TDACStatusBar;
  LProgress := Form1.FindComponent('demoProgress') as TDACProgress;
  LLoading := Form1.FindComponent('demoLoading') as TDACLoading;
  LDashboardCard := Form1.FindComponent('dashKpi1') as TDACSummaryCard;
  LDashboardChart := Form1.FindComponent('dashProductivityChart') as TDACChart;
  LDashboardModule := Form1.FindComponent('dashModule1') as TDACContainer;
  LDashboardQuickGrid := Form1.FindComponent('dashQuickActionsGrid') as TDACGridContainer;
  LThemeContainer := TDACContainer.Create(Form1);
  LThemeGrid := TDACGridContainer.Create(Form1);
  LThemeSummary := TDACSummaryCard.Create(Form1);
  LThemeSkia := TThemeSkiaControl.Create(Form1);
  LThemeSkia.Parent := Form1;
  LThemeSkia.SetBounds(Max(0, Form1.ClientWidth - 2), Max(0, Form1.ClientHeight - 2), 1, 1);
  LThemeText := TDACSystemText.Create(Form1);
  LThemeText.Parent := Form1;
  LThemeText.Visible := False;
  LThemeText.FontFamily := 'Arial';
  Require(SameText(LThemeText.FontFamily, TDACComponentStyle.FontFamily) and
    SameText((Form1.FindComponent('demoNavigationTitle') as TDACSystemText).FontFamily,
      TDACComponentStyle.FontFamily),
    'SystemText deve normalizar FontFamily de streaming/interacao para Inter.');
  Require((LThemeText.Role = mtrSmall) and
    (LThemeText.Tone = mttDefault) and
    (LThemeText.FontSize = Round(TDACComponentStyle.ResolveForSurface(
      LThemeText, dtmInherit).Tokens.Typography.SmallTextSize)),
    'SystemText nao iniciou com Role/Tone semanticos estaveis.');
  LThemeText.Role := mtrBody;
  LThemeText.FontSize := LThemeText.FontSize;
  LThemeText.Tone := mttSecondary;
  LThemeText.TextColor := LThemeText.TextColor;
  Require((LThemeText.Role = mtrCustom) and
    (LThemeText.Tone = mttCustom),
    'Setters legados iguais ao token nao promoveram Role/Tone para Custom.');
  LThemeText.Role := mtrSmall;
  LThemeText.Tone := mttDefault;
  System.Classes.RegisterClass(TDACSystemText);
  System.Classes.RegisterClass(TSkPaintBox);
  LSystemTextDfm := TStringStream.Create(
    'object LegacyText: TDACSystemText' + sLineBreak +
    '  Left = 0' + sLineBreak +
    '  Top = 0' + sLineBreak +
    '  Width = 120' + sLineBreak +
    '  Height = 20' + sLineBreak +
    '  FontFamily = ''Arial''' + sLineBreak +
    '  FontSize = 13' + sLineBreak +
    '  Text = ''Texto legado''' + sLineBreak +
    'end');
  LSystemTextBinary := TMemoryStream.Create;
  try
    LSystemTextDfm.Position := 0;
    ObjectTextToBinary(LSystemTextDfm, LSystemTextBinary);
    LSystemTextBinary.Position := 0;
    LStreamedSystemText := TDACSystemText(LSystemTextBinary.ReadComponent(nil));
    try
      Require(SameText(LStreamedSystemText.FontFamily,
        TDACComponentStyle.FontFamily),
        'Streaming DFM nao normalizou FontFamily legado para Inter.');
      Require((LStreamedSystemText.Role = mtrCustom) and
        (LStreamedSystemText.FontSize = 13),
        'Streaming DFM legado de FontSize nao promoveu Role para Custom.');
    finally
      LStreamedSystemText.Free;
    end;

    LSemanticSystemText := TDACSystemText.Create(nil);
    try
      LSemanticSystemText.Name := 'SemanticText';
      LSemanticSystemText.Role := mtrDisplay;
      LSemanticSystemText.Tone := mttAccent;
      LSystemTextBinary.Clear;
      LSystemTextBinary.WriteComponent(LSemanticSystemText);
      LSystemTextBinary.Position := 0;
      LStreamedSystemText :=
        TDACSystemText(LSystemTextBinary.ReadComponent(nil));
      try
        Require((LStreamedSystemText.Role = mtrDisplay) and
          (LStreamedSystemText.Tone = mttAccent) and
          (LStreamedSystemText.FontSize = Round(
            TDACComponentStyle.ResolveForSurface(LStreamedSystemText,
              dtmInherit).Tokens.Typography.DisplaySize)) and
          (LStreamedSystemText.TextColor =
            TDACComponentStyle.ResolveForSurface(LStreamedSystemText,
              dtmInherit).Tokens.Controls.SystemTextAccent),
          'Round-trip semantico de Role/Tone do SystemText perdeu tokens.');
      finally
        LStreamedSystemText.Free;
      end;
    finally
      LSemanticSystemText.Free;
    end;

    LSemanticButton := TDACButton.Create(nil);
    try
      LSemanticButton.Name := 'SemanticButton';
      Require((LSemanticButton.Shape = mbshDefault) and
        (LSemanticButton.CornerRadius = Round(
          TDACComponentStyle.ResolveForSurface(LSemanticButton,
            dtmInherit).Tokens.Controls.ButtonDefaultCornerRadius)),
        'ButtonShape Default nao resolveu o token canonico.');
      LSemanticButton.Shape := mbshCompact;
      Require(LSemanticButton.CornerRadius = Round(
        TDACComponentStyle.ResolveForSurface(LSemanticButton,
          dtmInherit).Tokens.Controls.ButtonCompactCornerRadius),
        'ButtonShape Compact nao resolveu o token canonico.');
      LSemanticButton.CornerRadius := LSemanticButton.CornerRadius;
      Require(LSemanticButton.Shape = mbshCustom,
        'CornerRadius legado igual ao token nao promoveu ButtonShape Custom.');
      LSemanticButton.Shape := mbshRounded;
      LSystemTextBinary.Clear;
      LSystemTextBinary.WriteComponent(LSemanticButton);
      LSystemTextBinary.Position := 0;
      LStreamedButton := TDACButton(LSystemTextBinary.ReadComponent(nil));
      try
        Require((LStreamedButton.Shape = mbshRounded) and
          (LStreamedButton.CornerRadius = Round(
            TDACComponentStyle.ResolveForSurface(LStreamedButton,
              dtmInherit).Tokens.Controls.ButtonRoundedCornerRadius)),
          'Round-trip de ButtonShape perdeu o preset Rounded.');
      finally
        LStreamedButton.Free;
      end;
    finally
      LSemanticButton.Free;
    end;

    LSemanticGrid := TDACGridContainer.Create(nil);
    try
      LSemanticGrid.Name := 'SemanticGrid';
      Require((LSemanticGrid.Layout = mgclDefault) and
        (LSemanticGrid.Appearance = mgcaDefault),
        'GridContainer nao iniciou com Layout/Appearance defaults.');
      LSemanticGrid.Layout := mgclDense;
      Require((LSemanticGrid.ContentPadding = 16) and
        (LSemanticGrid.Gutter = 10) and
        (LSemanticGrid.RowHeight = 44) and
        (LSemanticGrid.CornerRadius = 10),
        'GridContainer Dense divergiu dos tokens canonicos.');
      LSemanticGrid.ContentPadding := LSemanticGrid.ContentPadding;
      Require(LSemanticGrid.Layout = mgclCustom,
        'ContentPadding legado igual ao token nao promoveu Layout Custom.');
      LSemanticGrid.BackgroundColor := TAlphaColor($FF123456);
      LSemanticGrid.ThemeMode := dtmDark;
      Require((LSemanticGrid.BackgroundColor = TAlphaColor($FF123456)) and
        (LSemanticGrid.BorderColor =
          TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.
            GridContainerBorder),
        'Override isolado de background congelou a borda dark do GridContainer.');
      LSemanticGrid.ThemeMode := dtmLight;
      Require((LSemanticGrid.BackgroundColor = TAlphaColor($FF123456)) and
        (LSemanticGrid.BorderColor =
          TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.
            GridContainerBorder),
        'Override isolado de background congelou a borda light do GridContainer.');
      LSemanticGrid.Layout := mgclActionTiles;
      LSemanticGrid.Appearance := mgcaTransparent;
      LSemanticGrid.AutoContentHeight := True;
      LSemanticGrid.MinimumColumnWidth := 180;
      LSemanticGrid.SizeRowsToContent := True;
      LSemanticGrid.ThemeMode := dtmInherit;
      LSystemTextBinary.Clear;
      LSystemTextBinary.WriteComponent(LSemanticGrid);
      LSystemTextBinary.Position := 0;
      LStreamedGrid := TDACGridContainer(
        LSystemTextBinary.ReadComponent(nil));
      try
        Require((LStreamedGrid.Layout = mgclActionTiles) and
          (LStreamedGrid.Appearance = mgcaTransparent) and
          (LStreamedGrid.ContentPadding = 0) and
          (LStreamedGrid.Gutter = 12) and
          (LStreamedGrid.RowHeight = 70) and
          (LStreamedGrid.CornerRadius = 0) and
          LStreamedGrid.AutoContentHeight and
          (LStreamedGrid.MinimumColumnWidth = 180) and
          LStreamedGrid.SizeRowsToContent,
          'Round-trip do GridContainer perdeu layout, appearance ou sizing.');
      finally
        LStreamedGrid.Free;
      end;
    finally
      LSemanticGrid.Free;
    end;

    LSemanticScroll := TDACScrollContainer.Create(nil);
    try
      LSemanticScroll.Name := 'SemanticScroll';
      Require((LSemanticScroll.Appearance = mscaDefault) and
        (LSemanticScroll.CornerRadius = Round(
          TDACComponentStyle.ResolveForSurface(LSemanticScroll,
            dtmInherit).Tokens.Controls.ScrollContainerRadius)),
        'ScrollAppearance Default nao resolveu o token canonico.');
      LSemanticScroll.Appearance := mscaViewport;
      Require((LSemanticScroll.CornerRadius = 0) and
        (LSemanticScroll.BackgroundColor =
          TDACComponentStyle.ResolveForSurface(LSemanticScroll,
            dtmInherit).Tokens.Controls.ScrollContainerViewportBackground),
        'ScrollAppearance Viewport divergiu dos tokens canonicos.');
      LSemanticScroll.CornerRadius := LSemanticScroll.CornerRadius;
      Require(LSemanticScroll.Appearance = mscaCustom,
        'CornerRadius legado igual ao token nao promoveu ScrollAppearance Custom.');
      LSemanticScroll.CornerRadius := 3;
      LSemanticScroll.ThemeMode := dtmDark;
      Require((LSemanticScroll.CornerRadius = 3) and
        (LSemanticScroll.BackgroundColor =
          TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.
            ScrollContainerViewportBackground) and
        (LSemanticScroll.BorderColor =
          TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.
            ScrollContainerViewportBorder),
        'Override isolado de raio congelou cores dark do ScrollContainer.');
      LSemanticScroll.ThemeMode := dtmLight;
      Require((LSemanticScroll.CornerRadius = 3) and
        (LSemanticScroll.BackgroundColor =
          TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.
            ScrollContainerViewportBackground),
        'Override isolado de raio congelou cores light do ScrollContainer.');
      LSemanticScroll.Appearance := mscaDefault;
      LSemanticScroll.BackgroundColor := TAlphaColor($FF123456);
      LSemanticScroll.ThemeMode := dtmDark;
      Require((LSemanticScroll.BackgroundColor = TAlphaColor($FF123456)) and
        (LSemanticScroll.BorderColor =
          TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.
            ScrollContainerBorder),
        'Override isolado de background congelou a borda dark do ScrollContainer.');
      LSemanticScroll.ThemeMode := dtmLight;
      Require((LSemanticScroll.BackgroundColor = TAlphaColor($FF123456)) and
        (LSemanticScroll.BorderColor =
          TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.
            ScrollContainerBorder),
        'Override isolado de background congelou a borda light do ScrollContainer.');
      LSemanticScroll.Appearance := mscaViewport;
      LSemanticScroll.ThemeMode := dtmInherit;
      LSystemTextBinary.Clear;
      LSystemTextBinary.WriteComponent(LSemanticScroll);
      LSystemTextBinary.Position := 0;
      LStreamedScroll := TDACScrollContainer(
        LSystemTextBinary.ReadComponent(nil));
      try
        Require((LStreamedScroll.Appearance = mscaViewport) and
          (LStreamedScroll.CornerRadius = 0) and
          (LStreamedScroll.BackgroundColor =
            TDACComponentStyle.ResolveForSurface(LStreamedScroll,
              dtmInherit).Tokens.Controls.ScrollContainerViewportBackground),
          'Round-trip do ScrollContainer perdeu Appearance Viewport.');
      finally
        LStreamedScroll.Free;
      end;
    finally
      LSemanticScroll.Free;
    end;

    LSemanticContainer := TDACContainer.Create(nil);
    try
      LSemanticContainer.Name := 'SemanticContainer';
      LSemanticContainer.Appearance := mcaDarkCard;
      LSystemTextBinary.Clear;
      LSystemTextBinary.WriteComponent(LSemanticContainer);
      LSystemTextBinary.Position := 0;
      LStreamedContainer := TDACContainer(
        LSystemTextBinary.ReadComponent(nil));
      try
        Require((LStreamedContainer.Appearance = mcaDarkCard) and
          (LStreamedContainer.ContentPadding = 12) and
          (LStreamedContainer.CornerRadius = 12) and
          (LStreamedContainer.BorderRadius = 12),
          'Round-trip do Container perdeu Appearance DarkCard.');
      finally
        LStreamedContainer.Free;
      end;
    finally
      LSemanticContainer.Free;
    end;

    LSemanticSummary := TDACSummaryCard.Create(nil);
    try
      LSemanticSummary.Name := 'SemanticSummary';
      LSemanticSummary.Appearance := mcsaDashboard;
      LSystemTextBinary.Clear;
      LSystemTextBinary.WriteComponent(LSemanticSummary);
      LSystemTextBinary.Position := 0;
      LStreamedSummary := TDACSummaryCard(
        LSystemTextBinary.ReadComponent(nil));
      try
        Require((LStreamedSummary.Appearance = mcsaDashboard) and
          (LStreamedSummary.CornerRadius = 14),
          'Round-trip do SummaryCard perdeu Appearance Dashboard.');
      finally
        LStreamedSummary.Free;
      end;
    finally
      LSemanticSummary.Free;
    end;

    LSemanticChart := TDACChart.Create(nil);
    try
      LSemanticChart.Name := 'SemanticChart';
      LSemanticChart.Appearance := mchaDashboard;
      LSystemTextBinary.Clear;
      LSystemTextBinary.WriteComponent(LSemanticChart);
      LSystemTextBinary.Position := 0;
      LStreamedChart := TDACChart(LSystemTextBinary.ReadComponent(nil));
      try
        Require(LStreamedChart.Appearance = mchaDashboard,
          'Round-trip do Chart perdeu Appearance Dashboard.');
      finally
        LStreamedChart.Free;
      end;
    finally
      LSemanticChart.Free;
    end;
  finally
    LSystemTextBinary.Free;
    LSystemTextDfm.Free;
  end;
  LLegacyTextWidth := LThemeText.MeasureTextWidth('Medida Inter', 'Arial', 13, False);
  LInterTextWidth := LThemeText.MeasureTextWidth('Medida Inter',
    TDACComponentStyle.FontFamily, 13, False);
  Require((LLegacyTextWidth > 0) and (LLegacyTextWidth = LInterTextWidth),
    'MeasureTextWidth deve normalizar familia legada para Inter.');
  LBadge := Form1.FindComponent('demoBadge') as TDACBadge;
  LPagination := Form1.FindComponent('demoPagination') as TDACPagination;
  LToast := Form1.FindComponent('demoToast') as TDACToast;
  LTooltip := Form1.FindComponent('demoTooltip') as TDACTooltip;
  TDACThemeManager.SetApplicationMode(dtmLight);
  PumpMessages(40);
  LStatusBar.ThemeMode := dtmDark;
  LProgress.ThemeMode := dtmDark;
  LLoading.ThemeMode := dtmDark;
  Require((LStatusBar.ThemeMode = dtmDark) and (LProgress.ThemeMode = dtmDark) and
    (LLoading.ThemeMode = dtmDark),
    'StatusBar, Progress e Loading precisam expor o override local de tema.');
  Require((LStatusBar.ResolvedBackgroundColor =
      TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.StatusBackground) and
    (LStatusBar.ResolvedTextColor =
      TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.StatusText) and
    (LProgress.ResolvedTrackColor =
      TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.ProgressTrack) and
    (LProgress.ResolvedAccentColor =
      TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.Success) and
    (LLoading.ResolvedSurfaceColor =
      TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.PopupBackground) and
    (LLoading.ResolvedAccentColor =
      TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.LoadingAccent),
    'Override local dark nao foi resolvido pelo painter de Status, Progress ou Loading.');
  LStatusBar.ThemeMode := dtmInherit;
  LProgress.ThemeMode := dtmInherit;
  LLoading.ThemeMode := dtmInherit;
  Require((LStatusBar.ResolvedBackgroundColor =
      TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.StatusBackground) and
    (LProgress.ResolvedTrackColor =
      TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.ProgressTrack) and
    (LLoading.ResolvedSurfaceColor =
      TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.PopupBackground),
    'dtmInherit nao retomou a paleta light global em Status, Progress e Loading.');
  LThemeContainer.ThemeMode := dtmDark;
  LThemeSummary.ThemeMode := dtmDark;
  LThemeGrid.ThemeMode := dtmDark;
  LBadge.ThemeMode := dtmDark;
  LPagination.ThemeMode := dtmDark;
  LToast.ThemeMode := dtmDark;
  LTooltip.ThemeMode := dtmDark;
  LThemeText.ThemeMode := dtmDark;
  Require((LThemeContainer.ResolvedBackgroundColor =
      TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.ContainerSuiteBackground) and
    (LThemeContainer.TitleColor =
      TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.ContainerTitle) and
    (LThemeContainer.SubtitleColor =
      TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.ContainerSubtitle) and
    (LThemeSummary.ResolvedBackgroundColor =
      TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.SummaryCardBackground) and
    (LThemeGrid.ResolvedBackgroundColor =
      TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.GridContainerBackground) and
    (LBadge.ResolvedBackgroundColor =
      TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.BadgeSoftBackground) and
    (LPagination.ResolvedBackgroundColor =
      TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.PaginationBackground) and
    (LToast.ResolvedBackgroundColor =
      TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.ToastSuccessBackground) and
    (LTooltip.ResolvedBackgroundColor =
      TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.TooltipBackground) and
    (LThemeText.ResolvedTextColor =
      TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.InputText),
    'ThemeMode dark local nao chegou ao grupo A de containers e feedback.');
  LThemeContainer.ThemeMode := dtmInherit;
  LThemeSummary.ThemeMode := dtmInherit;
  LThemeGrid.ThemeMode := dtmInherit;
  LBadge.ThemeMode := dtmInherit;
  LPagination.ThemeMode := dtmInherit;
  LToast.ThemeMode := dtmInherit;
  LTooltip.ThemeMode := dtmInherit;
  LThemeText.ThemeMode := dtmInherit;
  Require(LThemeContainer.ResolvedBackgroundColor =
    TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.ContainerSuiteBackground,
    'Container inherit nao retomou o tema light.');
  Require((LThemeContainer.TitleColor =
      TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.ContainerTitle) and
    (LThemeContainer.SubtitleColor =
      TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.ContainerSubtitle),
    'Titulos do Container inherit nao retomaram o tema light.');
  Require(LThemeSummary.ResolvedBackgroundColor =
    TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.SummaryCardBackground,
    'SummaryCard inherit nao retomou o tema light.');
  Require(LThemeGrid.ResolvedBackgroundColor =
    TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.GridContainerBackground,
    'GridContainer inherit nao retomou o tema light.');
  Require(LPagination.ResolvedBackgroundColor =
    TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.PaginationBackground,
    'Pagination inherit nao retomou o tema light.');
  Require(LThemeText.ResolvedTextColor =
    TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.InputText,
    'SystemText inherit nao retomou o token Light efetivo da Form.');
  TDACThemeManager.SetApplicationMode(dtmDark);
  PumpMessages(40);
  Require((LThemeContainer.ResolvedBackgroundColor =
      TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.ContainerSuiteBackground) and
    (LThemeGrid.ResolvedBackgroundColor =
      TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.GridContainerBackground) and
    (LPagination.ResolvedBackgroundColor =
      TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.PaginationBackground) and
    (LToast.ResolvedBackgroundColor =
      TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.ToastSuccessBackground) and
    (LTooltip.ResolvedBackgroundColor =
      TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.TooltipBackground),
    'Painters herdados nao respeitaram o tema global dark em toda a pagina.');
  TDACThemeManager.SetApplicationMode(dtmLight);
  PumpMessages(40);
  LExplicitTextSize := 17;
  LExplicitTextColor := TAlphaColor($FF7A4B2A);
  LThemeText.FontSize := LExplicitTextSize;
  LThemeText.TextColor := LExplicitTextColor;
  Require((LThemeText.Role = mtrCustom) and
    (LThemeText.Tone = mttCustom),
    'Setters legados FontSize/TextColor nao promoveram Role/Tone para Custom.');
  TDACThemeManager.SetApplicationMode(dtmLight);
  LThemeText.ThemeMode := dtmDark;
  Require((LThemeText.FontSize = LExplicitTextSize) and
    (LThemeText.TextColor = LExplicitTextColor),
    'SystemText perdeu FontSize/TextColor explicitos no override local dark.');
  LThemeText.ThemeMode := dtmInherit;
  Require((LThemeText.FontSize = LExplicitTextSize) and
    (LThemeText.TextColor = LExplicitTextColor),
    'SystemText perdeu FontSize/TextColor explicitos no inherit light.');
  TDACThemeManager.SetApplicationMode(dtmDark);
  Require((LThemeText.FontSize = LExplicitTextSize) and
    (LThemeText.TextColor = LExplicitTextColor),
    'SystemText perdeu FontSize/TextColor explicitos no global dark.');
  TDACThemeManager.SetApplicationMode(dtmLight);
  LThemeSkia.ThemeMode := dtmDark;
  LThemeSkia.Redraw;
  PumpMessages(30);
  Require((LThemeSkia.ThemeMode = dtmDark) and
    (LThemeSkia.ResolvedTokens.ContainerSuiteBackground =
      TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.ContainerSuiteBackground) and
    (LThemeSkia.Theme.Tokens.Controls.ContainerSuiteBackground =
      TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.ContainerSuiteBackground) and
    (LThemeSkia.LastDrawBackground =
      TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.ContainerSuiteBackground) and
    (LThemeSkia.DrawCount > 0),
    'TDACSkiaControl nao aplicou o override local dark no DrawContent.');
  LThemeSkia.ThemeMode := dtmInherit;
  LThemeSkia.Redraw;
  PumpMessages(30);
  Require((LThemeSkia.ResolvedTokens.ContainerSuiteBackground =
      TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.ContainerSuiteBackground) and
    (LThemeSkia.LastDrawBackground =
      TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.ContainerSuiteBackground),
    'TDACSkiaControl inherit nao retomou a surface Light efetiva da Form.');
  TDACThemeManager.SetApplicationMode(dtmDark);
  PumpMessages(30);
  Require((LThemeSkia.ResolvedTokens.ContainerSuiteBackground =
      TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.ContainerSuiteBackground) and
    (LThemeSkia.LastDrawBackground =
      TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.ContainerSuiteBackground),
    'TDACSkiaControl inherit nao refletiu o global dark no DrawContent.');
  LThemeSkia.Theme := TDACComponentStyle.Resolve(dtmLight);
  LThemeSkia.Redraw;
  PumpMessages(30);
  Require((LThemeSkia.ThemeMode = dtmLight) and
    (LThemeSkia.Theme.Tokens.Controls.ContainerSuiteBackground =
      TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.ContainerSuiteBackground) and
    (LThemeSkia.LastDrawBackground =
      TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.ContainerSuiteBackground),
    'Fachada Theme do TDACSkiaControl nao preservou a semantica light resolvida.');
  LThemeSkia.ThemeMode := dtmInherit;
  TDACThemeManager.SetApplicationMode(dtmLight);
  Form1.btnKindPrimary.ThemeMode := dtmDark;
  Require(Form1.btnKindPrimary.ResolvedBackgroundColor =
    TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.ButtonPrimary,
    'ThemeMode local dark do Button vazou a paleta global light no chrome Skia.');
  Form1.btnKindPrimary.ThemeMode := dtmLight;
  Require(Form1.btnKindPrimary.ResolvedBackgroundColor =
    TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.ButtonPrimary,
    'ThemeMode local light do Button nao resolveu a paleta do proprio controle.');
  LInputEdit.ThemeMode := dtmDark;
  LInputButtonEdit.ThemeMode := dtmDark;
  LInputCombo.ThemeMode := dtmDark;
  LDateTime.ThemeMode := dtmDark;
  PumpMessages(40);
  Require((LInputEdit.EditControl.Font.Color = TDACComponentColors.ToVclColor(
      TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.InputText)) and
    (LInputButtonEdit.EditControl.Font.Color = TDACComponentColors.ToVclColor(
      TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.InputText)) and
    (LInputCombo.ComboControl.Font.Color = TDACComponentColors.ToVclColor(
      TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.InputText)) and
    (LDateTime.PickerControl.Font.Color = TDACComponentColors.ToVclColor(
      TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.InputText)),
    'Override ThemeMode local nao foi aplicado igualmente a HWNDs dos quatro campos.');
  LInputEdit.ThemeMode := dtmInherit;
  LInputButtonEdit.ThemeMode := dtmInherit;
  LInputCombo.ThemeMode := dtmInherit;
  LDateTime.ThemeMode := dtmInherit;
  PumpMessages(40);
  Require((LInputEdit.EditControl.Font.Color = TDACComponentColors.ToVclColor(
      TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.InputText)) and
    (LInputButtonEdit.EditControl.Font.Color = TDACComponentColors.ToVclColor(
      TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.InputText)) and
    (LInputCombo.ComboControl.Font.Color = TDACComponentColors.ToVclColor(
      TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.InputText)) and
    (LDateTime.PickerControl.Font.Color = TDACComponentColors.ToVclColor(
      TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.InputText)),
    'ThemeMode inherit nao retomou a semantica do tema global light.');
  TDACThemeManager.SetApplicationMode(dtmDark);
  PumpMessages(40);
  Require((LInputButtonEdit.EditControl.Font.Color = TDACComponentColors.ToVclColor(
      TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.InputText)) and
    (LInputButtonEdit.ButtonControl.ThemeMode = dtmInherit),
    'ButtonEdit inherit nao respeitou a superficie dark da TabSheet sob global dark.');
  TDACThemeManager.SetApplicationMode(dtmLight);
  PumpMessages(40);
  Require((LInputEdit.ThemeMode = dtmInherit) and
    (LInputEdit.EditControl.Font.Name = 'Inter') and
    (LInputCombo.ComboControl.Font.Name = 'Inter') and
    (LDateTime.PickerControl.Font.Name = 'Inter') and
    (LInputEdit.EditControl.Font.Color = TDACComponentColors.ToVclColor(
      TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.InputText)),
    'Tema claro ou fonte Inter nao foi propagado aos editores nativos.');
  TDACThemeManager.SetApplicationMode(dtmLight);
  LDateTime.ThemeMode := dtmInherit;
  Form1.GalleryTabs.ActiveIndex :=
    (Form1.FindComponent('tsSelectors') as TTabSheet).PageIndex;
  PumpMessages(40);
  Require(LDateTime.PickerControl.Visible and
    IsWindowVisible(LDateTime.PickerControl.Handle),
    Format('DateTimePicker nativo deve permanecer visivel como dono do texto fora de foco (fieldShowing=%s fieldHwnd=%s pickerVisible=%s pickerHwnd=%s parent=%s).',
      [BoolToStr(LDateTime.Showing, True),
       BoolToStr(IsWindowVisible(LDateTime.Handle), True),
       BoolToStr(LDateTime.PickerControl.Visible, True),
       BoolToStr(IsWindowVisible(LDateTime.PickerControl.Handle), True),
       LDateTime.PickerControl.Parent.Name]));
  LComboBeforeDate.SetFocus;
  PumpMessages(20);
  TFormAccess(Form1).FocusNext(LComboBeforeDate);
  PumpMessages(20);
  Require(LDateTime.PickerControl.Visible and
    LDateTime.PickerControl.Focused,
    'Tab nao transferiu o foco do seletor para o DateTimePicker nativo.');
  LDateTime.OpenPopup;
  PumpMessages(30);
  Require(LDateTime.PopupVisible and LDateTime.PickerControl.Visible and
    IsWindowVisible(LDateTime.PickerControl.Handle),
    'DateTimePicker focado nao manteve o HWND de texto visivel durante o popup.');
  LDateTime.OpenPopup;
  PumpMessages(20);
  Require(LDateTime.PopupVisible,
    'Reentrada durante popup ativo fechou ou recriou o calendario do DateTimePicker.');
  LShowingProbe := TEdit.Create(Form1);
  LShowingProbe.Parent := Form1.tsSelectors;
  LShowingProbe.SetBounds(-100, -100, 1, 1);
  Require(LShowingProbe.Showing,
    'Pre-condicao: controle VCL simples deve iniciar Showing na pagina ativa.');
  LMutationShowingHost := TShowingMutationHost.Create(Form1);
  LMutationShowingHost.Parent := Form1.tsSelectors;
  LMutationShowingHost.SetBounds(-120, -120, 2, 2);
  LDestroyShowingProbe := TEdit.Create(Form1);
  LDestroyShowingProbe.Parent := LMutationShowingHost;
  LDestroyShowingProbe.SetBounds(0, 0, 1, 1);
  LReparentShowingProbe := TShowingCountEdit.Create(Form1);
  LReparentShowingProbe.Parent := LMutationShowingHost;
  LReparentShowingProbe.SetBounds(0, 0, 1, 1);
  LActiveShowingProbe := TShowingCountEdit.Create(Form1);
  LActiveShowingProbe.Parent := Form1.tsInputs;
  LActiveShowingProbe.SetBounds(-100, -100, 1, 1);
  Require(LMutationShowingHost.Showing and
    not LActiveShowingProbe.Showing,
    'Pre-condicao: probes de mutacao devem refletir pagina antiga/ativa.');
  LReparentShowingProbe.ResetShowingChangeCount;
  LActiveShowingProbe.ResetShowingChangeCount;
  LMutationShowingHost.Arm(LDestroyShowingProbe,
    LReparentShowingProbe, Form1.tsInputs);
  LDestroyShowingProbe := nil;
  Form1.GalleryTabs.ActiveIndex := Form1.tsInputs.PageIndex;
  PumpMessages(40);
  Require(not LDateTime.Showing and
    not LDateTime.PopupVisible and
    not LDateTime.PickerControl.Visible,
    Format('Popup/guard do DateTimePicker permaneceu ativo depois de ocultar o host pela troca de aba (active=%d target=%d selector=%d parent=%s targetActive=%s pageShowing=%s showing=%s hwndVisible=%s popup=%s picker=%s).',
      [Form1.GalleryTabs.ActiveIndex, Form1.tsInputs.PageIndex,
       Form1.tsSelectors.PageIndex, LDateTime.Parent.Name,
       BoolToStr(Form1.GalleryTabs.ActivePage = Form1.tsInputs, True),
       BoolToStr(Form1.tsSelectors.Showing, True),
       BoolToStr(LDateTime.Showing, True),
       BoolToStr(IsWindowVisible(LDateTime.Handle), True),
       BoolToStr(LDateTime.PopupVisible, True),
       BoolToStr(LDateTime.PickerControl.Visible, True)]));
  Require(not LShowingProbe.Showing,
    'TDACTabs nao atualizou Showing de um controle VCL simples na pagina oculta.');
  Require(LMutationShowingHost.DestroyCompleted and
    LMutationShowingHost.ReparentCompleted and
    (LMutationShowingHost.MutationCount = 1),
    'CM_SHOWINGCHANGED nao concluiu destruicao/reparent mutation-safe.');
  Require((LReparentShowingProbe.Parent = Form1.tsInputs) and
    LReparentShowingProbe.Showing,
    'Controle reparentado durante CM_SHOWINGCHANGED ficou com cache Showing incorreto.');
  Require(LActiveShowingProbe.Showing and
    (LActiveShowingProbe.ShowingChangeCount = 1),
    Format('Pagina ativa recebeu propagacao redundante de Showing (count=%d).',
      [LActiveShowingProbe.ShowingChangeCount]));
  LMutationShowingHost.Free;
  LReparentShowingProbe.Free;
  LActiveShowingProbe.Free;
  LShowingProbe.Free;
  LDateTimePickerCount := 0;
  FillChar(LDateTimePickerClass, SizeOf(LDateTimePickerClass), 0);
  GetClassName(LDateTime.PickerControl.Handle, LDateTimePickerClass,
    Length(LDateTimePickerClass));
  LDateTimeChildHwnd := GetWindow(LDateTime.Handle, GW_CHILD);
  while LDateTimeChildHwnd <> 0 do
  begin
    FillChar(LDateTimeChildClass, SizeOf(LDateTimeChildClass), 0);
    GetClassName(LDateTimeChildHwnd, LDateTimeChildClass,
      Length(LDateTimeChildClass));
    if SameText(string(LDateTimeChildClass),
      string(LDateTimePickerClass)) then
      Inc(LDateTimePickerCount);
    LDateTimeChildHwnd := GetWindow(LDateTimeChildHwnd, GW_HWNDNEXT);
  end;
  Require((GetParent(LDateTime.PickerControl.Handle) = LDateTime.Handle) and
    (LDateTimePickerCount = 1),
    Format('Troca de aba com popup aberto duplicou/desanexou o SysDateTimePick32 (parent=%d expected=%d count=%d).',
      [GetParent(LDateTime.PickerControl.Handle), LDateTime.Handle,
       LDateTimePickerCount]));
  Form1.GalleryTabs.ActiveIndex :=
    (Form1.FindComponent('tsSelectors') as TTabSheet).PageIndex;
  PumpMessages(40);
  Form1.GalleryTabs.SetFocus;
  PumpMessages(20);
  Require(LDateTime.PickerControl.Visible and
    IsWindowVisible(LDateTime.PickerControl.Handle),
    'DateTimePicker nativo deixou de representar o valor depois de perder o foco.');
  LDateTime.OpenPopup;
  PumpMessages(20);
  Require(LDateTime.ResolvedPopupBackground =
    TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.DateTimePopupBackground,
    'Popup DateTime inherit nao iniciou no global light.');
  LDateTime.ThemeMode := dtmDark;
  PumpMessages(20);
  Require(LDateTime.ResolvedPopupBackground =
    TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.DateTimePopupBackground,
    'Popup DateTime nao recebeu ThemeMode dark do dono.');
  LDateTime.ThemeMode := dtmInherit;
  PumpMessages(20);
  Require(LDateTime.ResolvedPopupBackground =
    TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.DateTimePopupBackground,
    'Popup DateTime inherit nao retomou o global light.');
  TDACThemeManager.SetApplicationMode(dtmDark);
  PumpMessages(20);
  Require(LDateTime.ResolvedPopupBackground =
    TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.DateTimePopupBackground,
    'Popup DateTime inherit nao respeitou a superficie dark da TabSheet.');
  LDateTime.SimulatePopupKey(VK_ESCAPE);
  Require(not LDateTime.PopupVisible,
    'Popup de validacao de tema nao fechou antes do novo ciclo de selecao.');
  LDateTime.PickerKind := dtkDate;
  LDateTime.DateTime := EncodeDate(2026, 1, 31);
  LDateTime.OpenPopup;
  PumpMessages(40);
  Require(LDateTime.PopupVisible,
    'DateTimePicker nao abriu o popup Skia proprio para calendario/tempo.');
  LDateTime.SimulatePopupKey(VK_RIGHT);
  Require((DayOf(LDateTime.PopupSelectedDateTime) = 1) and
    (MonthOf(LDateTime.PopupSelectedDateTime) = 2) and
    (MonthOf(LDateTime.PopupDisplayMonth) = 2),
    'Seta no popup dtkDate nao moveu selecao e calendario antes de Enter/Esc.');
  LDateTime.SimulatePopupKey(VK_ESCAPE);
  Require(not LDateTime.PopupVisible,
    'Escape nao fechou o popup dtkDate apos a navegacao por seta.');
  LDateTime.PickerKind := dtkTime;
  LDateTime.TimeStepMinutes := 5;
  LDateTime.DateTime := EncodeDate(2026, 1, 31) + EncodeTime(23, 58, 0, 0);
  LDateTime.OpenPopup;
  LDateTime.SimulatePopupKey(VK_RIGHT);
  Require((MinuteOf(LDateTime.PopupSelectedDateTime) = 3) and
    (HourOf(LDateTime.PopupSelectedDateTime) = 0) and
    (MonthOf(LDateTime.PopupDisplayMonth) = 2),
    'Popup de hora nao aplicou step de minuto ou sincronizou o mes atravessado.');
  LDateTime.SimulatePopupKey(VK_UP);
  Require(HourOf(LDateTime.PopupSelectedDateTime) = 1,
    'Seta vertical do popup de hora nao ajustou a unidade de hora.');
  LDateTime.SimulatePopupKey(VK_ESCAPE);
  Require(not LDateTime.PopupVisible, 'Escape nao fechou o popup DateTime.');
  LDateTime.OpenPopup;
  LDateTime.SimulatePopupKey(VK_RIGHT);
  Require(LDateTime.PopupSelectedDateTime <> LDateTime.DateTime,
    'Seta nao moveu a selecao do calendario antes de Enter.');
  LDateTime.SimulatePopupKey(VK_RETURN);
  Require(not LDateTime.PopupVisible and (LDateTime.DateTime = LDateTime.PopupSelectedDateTime),
    'Enter nao aplicou valor/fechou o popup DateTime.');
  LDateTime.OpenPopup;
  LDateTime.SimulatePopupFooter(0);
  Require(LDateTime.PopupVisible and SameDate(LDateTime.PopupSelectedDateTime, Date),
    'Hoje nao selecionou a data atual.');
  LDateTime.SimulatePopupFooter(1);
  Require(not LDateTime.PopupVisible and SameValue(LDateTime.DateTime, 0),
    'Limpar nao zerou e fechou o popup DateTime.');
  LDateTime.DateTime := EncodeDate(2026, 1, 31);
  LDateTime.OpenPopup;
  LDateTime.SimulatePopupFooter(2);
  Require(not LDateTime.PopupVisible and (LDateTime.DateTime = LDateTime.PopupSelectedDateTime),
    'OK nao aplicou valor/fechou o popup DateTime.');
  LDateTime.OpenPopup;
  LDateTime.SimulatePopupExternalDeactivate;
  Require(not LDateTime.PopupVisible, 'Deactivate externo nao fechou o popup DateTime.');
  LDateTimeOriginalValue := LDateTime.DateTime;
  LDateTime.ReadOnly := True;
  Require(LDateTime.NativeLabel.FocusControl = nil,
    'Label do Date publicou FocusControl interno no streaming.');
  TControlClickAccess(LDateTime.NativeLabel).Click;
  PumpMessages(20);
  Require(LDateTime.PickerControl.Focused and
    LDateTime.PickerControl.Visible,
    'Date readonly nao aceitou foco/segmento nativo pelo label.');
  LDateTime.PickerControl.Perform(WM_KEYDOWN, VK_RIGHT, 0);
  LDateTime.PickerControl.Perform(WM_KEYUP, VK_RIGHT, 0);
  LDateTime.OpenPopup;
  LDateTime.SimulatePopupKey(VK_RIGHT);
  LDateTime.SimulatePopupFooter(1);
  Require(not LDateTime.PopupVisible and
    SameValue(LDateTime.DateTime, LDateTimeOriginalValue),
    'ReadOnly abriu ou alterou o DateTimePicker.');
  LDateTime.ReadOnly := False;
  Form1.GalleryTabs.SetFocus;
  LDateTime.Loading := True;
  TControlClickAccess(LDateTime.NativeLabel).Click;
  PumpMessages(20);
  Require(not LDateTime.PickerControl.Focused and
    LDateTime.PickerControl.Visible and
    not LDateTime.PickerControl.Enabled,
    'Date Loading recebeu foco ou ocultou o HWND nativo.');
  LDateTime.OpenPopup;
  LDateTime.SimulatePopupKey(VK_RIGHT);
  LDateTime.SimulatePopupFooter(1);
  Require(not LDateTime.PopupVisible and
    SameValue(LDateTime.DateTime, LDateTimeOriginalValue),
    'Loading abriu ou alterou o DateTimePicker.');
  LDateTime.Loading := False;
  Require(((GetWindowLong(LDateTime.PickerControl.Handle, GWL_STYLE) and
      WS_BORDER) = 0) and
    ((GetWindowLong(LDateTime.PickerControl.Handle, GWL_EXSTYLE) and
      (WS_EX_CLIENTEDGE or WS_EX_STATICEDGE)) = 0),
    'SysDateTimePick32 preservou borda/frame nativo dentro do chrome Skia.');
  Require(TDACThemeManager.IsUiThread,
    'Contrato de ThemeManager deve reconhecer a thread de UI do Interaction.');
  LScroll := Form1.scrButtons;
  Form1.GalleryTabs.ActivePage := Form1.tsInputs;
  PumpMessages(80);
  Require(Form1.GalleryTabs.ActivePage <> Form1.tsButtons,
    'Pre-condicao: scrButtons deve estar inativo antes da troca light para dark.');
  TDACThemeManager.SetApplicationMode(dtmDark);
  PumpMessages(40);
  Require(LScroll.BackgroundColor =
    TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.ScrollContainerViewportBackground,
    'ScrollContainer inativo nao recebeu a surface dark da TabSheet.');
  Form1.GalleryTabs.ActivePage := Form1.tsButtons;
  PumpMessages(120);
  Require((LScroll.BackgroundColor =
    TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.ScrollContainerViewportBackground) and
    LScroll.Showing,
    'Ativacao sob global dark nao preservou a superficie dark da TabSheet.');
  RequireScrollViewportSurface(LScroll, 'theme-inactive-dark-direct');

  Form1.GalleryTabs.ActivePage := Form1.tsInputs;
  PumpMessages(80);
  Require(Form1.GalleryTabs.ActivePage <> Form1.tsButtons,
    'Pre-condicao: scrButtons deve estar inativo antes da troca dark para light.');
  TDACThemeManager.SetApplicationMode(dtmLight);
  PumpMessages(40);
  Require(LScroll.BackgroundColor =
    TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.ScrollContainerViewportBackground,
    'ScrollContainer inativo nao atualizou o estado logico para light.');
  Form1.GalleryTabs.ActivePage := Form1.tsButtons;
  PumpMessages(120);
  Require((LScroll.BackgroundColor =
    TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.ScrollContainerViewportBackground) and
    LScroll.Showing,
    'Ativacao apos dark para light nao aplicou a superficie light pendente.');
  RequireScrollViewportSurface(LScroll, 'theme-inactive-dark-light-direct');

  TDACThemeManager.SetApplicationMode(dtmDark);
  PumpMessages(40);
  Form1.GalleryTabs.ActivePage := Form1.tsInputs;
  PumpMessages(120);
  TDACThemeManager.SetApplicationMode(dtmLight);
  LInputEdit.ThemeMode := dtmInherit;
  PumpMessages(30);
  RequireEditThemeTokens(LInputEdit, dtmLight, 'global light');
  LInputEdit.ThemeMode := dtmDark;
  PumpMessages(30);
  RequireEditThemeTokens(LInputEdit, dtmDark, 'override local dark');
  LInputEdit.ThemeMode := dtmInherit;
  PumpMessages(30);
  RequireEditThemeTokens(LInputEdit, dtmLight, 'inherit sob global light');
  TDACThemeManager.SetApplicationMode(dtmDark);
  PumpMessages(30);
  RequireEditThemeTokens(LInputEdit, dtmDark, 'inherit na TabSheet dark sob global dark');
  LInputEdit.EditKind := mekSearch;
  PumpMessages(20);
  Require(LInputEdit.EditControl.Width = LInputEdit.Width -
    Round(TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.InputNativeHorizontalPadding) -
    Round(TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.InputNativeRightReserveWithIcon),
    'TDACEdit nao reservou a coluna de icone pelo token InputNativeRightReserveWithIcon.');
  LInputEdit.EditKind := mekText;
  PumpMessages(20);
  LInputEdit.EditControl.SetFocus;
  Require(LInputEdit.EditControl.Focused,
    'TDACEdit nao transferiu foco para o TMaskEdit nativo apos a troca de tema.');
  LInputEdit.EditControl.Text := 'Edit nativo';
  LInputEdit.EditControl.SelStart := Length(LInputEdit.EditControl.Text);
  LInputEdit.EditControl.Perform(WM_CHAR, Ord('~'), 0);
  PumpMessages(20);
  Require(EndsText('~', LInputEdit.EditControl.Text) and
    (LInputEdit.EditControl.SelStart = Length(LInputEdit.EditControl.Text)),
    'Digitacao/caret nao permaneceu no TMaskEdit apos a troca de tema.');
  LInputEdit.EditControl.SelectAll;
  Require(LInputEdit.EditControl.SelLength = Length(LInputEdit.EditControl.Text),
    'Selecao nativa do TDACEdit foi perdida apos a troca de tema.');
  try
    LInputEdit.EditControl.CopyToClipboard;
    LClipboardText := Clipboard.AsText;
    LInputEdit.EditControl.Clear;
    LInputEdit.EditControl.PasteFromClipboard;
    Require(LInputEdit.EditControl.Text = LClipboardText,
      'Clipboard do TMaskEdit nao preservou o texto apos a troca de tema.');
  except
    on E: EClipboardException do
    begin
      // The desktop may temporarily own the system clipboard. Still exercise
      // the native edit message without presenting this environmental lock as
      // a component failure; an available clipboard follows the full branch.
      LInputEdit.EditControl.Perform(WM_COPY, 0, 0);
      Require(LInputEdit.EditControl.SelLength = Length(LInputEdit.EditControl.Text),
        'WM_COPY alterou a selecao nativa do TMaskEdit com clipboard bloqueado.');
    end;
  end;
  Require((LInputEdit.NativeLabel.FocusControl = nil) and
    (LInputButtonEdit.NativeLabel.FocusControl = nil) and
    (LInputMemo.NativeLabel.FocusControl = nil),
    'Presenter de label publicou referencia interna insegura no DFM.');
  LInputEdit.ReadOnly := True;
  TControlClickAccess(LInputEdit.NativeLabel).Click;
  PumpMessages(20);
  Require(LInputEdit.EditControl.Focused and LInputEdit.EditControl.ReadOnly,
    'Clique no label do Edit readonly nao levou foco/caret ao editor nativo.');
  LInputEdit.EditControl.SelectAll;
  Require(LInputEdit.EditControl.SelLength =
    Length(LInputEdit.EditControl.Text),
    'Edit readonly perdeu selecao/copia nativa apos clique no label.');
  LInputEdit.ReadOnly := False;
  TControlClickAccess(LInputButtonEdit.NativeLabel).Click;
  PumpMessages(20);
  Require(LInputButtonEdit.EditControl.Focused,
    'Clique no label do ButtonEdit nao levou foco ao TMaskEdit interno.');
  LInputMemo.ReadOnly := True;
  TControlClickAccess(LInputMemo.NativeLabel).Click;
  PumpMessages(20);
  Require(LInputMemo.MemoControl.Focused and LInputMemo.MemoControl.ReadOnly,
    'Clique no label do Memo readonly nao levou foco ao editor nativo.');
  LInputMemo.ReadOnly := False;
  LInputMemo.MemoControl.SetFocus;
  LInputEdit.Loading := True;
  TControlClickAccess(LInputEdit.NativeLabel).Click;
  PumpMessages(20);
  Require(not LInputEdit.EditControl.Focused,
    'Label do Edit transferiu foco enquanto Loading.');
  LInputEdit.Loading := False;
  TDACThemeManager.SetApplicationMode(dtmLight);
  LInputCombo.ThemeMode := dtmInherit;
  PumpMessages(30);
  RequireComboBoxThemeTokens(LInputCombo, dtmLight, 'global light');
  Form1.GalleryTabs.ActivePage := Form1.tsSelectors;
  PumpMessages(60);
  Require((LInputCombo.ComboControl.Owner = LInputCombo) and
    (LInputCombo.ComboControl.Parent = LInputCombo) and
    LInputCombo.ComboControl.HandleAllocated and
    LInputCombo.ComboControl.Visible and
    IsWindowVisible(LInputCombo.ComboControl.Handle),
    'ComboBox nativo nao possui owner/Parent/HWND visivel no campo ativo.');
  Require(LInputCombo.NativeLabel.FocusControl = nil,
    'Label do Combo publicou FocusControl interno no streaming.');
  LInputCombo.Items.Text := 'Alpha' + sLineBreak + 'Beta' + sLineBreak +
    'Charlie';
  LInputCombo.ItemIndex := 0;
  TControlClickAccess(LInputCombo.NativeLabel).Click;
  PumpMessages(20);
  Require(LInputCombo.ComboControl.Focused,
    'Clique no label do Combo nao levou foco ao HWND nativo.');
  LInputCombo.ComboControl.Perform(WM_CHAR, Ord('B'), 1);
  PumpMessages(20);
  Require((LInputCombo.ItemIndex = 1) and (LInputCombo.Text = 'Beta') and
    (LInputCombo.ComboControl.ItemIndex = 1) and
    not LInputCombo.PopupVisible,
    'Busca incremental fechada nao foi executada pelo TComboBox nativo.');
  LInputCombo.ComboControl.Perform(WM_KEYDOWN, VK_DOWN, 0);
  LInputCombo.ComboControl.Perform(WM_KEYUP, VK_DOWN, 0);
  PumpMessages(20);
  Require((LInputCombo.ItemIndex = 2) and (LInputCombo.Text = 'Charlie') and
    (LInputCombo.ComboControl.ItemIndex = 2) and
    not LInputCombo.PopupVisible,
    'Navegacao fechada por seta nao sincronizou o TComboBox nativo.');
  LInputCombo.ItemIndex := 999;
  Require((LInputCombo.ItemIndex = LInputCombo.Items.Count - 1) and
    (LInputCombo.Text = LInputCombo.Items[LInputCombo.ItemIndex]) and
    (LInputCombo.ComboControl.ItemIndex = LInputCombo.ItemIndex),
    'ItemIndex acima do limite nao foi clampado/sincronizado.');
  LInputCombo.ItemIndex := -99;
  Require((LInputCombo.ItemIndex = -1) and (LInputCombo.Text = '') and
    (LInputCombo.ComboControl.ItemIndex = -1),
    'ItemIndex abaixo de -1 nao foi clampado/limpo.');

  LProbe.ComboDropDownCount := 0;
  LProbe.ComboCloseCount := 0;
  LProbe.ComboReenter := True;
  LInputCombo.OnDropDown := LProbe.OnComboDropDown;
  LInputCombo.OnCloseUp := LProbe.OnComboCloseUp;
  LInputCombo.CloseDropDown;
  LComboPaintBox.Perform(WM_LBUTTONDOWN, MK_LBUTTON, MakeLong(10, 10));
  LComboPaintBox.Perform(WM_LBUTTONUP, 0, MakeLong(10, 10));
  PumpMessages(20);
  Require(LInputCombo.PopupVisible and
    (LProbe.ComboDropDownCount = 1) and (LProbe.ComboCloseCount = 0),
    'Primeiro clique real do owner nao abriu uma unica vez o dropdown.');
  LInputCombo.OpenDropDown;
  Require(LInputCombo.PopupVisible and (LProbe.ComboDropDownCount = 1),
    'OpenDropDown repetido nao foi idempotente.');
  LComboPaintBox.Perform(WM_LBUTTONDOWN, MK_LBUTTON, MakeLong(10, 10));
  LComboPaintBox.Perform(WM_LBUTTONUP, 0, MakeLong(10, 10));
  PumpMessages(20);
  Require(not LInputCombo.PopupVisible and
    (LProbe.ComboDropDownCount = 1) and (LProbe.ComboCloseCount = 1),
    'Segundo clique real do owner reabriu ou notificou duas vezes o dropdown.');
  LInputCombo.CloseDropDown;
  Require(LProbe.ComboCloseCount = 1,
    'CloseDropDown repetido nao foi idempotente.');
  LProbe.ComboReenter := False;

  LInputCombo.ItemIndex := 0;
  LInputCombo.ReadOnly := True;
  TControlClickAccess(LInputCombo.NativeLabel).Click;
  PumpMessages(20);
  Require(LInputCombo.ComboControl.Focused,
    'Combo readonly nao aceitou foco nativo pelo label.');
  LInputCombo.ComboControl.Perform(WM_KEYDOWN, VK_DOWN, 0);
  LInputCombo.ComboControl.Perform(WM_CHAR, Ord('C'), 1);
  LInputCombo.OpenDropDown;
  LInputCombo.SimulateDropDownClick(1);
  LInputCombo.SimulateDropDownKey(VK_DOWN);
  Require(not LInputCombo.PopupVisible and (LInputCombo.ItemIndex = 0) and
    (LInputCombo.Text = LInputCombo.Items[0]),
    'ReadOnly abriu ou alterou o ComboBox.');
  LInputCombo.ReadOnly := False;
  LInputCombo.Loading := True;
  Form1.GalleryTabs.SetFocus;
  TControlClickAccess(LInputCombo.NativeLabel).Click;
  PumpMessages(20);
  Require(not LInputCombo.ComboControl.Focused,
    'Label do Combo transferiu foco enquanto Loading.');
  LInputCombo.OpenDropDown;
  LInputCombo.SimulateDropDownClick(1);
  LInputCombo.SimulateDropDownKey(VK_DOWN);
  Require(not LInputCombo.PopupVisible and (LInputCombo.ItemIndex = 0) and
    (LInputCombo.Text = LInputCombo.Items[0]),
    'Loading abriu ou alterou o ComboBox.');
  LInputCombo.Loading := False;

  LInputCombo.OpenDropDown;
  PumpMessages(20);
  Require(LInputCombo.PopupVisible,
    'TDACComboBox nao abriu o dropdown tokenizado no global light.');
  LInputCombo.ThemeMode := dtmDark;
  PumpMessages(30);
  RequireComboBoxThemeTokens(LInputCombo, dtmDark, 'override local dark');
  Require(not LInputCombo.PopupVisible,
    'Troca de tema local deve fechar o popup anterior do TDACComboBox.');
  LInputCombo.OpenDropDown;
  PumpMessages(20);
  Require(LInputCombo.PopupVisible,
    'TDACComboBox nao abriu o dropdown sob override dark local.');
  LInputCombo.ThemeMode := dtmInherit;
  PumpMessages(30);
  RequireComboBoxThemeTokens(LInputCombo, dtmLight, 'inherit sob global light');
  TDACThemeManager.SetApplicationMode(dtmDark);
  PumpMessages(30);
  RequireComboBoxThemeTokens(LInputCombo, dtmDark,
    'inherit na TabSheet dark sob global dark');
  LInputCombo.OpenDropDown;
  PumpMessages(20);
  Require(LInputCombo.PopupVisible,
    'TDACComboBox nao abriu o dropdown sob global dark herdado.');
  LInputCombo.ItemIndex := 0;
  LInputCombo.SimulateDropDownKey(VK_DOWN);
  PumpMessages(20);
  Require((LInputCombo.ItemIndex = 1) and LInputCombo.PopupVisible,
    'Seta para baixo nao navegou a selecao nativa do dropdown.');
  LInputCombo.SimulateDropDownClick(2);
  PumpMessages(20);
  Require((LInputCombo.ItemIndex = 2) and not LInputCombo.PopupVisible,
    'Clique no item nao selecionou e fechou o dropdown do TDACComboBox.');
  LInputCombo.OpenDropDown;
  LInputCombo.SimulateDropDownKey(VK_ESCAPE);
  PumpMessages(20);
  Require(not LInputCombo.PopupVisible,
    'Escape nao fechou o dropdown do TDACComboBox.');
  LInputCombo.OpenDropDown;
  LInputCombo.SimulateDropDownExternalDeactivate;
  PumpMessages(20);
  Require(not LInputCombo.PopupVisible,
    'Clique externo/deactivate nao fechou o dropdown do TDACComboBox.');
  Form1.GalleryTabs.ActivePage := Form1.tsInputs;
  PumpMessages(60);
  LGalleryHeader := FindTabHeader(Form1.GalleryTabs);
  Require((LGalleryHeader <> nil) and LGalleryHeader.Showing,
    'Header principal da galeria nao esta visivel para validar o viewport.');
  LGalleryHeaderPoint := LGalleryHeader.ClientToScreen(Point(0, 0));
  LTitlePoint := (Form1.FindComponent('lblInputs') as TControl).ClientToScreen(Point(0, 0));
  Require(LTitlePoint.Y >= LGalleryHeaderPoint.Y + LGalleryHeader.Height + 16,
    Format('Titulo de Inputs iniciou sob o header da galeria (titleTop=%d, headerBottom=%d).',
      [LTitlePoint.Y, LGalleryHeaderPoint.Y + LGalleryHeader.Height]));
  Require((LInputEdit.Height = 64) and (LInputButtonEdit.Height = 64) and
    (LInputCombo.Height = 64) and (LDateTime.Height = 64),
    'Inputs rotulados devem compartilhar a altura DFM de 64 px.');
  Require(Abs((LInputEdit.EditControl.Top * 2 +
    LInputEdit.EditControl.Height) - (88 +
    (Round(LEditTokens.InputNativeVerticalOffset) * 2))) <= 1,
    'TDACEdit nao aplicou a centralizacao optica do editor nativo.');
  Require(Abs((LInputButtonEdit.EditControl.Top * 2 +
    LInputButtonEdit.EditControl.Height) - (88 +
    (Round(LButtonEditTokens.InputNativeVerticalOffset) * 2))) <= 1,
    'TDACButtonEdit nao herdou a centralizacao optica do editor nativo.');
  Require(Abs((LInputCombo.ComboControl.Top * 2 + LInputCombo.ComboControl.Height) - 88) <= 1,
    Format('TDACComboBox nao compartilha o centro vertical do contrato de input (top=%d, height=%d).',
      [LInputCombo.ComboControl.Top, LInputCombo.ComboControl.Height]));
  Require(Abs((LDateTime.PickerControl.Top * 2 + LDateTime.PickerControl.Height) - 88) <= 1,
    'TDACDateTimePicker nao compartilha o centro vertical do contrato de input.');
  Require((LInputButtonEdit.ButtonControl.Top =
      Round(LButtonEditTokens.InputChromeTop) +
      Ceil(Max(Max(LButtonEditTokens.InputBorderWidth,
        LButtonEditTokens.InputFocusBorderWidth),
        LButtonEditTokens.ButtonEditButtonInset))) and
    (LInputButtonEdit.ButtonControl.BoundsRect.Right <=
      LInputButtonEdit.Width -
      Ceil(Max(Max(LButtonEditTokens.InputBorderWidth,
        LButtonEditTokens.InputFocusBorderWidth),
        LButtonEditTokens.ButtonEditButtonInset))) and
    (LInputButtonEdit.ButtonControl.BoundsRect.Bottom <=
      Round(LButtonEditTokens.InputChromeTop) +
      Round(LButtonEditTokens.InputMediumChromeHeight) -
      Ceil(Max(Max(LButtonEditTokens.InputBorderWidth,
        LButtonEditTokens.InputFocusBorderWidth),
        LButtonEditTokens.ButtonEditButtonInset))),
    'ButtonEdit cobriu a borda externa do chrome Skia.');
  LButtonEditOriginalText := LInputButtonEdit.Text;
  LButtonEditOriginalButtonCaption := LInputButtonEdit.ButtonCaption;
  LButtonEditOriginalShowIcon := LInputButtonEdit.ShowButtonIcon;
  LButtonEditOriginalTheme := LInputButtonEdit.ThemeMode;
  LButtonEditOriginalVariant := LInputButtonEdit.Variant;
  LInputButtonEdit.Text :=
    'Texto nativo longo que jamais pode aparecer sob a coluna da acao transparente';
  LInputButtonEdit.Variant := mivOutlined;
  LInputButtonEdit.ThemeMode := dtmDark;
  LInputButtonEdit.EditControl.SetFocus;
  PumpMessages(30);
  Require(LInputButtonEdit.EditControl.Focused,
    'ButtonEdit normal dark perdeu o foco do TMaskEdit nativo.');
  RequireButtonEditNativeSeparation(LInputButtonEdit,
    'ButtonEdit normal dark/focused');
  LButtonEditNativeHandle := LInputButtonEdit.EditControl.Handle;
  LButtonEditNativeParent := GetParent(LButtonEditNativeHandle);
  LButtonEditActionHandle := LInputButtonEdit.ButtonControl.Handle;
  Require(GetWindowRect(LButtonEditNativeHandle, LButtonEditNativeRect),
    'ButtonEdit normal dark nao forneceu retangulo nativo.');
  Require(GetWindowRect(LButtonEditActionHandle, LButtonEditActionRect),
    'ButtonEdit normal dark nao forneceu retangulo da action.');
  RequireButtonEditActionSurface(LInputButtonEdit,
    TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.InputBackground,
    'ButtonEdit outlined dark');

  LInputButtonEdit.Enabled := False;
  PumpMessages(30);
  RequireButtonEditActionSurface(LInputButtonEdit,
    TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.InputDisabledBackground,
    'ButtonEdit disabled dark');
  RequireButtonEditNativeSeparation(LInputButtonEdit,
    'ButtonEdit disabled dark');
  Require((LInputButtonEdit.ButtonControl.Handle = LButtonEditActionHandle) and
    (LInputButtonEdit.EditControl.Handle = LButtonEditNativeHandle) and
    GetWindowRect(LButtonEditActionHandle, LButtonEditCurrentActionRect) and
    EqualRect(LButtonEditCurrentActionRect, LButtonEditActionRect) and
    GetWindowRect(LButtonEditNativeHandle, LButtonEditCurrentRect) and
    EqualRect(LButtonEditCurrentRect, LButtonEditNativeRect),
    'Disabled dark alterou HWND/geometria da action ou do editor.');

  LInputButtonEdit.ThemeMode := dtmLight;
  PumpMessages(30);
  RequireButtonEditActionSurface(LInputButtonEdit,
    TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.InputDisabledBackground,
    'ButtonEdit disabled light');
  RequireButtonEditNativeSeparation(LInputButtonEdit,
    'ButtonEdit disabled light');
  Require((LInputButtonEdit.ButtonControl.Handle = LButtonEditActionHandle) and
    (LInputButtonEdit.EditControl.Handle = LButtonEditNativeHandle) and
    GetWindowRect(LButtonEditActionHandle, LButtonEditCurrentActionRect) and
    EqualRect(LButtonEditCurrentActionRect, LButtonEditActionRect) and
    GetWindowRect(LButtonEditNativeHandle, LButtonEditCurrentRect) and
    EqualRect(LButtonEditCurrentRect, LButtonEditNativeRect),
    'Disabled light alterou HWND/geometria da action ou do editor.');

  LInputButtonEdit.Enabled := True;
  LInputButtonEdit.ThemeMode := dtmDark;
  LInputButtonEdit.Variant := mivUnderlined;
  LInputButtonEdit.EditControl.SetFocus;
  PumpMessages(30);
  RequireButtonEditActionSurface(LInputButtonEdit,
    TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.InputUnderlinedBackground,
    'ButtonEdit underlined dark');
  RequireButtonEditNativeSeparation(LInputButtonEdit,
    'ButtonEdit underlined dark');
  Require((LInputButtonEdit.ButtonControl.Handle = LButtonEditActionHandle) and
    (LInputButtonEdit.EditControl.Handle = LButtonEditNativeHandle) and
    LInputButtonEdit.EditControl.Focused and
    GetWindowRect(LButtonEditActionHandle, LButtonEditCurrentActionRect) and
    EqualRect(LButtonEditCurrentActionRect, LButtonEditActionRect) and
    GetWindowRect(LButtonEditNativeHandle, LButtonEditCurrentRect) and
    EqualRect(LButtonEditCurrentRect, LButtonEditNativeRect),
    'Underlined dark alterou foco/handles/geometria da composicao.');

  LInputButtonEdit.Variant := mivOutlined;
  PumpMessages(30);
  RequireButtonEditActionSurface(LInputButtonEdit,
    TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.InputBackground,
    'ButtonEdit outlined dark restaurado');
  LInputButtonEdit.ShowButtonIcon := False;
  LInputButtonEdit.ButtonCaption := '';
  RedrawWindow(LInputButtonEdit.ButtonControl.Handle, nil, 0,
    RDW_INVALIDATE or RDW_ERASE or RDW_FRAME or RDW_ALLCHILDREN or
    RDW_UPDATENOW);
  RequireButtonEditNativeSeparation(LInputButtonEdit,
    'ButtonEdit action repaint vazio');
  Require(LInputButtonEdit.ButtonControl.Handle = LButtonEditActionHandle,
    'Caption vazio recriou o HWND da action.');
  LInputButtonEdit.ButtonCaption := 'OK';
  RedrawWindow(LInputButtonEdit.ButtonControl.Handle, nil, 0,
    RDW_INVALIDATE or RDW_ERASE or RDW_FRAME or RDW_ALLCHILDREN or
    RDW_UPDATENOW);
  RequireButtonEditNativeSeparation(LInputButtonEdit,
    'ButtonEdit action repaint curto');
  Require(LInputButtonEdit.ButtonControl.Handle = LButtonEditActionHandle,
    'Caption curto recriou o HWND da action.');
  LInputButtonEdit.ButtonCaption :=
    'Selecionar registro relacionado com uma legenda de acao longa';
  RedrawWindow(LInputButtonEdit.ButtonControl.Handle, nil, 0,
    RDW_INVALIDATE or RDW_ERASE or RDW_FRAME or RDW_ALLCHILDREN or
    RDW_UPDATENOW);
  RequireButtonEditNativeSeparation(LInputButtonEdit,
    'ButtonEdit action repaint longo');
  Require((LInputButtonEdit.ButtonControl.Handle = LButtonEditActionHandle) and
    (LInputButtonEdit.EditControl.Handle = LButtonEditNativeHandle) and
    GetWindowRect(LButtonEditNativeHandle, LButtonEditCurrentRect) and
    EqualRect(LButtonEditCurrentRect, LButtonEditNativeRect),
    'Caption longo alterou HWND/geometria nativa da action ou do editor.');
  LInputButtonEdit.ButtonCaption := LButtonEditOriginalButtonCaption;
  LInputButtonEdit.ShowButtonIcon := LButtonEditOriginalShowIcon;
  InvalidateRect(LButtonEditNativeHandle, nil, True);
  UpdateWindow(LButtonEditNativeHandle);
  RedrawWindow(LInputButtonEdit.Handle, nil, 0,
    RDW_INVALIDATE or RDW_ERASE or RDW_FRAME or RDW_ALLCHILDREN or
    RDW_UPDATENOW);
  RequireButtonEditNativeSeparation(LInputButtonEdit,
    'ButtonEdit normal dark/repaint adversarial');
  Require((LInputButtonEdit.EditControl.Handle = LButtonEditNativeHandle) and
    (GetParent(LButtonEditNativeHandle) = LButtonEditNativeParent) and
    GetWindowRect(LButtonEditNativeHandle, LButtonEditCurrentRect) and
    EqualRect(LButtonEditCurrentRect, LButtonEditNativeRect),
    'Repaint adversarial recriou/reparentou/moveu o TMaskEdit normal dark.');
  LInputButtonEdit.ThemeMode := dtmLight;
  PumpMessages(30);
  RequireButtonEditActionSurface(LInputButtonEdit,
    TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.InputBackground,
    'ButtonEdit outlined light');
  RequireButtonEditNativeSeparation(LInputButtonEdit,
    'ButtonEdit normal light/focused');
  Require(LInputButtonEdit.EditControl.Focused and
    (LInputButtonEdit.EditControl.Handle = LButtonEditNativeHandle) and
    (GetParent(LButtonEditNativeHandle) = LButtonEditNativeParent) and
    GetWindowRect(LButtonEditNativeHandle, LButtonEditCurrentRect) and
    EqualRect(LButtonEditCurrentRect, LButtonEditNativeRect),
    'Dark para light alterou foco/handle/parent/retangulo do TMaskEdit normal.');
  LInputButtonEdit.ThemeMode := dtmDark;
  PumpMessages(30);
  RequireButtonEditActionSurface(LInputButtonEdit,
    TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.InputBackground,
    'ButtonEdit outlined dark apos light');
  RedrawWindow(LInputButtonEdit.Handle, nil, 0,
    RDW_INVALIDATE or RDW_ERASE or RDW_FRAME or RDW_ALLCHILDREN or
    RDW_UPDATENOW);
  RequireButtonEditNativeSeparation(LInputButtonEdit,
    'ButtonEdit normal dark restaurado');
  Require(LInputButtonEdit.EditControl.Focused and
    (LInputButtonEdit.EditControl.Handle = LButtonEditNativeHandle) and
    (GetParent(LButtonEditNativeHandle) = LButtonEditNativeParent) and
    GetWindowRect(LButtonEditNativeHandle, LButtonEditCurrentRect) and
    EqualRect(LButtonEditCurrentRect, LButtonEditNativeRect),
    'Light para dark alterou foco/handle/parent/retangulo do TMaskEdit normal.');

  LInputButtonEdit.Variant := mivCompact;
  LInputButtonEdit.ThemeMode := dtmDark;
  LInputButtonEdit.EditControl.SetFocus;
  PumpMessages(30);
  RequireButtonEditActionSurface(LInputButtonEdit,
    TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.InputBackground,
    'ButtonEdit compact dark');
  RequireButtonEditNativeSeparation(LInputButtonEdit,
    'ButtonEdit compact dark/focused');
  LButtonEditNativeHandle := LInputButtonEdit.EditControl.Handle;
  LButtonEditNativeParent := GetParent(LButtonEditNativeHandle);
  Require(GetWindowRect(LButtonEditNativeHandle, LButtonEditNativeRect),
    'ButtonEdit compact dark nao forneceu retangulo nativo.');
  LInputButtonEdit.ThemeMode := dtmLight;
  PumpMessages(30);
  RequireButtonEditActionSurface(LInputButtonEdit,
    TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.InputBackground,
    'ButtonEdit compact light');
  InvalidateRect(LButtonEditNativeHandle, nil, True);
  UpdateWindow(LButtonEditNativeHandle);
  RedrawWindow(LInputButtonEdit.Handle, nil, 0,
    RDW_INVALIDATE or RDW_ERASE or RDW_FRAME or RDW_ALLCHILDREN or
    RDW_UPDATENOW);
  RequireButtonEditNativeSeparation(LInputButtonEdit,
    'ButtonEdit compact light/repaint adversarial');
  Require(LInputButtonEdit.EditControl.Focused and
    (LInputButtonEdit.EditControl.Handle = LButtonEditNativeHandle) and
    (GetParent(LButtonEditNativeHandle) = LButtonEditNativeParent) and
    GetWindowRect(LButtonEditNativeHandle, LButtonEditCurrentRect) and
    EqualRect(LButtonEditCurrentRect, LButtonEditNativeRect),
    'Dark para light alterou foco/handle/parent/retangulo do TMaskEdit compact.');
  LInputButtonEdit.ThemeMode := dtmDark;
  PumpMessages(30);
  RequireButtonEditActionSurface(LInputButtonEdit,
    TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.InputBackground,
    'ButtonEdit compact dark restaurado');
  RequireButtonEditNativeSeparation(LInputButtonEdit,
    'ButtonEdit compact dark restaurado');
  Require(LInputButtonEdit.EditControl.Focused and
    (LInputButtonEdit.EditControl.Handle = LButtonEditNativeHandle) and
    (GetParent(LButtonEditNativeHandle) = LButtonEditNativeParent) and
    GetWindowRect(LButtonEditNativeHandle, LButtonEditCurrentRect) and
    EqualRect(LButtonEditCurrentRect, LButtonEditNativeRect),
    'Light para dark alterou foco/handle/parent/retangulo do TMaskEdit compact.');
  LInputButtonEdit.Variant := LButtonEditOriginalVariant;
  LInputButtonEdit.ThemeMode := LButtonEditOriginalTheme;
  LInputButtonEdit.Text := LButtonEditOriginalText;
  PumpMessages(30);
  RequireButtonEditNativeSeparation(LInputButtonEdit,
    'ButtonEdit restaurado');
  LButtonEditRegion := CreateRectRgn(0, 0, 0, 0);
  try
    LButtonEditRegionResult := GetWindowRgn(
      LInputButtonEdit.ButtonControl.Handle, LButtonEditRegion);
    Require((LButtonEditRegionResult = COMPLEXREGION) and
      (LInputButtonEdit.CornerRadius =
        Round(LButtonEditTokens.ButtonEditDefaultCornerRadius)) and
      (LInputButtonEdit.ButtonControl.CornerRadius =
        Round(LButtonEditTokens.ButtonEditButtonCornerRadius)) and
      PtInRegion(LButtonEditRegion,
        LInputButtonEdit.ButtonControl.Width div 2,
        LInputButtonEdit.ButtonControl.Height div 2) and
      PtInRegion(LButtonEditRegion, 0, 0) and
      PtInRegion(LButtonEditRegion, 0,
        LInputButtonEdit.ButtonControl.Height - 1) and
      PtInRegion(LButtonEditRegion,
        LInputButtonEdit.ButtonControl.Width - 2,
        LInputButtonEdit.ButtonControl.Height div 2) and
      not PtInRegion(LButtonEditRegion,
        LInputButtonEdit.ButtonControl.Width - 1, 0) and
      not PtInRegion(LButtonEditRegion,
        LInputButtonEdit.ButtonControl.Width - 1,
        LInputButtonEdit.ButtonControl.Height - 1),
      'ButtonEdit action HWND nao recortou apenas os cantos direitos com o raio externo 8.');
  finally
    DeleteObject(LButtonEditRegion);
  end;
  Require((LDateTime.PickerControl.Top >=
      Round(LDateTimeTokens.DateTimeChromeTop)) and
    (LDateTime.PickerControl.BoundsRect.Bottom <=
      Round(LDateTimeTokens.DateTimeChromeTop +
        LDateTimeTokens.DateTimeChromeHeight)),
    Format('DateTimePicker nativo escapou do chrome Skia (picker=%d..%d chrome=%d..%d).',
      [LDateTime.PickerControl.Top,
       LDateTime.PickerControl.BoundsRect.Bottom,
       Round(LDateTimeTokens.DateTimeChromeTop),
       Round(LDateTimeTokens.DateTimeChromeTop +
         LDateTimeTokens.DateTimeChromeHeight)]));
  FillChar(LDateTimeRegion, SizeOf(LDateTimeRegion), 0);
  LDateTimeRegionHandle := CreateRectRgn(0, 0, 0, 0);
  try
    LDateTimeRegionResult := GetWindowRgn(LDateTime.PickerControl.Handle,
      LDateTimeRegionHandle);
    LDateTimeRegionBoxResult := GetRgnBox(LDateTimeRegionHandle,
      LDateTimeRegion);
    Require((LDateTimeRegionResult = SIMPLEREGION) and
      (LDateTimeRegionBoxResult = SIMPLEREGION) and
      (LDateTimeRegion.Left = 0) and
      (LDateTimeRegion.Top =
        Round(LDateTimeTokens.DateTimeNativeVerticalClipInset)) and
      (LDateTimeRegion.Right = LDateTime.PickerControl.Width -
        Round(LDateTimeTokens.DateTimeNativeDropdownClipWidth)) and
      (LDateTimeRegion.Bottom = LDateTime.PickerControl.Height -
        Round(LDateTimeTokens.DateTimeNativeVerticalClipInset)),
      Format('DateTimePicker deixou o dropdown/borda nativos expostos sobre o Skia (result=%d boxResult=%d rect=%d,%d..%d,%d picker=%d,%d clip=%d).',
        [LDateTimeRegionResult, LDateTimeRegionBoxResult,
         LDateTimeRegion.Left, LDateTimeRegion.Top, LDateTimeRegion.Right,
         LDateTimeRegion.Bottom, LDateTime.PickerControl.Width,
         LDateTime.PickerControl.Height,
         Round(LDateTimeTokens.DateTimeNativeDropdownClipWidth)]));
  finally
    DeleteObject(LDateTimeRegionHandle);
  end;
  LDateTimePickerCount := 0;
  FillChar(LDateTimePickerClass, SizeOf(LDateTimePickerClass), 0);
  GetClassName(LDateTime.PickerControl.Handle, LDateTimePickerClass,
    Length(LDateTimePickerClass));
  LDateTimeChildHwnd := GetWindow(LDateTime.Handle, GW_CHILD);
  while LDateTimeChildHwnd <> 0 do
  begin
    FillChar(LDateTimeChildClass, SizeOf(LDateTimeChildClass), 0);
    GetClassName(LDateTimeChildHwnd, LDateTimeChildClass,
      Length(LDateTimeChildClass));
    if SameText(string(LDateTimeChildClass),
      string(LDateTimePickerClass)) then
      Inc(LDateTimePickerCount);
    LDateTimeChildHwnd := GetWindow(LDateTimeChildHwnd, GW_HWNDNEXT);
  end;
  Require((GetParent(LDateTime.PickerControl.Handle) = LDateTime.Handle) and
    (LDateTimePickerCount = 1),
    Format('DateTimePicker deve manter um SysDateTimePick32 no host (parent=%d expected=%d count=%d).',
      [GetParent(LDateTime.PickerControl.Handle), LDateTime.Handle,
       LDateTimePickerCount]));
  Require(GetWindowRect(LDateTime.PickerControl.Handle,
    LDateTimeNativeScreenRect),
    'DateTimePicker nativo nao forneceu retangulo de tela.');
  LDateTimeExpectedTopLeft := LDateTime.ClientToScreen(Point(
    LDateTime.PickerControl.Left, LDateTime.PickerControl.Top));
  LDateTimeExpectedBottomRight := LDateTime.ClientToScreen(Point(
    LDateTime.PickerControl.BoundsRect.Right,
    LDateTime.PickerControl.BoundsRect.Bottom));
  Require((LDateTimeNativeScreenRect.Left = LDateTimeExpectedTopLeft.X) and
    (LDateTimeNativeScreenRect.Top = LDateTimeExpectedTopLeft.Y) and
    (LDateTimeNativeScreenRect.Right = LDateTimeExpectedBottomRight.X) and
    (LDateTimeNativeScreenRect.Bottom = LDateTimeExpectedBottomRight.Y),
    Format('SysDateTimePick32 ficou em coordenada antiga (actual=%d,%d..%d,%d expected=%d,%d..%d,%d).',
      [LDateTimeNativeScreenRect.Left, LDateTimeNativeScreenRect.Top,
       LDateTimeNativeScreenRect.Right, LDateTimeNativeScreenRect.Bottom,
       LDateTimeExpectedTopLeft.X, LDateTimeExpectedTopLeft.Y,
       LDateTimeExpectedBottomRight.X, LDateTimeExpectedBottomRight.Y]));
  Require(LInputEdit.NativeLabel.Visible and
    Assigned(LInputButtonEdit.NativeLabel) and
    LInputButtonEdit.NativeLabel.Visible and
    LInputMemo.NativeLabel.Visible and LInputCombo.NativeLabel.Visible and
    LDateTime.NativeLabel.Visible,
    'Os cinco campos devem expor caption por TLabel nativo.');
  Require((LInputEdit.EditControl.Font.Size = TDACComponentStyle.InputTextSize) and
    (LInputButtonEdit.EditControl.Font.Size = TDACComponentStyle.InputTextSize) and
    (LInputCombo.ComboControl.Font.Size = TDACComponentStyle.InputGridTextSize) and
    (LDateTime.PickerControl.Font.Size = TDACComponentStyle.InputTextSize) and
    (LInputMemo.MemoControl.Font.Size = TDACComponentStyle.InputSmallTextSize) and
    (LInputEdit.NativeLabel.Font.Size = 9) and
    (LInputButtonEdit.NativeLabel.Font.Size = 9) and
    (LInputMemo.NativeLabel.Font.Size = 9) and
    (LInputCombo.NativeLabel.Font.Size = 9) and
    (LDateTime.NativeLabel.Font.Size = 9),
    'Editores perderam tipografia propria ou labels divergiram de Inter 9 pt.');
  Require((LInputEdit.NativeLabel.Top + LInputEdit.NativeLabel.Height <=
    LInputEdit.EditControl.Top) and
    (LInputCombo.NativeLabel.Top + LInputCombo.NativeLabel.Height <=
    LInputCombo.ComboControl.Top) and
    (LDateTime.NativeLabel.Top + LDateTime.NativeLabel.Height <=
    LDateTime.PickerControl.Top),
    'Label nativo invadiu a faixa editavel de um input composto.');
  Require(LInputEdit.ControlAtPos(Point(4, 8), False, False) =
    LInputEdit.NativeLabel, 'TDACEdit cobriu o caption nativo.');
  Require(LInputCombo.ControlAtPos(Point(4, 8), False, False) =
    LInputCombo.NativeLabel, 'TDACComboBox cobriu o caption nativo.');
  Require(LDateTime.ControlAtPos(Point(4, 8), False, False) =
    LDateTime.NativeLabel, 'TDACDateTimePicker cobriu o caption nativo.');
  Require(not RectanglesOverlap(LInputEdit.BoundsRect,
    LInputMemo.BoundsRect) and
    not RectanglesOverlap(LInputButtonEdit.BoundsRect,
      LInputMemo.BoundsRect),
    'Matriz declarativa de Inputs sobrepos as familias Edit/ButtonEdit e Memo.');
  Require((LInputMemo.LabelText = 'Memo / Default') and
    LInputMemo.MemoControl.Visible and
    (LInputMemo.MemoControl.Top >= Round(LEditTokens.FieldChromeTop)),
    'Memo deve apresentar uma legenda nativa e reservar seu chrome acima do texto.');
  LButtonLabelPoint := LInputMemo.NativeLabel.ClientToScreen(
    Point(0, LInputMemo.NativeLabel.Height));
  LMemoTextPoint := LInputMemo.MemoControl.ClientToScreen(Point(0, 0));
  Require(LButtonLabelPoint.Y <= LMemoTextPoint.Y,
    Format('Legenda e texto nativos do Memo ocupam a mesma faixa visual (labelBottom=%d, memoTop=%d).',
      [LButtonLabelPoint.Y, LMemoTextPoint.Y]));
  // Exercise a real move/restore through the same VCL path used by responsive
  // layout; the old and new parent regions must both be repainted.
  LInputButtonEdit.SetBounds(LInputButtonEdit.Left, LInputButtonEdit.Top + 4,
    LInputButtonEdit.Width, LInputButtonEdit.Height);
  PumpMessages(20);
  LInputButtonEdit.SetBounds(LInputButtonEdit.Left, LInputButtonEdit.Top - 4,
    LInputButtonEdit.Width, LInputButtonEdit.Height);
  PumpMessages(20);
  LButtonLabelPoint := LInputMemo.NativeLabel.ClientToScreen(
    Point(0, LInputMemo.NativeLabel.Height));
  LMemoTextPoint := LInputMemo.MemoControl.ClientToScreen(Point(0, 0));
  Require(LButtonLabelPoint.Y <= LMemoTextPoint.Y,
    'Reposicionamento externo invadiu a faixa local da legenda do Memo.');
  // Native child HWNDs remain the focus surface: click enters the embedded
  // edit and the normal dialog Tab path advances to the memo, unambiguously.
  LInputButtonEdit.EditControl.Perform(WM_LBUTTONDOWN, MK_LBUTTON,
    MakeLong(8, 8));
  LInputButtonEdit.EditControl.Perform(WM_LBUTTONUP, 0, MakeLong(8, 8));
  PumpMessages(20);
  Require(LInputButtonEdit.EditControl.Focused,
    'Clique no ButtonEdit nao transferiu foco para o editor nativo.');
  LInputEdit.EditKind := mekDate;
  Require(LInputEdit.EditControl.EditMask = '!99/99/9999;1;_',
    'EditMask de data nao chegou ao TMaskEdit nativo.');
  LInputEdit.EditControl.Text := '01012026';
  Require(LInputEdit.EditControl.Text <> '',
    'Mascara nativa nao aceitou entrada real no TDACEdit.');
  LInputEdit.EditKind := mekText;
  LInputButtonEdit.OnButtonClick := LProbe.OnButtonClick;
  LButtonClickBefore := ClickCount;
  LInputButtonEdit.ButtonControl.Click;
  Require(ClickCount = LButtonClickBefore + 1,
    'Clique do botao interno nao chegou ao OnButtonClick do ButtonEdit.');
  SendKey(LInputButtonEdit.EditControl, VK_END);
  Require(LInputButtonEdit.EditControl.Focused,
    'Teclado no ButtonEdit perdeu o foco/caret do editor nativo.');
  LInputEditReadOnly.EditControl.SetFocus;
  PumpMessages(20);
  TFormAccess(Form1).FocusNext(LInputEditReadOnly.EditControl);
  PumpMessages(20);
  Require(LInputMemo.MemoControl.Focused,
    Format('Tab apos o ultimo Edit nao transferiu foco para o primeiro Memo (formHasActive=%s, editFocused=%s, memoFocused=%s).',
      [BoolToStr(Form1.ActiveControl <> nil, True),
       BoolToStr(LInputEditReadOnly.EditControl.Focused, True),
       BoolToStr(LInputMemo.MemoControl.Focused, True)]));
  LInputMemoReadOnly.MemoControl.SetFocus;
  PumpMessages(20);
  TFormAccess(Form1).FocusNext(LInputMemoReadOnly.MemoControl);
  PumpMessages(20);
  Require(LInputButtonEdit.EditControl.Focused,
    Format('Tab apos o ultimo Memo nao transferiu foco para o primeiro ButtonEdit (formHasActive=%s, memoFocused=%s, buttonEditFocused=%s).',
      [BoolToStr(Form1.ActiveControl <> nil, True),
       BoolToStr(LInputMemoReadOnly.MemoControl.Focused, True),
       BoolToStr(LInputButtonEdit.EditControl.Focused, True)]));
  TDACThemeManager.SetApplicationMode(dtmLight);
  LInputMemo.ThemeMode := dtmDark;
  PumpMessages(30);
  Require((LInputMemo.MemoControl.Color = TDACComponentColors.ToVclColor(
      TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.MemoBackground)) and
    (LInputMemo.MemoControl.Font.Color = TDACComponentColors.ToVclColor(
      TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.MemoText)) and
    SameText(LInputMemo.MemoControl.Font.Name, TDACComponentStyle.FontFamily) and
    (LInputMemo.MemoControl.Font.Size = Round(
      TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.MemoTextSize)),
    'Memo nao aplicou o override local dark no HWND nativo.');
  LInputMemo.ThemeMode := dtmInherit;
  PumpMessages(30);
  Require((LInputMemo.MemoControl.Color = TDACComponentColors.ToVclColor(
      TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.MemoBackground)) and
    (LInputMemo.MemoControl.Font.Color = TDACComponentColors.ToVclColor(
      TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.MemoText)),
    'Memo inherit nao retornou ao global light.');
  TDACThemeManager.SetApplicationMode(dtmDark);
  PumpMessages(30);
  Require((LInputMemo.MemoControl.Color = TDACComponentColors.ToVclColor(
      TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.MemoBackground)) and
    (LInputMemo.MemoControl.Font.Color = TDACComponentColors.ToVclColor(
      TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.MemoText)),
    'Memo inherit nao respeitou a superficie dark da TabSheet.');
  LInputMemo.MemoControl.ReadOnly := False;
  LInputMemo.MemoControl.SetFocus;
  LInputMemo.MemoControl.SelStart := Length(LInputMemo.MemoControl.Text);
  LInputMemo.MemoControl.Perform(WM_CHAR, Ord('~'), 0);
  PumpMessages(20);
  Require(EndsText('~', LInputMemo.MemoControl.Text),
    'Digitacao nao permaneceu no TMemo nativo apos a troca de tema.');
  LInputMemo.MemoControl.SelectAll;
  Require(LInputMemo.MemoControl.SelLength = Length(LInputMemo.MemoControl.Text),
    'Selecao nativa do TMemo foi perdida apos a troca de tema.');
  RequirePhysicalNestedWheelRouting(Form1, LInputsScroll, LInputMemo,
    LInputEdit.EditControl);
  // A deferred/stale relayout must never repaint the same native controls at
  // a second offset after focus or the last queued page activation.
  LInputLayoutRevision := Form1.LayoutRevision;
  LInputEditBounds := LInputEdit.BoundsRect;
  LInputButtonEditBounds := LInputButtonEdit.BoundsRect;
  LInputMemoBounds := LInputMemo.BoundsRect;
  PumpMessages(120);
  Require(Form1.LayoutRevision = LInputLayoutRevision,
    'Uma revisao de layout atrasada executou apos o foco de Inputs.');
  Require(EqualRect(LInputEdit.BoundsRect, LInputEditBounds) and
    EqualRect(LInputButtonEdit.BoundsRect, LInputButtonEditBounds) and
    EqualRect(LInputMemo.BoundsRect, LInputMemoBounds),
    'Um segundo relayout alterou a geometria de Inputs apos o frame estabilizado.');
  RequireNativeChildInside(LInputEdit, LInputEdit.EditControl, 'TDACEdit');
  RequireNativeChildInside(LInputButtonEdit, LInputButtonEdit.EditControl,
    'TDACButtonEdit');
  RequireNativeChildInside(LInputMemo, LInputMemo.MemoControl, 'TDACMemo');
  Require(LDateTime.Left >= LInputCombo.Left + LInputCombo.Width + 56,
    'DateTimePicker invadiu a margem horizontal do grupo ComboBox.');
  Require((Form1.FindComponent('demoNavigationTitle') as TDACSystemText).Height >= 28,
    'Suite DAC nao recebeu altura suficiente para evitar clipping no cabecalho.');

  LDashboardButton := Form1.FindComponent('demoNavDashboard') as TDACButton;
  LDashboardScroll := Form1.FindComponent('scrDashboard') as TDACScrollContainer;
  LDashboardCard := Form1.FindComponent('dashKpi1') as TDACSummaryCard;
  LDashboardPanel := Form1.FindComponent('dashAgenda') as TDACContainer;
  LDashboardText := Form1.FindComponent('dashWelcomeTitle') as TDACSystemText;
  LDashboardTitleText := LDashboardText;
  LDashboardNameText := Form1.FindComponent('dashWelcomeName') as TDACSystemText;
  LDashboardSubtitleText := Form1.FindComponent('dashWelcomeSubtitle') as TDACSystemText;
  LDashboardDateText := Form1.FindComponent('dashDateValue') as TDACSystemText;
  LDashboardQuickGrid := Form1.FindComponent('dashQuickActionsGrid') as TDACGridContainer;
  LNavigation := Form1.FindComponent('demoNavigation') as TDACScrollContainer;
  RequireGalleryNavigationCoherence;
  Require(Assigned(LDashboardButton.OnClick),
    'Navegacao do Dashboard nao recebeu acao.');
  LDashboardButton.OnClick(LDashboardButton);
  PumpMessages(40);
  Require(Form1.GalleryTabs.ActivePage =
    (Form1.FindComponent('tsDashboard') as TTabSheet),
    'Menu interno nao abriu o Dashboard.');
  Require(LDashboardButton.Kind = mbkPrimary,
    'Menu interno nao refletiu o Dashboard ativo.');
  Require(LNavigation.Visible and
    (Form1.GalleryTabs.Left >= LNavigation.Width),
    'Dashboard deve permanecer na navegacao normal da galeria.');
  Require(LDashboardScroll.Parent = Form1.tsDashboard,
    'Dashboard nao pode reparentear seu viewport para o Form.');
  Require(LDashboardPanel.Parent = LDashboardScroll,
    'Conteudo agricola deve permanecer no scrDashboard da aba normal.');
  Require((LDashboardCard.Width > 0) and (LDashboardCard.Height > 0) and
    (LDashboardCard.Appearance = mcsaDashboard) and
    (LDashboardCard.CornerRadius = Round(
      TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.
        SummaryCardDashboardRadius)) and
    (LDashboardCard.BackgroundColor =
      TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.
        SummaryCardDashboardBackground),
    'KPI do Dashboard nao preservou a surface translucida tokenizada.');
  Require((LDashboardText.Text = 'Bem-vindo,') and
    (LDashboardText.Role = mtrDisplay) and
    (LDashboardText.Tone = mttPrimary) and
    (LDashboardText.FontSize = Round(
      TDACComponentStyle.Resolve(dtmDark).Tokens.Typography.DisplaySize)) and
    (LDashboardText.TextColor =
      TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.SystemTextPrimary),
    'Identidade semantica do boas-vindas nao foi materializada no DFM.');
  Require((LDashboardText.Width >= 220) and
    (LDashboardNameText.Left >= LDashboardText.Left + LDashboardText.Width + 8),
    'Cabecalho desktop nao reservou largura fisica para a saudacao completa.');
  Require((LDashboardPanel.Appearance = mcaDarkPanel) and
    (LDashboardPanel.CornerRadius = Round(
      TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.
        ContainerDarkPanelRadius)) and
    (LDashboardPanel.BackgroundColor =
      TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.
        ContainerDarkBackground) and
    (LDashboardModule.Appearance = mcaDarkCard) and
    (LDashboardChart.Appearance = mchaDashboard) and
    (LDashboardScroll.Appearance = mscaViewport) and
    (LDashboardScroll.ThemeMode = dtmInherit) and
    (LDashboardQuickGrid.Layout = mgclActionTiles) and
    (LDashboardQuickGrid.Appearance = mgcaTransparent),
    'Presets da surface Dashboard nao foram materializados no DFM.');
  LThemeBeforeOverrideCheck := TDACThemeManager.ApplicationMode;
  TDACThemeManager.SetApplicationMode(dtmLight);
  PumpMessages(30);
  Require((TTabSheetAccess(Form1.tsDashboard).Color =
      TDACComponentColors.ToVclColor(
        TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.
          ContainerSuiteBackground)) and
    (LDashboardScroll.BackgroundColor =
      TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.
        ScrollContainerViewportBackground) and
    (LDashboardPanel.BackgroundColor =
      TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.
        ContainerDarkBackground) and
    (LDashboardPanel.TitleColor =
      TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.ContainerDarkTitle) and
    (LDashboardModule.BackgroundColor =
      TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.
        ContainerDarkCardBackground) and
    (LDashboardCard.BackgroundColor =
      TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.
        SummaryCardDashboardBackground) and
    (LDashboardChart.BackgroundColor =
      TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.
        ChartDashboardBackground) and
    (LDashboardText.TextColor =
      TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.SystemTextPrimary) and
    (LDashboardText.Role = mtrDisplay) and (LDashboardText.Tone = mttPrimary),
    Format('Tema global light nao propagou os tokens Light pela arvore do Dashboard. ' +
      'page=%s/%s scroll=%s/%s panelBg=%s/%s panelTitle=%s/%s ' +
      'card=%s/%s chart=%s/%s module=%s/%s text=%s/%s',
      [IntToHex(Cardinal(TTabSheetAccess(Form1.tsDashboard).Color), 8),
       IntToHex(Cardinal(TDACComponentColors.ToVclColor(
         TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.
           ContainerSuiteBackground)), 8),
       IntToHex(Cardinal(LDashboardScroll.BackgroundColor), 8),
       IntToHex(Cardinal(TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.
         ScrollContainerViewportBackground), 8),
       IntToHex(Cardinal(LDashboardPanel.BackgroundColor), 8),
       IntToHex(Cardinal(TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.
         ContainerDarkBackground), 8),
       IntToHex(Cardinal(LDashboardPanel.TitleColor), 8),
       IntToHex(Cardinal(TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.
         ContainerDarkTitle), 8),
       IntToHex(Cardinal(LDashboardCard.BackgroundColor), 8),
       IntToHex(Cardinal(TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.
         SummaryCardDashboardBackground), 8),
       IntToHex(Cardinal(LDashboardChart.BackgroundColor), 8),
       IntToHex(Cardinal(TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.
         ChartDashboardBackground), 8),
       IntToHex(Cardinal(LDashboardModule.BackgroundColor), 8),
       IntToHex(Cardinal(TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.
         ContainerDarkCardBackground), 8),
       IntToHex(Cardinal(LDashboardText.TextColor), 8),
       IntToHex(Cardinal(TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.
         SystemTextPrimary), 8)]));
  TDACThemeManager.SetApplicationMode(dtmDark);
  PumpMessages(30);
  Require((TTabSheetAccess(Form1.tsDashboard).Color =
      TDACComponentColors.ToVclColor(
        TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.
          ContainerSuiteBackground)) and
    (LDashboardScroll.BackgroundColor =
      TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.
        ScrollContainerViewportBackground) and
    (LDashboardPanel.BackgroundColor =
      TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.
        ContainerDarkBackground) and
    (LDashboardPanel.TitleColor =
      TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.ContainerDarkTitle) and
    (LDashboardModule.BackgroundColor =
      TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.
        ContainerDarkCardBackground) and
    (LDashboardCard.BackgroundColor =
      TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.
        SummaryCardDashboardBackground) and
    (LDashboardChart.BackgroundColor =
      TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.
        ChartDashboardBackground) and
    (LDashboardText.TextColor =
      TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.SystemTextPrimary),
    'Retorno ao tema dark nao reverteu os tokens do Dashboard.');
  TDACThemeManager.SetApplicationMode(LThemeBeforeOverrideCheck);
  PumpMessages(30);
  Require((Cardinal(LDashboardScroll.BackgroundColor) = Cardinal($FF08130D)) and
    (LDashboardScroll.VertScrollBar.Range >= LDashboardScroll.ClientHeight),
    'Dashboard nao recebeu canvas agricola rolavel.');
  Require((LDashboardQuickGrid.BackgroundColor = TAlphaColor($00000000)) and
    (LDashboardQuickGrid.BorderColor = TAlphaColor($00000000)),
    'A grade de acoes rapidas deve permanecer transparente sobre a surface dark.');
  Require((TDACComponentColors.ContrastRatio(LDashboardText.TextColor,
      LDashboardScroll.BackgroundColor) >= 4.5) and
    (TDACComponentColors.ContrastRatio(LDashboardNameText.TextColor,
      LDashboardScroll.BackgroundColor) >= 4.5) and
    (TDACComponentColors.ContrastRatio(LDashboardPanel.TitleColor,
      LDashboardPanel.BackgroundColor) >= 4.5),
    'Texto/label do Dashboard perdeu contraste AA contra sua surface.');
  Require((LDashboardText.MeasureTextHeight(LDashboardText.Text,
      LDashboardText.Width) <= LDashboardText.Height) and
    (LDashboardNameText.MeasureTextHeight(LDashboardNameText.Text,
      LDashboardNameText.Width) <= LDashboardNameText.Height) and
    (LDashboardSubtitleText.MeasureTextHeight(LDashboardSubtitleText.Text,
      LDashboardSubtitleText.Width) <= LDashboardSubtitleText.Height),
    Format('Texto do Dashboard esta cortado (title=%d/%d name=%d/%d subtitle=%d/%d).',
      [LDashboardText.MeasureTextHeight(LDashboardText.Text,
         LDashboardText.Width), LDashboardText.Height,
       LDashboardNameText.MeasureTextHeight(LDashboardNameText.Text,
         LDashboardNameText.Width), LDashboardNameText.Height,
       LDashboardSubtitleText.MeasureTextHeight(LDashboardSubtitleText.Text,
         LDashboardSubtitleText.Width), LDashboardSubtitleText.Height]));
  LDashboardQuickAction := Form1.FindComponent('dashQuickAction1') as TDACButton;
  Require((TTabSheetAccess(Form1.tsDashboard).Color =
      TDACComponentColors.ToVclColor(
        TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.
          ContainerSuiteBackground)) and
    (TDACComponentStyle.ResolveForSurface(LDashboardQuickAction, dtmInherit).
      Tokens.Controls.ButtonFallbackBackground =
      TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.ButtonFallbackBackground),
    'A TabSheet do Dashboard ou Quick Actions ignorou a surface dark mais proxima.');
  LDashboardQuickAction.ThemeMode := dtmLight;
  Require(TDACComponentStyle.ResolveForSurface(LDashboardQuickAction, dtmLight).
    Tokens.Controls.ButtonFallbackBackground =
    TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.ButtonFallbackBackground,
    'Override explicito precisa vencer a surface dark do Dashboard.');
  LDashboardQuickAction.ThemeMode := dtmInherit;
  Form1.SetBounds(Form1.Left, Form1.Top, 520, 560);
  PumpMessages(100);
  Require(LDashboardNameText.Top >= LDashboardTitleText.Top +
    LDashboardTitleText.Height,
    'Dashboard compacto sobrepoe a saudacao e o nome do usuario.');
  Require(LDashboardSubtitleText.Top >= LDashboardNameText.Top +
    LDashboardNameText.Height,
    'Dashboard compacto sobrepoe nome e subtitulo.');
  Require((Form1.FindComponent('dashDateSummary') as TDACContainer).Top +
    LDashboardDateText.Top >= LDashboardSubtitleText.Top +
    LDashboardSubtitleText.Height,
    'Dashboard compacto sobrepoe data e cabecalho de boas-vindas.');
  Require((LDashboardDateText.Left >= 0) and
    (LDashboardDateText.Left + LDashboardDateText.Width <=
      (Form1.FindComponent('dashDateSummary') as TDACContainer).Width),
    'Valor da data excede o card compacto.');
  Form1.SetBounds(Form1.Left, Form1.Top, 1200, 760);
  PumpMessages(80);
  ExerciseThemeToggleCycles(1200, 760, Form1.tsDashboard,
    Form1.tsButtons, False, 'theme toggle 1200x760');
  ExerciseThemeToggleCycles(520, 560, Form1.tsInputs,
    Form1.tsGrid, True, 'theme toggle 520x560');
  Form1.GalleryTabs.ActivePage := Form1.tsDashboard;
  Form1.SetBounds(Form1.Left, Form1.Top, 1200, 760);
  PumpMessages(100);

  LNavigationButton := Form1.FindComponent('demoNavCharts') as TDACButton;
  Require(Assigned(LNavigationButton.OnClick),
    'Navegacao interna da Demo nao recebeu acao.');
  LNavigationButton.OnClick(LNavigationButton);
  Require(Form1.GalleryTabs.ActivePage = Form1.tsCharts,
    'Menu interno nao abriu a familia Charts.');
  Require(LNavigation.Visible,
    'A navegacao da galeria deve continuar visivel em Charts.');
  Require(LNavigationButton.Kind = mbkPrimary,
    'Menu interno nao refletiu a familia ativa.');
  RequireChartBottomRightSurface(Form1,
    Form1.FindComponent('demoBarChart') as TDACChart, 'bar');
  RequireChartBottomRightSurface(Form1,
    Form1.FindComponent('demoDoughnutChart') as TDACChart, 'doughnut');
  RequireChartBottomRightSurface(Form1,
    Form1.FindComponent('demoLineChart') as TDACChart, 'line');
  RequireChartBottomRightSurface(Form1,
    Form1.FindComponent('demoAreaChart') as TDACChart, 'area');
  LNavigationButton := Form1.FindComponent('demoNavButtons') as TDACButton;
  LNavigationButton.OnClick(LNavigationButton);
  PumpMessages(30);

  LScroll := Form1.scrButtons;
  LScroll.Redraw;
  PumpMessages(20);
  Require(Form1.lblButtonsSubtitle.MaxLines > 1,
    'O subtitulo da Demo nao recebeu quebra responsiva.');
  Require(Form1.lblButtonKinds.Top >= Form1.lblButtonsSubtitle.Top +
    Form1.lblButtonsSubtitle.Height + 12,
    'A secao de variantes sobrepoe o subtitulo refluido.');
  Require(Form1.lblButtonsSubtitle.Top >= Form1.lblButtonsTitle.Top +
    Form1.lblButtonsTitle.Height + 6,
    'O subtitulo esta proximo ou sobreposto ao titulo da Demo.');
  Require(Form1.lblButtonsSubtitle.Left + Form1.lblButtonsSubtitle.Width <=
    LScroll.ClientWidth - 1,
    'O subtitulo excede o viewport fisico da Demo (conteudo=' +
    IntToStr(Form1.lblButtonsSubtitle.Left + Form1.lblButtonsSubtitle.Width) +
    ', viewport=' + IntToStr(LScroll.ClientWidth) + ').');
  Require((Form1.btnKindInputAction.Caption = '') and
    Form1.btnKindInputAction.ShowHint and
    (Form1.btnKindInputAction.Hint = 'Acao de input') and
    (Form1.btnKindInputAction.Width >= Form1.btnKindInputAction.Height),
    'A acao de input precisa ser um alvo icon-only deliberado e identificado.');
  Require(Form1.btnStateLoading.Loading and Form1.btnStateLoading.Enabled and
    (TDACComponentColors.ContrastRatio(TDACComponentStyle.ButtonLoadingText,
      TDACComponentStyle.ButtonLoadingBackground) >= 4.5),
    'O cenario Carregando deve preservar a semantica primaria e contraste AA.');
  Require((not Form1.btnStateDisabled.Enabled) and
    (TDACComponentColors.ContrastRatio(TDACComponentStyle.ButtonDisabledText,
      TDACComponentStyle.ButtonDisabledBackground) >= 4.5),
    'O cenario Desabilitado deve preservar o estado inativo com contraste AA.');
  Require(LScroll.ControlAtPos(Point(Form1.lblButtonsTitle.Left,
    Form1.lblButtonsTitle.Top), False, False) =
    Form1.lblButtonsTitle,
    'A surface Skia do scroll container cobriu o primeiro filho VCL.');
  RequireGridWithinViewport(Form1.gcButtonKinds, LScroll, 24);
  RequireScrollViewportSurface(LScroll, 'padrao-topo-direct');

  LColumnsGrid := TDACGridContainer.Create(Form1);
  LColumnsGrid.Parent := Form1;
  LColumnsGrid.SetBounds(16, 360, 360, 120);
  LColumnFirst := TDACButton.Create(LColumnsGrid);
  LColumnFirst.Parent := LColumnsGrid;
  LColumnSecond := TDACButton.Create(LColumnsGrid);
  LColumnSecond.Parent := LColumnsGrid;
  LColumnThird := TDACButton.Create(LColumnsGrid);
  LColumnThird.Parent := LColumnsGrid;
  LColumnsGrid.Columns := 1;
  PumpMessages(30);
  Require(LColumnSecond.Top > LColumnFirst.Top,
    'Columns=1 nao foi respeitado.');
  LColumnsGrid.Columns := 2;
  PumpMessages(30);
  Require((LColumnSecond.Top = LColumnFirst.Top) and
    (LColumnThird.Top > LColumnFirst.Top), 'Columns=2 nao foi respeitado.');
  LColumnsGrid.Columns := 3;
  PumpMessages(30);
  Require(LColumnThird.Top = LColumnFirst.Top,
    'Columns>=3 nao manteve tres colunas quando havia espaco.');
  LColumnsGrid.Free;
  RequireLongCaptionGridAtFixedWidth(Form1);

  Form1.btnSplitMain.Caption :=
    'Executar acao composta com descricao completa';
  Form1.SetBounds(Form1.Left, Form1.Top, 521, 560);
  PumpMessages(50);
  Form1.SetBounds(Form1.Left, Form1.Top, 520, 560);
  PumpMessages(100);
  Require(Form1.btnKindGhost.Top > Form1.btnKindPrimary.Top,
    'A grade nao refez as colunas quando a largura ficou reduzida.');
  Require(Form1.lblButtonsSubtitle.Left + Form1.lblButtonsSubtitle.Width <=
    LScroll.ClientWidth - 1,
    'Resize deixou o subtitulo fora do viewport fisico.');
  Require(Form1.lblButtonsSubtitle.Height >
    Form1.lblButtonsSubtitle.MeasureTextHeight('Ag',
      Form1.lblButtonsSubtitle.Width),
    'Resize estreito nao aumentou a altura do subtitulo refluido.');
  Require(Form1.lblButtonKinds.Top >= Form1.lblButtonsSubtitle.Top +
    Form1.lblButtonsSubtitle.Height + 12,
    'Resize deixou a secao 1 sobreposta ao subtitulo.');
  Require(LNavigation.Visible and
    (LNavigation.Width = TDACDemoTokens.Default.NavigationCompactWidth),
    'Caption longa nao aplicou a rail compacta no viewport estreito.');
  Require(Form1.GalleryTabs.Left = LNavigation.Left + LNavigation.Width,
    'Galeria nao respeitou a largura da rail compacta.');
  Require(Form1.btnSplitMain.Width >= Form1.btnSplitMain.MinimumContentWidth,
    'Resize truncou a acao composta de caption longa.');
  Require(Form1.btnUploadAction.Width >= Form1.btnUploadAction.MinimumContentWidth,
    'Resize truncou a acao "Enviar arquivo".');
  RequireGridWithinViewport(Form1.gcButtonKinds, LScroll, 24);
  RequireGridWithinViewport(Form1.gcButtonSizes, LScroll, 24);
  LScrollRange := LScroll.VertScrollBar.Range;
  LScroll.Perform(WM_VSCROLL, SB_TOP, 0);
  PumpMessages(80);
  RequireScrollViewportSurface(LScroll, 'topo');
  RequireScrollChromeViewport(LScroll, LScrollRange, 'topo');
  LScroll.Perform(WM_VSCROLL, SB_PAGEDOWN, 0);
  PumpMessages(80);
  RequireScrollViewportSurface(LScroll, 'meio');
  RequireScrollChromeViewport(LScroll, LScrollRange, 'meio');
  LScroll.Perform(WM_VSCROLL, SB_BOTTOM, 0);
  PumpMessages(80);
  RequireScrollViewportSurface(LScroll, 'fim');
  RequireScrollChromeViewport(LScroll, LScrollRange, 'fim');
  LScroll.Perform(WM_VSCROLL, SB_TOP, 0);
  PumpMessages(80);
  LWheelPosition := LScroll.VertScrollBar.Position;
  Require(SetWindowPos(Form1.Handle, HWND_TOPMOST, 0, 0, 0, 0,
    SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE),
    'Nao foi possivel expor a pagina Buttons para o hit-test do wheel.');
  LPageContentPoint := Form1.btnKindPrimary.ClientToScreen(
    Point(Form1.btnKindPrimary.ClientWidth div 2,
      Form1.btnKindPrimary.ClientHeight div 2));
  LScroll.Perform(CM_MOUSEWHEEL, WPARAM($FFC40000),
    MakeLong(Word(LPageContentPoint.X), Word(LPageContentPoint.Y)));
  PumpMessages(40);
  Require(LScroll.VertScrollBar.Position = LWheelPosition,
    'Delta parcial da roda foi aplicado antes de acumular WHEEL_DELTA: ' +
    IntToStr(LWheelPosition) + ' -> ' +
    IntToStr(LScroll.VertScrollBar.Position) + '.');
  LScroll.Perform(CM_MOUSEWHEEL, WPARAM($FFC40000),
    MakeLong(Word(LPageContentPoint.X), Word(LPageContentPoint.Y)));
  PumpMessages(80);
  Require(LScroll.VertScrollBar.Position > LWheelPosition,
    'Roda sobre filho nao deslocou o TDACScrollContainer.');
  LWheelPosition := LScroll.VertScrollBar.Position;
  LPageContentPoint := LScroll.ClientToScreen(Point(12, 12));
  LScroll.Perform(CM_MOUSEWHEEL, WPARAM($FF880000),
    MakeLong(Word(LPageContentPoint.X), Word(LPageContentPoint.Y)));
  PumpMessages(80);
  Require(LScroll.VertScrollBar.Position > LWheelPosition,
    'Roda sobre viewport nao deslocou o TDACScrollContainer.');
  SetWindowPos(Form1.Handle, HWND_NOTOPMOST, 0, 0, 0, 0,
    SWP_NOMOVE or SWP_NOSIZE or SWP_NOACTIVATE);
  Require(Form1.HandleAllocated and Form1.Visible,
    'O scroll destruiu ou ocultou a janela principal.');

  // Restore the desktop viewport before validating the two side-by-side tab
  // demos; the preceding responsive-button scenario intentionally collapsed
  // navigation and cannot expose their declared 560/400 px canvases.
  Form1.SetBounds(Form1.Left, Form1.Top, 1200, 760);
  PumpMessages(80);

  LButton := TDACButton.Create(Form1);
  LButton.Parent := Form1;
  LButton.SetBounds(24, 24, 160, 40);
  LButton.Caption := 'Interaction button';
  LButton.BringToFront;
  LButton.OnClick := LProbe.OnButtonClick;
  TDACThemeManager.SetApplicationMode(dtmLight);
  LButton.ThemeMode := dtmInherit;
  LButton.Kind := mbkPrimary;
  LButton.Enabled := True;
  LButton.Loading := False;
  LButton.ShowIcon := False;
  PumpMessages(30);
  Require(LButton.ResolvedBackgroundColor =
    TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.ButtonPrimaryBackground,
    'TDACButton inherit nao iniciou no global light.');
  LButton.ThemeMode := dtmDark;
  PumpMessages(30);
  Require(LButton.ResolvedBackgroundColor =
    TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.ButtonPrimaryBackground,
    'TDACButton nao resolveu o override local dark.');
  LButton.ThemeMode := dtmInherit;
  PumpMessages(30);
  Require(LButton.ResolvedBackgroundColor =
    TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.ButtonPrimaryBackground,
    'TDACButton inherit nao retomou o global light.');
  TDACThemeManager.SetApplicationMode(dtmDark);
  PumpMessages(30);
  Require(LButton.ResolvedBackgroundColor =
    TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.ButtonPrimaryBackground,
    'TDACButton inherit nao refletiu o global dark.');

  LButton.Kind := mbkSecondary;
  Require(LButton.ResolvedBackgroundColor =
    TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.ButtonSecondaryBackground,
    'Variante secondary nao resolveu o ButtonSecondaryBackground local.');
  LButton.Kind := mbkGhost;
  Require(LButton.ResolvedBackgroundColor =
    TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.ButtonGhostBackground,
    'Variante ghost nao resolveu o ButtonGhostBackground local.');
  LButton.Kind := mbkWarning;
  Require(LButton.ResolvedBackgroundColor =
    TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.ButtonWarningBackground,
    'Variante warning nao resolveu o ButtonWarningBackground local.');
  LButton.Kind := mbkDanger;
  Require(LButton.ResolvedBackgroundColor =
    TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.ButtonDangerBackground,
    'Variante danger nao resolveu o ButtonDangerBackground local.');
  LButton.Kind := mbkTransparent;
  Require(LButton.ResolvedBackgroundColor =
    TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.ButtonTransparent,
    'Variante transparent nao resolveu o ButtonTransparent local.');
  LButton.Kind := mbkInputAction;
  LButton.ShowIcon := True;
  LButton.IconKind := mikCheck;
  LButton.Caption := '';
  LButton.Redraw;
  PumpMessages(20);
  Require(LButton.MinimumContentWidth >= Round(
    TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.ButtonMinimumWidth),
    'Input-action icon-only nao preservou o alvo minimo tokenizado.');
  Require(LButton.ResolvedBackgroundColor =
    TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.ButtonTransparent,
    'Input-action icon-only nao preservou o fundo transparente.');
  LButton.ShowIcon := False;
  LButton.Caption := 'Acao';
  LButton.Redraw;
  PumpMessages(20);
  Require(LButton.ResolvedBackgroundColor =
    TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.ButtonTransparent,
    'Input-action com caption nao preservou o canvas/divisor local.');

  LButton.Kind := mbkPrimary;
  LButton.Caption := 'Interaction button';
  LButton.SetFocus;
  PumpMessages(20);
  Require(LButton.Focused and (LButton.ResolvedBackgroundColor =
    TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.ButtonPrimaryPressedBackground),
    'Foco nao aplicou o estado primary focado do TDACButton.');
  TButtonAccess(LButton).SimulateMouseMove(12, 12);
  PumpMessages(20);
  Require(LButton.ResolvedBackgroundColor =
    TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.ButtonPrimaryHoverBackground,
    'Hover nao aplicou o estado primary hover do TDACButton.');
  LButtonClickBefore := ClickCount;
  TButtonAccess(LButton).SimulateMouseDown(12, 12);
  PumpMessages(20);
  Require(LButton.ResolvedBackgroundColor =
    TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.ButtonPrimaryPressedBackground,
    'Mouse down nao aplicou o estado primary pressed do TDACButton.');
  TButtonAccess(LButton).SimulateMouseUp(12, 12);
  PumpMessages(20);
  Require(ClickCount = LButtonClickBefore + 1,
    'Clique real nao acionou TDACButton.');
  LButton.Enabled := False;
  PumpMessages(20);
  Require(LButton.ResolvedBackgroundColor =
    TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.ButtonDisabledBackground,
    'Disabled nao aplicou o ButtonDisabledBackground local.');
  TButtonAccess(LButton).SimulateMouseDown(12, 12);
  TButtonAccess(LButton).SimulateMouseUp(12, 12);
  PumpMessages(20);
  Require(ClickCount = LButtonClickBefore + 1,
    'TDACButton desabilitado nao pode disparar clique.');
  LButton.Enabled := True;
  LButton.Loading := True;
  PumpMessages(20);
  Require(LButton.ResolvedBackgroundColor =
    TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.ButtonLoadingBackground,
    'Loading nao aplicou o ButtonLoadingBackground local.');
  LButtonClickBefore := ClickCount;
  TButtonAccess(LButton).SimulateMouseDown(12, 12);
  TButtonAccess(LButton).SimulateMouseUp(12, 12);
  SendKey(LButton, VK_SPACE);
  SendKey(LButton, VK_RETURN);
  Require(ClickCount = LButtonClickBefore,
    'TDACButton Loading nao pode disparar clique por mouse, Space ou Enter.');
  LButton.Loading := False;
  LButtonClickBefore := ClickCount;
  SendKey(LButton, VK_SPACE);
  SendKey(LButton, VK_RETURN);
  Require(ClickCount = LButtonClickBefore + 2,
    'Space/Enter nao acionaram TDACButton.');
  TFormAccess(Form1).FocusNext(LButton);
  Require(Form1.ActiveControl <> nil, 'Tab nao encontrou proximo controle.');

  TDACThemeManager.SetApplicationMode(dtmLight);
  Form1.GalleryTabs.ActivePage := Form1.tsControls;
  PumpMessages(40);
  LRadio := Form1.FindComponent('demoRadio') as TDACRadioButton;
  LToggle := Form1.FindComponent('demoToggle') as TDACToggleSwitch;
  Require((LRadio <> nil) and (LToggle <> nil),
    'DFM nao materializou Radio/Toggle para validacao de interacao.');
  LRadio.Checked := False;
  LRadio.Perform(WM_LBUTTONDOWN, MK_LBUTTON, MakeLong(8, 8));
  LRadio.Perform(WM_LBUTTONUP, 0, MakeLong(8, 8));
  Require(LRadio.Checked, 'Clique no Radio DFM nao selecionou o controle.');
  LToggle.Checked := False;
  LToggle.Perform(WM_LBUTTONDOWN, MK_LBUTTON, MakeLong(8, 8));
  LToggle.Perform(WM_LBUTTONUP, 0, MakeLong(8, 8));
  Require(LToggle.Checked, 'Clique no Toggle DFM nao alternou o controle.');
  LRadio.Checked := False;
  SendKey(LRadio, VK_SPACE);
  LToggle.Checked := False;
  SendKey(LToggle, VK_SPACE);
  Require(LRadio.Checked and LToggle.Checked,
    'VK_SPACE nao preservou a interacao do Radio/Toggle DFM.');
  LRadio.ThemeMode := dtmDark;
  LToggle.ThemeMode := dtmDark;
  Require((LRadio.ResolvedTextColor =
      TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.SelectorText) and
    (LToggle.ResolvedTextColor =
      TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.SelectorText),
    'Radio/Toggle DFM nao resolveram o tema dark local.');
  LRadio.ThemeMode := dtmInherit;
  LToggle.ThemeMode := dtmInherit;
  Require((LRadio.ResolvedTextColor =
      TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.SelectorText) and
    (LToggle.ResolvedTextColor =
      TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.SelectorText),
    'Radio/Toggle DFM nao retomaram o tema global light herdado.');
  TDACThemeManager.SetApplicationMode(dtmDark);
  Require((LRadio.ResolvedTextColor =
      TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.SelectorText) and
    (LToggle.ResolvedTextColor =
      TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.SelectorText),
    'Radio/Toggle DFM nao acompanharam a surface dark da TabSheet.');
  TDACThemeManager.SetApplicationMode(dtmLight);

  LCheck := TDACCheckBox.Create(Form1);
  LCheck.Parent := Form1;
  LCheck.SetBounds(24, 72, 180, 30);
  LCheck.BringToFront;
  LCheck.Checked := False;
  SendKey(LCheck, VK_SPACE);
  Require(LCheck.Checked, 'Space nao alternou TDACCheckBox.');
  LCheck.ThemeMode := dtmDark;
  Require(LCheck.ResolvedTextColor =
    TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.SelectorText,
    'Checkbox nao resolveu texto no ThemeMode dark local.');
  LCheck.ThemeMode := dtmInherit;
  Require(LCheck.ResolvedTextColor =
    TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.SelectorText,
    'Checkbox nao retomou texto da surface light do Form.');

  LRadio := TDACRadioButton.Create(Form1);
  LRadio.Parent := Form1;
  LRadio.SetBounds(210, 72, 180, 30);
  SendKey(LRadio, VK_SPACE);
  Require(LRadio.Checked, 'Space nao selecionou TDACRadioButton.');

  LToggle := TDACToggleSwitch.Create(Form1);
  LToggle.Parent := Form1;
  LToggle.SetBounds(400, 72, 190, 30);
  SendKey(LToggle, VK_SPACE);
  Require(LToggle.Checked, 'Space nao alternou TDACToggleSwitch.');

  LSlider := TDACSlider.Create(Form1);
  LSlider.Parent := Form1;
  LSlider.SetBounds(24, 110, 260, 36);
  LSlider.BringToFront;
  LSlider.Value := 50;
  SendKey(LSlider, VK_RIGHT);
  Require(LSlider.Value = 51, 'Seta direita nao incrementou TDACSlider.');
  SendKey(LSlider, VK_LEFT);
  Require(LSlider.Value = 50, 'Seta esquerda nao decrementou TDACSlider.');
  LSlider.ThemeMode := dtmDark;
  Require(LSlider.ResolvedTrackColor =
    TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.SliderTrack,
    'Slider nao resolveu track no ThemeMode dark local.');
  LSlider.ThemeMode := dtmInherit;
  Require(LSlider.ResolvedTrackColor =
    TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.SliderTrack,
    'Slider nao retomou track da surface light do Form.');

  TDACThemeManager.SetApplicationMode(dtmLight);
  LThemeScroll := TDACScrollContainer.Create(Form1);
  LThemeScroll.Parent := Form1;
  LThemeScroll.SetBounds(0, 0, 1, 1);
  Require(LThemeScroll.ResolvedBackgroundColor =
    TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.ScrollContainerBackground,
    'ScrollContainer herdado nao iniciou na surface light do Form.');
  LThemeScroll.ThemeMode := dtmDark;
  Require(LThemeScroll.ResolvedBackgroundColor =
    TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.ScrollContainerBackground,
    'ScrollContainer nao resolveu superficie dark local.');
  LThemeScroll.ThemeMode := dtmInherit;
  Require(LThemeScroll.ResolvedBackgroundColor =
    TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.ScrollContainerBackground,
    'ScrollContainer nao retomou a surface light do Form.');
  TDACThemeManager.SetApplicationMode(dtmDark);
  PumpMessages(40);
  Require(LThemeScroll.ResolvedBackgroundColor =
    TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.ScrollContainerBackground,
    'ScrollContainer herdado nao acompanhou a superficie dark global.');
  TDACThemeManager.SetApplicationMode(dtmLight);
  PumpMessages(40);

  LThemeChart := TDACChart.Create(Form1);
  LThemeChart.Parent := Form1;
  LThemeChart.ThemeMode := dtmDark;
  Require(LThemeChart.ResolvedBackgroundColor =
    TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.ContainerSuiteBackground,
    'Chart nao resolveu superficie dark local.');
  Require(LThemeChart.ResolvedAccentColor =
    TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.ChartAccent,
    'Chart nao resolveu a paleta local dark.');
  LThemeChart.ThemeMode := dtmInherit;
  Require(LThemeChart.ResolvedBackgroundColor =
    TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.ContainerSuiteBackground,
    'Chart nao retomou a surface light do Form.');
  Require((TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.ChartLineWidth = 2) and
    (TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.ReportToolbarHeight = 42) and
    (TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.TabsIndicatorWidth = 2) and
    (TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.TabsDividerWidth = 1) and
    (TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.TabsMedium.Height = 40),
    'Metricas visuais de Charts, ReportViewer e Tabs nao vieram do ControlTokens.');
  Require((Ord(mtaUnderline) = 0) and (Ord(mtaPills) = 1) and
    (Ord(mtaFilled) = 2) and (Ord(mtaSegmented) = 3),
    'Ordinais serializados de TDACTabAppearance foram alterados.');

  LThemeDoughnut := TDACChart.Create(Form1);
  LThemeDoughnut.Parent := Form1;
  LThemeDoughnut.ChartType := ctDoughnut;
  LThemeDoughnut.SetBounds(Max(0, Form1.ClientWidth - 2), Max(0, Form1.ClientHeight - 2), 1, 1);
  TDACThemeManager.SetApplicationMode(dtmLight);
  Require((LThemeDoughnut.ResolvedDoughnutSeriesColor(0) =
      TDACComponentStyle.Resolve(dtmLight).ChartPalette.ColorByIndex(0)) and
    (LThemeDoughnut.ResolvedDoughnutSeriesColor(1) =
      TDACComponentStyle.Resolve(dtmLight).ChartPalette.ColorByIndex(1)) and
    (LThemeDoughnut.ResolvedDoughnutSeriesColor(2) =
      TDACComponentStyle.Resolve(dtmLight).ChartPalette.ColorByIndex(2)) and
    (LThemeDoughnut.ResolvedDoughnutSeriesColor(3) =
      TDACComponentStyle.Resolve(dtmLight).ChartPalette.ColorByIndex(3)),
    'Doughnut inherit nao iniciou com a paleta da surface light do Form.');
  LThemeDoughnut.ThemeMode := dtmDark;
  Require((LThemeDoughnut.ResolvedDoughnutSeriesColor(0) =
      TDACComponentStyle.Resolve(dtmDark).ChartPalette.ColorByIndex(0)) and
    (LThemeDoughnut.ResolvedDoughnutSeriesColor(1) =
      TDACComponentStyle.Resolve(dtmDark).ChartPalette.ColorByIndex(1)) and
    (LThemeDoughnut.ResolvedDoughnutSeriesColor(2) =
      TDACComponentStyle.Resolve(dtmDark).ChartPalette.ColorByIndex(2)) and
    (LThemeDoughnut.ResolvedDoughnutSeriesColor(3) =
      TDACComponentStyle.Resolve(dtmDark).ChartPalette.ColorByIndex(3)),
    'Doughnut nao manteve as cores de serie no override local dark.');
  LThemeDoughnut.ThemeMode := dtmInherit;
  Require((LThemeDoughnut.ResolvedDoughnutSeriesColor(0) =
      TDACComponentStyle.Resolve(dtmLight).ChartPalette.ColorByIndex(0)),
    'Doughnut inherit nao retomou a paleta da surface light do Form.');
  TDACThemeManager.SetApplicationMode(dtmDark);
  Require((LThemeDoughnut.ResolvedDoughnutSeriesColor(0) =
      TDACComponentStyle.Resolve(dtmDark).ChartPalette.ColorByIndex(0)) and
    (LThemeDoughnut.ResolvedDoughnutSeriesColor(1) =
      TDACComponentStyle.Resolve(dtmDark).ChartPalette.ColorByIndex(1)) and
    (LThemeDoughnut.ResolvedDoughnutSeriesColor(2) =
      TDACComponentStyle.Resolve(dtmDark).ChartPalette.ColorByIndex(2)) and
    (LThemeDoughnut.ResolvedDoughnutSeriesColor(3) =
      TDACComponentStyle.Resolve(dtmDark).ChartPalette.ColorByIndex(3)),
    'Doughnut inherit nao refletiu as cores da serie sob global dark.');

  LThemeReport := TDACReportViewer.Create(Form1);
  LThemeReport.Parent := Form1;
  TDACThemeManager.SetApplicationMode(dtmLight);
  Require(LThemeReport.ResolvedBackgroundColor =
    TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.ContainerSuiteBackground,
    'ReportViewer inherit nao iniciou na surface light do Form.');
  LThemeReport.ThemeMode := dtmDark;
  Require(LThemeReport.ResolvedBackgroundColor =
    TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.ContainerSuiteBackground,
    'ReportViewer nao resolveu superficie dark local.');
  LThemeReport.ThemeMode := dtmInherit;
  Require(LThemeReport.ResolvedBackgroundColor =
    TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.ContainerSuiteBackground,
    'ReportViewer inherit nao retornou a surface light do Form.');
  TDACThemeManager.SetApplicationMode(dtmDark);
  Require(LThemeReport.ResolvedBackgroundColor =
    TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.ContainerSuiteBackground,
    'ReportViewer inherit nao refletiu o modo global dark efetivo.');

  LTabs := Form1.FindComponent('GalleryTabs') as TDACTabs;
  TDACThemeManager.SetApplicationMode(dtmLight);
  Require(LTabs.ResolvedTokens.ContainerSuiteBackground =
    TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.ContainerSuiteBackground,
    'Tabs inherit nao iniciou na surface light do Form.');
  Require((LTabs.ResolvedTokens.TabsSurface =
      TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.TabsSurface) and
    (LTabs.ResolvedTokens.TabsTextDefault <>
      LTabs.ResolvedTokens.SelectorText),
    'Tabs nao consumiu paleta semantica propria no tema light.');
  LTabs.ThemeMode := dtmDark;
  Require(LTabs.ResolvedTokens.ContainerSuiteBackground =
    TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.ContainerSuiteBackground,
    'Tabs nao resolveram tokens dark locais.');
  Require((LTabs.ResolvedTokens.TabsSurface =
      TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.TabsSurface) and
    (LTabs.ResolvedTokens.TabsSurface <>
      TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.TabsSurface),
    'Tabs nao trocou sua surface propria no override dark.');
  LTabs.ThemeMode := dtmInherit;
  Require(LTabs.ResolvedTokens.ContainerSuiteBackground =
    TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.ContainerSuiteBackground,
    'Tabs inherit nao retornou a surface light do Form.');
  TDACThemeManager.SetApplicationMode(dtmDark);
  Require(LTabs.ResolvedTokens.ContainerSuiteBackground =
    TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.ContainerSuiteBackground,
    'Tabs inherit nao refletiu o tema global dark.');
  LTabs.CornerRadius := 14;
  LTabs.ContentColor := TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.PopupBackground;
  LTabs.ShowContentBorder := False;
  Require((LTabs.CornerRadius = 14) and
    (LTabs.ContentColor = TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.PopupBackground) and
    not LTabs.ShowContentBorder,
    'Propriedades visuais de Tabs nao foram aplicadas.');
  LTabs.ShowContentBorder := True;
  LTabs.ActivePage := Form1.FindComponent('tsTabs') as TTabSheet;
  PumpMessages(40);
  LHorizontalTabs := Form1.FindComponent('demoTabs') as TDACTabs;
  Require(LHorizontalTabs.Orientation = mtoHorizontal,
    'Demo de tabs horizontal nao foi materializada.');
  Require((LHorizontalTabs.Appearance = mtaUnderline) and
    (LHorizontalTabs.Size = mtsMedium) and
    (LHorizontalTabs.Pages[0].Caption = 'Geral') and
    (LHorizontalTabs.Pages[1].Caption = 'Detalhes') and
    (LHorizontalTabs.Pages[2].Caption = 'Historico') and
    not LHorizontalTabs.Pages[2].Enabled,
    'Header horizontal nao materializou captions, estado selecionado e disabled.');
  LTabHeader := FindTabHeader(LHorizontalTabs);
  Require((LTabHeader <> nil) and LTabHeader.Visible and
    (LTabHeader.Height >= Round(LHorizontalTabs.ResolvedTokens.TabsHorizontalExtent)) and (LTabHeader.Width = LHorizontalTabs.Width) and
    (LTabHeader.Parent = LHorizontalTabs.Parent) and
    (LTabHeader.Left = LHorizontalTabs.Left) and (LTabHeader.Top = LHorizontalTabs.Top),
    'Renderer do header horizontal nao esta visivel ou nao reservou area de texto.');
  LTabHeaderPaintBox := FindTabHeaderPaintBox(LTabHeader);
  Require((LTabHeaderPaintBox <> nil) and LTabHeaderPaintBox.Visible,
    'Header horizontal nao manteve o paintbox Skia real para clique.');
  LTabLayout := LTabHeader.BuildTabLayout;
  Require((Length(LTabLayout) = 3) and
    (LTabLayout[0].PageIndex = 0) and (LTabLayout[1].PageIndex = 1) and
    (LTabLayout[2].PageIndex = 2) and
    (Abs(LTabLayout[0].Bounds.Height -
      LHorizontalTabs.ResolvedTokens.TabsMedium.Height) < 0.01) and
    (LTabLayout[1].Bounds.Width > LTabLayout[0].Bounds.Width),
    'Line horizontal nao produziu layout intrinseco MD para as tabs visiveis.');
  LTabSelectionRect := LTabHeader.TabRectForPage(0);
  LTabFocusRect := LTabHeader.FocusRectForPage(0);
  LTabSecondaryRect := LTabHeader.TabRectForPage(1);
  LTabTertiaryRect := LTabHeader.TabRectForPage(2);
  Require((LTabHeader.HitTestPageAt(
      Round((LTabSelectionRect.Left + LTabSelectionRect.Right) / 2),
      Round((LTabSelectionRect.Top + LTabSelectionRect.Bottom) / 2)) = 0) and
    (LTabHeader.HitTestPageAt(
      Round((LTabSecondaryRect.Left + LTabSecondaryRect.Right) / 2),
      Round((LTabSecondaryRect.Top + LTabSecondaryRect.Bottom) / 2)) = 1),
    'Paint bounds e hit-test nao compartilham o mesmo BuildTabLayout.');
  Require((LTabFocusRect.Left < LTabSelectionRect.Left) and
    (LTabFocusRect.Top < LTabSelectionRect.Top) and
    (LTabFocusRect.Right > LTabSelectionRect.Right) and
    (LTabFocusRect.Bottom > LTabSelectionRect.Bottom) and
    (LTabFocusRect.Left -
      (LHorizontalTabs.ResolvedTokens.TabsFocusWidth / 2) >= 0) and
    (LTabFocusRect.Top -
      (LHorizontalTabs.ResolvedTokens.TabsFocusWidth / 2) >= 0) and
    (LTabFocusRect.Right +
      (LHorizontalTabs.ResolvedTokens.TabsFocusWidth / 2) <=
      LTabHeader.Width) and
    (LTabFocusRect.Bottom +
      (LHorizontalTabs.ResolvedTokens.TabsFocusWidth / 2) <=
      LTabHeader.Height),
    'Focus ring externo de 2 px nao possui clipping reservado no header Line.');
  Require((LTabHeader.ResolvedTextColorForPage(0, True) =
      LHorizontalTabs.ResolvedTokens.TabsTextActive) and
    (LTabHeader.ResolvedTextColorForPage(1, True) =
      LHorizontalTabs.ResolvedTokens.TabsTextHover) and
    (LTabHeader.ResolvedTextColorForPage(2, True) =
      LHorizontalTabs.ResolvedTokens.TabsTextDisabled),
    'Precedencia disabled > active > hover > default das Tabs divergiu.');

  LTabOriginalCaption := LHorizontalTabs.Pages[1].Caption;
  LHorizontalTabs.Pages[1].Caption :=
    'Detalhes com uma legenda deliberadamente longa para validar elipse';
  LHorizontalTabs.HeaderTrailingReserve := 96;
  LTabLayout := LTabHeader.BuildTabLayout;
  Require((Length(LTabLayout) = 3) and
    (LTabLayout[High(LTabLayout)].Bounds.Right <=
      LTabHeader.Width - LHorizontalTabs.ResolvedTokens.TabsHeaderInset -
      LHorizontalTabs.HeaderTrailingReserve + 0.01),
    'Legenda longa invadiu HeaderTrailingReserve ou removeu tabs visiveis.');
  LHorizontalTabs.Pages[1].Caption := LTabOriginalCaption;
  LHorizontalTabs.HeaderTrailingReserve := 0;

  LHorizontalTabs.Pages[1].TabVisible := False;
  LTabLayout := LTabHeader.BuildTabLayout;
  Require((Length(LTabLayout) = 2) and
    (LTabLayout[0].PageIndex = 0) and (LTabLayout[1].PageIndex = 2) and
    (Abs(LTabLayout[0].Bounds.Right - LTabLayout[1].Bounds.Left) < 0.01),
    'TabVisible=False deixou gap ou ordinal fantasma no layout Line.');
  LHorizontalTabs.Pages[2].Enabled := True;
  LHiddenTabProbe := TShowingCountEdit.Create(Form1);
  LVisibleTabProbe := TShowingCountEdit.Create(Form1);
  try
    LHiddenTabProbe.Parent := LHorizontalTabs.Pages[1];
    LVisibleTabProbe.Parent := LHorizontalTabs.Pages[2];
    LHiddenTabProbe.Visible := True;
    LVisibleTabProbe.Visible := True;

    LHorizontalTabs.ActiveIndex := 0;
    LHiddenTabProbe.ResetShowingChangeCount;
    LVisibleTabProbe.ResetShowingChangeCount;
    LTabTertiaryRect := LTabHeader.TabRectForPage(2);
    LTabHeaderPaintBox.Perform(WM_LBUTTONDOWN, MK_LBUTTON,
      MakeLong(Round((LTabTertiaryRect.Left + LTabTertiaryRect.Right) / 2),
        Round((LTabTertiaryRect.Top + LTabTertiaryRect.Bottom) / 2)));
    PumpMessages(30);
    Require((LHorizontalTabs.ActivePage = LHorizontalTabs.Pages[2]) and
      (LHorizontalTabs.ActiveIndex = 2) and LVisibleTabProbe.Showing and
      (LVisibleTabProbe.ShowingChangeCount > 0) and
      (LHiddenTabProbe.ShowingChangeCount = 0),
      'Clique em C visivel confundiu PageIndex=2 com ordinal nativo=1.');

    LHorizontalTabs.ActiveIndex := 0;
    LHiddenTabProbe.ResetShowingChangeCount;
    LVisibleTabProbe.ResetShowingChangeCount;
    LHorizontalTabs.ActiveIndex := 2;
    PumpMessages(30);
    Require((LHorizontalTabs.ActivePage = LHorizontalTabs.Pages[2]) and
      (LHorizontalTabs.ActiveIndex = 2) and LVisibleTabProbe.Showing and
      (LVisibleTabProbe.ShowingChangeCount > 0) and
      (LHiddenTabProbe.ShowingChangeCount = 0),
      'Selecao programatica de C notificou a pagina oculta B.');

    LHorizontalTabs.ActiveIndex := 0;
    LHiddenTabProbe.ResetShowingChangeCount;
    LVisibleTabProbe.ResetShowingChangeCount;
    TDACTabsAccess(LHorizontalTabs).SimulateKeyDown(VK_RIGHT, []);
    PumpMessages(30);
    Require((LHorizontalTabs.ActivePage = LHorizontalTabs.Pages[2]) and
      (LHorizontalTabs.ActiveIndex = 2) and LVisibleTabProbe.Showing and
      (LVisibleTabProbe.ShowingChangeCount > 0) and
      (LHiddenTabProbe.ShowingChangeCount = 0),
      'Teclado nao saltou B oculta ao navegar de A para C.');

    LHorizontalTabs.ActiveIndex := 0;
    LHiddenTabProbe.ResetShowingChangeCount;
    LVisibleTabProbe.ResetShowingChangeCount;
    TDACTabsAccess(LHorizontalTabs).SimulateCtrlTab;
    PumpMessages(30);
    Require((LHorizontalTabs.ActivePage = LHorizontalTabs.Pages[2]) and
      (LHorizontalTabs.ActiveIndex = 2) and LVisibleTabProbe.Showing and
      (LVisibleTabProbe.ShowingChangeCount > 0) and
      (LHiddenTabProbe.ShowingChangeCount = 0),
      'Ctrl+Tab nao saltou B oculta ao navegar de A para C.');

    LHorizontalTabs.ActiveIndex := 0;
    LHorizontalTabs.Enabled := False;
    TDACTabsAccess(LHorizontalTabs).SimulateKeyDown(VK_RIGHT, []);
    TDACTabsAccess(LHorizontalTabs).SimulateCtrlTab;
    Require((LHorizontalTabs.ActivePage = LHorizontalTabs.Pages[0]) and
      (LHorizontalTabs.ActiveIndex = 0),
      'Host disabled alterou a pagina ativa por teclado.');
    LHorizontalTabs.Enabled := True;
  finally
    LHorizontalTabs.ActiveIndex := 0;
    LHiddenTabProbe.Free;
    LVisibleTabProbe.Free;
  end;
  LHorizontalTabs.Pages[1].TabVisible := True;
  LHorizontalTabs.Pages[2].Enabled := False;

  LHorizontalTabs.Appearance := mtaSegmented;
  LTabLayout := LTabHeader.BuildTabLayout;
  Require((Length(LTabLayout) = 3) and
    (Abs(LTabLayout[0].Bounds.Width - LTabLayout[1].Bounds.Width) < 0.01) and
    (Abs(LTabLayout[1].Bounds.Width - LTabLayout[2].Bounds.Width) < 0.01),
    'Somente Segmented deveria distribuir tabs em larguras iguais.');
  LHorizontalTabs.Appearance := mtaPills;
  LTabLayout := LTabHeader.BuildTabLayout;
  Require(Abs(LTabLayout[0].Bounds.Width - LTabLayout[1].Bounds.Width) > 0.01,
    'Pills perdeu o dimensionamento intrinseco por caption.');
  LHorizontalTabs.Appearance := mtaFilled;
  Require(LHorizontalTabs.Appearance = mtaFilled,
    'Appearance Filled nao respondeu em runtime.');
  LHorizontalTabs.Appearance := mtaUnderline;
  LHorizontalTabs.Size := mtsSmall;
  LTabLayout := LTabHeader.BuildTabLayout;
  Require(Abs(LTabLayout[0].Bounds.Height -
      LHorizontalTabs.ResolvedTokens.TabsSmall.Height) < 0.01,
    'Size Small nao atualizou as metricas de layout.');
  LHorizontalTabs.Size := mtsLarge;
  LTabLayout := LTabHeader.BuildTabLayout;
  Require(Abs(LTabLayout[0].Bounds.Height -
      LHorizontalTabs.ResolvedTokens.TabsLarge.Height) < 0.01,
    'Size Large nao atualizou as metricas de layout.');
  LHorizontalTabs.Size := mtsMedium;

  LHorizontalTabs.ActiveIndex := 0;
  LTabTertiaryRect := LTabHeader.TabRectForPage(2);
  LTabHeaderPaintBox.Perform(WM_MOUSEMOVE, 0,
    MakeLong(Round((LTabTertiaryRect.Left + LTabTertiaryRect.Right) / 2),
      Round((LTabTertiaryRect.Top + LTabTertiaryRect.Bottom) / 2)));
  Require(LTabHeader.Cursor = crDefault,
    'Hover sobre tab disabled manteve cursor interativo.');
  LTabHeaderPaintBox.Perform(WM_LBUTTONDOWN, MK_LBUTTON,
    MakeLong(Round((LTabTertiaryRect.Left + LTabTertiaryRect.Right) / 2),
      Round((LTabTertiaryRect.Top + LTabTertiaryRect.Bottom) / 2)));
  Require(LHorizontalTabs.ActiveIndex = 0,
    'Tab disabled aceitou selecao por clique.');
  LHorizontalTabs.ActiveIndex := 1;
  TDACTabsAccess(LHorizontalTabs).SimulateKeyDown(VK_RIGHT, []);
  Require(LHorizontalTabs.ActiveIndex = 0,
    'Seta direita nao saltou a pagina disabled.');
  LHorizontalTabs.ActiveIndex := 0;
  RequireTabHeaderFrame(LTabHeader, 'tabs antes da troca');
  LHorizontalText := Form1.FindComponent('demoTabsFirstText') as TDACSystemText;
  Require(LHorizontalTabs.ResolvedTokens.ContainerSuiteBackground =
    TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.ContainerSuiteBackground,
    'Header horizontal nao preservou a surface dark ancestral.');
  Require(TTabSheetAccess(LHorizontalTabs.ActivePage).Color =
    TDACComponentColors.ToVclColor(
      TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.ContainerSuiteBackground),
    'TabSheet horizontal nao acompanhou a surface dark resolvida.');
  Require((LHorizontalTabs.ActivePage.Font.Color =
      TDACComponentColors.ToVclColor(
        TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.ContainerTitle)) and
    SameText(LHorizontalTabs.ActivePage.Font.Name, TDACComponentStyle.FontFamily) and
    (LHorizontalTabs.ActivePage.Font.Size = TDACComponentStyle.TextSize) and
    (LHorizontalTabs.ActivePage.Font.Style = []),
    'Fonte da TabSheet horizontal nao preservou os tokens dark.');
  Require(LHorizontalText.ResolvedTextColor =
    TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.InputText,
    'Texto herdado da TabSheet horizontal nao permaneceu legivel em dark.');
  LTabSelectionRect := LTabHeader.TabRectForPage(1);
  LTabHeaderPaintBox.Perform(WM_MOUSEMOVE, 0,
    MakeLong(Round((LTabSelectionRect.Left + LTabSelectionRect.Right) / 2),
      Round((LTabSelectionRect.Top + LTabSelectionRect.Bottom) / 2)));
  PumpMessages(20);
  RequireTabHeaderFrame(LTabHeader, 'tabs em hover');
  LTabHeaderPaintBox.Perform(WM_LBUTTONDOWN, MK_LBUTTON,
    MakeLong(Round((LTabSelectionRect.Left + LTabSelectionRect.Right) / 2),
      Round((LTabSelectionRect.Top + LTabSelectionRect.Bottom) / 2)));
  LTabHeaderPaintBox.Perform(WM_LBUTTONUP, 0,
    MakeLong(Round((LTabSelectionRect.Left + LTabSelectionRect.Right) / 2),
      Round((LTabSelectionRect.Top + LTabSelectionRect.Bottom) / 2)));
  PumpMessages(30);
  Require((LHorizontalTabs.ActivePage = LHorizontalTabs.Pages[1]) and
    LHorizontalTabs.Focused,
    'Clique no paintbox real do header nao selecionou a tab nem devolveu foco.');
  SendKey(LHorizontalTabs, VK_LEFT);
  Require(LHorizontalTabs.ActivePage = LHorizontalTabs.Pages[0],
    'Tecla esquerda nao retornou a selecao da tab horizontal.');
  SendCtrlTab(LHorizontalTabs);
  Require(LHorizontalTabs.ActivePage = LHorizontalTabs.Pages[1],
    'Ctrl+Tab nao preservou a navegacao nativa do TPageControl.');
  SendKey(LHorizontalTabs, VK_LEFT);
  LTabHeaderPoint := LTabHeader.ClientToScreen(Point(0, 0));
  LHorizontalContentPoint := LHorizontalText.ClientToScreen(Point(0, 0));
  LPageContentPoint := LHorizontalTabs.ActivePage.ClientToScreen(Point(0, 0));
  Require((LHorizontalContentPoint.Y >= LTabHeaderPoint.Y + LTabHeader.Height + 4) and
    (LHorizontalContentPoint.X >= LPageContentPoint.X) and
    (LHorizontalContentPoint.X + LHorizontalText.Width <=
      LPageContentPoint.X + LHorizontalTabs.ActivePage.ClientWidth),
    Format('Conteudo horizontal nao foi posicionado abaixo do header no ClientRect real (content=%d,%d headerBottom=%d page=%d..%d).',
      [LHorizontalContentPoint.X, LHorizontalContentPoint.Y,
       LTabHeaderPoint.Y + LTabHeader.Height, LPageContentPoint.X,
       LPageContentPoint.X + LHorizontalTabs.ActivePage.ClientWidth]));
  LHorizontalTabs.Visible := False;
  PumpMessages(30);
  Require(not LTabHeader.Visible and not LTabHeader.Showing,
    'Header horizontal permaneceu visivel depois que o host TDACTabs foi ocultado.');
  LHorizontalTabs.Visible := True;
  PumpMessages(30);
  Require(LTabHeader.Visible and LTabHeader.Showing and
    (LTabHeader.Parent = LHorizontalTabs.Parent),
    'Header horizontal nao retornou com o host TDACTabs.');
  LHorizontalTabs.SetFocus;
  LHorizontalTabs.ActivePage :=
    Form1.FindComponent('demoTabsSecond') as TTabSheet;
  PumpMessages(1);
  RequireTabHeaderFrame(LTabHeader, 'tabs durante a troca');
  PumpMessages(30);
  RequireTabHeaderFrame(LTabHeader, 'tabs estabilizadas');
  Require((LHorizontalTabs.ActivePage.Name = 'demoTabsSecond') and
    (Form1.FindComponent('demoTabsSecondText') as TDACSystemText).Visible,
    'Selecao e conteudo da tab horizontal nao responderam.');
  LHorizontalText := Form1.FindComponent('demoTabsSecondText') as TDACSystemText;
  LHorizontalContentPoint := LHorizontalText.ClientToScreen(Point(0, 0));
  Require(LHorizontalContentPoint.Y >= LTabHeaderPoint.Y + LTabHeader.Height + 4,
    Format('Conteudo de Detalhes permaneceu atras do header horizontal (contentTop=%d, headerBottom=%d).',
      [LHorizontalContentPoint.Y, LTabHeaderPoint.Y + LTabHeader.Height]));
  LTabs := Form1.FindComponent('demoVerticalTabs') as TDACTabs;
  LTabs.RefreshContentLayout;
  PumpMessages(20);
  Require(LTabs.Orientation = mtoVertical,
    'Demo de tabs vertical nao foi materializada.');
  Require((LTabs.Appearance = mtaUnderline) and
    (LTabs.Size = mtsMedium) and
    (LTabs.Pages[0].Caption = 'Geral') and
    (LTabs.Pages[1].Caption = 'Detalhes') and
    (LTabs.Pages[2].Caption = 'Historico'),
    'Header vertical nao materializou as tres captions distintas.');
  LTabHeader := FindTabHeader(LTabs);
  Require((LTabHeader <> nil) and LTabHeader.Visible and
    (LTabHeader.Width >= Round(LTabs.ResolvedTokens.TabsVerticalExtent)) and (LTabHeader.Height = LTabs.Height) and
    (LTabHeader.Parent = LTabs.Parent) and
    (LTabHeader.Left = LTabs.Left) and (LTabHeader.Top = LTabs.Top),
    'Header vertical nao reservou largura fixa suficiente para as captions.');
  LTabs.Visible := False;
  PumpMessages(30);
  Require(not LTabHeader.Visible and not LTabHeader.Showing,
    'Header vertical permaneceu visivel depois que o host TDACTabs foi ocultado.');
  LTabs.Visible := True;
  PumpMessages(30);
  Require(LTabHeader.Visible and LTabHeader.Showing and
    (LTabHeader.Parent = LTabs.Parent) and (LTabHeader.Width >= Round(LTabs.ResolvedTokens.TabsVerticalExtent)),
    'Header vertical nao retornou com o host TDACTabs.');
  Require(LTabs.ContentInset >= LTabHeader.Width + Round(LTabs.ResolvedTokens.TabsContentGutter),
    'Inset vertical nao reservou gutter apos o header Skia.');
  LTabLayout := LTabHeader.BuildTabLayout;
  LTabSelectionRect := LTabHeader.TabRectForPage(LTabs.ActiveIndex);
  Require((Length(LTabLayout) = 3) and
    (Abs(LTabSelectionRect.Left - LTabs.ResolvedTokens.TabsHeaderInset) < 0.01) and
    (Abs(LTabSelectionRect.Top - LTabs.ResolvedTokens.TabsHeaderInset) < 0.01) and
    (Abs(LTabSelectionRect.Right -
      (LTabHeader.Width - LTabs.ResolvedTokens.TabsHeaderInset)) < 0.01) and
    (Abs(LTabSelectionRect.Height -
      LTabs.ResolvedTokens.TabsMedium.Height) < 0.01) and
    (Abs(LTabLayout[1].Bounds.Top - LTabLayout[0].Bounds.Bottom) < 0.01) and
    (Abs(LTabLayout[2].Bounds.Top - LTabLayout[1].Bounds.Bottom) < 0.01),
    'Line vertical nao empilhou rows MD 40 intrinsecas no rail tokenizado.');
  Require(LTabHeader.HitTestPageAt(
      Round((LTabLayout[2].Bounds.Left + LTabLayout[2].Bounds.Right) / 2),
      Round((LTabLayout[2].Bounds.Top + LTabLayout[2].Bounds.Bottom) / 2)) = 2,
    'Hit-test vertical divergiu dos paint bounds.');
  LTabs.ActivePage := Form1.FindComponent('demoVerticalTabsFirst') as TTabSheet;
  PumpMessages(30);
  LVerticalText := Form1.FindComponent('demoVerticalTabsFirstText') as TDACSystemText;
  LTabHeaderPoint := LTabHeader.ClientToScreen(Point(0, 0));
  LVerticalContentPoint := LVerticalText.ClientToScreen(Point(0, 0));
  LPageContentPoint := LTabs.ActivePage.ClientToScreen(Point(0, 0));
  Require(LVerticalContentPoint.X >= LPageContentPoint.X,
    'Conteudo vertical nao iniciou no ClientRect real da pagina.');
  Require(LVerticalContentPoint.X >= LTabHeaderPoint.X + LTabHeader.Width + Round(LTabs.ResolvedTokens.TabsContentGutter),
    Format('Conteudo vertical iniciou atras do header (contentLeft=%d, headerRight=%d).',
      [LVerticalContentPoint.X, LTabHeaderPoint.X + LTabHeader.Width]));
  Require(LVerticalContentPoint.X + LVerticalText.Width <= LTabHeaderPoint.X + LTabs.Width,
    Format('Conteudo vertical excedeu o viewport da tab (contentLeft=%d, width=%d, contentRight=%d, tabsLeft=%d, tabsRight=%d).',
      [LVerticalContentPoint.X, LVerticalText.Width,
       LVerticalContentPoint.X + LVerticalText.Width, LTabHeaderPoint.X,
       LTabHeaderPoint.X + LTabs.Width]));
  LTabs.ActivePage := Form1.FindComponent('demoVerticalTabsThird') as TTabSheet;
  PumpMessages(30);
  Require((LTabs.ActivePage.Name = 'demoVerticalTabsThird') and
    (Form1.FindComponent('demoVerticalTabsThirdText') as TDACSystemText).Visible,
    'Selecao e conteudo da tab vertical nao responderam.');

  Form1.SetBounds(Form1.Left, Form1.Top, 980, 700);
  PumpMessages(1);
  LGalleryHeader := FindTabHeader(Form1.GalleryTabs);
  RequireTabHeaderFrame(LGalleryHeader, 'resize durante a troca');
  PumpMessages(80);
  RequireTabHeaderFrame(LGalleryHeader, 'resize estabilizado');

  // Resume the compact viewport used by the grid interaction scenario below;
  // its explicit desktop canvas must retain the historical wheel/selection
  // contract independently from the tab layout viewport.
  Form1.SetBounds(Form1.Left, Form1.Top, 520, 560);
  PumpMessages(80);
  LTabs := Form1.FindComponent('GalleryTabs') as TDACTabs;
  LTabs.ActivePage := Form1.FindComponent('tsInputs') as TTabSheet;
  PumpMessages(80);
  Form1.SetBounds(Form1.Left, Form1.Top, 521, 560);
  PumpMessages(30);
  Form1.SetBounds(Form1.Left, Form1.Top, 520, 560);
  PumpMessages(100);
  RequireInputGalleryGeometry(Form1, 'compact no fluxo integrado');
  LTabPage := Form1.FindComponent('tsGrid') as TTabSheet;
  LTabs.ActivePage := LTabPage;
  PumpMessages(80);

  LGrid := Form1.FindComponent('demoDataGrid') as TDACDataGrid;
  LDataSet := Form1.FindComponent('demoGridDataSet') as TClientDataSet;
  LDataSource := Form1.FindComponent('demoGridDataSource') as TDataSource;
  PumpMessages(100);
  Require((LDataSet <> nil) and (LDataSource <> nil) and
    (LDataSource.DataSet = LDataSet) and (LGrid.DataSource = LDataSource),
    'Demo nao conectou o TDACDataGrid ao dataset declarativo de demonstracao.');
  TDACThemeManager.SetApplicationMode(dtmLight);
  RequireDataGridPreviewThemeTokens(dtmLight, 'global light');
  LGrid.ThemeMode := dtmDark;
  RequireDataGridPreviewThemeTokens(LGrid.ThemeMode, 'override local dark');
  Require((LGrid.Color = TDACComponentColors.ToVclColor(TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.DataGridBackground)) and
    (LGrid.FixedColor = TDACComponentColors.ToVclColor(TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.DataGridHeader)) and
    (LGrid.Font.Color = TDACComponentColors.ToVclColor(TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.DataGridText)) and
    (LGrid.TitleFont.Color = TDACComponentColors.ToVclColor(TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.DataGridHeaderText)) and
    SameText(LGrid.Font.Name, TDACComponentStyle.FontFamily),
    'DataGrid nao aplicou override dark nativo.');
  LGrid.ThemeMode := dtmInherit;
  RequireDataGridPreviewThemeTokens(dtmDark, 'inherit em surface dark');
  Require((LGrid.Color = TDACComponentColors.ToVclColor(TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.DataGridBackground)) and
    (LGrid.FixedColor = TDACComponentColors.ToVclColor(TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.DataGridHeader)) and
    (LGrid.Font.Color = TDACComponentColors.ToVclColor(TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.DataGridText)) and
    (LGrid.TitleFont.Color = TDACComponentColors.ToVclColor(TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.DataGridHeaderText)),
    'DataGrid inherit nao preservou a surface dark da TabSheet.');
  TDACThemeManager.SetApplicationMode(dtmDark);
  RequireDataGridPreviewThemeTokens(LGrid.ThemeMode, 'inherit com global dark');
  Require((LGrid.Color = TDACComponentColors.ToVclColor(TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.DataGridBackground)) and
    (LGrid.FixedColor = TDACComponentColors.ToVclColor(TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.DataGridHeader)) and
    (LGrid.Font.Color = TDACComponentColors.ToVclColor(TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.DataGridText)) and
    (LGrid.TitleFont.Color = TDACComponentColors.ToVclColor(TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.DataGridHeaderText)) and
    (TDataGridHandleAccess(LGrid).GridDefaultRowHeight = Round(TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.DataGridMediumRowHeight)) and
    (TDataGridHandleAccess(LGrid).GridHeaderHeight = Round(TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.DataGridMediumHeaderHeight)),
    'DataGrid inherit nao refletiu o global dark e metricas tokenizadas.');
  Require((LGrid.Density = dgdMedium) and
    (LGrid.Font.Size = Round(TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.DataGridMediumTextSize)),
    'DataGrid DFM deve iniciar na densidade MD do contrato MEM-100.');
  LGridChromeRevision := LGrid.ChromeRevision;
  LGrid.CornerRadius := 18;
  PumpMessages(30);
  Require((LGrid.CornerRadius = 18) and
    (LGrid.ChromeRevision > LGridChromeRevision),
    'CornerRadius do DataGrid nao invalidou o painter funcional.');
  LGrid.CornerRadius := DACDataGridDefaultCornerRadius;
  LGridTokens := TDACComponentStyle.ResolveForSurface(LGrid,
    LGrid.ThemeMode).Tokens.Controls;
  LGrid.Density := dgdSmall;
  PumpMessages(30);
  Require((TDataGridHandleAccess(LGrid).GridDefaultRowHeight = Round(
      LGridTokens.DataGridSmallRowHeight)) and
    (TDataGridHandleAccess(LGrid).GridHeaderHeight = Round(
      LGridTokens.DataGridSmallHeaderHeight)) and
    (LGrid.Font.Size = Round(LGridTokens.DataGridSmallTextSize)),
    'DataGrid SM nao aplicou os tokens de densidade.');
  LGrid.Density := dgdLarge;
  PumpMessages(30);
  Require((TDataGridHandleAccess(LGrid).GridDefaultRowHeight = Round(
      LGridTokens.DataGridLargeRowHeight)) and
    (TDataGridHandleAccess(LGrid).GridHeaderHeight = Round(
      LGridTokens.DataGridLargeHeaderHeight)) and
    (LGrid.Font.Size = Round(LGridTokens.DataGridLargeTextSize)),
    'DataGrid LG nao aplicou os tokens de densidade.');
  LGrid.Density := dgdMedium;
  PumpMessages(30);
  LDataSet.First;
  LGridRecNo := LDataSet.RecNo;
  TDACThemeManager.SetApplicationMode(dtmLight);
  LGrid.Loading := True;
  SendKey(LGrid, VK_DOWN);
  LGrid.Perform(WM_LBUTTONDOWN, MK_LBUTTON, 20 or (112 shl 16));
  LGrid.Perform(WM_LBUTTONUP, 0, 20 or (112 shl 16));
  LGridTopRow := TDataGridHandleAccess(LGrid).GridTopRow;
  LGrid.Perform(WM_MOUSEWHEEL, WPARAM($FF880000), 0);
  PumpMessages(50);
  Require(LGrid.Loading and (LDataSet.RecNo = LGridRecNo) and
    (TDataGridHandleAccess(LGrid).GridTopRow = LGridTopRow),
    'Loading deve bloquear teclado, mouse e WM_MOUSEWHEEL sem navegar ou rolar o dataset.');
  Require((TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.DataGridLoading <>
    TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.DataGridEmpty) and
    (TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.DataGridFocus <>
    TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.DataGridDisabledText),
    'Paleta Light nao declarou loading/empty/focus distintos.');
  LGrid.Loading := False;
  LEmptyDataSet := TClientDataSet.Create(Form1);
  LEmptyDataSet.FieldDefs.Add('ID', ftInteger);
  LEmptyDataSet.FieldDefs.Add('STATUS', ftString, 16);
  LEmptyDataSet.CreateDataSet;
  LEmptyDataSource := TDataSource.Create(Form1);
  LEmptyDataSource.DataSet := LEmptyDataSet;
  TDACThemeManager.SetApplicationMode(dtmDark);
  LGrid.DataSource := LEmptyDataSource;
  LGrid.Redraw;
  PumpMessages(50);
  Require(LEmptyDataSet.Active and (LEmptyDataSet.RecordCount = 0) and
    (LGrid.DataSource = LEmptyDataSource),
    'Empty deve derivar de dataset ativo vazio sem alterar seus registros.');
  Require((TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.DataGridEmpty <>
    TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.DataGridLoading) and
    (TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.DataGridError <>
    TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.DataGridSuccess),
    'Paleta Dark nao declarou empty/loading/error/success distintos.');
  LGrid.DataSource := LDataSource;
  PumpMessages(50);
  Require((LGrid.Width >= 900) and (LGrid.Height >= 420) and
    (LGrid.Font.Size = 13) and (LGrid.TitleFont.Size = 13) and
    (TDataGridHandleAccess(LGrid).GridDefaultRowHeight = 36) and
    (TDataGridHandleAccess(LGrid).GridHeaderHeight = 40),
    Format('Grid da Demo nao reservou area e tipografia legiveis (width=%d, height=%d, font=%d, title=%d, row=%d, header=%d).',
      [LGrid.Width, LGrid.Height, LGrid.Font.Size, LGrid.TitleFont.Size,
       TDataGridHandleAccess(LGrid).GridDefaultRowHeight,
       TDataGridHandleAccess(LGrid).GridHeaderHeight]));
  Require(LDataSet.RecordCount >= 30,
    'Demo precisa expor ao menos 30 registros para demonstrar rolagem.');
  Require(LGrid.Columns.Count >= 7,
    'Grid nao gerou as colunas automaticas do dataset da Demo.');
  Require((LGrid.Columns[1].Width >= 200) and (LGrid.Columns[2].Width >= 160) and
    (LGrid.Columns[6].Width >= 120),
    'Colunas de Cliente, Cidade ou Acoes ficaram estreitas/truncadas.');
  LDataSet.First;
  PumpMessages(80);
  LGridChromeRevision := LGrid.ChromeRevision;
  LDataSet.Next;
  PumpMessages(120);
  Require((LDataSet.RecNo = 2) and (LGrid.ChromeRevision > LGridChromeRevision),
    'Mudanca externa de registro nao atualizou o overlay Skia pelo DataLink.');
  LGridChromeRevision := LGrid.ChromeRevision;
  LDataSet.Edit;
  LDataSet.FieldByName('CLIENTE').AsString := 'Cliente alterado externamente';
  LDataSet.Post;
  PumpMessages(120);
  Require(LGrid.ChromeRevision > LGridChromeRevision,
    'Edicao externa do dataset nao atualizou o overlay Skia pelo DataLink.');
  LReplacementDataSet := TClientDataSet.Create(Form1);
  LReplacementSource := TDataSource.Create(Form1);
  LReplacementDataSet.FieldDefs.Add('ID', ftInteger);
  LReplacementDataSet.FieldDefs.Add('CLIENTE', ftString, 48);
  LReplacementDataSet.FieldDefs.Add('CIDADE', ftString, 48);
  LReplacementDataSet.FieldDefs.Add('STATUS', ftString, 16);
  LReplacementDataSet.FieldDefs.Add('VALOR', ftCurrency);
  LReplacementDataSet.FieldDefs.Add('DATA', ftDate);
  LReplacementDataSet.FieldDefs.Add('ACTIONS', ftString, 16);
  LReplacementDataSet.CreateDataSet;
  LReplacementDataSet.AppendRecord([9001, 'Fonte substituta 1', 'Sao Paulo',
    'Ativo', 100, EncodeDate(2026, 7, 21), 'Acoes']);
  LReplacementDataSet.AppendRecord([9002, 'Fonte substituta 2', 'Campinas',
    'Pendente', 200, EncodeDate(2026, 7, 22), 'Acoes']);
  LReplacementDataSet.First;
  LReplacementSource.DataSet := LReplacementDataSet;
  LGrid.DataSource := LReplacementSource;
  PumpMessages(100);
  LGridChromeRevision := LGrid.ChromeRevision;
  LReplacementDataSet.Next;
  PumpMessages(120);
  Require((LGrid.DataSource = LReplacementSource) and
    (LReplacementDataSet.RecNo = 2) and
    (LGrid.ChromeRevision > LGridChromeRevision),
    'Reatribuicao de DataSource nao conectou o novo DataLink ao overlay Skia.');
  LGrid.DataSource := LDataSource;
  PumpMessages(100);
  LDataSet.First;
  PumpMessages(80);
  // Leave the first DataLink update posted to the old HWND, then recreate
  // immediately. The following event must still queue a repaint on the new
  // HWND after DestroyWnd/CreateWnd reset FChromeUpdatePending.
  LDataSet.Next;
  TDataGridHandleAccess(LGrid).RecreateNativeHandle;
  LGridChromeRevision := LGrid.ChromeRevision;
  LDataSet.Next;
  PumpMessages(120);
  Require((LDataSet.RecNo = 3) and (LGrid.ChromeRevision > LGridChromeRevision),
    'Mensagem pendente do HWND antigo bloqueou o DataLink apos RecreateWnd.');
  LGrid.SetFocus;
  LGridRecNo := LDataSet.RecNo;
  SendKey(LGrid, VK_DOWN);
  Require(LDataSet.RecNo = LGridRecNo + 1,
    'Seta para baixo nao navegou a linha ativa do TDACDataGrid.');
  LDataSet.First;
  PumpMessages(80);
  LGridRecNo := LDataSet.RecNo;
  LGrid.Perform(WM_LBUTTONDOWN, MK_LBUTTON,
    20 or (112 shl 16));
  LGrid.Perform(WM_LBUTTONUP, 0,
    20 or (112 shl 16));
  PumpMessages(50);
  Require(LDataSet.RecNo <> LGridRecNo,
    'Clique em linha visivel nao selecionou outro registro do TDACDataGrid.');
  Require((TDataGridHandleAccess(LGrid).GridRow >=
    TDataGridHandleAccess(LGrid).GridFixedRows) and
    (TDataGridHandleAccess(LGrid).GridColumn >= 0),
    'Clique nao deixou selecao de linha/coluna materializada no TDACDataGrid.');
  LGridChromeRevision := LGrid.ChromeRevision;
  LGrid.Perform(WM_VSCROLL, SB_LINEDOWN, 0);
  PumpMessages(80);
  Require(LGrid.Focused and
    (LGrid.ChromeRevision > LGridChromeRevision),
    'WM_VSCROLL nao manteve o foco ou nao sincronizou o overlay Skia.');
  LGridChromeRevision := LGrid.ChromeRevision;
  LGrid.Perform(WM_VSCROLL, SB_LINEDOWN, 0);
  LExpectedRecNo := LDataSet.RecNo;
  PumpMessages(80);
  Require((LDataSet.RecNo = LExpectedRecNo) and
    (LGrid.ChromeRevision > LGridChromeRevision),
    'O repaint Skia postado apos scroll alterou o cursor ou nao redesenhou.');

  LGridPaintBox := nil;
  for I := 0 to LGrid.ComponentCount - 1 do
    if LGrid.Components[I] is TDACDataGridPaintBox then
    begin
      LGridPaintBox := TDACDataGridPaintBox(LGrid.Components[I]);
      Break;
    end;
  Require(Assigned(LGridPaintBox),
    'DataGrid nao materializou o paintbox Skia para testar a roda real.');
  LDataSet.First;
  PumpMessages(80);
  LGridRecNo := LDataSet.RecNo;
  LGridTopRow := TDataGridHandleAccess(LGrid).GridTopRow;
  Require(TDataGridPaintBoxAccess(LGridPaintBox).SimulateMouseWheel(-60),
    'Delta parcial anterior ao Loading nao foi consumido pelo DataGrid.');
  LGrid.Loading := True;
  LGrid.Loading := False;
  Require(TDataGridPaintBoxAccess(LGridPaintBox).SimulateMouseWheel(-60),
    'Delta parcial posterior ao Loading nao foi consumido pelo DataGrid.');
  PumpMessages(30);
  Require((LDataSet.RecNo = LGridRecNo) and
    (TDataGridHandleAccess(LGrid).GridTopRow = LGridTopRow),
    'Loading preservou metade de um gesto e rolou a grid apos o desbloqueio.');
  // Reset the second isolated fragment before checking the normal two-part
  // high-resolution gesture below.
  LGrid.Loading := True;
  LGrid.Loading := False;
  LGridChromeRevision := LGrid.ChromeRevision;
  Require(TDataGridPaintBoxAccess(LGridPaintBox).SimulateMouseWheel(-60),
    'Primeiro delta parcial da roda nao foi consumido pelo DataGrid.');
  PumpMessages(30);
  Require((LDataSet.RecNo = LGridRecNo) and
    (TDataGridHandleAccess(LGrid).GridTopRow = LGridTopRow) and
    (LGrid.ChromeRevision = LGridChromeRevision),
    'Delta parcial isolado rolou a grid antes de completar um detent.');
  Require(TDataGridPaintBoxAccess(LGridPaintBox).SimulateMouseWheel(-60),
    'Segundo delta parcial da roda nao foi consumido pelo DataGrid.');
  PumpMessages(100);
  Require((LDataSet.RecNo > LGridRecNo) and
    (TDataGridHandleAccess(LGrid).GridTopRow >= LGridTopRow) and
    (LGrid.ChromeRevision > LGridChromeRevision),
    'Dois deltas parciais nao formaram um detent descendente sincronizado.');
  Require(TDataGridHandleAccess(LGrid).GridBufferedRecordCount >= 3,
    'Roda deixou o buffer visual do DataLink esparso.');

  LDataSet.First;
  PumpMessages(50);
  LGridTokens := TDACComponentStyle.Resolve(LGrid.ThemeMode).Tokens.Controls;
  LGridActionCell := TDataGridHandleAccess(LGrid).GridCellRect(6,
    TDataGridHandleAccess(LGrid).GridFixedRows);
  LGridActionX := LGridActionCell.Left +
    Max(Round(LGridTokens.DataGridActionInset),
      (LGridActionCell.Width - ((Round(LGridTokens.DataGridActionSize) * 3) +
      (Round(LGridTokens.DataGridActionGap) * 2))) div 2) +
    (Round(LGridTokens.DataGridActionSize) div 2);
  LGridActionY := LGridActionCell.Top + (LGridActionCell.Height div 2);
  LProbe.ActionCount := 0;
  LProbe.LastAction := mdgakNone;
  LProbe.LastActionColumn := nil;
  LGrid.OnActionClick := LProbe.OnDataGridAction;
  LGrid.Perform(WM_LBUTTONDOWN, MK_LBUTTON,
    LGridActionX or (LGridActionY shl 16));
  LGrid.Perform(WM_LBUTTONUP, 0,
    LGridActionX or (LGridActionY shl 16));
  PumpMessages(50);
  Require((LProbe.ActionCount = 1) and (LProbe.LastAction = mdgakEdit) and
    (LProbe.LastActionColumn = LGrid.Columns[6]),
    'OnActionClick nao entregou a acao Edit e a coluna ACTIONS esperadas.');
  LGridRecNo := LDataSet.RecNo;
  LGridTopRow := TDataGridHandleAccess(LGrid).GridTopRow;
  LGrid.Loading := True;
  LGrid.Perform(WM_LBUTTONDOWN, MK_LBUTTON,
    LGridActionX or (LGridActionY shl 16));
  LGrid.Perform(WM_LBUTTONUP, 0,
    LGridActionX or (LGridActionY shl 16));
  PumpMessages(50);
  Require((LProbe.ActionCount = 1) and (LDataSet.RecNo = LGridRecNo) and
    (TDataGridHandleAccess(LGrid).GridTopRow = LGridTopRow),
    'Loading permitiu acao ou navegacao nativa do TDACDataGrid.');
  LGrid.Loading := False;

  LGrid.ReadOnly := False;
  LGrid.Options := (LGrid.Options - [dgRowSelect]) + [dgEditing];
  LDataSet.First;
  LGridOriginalClient := LDataSet.FieldByName('CLIENTE').AsString;
  LGridActionCell := TDataGridHandleAccess(LGrid).GridCellRect(1,
    TDataGridHandleAccess(LGrid).GridFixedRows);
  LGrid.Perform(WM_LBUTTONDOWN, MK_LBUTTON,
    (LGridActionCell.Left + 12) or ((LGridActionCell.Top + 12) shl 16));
  LGrid.Perform(WM_LBUTTONUP, 0,
    (LGridActionCell.Left + 12) or ((LGridActionCell.Top + 12) shl 16));
  LGrid.SetFocus;
  SendKey(LGrid, VK_F2);
  PumpMessages(50);
  Require(TDataGridHandleAccess(LGrid).GridEditorMode,
    'Celula editavel nao entrou em EditorMode pelo teclado nativo.');
  TDataGridHandleAccess(LGrid).GridEditorChar('~');
  PumpMessages(50);
  LGrid.Perform(WM_CHAR, Ord(#13), 0);
  PumpMessages(50);
  Require(LDataSet.FieldByName('CLIENTE').AsString <> LGridOriginalClient,
    Format('Edicao nativa nao confirmou o texto no campo (EditorMode=%s, State=%d, Value=%s).',
      [BoolToStr(TDataGridHandleAccess(LGrid).GridEditorMode, True), Ord(LDataSet.State),
       LDataSet.FieldByName('CLIENTE').AsString]));
  if LDataSet.State in dsEditModes then
    LDataSet.Post;
  Require((LDataSet.RecNo = 1) and
    (LDataSet.FieldByName('CLIENTE').AsString <> LGridOriginalClient),
    'Edicao nativa nao materializou o valor no registro ativo.');
  LDataSet.Edit;
  LDataSet.FieldByName('CLIENTE').AsString := LGridOriginalClient;
  LDataSet.Post;
  LGrid.Loading := True;
  SendKey(LGrid, VK_F2);
  TDataGridHandleAccess(LGrid).GridEditorChar('!');
  PumpMessages(50);
  Require((not TDataGridHandleAccess(LGrid).GridEditorMode) and
    (LDataSet.State = dsBrowse) and
    (LDataSet.FieldByName('CLIENTE').AsString = LGridOriginalClient),
    'Loading permitiu abrir ou alterar o editor nativo.');
  LGrid.Loading := False;
  LGrid.ReadOnly := True;

  LTooltip := Form1.FindComponent('demoTooltip') as TDACTooltip;
  LTooltip.TargetControl := LButton;
  LTooltip.ShowForTarget;
  RequireVisibleWithin(LTooltip, True, 500, 'Tooltip nao foi exibido.');
  PumpMessages(160);
  Require(LTooltip.Visible,
    'Tooltip programatico foi ocultado pelo rastreador sem HideTooltip.');
  LTooltip.HideTooltip;
  RequireVisibleWithin(LTooltip, False, 500, 'Tooltip nao foi ocultado.');

  LToast := Form1.FindComponent('demoToast') as TDACToast;
  LToast.TitleText := 'Interaction toast';
  LToast.MessageText := 'Feedback validado.';
  LToast.Visible := True;
  Require(LToast.Visible and (LToast.TitleText = 'Interaction toast'),
    'Toast nao respondeu ao feedback.');

  LModal := TDACModalDialog.Create(Form1);
  LModal.Parent := Form1;
  LModal.SetBounds(20, 20, 320, 180);
  LModal.Visible := True;
  SendKey(LModal, VK_ESCAPE);
  Require(not LModal.Visible, 'Escape nao fechou TDACModalDialog.');

  LPagination := Form1.FindComponent('demoPagination') as TDACPagination;
  LPagination.PageIndex := 2;
  Require((LPagination.PageIndex >= 1) and
    (LPagination.PageIndex <= LPagination.PageCount), 'Paginacao fora do limite.');

  LBadge := Form1.FindComponent('demoBadge') as TDACBadge;
  Require(LBadge.Visible, 'Badge nao esta visivel.');
  LWidthBefore := LTabs.Width;
  Form1.SetBounds(Form1.Left, Form1.Top, Form1.Width + 120, Form1.Height + 80);
  PumpMessages(100);
  Require(LTabs.Width <> LWidthBefore, 'Resize nao atualizou o layout das tabs.');
  LTabs.ActivePage := Form1.tsButtons;
  Form1.SetBounds(Form1.Left, Form1.Top, 180, 560);
  PumpMessages(100);
  Require(LNavigation.Visible and
    (LNavigation.Width = TDACDemoTokens.Default.NavigationCompactWidth),
    'Rail compacta deixou de preservar acesso as 17 paginas no viewport minimo.');
  Require((Form1.GalleryTabs.Left = LNavigation.Width) and
    (Form1.GalleryTabs.Width = Form1.ClientWidth - LNavigation.Width),
    'Galeria nao respeitou a rail compacta no viewport minimo.');
  Require(UnexpectedException = '', 'Excecao VCL: ' + UnexpectedException);
  finally
    LProbe.Free;
  end;
end;

var
  LExitCode: Integer;
  LProbe: TInteractionProbe;

  procedure DisposeDemoForm;
  begin
    if Form1 <> nil then
    begin
      Form1.Free;
      Form1 := nil;
    end;
    Require(DACNativeScrollBarHookAuthorityTotalCount = 0,
      Format('MEM-DEL-DB-065 authority teardown leak: total=%d.',
        [DACNativeScrollBarHookAuthorityTotalCount]));
    Writeln('MEM-DEL-DB-065 authority final PASS: total=0');
  end;
begin
  TestStatusTimelineContract;
  LExitCode := 0;
  Application.Initialize;
  Application.MainFormOnTaskbar := False;
  LProbe := TInteractionProbe.Create;
  try
    // Keep the application exception hook alive through destruction and one
    // final message drain.  A component that posts an exception while its
    // owner form is going away must fail this executable, never open a VCL
    // dialog after a misleading PASS line has already been printed.
    Application.OnException := LProbe.OnApplicationException;
    try
      RunInteraction;
    except
      on E: Exception do
      begin
        Writeln(E.ClassName + ': ' + E.Message);
        LExitCode := 1;
      end;
    end;
    try
      DisposeDemoForm;
      Application.ProcessMessages;
      if UnexpectedException <> '' then
      begin
        Writeln('VCL teardown exception: ' + UnexpectedException);
        LExitCode := 1;
      end;
    except
      on E: Exception do
      begin
        Writeln('Teardown ' + E.ClassName + ': ' + E.Message);
        LExitCode := 1;
      end;
    end;
  finally
    Application.OnException := nil;
    LProbe.Free;
  end;
  if LExitCode = 0 then
    Writeln('DACComponentsInteraction: PASS (clean teardown)');
  ExitCode := LExitCode;
end.
