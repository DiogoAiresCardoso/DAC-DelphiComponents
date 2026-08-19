unit DAC.Components.Controls.Progress;

interface

uses
  System.Classes,
  System.Skia,
  System.Types,
  System.UITypes,
  Winapi.Messages,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.Skia,
  DAC.Components.Controls.SystemText,
  DAC.Components.Skia.Renderer,
  DAC.Components.DesignSystem.Theme;

type
  TDACProgressKind = (
    mpkLinear,
    mpkCircular
  );

  TDACProgressStatus = (
    mpsNeutral,
    mpsSuccess,
    mpsWarning,
    mpsDanger,
    mpsInfo
  );

  TDACProgress = class(TCustomControl)
  private
    FKind: TDACProgressKind;
    FMaximum: Integer;
    FPaintBox: TSkPaintBox;
    FRenderer: TDACSkiaRenderer;
    FTextOverlay: TDACSystemTextOverlay;
    FShowValue: Boolean;
    FStatus: TDACProgressStatus;
    FThemeMode: TDACThemeMode;
    FValue: Integer;
    procedure CMEnabledChanged(var AMessage: TMessage); message CM_ENABLEDCHANGED;
    function AccentColor: TAlphaColor;
    procedure DrawArc(const ACanvas: ISkCanvas; const ARect: TRectF;
      const AStartAngle, ASweepAngle, AStrokeWidth: Single;
      const AColor: TAlphaColor; const AAlpha: Byte);
    procedure InvalidateProgress;
    procedure PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    function ParentSurfaceColor: TAlphaColor;
    function Percent: Single;
    function Pixels(const AValue: Integer): Integer;
    procedure SetKind(const AValue: TDACProgressKind);
    procedure SetMaximum(const AValue: Integer);
    procedure SetShowValue(const AValue: Boolean);
    procedure SetStatus(const AValue: TDACProgressStatus);
    procedure SetThemeMode(const AValue: TDACThemeMode);
    procedure SetValue(const AValue: Integer);
    function TrackColor: TAlphaColor;
    procedure ThemeChanged(Sender: TObject);
    procedure UpdatePaintBoxBounds;
    procedure WMEraseBkgnd(var AMessage: TWMEraseBkgnd); message WM_ERASEBKGND;
  protected
    procedure CreateWnd; override;
    procedure Loaded; override;
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ResolvedAccentColor: TAlphaColor;
    function ResolvedTrackColor: TAlphaColor;
    procedure Redraw;
  published
    property Align;
    property Anchors;
    property Constraints;
    property Enabled;
    property Hint;
    property Kind: TDACProgressKind read FKind write SetKind default mpkLinear;
    property Maximum: Integer read FMaximum write SetMaximum default 100;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property ShowValue: Boolean read FShowValue write SetShowValue default True;
    property Status: TDACProgressStatus read FStatus write SetStatus default mpsSuccess;
    property TabOrder;
    property TabStop default False;
    property ThemeMode: TDACThemeMode read FThemeMode write SetThemeMode default dtmInherit;
    property Value: Integer read FValue write SetValue default 0;
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
  System.SysUtils,
  DAC.Components.DesignSystem.Fonts,
  DAC.Components.DesignSystem.ComponentStyle,
  DAC.Components.DesignSystem.ControlTokens;

constructor TDACProgress.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque, csReplicatable];
  Width := Round(TDACComponentStyle.Resolve(dtmInherit).Tokens.Controls.ProgressDefaultWidth);
  Height := Round(TDACComponentStyle.Resolve(dtmInherit).Tokens.Controls.ProgressDefaultHeight);
  TabStop := False;
  ParentColor := False;
  StyleElements := [];

  FKind := mpkLinear;
  FMaximum := 100;
  FShowValue := True;
  FStatus := mpsSuccess;
  FValue := 0;
  FThemeMode := dtmInherit;
  TDACThemeManager.RegisterListener(Self, ThemeChanged);

  FRenderer := TDACSkiaRenderer.Create;
  FPaintBox := TSkPaintBox.Create(Self);
  FPaintBox.Parent := Self;
  FPaintBox.SetSubComponent(True);
  FPaintBox.StyleElements := [];
  FPaintBox.OnDraw := PaintBoxDraw;
  FTextOverlay := TDACSystemTextOverlay.Create(Self);
  FTextOverlay.Parent := Self;
  FTextOverlay.SetSubComponent(True);
  FTextOverlay.Align := alClient;

  UpdatePaintBoxBounds;
