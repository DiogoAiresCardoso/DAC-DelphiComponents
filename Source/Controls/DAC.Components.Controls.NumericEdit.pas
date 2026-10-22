unit DAC.Components.Controls.NumericEdit;

interface

uses
  System.Classes,
  System.Skia,
  System.Types,
  System.UITypes,
  Winapi.Messages,
  Vcl.Controls,
  Vcl.Skia,
  DAC.Components.Controls.Edit,
  DAC.Components.Controls.SystemText,
  DAC.Components.DesignSystem.ControlTokens,
  DAC.Components.DesignSystem.Theme,
  DAC.Components.Skia.Renderer;

type
  TDACNumericKind = (
    dnkNumber,
    dnkCurrency,
    dnkWeight
  );

  TDACNumericMaskKind = (
    nmkInteger,
    nmkDecimal
  );

  { Numeric specialization of the canonical TDACEdit. TDACEdit remains the
    sole owner of the native TMaskEdit, chrome, focus, labels, helper/error
    rows, theme and design-time preview. }
  TDACNumericEdit = class(TDACEdit)
  private
    FAllowNegative: Boolean;
    FDecimalPlaces: Integer;
    FDecimalPlacesExplicit: Boolean;
    FInternalTextUpdate: Boolean;
    FNumericKind: TDACNumericKind;
    FSuffixLabel: TDACSystemText;
    FSuffixPaintBox: TSkPaintBox;
    FSuffixRenderer: TDACSkiaRenderer;
    FSuffixText: string;
    FSuffixWidth: Integer;
    FUseGrouping: Boolean;
    FValue: Double;
    FWeightUnit: string;
    procedure CMEnabledChanged(var AMessage: TMessage); message CM_ENABLEDCHANGED;
    procedure CMParentColorChanged(var AMessage: TMessage); message CM_PARENTCOLORCHANGED;
    procedure CMParentFontChanged(var AMessage: TMessage); message CM_PARENTFONTCHANGED;
    procedure CommitEditorText;
    procedure EditorEnter(Sender: TObject);
    procedure EditorExit(Sender: TObject);
    procedure EditorKeyPress(Sender: TObject; var Key: Char);
    function DefaultDecimalPlaces: Integer;
    function FormatValue(const AValue: Double): string;
    function GetCornerRadiusValue: Integer;
    function GetEditKindValue: TDACEditKind;
    function GetLoadingValue: Boolean;
    function GetNumericMask: TDACNumericMaskKind;
    function GetReadOnlyValue: Boolean;
    function GetThemeModeValue: TDACThemeMode;
    function HasExternalSuffix: Boolean;
    function NormalizeEditableText(const AText: string): string;
    function NumberFormat: string;
    procedure SetAllowNegative(const AValue: Boolean);
    procedure SetCornerRadiusValue(const AValue: Integer);
    procedure SetDecimalPlaces(const AValue: Integer);
    procedure SetEditKindValue(const AValue: TDACEditKind);
    procedure SetEditorText(const AText: string);
    procedure SetLoadingValue(const AValue: Boolean);
    procedure SetNumericMask(const AValue: TDACNumericMaskKind);
    procedure SetNumericKind(const AValue: TDACNumericKind);
    procedure SetReadOnlyValue(const AValue: Boolean);
    procedure SetSuffixText(const AValue: string);
    procedure SetSuffixWidth(const AValue: Integer);
    procedure SetThemeModeValue(const AValue: TDACThemeMode);
    procedure SetUseGrouping(const AValue: Boolean);
    procedure SetValue(const AValue: Double);
    procedure SetWeightUnit(const AValue: string);
    procedure SuffixPaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    function TryTextToValue(const AText: string; out AValue: Double): Boolean;
    procedure UpdateEditorText(const AForceValue: Boolean = False);
    procedure UpdateSuffixLayout;
    procedure UpdateSuffixState;
  protected
    procedure Change; override;
    procedure CreateWnd; override;
    procedure Loaded; override;
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property SuffixControl: TDACSystemText read FSuffixLabel;
  published
    property AllowNegative: Boolean read FAllowNegative write SetAllowNegative
      default True;
    property CornerRadius: Integer read GetCornerRadiusValue
      write SetCornerRadiusValue default DACEditDefaultCornerRadius;
    property DecimalPlaces: Integer read FDecimalPlaces write SetDecimalPlaces
      default 0;
    property EditKind: TDACEditKind read GetEditKindValue write SetEditKindValue
      default mekNumeric;
    property Loading: Boolean read GetLoadingValue write SetLoadingValue
      default False;
    property NumericMask: TDACNumericMaskKind read GetNumericMask
      write SetNumericMask default nmkInteger;
    property NumericKind: TDACNumericKind read FNumericKind write SetNumericKind
      default dnkNumber;
    property ReadOnly: Boolean read GetReadOnlyValue write SetReadOnlyValue
      default False;
    property SuffixText: string read FSuffixText write SetSuffixText;
    property SuffixWidth: Integer read FSuffixWidth write SetSuffixWidth
      default DACButtonEditDefaultButtonWidth;
    property ThemeMode: TDACThemeMode read GetThemeModeValue
      write SetThemeModeValue default dtmInherit;
    property UseGrouping: Boolean read FUseGrouping write SetUseGrouping
      default True;
    property Value: Double read FValue write SetValue;
    property WeightUnit: string read FWeightUnit write SetWeightUnit;
  end;

