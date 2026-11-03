program DACTreeViewDemo;

uses
  Vcl.Forms,
  DAC.Components.Controls.Register,
  DAC.Components.Hooks.Register,
  TreeView.Demo.Main in 'TreeView.Demo.Main.pas';

{$R '..\Build\TreeView\Resources\DACTreeViewDemo.res'}

var DemoForm: TTreeDemoForm;

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'DAC TreeView - itens e objetos';
  Application.CreateForm(TTreeDemoForm,DemoForm);
  Application.Run;
end.
