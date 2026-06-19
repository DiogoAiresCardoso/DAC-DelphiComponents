unit MaxxRural.Components.Controls.Button;

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
  MaxxRural.Components.Controls.SystemText,
  MaxxRural.Components.DesignSystem.Fonts,
  MaxxRural.Components.DesignSystem.IconAssets,
  MaxxRural.Components.Skia.BackgroundPainter,
  MaxxRural.Components.Skia.BorderPainter,
  MaxxRural.Components.Skia.IconPainter,
  MaxxRural.Components.Skia.Renderer;

type
  TMaxxRuralButtonKind = (
    mbkPrimary,
    mbkSecondary,
    mbkGhost,
    mbkWarning,
    mbkDanger,
    mbkTransparent,
    mbkInputAction
  );

  TMaxxRuralButtonSize = (
    mbsSmall,
    mbsMedium,
    mbsLarge
  );

  TMaxxRuralButtonIconPosition = (
    mipLeft,
    mipRight
  );

  TMaxxRuralButton = class(TCustomControl)
  private
    FBackgroundPainter: TMaxxRuralSkiaBackgroundPainter;
    FBorderPainter: TMaxxRuralSkiaBorderPainter;
    FCornerRadius: Integer;
    FIconKind: TMaxxRuralIconKind;
    FIconPainter: TMaxxRuralSkiaIconPainter;
    FIconPosition: TMaxxRuralButtonIconPosition;
    FIconSize: Integer;
    FKind: TMaxxRuralButtonKind;
    FLoading: Boolean;
    FMouseInside: Boolean;
    FPaintBox: TSkPaintBox;
    FPressed: Boolean;
    FRenderer: TMaxxRuralSkiaRenderer;
    FShowIcon: Boolean;
    FSize: TMaxxRuralButtonSize;
    FTextLabel: TMaxxRuralSystemText;
    function ButtonFontSize: Single;
    procedure CalculateContentLayout(const ADest: TRectF;
      out AIconRect, ATextRect: TRectF);
    procedure CMEnabledChanged(var AMessage: TMessage); message CM_ENABLEDCHANGED;
    procedure CMFocusChanged(var AMessage: TMessage); message CM_FOCUSCHANGED;
    procedure CMTextChanged(var AMessage: TMessage); message CM_TEXTCHANGED;
    function ContentPadding: Integer;
    function CursorInside: Boolean;
    function EffectiveIconSize: Integer;
    procedure InvalidateButton;
    procedure LabelMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure LabelMouseEnter(Sender: TObject);
    procedure LabelMouseLeave(Sender: TObject);
    procedure LabelMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure LabelMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
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
    function ScaleFactor: Single;
    function ScaleMetric(const AValue: Integer): Integer;
    procedure SetCornerRadius(const AValue: Integer);
    procedure SetIconKind(const AValue: TMaxxRuralIconKind);
    procedure SetIconPosition(const AValue: TMaxxRuralButtonIconPosition);
    procedure SetIconSize(const AValue: Integer);
    procedure SetKind(const AValue: TMaxxRuralButtonKind);
    procedure SetLoading(const AValue: Boolean);
    procedure SetShowIcon(const AValue: Boolean);
    procedure SetSize(const AValue: TMaxxRuralButtonSize);
    procedure UpdateCursor;
    procedure UpdateLabel;
    procedure UpdatePaintBoxBounds;
    procedure UpdateZOrder;
    procedure WMEraseBkgnd(var AMessage: TWMEraseBkgnd); message WM_ERASEBKGND;
  protected
    procedure ChangeScale(M, D: Integer); override;
    procedure CreateWnd; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure KeyUp(var Key: Word; Shift: TShiftState); override;
    procedure Loaded; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Click; override;
    procedure Redraw;
  published
    property Align;
    property Anchors;
    property Caption;
    property Constraints;
    property CornerRadius: Integer read FCornerRadius write SetCornerRadius default 8;
    property Enabled;
    property Font;
    property Hint;
    property IconKind: TMaxxRuralIconKind read FIconKind write SetIconKind default mikCheck;
    property IconPosition: TMaxxRuralButtonIconPosition read FIconPosition write SetIconPosition default mipLeft;
    property IconSize: Integer read FIconSize write SetIconSize default 0;
    property Kind: TMaxxRuralButtonKind read FKind write SetKind default mbkPrimary;
    property Loading: Boolean read FLoading write SetLoading default False;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property ShowIcon: Boolean read FShowIcon write SetShowIcon default False;
    property Size: TMaxxRuralButtonSize read FSize write SetSize default mbsMedium;
    property TabOrder;
    property TabStop default True;
    property Visible;
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