implementation

uses
  System.Math,
  System.SysUtils,
  DAC.Components.DesignSystem.ComponentStyle;

constructor TDACNumericEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := DACSpecializedInputWidth;
  Constraints.MinWidth := DACSpecializedInputWidth;
  FAllowNegative := True;
  FDecimalPlaces := 0;
  FNumericKind := dnkNumber;
  FSuffixWidth := DACButtonEditDefaultButtonWidth;
  FUseGrouping := True;
  FWeightUnit := 'kg';
  { The fixed mekNumeric mask from the generic edit is intentionally not used.
    This specialization validates the locale-aware numeric text while keeping
    the inherited native editor unrestricted enough for currency and weight. }
  TDACEdit(Self).EditKind := mekText;
  EditControl.OnEnter := EditorEnter;
  EditControl.OnExit := EditorExit;
  EditControl.OnKeyPress := EditorKeyPress;

  { The suffix is informational rather than an action. Keep its divider in a
    non-windowed Skia layer and its glyphs in a non-windowed native text layer.
    This avoids a second focus/click target and leaves no HWND frame cached by
    the form designer when the suffix is cleared. }
  FSuffixRenderer := TDACSkiaRenderer.Create;
  FSuffixPaintBox := TSkPaintBox.Create(Self);
  FSuffixPaintBox.Parent := Self;
  FSuffixPaintBox.SetSubComponent(True);
  FSuffixPaintBox.Enabled := False;
  FSuffixPaintBox.StyleElements := [];
  FSuffixPaintBox.OnDraw := SuffixPaintBoxDraw;
  FSuffixPaintBox.Visible := False;

  FSuffixLabel := TDACSystemText.Create(Self);
  FSuffixLabel.Parent := Self;
  FSuffixLabel.SetSubComponent(True);
  FSuffixLabel.Enabled := False;
  FSuffixLabel.HorzAlign := mthaCenter;
  FSuffixLabel.VertAlign := mtvaCenter;
  FSuffixLabel.MaxLines := 1;
  FSuffixLabel.Bold := False;
  FSuffixLabel.Visible := False;
  UpdateSuffixState;
  UpdateSuffixLayout;
end;

destructor TDACNumericEdit.Destroy;
begin
  FreeAndNil(FSuffixLabel);
  FreeAndNil(FSuffixPaintBox);
  FreeAndNil(FSuffixRenderer);
  inherited;
end;

procedure TDACNumericEdit.Change;
var
  LCaret: Integer;
  LNormalized: string;
  LValue: Double;
begin
  if FInternalTextUpdate then
    Exit;

  LNormalized := NormalizeEditableText(Text);
  if Text <> LNormalized then
  begin
    LCaret := EditControl.SelStart;
    SetEditorText(LNormalized);
    EditControl.SelStart := Min(Length(LNormalized), LCaret);
  end;

  if TryTextToValue(LNormalized, LValue) then
    FValue := LValue
  else if LNormalized = '' then
    FValue := 0;
  inherited Change;
