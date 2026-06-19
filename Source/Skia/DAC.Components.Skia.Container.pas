unit MaxxRural.Components.Skia.Container;

interface

uses
  System.Classes,
  System.Generics.Collections,
  System.Skia,
  System.Types,
  Vcl.Controls,
  MaxxRural.Components.DesignSystem.DefaultTheme,
  MaxxRural.Components.DesignSystem.Theme,
  MaxxRural.Components.Skia.VisualElement,
  MaxxRural.Components.Types;

type
  TMaxxRuralSkiaElementContainer = class
  private
    FCursor: TCursor;
    FElements: TObjectList<TMaxxRuralSkiaVisualElement>;
    FInteractionState: TMaxxRuralInteractionState;
    FLayers: TDictionary<TMaxxRuralSkiaVisualElement, TMaxxRuralSkiaLayer>;
    FTheme: IMaxxRuralComponentsTheme;
    function ElementById(const AComponentId: string): TMaxxRuralSkiaVisualElement;
    function ElementIsFocusable(const AElement: TMaxxRuralSkiaVisualElement): Boolean;
    function FirstFocusableIndex: Integer;
    function LastFocusableIndex: Integer;
    procedure SetTheme(const ATheme: IMaxxRuralComponentsTheme);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(const AElement: TMaxxRuralSkiaVisualElement);
    procedure AddLayer(const AElement: TMaxxRuralSkiaVisualElement;
      const ALayer: TMaxxRuralSkiaLayer);
    procedure ApplyTheme(const ATheme: IMaxxRuralComponentsTheme);
    procedure ClearFocus;
    procedure ClearInteractionState;
    procedure ClearPointerState;
    procedure Draw(const ACanvas: ISkCanvas);
    procedure FocusByIndex(const AIndex: Integer);
    procedure FocusComponent(const AComponentId: string; const AElementId: string = '');
    procedure FocusNext(const ADirection: Integer);
    function ActivateFocused: Boolean;
    function HitTest(const APoint: TPointF): TMaxxRuralHitTestResult;
    procedure KeyDown(var Key: Word; Shift: TShiftState);
    procedure KeyPress(var Key: Char);
    function MouseDown(const APoint: TPointF;
      const AButton: TMaxxRuralPointerButton; const AShift: TShiftState = []): TMaxxRuralHitTestResult;
    function MouseMove(const APoint: TPointF; const AShift: TShiftState = []): TMaxxRuralHitTestResult;
    function MouseUp(const APoint: TPointF;
      const AButton: TMaxxRuralPointerButton; const AShift: TShiftState = []): TMaxxRuralHitTestResult;
    function NeedsLayout: Boolean;
    function NeedsPaint: Boolean;
    property Cursor: TCursor read FCursor;
    property InteractionState: TMaxxRuralInteractionState read FInteractionState;
    property Theme: IMaxxRuralComponentsTheme read FTheme write SetTheme;
  end;

implementation

uses
  System.Math,
  Winapi.Windows;

constructor TMaxxRuralSkiaElementContainer.Create;
begin
  inherited Create;
  FElements := TObjectList<TMaxxRuralSkiaVisualElement>.Create(False);
  FLayers := TDictionary<TMaxxRuralSkiaVisualElement, TMaxxRuralSkiaLayer>.Create;
  FTheme := TMaxxRuralDefaultComponentsTheme.New;
  FCursor := crDefault;
  FInteractionState.Clear;
end;

destructor TMaxxRuralSkiaElementContainer.Destroy;
begin
  FLayers.Free;
  FElements.Free;
  inherited;
end;

function TMaxxRuralSkiaElementContainer.ActivateFocused: Boolean;
var
  LElement: TMaxxRuralSkiaVisualElement;
begin
  LElement := ElementById(FInteractionState.FocusedComponentId);
  Result := (LElement <> nil) and LElement.Activate;
end;

procedure TMaxxRuralSkiaElementContainer.Add(
  const AElement: TMaxxRuralSkiaVisualElement);
begin
  AddLayer(AElement, mslContent);
end;

procedure TMaxxRuralSkiaElementContainer.AddLayer(
  const AElement: TMaxxRuralSkiaVisualElement; const ALayer: TMaxxRuralSkiaLayer);
begin
  if AElement = nil then
    Exit;
  if FElements.IndexOf(AElement) < 0 then
  begin
    FElements.Add(AElement);
    AElement.Theme := FTheme;
  end;
  FLayers.AddOrSetValue(AElement, ALayer);
end;

procedure TMaxxRuralSkiaElementContainer.ApplyTheme(
  const ATheme: IMaxxRuralComponentsTheme);
begin
  SetTheme(ATheme);
end;

procedure TMaxxRuralSkiaElementContainer.ClearFocus;
var
  LElement: TMaxxRuralSkiaVisualElement;
begin
  LElement := ElementById(FInteractionState.FocusedComponentId);
  if LElement <> nil then
    LElement.ClearFocus;
  FInteractionState.ClearFocus;
