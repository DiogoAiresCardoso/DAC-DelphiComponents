unit DAC.Components.Skia.SeparatorPainter;

{ Responsabilidade: desenhar linhas divisorias horizontais e verticais.
  Recebe ISkCanvas e tokens - sem conhecimento de VCL, TControl ou Handle. }

interface

uses
  System.Types,
  System.UITypes,
  System.Skia,
  DAC.Components.DesignSystem.Theme,
  DAC.Components.Skia.Renderer;

type
  TDACSkiaSeparatorPainter = class
  private
    FRenderer: TDACSkiaRenderer;
  public
    constructor Create(const ARenderer: TDACSkiaRenderer);
    
    procedure DrawHorizontal(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ATheme: IDACComponentsTheme);
    procedure DrawVertical(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ATheme: IDACComponentsTheme);
  end;

implementation

constructor TDACSkiaSeparatorPainter.Create(const ARenderer: TDACSkiaRenderer);
begin
  inherited Create;
  FRenderer := ARenderer;
end;

procedure TDACSkiaSeparatorPainter.DrawHorizontal(const ACanvas: ISkCanvas;
  const ARect: TRectF; const ATheme: IDACComponentsTheme);
var
  LColor: TAlphaColor;
begin
  if (ACanvas = nil) or (ATheme = nil) then
    Exit;
  LColor := ATheme.Tokens.Colors.Border;
  FRenderer.DrawLine(ACanvas, PointF(ARect.Left, ARect.Bottom),
    PointF(ARect.Right, ARect.Bottom), LColor, 1.0);
end;

procedure TDACSkiaSeparatorPainter.DrawVertical(const ACanvas: ISkCanvas;
  const ARect: TRectF; const ATheme: IDACComponentsTheme);
var
  LColor: TAlphaColor;
begin
  if (ACanvas = nil) or (ATheme = nil) then
    Exit;
  LColor := ATheme.Tokens.Colors.Border;
  FRenderer.DrawLine(ACanvas, PointF(ARect.Right, ARect.Top),
    PointF(ARect.Right, ARect.Bottom), LColor, 1.0);
end;

end.
