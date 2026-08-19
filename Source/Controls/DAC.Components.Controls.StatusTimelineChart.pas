unit DAC.Components.Controls.StatusTimelineChart;

interface

uses
  System.Classes,
  System.Skia,
  System.Types,
  System.UITypes,
  Winapi.Messages,
  Winapi.Windows,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.Skia,
  DAC.Components.Controls.SystemText,
  DAC.Components.DesignSystem.Theme,
  DAC.Components.Skia.Renderer;

type
  TDACStatusTimelineState = (
    stsOnline,
    stsUnstable,
    stsOffline,
    stsIndeterminate
  );

  TDACStatusTimelineSegment = class(TCollectionItem)
  private
    FFinishAt: TDateTime;
    FStartAt: TDateTime;
    FState: TDACStatusTimelineState;
    procedure SetFinishAt(const AValue: TDateTime);
    procedure SetStartAt(const AValue: TDateTime);
    procedure SetState(const AValue: TDACStatusTimelineState);
  published
    property StartAt: TDateTime read FStartAt write SetStartAt;
    property FinishAt: TDateTime read FFinishAt write SetFinishAt;
    property State: TDACStatusTimelineState read FState write SetState
      default stsIndeterminate;
  end;

  TDACStatusTimelineChart = class;

  TDACStatusTimelineSegments = class(TOwnedCollection)
  private
    function GetItem(const AIndex: Integer): TDACStatusTimelineSegment;
    procedure SetItem(const AIndex: Integer;
      const AValue: TDACStatusTimelineSegment);
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TDACStatusTimelineChart);
    function Add: TDACStatusTimelineSegment;
    property Items[const AIndex: Integer]: TDACStatusTimelineSegment
      read GetItem write SetItem; default;
  end;

  TDACStatusTimelineNormalizedSegment = record
    StartAt: TDateTime;
    FinishAt: TDateTime;
    State: TDACStatusTimelineState;
  end;

  TDACStatusTimelineChart = class(TCustomControl)
  private
    FCurrentState: TDACStatusTimelineState;
    FEmptyText: string;
    FPaintBox: TSkPaintBox;
    FRenderer: TDACSkiaRenderer;
    FTextOverlay: TDACSystemTextOverlay;
    FSegments: TDACStatusTimelineSegments;
    FShowAxis: Boolean;
    FShowCurrentMarker: Boolean;
    FShowFrame: Boolean;
    FShowLegend: Boolean;
    FThemeMode: TDACThemeMode;
    FWindowFinish: TDateTime;
    FWindowStart: TDateTime;
    function BuildNormalizedSegments:
      TArray<TDACStatusTimelineNormalizedSegment>;
    function ChartRect(const ADest: TRectF): TRectF;
    procedure DrawAxis(const ACanvas: ISkCanvas; const ARect: TRectF);
    procedure DrawEmpty(const ACanvas: ISkCanvas; const ARect: TRectF);
    procedure DrawFrame(const ACanvas: ISkCanvas; const ADest: TRectF);
    procedure DrawLegend(const ACanvas: ISkCanvas; const ADest: TRectF);
    procedure DrawTimeline(const ACanvas: ISkCanvas; const ARect: TRectF);
    function ParentSurfaceColor: TAlphaColor;
    procedure PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    function StateColor(const AState: TDACStatusTimelineState): TAlphaColor;
    function StateLabel(const AState: TDACStatusTimelineState): string;
    function StateY(const AState: TDACStatusTimelineState;
      const ARect: TRectF): Single;
    function TimeX(const AValue: TDateTime; const ARect: TRectF): Single;
    procedure SetCurrentState(const AValue: TDACStatusTimelineState);
    procedure SetEmptyText(const AValue: string);
    procedure SetSegments(const AValue: TDACStatusTimelineSegments);
    procedure SetShowAxis(const AValue: Boolean);
    procedure SetShowCurrentMarker(const AValue: Boolean);
    procedure SetShowFrame(const AValue: Boolean);
    procedure SetShowLegend(const AValue: Boolean);
    procedure SetThemeMode(const AValue: TDACThemeMode);
    procedure SetWindowFinish(const AValue: TDateTime);
    procedure SetWindowStart(const AValue: TDateTime);
    procedure ThemeChanged(Sender: TObject);
    procedure UpdatePaintBoxBounds;
    procedure WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
      message WM_ERASEBKGND;
  protected
    procedure CreateWnd; override;
    procedure Loaded; override;
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function AddSegment(const AStartAt, AFinishAt: TDateTime;
      const AState: TDACStatusTimelineState): TDACStatusTimelineSegment;
    procedure Clear;
    function NormalizedSegmentCount: Integer;
    procedure Redraw;
  published
    property Align;
    property Anchors;
    property Constraints;
    property CurrentState: TDACStatusTimelineState read FCurrentState
      write SetCurrentState default stsIndeterminate;
    property EmptyText: string read FEmptyText write SetEmptyText;
    property Enabled;
    property Hint;
    property ParentShowHint;
    property PopupMenu;
    property Segments: TDACStatusTimelineSegments read FSegments
      write SetSegments;
    property ShowAxis: Boolean read FShowAxis write SetShowAxis default True;
    property ShowCurrentMarker: Boolean read FShowCurrentMarker
      write SetShowCurrentMarker default True;
    property ShowFrame: Boolean read FShowFrame write SetShowFrame default True;
    property ShowHint;
    property ShowLegend: Boolean read FShowLegend write SetShowLegend default True;
    property TabOrder;
    property TabStop default False;
    property ThemeMode: TDACThemeMode read FThemeMode write SetThemeMode
      default dtmInherit;
    property Visible;
    property WindowFinish: TDateTime read FWindowFinish write SetWindowFinish;
    property WindowStart: TDateTime read FWindowStart write SetWindowStart;
  end;

