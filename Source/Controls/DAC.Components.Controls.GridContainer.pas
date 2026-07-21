unit DAC.Components.Controls.GridContainer;

interface

uses
  System.Classes,
  System.Skia,
  System.Types,
  System.UITypes,
  Winapi.Messages,
  Winapi.Windows,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.Skia,
  DAC.Components.Skia.Renderer;

type
  TDACGridContainer = class(TCustomControl)
  private
    FAutoLayout: Boolean;
    FBackgroundColor: TAlphaColor;
    FBorderColor: TAlphaColor;
    FColumns: Integer;
    FCornerRadius: Integer;
    FGutter: Integer;
    FPaintBox: TSkPaintBox;
    FContentPadding: Integer;
    FRenderer: TDACSkiaRenderer;
    FRowHeight: Integer;
    function ChildColumnSpan(const AControl: TControl;
      const AColumns: Integer): Integer;
    function EffectiveColumns(const AClientWidth, AGutter: Integer): Integer;
    function ParentSurfaceColor: TAlphaColor;
    function ScaleFactor: Single;
    function ScaleMetric(const AValue: Integer): Integer;
    function LayoutRect: TRect;
    procedure ArrangeChildren;
    procedure CMControlListChange(var AMessage: TCMControlListChange); message CM_CONTROLLISTCHANGE;
    procedure WMSize(var AMessage: TWMSize); message WM_SIZE;
    procedure PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    procedure RedrawChrome;
    procedure SetAutoLayout(const AValue: Boolean);
    procedure SetBackgroundColor(const AValue: TAlphaColor);
    procedure SetBorderColor(const AValue: TAlphaColor);
    procedure SetColumns(const AValue: Integer);
    procedure SetCornerRadius(const AValue: Integer);
    procedure SetGutter(const AValue: Integer);
    procedure SetContentPadding(const AValue: Integer);
    procedure SetRowHeight(const AValue: Integer);
    procedure UpdateChromeBounds;
    procedure WMEraseBkgnd(var AMessage: TWMEraseBkgnd); message WM_ERASEBKGND;
  protected
    procedure AdjustClientRect(var Rect: TRect); override;
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
    property AutoLayout: Boolean read FAutoLayout write SetAutoLayout default True;
    property BackgroundColor: TAlphaColor read FBackgroundColor write SetBackgroundColor;
    property BorderColor: TAlphaColor read FBorderColor write SetBorderColor;
    property Columns: Integer read FColumns write SetColumns default 12;
    property Constraints;
    property CornerRadius: Integer read FCornerRadius write SetCornerRadius default 8;
    property Enabled;
    property Font;
    property Gutter: Integer read FGutter write SetGutter default 16;
    property ContentPadding: Integer read FContentPadding write SetContentPadding default 24;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property RowHeight: Integer read FRowHeight write SetRowHeight default 64;
    property ShowHint;
    property TabOrder;
    property TabStop default True;
    property Visible;
  end;

implementation

uses
  System.Math,
  DAC.Components.Controls.Button,
  DAC.Components.DesignSystem.ColorTokens;

constructor TDACGridContainer.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csAcceptsControls, csOpaque];
  Width := 640;
  Height := 320;
  TabStop := True;
  ParentColor := False;
  StyleElements := [];

  FAutoLayout := True;
  FBackgroundColor := TDACComponentColors.White;
  FBorderColor := TDACComponentColors.ControlBorder;
  FColumns := 12;
  FCornerRadius := 8;
  FGutter := 16;
  FContentPadding := 24;
  FRowHeight := 64;
  FRenderer := TDACSkiaRenderer.Create;
  Color := TDACComponentColors.ToVclColor(FBackgroundColor);

  FPaintBox := TSkPaintBox.Create(Self);
  FPaintBox.Parent := Self;
  FPaintBox.SetSubComponent(True);
  FPaintBox.StyleElements := [];
  FPaintBox.OnDraw := PaintBoxDraw;
end;

destructor TDACGridContainer.Destroy;
begin
  FPaintBox.Free;
  FRenderer.Free;
  inherited;
end;

procedure TDACGridContainer.AdjustClientRect(var Rect: TRect);
var
  LPadding: Integer;
begin
  inherited AdjustClientRect(Rect);
  LPadding := ScaleMetric(FContentPadding);
  InflateRect(Rect, -LPadding, -LPadding);
  if Rect.Right < Rect.Left then
    Rect.Right := Rect.Left;
  if Rect.Bottom < Rect.Top then
    Rect.Bottom := Rect.Top;
end;

