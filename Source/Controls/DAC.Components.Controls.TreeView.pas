unit DAC.Components.Controls.TreeView;

interface

uses
  System.Classes, System.SysUtils, System.Types, System.Variants,
  System.Generics.Collections, Winapi.Windows, Winapi.Messages,
  Vcl.Controls, Vcl.Graphics,
  DAC.Components.DesignSystem.Theme,
  DAC.Components.Controls.TreeView.Types,
  DAC.Components.Controls.TreeView.Item,
  DAC.Components.Controls.TreeView.Items,
  DAC.Components.Controls.TreeView.Model,
  DAC.Components.Controls.TreeView.Columns,
  DAC.Components.Controls.TreeView.Roots,
  DAC.Components.Controls.TreeView.Painter;

type
  TDACTreeObjectCurrentEvent = procedure(Sender: TObject;
    const OldKey, NewKey: Variant; DataObject: TObject;
    Reason: TDACTreeChangeReason) of object;
  TDACTreeObjectBeforeCheckEvent = procedure(Sender: TObject;
    const Key: Variant; DataObject: TObject; Checked: Boolean;
    var Allow: Boolean) of object;
  TDACTreeObjectCheckEvent = procedure(Sender: TObject;
    const Key: Variant; DataObject: TObject; Checked: Boolean;
    Reason: TDACTreeChangeReason) of object;
  TDACTreeObjectActivateEvent = procedure(Sender: TObject;
    const Key: Variant; DataObject: TObject) of object;
  TDACTreeObjectEntry = record
    Data: TDACTreeItemData;
    DataObject: TObject;
  end;
  TDACTreeSavedState = record
    Checked, Expanded: Boolean;
  end;

  TDACTreeView = class(TCustomControl)
  private
    FItems: TDACTreeItems;
    FColumns: TDACTreeColumns;
    FRootValues: TDACTreeRoots;
    FModel: TDACTreeModel<TDACTreeModelNode>;
    FPainter: TDACTreePainter;
    FHistory: TDictionary<string,TDACTreeSavedState>;
    FSelectedKey, FRestoreKey: Variant;
    FSelectedToken, FSearchText, FLastError: string;
    FSelectedObject: TObject;
    FThemeMode: TDACThemeMode;
    FShowHeader: Boolean;
    FValid, FReadOnly, FShowCheckBoxes, FDirty, FDestroying,
      FLoadingData, FChecking: Boolean;
    FUpdateCount, FLock, FRevision, FLoadCount, FDataReadCount: Integer;
    FTopRow, FHorizontalOffset, FHoverRow, FDragStart, FDragOffset,
      FWheelRemainder: Integer;
    FDragKind: TDACTreeHitKind;
    FOnCurrentChanged: TDACTreeObjectCurrentEvent;
    FOnBeforeCheckChange: TDACTreeObjectBeforeCheckEvent;
    FOnCheckChanged: TDACTreeObjectCheckEvent;
    FOnActivateRecord: TDACTreeObjectActivateEvent;
    FOnDataError: TDACTreeErrorEvent;
    procedure ItemsChanged(Sender: TObject; Item: TDACTreeItem; Structural: Boolean);
    procedure ConfigurationChanged(Sender: TObject);
    procedure ThemeChanged(Sender: TObject);
    procedure SetItems(Value: TDACTreeItems);
    procedure SetColumns(Value: TDACTreeColumns);
    procedure SetRootValues(Value: TDACTreeRoots);
    procedure SetSearchText(const Value: string);
    procedure SetReadOnly(Value: Boolean);
    procedure SetShowHeader(Value: Boolean);
    procedure SetShowCheckBoxes(Value: Boolean);
    procedure SetThemeMode(Value: TDACThemeMode);
    procedure SetSelectedKey(const Value: Variant);
    function GetSelectedItem: TDACTreeItem;
    function GetCheckedKeys: TArray<Variant>;
    procedure SetNodeValues(Node: TDACTreeModelNode; const Data: TDACTreeItemData;
      DataObject: TObject);
    procedure ReadItem(Node: TDACTreeModelNode; Item: TDACTreeItem);
    procedure SaveHistory;
    procedure PublishModel(var Candidate: TDACTreeModel<TDACTreeModelNode>;
      const CurrentKey: Variant; Reason: TDACTreeChangeReason);
    function LoadEntries(const Entries: TArray<TDACTreeObjectEntry>;
      PreserveState: Boolean): Boolean;
    procedure RejectData(const Key: Variant; const MessageText: string);
    procedure ReportError(const Key: Variant; const MessageText: string);
    procedure ChangeCurrent(const Key: Variant; Reason: TDACTreeChangeReason);
    function Navigate(const Key: Variant; Reason: TDACTreeChangeReason): Boolean;
    procedure RebuildProjection;
    procedure ClampScroll;
    procedure EnsureCurrentVisible;
    function EffectiveDpi: Integer;
    procedure ActivateCurrent;
    procedure WMGetDlgCode(var M: TMessage); message WM_GETDLGCODE;
    procedure WMEraseBkgnd(var M: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure CMMouseLeave(var M: TMessage); message CM_MOUSELEAVE;
    procedure CMHintShow(var M: TCMHintShow); message CM_HINTSHOW;
    procedure WMCaptureChanged(var M: TMessage); message WM_CAPTURECHANGED;
    procedure CMCancelMode(var M: TCMCancelMode); message CM_CANCELMODE;
  protected
    procedure Loaded; override;
    procedure Paint; override;
    procedure Resize; override;
    procedure DoEnter; override;
    procedure DoExit; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
      MousePos: TPoint): Boolean; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X,Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X,Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X,Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function LoadObjects<T: class>(const Objects: TObjectList<T>;
      const Mapper: TFunc<T,TDACTreeItemData>;
      PreserveState: Boolean = True): Boolean;
    procedure Refresh; reintroduce;
    procedure BeginUpdate;
    procedure EndUpdate;
    function TrySetChecked(const Key: Variant; Checked: Boolean;
      Reason: TDACTreeChangeReason = tcrProgrammatic): Boolean;
    procedure Expand(const Key: Variant);
    procedure Collapse(const Key: Variant);
    procedure ExpandAll;
    procedure CollapseAll;
    property SelectedKey: Variant read FSelectedKey write SetSelectedKey;
    property SelectedItem: TDACTreeItem read GetSelectedItem;
    property SelectedObject: TObject read FSelectedObject;
    property CheckedKeys: TArray<Variant> read GetCheckedKeys;
    property Model: TDACTreeModel<TDACTreeModelNode> read FModel;
    property IsDataValid: Boolean read FValid;
    property LastError: string read FLastError;
    property LoadCount: Integer read FLoadCount;
    property DataReadCount: Integer read FDataReadCount;
  published
    property Items: TDACTreeItems read FItems write SetItems;
    property Columns: TDACTreeColumns read FColumns write SetColumns;
    property RootValues: TDACTreeRoots read FRootValues write SetRootValues;
    property ShowCheckBoxes: Boolean read FShowCheckBoxes write SetShowCheckBoxes default False;
    property ShowHeader: Boolean read FShowHeader write SetShowHeader default True;
    property ReadOnly: Boolean read FReadOnly write SetReadOnly default False;
    property SearchText: string read FSearchText write SetSearchText;
    property ThemeMode: TDACThemeMode read FThemeMode write SetThemeMode default dtmInherit;
    property Align;
    property Anchors;
    property Constraints;
    property Enabled;
    property Font;
    property ParentFont;
    property ParentShowHint;
    property ShowHint;
    property PopupMenu;
    property TabStop default True;
    property TabOrder;
    property Visible;
    property OnCurrentChanged: TDACTreeObjectCurrentEvent read FOnCurrentChanged write FOnCurrentChanged;
    property OnBeforeCheckChange: TDACTreeObjectBeforeCheckEvent read FOnBeforeCheckChange write FOnBeforeCheckChange;
    property OnCheckChanged: TDACTreeObjectCheckEvent read FOnCheckChanged write FOnCheckChanged;
    property OnActivateRecord: TDACTreeObjectActivateEvent read FOnActivateRecord write FOnActivateRecord;
    property OnDataError: TDACTreeErrorEvent read FOnDataError write FOnDataError;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;