implementation

uses
  System.DateUtils,
  System.Generics.Collections,
  System.Generics.Defaults,
  System.Math,
  System.SysUtils,
  DAC.Components.DesignSystem.ColorTokens,
  DAC.Components.DesignSystem.ComponentStyle,
  DAC.Components.DesignSystem.Fonts,
  DAC.Components.DesignSystem.SemanticColors;

{ TDACStatusTimelineSegment }

procedure TDACStatusTimelineSegment.SetFinishAt(const AValue: TDateTime);
begin
  if FFinishAt = AValue then
    Exit;
  FFinishAt := AValue;
  Changed(False);
end;

procedure TDACStatusTimelineSegment.SetStartAt(const AValue: TDateTime);
begin
  if FStartAt = AValue then
    Exit;
  FStartAt := AValue;
  Changed(False);
end;

procedure TDACStatusTimelineSegment.SetState(
  const AValue: TDACStatusTimelineState);
begin
  if FState = AValue then
    Exit;
  FState := AValue;
  Changed(False);
end;

{ TDACStatusTimelineSegments }

constructor TDACStatusTimelineSegments.Create(
  AOwner: TDACStatusTimelineChart);
begin
  inherited Create(AOwner, TDACStatusTimelineSegment);
end;

function TDACStatusTimelineSegments.Add: TDACStatusTimelineSegment;
begin
  Result := inherited Add as TDACStatusTimelineSegment;
end;

function TDACStatusTimelineSegments.GetItem(
  const AIndex: Integer): TDACStatusTimelineSegment;
begin
  Result := inherited GetItem(AIndex) as TDACStatusTimelineSegment;
end;

procedure TDACStatusTimelineSegments.SetItem(const AIndex: Integer;
  const AValue: TDACStatusTimelineSegment);
begin
  inherited SetItem(AIndex, AValue);
end;

procedure TDACStatusTimelineSegments.Update(Item: TCollectionItem);
begin
  inherited;
  if GetOwner is TDACStatusTimelineChart then
    TDACStatusTimelineChart(GetOwner).Redraw;
end;

{ TDACStatusTimelineChart }

