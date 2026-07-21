unit DAC.Components.Controls.DataGrid;

interface

uses
  System.Classes,
  System.Skia,
  System.Types,
  System.UITypes,
  Data.DB,
  Winapi.Messages,
  Vcl.Controls,
  Vcl.DBGrids,
  Vcl.Forms,
  Vcl.Grids,
  Vcl.Skia,
  DAC.Components.Skia.Renderer;

type
  TDACDataGridActionKind = (mdgakNone, mdgakEdit, mdgakDelete, mdgakMore);
  TDACDataGridActionClickEvent = procedure(Sender: TObject;
    AAction: TDACDataGridActionKind; AColumn: TColumn) of object;

  TDACDataGridPaintBox = class(TSkPaintBox)
  public
    procedure SetWheelHandler(const AHandler: TMouseWheelEvent);
  end;

  TDACDataGrid = class(TDBGrid)
  private
    FCornerRadius: Integer;
    FFooterText: string;
    FFooterValue: string;
    FHoverCell: TGridCoord;
    FOnActionClick: TDACDataGridActionClickEvent;
    FPaintBox: TDACDataGridPaintBox;
    FRenderer: TDACSkiaRenderer;
    FShowFooter: Boolean;
    FStatusFieldName: string;
    function ActionAt(const ACellRect: TRect; const X, Y: Integer): TDACDataGridActionKind;
    function ActionRect(const ACellRect: TRect;
      const AAction: TDACDataGridActionKind): TRect;
    procedure ApplyNativeBehavior;
    procedure DrawDataSetChrome(const ACanvas: ISkCanvas; const ADest: TRectF);
    procedure DrawPreview(const ACanvas: ISkCanvas; const ADest: TRectF);
    procedure EnsurePaintBox;
    function HasActiveDataSet: Boolean;
    procedure PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    procedure PaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxMouseWheel(Sender: TObject; Shift: TShiftState;
      WheelDelta: Integer; MousePos: TPoint; var Handled: Boolean);
    procedure SetCornerRadius(const AValue: Integer);
    procedure SetFooterText(const AValue: string);
    procedure SetFooterValue(const AValue: string);
    procedure SetShowFooter(const AValue: Boolean);
    procedure SetStatusFieldName(const AValue: string);
    function TryHitAction(const X, Y: Integer; out AColumn: TColumn;
      out AAction: TDACDataGridActionKind): Boolean;
    procedure UpdatePreview;
    procedure UpdatePaintBoxBounds;
    procedure WMEraseBkgnd(var AMessage: TWMEraseBkgnd); message WM_ERASEBKGND;
  protected
    procedure ChangeScale(M, D: Integer); override;
    procedure CreateWnd; override;
    procedure Loaded; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Redraw;
  published
    property Align;
    property Anchors;
    property BiDiMode;
    property BorderStyle;
    property Color;
    property Columns stored False;
    property Constraints;
    property CornerRadius: Integer read FCornerRadius write SetCornerRadius default 8;
    property Ctl3D;
    property DataSource;
    property DragCursor;
    property DragKind;
    property DragMode;
    property Enabled;
    property FixedColor;
    property Font;
    property FooterText: string read FFooterText write SetFooterText;
    property FooterValue: string read FFooterValue write SetFooterValue;
    property Hint;
    property Options;
    property ParentBiDiMode;
    property ParentColor;
    property ParentCtl3D;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly;
    property ShowFooter: Boolean read FShowFooter write SetShowFooter default True;
    property ShowHint;
    property StatusFieldName: string read FStatusFieldName write SetStatusFieldName;
    property TabOrder;
    property TabStop;
    property TitleFont;
    property Visible;
    property OnCellClick;
    property OnColEnter;
    property OnColExit;
    property OnColumnMoved;
    property OnDrawColumnCell;
    property OnDblClick;
    property OnDragDrop;
    property OnDragOver;
    property OnEndDock;
    property OnEndDrag;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
    property OnActionClick: TDACDataGridActionClickEvent read FOnActionClick write FOnActionClick;
    property OnStartDock;
    property OnStartDrag;
    property OnTitleClick;
  end;

