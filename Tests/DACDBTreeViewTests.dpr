program DACDBTreeViewTests;

{$APPTYPE CONSOLE}

uses
  System.Classes, System.SysUtils, System.Variants, System.Diagnostics,
  System.Types, Winapi.Windows, Vcl.Forms, Vcl.Controls, Vcl.Graphics,
  Data.DB, Datasnap.DBClient, MidasLib,
  DAC.Components.Controls.DBTreeView,
  DAC.Components.Controls.DBTreeView.Types,
  DAC.Components.Controls.DBTreeView.Roots,
  DAC.Components.DesignSystem.Theme;

type
  TTestProc = procedure;
  TFixture = class
  public
    Data: TClientDataSet;
    Source: TDataSource;
    Tree: TDACDBTreeView;
    Veto, AutoEdit, AutoPost, FailWrite: Boolean;
    MoveBefore, RefreshBefore, RefreshAfter, ReenterBefore, ReopenBefore: Boolean;
    RefreshOnReset: Boolean;
    ReenterAccepted: Boolean;
    PostMutation: Integer;
    SwapBefore: TDataSource;
    SwapOnGetText: TDataSource;
    Changed, Errors, CurrentChanged, Activations: Integer;
    constructor Create;
    destructor Destroy; override;
    procedure Add(const Key: string; const Parent: Variant;
      const Text: string; Eligible: Boolean = True);
    procedure Bind;
    procedure BeforeCheck(Sender: TObject; const Key: Variant;
      const Checked: Boolean; var Allow: Boolean);
    procedure CheckChanged(Sender: TObject; const Key: Variant;
      Checked: Boolean; Reason: TDACDBTreeChangeReason);
    procedure Current(Sender: TObject; const OldKey, NewKey: Variant;
      Reason: TDACDBTreeChangeReason);
    procedure Error(Sender: TObject; const Key: Variant;
      const MessageText: string);
    procedure ValidateCheck(Sender: TField);
    procedure Activate(Sender: TObject; const Key: Variant);
    procedure BeforePost(Sender: TDataSet);
    procedure GetText(Sender: TField; var Text: string; DisplayText: Boolean);
  end;

  TStreamForm = class(TForm)
  public
    Calls: Integer;
  published
    procedure BeforeCheck(Sender: TObject; const Key: Variant;
      const Checked: Boolean; var Allow: Boolean);
  end;

var Assertions, Failures: Integer;

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
  except
    on E: Exception do
    begin
      Inc(Failures);
      Writeln('FAIL ', Name, ': ', E.ClassName, ': ', E.Message);
    end;
  end;
end;

constructor TFixture.Create;
begin
  inherited;
  Data := TClientDataSet.Create(nil);
  Data.FieldDefs.Add('ID', ftString, 30);
  Data.FieldDefs.Add('PARENT', ftString, 30);
  Data.FieldDefs.Add('LABEL', ftString, 180);
  Data.FieldDefs.Add('CHECKED', ftBoolean);
  Data.FieldDefs.Add('ELIGIBLE', ftBoolean);
  Data.CreateDataSet;
  Data.BeforePost := BeforePost;
  Data.FieldByName('CHECKED').OnValidate := ValidateCheck;
  Source := TDataSource.Create(nil);
  Source.DataSet := Data;
  Tree := TDACDBTreeView.Create(nil);
  Tree.OnBeforeCheckChange := BeforeCheck;
  Tree.OnCheckChanged := CheckChanged;
  Tree.OnCurrentChanged := Current;
  Tree.OnDataError := Error;
  Tree.OnActivateRecord := Activate;
end;

destructor TFixture.Destroy;
begin
  Tree.Free;
  Source.Free;
  Data.Free;
  inherited;
end;

procedure TFixture.Add(const Key: string; const Parent: Variant;
  const Text: string; Eligible: Boolean);
begin
  Data.AppendRecord([Key, Parent, Text, False, Eligible]);
end;

procedure TFixture.Bind;
begin
  Data.First;
  Tree.BeginUpdate;
  try
    Tree.KeyField := 'ID';
    Tree.ParentField := 'PARENT';
    with Tree.Columns.Add do begin FieldName := 'ID'; Caption := 'Code'; Width := 100; end;
    with Tree.Columns.Add do begin FieldName := 'LABEL'; Caption := 'Description'; Width := 300; end;
    Tree.CheckableField := 'ELIGIBLE';
    Tree.DataSource := Source;
  finally
    Tree.EndUpdate;
  end;
end;

procedure TFixture.BeforeCheck(Sender: TObject; const Key: Variant;
  const Checked: Boolean; var Allow: Boolean);