constructor TDACStatusTimelineChart.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque, csReplicatable];
  Width := 720;
  Height := 220;
  TabStop := False;
  ParentColor := False;
  StyleElements := [];
  FCurrentState := stsIndeterminate;
  FEmptyText := 'Sem dados no periodo';
  FShowAxis := True;
  FShowCurrentMarker := True;
  FShowFrame := True;
  FShowLegend := True;
  FThemeMode := dtmInherit;
  FSegments := TDACStatusTimelineSegments.Create(Self);
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
  TDACThemeManager.RegisterListener(Self, ThemeChanged);
  UpdatePaintBoxBounds;
end;

destructor TDACStatusTimelineChart.Destroy;
begin
  TDACThemeManager.UnregisterListener(Self);
  FTextOverlay.Free;
  FPaintBox.Free;
  FRenderer.Free;
  FSegments.Free;
  inherited;
end;

function TDACStatusTimelineChart.AddSegment(const AStartAt,
  AFinishAt: TDateTime; const AState: TDACStatusTimelineState):
  TDACStatusTimelineSegment;
begin
  Result := FSegments.Add;
  Result.StartAt := AStartAt;
  Result.FinishAt := AFinishAt;
  Result.State := AState;
end;

function TDACStatusTimelineChart.BuildNormalizedSegments:
  TArray<TDACStatusTimelineNormalizedSegment>;
var
  I: Integer;
  LCount: Integer;
  LFinish: TDateTime;
  LStart: TDateTime;
  LValues: TArray<TDACStatusTimelineNormalizedSegment>;
begin
  SetLength(Result, 0);
  if (FWindowFinish <= FWindowStart) or (FSegments.Count = 0) then
    Exit;

  SetLength(LValues, FSegments.Count);
  LCount := 0;
  for I := 0 to FSegments.Count - 1 do
  begin
    LStart := Max(FSegments[I].StartAt, FWindowStart);
    LFinish := Min(FSegments[I].FinishAt, FWindowFinish);
    if LFinish <= LStart then
      Continue;
    LValues[LCount].StartAt := LStart;
    LValues[LCount].FinishAt := LFinish;
    LValues[LCount].State := FSegments[I].State;
    Inc(LCount);
  end;
  SetLength(LValues, LCount);
  TArray.Sort<TDACStatusTimelineNormalizedSegment>(LValues,
    TComparer<TDACStatusTimelineNormalizedSegment>.Construct(
      function(const ALeft,
        ARight: TDACStatusTimelineNormalizedSegment): Integer
      begin
        if ALeft.StartAt < ARight.StartAt then
          Result := -1
        else if ALeft.StartAt > ARight.StartAt then
          Result := 1
        else
          Result := 0;
      end));

  LCount := 0;
  for I := 0 to High(LValues) do
  begin
    LStart := LValues[I].StartAt;
    if (LCount > 0) and (LStart < Result[LCount - 1].FinishAt) then
      LStart := Result[LCount - 1].FinishAt;
    if LValues[I].FinishAt <= LStart then
      Continue;
    SetLength(Result, LCount + 1);
    Result[LCount] := LValues[I];
    Result[LCount].StartAt := LStart;
    Inc(LCount);
  end;
end;

function TDACStatusTimelineChart.ChartRect(const ADest: TRectF): TRectF;
var
  LBottom: Single;
begin
  LBottom := 16;
  if FShowAxis then
    LBottom := LBottom + 24;
  if FShowLegend then
    LBottom := LBottom + 30;
  Result := TRectF.Create(44, 20, ADest.Width - 24,
    ADest.Height - LBottom);
  if Result.Right <= Result.Left then
    Result.Right := Result.Left + 1;
  if Result.Bottom <= Result.Top then
    Result.Bottom := Result.Top + 1;
end;

procedure TDACStatusTimelineChart.Clear;
begin
  FSegments.Clear;
  Redraw;
end;

procedure TDACStatusTimelineChart.CreateWnd;
begin
  inherited;
  UpdatePaintBoxBounds;
  Redraw;
end;

