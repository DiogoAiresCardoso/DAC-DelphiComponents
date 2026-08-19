unit DAC.Components.Controls.ComboBox;

interface

uses
  System.Classes,
  System.Skia,
  System.Types,
  System.UITypes,
  System.SysUtils,
  Winapi.Messages,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Graphics,
  Vcl.Skia,
  Vcl.StdCtrls,
  DAC.Components.Controls.Edit,
  DAC.Components.Controls.SystemText,
  DAC.Components.Controls.FieldSupport,
  DAC.Components.DesignSystem.Fonts,
  DAC.Components.DesignSystem.ComponentStyle,
  DAC.Components.DesignSystem.ControlTokens,
  DAC.Components.DesignSystem.OpacityTokens,
  DAC.Components.DesignSystem.Theme,
  DAC.Components.DesignSystem.IconAssets,
  DAC.Components.Skia.IconPainter,
  DAC.Components.Skia.BackgroundPainter,
  DAC.Components.Skia.BorderPainter,
  DAC.Components.Skia.Renderer;

type
  TDACComboDropDownState = (cdsClosed, cdsOpening, cdsOpen, cdsClosing);

  TDACComboBox = class(TCustomControl)
  private
    FBackgroundPainter: TDACSkiaBackgroundPainter;
    FBindingCanModify: Boolean;
    FBorderPainter: TDACSkiaBorderPainter;
    FCombo: TComboBox;
    FCornerRadius: Integer;
    FCounterText: string;
    FDropDownCount: Integer;
    FDropDownForm: TForm;
    FDropDownHotIndex: Integer;
    FDropDownPaintBox: TSkPaintBox;
    FDropDownTextOverlay: TDACSystemTextOverlay;
    FDropDownState: TDACComboDropDownState;
    FDesignValueLabel: TLabel;
    FErrorText: string;
    FFieldText: TDACFieldTextSupport;
    FHelperText: string;
    FIconPainter: TDACSkiaIconPainter;
    FInputSize: TDACInputSize;
    FItemIndex: Integer;
    FItems: TStringList;
    FLabelText: string;
    FNativeLabel: TLabel;
    FMouseInside: Boolean;
    FLoading: Boolean;
    FReadOnly: Boolean;
    FOwnerClickCloseLatch: Boolean;
    FOnCloseUp: TNotifyEvent;
    FOnChange: TNotifyEvent;
    FOnDropDown: TNotifyEvent;
    FPaintBox: TSkPaintBox;
    FRenderer: TDACSkiaRenderer;
    FRequired: Boolean;
    FStatus: TDACEditStatus;
    FSyncingNative: Boolean;
    FLoadingTabStopCaptured: Boolean;
    FTabStopBeforeLoading: Boolean;
    FThemeMode: TDACThemeMode;
    FText: string;
    FVariant: TDACInputVariant;
    FStyle: TComboBoxStyle;
    function BorderAlpha: Byte;
    function BorderColor: TAlphaColor;
    function CanModifyValue: Boolean;
    procedure AttachComboToHost;
    function CanUpdateChildren: Boolean;
    function ControlHeight: Integer;
    procedure CMEnabledChanged(var AMessage: TMessage); message CM_ENABLEDCHANGED;
    procedure CMParentColorChanged(var AMessage: TMessage); message CM_PARENTCOLORCHANGED;
    procedure CMParentFontChanged(var AMessage: TMessage); message CM_PARENTFONTCHANGED;
    procedure CMShowingChanged(var AMessage: TMessage); message CM_SHOWINGCHANGED;
    procedure DoComboChange(Sender: TObject);
    procedure DoComboEnter(Sender: TObject);
    procedure DoComboExit(Sender: TObject);
    procedure DoMouseEnter(Sender: TObject);
    procedure DoMouseLeave(Sender: TObject);
    function ChromeTop: Integer;
    procedure DropDownDeactivate(Sender: TObject);
    procedure DropDownKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    function DropDownItemAt(const AY: Integer): Integer;
    function DropDownItemHeight: Integer;
    procedure DropDownPaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    procedure DropDownPaintBoxMouseLeave(Sender: TObject);
    procedure DropDownPaintBoxMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure DropDownPaintBoxMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    function DropDownVisible: Boolean;
    procedure EnsureDropDown;
    function GetDropDownCount: Integer;
    function GetItemIndex: Integer;
    function GetItems: TStrings;
    function GetStyle: TComboBoxStyle;
    function GetText: string;
    function HasLabel: Boolean;
    function HasSupportText: Boolean;
    function InputFontSize: Integer;
    function ResolvedFieldState: TDACResolvedFieldState;
    procedure ItemsChanged(Sender: TObject);
    procedure NativeRequestDropDown(Sender: TObject);
    function NativeFocused: Boolean;
    procedure PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    procedure PaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    function ParentSurfaceColor: TAlphaColor;
    function Pixels(const AValue: Integer): Integer;
    function ResolvedTokens: TDACControlTokens;
    procedure ResolveTextState(const AValue: string);
    procedure SetCornerRadius(const AValue: Integer);
    procedure SetCounterText(const AValue: string);
    procedure SetDropDownCount(const AValue: Integer);
    procedure SetErrorText(const AValue: string);
    procedure SetHelperText(const AValue: string);
    procedure SetInputSize(const AValue: TDACInputSize);
    procedure SetItemIndex(const AValue: Integer);
    procedure SetItems(const AValue: TStrings);
    procedure SetLabelText(const AValue: string);
    procedure SetLoading(const AValue: Boolean);
    procedure SetReadOnly(const AValue: Boolean);
    procedure SetRequired(const AValue: Boolean);
    procedure SetStatus(const AValue: TDACEditStatus);
    procedure SetStyle(const AValue: TComboBoxStyle);
    procedure SetText(const AValue: string);
    procedure SetThemeMode(const AValue: TDACThemeMode);
    procedure SetVariant(const AValue: TDACInputVariant);
    procedure ShowDropDown;
    procedure ToggleDropDown;
    procedure UpdateChildBounds;
    procedure UpdateComboStyle;
    procedure UpdateDesignValuePreview;
    procedure SynchronizeNative;
    procedure UpdateNativeLabel;
    procedure UpdatePaintBoxBounds;
    procedure UpdateZOrder;
    procedure ThemeChanged(Sender: TObject);
    procedure WMEraseBkgnd(var AMessage: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMSetFocus(var AMessage: TWMSetFocus); message WM_SETFOCUS;
  protected
    procedure CreateWnd; override;
    procedure Loaded; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Resize; override;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;
    procedure SetBindingCanModify(const AValue: Boolean);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function LabelFontSize: Integer;
    function PopupVisible: Boolean;
    function ResolvedChromeColor: TAlphaColor;
    function ResolvedPopupBackground: TAlphaColor;
    procedure CloseDropDown;
    procedure Redraw;
    procedure OpenDropDown;
    procedure SetFocus; reintroduce;
    procedure SimulateDropDownClick(const AIndex: Integer);
    procedure SimulateDropDownExternalDeactivate;
    procedure SimulateDropDownKey(const AKey: Word);
    property ComboControl: TComboBox read FCombo;
    property NativeLabel: TLabel read FNativeLabel;
  published
    property Align;
    property Anchors;
    property Constraints;
    property CornerRadius: Integer read FCornerRadius write SetCornerRadius
      default DACComboBoxDefaultCornerRadius;
    property CounterText: string read FCounterText write SetCounterText;
    property DropDownCount: Integer read GetDropDownCount write SetDropDownCount default 8;
    property Enabled;
    property ErrorText: string read FErrorText write SetErrorText;
    property Font;
    property HelperText: string read FHelperText write SetHelperText;
    property InputSize: TDACInputSize read FInputSize write SetInputSize default misSmall;
    property ItemIndex: Integer read GetItemIndex write SetItemIndex default -1;
    property Items: TStrings read GetItems write SetItems;
    property LabelText: string read FLabelText write SetLabelText;
    property Loading: Boolean read FLoading write SetLoading default False;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly: Boolean read FReadOnly write SetReadOnly default False;
    property Required: Boolean read FRequired write SetRequired default False;
    property ShowHint;
    property Status: TDACEditStatus read FStatus write SetStatus default mesNormal;
    property Style: TComboBoxStyle read GetStyle write SetStyle default csDropDownList;
    property TabOrder;
    property TabStop default True;
    property Text: string read GetText write SetText;
    property ThemeMode: TDACThemeMode read FThemeMode write SetThemeMode default dtmInherit;
    property Variant: TDACInputVariant read FVariant write SetVariant default mivOutlined;
    property Visible;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnCloseUp: TNotifyEvent read FOnCloseUp write FOnCloseUp;
    property OnClick;
    property OnDblClick;
    property OnEnter;
    property OnExit;
    property OnDropDown: TNotifyEvent read FOnDropDown write FOnDropDown;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
  end;

function DACNativeComboBoxClass: TWinControlClass;
function DACNativeComboBoxEditablePaintDelegations(
  const AControl: TComboBox): Cardinal;

implementation

uses
  DAC.Components.DesignSystem.ColorTokens,
  System.Math,
  Winapi.Windows,
  Winapi.UxTheme;

type
  { Keeps the real ComboBox HWND as the text, selection, keyboard-search and
    accessibility owner. Its native border/dropdown column are clipped so the
    surrounding DAC control remains the only visible chrome/popup owner. }
  TDACNativeComboBox = class(TComboBox)
  private
    FDropDownClipWidth: Integer;
    FEditablePaintDelegations: Cardinal;
    FInteractionLocked: Boolean;
    FOnRequestDropDown: TNotifyEvent;
    FVerticalClipInset: Integer;
    procedure ApplyClip;
    procedure SetDropDownClipWidth(const AValue: Integer);
    procedure SetVerticalClipInset(const AValue: Integer);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure Resize; override;
    procedure WndProc(var Message: TMessage); override;
  public
    constructor Create(AOwner: TComponent); override;
    property DropDownClipWidth: Integer read FDropDownClipWidth
      write SetDropDownClipWidth;
    property VerticalClipInset: Integer read FVerticalClipInset
      write SetVerticalClipInset;
    property InteractionLocked: Boolean read FInteractionLocked
      write FInteractionLocked;
    property OnRequestDropDown: TNotifyEvent read FOnRequestDropDown
      write FOnRequestDropDown;
  end;

function DACNativeComboBoxClass: TWinControlClass;
begin
  Result := TDACNativeComboBox;
end;

function DACNativeComboBoxEditablePaintDelegations(
  const AControl: TComboBox): Cardinal;
begin
  if AControl is TDACNativeComboBox then
    Result := TDACNativeComboBox(AControl).FEditablePaintDelegations
  else
    Result := 0;
end;

procedure TDACNativeComboBox.ApplyClip;
var
  LClipWidth: Integer;
  LInset: Integer;
  LRegion: HRGN;
begin
  if not HandleAllocated or (Width <= 0) or (Height <= 0) then
    Exit;
  LClipWidth := Max(1, Width - FDropDownClipWidth);
  LInset := Min(Max(0, FVerticalClipInset), Max(0, (Height - 1) div 2));
  LRegion := CreateRectRgn(0, LInset, LClipWidth, Height - LInset);
  if SetWindowRgn(Handle, LRegion, True) = 0 then
    DeleteObject(LRegion);
end;

constructor TDACNativeComboBox.Create(AOwner: TComponent);
begin
  inherited;
end;

procedure TDACNativeComboBox.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.Style := Params.Style and not WS_BORDER;
  Params.ExStyle := Params.ExStyle and not
    (WS_EX_CLIENTEDGE or WS_EX_STATICEDGE);
end;

procedure TDACNativeComboBox.CreateWnd;
begin
  inherited;
  SetWindowTheme(Handle, '', '');
  SetWindowLong(Handle, GWL_STYLE,
    GetWindowLong(Handle, GWL_STYLE) and not WS_BORDER);
  SetWindowLong(Handle, GWL_EXSTYLE,
    GetWindowLong(Handle, GWL_EXSTYLE) and not
      (WS_EX_CLIENTEDGE or WS_EX_STATICEDGE));
  SetWindowPos(Handle, 0, 0, 0, 0, 0, SWP_NOMOVE or SWP_NOSIZE or
    SWP_NOZORDER or SWP_NOACTIVATE or SWP_FRAMECHANGED);
  SendMessage(Handle, WM_CHANGEUISTATE,
    MakeLong(UIS_SET, UISF_HIDEFOCUS or UISF_HIDEACCEL), 0);
  ApplyClip;
end;

procedure TDACNativeComboBox.Resize;
begin
  inherited;
  ApplyClip;
end;

procedure TDACNativeComboBox.SetDropDownClipWidth(const AValue: Integer);
begin
  if FDropDownClipWidth = Max(0, AValue) then
    Exit;
  FDropDownClipWidth := Max(0, AValue);
  ApplyClip;
end;

procedure TDACNativeComboBox.SetVerticalClipInset(const AValue: Integer);
begin
  if FVerticalClipInset = Max(0, AValue) then
    Exit;
  FVerticalClipInset := Max(0, AValue);
  ApplyClip;
end;

procedure TDACNativeComboBox.WndProc(var Message: TMessage);
begin
  if Message.Msg = CB_SHOWDROPDOWN then
  begin
    if (Message.WParam <> 0) and Assigned(FOnRequestDropDown) and
      not FInteractionLocked then
      FOnRequestDropDown(Self);
    Message.Result := 0;
    Exit;
  end;

  if FInteractionLocked then
    case Message.Msg of
      WM_CHAR, WM_MOUSEWHEEL:
        begin
          Message.Result := 0;
          Exit;
        end;
      WM_KEYDOWN:
        if Message.WParam in [VK_UP, VK_DOWN, VK_LEFT, VK_RIGHT, VK_HOME,
          VK_END, VK_PRIOR, VK_NEXT, VK_F4, VK_SPACE] then
        begin
          Message.Result := 0;
          Exit;
        end;
    end;
  if (Style in [csDropDown, csSimple]) and
    ((Message.Msg = WM_PAINT) or (Message.Msg = WM_PRINTCLIENT)) then
    { Editable styles always reach the native ComboBox/edit child. No DAC
      text renderer is allowed to cover its selection, caret or IME state. }
    Inc(FEditablePaintDelegations);
  inherited;
end;

function ComboBoxVclColor(const AColor: TAlphaColor): TColor;
begin
  Result := TColor(((AColor and $00FF0000) shr 16) or
    (AColor and $0000FF00) or ((AColor and $000000FF) shl 16));
end;

constructor TDACComboBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  { The wrapper is only the host for native text and the Skia chrome. Keeping
    it non-opaque prevents a white rectangle behind its label/support rows. }
  ControlStyle := (ControlStyle + [csClickEvents, csCaptureMouse]) - [csOpaque];
  FBindingCanModify := True;
  FThemeMode := dtmInherit;
  Width := Round(ResolvedTokens.ComboBoxDefaultWidth);
  Height := Round(ResolvedTokens.ComboBoxDefaultHeight);
  TabStop := True;
  ParentColor := True;
  StyleElements := [];
  Cursor := crDefault;
  FCornerRadius := Round(ResolvedTokens.ComboBoxDefaultCornerRadius);
  TDACThemeManager.RegisterListener(Self, ThemeChanged);
  FInputSize := misSmall;
  FItemIndex := -1;
  FDropDownHotIndex := -1;
  FDropDownState := cdsClosed;
  FDropDownCount := ResolvedTokens.ComboBoxDefaultDropDownCount;
  FStatus := mesNormal;
  FStyle := csDropDownList;
  FVariant := mivOutlined;

  FRenderer := TDACSkiaRenderer.Create;
  FBackgroundPainter := TDACSkiaBackgroundPainter.Create(FRenderer);
  FBorderPainter := TDACSkiaBorderPainter.Create(FRenderer);
  FIconPainter := TDACSkiaIconPainter.Create(FRenderer);

  FItems := TStringList.Create;
  FItems.OnChange := ItemsChanged;

  FCombo := TDACNativeComboBox.Create(Self);
  { Parenting remains deferred until the wrapper has a complete HWND chain,
    preserving Parent=nil designer safety. The transient native child is not
    serialized, but becomes the permanent text/accessibility surface at
    runtime. }
  FCombo.Style := csDropDownList;
  { seClient is required for VCL 10.2 to dispatch WM_PAINT to the localized
    suite style hook. Border and font remain outside the style engine. }
  FCombo.StyleElements := [seClient];
  FCombo.ParentFont := False;
  FCombo.Visible := False;
  FCombo.TabStop := False;
  FCombo.OnChange := DoComboChange;
  FCombo.OnEnter := DoComboEnter;
  FCombo.OnExit := DoComboExit;
  FCombo.OnMouseEnter := DoMouseEnter;
  FCombo.OnMouseLeave := DoMouseLeave;
  TDACNativeComboBox(FCombo).OnRequestDropDown := NativeRequestDropDown;

  { The form designer must not host the transient HWND used by the runtime
    ComboBox. This lightweight VCL label presents the streamed value while
    keeping its text as crisp as the native editor. }
  FDesignValueLabel := TLabel.Create(Self);
  FDesignValueLabel.Parent := Self;
  FDesignValueLabel.SetSubComponent(True);
  FDesignValueLabel.AutoSize := False;
  FDesignValueLabel.Transparent := True;
  FDesignValueLabel.ParentFont := False;
  FDesignValueLabel.Visible := False;
  FDesignValueLabel.OnMouseDown := PaintBoxMouseDown;
  FDesignValueLabel.OnMouseEnter := DoMouseEnter;
  FDesignValueLabel.OnMouseLeave := DoMouseLeave;

  FFieldText := TDACFieldTextSupport.Create(Self, Self);
  FNativeLabel := FFieldText.CaptionLabel;
  FFieldText.SetFocusControl(FCombo);

  FPaintBox := TSkPaintBox.Create(Self);
  FPaintBox.Parent := Self;
  FPaintBox.SetSubComponent(True);
  FPaintBox.StyleElements := [];
  FPaintBox.OnDraw := PaintBoxDraw;
  FPaintBox.OnMouseDown := PaintBoxMouseDown;
  FPaintBox.OnMouseEnter := DoMouseEnter;
  FPaintBox.OnMouseLeave := DoMouseLeave;

  UpdateComboStyle;
  Resize;
end;

destructor TDACComboBox.Destroy;
begin
  TDACThemeManager.UnregisterListener(Self);
  FItems.OnChange := nil;
  FDropDownForm.Free;
  FDesignValueLabel.Free;
  FCombo.Free;
  FItems.Free;
  FFieldText.Free;
  FPaintBox.Free;
  FIconPainter.Free;
  FBorderPainter.Free;
  FBackgroundPainter.Free;
  FRenderer.Free;
  inherited;
end;

function TDACComboBox.BorderAlpha: Byte;
var
  LTokens: TDACControlTokens;
begin
  LTokens := ResolvedTokens;
  if FVariant = mivUnderlined then
  begin
    if NativeFocused or DropDownVisible or (FStatus <> mesNormal) then
      Exit(LTokens.ComboBoxUnderlinedBorderAlphaFocus);
    if FMouseInside then
      Exit(LTokens.ComboBoxUnderlinedBorderAlphaHover);
    Exit(LTokens.ComboBoxUnderlinedBorderAlphaNormal);
  end;

  if not Enabled or FLoading then
    Result := LTokens.ComboBoxBorderAlphaDisabled
  else if NativeFocused or DropDownVisible then
    Result := LTokens.ComboBoxBorderAlphaFocus
  else if FStatus <> mesNormal then
    Result := LTokens.ComboBoxBorderAlphaStatus
  else if FMouseInside then
    Result := LTokens.ComboBoxBorderAlphaHover
  else
    Result := LTokens.ComboBoxBorderAlphaNormal;
end;

function TDACComboBox.BorderColor: TAlphaColor;
var
  LTokens: TDACControlTokens;
begin
  LTokens := ResolvedTokens;
  case FStatus of
    mesSuccess:
      Result := LTokens.ComboBoxSuccessBorder;
    mesWarning:
      Result := LTokens.ComboBoxWarningBorder;
    mesDanger:
      Result := LTokens.ComboBoxDangerBorder;
  else
    if NativeFocused or DropDownVisible then
      Result := LTokens.ComboBoxFocusBorder
    else if FMouseInside then
      Result := LTokens.ComboBoxBorderHover
    else
      Result := LTokens.ComboBoxBorder;
  end;
end;

function TDACComboBox.CanModifyValue: Boolean;
begin
  Result := Enabled and not FLoading and not FReadOnly and FBindingCanModify;
end;

procedure TDACComboBox.AttachComboToHost;
begin
  if (FCombo = nil) or (FCombo.Parent = Self) or
    (csLoading in ComponentState) or (csDesigning in ComponentState) or
    (csDestroying in ComponentState) or (Parent = nil) or
    not HandleAllocated or not Parent.HandleAllocated then
    Exit;
  FCombo.Parent := Self;
  SynchronizeNative;
end;

function TDACComboBox.CanUpdateChildren: Boolean;
begin
  Result := not (csDestroying in ComponentState) and (Parent <> nil) and
    HandleAllocated and Parent.HandleAllocated and (FCombo <> nil) and
    (FCombo.Parent = Self);
end;

function TDACComboBox.ControlHeight: Integer;
var
  LTokens: TDACControlTokens;
begin
  LTokens := ResolvedTokens;
  case FInputSize of
    misSmall: Result := Round(LTokens.ComboBoxSmallChromeHeight);
    misLarge: Result := Round(LTokens.ComboBoxLargeChromeHeight);
  else
    Result := Round(LTokens.ComboBoxMediumChromeHeight);
  end;
  if FVariant = mivCompact then
    Result := Round(LTokens.ComboBoxSmallChromeHeight);
end;

procedure TDACComboBox.CloseDropDown;
begin
  if FDropDownState in [cdsClosed, cdsClosing] then
    Exit;
  FDropDownState := cdsClosing;
  if (FDropDownForm <> nil) and FDropDownForm.Visible then
    FDropDownForm.Hide;
  FDropDownHotIndex := -1;
  FDropDownState := cdsClosed;
  Redraw;
  if Assigned(FOnCloseUp) then
    FOnCloseUp(Self);
end;

function TDACComboBox.ChromeTop: Integer;
begin
  Result := DACFieldChromeTop(HasLabel, ResolvedTokens);
end;

procedure TDACComboBox.CMEnabledChanged(var AMessage: TMessage);
begin
  inherited;
  if not Enabled then
  begin
    CloseDropDown;
    DACFieldRelinquishFocus(Self, FCombo);
  end;
  UpdateComboStyle;
  Redraw;
end;

procedure TDACComboBox.CMParentColorChanged(var AMessage: TMessage);
begin
  inherited;
  UpdateComboStyle;
  Redraw;
end;

procedure TDACComboBox.CMParentFontChanged(var AMessage: TMessage);
begin
  inherited;
  UpdateComboStyle;
  Redraw;
end;

procedure TDACComboBox.CMShowingChanged(var AMessage: TMessage);
begin
  inherited;
  if not Showing then
  begin
    CloseDropDown;
    if FCombo <> nil then
      FCombo.Visible := False;
    Exit;
  end;
  AttachComboToHost;
  UpdateChildBounds;
  UpdateComboStyle;
  UpdateZOrder;
  Redraw;
end;

procedure TDACComboBox.CreateWnd;
begin
  inherited;
  AttachComboToHost;
  UpdateZOrder;
  UpdateChildBounds;
  UpdateComboStyle;
  Redraw;
end;

procedure TDACComboBox.DoComboChange(Sender: TObject);
begin
  if FSyncingNative then
    Exit;
  if not CanModifyValue then
  begin
    SynchronizeNative;
    Exit;
  end;
  if (FCombo <> nil) and FCombo.HandleAllocated then
  begin
    FItemIndex := FCombo.ItemIndex;
    if (FItemIndex >= 0) and (FItemIndex < FItems.Count) then
      FText := FItems[FItemIndex]
    else
    begin
      FItemIndex := -1;
      if FStyle = csDropDown then
        FText := FCombo.Text
      else
        FText := '';
    end;
  end;
  Redraw;
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TDACComboBox.DoComboEnter(Sender: TObject);
begin
  Redraw;
  if Assigned(OnEnter) then
    OnEnter(Self);
end;

procedure TDACComboBox.DoComboExit(Sender: TObject);
begin
  Redraw;
  if Assigned(OnExit) then
    OnExit(Self);
end;

procedure TDACComboBox.DropDownDeactivate(Sender: TObject);
var
  LPoint: TPoint;
begin
  FOwnerClickCloseLatch := False;
  if GetCursorPos(LPoint) then
  begin
    LPoint := ScreenToClient(LPoint);
    FOwnerClickCloseLatch := PtInRect(ClientRect, LPoint) and
      (GetKeyState(VK_LBUTTON) < 0);
  end;
  CloseDropDown;
end;

procedure TDACComboBox.DropDownKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
  LIndex: Integer;
  LKey: Word;
begin
  if not CanModifyValue or not DropDownVisible or
    (FCombo = nil) or (FItems.Count = 0) then
    Exit;

  LKey := Key;
  case Key of
    VK_ESCAPE:
      begin
        Key := 0;
        CloseDropDown;
      end;
    VK_RETURN:
      begin
        Key := 0;
        CloseDropDown;
      end;
    VK_DOWN, VK_UP:
      begin
        Key := 0;
        LIndex := FItemIndex;
        if LIndex < 0 then
          LIndex := 0
        else if LKey = VK_DOWN then
          LIndex := Min(FItems.Count - 1, LIndex + 1)
        else
          LIndex := Max(0, LIndex - 1);
        if FItemIndex = LIndex then
          Exit;
        SetItemIndex(LIndex);
        FDropDownHotIndex := LIndex;
        if Assigned(FOnChange) then
          FOnChange(Self);
        if FDropDownPaintBox <> nil then
          FDropDownPaintBox.Redraw;
      end;
  end;
end;

function TDACComboBox.DropDownItemAt(const AY: Integer): Integer;
begin
  Result := AY div DropDownItemHeight;
  if (Result < 0) or (Result >= FItems.Count) then
    Result := -1;
end;

function TDACComboBox.DropDownItemHeight: Integer;
begin
  Result := Round(ResolvedTokens.ComboBoxPopupItemHeight);
end;

procedure TDACComboBox.DropDownPaintBoxDraw(Sender: TObject;
  const ACanvas: ISkCanvas; const ADest: TRectF; const AOpacity: Single);
var
  LBackground: TAlphaColor;
  LBorder: TAlphaColor;
  LCheckRect: TRectF;
  LIconStyle: TDACIconStyle;
  LIndex: Integer;
  LItemHeight: Integer;
  LRect: TRectF;
  LRow: TRectF;
  LTextColor: TAlphaColor;
  LTokens: TDACControlTokens;
begin
  if (ACanvas = nil) or (FCombo = nil) then
    Exit;

  { Popup item captions are a native text layer.  Do not route form text
    through the Skia renderer: the popup keeps Skia for its surface and icons
    while Windows provides ClearType, font fallback and matching hinting. }
  FDropDownTextOverlay.BeginNativeTextFrame;
  try

  LTokens := ResolvedTokens;
  LBackground := LTokens.ComboBoxPopupBackground;
  LBorder := LTokens.ComboBoxPopupBorder;

  ACanvas.Clear(LTokens.ComboBoxPopupCanvasBackground);
  LRect := FRenderer.SnapRect(TRectF.Create(0, 0, ADest.Width, ADest.Height),
    LTokens.ComboBoxPopupSnapScale);
  LRect.Inflate(-LTokens.ComboBoxPopupBorderInset,
    -LTokens.ComboBoxPopupBorderInset);
  FRenderer.FillRoundRect(ACanvas, LRect, LBackground, FCornerRadius,
    LTokens.ComboBoxPopupBackgroundAlpha);
  FRenderer.StrokeRoundRect(ACanvas, LRect, LTokens.ComboBoxPopupBorder,
    FCornerRadius, LTokens.ComboBoxPopupBorderWidth,
    LTokens.ComboBoxPopupBorderAlpha);

  LItemHeight := DropDownItemHeight;
  for LIndex := 0 to FItems.Count - 1 do
  begin
    LRow := TRectF.Create(LRect.Left + LTokens.ComboBoxPopupItemInset,
      LRect.Top + (LIndex * LItemHeight) + LTokens.ComboBoxPopupItemInset,
      LRect.Right - LTokens.ComboBoxPopupItemInset,
      LRect.Top + ((LIndex + 1) * LItemHeight) + LTokens.ComboBoxPopupItemInset);
    if LRow.Top >= LRect.Bottom then
      Break;

    if LIndex = FItemIndex then
      FRenderer.FillRoundRect(ACanvas, LRow, LTokens.ComboBoxPopupItemSelectedBackground,
        LTokens.ComboBoxPopupRowRadius, LTokens.ComboBoxPopupSelectedAlpha)
    else if LIndex = FDropDownHotIndex then
      FRenderer.FillRoundRect(ACanvas, LRow, LTokens.ComboBoxPopupItemHotBackground,
        LTokens.ComboBoxPopupRowRadius, LTokens.ComboBoxPopupHotAlpha);

    LTextColor := LTokens.ComboBoxPopupItemText;
    if LIndex = FItemIndex then
      LTextColor := LTokens.ComboBoxPopupItemSelectedText;

    FDropDownTextOverlay.QueueCenteredText(FItems[LIndex],
      TDACComponentFontInstaller.FontFamily,
      TRectF.Create(LRow.Left + Pixels(Round(LTokens.ComboBoxPopupItemTextLeftInset)), LRow.Top,
        LRow.Right - Pixels(Round(LTokens.ComboBoxPopupItemTextRightReserve)), LRow.Bottom),
      Round(LTokens.ComboBoxPopupItemTextSize), LTextColor);

    if LIndex = FItemIndex then
    begin
      LCheckRect := TRectF.Create(LRow.Right - Pixels(Round(LTokens.ComboBoxPopupCheckColumnWidth)),
        LRow.Top + (LRow.Height - Pixels(Round(LTokens.ComboBoxPopupCheckSize))) / 2,
        LRow.Right - Pixels(Round(LTokens.ComboBoxPopupCheckRightInset)),
        LRow.Top + (LRow.Height + Pixels(Round(LTokens.ComboBoxPopupCheckSize))) / 2);
      LIconStyle.Color := LTokens.ComboBoxPopupCheck;
      LIconStyle.Alpha := LTokens.ComboBoxPopupCheckAlpha;
      FIconPainter.Draw(ACanvas, LCheckRect, mikCheck, LIconStyle);
    end;

    if LIndex < FItems.Count - 1 then
      FRenderer.StrokeRoundRect(ACanvas,
        TRectF.Create(LRect.Left + Pixels(Round(LTokens.ComboBoxPopupSeparatorInset)), LRow.Bottom,
          LRect.Right - Pixels(Round(LTokens.ComboBoxPopupSeparatorInset)),
          LRow.Bottom + LTokens.ComboBoxPopupSeparatorHeight), LBorder, 0,
        LTokens.ComboBoxPopupSeparatorHeight, LTokens.ComboBoxPopupSeparatorAlpha);
  end;
  finally
    FDropDownTextOverlay.EndNativeTextFrame;
  end;
end;

procedure TDACComboBox.DropDownPaintBoxMouseLeave(Sender: TObject);
begin
  if FDropDownHotIndex = -1 then
    Exit;
  FDropDownHotIndex := -1;
  if FDropDownPaintBox <> nil then
    FDropDownPaintBox.Redraw;
end;

procedure TDACComboBox.DropDownPaintBoxMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  LIndex: Integer;
begin
  LIndex := DropDownItemAt(Y);
  if FDropDownHotIndex = LIndex then
    Exit;
  FDropDownHotIndex := LIndex;
  if FDropDownPaintBox <> nil then
    FDropDownPaintBox.Redraw;
end;

procedure TDACComboBox.DropDownPaintBoxMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  LIndex: Integer;
begin
  if Button <> mbLeft then
    Exit;

  LIndex := DropDownItemAt(Y);
  if LIndex >= 0 then
  begin
    SetItemIndex(LIndex);
    CloseDropDown;
    if Assigned(FOnChange) then
      FOnChange(Self);
  end
  else
    CloseDropDown;
end;

function TDACComboBox.DropDownVisible: Boolean;
begin
  Result := (FDropDownState = cdsOpen) and
    (FDropDownForm <> nil) and FDropDownForm.Visible;
end;

procedure TDACComboBox.EnsureDropDown;
begin
  if FDropDownForm <> nil then
    Exit;

  FDropDownForm := TForm.CreateNew(nil);
  FDropDownForm.BorderStyle := bsNone;
  FDropDownForm.Position := poDesigned;
  FDropDownForm.StyleElements := [];
  FDropDownForm.Visible := False;
  FDropDownForm.KeyPreview := True;
  FDropDownForm.OnDeactivate := DropDownDeactivate;
  FDropDownForm.OnKeyDown := DropDownKeyDown;

  FDropDownPaintBox := TSkPaintBox.Create(FDropDownForm);
  FDropDownPaintBox.Parent := FDropDownForm;
  FDropDownPaintBox.Align := alClient;
  FDropDownPaintBox.StyleElements := [];
  FDropDownPaintBox.OnDraw := DropDownPaintBoxDraw;
  FDropDownPaintBox.OnMouseLeave := DropDownPaintBoxMouseLeave;
  FDropDownPaintBox.OnMouseMove := DropDownPaintBoxMouseMove;
  FDropDownPaintBox.OnMouseUp := DropDownPaintBoxMouseUp;
  FDropDownTextOverlay := TDACSystemTextOverlay.Create(FDropDownForm);
  FDropDownTextOverlay.Parent := FDropDownForm;
  FDropDownTextOverlay.SetSubComponent(True);
  FDropDownTextOverlay.Align := alClient;
end;

procedure TDACComboBox.DoMouseEnter(Sender: TObject);
begin
  if FMouseInside then
    Exit;
  FMouseInside := True;
  Redraw;
  if Assigned(OnMouseEnter) then
    OnMouseEnter(Self);
end;

procedure TDACComboBox.DoMouseLeave(Sender: TObject);
var
  LPoint: TPoint;
begin
  if not GetCursorPos(LPoint) then
    Exit;
  LPoint := ScreenToClient(LPoint);
  if PtInRect(ClientRect, LPoint) then
    Exit;

  if not FMouseInside then
    Exit;
  FMouseInside := False;
  Redraw;
  if Assigned(OnMouseLeave) then
    OnMouseLeave(Self);
end;

function TDACComboBox.GetDropDownCount: Integer;
begin
  Result := FDropDownCount;
end;

function TDACComboBox.GetItemIndex: Integer;
begin
  Result := FItemIndex;
end;

function TDACComboBox.GetItems: TStrings;
begin
  Result := FItems;
end;

function TDACComboBox.GetStyle: TComboBoxStyle;
begin
  Result := FStyle;
end;

function TDACComboBox.GetText: string;
begin
  Result := FText;
end;

function TDACComboBox.HasLabel: Boolean;
begin
  Result := FLabelText.Trim <> '';
end;

function TDACComboBox.HasSupportText: Boolean;
begin
  Result := (FHelperText.Trim <> '') or (FErrorText.Trim <> '') or
    (FCounterText.Trim <> '');
end;

function TDACComboBox.InputFontSize: Integer;
var
  LTokens: TDACControlTokens;
begin
  LTokens := ResolvedTokens;
  case FInputSize of
    misSmall:
      Result := Round(LTokens.ComboBoxSmallTextSize);
    misLarge:
      Result := Round(LTokens.ComboBoxLargeTextSize);
  else
    Result := Round(LTokens.ComboBoxMediumTextSize);
  end;
end;

procedure TDACComboBox.ItemsChanged(Sender: TObject);
begin
  ResolveTextState(FText);
  SynchronizeNative;
  Redraw;
end;

procedure TDACComboBox.NativeRequestDropDown(Sender: TObject);
begin
  if FOwnerClickCloseLatch then
  begin
    FOwnerClickCloseLatch := False;
    Exit;
  end;
  ToggleDropDown;
end;

function TDACComboBox.NativeFocused: Boolean;
begin
  Result := Focused or ((FCombo <> nil) and FCombo.Focused);
end;

function TDACComboBox.LabelFontSize: Integer;
begin
  Result := Round(ResolvedTokens.FieldLabelTextSize);
end;

procedure TDACComboBox.Loaded;
begin
  inherited;
  if FLoading then
  begin
    DACFieldBeginLoadingTabPolicy(Self, FTabStopBeforeLoading,
      FLoadingTabStopCaptured, True);
    DACFieldRelinquishFocus(Self, FCombo);
  end;
  AttachComboToHost;
  UpdatePaintBoxBounds;
  UpdateChildBounds;
  UpdateComboStyle;
  Redraw;
end;

procedure TDACComboBox.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  if (Button = mbLeft) and Enabled and not FLoading and CanFocus then
    SetFocus;
end;

procedure TDACComboBox.PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
  const ADest: TRectF; const AOpacity: Single);