implementation

uses
  MaxxRural.Components.DesignSystem.ColorTokens,
  System.Math,
  System.SysUtils,
  Winapi.Windows;

type
  TButtonPalette = record
    Background: TAlphaColor;
    Border: TAlphaColor;
    BorderAlpha: Byte;
    Text: TAlphaColor;
    Icon: TAlphaColor;
    Alpha: Byte;
  end;

function ButtonPalette(const AKind: TMaxxRuralButtonKind;
  const AEnabled, AHot, APressed, AFocused: Boolean): TButtonPalette;
var
  LActive: Boolean;
begin
  Result.Alpha := 255;
  Result.BorderAlpha := 0;
  LActive := AHot or AFocused;
  case AKind of
    mbkSecondary:
      begin
        Result.Background := TMaxxRuralComponentColors.White;
        Result.Border := TMaxxRuralComponentColors.ControlBorder;
        Result.BorderAlpha := 255;
        Result.Text := TMaxxRuralComponentColors.ControlText;
      end;
    mbkInputAction:
      begin
        Result.Background := TMaxxRuralComponentColors.Transparent;
        Result.Border := TMaxxRuralComponentColors.Transparent;
        Result.BorderAlpha := 0;
        Result.Text := TMaxxRuralComponentColors.PrimaryDark;
      end;
    mbkTransparent:
      begin
        Result.Background := TMaxxRuralComponentColors.Transparent;
        Result.Border := TMaxxRuralComponentColors.Transparent;
        Result.BorderAlpha := 0;
        Result.Text := TMaxxRuralComponentColors.PrimaryDark;
      end;
    mbkGhost:
      begin
        Result.Background := TMaxxRuralComponentColors.Transparent;
        Result.Border := TMaxxRuralComponentColors.PrimaryDark;
        Result.BorderAlpha := 140;
        Result.Text := TMaxxRuralComponentColors.PrimaryDark;
      end;
    mbkDanger:
      begin
        Result.Background := TMaxxRuralComponentColors.Danger;
        Result.Border := TMaxxRuralComponentColors.Transparent;
        Result.Text := TMaxxRuralComponentColors.White;
      end;
    mbkWarning:
      begin
        Result.Background := TMaxxRuralComponentColors.Warning;
        Result.Border := TMaxxRuralComponentColors.Transparent;
        Result.Text := TMaxxRuralComponentColors.ControlText;
      end;
  else
    begin
      Result.Background := TMaxxRuralComponentColors.Primary;
      Result.Border := TMaxxRuralComponentColors.Transparent;
      Result.Text := TMaxxRuralComponentColors.White;
    end;
  end;

  if LActive then
  begin
    case AKind of
      mbkPrimary:
        begin
          Result.Background := TMaxxRuralComponentColors.PrimaryFocus;
          if AHot then
            Result.Background := TMaxxRuralComponentColors.PrimaryLight;
        end;
      mbkSecondary:
        begin
          Result.Background := TMaxxRuralComponentColors.ControlBackgroundDisabled;
          Result.Border := TMaxxRuralComponentColors.ControlBorderHover;
        end;
      mbkInputAction:
        begin
          Result.Background := TMaxxRuralComponentColors.Transparent;
          Result.Border := TMaxxRuralComponentColors.Transparent;
          Result.BorderAlpha := 0;
        end;
      mbkTransparent:
        begin
          Result.Background := TMaxxRuralComponentColors.Transparent;
          Result.Border := TMaxxRuralComponentColors.Transparent;
          Result.BorderAlpha := 0;
          Result.Text := TMaxxRuralComponentColors.Primary;
        end;
      mbkGhost:
        begin
          Result.Background := TMaxxRuralComponentColors.Alpha(31, 59, 35, $14);
          Result.Border := TMaxxRuralComponentColors.PrimaryLight;
          Result.BorderAlpha := 190;
        end;
      mbkDanger:
        Result.Background := TMaxxRuralComponentColors.DangerLight;
      mbkWarning:
        Result.Background := TMaxxRuralComponentColors.WarningLight;
    end;
  end;

  if APressed then
  begin
    case AKind of
      mbkPrimary:
        Result.Background := TMaxxRuralComponentColors.PrimaryDark;
      mbkSecondary:
        begin
          Result.Background := TMaxxRuralComponentColors.ControlBorder;
          Result.Border := TMaxxRuralComponentColors.ControlBorderHover;
        end;
      mbkInputAction:
        begin
          Result.Background := TMaxxRuralComponentColors.Transparent;
          Result.Border := TMaxxRuralComponentColors.Transparent;
          Result.BorderAlpha := 0;
        end;
      mbkTransparent:
        begin
          Result.Background := TMaxxRuralComponentColors.Transparent;
          Result.Border := TMaxxRuralComponentColors.Transparent;
          Result.BorderAlpha := 0;
          Result.Text := TMaxxRuralComponentColors.PrimaryDark;
        end;
      mbkGhost:
        begin
          Result.Background := TMaxxRuralComponentColors.Alpha(47, 158, 34, $1F);
          Result.Border := TMaxxRuralComponentColors.Alpha(61, 184, 42, $66);
          Result.BorderAlpha := 255;
        end;
      mbkDanger:
        Result.Background := TMaxxRuralComponentColors.DangerDark;
      mbkWarning:
        Result.Background := TMaxxRuralComponentColors.WarningDark;
    end;
  end;

  if not AEnabled then
  begin
    Result.Alpha := 110;
    if Result.BorderAlpha > 0 then
      Result.BorderAlpha := Result.Alpha;
    Result.Text := TMaxxRuralComponentColors.TextSecondary;
  end;

  Result.Icon := Result.Text;
