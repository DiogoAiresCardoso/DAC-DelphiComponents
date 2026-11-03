program DACTreeViewTests;

{$APPTYPE CONSOLE}

uses
  System.Classes, System.SysUtils, System.Variants, System.Diagnostics,
  System.Generics.Collections, System.Types,
  Winapi.Windows, Winapi.Messages, Vcl.Forms, Vcl.Controls, Vcl.Graphics,
  DAC.Components.Controls.TreeView,
  DAC.Components.Controls.TreeView.Types,
  DAC.Components.Controls.TreeView.Item,
  DAC.Components.Controls.TreeView.Items,
  DAC.Components.Controls.TreeView.Roots,
  DAC.Components.Controls.TreeView.Painter,
  DAC.Components.DesignSystem.ComponentStyle,
  DAC.Components.DesignSystem.Theme;

type
  TTestProc = procedure;
  TDomainItem = class
  public
    class var Destroyed: Integer;
  public
    Key, ParentKey: Variant;
    Text: string;
    Details: TArray<string>;
    Checked, Checkable, FailMapping: Boolean;
    constructor Create(const AKey, AParent: Variant; const AText: string;
      ACheckable: Boolean = True);
    destructor Destroy; override;
  end;
  TTestTree = class(TDACTreeView)
  public
    procedure SendKey(AKey: Word);
    procedure SendChar(AChar: Char);
  end;
  TFixture = class
  public
    Tree: TTestTree;
    Objects, Replacement: TObjectList<TDomainItem>;
    Veto, WriteBack: Boolean;
    BeforeMode, AfterMode, CurrentMode, ActivationMode: Integer;
    Errors, BeforeCalls, Changed, CurrentCalls, Activations: Integer;
    ReenterAccepted: Boolean;
    LastKey: Variant;
    LastObject: TObject;
    constructor Create;
    destructor Destroy; override;
    function Add(const Key, ParentKey: Variant; const Text: string;
      Checkable: Boolean = True): TDomainItem;
    function Load(Preserve: Boolean = True): Boolean;
    procedure BeforeCheck(Sender: TObject; const Key: Variant;
      DataObject: TObject; Checked: Boolean; var Allow: Boolean);
    procedure CheckChanged(Sender: TObject; const Key: Variant;
      DataObject: TObject; Checked: Boolean; Reason: TDACTreeChangeReason);
    procedure Current(Sender: TObject; const OldKey, NewKey: Variant;
      DataObject: TObject; Reason: TDACTreeChangeReason);
    procedure Activated(Sender: TObject; const Key: Variant; DataObject: TObject);
    procedure Error(Sender: TObject; const Key: Variant; const MessageText: string);
  end;
  TStreamForm = class(TForm)
  public
    Calls: Integer;
  published
    procedure BeforeCheck(Sender: TObject; const Key: Variant;
      DataObject: TObject; Checked: Boolean; var Allow: Boolean);
  end;

var Assertions, Failures, MappingCalls: Integer;

procedure Require(Condition: Boolean; const MessageText: string);
begin
  Inc(Assertions);
  if not Condition then raise Exception.Create(MessageText);
end;

procedure RunTest(const Name: string; Test: TTestProc);
begin
  try
    Test;
    Writeln('PASS ', Name);
  except on E: Exception do
    begin Inc(Failures); Writeln('FAIL ', Name, ': ', E.ClassName, ': ', E.Message); end;
  end;
end;

constructor TDomainItem.Create(const AKey, AParent: Variant; const AText: string;
  ACheckable: Boolean);
begin
  inherited Create;
  Key := AKey; ParentKey := AParent; Text := AText; Checkable := ACheckable;
end;

destructor TDomainItem.Destroy;
begin Inc(Destroyed); inherited; end;

function MapDomain(Item: TDomainItem): TDACTreeItemData;
begin
  Inc(MappingCalls);
  if Item.FailMapping then raise EInvalidOperation.Create('Expected mapper rejection');
  Result.Key := Item.Key;
  Result.ParentKey := Item.ParentKey;
  Result.Text := Item.Text;
  Result.SubItems := Copy(Item.Details);
  Result.Checked := Item.Checked;
  Result.Checkable := Item.Checkable;
end;

procedure TTestTree.SendKey(AKey: Word);
begin KeyDown(AKey, []); end;
procedure TTestTree.SendChar(AChar: Char);
begin KeyPress(AChar); end;