procedure TDACGridContainer.ArrangeChildren;
var
  I: Integer;
  LChild: TControl;
  LClient: TRect;
  LColumn: Integer;
  LColumnWidth: Integer;
  LEffectiveColumns: Integer;
  LGutter: Integer;
  LLeft: Integer;
  LRow: Integer;
  LRowHeight: Integer;
  LSpan: Integer;
  LTop: Integer;
begin
  if not FAutoLayout or (csLoading in ComponentState) or (csDestroying in ComponentState) then
    Exit;

  LClient := LayoutRect;
  LGutter := ScaleMetric(FGutter);
  LRowHeight := ScaleMetric(FRowHeight);
  if FColumns <= 0 then
    Exit;

  LEffectiveColumns := EffectiveColumns(LClient.Width, LGutter);
  LColumnWidth := (Max(0, LClient.Width) -
    (LGutter * (LEffectiveColumns - 1))) div LEffectiveColumns;
  if LColumnWidth <= 0 then
    Exit;

  LColumn := 0;
  LRow := 0;
  DisableAlign;
  try
    for I := 0 to ControlCount - 1 do
    begin
      LChild := Controls[I];
      if (LChild = FPaintBox) or not LChild.Visible then
        Continue;

      LSpan := ChildColumnSpan(LChild, LEffectiveColumns);
      if (LColumn > 0) and (LColumn + LSpan > LEffectiveColumns) then
      begin
        LColumn := 0;
        Inc(LRow);
      end;

      LLeft := LClient.Left + (LColumn * (LColumnWidth + LGutter));
      LTop := LClient.Top + (LRow * (LRowHeight + LGutter));
      LChild.SetBounds(LLeft, LTop,
        (LColumnWidth * LSpan) + (LGutter * (LSpan - 1)), LRowHeight);

      Inc(LColumn, LSpan);
      if LColumn >= LEffectiveColumns then
      begin
        LColumn := 0;
        Inc(LRow);
      end;
    end;
  finally
    EnableAlign;
  end;
end;

procedure TDACGridContainer.ChangeScale(M, D: Integer);
begin
  inherited;
  ArrangeChildren;
  Redraw;
end;

function TDACGridContainer.ChildColumnSpan(const AControl: TControl;
  const AColumns: Integer): Integer;
begin
  Result := 1;
  if AControl <> nil then
    Result := AControl.Tag;
  if Result <= 0 then
    Result := 1;
  Result := Max(1, Min(Result, AColumns));
end;

function TDACGridContainer.EffectiveColumns(const AClientWidth,
  AGutter: Integer): Integer;
var
  I: Integer;
  LCandidate: Integer;
  LChild: TControl;
  LColumnWidth: Integer;
  LRequiredWidth: Integer;
  LSpan: Integer;
begin
  for LCandidate := FColumns downto 1 do
  begin
    LColumnWidth := (Max(0, AClientWidth) -
      (AGutter * (LCandidate - 1))) div LCandidate;
    if LColumnWidth <= 0 then
      Continue;
    for I := 0 to ControlCount - 1 do
    begin
      LChild := Controls[I];
      if (LChild = FPaintBox) or not LChild.Visible then
        Continue;
      LSpan := ChildColumnSpan(LChild, LCandidate);
      LRequiredWidth := Max(ScaleMetric(48), LChild.Constraints.MinWidth);
      if LChild is TDACButton then
        LRequiredWidth := Max(LRequiredWidth,
          TDACButton(LChild).MinimumContentWidth);
      if ((LColumnWidth * LSpan) + (AGutter * (LSpan - 1))) <
        LRequiredWidth then
        Break;
    end;
    if I = ControlCount then
      Exit(LCandidate);
  end;
  Result := 1;
end;

function TDACGridContainer.LayoutRect: TRect;
begin
  if HandleAllocated then
    Result := ClientRect
  else
    Result := Rect(0, 0, Width, Height);
  AdjustClientRect(Result);
end;

procedure TDACGridContainer.CMControlListChange(
  var AMessage: TCMControlListChange);
begin
  inherited;
  ArrangeChildren;
  Redraw;
end;

procedure TDACGridContainer.WMSize(var AMessage: TWMSize);
begin
  inherited;
  if (csDestroying in ComponentState) then
    Exit;
  UpdateChromeBounds;
  ArrangeChildren;
  Redraw;
end;

procedure TDACGridContainer.CreateWnd;
begin
  inherited;
  UpdateChromeBounds;
  ArrangeChildren;
  Redraw;
end;

procedure TDACGridContainer.Loaded;
begin
  inherited;
  UpdateChromeBounds;
  ArrangeChildren;
  Redraw;
end;

procedure TDACGridContainer.PaintBoxDraw(Sender: TObject;
  const ACanvas: ISkCanvas; const ADest: TRectF; const AOpacity: Single);
var
  LBackground: TAlphaColor;
  LRect: TRectF;
