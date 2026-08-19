unit DAC.Components.Controls.Button;

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
  DAC.Components.DesignSystem.Fonts,
  DAC.Components.DesignSystem.ControlTokens,
  DAC.Components.DesignSystem.ComponentStyle,
  DAC.Components.DesignSystem.Theme,
  DAC.Components.DesignSystem.IconAssets,
  DAC.Components.Skia.BackgroundPainter,
  DAC.Components.Skia.BorderPainter,
  DAC.Components.Skia.IconPainter,
  DAC.Components.Skia.Renderer;

type
  TDACButtonKind = (
    mbkPrimary,
    mbkSecondary,
    mbkGhost,
    mbkWarning,
    mbkDanger,
    mbkTransparent,
    mbkInputAction
  );

  TDACButtonSize = (
    mbsSmall,
    mbsMedium,
    mbsLarge
  );

  TDACButtonIconPosition = (
    mipLeft,
    mipRight
  );

  TDACButtonShape = (
    mbshDefault,
    mbshCompact,
    mbshRounded,
    mbshCustom
  );

  TDACInputActionSurfaceProvider = procedure(const ASender: TObject;
    out AColor: TAlphaColor) of object;

  TDACButton = class(TCustomControl)
  private
    FBackgroundPainter: TDACSkiaBackgroundPainter;
    FBorderPainter: TDACSkiaBorderPainter;
    FCornerRadius: Integer;
    FIconKind: TDACIconKind;
    FIconPainter: TDACSkiaIconPainter;
    FIconPosition: TDACButtonIconPosition;
    FIconSize: Integer;
    FInputActionOuterCornerRadius: Integer;
    FInputActionSurfaceProvider: TDACInputActionSurfaceProvider;
    FKind: TDACButtonKind;
    FLoading: Boolean;
    FMouseInside: Boolean;
    FPaintBox: TSkPaintBox;
    FPressed: Boolean;
    FRenderer: TDACSkiaRenderer;
    FShowIcon: Boolean;
    FShape: TDACButtonShape;
    FSize: TDACButtonSize;
    FTextLabel: TDACSystemText;
    FThemeMode: TDACThemeMode;
    function ButtonFontSize: Single;
    function CanvasBackground(
      const ATokens: TDACControlTokens): TAlphaColor;
    procedure CalculateContentLayout(const ADest: TRectF;
      out AIconRect, ATextRect: TRectF);
    procedure CMEnabledChanged(var AMessage: TMessage); message CM_ENABLEDCHANGED;
    procedure CMFocusChanged(var AMessage: TMessage); message CM_FOCUSCHANGED;
    procedure CMTextChanged(var AMessage: TMessage); message CM_TEXTCHANGED;
    function ContentPadding: Integer;
    function CursorInside: Boolean;
    function EffectiveIconSize: Integer;
    function IsDesignTimePreview: Boolean;
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
    function Pixels(const AValue: Integer): Integer;
    function IsCornerRadiusStored: Boolean;
    function ResolvedTokens: TDACControlTokens;
    procedure ApplyShape;
    procedure ApplyWindowRegion;
    procedure SetCornerRadius(const AValue: Integer);
    procedure SetIconKind(const AValue: TDACIconKind);
    procedure SetIconPosition(const AValue: TDACButtonIconPosition);
    procedure SetIconSize(const AValue: Integer);
    procedure SetKind(const AValue: TDACButtonKind);
    procedure SetLoading(const AValue: Boolean);
    procedure SetShowIcon(const AValue: Boolean);
    procedure SetShape(const AValue: TDACButtonShape);
    procedure SetSize(const AValue: TDACButtonSize);
    procedure SetThemeMode(const AValue: TDACThemeMode);
    procedure ThemeChanged(Sender: TObject);
    procedure UpdateCursor;
    procedure UpdateLabel;
    procedure UpdatePaintBoxBounds;
    procedure UpdateZOrder;
    procedure WMEraseBkgnd(var AMessage: TWMEraseBkgnd); message WM_ERASEBKGND;
  protected
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
    function MinimumContentWidth: Integer;
    function ResolvedBackgroundColor: TAlphaColor;
    function ResolvedCanvasBackgroundColor: TAlphaColor;
    procedure Redraw;
    procedure SetInputActionSurfaceProvider(
      const AProvider: TDACInputActionSurfaceProvider);
    procedure SetInputActionOuterCornerRadius(const AValue: Integer);
  published
    property Align;
    property Anchors;
    property Caption;
    property Constraints;
    property CornerRadius: Integer read FCornerRadius write SetCornerRadius
      stored IsCornerRadiusStored;
    property Enabled;
    property Font;
    property Hint;
    property IconKind: TDACIconKind read FIconKind write SetIconKind default mikCheck;
    property IconPosition: TDACButtonIconPosition read FIconPosition write SetIconPosition default mipLeft;
    property IconSize: Integer read FIconSize write SetIconSize default 0;
    property Kind: TDACButtonKind read FKind write SetKind default mbkPrimary;
    property Loading: Boolean read FLoading write SetLoading default False;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property ShowIcon: Boolean read FShowIcon write SetShowIcon default False;
    property Shape: TDACButtonShape read FShape write SetShape default mbshDefault;
    property Size: TDACButtonSize read FSize write SetSize default mbsMedium;
    property TabOrder;
    property TabStop default True;
    property ThemeMode: TDACThemeMode read FThemeMode write SetThemeMode default dtmInherit;
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

