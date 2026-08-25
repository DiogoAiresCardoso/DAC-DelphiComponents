unit DAC.Components.Controls.Slider;

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
  DAC.Components.DesignSystem.Theme,
  DAC.Components.Skia.Renderer;

type
  TDACSlider = class(TCustomControl)
  private
    FDragging: Boolean;
    FBindingCanModify: Boolean;
    FMaximum: Integer;
    FMinimum: Integer;
    FMouseInside: Boolean;
    FOnChange: TNotifyEvent;
    FPaintBox: TSkPaintBox;
    FRenderer: TDACSkiaRenderer;
    FTextOverlay: TDACSystemTextOverlay;
    FThemeMode: TDACThemeMode;
    FShowValue: Boolean;
    FValue: Integer;
    procedure CMEnabledChanged(var AMessage: TMessage); message CM_ENABLEDCHANGED;
    procedure DrawCircle(const ACanvas: ISkCanvas; const ACenter: TPointF;
      const ARadius: Single; const AColor: TAlphaColor; const AStroke: Boolean;
      const AStrokeWidth: Single; const AAlpha: Byte);
    procedure InvalidateSlider;
    procedure PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    procedure PaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxMouseEnter(Sender: TObject);
    procedure PaintBoxMouseLeave(Sender: TObject);
    procedure PaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    function ParentSurfaceColor: TAlphaColor;
    function Percent: Single;
    function Pixels(const AValue: Integer): Integer;
    procedure SetMaximum(const AValue: Integer);
    procedure SetMinimum(const AValue: Integer);
    procedure SetShowValue(const AValue: Boolean);
    procedure SetValue(const AValue: Integer);
    procedure SetValueFromX(const AX: Integer);
    procedure SetThemeMode(const AValue: TDACThemeMode);
    procedure ThemeChanged(Sender: TObject);
    procedure UpdatePaintBoxBounds;
    procedure WMEraseBkgnd(var AMessage: TWMEraseBkgnd); message WM_ERASEBKGND;
  protected
    procedure CreateWnd; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure Loaded; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Resize; override;
    procedure SetBindingCanModify(const AValue: Boolean);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ResolvedTrackColor: TAlphaColor;
    procedure Redraw;
  published
    property Align;
    property Anchors;
    property Constraints;
    property Enabled;
    property Font;
    property Maximum: Integer read FMaximum write SetMaximum default 100;
    property Minimum: Integer read FMinimum write SetMinimum default 0;
    property ParentFont;
    property ParentShowHint;
    property Position: Integer read FValue write SetValue default 0;
    property PopupMenu;
    property ShowHint;
    property ShowValue: Boolean read FShowValue write SetShowValue default True;
    property TabOrder;
    property TabStop default True;
    property ThemeMode: TDACThemeMode read FThemeMode write SetThemeMode default dtmInherit;
    property Value: Integer read FValue write SetValue default 0;
    property Visible;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
  end;

implementation

uses
  DAC.Components.DesignSystem.ColorTokens,
  DAC.Components.DesignSystem.ControlTokens,
  DAC.Components.DesignSystem.ComponentStyle,
  System.Math,
  System.SysUtils,
  Winapi.Windows;

constructor TDACSlider.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque, csClickEvents, csCaptureMouse];
  Width := Round(TDACComponentStyle.Resolve(dtmInherit).Tokens.Controls.SliderDefaultWidth);
  Height := Round(TDACComponentStyle.Resolve(dtmInherit).Tokens.Controls.SliderDefaultHeight);
  TabStop := True;
  ParentColor := False;
  StyleElements := [];
  Cursor := crHandPoint;
  FMinimum := 0;
  FMaximum := 100;
  FValue := 0;
  FBindingCanModify := True;
  FShowValue := True;
  FThemeMode := dtmInherit;
  FRenderer := TDACSkiaRenderer.Create;

  FPaintBox := TSkPaintBox.Create(Self);
  FPaintBox.Parent := Self;
  FPaintBox.SetSubComponent(True);
  FPaintBox.StyleElements := [];
  FPaintBox.OnDraw := PaintBoxDraw;
  FPaintBox.OnMouseDown := PaintBoxMouseDown;
  FPaintBox.OnMouseEnter := PaintBoxMouseEnter;
  FPaintBox.OnMouseLeave := PaintBoxMouseLeave;
  FPaintBox.OnMouseMove := PaintBoxMouseMove;
  FPaintBox.OnMouseUp := PaintBoxMouseUp;
  FTextOverlay := TDACSystemTextOverlay.Create(Self);
  FTextOverlay.Parent := Self;
  FTextOverlay.SetSubComponent(True);
  FTextOverlay.Align := alClient;
  TDACThemeManager.RegisterListener(Self, ThemeChanged);

  UpdatePaintBoxBounds;
end;

destructor TDACSlider.Destroy;
begin
  TDACThemeManager.UnregisterListener(Self);
  FTextOverlay.Free;
  FPaintBox.Free;
  FRenderer.Free;
  inherited;
end;

