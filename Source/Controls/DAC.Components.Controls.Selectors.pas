unit DAC.Components.Controls.Selectors;

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
  DAC.Components.DesignSystem.Fonts,
  DAC.Components.DesignSystem.IconAssets,
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
    FIconPainter: TDACSkiaIconPainter;
    FKind: TDACSelectorKind;
    FMouseInside: Boolean;
    FOnChange: TNotifyEvent;
    FPaintBox: TSkPaintBox;
    FPressed: Boolean;
    FRenderer: TDACSkiaRenderer;
    procedure CMEnabledChanged(var AMessage: TMessage); message CM_ENABLEDCHANGED;
    procedure CMTextChanged(var AMessage: TMessage); message CM_TEXTCHANGED;
    procedure DrawCircle(const ACanvas: ISkCanvas; const ACenter: TPointF;
      const ARadius: Single; const AColor: TAlphaColor; const AStroke: Boolean;
      const AStrokeWidth: Single = 1; const AAlpha: Byte = 255);
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
    function ScaleFactor: Single;
    function ScaleMetric(const AValue: Integer): Integer;
    procedure SetChecked(const AValue: Boolean);
    procedure SetKind(const AValue: TDACSelectorKind);
    procedure Toggle;
    procedure UpdatePaintBoxBounds;
    procedure WMEraseBkgnd(var AMessage: TWMEraseBkgnd); message WM_ERASEBKGND;
  protected
    procedure ChangeScale(M, D: Integer); override;
    procedure CreateWnd; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure Loaded; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Click; override;
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

  TDACRadioButton = class(TDACSelector)
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Kind default mskRadioButton;
  end;

  TDACToggleSwitch = class(TDACSelector)
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Kind default mskToggleSwitch;
  end;

  TDACSlider = class(TCustomControl)
  private
    FDragging: Boolean;
    FMaximum: Integer;
    FMinimum: Integer;
    FMouseInside: Boolean;
    FOnChange: TNotifyEvent;
    FPaintBox: TSkPaintBox;
    FRenderer: TDACSkiaRenderer;
    FShowValue: Boolean;
    FValue: Integer;
    procedure CMEnabledChanged(var AMessage: TMessage); message CM_ENABLEDCHANGED;
    procedure DrawCircle(const ACanvas: ISkCanvas; const ACenter: TPointF;
      const ARadius: Single; const AColor: TAlphaColor; const AStroke: Boolean;
      const AStrokeWidth: Single = 1; const AAlpha: Byte = 255);
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
    function ScaleFactor: Single;
    function ScaleMetric(const AValue: Integer): Integer;
    procedure SetMaximum(const AValue: Integer);
    procedure SetMinimum(const AValue: Integer);
    procedure SetShowValue(const AValue: Boolean);
    procedure SetValue(const AValue: Integer);
    procedure SetValueFromX(const AX: Integer);
    procedure UpdatePaintBoxBounds;
    procedure WMEraseBkgnd(var AMessage: TWMEraseBkgnd); message WM_ERASEBKGND;
  protected
    procedure ChangeScale(M, D: Integer); override;
    procedure CreateWnd; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure Loaded; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
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
  System.Math,
  System.SysUtils,
  Winapi.Windows;

constructor TDACSelector.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque, csClickEvents, csCaptureMouse];
  Width := 180;
  Height := 28;
  TabStop := True;
  ParentColor := False;
  StyleElements := [];
  Cursor := crHandPoint;
  Caption := 'Opcao';
  FKind := mskCheckBox;

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

  UpdatePaintBoxBounds;
end;

destructor TDACSelector.Destroy;
begin
  FPaintBox.Free;
  FIconPainter.Free;
  FRenderer.Free;
  inherited;
end;

procedure TDACSelector.ChangeScale(M, D: Integer);
begin
  inherited;
  UpdatePaintBoxBounds;
  InvalidateSelector;
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
  if (FPaintBox <> nil) and HandleAllocated then
    FPaintBox.Redraw;
end;

