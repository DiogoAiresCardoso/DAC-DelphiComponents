unit DAC.Components.Hooks.ScrollRenderer;

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

  TDACNativeScrollGeometry = record
    Available: Boolean;
    ScrollRect: TRect;
    SliderRect: TRect;
    StartButtonRect: TRect;
    EndButtonRect: TRect;
  end;

  TDACScrollHookPaintInfo = record
    Axis: TDACScrollHookAxis;
    Source: TDACScrollPaintSource;
    CoordinateSpace: TDACScrollCoordinateSpace;
    ControlHandle: HWND;
    TargetWindow: HWND;
    Enabled: Boolean;
    ScrollRect: TRect;
    SliderRect: TRect;
    StartButtonRect: TRect;
    EndButtonRect: TRect;
    SliderState: TThemedScrollBar;
    StartButtonState: TThemedScrollBar;
    EndButtonState: TThemedScrollBar;
    TrackColor: TAlphaColor;
    SliderColor: TAlphaColor;
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
function PaintDACNativeScrollBars(const AControl: TWinControl;
  const ADC: HDC; const ATokens: TDACControlTokens): Integer;
function ResolveDACNativeScrollGeometry(const AInfo: TScrollBarInfo;
  const AWindowRect: TRect; const AClientOrigin: TPoint;
  const AVertical: Boolean; out AGeometry: TDACNativeScrollGeometry): Boolean;

implementation

uses
  System.Math,
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
  GDACScrollRenderer: TDACSkiaRenderer;

function DACScrollRenderer: TDACSkiaRenderer;
begin
  if GDACScrollRenderer = nil then
    GDACScrollRenderer := TDACSkiaRenderer.Create;
  Result := GDACScrollRenderer;
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
    Result := ATokens.TabsTextDisabled
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

procedure DACDrawScrollArrow(const AControl: TWinControl;
  const ACanvas: ISkCanvas; const ARect: TRectF;
  const AVertical, APositive: Boolean;
  const ATokens: TDACControlTokens);
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
  if (AControl = nil) or not AControl.Enabled then
    LPaint.Color := ATokens.TabsTextDisabled
  else
    LPaint.Color := ATokens.ScrollBarArrow;
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
var
  LBitmap: TBitmap;
  LBorderInset: Single;
  LBorderRect: TRectF;
  LEndRect: TRectF;
  LPresented: Boolean;
  LSliderRect: TRectF;
  LStartRect: TRectF;
  LTokens: TDACControlTokens;
  LEffectiveEndState: TThemedScrollBar;
  LEffectiveSliderState: TThemedScrollBar;
  LEffectiveStartState: TThemedScrollBar;
  LInfo: TDACScrollHookPaintInfo;
begin
  if (AControl = nil) or (ADC = 0) or IsRectEmpty(AScrollRect) then
    Exit;
  LEffectiveSliderState := ASliderState;
  LTokens := ATokens;
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
  LBorderInset := Max(0, ATokens.ScrollBarBorderWidth / 2);
  LBorderRect := TRectF.Create(LBorderInset, LBorderInset,
    Max(LBorderInset, AScrollRect.Width - LBorderInset),
    Max(LBorderInset, AScrollRect.Height - LBorderInset));
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
  LBitmap := TBitmap.Create;
  try
    LBitmap.SetSize(AScrollRect.Width, AScrollRect.Height);
    LBitmap.SkiaDraw(
      procedure(const ACanvas: ISkCanvas)
      begin
        ACanvas.Clear(LTokens.ScrollBarTrack);
        if (LSliderRect.Width > 0) and (LSliderRect.Height > 0) then
          DACScrollRenderer.FillRoundRect(ACanvas, LSliderRect,
            DACScrollPartColor(AControl, LEffectiveSliderState, LTokens),
            LTokens.ScrollBarThumbRadius);
        if (LStartRect.Width > 0) and (LStartRect.Height > 0) then
        begin
          DACScrollRenderer.FillRoundRect(ACanvas, LStartRect,
            DACScrollPartColor(AControl, LEffectiveStartState, LTokens), 0);
          DACDrawScrollArrow(AControl, ACanvas, LStartRect, AVertical, False,
            LTokens);
        end;
        if (LEndRect.Width > 0) and (LEndRect.Height > 0) then
        begin
          DACScrollRenderer.FillRoundRect(ACanvas, LEndRect,
            DACScrollPartColor(AControl, LEffectiveEndState, LTokens), 0);
          DACDrawScrollArrow(AControl, ACanvas, LEndRect, AVertical, True,
            LTokens);
        end;
        DACScrollRenderer.StrokeRoundRect(ACanvas, LBorderRect,
          LTokens.ScrollBarBorder, 0, LTokens.ScrollBarBorderWidth);
      end);
    LPresented := BitBlt(ADC, AScrollRect.Left, AScrollRect.Top, LBitmap.Width,
      LBitmap.Height, LBitmap.Canvas.Handle, 0, 0, SRCCOPY);
    if Assigned(GDACScrollPaintObserver) then
    begin
      LInfo.Source := ASource;
      LInfo.CoordinateSpace := ACoordinateSpace;
      LInfo.ControlHandle := AControl.Handle;
      LInfo.TargetWindow := WindowFromDC(ADC);
      if AVertical then
        LInfo.Axis := shaVertical
      else
        LInfo.Axis := shaHorizontal;
      LInfo.Enabled := AControl.Enabled;
      LInfo.ScrollRect := AScrollRect;
      LInfo.SliderRect := ASliderRect;
      LInfo.StartButtonRect := AStartButtonRect;
      LInfo.EndButtonRect := AEndButtonRect;
      LInfo.SliderState := LEffectiveSliderState;
      LInfo.StartButtonState := LEffectiveStartState;
      LInfo.EndButtonState := LEffectiveEndState;
      LInfo.TrackColor := ATokens.ScrollBarTrack;
      LInfo.SliderColor := DACScrollPartColor(AControl,
        LEffectiveSliderState, ATokens);
      LInfo.StartButtonColor := DACScrollPartColor(AControl,
        LEffectiveStartState, ATokens);
      LInfo.EndButtonColor := DACScrollPartColor(AControl,
        LEffectiveEndState, ATokens);
      if AControl.Enabled then
        LInfo.ArrowColor := ATokens.ScrollBarArrow
      else
        LInfo.ArrowColor := ATokens.TabsTextDisabled;
      LInfo.BorderColor := ATokens.ScrollBarBorder;
      LInfo.RenderedWithSkia := True;
      LInfo.PresentedWithBitBlt := LPresented;
      DACNotifyScrollPaint(LInfo);
    end;
  finally
    LBitmap.Free;
  end;