function ButtonVclColor(const AColor: TAlphaColor): TColor;
begin
  Result := TColor(((AColor and $00FF0000) shr 16) or
    (AColor and $0000FF00) or ((AColor and $000000FF) shl 16));
end;

function ButtonPalette(const AKind: TDACButtonKind;
  const AEnabled, ALoading, AHot, APressed, AFocused: Boolean;
  const ATokens: TDACControlTokens): TButtonPalette;
var
  LActive: Boolean;
begin
  Result.Alpha := ATokens.ButtonAlphaOpaque;
  Result.BorderAlpha := ATokens.ButtonBorderAlphaNone;
  LActive := AHot or AFocused;
  case AKind of
    mbkSecondary:
      begin
        Result.Background := ATokens.ButtonSecondaryBackground;
        Result.Border := ATokens.ButtonSecondaryBorder;
        Result.BorderAlpha := ATokens.ButtonBorderAlphaFull;
        Result.Text := ATokens.ButtonSecondaryText;
      end;
    mbkInputAction:
      begin
        Result.Background := ATokens.ButtonTransparent;
        Result.Border := ATokens.ButtonTransparent;
        Result.BorderAlpha := ATokens.ButtonBorderAlphaNone;
        Result.Text := ATokens.ButtonInputActionText;
      end;
    mbkTransparent:
      begin
        Result.Background := ATokens.ButtonTransparent;
        Result.Border := ATokens.ButtonTransparent;
        Result.BorderAlpha := ATokens.ButtonBorderAlphaNone;
        Result.Text := ATokens.ButtonTransparentText;
      end;
    mbkGhost:
      begin
        Result.Background := ATokens.ButtonGhostBackground;
        Result.Border := ATokens.ButtonGhostBorder;
        Result.BorderAlpha := ATokens.ButtonBorderAlphaGhostNormal;
        Result.Text := ATokens.ButtonGhostText;
      end;
    mbkDanger:
      begin
        Result.Background := ATokens.ButtonDangerBackground;
        Result.Border := ATokens.ButtonTransparent;
        Result.Text := ATokens.ButtonDangerText;
      end;
    mbkWarning:
      begin
        Result.Background := ATokens.ButtonWarningBackground;
        Result.Border := ATokens.ButtonTransparent;
        Result.Text := ATokens.ButtonWarningText;
      end;
  else
    begin
      Result.Background := ATokens.ButtonPrimaryBackground;
      Result.Border := ATokens.ButtonTransparent;
      Result.Text := ATokens.ButtonPrimaryText;
    end;
  end;

  if LActive then
  begin
    case AKind of
      mbkPrimary:
        begin
          Result.Background := ATokens.ButtonPrimaryPressedBackground;
          if AHot then
            Result.Background := ATokens.ButtonPrimaryHoverBackground;
        end;
      mbkSecondary:
        begin
          Result.Background := ATokens.ButtonSecondaryHoverBackground;
          Result.Border := ATokens.ButtonSecondaryHoverBorder;
        end;
      mbkInputAction:
        begin
          Result.Background := ATokens.ButtonTransparent;
          Result.Border := ATokens.ButtonTransparent;
          Result.BorderAlpha := ATokens.ButtonBorderAlphaNone;
        end;
      mbkTransparent:
        begin
          Result.Background := ATokens.ButtonTransparent;
          Result.Border := ATokens.ButtonTransparent;
          Result.BorderAlpha := ATokens.ButtonBorderAlphaNone;
          Result.Text := ATokens.ButtonTransparentText;
        end;
      mbkGhost:
        begin
          Result.Background := ATokens.ButtonGhostActiveBackground;
          Result.Border := ATokens.ButtonGhostBorder;
          Result.BorderAlpha := ATokens.ButtonBorderAlphaGhostActive;
        end;
      mbkDanger:
        Result.Background := ATokens.ButtonDangerBackground;
      mbkWarning:
        Result.Background := ATokens.ButtonWarningHoverBackground;
    end;
  end;

  if APressed then
  begin
    case AKind of
      mbkPrimary:
        Result.Background := ATokens.ButtonPrimaryPressedBackground;
      mbkSecondary:
        begin
          Result.Background := ATokens.ButtonSecondaryPressedBackground;
          Result.Border := ATokens.ButtonSecondaryHoverBorder;
        end;
      mbkInputAction:
        begin
          Result.Background := ATokens.ButtonTransparent;
          Result.Border := ATokens.ButtonTransparent;
          Result.BorderAlpha := ATokens.ButtonBorderAlphaNone;
        end;
      mbkTransparent:
        begin
          Result.Background := ATokens.ButtonTransparent;
          Result.Border := ATokens.ButtonTransparent;
          Result.BorderAlpha := ATokens.ButtonBorderAlphaNone;
          Result.Text := ATokens.ButtonTransparentText;
        end;
      mbkGhost:
        begin
          Result.Background := ATokens.ButtonGhostActiveBackground;
          Result.Border := ATokens.ButtonGhostBorder;
          Result.BorderAlpha := ATokens.ButtonBorderAlphaFull;
        end;
      mbkDanger:
        Result.Background := ATokens.ButtonDangerBackground;
      mbkWarning:
        Result.Background := ATokens.ButtonWarningPressedBackground;
    end;
  end;

  if not AEnabled then
  begin
    if AKind = mbkInputAction then
    begin
      // Embedded actions never own the field's outer border. Keep the edit
      // chrome visible and only dim the action glyph/text.
      Result.Background := ATokens.ButtonTransparent;
      Result.Border := ATokens.ButtonTransparent;
      Result.BorderAlpha := ATokens.ButtonBorderAlphaNone;
    end
    else
    begin
      Result.Background := ATokens.ButtonDisabledBackground;
      Result.Border := ATokens.ButtonDisabledBorder;
      Result.BorderAlpha := ATokens.ButtonBorderAlphaFull;
    end;
    Result.Text := ATokens.ButtonDisabledText;
  end
  else if ALoading then
  begin
    // Loading is non-interactive, but still represents a live primary action.
    // Keep the primary semantic in an opaque, high-contrast palette instead
    // of applying the disabled alpha used by the old implementation.
    if AKind = mbkInputAction then
    begin
      Result.Background := ATokens.ButtonTransparent;
      Result.Border := ATokens.ButtonTransparent;
      Result.BorderAlpha := ATokens.ButtonBorderAlphaNone;
    end
    else
    begin
      Result.Background := ATokens.ButtonLoadingBackground;
      Result.Border := ATokens.ButtonLoadingBorder;
      Result.BorderAlpha := ATokens.ButtonBorderAlphaFull;
    end;
    Result.Text := ATokens.ButtonLoadingText;
  end;

  Result.Icon := Result.Text;
