program DACTreeViewPainterTests;

{$APPTYPE CONSOLE}

uses
  System.SysUtils, System.Classes, System.Types, System.Variants,
  Winapi.Windows, Vcl.Graphics, Vcl.Imaging.pngimage,
  DAC.Components.Controls.TreeView.Painter,
  DAC.Components.Controls.TreeView.Model,
  DAC.Components.Controls.TreeView.Columns,
  DAC.Components.DesignSystem.ControlTokens,
  DAC.Components.DesignSystem.ColorTokens,
  DAC.Components.DesignSystem.DBTreeTokens;

type
  TTestTreeModel = TDACTreeModel<TDACTreeModelNode>;
  TSourceProbe = class
  private
    FReads: Integer;
    function ReadText: string;
  public
    property Text: string read ReadText;
    property Reads: Integer read FReads;
  end;

var
  Assertions: Integer;
  SourceProbe: TSourceProbe;

function TSourceProbe.ReadText: string;
begin
  Inc(FReads);
  Result := 'Cached catalogue description with a long explanatory detail ';
end;

procedure Require(const Condition: Boolean; const MessageText: string);
begin
  Inc(Assertions);
  if not Condition then raise Exception.Create(MessageText);
end;

function Pixels(const Value, Dpi: Integer): Integer;
begin
  Result := TDACDBTreeTokens.Pixels(Value, Dpi);
end;

function DifferentPixels(Bitmap: TBitmap; const Bounds: TRect;
  const Background: TColor): Integer;
var X, Y: Integer;
begin
  Result := 0;
  for Y := Bounds.Top to Bounds.Bottom - 1 do
    for X := Bounds.Left to Bounds.Right - 1 do
      if ColorToRGB(Bitmap.Canvas.Pixels[X,Y]) <> ColorToRGB(Background) then
        Inc(Result);
end;

function InkRows(Bitmap: TBitmap; const Bounds: TRect;
  const Background: TColor): Integer;
var X, Y: Integer;
begin
  Result := 0;
  for Y := Bounds.Top to Bounds.Bottom - 1 do
    for X := Bounds.Left to Bounds.Right - 1 do
      if ColorToRGB(Bitmap.Canvas.Pixels[X,Y]) <> ColorToRGB(Background) then
      begin
        Inc(Result);
        Break;
      end;
end;

procedure SavePNG(Bitmap: TBitmap; const FileName: string);
var PNG: TPngImage;
begin
  PNG := TPngImage.Create;
  try
    PNG.Assign(Bitmap);
    PNG.SaveToFile(FileName);
  finally PNG.Free; end;
end;

procedure Populate(Model: TTestTreeModel; Columns: TDACTreeColumns);
var I: Integer; Node: TDACTreeModelNode;
begin
  Columns.Add.Caption := 'Code';
  Columns[0].Caption := 'Code';
  Columns[0].Width := 210;
  Columns.Add.Caption := 'Description';
  Columns[1].Caption := 'Description';
  Columns[1].Width := 650;
  for I := 0 to 999 do
  begin
    Node := TDACTreeModelNode.Create;
    Node.Key := Format('%.4d', [I]);
    if I > 0 then
    begin
      Node.ParentKey := '0000';
      Node.ParentToken := 'S:0000';
    end;
    Node.Expanded := I = 0;
    Node.Checked := I = 2;
    Node.Checkable := I <> 1;
    SetLength(Node.Cells, 2);
    Node.Cells[0] := Format('%.4d', [I]);
    Node.Cells[1] := SourceProbe.Text + IntToStr(I);
    Node.DataObject := SourceProbe;
    Model.Add(Node);
  end;
  Model.Validate;
  Model.BuildVisible('');
end;

procedure TestGeometry(Painter: TDACTreePainter; Model: TTestTreeModel;
  Columns: TDACTreeColumns; const Dpi: Integer);
var L, Last: TDACTreeLayout; H: TDACTreeHit;
  W, Height: Integer;
