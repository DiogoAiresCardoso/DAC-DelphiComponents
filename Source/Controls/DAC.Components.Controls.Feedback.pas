unit DAC.Components.Controls.Feedback;

interface

uses
  System.Classes,
  System.Skia,
  System.Types,
  System.UITypes,
  Winapi.Messages,
  Vcl.Controls,
  Vcl.ExtCtrls,
  Vcl.Graphics,
  Vcl.Skia,
  DAC.Components.Controls.SystemText,
  DAC.Components.DesignSystem.SemanticColors,
  DAC.Components.DesignSystem.Theme,
  DAC.Components.Skia.Renderer;

type
  TDACFeedbackStatus = TDACSemanticStatus;

  TDACToast = class(TCustomControl)
  private
    FMessageText: string;
    FPaintBox: TSkPaintBox;
    FRenderer: TDACSkiaRenderer;
    FTextOverlay: TDACSystemTextOverlay;
    FStatus: TDACFeedbackStatus;
    FThemeMode: TDACThemeMode;
    FTitleText: string;
    procedure PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    procedure SetMessageText(const AValue: string);
    procedure SetStatus(const AValue: TDACFeedbackStatus);
    procedure SetThemeMode(const AValue: TDACThemeMode);
    procedure SetTitleText(const AValue: string);
    procedure UpdatePaintBoxBounds;
    procedure ThemeChanged(Sender: TObject);
    procedure WMEraseBkgnd(var AMessage: TWMEraseBkgnd); message WM_ERASEBKGND;
  protected
    procedure CreateWnd; override;
    procedure Loaded; override;
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ResolvedBackgroundColor: TAlphaColor;
    procedure Redraw;
  published
    property Align;
    property Anchors;
    property Constraints;
    property Enabled;
    property MessageText: string read FMessageText write SetMessageText;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property Status: TDACFeedbackStatus read FStatus write SetStatus default mssSuccess;
    property TabOrder;
    property TabStop default False;
    property TitleText: string read FTitleText write SetTitleText;
    property ThemeMode: TDACThemeMode read FThemeMode write SetThemeMode default dtmInherit;
    property Visible;
  end;

  TDACModalDialog = class(TDACToast)
  protected
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
  public
    constructor Create(AOwner: TComponent); override;
  end;

  TDACTooltip = class(TCustomControl)
  private
    FPaintBox: TSkPaintBox;
    FRenderer: TDACSkiaRenderer;
    FTextOverlay: TDACSystemTextOverlay;
    FTargetControl: TControl;
    FText: string;
    FThemeMode: TDACThemeMode;
    FTracker: TTimer;
    FManualVisible: Boolean;
    function MouseInControl(AControl: TControl): Boolean;
    procedure PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    procedure SetTargetControl(const AValue: TControl);
    procedure SetText(const AValue: string);
    procedure SetThemeMode(const AValue: TDACThemeMode);
    procedure ShowForTargetInternal(const AManual: Boolean);
    procedure TrackerTimer(Sender: TObject);
    procedure UpdatePaintBoxBounds;
    procedure ThemeChanged(Sender: TObject);
    procedure WMEraseBkgnd(var AMessage: TWMEraseBkgnd); message WM_ERASEBKGND;
  protected
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ResolvedBackgroundColor: TAlphaColor;
    procedure HideTooltip;
    procedure ShowForTarget;
  published
    property Align;
    property Anchors;
    property Constraints;
    property Enabled;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop default False;
    property TargetControl: TControl read FTargetControl write SetTargetControl;
    property Text: string read FText write SetText;
    property ThemeMode: TDACThemeMode read FThemeMode write SetThemeMode default dtmInherit;
    property Visible default False;
  end;

implementation

uses
  Winapi.Windows,
  DAC.Components.DesignSystem.ColorTokens,
  DAC.Components.DesignSystem.Fonts,
  DAC.Components.DesignSystem.ComponentStyle,
  DAC.Components.DesignSystem.ControlTokens;

function ToastBackground(const AStatus: TDACFeedbackStatus;
  const ATokens: TDACControlTokens): TAlphaColor;
begin
  case AStatus of
    mssWarning: Result := ATokens.ToastWarningBackground;
    mssDanger: Result := ATokens.ToastDangerBackground;
    mssInfo: Result := ATokens.ToastInfoBackground;
    mssNeutral: Result := ATokens.ToastNeutralBackground;
  else
    Result := ATokens.ToastSuccessBackground;
  end;
end;

function ToastBorder(const AStatus: TDACFeedbackStatus;
  const ATokens: TDACControlTokens): TAlphaColor;
