unit DAC.Components.Skia.ScrollBarRenderer;

interface

uses
  System.Types,
  System.UITypes,
  Winapi.Windows,
  Vcl.Controls,
  Vcl.Themes,
  DAC.Components.DesignSystem.ControlTokens;

type
  TDACScrollHookAxis = (shaHorizontal, shaVertical);
  TDACScrollPaintSource = (spsStyleHook, spsNativeFallback);
  TDACScrollCoordinateSpace = (scsStyleHookWindowDC, scsControlWindowDC);
  TDACScrollVisualProfile = (svpLegacy, svpMaxxRuralMD);

  TDACNativeScrollGeometry = record
    Available: Boolean;
    ScrollRect: TRect;
    SliderRect: TRect;
    StartButtonRect: TRect;
    EndButtonRect: TRect;
    SliderStateFlags: DWORD;
    StartButtonStateFlags: DWORD;
    EndButtonStateFlags: DWORD;
  end;

  TDACScrollHookPaintInfo = record
    Axis: TDACScrollHookAxis;
    Profile: TDACScrollVisualProfile;
    Source: TDACScrollPaintSource;
    CoordinateSpace: TDACScrollCoordinateSpace;
    ControlHandle: HWND;
    TargetWindow: HWND;
    Enabled: Boolean;
    ScrollRect: TRect;
    SliderRect: TRect;
    VisualTrackRect: TRect;
    VisualSliderRect: TRect;
    StartButtonRect: TRect;
    EndButtonRect: TRect;
    SliderState: TThemedScrollBar;
    StartButtonState: TThemedScrollBar;
    EndButtonState: TThemedScrollBar;
    TrackColor: TAlphaColor;
    SliderColor: TAlphaColor;
    DisabledColor: TAlphaColor;
    StartButtonColor: TAlphaColor;
    EndButtonColor: TAlphaColor;
    ArrowColor: TAlphaColor;
    BorderColor: TAlphaColor;
    RenderedWithSkia: Boolean;
    PresentedWithBitBlt: Boolean;
  end;

  TDACScrollHookPaintObserver = procedure(
    const AInfo: TDACScrollHookPaintInfo);

procedure SetDACScrollPaintObserver(
  const AObserver: TDACScrollHookPaintObserver);
procedure RenderDACScroll(const AControl: TWinControl; const ADC: HDC;
  const AScrollRect, ASliderRect, AStartButtonRect, AEndButtonRect: TRect;
  const ASliderState, AStartButtonState,
  AEndButtonState: TThemedScrollBar; const AVertical: Boolean;
  const ATokens: TDACControlTokens; const ASource: TDACScrollPaintSource;
  const ACoordinateSpace: TDACScrollCoordinateSpace);
procedure RenderDACScrollProfile(const AControl: TWinControl; const ADC: HDC;
  const AScrollRect, ASliderRect, AStartButtonRect, AEndButtonRect: TRect;
  const ASliderState, AStartButtonState,
  AEndButtonState: TThemedScrollBar; const AVertical: Boolean;
  const ATokens: TDACControlTokens; const ASource: TDACScrollPaintSource;
  const ACoordinateSpace: TDACScrollCoordinateSpace;
  const AProfile: TDACScrollVisualProfile; const ASurfaceColor: TAlphaColor);
procedure RenderDACScrollCorner(const AControl: TWinControl; const ADC: HDC;
  const ACornerRect: TRect; const ATokens: TDACControlTokens);
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

uses
  System.Math,
  System.SysUtils,
  System.Skia,
  Vcl.Graphics,
  Vcl.Skia,
  DAC.Components.Skia.Renderer;

const
  DACNativeObjectIdHScroll = -6;
  DACNativeObjectIdVScroll = -5;
  DACNativeHorizontalPainted = 1;
  DACNativeVerticalPainted = 2;

var
  GDACScrollPaintObserver: TDACScrollHookPaintObserver;
  GDACScrollPaintObserverActive: Boolean;
  GDACScrollBitmap: TBitmap;
  GDACScrollBitmapActive: Boolean;
  GDACScrollRenderer: TDACSkiaRenderer;

type
  TDACScrollControlAccess = class(TWinControl);

function DACScrollRenderer: TDACSkiaRenderer;
begin
  if GDACScrollRenderer = nil then
    GDACScrollRenderer := TDACSkiaRenderer.Create;
  Result := GDACScrollRenderer;
end;

function DACScrollMetric(const AControl: TWinControl;
  const AValue: Single): Single;
begin
  if AControl = nil then
    Result := AValue
  else
    Result := AValue * Max(USER_DEFAULT_SCREEN_DPI,
      TDACScrollControlAccess(AControl).FCurrentPPI) /
      USER_DEFAULT_SCREEN_DPI;
end;

procedure DACScaleScrollMetrics(const AControl: TWinControl;
  var ATokens: TDACControlTokens);
begin
  ATokens.ScrollBarTrackThickness := DACScrollMetric(AControl,
    ATokens.ScrollBarTrackThickness);
  ATokens.ScrollBarThumbThickness := DACScrollMetric(AControl,
    ATokens.ScrollBarThumbThickness);
  ATokens.ScrollBarTrackRadius := DACScrollMetric(AControl,
    ATokens.ScrollBarTrackRadius);
  ATokens.ScrollBarThumbRadius := DACScrollMetric(AControl,
    ATokens.ScrollBarThumbRadius);
  ATokens.ScrollBarBorderWidth := DACScrollMetric(AControl,
    ATokens.ScrollBarBorderWidth);
  ATokens.ScrollBarArrowStrokeWidth := DACScrollMetric(AControl,
    ATokens.ScrollBarArrowStrokeWidth);
  ATokens.ScrollBarArrowInset := DACScrollMetric(AControl,
    ATokens.ScrollBarArrowInset);
