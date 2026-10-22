unit TestSupport.DACGridHostForm;
interface
uses System.Classes, Vcl.Forms, Vcl.DBGrids,
  DAC.Components.Controls.DBGrid.Column, DAC.Components.Controls.DBGrid.Action,
  DAC.Components.Controls.DBGrid.ActionTypes, DAC.Components.Controls.DBGrid.Types;
type
  TDACGridHostForm = class(TForm)
  published
    procedure GridOrdenar(Sender: TObject; AColumn: TColumn; const AFieldName: string;
      ADirection: TDACDBGridSortDirection; var AAccepted: Boolean);
    procedure GridAcaoEstado(Sender: TObject; AColumn: TDACDBGridColumn;
      AAction: TDACDBGridAction; const AContext: TDACDBGridActionContext;
      var AVisible, AEnabled: Boolean);
    procedure GridAcaoExecutar(Sender: TObject; AColumn: TDACDBGridColumn;
      AAction: TDACDBGridAction; const AContext: TDACDBGridActionContext);
  public
    Activations: Integer;
  end;
implementation
uses DAC.Components.Controls.DBGrid, DAC.Components.Controls.DBGrid.ClientDataSetSort,
  Datasnap.DBClient;
procedure TDACGridHostForm.GridOrdenar(Sender: TObject; AColumn: TColumn;
  const AFieldName: string; ADirection: TDACDBGridSortDirection; var AAccepted: Boolean);
var G: TDACDBGrid;
begin
  G := TDACDBGrid(Sender);
  AAccepted := TDACDBGridClientDataSetSort.Apply(TClientDataSet(G.DataSource.DataSet),
    AFieldName, ADirection, G.ActionKeyFields);
end;
procedure TDACGridHostForm.GridAcaoEstado(Sender: TObject; AColumn: TDACDBGridColumn;
  AAction: TDACDBGridAction; const AContext: TDACDBGridActionContext;
  var AVisible, AEnabled: Boolean);
begin
  AVisible := True; AEnabled := AContext.HasCompleteKey;
end;
procedure TDACGridHostForm.GridAcaoExecutar(Sender: TObject; AColumn: TDACDBGridColumn;
  AAction: TDACDBGridAction; const AContext: TDACDBGridActionContext);
begin Inc(Activations); end;
end.
