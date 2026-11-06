unit DAC.Components.Controls.ButtonEdit;

interface

uses
  System.Classes,
  System.Types,
  System.UITypes,
  Winapi.Messages,
  Vcl.Controls,
  DAC.Components.Controls.Button,
  DAC.Components.Controls.Edit,
  DAC.Components.DesignSystem.ControlTokens,
  DAC.Components.DesignSystem.IconAssets,
  DAC.Components.DesignSystem.Theme;

type
  { TDACEdit remains the single owner of the native TMaskEdit, input chrome,
    label/support rows, focus, hover, validation and designer preview. This
    descendant adds only the action box at the right-hand side. }
  TDACButtonEdit = class(TDACEdit)
  private
    FBindingCanModify: Boolean;
    FButton: TDACButton;
    FButtonCaption: string;
    FButtonWidth: Integer;
    FOnButtonClick: TNotifyEvent;
    procedure ActionClick(Sender: TObject);
    procedure ActionEnter(Sender: TObject);
    procedure ActionMouseEnter(Sender: TObject);
    procedure ActionMouseLeave(Sender: TObject);
    function CanModifyValue: Boolean;
    procedure CMEnabledChanged(var AMessage: TMessage); message CM_ENABLEDCHANGED;
    procedure CMParentColorChanged(var AMessage: TMessage); message CM_PARENTCOLORCHANGED;
    procedure CMParentFontChanged(var AMessage: TMessage); message CM_PARENTFONTCHANGED;
    procedure EditorKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    function GetButtonIconKind: TDACIconKind;
    function GetButtonKind: TDACButtonKind;
    function GetCornerRadiusValue: Integer;
    function GetLoadingValue: Boolean;
    function GetReadOnlyValue: Boolean;
    function GetShowButtonIcon: Boolean;
    function GetThemeModeValue: TDACThemeMode;
    procedure ResolveInputActionSurface(const ASender: TObject;
      out AColor: TAlphaColor);
    function ResolvedTokens: TDACControlTokens;
    procedure SetButtonCaption(const AValue: string);
    procedure SetButtonIconKind(const AValue: TDACIconKind);
    procedure SetButtonKind(const AValue: TDACButtonKind);
    procedure SetButtonWidth(const AValue: Integer);
    procedure SetCornerRadiusValue(const AValue: Integer);
    procedure SetLoadingValue(const AValue: Boolean);
    procedure SetReadOnlyValue(const AValue: Boolean);
    procedure SetShowButtonIcon(const AValue: Boolean);
    procedure SetThemeModeValue(const AValue: TDACThemeMode);
    procedure UpdateActionLayout;
    procedure UpdateActionState;
  protected
    procedure CreateWnd; override;
    procedure Loaded; override;
    procedure Resize; override;
    procedure SetBindingCanModify(const AValue: Boolean);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property ButtonControl: TDACButton read FButton;
  published
    property ButtonCaption: string read FButtonCaption write SetButtonCaption;
    property ButtonIconKind: TDACIconKind read GetButtonIconKind
      write SetButtonIconKind default mikSearch;
    property ButtonKind: TDACButtonKind read GetButtonKind write SetButtonKind
      default mbkInputAction;
    property ButtonWidth: Integer read FButtonWidth write SetButtonWidth
      default DACButtonEditDefaultButtonWidth;
    property CornerRadius: Integer read GetCornerRadiusValue
      write SetCornerRadiusValue default DACButtonEditDefaultCornerRadius;
    property Loading: Boolean read GetLoadingValue write SetLoadingValue
      default False;
    property ReadOnly: Boolean read GetReadOnlyValue write SetReadOnlyValue
      default False;
    property ShowButtonIcon: Boolean read GetShowButtonIcon
      write SetShowButtonIcon default True;
    property ThemeMode: TDACThemeMode read GetThemeModeValue
      write SetThemeModeValue default dtmInherit;
    property OnButtonClick: TNotifyEvent read FOnButtonClick write FOnButtonClick;
  end;

implementation

uses
  System.Math,
  System.SysUtils,
  Winapi.Windows,
  DAC.Components.DesignSystem.ComponentStyle;

constructor TDACButtonEdit.Create(AOwner: TComponent);
var
  LTokens: TDACControlTokens;
