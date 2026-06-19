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
        Result.Accent := TDACComponentColors.Alpha(37, 99, 235);
        Result.AccentDark := TDACComponentColors.Alpha(29, 78, 216);
        Result.AccentLight := TDACComponentColors.Alpha(96, 165, 250);
        Result.SoftBackground := TDACComponentColors.Alpha(226, 239, 255);
        Result.Text := TDACComponentColors.Alpha(29, 78, 216);
        Result.Border := TDACComponentColors.Alpha(174, 206, 255);
      end;
  else
    Result.Accent := TDACComponentColors.TextSecondary;
    Result.AccentDark := TDACComponentColors.ControlText;
    Result.AccentLight := TDACComponentColors.ControlBorderHover;
    Result.SoftBackground := TDACComponentColors.Alpha(244, 247, 244);
    Result.Text := TDACComponentColors.ControlText;
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

