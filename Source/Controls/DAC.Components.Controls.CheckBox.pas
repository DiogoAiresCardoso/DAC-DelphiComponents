unit DAC.Components.Controls.CheckBox;

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
  DAC.Components.Skia.IconPainter,
  DAC.Components.Skia.Renderer;

type
  TDACSelectorKind = (
    mskCheckBox,
    mskRadioButton,
    mskToggleSwitch
  );

  TDACSelector = class(TCustomControl)
  private
    FChecked: Boolean;
    FBindingCanModify: Boolean;
    FIconPainter: TDACSkiaIconPainter;
    FKind: TDACSelectorKind;
    FMouseInside: Boolean;
    FOnChange: TNotifyEvent;
    FPaintBox: TSkPaintBox;
    FPressed: Boolean;
    FRenderer: TDACSkiaRenderer;
    FTextOverlay: TDACSystemTextOverlay;
    FThemeMode: TDACThemeMode;
    procedure CMEnabledChanged(var AMessage: TMessage); message CM_ENABLEDCHANGED;
    procedure CMTextChanged(var AMessage: TMessage); message CM_TEXTCHANGED;
    procedure DrawCircle(const ACanvas: ISkCanvas; const ACenter: TPointF;
      const ARadius: Single; const AColor: TAlphaColor; const AStroke: Boolean;
      const AStrokeWidth: Single; const AAlpha: Byte);
    procedure InvalidateSelector;
    procedure PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    procedure PaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxMouseEnter(Sender: TObject);
    procedure PaintBoxMouseLeave(Sender: TObject);
    procedure PaintBoxMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    function ParentSurfaceColor: TAlphaColor;
    function Pixels(const AValue: Integer): Integer;
    procedure SetChecked(const AValue: Boolean);
    procedure SetKind(const AValue: TDACSelectorKind);
    procedure SetThemeMode(const AValue: TDACThemeMode);
    procedure ThemeChanged(Sender: TObject);
    procedure Toggle;
    procedure UpdatePaintBoxBounds;
    procedure WMEraseBkgnd(var AMessage: TWMEraseBkgnd); message WM_ERASEBKGND;
  protected
    procedure CreateWnd; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure Loaded; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Resize; override;
    procedure SetBindingCanModify(const AValue: Boolean);
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Click; override;
    function ResolvedTextColor: TAlphaColor;
    property Kind: TDACSelectorKind read FKind write SetKind default mskCheckBox;
  published
    property Align;
    property Anchors;
    property Caption;
    property Checked: Boolean read FChecked write SetChecked default False;
    property Constraints;
    property Enabled;
    property Font;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop default True;
    property ThemeMode: TDACThemeMode read FThemeMode write SetThemeMode default dtmInherit;
    property Visible;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnClick;
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

  TDACCheckBox = class(TDACSelector)
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Kind default mskCheckBox;
  end;

implementation

uses
  DAC.Components.DesignSystem.ColorTokens,
  DAC.Components.DesignSystem.ControlTokens,
  DAC.Components.DesignSystem.ComponentStyle,
  DAC.Components.DesignSystem.IconAssets,
  System.Math,
  System.SysUtils,
  Winapi.Windows;

constructor TDACSelector.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque, csClickEvents, csCaptureMouse];
  Width := Round(TDACComponentStyle.Resolve(dtmInherit).Tokens.Controls.SelectorDefaultWidth);
  Height := Round(TDACComponentStyle.Resolve(dtmInherit).Tokens.Controls.SelectorDefaultHeight);
  TabStop := True;
  ParentColor := False;
  StyleElements := [];
  Cursor := crHandPoint;
  Caption := 'Opcao';
  FBindingCanModify := True;
  FKind := mskCheckBox;
  FThemeMode := dtmInherit;

  FRenderer := TDACSkiaRenderer.Create;
  FIconPainter := TDACSkiaIconPainter.Create(FRenderer);

  FPaintBox := TSkPaintBox.Create(Self);
  FPaintBox.Parent := Self;
  FPaintBox.SetSubComponent(True);
  FPaintBox.StyleElements := [];
  FPaintBox.OnDraw := PaintBoxDraw;
  FPaintBox.OnMouseDown := PaintBoxMouseDown;
  FPaintBox.OnMouseEnter := PaintBoxMouseEnter;
  FPaintBox.OnMouseLeave := PaintBoxMouseLeave;
  FPaintBox.OnMouseUp := PaintBoxMouseUp;
  FTextOverlay := TDACSystemTextOverlay.Create(Self);
  FTextOverlay.Parent := Self;
  FTextOverlay.SetSubComponent(True);
  FTextOverlay.Align := alClient;
  TDACThemeManager.RegisterListener(Self, ThemeChanged);

  UpdatePaintBoxBounds;
end;

destructor TDACSelector.Destroy;
begin
  TDACThemeManager.UnregisterListener(Self);
  FTextOverlay.Free;
  FPaintBox.Free;
  FIconPainter.Free;
  FRenderer.Free;
  inherited;
end;

procedure TDACSelector.Click;
begin
  Toggle;
  inherited Click;
end;

