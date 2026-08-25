unit DAC.Components.Skia.ProgressPainter;

{ Responsabilidade: desenhar indicadores de progresso (determinado e
  indeterminado) em canvas Skia, sem conhecimento de VCL, TControl ou Handle.

  SOLID: SRP — esta classe tem uma unica responsabilidade: pintar trilhas
  e thumbs de progresso/loading usando primitivas do renderer. }

interface

uses
  System.Types,
  System.UITypes,
  System.Skia,
  DAC.Components.DesignSystem.Theme,
  DAC.Components.Skia.Renderer;

type
  { Opcoes para o modo de pintura do progresso. }
  TDACProgressKind = (
    mpkLinear,       { Barra horizontal determinada }
    mpkCircular,     { Arco circular determinado }
    mpkLinearIndeterminate,   { Barra pulsante }
    mpkCircularIndeterminate  { Arco giratorio }
  );

  { Pinta indicadores de progresso em canvas Skia.
    Recebe o canvas, o rect de destino e o valor de 0..1 (determinado)
    ou um angulo de fase (indeterminado). }
  TDACSkiaProgressPainter = class
  private
    FRenderer: TDACSkiaRenderer;
  public
    constructor Create(const ARenderer: TDACSkiaRenderer);

    { Desenha uma barra de progresso linear determinada.
      AValue: valor entre 0.0 e 1.0. }
    procedure DrawLinear(const ACanvas: ISkCanvas; const ARect: TRectF;
      const AValue: Single; const ATheme: IDACComponentsTheme);

    { Desenha uma barra de progresso linear indeterminada (pulsante).
      APhase: valor 0..1 que avanca a cada frame (fornecido pelo controle). }
    procedure DrawLinearIndeterminate(const ACanvas: ISkCanvas;
      const ARect: TRectF; const APhase: Single;
      const ATheme: IDACComponentsTheme);

    { Desenha um arco de progresso circular determinado.
      AValue: valor entre 0.0 e 1.0.
      ATrackWidth: espessura do anel. }
    procedure DrawCircular(const ACanvas: ISkCanvas; const ARect: TRectF;
      const AValue: Single; const ATrackWidth: Single;
      const ATheme: IDACComponentsTheme);

    { Desenha um arco de progresso circular indeterminado (giratorio).
      APhase: angulo inicial em graus, avanca a cada frame. }
    procedure DrawCircularIndeterminate(const ACanvas: ISkCanvas;
      const ARect: TRectF; const APhase: Single; const ATrackWidth: Single;
      const ATheme: IDACComponentsTheme);
  end;

implementation

uses
  System.Math,
  DAC.Components.DesignSystem.ControlTokens;

constructor TDACSkiaProgressPainter.Create(const ARenderer: TDACSkiaRenderer);
begin
  inherited Create;
  FRenderer := ARenderer;
end;

procedure TDACSkiaProgressPainter.DrawLinear(const ACanvas: ISkCanvas;
  const ARect: TRectF; const AValue: Single;
  const ATheme: IDACComponentsTheme);
var
  LTokens: TDACControlTokens;
  LTrackRect: TRectF;
  LFillRect: TRectF;
  LRadius: Single;
  LClampedValue: Single;
begin
  if (ACanvas = nil) or (ATheme = nil) then
    Exit;
  LTokens := ATheme.Tokens.Controls;
  LRadius := LTokens.ProgressLinearThickness / 2.0;
  LTrackRect := ARect;
  LTrackRect.Height := LTokens.ProgressLinearThickness;
  LTrackRect.Offset(0, (ARect.Height - LTrackRect.Height) / 2.0);

  { Trilha de fundo }
  FRenderer.FillRoundRect(ACanvas, LTrackRect, LTokens.ProgressTrack,
    LRadius, LTokens.AlphaOpaque);

  { Barra de preenchimento }
  LClampedValue := EnsureRange(AValue, 0.0, 1.0);
  LFillRect := LTrackRect;
  LFillRect.Right := LFillRect.Left + LFillRect.Width * LClampedValue;
  if LFillRect.Width > 0 then
    FRenderer.FillRoundRect(ACanvas, LFillRect, LTokens.Success,
      LRadius, LTokens.AlphaOpaque);
end;

procedure TDACSkiaProgressPainter.DrawLinearIndeterminate(
  const ACanvas: ISkCanvas; const ARect: TRectF; const APhase: Single;
  const ATheme: IDACComponentsTheme);
