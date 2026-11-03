unit DAC.Components.Controls.DBTreeView.Roots;
interface
uses System.Classes, DAC.Components.Controls.TreeView.Roots;
type
  TDACDBTreeRootKind = TDACTreeRootKind;
  TDACDBTreeRoot = class(TDACTreeRoot);
  TDACDBTreeRoots = class(TDACTreeRoots)
  private
    function GetItem(const AIndex: Integer): TDACDBTreeRoot;
  public
    constructor Create(AOwner: TPersistent);
    function Add: TDACDBTreeRoot;
    property Items[const AIndex: Integer]: TDACDBTreeRoot read GetItem; default;
  end;
const
  trkNull = DAC.Components.Controls.TreeView.Roots.trkNull;
  trkEmptyString = DAC.Components.Controls.TreeView.Roots.trkEmptyString;
  trkValue = DAC.Components.Controls.TreeView.Roots.trkValue;
implementation
constructor TDACDBTreeRoots.Create(AOwner: TPersistent);
begin inherited Create(AOwner, TDACDBTreeRoot); end;
function TDACDBTreeRoots.Add: TDACDBTreeRoot;
begin Result := TDACDBTreeRoot(inherited Add); end;
function TDACDBTreeRoots.GetItem(const AIndex: Integer): TDACDBTreeRoot;
begin Result := TDACDBTreeRoot(inherited Items[AIndex]); end;
end.
