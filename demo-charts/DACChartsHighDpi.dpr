program DACChartsHighDpi;

uses
  Vcl.Forms,
  DACChartsDemo.Main in 'DACChartsDemo.Main.pas' {ChartsDemoForm};

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TChartsDemoForm, ChartsDemoForm);
  Application.Run;
end.
