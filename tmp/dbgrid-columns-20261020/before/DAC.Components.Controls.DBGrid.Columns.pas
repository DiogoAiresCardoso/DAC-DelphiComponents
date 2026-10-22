unit DAC.Components.Controls.DBGrid.Columns;

interface

uses
  Vcl.DBGrids,
  DAC.Components.Controls.DBGrid.Column;

type
  TDACDBGridColumns = class(TDBGridColumns)
  private
    function GetItem(const AIndex: Integer): TDACDBGridColumn;
  public
    constructor Create(AGrid: TCustomDBGrid);
    function Add: TDACDBGridColumn;
    property Items[const AIndex: Integer]: TDACDBGridColumn
      read GetItem; default;
  end;

implementation

constructor TDACDBGridColumns.Create(AGrid: TCustomDBGrid);
begin
  inherited Create(AGrid, TDACDBGridColumn);
end;

function TDACDBGridColumns.Add: TDACDBGridColumn;
begin
  Result := inherited Add as TDACDBGridColumn;
end;

function TDACDBGridColumns.GetItem(
  const AIndex: Integer): TDACDBGridColumn;
begin
  Result := inherited Items[AIndex] as TDACDBGridColumn;
end;

end.