procedure TDACSlider.CMEnabledChanged(var AMessage: TMessage);
begin
  inherited;
  Cursor := crHandPoint;
  if not Enabled or not FBindingCanModify then
    Cursor := crDefault;
  InvalidateSlider;
end;

procedure TDACSlider.CreateWnd;
begin
  inherited;
  UpdatePaintBoxBounds;
  InvalidateSlider;
end;

procedure TDACSlider.DrawCircle(const ACanvas: ISkCanvas;
  const ACenter: TPointF; const ARadius: Single; const AColor: TAlphaColor;
  const AStroke: Boolean; const AStrokeWidth: Single; const AAlpha: Byte);
var
  LPaint: ISkPaint;
begin
  if AStroke then
    LPaint := TSkPaint.Create(TSkPaintStyle.Stroke)
  else
    LPaint := TSkPaint.Create(TSkPaintStyle.Fill);
  LPaint.AntiAlias := True;
  LPaint.Color := AColor;
  LPaint.Alpha := AAlpha;
  LPaint.StrokeWidth := AStrokeWidth;
  ACanvas.DrawCircle(ACenter.X, ACenter.Y, ARadius, LPaint);
end;

procedure TDACSlider.InvalidateSlider;
begin
  UpdatePaintBoxBounds;
  if (FPaintBox = nil) or (csDestroying in ComponentState) then
    Exit;

  if csDesigning in ComponentState then
  begin
    if Parent <> nil then
      FPaintBox.Redraw;
    Invalidate;
    Exit;
  end;

  if (Parent <> nil) and HandleAllocated and Parent.HandleAllocated then
    FPaintBox.Redraw;
end;

procedure TDACSlider.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited;
  if not Enabled or not FBindingCanModify then
    Exit;
  case Key of
    VK_LEFT, VK_DOWN:
      begin
        Value := Value - 1;
        Key := 0;
      end;
    VK_RIGHT, VK_UP:
      begin
        Value := Value + 1;
        Key := 0;
      end;
  end;
end;

procedure TDACSlider.Loaded;
begin
  inherited;
  UpdatePaintBoxBounds;
  InvalidateSlider;
end;

procedure TDACSlider.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  if (Button = mbLeft) and Enabled and FBindingCanModify then
  begin
    FDragging := True;
    if CanFocus then
      SetFocus;
    SetValueFromX(X);
  end;
end;

procedure TDACSlider.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if FDragging and Enabled and FBindingCanModify then
    SetValueFromX(X);
end;

procedure TDACSlider.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  if Button = mbLeft then
  begin
    FDragging := False;
    InvalidateSlider;
  end;
end;

procedure TDACSlider.PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
  const ADest: TRectF; const AOpacity: Single);
var
  LActiveRect: TRectF;
  LCenterY: Single;
  LKnobCenter: TPointF;
  LPercent: Single;
  LSurface: TAlphaColor;
  LTrackRect: TRectF;
  LValueText: string;
  LTokens: TDACControlTokens;
begin
  if (ACanvas = nil) or (ADest.Width <= 0) or (ADest.Height <= 0) then
    Exit;

  FRenderer.BeginNativeText(FTextOverlay);
  try

  LSurface := ParentSurfaceColor;
  LTokens := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls;
  ACanvas.Clear(LSurface);

  LCenterY := ADest.Height / 2;
  LTrackRect := TRectF.Create(Pixels(Round(LTokens.SliderTrackLeft)), LCenterY - Pixels(Round(LTokens.SliderTrackThickness)),
    ADest.Width - Pixels(Round(LTokens.SliderTrackRightWithValue)), LCenterY + Pixels(Round(LTokens.SliderTrackThickness)));
  if not FShowValue then
    LTrackRect.Right := ADest.Width - Pixels(Round(LTokens.SliderTrackRightWithoutValue));

  FRenderer.FillRoundRect(ACanvas, LTrackRect,
    LTokens.SliderTrack, Pixels(Round(LTokens.SliderTrackThickness)),
    IfThen(Enabled, LTokens.SliderTrackAlpha, LTokens.SliderDisabledTrackAlpha));
  LPercent := Percent;
  LActiveRect := LTrackRect;
  LActiveRect.Right := LTrackRect.Left + (LTrackRect.Width * LPercent);
  FRenderer.FillRoundRect(ACanvas, LActiveRect, LTokens.Success,
    Pixels(Round(LTokens.SliderTrackThickness)), IfThen(Enabled,
      LTokens.AlphaOpaque, LTokens.SliderDisabledAlpha));

  LKnobCenter := TPointF.Create(LActiveRect.Right, LCenterY);
  DrawCircle(ACanvas, LKnobCenter, Pixels(Round(LTokens.SliderKnobRadius)),
    LTokens.SelectorKnob, False, LTokens.SelectorStrokeWidth,
    LTokens.AlphaOpaque);
  DrawCircle(ACanvas, LKnobCenter, Pixels(Round(LTokens.SliderKnobRadius)), LTokens.Success,
    True, LTokens.SelectorCheckedBorderWidth, IfThen(FMouseInside or FDragging,
      LTokens.AlphaOpaque, LTokens.SliderHoverAlpha));

  if FShowValue then
  begin
    LValueText := IntToStr(FValue) + '%';
    FRenderer.Text(ACanvas, LValueText,
      TDACComponentStyle.FontFamily, ADest.Width - Pixels(Round(LTokens.SliderValueRight)),
      LCenterY + Pixels(Round(LTokens.SliderValueBaselineOffset)), LTokens.SliderValueTextSize,
      LTokens.SliderText, False, Pixels(Round(LTokens.SliderValueWidth)));
  end;
  finally
    FRenderer.EndNativeText;
  end;
