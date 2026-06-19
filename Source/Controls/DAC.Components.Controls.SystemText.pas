unit MaxxRural.Components.Controls.SystemText;

interface

uses
  System.Classes,
  System.UITypes,
  Vcl.Controls,
  Vcl.Graphics;

type
  TMaxxRuralSystemTextHorzAlign = (
    mthaLeft,
    mthaCenter,
    mthaRight
  );

  TMaxxRuralSystemTextVertAlign = (
    mtvaTop,
    mtvaCenter,
    mtvaBottom
  );

  TMaxxRuralSystemText = class(TGraphicControl)
  private
    FBold: Boolean;
    FFontFamily: string;
    FFontSize: Integer;
    FHorzAlign: TMaxxRuralSystemTextHorzAlign;
    FInvalidatePending: Boolean;
    FMaxLines: Integer;
    FText: string;
    FTextColor: TAlphaColor;
    FUpdateLock: Integer;
    FVertAlign: TMaxxRuralSystemTextVertAlign;
    procedure RequestInvalidate;
    procedure SetBold(const AValue: Boolean);
    procedure SetFontFamily(const AValue: string);
    procedure SetFontSize(const AValue: Integer);
    procedure SetHorzAlign(const AValue: TMaxxRuralSystemTextHorzAlign);
    procedure SetMaxLines(const AValue: Integer);
    procedure SetText(const AValue: string);
    procedure SetTextColor(const AValue: TAlphaColor);
    procedure SetVertAlign(const AValue: TMaxxRuralSystemTextVertAlign);
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    procedure BeginUpdate;
    procedure EndUpdate;
    property Bold: Boolean read FBold write SetBold;
    property FontFamily: string read FFontFamily write SetFontFamily;
    property FontSize: Integer read FFontSize write SetFontSize;
    property HorzAlign: TMaxxRuralSystemTextHorzAlign read FHorzAlign write SetHorzAlign;
    property MaxLines: Integer read FMaxLines write SetMaxLines;
    property Text: string read FText write SetText;
    property TextColor: TAlphaColor read FTextColor write SetTextColor;
    property VertAlign: TMaxxRuralSystemTextVertAlign read FVertAlign write SetVertAlign;
    property OnClick;
    property OnDblClick;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
  end;

implementation

uses
  System.Math,
  Winapi.Windows,
  MaxxRural.Components.DesignSystem.ColorTokens,
  MaxxRural.Components.DesignSystem.Fonts;

constructor TMaxxRuralSystemText.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FBold := False;
  FFontFamily := TMaxxRuralComponentFontInstaller.FontFamily;
  FFontSize := 10;
  FHorzAlign := mthaLeft;
  FInvalidatePending := False;
  FMaxLines := 1;
  FText := '';
  FTextColor := TMaxxRuralComponentColors.ControlText;
  FUpdateLock := 0;
  FVertAlign := mtvaTop;
end;

procedure TMaxxRuralSystemText.BeginUpdate;
begin
  Inc(FUpdateLock);
end;

procedure TMaxxRuralSystemText.EndUpdate;
begin
  if FUpdateLock > 0 then
    Dec(FUpdateLock);

  if (FUpdateLock = 0) and FInvalidatePending then
  begin
    FInvalidatePending := False;
    Invalidate;
  end;
end;

procedure TMaxxRuralSystemText.Paint;
var
  LFlags: Cardinal;
  LRect: TRect;
begin
  inherited;

  Canvas.Brush.Style := bsClear;
  Canvas.Font.Name := FFontFamily;
  Canvas.Font.Size := FFontSize;
  Canvas.Font.Color := TMaxxRuralComponentColors.ToVclColor(FTextColor);
  if FBold then
    Canvas.Font.Style := [fsBold]
  else
    Canvas.Font.Style := [];

  SetBkMode(Canvas.Handle, TRANSPARENT);

  LRect := ClientRect;
  LFlags := DT_NOPREFIX or DT_END_ELLIPSIS;
  if FMaxLines = 1 then
    LFlags := LFlags or DT_SINGLELINE;

  case FHorzAlign of
    mthaCenter:
      LFlags := LFlags or DT_CENTER;
    mthaRight:
      LFlags := LFlags or DT_RIGHT;
  else
    LFlags := LFlags or DT_LEFT;
  end;

  case FVertAlign of
    mtvaCenter:
      LFlags := LFlags or DT_VCENTER;
    mtvaBottom:
      LFlags := LFlags or DT_BOTTOM;
  else
    LFlags := LFlags or DT_TOP;
  end;

  DrawText(Canvas.Handle, PChar(FText), -1, LRect, LFlags);
end;

procedure TMaxxRuralSystemText.RequestInvalidate;
begin
  if FUpdateLock > 0 then
  begin
    FInvalidatePending := True;
    Exit;
  end;

  Invalidate;
end;

procedure TMaxxRuralSystemText.SetBold(const AValue: Boolean);
begin
  if FBold = AValue then
    Exit;
  FBold := AValue;
  RequestInvalidate;
end;

procedure TMaxxRuralSystemText.SetFontFamily(const AValue: string);
begin
  if FFontFamily = AValue then
    Exit;
  FFontFamily := AValue;
  RequestInvalidate;
end;

procedure TMaxxRuralSystemText.SetFontSize(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(1, AValue);
  if FFontSize = LValue then
    Exit;
  FFontSize := LValue;
  RequestInvalidate;
end;

procedure TMaxxRuralSystemText.SetHorzAlign(
  const AValue: TMaxxRuralSystemTextHorzAlign);
begin
  if FHorzAlign = AValue then
    Exit;
  FHorzAlign := AValue;
  RequestInvalidate;
end;

procedure TMaxxRuralSystemText.SetMaxLines(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(1, AValue);
  if FMaxLines = LValue then
    Exit;
  FMaxLines := LValue;
  RequestInvalidate;
end;

procedure TMaxxRuralSystemText.SetText(const AValue: string);
begin
  if FText = AValue then
    Exit;
  FText := AValue;
  RequestInvalidate;
end;

procedure TMaxxRuralSystemText.SetTextColor(const AValue: TAlphaColor);
var
  LValue: TAlphaColor;
begin
  LValue := TMaxxRuralComponentColors.Normalize(AValue);
  if FTextColor = LValue then
    Exit;
  FTextColor := LValue;
  RequestInvalidate;
end;

procedure TMaxxRuralSystemText.SetVertAlign(
  const AValue: TMaxxRuralSystemTextVertAlign);
begin
  if FVertAlign = AValue then
    Exit;
  FVertAlign := AValue;
  RequestInvalidate;
end;

end.
