unit DAC.Components.Controls.ScrollContainer;

interface

uses
  System.Classes,
  System.Skia,
  System.Types,
  System.UITypes,
  Winapi.Messages,
  Winapi.Windows,
  Vcl.Controls,
  Vcl.ComCtrls,
  Vcl.Forms,
  Vcl.Graphics,
  Vcl.Skia,
  DAC.Components.DesignSystem.ControlTokens,
  DAC.Components.DesignSystem.Theme,
  DAC.Components.Skia.Renderer;

type
  TDACScrollBarMode = (
    msbmAuto,
    msbmVertical,
    msbmHorizontal,
    msbmBoth,
    msbmNone
  );

  TDACScrollAppearance = (
    mscaDefault,
    mscaViewport,
    mscaCustom
  );

  TDACScrollContainer = class(TScrollBox)
  private
    FAppearance: TDACScrollAppearance;
    FBaseAppearance: TDACScrollAppearance;
    FBackgroundColor: TAlphaColor;
    FBorderColor: TAlphaColor;
    FCustomBackgroundColor: Boolean;
    FCustomBorderColor: Boolean;
    FCustomCornerRadius: Boolean;
    FCornerRadius: Integer;
    FPaintBox: TSkPaintBox;
    FRenderer: TDACSkiaRenderer;
    FScrollBarMode: TDACScrollBarMode;
    FWheelDeltaRemainder: Integer;
    FThemeMode: TDACThemeMode;
    FPendingThemeRedraw: Boolean;
    procedure ApplyTheme;
    procedure ApplyAppearance;
    procedure ApplyPendingTheme;
    function IsPageActive: Boolean;
    function IsBackgroundColorStored: Boolean;
    function IsBorderColorStored: Boolean;
    function IsCornerRadiusStored: Boolean;
    function CanArbitrateNestedWheel: Boolean;
    function WheelPointBelongsToContainer(const APoint: TPoint): Boolean;
    function ParentSurfaceColor: TAlphaColor;
    procedure ScrollVertically(const ACode: Word);
    procedure CMMouseWheel(var AMessage: TCMMouseWheel); message CM_MOUSEWHEEL;
    procedure CMParentColorChanged(var AMessage: TMessage); message CM_PARENTCOLORCHANGED;
    procedure CMParentFontChanged(var AMessage: TMessage); message CM_PARENTFONTCHANGED;
    procedure PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    procedure CMControlListChange(var AMessage: TCMControlListChange);
      message CM_CONTROLLISTCHANGE;
    procedure CMShowingChanged(var AMessage: TMessage); message CM_SHOWINGCHANGED;
    procedure RedrawChrome;
    procedure SetAppearance(const AValue: TDACScrollAppearance);
    procedure SetBackgroundColor(const AValue: TAlphaColor);
    procedure SetBorderColor(const AValue: TAlphaColor);
    procedure SetCornerRadius(const AValue: Integer);
    procedure SetScrollBarMode(const AValue: TDACScrollBarMode);
    procedure SetThemeMode(const AValue: TDACThemeMode);
    procedure ThemeChanged(Sender: TObject);
    procedure UpdateChromeBounds;
    procedure UpdateScrollBars;
    procedure WMEraseBkgnd(var AMessage: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMNCPaint(var AMessage: TWMNCPaint); message WM_NCPAINT;
  protected
    procedure CreateWnd; override;
    procedure Loaded; override;
    procedure Resize; override;
    procedure WndProc(var Message: TMessage); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ResolvedBackgroundColor: TAlphaColor;
    procedure Redraw;
  published
    property Align;
    property Anchors;
    property AutoScroll default True;
    property Appearance: TDACScrollAppearance read FAppearance
      write SetAppearance default mscaDefault;
    property BackgroundColor: TAlphaColor read FBackgroundColor
      write SetBackgroundColor stored IsBackgroundColorStored;
    property HasCustomBackgroundColor: Boolean read FCustomBackgroundColor stored False;
    property BorderColor: TAlphaColor read FBorderColor write SetBorderColor
      stored IsBorderColorStored;
    property BorderStyle default bsNone;
    property Constraints;
    property CornerRadius: Integer read FCornerRadius write SetCornerRadius
      stored IsCornerRadiusStored;
    property Enabled;
    property Font;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ScrollBarMode: TDACScrollBarMode read FScrollBarMode write SetScrollBarMode default msbmAuto;
    property ShowHint;
    property TabOrder;
    property TabStop default True;
    property ThemeMode: TDACThemeMode read FThemeMode write SetThemeMode default dtmInherit;
    property Visible;
  end;

implementation

uses
  System.Math,
  DAC.Components.Controls.NativeWindowTheme,
  DAC.Components.DesignSystem.ColorTokens,
  DAC.Components.DesignSystem.ComponentStyle;

constructor TDACScrollContainer.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csAcceptsControls, csOpaque];
  Width := Round(TDACComponentStyle.Resolve(dtmInherit).Tokens.Controls.ScrollContainerDefaultWidth);
  Height := Round(TDACComponentStyle.Resolve(dtmInherit).Tokens.Controls.ScrollContainerDefaultHeight);
  AutoScroll := True;
  BorderStyle := bsNone;
  HorzScrollBar.Tracking := True;
  VertScrollBar.Tracking := True;
  ParentColor := False;
  ParentBackground := False;
  ParentFont := False;
  TabStop := True;
  StyleElements := [];

  FThemeMode := dtmInherit;
  FAppearance := mscaDefault;
  FBaseAppearance := mscaDefault;
  ApplyAppearance;
  FScrollBarMode := msbmAuto;
  FRenderer := TDACSkiaRenderer.Create;
  Color := TDACComponentColors.ToVclColor(FBackgroundColor);

  FPaintBox := TSkPaintBox.Create(Self);
  FPaintBox.Parent := Self;
  FPaintBox.SetSubComponent(True);
  // The surface is viewport chrome, not scrollable content.  alClient keeps
  // it out of TScrollingWinControl.CalcAutoRange, which otherwise feeds the
  // current ScrollBar.Position back into the range and lets the surface grow
  // beneath the native scrollbar strip while scrolling.
  FPaintBox.Align := alClient;
  FPaintBox.StyleElements := [];
  FPaintBox.OnDraw := PaintBoxDraw;
  TDACThemeManager.RegisterListener(Self, ThemeChanged);