end;

function DACAcquireScrollBitmap(const AWidth, AHeight: Integer;
  out ATemporary: Boolean): TBitmap;
begin
  ATemporary := GDACScrollBitmapActive;
  if ATemporary then
  begin
    Result := TBitmap.Create;
    try
      Result.PixelFormat := pf32bit;
      Result.SetSize(Max(1, AWidth), Max(1, AHeight));
    except
      Result.Free;
      raise;
    end;
  end
  else
  begin
    if GDACScrollBitmap = nil then
    begin
      GDACScrollBitmap := TBitmap.Create;
      GDACScrollBitmap.PixelFormat := pf32bit;
    end;
    Result := GDACScrollBitmap;
    Result.SetSize(Max(1, AWidth), Max(1, AHeight));
    GDACScrollBitmapActive := True;
  end;
end;

procedure DACReleaseScrollBitmap(var ABitmap: TBitmap;
  const ATemporary: Boolean);
begin
  if ATemporary then
    FreeAndNil(ABitmap)
  else
  begin
    ABitmap := nil;
    GDACScrollBitmapActive := False;
  end;
end;

function DACScrollHighContrastEnabled: Boolean;
var
  LHighContrast: HIGHCONTRAST;
begin
  FillChar(LHighContrast, SizeOf(LHighContrast), 0);
  LHighContrast.cbSize := SizeOf(LHighContrast);
  Result := SystemParametersInfo(SPI_GETHIGHCONTRAST,
    SizeOf(LHighContrast), @LHighContrast, 0) and
    ((LHighContrast.dwFlags and HCF_HIGHCONTRASTON) <> 0);
end;

procedure SetDACScrollPaintObserver(
  const AObserver: TDACScrollHookPaintObserver);
begin
  GDACScrollPaintObserver := AObserver;
end;

procedure DACNotifyScrollPaint(const AInfo: TDACScrollHookPaintInfo);
var
  LObserver: TDACScrollHookPaintObserver;
begin
  if GDACScrollPaintObserverActive then
    Exit;
  LObserver := GDACScrollPaintObserver;
  if not Assigned(LObserver) then
    Exit;
  GDACScrollPaintObserverActive := True;
  try
    LObserver(AInfo);
  finally
    GDACScrollPaintObserverActive := False;
  end;
end;

function DACScrollPartColor(const AControl: TWinControl;
  const AState: TThemedScrollBar;
  const ATokens: TDACControlTokens): TAlphaColor;
begin
  if (AControl = nil) or not AControl.Enabled then
    Result := ATokens.ScrollBarThumbDisabled
  else if AState in [
    tsArrowBtnUpPressed, tsArrowBtnDownPressed,
    tsArrowBtnLeftPressed, tsArrowBtnRightPressed,
    tsThumbBtnHorzPressed, tsThumbBtnVertPressed,
    tsLowerTrackHorzPressed, tsUpperTrackHorzPressed,
    tsLowerTrackVertPressed, tsUpperTrackVertPressed] then
    Result := ATokens.ScrollBarThumbPressed
  else if AState in [
    tsArrowBtnUpHot, tsArrowBtnDownHot,
    tsArrowBtnLeftHot, tsArrowBtnRightHot,
    tsArrowBtnUpHover, tsArrowBtnDownHover,
    tsArrowBtnLeftHover, tsArrowBtnRightHover,
    tsThumbBtnHorzHot, tsThumbBtnVertHot,
    tsLowerTrackHorzHot, tsUpperTrackHorzHot,
    tsLowerTrackHorzHover, tsUpperTrackHorzHover,
    tsLowerTrackVertHot, tsUpperTrackVertHot,
    tsLowerTrackVertHover, tsUpperTrackVertHover] then
    Result := ATokens.ScrollBarThumbHot
  else
    Result := ATokens.ScrollBarThumb;
end;

function DACLegacyScrollTokens(
  const ATokens: TDACControlTokens): TDACControlTokens;
begin
  Result := ATokens;
  Result.ScrollBarTrack := ATokens.ScrollContainerViewportBackground;
  Result.ScrollBarThumb := ATokens.TabsDivider;
  Result.ScrollBarThumbHot := ATokens.InputFocus;
  Result.ScrollBarThumbPressed := ATokens.Success;
  Result.ScrollBarThumbDisabled := ATokens.TabsTextDisabled;
  Result.ScrollBarArrow := ATokens.TabsTextDefault;
  Result.ScrollBarBorder := ATokens.TabsDivider;
  Result.ScrollBarTrackThickness := 0;
  Result.ScrollBarThumbThickness := 0;
  Result.ScrollBarTrackRadius := 0;
  Result.ScrollBarThumbRadius := 4;
end;

function DACScrollStateDisabled(const AState: TThemedScrollBar): Boolean;
begin
  Result := AState in [
    tsArrowBtnUpDisabled, tsArrowBtnDownDisabled,
    tsArrowBtnLeftDisabled, tsArrowBtnRightDisabled,
    tsThumbBtnHorzDisabled, tsThumbBtnVertDisabled,
    tsLowerTrackHorzDisabled, tsUpperTrackHorzDisabled,
    tsLowerTrackVertDisabled, tsUpperTrackVertDisabled];