constructor TFixture.Create;
begin
  inherited;
  Objects := TObjectList<TDomainItem>.Create(True);
  Replacement := TObjectList<TDomainItem>.Create(True);
  Tree := TTestTree.Create(nil);
  Tree.BeginUpdate;
  try
    Tree.Columns.Clear;
    Tree.Columns.Add.Caption := 'Text';
    Tree.Columns.Add.Caption := 'Detail';
    Tree.ShowCheckBoxes := True;
  finally Tree.EndUpdate; end;
  Tree.OnBeforeCheckChange := BeforeCheck;
  Tree.OnCheckChanged := CheckChanged;
  Tree.OnCurrentChanged := Current;
  Tree.OnActivateRecord := Activated;
  Tree.OnDataError := Error;
  LastKey := Null;
end;

destructor TFixture.Destroy;
begin
  Tree.OnBeforeCheckChange := nil;
  Tree.OnCheckChanged := nil;
  Tree.OnCurrentChanged := nil;
  Tree.OnActivateRecord := nil;
  Tree.Items.Clear;
  Tree.Free;
  Objects.Free;
  Replacement.Free;
  inherited;
end;

function TFixture.Add(const Key, ParentKey: Variant; const Text: string;
  Checkable: Boolean): TDomainItem;
begin
  Result := TDomainItem.Create(Key, ParentKey, Text, Checkable);
  Objects.Add(Result);
end;

function TFixture.Load(Preserve: Boolean): Boolean;
begin
  Result := Tree.LoadObjects<TDomainItem>(Objects,
    function(Item: TDomainItem): TDACTreeItemData
    begin Result := MapDomain(Item); end, Preserve);
end;

procedure TFixture.BeforeCheck(Sender: TObject; const Key: Variant;
  DataObject: TObject; Checked: Boolean; var Allow: Boolean);
var Mode: Integer;
begin
  Inc(BeforeCalls); LastKey := Key; LastObject := DataObject;
  Allow := not Veto;
  Mode := BeforeMode; BeforeMode := 0;
  case Mode of
    1: Tree.Refresh;
    2: Tree.Items.Delete(Tree.SelectedItem);
    3: Tree.LoadObjects<TDomainItem>(Replacement,
         function(Item: TDomainItem): TDACTreeItemData
         begin Result := MapDomain(Item); end);
    4: ReenterAccepted := Tree.TrySetChecked(Key, Checked);
    5: Tree.ReadOnly := True;
  end;
  if Mode in [1, 2, 3] then
    Require(Key = 'A', 'before-check key changed or became invalid after reentry');
end;

procedure TFixture.CheckChanged(Sender: TObject; const Key: Variant;
  DataObject: TObject; Checked: Boolean; Reason: TDACTreeChangeReason);
var Mode: Integer;
begin
  Inc(Changed); LastKey := Key; LastObject := DataObject;
  if WriteBack and (DataObject is TDomainItem) and
    (Reason in [tcrUser, tcrProgrammatic]) then TDomainItem(DataObject).Checked := Checked;
  Mode := AfterMode; AfterMode := 0;
  case Mode of
    1: Tree.Refresh;
    2: Tree.Items.Clear;
  end;
  if Mode = 2 then Require(Key = 'A', 'changed-event key was not stable across Clear');
end;

procedure TFixture.Current(Sender: TObject; const OldKey, NewKey: Variant;
  DataObject: TObject; Reason: TDACTreeChangeReason);
var Mode: Integer;
begin
  Inc(CurrentCalls); LastKey := NewKey; LastObject := DataObject;
  Mode := CurrentMode; CurrentMode := 0;
  case Mode of
    1: Tree.Items.Clear;
    2: Tree.LoadObjects<TDomainItem>(Replacement,
         function(Item: TDomainItem): TDACTreeItemData
         begin Result := MapDomain(Item); end);
  end;
  if Mode = 1 then Require(NewKey = 'A', 'current-event key was not a stable snapshot');
end;

procedure TFixture.Activated(Sender: TObject; const Key: Variant; DataObject: TObject);
var Mode: Integer;
begin
  Inc(Activations); LastKey := Key; LastObject := DataObject;
  Mode := ActivationMode; ActivationMode := 0;
  if Mode = 1 then Tree.Items.Clear;
  if Mode = 1 then Require(Key = 'A', 'activation key was not stable across Clear');
end;

procedure TFixture.Error(Sender: TObject; const Key: Variant; const MessageText: string);
begin Inc(Errors); end;

procedure TStreamForm.BeforeCheck(Sender: TObject; const Key: Variant;
  DataObject: TObject; Checked: Boolean; var Allow: Boolean);
begin Inc(Calls); Allow := True; end;

procedure TestManualItems;
var F: TFixture; Root, Child, Grandchild, Sibling, RootSibling: TDACTreeItem;
  RootKey, ChildKey: Variant;
  Loads: Integer;