end;

procedure TDACScrollContainer.ApplyAppearance;
var
  LAppearance: TDACScrollAppearance;
  LTokens: TDACControlTokens;
begin
  LTokens := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls;
  LAppearance := FAppearance;
  if LAppearance = mscaCustom then
    LAppearance := FBaseAppearance;
  case LAppearance of
    mscaDefault:
      begin
        if (FAppearance <> mscaCustom) or not FCustomBackgroundColor then
          FBackgroundColor := LTokens.ScrollContainerBackground;
        if (FAppearance <> mscaCustom) or not FCustomBorderColor then
          FBorderColor := LTokens.ScrollContainerBorder;
        if (FAppearance <> mscaCustom) or not FCustomCornerRadius then
          FCornerRadius := Round(LTokens.ScrollContainerRadius);
      end;
    mscaViewport:
      begin
        if (FAppearance <> mscaCustom) or not FCustomBackgroundColor then
          FBackgroundColor := LTokens.ScrollContainerViewportBackground;
        if (FAppearance <> mscaCustom) or not FCustomBorderColor then
          FBorderColor := LTokens.ScrollContainerViewportBorder;
        if (FAppearance <> mscaCustom) or not FCustomCornerRadius then
          FCornerRadius := Round(LTokens.ScrollContainerViewportRadius);
      end;
  end;
  if FAppearance <> mscaCustom then
  begin
    FCustomBackgroundColor := False;
    FCustomBorderColor := False;
    FCustomCornerRadius := False;
  end;
  if FBackgroundColor = LTokens.TransparentSurfaceFallback then
    Color := TDACComponentColors.ToVclColor(ParentSurfaceColor)
  else
    Color := TDACComponentColors.ToVclColor(
      TDACComponentColors.Normalize(FBackgroundColor));
  ParentColor := False;
  ParentBackground := False;
  ParentFont := False;
  Font.Name := TDACComponentStyle.FontFamily;
  Font.Size := TDACComponentStyle.TextSize;
  Font.Style := [];
  Font.Color := TDACComponentColors.ToVclColor(LTokens.ContainerTitle);