end;

function TMaxxRuralButton.ButtonFontSize: Single;
begin
  case FSize of
    mbsSmall:
      Result := 7.5;
    mbsLarge:
      Result := 9;
  else
    Result := 8;
  end;
end;

procedure TMaxxRuralButton.CalculateContentLayout(const ADest: TRectF;
  out AIconRect, ATextRect: TRectF);
var
  LAvailableWidth: Single;
  LFontSize: Single;
  LGap: Single;
  LGroupLeft: Single;
  LGroupWidth: Single;
  LHasText: Boolean;
  LIconSize: Single;
  LTextWidth: Single;
begin
  AIconRect := TRectF.Empty;
  ATextRect := TRectF.Empty;

  LFontSize := ButtonFontSize;
  LGap := 8;
  LIconSize := EffectiveIconSize;
  LHasText := Trim(Caption) <> '';

  if FShowIcon and not LHasText then
  begin
    LIconSize := Round(LIconSize);
    AIconRect := TRectF.Create(
      Round((ADest.Width - LIconSize) / 2),
      Round((ADest.Height - LIconSize) / 2),
      Round((ADest.Width + LIconSize) / 2),
      Round((ADest.Height + LIconSize) / 2));
    Exit;
  end;

  if not LHasText then
  begin
    LGap := 0;
    LTextWidth := 0;
  end
  else
    LTextWidth := Ceil(FRenderer.MeasureText(Caption,
      TMaxxRuralComponentFontInstaller.FontFamily, LFontSize, False)) + 2;
  LAvailableWidth := Max(0, ADest.Width - (ContentPadding * 2));

  if FShowIcon then
    LAvailableWidth := Max(0, LAvailableWidth - LIconSize - LGap);
  LTextWidth := Min(LTextWidth, LAvailableWidth);

  LGroupWidth := LTextWidth;
  if FShowIcon then
    LGroupWidth := LGroupWidth + LIconSize + LGap;
  LGroupLeft := (ADest.Width - LGroupWidth) / 2;
  if LGroupLeft < ContentPadding then
    LGroupLeft := ContentPadding;
  LGroupLeft := Round(LGroupLeft);
  LIconSize := Round(LIconSize);
  LTextWidth := Round(LTextWidth);

  if FShowIcon and (FIconPosition = mipLeft) then
  begin
    AIconRect := TRectF.Create(LGroupLeft,
      (ADest.Height - LIconSize) / 2,
      LGroupLeft + LIconSize,
      (ADest.Height + LIconSize) / 2);
    ATextRect := TRectF.Create(AIconRect.Right + LGap, 0,
      AIconRect.Right + LGap + LTextWidth, ADest.Height);
  end
  else if FShowIcon then
  begin
    ATextRect := TRectF.Create(LGroupLeft, 0, LGroupLeft + LTextWidth,
      ADest.Height);
    AIconRect := TRectF.Create(ATextRect.Right + LGap,
      (ADest.Height - LIconSize) / 2,
      ATextRect.Right + LGap + LIconSize,
      (ADest.Height + LIconSize) / 2);
  end
  else
    ATextRect := TRectF.Create(LGroupLeft, 0, LGroupLeft + LTextWidth,
      ADest.Height);