end;

function DACScrollArrowColor(const AControl: TWinControl;
  const AState: TThemedScrollBar;
  const ATokens: TDACControlTokens): TAlphaColor;
begin
  if (AControl = nil) or not AControl.Enabled or
    DACScrollStateDisabled(AState) then
    Result := ATokens.ScrollBarThumbDisabled
  else if AState in [
    tsArrowBtnUpPressed, tsArrowBtnDownPressed,
    tsArrowBtnLeftPressed, tsArrowBtnRightPressed] then
    Result := ATokens.ScrollBarThumbPressed
  else if AState in [
    tsArrowBtnUpHot, tsArrowBtnDownHot,
    tsArrowBtnLeftHot, tsArrowBtnRightHot,
    tsArrowBtnUpHover, tsArrowBtnDownHover,
    tsArrowBtnLeftHover, tsArrowBtnRightHover] then
    Result := ATokens.ScrollBarThumbHot
  else
    Result := ATokens.ScrollBarArrow;
end;

procedure DACDrawScrollArrow(const ACanvas: ISkCanvas;
  const ARect: TRectF; const AVertical, APositive: Boolean;
  const AColor: TAlphaColor; const ATokens: TDACControlTokens);
var
  LCenter: TPointF;
  LHalf: Single;
  LPaint: ISkPaint;
  LStart: TPointF;
  LMiddle: TPointF;
  LFinish: TPointF;
begin
  if (ACanvas = nil) or (ARect.Width <= 0) or (ARect.Height <= 0) then
    Exit;
  LPaint := TSkPaint.Create(TSkPaintStyle.Stroke);
  LPaint.AntiAlias := True;
  LPaint.Color := AColor;
  LPaint.StrokeWidth := ATokens.ScrollBarArrowStrokeWidth;
  LPaint.StrokeCap := TSkStrokeCap.Round;
  LPaint.StrokeJoin := TSkStrokeJoin.Round;
  LCenter := PointF((ARect.Left + ARect.Right) / 2,
    (ARect.Top + ARect.Bottom) / 2);
  LHalf := Max(2, (Min(ARect.Width, ARect.Height) -
    (ATokens.ScrollBarArrowInset * 2)) / 2);
  if AVertical then
  begin
    if APositive then
    begin
      LStart := PointF(LCenter.X - LHalf, LCenter.Y - LHalf);
      LMiddle := PointF(LCenter.X, LCenter.Y + LHalf);
      LFinish := PointF(LCenter.X + LHalf, LCenter.Y - LHalf);
    end
    else
    begin
      LStart := PointF(LCenter.X - LHalf, LCenter.Y + LHalf);
      LMiddle := PointF(LCenter.X, LCenter.Y - LHalf);
      LFinish := PointF(LCenter.X + LHalf, LCenter.Y + LHalf);
    end;
  end
  else if APositive then
  begin
    LStart := PointF(LCenter.X - LHalf, LCenter.Y - LHalf);
    LMiddle := PointF(LCenter.X + LHalf, LCenter.Y);
    LFinish := PointF(LCenter.X - LHalf, LCenter.Y + LHalf);
  end
  else
  begin
    LStart := PointF(LCenter.X + LHalf, LCenter.Y - LHalf);
    LMiddle := PointF(LCenter.X - LHalf, LCenter.Y);
    LFinish := PointF(LCenter.X + LHalf, LCenter.Y + LHalf);
  end;
  ACanvas.DrawLine(LStart, LMiddle, LPaint);
  ACanvas.DrawLine(LMiddle, LFinish, LPaint);
end;

procedure RenderDACScroll(const AControl: TWinControl; const ADC: HDC;
  const AScrollRect, ASliderRect, AStartButtonRect, AEndButtonRect: TRect;
  const ASliderState, AStartButtonState,
  AEndButtonState: TThemedScrollBar; const AVertical: Boolean;
  const ATokens: TDACControlTokens; const ASource: TDACScrollPaintSource;
  const ACoordinateSpace: TDACScrollCoordinateSpace);
begin
  RenderDACScrollProfile(AControl, ADC, AScrollRect, ASliderRect,
    AStartButtonRect, AEndButtonRect, ASliderState, AStartButtonState,
    AEndButtonState, AVertical, ATokens, ASource, ACoordinateSpace,
    svpLegacy, ATokens.ScrollContainerViewportBackground);
end;

procedure RenderDACScrollProfile(const AControl: TWinControl; const ADC: HDC;
  const AScrollRect, ASliderRect, AStartButtonRect, AEndButtonRect: TRect;
  const ASliderState, AStartButtonState,
  AEndButtonState: TThemedScrollBar; const AVertical: Boolean;
  const ATokens: TDACControlTokens; const ASource: TDACScrollPaintSource;
  const ACoordinateSpace: TDACScrollCoordinateSpace;
  const AProfile: TDACScrollVisualProfile; const ASurfaceColor: TAlphaColor);
