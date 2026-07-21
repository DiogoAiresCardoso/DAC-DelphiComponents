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
  Vcl.Forms,
  Vcl.Graphics,
  Vcl.Skia,
  DAC.Components.Skia.Renderer;

type
  TDACScrollBarMode = (
    msbmAuto,
    msbmVertical,
    msbmHorizontal,
    msbmBoth,
    msbmNone
  );

  TDACScrollContainer = class(TScrollBox)
  private
    FBackgroundColor: TAlphaColor;
    FBorderColor: TAlphaColor;
    FCornerRadius: Integer;
    FPaintBox: TSkPaintBox;
    FRenderer: TDACSkiaRenderer;
    FScrollBarMode: TDACScrollBarMode;
    FWheelDeltaRemainder: Integer;
    function ParentSurfaceColor: TAlphaColor;
    procedure ScrollVertically(const ACode: Word);
    procedure CMMouseWheel(var AMessage: TCMMouseWheel); message CM_MOUSEWHEEL;
    procedure PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    procedure CMControlListChange(var AMessage: TCMControlListChange);
      message CM_CONTROLLISTCHANGE;
    procedure RedrawChrome;
    procedure SetBackgroundColor(const AValue: TAlphaColor);
    procedure SetBorderColor(const AValue: TAlphaColor);
    procedure SetCornerRadius(const AValue: Integer);
    procedure SetScrollBarMode(const AValue: TDACScrollBarMode);
    procedure UpdateChromeBounds;
    procedure UpdateScrollBars;
    procedure WMEraseBkgnd(var AMessage: TWMEraseBkgnd); message WM_ERASEBKGND;
  protected
    procedure ChangeScale(M, D: Integer); override;
    procedure CreateWnd; override;
    procedure Loaded; override;
    procedure Resize; override;
    procedure WndProc(var Message: TMessage); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Redraw;
  published
    property Align;
    property Anchors;
    property AutoScroll default True;
    property BackgroundColor: TAlphaColor read FBackgroundColor write SetBackgroundColor;
    property BorderColor: TAlphaColor read FBorderColor write SetBorderColor;
    property BorderStyle default bsNone;
    property Constraints;
    property CornerRadius: Integer read FCornerRadius write SetCornerRadius default 8;
    property Enabled;
    property Font;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ScrollBarMode: TDACScrollBarMode read FScrollBarMode write SetScrollBarMode default msbmAuto;
    property ShowHint;
    property TabOrder;
    property TabStop default True;
    property Visible;
  end;

implementation

uses
  System.Math,
  DAC.Components.DesignSystem.ColorTokens;

constructor TDACScrollContainer.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csAcceptsControls, csOpaque];
  Width := 360;
  Height := 220;
  AutoScroll := True;
  BorderStyle := bsNone;
  ParentColor := False;
  TabStop := True;
  StyleElements := [];

  FBackgroundColor := TDACComponentColors.White;
  FBorderColor := TDACComponentColors.ControlBorder;
  FCornerRadius := 8;
  FScrollBarMode := msbmAuto;
  FRenderer := TDACSkiaRenderer.Create;
  Color := TDACComponentColors.ToVclColor(FBackgroundColor);

  FPaintBox := TSkPaintBox.Create(Self);
  FPaintBox.Parent := Self;
  FPaintBox.SetSubComponent(True);
  FPaintBox.StyleElements := [];
  FPaintBox.OnDraw := PaintBoxDraw;
end;

destructor TDACScrollContainer.Destroy;
begin
  FPaintBox.Free;
  FRenderer.Free;
  inherited;
end;

procedure TDACScrollContainer.ChangeScale(M, D: Integer);
begin
  inherited;
  Redraw;
end;

procedure TDACScrollContainer.CMControlListChange(
  var AMessage: TCMControlListChange);
begin
  inherited;
  // The Skia surface is created before DFM child controls.  Reassert its
  // background role after every streamed/runtime child insertion so it can
  // never cover native labels, buttons or grid containers at runtime.
  if (FPaintBox <> nil) and HandleAllocated and
    not (csDesigning in ComponentState) then
    FPaintBox.SendToBack;
end;

