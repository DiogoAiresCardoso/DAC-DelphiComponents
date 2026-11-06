unit DAC.Components.Controls.FieldSupport;

interface

uses
  System.Classes,
  System.SysUtils,
  System.UITypes,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.StdCtrls,
  DAC.Components.DesignSystem.ControlTokens;

type
  TDACFieldAvailability = (mfaEditable, mfaReadOnly, mfaLoading, mfaDisabled);
  TDACFieldValidation = (mfvNormal, mfvSuccess, mfvWarning, mfvDanger);
  TDACFieldInteraction = (mfiRest, mfiHover, mfiFocused);
  TDACFieldContent = (mfcEmpty, mfcFilled);
  TDACFieldValidationTrigger = (mfvtExplicit, mfvtChange, mfvtExit);
  { Set AErrorText to a nonempty message to reject the current value. }
  TDACFieldValidateEvent = procedure(Sender: TObject; const AText: string;
    var AErrorText: string) of object;
  TDACFieldIntrinsicValidator = function(const AText: string): string of object;

  TDACFieldValidator = record
  private
    FRunning: Boolean;
    FShowOnChange: Boolean;
  public
    function TryValidate(const AHost: TWinControl; const AText: string;
      const AValidator: TDACFieldValidateEvent;
      const ATrigger: TDACFieldValidationTrigger; const AHasError: Boolean;
      out AErrorText: string;
      const AIntrinsic: TDACFieldIntrinsicValidator = nil): Boolean;
  end;

  TDACResolvedFieldState = record
    Availability: TDACFieldAvailability;
    Validation: TDACFieldValidation;
    Interaction: TDACFieldInteraction;
    Content: TDACFieldContent;
  end;

  { Pure resolver shared by all form fields. Validation deliberately remains
    orthogonal to availability and focus. }
  TDACFieldStateResolver = record
  public
    class function Resolve(const AEnabled, ALoading, AReadOnly, AFocused,
      AHovered, AHasContent: Boolean;
      const AValidation: TDACFieldValidation): TDACResolvedFieldState; static;
  end;

  { Resolved visual chrome for any field. Produced by TDACFieldChromeResolver
    so every input draws identical border, background and text. }
  TDACFieldChromeResult = record
    BorderColor: TAlphaColor;
    BorderAlpha: Byte;
    BorderWidth: Single;
    BackgroundColor: TAlphaColor;
    BackgroundAlpha: Byte;
    TextColor: TAlphaColor;
    IconColor: TAlphaColor;
    CanFocus: Boolean;
    CanModify: Boolean;
  end;

  { Single source of truth for field chrome rendering.
    Precedence (identical to TDACEdit):
      1. Disabled  2. Loading  3. ReadOnly
      4. Validation (border color)  5. Focus (border width)
      6. Hover  7. Normal }
  TDACFieldChromeResolver = record
  public
    class function Resolve(const AState: TDACResolvedFieldState;
      const ATokens: TDACControlTokens): TDACFieldChromeResult; static;
  end;

  { Owns only native caption/support. Values stay in native VCL editors and
    chrome stays in Skia. }
  TDACFieldTextSupport = class
  private
    FCaptionLabel: TLabel;
    FCounterLabel: TLabel;
    FRequiredLabel: TLabel;
    FSupportLabel: TLabel;
    function MeasureTextWidth(const AText: string; const AFont: TFont): Integer;
    procedure PrepareLabel(const ALabel: TLabel);
  public
    constructor Create(const AOwner: TComponent; const AParent: TWinControl);
    destructor Destroy; override;
    procedure SetFocusControl(const AControl: TWinControl);
    procedure Update(const ACaption, AHelperText, AErrorText, ACounterText: string;
      const ARequired: Boolean; const AState: TDACResolvedFieldState;
      const AWidth, AChromeTop, AChromeHeight: Integer;
      const ATokens: TDACControlTokens);
    property CaptionLabel: TLabel read FCaptionLabel;
    property SupportLabel: TLabel read FSupportLabel;
  end;

function DACFieldChromeTop(const AHasCaption: Boolean;
  const ATokens: TDACControlTokens): Integer;
function DACFieldSupportText(const AHelperText, AErrorText: string;
  const AValidation: TDACFieldValidation): string;
function DACFieldTotalHeight(const AHasCaption, AHasSupport: Boolean;
  const AChromeHeight: Integer; const ATokens: TDACControlTokens): Integer;
