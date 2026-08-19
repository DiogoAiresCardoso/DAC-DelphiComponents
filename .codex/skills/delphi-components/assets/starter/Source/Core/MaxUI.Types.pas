unit MaxUI.Types;

{$CODEPAGE 65001}

interface

uses
  Vcl.Graphics;

type
  TMaxVisualState = (
    mvsNormal,
    mvsHot,
    mvsPressed,
    mvsFocused,
    mvsDisabled,
    mvsSelected,
    mvsChecked,
    mvsError
  );

  TMaxControlSize = (mcsSmall, mcsMedium, mcsLarge);

  TMaxButtonKind = (
    mbkPrimary,
    mbkSecondary,
    mbkSuccess,
    mbkWarning,
    mbkDanger,
    mbkGhost
  );

  TMaxFieldState = (mfsNormal, mfsFocused, mfsError, mfsDisabled);
  TMaxIconPosition = (mipLeft, mipRight, mipTop, mipOnly);

  TMaxIconKind = (
    mikNone,
    mikPlus,
    mikEdit,
    mikCheck,
    mikWarning,
    mikDelete,
    mikSearch,
    mikEye,
    mikEyeOff,
    mikCalendar,
    mikClock,
    mikChevronDown,
    mikChevronLeft,
    mikChevronRight,
    mikInfo,
    mikClose,
    mikCurrency,
    mikCart,
    mikUsers,
    mikBox,
    mikDocument,
    mikLock,
    mikLeaf
  );

  TMaxDeltaKind = (mdkNeutral, mdkPositive, mdkNegative);
  TMaxPillKind = (mpkNeutral, mpkPrimary, mpkSuccess, mpkWarning, mpkDanger, mpkInfo);
  TMaxToastKind = (mtkSuccess, mtkWarning, mtkDanger, mtkInfo);
  TMaxSpinnerStyle = (mssRing, mssDots, mssSkeleton);
  TMaxChartKind = (mckBar, mckLine, mckArea, mckDonut);

  TMaxPalette = record
    Background: TColor;
    Surface: TColor;
    SurfaceSoft: TColor;
    Border: TColor;
    BorderStrong: TColor;
    Text: TColor;
    TextSecondary: TColor;
    TextDisabled: TColor;
    DisabledSurface: TColor;
    Primary: TColor;
    PrimaryHover: TColor;
    PrimaryLight: TColor;
    PrimarySoft: TColor;
    PrimaryDark: TColor;
    PrimaryDeep: TColor;
    Success: TColor;
    Warning: TColor;
    WarningDark: TColor;
    Danger: TColor;
    Info: TColor;
    AccentPurple: TColor;
    class function Light: TMaxPalette; static;
  end;

  TMaxMetrics = record
    Space4: Integer;
    Space8: Integer;
    Space12: Integer;
    Space16: Integer;
    Space24: Integer;
    Space32: Integer;
    RadiusSmall: Integer;
    RadiusMedium: Integer;
    RadiusCard: Integer;
    RadiusLarge: Integer;
    ControlHeightSmall: Integer;
    ControlHeightMedium: Integer;
    ControlHeightLarge: Integer;
    BorderWidth: Integer;
    FocusWidth: Integer;
    IconSmall: Integer;
    IconMedium: Integer;
    HeaderHeight: Integer;
    class function Defaults: TMaxMetrics; static;
  end;

implementation

uses
  Winapi.Windows;

class function TMaxPalette.Light: TMaxPalette;
begin
  Result.Background := TColor(RGB($FF, $FF, $FF));
  Result.Surface := TColor(RGB($FF, $FF, $FF));
  Result.SurfaceSoft := TColor(RGB($F7, $FA, $F6));
  Result.Border := TColor(RGB($E1, $E8, $DF));
  Result.BorderStrong := TColor(RGB($B8, $C4, $B8));
  Result.Text := TColor(RGB($10, $24, $17));
  Result.TextSecondary := TColor(RGB($65, $70, $67));
  Result.TextDisabled := TColor(RGB($A6, $AE, $A8));
  Result.DisabledSurface := TColor(RGB($F1, $F3, $F1));
  Result.Primary := TColor(RGB($2F, $9E, $22));
  Result.PrimaryHover := TColor(RGB($3D, $B8, $2A));
  Result.PrimaryLight := TColor(RGB($74, $D6, $4A));
  Result.PrimarySoft := TColor(RGB($EA, $F7, $E7));
  Result.PrimaryDark := TColor(RGB($10, $24, $17));
  Result.PrimaryDeep := TColor(RGB($07, $13, $0C));
  Result.Success := Result.Primary;
  Result.Warning := TColor(RGB($F5, $C8, $42));
  Result.WarningDark := TColor(RGB($9A, $68, $00));
  Result.Danger := TColor(RGB($D9, $4A, $3A));
  Result.Info := TColor(RGB($2F, $80, $ED));
  Result.AccentPurple := TColor(RGB($8B, $5C, $F6));
end;

class function TMaxMetrics.Defaults: TMaxMetrics;
begin
  Result.Space4 := 4;
  Result.Space8 := 8;
  Result.Space12 := 12;
  Result.Space16 := 16;
  Result.Space24 := 24;
  Result.Space32 := 32;
  Result.RadiusSmall := 4;
  Result.RadiusMedium := 8;
  Result.RadiusCard := 10;
  Result.RadiusLarge := 16;
  Result.ControlHeightSmall := 28;
  Result.ControlHeightMedium := 36;
  Result.ControlHeightLarge := 44;
  Result.BorderWidth := 1;
  Result.FocusWidth := 2;
  Result.IconSmall := 14;
  Result.IconMedium := 18;
  Result.HeaderHeight := 72;
end;

end.