var Save: TMemoryStream;
begin
  Allow := not Veto;
  if ReenterBefore then
  begin
    ReenterBefore := False;
    ReenterAccepted := Tree.TrySetChecked(Key, Checked);
  end;
  if ReopenBefore then
  begin
    Save := TMemoryStream.Create;
    try
      Data.SaveToStream(Save, dfBinary); Data.Close;
      Save.Position := 0; Data.LoadFromStream(Save);
    finally Save.Free; end;
  end;
  if Allow and AutoEdit then Data.Edit;
  if MoveBefore then Data.Next;
  if RefreshBefore then Tree.Refresh;
  if SwapBefore <> nil then Tree.DataSource := SwapBefore;
end;

procedure TFixture.CheckChanged(Sender: TObject; const Key: Variant;
  Checked: Boolean; Reason: TDACDBTreeChangeReason);
begin
  Inc(Changed);
  if AutoPost and (Reason in [tcrUser, tcrProgrammatic]) and
     (Data.State in [dsEdit, dsInsert]) then Data.Post;
  if RefreshAfter then Tree.Refresh;
end;

procedure TFixture.Current(Sender: TObject; const OldKey, NewKey: Variant;
  Reason: TDACDBTreeChangeReason);
begin
  Inc(CurrentChanged);
  if RefreshOnReset and (Reason = tcrReset) then
  begin
    RefreshOnReset := False;
    Tree.Refresh;
  end;
end;

procedure TFixture.Error(Sender: TObject; const Key: Variant;
  const MessageText: string);
begin
  Inc(Errors);
end;

procedure TFixture.ValidateCheck(Sender: TField);
begin
  if FailWrite then raise EDatabaseError.Create('Deliberate field validation failure');
end;

procedure TFixture.Activate(Sender: TObject; const Key: Variant);
begin
  Inc(Activations);
end;

procedure TFixture.BeforePost(Sender: TDataSet);
begin
  if (PostMutation = 0) or (Data.FieldByName('ID').AsString <> 'A') then Exit;
  case PostMutation of
    1:
      begin
        Data.FieldByName('LABEL').AsString := 'Final callback value';
        Data.FieldByName('CHECKED').AsBoolean := True;
        Data.FieldByName('ELIGIBLE').AsBoolean := False;
      end;
    2: Data.FieldByName('PARENT').AsString := 'B';
    3: Data.FieldByName('ID').AsString := 'A2';
    4: Data.FieldByName('PARENT').AsString := 'missing';
    5: Data.FieldByName('ID').AsString := 'B';
  end;
end;

procedure TFixture.GetText(Sender: TField; var Text: string; DisplayText: Boolean);
var Replacement: TDataSource;
begin
  Text := Sender.AsString;
  Replacement := SwapOnGetText;
  if Replacement <> nil then
  begin
    SwapOnGetText := nil;
    Tree.DataSource := Replacement;
  end;
end;

procedure TStreamForm.BeforeCheck(Sender: TObject; const Key: Variant;
  const Checked: Boolean; var Allow: Boolean);
begin
  Inc(Calls);
  Allow := False;
end;

procedure TestHierarchyAndSearch;
var F: TFixture; Loads: Integer;
begin
  F := TFixture.Create;
  try
    F.Add('001', Null, 'Root');
    F.Add('001-A', '001', 'Target');
    F.Add('002', '', 'Other root', False);
    F.Add('001-A-1', '001-A', 'Deep child');
    F.Bind;
    Require(F.Tree.IsDataValid, 'valid forest rejected: ' + F.Tree.LastError);
    Require(F.Tree.LoadCount = 1, 'initial binding performed multiple catalogue loads');
    Require(F.Tree.Model.Nodes.Count = 4, 'catalogue size');
    Require(F.Tree.Model.Visible.Count = 2, 'initial roots should be collapsed');
    Require(F.Tree.Model.Find('001').Key = '001', 'leading zeros were changed');
    Require(F.Tree.Model.Find('001-A-1').Depth = 2, 'key-parent depth');
    Require(F.Tree.TrySetChecked('001-A-1', True), 'local selection failed');
    Require(Length(F.Tree.CheckedKeys) = 1, 'checked keys missing');
    Require(not F.Tree.TrySetChecked('002', True), 'blocked record accepted');
    F.Tree.SelectedKey := '002';
    F.Tree.SearchText := 'tArGeT';
    Require(F.Tree.Model.Visible.Count = 2, 'search must keep ancestor and matching child only');
    Require(F.Tree.SelectedKey = '002', 'filter changed hidden current key');
    Require(Length(F.Tree.CheckedKeys) = 1, 'filter discarded hidden checks');
    F.Tree.SearchText := '';
    Require(F.Tree.Model.Visible.Count = 2, 'clearing filter did not restore expansion');
    F.Tree.Expand('001');
    Require(F.Tree.Model.Visible.Count = 3, 'expand wrong count');
    F.Tree.ExpandAll;
    Require(F.Tree.Model.Visible.Count = 4, 'expand all');
    F.Tree.CollapseAll;
    Require(F.Tree.Model.Visible.Count = 2, 'collapse all');
    Loads := F.Tree.LoadCount;
    F.Data.First; F.Data.Next; F.Data.Last;
    Require(F.Tree.LoadCount = Loads, Format('dataset scroll rebuilt catalogue (%d -> %d)', [Loads, F.Tree.LoadCount]));
    Require(F.Tree.SelectedKey = '001-A-1', 'external scroll did not synchronize current key');
  finally F.Free; end;