var
  LArrowRect: TRectF;
  LBackground: TDACBackgroundStyle;
  LBorder: TDACBorderStyle;
  LBorderRect: TRectF;
  LControlBottom: Single;
  LIconStyle: TDACIconStyle;
  LRect: TRectF;
  LSurface: TAlphaColor;
  LTop: Single;
  LTokens: TDACControlTokens;
begin
  if (ACanvas = nil) or (ADest.Width <= 0) or (ADest.Height <= 0) then
    Exit;

  LTop := 0;
  LControlBottom := Min(ADest.Height, ControlHeight);
  LBorderRect := FRenderer.SnapRect(TRectF.Create(0, LTop, ADest.Width,
    LControlBottom), ResolvedTokens.ComboBoxBorderSnapScale);
  LRect := LBorderRect;
  LRect.Inflate(-ResolvedTokens.ComboBoxBorderInset,
    -ResolvedTokens.ComboBoxBorderInset);

  LSurface := ParentSurfaceColor;
  LTokens := ResolvedTokens;
  ACanvas.Clear(LSurface);

  LBorder.Color := BorderColor;
  LBorder.Radius := FCornerRadius;
  LBorder.Width := LTokens.ComboBoxBorderWidth;
  if NativeFocused or DropDownVisible then
    LBorder.Width := LTokens.ComboBoxFocusBorderWidth;
  LBorder.Alpha := BorderAlpha;
  if csDesigning in ComponentState then
  begin
    { Delphi's design surface is also light. The runtime normal stroke is
      intentionally subtle, but the non-interactive preview needs a fully
      legible chrome boundary. }
    LBorder.Color := LTokens.ComboBoxBorderHover;
    LBorder.Alpha := DACOpacityOpaque;
  end;
  if FVariant = mivUnderlined then
  begin
    FRenderer.StrokeRoundRect(ACanvas,
      TRectF.Create(LRect.Left, LRect.Bottom - Pixels(Round(LTokens.ComboBoxUnderlineHeight)), LRect.Right,
        LRect.Bottom), LBorder.Color, 0, LBorder.Width, LBorder.Alpha);
  end
  else
  begin
    LBackground.Color := LTokens.ComboBoxBackground;
    if not Enabled or FLoading then
      LBackground.Color := LTokens.ComboBoxDisabledBackground;
    LBackground.Radius := FCornerRadius;
    LBackground.Alpha := LTokens.ComboBoxBackgroundAlpha;
    FBackgroundPainter.Draw(ACanvas, LRect, LBackground);
    FBorderPainter.Draw(ACanvas, LBorderRect, LBorder);
  end;

  LArrowRect := TRectF.Create(LRect.Right - Pixels(Round(LTokens.ComboBoxIconColumnWidth)),
    LRect.Top + (LRect.Height - Pixels(Round(LTokens.ComboBoxIconSize))) / 2,
    LRect.Right - Pixels(Round(LTokens.ComboBoxIconRightInset)),
    LRect.Top + (LRect.Height + Pixels(Round(LTokens.ComboBoxIconSize))) / 2);
  LIconStyle.Color := LTokens.ComboBoxIcon;
  if not Enabled or FLoading then
    LIconStyle.Color := LTokens.ComboBoxIconDisabled;
  LIconStyle.Alpha := LTokens.ComboBoxIconAlpha;
  if FLoading then
    FIconPainter.Draw(ACanvas, LArrowRect, mikRefresh, LIconStyle)
  else if DropDownVisible then
    FIconPainter.Draw(ACanvas, LArrowRect, mikChevronUp, LIconStyle)
  else
    FIconPainter.Draw(ACanvas, LArrowRect, mikChevronDown, LIconStyle);