end;

procedure TMaxxRuralSkiaElementContainer.ClearInteractionState;
var
  LElement: TMaxxRuralSkiaVisualElement;
begin
  for LElement in FElements do
    LElement.ClearInteractionState;
  FInteractionState.Clear;
end;

procedure TMaxxRuralSkiaElementContainer.ClearPointerState;
var
  LElement: TMaxxRuralSkiaVisualElement;
begin
  for LElement in FElements do
    LElement.ClearPointerState;
  FInteractionState.ClearPointer;
end;

procedure TMaxxRuralSkiaElementContainer.Draw(const ACanvas: ISkCanvas);
var
  LElement: TMaxxRuralSkiaVisualElement;
  LLayer: TMaxxRuralSkiaLayer;
  LStage: TMaxxRuralSkiaLayer;
begin
  for LStage := Low(TMaxxRuralSkiaLayer) to High(TMaxxRuralSkiaLayer) do
    for LElement in FElements do
    begin
      if not LElement.Visible then
        Continue;
      if not FLayers.TryGetValue(LElement, LLayer) then
        LLayer := mslContent;
      if LLayer = LStage then
        LElement.Draw(ACanvas);
    end;
end;

function TMaxxRuralSkiaElementContainer.ElementById(
  const AComponentId: string): TMaxxRuralSkiaVisualElement;
var
  LElement: TMaxxRuralSkiaVisualElement;
begin
  Result := nil;
  for LElement in FElements do
    if LElement.ComponentId = AComponentId then
      Exit(LElement);
end;

function TMaxxRuralSkiaElementContainer.ElementIsFocusable(
  const AElement: TMaxxRuralSkiaVisualElement): Boolean;
begin
  Result := (AElement <> nil) and AElement.Visible and AElement.Enabled and AElement.Focusable;
end;

function TMaxxRuralSkiaElementContainer.FirstFocusableIndex: Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to FElements.Count - 1 do
    if ElementIsFocusable(FElements[I]) then
      Exit(I);
end;

procedure TMaxxRuralSkiaElementContainer.FocusByIndex(const AIndex: Integer);
var
  LIndex: Integer;
begin
  if FElements.Count = 0 then
    Exit;
  LIndex := EnsureRange(AIndex, 0, FElements.Count - 1);
  if ElementIsFocusable(FElements[LIndex]) then
    FocusComponent(FElements[LIndex].ComponentId);
end;

procedure TMaxxRuralSkiaElementContainer.FocusComponent(const AComponentId,
  AElementId: string);
var
  LElement: TMaxxRuralSkiaVisualElement;
  LPrevious: TMaxxRuralSkiaVisualElement;
begin
  LPrevious := ElementById(FInteractionState.FocusedComponentId);
  if LPrevious <> nil then
    LPrevious.ClearFocus;

  LElement := ElementById(AComponentId);
  if not ElementIsFocusable(LElement) then
  begin
    FInteractionState.ClearFocus;
    Exit;
  end;

  LElement.SetFocus(AElementId);
  FInteractionState.FocusedComponentId := AComponentId;
  FInteractionState.FocusedElementId := AElementId;
end;

procedure TMaxxRuralSkiaElementContainer.FocusNext(const ADirection: Integer);
var
  I: Integer;
  LCurrentIndex: Integer;
  LNextIndex: Integer;
begin
  if FElements.Count = 0 then
    Exit;

  LCurrentIndex := -1;
  for I := 0 to FElements.Count - 1 do
    if FElements[I].ComponentId = FInteractionState.FocusedComponentId then
    begin
      LCurrentIndex := I;
      Break;
    end;

  if LCurrentIndex < 0 then
  begin
    if ADirection < 0 then
      FocusByIndex(LastFocusableIndex)
    else
      FocusByIndex(FirstFocusableIndex);
    Exit;
  end;

  LNextIndex := LCurrentIndex;
  repeat
    Inc(LNextIndex, ADirection);
    if LNextIndex < 0 then
      LNextIndex := FElements.Count - 1;
    if LNextIndex >= FElements.Count then
      LNextIndex := 0;
    if ElementIsFocusable(FElements[LNextIndex]) then
    begin
      FocusByIndex(LNextIndex);
      Exit;
    end;
  until LNextIndex = LCurrentIndex;
end;

function TMaxxRuralSkiaElementContainer.HitTest(
  const APoint: TPointF): TMaxxRuralHitTestResult;
var
  I: Integer;
  LEvent: TMaxxRuralPointerEvent;
begin
  Result := TMaxxRuralHitTestResult.Empty;
  LEvent := TMaxxRuralPointerEvent.Create(APoint);
  for I := FElements.Count - 1 downto 0 do
  begin
    Result := FElements[I].HitTest(LEvent);
    if Result.Handled then
      Exit;
  end;
end;

procedure TMaxxRuralSkiaElementContainer.KeyDown(var Key: Word;
  Shift: TShiftState);