end;

procedure TestInvalidHierarchy;
var F: TFixture;
  procedure Rejected(const Context: string);
  begin
    F.Bind;
    Require(not F.Tree.IsDataValid, Context + ' accepted');
    Require(F.Tree.Model.Nodes.Count = 0, Context + ' left actionable rows');
    Require(F.Errors > 0, Context + ' did not report error');
    Require(F.Tree.LastError <> '', Context + ' lacks retained diagnostic');
  end;
begin
  F := TFixture.Create;
  try F.Add('A', Null, 'one'); F.Add('A', Null, 'duplicate'); Rejected('duplicate'); finally F.Free; end;
  F := TFixture.Create;
  try F.Add('A', 'missing', 'orphan'); Rejected('orphan'); finally F.Free; end;
  F := TFixture.Create;
  try F.Add('A', 'A', 'self'); Rejected('self reference'); finally F.Free; end;
  F := TFixture.Create;
  try F.Add('A', 'B', 'cycle'); F.Add('B', 'A', 'cycle'); Rejected('cycle'); finally F.Free; end;
  F := TFixture.Create;
  try
    F.Data.AppendRecord([Null, Null, 'null key', False, True]);
    Rejected('null key');
  finally F.Free; end;
end;

procedure TestMarkingLifecycle;
var F: TFixture; Loads, Changes: Integer;
begin
  F := TFixture.Create;
  try
    F.Add('A', Null, 'Root'); F.Add('B', Null, 'Other'); F.Add('C', Null, 'Blocked', False);
    F.Bind;
    F.Tree.CheckField := 'CHECKED';
    F.Tree.CheckableField := 'ELIGIBLE';
    F.Tree.Refresh;
    F.Tree.SelectedKey := 'A';
    Require(not F.Tree.TrySetChecked('A', True), 'component initiated Edit without consumer');
    Require(F.Data.State = dsBrowse, 'failed marking changed browse state');
    Require(Length(F.Tree.CheckedKeys) = 0, 'write failure fell back to local check');
    F.AutoEdit := True;
    F.Veto := True;
    Require(not F.Tree.TrySetChecked('A', True), 'veto ignored');
    Require(F.Data.State = dsBrowse, 'veto started edit');
    F.Veto := False;
    F.Tree.ReadOnly := True;
    Require(not F.Tree.TrySetChecked('A', True), 'readonly ignored');
    F.Tree.ReadOnly := False;
    Require(not F.Tree.TrySetChecked('C', True), 'eligibility ignored');
    F.Tree.SelectedKey := 'A';
    Loads := F.Tree.LoadCount;
    Changes := F.Changed;
    Require(F.Tree.TrySetChecked('A', True), 'consumer Edit marking failed');
    Require(F.Data.State = dsEdit, 'component posted consumer edit');
    Require(F.Data.FieldByName('CHECKED').AsBoolean, 'check field unchanged');
    Require(F.Changed = Changes + 1, 'mark event missing/duplicated');
    Require(F.Tree.LoadCount = Loads, 'checkbox rebuilt catalogue');
    F.Data.Cancel;
    Require(not F.Tree.Model.Find('A').Checked, 'Cancel did not restore check state');
    Require(F.Tree.LoadCount = Loads, 'Cancel of check rebuilt catalogue');
    Require(F.Tree.TrySetChecked('A', True), 'second marking failed');
    F.Tree.SelectedKey := 'B';
    Require(F.Data.State = dsBrowse, 'normal VCL navigation did not conclude edit');
    F.Data.Locate('ID', 'A', []);
    Require(F.Data.FieldByName('CHECKED').AsBoolean, 'implicit Post did not keep local field');
    Require(F.Tree.LoadCount = Loads, 'Post/scroll of check rebuilt catalogue');
    F.FailWrite := True;
    Require(not F.Tree.TrySetChecked('A', False), 'field validation failure reported success');
    Require(F.Tree.Model.Find('A').Checked, 'failed write changed cached state');
    Require(F.Data.State = dsEdit, 'failed write changed consumer edit lifecycle');
    F.FailWrite := False; F.Data.Cancel;
    F.AutoPost := True;
    Require(F.Tree.TrySetChecked('A', False), 'consumer Post marking failed');
    Require(F.Data.State = dsBrowse, 'consumer Post not honored');
    Require(Length(F.Tree.CheckedKeys) = 0, 'consumer Post cache stale');
    F.Data.ReadOnly := True;
    Require(not F.Tree.TrySetChecked('A', True), 'readonly dataset accepted write');
    Require(Length(F.Tree.CheckedKeys) = 0, 'readonly dataset activated local fallback');
  finally F.Free; end;