begin
  F := TFixture.Create;
  try
    Require(not F.Tree.HandleAllocated, 'constructing an unparented tree created HWND');
    Loads := F.Tree.LoadCount;
    F.Tree.BeginUpdate;
    try
      Root := F.Tree.Items.Add(nil, 'Root');
      Child := F.Tree.Items.AddChild(Root, 'Child');
      Grandchild := F.Tree.Items.AddChild(Child, 'Grandchild');
      Sibling := F.Tree.Items.Add(Child, 'Child sibling');
      RootSibling := F.Tree.Items.Add(Root, 'Root sibling');
      Child.SubItems.Add('detail');
      F.Tree.ExpandAll;
    finally F.Tree.EndUpdate; end;
    Require(F.Tree.IsDataValid, 'manual tree rejected: ' + F.Tree.LastError);
    Require(F.Tree.LoadCount = Loads + 1, 'manual batch rebuilt the catalogue for individual items');
    Require(F.Tree.Items.Count = 5, 'manual item count');
    Require(F.Tree.Model.Visible.Count = 5, 'ExpandAll inside an unfinished manual batch failed');
    Require(Root.Parent = nil, 'root has a parent');
    Require(Child.Parent = Root, 'AddChild did not assign parent');
    Require(Grandchild.Parent = Child, 'grandchild parent');
    Require(Sibling.Parent = Root, 'Add(node) should append a sibling, not a child');
    Require(RootSibling.Parent = nil, 'Add(root) should create another root');
    Require(not VarIsEmpty(Root.Key) and not VarIsNull(Root.Key), 'automatic key missing');
    Require(Root.Key <> Child.Key, 'automatic item keys collide');
    RootKey := Root.Key; ChildKey := Child.Key;
    Require(F.Tree.Model.Find(ChildKey).Cells[1] = 'detail', 'SubItems not mapped to columns');
    Require(F.Tree.Model.Find(Grandchild.Key).Depth = 2, 'manual hierarchy depth');
    F.Tree.SelectedKey := ChildKey;
    Require(F.Tree.SelectedItem = Child, 'SelectedItem is not the actual manual item');
    F.Tree.Items.Delete(Child);
    Require(F.Tree.Items.Count = 3, 'Delete must remove the full subtree');
    Require(F.Tree.Model.Find(ChildKey) = nil, 'deleted key remains in catalogue');
    Require(F.Tree.Model.Find(RootKey) <> nil, 'delete damaged parent');
    F.Tree.Items.Clear;
    Require(F.Tree.Items.Count = 0, 'Clear left items');
    Require(F.Tree.Model.Nodes.Count = 0, 'Clear left cached nodes');
    Require(VarIsNull(F.Tree.SelectedKey) or VarIsEmpty(F.Tree.SelectedKey), 'Clear left selected key');
    Require(not F.Tree.HandleAllocated, 'manual configuration without Parent created HWND');
  finally F.Free; end;
end;

procedure TestObjectLoadingAndLifetime;
var F: TFixture; Root, Child: TDomainItem; DestroyedBefore: Integer;
begin
  DestroyedBefore := TDomainItem.Destroyed;
  F := TFixture.Create;
  try
    Child := F.Add('001-1', '001', 'Child first');
    SetLength(Child.Details, 1); Child.Details[0] := 'extra';
    Root := F.Add('001', Null, 'Root later', False);
    F.Add('002', '', 'Other root');
    MappingCalls := 0;
    Require(F.Load, 'shuffled object list rejected');
    Require(MappingCalls = F.Objects.Count, 'mapper should execute once per object');
    Require(F.Objects.OwnsObjects, 'component changed list ownership');
    Require(TDomainItem.Destroyed = DestroyedBefore, 'loading destroyed consumer objects');
    Require(F.Tree.Items.Count = 3, 'object list item count');
    Require(F.Tree.Model.Find('001-1').Depth = 1, 'child-before-parent not linked');
    Require(F.Tree.Model.Find('001-1').Cells[1] = 'extra', 'mapped details missing');
    F.Tree.SelectedKey := '001-1';
    Require(F.Tree.SelectedObject = Child, 'selected object is not the source instance');
    Require(F.Tree.SelectedItem.DataObject = Child, 'item lost source object');
    Require(F.LastObject = Child, 'current event did not expose source object');
    Require(not F.Tree.TrySetChecked('001', True), 'blocked root accepted check');
    Root.Text := 'Modified externally';
    Require(F.Tree.Model.Find('001').Cells[0] = 'Root later', 'view unexpectedly live-bound to consumer objects');
    Require(F.Load, 'explicit reload failed');
    Require(F.Tree.Model.Find('001').Cells[0] = 'Modified externally', 'explicit reload did not read source changes');
    F.Tree.Items.Clear;
    Require(TDomainItem.Destroyed = DestroyedBefore, 'Clear destroyed consumer objects');
  finally F.Free; end;
  Require(TDomainItem.Destroyed = DestroyedBefore + 3, 'consumer objects leaked or freed twice');
