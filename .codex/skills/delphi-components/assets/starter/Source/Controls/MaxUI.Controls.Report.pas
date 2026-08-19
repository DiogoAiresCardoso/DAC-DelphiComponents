unit MaxUI.Controls.Report;

{$CODEPAGE 65001}

interface

uses
  System.Classes,
  Vcl.Controls,
  MaxUI.Controls.Base;

type
  TMaxReportViewer = class(TMaxSurface)
  private
    FReportTitle: string;
    FPeriodText: string;
    FPageIndex: Integer;
    FPageCount: Integer;
    FZoom: Integer;
    FItems: TStringList;
    FCompanyName: string;
    FTotalText: string;
    procedure SetReportTitle(const Value: string);
    procedure SetPeriodText(const Value: string);
    procedure SetPageIndex(const Value: Integer);
    procedure SetPageCount(const Value: Integer);
    procedure SetZoom(const Value: Integer);
    procedure SetItems(const Value: TStrings);
    procedure SetCompanyName(const Value: string);
    procedure SetTotalText(const Value: string);
    procedure ItemsChanged(Sender: TObject);
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property ReportTitle: string read FReportTitle write SetReportTitle;
    property PeriodText: string read FPeriodText write SetPeriodText;
    property PageIndex: Integer read FPageIndex write SetPageIndex default 1;
    property PageCount: Integer read FPageCount write SetPageCount default 5;
    property Zoom: Integer read FZoom write SetZoom default 100;
    property Items: TStrings read FItems write SetItems;
    property CompanyName: string read FCompanyName write SetCompanyName;
    property TotalText: string read FTotalText write SetTotalText;
  end;

implementation

uses
  System.Math,
  System.SysUtils,
  System.Types,
  Winapi.Windows,
  Vcl.Graphics,
  MaxUI.Dpi,
  MaxUI.Icons,
  MaxUI.Painter,
  MaxUI.Theme;

constructor TMaxReportViewer.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FReportTitle := 'Relatório de Vendas';
  FPeriodText := 'Período: 01/05/2025 a 24/05/2025';
  FPageIndex := 1;
  FPageCount := 5;
  FZoom := 100;
  FCompanyName := 'Sua Empresa';
  FTotalText := 'Total Geral: R$ 80.500,00';
  SurfaceColor := TMaxTheme.Palette.SurfaceSoft;
  Width := 720;
  Height := 360;
  FItems := TStringList.Create;
  FItems.OnChange := ItemsChanged;
  FItems.Add('Notebook Dell i5|Informática|15|3.250,00|48.750,00');
  FItems.Add('Monitor 24|Informática|28|650,00|18.200,00');
  FItems.Add('Teclado Mecânico|Acessórios|35|250,00|8.750,00');
  FItems.Add('Mouse Óptico|Acessórios|40|120,00|4.800,00');
end;

destructor TMaxReportViewer.Destroy;
begin
  FItems.Free;
  inherited;
end;

procedure TMaxReportViewer.ItemsChanged(Sender: TObject);
begin
  Invalidate;
end;

procedure TMaxReportViewer.Paint;
var
  PageRect: TRect;
  HeaderRect: TRect;
  TitleRect: TRect;
  TableRect: TRect;
  RowRect: TRect;
  Cols: TStringList;
  ColWidths: array[0..4] of Integer;
  I: Integer;
  C: Integer;
  X: Integer;
  RowHeight: Integer;
  HeaderHeight: Integer;
  S: string;
  Save: Integer;
  IconRect: TRect;
  PageInfoRect: TRect;
  ScaleValue: Double;
  PageWidth: Integer;
  PageHeight: Integer;

  procedure DrawCellText(const TextValue: string; const CellRect: TRect;
    const Bold: Boolean; const AlignFlags: Cardinal);
  var
    R: TRect;
  begin
    R := CellRect;
    InflateRect(R, -MaxScale(6, CurrentPPI), 0);
    Canvas.Font.Assign(Font);
    Canvas.Font.Size := Max(7, Round(8 * ScaleValue));
    if Bold then Canvas.Font.Style := [fsBold]
    else Canvas.Font.Style := [];
    Canvas.Font.Color := TMaxTheme.Palette.Text;
    DrawText(Canvas.Handle, PChar(TextValue), Length(TextValue), R,
      DT_VCENTER or DT_SINGLELINE or DT_END_ELLIPSIS or AlignFlags);
  end;