end;

destructor TDACScrollContainer.Destroy;
begin
  TDACThemeManager.UnregisterListener(Self);
  FPaintBox.Free;
  FRenderer.Free;
  inherited;
end;

procedure TDACScrollContainer.CMControlListChange(
  var AMessage: TCMControlListChange);
begin
  inherited;
  // The Skia surface is created before DFM child controls.  Reassert its
  // background role after every streamed/runtime child insertion so it can
  // never cover native labels, buttons or grid containers at runtime.
  if (FPaintBox <> nil) and not (csLoading in ComponentState) and
    not (csDesigning in ComponentState) and (Parent <> nil) and
    HandleAllocated and Parent.HandleAllocated and Showing then
    FPaintBox.SendToBack;

  { A control added after a local theme was selected must resolve from this
    physical scroll surface immediately. RefreshTree is listener-only and
    never forces a HWND, so it is safe for streamed and runtime descendants. }
  if not (csLoading in ComponentState) and not (csDestroying in ComponentState) then
    TDACThemeManager.RefreshTree(Self);
end;

procedure TDACScrollContainer.CMShowingChanged(var AMessage: TMessage);
begin
  inherited;
  if Showing then
  begin
    ApplyPendingTheme;
    Redraw;
  end;
end;

procedure TDACScrollContainer.CMMouseWheel(var AMessage: TCMMouseWheel);
var
  LCode: Word;
  LNotches: Integer;
  LScrollLines: Cardinal;
  LSteps: Integer;
begin
  if not CanArbitrateNestedWheel or
    not WheelPointBelongsToContainer(
      SmallPointToPoint(AMessage.Pos)) then
  begin
    inherited;
    Exit;
  end;

  if VertScrollBar.Range <= ClientHeight then
  begin
    inherited;
    Exit;
  end;

  // Mark even a partial high-resolution delta as handled.  Otherwise VCL
  // falls through to DefWindowProc, which can forward the same wheel input
  // through the native parent chain and apply it a second time.
  AMessage.Result := 1;
  if ((FWheelDeltaRemainder > 0) and (AMessage.WheelDelta < 0)) or
    ((FWheelDeltaRemainder < 0) and (AMessage.WheelDelta > 0)) then
    FWheelDeltaRemainder := 0;
  FWheelDeltaRemainder := FWheelDeltaRemainder + AMessage.WheelDelta;
  LNotches := FWheelDeltaRemainder div WHEEL_DELTA;
  FWheelDeltaRemainder := FWheelDeltaRemainder - (LNotches * WHEEL_DELTA);
  if LNotches = 0 then
    Exit;

  if not SystemParametersInfo(SPI_GETWHEELSCROLLLINES, 0, @LScrollLines, 0) then
    LScrollLines := 3;
  if LScrollLines = 0 then
    Exit;

  if LScrollLines = WHEEL_PAGESCROLL then
    LSteps := 1
  else
    LSteps := Min(Integer(LScrollLines), 100);
  if LNotches > 0 then
    LCode := SB_LINEUP
  else
    LCode := SB_LINEDOWN;
  if LScrollLines = WHEEL_PAGESCROLL then
  begin
    if LNotches > 0 then
      LCode := SB_PAGEUP
    else
      LCode := SB_PAGEDOWN;
  end;

  LSteps := LSteps * Abs(LNotches);
  while LSteps > 0 do
  begin
    ScrollVertically(LCode);
    Dec(LSteps);
  end;
end;

function TDACScrollContainer.CanArbitrateNestedWheel: Boolean;
begin
  Result := not (csDesigning in ComponentState) and
    not (csLoading in ComponentState) and
    not (csDestroying in ComponentState) and
    (Parent <> nil) and HandleAllocated and Parent.HandleAllocated and
    IsWindow(Handle);
