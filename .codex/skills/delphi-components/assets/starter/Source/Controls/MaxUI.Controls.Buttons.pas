unit MaxUI.Controls.Buttons;

{$CODEPAGE 65001}

interface

uses
  System.Classes,
  Vcl.Controls,
  Vcl.Menus,
  Vcl.StdCtrls,
  MaxUI.Types;

type
  TMaxButton = class(TButton)
  private
    FKind: TMaxButtonKind;
    FControlSize: TMaxControlSize;
    FCornerRadius: Integer;
    FIconKind: TMaxIconKind;
    FIconPosition: TMaxIconPosition;
    FLoading: Boolean;
    FEnabledBeforeLoading: Boolean;
    procedure SetKind(const Value: TMaxButtonKind);
    procedure SetControlSize(const Value: TMaxControlSize);
    procedure SetCornerRadius(const Value: Integer);
    procedure SetIconKind(const Value: TMaxIconKind);
    procedure SetIconPosition(const Value: TMaxIconPosition);
    procedure SetLoading(const Value: Boolean);
    procedure UpdateLogicalHeight;
  protected
    procedure ChangeScale(M, D: Integer; isDpiChange: Boolean); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Kind: TMaxButtonKind read FKind write SetKind default mbkPrimary;
    property ControlSize: TMaxControlSize read FControlSize write SetControlSize default mcsMedium;
    property CornerRadius: Integer read FCornerRadius write SetCornerRadius default 8;
    property IconKind: TMaxIconKind read FIconKind write SetIconKind default mikNone;
    property IconPosition: TMaxIconPosition read FIconPosition write SetIconPosition default mipLeft;
    property Loading: Boolean read FLoading write SetLoading default False;
  end;

  TMaxIconButton = class(TMaxButton)
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TMaxSplitButton = class(TMaxButton)
  private
    FDropDownMenu: TPopupMenu;
    FDropDownWidth: Integer;
    FDropDownClick: Boolean;
    procedure SetDropDownMenu(const Value: TPopupMenu);
    procedure SetDropDownWidth(const Value: Integer);
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Click; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property DropDownMenu: TPopupMenu read FDropDownMenu write SetDropDownMenu;
    property DropDownWidth: Integer read FDropDownWidth write SetDropDownWidth default 32;
  end;

implementation

uses
  System.Math,
  System.Types,
  MaxUI.Dpi,
  MaxUI.Theme;

constructor TMaxButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FKind := mbkPrimary;
  FControlSize := mcsMedium;
  FCornerRadius := TMaxTheme.Metrics.RadiusMedium;
  FIconKind := mikNone;
  FIconPosition := mipLeft;
  FLoading := False;
  FEnabledBeforeLoading := True;
  DoubleBuffered := True;
  StyleElements := [seFont];
  Font.Name := 'Inter';
  Font.Size := 9;
  Caption := 'Botão';
  Width := 120;
  UpdateLogicalHeight;
end;

procedure TMaxButton.ChangeScale(M, D: Integer; isDpiChange: Boolean);
begin
  inherited;
  if isDpiChange then
    UpdateLogicalHeight;
end;

procedure TMaxButton.SetControlSize(const Value: TMaxControlSize);
begin
  if FControlSize = Value then Exit;
  FControlSize := Value;
  UpdateLogicalHeight;
  Invalidate;
end;

procedure TMaxButton.SetCornerRadius(const Value: Integer);
begin
  if FCornerRadius = Value then Exit;
  FCornerRadius := Max(0, Value);
  Invalidate;
end;

procedure TMaxButton.SetIconKind(const Value: TMaxIconKind);
begin
  if FIconKind = Value then Exit;
  FIconKind := Value;
  Invalidate;
end;

procedure TMaxButton.SetIconPosition(const Value: TMaxIconPosition);
begin
  if FIconPosition = Value then Exit;
  FIconPosition := Value;
  Invalidate;
end;

procedure TMaxButton.SetKind(const Value: TMaxButtonKind);
begin
  if FKind = Value then Exit;
  FKind := Value;
  Invalidate;
end;

procedure TMaxButton.SetLoading(const Value: Boolean);
begin
  if FLoading = Value then Exit;
  if Value then
  begin
    FEnabledBeforeLoading := Enabled;
    FLoading := True;
    Enabled := False;
  end
  else
  begin
    FLoading := False;
    Enabled := FEnabledBeforeLoading;
  end;
  Invalidate;
end;

procedure TMaxButton.UpdateLogicalHeight;
var
  LogicalHeight: Integer;
  M: TMaxMetrics;
begin
  M := TMaxTheme.Metrics;
  case FControlSize of
    mcsSmall: LogicalHeight := M.ControlHeightSmall;
    mcsLarge: LogicalHeight := M.ControlHeightLarge;
  else
    LogicalHeight := M.ControlHeightMedium;
  end;
  Height := MaxScale(LogicalHeight, CurrentPPI);
end;

constructor TMaxIconButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Caption := '';
  IconPosition := mipOnly;
  Width := Height;
end;

constructor TMaxSplitButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDropDownWidth := 32;
  FDropDownClick := False;
  Caption := 'Opções';
end;

procedure TMaxSplitButton.Click;
var
  P: TPoint;
begin
  if FDropDownClick and Assigned(FDropDownMenu) then
  begin
    P := ClientToScreen(Point(0, Height));
    FDropDownMenu.Popup(P.X, P.Y);
  end
  else
    inherited Click;
  FDropDownClick := False;
end;

procedure TMaxSplitButton.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  FDropDownClick := (Button = mbLeft) and
    (X >= Width - MaxScale(FDropDownWidth, CurrentPPI));
  inherited;
end;

procedure TMaxSplitButton.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FDropDownMenu) then
    FDropDownMenu := nil;
end;

procedure TMaxSplitButton.SetDropDownMenu(const Value: TPopupMenu);
begin
  if FDropDownMenu = Value then Exit;
  if Assigned(FDropDownMenu) then
    FDropDownMenu.RemoveFreeNotification(Self);
  FDropDownMenu := Value;
  if Assigned(FDropDownMenu) then
    FDropDownMenu.FreeNotification(Self);
end;

procedure TMaxSplitButton.SetDropDownWidth(const Value: Integer);
begin
  if FDropDownWidth = Value then Exit;
  FDropDownWidth := Max(20, Value);
  Invalidate;
end;

end.