var
  LBitmap: TBitmap;
  LBorderInset: Single;
  LBorderRect: TRectF;
  LEndArrowColor: TAlphaColor;
  LEndRect: TRectF;
  LInfo: TDACScrollHookPaintInfo;
  LPresented: Boolean;
  LSliderRect: TRectF;
  LSliderVisible: Boolean;
  LStartArrowColor: TAlphaColor;
  LStartRect: TRectF;
  LSurfaceColor: TAlphaColor;
  LTemporaryBitmap: Boolean;
  LTokens: TDACControlTokens;
  LTrackColor: TAlphaColor;
  LTrackRadius: Single;
  LTrackRect: TRectF;
  LTrackThickness: Single;
  LThumbRadius: Single;
  LThumbThickness: Single;
  LEffectiveEndState: TThemedScrollBar;
  LEffectiveSliderState: TThemedScrollBar;
  LEffectiveStartState: TThemedScrollBar;
begin
  if (AControl = nil) or (ADC = 0) or IsRectEmpty(AScrollRect) then
    Exit;
  LEffectiveSliderState := ASliderState;
  if AProfile = svpLegacy then
    LTokens := DACLegacyScrollTokens(ATokens)
  else
  begin
    LTokens := ATokens;
    DACScaleScrollMetrics(AControl, LTokens);
  end;
  LEffectiveStartState := AStartButtonState;
  LEffectiveEndState := AEndButtonState;
  if not AControl.Enabled then
  begin
    if AVertical then
    begin
      LEffectiveSliderState := tsThumbBtnVertDisabled;
      LEffectiveStartState := tsArrowBtnUpDisabled;
      LEffectiveEndState := tsArrowBtnDownDisabled;
    end
    else
    begin
      LEffectiveSliderState := tsThumbBtnHorzDisabled;
      LEffectiveStartState := tsArrowBtnLeftDisabled;
      LEffectiveEndState := tsArrowBtnRightDisabled;
    end;
  end;

  LSliderRect := TRectF.Create(ASliderRect.Left - AScrollRect.Left,
    ASliderRect.Top - AScrollRect.Top, ASliderRect.Right - AScrollRect.Left,
    ASliderRect.Bottom - AScrollRect.Top);
  LStartRect := TRectF.Create(AStartButtonRect.Left - AScrollRect.Left,
    AStartButtonRect.Top - AScrollRect.Top,
    AStartButtonRect.Right - AScrollRect.Left,
    AStartButtonRect.Bottom - AScrollRect.Top);
  LEndRect := TRectF.Create(AEndButtonRect.Left - AScrollRect.Left,
    AEndButtonRect.Top - AScrollRect.Top,
    AEndButtonRect.Right - AScrollRect.Left,
    AEndButtonRect.Bottom - AScrollRect.Top);
  LTrackRect := TRectF.Create(0, 0, AScrollRect.Width, AScrollRect.Height);
  LBorderInset := Max(0, LTokens.ScrollBarBorderWidth / 2);

  if AProfile = svpMaxxRuralMD then
  begin
    if AVertical then
    begin
      LTrackThickness := Min(LTokens.ScrollBarTrackThickness,
        AScrollRect.Width);
      LThumbThickness := Min(LTokens.ScrollBarThumbThickness,
        LTrackThickness);
      LTrackRect.Left := (AScrollRect.Width - LTrackThickness) / 2;
      LTrackRect.Right := LTrackRect.Left + LTrackThickness;
      LSliderRect.Left := (AScrollRect.Width - LThumbThickness) / 2;
      LSliderRect.Right := LSliderRect.Left + LThumbThickness;
    end
    else
    begin
      LTrackThickness := Min(LTokens.ScrollBarTrackThickness,
        AScrollRect.Height);
      LThumbThickness := Min(LTokens.ScrollBarThumbThickness,
        LTrackThickness);
      LTrackRect.Top := (AScrollRect.Height - LTrackThickness) / 2;
      LTrackRect.Bottom := LTrackRect.Top + LTrackThickness;
      LSliderRect.Top := (AScrollRect.Height - LThumbThickness) / 2;
      LSliderRect.Bottom := LSliderRect.Top + LThumbThickness;
    end;
    LBorderRect := LTrackRect;
    LBorderRect.Inflate(-LBorderInset, -LBorderInset);
    LSurfaceColor := ASurfaceColor;
  end
  else
  begin
    LBorderRect := TRectF.Create(LBorderInset, LBorderInset,
      Max(LBorderInset, AScrollRect.Width - LBorderInset),
      Max(LBorderInset, AScrollRect.Height - LBorderInset));
    LSurfaceColor := LTokens.ScrollBarTrack;
  end;

  LSliderVisible := (LSliderRect.Width > 0) and (LSliderRect.Height > 0) and
    (not DACScrollStateDisabled(LEffectiveSliderState) or
      not AControl.Enabled);
  if (AProfile = svpMaxxRuralMD) and
      (not AControl.Enabled or
       DACScrollStateDisabled(LEffectiveSliderState)) then
    LTrackColor := LTokens.ScrollBarThumbDisabled
  else
    LTrackColor := LTokens.ScrollBarTrack;
  if AProfile = svpMaxxRuralMD then
  begin
    LTrackRadius := Min(LTokens.ScrollBarTrackRadius,
      Min(LTrackRect.Width, LTrackRect.Height) / 2);
    LThumbRadius := Min(LTokens.ScrollBarThumbRadius,
      Min(LSliderRect.Width, LSliderRect.Height) / 2);
  end
  else
  begin
    LTrackRadius := 0;
    LThumbRadius := LTokens.ScrollBarThumbRadius;
  end;
  LStartArrowColor := DACScrollArrowColor(AControl, LEffectiveStartState,
    LTokens);
  LEndArrowColor := DACScrollArrowColor(AControl, LEffectiveEndState,
    LTokens);
  LBitmap := DACAcquireScrollBitmap(AScrollRect.Width, AScrollRect.Height,
    LTemporaryBitmap);
  try
    LBitmap.SkiaDraw(
      procedure(const ACanvas: ISkCanvas)
      begin
        ACanvas.Clear(LSurfaceColor);
        if AProfile = svpMaxxRuralMD then
        begin
          DACScrollRenderer.FillRoundRect(ACanvas, LTrackRect,
            LTrackColor, LTrackRadius);
          DACScrollRenderer.StrokeRoundRect(ACanvas, LBorderRect,
            LTokens.ScrollBarBorder, LTrackRadius,
            LTokens.ScrollBarBorderWidth);
        end;
        if LSliderVisible then
          DACScrollRenderer.FillRoundRect(ACanvas, LSliderRect,
            DACScrollPartColor(AControl, LEffectiveSliderState, LTokens),
            LThumbRadius);
        if (LStartRect.Width > 0) and (LStartRect.Height > 0) then
        begin
          if AProfile = svpLegacy then
            DACScrollRenderer.FillRoundRect(ACanvas, LStartRect,
              DACScrollPartColor(AControl, LEffectiveStartState, LTokens), 0);
          DACDrawScrollArrow(ACanvas, LStartRect, AVertical, False,
            LStartArrowColor, LTokens);
        end;
        if (LEndRect.Width > 0) and (LEndRect.Height > 0) then
        begin
          if AProfile = svpLegacy then
            DACScrollRenderer.FillRoundRect(ACanvas, LEndRect,
              DACScrollPartColor(AControl, LEffectiveEndState, LTokens), 0);
          DACDrawScrollArrow(ACanvas, LEndRect, AVertical, True,
            LEndArrowColor, LTokens);
        end;
        if AProfile = svpLegacy then
          DACScrollRenderer.StrokeRoundRect(ACanvas, LBorderRect,
            LTokens.ScrollBarBorder, 0, LTokens.ScrollBarBorderWidth);
      end);
    LPresented := BitBlt(ADC, AScrollRect.Left, AScrollRect.Top,
      LBitmap.Width, LBitmap.Height, LBitmap.Canvas.Handle, 0, 0, SRCCOPY);
    if Assigned(GDACScrollPaintObserver) then
    begin
      FillChar(LInfo, SizeOf(LInfo), 0);
      LInfo.Profile := AProfile;
      LInfo.Source := ASource;
      LInfo.CoordinateSpace := ACoordinateSpace;
      LInfo.ControlHandle := AControl.Handle;
      LInfo.TargetWindow := WindowFromDC(ADC);
      if AVertical then LInfo.Axis := shaVertical
      else LInfo.Axis := shaHorizontal;
      LInfo.Enabled := AControl.Enabled;
      LInfo.ScrollRect := AScrollRect;
      LInfo.SliderRect := ASliderRect;
      LInfo.VisualTrackRect := Rect(Round(LTrackRect.Left) + AScrollRect.Left,
        Round(LTrackRect.Top) + AScrollRect.Top,
        Round(LTrackRect.Right) + AScrollRect.Left,
        Round(LTrackRect.Bottom) + AScrollRect.Top);
      if LSliderVisible then
        LInfo.VisualSliderRect := Rect(
          Round(LSliderRect.Left) + AScrollRect.Left,
          Round(LSliderRect.Top) + AScrollRect.Top,
          Round(LSliderRect.Right) + AScrollRect.Left,
          Round(LSliderRect.Bottom) + AScrollRect.Top);
      LInfo.StartButtonRect := AStartButtonRect;
      LInfo.EndButtonRect := AEndButtonRect;
      LInfo.SliderState := LEffectiveSliderState;
      LInfo.StartButtonState := LEffectiveStartState;
      LInfo.EndButtonState := LEffectiveEndState;
      LInfo.TrackColor := LTrackColor;
      LInfo.SliderColor := DACScrollPartColor(AControl,
        LEffectiveSliderState, LTokens);
      LInfo.DisabledColor := LTokens.ScrollBarThumbDisabled;
      if AProfile = svpLegacy then
      begin
        LInfo.StartButtonColor := DACScrollPartColor(AControl,
          LEffectiveStartState, LTokens);
        LInfo.EndButtonColor := DACScrollPartColor(AControl,
          LEffectiveEndState, LTokens);
      end
      else
      begin
        LInfo.StartButtonColor := LStartArrowColor;
        LInfo.EndButtonColor := LEndArrowColor;
      end;
      if AControl.Enabled then
        LInfo.ArrowColor := LTokens.ScrollBarArrow
      else
        LInfo.ArrowColor := LTokens.ScrollBarThumbDisabled;
      LInfo.BorderColor := LTokens.ScrollBarBorder;
      LInfo.RenderedWithSkia := True;
      LInfo.PresentedWithBitBlt := LPresented;
      DACNotifyScrollPaint(LInfo);
    end;
  finally
    DACReleaseScrollBitmap(LBitmap, LTemporaryBitmap);
  end;
