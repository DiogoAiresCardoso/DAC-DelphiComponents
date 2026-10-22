unit DAC.Components.Controls.DBGrid;

interface

uses
  System.Classes,
  System.Generics.Collections,
  System.Types,
  Data.DB,
  Winapi.Messages,
  Vcl.Controls,
  Vcl.DBGrids,
  Vcl.Grids,
  DAC.Components.Controls.DBGrid.Action,
  DAC.Components.Controls.DBGrid.ActionTypes,
  DAC.Components.Controls.DBGrid.ActionPainter,
  DAC.Components.Controls.DBGrid.Column,
  DAC.Components.Controls.DBGrid.BadgePainter,
  DAC.Components.Controls.DBGrid.CellPainter,
  DAC.Components.Controls.DBGrid.Columns,
  DAC.Components.Controls.DBGrid.DataLink,
  DAC.Components.Controls.DBGrid.FramePainter,
  DAC.Components.Controls.DBGrid.FieldText,
  DAC.Components.Controls.DBGrid.HeaderPainter,
  DAC.Components.Controls.DBGrid.LayoutManager,
  DAC.Components.Controls.DBGrid.LayoutOptions,
  DAC.Components.Controls.DBGrid.SelectionController,
  DAC.Components.Controls.DBGrid.SelectionOptions,
  DAC.Components.Controls.DBGrid.SortController,
  DAC.Components.Controls.DBGrid.SurfaceBuffer,
  DAC.Components.Controls.DBGrid.Types,
  DAC.Components.DesignSystem.Theme;

type
  TDACDBGridActionStateEvent = procedure(Sender: TObject; AColumn: TDACDBGridColumn;
    AAction: TDACDBGridAction; const AContext: TDACDBGridActionContext;
    var AVisible, AEnabled: Boolean) of object;
  TDACDBGridActionExecuteEvent = procedure(Sender: TObject; AColumn: TDACDBGridColumn;
    AAction: TDACDBGridAction; const AContext: TDACDBGridActionContext) of object;

  TDACDBGrid = class(TCustomDBGrid)
  private
    FActionPainter: TDACDBGridActionPainter;
    FActionKeyFields: string;
    FOnActionState: TDACDBGridActionStateEvent;
    FOnActionExecute: TDACDBGridActionExecuteEvent;
    FActionMode, FActionMouse, FActionKeyDown, FQueryingAction: Boolean;
    FPressedActionId, FPressedActionColumn: string;
    FFocusedActionId, FFocusedActionColumn: string;
    FPressedActionRow, FHotActionIndex: Integer;
    FDataRevision, FPressedActionRevision: Cardinal;
    procedure CancelActionInteraction(const AExitMode: Boolean = False);
    function BuildActionViews(AColumn: TDACDBGridColumn; const ARect: TRect;
      const AContext: TDACDBGridActionContext): TArray<TDACDBGridActionView>;
    function ActionCell(const ACol, ARow: Integer; out AColumn: TDACDBGridColumn;
      out AContext: TDACDBGridActionContext): TArray<TDACDBGridActionView>;
    function ActionHit(const X, Y: Integer; out AColumn: TDACDBGridColumn;
      out AView: TDACDBGridActionView; out AContext: TDACDBGridActionContext): Boolean;
    function FocusAction(const ADirection: Integer; const AEnterMode: Boolean): Boolean;
    procedure ExecuteFocusedAction;
    procedure SetActionKeyFields(const AValue: string);
    procedure CMHintShow(var AMessage: TCMHintShow); message CM_HINTSHOW;
  private
    FBadgePainter: TDACDBGridBadgePainter;
    FCellPainter: TDACDBGridCellPainter;
    FDensity: TDACDBGridDensity;
    FEmptyText: string;
    FApplyingDensityMetrics: Boolean;
    FFramePainter: TDACDBGridFramePainter;
    FHeaderPainter: TDACDBGridHeaderPainter;
    FHotCell: TGridCoord;
    FHoverEnabled: Boolean;
    FLayoutManager: TDACDBGridLayoutManager;
    FLayoutOptions: TDACDBGridLayoutOptions;
    FLoading: Boolean;
    FNativeScrollMouseTracking: Boolean;
    FNativeScrollPaintActive: Boolean;
    FNativeScrollPaintPending: Boolean;
    FOnLayoutError: TDACDBGridErrorEvent;
    FOnSelectionChanged: TDACDBGridSelectionChangedEvent;
    FOnSelectionError: TDACDBGridErrorEvent;
    FOnSortRequest: TDACDBGridSortRequestEvent;
    FPressedTitleColumn: Integer;
    FRecalculatingSelection: Boolean;
    FRowSelectionEnabled: Boolean;
    FSelectionController: TDACDBGridSelectionController;
    FSelectionOptions: TDACDBGridSelectionOptions;
    FSelectionState: TDACDBGridSelectionState;
    FSortController: TDACDBGridSortController;
    FSurfaceBuffer: TDACDBGridSurfaceBuffer;
    FTextItems: TList<TDACDBGridTextItem>;
    FThemeMode: TDACThemeMode;
    FZebraEnabled: Boolean;
    procedure ApplyDensityMetrics;
    function BuildLayoutIdentity: string;
    procedure CMEnabledChanged(var AMessage: TMessage); message CM_ENABLEDCHANGED;
    procedure CMMouseLeave(var AMessage: TMessage); message CM_MOUSELEAVE;
    procedure CMParentColorChanged(var AMessage: TMessage);
      message CM_PARENTCOLORCHANGED;
    procedure DataLinkChanged(Sender: TObject; AField: TField);
    procedure DrawDataRows;
    procedure DrawHeaders;
    function DisplayCellRect(const ACol, ARow: Integer): TRect;
    function EffectivePPI: Integer;
    function EffectiveHeaderHeight: Integer;
    function GetColumns: TDACDBGridColumns;
    function HeaderHeight: Integer;
    procedure LayoutError(Sender: TObject; const AMessage: string);
    procedure LayoutOptionsChanged(Sender: TObject);
    procedure PaintNativeScrollBars;
    function Pixels(const AValue: Integer): Integer;
    procedure QueueNativeScrollPaint;
    procedure RecalculateSelectionState;
    function RowHeightForDensity: Integer;
    procedure SelectionOptionsChanged(Sender: TObject);
    procedure SetColumns(const AValue: TDACDBGridColumns);
    procedure SetDensity(const AValue: TDACDBGridDensity);
    procedure SetEmptyText(const AValue: string);
    procedure SetHoverEnabled(const AValue: Boolean);
    procedure SetLayoutOptions(const AValue: TDACDBGridLayoutOptions);
    procedure SetLoading(const AValue: Boolean);
    procedure SetRowSelectionEnabled(const AValue: Boolean);
    procedure SetSelectionOptions(const AValue: TDACDBGridSelectionOptions);
    procedure SetThemeMode(const AValue: TDACThemeMode);
    procedure SetZebraEnabled(const AValue: Boolean);
    procedure ThemeChanged(Sender: TObject);
    procedure TrackNativeScrollMouseLeave;
    procedure ToggleCurrentSelection;
    procedure ToggleSelectAll;
    procedure UpdateLayoutIdentity;
    procedure UpdateNativeOptions;
    procedure WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
      message WM_ERASEBKGND;
    procedure WMNCPaint(var AMessage: TWMNCPaint); message WM_NCPAINT;
  protected
    function CanEditAcceptKey(Key: Char): Boolean; override;
    function CanEditModify: Boolean; override;
    function CanEditShow: Boolean; override;
    procedure ChangeScale(M, D: Integer; isDpiChange: Boolean); override;
    procedure ColumnMoved(FromIndex, ToIndex: Longint); override;
    procedure ColWidthsChanged; override;
    function CreateColumns: TDBGridColumns; override;
    function CreateDataLink: TGridDataLink; override;
    procedure CreateWnd; override;
    procedure DestroyWnd; override;
    procedure DrawCell(ACol, ARow: Longint; ARect: TRect;
      AState: TGridDrawState); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    procedure Click; override;
    procedure Loaded; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure Paint; override;
    procedure Resize; override;
    procedure SetColumnAttributes; override;
    procedure TitleClick(Column: TColumn); override;
    procedure WndProc(var Message: TMessage); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ActionRect(const AColumnIndex, AVisibleRowIndex, AActionIndex: Integer): TRect;
    procedure LoadLayout;
    procedure Redraw;
    procedure ResetLayout;
    procedure SaveLayout;
    procedure SetColumnVisible(const ALayoutKey: string;
      const AVisible: Boolean);
    property Canvas;
  published
    property ActionKeyFields: string read FActionKeyFields write SetActionKeyFields;
    property OnActionState: TDACDBGridActionStateEvent read FOnActionState write FOnActionState;
    property OnActionExecute: TDACDBGridActionExecuteEvent read FOnActionExecute write FOnActionExecute;
    property Align;
    property Anchors;
    property BiDiMode;
    property Columns: TDACDBGridColumns read GetColumns write SetColumns;
    property Constraints;
    property DataSource;
    property Density: TDACDBGridDensity read FDensity write SetDensity
      default dgdStandard;
    property EmptyText: string read FEmptyText write SetEmptyText;
    property Enabled;
    property HoverEnabled: Boolean read FHoverEnabled write SetHoverEnabled
      default True;
    property Hint;
    property Layout: TDACDBGridLayoutOptions read FLayoutOptions
      write SetLayoutOptions;
    property Loading: Boolean read FLoading write SetLoading default False;
    property ParentBiDiMode;
    property ParentShowHint;
    property PopupMenu;
    property RowSelectionEnabled: Boolean read FRowSelectionEnabled
      write SetRowSelectionEnabled default True;
    property Selection: TDACDBGridSelectionOptions read FSelectionOptions
      write SetSelectionOptions;
    property ShowHint;
    property TabOrder;
    property TabStop default True;
    property ThemeMode: TDACThemeMode read FThemeMode write SetThemeMode
      default dtmInherit;
    property Visible;
    property ZebraEnabled: Boolean read FZebraEnabled write SetZebraEnabled
      default True;
    property OnCellClick;
    property OnClick;
    property OnColumnMoved;
    property OnDblClick;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnLayoutError: TDACDBGridErrorEvent read FOnLayoutError
      write FOnLayoutError;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnSelectionChanged: TDACDBGridSelectionChangedEvent
      read FOnSelectionChanged write FOnSelectionChanged;
    property OnSelectionError: TDACDBGridErrorEvent read FOnSelectionError
      write FOnSelectionError;
    property OnSortRequest: TDACDBGridSortRequestEvent read FOnSortRequest
      write FOnSortRequest;
    property OnTitleClick;
  end;