implementation

uses System.Math, DAC.Components.DesignSystem.ComponentStyle,
  DAC.Components.DesignSystem.DBTreeTokens;

constructor TDACTreeView.Create(AOwner: TComponent);
var Metrics: TDACDBTreeTokens;
begin
  inherited;
  ControlStyle := ControlStyle + [csOpaque,csCaptureMouse];
  StyleElements := [];
  Metrics := TDACDBTreeTokens.Resolve(TDACComponentStyle.Tokens.Controls);
  Width := Metrics.DefaultWidth;
  Height := Metrics.DefaultHeight;
  ParentFont := False;
  Font.Name := TDACComponentStyle.FontFamily;
  Font.PixelsPerInch := 96;
  Font.Size := Metrics.FontSize;
  TabStop := True;
  ShowHint := True;
  FHoverRow := -1;
  FSelectedKey := Null;
  FRestoreKey := Null;
  FModel := TDACTreeModel<TDACTreeModelNode>.Create;
  FHistory := TDictionary<string,TDACTreeSavedState>.Create;
  FItems := TDACTreeItems.Create(Self);
  FColumns := TDACTreeColumns.Create(Self);
  with FColumns.Add do begin Caption := 'Item'; Width := 320; end;
  FRootValues := TDACTreeRoots.Create(Self);
  FItems.RootValues := FRootValues;
  FShowHeader := True;
  FPainter := TDACTreePainter.Create;
  FPainter.ShowCheckBoxes := False;
  FValid := True;
  FItems.OnChanged := ItemsChanged;
  FColumns.OnChange := ConfigurationChanged;
  FRootValues.OnChange := ConfigurationChanged;
  TDACThemeManager.RegisterListener(Self,ThemeChanged);
