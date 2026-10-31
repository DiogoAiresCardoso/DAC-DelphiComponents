unit DAC.Components.Controls.DBTreeView.Columns;

interface

uses System.Classes, DAC.Components.Controls.DBTreeView.Column;

type
  TDACDBTreeColumns = class(TOwnedCollection)
  private
    FOnChange: TNotifyEvent;
    FNotifying: Boolean;
    function GetItem(const AIndex: Integer): TDACDBTreeColumn;
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent);
    function Add: TDACDBTreeColumn;
    property Items[const AIndex: Integer]: TDACDBTreeColumn read GetItem; default;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

implementation

constructor TDACDBTreeColumns.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TDACDBTreeColumn);
end;

function TDACDBTreeColumns.Add: TDACDBTreeColumn;
begin
  Result := TDACDBTreeColumn(inherited Add);
end;

function TDACDBTreeColumns.GetItem(const AIndex: Integer): TDACDBTreeColumn;
begin
  Result := TDACDBTreeColumn(inherited Items[AIndex]);
end;

procedure TDACDBTreeColumns.Update(Item: TCollectionItem);
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
