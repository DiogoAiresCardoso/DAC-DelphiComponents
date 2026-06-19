unit MaxxRural.Components.Controls.DataGrid;

interface

uses
  System.Classes,
  System.Types,
  System.UITypes,
  Data.DB,
  Winapi.Messages,
  Vcl.Controls,
  Vcl.DBGrids,
  Vcl.Forms,
  Vcl.Grids,
  Vcl.Graphics;

type
  TMaxxRuralDataGridActionKind = (
    mdgakNone,
    mdgakEdit,
    mdgakDelete,
    mdgakMore
  );

  TMaxxRuralDataGridStatus = (
    mdgsNone,
    mdgsSuccess,
    mdgsWarning,
    mdgsDanger,
    mdgsInfo
  );

  TMaxxRuralDataGridActionClickEvent = procedure(Sender: TObject;
    AAction: TMaxxRuralDataGridActionKind; AColumn: TColumn) of object;

  TMaxxRuralDataGrid = class(TDBGrid)
  private
    FCornerRadius: Integer;
    FFooterText: string;
    FFooterValue: string;
    FHotAction: TMaxxRuralDataGridActionKind;
    FOnActionClick: TMaxxRuralDataGridActionClickEvent;
    FPressedAction: TMaxxRuralDataGridActionKind;
    FShowFooter: Boolean;
    FStatusFieldName: string;
    function ActionAt(const ACellRect: TRect; const X, Y: Integer): TMaxxRuralDataGridActionKind;
    function ActionRect(const ACellRect: TRect;
      const AAction: TMaxxRuralDataGridActionKind): TRect;
    procedure ApplyAppearance;
    procedure CMEnabledChanged(var AMessage: TMessage); message CM_ENABLEDCHANGED;
    procedure CMMouseLeave(var AMessage: TMessage); message CM_MOUSELEAVE;
    function ColumnFromGridCoord(const ACoord: TGridCoord): TColumn;
    procedure DoActionClick(const AAction: TMaxxRuralDataGridActionKind;
      AColumn: TColumn);
    procedure DrawActionsCell(const ARect: TRect);
    procedure DrawFooter(const ARect: TRect);
    procedure DrawPreview;
    procedure DrawPreviewRow(const ARowIndex: Integer; const AValues: array of string;
      const AStatus: TMaxxRuralDataGridStatus; const ARect: TRect);
    procedure DrawStatusPill(const ARect: TRect; const AText: string;
      const AStatus: TMaxxRuralDataGridStatus);
    procedure DrawTextCell(const ARect: TRect; const AText: string;
      const AAlignment: TAlignment; const ABold: Boolean = False);
    function HasActiveDataSet: Boolean;
    function IsActionsColumn(const AColumn: TColumn): Boolean;
    function IsStatusColumn(const AColumn: TColumn): Boolean;
    procedure SetCornerRadius(const AValue: Integer);
    procedure SetFooterText(const AValue: string);
    procedure SetFooterValue(const AValue: string);
    procedure SetShowFooter(const AValue: Boolean);
    procedure SetStatusFieldName(const AValue: string);
    function StatusBackgroundColor(const AStatus: TMaxxRuralDataGridStatus): TColor;
    function StatusFromText(const AText: string): TMaxxRuralDataGridStatus;
    function StatusTextColor(const AStatus: TMaxxRuralDataGridStatus): TColor;
    function TryHitAction(const X, Y: Integer; out AColumn: TColumn;
      out AAction: TMaxxRuralDataGridActionKind): Boolean;
    function TokenColor(const AColor: TAlphaColor): TColor;
    procedure WMEraseBkgnd(var AMessage: TWMEraseBkgnd); message WM_ERASEBKGND;
  protected
    procedure ChangeScale(M, D: Integer); override;
    procedure CreateWnd; override;
    procedure DrawColumnCell(const Rect: TRect; DataCol: Integer;
      Column: TColumn; State: TGridDrawState); override;
    procedure Loaded; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
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
    property OnActionClick: TMaxxRuralDataGridActionClickEvent read FOnActionClick write FOnActionClick;
    property OnStartDock;
    property OnStartDrag;
    property OnTitleClick;
  end;

