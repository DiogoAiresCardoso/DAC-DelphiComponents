program DACComponentsInteractionCurrent;

{$APPTYPE CONSOLE}
{$MINSTACKSIZE $00200000}

uses
  System.Classes,
  System.SysUtils,
  System.TypInfo,
  Winapi.Messages,
  Winapi.Windows,
  Vcl.Controls,
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
    procedure Changed(Sender: TObject);
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
  LExpected: string;
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
  RequireResolverContract;
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
