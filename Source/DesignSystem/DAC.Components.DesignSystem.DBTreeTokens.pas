unit DAC.Components.DesignSystem.DBTreeTokens;

interface

uses
  System.UITypes,
  DAC.Components.DesignSystem.ControlTokens;

type
  { Logical geometry belongs to the tree, while colors come from the active
    DAC theme. No dataset or domain policy participates in these tokens. }
  TDACDBTreeTokens = record
    HeaderHeight, RowHeight, Indent, CellPadding: Integer;
    ExpanderSize, CheckSize, GlyphGap, ScrollSize, MinimumThumb: Integer;
    CheckRadius, ThumbRadius, ThumbInset: Integer;
    DefaultWidth, DefaultHeight, FontSize, BorderWidth, FocusWidth: Integer;
    Background, Header, Text, HeaderText, DisabledText, Border: TAlphaColor;
    Accent, CheckedFill, CheckedText, Hover, Track, Thumb: TAlphaColor;
    MarkAlpha, SelectionAlpha: Byte;
    class function Resolve(const AControls: TDACControlTokens): TDACDBTreeTokens; static;
    class function Pixels(const ALogical, ADpi: Integer): Integer; static;
  end;

implementation

uses
  System.Math,
  Winapi.Windows;

class function TDACDBTreeTokens.Pixels(const ALogical, ADpi: Integer): Integer;
begin
  Result := MulDiv(ALogical, Max(96, ADpi), 96);
end;

class function TDACDBTreeTokens.Resolve(
  const AControls: TDACControlTokens): TDACDBTreeTokens;
begin
  Result.HeaderHeight := 34;
  Result.RowHeight := 32;
  Result.Indent := 20;
  Result.CellPadding := 10;
  Result.ExpanderSize := 16;
  Result.CheckSize := 16;
  Result.GlyphGap := 6;
  Result.ScrollSize := 14;
  Result.MinimumThumb := 24;
  Result.CheckRadius := 2;
  Result.ThumbRadius := 3;
  Result.ThumbInset := 2;
  Result.DefaultWidth := 480;
  Result.DefaultHeight := 320;
  Result.FontSize := 9;
  Result.BorderWidth := 1;
  Result.FocusWidth := 2;
  Result.Background := AControls.InputBackground;
  Result.Header := AControls.InputDisabledBackground;
  Result.Text := AControls.InputText;
  Result.HeaderText := AControls.InputText;
  Result.DisabledText := AControls.InputDisabledText;
  Result.Border := AControls.InputBorder;
  Result.Accent := AControls.InputFocus;
  Result.CheckedFill := AControls.ButtonPrimaryBackground;
  Result.CheckedText := AControls.ButtonPrimaryText;
  Result.Hover := AControls.ComboBoxPopupItemHotBackground;
  Result.Track := AControls.ScrollBarTrack;
  Result.Thumb := AControls.ScrollBarThumb;
  Result.MarkAlpha := 22;
  Result.SelectionAlpha := 34;
end;

end.