end;

procedure TestRefreshAndLifecycle;
var F, G: TFixture; Saved: string;
begin
  F := TFixture.Create;
  G := TFixture.Create;
  try
    F.Add('A', Null, 'Root'); F.Add('B', 'A', 'Child'); F.Bind;
    G.Add('A', Null, 'Independent'); G.Bind;
    F.Tree.Expand('A');
    F.Tree.SelectedKey := 'B';
    F.Tree.TrySetChecked('B', True);
    F.Tree.Refresh;
    Require(F.Tree.Model.Find('A').Expanded, 'refresh lost expansion');
    Require(F.Tree.SelectedKey = 'B', 'refresh moved current record');
    Require(F.Tree.Model.Find('B').Checked, 'refresh lost local checks');
    Require(not G.Tree.Model.Find('A').Checked, 'instance state leaked');
    F.Data.Locate('ID', 'B', []);
    F.Data.Edit; F.Data.FieldByName('PARENT').AsString := 'missing'; F.Data.Post;
    F.Tree.Refresh;
    Require(not F.Tree.IsDataValid, 'invalid update accepted');
    Require(F.Tree.Model.Nodes.Count = 0, 'invalid update left nodes');
    F.Data.Edit; F.Data.FieldByName('PARENT').AsString := 'A'; F.Data.Post;
    F.Tree.Refresh;
    Require(F.Tree.IsDataValid, 'repaired update rejected');
    Require(F.Tree.Model.Find('A').Expanded, 'repair lost saved expansion');
    Require(F.Tree.Model.Find('B').Checked, 'repair lost saved checks');
    Saved := GetEnvironmentVariable('TEMP') + '\DACDBTreeView-close-reopen.xml';
    F.Data.SaveToFile(Saved, dfXMLUTF8);
    try
      F.Data.Close;
      Require(F.Tree.Model.Nodes.Count = 0, 'close left rows');
      F.Data.LoadFromFile(Saved);
      F.Tree.Refresh;
      Require(F.Tree.IsDataValid, 'reopen failed');
      Require(F.Tree.Model.Find('B').Checked, 'reopen lost local checks');
    finally System.SysUtils.DeleteFile(Saved); end;
    F.Tree.SelectedKey := 'B'; F.Data.Delete; F.Tree.Refresh;
    Require(Length(F.Tree.CheckedKeys) = 0, 'deleted key retained');
    Require(VarIsNull(F.Tree.SelectedKey) or (F.Tree.SelectedKey <> 'B'), 'deleted current key retained');
    F.Tree.DataSource := G.Source;
    F.Tree.Refresh;
    Require(F.Tree.Model.Nodes.Count = 1, 'source replacement not read');
    Require(Length(F.Tree.CheckedKeys) = 0, 'source replacement leaked checks');
    G.Data.Free; G.Data := nil;
    Require(G.Tree.Model.Nodes.Count = 0, 'dataset-first destruction left rows');
    Require(F.Tree.Model.Nodes.Count = 0, 'shared datasource destruction left rows');
    F.Source.Free; F.Source := nil;
    F.Tree.Free; F.Tree := nil;
    G.Source.Free; G.Source := nil;
    Require(G.Tree.DataSource = nil, 'datasource-first destruction left reference');
  finally G.Free; F.Free; end;
end;

