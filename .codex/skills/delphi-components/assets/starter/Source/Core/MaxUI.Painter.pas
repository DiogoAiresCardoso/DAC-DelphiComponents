unit MaxUI.Painter;

{$CODEPAGE 65001}

interface

uses
  System.Types,
  Vcl.Graphics,
  MaxUI.Types;

type
  TMaxPainter = class sealed
  strict private
    class procedure ResolveButtonColors(const AKind: TMaxButtonKind;
      const AState: TMaxVisualState; out AFill, ABorder, AText: TColor); static;
  public
    class function BlendColor(const AFrom, ATo: TColor; const AAmount: Byte): TColor; static;
    class function PillColors(const AKind: TMaxPillKind; out AFill, ABorder,
      AText: TColor): Boolean; static;
    class procedure DrawSurface(ACanvas: TCanvas; const ARect: TRect;
      const AFill, ABorder: TColor; const ARadius, ABorderWidth: Integer); static;
    class procedure DrawFocusRing(ACanvas: TCanvas; const ARect: TRect;
      const AColor: TColor; const ARadius, AWidth: Integer); static;
    class procedure DrawButton(ACanvas: TCanvas; const ARect: TRect;
      const ACaption: string; AFont: TFont; const AKind: TMaxButtonKind;
      const AState: TMaxVisualState; const ARadius, APPI: Integer;
      const AIcon: TMaxIconKind = mikNone; const AIconPosition: TMaxIconPosition = mipLeft;
      const ASplitWidth: Integer = 0); static;
    class procedure DrawFieldFrame(ACanvas: TCanvas; const ARect: TRect;
      const AState: TMaxFieldState; const ARadius, APPI: Integer); static;
    class procedure DrawCheckGlyph(ACanvas: TCanvas; const ARect: TRect;
      const AChecked, ARadio, AEnabled, AHot, AFocused: Boolean;
      const APPI: Integer); static;
    class procedure DrawToggle(ACanvas: TCanvas; const ARect: TRect;
      const AChecked, AEnabled, AFocused: Boolean; const APPI: Integer); static;
    class procedure DrawSlider(ACanvas: TCanvas; const ARect: TRect;
      const APosition, AMinimum, AMaximum: Integer; const AEnabled,
      AFocused: Boolean; const APPI: Integer); static;
    class procedure DrawLinearProgress(ACanvas: TCanvas; const ARect: TRect;
      const APosition, AMinimum, AMaximum, ARadius: Integer); static;
    class procedure DrawPill(ACanvas: TCanvas; const ARect: TRect;
      const AText: string; AFont: TFont; const AKind: TMaxPillKind;
      const ASelected, ACloseButton: Boolean; const APPI: Integer); static;
  end;

implementation

uses
  System.Math,
  Winapi.Windows,
  MaxUI.Dpi,
  MaxUI.Theme,
  MaxUI.Icons;

class function TMaxPainter.BlendColor(const AFrom, ATo: TColor;
  const AAmount: Byte): TColor;
var
  F: COLORREF;
  T: COLORREF;
  R: Integer;
  G: Integer;
  B: Integer;
begin
  F := ColorToRGB(AFrom);
  T := ColorToRGB(ATo);
  R := GetRValue(F) + MulDiv(GetRValue(T) - GetRValue(F), AAmount, 255);
  G := GetGValue(F) + MulDiv(GetGValue(T) - GetGValue(F), AAmount, 255);
  B := GetBValue(F) + MulDiv(GetBValue(T) - GetBValue(F), AAmount, 255);
  Result := TColor(RGB(R, G, B));
end;

class procedure TMaxPainter.ResolveButtonColors(const AKind: TMaxButtonKind;
  const AState: TMaxVisualState; out AFill, ABorder, AText: TColor);
var
  P: TMaxPalette;
