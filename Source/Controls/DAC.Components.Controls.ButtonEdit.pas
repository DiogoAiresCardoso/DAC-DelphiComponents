unit DAC.Components.Controls.ButtonEdit;

interface

uses
  System.Classes,
  System.SysUtils,
  Winapi.Messages,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.Mask,
  Vcl.StdCtrls,
  DAC.Components.Controls.Button,
  DAC.Components.Controls.Edit,
  DAC.Components.DesignSystem.IconAssets;

type
  TDACButtonEdit = class(TCustomControl)
  private
    FButton: TDACButton;
    FButtonCaption: string;
    FButtonWidth: Integer;
    FEdit: TDACEdit;
    FOnButtonClick: TNotifyEvent;
    FOnChange: TNotifyEvent;
    function ChromeTop: Integer;
    function GetButtonIconKind: TDACIconKind;
    function GetButtonKind: TDACButtonKind;
    function GetCharCase: TEditCharCase;
    function GetCornerRadius: Integer;
    function GetCounterText: string;
    function GetEditControl: TMaskEdit;
    function GetEditKind: TDACEditKind;
    function GetEditMask: string;
    function GetHelperText: string;
    function GetInputSize: TDACInputSize;
    function GetLabelText: string;
    function GetMaxLength: Integer;
    function GetPasswordChar: Char;
    function GetPlaceholder: string;
    function GetReadOnly: Boolean;
    function GetRequired: Boolean;
    function GetShowButtonIcon: Boolean;
    function GetStatus: TDACEditStatus;
    function GetText: string;
    function GetVariant: TDACInputVariant;
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
    procedure SetHelperText(const AValue: string);
    procedure SetInputSize(const AValue: TDACInputSize);
    procedure SetLabelText(const AValue: string);
    procedure SetMaxLength(const AValue: Integer);
    procedure SetPasswordChar(const AValue: Char);
    procedure SetPlaceholder(const AValue: string);
    procedure SetReadOnly(const AValue: Boolean);
    procedure SetRequired(const AValue: Boolean);
    procedure SetShowButtonIcon(const AValue: Boolean);
    procedure SetStatus(const AValue: TDACEditStatus);
    procedure SetText(const AValue: string);
    procedure SetVariant(const AValue: TDACInputVariant);
    procedure UpdateChildBounds;
    procedure WMEraseBkgnd(var AMessage: TWMEraseBkgnd); message WM_ERASEBKGND;
  protected
    procedure ChangeScale(M, D: Integer); override;
    procedure CreateWnd; override;
    procedure Loaded; override;
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure SetFocus; reintroduce;
    property ButtonControl: TDACButton read FButton;
    property EditControl: TMaskEdit read GetEditControl;
  published
    property Align;
    property Anchors;
    property ButtonCaption: string read FButtonCaption write SetButtonCaption;
    property ButtonIconKind: TDACIconKind read GetButtonIconKind write SetButtonIconKind default mikSearch;
    property ButtonKind: TDACButtonKind read GetButtonKind write SetButtonKind default mbkInputAction;
    property ButtonWidth: Integer read FButtonWidth write SetButtonWidth default 48;
    property CharCase: TEditCharCase read GetCharCase write SetCharCase default ecNormal;
    property Constraints;
    property CornerRadius: Integer read GetCornerRadius write SetCornerRadius default 8;
    property CounterText: string read GetCounterText write SetCounterText;
    property EditKind: TDACEditKind read GetEditKind write SetEditKind default mekText;
    property EditMask: string read GetEditMask write SetEditMask;
    property Enabled;
    property Font;
    property HelperText: string read GetHelperText write SetHelperText;
    property InputSize: TDACInputSize read GetInputSize write SetInputSize default misMedium;
    property LabelText: string read GetLabelText write SetLabelText;
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
  System.Math;