implementation

uses
  System.Math,
  System.SysUtils,
  DAC.Components.Controls.DataGridColumns,
  DAC.Components.DesignSystem.ColorTokens,
  DAC.Components.DesignSystem.Fonts;

const
  GridHeaderColor: TAlphaColor = TAlphaColor($FF111827);

procedure TDACDataGridPaintBox.SetWheelHandler(const AHandler: TMouseWheelEvent);
begin
  OnMouseWheel := AHandler;
end;

constructor TDACDataGrid.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  Width := 760;
  Height := 170;
  FCornerRadius := 8;
  FFooterText := 'Total: 0 registros';
  FFooterValue := '';
  FShowFooter := True;
  FStatusFieldName := 'STATUS';
  FHoverCell.X := -1;
  FHoverCell.Y := -1;
  BorderStyle := bsNone;
  Ctl3D := False;
  ReadOnly := True;
  TabStop := True;
  Options := Options + [dgTitles, dgColLines, dgRowLines, dgRowSelect];
  Options := Options - [dgIndicator];
  ApplyNativeBehavior;
  FRenderer := TDACSkiaRenderer.Create;
  UpdatePreview;
end;

destructor TDACDataGrid.Destroy;
begin
  FPaintBox.Free;
  FRenderer.Free;
  inherited;
end;

function TDACDataGrid.ActionAt(const ACellRect: TRect; const X,
  Y: Integer): TDACDataGridActionKind;
begin
  if PtInRect(ActionRect(ACellRect, mdgakEdit), Point(X, Y)) then
    Result := mdgakEdit
  else if PtInRect(ActionRect(ACellRect, mdgakDelete), Point(X, Y)) then
    Result := mdgakDelete
  else if PtInRect(ActionRect(ACellRect, mdgakMore), Point(X, Y)) then
    Result := mdgakMore
  else
    Result := mdgakNone;
end;

function TDACDataGrid.ActionRect(const ACellRect: TRect;
  const AAction: TDACDataGridActionKind): TRect;
const
  ActionSize = 18;
  ActionGap = 5;
var
  LLeft: Integer;
begin
  LLeft := ACellRect.Left + Max(6, (ACellRect.Width - ((ActionSize * 3) +
    (ActionGap * 2))) div 2);
  case AAction of
    mdgakDelete: Inc(LLeft, ActionSize + ActionGap);
    mdgakMore: Inc(LLeft, (ActionSize + ActionGap) * 2);
  end;
  Result := Rect(LLeft, ACellRect.Top + ((ACellRect.Height - ActionSize) div 2),
    LLeft + ActionSize, ACellRect.Top + ((ACellRect.Height - ActionSize) div 2) + ActionSize);
end;

procedure TDACDataGrid.ApplyNativeBehavior;
begin
  Color := TDACComponentColors.ToVclColor(TDACComponentColors.White);
  FixedColor := TDACComponentColors.ToVclColor(GridHeaderColor);
  Font.Name := TDACComponentFontInstaller.FontFamily;
  Font.Size := 9;
  Font.Color := TDACComponentColors.ToVclColor(TDACComponentColors.ControlText);
  TitleFont.Assign(Font);
  TitleFont.Color := TDACComponentColors.ToVclColor(TDACComponentColors.White);
  TitleFont.Style := [];
  DefaultDrawing := True;
end;

procedure TDACDataGrid.ChangeScale(M, D: Integer);
begin
  inherited;
  ApplyNativeBehavior;
  UpdatePreview;
end;

procedure TDACDataGrid.CreateWnd;
begin
  inherited;
  ApplyNativeBehavior;
  UpdatePreview;
end;

