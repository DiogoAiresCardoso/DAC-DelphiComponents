unit DAC.Components.Controls.StatusBar;

interface

uses
  System.Classes,
  System.Skia,
  System.Types,
  System.UITypes,
  Winapi.Messages,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.Skia,
  DAC.Components.Controls.SystemText,
  DAC.Components.Skia.Renderer,
  DAC.Components.DesignSystem.Theme;

type
  TDACStatusBar = class(TCustomControl)
  private
    FLeftText: string;
    FPaintBox: TSkPaintBox;
    FRenderer: TDACSkiaRenderer;
    FTextOverlay: TDACSystemTextOverlay;
    FRightText: string;
    FThemeMode: TDACThemeMode;
    procedure PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    procedure SetLeftText(const AValue: string);
    procedure SetRightText(const AValue: string);
    procedure SetThemeMode(const AValue: TDACThemeMode);
    procedure ThemeChanged(Sender: TObject);
    procedure UpdatePaintBoxBounds;
    procedure WMEraseBkgnd(var AMessage: TWMEraseBkgnd); message WM_ERASEBKGND;
  protected
    procedure CreateWnd; override;
    procedure Loaded; override;
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ResolvedBackgroundColor: TAlphaColor;
    function ResolvedTextColor: TAlphaColor;
    procedure Redraw;
  published
    property Align;
    property Anchors;
    property Constraints;
    property Enabled;
    property LeftText: string read FLeftText write SetLeftText;
    property ParentShowHint;
    property PopupMenu;
    property RightText: string read FRightText write SetRightText;
    property ShowHint;
    property TabOrder;
    property TabStop default False;
    property ThemeMode: TDACThemeMode read FThemeMode write SetThemeMode default dtmInherit;
    property Visible;
  end;

implementation

uses
  DAC.Components.DesignSystem.ComponentStyle,
  DAC.Components.DesignSystem.ControlTokens,
  DAC.Components.DesignSystem.Fonts,
  DAC.Components.DesignSystem.Tokens;

constructor TDACStatusBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  Width := Round(TDACComponentStyle.Resolve(dtmInherit).Tokens.Controls.StatusBarDefaultWidth);
  Height := Round(TDACComponentStyle.Resolve(dtmInherit).Tokens.Controls.StatusBarHeight);
  TabStop := False;
  ParentColor := False;
  StyleElements := [];
  FLeftText := 'Conectado';
  FRightText := 'Delphi + VCL + Skia';
  FThemeMode := dtmInherit;
  TDACThemeManager.RegisterListener(Self, ThemeChanged);
  FRenderer := TDACSkiaRenderer.Create;
  FPaintBox := TSkPaintBox.Create(Self);
  FPaintBox.Parent := Self;
  FPaintBox.SetSubComponent(True);
  FPaintBox.StyleElements := [];
  FPaintBox.OnDraw := PaintBoxDraw;
  FTextOverlay := TDACSystemTextOverlay.Create(Self);
  FTextOverlay.Parent := Self;
  FTextOverlay.SetSubComponent(True);
  FTextOverlay.Align := alClient;
end;

destructor TDACStatusBar.Destroy;
begin
  TDACThemeManager.UnregisterListener(Self);
  FTextOverlay.Free;
  FPaintBox.Free;
  FRenderer.Free;
  inherited;
end;

procedure TDACStatusBar.CreateWnd;
begin
  inherited;
  UpdatePaintBoxBounds;
  Redraw;
end;

procedure TDACStatusBar.Loaded;
begin
  inherited;
  UpdatePaintBoxBounds;
  Redraw;
end;

procedure TDACStatusBar.PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
  const ADest: TRectF; const AOpacity: Single);
var
  LTokens: TDACControlTokens;
  LPaint: ISkPaint;
  LRect: TRectF;
