from pathlib import Path
p=Path('Source/Skia/DAC.Components.Charts.Engine.pas');s=p.read_bytes().decode('cp1252').replace('\r\n','\n')
pos=s.index('procedure TDACChartEngine.DrawSeries')
s=s[:pos]+'''{ Control-point constraints follow Apache ECharts 6.1.0 poly.ts.
  See docs/charts/echarts-reference/NOTICE.md for attribution. }
procedure ChartPolyline(const Path: ISkPathBuilder; const Points: TArray<TPointF>;
  Smooth: Double; const Step,Monotone: string; Move: Boolean = True);
var I: Integer; P,Prev,Next,C0,C1,NextC: TPointF; L0,L1,Ratio,VX,VY,D: Double;
begin
  if Length(Points)=0 then Exit;
  Prev:=Points[0]; C0:=Prev;
  if Move then Path.MoveTo(Prev) else Path.LineTo(Prev);
  for I:=1 to High(Points) do begin
    P:=Points[I]; L0:=Hypot(P.X-Prev.X,P.Y-Prev.Y);
    if L0<0.0001 then Continue;
    if Step<>'' then begin
      if Step='middle' then begin Path.LineTo((Prev.X+P.X)/2,Prev.Y); Path.LineTo((Prev.X+P.X)/2,P.Y); end
      else if Step='start' then Path.LineTo(Prev.X,P.Y) else Path.LineTo(P.X,Prev.Y);
      Path.LineTo(P);
    end else if Smooth>0 then begin
      C1:=P; NextC:=P;
      if I<High(Points) then begin
        Next:=Points[I+1]; L1:=Hypot(Next.X-P.X,Next.Y-P.Y);
        if L1>0.0001 then begin
          if Monotone='x' then begin
            D:=Sign(Next.X-Prev.X); C1:=PointF(P.X-D*Abs(P.X-Prev.X)*Smooth,P.Y);
            NextC:=PointF(P.X+D*Abs(Next.X-P.X)*Smooth,P.Y);
          end else if Monotone='y' then begin
            D:=Sign(Next.Y-Prev.Y); C1:=PointF(P.X,P.Y-D*Abs(P.Y-Prev.Y)*Smooth);
            NextC:=PointF(P.X,P.Y+D*Abs(Next.Y-P.Y)*Smooth);
          end else begin
            Ratio:=L1/(L0+L1); VX:=Next.X-Prev.X; VY:=Next.Y-Prev.Y;
            NextC:=PointF(EnsureRange(P.X+VX*Smooth*Ratio,Min(P.X,Next.X),Max(P.X,Next.X)),
              EnsureRange(P.Y+VY*Smooth*Ratio,Min(P.Y,Next.Y),Max(P.Y,Next.Y)));
            C1:=PointF(EnsureRange(P.X-(NextC.X-P.X)*L0/L1,Min(P.X,Prev.X),Max(P.X,Prev.X)),
              EnsureRange(P.Y-(NextC.Y-P.Y)*L0/L1,Min(P.Y,Prev.Y),Max(P.Y,Prev.Y)));
            NextC:=PointF(P.X+(P.X-C1.X)*L1/L0,P.Y+(P.Y-C1.Y)*L1/L0);
          end;
        end;
      end;
      Path.CubicTo(C0.X,C0.Y,C1.X,C1.Y,P.X,P.Y); C0:=NextC;
    end else Path.LineTo(P);
    Prev:=P;
  end;
end;
'''+s[pos:]
s=s.replace('Pt,BasePt,Prev: TPointF;', 'Pt,BasePt: TPointF;')
s=s.replace('Style,LV: TJSONValue; Band,BW,Gap,Offset,Radius,Y,Origin: Double; Connected,HasArea: Boolean;\n  Seen: TStringList;', '''Style,LV: TJSONValue; Band,BW,Gap,Offset,Radius,Y,Smooth: Double; HasArea: Boolean;
  Seen: TStringList; Segment,Bases: TList<TPointF>; Rev: TArray<TPointF>; J: Integer; Step: string;
  procedure FlushSegment;
  var B: Integer;
  begin
    if Segment.Count=0 then Exit;
    ChartPolyline(Path,Segment.ToArray,Smooth,Step,CS(CJ(S.Options,'smoothMonotone')));
    if HasArea then begin
      Area:=TSkPathBuilder.Create;
      ChartPolyline(Area,Segment.ToArray,Smooth,Step,CS(CJ(S.Options,'smoothMonotone')));
      SetLength(Rev,Bases.Count); for B:=0 to Bases.Count-1 do Rev[B]:=Bases[Bases.Count-1-B];
      ChartPolyline(Area,Rev,0,Step,'',False); Area.Close;
      Paint:=PaintFor(CJ(S.Options,'areaStyle'),Palette(I),FPlot);
      Paint.AlphaF:=CN(CJ(CJ(S.Options,'areaStyle'),'opacity'),0.7);
      FC.DrawPath(Area.Snapshot,Paint);
    end;
    Segment.Clear; Bases.Clear;
  end;''')
