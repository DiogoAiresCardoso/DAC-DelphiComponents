unit DAC.Components.Controls.DBTreeView.Column;

interface

uses System.Classes;

type
  TDACDBTreeColumn = class(TCollectionItem)
  private
    FFieldName, FCaption, FHint, FTitleHint: string;
    FWidth: Integer;
    FAlignment: TAlignment;
    procedure SetFieldName(const AValue: string);
    procedure SetCaption(const AValue: string);
    procedure SetHint(const AValue: string);
    procedure SetTitleHint(const AValue: string);
    procedure SetWidth(const AValue: Integer);
    procedure SetAlignment(const AValue: TAlignment);
  protected
    function GetDisplayName: string; override;
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
  published
    property FieldName: string read FFieldName write SetFieldName;
    property Caption: string read FCaption write SetCaption;
    property Width: Integer read FWidth write SetWidth default 160;
    property Alignment: TAlignment read FAlignment write SetAlignment default taLeftJustify;
    property Hint: string read FHint write SetHint;
    property TitleHint: string read FTitleHint write SetTitleHint;
  end;

implementation

constructor TDACDBTreeColumn.Create(Collection: TCollection);
begin
  inherited;
  FWidth := 160;
  FAlignment := taLeftJustify;
end;

procedure TDACDBTreeColumn.Assign(Source: TPersistent);
var LSource: TDACDBTreeColumn;
begin
  if Source is TDACDBTreeColumn then
  begin
    LSource := TDACDBTreeColumn(Source);
    FFieldName := LSource.FFieldName;
    FCaption := LSource.FCaption;
    FWidth := LSource.FWidth;
    FAlignment := LSource.FAlignment;
    FHint := LSource.FHint;
    FTitleHint := LSource.FTitleHint;
    Changed(False);
  end
  else inherited;
end;

function TDACDBTreeColumn.GetDisplayName: string;
begin
  Result := FFieldName;
  if Result = '' then Result := inherited GetDisplayName;
end;

procedure TDACDBTreeColumn.SetFieldName(const AValue: string);
begin
  if FFieldName = AValue then Exit;
  FFieldName := AValue; Changed(False);
end;

procedure TDACDBTreeColumn.SetCaption(const AValue: string);
begin
  if FCaption = AValue then Exit;
  FCaption := AValue; Changed(False);
end;

procedure TDACDBTreeColumn.SetHint(const AValue: string);
begin
  if FHint = AValue then Exit;
  FHint := AValue; Changed(False);
end;

procedure TDACDBTreeColumn.SetTitleHint(const AValue: string);
begin
  if FTitleHint = AValue then Exit;
  FTitleHint := AValue; Changed(False);
end;

procedure TDACDBTreeColumn.SetWidth(const AValue: Integer);
var LValue: Integer;
begin
  LValue := AValue;
  if LValue < 16 then LValue := 16;
  if FWidth = LValue then Exit;
  FWidth := LValue; Changed(False);
end;

procedure TDACDBTreeColumn.SetAlignment(const AValue: TAlignment);
begin
  if FAlignment = AValue then Exit;
  FAlignment := AValue; Changed(False);
end;

end.