end;

function TDACButton.ButtonFontSize: Single;
var
  LTokens: TDACControlTokens;
begin
  LTokens := ResolvedTokens;
  case FSize of
    mbsSmall:
      Result := LTokens.ButtonSmall.NativeFontSize;
    mbsLarge:
      Result := LTokens.ButtonLarge.NativeFontSize;
  else
    Result := LTokens.ButtonMedium.NativeFontSize;
  end;
end;

function TDACButton.CanvasBackground(
  const ATokens: TDACControlTokens): TAlphaColor;
begin
  if FKind <> mbkInputAction then
    Exit(ATokens.ButtonCanvasBackground);
  Result := ATokens.ButtonInputActionCanvasBackground;
  if Assigned(FInputActionSurfaceProvider) then
    FInputActionSurfaceProvider(Self, Result);
end;

procedure TDACButton.CalculateContentLayout(const ADest: TRectF;
  out AIconRect, ATextRect: TRectF);
var
  LAvailableWidth: Single;
  LGap: Single;
  LGroupLeft: Single;
  LGroupWidth: Single;
  LHasText: Boolean;
  LIconSize: Single;
  LTextWidth: Single;
begin
  AIconRect := TRectF.Empty;
  ATextRect := TRectF.Empty;

  LGap := ResolvedTokens.ButtonContentGap;
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
  else if FTextLabel <> nil then
    LTextWidth := FTextLabel.MeasureTextWidth(Caption,
      TDACComponentFontInstaller.FontFamily, Round(ButtonFontSize), True)
  else
    LTextWidth := 0;
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

