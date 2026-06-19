unit DAC.Components.Types;

interface

uses
  System.Classes,
  System.Types,
  Vcl.Controls;

type
  TDACVisualState = (
    mvsNormal,
    mvsHovered,
    mvsPressed,
    mvsFocused,
    mvsSelected,
    mvsActive,
    mvsDisabled
  );

  TDACVisualStates = set of TDACVisualState;

  TDACPointerButton = (
    mpbNone,
    mpbLeft,
    mpbRight,
    mpbMiddle
  );

  TDACSkiaLayer = (
    mslBackground,
    mslContent,
    mslChrome,
    mslOverlay,
    mslAdorner
  );

  TDACAccessibleRole = (
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

  TDACPointerEvent = record
    Position: TPointF;
    Button: TDACPointerButton;
    Shift: TShiftState;
    WheelDelta: Integer;
    class function Create(const APosition: TPointF;
      const AButton: TDACPointerButton = mpbNone;
      const AShift: TShiftState = []; const AWheelDelta: Integer = 0): TDACPointerEvent; static;
  end;

  TDACHitTestResult = record
    ComponentId: string;
    ElementId: string;
    Cursor: TCursor;
    Handled: Boolean;
    class function Empty: TDACHitTestResult; static;
    class function Hit(const AComponentId, AElementId: string;
      const ACursor: TCursor = crDefault): TDACHitTestResult; static;
  end;

  TDACInteractionState = record
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

class function TDACPointerEvent.Create(const APosition: TPointF;
  const AButton: TDACPointerButton; const AShift: TShiftState;
  const AWheelDelta: Integer): TDACPointerEvent;
begin
  Result.Position := APosition;
  Result.Button := AButton;
  Result.Shift := AShift;
  Result.WheelDelta := AWheelDelta;
end;

class function TDACHitTestResult.Empty: TDACHitTestResult;
begin
  Result.ComponentId := '';
  Result.ElementId := '';
  Result.Cursor := crDefault;
  Result.Handled := False;
end;

class function TDACHitTestResult.Hit(const AComponentId,
  AElementId: string; const ACursor: TCursor): TDACHitTestResult;
begin
  Result.ComponentId := AComponentId;
  Result.ElementId := AElementId;
  Result.Cursor := ACursor;
  Result.Handled := True;
end;

procedure TDACInteractionState.Clear;
begin
  ClearPointer;
  ClearFocus;
end;

procedure TDACInteractionState.ClearFocus;
begin
  FocusedComponentId := '';
  FocusedElementId := '';
end;

procedure TDACInteractionState.ClearPointer;
begin
  HoveredComponentId := '';
  HoveredElementId := '';
  PressedComponentId := '';
  PressedElementId := '';
  CapturedComponentId := '';
  CapturedElementId := '';
end;

end.

