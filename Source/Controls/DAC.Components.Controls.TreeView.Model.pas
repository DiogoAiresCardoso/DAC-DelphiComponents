unit DAC.Components.Controls.TreeView.Model;

interface
uses System.SysUtils, System.Classes, System.Generics.Collections,
  DAC.Components.Controls.TreeView.Types;
type
  TDACTreeModelNode = class
  public
    Key, ParentKey: Variant;
    Token, ParentToken: string;
    Index, ParentIndex, Depth, VisibleIndex: Integer;
    Children: TList<Integer>;
    Cells: TArray<string>;
    SearchText: string;
    Checked, Checkable, Expanded, FilterExpanded: Boolean;
    DataObject: TObject;
    constructor Create;
    destructor Destroy; override;
    function EffectiveExpanded: Boolean;
  end;


  TDACTreeModelBase = class
  protected
    FRoots, FVisible: TList<Integer>;
    function GetNodeCount: Integer; virtual; abstract;
  public
    constructor Create;
    destructor Destroy; override;
    function Node(const Index: Integer): TDACTreeModelNode; virtual; abstract;
    property NodeCount: Integer read GetNodeCount;
    property Roots: TList<Integer> read FRoots;
    property Visible: TList<Integer> read FVisible;
  end;

  TDACTreeModel<T: TDACTreeModelNode> = class(TDACTreeModelBase)
  private
    FNodes: TObjectList<T>;
    FIndex: TDictionary<string, Integer>;
    FKeyKind: TDACTreeKeyKind;
  protected
    function GetNodeCount: Integer; override;
  public
    constructor Create(const AKeyKind: TDACTreeKeyKind = tkkAuto);
    destructor Destroy; override;
    procedure Clear;
    function Add(ANode: T): Integer;
    procedure Validate;
    procedure BuildVisible(const ASearchText: string);
    function Find(const AKey: Variant): T;
    function FindToken(const AToken: string): T;
    function Node(const Index: Integer): TDACTreeModelNode; override;
    property KeyKind: TDACTreeKeyKind read FKeyKind;
    property Nodes: TObjectList<T> read FNodes;
  end;
implementation
uses System.Variants, System.StrUtils;

constructor TDACTreeModelBase.Create;
begin
  inherited;
  FRoots := TList<Integer>.Create;
  FVisible := TList<Integer>.Create;
end;
destructor TDACTreeModelBase.Destroy;
begin FVisible.Free; FRoots.Free; inherited; end;
function TDACTreeModel<T>.GetNodeCount: Integer;
begin Result := FNodes.Count; end;
function TDACTreeModel<T>.Node(const Index: Integer): TDACTreeModelNode;
begin Result := FNodes[Index]; end;

constructor TDACTreeModelNode.Create;
begin
  inherited;
  Key := Null;
  ParentKey := Null;
  ParentIndex := -1;
  Index := -1;
  VisibleIndex := -1;
  Children := TList<Integer>.Create;
  Checkable := True;
end;

destructor TDACTreeModelNode.Destroy;
begin
  Children.Free;
  inherited;
end;

function TDACTreeModelNode.EffectiveExpanded: Boolean;
begin
  Result := Expanded or FilterExpanded;
end;

constructor TDACTreeModel<T>.Create(const AKeyKind: TDACTreeKeyKind);
begin
  inherited Create;
  FKeyKind := AKeyKind;
  FNodes := TObjectList<T>.Create(True);
  FIndex := TDictionary<string, Integer>.Create;

end;

destructor TDACTreeModel<T>.Destroy;
begin
  FIndex.Free;
  FNodes.Free;
  inherited;
end;

procedure TDACTreeModel<T>.Clear;
begin
  FVisible.Clear;
  FRoots.Clear;
  FIndex.Clear;
  FNodes.Clear;
end;

function TDACTreeModel<T>.Add(ANode: T): Integer;
begin
  if ANode = nil then
    raise EArgumentNilException.Create('ANode');
  if ANode.Token = '' then ANode.Token := TreeKeyToken(ANode.Key, FKeyKind);
  if FIndex.ContainsKey(ANode.Token) then
    raise EDACTreeDataError.CreateKey('Duplicate record key.', ANode.Key);
  Result := FNodes.Count;
  FIndex.Add(ANode.Token, Result);
  ANode.Index := Result;
  FNodes.Add(ANode);
end;

function TDACTreeModel<T>.Find(const AKey: Variant): T;
begin
  if VarIsNull(AKey) or VarIsEmpty(AKey) then Exit(nil);
  Result := FindToken(TreeKeyToken(AKey, FKeyKind));
