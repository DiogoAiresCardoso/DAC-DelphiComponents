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
    ControlBackground: TAlphaColor;
    ControlBackgroundDisabled: TAlphaColor;
    ControlBorder: TAlphaColor;
    ControlBorderHover: TAlphaColor;
    ControlText: TAlphaColor;
    ControlTextDisabled: TAlphaColor;
    ButtonLoadingBackground: TAlphaColor;
    ButtonLoadingText: TAlphaColor;
    PrimaryFocus: TAlphaColor;
    DangerDark: TAlphaColor;
    DangerLight: TAlphaColor;
    WarningDark: TAlphaColor;
    WarningLight: TAlphaColor;
    SuiteSectionSubtitle: TAlphaColor;
    SuiteSectionTitle: TAlphaColor;
    GridHeader: TAlphaColor;
    Info: TAlphaColor;
    InfoDark: TAlphaColor;
    InfoLight: TAlphaColor;
    InfoSoftBackground: TAlphaColor;
    InfoText: TAlphaColor;
    InfoBorder: TAlphaColor;
    Neutral: TAlphaColor;
    NeutralDark: TAlphaColor;
    NeutralLight: TAlphaColor;
    NeutralSoftBackground: TAlphaColor;
    class function Default: TDACColorTokens; static;
  end;

  TDACColorTokensProvider = function: TDACColorTokens;

  TDACComponentColors = class sealed
  public
    class procedure SetTokensProvider(const AProvider: TDACColorTokensProvider); static;
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
    class function ContrastRatio(const AForeground, ABackground: TAlphaColor): Double; static;
    class function GridHeader: TAlphaColor; static;
    class function Info: TAlphaColor; static;
    class function InfoDark: TAlphaColor; static;
    class function InfoLight: TAlphaColor; static;
    class function InfoSoftBackground: TAlphaColor; static;
    class function InfoText: TAlphaColor; static;
    class function InfoBorder: TAlphaColor; static;
    class function Neutral: TAlphaColor; static;
    class function NeutralDark: TAlphaColor; static;
    class function NeutralLight: TAlphaColor; static;
    class function NeutralSoftBackground: TAlphaColor; static;
    class function IsDarkSurface(const AColor: TAlphaColor): Boolean; static;
    class function ControlBackgroundForSurface(const ASurface: TAlphaColor): TAlphaColor; static;
    class function ControlBackgroundDisabledForSurface(const ASurface: TAlphaColor): TAlphaColor; static;
    class function ControlBorderForSurface(const ASurface: TAlphaColor): TAlphaColor; static;
    class function ControlBorderHoverForSurface(const ASurface: TAlphaColor): TAlphaColor; static;
    class function ControlTextForSurface(const ASurface: TAlphaColor): TAlphaColor; static;
    class function ControlTextDisabledForSurface(const ASurface: TAlphaColor): TAlphaColor; static;
  end;

implementation

uses
  System.Math;

var
  GTokensProvider: TDACColorTokensProvider;

function CurrentTokens: TDACColorTokens;
begin
  if Assigned(GTokensProvider) then
    Result := GTokensProvider()
  else
    Result := TDACColorTokens.Default;