end;

procedure TDACComboBox.PaintBoxMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  LWasOpen: Boolean;
begin
  LWasOpen := DropDownVisible;
  MouseDown(Button, Shift, X, Y);
  if Button = mbLeft then
  begin
    // Focusing the native editor deactivates (and closes) the modeless popup
    // before this handler resumes. Preserve the click's initial meaning:
    // a click that started while open is always a close, never a close/reopen.
    if LWasOpen then
    begin
      FOwnerClickCloseLatch := False;
      if DropDownVisible then
        CloseDropDown;
      Exit;
    end;
    if FOwnerClickCloseLatch then
    begin
      FOwnerClickCloseLatch := False;
      Exit;
    end;
    ToggleDropDown;
  end;
end;

function TDACComboBox.ParentSurfaceColor: TAlphaColor;
begin
  { The chrome needs to blend with the real host at its rounded corners.
    Tokens determine the field surface itself, not the background outside it. }
  Result := TDACComponentColors.ResolveParentSurface(Self);
end;

function TDACComboBox.PopupVisible: Boolean;
begin
  Result := DropDownVisible;
end;

procedure TDACComboBox.OpenDropDown;
begin
  ShowDropDown;
end;

procedure TDACComboBox.Redraw;
begin
  UpdateChildBounds;
  UpdateNativeLabel;
  UpdatePaintBoxBounds;
  if csDesigning in ComponentState then
  begin
    if FPaintBox <> nil then
      FPaintBox.Redraw;
    Invalidate;
    Exit;
  end;
  if (FPaintBox <> nil) and not (csDesigning in ComponentState) and
    not (csDestroying in ComponentState) and (Parent <> nil) and
    HandleAllocated and Parent.HandleAllocated then
    FPaintBox.Redraw;
