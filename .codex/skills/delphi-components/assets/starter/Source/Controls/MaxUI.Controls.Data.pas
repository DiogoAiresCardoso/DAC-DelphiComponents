unit MaxUI.Controls.Data;

{$CODEPAGE 65001}

interface

uses
  System.Classes,
  Winapi.Messages,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.Grids,
  Vcl.DBGrids,
  Data.DB;

type
  TMaxStringGrid = class(TStringGrid)
  private
    FZebraRows: Boolean;
    FShowRowHover: Boolean;
    FHoverRow: Integer;
    FSelectedRowColor: TColor;
    FHeaderHeightLogical: Integer;
    FRowHeightLogical: Integer;
    FStatusColumn: Integer;
    FActionColumn: Integer;
    procedure SetZebraRows(const Value: Boolean);
    procedure SetShowRowHover(const Value: Boolean);
    procedure SetSelectedRowColor(const Value: TColor);
    procedure SetHeaderHeightLogical(const Value: Integer);
    procedure SetRowHeightLogical(const Value: Integer);
    procedure SetStatusColumn(const Value: Integer);
    procedure SetActionColumn(const Value: Integer);
    procedure UpdateMetrics;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
  protected
    procedure DrawCell(ACol, ARow: Longint; ARect: TRect;
      AState: TGridDrawState); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure ChangeScale(M, D: Integer; isDpiChange: Boolean); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property ZebraRows: Boolean read FZebraRows write SetZebraRows default True;
    property ShowRowHover: Boolean read FShowRowHover write SetShowRowHover default True;
    property SelectedRowColor: TColor read FSelectedRowColor write SetSelectedRowColor;
    property HeaderHeightLogical: Integer read FHeaderHeightLogical write SetHeaderHeightLogical default 30;
    property RowHeightLogical: Integer read FRowHeightLogical write SetRowHeightLogical default 28;
    property StatusColumn: Integer read FStatusColumn write SetStatusColumn default -1;
    property ActionColumn: Integer read FActionColumn write SetActionColumn default -1;
  end;

  TMaxDBGrid = class(TDBGrid)
  private
    FZebraRows: Boolean;
    FSelectedRowColor: TColor;
    FStatusField: string;
    procedure SetZebraRows(const Value: Boolean);
    procedure SetSelectedRowColor(const Value: TColor);
    procedure SetStatusField(const Value: string);
  protected
    procedure DrawColumnCell(const Rect: TRect; DataCol: Integer;
      Column: TColumn; State: TGridDrawState); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property ZebraRows: Boolean read FZebraRows write SetZebraRows default True;
    property SelectedRowColor: TColor read FSelectedRowColor write SetSelectedRowColor;
    property StatusField: string read FStatusField write SetStatusField;
  end;

  TMaxStatusBar = class(TCustomControl)
  private
    FConnectionText: string;
    FUserText: string;
    FRoleText: string;
    FDateText: string;
    FTimeText: string;
    FSecure: Boolean;
    procedure SetConnectionText(const Value: string);
    procedure SetUserText(const Value: string);
    procedure SetRoleText(const Value: string);
    procedure SetDateText(const Value: string);
    procedure SetTimeText(const Value: string);
    procedure SetSecure(const Value: Boolean);
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Align;
    property Anchors;
    property Font;
    property ParentFont;
    property ConnectionText: string read FConnectionText write SetConnectionText;
    property UserText: string read FUserText write SetUserText;
    property RoleText: string read FRoleText write SetRoleText;
    property DateText: string read FDateText write SetDateText;
    property TimeText: string read FTimeText write SetTimeText;
    property Secure: Boolean read FSecure write SetSecure default True;
  end;

implementation

uses
  System.Math,
  System.SysUtils,
  Winapi.Windows,
  MaxUI.Dpi,
  MaxUI.Icons,
  MaxUI.Painter,
  MaxUI.Theme,
  MaxUI.Types;

function StatusKind(const S: string): TMaxPillKind;
begin
  if SameText(S, 'Ativo') or SameText(S, 'Concluído') then
    Result := mpkSuccess
  else if SameText(S, 'Pendente') or SameText(S, 'Em análise') then
    Result := mpkWarning
  else if SameText(S, 'Cancelado') or SameText(S, 'Inativo') then
    Result := mpkDanger
  else
    Result := mpkNeutral;
end;

