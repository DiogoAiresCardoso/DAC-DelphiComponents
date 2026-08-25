unit DAC.Components.Hooks.ScrollContainer;

interface

uses
  System.Types,
  Winapi.Windows,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Themes,
  DAC.Components.Controls.ScrollContainer,
  DAC.Components.Hooks.ScrollRenderer;

type
  TDACScrollHookAxis =
    DAC.Components.Hooks.ScrollRenderer.TDACScrollHookAxis;
  TDACScrollHookPaintInfo =
    DAC.Components.Hooks.ScrollRenderer.TDACScrollHookPaintInfo;
  TDACScrollHookPaintObserver =
    DAC.Components.Hooks.ScrollRenderer.TDACScrollHookPaintObserver;

const
  shaHorizontal =
    DAC.Components.Hooks.ScrollRenderer.shaHorizontal;
  shaVertical =
    DAC.Components.Hooks.ScrollRenderer.shaVertical;

type
  { Delphi 10.2 implements TScrollingStyleHook interaction through private
    helper windows but exposes its paint methods as protected virtuals. This
    localized descendant replaces only the non-client pixels; native hit-test,
    thumb drag, wheel and scroll commands remain inherited. }
  TDACScrollContainerStyleHook = class(TScrollBoxStyleHook)
  strict private
    FAuthorityHandle: HWND;
    FAuthorityTicket: NativeUInt;
    procedure DrawScroll(const ADC: HDC; const AScrollRect, ASliderRect,
      AStartButtonRect, AEndButtonRect: TRect;
      const ASliderState, AStartButtonState,
      AEndButtonState: TThemedScrollBar; const AVertical: Boolean);
  strict protected
    procedure DrawBorder; override;
    procedure DrawHorzScroll(DC: HDC); override;
    procedure DrawVertScroll(DC: HDC); override;
  public
    constructor Create(AControl: TWinControl); override;
    destructor Destroy; override;
    { Diagnostic/test seam only; it is not a published/DFM contract.
      Install and remove the observer exclusively on the main VCL thread.
      Synchronous repaints requested by the callback are painted normally,
      but nested observer notifications are deterministically suppressed. }
    class procedure SetPaintObserver(
      const AObserver: TDACScrollHookPaintObserver); static;
  end;

implementation

uses
  DAC.Components.Controls.NativeWindowTheme,
  DAC.Components.DesignSystem.ComponentStyle,
  DAC.Components.DesignSystem.ControlTokens;

function DACScrollTokens(const AControl: TWinControl;
  out ATokens: TDACControlTokens): Boolean;
begin
  Result := AControl is TDACScrollContainer;
  if Result then
    ATokens := TDACComponentStyle.ResolveForSurface(AControl,
      TDACScrollContainer(AControl).ThemeMode).Tokens.Controls;
end;

constructor TDACScrollContainerStyleHook.Create(AControl: TWinControl);
begin
  inherited;
  if (AControl <> nil) and AControl.HandleAllocated then
    FAuthorityHandle := AControl.Handle;
  FAuthorityTicket := AcquireDACNativeScrollBarHookAuthority(AControl);
end;

destructor TDACScrollContainerStyleHook.Destroy;
var
  LControl: TWinControl;
begin
  LControl := Control;
  try
    inherited;
  finally
    ReleaseDACNativeScrollBarHookAuthority(FAuthorityHandle,
      FAuthorityTicket);
  end;
  if LControl is TDACScrollContainer then
    ApplyDACNativeScrollBarTheme(LControl,
      TDACScrollContainer(LControl).ThemeMode);
end;

procedure TDACScrollContainerStyleHook.DrawScroll(const ADC: HDC;
  const AScrollRect, ASliderRect, AStartButtonRect, AEndButtonRect: TRect;
  const ASliderState, AStartButtonState,
  AEndButtonState: TThemedScrollBar; const AVertical: Boolean);
var
  LTokens: TDACControlTokens;
begin
  if DACScrollTokens(Control, LTokens) then
    RenderDACScroll(Control, ADC, AScrollRect, ASliderRect, AStartButtonRect,
      AEndButtonRect, ASliderState, AStartButtonState, AEndButtonState,
      AVertical, LTokens, spsStyleHook, scsStyleHookWindowDC);
end;

class procedure TDACScrollContainerStyleHook.SetPaintObserver(
  const AObserver: TDACScrollHookPaintObserver);
begin
  SetDACScrollPaintObserver(AObserver);
end;

procedure TDACScrollContainerStyleHook.DrawBorder;
begin
  { The DAC control owns a borderless token surface. }
end;

procedure TDACScrollContainerStyleHook.DrawHorzScroll(DC: HDC);
begin
  DrawScroll(DC, HorzScrollRect, HorzSliderRect, HorzUpButtonRect,
    HorzDownButtonRect, HorzSliderState, HorzUpState, HorzDownState, False);
end;

procedure TDACScrollContainerStyleHook.DrawVertScroll(DC: HDC);
begin
  DrawScroll(DC, VertScrollRect, VertSliderRect, VertUpButtonRect,
    VertDownButtonRect, VertSliderState, VertUpState, VertDownState, True);
end;

end.