implementation

uses
  System.Math,
  System.SysUtils,
  Winapi.Windows,
  MaxxRural.Components.DesignSystem.ColorTokens,
  MaxxRural.Components.DesignSystem.Fonts;

const
  GridHeaderColor: TAlphaColor = TAlphaColor($FF111827);

function TMaxxRuralDataGrid.ActionAt(const ACellRect: TRect; const X,
  Y: Integer): TMaxxRuralDataGridActionKind;
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

function TMaxxRuralDataGrid.ActionRect(const ACellRect: TRect;
  const AAction: TMaxxRuralDataGridActionKind): TRect;
const
  ActionSize = 18;
  ActionGap = 5;
var
  LLeft: Integer;
  LTop: Integer;
  LTotalWidth: Integer;
begin
  LTotalWidth := (ActionSize * 3) + (ActionGap * 2);
  LLeft := ACellRect.Left + Max(6, (ACellRect.Width - LTotalWidth) div 2);
  LTop := ACellRect.Top + ((ACellRect.Height - ActionSize) div 2);

  case AAction of
    mdgakDelete:
      Inc(LLeft, ActionSize + ActionGap);
    mdgakMore:
      Inc(LLeft, (ActionSize + ActionGap) * 2);
  end;

  Result := Rect(LLeft, LTop, LLeft + ActionSize, LTop + ActionSize);
end;

constructor TMaxxRuralDataGrid.Create(AOwner: TComponent);
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
  FHotAction := mdgakNone;
  FPressedAction := mdgakNone;

  BorderStyle := bsNone;
  Ctl3D := False;
  DefaultDrawing := False;
  ParentColor := False;
  ReadOnly := True;
  TabStop := True;

  Options := Options + [dgTitles, dgColLines, dgRowLines, dgRowSelect];
  Options := Options - [dgIndicator];
  ApplyAppearance;
end;

procedure TMaxxRuralDataGrid.ApplyAppearance;
begin
  Color := TokenColor(TMaxxRuralComponentColors.White);
  FixedColor := TokenColor(GridHeaderColor);
  Font.Name := TMaxxRuralComponentFontInstaller.FontFamily;
  Font.Size := 9;
  Font.Color := TokenColor(TMaxxRuralComponentColors.ControlText);
  TitleFont.Assign(Font);
  TitleFont.Color := TokenColor(TMaxxRuralComponentColors.White);
  TitleFont.Style := [fsBold];
end;

procedure TMaxxRuralDataGrid.ChangeScale(M, D: Integer);
begin
  inherited;
  ApplyAppearance;
  Invalidate;
end;

procedure TMaxxRuralDataGrid.CMEnabledChanged(var AMessage: TMessage);
begin
  inherited;
  Invalidate;
end;

procedure TMaxxRuralDataGrid.CMMouseLeave(var AMessage: TMessage);
begin
  inherited;
  if (FHotAction <> mdgakNone) or (FPressedAction <> mdgakNone) then
  begin
    FHotAction := mdgakNone;
    FPressedAction := mdgakNone;
    Cursor := crDefault;
    Invalidate;
  end;
end;

function TMaxxRuralDataGrid.ColumnFromGridCoord(
  const ACoord: TGridCoord): TColumn;
var
  LColumnIndex: Integer;
begin
  Result := nil;
  LColumnIndex := ACoord.X;
  if dgIndicator in Options then
    Dec(LColumnIndex);

  if (LColumnIndex >= 0) and (LColumnIndex < Columns.Count) then
    Result := Columns[LColumnIndex];
end;

procedure TMaxxRuralDataGrid.CreateWnd;
begin
  inherited;
  ApplyAppearance;
end;

procedure TMaxxRuralDataGrid.DoActionClick(
  const AAction: TMaxxRuralDataGridActionKind; AColumn: TColumn);