implementation

uses
  System.Math,
  System.Skia,
  System.SysUtils,
  System.UITypes,
  Winapi.Windows,
  Vcl.Forms,
  Vcl.Graphics,
  DAC.Components.Controls.DBGrid.NativeText,
  DAC.Components.Controls.NativeWindowTheme,
  DAC.Components.DesignSystem.ColorTokens,
  DAC.Components.DesignSystem.ComponentStyle,
  DAC.Components.DesignSystem.ControlTokens,
  DAC.Components.Skia.ScrollBarRenderer;

const
  WM_DAC_DBGRID_PAINT_NATIVE_SCROLL = WM_APP + $4D7;

function CurrentWindowsUser: string;
var
  LBuffer: array[0..255] of Char;
  LSize: Cardinal;
begin
  LSize := Length(LBuffer);
  if GetUserName(LBuffer, LSize) then
    Result := LBuffer
  else
    Result := GetEnvironmentVariable('USERNAME');
end;

function MakeGridCoord(const AX, AY: Integer): TGridCoord;
begin
  Result.X := AX;
  Result.Y := AY;
end;

function SameGridCoord(const ALeft, ARight: TGridCoord): Boolean;
begin
  Result := (ALeft.X = ARight.X) and (ALeft.Y = ARight.Y);
end;

function TDACDBGrid.DisplayCellRect(const ACol, ARow: Integer): TRect;
var I, X, LineWidth: Integer; Origin: TRect;
begin
  Result := TRect.Empty;
  if (ACol < 0) or (ACol >= ColCount) or (ARow < 0) or (ARow >= RowCount) then Exit;
  if ACol < FixedCols then Exit(CellRect(ACol, ARow));
  if ACol < LeftCol then Exit;
  // CellRect may alias an offscreen column to the last visible column when
  // an earlier column is wider than the viewport. Use the actual column extents.
  Origin := CellRect(LeftCol, ARow);
  if Origin.IsEmpty then Exit;
  LineWidth := 0;
  if dgColLines in Options then LineWidth := GridLineWidth;
  if UseRightToLeftAlignment then
  begin
    X := Origin.Right;
    for I := LeftCol to ACol - 1 do Dec(X, Max(0, ColWidths[I] + LineWidth));
    if X <= 0 then Exit;
    Exit(Rect(X - Max(0, ColWidths[ACol]), Origin.Top, X, Origin.Bottom));
  end;
  X := Origin.Left;
  for I := LeftCol to ACol - 1 do Inc(X, Max(0, ColWidths[I] + LineWidth));
  if X >= ClientWidth then Exit;
  Result := Rect(X, Origin.Top, X + Max(0, ColWidths[ACol]), Origin.Bottom);
end;

function TDACDBGrid.EffectivePPI: Integer;
var
  LDC: HDC;
begin
  Result := Screen.PixelsPerInch;
  if not HandleAllocated then
    Exit;
  LDC := GetDC(Handle);
  if LDC = 0 then
    Exit;
  try
    Result := GetDeviceCaps(LDC, LOGPIXELSX);
  finally
    ReleaseDC(Handle, LDC);
  end;
  if Result <= 0 then
    Result := Screen.PixelsPerInch;
end;

constructor TDACDBGrid.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque, csClickEvents];
  Width := DACDBGridDefaultWidth;
  Height := DACDBGridDefaultHeight;
  BorderStyle := bsNone;
  Ctl3D := False;
  DoubleBuffered := True;
  ParentColor := False;
  StyleElements := [];
  ReadOnly := True;
  TabStop := True;
  DefaultDrawing := False;

  FDensity := dgdStandard;
  FEmptyText := 'Nenhum registro encontrado.';
  FHotCell := MakeGridCoord(-1, -1);
  FHoverEnabled := True;
  FPressedTitleColumn := -1;
  FRowSelectionEnabled := True;
  FThemeMode := dtmInherit;
  FZebraEnabled := True;

  FSelectionOptions := TDACDBGridSelectionOptions.Create;
  FSelectionOptions.OnChange := SelectionOptionsChanged;
  FLayoutOptions := TDACDBGridLayoutOptions.Create;
  FLayoutOptions.OnChange := LayoutOptionsChanged;
  FSelectionController := TDACDBGridSelectionController.Create;
  FSortController := TDACDBGridSortController.Create;
  FSurfaceBuffer := TDACDBGridSurfaceBuffer.Create;
  FFramePainter := TDACDBGridFramePainter.Create;
  FHeaderPainter := TDACDBGridHeaderPainter.Create;
  FCellPainter := TDACDBGridCellPainter.Create;
  FBadgePainter := TDACDBGridBadgePainter.Create;
  FActionPainter := TDACDBGridActionPainter.Create;
  FPressedActionRow := -1;
  FHotActionIndex := -1;
  FTextItems := TList<TDACDBGridTextItem>.Create;
  FLayoutManager := TDACDBGridLayoutManager.Create(Self, GetColumns,
    FLayoutOptions, FSortController);
  FLayoutManager.OnError := LayoutError;

  if DataLink is TDACDBGridDataLink then
    TDACDBGridDataLink(DataLink).OnChanged := DataLinkChanged;
  TDACThemeManager.RegisterListener(Self, ThemeChanged);
  UpdateNativeOptions;
  ThemeChanged(Self);
end;