end;

function TDACComboBox.ResolvedChromeColor: TAlphaColor;
begin
  Result := ResolvedTokens.ComboBoxChromeBackground;
end;

function TDACComboBox.ResolvedPopupBackground: TAlphaColor;
begin
  Result := ResolvedTokens.ComboBoxPopupBackground;
end;

procedure TDACComboBox.Resize;
begin
  inherited;
  UpdatePaintBoxBounds;
  UpdateZOrder;
  UpdateChildBounds;
  Redraw;
end;

procedure TDACComboBox.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
var
  LMinimumHeight: Integer;
begin
  { Keep native label/helper rows outside the selector chrome even when the
    final DFM Height is streamed after the textual properties. }
  LMinimumHeight := DACFieldTotalHeight(HasLabel, HasSupportText,
    ControlHeight, ResolvedTokens);
  inherited SetBounds(ALeft, ATop, AWidth, Max(AHeight, LMinimumHeight));
end;

function TDACComboBox.Pixels(const AValue: Integer): Integer;
begin
  Result := AValue;
end;

function TDACComboBox.ResolvedTokens: TDACControlTokens;
begin
  Result := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls;
end;

procedure TDACComboBox.ResolveTextState(const AValue: string);
var
  LIndex: Integer;
begin
  LIndex := FItems.IndexOf(AValue);
  if LIndex >= 0 then
  begin
    FItemIndex := LIndex;
    FText := FItems[LIndex];
  end
  else
  begin
    FItemIndex := -1;
    if FStyle = csDropDown then
      FText := AValue
    else
      FText := '';
  end;
