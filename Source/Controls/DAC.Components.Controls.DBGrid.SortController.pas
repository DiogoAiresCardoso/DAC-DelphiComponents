unit DAC.Components.Controls.DBGrid.SortController;

interface

uses
  DAC.Components.Controls.DBGrid.Types;

type
  TDACDBGridSortController = class
  private
    FDirection: TDACDBGridSortDirection;
    FKey: string;
    FFieldName: string;
  public
    procedure Accept(const AKey: string;
      const ADirection: TDACDBGridSortDirection; const AFieldName: string = '');
    procedure Clear;
    function NextDirection(const AKey: string): TDACDBGridSortDirection;
    property Direction: TDACDBGridSortDirection read FDirection;
    property Key: string read FKey;
    property FieldName: string read FFieldName;
  end;

implementation

uses System.SysUtils;

procedure TDACDBGridSortController.Accept(const AKey: string;
  const ADirection: TDACDBGridSortDirection; const AFieldName: string);
begin
  if ADirection = dgsNone then
  begin
    Clear;
    Exit;
  end;
  FKey := AKey;
  FFieldName := AFieldName;
  FDirection := ADirection;
end;

procedure TDACDBGridSortController.Clear;
begin
  FKey := '';
  FFieldName := '';
  FDirection := dgsNone;
end;

function TDACDBGridSortController.NextDirection(
  const AKey: string): TDACDBGridSortDirection;
begin
  if not SameText(FKey, AKey) or (FDirection = dgsNone) then
    Exit(dgsAscending);
  case FDirection of
    dgsAscending: Result := dgsDescending;
    dgsDescending: Result := dgsAscending;
  else
    Result := dgsAscending;
  end;
end;

end.