procedure TestReentrantEvents;
var F, G: TFixture;
begin
  F := TFixture.Create; G := TFixture.Create;
  try
    F.Add('A', Null, 'Root'); F.Add('B', Null, 'Other'); F.Bind;
    G.Add('A', Null, 'Replacement'); G.Bind;
    F.ReenterBefore := True;
    Require(F.Tree.TrySetChecked('A', True), 'outer recursive-check request failed');
    Require(not F.ReenterAccepted, 'recursive before-check request was accepted');
    F.Tree.TrySetChecked('A', False);
    F.ReopenBefore := True;
    Require(not F.Tree.TrySetChecked('A', True), 'close/reopen during before-check accepted stale request');
    F.ReopenBefore := False;
    F.Tree.Refresh;
    Require(F.Tree.IsDataValid, 'close/reopen before-check left invalid binding');
    F.RefreshBefore := True;
    Require(not F.Tree.TrySetChecked('A', True), 'refresh during before-check accepted stale node');
    Require(not F.Tree.Model.Find('A').Checked, 'refresh during before-check changed check');
    F.RefreshBefore := False;
    F.SwapBefore := G.Source;
    Require(not F.Tree.TrySetChecked('A', True), 'source swap during before-check accepted stale node');
    F.Tree.Refresh;
    Require(not F.Tree.Model.Find('A').Checked, 'source swap wrote replacement node');
    F.SwapBefore := nil; F.Tree.DataSource := F.Source; F.Tree.Refresh;
    F.Tree.CheckField := 'CHECKED'; F.Tree.Refresh;
    F.MoveBefore := True;
    Require(not F.Tree.TrySetChecked('A', True), 'cursor move during before-check accepted wrong record');
    Require(not F.Data.FieldByName('CHECKED').AsBoolean, 'cursor move wrote wrong record');
    F.MoveBefore := False;
    F.Tree.CheckField := ''; F.Tree.Refresh;
    F.RefreshAfter := True;
    Require(F.Tree.TrySetChecked('A', True), 'refresh during changed-event failed successful local write');
    Require(F.Tree.Model.Find('A').Checked, 'refresh during changed-event lost local write');
  finally G.Free; F.Free; end;
end;

procedure TestBoundChanges;
var F, G: TFixture; Loads: Integer;
begin
  F := TFixture.Create; G := TFixture.Create;
  try
    F.Add('A', Null, 'Root'); F.Add('B', 'A', 'Child'); F.Bind;
    G.Add('Z', Null, 'Replacement dataset'); G.Bind;
    F.Tree.CheckField := 'CHECKED'; F.Tree.Refresh;
    Loads := F.Tree.LoadCount;
    F.Data.First;
    F.Data.Edit; F.Data.FieldByName('LABEL').AsString := 'Changed root'; F.Data.Post;
    Require(F.Tree.Model.Find('A').Cells[1] = 'Changed root', 'external display edit not cached');
    Require(F.Tree.LoadCount = Loads, 'nonstructural display edit rebuilt catalogue');
    F.Data.Edit; F.Data.FieldByName('CHECKED').AsBoolean := True;
    Require(F.Tree.Model.Find('A').Checked, 'external boolean edit not cached');
    F.Data.Cancel;
    Require(not F.Tree.Model.Find('A').Checked, 'external boolean Cancel did not restore cache');
    Require(F.Tree.LoadCount = Loads, 'external boolean edit/Cancel rebuilt catalogue');
    F.Add('C', 'A', 'Inserted while bound');
    Require(F.Tree.IsDataValid, 'insert left invalid catalogue: ' + F.Tree.LastError);
    Require(F.Tree.Model.Nodes.Count = 3, 'insert while bound not added automatically');
    Require(F.Tree.Model.Find('C') <> nil, 'insert key missing');
    F.Data.Delete;
    Require(F.Tree.Model.Nodes.Count = 2, 'delete while bound not removed automatically');
    F.Source.DataSet := G.Data;
    Require(F.Tree.IsDataValid, 'DataSource.DataSet replacement failed');
    Require(F.Tree.Model.Nodes.Count = 1, 'DataSource.DataSet replacement not loaded');
    Require(F.Tree.Model.Find('Z') <> nil, 'DataSource.DataSet replacement retained prior catalogue');
  finally G.Free; F.Free; end;
end;

