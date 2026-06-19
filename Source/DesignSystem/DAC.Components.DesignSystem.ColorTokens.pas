unit MaxxRural.Components.DesignSystem.ColorTokens;

interface

uses
  System.TypInfo,
  System.UITypes,
  Vcl.Controls,
  Vcl.Graphics;

type
  TMaxxRuralColorTokens = record
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
    class function Default: TMaxxRuralColorTokens; static;
  end;

  TMaxxRuralComponentColors = class sealed
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

class function TMaxxRuralColorTokens.Default: TMaxxRuralColorTokens;
begin
  Result.Background := TMaxxRuralComponentColors.Background;
  Result.SurfaceDark := TMaxxRuralComponentColors.SurfaceDark;
  Result.Panel := TMaxxRuralComponentColors.Panel;
  Result.Border := TMaxxRuralComponentColors.Border;
  Result.Text := TMaxxRuralComponentColors.Text;
  Result.TextSecondary := TMaxxRuralComponentColors.TextSecondary;
  Result.White := TMaxxRuralComponentColors.White;
  Result.PrimaryDark := TMaxxRuralComponentColors.PrimaryDark;
  Result.Primary := TMaxxRuralComponentColors.Primary;
  Result.PrimaryLight := TMaxxRuralComponentColors.PrimaryLight;
  Result.InteractionHover := TMaxxRuralComponentColors.InteractionHover;
  Result.Warning := TMaxxRuralComponentColors.Warning;
  Result.Orange := TMaxxRuralComponentColors.Alpha(217, 139, 40);
  Result.Danger := TMaxxRuralComponentColors.Danger;
  Result.UserMenuHighlight := TMaxxRuralComponentColors.Alpha(18, 63, 24);
  Result.UserMenuDanger := TMaxxRuralComponentColors.Alpha(255, 138, 138);
end;

class function TMaxxRuralComponentColors.Alpha(const ARed, AGreen, ABlue: Byte;
  const AAlpha: Byte): TAlphaColor;
begin
  Result := TAlphaColor((Cardinal(AAlpha) shl 24) or
    (Cardinal(ARed) shl 16) or (Cardinal(AGreen) shl 8) or Cardinal(ABlue));
end;

class function TMaxxRuralComponentColors.Background: TAlphaColor;
begin
  Result := TAlphaColor($FF07130C);
end;

class function TMaxxRuralComponentColors.Border: TAlphaColor;
begin
  Result := TAlphaColor($FF2B3D31);
end;

class function TMaxxRuralComponentColors.ControlBackground: TAlphaColor;
begin
  Result := White;
end;

class function TMaxxRuralComponentColors.ControlBackgroundDisabled: TAlphaColor;
begin
  Result := Alpha(244, 247, 244);
end;

class function TMaxxRuralComponentColors.ControlBorder: TAlphaColor;
begin
  Result := Alpha(213, 219, 230);
end;

class function TMaxxRuralComponentColors.ControlBorderHover: TAlphaColor;
begin
  Result := TextSecondary;
end;

class function TMaxxRuralComponentColors.ControlText: TAlphaColor;
begin
  Result := Alpha(17, 24, 39);
end;

class function TMaxxRuralComponentColors.ControlTextDisabled: TAlphaColor;
begin
  Result := Alpha(148, 163, 184);
end;

class function TMaxxRuralComponentColors.ControlBackgroundForSurface(
  const ASurface: TAlphaColor): TAlphaColor;
begin
  if IsDarkSurface(ASurface) then
    Exit(SurfaceDark);
  Result := ControlBackground;
end;

class function TMaxxRuralComponentColors.ControlBackgroundDisabledForSurface(
  const ASurface: TAlphaColor): TAlphaColor;
begin
  if IsDarkSurface(ASurface) then
    Exit(Alpha(22, 43, 28));
  Result := ControlBackgroundDisabled;
end;

class function TMaxxRuralComponentColors.ControlBorderForSurface(
  const ASurface: TAlphaColor): TAlphaColor;
begin
  if IsDarkSurface(ASurface) then
    Exit(Border);
  Result := ControlBorder;
end;

class function TMaxxRuralComponentColors.ControlBorderHoverForSurface(
  const ASurface: TAlphaColor): TAlphaColor;
begin
  if IsDarkSurface(ASurface) then
    Exit(TextSecondary);
  Result := ControlBorderHover;
end;

class function TMaxxRuralComponentColors.ControlTextDisabledForSurface(
  const ASurface: TAlphaColor): TAlphaColor;
begin
  if IsDarkSurface(ASurface) then
    Exit(Alpha(112, 130, 116));
  Result := ControlTextDisabled;
end;