begin
  case AStatus of
    mssWarning: Result := ATokens.ToastWarningBorder;
    mssDanger: Result := ATokens.ToastDangerBorder;
    mssInfo: Result := ATokens.ToastInfoBorder;
    mssNeutral: Result := ATokens.ToastNeutralBorder;
  else
    Result := ATokens.ToastSuccessBorder;
  end;
end;

constructor TDACToast.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  Width := Round(TDACComponentStyle.Resolve(dtmInherit).Tokens.Controls.ToastDefaultWidth);
  Height := Round(TDACComponentStyle.Resolve(dtmInherit).Tokens.Controls.ToastDefaultHeight);
  TabStop := False;
  ParentColor := False;
  StyleElements := [];
  FStatus := mssSuccess;
  FThemeMode := dtmInherit;
  TDACThemeManager.RegisterListener(Self, ThemeChanged);
  FTitleText := 'Operacao realizada';
  FMessageText := 'Mensagem de feedback.';
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

destructor TDACToast.Destroy;
begin
  TDACThemeManager.UnregisterListener(Self);
  FTextOverlay.Free;
  FPaintBox.Free;
  FRenderer.Free;
  inherited;
end;
procedure TDACToast.CreateWnd;
begin
  inherited;
  UpdatePaintBoxBounds;
  Redraw;
end;

procedure TDACToast.Loaded;
begin
  inherited;
  UpdatePaintBoxBounds;
  Redraw;
end;

procedure TDACToast.PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
  const ADest: TRectF; const AOpacity: Single);
var
  LPaint: ISkPaint;
  LRect: TRectF;
  LTokens: TDACControlTokens;
begin
  if ACanvas = nil then
    Exit;
  FRenderer.BeginNativeText(FTextOverlay);
  try
  LTokens := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls;
  LRect := TRectF.Create(LTokens.BorderWidth / 2, LTokens.BorderWidth / 2,
    ADest.Width - (LTokens.BorderWidth / 2), ADest.Height - (LTokens.BorderWidth / 2));
  FRenderer.FillRoundRect(ACanvas, LRect, ToastBackground(FStatus, LTokens),
    LTokens.ToastRadius, LTokens.AlphaOpaque);
  FRenderer.StrokeRoundRect(ACanvas, LRect, ToastBorder(FStatus, LTokens),
    LTokens.ToastRadius, LTokens.ToastBorderWidth, LTokens.ToastBorderAlpha);
  LPaint := TSkPaint.Create(TSkPaintStyle.Fill);
  LPaint.AntiAlias := True;
  LPaint.Color := LTokens.FeedbackText;
  ACanvas.DrawCircle(LTokens.ToastIndicatorX, ADest.Height / 2, LTokens.ToastIndicatorRadius, LPaint);
  FRenderer.Text(ACanvas, FTitleText, TDACComponentStyle.FontFamily,
    LTokens.ToastTitleX, LTokens.ToastTitleBaseline, LTokens.ToastTitleTextSize,
    LTokens.FeedbackText, True, ADest.Width - LTokens.ToastTextRightInset);
  FRenderer.Text(ACanvas, FMessageText, TDACComponentStyle.FontFamily,
    LTokens.ToastTitleX, LTokens.ToastMessageBaseline, LTokens.ToastMessageTextSize,
    LTokens.FeedbackText, False, ADest.Width - LTokens.ToastTextRightInset);
  finally
    FRenderer.EndNativeText;
  end;
end;

function TDACToast.ResolvedBackgroundColor: TAlphaColor;
begin
  Result := ToastBackground(FStatus, TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls);
end;

procedure TDACToast.Redraw;
begin
  if (FPaintBox <> nil) and not (csDestroying in ComponentState) and
    not (csDesigning in ComponentState) and (Parent <> nil) and
    HandleAllocated and Parent.HandleAllocated then
    FPaintBox.Redraw;
  if HandleAllocated then
    Invalidate;
end;

procedure TDACToast.Resize;
begin
  inherited;
  UpdatePaintBoxBounds;
  Redraw;
end;

procedure TDACToast.SetMessageText(const AValue: string);
begin
  if FMessageText = AValue then
    Exit;
  FMessageText := AValue;
  Redraw;
end;

procedure TDACToast.SetStatus(const AValue: TDACFeedbackStatus);
begin
  if FStatus = AValue then
    Exit;
  FStatus := AValue;
  Redraw;
end;

procedure TDACToast.SetThemeMode(const AValue: TDACThemeMode);
begin
  if FThemeMode = AValue then
    Exit;
  FThemeMode := AValue;
  ThemeChanged(Self);
end;

procedure TDACToast.ThemeChanged(Sender: TObject);
begin
  Redraw;
end;

procedure TDACToast.SetTitleText(const AValue: string);
begin
  if FTitleText = AValue then
    Exit;
  FTitleText := AValue;
  Redraw;
end;