end;

function NativeAxisState(const AControl: TWinControl;
  const ARect: TRect; const AVertical, ASlider, APositive,
  AAvailable: Boolean): TThemedScrollBar;
var
  LCursor: TPoint;
  LHot: Boolean;
  LPressed: Boolean;
begin
  if not AAvailable then
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
  LHot := PtInRect(ARect, LCursor);
  LPressed := LHot and (GetKeyState(VK_LBUTTON) < 0);
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
  const AVertical: Boolean; const ATokens: TDACControlTokens): Boolean;
var
  LClientOrigin: TPoint;
  LClipRect: TRect;
  LClipType: Integer;
  LGeometry: TDACNativeScrollGeometry;
  LInfo: TScrollBarInfo;
  LIntersection: TRect;
  LObjectId: Integer;
  LWindowRect: TRect;
  LScreenEndRect: TRect;
  LScreenSliderRect: TRect;
  LScreenStartRect: TRect;
begin
  Result := False;
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
      AVertical, LGeometry) then
    Exit;
  LClipType := GetClipBox(ADC, LClipRect);
  if (LClipType = ERROR) or (LClipType = NULLREGION) or
    not IntersectRect(LIntersection, LGeometry.ScrollRect, LClipRect) or
    not EqualRect(LIntersection, LGeometry.ScrollRect) then
    Exit;
  LScreenStartRect := LGeometry.StartButtonRect;
  LScreenEndRect := LGeometry.EndButtonRect;
  LScreenSliderRect := LGeometry.SliderRect;
  OffsetRect(LScreenStartRect, LWindowRect.Left, LWindowRect.Top);
  OffsetRect(LScreenEndRect, LWindowRect.Left, LWindowRect.Top);
  OffsetRect(LScreenSliderRect, LWindowRect.Left, LWindowRect.Top);
  RenderDACScroll(AControl, ADC, LGeometry.ScrollRect, LGeometry.SliderRect,
    LGeometry.StartButtonRect, LGeometry.EndButtonRect,
    NativeAxisState(AControl, LScreenSliderRect, AVertical, True, False,
      LGeometry.Available),
    NativeAxisState(AControl, LScreenStartRect, AVertical, False, False,
      LGeometry.Available),
    NativeAxisState(AControl, LScreenEndRect, AVertical, False, True,
      LGeometry.Available), AVertical, ATokens, spsNativeFallback,
      scsControlWindowDC);
  Result := True;
end;

function PaintDACNativeScrollBars(const AControl: TWinControl;
  const ADC: HDC; const ATokens: TDACControlTokens): Integer;
begin
  Result := 0;
  if (AControl = nil) or (ADC = 0) or not AControl.HandleAllocated then
    Exit;
  if PaintDACNativeAxis(AControl, ADC, False, ATokens) then
    Result := Result or DACNativeHorizontalPainted;
  if PaintDACNativeAxis(AControl, ADC, True, ATokens) then
    Result := Result or DACNativeVerticalPainted;
end;

initialization
  GDACScrollRenderer := nil;

finalization
  GDACScrollRenderer.Free;

end.
