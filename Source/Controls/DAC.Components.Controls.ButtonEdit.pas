unit MaxxRural.Components.Controls.ButtonEdit;

interface

uses
  System.Classes,
  System.SysUtils,
  Winapi.Messages,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.Mask,
  Vcl.StdCtrls,
  MaxxRural.Components.Controls.Button,
  MaxxRural.Components.Controls.Edit,
  MaxxRural.Components.DesignSystem.IconAssets;

type
  TMaxxRuralButtonEdit = class(TCustomControl)
  private
    FButton: TMaxxRuralButton;
    FButtonCaption: string;
    FButtonWidth: Integer;
    FEdit: TMaxxRuralEdit;
    FOnButtonClick: TNotifyEvent;
    FOnChange: TNotifyEvent;
    function ChromeTop: Integer;
    function GetButtonIconKind: TMaxxRuralIconKind;
    function GetButtonKind: TMaxxRuralButtonKind;
    function GetCharCase: TEditCharCase;
    function GetCornerRadius: Integer;
    function GetCounterText: string;
    function GetEditControl: TMaskEdit;
    function GetEditKind: TMaxxRuralEditKind;
    function GetEditMask: string;
    function GetHelperText: string;
    function GetInputSize: TMaxxRuralInputSize;
    function GetLabelText: string;
    function GetMaxLength: Integer;
    function GetPasswordChar: Char;
    function GetPlaceholder: string;
    function GetReadOnly: Boolean;
    function GetRequired: Boolean;
    function GetShowButtonIcon: Boolean;
    function GetStatus: TMaxxRuralEditStatus;
    function GetText: string;
    function GetVariant: TMaxxRuralInputVariant;
    procedure ButtonClick(Sender: TObject);
    procedure CMEnabledChanged(var AMessage: TMessage); message CM_ENABLEDCHANGED;
    procedure DoEditChange(Sender: TObject);
    procedure DoEditEnter(Sender: TObject);
    procedure DoEditExit(Sender: TObject);
    procedure SetButtonCaption(const AValue: string);
    procedure SetButtonIconKind(const AValue: TMaxxRuralIconKind);
    procedure SetButtonKind(const AValue: TMaxxRuralButtonKind);
    procedure SetButtonWidth(const AValue: Integer);
    procedure SetCharCase(const AValue: TEditCharCase);
    procedure SetCornerRadius(const AValue: Integer);
    procedure SetCounterText(const AValue: string);
    procedure SetEditKind(const AValue: TMaxxRuralEditKind);
    procedure SetEditMask(const AValue: string);
    procedure SetHelperText(const AValue: string);
    procedure SetInputSize(const AValue: TMaxxRuralInputSize);
    procedure SetLabelText(const AValue: string);
    procedure SetMaxLength(const AValue: Integer);
    procedure SetPasswordChar(const AValue: Char);
    procedure SetPlaceholder(const AValue: string);
    procedure SetReadOnly(const AValue: Boolean);
    procedure SetRequired(const AValue: Boolean);
    procedure SetShowButtonIcon(const AValue: Boolean);
    procedure SetStatus(const AValue: TMaxxRuralEditStatus);
    procedure SetText(const AValue: string);
    procedure SetVariant(const AValue: TMaxxRuralInputVariant);
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
    property ButtonControl: TMaxxRuralButton read FButton;
    property EditControl: TMaskEdit read GetEditControl;
  published
    property Align;
    property Anchors;
    property ButtonCaption: string read FButtonCaption write SetButtonCaption;
    property ButtonIconKind: TMaxxRuralIconKind read GetButtonIconKind write SetButtonIconKind default mikSearch;
    property ButtonKind: TMaxxRuralButtonKind read GetButtonKind write SetButtonKind default mbkInputAction;
    property ButtonWidth: Integer read FButtonWidth write SetButtonWidth default 48;
    property CharCase: TEditCharCase read GetCharCase write SetCharCase default ecNormal;
    property Constraints;
    property CornerRadius: Integer read GetCornerRadius write SetCornerRadius default 8;
    property CounterText: string read GetCounterText write SetCounterText;
    property EditKind: TMaxxRuralEditKind read GetEditKind write SetEditKind default mekText;
    property EditMask: string read GetEditMask write SetEditMask;
    property Enabled;
    property Font;
    property HelperText: string read GetHelperText write SetHelperText;
    property InputSize: TMaxxRuralInputSize read GetInputSize write SetInputSize default misMedium;
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
    property Status: TMaxxRuralEditStatus read GetStatus write SetStatus default mesNormal;
    property TabOrder;
    property TabStop default True;
    property Text: string read GetText write SetText;
    property Variant: TMaxxRuralInputVariant read GetVariant write SetVariant default mivOutlined;
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

