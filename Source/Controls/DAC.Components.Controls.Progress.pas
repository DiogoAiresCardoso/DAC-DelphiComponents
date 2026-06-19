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
  DAC.Components.Skia.Renderer;

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
    FShowValue: Boolean;
    FStatus: TDACProgressStatus;
    FValue: Integer;
    procedure CMEnabledChanged(var AMessage: TMessage); message CM_ENABLEDCHANGED;
    function AccentColor: TAlphaColor;
    procedure DrawArc(const ACanvas: ISkCanvas; const ARect: TRectF;
      const AStartAngle, ASweepAngle, AStrokeWidth: Single;
      const AColor: TAlphaColor; const AAlpha: Byte = 255);
    procedure InvalidateProgress;
    procedure PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    function ParentSurfaceColor: TAlphaColor;
    function Percent: Single;
    function ScaleFactor: Single;
    function ScaleMetric(const AValue: Integer): Integer;
    procedure SetKind(const AValue: TDACProgressKind);
    procedure SetMaximum(const AValue: Integer);
    procedure SetShowValue(const AValue: Boolean);
    procedure SetStatus(const AValue: TDACProgressStatus);
    procedure SetValue(const AValue: Integer);
    function TrackColor: TAlphaColor;
    procedure UpdatePaintBoxBounds;
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
  DAC.Components.DesignSystem.ColorTokens,
  DAC.Components.DesignSystem.Fonts;

constructor TDACProgress.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque, csReplicatable];
  Width := 260;
  Height := 28;
  TabStop := False;
  ParentColor := False;
  StyleElements := [];

  FKind := mpkLinear;
  FMaximum := 100;
  FShowValue := True;
  FStatus := mpsSuccess;
  FValue := 0;

  FRenderer := TDACSkiaRenderer.Create;
  FPaintBox := TSkPaintBox.Create(Self);
  FPaintBox.Parent := Self;
  FPaintBox.SetSubComponent(True);
  FPaintBox.StyleElements := [];
  FPaintBox.OnDraw := PaintBoxDraw;

  UpdatePaintBoxBounds;
end;

destructor TDACProgress.Destroy;
begin
  FPaintBox.Free;
  FRenderer.Free;
  inherited;
end;

function TDACProgress.AccentColor: TAlphaColor;
begin
  case FStatus of
    mpsWarning:
      Result := TDACComponentColors.Warning;
    mpsDanger:
      Result := TDACComponentColors.Danger;
    mpsInfo:
      Result := TDACComponentColors.Alpha(43, 125, 233);
    mpsNeutral:
      Result := TDACComponentColors.Alpha(71, 85, 105);
  else
    Result := TDACComponentColors.Primary;
  end;
end;

procedure TDACProgress.ChangeScale(M, D: Integer);
begin
  inherited;
  UpdatePaintBoxBounds;
  InvalidateProgress;
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
  UpdatePaintBoxBounds;
  if (FPaintBox <> nil) and HandleAllocated then
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
begin
  if ACanvas = nil then
    Exit;

  LScale := ScaleFactor;
  ACanvas.Clear(ParentSurfaceColor);
  LAlpha := 255;
  if not Enabled then
    LAlpha := 120;

  if FKind = mpkCircular then
  begin
    LStrokeWidth := ScaleMetric(8);
    LRadius := (Min(ADest.Width, ADest.Height) - LStrokeWidth) / 2;
    LCenter := TPointF.Create(ADest.Width / 2, ADest.Height / 2);
    LRect := TRectF.Create(LCenter.X - LRadius, LCenter.Y - LRadius,
      LCenter.X + LRadius, LCenter.Y + LRadius);
    DrawArc(ACanvas, LRect, -90, 360, LStrokeWidth, TrackColor, LAlpha);
    DrawArc(ACanvas, LRect, -90, 360 * Percent, LStrokeWidth, AccentColor, LAlpha);
    if FShowValue then
    begin
      LText := Format('%d%%', [Round(Percent * 100)]);
      LFontColor := TDACComponentColors.ControlTextForSurface(ParentSurfaceColor);
      FRenderer.TextCentered(ACanvas, LText,
        TDACComponentFontInstaller.FontFamily,
        TRectF.Create(0, 0, ADest.Width, ADest.Height), 13, LFontColor, True);
    end;
    Exit;
  end;

  LTrackRect := FRenderer.SnapRect(TRectF.Create(0, (ADest.Height - ScaleMetric(8)) / 2,
    ADest.Width, (ADest.Height + ScaleMetric(8)) / 2), LScale);
  LTrackRect.Inflate(-0.5 / LScale, -0.5 / LScale);
  FRenderer.FillRoundRect(ACanvas, LTrackRect, TrackColor, LTrackRect.Height / 2, LAlpha);

  LProgressRect := LTrackRect;
  LProgressRect.Right := LProgressRect.Left + (LTrackRect.Width * Percent);
  if LProgressRect.Width > 0 then
    FRenderer.FillRoundRect(ACanvas, LProgressRect, AccentColor,
      LProgressRect.Height / 2, LAlpha);

  if FShowValue then
  begin
    LText := Format('%d%%', [Round(Percent * 100)]);
    LFontColor := TDACComponentColors.ControlTextForSurface(ParentSurfaceColor);
    FRenderer.Text(ACanvas, LText, TDACComponentFontInstaller.FontFamily,
      ADest.Width - ScaleMetric(36), (ADest.Height / 2) + ScaleMetric(4),
      9, LFontColor, True, ScaleMetric(34));
  end;
end;

function TDACProgress.ParentSurfaceColor: TAlphaColor;
begin
  Result := TDACComponentColors.ResolveParentSurface(Self);
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

procedure TDACProgress.Resize;
begin
  inherited;
  UpdatePaintBoxBounds;
  InvalidateProgress;
end;

function TDACProgress.ScaleFactor: Single;
begin
  Result := 1;
  if FPaintBox <> nil then
    Result := FPaintBox.ScaleFactor;
end;

function TDACProgress.ScaleMetric(const AValue: Integer): Integer;
begin
  if AValue <= 0 then
    Exit(0);
  Result := Max(1, Round(AValue * ScaleFactor));
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

procedure TDACProgress.SetValue(const AValue: Integer);
begin
  if FValue = AValue then
    Exit;
  FValue := EnsureRange(AValue, 0, FMaximum);
  InvalidateProgress;
end;

function TDACProgress.TrackColor: TAlphaColor;
begin
  if TDACComponentColors.IsDarkSurface(ParentSurfaceColor) then
    Exit(TDACComponentColors.Alpha(38, 58, 44));
  Result := TDACComponentColors.Alpha(226, 232, 240);
end;

procedure TDACProgress.UpdatePaintBoxBounds;
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

procedure TDACProgress.WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
begin
  AMessage.Result := 1;
end;

end.

