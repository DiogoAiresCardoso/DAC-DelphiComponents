unit DAC.Components.DesignSystem.OpacityTokens;

interface

const
  DACOpacityTransparent = 0;
  DACOpacityOpaque = 255;

type
  TDACOpacityTokens = record
    Panel: Byte;
    Chrome: Byte;
    Border: Byte;
    WindowBorder: Byte;
    WindowShadow: Byte;
    BackgroundDarkOverlay: Byte;
    BackgroundGreenOverlay: Byte;
    GhostHover: Byte;
    SurfaceHover: Byte;
    Disabled: Byte;
    class function Default: TDACOpacityTokens; static;
  end;

implementation

class function TDACOpacityTokens.Default: TDACOpacityTokens;
begin
  Result.Panel := 240;
  Result.Chrome := 150;
  Result.Border := 128;
  Result.WindowBorder := 220;
  Result.WindowShadow := 48;
  Result.BackgroundDarkOverlay := 136;
  Result.BackgroundGreenOverlay := 48;
  Result.GhostHover := 31;
  Result.SurfaceHover := 26;
  Result.Disabled := 115;
end;

end.

