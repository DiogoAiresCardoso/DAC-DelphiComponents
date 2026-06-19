unit MaxxRural.Components.DesignSystem.InteractionTokens;

interface

uses
  System.UITypes;

type
  TMaxxRuralInteractionTokens = record
    HoverColor: TAlphaColor;
    PressedColor: TAlphaColor;
    FocusColor: TAlphaColor;
    FocusStrokeColor: TAlphaColor;
    HoverOpacity: Byte;
    PressedOpacity: Byte;
    FocusOpacity: Byte;
    class function Default: TMaxxRuralInteractionTokens; static;
  end;

implementation

class function TMaxxRuralInteractionTokens.Default: TMaxxRuralInteractionTokens;
begin
  Result.HoverColor := TAlphaColor($FF1F3B23);
  Result.PressedColor := TAlphaColor($FF3DB82A);
  Result.FocusColor := TAlphaColor($FF74D64A);
  Result.FocusStrokeColor := TAlphaColor($FF74D64A);
  Result.HoverOpacity := 100;
  Result.PressedOpacity := 120;
  Result.FocusOpacity := 190;
end;

end.
