unit DAC.Components.Controls.ButtonEdit;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Types,
  System.UITypes,
  Winapi.Messages,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.Mask,
  Vcl.StdCtrls,
  DAC.Components.Controls.Button,
  DAC.Components.Controls.Edit,
  DAC.Components.Controls.FieldSupport,
  DAC.Components.DesignSystem.ComponentStyle,
  DAC.Components.DesignSystem.ControlTokens,
  DAC.Components.DesignSystem.Theme,
  DAC.Components.DesignSystem.IconAssets;

type
  TDACButtonEdit = class(TCustomControl)
  private
    FButton: TDACButton;
    FBindingCanModify: Boolean;
    FButtonCaption: string;
    FButtonWidth: Integer;
    FEdit: TDACEdit;
    FLoading: Boolean;
    FLoadingTabStopCaptured: Boolean;
    FOnButtonClick: TNotifyEvent;
    FOnChange: TNotifyEvent;
    FThemeMode: TDACThemeMode;
    FTabStopBeforeLoading: Boolean;
    function ChromeTop: Integer;
    function GetButtonIconKind: TDACIconKind;
    function GetButtonKind: TDACButtonKind;
    function GetCharCase: TEditCharCase;
    function GetCornerRadius: Integer;
    function GetCounterText: string;
    function GetEditControl: TMaskEdit;
    function GetEditKind: TDACEditKind;
    function GetEditMask: string;
    function GetErrorText: string;
    function GetHelperText: string;
    function GetInputSize: TDACInputSize;
    function GetLabelText: string;
    function GetLoading: Boolean;
    function GetNativeLabel: TLabel;
    function GetMaxLength: Integer;
    function GetPasswordChar: Char;
    function GetPlaceholder: string;
    function GetReadOnly: Boolean;
    function GetRequired: Boolean;
    function GetShowButtonIcon: Boolean;
    function GetStatus: TDACEditStatus;
    function GetText: string;
    function GetThemeMode: TDACThemeMode;
    function GetVariant: TDACInputVariant;
    function ResolvedTokens: TDACControlTokens;
    procedure ResolveInputActionSurface(const ASender: TObject;
      out AColor: TAlphaColor);
    procedure ButtonClick(Sender: TObject);
    procedure CMEnabledChanged(var AMessage: TMessage); message CM_ENABLEDCHANGED;
    procedure DoEditChange(Sender: TObject);
    procedure DoEditEnter(Sender: TObject);
    procedure DoEditExit(Sender: TObject);
    procedure SetButtonCaption(const AValue: string);
    procedure SetButtonIconKind(const AValue: TDACIconKind);
    procedure SetButtonKind(const AValue: TDACButtonKind);
    procedure SetButtonWidth(const AValue: Integer);
    procedure SetCharCase(const AValue: TEditCharCase);
    procedure SetCornerRadius(const AValue: Integer);
    procedure SetCounterText(const AValue: string);
    procedure SetEditKind(const AValue: TDACEditKind);
    procedure SetEditMask(const AValue: string);
    procedure SetErrorText(const AValue: string);
    procedure SetHelperText(const AValue: string);
    procedure SetInputSize(const AValue: TDACInputSize);
    procedure SetLabelText(const AValue: string);
    procedure SetLoading(const AValue: Boolean);
    procedure SetMaxLength(const AValue: Integer);
    procedure SetPasswordChar(const AValue: Char);
    procedure SetPlaceholder(const AValue: string);
    procedure SetReadOnly(const AValue: Boolean);
    procedure SetRequired(const AValue: Boolean);
    procedure SetShowButtonIcon(const AValue: Boolean);
    procedure SetStatus(const AValue: TDACEditStatus);
    procedure SetText(const AValue: string);
    procedure SetThemeMode(const AValue: TDACThemeMode);
    procedure SetVariant(const AValue: TDACInputVariant);
    procedure InvalidateParentRegion(const ABounds: TRect);
    procedure UpdateChildBounds;
    procedure WMEraseBkgnd(var AMessage: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMSetFocus(var AMessage: TWMSetFocus); message WM_SETFOCUS;
  protected
    procedure CreateWnd; override;
    procedure Loaded; override;
    procedure Resize; override;
    procedure SetBindingCanModify(const AValue: Boolean);
  public
    constructor Create(AOwner: TComponent); override;
    procedure SetFocus; reintroduce;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
    property ButtonControl: TDACButton read FButton;
    property EditControl: TMaskEdit read GetEditControl;
    // Exposes the native caption hosted by the embedded edit so callers can
    // preserve the same focus and accessibility contract as TDACEdit.
    property NativeLabel: TLabel read GetNativeLabel;
  published
    property Align;
    property Anchors;
    property ButtonCaption: string read FButtonCaption write SetButtonCaption;
    property ButtonIconKind: TDACIconKind read GetButtonIconKind write SetButtonIconKind default mikSearch;
    property ButtonKind: TDACButtonKind read GetButtonKind write SetButtonKind default mbkInputAction;
    property ButtonWidth: Integer read FButtonWidth write SetButtonWidth
      default DACButtonEditDefaultButtonWidth;
    property CharCase: TEditCharCase read GetCharCase write SetCharCase default ecNormal;
    property Constraints;
    property CornerRadius: Integer read GetCornerRadius write SetCornerRadius
      default DACButtonEditDefaultCornerRadius;
    property CounterText: string read GetCounterText write SetCounterText;
    property EditKind: TDACEditKind read GetEditKind write SetEditKind default mekText;
    property EditMask: string read GetEditMask write SetEditMask;
    property Enabled;
    property ErrorText: string read GetErrorText write SetErrorText;
    property Font;
    property HelperText: string read GetHelperText write SetHelperText;
    property InputSize: TDACInputSize read GetInputSize write SetInputSize default misSmall;
    property LabelText: string read GetLabelText write SetLabelText;
    property Loading: Boolean read GetLoading write SetLoading default False;
    property MaxLength: Integer read GetMaxLength write SetMaxLength default 0;
    property ParentFont;
    property ParentShowHint;
    property PasswordChar: Char read GetPasswordChar write SetPasswordChar default #0;
    property Placeholder: string read GetPlaceholder write SetPlaceholder;
    property PopupMenu;
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly default False;
    property Required: Boolean read GetRequired write SetRequired default False;
    property ShowButtonIcon: Boolean read GetShowButtonIcon write SetShowButtonIcon default True;
    property ShowHint;
    property Status: TDACEditStatus read GetStatus write SetStatus default mesNormal;
    property TabOrder;
    property TabStop default True;
    property Text: string read GetText write SetText;
    property ThemeMode: TDACThemeMode read GetThemeMode write SetThemeMode default dtmInherit;
    property Variant: TDACInputVariant read GetVariant write SetVariant default mivOutlined;
    property Visible;
    property OnButtonClick: TNotifyEvent read FOnButtonClick write FOnButtonClick;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnClick;
    property OnDblClick;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
  end;

implementation

uses
  System.Math,
  Winapi.Windows;

constructor TDACButtonEdit.Create(AOwner: TComponent);
var
  LTokens: TDACControlTokens;
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csAcceptsControls, csClickEvents];
  FThemeMode := dtmInherit;
  FBindingCanModify := True;
  LTokens := ResolvedTokens;
  Width := Round(LTokens.ButtonEditDefaultWidth);
  Height := Round(LTokens.ButtonEditDefaultHeight);
  TabStop := True;
  ParentColor := False;
  StyleElements := [];

  FButtonWidth := Round(LTokens.ButtonEditDefaultButtonWidth);

  FEdit := TDACEdit.Create(Self);
  FEdit.Parent := Self;
  FEdit.SetSubComponent(True);
  // The composite is one form field. Its editor remains mouse-focusable, but
  // nested children must not create extra stops before the next form field.
  FEdit.TabStop := False;
  FEdit.CornerRadius := Round(LTokens.ButtonEditDefaultCornerRadius);
  FEdit.OnChange := DoEditChange;
  FEdit.OnEnter := DoEditEnter;
  FEdit.OnExit := DoEditExit;

  FButton := TDACButton.Create(Self);
  FButton.Parent := Self;
  FButton.SetSubComponent(True);
  FButton.Cursor := crHandPoint;
  FButton.Caption := '';
  FButton.CornerRadius := Round(LTokens.ButtonEditButtonCornerRadius);
  FButton.SetInputActionOuterCornerRadius(FEdit.CornerRadius);
  FButton.IconKind := mikSearch;
  FButton.Kind := mbkInputAction;
  FButton.SetInputActionSurfaceProvider(ResolveInputActionSurface);
  FButton.ShowIcon := True;
  FButton.Size := mbsMedium;
  FButton.TabStop := False;
  FButton.OnClick := ButtonClick;

  UpdateChildBounds;
