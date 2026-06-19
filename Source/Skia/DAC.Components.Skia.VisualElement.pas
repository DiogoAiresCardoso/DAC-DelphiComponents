unit MaxxRural.Components.Skia.VisualElement;

interface

uses
  System.Classes,
  System.Skia,
  System.Types,
  MaxxRural.Components.DesignSystem.DefaultTheme,
  MaxxRural.Components.DesignSystem.Theme,
  MaxxRural.Components.Skia.Renderer,
  MaxxRural.Components.Types;

type
  TMaxxRuralSkiaVisualElement = class
  private
    FAccessibleName: string;
    FAccessibleRole: TMaxxRuralAccessibleRole;
    FBounds: TRectF;
    FComponentId: string;
    FEnabled: Boolean;
    FFocusable: Boolean;
    FFocusedElementId: string;
    FHoveredElementId: string;
    FNeedsLayout: Boolean;
    FNeedsPaint: Boolean;
    FPressedElementId: string;
    FRenderer: TMaxxRuralSkiaRenderer;
    FTheme: IMaxxRuralComponentsTheme;
    FVisible: Boolean;
    FVisualStates: TMaxxRuralVisualStates;
    procedure SetTheme(const ATheme: IMaxxRuralComponentsTheme);
  protected
    function ContainsPoint(const APoint: TPointF): Boolean;
    procedure ExcludeVisualState(const AState: TMaxxRuralVisualState);
    procedure IncludeVisualState(const AState: TMaxxRuralVisualState);
    procedure ThemeChanged; virtual;
    property Renderer: TMaxxRuralSkiaRenderer read FRenderer;
  public
    constructor Create(const AComponentId: string); virtual;
    destructor Destroy; override;
    procedure Arrange(const ABounds: TRectF); virtual;
    procedure ClearFocus; virtual;
    procedure ClearInteractionState; virtual;
    procedure ClearPointerState; virtual;
    procedure Draw(const ACanvas: ISkCanvas); virtual;
    function HitTest(const AEvent: TMaxxRuralPointerEvent): TMaxxRuralHitTestResult; virtual;
    procedure InvalidateLayout; virtual;
    procedure InvalidatePaint; virtual;
    procedure KeyDown(var Key: Word; Shift: TShiftState); virtual;
    procedure KeyPress(var Key: Char); virtual;
    function Measure(const AAvailableSize: TSizeF): TSizeF; virtual;
    procedure MouseDown(const AEvent: TMaxxRuralPointerEvent;
      const AHit: TMaxxRuralHitTestResult); virtual;
    procedure MouseEnter(const AHit: TMaxxRuralHitTestResult); virtual;
    procedure MouseLeave; virtual;
    procedure MouseMove(const AEvent: TMaxxRuralPointerEvent;
      const AHit: TMaxxRuralHitTestResult); virtual;
    procedure MouseUp(const AEvent: TMaxxRuralPointerEvent;
      const AHit: TMaxxRuralHitTestResult); virtual;
    function MouseWheel(const AEvent: TMaxxRuralPointerEvent;
      const AHit: TMaxxRuralHitTestResult): Boolean; virtual;
    function Activate: Boolean; virtual;
    procedure SetFocus(const AElementId: string); virtual;
    function HasFocus: Boolean;
    property AccessibleName: string read FAccessibleName write FAccessibleName;
    property AccessibleRole: TMaxxRuralAccessibleRole read FAccessibleRole write FAccessibleRole;
    property Bounds: TRectF read FBounds write Arrange;
    property ComponentId: string read FComponentId;
    property Enabled: Boolean read FEnabled write FEnabled;
    property Focusable: Boolean read FFocusable write FFocusable;
    property FocusedElementId: string read FFocusedElementId;
    property NeedsLayout: Boolean read FNeedsLayout;
    property NeedsPaint: Boolean read FNeedsPaint;
    property Theme: IMaxxRuralComponentsTheme read FTheme write SetTheme;
    property Visible: Boolean read FVisible write FVisible;
    property VisualStates: TMaxxRuralVisualStates read FVisualStates;
  end;

implementation

constructor TMaxxRuralSkiaVisualElement.Create(const AComponentId: string);
begin
  inherited Create;
  FComponentId := AComponentId;
  FRenderer := TMaxxRuralSkiaRenderer.Create;
  FTheme := TMaxxRuralDefaultComponentsTheme.New;
  FEnabled := True;
  FFocusable := True;
  FVisible := True;
  FNeedsLayout := True;
  FNeedsPaint := True;
  FAccessibleRole := marNone;
end;

destructor TMaxxRuralSkiaVisualElement.Destroy;
begin
  FRenderer.Free;
  inherited;
end;

function TMaxxRuralSkiaVisualElement.Activate: Boolean;
begin
  Result := False;
end;

procedure TMaxxRuralSkiaVisualElement.Arrange(const ABounds: TRectF);
begin
  FBounds := ABounds;
  FNeedsLayout := False;
  InvalidatePaint;
end;

procedure TMaxxRuralSkiaVisualElement.ClearFocus;
begin
  FFocusedElementId := '';
  ExcludeVisualState(mvsFocused);
end;