end;

procedure TDACSlider.PaintBoxMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  MouseDown(Button, Shift, X, Y);
end;

procedure TDACSlider.PaintBoxMouseEnter(Sender: TObject);
begin
  FMouseInside := True;
  InvalidateSlider;
end;

procedure TDACSlider.PaintBoxMouseLeave(Sender: TObject);
begin
  FMouseInside := False;
  if not FDragging then
    InvalidateSlider;
end;

procedure TDACSlider.PaintBoxMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  MouseMove(Shift, X, Y);
end;

procedure TDACSlider.PaintBoxMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  MouseUp(Button, Shift, X, Y);
end;

function TDACSlider.ParentSurfaceColor: TAlphaColor;
begin
  Result := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls.PopupBackground;
end;

function TDACSlider.ResolvedTrackColor: TAlphaColor;
begin
  Result := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls.SliderTrack;
end;

function TDACSlider.Percent: Single;
begin
  if FMaximum <= FMinimum then
    Exit(0);
  Result := (FValue - FMinimum) / (FMaximum - FMinimum);
  Result := EnsureRange(Result, 0, 1);
end;

procedure TDACSlider.Redraw;
begin
  InvalidateSlider;
end;

procedure TDACSlider.Resize;
begin
  inherited;
  UpdatePaintBoxBounds;
  InvalidateSlider;
end;

function TDACSlider.Pixels(const AValue: Integer): Integer;
begin
  Result := AValue;
  if (AValue > 0) and (Result < 1) then
    Result := 1;
end;

procedure TDACSlider.SetMaximum(const AValue: Integer);
begin
  if FMaximum = AValue then
    Exit;
  FMaximum := Max(AValue, FMinimum + 1);
  SetValue(FValue);
  InvalidateSlider;
end;

procedure TDACSlider.SetMinimum(const AValue: Integer);
begin
  if FMinimum = AValue then
    Exit;
  FMinimum := Min(AValue, FMaximum - 1);
  SetValue(FValue);
  InvalidateSlider;
end;

procedure TDACSlider.SetShowValue(const AValue: Boolean);
begin
  if FShowValue = AValue then
    Exit;
  FShowValue := AValue;
  InvalidateSlider;
end;

procedure TDACSlider.SetBindingCanModify(const AValue: Boolean);
begin
  if FBindingCanModify = AValue then
    Exit;
  FBindingCanModify := AValue;
  if not FBindingCanModify then
    FDragging := False;
  Cursor := crHandPoint;
  if not Enabled or not FBindingCanModify then
    Cursor := crDefault;
  InvalidateSlider;
end;

procedure TDACSlider.SetValue(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := EnsureRange(AValue, FMinimum, FMaximum);
  if FValue = LValue then
    Exit;
  FValue := LValue;
  InvalidateSlider;
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TDACSlider.SetValueFromX(const AX: Integer);
var
  LPercent: Single;
  LRightPadding: Integer;
  LTrackLeft: Integer;
  LTrackWidth: Integer;
begin
  LTrackLeft := Pixels(Round(TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls.SliderTrackLeft));
  LRightPadding := Pixels(Round(TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls.SliderTrackRightWithValue));
  if not FShowValue then
    LRightPadding := Pixels(Round(TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls.SliderTrackRightWithoutValue));
  LTrackWidth := Max(1, Width - LTrackLeft - LRightPadding);
  LPercent := EnsureRange((AX - LTrackLeft) / LTrackWidth, 0, 1);
  Value := FMinimum + Round((FMaximum - FMinimum) * LPercent);
end;

procedure TDACSlider.SetThemeMode(const AValue: TDACThemeMode);
begin
  if FThemeMode = AValue then Exit;
  FThemeMode := AValue;
  ThemeChanged(Self);
end;

procedure TDACSlider.ThemeChanged(Sender: TObject);
begin
  InvalidateSlider;
end;

procedure TDACSlider.UpdatePaintBoxBounds;
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

  if (FPaintBox.Left <> 0) or (FPaintBox.Top <> 0) or
    (FPaintBox.Width <> LWidth) or (FPaintBox.Height <> LHeight) then
    FPaintBox.SetBounds(0, 0, LWidth, LHeight);
end;

procedure TDACSlider.WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
begin
  AMessage.Result := 1;
end;

end.