end;

destructor TDACProgress.Destroy;
begin
  TDACThemeManager.UnregisterListener(Self);
  FTextOverlay.Free;
  FPaintBox.Free;
  FRenderer.Free;
  inherited;
end;

function TDACProgress.AccentColor: TAlphaColor;
var
  LTokens: TDACControlTokens;
begin
  LTokens := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls;
  case FStatus of
    mpsWarning:
      Result := LTokens.ProgressWarning;
    mpsDanger:
      Result := LTokens.ProgressDanger;
    mpsInfo:
      Result := LTokens.ProgressInfo;
    mpsNeutral:
      Result := LTokens.ProgressNeutral;
  else
    Result := LTokens.Success;
  end;
end;
procedure TDACProgress.CMEnabledChanged(var AMessage: TMessage);
begin
  inherited;
  InvalidateProgress;
end;

procedure TDACProgress.CreateWnd;
begin
  inherited;
  UpdatePaintBoxBounds;
  InvalidateProgress;
end;

procedure TDACProgress.DrawArc(const ACanvas: ISkCanvas; const ARect: TRectF;
  const AStartAngle, ASweepAngle, AStrokeWidth: Single; const AColor: TAlphaColor;
  const AAlpha: Byte);
var
  LPaint: ISkPaint;
begin
  LPaint := TSkPaint.Create(TSkPaintStyle.Stroke);
  LPaint.AntiAlias := True;
  LPaint.Color := AColor;
  LPaint.Alpha := AAlpha;
  LPaint.StrokeCap := TSkStrokeCap.Round;
  LPaint.StrokeWidth := AStrokeWidth;
  ACanvas.DrawArc(ARect, AStartAngle, ASweepAngle, False, LPaint);
end;

procedure TDACProgress.InvalidateProgress;
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

procedure TDACProgress.Loaded;
begin
  inherited;
  UpdatePaintBoxBounds;
  InvalidateProgress;
end;

procedure TDACProgress.PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
  const ADest: TRectF; const AOpacity: Single);
var
  LAlpha: Byte;
  LCenter: TPointF;
  LFontColor: TAlphaColor;
  LProgressRect: TRectF;
  LRadius: Single;
  LRect: TRectF;
  LScale: Single;
  LStrokeWidth: Single;
  LText: string;
  LTrackRect: TRectF;
  LTokens: TDACControlTokens;