procedure TDACDataGrid.EnsurePaintBox;
begin
  if (FPaintBox <> nil) or (Parent = nil) or not HandleAllocated or
    not Parent.HandleAllocated then
    Exit;
  FPaintBox := TDACDataGridPaintBox.Create(Self);
  FPaintBox.Parent := Self;
  FPaintBox.SetSubComponent(True);
  FPaintBox.StyleElements := [];
  FPaintBox.OnDraw := PaintBoxDraw;
  FPaintBox.OnMouseDown := PaintBoxMouseDown;
  FPaintBox.OnMouseMove := PaintBoxMouseMove;
  FPaintBox.OnMouseUp := PaintBoxMouseUp;
  FPaintBox.SetWheelHandler(PaintBoxMouseWheel);
end;

procedure TDACDataGrid.DrawDataSetChrome(const ACanvas: ISkCanvas;
  const ADest: TRectF);
var
  LCell: TRect;
  LCellRect: TRectF;
  LColumn: TColumn;
  LColumnCount: Integer;
  LField: TField;
  LHeaderRect: TRectF;
  I: Integer;
  LRow: Integer;
  LRowRect: TRectF;
  LStatus: Boolean;
  LText: string;
  LOriginalActiveRecord: Integer;
  function GridColumnAt(const AIndex: Integer): TColumn;
  begin
    Result := TDACDataGridColumnResolver.ColumnAt(Self, AIndex);
  end;
  function GridFieldAt(const AIndex: Integer): TField;
  begin
    Result := TDACDataGridColumnResolver.FieldAt(Self, AIndex);
  end;
  function CellBounds(const AColumn, ARow: Integer): TRectF;
  begin
    if (AColumn >= 0) and (AColumn < ColCount) then
    begin
      LCell := CellRect(AColumn, ARow);
      Exit(TRectF.Create(LCell.Left, LCell.Top, LCell.Right, LCell.Bottom));
    end;
    Result := TRectF.Create((AColumn * ADest.Width) / LColumnCount,
      ARow * DefaultRowHeight, ((AColumn + 1) * ADest.Width) / LColumnCount,
      (ARow + 1) * DefaultRowHeight);
  end;
  procedure DrawActionChrome(const ARect: TRectF);
  var
    J: Integer;
    LActionRect: TRectF;
    LGap: Single;
    LSize: Single;
  begin
    LGap := 4;
    LSize := 16;
    for J := 0 to 2 do
    begin
      LActionRect := TRectF.Create(ARect.Left + 6 + (J * (LSize + LGap)),
        ARect.Top + ((ARect.Height - LSize) / 2),
        ARect.Left + 6 + (J * (LSize + LGap)) + LSize,
        ARect.Top + ((ARect.Height - LSize) / 2) + LSize);
      if J = 1 then
        FRenderer.FillRoundRect(ACanvas, LActionRect, TDACComponentColors.Alpha(253, 235, 233), 5)
      else
        FRenderer.FillRoundRect(ACanvas, LActionRect, TDACComponentColors.Alpha(232, 247, 228), 5);
      FRenderer.StrokeRoundRect(ACanvas, LActionRect,
        TDACComponentColors.ControlBorder, 5, 1);
    end;
  end;
