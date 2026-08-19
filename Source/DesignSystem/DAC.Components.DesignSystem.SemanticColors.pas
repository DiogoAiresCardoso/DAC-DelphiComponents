unit DAC.Components.DesignSystem.SemanticColors;

interface

uses
  System.UITypes;

type
  TDACSemanticStatus = (
    mssNeutral,
    mssSuccess,
    mssWarning,
    mssDanger,
    mssInfo
  );

  TDACSemanticColorSet = record
    Accent: TAlphaColor;
    AccentDark: TAlphaColor;
    AccentLight: TAlphaColor;
    SoftBackground: TAlphaColor;
    Text: TAlphaColor;
    Border: TAlphaColor;
  end;

  TDACSemanticColors = class sealed
  public
    class function ColorsFor(const AStatus: TDACSemanticStatus): TDACSemanticColorSet; static;
    class function AccentFor(const AStatus: TDACSemanticStatus): TAlphaColor; static;
    class function SoftBackgroundFor(const AStatus: TDACSemanticStatus): TAlphaColor; static;
    class function TextFor(const AStatus: TDACSemanticStatus): TAlphaColor; static;
  end;

implementation

uses
  DAC.Components.DesignSystem.ColorTokens;

class function TDACSemanticColors.AccentFor(
  const AStatus: TDACSemanticStatus): TAlphaColor;
begin
  Result := ColorsFor(AStatus).Accent;
end;

class function TDACSemanticColors.ColorsFor(
  const AStatus: TDACSemanticStatus): TDACSemanticColorSet;
begin
  case AStatus of
    mssSuccess:
      begin
        Result.Accent := TDACComponentColors.Primary;
        Result.AccentDark := TDACComponentColors.PrimaryDark;
        Result.AccentLight := TDACComponentColors.PrimaryLight;
        Result.SoftBackground := TDACComponentColors.Alpha(232, 247, 229);
        Result.Text := TDACComponentColors.PrimaryDark;
        Result.Border := TDACComponentColors.Alpha(185, 228, 174);
      end;
    mssWarning:
      begin
        Result.Accent := TDACComponentColors.Warning;
        Result.AccentDark := TDACComponentColors.WarningDark;
        Result.AccentLight := TDACComponentColors.WarningLight;
        Result.SoftBackground := TDACComponentColors.Alpha(255, 247, 218);
        Result.Text := TDACComponentColors.WarningDark;
        Result.Border := TDACComponentColors.Alpha(246, 206, 127);
      end;
    mssDanger:
      begin
        Result.Accent := TDACComponentColors.Danger;
        Result.AccentDark := TDACComponentColors.DangerDark;
        Result.AccentLight := TDACComponentColors.DangerLight;
        Result.SoftBackground := TDACComponentColors.Alpha(253, 232, 230);
        Result.Text := TDACComponentColors.DangerDark;
        Result.Border := TDACComponentColors.Alpha(238, 177, 170);
      end;
    mssInfo:
      begin
        Result.Accent := TDACComponentColors.Info;
        Result.AccentDark := TDACComponentColors.InfoDark;
        Result.AccentLight := TDACComponentColors.InfoLight;
        Result.SoftBackground := TDACComponentColors.InfoSoftBackground;
        Result.Text := TDACComponentColors.InfoText;
        Result.Border := TDACComponentColors.InfoBorder;
      end;
  else
    Result.Accent := TDACComponentColors.Neutral;
    Result.AccentDark := TDACComponentColors.NeutralDark;
    Result.AccentLight := TDACComponentColors.NeutralLight;
    Result.SoftBackground := TDACComponentColors.NeutralSoftBackground;
    Result.Text := TDACComponentColors.NeutralDark;
    Result.Border := TDACComponentColors.ControlBorder;
  end;
end;

class function TDACSemanticColors.SoftBackgroundFor(
  const AStatus: TDACSemanticStatus): TAlphaColor;
begin
  Result := ColorsFor(AStatus).SoftBackground;
end;

class function TDACSemanticColors.TextFor(
  const AStatus: TDACSemanticStatus): TAlphaColor;
begin
  Result := ColorsFor(AStatus).Text;
end;

end.

