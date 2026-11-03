unit DAC.Components.Controls.TreeView.Roots;

interface

uses System.Classes, System.Variants, System.Generics.Collections,
  DAC.Components.Controls.TreeView.Types;

type
  TDACTreeRootKind = (trkNull, trkEmptyString, trkValue);
  TDACTreeRoot = class(TCollectionItem)
  private
    FKind: TDACTreeRootKind;
    FValue: Variant;
    procedure SetKind(const AValue: TDACTreeRootKind);
    procedure SetValue(const AValue: Variant);
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
  published
    property Kind: TDACTreeRootKind read FKind write SetKind default trkNull;
    property Value: Variant read FValue write SetValue;
  end;

  TDACTreeRoots = class(TOwnedCollection)
  private
    FOnChange: TNotifyEvent;
    FNotifying: Boolean;
    FCompiled, FNullRoot, FEmptyRoot: Boolean;
    FCompiledKind: TDACTreeKeyKind;
    FTokens: TDictionary<string, Byte>;
    function GetItem(const AIndex: Integer): TDACTreeRoot;
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent; AItemClass: TCollectionItemClass = nil);
    destructor Destroy; override;
    function Add: TDACTreeRoot;
    function Matches(const AValue: Variant; const AKind: TDACTreeKeyKind): Boolean;
    procedure Validate(const AKind: TDACTreeKeyKind);
    property Items[const AIndex: Integer]: TDACTreeRoot read GetItem; default;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

implementation

constructor TDACTreeRoot.Create(Collection: TCollection);
begin
  inherited;
  FValue := Null;
end;

procedure TDACTreeRoot.Assign(Source: TPersistent);
begin
  if Source is TDACTreeRoot then
  begin
    FKind := TDACTreeRoot(Source).FKind;
    FValue := TDACTreeRoot(Source).FValue;
    Changed(False);
  end
  else inherited;
end;

procedure TDACTreeRoot.SetKind(const AValue: TDACTreeRootKind);
begin
  if FKind = AValue then Exit;
  FKind := AValue;
  Changed(False);
end;

procedure TDACTreeRoot.SetValue(const AValue: Variant);
begin
  if VarSameValue(FValue, AValue) and (VarType(FValue) = VarType(AValue)) then Exit;
  FValue := AValue;
  Changed(False);
end;

constructor TDACTreeRoots.Create(AOwner: TPersistent; AItemClass: TCollectionItemClass);
begin
  if AItemClass = nil then AItemClass := TDACTreeRoot;
  inherited Create(AOwner, AItemClass);
  FTokens := TDictionary<string, Byte>.Create;
  BeginUpdate;
  try
    Add.Kind := trkNull;
    Add.Kind := trkEmptyString;
  finally EndUpdate; end;
end;

destructor TDACTreeRoots.Destroy;
begin
  FOnChange := nil;
  FTokens.Free;
  inherited;
end;

function TDACTreeRoots.Add: TDACTreeRoot;
begin
  Result := TDACTreeRoot(inherited Add);
end;

function TDACTreeRoots.GetItem(const AIndex: Integer): TDACTreeRoot;
begin
  Result := TDACTreeRoot(inherited Items[AIndex]);
end;

procedure TDACTreeRoots.Update(Item: TCollectionItem);
begin
  FCompiled := False;
  inherited;
  if FNotifying then Exit;
  FNotifying := True;
  try
    if Assigned(FOnChange) then FOnChange(Self);
  finally FNotifying := False; end;
end;

procedure TDACTreeRoots.Validate(const AKind: TDACTreeKeyKind);
var I: Integer;
begin
  if FCompiled and (FCompiledKind = AKind) then Exit;
  FCompiled := False;
  FTokens.Clear;
  FNullRoot := False;
  FEmptyRoot := False;
  for I := 0 to Count - 1 do
    case Items[I].Kind of
      trkNull: FNullRoot := True;
      trkEmptyString: FEmptyRoot := True;
      trkValue: FTokens.AddOrSetValue(TreeKeyToken(Items[I].Value, AKind), 0);
    end;
  FCompiledKind := AKind;
  FCompiled := True;
end;

function TDACTreeRoots.Matches(const AValue: Variant;
  const AKind: TDACTreeKeyKind): Boolean;
begin
  Validate(AKind);
  if VarIsNull(AValue) then Exit(FNullRoot);
  if VarIsEmpty(AValue) then Exit(False);
  if FEmptyRoot and (AKind in [tkkText, tkkAuto]) and VarIsStr(AValue) and
    (string(AValue) = '') then Exit(True);
  Result := FTokens.ContainsKey(TreeKeyToken(AValue, AKind));
end;

end.