end;

procedure RenderDACScrollCorner(const AControl: TWinControl; const ADC: HDC;
  const ACornerRect: TRect; const ATokens: TDACControlTokens);
begin
  RenderDACScrollCornerProfile(AControl, ADC, ACornerRect, ATokens,
    svpLegacy, ATokens.ScrollContainerViewportBackground);
end;

procedure RenderDACScrollCornerProfile(const AControl: TWinControl;
  const ADC: HDC; const ACornerRect: TRect;
  const ATokens: TDACControlTokens; const AProfile: TDACScrollVisualProfile;
  const ASurfaceColor: TAlphaColor);
var
  LBitmap: TBitmap;
  LBorderInset: Single;
  LBorderRect: TRectF;
  LHorizontalRect: TRectF;
  LIsRTL: Boolean;
  LTemporaryBitmap: Boolean;
  LTokens: TDACControlTokens;
  LTrackColor: TAlphaColor;
  LTrackRadius: Single;
  LTrackThickness: Single;
  LVerticalRect: TRectF;
begin
  if (AControl = nil) or (ADC = 0) or IsRectEmpty(ACornerRect) then
    Exit;
  if AProfile = svpLegacy then
    LTokens := DACLegacyScrollTokens(ATokens)
  else
  begin
    LTokens := ATokens;
    DACScaleScrollMetrics(AControl, LTokens);
  end;
  if (AProfile = svpMaxxRuralMD) and not AControl.Enabled then
    LTrackColor := LTokens.ScrollBarThumbDisabled
  else
    LTrackColor := LTokens.ScrollBarTrack;
  LBitmap := DACAcquireScrollBitmap(ACornerRect.Width, ACornerRect.Height,
    LTemporaryBitmap);
  try
    LBorderInset := Max(0, LTokens.ScrollBarBorderWidth / 2);
    LBorderRect := TRectF.Create(LBorderInset, LBorderInset,
      Max(LBorderInset, ACornerRect.Width - LBorderInset),
      Max(LBorderInset, ACornerRect.Height - LBorderInset));
  LTrackThickness := Min(LTokens.ScrollBarTrackThickness,
      Min(ACornerRect.Width, ACornerRect.Height));
    LTrackRadius := Min(LTokens.ScrollBarTrackRadius,
      LTrackThickness / 2);
    LVerticalRect := TRectF.Create(
      (ACornerRect.Width - LTrackThickness) / 2, 0,
      (ACornerRect.Width + LTrackThickness) / 2,
      (ACornerRect.Height + LTrackThickness) / 2);
    LIsRTL := (GetWindowLong(AControl.Handle, GWL_EXSTYLE) and
      WS_EX_LAYOUTRTL) <> 0;
    if LIsRTL then
      LHorizontalRect := TRectF.Create(
        (ACornerRect.Width - LTrackThickness) / 2,
        (ACornerRect.Height - LTrackThickness) / 2,
        ACornerRect.Width,
        (ACornerRect.Height + LTrackThickness) / 2)
    else
      LHorizontalRect := TRectF.Create(0,
        (ACornerRect.Height - LTrackThickness) / 2,
        (ACornerRect.Width + LTrackThickness) / 2,
        (ACornerRect.Height + LTrackThickness) / 2);
    LBitmap.SkiaDraw(
      procedure(const ACanvas: ISkCanvas)
      begin
        if AProfile = svpMaxxRuralMD then
        begin
          ACanvas.Clear(ASurfaceColor);
          DACScrollRenderer.FillRoundRect(ACanvas, LVerticalRect,
            LTrackColor, LTrackRadius);
          DACScrollRenderer.FillRoundRect(ACanvas, LHorizontalRect,
            LTrackColor, LTrackRadius);
        end
        else
        begin
          ACanvas.Clear(LTokens.ScrollBarTrack);
          DACScrollRenderer.StrokeRoundRect(ACanvas, LBorderRect,
            LTokens.ScrollBarBorder, 0, LTokens.ScrollBarBorderWidth);
        end;
      end);
    BitBlt(ADC, ACornerRect.Left, ACornerRect.Top, LBitmap.Width,
      LBitmap.Height, LBitmap.Canvas.Handle, 0, 0, SRCCOPY);
  finally
    DACReleaseScrollBitmap(LBitmap, LTemporaryBitmap);
  end;