destructor TDACDBGrid.Destroy;
begin
  CancelActionInteraction(True);
  FOnActionState := nil;
  FOnActionExecute := nil;
  TDACThemeManager.UnregisterListener(Self);
  if DataLink is TDACDBGridDataLink then
    TDACDBGridDataLink(DataLink).OnChanged := nil;
  FLayoutManager.Free;
  FTextItems.Free;
  FBadgePainter.Free;
  FreeAndNil(FActionPainter);
  FCellPainter.Free;
  FHeaderPainter.Free;
  FFramePainter.Free;
  FSurfaceBuffer.Free;
  FSortController.Free;
  FSelectionController.Free;
  FLayoutOptions.Free;
  FSelectionOptions.Free;
  inherited;
end;

function TDACDBGrid.BuildLayoutIdentity: string;
var
  LForm: TCustomForm;
  LScreenName: string;
begin
  LScreenName := '';
  LForm := GetParentForm(Self);
  if LForm <> nil then
    LScreenName := LForm.ClassName
  else if Owner <> nil then
    LScreenName := Owner.ClassName;
  Result := LowerCase(CurrentWindowsUser + '|' + LScreenName + '|' + Name);
end;

function TDACDBGrid.CanEditAcceptKey(Key: Char): Boolean;
begin
  Result := False;
end;

function TDACDBGrid.CanEditModify: Boolean;
begin
  Result := False;
end;

function TDACDBGrid.CanEditShow: Boolean;
begin
  Result := False;
end;

procedure TDACDBGrid.ChangeScale(M, D: Integer; isDpiChange: Boolean);
begin
  inherited;
  ThemeChanged(Self);
end;

procedure TDACDBGrid.CMEnabledChanged(var AMessage: TMessage);
begin
  CancelActionInteraction(True);
  inherited;
  ApplyDACNativeScrollBarTheme(Self, FThemeMode);
  Redraw;
end;

procedure TDACDBGrid.CMMouseLeave(var AMessage: TMessage);
begin
  CancelActionInteraction;
  inherited;
  if (FHotCell.X <> -1) or (FHotCell.Y <> -1) then
  begin
    FHotCell := MakeGridCoord(-1, -1);
    Redraw;
  end;
end;

procedure TDACDBGrid.CMParentColorChanged(var AMessage: TMessage);
begin
  inherited;
  ThemeChanged(Self);
end;

procedure TDACDBGrid.ColumnMoved(FromIndex, ToIndex: Integer);
begin
  CancelActionInteraction(True);
  inherited;
  FLayoutManager.ScheduleSave;
  Redraw;
end;

procedure TDACDBGrid.ColWidthsChanged;
begin
  CancelActionInteraction;
  inherited;
  ApplyDensityMetrics;
  if (FLayoutManager <> nil) and not FLayoutManager.Applying then
    FLayoutManager.ScheduleSave;
end;

function TDACDBGrid.CreateColumns: TDBGridColumns;
begin
  Result := TDACDBGridColumns.Create(Self);
end;

function TDACDBGrid.CreateDataLink: TGridDataLink;
begin
  Result := TDACDBGridDataLink.Create(Self);
end;

procedure TDACDBGrid.CreateWnd;
begin
  inherited;
  UpdateNativeOptions;
  ApplyDACNativeScrollBarTheme(Self, FThemeMode);
  UpdateLayoutIdentity;
  FLayoutManager.Load;
  Redraw;
end;

procedure TDACDBGrid.DestroyWnd;
var
  LPendingMessage: TMsg;
  LTrack: TTrackMouseEvent;
begin
  CancelActionInteraction(True);
  if FNativeScrollMouseTracking and HandleAllocated then
  begin
    FillChar(LTrack, SizeOf(LTrack), 0);
    LTrack.cbSize := SizeOf(LTrack);
    LTrack.dwFlags := TME_CANCEL or TME_LEAVE or TME_NONCLIENT;
    LTrack.hwndTrack := Handle;
    TrackMouseEvent(LTrack);
  end;
  if HandleAllocated then
    while PeekMessage(LPendingMessage, Handle,
      WM_DAC_DBGRID_PAINT_NATIVE_SCROLL,
      WM_DAC_DBGRID_PAINT_NATIVE_SCROLL, PM_REMOVE) do
      ;
  FNativeScrollMouseTracking := False;
  FNativeScrollPaintPending := False;
  FNativeScrollPaintActive := False;
  inherited;
end;

procedure TDACDBGrid.DataLinkChanged(Sender: TObject; AField: TField);
begin
  if csDestroying in ComponentState then
    Exit;
  Inc(FDataRevision);
  CancelActionInteraction;
  RecalculateSelectionState;
  UpdateLayoutIdentity;
  FLayoutManager.Load;
  Redraw;
end;

procedure TDACDBGrid.DrawCell(ACol, ARow: Integer; ARect: TRect;
  AState: TGridDrawState);
begin
  { Paint owns the complete client rendering. Keeping DrawCell empty prevents
    the inherited DBGrid painter from overwriting the Skia frame. }
end;

procedure TDACDBGrid.DrawDataRows;
var
  LChecked: Boolean;
  LColumn: TDACDBGridColumn;
  LDataColumn: Integer;
  LDataRow: Integer;
  LField: TField;
  LOldActiveRecord: Integer;
  LRawColumn: Integer;
  LRawRow: Integer;
  LRect: TRect;
  LSelected: Boolean;
  LSelectionField: TField;
  LText: string;
  LTokens: TDACControlTokens;
  LContext: TDACDBGridActionContext;
  LActionViews: TArray<TDACDBGridActionView>;
  LActionView: TDACDBGridActionView;
  LAction: TDACDBGridAction;
