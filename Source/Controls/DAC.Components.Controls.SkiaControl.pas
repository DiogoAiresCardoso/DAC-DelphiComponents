unit DAC.Components.Controls.SkiaControl;

interface

uses
  System.Classes,
  System.Skia,
  System.Types,
  Vcl.Controls,
  Vcl.Skia,
  DAC.Components.DesignSystem.DefaultTheme,
  DAC.Components.DesignSystem.Theme,
  DAC.Components.Skia.BackgroundPainter,
  DAC.Components.Skia.BorderPainter,
  DAC.Components.Skia.Container,
  DAC.Components.Skia.IconPainter,
  DAC.Components.Skia.Renderer,
  DAC.Components.Types;

type
  TDACSkiaControl = class(TCustomControl)
  private
    FBackgroundPainter: TDACSkiaBackgroundPainter;
    FBorderPainter: TDACSkiaBorderPainter;
    FContainer: TDACSkiaElementContainer;
    FIconPainter: TDACSkiaIconPainter;
    FPaintBox: TSkPaintBox;
    FRenderer: TDACSkiaRenderer;
    FTheme: IDACComponentsTheme;
    procedure PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    procedure PaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SetTheme(const ATheme: IDACComponentsTheme);
    function CanUsePaintBox: Boolean;
  protected
    function MouseButtonToPointerButton(const AButton: TMouseButton): TDACPointerButton;
    procedure DrawContent(const ACanvas: ISkCanvas; const ADest: TRectF); virtual;
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Redraw;
    property BackgroundPainter: TDACSkiaBackgroundPainter read FBackgroundPainter;
    property BorderPainter: TDACSkiaBorderPainter read FBorderPainter;
    property Container: TDACSkiaElementContainer read FContainer;
    property IconPainter: TDACSkiaIconPainter read FIconPainter;
    property PaintBox: TSkPaintBox read FPaintBox;
    property Renderer: TDACSkiaRenderer read FRenderer;
    property Theme: IDACComponentsTheme read FTheme write SetTheme;
  published
    property Align;
    property Anchors;
    property Constraints;
    property Enabled;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop default True;
    property Visible;
  end;

implementation

constructor TDACSkiaControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  Width := 280;
  Height := 160;
  TabStop := True;
  FRenderer := TDACSkiaRenderer.Create;
  FBackgroundPainter := TDACSkiaBackgroundPainter.Create(FRenderer);
  FBorderPainter := TDACSkiaBorderPainter.Create(FRenderer);
  FIconPainter := TDACSkiaIconPainter.Create(FRenderer);
  FTheme := TDACDefaultComponentsTheme.New;
  FContainer := TDACSkiaElementContainer.Create;
  FContainer.Theme := FTheme;

  FPaintBox := TSkPaintBox.Create(Self);
  FPaintBox.Parent := Self;
  FPaintBox.Align := alClient;
  FPaintBox.OnDraw := PaintBoxDraw;
  FPaintBox.OnMouseDown := PaintBoxMouseDown;
  FPaintBox.OnMouseMove := PaintBoxMouseMove;
  FPaintBox.OnMouseUp := PaintBoxMouseUp;
end;

destructor TDACSkiaControl.Destroy;
begin
  FPaintBox.Free;
  FContainer.Free;
  FIconPainter.Free;
  FBorderPainter.Free;
  FBackgroundPainter.Free;
  FRenderer.Free;
  inherited;
end;

procedure TDACSkiaControl.DrawContent(const ACanvas: ISkCanvas;
  const ADest: TRectF);
begin
  FBackgroundPainter.DrawPanel(ACanvas, ADest, FTheme);
  FBorderPainter.DrawPanelBorder(ACanvas, ADest, FTheme);
  FContainer.Draw(ACanvas);
end;

function TDACSkiaControl.CanUsePaintBox: Boolean;
begin
  Result := (FPaintBox <> nil) and not (csDestroying in ComponentState);
  if not Result then
    Exit;

  if (csLoading in ComponentState) then
  begin
    Result := False;
    Exit;
  end;

  if (csDesigning in ComponentState) and (Parent = nil) then
  begin
    Result := False;
    Exit;
  end;
end;

function TDACSkiaControl.MouseButtonToPointerButton(
  const AButton: TMouseButton): TDACPointerButton;
begin
  case AButton of
    mbLeft: Result := mpbLeft;
    mbRight: Result := mpbRight;
    mbMiddle: Result := mpbMiddle;
  else
    Result := mpbNone;
  end;
end;

procedure TDACSkiaControl.PaintBoxDraw(Sender: TObject;
  const ACanvas: ISkCanvas; const ADest: TRectF; const AOpacity: Single);
begin
  DrawContent(ACanvas, ADest);
end;

procedure TDACSkiaControl.PaintBoxMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (Parent <> nil) and HandleAllocated and CanFocus then
    SetFocus;
  FContainer.MouseDown(TPointF.Create(X, Y), MouseButtonToPointerButton(Button), Shift);
  Redraw;
end;

procedure TDACSkiaControl.PaintBoxMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  FContainer.MouseMove(TPointF.Create(X, Y), Shift);
  if FPaintBox <> nil then
    FPaintBox.Cursor := FContainer.Cursor;
  if FContainer.NeedsPaint then
    Redraw;
end;

procedure TDACSkiaControl.PaintBoxMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FContainer.MouseUp(TPointF.Create(X, Y), MouseButtonToPointerButton(Button), Shift);
  Redraw;
end;

procedure TDACSkiaControl.Redraw;
begin
  if CanUsePaintBox then
    FPaintBox.Redraw;
end;

procedure TDACSkiaControl.Resize;
begin
  inherited;
  Redraw;
end;

procedure TDACSkiaControl.SetTheme(const ATheme: IDACComponentsTheme);
begin
  if ATheme = nil then
    FTheme := TDACDefaultComponentsTheme.New
  else
    FTheme := ATheme;
  FContainer.Theme := FTheme;
  Redraw;
end;

end.

