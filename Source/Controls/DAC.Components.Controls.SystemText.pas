unit DAC.Components.Controls.SystemText;

interface

uses
  System.Classes,
  System.Generics.Collections,
  System.Types,
  System.UITypes,
  Winapi.Windows,
  Vcl.Controls,
  Vcl.Graphics,
  DAC.Components.DesignSystem.Theme,
  DAC.Components.Skia.Renderer;

type
  TDACSystemTextHorzAlign = (
    mthaLeft,
    mthaCenter,
    mthaRight
  );

  TDACSystemTextVertAlign = (
    mtvaTop,
    mtvaCenter,
    mtvaBottom
  );

  TDACSystemTextRole = (
    mtrSmall,
    mtrBody,
    mtrCaption,
    mtrDisplay,
    mtrCustom
  );

  TDACSystemTextTone = (
    mttDefault,
    mttPrimary,
    mttSecondary,
    mttMuted,
    mttAccent,
    mttSuccess,
    mttWarning,
    mttDanger,
    mttCustom
  );

  { A non-windowed layer used by Skia controls that need native text metrics
    and ClearType glyph rasterization.  It deliberately owns no visual chrome:
    Skia continues to draw the surface, borders, icons and states below it. }
  TDACSystemTextOverlay = class(TGraphicControl, IDACNativeTextSink)
  private
    FItems: TList<TDACNativeTextDrawItem>;
    FInvalidatePending: Boolean;
    function NativeColor(const AColor: TAlphaColor): TColor;
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function _AddRef: Integer; stdcall;
    function _Release: Integer; stdcall;
    procedure BeginNativeTextFrame;
    procedure QueueNativeText(const AItem: TDACNativeTextDrawItem);
    procedure EndNativeTextFrame;
    procedure QueueText(const AText, AFamily: string; const AX, AY, ASize: Single;
      const AColor: TAlphaColor; const ABold: Boolean = False;
      const AMaxWidth: Single = 0);
    procedure QueueCenteredText(const AText, AFamily: string;
      const ABounds: TRectF; const ASize: Single; const AColor: TAlphaColor;
      const ABold: Boolean = False; const AMaxWidth: Single = 0);
  end;

  TDACSystemText = class(TGraphicControl)
  private
    FBold: Boolean;
    FCustomFontSize: Boolean;
    FCustomTextColor: Boolean;
    FFontFamily: string;
    FFontSize: Integer;
    FHorzAlign: TDACSystemTextHorzAlign;
    FInvalidatePending: Boolean;
    FMaxLines: Integer;
    FRole: TDACSystemTextRole;
    FText: string;
    FTextColor: TAlphaColor;
    FThemeMode: TDACThemeMode;
    FTone: TDACSystemTextTone;
    FUpdateLock: Integer;
    FVertAlign: TDACSystemTextVertAlign;
    procedure RequestInvalidate;
    function IsFontSizeStored: Boolean;
    function IsTextColorStored: Boolean;
    procedure SetBold(const AValue: Boolean);
    procedure SetFontFamily(const AValue: string);
    procedure SetFontSize(const AValue: Integer);
    procedure SetHorzAlign(const AValue: TDACSystemTextHorzAlign);
    procedure SetMaxLines(const AValue: Integer);
    procedure SetRole(const AValue: TDACSystemTextRole);
    procedure SetText(const AValue: string);
    procedure SetTextColor(const AValue: TAlphaColor);
    procedure SetThemeMode(const AValue: TDACThemeMode);
    procedure SetTone(const AValue: TDACSystemTextTone);
    procedure SetVertAlign(const AValue: TDACSystemTextVertAlign);
    procedure ThemeChanged(Sender: TObject);
    procedure ApplyCanvasFont(const AFontFamily: string; const AFontSize: Integer;
      const ABold: Boolean);
    procedure ApplySemanticStyle;
  protected
    procedure Loaded; override;
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure BeginUpdate;
    procedure EndUpdate;
    function MeasureTextHeight(const AText: string;
      const AWidth: Integer): Integer;
    function MeasureTextWidth(const AText, AFontFamily: string;
      const AFontSize: Integer; const ABold: Boolean): Integer;
    function ResolvedTextColor: TAlphaColor;
  published
    property Bold: Boolean read FBold write SetBold;
    property FontFamily: string read FFontFamily write SetFontFamily;
    property FontSize: Integer read FFontSize write SetFontSize
      stored IsFontSizeStored;
    property HorzAlign: TDACSystemTextHorzAlign read FHorzAlign write SetHorzAlign;
    property MaxLines: Integer read FMaxLines write SetMaxLines;
    property Role: TDACSystemTextRole read FRole write SetRole default mtrSmall;
    property Text: string read FText write SetText;
    property TextColor: TAlphaColor read FTextColor write SetTextColor
      stored IsTextColorStored;
    property ThemeMode: TDACThemeMode read FThemeMode write SetThemeMode default dtmInherit;
    property Tone: TDACSystemTextTone read FTone write SetTone default mttDefault;
    property VertAlign: TDACSystemTextVertAlign read FVertAlign write SetVertAlign;
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
  System.SysUtils,
  DAC.Components.DesignSystem.ColorTokens,
  DAC.Components.DesignSystem.ControlTokens,
  DAC.Components.DesignSystem.Fonts,
  DAC.Components.DesignSystem.ComponentStyle;

