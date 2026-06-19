unit MaxxRural.Components.Skia.IconPainter;

interface

uses
  System.Generics.Collections,
  System.Skia,
  System.Types,
  System.UITypes,
  MaxxRural.Components.DesignSystem.IconAssets,
  MaxxRural.Components.DesignSystem.Theme,
  MaxxRural.Components.Skia.Renderer;

type
  TMaxxRuralIconStyle = record
    Color: TAlphaColor;
    Alpha: Byte;
    class function FromTheme(const ATheme: IMaxxRuralComponentsTheme): TMaxxRuralIconStyle; static;
    class function Semantic(const ATheme: IMaxxRuralComponentsTheme;
      const AKind: TMaxxRuralIconKind): TMaxxRuralIconStyle; static;
  end;

  TMaxxRuralSkiaIconPainter = class
  private
    FIconCache: TDictionary<string, ISkSVGDOM>;
    FRenderer: TMaxxRuralSkiaRenderer;
    function IconCacheKey(const AKind: TMaxxRuralIconKind;
      const AStyle: TMaxxRuralIconStyle): string;
    function ResolveIcon(const AKind: TMaxxRuralIconKind;
      const AStyle: TMaxxRuralIconStyle): ISkSVGDOM;
    function SvgSource(const AKind: TMaxxRuralIconKind;
      const AStyle: TMaxxRuralIconStyle): string;
  public
    constructor Create(const ARenderer: TMaxxRuralSkiaRenderer);
    destructor Destroy; override;
    procedure ClearCache;
    procedure Draw(const ACanvas: ISkCanvas; const ARect: TRectF;
      const AKind: TMaxxRuralIconKind; const AStyle: TMaxxRuralIconStyle); overload;
    procedure Draw(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ATheme: IMaxxRuralComponentsTheme; const AKind: TMaxxRuralIconKind); overload;
    procedure DrawSvg(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ASvg: ISkSVGDOM);
    procedure DrawChevronDown(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ATheme: IMaxxRuralComponentsTheme);
    procedure DrawChevronRight(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ATheme: IMaxxRuralComponentsTheme);
    procedure DrawSearch(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ATheme: IMaxxRuralComponentsTheme);
    procedure DrawUser(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ATheme: IMaxxRuralComponentsTheme);
    procedure DrawCheck(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ATheme: IMaxxRuralComponentsTheme);
    procedure DrawWarning(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ATheme: IMaxxRuralComponentsTheme);
    procedure DrawDanger(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ATheme: IMaxxRuralComponentsTheme);
    procedure DrawEye(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ATheme: IMaxxRuralComponentsTheme);
    procedure DrawClose(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ATheme: IMaxxRuralComponentsTheme);
    property Renderer: TMaxxRuralSkiaRenderer read FRenderer;
  end;

implementation

uses
  System.Math,
  System.SysUtils,
  MaxxRural.Components.DesignSystem.DefaultTheme;

function ResolveTheme(const ATheme: IMaxxRuralComponentsTheme): IMaxxRuralComponentsTheme;
begin
  if ATheme = nil then
    Result := TMaxxRuralDefaultComponentsTheme.New
  else
    Result := ATheme;
end;

class function TMaxxRuralIconStyle.FromTheme(
  const ATheme: IMaxxRuralComponentsTheme): TMaxxRuralIconStyle;
var
  LTheme: IMaxxRuralComponentsTheme;
begin
  LTheme := ResolveTheme(ATheme);
  Result.Color := LTheme.Tokens.Colors.Text;
  Result.Alpha := 255;
end;

class function TMaxxRuralIconStyle.Semantic(
  const ATheme: IMaxxRuralComponentsTheme;
  const AKind: TMaxxRuralIconKind): TMaxxRuralIconStyle;
var
  LTheme: IMaxxRuralComponentsTheme;
begin
  LTheme := ResolveTheme(ATheme);
  Result := FromTheme(LTheme);
  case AKind of
    mikWarning:
      Result.Color := LTheme.Tokens.Colors.Warning;
    mikDanger,
    mikTrash,
    mikClose:
      Result.Color := LTheme.Tokens.Colors.Danger;
    mikCheck,
    mikClipboardCheck,
    mikStatusConnected,
    mikSuccessCircle:
      Result.Color := LTheme.Tokens.Colors.PrimaryLight;
  end;
end;

constructor TMaxxRuralSkiaIconPainter.Create(
  const ARenderer: TMaxxRuralSkiaRenderer);
begin
  inherited Create;
  FRenderer := ARenderer;
  FIconCache := TDictionary<string, ISkSVGDOM>.Create;
end;

destructor TMaxxRuralSkiaIconPainter.Destroy;
begin
  FIconCache.Free;
  inherited;
end;

procedure TMaxxRuralSkiaIconPainter.ClearCache;
begin
  FIconCache.Clear;
end;

procedure TMaxxRuralSkiaIconPainter.Draw(const ACanvas: ISkCanvas;
  const ARect: TRectF; const AKind: TMaxxRuralIconKind;
  const AStyle: TMaxxRuralIconStyle);