end;

destructor TDACTreeView.Destroy;
begin
  FDestroying := True;
  TDACThemeManager.UnregisterListener(Self);
  FItems.OnChanged := nil;
  FColumns.OnChange := nil;
  FRootValues.OnChange := nil;
  FItems.Free;
  FColumns.Free;
  FRootValues.Free;
  FModel.Free;
  FPainter.Free;
  FHistory.Free;
  inherited;
end;

procedure TDACTreeView.Loaded;
begin inherited; Refresh; end;
procedure TDACTreeView.SetItems(Value: TDACTreeItems);
begin if Value <> FItems then FItems.Assign(Value); end;
procedure TDACTreeView.SetColumns(Value: TDACTreeColumns);
begin if Value <> FColumns then FColumns.Assign(Value); end;
procedure TDACTreeView.SetRootValues(Value: TDACTreeRoots);
begin if Value <> FRootValues then FRootValues.Assign(Value); end;
procedure TDACTreeView.SetShowHeader(Value: Boolean);
begin
  if FShowHeader = Value then Exit;
  FShowHeader := Value;
  FPainter.ShowHeader := Value;
  FHoverRow := -1;
  FDragKind := thNone;
  ClampScroll;
  EnsureCurrentVisible;
  Invalidate;
end;

procedure TDACTreeView.SetReadOnly(Value: Boolean);
begin FReadOnly := Value; Invalidate; end;
procedure TDACTreeView.SetShowCheckBoxes(Value: Boolean);
begin FShowCheckBoxes := Value; FPainter.ShowCheckBoxes := Value; Invalidate; end;
procedure TDACTreeView.SetThemeMode(Value: TDACThemeMode);
begin FThemeMode := Value; Invalidate; end;
procedure TDACTreeView.ThemeChanged(Sender: TObject);
begin Invalidate; end;
procedure TDACTreeView.ConfigurationChanged(Sender: TObject);
begin Inc(FRevision); FDirty := True; Refresh; end;
procedure TDACTreeView.BeginUpdate;
begin Inc(FUpdateCount); end;
procedure TDACTreeView.EndUpdate;
begin
  if FUpdateCount = 0 then raise EInvalidOperation.Create('Unbalanced TreeView.EndUpdate');
  Dec(FUpdateCount);
  if FUpdateCount = 0 then if FDirty then Refresh else RebuildProjection;
end;

procedure TDACTreeView.SetNodeValues(Node: TDACTreeModelNode;
  const Data: TDACTreeItemData; DataObject: TObject);
var I: Integer;
begin
  Node.Key := Data.Key;
  Node.ParentKey := Data.ParentKey;
  Node.Token := TreeKeyToken(Data.Key,tkkAuto);
  if FRootValues.Matches(Data.ParentKey,tkkAuto) then Node.ParentToken := ''
  else Node.ParentToken := TreeKeyToken(Data.ParentKey,tkkAuto);
  SetLength(Node.Cells,Length(Data.SubItems)+1);
  Node.Cells[0] := Data.Text;
  Node.SearchText := Data.Text;
  for I := 0 to High(Data.SubItems) do
  begin
    Node.Cells[I+1] := Data.SubItems[I];
    Node.SearchText := Node.SearchText + #0 + Data.SubItems[I];
  end;
  Node.Checked := Data.Checked;
  Node.Checkable := Data.Checkable;
  Node.DataObject := DataObject;
end;
procedure TDACTreeView.ReadItem(Node: TDACTreeModelNode; Item: TDACTreeItem);
var Data: TDACTreeItemData; I: Integer;
begin
  Inc(FDataReadCount);
  Data.Key := Item.Key;
  Data.ParentKey := Item.ParentKey;
  Data.Text := Item.Text;
  Data.Checked := Item.Checked;
  Data.Checkable := Item.Checkable;
  SetLength(Data.SubItems,Item.SubItems.Count);
  for I := 0 to Item.SubItems.Count-1 do Data.SubItems[I] := Item.SubItems[I];
  SetNodeValues(Node,Data,Item.DataObject);
  Node.Expanded := Item.Expanded;
end;
procedure TDACTreeView.SaveHistory;
var N: TDACTreeModelNode; S: TDACTreeSavedState;
begin
  if not FValid then Exit;
  FHistory.Clear;
  for N in FModel.Nodes do
  begin
    S.Checked := N.Checked; S.Expanded := N.Expanded;
    FHistory.AddOrSetValue(N.Token,S);
  end;
  FRestoreKey := FSelectedKey;
end;
procedure TDACTreeView.ReportError(const Key: Variant; const MessageText: string);
var StableKey: Variant;
begin
  StableKey := Key;
  FLastError := MessageText;
  Invalidate;
  if not FDestroying and Assigned(FOnDataError) then FOnDataError(Self,StableKey,MessageText);