end;

constructor TMaxxRuralButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque, csClickEvents, csCaptureMouse];
  Width := 128;
  Height := 36;
  TabStop := True;
  Cursor := crHandPoint;
  ParentColor := False;
  StyleElements := [];
  Color := clWhite;
  FCornerRadius := 8;
  FIconKind := mikCheck;
  FIconPosition := mipLeft;
  FIconSize := 0;
  FKind := mbkPrimary;
  FSize := mbsMedium;
  Caption := 'Botao';

  FRenderer := TMaxxRuralSkiaRenderer.Create;
  FBackgroundPainter := TMaxxRuralSkiaBackgroundPainter.Create(FRenderer);
  FBorderPainter := TMaxxRuralSkiaBorderPainter.Create(FRenderer);
  FIconPainter := TMaxxRuralSkiaIconPainter.Create(FRenderer);

  FPaintBox := TSkPaintBox.Create(Self);
  FPaintBox.Parent := Self;
  FPaintBox.SetSubComponent(True);
  FPaintBox.Cursor := crHandPoint;
  FPaintBox.StyleElements := [];
  FPaintBox.OnDraw := PaintBoxDraw;
  FPaintBox.OnMouseDown := PaintBoxMouseDown;
  FPaintBox.OnMouseEnter := PaintBoxMouseEnter;
  FPaintBox.OnMouseLeave := PaintBoxMouseLeave;
  FPaintBox.OnMouseMove := PaintBoxMouseMove;
  FPaintBox.OnMouseUp := PaintBoxMouseUp;

  FTextLabel := TMaxxRuralSystemText.Create(Self);
  FTextLabel.Parent := Self;
  FTextLabel.SetSubComponent(True);
  FTextLabel.Cursor := crHandPoint;
  FTextLabel.OnMouseDown := LabelMouseDown;
  FTextLabel.OnMouseEnter := LabelMouseEnter;
  FTextLabel.OnMouseLeave := LabelMouseLeave;
  FTextLabel.OnMouseMove := LabelMouseMove;
  FTextLabel.OnMouseUp := LabelMouseUp;

  Resize;
end;

destructor TMaxxRuralButton.Destroy;
begin
  FTextLabel.Free;
  FPaintBox.Free;
  FIconPainter.Free;
  FBorderPainter.Free;
  FBackgroundPainter.Free;
  FRenderer.Free;
  inherited;
end;

procedure TMaxxRuralButton.ChangeScale(M, D: Integer);
begin
  inherited;
  UpdateCursor;
  UpdateLabel;
  Redraw;
end;

procedure TMaxxRuralButton.Click;
begin
  if FLoading then
    Exit;
  inherited;
end;

procedure TMaxxRuralButton.CMEnabledChanged(var AMessage: TMessage);
begin
  inherited;
  UpdateLabel;
  Redraw;
end;

procedure TMaxxRuralButton.CMFocusChanged(var AMessage: TMessage);
begin
  inherited;
  Redraw;
end;