procedure TestImplicitPostCallbacks;
var F: TFixture; Mutation, Loads, Changes: Integer;
begin
  for Mutation := 1 to 5 do
  begin
    F := TFixture.Create;
    try
      F.Add('A', Null, 'First'); F.Add('B', Null, 'Target'); F.Bind;
      F.Tree.CheckField := 'CHECKED'; F.Tree.Refresh;
      F.Tree.SelectedKey := 'A';
      Loads := F.Tree.LoadCount;
      Changes := F.Changed;
      F.Data.Edit;
      F.Data.FieldByName('LABEL').AsString := 'Pending user edit';
      F.PostMutation := Mutation;
      { Navigate performs normal VCL implicit Post. The component does not
        own the edit transaction and must reread any callback mutations. }
      F.Tree.SelectedKey := 'B';
      Require(F.Data.State = dsBrowse, 'implicit callback Post did not finish');
      Require(F.Data.FieldByName('ID').AsString = 'B', 'callback navigation did not preserve target cursor');
      if Mutation <= 3 then
      begin
        Require(F.Tree.IsDataValid, 'valid callback mutation rejected: ' + F.Tree.LastError);
        Require(F.Tree.SelectedKey = 'B', 'callback mutation moved selected target');
        case Mutation of
          1:
            begin
              Require(F.Tree.Model.Find('A').Cells[1] = 'Final callback value', 'implicit Post cached stale callback label');
              Require(F.Tree.Model.Find('A').Checked, 'implicit Post cached stale callback check');
              Require(not F.Tree.Model.Find('A').Checkable, 'implicit Post cached stale eligibility');
              Require(F.Changed = Changes + 1, 'implicit Post callback check event missing/duplicated');
              Require(F.Tree.LoadCount = Loads, 'nonstructural implicit Post callback rebuilt catalogue');
            end;
          2:
            begin
              Require(F.Tree.Model.Find('A').ParentIndex = F.Tree.Model.Find('B').Index, 'implicit Post parent callback not rebuilt');
              Require(F.Tree.LoadCount > Loads, 'structural parent callback did not rebuild catalogue');
            end;
          3:
            begin
              Require(F.Tree.Model.Find('A') = nil, 'implicit Post retained obsolete callback key');
              Require(F.Tree.Model.Find('A2') <> nil, 'implicit Post callback new key missing');
              Require(F.Tree.LoadCount > Loads, 'structural key callback did not rebuild catalogue');
            end;
        end;
      end
      else
      begin
        Require(not F.Tree.IsDataValid, 'invalid implicit Post callback hierarchy accepted');
        Require(F.Tree.Model.Nodes.Count = 0, 'invalid implicit Post callback retained nodes');
        Require(VarIsNull(F.Tree.SelectedKey), 'invalid implicit Post callback retained selection');
        Require(F.Errors > 0, 'invalid implicit Post callback not signaled');
      end;
    finally F.Free; end;
  end;
end;

procedure TestReentrantBindingReset;
var F, G: TFixture;
begin
  F := TFixture.Create; G := TFixture.Create;
  try
    F.Add('A', Null, 'Old dataset'); F.Bind;
    G.Add('A', Null, 'New dataset with reused key'); G.Bind;
    Require(F.Tree.TrySetChecked('A', True), 'binding-reset setup mark failed');
    F.RefreshOnReset := True;
    F.Tree.DataSource := G.Source;
    F.Tree.Refresh;
    Require(F.Tree.IsDataValid, 'reentrant binding reset left invalid catalogue');
    Require(F.Tree.Model.Find('A').Cells[1] = 'New dataset with reused key', 'reentrant reset retained old catalogue');
    Require(not F.Tree.Model.Find('A').Checked, 'reentrant reset leaked local check to new binding');
    Require(Length(F.Tree.CheckedKeys) = 0, 'reentrant reset exposed old checked keys');
    Require(not F.RefreshOnReset, 'binding reset did not emit reset-current event');
  finally G.Free; F.Free; end;
end;

procedure TestBindingSwapDuringScan;
var F, G: TFixture;
begin
  F := TFixture.Create; G := TFixture.Create;
  try
    F.Add('Old', Null, 'Old catalogue'); F.Bind;
    G.Add('New', Null, 'Replacement catalogue'); G.Bind;
    F.Data.FieldByName('LABEL').OnGetText := F.GetText;
    F.SwapOnGetText := G.Source;
    F.Tree.Refresh;
    Require(F.Tree.DataSource = G.Source, 'scan callback did not replace binding');
    Require(not F.Data.ControlsDisabled, 'binding change during scan leaked DisableControls on old dataset');
    Require(F.Tree.Model.Find('Old') = nil, 'scan callback published obsolete catalogue');
    F.Tree.Refresh;
    Require(F.Tree.IsDataValid, 'replacement catalogue invalid after explicit refresh');
    Require(F.Tree.Model.Find('New') <> nil, 'replacement catalogue not loaded after scan callback');
    Require(F.Tree.Model.Nodes.Count = 1, 'scan callback mixed old and new rows');
  finally G.Free; F.Free; end;
end;

