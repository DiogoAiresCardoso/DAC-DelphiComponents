unit MaxxRural.Components.Controls.Edit;

interface

uses
  System.Classes,
  System.Skia,
  System.Types,
  System.UITypes,
  Winapi.Messages,
  System.SysUtils,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Graphics,
  Vcl.Mask,
  Vcl.Skia,
  Vcl.StdCtrls,
  MaxxRural.Components.DesignSystem.Fonts,
  MaxxRural.Components.DesignSystem.IconAssets,
  MaxxRural.Components.Skia.BackgroundPainter,
  MaxxRural.Components.Skia.BorderPainter,
  MaxxRural.Components.Skia.IconPainter,
  MaxxRural.Components.Skia.Renderer;

type
  TMaxxRuralEditStatus = (
    mesNormal,
    mesSuccess,
    mesWarning,
    mesDanger
  );

  TMaxxRuralEditKind = (
    mekText,
    mekMasked,
    mekPassword,
    mekSearch,
    mekNumeric,
    mekDate,
    mekTime
  );

  TMaxxRuralInputSize = (
    misSmall,
    misMedium,
    misLarge
  );

  TMaxxRuralInputVariant = (
    mivOutlined,
    mivUnderlined,
    mivCompact
  );

  TMaxxRuralEdit = class(TCustomControl)
  private
    FBackgroundPainter: TMaxxRuralSkiaBackgroundPainter;
    FBorderPainter: TMaxxRuralSkiaBorderPainter;
    FCornerRadius: Integer;
    FEdit: TMaskEdit;
    FEditKind: TMaxxRuralEditKind;
    FEditMask: string;
    FCounterText: string;
    FHelperText: string;
    FIconPainter: TMaxxRuralSkiaIconPainter;
    FInputSize: TMaxxRuralInputSize;
    FLabelText: string;
    FMouseInside: Boolean;
    FOnChange: TNotifyEvent;
    FPaintBox: TSkPaintBox;
    FPlaceholder: string;
    FRenderer: TMaxxRuralSkiaRenderer;
    FRequired: Boolean;
    FStatus: TMaxxRuralEditStatus;
    FVariant: TMaxxRuralInputVariant;
    function BorderAlpha: Byte;
    function BorderColor: TAlphaColor;
    function ControlHeight: Integer;
    procedure CMEnabledChanged(var AMessage: TMessage); message CM_ENABLEDCHANGED;
    procedure CMParentColorChanged(var AMessage: TMessage); message CM_PARENTCOLORCHANGED;
    procedure DoEditChange(Sender: TObject);
    procedure DoEditEnter(Sender: TObject);
    procedure DoEditExit(Sender: TObject);
    procedure DoMouseEnter(Sender: TObject);
    procedure DoMouseLeave(Sender: TObject);
    function GetCharCase: TEditCharCase;
    function GetEffectivePasswordChar: Char;
    function GetMaxLength: Integer;
    function GetPasswordChar: Char;
    function GetReadOnly: Boolean;
    function GetText: string;
    function EffectiveEditMask: string;
    function RightIconKind: TMaxxRuralIconKind;
    function HasRightIcon: Boolean;
    function HasLabel: Boolean;
    function HasSupportText: Boolean;
    function InputFontSize: Integer;
    function SupportTextColor(const ASurface: TAlphaColor): TAlphaColor;
    function ChromeTop: Integer;
    procedure InvalidateChrome;
    procedure PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    function ParentSurfaceColor: TAlphaColor;
    function ScaleFactor: Single;
    function ScaleMetric(const AValue: Integer): Integer;
    procedure SetCharCase(const AValue: TEditCharCase);
    procedure SetCornerRadius(const AValue: Integer);
    procedure SetCounterText(const AValue: string);
    procedure SetEditKind(const AValue: TMaxxRuralEditKind);
    procedure SetEditMask(const AValue: string);
    procedure SetHelperText(const AValue: string);
    procedure SetInputSize(const AValue: TMaxxRuralInputSize);
    procedure SetLabelText(const AValue: string);
    procedure SetMaxLength(const AValue: Integer);
    procedure SetPasswordChar(const AValue: Char);
    procedure SetPlaceholder(const AValue: string);
    procedure SetReadOnly(const AValue: Boolean);
    procedure SetRequired(const AValue: Boolean);
    procedure SetStatus(const AValue: TMaxxRuralEditStatus);
    procedure SetText(const AValue: string);
    procedure SetVariant(const AValue: TMaxxRuralInputVariant);
    procedure UpdateChildBounds;
    procedure UpdateEditStyle;
    procedure UpdatePaintBoxBounds;
    procedure UpdateZOrder;
    procedure WMEraseBkgnd(var AMessage: TWMEraseBkgnd); message WM_ERASEBKGND;
  protected
    procedure ChangeScale(M, D: Integer); override;
    procedure CreateWnd; override;
    procedure Loaded; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Redraw;
    procedure SetFocus; reintroduce;
    property EditControl: TMaskEdit read FEdit;
  published
    property Align;
    property Anchors;
    property CharCase: TEditCharCase read GetCharCase write SetCharCase default ecNormal;
    property Constraints;
    property CornerRadius: Integer read FCornerRadius write SetCornerRadius default 8;
    property CounterText: string read FCounterText write SetCounterText;
    property EditKind: TMaxxRuralEditKind read FEditKind write SetEditKind default mekText;
    property EditMask: string read FEditMask write SetEditMask;
    property Enabled;
    property Font;
    property HelperText: string read FHelperText write SetHelperText;
    property InputSize: TMaxxRuralInputSize read FInputSize write SetInputSize default misMedium;
    property LabelText: string read FLabelText write SetLabelText;
    property MaxLength: Integer read GetMaxLength write SetMaxLength default 0;
    property ParentFont;
    property ParentShowHint;
    property PasswordChar: Char read GetPasswordChar write SetPasswordChar default #0;
    property Placeholder: string read FPlaceholder write SetPlaceholder;
    property PopupMenu;
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly default False;
    property Required: Boolean read FRequired write SetRequired default False;
    property ShowHint;
    property Status: TMaxxRuralEditStatus read FStatus write SetStatus default mesNormal;
    property TabOrder;
    property TabStop default True;
    property Text: string read GetText write SetText;
    property Variant: TMaxxRuralInputVariant read FVariant write SetVariant default mivOutlined;
    property Visible;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnClick;
    property OnDblClick;
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
  Winapi.Windows;

