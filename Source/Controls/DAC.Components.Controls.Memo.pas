unit DAC.Components.Controls.Memo;

interface

uses
  System.Classes,
  System.Skia,
  System.Types,
  System.UITypes,
  System.SysUtils,
  Winapi.Messages,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Graphics,
  Vcl.Skia,
  Vcl.StdCtrls,
  DAC.Components.Controls.Edit,
  DAC.Components.DesignSystem.Fonts,
  DAC.Components.Skia.BackgroundPainter,
  DAC.Components.Skia.BorderPainter,
  DAC.Components.Skia.Renderer;

type
  TDACMemo = class(TCustomControl)
  private
    FBackgroundPainter: TDACSkiaBackgroundPainter;
    FBorderPainter: TDACSkiaBorderPainter;
    FCornerRadius: Integer;
    FLabelText: string;
    FMemo: TMemo;
    FMouseInside: Boolean;
    FOnChange: TNotifyEvent;
    FPaintBox: TSkPaintBox;
    FRenderer: TDACSkiaRenderer;
    FRequired: Boolean;
    FStatus: TDACEditStatus;
    function BorderAlpha: Byte;
    function BorderColor: TAlphaColor;
    procedure CMEnabledChanged(var AMessage: TMessage); message CM_ENABLEDCHANGED;
    procedure CMParentColorChanged(var AMessage: TMessage); message CM_PARENTCOLORCHANGED;
    procedure DoMemoChange(Sender: TObject);
    procedure DoMemoEnter(Sender: TObject);
    procedure DoMemoExit(Sender: TObject);
    procedure DoMouseEnter(Sender: TObject);
    procedure DoMouseLeave(Sender: TObject);
    function GetLines: TStrings;
    function GetReadOnly: Boolean;
    function GetScrollBars: System.UITypes.TScrollStyle;
    function GetText: string;
    function GetWordWrap: Boolean;
    function HasLabel: Boolean;
    function ChromeTop: Integer;
    procedure PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    function ParentSurfaceColor: TAlphaColor;
    function ScaleFactor: Single;
    function ScaleMetric(const AValue: Integer): Integer;
    procedure SetCornerRadius(const AValue: Integer);
    procedure SetLabelText(const AValue: string);
    procedure SetLines(const AValue: TStrings);
    procedure SetReadOnly(const AValue: Boolean);
    procedure SetScrollBars(const AValue: System.UITypes.TScrollStyle);
    procedure SetRequired(const AValue: Boolean);
    procedure SetStatus(const AValue: TDACEditStatus);
    procedure SetText(const AValue: string);
    procedure SetWordWrap(const AValue: Boolean);
    procedure UpdateChildBounds;
    procedure UpdateMemoStyle;
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
    property MemoControl: TMemo read FMemo;
  published
    property Align;
    property Anchors;
    property Constraints;
    property CornerRadius: Integer read FCornerRadius write SetCornerRadius default 8;
    property Enabled;
    property Font;
    property LabelText: string read FLabelText write SetLabelText;
    property Lines: TStrings read GetLines write SetLines;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ReadOnly: Boolean read GetReadOnly write SetReadOnly default False;
    property Required: Boolean read FRequired write SetRequired default False;
    property ScrollBars: System.UITypes.TScrollStyle read GetScrollBars write SetScrollBars default ssNone;
    property ShowHint;
    property Status: TDACEditStatus read FStatus write SetStatus default mesNormal;
    property TabOrder;
    property TabStop default True;
    property Text: string read GetText write SetText;
    property Visible;
    property WordWrap: Boolean read GetWordWrap write SetWordWrap default True;
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
  Winapi.Windows;

constructor TDACMemo.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque, csClickEvents, csCaptureMouse];
  Width := 220;
  Height := 88;
  TabStop := True;
  ParentColor := False;
  StyleElements := [];
  Cursor := crIBeam;
  Color := clWhite;
  FCornerRadius := 8;
  FStatus := mesNormal;

  FRenderer := TDACSkiaRenderer.Create;
  FBackgroundPainter := TDACSkiaBackgroundPainter.Create(FRenderer);
  FBorderPainter := TDACSkiaBorderPainter.Create(FRenderer);

  FPaintBox := TSkPaintBox.Create(Self);
  FPaintBox.Parent := Self;
  FPaintBox.SetSubComponent(True);
  FPaintBox.StyleElements := [];
  FPaintBox.Cursor := crIBeam;
  FPaintBox.OnDraw := PaintBoxDraw;
  FPaintBox.OnMouseEnter := DoMouseEnter;
  FPaintBox.OnMouseLeave := DoMouseLeave;

  FMemo := TMemo.Create(Self);
  FMemo.Parent := Self;
  FMemo.SetSubComponent(True);
  FMemo.BorderStyle := bsNone;
  FMemo.StyleElements := [];
  FMemo.ParentFont := False;
  FMemo.WordWrap := True;
  FMemo.OnChange := DoMemoChange;
  FMemo.OnEnter := DoMemoEnter;
  FMemo.OnExit := DoMemoExit;
  FMemo.OnMouseEnter := DoMouseEnter;
  FMemo.OnMouseLeave := DoMouseLeave;

  UpdateMemoStyle;
  Resize;
