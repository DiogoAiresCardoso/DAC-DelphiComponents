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
    function BackgroundColor(const ARowIndex: Integer;
      const ASelected, AHot, AEnabled, AZebraEnabled: Boolean;
      const ATokens: TDACControlTokens): TAlphaColor;
    procedure DrawCheckBox(const ACanvas: ISkCanvas; const ARect: TRectF;
      const AChecked, AEnabled: Boolean; const ATokens: TDACControlTokens);
  public
    constructor Create;
    destructor Destroy; override;
    procedure DrawRowBackground(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ARowIndex: Integer; const ASelected, AEnabled, AZebraEnabled: Boolean;
      const ATokens: TDACControlTokens; const APPI: Integer);
    procedure DrawRowMarker(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ATokens: TDACControlTokens; const APPI: Integer);
    procedure DrawFocus(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ATokens: TDACControlTokens; const APPI: Integer);
    procedure Draw(const ACanvas: ISkCanvas; const ARect: TRectF;
      const AText: string; const AAlignment: TAlignment;
      const ARowIndex: Integer; const ASelected, AHot, AEnabled,
      AIndicator, AChecked, AFirstColumn, AZebraEnabled: Boolean;
      const ATokens: TDACControlTokens;
      const ATextItems: TList<TDACDBGridTextItem>; const APPI: Integer = 96);
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
  const ATextItems: TList<TDACDBGridTextItem>; const APPI: Integer);
var
  LBackground: TAlphaColor;
  LItem: TDACDBGridTextItem;
  R: TRectF;
  Scale: Single;
begin
  Scale := Max(1, APPI / 96);
  R := TRectF.Create(ARect.Left / Scale, ARect.Top / Scale,
    ARect.Right / Scale, ARect.Bottom / Scale);
  ACanvas.Save;
  ACanvas.Scale(Scale, Scale);
  try
    LBackground := BackgroundColor(ARowIndex, ASelected, AHot, AEnabled,
      AZebraEnabled, ATokens);

    FRenderer.FillRoundRect(ACanvas, R, LBackground, 0);
    FRenderer.DrawLine(ACanvas, PointF(R.Left, R.Bottom - 0.5),
      PointF(R.Right, R.Bottom - 0.5), ATokens.DataGridBorder, 1);
    if AFirstColumn and ASelected then
      FRenderer.FillRoundRect(ACanvas, TRectF.Create(R.Left,
        R.Top, R.Left + 4, R.Bottom), ATokens.DataGridFocus, 0);

    if AHot and ASelected and AEnabled then
      FRenderer.StrokeRoundRect(ACanvas, TRectF.Create(R.Left + 1, R.Top + 1,
        R.Right - 1, R.Bottom - 1), ATokens.DataGridHoverBorder, 0, 1);

    if AIndicator then
    begin
      DrawCheckBox(ACanvas, R, AChecked, AEnabled, ATokens);
      Exit;
    end;

    LItem.Text := AText;
    LItem.Bounds := Rect(Round((R.Left + 12) * Scale), Round(R.Top * Scale),
      Round((R.Right - 12) * Scale), Round(R.Bottom * Scale));
    if AEnabled then
      LItem.Color := ATokens.DataGridText
    else
      LItem.Color := ATokens.DataGridDisabledText;
    LItem.FontSize := DACDBGridDefaultFontSize;
    LItem.Bold := False;
    LItem.Alignment := AAlignment;
    LItem.Ellipsis := True;
    ATextItems.Add(LItem);
  finally ACanvas.Restore; end;
end;

function TDACDBGridCellPainter.BackgroundColor(const ARowIndex: Integer;
  const ASelected, AHot, AEnabled, AZebraEnabled: Boolean;
  const ATokens: TDACControlTokens): TAlphaColor;
begin
  Result := ATokens.DataGridBackground;
  if not AEnabled then Result := ATokens.DataGridEmpty
  else if ASelected then Result := ATokens.DataGridSelection
  else if AHot then Result := ATokens.DataGridHover
  else if AZebraEnabled and Odd(ARowIndex) then Result := ATokens.DataGridRowAlternate;
end;

procedure TDACDBGridCellPainter.DrawRowBackground(const ACanvas: ISkCanvas;
  const ARect: TRectF; const ARowIndex: Integer;
  const ASelected, AEnabled, AZebraEnabled: Boolean;
  const ATokens: TDACControlTokens; const APPI: Integer);
var R: TRectF; Scale: Single;
begin
  Scale := Max(1, APPI / 96);
  R := TRectF.Create(ARect.Left / Scale, ARect.Top / Scale,
    ARect.Right / Scale, ARect.Bottom / Scale);
  ACanvas.Save;
  ACanvas.Scale(Scale, Scale);
  try
    FRenderer.FillRoundRect(ACanvas, R, BackgroundColor(ARowIndex, ASelected,
      False, AEnabled, AZebraEnabled, ATokens), 0);
    FRenderer.DrawLine(ACanvas, PointF(R.Left, R.Bottom - 0.5),
      PointF(R.Right, R.Bottom - 0.5), ATokens.DataGridBorder, 1);
  finally ACanvas.Restore; end;
end;

procedure TDACDBGridCellPainter.DrawRowMarker(const ACanvas: ISkCanvas;
  const ARect: TRectF; const ATokens: TDACControlTokens; const APPI: Integer);
begin
  FRenderer.FillRoundRect(ACanvas, TRectF.Create(ARect.Left, ARect.Top,
    ARect.Left + 4 * Max(1, APPI / 96), ARect.Bottom), ATokens.DataGridFocus, 0);
end;

procedure TDACDBGridCellPainter.DrawFocus(const ACanvas: ISkCanvas;
  const ARect: TRectF; const ATokens: TDACControlTokens; const APPI: Integer);
var Inset: Single;
begin
  Inset := Max(1, APPI / 96);
  FRenderer.StrokeRoundRect(ACanvas, TRectF.Create(ARect.Left + Inset * 1.5,
    ARect.Top + Inset * 1.5, ARect.Right - Inset * 1.5, ARect.Bottom - Inset * 1.5),
    ATokens.DataGridFocus, 0, Inset);
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