end;

function NativeAxisState(const AControl: TWinControl;
  const ARect: TRect; const AVertical, ASlider, APositive,
  AAvailable: Boolean; const AStateFlags: DWORD): TThemedScrollBar;
var
  LCursor: TPoint;
  LHot: Boolean;
  LPressed: Boolean;
begin
  if not AAvailable or
      ((AStateFlags and STATE_SYSTEM_UNAVAILABLE) <> 0) then
  begin
    if ASlider then
      if AVertical then
        Exit(tsThumbBtnVertDisabled)
      else
        Exit(tsThumbBtnHorzDisabled)
    else if AVertical then
      if APositive then
        Exit(tsArrowBtnDownDisabled)
      else
        Exit(tsArrowBtnUpDisabled)
    else if APositive then
      Exit(tsArrowBtnRightDisabled)
    else
      Exit(tsArrowBtnLeftDisabled);
  end;
  GetCursorPos(LCursor);
  LHot := ((AStateFlags and STATE_SYSTEM_HOTTRACKED) <> 0) or
    PtInRect(ARect, LCursor);
  LPressed := ((AStateFlags and STATE_SYSTEM_PRESSED) <> 0) or
    (LHot and (GetKeyState(VK_LBUTTON) < 0));
  if ASlider then
    if AVertical then
      if LPressed then Result := tsThumbBtnVertPressed
      else if LHot then Result := tsThumbBtnVertHot
      else Result := tsThumbBtnVertNormal
    else
      if LPressed then Result := tsThumbBtnHorzPressed
      else if LHot then Result := tsThumbBtnHorzHot
      else Result := tsThumbBtnHorzNormal
  else if AVertical then
    if APositive then
      if LPressed then Result := tsArrowBtnDownPressed
      else if LHot then Result := tsArrowBtnDownHot
      else Result := tsArrowBtnDownNormal
    else
      if LPressed then Result := tsArrowBtnUpPressed
      else if LHot then Result := tsArrowBtnUpHot
      else Result := tsArrowBtnUpNormal
  else if APositive then
    if LPressed then Result := tsArrowBtnRightPressed
    else if LHot then Result := tsArrowBtnRightHot
    else Result := tsArrowBtnRightNormal
  else
    if LPressed then Result := tsArrowBtnLeftPressed
    else if LHot then Result := tsArrowBtnLeftHot
    else Result := tsArrowBtnLeftNormal;
