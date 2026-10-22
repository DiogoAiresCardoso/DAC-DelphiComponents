from pathlib import Path
def patch(file,fn):
 p=Path(file);s=p.read_bytes().decode('cp1252').replace('\r\n','\n');s=fn(s);p.write_bytes(s.replace('\n','\r\n').encode('cp1252'))
def engine(s):
 s=s.replace('FLabelBounds: TList<TRectF>;', 'FLabelBounds: TList<TRectF>;\n    FTexts: TJSONArray;')
 s=s.replace('FLabelBounds:=TList<TRectF>.Create;', 'FLabelBounds:=TList<TRectF>.Create; FTexts:=TJSONArray.Create;')
 s=s.replace('FFonts.Free; FLabelBounds.Free;', 'FFonts.Free; FLabelBounds.Free; FTexts.Free;')
 s=s.replace('FMarks.Clear; FLabelBounds.Clear;', 'FMarks.Clear; FLabelBounds.Clear; FTexts.Free; FTexts:=TJSONArray.Create;')
 s=s.replace('Paint: ISkPaint; Box: TRectF;', 'Paint: ISkPaint; Box: TRectF; Evidence: TJSONObject;')
 s=s.replace('    DrawText(FSurface.DC,PChar(T),Length(T),R,Flags); FSurface.OpaqueRect(R);', '''    Evidence:=TJSONObject.Create; FTexts.AddElement(Evidence);
    Evidence.AddPair('text',T); Evidence.AddPair('x',TJSONNumber.Create(X)); Evidence.AddPair('y',TJSONNumber.Create(Y));
    Evidence.AddPair('width',TJSONNumber.Create(SZ.cx)); Evidence.AddPair('height',TJSONNumber.Create(SZ.cy));
    Evidence.AddPair('rotate',TJSONNumber.Create(CN(CJ(Style,'rotate'))));
    Evidence.AddPair('font',CS(CJ(Style,'fontFamily'),'Arial'));
    Evidence.AddPair('fontSize',TJSONNumber.Create(CN(CJ(Style,'fontSize'),12)*FScale));
    Evidence.AddPair('clipped',TJSONBool.Create((X<0) or (Y<0) or (X+Min(SZ.cx,R.Width)>FSurface.Width) or (Y+SZ.cy>FSurface.Height)));
    DrawText(FSurface.DC,PChar(T),Length(T),R,Flags); FSurface.OpaqueRect(R);''')
 s=s.replace("    A:=TJSONArray.Create; O.AddPair('marks',A);", "    O.AddPair('texts',TJSONValue(FTexts.Clone));\n    O.AddPair('resolvedOption',TJSONValue(FOptions.Clone));\n    A:=TJSONArray.Create; O.AddPair('marks',A);")
 s=s.replace('R0,R1,CX,CY,Sign,V: Double;', 'R0,R1,CX,CY,CenterX,CenterY,Shift,Sign,V: Double;')
 s=s.replace("  for P:=0 to N-1 do begin\n    if S.Values[P].Missing or IsHidden(S.Values[P].Name) then Continue;", "  CenterX:=CX; CenterY:=CY;\n  for P:=0 to N-1 do begin\n    if S.Values[P].Missing or IsHidden(S.Values[P].Name) then Continue;")
 s=s.replace("    if Abs(Sweep)<1E-10 then Continue;",'''    if Abs(Sweep)<1E-10 then Continue;
    Shift:=0;
    if FSelected.ContainsKey(IntToStr(I)+'|'+S.Values[P].Name) then Shift:=CN(CJ(Opt,'selectedOffset'),10)*FScale;
    CX:=CenterX+Shift*Cos(DegToRad(Angle+Sweep/2)); CY:=CenterY+Shift*Sin(DegToRad(Angle+Sweep/2));
    Outer:=TRectF.Create(CX-R1,CY-R1,CX+R1,CY+R1); Inner:=TRectF.Create(CX-R0,CY-R0,CX+R0,CY+R0);''')
 return s
patch('Source/Skia/DAC.Components.Charts.Engine.pas',engine)
def demo(s):
 s=s.replace('S,P,I: Integer; Series: TJSONObject; Start: Cardinal;', 'S,P,I,Points,Frames,DPI: Integer; Series: TJSONObject; Start: Cardinal;')
 s=s.replace('  O:=TJSONObject.Create; A:=TJSONArray.Create;\n  try', '''  Points:=Max(6,StrToIntDef(Arg('--points','996'),996));
  Frames:=Max(1,StrToIntDef(Arg('--frames','120'),120));
  DPI:=StrToIntDef(Arg('--dpi','144'),144);
  SendMessage(FStress.Handle,WM_DPICHANGED,MakeWParam(DPI,DPI),0);
  O:=TJSONObject.Create; A:=TJSONArray.Create;
  try''')
 s=s.replace('for P:=0 to 165 do', 'for P:=0 to (Points div 6)-1 do')
 s=s.replace('for I:=0 to 119 do', 'for I:=0 to Frames-1 do')
 s=s.replace('100+I*3,150', '100+(I*3 mod 500),150')
 s=s.replace('var OutDir,Id,CaseId: string; A: TJSONArray; I: Integer;', 'var OutDir,Id,CaseId: string; A: TJSONArray; I,Matches: Integer; Bitmap: TBitmap; PNG: TPngImage;')
 s=s.replace("    Pages.ActivePage:=ConfigTab;", '''    Pages.ActivePage:=GalleryTab; Update; Application.ProcessMessages;
    Bitmap:=TBitmap.Create; PNG:=TPngImage.Create;
    try Bitmap.SetSize(ClientWidth,ClientHeight); PaintTo(Bitmap.Canvas.Handle,0,0);
      PNG.Assign(Bitmap); PNG.SaveToFile(TPath.Combine(OutDir,'gallery.png'));
    finally PNG.Free; Bitmap.Free; end;
    Matches:=0;
    Pages.ActivePage:=ConfigTab;''')
 s=s.replace("      FChart.LoadJSON(CJ(A.Items[I],'option').ToJSON);", "      Inc(Matches); FChart.LoadJSON(CJ(A.Items[I],'option').ToJSON);")
 s=s.replace("    if Arg('--stress','')<>'' then begin", "    if Matches=0 then raise Exception.Create('Cenario nao encontrado: '+CaseId);\n    if Arg('--stress','')<>'' then begin")
 return s
patch('demo-charts/DACChartsDemo.Main.pas',demo)