procedure TDACSelector.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited;
  if (Key = VK_SPACE) and Enabled then
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
  if Enabled and PtInRect(Rect(0, 0, Width, Height), LPoint) then
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
begin
  if (ACanvas = nil) or (ADest.Width <= 0) or (ADest.Height <= 0) then
    Exit;

  LScale := ScaleFactor;
  LSurface := ParentSurfaceColor;
  ACanvas.Clear(LSurface);

  LTextColor := TDACComponentColors.ControlTextForSurface(LSurface);
  if not Enabled then
    LTextColor := TDACComponentColors.ControlTextDisabledForSurface(LSurface);

  case FKind of
    mskToggleSwitch:
      begin
        LTrackRect := FRenderer.SnapRect(TRectF.Create(0,
          (ADest.Height - ScaleMetric(24)) / 2, ScaleMetric(44),
          (ADest.Height + ScaleMetric(24)) / 2), LScale);
        LFill := TDACComponentColors.ControlBorderForSurface(LSurface);
        if FChecked then
          LFill := TDACComponentColors.Primary;
        if FMouseInside and Enabled and not FChecked then
          LFill := TDACComponentColors.ControlBorderHoverForSurface(LSurface);
        FRenderer.FillRoundRect(ACanvas, LTrackRect, LFill, LTrackRect.Height / 2,
          IfThen(Enabled, 255, 120));
        LKnobCenter := TPointF.Create(LTrackRect.Left + ScaleMetric(12),
          LTrackRect.Top + (LTrackRect.Height / 2));
        if FChecked then
          LKnobCenter.X := LTrackRect.Right - ScaleMetric(12);
        DrawCircle(ACanvas, LKnobCenter, ScaleMetric(9), TDACComponentColors.White, False);
        LTextLeft := LTrackRect.Right + ScaleMetric(12);
      end;
    mskRadioButton:
      begin
        LKnobCenter := TPointF.Create(ScaleMetric(10), ADest.Height / 2);
        DrawCircle(ACanvas, LKnobCenter, ScaleMetric(8),
          TDACComponentColors.ControlBorderForSurface(LSurface), True, ScaleMetric(1));
        if FMouseInside and Enabled then
          DrawCircle(ACanvas, LKnobCenter, ScaleMetric(8),
            TDACComponentColors.Primary, True, ScaleMetric(1), 180);
        if FChecked then
        begin
          DrawCircle(ACanvas, LKnobCenter, ScaleMetric(8),
            TDACComponentColors.Primary, True, 1.5 * ScaleFactor);
          DrawCircle(ACanvas, LKnobCenter, ScaleMetric(4),
            TDACComponentColors.Primary, False);
        end;
        LTextLeft := ScaleMetric(28);
      end;
  else
    begin
      LBoxRect := FRenderer.SnapRect(TRectF.Create(0,
        (ADest.Height - ScaleMetric(18)) / 2, ScaleMetric(18),
        (ADest.Height + ScaleMetric(18)) / 2), LScale);
      LFill := TDACComponentColors.ControlBackgroundForSurface(LSurface);
      if FChecked then
        LFill := TDACComponentColors.Primary;
      FRenderer.FillRoundRect(ACanvas, LBoxRect, LFill, ScaleMetric(4), IfThen(Enabled, 255, 120));
      FRenderer.StrokeRoundRect(ACanvas, LBoxRect,
        TDACComponentColors.ControlBorderForSurface(LSurface), ScaleMetric(4),
        ScaleMetric(1), IfThen(FMouseInside and Enabled, 255, 180));
      if FChecked then
      begin
        LIconRect := TRectF.Create(LBoxRect.Left + ScaleMetric(2), LBoxRect.Top + ScaleMetric(2),
          LBoxRect.Right - ScaleMetric(2), LBoxRect.Bottom - ScaleMetric(2));
        LIconStyle.Color := TDACComponentColors.White;
        LIconStyle.Alpha := 255;
        FIconPainter.Draw(ACanvas, LIconRect, mikCheck, LIconStyle);
      end;
      LTextLeft := ScaleMetric(28);
    end;
  end;

  if Caption <> '' then
    FRenderer.Text(ACanvas, Caption,
      TDACComponentFontInstaller.FontFamily, LTextLeft,
      (ADest.Height / 2) + ScaleMetric(4), 10.5, LTextColor, False,
      ADest.Width - LTextLeft);
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

procedure TDACSelector.Resize;
begin
  inherited;
  UpdatePaintBoxBounds;
  InvalidateSelector;
end;

function TDACSelector.ScaleFactor: Single;
begin
  Result := 1;
  if FPaintBox <> nil then
    Result := FPaintBox.ScaleFactor;
  if Result <= 0 then
    Result := 1;
end;

function TDACSelector.ScaleMetric(const AValue: Integer): Integer;
begin
  Result := Round(AValue * ScaleFactor);
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

procedure TDACSelector.SetKind(const AValue: TDACSelectorKind);
begin
  if FKind = AValue then
    Exit;
  FKind := AValue;
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
  if FPaintBox = nil then
    Exit;

  LWidth := Width;
  LHeight := Height;
  if HandleAllocated then
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

