unit DAC.Components.Controls.DateTimePicker;

interface

uses
  System.Classes,
  System.Skia,
  System.SysUtils,
  System.Types,
  System.UITypes,
  Winapi.Messages,
  Vcl.ComCtrls,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.Skia,
  DAC.Components.Controls.Edit,
  DAC.Components.DesignSystem.IconAssets,
  DAC.Components.Skia.BackgroundPainter,
  DAC.Components.Skia.BorderPainter,
  DAC.Components.Skia.IconPainter,
  DAC.Components.Skia.Renderer;

type
  TDACDateTimePicker = class(TCustomControl)
  private
    FBackgroundPainter: TDACSkiaBackgroundPainter;
    FBorderPainter: TDACSkiaBorderPainter;
    FCornerRadius: Integer;
    FIconPainter: TDACSkiaIconPainter;
    FLabelText: string;
    FMouseInside: Boolean;
    FOnChange: TNotifyEvent;
    FPaintBox: TSkPaintBox;
    FPicker: TDateTimePicker;
    FRenderer: TDACSkiaRenderer;
    FRequired: Boolean;
    FStatus: TDACEditStatus;
    function BorderAlpha: Byte;
    function BorderColor: TAlphaColor;
    procedure CMEnabledChanged(var AMessage: TMessage); message CM_ENABLEDCHANGED;
    procedure CMParentColorChanged(var AMessage: TMessage); message CM_PARENTCOLORCHANGED;
    function ChromeTop: Integer;
    procedure DoPickerChange(Sender: TObject);
    procedure DoPickerEnter(Sender: TObject);
    procedure DoPickerExit(Sender: TObject);
    procedure DoMouseEnter(Sender: TObject);
    procedure DoMouseLeave(Sender: TObject);
    function GetDateTime: TDateTime;
    function GetFormatString: string;
    function GetPickerKind: TDateTimeKind;
    function HasLabel: Boolean;
    procedure PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    function ParentSurfaceColor: TAlphaColor;
    function ScaleFactor: Single;
    function ScaleMetric(const AValue: Integer): Integer;
    procedure SetCornerRadius(const AValue: Integer);
    procedure SetDateTime(const AValue: TDateTime);
    procedure SetFormatString(const AValue: string);
    procedure SetLabelText(const AValue: string);
    procedure SetPickerKind(const AValue: TDateTimeKind);
    procedure SetRequired(const AValue: Boolean);
    procedure SetStatus(const AValue: TDACEditStatus);
    procedure UpdateChildBounds;
    procedure UpdatePaintBoxBounds;
    procedure UpdatePickerStyle;
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
    property PickerControl: TDateTimePicker read FPicker;
  published
    property Align;
    property Anchors;
    property Constraints;
    property CornerRadius: Integer read FCornerRadius write SetCornerRadius default 8;
    property DateTime: TDateTime read GetDateTime write SetDateTime;
    property Enabled;
    property Font;
    property FormatString: string read GetFormatString write SetFormatString;
    property LabelText: string read FLabelText write SetLabelText;
    property ParentFont;
    property ParentShowHint;
    property PickerKind: TDateTimeKind read GetPickerKind write SetPickerKind default dtkDate;
    property PopupMenu;
    property Required: Boolean read FRequired write SetRequired default False;
    property ShowHint;
    property Status: TDACEditStatus read FStatus write SetStatus default mesNormal;
    property TabOrder;
    property TabStop default True;
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
  System.Math,
  Winapi.Windows,
  DAC.Components.DesignSystem.ColorTokens,
  DAC.Components.DesignSystem.Fonts;

