unit MaxUI.Controls.Selectors;

{$CODEPAGE 65001}

interface

uses
  System.Classes,
  System.SysUtils,
  Winapi.Messages,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.ComCtrls,
  MaxUI.Types;

type
  TMaxComboBox = class(TComboBox)
  private
    FPlaceholder: string;
    FFieldState: TMaxFieldState;
    FCornerRadius: Integer;
    procedure SetPlaceholder(const Value: string);
    procedure SetFieldState(const Value: TMaxFieldState);
    procedure SetCornerRadius(const Value: Integer);
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Placeholder: string read FPlaceholder write SetPlaceholder;
    property FieldState: TMaxFieldState read FFieldState write SetFieldState default mfsNormal;
    property CornerRadius: Integer read FCornerRadius write SetCornerRadius default 8;
  end;

  TMaxDatePicker = class(TDateTimePicker)
  private
    FFieldState: TMaxFieldState;
    FCornerRadius: Integer;
    procedure SetFieldState(const Value: TMaxFieldState);
    procedure SetCornerRadius(const Value: Integer);
  public
    constructor Create(AOwner: TComponent); override;
  published
    property FieldState: TMaxFieldState read FFieldState write SetFieldState default mfsNormal;
    property CornerRadius: Integer read FCornerRadius write SetCornerRadius default 8;
  end;

  TMaxTimePicker = class(TDateTimePicker)
  private
    FFieldState: TMaxFieldState;
    FCornerRadius: Integer;
    procedure SetFieldState(const Value: TMaxFieldState);
    procedure SetCornerRadius(const Value: Integer);
  public
    constructor Create(AOwner: TComponent); override;
  published
    property FieldState: TMaxFieldState read FFieldState write SetFieldState default mfsNormal;
    property CornerRadius: Integer read FCornerRadius write SetCornerRadius default 8;
  end;

  TMaxSpinField = class(TCustomControl)
  private
    FEdit: TEdit;
    FUpDown: TUpDown;
    FMinimum: Integer;
    FMaximum: Integer;
    FPosition: Integer;
    FIncrement: Integer;
    FFieldState: TMaxFieldState;
    FOnChange: TNotifyEvent;
    FInternalChange: Boolean;
    procedure EditChange(Sender: TObject);
    procedure UpDownClick(Sender: TObject; Button: TUDBtnType);
    procedure SetMinimum(const Value: Integer);
    procedure SetMaximum(const Value: Integer);
    procedure SetPosition(const Value: Integer);
    procedure SetIncrement(const Value: Integer);
    procedure SetFieldState(const Value: TMaxFieldState);
    function GetText: string;
    procedure SetText(const Value: string);
  protected
    procedure Paint; override;
    procedure Resize; override;
    procedure DoEnter; override;
    procedure DoExit; override;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
  public
    constructor Create(AOwner: TComponent); override;
    property Editor: TEdit read FEdit;
  published
    property Align;
    property Anchors;
    property Constraints;
    property Enabled;
    property Font;
    property ParentFont;
    property TabOrder;
    property TabStop default True;
    property Minimum: Integer read FMinimum write SetMinimum default 0;
    property Maximum: Integer read FMaximum write SetMaximum default 100;
    property Position: Integer read FPosition write SetPosition default 0;
    property Increment: Integer read FIncrement write SetIncrement default 1;
    property Text: string read GetText write SetText;
    property FieldState: TMaxFieldState read FFieldState write SetFieldState default mfsNormal;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

implementation

uses
  System.Math,
  Winapi.Windows,
  MaxUI.Dpi,
  MaxUI.Painter,
  MaxUI.Theme;

constructor TMaxComboBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FPlaceholder := 'Selecione uma opção';
  FFieldState := mfsNormal;
  FCornerRadius := TMaxTheme.Metrics.RadiusMedium;
  Style := csDropDownList;
  StyleElements := [seFont];
  Font.Name := 'Inter';
  Font.Size := 9;
  Color := TMaxTheme.Palette.Surface;
  Width := 220;
  Height := MaxScale(TMaxTheme.Metrics.ControlHeightMedium, CurrentPPI);
end;

procedure TMaxComboBox.SetCornerRadius(const Value: Integer);
begin
  if FCornerRadius = Value then Exit;
  FCornerRadius := Max(0, Value);
  Invalidate;
end;

procedure TMaxComboBox.SetFieldState(const Value: TMaxFieldState);
begin
  if FFieldState = Value then Exit;
  FFieldState := Value;
  Enabled := Value <> mfsDisabled;
  Invalidate;
end;

procedure TMaxComboBox.SetPlaceholder(const Value: string);
begin
  if FPlaceholder = Value then Exit;
  FPlaceholder := Value;
  Invalidate;
end;

constructor TMaxDatePicker.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FFieldState := mfsNormal;
  FCornerRadius := TMaxTheme.Metrics.RadiusMedium;
  Kind := dtkDate;
  Format := 'dd/MM/yyyy';
  StyleElements := [seFont];
  Font.Name := 'Inter';
  Font.Size := 9;
  Width := 140;
  Height := MaxScale(TMaxTheme.Metrics.ControlHeightMedium, CurrentPPI);
end;

procedure TMaxDatePicker.SetCornerRadius(const Value: Integer);
begin
  if FCornerRadius = Value then Exit;
  FCornerRadius := Max(0, Value);
  Invalidate;
end;

procedure TMaxDatePicker.SetFieldState(const Value: TMaxFieldState);
begin
  if FFieldState = Value then Exit;
  FFieldState := Value;
  Enabled := Value <> mfsDisabled;
  Invalidate;
end;