end;

procedure TDACNumericEdit.CommitEditorText;
var
  LValue: Double;
begin
  if Trim(Text) = '' then
  begin
    FValue := 0;
    Exit;
  end;
  if TryTextToValue(Text, LValue) then
    FValue := LValue;
  UpdateEditorText;
end;

procedure TDACNumericEdit.CMEnabledChanged(var AMessage: TMessage);
begin
  inherited;
  UpdateSuffixState;
end;

procedure TDACNumericEdit.CMParentColorChanged(var AMessage: TMessage);
begin
  inherited;
  UpdateSuffixState;
  UpdateSuffixLayout;
end;

procedure TDACNumericEdit.CMParentFontChanged(var AMessage: TMessage);
begin
  inherited;
  UpdateSuffixLayout;
end;

procedure TDACNumericEdit.CreateWnd;
begin
  inherited;
  UpdateSuffixState;
  UpdateSuffixLayout;
end;

procedure TDACNumericEdit.EditorEnter(Sender: TObject);
begin
  if Trim(Text) <> '' then
    SetEditorText(NormalizeEditableText(FloatToStr(FValue)));
  Redraw;
  if Assigned(OnEnter) then
    OnEnter(Self);
end;

procedure TDACNumericEdit.EditorExit(Sender: TObject);
begin
  CommitEditorText;
  Redraw;
  if Assigned(OnExit) then
    OnExit(Self);
end;

procedure TDACNumericEdit.EditorKeyPress(Sender: TObject; var Key: Char);
var
  LDecimalSeparator: Char;
  LSelectionRemovesSeparator: Boolean;
begin
  if Key < #32 then
  begin
    if Assigned(OnKeyPress) then
      OnKeyPress(Self, Key);
    Exit;
  end;
  if CharInSet(Key, ['0'..'9']) then
  begin
    if Assigned(OnKeyPress) then
      OnKeyPress(Self, Key);
    Exit;
  end;

  LDecimalSeparator := FormatSettings.DecimalSeparator;
  if CharInSet(Key, [',', '.']) and (FDecimalPlaces > 0) then
  begin
    LSelectionRemovesSeparator := (EditControl.SelLength > 0) and
      (Pos(LDecimalSeparator, Copy(Text, EditControl.SelStart + 1,
        EditControl.SelLength)) > 0);
    if (Pos(LDecimalSeparator, Text) = 0) or LSelectionRemovesSeparator then
    begin
      Key := LDecimalSeparator;
      if Assigned(OnKeyPress) then
        OnKeyPress(Self, Key);
      Exit;
    end;
  end;

  if (Key = '-') and FAllowNegative and
    ((EditControl.SelStart = 0) or
     ((EditControl.SelStart = 1) and (Text[1] = '-'))) then
  begin
    if Assigned(OnKeyPress) then
      OnKeyPress(Self, Key);
    Exit;
  end;
  Key := #0;
end;

function TDACNumericEdit.DefaultDecimalPlaces: Integer;
begin
  case FNumericKind of
    dnkWeight:
      Result := 3;
  else
    Result := 2;
  end;
end;

function TDACNumericEdit.FormatValue(const AValue: Double): string;
begin
  case FNumericKind of
    dnkCurrency:
      if HasExternalSuffix then
        Result := FormatFloat(NumberFormat, AValue)
      else
        Result := FloatToStrF(AValue, ffCurrency, 18, FDecimalPlaces);
    dnkWeight:
      begin
        Result := FormatFloat(NumberFormat, AValue);
        if not HasExternalSuffix and (Trim(FWeightUnit) <> '') then
          Result := Result + ' ' + Trim(FWeightUnit);
      end;
  else
    Result := FormatFloat(NumberFormat, AValue);
  end;
end;

function TDACNumericEdit.GetCornerRadiusValue: Integer;
begin
  Result := TDACEdit(Self).CornerRadius;
end;

function TDACNumericEdit.GetEditKindValue: TDACEditKind;
begin
  Result := mekNumeric;
end;

function TDACNumericEdit.GetLoadingValue: Boolean;
begin
  Result := TDACEdit(Self).Loading;
end;