procedure TMaxxRuralButton.CMTextChanged(var AMessage: TMessage);
begin
  inherited;
  UpdateLabel;
end;

function TMaxxRuralButton.ContentPadding: Integer;
begin
  case FSize of
    mbsSmall:
      Result := 10;
    mbsLarge:
      Result := 18;
  else
    Result := 14;
  end;
end;

function TMaxxRuralButton.CursorInside: Boolean;
var
  LPoint: TPoint;
begin
  Result := False;
  if not HandleAllocated then
    Exit;

  if not GetCursorPos(LPoint) then
    Exit;
  LPoint := ScreenToClient(LPoint);
  Result := PtInRect(ClientRect, LPoint);
end;

procedure TMaxxRuralButton.CreateWnd;
begin
  inherited;
  UpdateZOrder;
  UpdateLabel;
  Redraw;
end;

procedure TMaxxRuralButton.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited;
  if (Key in [VK_RETURN, VK_SPACE]) and Enabled and not FLoading then
  begin
    FPressed := True;
    Redraw;
  end;
end;

procedure TMaxxRuralButton.KeyUp(var Key: Word; Shift: TShiftState);
begin
  inherited;
  if (Key in [VK_RETURN, VK_SPACE]) and FPressed then
  begin
    FPressed := False;
    Redraw;
    if Enabled and not FLoading then
      Click;
  end;
end;

procedure TMaxxRuralButton.Loaded;
begin
  inherited;
  UpdatePaintBoxBounds;
  UpdateZOrder;
  UpdateLabel;
  Redraw;
end;

function TMaxxRuralButton.EffectiveIconSize: Integer;
begin
  if FIconSize > 0 then
    Exit(FIconSize);

  case FSize of
    mbsSmall:
      Result := 14;
    mbsLarge:
      Result := 18;
  else
    Result := 16;
  end;
end;

procedure TMaxxRuralButton.InvalidateButton;
begin
  UpdateLabel;
  Redraw;
  Invalidate;
end;

procedure TMaxxRuralButton.LabelMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  MouseDown(Button, Shift, X + FTextLabel.Left, Y + FTextLabel.Top);
end;

procedure TMaxxRuralButton.LabelMouseEnter(Sender: TObject);
begin
  PaintBoxMouseEnter(Sender);
end;

procedure TMaxxRuralButton.LabelMouseLeave(Sender: TObject);
begin
  PaintBoxMouseLeave(Sender);
end;

procedure TMaxxRuralButton.LabelMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  MouseMove(Shift, X + FTextLabel.Left, Y + FTextLabel.Top);
end;

procedure TMaxxRuralButton.LabelMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  MouseUp(Button, Shift, X + FTextLabel.Left, Y + FTextLabel.Top);
end;

procedure TMaxxRuralButton.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  if Button <> mbLeft then
    Exit;
  if CanFocus then
    SetFocus;
  if Enabled and not FLoading then
  begin
    FPressed := True;
    MouseCapture := True;
    Redraw;
  end;
end;

procedure TMaxxRuralButton.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if not FMouseInside then
  begin
    FMouseInside := True;
    Redraw;
  end;
end;

procedure TMaxxRuralButton.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  LWasPressed: Boolean;
begin
  inherited;
  if Button <> mbLeft then
    Exit;
  LWasPressed := FPressed;
  FPressed := False;
  MouseCapture := False;
  Redraw;
  if LWasPressed and Enabled and not FLoading and PtInRect(ClientRect, Point(X, Y)) then
    Click;
end;

procedure TMaxxRuralButton.PaintBoxDraw(Sender: TObject;
  const ACanvas: ISkCanvas; const ADest: TRectF; const AOpacity: Single);
var
  LBackground: TMaxxRuralBackgroundStyle;
  LBackgroundRect: TRectF;
  LBorder: TMaxxRuralBorderStyle;
  LBorderRect: TRectF;
  LIconRect: TRectF;
  LPalette: TButtonPalette;
  LScale: Single;
  LStyle: TMaxxRuralIconStyle;
  LTextRect: TRectF;