begin
  if (ACanvas = nil) or not HasActiveDataSet then
    Exit;
  LColumnCount := TDACDataGridColumnResolver.Count(Self);
  if LColumnCount = 0 then
    Exit;
  ACanvas.Clear(TDACComponentColors.White);
  FRenderer.FillRoundRect(ACanvas, TRectF.Create(0.5, 0.5,
    ADest.Width - 0.5, ADest.Height - 0.5), TDACComponentColors.White, FCornerRadius);
  FRenderer.StrokeRoundRect(ACanvas, TRectF.Create(0.5, 0.5,
    ADest.Width - 0.5, ADest.Height - 0.5),
    TDACComponentColors.ControlBorder, FCornerRadius, 1);

  for I := 0 to LColumnCount - 1 do
  begin
    LHeaderRect := CellBounds(I, 0);
    FRenderer.FillRoundRect(ACanvas, LHeaderRect, GridHeaderColor, 0);
    LColumn := GridColumnAt(I);
    if LColumn <> nil then
      LText := LColumn.Title.Caption
    else if GridFieldAt(I) <> nil then
      LText := GridFieldAt(I).DisplayName
    else
      LText := '';
    FRenderer.TextCentered(ACanvas, LText, TDACComponentFontInstaller.FontFamily,
      LHeaderRect, 9, TDACComponentColors.White, True);
  end;

  LOriginalActiveRecord := DataLink.ActiveRecord;
  try
    for LRow := FixedRows to RowCount - 1 do
    begin
      DataLink.ActiveRecord := LRow - FixedRows;
      LRowRect := CellBounds(0, LRow);
      LRowRect.Right := ADest.Width - 1;
      if (LRow mod 2) = 0 then
        FRenderer.FillRoundRect(ACanvas, LRowRect,
          TDACComponentColors.Alpha(250, 252, 250), 0);
      if LRow = Row then
        FRenderer.FillRoundRect(ACanvas, LRowRect,
          TDACComponentColors.Alpha(232, 247, 228), 0, 120);
      for I := 0 to LColumnCount - 1 do
      begin
        LCellRect := CellBounds(I, LRow);
        LColumn := GridColumnAt(I);
        LField := GridFieldAt(I);
        if LField <> nil then
          LText := LField.DisplayText
        else
          LText := '';
        LStatus := (LField <> nil) and SameText(LField.FieldName, FStatusFieldName);
        if LStatus then
        begin
          FRenderer.FillRoundRect(ACanvas, TRectF.Create(LCellRect.Left + 6,
            LCellRect.Top + 6, LCellRect.Right - 6, LCellRect.Bottom - 6),
            TDACComponentColors.Alpha(232, 247, 228), 9);
          FRenderer.TextCentered(ACanvas, LText, TDACComponentFontInstaller.FontFamily,
            TRectF.Create(LCellRect.Left + 6, LCellRect.Top + 6,
            LCellRect.Right - 6, LCellRect.Bottom - 6), 8,
            TDACComponentColors.PrimaryDark, True);
        end
        else if (LColumn <> nil) and (LField <> nil) and
          SameText(LField.FieldName, 'ACTIONS') then
          DrawActionChrome(LCellRect)
        else
          FRenderer.TextCentered(ACanvas, LText, TDACComponentFontInstaller.FontFamily,
            TRectF.Create(LCellRect.Left + 6, LCellRect.Top,
            LCellRect.Right - 6, LCellRect.Bottom), 9,
            TDACComponentColors.ControlText);
        if (FHoverCell.X = I) and (FHoverCell.Y = LRow) then
          FRenderer.StrokeRoundRect(ACanvas, TRectF.Create(LCellRect.Left + 1,
            LCellRect.Top + 1, LCellRect.Right - 1, LCellRect.Bottom - 1),
            TDACComponentColors.PrimaryLight, 4, 1);
      end;
    end;
  finally
    DataLink.ActiveRecord := LOriginalActiveRecord;
  end;
end;

procedure TDACDataGrid.DrawPreview(const ACanvas: ISkCanvas; const ADest: TRectF);
const
  Headers: array[0..6] of string = ('ID', 'Cliente', 'Cidade', 'Status', 'Valor', 'Data', 'Acoes');
  Row1: array[0..5] of string = ('1001', 'Maria Silva', 'Sao Paulo - SP', 'Ativo', '1.250,00', '24/05/2025');
  Row2: array[0..5] of string = ('1002', 'Joao Santos', 'Rio de Janeiro - RJ', 'Ativo', '980,50', '24/05/2025');
