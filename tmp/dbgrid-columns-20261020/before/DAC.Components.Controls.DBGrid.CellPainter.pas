unit DAC.Components.Controls.DBGrid.CellPainter;

interface

uses
  System.Classes,
  System.Generics.Collections,
  System.Skia,
  System.Types,
  System.UITypes,
  DAC.Components.Controls.DBGrid.Types,
  DAC.Components.DesignSystem.ControlTokens,
  DAC.Components.Skia.Renderer;

type
  TDACDBGridCellPainter = class
  private
    FRenderer: TDACSkiaRenderer;
    procedure DrawCheckBox(const ACanvas: ISkCanvas; const ARect: TRectF;
      const AChecked, AEnabled: Boolean; const ATokens: TDACControlTokens);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Draw(const ACanvas: ISkCanvas; const ARect: TRectF;
      const AText: string; const AAlignment: TAlignment;
      const ARowIndex: Integer; const ASelected, AHot, AEnabled,
      AIndicator, AChecked, AFirstColumn, AZebraEnabled: Boolean;
      const ATokens: TDACControlTokens;
      const ATextItems: TList<TDACDBGridTextItem>);
  end;

implementation

uses
  System.Math;

constructor TDACDBGridCellPainter.Create;
begin
  inherited Create;
  FRenderer := TDACSkiaRenderer.Create;
end;

destructor TDACDBGridCellPainter.Destroy;
begin
  FRenderer.Free;
  inherited;
end;

procedure TDACDBGridCellPainter.Draw(const ACanvas: ISkCanvas;
  const ARect: TRectF; const AText: string; const AAlignment: TAlignment;
  const ARowIndex: Integer; const ASelected, AHot, AEnabled,
  AIndicator, AChecked, AFirstColumn, AZebraEnabled: Boolean;
  const ATokens: TDACControlTokens;
  const ATextItems: TList<TDACDBGridTextItem>);
var
  LBackground: TAlphaColor;
  LItem: TDACDBGridTextItem;
begin
  LBackground := ATokens.DataGridBackground;
  if not AEnabled then
    LBackground := ATokens.DataGridEmpty
  else if ASelected then
    LBackground := ATokens.DataGridSelection
  else if AHot then
    LBackground := ATokens.DataGridHover
  else if AZebraEnabled and Odd(ARowIndex) then
    LBackground := ATokens.DataGridRowAlternate;

  FRenderer.FillRoundRect(ACanvas, ARect, LBackground, 0);
  FRenderer.DrawLine(ACanvas, PointF(ARect.Left, ARect.Bottom - 0.5),
    PointF(ARect.Right, ARect.Bottom - 0.5), ATokens.DataGridBorder, 1);
  if AFirstColumn and ASelected then
    FRenderer.FillRoundRect(ACanvas, TRectF.Create(ARect.Left,
      ARect.Top, ARect.Left + 4, ARect.Bottom), ATokens.DataGridFocus, 0);

  if AIndicator then
  begin
    DrawCheckBox(ACanvas, ARect, AChecked, AEnabled, ATokens);
    Exit;
  end;

  LItem.Text := AText;
  LItem.Bounds := Rect(Round(ARect.Left + 12), Round(ARect.Top),
    Round(ARect.Right - 12), Round(ARect.Bottom));
  if AEnabled then
    LItem.Color := ATokens.DataGridText
  else
    LItem.Color := ATokens.DataGridDisabledText;
  LItem.FontSize := DACDBGridDefaultFontSize;
  LItem.Bold := False;
  LItem.Alignment := AAlignment;
  LItem.Ellipsis := True;
  ATextItems.Add(LItem);
end;

procedure TDACDBGridCellPainter.DrawCheckBox(const ACanvas: ISkCanvas;
  const ARect: TRectF; const AChecked, AEnabled: Boolean;
  const ATokens: TDACControlTokens);
var
  LBox: TRectF;
  LSize: Single;
begin
  LSize := Min(16, Min(ARect.Width - 8, ARect.Height - 8));
  LBox := TRectF.Create(ARect.CenterPoint.X - (LSize / 2),
    ARect.CenterPoint.Y - (LSize / 2), ARect.CenterPoint.X + (LSize / 2),
    ARect.CenterPoint.Y + (LSize / 2));
  if AChecked and AEnabled then
    FRenderer.FillRoundRect(ACanvas, LBox, ATokens.DataGridFocus, 3)
  else
    FRenderer.FillRoundRect(ACanvas, LBox, ATokens.DataGridBackground, 3);
  FRenderer.StrokeRoundRect(ACanvas, LBox, ATokens.DataGridBorder, 3, 1);
  if AChecked then
  begin
    FRenderer.DrawLine(ACanvas, PointF(LBox.Left + 3, LBox.CenterPoint.Y),
      PointF(LBox.Left + 7, LBox.Bottom - 4), ATokens.DataGridHeaderText, 2);
    FRenderer.DrawLine(ACanvas, PointF(LBox.Left + 7, LBox.Bottom - 4),
      PointF(LBox.Right - 3, LBox.Top + 4), ATokens.DataGridHeaderText, 2);
  end;
end;

end.