constructor TDACSystemTextOverlay.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle - [csOpaque];
  Enabled := False;
  FInvalidatePending := False;
  FItems := TList<TDACNativeTextDrawItem>.Create;
end;

destructor TDACSystemTextOverlay.Destroy;
begin
  FItems.Free;
  inherited;
end;

function TDACSystemTextOverlay._AddRef: Integer;
begin
  Result := -1;
end;

function TDACSystemTextOverlay._Release: Integer;
begin
  Result := -1;
end;

function TDACSystemTextOverlay.NativeColor(const AColor: TAlphaColor): TColor;
var
  LValue: Cardinal;
begin
  LValue := Cardinal(AColor);
  Result := RGB((LValue shr 16) and $FF, (LValue shr 8) and $FF,
    LValue and $FF);
end;

procedure TDACSystemTextOverlay.BeginNativeTextFrame;
begin
  FItems.Clear;
  FInvalidatePending := False;
end;

procedure TDACSystemTextOverlay.QueueNativeText(
  const AItem: TDACNativeTextDrawItem);
begin
  if AItem.Text = '' then
    Exit;
  FItems.Add(AItem);
end;

procedure TDACSystemTextOverlay.EndNativeTextFrame;
begin
  if FInvalidatePending then
    Exit;
  FInvalidatePending := True;
  Invalidate;
end;

procedure TDACSystemTextOverlay.QueueText(const AText, AFamily: string;
  const AX, AY, ASize: Single; const AColor: TAlphaColor;
  const ABold: Boolean; const AMaxWidth: Single);
var
  LItem: TDACNativeTextDrawItem;
begin
  LItem.Text := AText;
  LItem.Family := AFamily;
  LItem.Bounds := TRectF.Create(0, 0, 0, 0);
  LItem.Baseline := TPointF.Create(AX, AY);
  LItem.Size := ASize;
  LItem.Color := AColor;
  LItem.Bold := ABold;
  LItem.Centered := False;
  LItem.MaxWidth := AMaxWidth;
  QueueNativeText(LItem);
end;

procedure TDACSystemTextOverlay.QueueCenteredText(const AText, AFamily: string;
  const ABounds: TRectF; const ASize: Single; const AColor: TAlphaColor;
  const ABold: Boolean; const AMaxWidth: Single);
var
  LItem: TDACNativeTextDrawItem;
