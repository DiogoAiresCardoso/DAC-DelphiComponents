program DACDemoStartupCurrent;

{$APPTYPE CONSOLE}
{$MINSTACKSIZE $00200000}

uses
  System.SysUtils,
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