end;
procedure TDACTreeView.RejectData(const Key: Variant; const MessageText: string);
var StableKey: Variant;
begin
  StableKey := Key;
  SaveHistory;
  Inc(FLock);
  try FItems.Clear; finally Dec(FLock); end;
  FModel.Clear;
  FValid := False;
  FDirty := False;
  Inc(FRevision);
  FTopRow := 0;
  FHoverRow := -1;
  ChangeCurrent(Null,tcrReset);
  ReportError(StableKey,MessageText);
end;

procedure TDACTreeView.PublishModel(var Candidate: TDACTreeModel<TDACTreeModelNode>;
  const CurrentKey: Variant; Reason: TDACTreeChangeReason);
type TChange = record Key: Variant; DataObject: TObject; Checked: Boolean; Reason: TDACTreeChangeReason; end;
var Old: TDACTreeModel<TDACTreeModelNode>; N, Previous: TDACTreeModelNode;
  Changes: TList<TChange>; C: TChange; Revision: Integer; StableKey: Variant;
begin
  StableKey := CurrentKey;
  Changes := TList<TChange>.Create;
  Old := FModel;
  try
    for N in Old.Nodes do
      if N.Checked and (Candidate.FindToken(N.Token) = nil) then
      begin C.Key := N.Key; C.DataObject := N.DataObject; C.Checked := False; C.Reason := tcrRemoved; Changes.Add(C); end;
    for N in Candidate.Nodes do
    begin
      Previous := Old.FindToken(N.Token);
      if ((Previous = nil) and N.Checked) or ((Previous <> nil) and (Previous.Checked <> N.Checked)) then
      begin C.Key := N.Key; C.DataObject := N.DataObject; C.Checked := N.Checked; C.Reason := Reason; Changes.Add(C); end;
    end;
    FModel := Candidate;
    Candidate := nil;
    Old.Free;
    FValid := True;
    FDirty := False;
    FLastError := '';
    Inc(FLoadCount);
    Inc(FRevision);
    Revision := FRevision;
    ClampScroll;
    ChangeCurrent(StableKey,Reason);
    if Revision <> FRevision then Exit;
    SaveHistory;
    for C in Changes do
    begin
      if Assigned(FOnCheckChanged) then FOnCheckChanged(Self,C.Key,C.DataObject,C.Checked,C.Reason);
      if Revision <> FRevision then Break;
    end;
    Invalidate;
  finally Changes.Free; Candidate.Free; end;
end;

procedure TDACTreeView.Refresh;
var Candidate: TDACTreeModel<TDACTreeModelNode>; N: TDACTreeModelNode;
  I: Integer; ErrorText: string; ErrorKey, Current: Variant;
begin
  if FDestroying or (FLock > 0) or (FUpdateCount > 0) or
    (csLoading in ComponentState) then begin FDirty := True; Exit; end;
  Candidate := TDACTreeModel<TDACTreeModelNode>.Create;
  ErrorText := '';
  ErrorKey := Null;
  Current := FSelectedKey;
  SaveHistory;
  try
    try
      FRootValues.Validate(tkkAuto);
      for I := 0 to FItems.Count-1 do
      begin
        N := TDACTreeModelNode.Create;
        try
          ReadItem(N,FItems[I]);
          Candidate.Add(N); N := nil;
        finally N.Free; end;
      end;
      Candidate.Validate;
      Candidate.BuildVisible(FSearchText);
    except on E: Exception do
      begin ErrorText := E.Message; if E is EDACTreeDataError then ErrorKey := EDACTreeDataError(E).Key; end;
    end;
    if ErrorText <> '' then begin RejectData(ErrorKey,ErrorText); Exit; end;
    PublishModel(Candidate,Current,tcrProgrammatic);
    Candidate := nil;
  finally Candidate.Free; end;
end;

procedure TDACTreeView.ItemsChanged(Sender: TObject; Item: TDACTreeItem; Structural: Boolean);
var N: TDACTreeModelNode; WasChecked, NewChecked: Boolean;
  StableKey: Variant; Obj: TObject; Revision: Integer; Token: string;
begin
  Inc(FRevision);
  if FDestroying or (FLock > 0) then Exit;
  FDirty := True;
  if (FUpdateCount > 0) or (csLoading in ComponentState) then Exit;
  if Structural or (Item = nil) or not FValid then begin Refresh; Exit; end;
  try
    N := FModel.Find(Item.Key);
    if N = nil then begin Refresh; Exit; end;
    WasChecked := N.Checked;
    StableKey := Item.Key;
    Obj := Item.DataObject;
    ReadItem(N,Item);
    NewChecked := N.Checked;
    Token := N.Token;
    FDirty := False;
    RebuildProjection;
    SaveHistory;
    Revision := FRevision;
    if FSelectedToken = Token then ChangeCurrent(StableKey,tcrProgrammatic);
    if Revision <> FRevision then Exit;
    if (WasChecked <> NewChecked) and Assigned(FOnCheckChanged) then
      FOnCheckChanged(Self,StableKey,Obj,NewChecked,tcrProgrammatic);
  except on E: Exception do RejectData(Null,E.Message); end;
