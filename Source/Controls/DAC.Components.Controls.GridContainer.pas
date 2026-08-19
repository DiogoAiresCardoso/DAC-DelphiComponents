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
  DAC.Components.DesignSystem.ControlTokens,
  DAC.Components.DesignSystem.Theme,
  DAC.Components.Skia.Renderer;

type
  TDACGridContainerLayout = (
    mgclDefault,
    mgclDense,
    mgclCompact,
    mgclActionTiles,
    mgclCustom
  );

  TDACGridContainerAppearance = (
    mgcaDefault,
    mgcaTransparent,
    mgcaViewport,
    mgcaCustom
  );

  TDACGridContainer = class(TCustomControl)
  private
    FArranging: Boolean;
    FAutoContentHeight: Boolean;
    FAutoLayout: Boolean;
    FBackgroundColor: TAlphaColor;
    FBorderColor: TAlphaColor;
    FColumns: Integer;
    FCustomBackgroundColor: Boolean;
    FCustomBorderColor: Boolean;
    FCornerRadius: Integer;
    FGutter: Integer;
    FPaintBox: TSkPaintBox;
    FContentPadding: Integer;
    FAppearance: TDACGridContainerAppearance;
    FBaseAppearance: TDACGridContainerAppearance;
    FLayout: TDACGridContainerLayout;
    FMinimumColumnWidth: Integer;
    FRenderer: TDACSkiaRenderer;
    FRowHeight: Integer;
    FSizeRowsToContent: Boolean;
    FThemeMode: TDACThemeMode;
    function ChildColumnSpan(const AControl: TControl;
      const AColumns: Integer): Integer;
    function EffectiveColumns(const AClientWidth, AGutter: Integer): Integer;
    function ParentSurfaceColor: TAlphaColor;
    function Pixels(const AValue: Integer): Integer;
    function LayoutRect: TRect;
    function IsBackgroundColorStored: Boolean;
    function IsBorderColorStored: Boolean;
    function IsLayoutMetricStored: Boolean;
    procedure ApplyAppearance;
    procedure ApplyLayout;
    procedure ArrangeChildren;
    procedure CMControlListChange(var AMessage: TCMControlListChange); message CM_CONTROLLISTCHANGE;
    procedure CMParentColorChanged(var AMessage: TMessage); message CM_PARENTCOLORCHANGED;
    procedure CMParentFontChanged(var AMessage: TMessage); message CM_PARENTFONTCHANGED;
    procedure WMSize(var AMessage: TWMSize); message WM_SIZE;
    procedure PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    procedure RedrawChrome;
    procedure SetAutoContentHeight(const AValue: Boolean);
    procedure SetAutoLayout(const AValue: Boolean);
    procedure SetAppearance(const AValue: TDACGridContainerAppearance);
    procedure SetBackgroundColor(const AValue: TAlphaColor);
    procedure SetBorderColor(const AValue: TAlphaColor);
    procedure SetColumns(const AValue: Integer);
    procedure SetCornerRadius(const AValue: Integer);
    procedure SetGutter(const AValue: Integer);
    procedure SetLayout(const AValue: TDACGridContainerLayout);
    procedure SetMinimumColumnWidth(const AValue: Integer);
    procedure SetContentPadding(const AValue: Integer);
    procedure SetRowHeight(const AValue: Integer);
    procedure SetSizeRowsToContent(const AValue: Boolean);
    procedure SetThemeMode(const AValue: TDACThemeMode);
    procedure ThemeChanged(Sender: TObject);
    procedure UpdateChromeBounds;
    procedure WMEraseBkgnd(var AMessage: TWMEraseBkgnd); message WM_ERASEBKGND;
  protected
    procedure AdjustClientRect(var Rect: TRect); override;
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
    property AutoContentHeight: Boolean read FAutoContentHeight
      write SetAutoContentHeight default False;
    property AutoLayout: Boolean read FAutoLayout write SetAutoLayout default True;
    property Appearance: TDACGridContainerAppearance read FAppearance
      write SetAppearance default mgcaDefault;
    property BackgroundColor: TAlphaColor read FBackgroundColor
      write SetBackgroundColor stored IsBackgroundColorStored;
    property HasCustomBackgroundColor: Boolean read FCustomBackgroundColor stored False;
    property BorderColor: TAlphaColor read FBorderColor write SetBorderColor
      stored IsBorderColorStored;
    property Columns: Integer read FColumns write SetColumns default 12;
    property Constraints;
    property CornerRadius: Integer read FCornerRadius write SetCornerRadius
      stored IsLayoutMetricStored;
    property Enabled;
    property Font;
    property Gutter: Integer read FGutter write SetGutter
      stored IsLayoutMetricStored;
    property Layout: TDACGridContainerLayout read FLayout write SetLayout
      default mgclDefault;
    property MinimumColumnWidth: Integer read FMinimumColumnWidth
      write SetMinimumColumnWidth default 0;
    property ContentPadding: Integer read FContentPadding write SetContentPadding
      stored IsLayoutMetricStored;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property RowHeight: Integer read FRowHeight write SetRowHeight
      stored IsLayoutMetricStored;
    property SizeRowsToContent: Boolean read FSizeRowsToContent
      write SetSizeRowsToContent default False;
    property ShowHint;
    property TabOrder;
    property TabStop default True;
    property ThemeMode: TDACThemeMode read FThemeMode write SetThemeMode default dtmInherit;
    property Visible;
  end;