end;

function TDACScrollContainer.WheelPointBelongsToContainer(
  const APoint: TPoint): Boolean;
var
  LWindow: HWND;
begin
  LWindow := WindowFromPoint(APoint);
  Result := (LWindow <> 0) and
    ((LWindow = Handle) or IsChild(Handle, LWindow));
end;

procedure TDACScrollContainer.CreateWnd;
begin
  inherited;
  ApplyAppearance;
  UpdateScrollBars;
  ApplyDACNativeScrollBarTheme(Self, FThemeMode);
  UpdateChromeBounds;
  TDACThemeManager.RefreshTree(Self);
  ApplyPendingTheme;
  Redraw;
end;

procedure TDACScrollContainer.Loaded;
begin
  inherited;
  ApplyAppearance;
  UpdateScrollBars;
  UpdateChromeBounds;
  { Children can be streamed after the container ThemeMode. Reapply the
    resolved physical palette only after the visual tree is complete. }
  TDACThemeManager.RefreshTree(Self);
  ApplyPendingTheme;
  Redraw;
end;

procedure TDACScrollContainer.PaintBoxDraw(Sender: TObject;
  const ACanvas: ISkCanvas; const ADest: TRectF; const AOpacity: Single);
var
  LBackground: TAlphaColor;
  LRect: TRectF;
  LScale: Single;
  LTokens: TDACControlTokens;
begin
  LTokens := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls;
  if FBackgroundColor = LTokens.TransparentSurfaceFallback then
    LBackground := ParentSurfaceColor
  else
    LBackground := TDACComponentColors.Normalize(FBackgroundColor);

  LScale := LTokens.ScrollContainerBorderWidth;

  ACanvas.Clear(LBackground);
  LRect := FRenderer.SnapRect(TRectF.Create(0, 0, ADest.Width, ADest.Height), LScale);
  LRect.Inflate(-(LTokens.ScrollContainerBorderWidth / 2),
    -(LTokens.ScrollContainerBorderWidth / 2));
  FRenderer.FillRoundRect(ACanvas, LRect, LBackground, FCornerRadius,
    LTokens.AlphaOpaque);
  FRenderer.StrokeRoundRect(ACanvas, LRect,
    TDACComponentColors.Normalize(FBorderColor), FCornerRadius,
    LTokens.ScrollContainerBorderWidth, LTokens.AlphaOpaque);
end;

function TDACScrollContainer.ParentSurfaceColor: TAlphaColor;
begin
  Result := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls.PopupBackground;
end;

function TDACScrollContainer.IsPageActive: Boolean;
var
  LTabSheet: TTabSheet;
begin
  Result := Showing;
  if Parent is TTabSheet then
  begin
    LTabSheet := TTabSheet(Parent);
    Result := Result and (LTabSheet.PageControl <> nil) and
      (LTabSheet.PageControl.ActivePage = LTabSheet);
  end;
end;

function TDACScrollContainer.IsBackgroundColorStored: Boolean;
begin
  Result := (FAppearance = mscaCustom) and FCustomBackgroundColor;
end;

function TDACScrollContainer.IsBorderColorStored: Boolean;
begin
  Result := (FAppearance = mscaCustom) and FCustomBorderColor;
end;

function TDACScrollContainer.IsCornerRadiusStored: Boolean;
begin
  Result := (FAppearance = mscaCustom) and FCustomCornerRadius;
end;

function TDACScrollContainer.ResolvedBackgroundColor: TAlphaColor;
var
  LAppearance: TDACScrollAppearance;
  LTokens: TDACControlTokens;
begin
  if (FAppearance = mscaCustom) and FCustomBackgroundColor then
    Exit(FBackgroundColor);
  LAppearance := FAppearance;
  if LAppearance = mscaCustom then
    LAppearance := FBaseAppearance;
  LTokens := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls;
  if LAppearance = mscaViewport then
    Result := LTokens.ScrollContainerViewportBackground
  else
    Result := LTokens.ScrollContainerBackground;