function DACFieldVclColor(const AColor: TAlphaColor): TColor;
procedure DACFieldBeginLoadingTabPolicy(const AHost: TWinControl;
  var APreviousTabStop, ACaptured: Boolean;
  const AFinalStreamingValue: Boolean = False);
procedure DACFieldEndLoadingTabPolicy(const AHost: TWinControl;
  var APreviousTabStop, ACaptured: Boolean);
procedure DACFieldRelinquishFocus(const AHost, AEditor: TWinControl);
function DACFieldIsLeaving(const AHost: TWinControl): Boolean;
procedure DACFieldRejectExit(const AEditor: TWinControl);

{ Mede a largura de AText em pixels usando a API GDI nativa com a fonte AFont.
  Use esta funcao em controles que precisam alinhar texto nativo (TLabel, DrawText)
  com o layout calculado em codigo — nunca use TDACSkiaRenderer.MeasureText
  para posicionar texto VCL, pois Skia opera em pixels de dispositivo enquanto
  VCL opera em pontos de fonte. }
function DACMeasureNativeText(const AText: string; const AFont: TFont): Integer;


implementation

uses
  System.Math,
  Winapi.Windows,
  Vcl.Forms,
  DAC.Components.DesignSystem.Fonts;

type
  TDACWinControlAccess = class(TWinControl);

  { A published TLabel.FocusControl pointing at an unnamed internal child is
    serialized as an invalid property path by Delphi's component writer.
    Keep the label native, but route its click through a transient presenter
    that tracks the actual editor without publishing that reference. }
  TDACFieldNativeLabel = class(TLabel)
  private
    FFocusTarget: TWinControl;
  protected
    procedure Click; override;
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure SetFocusTarget(const AControl: TWinControl);
  end;

constructor TDACFieldNativeLabel.Create(AOwner: TComponent);
begin
  inherited;
end;

procedure TDACFieldNativeLabel.Click;
begin
  inherited;
  if (FFocusTarget <> nil) and FFocusTarget.Enabled and
    FFocusTarget.Visible and FFocusTarget.CanFocus then
    FFocusTarget.SetFocus;
end;

procedure TDACFieldNativeLabel.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FFocusTarget) then
    FFocusTarget := nil;
end;

procedure TDACFieldNativeLabel.SetFocusTarget(const AControl: TWinControl);
begin
  if FFocusTarget = AControl then
    Exit;
  if FFocusTarget <> nil then
    FFocusTarget.RemoveFreeNotification(Self);
  FFocusTarget := AControl;
  if FFocusTarget <> nil then
    FFocusTarget.FreeNotification(Self);
end;

procedure DACFieldBeginLoadingTabPolicy(const AHost: TWinControl;
  var APreviousTabStop, ACaptured: Boolean;
  const AFinalStreamingValue: Boolean);
begin
  if AHost = nil then
    Exit;
  { Property order is not stable while a DFM is loading. Loaded calls this
    again after the final streamed TabStop value is known. }
  if (csLoading in AHost.ComponentState) and not AFinalStreamingValue then
    Exit;
  if not ACaptured then
  begin
    APreviousTabStop := AHost.TabStop;
    ACaptured := True;
  end;
  AHost.TabStop := False;
end;

procedure DACFieldEndLoadingTabPolicy(const AHost: TWinControl;
  var APreviousTabStop, ACaptured: Boolean);
begin
  if (AHost = nil) or (csLoading in AHost.ComponentState) then
    Exit;
  if ACaptured then
  begin
    AHost.TabStop := APreviousTabStop;
    ACaptured := False;
  end;
end;

procedure DACFieldRelinquishFocus(const AHost, AEditor: TWinControl);
var
  LFocus: HWND;
begin
  if (AHost = nil) or (csDesigning in AHost.ComponentState) or
    (csLoading in AHost.ComponentState) or
    (csDestroying in AHost.ComponentState) or
    (AHost.Parent = nil) or not AHost.HandleAllocated or
    not AHost.Parent.HandleAllocated then
    Exit;
  LFocus := Winapi.Windows.GetFocus;
  if (LFocus = 0) or
    ((LFocus <> AHost.Handle) and
     ((AEditor = nil) or not AEditor.HandleAllocated or
      (LFocus <> AEditor.Handle)) and
     not IsChild(AHost.Handle, LFocus)) then
    Exit;
  TDACWinControlAccess(AHost.Parent).SelectNext(AHost, True, True);
  LFocus := Winapi.Windows.GetFocus;
  if (LFocus = AHost.Handle) or IsChild(AHost.Handle, LFocus) then
    Winapi.Windows.SetFocus(0);
end;