begin
  inherited;
  ScaleValue := EnsureRange(FZoom, 25, 400) / 100;
  PageWidth := Min(Width - MaxScale(36, CurrentPPI),
    Round(MaxScale(650, CurrentPPI) * Min(ScaleValue, 1.25)));
  PageHeight := Min(Height - MaxScale(52, CurrentPPI),
    Round(MaxScale(310, CurrentPPI) * Min(ScaleValue, 1.25)));
  PageRect := Rect((Width - PageWidth) div 2, MaxScale(34, CurrentPPI),
    (Width + PageWidth) div 2, MaxScale(34, CurrentPPI) + PageHeight);

  TMaxPainter.DrawSurface(Canvas, PageRect, clWhite,
    TMaxTheme.Palette.Border, MaxScale(3, CurrentPPI), 1);

  PageInfoRect := Rect(MaxScale(12, CurrentPPI), MaxScale(4, CurrentPPI),
    Width - MaxScale(12, CurrentPPI), MaxScale(30, CurrentPPI));
  Save := SaveDC(Canvas.Handle);
  try
    Canvas.Font.Assign(Font);
    Canvas.Font.Size := 8;
    Canvas.Font.Color := TMaxTheme.Palette.TextSecondary;
    SetBkMode(Canvas.Handle, TRANSPARENT);
    S := Format('Página %d de %d   •   Zoom %d%%',
      [FPageIndex, FPageCount, FZoom]);
    DrawText(Canvas.Handle, PChar(S), Length(S), PageInfoRect,
      DT_RIGHT or DT_VCENTER or DT_SINGLELINE);
  finally
    RestoreDC(Canvas.Handle, Save);
  end;

  HeaderHeight := MaxScale(74, CurrentPPI);
  HeaderRect := PageRect;
  InflateRect(HeaderRect, -MaxScale(22, CurrentPPI), 0);
  HeaderRect.Top := PageRect.Top + MaxScale(16, CurrentPPI);
  HeaderRect.Bottom := HeaderRect.Top + HeaderHeight;
  IconRect := Rect(HeaderRect.Right - MaxScale(150, CurrentPPI),
    HeaderRect.Top, HeaderRect.Right - MaxScale(116, CurrentPPI),
    HeaderRect.Top + MaxScale(34, CurrentPPI));
  TMaxIconPainter.Draw(Canvas, IconRect, mikLeaf,
    TMaxTheme.Palette.Primary, 2);

  Save := SaveDC(Canvas.Handle);
  try
    SetBkMode(Canvas.Handle, TRANSPARENT);
    TitleRect := HeaderRect;
    TitleRect.Right := HeaderRect.Right - MaxScale(160, CurrentPPI);
    TitleRect.Bottom := HeaderRect.Top + MaxScale(32, CurrentPPI);
    Canvas.Font.Assign(Font);
    Canvas.Font.Size := Max(11, Round(15 * Min(ScaleValue, 1.2)));
    Canvas.Font.Style := [fsBold];
    Canvas.Font.Color := TMaxTheme.Palette.Text;
    DrawText(Canvas.Handle, PChar(FReportTitle), Length(FReportTitle), TitleRect,
      DT_LEFT or DT_VCENTER or DT_SINGLELINE or DT_END_ELLIPSIS);
    TitleRect.Top := TitleRect.Bottom;
    TitleRect.Bottom := TitleRect.Top + MaxScale(22, CurrentPPI);
    Canvas.Font.Size := 8;
    Canvas.Font.Style := [];
    Canvas.Font.Color := TMaxTheme.Palette.Info;
    DrawText(Canvas.Handle, PChar(FPeriodText), Length(FPeriodText), TitleRect,
      DT_LEFT or DT_TOP or DT_SINGLELINE or DT_END_ELLIPSIS);
    TitleRect := Rect(IconRect.Right + MaxScale(6, CurrentPPI), HeaderRect.Top,
      HeaderRect.Right, HeaderRect.Top + MaxScale(34, CurrentPPI));
    Canvas.Font.Color := TMaxTheme.Palette.Text;
    Canvas.Font.Style := [fsBold];
    DrawText(Canvas.Handle, PChar(FCompanyName), Length(FCompanyName), TitleRect,
      DT_LEFT or DT_VCENTER or DT_SINGLELINE or DT_END_ELLIPSIS);
  finally
    RestoreDC(Canvas.Handle, Save);
  end;

  TableRect := PageRect;
  InflateRect(TableRect, -MaxScale(22, CurrentPPI), 0);
  TableRect.Top := HeaderRect.Bottom;
  TableRect.Bottom := PageRect.Bottom - MaxScale(38, CurrentPPI);
  RowHeight := Max(18, TableRect.Height div Max(2, FItems.Count + 1));
  RowHeight := Min(RowHeight, MaxScale(28, CurrentPPI));
  ColWidths[0] := Round(TableRect.Width * 0.30);
  ColWidths[1] := Round(TableRect.Width * 0.22);
  ColWidths[2] := Round(TableRect.Width * 0.14);
  ColWidths[3] := Round(TableRect.Width * 0.16);
  ColWidths[4] := TableRect.Width - ColWidths[0] - ColWidths[1] -
    ColWidths[2] - ColWidths[3];

  Canvas.Brush.Color := TMaxTheme.Palette.DisabledSurface;
  Canvas.Pen.Color := TMaxTheme.Palette.Border;
  RowRect := Rect(TableRect.Left, TableRect.Top, TableRect.Right,
    TableRect.Top + RowHeight);
  Canvas.Rectangle(RowRect);
  Save := SaveDC(Canvas.Handle);
  try
    SetBkMode(Canvas.Handle, TRANSPARENT);
    X := TableRect.Left;
    S := 'Produto';
    DrawCellText(S, Rect(X, RowRect.Top, X + ColWidths[0], RowRect.Bottom), True, DT_LEFT);
    Inc(X, ColWidths[0]);
    DrawCellText('Categoria', Rect(X, RowRect.Top, X + ColWidths[1], RowRect.Bottom), True, DT_LEFT);
    Inc(X, ColWidths[1]);
    DrawCellText('Quantidade', Rect(X, RowRect.Top, X + ColWidths[2], RowRect.Bottom), True, DT_CENTER);
    Inc(X, ColWidths[2]);
    DrawCellText('Valor Unitário', Rect(X, RowRect.Top, X + ColWidths[3], RowRect.Bottom), True, DT_RIGHT);
    Inc(X, ColWidths[3]);
    DrawCellText('Valor Total', Rect(X, RowRect.Top, X + ColWidths[4], RowRect.Bottom), True, DT_RIGHT);

    Cols := TStringList.Create;
    try
      Cols.StrictDelimiter := True;
      Cols.Delimiter := '|';
      for I := 0 to FItems.Count - 1 do
      begin
        RowRect.Top := TableRect.Top + RowHeight * (I + 1);
        RowRect.Bottom := RowRect.Top + RowHeight;
        if RowRect.Bottom > TableRect.Bottom then Break;
        if Odd(I) then Canvas.Brush.Color := TMaxTheme.Palette.SurfaceSoft
        else Canvas.Brush.Color := clWhite;
        Canvas.Pen.Color := TMaxTheme.Palette.Border;
        Canvas.Rectangle(RowRect);
        Cols.DelimitedText := FItems[I];
        X := TableRect.Left;
        for C := 0 to 4 do
        begin
          if C < Cols.Count then S := Cols[C] else S := '';
          if C = 0 then
            DrawCellText(S, Rect(X, RowRect.Top, X + ColWidths[C], RowRect.Bottom), False, DT_LEFT)
          else if C = 1 then
            DrawCellText(S, Rect(X, RowRect.Top, X + ColWidths[C], RowRect.Bottom), False, DT_LEFT)
          else if C = 2 then
            DrawCellText(S, Rect(X, RowRect.Top, X + ColWidths[C], RowRect.Bottom), False, DT_CENTER)
          else
            DrawCellText(S, Rect(X, RowRect.Top, X + ColWidths[C], RowRect.Bottom), False, DT_RIGHT);
          Inc(X, ColWidths[C]);
        end;
      end;
    finally
      Cols.Free;
    end;

    RowRect := Rect(TableRect.Left, PageRect.Bottom - MaxScale(32, CurrentPPI),
      TableRect.Right, PageRect.Bottom - MaxScale(12, CurrentPPI));
    Canvas.Brush.Color := TMaxTheme.Palette.DisabledSurface;
    Canvas.Pen.Color := TMaxTheme.Palette.Border;
    Canvas.Rectangle(RowRect);
    DrawCellText(Format('Total de itens: %d', [FItems.Count]),
      Rect(RowRect.Left, RowRect.Top, (RowRect.Left + RowRect.Right) div 2,
      RowRect.Bottom), True, DT_LEFT);
    DrawCellText(FTotalText,
      Rect((RowRect.Left + RowRect.Right) div 2, RowRect.Top, RowRect.Right,
      RowRect.Bottom), True, DT_RIGHT);
  finally
    RestoreDC(Canvas.Handle, Save);
  end;