begin
  inherited Create(AOwner);
  FBindingCanModify := True;
  LTokens := ResolvedTokens;
  Width := Round(LTokens.ButtonEditDefaultWidth);
  Constraints.MinWidth := Round(LTokens.ButtonEditDefaultWidth);
  FButtonWidth := Round(LTokens.ButtonEditDefaultButtonWidth);

  FButton := TDACButton.Create(Self);
  FButton.Parent := Self;
  FButton.SetSubComponent(True);
  FButton.Caption := '';
  FButton.Kind := mbkInputAction;
  FButton.IconKind := mikSearch;
  FButton.ShowIcon := True;
  FButton.Size := mbsMedium;
  FButton.TabStop := False;
  FButton.Cursor := crHandPoint;
  FButton.CornerRadius := Round(LTokens.ButtonEditButtonCornerRadius);
  FButton.SetInputActionOuterCornerRadius(CornerRadius);
  FButton.SetInputActionSurfaceProvider(ResolveInputActionSurface);
  FButton.OnClick := ActionClick;
  FButton.OnEnter := ActionEnter;
  FButton.OnMouseEnter := ActionMouseEnter;
  FButton.OnMouseLeave := ActionMouseLeave;

  { The composite field is a single dialog tab stop. TDACEdit transfers focus
    to this native editor, retaining caret, IME and accessibility. }
  EditControl.TabStop := False;
  EditControl.OnKeyDown := EditorKeyDown;
  UpdateActionState;
  UpdateActionLayout;
end;

destructor TDACButtonEdit.Destroy;
begin
  FreeAndNil(FButton);
  inherited;
end;

procedure TDACButtonEdit.ActionClick(Sender: TObject);
begin
  if not CanModifyValue then
    Exit;
  SetFocus;
  if Assigned(FOnButtonClick) then
    FOnButtonClick(Self);
end;

procedure TDACButtonEdit.ActionEnter(Sender: TObject);
begin
  SetFocus;
end;

procedure TDACButtonEdit.ActionMouseEnter(Sender: TObject);
begin
  SetCompositeMouseInside(True);
end;

procedure TDACButtonEdit.ActionMouseLeave(Sender: TObject);
var
  LPoint: TPoint;
begin
  if GetCursorPos(LPoint) then
  begin
    LPoint := ScreenToClient(LPoint);
    if PtInRect(Rect(0, 0, Width, Height), LPoint) then
      Exit;
  end;
  SetCompositeMouseInside(False);
end;

function TDACButtonEdit.CanModifyValue: Boolean;
begin
  Result := Enabled and not Loading and not ReadOnly and FBindingCanModify;
end;

procedure TDACButtonEdit.CMEnabledChanged(var AMessage: TMessage);
begin
  inherited;
  UpdateActionState;
end;

procedure TDACButtonEdit.CMParentColorChanged(var AMessage: TMessage);
begin
  inherited;
  if FButton <> nil then
    FButton.ThemeMode := ThemeMode;
  UpdateActionLayout;
end;

procedure TDACButtonEdit.CMParentFontChanged(var AMessage: TMessage);
begin
  inherited;
  UpdateActionLayout;
end;

procedure TDACButtonEdit.CreateWnd;
begin
  inherited;
  UpdateActionState;
  UpdateActionLayout;
end;

procedure TDACButtonEdit.EditorKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  KeyDown(Key, Shift);
  if (Key = VK_F3) and (Shift = []) and Assigned(FOnButtonClick) and
    CanModifyValue then
  begin
    Key := 0;
    ActionClick(Sender);
  end;
end;

function TDACButtonEdit.GetButtonIconKind: TDACIconKind;
begin
  Result := FButton.IconKind;
end;

function TDACButtonEdit.GetButtonKind: TDACButtonKind;
begin
  Result := FButton.Kind;
end;

function TDACButtonEdit.GetCornerRadiusValue: Integer;
begin
  Result := TDACEdit(Self).CornerRadius;
end;

function TDACButtonEdit.GetLoadingValue: Boolean;
begin
  Result := TDACEdit(Self).Loading;
end;

function TDACButtonEdit.GetReadOnlyValue: Boolean;
begin
  Result := TDACEdit(Self).ReadOnly;
end;

function TDACButtonEdit.GetShowButtonIcon: Boolean;
begin
  Result := FButton.ShowIcon;
end;

function TDACButtonEdit.GetThemeModeValue: TDACThemeMode;
begin
  Result := TDACEdit(Self).ThemeMode;
end;

procedure TDACButtonEdit.Loaded;
begin
  inherited;
  if FButton <> nil then
  begin
    FButton.Caption := FButtonCaption;
    FButton.ThemeMode := ThemeMode;
  end;
  UpdateActionState;
  UpdateActionLayout;
end;

