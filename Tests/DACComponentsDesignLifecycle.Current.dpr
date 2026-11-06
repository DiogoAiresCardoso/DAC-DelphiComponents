program DACComponentsDesignLifecycleCurrent;

{$APPTYPE CONSOLE}
{$MINSTACKSIZE $00200000}

uses
  System.Classes,
  System.SysUtils,
  Winapi.Windows,
  Vcl.Controls,
  Vcl.Forms,
  DAC.Components.Controls.ButtonEdit,
  DAC.Components.Controls.CheckBox,
  DAC.Components.Controls.ComboBox,
  DAC.Components.Controls.Container,
  DAC.Components.Controls.DateTimePicker,
  DAC.Components.Controls.Edit,
  DAC.Components.Controls.NumericEdit,
  DAC.Components.Controls.Memo,
  DAC.Components.Controls.RadioButton,
  DAC.Components.Controls.Slider,
  DAC.Components.Controls.ToggleSwitch,
  DAC.Components.DesignSystem.Theme;

type
  TComponentAccess = class(TComponent)
  public
    procedure EnterDesignMode;
  end;

  TWinControlAccess = class(TWinControl)
  public
    procedure RecreateNativeHandle;
  end;

procedure TComponentAccess.EnterDesignMode;
begin
  SetDesigning(True, True);
end;

procedure TWinControlAccess.RecreateNativeHandle;
begin
  RecreateWnd;
end;

