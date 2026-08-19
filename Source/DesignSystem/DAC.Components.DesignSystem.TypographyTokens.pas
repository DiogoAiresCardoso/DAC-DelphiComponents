unit DAC.Components.DesignSystem.TypographyTokens;

interface

type
  TDACTypographyTokens = record
    FontFamily: string;
    Title1Size: Single;
    Title2Size: Single;
    Title3Size: Single;
    TextSize: Single;
    TextSecondarySize: Single;
    CaptionSize: Single;
    SmallTextSize: Single;
    DisplaySize: Single;
    TabTextSize: Single;
    GridTextSize: Single;
    MetricSize: Single;
    class function Default: TDACTypographyTokens; static;
  end;

implementation

uses
  DAC.Components.DesignSystem.Fonts;

class function TDACTypographyTokens.Default: TDACTypographyTokens;
begin
  Result.FontFamily := TDACComponentFontInstaller.FontFamily;
  Result.Title1Size := 22;
  Result.Title2Size := 16;
  Result.Title3Size := 13;
  Result.TextSize := 11;
  Result.TextSecondarySize := 10;
  Result.CaptionSize := 9;
  Result.SmallTextSize := 10;
  Result.DisplaySize := 20;
  Result.TabTextSize := 12;
  Result.GridTextSize := 12;
  Result.MetricSize := 18;
end;

end.

