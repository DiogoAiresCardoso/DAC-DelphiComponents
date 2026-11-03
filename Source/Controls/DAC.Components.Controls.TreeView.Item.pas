unit DAC.Components.Controls.TreeView.Item;

interface

uses System.Classes, System.SysUtils, System.Variants;

type
  TDACTreeItem = class(TCollectionItem)
  private
    FKey, FParentKey: Variant;
    FText: string;
    FSubItems: TStringList;
    FChecked, FCheckable, FExpanded, FStructuralChange: Boolean;
    FDataObject: TObject;
    procedure Change(Structural: Boolean);
    procedure SubItemsChanged(Sender: TObject);
    function GetSubItems: TStrings;
    function GetParent: TDACTreeItem;
    procedure SetKey(const Value: Variant);
    procedure SetParentKey(const Value: Variant);
    procedure SetText(const Value: string);
    procedure SetSubItems(Value: TStrings);
    procedure SetChecked(Value: Boolean);
    procedure SetCheckable(Value: Boolean);
    procedure SetExpanded(Value: Boolean);
    procedure SetDataObject(Value: TObject);
  protected
    function GetDisplayName: string; override;
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    property Parent: TDACTreeItem read GetParent;
    property DataObject: TObject read FDataObject write SetDataObject;
    property StructuralChange: Boolean read FStructuralChange;
  published
    property Key: Variant read FKey write SetKey;
    property ParentKey: Variant read FParentKey write SetParentKey;
    property Text: string read FText write SetText;
    property SubItems: TStrings read GetSubItems write SetSubItems;
    property Checked: Boolean read FChecked write SetChecked default False;
    property Checkable: Boolean read FCheckable write SetCheckable default True;
    property Expanded: Boolean read FExpanded write SetExpanded default False;
  end;

implementation

uses DAC.Components.Controls.TreeView.Items;

constructor TDACTreeItem.Create(Collection: TCollection);
var Id: TGUID;
begin
  CreateGUID(Id);
  FKey := 'item:' + GUIDToString(Id);
  FParentKey := Null;
  FCheckable := True;
  FSubItems := TStringList.Create;
  FSubItems.OnChange := SubItemsChanged;
  FStructuralChange := True;
  inherited;
end;

destructor TDACTreeItem.Destroy;
begin
  FSubItems.OnChange := nil;
  FSubItems.Free;
  inherited;
end;

procedure TDACTreeItem.Change(Structural: Boolean);
begin
  FStructuralChange := Structural;
  { A change handler may replace/clear the collection. Do not access Self
    after dispatching the notification. The next change sets its own kind. }
  Changed(False);
end;
procedure TDACTreeItem.SubItemsChanged(Sender: TObject);
begin Change(False); end;
function TDACTreeItem.GetSubItems: TStrings;
begin Result := FSubItems; end;
function TDACTreeItem.GetParent: TDACTreeItem;
begin
  Result := nil;
  if Collection is TDACTreeItems then
    Result := TDACTreeItems(Collection).ParentOf(Self);
end;
function TDACTreeItem.GetDisplayName: string;
begin Result := FText; if Result = '' then Result := inherited; end;
procedure TDACTreeItem.SetKey(const Value: Variant);
begin
  if (VarType(Value) = VarType(FKey)) and VarSameValue(Value, FKey) then Exit;
  FKey := Value;
  Change(True);
end;
procedure TDACTreeItem.SetParentKey(const Value: Variant);
begin
  if (VarType(Value) = VarType(FParentKey)) and VarSameValue(Value, FParentKey) then Exit;
  FParentKey := Value;
  Change(True);
end;
procedure TDACTreeItem.SetText(const Value: string);
begin if FText <> Value then begin FText := Value; Change(False); end; end;
procedure TDACTreeItem.SetSubItems(Value: TStrings);
begin if Value <> FSubItems then FSubItems.Assign(Value); end;
procedure TDACTreeItem.SetChecked(Value: Boolean);
begin if FChecked <> Value then begin FChecked := Value; Change(False); end; end;
procedure TDACTreeItem.SetCheckable(Value: Boolean);
begin if FCheckable <> Value then begin FCheckable := Value; Change(False); end; end;
procedure TDACTreeItem.SetExpanded(Value: Boolean);
begin if FExpanded <> Value then begin FExpanded := Value; Change(False); end; end;
procedure TDACTreeItem.SetDataObject(Value: TObject);
begin if FDataObject <> Value then begin FDataObject := Value; Change(False); end; end;
procedure TDACTreeItem.Assign(Source: TPersistent);
var S: TDACTreeItem;
begin
  if Source = Self then Exit;
  if Source is TDACTreeItem then
  begin
    S := TDACTreeItem(Source);
    FKey := S.FKey;
    FParentKey := S.FParentKey;
    FText := S.FText;
    FChecked := S.FChecked;
    FCheckable := S.FCheckable;
    FExpanded := S.FExpanded;
    FDataObject := S.FDataObject;
    FSubItems.OnChange := nil;
    try FSubItems.Assign(S.FSubItems); finally FSubItems.OnChange := SubItemsChanged; end;
    Change(True);
  end else inherited;
end;

end.
