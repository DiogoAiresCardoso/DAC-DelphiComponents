unit DAC.Components.Controls.DBGrid.FramePainter;

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
  TDACDBGridFramePainter = class
  private
    FRenderer: TDACSkiaRenderer;
  public
    constructor Create;
    destructor Destroy; override;
    procedure DrawBackground(const ACanvas: ISkCanvas; const ABounds: TRectF;
      const AHeaderHeight, ARadius: Single; const ATokens: TDACControlTokens;
      const AParentSurface: TAlphaColor);
    procedure DrawBorder(const ACanvas: ISkCanvas; const ABounds: TRectF;
      const ARadius: Single; const ATokens: TDACControlTokens);
    procedure DrawState(const ACanvas: ISkCanvas; const ABounds: TRectF;
      const AHeaderHeight: Single; const ALoading: Boolean;
      const AEmptyText: string; const ATokens: TDACControlTokens;
      const ATextItems: TList<TDACDBGridTextItem>);
  end;

implementation

uses
  System.Math;

constructor TDACDBGridFramePainter.Create;
begin
  inherited Create;
  FRenderer := TDACSkiaRenderer.Create;
end;

destructor TDACDBGridFramePainter.Destroy;
begin
  FRenderer.Free;
  inherited;
end;

procedure TDACDBGridFramePainter.DrawBackground(const ACanvas: ISkCanvas;
  const ABounds: TRectF; const AHeaderHeight, ARadius: Single;
  const ATokens: TDACControlTokens; const AParentSurface: TAlphaColor);
var
  LHeaderRect: TRectF;
begin
  ACanvas.Clear(AParentSurface);
  FRenderer.FillRoundRect(ACanvas, ABounds, ATokens.DataGridBackground,
    ARadius);
  LHeaderRect := TRectF.Create(ABounds.Left, ABounds.Top, ABounds.Right,
    Min(ABounds.Bottom, ABounds.Top + AHeaderHeight + ARadius));
  FRenderer.FillRoundRect(ACanvas, LHeaderRect, ATokens.DataGridHeader,
    ARadius);
  if LHeaderRect.Bottom > ABounds.Top + ARadius then
    FRenderer.FillRoundRect(ACanvas, TRectF.Create(ABounds.Left,
      ABounds.Top + ARadius, ABounds.Right,
      Min(ABounds.Bottom, ABounds.Top + AHeaderHeight)),
      ATokens.DataGridHeader, 0);
end;

procedure TDACDBGridFramePainter.DrawBorder(const ACanvas: ISkCanvas;
  const ABounds: TRectF; const ARadius: Single;
  const ATokens: TDACControlTokens);
var
  LRect: TRectF;
  LWidth: Single;
begin
  LWidth := ATokens.DataGridBorderWidth;
  LRect := FRenderer.SnapRect(ABounds, 1);
  LRect.Inflate(-(LWidth / 2), -(LWidth / 2));
  FRenderer.StrokeRoundRect(ACanvas, LRect, ATokens.DataGridBorder,
    ARadius, LWidth);
end;

procedure TDACDBGridFramePainter.DrawState(const ACanvas: ISkCanvas;
  const ABounds: TRectF; const AHeaderHeight: Single;
  const ALoading: Boolean; const AEmptyText: string;
  const ATokens: TDACControlTokens;
  const ATextItems: TList<TDACDBGridTextItem>);
var
  LItem: TDACDBGridTextItem;
  LRect: TRectF;
begin
  LRect := TRectF.Create(ABounds.Left + 1, ABounds.Top + AHeaderHeight,
    ABounds.Right - 1, ABounds.Bottom - 1);
  if ALoading then
    FRenderer.FillRoundRect(ACanvas, LRect, ATokens.DataGridLoading, 0)
  else
    FRenderer.FillRoundRect(ACanvas, LRect, ATokens.DataGridEmpty, 0);
  LItem.Text := AEmptyText;
  if ALoading then
    LItem.Text := 'Carregando...';
  LItem.Bounds := Rect(Round(LRect.Left + 16), Round(LRect.Top),
    Round(LRect.Right - 16), Round(LRect.Bottom));
  LItem.Color := ATokens.DataGridSecondaryText;
  LItem.FontSize := DACDBGridDefaultFontSize;
  LItem.Bold := False;
  LItem.Alignment := taCenter;
  LItem.Ellipsis := True;
  ATextItems.Add(LItem);
end;

end.
