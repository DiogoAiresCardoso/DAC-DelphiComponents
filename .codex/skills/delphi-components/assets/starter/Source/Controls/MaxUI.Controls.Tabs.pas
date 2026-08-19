unit MaxUI.Controls.Tabs;

{$CODEPAGE 65001}

interface

uses
  System.Classes,
  System.Types,
  Vcl.Controls,
  Vcl.ComCtrls,
  Vcl.Graphics;

type
  TMaxPageControl = class(TPageControl)
  private
    FAccentColor: TColor;
    FIndicatorThickness: Integer;
    FTabHeightLogical: Integer;
    procedure SetAccentColor(const Value: TColor);
    procedure SetIndicatorThickness(const Value: Integer);
    procedure SetTabHeightLogical(const Value: Integer);
    procedure UpdateTabMetrics;
  protected
    procedure DrawTab(TabIndex: Integer; const Rect: TRect; Active: Boolean); override;
    procedure ChangeScale(M, D: Integer; isDpiChange: Boolean); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property AccentColor: TColor read FAccentColor write SetAccentColor;
    property IndicatorThickness: Integer read FIndicatorThickness write SetIndicatorThickness default 3;
    property TabHeightLogical: Integer read FTabHeightLogical write SetTabHeightLogical default 34;
  end;

implementation

uses
  System.Math,
  Winapi.Windows,
  MaxUI.Dpi,
  MaxUI.Painter,
  MaxUI.Theme;

constructor TMaxPageControl.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  OwnerDraw := True;
  DoubleBuffered := True;
  StyleElements := [seFont];
  Font.Name := 'Inter';
  Font.Size := 9;
  FAccentColor := TMaxTheme.Palette.Primary;
  FIndicatorThickness := 3;
  FTabHeightLogical := 34;
  Color := TMaxTheme.Palette.Surface;
  UpdateTabMetrics;
end;

procedure TMaxPageControl.ChangeScale(M, D: Integer; isDpiChange: Boolean);
begin
  inherited;
  if isDpiChange then
    UpdateTabMetrics;
end;

procedure TMaxPageControl.DrawTab(TabIndex: Integer; const Rect: TRect;
  Active: Boolean);
var
  R: TRect;
  Indicator: TRect;
  TextColor: TColor;
  FillColor: TColor;
  CaptionText: string;
  Save: Integer;
begin
  R := Rect;
  if Active then
  begin
    FillColor := TMaxTheme.Palette.PrimarySoft;
    TextColor := TMaxTheme.Palette.PrimaryDark;
  end
  else
  begin
    FillColor := TMaxTheme.Palette.Surface;
    TextColor := TMaxTheme.Palette.TextSecondary;
  end;
  TMaxPainter.DrawSurface(Canvas, R, FillColor, TMaxTheme.Palette.Border,
    MaxScale(6, CurrentPPI), 1);

  if Active then
  begin
    Indicator := R;
    case TabPosition of
      tpLeft:
        Indicator.Right := Indicator.Left + MaxScale(FIndicatorThickness, CurrentPPI);
      tpRight:
        Indicator.Left := Indicator.Right - MaxScale(FIndicatorThickness, CurrentPPI);
      tpBottom:
        Indicator.Top := Indicator.Bottom - MaxScale(FIndicatorThickness, CurrentPPI);
    else
      Indicator.Bottom := Indicator.Top + MaxScale(FIndicatorThickness, CurrentPPI);
    end;
    Canvas.Brush.Color := FAccentColor;
    Canvas.Pen.Color := FAccentColor;
    Canvas.Rectangle(Indicator);
  end;

  if (TabIndex >= 0) and (TabIndex < PageCount) then
    CaptionText := Pages[TabIndex].Caption
  else
    CaptionText := '';
  InflateRect(R, -MaxScale(8, CurrentPPI), -MaxScale(4, CurrentPPI));
  Save := SaveDC(Canvas.Handle);
  try
    Canvas.Font.Assign(Font);
    Canvas.Font.Color := TextColor;
    if Active then Canvas.Font.Style := [fsBold]
    else Canvas.Font.Style := [];
    SetBkMode(Canvas.Handle, TRANSPARENT);
    DrawText(Canvas.Handle, PChar(CaptionText), Length(CaptionText), R,
      DT_CENTER or DT_VCENTER or DT_SINGLELINE or DT_END_ELLIPSIS);
  finally
    RestoreDC(Canvas.Handle, Save);
  end;
end;

procedure TMaxPageControl.SetAccentColor(const Value: TColor);
begin
  if FAccentColor = Value then Exit;
  FAccentColor := Value;
  Invalidate;
end;

procedure TMaxPageControl.SetIndicatorThickness(const Value: Integer);
begin
  if FIndicatorThickness = Value then Exit;
  FIndicatorThickness := Max(1, Value);
  Invalidate;
end;

procedure TMaxPageControl.SetTabHeightLogical(const Value: Integer);
begin
  if FTabHeightLogical = Value then Exit;
  FTabHeightLogical := Max(24, Value);
  UpdateTabMetrics;
end;

procedure TMaxPageControl.UpdateTabMetrics;
begin
  TabHeight := MaxScale(FTabHeightLogical, CurrentPPI);
end;

end.
