program DACChartsDemo;

uses
  Vcl.Forms,
  DACChartsDemo.Main in 'DACChartsDemo.Main.pas' {ChartsDemoForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TChartsDemoForm, ChartsDemoForm);
  Application.Run;
end.