constructor TDACButtonEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csAcceptsControls, csClickEvents];
  Width := 300;
  Height := 38;
  TabStop := True;
  ParentColor := False;
  StyleElements := [];

  FButtonWidth := 48;

  FEdit := TDACEdit.Create(Self);
  FEdit.Parent := Self;
  FEdit.SetSubComponent(True);
  FEdit.TabStop := True;
  FEdit.OnChange := DoEditChange;
  FEdit.OnEnter := DoEditEnter;
  FEdit.OnExit := DoEditExit;

  FButton := TDACButton.Create(Self);
  FButton.Parent := Self;
  FButton.SetSubComponent(True);
  FButton.Cursor := crHandPoint;
  FButton.Caption := '';
  FButton.CornerRadius := 0;
  FButton.IconKind := mikSearch;
  FButton.Kind := mbkInputAction;
  FButton.ShowIcon := True;
  FButton.Size := mbsMedium;
  FButton.TabStop := True;
  FButton.OnClick := ButtonClick;

  UpdateChildBounds;
end;

procedure TDACButtonEdit.ButtonClick(Sender: TObject);
begin
  if Assigned(FOnButtonClick) then
    FOnButtonClick(Self);
end;

procedure TDACButtonEdit.ChangeScale(M, D: Integer);
begin
  inherited;
  UpdateChildBounds;
end;

function TDACButtonEdit.ChromeTop: Integer;
begin
  Result := 0;
  if GetLabelText.Trim <> '' then
    Result := 24;
end;

procedure TDACButtonEdit.CMEnabledChanged(var AMessage: TMessage);
begin
  inherited;
  FEdit.Enabled := Enabled;
  FButton.Enabled := Enabled and not FEdit.ReadOnly;
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

function TDACButtonEdit.GetVariant: TDACInputVariant;
begin
  Result := FEdit.Variant;
end;

procedure TDACButtonEdit.Loaded;
begin
  inherited;
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
  FButtonWidth := Max(34, AValue);
  UpdateChildBounds;
end;

procedure TDACButtonEdit.SetCharCase(const AValue: TEditCharCase);
begin
  FEdit.CharCase := AValue;
end;

procedure TDACButtonEdit.SetCornerRadius(const AValue: Integer);
begin
  FEdit.CornerRadius := AValue;
  FButton.CornerRadius := 0;
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
  if FEdit <> nil then
    FEdit.SetFocus
  else
    inherited;
end;

procedure TDACButtonEdit.SetLabelText(const AValue: string);
begin
  FEdit.LabelText := AValue;
  if (AValue.Trim <> '') and (Height <= 38) then
    Height := 60;
  UpdateChildBounds;
end;

procedure TDACButtonEdit.SetMaxLength(const AValue: Integer);
begin
  FEdit.MaxLength := AValue;
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
  FButton.Enabled := Enabled and not AValue;
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

procedure TDACButtonEdit.SetVariant(const AValue: TDACInputVariant);
begin
  FEdit.Variant := AValue;
  UpdateChildBounds;
end;

procedure TDACButtonEdit.UpdateChildBounds;
var
  LAvailableControlHeight: Integer;
  LButtonTop: Integer;
  LButtonWidth: Integer;
  LChromeTop: Integer;
  LControlHeight: Integer;
  LGap: Integer;
  LInset: Integer;
begin
  if (FEdit = nil) or (FButton = nil) then
    Exit;

  LGap := 0;
  LInset := 3;
  LChromeTop := ChromeTop;
  LAvailableControlHeight := Max(0, Height - LChromeTop);
  case GetInputSize of
    misSmall:
      LControlHeight := 32;
    misLarge:
      LControlHeight := 48;
  else
    LControlHeight := 40;
  end;
  if GetVariant = mivCompact then
    LControlHeight := 32;
  LControlHeight := Min(LAvailableControlHeight, LControlHeight);
  LButtonTop := LChromeTop;
  LButtonWidth := Max(0, FButtonWidth - LInset - 1);

  FEdit.SetBounds(0, 0, Width, Height);
  FButton.SetBounds(Max(LInset, Width - FButtonWidth - LGap),
    LButtonTop + LInset, LButtonWidth,
    Max(0, LControlHeight - (LInset * 2)));
  FButton.CornerRadius := 0;
  FButton.Redraw;
end;

procedure TDACButtonEdit.WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
begin
  AMessage.Result := 1;
end;

end.