begin
  if not DataLink.Active or (DataLink.DataSet = nil) or
    (DataLink.RecordCount <= 0) then
    Exit;
  LTokens := TDACComponentStyle.ResolveForSurface(Self,
    FThemeMode).Tokens.Controls;
  LSelectionField := nil;
  if FSelectionOptions.Enabled then
    LSelectionField := DataLink.DataSet.FindField(FSelectionOptions.FieldName);
  LOldActiveRecord := DataLink.ActiveRecord;
  try
    for LRawRow := FixedRows to RowCount - 1 do
    begin
      LDataRow := LRawRow - FixedRows;
      if LDataRow >= DataLink.RecordCount then
        Break;
      DataLink.ActiveRecord := LDataRow;
      LSelected := FRowSelectionEnabled and (LRawRow = Row);
      for LRawColumn := 0 to ColCount - 1 do
      begin
        LRect := DisplayCellRect(LRawColumn, LRawRow);
        if LRect.IsEmpty or (LRect.Right <= 0) or (LRect.Left >= Width) or
          (LRect.Bottom <= 0) or (LRect.Top >= Height) then
          Continue;
        if FSelectionOptions.Enabled and (LRawColumn = 0) then
        begin
          LChecked := (LSelectionField is TBooleanField) and
            TBooleanField(LSelectionField).AsBoolean;
          FCellPainter.Draw(FSurfaceBuffer.Surface.Canvas,
            TRectF.Create(LRect), '', taCenter, LDataRow, LSelected,
            FHoverEnabled and (FHotCell.Y = LRawRow), Enabled and not FLoading,
            True, LChecked, True, FZebraEnabled, LTokens, FTextItems);
          Continue;
        end;
        LDataColumn := RawToDataColumn(LRawColumn);
        if (LDataColumn < 0) or (LDataColumn >= GetColumns.Count) then
          Continue;
        LColumn := GetColumns[LDataColumn];
        LField := LColumn.Field;
        LText := TDACDBGridFieldTextResolver.Resolve(LField);
        if LColumn.Actions.Count > 0 then
        begin
          FCellPainter.Draw(FSurfaceBuffer.Surface.Canvas,
            TRectF.Create(LRect), '', LColumn.Alignment, LDataRow, LSelected,
            FHoverEnabled and (FHotCell.Y = LRawRow), Enabled and not FLoading,
            False, False, LRawColumn = 0, FZebraEnabled, LTokens, FTextItems);
          LContext := TDACDBGridActionContext.Capture(DataLink.DataSet,
            FActionKeyFields, LColumn.EffectiveLayoutKey);
          LActionViews := BuildActionViews(LColumn, LRect, LContext);
          for LActionView in LActionViews do
          begin
            LAction := LColumn.Actions[LActionView.ActionIndex];
            FActionPainter.Draw(FSurfaceBuffer.Surface.Canvas, LActionView, LAction,
              FHoverEnabled and SameGridCoord(FHotCell, MakeGridCoord(LRawColumn, LRawRow)) and
                (FHotActionIndex = LActionView.ActionIndex),
              ((FPressedActionRow = LRawRow) and (FPressedActionId = LAction.ActionId) and
                (FPressedActionColumn = LColumn.EffectiveLayoutKey)) or
                (FActionKeyDown and FActionMode and (LRawRow = Row) and
                (FFocusedActionId = LAction.ActionId) and
                (FFocusedActionColumn = LColumn.EffectiveLayoutKey)),
              Focused and FActionMode and (LRawRow = Row) and
                (FFocusedActionId = LAction.ActionId) and
                (FFocusedActionColumn = LColumn.EffectiveLayoutKey),
              EffectivePPI, LTokens, FTextItems);
          end;
        end
        else if (LColumn.BadgeMode <> dbmNone) and (LField <> nil) then
        begin
          FCellPainter.Draw(FSurfaceBuffer.Surface.Canvas,
            TRectF.Create(LRect), '', LColumn.Alignment, LDataRow, LSelected,
            FHoverEnabled and (FHotCell.Y = LRawRow), Enabled and not FLoading,
            False, False, LRawColumn = 0, FZebraEnabled, LTokens, FTextItems);
          if not FBadgePainter.Draw(FSurfaceBuffer.Surface.Canvas,
            Canvas.Handle, EffectivePPI, TRectF.Create(LRect), LColumn,
            LField, LTokens, FTextItems) then
            FCellPainter.Draw(FSurfaceBuffer.Surface.Canvas,
              TRectF.Create(LRect), LText, LColumn.Alignment, LDataRow,
              LSelected, FHoverEnabled and (FHotCell.Y = LRawRow),
              Enabled and not FLoading, False, False, LRawColumn = 0,
              FZebraEnabled, LTokens, FTextItems);
        end
        else
          FCellPainter.Draw(FSurfaceBuffer.Surface.Canvas,
            TRectF.Create(LRect), LText, LColumn.Alignment, LDataRow,
            LSelected, FHoverEnabled and (FHotCell.Y = LRawRow),
            Enabled and not FLoading, False, False, LRawColumn = 0,
            FZebraEnabled, LTokens, FTextItems);
      end;
    end;
  finally
    DataLink.ActiveRecord := LOldActiveRecord;
  end;
end;

procedure TDACDBGrid.DrawHeaders;
var
  LAlignment: TAlignment;
  LCaption: string;
  LColumn: TDACDBGridColumn;
  LDataColumn: Integer;
  LDirection: TDACDBGridSortDirection;
  LRawColumn: Integer;
  LRect: TRect;
  LTokens: TDACControlTokens;
begin
  if not (dgTitles in Options) or (FixedRows = 0) then
    Exit;
  LTokens := TDACComponentStyle.ResolveForSurface(Self,
    FThemeMode).Tokens.Controls;
  for LRawColumn := 0 to ColCount - 1 do
  begin
    LRect := DisplayCellRect(LRawColumn, 0);
    if LRect.IsEmpty or (LRect.Right <= 0) or (LRect.Left >= Width) then
      Continue;
    if FSelectionOptions.Enabled and (LRawColumn = 0) then
    begin
      FHeaderPainter.Draw(FSurfaceBuffer.Surface.Canvas, TRectF.Create(LRect),
        '', taCenter, SameGridCoord(FHotCell, MakeGridCoord(LRawColumn, 0)),
        FPressedTitleColumn = LRawColumn, True, FSelectionState, dgsNone,
        LTokens, FTextItems);
      Continue;
    end;
    LDataColumn := RawToDataColumn(LRawColumn);
    if (LDataColumn < 0) or (LDataColumn >= GetColumns.Count) then
      Continue;
    LColumn := GetColumns[LDataColumn];
    LCaption := LColumn.Title.Caption;
    LAlignment := LColumn.Title.Alignment;
    LDirection := dgsNone;
    if SameText(FSortController.Key, LColumn.EffectiveLayoutKey) then
      LDirection := FSortController.Direction;
    FHeaderPainter.Draw(FSurfaceBuffer.Surface.Canvas, TRectF.Create(LRect),
      LCaption, LAlignment,
      SameGridCoord(FHotCell, MakeGridCoord(LRawColumn, 0)),
      FPressedTitleColumn = LRawColumn, False, dgssUnchecked, LDirection,
      LTokens, FTextItems);
  end;
end;

function TDACDBGrid.GetColumns: TDACDBGridColumns;
begin
  Result := inherited Columns as TDACDBGridColumns;
end;

procedure TDACDBGrid.ApplyDensityMetrics;
var
  LHeaderHeight: Integer;
  LRowHeight: Integer;
begin
  if FApplyingDensityMetrics or (csDestroying in ComponentState) then
    Exit;
  FApplyingDensityMetrics := True;
  try
    LRowHeight := RowHeightForDensity;
    if DefaultRowHeight <> LRowHeight then
      DefaultRowHeight := LRowHeight;
    if (dgTitles in Options) and (FixedRows > 0) and (RowCount > 0) then
    begin
      LHeaderHeight := HeaderHeight;
      if RowHeights[0] <> LHeaderHeight then
        RowHeights[0] := LHeaderHeight;
    end;
  finally
    FApplyingDensityMetrics := False;
  end;
end;

function TDACDBGrid.EffectiveHeaderHeight: Integer;
begin
  if not (dgTitles in Options) then
    Exit(0);
  Result := HeaderHeight;
  if (dgTitles in Options) and (FixedRows > 0) and (RowCount > 0) and
    (RowHeights[0] > 0) then
    Result := RowHeights[0];
end;

function TDACDBGrid.HeaderHeight: Integer;
var
  LTokens: TDACControlTokens;
begin
  LTokens := TDACComponentStyle.ResolveForSurface(Self,
    FThemeMode).Tokens.Controls;
  case FDensity of
    dgdCompact: Result := Pixels(Round(LTokens.DataGridSmallHeaderHeight));
    dgdComfortable: Result := Pixels(Round(LTokens.DataGridLargeHeaderHeight));
  else
    Result := Pixels(Round(LTokens.DataGridMediumHeaderHeight));
  end;
end;

procedure TDACDBGrid.CancelActionInteraction(const AExitMode: Boolean);
begin
  FPressedActionId := '';
  FPressedActionColumn := '';
  FPressedActionRow := -1;
  FHotActionIndex := -1;
  if AExitMode then
  begin
    FActionMode := False;
    FActionKeyDown := False;
    FFocusedActionId := '';
    FFocusedActionColumn := '';
  end;
  if FActionMouse and HandleAllocated and (GetCapture = Handle) then
    MouseCapture := False;
end;

procedure TDACDBGrid.SetActionKeyFields(const AValue: string);
begin
  if FActionKeyFields = AValue then Exit;
  FActionKeyFields := AValue;
  CancelActionInteraction(True);
  Redraw;
end;

function TDACDBGrid.BuildActionViews(AColumn: TDACDBGridColumn;
  const ARect: TRect; const AContext: TDACDBGridActionContext): TArray<TDACDBGridActionView>;
var
  I, X, W, H, Gap, Inset, Count: Integer;
  Visible, ActionEnabled: Boolean;
  Action: TDACDBGridAction;
  Context: TDACDBGridActionContext;
  Tokens: TDACControlTokens;
  Revision: Cardinal;