begin
  P := TMaxTheme.Palette;
  case AKind of
    mbkSecondary:
      begin
        AFill := P.Surface;
        ABorder := P.Primary;
        AText := P.Primary;
      end;
    mbkSuccess:
      begin
        AFill := P.Success;
        ABorder := P.Success;
        AText := clWhite;
      end;
    mbkWarning:
      begin
        AFill := P.Warning;
        ABorder := P.Warning;
        AText := P.WarningDark;
      end;
    mbkDanger:
      begin
        AFill := P.Danger;
        ABorder := P.Danger;
        AText := clWhite;
      end;
    mbkGhost:
      begin
        AFill := P.Surface;
        ABorder := P.Border;
        AText := P.PrimaryDark;
      end;
  else
    begin
      AFill := P.Primary;
      ABorder := P.Primary;
      AText := clWhite;
    end;
  end;

  case AState of
    mvsHot:
      begin
        if AKind in [mbkPrimary, mbkSuccess] then
          AFill := P.PrimaryHover
        else
          AFill := BlendColor(AFill, P.PrimarySoft, 96);
      end;
    mvsPressed:
      begin
        AFill := BlendColor(AFill, P.PrimaryDeep, 80);
        ABorder := BlendColor(ABorder, P.PrimaryDeep, 80);
      end;
    mvsDisabled:
      begin
        AFill := P.DisabledSurface;
        ABorder := P.Border;
        AText := P.TextDisabled;
      end;
  end;
end;

class function TMaxPainter.PillColors(const AKind: TMaxPillKind;
  out AFill, ABorder, AText: TColor): Boolean;
var
  P: TMaxPalette;
begin
  P := TMaxTheme.Palette;
  Result := True;
  case AKind of
    mpkPrimary:
      begin AFill := P.PrimarySoft; ABorder := P.Primary; AText := P.PrimaryDark; end;
    mpkSuccess:
      begin AFill := P.PrimarySoft; ABorder := P.Success; AText := P.PrimaryDark; end;
    mpkWarning:
      begin AFill := BlendColor(P.Warning, clWhite, 170); ABorder := P.Warning; AText := P.WarningDark; end;
    mpkDanger:
      begin AFill := BlendColor(P.Danger, clWhite, 205); ABorder := P.Danger; AText := P.Danger; end;
    mpkInfo:
      begin AFill := BlendColor(P.Info, clWhite, 210); ABorder := P.Info; AText := P.Info; end;
  else
    begin AFill := P.SurfaceSoft; ABorder := P.Border; AText := P.Text; end;
  end;
end;

class procedure TMaxPainter.DrawSurface(ACanvas: TCanvas; const ARect: TRect;
  const AFill, ABorder: TColor; const ARadius, ABorderWidth: Integer);
var
  R: TRect;
begin
  if (ACanvas = nil) or IsRectEmpty(ARect) then
    Exit;
  R := ARect;
  ACanvas.Brush.Style := bsSolid;
  ACanvas.Brush.Color := AFill;
  ACanvas.Pen.Style := psSolid;
  ACanvas.Pen.Color := ABorder;
  ACanvas.Pen.Width := Max(1, ABorderWidth);
  ACanvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom,
    Max(1, ARadius * 2), Max(1, ARadius * 2));
end;

class procedure TMaxPainter.DrawFocusRing(ACanvas: TCanvas;
  const ARect: TRect; const AColor: TColor; const ARadius, AWidth: Integer);
var
  R: TRect;
begin
  R := ARect;
  InflateRect(R, -1, -1);
  ACanvas.Brush.Style := bsClear;
  ACanvas.Pen.Style := psSolid;
  ACanvas.Pen.Color := AColor;
  ACanvas.Pen.Width := Max(1, AWidth);
  ACanvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom,
    Max(1, ARadius * 2), Max(1, ARadius * 2));
  ACanvas.Brush.Style := bsSolid;
end;

class procedure TMaxPainter.DrawButton(ACanvas: TCanvas; const ARect: TRect;
  const ACaption: string; AFont: TFont; const AKind: TMaxButtonKind;
  const AState: TMaxVisualState; const ARadius, APPI: Integer;
  const AIcon: TMaxIconKind; const AIconPosition: TMaxIconPosition;
  const ASplitWidth: Integer);
var
  FillColor: TColor;
  BorderColor: TColor;
  TextColor: TColor;
  R: TRect;
  TextRect: TRect;
  IconRect: TRect;
  Radius: Integer;
  IconSize: Integer;
  Gap: Integer;
  TextWidth: Integer;
  ContentWidth: Integer;
  ContentLeft: Integer;
  SplitX: Integer;
  Save: Integer;