end;

function TDACTreeView.LoadObjects<T>(const Objects: TObjectList<T>;
  const Mapper: TFunc<T,TDACTreeItemData>; PreserveState: Boolean): Boolean;
var Entries: TArray<TDACTreeObjectEntry>; I, Revision: Integer; ErrorText: string;
begin
  Result := False;
  if FLoadingData or FDestroying then Exit;
  Revision := FRevision;
  FLoadingData := True;
  ErrorText := '';
  try
    try
      if Objects <> nil then
      begin
        if not Assigned(Mapper) then raise EArgumentNilException.Create('Mapper');
        SetLength(Entries,Objects.Count);
        for I := 0 to Objects.Count-1 do
        begin
          if Objects[I] = nil then raise EArgumentNilException.Create('Object list contains nil');
          Entries[I].DataObject := TObject(Objects[I]);
          Entries[I].Data := Mapper(Objects[I]);
          if Revision <> FRevision then raise EInvalidOperation.Create('Tree changed during object mapping');
        end;
      end;
    except on E: Exception do ErrorText := E.Message; end;
  finally FLoadingData := False; end;
  if ErrorText <> '' then
  begin
    if Revision = FRevision then RejectData(Null,ErrorText) else ReportError(Null,ErrorText);
    Exit;
  end;
  Result := LoadEntries(Entries,PreserveState);
end;

function TDACTreeView.LoadEntries(const Entries: TArray<TDACTreeObjectEntry>;
  PreserveState: Boolean): Boolean;
var Candidate: TDACTreeModel<TDACTreeModelNode>; N: TDACTreeModelNode;
  S: TDACTreeSavedState; Item: TDACTreeItem; Current, ErrorKey: Variant;
  I,J: Integer; ErrorText: string;
begin
  Result := False;
  SaveHistory;
  Current := Null;
  if PreserveState then Current := FRestoreKey;
  Candidate := TDACTreeModel<TDACTreeModelNode>.Create;
  ErrorText := ''; ErrorKey := Null;
  try
    try
      FRootValues.Validate(tkkAuto);
      for I := 0 to High(Entries) do
      begin
        N := TDACTreeModelNode.Create;
        try
          Inc(FDataReadCount);
          SetNodeValues(N,Entries[I].Data,Entries[I].DataObject);
          if PreserveState and FHistory.TryGetValue(N.Token,S) then
          begin N.Checked := S.Checked; N.Expanded := S.Expanded; end;
          Candidate.Add(N); N := nil;
        finally N.Free; end;
      end;
      Candidate.Validate;
      Candidate.BuildVisible(FSearchText);
    except on E: Exception do
      begin ErrorText := E.Message; if E is EDACTreeDataError then ErrorKey := EDACTreeDataError(E).Key; end;
    end;
    if ErrorText <> '' then begin RejectData(ErrorKey,ErrorText); Exit; end;
    Inc(FLock);
    FItems.BeginUpdate;
    try
      FItems.Clear;
      for I := 0 to High(Entries) do
      begin
        N := Candidate.Nodes[I];
        Item := FItems.Add;
        Item.Key := N.Key;
        Item.ParentKey := N.ParentKey;
        Item.Text := Entries[I].Data.Text;
        for J := 0 to High(Entries[I].Data.SubItems) do Item.SubItems.Add(Entries[I].Data.SubItems[J]);
        Item.Checked := N.Checked;
        Item.Checkable := N.Checkable;
        Item.Expanded := N.Expanded;
        Item.DataObject := N.DataObject;
      end;
    finally FItems.EndUpdate; Dec(FLock); end;
    PublishModel(Candidate,Current,tcrProgrammatic);
    Candidate := nil;
    Result := FValid;
  finally Candidate.Free; end;
end;

procedure TDACTreeView.ChangeCurrent(const Key: Variant; Reason: TDACTreeChangeReason);
var N: TDACTreeModelNode; OldKey, StableKey: Variant; Token: string; Obj: TObject;
begin
  StableKey := Key;
  N := nil;
  if FValid and not VarIsNull(StableKey) and not VarIsEmpty(StableKey) then N := FModel.Find(StableKey);
  Token := ''; Obj := nil; StableKey := Null;
  if N <> nil then begin Token := N.Token; Obj := N.DataObject; StableKey := N.Key; end;
  if (Token = FSelectedToken) and (Obj = FSelectedObject) then Exit;
  OldKey := FSelectedKey;
  FSelectedKey := StableKey;
  FSelectedToken := Token;
  FSelectedObject := Obj;
  Invalidate;
  if not FDestroying and Assigned(FOnCurrentChanged) then FOnCurrentChanged(Self,OldKey,StableKey,Obj,Reason);
