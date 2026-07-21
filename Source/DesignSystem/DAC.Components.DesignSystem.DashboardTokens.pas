unit DAC.Components.DesignSystem.DashboardTokens;

interface

uses
  System.UITypes;

type
  // Tokens reconstructed from the agricultural dashboard reference.  Keeping
  // them in the design-system layer makes the demo an executable composition
  // of the same visual language rather than a set of one-off literals.
  TDACDashboardTokens = record
  public
    class function AppBackground: TAlphaColor; static;
    class function GlassSurface: TAlphaColor; static;
    class function CardSurface: TAlphaColor; static;
    class function Border: TAlphaColor; static;
    class function Brand: TAlphaColor; static;
    class function BrandLight: TAlphaColor; static;
    class function BrandDark: TAlphaColor; static;
    class function TextPrimary: TAlphaColor; static;
    class function TextSecondary: TAlphaColor; static;
    class function TextMuted: TAlphaColor; static;
    class function Warning: TAlphaColor; static;
    class function Danger: TAlphaColor; static;
    class function Success: TAlphaColor; static;
    class function BrandBorder: TAlphaColor; static;
    class function CardRadius: Integer; static;
    class function CardPadding: Integer; static;
    class function CardGap: Integer; static;
  end;

implementation

uses
  DAC.Components.DesignSystem.ColorTokens;

class function TDACDashboardTokens.AppBackground: TAlphaColor;
begin
  Result := TDACComponentColors.Alpha($08, $13, $0D);
end;

class function TDACDashboardTokens.Brand: TAlphaColor;
begin
  Result := TDACComponentColors.Alpha($43, $B7, $2B);
end;

class function TDACDashboardTokens.BrandBorder: TAlphaColor;
begin
  Result := TDACComponentColors.Alpha($43, $B7, $2B, 140);
end;

class function TDACDashboardTokens.BrandDark: TAlphaColor;
begin
  Result := TDACComponentColors.Alpha($24, $7C, $1D);
end;

class function TDACDashboardTokens.BrandLight: TAlphaColor;
begin
  Result := TDACComponentColors.Alpha($62, $CC, $3A);
end;

class function TDACDashboardTokens.Border: TAlphaColor;
begin
  Result := TDACComponentColors.Alpha($FF, $FF, $FF, 28);
end;

class function TDACDashboardTokens.CardGap: Integer;
begin
  Result := 16;
end;

class function TDACDashboardTokens.CardPadding: Integer;
begin
  Result := 20;
end;

class function TDACDashboardTokens.CardRadius: Integer;
begin
  Result := 14;
end;

class function TDACDashboardTokens.CardSurface: TAlphaColor;
begin
  Result := TDACComponentColors.Alpha($0E, $1F, $15, 230);
end;

class function TDACDashboardTokens.Danger: TAlphaColor;
begin
  Result := TDACComponentColors.Alpha($E5, $48, $4D);
end;

class function TDACDashboardTokens.GlassSurface: TAlphaColor;
begin
  Result := TDACComponentColors.Alpha($0C, $1D, $13, 224);
end;

class function TDACDashboardTokens.Success: TAlphaColor;
begin
  Result := TDACComponentColors.Alpha($45, $C3, $3A);
end;

class function TDACDashboardTokens.TextMuted: TAlphaColor;
begin
  Result := TDACComponentColors.Alpha($87, $92, $8A);
end;

class function TDACDashboardTokens.TextPrimary: TAlphaColor;
begin
  Result := TDACComponentColors.Alpha($F5, $F8, $F5);
end;

class function TDACDashboardTokens.TextSecondary: TAlphaColor;
begin
  Result := TDACComponentColors.Alpha($B8, $C1, $BA);
end;

class function TDACDashboardTokens.Warning: TAlphaColor;
begin
  Result := TDACComponentColors.Alpha($F0, $B3, $00);
end;

end.