constructor TDACButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque, csClickEvents, csCaptureMouse];
  FThemeMode := dtmInherit;
  Width := Round(ResolvedTokens.ButtonDefaultWidth);
  Height := Round(ResolvedTokens.ButtonDefaultHeight);
  TabStop := True;
  Cursor := crHandPoint;
  ParentColor := False;
  StyleElements := [];
  Color := ButtonVclColor(ResolvedTokens.ButtonFallbackBackground);
  FShape := mbshDefault;
  ApplyShape;
  FIconKind := mikCheck;
  FIconPosition := mipLeft;
  FIconSize := 0;
  FKind := mbkPrimary;
  FSize := mbsMedium;
  TDACThemeManager.RegisterListener(Self, ThemeChanged);
  Caption := 'Botao';

  FRenderer := TDACSkiaRenderer.Create;
  FBackgroundPainter := TDACSkiaBackgroundPainter.Create(FRenderer);
  FBorderPainter := TDACSkiaBorderPainter.Create(FRenderer);
  FIconPainter := TDACSkiaIconPainter.Create(FRenderer);

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

  FTextLabel := TDACSystemText.Create(Self);
  FTextLabel.Parent := Self;
  FTextLabel.SetSubComponent(True);
  FTextLabel.Cursor := crHandPoint;
  FTextLabel.OnMouseDown := LabelMouseDown;
  FTextLabel.OnMouseEnter := LabelMouseEnter;
  FTextLabel.OnMouseLeave := LabelMouseLeave;
  FTextLabel.OnMouseMove := LabelMouseMove;
  FTextLabel.OnMouseUp := LabelMouseUp;

  { Do not calculate text/layout from the constructor.  At this point the
    button may still have no Parent (the IDE uses this creation order), and a
    native text measurement would otherwise force TWinControl.CreateWnd. }
end;

procedure TDACButton.ApplyShape;
var
  LTokens: TDACControlTokens;
begin
  LTokens := ResolvedTokens;
  case FShape of
    mbshDefault:
      FCornerRadius := Round(LTokens.ButtonDefaultCornerRadius);
    mbshCompact:
      FCornerRadius := Round(LTokens.ButtonCompactCornerRadius);
    mbshRounded:
      FCornerRadius := Round(LTokens.ButtonRoundedCornerRadius);
  end;
  ApplyWindowRegion;
  InvalidateButton;
end;

destructor TDACButton.Destroy;
begin
  TDACThemeManager.UnregisterListener(Self);
  FTextLabel.Free;
  FPaintBox.Free;
  FIconPainter.Free;
  FBorderPainter.Free;
  FBackgroundPainter.Free;
  FRenderer.Free;
  inherited;
end;
procedure TDACButton.Click;
begin
  if FLoading then
    Exit;
  inherited;
end;

procedure TDACButton.CMEnabledChanged(var AMessage: TMessage);
begin
  inherited;
  UpdateLabel;
  Redraw;
end;

procedure TDACButton.CMFocusChanged(var AMessage: TMessage);
begin
  inherited;
  Redraw;
end;

procedure TDACButton.CMTextChanged(var AMessage: TMessage);
begin
  inherited;
  UpdateLabel;
end;

function TDACButton.ContentPadding: Integer;
var
  LTokens: TDACControlTokens;
begin
  LTokens := ResolvedTokens;
  case FSize of
    mbsSmall:
      Result := Round(LTokens.ButtonSmall.PaddingHorizontal);
    mbsLarge:
      Result := Round(LTokens.ButtonLarge.PaddingHorizontal);
  else
    Result := Round(LTokens.ButtonMedium.PaddingHorizontal);
  end;
end;

procedure TDACButton.ApplyWindowRegion;
var
  LDiameter: Integer;
  LLeftRegion: HRGN;
  LRadius: Integer;
  LRegion: HRGN;