begin
  ResolveButtonColors(AKind, AState, FillColor, BorderColor, TextColor);
  R := ARect;
  InflateRect(R, -1, -1);
  Radius := MaxScale(ARadius, APPI);
  DrawSurface(ACanvas, R, FillColor, BorderColor, Radius,
    MaxScale(TMaxTheme.Metrics.BorderWidth, APPI));
  if AState = mvsFocused then
    DrawFocusRing(ACanvas, R, TMaxTheme.Palette.Primary, Radius,
      MaxScale(TMaxTheme.Metrics.FocusWidth, APPI));

  TextRect := R;
  if ASplitWidth > 0 then
  begin
    SplitX := R.Right - MaxScale(ASplitWidth, APPI);
    ACanvas.Pen.Color := BlendColor(BorderColor, TextColor, 80);
    ACanvas.Pen.Width := 1;
    ACanvas.MoveTo(SplitX, R.Top + 4);
    ACanvas.LineTo(SplitX, R.Bottom - 4);
    IconRect := Rect(SplitX, R.Top, R.Right, R.Bottom);
    InflateRect(IconRect, -MaxScale(8, APPI), -MaxScale(8, APPI));
    TMaxIconPainter.Draw(ACanvas, IconRect, mikChevronDown, TextColor,
      Max(1, MaxScale(1, APPI)));
    TextRect.Right := SplitX;
  end;

  Save := SaveDC(ACanvas.Handle);
  try
    ACanvas.Font.Assign(AFont);
    ACanvas.Font.Color := TextColor;
    SetBkMode(ACanvas.Handle, TRANSPARENT);

    if AIcon = mikNone then
      DrawText(ACanvas.Handle, PChar(ACaption), Length(ACaption), TextRect,
        DT_CENTER or DT_VCENTER or DT_SINGLELINE or DT_END_ELLIPSIS)
    else
    begin
      IconSize := MaxScale(TMaxTheme.Metrics.IconSmall, APPI);
      Gap := MaxScale(8, APPI);
      TextWidth := ACanvas.TextWidth(ACaption);
      if (AIconPosition = mipOnly) or (ACaption = '') then
      begin
        IconRect := TextRect;
        IconRect.Left := (TextRect.Left + TextRect.Right - IconSize) div 2;
        IconRect.Top := (TextRect.Top + TextRect.Bottom - IconSize) div 2;
        IconRect.Right := IconRect.Left + IconSize;
        IconRect.Bottom := IconRect.Top + IconSize;
      end
      else
      begin
        ContentWidth := IconSize + Gap + TextWidth;
        ContentLeft := (TextRect.Left + TextRect.Right - ContentWidth) div 2;
        if AIconPosition = mipRight then
        begin
          TextRect.Left := ContentLeft;
          TextRect.Right := ContentLeft + TextWidth;
          IconRect := Rect(TextRect.Right + Gap,
            (R.Top + R.Bottom - IconSize) div 2,
            TextRect.Right + Gap + IconSize,
            (R.Top + R.Bottom - IconSize) div 2 + IconSize);
        end
        else
        begin
          IconRect := Rect(ContentLeft,
            (R.Top + R.Bottom - IconSize) div 2,
            ContentLeft + IconSize,
            (R.Top + R.Bottom - IconSize) div 2 + IconSize);
          TextRect.Left := IconRect.Right + Gap;
          TextRect.Right := TextRect.Left + TextWidth;
        end;
      end;
      TMaxIconPainter.Draw(ACanvas, IconRect, AIcon, TextColor,
        Max(1, MaxScale(1, APPI)));
      if ACaption <> '' then
        DrawText(ACanvas.Handle, PChar(ACaption), Length(ACaption), TextRect,
          DT_CENTER or DT_VCENTER or DT_SINGLELINE or DT_END_ELLIPSIS);
    end;
  finally
    RestoreDC(ACanvas.Handle, Save);
  end;
end;

class procedure TMaxPainter.DrawFieldFrame(ACanvas: TCanvas;
  const ARect: TRect; const AState: TMaxFieldState; const ARadius, APPI: Integer);
var
  P: TMaxPalette;
  FillColor: TColor;
  BorderColor: TColor;
  R: TRect;
begin
  P := TMaxTheme.Palette;
  FillColor := P.Surface;
  BorderColor := P.Border;
  case AState of
    mfsFocused: BorderColor := P.Primary;
    mfsError: BorderColor := P.Danger;
    mfsDisabled:
      begin
        FillColor := P.DisabledSurface;
        BorderColor := P.Border;
      end;
  end;
  R := ARect;
  InflateRect(R, -1, -1);
  DrawSurface(ACanvas, R, FillColor, BorderColor, MaxScale(ARadius, APPI), 1);
  if AState = mfsFocused then
    DrawFocusRing(ACanvas, R, P.Primary, MaxScale(ARadius, APPI),
      MaxScale(TMaxTheme.Metrics.FocusWidth, APPI));