begin
  if (ACanvas = nil) or (ADest.Width <= 0) or (ADest.Height <= 0) then
    Exit;

  LPalette := ButtonPalette(FKind, Enabled and not FLoading, FMouseInside,
    FPressed, Focused);
  LScale := ScaleFactor;
  LBorderRect := FRenderer.SnapRect(TRectF.Create(0, 0, ADest.Width,
    ADest.Height), LScale);
  LBackgroundRect := LBorderRect;
  LBackgroundRect.Inflate(-0.5 / LScale, -0.5 / LScale);

  if FKind = mbkInputAction then
    ACanvas.Clear(TMaxxRuralComponentColors.ControlBackgroundForSurface(ParentSurfaceColor))
  else
    ACanvas.Clear(ParentSurfaceColor);

  if LPalette.Background <> TMaxxRuralComponentColors.Transparent then
  begin
    LBackground.Color := LPalette.Background;
    LBackground.Radius := FCornerRadius;
    LBackground.Alpha := LPalette.Alpha;
    FBackgroundPainter.Draw(ACanvas, LBackgroundRect, LBackground);
  end;

  if LPalette.BorderAlpha > 0 then
  begin
    LBorder.Color := LPalette.Border;
    LBorder.Radius := FCornerRadius;
    LBorder.Width := 1;
    LBorder.Alpha := LPalette.BorderAlpha;
    FBorderPainter.Draw(ACanvas, LBorderRect, LBorder);
  end;

  if FKind = mbkInputAction then
    FRenderer.FillRoundRect(ACanvas,
      TRectF.Create(0, 1 / LScale, 1 / LScale, ADest.Height - (1 / LScale)),
      TMaxxRuralComponentColors.ControlBorder, 0, 255);

  if (FKind = mbkInputAction) and (not FShowIcon) and (Trim(Caption) <> '') then
    FRenderer.TextCentered(ACanvas, Caption,
      TMaxxRuralComponentFontInstaller.FontFamily, ADest, 11,
      LPalette.Text, True, ADest.Width - 8);

  if FShowIcon then
  begin
    CalculateContentLayout(ADest, LIconRect, LTextRect);
    LStyle.Color := LPalette.Icon;
    LStyle.Alpha := LPalette.Alpha;
    FIconPainter.Draw(ACanvas, LIconRect, FIconKind, LStyle);
  end;
end;

procedure TMaxxRuralButton.PaintBoxMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  MouseDown(Button, Shift, X, Y);
end;

procedure TMaxxRuralButton.PaintBoxMouseEnter(Sender: TObject);
begin
  FMouseInside := True;
  Redraw;
end;

procedure TMaxxRuralButton.PaintBoxMouseLeave(Sender: TObject);
begin
  if not MouseCapture and not CursorInside then
  begin
    FMouseInside := False;
    FPressed := False;
    Redraw;
  end;
end;

procedure TMaxxRuralButton.PaintBoxMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  MouseMove(Shift, X, Y);
end;

procedure TMaxxRuralButton.PaintBoxMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  MouseUp(Button, Shift, X, Y);
end;

function TMaxxRuralButton.ParentSurfaceColor: TAlphaColor;
begin
  Result := TMaxxRuralComponentColors.ResolveParentSurface(Self);
end;

procedure TMaxxRuralButton.Redraw;
begin
  UpdatePaintBoxBounds;
  UpdateLabel;
  if (FPaintBox <> nil) and HandleAllocated then
    FPaintBox.Redraw;
end;

procedure TMaxxRuralButton.Resize;
begin
  inherited;
  UpdatePaintBoxBounds;
  UpdateZOrder;
  UpdateLabel;
  Redraw;
end;

function TMaxxRuralButton.ScaleFactor: Single;
begin
  Result := 1;
  if FPaintBox <> nil then
    Result := FPaintBox.ScaleFactor;
  if Result <= 0 then
    Result := 1;
end;

function TMaxxRuralButton.ScaleMetric(const AValue: Integer): Integer;
begin
  Result := Round(AValue * ScaleFactor);
  if (AValue > 0) and (Result < 1) then
    Result := 1;
end;

procedure TMaxxRuralButton.SetCornerRadius(const AValue: Integer);
begin
  if FCornerRadius = AValue then
    Exit;
  FCornerRadius := Max(0, AValue);
  InvalidateButton;