procedure TDACSelector.CMEnabledChanged(var AMessage: TMessage);
begin
  inherited;
  Cursor := crHandPoint;
  if not Enabled then
    Cursor := crDefault;
  InvalidateSelector;
end;

procedure TDACSelector.CMTextChanged(var AMessage: TMessage);
begin
  inherited;
  InvalidateSelector;
end;

procedure TDACSelector.CreateWnd;
begin
  inherited;
  UpdatePaintBoxBounds;
  InvalidateSelector;
end;

procedure TDACSelector.DrawCircle(const ACanvas: ISkCanvas;
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

procedure TDACSelector.InvalidateSelector;
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

procedure TDACSelector.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited;
  if (Key = VK_SPACE) and Enabled and FBindingCanModify then
  begin
    Toggle;
    Key := 0;
  end;
end;

procedure TDACSelector.Loaded;
begin
  inherited;
  UpdatePaintBoxBounds;
  InvalidateSelector;
end;

procedure TDACSelector.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  if (Button = mbLeft) and Enabled and FBindingCanModify then
  begin
    FPressed := True;
    if CanFocus then
      SetFocus;
    InvalidateSelector;
  end;
end;

procedure TDACSelector.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  LPoint: TPoint;
begin
  inherited;
  if Button <> mbLeft then
    Exit;
  FPressed := False;
  LPoint := Point(X, Y);
  if Enabled and FBindingCanModify and
    PtInRect(Rect(0, 0, Width, Height), LPoint) then
    Click
  else
    InvalidateSelector;
end;

procedure TDACSelector.PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
  const ADest: TRectF; const AOpacity: Single);
var
  LBoxRect: TRectF;
  LFill: TAlphaColor;
  LIconRect: TRectF;
  LIconStyle: TDACIconStyle;
  LKnobCenter: TPointF;
  LScale: Single;
  LSurface: TAlphaColor;
  LTextColor: TAlphaColor;
  LTextLeft: Single;
  LTrackRect: TRectF;
  LTokens: TDACControlTokens;
begin
  if (ACanvas = nil) or (ADest.Width <= 0) or (ADest.Height <= 0) then
    Exit;

  FRenderer.BeginNativeText(FTextOverlay);
  try

  LSurface := ParentSurfaceColor;
  LTokens := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls;
  LScale := LTokens.BorderWidth;
  ACanvas.Clear(LSurface);

  LTextColor := LTokens.SelectorText;
  if not Enabled then
    LTextColor := LTokens.SelectorDisabledText;

  case FKind of
    mskToggleSwitch:
      begin
        LTrackRect := FRenderer.SnapRect(TRectF.Create(0,
          (ADest.Height - Pixels(Round(LTokens.SelectorToggleHeight))) / 2,
          Pixels(Round(LTokens.SelectorToggleWidth)),
          (ADest.Height + Pixels(Round(LTokens.SelectorToggleHeight))) / 2), LScale);
        LFill := LTokens.SelectorTrack;
        if FChecked then
          LFill := LTokens.Success;
        if FMouseInside and Enabled and not FChecked then
          LFill := LTokens.SelectorTrackHover;
        FRenderer.FillRoundRect(ACanvas, LTrackRect, LFill, LTrackRect.Height / 2,
          IfThen(Enabled, LTokens.AlphaOpaque, LTokens.SelectorDisabledAlpha));
        LKnobCenter := TPointF.Create(LTrackRect.Left + Pixels(Round(LTokens.SelectorToggleKnobOffset)),
          LTrackRect.Top + (LTrackRect.Height / 2));
        if FChecked then
          LKnobCenter.X := LTrackRect.Right - Pixels(Round(LTokens.SelectorToggleKnobOffset));
        DrawCircle(ACanvas, LKnobCenter,
          Pixels(Round(LTokens.SelectorToggleKnobRadius)), LTokens.SelectorKnob,
          False, LTokens.SelectorStrokeWidth, LTokens.AlphaOpaque);
        LTextLeft := LTrackRect.Right + Pixels(Round(LTokens.SelectorTextOffset - LTokens.SelectorCheckSize));
      end;
    mskRadioButton:
      begin
        LKnobCenter := TPointF.Create(Pixels(Round(LTokens.SelectorRadioCenter)), ADest.Height / 2);
        DrawCircle(ACanvas, LKnobCenter, Pixels(Round(LTokens.SelectorRadioRadius)),
          LTokens.SelectorBorder, True, Pixels(Round(LTokens.SelectorStrokeWidth)),
          LTokens.AlphaOpaque);
        if FMouseInside and Enabled then
          DrawCircle(ACanvas, LKnobCenter, Pixels(Round(LTokens.SelectorRadioRadius)),
            LTokens.Success, True, Pixels(Round(LTokens.SelectorStrokeWidth)), LTokens.SelectorHoverAlpha);
        if FChecked then
        begin
          DrawCircle(ACanvas, LKnobCenter, Pixels(Round(LTokens.SelectorRadioRadius)),
            LTokens.Success, True, LTokens.SelectorCheckedBorderWidth,
            LTokens.AlphaOpaque);
          DrawCircle(ACanvas, LKnobCenter, Pixels(Round(LTokens.SelectorRadioDotRadius)),
            LTokens.Success, False, LTokens.SelectorStrokeWidth,
            LTokens.AlphaOpaque);
        end;
        LTextLeft := Pixels(Round(LTokens.SelectorTextOffset));
      end;
  else
    begin
      LBoxRect := FRenderer.SnapRect(TRectF.Create(0,
        (ADest.Height - Pixels(Round(LTokens.SelectorCheckSize))) / 2,
        Pixels(Round(LTokens.SelectorCheckSize)),
        (ADest.Height + Pixels(Round(LTokens.SelectorCheckSize))) / 2), LScale);
      LFill := LTokens.SelectorControlBackground;
      if FChecked then
        LFill := LTokens.Success;
      FRenderer.FillRoundRect(ACanvas, LBoxRect, LFill,
        Pixels(Round(LTokens.SelectorCheckRadius)),
        IfThen(Enabled, LTokens.AlphaOpaque, LTokens.SelectorDisabledAlpha));
      FRenderer.StrokeRoundRect(ACanvas, LBoxRect,
        LTokens.SelectorBorder, Pixels(Round(LTokens.SelectorCheckRadius)),
        Pixels(Round(LTokens.SelectorStrokeWidth)), IfThen(FMouseInside and Enabled,
          LTokens.AlphaOpaque, LTokens.SelectorHoverAlpha));
      if FChecked then
      begin
        LIconRect := TRectF.Create(LBoxRect.Left + Pixels(Round(LTokens.SelectorCheckInset)), LBoxRect.Top + Pixels(Round(LTokens.SelectorCheckInset)),
          LBoxRect.Right - Pixels(Round(LTokens.SelectorCheckInset)), LBoxRect.Bottom - Pixels(Round(LTokens.SelectorCheckInset)));
        LIconStyle.Color := LTokens.FeedbackText;
        LIconStyle.Alpha := LTokens.AlphaOpaque;
        FIconPainter.Draw(ACanvas, LIconRect, mikCheck, LIconStyle);
      end;
      LTextLeft := Pixels(Round(LTokens.SelectorTextOffset));
    end;
  end;

  if Caption <> '' then
    FRenderer.Text(ACanvas, Caption,
      TDACComponentStyle.FontFamily, LTextLeft,
      (ADest.Height / 2) + Pixels(Round(LTokens.SelectorTextBaselineOffset)), LTokens.SelectorTextSize, LTextColor, False,
      ADest.Width - LTextLeft);
  finally
    FRenderer.EndNativeText;
  end;