procedure TDACToast.UpdatePaintBoxBounds;
begin
  if (FPaintBox = nil) or (csLoading in ComponentState) or
    (csDestroying in ComponentState) or (csDesigning in ComponentState) or
    (Parent = nil) or not HandleAllocated or not Parent.HandleAllocated then
    Exit;
  FPaintBox.SetBounds(0, 0, ClientWidth, ClientHeight);
end;

procedure TDACToast.WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
var
  LBrush: HBRUSH;
  LColor: TAlphaColor;
begin
  { Fill com cor de fundo para eliminar pixels fantasma em design-time. }
  LColor := ResolvedBackgroundColor;
  LBrush := CreateSolidBrush(ColorToRGB(
    TColor(((LColor and $00FF0000) shr 16) or
    (LColor and $0000FF00) or ((LColor and $000000FF) shl 16))));
  try
    Winapi.Windows.FillRect(AMessage.DC, ClientRect, LBrush);
  finally
    DeleteObject(LBrush);
  end;
  AMessage.Result := 1;
end;



constructor TDACModalDialog.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := Round(TDACComponentStyle.Resolve(dtmInherit).Tokens.Controls.ModalDefaultWidth);
  Height := Round(TDACComponentStyle.Resolve(dtmInherit).Tokens.Controls.ModalDefaultHeight);
  TitleText := 'Confirmacao';
  MessageText := 'Deseja confirmar esta operacao?';
end;

procedure TDACModalDialog.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited;
  if Key = VK_ESCAPE then
  begin
    Visible := False;
    Key := 0;
  end;
end;

constructor TDACTooltip.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  Width := Round(TDACComponentStyle.Resolve(dtmInherit).Tokens.Controls.TooltipDefaultWidth);
  Height := Round(TDACComponentStyle.Resolve(dtmInherit).Tokens.Controls.TooltipDefaultHeight);
  TabStop := False;
  ParentColor := False;
  StyleElements := [];
  FText := 'Informacao adicional';
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
  FTracker := TTimer.Create(Self);
  FTracker.Enabled := False;
  FTracker.Interval := 120;
  FTracker.OnTimer := TrackerTimer;
  Visible := False;
end;

destructor TDACTooltip.Destroy;
begin
  TDACThemeManager.UnregisterListener(Self);
  FTracker.Free;
  FTextOverlay.Free;
  FPaintBox.Free;
  FRenderer.Free;
  inherited;
end;
procedure TDACTooltip.HideTooltip;
begin
  FManualVisible := False;
  Visible := False;
end;

function TDACTooltip.MouseInControl(AControl: TControl): Boolean;
var
  LCursor: TPoint;
  LOrigin: TPoint;
begin
  Result := False;
  if (AControl = nil) or not AControl.Visible then
    Exit;
  GetCursorPos(LCursor);
  LOrigin := AControl.ClientToScreen(Point(0, 0));
  Result := PtInRect(Rect(LOrigin.X, LOrigin.Y, LOrigin.X + AControl.Width,
    LOrigin.Y + AControl.Height), LCursor);
end;

procedure TDACTooltip.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FTargetControl) then
  begin
    FTargetControl := nil;
    HideTooltip;
    FTracker.Enabled := False;
  end;
end;

procedure TDACTooltip.PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
  const ADest: TRectF; const AOpacity: Single);
var
  LRect: TRectF;
  LTokens: TDACControlTokens;
begin
  if ACanvas = nil then
    Exit;
  FRenderer.BeginNativeText(FTextOverlay);
  try
  LTokens := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls;
  ACanvas.Clear(LTokens.TransparentSurfaceFallback);
  LRect := TRectF.Create(LTokens.BorderWidth / 2, LTokens.BorderWidth / 2,
    ADest.Width - (LTokens.BorderWidth / 2), ADest.Height - (LTokens.BorderWidth / 2));
  FRenderer.FillRoundRect(ACanvas, LRect, LTokens.TooltipBackground,
    LTokens.TooltipRadius, LTokens.TooltipBackgroundAlpha);
  FRenderer.StrokeRoundRect(ACanvas, LRect, LTokens.TooltipBorder,
    LTokens.TooltipRadius, LTokens.TooltipBorderWidth, LTokens.TooltipBorderAlpha);
  FRenderer.TextCentered(ACanvas, FText, TDACComponentStyle.FontFamily,
    TRectF.Create(LTokens.TooltipTextInsetHorizontal, LTokens.TooltipTextInsetVertical,
      ADest.Width - LTokens.TooltipTextInsetHorizontal, ADest.Height - LTokens.TooltipTextInsetVertical),
    LTokens.TooltipTextSize, LTokens.TooltipText, False);
  finally
    FRenderer.EndNativeText;
  end;
end;

function TDACTooltip.ResolvedBackgroundColor: TAlphaColor;
begin
  Result := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls.TooltipBackground;