end;

procedure TDACButtonEdit.ButtonClick(Sender: TObject);
begin
  if Assigned(FOnButtonClick) then
    FOnButtonClick(Self);
end;

function TDACButtonEdit.ChromeTop: Integer;
begin
  if FEdit <> nil then
    Result := FEdit.InputChromeTop
  else
    Result := 0;
end;

procedure TDACButtonEdit.CMEnabledChanged(var AMessage: TMessage);
begin
  inherited;
  FEdit.Enabled := Enabled;
  FButton.Enabled := Enabled and not FEdit.ReadOnly and not FEdit.Loading;
  if not Enabled then
    DACFieldRelinquishFocus(Self, EditControl);
end;

procedure TDACButtonEdit.CreateWnd;
begin
  inherited;
  UpdateChildBounds;
end;

procedure TDACButtonEdit.DoEditChange(Sender: TObject);
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TDACButtonEdit.DoEditEnter(Sender: TObject);
begin
  if Assigned(OnEnter) then
    OnEnter(Self);
end;

procedure TDACButtonEdit.DoEditExit(Sender: TObject);
begin
  if Assigned(OnExit) then
    OnExit(Self);
end;

procedure TDACButtonEdit.InvalidateParentRegion(const ABounds: TRect);
var
  LBounds: TRect;