constructor TMaxxRuralEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque, csClickEvents, csCaptureMouse];
  Width := 220;
  Height := 38;
  TabStop := True;
  ParentColor := False;
  StyleElements := [];
  Cursor := crIBeam;
  Color := clWhite;
  FCornerRadius := 8;
  FEditKind := mekText;
  FInputSize := misMedium;
  FStatus := mesNormal;
  FVariant := mivOutlined;

  FRenderer := TMaxxRuralSkiaRenderer.Create;
  FBackgroundPainter := TMaxxRuralSkiaBackgroundPainter.Create(FRenderer);
  FBorderPainter := TMaxxRuralSkiaBorderPainter.Create(FRenderer);
  FIconPainter := TMaxxRuralSkiaIconPainter.Create(FRenderer);

  FPaintBox := TSkPaintBox.Create(Self);
  FPaintBox.Parent := Self;
  FPaintBox.SetSubComponent(True);
  FPaintBox.StyleElements := [];
  FPaintBox.Cursor := crIBeam;
  FPaintBox.OnDraw := PaintBoxDraw;
  FPaintBox.OnMouseEnter := DoMouseEnter;
  FPaintBox.OnMouseLeave := DoMouseLeave;

  FEdit := TMaskEdit.Create(Self);
  FEdit.Parent := Self;
  FEdit.SetSubComponent(True);
  FEdit.BorderStyle := bsNone;
  FEdit.StyleElements := [];
  FEdit.ParentFont := False;
  FEdit.OnChange := DoEditChange;
  FEdit.OnEnter := DoEditEnter;
  FEdit.OnExit := DoEditExit;
  FEdit.OnMouseEnter := DoMouseEnter;
  FEdit.OnMouseLeave := DoMouseLeave;

  UpdateEditStyle;
  Resize;
