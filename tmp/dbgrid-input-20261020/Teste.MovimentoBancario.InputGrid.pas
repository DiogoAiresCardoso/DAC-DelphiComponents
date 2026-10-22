unit Teste.MovimentoBancario.InputGrid;
interface
uses DUnitX.TestFramework;
type
  [TestFixture]
  TMovimentoBancarioInputGridTests = class
  public
    [TestCase('Prontos','0')]
    [TestCase('Conciliar','1')]
    [TestCase('Importados','2')]
    procedure HitTestFocoCliqueEScrollNaHierarquiaReal(const Page: Integer);
  end;
implementation
uses System.Classes, System.SysUtils, System.Types, System.IOUtils,
  System.RegularExpressions, Winapi.Windows, Winapi.Messages, Vcl.Forms,
  Vcl.Controls, Vcl.ComCtrls, Data.DB, Datasnap.DBClient,
  TestSupport.DACGridHostForm, DAC.Components.Controls.Tabs,
  DAC.Components.Controls.DBGrid;

procedure TMovimentoBancarioInputGridTests.HitTestFocoCliqueEScrollNaHierarquiaReal(const Page: Integer);
var F: TDACGridHostForm; Tabs: TDACTabs; G: TDACDBGrid; D: TClientDataSet;
  S: TDataSource; Input: TStringStream; Binary: TMemoryStream;
  Text, Block, Key: string; M: TMatch; I, J, FirstLeft: Integer;
  P, Local: TPoint; Hit: HWND; Started: Cardinal;
  procedure Pump;
  var N: Integer;
  begin for N := 1 to 4 do Application.ProcessMessages; end;
begin
  Application.Initialize;
  if GetClass('TDACDBGrid') = nil then RegisterClass(TDACDBGrid);
  if GetClass('TDACTabs') = nil then RegisterClass(TDACTabs);
  if GetClass('TTabSheet') = nil then RegisterClass(TTabSheet);
  F := TDACGridHostForm.CreateNew(nil);
  Input := nil; Binary := nil;
  try
    Text := TFile.ReadAllText(TPath.GetFullPath(ExtractFilePath(ParamStr(0)) +
      '..\source\view\View.MovimentoBancario.dfm'), TEncoding.GetEncoding(1252));
    M := TRegEx.Match(Text, '(?ms)^    object DACTabs1: TDACTabs\r?\n.*?^    end\r?$');
    Assert.IsTrue(M.Success);
    Block := TRegEx.Replace(M.Value, '(?m)^\s*DataSource = [^\r\n]+\r?\n', '');
    Block := 'object Host: TDACGridHostForm'#13#10 +
      'Caption = ''QA input TDACDBGrid'''#13#10 +
      'Width = 1000'#13#10'Height = 600'#13#10 + Block + #13#10'end';
    Input := TStringStream.Create(Block, TEncoding.UTF8); Binary := TMemoryStream.Create;
    ObjectTextToBinary(Input, Binary); Binary.Position := 0; Binary.ReadComponent(F);
    Tabs := TDACTabs(F.FindComponent('DACTabs1'));
    Assert.IsNotNull(Tabs);
    Assert.AreEqual(3, Tabs.PageCount);
    for J := 0 to 2 do
    begin
      G := TDACDBGrid(Tabs.Pages[J].Controls[0]);
      G.Layout.Enabled := False;
      D := TClientDataSet.Create(F);
      D.FieldDefs.Add('COD_EMP', ftString, 10); D.FieldDefs.Add('MOV_COD', ftString, 10);
      D.FieldDefs.Add('MOVIMENTOFECHADO', ftString, 30);
      D.FieldDefs.Add('HIST_DESC', ftString, 100); D.CreateDataSet;
      for I := 1 to 80 do D.AppendRecord(['0000000007', Format('%.10d', [I]), 'ABERTO', 'REGISTRO ' + IntToStr(I)]);
      D.First; S := TDataSource.Create(F); S.DataSet := D; G.DataSource := S;
    end;
    F.SetBounds(30, 30, 1000, 600); F.Show; Tabs.ActiveIndex := Page; Pump;
    G := TDACDBGrid(Tabs.Pages[Page].Controls[0]); D := TClientDataSet(G.DataSource.DataSet);
    if GetEnvironmentVariable('DAC_GRID_NATIVE_QA') = '1' then
    begin
      Started := GetTickCount;
      while GetTickCount - Started < 60000 do
      begin
        F.Caption := 'QA input TDACDBGrid - registro ' + D.FieldByName('MOV_COD').AsString +
          ' foco=' + BoolToStr(G.Focused, True);
        Pump; Sleep(10);
      end;
      Exit;
    end;
    // Discover the native target first. Sending messages directly to G would
    // bypass a disabled HWND or a sibling intercepting real mouse input.
    Local := Point(100, 94); P := G.ClientToScreen(Local);
    Hit := WindowFromPoint(P);
    Assert.IsTrue(Hit = G.Handle, Format('Hit alvo=%x grid=%x enabled=%s visible=%s canfocus=%s',
      [Hit, G.Handle, BoolToStr(IsWindowEnabled(G.Handle), True),
       BoolToStr(IsWindowVisible(G.Handle), True), BoolToStr(G.CanFocus, True)]));
    Assert.IsTrue(IsWindowEnabled(G.Handle), 'HWND nativo desabilitado.');
    SendMessage(Hit, WM_LBUTTONDOWN, MK_LBUTTON, MakeLParam(Local.X, Local.Y));
    SendMessage(Hit, WM_LBUTTONUP, 0, MakeLParam(Local.X, Local.Y)); Pump;
    Assert.IsTrue(G.Focused, 'Clique nao transferiu foco para a grid.');
    Assert.AreEqual('0000000002', D.FieldByName('MOV_COD').AsString);
    Key := D.FieldByName('MOV_COD').AsString;
    SendMessage(G.Handle, WM_VSCROLL, SB_LINEDOWN, 0); Pump;
    Assert.AreNotEqual(Key, D.FieldByName('MOV_COD').AsString, 'Scroll vertical nao navegou.');
    FirstLeft := GetScrollPos(G.Handle, SB_HORZ);
    SendMessage(G.Handle, WM_HSCROLL, SB_LINERIGHT, 0); Pump;
    Assert.IsTrue(GetScrollPos(G.Handle, SB_HORZ) > FirstLeft, 'Scroll horizontal nao moveu.');
  finally Binary.Free; Input.Free; F.Free; end;
end;
initialization
  TDUnitX.RegisterTestFixture(TMovimentoBancarioInputGridTests);
end.