end;

function TDACComboBox.ResolvedFieldState: TDACResolvedFieldState;
begin
  Result := TDACFieldStateResolver.Resolve(Enabled, FLoading,
    FReadOnly or not FBindingCanModify,
    NativeFocused or DropDownVisible, FMouseInside, FText <> '',
    TDACFieldValidation(Ord(FStatus)));
end;

procedure TDACComboBox.SetCornerRadius(const AValue: Integer);
begin
  if FCornerRadius = AValue then
    Exit;
  FCornerRadius := Max(0, AValue);
  Redraw;
end;

procedure TDACComboBox.SetCounterText(const AValue: string);
var
  LHadSupport: Boolean;
begin
  if FCounterText = AValue then
    Exit;

  LHadSupport := HasSupportText;
  FCounterText := AValue;
  if (not LHadSupport) and HasSupportText and (Height <= ChromeTop + ControlHeight) then
    Height := DACFieldTotalHeight(HasLabel, HasSupportText, ControlHeight,
      ResolvedTokens);
  Redraw;
end;

procedure TDACComboBox.SetDropDownCount(const AValue: Integer);
begin
  FDropDownCount := Max(1, AValue);
  if DropDownVisible and (FDropDownPaintBox <> nil) then
    ShowDropDown;
end;

procedure TDACComboBox.SetErrorText(const AValue: string);
var
  LHadSupport: Boolean;