constructor TMaxStringGrid.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FZebraRows := True;
  FShowRowHover := True;
  FHoverRow := -1;
  FSelectedRowColor := TMaxTheme.Palette.PrimarySoft;
  FHeaderHeightLogical := 30;
  FRowHeightLogical := 28;
  FStatusColumn := -1;
  FActionColumn := -1;
  DefaultDrawing := False;
  DoubleBuffered := True;
  StyleElements := [seFont];
  Color := TMaxTheme.Palette.Surface;
  FixedColor := TMaxTheme.Palette.PrimaryDark;
  Font.Name := 'Inter';
  Font.Size := 9;
  Options := Options + [goRowSelect] - [goEditing];
  ColCount := 5;
  RowCount := 6;
  FixedRows := 1;
  FixedCols := 0;
  UpdateMetrics;
end;

procedure TMaxStringGrid.ChangeScale(M, D: Integer; isDpiChange: Boolean);
begin
  inherited;
  if isDpiChange then UpdateMetrics;
end;

procedure TMaxStringGrid.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if FHoverRow <> -1 then
  begin
    FHoverRow := -1;
    Invalidate;
  end;
end;

procedure TMaxStringGrid.DrawCell(ACol, ARow: Integer; ARect: TRect;
  AState: TGridDrawState);
var
  FillColor: TColor;
  TextColor: TColor;
  TextRect: TRect;
  TextValue: string;
  IconRect: TRect;
  Kind: TMaxPillKind;
  Save: Integer;
begin
  if ARow = 0 then
  begin
    FillColor := TMaxTheme.Palette.PrimaryDark;
    TextColor := clWhite;
  end
  else if gdSelected in AState then
  begin
    FillColor := FSelectedRowColor;
    TextColor := TMaxTheme.Palette.Text;
  end
  else if FShowRowHover and (ARow = FHoverRow) then
  begin
    FillColor := TMaxPainter.BlendColor(TMaxTheme.Palette.PrimarySoft,
      clWhite, 120);
    TextColor := TMaxTheme.Palette.Text;
  end
  else if FZebraRows and Odd(ARow) then
  begin
    FillColor := TMaxTheme.Palette.SurfaceSoft;
    TextColor := TMaxTheme.Palette.Text;
  end
  else
  begin
    FillColor := TMaxTheme.Palette.Surface;
    TextColor := TMaxTheme.Palette.Text;
  end;

  Canvas.Brush.Color := FillColor;
  Canvas.Pen.Color := TMaxTheme.Palette.Border;
  Canvas.Rectangle(ARect);
  TextValue := Cells[ACol, ARow];

  if (ARow > 0) and (ACol = FStatusColumn) then
  begin
    Kind := StatusKind(TextValue);
    TextRect := ARect;
    InflateRect(TextRect, -MaxScale(6, CurrentPPI), -MaxScale(5, CurrentPPI));
    TMaxPainter.DrawPill(Canvas, TextRect, TextValue, Font, Kind, False, False,
      CurrentPPI);
  end
  else if (ARow > 0) and (ACol = FActionColumn) then
  begin
    IconRect := ARect;
    IconRect.Left := IconRect.Right - MaxScale(48, CurrentPPI);
    IconRect.Right := IconRect.Left + MaxScale(16, CurrentPPI);
    InflateRect(IconRect, -1, -MaxScale(6, CurrentPPI));
    TMaxIconPainter.Draw(Canvas, IconRect, mikEdit,
      TMaxTheme.Palette.TextSecondary, 1);
    OffsetRect(IconRect, MaxScale(24, CurrentPPI), 0);
    TMaxIconPainter.Draw(Canvas, IconRect, mikDelete,
      TMaxTheme.Palette.TextSecondary, 1);
  end
  else
  begin
    TextRect := ARect;
    InflateRect(TextRect, -MaxScale(8, CurrentPPI), 0);
    Save := SaveDC(Canvas.Handle);
    try
      Canvas.Font.Assign(Font);
      Canvas.Font.Color := TextColor;
      if ARow = 0 then Canvas.Font.Style := [fsBold]
      else Canvas.Font.Style := [];
      SetBkMode(Canvas.Handle, TRANSPARENT);
      DrawText(Canvas.Handle, PChar(TextValue), Length(TextValue), TextRect,
        DT_LEFT or DT_VCENTER or DT_SINGLELINE or DT_END_ELLIPSIS);
    finally
      RestoreDC(Canvas.Handle, Save);
    end;
  end;

  if Assigned(OnDrawCell) then
    OnDrawCell(Self, ACol, ARow, ARect, AState);
