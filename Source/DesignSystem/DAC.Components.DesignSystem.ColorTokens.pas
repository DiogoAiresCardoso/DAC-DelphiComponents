unit DAC.Components.DesignSystem.ColorTokens;

interface

uses
  System.TypInfo,
  System.UITypes,
  Vcl.Controls,
  Vcl.Graphics;

type
  TDACColorTokens = record
    Background: TAlphaColor;
    SurfaceDark: TAlphaColor;
    Panel: TAlphaColor;
    Border: TAlphaColor;
    Text: TAlphaColor;
    TextSecondary: TAlphaColor;
    White: TAlphaColor;
    PrimaryDark: TAlphaColor;
    Primary: TAlphaColor;
    PrimaryLight: TAlphaColor;
    InteractionHover: TAlphaColor;
    Warning: TAlphaColor;
    Orange: TAlphaColor;
    Danger: TAlphaColor;
    UserMenuHighlight: TAlphaColor;
    UserMenuDanger: TAlphaColor;
    class function Default: TDACColorTokens; static;
  end;

  TDACComponentColors = class sealed
  public
    class function Alpha(const ARed, AGreen, ABlue: Byte;
      const AAlpha: Byte = 255): TAlphaColor; static;
    class function Normalize(const AColor: TAlphaColor): TAlphaColor; static;
    class function FromVclColor(const AColor: TColor): TAlphaColor; static;
    class function ToVclColor(const AColor: TAlphaColor): TColor; static;
    class function ResolveParentSurface(const AControl: TControl): TAlphaColor; static;

    class function Transparent: TAlphaColor; static;
    class function Background: TAlphaColor; static;
    class function SurfaceDark: TAlphaColor; static;
    class function Panel: TAlphaColor; static;
    class function Border: TAlphaColor; static;
    class function Text: TAlphaColor; static;
    class function TextSecondary: TAlphaColor; static;
    class function White: TAlphaColor; static;
    class function PrimaryDark: TAlphaColor; static;
    class function Primary: TAlphaColor; static;
    class function PrimaryFocus: TAlphaColor; static;
    class function PrimaryLight: TAlphaColor; static;
    class function InteractionHover: TAlphaColor; static;
    class function Danger: TAlphaColor; static;
    class function DangerDark: TAlphaColor; static;
    class function DangerLight: TAlphaColor; static;
    class function Warning: TAlphaColor; static;
    class function WarningDark: TAlphaColor; static;
    class function WarningLight: TAlphaColor; static;

    class function SuiteSectionBackground: TAlphaColor; static;
    class function SuiteSectionBorder: TAlphaColor; static;
    class function SuiteSectionTitle: TAlphaColor; static;
    class function SuiteSectionSubtitle: TAlphaColor; static;
    class function DarkPanelBackground: TAlphaColor; static;
    class function DarkPanelBorder: TAlphaColor; static;
    class function ControlBackground: TAlphaColor; static;
    class function ControlBackgroundDisabled: TAlphaColor; static;
    class function ControlBorder: TAlphaColor; static;
    class function ControlBorderHover: TAlphaColor; static;
    class function ControlText: TAlphaColor; static;
    class function ControlTextDisabled: TAlphaColor; static;
    class function IsDarkSurface(const AColor: TAlphaColor): Boolean; static;
    class function ControlBackgroundForSurface(const ASurface: TAlphaColor): TAlphaColor; static;
    class function ControlBackgroundDisabledForSurface(const ASurface: TAlphaColor): TAlphaColor; static;
    class function ControlBorderForSurface(const ASurface: TAlphaColor): TAlphaColor; static;
    class function ControlBorderHoverForSurface(const ASurface: TAlphaColor): TAlphaColor; static;
    class function ControlTextForSurface(const ASurface: TAlphaColor): TAlphaColor; static;
    class function ControlTextDisabledForSurface(const ASurface: TAlphaColor): TAlphaColor; static;
  end;

implementation

function TryReadPublishedColor(const AControl: TControl; out AColor: TColor): Boolean;
var
  LPropInfo: PPropInfo;
begin
  Result := False;
  AColor := clNone;

  if AControl = nil then
    Exit;

  LPropInfo := GetPropInfo(AControl, 'Color');
  if LPropInfo = nil then
    Exit;

  AColor := TColor(GetOrdProp(AControl, LPropInfo));
  Result := (AColor <> clNone) and (AColor <> clDefault);
end;

