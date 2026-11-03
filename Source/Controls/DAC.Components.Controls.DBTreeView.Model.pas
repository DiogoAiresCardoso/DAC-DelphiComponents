unit DAC.Components.Controls.DBTreeView.Model;
interface
uses Data.DB, DAC.Components.Controls.TreeView.Model,
  DAC.Components.Controls.DBTreeView.Types;
type
  TDACDBTreeNode = class(TDACTreeModelNode)
  public
    Bookmark: TBookmark;
  end;
  TDACDBTreeModel = class(TDACTreeModel<TDACDBTreeNode>)
  public
    constructor Create(const AKeyKind: TDACDBTreeKeyKind = tkkText);
  end;
implementation
constructor TDACDBTreeModel.Create(const AKeyKind: TDACDBTreeKeyKind);
begin inherited Create(AKeyKind); end;
end.