begin
  LItem.Text := AText;
  LItem.Family := AFamily;
  LItem.Bounds := ABounds;
  LItem.Baseline := TPointF.Create(0, 0);
  LItem.Size := ASize;
  LItem.Color := AColor;
  LItem.Bold := ABold;
  LItem.Centered := True;
  LItem.MaxWidth := AMaxWidth;
  QueueNativeText(LItem);
end;

procedure TDACSystemTextOverlay.Paint;
var
  LFlags: Cardinal;
  LFont: HFONT;
  LFontHeight: Integer;
  LIndex: Integer;
  LItem: TDACNativeTextDrawItem;
  LOldFont: HGDIOBJ;
  LRect: TRect;
  LWidth: Integer;
begin
  inherited;
  FInvalidatePending := False;
  if FItems.Count = 0 then
    Exit;

  SetBkMode(Canvas.Handle, TRANSPARENT);
  for LIndex := 0 to FItems.Count - 1 do
  begin
    LItem := FItems[LIndex];
    LFontHeight := Max(1, Round(LItem.Size));
    LFont := CreateFont(-LFontHeight, 0, 0, 0,
      IfThen(LItem.Bold, FW_BOLD, FW_NORMAL), 0, 0, 0, DEFAULT_CHARSET,
      OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, CLEARTYPE_QUALITY,
      DEFAULT_PITCH or FF_DONTCARE, PChar(LItem.Family));
    if LFont = 0 then
      Continue;
    LOldFont := SelectObject(Canvas.Handle, LFont);
    try
      SetTextColor(Canvas.Handle, NativeColor(LItem.Color));
      LFlags := DT_SINGLELINE or DT_END_ELLIPSIS or DT_NOPREFIX;
      if LItem.Centered then
      begin
        LRect := Rect(Round(LItem.Bounds.Left), Round(LItem.Bounds.Top),
          Round(LItem.Bounds.Right), Round(LItem.Bounds.Bottom));
        LFlags := LFlags or DT_CENTER or DT_VCENTER;
      end
      else
      begin
        LWidth := Round(LItem.MaxWidth);
        if LWidth <= 0 then
          LWidth := Max(1, Width - Round(LItem.Baseline.X));
        LRect := Rect(Round(LItem.Baseline.X),
          Round(LItem.Baseline.Y) - LFontHeight,
          Round(LItem.Baseline.X) + LWidth,
          Round(LItem.Baseline.Y) + Max(1, LFontHeight div 3));
        LFlags := LFlags or DT_LEFT or DT_TOP;
      end;
      DrawText(Canvas.Handle, PChar(LItem.Text), Length(LItem.Text), LRect,
        LFlags);
    finally
      SelectObject(Canvas.Handle, LOldFont);
      DeleteObject(LFont);
    end;
  end;
end;

constructor TDACSystemText.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FBold := False;
  FCustomFontSize := False;
  FCustomTextColor := False;
  FFontFamily := TDACComponentStyle.FontFamily;
  FFontSize := TDACComponentStyle.SmallTextSize;
  FHorzAlign := mthaLeft;
  FInvalidatePending := False;
  FMaxLines := 1;
  FRole := mtrSmall;
  FText := '';
  FThemeMode := dtmInherit;
  FTone := mttDefault;
  ApplySemanticStyle;
  TDACThemeManager.RegisterListener(Self, ThemeChanged);
  FUpdateLock := 0;
  FVertAlign := mtvaTop;
end;

destructor TDACSystemText.Destroy;
begin
  TDACThemeManager.UnregisterListener(Self);
  inherited;
end;

procedure TDACSystemText.ApplySemanticStyle;
var
  LTheme: IDACComponentsTheme;
  LTokens: TDACControlTokens;