end;

procedure TestStateAndReplacement;
var F: TFixture; OldChild, NewChild: TDomainItem;
begin
  F := TFixture.Create;
  try
    F.Add('R', Null, 'Root', False);
    OldChild := F.Add('C', 'R', 'Child');
    F.Add('X', Null, 'Other');
    Require(F.Load, 'initial state fixture rejected');
    F.Tree.Expand('R');
    F.Tree.SelectedKey := 'C';
    Require(F.Tree.TrySetChecked('C', True), 'initial marking failed');
    F.Tree.SearchText := 'Other';
    Require(F.Tree.SelectedKey = 'C', 'search navigated away from hidden current item');
    Require(F.Tree.SelectedObject = OldChild, 'hidden current object changed');
    Require(Length(F.Tree.CheckedKeys) = 1, 'search lost hidden marking');
    F.Tree.SearchText := '';
    Require(F.Tree.Model.Find('R').Expanded, 'clearing search lost explicit expansion');
    Require(F.Load(True), 'preserving reload failed');
    Require(F.Tree.SelectedKey = 'C', 'preserving reload lost selection');
    Require(F.Tree.Model.Find('C').Checked, 'preserving reload ignored local marking');
    Require(not OldChild.Checked, 'tree wrote back to object without consumer event handler');
    Require(F.Load(False), 'reset reload failed');
    Require(not F.Tree.Model.Find('C').Checked, 'PreserveState=False did not apply mapper states');
    Require(not F.Tree.Model.Find('R').Expanded, 'PreserveState=False kept old expansion');
    NewChild := TDomainItem.Create('C', 'R', 'Replacement child');
    F.Replacement.Add(TDomainItem.Create('R', Null, 'Replacement root', False));
    F.Replacement.Add(NewChild);
    F.Tree.SelectedKey := 'C';
    Require(F.Tree.LoadObjects<TDomainItem>(F.Replacement,
      function(Item: TDomainItem): TDACTreeItemData
      begin Result := MapDomain(Item); end), 'replacement load failed');
    Require(F.Tree.SelectedObject = NewChild, 'same-key replacement retained old object reference');
    F.Objects.Clear;
    Require(F.Tree.SelectedObject = NewChild, 'freeing removed source objects damaged replacement');
    Require(F.Tree.Items.Count = 2, 'load merged instead of replacing catalogue');
  finally F.Free; end;
end;

procedure TestInvalidData;
var F: TFixture; Item: TDomainItem;
  procedure ExpectFailure(const Name: string);
  begin
    Require(not F.Load, Name + ' accepted');
    Require(not F.Tree.IsDataValid, Name + ' left a valid catalogue');
    Require(F.Tree.Model.Nodes.Count = 0, Name + ' left actionable cached nodes');
    Require(F.Errors > 0, Name + ' did not report a controlled error');
    Require(Length(F.Tree.CheckedKeys) = 0, Name + ' left stale marked keys');
    F.Tree.Items.Clear; F.Objects.Clear;
  end;
begin
  F := TFixture.Create;
  try
    F.Add('A', Null, 'First'); F.Add('A', Null, 'Duplicate'); ExpectFailure('duplicate');
    F.Add('A', 'missing', 'Orphan'); ExpectFailure('orphan');
    F.Add('A', 'A', 'Self'); ExpectFailure('self-parent');
    F.Add('A', 'B', 'Cycle A'); F.Add('B', 'A', 'Cycle B'); ExpectFailure('cycle');
    F.Add(Null, Null, 'Null identity'); ExpectFailure('null identity');
    F.Add('A', Null, 'Valid'); Require(F.Load, 'valid data rejected before mapper failure');
    Item := F.Add('B', Null, 'Mapping error'); Item.FailMapping := True;
    ExpectFailure('mapper exception');
    Require(F.Load, 'empty list should clear to a valid empty tree');
    Require(F.Tree.Items.Count = 0, 'empty load left items');
  finally F.Free; end;
end;

