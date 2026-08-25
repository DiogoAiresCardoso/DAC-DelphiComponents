unit DAC.Components.Skia.ChartPainter;

{ Responsabilidade: definir a interface e a base abstrata para todos os
  painters de grafico do DAC. Cada tipo de grafico (Bar, Line, Area,
  Doughnut) implementa TDACSkiaChartPainter em seu proprio arquivo.

  SOLID: OCP — novos tipos de grafico sao adicionados por extensao, nao
  por modificacao desta unit. SRP — esta unit so define o contrato base. }

interface

uses
  System.Classes,
  System.Generics.Collections,
  System.Types,
  System.UITypes,
  System.Skia,
  DAC.Components.DesignSystem.Theme,
  DAC.Components.Skia.Renderer;

type
  { Ponto de dado individual do grafico. }
  TDACChartDataPoint = record
    Value: Double;
    Label_: string;
    Color: TAlphaColor;
  end;

  { Serie de dados para um grafico. }
  TDACChartSeries = record
    Name: string;
    Color: TAlphaColor;
    Points: array of TDACChartDataPoint;
  end;

  { Opcoes de exibicao do grafico (eixos, legenda, grid, etc.) }
  TDACChartDisplayOptions = record
    ShowGrid: Boolean;
    ShowLegend: Boolean;
    ShowLabels: Boolean;
    ShowValues: Boolean;
    AnimationPhase: Single; { 0..1, 0=vazio, 1=completo }
  end;

  { Interface que todos os painters de grafico devem implementar.
    Garante que o motor de renderizacao principal nao depende de implementacoes
    concretas de grafico (Dependency Inversion). }
  IDACChartPainter = interface
    ['{A7E21F4C-3B8D-4E9A-B5F7-C2D8A1E3F6B9}']
    procedure Draw(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ASeries: array of TDACChartSeries;
      const AOptions: TDACChartDisplayOptions;
      const ATheme: IDACComponentsTheme);
  end;

  { Classe base abstrata para painters de grafico.
    Contem utilitarios compartilhados (paleta de cores, padding, etc.)
    mas nao implementa Draw — responsabilidade dos descendentes. }
  TDACSkiaChartPainter = class abstract(TInterfacedObject, IDACChartPainter)
  protected
    FRenderer: TDACSkiaRenderer;
    { Calcula o rect de plotagem descontando padding para eixos e legenda. }
    function PlotRect(const ARect: TRectF;
      const AOptions: TDACChartDisplayOptions;
      const ATheme: IDACComponentsTheme): TRectF; virtual;
    { Desenha o grid horizontal de referencia. }
    procedure DrawGrid(const ACanvas: ISkCanvas; const APlotRect: TRectF;
      const ATheme: IDACComponentsTheme); virtual;
    { Desenha os rotulos de eixo X abaixo do plot rect. }
    procedure DrawXLabels(const ACanvas: ISkCanvas; const APlotRect: TRectF;
      const ALabels: array of string; const ATheme: IDACComponentsTheme); virtual;
    { Resolve a cor de uma serie: usa Series.Color se definido, caso contrario
      retorna a cor da paleta do tema pelo indice. }
    function SeriesColor(const ASeries: TDACChartSeries;
      const AIndex: Integer;
      const ATheme: IDACComponentsTheme): TAlphaColor; virtual;
  public
    constructor Create(const ARenderer: TDACSkiaRenderer);
    procedure Draw(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ASeries: array of TDACChartSeries;
      const AOptions: TDACChartDisplayOptions;
      const ATheme: IDACComponentsTheme); virtual; abstract;
  end;

implementation

uses
  System.Math,
  DAC.Components.DesignSystem.ComponentStyle,
  DAC.Components.DesignSystem.ControlTokens,
  DAC.Components.DesignSystem.ChartPalette;

constructor TDACSkiaChartPainter.Create(const ARenderer: TDACSkiaRenderer);
begin
  inherited Create;
  FRenderer := ARenderer;
end;

function TDACSkiaChartPainter.PlotRect(const ARect: TRectF;
  const AOptions: TDACChartDisplayOptions;
  const ATheme: IDACComponentsTheme): TRectF;
var
  LTokens: TDACControlTokens;
begin
  LTokens := ATheme.Tokens.Controls;
  Result := ARect;
  Result.Left := Result.Left + LTokens.ChartInsetLeft;
  Result.Top := Result.Top + LTokens.ChartInsetTop;
  Result.Right := Result.Right - LTokens.ChartInsetRight;
  Result.Bottom := Result.Bottom - LTokens.ChartInsetBottom;
end;

procedure TDACSkiaChartPainter.DrawGrid(const ACanvas: ISkCanvas;
  const APlotRect: TRectF; const ATheme: IDACComponentsTheme);
var
  LTokens: TDACControlTokens;
  I: Integer;
  LStep: Single;
  LY: Single;
  LLeft: TPointF;
  LRight: TPointF;
begin
  LTokens := ATheme.Tokens.Controls;
  LStep := APlotRect.Height / Max(1, LTokens.ChartGridLines);
  for I := 0 to LTokens.ChartGridLines do
  begin
    LY := APlotRect.Top + I * LStep;
    LLeft := TPointF.Create(APlotRect.Left, LY);
    LRight := TPointF.Create(APlotRect.Right, LY);
    FRenderer.StrokeLine(ACanvas, LLeft, LRight,
      LTokens.ChartGrid, LTokens.ChartBorderWidth, LTokens.ChartGridAlpha);
  end;
end;

procedure TDACSkiaChartPainter.DrawXLabels(const ACanvas: ISkCanvas;
  const APlotRect: TRectF; const ALabels: array of string;
  const ATheme: IDACComponentsTheme);
var
  LTokens: TDACControlTokens;
  I: Integer;
  LCount: Integer;
  LStepX: Single;
  LLabelRect: TRectF;
begin
  LTokens := ATheme.Tokens.Controls;
  LCount := Length(ALabels);
  if LCount = 0 then
    Exit;
  LStepX := APlotRect.Width / LCount;
  for I := 0 to LCount - 1 do
  begin
    LLabelRect := TRectF.Create(
      APlotRect.Left + I * LStepX,
      APlotRect.Bottom + 4,
      APlotRect.Left + (I + 1) * LStepX,
      APlotRect.Bottom + 20);
    FRenderer.TextCentered(ACanvas, ALabels[I],
      TDACComponentStyle.FontFamily, LLabelRect, 10,
      LTokens.InputText);
  end;
end;

function TDACSkiaChartPainter.SeriesColor(const ASeries: TDACChartSeries;
  const AIndex: Integer; const ATheme: IDACComponentsTheme): TAlphaColor;
begin
  if ASeries.Color <> TAlphaColors.Null then
    Exit(ASeries.Color);
  Result := ATheme.ChartPalette.ColorByIndex(AIndex);
end;

end.
