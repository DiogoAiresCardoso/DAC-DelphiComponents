unit DAC.Components.Skia.BorderPainter;

interface

uses
  System.Skia,
  System.Types,
  System.UITypes,
  DAC.Components.DesignSystem.Theme,
  DAC.Components.Skia.Renderer;

type
  TDACBorderKind = (
    mbkPanel,
    mbkCard,
    mbkControl,
    mbkFocused,
    mbkDanger,
    mbkWarning
  );

  TDACBorderStyle = record
    Color: TAlphaColor;
    Radius: Single;
    Width: Single;
    Alpha: Byte;
    class function FromTheme(const ATheme: IDACComponentsTheme;
      const AKind: TDACBorderKind): TDACBorderStyle; static;
  end;

  TDACSkiaBorderPainter = class
  private
    FRenderer: TDACSkiaRenderer;
    function InsetRect(const ARect: TRectF; const AInset: Single): TRectF;
  public
    constructor Create(const ARenderer: TDACSkiaRenderer);
    procedure Draw(const ACanvas: ISkCanvas; const ARect: TRectF;
      const AStyle: TDACBorderStyle); overload;
    procedure Draw(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ATheme: IDACComponentsTheme;
      const AKind: TDACBorderKind); overload;
    procedure DrawPanelBorder(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ATheme: IDACComponentsTheme);
    procedure DrawCardBorder(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ATheme: IDACComponentsTheme);
    procedure DrawControlBorder(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ATheme: IDACComponentsTheme);
    procedure DrawFocusBorder(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ATheme: IDACComponentsTheme);
    procedure DrawDangerBorder(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ATheme: IDACComponentsTheme);
    procedure DrawWarningBorder(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ATheme: IDACComponentsTheme);
    property Renderer: TDACSkiaRenderer read FRenderer;
  end;

implementation

uses
  DAC.Components.DesignSystem.DefaultTheme;

function ResolveTheme(const ATheme: IDACComponentsTheme): IDACComponentsTheme;
begin
  if ATheme = nil then
    Result := TDACDefaultComponentsTheme.New
  else
    Result := ATheme;
end;

class function TDACBorderStyle.FromTheme(
  const ATheme: IDACComponentsTheme;
  const AKind: TDACBorderKind): TDACBorderStyle;
var
  LTheme: IDACComponentsTheme;
begin
  LTheme := ResolveTheme(ATheme);
  Result.Color := LTheme.Tokens.Colors.Border;
  Result.Radius := LTheme.Tokens.Radius.R8;
  Result.Width := LTheme.Metrics.BorderWidth;
  Result.Alpha := LTheme.Tokens.Opacities.Border;

  case AKind of
    mbkPanel:
      Result.Radius := LTheme.Tokens.Radius.R10;
    mbkCard:
      begin
        Result.Color := LTheme.Tokens.Colors.Border;
        Result.Radius := LTheme.Tokens.Radius.R10;
        Result.Width := LTheme.Tokens.Radius.CardBorderWidth;
        Result.Alpha := LTheme.Tokens.Card.BorderDefaultOpacity;
      end;
    mbkFocused:
      begin
        Result.Color := LTheme.Tokens.Colors.PrimaryLight;
        Result.Width := LTheme.Metrics.FocusStrokeWidth;
        Result.Alpha := 255;
      end;
    mbkDanger:
      begin
        Result.Color := LTheme.Tokens.Colors.Danger;
        Result.Alpha := 255;
      end;
    mbkWarning:
      begin
        Result.Color := LTheme.Tokens.Colors.Warning;
        Result.Alpha := 255;
      end;
  end;
end;

constructor TDACSkiaBorderPainter.Create(
  const ARenderer: TDACSkiaRenderer);
begin
  inherited Create;
  FRenderer := ARenderer;
end;

function TDACSkiaBorderPainter.InsetRect(const ARect: TRectF;
  const AInset: Single): TRectF;
begin
  Result := TRectF.Create(ARect.Left + AInset, ARect.Top + AInset,
    ARect.Right - AInset, ARect.Bottom - AInset);
end;

procedure TDACSkiaBorderPainter.Draw(const ACanvas: ISkCanvas;
  const ARect: TRectF; const AStyle: TDACBorderStyle);
var
  LRect: TRectF;
begin
  if (FRenderer = nil) or (ACanvas = nil) or (AStyle.Width <= 0) or
    (AStyle.Alpha = 0) then
    Exit;

  LRect := InsetRect(ARect, AStyle.Width / 2);
  FRenderer.StrokeRoundRect(ACanvas, LRect, AStyle.Color, AStyle.Radius,
    AStyle.Width, AStyle.Alpha);
end;

procedure TDACSkiaBorderPainter.Draw(const ACanvas: ISkCanvas;
  const ARect: TRectF; const ATheme: IDACComponentsTheme;
  const AKind: TDACBorderKind);
begin
  Draw(ACanvas, ARect, TDACBorderStyle.FromTheme(ATheme, AKind));
end;

procedure TDACSkiaBorderPainter.DrawPanelBorder(
  const ACanvas: ISkCanvas; const ARect: TRectF;
  const ATheme: IDACComponentsTheme);
begin
  Draw(ACanvas, ARect, ATheme, mbkPanel);
end;

procedure TDACSkiaBorderPainter.DrawCardBorder(const ACanvas: ISkCanvas;
  const ARect: TRectF; const ATheme: IDACComponentsTheme);
begin
  Draw(ACanvas, ARect, ATheme, mbkCard);
end;

procedure TDACSkiaBorderPainter.DrawControlBorder(
  const ACanvas: ISkCanvas; const ARect: TRectF;
  const ATheme: IDACComponentsTheme);
begin
  Draw(ACanvas, ARect, ATheme, mbkControl);
end;

procedure TDACSkiaBorderPainter.DrawFocusBorder(const ACanvas: ISkCanvas;
  const ARect: TRectF; const ATheme: IDACComponentsTheme);
begin
  Draw(ACanvas, ARect, ATheme, mbkFocused);
end;

procedure TDACSkiaBorderPainter.DrawDangerBorder(
  const ACanvas: ISkCanvas; const ARect: TRectF;
  const ATheme: IDACComponentsTheme);
begin
  Draw(ACanvas, ARect, ATheme, mbkDanger);
end;

procedure TDACSkiaBorderPainter.DrawWarningBorder(
  const ACanvas: ISkCanvas; const ARect: TRectF;
  const ATheme: IDACComponentsTheme);
begin
  Draw(ACanvas, ARect, ATheme, mbkWarning);
end;

end.

