unit DAC.Components.Controls.DBTreeView.Model;

interface

uses
  System.SysUtils, System.Classes, System.Generics.Collections, Data.DB,
  DAC.Components.Controls.DBTreeView.Types;

type
  TDACDBTreeNode = class
  public
    Key, ParentKey: Variant;
    Token, ParentToken: string;
    Index, ParentIndex, Depth, VisibleIndex: Integer;
    Children: TList<Integer>;
    Cells: TArray<string>;
    SearchText: string;
    Checked, Checkable, Expanded, FilterExpanded: Boolean;
    Bookmark: TBookmark;
    constructor Create;
    destructor Destroy; override;
    function EffectiveExpanded: Boolean;
  end;

  TDACDBTreeModel = class
  private
    FNodes: TObjectList<TDACDBTreeNode>;
    FRoots, FVisible: TList<Integer>;
    FIndex: TDictionary<string, Integer>;
    FKeyKind: TDACDBTreeKeyKind;
  public
    constructor Create(const AKeyKind: TDACDBTreeKeyKind = tkkText);
    destructor Destroy; override;
    procedure Clear;
    function Add(ANode: TDACDBTreeNode): Integer;
    procedure Validate;
    procedure BuildVisible(const ASearchText: string);
    function Find(const AKey: Variant): TDACDBTreeNode;
    function FindToken(const AToken: string): TDACDBTreeNode;
    property KeyKind: TDACDBTreeKeyKind read FKeyKind;
    property Nodes: TObjectList<TDACDBTreeNode> read FNodes;
    property Roots: TList<Integer> read FRoots;
    property Visible: TList<Integer> read FVisible;
  end;

implementation

uses System.Variants, System.StrUtils;

constructor TDACDBTreeNode.Create;
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

destructor TDACDBTreeNode.Destroy;
begin
  Children.Free;
  inherited;
end;

function TDACDBTreeNode.EffectiveExpanded: Boolean;
begin
  Result := Expanded or FilterExpanded;
end;

constructor TDACDBTreeModel.Create(const AKeyKind: TDACDBTreeKeyKind);
begin
  inherited Create;
  FKeyKind := AKeyKind;
  FNodes := TObjectList<TDACDBTreeNode>.Create(True);
  FIndex := TDictionary<string, Integer>.Create;
  FRoots := TList<Integer>.Create;
  FVisible := TList<Integer>.Create;
end;

destructor TDACDBTreeModel.Destroy;
begin
  FVisible.Free;
  FRoots.Free;
  FIndex.Free;
  FNodes.Free;
  inherited;
end;

procedure TDACDBTreeModel.Clear;
begin
  FVisible.Clear;
  FRoots.Clear;
  FIndex.Clear;
  FNodes.Clear;
end;

function TDACDBTreeModel.Add(ANode: TDACDBTreeNode): Integer;
begin
  if ANode = nil then
    raise EArgumentNilException.Create('ANode');
  if ANode.Token = '' then ANode.Token := DBTreeKeyToken(ANode.Key, FKeyKind);
  if FIndex.ContainsKey(ANode.Token) then
    raise EDACDBTreeDataError.CreateKey('Duplicate record key.', ANode.Key);
  Result := FNodes.Count;
  FIndex.Add(ANode.Token, Result);
  ANode.Index := Result;
  FNodes.Add(ANode);
end;

function TDACDBTreeModel.Find(const AKey: Variant): TDACDBTreeNode;
begin
  if VarIsNull(AKey) or VarIsEmpty(AKey) then Exit(nil);
  Result := FindToken(DBTreeKeyToken(AKey, FKeyKind));
end;

function TDACDBTreeModel.FindToken(const AToken: string): TDACDBTreeNode;
var LIndex: Integer;
begin
  if FIndex.TryGetValue(AToken, LIndex) then Result := FNodes[LIndex]
  else Result := nil;
end;

procedure TDACDBTreeModel.Validate;
var
  I, J, LCurrent, LParent: Integer;
  LColor: TArray<Byte>;
  LPath, LStack: TList<Integer>;
  LNode: TDACDBTreeNode;
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
        raise EDACDBTreeDataError.CreateKey('A record cannot be its own parent.', LNode.Key);
      if not FIndex.TryGetValue(LNode.ParentToken, LParent) then
        raise EDACDBTreeDataError.CreateKey('Parent record was not found.', LNode.Key);
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
          raise EDACDBTreeDataError.CreateKey('Cycle in parent relationships.', FNodes[LCurrent].Key);
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

procedure TDACDBTreeModel.BuildVisible(const ASearchText: string);
var
  I, J, LCurrent: Integer;
  LInclude: TArray<Boolean>;
  LStack: TList<Integer>;
  LNode: TDACDBTreeNode;
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
