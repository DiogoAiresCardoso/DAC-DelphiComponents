program DACComponentsInteractionCurrent;

{$APPTYPE CONSOLE}
{$MINSTACKSIZE $00200000}

uses
  DACComponentsButtonLayout.Tests in 'DACComponentsButtonLayout.Tests.pas',
  DACComponentsIcons.Tests in 'DACComponentsIcons.Tests.pas',
  System.Classes,
  System.SysUtils,
  System.Types,
  System.TypInfo,
  Winapi.Messages,
  Winapi.Windows,
  Vcl.Controls,
  Vcl.ComCtrls,
  Vcl.Forms,
  Vcl.Graphics,
  Vcl.Mask,
  Vcl.StdCtrls,
  DAC.Components.Controls.ButtonEdit,
  DAC.Components.Controls.CheckBox,
  DAC.Components.Controls.ComboBox,
  DAC.Components.Controls.Container,
  DAC.Components.Controls.DateTimePicker,
  DAC.Components.Controls.Edit,
  DAC.Components.Controls.NumericEdit,
  DAC.Components.Controls.FieldSupport,
  DAC.Components.Controls.Memo,
  DAC.Components.Controls.RadioButton,
  DAC.Components.Controls.Slider,
  DAC.Components.Controls.ToggleSwitch,
  DAC.Components.DesignSystem.ComponentStyle,
  DAC.Components.DesignSystem.ControlTokens,
  DAC.Components.DesignSystem.Theme;

type
  TEditAccess = class(TDACEdit)
  public
    procedure ApplyBindingCanModify(const AValue: Boolean);
    function UsesParentColor: Boolean;
  end;

  TButtonEditAccess = class(TDACButtonEdit)
  public
    procedure ApplyBindingCanModify(const AValue: Boolean);
    function UsesParentColor: Boolean;
  end;

  TDesignContainerAccess = class(TDACContainer)
  public
    procedure SimulateDesignerLoaded;
    function UsesParentColor: Boolean;
  end;

  TSelectorAccess = class(TDACSelector)
  public
    procedure PressSpace;
  end;

  TSliderAccess = class(TDACSlider)
  public
    procedure PressRight;
  end;

  TChangeProbe = class
  public
    Count: Integer;
    LastSender: TObject;
    procedure Changed(Sender: TObject);
    procedure ConsumeSearchKey(Sender: TObject; var Key: Word;
      Shift: TShiftState);
  end;

  TValidationProbe = class
  public
    Count: Integer;
    ExitCount: Integer;
    ExceptionMessage: string;
    LastText: string;
    procedure Check(Sender: TObject; const AText: string; var AErrorText: string);
    procedure Exited(Sender: TObject);
    procedure HandleException(Sender: TObject; E: Exception);
  end;

