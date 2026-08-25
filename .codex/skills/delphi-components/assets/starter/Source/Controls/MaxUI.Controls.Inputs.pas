unit MaxUI.Controls.Inputs;

{$CODEPAGE 65001}

interface

uses
  System.Classes,
  Winapi.Messages,
  Vcl.Controls,
  Vcl.StdCtrls,
  Vcl.Mask,
  MaxUI.Types;

type
  TMaxEdit = class(TEdit)
  private
    FFieldState: TMaxFieldState;
    FCornerRadius: Integer;
    FLeadingIcon: TMaxIconKind;
    FTrailingIcon: TMaxIconKind;
    FErrorText: string;
    FOnTrailingIconClick: TNotifyEvent;
    procedure SetFieldState(const Value: TMaxFieldState);
    procedure SetCornerRadius(const Value: Integer);
    procedure SetLeadingIcon(const Value: TMaxIconKind);
    procedure SetTrailingIcon(const Value: TMaxIconKind);
    procedure SetPlaceholder(const Value: string);
    function GetPlaceholder: string;
    procedure UpdateMargins;
    procedure CMFontChanged(var Message: TMessage); message CM_FONTCHANGED;
    procedure WMSize(var Message: TWMSize); message WM_SIZE;
  protected
    procedure CreateWnd; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    function TrailingIconRect: TRect;
  published
    property FieldState: TMaxFieldState read FFieldState write SetFieldState default mfsNormal;
    property CornerRadius: Integer read FCornerRadius write SetCornerRadius default 8;
    property LeadingIcon: TMaxIconKind read FLeadingIcon write SetLeadingIcon default mikNone;
    property TrailingIcon: TMaxIconKind read FTrailingIcon write SetTrailingIcon default mikNone;
    property Placeholder: string read GetPlaceholder write SetPlaceholder;
    property ErrorText: string read FErrorText write FErrorText;
    property OnTrailingIconClick: TNotifyEvent read FOnTrailingIconClick write FOnTrailingIconClick;
  end;

  TMaxSearchEdit = class(TMaxEdit)
  private
    FOnSearch: TNotifyEvent;
  protected
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property OnSearch: TNotifyEvent read FOnSearch write FOnSearch;
  end;

  TMaxPasswordEdit = class(TMaxEdit)
  private
    FShowPassword: Boolean;
    procedure SetShowPassword(const Value: Boolean);
    procedure TogglePassword(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
  published
    property ShowPassword: Boolean read FShowPassword write SetShowPassword default False;
  end;

  TMaxMaskedEdit = class(TMaskEdit)
  private
    FFieldState: TMaxFieldState;
    FCornerRadius: Integer;
    FErrorText: string;
    procedure SetFieldState(const Value: TMaxFieldState);
    procedure SetCornerRadius(const Value: Integer);
    procedure SetPlaceholder(const Value: string);
    function GetPlaceholder: string;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property FieldState: TMaxFieldState read FFieldState write SetFieldState default mfsNormal;
    property CornerRadius: Integer read FCornerRadius write SetCornerRadius default 8;
    property Placeholder: string read GetPlaceholder write SetPlaceholder;
    property ErrorText: string read FErrorText write FErrorText;
  end;

  TMaxMemo = class(TMemo)
  private
    FFieldState: TMaxFieldState;
    FCornerRadius: Integer;
    FErrorText: string;
    procedure SetFieldState(const Value: TMaxFieldState);
    procedure SetCornerRadius(const Value: Integer);
    procedure SetPlaceholder(const Value: string);
    function GetPlaceholder: string;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property FieldState: TMaxFieldState read FFieldState write SetFieldState default mfsNormal;
    property CornerRadius: Integer read FCornerRadius write SetCornerRadius default 8;
    property Placeholder: string read GetPlaceholder write SetPlaceholder;
    property ErrorText: string read FErrorText write FErrorText;
  end;

implementation

uses
  System.Math,
  Winapi.Windows,
  MaxUI.Dpi,
  MaxUI.Theme;

constructor TMaxEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FFieldState := mfsNormal;
  FCornerRadius := TMaxTheme.Metrics.RadiusMedium;
  FLeadingIcon := mikNone;
  FTrailingIcon := mikNone;
  Color := TMaxTheme.Palette.Surface;
  Font.Name := 'Inter';
  Font.Size := 9;
  Font.Color := TMaxTheme.Palette.Text;
  StyleElements := [seFont];
  Height := MaxScale(TMaxTheme.Metrics.ControlHeightMedium, CurrentPPI);
  Width := 180;
end;

procedure TMaxEdit.CMFontChanged(var Message: TMessage);
begin
  inherited;
  UpdateMargins;
end;

procedure TMaxEdit.CreateWnd;
begin
  inherited;
  UpdateMargins;
end;

function TMaxEdit.GetPlaceholder: string;
begin
  Result := TextHint;
end;

procedure TMaxEdit.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  if (Button = mbLeft) and (FTrailingIcon <> mikNone) and
    PtInRect(TrailingIconRect, Point(X, Y)) and Assigned(FOnTrailingIconClick) then
  begin
    FOnTrailingIconClick(Self);
    Exit;
  end;
  inherited;
end;

procedure TMaxEdit.SetCornerRadius(const Value: Integer);
begin
  if FCornerRadius = Value then Exit;
  FCornerRadius := Max(0, Value);
  Invalidate;
end;

procedure TMaxEdit.SetFieldState(const Value: TMaxFieldState);
begin
  if FFieldState = Value then Exit;
  FFieldState := Value;
  Enabled := Value <> mfsDisabled;
  Invalidate;
end;

procedure TMaxEdit.SetLeadingIcon(const Value: TMaxIconKind);
begin
  if FLeadingIcon = Value then Exit;
  FLeadingIcon := Value;
  UpdateMargins;
  Invalidate;
end;

procedure TMaxEdit.SetPlaceholder(const Value: string);
begin
  TextHint := Value;
end;

procedure TMaxEdit.SetTrailingIcon(const Value: TMaxIconKind);
begin
  if FTrailingIcon = Value then Exit;
  FTrailingIcon := Value;
  UpdateMargins;
  Invalidate;
end;

function TMaxEdit.TrailingIconRect: TRect;
var
  IconSize: Integer;
  Padding: Integer;
begin
  IconSize := MaxScale(TMaxTheme.Metrics.IconSmall, CurrentPPI);
  Padding := MaxScale(10, CurrentPPI);
  Result := Rect(Width - Padding - IconSize, (Height - IconSize) div 2,
    Width - Padding, (Height - IconSize) div 2 + IconSize);
end;

procedure TMaxEdit.UpdateMargins;
var
  LeftMargin: Integer;
  RightMargin: Integer;
  IconSpace: Integer;
begin
  IconSpace := MaxScale(TMaxTheme.Metrics.IconSmall + 16, CurrentPPI);
  LeftMargin := MaxScale(10, CurrentPPI);
  RightMargin := MaxScale(10, CurrentPPI);
  if FLeadingIcon <> mikNone then
    Inc(LeftMargin, IconSpace);
  if FTrailingIcon <> mikNone then
    Inc(RightMargin, IconSpace);
  if HandleAllocated then
    SendMessage(Handle, EM_SETMARGINS, EC_LEFTMARGIN or EC_RIGHTMARGIN,
      MakeLParam(LeftMargin, RightMargin));
end;

procedure TMaxEdit.WMSize(var Message: TWMSize);
begin
  inherited;
  UpdateMargins;
end;

constructor TMaxSearchEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Placeholder := 'Pesquisar...';
  TrailingIcon := mikSearch;
end;

procedure TMaxSearchEdit.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited;
  if (Key = VK_RETURN) and Assigned(FOnSearch) then
  begin
    FOnSearch(Self);
    Key := 0;
  end;
end;

constructor TMaxPasswordEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FShowPassword := False;
  PasswordChar := '*';
  TrailingIcon := mikEye;
  OnTrailingIconClick := TogglePassword;
end;

procedure TMaxPasswordEdit.SetShowPassword(const Value: Boolean);
var
  StartPos: Integer;
  LengthValue: Integer;
begin
  if FShowPassword = Value then Exit;
  StartPos := SelStart;
  LengthValue := SelLength;
  FShowPassword := Value;
  if Value then
  begin
    PasswordChar := #0;
    TrailingIcon := mikEyeOff;
  end
  else
  begin
    PasswordChar := '*';
    TrailingIcon := mikEye;
  end;
  SelStart := StartPos;
  SelLength := LengthValue;
end;

procedure TMaxPasswordEdit.TogglePassword(Sender: TObject);
begin
  ShowPassword := not ShowPassword;
end;

constructor TMaxMaskedEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FFieldState := mfsNormal;
  FCornerRadius := TMaxTheme.Metrics.RadiusMedium;
  Color := TMaxTheme.Palette.Surface;
  Font.Name := 'Inter';
  Font.Size := 9;
  StyleElements := [seFont];
  Height := MaxScale(TMaxTheme.Metrics.ControlHeightMedium, CurrentPPI);
  Width := 180;
end;

function TMaxMaskedEdit.GetPlaceholder: string;
begin
  Result := TextHint;
end;

procedure TMaxMaskedEdit.SetCornerRadius(const Value: Integer);
begin
  if FCornerRadius = Value then Exit;
  FCornerRadius := Max(0, Value);
  Invalidate;
end;

procedure TMaxMaskedEdit.SetFieldState(const Value: TMaxFieldState);
begin
  if FFieldState = Value then Exit;
  FFieldState := Value;
  Enabled := Value <> mfsDisabled;
  Invalidate;
end;

procedure TMaxMaskedEdit.SetPlaceholder(const Value: string);
begin
  TextHint := Value;
end;

constructor TMaxMemo.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FFieldState := mfsNormal;
  FCornerRadius := TMaxTheme.Metrics.RadiusMedium;
  Color := TMaxTheme.Palette.Surface;
  Font.Name := 'Inter';
  Font.Size := 9;
  StyleElements := [seFont];
  ScrollBars := ssVertical;
  Width := 220;
  Height := 88;
end;

function TMaxMemo.GetPlaceholder: string;
begin
  Result := TextHint;
end;

procedure TMaxMemo.SetCornerRadius(const Value: Integer);
begin
  if FCornerRadius = Value then Exit;
  FCornerRadius := Max(0, Value);
  Invalidate;
end;

procedure TMaxMemo.SetFieldState(const Value: TMaxFieldState);
begin
  if FFieldState = Value then Exit;
  FFieldState := Value;
  Enabled := Value <> mfsDisabled;
  Invalidate;
end;

procedure TMaxMemo.SetPlaceholder(const Value: string);
begin
  TextHint := Value;
end;

end.