procedure TestTypedKeysAndRoots;
var F: TFixture;
begin
  F := TFixture.Create;
  try
    F.Add(1, Null, 'Integer'); F.Add('1', Null, 'Text'); F.Add('001', '', 'Leading zero');
    Require(F.Load, 'mixed typed keys rejected');
    Require(F.Tree.Model.Nodes.Count = 3, 'typed identities were merged');
    Require(F.Tree.Model.Find(1).Cells[0] = 'Integer', 'integer key lookup');
    Require(F.Tree.Model.Find('1').Cells[0] = 'Text', 'text key was coerced');
    Require(F.Tree.Model.Find('001').Cells[0] = 'Leading zero', 'leading zero key was normalized');
    F.Tree.Items.Clear; F.Objects.Clear;
    F.Add('R', 0, 'Explicit zero root');
    Require(not F.Load, 'zero silently treated as a root');
    F.Tree.RootValues.BeginUpdate;
    try
      with F.Tree.RootValues.Add do begin Kind := trkValue; Value := 0; end;
    finally F.Tree.RootValues.EndUpdate; end;
    Require(F.Load, 'explicit integer sentinel rejected');
    Require(F.Tree.Model.Find('R').Depth = 0, 'sentinel root linked to arbitrary parent');
    F.Tree.Items.Clear; F.Objects.Clear;
    F.Add(0, 0, 'Sentinel key also root'); F.Add(1, 0, 'Independent sentinel root');
    Require(F.Load, 'sentinel matching an existing key rejected');
    Require(F.Tree.Items.Find(0).Parent = nil, 'sentinel root has itself as Parent');
    Require(F.Tree.Items.Find(1).Parent = nil, 'sentinel root was attached to existing key');
    F.Tree.Items.Delete(F.Tree.Items.Find(0));
    Require(F.Tree.Items.Count = 1, 'deleting sentinel-key root removed unrelated root');
    Require(F.Tree.Model.Find(1) <> nil, 'independent root disappeared after deletion');
    Require(F.Objects.Count = 2, 'sentinel deletion changed consumer collection');
  finally F.Free; end;
end;