begin
  W := Pixels(640,Dpi);
  Height := Pixels(320,Dpi);
  L := Painter.Layout(W,Height,Dpi,Model,Columns);
  Require(Painter.HeaderHeight(Dpi) = Pixels(34,Dpi), 'Header DPI scaling');
  Require(Painter.RowHeight(Dpi) = Pixels(32,Dpi), 'Row DPI scaling');
  Require(L.PageRows = 8, 'Page rows derived from content after both scrollbars');
  Require(L.MaxTopRow = Model.Visible.Count - L.PageRows, 'Vertical row range');
  Require(L.MaxHorizontalOffset = Pixels(860,Dpi) - L.ContentRect.Width,
    'Horizontal range uses column widths');
  H := Painter.HitTest(Pixels(18,Dpi),Pixels(50,Dpi),W,Height,Dpi,Model,Columns,0,0);
  Require((H.Kind = thExpander) and (H.NodeIndex = 0), 'Expander hit is distinct');
  H := Painter.HitTest(Pixels(40,Dpi),Pixels(50,Dpi),W,Height,Dpi,Model,Columns,0,0);
  Require((H.Kind = thCheck) and (H.NodeIndex = 0), 'Check hit is distinct');
  H := Painter.HitTest(Pixels(100,Dpi),Pixels(50,Dpi),W,Height,Dpi,Model,Columns,0,0);
  Require((H.Kind = thRow) and (H.ColumnIndex = 0), 'Body hit is distinct');
  H := Painter.HitTest(Pixels(60,Dpi),Pixels(82,Dpi),W,Height,Dpi,Model,Columns,0,0);
  Require((H.Kind = thRow) and (H.NodeIndex = 1), 'Blocked node has no checkbox hit');
  H := Painter.HitTest(Pixels(60,Dpi),Pixels(114,Dpi),W,Height,Dpi,Model,Columns,0,0);
  Require((H.Kind = thCheck) and (H.NodeIndex = 2), 'Child indentation affects checkbox hit');
  H := Painter.HitTest(Pixels(250,Dpi),Pixels(15,Dpi),W,Height,Dpi,Model,Columns,0,0);
  Require((H.Kind = thHeader) and (H.ColumnIndex = 1), 'Header column hit');
  H := Painter.HitTest(L.VerticalThumb.CenterPoint.X,L.VerticalThumb.CenterPoint.Y,
    W,Height,Dpi,Model,Columns,0,0);
  Require(H.Kind = thVerticalThumb, 'Vertical thumb hit');
  H := Painter.HitTest(L.VerticalTrack.CenterPoint.X,L.VerticalTrack.Bottom - 1,
    W,Height,Dpi,Model,Columns,0,0);
  Require(H.Kind = thVerticalTrack, 'Vertical track hit outside thumb');
  H := Painter.HitTest(L.HorizontalThumb.CenterPoint.X,L.HorizontalThumb.CenterPoint.Y,
    W,Height,Dpi,Model,Columns,0,0);
  Require(H.Kind = thHorizontalThumb, 'Horizontal thumb hit');
  H := Painter.HitTest(L.HorizontalTrack.Right - 1,L.HorizontalTrack.CenterPoint.Y,
    W,Height,Dpi,Model,Columns,0,0);
  Require(H.Kind = thHorizontalTrack, 'Horizontal track hit outside thumb');
  Last := Painter.Layout(W,Height,Dpi,Model,Columns,MaxInt,MaxInt);
  Require(Last.TopRow = L.MaxTopRow, 'Vertical offset clamps to last page');
  Require(Last.HorizontalOffset = L.MaxHorizontalOffset, 'Horizontal offset clamps');
  Require(Last.VerticalThumb.Bottom = Last.VerticalTrack.Bottom,
    'Vertical thumb reaches track end');
  Require(Last.HorizontalThumb.Right = Last.HorizontalTrack.Right,
    'Horizontal thumb reaches track end');
  Last := Painter.Layout(W,Height,Dpi,Model,Columns,-100,-100);
  Require((Last.TopRow = 0) and (Last.HorizontalOffset = 0), 'Negative offsets clamp');
  Columns[0].Width := 16;
  try
    H := Painter.HitTest(Pixels(40,Dpi),Pixels(50,Dpi),W,Height,Dpi,Model,Columns,0,0);
    Require((H.Kind = thRow) and (H.ColumnIndex = 1),
      'Narrow first column cannot expose its checkbox hit in the next column');
  finally Columns[0].Width := 210; end;
end;