end;

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
  Result.Background := TAlphaColor($FF07130C);
  Result.SurfaceDark := TAlphaColor($FF08140D);
  Result.Panel := TAlphaColor($FF102417);
  Result.Border := TAlphaColor($FF2B3D31);
  Result.Text := TAlphaColor($FFE8EEE8);
  Result.TextSecondary := TAlphaColor($FFB8C4B8);
  Result.White := TAlphaColor($FFFFFFFF);
  Result.PrimaryDark := TAlphaColor($FF2F9E22);
  Result.Primary := TAlphaColor($FF3DB82A);
  Result.PrimaryLight := TAlphaColor($FF74D64A);
  Result.InteractionHover := TAlphaColor($FF1F3B23);
  Result.Warning := TAlphaColor($FFF5C842);
  Result.Orange := TAlphaColor($FFD98B28);
  Result.Danger := TAlphaColor($FFD94A3A);
  Result.UserMenuHighlight := TAlphaColor($FF123F18);
  Result.UserMenuDanger := TAlphaColor($FFFF8A8A);
  Result.ControlBackground := Result.White;
  // Disabled controls need to be visibly inactive without turning their
  // label into low-contrast placeholder text. These opaque values are also
  // safe to use when the control chrome is painted by Skia.
  Result.ControlBackgroundDisabled := TAlphaColor($FFE2E8E2);
  Result.ControlBorder := TAlphaColor($FFD5DBE6);
  Result.ControlBorderHover := Result.TextSecondary;
  Result.ControlText := TAlphaColor($FF111827);
  Result.ControlTextDisabled := TAlphaColor($FF475569);
  Result.ButtonLoadingBackground := TAlphaColor($FF1D6B18);
  Result.ButtonLoadingText := Result.White;
  Result.PrimaryFocus := TAlphaColor($FF48C934);
  Result.DangerDark := TAlphaColor($FFB93428);
  Result.DangerLight := TAlphaColor($FFE85C4A);
  Result.WarningDark := Result.Orange;
  Result.WarningLight := TAlphaColor($FFFFD54F);
  Result.SuiteSectionSubtitle := TAlphaColor($FF475569);
  Result.SuiteSectionTitle := TAlphaColor($FF0F172A);
  Result.GridHeader := TAlphaColor($FF111827);
  Result.Info := TAlphaColor($FF2B7DE9);
  Result.InfoDark := TAlphaColor($FF1C5EA8);
  Result.InfoLight := TAlphaColor($FF60A5FA);
  Result.InfoSoftBackground := TAlphaColor($FFE5F1FF);
  Result.InfoText := TAlphaColor($FF1D4ED8);
  Result.InfoBorder := TAlphaColor($FFAECEFF);
  Result.Neutral := Result.SuiteSectionSubtitle;
  Result.NeutralDark := TAlphaColor($FF334155);
  Result.NeutralLight := Result.ControlBorderHover;
  Result.NeutralSoftBackground := TAlphaColor($FFF1F5F9);
end;

class function TDACComponentColors.Alpha(const ARed, AGreen, ABlue: Byte;
  const AAlpha: Byte): TAlphaColor;
begin
  Result := TAlphaColor((Cardinal(AAlpha) shl 24) or
    (Cardinal(ARed) shl 16) or (Cardinal(AGreen) shl 8) or Cardinal(ABlue));
end;

class procedure TDACComponentColors.SetTokensProvider(
  const AProvider: TDACColorTokensProvider);
begin
  GTokensProvider := AProvider;
end;

class function TDACComponentColors.Background: TAlphaColor;
begin
  Result := CurrentTokens.Background;
end;

class function TDACComponentColors.Border: TAlphaColor;
begin
  Result := CurrentTokens.Border;
end;

class function TDACComponentColors.ControlBackground: TAlphaColor;
begin
  Result := CurrentTokens.ControlBackground;
end;

class function TDACComponentColors.ControlBackgroundDisabled: TAlphaColor;
begin
  Result := CurrentTokens.ControlBackgroundDisabled;
end;

class function TDACComponentColors.ControlBorder: TAlphaColor;
begin
  Result := CurrentTokens.ControlBorder;
end;

class function TDACComponentColors.ControlBorderHover: TAlphaColor;
begin
  Result := CurrentTokens.ControlBorderHover;
end;

class function TDACComponentColors.ControlText: TAlphaColor;
begin
  Result := CurrentTokens.ControlText;
end;

class function TDACComponentColors.ControlTextDisabled: TAlphaColor;
begin
  Result := CurrentTokens.ControlTextDisabled;
end;

class function TDACComponentColors.ContrastRatio(const AForeground,
  ABackground: TAlphaColor): Double;
  function ChannelLuminance(const AValue: Byte): Double;
  var
    LChannel: Double;
  begin
    LChannel := AValue / 255;
    if LChannel <= 0.04045 then
      Exit(LChannel / 12.92);
    Result := Power((LChannel + 0.055) / 1.055, 2.4);
  end;
  function RelativeLuminance(const AColor: TAlphaColor): Double;
  var
    LColor: Cardinal;
  begin
    LColor := Cardinal(Normalize(AColor));
    Result := (0.2126 * ChannelLuminance(Byte((LColor shr 16) and $FF))) +
      (0.7152 * ChannelLuminance(Byte((LColor shr 8) and $FF))) +
      (0.0722 * ChannelLuminance(Byte(LColor and $FF)));
  end;