constructor TDACDateTimePicker.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque, csClickEvents, csCaptureMouse];
  Width := 220;
  Height := 60;
  TabStop := True;
  ParentColor := False;
  StyleElements := [];
  Cursor := crDefault;
  Color := clWhite;
  FCornerRadius := 8;
  FStatus := mesNormal;

  FRenderer := TDACSkiaRenderer.Create;
  FBackgroundPainter := TDACSkiaBackgroundPainter.Create(FRenderer);
  FBorderPainter := TDACSkiaBorderPainter.Create(FRenderer);
  FIconPainter := TDACSkiaIconPainter.Create(FRenderer);

  FPicker := TDateTimePicker.Create(Self);
  FPicker.Parent := Self;
  FPicker.DateTime := EncodeDate(2025, 5, 24) + EncodeTime(14, 35, 0, 0);
  FPicker.Kind := dtkDate;
  FPicker.StyleElements := [];
  FPicker.TabStop := True;
  FPicker.OnChange := DoPickerChange;
  FPicker.OnEnter := DoPickerEnter;
  FPicker.OnExit := DoPickerExit;
  FPicker.OnMouseEnter := DoMouseEnter;
  FPicker.OnMouseLeave := DoMouseLeave;

  FPaintBox := TSkPaintBox.Create(Self);
  FPaintBox.Parent := Self;
  FPaintBox.SetSubComponent(True);
  FPaintBox.StyleElements := [];
  FPaintBox.OnDraw := PaintBoxDraw;
  FPaintBox.OnMouseEnter := DoMouseEnter;
  FPaintBox.OnMouseLeave := DoMouseLeave;

  UpdatePaintBoxBounds;
  UpdateChildBounds;
  UpdatePickerStyle;
end;

destructor TDACDateTimePicker.Destroy;
begin
  FPaintBox.Free;
  FPicker.Free;
  FIconPainter.Free;
  FBorderPainter.Free;
  FBackgroundPainter.Free;
  FRenderer.Free;
  inherited;
end;

function TDACDateTimePicker.BorderAlpha: Byte;
begin
  Result := 180;
  if FPicker.Focused or FMouseInside then
    Result := 255;
  if not Enabled then
    Result := 100;
end;

function TDACDateTimePicker.BorderColor: TAlphaColor;
var
  LSurface: TAlphaColor;
begin
  LSurface := ParentSurfaceColor;
  case FStatus of
    mesSuccess:
      Result := TDACComponentColors.PrimaryDark;
    mesWarning:
      Result := TDACComponentColors.Warning;
    mesDanger:
      Result := TDACComponentColors.Danger;
  else
    if FPicker.Focused then
      Result := TDACComponentColors.Primary
    else if FMouseInside then
      Result := TDACComponentColors.ControlBorderHoverForSurface(LSurface)
    else
      Result := TDACComponentColors.ControlBorderForSurface(LSurface);
  end;
end;

procedure TDACDateTimePicker.ChangeScale(M, D: Integer);
begin
  inherited;
  UpdatePaintBoxBounds;
  UpdateChildBounds;
  Redraw;
end;

function TDACDateTimePicker.ChromeTop: Integer;
begin
  Result := 0;
  if HasLabel then
    Result := ScaleMetric(22);
end;

procedure TDACDateTimePicker.CMEnabledChanged(var AMessage: TMessage);
begin
  inherited;
  UpdatePickerStyle;
  Redraw;
end;

procedure TDACDateTimePicker.CMParentColorChanged(var AMessage: TMessage);
begin
  inherited;
  UpdatePickerStyle;
  Redraw;
end;

procedure TDACDateTimePicker.CreateWnd;
begin
  inherited;
  UpdateZOrder;
  UpdatePaintBoxBounds;
  UpdateChildBounds;
  UpdatePickerStyle;
  Redraw;
end;

procedure TDACDateTimePicker.DoMouseEnter(Sender: TObject);
begin
  if FMouseInside then
    Exit;
  FMouseInside := True;
  Redraw;
  if Assigned(OnMouseEnter) then
    OnMouseEnter(Self);
end;

procedure TDACDateTimePicker.DoMouseLeave(Sender: TObject);
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

procedure TDACDateTimePicker.DoPickerChange(Sender: TObject);
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TDACDateTimePicker.DoPickerEnter(Sender: TObject);
begin
  Redraw;
  if Assigned(OnEnter) then
    OnEnter(Self);
end;

procedure TDACDateTimePicker.DoPickerExit(Sender: TObject);
begin
  Redraw;
  if Assigned(OnExit) then
    OnExit(Self);
end;

function TDACDateTimePicker.GetDateTime: TDateTime;
begin
  Result := FPicker.DateTime;
end;

function TDACDateTimePicker.GetFormatString: string;
begin
  Result := FPicker.Format;
end;

function TDACDateTimePicker.GetPickerKind: TDateTimeKind;
begin
  Result := FPicker.Kind;
