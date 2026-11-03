program Demo;

uses
  Vcl.Forms,
  MidasLib,
  TreeView.Demo.Main in '..\demo-treeview\TreeView.Demo.Main.pas',
  DBTreeView.Demo.Main in '..\demo-db-treeview\DBTreeView.Demo.Main.pas' {DBTreeDemoForm},
  Demo.Principal in 'Demo.Principal.pas' {Form1},
  Vcl.Themes,
  Vcl.Styles;

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  TStyleManager.TrySetStyle('Windows10');
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