implementation

uses
  System.Math,
  Vcl.Forms,
  DAC.Components.Controls.Button,
  DAC.Components.DesignSystem.ColorTokens,
  DAC.Components.DesignSystem.ComponentStyle;

type
  TDACGridPlacement = record
    Column: Integer;
    Control: TControl;
    Row: Integer;
    Span: Integer;
  end;

constructor TDACGridContainer.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csAcceptsControls, csOpaque];
  Width := Round(TDACComponentStyle.Resolve(dtmInherit).Tokens.Controls.GridContainerDefaultWidth);
  Height := Round(TDACComponentStyle.Resolve(dtmInherit).Tokens.Controls.GridContainerDefaultHeight);
  TabStop := True;
  ParentColor := False;
  ParentBackground := False;
  ParentFont := False;
  StyleElements := [];

  FAutoContentHeight := False;
  FAutoLayout := True;
  FMinimumColumnWidth := 0;
  FSizeRowsToContent := False;
  FThemeMode := dtmInherit;
  FAppearance := mgcaDefault;
  FBaseAppearance := mgcaDefault;
  FLayout := mgclDefault;
  FColumns := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).
    Tokens.Controls.GridContainerDefaultColumns;
  ApplyAppearance;
  ApplyLayout;
  FRenderer := TDACSkiaRenderer.Create;
  Color := TDACComponentColors.ToVclColor(FBackgroundColor);

  FPaintBox := TSkPaintBox.Create(Self);
  FPaintBox.Parent := Self;
  FPaintBox.SetSubComponent(True);
  FPaintBox.StyleElements := [];
  FPaintBox.OnDraw := PaintBoxDraw;
  TDACThemeManager.RegisterListener(Self, ThemeChanged);
end;

procedure TDACGridContainer.ApplyAppearance;
var
  LAppearance: TDACGridContainerAppearance;
  LTokens: TDACControlTokens;