end;

destructor TDACMemo.Destroy;
begin
  FMemo.Free;
  FPaintBox.Free;
  FBorderPainter.Free;
  FBackgroundPainter.Free;
  FRenderer.Free;
  inherited;
end;

function TDACMemo.BorderAlpha: Byte;
begin
  if not Enabled then
    Result := 130
  else if FMemo.Focused then
    Result := 255
  else if FStatus <> mesNormal then
    Result := 215
  else if FMouseInside then
    Result := 210
  else
    Result := 185;
end;

function TDACMemo.BorderColor: TAlphaColor;
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
    if FMemo.Focused then
      Result := TDACComponentColors.Primary
    else if FMouseInside then
      Result := TDACComponentColors.ControlBorderHoverForSurface(LSurface)
    else
      Result := TDACComponentColors.ControlBorderForSurface(LSurface);
  end;
end;

procedure TDACMemo.ChangeScale(M, D: Integer);
begin
  inherited;
  UpdateChildBounds;
  Redraw;
end;

procedure TDACMemo.CMEnabledChanged(var AMessage: TMessage);
begin
  inherited;
  UpdateMemoStyle;
  Redraw;
end;

procedure TDACMemo.CMParentColorChanged(var AMessage: TMessage);
begin
  inherited;
  UpdateMemoStyle;
  Redraw;
end;

procedure TDACMemo.CreateWnd;
begin
  inherited;
  UpdateZOrder;
  UpdateChildBounds;
  UpdateMemoStyle;
  Redraw;
end;

procedure TDACMemo.DoMemoChange(Sender: TObject);
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TDACMemo.DoMemoEnter(Sender: TObject);
begin
  Redraw;
  if Assigned(OnEnter) then
    OnEnter(Self);
end;

procedure TDACMemo.DoMemoExit(Sender: TObject);
begin
  Redraw;
  if Assigned(OnExit) then
    OnExit(Self);
end;

procedure TDACMemo.DoMouseEnter(Sender: TObject);
begin
  if FMouseInside then
    Exit;
  FMouseInside := True;
  Redraw;
  if Assigned(OnMouseEnter) then
    OnMouseEnter(Self);
end;

procedure TDACMemo.DoMouseLeave(Sender: TObject);
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

procedure TDACMemo.Loaded;
begin
  inherited;
  UpdatePaintBoxBounds;
  UpdateZOrder;
  UpdateChildBounds;
  UpdateMemoStyle;
  Redraw;
end;

function TDACMemo.GetLines: TStrings;
begin
  Result := FMemo.Lines;
end;

function TDACMemo.GetReadOnly: Boolean;
begin
  Result := FMemo.ReadOnly;
end;

function TDACMemo.GetScrollBars: System.UITypes.TScrollStyle;
begin
  Result := FMemo.ScrollBars;
end;

function TDACMemo.GetText: string;
begin
  Result := FMemo.Text;
end;

function TDACMemo.GetWordWrap: Boolean;
begin
  Result := FMemo.WordWrap;
end;

function TDACMemo.HasLabel: Boolean;
begin
  Result := FLabelText.Trim <> '';
end;

function TDACMemo.ChromeTop: Integer;
begin
  Result := 0;
  if HasLabel then
    Result := ScaleMetric(24);
end;

procedure TDACMemo.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  if (Button = mbLeft) and Enabled and (FMemo <> nil) then
    FMemo.SetFocus;
end;

procedure TDACMemo.PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
  const ADest: TRectF; const AOpacity: Single);
var
  LBackground: TDACBackgroundStyle;
  LBorder: TDACBorderStyle;
  LBorderRect: TRectF;
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
      ScaleMetric(15), 12, LLabelColor, FRequired, ADest.Width);
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
  if FMemo.Focused then
    LBorder.Width := 1.5;
  LBorder.Alpha := BorderAlpha;
  FBorderPainter.Draw(ACanvas, LBorderRect, LBorder);
end;

function TDACMemo.ParentSurfaceColor: TAlphaColor;
begin
  Result := TDACComponentColors.ResolveParentSurface(Self);
end;

