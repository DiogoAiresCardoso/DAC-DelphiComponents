unit DAC.Components.Controls.DBTreeView.Roots;

interface

uses System.Classes, System.Variants, System.Generics.Collections,
  DAC.Components.Controls.DBTreeView.Types;

type
  TDACDBTreeRootKind = (trkNull, trkEmptyString, trkValue);
  TDACDBTreeRoot = class(TCollectionItem)
  private
    FKind: TDACDBTreeRootKind;
    FValue: Variant;
    procedure SetKind(const AValue: TDACDBTreeRootKind);
    procedure SetValue(const AValue: Variant);
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
  published
    property Kind: TDACDBTreeRootKind read FKind write SetKind default trkNull;
    property Value: Variant read FValue write SetValue;
  end;

  TDACDBTreeRoots = class(TOwnedCollection)
  private
    FOnChange: TNotifyEvent;
    FNotifying: Boolean;
    FCompiled, FNullRoot, FEmptyRoot: Boolean;
    FCompiledKind: TDACDBTreeKeyKind;
    FTokens: TDictionary<string, Byte>;
    function GetItem(const AIndex: Integer): TDACDBTreeRoot;
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent);
    destructor Destroy; override;
    function Add: TDACDBTreeRoot;
    function Matches(const AValue: Variant; const AKind: TDACDBTreeKeyKind): Boolean;
    procedure Validate(const AKind: TDACDBTreeKeyKind);
    property Items[const AIndex: Integer]: TDACDBTreeRoot read GetItem; default;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

implementation

constructor TDACDBTreeRoot.Create(Collection: TCollection);
begin
  inherited;
  FValue := Null;
end;

procedure TDACDBTreeRoot.Assign(Source: TPersistent);
begin
  if Source is TDACDBTreeRoot then
  begin
    FKind := TDACDBTreeRoot(Source).FKind;
    FValue := TDACDBTreeRoot(Source).FValue;
    Changed(False);
  end
  else inherited;
end;

procedure TDACDBTreeRoot.SetKind(const AValue: TDACDBTreeRootKind);
begin
  if FKind = AValue then Exit;
  FKind := AValue;
  Changed(False);
end;

procedure TDACDBTreeRoot.SetValue(const AValue: Variant);
begin
  if VarSameValue(FValue, AValue) and (VarType(FValue) = VarType(AValue)) then Exit;
  FValue := AValue;
  Changed(False);
end;

constructor TDACDBTreeRoots.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TDACDBTreeRoot);
  FTokens := TDictionary<string, Byte>.Create;
  BeginUpdate;
  try
    Add.Kind := trkNull;
    Add.Kind := trkEmptyString;
  finally EndUpdate; end;
end;

destructor TDACDBTreeRoots.Destroy;
begin
  FOnChange := nil;
  FTokens.Free;
  inherited;
end;

function TDACDBTreeRoots.Add: TDACDBTreeRoot;
begin
  Result := TDACDBTreeRoot(inherited Add);
end;

function TDACDBTreeRoots.GetItem(const AIndex: Integer): TDACDBTreeRoot;
begin
  Result := TDACDBTreeRoot(inherited Items[AIndex]);
end;

procedure TDACDBTreeRoots.Update(Item: TCollectionItem);
begin
  FCompiled := False;
  inherited;
  if FNotifying then Exit;
  FNotifying := True;
  try
    if Assigned(FOnChange) then FOnChange(Self);
  finally FNotifying := False; end;
end;

procedure TDACDBTreeRoots.Validate(const AKind: TDACDBTreeKeyKind);
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
      trkValue: FTokens.AddOrSetValue(DBTreeKeyToken(Items[I].Value, AKind), 0);
    end;
  FCompiledKind := AKind;
  FCompiled := True;
end;

function TDACDBTreeRoots.Matches(const AValue: Variant;
  const AKind: TDACDBTreeKeyKind): Boolean;
begin
  Validate(AKind);
  if VarIsNull(AValue) then Exit(FNullRoot);
  if VarIsEmpty(AValue) then Exit(False);
  if FEmptyRoot and (AKind = tkkText) and VarIsStr(AValue) and
    (string(AValue) = '') then Exit(True);
  Result := FTokens.ContainsKey(DBTreeKeyToken(AValue, AKind));
end;

end.
