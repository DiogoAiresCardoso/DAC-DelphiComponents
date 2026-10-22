unit DAC.Components.Hooks.DBGridScroll;

interface

uses
  System.Types,
  Winapi.Windows,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Themes,
  DAC.Components.Controls.DBGrid;

type
  { Localized non-client hook. TScrollingStyleHook keeps ownership of native
    hit-testing, range, position, wheel, track clicks and thumb dragging. }
  TDACDBGridScrollStyleHook = class(TScrollingStyleHook)
  strict private
    FAuthorityHandle: HWND;
    FAuthorityTicket: NativeUInt;
    procedure DrawCorner;
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
  end;

implementation

uses
  DAC.Components.Controls.NativeWindowTheme,
  DAC.Components.DesignSystem.ComponentStyle,
  DAC.Components.DesignSystem.ControlTokens,
  DAC.Components.Skia.ScrollBarRenderer;

function DACDBGridScrollTokens(const AControl: TWinControl;
  out ATokens: TDACControlTokens): Boolean;
begin
  Result := AControl is TDACDBGrid;
  if Result then
    ATokens := TDACComponentStyle.ResolveForSurface(AControl,
      TDACDBGrid(AControl).ThemeMode).Tokens.Controls;
end;

constructor TDACDBGridScrollStyleHook.Create(AControl: TWinControl);
begin
  inherited;
  if (AControl <> nil) and AControl.HandleAllocated then
    FAuthorityHandle := AControl.Handle;
  FAuthorityTicket := AcquireDACNativeScrollBarHookAuthority(AControl);
end;

destructor TDACDBGridScrollStyleHook.Destroy;
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
  if LControl is TDACDBGrid then
    ApplyDACNativeScrollBarTheme(LControl,
      TDACDBGrid(LControl).ThemeMode);
end;

procedure TDACDBGridScrollStyleHook.DrawCorner;
var
  LCornerRect: TRect;
  LDC: HDC;
  LTokens: TDACControlTokens;
begin
  if (Control = nil) or not Control.HandleAllocated or
    not DACDBGridScrollTokens(Control, LTokens) or
    not ResolveDACScrollCornerRect(HorzScrollRect, VertScrollRect,
      LCornerRect) then
    Exit;
  LDC := GetWindowDC(Control.Handle);
  if LDC = 0 then
    Exit;
  try
    RenderDACScrollCornerProfile(Control, LDC, LCornerRect, LTokens,
      svpMaxxRuralMD, LTokens.DataGridBackground);
  finally
    ReleaseDC(Control.Handle, LDC);
  end;
end;

procedure TDACDBGridScrollStyleHook.DrawScroll(const ADC: HDC;
  const AScrollRect, ASliderRect, AStartButtonRect, AEndButtonRect: TRect;
  const ASliderState, AStartButtonState,
  AEndButtonState: TThemedScrollBar; const AVertical: Boolean);
var
  LTokens: TDACControlTokens;
begin
  if DACDBGridScrollTokens(Control, LTokens) then
    RenderDACScrollProfile(Control, ADC, AScrollRect, ASliderRect,
      AStartButtonRect, AEndButtonRect, ASliderState, AStartButtonState,
      AEndButtonState, AVertical, LTokens, spsStyleHook,
      scsStyleHookWindowDC, svpMaxxRuralMD, LTokens.DataGridBackground);
end;

procedure TDACDBGridScrollStyleHook.DrawBorder;
begin
  { TDACDBGrid owns its client frame. Only the native scrollbar corner is
    painted here, so focus/header/cells remain untouched. }
  if DACScrollHighContrastEnabled then
    inherited
  else
    DrawCorner;
end;

procedure TDACDBGridScrollStyleHook.DrawHorzScroll(DC: HDC);
begin
  if DACScrollHighContrastEnabled then
    inherited
  else
    DrawScroll(DC, HorzScrollRect, HorzSliderRect, HorzUpButtonRect,
      HorzDownButtonRect, HorzSliderState, HorzUpState, HorzDownState, False);
end;

procedure TDACDBGridScrollStyleHook.DrawVertScroll(DC: HDC);
begin
  if DACScrollHighContrastEnabled then
    inherited
  else
    DrawScroll(DC, VertScrollRect, VertSliderRect, VertUpButtonRect,
      VertDownButtonRect, VertSliderState, VertUpState, VertDownState, True);
end;

end.
