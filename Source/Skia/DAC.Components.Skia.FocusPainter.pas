unit DAC.Components.Skia.FocusPainter;

{ Responsabilidade: desenhar o indicador de foco acessivel sobre controles.
  Recebe ISkCanvas e tokens - sem conhecimento de VCL, TControl ou Handle. }

interface

uses
  System.Types,
  System.UITypes,
  System.Skia,
  DAC.Components.DesignSystem.Theme,
  DAC.Components.Skia.Renderer;

type
  TDACSkiaFocusPainter = class
  private
    FRenderer: TDACSkiaRenderer;
  public
    constructor Create(const ARenderer: TDACSkiaRenderer);
    { Desenha um anel de foco acessivel ao redor de ARect.
      ARadius define o raio do anel (deve coincidir com o raio do chrome).
      Usa token de cor de foco do tema para garantir contraste WCAG AA. }
    procedure DrawFocusRing(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ARadius: Single; const ATheme: IDACComponentsTheme);
  end;

implementation

uses
  System.Math,
  DAC.Components.DesignSystem.ControlTokens;

constructor TDACSkiaFocusPainter.Create(const ARenderer: TDACSkiaRenderer);
begin
  inherited Create;
  FRenderer := ARenderer;
end;

procedure TDACSkiaFocusPainter.DrawFocusRing(const ACanvas: ISkCanvas;
  const ARect: TRectF; const ARadius: Single;
  const ATheme: IDACComponentsTheme);
var
  LTokens: TDACControlTokens;
  LRingRect: TRectF;
  LOffset: Single;
begin
  if (ACanvas = nil) or (ATheme = nil) then
    Exit;

  LTokens := ATheme.Tokens.Controls;
  LOffset := 2.0; // Offset fallback se nao existir no tema
  
  LRingRect := TRectF.Create(
    ARect.Left - LOffset,
    ARect.Top - LOffset,
    ARect.Right + LOffset,
    ARect.Bottom + LOffset);

  FRenderer.StrokeRoundRect(ACanvas, LRingRect,
    ATheme.Tokens.Interactions.FocusStrokeColor, ARadius + LOffset,
    LTokens.FocusRingWidth);
end;

end.