begin
  if AKind = mikNone then
    Exit;

  DrawSvg(ACanvas, ARect, ResolveIcon(AKind, AStyle));
end;

procedure TMaxxRuralSkiaIconPainter.Draw(const ACanvas: ISkCanvas;
  const ARect: TRectF; const ATheme: IMaxxRuralComponentsTheme;
  const AKind: TMaxxRuralIconKind);
begin
  Draw(ACanvas, ARect, AKind, TMaxxRuralIconStyle.Semantic(ATheme, AKind));
end;

procedure TMaxxRuralSkiaIconPainter.DrawSvg(const ACanvas: ISkCanvas;
  const ARect: TRectF; const ASvg: ISkSVGDOM);
const
  LIconViewBoxSize = 120;
var
  LScale: Single;
  LSize: Single;
begin
  if (ACanvas = nil) or (ASvg = nil) or (ARect.Width <= 0) or
    (ARect.Height <= 0) then
    Exit;

  LSize := Min(ARect.Width, ARect.Height);
  LScale := LSize / LIconViewBoxSize;

  ASvg.SetContainerSize(TSizeF.Create(LIconViewBoxSize, LIconViewBoxSize));
  ACanvas.Save;
  try
    ACanvas.Translate(ARect.Left + ((ARect.Width - LSize) / 2),
      ARect.Top + ((ARect.Height - LSize) / 2));
    ACanvas.Scale(LScale, LScale);
    ASvg.Render(ACanvas);
  finally
    ACanvas.Restore;
  end;
end;

procedure TMaxxRuralSkiaIconPainter.DrawChevronDown(const ACanvas: ISkCanvas;
  const ARect: TRectF; const ATheme: IMaxxRuralComponentsTheme);
begin
  Draw(ACanvas, ARect, ATheme, mikChevronDown);
end;

procedure TMaxxRuralSkiaIconPainter.DrawChevronRight(const ACanvas: ISkCanvas;
  const ARect: TRectF; const ATheme: IMaxxRuralComponentsTheme);
begin
  Draw(ACanvas, ARect, ATheme, mikChevronRight);
end;

procedure TMaxxRuralSkiaIconPainter.DrawSearch(const ACanvas: ISkCanvas;
  const ARect: TRectF; const ATheme: IMaxxRuralComponentsTheme);
begin
  Draw(ACanvas, ARect, ATheme, mikSearch);
end;

procedure TMaxxRuralSkiaIconPainter.DrawUser(const ACanvas: ISkCanvas;
  const ARect: TRectF; const ATheme: IMaxxRuralComponentsTheme);
begin
  Draw(ACanvas, ARect, ATheme, mikUser);
end;

procedure TMaxxRuralSkiaIconPainter.DrawCheck(const ACanvas: ISkCanvas;
  const ARect: TRectF; const ATheme: IMaxxRuralComponentsTheme);
begin
  Draw(ACanvas, ARect, ATheme, mikCheck);
end;

procedure TMaxxRuralSkiaIconPainter.DrawWarning(const ACanvas: ISkCanvas;
  const ARect: TRectF; const ATheme: IMaxxRuralComponentsTheme);
begin
  Draw(ACanvas, ARect, ATheme, mikWarning);
end;

procedure TMaxxRuralSkiaIconPainter.DrawDanger(const ACanvas: ISkCanvas;
  const ARect: TRectF; const ATheme: IMaxxRuralComponentsTheme);
begin
  Draw(ACanvas, ARect, ATheme, mikDanger);
end;

procedure TMaxxRuralSkiaIconPainter.DrawEye(const ACanvas: ISkCanvas;
  const ARect: TRectF; const ATheme: IMaxxRuralComponentsTheme);
begin
  Draw(ACanvas, ARect, ATheme, mikEye);
end;

procedure TMaxxRuralSkiaIconPainter.DrawClose(const ACanvas: ISkCanvas;
  const ARect: TRectF; const ATheme: IMaxxRuralComponentsTheme);
begin
  Draw(ACanvas, ARect, ATheme, mikClose);
end;

function TMaxxRuralSkiaIconPainter.IconCacheKey(
  const AKind: TMaxxRuralIconKind; const AStyle: TMaxxRuralIconStyle): string;
begin
  Result := Format('%d|%s|%d', [Ord(AKind), IntToHex(AStyle.Color, 8),
    AStyle.Alpha]);
end;

function TMaxxRuralSkiaIconPainter.ResolveIcon(
  const AKind: TMaxxRuralIconKind;
  const AStyle: TMaxxRuralIconStyle): ISkSVGDOM;
var
  LKey: string;
begin
  LKey := IconCacheKey(AKind, AStyle);
  if not FIconCache.TryGetValue(LKey, Result) then
  begin
    Result := TSkSVGDOM.Make(SvgSource(AKind, AStyle));
    FIconCache.Add(LKey, Result);
  end;
end;

function TMaxxRuralSkiaIconPainter.SvgSource(
  const AKind: TMaxxRuralIconKind;
  const AStyle: TMaxxRuralIconStyle): string;
begin
  Result := TMaxxRuralIconAssets.SvgSource(AKind, AStyle.Color,
    AStyle.Alpha);
end;

end.