begin
  LTokens := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls;
  LAppearance := FAppearance;
  if LAppearance = mgcaCustom then
    LAppearance := FBaseAppearance;
  case LAppearance of
    mgcaDefault:
      begin
        if (FAppearance <> mgcaCustom) or not FCustomBackgroundColor then
          FBackgroundColor := LTokens.GridContainerBackground;
        if (FAppearance <> mgcaCustom) or not FCustomBorderColor then
          FBorderColor := LTokens.GridContainerBorder;
      end;
    mgcaTransparent:
      begin
        if (FAppearance <> mgcaCustom) or not FCustomBackgroundColor then
          FBackgroundColor := LTokens.GridContainerTransparentBackground;
        if (FAppearance <> mgcaCustom) or not FCustomBorderColor then
          FBorderColor := LTokens.GridContainerTransparentBorder;
      end;
    mgcaViewport:
      begin
        if (FAppearance <> mgcaCustom) or not FCustomBackgroundColor then
          FBackgroundColor := LTokens.ScrollContainerViewportBackground;
        if (FAppearance <> mgcaCustom) or not FCustomBorderColor then
          FBorderColor := LTokens.GridContainerTransparentBorder;
      end;
  end;
  if FAppearance <> mgcaCustom then
  begin
    FCustomBackgroundColor := False;
    FCustomBorderColor := False;
  end;
  if FBackgroundColor = LTokens.TransparentSurfaceFallback then
    Color := TDACComponentColors.ToVclColor(ParentSurfaceColor)
  else
    Color := TDACComponentColors.ToVclColor(
      TDACComponentColors.Normalize(FBackgroundColor));
  ParentColor := False;
  ParentBackground := False;
  ParentFont := False;
  Font.Name := TDACComponentStyle.FontFamily;
  Font.Size := TDACComponentStyle.TextSize;
  Font.Style := [];
  Font.Color := TDACComponentColors.ToVclColor(LTokens.ContainerTitle);
  Redraw;
end;

procedure TDACGridContainer.ApplyLayout;
var
  LTokens: TDACControlTokens;
begin
  LTokens := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls;
  case FLayout of
    mgclDefault:
      begin
        FCornerRadius := Round(LTokens.GridContainerRadius);
        FGutter := Round(LTokens.GridContainerGutter);
        FContentPadding := Round(LTokens.GridContainerPadding);
        FRowHeight := Round(LTokens.GridContainerRowHeight);
      end;
    mgclDense:
      begin
        FCornerRadius := Round(LTokens.GridContainerDenseRadius);
        FGutter := Round(LTokens.GridContainerDenseGutter);
        FContentPadding := Round(LTokens.GridContainerDensePadding);
        FRowHeight := Round(LTokens.GridContainerDenseRowHeight);
      end;
    mgclCompact:
      begin
        FCornerRadius := Round(LTokens.GridContainerCompactRadius);
        FGutter := Round(LTokens.GridContainerCompactGutter);
        FContentPadding := Round(LTokens.GridContainerCompactPadding);
        FRowHeight := Round(LTokens.GridContainerCompactRowHeight);
      end;
    mgclActionTiles:
      begin
        FCornerRadius := Round(LTokens.GridContainerActionTilesRadius);
        FGutter := Round(LTokens.GridContainerActionTilesGutter);
        FContentPadding := Round(LTokens.GridContainerActionTilesPadding);
        FRowHeight := Round(LTokens.GridContainerActionTilesRowHeight);
      end;
  end;
  ArrangeChildren;
  Redraw;
end;

destructor TDACGridContainer.Destroy;
begin
  TDACThemeManager.UnregisterListener(Self);
  FPaintBox.Free;
  FRenderer.Free;
  inherited;
end;

procedure TDACGridContainer.AdjustClientRect(var Rect: TRect);
var
  LPadding: Integer;
begin
  inherited AdjustClientRect(Rect);
  LPadding := Pixels(FContentPadding);
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
  LContentHeight: Integer;
  LEffectiveColumns: Integer;
  LGutter: Integer;
  LHeightChanged: Boolean;
  LLeft: Integer;
  LRow: Integer;
  LRowCount: Integer;
  LRowHeight: Integer;
  LRowHeights: array of Integer;
  LRowTops: array of Integer;
  LSpan: Integer;
  LTop: Integer;
  LPlacements: array of TDACGridPlacement;
