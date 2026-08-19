unit DAC.Components.DesignSystem.DashboardTokens;

interface

uses
  System.UITypes;

type
  { Dashboard-specific tokens derived from assets/dashboarrd.png and the
    agricultural design-system specification.  Generic spacing, typography,
    radius and control dimensions remain in their respective token groups. }
  TDACDashboardTokens = record
    AppBackground: TAlphaColor;
    GlassSurface: TAlphaColor;
    CardSurface: TAlphaColor;
    CardBorder: TAlphaColor;
    ContentMinimumWidth: Single;
    KpiMinimumWidth: Single;
    KpiHeight: Single;
    DateSummaryMinimumWidth: Single;
    DateSummaryMaximumWidth: Single;
    DateSummaryHeight: Single;
    DateAndGreetingBreakpoint: Single;
    GreetingMinimumHeight: Single;
    GreetingTitleWidth: Single;
    GreetingNameLeftOffset: Single;
    GreetingDateReservedWidth: Single;
    GreetingSubtitleMinimumWidth: Single;
    GreetingSubtitleMinimumHeight: Single;
    GreetingTextGap: Single;
    GreetingContentBottomGap: Single;
    GreetingMinimumContentTop: Single;
    QuickActionsSingleColumnBreakpoint: Single;
    QuickActionsSingleColumnHeight: Single;
    ThreeColumnBreakpoint: Single;
    TwoColumnBreakpoint: Single;
    FiveKpiBreakpoint: Single;
    ThreeKpiBreakpoint: Single;
    TwoKpiBreakpoint: Single;
    AnalyticsTwoColumnBreakpoint: Single;
    AnalyticsPanelHeight: Single;
    ModuleFourColumnBreakpoint: Single;
    ModuleTwoColumnBreakpoint: Single;
    ModuleMinimumWidth: Single;
    ModuleContentTop: Single;
    ModuleRowStride: Single;
    ModuleHeight: Single;
    ChartTop: Single;
    ChartMinimumWidth: Single;
    ChartMinimumHeight: Single;
    ProductivitySelectRightInset: Single;
    ProductivitySelectWidth: Single;
    StatusHeight: Single;
    StatusTextTop: Single;
    StatusTextHeight: Single;
    StatusConnectionWidth: Single;
    StatusFarmMinimumLeft: Single;
    StatusFarmCenterOffset: Single;
    StatusFarmWidth: Single;
    StatusSeasonMinimumLeft: Single;
    StatusSeasonRightInset: Single;
    StatusSeasonWidth: Single;
    class function Dark: TDACDashboardTokens; static;
    class function Light: TDACDashboardTokens; static;
  end;

implementation

const
  { Values are stored as AARRGGBB because TAlphaColor is not premultiplied. }
  C_DARK_APP_BACKGROUND = $FF08130D;
  C_DARK_GLASS_SURFACE = $E00C1D13;
  C_DARK_CARD_SURFACE = $E60E1F15;
  C_DARK_CARD_BORDER = $1FFFFFFF;
  C_LIGHT_APP_BACKGROUND = $FFF4F6F5;
  C_LIGHT_GLASS_SURFACE = $F2FFFFFF;
  C_LIGHT_CARD_SURFACE = $F5FFFFFF;
  C_LIGHT_CARD_BORDER = $1F0E1F15;

procedure ConfigureMetrics(var ATokens: TDACDashboardTokens);
begin
  ATokens.ContentMinimumWidth := 240;
  ATokens.KpiMinimumWidth := 200;
  ATokens.KpiHeight := 108;
  ATokens.DateSummaryMinimumWidth := 180;
  ATokens.DateSummaryMaximumWidth := 210;
  ATokens.DateSummaryHeight := 72;
  ATokens.DateAndGreetingBreakpoint := 620;
  ATokens.GreetingMinimumHeight := 32;
  ATokens.GreetingTitleWidth := 220;
  ATokens.GreetingNameLeftOffset := 228;
  ATokens.GreetingDateReservedWidth := 236;
  ATokens.GreetingSubtitleMinimumWidth := 180;
  ATokens.GreetingSubtitleMinimumHeight := 24;
  ATokens.GreetingTextGap := 2;
  ATokens.GreetingContentBottomGap := 14;
  ATokens.GreetingMinimumContentTop := 96;
  ATokens.QuickActionsSingleColumnBreakpoint := 420;
  ATokens.QuickActionsSingleColumnHeight := 356;
  ATokens.ThreeColumnBreakpoint := 1080;
  ATokens.TwoColumnBreakpoint := 640;
  ATokens.FiveKpiBreakpoint := 1180;
  ATokens.ThreeKpiBreakpoint := 840;
  ATokens.TwoKpiBreakpoint := 520;
  ATokens.AnalyticsTwoColumnBreakpoint := 840;
  ATokens.AnalyticsPanelHeight := 270;
  ATokens.ModuleFourColumnBreakpoint := 760;
  ATokens.ModuleTwoColumnBreakpoint := 420;
  ATokens.ModuleMinimumWidth := 180;
  ATokens.ModuleContentTop := 56;
  ATokens.ModuleRowStride := 178;
  ATokens.ModuleHeight := 172;
  ATokens.ChartTop := 72;
  ATokens.ChartMinimumWidth := 120;
  ATokens.ChartMinimumHeight := 96;
  ATokens.ProductivitySelectRightInset := 170;
  ATokens.ProductivitySelectWidth := 150;
  ATokens.StatusHeight := 64;
  ATokens.StatusTextTop := 18;
  ATokens.StatusTextHeight := 20;
  ATokens.StatusConnectionWidth := 130;
  ATokens.StatusFarmMinimumLeft := 160;
  ATokens.StatusFarmCenterOffset := 90;
  ATokens.StatusFarmWidth := 180;
  ATokens.StatusSeasonMinimumLeft := 300;
  ATokens.StatusSeasonRightInset := 170;
  ATokens.StatusSeasonWidth := 150;
end;

class function TDACDashboardTokens.Dark: TDACDashboardTokens;
begin
  ConfigureMetrics(Result);
  Result.AppBackground := C_DARK_APP_BACKGROUND;
  Result.GlassSurface := C_DARK_GLASS_SURFACE;
  Result.CardSurface := C_DARK_CARD_SURFACE;
  Result.CardBorder := C_DARK_CARD_BORDER;
end;

class function TDACDashboardTokens.Light: TDACDashboardTokens;
begin
  ConfigureMetrics(Result);
  Result.AppBackground := C_LIGHT_APP_BACKGROUND;
  Result.GlassSurface := C_LIGHT_GLASS_SURFACE;
  Result.CardSurface := C_LIGHT_CARD_SURFACE;
  Result.CardBorder := C_LIGHT_CARD_BORDER;
end;

end.