begin
  Result := nil;
  if AColumn = nil then Exit;
  Tokens := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls;
  Inset := Pixels(Round(Tokens.DataGridActionInset));
  Gap := Pixels(Round(Tokens.ButtonContentGap));
  H := Min(Pixels(Round(Tokens.ButtonSmall.Height)), ARect.Height - Inset);
  if H <= 0 then Exit;
  X := ARect.Left + Inset;
  SetLength(Result, AColumn.Actions.Count);
  Count := 0;
  for I := 0 to AColumn.Actions.Count - 1 do
  begin
    Action := AColumn.Actions[I];
    Visible := Action.Visible;
    ActionEnabled := Action.Enabled and Enabled and not FLoading;
    Context := AContext;
    Context.ActionId := Action.ActionId;
    if Visible and not FLoading and not (csDesigning in ComponentState) and
      Assigned(FOnActionState) and not FQueryingAction then
    begin
      Revision := FDataRevision;
      FQueryingAction := True;
      try
        FOnActionState(Self, AColumn, Action, Context, Visible, ActionEnabled);
      finally FQueryingAction := False; end;
      if Revision <> FDataRevision then
        raise EInvalidOperation.Create('OnActionState must not navigate or modify the dataset.');
    end;
    Visible := Visible and Action.Visible;
    ActionEnabled := ActionEnabled and Action.Enabled and Enabled and not FLoading;
    if not Visible then Continue;
    W := Pixels(Action.Width);
    // Never display or activate a button partially outside its own cell.
    if X + W > ARect.Right - Inset then Break;
    Result[Count].ActionIndex := I;
    Result[Count].Bounds := Rect(X, ARect.Top + (ARect.Height - H) div 2,
      X + W, ARect.Top + (ARect.Height + H) div 2);
    Result[Count].Enabled := ActionEnabled;
    Inc(Count);
    Inc(X, W + Gap);
  end;
  SetLength(Result, Count);
end;

function TDACDBGrid.ActionCell(const ACol, ARow: Integer;
  out AColumn: TDACDBGridColumn; out AContext: TDACDBGridActionContext): TArray<TDACDBGridActionView>;
var I, OldRecord: Integer;
begin
  Result := nil;
  AColumn := nil;
  AContext := Default(TDACDBGridActionContext);
  if FLoading or FQueryingAction or not Enabled or
    ([csLoading, csDestroying, csDesigning] * ComponentState <> []) or
    not DataLink.Active or (DataLink.DataSet = nil) or
    (DataLink.DataSet.State <> dsBrowse) or (DataLink.RecordCount <= 0) or
    (ARow < FixedRows) or (ARow >= RowCount) or
    (ARow - FixedRows >= DataLink.RecordCount) or
    (ACol < 0) or (ACol >= ColCount) then Exit;
  if FSelectionOptions.Enabled and (ACol = 0) then Exit;
  I := RawToDataColumn(ACol);
  if (I < 0) or (I >= GetColumns.Count) then Exit;
  AColumn := GetColumns[I];
  if not AColumn.Visible or (AColumn.Actions.Count = 0) then Exit;
  OldRecord := DataLink.ActiveRecord;
  try
    DataLink.ActiveRecord := ARow - FixedRows;
    AContext := TDACDBGridActionContext.Capture(DataLink.DataSet,
      FActionKeyFields, AColumn.EffectiveLayoutKey);
    Result := BuildActionViews(AColumn, DisplayCellRect(ACol, ARow), AContext);
  finally DataLink.ActiveRecord := OldRecord; end;
end;

function TDACDBGrid.ActionHit(const X, Y: Integer; out AColumn: TDACDBGridColumn;
  out AView: TDACDBGridActionView; out AContext: TDACDBGridActionContext): Boolean;
var Cell: TGridCoord; View: TDACDBGridActionView;
begin
  Result := False;
  AColumn := nil;
  AView := Default(TDACDBGridActionView);
  AContext := Default(TDACDBGridActionContext);
  if not HandleAllocated or (X < 0) or (Y < 0) or (X >= ClientWidth) or
    (Y >= ClientHeight) then Exit;
  Cell := MouseCoord(X, Y);
  for View in ActionCell(Cell.X, Cell.Y, AColumn, AContext) do
    if PtInRect(View.Bounds, Point(X, Y)) then
    begin
      AView := View;
      AContext.ActionId := AColumn.Actions[View.ActionIndex].ActionId;
      Exit(True);
    end;
end;

procedure TDACDBGrid.CMHintShow(var AMessage: TCMHintShow);
var Column: TDACDBGridColumn; View: TDACDBGridActionView;
  Context: TDACDBGridActionContext;
begin
  if ActionHit(AMessage.HintInfo^.CursorPos.X, AMessage.HintInfo^.CursorPos.Y,
    Column, View, Context) then
  begin
    AMessage.HintInfo^.HintStr := Column.Actions[View.ActionIndex].Hint;
    AMessage.HintInfo^.CursorRect := View.Bounds;
    AMessage.Result := Ord(AMessage.HintInfo^.HintStr = '');
  end
  else inherited;
end;

function TDACDBGrid.FocusAction(const ADirection: Integer;
  const AEnterMode: Boolean): Boolean;
var I, J, Current, Next, RawColumn: Integer;
  CellBounds: TRect;
  Column: TDACDBGridColumn; Context: TDACDBGridActionContext;
  Views: TArray<TDACDBGridActionView>;
  Eligible: TList<Integer>;
begin
  Result := False;
  if not HandleAllocated or FLoading or not Enabled or not DataLink.Active or
    (DataLink.RecordCount <= 0) then Exit;
  Eligible := TList<Integer>.Create;
  try
    for I := 0 to GetColumns.Count - 1 do
    begin
      if not GetColumns[I].Visible or (GetColumns[I].Actions.Count = 0) then Continue;
      if not AEnterMode and (GetColumns[I].EffectiveLayoutKey <> FFocusedActionColumn) then Continue;
      if AEnterMode and (SelectedIndex >= 0) and (SelectedIndex < GetColumns.Count) and
        (GetColumns[SelectedIndex].Actions.Count > 0) and (I <> SelectedIndex) then Continue;
      RawColumn := DataToRawColumn(I);
      if AEnterMode then
      begin
        CellBounds := DisplayCellRect(RawColumn, Row);
        if CellBounds.IsEmpty or (RawColumn < LeftCol) or
          (CellBounds.Left < 0) or (CellBounds.Right > ClientWidth) then
          LeftCol := Max(FixedCols, RawColumn);
      end;
      Views := ActionCell(RawColumn, Row, Column, Context);
      Eligible.Clear;
      Current := -1;
      for J := 0 to Length(Views) - 1 do
        if Views[J].Enabled then
        begin
          if GetColumns[I].Actions[Views[J].ActionIndex].ActionId = FFocusedActionId then
            Current := Eligible.Count;
          Eligible.Add(Views[J].ActionIndex);
        end;
      if Eligible.Count = 0 then Continue;
      if AEnterMode then Next := 0
      else Next := (Current + ADirection + Eligible.Count) mod Eligible.Count;
      FActionMode := True;
      FFocusedActionColumn := Column.EffectiveLayoutKey;
      FFocusedActionId := Column.Actions[Eligible[Next]].ActionId;
      if not FRowSelectionEnabled then SelectedIndex := I;
      Redraw;
      Exit(True);
    end;
  finally Eligible.Free; end;
end;

procedure TDACDBGrid.ExecuteFocusedAction;
var I: Integer; Column: TDACDBGridColumn; View: TDACDBGridActionView;
  Context: TDACDBGridActionContext;
begin
  if not FActionMode then Exit;
  for I := 0 to GetColumns.Count - 1 do
    if GetColumns[I].EffectiveLayoutKey = FFocusedActionColumn then
    begin
      for View in ActionCell(DataToRawColumn(I), Row, Column, Context) do
        if View.Enabled and (Column.Actions[View.ActionIndex].ActionId = FFocusedActionId) then
        begin
          Context.ActionId := FFocusedActionId;
          if Assigned(FOnActionExecute) then
            FOnActionExecute(Self, Column, Column.Actions[View.ActionIndex], Context);
          Exit;
        end;
      Exit;
    end;
end;

procedure TDACDBGrid.Click;
begin
  if not FActionMouse then inherited;
end;