var
  LForeground: Double;
  LBackground: Double;
begin
  LForeground := RelativeLuminance(AForeground);
  LBackground := RelativeLuminance(ABackground);
  if LForeground < LBackground then
    Result := (LBackground + 0.05) / (LForeground + 0.05)
  else
    Result := (LForeground + 0.05) / (LBackground + 0.05);
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
    Exit(TextSecondary);
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
  Result := CurrentTokens.Danger;
end;

class function TDACComponentColors.DangerDark: TAlphaColor;
begin
  Result := CurrentTokens.DangerDark;
end;

class function TDACComponentColors.DangerLight: TAlphaColor;
begin
  Result := CurrentTokens.DangerLight;
end;

class function TDACComponentColors.DarkPanelBackground: TAlphaColor;
begin
  Result := CurrentTokens.Panel;
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
  Result := CurrentTokens.InteractionHover;
end;

class function TDACComponentColors.GridHeader: TAlphaColor;
begin
  Result := CurrentTokens.GridHeader;
end;

class function TDACComponentColors.Info: TAlphaColor;
begin
  Result := CurrentTokens.Info;
end;

class function TDACComponentColors.InfoBorder: TAlphaColor;
begin
  Result := CurrentTokens.InfoBorder;
end;

class function TDACComponentColors.InfoDark: TAlphaColor;
begin
  Result := CurrentTokens.InfoDark;
end;

class function TDACComponentColors.InfoLight: TAlphaColor;
begin
  Result := CurrentTokens.InfoLight;
end;

class function TDACComponentColors.InfoSoftBackground: TAlphaColor;
begin
  Result := CurrentTokens.InfoSoftBackground;
end;

class function TDACComponentColors.InfoText: TAlphaColor;
begin
  Result := CurrentTokens.InfoText;
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

class function TDACComponentColors.Neutral: TAlphaColor;
begin
  Result := CurrentTokens.Neutral;
end;

class function TDACComponentColors.NeutralDark: TAlphaColor;
begin
  Result := CurrentTokens.NeutralDark;
end;

class function TDACComponentColors.NeutralLight: TAlphaColor;
begin
  Result := CurrentTokens.NeutralLight;
end;

class function TDACComponentColors.NeutralSoftBackground: TAlphaColor;
begin
  Result := CurrentTokens.NeutralSoftBackground;
end;

class function TDACComponentColors.Panel: TAlphaColor;
begin
  Result := CurrentTokens.Panel;
end;

class function TDACComponentColors.Primary: TAlphaColor;
begin
  Result := CurrentTokens.Primary;
end;

class function TDACComponentColors.PrimaryDark: TAlphaColor;
begin
  Result := CurrentTokens.PrimaryDark;
end;

class function TDACComponentColors.PrimaryFocus: TAlphaColor;
begin
  Result := CurrentTokens.PrimaryFocus;
end;

class function TDACComponentColors.PrimaryLight: TAlphaColor;
begin
  Result := CurrentTokens.PrimaryLight;
end;

class function TDACComponentColors.ResolveParentSurface(
  const AControl: TControl): TAlphaColor;
var
  LControl: TControl;
  LColor: TColor;
begin
  Result := CurrentTokens.White;
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
  Result := CurrentTokens.SuiteSectionSubtitle;
end;

class function TDACComponentColors.SuiteSectionTitle: TAlphaColor;
begin
  Result := CurrentTokens.SuiteSectionTitle;
end;

class function TDACComponentColors.SurfaceDark: TAlphaColor;
begin
  Result := CurrentTokens.SurfaceDark;
end;

class function TDACComponentColors.Text: TAlphaColor;
begin
  Result := CurrentTokens.Text;
end;

class function TDACComponentColors.TextSecondary: TAlphaColor;
begin
  Result := CurrentTokens.TextSecondary;
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
  Result := CurrentTokens.Warning;
end;

class function TDACComponentColors.WarningDark: TAlphaColor;
begin
  Result := CurrentTokens.WarningDark;
end;

class function TDACComponentColors.WarningLight: TAlphaColor;
begin
  Result := CurrentTokens.WarningLight;
end;

class function TDACComponentColors.White: TAlphaColor;
begin
  Result := CurrentTokens.White;
end;

end.

