unit DAC.Components.Controls.DBGrid.SortController;

interface

uses
  DAC.Components.Controls.DBGrid.Types;

type
  TDACDBGridSortController = class
  private
    FDirection: TDACDBGridSortDirection;
    FKey: string;
  public
    procedure Accept(const AKey: string;
      const ADirection: TDACDBGridSortDirection);
    procedure Clear;
    function NextDirection(const AKey: string): TDACDBGridSortDirection;
    property Direction: TDACDBGridSortDirection read FDirection;
    property Key: string read FKey;
  end;

implementation

procedure TDACDBGridSortController.Accept(const AKey: string;
  const ADirection: TDACDBGridSortDirection);
begin
  if ADirection = dgsNone then
  begin
    Clear;
    Exit;
  end;
  FKey := AKey;
  FDirection := ADirection;
end;

procedure TDACDBGridSortController.Clear;
begin
  FKey := '';
  FDirection := dgsNone;
end;

function TDACDBGridSortController.NextDirection(
  const AKey: string): TDACDBGridSortDirection;
begin
  if (FKey <> AKey) or (FDirection = dgsNone) then
    Exit(dgsAscending);
  case FDirection of
    dgsAscending: Result := dgsDescending;
    dgsDescending: Result := dgsNone;
  else
    Result := dgsAscending;
  end;
end;

end.
