program DACTreeViewHeaderTests;

{$APPTYPE CONSOLE}

uses
  System.SysUtils, System.Classes, System.Types, System.Variants, System.Math,
  Winapi.Windows, Winapi.Messages, Vcl.Controls, Vcl.Forms, Vcl.Graphics,
  Vcl.Imaging.pngimage, Data.DB, Datasnap.DBClient, MidasLib,
  DAC.Components.Controls.DBTreeView,
  DAC.Components.Controls.DBTreeView.Types,
  DAC.Components.Controls.DBTreeView.Painter,
  DAC.Components.Controls.TreeView,
  DAC.Components.Controls.TreeView.Painter,
  DAC.Components.Controls.TreeView.Model,
  DAC.Components.Controls.TreeView.Columns,
  DAC.Components.Controls.TreeView.Item,
  DAC.Components.DesignSystem.DBTreeTokens,
  DAC.Components.DesignSystem.Theme,
  DAC.Components.DesignSystem.ColorTokens,
  DAC.Components.DesignSystem.ControlTokens;

type
  TDBAccess = class(TDACDBTreeView)
  public
    procedure ClickAt(const P: TPoint);
    procedure Key(AKey: Word);
    procedure Recreate;
    procedure DesignMode;
  end;
  TTreeAccess = class(TDACTreeView)
  public
    procedure ClickAt(const P: TPoint);
    procedure Key(AKey: Word);
    procedure Recreate;
    procedure DesignMode;
  end;
  TFixture = class
  public
    Form: TForm;
    Data: TClientDataSet;
    Source: TDataSource;
    DB: TDBAccess;
    Tree: TTreeAccess;
    Activations: Integer;
    constructor Create;
    destructor Destroy; override;
    procedure DBActivate(Sender: TObject; const Key: Variant);
    procedure TreeActivate(Sender: TObject; const Key: Variant; DataObject: TObject);
  end;

var Assertions: Integer; Evidence: string;

procedure Require(Condition: Boolean; const MessageText: string);
begin
  Inc(Assertions);
  if not Condition then raise Exception.Create(MessageText);
end;

procedure TDBAccess.ClickAt(const P: TPoint);
begin MouseDown(mbLeft, [], P.X, P.Y); MouseUp(mbLeft, [], P.X, P.Y); end;
procedure TTreeAccess.ClickAt(const P: TPoint);
begin MouseDown(mbLeft, [], P.X, P.Y); MouseUp(mbLeft, [], P.X, P.Y); end;
procedure TDBAccess.Key(AKey: Word);
begin KeyDown(AKey, []); end;
procedure TTreeAccess.Key(AKey: Word);
begin KeyDown(AKey, []); end;
procedure TDBAccess.Recreate;
begin RecreateWnd; end;
procedure TTreeAccess.Recreate;
begin RecreateWnd; end;
procedure TDBAccess.DesignMode;
begin SetDesigning(True); end;
procedure TTreeAccess.DesignMode;
begin SetDesigning(True); end;

constructor TFixture.Create;
var I: Integer; Item: TDACTreeItem; K: string;
begin
  inherited;
  Form := TForm.CreateNew(nil);
  Form.SetBounds(0,0,700,700);
  Data := TClientDataSet.Create(Form);
  Data.FieldDefs.Add('ID',ftString,20);
  Data.FieldDefs.Add('PARENT',ftString,20);
  Data.FieldDefs.Add('LABEL',ftString,160);
  Data.CreateDataSet;
  Data.AppendRecord(['R',Null,'Root description']);
  for I := 1 to 30 do
    Data.AppendRecord([Format('N%.2d',[I]),'R','Long description of child ' + IntToStr(I)]);
  Data.First;
  Source := TDataSource.Create(Form);
  Source.DataSet := Data;
  DB := TDBAccess.Create(Form);
  Tree := TTreeAccess.Create(Form);
  Require(DB.ShowHeader and Tree.ShowHeader, 'Both controls default to ShowHeader=True');
  DB.ShowHeader := False;
  Tree.ShowHeader := False;
  Require(not DB.HandleAllocated and not Tree.HandleAllocated,
    'Visual setters do not create handles without Parent');
  DB.Parent := Form;
  Tree.Parent := Form;
  DB.SetBounds(0,0,640,320);
  Tree.SetBounds(0,330,640,320);
  DB.BeginUpdate;
  try
    DB.KeyField := 'ID'; DB.ParentField := 'PARENT';
    with DB.Columns.Add do begin FieldName := 'LABEL'; Caption := 'Header'; Width := 210;
      TitleHint := 'TITLE ONLY'; Hint := 'CELL HINT'; end;
    with DB.Columns.Add do begin FieldName := 'ID'; Caption := 'Key'; Width := 650; end;
    DB.DataSource := Source;
  finally DB.EndUpdate; end;
  Tree.BeginUpdate;
  try
    Tree.Columns[0].Caption := 'Header'; Tree.Columns[0].Width := 210;
    Tree.Columns[0].TitleHint := 'TITLE ONLY'; Tree.Columns[0].Hint := 'CELL HINT';
    with Tree.Columns.Add do begin Caption := 'Key'; Width := 650; end;
    Item := Tree.Items.Add(nil,'Root description'); Item.Key := 'R';
    for I := 1 to 30 do
    begin
      K := Format('N%.2d',[I]);
      Item := Tree.Items.AddChild(Tree.Items[0], 'Long description of child ' + IntToStr(I));
      Item.Key := K; Item.SubItems.Add(K);
    end;
  finally Tree.EndUpdate; end;
  Tree.ShowCheckBoxes := True;
  DB.ExpandAll; Tree.ExpandAll;
  DB.OnActivateRecord := DBActivate; Tree.OnActivateRecord := TreeActivate;
