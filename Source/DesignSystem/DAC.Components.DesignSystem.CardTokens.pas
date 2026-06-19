unit MaxxRural.Components.DesignSystem.CardTokens;

interface

uses
  System.UITypes;

type
  TMaxxRuralCardTokens = record
    DefaultOpacity: Byte;
    HoveredOpacity: Byte;
    PressedOpacity: Byte;
    BorderDefaultOpacity: Byte;
    BorderHoveredOpacity: Byte;
    BorderPressedOpacity: Byte;
    HoverColor: TAlphaColor;
    PressedColor: TAlphaColor;
    FocusColor: TAlphaColor;
    class function Default: TMaxxRuralCardTokens; static;
  end;

implementation

class function TMaxxRuralCardTokens.Default: TMaxxRuralCardTokens;
begin
  Result.DefaultOpacity := 176;
  Result.HoveredOpacity := 196;
  Result.PressedOpacity := 220;
  Result.BorderDefaultOpacity := 170;
  Result.BorderHoveredOpacity := 190;
  Result.BorderPressedOpacity := 210;
  Result.HoverColor := TAlphaColor($FF3DB82A);
  Result.PressedColor := TAlphaColor($FF2F9E22);
  Result.FocusColor := TAlphaColor($FF74D64A);
end;

end.
