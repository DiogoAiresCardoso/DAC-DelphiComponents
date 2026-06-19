unit DAC.Components.Skia.Container;

interface

uses
  System.Classes,
  System.Generics.Collections,
  System.Skia,
  System.Types,
  Vcl.Controls,
  DAC.Components.DesignSystem.DefaultTheme,
  DAC.Components.DesignSystem.Theme,
  DAC.Components.Skia.VisualElement,
  DAC.Components.Types;

type
  TDACSkiaElementContainer = class
  private
    FCursor: TCursor;
    FElements: TObjectList<TDACSkiaVisualElement>;
    FInteractionState: TDACInteractionState;
    FLayers: TDictionary<TDACSkiaVisualElement, TDACSkiaLayer>;
    FTheme: IDACComponentsTheme;
    function ElementById(const AComponentId: string): TDACSkiaVisualElement;
    function ElementIsFocusable(const AElement: TDACSkiaVisualElement): Boolean;
    function FirstFocusableIndex: Integer;
    function LastFocusableIndex: Integer;
    procedure SetTheme(const ATheme: IDACComponentsTheme);
  public
    constructor Create;
    destructor Destroy; override;
    procedure Add(const AElement: TDACSkiaVisualElement);
    procedure AddLayer(const AElement: TDACSkiaVisualElement;
      const ALayer: TDACSkiaLayer);
    procedure ApplyTheme(const ATheme: IDACComponentsTheme);
    procedure ClearFocus;
    procedure ClearInteractionState;
    procedure ClearPointerState;
    procedure Draw(const ACanvas: ISkCanvas);
    procedure FocusByIndex(const AIndex: Integer);
    procedure FocusComponent(const AComponentId: string; const AElementId: string = '');
    procedure FocusNext(const ADirection: Integer);
    function ActivateFocused: Boolean;
    function HitTest(const APoint: TPointF): TDACHitTestResult;
    procedure KeyDown(var Key: Word; Shift: TShiftState);
    procedure KeyPress(var Key: Char);
    function MouseDown(const APoint: TPointF;
      const AButton: TDACPointerButton; const AShift: TShiftState = []): TDACHitTestResult;
    function MouseMove(const APoint: TPointF; const AShift: TShiftState = []): TDACHitTestResult;
    function MouseUp(const APoint: TPointF;
      const AButton: TDACPointerButton; const AShift: TShiftState = []): TDACHitTestResult;
    function NeedsLayout: Boolean;
    function NeedsPaint: Boolean;
    property Cursor: TCursor read FCursor;
    property InteractionState: TDACInteractionState read FInteractionState;
    property Theme: IDACComponentsTheme read FTheme write SetTheme;
  end;

implementation

uses
  System.Math,
  Winapi.Windows;

constructor TDACSkiaElementContainer.Create;
begin
  inherited Create;
  FElements := TObjectList<TDACSkiaVisualElement>.Create(False);
  FLayers := TDictionary<TDACSkiaVisualElement, TDACSkiaLayer>.Create;
  FTheme := TDACDefaultComponentsTheme.New;
  FCursor := crDefault;
  FInteractionState.Clear;
end;

destructor TDACSkiaElementContainer.Destroy;
begin
  FLayers.Free;
  FElements.Free;
  inherited;
end;

function TDACSkiaElementContainer.ActivateFocused: Boolean;
var
  LElement: TDACSkiaVisualElement;
begin
  LElement := ElementById(FInteractionState.FocusedComponentId);
  Result := (LElement <> nil) and LElement.Activate;
end;

procedure TDACSkiaElementContainer.Add(
  const AElement: TDACSkiaVisualElement);
begin
  AddLayer(AElement, mslContent);
end;

procedure TDACSkiaElementContainer.AddLayer(
  const AElement: TDACSkiaVisualElement; const ALayer: TDACSkiaLayer);
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

procedure TDACSkiaElementContainer.ApplyTheme(
  const ATheme: IDACComponentsTheme);
begin
  SetTheme(ATheme);
end;

procedure TDACSkiaElementContainer.ClearFocus;
var
  LElement: TDACSkiaVisualElement;
begin
  LElement := ElementById(FInteractionState.FocusedComponentId);
  if LElement <> nil then
    LElement.ClearFocus;
  FInteractionState.ClearFocus;
end;

procedure TDACSkiaElementContainer.ClearInteractionState;
var
  LElement: TDACSkiaVisualElement;
begin
  for LElement in FElements do
    LElement.ClearInteractionState;
  FInteractionState.Clear;
end;

procedure TDACSkiaElementContainer.ClearPointerState;
var
  LElement: TDACSkiaVisualElement;
begin
  for LElement in FElements do
    LElement.ClearPointerState;
  FInteractionState.ClearPointer;
end;

procedure TDACSkiaElementContainer.Draw(const ACanvas: ISkCanvas);
var
  LElement: TDACSkiaVisualElement;
  LLayer: TDACSkiaLayer;
  LStage: TDACSkiaLayer;
begin
  for LStage := Low(TDACSkiaLayer) to High(TDACSkiaLayer) do
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