begin
  if FBackgroundColor = TAlphaColor($00000000) then
    LBackground := ParentSurfaceColor
  else
    LBackground := TDACComponentColors.Normalize(FBackgroundColor);

  LRect := TRectF.Create(0, 0, ADest.Width, ADest.Height);
  LRect := FRenderer.SnapRect(LRect, ScaleFactor);
  LRect.Inflate(-0.5, -0.5);
  FRenderer.FillRoundRect(ACanvas, LRect, LBackground, ScaleMetric(FCornerRadius), 255);
  FRenderer.StrokeRoundRect(ACanvas, LRect,
    TDACComponentColors.Normalize(FBorderColor), ScaleMetric(FCornerRadius), 1, 255);
end;

function TDACGridContainer.ParentSurfaceColor: TAlphaColor;
begin
  Result := TDACComponentColors.ResolveParentSurface(Self);
end;

procedure TDACGridContainer.Redraw;
begin
  RedrawChrome;
end;

procedure TDACGridContainer.RedrawChrome;
begin
  if (FPaintBox <> nil) and not (csDestroying in ComponentState) and
    ((Parent <> nil) or not (csDesigning in ComponentState)) then
    FPaintBox.Redraw;
  Invalidate;
end;

procedure TDACGridContainer.Resize;
begin
  inherited;
  UpdateChromeBounds;
  ArrangeChildren;
  Redraw;
end;

function TDACGridContainer.ScaleFactor: Single;
begin
  Result := 1;
  if FPaintBox <> nil then
    Result := FPaintBox.ScaleFactor;
  if Result <= 0 then
    Result := 1;
end;

function TDACGridContainer.ScaleMetric(const AValue: Integer): Integer;
begin
  Result := Round(AValue * ScaleFactor);
  if (AValue > 0) and (Result < 1) then
    Result := 1;
end;

procedure TDACGridContainer.SetAutoLayout(const AValue: Boolean);
begin
  if FAutoLayout = AValue then
    Exit;
  FAutoLayout := AValue;
  ArrangeChildren;
end;

procedure TDACGridContainer.SetBackgroundColor(const AValue: TAlphaColor);
begin
  if FBackgroundColor = AValue then
    Exit;
  FBackgroundColor := AValue;
  if FBackgroundColor = TAlphaColor($00000000) then
    Color := TDACComponentColors.ToVclColor(ParentSurfaceColor)
  else
    Color := TDACComponentColors.ToVclColor(
      TDACComponentColors.Normalize(FBackgroundColor));
  Redraw;
end;

procedure TDACGridContainer.SetBorderColor(const AValue: TAlphaColor);
begin
  if FBorderColor = AValue then
    Exit;
  FBorderColor := AValue;
  Redraw;
end;

procedure TDACGridContainer.SetColumns(const AValue: Integer);
begin
  if FColumns = AValue then
    Exit;
  FColumns := Max(1, Min(AValue, 12));
  ArrangeChildren;
  Redraw;
end;

procedure TDACGridContainer.SetCornerRadius(const AValue: Integer);
begin
  if FCornerRadius = AValue then
    Exit;
  FCornerRadius := Max(0, AValue);
  Redraw;
end;

procedure TDACGridContainer.SetGutter(const AValue: Integer);
begin
  if FGutter = AValue then
    Exit;
  FGutter := Max(0, AValue);
  ArrangeChildren;
  Redraw;
end;

procedure TDACGridContainer.SetContentPadding(const AValue: Integer);
begin
  if FContentPadding = AValue then
    Exit;
  FContentPadding := Max(0, AValue);
  ArrangeChildren;
  Redraw;
end;

procedure TDACGridContainer.SetRowHeight(const AValue: Integer);
begin
  if FRowHeight = AValue then
    Exit;
  FRowHeight := Max(24, AValue);
  ArrangeChildren;
  Redraw;
end;

procedure TDACGridContainer.UpdateChromeBounds;
begin
  if FPaintBox = nil then
    Exit;
  FPaintBox.SetBounds(0, 0, Width, Height);
  if (csLoading in ComponentState) or (csDesigning in ComponentState) or
    not HandleAllocated then
    Exit;
  FPaintBox.SendToBack;
end;

procedure TDACGridContainer.WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
var
  LBrush: HBRUSH;
begin
  // A grid can be exposed while its scrollbox parent moves child HWNDs.  Its
  // Skia surface redraws afterward, so the native erase must already carry
  // the same token color instead of leaving the default black background.
  LBrush := CreateSolidBrush(ColorToRGB(Color));
  try
    Winapi.Windows.FillRect(AMessage.DC, ClientRect, LBrush);
  finally
    DeleteObject(LBrush);
  end;
  AMessage.Result := 1;
end;

end.

