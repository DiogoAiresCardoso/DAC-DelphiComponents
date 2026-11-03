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
  DAC.Components.Controls.Edit,
  DAC.Components.DesignSystem.Theme,
  DAC.Components.Skia.IconPainter,
  DAC.Components.Skia.Renderer,
  DAC.Components.Controls.FieldSupport;

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
    FReadOnly: Boolean;
    FRequired: Boolean;
    FStatus: TDACEditStatus;
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
    function ResolvedFieldState: TDACResolvedFieldState;
    function Pixels(const AValue: Integer): Integer;
    procedure SetChecked(const AValue: Boolean);
    procedure SetKind(const AValue: TDACSelectorKind);
    procedure SetReadOnly(const AValue: Boolean);
    procedure SetRequired(const AValue: Boolean);
    procedure SetStatus(const AValue: TDACEditStatus);
    procedure SetThemeMode(const AValue: TDACThemeMode);
    procedure ThemeChanged(Sender: TObject);
    procedure Toggle;
    procedure UpdatePaintBoxBounds;
    procedure WMEraseBkgnd(var AMessage: TWMEraseBkgnd); message WM_ERASEBKGND;
  protected
    procedure CreateWnd; override;
    procedure DoEnter; override;
    procedure DoExit; override;
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
    property ReadOnly: Boolean read FReadOnly write SetReadOnly default False;
    property Required: Boolean read FRequired write SetRequired default False;
    property Status: TDACEditStatus read FStatus write SetStatus default mesNormal;
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
  FReadOnly := False;
  FRequired := False;
  FStatus := mesNormal;

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
  FTextOverlay.Enabled := True;
  FTextOverlay.OnMouseDown := PaintBoxMouseDown;
  FTextOverlay.OnMouseEnter := PaintBoxMouseEnter;
  FTextOverlay.OnMouseLeave := PaintBoxMouseLeave;
  FTextOverlay.OnMouseUp := PaintBoxMouseUp;
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
  if not Enabled or FReadOnly or not FBindingCanModify then
    Exit;
  Toggle;
  inherited Click;
end;

procedure TDACSelector.CMEnabledChanged(var AMessage: TMessage);
begin
  inherited;
  Cursor := crHandPoint;
  if not Enabled or FReadOnly or not FBindingCanModify then
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

procedure TDACSelector.DoEnter;
begin
  inherited;
  InvalidateSelector;
end;

procedure TDACSelector.DoExit;
begin
  inherited;
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
  if (Key = VK_SPACE) and Enabled and FBindingCanModify and not FReadOnly then
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
  if (Button = mbLeft) and Enabled then
  begin
    if CanFocus then
      SetFocus;
    FPressed := FBindingCanModify and not FReadOnly;
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
  if Enabled and FBindingCanModify and not FReadOnly and
    PtInRect(Rect(0, 0, Width, Height), LPoint) then
    Click
  else
    InvalidateSelector;
end;

procedure TDACSelector.PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
  const ADest: TRectF; const AOpacity: Single);
const
  CheckFocusOutset = 2;
var
  LBoxPadding: Single;
  LBoxRect: TRectF;
  LBoxSize: Single;
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
  LDrawCaption: string;
  LDrawColor: TAlphaColor;
  LDrawBold: Boolean;
  LFocusRect: TRectF;
  LChrome: TDACFieldChromeResult;