begin
  if Assigned(FOnActionClick) then
    FOnActionClick(Self, AAction, AColumn);
end;

procedure TMaxxRuralDataGrid.DrawActionsCell(const ARect: TRect);
var
  LCenterY: Integer;
  LHotPoint: TPoint;
  LHotRect: TRect;
  LRect: TRect;
begin
  Canvas.Brush.Style := bsClear;
  Canvas.Pen.Width := 1;
  Canvas.Pen.Color := TokenColor(TMaxxRuralComponentColors.Alpha(71, 85, 105));
  LCenterY := ARect.Top + (ARect.Height div 2);

  if FHotAction <> mdgakNone then
  begin
    GetCursorPos(LHotPoint);
    LHotPoint := ScreenToClient(LHotPoint);
    LHotRect := ActionRect(ARect, FHotAction);
    if PtInRect(LHotRect, LHotPoint) then
    begin
      Canvas.Brush.Color := TokenColor(TMaxxRuralComponentColors.Alpha(239, 247, 237));
      Canvas.Brush.Style := bsSolid;
      Canvas.Pen.Style := psClear;
      Canvas.RoundRect(LHotRect.Left, LHotRect.Top, LHotRect.Right, LHotRect.Bottom, 8, 8);
      Canvas.Pen.Style := psSolid;
      Canvas.Brush.Style := bsClear;
    end;
  end;

  LRect := ActionRect(ARect, mdgakEdit);
  InflateRect(LRect, -3, -3);
  Canvas.MoveTo(LRect.Left + 2, LRect.Bottom - 2);
  Canvas.LineTo(LRect.Right - 2, LRect.Top + 2);
  Canvas.Rectangle(LRect.Left, LRect.Top, LRect.Right, LRect.Bottom);

  Canvas.Pen.Color := TokenColor(TMaxxRuralComponentColors.Danger);
  LRect := ActionRect(ARect, mdgakDelete);
  InflateRect(LRect, -3, -3);
  Canvas.Rectangle(LRect.Left + 2, LRect.Top + 4, LRect.Right - 2, LRect.Bottom);
  Canvas.MoveTo(LRect.Left + 1, LRect.Top + 3);
  Canvas.LineTo(LRect.Right - 1, LRect.Top + 3);

  Canvas.Pen.Color := TokenColor(TMaxxRuralComponentColors.Alpha(100, 116, 139));
  LRect := ActionRect(ARect, mdgakMore);
  InflateRect(LRect, -3, -3);
  Canvas.Ellipse(LRect.Left + 1, LCenterY - 1, LRect.Left + 3, LCenterY + 1);
  Canvas.Ellipse(LRect.Left + 6, LCenterY - 1, LRect.Left + 8, LCenterY + 1);
  Canvas.Ellipse(LRect.Left + 11, LCenterY - 1, LRect.Left + 13, LCenterY + 1);
end;

procedure TMaxxRuralDataGrid.DrawColumnCell(const Rect: TRect; DataCol: Integer;
  Column: TColumn; State: TGridDrawState);
var
  LAlignment: TAlignment;
  LRect: TRect;
  LStatus: TMaxxRuralDataGridStatus;
  LText: string;
begin
  LRect := Rect;
  InflateRect(LRect, -1, -1);

  if gdSelected in State then
    Canvas.Brush.Color := TokenColor(TMaxxRuralComponentColors.Alpha(239, 247, 237))
  else
    Canvas.Brush.Color := Color;
  Canvas.FillRect(Rect);

  if IsActionsColumn(Column) then
  begin
    DrawActionsCell(LRect);
    Exit;
  end;

  if (Column <> nil) and (Column.Field <> nil) then
    LText := Column.Field.DisplayText
  else
    LText := '';

  if IsStatusColumn(Column) then
  begin
    LStatus := StatusFromText(LText);
    DrawStatusPill(LRect, LText, LStatus);
    Exit;
  end;

  LAlignment := taLeftJustify;
  if Column <> nil then
    LAlignment := Column.Alignment;
  DrawTextCell(LRect, LText, LAlignment);
