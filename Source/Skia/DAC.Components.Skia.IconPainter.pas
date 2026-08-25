unit DAC.Components.Skia.IconPainter;

interface

uses
  System.Generics.Collections,
  System.Skia,
  System.Types,
  System.UITypes,
  DAC.Components.DesignSystem.IconAssets,
  DAC.Components.DesignSystem.Theme,
  DAC.Components.Skia.Renderer;

type
  TDACIconStyle = record
    Color: TAlphaColor;
    Alpha: Byte;
    class function FromTheme(const ATheme: IDACComponentsTheme): TDACIconStyle; static;
    class function Semantic(const ATheme: IDACComponentsTheme;
      const AKind: TDACIconKind): TDACIconStyle; static;
  end;

  TDACSkiaIconPainter = class
  private
    FIconCache: TDictionary<string, ISkSVGDOM>;
    FRenderer: TDACSkiaRenderer;
    function IconCacheKey(const AKind: TDACIconKind;
      const AStyle: TDACIconStyle): string;
    function ResolveIcon(const AKind: TDACIconKind;
      const AStyle: TDACIconStyle): ISkSVGDOM;
    function SvgSource(const AKind: TDACIconKind;
      const AStyle: TDACIconStyle): string;
  public
    constructor Create(const ARenderer: TDACSkiaRenderer);
    destructor Destroy; override;
    procedure ClearCache;
    procedure Draw(const ACanvas: ISkCanvas; const ARect: TRectF;
      const AKind: TDACIconKind; const AStyle: TDACIconStyle); overload;
    procedure Draw(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ATheme: IDACComponentsTheme; const AKind: TDACIconKind); overload;
    procedure DrawSvg(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ASvg: ISkSVGDOM);
    procedure DrawChevronDown(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ATheme: IDACComponentsTheme);
    procedure DrawChevronRight(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ATheme: IDACComponentsTheme);
    procedure DrawSearch(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ATheme: IDACComponentsTheme);
    procedure DrawUser(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ATheme: IDACComponentsTheme);
    procedure DrawCheck(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ATheme: IDACComponentsTheme);
    procedure DrawWarning(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ATheme: IDACComponentsTheme);
    procedure DrawDanger(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ATheme: IDACComponentsTheme);
    procedure DrawEye(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ATheme: IDACComponentsTheme);
    procedure DrawClose(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ATheme: IDACComponentsTheme);
    property Renderer: TDACSkiaRenderer read FRenderer;
  end;

implementation

uses
  System.Math,
  System.SysUtils,
  DAC.Components.DesignSystem.DefaultTheme,
  DAC.Components.DesignSystem.OpacityTokens;

function ResolveTheme(const ATheme: IDACComponentsTheme): IDACComponentsTheme;
begin
  if ATheme = nil then
    Result := TDACDefaultComponentsTheme.New
  else
    Result := ATheme;
end;

class function TDACIconStyle.FromTheme(
  const ATheme: IDACComponentsTheme): TDACIconStyle;
var
  LTheme: IDACComponentsTheme;
begin
  LTheme := ResolveTheme(ATheme);
  Result.Color := LTheme.Tokens.Colors.Text;
  Result.Alpha := DACOpacityOpaque;
end;

class function TDACIconStyle.Semantic(
  const ATheme: IDACComponentsTheme;
  const AKind: TDACIconKind): TDACIconStyle;
var
  LTheme: IDACComponentsTheme;
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

constructor TDACSkiaIconPainter.Create(
  const ARenderer: TDACSkiaRenderer);
begin
  inherited Create;
  FRenderer := ARenderer;
  FIconCache := TDictionary<string, ISkSVGDOM>.Create;
end;

destructor TDACSkiaIconPainter.Destroy;
begin
  FIconCache.Free;
  inherited;
end;

procedure TDACSkiaIconPainter.ClearCache;
begin
  FIconCache.Clear;
end;

procedure TDACSkiaIconPainter.Draw(const ACanvas: ISkCanvas;
  const ARect: TRectF; const AKind: TDACIconKind;
  const AStyle: TDACIconStyle);
begin
  if AKind = mikNone then
    Exit;

  DrawSvg(ACanvas, ARect, ResolveIcon(AKind, AStyle));
end;

procedure TDACSkiaIconPainter.Draw(const ACanvas: ISkCanvas;
  const ARect: TRectF; const ATheme: IDACComponentsTheme;
  const AKind: TDACIconKind);
begin
  Draw(ACanvas, ARect, AKind, TDACIconStyle.Semantic(ATheme, AKind));
end;

procedure TDACSkiaIconPainter.DrawSvg(const ACanvas: ISkCanvas;
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

procedure TDACSkiaIconPainter.DrawChevronDown(const ACanvas: ISkCanvas;
  const ARect: TRectF; const ATheme: IDACComponentsTheme);
begin
  Draw(ACanvas, ARect, ATheme, mikChevronDown);
end;

procedure TDACSkiaIconPainter.DrawChevronRight(const ACanvas: ISkCanvas;
  const ARect: TRectF; const ATheme: IDACComponentsTheme);
begin
  Draw(ACanvas, ARect, ATheme, mikChevronRight);
end;

procedure TDACSkiaIconPainter.DrawSearch(const ACanvas: ISkCanvas;
  const ARect: TRectF; const ATheme: IDACComponentsTheme);
begin
  Draw(ACanvas, ARect, ATheme, mikSearch);
end;

procedure TDACSkiaIconPainter.DrawUser(const ACanvas: ISkCanvas;
  const ARect: TRectF; const ATheme: IDACComponentsTheme);
begin
  Draw(ACanvas, ARect, ATheme, mikUser);
end;

procedure TDACSkiaIconPainter.DrawCheck(const ACanvas: ISkCanvas;
  const ARect: TRectF; const ATheme: IDACComponentsTheme);
begin
  Draw(ACanvas, ARect, ATheme, mikCheck);
end;

procedure TDACSkiaIconPainter.DrawWarning(const ACanvas: ISkCanvas;
  const ARect: TRectF; const ATheme: IDACComponentsTheme);
begin
  Draw(ACanvas, ARect, ATheme, mikWarning);
end;

procedure TDACSkiaIconPainter.DrawDanger(const ACanvas: ISkCanvas;
  const ARect: TRectF; const ATheme: IDACComponentsTheme);
begin
  Draw(ACanvas, ARect, ATheme, mikDanger);
end;

procedure TDACSkiaIconPainter.DrawEye(const ACanvas: ISkCanvas;
  const ARect: TRectF; const ATheme: IDACComponentsTheme);
begin
  Draw(ACanvas, ARect, ATheme, mikEye);
end;

procedure TDACSkiaIconPainter.DrawClose(const ACanvas: ISkCanvas;
  const ARect: TRectF; const ATheme: IDACComponentsTheme);
begin
  Draw(ACanvas, ARect, ATheme, mikClose);
end;

function TDACSkiaIconPainter.IconCacheKey(
  const AKind: TDACIconKind; const AStyle: TDACIconStyle): string;
begin
  Result := Format('%d|%s|%d', [Ord(AKind), IntToHex(AStyle.Color, 8),
    AStyle.Alpha]);
end;

function TDACSkiaIconPainter.ResolveIcon(
  const AKind: TDACIconKind;
  const AStyle: TDACIconStyle): ISkSVGDOM;
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

function TDACSkiaIconPainter.SvgSource(
  const AKind: TDACIconKind;
  const AStyle: TDACIconStyle): string;
begin
  Result := TDACIconAssets.SvgSource(AKind, AStyle.Color,
    AStyle.Alpha);
end;

end.

