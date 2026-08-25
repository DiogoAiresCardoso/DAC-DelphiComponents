unit DAC.Components.Skia.StatePainter;

{ Responsabilidade: desenhar overlays de estado de interacao (hover, pressed, disabled).
  Recebe ISkCanvas e tokens - sem conhecimento de VCL, TControl ou Handle. }

interface

uses
  System.Types,
  System.UITypes,
  System.Skia,
  DAC.Components.DesignSystem.Theme,
  DAC.Components.Skia.Renderer;

type
  TDACSkiaStatePainter = class
  private
    FRenderer: TDACSkiaRenderer;
  public
    constructor Create(const ARenderer: TDACSkiaRenderer);
    
    procedure DrawHoverOverlay(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ARadius: Single; const ATheme: IDACComponentsTheme);
    procedure DrawPressedOverlay(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ARadius: Single; const ATheme: IDACComponentsTheme);
    procedure DrawDisabledOverlay(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ARadius: Single; const ATheme: IDACComponentsTheme);
  end;

implementation

constructor TDACSkiaStatePainter.Create(const ARenderer: TDACSkiaRenderer);
begin
  inherited Create;
  FRenderer := ARenderer;
end;

procedure TDACSkiaStatePainter.DrawHoverOverlay(const ACanvas: ISkCanvas;
  const ARect: TRectF; const ARadius: Single; const ATheme: IDACComponentsTheme);
var
  LColor: TAlphaColor;
begin
  if (ACanvas = nil) or (ATheme = nil) then
    Exit;
  LColor := ATheme.Tokens.Interactions.HoverColor;
  FRenderer.FillRoundRect(ACanvas, ARect, LColor, ARadius);
end;

procedure TDACSkiaStatePainter.DrawPressedOverlay(const ACanvas: ISkCanvas;
  const ARect: TRectF; const ARadius: Single; const ATheme: IDACComponentsTheme);
var
  LColor: TAlphaColor;
begin
  if (ACanvas = nil) or (ATheme = nil) then
    Exit;
  LColor := ATheme.Tokens.Interactions.PressedColor;
  FRenderer.FillRoundRect(ACanvas, ARect, LColor, ARadius);
end;

procedure TDACSkiaStatePainter.DrawDisabledOverlay(const ACanvas: ISkCanvas;
  const ARect: TRectF; const ARadius: Single; const ATheme: IDACComponentsTheme);
var
  LColor: TAlphaColor;
begin
  if (ACanvas = nil) or (ATheme = nil) then
    Exit;
  LColor := ATheme.Tokens.Colors.ControlBackgroundDisabled;
  FRenderer.FillRoundRect(ACanvas, ARect, LColor, ARadius);
end;

end.