procedure TestPaint(Painter: TDACTreePainter; Model: TTestTreeModel;
  Columns: TDACTreeColumns; Bitmap: TBitmap; const Dpi: Integer;
  const Dark: Boolean; const OutputDirectory: string);
var L: TDACTreeLayout; Tokens: TDACControlTokens;
  ThemeName: string; Background: TColor; SourceReads: Integer;
begin
  SourceReads := SourceProbe.Reads;
  if Dark then begin Tokens := TDACControlTokens.Dark; ThemeName := 'dark'; end
  else begin Tokens := TDACControlTokens.Light; ThemeName := 'light'; end;
  Bitmap.SetSize(Pixels(640,Dpi),Pixels(320,Dpi));
  L := Painter.Layout(Bitmap.Width,Bitmap.Height,Dpi,Model,Columns);
  Painter.Paint(Bitmap.Canvas.Handle,Bitmap.Width,Bitmap.Height,Dpi,Tokens,
    Model,Columns,'S:0002',0,0,4,True,True,False,'');
  Require((Painter.PaintedRows > 0) and (Painter.PaintedRows <= L.PageRows + 1),
    'Paint traverses viewport and partial trailing row only');
  Require((Model.Nodes.Count = 1000) and (Model.Visible.Count = 1000),
    'Painting does not remove catalogue or projection entries');
  Require(Model.Nodes[0].Expanded and Model.Nodes[2].Checked and
    not Model.Nodes[1].Checkable, 'Painting preserves interaction state');
  Background := TDACComponentColors.ToVclColor(Tokens.InputDisabledBackground);
  Require(DifferentPixels(Bitmap,Rect(Pixels(10,Dpi),Pixels(6,Dpi),
    Pixels(100,Dpi),Pixels(27,Dpi)),Background) > 0, 'Native header text reaches buffer');
  Background := TDACComponentColors.ToVclColor(Tokens.InputBackground);
  Require(DifferentPixels(Bitmap,Rect(Pixels(55,Dpi),Pixels(40,Dpi),
    Pixels(150,Dpi),Pixels(61,Dpi)),Background) > 0, 'Native cell text reaches buffer');
  SavePNG(Bitmap,IncludeTrailingPathDelimiter(OutputDirectory) +
    'tree-' + IntToStr(Dpi) + '-' + ThemeName + '.png');
  Painter.Paint(Bitmap.Canvas.Handle,Bitmap.Width,Bitmap.Height,Dpi,Tokens,
    Model,Columns,'',L.MaxTopRow,L.MaxHorizontalOffset,-1,False,True,True,'');
  Require(Painter.PaintedRows <= L.PageRows + 1, 'Last page remains viewport bounded');
  Painter.Paint(Bitmap.Canvas.Handle,Bitmap.Width,Bitmap.Height,Dpi,Tokens,
    Model,Columns,'',0,0,-1,False,False,True,'Rejected catalogue');
  Require(Painter.PaintedRows = 0, 'Status screen never draws catalogue rows');
  Require(SourceProbe.Reads = SourceReads, 'Painter reads cache without invoking external object getters');
  Require(Model.Nodes[0].DataObject = SourceProbe, 'Painting preserves unowned object association');
end;

procedure TestClipping(Painter: TDACTreePainter; Model: TTestTreeModel;
  Columns: TDACTreeColumns; Bitmap: TBitmap);
var Node: TDACTreeModelNode; Tokens: TDACControlTokens; Background: TColor;
begin
  Tokens := TDACControlTokens.Light;
  Background := TDACComponentColors.ToVclColor(Tokens.InputBackground);
  for Node in Model.Nodes do Node.Cells[1] := '';
  Model.Nodes[0].Cells[0] := StringOfChar('W',100);
  Bitmap.SetSize(640,320);
  Columns[0].Width := 110;
  Painter.Paint(Bitmap.Canvas.Handle,640,320,96,Tokens,
    Model,Columns,'',0,0,-1,False,True,False,'');
  Require(DifferentPixels(Bitmap,Rect(120,39,200,61),Background) = 0,
    'Long native text is clipped before the next column');
  Columns[0].Width := 16;
  Painter.Paint(Bitmap.Canvas.Handle,640,320,96,Tokens,
    Model,Columns,'',0,0,-1,False,True,False,'');
  Require(DifferentPixels(Bitmap,Rect(20,39,100,61),Background) = 0,
    'Expander and checkbox chrome are clipped before the next column');
  Columns[0].Width := 210;
