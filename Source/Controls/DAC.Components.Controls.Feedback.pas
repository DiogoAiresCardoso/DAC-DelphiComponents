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
  DAC.Components.DesignSystem.SemanticColors,
  DAC.Components.Skia.Renderer;

type
  TDACFeedbackStatus = TDACSemanticStatus;

  TDACToast = class(TCustomControl)
  private
    FMessageText: string;
    FPaintBox: TSkPaintBox;
    FRenderer: TDACSkiaRenderer;
    FStatus: TDACFeedbackStatus;
    FTitleText: string;
    procedure PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    procedure SetMessageText(const AValue: string);
    procedure SetStatus(const AValue: TDACFeedbackStatus);
    procedure SetTitleText(const AValue: string);
    procedure UpdatePaintBoxBounds;
    procedure WMEraseBkgnd(var AMessage: TWMEraseBkgnd); message WM_ERASEBKGND;
  protected
    procedure ChangeScale(M, D: Integer); override;
    procedure CreateWnd; override;
    procedure Loaded; override;
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
    property MessageText: string read FMessageText write SetMessageText;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property Status: TDACFeedbackStatus read FStatus write SetStatus default mssSuccess;
    property TabOrder;
    property TabStop default False;
    property TitleText: string read FTitleText write SetTitleText;
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
    FTargetControl: TControl;
    FText: string;
    FTracker: TTimer;
    function MouseInControl(AControl: TControl): Boolean;
    procedure PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    procedure SetTargetControl(const AValue: TControl);
    procedure SetText(const AValue: string);
    procedure TrackerTimer(Sender: TObject);
    procedure UpdatePaintBoxBounds;
    procedure WMEraseBkgnd(var AMessage: TWMEraseBkgnd); message WM_ERASEBKGND;
  protected
    procedure ChangeScale(M, D: Integer); override;
    procedure Notification(AComponent: TComponent;
      Operation: TOperation); override;
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
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
    property Visible default False;
  end;

implementation

uses
  Winapi.Windows,
  DAC.Components.DesignSystem.ColorTokens,
  DAC.Components.DesignSystem.Fonts;

constructor TDACToast.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  Width := 260;
  Height := 72;
  TabStop := False;
  ParentColor := False;
  StyleElements := [];
  FStatus := mssSuccess;
  FTitleText := 'Operacao realizada';
  FMessageText := 'Mensagem de feedback.';
  FRenderer := TDACSkiaRenderer.Create;
  FPaintBox := TSkPaintBox.Create(Self);
  FPaintBox.Parent := Self;
  FPaintBox.SetSubComponent(True);
  FPaintBox.StyleElements := [];
  FPaintBox.OnDraw := PaintBoxDraw;
end;

destructor TDACToast.Destroy;
begin
  FPaintBox.Free;
  FRenderer.Free;
  inherited;
end;

procedure TDACToast.ChangeScale(M, D: Integer);
begin
  inherited;
  Redraw;
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
  LColors: TDACSemanticColorSet;
  LPaint: ISkPaint;
  LRect: TRectF;
begin
  LColors := TDACSemanticColors.ColorsFor(FStatus);
  LRect := TRectF.Create(0.5, 0.5, ADest.Width - 0.5, ADest.Height - 0.5);
  FRenderer.FillRoundRect(ACanvas, LRect, LColors.AccentDark, 8, 255);
  FRenderer.StrokeRoundRect(ACanvas, LRect, LColors.AccentLight, 8, 1, 150);
  LPaint := TSkPaint.Create(TSkPaintStyle.Fill);
  LPaint.AntiAlias := True;
  LPaint.Color := TDACComponentColors.White;
  ACanvas.DrawCircle(24, ADest.Height / 2, 9, LPaint);
  FRenderer.Text(ACanvas, FTitleText, TDACComponentFontInstaller.FontFamily,
    46, 30, 12, TDACComponentColors.White, True, ADest.Width - 58);
  FRenderer.Text(ACanvas, FMessageText, TDACComponentFontInstaller.FontFamily,
    46, 50, 11, TDACComponentColors.White, False, ADest.Width - 58);