class function TDACColorTokens.Default: TDACColorTokens;
begin
  Result.Background := TDACComponentColors.Background;
  Result.SurfaceDark := TDACComponentColors.SurfaceDark;
  Result.Panel := TDACComponentColors.Panel;
  Result.Border := TDACComponentColors.Border;
  Result.Text := TDACComponentColors.Text;
  Result.TextSecondary := TDACComponentColors.TextSecondary;
  Result.White := TDACComponentColors.White;
  Result.PrimaryDark := TDACComponentColors.PrimaryDark;
  Result.Primary := TDACComponentColors.Primary;
  Result.PrimaryLight := TDACComponentColors.PrimaryLight;
  Result.InteractionHover := TDACComponentColors.InteractionHover;
  Result.Warning := TDACComponentColors.Warning;
  Result.Orange := TDACComponentColors.Alpha(217, 139, 40);
  Result.Danger := TDACComponentColors.Danger;
  Result.UserMenuHighlight := TDACComponentColors.Alpha(18, 63, 24);
  Result.UserMenuDanger := TDACComponentColors.Alpha(255, 138, 138);
end;

class function TDACComponentColors.Alpha(const ARed, AGreen, ABlue: Byte;
  const AAlpha: Byte): TAlphaColor;
begin
  Result := TAlphaColor((Cardinal(AAlpha) shl 24) or
    (Cardinal(ARed) shl 16) or (Cardinal(AGreen) shl 8) or Cardinal(ABlue));
end;

class function TDACComponentColors.Background: TAlphaColor;
begin
  Result := TAlphaColor($FF07130C);
end;

class function TDACComponentColors.Border: TAlphaColor;
begin
  Result := TAlphaColor($FF2B3D31);
end;

class function TDACComponentColors.ControlBackground: TAlphaColor;
begin
  Result := White;
end;

class function TDACComponentColors.ControlBackgroundDisabled: TAlphaColor;
begin
  Result := Alpha(244, 247, 244);
end;

class function TDACComponentColors.ControlBorder: TAlphaColor;
begin
  Result := Alpha(213, 219, 230);
end;

class function TDACComponentColors.ControlBorderHover: TAlphaColor;
begin
  Result := TextSecondary;
end;

class function TDACComponentColors.ControlText: TAlphaColor;
begin
  Result := Alpha(17, 24, 39);
end;

class function TDACComponentColors.ControlTextDisabled: TAlphaColor;
begin
  Result := Alpha(148, 163, 184);
end;

class function TDACComponentColors.ControlBackgroundForSurface(
  const ASurface: TAlphaColor): TAlphaColor;
begin
  if IsDarkSurface(ASurface) then
    Exit(SurfaceDark);
  Result := ControlBackground;
end;

class function TDACComponentColors.ControlBackgroundDisabledForSurface(
  const ASurface: TAlphaColor): TAlphaColor;
begin
  if IsDarkSurface(ASurface) then
    Exit(Alpha(22, 43, 28));
  Result := ControlBackgroundDisabled;
end;

class function TDACComponentColors.ControlBorderForSurface(
  const ASurface: TAlphaColor): TAlphaColor;
begin
  if IsDarkSurface(ASurface) then
    Exit(Border);
  Result := ControlBorder;
end;

class function TDACComponentColors.ControlBorderHoverForSurface(
  const ASurface: TAlphaColor): TAlphaColor;
begin
  if IsDarkSurface(ASurface) then
    Exit(TextSecondary);
  Result := ControlBorderHover;
end;

class function TDACComponentColors.ControlTextDisabledForSurface(
  const ASurface: TAlphaColor): TAlphaColor;
begin
  if IsDarkSurface(ASurface) then
    Exit(Alpha(112, 130, 116));
  Result := ControlTextDisabled;
end;

class function TDACComponentColors.ControlTextForSurface(
  const ASurface: TAlphaColor): TAlphaColor;
begin
  if IsDarkSurface(ASurface) then
    Exit(Text);
  Result := ControlText;
end;

class function TDACComponentColors.Danger: TAlphaColor;
begin
  Result := TAlphaColor($FFD94A3A);
end;

class function TDACComponentColors.DangerDark: TAlphaColor;
begin
  Result := TAlphaColor($FFB93428);
end;

class function TDACComponentColors.DangerLight: TAlphaColor;
begin
  Result := TAlphaColor($FFE85C4A);
end;

class function TDACComponentColors.DarkPanelBackground: TAlphaColor;
begin
  Result := Panel;
end;

class function TDACComponentColors.DarkPanelBorder: TAlphaColor;
begin
  Result := Border;
end;

class function TDACComponentColors.FromVclColor(
  const AColor: TColor): TAlphaColor;