procedure Require(const ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create(AMessage);
end;

function CountMaskEditDescendants(const AParent: TWinControl): Integer;
var
  I: Integer;
  LControl: TControl;
begin
  Result := 0;
  if AParent = nil then
    Exit;
  for I := 0 to AParent.ControlCount - 1 do
  begin
    LControl := AParent.Controls[I];
    if LControl is TMaskEdit then
      Inc(Result);
    if LControl is TWinControl then
      Inc(Result, CountMaskEditDescendants(TWinControl(LControl)));
  end;
end;

procedure TSelectorAccess.PressSpace;
var
  LKey: Word;
begin
  LKey := VK_SPACE;
  KeyDown(LKey, []);
end;

procedure TSliderAccess.PressRight;
var
  LKey: Word;
begin
  LKey := VK_RIGHT;
  KeyDown(LKey, []);
end;

procedure TChangeProbe.Changed(Sender: TObject);
begin
  Inc(Count);
  LastSender := Sender;
end;

procedure TChangeProbe.ConsumeSearchKey(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key = VK_F3 then
  begin
    Key := 0;
    Changed(Sender);
  end;
end;

procedure TValidationProbe.Check(Sender: TObject; const AText: string;
  var AErrorText: string);
begin
  Inc(Count);
  LastText := AText;
  if Trim(AText) = '' then
    AErrorText := 'Informe um valor'
  else if not AText.StartsWith('2') then
    AErrorText := 'Valor invalido: ' + AText;
end;

procedure TValidationProbe.Exited(Sender: TObject);
begin
  Inc(ExitCount);
end;

procedure TValidationProbe.HandleException(Sender: TObject; E: Exception);
begin
  ExceptionMessage := E.Message;
end;

procedure TEditAccess.ApplyBindingCanModify(const AValue: Boolean);
begin
  SetBindingCanModify(AValue);
end;

function TEditAccess.UsesParentColor: Boolean;
begin
  Result := ParentColor;
end;

procedure TButtonEditAccess.ApplyBindingCanModify(const AValue: Boolean);
begin
  SetBindingCanModify(AValue);
end;

function TButtonEditAccess.UsesParentColor: Boolean;
begin
  Result := ParentColor;
end;

procedure TDesignContainerAccess.SimulateDesignerLoaded;
begin
  SetDesigning(True);
  Loaded;
end;

function TDesignContainerAccess.UsesParentColor: Boolean;
begin
  Result := ParentColor;
end;

procedure RequirePublished(const AClass: TClass; const AName: string);
begin
  Require(GetPropInfo(AClass, AName) <> nil,
    AClass.ClassName + ' nao publicou ' + AName + '.');
end;

procedure RequireTransparentContainerLifecycle;
var
  I: Integer;
  LChild: TDesignContainerAccess;
  LContainer: TDesignContainerAccess;
  LForm: TForm;
begin
  LForm := TForm.Create(nil);
  try
    LForm.Color := RGB($F1, $F5, $F1);
    LContainer := TDesignContainerAccess.Create(LForm);
    LContainer.Parent := LForm;
    LContainer.SimulateDesignerLoaded;
    LContainer.Appearance := mcaTransparent;

    LChild := TDesignContainerAccess.Create(LForm);
    LChild.Parent := LContainer;
    LChild.SimulateDesignerLoaded;
    LChild.Appearance := mcaTransparent;

    for I := 0 to 31 do
    begin
      if Odd(I) then
        LContainer.ThemeMode := dtmLight
      else
        LContainer.ThemeMode := dtmDark;
      LContainer.Appearance := mcaTransparent;
      LChild.Appearance := mcaTransparent;
      TDACThemeManager.RefreshTree(LContainer);
      LForm.Color := RGB($F1 - (I mod 2), $F5, $F1);
    end;

    Require(not LContainer.UsesParentColor and not LChild.UsesParentColor,
      'Container transparente reativou ParentColor e pode recursar no designer.');
    Require(ColorToRGB(LContainer.Color) = ColorToRGB(LForm.Color),
      'Container transparente nao publicou a superficie fisica do parent.');
    Require(ColorToRGB(LChild.Color) = ColorToRGB(LContainer.Color),
      'Container transparente aninhado divergiu da superficie ancestral.');
  finally
    LForm.Free;
  end;
end;

procedure RequireResolverContract;
var
  LResult: TDACFieldChromeResult;
  LState: TDACResolvedFieldState;
  LTokens: TDACControlTokens;
begin
  LTokens := TDACComponentStyle.Resolve(dtmLight).Tokens.Controls;
  LState := TDACFieldStateResolver.Resolve(True, False, False, False,
    False, False, mfvNormal);
  LResult := TDACFieldChromeResolver.Resolve(LState, LTokens);
  Require(LResult.BorderWidth = LTokens.InputBorderWidth,
    'Resolver normal nao usa InputBorderWidth.');
  LState.Interaction := mfiFocused;
  LResult := TDACFieldChromeResolver.Resolve(LState, LTokens);
  Require(LResult.BorderWidth = LTokens.InputFocusBorderWidth,
    'Resolver focado nao usa InputFocusBorderWidth.');
  Require(LResult.BorderColor = LTokens.InputFocus,
    'Resolver focado nao usa InputFocus.');
  LState.Validation := mfvDanger;
  LResult := TDACFieldChromeResolver.Resolve(LState, LTokens);
  Require((LResult.BorderWidth = LTokens.InputFocusBorderWidth) and
    (LResult.BorderColor = LTokens.InputDangerBorder),
    'Status danger nao preservou a espessura de foco.');
  LState.Availability := mfaDisabled;
  LResult := TDACFieldChromeResolver.Resolve(LState, LTokens);
  Require(not LResult.CanFocus and not LResult.CanModify,
    'Disabled nao prevaleceu sobre os demais estados.');
end;

procedure RequireFieldErrorText(const ATokens: TDACControlTokens);
var
  LField: TDACFieldTextSupport;
  LHost: TCustomControl;
  LState: TDACResolvedFieldState;
  LDangerColor: TColor;
begin
  LHost := TCustomControl.Create(nil);
  try
    LField := TDACFieldTextSupport.Create(LHost, LHost);
    try
      LDangerColor := DACFieldVclColor(ATokens.FieldDangerText);
      LState := TDACFieldStateResolver.Resolve(True, False, False, True,
        False, True, mfvDanger);
      LField.Update('Campo', 'Texto de ajuda', '', '', False, LState,
        220, 22, 32, ATokens);
      Require((LField.CaptionLabel.Font.Color = LDangerColor) and
        (LField.SupportLabel.Font.Color = LDangerColor) and
        (LField.SupportLabel.Caption = 'Texto de ajuda'),
        'Erro deve destacar o label e o texto de ajuda.');

      LState.Availability := mfaDisabled;
      LField.Update('Campo', 'Texto de ajuda', 'Valor invalido', '', True,
        LState, 220, 22, 32, ATokens);
      Require((LField.CaptionLabel.Font.Color = LDangerColor) and
        (LField.SupportLabel.Font.Color = LDangerColor) and
        (LField.SupportLabel.Caption = 'Valor invalido'),
        'Erro deve destacar o campo obrigatorio e sua mensagem explicita.');

      LState.Availability := mfaEditable;
      LState.Validation := mfvNormal;
      LField.Update('Campo', 'Texto de ajuda', 'Valor invalido', '', True,
        LState, 220, 22, 32, ATokens);
      Require((LField.CaptionLabel.Font.Color =
        DACFieldVclColor(ATokens.FieldRequiredText)) and
        (LField.SupportLabel.Font.Color =
        DACFieldVclColor(ATokens.FieldSupportText)) and
        (LField.SupportLabel.Caption = 'Texto de ajuda'),
        'Remover o erro deve restaurar as cores e o texto de ajuda.');
    finally
      LField.Free;
    end;
  finally
    LHost.Free;
  end;
end;

procedure RequireSelectorContract(const ASelector: TDACSelector;
  const AProbe: TChangeProbe);
var
  LBefore: Boolean;
begin
  ASelector.OnChange := AProbe.Changed;
  LBefore := ASelector.Checked;
  TSelectorAccess(ASelector).PressSpace;
  Require(ASelector.Checked <> LBefore,
    ASelector.ClassName + ' nao alternou por Space.');
  Require(AProbe.Count = 1,
    ASelector.ClassName + ' duplicou OnChange.');
  ASelector.ReadOnly := True;
  LBefore := ASelector.Checked;
  TSelectorAccess(ASelector).PressSpace;
  Require(ASelector.Checked = LBefore,
    ASelector.ClassName + ' alterou em ReadOnly.');
  ASelector.ReadOnly := False;
  ASelector.Enabled := False;
  TSelectorAccess(ASelector).PressSpace;
  Require(ASelector.Checked = LBefore,
    ASelector.ClassName + ' alterou desabilitado.');
end;

procedure RequireButtonEditSearchKey(const AForm: TForm;
  const AButtonEdit: TDACButtonEdit; const AProbe: TChangeProbe);

  procedure PressF3;
  begin
    Require(PostMessage(AButtonEdit.EditControl.Handle, WM_KEYDOWN, VK_F3, 1),
      'Falha ao enviar F3 ao editor nativo.');
    Application.ProcessMessages;
  end;

begin
  AButtonEdit.SetFocus;
  Require(AButtonEdit.EditControl.Focused, 'Editor nativo sem foco para F3.');
  AProbe.Count := 0;
  PressF3;
  Require((AProbe.Count = 1) and (AProbe.LastSender = AButtonEdit),
    'F3 nao disparou OnButtonClick exatamente uma vez no ButtonEdit.');

  AButtonEdit.OnKeyDown := AProbe.ConsumeSearchKey;
  PressF3;
  Require((AProbe.Count = 2) and (AProbe.LastSender = AButtonEdit),
    'F3 nao respeitou OnKeyDown do ButtonEdit.');
  AButtonEdit.OnKeyDown := nil;

  AForm.KeyPreview := True;
  AForm.OnKeyDown := AProbe.ConsumeSearchKey;
  PressF3;
  Require((AProbe.Count = 3) and (AProbe.LastSender = AForm),
    'F3 nao respeitou KeyPreview do formulario.');
  AForm.OnKeyDown := nil;
  AForm.KeyPreview := False;

  AButtonEdit.ReadOnly := True;
  PressF3;
  AButtonEdit.ReadOnly := False;
  TButtonEditAccess(AButtonEdit).ApplyBindingCanModify(False);
  PressF3;
  TButtonEditAccess(AButtonEdit).ApplyBindingCanModify(True);
  AButtonEdit.Loading := True;
  PressF3;
  AButtonEdit.Loading := False;
  AButtonEdit.Enabled := False;
  PressF3;
  AButtonEdit.Enabled := True;
  Require(AProbe.Count = 3, 'F3 executou a acao com o ButtonEdit bloqueado.');
end;

procedure RequireButtonEditParity(const AEdit: TDACEdit;
  const AButtonEdit: TDACButtonEdit; const AProbe: TChangeProbe);
var
  LExpectedHeight: Integer;
begin
  Require(TDACButtonEdit.ClassParent = TDACEdit,
    'ButtonEdit deixou de herdar diretamente do Edit canonico.');
  Require(CountMaskEditDescendants(AButtonEdit) = 1,
    'ButtonEdit deve possuir somente o TMaskEdit herdado do Edit.');
  Require(AButtonEdit.EditControl.BoundsRect.Right <=
    AButtonEdit.ButtonControl.Left,
    'Editor nativo invadiu a caixa de acao do ButtonEdit.');
  Require(TButtonEditAccess(AButtonEdit).UsesParentColor =
    TEditAccess(AEdit).UsesParentColor,
    'ButtonEdit divergiu do ParentColor canonico do Edit.');
  Require(AButtonEdit.Height = AEdit.Height,
    'ButtonEdit divergiu da altura single-line do Edit.');
  Require(AButtonEdit.InputSize = misSmall,
    'ButtonEdit nao normalizou InputSize para Small.');

  AEdit.LabelText := 'Campo';
  AButtonEdit.LabelText := 'Campo';
  Require(AButtonEdit.Height = AEdit.Height,
    'LabelText gerou alturas diferentes em Edit e ButtonEdit.');
  AEdit.HelperText := 'Ajuda';
  AButtonEdit.HelperText := 'Ajuda';
  Require(AButtonEdit.Height = AEdit.Height,
    'HelperText foi cortado ou divergiu da altura do Edit.');
  AEdit.HelperText := '';
  AButtonEdit.HelperText := '';
  AEdit.SetBounds(AEdit.Left, AEdit.Top, AEdit.Width, 1);
  AButtonEdit.SetBounds(AButtonEdit.Left, AButtonEdit.Top,
    AButtonEdit.Width, 1);
  AEdit.ErrorText := 'Erro';
  AButtonEdit.ErrorText := 'Erro';
  Require(AButtonEdit.Height = AEdit.Height,
    'ErrorText foi cortado ou divergiu da altura do Edit.');
  AEdit.ErrorText := '';
  AButtonEdit.ErrorText := '';
  AEdit.SetBounds(AEdit.Left, AEdit.Top, AEdit.Width, 1);
  AButtonEdit.SetBounds(AButtonEdit.Left, AButtonEdit.Top,
    AButtonEdit.Width, 1);
  AEdit.CounterText := '3/12';
  AButtonEdit.CounterText := '3/12';
  Require(AButtonEdit.Height = AEdit.Height,
    'CounterText foi cortado ou divergiu da altura do Edit.');
  LExpectedHeight := AEdit.Height;
  AButtonEdit.SetBounds(AButtonEdit.Left, AButtonEdit.Top,
    AButtonEdit.Width, 1);
  Require(AButtonEdit.Height = LExpectedHeight,
    'SetBounds permitiu que ButtonEdit cortasse label/helper.');

  AEdit.Text := 'ABC';
  AButtonEdit.Text := 'ABC';
  AEdit.CharCase := ecUpperCase;
  AButtonEdit.CharCase := ecUpperCase;
  AEdit.MaxLength := 12;
  AButtonEdit.MaxLength := 12;
  AEdit.Placeholder := 'Digite';
  AButtonEdit.Placeholder := 'Digite';
  AEdit.CornerRadius := 6;
  AButtonEdit.CornerRadius := 6;
  AEdit.Required := True;
  AButtonEdit.Required := True;
  AEdit.Status := mesDanger;
  AButtonEdit.Status := mesDanger;
  Require((AButtonEdit.Text = AEdit.Text) and
    (AButtonEdit.CharCase = AEdit.CharCase) and
    (AButtonEdit.MaxLength = AEdit.MaxLength) and
    (AButtonEdit.Placeholder = AEdit.Placeholder) and
    (AButtonEdit.CornerRadius = AEdit.CornerRadius) and
    (AButtonEdit.Required = AEdit.Required) and
    (AButtonEdit.Status = AEdit.Status),
    'ButtonEdit nao propagou o contrato publicado do Edit.');

  AButtonEdit.SetFocus;
  Application.ProcessMessages;
  Require(AButtonEdit.EditControl.Focused,
    'SetFocus do ButtonEdit nao transferiu o caret ao TMaskEdit.');
  AButtonEdit.ButtonControl.SetFocus;
  Application.ProcessMessages;
  Require(AButtonEdit.EditControl.Focused,
    'Botao de acao roubou o foco do editor nativo.');

  AProbe.Count := 0;
  AButtonEdit.OnButtonClick := AProbe.Changed;
  AButtonEdit.ButtonControl.Click;
  Require(AProbe.Count = 1,
    'ButtonEdit editavel nao disparou a acao exatamente uma vez.');

  AEdit.ReadOnly := True;
  AButtonEdit.ReadOnly := True;
  Require(AEdit.EditControl.ReadOnly and AButtonEdit.EditControl.ReadOnly and
    not AButtonEdit.ButtonControl.Enabled,
    'ReadOnly nao foi aplicado igualmente ao editor e a acao.');
  AButtonEdit.ButtonControl.Click;
  Require(AProbe.Count = 1,
    'ButtonEdit executou a acao em ReadOnly.');
  AEdit.ReadOnly := False;
  AButtonEdit.ReadOnly := False;

  TEditAccess(AEdit).ApplyBindingCanModify(False);
  TButtonEditAccess(AButtonEdit).ApplyBindingCanModify(False);
  Require(AEdit.EditControl.ReadOnly and AButtonEdit.EditControl.ReadOnly and
    not AButtonEdit.ButtonControl.Enabled,
    'BindingCanModify=False divergiu entre Edit e ButtonEdit.');
  AButtonEdit.ButtonControl.Click;
  Require(AProbe.Count = 1,
    'ButtonEdit executou a acao com BindingCanModify=False.');
  TEditAccess(AEdit).ApplyBindingCanModify(True);
  TButtonEditAccess(AButtonEdit).ApplyBindingCanModify(True);
  Require(not AEdit.EditControl.ReadOnly and
    not AButtonEdit.EditControl.ReadOnly and
    AButtonEdit.ButtonControl.Enabled,
    'BindingCanModify=True nao restaurou o campo composto.');

  AEdit.Loading := True;
  AButtonEdit.Loading := True;
  Require(not AEdit.TabStop and not AButtonEdit.TabStop and
    not AButtonEdit.ButtonControl.Enabled,
    'Loading divergiu na politica de Tab/acao do ButtonEdit.');
  AButtonEdit.ButtonControl.Click;
  Require(AProbe.Count = 1,
    'ButtonEdit executou a acao durante Loading.');
  AEdit.Loading := False;
  AButtonEdit.Loading := False;
  Require(AEdit.TabStop and AButtonEdit.TabStop and
    AButtonEdit.ButtonControl.Enabled,
    'ButtonEdit nao restaurou Tab/acao apos Loading.');

  AEdit.Enabled := False;
  AButtonEdit.Enabled := False;
  Require(not AEdit.EditControl.Enabled and
    not AButtonEdit.EditControl.Enabled and
    not AButtonEdit.ButtonControl.Enabled,
    'Disabled divergiu entre Edit e ButtonEdit.');
  AButtonEdit.ButtonControl.Click;
  Require(AProbe.Count = 1,
    'ButtonEdit executou a acao desabilitado.');
  AEdit.Enabled := True;
  AButtonEdit.Enabled := True;

  AButtonEdit.ThemeMode := dtmDark;
  AButtonEdit.ThemeMode := dtmDark;
  Require(AButtonEdit.ButtonControl.ThemeMode = dtmDark,
    'Reaplicacao do mesmo tema nao alcancou o botao interno.');
end;

procedure RequireNumericEditContract(const ANumeric: TDACNumericEdit);
var
  LEditorBounds: TRect;
  LExpected: string;
  LTokens: TDACControlTokens;
begin
  Require(TDACNumericEdit.ClassParent = TDACEdit,
    'NumericEdit deixou de herdar diretamente do Edit canonico.');
  Require(ANumeric.EditControl <> nil,
    'NumericEdit nao preservou o TMaskEdit nativo herdado.');
  Require(ANumeric.EditKind = mekNumeric,
    'NumericEdit nao publicou a especializacao numerica.');

  ANumeric.NumericKind := dnkNumber;
  ANumeric.DecimalPlaces := 2;
  ANumeric.UseGrouping := False;
  ANumeric.Value := 1234.5;
  LExpected := FormatFloat('0.00', 1234.5);
  Require(ANumeric.Text = LExpected,
    'NumericEdit nao formatou numero com as casas configuradas.');

  ANumeric.Text := '12a3' + FormatSettings.DecimalSeparator + '45kg';
  Require((Pos('a', ANumeric.Text) = 0) and
    (Pos('k', ANumeric.Text) = 0) and
    (Abs(ANumeric.Value - 123.45) < 0.000001),
    'NumericEdit aceitou texto nao numerico ou perdeu o valor colado.');

  ANumeric.NumericKind := dnkCurrency;
  ANumeric.Value := 98.7;
  Require((FormatSettings.CurrencyString = '') or
    (Pos(FormatSettings.CurrencyString, ANumeric.Text) > 0),
    'NumericEdit de moeda nao aplicou a formatacao regional.');

  ANumeric.NumericKind := dnkWeight;
  ANumeric.WeightUnit := 'kg';
  ANumeric.Value := 12.345;
  Require(Pos('kg', ANumeric.Text) > 0,
    'NumericEdit de peso nao exibiu a unidade configurada.');

  ANumeric.AllowNegative := False;
  ANumeric.Value := -10;
  Require(ANumeric.Value = 0,
    'NumericEdit aceitou valor negativo quando bloqueado.');

  ANumeric.Value := 12.34;
  ANumeric.SetFocus;
  ANumeric.EditControl.SelStart := 1;
  ANumeric.EditControl.SelLength := 2;
  LEditorBounds := ANumeric.EditControl.BoundsRect;
  LExpected := ANumeric.Text;
  ANumeric.SuffixText := 'kg';
  Require((ANumeric.SuffixPosition = nspRight) and
    (ANumeric.EditControl.Left = LEditorBounds.Left) and
    (ANumeric.EditControl.BoundsRect.Right <= ANumeric.SuffixControl.Left),
    'Sufixo padrao deve reservar espaco a direita.');
  ANumeric.SuffixPosition := nspLeft;
  Require((ANumeric.SuffixControl.BoundsRect.Right <= ANumeric.EditControl.Left) and
    (ANumeric.EditControl.BoundsRect.Right = LEditorBounds.Right),
    'Sufixo a esquerda deve liberar o espaco que ocupava a direita.');
  Require(ANumeric.EditControl.Focused and (ANumeric.Text = LExpected) and
    (ANumeric.EditControl.SelStart = 1) and (ANumeric.EditControl.SelLength = 2),
    'Trocar o lado deve preservar o texto, o foco e a selecao.');
  LTokens := TDACComponentStyle.ResolveForSurface(ANumeric,
    ANumeric.ThemeMode).Tokens.Controls;
  TDACEdit(ANumeric).Status := mesDanger;
  Require(ANumeric.SuffixControl.TextColor = LTokens.FieldDangerText,
    'Sufixo nao acompanhou a mudanca para erro pelo TDACEdit.');
  TDACEdit(ANumeric).Status := mesNormal;
  Require(ANumeric.SuffixControl.TextColor = LTokens.ButtonInputActionText,
    'Sufixo nao voltou a cor normal apos limpar o erro.');
  ANumeric.SuffixText := '';
  Require(not ANumeric.SuffixControl.Visible and
    EqualRect(ANumeric.EditControl.BoundsRect, LEditorBounds),
    'Remover o sufixo deve restaurar toda a largura do editor.');
  ANumeric.SuffixPosition := nspRight;
end;

procedure RequireLegacyNegative(const ANumeric: TDACNumericEdit; const ANext: TDACEdit);
begin
  ANumeric.AllowNegative := True;
  ANumeric.Value := 7;
  ANumeric.SetFocus;
  ANumeric.EditControl.SelectAll;
  SendMessage(ANumeric.EditControl.Handle, WM_CHAR, Ord('-'), 1);
  Require(ANumeric.Text = '-', 'O sinal parcial foi apagado.');
  SendMessage(ANumeric.EditControl.Handle, WM_CHAR, Ord('1'), 1);
  Require((ANumeric.Text = '-1') and (ANumeric.Value = -1),
    'O digito deve manter o sinal negativo.');
  ANumeric.EditControl.SelectAll;
  SendMessage(ANumeric.EditControl.Handle, WM_CHAR, Ord('-'), 1);
  ANext.SetFocus;
  Require(ANext.EditControl.Focused and (ANumeric.Text = '') and
    (ANumeric.Value = 0), 'O sinal isolado deve sair como campo vazio.');
  ANumeric.AllowNegative := False;
  ANumeric.SetFocus;
  SendMessage(ANumeric.EditControl.Handle, WM_CHAR, Ord('-'), 1);
  Require(ANumeric.Text = '', 'AllowNegative=False deve filtrar o sinal.');
  ANext.SetFocus;
end;

procedure RequireIntrinsicDateValidation(const ADate: TDACDateTimePicker;
  const ANext: TDACEdit);
var
  LDate: TDateTime;
  LPreviousDate: TDateTime;
  LSettings: TFormatSettings;
begin
  LSettings := FormatSettings;
  try
    FormatSettings.DateSeparator := '/';
    FormatSettings.ShortDateFormat := 'dd/mm/yyyy';
    FormatSettings.TimeSeparator := ':';
    FormatSettings.ShortTimeFormat := 'hh:nn';
    ADate.FormatString := 'dd/mm/yyyy';
    ADate.AllowNull := False;
    LPreviousDate := EncodeDate(2026, 11, 6) + EncodeTime(14, 35, 0, 0);
    ADate.DateTime := LPreviousDate;
    ADate.SetFocus;
    ADate.EditControl.EditText := '31/02/2026';
    Require(not ADate.Validate and not ADate.TryGetEditedDateTime(LDate) and
      (ADate.DateTime = LPreviousDate), 'Uma data invalida foi lida como a data anterior.');
    Require(PostMessage(ADate.EditControl.Handle, WM_KEYDOWN, VK_TAB, 1),
      'Falha ao enviar Tab ao campo de data.');
    Application.ProcessMessages;
    Require(ADate.EditControl.Focused and (ADate.Status = mesDanger),
      'Uma data invalida permitiu sair com Tab.');
    ADate.EditControl.EditText := '06/11/2___';
    Require(not ADate.Validate and not ADate.TryGetEditedDateTime(LDate),
      'Ano incompleto passou na validacao.');
    ADate.ActionButton.Click;
    Require(ADate.PopupVisible, 'O calendario deve abrir com texto invalido.');
    ADate.SimulatePopupDayClick(7);
    ADate.SimulatePopupKey(VK_RETURN);
    Require(ADate.TryGetEditedDateTime(LDate) and
      (FormatDateTime('dd/mm/yyyy hh:nn', LDate) = '07/11/2026 14:35'),
      'A selecao no calendario deve corrigir a data e preservar a hora.');
    ADate.SetFocus;
    ADate.EditControl.EditText := '31/02/2026';
    Require(not ADate.Validate, 'Data impossivel aceitou validacao.');
    ADate.OpenPopup;
    ADate.SimulatePopupDayClick(7);
    ADate.SimulatePopupKey(VK_RETURN);
    Require((ADate.Status = mesNormal) and ADate.TryGetEditedDateTime(LDate),
      'Escolher a data ja confirmada deve limpar o erro da edicao.');
    ADate.SetFocus;
    ADate.EditControl.Clear;
    ANext.SetFocus;
    Require(ANext.EditControl.Focused and not ADate.Validate and
      not ADate.TryGetEditedDateTime(LDate), 'Vazio deve permitir sair e falhar na validacao obrigatoria.');
    ADate.AllowNull := True;
    ADate.IsNull := True;
    Require(ADate.Validate and not ADate.TryGetEditedDateTime(LDate),
      'Vazio opcional deve ser valido sem fornecer data.');
    ADate.PickerKind := dtkTime;
    ADate.FormatString := 'hh:nn';
    ADate.DateTime := LPreviousDate;
    ADate.EditControl.EditText := '16:20';
    Require(ADate.Validate and ADate.TryGetEditedDateTime(LDate) and
      (FormatDateTime('dd/mm/yyyy hh:nn', LDate) = '06/11/2026 16:20'),
      'A edicao da hora deve preservar a data.');
  finally
    FormatSettings := LSettings;
  end;
end;

procedure RequireRuntimeValidation(const AEdit, ANext: TDACEdit;
  const ANumeric: TDACNumericEdit; const AMemo: TDACMemo; const ACombo: TDACComboBox;
  const ADate: TDACDateTimePicker);
var
  LProbe: TValidationProbe;
  LPreviousCount: Integer;

  procedure TypeChar(const AChar: Char);
  begin
    SendMessage(GetFocus, WM_CHAR, Ord(AChar), 1);
    Application.ProcessMessages;
    Require(LProbe.ExceptionMessage = '', LProbe.ExceptionMessage);
  end;

  procedure MoveToNext;
  begin
    ANext.SetFocus;
    Application.ProcessMessages;
    Require(LProbe.ExceptionMessage = '', LProbe.ExceptionMessage);
  end;

begin
  LProbe := TValidationProbe.Create;
  try
    Application.OnException := LProbe.HandleException;
    AEdit.Status := mesNormal;
    AEdit.Text := '';
    AEdit.OnValidate := LProbe.Check;
    AEdit.OnExit := LProbe.Exited;
    AEdit.SetFocus;
    TypeChar('1');
    Require((LProbe.Count = 1) and (LProbe.LastText = '1') and
      (AEdit.Status = mesNormal) and (AEdit.ErrorText = ''),
      'Digitar deve validar sem exibir o primeiro erro.');
    Require(PostMessage(AEdit.EditControl.Handle, WM_KEYDOWN, VK_TAB, 1),
      'Falha ao enviar Tab ao editor.');
    Application.ProcessMessages;
    Require(LProbe.ExceptionMessage = '', LProbe.ExceptionMessage);
    Require((LProbe.Count = 2) and (LProbe.ExitCount = 0) and
      AEdit.EditControl.Focused and (AEdit.Status = mesDanger),
      'Sair com valor invalido deve exibir o erro e reter o foco.');
    AEdit.EditControl.SelStart := Length(AEdit.Text);
    TypeChar('3');
    Require(AEdit.ErrorText = 'Valor invalido: 13',
      'O erro exibido deve acompanhar a digitacao.');
    AEdit.EditControl.SelectAll;
    TypeChar('2');
    Require((AEdit.Status = mesNormal) and (AEdit.ErrorText = ''),
      'Corrigir deve limpar o erro imediatamente.');
    AEdit.EditControl.SelectAll;
    TypeChar('1');
    Require(AEdit.Status = mesDanger,
      'Nova falha na mesma edicao deve aparecer enquanto digita.');
    AEdit.EditControl.SelectAll;
    TypeChar(#8);
    LPreviousCount := LProbe.Count;
    MoveToNext;
    Require((LProbe.LastText = '') and (LProbe.Count = LPreviousCount + 1) and
      (LProbe.ExitCount > 0) and ANext.EditControl.Focused and
      (AEdit.Status = mesNormal), 'Limpar deve validar e liberar o foco.');
    Require(not AEdit.Validate and (AEdit.ErrorText = 'Informe um valor'),
      'A validacao explicita deve poder rejeitar o campo em branco.');

    AEdit.Status := mesNormal;
    AEdit.ErrorText := '';
    AEdit.EditKind := mekMasked;
    AEdit.EditMask := '!00/00;1;_';
    AEdit.SetFocus;
    TypeChar('1');
    MoveToNext;
    Require(AEdit.EditControl.Focused and (AEdit.Status = mesDanger),
      'A mascara parcial deve passar pela regra antes de perder o foco.');
    AEdit.EditControl.Clear;
    MoveToNext;
    Require((LProbe.LastText = '') and ANext.EditControl.Focused and
      (AEdit.Status = mesNormal), 'Literais da mascara vazia retiveram o foco.');

    ANumeric.OnValidate := LProbe.Check;
    ANumeric.Value := 1;
    ANumeric.SetFocus;
    MoveToNext;
    Require(ANumeric.EditControl.Focused and (ANumeric.Status = mesDanger),
      'NumericEdit nao reteve o foco com valor invalido.');
    ANumeric.EditControl.SelectAll;
    TypeChar('2');
    MoveToNext;
    Require((ANumeric.Value = 2) and ANext.EditControl.Focused and
      (ANumeric.Status = mesNormal), 'NumericEdit nao aceitou a correcao.');

    AMemo.Text := '';
    AMemo.OnValidate := LProbe.Check;
    AMemo.SetFocus;
    TypeChar('1');
    MoveToNext;
    Require(AMemo.MemoControl.Focused and (AMemo.Status = mesDanger),
      'Memo nao validou a saida.');
    AMemo.MemoControl.SelectAll;
    TypeChar('2');
    MoveToNext;
    Require((AMemo.Text = '2') and ANext.EditControl.Focused and
      (AMemo.Status = mesNormal), 'Memo nao liberou o foco apos correcao.');

    ACombo.Style := csDropDown;
    ACombo.Text := '';
    ACombo.OnValidate := LProbe.Check;
    ACombo.SetFocus;
    TypeChar('1');
    MoveToNext;
    Require(IsChild(ACombo.Handle, GetFocus) and (ACombo.Status = mesDanger),
      'Combo editavel nao validou a saida.');
    SendMessage(GetFocus, EM_SETSEL, 0, -1);
    TypeChar('2');
    MoveToNext;
    Require((ACombo.Text = '2') and ANext.EditControl.Focused and
      (ACombo.Status = mesNormal), 'Combo nao liberou o foco apos correcao.');

    ACombo.Style := csDropDownList;
    ACombo.Items.Text := '1' + sLineBreak + '2';
    ACombo.ItemIndex := 0;
    ACombo.SetFocus;
    MoveToNext;
    Require(ACombo.Focused and (ACombo.Status = mesDanger),
      'Combo somente selecao nao reteve o foco.');
    ACombo.OpenDropDown;
    Require(ACombo.PopupVisible, 'Validacao bloqueou a abertura das opcoes.');
    ACombo.SimulateDropDownClick(1);
    Application.ProcessMessages;
    Require((ACombo.Text = '2') and (ACombo.Status = mesNormal),
      'Selecionar uma opcao valida deve limpar o erro.');

    ADate.AllowNull := True;
    ADate.EditControl.Clear;
    ADate.OnValidate := LProbe.Check;
    ADate.SetFocus;
    LProbe.Count := 0;
    TypeChar('1');
    Require((LProbe.Count > 0) and (ADate.Status = mesNormal),
      'DateTimePicker nao validou a digitacao parcial.');
    MoveToNext;
    Require(ADate.EditControl.Focused and (ADate.Status = mesDanger),
      'DateTimePicker nao reteve o foco com mascara parcial.');
    ADate.OpenPopup;
    Require(ADate.PopupVisible, 'Validacao bloqueou a abertura do calendario.');
    ADate.SimulatePopupKey(VK_ESCAPE);
    ADate.SetFocus;
    ADate.EditControl.Clear;
    MoveToNext;
    Require((LProbe.LastText = '') and ANext.EditControl.Focused and
      (ADate.Status = mesNormal), 'DateTimePicker nao liberou a mascara vazia.');
  finally
    Application.OnException := nil;
    ADate.OnValidate := nil;
    ACombo.OnValidate := nil;
    AMemo.OnValidate := nil;
    ANumeric.OnValidate := nil;
    AEdit.OnValidate := nil;
    AEdit.OnExit := nil;
    LProbe.Free;
  end;
end;

procedure RunInteraction;
var
  LButtonEdit: TDACButtonEdit;
  LCheck: TDACCheckBox;
  LCombo: TDACComboBox;
  LContainer: TDACContainer;
  LDate: TDACDateTimePicker;
  LEdit: TDACEdit;
  LForm: TForm;
  LMemo: TDACMemo;
  LNumeric: TDACNumericEdit;
  LProbe: TChangeProbe;
  LRadio: TDACRadioButton;
  LSlider: TDACSlider;
  LToggle: TDACToggleSwitch;
begin
  TDACButtonLayoutTests.Run;
  TDACComponentsIconTests.Run;
  RequireResolverContract;
  RequireFieldErrorText(TDACComponentStyle.Resolve(dtmLight).Tokens.Controls);
  RequireFieldErrorText(TDACComponentStyle.Resolve(dtmDark).Tokens.Controls);
  RequireTransparentContainerLifecycle;
  RequirePublished(TDACCheckBox, 'ReadOnly');
  RequirePublished(TDACCheckBox, 'Required');
  RequirePublished(TDACCheckBox, 'Status');
  RequirePublished(TDACRadioButton, 'ReadOnly');
  RequirePublished(TDACToggleSwitch, 'Required');
  RequirePublished(TDACSlider, 'ReadOnly');
  RequirePublished(TDACSlider, 'Status');
  RequirePublished(TDACNumericEdit, 'NumericKind');
  RequirePublished(TDACNumericEdit, 'Value');

  LForm := TForm.Create(nil);
  LProbe := TChangeProbe.Create;
  try
    LForm.SetBounds(100, 100, 900, 600);
    LContainer := TDACContainer.Create(LForm);
    LContainer.Parent := LForm;
    LContainer.Align := alClient;
    LContainer.ThemeMode := dtmDark;

    LEdit := TDACEdit.Create(LForm);
    LEdit.Parent := LContainer;
    LEdit.SetBounds(20, 20, 220, LEdit.Height);
    LCombo := TDACComboBox.Create(LForm);
    LCombo.Parent := LContainer;
    LCombo.SetBounds(20, 80, 220, LCombo.Height);
    LMemo := TDACMemo.Create(LForm);
    LMemo.Parent := LContainer;
    LMemo.SetBounds(20, 140, 300, LMemo.Height);
    LNumeric := TDACNumericEdit.Create(LForm);
    LNumeric.Parent := LContainer;
    LNumeric.SetBounds(20, 340, 220, LNumeric.Height);
    LButtonEdit := TDACButtonEdit.Create(LForm);
    LButtonEdit.Parent := LContainer;
    LButtonEdit.SetBounds(350, 20, 220, LButtonEdit.Height);
    LDate := TDACDateTimePicker.Create(LForm);
    LDate.Parent := LContainer;
    LDate.SetBounds(350, 80, 220, LDate.Height);
    LCheck := TDACCheckBox.Create(LForm);
    LCheck.Parent := LContainer;
    LCheck.SetBounds(350, 150, 220, LCheck.Height);
    LRadio := TDACRadioButton.Create(LForm);
    LRadio.Parent := LContainer;
    LRadio.SetBounds(350, 190, 220, LRadio.Height);
    LToggle := TDACToggleSwitch.Create(LForm);
    LToggle.Parent := LContainer;
    LToggle.SetBounds(350, 230, 220, LToggle.Height);
    LSlider := TDACSlider.Create(LForm);
    LSlider.Parent := LContainer;
    LSlider.SetBounds(350, 280, 260, LSlider.Height);

    LForm.Show;
    Application.ProcessMessages;
    Require((LEdit.Width = 220) and (LNumeric.Width = 220) and
      (LCombo.Width = 220) and
      (LButtonEdit.Width = 220) and (LDate.Width = 220),
      'Campos single-line divergiram da largura canonica.');
    Require(LDate.TabStop, 'Host DateTimePicker deixou de ser tab stop.');
    LDate.SetFocus;
    Application.ProcessMessages;
    Require(LDate.PickerControl.Focused,
      'DateTimePicker nao transferiu foco ao SysDateTimePick32.');

    RequireButtonEditParity(LEdit, LButtonEdit, LProbe);
    RequireButtonEditSearchKey(LForm, LButtonEdit, LProbe);
    RequireNumericEditContract(LNumeric);

    LProbe.Count := 0;
    RequireSelectorContract(LCheck, LProbe);
    LProbe.Count := 0;
    RequireSelectorContract(LRadio, LProbe);
    LProbe.Count := 0;
    RequireSelectorContract(LToggle, LProbe);

    LSlider.Value := 10;
    TSliderAccess(LSlider).PressRight;
    Require(LSlider.Value = 11, 'Slider nao respondeu ao teclado.');
    LSlider.ReadOnly := True;
    TSliderAccess(LSlider).PressRight;
    Require(LSlider.Value = 11, 'Slider alterou em ReadOnly.');

    LContainer.ThemeMode := dtmLight;
    LContainer.ThemeMode := dtmLight;
    Application.ProcessMessages;
    Require((LEdit.ThemeMode = dtmInherit) and
      (LNumeric.ThemeMode = dtmInherit) and
      (LCombo.ThemeMode = dtmInherit) and (LDate.ThemeMode = dtmInherit),
      'Reaplicacao do tema alterou o contrato inherit dos filhos.');
    RequireRuntimeValidation(LEdit, LButtonEdit, LNumeric, LMemo, LCombo, LDate);
    RequireLegacyNegative(LNumeric, LButtonEdit);
    RequireIntrinsicDateValidation(LDate, LButtonEdit);
  finally
    LProbe.Free;
    LForm.Free;
  end;
end;

begin
  try
    Application.Initialize;
    RunInteraction;
    Writeln('DACComponentsInteraction: PASS');
    ExitCode := 0;
  except
    on E: Exception do
    begin
      Writeln('DACComponentsInteraction: FAIL: ', E.ClassName, ': ', E.Message);
      ExitCode := 1;
    end;
  end;
end.