constructor TDACRadioButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Kind := mskRadioButton;
  Caption := 'RadioButton';
end;

constructor TDACToggleSwitch.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Kind := mskToggleSwitch;
  Caption := 'Toggle Switch';
  Width := 190;
  Height := 30;
end;

constructor TDACSlider.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque, csClickEvents, csCaptureMouse];
  Width := 260;
  Height := 36;
  TabStop := True;
  ParentColor := False;
  StyleElements := [];
  Cursor := crHandPoint;
  FMinimum := 0;
  FMaximum := 100;
  FValue := 0;
  FShowValue := True;
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

  UpdatePaintBoxBounds;
end;

destructor TDACSlider.Destroy;
begin
  FPaintBox.Free;
  FRenderer.Free;
  inherited;
end;

procedure TDACSlider.ChangeScale(M, D: Integer);
begin
  inherited;
  UpdatePaintBoxBounds;
  InvalidateSlider;
end;

procedure TDACSlider.CMEnabledChanged(var AMessage: TMessage);
begin
  inherited;
  Cursor := crHandPoint;
  if not Enabled then
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
  if (FPaintBox <> nil) and HandleAllocated then
    FPaintBox.Redraw;
end;

procedure TDACSlider.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited;
  if not Enabled then
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
  if (Button = mbLeft) and Enabled then
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
  if FDragging and Enabled then
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
begin
  if (ACanvas = nil) or (ADest.Width <= 0) or (ADest.Height <= 0) then
    Exit;

  LSurface := ParentSurfaceColor;
  ACanvas.Clear(LSurface);

  LCenterY := ADest.Height / 2;
  LTrackRect := TRectF.Create(ScaleMetric(8), LCenterY - ScaleMetric(3),
    ADest.Width - ScaleMetric(50), LCenterY + ScaleMetric(3));
  if not FShowValue then
    LTrackRect.Right := ADest.Width - ScaleMetric(12);

  FRenderer.FillRoundRect(ACanvas, LTrackRect,
    TDACComponentColors.ControlBorderForSurface(LSurface), ScaleMetric(3),
    IfThen(Enabled, 150, 80));
  LPercent := Percent;
  LActiveRect := LTrackRect;
  LActiveRect.Right := LTrackRect.Left + (LTrackRect.Width * LPercent);
  FRenderer.FillRoundRect(ACanvas, LActiveRect, TDACComponentColors.Primary,
    ScaleMetric(3), IfThen(Enabled, 255, 120));

  LKnobCenter := TPointF.Create(LActiveRect.Right, LCenterY);
  DrawCircle(ACanvas, LKnobCenter, ScaleMetric(8), TDACComponentColors.White, False);
  DrawCircle(ACanvas, LKnobCenter, ScaleMetric(8), TDACComponentColors.Primary,
    True, 1.5 * ScaleFactor, IfThen(FMouseInside or FDragging, 255, 220));

  if FShowValue then
  begin
    LValueText := IntToStr(FValue) + '%';
    FRenderer.Text(ACanvas, LValueText,
      TDACComponentFontInstaller.FontFamily, ADest.Width - ScaleMetric(40),
      LCenterY + ScaleMetric(4), 10,
      TDACComponentColors.ControlTextForSurface(LSurface), False,
      ScaleMetric(38));
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
  Result := TDACComponentColors.ResolveParentSurface(Self);
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

function TDACSlider.ScaleFactor: Single;
begin
  Result := 1;
  if FPaintBox <> nil then
    Result := FPaintBox.ScaleFactor;
  if Result <= 0 then
    Result := 1;
end;

function TDACSlider.ScaleMetric(const AValue: Integer): Integer;
begin
  Result := Round(AValue * ScaleFactor);
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
  LTrackLeft := ScaleMetric(8);
  LRightPadding := ScaleMetric(50);
  if not FShowValue then
    LRightPadding := ScaleMetric(12);
  LTrackWidth := Max(1, Width - LTrackLeft - LRightPadding);
  LPercent := EnsureRange((AX - LTrackLeft) / LTrackWidth, 0, 1);
  Value := FMinimum + Round((FMaximum - FMinimum) * LPercent);
end;

procedure TDACSlider.UpdatePaintBoxBounds;
var
  LHeight: Integer;
  LWidth: Integer;
begin
  if FPaintBox = nil then
    Exit;

  LWidth := Width;
  LHeight := Height;
  if HandleAllocated then
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

