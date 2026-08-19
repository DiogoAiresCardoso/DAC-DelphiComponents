unit MaxUI.Controls.Choices;

{$CODEPAGE 65001}

interface

uses
  System.Classes,
  Winapi.Messages,
  Vcl.Controls,
  Vcl.StdCtrls,
  MaxUI.Types;

type
  TMaxCheckBox = class(TCheckBox)
  private
    FGlyphSize: Integer;
    procedure SetGlyphSize(const Value: Integer);
  public
    constructor Create(AOwner: TComponent); override;
  published
    property GlyphSize: Integer read FGlyphSize write SetGlyphSize default 16;
  end;

  TMaxRadioButton = class(TRadioButton)
  private
    FGlyphSize: Integer;
    procedure SetGlyphSize(const Value: Integer);
  public
    constructor Create(AOwner: TComponent); override;
  published
    property GlyphSize: Integer read FGlyphSize write SetGlyphSize default 16;
  end;

  TMaxToggleSwitch = class(TCustomControl)
  private
    FChecked: Boolean;
    FOnText: string;
    FOffText: string;
    FShowStateText: Boolean;
    FOnChange: TNotifyEvent;
    procedure SetChecked(const Value: Boolean);
    procedure SetOnText(const Value: string);
    procedure SetOffText(const Value: string);
    procedure SetShowStateText(const Value: Boolean);
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure DoChange; virtual;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Align;
    property Anchors;
    property Enabled;
    property Font;
    property ParentFont;
    property TabOrder;
    property TabStop default True;
    property Checked: Boolean read FChecked write SetChecked default False;
    property OnText: string read FOnText write SetOnText;
    property OffText: string read FOffText write SetOffText;
    property ShowStateText: Boolean read FShowStateText write SetShowStateText default False;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TMaxSlider = class(TCustomControl)
  private
    FMinimum: Integer;
    FMaximum: Integer;
    FPosition: Integer;
    FShowValue: Boolean;
    FDragging: Boolean;
    FOnChange: TNotifyEvent;
    procedure SetMinimum(const Value: Integer);
    procedure SetMaximum(const Value: Integer);
    procedure SetPosition(const Value: Integer);
    procedure SetShowValue(const Value: Boolean);
    procedure SetPositionFromX(const X: Integer);
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure DoChange; virtual;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Align;
    property Anchors;
    property Enabled;
    property Font;
    property ParentFont;
    property TabOrder;
    property TabStop default True;
    property Minimum: Integer read FMinimum write SetMinimum default 0;
    property Maximum: Integer read FMaximum write SetMaximum default 100;
    property Position: Integer read FPosition write SetPosition default 0;
    property ShowValue: Boolean read FShowValue write SetShowValue default True;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

implementation

uses
  System.Math,
  System.SysUtils,
  Winapi.Windows,
  MaxUI.Dpi,
  MaxUI.Painter,
  MaxUI.Theme;

constructor TMaxCheckBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FGlyphSize := 16;
  StyleElements := [seFont];
  Font.Name := 'Inter';
  Font.Size := 9;
  Height := 24;
  Width := 150;
end;

procedure TMaxCheckBox.SetGlyphSize(const Value: Integer);
begin
  if FGlyphSize = Value then Exit;
  FGlyphSize := Max(12, Value);
  Invalidate;
end;

constructor TMaxRadioButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FGlyphSize := 16;
  StyleElements := [seFont];
  Font.Name := 'Inter';
  Font.Size := 9;
  Height := 24;
  Width := 150;
end;

procedure TMaxRadioButton.SetGlyphSize(const Value: Integer);
begin
  if FGlyphSize = Value then Exit;
  FGlyphSize := Max(12, Value);
  Invalidate;
end;

constructor TMaxToggleSwitch.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  DoubleBuffered := True;
  ParentBackground := False;
  StyleElements := [seFont];
  TabStop := True;
  FChecked := False;
  FOnText := 'Ativado';
  FOffText := 'Desativado';
  FShowStateText := False;
  Font.Name := 'Inter';
  Font.Size := 9;
  Width := 92;
  Height := MaxScale(28, CurrentPPI);
end;

procedure TMaxToggleSwitch.DoChange;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TMaxToggleSwitch.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited;
  if Key = VK_SPACE then
  begin
    Checked := not Checked;
    Key := 0;
  end;
end;

procedure TMaxToggleSwitch.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  if (Button = mbLeft) and Enabled then
  begin
    if CanFocus then SetFocus;
    Checked := not Checked;
  end;
end;

procedure TMaxToggleSwitch.Paint;
var
  ToggleRect: TRect;
  TextRect: TRect;
  StateText: string;
  Save: Integer;
begin
  Canvas.Brush.Color := TMaxTheme.Palette.Background;
  Canvas.FillRect(ClientRect);
  ToggleRect := Rect(1, (Height - MaxScale(24, CurrentPPI)) div 2,
    MaxScale(46, CurrentPPI), (Height + MaxScale(24, CurrentPPI)) div 2);
  TMaxPainter.DrawToggle(Canvas, ToggleRect, FChecked, Enabled, Focused, CurrentPPI);
  if FShowStateText then
  begin
    if FChecked then StateText := FOnText else StateText := FOffText;
    TextRect := ClientRect;
    TextRect.Left := ToggleRect.Right + MaxScale(8, CurrentPPI);
    Save := SaveDC(Canvas.Handle);
    try
      Canvas.Font.Assign(Font);
      if Enabled then Canvas.Font.Color := TMaxTheme.Palette.Text
      else Canvas.Font.Color := TMaxTheme.Palette.TextDisabled;
      SetBkMode(Canvas.Handle, TRANSPARENT);
      DrawText(Canvas.Handle, PChar(StateText), Length(StateText), TextRect,
        DT_LEFT or DT_VCENTER or DT_SINGLELINE or DT_END_ELLIPSIS);
    finally
      RestoreDC(Canvas.Handle, Save);
    end;
  end;
