unit DAC.Components.Controls.DBGrid.ClientDataSetSortSource;

interface

uses System.Classes, Data.DB, Datasnap.DBClient;

type
  // Owned by the sorted buffer. No event on the application's datasource is replaced.
  TDACDBGridClientDataSetSortSource = class(TDataSource)
  private
    procedure StateChanged(Sender: TObject);
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

constructor TDACDBGridClientDataSetSortSource.Create(AOwner: TComponent);
begin
  inherited;
  AutoEdit := False;
  OnStateChange := StateChanged;
  if AOwner is TClientDataSet then DataSet := TClientDataSet(AOwner);
end;

procedure TDACDBGridClientDataSetSortSource.StateChanged(Sender: TObject);
begin
  // Runtime MIDAS indexes do not survive Close/Open of a data packet.
  if (DataSet is TClientDataSet) and not DataSet.Active and
    (Copy(TClientDataSet(DataSet).IndexName, 1, 9) = 'DAC_GRID_') then
    TClientDataSet(DataSet).IndexName := '';
end;

end.