end;

procedure TMaxStringGrid.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  ColValue: Integer;
  RowValue: Integer;
begin
  inherited;
  if not FShowRowHover then Exit;
  MouseToCell(X, Y, ColValue, RowValue);
  if RowValue = 0 then RowValue := -1;
  if FHoverRow <> RowValue then
  begin
    FHoverRow := RowValue;
    Invalidate;
  end;
end;

procedure TMaxStringGrid.SetActionColumn(const Value: Integer);
begin
  if FActionColumn = Value then Exit;
  FActionColumn := Value;
  Invalidate;
end;

procedure TMaxStringGrid.SetHeaderHeightLogical(const Value: Integer);
begin
  if FHeaderHeightLogical = Value then Exit;
  FHeaderHeightLogical := Max(24, Value);
  UpdateMetrics;
end;

procedure TMaxStringGrid.SetRowHeightLogical(const Value: Integer);
begin
  if FRowHeightLogical = Value then Exit;
  FRowHeightLogical := Max(22, Value);
  UpdateMetrics;
end;

procedure TMaxStringGrid.SetSelectedRowColor(const Value: TColor);
begin
  if FSelectedRowColor = Value then Exit;
  FSelectedRowColor := Value;
  Invalidate;
end;

procedure TMaxStringGrid.SetShowRowHover(const Value: Boolean);
begin
  if FShowRowHover = Value then Exit;
  FShowRowHover := Value;
  if not Value then FHoverRow := -1;
  Invalidate;
end;

procedure TMaxStringGrid.SetStatusColumn(const Value: Integer);
begin
  if FStatusColumn = Value then Exit;
  FStatusColumn := Value;
  Invalidate;
end;

procedure TMaxStringGrid.SetZebraRows(const Value: Boolean);
begin
  if FZebraRows = Value then Exit;
  FZebraRows := Value;
  Invalidate;
end;

procedure TMaxStringGrid.UpdateMetrics;
begin
  DefaultRowHeight := MaxScale(FRowHeightLogical, CurrentPPI);
  if FixedRows > 0 then
    RowHeights[0] := MaxScale(FHeaderHeightLogical, CurrentPPI);
end;

constructor TMaxDBGrid.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FZebraRows := True;
  FSelectedRowColor := TMaxTheme.Palette.PrimarySoft;
  FStatusField := 'STATUS';
  DoubleBuffered := True;
  StyleElements := [seFont];
  Color := TMaxTheme.Palette.Surface;
  Font.Name := 'Inter';
  Font.Size := 9;
  Options := Options + [dgRowSelect] - [dgEditing];
end;

procedure TMaxDBGrid.DrawColumnCell(const Rect: TRect; DataCol: Integer;
  Column: TColumn; State: TGridDrawState);
var
  RecNoValue: Integer;
  TextValue: string;
  R: TRect;
begin
  if gdSelected in State then
    Canvas.Brush.Color := FSelectedRowColor
  else
  begin
    RecNoValue := 0;
    if Assigned(DataSource) and Assigned(DataSource.DataSet) and
      DataSource.DataSet.Active then
      RecNoValue := DataSource.DataSet.RecNo;
    if FZebraRows and Odd(RecNoValue) then
      Canvas.Brush.Color := TMaxTheme.Palette.SurfaceSoft
    else
      Canvas.Brush.Color := TMaxTheme.Palette.Surface;
  end;
  Canvas.Font.Assign(Font);
  Canvas.Font.Color := TMaxTheme.Palette.Text;
  Canvas.FillRect(Rect);

  if SameText(Column.FieldName, FStatusField) and Assigned(Column.Field) then
  begin
    TextValue := Column.Field.AsString;
    R := Rect;
    InflateRect(R, -6, -4);
    TMaxPainter.DrawPill(Canvas, R, TextValue, Font, StatusKind(TextValue),
      False, False, CurrentPPI);
  end
  else
    DefaultDrawColumnCell(Rect, DataCol, Column, State);
end;

procedure TMaxDBGrid.SetSelectedRowColor(const Value: TColor);
begin
  if FSelectedRowColor = Value then Exit;
  FSelectedRowColor := Value;
  Invalidate;
end;

procedure TMaxDBGrid.SetStatusField(const Value: string);
begin
  if FStatusField = Value then Exit;
  FStatusField := Value;
  Invalidate;
end;

procedure TMaxDBGrid.SetZebraRows(const Value: Boolean);
begin
  if FZebraRows = Value then Exit;
  FZebraRows := Value;
  Invalidate;