begin
  if FErrorText = AValue then
    Exit;
  LHadSupport := HasSupportText;
  FErrorText := AValue;
  if (not LHadSupport) and HasSupportText and
    (Height <= ChromeTop + ControlHeight) then
    Height := DACFieldTotalHeight(HasLabel, True, ControlHeight,
      ResolvedTokens);
  Redraw;
end;

procedure TDACComboBox.SetHelperText(const AValue: string);
var
  LHadSupport: Boolean;
begin
  if FHelperText = AValue then
    Exit;

  LHadSupport := HasSupportText;
  FHelperText := AValue;
  if (not LHadSupport) and HasSupportText and (Height <= ChromeTop + ControlHeight) then
    Height := DACFieldTotalHeight(HasLabel, HasSupportText, ControlHeight,
      ResolvedTokens);
  Redraw;
end;

procedure TDACComboBox.SetInputSize(const AValue: TDACInputSize);
begin
  { Match TDACEdit: the persisted enum remains for old DFMs, while all new
    and streamed instances use the one compact Small density. }
  if FInputSize = misSmall then
    Exit;

  FInputSize := misSmall;
  if not HasLabel and not HasSupportText then
    Height := ControlHeight
  else
    Height := DACFieldTotalHeight(HasLabel, HasSupportText, ControlHeight,
      ResolvedTokens);
  UpdateComboStyle;
  Redraw;
end;

procedure TDACComboBox.SetFocus;
begin
  if FLoading or not Enabled then
    Exit;
  if FStyle = csDropDownList then
  begin
    inherited SetFocus;
    Exit;
  end;
  AttachComboToHost;
  if (FCombo <> nil) and FCombo.Visible and FCombo.Enabled and
    FCombo.CanFocus then
    FCombo.SetFocus
  else if CanFocus then
    inherited;
end;

procedure TDACComboBox.SimulateDropDownClick(const AIndex: Integer);
begin
  if not CanModifyValue or (FCombo = nil) or
    (AIndex < 0) or (AIndex >= FItems.Count) then
    Exit;
  if not DropDownVisible then
    OpenDropDown;
  if not DropDownVisible then
    Exit;
  DropDownPaintBoxMouseUp(FDropDownPaintBox, mbLeft, [], 0,
    (AIndex * DropDownItemHeight) + (DropDownItemHeight div 2));