function TDACNumericEdit.GetNumericMask: TDACNumericMaskKind;
begin
  if FDecimalPlaces > 0 then
    Result := nmkDecimal
  else
    Result := nmkInteger;
end;

function TDACNumericEdit.GetReadOnlyValue: Boolean;
begin
  Result := TDACEdit(Self).ReadOnly;
end;

function TDACNumericEdit.GetThemeModeValue: TDACThemeMode;
begin
  Result := TDACEdit(Self).ThemeMode;
end;

function TDACNumericEdit.HasExternalSuffix: Boolean;
begin
  Result := Trim(FSuffixText) <> '';
end;

procedure TDACNumericEdit.Loaded;
begin
  inherited;
  UpdateSuffixState;
  UpdateSuffixLayout;
end;

function TDACNumericEdit.NormalizeEditableText(const AText: string): string;
var
  I: Integer;
  LDecimalIndex: Integer;
  LDecimalSeparator: Char;
  LDigitCount: Integer;
  LDigitsBeforeDecimal: Integer;
  LHasNegative: Boolean;
  LSource: string;
begin
  LSource := Trim(AText);
  LHasNegative := FAllowNegative and
    ((Pos('-', LSource) > 0) or
     ((Pos('(', LSource) > 0) and (Pos(')', LSource) > 0)));
  LDecimalIndex := 0;
  if FDecimalPlaces > 0 then
    for I := Length(LSource) downto 1 do
      if CharInSet(LSource[I], [',', '.']) then
      begin
        LDecimalIndex := I;
        Break;
      end;

  LDigitsBeforeDecimal := 0;
  if LDecimalIndex > 0 then
    for I := 1 to LDecimalIndex - 1 do
      if CharInSet(LSource[I], ['0'..'9']) then
        Inc(LDigitsBeforeDecimal);

  Result := '';
  for I := 1 to Length(LSource) do
    if CharInSet(LSource[I], ['0'..'9']) then
      Result := Result + LSource[I];

  if (LDecimalIndex > 0) and (FDecimalPlaces > 0) then
  begin
    LDecimalSeparator := FormatSettings.DecimalSeparator;
    Insert(LDecimalSeparator, Result, LDigitsBeforeDecimal + 1);
    LDigitCount := Length(Result) - LDigitsBeforeDecimal - 1;
    if LDigitCount > FDecimalPlaces then
      Delete(Result, LDigitsBeforeDecimal + FDecimalPlaces + 2,
        LDigitCount - FDecimalPlaces);
  end;

  if LHasNegative and (Result <> '') then
    Result := '-' + Result;
end;

function TDACNumericEdit.NumberFormat: string;
begin
  if FUseGrouping then
    Result := '#,##0'
  else
    Result := '0';
  if FDecimalPlaces > 0 then
    Result := Result + '.' + StringOfChar('0', FDecimalPlaces);
end;

procedure TDACNumericEdit.Resize;
begin
  inherited;
  UpdateSuffixLayout;
end;

procedure TDACNumericEdit.SetAllowNegative(const AValue: Boolean);
begin
  if FAllowNegative = AValue then
    Exit;
  FAllowNegative := AValue;
  if not FAllowNegative and (FValue < 0) then
    FValue := 0;
  UpdateEditorText;
end;

procedure TDACNumericEdit.SetCornerRadiusValue(const AValue: Integer);
begin
  TDACEdit(Self).CornerRadius := AValue;
  UpdateSuffixLayout;
end;

