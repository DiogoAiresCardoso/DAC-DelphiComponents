unit MaxxRural.Components.Controls.Loading;

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
  MaxxRural.Components.Skia.Renderer;

type
  TMaxxRuralLoadingKind = (
    mlkSpinner,
    mlkDots,
    mlkSkeleton
  );

  TMaxxRuralLoading = class(TCustomControl)
  private
    FActive: Boolean;
    FKind: TMaxxRuralLoadingKind;
    FPaintBox: TSkPaintBox;
    FPhase: Integer;
    FRenderer: TMaxxRuralSkiaRenderer;
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
    function ScaleFactor: Single;
    function ScaleMetric(const AValue: Integer): Integer;
    procedure SetActive(const AValue: Boolean);
    procedure SetKind(const AValue: TMaxxRuralLoadingKind);
    procedure TimerTick(Sender: TObject);
    procedure UpdatePaintBoxBounds;
    procedure UpdateTimer;
    procedure WMEraseBkgnd(var AMessage: TWMEraseBkgnd); message WM_ERASEBKGND;
  protected
    procedure ChangeScale(M, D: Integer); override;
    procedure CreateWnd; override;
    procedure Loaded; override;
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Redraw;
  published
    property Active: Boolean read FActive write SetActive default True;
    property Align;
    property Anchors;
    property Constraints;
    property Enabled;
    property Hint;
    property Kind: TMaxxRuralLoadingKind read FKind write SetKind default mlkSpinner;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop default False;
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
  MaxxRural.Components.DesignSystem.ColorTokens;

constructor TMaxxRuralLoading.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque, csReplicatable];
  Width := 160;
  Height := 48;
  TabStop := False;
  ParentColor := False;
  StyleElements := [];

  FActive := True;
  FKind := mlkSpinner;
  FPhase := 0;
  FRenderer := TMaxxRuralSkiaRenderer.Create;

  FPaintBox := TSkPaintBox.Create(Self);
  FPaintBox.Parent := Self;
  FPaintBox.SetSubComponent(True);
  FPaintBox.StyleElements := [];
  FPaintBox.OnDraw := PaintBoxDraw;

  FTimer := TTimer.Create(Self);
  FTimer.Enabled := False;
  FTimer.Interval := 120;
  FTimer.OnTimer := TimerTick;

  UpdatePaintBoxBounds;
  UpdateTimer;
end;

destructor TMaxxRuralLoading.Destroy;
begin
  FTimer.Free;
  FPaintBox.Free;
  FRenderer.Free;
  inherited;
end;

procedure TMaxxRuralLoading.ChangeScale(M, D: Integer);
begin
  inherited;
  UpdatePaintBoxBounds;
  InvalidateLoading;
end;

procedure TMaxxRuralLoading.CMEnabledChanged(var AMessage: TMessage);
begin
  inherited;
  UpdateTimer;
  InvalidateLoading;
end;

procedure TMaxxRuralLoading.CMVisibleChanged(var AMessage: TMessage);
begin
  inherited;
  UpdateTimer;
  InvalidateLoading;
end;

procedure TMaxxRuralLoading.CreateWnd;
begin
  inherited;
  UpdatePaintBoxBounds;
  UpdateTimer;
  InvalidateLoading;
end;

procedure TMaxxRuralLoading.DrawDots(const ACanvas: ISkCanvas; const ADest: TRectF;
  const AAlpha: Byte);
var
  I: Integer;
  LAlpha: Byte;
  LCenterX: Single;
  LPaint: ISkPaint;
  LRadius: Single;
  LSpacing: Single;
begin
  LRadius := ScaleMetric(5);
  LSpacing := ScaleMetric(20);
  LCenterX := (ADest.Width / 2) - LSpacing;
  LPaint := TSkPaint.Create(TSkPaintStyle.Fill);
  LPaint.AntiAlias := True;
  LPaint.Color := TMaxxRuralComponentColors.PrimaryDark;

  for I := 0 to 2 do
  begin
    LAlpha := 92;
    if (FPhase mod 3) = I then
      LAlpha := AAlpha;
    LPaint.Alpha := LAlpha;
    ACanvas.DrawCircle(LCenterX + (I * LSpacing), ADest.Height / 2, LRadius, LPaint);
  end;
end;

procedure TMaxxRuralLoading.DrawSkeleton(const ACanvas: ISkCanvas; const ADest: TRectF;
  const AAlpha: Byte);
var
  LBase: TAlphaColor;
  LHighlight: TAlphaColor;
  LOffset: Single;
  LRect: TRectF;
begin
  LBase := TMaxxRuralComponentColors.Alpha(229, 235, 229);
  LHighlight := TMaxxRuralComponentColors.Alpha(246, 248, 246);
  if TMaxxRuralComponentColors.IsDarkSurface(ParentSurfaceColor) then
  begin
    LBase := TMaxxRuralComponentColors.Alpha(18, 36, 24);
    LHighlight := TMaxxRuralComponentColors.Alpha(32, 54, 40);
  end;

  LRect := TRectF.Create(0, ScaleMetric(6), ScaleMetric(56), ScaleMetric(38));
  FRenderer.FillRoundRect(ACanvas, LRect, LBase, ScaleMetric(6), AAlpha);
  LRect := TRectF.Create(ScaleMetric(66), ScaleMetric(10), ADest.Width, ScaleMetric(18));
  FRenderer.FillRoundRect(ACanvas, LRect, LBase, ScaleMetric(4), AAlpha);
  LRect := TRectF.Create(ScaleMetric(66), ScaleMetric(28), ADest.Width - ScaleMetric(24),
    ScaleMetric(36));
  FRenderer.FillRoundRect(ACanvas, LRect, LBase, ScaleMetric(4), AAlpha);

  LOffset := (FPhase mod 8) / 8;
  LRect := TRectF.Create(ADest.Width * LOffset, ScaleMetric(10),
    (ADest.Width * LOffset) + ScaleMetric(44), ScaleMetric(18));
  FRenderer.FillRoundRect(ACanvas, LRect, LHighlight, ScaleMetric(4), 150);