var
  I: Integer;
  LCellWidth: Single;
  LHeader: TRectF;
  LRect: TRectF;
  LRowTop: Single;
  procedure DrawRow(const AValues: array of string; const ATop: Single);
  var
    J: Integer;
    LCell: TRectF;
  begin
    FRenderer.FillRoundRect(ACanvas, TRectF.Create(1, ATop, ADest.Width - 1,
      ATop + 32), TDACComponentColors.Alpha(250, 252, 250), 0);
    for J := 0 to High(AValues) do
    begin
      LCell := TRectF.Create(8 + (J * LCellWidth), ATop, (J + 1) * LCellWidth - 8,
        ATop + 32);
      FRenderer.TextCentered(ACanvas, AValues[J], TDACComponentFontInstaller.FontFamily,
        LCell, 9, TDACComponentColors.ControlText);
    end;
    FRenderer.FillRoundRect(ACanvas, TRectF.Create(8 + (3 * LCellWidth), ATop + 7,
      (4 * LCellWidth) - 8, ATop + 25), TDACComponentColors.Alpha(232, 247, 228), 9);
    FRenderer.TextCentered(ACanvas, AValues[3], TDACComponentFontInstaller.FontFamily,
      TRectF.Create(8 + (3 * LCellWidth), ATop + 7, (4 * LCellWidth) - 8, ATop + 25),
      8, TDACComponentColors.PrimaryDark, True);
  end;
begin
  ACanvas.Clear(TDACComponentColors.White);
  LRect := TRectF.Create(0.5, 0.5, ADest.Width - 0.5, ADest.Height - 0.5);
  FRenderer.FillRoundRect(ACanvas, LRect, TDACComponentColors.White, FCornerRadius);
  FRenderer.StrokeRoundRect(ACanvas, LRect, TDACComponentColors.ControlBorder,
    FCornerRadius, 1);
  LHeader := TRectF.Create(1, 1, ADest.Width - 1, 34);
  FRenderer.FillRoundRect(ACanvas, LHeader, GridHeaderColor, FCornerRadius);
  LCellWidth := ADest.Width / Length(Headers);
  for I := Low(Headers) to High(Headers) do
    FRenderer.TextCentered(ACanvas, Headers[I], TDACComponentFontInstaller.FontFamily,
      TRectF.Create(I * LCellWidth + 4, 1, (I + 1) * LCellWidth - 4, 34), 9,
      TDACComponentColors.White, True);
  LRowTop := 35;
  DrawRow(Row1, LRowTop);
  DrawRow(Row2, LRowTop + 32);
  if FShowFooter then
  begin
    FRenderer.FillRoundRect(ACanvas, TRectF.Create(1, ADest.Height - 31,
      ADest.Width - 1, ADest.Height - 1), GridHeaderColor, 0);
    FRenderer.Text(ACanvas, FFooterText, TDACComponentFontInstaller.FontFamily,
      12, ADest.Height - 12, 9, TDACComponentColors.White, True, ADest.Width * 0.65);
    FRenderer.TextCentered(ACanvas, FFooterValue, TDACComponentFontInstaller.FontFamily,
      TRectF.Create(ADest.Width * 0.7, ADest.Height - 30, ADest.Width - 12, ADest.Height - 2),
      9, TDACComponentColors.White, True);
  end;
end;

function TDACDataGrid.HasActiveDataSet: Boolean;
begin
  Result := (DataSource <> nil) and (DataSource.DataSet <> nil) and DataSource.DataSet.Active;
end;

procedure TDACDataGrid.Loaded;
begin
  inherited;
  UpdatePreview;
end;

procedure TDACDataGrid.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited;
  Redraw;
end;

procedure TDACDataGrid.MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  LAction: TDACDataGridActionKind;
  LColumn: TColumn;
begin
  inherited;
  if (Button = mbLeft) and TryHitAction(X, Y, LColumn, LAction) and
    Assigned(FOnActionClick) then
    FOnActionClick(Self, LAction, LColumn);
end;

procedure TDACDataGrid.PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
  const ADest: TRectF; const AOpacity: Single);