end;

destructor TMaxxRuralEdit.Destroy;
begin
  FEdit.Free;
  FPaintBox.Free;
  FIconPainter.Free;
  FBorderPainter.Free;
  FBackgroundPainter.Free;
  FRenderer.Free;
  inherited;
end;

function TMaxxRuralEdit.BorderAlpha: Byte;
begin
  if FVariant = mivUnderlined then
  begin
    if FEdit.Focused or (FStatus <> mesNormal) then
      Exit(255);
    if FMouseInside then
      Exit(220);
    Exit(190);
  end;

  if not Enabled then
    Result := 130
  else if FEdit.Focused then
    Result := 255
  else if FStatus <> mesNormal then
    Result := 215
  else if FMouseInside then
    Result := 210
  else
    Result := 185;
end;

function TMaxxRuralEdit.BorderColor: TAlphaColor;
var
  LSurface: TAlphaColor;
begin
  LSurface := ParentSurfaceColor;
  case FStatus of
    mesSuccess:
      Result := TMaxxRuralComponentColors.PrimaryDark;
    mesWarning:
      Result := TMaxxRuralComponentColors.Warning;
    mesDanger:
      Result := TMaxxRuralComponentColors.Danger;
  else
    if FEdit.Focused then
      Result := TMaxxRuralComponentColors.Primary
    else if FMouseInside then
      Result := TMaxxRuralComponentColors.ControlBorderHoverForSurface(LSurface)
    else
      Result := TMaxxRuralComponentColors.ControlBorderForSurface(LSurface);
  end;
end;

function TMaxxRuralEdit.ControlHeight: Integer;
begin
  case FInputSize of
    misSmall:
      Result := ScaleMetric(32);
    misLarge:
      Result := ScaleMetric(48);
  else
    Result := ScaleMetric(40);
  end;

  if FVariant = mivCompact then
    Result := ScaleMetric(32);
end;

procedure TMaxxRuralEdit.ChangeScale(M, D: Integer);
begin
  inherited;
  UpdateChildBounds;
  Redraw;
end;

procedure TMaxxRuralEdit.CMEnabledChanged(var AMessage: TMessage);
begin
  inherited;
  UpdateEditStyle;
  Redraw;
end;

procedure TMaxxRuralEdit.CMParentColorChanged(var AMessage: TMessage);
begin
  inherited;
  UpdateEditStyle;
  Redraw;
end;

procedure TMaxxRuralEdit.CreateWnd;
begin
  inherited;
  UpdateZOrder;
  UpdateChildBounds;
  UpdateEditStyle;
  Redraw;
end;

procedure TMaxxRuralEdit.DoEditChange(Sender: TObject);
begin
  if Assigned(OnChange) then
    OnChange(Self);
end;

procedure TMaxxRuralEdit.DoEditEnter(Sender: TObject);
begin
  Redraw;
  if Assigned(OnEnter) then
    OnEnter(Self);
end;

procedure TMaxxRuralEdit.DoEditExit(Sender: TObject);
begin
  Redraw;
  if Assigned(OnExit) then
    OnExit(Self);
end;

procedure TMaxxRuralEdit.DoMouseEnter(Sender: TObject);
begin
  if FMouseInside then
    Exit;
  FMouseInside := True;
  Redraw;
  if Assigned(OnMouseEnter) then
    OnMouseEnter(Self);
end;

procedure TMaxxRuralEdit.DoMouseLeave(Sender: TObject);
var
  LPoint: TPoint;
begin
  if not GetCursorPos(LPoint) then
    Exit;
  LPoint := ScreenToClient(LPoint);
  if PtInRect(ClientRect, LPoint) then
    Exit;

  if not FMouseInside then
    Exit;
  FMouseInside := False;
  Redraw;
  if Assigned(OnMouseLeave) then
    OnMouseLeave(Self);
end;