begin
  if FArranging or not FAutoLayout or (csLoading in ComponentState) or
    (csDestroying in ComponentState) or (csDesigning in ComponentState) or
    (Parent = nil) or not HandleAllocated or not Parent.HandleAllocated then
    Exit;

  LClient := LayoutRect;
  LGutter := Pixels(FGutter);
  LRowHeight := Pixels(FRowHeight);
  if FColumns <= 0 then
    Exit;

  LEffectiveColumns := EffectiveColumns(LClient.Width, LGutter);
  LColumnWidth := (Max(0, LClient.Width) -
    (LGutter * (LEffectiveColumns - 1))) div LEffectiveColumns;
  if LColumnWidth <= 0 then
    Exit;

  LColumn := 0;
  LRow := 0;
  SetLength(LPlacements, 0);
  SetLength(LRowHeights, ControlCount);
  for I := 0 to ControlCount - 1 do
    LRowHeights[I] := 0;

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

    SetLength(LPlacements, Length(LPlacements) + 1);
    LPlacements[High(LPlacements)].Column := LColumn;
    LPlacements[High(LPlacements)].Control := LChild;
    LPlacements[High(LPlacements)].Row := LRow;
    LPlacements[High(LPlacements)].Span := LSpan;
    if FSizeRowsToContent then
      LRowHeights[LRow] := Max(LRowHeights[LRow], LChild.Height)
    else
      LRowHeights[LRow] := LRowHeight;

    Inc(LColumn, LSpan);
    if LColumn >= LEffectiveColumns then
    begin
      LColumn := 0;
      Inc(LRow);
    end;
  end;

  if Length(LPlacements) = 0 then
    LRowCount := 0
  else if LColumn = 0 then
    LRowCount := LRow
  else
    LRowCount := LRow + 1;

  SetLength(LRowTops, LRowCount);
  LTop := LClient.Top;
  for I := 0 to LRowCount - 1 do
  begin
    LRowTops[I] := LTop;
    LTop := LTop + LRowHeights[I];
    if I < LRowCount - 1 then
      Inc(LTop, LGutter);
  end;

  LContentHeight := LTop + Pixels(FContentPadding);
  if LRowCount = 0 then
    LContentHeight := Pixels(FContentPadding) * 2;

  FArranging := True;
  LHeightChanged := False;
  DisableAlign;
  try
    for I := 0 to Length(LPlacements) - 1 do
    begin
      LChild := LPlacements[I].Control;
      LLeft := LClient.Left +
        (LPlacements[I].Column * (LColumnWidth + LGutter));
      LTop := LRowTops[LPlacements[I].Row];
      if FSizeRowsToContent then
        LRowHeight := LChild.Height;
      LChild.SetBounds(LLeft, LTop,
        (LColumnWidth * LPlacements[I].Span) +
          (LGutter * (LPlacements[I].Span - 1)), LRowHeight);
    end;
    if FAutoContentHeight and (Height <> LContentHeight) then
    begin
      Height := LContentHeight;
      LHeightChanged := True;
    end;
  finally
    EnableAlign;
    FArranging := False;
  end;
  if LHeightChanged and (Parent is TScrollingWinControl) then
  begin
    TScrollingWinControl(Parent).DisableAutoRange;
    TScrollingWinControl(Parent).EnableAutoRange;
  end;
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
      LRequiredWidth := Max(Pixels(Round(
        TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls.
          GridContainerMinimumChildWidth)), LChild.Constraints.MinWidth);
      LRequiredWidth := Max(LRequiredWidth, Pixels(FMinimumColumnWidth));
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

function TDACGridContainer.IsBackgroundColorStored: Boolean;
begin
  Result := (FAppearance = mgcaCustom) and FCustomBackgroundColor;
end;

function TDACGridContainer.IsBorderColorStored: Boolean;
begin
  Result := (FAppearance = mgcaCustom) and FCustomBorderColor;
end;

function TDACGridContainer.IsLayoutMetricStored: Boolean;
begin
  Result := FLayout = mgclCustom;
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
  ApplyAppearance;
  ApplyLayout;
  UpdateChromeBounds;
  ArrangeChildren;
  Redraw;
