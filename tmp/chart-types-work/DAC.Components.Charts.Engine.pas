unit DAC.Components.Charts.Engine;

interface

uses System.Classes, System.SysUtils, System.Types, System.UITypes,
  System.JSON, System.Generics.Collections, System.Skia, Winapi.Windows,
  DAC.Components.Charts.Options, DAC.Components.Charts.Surface;

type
  TDACChartDatum = record
    X,Y,Base: Double;
    Name,Id: string;
    Missing: Boolean;
    Item: TJSONValue;
  end;
  TDACChartRenderSeries = record
    Name,Kind,Stack: string;
    Options: TJSONValue;
    Values: TArray<TDACChartDatum>;
  end;
  TDACChartMark = record
    SeriesIndex,DataIndex: Integer;
    Kind,Name: string;
    X,Y,Value,Base,CX,CY,R0,R,StartAngle,Sweep: Double;
    Bounds: TRectF;
  end;
  TDACChartFormatEvent = procedure(Sender: TObject; const SeriesIndex,
    DataIndex: Integer; const Name: string; const Value: Double;
    var Text: string) of object;
  TDACChartEngine = class
  private
    FOptions: TJSONObject;
    FSeries: TArray<TDACChartRenderSeries>;
    FMarks: TList<TDACChartMark>;
    FHidden: TDictionary<string,Boolean>;
    FSelected: TDictionary<string,Boolean>;
    FPrevious: TDictionary<string,Double>;
    FFonts: TDictionary<string,HFONT>;
    FLabelBounds: TList<TRectF>;
    FTexts: TJSONArray;
    FC: ISkCanvas;
    FSurface: TDACChartSurface;
    FPlot: TRectF;
    FScale: Single;
    FXMin,FXMax,FYMin,FYMax: Double;
    FXCategory,FYCategory,FBands,FXInverse,FYInverse: Boolean;
    FCategories: TArray<string>;
    FHover: Integer;
    FHoveredSeries,FHoveredData: Integer;
    FMouse: TPointF;
    FProgress: Double;
    FLegendPage: Integer;
    FOnFormat: TDACChartFormatEvent;
    FTooltipVisible: Boolean;
    function Palette(I: Integer): TAlphaColor;
    function ItemStyle(S,P: Integer): TJSONObject;
    function Color(V: TJSONValue; Default: TAlphaColor): TAlphaColor;
    function Coord(X,Y: Double): TPointF;
    function LengthValue(V: TJSONValue; Total,Default: Double): Double;
    function PaintFor(V: TJSONValue; Default: TAlphaColor; const R: TRectF;
      Stroke: Boolean = False): ISkPaint;
    function NativeFont(Style: TJSONValue): HFONT;
    function TextWidth(const S: string; Style: TJSONValue): Double;
    procedure Text(const S: string; X,Y: Double; Style: TJSONValue;
      const Align: string = 'left'; MaxWidth: Double = 0);
    procedure LoadData;
    procedure DrawAxes;
    procedure DrawSeries(I: Integer);
    procedure DrawPie(I: Integer);
    procedure DrawTitle;
    procedure DrawLegend;
    procedure DrawTooltip;
    procedure DrawLabel(const M: TDACChartMark; V: TJSONValue);
    function AnimatedValue(S,P: Integer): Double;
    function IsHidden(const Name: string): Boolean;
    function ValueKey(S,P: Integer): string;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Configure(const JSON: string);
    procedure Render(Target: TDACChartSurface; W,H,Dpi: Integer;
      const Mouse: TPointF; Progress: Double = 1);
    function HitTest(const P: TPointF): Integer;
    procedure Activate(const P: TPointF);
    function GeometryJSON: string;
    function DataCount: Integer;
    function NativeFontCount: Integer;
    property Marks: TList<TDACChartMark> read FMarks;
    property Options: TJSONObject read FOptions;
    property OnFormat: TDACChartFormatEvent read FOnFormat write FOnFormat;
    property TooltipVisible: Boolean read FTooltipVisible write FTooltipVisible;
  end;

implementation

uses System.Math, System.DateUtils, System.StrUtils;

function Arr(V: TJSONValue; I: Integer): TJSONValue;
begin
  Result:=nil;
  if (V is TJSONArray) and (I>=0) and (I<TJSONArray(V).Count) then Result:=TJSONArray(V).Items[I];
end;
function Count(V: TJSONValue): Integer;
begin Result:=0; if V is TJSONArray then Result:=TJSONArray(V).Count; end;
function Numeric(V: TJSONValue): Double;
var D: TDateTime;
begin
  if (V=nil) or (V is TJSONNull) or (CS(V)='-') then Exit(NaN);
  Result:=CN(V,NaN);
  if IsNan(Result) and TryISO8601ToDate(CS(V),D,True) then Result:=DateTimeToUnix(D,True)*1000;
end;
function NiceStep(V: Double): Double;
var P,F: Double;
begin
  if V<=0 then Exit(1);
  P:=Power(10,Floor(Log10(V))); F:=V/P;
  if F<1.5 then F:=1 else if F<2.5 then F:=2 else if F<4 then F:=3 else if F<7 then F:=5 else F:=10;
  Result:=P*F;
end;
constructor TDACChartEngine.Create;
begin
  inherited; FOptions:=TJSONObject.Create;
  FMarks:=TList<TDACChartMark>.Create;
  FHidden:=TDictionary<string,Boolean>.Create;
  FSelected:=TDictionary<string,Boolean>.Create;
  FPrevious:=TDictionary<string,Double>.Create;
  FFonts:=TDictionary<string,HFONT>.Create;
  FLabelBounds:=TList<TRectF>.Create; FTexts:=TJSONArray.Create;
  FHover:=-1;
  FTooltipVisible:=True;
end;
destructor TDACChartEngine.Destroy;
var Font: HFONT;
begin
  for Font in FFonts.Values do DeleteObject(Font);
  FFonts.Free; FLabelBounds.Free; FTexts.Free;
  FPrevious.Free; FSelected.Free; FHidden.Free; FMarks.Free; FOptions.Free; inherited;
end;
function TDACChartEngine.ValueKey(S,P: Integer): string;
begin Result:=CS(CJ(FSeries[S].Options,'id'),CS(CJ(FSeries[S].Options,'name'),IntToStr(S)))+'|'+FSeries[S].Values[P].Id; end;
procedure TDACChartEngine.Configure(const JSON: string);
var O,Old: TJSONObject; V: TJSONValue; S,P: Integer; Pair: TJSONPair;
  Previous: TDictionary<string,Double>;
begin
  V:=TJSONObject.ParseJSONValue(JSON);
  if not (V is TJSONObject) then begin V.Free; raise EDACChartOptionError.Create('JSON invalido'); end;
  O:=TJSONObject(V);
  try ValidateChartOptions(O); except O.Free; raise; end;
  Previous:=TDictionary<string,Double>.Create;
  for S:=0 to High(FSeries) do for P:=0 to High(FSeries[S].Values) do
    if not FSeries[S].Values[P].Missing then Previous.AddOrSetValue(ValueKey(S,P),AnimatedValue(S,P));
  FPrevious.Free; FPrevious:=Previous;
  Old:=FOptions; FOptions:=O;
  try
    LoadData;
  except
    FOptions:=Old; O.Free; LoadData; raise;
  end;
  Old.Free; FHidden.Clear;
  V:=CJ(CJ(FOptions,'legend'),'selected');
  if V is TJSONObject then for Pair in TJSONObject(V) do
    if CB(Pair.JsonValue,True) then FHidden.Remove(Pair.JsonString.Value)
    else FHidden.AddOrSetValue(Pair.JsonString.Value,True);
  LoadData;
end;
procedure TDACChartEngine.LoadData;
var A,D,Source,Dims,Row,V,Enc,XV,YV,Item,Names: TJSONValue;
  S,P,K,N,StartRow,XCol,YCol: Integer; ByRow,HasHeader: Boolean;
  function Dimension(E: TJSONValue; Default: Integer): Integer;
  var J: Integer; DN: TJSONValue;
  begin
    Result:=Default;
    if E is TJSONArray then E:=Arr(E,0);
    if E=nil then Exit;
    if E is TJSONNumber then Exit(Round(CN(E)));
    for J:=0 to Count(Dims)-1 do begin
      DN:=Arr(Dims,J); if DN is TJSONObject then DN:=CJ(DN,'name');
      if CS(DN)=CS(E) then Exit(J);
    end;
    if HasHeader then for J:=0 to Count(Arr(Source,0))-1 do
      if CS(Arr(Arr(Source,0),J))=CS(E) then Exit(J);
    raise EDACChartOptionError.Create('encode: dimensao ausente '+CS(E));
  end;
  function Cell(R: TJSONValue; C: Integer): TJSONValue;
  var NameV: TJSONValue;
  begin
    if R is TJSONArray then Exit(Arr(R,C));
    NameV:=Arr(Dims,C); if NameV is TJSONObject then NameV:=CJ(NameV,'name');
    Result:=CJ(R,CS(NameV));
    if (R is TJSONObject) and (Result=nil) then
      raise EDACChartOptionError.Create('dataset.source: campo ausente '+CS(NameV));
  end;