procedure TDACStatusTimelineChart.DrawAxis(const ACanvas: ISkCanvas;
  const ARect: TRectF);
var
  I: Integer;
  LAt: TDateTime;
  LColor: TAlphaColor;
  LPaint: ISkPaint;
  LX: Single;
  LText: string;
begin
  LColor := TDACComponentColors.ControlBorder;
  LPaint := TSkPaint.Create(TSkPaintStyle.Stroke);
  LPaint.AntiAlias := True;
  LPaint.Color := LColor;
  LPaint.StrokeWidth := 1;
  for I := 0 to 4 do
  begin
    LX := ARect.Left + (ARect.Width * I / 4);
    ACanvas.DrawLine(PointF(LX, ARect.Top), PointF(LX, ARect.Bottom), LPaint);
    LAt := FWindowStart + ((FWindowFinish - FWindowStart) * I / 4);
    LText := FormatDateTime('hh:nn', LAt);
    FRenderer.TextCentered(ACanvas, LText, TDACComponentStyle.FontFamily,
      TRectF.Create(LX - 35, ARect.Bottom + 3, LX + 35,
        ARect.Bottom + 21), 10, TDACComponentColors.TextSecondary,
      False, 70);
  end;
end;

procedure TDACStatusTimelineChart.DrawEmpty(const ACanvas: ISkCanvas;
  const ARect: TRectF);
begin
  FRenderer.TextCentered(ACanvas, FEmptyText, TDACComponentStyle.FontFamily,
    ARect, 12, TDACComponentColors.TextSecondary, False, ARect.Width - 16);
end;

procedure TDACStatusTimelineChart.DrawFrame(const ACanvas: ISkCanvas;
  const ADest: TRectF);
var
  LRect: TRectF;
begin
  LRect := TRectF.Create(0.5, 0.5, ADest.Width - 0.5,
    ADest.Height - 0.5);
  FRenderer.FillRoundRect(ACanvas, LRect,
    TDACComponentColors.ControlBackground, 8, 255);
  FRenderer.StrokeRoundRect(ACanvas, LRect,
    TDACComponentColors.ControlBorder, 8, 1, 255);
end;

procedure TDACStatusTimelineChart.DrawLegend(const ACanvas: ISkCanvas;
  const ADest: TRectF);
const
  LStates: array[0..3] of TDACStatusTimelineState =
    (stsOnline, stsUnstable, stsOffline, stsIndeterminate);
var
  I: Integer;
  LItemWidth: Single;
  LPaint: ISkPaint;
  LX: Single;
  LY: Single;
begin
  LItemWidth := Min(135, (ADest.Width - 32) / 4);
  LX := Max(16, (ADest.Width - (LItemWidth * 4)) / 2);
  LY := ADest.Height - 17;
  for I := 0 to 3 do
  begin
    LPaint := TSkPaint.Create(TSkPaintStyle.Fill);
    LPaint.AntiAlias := True;
    LPaint.Color := StateColor(LStates[I]);
    ACanvas.DrawCircle(LX + 5, LY - 4, 4, LPaint);
    FRenderer.Text(ACanvas, StateLabel(LStates[I]),
      TDACComponentStyle.FontFamily, LX + 15, LY, 10,
      TDACComponentColors.TextSecondary, False, LItemWidth - 18);
    LX := LX + LItemWidth;
  end;
end;

procedure TDACStatusTimelineChart.DrawTimeline(const ACanvas: ISkCanvas;
  const ARect: TRectF);
var
  I: Integer;
  LCurrentPaint: ISkPaint;
  LLinePaint: ISkPaint;
  LSegments: TArray<TDACStatusTimelineNormalizedSegment>;
  LX1: Single;
  LX2: Single;
  LY: Single;
  LPreviousY: Single;
