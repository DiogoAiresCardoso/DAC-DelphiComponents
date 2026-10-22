unit DAC.Components.Controls.DBGrid.BadgeRule;

interface

uses
  System.Classes,
  System.UITypes,
  DAC.Components.Controls.Badges;

type
  TDACDBGridBadgeRule = class(TCollectionItem)
  private
    FAppearance: TDACBadgeAppearance;
    FBackgroundColor: TAlphaColor;
    FBorderColor: TAlphaColor;
    FCaption: string;
    FCaseSensitive: Boolean;
    FEnabled: Boolean;
    FStatus: TDACBadgeStatus;
    FTextColor: TAlphaColor;
    FUseCustomColors: Boolean;
    FValue: string;
    procedure SetAppearance(const AValue: TDACBadgeAppearance);
    procedure SetBackgroundColor(const AValue: TAlphaColor);
    procedure SetBorderColor(const AValue: TAlphaColor);
    procedure SetCaption(const AValue: string);
    procedure SetCaseSensitive(const AValue: Boolean);
    procedure SetEnabled(const AValue: Boolean);
    procedure SetStatus(const AValue: TDACBadgeStatus);
    procedure SetTextColor(const AValue: TAlphaColor);
    procedure SetUseCustomColors(const AValue: Boolean);
    procedure SetValue(const AValue: string);
  public
    constructor Create(Collection: TCollection); override;
    procedure Assign(Source: TPersistent); override;
    function Matches(const AValue: string): Boolean;
  published
    property Appearance: TDACBadgeAppearance read FAppearance
      write SetAppearance default mbaSoft;
    property BackgroundColor: TAlphaColor read FBackgroundColor
      write SetBackgroundColor default 0;
    property BorderColor: TAlphaColor read FBorderColor
      write SetBorderColor default 0;
    property Caption: string read FCaption write SetCaption;
    property CaseSensitive: Boolean read FCaseSensitive
      write SetCaseSensitive default False;
    property Enabled: Boolean read FEnabled write SetEnabled default True;
    property Status: TDACBadgeStatus read FStatus write SetStatus
      default mbsNeutral;
    property TextColor: TAlphaColor read FTextColor write SetTextColor default 0;
    property UseCustomColors: Boolean read FUseCustomColors
      write SetUseCustomColors default False;
    property Value: string read FValue write SetValue;
  end;

implementation

uses
  System.SysUtils;

constructor TDACDBGridBadgeRule.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FAppearance := mbaSoft;
  FEnabled := True;
  FStatus := mbsNeutral;
end;

procedure TDACDBGridBadgeRule.Assign(Source: TPersistent);
var
  LSource: TDACDBGridBadgeRule;
begin
  if Source is TDACDBGridBadgeRule then
  begin
    LSource := TDACDBGridBadgeRule(Source);
    FAppearance := LSource.FAppearance;
    FBackgroundColor := LSource.FBackgroundColor;
    FBorderColor := LSource.FBorderColor;
    FCaption := LSource.FCaption;
    FCaseSensitive := LSource.FCaseSensitive;
    FEnabled := LSource.FEnabled;
    FStatus := LSource.FStatus;
    FTextColor := LSource.FTextColor;
    FUseCustomColors := LSource.FUseCustomColors;
    FValue := LSource.FValue;
    Changed(False);
  end
  else
    inherited Assign(Source);
end;

function TDACDBGridBadgeRule.Matches(const AValue: string): Boolean;
begin
  if not FEnabled then
    Exit(False);
  if FCaseSensitive then
    Result := FValue = AValue
  else
    Result := SameText(FValue, AValue);
end;

procedure TDACDBGridBadgeRule.SetAppearance(
  const AValue: TDACBadgeAppearance);
begin
  if FAppearance = AValue then Exit;
  FAppearance := AValue;
  Changed(False);
end;

procedure TDACDBGridBadgeRule.SetBackgroundColor(const AValue: TAlphaColor);
begin
  if FBackgroundColor = AValue then Exit;
  FBackgroundColor := AValue;
  Changed(False);
end;

procedure TDACDBGridBadgeRule.SetBorderColor(const AValue: TAlphaColor);
begin
  if FBorderColor = AValue then Exit;
  FBorderColor := AValue;
  Changed(False);
end;

procedure TDACDBGridBadgeRule.SetCaption(const AValue: string);
begin
  if FCaption = AValue then Exit;
  FCaption := AValue;
  Changed(False);
end;

procedure TDACDBGridBadgeRule.SetCaseSensitive(const AValue: Boolean);
begin
  if FCaseSensitive = AValue then Exit;
  FCaseSensitive := AValue;
  Changed(False);
end;

procedure TDACDBGridBadgeRule.SetEnabled(const AValue: Boolean);
begin
  if FEnabled = AValue then Exit;
  FEnabled := AValue;
  Changed(False);
end;

procedure TDACDBGridBadgeRule.SetStatus(const AValue: TDACBadgeStatus);
begin
  if FStatus = AValue then Exit;
  FStatus := AValue;
  Changed(False);
end;

procedure TDACDBGridBadgeRule.SetTextColor(const AValue: TAlphaColor);
begin
  if FTextColor = AValue then Exit;
  FTextColor := AValue;
  Changed(False);
end;

procedure TDACDBGridBadgeRule.SetUseCustomColors(const AValue: Boolean);
begin
  if FUseCustomColors = AValue then Exit;
  FUseCustomColors := AValue;
  Changed(False);
end;

procedure TDACDBGridBadgeRule.SetValue(const AValue: string);
begin
  if FValue = AValue then Exit;
  FValue := AValue;
  Changed(False);
end;

end.