procedure TestMarkingAndKeyboard;
var F: TFixture; Item: TDomainItem; Changes: Integer;
begin
  F := TFixture.Create;
  try
    Item := F.Add('A', Null, 'Allowed'); F.Add('B', Null, 'Blocked', False);
    Require(F.Load, 'marking fixture rejected');
    F.Tree.SelectedKey := 'A';
    F.Veto := True;
    Require(not F.Tree.TrySetChecked('A', True), 'veto ignored');
    Require(not F.Tree.Model.Find('A').Checked, 'veto changed state');
    F.Veto := False; F.Tree.ReadOnly := True;
    Require(not F.Tree.TrySetChecked('A', True), 'readonly ignored');
    F.Tree.ReadOnly := False;
    Require(not F.Tree.TrySetChecked('B', True), 'blocked object checked');
    F.WriteBack := True;
    Changes := F.Changed;
    Require(F.Tree.TrySetChecked('A', True), 'allowed check failed');
    Require(F.Changed = Changes + 1, 'check should notify once');
    Require(F.LastObject = Item, 'check event lost source object');
    Require(Item.Checked, 'consumer event did not update object');
    Changes := F.Changed;
    Require(F.Tree.TrySetChecked('A', True), 'idempotent check returned failure');
    Require(F.Changed = Changes, 'idempotent check emitted duplicate event');
    F.Tree.SendKey(VK_SPACE); F.Tree.SendChar(' ');
    Require(not F.Tree.Model.Find('A').Checked, 'space did not toggle exactly once');
    Require(not Item.Checked, 'space did not notify consumer');
    F.Tree.SendKey(VK_RETURN); F.Tree.SendChar(#13);
    Require(F.Activations = 1, 'KeyDown/KeyPress emitted duplicate activation');
    Require(F.LastObject = Item, 'activation did not include original object');
    F.Tree.SendKey(VK_DOWN);
    Require(F.Tree.SelectedKey = 'B', 'arrow navigation did not move to visible row');
  finally F.Free; end;
end;

procedure TestReentrantEvents;
var F: TFixture; Mode: Integer;
begin
  for Mode := 1 to 5 do
  begin
    F := TFixture.Create;
    try
      F.Add('A', Null, 'Original'); Require(F.Load, 'reentrant initial load');
      F.Replacement.Add(TDomainItem.Create('Z', Null, 'Replacement'));
      F.Tree.SelectedKey := 'A'; F.BeforeMode := Mode;
      F.Tree.TrySetChecked('A', True);
      case Mode of
        1: Require(F.Tree.IsDataValid, 'refresh before check invalidated tree');
        2: Require(F.Tree.Items.Count = 0, 'delete inside before-check left a stale item');
        3: begin
             Require(F.Tree.Items.Count = 1, 'replacement during before-check corrupted count');
             Require(F.Tree.Model.Find('Z') <> nil, 'replacement during before-check was lost');
             Require(F.Tree.Model.Find('A') = nil, 'old item survived reentrant replacement');
           end;
        4: Require(not F.ReenterAccepted, 'recursive check request was accepted');
        5: Require(not F.Tree.Model.Find('A').Checked, 'readonly set by before-check ignored');
      end;
    finally F.Free; end;
  end;
  F := TFixture.Create;
  try
    F.Add('A', Null, 'Allowed'); Require(F.Load, 'after-event load');
    F.AfterMode := 2; F.Tree.TrySetChecked('A', True);
    Require(F.Tree.Items.Count = 0, 'clear inside changed-event left stale items');
    Require(F.Load, 'reload after reentrant clear');
    F.CurrentMode := 1; F.Tree.SelectedKey := 'A';
    Require(F.Tree.Items.Count = 0, 'clear inside current-event left stale items');
    Require(F.Load, 'reload before activation');
    F.Tree.SelectedKey := 'A'; F.ActivationMode := 1; F.Tree.SendKey(VK_RETURN);
    Require(F.Tree.Items.Count = 0, 'clear inside activation left stale items');
  finally F.Free; end;
end;

procedure TestDirectItemUpdatesAndFilteredNavigation;
var F: TFixture;
begin
  F := TFixture.Create;
  try
    F.Add('R', Null, 'Root', False);
    F.Add('A', 'R', 'Hidden child');
    F.Add('B', 'R', 'Matching child');
    Require(F.Load, 'filtered keyboard fixture rejected');
    F.Tree.ExpandAll; F.Tree.SelectedKey := 'R'; F.Tree.SearchText := 'Matching';
    F.Tree.SendKey(VK_RIGHT);
    Require(F.Tree.SelectedKey = 'B', 'right arrow selected an excluded first child');
    F.Tree.SendKey(VK_LEFT);
    Require(F.Tree.SelectedKey = 'R', 'left arrow did not select visible parent');
    F.Tree.SearchText := '';
    F.Tree.SelectedKey := 'A';
    F.AfterMode := 2;
    F.Tree.Items.Find('A').Checked := True;
    Require(F.Tree.Items.Count = 0, 'clear inside a direct item setter event left stale items');
    Require(F.Load, 'reload after direct item setter clear');
    F.Tree.Items.Find('A').ParentKey := 'missing';
    Require(not F.Tree.IsDataValid, 'invalid manual parent was accepted');
    Require(F.Tree.Model.Nodes.Count = 0, 'invalid manual edit left actionable presentation');
  finally F.Free; end;
end;

procedure TestStreaming;
var Source, Restored: TStreamForm; Tree, CopyTree: TDACTreeView;
  Stream: TMemoryStream; Root: TDACTreeItem; Domain: TDomainItem;
begin
  System.Classes.RegisterClass(TDACTreeView); System.Classes.RegisterClass(TStreamForm);
  Source := TStreamForm.CreateNew(nil);
  Restored := TStreamForm.CreateNew(nil);
  Stream := TMemoryStream.Create;
  Domain := TDomainItem.Create('object', Null, 'External object');
  try
    Tree := TDACTreeView.Create(Source); Tree.Name := 'DemoTree'; Tree.Parent := Source;
    Tree.ShowCheckBoxes := True;
    Tree.BeginUpdate;
    try
      Tree.Columns.Clear;
      with Tree.Columns.Add do begin Caption := 'Caption'; Width := 123; Hint := 'Cell hint'; TitleHint := 'Title hint'; end;
      Tree.Columns.Add.Caption := 'Details';
      Root := Tree.Items.Add(nil, 'Stream root'); Root.Key := 'R'; Root.DataObject := Domain;
      Root.SubItems.Add('Stream detail');
      Tree.Items.AddChild(Root, 'Stream child').Key := 'C';
      with Tree.RootValues.Add do begin Kind := trkValue; Value := 0; end;
      Tree.OnBeforeCheckChange := Source.BeforeCheck;
    finally Tree.EndUpdate; end;
    Stream.WriteComponent(Source); Stream.Position := 0; Stream.ReadComponent(Restored);
    CopyTree := Restored.FindComponent('DemoTree') as TDACTreeView;
    Require(CopyTree <> nil, 'tree missing after DFM roundtrip');
    Require(CopyTree.IsDataValid, 'streamed tree invalid: ' + CopyTree.LastError);
    Require(CopyTree.Items.Count = 2, 'streaming lost items');
    Require(CopyTree.Columns.Count = 2, 'streaming lost columns');
    Require(CopyTree.Columns[0].Width = 123, 'column width not streamed');
    Require(CopyTree.Columns[0].Hint = 'Cell hint', 'column hint not streamed');
    Require(CopyTree.Columns[0].TitleHint = 'Title hint', 'column title hint not streamed');
    Require(CopyTree.Model.Find('C').Depth = 1, 'streaming lost hierarchy');
    Require(CopyTree.Model.Find('R').Cells[1] = 'Stream detail', 'streaming lost SubItems');
    CopyTree.SelectedKey := 'R';
    Require(CopyTree.SelectedObject = nil, 'runtime object pointer was serialized');
    Require(CopyTree.TrySetChecked('R', True), 'streamed before-check handler failed');
    Require(Restored.Calls = 1, 'DFM event still targets original owner');
    Require(Source.Calls = 0, 'DFM event called original owner');
    Require(CopyTree.RootValues.Count = Tree.RootValues.Count, 'streaming lost root sentinels');
  finally
    Restored.Free; Source.Free; Stream.Free; Domain.Free;
  end;
end;

procedure TestPaintUsesSnapshot;
var F: TFixture; Form: TForm; Bitmap: TBitmap; Calls, Reads, I: Integer;
begin
  F := TFixture.Create; Form := TForm.CreateNew(nil); Bitmap := TBitmap.Create;
  try
    F.Add('A', Null, 'Snapshot text'); Require(F.Load, 'paint fixture rejected');
    F.Tree.Parent := Form; F.Tree.SetBounds(0, 0, 400, 250);
    Form.Show; Application.ProcessMessages;
    Bitmap.SetSize(400, 250); Calls := MappingCalls; Reads := F.Tree.DataReadCount;
    for I := 1 to 20 do F.Tree.PaintTo(Bitmap.Canvas.Handle, 0, 0);
    Require(MappingCalls = Calls, 'painting called object mapper');
    Require(F.Tree.DataReadCount = Reads, 'painting rebuilt item snapshots');
    Require(F.Tree.Model.Find('A').Cells[0] = 'Snapshot text', 'painting mutated catalogue');
    Form.Hide;
  finally Bitmap.Free; F.Free; Form.Free; end;
end;

procedure TestDefaultsAndDpi;
var Tree: TTestTree;
begin
  Tree := TTestTree.Create(nil);
  try
    Require(not Tree.ShowCheckBoxes, 'checkbox chrome should be optional and disabled by default');
    Require(not Tree.ParentFont, 'tree must own its DAC default font');
    Require(Tree.Font.PixelsPerInch = 96, 'default font is not authored at 96 DPI');
    Require(Tree.Font.Height = -12, 'default point font was pre-scaled at Screen.PPI');
    Tree.ScaleBy(144, 96);
    Require(Tree.Font.Height = -18, '144-DPI programmatic font scaling applied twice');
    Tree.ScaleBy(192, 144);
    Require(Tree.Font.Height = -24, '192-DPI programmatic font scaling applied twice');
    Require(not Tree.HandleAllocated, 'DPI/configuration before Parent created HWND');
  finally Tree.Free; end;
end;

procedure TestPlainPainterDpiAndOptionalChecks;
const Dpis: array[0..2] of Integer = (96, 144, 192);
var F: TFixture; Painter: TDACTreePainter; Bitmap: TBitmap;
  Dpi, X, Y: Integer; Hit: TDACTreeHit;
begin
  F := TFixture.Create; Painter := TDACTreePainter.Create; Bitmap := TBitmap.Create;
  try
    F.Add('A', Null, 'Plain object paint'); Require(F.Load, 'plain painter fixture rejected');
    for Dpi in Dpis do
    begin
      X := MulDiv(40, Dpi, 96); Y := MulDiv(50, Dpi, 96);
      Painter.ShowCheckBoxes := False;
      Hit := Painter.HitTest(X, Y, MulDiv(400,Dpi,96), MulDiv(250,Dpi,96),
        Dpi, F.Tree.Model, F.Tree.Columns, 0, 0);
      Require(Hit.Kind = thRow, 'hidden checkbox still accepts checkbox hit at DPI ' + IntToStr(Dpi));
      Painter.ShowCheckBoxes := True;
      Hit := Painter.HitTest(X, Y, MulDiv(400,Dpi,96), MulDiv(250,Dpi,96),
        Dpi, F.Tree.Model, F.Tree.Columns, 0, 0);
      Require(Hit.Kind = thCheck, 'visible checkbox has no hit at DPI ' + IntToStr(Dpi));
      Bitmap.SetSize(MulDiv(400,Dpi,96), MulDiv(250,Dpi,96));
      Painter.Paint(Bitmap.Canvas.Handle, Bitmap.Width, Bitmap.Height, Dpi,
        TDACComponentStyle.Resolve(dtmLight).Tokens.Controls,
        F.Tree.Model, F.Tree.Columns, '', 0, 0, -1, False, True, False, '', nil);
      Require(Painter.PaintedRows = 1, 'plain painter rendered nonvisible nodes');
      Require(not F.Tree.Model.Find('A').Checked, 'plain painter mutated check state');
    end;
    Writeln('DPI plain-tree offscreen 96/144/192 with optional checkbox hit-tests');
  finally Bitmap.Free; Painter.Free; F.Free; end;
end;

procedure TestPerformance;
const Sizes: array[0..2] of Integer = (1000, 10000, 50000);
var F: TFixture; S, I, N, Loads: Integer; Parent: Variant;
  Watch: TStopwatch; LoadMs, NavigationMs, DeleteMs: Double;
begin
  for S := Low(Sizes) to High(Sizes) do
  begin
    N := Sizes[S]; F := TFixture.Create;
    try
      for I := N downto 1 do
      begin
        if I = 1 then Parent := Null else Parent := I - 1;
        F.Add(I, Parent, 'Deep item ' + IntToStr(I));
      end;
      MappingCalls := 0; Loads := F.Tree.LoadCount;
      Watch := TStopwatch.StartNew;
      Require(F.Load, 'deep object catalogue rejected: ' + F.Tree.LastError);
      LoadMs := Watch.Elapsed.TotalMilliseconds;
      Require(MappingCalls = N, 'deep load mapped records more than once');
      Require(F.Tree.LoadCount = Loads + 1, 'deep object load published more than once');
      Require(F.Tree.Model.Nodes.Count = N, 'deep catalogue truncated');
      Require(F.Tree.Model.Find(N).Depth = N - 1, 'deep hierarchy depth incorrect');
      F.Tree.ExpandAll;
      Require(F.Tree.Model.Visible.Count = N, 'deep expansion truncated');
      F.Tree.SearchText := 'Deep item ' + IntToStr(N);
      Require(F.Tree.Model.Visible.Count = N, 'deep search lost ancestors');
      F.Tree.SearchText := '';
      Loads := F.Tree.LoadCount; Watch := TStopwatch.StartNew;
      for I := 1 to 100 do begin F.Tree.SelectedKey := 1; F.Tree.SelectedKey := 2; end;
      NavigationMs := Watch.Elapsed.TotalMilliseconds;
      Require(F.Tree.LoadCount = Loads, 'selection rebuilt catalogue');
      Require(MappingCalls = N, 'navigation remapped source objects');
      Watch := TStopwatch.StartNew;
      F.Tree.Items.Delete(F.Tree.Items.Find(1));
      DeleteMs := Watch.Elapsed.TotalMilliseconds;
      Require(F.Tree.Items.Count = 0, 'deep subtree deletion left descendants');
      Require(F.Objects.Count = N, 'deep deletion modified source collection');
      Require(MappingCalls = N, 'deep deletion remapped source objects');
      Writeln(Format('PERF records=%d load_ms=%.3f navigation_200_moves_ms=%.3f delete_ms=%.3f',
        [N, LoadMs, NavigationMs, DeleteMs]));
    finally F.Free; end;
  end;
end;

begin
  try
    Application.Initialize;
    RunTest('manual items and subtree deletion', TestManualItems);
    RunTest('generic objects and external ownership', TestObjectLoadingAndLifetime);
    RunTest('state preservation and object replacement', TestStateAndReplacement);
    RunTest('invalid hierarchy and mapper failures', TestInvalidData);
    RunTest('typed keys and root sentinels', TestTypedKeysAndRoots);
    RunTest('checkbox policy, consumer writes and keyboard', TestMarkingAndKeyboard);
    RunTest('reentrant events', TestReentrantEvents);
    RunTest('direct item setters and filtered keyboard', TestDirectItemUpdatesAndFilteredNavigation);
    RunTest('DFM items, columns, roots and events', TestStreaming);
    RunTest('paint uses snapshots', TestPaintUsesSnapshot);
    RunTest('defaults and programmatic DPI scaling', TestDefaultsAndDpi);
    RunTest('plain painter DPI and optional checkboxes', TestPlainPainterDpiAndOptionalChecks);
    RunTest('performance', TestPerformance);
    Writeln('RESULT assertions=', Assertions, ' failures=', Failures);
    if Failures > 0 then ExitCode := 1;
  except on E: Exception do begin Writeln('FAIL ', E.ClassName, ': ', E.Message); ExitCode := 1; end; end;
end.
