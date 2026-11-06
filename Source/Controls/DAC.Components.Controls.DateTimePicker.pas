unit DAC.Components.Controls.DateTimePicker;

interface

uses
  System.Classes,
  System.SysUtils,
  System.Types,
  System.UITypes,
  Winapi.Messages,
  Vcl.ComCtrls,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.Mask,
  DAC.Components.Controls.Button,
  DAC.Components.Controls.DateTimePickerPopup,
  DAC.Components.Controls.Edit,
  DAC.Components.Controls.FieldSupport,
  DAC.Components.DesignSystem.ControlTokens,
  DAC.Components.DesignSystem.IconAssets,
  DAC.Components.DesignSystem.Theme;

type
{$IFDEF DAC_TESTING}
  { Compatibility record for old diagnostics. The editor is now the canonical
    TMaskEdit owned by TDACEdit, so no SysDateTimePick32 paint path exists. }
  TDACNativeDateTimePickerPaintMetrics = record
    BufferAllocations: Cardinal;
    BufferResizes: Cardinal;
    HandleGenerations: Cardinal;
    NativeRenders: Cardinal;
    Paints: Cardinal;
    Presents: Cardinal;
    MaxMicroseconds: Int64;
    P95Microseconds: Int64;
  end;
{$ENDIF}

  TDACDateTimePicker = class(TDACEdit)
  private
    FActionButton: TDACButton;
    FAllowNull: Boolean;
    FBindingCanModify: Boolean;
    FDateTime: TDateTime;
    FFormatString: string;
    FInternalTextUpdate: Boolean;
    FIsNull: Boolean;
    FOnCloseUp: TNotifyEvent;
    FOnDropDown: TNotifyEvent;
    FPickerKind: TDateTimeKind;
    FPopup: TDACDateTimePickerPopup;
    FPopupActive: Boolean;
    FTimeStepMinutes: Integer;
    function BuildEditMask: string;
    function CanModifyValue: Boolean;
    function CommitEditorValue: Boolean;
    procedure ActionClick(Sender: TObject);
    procedure ActionEnter(Sender: TObject);
    procedure ActionMouseEnter(Sender: TObject);
    procedure ActionMouseLeave(Sender: TObject);
    procedure CMEnabledChanged(var AMessage: TMessage); message CM_ENABLEDCHANGED;
    procedure CMParentColorChanged(var AMessage: TMessage); message CM_PARENTCOLORCHANGED;
    procedure CMParentFontChanged(var AMessage: TMessage); message CM_PARENTFONTCHANGED;
    procedure CMVisibleChanged(var AMessage: TMessage); message CM_VISIBLECHANGED;
    procedure ClosePopup;
    procedure ConfigureEditor;
    procedure EditorKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    function FormatValue(const AValue: TDateTime): string;
    function GetCornerRadiusValue: Integer;
    function GetDateTime: TDateTime;
    function GetFormatString: string;
    function GetLoadingValue: Boolean;
    function GetPickerControl: TMaskEdit;
    function GetReadOnlyValue: Boolean;
    function GetThemeModeValue: TDACThemeMode;
    function IsEditorComplete: Boolean;
{$IFDEF DAC_TESTING}
    function GetNativePresentationPending: Boolean;
{$ENDIF}
    procedure PopupAccept(Sender: TObject);
    procedure PopupCancel(Sender: TObject);
    procedure PopupClear(Sender: TObject);
    procedure PopupHide(Sender: TObject);
    procedure ResolveInputActionSurface(const ASender: TObject;
      out AColor: TAlphaColor);
    function ResolvedPopupThemeMode: TDACThemeMode;
    function ResolvedTokens: TDACControlTokens;
    procedure SetAllowNull(const AValue: Boolean);
    procedure SetCornerRadiusValue(const AValue: Integer);
    procedure SetDateTime(const AValue: TDateTime);
    procedure SetEditorText(const AText: string);
    procedure SetFormatString(const AValue: string);
    procedure SetIsNull(const AValue: Boolean);
    procedure SetLoadingValue(const AValue: Boolean);
    procedure SetPickerKind(const AValue: TDateTimeKind);
    procedure SetReadOnlyValue(const AValue: Boolean);
    procedure SetThemeModeValue(const AValue: TDACThemeMode);
    procedure SetTimeStepMinutes(const AValue: Integer);
    procedure ShowCalendarPopup;
    function TryTextToValue(const AText: string; out AValue: TDateTime): Boolean;
    function TryReadEditedDateTime(const AText: string; out AValue: TDateTime): Boolean;
    function IntrinsicDateError(const AText: string): string;
    procedure UpdateActionLayout;
    procedure UpdateActionState;
    procedure UpdateEditorText;
  protected
    procedure Change; override;
    function CanValidateEditorExit: Boolean; override;
    function IntrinsicValidator: TDACFieldIntrinsicValidator; override;
    procedure CreateWnd; override;
    procedure DoAcceptValue(const AValue: TDateTime); virtual;
    procedure DoClearValue; virtual;
    procedure Loaded; override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
    procedure Resize; override;
    procedure SetBindingCanModify(const AValue: Boolean);
    procedure SetBindingDisplayNull(const AValue: Boolean);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function PopupDisplayMonth: TDateTime;
    function PopupSelectedDateTime: TDateTime;
    function PopupVisible: Boolean;
    function TryGetEditedDateTime(out AValue: TDateTime): Boolean;
    function ResolvedPopupBackground: TAlphaColor;
    procedure OpenPopup;
    procedure RequestNativePickerActivation;
    procedure SimulatePopupDayClick(const ADay: Integer);
    procedure SimulatePopupExternalDeactivate;
    procedure SimulatePopupFooter(const AAction: Integer);
    procedure SimulatePopupKey(const AKey: Word);
    property ActionButton: TDACButton read FActionButton;
    { Compatibility alias. The editable native child is now the TMaskEdit
      inherited from TDACEdit; no SysDateTimePick32 is created. }
    property PickerControl: TMaskEdit read GetPickerControl;
{$IFDEF DAC_TESTING}
    property NativePresentationPending: Boolean
      read GetNativePresentationPending;
{$ENDIF}
  published
    property AllowNull: Boolean read FAllowNull write SetAllowNull default False;
    property CornerRadius: Integer read GetCornerRadiusValue
      write SetCornerRadiusValue default DACDateTimeDefaultCornerRadius;
    property DateTime: TDateTime read GetDateTime write SetDateTime;
    property FormatString: string read GetFormatString write SetFormatString;
    property IsNull: Boolean read FIsNull write SetIsNull default False;
    property Loading: Boolean read GetLoadingValue write SetLoadingValue default False;
    property PickerKind: TDateTimeKind read FPickerKind write SetPickerKind default dtkDate;
    property ReadOnly: Boolean read GetReadOnlyValue write SetReadOnlyValue default False;
    property ThemeMode: TDACThemeMode read GetThemeModeValue
      write SetThemeModeValue default dtmInherit;
    property TimeStepMinutes: Integer read FTimeStepMinutes
      write SetTimeStepMinutes default 5;
    property OnCloseUp: TNotifyEvent read FOnCloseUp write FOnCloseUp;
    property OnDropDown: TNotifyEvent read FOnDropDown write FOnDropDown;
  end;

