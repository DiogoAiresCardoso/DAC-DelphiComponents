unit DAC.Components.Controls.TreeView.Items;

interface

uses System.Classes, System.SysUtils, System.Variants,
  System.Generics.Collections,
  DAC.Components.Controls.TreeView.Item, DAC.Components.Controls.TreeView.Roots;

type
  TDACTreeItemsChangedEvent = procedure(Sender: TObject; Item: TDACTreeItem;
    Structural: Boolean) of object;
  TDACTreeItems = class(TOwnedCollection)
  private
    FOnChanged: TDACTreeItemsChangedEvent;
    FIndex: TDictionary<string,TDACTreeItem>;
    FIndexDirty, FDestroying: Boolean;
    FRootValues: TDACTreeRoots;
    function GetItem(Index: Integer): TDACTreeItem;
    procedure BuildIndex;
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(Owner: TPersistent);
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function Add: TDACTreeItem; overload;
    function Add(Sibling: TDACTreeItem; const Text: string): TDACTreeItem; overload;
    function AddChild(Parent: TDACTreeItem; const Text: string): TDACTreeItem;
    procedure Delete(Item: TDACTreeItem); reintroduce;
    function Find(const Key: Variant): TDACTreeItem;
    function ParentOf(Item: TDACTreeItem): TDACTreeItem;
    function IsRoot(Item: TDACTreeItem): Boolean;
    property RootValues: TDACTreeRoots read FRootValues write FRootValues;
    property Items[Index: Integer]: TDACTreeItem read GetItem; default;
    property OnChanged: TDACTreeItemsChangedEvent read FOnChanged write FOnChanged;
  end;

implementation

uses DAC.Components.Controls.TreeView.Types;

constructor TDACTreeItems.Create(Owner: TPersistent);
begin
  FIndex := TDictionary<string,TDACTreeItem>.Create;
  FIndexDirty := True;
  inherited Create(Owner,TDACTreeItem);
end;
destructor TDACTreeItems.Destroy;
begin
  FDestroying := True;
  FOnChanged := nil;
  inherited;
  FIndex.Free;
end;
procedure TDACTreeItems.Assign(Source: TPersistent);
begin if Source <> Self then inherited; end;
procedure TDACTreeItems.Update(Item: TCollectionItem);
var Structural: Boolean;
begin
  inherited;
  if FDestroying then Exit;
  Structural := (Item = nil) or TDACTreeItem(Item).StructuralChange;
  if Structural then FIndexDirty := True;
  if Assigned(FOnChanged) then FOnChanged(Self,TDACTreeItem(Item),Structural);
end;
function TDACTreeItems.GetItem(Index: Integer): TDACTreeItem;
begin Result := TDACTreeItem(inherited Items[Index]); end;
function TDACTreeItems.Add: TDACTreeItem;
begin Result := TDACTreeItem(inherited Add); end;
function TDACTreeItems.Add(Sibling: TDACTreeItem; const Text: string): TDACTreeItem;
begin
  if (Sibling <> nil) and (Sibling.Collection <> Self) then
    raise EArgumentException.Create('Sibling belongs to another tree');
  BeginUpdate;
  try
    Result := Add;
    if Sibling <> nil then Result.ParentKey := Sibling.ParentKey;
    Result.Text := Text;
  finally EndUpdate; end;
end;
function TDACTreeItems.AddChild(Parent: TDACTreeItem; const Text: string): TDACTreeItem;
begin
  if (Parent <> nil) and (Parent.Collection <> Self) then
    raise EArgumentException.Create('Parent belongs to another tree');
  BeginUpdate;
  try
    Result := Add;
    if Parent <> nil then Result.ParentKey := Parent.Key;
    Result.Text := Text;
  finally EndUpdate; end;
end;
procedure TDACTreeItems.BuildIndex;
var I: Integer; Token: string;
begin
  FIndex.Clear;
  for I := 0 to Count-1 do
  begin
    Token := TreeKeyToken(Items[I].Key,tkkAuto);
    if not FIndex.ContainsKey(Token) then FIndex.Add(Token,Items[I]);
  end;
  FIndexDirty := False;
end;
function TDACTreeItems.Find(const Key: Variant): TDACTreeItem;
begin
  Result := nil;
  if VarIsEmpty(Key) or VarIsNull(Key) then Exit;
  if FIndexDirty then BuildIndex;
  FIndex.TryGetValue(TreeKeyToken(Key,tkkAuto),Result);
end;
function TDACTreeItems.IsRoot(Item: TDACTreeItem): Boolean;
begin
  if FRootValues <> nil then Result := FRootValues.Matches(Item.ParentKey,tkkAuto)
  else Result := VarIsNull(Item.ParentKey) or VarIsEmpty(Item.ParentKey) or
    (VarIsStr(Item.ParentKey) and (VarToStr(Item.ParentKey) = ''));
end;
function TDACTreeItems.ParentOf(Item: TDACTreeItem): TDACTreeItem;
begin
  Result := nil;
  if (Item <> nil) and not IsRoot(Item) then Result := Find(Item.ParentKey);
end;
procedure TDACTreeItems.Delete(Item: TDACTreeItem);
var Children: TDictionary<string,TList<TDACTreeItem>>;
  Lists: TObjectList<TList<TDACTreeItem>>;
  Stack, L: TList<TDACTreeItem>; N: TDACTreeItem;
  I,J: Integer; Token: string;
  Seen: TDictionary<TDACTreeItem,Byte>;
begin
  if Item = nil then Exit;
  if Item.Collection <> Self then raise EArgumentException.Create('Item belongs to another tree');
  Children := TDictionary<string,TList<TDACTreeItem>>.Create;
  Lists := TObjectList<TList<TDACTreeItem>>.Create(True);
  Stack := TList<TDACTreeItem>.Create;
  Seen := TDictionary<TDACTreeItem,Byte>.Create;
  try
    for I := 0 to Count-1 do
      if not IsRoot(Items[I]) then
      begin
        Token := TreeKeyToken(Items[I].ParentKey,tkkAuto);
        if not Children.TryGetValue(Token,L) then
        begin L := TList<TDACTreeItem>.Create; Lists.Add(L); Children.Add(Token,L); end;
        L.Add(Items[I]);
      end;
    Stack.Add(Item);
    while Stack.Count > 0 do
    begin
      N := Stack.Last; Stack.Delete(Stack.Count-1);
      if Seen.ContainsKey(N) then Continue;
      Seen.Add(N,0);
      if Children.TryGetValue(TreeKeyToken(N.Key,tkkAuto),L) then
        for J := 0 to L.Count-1 do Stack.Add(L[J]);
    end;
    BeginUpdate;
    { Walk actual collection positions rather than Item.Index: its getter
      performs a linear search. Tail-first removal also uses VCL's fast path. }
    try for I := Count-1 downto 0 do
      if Seen.ContainsKey(Items[I]) then Items[I].Free;
    finally EndUpdate; end;
  finally Seen.Free; Stack.Free; Lists.Free; Children.Free; end;
end;

end.
