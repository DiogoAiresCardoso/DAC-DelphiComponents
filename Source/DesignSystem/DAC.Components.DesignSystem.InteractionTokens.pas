unit DAC.Components.DesignSystem.InteractionTokens;

interface

uses
  System.UITypes;

type
  TDACInteractionTokens = record
    HoverColor: TAlphaColor;
    PressedColor: TAlphaColor;
    FocusColor: TAlphaColor;
    FocusStrokeColor: TAlphaColor;
    HoverOpacity: Byte;
    PressedOpacity: Byte;
    FocusOpacity: Byte;
    class function Default: TDACInteractionTokens; static;
  end;

implementation

class function TDACInteractionTokens.Default: TDACInteractionTokens;
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

