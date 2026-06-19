unit MaxxRural.Components.Controls.Memo;

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
  MaxxRural.Components.Controls.Edit,
  MaxxRural.Components.DesignSystem.Fonts,
  MaxxRural.Components.Skia.BackgroundPainter,
  MaxxRural.Components.Skia.BorderPainter,
  MaxxRural.Components.Skia.Renderer;

type
  TMaxxRuralMemo = class(TCustomControl)
  private
    FBackgroundPainter: TMaxxRuralSkiaBackgroundPainter;
    FBorderPainter: TMaxxRuralSkiaBorderPainter;
    FCornerRadius: Integer;
    FLabelText: string;
    FMemo: TMemo;
    FMouseInside: Boolean;
    FOnChange: TNotifyEvent;
    FPaintBox: TSkPaintBox;
    FRenderer: TMaxxRuralSkiaRenderer;
    FRequired: Boolean;
    FStatus: TMaxxRuralEditStatus;
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
    procedure SetStatus(const AValue: TMaxxRuralEditStatus);
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
    property Status: TMaxxRuralEditStatus read FStatus write SetStatus default mesNormal;
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
  MaxxRural.Components.DesignSystem.ColorTokens,
  System.Math,
  Winapi.Windows;

constructor TMaxxRuralMemo.Create(AOwner: TComponent);
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

  FRenderer := TMaxxRuralSkiaRenderer.Create;
  FBackgroundPainter := TMaxxRuralSkiaBackgroundPainter.Create(FRenderer);
  FBorderPainter := TMaxxRuralSkiaBorderPainter.Create(FRenderer);

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

destructor TMaxxRuralMemo.Destroy;
begin
  FMemo.Free;
  FPaintBox.Free;
  FBorderPainter.Free;
  FBackgroundPainter.Free;
  FRenderer.Free;
  inherited;
end;

function TMaxxRuralMemo.BorderAlpha: Byte;
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

function TMaxxRuralMemo.BorderColor: TAlphaColor;
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
    if FMemo.Focused then
      Result := TMaxxRuralComponentColors.Primary
    else if FMouseInside then
      Result := TMaxxRuralComponentColors.ControlBorderHoverForSurface(LSurface)
    else
      Result := TMaxxRuralComponentColors.ControlBorderForSurface(LSurface);
  end;
end;

procedure TMaxxRuralMemo.ChangeScale(M, D: Integer);
begin
  inherited;
  UpdateChildBounds;
  Redraw;
end;

procedure TMaxxRuralMemo.CMEnabledChanged(var AMessage: TMessage);
begin
  inherited;
  UpdateMemoStyle;
  Redraw;
end;

procedure TMaxxRuralMemo.CMParentColorChanged(var AMessage: TMessage);
begin
  inherited;
  UpdateMemoStyle;
  Redraw;
end;

procedure TMaxxRuralMemo.CreateWnd;
begin
  inherited;
  UpdateZOrder;
  UpdateChildBounds;
  UpdateMemoStyle;
  Redraw;
end;

procedure TMaxxRuralMemo.DoMemoChange(Sender: TObject);
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TMaxxRuralMemo.DoMemoEnter(Sender: TObject);
begin
  Redraw;
  if Assigned(OnEnter) then
    OnEnter(Self);
end;

procedure TMaxxRuralMemo.DoMemoExit(Sender: TObject);
begin
  Redraw;
  if Assigned(OnExit) then
    OnExit(Self);
end;

procedure TMaxxRuralMemo.DoMouseEnter(Sender: TObject);
begin
  if FMouseInside then
    Exit;
  FMouseInside := True;
  Redraw;
  if Assigned(OnMouseEnter) then
    OnMouseEnter(Self);
end;

procedure TMaxxRuralMemo.DoMouseLeave(Sender: TObject);
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

procedure TMaxxRuralMemo.Loaded;
begin
  inherited;
  UpdatePaintBoxBounds;
  UpdateZOrder;
  UpdateChildBounds;
  UpdateMemoStyle;
  Redraw;
end;

function TMaxxRuralMemo.GetLines: TStrings;
begin
  Result := FMemo.Lines;
end;

function TMaxxRuralMemo.GetReadOnly: Boolean;
begin
  Result := FMemo.ReadOnly;
end;

function TMaxxRuralMemo.GetScrollBars: System.UITypes.TScrollStyle;
begin
  Result := FMemo.ScrollBars;
end;

function TMaxxRuralMemo.GetText: string;
begin
  Result := FMemo.Text;
end;

function TMaxxRuralMemo.GetWordWrap: Boolean;
begin
  Result := FMemo.WordWrap;
end;

function TMaxxRuralMemo.HasLabel: Boolean;
begin
  Result := FLabelText.Trim <> '';
end;

function TMaxxRuralMemo.ChromeTop: Integer;
begin
  Result := 0;
  if HasLabel then
    Result := ScaleMetric(24);
end;

procedure TMaxxRuralMemo.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  if (Button = mbLeft) and Enabled and (FMemo <> nil) then
    FMemo.SetFocus;
end;

