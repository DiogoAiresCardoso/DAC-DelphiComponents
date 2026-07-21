program DACComponentsInteraction;

{$APPTYPE CONSOLE}

uses
  System.Classes,
  System.SysUtils,
  Data.DB,
  Datasnap.DBClient,
  Winapi.Messages,
  Winapi.Windows,
  Vcl.ComCtrls,
  Vcl.Controls,
  Vcl.Forms,
  DAC.Components.Dpi in '..\Source\Core\DAC.Components.Dpi.pas',
  DAC.Components.Controls.Badges in '..\Source\Controls\DAC.Components.Controls.Badges.pas',
  DAC.Components.Controls.Button in '..\Source\Controls\DAC.Components.Controls.Button.pas',
  DAC.Components.Controls.Charts in '..\Source\Controls\DAC.Components.Controls.Charts.pas',
  DAC.Components.Controls.DataGrid in '..\Source\Controls\DAC.Components.Controls.DataGrid.pas',
  DAC.Components.Controls.Feedback in '..\Source\Controls\DAC.Components.Controls.Feedback.pas',
  DAC.Components.Controls.Loading in '..\Source\Controls\DAC.Components.Controls.Loading.pas',
  DAC.Components.Controls.Pagination in '..\Source\Controls\DAC.Components.Controls.Pagination.pas',
  DAC.Components.Controls.Progress in '..\Source\Controls\DAC.Components.Controls.Progress.pas',
  DAC.Components.Controls.ReportViewer in '..\Source\Controls\DAC.Components.Controls.ReportViewer.pas',
  DAC.Components.Controls.Selectors in '..\Source\Controls\DAC.Components.Controls.Selectors.pas',
  DAC.Components.Controls.StatusBar in '..\Source\Controls\DAC.Components.Controls.StatusBar.pas',
  DAC.Components.Controls.SummaryCard in '..\Source\Controls\DAC.Components.Controls.SummaryCard.pas',
  DAC.Components.Controls.Tabs in '..\Source\Controls\DAC.Components.Controls.Tabs.pas',
  Demo.Principal in '..\demo\Demo.Principal.pas' {Form1};

var
  UnexpectedException: string;
  ClickCount: Integer;

type
  TInteractionProbe = class
  public
    procedure OnApplicationException(Sender: TObject; E: Exception);
    procedure OnButtonClick(Sender: TObject);
  end;

  TFormAccess = class(TForm)
  public
    procedure FocusNext(const AControl: TWinControl);
  end;