s=s.replace('Path:=TSkPathBuilder.Create; Area:=TSkPathBuilder.Create; Connected:=False;', '''Path:=TSkPathBuilder.Create;
  Smooth:=CN(CJ(S.Options,'smooth')); if CB(CJ(S.Options,'smooth')) then Smooth:=0.5;
  Step:=CS(CJ(S.Options,'step')); if Step='false' then Step:=''; if Step='true' then Step:='end';
  Segment:=TList<TPointF>.Create; Bases:=TList<TPointF>.Create;
  try''')
s=s.replace("if not CB(CJ(S.Options,'connectNulls')) then Connected:=False;","if not CB(CJ(S.Options,'connectNulls')) then FlushSegment;")
a=s.index('      if not Connected then Path.MoveTo');b=s.index("      Radius:=CN(CJ(S.Options,'symbolSize')",a)
s=s[:a]+'''      Segment.Add(Pt); Bases.Add(BasePt);
'''+s[b:]
needle="  if S.Kind='line' then begin\n    LinePaint:="
s=s.replace(needle,"  FlushSegment;\n  finally Segment.Free; Bases.Free; end;\n"+needle)
s=s.replace("  Rich:=CJ(Style,'rich');", "  W:=0; Rich:=CJ(Style,'rich');")
s=s.replace('Seen: TStringList; Segment,Bases: TList<TPointF>; Rev: TArray<TPointF>; J: Integer; Step: string;', 'Seen: TStringList; Segment,Bases: TList<TPointF>; Rev: TArray<TPointF>; Step: string;')
# Tooltip series must meet at the same coordinate, not an unrelated row index.
s=s.replace('(N.DataIndex=M.DataIndex)',"(Abs(FSeries[N.SeriesIndex].Values[N.DataIndex].X-FSeries[M.SeriesIndex].Values[M.DataIndex].X)<1E-8)")
s=s.replace("Lines.Add(S);\n      end;\n    end;\n    W:=0;", "Lines.AddObject(S,TObject(NativeInt(N.SeriesIndex)+1));\n      end;\n    end;\n    W:=0;")
s=s.replace("    for I:=0 to Lines.Count-1 do Text(Lines[I],X+10*FScale,Y+(10+I*20)*FScale,CJ(V,'textStyle'),'left',W-20*FScale);",'''    for I:=0 to Lines.Count-1 do begin
      if I>0 then begin
        Paint:=PaintFor(nil,Palette(NativeInt(Lines.Objects[I])-1),R);
        FC.DrawCircle(X+14*FScale,Y+(17+I*20)*FScale,4*FScale,Paint);
      end;
      Text(Lines[I],X+(10+16*Ord(I>0))*FScale,Y+(10+I*20)*FScale,CJ(V,'textStyle'),'left',W-36*FScale);
    end;''')
p.write_bytes(s.replace('\n','\r\n').encode('cp1252'))
p=Path('Source/Controls/DAC.Components.Charts.Options.pas');s=p.read_bytes().decode('cp1252');s=s.replace('selectedOffset|smooth|step','selectedOffset|smooth|smoothMonotone|step');p.write_bytes(s.encode('cp1252'))
for name in ['DACChartsHighDpi','DACChartsNoHighDpi']:
 p=Path('demo-charts/'+name+'.dproj');s=p.read_bytes().decode('utf-8');needle='    <Copy SourceFiles="$(DAC_SkiaRuntimeSource)" DestinationFiles="$(DCC_ExeOutput)\\sk4d.dll"/>'
 if 'reference-cases.json' not in s:s=s.replace(needle,needle+'\r\n    <Copy SourceFiles="..\\Tests\\Charts.Visual\\fixtures.json" DestinationFiles="$(DCC_ExeOutput)\\reference-cases.json"/>')
 p.write_bytes(s.encode('utf-8'))