begin
  if ACanvas = nil then
    Exit;

  FRenderer.BeginNativeText(FTextOverlay);
  try

  LTokens := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls;
  LScale := LTokens.BorderWidth;
  ACanvas.Clear(ParentSurfaceColor);
  LAlpha := LTokens.AlphaOpaque;
  if not Enabled then
    LAlpha := LTokens.ProgressDisabledAlpha;

  if FKind = mpkCircular then
  begin
    LStrokeWidth := Pixels(Round(LTokens.ProgressCircularThickness));
    LRadius := (Min(ADest.Width, ADest.Height) - LStrokeWidth) / 2;
    LCenter := TPointF.Create(ADest.Width / 2, ADest.Height / 2);
    LRect := TRectF.Create(LCenter.X - LRadius, LCenter.Y - LRadius,
      LCenter.X + LRadius, LCenter.Y + LRadius);
    DrawArc(ACanvas, LRect, -90, 360, LStrokeWidth, TrackColor, LAlpha);
    DrawArc(ACanvas, LRect, -90, 360 * Percent, LStrokeWidth, AccentColor, LAlpha);
    if FShowValue then
    begin
      LText := Format('%d%%', [Round(Percent * 100)]);
      LFontColor := LTokens.ProgressValueText;
      FRenderer.TextCentered(ACanvas, LText,
        TDACComponentStyle.FontFamily,
        TRectF.Create(0, 0, ADest.Width, ADest.Height), LTokens.ProgressValueTextSize, LFontColor, True);
    end;
    Exit;
  end;

  LTrackRect := FRenderer.SnapRect(TRectF.Create(0,
    (ADest.Height - Pixels(Round(LTokens.ProgressLinearThickness))) / 2,
    ADest.Width, (ADest.Height + Pixels(Round(LTokens.ProgressLinearThickness))) / 2), LScale);
  LTrackRect.Inflate(-(LTokens.BorderWidth / 2) / LScale,
    -(LTokens.BorderWidth / 2) / LScale);
  FRenderer.FillRoundRect(ACanvas, LTrackRect, TrackColor, LTrackRect.Height / 2, LAlpha);

  LProgressRect := LTrackRect;
  LProgressRect.Right := LProgressRect.Left + (LTrackRect.Width * Percent);
  if LProgressRect.Width > 0 then
    FRenderer.FillRoundRect(ACanvas, LProgressRect, AccentColor,
      LProgressRect.Height / 2, LAlpha);

  if FShowValue then
  begin
    LText := Format('%d%%', [Round(Percent * 100)]);
    LFontColor := LTokens.ProgressValueText;
    FRenderer.Text(ACanvas, LText, TDACComponentStyle.FontFamily,
      ADest.Width - Pixels(Round(LTokens.ProgressValueTextInset)),
      (ADest.Height / 2) + Pixels(Round(LTokens.ProgressValueTextOffset)),
      LTokens.ProgressValueTextSize, LFontColor, True,
      Pixels(Round(LTokens.ProgressValueTextInset - LTokens.ProgressValueTextOffset)));
  end;
  finally
    FRenderer.EndNativeText;
  end;
end;

function TDACProgress.ParentSurfaceColor: TAlphaColor;
begin
  Result := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls.PopupBackground;
end;

function TDACProgress.Percent: Single;
begin
  if FMaximum <= 0 then
    Exit(0);
  Result := EnsureRange(FValue / FMaximum, 0, 1);
end;

procedure TDACProgress.Redraw;
begin
  InvalidateProgress;
end;

function TDACProgress.ResolvedAccentColor: TAlphaColor;
begin
  Result := AccentColor;
end;

function TDACProgress.ResolvedTrackColor: TAlphaColor;
begin
  Result := TrackColor;
end;

procedure TDACProgress.Resize;
begin
  inherited;
  UpdatePaintBoxBounds;
  InvalidateProgress;
end;

function TDACProgress.Pixels(const AValue: Integer): Integer;
begin
  if AValue <= 0 then
    Exit(0);
  Result := Max(1, Round(AValue * 1));
end;

procedure TDACProgress.SetKind(const AValue: TDACProgressKind);
begin
  if FKind = AValue then
    Exit;
  FKind := AValue;
  InvalidateProgress;
end;

procedure TDACProgress.SetMaximum(const AValue: Integer);
begin
  if FMaximum = AValue then
    Exit;
  FMaximum := Max(1, AValue);
  if FValue > FMaximum then
    FValue := FMaximum;
  InvalidateProgress;
end;

procedure TDACProgress.SetShowValue(const AValue: Boolean);
begin
  if FShowValue = AValue then
    Exit;
  FShowValue := AValue;
  InvalidateProgress;
end;

procedure TDACProgress.SetStatus(const AValue: TDACProgressStatus);
begin
  if FStatus = AValue then
    Exit;
  FStatus := AValue;
  InvalidateProgress;
end;

procedure TDACProgress.SetThemeMode(const AValue: TDACThemeMode);
begin
  if FThemeMode = AValue then
    Exit;
  FThemeMode := AValue;
  ThemeChanged(Self);
end;

procedure TDACProgress.SetValue(const AValue: Integer);
begin
  if FValue = AValue then
    Exit;
  FValue := EnsureRange(AValue, 0, FMaximum);
  InvalidateProgress;
end;

function TDACProgress.TrackColor: TAlphaColor;
begin
  Result := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls.ProgressTrack;
end;

procedure TDACProgress.ThemeChanged(Sender: TObject);
begin
  InvalidateProgress;
end;

procedure TDACProgress.UpdatePaintBoxBounds;
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

procedure TDACProgress.WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
begin
  AMessage.Result := 1;
end;

end.