procedure TMaxxRuralSkiaVisualElement.ClearInteractionState;
begin
  FHoveredElementId := '';
  FPressedElementId := '';
  FFocusedElementId := '';
  FVisualStates := [];
  InvalidatePaint;
end;

procedure TMaxxRuralSkiaVisualElement.ClearPointerState;
begin
  FHoveredElementId := '';
  FPressedElementId := '';
  ExcludeVisualState(mvsHovered);
  ExcludeVisualState(mvsPressed);
end;

function TMaxxRuralSkiaVisualElement.ContainsPoint(const APoint: TPointF): Boolean;
begin
  Result := (APoint.X >= FBounds.Left) and (APoint.X <= FBounds.Right) and
    (APoint.Y >= FBounds.Top) and (APoint.Y <= FBounds.Bottom);
end;

procedure TMaxxRuralSkiaVisualElement.Draw(const ACanvas: ISkCanvas);
begin
  FNeedsPaint := False;
end;

procedure TMaxxRuralSkiaVisualElement.ExcludeVisualState(
  const AState: TMaxxRuralVisualState);
begin
  if AState in FVisualStates then
  begin
    Exclude(FVisualStates, AState);
    InvalidatePaint;
  end;
end;

function TMaxxRuralSkiaVisualElement.HasFocus: Boolean;
begin
  Result := mvsFocused in FVisualStates;
end;

function TMaxxRuralSkiaVisualElement.HitTest(
  const AEvent: TMaxxRuralPointerEvent): TMaxxRuralHitTestResult;
begin
  Result := TMaxxRuralHitTestResult.Empty;
  if FVisible and FEnabled and ContainsPoint(AEvent.Position) then
    Result := TMaxxRuralHitTestResult.Hit(FComponentId, '');
end;

procedure TMaxxRuralSkiaVisualElement.IncludeVisualState(
  const AState: TMaxxRuralVisualState);
begin
  if not (AState in FVisualStates) then
  begin
    Include(FVisualStates, AState);
    InvalidatePaint;
  end;
end;

procedure TMaxxRuralSkiaVisualElement.InvalidateLayout;
begin
  FNeedsLayout := True;
  InvalidatePaint;
end;

procedure TMaxxRuralSkiaVisualElement.InvalidatePaint;
begin
  FNeedsPaint := True;
end;

procedure TMaxxRuralSkiaVisualElement.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if Key = 0 then
    Exit;
end;

procedure TMaxxRuralSkiaVisualElement.KeyPress(var Key: Char);
begin
  if Key = #0 then
    Exit;
end;

function TMaxxRuralSkiaVisualElement.Measure(
  const AAvailableSize: TSizeF): TSizeF;
begin
  Result := TSizeF.Create(FBounds.Width, FBounds.Height);
  if Result.Width <= 0 then
    Result.Width := AAvailableSize.Width;
  if Result.Height <= 0 then
    Result.Height := AAvailableSize.Height;
end;

procedure TMaxxRuralSkiaVisualElement.MouseDown(
  const AEvent: TMaxxRuralPointerEvent; const AHit: TMaxxRuralHitTestResult);
begin
  FPressedElementId := AHit.ElementId;
  FFocusedElementId := AHit.ElementId;
  IncludeVisualState(mvsPressed);
  IncludeVisualState(mvsFocused);
end;

procedure TMaxxRuralSkiaVisualElement.MouseEnter(
  const AHit: TMaxxRuralHitTestResult);
begin
  FHoveredElementId := AHit.ElementId;
  IncludeVisualState(mvsHovered);
end;

procedure TMaxxRuralSkiaVisualElement.MouseLeave;
begin
  FHoveredElementId := '';
  ExcludeVisualState(mvsHovered);
end;

procedure TMaxxRuralSkiaVisualElement.MouseMove(
  const AEvent: TMaxxRuralPointerEvent; const AHit: TMaxxRuralHitTestResult);
begin
  if FHoveredElementId <> AHit.ElementId then
  begin
    FHoveredElementId := AHit.ElementId;
    InvalidatePaint;
  end;
end;

procedure TMaxxRuralSkiaVisualElement.MouseUp(
  const AEvent: TMaxxRuralPointerEvent; const AHit: TMaxxRuralHitTestResult);
begin
  FPressedElementId := '';
  ExcludeVisualState(mvsPressed);
end;

function TMaxxRuralSkiaVisualElement.MouseWheel(
  const AEvent: TMaxxRuralPointerEvent; const AHit: TMaxxRuralHitTestResult): Boolean;
begin
  Result := False;
end;

procedure TMaxxRuralSkiaVisualElement.SetFocus(const AElementId: string);
begin
  FFocusedElementId := AElementId;
  IncludeVisualState(mvsFocused);
end;

procedure TMaxxRuralSkiaVisualElement.SetTheme(
  const ATheme: IMaxxRuralComponentsTheme);
begin
  if ATheme = nil then
    FTheme := TMaxxRuralDefaultComponentsTheme.New
  else
    FTheme := ATheme;
  ThemeChanged;
  InvalidateLayout;
end;

procedure TMaxxRuralSkiaVisualElement.ThemeChanged;
begin
  InvalidatePaint;
end;

end.