begin
  A:=CJ(FOptions,'series'); D:=CJ(FOptions,'dataset');
  Source:=CJ(D,'source'); Dims:=CJ(D,'dimensions');
  HasHeader:=CB(CJ(D,'sourceHeader'),(Dims=nil) and (Arr(Arr(Source,0),0) is TJSONString));
  SetLength(FSeries,Count(A)); SetLength(FCategories,0);
  FXCategory:=CS(CJ(CJ(FOptions,'xAxis'),'type'),'value')='category';
  FYCategory:=CS(CJ(CJ(FOptions,'yAxis'),'type'),'value')='category';
  Names:=CJ(CJ(FOptions,'xAxis'),'data'); if FYCategory then Names:=CJ(CJ(FOptions,'yAxis'),'data');
  for P:=0 to Count(Names)-1 do begin
    SetLength(FCategories,P+1); V:=Arr(Names,P); if V is TJSONObject then V:=CJ(V,'value'); FCategories[P]:=CS(V);
  end;
  for S:=0 to High(FSeries) do begin
    Item:=Arr(A,S); FSeries[S].Options:=Item;
    FSeries[S].Kind:=CS(CJ(Item,'type'),'bar'); FSeries[S].Name:=CS(CJ(Item,'name'));
    FSeries[S].Stack:=CS(CJ(Item,'stack'));
    Enc:=CJ(Item,'encode'); ByRow:=CS(CJ(Item,'seriesLayoutBy'),'column')='row';
    V:=CJ(Item,'data');
    if V<>nil then N:=Count(V) else if ByRow then N:=Count(Arr(Source,0))-Ord(HasHeader) else N:=Count(Source)-Ord(HasHeader);
    N:=Max(0,N); SetLength(FSeries[S].Values,N);
    XCol:=Dimension(CJ(Enc,'x'),0); YCol:=Dimension(CJ(Enc,'y'),S+1);
    if FYCategory then begin XCol:=Dimension(CJ(Enc,'x'),S+1); YCol:=Dimension(CJ(Enc,'y'),0); end;
    if FSeries[S].Kind='pie' then YCol:=Dimension(CJ(Enc,'value'),S+1);
    if (FSeries[S].Name='') and HasHeader and (V=nil) then
      if ByRow then FSeries[S].Name:=CS(Arr(Arr(Source,S+1),0)) else FSeries[S].Name:=CS(Arr(Arr(Source,0),YCol));
    StartRow:=Ord(HasHeader);
    for P:=0 to N-1 do begin
      Row:=Arr(V,P); FSeries[S].Values[P].Item:=Row;
      if V<>nil then begin
        if Row is TJSONObject then Row:=CJ(Row,'value');
        XV:=Arr(Row,0); YV:=Arr(Row,1);
        if not (Row is TJSONArray) then begin XV:=nil; YV:=Row; end;
        if FYCategory and (Row is TJSONArray) then begin YV:=Arr(Row,0); XV:=Arr(Row,1); end;
      end else if ByRow then begin
        XV:=Arr(Arr(Source,XCol),P+StartRow); YV:=Arr(Arr(Source,YCol),P+StartRow);
      end else begin
        Row:=Arr(Source,P+StartRow); XV:=Cell(Row,XCol); YV:=Cell(Row,YCol);
        if FYCategory then begin XV:=Cell(Row,YCol); YV:=Cell(Row,XCol); end;
      end;
      FSeries[S].Values[P].Y:=Numeric(YV);
      FSeries[S].Values[P].X:=Numeric(XV);
      FSeries[S].Values[P].Name:=CS(CJ(FSeries[S].Values[P].Item,'name'),CS(XV,IntToStr(P)));
      FSeries[S].Values[P].Id:=CS(CJ(FSeries[S].Values[P].Item,'id'),FSeries[S].Values[P].Name+'|'+IntToStr(P));
      if FXCategory or FYCategory then begin
        if P>=Length(FCategories) then begin SetLength(FCategories,P+1); FCategories[P]:=FSeries[S].Values[P].Name; end;
        FSeries[S].Values[P].X:=P; FSeries[S].Values[P].Name:=FCategories[P];
      end else if XV=nil then FSeries[S].Values[P].X:=P;
      FSeries[S].Values[P].Missing:=IsNan(FSeries[S].Values[P].Y) or IsInfinite(FSeries[S].Values[P].Y) or IsNan(FSeries[S].Values[P].X) or IsInfinite(FSeries[S].Values[P].X);
      FSeries[S].Values[P].Base:=0;
      if (FSeries[S].Stack<>'') and not FSeries[S].Values[P].Missing then
        for K:=S-1 downto 0 do
          if (FSeries[K].Stack=FSeries[S].Stack) and not IsHidden(FSeries[K].Name) and (P<Length(FSeries[K].Values)) and
            not FSeries[K].Values[P].Missing and
            ((FSeries[K].Values[P].Y>=0)=(FSeries[S].Values[P].Y>=0)) then begin
            FSeries[S].Values[P].Base:=FSeries[K].Values[P].Y+FSeries[K].Values[P].Base; Break;
          end;
    end;
  end;
end;
function TDACChartEngine.LengthValue(V: TJSONValue; Total,Default: Double): Double;
var S: string;
begin
  S:=CS(V); if S.EndsWith('%') then Result:=StrToFloatDef(S.Substring(0,S.Length-1),0,TFormatSettings.Invariant)*Total/100
  else Result:=CN(V,Default)*FScale;
end;
function TDACChartEngine.Color(V: TJSONValue; Default: TAlphaColor): TAlphaColor;
var S: string; N: Int64; P: TArray<string>; A: Integer;
begin
  Result:=Default; S:=LowerCase(CS(V));
  if S='transparent' then Exit(0);
  if S='white' then Exit($FFFFFFFF); if S='black' then Exit($FF000000);
  if S='red' then Exit($FFFF0000); if S='green' then Exit($FF008000); if S='blue' then Exit($FF0000FF);
  if S.StartsWith('#') then begin
    S:=Copy(S,2,MaxInt);
    if Length(S)=3 then S:=S[1]+S[1]+S[2]+S[2]+S[3]+S[3];
    if TryStrToInt64('$'+S,N) then begin
      if Length(S)=6 then Result:=$FF000000 or Cardinal(N)
      else if Length(S)=8 then Result:=(Cardinal(N) shr 8) or ((Cardinal(N) and $FF) shl 24);
    end;
  end else if S.StartsWith('rgb') then begin
    S:=Copy(S,Pos('(',S)+1,MaxInt); S:=StringReplace(S,')','',[rfReplaceAll]); P:=S.Split([',']);
    if Length(P)>=3 then begin
      A:=255; if Length(P)=4 then A:=Round(StrToFloatDef(P[3],1,TFormatSettings.Invariant)*255);
      Result:=(Cardinal(A) shl 24) or (StrToIntDef(Trim(P[0]),0) shl 16) or
        (StrToIntDef(Trim(P[1]),0) shl 8) or StrToIntDef(Trim(P[2]),0);
    end;
  end;
end;
function TDACChartEngine.Palette(I: Integer): TAlphaColor;
const C: array[0..8] of TAlphaColor=($FF5070DD,$FFB6D634,$FF505372,$FFFF994D,$FF0CA8DF,$FFFFD10A,$FFFB628B,$FF785DB0,$FF3FBE95);
var V: TJSONValue;
begin
  V:=CJ(FOptions,'color'); if Count(V)>0 then Result:=Color(Arr(V,I mod Count(V)),C[I mod 9]) else Result:=C[I mod 9];
end;
function TDACChartEngine.ItemStyle(S,P: Integer): TJSONObject;
var V: TJSONValue; Pair: TJSONPair; State: string;
  procedure Merge(O: TJSONValue);
  var Pair: TJSONPair;
  begin
    if O is TJSONObject then for Pair in TJSONObject(O) do
      CSet(Result,Pair.JsonString.Value,TJSONValue(Pair.JsonValue.Clone));
  end;
begin
  Result:=TJSONObject.Create;
  Merge(CJ(FSeries[S].Options,'itemStyle'));
  if P>=0 then Merge(CJ(FSeries[S].Values[P].Item,'itemStyle'));
  State:='';
  if (P>=0) and FSelected.ContainsKey(IntToStr(S)+'|'+FSeries[S].Values[P].Name) then State:='select';
  if (FHoveredSeries=S) and (FHoveredData=P) then State:='emphasis'
  else if (FHoveredSeries>=0) and (FHoveredSeries<>S) and (CS(CJ(CJ(FSeries[FHoveredSeries].Options,'emphasis'),'focus'))='series') then State:='blur';
  if State<>'' then begin
    Merge(CJ(CJ(FSeries[S].Options,State),'itemStyle'));
    if P>=0 then Merge(CJ(CJ(FSeries[S].Values[P].Item,State),'itemStyle'));
  end;
end;
function TDACChartEngine.PaintFor(V: TJSONValue; Default: TAlphaColor;
  const R: TRectF; Stroke: Boolean): ISkPaint;
var G,A: TJSONValue; Colors: TArray<TAlphaColor>; Stops,Dash: TArray<Single>; I: Integer; P1,P2: TPointF;
begin
  Result:=TSkPaint.Create; Result.AntiAlias:=True;
  Result.Color:=Color(CJ(V,'color'),Default);
  Result.AlphaF:=CN(CJ(V,'opacity'),1)*((Result.Color shr 24) and 255)/255;
  if Stroke then begin Result.Style:=TSkPaintStyle.Stroke; Result.StrokeWidth:=CN(CJ(V,'width'),2)*FScale; end;
  if CN(CJ(V,'shadowBlur'))>0 then
    Result.ImageFilter:=TSkImageFilter.MakeDropShadow(CN(CJ(V,'shadowOffsetX'))*FScale,
      CN(CJ(V,'shadowOffsetY'))*FScale,CN(CJ(V,'shadowBlur'))*FScale/2,
      CN(CJ(V,'shadowBlur'))*FScale/2,Color(CJ(V,'shadowColor'),$80000000));
  if CS(CJ(V,'type'))='dotted' then begin SetLength(Dash,2); Dash[0]:=FScale; Dash[1]:=2*FScale; Result.PathEffect:=TSkPathEffect.MakeDash(Dash,0); end;
  if CS(CJ(V,'type'))='dashed' then begin SetLength(Dash,2); Dash[0]:=4*FScale; Dash[1]:=3*FScale; Result.PathEffect:=TSkPathEffect.MakeDash(Dash,0); end;
  G:=CJ(V,'color'); A:=CJ(G,'colorStops');
  if Count(A)>0 then begin
    SetLength(Colors,Count(A)); SetLength(Stops,Count(A));
    for I:=0 to High(Colors) do begin Colors[I]:=Color(CJ(Arr(A,I),'color'),Default); Stops[I]:=CN(CJ(Arr(A,I),'offset')); end;
    P1:=PointF(R.Left+CN(CJ(G,'x'))*R.Width,R.Top+CN(CJ(G,'y'))*R.Height);
    P2:=PointF(R.Left+CN(CJ(G,'x2'))*R.Width,R.Top+CN(CJ(G,'y2'),1)*R.Height);
    if CS(CJ(G,'type'))='radial' then Result.Shader:=TSkShader.MakeGradientRadial(P1,CN(CJ(G,'r'),0.5)*Min(R.Width,R.Height),Colors,Stops,TSkTileMode.Clamp)
    else Result.Shader:=TSkShader.MakeGradientLinear(P1,P2,Colors,Stops,TSkTileMode.Clamp);
  end;