var
  LTokens: TDACControlTokens;
  LTrackRect: TRectF;
  LPulseRect: TRectF;
  LRadius: Single;
  LPulseWidth: Single;
  LPhaseNorm: Single;
begin
  if (ACanvas = nil) or (ATheme = nil) then
    Exit;
  LTokens := ATheme.Tokens.Controls;
  LRadius := LTokens.ProgressLinearThickness / 2.0;
  LTrackRect := ARect;
  LTrackRect.Height := LTokens.ProgressLinearThickness;
  LTrackRect.Offset(0, (ARect.Height - LTrackRect.Height) / 2.0);

  FRenderer.FillRoundRect(ACanvas, LTrackRect, LTokens.ProgressTrack,
    LRadius, LTokens.AlphaOpaque);

  { Pulso: barra de 1/3 da largura que desliza da esquerda para a direita }
  LPulseWidth := LTrackRect.Width / 3.0;
  LPhaseNorm := Frac(APhase); { 0..1 ciclico }
  LPulseRect := LTrackRect;
  LPulseRect.Left := LTrackRect.Left + (LTrackRect.Width + LPulseWidth) * LPhaseNorm - LPulseWidth;
  LPulseRect.Right := LPulseRect.Left + LPulseWidth;

  { Clipar ao track para nao vazar para fora }
  LPulseRect.Left := Max(LPulseRect.Left, LTrackRect.Left);
  LPulseRect.Right := Min(LPulseRect.Right, LTrackRect.Right);

  if LPulseRect.Width > 0 then
    FRenderer.FillRoundRect(ACanvas, LPulseRect, LTokens.Success,
      LRadius, LTokens.AlphaOpaque);
end;

procedure TDACSkiaProgressPainter.DrawCircular(const ACanvas: ISkCanvas;
  const ARect: TRectF; const AValue: Single; const ATrackWidth: Single;
  const ATheme: IDACComponentsTheme);
var
  LTokens: TDACControlTokens;
  LOvalRect: TRectF;
  LPaint: ISkPaint;
  LClampedValue: Single;
  LSweepAngle: Single;
  LInset: Single;
begin
  if (ACanvas = nil) or (ATheme = nil) then
    Exit;
  LTokens := ATheme.Tokens.Controls;
  LInset := ATrackWidth / 2.0;
  LOvalRect := ARect;
  LOvalRect.Inflate(-LInset, -LInset);

  { Trilha de fundo — circulo completo }
  LPaint := TSkPaint.Create;
  LPaint.AntiAlias := True;
  LPaint.Style := TSkPaintStyle.Stroke;
  LPaint.StrokeWidth := ATrackWidth;
  LPaint.Color := LTokens.ProgressTrack;
  ACanvas.DrawOval(LOvalRect, LPaint);

  { Arco de preenchimento: -90 graus e o topo }
  LClampedValue := EnsureRange(AValue, 0.0, 1.0);
  LSweepAngle := 360.0 * LClampedValue;
  if LSweepAngle > 0 then
  begin
    LPaint.Color := LTokens.Success;
    ACanvas.DrawArc(LOvalRect, -90, LSweepAngle, False, LPaint);
  end;
end;

procedure TDACSkiaProgressPainter.DrawCircularIndeterminate(
  const ACanvas: ISkCanvas; const ARect: TRectF; const APhase: Single;
  const ATrackWidth: Single; const ATheme: IDACComponentsTheme);
var
  LTokens: TDACControlTokens;
  LOvalRect: TRectF;
  LPaint: ISkPaint;
  LInset: Single;
  LStartAngle: Single;
begin
  if (ACanvas = nil) or (ATheme = nil) then
    Exit;
  LTokens := ATheme.Tokens.Controls;
  LInset := ATrackWidth / 2.0;
  LOvalRect := ARect;
  LOvalRect.Inflate(-LInset, -LInset);

  LPaint := TSkPaint.Create;
  LPaint.AntiAlias := True;
  LPaint.Style := TSkPaintStyle.Stroke;
  LPaint.StrokeWidth := ATrackWidth;
  LPaint.Color := LTokens.ProgressTrack;
  ACanvas.DrawOval(LOvalRect, LPaint);

  { Arco giratorio de 90 graus }
  LStartAngle := APhase * 360.0;
  LPaint.Color := LTokens.Success;
  ACanvas.DrawArc(LOvalRect, LStartAngle, 90, False, LPaint);
end;

end.