procedure TestIntegerRootsAndGuid;
var D: TClientDataSet; S: TDataSource; T: TDACDBTreeView; I: Integer;
begin
  for I := 0 to 1 do
  begin
    D := TClientDataSet.Create(nil); S := TDataSource.Create(nil); T := TDACDBTreeView.Create(nil);
    try
      if I = 0 then begin D.FieldDefs.Add('ID', ftInteger); D.FieldDefs.Add('PARENT', ftInteger); end
      else begin D.FieldDefs.Add('ID', ftGuid, 38); D.FieldDefs.Add('PARENT', ftGuid, 38); end;
      D.CreateDataSet; S.DataSet := D;
      if I = 0 then begin
        D.AppendRecord([1, 0]); D.AppendRecord([2, 1]);
        with T.RootValues.Add do begin Kind := trkValue; Value := 0; end;
      end else begin
        D.AppendRecord(['{C96EA609-7FC4-41E6-B747-57E933DDF862}', Null]);
        D.AppendRecord(['{D96EA609-7FC4-41E6-B747-57E933DDF862}', '{C96EA609-7FC4-41E6-B747-57E933DDF862}']);
      end;
      T.BeginUpdate;
      try T.KeyField := 'ID'; T.ParentField := 'PARENT'; T.DataSource := S; finally T.EndUpdate; end;
      T.Refresh;
      Require(T.IsDataValid, 'integer/GUID hierarchy rejected: ' + T.LastError);
      Require(T.Model.Nodes.Count = 2, 'integer/GUID catalogue size');
      if I = 0 then begin
        T.RootValues.Clear;
        with T.RootValues.Add do begin Kind := trkValue; Value := '0'; end;
        T.Refresh;
        Require(not T.IsDataValid, 'text sentinel silently matched numeric zero');
      end;
    finally T.Free; S.Free; D.Free; end;
  end;
end;

procedure TestStreaming;
var Host, CopyHost: TStreamForm; Tree, CopyTree: TDACDBTreeView;
  Stream: TMemoryStream;
begin
  System.Classes.RegisterClass(TDACDBTreeView);
  System.Classes.RegisterClass(TStreamForm);
  Host := TStreamForm.CreateNew(nil);
  Stream := TMemoryStream.Create;
  CopyHost := nil;
  try
    Host.Name := 'StreamHost';
    Tree := TDACDBTreeView.Create(Host); Tree.Name := 'Tree'; Tree.Parent := Host;
    Tree.KeyField := 'ID'; Tree.ParentField := 'PARENT';
    Tree.SearchFields.Add('LABEL');
    with Tree.Columns.Add do begin FieldName := 'ID'; Caption := 'Code'; Width := 123; Hint := 'Column hint'; end;
    with Tree.RootValues.Add do begin Kind := trkValue; Value := 0; end;
    with Tree.RootValues.Add do begin Kind := trkValue; Value := '000'; end;
    Tree.OnBeforeCheckChange := Host.BeforeCheck;
    Tree.ThemeMode := dtmLight;
    Stream.WriteComponent(Host);
    Stream.Position := 0;
    CopyHost := TStreamForm.CreateNew(nil);
    Stream.ReadComponent(CopyHost);
    CopyTree := CopyHost.FindComponent('Tree') as TDACDBTreeView;
    Require(CopyTree <> nil, 'DFM tree missing');
    Require(CopyTree.Columns.Count = 1, 'DFM columns lost');
    Require(CopyTree.Columns[0].Width = 123, 'DFM column width lost');
    Require(CopyTree.Columns[0].Hint = 'Column hint', 'DFM hint lost');
    Require(CopyTree.RootValues.Count = 4, 'DFM root collection duplicated/lost defaults');
    Require(VarType(CopyTree.RootValues[2].Value) <> varUString, 'DFM numeric root became text');
    Require(CopyTree.RootValues[3].Value = '000', 'DFM textual sentinel changed');
    Require(CopyTree.SearchFields[0] = 'LABEL', 'DFM search fields lost');
    Require(CopyTree.ThemeMode = dtmLight, 'DFM theme lost');
    Require(Assigned(CopyTree.OnBeforeCheckChange), 'DFM event not bound');
    Require(TMethod(CopyTree.OnBeforeCheckChange).Data = CopyHost, 'DFM event bound to old owner');
  finally CopyHost.Free; Stream.Free; Host.Free; end;
end;

procedure TestPaintUsesCache;
var F: TFixture; Host: TForm; Bitmap: TBitmap; Reads, Loads: Integer;
begin
  F := TFixture.Create; Host := TForm.CreateNew(nil); Bitmap := TBitmap.Create;
  try
    F.Add('A', Null, 'Root'); F.Add('B', 'A', 'Child'); F.Bind;
    F.Tree.Parent := Host;
    F.Tree.SetBounds(0, 0, 480, 240);
    Require(F.Tree.Handle <> 0, 'runtime handle not created with parent');
    F.Tree.Refresh; F.Tree.ExpandAll;
    Bitmap.SetSize(480, 240);
    Reads := F.Tree.DataReadCount;
    Loads := F.Tree.LoadCount;
    F.Tree.PaintTo(Bitmap.Canvas.Handle, 0, 0);
    F.Tree.PaintTo(Bitmap.Canvas.Handle, 0, 0);
    Require(F.Tree.DataReadCount = Reads, 'paint read dataset');
    Require(F.Tree.LoadCount = Loads, 'paint rebuilt catalogue');
    F.Tree.Parent := nil;
  finally Bitmap.Free; Host.Free; F.Free; end;
