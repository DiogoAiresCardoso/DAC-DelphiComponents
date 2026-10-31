program DACDBTreeViewDemo;

uses
  Vcl.Forms,
  MidasLib,
  DAC.Components.Controls.Register,
  DAC.Components.Hooks.Register,
  DBTreeView.Demo.Main in 'DBTreeView.Demo.Main.pas' {DBTreeDemoForm};

{$R '..\Build\DBTreeView\Resources\DACDBTreeViewDemo.res'}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'DAC DBTreeView - local data-aware example';
  Application.CreateForm(TDBTreeDemoForm, DBTreeDemoForm);
  Application.Run;
end.