procedure TMaxxRuralEdit.Loaded;
begin
  inherited;
  UpdatePaintBoxBounds;
  UpdateZOrder;
  UpdateChildBounds;
  UpdateEditStyle;
  Redraw;
end;

function TMaxxRuralEdit.GetCharCase: TEditCharCase;
begin
  Result := FEdit.CharCase;
end;

function TMaxxRuralEdit.GetEffectivePasswordChar: Char;
begin
  Result := #0;
  if FEditKind = mekPassword then
  begin
    Result := FEdit.PasswordChar;
    if Result = #0 then
      Result := '*';
  end;
end;

function TMaxxRuralEdit.EffectiveEditMask: string;
begin
  Result := FEditMask;
  if Result <> '' then
    Exit;

  case FEditKind of
    mekNumeric:
      Result := '999.999.999,99;0;_';
    mekDate:
      Result := '!99/99/9999;1;_';
    mekTime:
      Result := '!99:99;1;_';
  end;
end;

function TMaxxRuralEdit.GetMaxLength: Integer;
begin
  Result := FEdit.MaxLength;
end;

function TMaxxRuralEdit.GetPasswordChar: Char;
begin
  Result := FEdit.PasswordChar;
end;

function TMaxxRuralEdit.GetReadOnly: Boolean;
begin
  Result := FEdit.ReadOnly;
end;

function TMaxxRuralEdit.GetText: string;
begin
  Result := FEdit.Text;
end;

function TMaxxRuralEdit.HasRightIcon: Boolean;
begin
  Result := RightIconKind <> mikNone;
end;

function TMaxxRuralEdit.RightIconKind: TMaxxRuralIconKind;
begin
  case FEditKind of
    mekPassword:
      Result := mikEye;
    mekSearch:
      Result := mikSearch;
    mekDate:
      Result := mikCalendar;
    mekTime:
      Result := mikClock;
  else
    Result := mikNone;
  end;
end;

procedure TMaxxRuralEdit.InvalidateChrome;
begin
  UpdateChildBounds;
  Redraw;
  Invalidate;
end;

procedure TMaxxRuralEdit.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  if (Button = mbLeft) and Enabled and (FEdit <> nil) then
    FEdit.SetFocus;
end;

procedure TMaxxRuralEdit.PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
  const ADest: TRectF; const AOpacity: Single);
var
  LBackground: TMaxxRuralBackgroundStyle;
  LBorder: TMaxxRuralBorderStyle;
  LIconRect: TRectF;
  LIconStyle: TMaxxRuralIconStyle;
  LCounterWidth: Single;
  LLabelColor: TAlphaColor;
  LScale: Single;
  LBorderRect: TRectF;
  LControlBottom: Single;
  LRect: TRectF;
  LSurface: TAlphaColor;
  LSupportColor: TAlphaColor;
  LTop: Single;