end;

destructor TFixture.Destroy;
begin Form.Free; inherited; end;
procedure TFixture.DBActivate(Sender: TObject; const Key: Variant);
begin Inc(Activations); end;
procedure TFixture.TreeActivate(Sender: TObject; const Key: Variant; DataObject: TObject);
begin Inc(Activations); end;

function HintAt(Control: TControl; const P: TPoint): string;
var Info: Vcl.Controls.THintInfo;
begin
  Info := Default(Vcl.Controls.THintInfo); Info.CursorPos := P;
  Control.Perform(CM_HINTSHOW,0,LPARAM(@Info));
  Result := Info.HintStr;
end;

procedure RequireKeyVisible(Control: TControl; const Key: string; ContentBottom: Integer);
var Info: Vcl.Controls.THintInfo; Y: Integer;
begin
  for Y := 1 to ContentBottom-1 do
  begin
    Info := Default(Vcl.Controls.THintInfo); Info.CursorPos := Point(250,Y);
    Control.Perform(CM_HINTSHOW,0,LPARAM(@Info));
    if Info.HintStr = Key then
    begin
      Require(Info.CursorRect.Bottom <= ContentBottom,'Current row is completely visible');
      Exit;
    end;
  end;
  Require(False,'Current key has no cell in the viewport');
end;

function FindHit(Painter: TDACTreePainter; Model: TDACTreeModelBase;
  Columns: TDACTreeColumns; Kind: TDACTreeHitKind; const Y, Dpi: Integer): TPoint;
var X: Integer; H: TDACTreeHit;
begin
  for X := 1 to 639 do
  begin
    H := Painter.HitTest(X,Y,640,320,Dpi,Model,Columns,0,0);
    if (H.Kind = Kind) and (H.NodeIndex = 0) then Exit(H.Bounds.CenterPoint);
  end;
  raise Exception.Create('Expected first-row hit not found');
end;

procedure TestGeometryAndPaint(Painter: TDACTreePainter;
  Model: TDACTreeModelBase; Columns: TDACTreeColumns; const Name: string);
var Dpi, Scale, Mode, W, Height, Border, X, Y, I: Integer;
  L, Visible, Last: TDACTreeLayout; H: TDACTreeHit;
  Bitmap: TBitmap; PNG: TPngImage; Tokens: TDACControlTokens; ThemeName: string;