end;
function TDACTreeView.Navigate(const Key: Variant; Reason: TDACTreeChangeReason): Boolean;
var StableKey: Variant;
begin
  Result := False;
  if not FValid or FDirty then Exit;
  StableKey := Key;
  if not VarIsNull(StableKey) and not VarIsEmpty(StableKey) and (FModel.Find(StableKey) = nil) then Exit;
  ChangeCurrent(StableKey,Reason);
  EnsureCurrentVisible;
  Result := True;
end;
procedure TDACTreeView.SetSelectedKey(const Value: Variant);
begin Navigate(Value,tcrProgrammatic); end;
function TDACTreeView.GetSelectedItem: TDACTreeItem;
begin Result := nil; if FValid then Result := FItems.Find(FSelectedKey); end;
function TDACTreeView.GetCheckedKeys: TArray<Variant>;
var N: TDACTreeModelNode; Keys: TList<Variant>;
begin
  Keys := TList<Variant>.Create;
  try
    if FValid then for N in FModel.Nodes do if N.Checked then Keys.Add(N.Key);
    Result := Keys.ToArray;
  finally Keys.Free; end;
end;
function TDACTreeView.TrySetChecked(const Key: Variant; Checked: Boolean;
  Reason: TDACTreeChangeReason): Boolean;
var N: TDACTreeModelNode; Item: TDACTreeItem; StableKey: Variant; Obj: TObject;
  Revision: Integer; Allow: Boolean;
begin
  Result := False;
  if FChecking or not FValid or FDirty or FReadOnly or not Enabled then Exit;
  if (Reason = tcrUser) and not FShowCheckBoxes then Exit;
  StableKey := Key;
  N := FModel.Find(StableKey);
  if (N = nil) or not N.Checkable then Exit;
  if N.Checked = Checked then Exit(True);
  Obj := N.DataObject;
  Revision := FRevision;
  FChecking := True;
  try
    Allow := True;
    if Assigned(FOnBeforeCheckChange) then FOnBeforeCheckChange(Self,StableKey,Obj,Checked,Allow);
    if not Allow or (Revision <> FRevision) or not FValid or FReadOnly or not Enabled then Exit;
    N := FModel.Find(StableKey);
    Item := FItems.Find(StableKey);
    if (N = nil) or (Item = nil) or not Item.Checkable then Exit;
    Inc(FLock);
    try Item.Checked := Checked; N.Checked := Checked;
    finally Dec(FLock); end;
    SaveHistory;
    Result := True;
    Invalidate;
    if Assigned(FOnCheckChanged) then FOnCheckChanged(Self,StableKey,Obj,Checked,Reason);
  finally FChecking := False; end;
end;
procedure TDACTreeView.SetSearchText(const Value: string);
begin
  if FSearchText = Value then Exit;
  FSearchText := Value; FTopRow := 0; RebuildProjection;
end;
procedure TDACTreeView.RebuildProjection;
begin
  if FUpdateCount > 0 then Exit;
  FModel.BuildVisible(FSearchText); ClampScroll; Invalidate;
end;
procedure TDACTreeView.Expand(const Key: Variant);
var Item: TDACTreeItem;
begin Item := FItems.Find(Key); if Item <> nil then Item.Expanded := True; end;
procedure TDACTreeView.Collapse(const Key: Variant);
var Item: TDACTreeItem;
begin Item := FItems.Find(Key); if Item <> nil then Item.Expanded := False; end;
procedure TDACTreeView.ExpandAll;
var I: Integer;
begin
  Inc(FLock);
  try for I := 0 to FItems.Count-1 do FItems[I].Expanded := True;
  finally Dec(FLock); end;
  if (FUpdateCount > 0) or FDirty or not FValid or (FModel.Nodes.Count <> FItems.Count) then
  begin FDirty := True; Refresh; Exit; end;
  for I := 0 to FModel.Nodes.Count-1 do FModel.Nodes[I].Expanded := True;
  SaveHistory; RebuildProjection;
end;
procedure TDACTreeView.CollapseAll;
var I: Integer;
begin
  Inc(FLock);
  try for I := 0 to FItems.Count-1 do FItems[I].Expanded := False;
  finally Dec(FLock); end;
  if (FUpdateCount > 0) or FDirty or not FValid or (FModel.Nodes.Count <> FItems.Count) then
  begin FDirty := True; Refresh; Exit; end;
  for I := 0 to FModel.Nodes.Count-1 do FModel.Nodes[I].Expanded := False;
  SaveHistory; RebuildProjection;
end;

{ Shared painter; VCL input is routed exclusively through cached model rows. }

function TDACTreeView.EffectiveDpi: Integer;
begin
  Result := GetParentCurrentDpi;
  if Result <= 0 then Result := 96;
end;
procedure TDACTreeView.ClampScroll;
var L: TDACTreeLayout;
begin
  if FPainter = nil then Exit;
  L := FPainter.Layout(Width, Height, EffectiveDpi, FModel, FColumns, FTopRow, FHorizontalOffset);
  FTopRow := L.TopRow;
  FHorizontalOffset := L.HorizontalOffset;