begin
  if (Parent = nil) or not Parent.HandleAllocated or
    (csLoading in ComponentState) or (csDestroying in ComponentState) then
    Exit;
  LBounds := ABounds;
  InflateRect(LBounds, 1, 1);
  Winapi.Windows.InvalidateRect(Parent.Handle, @LBounds, True);
end;

function TDACButtonEdit.GetCharCase: TEditCharCase;
begin
  Result := FEdit.CharCase;
end;

function TDACButtonEdit.GetButtonIconKind: TDACIconKind;
begin
  Result := FButton.IconKind;
end;

function TDACButtonEdit.GetButtonKind: TDACButtonKind;
begin
  Result := FButton.Kind;
end;

function TDACButtonEdit.GetCornerRadius: Integer;
begin
  Result := FEdit.CornerRadius;
end;

function TDACButtonEdit.GetCounterText: string;
begin
  Result := FEdit.CounterText;
end;

function TDACButtonEdit.GetEditControl: TMaskEdit;
begin
  Result := nil;
  if FEdit <> nil then
    Result := FEdit.EditControl;
end;

function TDACButtonEdit.GetEditKind: TDACEditKind;
begin
  Result := FEdit.EditKind;
end;

function TDACButtonEdit.GetEditMask: string;
begin
  Result := FEdit.EditMask;
end;

function TDACButtonEdit.GetErrorText: string;
begin
  Result := FEdit.ErrorText;
end;

function TDACButtonEdit.GetHelperText: string;
begin
  Result := FEdit.HelperText;
end;

function TDACButtonEdit.GetInputSize: TDACInputSize;
begin
  Result := FEdit.InputSize;
end;

function TDACButtonEdit.GetLabelText: string;
begin
  Result := FEdit.LabelText;
end;

function TDACButtonEdit.GetLoading: Boolean;
begin
  Result := FLoading;
end;

