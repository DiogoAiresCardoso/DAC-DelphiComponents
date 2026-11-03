unit DAC.Components.Controls.DBTreeView.Columns;
interface
uses System.Classes, DAC.Components.Controls.TreeView.Columns,
  DAC.Components.Controls.DBTreeView.Column;
type
  TDACDBTreeColumns = class(TDACTreeColumns)
  private
    function GetItem(const AIndex: Integer): TDACDBTreeColumn;
  public
    constructor Create(AOwner: TPersistent);
    function Add: TDACDBTreeColumn;
    property Items[const AIndex: Integer]: TDACDBTreeColumn read GetItem; default;
  end;
implementation
constructor TDACDBTreeColumns.Create(AOwner: TPersistent);
begin inherited Create(AOwner, TDACDBTreeColumn); end;
function TDACDBTreeColumns.Add: TDACDBTreeColumn;
begin Result := TDACDBTreeColumn(inherited Add); end;
function TDACDBTreeColumns.GetItem(const AIndex: Integer): TDACDBTreeColumn;
begin Result := TDACDBTreeColumn(inherited Items[AIndex]); end;
end.
