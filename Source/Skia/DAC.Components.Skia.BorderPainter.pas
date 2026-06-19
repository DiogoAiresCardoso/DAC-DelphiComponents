unit MaxxRural.Components.Skia.BorderPainter;

interface

uses
  System.Skia,
  System.Types,
  System.UITypes,
  MaxxRural.Components.DesignSystem.Theme,
  MaxxRural.Components.Skia.Renderer;

type
  TMaxxRuralBorderKind = (
    mbkPanel,
    mbkCard,
    mbkControl,
    mbkFocused,
    mbkDanger,
    mbkWarning
  );

  TMaxxRuralBorderStyle = record
    Color: TAlphaColor;
    Radius: Single;
    Width: Single;
    Alpha: Byte;
    class function FromTheme(const ATheme: IMaxxRuralComponentsTheme;
      const AKind: TMaxxRuralBorderKind): TMaxxRuralBorderStyle; static;
  end;

  TMaxxRuralSkiaBorderPainter = class
  private
    FRenderer: TMaxxRuralSkiaRenderer;
    function InsetRect(const ARect: TRectF; const AInset: Single): TRectF;
  public
    constructor Create(const ARenderer: TMaxxRuralSkiaRenderer);
    procedure Draw(const ACanvas: ISkCanvas; const ARect: TRectF;
      const AStyle: TMaxxRuralBorderStyle); overload;
    procedure Draw(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ATheme: IMaxxRuralComponentsTheme;
      const AKind: TMaxxRuralBorderKind); overload;
    procedure DrawPanelBorder(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ATheme: IMaxxRuralComponentsTheme);
    procedure DrawCardBorder(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ATheme: IMaxxRuralComponentsTheme);
    procedure DrawControlBorder(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ATheme: IMaxxRuralComponentsTheme);
    procedure DrawFocusBorder(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ATheme: IMaxxRuralComponentsTheme);
    procedure DrawDangerBorder(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ATheme: IMaxxRuralComponentsTheme);
    procedure DrawWarningBorder(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ATheme: IMaxxRuralComponentsTheme);
    property Renderer: TMaxxRuralSkiaRenderer read FRenderer;
  end;

implementation

uses
  MaxxRural.Components.DesignSystem.DefaultTheme;

function ResolveTheme(const ATheme: IMaxxRuralComponentsTheme): IMaxxRuralComponentsTheme;
begin
  if ATheme = nil then
    Result := TMaxxRuralDefaultComponentsTheme.New
  else
    Result := ATheme;
end;

class function TMaxxRuralBorderStyle.FromTheme(
  const ATheme: IMaxxRuralComponentsTheme;
  const AKind: TMaxxRuralBorderKind): TMaxxRuralBorderStyle;
var
  LTheme: IMaxxRuralComponentsTheme;
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

constructor TMaxxRuralSkiaBorderPainter.Create(
  const ARenderer: TMaxxRuralSkiaRenderer);
begin
  inherited Create;
  FRenderer := ARenderer;
end;

function TMaxxRuralSkiaBorderPainter.InsetRect(const ARect: TRectF;
  const AInset: Single): TRectF;
begin
  Result := TRectF.Create(ARect.Left + AInset, ARect.Top + AInset,
    ARect.Right - AInset, ARect.Bottom - AInset);
end;

procedure TMaxxRuralSkiaBorderPainter.Draw(const ACanvas: ISkCanvas;
  const ARect: TRectF; const AStyle: TMaxxRuralBorderStyle);
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

procedure TMaxxRuralSkiaBorderPainter.Draw(const ACanvas: ISkCanvas;
  const ARect: TRectF; const ATheme: IMaxxRuralComponentsTheme;
  const AKind: TMaxxRuralBorderKind);
begin
  Draw(ACanvas, ARect, TMaxxRuralBorderStyle.FromTheme(ATheme, AKind));
end;

procedure TMaxxRuralSkiaBorderPainter.DrawPanelBorder(
  const ACanvas: ISkCanvas; const ARect: TRectF;
  const ATheme: IMaxxRuralComponentsTheme);
begin
  Draw(ACanvas, ARect, ATheme, mbkPanel);
end;

procedure TMaxxRuralSkiaBorderPainter.DrawCardBorder(const ACanvas: ISkCanvas;
  const ARect: TRectF; const ATheme: IMaxxRuralComponentsTheme);
begin
  Draw(ACanvas, ARect, ATheme, mbkCard);
end;

procedure TMaxxRuralSkiaBorderPainter.DrawControlBorder(
  const ACanvas: ISkCanvas; const ARect: TRectF;
  const ATheme: IMaxxRuralComponentsTheme);
begin
  Draw(ACanvas, ARect, ATheme, mbkControl);
end;

procedure TMaxxRuralSkiaBorderPainter.DrawFocusBorder(const ACanvas: ISkCanvas;
  const ARect: TRectF; const ATheme: IMaxxRuralComponentsTheme);
begin
  Draw(ACanvas, ARect, ATheme, mbkFocused);
end;

procedure TMaxxRuralSkiaBorderPainter.DrawDangerBorder(
  const ACanvas: ISkCanvas; const ARect: TRectF;
  const ATheme: IMaxxRuralComponentsTheme);
begin
  Draw(ACanvas, ARect, ATheme, mbkDanger);
end;

procedure TMaxxRuralSkiaBorderPainter.DrawWarningBorder(
  const ACanvas: ISkCanvas; const ARect: TRectF;
  const ATheme: IMaxxRuralComponentsTheme);
begin
  Draw(ACanvas, ARect, ATheme, mbkWarning);
end;

end.
