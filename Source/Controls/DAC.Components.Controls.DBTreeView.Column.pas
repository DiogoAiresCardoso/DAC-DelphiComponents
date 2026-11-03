unit DAC.Components.Controls.DBTreeView.Column;
interface
uses System.Classes, DAC.Components.Controls.TreeView.Column;
type
  TDACDBTreeColumn = class(TDACTreeColumn)
  private
    FFieldName: string;
    procedure SetFieldName(const AValue: string);
  protected
    function GetDisplayName: string; override;
  public
    procedure Assign(Source: TPersistent); override;
    function DisplayCaption: string; override;
  published
    property FieldName: string read FFieldName write SetFieldName;
  end;
implementation
procedure TDACDBTreeColumn.Assign(Source: TPersistent);
begin
  if Collection <> nil then Collection.BeginUpdate;
  try
    inherited;
    if Source is TDACDBTreeColumn then SetFieldName(TDACDBTreeColumn(Source).FieldName);
  finally
    if Collection <> nil then Collection.EndUpdate;
  end;
end;
function TDACDBTreeColumn.GetDisplayName: string;
begin Result := FFieldName; if Result = '' then Result := inherited GetDisplayName; end;
function TDACDBTreeColumn.DisplayCaption: string;
begin Result := Caption; if Result = '' then Result := FFieldName; end;
procedure TDACDBTreeColumn.SetFieldName(const AValue: string);
begin
  if FFieldName = AValue then Exit;
  FFieldName := AValue;
  Changed(False);
end;
end.