procedure TDACDBGrid.KeyDown(var Key: Word; Shift: TShiftState);
var Direction: Integer;
begin
  if (Key = VK_F2) and (Shift = []) and FocusAction(1, True) then
  begin Key := 0; Exit; end;
  if FActionMode then
  begin
    case Key of
      VK_ESCAPE:
        begin CancelActionInteraction(True); Redraw; Key := 0; Exit; end;
      VK_LEFT, VK_RIGHT, VK_TAB:
        if not (ssCtrl in Shift) and not (ssAlt in Shift) then
        begin
          Direction := 1;
          if (Key = VK_LEFT) or ((Key = VK_TAB) and (ssShift in Shift)) then Direction := -1;
          FocusAction(Direction, False);
          Key := 0; Exit;
        end;
      VK_RETURN, VK_SPACE:
        if Shift = [] then
        begin
          Key := 0;
          if not FActionKeyDown then
          begin
            FActionKeyDown := True;
            Redraw;
            ExecuteFocusedAction;
          end;
          Exit;
        end;
    else
      CancelActionInteraction(True);
    end;
  end;
  if (Key = VK_SPACE) and FSelectionOptions.Enabled and Enabled and not FLoading then
  begin
    ToggleCurrentSelection;
    Key := 0; Exit;
  end;
  inherited;
end;

procedure TDACDBGrid.KeyUp(var Key: Word; Shift: TShiftState);
begin
  if Key in [VK_RETURN, VK_SPACE] then
  begin FActionKeyDown := False; Redraw; end;
  inherited;
end;

procedure TDACDBGrid.MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var Cell: TGridCoord; Column: TDACDBGridColumn; View: TDACDBGridActionView;
  ViewportColumn: Integer;
  Context: TDACDBGridActionContext;
begin
  CancelActionInteraction;
  FActionMouse := False;
  Cell := MouseCoord(X, Y);
  if (Button = mbLeft) and ActionHit(X, Y, Column, View, Context) then
  begin
    FActionMouse := True;
    if not View.Enabled or (ssDouble in Shift) or not CanFocus then Exit;
    ViewportColumn := LeftCol;
    if not Focused then SetFocus;
    // Native row navigation can clamp a row-select grid to its first column.
    // Keep the horizontal viewport of the action that was actually clicked.
    if Cell.Y <> Row then
      TDACDBGridDataLink(DataLink).MoveViewport(Cell.Y - Row);
    if FRowSelectionEnabled and (LeftCol <> ViewportColumn) then
      LeftCol := Min(ColCount - 1, Max(FixedCols, ViewportColumn));
    if not ActionHit(X, Y, Column, View, Context) or not View.Enabled or
      (MouseCoord(X, Y).Y <> Row) then Exit;
    if not FRowSelectionEnabled then SelectedIndex := Column.Index;
    FActionMode := True;
    FFocusedActionId := Context.ActionId;
    FFocusedActionColumn := Context.ColumnKey;
    FPressedActionId := Context.ActionId;
    FPressedActionColumn := Context.ColumnKey;
    FPressedActionRow := Row;
    FPressedActionRevision := FDataRevision;
    MouseCapture := True;
    Redraw;
    Exit;
  end;
  FActionMode := False;
  if (Button = mbLeft) and (Cell.Y = 0) then FPressedTitleColumn := Cell.X;
  inherited;
  Redraw;
end;

procedure TDACDBGrid.MouseMove(Shift: TShiftState; X, Y: Integer);
var Cell: TGridCoord; Column: TDACDBGridColumn; View: TDACDBGridActionView;
  Context: TDACDBGridActionContext; HotIndex: Integer; Hit: Boolean;
begin
  if not FActionMouse then inherited;
  Cell := MouseCoord(X, Y);
  Hit := ActionHit(X, Y, Column, View, Context);
  HotIndex := -1;
  if Hit then HotIndex := View.ActionIndex;
  if FActionMouse and (FPressedActionId <> '') and
    (not Hit or not View.Enabled or (Context.ActionId <> FPressedActionId) or
      (Context.ColumnKey <> FPressedActionColumn) or (Cell.Y <> FPressedActionRow)) then
    CancelActionInteraction;
  if not SameGridCoord(Cell, FHotCell) or (HotIndex <> FHotActionIndex) then
  begin
    FHotCell := Cell;
    FHotActionIndex := HotIndex;
    if Hit and View.Enabled then Cursor := crHandPoint else Cursor := crDefault;
    Redraw;
  end;
end;

procedure TDACDBGrid.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var Cell: TGridCoord; Column: TDACDBGridColumn; View: TDACDBGridActionView;
  Context: TDACDBGridActionContext; Execute: Boolean;
begin
  if FActionMouse and (Button = mbLeft) then
  begin
    Execute := (FPressedActionId <> '') and (FPressedActionRevision = FDataRevision) and
      ActionHit(X, Y, Column, View, Context);
    if Execute then
      Execute := View.Enabled and (Context.ActionId = FPressedActionId) and
        (Context.ColumnKey = FPressedActionColumn) and
        (MouseCoord(X, Y).Y = FPressedActionRow) and (FPressedActionRow = Row);
    CancelActionInteraction;
    FActionMouse := False;
    Redraw;
    if Execute and Assigned(FOnActionExecute) then
      FOnActionExecute(Self, Column, Column.Actions[View.ActionIndex], Context);
    Exit;
  end;
  Cell := MouseCoord(X, Y);
  inherited;
  if (Button = mbLeft) and FSelectionOptions.Enabled and (Cell.X = 0) and
    Enabled and not FLoading then
  begin
    if (Cell.Y = 0) and FSelectionOptions.AllowSelectAll then ToggleSelectAll
    else if Cell.Y >= FixedRows then ToggleCurrentSelection;
  end;
  FPressedTitleColumn := -1;
  Redraw;
end;

procedure TDACDBGrid.LayoutError(Sender: TObject; const AMessage: string);
begin
  if Assigned(FOnLayoutError) then
    FOnLayoutError(Self, AMessage);
end;

procedure TDACDBGrid.LayoutOptionsChanged(Sender: TObject);
begin
  FLayoutManager.SetIdentity('');
  UpdateLayoutIdentity;
  FLayoutManager.Load;
end;

procedure TDACDBGrid.PaintNativeScrollBars;
var
  LDC: HDC;
  LTokens: TDACControlTokens;
begin
  if FNativeScrollPaintActive or not HandleAllocated or
    (csDestroying in ComponentState) or
    (DACNativeScrollBarHookAuthorityCount(Handle) <> 0) or
    DACScrollHighContrastEnabled then
    Exit;
  FNativeScrollPaintActive := True;
  try
    LDC := GetWindowDC(Handle);
    if LDC = 0 then
      Exit;
    try
      LTokens := TDACComponentStyle.ResolveForSurface(Self,
        FThemeMode).Tokens.Controls;
      PaintDACNativeScrollBarThemeProfile(Self, FThemeMode, LDC, True,
        svpMaxxRuralMD, LTokens.DataGridBackground);
    finally
      ReleaseDC(Handle, LDC);
    end;
  finally
    FNativeScrollPaintActive := False;
  end;
end;

procedure TDACDBGrid.QueueNativeScrollPaint;
begin
  if FNativeScrollPaintPending or not HandleAllocated or
    (csDestroying in ComponentState) or
    (DACNativeScrollBarHookAuthorityCount(Handle) <> 0) or
    DACScrollHighContrastEnabled then
    Exit;
  // DefWindowProc may finish a native hover transition after the current
  // non-client dispatch. Reassert the DAC surface once the queue is drained.
  if PostMessage(Handle, WM_DAC_DBGRID_PAINT_NATIVE_SCROLL, 0, 0) then
    FNativeScrollPaintPending := True;
end;

procedure TDACDBGrid.Loaded;
begin
  inherited;
  UpdateNativeOptions;
  ApplyDACNativeScrollBarTheme(Self, FThemeMode);
  UpdateLayoutIdentity;
  FLayoutManager.Load;
  RecalculateSelectionState;
end;