procedure Require(const ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create(AMessage);
end;

procedure RunCycle(const ACycle: Integer);
const
  Classes: array[0..9] of TWinControlClass = (
    TDACEdit, TDACNumericEdit, TDACMemo, TDACComboBox, TDACButtonEdit,
    TDACDateTimePicker, TDACCheckBox, TDACRadioButton,
    TDACToggleSwitch, TDACSlider);
var
  LControl: TWinControl;
  LContainer: TDACContainer;
  LForm: TForm;
  I: Integer;
begin
  for I := Low(Classes) to High(Classes) do
  begin
    LControl := Classes[I].Create(nil);
    try
      Require(not LControl.HandleAllocated,
        Classes[I].ClassName + ' criou HWND com Parent=nil.');
    finally
      LControl.Free;
    end;
  end;

  LForm := TForm.Create(nil);
  try
    LForm.SetBounds(80 + ACycle, 80 + ACycle, 800, 560);
    LContainer := TDACContainer.Create(LForm);
    LContainer.Parent := LForm;
    LContainer.Align := alClient;
    for I := Low(Classes) to High(Classes) do
    begin
      LControl := Classes[I].Create(LForm);
      LControl.Parent := LContainer;
      LControl.SetBounds(20 + (I mod 3) * 240,
        20 + (I div 3) * 100, LControl.Width, LControl.Height);
    end;
    LForm.Show;
    Application.ProcessMessages;
    Require(LForm.HandleAllocated and LContainer.HandleAllocated,
      'Lifecycle nao materializou os handles do host.');
    for I := 0 to LContainer.ControlCount - 1 do
      if LContainer.Controls[I] is TWinControl then
      begin
        LControl := TWinControl(LContainer.Controls[I]);
        LControl.HandleNeeded;
        TWinControlAccess(LControl).RecreateNativeHandle;
        Require(LControl.HandleAllocated,
          LControl.ClassName + ' perdeu HWND na recriacao.');
      end;
    LContainer.ThemeMode := dtmDark;
    LContainer.ThemeMode := dtmLight;
    LContainer.ThemeMode := dtmLight;
    Application.ProcessMessages;
  finally
    LForm.Free;
  end;
end;

procedure RunButtonEditDesignerInsertion;
var
  LButtonEdit: TDACButtonEdit;
  LForm: TForm;
begin
  { Reproduces the order used by the form designer: the component is marked as
    designing and receives property/bounds updates before Parent is assigned. }
  LButtonEdit := TDACButtonEdit.Create(nil);
  try
    TComponentAccess(LButtonEdit).EnterDesignMode;
    LButtonEdit.SetBounds(24, 24, 260, 48);
    LButtonEdit.LabelText := 'Pesquisa';
    LButtonEdit.ButtonCaption := 'Abrir';
    LButtonEdit.HelperText := 'Selecione um registro';
    Require(not LButtonEdit.HandleAllocated,
      'TDACButtonEdit criou HWND no designer antes de receber Parent.');
    Require((LButtonEdit.EditControl = nil) or
      not LButtonEdit.EditControl.HandleAllocated,
      'Editor interno criou HWND no designer antes do host receber Parent.');
    Require(not LButtonEdit.ButtonControl.HandleAllocated,
      'Botao interno criou HWND no designer antes do host receber Parent.');
  finally
    LButtonEdit.Free;
  end;

  LForm := TForm.Create(nil);
  try
    TComponentAccess(LForm).EnterDesignMode;
    LButtonEdit := TDACButtonEdit.Create(LForm);
    TComponentAccess(LButtonEdit).EnterDesignMode;
    LButtonEdit.SetBounds(32, 32, 260, 48);
    LButtonEdit.Parent := LForm;
    LButtonEdit.SetBounds(40, 40, 280, 64);
    LButtonEdit.ThemeMode := dtmDark;
    LButtonEdit.ThemeMode := dtmLight;
    Require(LButtonEdit.Parent = LForm,
      'TDACButtonEdit perdeu o Parent durante a insercao no designer.');
    Require(LButtonEdit.ButtonControl.Parent = LButtonEdit,
      'Botao interno perdeu o host durante a insercao no designer.');
    Require((LButtonEdit.EditControl = nil) or
      (LButtonEdit.EditControl.Parent = nil),
      'Editor nativo permaneceu anexado durante a previa de design.');
  finally
    LForm.Free;
  end;
end;

procedure RunNumericSuffixDesignerInsertion;
var
  LNumeric: TDACNumericEdit;
  LRightPosition: Integer;
begin
  LNumeric := TDACNumericEdit.Create(nil);
  try
    TComponentAccess(LNumeric).EnterDesignMode;
    LNumeric.SetBounds(24, 24, 220, 48);
    LNumeric.Value := 5;
    LNumeric.SuffixText := #163;
    LRightPosition := LNumeric.SuffixControl.Left;
    LNumeric.SuffixPosition := nspLeft;
    Require(LNumeric.SuffixControl.Visible and
      (LNumeric.SuffixControl.BoundsRect.Right < LRightPosition),
      'A previa do sufixo nao acompanhou a posicao a esquerda.');
    Require(not LNumeric.HandleAllocated and not LNumeric.EditControl.HandleAllocated,
      'Alterar o lado do sufixo criou HWND no designer antes de receber Parent.');
  finally
    LNumeric.Free;
  end;
end;

procedure RunDateTimeDesignerInsertion;
var
  LDate: TDACDateTimePicker;
  LForm: TForm;
begin
  LDate := TDACDateTimePicker.Create(nil);
  try
    TComponentAccess(LDate).EnterDesignMode;
    LDate.SetBounds(24, 24, 260, 64);
    LDate.LabelText := 'Data';
    LDate.FormatString := 'dd/MM/yyyy';
    LDate.DateTime := EncodeDate(2026, 8, 28);
    Require(not LDate.HandleAllocated,
      'TDACDateTimePicker criou HWND antes de receber Parent no designer.');
    Require(not LDate.PickerControl.HandleAllocated,
      'TMaskEdit de data criou HWND prematuro no designer.');
    Require(not LDate.ActionButton.HandleAllocated,
      'Caixa de calendario criou HWND prematuro no designer.');
    Require(LDate.Text = '28/08/2026',
      'Valor de data nao foi propagado ao editor herdado no designer.');
  finally
    LDate.Free;
  end;

  LForm := TForm.Create(nil);
  try
    TComponentAccess(LForm).EnterDesignMode;
    LDate := TDACDateTimePicker.Create(LForm);
    TComponentAccess(LDate).EnterDesignMode;
    LDate.Parent := LForm;
    LDate.SetBounds(40, 40, 280, 64);
    LDate.ThemeMode := dtmDark;
    LDate.ThemeMode := dtmLight;
    Require(LDate.ActionButton.Parent = LDate,
      'Caixa de calendario perdeu o host no designer.');
    Require(LDate.PickerControl.Parent = nil,
      'TMaskEdit permaneceu anexado durante a previa de design.');
  finally
    LForm.Free;
  end;
end;

procedure RunLifecycle;
var
  LGdiBefore: DWORD;
  LUserBefore: DWORD;
  I: Integer;
begin
  { Inicializa caches globais da VCL/Skia antes da medicao. Esses caches
    pertencem ao processo, nao aos ciclos de vida dos componentes. }
  RunCycle(0);
  Application.ProcessMessages;
  LGdiBefore := GetGuiResources(GetCurrentProcess, GR_GDIOBJECTS);
  LUserBefore := GetGuiResources(GetCurrentProcess, GR_USEROBJECTS);
  for I := 1 to 3 do
    RunCycle(I);
  Application.ProcessMessages;
  Require(GetGuiResources(GetCurrentProcess, GR_GDIOBJECTS) = LGdiBefore,
    'Lifecycle deixou saldo de objetos GDI.');
  Require(GetGuiResources(GetCurrentProcess, GR_USEROBJECTS) = LUserBefore,
    'Lifecycle deixou saldo de objetos USER.');
end;

begin
  try
    Application.Initialize;
    RunButtonEditDesignerInsertion;
    Writeln('TDACButtonEdit designer insertion: PASS');
    RunNumericSuffixDesignerInsertion;
    RunDateTimeDesignerInsertion;
    Writeln('TDACDateTimePicker designer insertion: PASS');
    RunLifecycle;
    Writeln('DACComponentsDesignLifecycle: PASS');
    ExitCode := 0;
  except
    on E: Exception do
    begin
      Writeln('DACComponentsDesignLifecycle: FAIL: ', E.ClassName, ': ', E.Message);
      ExitCode := 1;
    end;
  end;
end.