end;

constructor TMaxStatusBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  DoubleBuffered := True;
  ParentBackground := False;
  StyleElements := [seFont];
  Font.Name := 'Inter';
  Font.Size := 9;
  FConnectionText := 'Conectado';
  FUserText := 'Usuário: admin';
  FRoleText := 'Perfil: Administrador';
  FDateText := FormatDateTime('dd/MM/yyyy', Date);
  FTimeText := FormatDateTime('hh:nn', Time);
  FSecure := True;
  Height := MaxScale(34, CurrentPPI);
  Width := 700;
end;

procedure TMaxStatusBar.Paint;
var
  R: TRect;
  X: Integer;
  SegmentRect: TRect;
  TextValue: string;
  Save: Integer;

  procedure DrawSegment(const S: string; const Flexible: Boolean = False);
  var
    W: Integer;
  begin
    if Flexible then
      W := MaxScale(180, CurrentPPI)
    else
      W := Canvas.TextWidth(S) + MaxScale(28, CurrentPPI);
    SegmentRect := Rect(X, 0, Min(Width, X + W), Height);
    DrawText(Canvas.Handle, PChar(S), Length(S), SegmentRect,
      DT_CENTER or DT_VCENTER or DT_SINGLELINE or DT_END_ELLIPSIS);
    X := SegmentRect.Right;
    if X < Width - 1 then
    begin
      Canvas.Pen.Color := TMaxTheme.Palette.Border;
      Canvas.MoveTo(X, MaxScale(8, CurrentPPI));
      Canvas.LineTo(X, Height - MaxScale(8, CurrentPPI));
    end;
  end;

begin
  R := ClientRect;
  TMaxPainter.DrawSurface(Canvas, R, TMaxTheme.Palette.Surface,
    TMaxTheme.Palette.Border, MaxScale(8, CurrentPPI), 1);
  Save := SaveDC(Canvas.Handle);
  try
    Canvas.Font.Assign(Font);
    Canvas.Font.Color := TMaxTheme.Palette.TextSecondary;
    SetBkMode(Canvas.Handle, TRANSPARENT);
    X := MaxScale(18, CurrentPPI);
    Canvas.Brush.Color := TMaxTheme.Palette.Primary;
    Canvas.Pen.Color := Canvas.Brush.Color;
    Canvas.Ellipse(X, Height div 2 - MaxScale(4, CurrentPPI),
      X + MaxScale(8, CurrentPPI), Height div 2 + MaxScale(4, CurrentPPI));
    Inc(X, MaxScale(14, CurrentPPI));
    DrawSegment(FConnectionText);
    DrawSegment(FUserText);
    DrawSegment(FRoleText, True);
    DrawSegment(FDateText);
    DrawSegment(FTimeText);
    if FSecure then
    begin
      SegmentRect := Rect(X, 0, Width - MaxScale(8, CurrentPPI), Height);
      SegmentRect.Left := Max(SegmentRect.Left, SegmentRect.Right - MaxScale(28, CurrentPPI));
      InflateRect(SegmentRect, -MaxScale(5, CurrentPPI), -MaxScale(8, CurrentPPI));
      TMaxIconPainter.Draw(Canvas, SegmentRect, mikLock,
        TMaxTheme.Palette.TextSecondary, 1);
    end;
  finally
    RestoreDC(Canvas.Handle, Save);
  end;
end;

procedure TMaxStatusBar.SetConnectionText(const Value: string);
begin
  if FConnectionText = Value then Exit;
  FConnectionText := Value;
  Invalidate;
end;

procedure TMaxStatusBar.SetDateText(const Value: string);
begin
  if FDateText = Value then Exit;
  FDateText := Value;
  Invalidate;
end;

procedure TMaxStatusBar.SetRoleText(const Value: string);
begin
  if FRoleText = Value then Exit;
  FRoleText := Value;
  Invalidate;
end;

procedure TMaxStatusBar.SetSecure(const Value: Boolean);
begin
  if FSecure = Value then Exit;
  FSecure := Value;
  Invalidate;
end;

procedure TMaxStatusBar.SetTimeText(const Value: string);
begin
  if FTimeText = Value then Exit;
  FTimeText := Value;
  Invalidate;
end;

procedure TMaxStatusBar.SetUserText(const Value: string);
begin
  if FUserText = Value then Exit;
  FUserText := Value;
  Invalidate;
end;

end.