constructor TMaxxRuralButtonEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csAcceptsControls, csClickEvents];
  Width := 300;
  Height := 38;
  TabStop := True;
  ParentColor := False;
  StyleElements := [];

  FButtonWidth := 48;

  FEdit := TMaxxRuralEdit.Create(Self);
  FEdit.Parent := Self;
  FEdit.SetSubComponent(True);
  FEdit.TabStop := True;
  FEdit.OnChange := DoEditChange;
  FEdit.OnEnter := DoEditEnter;
  FEdit.OnExit := DoEditExit;

  FButton := TMaxxRuralButton.Create(Self);
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

procedure TMaxxRuralButtonEdit.ButtonClick(Sender: TObject);
begin
  if Assigned(FOnButtonClick) then
    FOnButtonClick(Self);
end;

procedure TMaxxRuralButtonEdit.ChangeScale(M, D: Integer);
begin
  inherited;
  UpdateChildBounds;
end;

function TMaxxRuralButtonEdit.ChromeTop: Integer;
begin
  Result := 0;
  if GetLabelText.Trim <> '' then
    Result := 24;
end;

procedure TMaxxRuralButtonEdit.CMEnabledChanged(var AMessage: TMessage);
begin
  inherited;
  FEdit.Enabled := Enabled;
  FButton.Enabled := Enabled and not FEdit.ReadOnly;
end;

procedure TMaxxRuralButtonEdit.CreateWnd;
begin
  inherited;
  UpdateChildBounds;
end;

procedure TMaxxRuralButtonEdit.DoEditChange(Sender: TObject);
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TMaxxRuralButtonEdit.DoEditEnter(Sender: TObject);
begin
  if Assigned(OnEnter) then
    OnEnter(Self);
end;

procedure TMaxxRuralButtonEdit.DoEditExit(Sender: TObject);
begin
  if Assigned(OnExit) then
    OnExit(Self);
end;

function TMaxxRuralButtonEdit.GetCharCase: TEditCharCase;
begin
  Result := FEdit.CharCase;
end;

function TMaxxRuralButtonEdit.GetButtonIconKind: TMaxxRuralIconKind;
begin
  Result := FButton.IconKind;
end;

function TMaxxRuralButtonEdit.GetButtonKind: TMaxxRuralButtonKind;
begin
  Result := FButton.Kind;
end;

function TMaxxRuralButtonEdit.GetCornerRadius: Integer;
begin
  Result := FEdit.CornerRadius;
end;

function TMaxxRuralButtonEdit.GetCounterText: string;
begin
  Result := FEdit.CounterText;
end;

function TMaxxRuralButtonEdit.GetEditControl: TMaskEdit;
begin
  Result := nil;
  if FEdit <> nil then
    Result := FEdit.EditControl;
end;

function TMaxxRuralButtonEdit.GetEditKind: TMaxxRuralEditKind;
begin
  Result := FEdit.EditKind;
end;

function TMaxxRuralButtonEdit.GetEditMask: string;
begin
  Result := FEdit.EditMask;
end;

function TMaxxRuralButtonEdit.GetHelperText: string;
begin
  Result := FEdit.HelperText;
end;

function TMaxxRuralButtonEdit.GetInputSize: TMaxxRuralInputSize;
begin
  Result := FEdit.InputSize;
end;

function TMaxxRuralButtonEdit.GetLabelText: string;
begin
  Result := FEdit.LabelText;
end;

function TMaxxRuralButtonEdit.GetMaxLength: Integer;
begin
  Result := FEdit.MaxLength;
end;

function TMaxxRuralButtonEdit.GetPasswordChar: Char;
begin
  Result := FEdit.PasswordChar;
end;

function TMaxxRuralButtonEdit.GetPlaceholder: string;
begin
  Result := FEdit.Placeholder;
end;

function TMaxxRuralButtonEdit.GetReadOnly: Boolean;
begin
  Result := FEdit.ReadOnly;
end;

function TMaxxRuralButtonEdit.GetRequired: Boolean;
begin
  Result := FEdit.Required;
end;

function TMaxxRuralButtonEdit.GetShowButtonIcon: Boolean;
begin
  Result := FButton.ShowIcon;
end;

function TMaxxRuralButtonEdit.GetStatus: TMaxxRuralEditStatus;
begin
  Result := FEdit.Status;
end;

function TMaxxRuralButtonEdit.GetText: string;
begin
  Result := FEdit.Text;