begin
  Bitmap := TBitmap.Create; PNG := TPngImage.Create;
  try
    Require(Painter.ShowHeader,'Painter default preserves existing clients');
    for Scale := 1 to 3 do
    begin
      case Scale of 1: Dpi := 96; 2: Dpi := 144; else Dpi := 192; end;
      W := MulDiv(640,Dpi,96); Height := MulDiv(320,Dpi,96);
      Border := TDACDBTreeTokens.Pixels(1,Dpi);
      Painter.ShowHeader := True;
      Visible := Painter.Layout(W,Height,Dpi,Model,Columns);
      Require(Visible.HeaderRect.Height = Painter.HeaderHeight(Dpi),'Default header geometry');
      Require(Visible.PageRows = 8,'Default page capacity unchanged');
      Painter.ShowHeader := False;
      L := Painter.Layout(W,Height,Dpi,Model,Columns);
      Require((L.HeaderRect.Height = 0) and (L.ContentRect.Top = Border),
        'No reserved space above rows');
      Require(L.PageRows > Visible.PageRows,'Hidden header increases row capacity');
      Require(L.MaxTopRow = Model.Visible.Count - L.PageRows,'New vertical limit');
      Require(L.MaxHorizontalOffset = Visible.MaxHorizontalOffset,'Horizontal alignment preserved');
      Require(L.VerticalThumb.Height >= Visible.VerticalThumb.Height,'Thumb reflects larger page');
      Y := L.ContentRect.Top + Painter.RowHeight(Dpi) div 2;
      H := Painter.HitTest(MulDiv(18,Dpi,96),Y,W,Height,Dpi,Model,Columns,0,0);
      Require((H.Kind = thExpander) and (H.NodeIndex = 0),'First row expander without header');
      H := Painter.HitTest(MulDiv(40,Dpi,96),Y,W,Height,Dpi,Model,Columns,0,0);
      Require((H.Kind = thCheck) and (H.NodeIndex = 0),'First row checkbox without header');
      for I := 0 to 2 do
      begin
        X := MulDiv(100,Dpi,96);
        H := Painter.HitTest(X,L.ContentRect.Top + I,W,Height,Dpi,Model,Columns,0,0);
        Require((H.Kind = thRow) and (H.NodeIndex = 0),'No invisible header hit strip');
      end;
      for Mode := 0 to 1 do
      begin
        Painter.ShowHeader := Mode = 1;
        L := Painter.Layout(W,Height,Dpi,Model,Columns,-100,-100);
        Require((L.TopRow = 0) and (L.HorizontalOffset = 0),'Lower scroll clamps');
        Last := Painter.Layout(W,Height,Dpi,Model,Columns,MaxInt,MaxInt);
        Require((Last.TopRow = Last.MaxTopRow) and
          (Last.HorizontalOffset = Last.MaxHorizontalOffset),'Upper scroll clamps');
        Require((Last.VerticalThumb.Bottom = Last.VerticalTrack.Bottom) and
          (Last.HorizontalThumb.Right = Last.HorizontalTrack.Right),'Thumb reaches both track ends');
        Y := Last.ContentRect.Top + (Model.Visible.Count - 1 - Last.TopRow) *
          Painter.RowHeight(Dpi) + Painter.RowHeight(Dpi) div 2;
        H := Painter.HitTest(Last.ContentRect.Right-2,Y,W,Height,Dpi,Model,Columns,
          Last.TopRow,Last.HorizontalOffset);
        Require((H.Kind = thRow) and (H.NodeIndex = Model.Visible[Model.Visible.Count-1]),
          'Last full row hits the last record at scroll limit');
        H := Painter.HitTest(Last.ContentRect.Right-2,Last.ContentRect.Top+2,W,Height,Dpi,
          Model,Columns,Last.TopRow,Last.HorizontalOffset);
        Require(H.ColumnIndex = 1,'Horizontal scrolling keeps column hit alignment');
        Bitmap.SetSize(W,Height);
        for I := 0 to 1 do
        begin
          if I = 0 then begin Tokens := TDACControlTokens.Light; ThemeName := 'light'; end
          else begin Tokens := TDACControlTokens.Dark; ThemeName := 'dark'; end;
          Painter.Paint(Bitmap.Canvas.Handle,W,Height,Dpi,Tokens,Model,Columns,'',0,0,-1,
            True,True,False,'');
          Require((Painter.PaintedRows > 0) and (Painter.PaintedRows <= L.PageRows+1),
            'Paint is limited to the viewport in both modes');
          PNG.Assign(Bitmap);
          PNG.SaveToFile(IncludeTrailingPathDelimiter(Evidence)+Format('%s-%d-%s-header-%d.png',
            [Name,Dpi,ThemeName,Mode]));
          Painter.Paint(Bitmap.Canvas.Handle,MulDiv(90,Dpi,96),MulDiv(18,Dpi,96),
            Dpi,Tokens,Model,Columns,'',0,0,-1,False,True,False,'');
          L := Painter.Layout(MulDiv(90,Dpi,96),MulDiv(18,Dpi,96),Dpi,Model,Columns);
          Require((L.HeaderRect.Height >= 0) and (L.ContentRect.Height >= 0) and
            (L.PageRows >= 1),'Tiny control remains safe');
          L := Painter.Layout(W,Height,Dpi,Model,Columns);
        end;
      end;
    end;
  finally PNG.Free; Bitmap.Free; end;
