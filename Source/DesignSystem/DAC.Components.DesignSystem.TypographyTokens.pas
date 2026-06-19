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
  Result.TextSize := 9;
  Result.TextSecondarySize := 8;
  Result.CaptionSize := 8;
  Result.MetricSize := 18;
end;

end.