begin
  if not HandleAllocated or (Width <= 0) or (Height <= 0) then
    Exit;
  if FKind <> mbkInputAction then
  begin
    SetWindowRgn(Handle, 0, True);
    Exit;
  end;

  // An input action is hosted inside another component's rounded chrome. A
  // rectangular child HWND would occlude the parent's right corner even when
  // its Skia canvas is transparent. The left edge remains square so the
  // embedded action still covers its full divider/content column.
  LRadius := FInputActionOuterCornerRadius;
  if LRadius <= 0 then
    LRadius := FCornerRadius;
  LDiameter := Max(1, LRadius * 2);
  LRegion := CreateRoundRectRgn(0, 0, Width + 1, Height + 1,
    LDiameter, LDiameter);
  LLeftRegion := CreateRectRgn(0, 0, Min(Width, LRadius + 1), Height + 1);
  if LLeftRegion <> 0 then
  begin
    CombineRgn(LRegion, LRegion, LLeftRegion, RGN_OR);
    DeleteObject(LLeftRegion);
  end;
  if SetWindowRgn(Handle, LRegion, True) = 0 then
    DeleteObject(LRegion);
end;

function TDACButton.CursorInside: Boolean;
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

procedure TDACButton.CreateWnd;
begin
  inherited;
  ApplyWindowRegion;
  UpdateZOrder;
  UpdateLabel;
  Redraw;
end;

procedure TDACButton.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited;
  if (Key in [VK_RETURN, VK_SPACE]) and Enabled and not FLoading then
  begin
    FPressed := True;
    Redraw;
  end;
end;

procedure TDACButton.KeyUp(var Key: Word; Shift: TShiftState);
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

procedure TDACButton.Loaded;
begin
  inherited;
  ApplyShape;
  ApplyWindowRegion;
  UpdatePaintBoxBounds;
  UpdateZOrder;
  UpdateLabel;
  Redraw;
end;

function TDACButton.EffectiveIconSize: Integer;
var
  LTokens: TDACControlTokens;
begin
  if FIconSize > 0 then
    Exit(FIconSize);

  LTokens := ResolvedTokens;
  case FSize of
    mbsSmall:
      Result := Round(LTokens.ButtonSmall.IconSize);
    mbsLarge:
      Result := Round(LTokens.ButtonLarge.IconSize);
  else
    Result := Round(LTokens.ButtonMedium.IconSize);
  end;
end;

function TDACButton.IsDesignTimePreview: Boolean;
var
  LControl: TControl;
begin
  { A child can receive CreateWnd/Resize while the IDE is reparenting it and
    before csDesigning is reflected on the child itself.  Inspect the existing
    owner/parent chain before performing runtime-only Z-order work. }
  Result := csDesigning in ComponentState;
  if (not Result) and (Owner <> nil) then
    Result := csDesigning in Owner.ComponentState;

  LControl := Parent;
  while (not Result) and (LControl <> nil) do
  begin
    Result := csDesigning in LControl.ComponentState;
    LControl := LControl.Parent;
  end;
end;

function TDACButton.MinimumContentWidth: Integer;
var
  LGap: Integer;
  LTextWidth: Single;
  LWidth: Integer;
begin
  LWidth := ContentPadding * 2;
  if Trim(Caption) <> '' then
  begin
    LTextWidth := 0;
    if FTextLabel <> nil then
      LTextWidth := FTextLabel.MeasureTextWidth(Caption,
      TDACComponentFontInstaller.FontFamily, Round(ButtonFontSize), True);
    Inc(LWidth, Ceil(LTextWidth));
  end;
  if FShowIcon then
  begin
    LGap := 0;
    if Trim(Caption) <> '' then
      LGap := Round(ResolvedTokens.ButtonContentGap);
    Inc(LWidth, EffectiveIconSize + LGap);
  end;
  Result := Max(Pixels(Round(ResolvedTokens.ButtonMinimumWidth)), Pixels(LWidth));
end;

function TDACButton.ResolvedBackgroundColor: TAlphaColor;
begin
  Result := ButtonPalette(FKind, Enabled, FLoading, FMouseInside, FPressed,
    Focused, ResolvedTokens).Background;
end;

function TDACButton.ResolvedCanvasBackgroundColor: TAlphaColor;
begin
  Result := CanvasBackground(ResolvedTokens);
end;

function TDACButton.IsCornerRadiusStored: Boolean;
begin
  Result := FShape = mbshCustom;
end;