constructor TMaxTimePicker.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FFieldState := mfsNormal;
  FCornerRadius := TMaxTheme.Metrics.RadiusMedium;
  Kind := dtkTime;
  Format := 'HH:mm:ss';
  StyleElements := [seFont];
  Font.Name := 'Inter';
  Font.Size := 9;
  Width := 120;
  Height := MaxScale(TMaxTheme.Metrics.ControlHeightMedium, CurrentPPI);
end;

procedure TMaxTimePicker.SetCornerRadius(const Value: Integer);
begin
  if FCornerRadius = Value then Exit;
  FCornerRadius := Max(0, Value);
  Invalidate;
end;

procedure TMaxTimePicker.SetFieldState(const Value: TMaxFieldState);
begin
  if FFieldState = Value then Exit;
  FFieldState := Value;
  Enabled := Value <> mfsDisabled;
  Invalidate;
end;

constructor TMaxSpinField.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  DoubleBuffered := True;
  ParentBackground := False;
  StyleElements := [seFont];
  TabStop := True;
  FMinimum := 0;
  FMaximum := 100;
  FPosition := 0;
  FIncrement := 1;
  FFieldState := mfsNormal;
  Width := 100;
  Height := MaxScale(TMaxTheme.Metrics.ControlHeightMedium, CurrentPPI);
  Font.Name := 'Inter';
  Font.Size := 9;

  FEdit := TEdit.Create(Self);
  FEdit.Parent := Self;
  FEdit.SetSubComponent(True);
  FEdit.BorderStyle := bsNone;
  FEdit.Color := TMaxTheme.Palette.Surface;
  FEdit.Font.Assign(Font);
  FEdit.Text := '0';
  FEdit.OnChange := EditChange;

  FUpDown := TUpDown.Create(Self);
  FUpDown.Parent := Self;
  FUpDown.SetSubComponent(True);
  FUpDown.Min := FMinimum;
  FUpDown.Max := FMaximum;
  FUpDown.Position := FPosition;
  FUpDown.Increment := FIncrement;
  FUpDown.OnClick := UpDownClick;
end;

procedure TMaxSpinField.DoEnter;
begin
  inherited;
  FFieldState := mfsFocused;
  Invalidate;
  if FEdit.CanFocus then
    FEdit.SetFocus;
end;

procedure TMaxSpinField.DoExit;
begin
  inherited;
  if FFieldState = mfsFocused then
    FFieldState := mfsNormal;
  Invalidate;
end;

procedure TMaxSpinField.EditChange(Sender: TObject);
var
  V: Integer;
begin
  if FInternalChange then Exit;
  if TryStrToInt(Trim(FEdit.Text), V) then
  begin
    V := EnsureRange(V, FMinimum, FMaximum);
    if FPosition <> V then
    begin
      FPosition := V;
      FUpDown.Position := V;
      if Assigned(FOnChange) then
        FOnChange(Self);
    end;
  end;
end;

function TMaxSpinField.GetText: string;
begin
  Result := FEdit.Text;
end;

procedure TMaxSpinField.Paint;
begin
  TMaxPainter.DrawFieldFrame(Canvas, ClientRect, FFieldState,
    TMaxTheme.Metrics.RadiusMedium, CurrentPPI);
end;

procedure TMaxSpinField.Resize;
var
  ButtonWidth: Integer;
  Padding: Integer;
begin
  inherited;
  ButtonWidth := MaxScale(22, CurrentPPI);
  Padding := MaxScale(8, CurrentPPI);
  FUpDown.SetBounds(Width - ButtonWidth - 2, 2, ButtonWidth, Height - 4);
  FEdit.SetBounds(Padding, (Height - FEdit.Font.Height) div 2 - 2,
    Max(1, Width - ButtonWidth - Padding - 6), Max(18, Height - 8));
end;

procedure TMaxSpinField.SetFieldState(const Value: TMaxFieldState);
begin
  if FFieldState = Value then Exit;
  FFieldState := Value;
  Enabled := Value <> mfsDisabled;
  FEdit.Enabled := Enabled;
  FUpDown.Enabled := Enabled;
  Invalidate;
end;

procedure TMaxSpinField.SetIncrement(const Value: Integer);
begin
  if FIncrement = Value then Exit;
  FIncrement := Max(1, Value);
  FUpDown.Increment := FIncrement;
end;

procedure TMaxSpinField.SetMaximum(const Value: Integer);
begin
  if FMaximum = Value then Exit;
  FMaximum := Max(FMinimum, Value);
  FUpDown.Max := EnsureRange(FMaximum, Low(SmallInt), High(SmallInt));
  Position := FPosition;
end;

procedure TMaxSpinField.SetMinimum(const Value: Integer);
begin
  if FMinimum = Value then Exit;
  FMinimum := Min(Value, FMaximum);
  FUpDown.Min := EnsureRange(FMinimum, Low(SmallInt), High(SmallInt));
  Position := FPosition;
end;

procedure TMaxSpinField.SetPosition(const Value: Integer);
begin
  if FPosition = EnsureRange(Value, FMinimum, FMaximum) then Exit;
  FPosition := EnsureRange(Value, FMinimum, FMaximum);
  FInternalChange := True;
  try
    FEdit.Text := IntToStr(FPosition);
    FUpDown.Position := EnsureRange(FPosition, Low(SmallInt), High(SmallInt));
  finally
    FInternalChange := False;
  end;
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TMaxSpinField.SetText(const Value: string);
begin
  FEdit.Text := Value;
  EditChange(FEdit);
end;

procedure TMaxSpinField.UpDownClick(Sender: TObject; Button: TUDBtnType);
var
  Delta: Integer;
begin
  if Button = btNext then
    Delta := FIncrement
  else
    Delta := -FIncrement;
  Position := FPosition + Delta;
end;

procedure TMaxSpinField.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  Message.Result := 1;
end;

end.