function TDACButtonEdit.GetNativeLabel: TLabel;
begin
  Result := nil;
  if FEdit <> nil then
    Result := FEdit.NativeLabel;
end;

function TDACButtonEdit.GetMaxLength: Integer;
begin
  Result := FEdit.MaxLength;
end;

function TDACButtonEdit.GetPasswordChar: Char;
begin
  Result := FEdit.PasswordChar;
end;

function TDACButtonEdit.GetPlaceholder: string;
begin
  Result := FEdit.Placeholder;
end;

function TDACButtonEdit.GetReadOnly: Boolean;
begin
  Result := FEdit.ReadOnly;
end;

function TDACButtonEdit.GetRequired: Boolean;
begin
  Result := FEdit.Required;
end;

function TDACButtonEdit.GetShowButtonIcon: Boolean;
begin
  Result := FButton.ShowIcon;
end;

function TDACButtonEdit.GetStatus: TDACEditStatus;
begin
  Result := FEdit.Status;
end;

function TDACButtonEdit.GetText: string;
begin
  Result := FEdit.Text;
end;

function TDACButtonEdit.GetThemeMode: TDACThemeMode;
begin
  Result := FThemeMode;
end;

function TDACButtonEdit.GetVariant: TDACInputVariant;
begin
  Result := FEdit.Variant;
end;

function TDACButtonEdit.ResolvedTokens: TDACControlTokens;
begin
  Result := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls;
end;

procedure TDACButtonEdit.ResolveInputActionSurface(const ASender: TObject;
  out AColor: TAlphaColor);
begin
  if FEdit <> nil then
    AColor := FEdit.ResolvedInputSurfaceColor;
end;

procedure TDACButtonEdit.Loaded;
begin
  inherited;
  if FLoading then
  begin
    DACFieldBeginLoadingTabPolicy(Self, FTabStopBeforeLoading,
      FLoadingTabStopCaptured, True);
    DACFieldRelinquishFocus(Self, EditControl);
  end;
  UpdateChildBounds;
end;

procedure TDACButtonEdit.Resize;
begin
  inherited;
  UpdateChildBounds;
end;

procedure TDACButtonEdit.SetButtonCaption(const AValue: string);
begin
  if FButtonCaption = AValue then
    Exit;
  FButtonCaption := AValue;
  FButton.Caption := FButtonCaption;
  FButton.ShowIcon := (FButtonCaption = '') or FButton.ShowIcon;
  UpdateChildBounds;
end;

procedure TDACButtonEdit.SetButtonIconKind(const AValue: TDACIconKind);
begin
  FButton.IconKind := AValue;
end;

procedure TDACButtonEdit.SetButtonKind(const AValue: TDACButtonKind);
begin
  FButton.Kind := AValue;
end;

procedure TDACButtonEdit.SetButtonWidth(const AValue: Integer);
begin
  if FButtonWidth = AValue then
    Exit;
  FButtonWidth := Max(Round(ResolvedTokens.ButtonEditDefaultButtonWidth), AValue);
  UpdateChildBounds;
end;

procedure TDACButtonEdit.SetCharCase(const AValue: TEditCharCase);
begin
  FEdit.CharCase := AValue;
end;

procedure TDACButtonEdit.SetCornerRadius(const AValue: Integer);
begin
  FEdit.CornerRadius := AValue;
  FButton.SetInputActionOuterCornerRadius(FEdit.CornerRadius);
end;

procedure TDACButtonEdit.SetCounterText(const AValue: string);
begin
  FEdit.CounterText := AValue;
  UpdateChildBounds;
end;

procedure TDACButtonEdit.SetEditKind(const AValue: TDACEditKind);
begin
  FEdit.EditKind := AValue;
end;

procedure TDACButtonEdit.SetEditMask(const AValue: string);
begin
  FEdit.EditMask := AValue;
end;

procedure TDACButtonEdit.SetErrorText(const AValue: string);
begin
  FEdit.ErrorText := AValue;
  UpdateChildBounds;
end;

