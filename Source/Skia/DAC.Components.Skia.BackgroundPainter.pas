unit DAC.Components.Skia.BackgroundPainter;

interface

uses
  System.Skia,
  System.Types,
  System.UITypes,
  DAC.Components.DesignSystem.Theme,
  DAC.Components.Skia.Renderer;

type
  TDACBackgroundKind = (
    mbgApplication,
    mbgPanel,
    mbgCard,
    mbgControl,
    mbgOverlay,
    mbgTransparent
  );

  TDACBackgroundStyle = record
    Color: TAlphaColor;
    Radius: Single;
    Alpha: Byte;
    class function FromTheme(const ATheme: IDACComponentsTheme;
      const AKind: TDACBackgroundKind): TDACBackgroundStyle; static;
  end;

  TDACSkiaBackgroundPainter = class
  private
    FRenderer: TDACSkiaRenderer;
  public
    constructor Create(const ARenderer: TDACSkiaRenderer);
    procedure Draw(const ACanvas: ISkCanvas; const ARect: TRectF;
      const AStyle: TDACBackgroundStyle); overload;
    procedure Draw(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ATheme: IDACComponentsTheme;
      const AKind: TDACBackgroundKind); overload;
    procedure DrawApplication(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ATheme: IDACComponentsTheme);
    procedure DrawPanel(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ATheme: IDACComponentsTheme);
    procedure DrawCard(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ATheme: IDACComponentsTheme);
    procedure DrawControl(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ATheme: IDACComponentsTheme);
    procedure DrawOverlay(const ACanvas: ISkCanvas; const ARect: TRectF;
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

class function TDACBackgroundStyle.FromTheme(
  const ATheme: IDACComponentsTheme;
  const AKind: TDACBackgroundKind): TDACBackgroundStyle;
var
  LTheme: IDACComponentsTheme;
begin
  LTheme := ResolveTheme(ATheme);
  Result.Radius := 0;
  Result.Alpha := 255;

  case AKind of
    mbgApplication:
      begin
        Result.Color := LTheme.Tokens.Colors.Background;
        Result.Alpha := 255;
      end;
    mbgPanel:
      begin
        Result.Color := LTheme.Tokens.Colors.Panel;
        Result.Radius := LTheme.Tokens.Radius.R10;
        Result.Alpha := LTheme.Tokens.Opacities.Panel;
      end;
    mbgCard:
      begin
        Result.Color := LTheme.Tokens.Colors.Panel;
        Result.Radius := LTheme.Tokens.Radius.R10;
        Result.Alpha := LTheme.Tokens.Card.DefaultOpacity;
      end;
    mbgControl:
      begin
        Result.Color := LTheme.Tokens.Colors.SurfaceDark;
        Result.Radius := LTheme.Tokens.Radius.R8;
        Result.Alpha := LTheme.Tokens.Opacities.Chrome;
      end;
    mbgOverlay:
      begin
        Result.Color := LTheme.Tokens.Colors.Background;
        Result.Alpha := LTheme.Tokens.Opacities.BackgroundDarkOverlay;
      end;
  else
    begin
      Result.Color := TAlphaColorRec.Null;
      Result.Alpha := 0;
    end;
  end;
end;

constructor TDACSkiaBackgroundPainter.Create(
  const ARenderer: TDACSkiaRenderer);
begin
  inherited Create;
  FRenderer := ARenderer;
end;

procedure TDACSkiaBackgroundPainter.Draw(const ACanvas: ISkCanvas;
  const ARect: TRectF; const AStyle: TDACBackgroundStyle);
begin
  if (FRenderer = nil) or (ACanvas = nil) or (AStyle.Alpha = 0) then
    Exit;

  FRenderer.FillRoundRect(ACanvas, ARect, AStyle.Color, AStyle.Radius,
    AStyle.Alpha);
end;

procedure TDACSkiaBackgroundPainter.Draw(const ACanvas: ISkCanvas;
  const ARect: TRectF; const ATheme: IDACComponentsTheme;
  const AKind: TDACBackgroundKind);
begin
  Draw(ACanvas, ARect, TDACBackgroundStyle.FromTheme(ATheme, AKind));
end;

procedure TDACSkiaBackgroundPainter.DrawApplication(
  const ACanvas: ISkCanvas; const ARect: TRectF;
  const ATheme: IDACComponentsTheme);
begin
  Draw(ACanvas, ARect, ATheme, mbgApplication);
end;

procedure TDACSkiaBackgroundPainter.DrawPanel(const ACanvas: ISkCanvas;
  const ARect: TRectF; const ATheme: IDACComponentsTheme);
begin
  Draw(ACanvas, ARect, ATheme, mbgPanel);
end;

procedure TDACSkiaBackgroundPainter.DrawCard(const ACanvas: ISkCanvas;
  const ARect: TRectF; const ATheme: IDACComponentsTheme);
begin
  Draw(ACanvas, ARect, ATheme, mbgCard);
end;

procedure TDACSkiaBackgroundPainter.DrawControl(const ACanvas: ISkCanvas;
  const ARect: TRectF; const ATheme: IDACComponentsTheme);
begin
  Draw(ACanvas, ARect, ATheme, mbgControl);
end;

procedure TDACSkiaBackgroundPainter.DrawOverlay(const ACanvas: ISkCanvas;
  const ARect: TRectF; const ATheme: IDACComponentsTheme);
begin
  Draw(ACanvas, ARect, ATheme, mbgOverlay);
end;

end.

