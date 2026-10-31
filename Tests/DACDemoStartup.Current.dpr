program DACDemoStartupCurrent;

{$APPTYPE CONSOLE}
{$MINSTACKSIZE $00200000}

uses
  System.SysUtils,
  System.Variants,
  MidasLib,
  DAC.Components.DesignSystem.IconAssets,
  Vcl.Forms,
  Demo.Principal in '..\demo\Demo.Principal.pas' {Form1};

procedure Require(const ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create(AMessage);
end;

begin
  try
    Application.Initialize;
    Form1 := TForm1.Create(nil);
    try
      Form1.Show;
      Application.ProcessMessages;
      Require(Form1.HandleAllocated, 'Demo nao criou a janela principal.');
      Require(Form1.GalleryTabs <> nil, 'Demo nao criou a galeria.');
      Require(Form1.GalleryTabs.PageCount > 0, 'Demo iniciou sem paginas.');
      Require((Form1.btnIconFileJson.IconKind = mikFileJson) and
        (Form1.btnIconFolderOpen.IconKind = mikFolderOpen) and
        (Form1.btnIconDatabase.IconKind = mikDatabase), 'Novos icones nao carregaram do DFM real.');
      Form1.GalleryTabs.ActiveIndex := Form1.tsButtons.PageIndex;
      Application.ProcessMessages;
      Require((Form1.btnIconFileJson.Parent = Form1.gcButtonIcons) and
        (Form1.btnIconFolderOpen.Parent = Form1.gcButtonIcons) and
        (Form1.btnIconDatabase.Parent = Form1.gcButtonIcons), 'Exemplos fora da secao de icones.');
      Require(Form1.btnIconDatabase.Width >= Form1.btnIconDatabase.MinimumContentWidth,
        'Exemplo com icone nao recebeu a largura minima de conteudo.');
      Require(Form1.tsDBTreeView <> nil, 'Official DBTreeView gallery page missing.');
      Require(Form1.DBTreeDemo <> nil, 'Official gallery did not create the data-aware example.');
      Require(Form1.DBTreeDemo.Parent = Form1.tsDBTreeView, 'Tree example is outside official gallery.');
      Require(Form1.DBTreeDemo.Tree.IsDataValid, 'Official tree dataset was not loaded.');
      Form1.GalleryTabs.ActivePage := Form1.tsDBTreeView;
      Application.ProcessMessages;
      Require(Form1.DBTreeDemo.Tree.Showing, 'Official tree page is not visible.');
      Require(Form1.DBTreeDemo.Tree.TrySetChecked('011', True), 'Official example check failed.');
      Require(Length(Form1.DBTreeDemo.Tree.CheckedKeys) = 1, 'Official example did not preserve marking.');
      Require(not Form1.DBTreeDemo.Tree.TrySetChecked('001', True), 'Official example allowed a blocked group.');
      Form1.DBTreeDemo.Search.Text := 'produtos';
      Require(Form1.DBTreeDemo.Tree.Model.Visible.Count = 3, 'Official search did not preserve ancestors.');
      Form1.DBTreeDemo.Search.Clear;
      Form1.Hide;
      Application.ProcessMessages;
    finally
      Form1.Free;
      Form1 := nil;
    end;
    Writeln('DACDemoStartup: PASS');
    ExitCode := 0;
  except
    on E: Exception do
    begin
      Writeln('DACDemoStartup: FAIL: ', E.ClassName, ': ', E.Message);
      ExitCode := 1;
    end;
  end;
end.