begin
  LTheme := TDACComponentStyle.ResolveForSurface(Self, FThemeMode);
  LTokens := LTheme.Tokens.Controls;
  FFontFamily := TDACComponentStyle.FontFamily;

  case FRole of
    mtrSmall:
      FFontSize := Round(LTheme.Tokens.Typography.SmallTextSize);
    mtrBody:
      FFontSize := Round(LTheme.Tokens.Typography.TextSize);
    mtrCaption:
      FFontSize := Round(LTheme.Tokens.Typography.CaptionSize);
    mtrDisplay:
      FFontSize := Round(LTheme.Tokens.Typography.DisplaySize);
  end;

  case FTone of
    mttDefault:
      FTextColor := LTokens.InputText;
    mttPrimary:
      FTextColor := LTokens.SystemTextPrimary;
    mttSecondary:
      FTextColor := LTokens.SystemTextSecondary;
    mttMuted:
      FTextColor := LTokens.SystemTextMuted;
    mttAccent:
      FTextColor := LTokens.SystemTextAccent;
    mttSuccess:
      FTextColor := LTokens.SystemTextSuccess;
    mttWarning:
      FTextColor := LTokens.SystemTextWarning;
    mttDanger:
      FTextColor := LTokens.SystemTextDanger;
  end;

  RequestInvalidate;
end;

function TDACSystemText.ResolvedTextColor: TAlphaColor;
begin
  Result := FTextColor;
end;

function TDACSystemText.IsFontSizeStored: Boolean;
begin
  Result := FCustomFontSize;
end;

function TDACSystemText.IsTextColorStored: Boolean;
begin
  Result := FCustomTextColor;
end;

procedure TDACSystemText.BeginUpdate;
begin
  Inc(FUpdateLock);
end;

procedure TDACSystemText.EndUpdate;
begin
  if FUpdateLock > 0 then
    Dec(FUpdateLock);

  if (FUpdateLock = 0) and FInvalidatePending then
  begin
    FInvalidatePending := False;
    Invalidate;
  end;
end;

procedure TDACSystemText.Loaded;
begin
  inherited;
  ApplySemanticStyle;
end;

procedure TDACSystemText.Paint;
var
  LFlags: Cardinal;
  LRect: TRect;
begin
  inherited;

  Canvas.Brush.Style := bsClear;
  ApplyCanvasFont(FFontFamily, FFontSize, FBold);
  Canvas.Font.Color := TDACComponentColors.ToVclColor(FTextColor);

  SetBkMode(Canvas.Handle, TRANSPARENT);

  LRect := ClientRect;
  LFlags := DT_NOPREFIX;
  if FMaxLines = 1 then
    LFlags := LFlags or DT_SINGLELINE or DT_END_ELLIPSIS
  else
    // Educational/gallery text must use its allocated lines completely.
    // Truncating a multi-line caption hides the very behavior being shown.
    LFlags := LFlags or DT_WORDBREAK;

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

procedure TDACSystemText.ApplyCanvasFont(const AFontFamily: string;
  const AFontSize: Integer; const ABold: Boolean);
begin
  if Trim(AFontFamily) <> '' then
    Canvas.Font.Name := AFontFamily
  else
    Canvas.Font.Name := TDACComponentStyle.FontFamily;
  Canvas.Font.Size := Max(1, AFontSize);
  if ABold then
    Canvas.Font.Style := [fsBold]
  else
    Canvas.Font.Style := [];
end;

function TDACSystemText.MeasureTextWidth(const AText, AFontFamily: string;
  const AFontSize: Integer; const ABold: Boolean): Integer;
begin
  { TGraphicControl.Canvas obtains its device context through Parent.  During
    IDE insertion a composite control has not yet been parented, so asking the
    canvas for text metrics would force CreateWnd and raise "has no parent
    window".  Use a deterministic, conservative pre-parent estimate; the
    next layout pass uses the real Windows text metrics once the host exists. }
  if (Parent = nil) or not Parent.HandleAllocated then
    Exit(Max(1, Round(Length(AText) * Max(1, AFontSize) * 0.62)));

  ApplyCanvasFont(AFontFamily, AFontSize, ABold);
  Result := Canvas.TextWidth(AText);
end;

function TDACSystemText.MeasureTextHeight(const AText: string;
  const AWidth: Integer): Integer;