function DACFieldIsLeaving(const AHost: TWinControl): Boolean;
var
  LForm: TCustomForm;
begin
  LForm := GetParentForm(AHost);
  Result := AHost.Showing and (LForm <> nil) and
    not (csDestroying in LForm.ComponentState) and
    not AHost.ContainsControl(LForm.ActiveControl);
end;

procedure DACFieldRejectExit(const AEditor: TWinControl);
begin
  if AEditor.Showing and AEditor.CanFocus then
  begin
    AEditor.SetFocus;
    Abort;
  end;
end;

function TDACFieldValidator.TryValidate(const AHost: TWinControl; const AText: string;
  const AValidator: TDACFieldValidateEvent;
  const ATrigger: TDACFieldValidationTrigger; const AHasError: Boolean;
  out AErrorText: string; const AIntrinsic: TDACFieldIntrinsicValidator): Boolean;
var
  LBlank: Boolean;
  LIntrinsicError: string;
begin
  Result := False;
  if (not Assigned(AValidator) and not Assigned(AIntrinsic)) or FRunning or
    (AHost.ComponentState * [csDesigning, csLoading, csDestroying] <> []) then
    Exit;

  FRunning := True;
  try
    LIntrinsicError := '';
    if Assigned(AIntrinsic) then
      LIntrinsicError := AIntrinsic(AText);
    AErrorText := '';
    if Assigned(AValidator) then
      AValidator(AHost, AText, AErrorText);
    AErrorText := Trim(AErrorText);
    if AErrorText = '' then
      AErrorText := LIntrinsicError;
    LBlank := Trim(AText) = '';
    { Clearing the field releases focus. Explicit validation, such as saving,
      can still reject a blank value. }
    if (ATrigger <> mfvtExplicit) and LBlank then
      AErrorText := '';
    Result := (ATrigger <> mfvtChange) or AHasError or FShowOnChange;
    if Result and (AErrorText <> '') then
      FShowOnChange := True
    else if (ATrigger = mfvtExit) or LBlank then
      FShowOnChange := False;
  finally
    FRunning := False;
  end;
end;

function DACFieldVclColor(const AColor: TAlphaColor): TColor;
begin
  Result := TColor(((AColor and $00FF0000) shr 16) or
    (AColor and $0000FF00) or ((AColor and $000000FF) shl 16));
end;

function DACMeasureNativeText(const AText: string; const AFont: TFont): Integer;
var
  LBitmap: Vcl.Graphics.TBitmap;
begin
  Result := 0;
  if AText = '' then
    Exit;
  LBitmap := Vcl.Graphics.TBitmap.Create;
  try
    LBitmap.Canvas.Font.Assign(AFont);
    Result := LBitmap.Canvas.TextWidth(AText);
  finally
    LBitmap.Free;
  end;
end;


function DACFieldChromeTop(const AHasCaption: Boolean;
  const ATokens: TDACControlTokens): Integer;
begin
  if AHasCaption then
    Result := Round(ATokens.FieldChromeTop)
  else
    Result := 0;
end;

function DACFieldSupportText(const AHelperText, AErrorText: string;
  const AValidation: TDACFieldValidation): string;
begin
  if (AValidation = mfvDanger) and (AErrorText.Trim <> '') then
    Result := AErrorText
  else
    Result := AHelperText;
end;

function DACFieldTotalHeight(const AHasCaption, AHasSupport: Boolean;
  const AChromeHeight: Integer; const ATokens: TDACControlTokens): Integer;
begin
  Result := DACFieldChromeTop(AHasCaption, ATokens) + AChromeHeight;
  if AHasSupport then
    Inc(Result, Round(ATokens.FieldSupportGap +
      ATokens.FieldSupportRowHeight));
end;

class function TDACFieldStateResolver.Resolve(const AEnabled, ALoading,
  AReadOnly, AFocused, AHovered, AHasContent: Boolean;
  const AValidation: TDACFieldValidation): TDACResolvedFieldState;
begin
  if not AEnabled then
    Result.Availability := mfaDisabled
  else if ALoading then
    Result.Availability := mfaLoading
  else if AReadOnly then
    Result.Availability := mfaReadOnly
  else
    Result.Availability := mfaEditable;
  Result.Validation := AValidation;
  if AFocused then
    Result.Interaction := mfiFocused
  else if AHovered then
    Result.Interaction := mfiHover
  else
    Result.Interaction := mfiRest;
  if AHasContent then
    Result.Content := mfcFilled
  else
    Result.Content := mfcEmpty;
end;

