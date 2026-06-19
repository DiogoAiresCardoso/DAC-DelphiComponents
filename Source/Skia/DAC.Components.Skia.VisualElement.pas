unit DAC.Components.Skia.VisualElement;

interface

uses
  System.Classes,
  System.Skia,
  System.Types,
  DAC.Components.DesignSystem.DefaultTheme,
  DAC.Components.DesignSystem.Theme,
  DAC.Components.Skia.Renderer,
  DAC.Components.Types;

type
  TDACSkiaVisualElement = class
  private
    FAccessibleName: string;
    FAccessibleRole: TDACAccessibleRole;
    FBounds: TRectF;
    FComponentId: string;
    FEnabled: Boolean;
    FFocusable: Boolean;
    FFocusedElementId: string;
    FHoveredElementId: string;
    FNeedsLayout: Boolean;
    FNeedsPaint: Boolean;
    FPressedElementId: string;
    FRenderer: TDACSkiaRenderer;
    FTheme: IDACComponentsTheme;
    FVisible: Boolean;
    FVisualStates: TDACVisualStates;
    procedure SetTheme(const ATheme: IDACComponentsTheme);
  protected
    function ContainsPoint(const APoint: TPointF): Boolean;
    procedure ExcludeVisualState(const AState: TDACVisualState);
    procedure IncludeVisualState(const AState: TDACVisualState);
    procedure ThemeChanged; virtual;
    property Renderer: TDACSkiaRenderer read FRenderer;
  public
    constructor Create(const AComponentId: string); virtual;
    destructor Destroy; override;
    procedure Arrange(const ABounds: TRectF); virtual;
    procedure ClearFocus; virtual;
    procedure ClearInteractionState; virtual;
    procedure ClearPointerState; virtual;
    procedure Draw(const ACanvas: ISkCanvas); virtual;
    function HitTest(const AEvent: TDACPointerEvent): TDACHitTestResult; virtual;
    procedure InvalidateLayout; virtual;
    procedure InvalidatePaint; virtual;
    procedure KeyDown(var Key: Word; Shift: TShiftState); virtual;
    procedure KeyPress(var Key: Char); virtual;
    function Measure(const AAvailableSize: TSizeF): TSizeF; virtual;
    procedure MouseDown(const AEvent: TDACPointerEvent;
      const AHit: TDACHitTestResult); virtual;
    procedure MouseEnter(const AHit: TDACHitTestResult); virtual;
    procedure MouseLeave; virtual;
    procedure MouseMove(const AEvent: TDACPointerEvent;
      const AHit: TDACHitTestResult); virtual;
    procedure MouseUp(const AEvent: TDACPointerEvent;
      const AHit: TDACHitTestResult); virtual;
    function MouseWheel(const AEvent: TDACPointerEvent;
      const AHit: TDACHitTestResult): Boolean; virtual;
    function Activate: Boolean; virtual;
    procedure SetFocus(const AElementId: string); virtual;
    function HasFocus: Boolean;
    property AccessibleName: string read FAccessibleName write FAccessibleName;
    property AccessibleRole: TDACAccessibleRole read FAccessibleRole write FAccessibleRole;
    property Bounds: TRectF read FBounds write Arrange;
    property ComponentId: string read FComponentId;
    property Enabled: Boolean read FEnabled write FEnabled;
    property Focusable: Boolean read FFocusable write FFocusable;
    property FocusedElementId: string read FFocusedElementId;
    property NeedsLayout: Boolean read FNeedsLayout;
    property NeedsPaint: Boolean read FNeedsPaint;
    property Theme: IDACComponentsTheme read FTheme write SetTheme;
    property Visible: Boolean read FVisible write FVisible;
    property VisualStates: TDACVisualStates read FVisualStates;
  end;

implementation

constructor TDACSkiaVisualElement.Create(const AComponentId: string);
begin
  inherited Create;
  FComponentId := AComponentId;
  FRenderer := TDACSkiaRenderer.Create;
  FTheme := TDACDefaultComponentsTheme.New;
  FEnabled := True;
  FFocusable := True;
  FVisible := True;
  FNeedsLayout := True;
  FNeedsPaint := True;
  FAccessibleRole := marNone;
end;

destructor TDACSkiaVisualElement.Destroy;
begin
  FRenderer.Free;
  inherited;
end;

function TDACSkiaVisualElement.Activate: Boolean;
begin
  Result := False;
end;

procedure TDACSkiaVisualElement.Arrange(const ABounds: TRectF);
begin
  FBounds := ABounds;
  FNeedsLayout := False;
  InvalidatePaint;
end;

procedure TDACSkiaVisualElement.ClearFocus;
begin
  FFocusedElementId := '';
  ExcludeVisualState(mvsFocused);
end;

