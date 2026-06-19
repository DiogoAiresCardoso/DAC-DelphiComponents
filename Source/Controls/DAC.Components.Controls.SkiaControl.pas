unit MaxxRural.Components.Controls.SkiaControl;

interface

uses
  System.Classes,
  System.Skia,
  System.Types,
  Vcl.Controls,
  Vcl.Skia,
  MaxxRural.Components.DesignSystem.DefaultTheme,
  MaxxRural.Components.DesignSystem.Theme,
  MaxxRural.Components.Skia.BackgroundPainter,
  MaxxRural.Components.Skia.BorderPainter,
  MaxxRural.Components.Skia.Container,
  MaxxRural.Components.Skia.IconPainter,
  MaxxRural.Components.Skia.Renderer,
  MaxxRural.Components.Types;

type
  TMaxxRuralSkiaControl = class(TCustomControl)
  private
    FBackgroundPainter: TMaxxRuralSkiaBackgroundPainter;
    FBorderPainter: TMaxxRuralSkiaBorderPainter;
    FContainer: TMaxxRuralSkiaElementContainer;
    FIconPainter: TMaxxRuralSkiaIconPainter;
    FPaintBox: TSkPaintBox;
    FRenderer: TMaxxRuralSkiaRenderer;
    FTheme: IMaxxRuralComponentsTheme;
    procedure PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    procedure PaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SetTheme(const ATheme: IMaxxRuralComponentsTheme);
    function CanUsePaintBox: Boolean;
  protected
    function MouseButtonToPointerButton(const AButton: TMouseButton): TMaxxRuralPointerButton;
    procedure DrawContent(const ACanvas: ISkCanvas; const ADest: TRectF); virtual;
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Redraw;
    property BackgroundPainter: TMaxxRuralSkiaBackgroundPainter read FBackgroundPainter;
    property BorderPainter: TMaxxRuralSkiaBorderPainter read FBorderPainter;
    property Container: TMaxxRuralSkiaElementContainer read FContainer;
    property IconPainter: TMaxxRuralSkiaIconPainter read FIconPainter;
    property PaintBox: TSkPaintBox read FPaintBox;
    property Renderer: TMaxxRuralSkiaRenderer read FRenderer;
    property Theme: IMaxxRuralComponentsTheme read FTheme write SetTheme;
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

constructor TMaxxRuralSkiaControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  Width := 280;
  Height := 160;
  TabStop := True;
  FRenderer := TMaxxRuralSkiaRenderer.Create;
  FBackgroundPainter := TMaxxRuralSkiaBackgroundPainter.Create(FRenderer);
  FBorderPainter := TMaxxRuralSkiaBorderPainter.Create(FRenderer);
  FIconPainter := TMaxxRuralSkiaIconPainter.Create(FRenderer);
  FTheme := TMaxxRuralDefaultComponentsTheme.New;
  FContainer := TMaxxRuralSkiaElementContainer.Create;
  FContainer.Theme := FTheme;

  FPaintBox := TSkPaintBox.Create(Self);
  FPaintBox.Parent := Self;
  FPaintBox.Align := alClient;
  FPaintBox.OnDraw := PaintBoxDraw;
  FPaintBox.OnMouseDown := PaintBoxMouseDown;
  FPaintBox.OnMouseMove := PaintBoxMouseMove;
  FPaintBox.OnMouseUp := PaintBoxMouseUp;
end;

destructor TMaxxRuralSkiaControl.Destroy;
begin
  FPaintBox.Free;
  FContainer.Free;
  FIconPainter.Free;
  FBorderPainter.Free;
  FBackgroundPainter.Free;
  FRenderer.Free;
  inherited;
end;

procedure TMaxxRuralSkiaControl.DrawContent(const ACanvas: ISkCanvas;
  const ADest: TRectF);
begin
  FBackgroundPainter.DrawPanel(ACanvas, ADest, FTheme);
  FBorderPainter.DrawPanelBorder(ACanvas, ADest, FTheme);
  FContainer.Draw(ACanvas);
end;

function TMaxxRuralSkiaControl.CanUsePaintBox: Boolean;
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

function TMaxxRuralSkiaControl.MouseButtonToPointerButton(
  const AButton: TMouseButton): TMaxxRuralPointerButton;
begin
  case AButton of
    mbLeft: Result := mpbLeft;
    mbRight: Result := mpbRight;
    mbMiddle: Result := mpbMiddle;
  else
    Result := mpbNone;
  end;
end;

procedure TMaxxRuralSkiaControl.PaintBoxDraw(Sender: TObject;
  const ACanvas: ISkCanvas; const ADest: TRectF; const AOpacity: Single);
begin
  DrawContent(ACanvas, ADest);
end;

procedure TMaxxRuralSkiaControl.PaintBoxMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  if (Parent <> nil) and HandleAllocated and CanFocus then
    SetFocus;
  FContainer.MouseDown(TPointF.Create(X, Y), MouseButtonToPointerButton(Button), Shift);
  Redraw;
end;

procedure TMaxxRuralSkiaControl.PaintBoxMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  FContainer.MouseMove(TPointF.Create(X, Y), Shift);
  if FPaintBox <> nil then
    FPaintBox.Cursor := FContainer.Cursor;
  if FContainer.NeedsPaint then
    Redraw;
end;

procedure TMaxxRuralSkiaControl.PaintBoxMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  FContainer.MouseUp(TPointF.Create(X, Y), MouseButtonToPointerButton(Button), Shift);
  Redraw;
end;

procedure TMaxxRuralSkiaControl.Redraw;
begin
  if CanUsePaintBox then
    FPaintBox.Redraw;
end;

procedure TMaxxRuralSkiaControl.Resize;
begin
  inherited;
  Redraw;
end;

procedure TMaxxRuralSkiaControl.SetTheme(const ATheme: IMaxxRuralComponentsTheme);
begin
  if ATheme = nil then
    FTheme := TMaxxRuralDefaultComponentsTheme.New
  else
    FTheme := ATheme;
  FContainer.Theme := FTheme;
  Redraw;
end;

end.
