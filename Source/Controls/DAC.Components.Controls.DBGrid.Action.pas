unit DAC.Components.Controls.DBGrid.Action;

interface

uses
  System.Classes,
  DAC.Components.DesignSystem.IconAssets,
  DAC.Components.Controls.DBGrid.ActionTypes;

type
  TDACDBGridAction = class(TCollectionItem)
  private
    FActionId, FCaption, FHint: string;
    FIconKind: TDACIconKind;
    FWidth: Integer;
    FVisible, FEnabled: Boolean;
    FAppearance: TDACDBGridActionAppearance;
    procedure SetActionId(const AValue: string);
    procedure SetCaption(const AValue: string);
    procedure SetHint(const AValue: string);
    procedure SetIconKind(const AValue: TDACIconKind);
    procedure SetWidth(const AValue: Integer);
    procedure SetVisible(const AValue: Boolean);
    procedure SetEnabled(const AValue: Boolean);
    procedure SetAppearance(const AValue: TDACDBGridActionAppearance);
  protected
    function GetDisplayName: string; override;
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
  published
    property ActionId: string read FActionId write SetActionId;
    property Caption: string read FCaption write SetCaption;
    property IconKind: TDACIconKind read FIconKind write SetIconKind default mikNone;
    property Hint: string read FHint write SetHint;
    // Logical pixels at 96 PPI, scaled by the grid.
    property Width: Integer read FWidth write SetWidth default 32;
    property Visible: Boolean read FVisible write SetVisible default True;
    property Enabled: Boolean read FEnabled write SetEnabled default True;
    property Appearance: TDACDBGridActionAppearance read FAppearance
      write SetAppearance default daaDefault;
  end;

implementation

uses System.SysUtils, System.Math;

constructor TDACDBGridAction.Create(Collection: TCollection);
var Id: TGUID;
begin
  inherited;
  CreateGUID(Id);
  FActionId := GUIDToString(Id);
  FWidth := 32;
  FVisible := True;
  FEnabled := True;
end;

procedure TDACDBGridAction.Assign(Source: TPersistent);
var S: TDACDBGridAction;
begin
  if not (Source is TDACDBGridAction) then begin inherited; Exit; end;
  S := TDACDBGridAction(Source);
  SetActionId(S.ActionId);
  FCaption := S.Caption;
  FHint := S.Hint;
  FIconKind := S.IconKind;
  FWidth := S.Width;
  FVisible := S.Visible;
  FEnabled := S.Enabled;
  FAppearance := S.Appearance;
  Changed(False);
end;

function TDACDBGridAction.GetDisplayName: string;
begin
  Result := FActionId;
  if FCaption <> '' then Result := Result + ' - ' + FCaption;
end;

procedure TDACDBGridAction.SetActionId(const AValue: string);
var I: Integer; S: string;
begin
  S := Trim(AValue);
  if S = '' then raise EArgumentException.Create('ActionId cannot be empty.');
  if Collection <> nil then
    for I := 0 to Collection.Count - 1 do
      if (Collection.Items[I] <> Self) and
        SameText(TDACDBGridAction(Collection.Items[I]).ActionId, S) then
        raise EArgumentException.Create('Duplicate ActionId: ' + S);
  if FActionId = S then Exit;
  FActionId := S;
  Changed(False);
end;

procedure TDACDBGridAction.SetCaption(const AValue: string);
begin
  if FCaption = AValue then Exit;
  FCaption := AValue; Changed(False);
end;

procedure TDACDBGridAction.SetHint(const AValue: string);
begin
  if FHint = AValue then Exit;
  FHint := AValue; Changed(False);
end;

procedure TDACDBGridAction.SetIconKind(const AValue: TDACIconKind);
begin
  if FIconKind = AValue then Exit;
  FIconKind := AValue; Changed(False);
end;

procedure TDACDBGridAction.SetWidth(const AValue: Integer);
var V: Integer;
begin
  V := Max(16, AValue);
  if FWidth = V then Exit;
  FWidth := V; Changed(False);
end;

procedure TDACDBGridAction.SetVisible(const AValue: Boolean);
begin
  if FVisible = AValue then Exit;
  FVisible := AValue; Changed(False);
end;

procedure TDACDBGridAction.SetEnabled(const AValue: Boolean);
begin
  if FEnabled = AValue then Exit;
  FEnabled := AValue; Changed(False);
end;

procedure TDACDBGridAction.SetAppearance(const AValue: TDACDBGridActionAppearance);
begin
  if FAppearance = AValue then Exit;
  FAppearance := AValue; Changed(False);
end;

end.
