unit DACChartsDemo.ClientDataSetAdapter;

interface

implementation

uses
  Data.DB,
  Datasnap.DBClient,
  DAC.Components.Controls.Charts;

type
  { The chart package intentionally has no DataSnap dependency.  The demo
    registers this adapter so its TClientDataSet can be read from a clone,
    preserving the cursor currently displayed to the user. }
  TDACChartsDemoClientDataSetAdapter = class(TDACChartDataSetAdapter)
  public
    function Supports(const ADataSet: TDataSet): Boolean; override;
    function CreateReadCursor(const ADataSet: TDataSet): TDataSet; override;
  end;

var
  GClientDataSetAdapter: TDACChartDataSetAdapter;

function TDACChartsDemoClientDataSetAdapter.Supports(
  const ADataSet: TDataSet): Boolean;
begin
  Result := ADataSet is TCustomClientDataSet;
end;

function TDACChartsDemoClientDataSetAdapter.CreateReadCursor(
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
  GClientDataSetAdapter := TDACChartsDemoClientDataSetAdapter.Create;
  RegisterDACChartDataSetAdapter(GClientDataSetAdapter);

finalization
  UnregisterDACChartDataSetAdapter(GClientDataSetAdapter);
  GClientDataSetAdapter.Free;

end.
