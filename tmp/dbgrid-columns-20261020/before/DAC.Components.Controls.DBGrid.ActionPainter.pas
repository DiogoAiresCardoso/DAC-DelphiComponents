unit DAC.Components.Controls.DBGrid.ActionPainter;

interface

uses
  System.Classes, System.Types, System.Generics.Collections, System.Skia,
  DAC.Components.Controls.DBGrid.Action,
  DAC.Components.Controls.DBGrid.ActionTypes,
  DAC.Components.Controls.DBGrid.Types,
  DAC.Components.DesignSystem.ControlTokens,
  DAC.Components.Skia.Renderer,
  DAC.Components.Skia.IconPainter;

type
  TDACDBGridActionPainter = class
  private
    FRenderer: TDACSkiaRenderer;
    FIcons: TDACSkiaIconPainter;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Draw(const ACanvas: ISkCanvas; const AView: TDACDBGridActionView;
      AAction: TDACDBGridAction; const AHot, APressed, AFocused: Boolean;
      const APPI: Integer; const ATokens: TDACControlTokens;
      ATextItems: TList<TDACDBGridTextItem>);
  end;

implementation

uses
  System.Math, System.UITypes, Winapi.Windows,
  DAC.Components.DesignSystem.IconAssets;

constructor TDACDBGridActionPainter.Create;
begin
  inherited;
  FRenderer := TDACSkiaRenderer.Create;
  FIcons := TDACSkiaIconPainter.Create(FRenderer);
end;

destructor TDACDBGridActionPainter.Destroy;
begin
  FIcons.Free;
  FRenderer.Free;
  inherited;
end;

procedure TDACDBGridActionPainter.Draw(const ACanvas: ISkCanvas;
  const AView: TDACDBGridActionView; AAction: TDACDBGridAction;
  const AHot, APressed, AFocused: Boolean; const APPI: Integer;
  const ATokens: TDACControlTokens; ATextItems: TList<TDACDBGridTextItem>);
var
  R, IconRect: TRectF;
  Item: TDACDBGridTextItem;
  Style: TDACIconStyle;
  Background, Border, Text: TAlphaColor;
  Scale, Inset, Size, Radius: Single;
begin
  Scale := APPI / 96;
  R := TRectF.Create(AView.Bounds);
  Radius := ATokens.DataGridActionRadius * Scale;
  Background := ATokens.ButtonSecondaryBackground;
  Border := ATokens.ButtonSecondaryBorder;
  Text := ATokens.ButtonSecondaryText;
  if AHot then Background := ATokens.ButtonSecondaryHoverBackground;
  if APressed then Background := ATokens.ButtonSecondaryPressedBackground;
  if AAction.Appearance = daaDanger then
  begin
    Background := ATokens.DataGridActionBackground;
    Border := ATokens.DataGridActionDangerText;
    Text := Border;
    if AHot or APressed then
    begin
      Background := ATokens.ButtonDangerBackground;
      Text := ATokens.ButtonDangerText;
    end;
    if APressed then Border := ATokens.DataGridFocus;
  end;
  if not AView.Enabled then
  begin
    Background := ATokens.ButtonDisabledBackground;
    Border := ATokens.ButtonDisabledBorder;
    Text := ATokens.ButtonDisabledText;
  end;
  FRenderer.FillRoundRect(ACanvas, R, Background, Radius);
  FRenderer.StrokeRoundRect(ACanvas, R, Border, Radius,
    ATokens.DataGridActionBorderWidth * Scale);
  if AFocused then
    FRenderer.StrokeRoundRect(ACanvas, R, ATokens.DataGridFocus, Radius,
      ATokens.FocusRingWidth * Scale);
  Inset := ATokens.DataGridActionInset * Scale;
  Item := Default(TDACDBGridTextItem);
  Item.Bounds := Rect(Round(R.Left + Inset), Round(R.Top),
    Round(R.Right - Inset), Round(R.Bottom));
  if AAction.IconKind <> mikNone then
  begin
    Size := Min(ATokens.DataGridActionSize * Scale, R.Height - 2 * Scale);
    Size := Min(Size, R.Width - 2 * Inset);
    if AAction.Caption = '' then
      IconRect := TRectF.Create(R.CenterPoint.X - Size / 2,
        R.CenterPoint.Y - Size / 2, R.CenterPoint.X + Size / 2,
        R.CenterPoint.Y + Size / 2)
    else
    begin
      IconRect := TRectF.Create(R.Left + Inset, R.CenterPoint.Y - Size / 2,
        R.Left + Inset + Size, R.CenterPoint.Y + Size / 2);
      Item.Bounds.Left := Round(IconRect.Right + Inset);
    end;
    Style.Color := Text;
    Style.Alpha := 255;
    FIcons.Draw(ACanvas, IconRect, AAction.IconKind, Style);
  end;
  Item.Text := AAction.Caption;
  Item.Color := Text;
  Item.FontSize := DACDBGridDefaultFontSize;
  Item.Alignment := taCenter;
  Item.Ellipsis := True;
  if Item.Bounds.Right > Item.Bounds.Left then ATextItems.Add(Item);
end;

end.