end;

procedure TDACGridContainer.Loaded;
begin
  inherited;
  ApplyAppearance;
  ApplyLayout;
  UpdateChromeBounds;
  ArrangeChildren;
  Redraw;
end;

procedure TDACGridContainer.PaintBoxDraw(Sender: TObject;
  const ACanvas: ISkCanvas; const ADest: TRectF; const AOpacity: Single);
var
  LBackground: TAlphaColor;
  LRect: TRectF;
  LTokens: TDACControlTokens;
begin
  LTokens := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls;
  if FBackgroundColor = LTokens.TransparentSurfaceFallback then
    LBackground := ParentSurfaceColor
  else
    LBackground := TDACComponentColors.Normalize(FBackgroundColor);

  LRect := TRectF.Create(0, 0, ADest.Width, ADest.Height);
  LRect := FRenderer.SnapRect(LRect, LTokens.GridContainerBorderWidth);
  LRect.Inflate(-(LTokens.GridContainerBorderWidth / 2),
    -(LTokens.GridContainerBorderWidth / 2));
  FRenderer.FillRoundRect(ACanvas, LRect, LBackground, Pixels(FCornerRadius),
    LTokens.AlphaOpaque);
  FRenderer.StrokeRoundRect(ACanvas, LRect,
    TDACComponentColors.Normalize(FBorderColor), Pixels(FCornerRadius),
    LTokens.GridContainerBorderWidth, LTokens.AlphaOpaque);
end;

function TDACGridContainer.ParentSurfaceColor: TAlphaColor;
begin
  Result := TDACComponentStyle.ResolveForSurface(Self,
    FThemeMode).Tokens.Controls.PopupBackground;
end;

function TDACGridContainer.ResolvedBackgroundColor: TAlphaColor;
var
  LAppearance: TDACGridContainerAppearance;
  LTokens: TDACControlTokens;
begin
  if (FAppearance = mgcaCustom) and FCustomBackgroundColor then
    Exit(FBackgroundColor);
  LAppearance := FAppearance;
  if LAppearance = mgcaCustom then
    LAppearance := FBaseAppearance;
  LTokens := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls;
  case LAppearance of
    mgcaTransparent:
      Result := LTokens.GridContainerTransparentBackground;
    mgcaViewport:
      Result := LTokens.ScrollContainerViewportBackground;
  else
    Result := LTokens.GridContainerBackground;
  end;
end;

procedure TDACGridContainer.Redraw;
begin
  RedrawChrome;
end;

procedure TDACGridContainer.RedrawChrome;
begin
  if (FPaintBox <> nil) and not (csDestroying in ComponentState) and
    not (csDesigning in ComponentState) and (Parent <> nil) and
    HandleAllocated and Parent.HandleAllocated then
    FPaintBox.Redraw;
  if HandleAllocated then
    Invalidate;
end;

procedure TDACGridContainer.Resize;
begin
  inherited;
  UpdateChromeBounds;
  ArrangeChildren;
  Redraw;
end;

function TDACGridContainer.Pixels(const AValue: Integer): Integer;
begin
  Result := AValue;
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

procedure TDACGridContainer.SetAutoContentHeight(const AValue: Boolean);
begin
  if FAutoContentHeight = AValue then
    Exit;
  FAutoContentHeight := AValue;
  ArrangeChildren;
end;

procedure TDACGridContainer.SetAppearance(
  const AValue: TDACGridContainerAppearance);
begin
  if FAppearance = AValue then
  begin
    if AValue <> mgcaCustom then
      ApplyAppearance;
    Exit;
  end;
  FAppearance := AValue;
  if AValue <> mgcaCustom then
    FBaseAppearance := AValue;
  if AValue = mgcaCustom then
  begin
    FCustomBackgroundColor := True;
    FCustomBorderColor := True;
  end;
  ApplyAppearance;
end;

