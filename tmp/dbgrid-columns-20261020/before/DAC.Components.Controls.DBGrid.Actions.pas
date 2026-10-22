unit DAC.Components.Controls.DBGrid.Actions;

interface

uses System.Classes, DAC.Components.Controls.DBGrid.Action;

type
  TDACDBGridActions = class(TOwnedCollection)
  private
    FOnChange: TNotifyEvent;
    function GetItem(const AIndex: Integer): TDACDBGridAction;
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent);
    function Add: TDACDBGridAction;
    function Find(const AActionId: string): TDACDBGridAction;
    property Items[const AIndex: Integer]: TDACDBGridAction read GetItem; default;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

implementation

uses System.SysUtils;

constructor TDACDBGridActions.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TDACDBGridAction);
end;

function TDACDBGridActions.Add: TDACDBGridAction;
begin
  Result := inherited Add as TDACDBGridAction;
end;

function TDACDBGridActions.Find(const AActionId: string): TDACDBGridAction;
var I: Integer;
begin
  for I := 0 to Count - 1 do
    if SameText(Items[I].ActionId, AActionId) then Exit(Items[I]);
  Result := nil;
end;

function TDACDBGridActions.GetItem(const AIndex: Integer): TDACDBGridAction;
begin
  Result := inherited Items[AIndex] as TDACDBGridAction;
end;

procedure TDACDBGridActions.Update(Item: TCollectionItem);
begin
  inherited;
  if Assigned(FOnChange) then FOnChange(Self);
end;

end.