end;
procedure TDACTreeView.EnsureCurrentVisible;
var N: TDACTreeModelNode; L: TDACTreeLayout;
begin
  if not FValid then Exit;
  N := FModel.FindToken(FSelectedToken);
  if (N = nil) or (N.VisibleIndex < 0) then Exit;
  L := FPainter.Layout(Width, Height, EffectiveDpi, FModel, FColumns, FTopRow, FHorizontalOffset);
  if N.VisibleIndex < FTopRow then FTopRow := N.VisibleIndex
  else if N.VisibleIndex >= FTopRow + L.PageRows then
    FTopRow := N.VisibleIndex - L.PageRows + 1;
  ClampScroll;
end;
procedure TDACTreeView.Resize;
begin inherited; ClampScroll; Invalidate; end;
procedure TDACTreeView.Paint;
var S: string;
begin
  S := FLastError;
  if FValid then S := '';
  if (S = '') and (csDesigning in ComponentState) and (FModel.Nodes.Count = 0) then
    S := 'TDACTreeView - configure Items or LoadObjects';
  FPainter.Paint(Canvas.Handle, ClientWidth, ClientHeight, EffectiveDpi,
    TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls,
    FModel, FColumns, FSelectedToken, FTopRow, FHorizontalOffset, FHoverRow,
    Focused, Enabled, FReadOnly, S, Font);
end;
procedure TDACTreeView.WMEraseBkgnd(var M: TWMEraseBkgnd);
begin M.Result := 1; end;
procedure TDACTreeView.DoEnter;
begin inherited; Invalidate; end;
procedure TDACTreeView.DoExit;
begin inherited; Invalidate; end;
procedure TDACTreeView.WMGetDlgCode(var M: TMessage);
begin
  inherited;
  M.Result := M.Result or DLGC_WANTARROWS;
  if (M.LParam <> 0) and (PMsg(M.LParam).wParam in [VK_RETURN, VK_SPACE]) and
    (GetKeyState(VK_CONTROL) >= 0) and (GetKeyState(VK_MENU) >= 0) and
    (GetKeyState(VK_SHIFT) >= 0) then
    M.Result := M.Result or DLGC_WANTMESSAGE;
end;
procedure TDACTreeView.ActivateCurrent;
var StableKey: Variant; Obj: TObject;
begin
  StableKey := FSelectedKey;
  Obj := FSelectedObject;
  if FValid and (FSelectedToken <> '') and Assigned(FOnActivateRecord) then
    FOnActivateRecord(Self, StableKey, Obj);
end;
procedure TDACTreeView.KeyDown(var Key: Word; Shift: TShiftState);
var N: TDACTreeModelNode; Row: Integer; K: Variant; L: TDACTreeLayout;
begin
  inherited;
  if (Key = 0) or (Shift <> []) or not FValid then Exit;
  N := FModel.FindToken(FSelectedToken);
  Row := -1;
  if N <> nil then Row := N.VisibleIndex;
  case Key of
    VK_UP, VK_DOWN, VK_HOME, VK_END, VK_PRIOR, VK_NEXT:
      begin
        if FModel.Visible.Count = 0 then Exit;
        L := FPainter.Layout(Width, Height, EffectiveDpi, FModel, FColumns, FTopRow, FHorizontalOffset);
        case Key of
          VK_UP: Dec(Row);
          VK_DOWN: Inc(Row);
          VK_HOME: Row := 0;
          VK_END: Row := FModel.Visible.Count - 1;
          VK_PRIOR: Dec(Row, L.PageRows);
          VK_NEXT: Inc(Row, L.PageRows);
        end;
        Row := EnsureRange(Row, 0, FModel.Visible.Count - 1);
        K := FModel.Nodes[FModel.Visible[Row]].Key;
        Navigate(K, tcrUser);
      end;
    VK_LEFT:
      if N <> nil then
        if N.EffectiveExpanded and (N.Children.Count > 0) then Collapse(N.Key)
        else if N.ParentIndex >= 0 then Navigate(FModel.Nodes[N.ParentIndex].Key, tcrUser);
    VK_RIGHT:
      if (N <> nil) and (N.Children.Count > 0) then
        if not N.EffectiveExpanded then Expand(N.Key)
        else if (Row >= 0) and (Row + 1 < FModel.Visible.Count) and
          (FModel.Nodes[FModel.Visible[Row + 1]].Depth > N.Depth) then
          Navigate(FModel.Nodes[FModel.Visible[Row + 1]].Key, tcrUser);
    VK_SPACE: if N <> nil then TrySetChecked(N.Key, not N.Checked, tcrUser);
    VK_RETURN: ActivateCurrent;
    else Exit;
  end;
  Key := 0;
  Invalidate;
end;
function TDACTreeView.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean;
begin
  if Shift <> [] then Exit(inherited DoMouseWheel(Shift, WheelDelta, MousePos));
  Inc(FWheelRemainder, WheelDelta);
  FTopRow := FTopRow - (FWheelRemainder div WHEEL_DELTA) * 3;
  FWheelRemainder := FWheelRemainder mod WHEEL_DELTA;
  ClampScroll;
  Invalidate;
  Result := True;