begin
  if ACanvas = nil then
    Exit;
  FRenderer.BeginNativeText(FTextOverlay);
  try
  LTokens := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls;
  LRect := TRectF.Create(LTokens.BorderWidth / 2, LTokens.BorderWidth / 2,
    ADest.Width - (LTokens.BorderWidth / 2), ADest.Height - (LTokens.BorderWidth / 2));
  FRenderer.FillRoundRect(ACanvas, LRect, LTokens.StatusBackground,
    LTokens.StatusBarRadius, LTokens.AlphaOpaque);
  FRenderer.StrokeRoundRect(ACanvas, LRect, LTokens.StatusBorder,
    LTokens.StatusBarRadius, LTokens.BorderWidth, LTokens.AlphaOpaque);
  LPaint := TSkPaint.Create(TSkPaintStyle.Fill);
  LPaint.AntiAlias := True;
  LPaint.Color := LTokens.StatusIndicator;
  ACanvas.DrawCircle(LTokens.StatusBarInset, ADest.Height / 2,
    LTokens.StatusBarIndicatorRadius, LPaint);
  FRenderer.Text(ACanvas, FLeftText, TDACComponentStyle.FontFamily,
    LTokens.StatusBarInset + LTokens.StatusBarLeftTextOffset, LTokens.StatusBarTextBaseline,
    LTokens.StatusBarTextSize, LTokens.StatusText, False,
    (ADest.Width / 2) - LTokens.StatusBarRightTextInset - LTokens.StatusBarLeftTextOffset);
  FRenderer.Text(ACanvas, FRightText, TDACComponentStyle.FontFamily,
    ADest.Width / 2, LTokens.StatusBarTextBaseline, LTokens.StatusBarTextSize, LTokens.StatusTextSecondary, False,
    (ADest.Width / 2) - LTokens.StatusBarRightTextInset);
  finally
    FRenderer.EndNativeText;
  end;
end;

procedure TDACStatusBar.Redraw;
begin
  if (FPaintBox = nil) or (csDestroying in ComponentState) then
    Exit;
  UpdatePaintBoxBounds;
  if csDesigning in ComponentState then
  begin
    if Parent <> nil then
      FPaintBox.Redraw;
    Invalidate;
    Exit;
  end;
  if (Parent <> nil) and HandleAllocated and Parent.HandleAllocated then
    FPaintBox.Redraw;
  if HandleAllocated then
    Invalidate;
end;

function TDACStatusBar.ResolvedBackgroundColor: TAlphaColor;
begin
  Result := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls.StatusBackground;
end;

function TDACStatusBar.ResolvedTextColor: TAlphaColor;
begin
  Result := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls.StatusText;
end;

procedure TDACStatusBar.Resize;
begin
  inherited;
  UpdatePaintBoxBounds;
  Redraw;
end;

procedure TDACStatusBar.SetLeftText(const AValue: string);
begin
  if FLeftText = AValue then
    Exit;
  FLeftText := AValue;
  Redraw;
end;

procedure TDACStatusBar.SetRightText(const AValue: string);
begin
  if FRightText = AValue then
    Exit;
  FRightText := AValue;
  Redraw;
end;

procedure TDACStatusBar.SetThemeMode(const AValue: TDACThemeMode);
begin
  if FThemeMode = AValue then
    Exit;
  FThemeMode := AValue;
  ThemeChanged(Self);
end;

procedure TDACStatusBar.ThemeChanged(Sender: TObject);
begin
  Redraw;
end;

procedure TDACStatusBar.UpdatePaintBoxBounds;
var
  LHeight: Integer;
  LWidth: Integer;
begin
  if (FPaintBox = nil) or (csLoading in ComponentState) or
    (csDestroying in ComponentState) then
    Exit;
  LWidth := Width;
  LHeight := Height;
  if not (csDesigning in ComponentState) and HandleAllocated then
  begin
    LWidth := ClientWidth;
    LHeight := ClientHeight;
  end;
  FPaintBox.SetBounds(0, 0, LWidth, LHeight);
end;

procedure TDACStatusBar.WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
begin
  AMessage.Result := 1;
end;

end.

