program ChartDiagnostic;
{$APPTYPE CONSOLE}
uses
  System.SysUtils, System.Classes, System.Types, Data.DB, Datasnap.DBClient,
  Vcl.Forms,
  DAC.Components.Controls.Charts in 'DAC.Components.Controls.Charts.pas',
  DACComponentsCharts.ClientDataSetAdapter in '..\..\Tests\DACComponentsCharts.ClientDataSetAdapter.pas';

procedure Point(S: TDACChartSeries; const C: string; X, Y: Double);
var P: TDACChartPoint;
begin
  P := S.Points.Add; P.Category := C; P.XValue := X; P.Value := Y;
end;

procedure ManualCases;
var C: TDACChart; S: TDACChartSeries; Snap: TDACChartSnapshot;
  H: TDACChartHitArea; T: TDACChartNativeTextItem; R: TRectF;
begin
  C := TDACChart.Create(nil);
  try
    C.Animation.Enabled := False; C.Legend.Visible := False;
    C.Width := 800; C.Height := 500;
    S := C.Series.Add; S.ChartType := ctLine;
    Point(S, 'A', 0, 10); Point(S, 'B', 1, 20); Point(S, 'C', 100, 30);
    C.XAxis.AxisType := catValue;
    C.BuildManualSnapshot(Snap); C.BuildGeometry(Snap);
    R := C.ChartRect(TRectF.Create(0,0,C.Width,C.Height), Snap);
    for H in C.FHitAreas do
      if H.Shape = chsCircle then
        Writeln(Format('numeric X point %d normalized=%.4f', [H.PointIndex, (H.Center.X-R.Left)/R.Width]));
    C.XAxis.AutoScale := False; C.XAxis.Min := 0; C.XAxis.Max := 200;
    C.BuildGeometry(Snap);
    for H in C.FHitAreas do
      if (H.Shape = chsCircle) and (H.PointIndex = 2) then
        Writeln(Format('X=100 with axis 0..200 normalized=%.4f', [(H.Center.X-R.Left)/R.Width]));
    C.XAxis.AxisType := catCategory; C.BuildGeometry(Snap);
    for T in C.FNativeStaticTextItems do
      if (T.Text='A') or (T.Text='B') or (T.Text='C') then
        Writeln('category label: ', T.Text);
    S.Points.Delete(2); C.BuildManualSnapshot(Snap); C.BuildGeometry(Snap);
    for T in C.FNativeStaticTextItems do
      if (T.Text='A') or (T.Text='B') then Writeln('two-point label: ', T.Text);
    C.YAxis.AutoScale := False; C.YAxis.Min := 0; C.YAxis.Max := 100;
    C.BuildGeometry(Snap);
    for T in C.FNativeStaticTextItems do
      if (T.Text='105') or (T.Text='-5') then Writeln('manual Y limit label: ', T.Text);
    C.Series.Clear; S := C.Series.Add; S.ChartType := ctBar;
    Point(S,'A',0,10); Point(S,'B',1,20); Point(S,'C',2,30);
    S := C.Series.Add; S.ChartType := ctLine;
    Point(S,'A',0,10); Point(S,'B',1,20); Point(S,'C',2,30);
    C.BuildManualSnapshot(Snap); C.BuildGeometry(Snap);
    R := C.ChartRect(TRectF.Create(0,0,C.Width,C.Height), Snap);
    for H in C.FHitAreas do
      if H.PointIndex=0 then
        if H.Shape=chsCircle then Writeln(Format('mixed A line normalized=%.4f', [(H.Center.X-R.Left)/R.Width]))
        else if H.Shape=chsRectangle then Writeln(Format('mixed A bar normalized=%.4f', [((H.Rect.Left+H.Rect.Right)/2-R.Left)/R.Width]));
  finally C.Free; end;
end;

procedure DatasetCases;
var C: TDACChart; S: TDACChartSeries; D: TClientDataSet; DS: TDataSource;
  Snap: TDACChartSnapshot; V: TDACChartValue;
begin
  C := TDACChart.Create(nil); D := TClientDataSet.Create(nil); DS := TDataSource.Create(nil);
  try
    D.FieldDefs.Add('X',ftFloat); D.FieldDefs.Add('Y',ftFloat); D.FieldDefs.Add('OTHER',ftFloat);
    D.CreateDataSet; D.AppendRecord([10.0,10.0,90.0]); D.AppendRecord([100.0,20.0,80.0]);
    DS.DataSet := D; C.DataSource := DS; C.DataMode := cdmDataSource;
    S := C.Series.Add; S.EncodeX := 'X'; S.EncodeY := 'Y';
    C.XAxis.AxisType := catValue; C.BuildSnapshotFromDataSet(Snap);
    for V in Snap.Series[0].Values do Writeln(Format('dataset category=%s XValue=%.0f', [V.Category,V.XValue]));
    S.EncodeY := 'MISSING';
    try
      C.BuildSnapshotFromDataSet(Snap);
      Writeln('missing field: NO EXCEPTION; IsNull=', BoolToStr(Snap.Series[0].Values[0].IsNull, True));
    except on E:Exception do Writeln('missing field: ', E.Message); end;
    S.EncodeY := 'Y'; S.EncodeValue := 'OTHER'; S.ChartType := ctPie;
    C.BuildSnapshotFromDataSet(Snap);
    Writeln(Format('pie both encodes: value=%.0f (EncodeY=10; EncodeValue=90)', [Snap.Series[0].Values[0].Value]));
    D.Filter := 'Y=10'; D.Filtered := True;
    C.BuildSnapshotFromDataSet(Snap);
    Writeln(Format('filtered source count=%d snapshot count=%d', [D.RecordCount, Length(Snap.Series[0].Values)]));
  finally DS.Free; D.Free; C.Free; end;
end;

procedure BoundaryCases;
var C: TDACChart; S: TDACChartSeries; Snap: TDACChartSnapshot;
  H, Hit: TDACChartHitArea;
begin
  C := TDACChart.Create(nil);
  try
    C.Animation.Enabled := False; C.Legend.Visible := False;
    C.BuildManualSnapshot(Snap); C.BuildGeometry(Snap);
    Writeln('empty geometry: OK');
    S := C.Series.Add; S.ChartType := ctLine; Point(S,'A',0,5);
    C.BuildManualSnapshot(Snap); C.BuildGeometry(Snap);
    Writeln('single point hit count=',C.FHitAreas.Count);
    Point(S,'B',1,5); Point(S,'C',2,5);
    C.BuildManualSnapshot(Snap); C.BuildGeometry(Snap);
    Writeln('equal values hit count=',C.FHitAreas.Count);
    S.Points[1].IsNull := True;
    C.BuildManualSnapshot(Snap); C.BuildGeometry(Snap);
    Writeln('null gap hit count=',C.FHitAreas.Count);
    S.Points.Clear; S.ChartType := ctDoughnut; Point(S,'A',0,0);
    C.BuildManualSnapshot(Snap); C.BuildGeometry(Snap);
    Writeln('zero doughnut hit count=',C.FHitAreas.Count);
    S.Points[0].Value := 10;
    C.BuildManualSnapshot(Snap); C.BuildGeometry(Snap);
    H := C.FHitAreas[0];
    Writeln('doughnut hole hit=',BoolToStr(C.TryHitTest(H.Center,Hit),True));
  finally C.Free; end;
end;

begin
  Application.Initialize;
  try ManualCases; DatasetCases; BoundaryCases;
  except on E:Exception do begin Writeln(E.ClassName, ': ', E.Message); Halt(1); end; end;
end.