end;

function TMaxxRuralButtonEdit.GetVariant: TMaxxRuralInputVariant;
begin
  Result := FEdit.Variant;
end;

procedure TMaxxRuralButtonEdit.Loaded;
begin
  inherited;
  UpdateChildBounds;
end;

procedure TMaxxRuralButtonEdit.Resize;
begin
  inherited;
  UpdateChildBounds;
end;

procedure TMaxxRuralButtonEdit.SetButtonCaption(const AValue: string);
begin
  if FButtonCaption = AValue then
    Exit;
  FButtonCaption := AValue;
  FButton.Caption := FButtonCaption;
  FButton.ShowIcon := (FButtonCaption = '') or FButton.ShowIcon;
  UpdateChildBounds;
end;

procedure TMaxxRuralButtonEdit.SetButtonIconKind(const AValue: TMaxxRuralIconKind);
begin
  FButton.IconKind := AValue;
end;

procedure TMaxxRuralButtonEdit.SetButtonKind(const AValue: TMaxxRuralButtonKind);
begin
  FButton.Kind := AValue;
end;

procedure TMaxxRuralButtonEdit.SetButtonWidth(const AValue: Integer);
begin
  if FButtonWidth = AValue then
    Exit;
  FButtonWidth := Max(34, AValue);
  UpdateChildBounds;
end;

procedure TMaxxRuralButtonEdit.SetCharCase(const AValue: TEditCharCase);
begin
  FEdit.CharCase := AValue;
end;

procedure TMaxxRuralButtonEdit.SetCornerRadius(const AValue: Integer);
begin
  FEdit.CornerRadius := AValue;
  FButton.CornerRadius := 0;
end;

procedure TMaxxRuralButtonEdit.SetCounterText(const AValue: string);
begin
  FEdit.CounterText := AValue;
  UpdateChildBounds;
end;

procedure TMaxxRuralButtonEdit.SetEditKind(const AValue: TMaxxRuralEditKind);
begin
  FEdit.EditKind := AValue;
end;

procedure TMaxxRuralButtonEdit.SetEditMask(const AValue: string);
begin
  FEdit.EditMask := AValue;
end;

procedure TMaxxRuralButtonEdit.SetHelperText(const AValue: string);
begin
  FEdit.HelperText := AValue;
  UpdateChildBounds;
end;

procedure TMaxxRuralButtonEdit.SetInputSize(const AValue: TMaxxRuralInputSize);
begin
  FEdit.InputSize := AValue;
  UpdateChildBounds;
end;

procedure TMaxxRuralButtonEdit.SetFocus;
begin
  if FEdit <> nil then
    FEdit.SetFocus
  else
    inherited;
end;

procedure TMaxxRuralButtonEdit.SetLabelText(const AValue: string);
begin
  FEdit.LabelText := AValue;
  if (AValue.Trim <> '') and (Height <= 38) then
    Height := 60;
  UpdateChildBounds;
end;

procedure TMaxxRuralButtonEdit.SetMaxLength(const AValue: Integer);
begin
  FEdit.MaxLength := AValue;
end;

procedure TMaxxRuralButtonEdit.SetPasswordChar(const AValue: Char);
begin
  FEdit.PasswordChar := AValue;
end;

procedure TMaxxRuralButtonEdit.SetPlaceholder(const AValue: string);
begin
  FEdit.Placeholder := AValue;
end;

procedure TMaxxRuralButtonEdit.SetReadOnly(const AValue: Boolean);
begin
  FEdit.ReadOnly := AValue;
  FButton.Enabled := Enabled and not AValue;
end;

procedure TMaxxRuralButtonEdit.SetRequired(const AValue: Boolean);
begin
  FEdit.Required := AValue;
end;

procedure TMaxxRuralButtonEdit.SetShowButtonIcon(const AValue: Boolean);
begin
  FButton.ShowIcon := AValue;
end;

procedure TMaxxRuralButtonEdit.SetStatus(const AValue: TMaxxRuralEditStatus);
begin
  FEdit.Status := AValue;
end;

procedure TMaxxRuralButtonEdit.SetText(const AValue: string);
begin
  FEdit.Text := AValue;
end;

procedure TMaxxRuralButtonEdit.SetVariant(const AValue: TMaxxRuralInputVariant);
begin
  FEdit.Variant := AValue;
  UpdateChildBounds;
end;

procedure TMaxxRuralButtonEdit.UpdateChildBounds;
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

procedure TMaxxRuralButtonEdit.WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
begin
  AMessage.Result := 1;
end;

end.