begin
  if (ACanvas = nil) or (ADest.Width <= 0) or (ADest.Height <= 0) then
    Exit;

  LScale := ScaleFactor;
  LTop := ChromeTop;
  LControlBottom := Min(ADest.Height, LTop + ControlHeight);
  LBorderRect := FRenderer.SnapRect(TRectF.Create(0, LTop, ADest.Width,
    LControlBottom), LScale);
  LRect := LBorderRect;
  LRect.Inflate(-0.5 / LScale, -0.5 / LScale);

  LSurface := ParentSurfaceColor;
  ACanvas.Clear(LSurface);

  if HasLabel then
  begin
    LLabelColor := TMaxxRuralComponentColors.ControlTextForSurface(LSurface);
    if FRequired then
      LLabelColor := TMaxxRuralComponentColors.PrimaryDark;
    FRenderer.Text(ACanvas, FLabelText,
      TMaxxRuralComponentFontInstaller.FontFamily, 0,
      ScaleMetric(15), 12, LLabelColor, FRequired, ADest.Width);
  end;

  LBorder.Color := BorderColor;
  LBorder.Radius := FCornerRadius;
  LBorder.Width := 1;
  if FEdit.Focused then
    LBorder.Width := 1.5;
  LBorder.Alpha := BorderAlpha;
  if FVariant = mivUnderlined then
  begin
    FRenderer.StrokeRoundRect(ACanvas,
      TRectF.Create(LRect.Left, LRect.Bottom - ScaleMetric(1), LRect.Right,
        LRect.Bottom), LBorder.Color, 0, LBorder.Width, LBorder.Alpha);
  end
  else
  begin
    LBackground.Color := TMaxxRuralComponentColors.ControlBackgroundForSurface(LSurface);
    if not Enabled then
      LBackground.Color := TMaxxRuralComponentColors.ControlBackgroundDisabledForSurface(LSurface);
    LBackground.Radius := FCornerRadius;
    LBackground.Alpha := 255;
    FBackgroundPainter.Draw(ACanvas, LRect, LBackground);
    FBorderPainter.Draw(ACanvas, LBorderRect, LBorder);
  end;

  if HasRightIcon then
  begin
    LIconRect := TRectF.Create(ADest.Width - ScaleMetric(30),
      LRect.Top + (LRect.Height - ScaleMetric(16)) / 2,
      ADest.Width - ScaleMetric(14),
      LRect.Top + (LRect.Height + ScaleMetric(16)) / 2);
    LIconStyle.Color := TMaxxRuralComponentColors.ControlBorderHoverForSurface(LSurface);
    LIconStyle.Alpha := 255;
    if not Enabled then
      LIconStyle.Color := TMaxxRuralComponentColors.ControlTextDisabledForSurface(LSurface);

    FIconPainter.Draw(ACanvas, LIconRect, RightIconKind, LIconStyle);
  end;

  if HasSupportText then
  begin
    LSupportColor := SupportTextColor(LSurface);
    if FHelperText.Trim <> '' then
      FRenderer.Text(ACanvas, FHelperText,
        TMaxxRuralComponentFontInstaller.FontFamily, 0,
        LBorderRect.Bottom + ScaleMetric(18), 11, LSupportColor, False,
        ADest.Width);
    if FCounterText.Trim <> '' then
    begin
      LCounterWidth := FRenderer.MeasureText(FCounterText,
        TMaxxRuralComponentFontInstaller.FontFamily, 11);
      FRenderer.Text(ACanvas, FCounterText,
        TMaxxRuralComponentFontInstaller.FontFamily,
        Max(0, ADest.Width - LCounterWidth),
        LBorderRect.Bottom + ScaleMetric(18), 11,
        TMaxxRuralComponentColors.ControlTextDisabledForSurface(LSurface),
        False, LCounterWidth);
    end;
  end;
end;

function TMaxxRuralEdit.HasLabel: Boolean;
begin
  Result := FLabelText.Trim <> '';
end;

function TMaxxRuralEdit.HasSupportText: Boolean;
begin
  Result := (FHelperText.Trim <> '') or (FCounterText.Trim <> '');
end;

function TMaxxRuralEdit.InputFontSize: Integer;
begin
  case FInputSize of
    misSmall:
      Result := 9;
    misLarge:
      Result := 12;
  else
    Result := 10;
  end;
end;

function TMaxxRuralEdit.ChromeTop: Integer;
begin
  Result := 0;
  if HasLabel then
    Result := ScaleMetric(24);
end;

function TMaxxRuralEdit.ParentSurfaceColor: TAlphaColor;
begin
  Result := TMaxxRuralComponentColors.ResolveParentSurface(Self);
end;

procedure TMaxxRuralEdit.Redraw;
begin
  UpdatePaintBoxBounds;
  if (FPaintBox <> nil) and HandleAllocated then
    FPaintBox.Redraw;
end;

procedure TMaxxRuralEdit.Resize;
begin
  inherited;
  UpdatePaintBoxBounds;
  UpdateZOrder;
  UpdateChildBounds;
  Redraw;
end;

function TMaxxRuralEdit.ScaleFactor: Single;
begin
  Result := 1;
  if FPaintBox <> nil then
    Result := FPaintBox.ScaleFactor;
  if Result <= 0 then
    Result := 1;
end;