end;

function TDACDateTimePicker.HasLabel: Boolean;
begin
  Result := FLabelText.Trim <> '';
end;

procedure TDACDateTimePicker.Loaded;
begin
  inherited;
  UpdatePaintBoxBounds;
  UpdateZOrder;
  UpdateChildBounds;
  UpdatePickerStyle;
  Redraw;
end;

procedure TDACDateTimePicker.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  if (Button = mbLeft) and Enabled and (FPicker <> nil) and FPicker.CanFocus then
    FPicker.SetFocus;
end;

procedure TDACDateTimePicker.PaintBoxDraw(Sender: TObject;
  const ACanvas: ISkCanvas; const ADest: TRectF; const AOpacity: Single);
var
  LBackground: TDACBackgroundStyle;
  LBorder: TDACBorderStyle;
  LBorderRect: TRectF;
  LIconRect: TRectF;
  LIconStyle: TDACIconStyle;
  LLabelColor: TAlphaColor;
  LRect: TRectF;
  LScale: Single;
  LSurface: TAlphaColor;
  LTop: Single;
begin
  if (ACanvas = nil) or (ADest.Width <= 0) or (ADest.Height <= 0) then
    Exit;

  LScale := ScaleFactor;
  LTop := ChromeTop;
  LBorderRect := FRenderer.SnapRect(TRectF.Create(0, LTop, ADest.Width,
    ADest.Height), LScale);
  LRect := LBorderRect;
  LRect.Inflate(-0.5 / LScale, -0.5 / LScale);

  LSurface := ParentSurfaceColor;
  ACanvas.Clear(LSurface);

  if HasLabel then
  begin
    LLabelColor := TDACComponentColors.ControlTextForSurface(LSurface);
    if FRequired then
      LLabelColor := TDACComponentColors.PrimaryDark;
    FRenderer.Text(ACanvas, FLabelText,
      TDACComponentFontInstaller.FontFamily, 0,
      ScaleMetric(14), 11, LLabelColor, FRequired, ADest.Width);
  end;

  LBackground.Color := TDACComponentColors.ControlBackgroundForSurface(LSurface);
  if not Enabled then
    LBackground.Color := TDACComponentColors.ControlBackgroundDisabledForSurface(LSurface);
  LBackground.Radius := FCornerRadius;
  LBackground.Alpha := 255;
  FBackgroundPainter.Draw(ACanvas, LRect, LBackground);

  LBorder.Color := BorderColor;
  LBorder.Radius := FCornerRadius;
  LBorder.Width := 1;
  if FPicker.Focused then
    LBorder.Width := 1.5;
  LBorder.Alpha := BorderAlpha;
  FBorderPainter.Draw(ACanvas, LBorderRect, LBorder);

  LIconRect := TRectF.Create(ADest.Width - ScaleMetric(30),
    LRect.Top + (LRect.Height - ScaleMetric(16)) / 2,
    ADest.Width - ScaleMetric(14),
    LRect.Top + (LRect.Height + ScaleMetric(16)) / 2);
  LIconStyle.Color := TDACComponentColors.ControlBorderHoverForSurface(LSurface);
  LIconStyle.Alpha := 255;
  if not Enabled then
    LIconStyle.Color := TDACComponentColors.ControlTextDisabledForSurface(LSurface);
  if FPicker.Kind = dtkTime then
    FIconPainter.Draw(ACanvas, LIconRect, mikClock, LIconStyle)
  else
    FIconPainter.Draw(ACanvas, LIconRect, mikCalendar, LIconStyle);
end;

function TDACDateTimePicker.ParentSurfaceColor: TAlphaColor;
begin
  Result := TDACComponentColors.ResolveParentSurface(Self);
end;

procedure TDACDateTimePicker.Redraw;
begin
  UpdatePaintBoxBounds;
  if (FPaintBox <> nil) and HandleAllocated then
    FPaintBox.Redraw;
end;

procedure TDACDateTimePicker.Resize;
begin
  inherited;
  UpdatePaintBoxBounds;
  UpdateZOrder;
  UpdateChildBounds;
  Redraw;
end;

function TDACDateTimePicker.ScaleFactor: Single;
begin
  Result := 1;
  if FPaintBox <> nil then
    Result := FPaintBox.ScaleFactor;
  if Result <= 0 then
    Result := 1;
