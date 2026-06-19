unit MaxxRural.Components.DesignSystem.OpacityTokens;

interface

type
  TMaxxRuralOpacityTokens = record
    Panel: Byte;
    Chrome: Byte;
    Border: Byte;
    WindowBorder: Byte;
    WindowShadow: Byte;
    BackgroundDarkOverlay: Byte;
    BackgroundGreenOverlay: Byte;
    class function Default: TMaxxRuralOpacityTokens; static;
  end;

implementation

class function TMaxxRuralOpacityTokens.Default: TMaxxRuralOpacityTokens;
begin
  Result.Panel := 240;
  Result.Chrome := 150;
  Result.Border := 128;
  Result.WindowBorder := 220;
  Result.WindowShadow := 48;
  Result.BackgroundDarkOverlay := 136;
  Result.BackgroundGreenOverlay := 48;
end;

end.