end;

procedure TMaxxRuralDataGrid.DrawFooter(const ARect: TRect);
var
  LRect: TRect;
begin
  LRect := ARect;
  Canvas.Brush.Color := TokenColor(GridHeaderColor);
  Canvas.FillRect(LRect);

  Canvas.Font.Assign(TitleFont);
  Canvas.Font.Color := clWhite;
  DrawTextCell(Rect(LRect.Left + 10, LRect.Top, LRect.Left + 280, LRect.Bottom),
    FFooterText, taLeftJustify, True);
  DrawTextCell(Rect(LRect.Right - 150, LRect.Top, LRect.Right - 10, LRect.Bottom),
    FFooterValue, taRightJustify, True);
end;

procedure TMaxxRuralDataGrid.DrawPreview;
var
  LFooterRect: TRect;
  LHeaderRect: TRect;
  LRect: TRect;
  LRowTop: Integer;
begin
  Canvas.Brush.Color := Color;
  Canvas.FillRect(ClientRect);

  LRect := ClientRect;
  InflateRect(LRect, -1, -1);
  Canvas.Pen.Color := TokenColor(TMaxxRuralComponentColors.ControlBorder);
  Canvas.Brush.Style := bsClear;
  Canvas.RoundRect(LRect.Left, LRect.Top, LRect.Right, LRect.Bottom,
    FCornerRadius, FCornerRadius);

  LHeaderRect := Rect(LRect.Left + 1, LRect.Top + 1, LRect.Right - 1,
    LRect.Top + 31);
  Canvas.Brush.Color := TokenColor(GridHeaderColor);
  Canvas.FillRect(LHeaderRect);
  Canvas.Font.Assign(TitleFont);
  DrawTextCell(Rect(LHeaderRect.Left + 8, LHeaderRect.Top, LHeaderRect.Left + 70,
    LHeaderRect.Bottom), 'ID', taLeftJustify, True);
  DrawTextCell(Rect(LHeaderRect.Left + 70, LHeaderRect.Top, LHeaderRect.Left + 230,
    LHeaderRect.Bottom), 'Nome do Cliente', taLeftJustify, True);
  DrawTextCell(Rect(LHeaderRect.Left + 230, LHeaderRect.Top, LHeaderRect.Left + 390,
    LHeaderRect.Bottom), 'Cidade', taLeftJustify, True);
  DrawTextCell(Rect(LHeaderRect.Left + 390, LHeaderRect.Top, LHeaderRect.Left + 490,
    LHeaderRect.Bottom), 'Status', taCenter, True);
  DrawTextCell(Rect(LHeaderRect.Left + 490, LHeaderRect.Top, LHeaderRect.Left + 600,
    LHeaderRect.Bottom), 'Valor (R$)', taRightJustify, True);
  DrawTextCell(Rect(LHeaderRect.Left + 600, LHeaderRect.Top, LHeaderRect.Left + 690,
    LHeaderRect.Bottom), 'Data', taCenter, True);
  DrawTextCell(Rect(LHeaderRect.Left + 690, LHeaderRect.Top, LHeaderRect.Right,
    LHeaderRect.Bottom), 'Acoes', taCenter, True);

  Canvas.Font.Assign(Font);
  LRowTop := LHeaderRect.Bottom;
  DrawPreviewRow(0, ['1001', 'Maria Silva', 'Sao Paulo - SP', 'Ativo',
    '1.250,00', '24/05/2025'], mdgsSuccess, Rect(LRect.Left + 1, LRowTop,
    LRect.Right - 1, LRowTop + 30));
  Inc(LRowTop, 30);
  DrawPreviewRow(1, ['1002', 'Joao Santos', 'Rio de Janeiro - RJ', 'Ativo',
    '980,50', '24/05/2025'], mdgsSuccess, Rect(LRect.Left + 1, LRowTop,
    LRect.Right - 1, LRowTop + 30));
  Inc(LRowTop, 30);
  DrawPreviewRow(2, ['1003', 'Ana Oliveira', 'Belo Horizonte - MG', 'Pendente',
    '750,00', '23/05/2025'], mdgsWarning, Rect(LRect.Left + 1, LRowTop,
    LRect.Right - 1, LRowTop + 30));

  if FShowFooter then
  begin
    LFooterRect := Rect(LRect.Left + 1, LRect.Bottom - 30, LRect.Right - 1,
      LRect.Bottom - 1);
    DrawFooter(LFooterRect);
  end;