end;

function TDACTreeModel<T>.FindToken(const AToken: string): T;
var LIndex: Integer;
begin
  if FIndex.TryGetValue(AToken, LIndex) then Result := FNodes[LIndex]
  else Result := nil;
end;

procedure TDACTreeModel<T>.Validate;
var
  I, J, LCurrent, LParent: Integer;
  LColor: TArray<Byte>;
  LPath, LStack: TList<Integer>;
  LNode: TDACTreeModelNode;
begin
  FRoots.Clear;
  FVisible.Clear;
  for I := 0 to FNodes.Count - 1 do
  begin
    FNodes[I].Children.Clear;
    FNodes[I].ParentIndex := -1;
    FNodes[I].VisibleIndex := -1;
    FNodes[I].Depth := 0;
  end;
  for I := 0 to FNodes.Count - 1 do
  begin
    LNode := FNodes[I];
    if LNode.ParentToken = '' then
      FRoots.Add(I)
    else
    begin
      if LNode.ParentToken = LNode.Token then
        raise EDACTreeDataError.CreateKey('A record cannot be its own parent.', LNode.Key);
      if not FIndex.TryGetValue(LNode.ParentToken, LParent) then
        raise EDACTreeDataError.CreateKey('Parent record was not found.', LNode.Key);
      LNode.ParentIndex := LParent;
      FNodes[LParent].Children.Add(I);
    end;
  end;
  SetLength(LColor, FNodes.Count);
  LPath := TList<Integer>.Create;
  LStack := TList<Integer>.Create;
  try
    for I := 0 to FNodes.Count - 1 do
      if LColor[I] = 0 then
      begin
        LPath.Clear;
        LCurrent := I;
        while (LCurrent >= 0) and (LColor[LCurrent] = 0) do
        begin
          LColor[LCurrent] := 1;
          LPath.Add(LCurrent);
          LCurrent := FNodes[LCurrent].ParentIndex;
        end;
        if (LCurrent >= 0) and (LColor[LCurrent] = 1) then
          raise EDACTreeDataError.CreateKey('Cycle in parent relationships.', FNodes[LCurrent].Key);
        for J := 0 to LPath.Count - 1 do LColor[LPath[J]] := 2;
      end;
    for I := FRoots.Count - 1 downto 0 do LStack.Add(FRoots[I]);
    while LStack.Count > 0 do
    begin
      LCurrent := LStack.Last;
      LStack.Delete(LStack.Count - 1);
      LNode := FNodes[LCurrent];
      for J := LNode.Children.Count - 1 downto 0 do
      begin
        FNodes[LNode.Children[J]].Depth := LNode.Depth + 1;
        LStack.Add(LNode.Children[J]);
      end;
    end;
  finally
    LStack.Free;
    LPath.Free;
  end;
end;

procedure TDACTreeModel<T>.BuildVisible(const ASearchText: string);
var
  I, J, LCurrent: Integer;
  LInclude: TArray<Boolean>;
  LStack: TList<Integer>;
  LNode: TDACTreeModelNode;
  LSearching: Boolean;
begin
  FVisible.Clear;
  LSearching := ASearchText <> '';
  SetLength(LInclude, FNodes.Count);
  for I := 0 to FNodes.Count - 1 do
  begin
    FNodes[I].VisibleIndex := -1;
    FNodes[I].FilterExpanded := False;
  end;
  if LSearching then
    for I := 0 to FNodes.Count - 1 do
      if ContainsText(FNodes[I].SearchText, ASearchText) then
      begin
        LCurrent := I;
        while (LCurrent >= 0) and not LInclude[LCurrent] do
        begin
          LInclude[LCurrent] := True;
          LCurrent := FNodes[LCurrent].ParentIndex;
          if LCurrent >= 0 then FNodes[LCurrent].FilterExpanded := True;
        end;
      end;
  LStack := TList<Integer>.Create;
  try
    for I := FRoots.Count - 1 downto 0 do LStack.Add(FRoots[I]);
    while LStack.Count > 0 do
    begin
      LCurrent := LStack.Last;
      LStack.Delete(LStack.Count - 1);
      if LSearching and not LInclude[LCurrent] then Continue;
      LNode := FNodes[LCurrent];
      LNode.VisibleIndex := FVisible.Count;
      FVisible.Add(LCurrent);
      if LNode.EffectiveExpanded then
        for J := LNode.Children.Count - 1 downto 0 do LStack.Add(LNode.Children[J]);
    end;
  finally LStack.Free; end;
end;

end.