end;

procedure TDACScrollContainer.ScrollVertically(const ACode: Word);
begin
  Perform(WM_VSCROLL, ACode, 0);
end;

procedure TDACScrollContainer.Redraw;
begin
  RedrawChrome;
end;

procedure TDACScrollContainer.RedrawChrome;
begin
  if (FPaintBox = nil) or (csDestroying in ComponentState) then
    Exit;
  if csDesigning in ComponentState then
  begin
    { Design-time: descarta cache Skia e invalida a superficie do designer.
      TSkPaintBox e TGraphicControl — Redraw nao cria HWND. }
    FPaintBox.Redraw;
    Invalidate;
    Exit;
  end;
  if (Parent = nil) or not HandleAllocated or not Parent.HandleAllocated or
    not Showing or not IsPageActive then
    Exit;
  FPaintBox.Redraw;
  FPaintBox.Invalidate;
  FPaintBox.Update;
  RedrawWindow(Handle, nil, 0, RDW_INVALIDATE or RDW_FRAME);
end;

procedure TDACScrollContainer.Resize;
begin
  inherited;
  UpdateChromeBounds;
  Redraw;
end;

procedure TDACScrollContainer.WMNCPaint(var AMessage: TWMNCPaint);
var
  LDC: HDC;
begin
  inherited;
  if not HandleAllocated or
    (DACNativeScrollBarHookAuthorityCount(Handle) <> 0) then
    Exit;
  LDC := GetWindowDC(Handle);
  if LDC = 0 then
    Exit;
  try
    PaintDACNativeScrollBarTheme(Self, FThemeMode, LDC);
  finally
    ReleaseDC(Handle, LDC);
  end;
end;

procedure TDACScrollContainer.SetBackgroundColor(const AValue: TAlphaColor);
begin
  FAppearance := mscaCustom;
  FCustomBackgroundColor := True;
  if FBackgroundColor = AValue then
    Exit;
  FBackgroundColor := AValue;
  if FBackgroundColor = TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls.
    TransparentSurfaceFallback then
    Color := TDACComponentColors.ToVclColor(ParentSurfaceColor)
  else
    Color := TDACComponentColors.ToVclColor(
      TDACComponentColors.Normalize(FBackgroundColor));
  Redraw;
end;

procedure TDACScrollContainer.SetBorderColor(const AValue: TAlphaColor);
begin
  FAppearance := mscaCustom;
  FCustomBorderColor := True;
  if FBorderColor = AValue then
    Exit;
  FBorderColor := AValue;
  Redraw;
end;

procedure TDACScrollContainer.SetThemeMode(const AValue: TDACThemeMode);
begin
  if FThemeMode = AValue then
  begin
    ApplyTheme;
    TDACThemeManager.RefreshTree(Self);
    Exit;
  end;
  FThemeMode := AValue;
  ApplyTheme;
  TDACThemeManager.RefreshTree(Self);
end;

procedure TDACScrollContainer.CMParentColorChanged(var AMessage: TMessage);
begin
  inherited;
  ApplyTheme;
  TDACThemeManager.RefreshTree(Self);
end;

procedure TDACScrollContainer.CMParentFontChanged(var AMessage: TMessage);
begin
  inherited;
  ApplyTheme;
  TDACThemeManager.RefreshTree(Self);
end;

procedure TDACScrollContainer.ApplyTheme;
begin
  ApplyAppearance;
  Color := TDACComponentColors.ToVclColor(ResolvedBackgroundColor);
  ApplyDACNativeScrollBarTheme(Self, FThemeMode);
  if HandleAllocated and not (csDesigning in ComponentState) then
    RedrawWindow(Handle, nil, 0, RDW_INVALIDATE or RDW_FRAME);
  FPendingThemeRedraw := not ((Parent <> nil) and HandleAllocated and
    IsPageActive and not (csDesigning in ComponentState));
  if not FPendingThemeRedraw then
    Redraw;
end;

