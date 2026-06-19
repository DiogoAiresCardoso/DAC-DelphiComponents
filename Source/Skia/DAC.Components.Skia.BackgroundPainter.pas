unit MaxxRural.Components.Skia.BackgroundPainter;

interface

uses
  System.Skia,
  System.Types,
  System.UITypes,
  MaxxRural.Components.DesignSystem.Theme,
  MaxxRural.Components.Skia.Renderer;

type
  TMaxxRuralBackgroundKind = (
    mbgApplication,
    mbgPanel,
    mbgCard,
    mbgControl,
    mbgOverlay,
    mbgTransparent
  );

  TMaxxRuralBackgroundStyle = record
    Color: TAlphaColor;
    Radius: Single;
    Alpha: Byte;
    class function FromTheme(const ATheme: IMaxxRuralComponentsTheme;
      const AKind: TMaxxRuralBackgroundKind): TMaxxRuralBackgroundStyle; static;
  end;

  TMaxxRuralSkiaBackgroundPainter = class
  private
    FRenderer: TMaxxRuralSkiaRenderer;
  public
    constructor Create(const ARenderer: TMaxxRuralSkiaRenderer);
    procedure Draw(const ACanvas: ISkCanvas; const ARect: TRectF;
      const AStyle: TMaxxRuralBackgroundStyle); overload;
    procedure Draw(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ATheme: IMaxxRuralComponentsTheme;
      const AKind: TMaxxRuralBackgroundKind); overload;
    procedure DrawApplication(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ATheme: IMaxxRuralComponentsTheme);
    procedure DrawPanel(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ATheme: IMaxxRuralComponentsTheme);
    procedure DrawCard(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ATheme: IMaxxRuralComponentsTheme);
    procedure DrawControl(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ATheme: IMaxxRuralComponentsTheme);
    procedure DrawOverlay(const ACanvas: ISkCanvas; const ARect: TRectF;
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

class function TMaxxRuralBackgroundStyle.FromTheme(
  const ATheme: IMaxxRuralComponentsTheme;
  const AKind: TMaxxRuralBackgroundKind): TMaxxRuralBackgroundStyle;
var
  LTheme: IMaxxRuralComponentsTheme;
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

constructor TMaxxRuralSkiaBackgroundPainter.Create(
  const ARenderer: TMaxxRuralSkiaRenderer);
begin
  inherited Create;
  FRenderer := ARenderer;
end;

procedure TMaxxRuralSkiaBackgroundPainter.Draw(const ACanvas: ISkCanvas;
  const ARect: TRectF; const AStyle: TMaxxRuralBackgroundStyle);
begin
  if (FRenderer = nil) or (ACanvas = nil) or (AStyle.Alpha = 0) then
    Exit;

  FRenderer.FillRoundRect(ACanvas, ARect, AStyle.Color, AStyle.Radius,
    AStyle.Alpha);
end;

procedure TMaxxRuralSkiaBackgroundPainter.Draw(const ACanvas: ISkCanvas;
  const ARect: TRectF; const ATheme: IMaxxRuralComponentsTheme;
  const AKind: TMaxxRuralBackgroundKind);
begin
  Draw(ACanvas, ARect, TMaxxRuralBackgroundStyle.FromTheme(ATheme, AKind));
end;

procedure TMaxxRuralSkiaBackgroundPainter.DrawApplication(
  const ACanvas: ISkCanvas; const ARect: TRectF;
  const ATheme: IMaxxRuralComponentsTheme);
begin
  Draw(ACanvas, ARect, ATheme, mbgApplication);
end;

procedure TMaxxRuralSkiaBackgroundPainter.DrawPanel(const ACanvas: ISkCanvas;
  const ARect: TRectF; const ATheme: IMaxxRuralComponentsTheme);
begin
  Draw(ACanvas, ARect, ATheme, mbgPanel);
end;

procedure TMaxxRuralSkiaBackgroundPainter.DrawCard(const ACanvas: ISkCanvas;
  const ARect: TRectF; const ATheme: IMaxxRuralComponentsTheme);
begin
  Draw(ACanvas, ARect, ATheme, mbgCard);
end;

procedure TMaxxRuralSkiaBackgroundPainter.DrawControl(const ACanvas: ISkCanvas;
  const ARect: TRectF; const ATheme: IMaxxRuralComponentsTheme);
begin
  Draw(ACanvas, ARect, ATheme, mbgControl);
end;

procedure TMaxxRuralSkiaBackgroundPainter.DrawOverlay(const ACanvas: ISkCanvas;
  const ARect: TRectF; const ATheme: IMaxxRuralComponentsTheme);
begin
  Draw(ACanvas, ARect, ATheme, mbgOverlay);
end;

end.
