program MaxUIDemo;

{$CODEPAGE 65001}

uses
  Vcl.Forms,
  MaxUI.Hooks.Register in '..\Source\Hooks\MaxUI.Hooks.Register.pas',
  MaxUI.Demo.Main in 'MaxUI.Demo.Main.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmComponentGallery, frmComponentGallery);
  Application.Run;
end.