function TDACSkiaElementContainer.ElementById(
  const AComponentId: string): TDACSkiaVisualElement;
var
  LElement: TDACSkiaVisualElement;
begin
  Result := nil;
  for LElement in FElements do
    if LElement.ComponentId = AComponentId then
      Exit(LElement);
end;

function TDACSkiaElementContainer.ElementIsFocusable(
  const AElement: TDACSkiaVisualElement): Boolean;
begin
  Result := (AElement <> nil) and AElement.Visible and AElement.Enabled and AElement.Focusable;
end;

function TDACSkiaElementContainer.FirstFocusableIndex: Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to FElements.Count - 1 do
    if ElementIsFocusable(FElements[I]) then
      Exit(I);
end;

procedure TDACSkiaElementContainer.FocusByIndex(const AIndex: Integer);
var
  LIndex: Integer;
begin
  if FElements.Count = 0 then
    Exit;
  LIndex := EnsureRange(AIndex, 0, FElements.Count - 1);
  if ElementIsFocusable(FElements[LIndex]) then
    FocusComponent(FElements[LIndex].ComponentId);
end;

procedure TDACSkiaElementContainer.FocusComponent(const AComponentId,
  AElementId: string);
var
  LElement: TDACSkiaVisualElement;
  LPrevious: TDACSkiaVisualElement;
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

procedure TDACSkiaElementContainer.FocusNext(const ADirection: Integer);
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

function TDACSkiaElementContainer.HitTest(
  const APoint: TPointF): TDACHitTestResult;
var
  I: Integer;
  LEvent: TDACPointerEvent;
begin
  Result := TDACHitTestResult.Empty;
  LEvent := TDACPointerEvent.Create(APoint);
  for I := FElements.Count - 1 downto 0 do
  begin
    Result := FElements[I].HitTest(LEvent);
    if Result.Handled then
      Exit;
  end;
end;

procedure TDACSkiaElementContainer.KeyDown(var Key: Word;
  Shift: TShiftState);
var
  LElement: TDACSkiaVisualElement;
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

procedure TDACSkiaElementContainer.KeyPress(var Key: Char);
var
  LElement: TDACSkiaVisualElement;
begin
  LElement := ElementById(FInteractionState.FocusedComponentId);
  if LElement <> nil then
    LElement.KeyPress(Key);
end;

function TDACSkiaElementContainer.LastFocusableIndex: Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := FElements.Count - 1 downto 0 do
    if ElementIsFocusable(FElements[I]) then
      Exit(I);
end;

function TDACSkiaElementContainer.MouseDown(const APoint: TPointF;
  const AButton: TDACPointerButton; const AShift: TShiftState): TDACHitTestResult;
var
  LElement: TDACSkiaVisualElement;
  LEvent: TDACPointerEvent;
begin
  Result := HitTest(APoint);
  if not Result.Handled then
    Exit;

  LElement := ElementById(Result.ComponentId);
  LEvent := TDACPointerEvent.Create(APoint, AButton, AShift);
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

function TDACSkiaElementContainer.MouseMove(const APoint: TPointF;
  const AShift: TShiftState): TDACHitTestResult;
var
  LElement: TDACSkiaVisualElement;
  LEvent: TDACPointerEvent;
  LPrevious: TDACSkiaVisualElement;
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
  LEvent := TDACPointerEvent.Create(APoint, mpbNone, AShift);
  if LElement <> nil then
    LElement.MouseMove(LEvent, Result);

  FInteractionState.HoveredComponentId := Result.ComponentId;
  FInteractionState.HoveredElementId := Result.ElementId;
end;

function TDACSkiaElementContainer.MouseUp(const APoint: TPointF;
  const AButton: TDACPointerButton; const AShift: TShiftState): TDACHitTestResult;
var
  LElement: TDACSkiaVisualElement;
  LEvent: TDACPointerEvent;
begin
  Result := HitTest(APoint);
  LElement := ElementById(FInteractionState.CapturedComponentId);
  LEvent := TDACPointerEvent.Create(APoint, AButton, AShift);
  if LElement <> nil then
    LElement.MouseUp(LEvent, Result);
  FInteractionState.PressedComponentId := '';
  FInteractionState.PressedElementId := '';
  FInteractionState.CapturedComponentId := '';
  FInteractionState.CapturedElementId := '';
end;

function TDACSkiaElementContainer.NeedsLayout: Boolean;
var
  LElement: TDACSkiaVisualElement;
begin
  Result := False;
  for LElement in FElements do
    if LElement.NeedsLayout then
      Exit(True);
end;

function TDACSkiaElementContainer.NeedsPaint: Boolean;
var
  LElement: TDACSkiaVisualElement;
begin
  Result := False;
  for LElement in FElements do
    if LElement.NeedsPaint then
      Exit(True);
end;

procedure TDACSkiaElementContainer.SetTheme(
  const ATheme: IDACComponentsTheme);
var
  LElement: TDACSkiaVisualElement;
begin
  if ATheme = nil then
    FTheme := TDACDefaultComponentsTheme.New
  else
    FTheme := ATheme;
  for LElement in FElements do
    LElement.Theme := FTheme;
end;

end.

