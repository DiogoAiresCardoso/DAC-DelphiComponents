program DACTreeViewPhysical;

{$APPTYPE CONSOLE}
{$MINSTACKSIZE $00200000}
{$R '..\Build\TreeView\Resources\DACTreeViewDemo.res'}

uses
  System.SysUtils, System.Variants, System.Types, System.Math,
  Winapi.Windows, Vcl.Forms, Vcl.Graphics, Vcl.Imaging.pngimage,
  MidasLib,
  DAC.Components.Controls.TreeView,
  DAC.Components.Controls.TreeView.Painter,
  DAC.Components.Controls.TreeView.Types,
  TreeView.Demo.Main,
  Demo.Principal in '..\demo\Demo.Principal.pas';

type
  TPhysicalTreeAccess = class(TDACTreeView)
  public
    function RenderDpi: Integer;
  end;

const MouseEventVirtualDesk = $4000;

function NativePrintWindow(Window: HWND; DC: HDC; Flags: UINT): BOOL; stdcall;
  external 'user32.dll' name 'PrintWindow';
procedure NativeSwitchToThisWindow(Window: HWND; AltTab: BOOL); stdcall;
  external 'user32.dll' name 'SwitchToThisWindow';

var Checks: Integer;

function TPhysicalTreeAccess.RenderDpi: Integer;
begin Result := GetParentCurrentDpi; end;

procedure Require(Condition: Boolean; const MessageText: string);
begin
  Inc(Checks);
  if not Condition then raise Exception.Create(MessageText);
end;

procedure Trace(const MessageText: string);
begin Writeln(MessageText); Flush(Output); end;

procedure Pump(Milliseconds: Cardinal = 100);
var Started: Cardinal;
begin
  Started := GetTickCount;
  repeat Application.ProcessMessages; Sleep(1);
  until GetTickCount - Started >= Milliseconds;
end;

procedure RequireOwnedForeground;
begin
  Require((Form1 <> nil) and Form1.HandleAllocated,
    'Owned application window is unavailable');
  Require(GetForegroundWindow = Form1.Handle,
    Format('Physical input refused: foreground=%s differs from owned=%s',
      [IntToHex(GetForegroundWindow, 8), IntToHex(Form1.Handle, 8)]));
end;