end;

procedure TDACSelector.PaintBoxMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  MouseDown(Button, Shift, X, Y);
end;

procedure TDACSelector.PaintBoxMouseEnter(Sender: TObject);
begin
  FMouseInside := True;
  InvalidateSelector;
end;

procedure TDACSelector.PaintBoxMouseLeave(Sender: TObject);
begin
  FMouseInside := False;
  FPressed := False;
  InvalidateSelector;
end;

procedure TDACSelector.PaintBoxMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  MouseUp(Button, Shift, X, Y);
end;

function TDACSelector.ParentSurfaceColor: TAlphaColor;
begin
  Result := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls.PopupBackground;
end;

function TDACSelector.ResolvedTextColor: TAlphaColor;
begin
  Result := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls.SelectorText;
end;

procedure TDACSelector.Resize;
begin
  inherited;
  UpdatePaintBoxBounds;
  InvalidateSelector;
end;

function TDACSelector.Pixels(const AValue: Integer): Integer;
begin
  Result := AValue;
  if (AValue > 0) and (Result < 1) then
    Result := 1;
end;

procedure TDACSelector.SetChecked(const AValue: Boolean);
begin
  if FChecked = AValue then
    Exit;
  FChecked := AValue;
  InvalidateSelector;
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TDACSelector.SetBindingCanModify(const AValue: Boolean);
begin
  if FBindingCanModify = AValue then
    Exit;
  FBindingCanModify := AValue;
  if not FBindingCanModify then
    FPressed := False;
  Cursor := crHandPoint;
  if not Enabled or not FBindingCanModify then
    Cursor := crDefault;
  InvalidateSelector;
end;

procedure TDACSelector.SetKind(const AValue: TDACSelectorKind);
begin
  if FKind = AValue then
    Exit;
  FKind := AValue;
  InvalidateSelector;
end;

procedure TDACSelector.SetThemeMode(const AValue: TDACThemeMode);
begin
  if FThemeMode = AValue then Exit;
  FThemeMode := AValue;
  ThemeChanged(Self);
end;

procedure TDACSelector.ThemeChanged(Sender: TObject);
begin
  InvalidateSelector;
end;

procedure TDACSelector.Toggle;
begin
  if FKind = mskRadioButton then
    Checked := True
  else
    Checked := not Checked;
end;

procedure TDACSelector.UpdatePaintBoxBounds;
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

procedure TDACSelector.WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
begin
  AMessage.Result := 1;
end;

constructor TDACCheckBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Kind := mskCheckBox;
  Caption := 'CheckBox';
end;

end.