function DACNativeDateTimePickerClass: TWinControlClass;
{$IFDEF DAC_TESTING}
procedure DACNativeDateTimePickerCapturePipeline(
  const AControl: TWinControl; const APreRemap, APostRemap,
  AFinal: Vcl.Graphics.TBitmap);
function DACNativeDateTimePickerFocusedPaintDelegations(
  const AControl: TWinControl): Cardinal;
function DACNativeDateTimePickerPaintMetrics(
  const AControl: TWinControl): TDACNativeDateTimePickerPaintMetrics;
procedure DACNativeDateTimePickerResetPaintMetrics(
  const AControl: TWinControl);
{$ENDIF}

implementation

uses
  System.DateUtils,
  System.MaskUtils,
  System.Math,
  Winapi.Windows,
  DAC.Components.DesignSystem.ComponentStyle;

function DACNativeDateTimePickerClass: TWinControlClass;
begin
  Result := TMaskEdit;
end;

{$IFDEF DAC_TESTING}
procedure DACNativeDateTimePickerCapturePipeline(
  const AControl: TWinControl; const APreRemap, APostRemap,
  AFinal: Vcl.Graphics.TBitmap);
var
  LBitmap: Vcl.Graphics.TBitmap;
begin
  if (AControl = nil) or (APreRemap = nil) or (APostRemap = nil) or
    (AFinal = nil) then
    Exit;
  LBitmap := Vcl.Graphics.TBitmap.Create;
  try
    LBitmap.SetSize(Max(1, AControl.ClientWidth),
      Max(1, AControl.ClientHeight));
    LBitmap.Canvas.Brush.Color := clWindow;
    LBitmap.Canvas.FillRect(Rect(0, 0, LBitmap.Width, LBitmap.Height));
    if AControl.HandleAllocated then
      AControl.PaintTo(LBitmap.Canvas.Handle, 0, 0);
    APreRemap.Assign(LBitmap);
    APostRemap.Assign(LBitmap);
    AFinal.Assign(LBitmap);
  finally
    LBitmap.Free;
  end;