begin
  LSegments := BuildNormalizedSegments;
  if Length(LSegments) = 0 then
  begin
    DrawEmpty(ACanvas, ARect);
    Exit;
  end;

  LPreviousY := 0;
  for I := 0 to High(LSegments) do
  begin
    LX1 := TimeX(LSegments[I].StartAt, ARect);
    LX2 := TimeX(LSegments[I].FinishAt, ARect);
    LY := StateY(LSegments[I].State, ARect);
    LLinePaint := TSkPaint.Create(TSkPaintStyle.Stroke);
    LLinePaint.AntiAlias := True;
    LLinePaint.Color := StateColor(LSegments[I].State);
    LLinePaint.StrokeWidth := 3;
    LLinePaint.StrokeCap := TSkStrokeCap.Square;
    if (I > 0) and (Abs(LSegments[I - 1].FinishAt -
      LSegments[I].StartAt) < OneMillisecond) then
      ACanvas.DrawLine(PointF(LX1, LPreviousY), PointF(LX1, LY),
        LLinePaint);
    ACanvas.DrawLine(PointF(LX1, LY), PointF(LX2, LY), LLinePaint);
    LPreviousY := LY;
  end;

  if FShowCurrentMarker then
  begin
    LCurrentPaint := TSkPaint.Create(TSkPaintStyle.Fill);
    LCurrentPaint.AntiAlias := True;
    LCurrentPaint.Color := StateColor(FCurrentState);
    ACanvas.DrawCircle(TimeX(LSegments[High(LSegments)].FinishAt, ARect),
      StateY(FCurrentState, ARect), 5, LCurrentPaint);
  end;
end;

procedure TDACStatusTimelineChart.Loaded;
begin
  inherited;
  UpdatePaintBoxBounds;
  Redraw;
end;

function TDACStatusTimelineChart.NormalizedSegmentCount: Integer;
begin
  Result := Length(BuildNormalizedSegments);
end;

procedure TDACStatusTimelineChart.PaintBoxDraw(Sender: TObject;
  const ACanvas: ISkCanvas; const ADest: TRectF; const AOpacity: Single);
var
  LRect: TRectF;
begin
  if ACanvas = nil then
    Exit;
  FRenderer.BeginNativeText(FTextOverlay);
  try
  ACanvas.Clear(ParentSurfaceColor);
  if FShowFrame then
    DrawFrame(ACanvas, ADest);
  LRect := ChartRect(ADest);
  if FShowAxis and (FWindowFinish > FWindowStart) then
    DrawAxis(ACanvas, LRect);
  DrawTimeline(ACanvas, LRect);
  if FShowLegend then
    DrawLegend(ACanvas, ADest);
  finally
    FRenderer.EndNativeText;
  end;
end;

function TDACStatusTimelineChart.ParentSurfaceColor: TAlphaColor;
begin
  Result := TDACComponentColors.ResolveParentSurface(Self);
end;

procedure TDACStatusTimelineChart.Redraw;
begin
  if (FPaintBox = nil) or (csDestroying in ComponentState) then
    Exit;
  UpdatePaintBoxBounds;
  if csDesigning in ComponentState then
  begin
    if Parent <> nil then
      FPaintBox.Redraw;
    Invalidate;
    Exit;
  end;
  if (Parent <> nil) and HandleAllocated and Parent.HandleAllocated then
    FPaintBox.Redraw;
  if HandleAllocated then
    Invalidate;
end;

procedure TDACStatusTimelineChart.Resize;
begin
  inherited;
  UpdatePaintBoxBounds;
  Redraw;
end;

procedure TDACStatusTimelineChart.SetCurrentState(
  const AValue: TDACStatusTimelineState);
begin
  if FCurrentState = AValue then
    Exit;
  FCurrentState := AValue;
  Redraw;
end;

procedure TDACStatusTimelineChart.SetEmptyText(const AValue: string);
begin
  if FEmptyText = AValue then
    Exit;
  FEmptyText := AValue;
  Redraw;
end;

procedure TDACStatusTimelineChart.SetSegments(
  const AValue: TDACStatusTimelineSegments);
begin
  FSegments.Assign(AValue);
end;