end;

function ResolveDACNativeScrollGeometry(const AInfo: TScrollBarInfo;
  const AWindowRect: TRect; const AClientOrigin: TPoint;
  const AVertical: Boolean; out AGeometry: TDACNativeScrollGeometry): Boolean;
var
  LButtonExtent: Integer;
  LClientDelta: TPoint;
  LThumbEnd: Integer;
  LThumbStart: Integer;
  LTrackEnd: Integer;
  LTrackStart: Integer;
begin
  FillChar(AGeometry, SizeOf(AGeometry), 0);
  Result := ((AInfo.rgstate[0] and STATE_SYSTEM_INVISIBLE) = 0) and
    not IsRectEmpty(AInfo.rcScrollBar) and not IsRectEmpty(AWindowRect);
  if not Result then
    Exit;

  AGeometry.Available :=
    (AInfo.rgstate[0] and STATE_SYSTEM_UNAVAILABLE) = 0;
  AGeometry.StartButtonStateFlags := AInfo.rgstate[1];
  AGeometry.SliderStateFlags := AInfo.rgstate[3];
  AGeometry.EndButtonStateFlags := AInfo.rgstate[5];
  AGeometry.ScrollRect := AInfo.rcScrollBar;
  OffsetRect(AGeometry.ScrollRect, -AWindowRect.Left, -AWindowRect.Top);
  if IsRectEmpty(AGeometry.ScrollRect) then
    Exit(False);

  AGeometry.StartButtonRect := AGeometry.ScrollRect;
  AGeometry.EndButtonRect := AGeometry.ScrollRect;
  AGeometry.SliderRect := AGeometry.ScrollRect;
  LClientDelta := Point(AClientOrigin.X - AWindowRect.Left,
    AClientOrigin.Y - AWindowRect.Top);
  if AVertical then
  begin
    LButtonExtent := EnsureRange(AInfo.dxyLineButton, 0,
      AGeometry.ScrollRect.Height div 2);
    AGeometry.StartButtonRect.Bottom :=
      AGeometry.StartButtonRect.Top + LButtonExtent;
    AGeometry.EndButtonRect.Top :=
      AGeometry.EndButtonRect.Bottom - LButtonExtent;
    LTrackStart := AGeometry.StartButtonRect.Bottom;
    LTrackEnd := AGeometry.EndButtonRect.Top;
    if AGeometry.Available then
    begin
      LThumbStart := EnsureRange(LClientDelta.Y + AInfo.xyThumbTop,
        LTrackStart, LTrackEnd);
      LThumbEnd := EnsureRange(LClientDelta.Y + AInfo.xyThumbBottom,
        LThumbStart, LTrackEnd);
    end
    else
    begin
      LThumbStart := LTrackStart;
      LThumbEnd := LTrackStart;
    end;
    AGeometry.SliderRect.Top := LThumbStart;
    AGeometry.SliderRect.Bottom := LThumbEnd;
  end
  else
  begin
    LButtonExtent := EnsureRange(AInfo.dxyLineButton, 0,
      AGeometry.ScrollRect.Width div 2);
    AGeometry.StartButtonRect.Right :=
      AGeometry.StartButtonRect.Left + LButtonExtent;
    AGeometry.EndButtonRect.Left :=
      AGeometry.EndButtonRect.Right - LButtonExtent;
    LTrackStart := AGeometry.StartButtonRect.Right;
    LTrackEnd := AGeometry.EndButtonRect.Left;
    if AGeometry.Available then
    begin
      LThumbStart := EnsureRange(LClientDelta.X + AInfo.xyThumbTop,
        LTrackStart, LTrackEnd);
      LThumbEnd := EnsureRange(LClientDelta.X + AInfo.xyThumbBottom,
        LThumbStart, LTrackEnd);
    end
    else
    begin
      LThumbStart := LTrackStart;
      LThumbEnd := LTrackStart;
    end;
    AGeometry.SliderRect.Left := LThumbStart;
    AGeometry.SliderRect.Right := LThumbEnd;
  end;
end;

function PaintDACNativeAxis(const AControl: TWinControl; const ADC: HDC;
  const AVertical: Boolean; const ATokens: TDACControlTokens;
  const AProfile: TDACScrollVisualProfile; const ASurfaceColor: TAlphaColor;
  out AGeometry: TDACNativeScrollGeometry): Boolean;
