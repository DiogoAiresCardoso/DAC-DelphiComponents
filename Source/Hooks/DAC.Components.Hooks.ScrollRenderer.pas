unit DAC.Components.Hooks.ScrollRenderer;

interface

uses
  System.Types,
  System.UITypes,
  Winapi.Windows,
  Vcl.Controls,
  Vcl.Themes,
  DAC.Components.DesignSystem.ControlTokens,
  DAC.Components.Skia.ScrollBarRenderer;

type
  { Compatibility facade. Scroll geometry and painting live exclusively in
    DAC.Components.Skia.ScrollBarRenderer. }
  TDACScrollHookAxis =
    DAC.Components.Skia.ScrollBarRenderer.TDACScrollHookAxis;
  TDACScrollPaintSource =
    DAC.Components.Skia.ScrollBarRenderer.TDACScrollPaintSource;
  TDACScrollCoordinateSpace =
    DAC.Components.Skia.ScrollBarRenderer.TDACScrollCoordinateSpace;
  TDACScrollVisualProfile =
    DAC.Components.Skia.ScrollBarRenderer.TDACScrollVisualProfile;
  TDACNativeScrollGeometry =
    DAC.Components.Skia.ScrollBarRenderer.TDACNativeScrollGeometry;
  TDACScrollHookPaintInfo =
    DAC.Components.Skia.ScrollBarRenderer.TDACScrollHookPaintInfo;
  TDACScrollHookPaintObserver =
    DAC.Components.Skia.ScrollBarRenderer.TDACScrollHookPaintObserver;

const
  shaHorizontal = DAC.Components.Skia.ScrollBarRenderer.shaHorizontal;
  shaVertical = DAC.Components.Skia.ScrollBarRenderer.shaVertical;
  spsStyleHook = DAC.Components.Skia.ScrollBarRenderer.spsStyleHook;
  spsNativeFallback =
    DAC.Components.Skia.ScrollBarRenderer.spsNativeFallback;
  scsStyleHookWindowDC =
    DAC.Components.Skia.ScrollBarRenderer.scsStyleHookWindowDC;
  scsControlWindowDC =
    DAC.Components.Skia.ScrollBarRenderer.scsControlWindowDC;
  svpLegacy = DAC.Components.Skia.ScrollBarRenderer.svpLegacy;
  svpMaxxRuralMD = DAC.Components.Skia.ScrollBarRenderer.svpMaxxRuralMD;

procedure SetDACScrollPaintObserver(
  const AObserver: TDACScrollHookPaintObserver);
procedure RenderDACScroll(const AControl: TWinControl; const ADC: HDC;
  const AScrollRect, ASliderRect, AStartButtonRect, AEndButtonRect: TRect;
  const ASliderState, AStartButtonState,
  AEndButtonState: TThemedScrollBar; const AVertical: Boolean;
  const ATokens: TDACControlTokens; const ASource: TDACScrollPaintSource;
  const ACoordinateSpace: TDACScrollCoordinateSpace);
procedure RenderDACScrollCorner(const AControl: TWinControl; const ADC: HDC;
  const ACornerRect: TRect; const ATokens: TDACControlTokens);
procedure RenderDACScrollProfile(const AControl: TWinControl; const ADC: HDC;
  const AScrollRect, ASliderRect, AStartButtonRect, AEndButtonRect: TRect;
  const ASliderState, AStartButtonState,
  AEndButtonState: TThemedScrollBar; const AVertical: Boolean;
  const ATokens: TDACControlTokens; const ASource: TDACScrollPaintSource;
  const ACoordinateSpace: TDACScrollCoordinateSpace;
  const AProfile: TDACScrollVisualProfile; const ASurfaceColor: TAlphaColor);
procedure RenderDACScrollCornerProfile(const AControl: TWinControl;
  const ADC: HDC; const ACornerRect: TRect;
  const ATokens: TDACControlTokens; const AProfile: TDACScrollVisualProfile;
  const ASurfaceColor: TAlphaColor);
function PaintDACNativeScrollBars(const AControl: TWinControl;
  const ADC: HDC; const ATokens: TDACControlTokens;
  const APaintCorner: Boolean = False): Integer;
function PaintDACNativeScrollBarsProfile(const AControl: TWinControl;
  const ADC: HDC; const ATokens: TDACControlTokens;
  const APaintCorner: Boolean; const AProfile: TDACScrollVisualProfile;
  const ASurfaceColor: TAlphaColor): Integer;
function ResolveDACNativeScrollGeometry(const AInfo: TScrollBarInfo;
  const AWindowRect: TRect; const AClientOrigin: TPoint;
  const AVertical: Boolean; out AGeometry: TDACNativeScrollGeometry): Boolean;