class function TDACFieldChromeResolver.Resolve(
  const AState: TDACResolvedFieldState;
  const ATokens: TDACControlTokens): TDACFieldChromeResult;
begin
  { --- Defaults (Normal state) --- }
  Result.BorderColor := ATokens.InputBorder;
  Result.BorderAlpha := ATokens.InputBorderAlphaNormal;
  Result.BorderWidth := ATokens.InputBorderWidth;
  Result.BackgroundColor := ATokens.InputBackground;
  Result.BackgroundAlpha := ATokens.InputBackgroundAlpha;
  Result.TextColor := ATokens.InputText;
  Result.IconColor := ATokens.InputIcon;
  Result.CanFocus := True;
  Result.CanModify := True;

  { --- Precedence 7/6: Hover (lowest visual priority) --- }
  if AState.Interaction = mfiHover then
  begin
    Result.BorderColor := ATokens.InputBorderHover;
    Result.BorderAlpha := ATokens.InputBorderAlphaHover;
  end;

  { --- Precedence 5: Focus (sets border width to 2px) --- }
  if AState.Interaction = mfiFocused then
  begin
    Result.BorderColor := ATokens.InputFocus;
    Result.BorderAlpha := ATokens.InputBorderAlphaFocus;
    Result.BorderWidth := ATokens.InputFocusBorderWidth;
  end;

  { --- Precedence 4: Validation (overrides border color, not width) --- }
  case AState.Validation of
    mfvSuccess:
    begin
      Result.BorderColor := ATokens.InputSuccessBorder;
      Result.BorderAlpha := ATokens.InputBorderAlphaStatus;
    end;
    mfvWarning:
    begin
      Result.BorderColor := ATokens.InputWarningBorder;
      Result.BorderAlpha := ATokens.InputBorderAlphaStatus;
    end;
    mfvDanger:
    begin
      Result.BorderColor := ATokens.InputDangerBorder;
      Result.BorderAlpha := ATokens.InputBorderAlphaStatus;
    end;
  end;

  { --- Precedence 3: ReadOnly --- }
  if AState.Availability = mfaReadOnly then
    Result.CanModify := False;

  { --- Precedence 2: Loading (same visual as disabled, no focus) --- }
  if AState.Availability = mfaLoading then
  begin
    Result.BorderAlpha := ATokens.InputBorderAlphaDisabled;
    Result.BackgroundColor := ATokens.InputDisabledBackground;
    Result.TextColor := ATokens.InputDisabledText;
    Result.IconColor := ATokens.InputIconDisabled;
    Result.CanFocus := False;
    Result.CanModify := False;
  end;

  { --- Precedence 1: Disabled (highest priority) --- }
  if AState.Availability = mfaDisabled then
  begin
    Result.BorderAlpha := ATokens.InputBorderAlphaDisabled;
    Result.BackgroundColor := ATokens.InputDisabledBackground;
    Result.TextColor := ATokens.InputDisabledText;
    Result.IconColor := ATokens.InputIconDisabled;
    Result.CanFocus := False;
    Result.CanModify := False;
  end;
end;

constructor TDACFieldTextSupport.Create(const AOwner: TComponent;
  const AParent: TWinControl);
begin
  inherited Create;
  FCaptionLabel := TDACFieldNativeLabel.Create(nil);
  PrepareLabel(FCaptionLabel);
  FCaptionLabel.Parent := AParent;
  FRequiredLabel := TDACFieldNativeLabel.Create(nil);
  PrepareLabel(FRequiredLabel);
  FRequiredLabel.Parent := AParent;
  FRequiredLabel.Caption := '*';
  FSupportLabel := TDACFieldNativeLabel.Create(nil);
  PrepareLabel(FSupportLabel);
  FSupportLabel.Parent := AParent;
  FCounterLabel := TDACFieldNativeLabel.Create(nil);
  PrepareLabel(FCounterLabel);
  FCounterLabel.Alignment := taRightJustify;
  FCounterLabel.Parent := AParent;
end;

destructor TDACFieldTextSupport.Destroy;
begin
  FCounterLabel.Free;
  FSupportLabel.Free;
  FRequiredLabel.Free;
  FCaptionLabel.Free;
  inherited;
end;

function TDACFieldTextSupport.MeasureTextWidth(const AText: string;
  const AFont: TFont): Integer;
var
  LBitmap: Vcl.Graphics.TBitmap;
begin
  Result := 0;
  if AText = '' then
    Exit;
  LBitmap := Vcl.Graphics.TBitmap.Create;
  try
    LBitmap.Canvas.Font.Assign(AFont);
    Result := LBitmap.Canvas.TextWidth(AText);
  finally
    LBitmap.Free;
  end;