end;
function TDACChartEngine.NativeFont(Style: TJSONValue): HFONT;
var LF: TLogFont; Key: string; OldFont: HFONT;
begin
  FillChar(LF,SizeOf(LF),0); LF.lfHeight:=-Round(CN(CJ(Style,'fontSize'),12)*FScale);
  LF.lfWeight:=FW_NORMAL; if (CS(CJ(Style,'fontWeight'))='bold') or (CN(CJ(Style,'fontWeight'))>=600) then LF.lfWeight:=FW_BOLD;
  LF.lfItalic:=Ord(CS(CJ(Style,'fontStyle'))='italic'); LF.lfQuality:=CLEARTYPE_QUALITY;
  LF.lfEscapement:=Round(CN(CJ(Style,'rotate'))*10); LF.lfOrientation:=LF.lfEscapement;
  StringToWideChar(CS(CJ(Style,'fontFamily'),'Arial'),LF.lfFaceName,LF_FACESIZE);
  Key:=string(LF.lfFaceName)+'|'+IntToStr(LF.lfHeight)+'|'+IntToStr(LF.lfWeight)+'|'+IntToStr(LF.lfItalic)+'|'+IntToStr(LF.lfEscapement);
  if FFonts.TryGetValue(Key,Result) then Exit;
  if FFonts.Count>=256 then begin for OldFont in FFonts.Values do DeleteObject(OldFont); FFonts.Clear; end;
  Result:=CreateFontIndirect(LF); FFonts.Add(Key,Result);
end;
function TDACChartEngine.TextWidth(const S: string; Style: TJSONValue): Double;
var Old: HGDIOBJ; Size: TSize;
begin
  Old:=SelectObject(FSurface.DC,NativeFont(Style));
  try GetTextExtentPoint32(FSurface.DC,PChar(S),Length(S),Size); Result:=Size.cx;
  finally SelectObject(FSurface.DC,Old); end;
end;
procedure TDACChartEngine.Text(const S: string; X,Y: Double; Style: TJSONValue;
  const Align: string; MaxWidth: Double);
var Old: HGDIOBJ; R: TRect; SZ: TSize; Flags: Cardinal; C: TAlphaColor; T,Token,Name: string;
  Start,P,Q,Sep,Pass: Integer; XX,YY,W,Total,LineHeight,Padding: Double;
  Rich,Fragment: TJSONValue; Merged,Plain: TJSONObject; Pair: TJSONPair;
  Paint: ISkPaint; Box: TRectF; Evidence: TJSONObject;