function TMaxxRuralEdit.ScaleMetric(const AValue: Integer): Integer;
begin
  Result := Round(AValue * ScaleFactor);
  if (AValue > 0) and (Result < 1) then
    Result := 1;
end;

procedure TMaxxRuralEdit.SetCharCase(const AValue: TEditCharCase);
begin
  FEdit.CharCase := AValue;
end;

procedure TMaxxRuralEdit.SetCornerRadius(const AValue: Integer);
begin
  if FCornerRadius = AValue then
    Exit;
  FCornerRadius := Max(0, AValue);
  InvalidateChrome;
end;

procedure TMaxxRuralEdit.SetCounterText(const AValue: string);
var
  LHadSupport: Boolean;
begin
  if FCounterText = AValue then
    Exit;

  LHadSupport := HasSupportText;
  FCounterText := AValue;
  if (not LHadSupport) and HasSupportText and (Height <= ChromeTop + ControlHeight) then
    Height := ChromeTop + ControlHeight + ScaleMetric(24);
  InvalidateChrome;
end;

procedure TMaxxRuralEdit.SetEditKind(const AValue: TMaxxRuralEditKind);
begin
  if FEditKind = AValue then
    Exit;
  FEditKind := AValue;
  UpdateEditStyle;
  InvalidateChrome;
end;

procedure TMaxxRuralEdit.SetEditMask(const AValue: string);
begin
  if FEditMask = AValue then
    Exit;
  FEditMask := AValue;
  UpdateEditStyle;
end;

procedure TMaxxRuralEdit.SetHelperText(const AValue: string);
var
  LHadSupport: Boolean;
begin
  if FHelperText = AValue then
    Exit;

  LHadSupport := HasSupportText;
  FHelperText := AValue;
  if (not LHadSupport) and HasSupportText and (Height <= ChromeTop + ControlHeight) then
    Height := ChromeTop + ControlHeight + ScaleMetric(24);
  InvalidateChrome;
end;

procedure TMaxxRuralEdit.SetInputSize(const AValue: TMaxxRuralInputSize);
begin
  if FInputSize = AValue then
    Exit;

  FInputSize := AValue;
  if not HasLabel and not HasSupportText then
    Height := ControlHeight
  else
    Height := ChromeTop + ControlHeight + IfThen(HasSupportText, ScaleMetric(24), 0);
  UpdateEditStyle;
  InvalidateChrome;
end;

procedure TMaxxRuralEdit.SetLabelText(const AValue: string);
var
  LHadLabel: Boolean;
begin
  if FLabelText = AValue then
    Exit;

  LHadLabel := HasLabel;
  FLabelText := AValue;
  if (not LHadLabel) and HasLabel and (Height <= ControlHeight) then
    Height := ChromeTop + ControlHeight + IfThen(HasSupportText, ScaleMetric(24), 0);
  InvalidateChrome;
end;

procedure TMaxxRuralEdit.SetFocus;
begin
  if (FEdit <> nil) and FEdit.CanFocus then
    FEdit.SetFocus
  else
    inherited;
end;

procedure TMaxxRuralEdit.SetMaxLength(const AValue: Integer);
begin
  FEdit.MaxLength := Max(0, AValue);
end;

procedure TMaxxRuralEdit.SetPasswordChar(const AValue: Char);
begin
  FEdit.PasswordChar := AValue;
end;

procedure TMaxxRuralEdit.SetPlaceholder(const AValue: string);
begin
  if FPlaceholder = AValue then
    Exit;
  FPlaceholder := AValue;
  FEdit.TextHint := FPlaceholder;
end;

procedure TMaxxRuralEdit.SetReadOnly(const AValue: Boolean);
begin
  if FEdit.ReadOnly = AValue then
    Exit;
  FEdit.ReadOnly := AValue;
  UpdateEditStyle;
end;

procedure TMaxxRuralEdit.SetRequired(const AValue: Boolean);
begin
  if FRequired = AValue then
    Exit;
  FRequired := AValue;
  InvalidateChrome;
end;

procedure TMaxxRuralEdit.SetStatus(const AValue: TMaxxRuralEditStatus);
begin
  if FStatus = AValue then
    Exit;
  FStatus := AValue;
  Redraw;