end;

procedure TDACToast.Redraw;
begin
  if (FPaintBox <> nil) and not (csDestroying in ComponentState) and
    ((Parent <> nil) or not (csDesigning in ComponentState)) then
    FPaintBox.Redraw;
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

procedure TDACToast.SetTitleText(const AValue: string);
begin
  if FTitleText = AValue then
    Exit;
  FTitleText := AValue;
  Redraw;
end;

procedure TDACToast.UpdatePaintBoxBounds;
begin
  if FPaintBox <> nil then
    FPaintBox.SetBounds(0, 0, Width, Height);
end;

procedure TDACToast.WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
begin
  AMessage.Result := 1;
end;

constructor TDACModalDialog.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := 320;
  Height := 180;
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
  Width := 220;
  Height := 36;
  TabStop := False;
  ParentColor := False;
  StyleElements := [];
  FText := 'Informacao adicional';
  FRenderer := TDACSkiaRenderer.Create;
  FPaintBox := TSkPaintBox.Create(Self);
  FPaintBox.Parent := Self;
  FPaintBox.SetSubComponent(True);
  FPaintBox.StyleElements := [];
  FPaintBox.OnDraw := PaintBoxDraw;
  FTracker := TTimer.Create(Self);
  FTracker.Enabled := False;
  FTracker.Interval := 120;
  FTracker.OnTimer := TrackerTimer;
  Visible := False;
end;

destructor TDACTooltip.Destroy;
begin
  FTracker.Free;
  FPaintBox.Free;
  FRenderer.Free;
  inherited;
end;

procedure TDACTooltip.ChangeScale(M, D: Integer);
begin
  inherited;
  UpdatePaintBoxBounds;
  if FPaintBox <> nil then
    FPaintBox.Redraw;
end;

procedure TDACTooltip.HideTooltip;
begin
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
begin
  if ACanvas = nil then
    Exit;
  ACanvas.Clear(TDACComponentColors.Alpha(0, 0, 0, 0));
  LRect := TRectF.Create(0.5, 0.5, ADest.Width - 0.5, ADest.Height - 0.5);
  FRenderer.FillRoundRect(ACanvas, LRect,
    TDACComponentColors.Alpha(7, 19, 12), 6, 245);
  FRenderer.StrokeRoundRect(ACanvas, LRect,
    TDACComponentColors.Alpha(61, 184, 42), 6, 1, 190);
  FRenderer.TextCentered(ACanvas, FText, TDACComponentFontInstaller.FontFamily,
    TRectF.Create(10, 4, ADest.Width - 10, ADest.Height - 4), 10,
    TDACComponentColors.White, False);
end;

procedure TDACTooltip.Resize;
begin
  inherited;
  UpdatePaintBoxBounds;
  if FPaintBox <> nil then
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
  if FPaintBox <> nil then
    FPaintBox.Redraw;
end;

procedure TDACTooltip.ShowForTarget;
var
  LParent: TWinControl;
begin
  if (FTargetControl = nil) or (FTargetControl.Parent = nil) or
    (csDesigning in ComponentState) then
    Exit;
  LParent := FTargetControl.Parent;
  if Parent <> LParent then
    Parent := LParent;
  SetBounds(FTargetControl.Left, FTargetControl.Top + FTargetControl.Height + 4,
    Width, Height);
  Visible := True;
  if HandleAllocated and Parent.HandleAllocated then
    BringToFront;
  UpdatePaintBoxBounds;
  if HandleAllocated and Parent.HandleAllocated then
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
      ShowForTarget;
  end
  else if Visible and not MouseInControl(Self) then
    HideTooltip;
end;

procedure TDACTooltip.UpdatePaintBoxBounds;
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
  FPaintBox.SetBounds(0, 0, LWidth, LHeight);
end;

procedure TDACTooltip.WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
begin
  AMessage.Result := 1;
end;

end.

