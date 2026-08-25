unit DAC.Components.Controls.Loading;

interface

uses
  System.Classes,
  System.Skia,
  System.Types,
  System.UITypes,
  Winapi.Messages,
  Vcl.Controls,
  Vcl.ExtCtrls,
  Vcl.Graphics,
  Vcl.Skia,
  DAC.Components.Skia.Renderer,
  DAC.Components.DesignSystem.Theme;

type
  TDACLoadingKind = (
    mlkSpinner,
    mlkDots,
    mlkSkeleton
  );

  TDACLoading = class(TCustomControl)
  private
    FActive: Boolean;
    FKind: TDACLoadingKind;
    FPaintBox: TSkPaintBox;
    FPhase: Integer;
    FRenderer: TDACSkiaRenderer;
    FThemeMode: TDACThemeMode;
    FTimer: TTimer;
    procedure CMEnabledChanged(var AMessage: TMessage); message CM_ENABLEDCHANGED;
    procedure CMVisibleChanged(var AMessage: TMessage); message CM_VISIBLECHANGED;
    procedure DrawDots(const ACanvas: ISkCanvas; const ADest: TRectF; const AAlpha: Byte);
    procedure DrawSkeleton(const ACanvas: ISkCanvas; const ADest: TRectF; const AAlpha: Byte);
    procedure DrawSpinner(const ACanvas: ISkCanvas; const ADest: TRectF; const AAlpha: Byte);
    procedure InvalidateLoading;
    procedure PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    function ParentSurfaceColor: TAlphaColor;
    function Pixels(const AValue: Integer): Integer;
    procedure SetActive(const AValue: Boolean);
    procedure SetKind(const AValue: TDACLoadingKind);
    procedure SetThemeMode(const AValue: TDACThemeMode);
    procedure TimerTick(Sender: TObject);
    procedure ThemeChanged(Sender: TObject);
    procedure UpdatePaintBoxBounds;
    procedure UpdateTimer;
    procedure WMEraseBkgnd(var AMessage: TWMEraseBkgnd); message WM_ERASEBKGND;
  protected
    procedure CreateWnd; override;
    procedure Loaded; override;
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ResolvedAccentColor: TAlphaColor;
    function ResolvedSurfaceColor: TAlphaColor;
    procedure Redraw;
  published
    property Active: Boolean read FActive write SetActive default True;
    property Align;
    property Anchors;
    property Constraints;
    property Enabled;
    property Hint;
    property Kind: TDACLoadingKind read FKind write SetKind default mlkSpinner;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop default False;
    property ThemeMode: TDACThemeMode read FThemeMode write SetThemeMode default dtmInherit;
    property Visible;
    property OnClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
  end;

implementation

uses
  System.Math,
  DAC.Components.DesignSystem.ComponentStyle,
  DAC.Components.DesignSystem.ControlTokens;

constructor TDACLoading.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque, csReplicatable];
  Width := Round(TDACComponentStyle.Resolve(dtmInherit).Tokens.Controls.LoadingDefaultWidth);
  Height := Round(TDACComponentStyle.Resolve(dtmInherit).Tokens.Controls.LoadingDefaultHeight);
  TabStop := False;
  ParentColor := False;
  StyleElements := [];

  FActive := True;
  FKind := mlkSpinner;
  FPhase := 0;
  FThemeMode := dtmInherit;
  TDACThemeManager.RegisterListener(Self, ThemeChanged);
  FRenderer := TDACSkiaRenderer.Create;

  FPaintBox := TSkPaintBox.Create(Self);
  FPaintBox.Parent := Self;
  FPaintBox.SetSubComponent(True);
  FPaintBox.StyleElements := [];
  FPaintBox.OnDraw := PaintBoxDraw;

  FTimer := TTimer.Create(Self);
  FTimer.Enabled := False;
  FTimer.Interval := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls.LoadingTimerInterval;
  FTimer.OnTimer := TimerTick;

  UpdatePaintBoxBounds;
  UpdateTimer;
end;

destructor TDACLoading.Destroy;
begin
  TDACThemeManager.UnregisterListener(Self);
  FTimer.Free;
  FPaintBox.Free;
  FRenderer.Free;
  inherited;
end;
procedure TDACLoading.CMEnabledChanged(var AMessage: TMessage);
begin
  inherited;
  UpdateTimer;
  InvalidateLoading;
end;

procedure TDACLoading.CMVisibleChanged(var AMessage: TMessage);
begin
  inherited;
  UpdateTimer;
  InvalidateLoading;
end;

procedure TDACLoading.CreateWnd;
begin
  inherited;
  UpdatePaintBoxBounds;
  UpdateTimer;
  InvalidateLoading;
end;

procedure TDACLoading.DrawDots(const ACanvas: ISkCanvas; const ADest: TRectF;
  const AAlpha: Byte);
