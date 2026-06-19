unit MaxxRural.Components.DesignSystem.TypographyTokens;

interface

type
  TMaxxRuralTypographyTokens = record
    FontFamily: string;
    Title1Size: Single;
    Title2Size: Single;
    Title3Size: Single;
    TextSize: Single;
    TextSecondarySize: Single;
    CaptionSize: Single;
    MetricSize: Single;
    class function Default: TMaxxRuralTypographyTokens; static;
  end;

implementation

uses
  MaxxRural.Components.DesignSystem.Fonts;

class function TMaxxRuralTypographyTokens.Default: TMaxxRuralTypographyTokens;
begin
  Result.FontFamily := TMaxxRuralComponentFontInstaller.FontFamily;
  Result.Title1Size := 22;
  Result.Title2Size := 16;
  Result.Title3Size := 13;
  Result.TextSize := 9;
  Result.TextSecondarySize := 8;
  Result.CaptionSize := 8;
  Result.MetricSize := 18;
end;

end.