end;

procedure TMaxxRuralDataGrid.DrawPreviewRow(const ARowIndex: Integer;
  const AValues: array of string; const AStatus: TMaxxRuralDataGridStatus;
  const ARect: TRect);
var
  LRect: TRect;
begin
  if Odd(ARowIndex) then
    Canvas.Brush.Color := TokenColor(TMaxxRuralComponentColors.Alpha(250, 252, 250))
  else
    Canvas.Brush.Color := Color;
  Canvas.FillRect(ARect);
  Canvas.Pen.Color := TokenColor(TMaxxRuralComponentColors.Alpha(226, 232, 240));
  Canvas.MoveTo(ARect.Left, ARect.Bottom);
  Canvas.LineTo(ARect.Right, ARect.Bottom);

  LRect := Rect(ARect.Left + 8, ARect.Top, ARect.Left + 70, ARect.Bottom);
  DrawTextCell(LRect, AValues[0], taLeftJustify);
  LRect := Rect(ARect.Left + 70, ARect.Top, ARect.Left + 230, ARect.Bottom);
  DrawTextCell(LRect, AValues[1], taLeftJustify);
  LRect := Rect(ARect.Left + 230, ARect.Top, ARect.Left + 390, ARect.Bottom);
  DrawTextCell(LRect, AValues[2], taLeftJustify);
  LRect := Rect(ARect.Left + 390, ARect.Top, ARect.Left + 490, ARect.Bottom);
  DrawStatusPill(LRect, AValues[3], AStatus);
  LRect := Rect(ARect.Left + 490, ARect.Top, ARect.Left + 600, ARect.Bottom);
  DrawTextCell(LRect, AValues[4], taRightJustify);
  LRect := Rect(ARect.Left + 600, ARect.Top, ARect.Left + 690, ARect.Bottom);
  DrawTextCell(LRect, AValues[5], taCenter);
  LRect := Rect(ARect.Left + 690, ARect.Top, ARect.Right, ARect.Bottom);
  DrawActionsCell(LRect);
end;

procedure TMaxxRuralDataGrid.DrawStatusPill(const ARect: TRect;
  const AText: string; const AStatus: TMaxxRuralDataGridStatus);
var
  LRect: TRect;
  LTextWidth: Integer;
begin
  Canvas.Font.Assign(Font);
  LTextWidth := Canvas.TextWidth(AText) + 20;
  LTextWidth := Min(ARect.Width - 8, Max(56, LTextWidth));
  LRect := Rect(ARect.Left + ((ARect.Width - LTextWidth) div 2),
    ARect.Top + ((ARect.Height - 20) div 2),
    ARect.Left + ((ARect.Width + LTextWidth) div 2),
    ARect.Top + ((ARect.Height + 20) div 2));

  Canvas.Brush.Color := StatusBackgroundColor(AStatus);
  Canvas.Pen.Style := psClear;
  Canvas.RoundRect(LRect.Left, LRect.Top, LRect.Right, LRect.Bottom, 10, 10);
  Canvas.Pen.Style := psSolid;
  Canvas.Font.Color := StatusTextColor(AStatus);
  DrawTextCell(LRect, AText, taCenter);
end;

procedure TMaxxRuralDataGrid.DrawTextCell(const ARect: TRect; const AText: string;
  const AAlignment: TAlignment; const ABold: Boolean);
var
  LFlags: Cardinal;
  LRect: TRect;
