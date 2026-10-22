unit DAC.Components.Controls.DBGrid.BadgeRules;

interface

uses
  System.Classes,
  DAC.Components.Controls.DBGrid.BadgeRule;

type
  TDACDBGridBadgeRules = class(TOwnedCollection)
  private
    FOnChange: TNotifyEvent;
    function GetItem(const AIndex: Integer): TDACDBGridBadgeRule;
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent);
    function Add: TDACDBGridBadgeRule;
    function FindMatch(const AValue: string): TDACDBGridBadgeRule;
    property Items[const AIndex: Integer]: TDACDBGridBadgeRule
      read GetItem; default;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

implementation

constructor TDACDBGridBadgeRules.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TDACDBGridBadgeRule);
end;

function TDACDBGridBadgeRules.Add: TDACDBGridBadgeRule;
begin
  Result := inherited Add as TDACDBGridBadgeRule;
end;

function TDACDBGridBadgeRules.FindMatch(
  const AValue: string): TDACDBGridBadgeRule;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to Count - 1 do
    if Items[I].Matches(AValue) then
      Exit(Items[I]);
end;

function TDACDBGridBadgeRules.GetItem(
  const AIndex: Integer): TDACDBGridBadgeRule;
begin
  Result := inherited Items[AIndex] as TDACDBGridBadgeRule;
end;

procedure TDACDBGridBadgeRules.Update(Item: TCollectionItem);
begin
  inherited Update(Item);
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

end.
