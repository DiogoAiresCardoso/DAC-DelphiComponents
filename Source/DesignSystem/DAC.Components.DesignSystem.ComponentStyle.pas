unit DAC.Components.DesignSystem.ComponentStyle;

interface

uses
  System.UITypes,
  Vcl.Controls,
  Vcl.Graphics,
  DAC.Components.DesignSystem.ChartPalette,
  DAC.Components.DesignSystem.ControlTokens,
  DAC.Components.DesignSystem.Metrics,
  DAC.Components.DesignSystem.SemanticColors,
  DAC.Components.DesignSystem.Theme,
  DAC.Components.DesignSystem.Tokens,
  DAC.Components.DesignSystem.TypographyTokens;

type
  // Read-only facade used by public controls for their visual defaults.
  // Values are logical and fixed here, so each control keeps ownership of its
  // geometry contract.
  TDACComponentStyle = class sealed
  private
    class var FDarkTheme: IDACComponentsTheme;
    class var FLightTheme: IDACComponentsTheme;
    class function CurrentTheme: IDACComponentsTheme; static;
  public
    class function Resolve(const AMode: TDACThemeMode): IDACComponentsTheme; static;
    class function ResolveForSurface(const AControl: TControl;
      const AMode: TDACThemeMode): IDACComponentsTheme; static;
    class function TryResolveSurface(const AControl: TControl;
      out AMode: TDACThemeMode; out AColor: TColor): Boolean; static;
    class function Tokens: TDACDesignTokens; static;
    class function Metrics: TDACComponentMetrics; static;
    class function Typography: TDACTypographyTokens; static;
    class function ChartPalette: TDACChartPalette; static;
    class function Semantic(const AStatus: TDACSemanticStatus): TDACSemanticColorSet; static;
    class function GridHeaderColor: TAlphaColor; static;
    class function ButtonDisabledBackground: TAlphaColor; static;
    class function ButtonDisabledBorder: TAlphaColor; static;
    class function ButtonDisabledText: TAlphaColor; static;
    class function ButtonLoadingBackground: TAlphaColor; static;
    class function ButtonLoadingText: TAlphaColor; static;

    class function FontFamily: string; static;
    class function CaptionSize: Integer; static;
    class function TextSize: Integer; static;
    class function SmallTextSize: Integer; static;
    class function TabTextSize: Integer; static;
    class function GridTextSize: Integer; static;
    // Native editors and their labels share semantic input tokens. Each is
    // exactly two points below its former typography base without changing
    // geometry or introducing a second sizing policy in controls.
    class function InputTextSize: Integer; static;
    class function InputSmallTextSize: Integer; static;
    class function InputLargeTextSize: Integer; static;
    class function InputGridTextSize: Integer; static;
    class function InputLargeGridTextSize: Integer; static;
    class function SectionTitleSize: Integer; static;
  end;

  { Applies the default native VCL semantics only inside an explicitly owned
    subtree. DAC controls keep resolving their own ThemeMode through listeners;
    this helper exists for native labels/panels that have no theme contract. }
  TDACNativeThemeScopeApplicator = class sealed
  public
    class procedure Apply(const ARoot: TControl;
      const ATokens: TDACControlTokens); static;
  end;

implementation

uses
  System.Math,
  System.SysUtils,
  System.TypInfo,
  Vcl.ComCtrls,
  Vcl.ExtCtrls,
  Vcl.StdCtrls,
  DAC.Components.DesignSystem.ColorTokens,
  DAC.Components.DesignSystem.DefaultTheme,
  DAC.Components.DesignSystem.Fonts;

type
  TTabSheetSurfaceAccess = class(TTabSheet)
  public
    function SurfaceColor: TColor;
  end;

function TTabSheetSurfaceAccess.SurfaceColor: TColor;
begin
  Result := Color;
end;

function CurrentComponentStyleColors: TDACColorTokens;
begin
  Result := TDACComponentStyle.Tokens.Colors;
end;

class procedure TDACNativeThemeScopeApplicator.Apply(
  const ARoot: TControl; const ATokens: TDACControlTokens);
var
  I: Integer;