procedure TMaxxRuralMemo.PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
  const ADest: TRectF; const AOpacity: Single);
var
  LBackground: TMaxxRuralBackgroundStyle;
  LBorder: TMaxxRuralBorderStyle;
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
    LLabelColor := TMaxxRuralComponentColors.ControlTextForSurface(LSurface);
    if FRequired then
      LLabelColor := TMaxxRuralComponentColors.PrimaryDark;
    FRenderer.Text(ACanvas, FLabelText,
      TMaxxRuralComponentFontInstaller.FontFamily, 0,
      ScaleMetric(15), 12, LLabelColor, FRequired, ADest.Width);
  end;

  LBackground.Color := TMaxxRuralComponentColors.ControlBackgroundForSurface(LSurface);
  if not Enabled then
    LBackground.Color := TMaxxRuralComponentColors.ControlBackgroundDisabledForSurface(LSurface);
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

function TMaxxRuralMemo.ParentSurfaceColor: TAlphaColor;
begin
  Result := TMaxxRuralComponentColors.ResolveParentSurface(Self);
end;

procedure TMaxxRuralMemo.Redraw;
begin
  UpdatePaintBoxBounds;
  if (FPaintBox <> nil) and HandleAllocated then
    FPaintBox.Redraw;
end;

procedure TMaxxRuralMemo.Resize;
begin
  inherited;
  UpdatePaintBoxBounds;
  UpdateZOrder;
  UpdateChildBounds;
  Redraw;
end;

function TMaxxRuralMemo.ScaleFactor: Single;
begin
  Result := 1;
  if FPaintBox <> nil then
    Result := FPaintBox.ScaleFactor;
  if Result <= 0 then
    Result := 1;
end;

function TMaxxRuralMemo.ScaleMetric(const AValue: Integer): Integer;
begin
  Result := Round(AValue * ScaleFactor);
  if (AValue > 0) and (Result < 1) then
    Result := 1;
end;

procedure TMaxxRuralMemo.SetCornerRadius(const AValue: Integer);
begin
  if FCornerRadius = AValue then
    Exit;
  FCornerRadius := Max(0, AValue);
  Redraw;
end;

procedure TMaxxRuralMemo.SetFocus;
begin
  if (FMemo <> nil) and FMemo.CanFocus then
    FMemo.SetFocus
  else
    inherited;
end;

procedure TMaxxRuralMemo.SetLabelText(const AValue: string);
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

procedure TMaxxRuralMemo.SetLines(const AValue: TStrings);
begin
  FMemo.Lines.Assign(AValue);
end;

procedure TMaxxRuralMemo.SetReadOnly(const AValue: Boolean);
begin
  if FMemo.ReadOnly = AValue then
    Exit;
  FMemo.ReadOnly := AValue;
  UpdateMemoStyle;
end;

procedure TMaxxRuralMemo.SetScrollBars(const AValue: System.UITypes.TScrollStyle);
begin
  FMemo.ScrollBars := AValue;
end;

procedure TMaxxRuralMemo.SetRequired(const AValue: Boolean);
begin
  if FRequired = AValue then
    Exit;
  FRequired := AValue;
  Redraw;
end;

procedure TMaxxRuralMemo.SetStatus(const AValue: TMaxxRuralEditStatus);
begin
  if FStatus = AValue then
    Exit;
  FStatus := AValue;
  Redraw;
end;

procedure TMaxxRuralMemo.SetText(const AValue: string);
begin
  FMemo.Text := AValue;
end;

procedure TMaxxRuralMemo.SetWordWrap(const AValue: Boolean);
begin
  FMemo.WordWrap := AValue;
end;

procedure TMaxxRuralMemo.UpdateChildBounds;
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

procedure TMaxxRuralMemo.UpdatePaintBoxBounds;
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

procedure TMaxxRuralMemo.UpdateZOrder;
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

procedure TMaxxRuralMemo.UpdateMemoStyle;
var
  LSurface: TAlphaColor;
  LTextColor: TColor;
begin
  if FMemo = nil then
    Exit;

  LSurface := ParentSurfaceColor;
  FMemo.Enabled := Enabled;
  FMemo.Color := TMaxxRuralComponentColors.ToVclColor(
    TMaxxRuralComponentColors.ControlBackgroundForSurface(LSurface));
  if not Enabled then
    FMemo.Color := TMaxxRuralComponentColors.ToVclColor(
      TMaxxRuralComponentColors.ControlBackgroundDisabledForSurface(LSurface));
  FMemo.Font.Name := TMaxxRuralComponentFontInstaller.FontFamily;
  FMemo.Font.Size := 10;
  FMemo.Font.Style := [];
  LTextColor := TMaxxRuralComponentColors.ToVclColor(
    TMaxxRuralComponentColors.ControlTextForSurface(LSurface));
  if not Enabled then
    LTextColor := TMaxxRuralComponentColors.ToVclColor(
      TMaxxRuralComponentColors.ControlTextDisabledForSurface(LSurface));
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

procedure TMaxxRuralMemo.WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
begin
  AMessage.Result := 1;
end;

end.