end;

class procedure TMaxPainter.DrawCheckGlyph(ACanvas: TCanvas;
  const ARect: TRect; const AChecked, ARadio, AEnabled, AHot,
  AFocused: Boolean; const APPI: Integer);
var
  P: TMaxPalette;
  R: TRect;
  FillColor: TColor;
  BorderColor: TColor;
  S: Integer;
begin
  P := TMaxTheme.Palette;
  R := ARect;
  S := Min(R.Width, R.Height);
  R.Right := R.Left + S;
  R.Bottom := R.Top + S;
  FillColor := P.Surface;
  BorderColor := P.BorderStrong;
  if AHot then
    BorderColor := P.Primary;
  if AChecked then
  begin
    FillColor := P.Primary;
    BorderColor := P.Primary;
  end;
  if not AEnabled then
  begin
    FillColor := P.DisabledSurface;
    BorderColor := P.Border;
  end;

  ACanvas.Brush.Style := bsSolid;
  ACanvas.Brush.Color := FillColor;
  ACanvas.Pen.Color := BorderColor;
  ACanvas.Pen.Width := Max(1, MaxScale(1, APPI));
  if ARadio then
    ACanvas.Ellipse(R)
  else
    ACanvas.RoundRect(R.Left, R.Top, R.Right, R.Bottom,
      MaxScale(4, APPI), MaxScale(4, APPI));

  if AChecked then
  begin
    InflateRect(R, -MaxScale(3, APPI), -MaxScale(3, APPI));
    if ARadio then
    begin
      ACanvas.Brush.Color := clWhite;
      ACanvas.Pen.Color := clWhite;
      ACanvas.Ellipse(R);
    end
    else
      TMaxIconPainter.Draw(ACanvas, R, mikCheck, clWhite,
        Max(1, MaxScale(2, APPI)));
  end;

  if AFocused then
  begin
    R := ARect;
    InflateRect(R, 2, 2);
    DrawFocusRing(ACanvas, R, P.Primary, MaxScale(4, APPI), 1);
  end;
end;

class procedure TMaxPainter.DrawToggle(ACanvas: TCanvas; const ARect: TRect;
  const AChecked, AEnabled, AFocused: Boolean; const APPI: Integer);
var
  P: TMaxPalette;
  R: TRect;
  Thumb: TRect;
  Radius: Integer;
  D: Integer;
begin
  P := TMaxTheme.Palette;
  R := ARect;
  Radius := R.Height div 2;
  DrawSurface(ACanvas, R,
    IfThen(AChecked and AEnabled, P.Primary, P.BorderStrong),
    IfThen(AChecked and AEnabled, P.Primary, P.BorderStrong), Radius, 1);
  D := R.Height - MaxScale(6, APPI);
  if AChecked then
    Thumb.Left := R.Right - D - MaxScale(3, APPI)
  else
    Thumb.Left := R.Left + MaxScale(3, APPI);
  Thumb.Top := R.Top + MaxScale(3, APPI);
  Thumb.Right := Thumb.Left + D;
  Thumb.Bottom := Thumb.Top + D;
  ACanvas.Brush.Color := IfThen(AEnabled, clWhite, P.DisabledSurface);
  ACanvas.Pen.Color := ACanvas.Brush.Color;
  ACanvas.Ellipse(Thumb);
  if AFocused then
    DrawFocusRing(ACanvas, R, P.Primary, Radius, 1);
end;

class procedure TMaxPainter.DrawSlider(ACanvas: TCanvas; const ARect: TRect;
  const APosition, AMinimum, AMaximum: Integer; const AEnabled,
  AFocused: Boolean; const APPI: Integer);
var
  P: TMaxPalette;
  Track: TRect;
  Fill: TRect;
  Thumb: TRect;
  RangeValue: Integer;
  PosValue: Integer;
  X: Integer;
  ThumbSize: Integer;