var
  I: Integer;
  LAlpha: Byte;
  LCenterX: Single;
  LPaint: ISkPaint;
  LRadius: Single;
  LSpacing: Single;
  LTokens: TDACControlTokens;
begin
  LTokens := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls;
  LRadius := Pixels(Round(LTokens.LoadingDotsRadius));
  LSpacing := Pixels(Round(LTokens.LoadingDotsSpacing));
  LCenterX := (ADest.Width / 2) - LSpacing;
  LPaint := TSkPaint.Create(TSkPaintStyle.Fill);
  LPaint.AntiAlias := True;
  LPaint.Color := LTokens.LoadingAccent;

  for I := 0 to 2 do
  begin
    LAlpha := LTokens.LoadingDotsInactiveAlpha;
    if (FPhase mod 3) = I then
      LAlpha := AAlpha;
    LPaint.Alpha := LAlpha;
    ACanvas.DrawCircle(LCenterX + (I * LSpacing), ADest.Height / 2, LRadius, LPaint);
  end;
end;

procedure TDACLoading.DrawSkeleton(const ACanvas: ISkCanvas; const ADest: TRectF;
  const AAlpha: Byte);
var
  LBase: TAlphaColor;
  LHighlight: TAlphaColor;
  LOffset: Single;
  LRect: TRectF;
  LTokens: TDACControlTokens;
begin
  LTokens := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls;
  LBase := LTokens.LoadingSkeletonBase;
  LHighlight := LTokens.LoadingSkeletonHighlight;

  LRect := TRectF.Create(0, Pixels(Round(LTokens.LoadingSkeletonAvatarTop)),
    Pixels(Round(LTokens.LoadingSkeletonAvatarWidth)),
    Pixels(Round(LTokens.LoadingSkeletonAvatarTop + LTokens.LoadingSkeletonAvatarHeight)));
  FRenderer.FillRoundRect(ACanvas, LRect, LBase,
    Pixels(Round(LTokens.LoadingSkeletonAvatarRadius)), AAlpha);
  LRect := TRectF.Create(Pixels(Round(LTokens.LoadingSkeletonTextLeft)),
    Pixels(Round(LTokens.LoadingSkeletonTitleTop)), ADest.Width,
    Pixels(Round(LTokens.LoadingSkeletonTitleTop + LTokens.LoadingSkeletonTitleHeight)));
  FRenderer.FillRoundRect(ACanvas, LRect, LBase, Pixels(Round(LTokens.LoadingSkeletonRadius)), AAlpha);
  LRect := TRectF.Create(Pixels(Round(LTokens.LoadingSkeletonTextLeft)),
    Pixels(Round(LTokens.LoadingSkeletonLineTop)),
    ADest.Width - Pixels(Round(LTokens.LoadingSkeletonLineRightInset)),
    Pixels(Round(LTokens.LoadingSkeletonLineTop + LTokens.LoadingSkeletonLineHeight)));
  FRenderer.FillRoundRect(ACanvas, LRect, LBase, Pixels(Round(LTokens.LoadingSkeletonRadius)), AAlpha);

  LOffset := (FPhase mod 8) / 8;
  LRect := TRectF.Create(ADest.Width * LOffset,
    Pixels(Round(LTokens.LoadingSkeletonTitleTop)),
    (ADest.Width * LOffset) + Pixels(Round(LTokens.LoadingSkeletonHighlightWidth)),
    Pixels(Round(LTokens.LoadingSkeletonTitleTop + LTokens.LoadingSkeletonTitleHeight)));
  FRenderer.FillRoundRect(ACanvas, LRect, LHighlight,
    Pixels(Round(LTokens.LoadingSkeletonRadius)), LTokens.LoadingSkeletonHighlightAlpha);
end;

procedure TDACLoading.DrawSpinner(const ACanvas: ISkCanvas; const ADest: TRectF;
  const AAlpha: Byte);
var
  LPaint: ISkPaint;
  LRect: TRectF;
  LSize: Single;
  LTokens: TDACControlTokens;
begin
  LTokens := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls;
  LSize := Min(ADest.Width, ADest.Height) - Pixels(Round(LTokens.LoadingSpinnerInset));
  LRect := TRectF.Create((ADest.Width - LSize) / 2, (ADest.Height - LSize) / 2,
    (ADest.Width + LSize) / 2, (ADest.Height + LSize) / 2);

  LPaint := TSkPaint.Create(TSkPaintStyle.Stroke);
  LPaint.AntiAlias := True;
  LPaint.Color := LTokens.LoadingSpinnerTrack;
  LPaint.Alpha := LTokens.LoadingSpinnerTrackAlpha;
  LPaint.StrokeCap := TSkStrokeCap.Round;
  LPaint.StrokeWidth := Pixels(Round(LTokens.LoadingSpinnerThickness));
  ACanvas.DrawArc(LRect, 0, 360, False, LPaint);

  LPaint.Color := LTokens.LoadingAccent;
  LPaint.Alpha := AAlpha;
  ACanvas.DrawArc(LRect, -90 + (FPhase * 32), 250, False, LPaint);
