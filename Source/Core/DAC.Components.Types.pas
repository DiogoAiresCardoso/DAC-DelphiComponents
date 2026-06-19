unit MaxxRural.Components.Types;

interface

uses
  System.Classes,
  System.Types,
  Vcl.Controls;

type
  TMaxxRuralVisualState = (
    mvsNormal,
    mvsHovered,
    mvsPressed,
    mvsFocused,
    mvsSelected,
    mvsActive,
    mvsDisabled
  );

  TMaxxRuralVisualStates = set of TMaxxRuralVisualState;

  TMaxxRuralPointerButton = (
    mpbNone,
    mpbLeft,
    mpbRight,
    mpbMiddle
  );

  TMaxxRuralSkiaLayer = (
    mslBackground,
    mslContent,
    mslChrome,
    mslOverlay,
    mslAdorner
  );

  TMaxxRuralAccessibleRole = (
    marNone,
    marButton,
    marInput,
    marList,
    marListItem,
    marGrid,
    marGridCell,
    marTab,
    marProgress,
    marChart,
    marDialog,
    marDocument
  );

  TMaxxRuralPointerEvent = record
    Position: TPointF;
    Button: TMaxxRuralPointerButton;
    Shift: TShiftState;
    WheelDelta: Integer;
    class function Create(const APosition: TPointF;
      const AButton: TMaxxRuralPointerButton = mpbNone;
      const AShift: TShiftState = []; const AWheelDelta: Integer = 0): TMaxxRuralPointerEvent; static;
  end;

  TMaxxRuralHitTestResult = record
    ComponentId: string;
    ElementId: string;
    Cursor: TCursor;
    Handled: Boolean;
    class function Empty: TMaxxRuralHitTestResult; static;
    class function Hit(const AComponentId, AElementId: string;
      const ACursor: TCursor = crDefault): TMaxxRuralHitTestResult; static;
  end;

  TMaxxRuralInteractionState = record
    HoveredComponentId: string;
    HoveredElementId: string;
    PressedComponentId: string;
    PressedElementId: string;
    CapturedComponentId: string;
    CapturedElementId: string;
    FocusedComponentId: string;
    FocusedElementId: string;
    procedure Clear;
    procedure ClearPointer;
    procedure ClearFocus;
  end;

implementation

class function TMaxxRuralPointerEvent.Create(const APosition: TPointF;
  const AButton: TMaxxRuralPointerButton; const AShift: TShiftState;
  const AWheelDelta: Integer): TMaxxRuralPointerEvent;
begin
  Result.Position := APosition;
  Result.Button := AButton;
  Result.Shift := AShift;
  Result.WheelDelta := AWheelDelta;
end;

class function TMaxxRuralHitTestResult.Empty: TMaxxRuralHitTestResult;
begin
  Result.ComponentId := '';
  Result.ElementId := '';
  Result.Cursor := crDefault;
  Result.Handled := False;
end;

class function TMaxxRuralHitTestResult.Hit(const AComponentId,
  AElementId: string; const ACursor: TCursor): TMaxxRuralHitTestResult;
begin
  Result.ComponentId := AComponentId;
  Result.ElementId := AElementId;
  Result.Cursor := ACursor;
  Result.Handled := True;
end;

procedure TMaxxRuralInteractionState.Clear;
begin
  ClearPointer;
  ClearFocus;
end;

procedure TMaxxRuralInteractionState.ClearFocus;
begin
  FocusedComponentId := '';
  FocusedElementId := '';
end;

procedure TMaxxRuralInteractionState.ClearPointer;
begin
  HoveredComponentId := '';
  HoveredElementId := '';
  PressedComponentId := '';
  PressedElementId := '';
  CapturedComponentId := '';
  CapturedElementId := '';
end;

end.
