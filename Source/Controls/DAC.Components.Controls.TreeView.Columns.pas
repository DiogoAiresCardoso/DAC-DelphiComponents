unit DAC.Components.Controls.TreeView.Columns;

interface

uses System.Classes, DAC.Components.Controls.TreeView.Column;

type
  TDACTreeColumns = class(TOwnedCollection)
  private
    FOnChange: TNotifyEvent;
    FNotifying: Boolean;
    function GetItem(const AIndex: Integer): TDACTreeColumn;
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent; AItemClass: TCollectionItemClass = nil);
    function Add: TDACTreeColumn;
    property Items[const AIndex: Integer]: TDACTreeColumn read GetItem; default;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

implementation

constructor TDACTreeColumns.Create(AOwner: TPersistent; AItemClass: TCollectionItemClass);
begin
  if AItemClass = nil then AItemClass := TDACTreeColumn;
  inherited Create(AOwner, AItemClass);
end;

function TDACTreeColumns.Add: TDACTreeColumn;
begin
  Result := TDACTreeColumn(inherited Add);
end;

function TDACTreeColumns.GetItem(const AIndex: Integer): TDACTreeColumn;
begin
  Result := TDACTreeColumn(inherited Items[AIndex]);
end;

procedure TDACTreeColumns.Update(Item: TCollectionItem);
begin
  inherited;
  if FNotifying then Exit;
  FNotifying := True;
  try
    if Assigned(FOnChange) then FOnChange(Self);
  finally
    FNotifying := False;
  end;
end;

end.