procedure TDACButton.InvalidateButton;
begin
  UpdateLabel;
  Redraw;
  Invalidate;
end;

procedure TDACButton.LabelMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  MouseDown(Button, Shift, X + FTextLabel.Left, Y + FTextLabel.Top);
end;

procedure TDACButton.LabelMouseEnter(Sender: TObject);
begin
  PaintBoxMouseEnter(Sender);
end;

procedure TDACButton.LabelMouseLeave(Sender: TObject);
begin
  PaintBoxMouseLeave(Sender);
end;

procedure TDACButton.LabelMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  MouseMove(Shift, X + FTextLabel.Left, Y + FTextLabel.Top);
end;

procedure TDACButton.LabelMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  MouseUp(Button, Shift, X + FTextLabel.Left, Y + FTextLabel.Top);
end;

procedure TDACButton.MouseDown(Button: TMouseButton; Shift: TShiftState;
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

procedure TDACButton.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  inherited;
  if not FMouseInside then
  begin
    FMouseInside := True;
    Redraw;
  end;
end;

procedure TDACButton.MouseUp(Button: TMouseButton; Shift: TShiftState;
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

procedure TDACButton.PaintBoxDraw(Sender: TObject;
  const ACanvas: ISkCanvas; const ADest: TRectF; const AOpacity: Single);
var
  LBackground: TDACBackgroundStyle;
  LBackgroundRect: TRectF;
  LBorder: TDACBorderStyle;
  LBorderRect: TRectF;
  LIconRect: TRectF;
  LPalette: TButtonPalette;
  LScale: Single;
  LStyle: TDACIconStyle;
  LTextRect: TRectF;
  LTokens: TDACControlTokens;
begin
  if (ACanvas = nil) or (ADest.Width <= 0) or (ADest.Height <= 0) then
    Exit;

  LTokens := ResolvedTokens;
  LPalette := ButtonPalette(FKind, Enabled, FLoading, FMouseInside,
    FPressed, Focused, LTokens);
  LScale := LTokens.ButtonPainterSnapScale;
  LBorderRect := FRenderer.SnapRect(TRectF.Create(0, 0, ADest.Width,
    ADest.Height), LScale);
  LBackgroundRect := LBorderRect;
  LBackgroundRect.Inflate(-LTokens.ButtonPainterInset / LScale,
    -LTokens.ButtonPainterInset / LScale);

  ACanvas.Clear(CanvasBackground(LTokens));

  if LPalette.Background <> LTokens.ButtonTransparent then
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
    LBorder.Width := LTokens.ButtonBorderWidth;
    LBorder.Alpha := LPalette.BorderAlpha;
    FBorderPainter.Draw(ACanvas, LBorderRect, LBorder);
  end;

  if FKind = mbkInputAction then
    FRenderer.FillRoundRect(ACanvas,
      TRectF.Create(0, LTokens.ButtonInputActionDividerVerticalInset / LScale,
        LTokens.ButtonInputActionDividerWidth / LScale,
        ADest.Height - (LTokens.ButtonInputActionDividerVerticalInset / LScale)),
      LTokens.ButtonInputActionDivider, 0, LTokens.ButtonAlphaOpaque);

  if FShowIcon then
  begin
    CalculateContentLayout(ADest, LIconRect, LTextRect);
    LStyle.Color := LPalette.Icon;
    LStyle.Alpha := LPalette.Alpha;
    FIconPainter.Draw(ACanvas, LIconRect, FIconKind, LStyle);
  end;
end;

procedure TDACButton.PaintBoxMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  MouseDown(Button, Shift, X, Y);
end;

procedure TDACButton.PaintBoxMouseEnter(Sender: TObject);
begin
  FMouseInside := True;
  Redraw;
end;

procedure TDACButton.PaintBoxMouseLeave(Sender: TObject);
begin
  if not MouseCapture and not CursorInside then
  begin
    FMouseInside := False;
    FPressed := False;
    Redraw;
  end;
end;

procedure TDACButton.PaintBoxMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
begin
  MouseMove(Shift, X, Y);
end;

procedure TDACButton.PaintBoxMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  MouseUp(Button, Shift, X, Y);
end;

procedure TDACButton.Redraw;
begin
  if (FPaintBox = nil) or (FPaintBox.Parent <> Self) or
    (csDestroying in ComponentState) then
    Exit;
  UpdatePaintBoxBounds;
  UpdateLabel;

  { The designer does not guarantee a stable HWND tree while a component is
    being inserted or resized.  TSkPaintBox and TDACSystemText are child
    controls/graphic controls, so their design preview must use the persisted
    bounds and regular invalidation instead of waiting for runtime handles. }
  if IsDesignTimePreview then
  begin
    { Invalidate alone retains the cached Skia frame in the VCL designer.
      Redraw clears that cache and repaints the current token palette without
      requiring a HWND or changing the composition order. }
    FPaintBox.Redraw;
    if (FTextLabel <> nil) and (FTextLabel.Parent = Self) then
      FTextLabel.Invalidate;
    Invalidate;
    Exit;
  end;

  if (Parent = nil) or not HandleAllocated or not Parent.HandleAllocated then
    Exit;
  FPaintBox.Redraw;
end;

procedure TDACButton.Resize;
begin
  inherited;
  ApplyWindowRegion;
  UpdatePaintBoxBounds;
  UpdateZOrder;
  UpdateLabel;
  Redraw;
end;

function TDACButton.Pixels(const AValue: Integer): Integer;
begin
  Result := AValue;
  if (AValue > 0) and (Result < 1) then
    Result := 1;
end;

function TDACButton.ResolvedTokens: TDACControlTokens;
begin
  Result := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls;
end;

procedure TDACButton.SetCornerRadius(const AValue: Integer);
begin
  FShape := mbshCustom;
  if FCornerRadius = Max(0, AValue) then
    Exit;
  FCornerRadius := Max(0, AValue);
  ApplyWindowRegion;
  InvalidateButton;
end;

procedure TDACButton.SetInputActionOuterCornerRadius(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(0, AValue);
  if FInputActionOuterCornerRadius = LValue then
    Exit;
  FInputActionOuterCornerRadius := LValue;
  ApplyWindowRegion;
  InvalidateButton;
end;

procedure TDACButton.SetInputActionSurfaceProvider(
  const AProvider: TDACInputActionSurfaceProvider);
begin
  FInputActionSurfaceProvider := AProvider;
  InvalidateButton;
end;

procedure TDACButton.SetShape(const AValue: TDACButtonShape);
begin
  if FShape = AValue then
  begin
    if AValue <> mbshCustom then
      ApplyShape;
    Exit;
  end;
  FShape := AValue;
  ApplyShape;
end;

procedure TDACButton.SetIconKind(const AValue: TDACIconKind);
begin
  if FIconKind = AValue then
    Exit;
  FIconKind := AValue;
  InvalidateButton;
end;

procedure TDACButton.SetIconPosition(
  const AValue: TDACButtonIconPosition);
begin
  if FIconPosition = AValue then
    Exit;
  FIconPosition := AValue;
  InvalidateButton;
end;

procedure TDACButton.SetIconSize(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(0, Min(AValue, ResolvedTokens.ButtonMaximumIconSize));
  if FIconSize = LValue then
    Exit;
  FIconSize := LValue;
  InvalidateButton;
end;

procedure TDACButton.SetKind(const AValue: TDACButtonKind);
begin
  if FKind = AValue then
    Exit;
  FKind := AValue;
  ApplyWindowRegion;
  InvalidateButton;
end;

procedure TDACButton.SetLoading(const AValue: Boolean);
begin
  if FLoading = AValue then
    Exit;
  FLoading := AValue;
  FPressed := False;
  UpdateCursor;
  InvalidateButton;
end;

procedure TDACButton.SetShowIcon(const AValue: Boolean);
begin
  if FShowIcon = AValue then
    Exit;
  FShowIcon := AValue;
  InvalidateButton;
end;

procedure TDACButton.SetSize(const AValue: TDACButtonSize);
var
  LTokens: TDACControlTokens;
begin
  if FSize = AValue then
    Exit;
  FSize := AValue;
  LTokens := ResolvedTokens;
  case FSize of
    mbsSmall:
      Height := Pixels(Round(LTokens.ButtonSmall.Height));
    mbsLarge:
      Height := Pixels(Round(LTokens.ButtonLarge.Height));
  else
    Height := Pixels(Round(LTokens.ButtonMedium.Height));
  end;
  ApplyWindowRegion;
  InvalidateButton;
end;

procedure TDACButton.SetThemeMode(const AValue: TDACThemeMode);
begin
  if FThemeMode = AValue then
    Exit;
  FThemeMode := AValue;
  ThemeChanged(Self);
end;

procedure TDACButton.ThemeChanged(Sender: TObject);
begin
  Color := ButtonVclColor(ResolvedTokens.ButtonFallbackBackground);
  ApplyShape;
  InvalidateButton;
end;

procedure TDACButton.UpdateCursor;
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

procedure TDACButton.UpdateLabel;
var
  LPalette: TButtonPalette;
  LTokens: TDACControlTokens;
  LIconRect: TRectF;
  LLabelLeft: Integer;
  LLabelWidth: Integer;
  LTextRect: TRectF;
begin
  if (FTextLabel = nil) or (FTextLabel.Parent <> Self) or
    (csDestroying in ComponentState) then
    Exit;

  if FKind = mbkInputAction then
  begin
    FTextLabel.Visible := (not FShowIcon) and (Trim(Caption) <> '');
    if not FTextLabel.Visible then
      Exit;
    LTokens := ResolvedTokens;
    LPalette := ButtonPalette(FKind, Enabled, FLoading, FMouseInside,
      FPressed, Focused, LTokens);
    FTextLabel.SetBounds(0, 0,
      Max(0, Width - Round(LTokens.ButtonInputActionCaptionRightInset)), Height);
    FTextLabel.Text := Caption;
    FTextLabel.FontFamily := TDACComponentFontInstaller.FontFamily;
    FTextLabel.FontSize := Round(LTokens.ButtonInputActionCaptionTextSize);
    FTextLabel.Bold := True;
    FTextLabel.TextColor := LPalette.Text;
    FTextLabel.HorzAlign := mthaCenter;
    FTextLabel.VertAlign := mtvaCenter;
    FTextLabel.MaxLines := 1;
    Exit;
  end;

  FTextLabel.Visible := True;
  LTokens := ResolvedTokens;
  LPalette := ButtonPalette(FKind, Enabled, FLoading, FMouseInside,
    FPressed, Focused, LTokens);
  CalculateContentLayout(TRectF.Create(0, 0, Width, Height),
    LIconRect, LTextRect);

  LLabelLeft := Max(0, Round(LTextRect.Left));
  LLabelWidth := Max(0, Round(LTextRect.Width));
  LLabelWidth := Min(LLabelWidth, Width - LLabelLeft);
  FTextLabel.SetBounds(LLabelLeft, 0, LLabelWidth, Height);
  FTextLabel.Text := Caption;
  FTextLabel.FontFamily := TDACComponentFontInstaller.FontFamily;
  FTextLabel.FontSize := Round(ButtonFontSize);
  FTextLabel.Bold := LTokens.ButtonCaptionBold;
  FTextLabel.TextColor := LPalette.Text;
  FTextLabel.HorzAlign := mthaCenter;
  FTextLabel.VertAlign := mtvaCenter;
  FTextLabel.MaxLines := LTokens.ButtonCaptionMaxLines;
end;

procedure TDACButton.UpdatePaintBoxBounds;
var
  LWidth: Integer;
  LHeight: Integer;
begin
  if (FPaintBox = nil) or (FPaintBox.Parent <> Self) or
    (csLoading in ComponentState) or
    (csDestroying in ComponentState) then
    Exit;

  { Width/Height are the only reliable dimensions before the VCL has created
    the design-time HWND hierarchy.  At runtime keep using client bounds so
    the chrome follows the actual client area. }
  LWidth := Width;
  LHeight := Height;
  if not IsDesignTimePreview and HandleAllocated and
    (Parent <> nil) and Parent.HandleAllocated then
  begin
    LWidth := ClientWidth;
    LHeight := ClientHeight;
  end;

  if (FPaintBox.Left <> 0) or (FPaintBox.Top <> 0) or
    (FPaintBox.Width <> LWidth) or (FPaintBox.Height <> LHeight) then
    FPaintBox.SetBounds(0, 0, LWidth, LHeight);

end;

procedure TDACButton.UpdateZOrder;
begin
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    Exit;
  if IsDesignTimePreview then
    Exit;
  if not HandleAllocated then
    Exit;
  if (Parent = nil) or not Parent.HandleAllocated or not Showing then
    Exit;

  if (FPaintBox <> nil) and (FPaintBox.Parent = Self) then
    FPaintBox.SendToBack;
  if (FTextLabel <> nil) and (FTextLabel.Parent = Self) then
    FTextLabel.BringToFront;
end;

procedure TDACButton.WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
begin
  AMessage.Result := 1;
end;

end.