begin
  if ARoot = nil then
    Exit;

  if ARoot is TLabel then
  begin
    { A native label has no ThemeMode. Inside the explicit gallery/page scope
      it represents default content text, while semantic/accent text remains a
      TDACSystemText owned by the component layer. }
    TLabel(ARoot).ParentFont := False;
    TLabel(ARoot).Font.Name := TDACComponentStyle.FontFamily;
    TLabel(ARoot).Font.Size := TDACComponentStyle.TextSize;
    TLabel(ARoot).Font.Color := TDACComponentColors.ToVclColor(
      ATokens.ContainerTitle);
    TLabel(ARoot).Transparent := True;
  end
  else if (ARoot is TPanel) and TPanel(ARoot).ParentColor then
    TPanel(ARoot).ParentBackground := True;

  if ARoot is TWinControl then
    for I := 0 to TWinControl(ARoot).ControlCount - 1 do
      Apply(TWinControl(ARoot).Controls[I], ATokens);
end;

function ExplicitThemeModeOf(const AControl: TControl;
  out AMode: TDACThemeMode): Boolean;
var
  LInfo: PPropInfo;
  LValue: Integer;
begin
  Result := False;
  AMode := dtmInherit;
  if AControl = nil then
    Exit;
  LInfo := GetPropInfo(AControl.ClassInfo, 'ThemeMode');
  if (LInfo = nil) or (LInfo.PropType^.Kind <> tkEnumeration) or
     not SameText(string(LInfo.PropType^.Name), 'TDACThemeMode') then
    Exit;
  LValue := GetOrdProp(AControl, LInfo);
  if not (LValue in [Ord(Low(TDACThemeMode))..Ord(High(TDACThemeMode))]) then
    Exit;
  AMode := TDACThemeMode(LValue);
  Result := AMode <> dtmInherit;
end;

function ModeForLuminance(const ALuminance: Integer;
  out AMode: TDACThemeMode): Boolean;
begin
  Result := True;
  if ALuminance <= DACSurfaceDarkLuminanceMax then
    AMode := dtmDark
  else if ALuminance >= DACSurfaceLightLuminanceMin then
    AMode := dtmLight
  else
  begin
    AMode := dtmInherit;
    Result := False;
  end;
end;

function ModeForSurfaceColor(const AColor: TColor;
  out AMode: TDACThemeMode): Boolean;
var
  LColor: TColor;
  LColorValue: Cardinal;
  LLuminance: Integer;
begin
  AMode := dtmInherit;
  if (AColor = clNone) or (AColor = clDefault) then
    Exit(False);
  LColor := ColorToRGB(AColor);
  LColorValue := Cardinal(LColor);
  LLuminance := ((LColorValue and $FF) * 299 +
    ((LColorValue shr 8) and $FF) * 587 +
    ((LColorValue shr 16) and $FF) * 114) div 1000;
  Result := ModeForLuminance(LLuminance, AMode);
end;

function ModeForAlphaSurfaceColor(const AColor: TAlphaColor;
  out AMode: TDACThemeMode): Boolean;
var
  LColorValue: Cardinal;
  LLuminance: Integer;
begin
  AMode := dtmInherit;
  LColorValue := Cardinal(AColor);
  LLuminance := (((LColorValue shr 16) and $FF) * 299 +
    ((LColorValue shr 8) and $FF) * 587 +
    (LColorValue and $FF) * 114) div 1000;
  Result := ModeForLuminance(LLuminance, AMode);
end;

function TryGetIntegerProperty(const AInstance: TObject;
  const AInfo: PPropInfo; out AValue: Int64): Boolean;
begin
  Result := False;
  AValue := 0;
  if (AInstance = nil) or (AInfo = nil) then
    Exit;
  case AInfo.PropType^.Kind of
    tkInteger:
      AValue := GetOrdProp(AInstance, AInfo);
    tkInt64:
      AValue := GetInt64Prop(AInstance, AInfo);
  else
    Exit;
  end;
  Result := True;
end;

function IntegerPropertyFitsColor(const AInfo: PPropInfo;
  const AValue: Int64): Boolean;
begin
  Result := (AInfo <> nil) and ((AInfo.PropType^.Kind <> tkInt64) or
    ((AValue >= Low(Integer)) and (AValue <= High(Cardinal))));
end;

function BooleanPropertyIsTrue(const AControl: TControl;
  const APropertyName: string): Boolean;
var
  LInfo: PPropInfo;
