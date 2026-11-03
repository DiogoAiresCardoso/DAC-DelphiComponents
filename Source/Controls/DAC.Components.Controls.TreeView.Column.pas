unit DAC.Components.Controls.TreeView.Column;

interface

uses System.Classes;

type
  TDACTreeColumn = class(TCollectionItem)
  private
    FCaption, FHint, FTitleHint: string;
    FWidth: Integer;
    FAlignment: TAlignment;
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
    function DisplayCaption: string; virtual;
  published
    property Caption: string read FCaption write SetCaption;
    property Width: Integer read FWidth write SetWidth default 160;
    property Alignment: TAlignment read FAlignment write SetAlignment default taLeftJustify;
    property Hint: string read FHint write SetHint;
    property TitleHint: string read FTitleHint write SetTitleHint;
  end;

implementation

constructor TDACTreeColumn.Create(Collection: TCollection);
begin
  inherited;
  FWidth := 160;
  FAlignment := taLeftJustify;
end;

procedure TDACTreeColumn.Assign(Source: TPersistent);
var LSource: TDACTreeColumn;
begin
  if Source is TDACTreeColumn then
  begin
    LSource := TDACTreeColumn(Source);
    FCaption := LSource.FCaption;
    FWidth := LSource.FWidth;
    FAlignment := LSource.FAlignment;
    FHint := LSource.FHint;
    FTitleHint := LSource.FTitleHint;
    Changed(False);
  end
  else inherited;
end;

function TDACTreeColumn.GetDisplayName: string;
begin
  Result := FCaption;
  if Result = '' then Result := inherited GetDisplayName;
end;

function TDACTreeColumn.DisplayCaption: string;
begin Result := FCaption; end;

procedure TDACTreeColumn.SetCaption(const AValue: string);
begin
  if FCaption = AValue then Exit;
  FCaption := AValue; Changed(False);
end;

procedure TDACTreeColumn.SetHint(const AValue: string);
begin
  if FHint = AValue then Exit;
  FHint := AValue; Changed(False);
end;

procedure TDACTreeColumn.SetTitleHint(const AValue: string);
begin
  if FTitleHint = AValue then Exit;
  FTitleHint := AValue; Changed(False);
end;

procedure TDACTreeColumn.SetWidth(const AValue: Integer);
var LValue: Integer;
begin
  LValue := AValue;
  if LValue < 16 then LValue := 16;
  if FWidth = LValue then Exit;
  FWidth := LValue; Changed(False);
end;

procedure TDACTreeColumn.SetAlignment(const AValue: TAlignment);
begin
  if FAlignment = AValue then Exit;
  FAlignment := AValue; Changed(False);
end;

end.