begin
  if (ACanvas = nil) or (ADest.Width <= 0) or (ADest.Height <= 0) then
    Exit;

  FRenderer.BeginNativeText(FTextOverlay);
  try

  LSurface := ParentSurfaceColor;
  LTokens := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls;
  LChrome := TDACFieldChromeResolver.Resolve(ResolvedFieldState, LTokens);
  LScale := LTokens.BorderWidth;
  ACanvas.Clear(LSurface);

  LTextColor := LChrome.TextColor;

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
          IfThen(Enabled, LTokens.AlphaOpaque, LTokens.InputBorderAlphaDisabled));
        FRenderer.StrokeRoundRect(ACanvas, LTrackRect, LChrome.BorderColor,
          LTrackRect.Height / 2, LChrome.BorderWidth, LChrome.BorderAlpha);
        LKnobCenter := TPointF.Create(LTrackRect.Left + Pixels(Round(LTokens.SelectorToggleKnobOffset)),
          LTrackRect.Top + (LTrackRect.Height / 2));
        if FChecked then
          LKnobCenter.X := LTrackRect.Right - Pixels(Round(LTokens.SelectorToggleKnobOffset));
        DrawCircle(ACanvas, LKnobCenter,
          Pixels(Round(LTokens.SelectorToggleKnobRadius)), LTokens.SelectorKnob,
          False, LTokens.SelectorStrokeWidth, LTokens.AlphaOpaque);
        LTextLeft := LTrackRect.Right + Pixels(Round(LTokens.SelectorTextOffset - LTokens.SelectorCheckSize));
        if Focused then
        begin
          LFocusRect := LTrackRect;
          LFocusRect.Inflate(2, 2);
          FRenderer.StrokeRoundRect(ACanvas, LFocusRect, LChrome.BorderColor,
            (LTrackRect.Height / 2) + 2, LChrome.BorderWidth,
            LChrome.BorderAlpha);
        end;
      end;
    mskRadioButton:
      begin
        LKnobCenter := TPointF.Create(Pixels(Round(LTokens.SelectorRadioCenter)), ADest.Height / 2);
        DrawCircle(ACanvas, LKnobCenter, Pixels(Round(LTokens.SelectorRadioRadius)),
          LChrome.BorderColor, True, LChrome.BorderWidth,
          LChrome.BorderAlpha);
        if FChecked then
        begin
          DrawCircle(ACanvas, LKnobCenter, Pixels(Round(LTokens.SelectorRadioDotRadius)),
            LTokens.Success, False, LTokens.SelectorStrokeWidth,
            LTokens.AlphaOpaque);
        end;
        LTextLeft := Pixels(Round(LTokens.SelectorTextOffset));
        if Focused then
        begin
          LFocusRect := TRectF.Create(LKnobCenter.X - Pixels(Round(LTokens.SelectorRadioRadius)) - 2,
            LKnobCenter.Y - Pixels(Round(LTokens.SelectorRadioRadius)) - 2,
            LKnobCenter.X + Pixels(Round(LTokens.SelectorRadioRadius)) + 2,
            LKnobCenter.Y + Pixels(Round(LTokens.SelectorRadioRadius)) + 2);
          FRenderer.StrokeRoundRect(ACanvas, LFocusRect, LChrome.BorderColor,
            (LFocusRect.Width / 2), LChrome.BorderWidth,
            LChrome.BorderAlpha);
        end;
      end;
  else
    begin
      LBoxPadding := CheckFocusOutset +
        Ceil(Max(LTokens.InputBorderWidth, LTokens.InputFocusBorderWidth) / 2);
      LBoxSize := Min(Pixels(Round(LTokens.SelectorCheckSize)),
        Max(0.0, Min(ADest.Width, ADest.Height) - 2 * LBoxPadding));
      LBoxRect := TRectF.Create(LBoxPadding, (ADest.Height - LBoxSize) / 2,
        LBoxPadding + LBoxSize, (ADest.Height + LBoxSize) / 2);
      LFill := LTokens.SelectorControlBackground;
      if FChecked then
        LFill := LTokens.Success;
      FRenderer.FillRoundRect(ACanvas, LBoxRect, LFill,
        Pixels(Round(LTokens.SelectorCheckRadius)),
        IfThen(Enabled, LTokens.AlphaOpaque, LTokens.InputBorderAlphaDisabled));
      FRenderer.StrokeRoundRect(ACanvas, LBoxRect,
        LChrome.BorderColor, Pixels(Round(LTokens.SelectorCheckRadius)),
        LChrome.BorderWidth, LChrome.BorderAlpha);
      if FChecked and (LBoxSize > 2 * Pixels(Round(LTokens.SelectorCheckInset))) then
      begin
        LIconRect := TRectF.Create(LBoxRect.Left + Pixels(Round(LTokens.SelectorCheckInset)), LBoxRect.Top + Pixels(Round(LTokens.SelectorCheckInset)),
          LBoxRect.Right - Pixels(Round(LTokens.SelectorCheckInset)), LBoxRect.Bottom - Pixels(Round(LTokens.SelectorCheckInset)));
        LIconStyle.Color := LTokens.FeedbackText;
        LIconStyle.Alpha := LTokens.AlphaOpaque;
        FIconPainter.Draw(ACanvas, LIconRect, mikCheck, LIconStyle);
      end;
      LTextLeft := Pixels(Round(LTokens.SelectorTextOffset));
      if Focused and (LBoxSize > 0) then
      begin
        LFocusRect := LBoxRect;
        LFocusRect.Inflate(CheckFocusOutset, CheckFocusOutset);
        FRenderer.StrokeRoundRect(ACanvas, LFocusRect, LChrome.BorderColor,
          Pixels(Round(LTokens.SelectorCheckRadius)) + CheckFocusOutset,
          LChrome.BorderWidth, LChrome.BorderAlpha);
      end;
    end;
  end;

  if Caption <> '' then
  begin
    LDrawCaption := Caption;
    LDrawColor := LTextColor;
    LDrawBold := False;
    if FRequired then
    begin
      LDrawCaption := LDrawCaption + ' *';
      LDrawColor := LTokens.FieldRequiredText;
      LDrawBold := True;
    end;
    FRenderer.Text(ACanvas, LDrawCaption,
      TDACComponentStyle.FontFamily, LTextLeft,
      (ADest.Height / 2) + Pixels(Round(LTokens.SelectorTextBaselineOffset)), LTokens.SelectorTextSize, LDrawColor, LDrawBold,
      ADest.Width - LTextLeft);
  end;
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
  Result := TDACComponentColors.ResolveParentSurface(Self);
end;

function TDACSelector.ResolvedFieldState: TDACResolvedFieldState;
begin
  Result := TDACFieldStateResolver.Resolve(Enabled, False,
    FReadOnly or not FBindingCanModify, Focused, FMouseInside, FChecked,
    TDACFieldValidation(Ord(FStatus)));
end;

function TDACSelector.ResolvedTextColor: TAlphaColor;
var
  LTokens: TDACControlTokens;
begin
  LTokens := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls;
  Result := TDACFieldChromeResolver.Resolve(ResolvedFieldState, LTokens).TextColor;
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
  if not Enabled or FReadOnly or not FBindingCanModify then
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

procedure TDACSelector.SetReadOnly(const AValue: Boolean);
begin
  if FReadOnly = AValue then
    Exit;
  FReadOnly := AValue;
  if FReadOnly then
    FPressed := False;
  Cursor := crHandPoint;
  if not Enabled or FReadOnly or not FBindingCanModify then
    Cursor := crDefault;
  InvalidateSelector;
end;

procedure TDACSelector.SetRequired(const AValue: Boolean);
begin
  if FRequired = AValue then
    Exit;
  FRequired := AValue;
  InvalidateSelector;
end;

procedure TDACSelector.SetStatus(const AValue: TDACEditStatus);
begin
  if FStatus = AValue then
    Exit;
  FStatus := AValue;
  InvalidateSelector;
end;

procedure TDACSelector.SetThemeMode(const AValue: TDACThemeMode);
begin
  if FThemeMode <> AValue then
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
