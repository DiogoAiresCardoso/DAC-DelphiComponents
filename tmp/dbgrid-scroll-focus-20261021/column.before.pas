unit DAC.Components.Controls.DBGrid.Column;

interface

uses
  System.Classes,
  Vcl.DBGrids,
  DAC.Components.Controls.Badges,
  DAC.Components.Controls.DBGrid.Actions,
  DAC.Components.Controls.DBGrid.BadgeRules,
  DAC.Components.Controls.DBGrid.Types;

type
  TDACDBGridColumn = class(TColumn)
  private
    FActions: TDACDBGridActions;
    FHint, FTitleHint: string;
    FMinWidth: Integer;
    FBadgeMode: TDACDBGridBadgeMode;
    FBadgeRules: TDACDBGridBadgeRules;
    FFalseCaption: string;
    FFalseStatus: TDACBadgeStatus;
    FLayoutKey: string;
    FSortable: Boolean;
    FTrueCaption: string;
    FTrueStatus: TDACBadgeStatus;
    FUserHideable: Boolean;
    procedure SetHint(const AValue: string);
    procedure SetTitleHint(const AValue: string);
    procedure SetMinWidth(const AValue: Integer);
    procedure BadgeRulesChanged(Sender: TObject);
    procedure SetActions(const AValue: TDACDBGridActions);
    procedure SetBadgeMode(const AValue: TDACDBGridBadgeMode);
    procedure SetBadgeRules(const AValue: TDACDBGridBadgeRules);
    procedure SetFalseCaption(const AValue: string);
    procedure SetFalseStatus(const AValue: TDACBadgeStatus);
    procedure SetLayoutKey(const AValue: string);
    procedure SetSortable(const AValue: Boolean);
    procedure SetTrueCaption(const AValue: string);
    procedure SetTrueStatus(const AValue: TDACBadgeStatus);
    procedure SetUserHideable(const AValue: Boolean);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
    function EffectiveLayoutKey: string;
  published
    property Hint: string read FHint write SetHint;
    property TitleHint: string read FTitleHint write SetTitleHint;
    property MinWidth: Integer read FMinWidth write SetMinWidth default 16;
    property Actions: TDACDBGridActions read FActions write SetActions;
    property BadgeMode: TDACDBGridBadgeMode read FBadgeMode
      write SetBadgeMode default dbmNone;
    property BadgeRules: TDACDBGridBadgeRules read FBadgeRules
      write SetBadgeRules;
    property FalseCaption: string read FFalseCaption write SetFalseCaption;
    property FalseStatus: TDACBadgeStatus read FFalseStatus
      write SetFalseStatus default mbsNeutral;
    property LayoutKey: string read FLayoutKey write SetLayoutKey;
    property Sortable: Boolean read FSortable write SetSortable default True;
    property TrueCaption: string read FTrueCaption write SetTrueCaption;
    property TrueStatus: TDACBadgeStatus read FTrueStatus
      write SetTrueStatus default mbsSuccess;
    property UserHideable: Boolean read FUserHideable
      write SetUserHideable default True;
  end;

implementation

uses System.Math;

constructor TDACDBGridColumn.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FMinWidth := 16;
  FActions := TDACDBGridActions.Create(Self);
  FActions.OnChange := BadgeRulesChanged;
  FBadgeRules := TDACDBGridBadgeRules.Create(Self);
  FBadgeRules.OnChange := BadgeRulesChanged;
  FFalseCaption := 'Não';
  FFalseStatus := mbsNeutral;
  FSortable := True;
  FTrueCaption := 'Sim';
  FTrueStatus := mbsSuccess;
  FUserHideable := True;
  Title.Alignment := taCenter;
end;

destructor TDACDBGridColumn.Destroy;
begin
  if FActions <> nil then FActions.OnChange := nil;
  FActions.Free;
  FBadgeRules.Free;
  inherited;
end;

procedure TDACDBGridColumn.Assign(Source: TPersistent);
var
  LSource: TDACDBGridColumn;
begin
  if Source is TDACDBGridColumn then
  begin
    inherited Assign(Source);
    LSource := TDACDBGridColumn(Source);
    FActions.Assign(LSource.FActions);
    FMinWidth := LSource.MinWidth;
    FHint := LSource.Hint;
    FTitleHint := LSource.TitleHint;
    FBadgeMode := LSource.FBadgeMode;
    FBadgeRules.Assign(LSource.FBadgeRules);
    FFalseCaption := LSource.FFalseCaption;
    FFalseStatus := LSource.FFalseStatus;
    FLayoutKey := LSource.FLayoutKey;
    FSortable := LSource.FSortable;
    FTrueCaption := LSource.FTrueCaption;
    FTrueStatus := LSource.FTrueStatus;
    FUserHideable := LSource.FUserHideable;
    Changed(False);
  end
  else
    inherited Assign(Source);
end;

procedure TDACDBGridColumn.BadgeRulesChanged(Sender: TObject);
begin
  Changed(False);
end;

procedure TDACDBGridColumn.SetActions(const AValue: TDACDBGridActions);
begin
  FActions.Assign(AValue);
end;

procedure TDACDBGridColumn.SetHint(const AValue: string);
begin
  if FHint = AValue then Exit;
  FHint := AValue; Changed(False);
end;

procedure TDACDBGridColumn.SetTitleHint(const AValue: string);
begin
  if FTitleHint = AValue then Exit;
  FTitleHint := AValue; Changed(False);
end;

procedure TDACDBGridColumn.SetMinWidth(const AValue: Integer);
begin
  if FMinWidth = Max(16, AValue) then Exit;
  FMinWidth := Max(16, AValue); Changed(True);
end;

function TDACDBGridColumn.EffectiveLayoutKey: string;
begin
  Result := FLayoutKey;
  if Result = '' then
    Result := FieldName;
end;

procedure TDACDBGridColumn.SetBadgeMode(const AValue: TDACDBGridBadgeMode);
begin
  if FBadgeMode = AValue then Exit;
  FBadgeMode := AValue;
  Changed(False);
end;

procedure TDACDBGridColumn.SetBadgeRules(
  const AValue: TDACDBGridBadgeRules);
begin
  FBadgeRules.Assign(AValue);
end;

procedure TDACDBGridColumn.SetFalseCaption(const AValue: string);
begin
  if FFalseCaption = AValue then Exit;
  FFalseCaption := AValue;
  Changed(False);
end;

procedure TDACDBGridColumn.SetFalseStatus(const AValue: TDACBadgeStatus);
begin
  if FFalseStatus = AValue then Exit;
  FFalseStatus := AValue;
  Changed(False);
end;

procedure TDACDBGridColumn.SetLayoutKey(const AValue: string);
begin
  if FLayoutKey = AValue then Exit;
  FLayoutKey := AValue;
  Changed(False);
end;

procedure TDACDBGridColumn.SetSortable(const AValue: Boolean);
begin
  if FSortable = AValue then Exit;
  FSortable := AValue;
  Changed(False);
end;

procedure TDACDBGridColumn.SetTrueCaption(const AValue: string);
begin
  if FTrueCaption = AValue then Exit;
  FTrueCaption := AValue;
  Changed(False);
end;

procedure TDACDBGridColumn.SetTrueStatus(const AValue: TDACBadgeStatus);
begin
  if FTrueStatus = AValue then Exit;
  FTrueStatus := AValue;
  Changed(False);
end;

procedure TDACDBGridColumn.SetUserHideable(const AValue: Boolean);
begin
  if FUserHideable = AValue then Exit;
  FUserHideable := AValue;
  Changed(False);
end;

end.
