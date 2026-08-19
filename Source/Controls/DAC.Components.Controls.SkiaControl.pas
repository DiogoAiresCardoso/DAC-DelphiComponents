unit DAC.Components.Controls.SkiaControl;

interface

uses
  System.Classes,
  System.Skia,
  System.Types,
  Winapi.Messages,
  Vcl.Controls,
  Vcl.Skia,
  DAC.Components.DesignSystem.ComponentStyle,
  DAC.Components.DesignSystem.ControlTokens,
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
    FThemeMode: TDACThemeMode;
    procedure PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    procedure PaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    function GetTheme: IDACComponentsTheme;
    function ThemeModeFor(const ATheme: IDACComponentsTheme): TDACThemeMode;
    procedure SetTheme(const ATheme: IDACComponentsTheme);
    procedure SetThemeMode(const AValue: TDACThemeMode);
    procedure ThemeChanged(Sender: TObject);
    procedure CMParentColorChanged(var AMessage: TMessage); message CM_PARENTCOLORCHANGED;
    procedure CMParentFontChanged(var AMessage: TMessage); message CM_PARENTFONTCHANGED;
  protected
    function MouseButtonToPointerButton(const AButton: TMouseButton): TDACPointerButton;
    procedure DrawContent(const ACanvas: ISkCanvas; const ADest: TRectF); virtual;
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Redraw;
    function ResolvedTheme: IDACComponentsTheme;
    function ResolvedTokens: TDACControlTokens;
    property BackgroundPainter: TDACSkiaBackgroundPainter read FBackgroundPainter;
    property BorderPainter: TDACSkiaBorderPainter read FBorderPainter;
    property Container: TDACSkiaElementContainer read FContainer;
    property IconPainter: TDACSkiaIconPainter read FIconPainter;
    property PaintBox: TSkPaintBox read FPaintBox;
    property Renderer: TDACSkiaRenderer read FRenderer;
    // Compatibility facade: Theme always exposes the effective mode-resolved
    // palette. Assigning a standard light/dark theme selects its ThemeMode.
    property Theme: IDACComponentsTheme read GetTheme write SetTheme;
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
    property ThemeMode: TDACThemeMode read FThemeMode write SetThemeMode default dtmInherit;
    property Visible;
  end;

implementation

constructor TDACSkiaControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  Width := Round(TDACComponentStyle.Resolve(dtmInherit).Tokens.Controls.SkiaControlDefaultWidth);
  Height := Round(TDACComponentStyle.Resolve(dtmInherit).Tokens.Controls.SkiaControlDefaultHeight);
  TabStop := True;
  FRenderer := TDACSkiaRenderer.Create;
  FBackgroundPainter := TDACSkiaBackgroundPainter.Create(FRenderer);
  FBorderPainter := TDACSkiaBorderPainter.Create(FRenderer);
  FIconPainter := TDACSkiaIconPainter.Create(FRenderer);
  FThemeMode := dtmInherit;
  FContainer := TDACSkiaElementContainer.Create;
  FContainer.Theme := ResolvedTheme;

  FPaintBox := TSkPaintBox.Create(Self);
  FPaintBox.Parent := Self;
  FPaintBox.Align := alClient;
  FPaintBox.OnDraw := PaintBoxDraw;
  FPaintBox.OnMouseDown := PaintBoxMouseDown;
  FPaintBox.OnMouseMove := PaintBoxMouseMove;
  FPaintBox.OnMouseUp := PaintBoxMouseUp;
  TDACThemeManager.RegisterListener(Self, ThemeChanged);
end;

destructor TDACSkiaControl.Destroy;
begin
  TDACThemeManager.UnregisterListener(Self);
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
  FContainer.Theme := ResolvedTheme;
  FBackgroundPainter.DrawPanel(ACanvas, ADest, ResolvedTheme);
  FBorderPainter.DrawPanelBorder(ACanvas, ADest, ResolvedTheme);
  FContainer.Draw(ACanvas);
end;

function TDACSkiaControl.GetTheme: IDACComponentsTheme;
begin
  Result := ResolvedTheme;
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
  if (FPaintBox <> nil) and not (csDesigning in ComponentState) and
    not (csDestroying in ComponentState) and (Parent <> nil) and
    HandleAllocated and Parent.HandleAllocated then
    FPaintBox.Redraw;
end;

procedure TDACSkiaControl.Resize;
begin
  inherited;
  Redraw;
end;

procedure TDACSkiaControl.SetTheme(const ATheme: IDACComponentsTheme);
begin
  SetThemeMode(ThemeModeFor(ATheme));
end;

procedure TDACSkiaControl.SetThemeMode(const AValue: TDACThemeMode);
begin
  if FThemeMode = AValue then
  begin
    ThemeChanged(Self);
    TDACThemeManager.RefreshTree(Self);
    Exit;
  end;
  FThemeMode := AValue;
  ThemeChanged(Self);
  TDACThemeManager.RefreshTree(Self);
end;

procedure TDACSkiaControl.CMParentColorChanged(var AMessage: TMessage);
begin
  inherited;
  ThemeChanged(Self);
  TDACThemeManager.RefreshTree(Self);
end;

procedure TDACSkiaControl.CMParentFontChanged(var AMessage: TMessage);
begin
  inherited;
  ThemeChanged(Self);
  TDACThemeManager.RefreshTree(Self);
end;

procedure TDACSkiaControl.ThemeChanged(Sender: TObject);
begin
  if (FThemeMode <> dtmInherit) and (Sender <> Self) then
    Exit;
  if FContainer <> nil then
    FContainer.Theme := ResolvedTheme;
  Redraw;
end;

function TDACSkiaControl.ThemeModeFor(
  const ATheme: IDACComponentsTheme): TDACThemeMode;
begin
  if ATheme = nil then
    Exit(dtmInherit);
  if ATheme.Tokens.Controls.ContainerSuiteBackground =
    TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.ContainerSuiteBackground then
    Exit(dtmLight);
  Result := dtmDark;
end;

function TDACSkiaControl.ResolvedTheme: IDACComponentsTheme;
begin
  Result := TDACComponentStyle.ResolveForSurface(Self, FThemeMode);
end;

function TDACSkiaControl.ResolvedTokens: TDACControlTokens;
begin
  Result := ResolvedTheme.Tokens.Controls;
end;

end.