end;

function DACNativeDateTimePickerFocusedPaintDelegations(
  const AControl: TWinControl): Cardinal;
begin
  Result := 0;
end;

function DACNativeDateTimePickerPaintMetrics(
  const AControl: TWinControl): TDACNativeDateTimePickerPaintMetrics;
begin
  FillChar(Result, SizeOf(Result), 0);
end;

procedure DACNativeDateTimePickerResetPaintMetrics(
  const AControl: TWinControl);
begin
end;
{$ENDIF}

constructor TDACDateTimePicker.Create(AOwner: TComponent);
var
  LTokens: TDACControlTokens;
begin
  inherited Create(AOwner);
  LTokens := ResolvedTokens;
  FBindingCanModify := True;
  FPickerKind := dtkDate;
  FTimeStepMinutes := Max(1, Round(LTokens.DateTimeTimeStepMinutes));
  FDateTime := EncodeDate(2025, 5, 24) + EncodeTime(14, 35, 0, 0);
  Width := Round(LTokens.DateTimeDefaultWidth);
  Constraints.MinWidth := Round(LTokens.DateTimeDefaultWidth);
  Height := Round(LTokens.DateTimeDefaultHeight);

  FActionButton := TDACButton.Create(Self);
  FActionButton.Parent := Self;
  FActionButton.SetSubComponent(True);
  FActionButton.Caption := '';
  FActionButton.Kind := mbkInputAction;
  FActionButton.IconKind := mikCalendar;
  FActionButton.ShowIcon := True;
  FActionButton.Size := mbsMedium;
  FActionButton.TabStop := False;
  FActionButton.Cursor := crHandPoint;
  FActionButton.CornerRadius := Round(LTokens.ButtonEditButtonCornerRadius);
  FActionButton.SetInputActionOuterCornerRadius(CornerRadius);
  FActionButton.SetInputActionSurfaceProvider(ResolveInputActionSurface);
  FActionButton.OnClick := ActionClick;
  FActionButton.OnEnter := ActionEnter;
  FActionButton.OnMouseEnter := ActionMouseEnter;
  FActionButton.OnMouseLeave := ActionMouseLeave;

  { The composite host is the only dialog tab stop. The native TMaskEdit still
    receives caret focus programmatically, matching TDACButtonEdit. }
  EditControl.TabStop := False;
  EditControl.OnKeyDown := EditorKeyDown;
  ConfigureEditor;
  UpdateEditorText;
  UpdateActionState;
  UpdateActionLayout;
end;

destructor TDACDateTimePicker.Destroy;
begin
  if FPopup <> nil then
  begin
    FPopup.OnAccept := nil;
    FPopup.OnCancel := nil;
    FPopup.OnClear := nil;
    FPopup.OnHide := nil;
    FPopup.RemoveFreeNotification(Self);
    FreeAndNil(FPopup);
  end;
  FreeAndNil(FActionButton);
  inherited;
end;

procedure TDACDateTimePicker.ActionClick(Sender: TObject);
begin
  SetFocus;
  ShowCalendarPopup;
end;

procedure TDACDateTimePicker.ActionEnter(Sender: TObject);
begin
  SetFocus;
end;

procedure TDACDateTimePicker.ActionMouseEnter(Sender: TObject);
begin
  SetCompositeMouseInside(True);
end;

procedure TDACDateTimePicker.ActionMouseLeave(Sender: TObject);
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