function TDACDBGrid.ActionRect(const AColumnIndex, AVisibleRowIndex,
  AActionIndex: Integer): TRect;
var Column: TDACDBGridColumn; Context: TDACDBGridActionContext;
  View: TDACDBGridActionView;
begin
  Result := TRect.Empty;
  if (AColumnIndex < 0) or (AColumnIndex >= GetColumns.Count) then Exit;
  for View in ActionCell(DataToRawColumn(AColumnIndex),
    FixedRows + AVisibleRowIndex, Column, Context) do
    if View.ActionIndex = AActionIndex then Exit(View.Bounds);
end;

procedure TDACDBGrid.LoadLayout;
begin
  FLayoutManager.SetIdentity('');
  UpdateLayoutIdentity;
  FLayoutManager.Load;
  Redraw;
end;

procedure TDACDBGrid.Paint;
var
  LBounds: TRectF;
  LHasRows: Boolean;
  LParentSurface: TAlphaColor;
  LRadius: Single;
  LTokens: TDACControlTokens;
begin
  if (Width <= 0) or (Height <= 0) then
    Exit;
  FSurfaceBuffer.EnsureSize(Width, Height);
  FTextItems.Clear;
  LTokens := TDACComponentStyle.ResolveForSurface(Self,
    FThemeMode).Tokens.Controls;
  LBounds := TRectF.Create(0, 0, Width, Height);
  LRadius := Pixels(Round(LTokens.DataGridRadius));
  LParentSurface := TDACComponentColors.ResolveParentSurface(Self);
  FFramePainter.DrawBackground(FSurfaceBuffer.Surface.Canvas, LBounds,
    EffectiveHeaderHeight, LRadius, LTokens, LParentSurface);
  DrawHeaders;
  LHasRows := DataLink.Active and (DataLink.DataSet <> nil) and
    (DataLink.RecordCount > 0);
  if FLoading or not LHasRows then
    FFramePainter.DrawState(FSurfaceBuffer.Surface.Canvas, LBounds,
      EffectiveHeaderHeight, FLoading, FEmptyText, LTokens, FTextItems)
  else
    DrawDataRows;
  FFramePainter.DrawBorder(FSurfaceBuffer.Surface.Canvas, LBounds, LRadius,
    LTokens);
  FSurfaceBuffer.Present(Canvas.Handle);
  DACDrawDBGridTextItems(Canvas.Handle, TDACComponentStyle.FontFamily,
    EffectivePPI, FTextItems);
end;

function TDACDBGrid.Pixels(const AValue: Integer): Integer;
begin
  Result := MulDiv(AValue, Max(96, EffectivePPI), 96);
end;

procedure TDACDBGrid.RecalculateSelectionState;
begin
  if FRecalculatingSelection then
    Exit;
  FRecalculatingSelection := True;
  try
  FSelectionState := dgssUnchecked;
  if not FSelectionOptions.Enabled or (DataLink.DataSet = nil) or
    not DataLink.Active then
    Exit;
  try
    FSelectionState := FSelectionController.CalculateState(DataLink.DataSet,
      FSelectionOptions);
  except
    on E: Exception do
      if Assigned(FOnSelectionError) then
        FOnSelectionError(Self, E.Message);
  end;
  finally
    FRecalculatingSelection := False;
  end;
end;

procedure TDACDBGrid.Redraw;
begin
  if HandleAllocated then
    Invalidate;
end;

procedure TDACDBGrid.ResetLayout;
begin
  FLayoutManager.Reset;
  Redraw;
end;

procedure TDACDBGrid.Resize;
begin
  inherited;
  ApplyDACNativeScrollBarTheme(Self, FThemeMode);
  Redraw;
end;

function TDACDBGrid.RowHeightForDensity: Integer;
var
  LTokens: TDACControlTokens;
begin
  LTokens := TDACComponentStyle.ResolveForSurface(Self,
    FThemeMode).Tokens.Controls;
  case FDensity of
    dgdCompact: Result := Pixels(Round(LTokens.DataGridSmallRowHeight));
    dgdComfortable: Result := Pixels(Round(LTokens.DataGridLargeRowHeight));
  else
    Result := Pixels(Round(LTokens.DataGridMediumRowHeight));
  end;
end;

procedure TDACDBGrid.SaveLayout;
begin
  FLayoutManager.Save;
end;

procedure TDACDBGrid.SelectionOptionsChanged(Sender: TObject);
begin
  UpdateNativeOptions;
  RecalculateSelectionState;
  Redraw;
end;

procedure TDACDBGrid.SetColumnAttributes;
begin
  CancelActionInteraction;
  if ([csLoading, csDestroying] * ComponentState) <> [] then
    Exit;
  inherited;
  if FSelectionOptions.Enabled and (dgIndicator in Options) and
    (ColCount > 0) then
    ColWidths[0] := Pixels(FSelectionOptions.Width);
  ApplyDensityMetrics;
end;

procedure TDACDBGrid.SetColumns(const AValue: TDACDBGridColumns);
begin
  GetColumns.Assign(AValue);
  UpdateNativeOptions;
  FLayoutManager.SetIdentity('');
  UpdateLayoutIdentity;
  FLayoutManager.Load;
end;

procedure TDACDBGrid.SetColumnVisible(const ALayoutKey: string;
  const AVisible: Boolean);
var
  I: Integer;
  J: Integer;
  LTargetIndex: Integer;
  LVisibleCount: Integer;
begin
  LTargetIndex := -1;
  for I := 0 to GetColumns.Count - 1 do
    if SameText(GetColumns[I].EffectiveLayoutKey, ALayoutKey) then
    begin
      LTargetIndex := I;
      Break;
    end;
  if LTargetIndex < 0 then
    Exit;
  if not GetColumns[LTargetIndex].UserHideable then
    Exit;
  if not AVisible then
  begin
    LVisibleCount := 0;
    for J := 0 to GetColumns.Count - 1 do
      if GetColumns[J].Visible then
        Inc(LVisibleCount);
    if LVisibleCount <= 1 then
      Exit;
  end;
  GetColumns[LTargetIndex].Visible := AVisible;
  FLayoutManager.ScheduleSave;
  Redraw;
end;

procedure TDACDBGrid.SetDensity(const AValue: TDACDBGridDensity);
begin
  if FDensity = AValue then Exit;
  FDensity := AValue;
  ThemeChanged(Self);
end;

procedure TDACDBGrid.SetEmptyText(const AValue: string);
begin
  if FEmptyText = AValue then Exit;
  FEmptyText := AValue;
  Redraw;
end;

procedure TDACDBGrid.SetHoverEnabled(const AValue: Boolean);
begin
  if FHoverEnabled = AValue then Exit;
  FHoverEnabled := AValue;
  Redraw;
end;

procedure TDACDBGrid.SetLayoutOptions(
  const AValue: TDACDBGridLayoutOptions);
begin
  FLayoutOptions.Assign(AValue);
end;

procedure TDACDBGrid.SetLoading(const AValue: Boolean);
begin
  if FLoading = AValue then Exit;
  FLoading := AValue;
  CancelActionInteraction(True);
  Redraw;
end;

procedure TDACDBGrid.SetRowSelectionEnabled(const AValue: Boolean);
begin
  if FRowSelectionEnabled = AValue then Exit;
  FRowSelectionEnabled := AValue;
  UpdateNativeOptions;
  Redraw;
end;

procedure TDACDBGrid.SetSelectionOptions(
  const AValue: TDACDBGridSelectionOptions);
begin
  FSelectionOptions.Assign(AValue);
end;

procedure TDACDBGrid.SetThemeMode(const AValue: TDACThemeMode);
begin
  FThemeMode := AValue;
  ThemeChanged(Self);
end;

procedure TDACDBGrid.SetZebraEnabled(const AValue: Boolean);
begin
  if FZebraEnabled = AValue then Exit;
  FZebraEnabled := AValue;
  Redraw;
end;

procedure TDACDBGrid.ThemeChanged(Sender: TObject);
var
  LTokens: TDACControlTokens;