end;

procedure TMaxxRuralEdit.SetText(const AValue: string);
begin
  FEdit.Text := AValue;
end;

procedure TMaxxRuralEdit.SetVariant(const AValue: TMaxxRuralInputVariant);
begin
  if FVariant = AValue then
    Exit;

  FVariant := AValue;
  UpdateEditStyle;
  InvalidateChrome;
end;

function TMaxxRuralEdit.SupportTextColor(const ASurface: TAlphaColor): TAlphaColor;
begin
  case FStatus of
    mesSuccess:
      Result := TMaxxRuralComponentColors.PrimaryDark;
    mesWarning:
      Result := TMaxxRuralComponentColors.WarningDark;
    mesDanger:
      Result := TMaxxRuralComponentColors.Danger;
  else
    Result := TMaxxRuralComponentColors.ControlTextDisabledForSurface(ASurface);
  end;
end;

procedure TMaxxRuralEdit.UpdateChildBounds;
var
  LHorizontalPadding: Integer;
  LInputHeight: Integer;
  LRightPadding: Integer;
  LTextHeight: Integer;
  LTop: Integer;
begin
  if FEdit = nil then
    Exit;

  LHorizontalPadding := ScaleMetric(12);
  LRightPadding := LHorizontalPadding;
  if HasRightIcon then
    LRightPadding := ScaleMetric(38);
  LInputHeight := Min(ControlHeight, Max(0, Height - ChromeTop));
  LTextHeight := ScaleMetric(22);
  LTop := ChromeTop + Max(0, (LInputHeight - LTextHeight) div 2);
  FEdit.SetBounds(LHorizontalPadding, LTop,
    Max(0, Width - LHorizontalPadding - LRightPadding), LTextHeight);
end;

procedure TMaxxRuralEdit.UpdatePaintBoxBounds;
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

procedure TMaxxRuralEdit.UpdateZOrder;
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
  if FEdit <> nil then
    FEdit.BringToFront;
end;

procedure TMaxxRuralEdit.UpdateEditStyle;
var
  LSurface: TAlphaColor;
  LTextColor: TColor;
begin
  if FEdit = nil then
    Exit;

  LSurface := ParentSurfaceColor;
  FEdit.Enabled := Enabled;
  if FVariant = mivUnderlined then
    FEdit.Color := TMaxxRuralComponentColors.ToVclColor(LSurface)
  else
    FEdit.Color := TMaxxRuralComponentColors.ToVclColor(
      TMaxxRuralComponentColors.ControlBackgroundForSurface(LSurface));
  if not Enabled then
    FEdit.Color := TMaxxRuralComponentColors.ToVclColor(
      TMaxxRuralComponentColors.ControlBackgroundDisabledForSurface(LSurface));
  FEdit.Font.Name := TMaxxRuralComponentFontInstaller.FontFamily;
  FEdit.Font.Size := InputFontSize;
  FEdit.Font.Style := [];
  LTextColor := TMaxxRuralComponentColors.ToVclColor(
    TMaxxRuralComponentColors.ControlTextForSurface(LSurface));
  if not Enabled then
    LTextColor := TMaxxRuralComponentColors.ToVclColor(
      TMaxxRuralComponentColors.ControlTextDisabledForSurface(LSurface));
  FEdit.Font.Color := LTextColor;
  FEdit.TextHint := FPlaceholder;
  if FEditKind in [mekMasked, mekNumeric, mekDate, mekTime] then
    FEdit.EditMask := EffectiveEditMask
  else
    FEdit.EditMask := '';
  FEdit.PasswordChar := GetEffectivePasswordChar;
  Cursor := crIBeam;
  FPaintBox.Cursor := crIBeam;
  FEdit.Cursor := crIBeam;
  if not Enabled then
  begin
    Cursor := crDefault;
    FPaintBox.Cursor := crDefault;
    FEdit.Cursor := crDefault;
  end;
end;

procedure TMaxxRuralEdit.WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
begin
  AMessage.Result := 1;
end;

end.