end;

procedure TMaxxRuralLoading.DrawSpinner(const ACanvas: ISkCanvas; const ADest: TRectF;
  const AAlpha: Byte);
var
  LPaint: ISkPaint;
  LRect: TRectF;
  LSize: Single;
begin
  LSize := Min(ADest.Width, ADest.Height) - ScaleMetric(8);
  LRect := TRectF.Create((ADest.Width - LSize) / 2, (ADest.Height - LSize) / 2,
    (ADest.Width + LSize) / 2, (ADest.Height + LSize) / 2);

  LPaint := TSkPaint.Create(TSkPaintStyle.Stroke);
  LPaint.AntiAlias := True;
  LPaint.Color := TMaxxRuralComponentColors.ControlBorderForSurface(ParentSurfaceColor);
  LPaint.Alpha := 100;
  LPaint.StrokeCap := TSkStrokeCap.Round;
  LPaint.StrokeWidth := ScaleMetric(4);
  ACanvas.DrawArc(LRect, 0, 360, False, LPaint);

  LPaint.Color := TMaxxRuralComponentColors.PrimaryDark;
  LPaint.Alpha := AAlpha;
  ACanvas.DrawArc(LRect, -90 + (FPhase * 32), 250, False, LPaint);
end;

procedure TMaxxRuralLoading.InvalidateLoading;
begin
  UpdatePaintBoxBounds;
  if (FPaintBox <> nil) and HandleAllocated then
    FPaintBox.Redraw;
end;

procedure TMaxxRuralLoading.Loaded;
begin
  inherited;
  UpdatePaintBoxBounds;
  UpdateTimer;
  InvalidateLoading;
end;

procedure TMaxxRuralLoading.PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
  const ADest: TRectF; const AOpacity: Single);
var
  LAlpha: Byte;
begin
  if (ACanvas = nil) or (ADest.Width <= 0) or (ADest.Height <= 0) then
    Exit;

  ACanvas.Clear(ParentSurfaceColor);
  LAlpha := 255;
  if not Enabled then
    LAlpha := 120;

  case FKind of
    mlkDots:
      DrawDots(ACanvas, ADest, LAlpha);
    mlkSkeleton:
      DrawSkeleton(ACanvas, ADest, LAlpha);
  else
    DrawSpinner(ACanvas, ADest, LAlpha);
  end;
end;

function TMaxxRuralLoading.ParentSurfaceColor: TAlphaColor;
begin
  Result := TMaxxRuralComponentColors.ResolveParentSurface(Self);
end;

procedure TMaxxRuralLoading.Redraw;
begin
  if (FPaintBox <> nil) and HandleAllocated then
    FPaintBox.Redraw;
end;

procedure TMaxxRuralLoading.Resize;
begin
  inherited;
  UpdatePaintBoxBounds;
  Redraw;
end;

function TMaxxRuralLoading.ScaleFactor: Single;
begin
  Result := 1;
  if FPaintBox <> nil then
    Result := FPaintBox.ScaleFactor;
  if Result <= 0 then
    Result := 1;
end;

function TMaxxRuralLoading.ScaleMetric(const AValue: Integer): Integer;
begin
  Result := Round(AValue * ScaleFactor);
  if (AValue > 0) and (Result < 1) then
    Result := 1;
end;

procedure TMaxxRuralLoading.SetActive(const AValue: Boolean);
begin
  if FActive = AValue then
    Exit;
  FActive := AValue;
  UpdateTimer;
  InvalidateLoading;
end;

procedure TMaxxRuralLoading.SetKind(const AValue: TMaxxRuralLoadingKind);
begin
  if FKind = AValue then
    Exit;
  FKind := AValue;
  InvalidateLoading;
end;

procedure TMaxxRuralLoading.TimerTick(Sender: TObject);
begin
  Inc(FPhase);
  InvalidateLoading;
end;

procedure TMaxxRuralLoading.UpdatePaintBoxBounds;
var
  LHeight: Integer;
  LWidth: Integer;
begin
  if FPaintBox = nil then
    Exit;

  LWidth := Width;
  LHeight := Height;
  if HandleAllocated then
  begin
    LWidth := ClientWidth;
    LHeight := ClientHeight;
  end;

  if (FPaintBox.Left <> 0) or (FPaintBox.Top <> 0) or
    (FPaintBox.Width <> LWidth) or (FPaintBox.Height <> LHeight) then
    FPaintBox.SetBounds(0, 0, LWidth, LHeight);
end;

procedure TMaxxRuralLoading.UpdateTimer;
begin
  if FTimer = nil then
    Exit;
  FTimer.Enabled := FActive and Enabled and Visible and not (csDesigning in ComponentState);
end;

procedure TMaxxRuralLoading.WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
begin
  AMessage.Result := 1;
end;

end.
