unit DAC.Components.Controls.DBGrid.Columns;

interface

uses
  System.Classes,
  Vcl.DBGrids,
  DAC.Components.Controls.DBGrid.Column;

type
  TDACDBGridColumns = class(TDBGridColumns)
  private
    FOnChange: TNotifyEvent;
    FNotifying: Boolean;
    function GetItem(const AIndex: Integer): TDACDBGridColumn;
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    constructor Create(AGrid: TCustomDBGrid);
    function Add: TDACDBGridColumn;
    property Items[const AIndex: Integer]: TDACDBGridColumn
      read GetItem; default;
  end;

implementation

procedure TDACDBGridColumns.Update(Item: TCollectionItem);
begin
  inherited;
  if FNotifying then Exit;
  FNotifying := True;
  try
    if Assigned(FOnChange) then FOnChange(Self);
  finally FNotifying := False; end;
end;

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