end;

procedure TMaxToggleSwitch.SetChecked(const Value: Boolean);
begin
  if FChecked = Value then Exit;
  FChecked := Value;
  Invalidate;
  DoChange;
end;

procedure TMaxToggleSwitch.SetOffText(const Value: string);
begin
  if FOffText = Value then Exit;
  FOffText := Value;
  Invalidate;
end;

procedure TMaxToggleSwitch.SetOnText(const Value: string);
begin
  if FOnText = Value then Exit;
  FOnText := Value;
  Invalidate;
end;

procedure TMaxToggleSwitch.SetShowStateText(const Value: Boolean);
begin
  if FShowStateText = Value then Exit;
  FShowStateText := Value;
  Invalidate;
end;

constructor TMaxSlider.Create(AOwner: TComponent);
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
  FShowValue := True;
  FDragging := False;
  Font.Name := 'Inter';
  Font.Size := 9;
  Width := 220;
  Height := MaxScale(32, CurrentPPI);
end;

procedure TMaxSlider.DoChange;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TMaxSlider.KeyDown(var Key: Word; Shift: TShiftState);
var
  Step: Integer;
begin
  inherited;
  Step := 1;
  if ssShift in Shift then Step := 10;
  case Key of
    VK_LEFT, VK_DOWN: Position := Position - Step;
    VK_RIGHT, VK_UP: Position := Position + Step;
    VK_PRIOR: Position := Position + 10;
    VK_NEXT: Position := Position - 10;
    VK_HOME: Position := Minimum;
    VK_END: Position := Maximum;
  else
    Exit;
  end;
  Key := 0;
end;

procedure TMaxSlider.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  if (Button = mbLeft) and Enabled then
  begin
    if CanFocus then SetFocus;
    FDragging := True;
    MouseCapture := True;
    SetPositionFromX(X);
  end;
end;

procedure TMaxSlider.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if FDragging then
    SetPositionFromX(X);
end;

procedure TMaxSlider.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  if Button = mbLeft then
  begin
    FDragging := False;
    MouseCapture := False;
  end;
end;

procedure TMaxSlider.Paint;
var
  R: TRect;
  ValueRect: TRect;
  TextValue: string;
  Save: Integer;
begin
  Canvas.Brush.Color := TMaxTheme.Palette.Background;
  Canvas.FillRect(ClientRect);
  R := ClientRect;
  if FShowValue then
    Dec(R.Right, MaxScale(42, CurrentPPI));
  InflateRect(R, -MaxScale(8, CurrentPPI), 0);
  TMaxPainter.DrawSlider(Canvas, R, FPosition, FMinimum, FMaximum,
    Enabled, Focused, CurrentPPI);
  if FShowValue then
  begin
    TextValue := IntToStr(FPosition) + '%';
    ValueRect := ClientRect;
    ValueRect.Left := R.Right + MaxScale(8, CurrentPPI);
    Save := SaveDC(Canvas.Handle);
    try
      Canvas.Font.Assign(Font);
      Canvas.Font.Color := TMaxTheme.Palette.TextSecondary;
      SetBkMode(Canvas.Handle, TRANSPARENT);
      DrawText(Canvas.Handle, PChar(TextValue), Length(TextValue), ValueRect,
        DT_CENTER or DT_VCENTER or DT_SINGLELINE);
    finally
      RestoreDC(Canvas.Handle, Save);
    end;
  end;
end;

procedure TMaxSlider.SetMaximum(const Value: Integer);
begin
  if FMaximum = Value then Exit;
  FMaximum := Max(FMinimum + 1, Value);
  Position := FPosition;
  Invalidate;
end;

procedure TMaxSlider.SetMinimum(const Value: Integer);
begin
  if FMinimum = Value then Exit;
  FMinimum := Min(Value, FMaximum - 1);
  Position := FPosition;
  Invalidate;
end;

procedure TMaxSlider.SetPosition(const Value: Integer);
var
  NewValue: Integer;
begin
  NewValue := EnsureRange(Value, FMinimum, FMaximum);
  if FPosition = NewValue then Exit;
  FPosition := NewValue;
  Invalidate;
  DoChange;
end;

procedure TMaxSlider.SetPositionFromX(const X: Integer);
var
  LeftPadding: Integer;
  RightPadding: Integer;
  TrackWidth: Integer;
  ClampedX: Integer;
  NewValue: Integer;
begin
  LeftPadding := MaxScale(8, CurrentPPI);
  RightPadding := MaxScale(8, CurrentPPI);
  if FShowValue then Inc(RightPadding, MaxScale(42, CurrentPPI));
  TrackWidth := Max(1, Width - LeftPadding - RightPadding);
  ClampedX := EnsureRange(X - LeftPadding, 0, TrackWidth);
  NewValue := FMinimum + MulDiv(ClampedX, FMaximum - FMinimum, TrackWidth);
  Position := NewValue;
end;

procedure TMaxSlider.SetShowValue(const Value: Boolean);
begin
  if FShowValue = Value then Exit;
  FShowValue := Value;
  Invalidate;
end;

end.
