unit DAC.Components.Controls.ScrollContainer;

interface

uses
  System.Classes,
  System.Skia,
  System.Types,
  System.UITypes,
  Winapi.Messages,
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
    function ParentSurfaceColor: TAlphaColor;
    procedure PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
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

  LRect := TRectF.Create(0, 0, ADest.Width, ADest.Height);
  LRect := FRenderer.SnapRect(LRect, LScale);
  LRect.Inflate(-0.5, -0.5);
  FRenderer.FillRoundRect(ACanvas, LRect, LBackground, FCornerRadius, 255);
  FRenderer.StrokeRoundRect(ACanvas, LRect,
    TDACComponentColors.Normalize(FBorderColor), FCornerRadius, 1, 255);
end;

function TDACScrollContainer.ParentSurfaceColor: TAlphaColor;
begin
  Result := TDACComponentColors.ResolveParentSurface(Self);
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
begin
  if FPaintBox = nil then
    Exit;
  FPaintBox.SetBounds(0, 0, Width, Height);
  if (csLoading in ComponentState) or (csDesigning in ComponentState) or
    not HandleAllocated then
    Exit;
  FPaintBox.SendToBack;
end;

procedure TDACScrollContainer.UpdateScrollBars;
begin
  HorzScrollBar.Visible := FScrollBarMode in [msbmAuto, msbmHorizontal, msbmBoth];
  VertScrollBar.Visible := FScrollBarMode in [msbmAuto, msbmVertical, msbmBoth];
end;

procedure TDACScrollContainer.WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
begin
  AMessage.Result := 1;
end;

end.