end;

procedure TDACTooltip.Resize;
begin
  inherited;
  UpdatePaintBoxBounds;
  if (FPaintBox <> nil) and not (csLoading in ComponentState) and
    not (csDestroying in ComponentState) and not (csDesigning in ComponentState) and
    (Parent <> nil) and HandleAllocated and Parent.HandleAllocated then
    FPaintBox.Redraw;
end;

procedure TDACTooltip.SetTargetControl(const AValue: TControl);
begin
  if FTargetControl = AValue then
    Exit;
  if FTargetControl <> nil then
    FTargetControl.RemoveFreeNotification(Self);
  FTargetControl := AValue;
  if FTargetControl <> nil then
    FTargetControl.FreeNotification(Self);
  FTracker.Enabled := (FTargetControl <> nil) and not (csDesigning in ComponentState);
  if FTargetControl = nil then
    HideTooltip;
end;

procedure TDACTooltip.SetText(const AValue: string);
begin
  if FText = AValue then
    Exit;
  FText := AValue;
  if (FPaintBox <> nil) and not (csLoading in ComponentState) and
    not (csDestroying in ComponentState) and not (csDesigning in ComponentState) and
    (Parent <> nil) and HandleAllocated and Parent.HandleAllocated then
    FPaintBox.Redraw;
end;

procedure TDACTooltip.SetThemeMode(const AValue: TDACThemeMode);
begin
  if FThemeMode = AValue then
    Exit;
  FThemeMode := AValue;
  ThemeChanged(Self);
end;

procedure TDACTooltip.ShowForTarget;
begin
  ShowForTargetInternal(True);
end;

procedure TDACTooltip.ShowForTargetInternal(const AManual: Boolean);
var
  LParent: TWinControl;
begin
  if (FTargetControl = nil) or (FTargetControl.Parent = nil) or
    (csLoading in ComponentState) or (csDestroying in ComponentState) or
    (csDesigning in ComponentState) then
    Exit;
  LParent := FTargetControl.Parent;
  if not LParent.HandleAllocated then
    Exit;
  if Parent <> LParent then
    Parent := LParent;
  if not HandleAllocated then
    HandleNeeded;
  if (Parent = nil) or not HandleAllocated or not Parent.HandleAllocated then
    Exit;
  SetBounds(FTargetControl.Left, FTargetControl.Top + FTargetControl.Height +
    Round(TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls.TooltipOffset),
    Width, Height);
  FManualVisible := AManual;
  Visible := True;
  BringToFront;
  UpdatePaintBoxBounds;
  if (FPaintBox <> nil) and not (csLoading in ComponentState) and
    not (csDestroying in ComponentState) and
    not (csDesigning in ComponentState) and (Parent <> nil) and
    HandleAllocated and Parent.HandleAllocated then
    FPaintBox.Redraw;
end;

procedure TDACTooltip.ThemeChanged(Sender: TObject);
begin
  if (FPaintBox <> nil) and not (csLoading in ComponentState) and
    not (csDestroying in ComponentState) and
    HandleAllocated and (Parent <> nil) and Parent.HandleAllocated and
    not (csDesigning in ComponentState) then
    FPaintBox.Redraw;
end;

procedure TDACTooltip.TrackerTimer(Sender: TObject);
begin
  if (FTargetControl = nil) or (csDestroying in ComponentState) then
  begin
    HideTooltip;
    Exit;
  end;
  if MouseInControl(FTargetControl) then
  begin
    if not Visible then
      ShowForTargetInternal(False);
  end
  else if Visible and not FManualVisible and not MouseInControl(Self) then
    HideTooltip;
end;

procedure TDACTooltip.UpdatePaintBoxBounds;
var
  LHeight: Integer;
  LWidth: Integer;
begin
  if (FPaintBox = nil) or (csLoading in ComponentState) or
    (csDestroying in ComponentState) or (csDesigning in ComponentState) or
    (Parent = nil) or not HandleAllocated or not Parent.HandleAllocated then
    Exit;
  LWidth := ClientWidth;
  LHeight := ClientHeight;
  FPaintBox.SetBounds(0, 0, LWidth, LHeight);
end;

procedure TDACTooltip.WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
var
  LBrush: HBRUSH;
  LColor: TAlphaColor;
begin
  LColor := ResolvedBackgroundColor;
  LBrush := CreateSolidBrush(ColorToRGB(
    TColor(((LColor and $00FF0000) shr 16) or
    (LColor and $0000FF00) or ((LColor and $000000FF) shl 16))));
  try
    Winapi.Windows.FillRect(AMessage.DC, ClientRect, LBrush);
  finally
    DeleteObject(LBrush);
  end;
  AMessage.Result := 1;
end;


end.