end;

procedure TestFontScaling;
var Tree: TDACDBTreeView;
begin
  Tree := TDACDBTreeView.Create(nil);
  try
    Require(not Tree.ParentFont, 'default font unexpectedly inherits screen-scaled parent font');
    Require(Tree.Font.PixelsPerInch = 96, 'constructor font is not based on design DPI');
    Require(Tree.Font.Height = -12, 'constructor applied screen DPI to the default font');
    Require(not Tree.HandleAllocated, 'default font setup forced HWND without parent');
    Tree.ScaleBy(144, 96);
    Require(Tree.Font.Height = -18, '144 DPI font was scaled twice or not scaled');
    Tree.ScaleBy(192, 144);
    Require(Tree.Font.Height = -24, '192 DPI font was scaled twice or not scaled');
  finally Tree.Free; end;
end;

procedure TestPerformance;
const Sizes: array[0..2] of Integer = (1000, 10000, 50000);
var F: TFixture; S, I, N, Loads: Integer; Watch: TStopwatch; LoadMs, NavMs: Double;
begin
  for S := Low(Sizes) to High(Sizes) do
  begin
    N := Sizes[S]; F := TFixture.Create;
    try
      F.Data.LogChanges := False;
      F.Data.DisableControls;
      try
        F.Add('1', Null, 'Root');
        for I := 2 to N do F.Add(IntToStr(I), IntToStr(I - 1), 'Deep node ' + IntToStr(I));
      finally F.Data.EnableControls; end;
      Watch := TStopwatch.StartNew;
      F.Bind;
      LoadMs := Watch.Elapsed.TotalMilliseconds;
      Require(F.Tree.IsDataValid, 'deep catalogue rejected: ' + F.Tree.LastError);
      Require(F.Tree.LoadCount = 1, 'benchmark measured multiple initial loads');
      Require(F.Tree.DataReadCount = N, 'benchmark did not read exactly one catalogue');
      Require(F.Tree.Model.Nodes.Count = N, 'deep catalogue truncated');
      Require(F.Tree.Model.Find(IntToStr(N)).Depth = N - 1, 'deep iterative depth invalid');
      F.Tree.ExpandAll;
      Require(F.Tree.Model.Visible.Count = N, 'deep projection truncated');
      F.Tree.SearchText := 'Deep node ' + IntToStr(N);
      Require(F.Tree.Model.Visible.Count = N, 'deep search did not preserve all ancestors');
      F.Tree.SearchText := '';
      Loads := F.Tree.LoadCount;
      Watch := TStopwatch.StartNew;
      for I := 1 to 100 do begin F.Data.First; F.Data.Next; end;
      NavMs := Watch.Elapsed.TotalMilliseconds;
      Require(F.Tree.LoadCount = Loads, 'navigation rebuilt deep catalogue');
      Writeln(Format('PERF records=%d load_ms=%.3f navigation_200_moves_ms=%.3f', [N, LoadMs, NavMs]));
    finally F.Free; end;
  end;
end;

begin
  try
    Application.Initialize;
    RunTest('hierarchy/search/scrolling', TestHierarchyAndSearch);
    RunTest('invalid hierarchy', TestInvalidHierarchy);
    RunTest('marking lifecycle', TestMarkingLifecycle);
    RunTest('refresh and lifecycle', TestRefreshAndLifecycle);
    RunTest('reentrant events', TestReentrantEvents);
    RunTest('changes while bound', TestBoundChanges);
    RunTest('implicit Post callbacks', TestImplicitPostCallbacks);
    RunTest('reentrant binding reset', TestReentrantBindingReset);
    RunTest('binding replacement during scan', TestBindingSwapDuringScan);
    RunTest('typed roots and GUID', TestIntegerRootsAndGuid);
    RunTest('DFM streaming', TestStreaming);
    RunTest('paint cache', TestPaintUsesCache);
    RunTest('default font and DPI scaling', TestFontScaling);
    RunTest('performance', TestPerformance);
    Writeln('RESULT assertions=', Assertions, ' failures=', Failures);
    if Failures <> 0 then ExitCode := 1;
  except
    on E: Exception do begin Writeln('FAIL ', E.ClassName, ': ', E.Message); ExitCode := 1; end;
  end;
end.