begin
  P := TMaxTheme.Palette;
  Track := ARect;
  Track.Top := (ARect.Top + ARect.Bottom) div 2 - MaxScale(2, APPI);
  Track.Bottom := Track.Top + MaxScale(4, APPI);
  RangeValue := Max(1, AMaximum - AMinimum);
  PosValue := EnsureRange(APosition, AMinimum, AMaximum) - AMinimum;
  X := Track.Left + MulDiv(Track.Width, PosValue, RangeValue);
  DrawSurface(ACanvas, Track, P.Border, P.Border, MaxScale(2, APPI), 1);
  Fill := Track;
  Fill.Right := X;
  if Fill.Right > Fill.Left then
    DrawSurface(ACanvas, Fill, IfThen(AEnabled, P.Primary, P.TextDisabled),
      IfThen(AEnabled, P.Primary, P.TextDisabled), MaxScale(2, APPI), 1);
  ThumbSize := MaxScale(14, APPI);
  Thumb := Rect(X - ThumbSize div 2,
    (ARect.Top + ARect.Bottom - ThumbSize) div 2,
    X - ThumbSize div 2 + ThumbSize,
    (ARect.Top + ARect.Bottom - ThumbSize) div 2 + ThumbSize);
  ACanvas.Brush.Color := P.Surface;
  ACanvas.Pen.Color := IfThen(AEnabled, P.Primary, P.TextDisabled);
  ACanvas.Pen.Width := Max(1, MaxScale(2, APPI));
  ACanvas.Ellipse(Thumb);
  if AFocused then
    DrawFocusRing(ACanvas, Thumb, P.Primary, ThumbSize div 2, 1);
end;

class procedure TMaxPainter.DrawLinearProgress(ACanvas: TCanvas;
  const ARect: TRect; const APosition, AMinimum, AMaximum, ARadius: Integer);
var
  P: TMaxPalette;
  Fill: TRect;
  RangeValue: Integer;
  PosValue: Integer;
  WidthValue: Integer;
begin
  P := TMaxTheme.Palette;
  RangeValue := AMaximum - AMinimum;
  if RangeValue <= 0 then
    PosValue := 0
  else
    PosValue := EnsureRange(APosition, AMinimum, AMaximum) - AMinimum;
  DrawSurface(ACanvas, ARect, P.Border, P.Border, ARadius, 1);
  if RangeValue <= 0 then
    Exit;
  WidthValue := MulDiv(ARect.Width, PosValue, RangeValue);
  if WidthValue <= 0 then
    Exit;
  Fill := ARect;
  Fill.Right := Min(Fill.Right, Fill.Left + WidthValue);
  DrawSurface(ACanvas, Fill, P.Primary, P.Primary, ARadius, 1);
end;

class procedure TMaxPainter.DrawPill(ACanvas: TCanvas; const ARect: TRect;
  const AText: string; AFont: TFont; const AKind: TMaxPillKind;
  const ASelected, ACloseButton: Boolean; const APPI: Integer);
var
  FillColor: TColor;
  BorderColor: TColor;
  TextColor: TColor;
  R: TRect;
  TextRect: TRect;
  IconRect: TRect;
  Save: Integer;
begin
  PillColors(AKind, FillColor, BorderColor, TextColor);
  if ASelected then
  begin
    FillColor := TMaxTheme.Palette.Primary;
    BorderColor := TMaxTheme.Palette.Primary;
    TextColor := clWhite;
  end;
  R := ARect;
  InflateRect(R, -1, -1);
  DrawSurface(ACanvas, R, FillColor, BorderColor, R.Height div 2, 1);
  TextRect := R;
  InflateRect(TextRect, -MaxScale(10, APPI), 0);
  if ACloseButton then
  begin
    IconRect := Rect(R.Right - MaxScale(20, APPI), R.Top,
      R.Right - MaxScale(4, APPI), R.Bottom);
    TextRect.Right := IconRect.Left;
    InflateRect(IconRect, -MaxScale(3, APPI), -MaxScale(3, APPI));
    TMaxIconPainter.Draw(ACanvas, IconRect, mikClose, TextColor, 1);
  end;
  Save := SaveDC(ACanvas.Handle);
  try
    ACanvas.Font.Assign(AFont);
    ACanvas.Font.Color := TextColor;
    SetBkMode(ACanvas.Handle, TRANSPARENT);
    DrawText(ACanvas.Handle, PChar(AText), Length(AText), TextRect,
      DT_CENTER or DT_VCENTER or DT_SINGLELINE or DT_END_ELLIPSIS);
  finally
    RestoreDC(ACanvas.Handle, Save);
  end;
end;

end.