end;
procedure TDACTreeView.MouseDown(Button: TMouseButton; Shift: TShiftState; X,Y: Integer);
var H: TDACTreeHit; L: TDACTreeLayout; N: TDACTreeModelNode; K: Variant; B: Boolean;
begin
  inherited;
  if (Button <> mbLeft) or not Enabled then Exit;
  if CanFocus then SetFocus;
  H := FPainter.HitTest(X,Y,ClientWidth,ClientHeight,EffectiveDpi,FModel,FColumns,FTopRow,FHorizontalOffset);
  L := FPainter.Layout(ClientWidth,ClientHeight,EffectiveDpi,FModel,FColumns,FTopRow,FHorizontalOffset);
  case H.Kind of
    thVerticalTrack:
      if Y < L.VerticalThumb.Top then Dec(FTopRow,L.PageRows) else Inc(FTopRow,L.PageRows);
    thHorizontalTrack:
      if X < L.HorizontalThumb.Left then Dec(FHorizontalOffset,L.ContentRect.Width)
      else Inc(FHorizontalOffset,L.ContentRect.Width);
    thVerticalThumb,thHorizontalThumb:
      begin
        FDragKind := H.Kind;
        MouseCapture := True;
        if H.Kind = thVerticalThumb then begin FDragStart := Y; FDragOffset := FTopRow; end
        else begin FDragStart := X; FDragOffset := FHorizontalOffset; end;
      end;
    thRow,thCheck,thExpander:
      begin
        if not FValid or (H.NodeIndex < 0) then Exit;
        N := FModel.Nodes[H.NodeIndex];
        K := N.Key;
        B := N.Checked;
        case H.Kind of
          thRow: Navigate(K,tcrUser);
          thCheck: TrySetChecked(K,not B,tcrUser);
          thExpander: if N.EffectiveExpanded then Collapse(K) else Expand(K);
        end;
      end;
  end;
  ClampScroll;
  Invalidate;
end;
procedure TDACTreeView.MouseMove(Shift: TShiftState; X,Y: Integer);
var L: TDACTreeLayout; H: TDACTreeHit;
begin
  inherited;
  if not MouseCapture or not (ssLeft in Shift) then FDragKind := thNone;
  L := FPainter.Layout(ClientWidth,ClientHeight,EffectiveDpi,FModel,FColumns,FTopRow,FHorizontalOffset);
  case FDragKind of
    thVerticalThumb:
      FTopRow := FDragOffset + MulDiv(Y-FDragStart,L.MaxTopRow,
        Max(1,L.VerticalTrack.Height-L.VerticalThumb.Height));
    thHorizontalThumb:
      FHorizontalOffset := FDragOffset + MulDiv(X-FDragStart,L.MaxHorizontalOffset,
        Max(1,L.HorizontalTrack.Width-L.HorizontalThumb.Width));
    else
      begin
        H := FPainter.HitTest(X,Y,ClientWidth,ClientHeight,EffectiveDpi,FModel,FColumns,FTopRow,FHorizontalOffset);
        FHoverRow := H.VisibleRow;
      end;
  end;
  ClampScroll;
  Invalidate;
end;
procedure TDACTreeView.MouseUp(Button: TMouseButton; Shift: TShiftState; X,Y: Integer);
begin inherited; FDragKind := thNone; MouseCapture := False; end;
procedure TDACTreeView.WMCaptureChanged(var M: TMessage);
begin FDragKind := thNone; inherited; end;
procedure TDACTreeView.CMCancelMode(var M: TCMCancelMode);
begin FDragKind := thNone; MouseCapture := False; inherited; end;
procedure TDACTreeView.CMMouseLeave(var M: TMessage);
begin FHoverRow := -1; Invalidate; end;
procedure TDACTreeView.CMHintShow(var M: TCMHintShow);
var H: TDACTreeHit; N: TDACTreeModelNode;
begin
  inherited;
  H := FPainter.HitTest(M.HintInfo.CursorPos.X,M.HintInfo.CursorPos.Y,
    ClientWidth,ClientHeight,EffectiveDpi,FModel,FColumns,FTopRow,FHorizontalOffset);
  if (H.ColumnIndex < 0) or (H.ColumnIndex >= FColumns.Count) then Exit;
  if H.Kind = thHeader then M.HintInfo.HintStr := FColumns[H.ColumnIndex].TitleHint
  else if (H.NodeIndex >= 0) and (H.NodeIndex < FModel.Nodes.Count) then
  begin
    N := FModel.Nodes[H.NodeIndex];
    if FColumns[H.ColumnIndex].Hint <> '' then M.HintInfo.HintStr := FColumns[H.ColumnIndex].Hint
    else if H.ColumnIndex < Length(N.Cells) then M.HintInfo.HintStr := N.Cells[H.ColumnIndex];
  end;
  M.HintInfo.CursorRect := H.Bounds;
end;

end.