begin
  LRect := ARect;
  InflateRect(LRect, -8, 0);
  SetBkMode(Canvas.Handle, TRANSPARENT);
  if ABold then
    Canvas.Font.Style := Canvas.Font.Style + [fsBold]
  else
    Canvas.Font.Style := Canvas.Font.Style - [fsBold];

  LFlags := DT_SINGLELINE or DT_VCENTER or DT_END_ELLIPSIS;
  case AAlignment of
    taRightJustify:
      LFlags := LFlags or DT_RIGHT;
    taCenter:
      LFlags := LFlags or DT_CENTER;
  else
    LFlags := LFlags or DT_LEFT;
  end;
  DrawText(Canvas.Handle, PChar(AText), Length(AText), LRect, LFlags);
end;

function TMaxxRuralDataGrid.HasActiveDataSet: Boolean;
begin
  Result := (DataSource <> nil) and (DataSource.DataSet <> nil) and
    DataSource.DataSet.Active;
end;

function TMaxxRuralDataGrid.IsActionsColumn(const AColumn: TColumn): Boolean;
var
  LTitle: string;
begin
  Result := False;
  if AColumn = nil then
    Exit;
  LTitle := AColumn.Title.Caption.Trim;
  Result := SameText(LTitle, 'Acoes') or SameText(LTitle, 'Acoes...') or
    SameText(LTitle, 'A' + #231 + #245 + 'es') or
    SameText(LTitle, 'A' + #231 + #245 + 'es...');
end;

function TMaxxRuralDataGrid.IsStatusColumn(const AColumn: TColumn): Boolean;
begin
  Result := False;
  if AColumn = nil then
    Exit;
  Result := SameText(AColumn.FieldName, FStatusFieldName) or
    SameText(AColumn.Title.Caption, 'Status');
end;

procedure TMaxxRuralDataGrid.Loaded;
begin
  inherited;
  ApplyAppearance;
end;

procedure TMaxxRuralDataGrid.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  LAction: TMaxxRuralDataGridActionKind;
  LColumn: TColumn;
begin
  inherited;

  if (Button = mbLeft) and TryHitAction(X, Y, LColumn, LAction) then
  begin
    FPressedAction := LAction;
    FHotAction := LAction;
    Cursor := crHandPoint;
    Invalidate;
  end;
end;

procedure TMaxxRuralDataGrid.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LAction: TMaxxRuralDataGridActionKind;
  LColumn: TColumn;
begin
  inherited;

  if TryHitAction(X, Y, LColumn, LAction) then
  begin
    Cursor := crHandPoint;
    if FHotAction <> LAction then
    begin
      FHotAction := LAction;
      Invalidate;
    end;
    Exit;
  end;

  if FHotAction <> mdgakNone then
  begin
    FHotAction := mdgakNone;
    Cursor := crDefault;
    Invalidate;
  end
  else if Cursor <> crDefault then
    Cursor := crDefault;
end;

procedure TMaxxRuralDataGrid.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  LAction: TMaxxRuralDataGridActionKind;
  LColumn: TColumn;
  LPressedAction: TMaxxRuralDataGridActionKind;
begin
  inherited;

  LPressedAction := FPressedAction;
  FPressedAction := mdgakNone;

  if (Button = mbLeft) and (LPressedAction <> mdgakNone) and
    TryHitAction(X, Y, LColumn, LAction) and (LAction = LPressedAction) then
    DoActionClick(LAction, LColumn);
end;

procedure TMaxxRuralDataGrid.Paint;
var
  LFooterRect: TRect;
begin
  if not HasActiveDataSet then
  begin
    DrawPreview;
    Exit;
  end;

  inherited Paint;

  if FShowFooter then
  begin
    LFooterRect := Rect(0, ClientHeight - 30, ClientWidth, ClientHeight);
    DrawFooter(LFooterRect);
  end;
end;

procedure TMaxxRuralDataGrid.Redraw;
begin
  Invalidate;
end;

procedure TMaxxRuralDataGrid.SetCornerRadius(const AValue: Integer);
begin
  if FCornerRadius <> AValue then
  begin
    FCornerRadius := Max(0, AValue);
    Invalidate;
  end;
end;

procedure TMaxxRuralDataGrid.SetFooterText(const AValue: string);
begin
  if FFooterText <> AValue then
  begin
    FFooterText := AValue;
    Invalidate;
  end;
end;

procedure TMaxxRuralDataGrid.SetFooterValue(const AValue: string);
begin
  if FFooterValue <> AValue then
  begin
    FFooterValue := AValue;
    Invalidate;
  end;
end;

procedure TMaxxRuralDataGrid.SetShowFooter(const AValue: Boolean);
begin
  if FShowFooter <> AValue then
  begin
    FShowFooter := AValue;
    Invalidate;
  end;
end;

procedure TMaxxRuralDataGrid.SetStatusFieldName(const AValue: string);
begin
  if FStatusFieldName <> AValue then
  begin
    FStatusFieldName := AValue;
    Invalidate;
  end;
end;

function TMaxxRuralDataGrid.StatusBackgroundColor(
  const AStatus: TMaxxRuralDataGridStatus): TColor;
begin
  case AStatus of
    mdgsWarning:
      Result := TokenColor(TMaxxRuralComponentColors.Alpha(255, 244, 205));
    mdgsDanger:
      Result := TokenColor(TMaxxRuralComponentColors.Alpha(255, 224, 224));
    mdgsInfo:
      Result := TokenColor(TMaxxRuralComponentColors.Alpha(219, 234, 254));
  else
    Result := TokenColor(TMaxxRuralComponentColors.Alpha(220, 244, 215));
  end;
end;

function TMaxxRuralDataGrid.StatusFromText(
  const AText: string): TMaxxRuralDataGridStatus;
begin
  if SameText(AText, 'Pendente') or SameText(AText, 'Alerta') then
    Result := mdgsWarning
  else if SameText(AText, 'Cancelado') or SameText(AText, 'Erro') then
    Result := mdgsDanger
  else if SameText(AText, 'Info') then
    Result := mdgsInfo
  else if AText = '' then
    Result := mdgsNone
  else
    Result := mdgsSuccess;
end;

function TMaxxRuralDataGrid.StatusTextColor(
  const AStatus: TMaxxRuralDataGridStatus): TColor;
begin
  case AStatus of
    mdgsWarning:
      Result := TokenColor(TMaxxRuralComponentColors.Alpha(146, 100, 12));
    mdgsDanger:
      Result := TokenColor(TMaxxRuralComponentColors.DangerDark);
    mdgsInfo:
      Result := TokenColor(TMaxxRuralComponentColors.Alpha(37, 99, 235));
  else
    Result := TokenColor(TMaxxRuralComponentColors.Primary);
  end;
end;

function TMaxxRuralDataGrid.TryHitAction(const X, Y: Integer;
  out AColumn: TColumn; out AAction: TMaxxRuralDataGridActionKind): Boolean;
var
  LCellRect: TRect;
  LCoord: TGridCoord;
begin
  AColumn := nil;
  AAction := mdgakNone;
  Result := False;

  if not HasActiveDataSet then
    Exit;

  if FShowFooter and (Y >= ClientHeight - 30) then
    Exit;

  LCoord := MouseCoord(X, Y);
  if (LCoord.X < 0) or (LCoord.Y <= 0) then
    Exit;

  AColumn := ColumnFromGridCoord(LCoord);
  if not IsActionsColumn(AColumn) then
    Exit;

  LCellRect := CellRect(LCoord.X, LCoord.Y);
  AAction := ActionAt(LCellRect, X, Y);
  Result := AAction <> mdgakNone;
end;

function TMaxxRuralDataGrid.TokenColor(const AColor: TAlphaColor): TColor;
begin
  Result := TMaxxRuralComponentColors.ToVclColor(AColor);
end;

procedure TMaxxRuralDataGrid.WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
begin
  AMessage.Result := 1;
end;

end.