end;

procedure TDACLoading.InvalidateLoading;
begin
  if (FPaintBox = nil) or (csLoading in ComponentState) or
    (csDestroying in ComponentState) then
    Exit;
  UpdatePaintBoxBounds;
  if csDesigning in ComponentState then
  begin
    if Parent <> nil then
      FPaintBox.Redraw;
    Invalidate;
    Exit;
  end;
  if (Parent = nil) or not HandleAllocated or not Parent.HandleAllocated then
    Exit;
  FPaintBox.Redraw;
end;

procedure TDACLoading.Loaded;
begin
  inherited;
  UpdatePaintBoxBounds;
  UpdateTimer;
  InvalidateLoading;
end;

procedure TDACLoading.PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
  const ADest: TRectF; const AOpacity: Single);
var
  LAlpha: Byte;
  LTokens: TDACControlTokens;
begin
  if (ACanvas = nil) or (ADest.Width <= 0) or (ADest.Height <= 0) then
    Exit;

  ACanvas.Clear(ParentSurfaceColor);
  LTokens := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls;
  LAlpha := LTokens.AlphaOpaque;
  if not Enabled then
    LAlpha := LTokens.LoadingDisabledAlpha;

  case FKind of
    mlkDots:
      DrawDots(ACanvas, ADest, LAlpha);
    mlkSkeleton:
      DrawSkeleton(ACanvas, ADest, LAlpha);
  else
    DrawSpinner(ACanvas, ADest, LAlpha);
  end;
end;

function TDACLoading.ParentSurfaceColor: TAlphaColor;
begin
  Result := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls.PopupBackground;
end;

procedure TDACLoading.Redraw;
begin
  if (FPaintBox = nil) or (csLoading in ComponentState) or
    (csDestroying in ComponentState) then
    Exit;

  UpdatePaintBoxBounds;

  { The designer has a parent surface but no stable runtime HWND lifecycle.
    Keep the Skia chrome preview available there without forcing a handle. }
  if csDesigning in ComponentState then
  begin
    if Parent <> nil then
      FPaintBox.Redraw;
    Invalidate;
    Exit;
  end;

  if (Parent = nil) or not HandleAllocated or not Parent.HandleAllocated then
    Exit;

  FPaintBox.Redraw;
end;

function TDACLoading.ResolvedAccentColor: TAlphaColor;
begin
  Result := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls.LoadingAccent;
end;

function TDACLoading.ResolvedSurfaceColor: TAlphaColor;
begin
  Result := ParentSurfaceColor;
end;

procedure TDACLoading.Resize;
begin
  inherited;
  UpdatePaintBoxBounds;
  Redraw;
end;

function TDACLoading.Pixels(const AValue: Integer): Integer;
begin
  Result := AValue;
  if (AValue > 0) and (Result < 1) then
    Result := 1;
end;

procedure TDACLoading.SetActive(const AValue: Boolean);
begin
  if FActive = AValue then
    Exit;
  FActive := AValue;
  UpdateTimer;
  InvalidateLoading;
end;

procedure TDACLoading.SetKind(const AValue: TDACLoadingKind);
begin
  if FKind = AValue then
    Exit;
  FKind := AValue;
  InvalidateLoading;
end;

procedure TDACLoading.SetThemeMode(const AValue: TDACThemeMode);
begin
  if FThemeMode = AValue then
    Exit;
  FThemeMode := AValue;
  ThemeChanged(Self);
end;

procedure TDACLoading.TimerTick(Sender: TObject);
begin
  Inc(FPhase);
  InvalidateLoading;
end;

procedure TDACLoading.ThemeChanged(Sender: TObject);
begin
  InvalidateLoading;
end;

procedure TDACLoading.UpdatePaintBoxBounds;
var
  LHeight: Integer;
  LWidth: Integer;
begin
  if (FPaintBox = nil) or (csLoading in ComponentState) or
    (csDestroying in ComponentState) then
    Exit;

  LWidth := Width;
  LHeight := Height;
  if not (csDesigning in ComponentState) and HandleAllocated then
  begin
    LWidth := ClientWidth;
    LHeight := ClientHeight;
  end;

  if (FPaintBox.Left <> 0) or (FPaintBox.Top <> 0) or
    (FPaintBox.Width <> LWidth) or (FPaintBox.Height <> LHeight) then
    FPaintBox.SetBounds(0, 0, LWidth, LHeight);
end;

procedure TDACLoading.UpdateTimer;
begin
  if FTimer = nil then
    Exit;
  FTimer.Enabled := FActive and Enabled and Visible and not (csDesigning in ComponentState);
end;

procedure TDACLoading.WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
begin
  AMessage.Result := 1;
end;

end.