begin
  if S='' then Exit;
  W:=0; Rich:=CJ(Style,'rich');
  if (Rich is TJSONObject) and (Pos('{',S)>0) then begin
    { Native font metrics per fragment; Skia owns each fragment's box/effects. }
    for Pass:=0 to 1 do begin
      Start:=1; Total:=0; XX:=X; YY:=Y;
      if Pass=1 then begin
        if Align='center' then XX:=X-W/2 else if Align='right' then XX:=X-W;
      end;
      while Start<=Length(S) do begin
        P:=PosEx('{',S,Start); Fragment:=nil;
        if P=Start then begin
          Q:=PosEx('}',S,P+1); Sep:=PosEx('|',S,P+1);
          if (Q>P) and (Sep>P) and (Sep<Q) then begin
            Name:=Copy(S,P+1,Sep-P-1); Token:=Copy(S,Sep+1,Q-Sep-1);
            Fragment:=CJ(Rich,Name); Start:=Q+1;
          end else begin Token:=Copy(S,Start,1); Inc(Start); end;
        end else begin
          if P=0 then P:=Length(S)+1; Token:=Copy(S,Start,P-Start); Start:=P;
        end;
        Merged:=TJSONObject.Create;
        try
          if Style is TJSONObject then for Pair in TJSONObject(Style) do
            if Pair.JsonString.Value<>'rich' then Merged.AddPair(Pair.JsonString.Value,TJSONValue(Pair.JsonValue.Clone));
          if Fragment is TJSONObject then for Pair in TJSONObject(Fragment) do
            CSet(Merged,Pair.JsonString.Value,TJSONValue(Pair.JsonValue.Clone));
          Padding:=CN(CJ(Merged,'padding'))*FScale;
          Total:=Total+TextWidth(Token,Merged)+Padding*2;
          if Pass=1 then begin Text(Token,XX+Padding,YY,Merged,'left'); XX:=XX+TextWidth(Token,Merged)+Padding*2; end;
        finally Merged.Free; end;
      end;
      if Pass=0 then W:=Total;
    end;
    Exit;
  end;
  if Pos(#10,S)>0 then begin
    Start:=1; YY:=Y; LineHeight:=CN(CJ(Style,'lineHeight'),CN(CJ(Style,'fontSize'),12)*1.2)*FScale;
    repeat
      P:=PosEx(#10,S,Start); if P=0 then P:=Length(S)+1;
      Text(TrimRight(Copy(S,Start,P-Start)),X,YY,Style,Align,MaxWidth);
      Start:=P+1; YY:=YY+LineHeight;
    until Start>Length(S);
    Exit;
  end;
  T:=S;
  if (MaxWidth>0) and (TextWidth(T,Style)>MaxWidth) then begin
    while (Length(T)>0) and (TextWidth(T+'...',Style)>MaxWidth) do Delete(T,Length(T),1);
    T:=T+'...';
  end;
  W:=TextWidth(T,Style); XX:=X;
  if Align='center' then XX:=X-W/2 else if Align='right' then XX:=X-W;
  Padding:=CN(CJ(Style,'padding'))*FScale;
  Box:=TRectF.Create(XX-Padding,Y-Padding,XX+W+Padding,Y+CN(CJ(Style,'lineHeight'),CN(CJ(Style,'fontSize'),12)*1.2)*FScale+Padding);
  if CJ(Style,'backgroundColor')<>nil then begin
    Plain:=TJSONObject.Create;
    try
      CSet(Plain,'color',TJSONValue(CJ(Style,'backgroundColor').Clone));
      for Name in TArray<string>.Create('shadowBlur','shadowColor','shadowOffsetX','shadowOffsetY') do
        if CJ(Style,Name)<>nil then CSet(Plain,Name,TJSONValue(CJ(Style,Name).Clone));
      Paint:=PaintFor(Plain,$FFFFFFFF,Box); FC.DrawRoundRect(Box,CN(CJ(Style,'borderRadius'))*FScale,CN(CJ(Style,'borderRadius'))*FScale,Paint);
    finally Plain.Free; end;
  end;
  if CN(CJ(Style,'borderWidth'))>0 then begin
    Paint:=PaintFor(nil,Color(CJ(Style,'borderColor'),$FF333333),Box,True); Paint.StrokeWidth:=CN(CJ(Style,'borderWidth'))*FScale;
    FC.DrawRoundRect(Box,CN(CJ(Style,'borderRadius'))*FScale,CN(CJ(Style,'borderRadius'))*FScale,Paint);
  end;
  FSurface.Flush; Old:=SelectObject(FSurface.DC,NativeFont(Style));
  try
    SetBkMode(FSurface.DC,TRANSPARENT); C:=Color(CJ(Style,'color'),$FF54555A);
    SetTextColor(FSurface.DC,RGB((C shr 16) and 255,(C shr 8) and 255,C and 255));
    GetTextExtentPoint32(FSurface.DC,PChar(T),Length(T),SZ);
    if Align='center' then X:=X-SZ.cx/2 else if Align='right' then X:=X-SZ.cx;
    R:=Rect(Round(X),Round(Y),Round(X+Max(SZ.cx,MaxWidth)+2),Round(Y+Max(SZ.cy,100*FScale)));
    Flags:=DT_NOPREFIX or DT_TOP;
    if MaxWidth>0 then begin R.Right:=R.Left+Round(MaxWidth); Flags:=Flags or DT_END_ELLIPSIS; end;
    Evidence:=TJSONObject.Create; FTexts.AddElement(Evidence);
    Evidence.AddPair('text',T); Evidence.AddPair('x',TJSONNumber.Create(X)); Evidence.AddPair('y',TJSONNumber.Create(Y));
    Evidence.AddPair('width',TJSONNumber.Create(SZ.cx)); Evidence.AddPair('height',TJSONNumber.Create(SZ.cy));
    Evidence.AddPair('rotate',TJSONNumber.Create(CN(CJ(Style,'rotate'))));
    Evidence.AddPair('font',CS(CJ(Style,'fontFamily'),'Arial'));
    Evidence.AddPair('fontSize',TJSONNumber.Create(CN(CJ(Style,'fontSize'),12)*FScale));
    Evidence.AddPair('clipped',TJSONBool.Create((X<0) or (Y<0) or (X+Min(SZ.cx,R.Width)>FSurface.Width) or (Y+SZ.cy>FSurface.Height)));
    DrawText(FSurface.DC,PChar(T),Length(T),R,Flags); FSurface.OpaqueRect(R);
  finally SelectObject(FSurface.DC,Old); end;
end;
function TDACChartEngine.Coord(X,Y: Double): TPointF;
var TX,TY: Double; N: Integer;
begin
  N:=Length(FCategories);
  if FXCategory or FYCategory then begin
    if FBands then TX:=(X+0.5)/Max(1,N) else if N>1 then TX:=X/(N-1) else TX:=0.5;
    if FYCategory then begin TY:=TX; TX:=(Y-FXMin)/(FXMax-FXMin); end
    else TY:=(Y-FYMin)/(FYMax-FYMin);
  end else begin TX:=(X-FXMin)/(FXMax-FXMin); TY:=(Y-FYMin)/(FYMax-FYMin); end;
  if FXInverse then TX:=1-TX; if FYInverse then TY:=1-TY;
  Result:=PointF(FPlot.Left+TX*FPlot.Width,FPlot.Bottom-TY*FPlot.Height);
end;
function TDACChartEngine.AnimatedValue(S,P: Integer): Double;
var Old,T: Double; Easing: string;
begin
  if FProgress>=1 then Exit(FSeries[S].Values[P].Y);
  Old:=0; FPrevious.TryGetValue(ValueKey(S,P),Old);
  T:=FProgress;
  Easing:=CS(CJ(FOptions,'animationEasingUpdate'),'cubicInOut');
  if FPrevious.Count=0 then begin
    Easing:=CS(CJ(FOptions,'animationEasing'),'cubicInOut');
    if (FSeries[S].Kind='line') and (CJ(FOptions,'animationEasing')=nil) then Easing:='linear';
  end;
  if Easing='cubicIn' then T:=T*T*T
  else if Easing='cubicOut' then T:=1-Power(1-T,3)
  else if Easing='cubicInOut' then
    if T<0.5 then T:=4*T*T*T else T:=1-Power(-2*T+2,3)/2;
  Result:=Old+(FSeries[S].Values[P].Y-Old)*T;
end;
function TDACChartEngine.IsHidden(const Name: string): Boolean;
begin Result:=FHidden.ContainsKey(Name); end;
procedure TDACChartEngine.Render(Target: TDACChartSurface; W,H,Dpi: Integer;
  const Mouse: TPointF; Progress: Double);
var G,XA,YA: TJSONValue; S,P: Integer; X,Y,Step: Double; HasX,HasY,HasCartesian: Boolean;
  procedure Bounds(Axis: TJSONValue; var Lo,Hi: Double);
  var St,DataLo,DataHi: Double;
  begin
    DataLo:=Lo; DataHi:=Hi;
    if ((CJ(Axis,'min')=nil) or (CS(CJ(Axis,'min'))='auto')) and not CB(CJ(Axis,'scale')) then Lo:=Min(0,Lo);
    if ((CJ(Axis,'max')=nil) or (CS(CJ(Axis,'max'))='auto')) and not CB(CJ(Axis,'scale')) then Hi:=Max(0,Hi);
    if SameValue(Lo,Hi) then begin Lo:=Lo-1; Hi:=Hi+1; end;
    St:=NiceStep((Hi-Lo)/Max(1,CN(CJ(Axis,'splitNumber'),5)));
    if (CJ(Axis,'min')=nil) or (CS(CJ(Axis,'min'))='auto') then Lo:=Floor(Lo/St)*St else Lo:=CN(CJ(Axis,'min'),Lo);
    if (CJ(Axis,'max')=nil) or (CS(CJ(Axis,'max'))='auto') then Hi:=Ceil(Hi/St)*St else Hi:=CN(CJ(Axis,'max'),Hi);
    if CS(CJ(Axis,'min'))='dataMin' then Lo:=DataLo;
    if CS(CJ(Axis,'max'))='dataMax' then Hi:=DataHi;
    if Hi<=Lo then raise EDACChartOptionError.Create('axis: max deve exceder min');
  end;
begin
  Target.SetSize(W,H); FSurface:=Target; FC:=Target.Surface.Canvas;
  FScale:=Dpi/96; FProgress:=Progress; FMouse:=Mouse;
  FHover:=HitTest(Mouse); FHoveredSeries:=-1; FHoveredData:=-1;
  if FHover>=0 then begin FHoveredSeries:=FMarks[FHover].SeriesIndex; FHoveredData:=FMarks[FHover].DataIndex; end;
  FMarks.Clear; FLabelBounds.Clear; FTexts.Free; FTexts:=TJSONArray.Create;
  FC.Clear(Color(CJ(FOptions,'backgroundColor'),$FFFFFFFF));
  G:=CJ(FOptions,'grid'); XA:=CJ(FOptions,'xAxis'); YA:=CJ(FOptions,'yAxis');
  FPlot:=TRectF.Create(LengthValue(CJ(G,'left'),W,W*0.1/FScale),LengthValue(CJ(G,'top'),H,60),
    W-LengthValue(CJ(G,'right'),W,W*0.1/FScale),H-LengthValue(CJ(G,'bottom'),H,70));
  if FPlot.Width<1 then FPlot.Right:=FPlot.Left+1; if FPlot.Height<1 then FPlot.Bottom:=FPlot.Top+1;
  FXInverse:=CB(CJ(XA,'inverse')); FYInverse:=CB(CJ(YA,'inverse'));
  if FYCategory then FBands:=CB(CJ(YA,'boundaryGap'),True) else FBands:=CB(CJ(XA,'boundaryGap'),True);
  FXMin:=0; FXMax:=1; FYMin:=0; FYMax:=1; HasX:=False; HasY:=False; HasCartesian:=False;
  for S:=0 to High(FSeries) do if (FSeries[S].Kind<>'pie') and not IsHidden(FSeries[S].Name) then begin
    HasCartesian:=True;
    for P:=0 to High(FSeries[S].Values) do if not FSeries[S].Values[P].Missing then begin
      X:=FSeries[S].Values[P].X; Y:=FSeries[S].Values[P].Y+FSeries[S].Values[P].Base;
      if not HasX then begin FXMin:=X; FXMax:=X; HasX:=True; end else begin FXMin:=Min(FXMin,X); FXMax:=Max(FXMax,X); end;
      if not HasY then begin FYMin:=Y; FYMax:=Y; HasY:=True; end else begin FYMin:=Min(FYMin,Y); FYMax:=Max(FYMax,Y); end;
    end;
  end;
  if FYCategory then begin FXMin:=FYMin; FXMax:=FYMax; end;
  if not FXCategory then Bounds(XA,FXMin,FXMax);
  if not FYCategory then Bounds(YA,FYMin,FYMax);
  if HasCartesian or (XA<>nil) or (YA<>nil) then DrawAxes;
  FC.Save;
  FC.ClipRect(FPlot);
  for S:=0 to High(FSeries) do if (FSeries[S].Kind<>'pie') and not IsHidden(FSeries[S].Name) then DrawSeries(S);
  FC.Restore;
  for S:=0 to High(FSeries) do if FSeries[S].Kind='pie' then DrawPie(S);
  for P:=0 to FMarks.Count-1 do begin
    S:=FMarks[P].SeriesIndex;
    if S>=0 then DrawLabel(FMarks[P],CJ(FSeries[S].Options,'label'));
  end;
  DrawTitle; DrawLegend;
  FHover:=HitTest(FMouse); DrawTooltip; Target.Flush;
end;
procedure TDACChartEngine.DrawAxes;
var Axis,LabelV,LineV,SplitV,Tick: TJSONValue; AxisNo,I,N,Stride,K: Integer;
  Horizontal,Category,ShowAxis: Boolean; P: TPointF; Paint: ISkPaint;
  Lo,Hi,Step,V,Pos,MaxLabelWidth,TickLength,AxisPosition,PreviousTick: Double; S,Align: string;
begin
  for AxisNo:=0 to 1 do begin
    Horizontal:=AxisNo=0;
    if Horizontal then begin Axis:=CJ(FOptions,'xAxis'); Category:=FXCategory; Lo:=FXMin; Hi:=FXMax; end
    else begin Axis:=CJ(FOptions,'yAxis'); Category:=FYCategory; Lo:=FYMin; Hi:=FYMax; end;
    if not CB(CJ(Axis,'show'),True) then Continue;
    LabelV:=CJ(Axis,'axisLabel'); LineV:=CJ(Axis,'axisLine'); SplitV:=CJ(Axis,'splitLine');
    if Horizontal then AxisPosition:=FPlot.Bottom else AxisPosition:=FPlot.Left;
    if (CS(CJ(LineV,'onZero'),'auto')<>'false') and Category then begin
      if Horizontal and (FYMin<=0) and (FYMax>=0) then AxisPosition:=Coord(0,0).Y;
      if not Horizontal and (FXMin<=0) and (FXMax>=0) then AxisPosition:=Coord(0,0).X;
    end;
    Paint:=PaintFor(CJ(LineV,'lineStyle'),$FF54555A,FPlot,True); Paint.StrokeWidth:=FScale;
    if CB(CJ(LineV,'show'),Category) then
      if Horizontal then FC.DrawLine(FPlot.Left,Round(AxisPosition)+0.5,FPlot.Right,Round(AxisPosition)+0.5,Paint)
      else FC.DrawLine(Round(AxisPosition)+0.5,FPlot.Top,Round(AxisPosition)+0.5,FPlot.Bottom,Paint);
    if Category then begin N:=Length(FCategories)-1; Step:=1; end
    else begin
      Step:=CN(CJ(Axis,'interval'),NiceStep((Hi-Lo)/Max(1,CN(CJ(Axis,'splitNumber'),5))));
      if (CS(CJ(Axis,'type'))='time') and ((Hi-Lo)>=86400000) then
        Step:=Max(1,Round((Hi-Lo)/Max(1,CN(CJ(Axis,'splitNumber'),5))/86400000))*86400000;
      N:=Min(1000,Ceil((Hi-Lo)/Max(1E-100,Step))+2);
    end;
    Stride:=1;
    if Category then begin
      if (CJ(LabelV,'interval')<>nil) and (CS(CJ(LabelV,'interval'))<>'auto') then Stride:=Max(1,Round(CN(CJ(LabelV,'interval')))+1)
      else begin
        MaxLabelWidth:=0;
        for K:=0 to High(FCategories) do MaxLabelWidth:=Max(MaxLabelWidth,TextWidth(FCategories[K],LabelV)+8*FScale);
        if Horizontal and (CN(CJ(LabelV,'rotate'))=0) then Stride:=Max(1,Ceil(MaxLabelWidth/Max(1,FPlot.Width/Max(1,N+1))))
        else if not Horizontal then Stride:=Max(1,Ceil(18*FScale/Max(1,FPlot.Height/Max(1,N+1))));
      end;
    end;
    PreviousTick:=-MaxDouble;
    for I:=0 to N do begin
      if Category then begin
        V:=I; S:=FCategories[I]; P:=Coord(I,0);
        if Horizontal then Pos:=P.X else Pos:=P.Y;
      end else begin
        if PreviousTick>=Hi then Break;
        if I=0 then V:=Lo else V:=Min(Hi,(Floor(Lo/Step+1E-8)+I)*Step);
        PreviousTick:=V; S:=FormatFloat('0.########',V,TFormatSettings.Invariant);
        if CS(CJ(Axis,'type'))='time' then
          if Hi-Lo>=86400000 then
            if (I=0) then S:=FormatDateTime('yyyy',UnixToDateTime(Trunc(V/1000),CB(CJ(FOptions,'useUTC'))))
            else S:=FormatDateTime('d',UnixToDateTime(Trunc(V/1000),CB(CJ(FOptions,'useUTC'))))
          else S:=FormatDateTime('hh:nn:ss',UnixToDateTime(Trunc(V/1000),CB(CJ(FOptions,'useUTC'))));
        if Horizontal then begin Pos:=(V-Lo)/(Hi-Lo); if FXInverse then Pos:=1-Pos; Pos:=FPlot.Left+Pos*FPlot.Width; end
        else begin Pos:=(V-Lo)/(Hi-Lo); if FYInverse then Pos:=1-Pos; Pos:=FPlot.Bottom-Pos*FPlot.Height; end;
      end;
      if CS(CJ(LabelV,'formatter'))<>'' then S:=StringReplace(CS(CJ(LabelV,'formatter')),'{value}',S,[rfReplaceAll]);
      Tick:=CJ(Axis,'axisTick');
      if CB(CJ(Tick,'show')) then begin
        Paint:=PaintFor(CJ(Tick,'lineStyle'),$FF54555A,FPlot,True); Paint.StrokeWidth:=FScale;
        TickLength:=CN(CJ(Tick,'length'),5)*FScale; if CB(CJ(Tick,'inside')) then TickLength:=-TickLength;
        if Horizontal then FC.DrawLine(Pos,FPlot.Bottom,Pos,FPlot.Bottom+TickLength,Paint)
        else FC.DrawLine(FPlot.Left,Pos,FPlot.Left-TickLength,Pos,Paint);
      end;
      if CB(CJ(SplitV,'show'),not Category) then begin
        Paint:=PaintFor(CJ(SplitV,'lineStyle'),$FFDBDEE4,FPlot,True); Paint.StrokeWidth:=FScale;
        if Horizontal then FC.DrawLine(Round(Pos)+0.5,FPlot.Top,Round(Pos)+0.5,FPlot.Bottom,Paint)
        else FC.DrawLine(FPlot.Left,Round(Pos)+0.5,FPlot.Right,Round(Pos)+0.5,Paint);
      end;
      if CB(CJ(LabelV,'show'),True) and ((I mod Stride)=0) then
        if Horizontal then Text(S,Pos,FPlot.Bottom+8*FScale,LabelV,'center')
        else Text(S,FPlot.Left-8*FScale,Pos-6*FScale,LabelV,'right');
    end;
    S:=CS(CJ(Axis,'name'));
    if Horizontal then Text(S,FPlot.Right+8*FScale,FPlot.Bottom, CJ(Axis,'nameTextStyle'))
    else Text(S,FPlot.Left,FPlot.Top-25*FScale,CJ(Axis,'nameTextStyle'),'center');
  end;
end;
{ Control-point constraints follow Apache ECharts 6.1.0 poly.ts.
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
procedure TDACChartEngine.DrawSeries(I: Integer);
var S: TDACChartRenderSeries; P,K,Group,Groups,N: Integer; D: TDACChartDatum; M: TDACChartMark;
  Pt,BasePt: TPointF; R: TRectF; Paint,LinePaint: ISkPaint; Path,Area: ISkPathBuilder;
  Style,LV: TJSONValue; Band,BW,Gap,Offset,Radius,Y,Smooth: Double; HasArea: Boolean;
  Seen: TStringList; Segment,Bases: TList<TPointF>; Rev: TArray<TPointF>; Step: string;
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
  end;
begin
  S:=FSeries[I]; N:=Length(S.Values); HasArea:=CJ(S.Options,'areaStyle')<>nil;
  Style:=CJ(S.Options,'itemStyle'); LV:=CJ(S.Options,'lineStyle');
  if FYCategory then Band:=FPlot.Height/Max(1,Length(FCategories)) else Band:=FPlot.Width/Max(1,Length(FCategories));
  Seen:=TStringList.Create;
  try
    Group:=0;
    for K:=0 to High(FSeries) do if (FSeries[K].Kind='bar') and not IsHidden(FSeries[K].Name) then begin
      if FSeries[K].Stack='' then Seen.Add('#'+IntToStr(K))
      else if Seen.IndexOf(FSeries[K].Stack)<0 then Seen.Add(FSeries[K].Stack);
      if K=I then Group:=Seen.Count-1;
      if (K=I) and (S.Stack<>'') then Group:=Seen.IndexOf(S.Stack);
    end;
    Groups:=Max(1,Seen.Count);
  finally Seen.Free; end;
  Gap:=0.1;
  if CJ(S.Options,'barGap')<>nil then Gap:=LengthValue(CJ(S.Options,'barGap'),1,0.1/FScale);
  BW:=(Band-LengthValue(CJ(S.Options,'barCategoryGap'),Band,Band*Max(35-Groups*4,15)/100/FScale))/(Groups+(Groups-1)*Gap);
  BW:=LengthValue(CJ(S.Options,'barWidth'),Band,BW/FScale);
  BW:=Min(BW,LengthValue(CJ(S.Options,'barMaxWidth'),Band,BW/FScale));
  BW:=Max(BW,LengthValue(CJ(S.Options,'barMinWidth'),Band,0));
  Offset:=(Group-(Groups-1)/2)*(BW*(1+Gap));
  Path:=TSkPathBuilder.Create;
  Smooth:=CN(CJ(S.Options,'smooth')); if CB(CJ(S.Options,'smooth')) then Smooth:=0.5;
  Step:=CS(CJ(S.Options,'step')); if Step='false' then Step:=''; if Step='true' then Step:='end';
  Segment:=TList<TPointF>.Create; Bases:=TList<TPointF>.Create;
  try
  for P:=0 to N-1 do begin
    D:=S.Values[P];
    if D.Missing then begin
      if not CB(CJ(S.Options,'connectNulls')) then FlushSegment;
      Continue;
    end;
    Y:=AnimatedValue(I,P)+D.Base; Pt:=Coord(D.X,Y); BasePt:=Coord(D.X,D.Base);
    M:=Default(TDACChartMark); M.Kind:=S.Kind; M.SeriesIndex:=I; M.DataIndex:=P; M.Name:=D.Name;
    M.X:=Pt.X; M.Y:=Pt.Y; M.Value:=D.Y; M.Base:=D.Base;
    if S.Kind='bar' then begin
      if FYCategory then begin
        Pt.Y:=Pt.Y+Offset; M.Y:=Pt.Y;
        R:=TRectF.Create(Min(BasePt.X,Pt.X),Pt.Y-BW/2,Max(BasePt.X,Pt.X),Pt.Y+BW/2);
      end else begin
        Pt.X:=Pt.X+Offset; M.X:=Pt.X;
        R:=TRectF.Create(Pt.X-BW/2,Min(Pt.Y,BasePt.Y),Pt.X+BW/2,Max(Pt.Y,BasePt.Y));
      end;
      M.Bounds:=R;
      Style:=ItemStyle(I,P);
      Paint:=PaintFor(Style,Palette(I),R);
      if FYCategory and (R.Width<CN(CJ(S.Options,'barMinHeight'))*FScale) then
        if D.Y>=0 then R.Right:=R.Left+CN(CJ(S.Options,'barMinHeight'))*FScale else R.Left:=R.Right-CN(CJ(S.Options,'barMinHeight'))*FScale;
      if not FYCategory and (R.Height<CN(CJ(S.Options,'barMinHeight'))*FScale) then
        if D.Y>=0 then R.Top:=R.Bottom-CN(CJ(S.Options,'barMinHeight'))*FScale else R.Bottom:=R.Top+CN(CJ(S.Options,'barMinHeight'))*FScale;
      M.Bounds:=R; Radius:=CN(CJ(Style,'borderRadius'))*FScale;
      FC.DrawRoundRect(R,Radius,Radius,Paint);
      if CN(CJ(Style,'borderWidth'))>0 then begin Paint:=PaintFor(nil,Color(CJ(Style,'borderColor'),Palette(I)),R,True); Paint.StrokeWidth:=CN(CJ(Style,'borderWidth'))*FScale; FC.DrawRoundRect(R,Radius,Radius,Paint); end;
      Style.Free; Style:=CJ(S.Options,'itemStyle');
    end else begin
      Segment.Add(Pt); Bases.Add(BasePt);
      Radius:=CN(CJ(S.Options,'symbolSize'),6)*FScale/2;
      M.Bounds:=TRectF.Create(Pt.X-Max(5*FScale,Radius),Pt.Y-Max(5*FScale,Radius),Pt.X+Max(5*FScale,Radius),Pt.Y+Max(5*FScale,Radius));
    end;
    FMarks.Add(M);
  end;
  FlushSegment;
  finally Segment.Free; Bases.Free; end;
  if S.Kind='line' then begin
    LinePaint:=PaintFor(LV,Palette(I),FPlot,True); FC.DrawPath(Path.Snapshot,LinePaint);
    if CB(CJ(S.Options,'showSymbol'),True) and (CS(CJ(S.Options,'symbol'))<>'none') then
      for K:=0 to FMarks.Count-1 do if FMarks[K].SeriesIndex=I then begin
        M:=FMarks[K]; Paint:=PaintFor(Style,Palette(I),M.Bounds);
        Radius:=CN(CJ(S.Options,'symbolSize'),6)*FScale/2;
        if CS(CJ(S.Options,'symbol'),'emptyCircle')='emptyCircle' then begin
          Paint.Color:=$FFFFFFFF; FC.DrawCircle(M.X,M.Y,Radius,Paint);
          Paint:=PaintFor(nil,Palette(I),M.Bounds,True); Paint.StrokeWidth:=2*FScale;
        end;
        if (CS(CJ(S.Options,'symbol'))='rect') or (CS(CJ(S.Options,'symbol'))='roundRect') then
          FC.DrawRoundRect(TRectF.Create(M.X-Radius,M.Y-Radius,M.X+Radius,M.Y+Radius),
            Radius*Ord(CS(CJ(S.Options,'symbol'))='roundRect')/3,
            Radius*Ord(CS(CJ(S.Options,'symbol'))='roundRect')/3,Paint)
        else if (CS(CJ(S.Options,'symbol'))='triangle') or (CS(CJ(S.Options,'symbol'))='diamond') then begin
          Area:=TSkPathBuilder.Create; Area.MoveTo(M.X,M.Y-Radius);
          if CS(CJ(S.Options,'symbol'))='triangle' then begin Area.LineTo(M.X+Radius,M.Y+Radius); Area.LineTo(M.X-Radius,M.Y+Radius); end
          else begin Area.LineTo(M.X+Radius,M.Y); Area.LineTo(M.X,M.Y+Radius); Area.LineTo(M.X-Radius,M.Y); end;
          Area.Close; FC.DrawPath(Area.Snapshot,Paint);
        end else FC.DrawCircle(M.X,M.Y,Radius,Paint);
      end;
  end;
end;
procedure TDACChartEngine.DrawPie(I: Integer);
var S: TDACChartRenderSeries; P,N: Integer; Total,Angle,Sweep,R0,R1,CX,CY,CenterX,CenterY,Shift,Sign,V: Double;
  Opt,Radii,Center: TJSONValue; Paint: ISkPaint; Path: ISkPathBuilder; Outer,Inner: TRectF; M: TDACChartMark;
begin
  S:=FSeries[I]; Opt:=S.Options; N:=Length(S.Values); Total:=0;
  for P:=0 to N-1 do if not S.Values[P].Missing and not IsHidden(S.Values[P].Name) then Total:=Total+Max(0,S.Values[P].Y);
  Center:=CJ(Opt,'center'); CX:=LengthValue(Arr(Center,0),FSurface.Width,FSurface.Width/2/FScale);
  CY:=LengthValue(Arr(Center,1),FSurface.Height,FSurface.Height/2/FScale);
  Radii:=CJ(Opt,'radius'); R0:=0;
  if Radii is TJSONArray then begin R0:=LengthValue(Arr(Radii,0),Min(FSurface.Width,FSurface.Height)/2,0); Radii:=Arr(Radii,1); end;
  R1:=LengthValue(Radii,Min(FSurface.Width,FSurface.Height)/2,Min(FSurface.Width,FSurface.Height)/4/FScale);
  R0:=Min(R0,R1); Angle:=-CN(CJ(Opt,'startAngle'),90); Sign:=1; if not CB(CJ(Opt,'clockwise'),True) then Sign:=-1;
  Outer:=TRectF.Create(CX-R1,CY-R1,CX+R1,CY+R1); Inner:=TRectF.Create(CX-R0,CY-R0,CX+R0,CY+R0);
  if (N=0) and CB(CJ(Opt,'showEmptyCircle'),True) then begin Paint:=PaintFor(CJ(Opt,'emptyCircleStyle'),$FFD3D3D3,Outer); FC.DrawCircle(CX,CY,R1,Paint); Exit; end;
  CenterX:=CX; CenterY:=CY;
  for P:=0 to N-1 do begin
    if S.Values[P].Missing or IsHidden(S.Values[P].Name) then Continue;
    V:=Max(0,S.Values[P].Y);
    if Total>0 then Sweep:=360*V/Total else if CB(CJ(Opt,'stillShowZeroSum'),True) then Sweep:=360/Max(1,N) else Sweep:=0;
    Sweep:=Sweep*Sign;
    if Abs(Sweep)<1E-10 then Continue;
    Shift:=0;
    if FSelected.ContainsKey(IntToStr(I)+'|'+S.Values[P].Name) then Shift:=CN(CJ(Opt,'selectedOffset'),10)*FScale;
    CX:=CenterX+Shift*Cos(DegToRad(Angle+Sweep/2)); CY:=CenterY+Shift*Sin(DegToRad(Angle+Sweep/2));
    Outer:=TRectF.Create(CX-R1,CY-R1,CX+R1,CY+R1); Inner:=TRectF.Create(CX-R0,CY-R0,CX+R0,CY+R0);
    Path:=TSkPathBuilder.Create;
    Path.MoveTo(CX+R1*Cos(DegToRad(Angle)),CY+R1*Sin(DegToRad(Angle)));
    Path.ArcTo(Outer,Angle,Sweep*FProgress,False);
    if R0>0 then begin
      Path.LineTo(CX+R0*Cos(DegToRad(Angle+Sweep*FProgress)),CY+R0*Sin(DegToRad(Angle+Sweep*FProgress)));
      Path.ArcTo(Inner,Angle+Sweep*FProgress,-Sweep*FProgress,False);
    end else Path.LineTo(CX,CY);
    Path.Close;
    Opt:=ItemStyle(I,P);
    try Paint:=PaintFor(Opt,Palette(P),Outer); FC.DrawPath(Path.Snapshot,Paint);
    finally Opt.Free; end;
    Opt:=S.Options;
    M:=Default(TDACChartMark); M.Kind:='pie'; M.SeriesIndex:=I; M.DataIndex:=P; M.Name:=S.Values[P].Name; M.Value:=S.Values[P].Y;
    M.CX:=CX; M.CY:=CY; M.R:=R1; M.R0:=R0; M.StartAngle:=Angle; M.Sweep:=Sweep*FProgress; M.Bounds:=Outer;
    M.X:=CX+R1*Cos(DegToRad(Angle+Sweep/2)); M.Y:=CY+R1*Sin(DegToRad(Angle+Sweep/2));
    FMarks.Add(M); Angle:=Angle+Sweep;
  end;
end;
procedure TDACChartEngine.DrawLabel(const M: TDACChartMark; V: TJSONValue);
var S,Position,Align: string; X,Y,D,W,H,Total: Double; Paint: ISkPaint;
  R,Other: TRectF; HideOverlap,Overlap: Boolean; I,Attempts: Integer; Line: TJSONValue; Resolved: TJSONObject;
begin
  if not CB(CJ(V,'show'),M.Kind='pie') then Exit;
  S:=CS(CJ(V,'formatter')); if S='' then if M.Kind='pie' then S:=M.Name else S:=FloatToStr(M.Value,TFormatSettings.Invariant);
  S:=StringReplace(S,'{b}',M.Name,[rfReplaceAll]); S:=StringReplace(S,'{c}',FloatToStr(M.Value,TFormatSettings.Invariant),[rfReplaceAll]);
  S:=StringReplace(S,'{a}',FSeries[M.SeriesIndex].Name,[rfReplaceAll]);
  if Pos('{d}',S)>0 then begin
    Total:=0; for I:=0 to High(FSeries[M.SeriesIndex].Values) do if not FSeries[M.SeriesIndex].Values[I].Missing then Total:=Total+Max(0,FSeries[M.SeriesIndex].Values[I].Y);
    if Total>0 then Total:=M.Value*100/Total;
    S:=StringReplace(S,'{d}',FormatFloat('0.'+StringOfChar('#',EnsureRange(Round(CN(CJ(FSeries[M.SeriesIndex].Options,'percentPrecision'),2)),0,15)),Total,TFormatSettings.Invariant),[rfReplaceAll]);
  end;
  if Assigned(FOnFormat) then FOnFormat(Self,M.SeriesIndex,M.DataIndex,M.Name,M.Value,S);
  if M.Kind='bar' then Position:=CS(CJ(V,'position'),'inside') else Position:=CS(CJ(V,'position'),'top'); D:=CN(CJ(V,'distance'),5)*FScale; X:=M.X; Y:=M.Y-D-12*FScale; Align:='center';
  if Position='inside' then begin X:=(M.Bounds.Left+M.Bounds.Right)/2; Y:=(M.Bounds.Top+M.Bounds.Bottom)/2-6*FScale; end;
  if Position='bottom' then begin X:=(M.Bounds.Left+M.Bounds.Right)/2; Y:=M.Bounds.Bottom+D; end;
  if Position='left' then begin X:=M.Bounds.Left-D; Y:=(M.Bounds.Top+M.Bounds.Bottom)/2-6*FScale; Align:='right'; end;
  if Position='right' then begin X:=M.Bounds.Right+D; Y:=(M.Bounds.Top+M.Bounds.Bottom)/2-6*FScale; Align:='left'; end;
  if Position='insideTop' then begin X:=(M.Bounds.Left+M.Bounds.Right)/2; Y:=M.Bounds.Top+D; end;
  if Position='insideBottom' then begin X:=(M.Bounds.Left+M.Bounds.Right)/2; Y:=M.Bounds.Bottom-D-12*FScale; end;
  if M.Kind='pie' then begin
    if Position='inside' then begin X:=M.CX+(M.X-M.CX)*0.65; Y:=M.CY+(M.Y-M.CY)*0.65; end
    else begin
      X:=M.CX+(M.X-M.CX)*1.16; Y:=M.CY+(M.Y-M.CY)*1.16;
      Line:=CJ(FSeries[M.SeriesIndex].Options,'labelLine');
      if CB(CJ(Line,'show'),True) then begin
        Paint:=PaintFor(CJ(Line,'lineStyle'),Palette(M.DataIndex),M.Bounds,True); Paint.StrokeWidth:=FScale;
        FC.DrawLine(M.X,M.Y,X,Y,Paint);
      end;
    end;
  end;
  W:=TextWidth(S,V); H:=CN(CJ(V,'fontSize'),12)*FScale;
  HideOverlap:=CB(CJ(CJ(FSeries[M.SeriesIndex].Options,'labelLayout'),'hideOverlap'));
  R:=TRectF.Create(X-W/2,Y,X+W/2,Y+H);
  for Other in FLabelBounds do if R.IntersectsWith(Other) and HideOverlap then Exit;
  if (M.Kind='pie') and CB(CJ(FSeries[M.SeriesIndex].Options,'avoidLabelOverlap'),True) then begin
    Attempts:=0;
    repeat
      Overlap:=False;
      for Other in FLabelBounds do if R.IntersectsWith(Other) then begin Overlap:=True; Break; end;
      if Overlap then begin R.Offset(0,H+2*FScale); Y:=R.Top; end;
      Inc(Attempts);
    until not Overlap or (Attempts>FMarks.Count);
    if R.Bottom>FSurface.Height then Exit;
  end;
  FLabelBounds.Add(R);
  if V is TJSONObject then Resolved:=TJSONObject(V.Clone) else Resolved:=TJSONObject.Create;
  try
    if (M.Kind='bar') and Position.StartsWith('inside') and (CJ(V,'color')=nil) then CSet(Resolved,'color',TJSONString.Create('#ffffff'));
    Text(S,X,Y,Resolved,Align,CN(CJ(V,'width'))*FScale);
  finally Resolved.Free; end;
end;
procedure TDACChartEngine.DrawTitle;
var V,Style: TJSONValue; X,Y: Double; Align: string; Resolved: TJSONObject; Pair: TJSONPair;
begin
  V:=CJ(FOptions,'title'); if (V=nil) or not CB(CJ(V,'show'),True) then Exit;
  X:=LengthValue(CJ(V,'left'),FSurface.Width,5); Y:=LengthValue(CJ(V,'top'),FSurface.Height,15)+5*FScale; Align:='left';
  if CS(CJ(V,'left'),'center')='center' then begin X:=FSurface.Width/2; Align:='center'; end;
  if CS(CJ(V,'left'))='right' then begin X:=FSurface.Width-5*FScale; Align:='right'; end;
  Style:=CJ(V,'textStyle');
  Resolved:=TJSONObject.Create;
  try
    Resolved.AddPair('fontSize',TJSONNumber.Create(18)); Resolved.AddPair('fontWeight','bold'); Resolved.AddPair('color','#3c3c41');
    if Style is TJSONObject then for Pair in TJSONObject(Style) do CSet(Resolved,Pair.JsonString.Value,TJSONValue(Pair.JsonValue.Clone));
    Text(CS(CJ(V,'text')),X,Y,Resolved,Align);
  finally Resolved.Free; end;
  Text(CS(CJ(V,'subtext')),X,Y+(CN(CJ(Style,'fontSize'),18)+CN(CJ(V,'itemGap'),10))*FScale,CJ(V,'subtextStyle'),Align);
end;
procedure TDACChartEngine.DrawLegend;
var V,Style: TJSONValue; Names: TStringList; S,P,I,First,Last,PageSize: Integer;
  X,Y,W,H,Gap,ItemW,Available,TotalWidth,Used: Double; M: TDACChartMark; Paint: ISkPaint;
  Vertical,Scroll: Boolean;
begin
  V:=CJ(FOptions,'legend'); if (V=nil) or not CB(CJ(V,'show'),True) then Exit;
  Names:=TStringList.Create;
  try
    for S:=0 to High(FSeries) do
      if FSeries[S].Kind='pie' then for P:=0 to High(FSeries[S].Values) do Names.AddObject(FSeries[S].Values[P].Name,TObject(NativeInt(S)+1))
      else if FSeries[S].Name<>'' then Names.AddObject(FSeries[S].Name,TObject(NativeInt(S)+1));
    W:=CN(CJ(V,'itemWidth'),25)*FScale; H:=CN(CJ(V,'itemHeight'),14)*FScale; Gap:=CN(CJ(V,'itemGap'),10)*FScale;
    X:=LengthValue(CJ(V,'left'),FSurface.Width,5); Y:=LengthValue(CJ(V,'top'),FSurface.Height,5);
    if CS(CJ(V,'top'))='bottom' then Y:=FSurface.Height-H-5*FScale;
    X:=X+5*FScale;
    Style:=CJ(V,'textStyle'); TotalWidth:=0;
    for I:=0 to Names.Count-1 do TotalWidth:=TotalWidth+W+5*FScale+TextWidth(Names[I],Style)+Gap;
    TotalWidth:=Max(0,TotalWidth-Gap);
    if CS(CJ(V,'left'),'center')='center' then X:=Max(5*FScale,(FSurface.Width-TotalWidth)/2);
    if CS(CJ(V,'left'))='right' then X:=FSurface.Width-120*FScale;
    Style:=CJ(V,'textStyle'); Vertical:=CS(CJ(V,'orient'),'horizontal')='vertical';
    Scroll:=CS(CJ(V,'type'),'plain')='scroll'; PageSize:=Max(1,Names.Count);
    Available:=FSurface.Width-X-10*FScale;
    if Vertical then Available:=FSurface.Height-Y-10*FScale;
    if Scroll then begin
      if Vertical then PageSize:=Max(1,Floor((Available-24*FScale)/(H+Gap)))
      else begin
        PageSize:=0; Used:=0;
        for I:=0 to Names.Count-1 do begin
          ItemW:=TextWidth(Names[I],Style)+W+5*FScale+Gap;
          if (Used+ItemW-Gap>Available-58*FScale) and (PageSize>0) then Break;
          Used:=Used+ItemW; Inc(PageSize);
        end;
        PageSize:=Max(1,PageSize);
      end;
    end;
    FLegendPage:=EnsureRange(FLegendPage,0,Max(0,(Names.Count-1) div PageSize));
    First:=FLegendPage*PageSize; Last:=Min(Names.Count-1,First+PageSize-1);
    if not Scroll then begin First:=0; Last:=Names.Count-1; end;
    for I:=First to Last do begin
      M:=Default(TDACChartMark); M.Kind:='legend'; M.SeriesIndex:=-1; M.DataIndex:=I; M.Name:=Names[I];
      ItemW:=TextWidth(Names[I],Style)+W+5*FScale;
      if not Vertical and (X+ItemW>FSurface.Width-5*FScale) and not Scroll then begin X:=5*FScale; Y:=Y+H+Gap; end;
      M.Bounds:=TRectF.Create(X,Y,X+ItemW,Y+H); Paint:=PaintFor(nil,Palette(I),M.Bounds);
      if IsHidden(M.Name) then Paint.Color:=$FFCCCCCC;
      S:=NativeInt(Names.Objects[I])-1;
      if FSeries[S].Kind='line' then begin
        Paint.Style:=TSkPaintStyle.Stroke; Paint.StrokeWidth:=2*FScale;
        FC.DrawLine(X,Y+H/2,X+W,Y+H/2,Paint);
        FC.DrawCircle(X+W/2,Y+H/2,5*FScale,Paint);
      end else FC.DrawRoundRect(TRectF.Create(X,Y,X+W,Y+H),2*FScale,2*FScale,Paint);
      Text(M.Name,X+W+5*FScale,Y,Style,'left'); FMarks.Add(M);
      if Vertical then Y:=Y+H+Gap else X:=X+ItemW+Gap;
    end;
    if Scroll and (Names.Count>PageSize) then begin
      if not Vertical then X:=FSurface.Width-65*FScale;
      M:=Default(TDACChartMark); M.SeriesIndex:=-1; M.Kind:='legend-prev';
      M.Bounds:=TRectF.Create(X,Y,X+20*FScale,Y+20*FScale); FMarks.Add(M); Text('<',X,Y,Style);
      Text(Format('%d/%d',[FLegendPage+1,Ceil(Names.Count/PageSize)]),X+24*FScale,Y,Style);
      M.Kind:='legend-next'; M.Bounds:=TRectF.Create(X+45*FScale,Y,X+65*FScale,Y+20*FScale); FMarks.Add(M); Text('>',X+45*FScale,Y,Style);
    end;
  finally Names.Free; end;
end;
function TDACChartEngine.HitTest(const P: TPointF): Integer;
var I: Integer; M: TDACChartMark; D,A,T,Best: Double; V: TJSONValue;
begin
  Result:=-1;
  for I:=FMarks.Count-1 downto 0 do begin
    M:=FMarks[I];
    if M.Kind='pie' then begin
      D:=Hypot(P.X-M.CX,P.Y-M.CY); if (D<M.R0) or (D>M.R) then Continue;
      A:=RadToDeg(ArcTan2(P.Y-M.CY,P.X-M.CX))-M.StartAngle;
      if M.Sweep<0 then A:=-A; A:=A-Floor(A/360)*360;
      if A<=Abs(M.Sweep) then Exit(I);
    end else if M.Bounds.Contains(P) then Exit(I);
  end;
  V:=CJ(FOptions,'tooltip');
  if (CS(CJ(V,'trigger'))='axis') and FPlot.Contains(P) then begin
    Best:=MaxDouble;
    for I:=0 to FMarks.Count-1 do if (FMarks[I].SeriesIndex>=0) and (FMarks[I].Kind<>'pie') then begin
      if FYCategory then D:=Abs(FMarks[I].Y-P.Y) else D:=Abs(FMarks[I].X-P.X);
      if D<Best then begin Best:=D; Result:=I; end;
    end;
  end;
end;
procedure TDACChartEngine.Activate(const P: TPointF);
var I,J: Integer; M: TDACChartMark; K,Mode: string;
begin
  I:=HitTest(P); if I<0 then Exit; M:=FMarks[I];
  if M.Kind='legend-prev' then begin FLegendPage:=Max(0,FLegendPage-1); Exit; end;
  if M.Kind='legend-next' then begin Inc(FLegendPage); Exit; end;
  if M.Kind='legend' then begin
    Mode:=CS(CJ(CJ(FOptions,'legend'),'selectedMode'),'true');
    if Mode='false' then Exit;
    if Mode='single' then begin
      for J:=0 to FMarks.Count-1 do if (FMarks[J].Kind='legend') and (FMarks[J].Name<>M.Name) then FHidden.AddOrSetValue(FMarks[J].Name,True);
      FHidden.Remove(M.Name); LoadData; Exit;
    end;
    if IsHidden(M.Name) then FHidden.Remove(M.Name) else FHidden.Add(M.Name,True); LoadData;
  end else begin
    Mode:=CS(CJ(FSeries[M.SeriesIndex].Options,'selectedMode'),'false');
    if Mode='false' then Exit;
    if Mode='single' then FSelected.Clear;
    K:=IntToStr(M.SeriesIndex)+'|'+M.Name;
    if FSelected.ContainsKey(K) then FSelected.Remove(K) else FSelected.Add(K,True);
  end;
end;
function TDACChartEngine.DataCount: Integer;
var S: TDACChartRenderSeries;
begin Result:=0; for S in FSeries do Inc(Result,Length(S.Values)); end;
function TDACChartEngine.NativeFontCount: Integer;
begin Result:=FFonts.Count; end;
procedure TDACChartEngine.DrawTooltip;
var V,PointerOptions: TJSONValue; M,N: TDACChartMark; Lines: TStringList; I: Integer;
  X,Y,W,H: Double; R: TRectF; Paint: ISkPaint; S: string;
begin
  V:=CJ(FOptions,'tooltip');
  if not FTooltipVisible or (V=nil) or not CB(CJ(V,'show'),True) or (CS(CJ(V,'trigger'))='none') or (FHover<0) then Exit;
  M:=FMarks[FHover]; if M.SeriesIndex<0 then Exit;
  if (CS(CJ(V,'trigger'))='axis') and (M.Kind<>'pie') then begin
    PointerOptions:=CJ(V,'axisPointer');
    if CS(CJ(PointerOptions,'type'),'line')='shadow' then begin
      Paint:=PaintFor(CJ(PointerOptions,'shadowStyle'),$20000000,FPlot);
      if FYCategory then R:=TRectF.Create(FPlot.Left,M.Y-FPlot.Height/Max(1,Length(FCategories))/2,FPlot.Right,M.Y+FPlot.Height/Max(1,Length(FCategories))/2)
      else R:=TRectF.Create(M.X-FPlot.Width/Max(1,Length(FCategories))/2,FPlot.Top,M.X+FPlot.Width/Max(1,Length(FCategories))/2,FPlot.Bottom);
      FC.DrawRect(R,Paint);
    end else if CS(CJ(PointerOptions,'type'),'line')='line' then begin
      Paint:=PaintFor(CJ(PointerOptions,'lineStyle'),$FFB7B9BE,FPlot,True); Paint.StrokeWidth:=FScale;
      if FYCategory then FC.DrawLine(FPlot.Left,M.Y,FPlot.Right,M.Y,Paint)
      else FC.DrawLine(M.X,FPlot.Top,M.X,FPlot.Bottom,Paint);
    end;
  end;
  Lines:=TStringList.Create;
  try
    Lines.Add(M.Name);
    for I:=0 to FMarks.Count-1 do begin
      N:=FMarks[I]; if N.SeriesIndex<0 then Continue;
      if ((CS(CJ(V,'trigger'),'item')='axis') and (Abs(FSeries[N.SeriesIndex].Values[N.DataIndex].X-FSeries[M.SeriesIndex].Values[M.DataIndex].X)<1E-8)) or (I=FHover) then begin
        S:=FSeries[N.SeriesIndex].Name+': '+FloatToStr(N.Value,TFormatSettings.Invariant);
        if CS(CJ(V,'formatter'))<>'' then begin
          S:=StringReplace(CS(CJ(V,'formatter')),'{a}',FSeries[N.SeriesIndex].Name,[rfReplaceAll]);
          S:=StringReplace(S,'{b}',N.Name,[rfReplaceAll]); S:=StringReplace(S,'{c}',FloatToStr(N.Value,TFormatSettings.Invariant),[rfReplaceAll]);
        end;
        if Assigned(FOnFormat) then FOnFormat(Self,N.SeriesIndex,N.DataIndex,N.Name,N.Value,S);
        Lines.AddObject(S,TObject(NativeInt(N.SeriesIndex)+1));
      end;
    end;
    W:=0;
    for I:=0 to Lines.Count-1 do W:=Max(W,TextWidth(Lines[I],CJ(V,'textStyle')));
    W:=Min(FSurface.Width,W+2*CN(CJ(V,'padding'),10)*FScale+16*FScale);
    H:=(Lines.Count*20+2*CN(CJ(V,'padding'),10))*FScale;
    X:=EnsureRange(FMouse.X+15*FScale,0,Max(0,FSurface.Width-W));
    Y:=EnsureRange(FMouse.Y+15*FScale,0,Max(0,FSurface.Height-H));
    R:=TRectF.Create(X,Y,X+W,Y+H);
    Paint:=PaintFor(nil,Color(CJ(V,'backgroundColor'),$FFFFFFFF),R); FC.DrawRoundRect(R,4*FScale,4*FScale,Paint);
    Paint:=PaintFor(nil,Color(CJ(V,'borderColor'),Palette(M.SeriesIndex)),R,True); Paint.StrokeWidth:=FScale; FC.DrawRoundRect(R,4*FScale,4*FScale,Paint);
    for I:=0 to Lines.Count-1 do begin
      if I>0 then begin
        Paint:=PaintFor(nil,Palette(NativeInt(Lines.Objects[I])-1),R);
        FC.DrawCircle(X+14*FScale,Y+(17+I*20)*FScale,4*FScale,Paint);
      end;
      Text(Lines[I],X+(10+16*Ord(I>0))*FScale,Y+(10+I*20)*FScale,CJ(V,'textStyle'),'left',W-36*FScale);
    end;
  finally Lines.Free; end;
end;
function TDACChartEngine.GeometryJSON: string;
var O,J: TJSONObject; A: TJSONArray; M: TDACChartMark;
begin
  O:=TJSONObject.Create;
  try
    O.AddPair('xMin',TJSONNumber.Create(FXMin)); O.AddPair('xMax',TJSONNumber.Create(FXMax));
    O.AddPair('yMin',TJSONNumber.Create(FYMin)); O.AddPair('yMax',TJSONNumber.Create(FYMax));
    O.AddPair('texts',TJSONValue(FTexts.Clone));
    O.AddPair('resolvedOption',TJSONValue(FOptions.Clone));
    A:=TJSONArray.Create; O.AddPair('marks',A);
    for M in FMarks do begin
      J:=TJSONObject.Create; A.AddElement(J);
      J.AddPair('kind',M.Kind); J.AddPair('name',M.Name);
      J.AddPair('series',TJSONNumber.Create(M.SeriesIndex)); J.AddPair('dataIndex',TJSONNumber.Create(M.DataIndex));
      J.AddPair('x',TJSONNumber.Create(M.X)); J.AddPair('y',TJSONNumber.Create(M.Y));
      J.AddPair('value',TJSONNumber.Create(M.Value)); J.AddPair('base',TJSONNumber.Create(M.Base));
      J.AddPair('left',TJSONNumber.Create(M.Bounds.Left)); J.AddPair('top',TJSONNumber.Create(M.Bounds.Top));
      J.AddPair('right',TJSONNumber.Create(M.Bounds.Right)); J.AddPair('bottom',TJSONNumber.Create(M.Bounds.Bottom));
      J.AddPair('radius',TJSONNumber.Create(M.R)); J.AddPair('innerRadius',TJSONNumber.Create(M.R0));
      J.AddPair('startAngle',TJSONNumber.Create(M.StartAngle)); J.AddPair('sweep',TJSONNumber.Create(M.Sweep));
    end;
    Result:=O.ToJSON;
  finally O.Free; end;
end;
end.