begin
  LTokens := TDACComponentStyle.ResolveForSurface(Self,
    FThemeMode).Tokens.Controls;
  Font.Name := TDACComponentStyle.FontFamily;
  Font.Size := DACDBGridDefaultFontSize;
  Font.Color := TDACComponentColors.ToVclColor(LTokens.DataGridText);
  TitleFont.Assign(Font);
  TitleFont.Style := [fsBold];
  TitleFont.Color := TDACComponentColors.ToVclColor(LTokens.DataGridHeaderText);
  Color := TDACComponentColors.ToVclColor(LTokens.DataGridBackground);
  FixedColor := TDACComponentColors.ToVclColor(LTokens.DataGridHeader);
  UpdateNativeOptions;
  ApplyDensityMetrics;
  ApplyDACNativeScrollBarTheme(Self, FThemeMode);
  Redraw;
end;

procedure TDACDBGrid.TrackNativeScrollMouseLeave;
var
  LTrack: TTrackMouseEvent;
begin
  if FNativeScrollMouseTracking or not HandleAllocated or
    (csDestroying in ComponentState) or
    (DACNativeScrollBarHookAuthorityCount(Handle) <> 0) or
    DACScrollHighContrastEnabled then
    Exit;
  FillChar(LTrack, SizeOf(LTrack), 0);
  LTrack.cbSize := SizeOf(LTrack);
  LTrack.dwFlags := TME_LEAVE or TME_NONCLIENT;
  LTrack.hwndTrack := Handle;
  LTrack.dwHoverTime := HOVER_DEFAULT;
  if TrackMouseEvent(LTrack) then
    FNativeScrollMouseTracking := True
  else
    FNativeScrollMouseTracking := False;
end;

procedure TDACDBGrid.TitleClick(Column: TColumn);
var
  LAccepted: Boolean;
  LDACColumn: TDACDBGridColumn;
  LDirection: TDACDBGridSortDirection;
begin
  inherited;
  if not (Column is TDACDBGridColumn) then
    Exit;
  LDACColumn := TDACDBGridColumn(Column);
  if not LDACColumn.Sortable or (LDACColumn.FieldName = '') then
    Exit;
  LDirection := FSortController.NextDirection(LDACColumn.EffectiveLayoutKey);
  LAccepted := False;
  if Assigned(FOnSortRequest) then
    FOnSortRequest(Self, Column, LDACColumn.FieldName, LDirection, LAccepted);
  if not LAccepted then
    Exit;
  FSortController.Accept(LDACColumn.EffectiveLayoutKey, LDirection);
  FLayoutManager.ScheduleSave;
  Redraw;
end;

procedure TDACDBGrid.ToggleCurrentSelection;
var
  LChecked: Boolean;
  LField: TField;
begin
  if not FSelectionOptions.Enabled or not Enabled or FLoading or
    not DataLink.Active or (DataLink.DataSet = nil) then
    Exit;
  try
    if FSelectionController.ToggleCurrent(DataLink.DataSet,
      FSelectionOptions, LField, LChecked) then
    begin
      RecalculateSelectionState;
      if Assigned(FOnSelectionChanged) then
        FOnSelectionChanged(Self, LField, LChecked);
      Redraw;
    end;
  except
    on E: Exception do
      if Assigned(FOnSelectionError) then
        FOnSelectionError(Self, E.Message);
  end;
end;

procedure TDACDBGrid.ToggleSelectAll;
var
  LChecked: Boolean;
  LField: TField;
begin
  if not FSelectionOptions.Enabled or not FSelectionOptions.AllowSelectAll or
    not Enabled or FLoading or not DataLink.Active or
    (DataLink.DataSet = nil) then
    Exit;
  LChecked := FSelectionState <> dgssChecked;
  try
    FSelectionController.SetAll(DataLink.DataSet, FSelectionOptions, LChecked);
    RecalculateSelectionState;
    LField := DataLink.DataSet.FindField(FSelectionOptions.FieldName);
    if Assigned(FOnSelectionChanged) then
      FOnSelectionChanged(Self, LField, LChecked);
    Redraw;
  except
    on E: Exception do
      if Assigned(FOnSelectionError) then
        FOnSelectionError(Self, E.Message);
  end;
end;

procedure TDACDBGrid.UpdateLayoutIdentity;
begin
  if FLayoutManager <> nil then
    FLayoutManager.SetIdentity(BuildLayoutIdentity);
end;

procedure TDACDBGrid.UpdateNativeOptions;
var
  LOptions: TDBGridOptions;
begin
  LOptions := [dgTitles, dgColumnResize, dgRowSelect, dgAlwaysShowSelection,
    dgTitleClick, dgTitleHotTrack];
  if not FRowSelectionEnabled then
    Exclude(LOptions, dgRowSelect);
  if FSelectionOptions.Enabled then
    Include(LOptions, dgIndicator);
  Options := LOptions;
  ReadOnly := True;
  DefaultDrawing := False;
  SetColumnAttributes;
  ApplyDensityMetrics;
end;

procedure TDACDBGrid.WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
begin
  AMessage.Result := 1;
end;

procedure TDACDBGrid.WMNCPaint(var AMessage: TWMNCPaint);
begin
  inherited;
  PaintNativeScrollBars;
end;

procedure TDACDBGrid.WndProc(var Message: TMessage);
var
  Column: TDACDBGridColumn;
  View: TDACDBGridActionView;
  Context: TDACDBGridActionContext;
  P: TPoint;
begin
  // TControl releases mouse capture before MouseUp. Route action releases first,
  // so an ordinary release is not mistaken for a lost-capture cancellation.
  if (Message.Msg = WM_LBUTTONUP) and FActionMouse then
  begin
    ControlState := ControlState - [csClicked];
    P := SmallPointToPoint(TSmallPoint(Message.LParam));
    Message.Result := 0;
    MouseUp(mbLeft, KeysToShiftState(Message.WParam), P.X, P.Y);
    Exit;
  end;
  if Message.Msg = WM_LBUTTONDBLCLK then
  begin
    P := SmallPointToPoint(TSmallPoint(Message.LParam));
    if ActionHit(P.X, P.Y, Column, View, Context) then
    begin
      CancelActionInteraction;
      FActionMouse := True;
      Message.Result := 0;
      Exit;
    end;
  end;
  case Message.Msg of
    WM_HSCROLL, WM_VSCROLL, WM_MOUSEWHEEL, WM_MOUSEHWHEEL,
    WM_CANCELMODE, CM_CANCELMODE, WM_CAPTURECHANGED, WM_SIZE,
    WM_KILLFOCUS, CM_DEACTIVATE:
      begin
        CancelActionInteraction((Message.Msg = WM_KILLFOCUS) or (Message.Msg = CM_DEACTIVATE));
        if not (csDestroying in ComponentState) then Invalidate;
      end;
  end;
  if Message.Msg = WM_DAC_DBGRID_PAINT_NATIVE_SCROLL then
  begin
    FNativeScrollPaintPending := False;
    PaintNativeScrollBars;
    Message.Result := 0;
    Exit;
  end;

  if Message.Msg = WM_NCMOUSEMOVE then
    TrackNativeScrollMouseLeave
  else if Message.Msg = WM_NCMOUSELEAVE then
    FNativeScrollMouseTracking := False;

  inherited;

  if (Message.Msg = WM_GETDLGCODE) and FActionMode then
    Message.Result := Message.Result or DLGC_WANTALLKEYS or DLGC_WANTTAB or DLGC_WANTARROWS;

  case Message.Msg of
    WM_NCMOUSEMOVE,
    WM_NCMOUSELEAVE,
    WM_NCLBUTTONDOWN,
    WM_NCLBUTTONUP,
    WM_CAPTURECHANGED,
    WM_HSCROLL,
    WM_VSCROLL,
    WM_MOUSEWHEEL:
      begin
        PaintNativeScrollBars;
        QueueNativeScrollPaint;
      end;
    WM_MOUSEMOVE:
      if HandleAllocated and (GetCapture = Handle) then
      begin
        PaintNativeScrollBars;
        QueueNativeScrollPaint;
      end;
  end;
end;

end.