begin
  if HasActiveDataSet then
    DrawDataSetChrome(ACanvas, ADest)
  else
    DrawPreview(ACanvas, ADest);
end;

procedure TDACDataGrid.PaintBoxMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if CanFocus then
    SetFocus;
  inherited MouseDown(Button, Shift, X, Y);
  Redraw;
end;

procedure TDACDataGrid.PaintBoxMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  LCell: TGridCoord;
begin
  inherited MouseMove(Shift, X, Y);
  LCell := MouseCoord(X, Y);
  if (LCell.X <> FHoverCell.X) or (LCell.Y <> FHoverCell.Y) then
  begin
    FHoverCell := LCell;
    Redraw;
  end;
end;

procedure TDACDataGrid.PaintBoxMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  MouseUp(Button, Shift, X, Y);
  Redraw;
end;

procedure TDACDataGrid.PaintBoxMouseWheel(Sender: TObject;
  Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint;
  var Handled: Boolean);
begin
  Perform(WM_MOUSEWHEEL, Word(WheelDelta) shl 16,
    (MousePos.X and $FFFF) or ((MousePos.Y and $FFFF) shl 16));
  Handled := True;
  Redraw;
end;

procedure TDACDataGrid.Redraw;
begin
  UpdatePreview;
  if (FPaintBox <> nil) and FPaintBox.Visible and HandleAllocated and
    (Parent <> nil) then
    FPaintBox.Redraw;
  Invalidate;
end;

procedure TDACDataGrid.Resize;
begin
  inherited;
  UpdatePreview;
end;

procedure TDACDataGrid.SetCornerRadius(const AValue: Integer);
begin
  FCornerRadius := Max(0, AValue);
  Redraw;
end;

procedure TDACDataGrid.SetFooterText(const AValue: string);
begin
  FFooterText := AValue;
  Redraw;
end;

procedure TDACDataGrid.SetFooterValue(const AValue: string);
begin
  FFooterValue := AValue;
  Redraw;
end;

procedure TDACDataGrid.SetShowFooter(const AValue: Boolean);
begin
  FShowFooter := AValue;
  Redraw;
end;

procedure TDACDataGrid.SetStatusFieldName(const AValue: string);
begin
  FStatusFieldName := AValue;
  Redraw;
end;

function TDACDataGrid.TryHitAction(const X, Y: Integer; out AColumn: TColumn;
  out AAction: TDACDataGridActionKind): Boolean;
var
  LCoord: TGridCoord;
begin
  AColumn := nil;
  AAction := mdgakNone;
  Result := False;
  if not HasActiveDataSet then
    Exit;
  LCoord := MouseCoord(X, Y);
  if (LCoord.X < 0) or (LCoord.Y <= 0) or (LCoord.X >= Columns.Count) then
    Exit;
  AColumn := Columns[LCoord.X];
  if not SameText(AColumn.FieldName, 'ACTIONS') then
  begin
    AColumn := nil;
    Exit;
  end;
  AAction := ActionAt(CellRect(LCoord.X, LCoord.Y), X, Y);
  Result := AAction <> mdgakNone;
end;

procedure TDACDataGrid.UpdatePaintBoxBounds;
var
  LHeight: Integer;
  LWidth: Integer;
begin
  if FPaintBox = nil then
    Exit;
  LWidth := Width;
  LHeight := Height;
  if HandleAllocated then
  begin
    LWidth := ClientWidth;
    LHeight := ClientHeight;
  end;
  FPaintBox.SetBounds(0, 0, LWidth, LHeight);
end;

procedure TDACDataGrid.UpdatePreview;
begin
  EnsurePaintBox;
  UpdatePaintBoxBounds;
  if FPaintBox = nil then
    Exit;
  FPaintBox.Visible := True;
  if HandleAllocated then
    FPaintBox.BringToFront;
  if HandleAllocated and (Parent <> nil) then
    FPaintBox.Redraw;
end;

procedure TDACDataGrid.WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
begin
  AMessage.Result := 1;
end;

end.