procedure TDACButtonEdit.ResolveInputActionSurface(
  const ASender: TObject; out AColor: TAlphaColor);
begin
  AColor := ResolvedInputSurfaceColor;
end;

function TDACButtonEdit.ResolvedTokens: TDACControlTokens;
begin
  Result := TDACComponentStyle.ResolveForSurface(Self,
    TDACEdit(Self).ThemeMode).Tokens.Controls;
end;

procedure TDACButtonEdit.Resize;
begin
  inherited;
  UpdateActionLayout;
end;

procedure TDACButtonEdit.SetBindingCanModify(const AValue: Boolean);
begin
  if FBindingCanModify = AValue then
    Exit;
  FBindingCanModify := AValue;
  inherited SetBindingCanModify(AValue);
  UpdateActionState;
end;

procedure TDACButtonEdit.SetButtonCaption(const AValue: string);
begin
  if FButtonCaption = AValue then
    Exit;
  FButtonCaption := AValue;
  if FButton <> nil then
    FButton.Caption := AValue;
end;

procedure TDACButtonEdit.SetButtonIconKind(const AValue: TDACIconKind);
begin
  if FButton <> nil then
    FButton.IconKind := AValue;
end;

procedure TDACButtonEdit.SetButtonKind(const AValue: TDACButtonKind);
begin
  if FButton <> nil then
    FButton.Kind := AValue;
end;

procedure TDACButtonEdit.SetButtonWidth(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(0, AValue);
  if FButtonWidth = LValue then
  begin
    UpdateActionLayout;
    Exit;
  end;
  FButtonWidth := LValue;
  UpdateActionLayout;
end;

procedure TDACButtonEdit.SetCornerRadiusValue(const AValue: Integer);
begin
  TDACEdit(Self).CornerRadius := AValue;
  if FButton <> nil then
    FButton.SetInputActionOuterCornerRadius(AValue);
  UpdateActionLayout;
end;

procedure TDACButtonEdit.SetLoadingValue(const AValue: Boolean);
begin
  TDACEdit(Self).Loading := AValue;
  UpdateActionState;
end;

procedure TDACButtonEdit.SetReadOnlyValue(const AValue: Boolean);
begin
  TDACEdit(Self).ReadOnly := AValue;
  UpdateActionState;
end;

procedure TDACButtonEdit.SetShowButtonIcon(const AValue: Boolean);
begin
  if FButton <> nil then
    FButton.ShowIcon := AValue;
end;

procedure TDACButtonEdit.SetThemeModeValue(const AValue: TDACThemeMode);
begin
  TDACEdit(Self).ThemeMode := AValue;
  if FButton <> nil then
    FButton.ThemeMode := AValue;
  UpdateActionLayout;
end;

procedure TDACButtonEdit.UpdateActionLayout;
var
  LButtonLeft: Integer;
  LButtonWidth: Integer;
  LChromeHeight: Integer;
  LChromeTop: Integer;
  LOuterInset: Integer;
  LRight: Integer;
  LTokens: TDACControlTokens;
begin
  if (FButton = nil) or (csLoading in ComponentState) or
    (csDestroying in ComponentState) then
    Exit;
  if not (csDesigning in ComponentState) and
    ((Parent = nil) or not HandleAllocated or not Parent.HandleAllocated) then
    Exit;

  LTokens := ResolvedTokens;
  LOuterInset := Ceil(Max(Max(LTokens.InputBorderWidth,
    LTokens.InputFocusBorderWidth), LTokens.ButtonEditButtonInset));
  LChromeTop := InputChromeTop;
  LChromeHeight := Min(InputChromeHeight, Max(0, Height - LChromeTop));
  LRight := Max(LOuterInset, Width - LOuterInset);
  LButtonWidth := Min(FButtonWidth, Max(0, LRight - LOuterInset));
  LButtonLeft := Max(LOuterInset, LRight - LButtonWidth);

  RightContentReserve := Max(0, Width - LButtonLeft);
  FButton.SetBounds(LButtonLeft, LChromeTop + LOuterInset,
    LButtonWidth, Max(0, LChromeHeight - (LOuterInset * 2)));
  FButton.SetInputActionOuterCornerRadius(CornerRadius);
  if csDesigning in ComponentState then
  begin
    FButton.Invalidate;
    Invalidate;
    Exit;
  end;
  FButton.BringToFront;
  FButton.Redraw;
end;

procedure TDACButtonEdit.UpdateActionState;
begin
  if FButton = nil then
    Exit;
  FButton.Loading := Loading;
  FButton.Enabled := CanModifyValue;
end;

end.