procedure Require(const ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create(AMessage);
end;

procedure PumpMessages(const AMilliseconds: Cardinal = 100);
var
  LStart: Cardinal;
begin
  LStart := GetTickCount;
  repeat
    Application.ProcessMessages;
  until Cardinal(GetTickCount - LStart) >= AMilliseconds;
end;

procedure TInteractionProbe.OnApplicationException(Sender: TObject; E: Exception);
begin
  UnexpectedException := E.ClassName + ': ' + E.Message;
end;

procedure TInteractionProbe.OnButtonClick(Sender: TObject);
begin
  Inc(ClickCount);
end;

procedure TFormAccess.FocusNext(const AControl: TWinControl);
begin
  SelectNext(AControl, True, True);
end;

procedure SendKey(const AControl: TControl; const AKey: Word);
begin
  TWinControl(AControl).SetFocus;
  PumpMessages(20);
  AControl.Perform(WM_KEYDOWN, AKey, 0);
  AControl.Perform(WM_KEYUP, AKey, 0);
  PumpMessages(30);
end;

procedure RequireComponent(const AForm: TForm; const AName: string;
  const AClass: TClass);
var
  LComponent: TComponent;
begin
  LComponent := AForm.FindComponent(AName);
  Require((LComponent <> nil) and LComponent.InheritsFrom(AClass),
    AName + ' nao foi instanciado como ' + AClass.ClassName + '.');
end;

procedure RunInteraction;
var
  LBadge: TDACBadge;
  LButton: TDACButton;
  LCheck: TDACCheckBox;
  LDataSet: TClientDataSet;
  LDataSource: TDataSource;
  LGrid: TDACDataGrid;
  LModal: TDACModalDialog;
  LPagination: TDACPagination;
  LSlider: TDACSlider;
  LTabPage: TTabSheet;
  LTabs: TDACTabs;
  LToast: TDACToast;
  LTooltip: TDACTooltip;
  LWidthBefore: Integer;
  LProbe: TInteractionProbe;
  I: Integer;
  LExpectedRecNo: Integer;
begin
  LProbe := TInteractionProbe.Create;
  try
  Require(DACScale(36, 96) = 36, 'DPI 96 invalido.');
  Require(DACScale(36, 120) = 45, 'DPI 120 invalido.');
  Require(DACScale(36, 144) = 54, 'DPI 144 invalido.');
  Require(DACScale(36, 192) = 72, 'DPI 192 invalido.');

  Application.CreateForm(TForm1, Form1);
  Form1.Show;
  PumpMessages(150);

  RequireComponent(Form1, 'GalleryTabs', TDACTabs);
  RequireComponent(Form1, 'demoEdit', TControl);
  RequireComponent(Form1, 'demoCombo', TControl);
  RequireComponent(Form1, 'demoCheck', TDACCheckBox);
  RequireComponent(Form1, 'demoSlider', TDACSlider);
  RequireComponent(Form1, 'demoSummaryCard', TDACSummaryCard);
  RequireComponent(Form1, 'demoDataGrid', TDACDataGrid);
  RequireComponent(Form1, 'demoStatusBar', TDACStatusBar);
  RequireComponent(Form1, 'demoProgress', TDACProgress);
  RequireComponent(Form1, 'demoBadge', TDACBadge);
  RequireComponent(Form1, 'demoToast', TDACToast);
  RequireComponent(Form1, 'demoTooltip', TDACTooltip);
  RequireComponent(Form1, 'demoPagination', TDACPagination);
  RequireComponent(Form1, 'demoLoading', TDACLoading);
  RequireComponent(Form1, 'demoBarChart', TDACBarChart);
  RequireComponent(Form1, 'demoReportViewer', TDACReportViewer);

  LButton := TDACButton.Create(Form1);
  LButton.Parent := Form1;
  LButton.SetBounds(24, 24, 160, 40);
  LButton.Caption := 'Interaction button';
  LButton.BringToFront;
  LButton.OnClick := LProbe.OnButtonClick;
  SendKey(LButton, VK_RETURN);
  Require(ClickCount = 1, 'Enter nao acionou TDACButton.');
  TFormAccess(Form1).FocusNext(LButton);
  Require(Form1.ActiveControl <> nil, 'Tab nao encontrou proximo controle.');

  LCheck := TDACCheckBox.Create(Form1);
  LCheck.Parent := Form1;
  LCheck.SetBounds(24, 72, 180, 30);
  LCheck.BringToFront;
  LCheck.Checked := False;
  SendKey(LCheck, VK_SPACE);
  Require(LCheck.Checked, 'Space nao alternou TDACCheckBox.');

  LSlider := TDACSlider.Create(Form1);
  LSlider.Parent := Form1;
  LSlider.SetBounds(24, 110, 260, 36);
  LSlider.BringToFront;
  LSlider.Value := 50;
  SendKey(LSlider, VK_RIGHT);
  Require(LSlider.Value = 51, 'Seta direita nao incrementou TDACSlider.');
  SendKey(LSlider, VK_LEFT);
  Require(LSlider.Value = 50, 'Seta esquerda nao decrementou TDACSlider.');

  LTabs := Form1.FindComponent('GalleryTabs') as TDACTabs;
  LTabPage := Form1.FindComponent('tsGrid') as TTabSheet;
  LTabs.ActivePage := LTabPage;
  PumpMessages(80);

  LGrid := Form1.FindComponent('demoDataGrid') as TDACDataGrid;
  LDataSet := TClientDataSet.Create(Form1);
  LDataSource := TDataSource.Create(Form1);
  LDataSet.FieldDefs.Add('ID', ftInteger);
  LDataSet.FieldDefs.Add('STATUS', ftString, 16);
  LDataSet.FieldDefs.Add('ACTIONS', ftString, 16);
  LDataSet.CreateDataSet;
  for I := 1 to 30 do
    LDataSet.AppendRecord([I, 'Ativo', '...']);
  LDataSet.RecNo := 12;
  LDataSource.DataSet := LDataSet;
  LGrid.DataSource := LDataSource;
  LGrid.Columns.Clear;
  PumpMessages(100);
  Require(LGrid.Columns.Count = 3, 'Grid nao gerou colunas automaticas.');
  LGrid.Perform(WM_VSCROLL, SB_LINEDOWN, 0);
  PumpMessages(80);
  LExpectedRecNo := LDataSet.RecNo;
  LGrid.Redraw;
  PumpMessages(50);
  Require(LDataSet.RecNo = LExpectedRecNo,
    'A pintura apos scroll alterou o cursor do dataset.');

  LTooltip := Form1.FindComponent('demoTooltip') as TDACTooltip;
  LTooltip.TargetControl := LButton;
  LTooltip.ShowForTarget;
  PumpMessages(30);
  Require(LTooltip.Visible, 'Tooltip nao foi exibido.');
  LTooltip.HideTooltip;
  Require(not LTooltip.Visible, 'Tooltip nao foi ocultado.');

  LToast := Form1.FindComponent('demoToast') as TDACToast;
  LToast.TitleText := 'Interaction toast';
  LToast.MessageText := 'Feedback validado.';
  LToast.Visible := True;
  Require(LToast.Visible and (LToast.TitleText = 'Interaction toast'),
    'Toast nao respondeu ao feedback.');

  LModal := TDACModalDialog.Create(Form1);
  LModal.Parent := Form1;
  LModal.SetBounds(20, 20, 320, 180);
  LModal.Visible := True;
  SendKey(LModal, VK_ESCAPE);
  Require(not LModal.Visible, 'Escape nao fechou TDACModalDialog.');

  LPagination := Form1.FindComponent('demoPagination') as TDACPagination;
  LPagination.PageIndex := 2;
  Require((LPagination.PageIndex >= 1) and
    (LPagination.PageIndex <= LPagination.PageCount), 'Paginacao fora do limite.');

  LBadge := Form1.FindComponent('demoBadge') as TDACBadge;
  Require(LBadge.Visible, 'Badge nao esta visivel.');
  LWidthBefore := LTabs.Width;
  Form1.SetBounds(Form1.Left, Form1.Top, Form1.Width + 120, Form1.Height + 80);
  PumpMessages(100);
  Require(LTabs.Width <> LWidthBefore, 'Resize nao atualizou o layout das tabs.');
  Require(UnexpectedException = '', 'Excecao VCL: ' + UnexpectedException);
  finally
    LProbe.Free;
  end;
end;

var
  LExitCode: Integer;
begin
  LExitCode := 0;
  Application.Initialize;
  Application.MainFormOnTaskbar := False;
  with TInteractionProbe.Create do
  try
    Application.OnException := OnApplicationException;
    try
      RunInteraction;
      Writeln('DACComponentsInteraction: PASS');
    except
      on E: Exception do
      begin
        Writeln(E.ClassName + ': ' + E.Message);
        LExitCode := 1;
      end;
    end;
  finally
    Application.OnException := nil;
    Free;
  end;
  Form1.Free;
  ExitCode := LExitCode;
end.