var
  LFlags: Cardinal;
  LRect: TRect;
begin
  { See MeasureTextWidth: never force a parent HWND just to calculate the
    provisional design-time layout of a non-windowed native text layer. }
  if (Parent = nil) or not Parent.HandleAllocated then
    Exit(Max(1, Round(Max(1, FFontSize) * 1.40)));

  ApplyCanvasFont(FFontFamily, FFontSize, FBold);
  LRect := Rect(0, 0, Max(1, AWidth), 0);
  LFlags := DT_CALCRECT or DT_NOPREFIX;
  if FMaxLines = 1 then
    LFlags := LFlags or DT_SINGLELINE
  else
    LFlags := LFlags or DT_WORDBREAK;
  Result := DrawText(Canvas.Handle, PChar(AText), Length(AText), LRect,
    LFlags);
  Result := Max(Canvas.TextHeight('Ag'), Result);
end;

procedure TDACSystemText.RequestInvalidate;
begin
  if FUpdateLock > 0 then
  begin
    FInvalidatePending := True;
    Exit;
  end;

  Invalidate;
end;

procedure TDACSystemText.SetBold(const AValue: Boolean);
begin
  if FBold = AValue then
    Exit;
  FBold := AValue;
  RequestInvalidate;
end;

procedure TDACSystemText.SetFontFamily(const AValue: string);
begin
  if FFontFamily = AValue then
    Exit;
  FFontFamily := AValue;
  RequestInvalidate;
end;

procedure TDACSystemText.SetFontSize(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(1, AValue);
  FRole := mtrCustom;
  FCustomFontSize := True;
  if FFontSize = LValue then
    Exit;
  FFontSize := LValue;
  RequestInvalidate;
end;

procedure TDACSystemText.SetHorzAlign(
  const AValue: TDACSystemTextHorzAlign);
begin
  if FHorzAlign = AValue then
    Exit;
  FHorzAlign := AValue;
  RequestInvalidate;
end;

procedure TDACSystemText.SetMaxLines(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(1, AValue);
  if FMaxLines = LValue then
    Exit;
  FMaxLines := LValue;
  RequestInvalidate;
end;

procedure TDACSystemText.SetRole(const AValue: TDACSystemTextRole);
begin
  if FRole = AValue then
  begin
    if AValue <> mtrCustom then
      ApplySemanticStyle;
    Exit;
  end;
  FRole := AValue;
  FCustomFontSize := AValue = mtrCustom;
  ApplySemanticStyle;
end;

procedure TDACSystemText.SetText(const AValue: string);
begin
  if FText = AValue then
    Exit;
  FText := AValue;
  RequestInvalidate;
end;

procedure TDACSystemText.SetTextColor(const AValue: TAlphaColor);
var
  LValue: TAlphaColor;
begin
  LValue := TDACComponentColors.Normalize(AValue);
  FTone := mttCustom;
  FCustomTextColor := True;
  if FTextColor = LValue then
    Exit;
  FTextColor := LValue;
  RequestInvalidate;
end;

procedure TDACSystemText.SetThemeMode(const AValue: TDACThemeMode);
begin
  if FThemeMode = AValue then
    Exit;
  FThemeMode := AValue;
  ThemeChanged(Self);
end;

procedure TDACSystemText.SetTone(const AValue: TDACSystemTextTone);
begin
  if FTone = AValue then
  begin
    if AValue <> mttCustom then
      ApplySemanticStyle;
    Exit;
  end;
  FTone := AValue;
  FCustomTextColor := AValue = mttCustom;
  ApplySemanticStyle;
end;

procedure TDACSystemText.ThemeChanged(Sender: TObject);
begin
  ApplySemanticStyle;
end;

procedure TDACSystemText.SetVertAlign(
  const AValue: TDACSystemTextVertAlign);
begin
  if FVertAlign = AValue then
    Exit;
  FVertAlign := AValue;
  RequestInvalidate;
end;

end.