end;

procedure TestInteraction(F: TFixture);
var Painter: TDACTreePainter; L: TDACTreeLayout; P: TPoint;
  Dpi, I, DBReads, DBLoads, Reads, Loads, Count: Integer; Bitmap: TBitmap;
begin
  Painter := TDACTreePainter.Create; Bitmap := TBitmap.Create;
  try
    Dpi := 96;
    F.DB.ShowHeader := False; F.Tree.ShowHeader := False;
    Painter.ShowHeader := False;
    L := Painter.Layout(640,320,Dpi,F.DB.Model,F.DB.Columns);
    P := FindHit(Painter,F.DB.Model,F.DB.Columns,thCheck,
      L.ContentRect.Top+Painter.RowHeight(Dpi) div 2,Dpi);
    F.DB.ClickAt(P); F.Tree.ClickAt(P);
    Require(F.DB.Model.Find('R').Checked and F.Tree.Model.Find('R').Checked,
      'Headerless first-row checkbox updates the right node');
    Require(HintAt(F.DB,Point(100,L.ContentRect.Top+2)) = 'CELL HINT','DB cell hint replaces title');
    Require(HintAt(F.Tree,Point(100,L.ContentRect.Top+2)) = 'CELL HINT','Tree cell hint replaces title');
    P := FindHit(Painter,F.DB.Model,F.DB.Columns,thExpander,
      L.ContentRect.Top+Painter.RowHeight(Dpi) div 2,Dpi);
    F.DB.ClickAt(P); F.Tree.ClickAt(P);
    Require((F.DB.Model.Visible.Count = 1) and (F.Tree.Model.Visible.Count = 1),
      'Headerless first-row expander collapses only its subtree');
    F.DB.ClickAt(P); F.Tree.ClickAt(P);
    Require((F.DB.Model.Visible.Count = 31) and (F.Tree.Model.Visible.Count = 31),'Expand restored');
    F.DB.ClickAt(Point(100,L.ContentRect.Top+2)); F.Tree.ClickAt(Point(100,L.ContentRect.Top+2));
    Require((F.DB.SelectedKey = 'R') and (F.Tree.SelectedKey = 'R'),'First row body selection');
    F.DB.Key(VK_DOWN); F.Tree.Key(VK_DOWN);
    Require((F.DB.SelectedKey = 'N01') and (F.Tree.SelectedKey = 'N01'),'Arrow navigation');
    F.DB.Key(VK_SPACE); F.Tree.Key(VK_SPACE);
    Require(F.DB.Model.Find('N01').Checked and F.Tree.Model.Find('N01').Checked,'Space marks current');
    F.DB.Key(VK_RETURN); F.Tree.Key(VK_RETURN);
    Require(F.Activations = 2,'One activation per Enter');
    F.DB.Perform(WM_LBUTTONDBLCLK,MK_LBUTTON,MakeLParam(100,L.ContentRect.Top+2));
    F.Tree.Perform(WM_LBUTTONDBLCLK,MK_LBUTTON,MakeLParam(100,L.ContentRect.Top+2));
    Require((F.Activations = 2) and F.DB.Model.Find('R').Expanded and
      F.Tree.Model.Find('R').Expanded and F.DB.Model.Find('R').Checked and
      F.Tree.Model.Find('R').Checked,'Double click preserves existing activation/expansion/check behavior');
    F.DB.SelectedKey := 'N01'; F.Tree.SelectedKey := 'N01';
    F.DB.SearchText := 'child 30'; F.Tree.SearchText := 'child 30';
    DBReads := F.DB.DataReadCount; DBLoads := F.DB.LoadCount;
    Reads := F.Tree.DataReadCount; Loads := F.Tree.LoadCount;
    Count := F.DB.Model.Visible.Count;
    for I := 1 to 10 do
    begin
      F.DB.ShowHeader := Odd(I); F.Tree.ShowHeader := not Odd(I);
      Require(F.DB.ShowHeader <> F.Tree.ShowHeader,'Instances keep independent header state');
      Require((F.DB.SelectedKey = 'N01') and (F.Tree.SelectedKey = 'N01'),
        'Selection outside search preserved');
      Require((F.DB.SearchText = 'child 30') and (F.Tree.SearchText = 'child 30') and
        (F.DB.Model.Visible.Count = Count) and (F.Tree.Model.Visible.Count = Count),
        'Search and projection are not rebuilt by a visual setter');
      Require(F.DB.Model.Find('R').Expanded and F.Tree.Model.Find('R').Expanded and
        F.DB.Model.Find('N01').Checked and F.Tree.Model.Find('N01').Checked,
        'Expansion and marking preserved');
    end;
    F.DB.SearchText := ''; F.Tree.SearchText := '';
    F.DB.SelectedKey := 'N30'; F.Tree.SelectedKey := 'N30';
    Bitmap.SetSize(640,320);
    for I := 1 to 5 do
    begin
      F.DB.ShowHeader := Odd(I); F.Tree.ShowHeader := not Odd(I);
      RequireKeyVisible(F.DB,'N30',L.ContentRect.Bottom);
      RequireKeyVisible(F.Tree,'N30',L.ContentRect.Bottom);
      F.DB.PaintTo(Bitmap.Canvas.Handle,0,0); F.Tree.PaintTo(Bitmap.Canvas.Handle,0,0);
      F.DB.Recreate; F.Tree.Recreate;
      Require((F.DB.SelectedKey = 'N30') and (F.Tree.SelectedKey = 'N30'),
        'Handle recreation keeps last-row selection');
    end;
    Require((F.DB.DataReadCount = DBReads) and (F.DB.LoadCount = DBLoads),
      'Visual toggles, painting and handle recreation never reread dataset');
    Require((F.Tree.DataReadCount = Reads) and (F.Tree.LoadCount = Loads),
      'Plain tree visual changes never reload items');
    F.DB.SelectedKey := 'R'; F.Tree.SelectedKey := 'R';
    F.DB.ShowHeader := True; F.Tree.ShowHeader := True;
    Require(HintAt(F.DB,Point(100,10)) = 'TITLE ONLY','Visible DB TitleHint');
    Require(HintAt(F.Tree,Point(100,10)) = 'TITLE ONLY','Visible Tree TitleHint');
  finally Bitmap.Free; Painter.Free; end;