procedure TDACButtonEdit.SetHelperText(const AValue: string);
begin
  FEdit.HelperText := AValue;
  UpdateChildBounds;
end;

procedure TDACButtonEdit.SetInputSize(const AValue: TDACInputSize);
begin
  FEdit.InputSize := AValue;
  UpdateChildBounds;
end;

procedure TDACButtonEdit.SetFocus;
begin
  if FLoading or not Enabled then
    Exit;
  if (FEdit <> nil) and (EditControl <> nil) and EditControl.CanFocus then
    FEdit.SetFocus;
end;

procedure TDACButtonEdit.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
var
  LCanLayout: Boolean;
  LChanged: Boolean;
  LPreviousBounds: TRect;
begin
  LPreviousBounds := BoundsRect;
  LChanged := (LPreviousBounds.Left <> ALeft) or (LPreviousBounds.Top <> ATop) or
    (LPreviousBounds.Width <> AWidth) or (LPreviousBounds.Height <> AHeight);
  LCanLayout := not (csLoading in ComponentState) and
    not (csDestroying in ComponentState) and not (csDesigning in ComponentState) and
    (Parent <> nil) and HandleAllocated and Parent.HandleAllocated;
  if LChanged and LCanLayout then
  begin
    Perform(WM_SETREDRAW, 0, 0);
    SetWindowPos(Handle, 0, ALeft, ATop, AWidth, AHeight,
      SWP_NOZORDER or SWP_NOACTIVATE or SWP_NOCOPYBITS or SWP_NOREDRAW);
  end;
  try
    inherited;
  finally
    if LChanged and LCanLayout then
      Perform(WM_SETREDRAW, 1, 0);
  end;
  if LChanged and LCanLayout then
  begin
    InvalidateParentRegion(LPreviousBounds);
    InvalidateParentRegion(BoundsRect);
    if FEdit <> nil then
      FEdit.Redraw;
    if FButton <> nil then
      FButton.Redraw;
    if HandleAllocated then
      RedrawWindow(Handle, nil, 0,
        RDW_INVALIDATE or RDW_ERASE or RDW_FRAME or RDW_ALLCHILDREN or RDW_UPDATENOW);
  end;
end;

procedure TDACButtonEdit.WMSetFocus(var AMessage: TWMSetFocus);
begin
  inherited;
  if FLoading or not Enabled then
  begin
    DACFieldRelinquishFocus(Self, EditControl);
    Exit;
  end;
  // VCL dialog navigation focuses the composite HWND. Hand the focus to the
  // native edit immediately so Tab and mouse entry expose one clear caret.
  if (FEdit <> nil) and FEdit.CanFocus then
    FEdit.SetFocus;
end;

procedure TDACButtonEdit.SetLabelText(const AValue: string);
begin
  FEdit.LabelText := AValue;
  if (AValue.Trim <> '') and
    (Height <= Round(ResolvedTokens.ButtonEditDefaultHeight)) then
    Height := Round(ResolvedTokens.ButtonEditLabeledMinimumHeight);
  UpdateChildBounds;
end;

procedure TDACButtonEdit.SetMaxLength(const AValue: Integer);
begin
  FEdit.MaxLength := AValue;
end;

procedure TDACButtonEdit.SetLoading(const AValue: Boolean);
begin
  if FLoading = AValue then
    Exit;
  FLoading := AValue;
  if FLoading then
  begin
    DACFieldBeginLoadingTabPolicy(Self, FTabStopBeforeLoading,
      FLoadingTabStopCaptured);
    DACFieldRelinquishFocus(Self, EditControl);
  end;
  FEdit.Loading := AValue;
  if not FLoading then
    DACFieldEndLoadingTabPolicy(Self, FTabStopBeforeLoading,
      FLoadingTabStopCaptured);
  FButton.Enabled := Enabled and not FEdit.ReadOnly and not AValue;
  UpdateChildBounds;
end;

procedure TDACButtonEdit.SetPasswordChar(const AValue: Char);
begin
  FEdit.PasswordChar := AValue;
end;