end;

procedure TDACFieldTextSupport.PrepareLabel(const ALabel: TLabel);
begin
  ALabel.AutoSize := False;
  ALabel.Transparent := True;
  ALabel.ParentFont := False;
  ALabel.StyleElements := ALabel.StyleElements - [seFont];
  ALabel.Font.Name := DACComponentFontFamily;
  ALabel.Font.Size := 9;
  ALabel.Font.Style := [];
  ALabel.Visible := False;
end;

procedure TDACFieldTextSupport.SetFocusControl(const AControl: TWinControl);
begin
  FCaptionLabel.FocusControl := nil;
  TDACFieldNativeLabel(FCaptionLabel).SetFocusTarget(AControl);
end;

procedure TDACFieldTextSupport.Update(const ACaption, AHelperText, AErrorText,
  ACounterText: string; const ARequired: Boolean;
  const AState: TDACResolvedFieldState;
  const AWidth, AChromeTop, AChromeHeight: Integer;
  const ATokens: TDACControlTokens);
var
  LCaptionWidth: Integer;
  LSupportColor: TAlphaColor;
  LSupportText: string;
  LSupportTop: Integer;
begin
  FCaptionLabel.Font.Name := TDACComponentFontInstaller.FontFamily;
  FCaptionLabel.Font.Size := Round(ATokens.FieldLabelTextSize);
  if ARequired then
    FCaptionLabel.Font.Style := [fsBold]
  else
    FCaptionLabel.Font.Style := [];
  FCaptionLabel.Caption := ACaption;
  if AState.Validation = mfvDanger then
    FCaptionLabel.Font.Color := DACFieldVclColor(ATokens.FieldDangerText)
  else if ARequired then
    { Required fields use the exact focus-border token. This keeps the native
      label visually coupled to the primary selected outline in both themes. }
    FCaptionLabel.Font.Color := DACFieldVclColor(ATokens.FieldRequiredText)
  else
    FCaptionLabel.Font.Color := DACFieldVclColor(ATokens.FieldLabelText);
  FCaptionLabel.Visible := ACaption.Trim <> '';
  FCaptionLabel.SetBounds(0, 0, Max(0, AWidth),
    Round(ATokens.FieldLabelRowHeight));

  LCaptionWidth := MeasureTextWidth(ACaption, FCaptionLabel.Font);
  FRequiredLabel.Font.Assign(FCaptionLabel.Font);
  FRequiredLabel.Visible := FCaptionLabel.Visible and ARequired;
  FRequiredLabel.SetBounds(LCaptionWidth + Round(ATokens.FieldRequiredGap), 0,
    Max(0, AWidth - LCaptionWidth), Round(ATokens.FieldLabelRowHeight));

  LSupportText := DACFieldSupportText(AHelperText, AErrorText,
    AState.Validation);
  LSupportColor := ATokens.FieldSupportText;
  case AState.Validation of
    mfvSuccess: LSupportColor := ATokens.FieldSuccessText;
    mfvWarning: LSupportColor := ATokens.FieldWarningText;
    mfvDanger: LSupportColor := ATokens.FieldDangerText;
  end;
  if (AState.Availability = mfaDisabled) and (AState.Validation <> mfvDanger) then
    LSupportColor := ATokens.FieldDisabledText;

  LSupportTop := AChromeTop + AChromeHeight +
    Round(ATokens.FieldSupportGap);
  FSupportLabel.Font.Name := TDACComponentFontInstaller.FontFamily;
  FSupportLabel.Font.Size := Round(ATokens.FieldSupportTextSize);
  FSupportLabel.Font.Style := [];
  FSupportLabel.Font.Color := DACFieldVclColor(LSupportColor);
  FSupportLabel.Caption := LSupportText;
  FSupportLabel.Visible := LSupportText.Trim <> '';
  FSupportLabel.SetBounds(0, LSupportTop, Max(0, AWidth),
    Round(ATokens.FieldSupportRowHeight));

  FCounterLabel.Font.Assign(FSupportLabel.Font);
  FCounterLabel.Font.Color := DACFieldVclColor(ATokens.FieldCounterText);
  FCounterLabel.Caption := ACounterText;
  FCounterLabel.Visible := ACounterText.Trim <> '';
  FCounterLabel.SetBounds(0, LSupportTop, Max(0, AWidth),
    Round(ATokens.FieldSupportRowHeight));
end;

end.