end;

procedure TestStreaming(F: TFixture);
var DB, DBRead: TDACDBTreeView; Tree, TreeRead: TDACTreeView;
  Binary: TMemoryStream; Text: TStringStream; I: Integer; Bitmap: TBitmap;
begin
  System.Classes.RegisterClass(TDACDBTreeView); System.Classes.RegisterClass(TDACTreeView);
  for I := 0 to 9 do
  begin
    DB := TDACDBTreeView.Create(nil); Tree := TDACTreeView.Create(nil);
    Binary := TMemoryStream.Create; Text := TStringStream.Create(''); Bitmap := TBitmap.Create;
    try
      DB.Name := 'DB'; Tree.Name := 'Tree';
      DB.ShowHeader := False; Tree.ShowHeader := False;
      Tree.Items.Add(nil,'Streamed root');
      Tree.Columns[0].Width := 640;
      Require(not DB.HandleAllocated and not Tree.HandleAllocated,'Unparented setters are handle-free');
      Binary.WriteComponent(DB); Binary.Position := 0;
      ObjectBinaryToText(Binary,Text);
      Require(Pos('ShowHeader = False',Text.DataString) > 0,'False stored in DB DFM');
      Binary.Position := 0;
      DBRead := TDACDBTreeView(Binary.ReadComponent(nil));
      try
        Require(not DBRead.ShowHeader and not DBRead.HandleAllocated,'DB false restored without Parent');
        DBRead.KeyField := 'ID'; DBRead.ParentField := 'PARENT';
        with DBRead.Columns.Add do begin FieldName := 'LABEL'; Width := 640; end;
        DBRead.DataSource := F.Source;
        DBRead.Parent := F.Form; DBRead.SetBounds(0,0,640,320); DBRead.ThemeMode := dtmLight;
        Bitmap.SetSize(640,320); DBRead.PaintTo(Bitmap.Canvas.Handle,0,0);
        Require(HintAt(DBRead,Point(100,3)) = 'Root description','DB first row after DFM starts at border');
        Require(ColorToRGB(Bitmap.Canvas.Pixels[500,10]) <>
          ColorToRGB(TDACComponentColors.ToVclColor(TDACControlTokens.Light.InputDisabledBackground)),
          'DB first paint after DFM does not draw header background');
      finally DBRead.Free; end;
      Binary.Clear; Text.Clear;
      Binary.WriteComponent(Tree); Binary.Position := 0;
      ObjectBinaryToText(Binary,Text);
      Require(Pos('ShowHeader = False',Text.DataString) > 0,'False stored in Tree DFM');
      Binary.Position := 0;
      TreeRead := TDACTreeView(Binary.ReadComponent(nil));
      try
        Require(not TreeRead.ShowHeader and not TreeRead.HandleAllocated,'Tree false restored without Parent');
        TreeRead.Parent := F.Form; TreeRead.SetBounds(0,0,640,320); TreeRead.ThemeMode := dtmLight;
        TreeRead.PaintTo(Bitmap.Canvas.Handle,0,0);
        Require(HintAt(TreeRead,Point(100,3)) = 'Streamed root','Streamed item first row starts at border');
        Require(ColorToRGB(Bitmap.Canvas.Pixels[500,10]) <>
          ColorToRGB(TDACComponentColors.ToVclColor(TDACControlTokens.Light.InputDisabledBackground)),
          'Tree first paint after DFM does not draw header background');
      finally TreeRead.Free; end;
      Binary.Clear; Text.Clear;
      DB.ShowHeader := True; Binary.WriteComponent(DB); Binary.Position := 0;
      ObjectBinaryToText(Binary,Text);
      Require(Pos('ShowHeader',Text.DataString) = 0,'Default true omitted from DB DFM');
      Binary.Clear; Text.Clear;
      Tree.ShowHeader := True; Binary.WriteComponent(Tree); Binary.Position := 0;
      ObjectBinaryToText(Binary,Text);
      Require(Pos('ShowHeader',Text.DataString) = 0,'Default true omitted from Tree DFM');
    finally Bitmap.Free; Text.Free; Binary.Free; Tree.Free; DB.Free; end;
  end;
