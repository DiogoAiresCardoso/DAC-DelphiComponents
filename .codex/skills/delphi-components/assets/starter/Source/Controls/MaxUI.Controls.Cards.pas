unit MaxUI.Controls.Cards;

{$CODEPAGE 65001}

interface

uses
  System.Classes,
  Winapi.Messages,
  Vcl.Controls,
  Vcl.Graphics,
  MaxUI.Controls.Base,
  MaxUI.Types;

type
  TMaxSummaryCard = class(TMaxCard)
  private
    FTitle: string;
    FValueText: string;
    FDeltaText: string;
    FDeltaKind: TMaxDeltaKind;
    FIconKind: TMaxIconKind;
    FAccentColor: TColor;
    FClickable: Boolean;
    FHot: Boolean;
    FPressed: Boolean;
    procedure SetTitle(const Value: string);
    procedure SetValueText(const Value: string);
    procedure SetDeltaText(const Value: string);
    procedure SetDeltaKind(const Value: TMaxDeltaKind);
    procedure SetIconKind(const Value: TMaxIconKind);
    procedure SetAccentColor(const Value: TColor);
    procedure SetClickable(const Value: Boolean);
    procedure CMMouseEnter(var Message: TMessage); message CM_MOUSEENTER;
    procedure CMMouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Title: string read FTitle write SetTitle;
    property ValueText: string read FValueText write SetValueText;
    property DeltaText: string read FDeltaText write SetDeltaText;
    property DeltaKind: TMaxDeltaKind read FDeltaKind write SetDeltaKind default mdkNeutral;
    property IconKind: TMaxIconKind read FIconKind write SetIconKind default mikCurrency;
    property AccentColor: TColor read FAccentColor write SetAccentColor;
    property Clickable: Boolean read FClickable write SetClickable default False;
    property OnClick;
  end;

implementation

uses
  System.Math,
  Winapi.Windows,
  MaxUI.Dpi,
  MaxUI.Icons,
  MaxUI.Painter,
  MaxUI.Theme;

constructor TMaxSummaryCard.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FTitle := 'Receita';
  FValueText := 'R$ 0,00';
  FDeltaText := '0% vs. período anterior';
  FDeltaKind := mdkNeutral;
  FIconKind := mikCurrency;
  FAccentColor := TMaxTheme.Palette.Primary;
  FClickable := False;
  FHot := False;
  FPressed := False;
  TabStop := False;
  Width := 170;
  Height := 128;
end;

procedure TMaxSummaryCard.CMMouseEnter(var Message: TMessage);
begin
  inherited;
  if FClickable then
  begin
    FHot := True;
    Invalidate;
  end;
end;

procedure TMaxSummaryCard.CMMouseLeave(var Message: TMessage);
begin
  inherited;
  if FHot or FPressed then
  begin
    FHot := False;
    FPressed := False;
    Invalidate;
  end;
end;

procedure TMaxSummaryCard.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited;
  if FClickable and (Key in [VK_SPACE, VK_RETURN]) then
  begin
    Click;
    Key := 0;
  end;
end;

procedure TMaxSummaryCard.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  if FClickable and (Button = mbLeft) then
  begin
    FPressed := True;
    if CanFocus then SetFocus;
    Invalidate;
  end;
end;

procedure TMaxSummaryCard.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  if FClickable and FPressed and (Button = mbLeft) then
  begin
    FPressed := False;
    Invalidate;
    if PtInRect(ClientRect, Point(X, Y)) then
      Click;
  end;
end;

procedure TMaxSummaryCard.Paint;
var
  R: TRect;
  IconCircle: TRect;
  IconRect: TRect;
  TextRect: TRect;
  DeltaColor: TColor;
  DeltaPrefix: string;
  FillColor: TColor;
  CardBorderColor: TColor;
  Save: Integer;
