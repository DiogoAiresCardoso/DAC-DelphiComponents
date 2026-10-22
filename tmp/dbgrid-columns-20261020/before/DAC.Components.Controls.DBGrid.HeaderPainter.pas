unit DAC.Components.Controls.DBGrid.HeaderPainter;

interface

uses
  System.Classes,
  System.Generics.Collections,
  System.Skia,
  System.Types,
  DAC.Components.Controls.DBGrid.Types,
  DAC.Components.DesignSystem.ControlTokens,
  DAC.Components.Skia.Renderer;

type
  TDACDBGridHeaderPainter = class
  private
    FRenderer: TDACSkiaRenderer;
    procedure DrawCheckBox(const ACanvas: ISkCanvas; const ARect: TRectF;
      const AState: TDACDBGridSelectionState;
      const ATokens: TDACControlTokens);
    procedure DrawSortGlyph(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ADirection: TDACDBGridSortDirection;
      const ATokens: TDACControlTokens);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Draw(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ACaption: string; const AAlignment: TAlignment;
      const AHot, APressed, AIndicator: Boolean;
      const ASelectionState: TDACDBGridSelectionState;
      const ASortDirection: TDACDBGridSortDirection;
      const ATokens: TDACControlTokens;
      const ATextItems: TList<TDACDBGridTextItem>);
  end;

implementation

uses
  System.Math;

constructor TDACDBGridHeaderPainter.Create;
begin
  inherited Create;
  FRenderer := TDACSkiaRenderer.Create;
end;

destructor TDACDBGridHeaderPainter.Destroy;
begin
  FRenderer.Free;
  inherited;
end;

procedure TDACDBGridHeaderPainter.Draw(const ACanvas: ISkCanvas;
  const ARect: TRectF; const ACaption: string;
  const AAlignment: TAlignment; const AHot, APressed, AIndicator: Boolean;
  const ASelectionState: TDACDBGridSelectionState;
  const ASortDirection: TDACDBGridSortDirection;
  const ATokens: TDACControlTokens;
  const ATextItems: TList<TDACDBGridTextItem>);
var
  LItem: TDACDBGridTextItem;
  LTextRight: Single;
begin
  if APressed then
    FRenderer.FillRoundRect(ACanvas, ARect, ATokens.DataGridSelection, 0)
  else if AHot then
    FRenderer.FillRoundRect(ACanvas, ARect, ATokens.DataGridHover, 0);

  FRenderer.DrawLine(ACanvas, PointF(ARect.Right - 0.5, ARect.Top + 8),
    PointF(ARect.Right - 0.5, ARect.Bottom - 8), ATokens.DataGridBorder, 1);
  FRenderer.DrawLine(ACanvas, PointF(ARect.Left, ARect.Bottom - 0.5),
    PointF(ARect.Right, ARect.Bottom - 0.5), ATokens.DataGridBorder, 1);

  if AIndicator then
  begin
    DrawCheckBox(ACanvas, ARect, ASelectionState, ATokens);
    Exit;
  end;

  LTextRight := ARect.Right - 12;
  if ASortDirection <> dgsNone then
  begin
    LTextRight := LTextRight - 16;
    DrawSortGlyph(ACanvas, TRectF.Create(ARect.Right - 24, ARect.Top,
      ARect.Right - 8, ARect.Bottom), ASortDirection, ATokens);
  end;
  LItem.Text := ACaption;
  LItem.Bounds := Rect(Round(ARect.Left + 12), Round(ARect.Top),
    Round(LTextRight), Round(ARect.Bottom));
  LItem.Color := ATokens.DataGridHeaderText;
  LItem.FontSize := DACDBGridDefaultFontSize;
  LItem.Bold := True;
  LItem.Alignment := AAlignment;
  LItem.Ellipsis := True;
  ATextItems.Add(LItem);
end;

procedure TDACDBGridHeaderPainter.DrawCheckBox(const ACanvas: ISkCanvas;
  const ARect: TRectF; const AState: TDACDBGridSelectionState;
  const ATokens: TDACControlTokens);
var
  LBox: TRectF;
  LSize: Single;
begin
  LSize := Min(16, Min(ARect.Width - 8, ARect.Height - 8));
  LBox := TRectF.Create(ARect.CenterPoint.X - (LSize / 2),
    ARect.CenterPoint.Y - (LSize / 2), ARect.CenterPoint.X + (LSize / 2),
    ARect.CenterPoint.Y + (LSize / 2));
  if AState = dgssUnchecked then
    FRenderer.FillRoundRect(ACanvas, LBox, ATokens.DataGridBackground, 3)
  else
    FRenderer.FillRoundRect(ACanvas, LBox, ATokens.DataGridFocus, 3);
  FRenderer.StrokeRoundRect(ACanvas, LBox, ATokens.DataGridBorder, 3, 1);
  case AState of
    dgssMixed:
      FRenderer.DrawLine(ACanvas, PointF(LBox.Left + 4, LBox.CenterPoint.Y),
        PointF(LBox.Right - 4, LBox.CenterPoint.Y),
        ATokens.DataGridHeaderText, 2);
    dgssChecked:
      begin
        FRenderer.DrawLine(ACanvas, PointF(LBox.Left + 3,
          LBox.CenterPoint.Y), PointF(LBox.Left + 7, LBox.Bottom - 4),
          ATokens.DataGridHeaderText, 2);
        FRenderer.DrawLine(ACanvas, PointF(LBox.Left + 7, LBox.Bottom - 4),
          PointF(LBox.Right - 3, LBox.Top + 4),
          ATokens.DataGridHeaderText, 2);
      end;
  end;
end;

procedure TDACDBGridHeaderPainter.DrawSortGlyph(const ACanvas: ISkCanvas;
  const ARect: TRectF; const ADirection: TDACDBGridSortDirection;
  const ATokens: TDACControlTokens);
var
  LCenter: TPointF;
begin
  LCenter := ARect.CenterPoint;
  if ADirection = dgsAscending then
  begin
    FRenderer.DrawLine(ACanvas, PointF(LCenter.X - 4, LCenter.Y + 2),
      PointF(LCenter.X, LCenter.Y - 2), ATokens.DataGridHeaderText, 1.5);
    FRenderer.DrawLine(ACanvas, PointF(LCenter.X, LCenter.Y - 2),
      PointF(LCenter.X + 4, LCenter.Y + 2), ATokens.DataGridHeaderText, 1.5);
  end
  else
  begin
    FRenderer.DrawLine(ACanvas, PointF(LCenter.X - 4, LCenter.Y - 2),
      PointF(LCenter.X, LCenter.Y + 2), ATokens.DataGridHeaderText, 1.5);
    FRenderer.DrawLine(ACanvas, PointF(LCenter.X, LCenter.Y + 2),
      PointF(LCenter.X + 4, LCenter.Y - 2), ATokens.DataGridHeaderText, 1.5);
  end;
end;

end.