end;

procedure TestDesigner;
var DB: TDBAccess; Tree: TTreeAccess;
begin
  DB := TDBAccess.Create(nil); Tree := TTreeAccess.Create(nil);
  try
    DB.DesignMode; Tree.DesignMode;
    DB.ShowHeader := False; Tree.ShowHeader := False;
    DB.Width := 80; DB.Height := 18; Tree.Width := 80; Tree.Height := 18;
    Require(not DB.HandleAllocated and not Tree.HandleAllocated,
      'Designer setter and resize remain safe without Parent');
    DB.ShowHeader := True; Tree.ShowHeader := True;
    Require(not DB.HandleAllocated and not Tree.HandleAllocated,
      'Designer restores header without allocating handles');
  finally Tree.Free; DB.Free; end;
end;

procedure Run;
var F: TFixture; Painter: TDACTreePainter; DBPainter: TDACDBTreePainter;
begin
  Evidence := ExpandFileName(ParamStr(1));
  if ParamStr(1) = '' then Evidence := ExtractFilePath(ParamStr(0))+'Evidence';
  ForceDirectories(Evidence);
  Application.Initialize;
  TestDesigner;
  F := TFixture.Create;
  Painter := TDACTreePainter.Create; DBPainter := TDACDBTreePainter.Create;
  try
    TestStreaming(F); Writeln('PASS ShowHeader DFM, first paint and parentless lifecycle');
    TestGeometryAndPaint(Painter,F.Tree.Model,F.Tree.Columns,'tree');
    TestGeometryAndPaint(DBPainter,F.DB.Model,F.DB.Columns,'dbtree');
    Writeln('PASS ShowHeader geometry/scroll/paint 96/144/192 light/dark and tiny controls');
    F.Form.Show;
    Application.ProcessMessages;
    TestInteraction(F);
    Writeln('PASS ShowHeader interaction/hints/state/counters and handle recreation');
  finally DBPainter.Free; Painter.Free; F.Free; end;
  Writeln('RESULT header_assertions=',Assertions,' failures=0');
  Writeln('Evidence: ',Evidence,' (offscreen; native physical testing is separate)');
end;

begin
  try Run;
  except on E: Exception do begin Writeln('FAIL ',E.ClassName,': ',E.Message); ExitCode := 1; end; end;
end.
