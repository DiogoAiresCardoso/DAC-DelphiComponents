unit MaxxRural.Components.DesignSystem.SemanticColors;

interface

uses
  System.UITypes;

type
  TMaxxRuralSemanticStatus = (
    mssNeutral,
    mssSuccess,
    mssWarning,
    mssDanger,
    mssInfo
  );

  TMaxxRuralSemanticColorSet = record
    Accent: TAlphaColor;
    AccentDark: TAlphaColor;
    AccentLight: TAlphaColor;
    SoftBackground: TAlphaColor;
    Text: TAlphaColor;
    Border: TAlphaColor;
  end;

  TMaxxRuralSemanticColors = class sealed
  public
    class function ColorsFor(const AStatus: TMaxxRuralSemanticStatus): TMaxxRuralSemanticColorSet; static;
    class function AccentFor(const AStatus: TMaxxRuralSemanticStatus): TAlphaColor; static;
    class function SoftBackgroundFor(const AStatus: TMaxxRuralSemanticStatus): TAlphaColor; static;
    class function TextFor(const AStatus: TMaxxRuralSemanticStatus): TAlphaColor; static;
  end;

implementation

uses
  MaxxRural.Components.DesignSystem.ColorTokens;

class function TMaxxRuralSemanticColors.AccentFor(
  const AStatus: TMaxxRuralSemanticStatus): TAlphaColor;
begin
  Result := ColorsFor(AStatus).Accent;
end;

class function TMaxxRuralSemanticColors.ColorsFor(
  const AStatus: TMaxxRuralSemanticStatus): TMaxxRuralSemanticColorSet;
begin
  case AStatus of
    mssSuccess:
      begin
        Result.Accent := TMaxxRuralComponentColors.Primary;
        Result.AccentDark := TMaxxRuralComponentColors.PrimaryDark;
        Result.AccentLight := TMaxxRuralComponentColors.PrimaryLight;
        Result.SoftBackground := TMaxxRuralComponentColors.Alpha(232, 247, 229);
        Result.Text := TMaxxRuralComponentColors.PrimaryDark;
        Result.Border := TMaxxRuralComponentColors.Alpha(185, 228, 174);
      end;
    mssWarning:
      begin
        Result.Accent := TMaxxRuralComponentColors.Warning;
        Result.AccentDark := TMaxxRuralComponentColors.WarningDark;
        Result.AccentLight := TMaxxRuralComponentColors.WarningLight;
        Result.SoftBackground := TMaxxRuralComponentColors.Alpha(255, 247, 218);
        Result.Text := TMaxxRuralComponentColors.WarningDark;
        Result.Border := TMaxxRuralComponentColors.Alpha(246, 206, 127);
      end;
    mssDanger:
      begin
        Result.Accent := TMaxxRuralComponentColors.Danger;
        Result.AccentDark := TMaxxRuralComponentColors.DangerDark;
        Result.AccentLight := TMaxxRuralComponentColors.DangerLight;
        Result.SoftBackground := TMaxxRuralComponentColors.Alpha(253, 232, 230);
        Result.Text := TMaxxRuralComponentColors.DangerDark;
        Result.Border := TMaxxRuralComponentColors.Alpha(238, 177, 170);
      end;
    mssInfo:
      begin
        Result.Accent := TMaxxRuralComponentColors.Alpha(37, 99, 235);
        Result.AccentDark := TMaxxRuralComponentColors.Alpha(29, 78, 216);
        Result.AccentLight := TMaxxRuralComponentColors.Alpha(96, 165, 250);
        Result.SoftBackground := TMaxxRuralComponentColors.Alpha(226, 239, 255);
        Result.Text := TMaxxRuralComponentColors.Alpha(29, 78, 216);
        Result.Border := TMaxxRuralComponentColors.Alpha(174, 206, 255);
      end;
  else
    Result.Accent := TMaxxRuralComponentColors.TextSecondary;
    Result.AccentDark := TMaxxRuralComponentColors.ControlText;
    Result.AccentLight := TMaxxRuralComponentColors.ControlBorderHover;
    Result.SoftBackground := TMaxxRuralComponentColors.Alpha(244, 247, 244);
    Result.Text := TMaxxRuralComponentColors.ControlText;
    Result.Border := TMaxxRuralComponentColors.ControlBorder;
  end;
end;

class function TMaxxRuralSemanticColors.SoftBackgroundFor(
  const AStatus: TMaxxRuralSemanticStatus): TAlphaColor;
begin
  Result := ColorsFor(AStatus).SoftBackground;
end;

class function TMaxxRuralSemanticColors.TextFor(
  const AStatus: TMaxxRuralSemanticStatus): TAlphaColor;
begin
  Result := ColorsFor(AStatus).Text;
end;

end.