var
  LElement: TMaxxRuralSkiaVisualElement;
begin
  case Key of
    VK_TAB:
      begin
        if ssShift in Shift then
          FocusNext(-1)
        else
          FocusNext(1);
        Key := 0;
      end;
    VK_RETURN, VK_SPACE:
      if ActivateFocused then
        Key := 0;
  else
    LElement := ElementById(FInteractionState.FocusedComponentId);
    if LElement <> nil then
      LElement.KeyDown(Key, Shift);
  end;
end;

procedure TMaxxRuralSkiaElementContainer.KeyPress(var Key: Char);
var
  LElement: TMaxxRuralSkiaVisualElement;
begin
  LElement := ElementById(FInteractionState.FocusedComponentId);
  if LElement <> nil then
    LElement.KeyPress(Key);
end;

function TMaxxRuralSkiaElementContainer.LastFocusableIndex: Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := FElements.Count - 1 downto 0 do
    if ElementIsFocusable(FElements[I]) then
      Exit(I);
end;

function TMaxxRuralSkiaElementContainer.MouseDown(const APoint: TPointF;
  const AButton: TMaxxRuralPointerButton; const AShift: TShiftState): TMaxxRuralHitTestResult;
var
  LElement: TMaxxRuralSkiaVisualElement;
  LEvent: TMaxxRuralPointerEvent;
begin
  Result := HitTest(APoint);
  if not Result.Handled then
    Exit;

  LElement := ElementById(Result.ComponentId);
  LEvent := TMaxxRuralPointerEvent.Create(APoint, AButton, AShift);
  if LElement <> nil then
  begin
    LElement.MouseDown(LEvent, Result);
    FInteractionState.PressedComponentId := Result.ComponentId;
    FInteractionState.PressedElementId := Result.ElementId;
    FInteractionState.CapturedComponentId := Result.ComponentId;
    FInteractionState.CapturedElementId := Result.ElementId;
    FocusComponent(Result.ComponentId, Result.ElementId);
  end;
end;

function TMaxxRuralSkiaElementContainer.MouseMove(const APoint: TPointF;
  const AShift: TShiftState): TMaxxRuralHitTestResult;
var
  LElement: TMaxxRuralSkiaVisualElement;
  LEvent: TMaxxRuralPointerEvent;
  LPrevious: TMaxxRuralSkiaVisualElement;
begin
  Result := HitTest(APoint);
  FCursor := Result.Cursor;

  if FInteractionState.HoveredComponentId <> Result.ComponentId then
  begin
    LPrevious := ElementById(FInteractionState.HoveredComponentId);
    if LPrevious <> nil then
      LPrevious.MouseLeave;
    LElement := ElementById(Result.ComponentId);
    if LElement <> nil then
      LElement.MouseEnter(Result);
  end;

  LElement := ElementById(Result.ComponentId);
  LEvent := TMaxxRuralPointerEvent.Create(APoint, mpbNone, AShift);
  if LElement <> nil then
    LElement.MouseMove(LEvent, Result);

  FInteractionState.HoveredComponentId := Result.ComponentId;
  FInteractionState.HoveredElementId := Result.ElementId;
end;

function TMaxxRuralSkiaElementContainer.MouseUp(const APoint: TPointF;
  const AButton: TMaxxRuralPointerButton; const AShift: TShiftState): TMaxxRuralHitTestResult;
var
  LElement: TMaxxRuralSkiaVisualElement;
  LEvent: TMaxxRuralPointerEvent;
begin
  Result := HitTest(APoint);
  LElement := ElementById(FInteractionState.CapturedComponentId);
  LEvent := TMaxxRuralPointerEvent.Create(APoint, AButton, AShift);
  if LElement <> nil then
    LElement.MouseUp(LEvent, Result);
  FInteractionState.PressedComponentId := '';
  FInteractionState.PressedElementId := '';
  FInteractionState.CapturedComponentId := '';
  FInteractionState.CapturedElementId := '';
end;

function TMaxxRuralSkiaElementContainer.NeedsLayout: Boolean;
var
  LElement: TMaxxRuralSkiaVisualElement;
begin
  Result := False;
  for LElement in FElements do
    if LElement.NeedsLayout then
      Exit(True);
end;

function TMaxxRuralSkiaElementContainer.NeedsPaint: Boolean;
var
  LElement: TMaxxRuralSkiaVisualElement;
begin
  Result := False;
  for LElement in FElements do
    if LElement.NeedsPaint then
      Exit(True);
end;

procedure TMaxxRuralSkiaElementContainer.SetTheme(
  const ATheme: IMaxxRuralComponentsTheme);
var
  LElement: TMaxxRuralSkiaVisualElement;
begin
  if ATheme = nil then
    FTheme := TMaxxRuralDefaultComponentsTheme.New
  else
    FTheme := ATheme;
  for LElement in FElements do
    LElement.Theme := FTheme;
end;

end.