var
  LClientOrigin: TPoint;
  LClipRect: TRect;
  LClipType: Integer;
  LInfo: TScrollBarInfo;
  LIntersection: TRect;
  LObjectId: Integer;
  LWindowRect: TRect;
  LScreenEndRect: TRect;
  LScreenSliderRect: TRect;
  LScreenStartRect: TRect;
begin
  Result := False;
  FillChar(AGeometry, SizeOf(AGeometry), 0);
  FillChar(LInfo, SizeOf(LInfo), 0);
  LInfo.cbSize := SizeOf(LInfo);
  if AVertical then LObjectId := DACNativeObjectIdVScroll
  else LObjectId := DACNativeObjectIdHScroll;
  if not GetScrollBarInfo(AControl.Handle, LObjectId, LInfo) then
    Exit;
  if not GetWindowRect(AControl.Handle, LWindowRect) then
    Exit;
  LClientOrigin := Point(0, 0);
  if not ClientToScreen(AControl.Handle, LClientOrigin) then
    Exit;
  if not ResolveDACNativeScrollGeometry(LInfo, LWindowRect, LClientOrigin,
      AVertical, AGeometry) then
    Exit;
  LClipType := GetClipBox(ADC, LClipRect);
  if (LClipType = ERROR) or (LClipType = NULLREGION) or
    not IntersectRect(LIntersection, AGeometry.ScrollRect, LClipRect) then
    Exit;
  LScreenStartRect := AGeometry.StartButtonRect;
  LScreenEndRect := AGeometry.EndButtonRect;
  LScreenSliderRect := AGeometry.SliderRect;
  OffsetRect(LScreenStartRect, LWindowRect.Left, LWindowRect.Top);
  OffsetRect(LScreenEndRect, LWindowRect.Left, LWindowRect.Top);
  OffsetRect(LScreenSliderRect, LWindowRect.Left, LWindowRect.Top);
  RenderDACScrollProfile(AControl, ADC, AGeometry.ScrollRect,
    AGeometry.SliderRect, AGeometry.StartButtonRect,
    AGeometry.EndButtonRect,
    NativeAxisState(AControl, LScreenSliderRect, AVertical, True, False,
      AGeometry.Available, AGeometry.SliderStateFlags),
    NativeAxisState(AControl, LScreenStartRect, AVertical, False, False,
      AGeometry.Available, AGeometry.StartButtonStateFlags),
    NativeAxisState(AControl, LScreenEndRect, AVertical, False, True,
      AGeometry.Available, AGeometry.EndButtonStateFlags), AVertical, ATokens,
      spsNativeFallback,
      scsControlWindowDC, AProfile, ASurfaceColor);
  Result := True;
end;

function ResolveDACScrollCornerRect(const AHorzScrollRect,
  AVertScrollRect: TRect; out ACornerRect: TRect): Boolean;
begin
  ACornerRect := Rect(0, 0, 0, 0);
  Result := not IsRectEmpty(AHorzScrollRect) and
    not IsRectEmpty(AVertScrollRect);
  if not Result then
    Exit;
  ACornerRect := Rect(AVertScrollRect.Left, AHorzScrollRect.Top,
    AVertScrollRect.Right, AHorzScrollRect.Bottom);
  Result := not IsRectEmpty(ACornerRect);
end;

function PaintDACNativeScrollBars(const AControl: TWinControl;
  const ADC: HDC; const ATokens: TDACControlTokens;
  const APaintCorner: Boolean): Integer;
begin
  Result := PaintDACNativeScrollBarsProfile(AControl, ADC, ATokens,
    APaintCorner, svpLegacy, ATokens.ScrollContainerViewportBackground);
end;

function PaintDACNativeScrollBarsProfile(const AControl: TWinControl;
  const ADC: HDC; const ATokens: TDACControlTokens;
  const APaintCorner: Boolean; const AProfile: TDACScrollVisualProfile;
  const ASurfaceColor: TAlphaColor): Integer;
var
  LCornerRect: TRect;
  LHorzGeometry: TDACNativeScrollGeometry;
  LHorzPainted: Boolean;
  LVertGeometry: TDACNativeScrollGeometry;
  LVertPainted: Boolean;
begin
  Result := 0;
  if (AControl = nil) or (ADC = 0) or not AControl.HandleAllocated or
    ((AProfile = svpMaxxRuralMD) and DACScrollHighContrastEnabled) then
    Exit;
  LHorzPainted := PaintDACNativeAxis(AControl, ADC, False, ATokens,
    AProfile, ASurfaceColor, LHorzGeometry);
  if LHorzPainted then
    Result := Result or DACNativeHorizontalPainted;
  LVertPainted := PaintDACNativeAxis(AControl, ADC, True, ATokens,
    AProfile, ASurfaceColor, LVertGeometry);
  if LVertPainted then
    Result := Result or DACNativeVerticalPainted;
  if APaintCorner and LHorzPainted and LVertPainted and
    ResolveDACScrollCornerRect(LHorzGeometry.ScrollRect,
      LVertGeometry.ScrollRect, LCornerRect) then
    RenderDACScrollCornerProfile(AControl, ADC, LCornerRect, ATokens,
      AProfile, ASurfaceColor);
end;

initialization
  GDACScrollRenderer := nil;
  GDACScrollBitmap := nil;

finalization
  GDACScrollBitmap.Free;
  GDACScrollRenderer.Free;

end.