begin
  Result := False;
  if AControl = nil then
    Exit;
  LInfo := GetPropInfo(AControl.ClassInfo, APropertyName);
  if (LInfo <> nil) and (LInfo.PropType^.Kind = tkEnumeration) and
     SameText(string(LInfo.PropType^.Name), 'Boolean') then
    Result := GetOrdProp(AControl, LInfo) <> 0;
end;

function DACSurfaceThemeModeOf(const AControl: TControl;
  out AMode: TDACThemeMode; out AColor: TColor): Boolean;
var
  LInfo: PPropInfo;
  LColor: Cardinal;
  LValue: Int64;
begin
  Result := False;
  AMode := dtmInherit;
  AColor := clNone;
  if (AControl = nil) or not SameText(Copy(AControl.ClassName, 1, 4), 'TDAC') then
    Exit;
  LInfo := GetPropInfo(AControl.ClassInfo, 'BackgroundColor');
  if not TryGetIntegerProperty(AControl, LInfo, LValue) or
     not IntegerPropertyFitsColor(LInfo, LValue) then
    Exit;
  LColor := Cardinal(LValue);
  // A transparent compositing host (such as the Quick Actions grid) exposes
  // no physical surface and must let the next visual ancestor decide.
  if (LColor shr 24) = 0 then
    Exit;
  Result := ModeForAlphaSurfaceColor(TAlphaColor(LColor), AMode);
  if Result then
    AColor := TDACComponentColors.ToVclColor(TAlphaColor(LColor));
end;

function VCLSurfaceThemeModeOf(const AControl: TControl;
  out AMode: TDACThemeMode; out AColor: TColor): Boolean;
var
  LInfo: PPropInfo;
  LColor: TColor;
  LValue: Int64;
begin
  Result := False;
  AMode := dtmInherit;
  AColor := clNone;
  if AControl = nil then
    Exit;
  // Generic VCL hosts are considered only when they really own an opaque
  // surface. Inherited/transparent backgrounds must not shadow a farther
  // container or the global mode.
  if BooleanPropertyIsTrue(AControl, 'Transparent') then
    Exit;
  if (AControl.Parent <> nil) and
     (BooleanPropertyIsTrue(AControl, 'ParentColor') or
      BooleanPropertyIsTrue(AControl, 'ParentBackground')) then
    Exit;
  LInfo := GetPropInfo(AControl.ClassInfo, 'Color');
  if not TryGetIntegerProperty(AControl, LInfo, LValue) or
     not IntegerPropertyFitsColor(LInfo, LValue) then
    Exit;
  LColor := TColor(LValue);
  Result := ModeForSurfaceColor(LColor, AMode);
  if Result then
    AColor := LColor;
end;

class function TDACComponentStyle.CaptionSize: Integer;
begin
  Result := Round(Typography.CaptionSize);
end;

class function TDACComponentStyle.ButtonDisabledBackground: TAlphaColor;
begin
  Result := Tokens.Colors.ControlBackgroundDisabled;
end;

class function TDACComponentStyle.ButtonDisabledBorder: TAlphaColor;
begin
  Result := Tokens.Colors.ControlBorder;
end;

class function TDACComponentStyle.ButtonDisabledText: TAlphaColor;
begin
  // Buttons retain an AA label on their disabled agricultural surface; field
  // editors keep the separate #6F7C74 disabled-input token.
  Result := Tokens.Controls.InputPlaceholder;
end;

class function TDACComponentStyle.ButtonLoadingBackground: TAlphaColor;
begin
  Result := Tokens.Colors.ButtonLoadingBackground;
end;

class function TDACComponentStyle.ButtonLoadingText: TAlphaColor;
begin
  Result := Tokens.Colors.ButtonLoadingText;
end;

class function TDACComponentStyle.ChartPalette: TDACChartPalette;
begin
  Result := CurrentTheme.ChartPalette;
end;

class function TDACComponentStyle.CurrentTheme: IDACComponentsTheme;
begin
  Result := Resolve(dtmInherit);
end;

class function TDACComponentStyle.Resolve(
  const AMode: TDACThemeMode): IDACComponentsTheme;
