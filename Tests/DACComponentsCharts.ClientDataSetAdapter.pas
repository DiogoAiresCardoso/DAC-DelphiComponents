unit DACComponentsCharts.ClientDataSetAdapter;

interface

implementation

uses
  Data.DB,
  Datasnap.DBClient,
  DAC.Components.Controls.Charts;

type
  { Test-only DataSnap integration.  The runtime suite exposes only the
    TDataSet adapter contract and must never link Datasnap.DBClient. }
  TDACChartsTestClientDataSetAdapter = class(TDACChartDataSetAdapter)
  public
    function Supports(const ADataSet: TDataSet): Boolean; override;
    function CreateReadCursor(const ADataSet: TDataSet): TDataSet; override;
  end;

var
  GClientDataSetAdapter: TDACChartDataSetAdapter;

function TDACChartsTestClientDataSetAdapter.Supports(
  const ADataSet: TDataSet): Boolean;
begin
  Result := ADataSet is TCustomClientDataSet;
end;

function TDACChartsTestClientDataSetAdapter.CreateReadCursor(
  const ADataSet: TDataSet): TDataSet;
var
  LClone: TClientDataSet;
begin
  LClone := TClientDataSet.Create(nil);
  try
    LClone.CloneCursor(TCustomClientDataSet(ADataSet), True, True);
    Result := LClone;
  except
    LClone.Free;
    raise;
  end;
end;

initialization
  GClientDataSetAdapter := TDACChartsTestClientDataSetAdapter.Create;
  RegisterDACChartDataSetAdapter(GClientDataSetAdapter);

finalization
  UnregisterDACChartDataSetAdapter(GClientDataSetAdapter);
  GClientDataSetAdapter.Free;

end.