procedure TDACGridContainer.SetBackgroundColor(const AValue: TAlphaColor);
begin
  FAppearance := mgcaCustom;
  FCustomBackgroundColor := True;
  if FBackgroundColor = AValue then
    Exit;
  FBackgroundColor := AValue;
  if FBackgroundColor = TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls.
    TransparentSurfaceFallback then
    Color := TDACComponentColors.ToVclColor(ParentSurfaceColor)
  else
    Color := TDACComponentColors.ToVclColor(
      TDACComponentColors.Normalize(FBackgroundColor));
  Redraw;
end;

procedure TDACGridContainer.SetBorderColor(const AValue: TAlphaColor);
begin
  FAppearance := mgcaCustom;
  FCustomBorderColor := True;
  if FBorderColor = AValue then
    Exit;
  FBorderColor := AValue;
  Redraw;
end;

procedure TDACGridContainer.SetThemeMode(const AValue: TDACThemeMode);
begin
  if FThemeMode = AValue then
  begin
    ThemeChanged(Self);
    TDACThemeManager.RefreshTree(Self);
    Exit;
  end;
  FThemeMode := AValue;
  ThemeChanged(Self);
  TDACThemeManager.RefreshTree(Self);
end;

procedure TDACGridContainer.ThemeChanged(Sender: TObject);
begin
  ApplyAppearance;
  ApplyLayout;
end;

procedure TDACGridContainer.CMParentColorChanged(var AMessage: TMessage);
begin
  inherited;
  ThemeChanged(Self);
  TDACThemeManager.RefreshTree(Self);
end;

procedure TDACGridContainer.CMParentFontChanged(var AMessage: TMessage);
begin
  inherited;
  ThemeChanged(Self);
  TDACThemeManager.RefreshTree(Self);
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
  FLayout := mgclCustom;
  if FCornerRadius = Max(0, AValue) then
    Exit;
  FCornerRadius := Max(0, AValue);
  Redraw;
end;

procedure TDACGridContainer.SetGutter(const AValue: Integer);
begin
  FLayout := mgclCustom;
  if FGutter = Max(0, AValue) then
    Exit;
  FGutter := Max(0, AValue);
  ArrangeChildren;
  Redraw;
end;

procedure TDACGridContainer.SetLayout(
  const AValue: TDACGridContainerLayout);
begin
  if FLayout = AValue then
  begin
    if AValue <> mgclCustom then
      ApplyLayout;
    Exit;
  end;
  FLayout := AValue;
  ApplyLayout;
end;

procedure TDACGridContainer.SetMinimumColumnWidth(const AValue: Integer);
begin
  if FMinimumColumnWidth = Max(0, AValue) then
    Exit;
  FMinimumColumnWidth := Max(0, AValue);
  ArrangeChildren;
end;

procedure TDACGridContainer.SetContentPadding(const AValue: Integer);
begin
  FLayout := mgclCustom;
  if FContentPadding = Max(0, AValue) then
    Exit;
  FContentPadding := Max(0, AValue);
  ArrangeChildren;
  Redraw;
end;

procedure TDACGridContainer.SetRowHeight(const AValue: Integer);
var
  LValue: Integer;
begin
  FLayout := mgclCustom;
  LValue := Max(Round(
    TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls.
      GridContainerMinimumRowHeight), AValue);
  if FRowHeight = LValue then
    Exit;
  FRowHeight := LValue;
  ArrangeChildren;
  Redraw;
end;

procedure TDACGridContainer.SetSizeRowsToContent(const AValue: Boolean);
begin
  if FSizeRowsToContent = AValue then
    Exit;
  FSizeRowsToContent := AValue;
  ArrangeChildren;
end;

procedure TDACGridContainer.UpdateChromeBounds;
begin
  if (FPaintBox = nil) or (csLoading in ComponentState) or
    (csDestroying in ComponentState) or (csDesigning in ComponentState) or
    (Parent = nil) or not HandleAllocated or not Parent.HandleAllocated or
    not Showing then
    Exit;
  FPaintBox.SetBounds(0, 0, Width, Height);
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