end;

procedure TestResources(Model: TTestTreeModel; Columns: TDACTreeColumns;
  Bitmap: TBitmap);
var I: Integer; Painter: TDACTreePainter; BeforeCount, AfterCount: DWORD;
begin
  { The caller has already warmed Skia, the font installer and bitmap DC. }
  BeforeCount := GetGuiResources(GetCurrentProcess,GR_GDIOBJECTS);
  for I := 1 to 50 do
  begin
    Painter := TDACTreePainter.Create;
    try
      Painter.Paint(Bitmap.Canvas.Handle,640,320,96,TDACControlTokens.Light,
        Model,Columns,'',0,0,-1,False,True,False,'');
    finally Painter.Free; end;
  end;
  AfterCount := GetGuiResources(GetCurrentProcess,GR_GDIOBJECTS);
  Require(AfterCount <= BeforeCount + 2, 'Repeated surface/font teardown leaks GDI handles');
end;

procedure TestNativeFontScaling(Painter: TDACTreePainter; Model: TTestTreeModel;
  Columns: TDACTreeColumns; Bitmap: TBitmap);
var NativeFont: TFont; I, Dpi, InkHeight: Integer;
  L: TDACTreeLayout; R: TRect; Tokens: TDACControlTokens;
begin
  NativeFont := TFont.Create;
  try
    NativeFont.Name := 'Arial';
    NativeFont.PixelsPerInch := 96;
    Tokens := TDACControlTokens.Light;
    Model.Nodes[0].Cells[0] := StringOfChar('W',100);
    for I := 0 to 2 do
    begin
      case I of 0: Dpi := 96; 1: Dpi := 144; else Dpi := 192; end;
      { Delphi 10.2 ChangeScale changes Height without updating the font PPI.
        Its Size property therefore already includes the VCL scaling factor. }
      NativeFont.Height := -Pixels(12,Dpi);
      Bitmap.SetSize(Pixels(640,Dpi),Pixels(320,Dpi));
      Painter.Paint(Bitmap.Canvas.Handle,Bitmap.Width,Bitmap.Height,Dpi,Tokens,
        Model,Columns,'',0,0,-1,False,True,False,'',NativeFont);
      L := Painter.Layout(Bitmap.Width,Bitmap.Height,Dpi,Model,Columns);
      R := Rect(Pixels(55,Dpi),L.ContentRect.Top + Pixels(2,Dpi),
        Pixels(150,Dpi),L.ContentRect.Top + Painter.RowHeight(Dpi) - Pixels(2,Dpi));
      InkHeight := InkRows(Bitmap,R,TDACComponentColors.ToVclColor(Tokens.InputBackground));
      Require(InkHeight > 0, 'Explicit VCL font draws native glyphs');
      Require(InkHeight <= Abs(NativeFont.Height),
        'VCL-scaled font height must not be scaled a second time at DPI ' + IntToStr(Dpi));
    end;
  finally NativeFont.Free; end;
end;

procedure TestOptionalChecks(Painter: TDACTreePainter; Model: TTestTreeModel;
  Columns: TDACTreeColumns; Bitmap: TBitmap; Dpi: Integer);
var H: TDACTreeHit; Tokens: TDACControlTokens; Background: TColor;
  WithCheckX, WithoutCheckX: Integer; OriginalText: string;
  function FirstInk: Integer;
  var X, Y: Integer;
  begin
    Result := MaxInt;
    for X := Pixels(30,Dpi) to Pixels(180,Dpi) do
      for Y := Pixels(40,Dpi) to Pixels(60,Dpi) do
        if ColorToRGB(Bitmap.Canvas.Pixels[X,Y]) <> ColorToRGB(Background) then
          Exit(X);
  end;