end;

procedure TMaxReportViewer.SetCompanyName(const Value: string);
begin
  if FCompanyName = Value then Exit;
  FCompanyName := Value;
  Invalidate;
end;

procedure TMaxReportViewer.SetItems(const Value: TStrings);
begin
  FItems.Assign(Value);
end;

procedure TMaxReportViewer.SetPageCount(const Value: Integer);
begin
  FPageCount := Max(1, Value);
  if FPageIndex > FPageCount then FPageIndex := FPageCount;
  Invalidate;
end;

procedure TMaxReportViewer.SetPageIndex(const Value: Integer);
begin
  FPageIndex := EnsureRange(Value, 1, Max(1, FPageCount));
  Invalidate;
end;

procedure TMaxReportViewer.SetPeriodText(const Value: string);
begin
  if FPeriodText = Value then Exit;
  FPeriodText := Value;
  Invalidate;
end;

procedure TMaxReportViewer.SetReportTitle(const Value: string);
begin
  if FReportTitle = Value then Exit;
  FReportTitle := Value;
  Invalidate;
end;

procedure TMaxReportViewer.SetTotalText(const Value: string);
begin
  if FTotalText = Value then Exit;
  FTotalText := Value;
  Invalidate;
end;

procedure TMaxReportViewer.SetZoom(const Value: Integer);
begin
  FZoom := EnsureRange(Value, 25, 400);
  Invalidate;
end;

end.