procedure TDACSkiaVisualElement.ClearInteractionState;
begin
  FHoveredElementId := '';
  FPressedElementId := '';
  FFocusedElementId := '';
  FVisualStates := [];
  InvalidatePaint;
end;

procedure TDACSkiaVisualElement.ClearPointerState;
begin
  FHoveredElementId := '';
  FPressedElementId := '';
  ExcludeVisualState(mvsHovered);
  ExcludeVisualState(mvsPressed);
end;

function TDACSkiaVisualElement.ContainsPoint(const APoint: TPointF): Boolean;
begin
  Result := (APoint.X >= FBounds.Left) and (APoint.X <= FBounds.Right) and
    (APoint.Y >= FBounds.Top) and (APoint.Y <= FBounds.Bottom);
end;

procedure TDACSkiaVisualElement.Draw(const ACanvas: ISkCanvas);
begin
  FNeedsPaint := False;
end;

procedure TDACSkiaVisualElement.ExcludeVisualState(
  const AState: TDACVisualState);
begin
  if AState in FVisualStates then
  begin
    Exclude(FVisualStates, AState);
    InvalidatePaint;
  end;
end;

function TDACSkiaVisualElement.HasFocus: Boolean;
begin
  Result := mvsFocused in FVisualStates;
end;

function TDACSkiaVisualElement.HitTest(
  const AEvent: TDACPointerEvent): TDACHitTestResult;
begin
  Result := TDACHitTestResult.Empty;
  if FVisible and FEnabled and ContainsPoint(AEvent.Position) then
    Result := TDACHitTestResult.Hit(FComponentId, '');
end;

procedure TDACSkiaVisualElement.IncludeVisualState(
  const AState: TDACVisualState);
begin
  if not (AState in FVisualStates) then
  begin
    Include(FVisualStates, AState);
    InvalidatePaint;
  end;
end;

procedure TDACSkiaVisualElement.InvalidateLayout;
begin
  FNeedsLayout := True;
  InvalidatePaint;
end;

procedure TDACSkiaVisualElement.InvalidatePaint;
begin
  FNeedsPaint := True;
end;

procedure TDACSkiaVisualElement.KeyDown(var Key: Word; Shift: TShiftState);
begin
  if Key = 0 then
    Exit;
end;

procedure TDACSkiaVisualElement.KeyPress(var Key: Char);
begin
  if Key = #0 then
    Exit;
end;

function TDACSkiaVisualElement.Measure(
  const AAvailableSize: TSizeF): TSizeF;
begin
  Result := TSizeF.Create(FBounds.Width, FBounds.Height);
  if Result.Width <= 0 then
    Result.Width := AAvailableSize.Width;
  if Result.Height <= 0 then
    Result.Height := AAvailableSize.Height;
end;

procedure TDACSkiaVisualElement.MouseDown(
  const AEvent: TDACPointerEvent; const AHit: TDACHitTestResult);
begin
  FPressedElementId := AHit.ElementId;
  FFocusedElementId := AHit.ElementId;
  IncludeVisualState(mvsPressed);
  IncludeVisualState(mvsFocused);
end;

procedure TDACSkiaVisualElement.MouseEnter(
  const AHit: TDACHitTestResult);
begin
  FHoveredElementId := AHit.ElementId;
  IncludeVisualState(mvsHovered);
end;

procedure TDACSkiaVisualElement.MouseLeave;
begin
  FHoveredElementId := '';
  ExcludeVisualState(mvsHovered);
end;

procedure TDACSkiaVisualElement.MouseMove(
  const AEvent: TDACPointerEvent; const AHit: TDACHitTestResult);
begin
  if FHoveredElementId <> AHit.ElementId then
  begin
    FHoveredElementId := AHit.ElementId;
    InvalidatePaint;
  end;
end;

procedure TDACSkiaVisualElement.MouseUp(
  const AEvent: TDACPointerEvent; const AHit: TDACHitTestResult);
begin
  FPressedElementId := '';
  ExcludeVisualState(mvsPressed);
end;

function TDACSkiaVisualElement.MouseWheel(
  const AEvent: TDACPointerEvent; const AHit: TDACHitTestResult): Boolean;
begin
  Result := False;
end;

procedure TDACSkiaVisualElement.SetFocus(const AElementId: string);
begin
  FFocusedElementId := AElementId;
  IncludeVisualState(mvsFocused);
end;

procedure TDACSkiaVisualElement.SetTheme(
  const ATheme: IDACComponentsTheme);
begin
  if ATheme = nil then
    FTheme := TDACDefaultComponentsTheme.New
  else
    FTheme := ATheme;
  ThemeChanged;
  InvalidateLayout;
end;

procedure TDACSkiaVisualElement.ThemeChanged;
begin
  InvalidatePaint;
end;

end.