procedure TDACStatusTimelineChart.SetShowAxis(const AValue: Boolean);
begin
  if FShowAxis = AValue then
    Exit;
  FShowAxis := AValue;
  Redraw;
end;

procedure TDACStatusTimelineChart.SetShowCurrentMarker(
  const AValue: Boolean);
begin
  if FShowCurrentMarker = AValue then
    Exit;
  FShowCurrentMarker := AValue;
  Redraw;
end;

procedure TDACStatusTimelineChart.SetShowFrame(const AValue: Boolean);
begin
  if FShowFrame = AValue then
    Exit;
  FShowFrame := AValue;
  Redraw;
end;

procedure TDACStatusTimelineChart.SetShowLegend(const AValue: Boolean);
begin
  if FShowLegend = AValue then
    Exit;
  FShowLegend := AValue;
  Redraw;
end;

procedure TDACStatusTimelineChart.SetThemeMode(const AValue: TDACThemeMode);
begin
  if FThemeMode = AValue then
    Exit;
  FThemeMode := AValue;
  ThemeChanged(Self);
end;

procedure TDACStatusTimelineChart.SetWindowFinish(const AValue: TDateTime);
begin
  if FWindowFinish = AValue then
    Exit;
  FWindowFinish := AValue;
  Redraw;
end;

procedure TDACStatusTimelineChart.SetWindowStart(const AValue: TDateTime);
begin
  if FWindowStart = AValue then
    Exit;
  FWindowStart := AValue;
  Redraw;
end;

function TDACStatusTimelineChart.StateColor(
  const AState: TDACStatusTimelineState): TAlphaColor;
begin
  case AState of
    stsOnline:
      Result := TDACSemanticColors.AccentFor(mssSuccess);
    stsUnstable:
      Result := TDACSemanticColors.AccentFor(mssWarning);
    stsOffline:
      Result := TDACSemanticColors.AccentFor(mssDanger);
  else
    Result := TDACSemanticColors.AccentFor(mssNeutral);
  end;
end;

function TDACStatusTimelineChart.StateLabel(
  const AState: TDACStatusTimelineState): string;
begin
  case AState of
    stsOnline: Result := 'Online';
    stsUnstable: Result := 'Instavel';
    stsOffline: Result := 'Offline';
  else
    Result := 'Indeterminado';
  end;
end;

function TDACStatusTimelineChart.StateY(
  const AState: TDACStatusTimelineState; const ARect: TRectF): Single;
begin
  case AState of
    stsOnline: Result := ARect.Top + (ARect.Height * 0.12);
    stsUnstable: Result := ARect.Top + (ARect.Height * 0.38);
    stsOffline: Result := ARect.Top + (ARect.Height * 0.64);
  else
    Result := ARect.Top + (ARect.Height * 0.88);
  end;
end;

procedure TDACStatusTimelineChart.ThemeChanged(Sender: TObject);
begin
  if (FThemeMode <> dtmInherit) and (Sender <> Self) then
    Exit;
  Redraw;
end;

function TDACStatusTimelineChart.TimeX(const AValue: TDateTime;
  const ARect: TRectF): Single;
begin
  if FWindowFinish <= FWindowStart then
    Exit(ARect.Left);
  Result := ARect.Left + ((AValue - FWindowStart) /
    (FWindowFinish - FWindowStart) * ARect.Width);
  Result := EnsureRange(Result, ARect.Left, ARect.Right);
end;

procedure TDACStatusTimelineChart.UpdatePaintBoxBounds;
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
  FPaintBox.SetBounds(0, 0, LWidth, LHeight);
end;

procedure TDACStatusTimelineChart.WMEraseBkgnd(
  var AMessage: TWMEraseBkgnd);
var
  LBrush: HBRUSH;
begin
  LBrush := CreateSolidBrush(ColorToRGB(
    TDACComponentColors.ToVclColor(ParentSurfaceColor)));
  try
    Winapi.Windows.FillRect(AMessage.DC, ClientRect, LBrush);
  finally
    DeleteObject(LBrush);
  end;
  AMessage.Result := 1;
end;

end.