class function TMaxxRuralComponentColors.ControlTextForSurface(
  const ASurface: TAlphaColor): TAlphaColor;
begin
  if IsDarkSurface(ASurface) then
    Exit(Text);
  Result := ControlText;
end;

class function TMaxxRuralComponentColors.Danger: TAlphaColor;
begin
  Result := TAlphaColor($FFD94A3A);
end;

class function TMaxxRuralComponentColors.DangerDark: TAlphaColor;
begin
  Result := TAlphaColor($FFB93428);
end;

class function TMaxxRuralComponentColors.DangerLight: TAlphaColor;
begin
  Result := TAlphaColor($FFE85C4A);
end;

class function TMaxxRuralComponentColors.DarkPanelBackground: TAlphaColor;
begin
  Result := Panel;
end;

class function TMaxxRuralComponentColors.DarkPanelBorder: TAlphaColor;
begin
  Result := Border;
end;

class function TMaxxRuralComponentColors.FromVclColor(
  const AColor: TColor): TAlphaColor;
var
  LColorRef: TColorRef;
begin
  LColorRef := ColorToRGB(AColor);
  Result := TAlphaColor($FF000000 or ((LColorRef and $0000FF) shl 16) or
    (LColorRef and $00FF00) or ((LColorRef and $FF0000) shr 16));
end;

class function TMaxxRuralComponentColors.InteractionHover: TAlphaColor;
begin
  Result := TAlphaColor($FF1F3B23);
end;

class function TMaxxRuralComponentColors.IsDarkSurface(
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

class function TMaxxRuralComponentColors.Normalize(
  const AColor: TAlphaColor): TAlphaColor;
begin
  Result := AColor;
  if (Result <> Transparent) and ((Cardinal(Result) and $FF000000) = 0) then
    Result := TAlphaColor(Cardinal(Result) or $FF000000);
end;

class function TMaxxRuralComponentColors.Panel: TAlphaColor;
begin
  Result := TAlphaColor($FF102417);
end;

class function TMaxxRuralComponentColors.Primary: TAlphaColor;
begin
  Result := TAlphaColor($FF3DB82A);
end;

class function TMaxxRuralComponentColors.PrimaryDark: TAlphaColor;
begin
  Result := TAlphaColor($FF2F9E22);
end;

class function TMaxxRuralComponentColors.PrimaryFocus: TAlphaColor;
begin
  Result := TAlphaColor($FF48C934);
end;

class function TMaxxRuralComponentColors.PrimaryLight: TAlphaColor;
begin
  Result := TAlphaColor($FF74D64A);
end;

class function TMaxxRuralComponentColors.ResolveParentSurface(
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

class function TMaxxRuralComponentColors.SuiteSectionBackground: TAlphaColor;
begin
  Result := White;
end;

class function TMaxxRuralComponentColors.SuiteSectionBorder: TAlphaColor;
begin
  Result := ControlBorder;
end;

class function TMaxxRuralComponentColors.SuiteSectionSubtitle: TAlphaColor;
begin
  Result := Alpha(71, 85, 105);
end;

class function TMaxxRuralComponentColors.SuiteSectionTitle: TAlphaColor;
begin
  Result := Alpha(15, 23, 42);
end;

class function TMaxxRuralComponentColors.SurfaceDark: TAlphaColor;
begin
  Result := TAlphaColor($FF08140D);
end;

class function TMaxxRuralComponentColors.Text: TAlphaColor;
begin
  Result := TAlphaColor($FFE8EEE8);
end;

class function TMaxxRuralComponentColors.TextSecondary: TAlphaColor;
begin
  Result := TAlphaColor($FFB8C4B8);
end;

class function TMaxxRuralComponentColors.ToVclColor(
  const AColor: TAlphaColor): TColor;
var
  LColor: Cardinal;
begin
  LColor := Cardinal(Normalize(AColor));
  Result := TColor(((LColor and $0000FF) shl 16) or
    (LColor and $00FF00) or ((LColor and $FF0000) shr 16));
end;

class function TMaxxRuralComponentColors.Transparent: TAlphaColor;
begin
  Result := TAlphaColorRec.Null;
end;

class function TMaxxRuralComponentColors.Warning: TAlphaColor;
begin
  Result := TAlphaColor($FFF5C842);
end;

class function TMaxxRuralComponentColors.WarningDark: TAlphaColor;
begin
  Result := Alpha(217, 139, 40);
end;

class function TMaxxRuralComponentColors.WarningLight: TAlphaColor;
begin
  Result := Alpha(255, 213, 79);
end;

class function TMaxxRuralComponentColors.White: TAlphaColor;
begin
  Result := TAlphaColor($FFFFFFFF);
end;

end.