function ResolveDACScrollCornerRect(const AHorzScrollRect,
  AVertScrollRect: TRect; out ACornerRect: TRect): Boolean;
function DACScrollHighContrastEnabled: Boolean;

implementation

procedure SetDACScrollPaintObserver(
  const AObserver: TDACScrollHookPaintObserver);
begin
  DAC.Components.Skia.ScrollBarRenderer.SetDACScrollPaintObserver(AObserver);
end;

procedure RenderDACScroll(const AControl: TWinControl; const ADC: HDC;
  const AScrollRect, ASliderRect, AStartButtonRect, AEndButtonRect: TRect;
  const ASliderState, AStartButtonState,
  AEndButtonState: TThemedScrollBar; const AVertical: Boolean;
  const ATokens: TDACControlTokens; const ASource: TDACScrollPaintSource;
  const ACoordinateSpace: TDACScrollCoordinateSpace);
begin
  DAC.Components.Skia.ScrollBarRenderer.RenderDACScroll(AControl, ADC,
    AScrollRect, ASliderRect, AStartButtonRect, AEndButtonRect,
    ASliderState, AStartButtonState, AEndButtonState, AVertical, ATokens,
    ASource, ACoordinateSpace);
end;

procedure RenderDACScrollCorner(const AControl: TWinControl; const ADC: HDC;
  const ACornerRect: TRect; const ATokens: TDACControlTokens);
begin
  DAC.Components.Skia.ScrollBarRenderer.RenderDACScrollCorner(AControl, ADC,
    ACornerRect, ATokens);
end;

procedure RenderDACScrollProfile(const AControl: TWinControl; const ADC: HDC;
  const AScrollRect, ASliderRect, AStartButtonRect, AEndButtonRect: TRect;
  const ASliderState, AStartButtonState,
  AEndButtonState: TThemedScrollBar; const AVertical: Boolean;
  const ATokens: TDACControlTokens; const ASource: TDACScrollPaintSource;
  const ACoordinateSpace: TDACScrollCoordinateSpace;
  const AProfile: TDACScrollVisualProfile; const ASurfaceColor: TAlphaColor);
begin
  DAC.Components.Skia.ScrollBarRenderer.RenderDACScrollProfile(AControl, ADC,
    AScrollRect, ASliderRect, AStartButtonRect, AEndButtonRect,
    ASliderState, AStartButtonState, AEndButtonState, AVertical, ATokens,
    ASource, ACoordinateSpace, AProfile, ASurfaceColor);
end;

procedure RenderDACScrollCornerProfile(const AControl: TWinControl;
  const ADC: HDC; const ACornerRect: TRect;
  const ATokens: TDACControlTokens; const AProfile: TDACScrollVisualProfile;
  const ASurfaceColor: TAlphaColor);
begin
  DAC.Components.Skia.ScrollBarRenderer.RenderDACScrollCornerProfile(AControl,
    ADC, ACornerRect, ATokens, AProfile, ASurfaceColor);
end;

function PaintDACNativeScrollBars(const AControl: TWinControl;
  const ADC: HDC; const ATokens: TDACControlTokens;
  const APaintCorner: Boolean): Integer;
begin
  Result := DAC.Components.Skia.ScrollBarRenderer.PaintDACNativeScrollBars(
    AControl, ADC, ATokens, APaintCorner);
end;

function PaintDACNativeScrollBarsProfile(const AControl: TWinControl;
  const ADC: HDC; const ATokens: TDACControlTokens;
  const APaintCorner: Boolean; const AProfile: TDACScrollVisualProfile;
  const ASurfaceColor: TAlphaColor): Integer;
begin
  Result := DAC.Components.Skia.ScrollBarRenderer.
    PaintDACNativeScrollBarsProfile(AControl, ADC, ATokens, APaintCorner,
      AProfile, ASurfaceColor);
end;

function ResolveDACNativeScrollGeometry(const AInfo: TScrollBarInfo;
  const AWindowRect: TRect; const AClientOrigin: TPoint;
  const AVertical: Boolean; out AGeometry: TDACNativeScrollGeometry): Boolean;
begin
  Result := DAC.Components.Skia.ScrollBarRenderer.
    ResolveDACNativeScrollGeometry(AInfo, AWindowRect, AClientOrigin,
      AVertical, AGeometry);
end;

function ResolveDACScrollCornerRect(const AHorzScrollRect,
  AVertScrollRect: TRect; out ACornerRect: TRect): Boolean;
begin
  Result := DAC.Components.Skia.ScrollBarRenderer.ResolveDACScrollCornerRect(
    AHorzScrollRect, AVertScrollRect, ACornerRect);
end;

function DACScrollHighContrastEnabled: Boolean;
begin
  Result := DAC.Components.Skia.ScrollBarRenderer.
    DACScrollHighContrastEnabled;
end;

end.