begin
  Tokens := TDACControlTokens.Light;
  Background := TDACComponentColors.ToVclColor(Tokens.InputBackground);
  Bitmap.SetSize(Pixels(640,Dpi),Pixels(320,Dpi));
  Painter.ShowCheckBoxes := False;
  H := Painter.HitTest(Pixels(40,Dpi),Pixels(50,Dpi),Bitmap.Width,Bitmap.Height,
    Dpi,Model,Columns,0,0);
  Require(H.Kind = thRow, 'Hidden checkbox exposes row body rather than a checkbox hit');
  H := Painter.HitTest(Pixels(60,Dpi),Pixels(114,Dpi),Bitmap.Width,Bitmap.Height,
    Dpi,Model,Columns,0,0);
  Require(H.Kind = thRow, 'Hidden child checkbox is not clickable');
  OriginalText := Model.Nodes[0].Cells[0];
  Model.Nodes[0].Cells[0] := 'WWWW';
  Model.Nodes[0].Checkable := False;
  try
    Painter.Paint(Bitmap.Canvas.Handle,Bitmap.Width,Bitmap.Height,Dpi,Tokens,
      Model,Columns,'',0,0,-1,False,True,False,'');
    WithoutCheckX := FirstInk;
    Painter.ShowCheckBoxes := True;
    Painter.Paint(Bitmap.Canvas.Handle,Bitmap.Width,Bitmap.Height,Dpi,Tokens,
      Model,Columns,'',0,0,-1,False,True,False,'');
    WithCheckX := FirstInk;
    Require((WithoutCheckX <> MaxInt) and (WithCheckX <> MaxInt),
      'Both checkbox modes draw native item text');
    Require(WithoutCheckX + Pixels(12,Dpi) <= WithCheckX,
      'Hidden checkbox does not reserve its horizontal text space');
  finally
    Painter.ShowCheckBoxes := True;
    Model.Nodes[0].Checkable := True;
    Model.Nodes[0].Cells[0] := OriginalText;
  end;
end;

procedure Run;
var Painter: TDACTreePainter; Model: TTestTreeModel;
  Columns: TDACTreeColumns; Bitmap: TBitmap; Dpi, I: Integer;
  OutputDirectory: string;
begin
  OutputDirectory := ParamStr(1);
  if OutputDirectory = '' then
    OutputDirectory := ExtractFilePath(ParamStr(0)) + 'PainterEvidence';
  OutputDirectory := ExpandFileName(OutputDirectory);
  ForceDirectories(OutputDirectory);
  SourceProbe := TSourceProbe.Create;
  Painter := TDACTreePainter.Create;
  Model := TTestTreeModel.Create;
  Columns := TDACTreeColumns.Create(nil);
  Bitmap := TBitmap.Create;
  try
    Populate(Model,Columns);
    for I := 0 to 2 do
    begin
      case I of 0: Dpi := 96; 1: Dpi := 144; else Dpi := 192; end;
      TestGeometry(Painter,Model,Columns,Dpi);
      TestOptionalChecks(Painter,Model,Columns,Bitmap,Dpi);
      TestPaint(Painter,Model,Columns,Bitmap,Dpi,False,OutputDirectory);
      TestPaint(Painter,Model,Columns,Bitmap,Dpi,True,OutputDirectory);
      Writeln('PASS painter geometry/rendering DPI ',Dpi,' light/dark');
    end;
    TestClipping(Painter,Model,Columns,Bitmap);
    TestNativeFontScaling(Painter,Model,Columns,Bitmap);
    TestResources(Model,Columns,Bitmap);
    Model.Clear;
    Require(Painter.Layout(640,320,96,Model,Columns).MaxTopRow = 0,
      'Empty model has no vertical range');
    Painter.Paint(Bitmap.Canvas.Handle,640,320,96,TDACControlTokens.Light,
      Model,Columns,'',0,0,-1,False,True,False,'No rows');
    Require(Painter.PaintedRows = 0, 'Empty model paints no rows');
    Writeln('PASS ',Assertions,' painter assertions. Evidence: ',OutputDirectory);
    Writeln('DPI cases are offscreen raster tests; physical monitor DPI remains separate.');
  finally
    Bitmap.Free;
    Columns.Free;
    Model.Free;
    Painter.Free;
    SourceProbe.Free;
  end;
end;

begin
  try
    Run;
  except
    on E: Exception do
    begin
      Writeln('FAIL: ',E.ClassName,': ',E.Message);
      Halt(1);
    end;
  end;
end.