end;

function TDACDateTimePicker.ScaleMetric(const AValue: Integer): Integer;
begin
  Result := Round(AValue * ScaleFactor);
  if (AValue > 0) and (Result < 1) then
    Result := 1;
end;

procedure TDACDateTimePicker.SetCornerRadius(const AValue: Integer);
begin
  if FCornerRadius = AValue then
    Exit;
  FCornerRadius := Max(0, AValue);
  Redraw;
end;

procedure TDACDateTimePicker.SetDateTime(const AValue: TDateTime);
begin
  if SameValue(FPicker.DateTime, AValue) then
    Exit;
  FPicker.DateTime := AValue;
end;

procedure TDACDateTimePicker.SetFocus;
begin
  if (FPicker <> nil) and FPicker.CanFocus then
    FPicker.SetFocus
  else
    inherited;
end;

procedure TDACDateTimePicker.SetFormatString(const AValue: string);
begin
  if FPicker.Format = AValue then
    Exit;
  FPicker.Format := AValue;
  UpdatePickerStyle;
end;

procedure TDACDateTimePicker.SetLabelText(const AValue: string);
var
  LHadLabel: Boolean;
begin
  if FLabelText = AValue then
    Exit;

  LHadLabel := HasLabel;
  FLabelText := AValue;
  if (not LHadLabel) and HasLabel and (Height <= ScaleMetric(38)) then
    Height := ScaleMetric(60);
  Redraw;
end;

procedure TDACDateTimePicker.SetPickerKind(const AValue: TDateTimeKind);
begin
  if FPicker.Kind = AValue then
    Exit;
  FPicker.Kind := AValue;
  UpdatePickerStyle;
  Redraw;
end;

procedure TDACDateTimePicker.SetRequired(const AValue: Boolean);
begin
  if FRequired = AValue then
    Exit;
  FRequired := AValue;
  Redraw;
end;

procedure TDACDateTimePicker.SetStatus(const AValue: TDACEditStatus);
begin
  if FStatus = AValue then
    Exit;
  FStatus := AValue;
  Redraw;
end;

procedure TDACDateTimePicker.UpdateChildBounds;
var
  LHorizontalPadding: Integer;
  LRightPadding: Integer;
  LTop: Integer;
begin
  if FPicker = nil then
    Exit;

  LHorizontalPadding := ScaleMetric(12);
  LRightPadding := ScaleMetric(38);
  LTop := ChromeTop + Max(0, (Height - ChromeTop - ScaleMetric(22)) div 2);
  FPicker.SetBounds(LHorizontalPadding, LTop,
    Max(0, Width - LHorizontalPadding - LRightPadding), ScaleMetric(22));
end;

procedure TDACDateTimePicker.UpdatePaintBoxBounds;
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

procedure TDACDateTimePicker.UpdatePickerStyle;
var
  LSurface: TAlphaColor;
  LTextColor: TColor;
begin
  if FPicker = nil then
    Exit;

  LSurface := ParentSurfaceColor;
  FPicker.Enabled := Enabled;
  FPicker.Color := TDACComponentColors.ToVclColor(
    TDACComponentColors.ControlBackgroundForSurface(LSurface));
  if not Enabled then
    FPicker.Color := TDACComponentColors.ToVclColor(
      TDACComponentColors.ControlBackgroundDisabledForSurface(LSurface));
  FPicker.Font.Name := TDACComponentFontInstaller.FontFamily;
  FPicker.Font.Size := 10;
  FPicker.Font.Style := [];
  LTextColor := TDACComponentColors.ToVclColor(
    TDACComponentColors.ControlTextForSurface(LSurface));
  if not Enabled then
    LTextColor := TDACComponentColors.ToVclColor(
      TDACComponentColors.ControlTextDisabledForSurface(LSurface));
  FPicker.Font.Color := LTextColor;
  Cursor := crDefault;
  FPaintBox.Cursor := crDefault;
  FPicker.Cursor := crDefault;
end;

procedure TDACDateTimePicker.UpdateZOrder;
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
  if FPicker <> nil then
    FPicker.BringToFront;
end;

procedure TDACDateTimePicker.WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
begin
  AMessage.Result := 1;
end;

end.