end;

procedure TDACComboBox.SimulateDropDownExternalDeactivate;
begin
  DropDownDeactivate(Self);
end;

procedure TDACComboBox.SimulateDropDownKey(const AKey: Word);
var
  LKey: Word;
begin
  LKey := AKey;
  DropDownKeyDown(Self, LKey, []);
end;

procedure TDACComboBox.SetItemIndex(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(-1, Min(AValue, FItems.Count - 1));
  if (FItemIndex = LValue) and
    (((LValue < 0) and (FText = '')) or
      ((LValue >= 0) and (FText = FItems[LValue]))) then
    Exit;
  FItemIndex := LValue;
  if FItemIndex >= 0 then
    FText := FItems[FItemIndex]
  else
    FText := '';
  SynchronizeNative;
  Redraw;
end;

procedure TDACComboBox.SetItems(const AValue: TStrings);
begin
  FItems.Assign(AValue);
end;

procedure TDACComboBox.SetLabelText(const AValue: string);
var
  LHadLabel: Boolean;
begin
  if FLabelText = AValue then
    Exit;

  LHadLabel := HasLabel;
  FLabelText := AValue;
  if (not LHadLabel) and HasLabel and (Height <= ControlHeight) then
    Height := DACFieldTotalHeight(HasLabel, HasSupportText, ControlHeight,
      ResolvedTokens);
  UpdateChildBounds;
  Redraw;
end;

procedure TDACComboBox.SetLoading(const AValue: Boolean);
begin
  if FLoading = AValue then
    Exit;
  FLoading := AValue;
  if AValue then
  begin
    DACFieldBeginLoadingTabPolicy(Self, FTabStopBeforeLoading,
      FLoadingTabStopCaptured);
    DACFieldRelinquishFocus(Self, FCombo);
    CloseDropDown;
  end
  else
    DACFieldEndLoadingTabPolicy(Self, FTabStopBeforeLoading,
      FLoadingTabStopCaptured);
  UpdateComboStyle;
  Redraw;
end;

procedure TDACComboBox.SetReadOnly(const AValue: Boolean);
begin
  if FReadOnly = AValue then
    Exit;
  FReadOnly := AValue;
  if FReadOnly then
    CloseDropDown;
  UpdateComboStyle;
  Redraw;
end;

procedure TDACComboBox.SetBindingCanModify(const AValue: Boolean);
begin
  if FBindingCanModify = AValue then
    Exit;
  FBindingCanModify := AValue;
  if not FBindingCanModify then
    CloseDropDown;
  UpdateComboStyle;
  Redraw;
end;

procedure TDACComboBox.SetRequired(const AValue: Boolean);
begin
  if FRequired = AValue then
    Exit;
  FRequired := AValue;
  Redraw;
end;

procedure TDACComboBox.SetStatus(const AValue: TDACEditStatus);
begin
  if FStatus = AValue then
    Exit;
  FStatus := AValue;
  Redraw;
end;

procedure TDACComboBox.SetStyle(const AValue: TComboBoxStyle);
begin
  if FStyle = AValue then
    Exit;
  FStyle := AValue;
  ResolveTextState(FText);
  SynchronizeNative;
  UpdateChildBounds;
end;

procedure TDACComboBox.SetText(const AValue: string);
begin
  ResolveTextState(AValue);
  SynchronizeNative;
  Redraw;
end;

procedure TDACComboBox.SetThemeMode(const AValue: TDACThemeMode);
begin
  if FThemeMode = AValue then
  begin
    ThemeChanged(Self);
    Exit;
  end;
  FThemeMode := AValue;
  ThemeChanged(Self);
end;

procedure TDACComboBox.ThemeChanged(Sender: TObject);
begin
  UpdateComboStyle;
  if DropDownVisible then
    CloseDropDown;
  Redraw;
end;

procedure TDACComboBox.SetVariant(const AValue: TDACInputVariant);
begin
  if FVariant = AValue then
    Exit;

  FVariant := AValue;
  UpdateComboStyle;
  Redraw;
end;

procedure TDACComboBox.ShowDropDown;
var
  LHeight: Integer;
  LItemCount: Integer;
  LPoint: TPoint;
begin
  if (csDesigning in ComponentState) or (csDestroying in ComponentState) or
    (csLoading in ComponentState) or not CanModifyValue or
    (FCombo = nil) then
    Exit;
  if (Parent = nil) or not HandleAllocated or not Parent.HandleAllocated then
    Exit;
  if FItems.Count = 0 then
    Exit;

  if FDropDownState in [cdsOpening, cdsOpen] then
    Exit;

  FDropDownState := cdsOpening;
  EnsureDropDown;
  LItemCount := Min(FItems.Count, Max(1, FDropDownCount));
  LHeight := LItemCount * DropDownItemHeight;
  LPoint := ClientToScreen(Point(0, ChromeTop + ControlHeight +
    Pixels(Round(ResolvedTokens.ComboBoxPopupOffset))));
  FDropDownHotIndex := FItemIndex;
  FDropDownForm.Color := ComboBoxVclColor(ResolvedTokens.ComboBoxPopupBackground);
  FDropDownForm.SetBounds(LPoint.X, LPoint.Y, Width, LHeight);
  FDropDownForm.Show;
  FDropDownForm.BringToFront;
  FDropDownState := cdsOpen;
  if FDropDownPaintBox <> nil then
    FDropDownPaintBox.Redraw;
  Redraw;
  if Assigned(FOnDropDown) then
    FOnDropDown(Self);
end;

procedure TDACComboBox.ToggleDropDown;
begin
  if DropDownVisible then
    CloseDropDown
  else
    ShowDropDown;
end;

procedure TDACComboBox.UpdateChildBounds;
var
  LHorizontalPadding: Integer;
  LInputHeight: Integer;
  LTextHeight: Integer;
  LTop: Integer;
  LTokens: TDACControlTokens;
begin
  if (FCombo = nil) or (csDestroying in ComponentState) then
    Exit;

  if csDesigning in ComponentState then
  begin
    { Never leave the native drop-down HWND parented to the form designer.
      It may otherwise repaint stale themed pixels over the Skia chrome. }
    FCombo.Visible := False;
    if FCombo.Parent <> nil then
      FCombo.Parent := nil;
    UpdateDesignValuePreview;
    UpdateNativeLabel;
    Exit;
  end;

  if csLoading in ComponentState then
    Exit;

  if not CanUpdateChildren then
    Exit;

  if FStyle = csDropDownList then
  begin
    { The list-style selector has no editable surface. Showing the native
      ComboBox here would also show its own button; a native label keeps the
      selected text crisp while Skia owns the arrow and border. }
    FCombo.Visible := False;
    FFieldText.SetFocusControl(Self);
    UpdateDesignValuePreview;
    UpdateNativeLabel;
    Exit;
  end;

  if FCombo.Parent <> Self then
    FCombo.Parent := Self;
  FCombo.Visible := True;
  FFieldText.SetFocusControl(FCombo);
  if FDesignValueLabel <> nil then
    FDesignValueLabel.Visible := False;

  LTokens := ResolvedTokens;
  LHorizontalPadding := Pixels(Round(LTokens.ComboBoxNativeHorizontalPadding));
  LInputHeight := Min(ControlHeight, Max(0, Height - ChromeTop));
  case FInputSize of
    misSmall: LTextHeight := Pixels(Round(LTokens.ComboBoxSmallEditorHeight));
    misLarge: LTextHeight := Pixels(Round(LTokens.ComboBoxLargeEditorHeight));
  else
    LTextHeight := Pixels(Round(LTokens.ComboBoxMediumEditorHeight));
  end;
  LTextHeight := Min(LInputHeight, LTextHeight);
  LTop := ChromeTop + Max(0, (LInputHeight - LTextHeight) div 2) +
    Pixels(Round(LTokens.InputNativeVerticalOffset));
  LTop := Min(ChromeTop + Max(0, LInputHeight - LTextHeight), LTop);
  FCombo.SetBounds(LHorizontalPadding, LTop,
    Max(0, Width - LHorizontalPadding), LTextHeight);
  TDACNativeComboBox(FCombo).DropDownClipWidth :=
    Pixels(Round(LTokens.ComboBoxNativeRightReserve));
  TDACNativeComboBox(FCombo).VerticalClipInset :=
    Pixels(Round(LTokens.ComboBoxNativeVerticalClipInset));
  // The native combo may negotiate a taller edit window for the active VCL
  // font. Center that effective height in the same 24..64 chrome used by
  // the other inputs instead of trusting the requested bounds height.
  FCombo.Top := ChromeTop + Max(0, (LInputHeight - FCombo.Height) div 2) +
    Pixels(Round(LTokens.InputNativeVerticalOffset));
  FCombo.Top := Min(ChromeTop + Max(0, LInputHeight - FCombo.Height),
    FCombo.Top);
  UpdateNativeLabel;
end;

procedure TDACComboBox.SynchronizeNative;
begin
  if FSyncingNative or (FCombo = nil) or not CanUpdateChildren then
    Exit;
  FSyncingNative := True;
  try
    if FCombo.Style <> FStyle then
      FCombo.Style := FStyle;
    FCombo.Items.Assign(FItems);
    FCombo.ItemIndex := FItemIndex;
    if FStyle = csDropDown then
    begin
      FCombo.Text := FText;
      FCombo.ItemIndex := FItemIndex;
    end;
  finally
    FSyncingNative := False;
  end;
end;

procedure TDACComboBox.UpdateNativeLabel;
begin
  if FFieldText = nil then
    Exit;
  FFieldText.Update(FLabelText, FHelperText, FErrorText, FCounterText,
    FRequired, ResolvedFieldState, Width, ChromeTop, ControlHeight,
    ResolvedTokens);
end;

procedure TDACComboBox.UpdateComboStyle;
var
  LTokens: TDACControlTokens;
  LTextColor: TColor;
begin
  if (FCombo = nil) or (csDestroying in ComponentState) then
    Exit;

  if csDesigning in ComponentState then
  begin
    UpdateDesignValuePreview;
    UpdateNativeLabel;
    Exit;
  end;

  if not CanUpdateChildren then
    Exit;

  LTokens := ResolvedTokens;
  FCombo.Enabled := Enabled and not FLoading;
  TDACNativeComboBox(FCombo).InteractionLocked :=
    not CanModifyValue;
  SynchronizeNative;
  FCombo.Visible := Showing;
  FCombo.TabStop := False;
  if FVariant = mivUnderlined then
    FCombo.Color := ComboBoxVclColor(LTokens.ComboBoxUnderlinedBackground)
  else
    FCombo.Color := ComboBoxVclColor(LTokens.ComboBoxBackground);
  if not Enabled or FLoading then
    FCombo.Color := ComboBoxVclColor(LTokens.ComboBoxDisabledBackground);
  FCombo.Font.Name := TDACComponentFontInstaller.FontFamily;
  FCombo.Font.Size := InputFontSize;
  FCombo.Font.Style := [];
  LTextColor := ComboBoxVclColor(LTokens.ComboBoxText);
  if not Enabled or FLoading then
    LTextColor := ComboBoxVclColor(LTokens.ComboBoxDisabledText);
  FCombo.Font.Color := LTextColor;
  { A native TComboBox can renegotiate its effective height after Font
    changes. Recenter that final height in the shared input chrome. }
  UpdateChildBounds;
  UpdateNativeLabel;
  UpdateZOrder;
  if not CanModifyValue then
    Cursor := crDefault;
  if FDropDownForm <> nil then
    FDropDownForm.Color := ComboBoxVclColor(LTokens.ComboBoxPopupBackground);
end;

procedure TDACComboBox.UpdateDesignValuePreview;
var
  LHorizontalPadding: Integer;
  LInputHeight: Integer;
  LTextHeight: Integer;
  LText: string;
  LTokens: TDACControlTokens;
  LTop: Integer;
begin
  if FDesignValueLabel = nil then
    Exit;
  if not (csDesigning in ComponentState) and (FStyle <> csDropDownList) then
  begin
    FDesignValueLabel.Visible := False;
    Exit;
  end;

  LTokens := ResolvedTokens;
  LText := FText;
  if (LText = '') and (FItemIndex >= 0) and (FItemIndex < FItems.Count) then
    LText := FItems[FItemIndex];
  FDesignValueLabel.Caption := LText;
  FDesignValueLabel.Font.Name := TDACComponentStyle.FontFamily;
  FDesignValueLabel.Font.Size := InputFontSize;
  FDesignValueLabel.Font.Style := [];
  if not Enabled or FLoading then
    FDesignValueLabel.Font.Color := ComboBoxVclColor(LTokens.ComboBoxDisabledText)
  else
    FDesignValueLabel.Font.Color := ComboBoxVclColor(LTokens.ComboBoxText);
  FDesignValueLabel.Visible := Showing and (LText <> '');

  LHorizontalPadding := Pixels(Round(LTokens.ComboBoxNativeHorizontalPadding));
  LInputHeight := Min(ControlHeight, Max(0, Height - ChromeTop));
  case FInputSize of
    misSmall: LTextHeight := Pixels(Round(LTokens.ComboBoxSmallEditorHeight));
    misLarge: LTextHeight := Pixels(Round(LTokens.ComboBoxLargeEditorHeight));
  else
    LTextHeight := Pixels(Round(LTokens.ComboBoxMediumEditorHeight));
  end;
  LTextHeight := Min(LInputHeight, LTextHeight);
  LTop := ChromeTop + Max(0, (LInputHeight - LTextHeight) div 2) +
    Pixels(Round(LTokens.InputNativeVerticalOffset));
  LTop := Min(ChromeTop + Max(0, LInputHeight - LTextHeight), LTop);
  FDesignValueLabel.SetBounds(LHorizontalPadding, LTop,
    Max(0, Width - LHorizontalPadding -
      Pixels(Round(LTokens.ComboBoxNativeRightReserve))), LTextHeight);
end;

procedure TDACComboBox.UpdatePaintBoxBounds;
var
  LWidth: Integer;
  LHeight: Integer;
  LTop: Integer;
begin
  if (FPaintBox = nil) or (csDestroying in ComponentState) or
    ((csLoading in ComponentState) and not (csDesigning in ComponentState)) then
    Exit;

  { Width/Height work while the component is being streamed into the form
    designer. Reading ClientRect here could force an invalid HWND chain. }
  LWidth := Width;
  LHeight := Height;
  if not (csDesigning in ComponentState) and HandleAllocated then
  begin
    LWidth := ClientWidth;
    LHeight := ClientHeight;
  end;

  LTop := ChromeTop;
  { Only the selector chrome is Skia-backed.  Label/helper rows must retain
    the host surface painted by VCL and cannot be cleared by this child. }
  LHeight := Min(ControlHeight, Max(0, LHeight - LTop));
  if (FPaintBox.Left <> 0) or (FPaintBox.Top <> LTop) or
    (FPaintBox.Width <> LWidth) or (FPaintBox.Height <> LHeight) then
    FPaintBox.SetBounds(0, LTop, LWidth, LHeight);
end;

procedure TDACComboBox.UpdateZOrder;
begin
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    Exit;
  if csDesigning in ComponentState then
    Exit;
  if (Parent = nil) or not HandleAllocated or not Parent.HandleAllocated or
    not Showing then
    Exit;

  if FPaintBox <> nil then
    FPaintBox.SendToBack;
  if FCombo <> nil then
    FCombo.BringToFront;
  if FDesignValueLabel <> nil then
    FDesignValueLabel.BringToFront;
end;

procedure TDACComboBox.WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
begin
  inherited;
end;

procedure TDACComboBox.WMSetFocus(var AMessage: TWMSetFocus);
begin
  inherited;
  if FLoading or not Enabled then
  begin
    DACFieldRelinquishFocus(Self, FCombo);
    Exit;
  end;
  if not NativeFocused then
    SetFocus;
end;

end.