procedure TDACNumericEdit.SetDecimalPlaces(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := EnsureRange(AValue, 0, 8);
  FDecimalPlacesExplicit := True;
  if FDecimalPlaces = LValue then
  begin
    UpdateEditorText;
    Exit;
  end;
  FDecimalPlaces := LValue;
  UpdateEditorText;
end;

procedure TDACNumericEdit.SetEditKindValue(const AValue: TDACEditKind);
begin
  { NumericEdit is intentionally closed over numeric semantics. The native
    editor stays mask-free; accepting another EditKind would reintroduce the
    fixed generic masks this component replaces. }
  TDACEdit(Self).EditKind := mekText;
end;

procedure TDACNumericEdit.SetEditorText(const AText: string);
begin
  FInternalTextUpdate := True;
  try
    TDACEdit(Self).Text := AText;
  finally
    FInternalTextUpdate := False;
  end;
end;

procedure TDACNumericEdit.SetLoadingValue(const AValue: Boolean);
begin
  TDACEdit(Self).Loading := AValue;
  UpdateSuffixState;
end;

procedure TDACNumericEdit.SetNumericMask(const AValue: TDACNumericMaskKind);
var
  LDecimalPlaces: Integer;
begin
  FDecimalPlacesExplicit := True;
  if AValue = nmkDecimal then
  begin
    LDecimalPlaces := FDecimalPlaces;
    if LDecimalPlaces <= 0 then
      LDecimalPlaces := DefaultDecimalPlaces;
  end
  else
    LDecimalPlaces := 0;

  if FDecimalPlaces = LDecimalPlaces then
  begin
    UpdateEditorText;
    Exit;
  end;
  FDecimalPlaces := LDecimalPlaces;
  UpdateEditorText;
end;

procedure TDACNumericEdit.SetNumericKind(const AValue: TDACNumericKind);
begin
  if FNumericKind = AValue then
  begin
    UpdateEditorText;
    Exit;
  end;
  FNumericKind := AValue;
  if not FDecimalPlacesExplicit then
    if FNumericKind = dnkNumber then
      FDecimalPlaces := 0
    else
      FDecimalPlaces := DefaultDecimalPlaces;
  UpdateEditorText;
end;

procedure TDACNumericEdit.SetReadOnlyValue(const AValue: Boolean);
begin
  TDACEdit(Self).ReadOnly := AValue;
  UpdateSuffixState;
end;

procedure TDACNumericEdit.SetSuffixText(const AValue: string);
begin
  if FSuffixText = AValue then
  begin
    UpdateSuffixState;
    UpdateSuffixLayout;
    Exit;
  end;
  FSuffixText := AValue;
  UpdateEditorText;
  UpdateSuffixState;
  UpdateSuffixLayout;
end;

procedure TDACNumericEdit.SetSuffixWidth(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(0, AValue);
  if FSuffixWidth = LValue then
  begin
    UpdateSuffixLayout;
    Exit;
  end;
  FSuffixWidth := LValue;
  UpdateSuffixLayout;
end;

procedure TDACNumericEdit.SetThemeModeValue(const AValue: TDACThemeMode);
begin
  TDACEdit(Self).ThemeMode := AValue;
  UpdateSuffixState;
  UpdateSuffixLayout;
end;

procedure TDACNumericEdit.SetUseGrouping(const AValue: Boolean);
begin
  if FUseGrouping = AValue then
    Exit;
  FUseGrouping := AValue;
  UpdateEditorText;
end;

procedure TDACNumericEdit.SetValue(const AValue: Double);
begin
  if not FAllowNegative and (AValue < 0) then
    FValue := 0
  else
    FValue := AValue;
  UpdateEditorText(True);
end;

procedure TDACNumericEdit.SetWeightUnit(const AValue: string);
begin
  if FWeightUnit = AValue then
    Exit;
  FWeightUnit := AValue;
  UpdateEditorText;
end;

procedure TDACNumericEdit.SuffixPaintBoxDraw(Sender: TObject;
  const ACanvas: ISkCanvas; const ADest: TRectF; const AOpacity: Single);
var
  LTokens: TDACControlTokens;
begin
  if (ACanvas = nil) or (ADest.Width <= 0) or (ADest.Height <= 0) or
    not HasExternalSuffix then
    Exit;
  LTokens := TDACComponentStyle.ResolveForSurface(Self,
    TDACEdit(Self).ThemeMode).Tokens.Controls;
  { This layer only owns the divider. Keeping the canvas transparent lets the
    canonical TDACEdit surface and rounded corners remain the sole chrome. }
  ACanvas.Clear(LTokens.TransparentSurfaceFallback);
  FSuffixRenderer.FillRoundRect(ACanvas,
    TRectF.Create(0, LTokens.ButtonInputActionDividerVerticalInset,
      LTokens.ButtonInputActionDividerWidth,
      ADest.Height - LTokens.ButtonInputActionDividerVerticalInset),
    LTokens.ButtonInputActionDivider, 0, LTokens.AlphaOpaque);
end;

function TDACNumericEdit.TryTextToValue(const AText: string;
  out AValue: Double): Boolean;
var
  LText: string;
begin
  LText := NormalizeEditableText(AText);
  Result := (LText <> '') and (LText <> '-') and
    TryStrToFloat(LText, AValue);
  if Result and not FAllowNegative and (AValue < 0) then
  begin
    AValue := 0;
    Result := True;
  end;
end;

procedure TDACNumericEdit.UpdateEditorText(const AForceValue: Boolean);
begin
  if not AForceValue and (Trim(Text) = '') then
  begin
    Redraw;
    Exit;
  end;
  if EditControl.Focused and not (csDesigning in ComponentState) then
    SetEditorText(NormalizeEditableText(FloatToStr(FValue)))
  else
    SetEditorText(FormatValue(FValue));
  Redraw;
end;

procedure TDACNumericEdit.UpdateSuffixLayout;
var
  LChromeHeight: Integer;
  LChromeTop: Integer;
  LOuterInset: Integer;
  LRight: Integer;
  LSuffixLeft: Integer;
  LSuffixWidth: Integer;
  LTokens: TDACControlTokens;
begin
  if (FSuffixPaintBox = nil) or (FSuffixLabel = nil) or
    (csLoading in ComponentState) or
    (csDestroying in ComponentState) then
    Exit;

  FSuffixPaintBox.Visible := HasExternalSuffix;
  FSuffixLabel.Visible := HasExternalSuffix;
  if not HasExternalSuffix then
  begin
    RightContentReserve := 0;
    FSuffixPaintBox.Redraw;
    FSuffixLabel.Invalidate;
    Redraw;
    Exit;
  end;

  LTokens := TDACComponentStyle.ResolveForSurface(Self,
    TDACEdit(Self).ThemeMode).Tokens.Controls;
  LOuterInset := Ceil(Max(Max(LTokens.InputBorderWidth,
    LTokens.InputFocusBorderWidth), LTokens.ButtonEditButtonInset));
  LChromeTop := InputChromeTop;
  LChromeHeight := Min(InputChromeHeight, Max(0, Height - LChromeTop));
  LRight := Max(LOuterInset, Width - LOuterInset);
  LSuffixWidth := Min(FSuffixWidth, Max(0, LRight - LOuterInset));
  LSuffixLeft := Max(LOuterInset, LRight - LSuffixWidth);

  RightContentReserve := Max(0, Width - LSuffixLeft);
  FSuffixPaintBox.SetBounds(LSuffixLeft, LChromeTop + LOuterInset,
    LSuffixWidth, Max(0, LChromeHeight - (LOuterInset * 2)));
  FSuffixLabel.SetBounds(LSuffixLeft + Round(LTokens.ButtonInputActionDividerWidth),
    LChromeTop + LOuterInset,
    Max(0, LSuffixWidth - Round(LTokens.ButtonInputActionDividerWidth)),
    Max(0, LChromeHeight - (LOuterInset * 2)));
  FSuffixPaintBox.BringToFront;
  FSuffixLabel.BringToFront;
  FSuffixPaintBox.Redraw;
  FSuffixLabel.Invalidate;
end;

procedure TDACNumericEdit.UpdateSuffixState;
var
  LTokens: TDACControlTokens;
begin
  if (FSuffixPaintBox = nil) or (FSuffixLabel = nil) then
    Exit;
  LTokens := TDACComponentStyle.ResolveForSurface(Self,
    TDACEdit(Self).ThemeMode).Tokens.Controls;
  FSuffixLabel.BeginUpdate;
  try
    FSuffixLabel.Text := FSuffixText;
    FSuffixLabel.ThemeMode := ThemeMode;
    FSuffixLabel.FontFamily := TDACComponentStyle.FontFamily;
    FSuffixLabel.FontSize := Round(LTokens.InputSmallTextSize);
    FSuffixLabel.Bold := False;
    if not Enabled or Loading then
      FSuffixLabel.TextColor := LTokens.InputDisabledText
    else
      FSuffixLabel.TextColor := LTokens.ButtonInputActionText;
  finally
    FSuffixLabel.EndUpdate;
  end;
  FSuffixPaintBox.Redraw;
end;

end.