function TDACDateTimePicker.BuildEditMask: string;
var
  I: Integer;
  LFormat: string;
  LQuoted: Boolean;
begin
  LFormat := FFormatString;
  if LFormat = '' then
  begin
    if FPickerKind = dtkTime then
      LFormat := FormatSettings.ShortTimeFormat
    else
      LFormat := FormatSettings.ShortDateFormat;
  end;

  Result := '';
  LQuoted := False;
  for I := 1 to Length(LFormat) do
  begin
    if LFormat[I] = '''' then
    begin
      LQuoted := not LQuoted;
      Continue;
    end;
    if not LQuoted and CharInSet(LFormat[I],
      ['d', 'D', 'm', 'M', 'y', 'Y', 'h', 'H', 'n', 'N', 's', 'S']) then
      Result := Result + '0'
    else
      Result := Result + LFormat[I];
  end;
  Result := '!' + Result + ';1;_';
end;

function TDACDateTimePicker.CanModifyValue: Boolean;
begin
  Result := Enabled and not Loading and not ReadOnly and FBindingCanModify;
end;

function TDACDateTimePicker.CommitEditorValue: Boolean;
var
  LChanged: Boolean;
  LText: string;
  LValue: TDateTime;
begin
  if FInternalTextUpdate then
    Exit(True);

  Result := False;
  LText := ValidationText;
  if Trim(LText) = '' then
  begin
    if not FAllowNull then
      Exit;
    LChanged := not FIsNull;
    FIsNull := True;
  end
  else
  begin
    if not TryReadEditedDateTime(LText, LValue) then
      Exit;
    LChanged := FIsNull or not SameValue(FDateTime, LValue);
    FDateTime := LValue;
    FIsNull := False;
  end;

  Result := True;
  if LChanged then
    inherited Change
  else
  begin
    ValidateChange;
    Redraw;
  end;
end;

function TDACDateTimePicker.TryGetEditedDateTime(out AValue: TDateTime): Boolean;
begin
  Result := TryReadEditedDateTime(ValidationText, AValue);
end;

function TDACDateTimePicker.TryReadEditedDateTime(const AText: string;
  out AValue: TDateTime): Boolean;
begin
  { The regional parser alone can interpret a partial year as a full year. }
  AValue := 0;
  Result := (Trim(AText) <> '') and IsEditorComplete and
    TryTextToValue(AText, AValue);
end;

function TDACDateTimePicker.CanValidateEditorExit: Boolean;
begin
  Result := not FPopupActive and inherited CanValidateEditorExit;
end;

function TDACDateTimePicker.IntrinsicValidator: TDACFieldIntrinsicValidator;
begin
  Result := IntrinsicDateError;
end;

function TDACDateTimePicker.IntrinsicDateError(const AText: string): string;
var
  LValue: TDateTime;
begin
  Result := '';
  if (Trim(AText) = '') and FAllowNull then
    Exit;
  if TryReadEditedDateTime(AText, LValue) then
    Exit;
  if FPickerKind = dtkTime then
    Result := 'Informe uma hora completa e v' + #225 + 'lida.'
  else
    Result := 'Informe uma data completa e v' + #225 + 'lida.';
end;

procedure TDACDateTimePicker.Change;
begin
  if FInternalTextUpdate then
    Exit;
  if not CommitEditorValue then
    ValidateChange;
end;

procedure TDACDateTimePicker.CMEnabledChanged(var AMessage: TMessage);
begin
  inherited;
  if not Enabled then
    ClosePopup;
  UpdateActionState;
end;

procedure TDACDateTimePicker.CMParentColorChanged(var AMessage: TMessage);
begin
  inherited;
  if FActionButton <> nil then
    FActionButton.ThemeMode := ThemeMode;
  UpdateActionLayout;
end;

procedure TDACDateTimePicker.CMParentFontChanged(var AMessage: TMessage);
begin
  inherited;
  UpdateActionLayout;
end;

procedure TDACDateTimePicker.CMVisibleChanged(var AMessage: TMessage);
begin
  inherited;
  if not Visible then
    ClosePopup;
end;

procedure TDACDateTimePicker.ClosePopup;
begin
  if (FPopup <> nil) and FPopup.Visible then
    FPopup.Hide;
  FPopupActive := False;
  Redraw;
end;

procedure TDACDateTimePicker.ConfigureEditor;
begin
  { A format/kind transition can make the currently displayed value invalid
    for the next mask. Remove the old mask and text under the internal-change
    guard before installing the new contract; UpdateEditorText restores the
    authoritative FDateTime immediately afterwards. }
  FInternalTextUpdate := True;
  try
    TDACEdit(Self).EditMask := '';
    TDACEdit(Self).Text := '';
    TDACEdit(Self).EditKind := mekMasked;
    TDACEdit(Self).EditMask := BuildEditMask;
  finally
    FInternalTextUpdate := False;
  end;
  EditControl.OnKeyDown := EditorKeyDown;
  if FPickerKind = dtkTime then
    FActionButton.IconKind := mikClock
  else
    FActionButton.IconKind := mikCalendar;
end;

procedure TDACDateTimePicker.CreateWnd;
begin
  inherited;
  UpdateActionState;
  UpdateActionLayout;
end;

procedure TDACDateTimePicker.DoAcceptValue(const AValue: TDateTime);
var
  LChanged: Boolean;
begin
  if not CanModifyValue then
    Exit;
  LChanged := FIsNull or not SameValue(FDateTime, AValue);
  FDateTime := AValue;
  FIsNull := False;
  UpdateEditorText;
  if LChanged then
    inherited Change
  else
    ValidateChange;
end;

procedure TDACDateTimePicker.DoClearValue;
var
  LChanged: Boolean;
begin
  if not CanModifyValue then
    Exit;
  if not FAllowNull then
  begin
    DoAcceptValue(0);
    Exit;
  end;
  LChanged := not FIsNull or (Text <> '');
  FIsNull := True;
  UpdateEditorText;
  if LChanged then
    inherited Change;
end;

procedure TDACDateTimePicker.EditorKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if ((Key = VK_F4) or ((Key = VK_DOWN) and (ssAlt in Shift))) and
    CanModifyValue then
  begin
    ShowCalendarPopup;
    Key := 0;
    Exit;
  end;
  if (Key = VK_ESCAPE) and PopupVisible then
  begin
    ClosePopup;
    Key := 0;
    Exit;
  end;
  if Assigned(OnKeyDown) then
    OnKeyDown(Self, Key, Shift);
end;

function TDACDateTimePicker.FormatValue(const AValue: TDateTime): string;
begin
  if FFormatString <> '' then
    Exit(FormatDateTime(FFormatString, AValue));
  if FPickerKind = dtkTime then
    Result := FormatDateTime(FormatSettings.ShortTimeFormat, AValue)
  else
    Result := DateToStr(AValue);
end;

function TDACDateTimePicker.GetCornerRadiusValue: Integer;
begin
  Result := TDACEdit(Self).CornerRadius;
end;

function TDACDateTimePicker.GetDateTime: TDateTime;
begin
  Result := FDateTime;
end;

function TDACDateTimePicker.GetFormatString: string;
begin
  Result := FFormatString;
end;

function TDACDateTimePicker.GetLoadingValue: Boolean;
begin
  Result := TDACEdit(Self).Loading;
end;

function TDACDateTimePicker.GetPickerControl: TMaskEdit;
begin
  Result := EditControl;
end;

function TDACDateTimePicker.GetReadOnlyValue: Boolean;
begin
  Result := TDACEdit(Self).ReadOnly;
end;

function TDACDateTimePicker.GetThemeModeValue: TDACThemeMode;
begin
  Result := TDACEdit(Self).ThemeMode;
end;

function TDACDateTimePicker.IsEditorComplete: Boolean;
var
  I: Integer;
  LMask: string;
  LOffset: Integer;
  LText: string;
begin
  LMask := EditControl.EditMask;
  if LMask = '' then
    LMask := BuildEditMask;
  LText := EditControl.EditText;
  LOffset := 1;
  for I := 1 to Length(LMask) do
    case MaskGetCharType(LMask, I) of
      mcLiteral, mcIntlLiteral, mcMaskOpt:
        Inc(LOffset);
      mcMask:
        begin
          if (LOffset > Length(LText)) or
            (LText[LOffset] = MaskGetMaskBlank(LMask)) or
            (LText[LOffset] = ' ') then
            Exit(False);
          Inc(LOffset);
        end;
    end;
  Result := True;
end;

{$IFDEF DAC_TESTING}
function TDACDateTimePicker.GetNativePresentationPending: Boolean;
begin
  Result := False;
end;
{$ENDIF}

procedure TDACDateTimePicker.Loaded;
begin
  inherited;
  ConfigureEditor;
  UpdateEditorText;
  UpdateActionState;
  UpdateActionLayout;
end;

procedure TDACDateTimePicker.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  { TCustomControl can finish its native mouse-focus processing after
    TDACEdit.MouseDown has focused the child. Reassert the canonical editor on
    release so clicks on the border/chrome always leave the caret in TMaskEdit. }
  if (Button = mbLeft) and Enabled and not Loading then
    SetFocus;
end;

procedure TDACDateTimePicker.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FPopup) then
  begin
    FPopup := nil;
    FPopupActive := False;
  end;
end;

procedure TDACDateTimePicker.OpenPopup;
begin
  ShowCalendarPopup;
end;

procedure TDACDateTimePicker.PopupAccept(Sender: TObject);
begin
  if (FPopup <> nil) and CanModifyValue then
    DoAcceptValue(FPopup.SelectedDateTime);
  SetFocus;
end;

procedure TDACDateTimePicker.PopupCancel(Sender: TObject);
begin
  SetFocus;
end;

procedure TDACDateTimePicker.PopupClear(Sender: TObject);
begin
  DoClearValue;
  SetFocus;
end;

function TDACDateTimePicker.PopupDisplayMonth: TDateTime;
begin
  if FPopup <> nil then
    Result := FPopup.DisplayMonth
  else
    Result := StartOfTheMonth(FDateTime);
end;

procedure TDACDateTimePicker.PopupHide(Sender: TObject);
begin
  FPopupActive := False;
  Redraw;
  if Assigned(FOnCloseUp) then
    FOnCloseUp(Self);
end;

function TDACDateTimePicker.PopupSelectedDateTime: TDateTime;
begin
  if FPopup <> nil then
    Result := FPopup.SelectedDateTime
  else
    Result := FDateTime;
end;

function TDACDateTimePicker.PopupVisible: Boolean;
begin
  Result := (FPopup <> nil) and FPopup.Visible;
end;

procedure TDACDateTimePicker.RequestNativePickerActivation;
begin
  { Compatibility entry point. There is no delayed native-picker lifecycle
    anymore; the inherited TMaskEdit is attached by TDACEdit. }
  UpdateActionLayout;
end;

procedure TDACDateTimePicker.ResolveInputActionSurface(
  const ASender: TObject; out AColor: TAlphaColor);
begin
  AColor := ResolvedInputSurfaceColor;
end;

function TDACDateTimePicker.ResolvedPopupBackground: TAlphaColor;
begin
  if FPopup <> nil then
    Result := FPopup.ResolvedBackground
  else
    Result := ResolvedTokens.DateTimePopupBackground;
end;

function TDACDateTimePicker.ResolvedPopupThemeMode: TDACThemeMode;
begin
  if ThemeMode <> dtmInherit then
    Exit(ThemeMode);
  if ResolvedTokens.DateTimePopupBackground =
    TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.DateTimePopupBackground then
    Result := dtmLight
  else
    Result := dtmDark;
end;

function TDACDateTimePicker.ResolvedTokens: TDACControlTokens;
begin
  Result := TDACComponentStyle.ResolveForSurface(Self,
    TDACEdit(Self).ThemeMode).Tokens.Controls;
end;

procedure TDACDateTimePicker.Resize;
begin
  inherited;
  UpdateActionLayout;
end;

procedure TDACDateTimePicker.SetAllowNull(const AValue: Boolean);
begin
  if FAllowNull = AValue then
    Exit;
  FAllowNull := AValue;
  if not FAllowNull and FIsNull then
  begin
    FIsNull := False;
    UpdateEditorText;
  end;
end;

procedure TDACDateTimePicker.SetBindingCanModify(const AValue: Boolean);
begin
  if FBindingCanModify = AValue then
    Exit;
  FBindingCanModify := AValue;
  inherited SetBindingCanModify(AValue);
  if not FBindingCanModify then
    ClosePopup;
  UpdateActionState;
end;

procedure TDACDateTimePicker.SetBindingDisplayNull(const AValue: Boolean);
begin
  FIsNull := AValue;
  UpdateEditorText;
end;

procedure TDACDateTimePicker.SetCornerRadiusValue(const AValue: Integer);
begin
  TDACEdit(Self).CornerRadius := AValue;
  if FActionButton <> nil then
    FActionButton.SetInputActionOuterCornerRadius(AValue);
  UpdateActionLayout;
end;

procedure TDACDateTimePicker.SetDateTime(const AValue: TDateTime);
begin
  FDateTime := AValue;
  FIsNull := False;
  UpdateEditorText;
  Redraw;
end;

procedure TDACDateTimePicker.SetEditorText(const AText: string);
begin
  FInternalTextUpdate := True;
  try
    if AText = '' then
    begin
      { A required TMaskEdit mask rejects an empty assignment. Null is a
        semantic DateTime state, so remove only the editing mask while empty;
        UpdateEditorText reinstalls it before the next valid value. }
      TDACEdit(Self).EditMask := '';
      TDACEdit(Self).Text := '';
    end
    else
    begin
      try
        TDACEdit(Self).Text := AText;
      except
        on E: EDBEditError do
        begin
          { Custom FormatString values can contain literals that do not map
            one-to-one to a TMaskEdit mask. Keep the native editor usable and
            preserve the formatted value instead of rejecting the property. }
          TDACEdit(Self).EditMask := '';
          TDACEdit(Self).Text := AText;
        end;
      end;
    end;
  finally
    FInternalTextUpdate := False;
  end;
end;

procedure TDACDateTimePicker.SetFormatString(const AValue: string);
begin
  if FFormatString = AValue then
  begin
    UpdateEditorText;
    Exit;
  end;
  FFormatString := AValue;
  ConfigureEditor;
  UpdateEditorText;
  UpdateActionLayout;
end;

procedure TDACDateTimePicker.SetIsNull(const AValue: Boolean);
begin
  if AValue and not FAllowNull then
    Exit;
  if FIsNull = AValue then
  begin
    UpdateEditorText;
    Exit;
  end;
  FIsNull := AValue;
  UpdateEditorText;
end;

procedure TDACDateTimePicker.SetLoadingValue(const AValue: Boolean);
begin
  TDACEdit(Self).Loading := AValue;
  if AValue then
    ClosePopup;
  UpdateActionState;
end;

procedure TDACDateTimePicker.SetPickerKind(const AValue: TDateTimeKind);
begin
  if FPickerKind = AValue then
  begin
    UpdateEditorText;
    Exit;
  end;
  FPickerKind := AValue;
  ConfigureEditor;
  UpdateEditorText;
  UpdateActionLayout;
end;

procedure TDACDateTimePicker.SetReadOnlyValue(const AValue: Boolean);
begin
  TDACEdit(Self).ReadOnly := AValue;
  if AValue then
    ClosePopup;
  UpdateActionState;
end;

procedure TDACDateTimePicker.SetThemeModeValue(const AValue: TDACThemeMode);
begin
  TDACEdit(Self).ThemeMode := AValue;
  if FActionButton <> nil then
    FActionButton.ThemeMode := AValue;
  if FPopup <> nil then
    FPopup.ApplyThemeMode(ResolvedPopupThemeMode);
  UpdateActionLayout;
end;

procedure TDACDateTimePicker.SetTimeStepMinutes(const AValue: Integer);
begin
  FTimeStepMinutes := Max(1, AValue);
end;

procedure TDACDateTimePicker.ShowCalendarPopup;
var
  LPopupValue: TDateTime;
begin
  if not CanModifyValue or FPopupActive or
    (csDesigning in ComponentState) or (csLoading in ComponentState) or
    (csDestroying in ComponentState) or (Parent = nil) or
    not HandleAllocated or not Parent.HandleAllocated then
    Exit;

  { Commit the text synchronously before the popup opens. This keeps the
    highlighted calendar day aligned with the value that the user just typed,
    including the click that transfers focus to the action button. }
  { An incomplete/invalid mask must not make the calendar button inert. When
    parsing succeeds FDateTime is refreshed; otherwise the popup keeps the
    last valid authoritative value and leaves the text available for repair. }
  CommitEditorValue;

  if FIsNull then
    LPopupValue := Date
  else
    LPopupValue := FDateTime;

  FPopupActive := True;
  try
    if FPopup = nil then
    begin
      FPopup := TDACDateTimePickerPopup.Create(Self);
      FPopup.FreeNotification(Self);
      FPopup.OnAccept := PopupAccept;
      FPopup.OnCancel := PopupCancel;
      FPopup.OnClear := PopupClear;
      FPopup.OnHide := PopupHide;
    end;
    FPopup.ShowFor(Self, ResolvedPopupThemeMode, FPickerKind, LPopupValue,
      FTimeStepMinutes);
    FPopupActive := FPopup.Visible;
    if FPopupActive and Assigned(FOnDropDown) then
      FOnDropDown(Self);
  finally
    if not PopupVisible then
    begin
      FPopupActive := False;
      Redraw;
    end;
  end;
end;

procedure TDACDateTimePicker.SimulatePopupDayClick(const ADay: Integer);
begin
  if FPopup <> nil then
    FPopup.SimulateDayClick(ADay);
end;

procedure TDACDateTimePicker.SimulatePopupExternalDeactivate;
begin
  if FPopup <> nil then
    FPopup.SimulateExternalDeactivate;
end;

procedure TDACDateTimePicker.SimulatePopupFooter(const AAction: Integer);
begin
  if FPopup <> nil then
    FPopup.SimulateFooterAction(AAction);
end;

procedure TDACDateTimePicker.SimulatePopupKey(const AKey: Word);
begin
  if FPopup <> nil then
    FPopup.SimulateKey(AKey);
end;

function TDACDateTimePicker.TryTextToValue(const AText: string;
  out AValue: TDateTime): Boolean;
var
  LParsed: TDateTime;
begin
  if FPickerKind = dtkTime then
  begin
    Result := TryStrToTime(Trim(AText), LParsed);
    if Result then
      AValue := DateOf(FDateTime) + TimeOf(LParsed);
  end
  else
  begin
    Result := TryStrToDate(Trim(AText), LParsed);
    if not Result then
      Result := TryStrToDateTime(Trim(AText), LParsed);
    if Result then
      AValue := DateOf(LParsed) + TimeOf(FDateTime);
  end;
end;

procedure TDACDateTimePicker.UpdateActionLayout;
var
  LButtonLeft: Integer;
  LButtonWidth: Integer;
  LChromeHeight: Integer;
  LChromeTop: Integer;
  LOuterInset: Integer;
  LRight: Integer;
  LTokens: TDACControlTokens;
begin
  if (FActionButton = nil) or (csLoading in ComponentState) or
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
  LButtonWidth := Min(Round(LTokens.ButtonEditDefaultButtonWidth),
    Max(0, LRight - LOuterInset));
  LButtonLeft := Max(LOuterInset, LRight - LButtonWidth);

  RightContentReserve := Max(0, Width - LButtonLeft);
  FActionButton.SetBounds(LButtonLeft, LChromeTop + LOuterInset,
    LButtonWidth, Max(0, LChromeHeight - (LOuterInset * 2)));
  FActionButton.SetInputActionOuterCornerRadius(CornerRadius);
  if csDesigning in ComponentState then
  begin
    FActionButton.Invalidate;
    Invalidate;
    Exit;
  end;
  FActionButton.BringToFront;
  FActionButton.Redraw;
end;

procedure TDACDateTimePicker.UpdateActionState;
begin
  if FActionButton = nil then
    Exit;
  FActionButton.Loading := Loading;
  FActionButton.Enabled := CanModifyValue;
end;

procedure TDACDateTimePicker.UpdateEditorText;
begin
  if FIsNull then
    SetEditorText('')
  else
  begin
    if TDACEdit(Self).EditMask <> BuildEditMask then
      ConfigureEditor;
    SetEditorText(FormatValue(FDateTime));
  end;
  { TDACEdit's native designer presenter is updated from Redraw rather than
    from the detached TMaskEdit HWND. Keep DateTime/format/null assignments
    immediately visible in both designer and runtime. }
  Redraw;
end;

end.