procedure TDACButtonEdit.SetPlaceholder(const AValue: string);
begin
  FEdit.Placeholder := AValue;
end;

procedure TDACButtonEdit.SetReadOnly(const AValue: Boolean);
begin
  FEdit.ReadOnly := AValue;
  FEdit.EditControl.ReadOnly := AValue or not FBindingCanModify;
  FButton.Enabled := Enabled and not AValue and not FEdit.Loading;
end;

procedure TDACButtonEdit.SetBindingCanModify(const AValue: Boolean);
begin
  if FBindingCanModify = AValue then
    Exit;
  FBindingCanModify := AValue;
  if FEdit <> nil then
    FEdit.EditControl.ReadOnly := FEdit.ReadOnly or not FBindingCanModify;
end;

procedure TDACButtonEdit.SetRequired(const AValue: Boolean);
begin
  FEdit.Required := AValue;
end;

procedure TDACButtonEdit.SetShowButtonIcon(const AValue: Boolean);
begin
  FButton.ShowIcon := AValue;
end;

procedure TDACButtonEdit.SetStatus(const AValue: TDACEditStatus);
begin
  FEdit.Status := AValue;
end;

procedure TDACButtonEdit.SetText(const AValue: string);
begin
  FEdit.Text := AValue;
end;

procedure TDACButtonEdit.SetThemeMode(const AValue: TDACThemeMode);
begin
  if FThemeMode = AValue then
    Exit;
  FThemeMode := AValue;
  FEdit.ThemeMode := AValue;
  FButton.ThemeMode := AValue;
  Invalidate;
end;

procedure TDACButtonEdit.SetVariant(const AValue: TDACInputVariant);
begin
  FEdit.Variant := AValue;
  UpdateChildBounds;
end;

procedure TDACButtonEdit.UpdateChildBounds;
var
  LAvailableControlHeight: Integer;
  LButtonLeft: Integer;
  LButtonTop: Integer;
  LButtonWidth: Integer;
  LChromeTop: Integer;
  LContentReserve: Integer;
  LControlHeight: Integer;
  LOuterInset: Integer;
  LRight: Integer;
  LTokens: TDACControlTokens;
begin
  if (FEdit = nil) or (FButton = nil) or (csLoading in ComponentState) or
    (csDestroying in ComponentState) or (csDesigning in ComponentState) or
    (Parent = nil) or not HandleAllocated or not Parent.HandleAllocated then
    Exit;

  LTokens := ResolvedTokens;
  LOuterInset := Ceil(Max(Max(LTokens.InputBorderWidth,
    LTokens.InputFocusBorderWidth), LTokens.ButtonEditButtonInset));
  LChromeTop := ChromeTop;
  LAvailableControlHeight := Max(0, Height - LChromeTop);
  LControlHeight := FEdit.InputChromeHeight;
  LControlHeight := Min(LAvailableControlHeight, LControlHeight);
  LButtonTop := LChromeTop;
  LRight := Max(LOuterInset, Width - LOuterInset);
  LButtonWidth := Min(FButtonWidth, Max(0, LRight - LOuterInset));
  LButtonLeft := Max(LOuterInset, LRight - LButtonWidth);
  // The embedded TDACEdit keeps the full composite width so its Skia chrome
  // remains continuous. Reserve only the native text HWND up to the future
  // action column before either child moves, avoiding one frame of text under
  // the transparent button. TDACEdit's own right padding is the visual gap.
  LContentReserve := Max(0, Width - LButtonLeft);
  FEdit.RightContentReserve := LContentReserve;

  FEdit.SetBounds(0, 0, Width, Height);
  FButton.SetBounds(LButtonLeft,
    LButtonTop + LOuterInset, LButtonWidth,
    Max(0, LControlHeight - (LOuterInset * 2)));
  FEdit.RightContentReserve := Max(0, Width - FButton.Left);
  FButton.SetInputActionOuterCornerRadius(FEdit.CornerRadius);
  FButton.BringToFront;
  FButton.Redraw;
end;

procedure TDACButtonEdit.WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
begin
  inherited;
end;

end.