begin
  FillColor := SurfaceColor;
  CardBorderColor := Self.BorderColor;
  if FHot then CardBorderColor := TMaxTheme.Palette.Primary;
  if FPressed then FillColor := TMaxTheme.Palette.PrimarySoft;
  R := ClientRect;
  InflateRect(R, -1, -1);
  TMaxPainter.DrawSurface(Canvas, R, FillColor, CardBorderColor,
    MaxScale(CornerRadius, CurrentPPI), 1);
  if Focused and FClickable then
    TMaxPainter.DrawFocusRing(Canvas, R, TMaxTheme.Palette.Primary,
      MaxScale(CornerRadius, CurrentPPI), 2);

  IconCircle := Rect(MaxScale(14, CurrentPPI), MaxScale(14, CurrentPPI),
    MaxScale(50, CurrentPPI), MaxScale(50, CurrentPPI));
  Canvas.Brush.Color := TMaxPainter.BlendColor(FAccentColor, clWhite, 205);
  Canvas.Pen.Color := Canvas.Brush.Color;
  Canvas.Ellipse(IconCircle);
  IconRect := IconCircle;
  InflateRect(IconRect, -MaxScale(9, CurrentPPI), -MaxScale(9, CurrentPPI));
  TMaxIconPainter.Draw(Canvas, IconRect, FIconKind, FAccentColor,
    Max(1, MaxScale(2, CurrentPPI)));

  Save := SaveDC(Canvas.Handle);
  try
    SetBkMode(Canvas.Handle, TRANSPARENT);
    TextRect := Rect(MaxScale(14, CurrentPPI), MaxScale(56, CurrentPPI),
      Width - MaxScale(12, CurrentPPI), MaxScale(76, CurrentPPI));
    Canvas.Font.Assign(Font);
    Canvas.Font.Color := TMaxTheme.Palette.TextSecondary;
    DrawText(Canvas.Handle, PChar(FTitle), Length(FTitle), TextRect,
      DT_LEFT or DT_VCENTER or DT_SINGLELINE or DT_END_ELLIPSIS);

    TextRect.Top := MaxScale(75, CurrentPPI);
    TextRect.Bottom := MaxScale(102, CurrentPPI);
    Canvas.Font.Size := 12;
    Canvas.Font.Style := [fsBold];
    Canvas.Font.Color := TMaxTheme.Palette.Text;
    DrawText(Canvas.Handle, PChar(FValueText), Length(FValueText), TextRect,
      DT_LEFT or DT_VCENTER or DT_SINGLELINE or DT_END_ELLIPSIS);

    case FDeltaKind of
      mdkPositive:
        begin DeltaColor := TMaxTheme.Palette.Success; DeltaPrefix := '▲ '; end;
      mdkNegative:
        begin DeltaColor := TMaxTheme.Palette.Danger; DeltaPrefix := '▼ '; end;
    else
      begin DeltaColor := TMaxTheme.Palette.TextSecondary; DeltaPrefix := '• '; end;
    end;
    TextRect.Top := MaxScale(103, CurrentPPI);
    TextRect.Bottom := Height - MaxScale(8, CurrentPPI);
    Canvas.Font.Size := 8;
    Canvas.Font.Style := [];
    Canvas.Font.Color := DeltaColor;
    DeltaPrefix := DeltaPrefix + FDeltaText;
    DrawText(Canvas.Handle, PChar(DeltaPrefix), Length(DeltaPrefix), TextRect,
      DT_LEFT or DT_VCENTER or DT_SINGLELINE or DT_END_ELLIPSIS);
  finally
    RestoreDC(Canvas.Handle, Save);
  end;
end;

procedure TMaxSummaryCard.SetAccentColor(const Value: TColor);
begin
  if FAccentColor = Value then Exit;
  FAccentColor := Value;
  Invalidate;
end;

procedure TMaxSummaryCard.SetClickable(const Value: Boolean);
begin
  if FClickable = Value then Exit;
  FClickable := Value;
  TabStop := Value;
  Invalidate;
end;

procedure TMaxSummaryCard.SetDeltaKind(const Value: TMaxDeltaKind);
begin
  if FDeltaKind = Value then Exit;
  FDeltaKind := Value;
  Invalidate;
end;

procedure TMaxSummaryCard.SetDeltaText(const Value: string);
begin
  if FDeltaText = Value then Exit;
  FDeltaText := Value;
  Invalidate;
end;

procedure TMaxSummaryCard.SetIconKind(const Value: TMaxIconKind);
begin
  if FIconKind = Value then Exit;
  FIconKind := Value;
  Invalidate;
end;

procedure TMaxSummaryCard.SetTitle(const Value: string);
begin
  if FTitle = Value then Exit;
  FTitle := Value;
  Invalidate;
end;

procedure TMaxSummaryCard.SetValueText(const Value: string);
begin
  if FValueText = Value then Exit;
  FValueText := Value;
  Invalidate;
end;

end.
