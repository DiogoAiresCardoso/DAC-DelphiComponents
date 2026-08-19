program MaxUISmoke;

{$CODEPAGE 65001}

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  Vcl.Forms,
  Vcl.Controls,
  MaxUI.Types in '..\Source\Core\MaxUI.Types.pas',
  MaxUI.Dpi in '..\Source\Core\MaxUI.Dpi.pas',
  MaxUI.Theme in '..\Source\Core\MaxUI.Theme.pas',
  MaxUI.Icons in '..\Source\Core\MaxUI.Icons.pas',
  MaxUI.Painter in '..\Source\Core\MaxUI.Painter.pas',
  MaxUI.Controls.Base in '..\Source\Controls\MaxUI.Controls.Base.pas',
  MaxUI.Controls.Buttons in '..\Source\Controls\MaxUI.Controls.Buttons.pas',
  MaxUI.Controls.Inputs in '..\Source\Controls\MaxUI.Controls.Inputs.pas',
  MaxUI.Controls.Selectors in '..\Source\Controls\MaxUI.Controls.Selectors.pas',
  MaxUI.Controls.Choices in '..\Source\Controls\MaxUI.Controls.Choices.pas',
  MaxUI.Controls.Tabs in '..\Source\Controls\MaxUI.Controls.Tabs.pas',
  MaxUI.Controls.Cards in '..\Source\Controls\MaxUI.Controls.Cards.pas',
  MaxUI.Controls.Data in '..\Source\Controls\MaxUI.Controls.Data.pas',
  MaxUI.Controls.Feedback in '..\Source\Controls\MaxUI.Controls.Feedback.pas',
  MaxUI.Controls.Charts in '..\Source\Controls\MaxUI.Controls.Charts.pas',
  MaxUI.Controls.Report in '..\Source\Controls\MaxUI.Controls.Report.pas',
  MaxUI.Hooks.Buttons in '..\Source\Hooks\MaxUI.Hooks.Buttons.pas',
  MaxUI.Hooks.Inputs in '..\Source\Hooks\MaxUI.Hooks.Inputs.pas',
  MaxUI.Hooks.Selectors in '..\Source\Hooks\MaxUI.Hooks.Selectors.pas',
  MaxUI.Hooks.Choices in '..\Source\Hooks\MaxUI.Hooks.Choices.pas',
  MaxUI.Hooks.Register in '..\Source\Hooks\MaxUI.Hooks.Register.pas';

var
  Host: TForm;
  Button: TMaxButton;
  Edit: TMaxEdit;
  Slider: TMaxSlider;
  Chart: TMaxChart;
  Report: TMaxReportViewer;
begin
  Application.Initialize;
  Host := TForm.Create(nil);
  try
    Button := TMaxButton.Create(Host);
    Button.Parent := Host;
    Assert(Button.Kind = mbkPrimary);
    Assert(Button.Height > 0);

    Edit := TMaxEdit.Create(Host);
    Edit.Parent := Host;
    Edit.Placeholder := 'Teste';
    Assert(Edit.Placeholder = 'Teste');

    Slider := TMaxSlider.Create(Host);
    Slider.Parent := Host;
    Slider.Position := 150;
    Assert(Slider.Position = Slider.Maximum);

    Chart := TMaxChart.Create(Host);
    Chart.Parent := Host;
    Assert(Chart.Data.Count > 0);

    Report := TMaxReportViewer.Create(Host);
    Report.Parent := Host;
    Assert(Report.Items.Count > 0);

    RegisterMaxUIHooks;
    Assert(MaxUIHooksRegistered);
    UnregisterMaxUIHooks;
    Assert(not MaxUIHooksRegistered);
    RegisterMaxUIHooks;

    Writeln('MaxUI smoke test concluído.');
  finally
    Host.Free;
  end;
end.
