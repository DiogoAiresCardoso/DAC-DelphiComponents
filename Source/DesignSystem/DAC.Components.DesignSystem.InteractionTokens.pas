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
  Result.PressedColor := TAlphaColor($FF4DAA33);
  Result.FocusColor := TAlphaColor($FF4CD964);
  Result.FocusStrokeColor := TAlphaColor($FF4CD964);
  Result.HoverOpacity := 100;
  Result.PressedOpacity := 120;
  Result.FocusOpacity := 190;
end;

end.