begin
  case TDACThemeManager.ResolveMode(AMode) of
    dtmLight:
      begin
        if FLightTheme = nil then
          FLightTheme := TDACDefaultComponentsTheme.NewForMode(dtmLight);
        Result := FLightTheme;
      end;
  else
    begin
      if FDarkTheme = nil then
        FDarkTheme := TDACDefaultComponentsTheme.NewForMode(dtmDark);
      Result := FDarkTheme;
    end;
  end;
end;

class function TDACComponentStyle.ResolveForSurface(const AControl: TControl;
  const AMode: TDACThemeMode): IDACComponentsTheme;
var
  LAncestor: TControl;
  LColor: TColor;
  LMode: TDACThemeMode;
begin
  // Resolution is intentionally local and read-only. Explicit modes form one
  // precedence layer and physical surfaces form the next, so a farther
  // explicit owner is never accidentally shadowed by an inferred color.
  if AMode <> dtmInherit then
    Exit(Resolve(AMode));

  LAncestor := AControl.Parent;
  while LAncestor <> nil do
  begin
    if ExplicitThemeModeOf(LAncestor, LMode) then
      Exit(Resolve(LMode));
    LAncestor := LAncestor.Parent;
  end;

  LAncestor := AControl.Parent;
  while LAncestor <> nil do
  begin
    if TryResolveSurface(LAncestor, LMode, LColor) then
      Exit(Resolve(LMode));
    LAncestor := LAncestor.Parent;
  end;
  Result := Resolve(dtmInherit);
end;

class function TDACComponentStyle.TryResolveSurface(const AControl: TControl;
  out AMode: TDACThemeMode; out AColor: TColor): Boolean;
begin
  AMode := dtmInherit;
  AColor := clNone;
  if AControl = nil then
    Exit(False);
  if DACSurfaceThemeModeOf(AControl, AMode, AColor) then
    Exit(True);
  if AControl is TTabSheet then
  begin
    AColor := TTabSheetSurfaceAccess(AControl).SurfaceColor;
    Exit(ModeForSurfaceColor(AColor, AMode));
  end;
  Result := VCLSurfaceThemeModeOf(AControl, AMode, AColor);
end;

class function TDACComponentStyle.FontFamily: string;
begin
  // Theme owns the selected family; the installer keeps the family available
  // to VCL native editors and Skia text alike.
  TDACComponentFontInstaller.InstallInter;
  Result := Typography.FontFamily;
end;

class function TDACComponentStyle.GridTextSize: Integer;
begin
  Result := Round(Typography.GridTextSize);
end;

class function TDACComponentStyle.InputGridTextSize: Integer;
begin
  Result := Max(1, GridTextSize - 2);
end;

class function TDACComponentStyle.InputLargeGridTextSize: Integer;
begin
  Result := Max(1, GridTextSize);
end;

class function TDACComponentStyle.InputLargeTextSize: Integer;
begin
  Result := Max(1, TextSize);
end;

class function TDACComponentStyle.InputSmallTextSize: Integer;
begin
  Result := Max(1, SmallTextSize - 2);
end;

class function TDACComponentStyle.InputTextSize: Integer;
begin
  Result := Max(1, TextSize - 2);
end;

class function TDACComponentStyle.GridHeaderColor: TAlphaColor;
begin
  Result := Tokens.Colors.GridHeader;
end;

class function TDACComponentStyle.Metrics: TDACComponentMetrics;
begin
  Result := CurrentTheme.Metrics;
end;

class function TDACComponentStyle.SectionTitleSize: Integer;
begin
  Result := Round(Typography.Title3Size);
end;

class function TDACComponentStyle.Semantic(
  const AStatus: TDACSemanticStatus): TDACSemanticColorSet;
begin
  Result := TDACSemanticColors.ColorsFor(AStatus);
end;

class function TDACComponentStyle.SmallTextSize: Integer;
begin
  Result := Round(Typography.SmallTextSize);
end;

class function TDACComponentStyle.TabTextSize: Integer;
begin
  Result := Round(Typography.TabTextSize);
end;

class function TDACComponentStyle.TextSize: Integer;
begin
  Result := Round(Typography.TextSize);
end;

class function TDACComponentStyle.Tokens: TDACDesignTokens;
begin
  Result := CurrentTheme.Tokens;
end;

class function TDACComponentStyle.Typography: TDACTypographyTokens;
begin
  Result := Tokens.Typography;
end;

initialization
  TDACComponentColors.SetTokensProvider(CurrentComponentStyleColors);

end.