var
  LColorRef: TColorRef;
begin
  LColorRef := ColorToRGB(AColor);
  Result := TAlphaColor($FF000000 or ((LColorRef and $0000FF) shl 16) or
    (LColorRef and $00FF00) or ((LColorRef and $FF0000) shr 16));
end;

class function TDACComponentColors.InteractionHover: TAlphaColor;
begin
  Result := TAlphaColor($FF1F3B23);
end;

class function TDACComponentColors.IsDarkSurface(
  const AColor: TAlphaColor): Boolean;
var
  LColor: Cardinal;
  LBlue: Byte;
  LGreen: Byte;
  LRed: Byte;
  LLuminance: Integer;
begin
  LColor := Cardinal(Normalize(AColor));
  LRed := Byte((LColor and $00FF0000) shr 16);
  LGreen := Byte((LColor and $0000FF00) shr 8);
  LBlue := Byte(LColor and $000000FF);
  LLuminance := (Integer(LRed) * 299 + Integer(LGreen) * 587 +
    Integer(LBlue) * 114) div 1000;
  Result := LLuminance < 96;
end;

class function TDACComponentColors.Normalize(
  const AColor: TAlphaColor): TAlphaColor;
begin
  Result := AColor;
  if (Result <> Transparent) and ((Cardinal(Result) and $FF000000) = 0) then
    Result := TAlphaColor(Cardinal(Result) or $FF000000);
end;

class function TDACComponentColors.Panel: TAlphaColor;
begin
  Result := TAlphaColor($FF102417);
end;

class function TDACComponentColors.Primary: TAlphaColor;
begin
  Result := TAlphaColor($FF3DB82A);
end;

class function TDACComponentColors.PrimaryDark: TAlphaColor;
begin
  Result := TAlphaColor($FF2F9E22);
end;

class function TDACComponentColors.PrimaryFocus: TAlphaColor;
begin
  Result := TAlphaColor($FF48C934);
end;

class function TDACComponentColors.PrimaryLight: TAlphaColor;
begin
  Result := TAlphaColor($FF74D64A);
end;

class function TDACComponentColors.ResolveParentSurface(
  const AControl: TControl): TAlphaColor;
var
  LControl: TControl;
  LColor: TColor;
begin
  Result := White;
  LControl := nil;
  if AControl <> nil then
    LControl := AControl.Parent;

  while LControl <> nil do
  begin
    if TryReadPublishedColor(LControl, LColor) then
      Exit(FromVclColor(LColor));
    LControl := LControl.Parent;
  end;

  if TryReadPublishedColor(AControl, LColor) then
    Result := FromVclColor(LColor);
end;

class function TDACComponentColors.SuiteSectionBackground: TAlphaColor;
begin
  Result := White;
end;

class function TDACComponentColors.SuiteSectionBorder: TAlphaColor;
begin
  Result := ControlBorder;
end;

class function TDACComponentColors.SuiteSectionSubtitle: TAlphaColor;
begin
  Result := Alpha(71, 85, 105);
end;

class function TDACComponentColors.SuiteSectionTitle: TAlphaColor;
begin
  Result := Alpha(15, 23, 42);
end;

class function TDACComponentColors.SurfaceDark: TAlphaColor;
begin
  Result := TAlphaColor($FF08140D);
end;

class function TDACComponentColors.Text: TAlphaColor;
begin
  Result := TAlphaColor($FFE8EEE8);
end;

class function TDACComponentColors.TextSecondary: TAlphaColor;
begin
  Result := TAlphaColor($FFB8C4B8);
end;

class function TDACComponentColors.ToVclColor(
  const AColor: TAlphaColor): TColor;
var
  LColor: Cardinal;
begin
  LColor := Cardinal(Normalize(AColor));
  Result := TColor(((LColor and $0000FF) shl 16) or
    (LColor and $00FF00) or ((LColor and $FF0000) shr 16));
end;

class function TDACComponentColors.Transparent: TAlphaColor;
begin
  Result := TAlphaColorRec.Null;
end;

class function TDACComponentColors.Warning: TAlphaColor;
begin
  Result := TAlphaColor($FFF5C842);
end;

class function TDACComponentColors.WarningDark: TAlphaColor;
begin
  Result := Alpha(217, 139, 40);
end;

class function TDACComponentColors.WarningLight: TAlphaColor;
begin
  Result := Alpha(255, 213, 79);
end;

class function TDACComponentColors.White: TAlphaColor;
begin
  Result := TAlphaColor($FFFFFFFF);
end;

end.