procedure TDACScrollContainer.SetAppearance(
  const AValue: TDACScrollAppearance);
begin
  if FAppearance = AValue then
  begin
    if AValue <> mscaCustom then
      ApplyTheme;
    Exit;
  end;
  FAppearance := AValue;
  if AValue <> mscaCustom then
    FBaseAppearance := AValue;
  if AValue = mscaCustom then
  begin
    FCustomBackgroundColor := True;
    FCustomBorderColor := True;
    FCustomCornerRadius := True;
  end;
  ApplyTheme;
end;

procedure TDACScrollContainer.ApplyPendingTheme;
begin
  if not FPendingThemeRedraw then
    Exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) or
    (csDesigning in ComponentState) or (Parent = nil) or not HandleAllocated or
    not Parent.HandleAllocated or not IsPageActive then
    Exit;
  FPendingThemeRedraw := False;
  if FPaintBox <> nil then
  begin
    // A TSkPaintBox created under an inactive TTabSheet can retain the old
    // backing surface.  Recreate its visible paint pass only after the tab
    // is showing, then keep it behind the native interactive children.
    FPaintBox.Visible := False;
    FPaintBox.Visible := True;
    FPaintBox.SendToBack;
  end;
  Redraw;
end;

procedure TDACScrollContainer.ThemeChanged(Sender: TObject);
begin
  if FThemeMode <> dtmInherit then
    Exit;
  ApplyTheme;
end;

procedure TDACScrollContainer.SetCornerRadius(const AValue: Integer);
begin
  FAppearance := mscaCustom;
  FCustomCornerRadius := True;
  if FCornerRadius = Max(0, AValue) then
    Exit;
  FCornerRadius := Max(0, AValue);
  Redraw;
end;

procedure TDACScrollContainer.SetScrollBarMode(
  const AValue: TDACScrollBarMode);
begin
  if FScrollBarMode = AValue then
    Exit;
  FScrollBarMode := AValue;
  UpdateScrollBars;
end;

procedure TDACScrollContainer.UpdateChromeBounds;
begin
  if (FPaintBox = nil) or (csLoading in ComponentState) or
    (csDestroying in ComponentState) then
    Exit;
  if csDesigning in ComponentState then
  begin
    { Never query ClientRect nor change z-order while the designer is
      streaming. Width/Height provide the same static preview bounds. }
    FPaintBox.SetBounds(0, 0, Width, Height);
    Exit;
  end;
  if (Parent = nil) or not HandleAllocated or not Parent.HandleAllocated or
    not Showing then
    Exit;
  if FPaintBox.Align <> alClient then
    FPaintBox.Align := alClient;
  FPaintBox.SendToBack;
end;

procedure TDACScrollContainer.WndProc(var Message: TMessage);
begin
  inherited;
  case Message.Msg of
    WM_HSCROLL,
    WM_VSCROLL,
    WM_MOUSEWHEEL,
    WM_SIZE:
      begin
        UpdateChromeBounds;
        RedrawChrome;
      end;
    WM_PAINT:
      ApplyPendingTheme;
  end;
end;

procedure TDACScrollContainer.UpdateScrollBars;
begin
  HorzScrollBar.Visible := FScrollBarMode in [msbmAuto, msbmHorizontal, msbmBoth];
  VertScrollBar.Visible := FScrollBarMode in [msbmAuto, msbmVertical, msbmBoth];
end;

procedure TDACScrollContainer.WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
var
  LBrush: HBRUSH;
begin
  // TScrollBox exposes newly uncovered pixels while it scrolls its children.
  // The Skia paintbox is a child too, so it can be temporarily outside those
  // pixels during the native scroll.  Paint the same token surface here to
  // prevent the default black brush from becoming visible between grids.
  // Em design-time tambem preenche para evitar pixels fantasma ao mover.
  LBrush := CreateSolidBrush(ColorToRGB(Color));
  try
    Winapi.Windows.FillRect(AMessage.DC, ClientRect, LBrush);
  finally
    DeleteObject(LBrush);
  end;
  AMessage.Result := 1;
end;

end.