end;

procedure TMaxxRuralButton.SetIconKind(const AValue: TMaxxRuralIconKind);
begin
  if FIconKind = AValue then
    Exit;
  FIconKind := AValue;
  InvalidateButton;
end;

procedure TMaxxRuralButton.SetIconPosition(
  const AValue: TMaxxRuralButtonIconPosition);
begin
  if FIconPosition = AValue then
    Exit;
  FIconPosition := AValue;
  InvalidateButton;
end;

procedure TMaxxRuralButton.SetIconSize(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(0, Min(AValue, 64));
  if FIconSize = LValue then
    Exit;
  FIconSize := LValue;
  InvalidateButton;
end;

procedure TMaxxRuralButton.SetKind(const AValue: TMaxxRuralButtonKind);
begin
  if FKind = AValue then
    Exit;
  FKind := AValue;
  InvalidateButton;
end;

procedure TMaxxRuralButton.SetLoading(const AValue: Boolean);
begin
  if FLoading = AValue then
    Exit;
  FLoading := AValue;
  FPressed := False;
  UpdateCursor;
  InvalidateButton;
end;

procedure TMaxxRuralButton.SetShowIcon(const AValue: Boolean);
begin
  if FShowIcon = AValue then
    Exit;
  FShowIcon := AValue;
  InvalidateButton;
end;

procedure TMaxxRuralButton.SetSize(const AValue: TMaxxRuralButtonSize);
begin
  if FSize = AValue then
    Exit;
  FSize := AValue;
  case FSize of
    mbsSmall:
      Height := ScaleMetric(30);
    mbsLarge:
      Height := ScaleMetric(42);
  else
    Height := ScaleMetric(36);
  end;
  InvalidateButton;
end;

procedure TMaxxRuralButton.UpdateCursor;
var
  LCursor: TCursor;
begin
  if Enabled and not FLoading then
    LCursor := crHandPoint
  else
    LCursor := crDefault;

  Cursor := LCursor;
  if FPaintBox <> nil then
    FPaintBox.Cursor := LCursor;
  if FTextLabel <> nil then
    FTextLabel.Cursor := LCursor;
end;

procedure TMaxxRuralButton.UpdateLabel;
var
  LPalette: TButtonPalette;
  LIconRect: TRectF;
  LTextRect: TRectF;
begin
  if (FTextLabel = nil) or not HandleAllocated then
    Exit;

  if FKind = mbkInputAction then
  begin
    FTextLabel.Visible := False;
    Exit;
  end;

  FTextLabel.Visible := True;
  LPalette := ButtonPalette(FKind, Enabled and not FLoading, FMouseInside,
    FPressed, Focused);
  CalculateContentLayout(TRectF.Create(0, 0, Width / ScaleFactor,
    Height / ScaleFactor), LIconRect, LTextRect);

  FTextLabel.SetBounds(Round(LTextRect.Left * ScaleFactor), 0,
    Max(0, Round(LTextRect.Width * ScaleFactor)), Height);
  FTextLabel.Text := Caption;
  FTextLabel.FontFamily := TMaxxRuralComponentFontInstaller.FontFamily;
  FTextLabel.FontSize := Round(ButtonFontSize);
  FTextLabel.Bold := True;
  FTextLabel.TextColor := LPalette.Text;
  FTextLabel.HorzAlign := mthaCenter;
  FTextLabel.VertAlign := mtvaCenter;
  FTextLabel.MaxLines := 1;
end;

procedure TMaxxRuralButton.UpdatePaintBoxBounds;
var
  LWidth: Integer;
  LHeight: Integer;
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

procedure TMaxxRuralButton.UpdateZOrder;
begin
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    Exit;
  if csDesigning in ComponentState then
    Exit;
  if not HandleAllocated then
    Exit;
  if (Parent = nil) or not Parent.HandleAllocated then
    Exit;

  if FPaintBox <> nil then
    FPaintBox.SendToBack;
  if FTextLabel <> nil then
    FTextLabel.BringToFront;
end;

procedure TMaxxRuralButton.WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
begin
  AMessage.Result := 1;
end;

end.