procedure TDACScrollContainer.CMMouseWheel(var AMessage: TCMMouseWheel);
var
  LCode: Word;
  LNotches: Integer;
  LScrollLines: Cardinal;
  LSteps: Integer;
begin
  if VertScrollBar.Range <= ClientHeight then
  begin
    inherited;
    Exit;
  end;

  // Mark even a partial high-resolution delta as handled.  Otherwise VCL
  // falls through to DefWindowProc, which can forward the same wheel input
  // through the native parent chain and apply it a second time.
  AMessage.Result := 1;
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

procedure TDACScrollContainer.CreateWnd;
begin
  inherited;
  UpdateScrollBars;
  UpdateChromeBounds;
  Redraw;
end;

procedure TDACScrollContainer.Loaded;
begin
  inherited;
  UpdateScrollBars;
  UpdateChromeBounds;
  Redraw;
end;

procedure TDACScrollContainer.PaintBoxDraw(Sender: TObject;
  const ACanvas: ISkCanvas; const ADest: TRectF; const AOpacity: Single);
var
  LBackground: TAlphaColor;
  LRect: TRectF;
  LScale: Single;
begin
  if FBackgroundColor = TAlphaColor($00000000) then
    LBackground := ParentSurfaceColor
  else
    LBackground := TDACComponentColors.Normalize(FBackgroundColor);

  LScale := 1;
  if FPaintBox <> nil then
    LScale := FPaintBox.ScaleFactor;
  if LScale <= 0 then
    LScale := 1;

  ACanvas.Clear(LBackground);
  LRect := FRenderer.SnapRect(TRectF.Create(0, 0, ADest.Width, ADest.Height), LScale);
  LRect.Inflate(-0.5, -0.5);
  FRenderer.FillRoundRect(ACanvas, LRect, LBackground, FCornerRadius, 255);
  FRenderer.StrokeRoundRect(ACanvas, LRect,
    TDACComponentColors.Normalize(FBorderColor), FCornerRadius, 1, 255);
end;

function TDACScrollContainer.ParentSurfaceColor: TAlphaColor;
begin
  Result := TDACComponentColors.ResolveParentSurface(Self);
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
  if (FPaintBox <> nil) and not (csDestroying in ComponentState) and
    ((Parent <> nil) or not (csDesigning in ComponentState)) then
    FPaintBox.Redraw;
  Invalidate;
end;

procedure TDACScrollContainer.Resize;
begin
  inherited;
  UpdateChromeBounds;
  Redraw;
end;

procedure TDACScrollContainer.SetBackgroundColor(const AValue: TAlphaColor);
begin
  if FBackgroundColor = AValue then
    Exit;
  FBackgroundColor := AValue;
  if FBackgroundColor = TAlphaColor($00000000) then
    Color := TDACComponentColors.ToVclColor(ParentSurfaceColor)
  else
    Color := TDACComponentColors.ToVclColor(
      TDACComponentColors.Normalize(FBackgroundColor));
  Redraw;
end;

procedure TDACScrollContainer.SetBorderColor(const AValue: TAlphaColor);
begin
  if FBorderColor = AValue then
    Exit;
  FBorderColor := AValue;
  Redraw;
end;

procedure TDACScrollContainer.SetCornerRadius(const AValue: Integer);
begin
  if FCornerRadius = AValue then
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
var
  LHeight: Integer;
  LLeft: Integer;
  LTop: Integer;
  LWidth: Integer;
begin
  if FPaintBox = nil then
    Exit;
  LLeft := 0;
  LTop := 0;
  LWidth := Width;
  LHeight := Height;
  if HandleAllocated then
  begin
    LLeft := HorzScrollBar.Position;
    LTop := VertScrollBar.Position;
    LWidth := ClientWidth;
    LHeight := ClientHeight;
  end;
  FPaintBox.SetBounds(LLeft, LTop, LWidth, LHeight);
  if (csDesigning in ComponentState) or not HandleAllocated then
    Exit;
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
  LBrush := CreateSolidBrush(ColorToRGB(Color));
  try
    Winapi.Windows.FillRect(AMessage.DC, ClientRect, LBrush);
  finally
    DeleteObject(LBrush);
  end;
  AMessage.Result := 1;
end;

end.