procedure TDACMemo.Redraw;
begin
  UpdatePaintBoxBounds;
  if (FPaintBox <> nil) and HandleAllocated then
    FPaintBox.Redraw;
end;

procedure TDACMemo.Resize;
begin
  inherited;
  UpdatePaintBoxBounds;
  UpdateZOrder;
  UpdateChildBounds;
  Redraw;
end;

function TDACMemo.ScaleFactor: Single;
begin
  Result := 1;
  if FPaintBox <> nil then
    Result := FPaintBox.ScaleFactor;
  if Result <= 0 then
    Result := 1;
end;

function TDACMemo.ScaleMetric(const AValue: Integer): Integer;
begin
  Result := Round(AValue * ScaleFactor);
  if (AValue > 0) and (Result < 1) then
    Result := 1;
end;

procedure TDACMemo.SetCornerRadius(const AValue: Integer);
begin
  if FCornerRadius = AValue then
    Exit;
  FCornerRadius := Max(0, AValue);
  Redraw;
end;

procedure TDACMemo.SetFocus;
begin
  if (FMemo <> nil) and FMemo.CanFocus then
    FMemo.SetFocus
  else
    inherited;
end;

procedure TDACMemo.SetLabelText(const AValue: string);
var
  LHadLabel: Boolean;
begin
  if FLabelText = AValue then
    Exit;

  LHadLabel := HasLabel;
  FLabelText := AValue;
  if (not LHadLabel) and HasLabel and (Height <= ScaleMetric(88)) then
    Height := ScaleMetric(112);
  UpdateChildBounds;
  Redraw;
end;

procedure TDACMemo.SetLines(const AValue: TStrings);
begin
  FMemo.Lines.Assign(AValue);
end;

procedure TDACMemo.SetReadOnly(const AValue: Boolean);
begin
  if FMemo.ReadOnly = AValue then
    Exit;
  FMemo.ReadOnly := AValue;
  UpdateMemoStyle;
end;

procedure TDACMemo.SetScrollBars(const AValue: System.UITypes.TScrollStyle);
begin
  FMemo.ScrollBars := AValue;
end;

procedure TDACMemo.SetRequired(const AValue: Boolean);
begin
  if FRequired = AValue then
    Exit;
  FRequired := AValue;
  Redraw;
end;

procedure TDACMemo.SetStatus(const AValue: TDACEditStatus);
begin
  if FStatus = AValue then
    Exit;
  FStatus := AValue;
  Redraw;
end;

procedure TDACMemo.SetText(const AValue: string);
begin
  FMemo.Text := AValue;
end;

procedure TDACMemo.SetWordWrap(const AValue: Boolean);
begin
  FMemo.WordWrap := AValue;
end;

procedure TDACMemo.UpdateChildBounds;
var
  LPadding: Integer;
  LTop: Integer;
begin
  if FMemo = nil then
    Exit;

  LPadding := ScaleMetric(8);
  LTop := ChromeTop + LPadding;
  FMemo.SetBounds(LPadding, LTop,
    Max(0, Width - (LPadding * 2)), Max(0, Height - LTop - LPadding));
end;

procedure TDACMemo.UpdatePaintBoxBounds;
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

procedure TDACMemo.UpdateZOrder;
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
  if FMemo <> nil then
    FMemo.BringToFront;
end;

procedure TDACMemo.UpdateMemoStyle;
var
  LSurface: TAlphaColor;
  LTextColor: TColor;
begin
  if FMemo = nil then
    Exit;

  LSurface := ParentSurfaceColor;
  FMemo.Enabled := Enabled;
  FMemo.Color := TDACComponentColors.ToVclColor(
    TDACComponentColors.ControlBackgroundForSurface(LSurface));
  if not Enabled then
    FMemo.Color := TDACComponentColors.ToVclColor(
      TDACComponentColors.ControlBackgroundDisabledForSurface(LSurface));
  FMemo.Font.Name := TDACComponentFontInstaller.FontFamily;
  FMemo.Font.Size := 10;
  FMemo.Font.Style := [];
  LTextColor := TDACComponentColors.ToVclColor(
    TDACComponentColors.ControlTextForSurface(LSurface));
  if not Enabled then
    LTextColor := TDACComponentColors.ToVclColor(
      TDACComponentColors.ControlTextDisabledForSurface(LSurface));
  FMemo.Font.Color := LTextColor;
  Cursor := crIBeam;
  FPaintBox.Cursor := crIBeam;
  FMemo.Cursor := crIBeam;
  if not Enabled then
  begin
    Cursor := crDefault;
    FPaintBox.Cursor := crDefault;
    FMemo.Cursor := crDefault;
  end;
end;

procedure TDACMemo.WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
begin
  AMessage.Result := 1;
end;

end.