procedure Submit(var Inputs: array of TInput);
var Sent, ErrorCode: Cardinal;
begin
  { This self-test never injects into another application's window. }
  RequireOwnedForeground;
  SetLastError(0);
  Sent := Winapi.Windows.SendInput(Length(Inputs), Inputs[0], SizeOf(TInput));
  ErrorCode := GetLastError;
  Require(Sent = Cardinal(Length(Inputs)), Format(
    'SendInput sent %d/%d events; Win32 error=%d. Input may be blocked by UIPI.',
    [Sent, Length(Inputs), ErrorCode]));
  Pump;
end;

procedure KeyboardInput(var Input: TInput; Key: Word; KeyUp: Boolean);
begin
  FillChar(Input, SizeOf(Input), 0);
  Input.Itype := INPUT_KEYBOARD;
  Input.ki.wVk := Key;
  Input.ki.wScan := MapVirtualKey(Key, MAPVK_VK_TO_VSC);
  if Key in [VK_LEFT, VK_RIGHT, VK_UP, VK_DOWN, VK_HOME, VK_END,
    VK_PRIOR, VK_NEXT, VK_INSERT, VK_DELETE] then Input.ki.dwFlags := KEYEVENTF_EXTENDEDKEY;
  if KeyUp then Input.ki.dwFlags := Input.ki.dwFlags or KEYEVENTF_KEYUP;
end;

procedure PhysicalKey(Key: Word; Shift: Boolean = False);
var Inputs: array[0..3] of TInput; Plain: array[0..1] of TInput;
begin
  if Shift then
  begin
    KeyboardInput(Inputs[0], VK_SHIFT, False);
    KeyboardInput(Inputs[1], Key, False);
    KeyboardInput(Inputs[2], Key, True);
    KeyboardInput(Inputs[3], VK_SHIFT, True);
    Submit(Inputs);
  end
  else
  begin
    KeyboardInput(Plain[0], Key, False);
    KeyboardInput(Plain[1], Key, True);
    Submit(Plain);
  end;
end;

procedure FocusTree(Tree: TDACTreeView);
begin
  RequireOwnedForeground;
  Tree.SetFocus; Pump;
  Require(GetFocus = Tree.Handle, 'Tree did not receive real Windows keyboard focus');
end;

procedure PhysicalCheckboxClick(Tree: TDACTreeView; const Key: Variant);
var Painter: TDACTreePainter; Layout: TDACTreeLayout; Hit: TDACTreeHit;
  Dpi, X, Y, NodeIndex: Integer; P: TPoint;
  Inputs: array[0..2] of TInput; Found: Boolean; Target: HWND; TargetProcess: Cardinal;
begin
  Tree.SelectedKey := Key; Pump;
  Dpi := TPhysicalTreeAccess(Tree).RenderDpi;
  Painter := TDACTreePainter.Create;
  try
    Painter.ShowCheckBoxes := True;
    Painter.ShowHeader := Tree.ShowHeader;
    Layout := Painter.Layout(Tree.ClientWidth, Tree.ClientHeight, Dpi,
      Tree.Model, Tree.Columns, 0, 0);
    NodeIndex := Tree.Model.Find(Key).Index;
    Y := Layout.ContentRect.Top + Tree.Model.Find(Key).VisibleIndex *
      Painter.RowHeight(Dpi) + Painter.RowHeight(Dpi) div 2;
    Found := False;
    for X := 0 to Tree.ClientWidth - 1 do
    begin
      Hit := Painter.HitTest(X, Y, Tree.ClientWidth, Tree.ClientHeight, Dpi,
        Tree.Model, Tree.Columns, 0, 0);
      if (Hit.Kind = thCheck) and (Hit.NodeIndex = NodeIndex) then
      begin
        P := Tree.ClientToScreen(Point((Hit.Bounds.Left + Hit.Bounds.Right) div 2,
          (Hit.Bounds.Top + Hit.Bounds.Bottom) div 2));
        Found := True; Break;
      end;
    end;
    Require(Found, 'No visible checkbox was found in the owned tree viewport');
    Target := WindowFromPoint(P);
    TargetProcess := 0; GetWindowThreadProcessId(Target, TargetProcess);
    Require((TargetProcess = GetCurrentProcessId) and
      ((Target = Tree.Handle) or IsChild(Tree.Handle, Target)),
      Format('Physical mouse refused: target=%s tree=%s targetpid=%d ownpid=%d point=%d,%d dpi=%d',
        [IntToHex(Target,8), IntToHex(Tree.Handle,8), TargetProcess,
         GetCurrentProcessId, P.X, P.Y, Dpi]));
    FillChar(Inputs, SizeOf(Inputs), 0);
    Inputs[0].Itype := INPUT_MOUSE;
    Inputs[0].mi.dx := MulDiv(P.X - GetSystemMetrics(SM_XVIRTUALSCREEN),
      65535, Max(1, GetSystemMetrics(SM_CXVIRTUALSCREEN) - 1));
    Inputs[0].mi.dy := MulDiv(P.Y - GetSystemMetrics(SM_YVIRTUALSCREEN),
      65535, Max(1, GetSystemMetrics(SM_CYVIRTUALSCREEN) - 1));
    Inputs[0].mi.dwFlags := MOUSEEVENTF_MOVE or MOUSEEVENTF_ABSOLUTE or MouseEventVirtualDesk;
    Inputs[1].Itype := INPUT_MOUSE; Inputs[1].mi.dwFlags := MOUSEEVENTF_LEFTDOWN;
    Inputs[2].Itype := INPUT_MOUSE; Inputs[2].mi.dwFlags := MOUSEEVENTF_LEFTUP;
    Submit(Inputs);
  finally Painter.Free; end;
end;

procedure CaptureOwnedWindow(const FileName: string);
var Bitmap: TBitmap; PNG: TPngImage; Bounds: TRect;
  SourceDC: HDC; Captured: Boolean;
  function HasWindowContent: Boolean;
  var I, Different: Integer; C: TColor;
  begin
    GdiFlush;
    Different := 0; C := Bitmap.Canvas.Pixels[0, 0];
    for I := 1 to 20 do
      if Bitmap.Canvas.Pixels[MulDiv(I, Bitmap.Width - 1, 21),
        MulDiv(I, Bitmap.Height - 1, 21)] <> C then Inc(Different);
    Result := Different > 3;
  end;
begin
  RequireOwnedForeground;
  Pump;
  Require(GetWindowRect(Form1.Handle, Bounds), 'Cannot measure the owned application window');
  Bitmap := TBitmap.Create; PNG := TPngImage.Create;
  try
    Bitmap.PixelFormat := pf24bit;
    Bitmap.SetSize(Bounds.Width, Bounds.Height);
    Captured := NativePrintWindow(Form1.Handle, Bitmap.Canvas.Handle, 0);
    if Captured and HasWindowContent then Trace('CAPTURE method=PrintWindow')
    else
    begin
      { Copy the visible owned HWND surface, never a whole-desktop DC. }
      RequireOwnedForeground;
      SourceDC := GetWindowDC(Form1.Handle);
      Require(SourceDC <> 0, 'Could not read the owned window DC');
      try Captured := BitBlt(Bitmap.Canvas.Handle, 0, 0, Bitmap.Width,
        Bitmap.Height, SourceDC, 0, 0, SRCCOPY);
      finally ReleaseDC(Form1.Handle, SourceDC); end;
      if Captured then Trace('CAPTURE method=owned-window-DC');
    end;
    Require(Captured, 'Both PrintWindow and the owned window DC capture failed');
    if not HasWindowContent then
    begin
      PNG.Assign(Bitmap); PNG.SaveToFile(FileName + '.rejected.png');
      Require(False, 'Captured application image is empty or uniform; rejected diagnostic image saved');
    end;
    PNG.Assign(Bitmap); PNG.SaveToFile(FileName);
  finally PNG.Free; Bitmap.Free; end;
end;

procedure Run;
var Tree: TDACTreeView; Source: TTreeExampleObject; OutputDir, Status: string; Mode: Integer;
begin
  OutputDir := ParamStr(1);
  if OutputDir = '' then OutputDir := IncludeTrailingPathDelimiter(ExtractFilePath(ParamStr(0))) + 'Evidence';
  ForceDirectories(OutputDir);
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TForm1, Form1);
  try
    Form1.Show; Form1.GalleryTabs.ActivePage := Form1.tsTreeView;
    SetWindowPos(Form1.Handle, HWND_TOPMOST, 0, 0, 0, 0,
      SWP_NOMOVE or SWP_NOSIZE or SWP_SHOWWINDOW);
    Form1.BringToFront; SetForegroundWindow(Form1.Handle);
    NativeSwitchToThisWindow(Form1.Handle, False); Pump(250);
    RequireOwnedForeground;
    Tree := Form1.TreeDemo.Tree;
    Require(Tree.IsDataValid, 'Official TreeView example has no valid catalogue');
    for Mode := 0 to 1 do
    begin
    Form1.TreeDemo.ShowHeaderBox.Checked := Mode = 0;
    Tree.ShowHeader := Mode = 0;
    Tree.ExpandAll; Tree.SelectedKey := '011';
    Tree.TrySetChecked('011', False);
    FocusTree(Tree);
    Source := Tree.SelectedObject as TTreeExampleObject;
    Require(not Source.Checked, 'Physical fixture must start unchecked');
    PhysicalKey(VK_SPACE);
    Require(Tree.SelectedItem.Checked and Source.Checked,
      'Physical Space did not mark exactly once or did not reach consumer object');
    PhysicalKey(VK_SPACE);
    Require(not Tree.SelectedItem.Checked and not Source.Checked,
      'Second physical Space did not unmark exactly once');
    Trace('PASS physical Space and consumer writeback');
    PhysicalKey(VK_RETURN);
    Status := StringReplace(Form1.TreeDemo.Status.Caption, ' ', '', [rfReplaceAll]);
    Require(Pos(Format('Ativacoes:%d|',[Mode+1]), Status) > 0,
      'Physical Enter did not produce exactly one activation: ' + Status);
    Trace('PASS physical Enter single activation');
    PhysicalKey(VK_UP); Require(Tree.SelectedKey = '010', 'Physical Up did not navigate to parent row');
    PhysicalKey(VK_LEFT); Require(not Tree.Model.Find('010').Expanded, 'Physical Left did not collapse branch');
    PhysicalKey(VK_RIGHT); Require(Tree.Model.Find('010').Expanded, 'Physical Right did not expand branch');
    PhysicalKey(VK_DOWN); Require(Tree.SelectedKey = '011', 'Physical Down did not enter child');
    PhysicalKey(VK_LEFT); Require(Tree.SelectedKey = '010', 'Physical Left on leaf did not select parent');
    PhysicalKey(VK_DOWN); Require(Tree.SelectedKey = '011', 'Physical Down did not return to leaf');
    Trace('PASS physical arrows and expansion');
    PhysicalKey(VK_TAB);
    Require((GetFocus <> Tree.Handle) and IsChild(Form1.Handle, GetFocus),
      'Physical Tab did not leave tree for another owned control');
    FocusTree(Tree); PhysicalKey(VK_TAB, True);
    Require((GetFocus <> Tree.Handle) and IsChild(Form1.Handle, GetFocus),
      'Physical Shift+Tab did not leave tree for another owned control');
    Trace('PASS physical Tab/Shift+Tab and real focus');
    try PhysicalCheckboxClick(Tree, '011');
    except on E: Exception do
      begin
        Trace('MOUSE_FAILURE ' + E.Message);
        try CaptureOwnedWindow(IncludeTrailingPathDelimiter(OutputDir) + 'official-tree.png');
        except on CaptureError: Exception do Trace('CAPTURE_FAILURE ' + CaptureError.Message); end;
        raise;
      end;
    end;
    Require(Tree.Model.Find('011').Checked and Source.Checked,
      'Physical mouse checkbox did not update tree and original object');
    Trace('PASS physical mouse checkbox');
    CaptureOwnedWindow(IncludeTrailingPathDelimiter(OutputDir) +
      'official-tree-header-' + LowerCase(BoolToStr(Tree.ShowHeader,True)) + '.png');
    Trace('PASS physical ShowHeader=' + BoolToStr(Tree.ShowHeader,True));
    end;
    CaptureOwnedWindow(IncludeTrailingPathDelimiter(OutputDir) + 'official-tree.png');
    Trace('SCREENSHOT ' + IncludeTrailingPathDelimiter(OutputDir) + 'official-tree.png');
    Trace(Format('RESULT physical_checks=%d failures=0 system_dpi=%d render_dpi=%d',
      [Checks, Screen.PixelsPerInch, TPhysicalTreeAccess(Tree).RenderDpi]));
  finally Form1.Free; Form1 := nil; end;
end;

begin
  try Run;
  except on E: Exception do
    begin Trace('FAIL ' + E.ClassName + ': ' + E.Message); ExitCode := 1; end;
  end;
end.
