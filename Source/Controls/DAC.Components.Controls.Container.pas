unit DAC.Components.Controls.Container;

interface

uses
  System.Classes,
  System.Skia,
  System.Types,
  System.UITypes,
  Winapi.Messages,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.StdCtrls,
  Vcl.Skia,
  DAC.Components.Controls.SystemText,
  DAC.Components.DesignSystem.ColorTokens,
  DAC.Components.DesignSystem.Fonts,
  DAC.Components.DesignSystem.ComponentStyle,
  DAC.Components.DesignSystem.ControlTokens,
  DAC.Components.DesignSystem.Theme,
  DAC.Components.Skia.BackgroundPainter,
  DAC.Components.Skia.BorderPainter,
  DAC.Components.Skia.Renderer;

type
  TDACContainerAppearance = (
    mcaSuiteSection,
    mcaDarkPanel,
    mcaDarkCard,
    mcaTransparent
  );

  TDACContainer = class(TCustomControl)
  private
    FAppearance: TDACContainerAppearance;
    FBackgroundColor: TAlphaColor;
    FBackgroundPainter: TDACSkiaBackgroundPainter;
    FBorderColor: TAlphaColor;
    FCustomBackgroundColor: Boolean;
    FCustomBorderColor: Boolean;
    FCustomSubtitleColor: Boolean;
    FCustomTitleColor: Boolean;
    FCustomBorderRadius: Boolean;
    FCustomContentPadding: Boolean;
    FCustomCornerRadius: Boolean;
    FBorderPainter: TDACSkiaBorderPainter;
    FBorderRadius: Integer;
    FBorderWidth: Integer;
    FContentPadding: Integer;
    FCornerRadius: Integer;
    FHeaderHeight: Integer;
    FPaintBox: TSkPaintBox;
    FRenderer: TDACSkiaRenderer;
    FSectionNumber: Integer;
    FShowHeader: Boolean;
    FSubtitle: string;
    FSubtitleLabel: TDACSystemText;
    FSubtitleColor: TAlphaColor;
    FTitle: string;
    FTitleLabel: TDACSystemText;
    FTitleColor: TAlphaColor;
    FThemeMode: TDACThemeMode;
    procedure CMControlChange(var AMessage: TMessage); message CM_CONTROLCHANGE;
    procedure ApplyAppearanceColors;
    procedure CMParentColorChanged(var AMessage: TMessage); message CM_PARENTCOLORCHANGED;
    procedure CMParentFontChanged(var AMessage: TMessage); message CM_PARENTFONTCHANGED;
    function HeaderText: string;
    function LayoutRect: TRect;
    procedure InvalidateChrome;
    procedure PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    function ParentSurfaceColor: TAlphaColor;
    function Pixels(const AValue: Integer): Integer;
    function IsBackgroundColorStored: Boolean;
    function IsBorderColorStored: Boolean;
    function IsBorderRadiusStored: Boolean;
    function IsContentPaddingStored: Boolean;
    function IsCornerRadiusStored: Boolean;
    function IsSubtitleColorStored: Boolean;
    function IsTitleColorStored: Boolean;
    procedure SetAppearance(const AValue: TDACContainerAppearance);
    procedure SetBackgroundColor(const AValue: TAlphaColor);
    procedure SetBorderColor(const AValue: TAlphaColor);
    procedure SetBorderRadius(const AValue: Integer);
    procedure SetBorderWidth(const AValue: Integer);
    procedure SetContentPadding(const AValue: Integer);
    procedure SetCornerRadius(const AValue: Integer);
    procedure SetHeaderHeight(const AValue: Integer);
    procedure SetSectionNumber(const AValue: Integer);
    procedure SetShowHeader(const AValue: Boolean);
    procedure SetSubtitle(const AValue: string);
    procedure SetSubtitleColor(const AValue: TAlphaColor);
    procedure SetTitle(const AValue: string);
    procedure SetTitleColor(const AValue: TAlphaColor);
    procedure SetThemeMode(const AValue: TDACThemeMode);
    procedure ReleaseThemeAppearanceOverrides;
    procedure RefreshThemeDescendants;
    procedure SynchronizeNativeLabels;
    procedure ThemeChanged(Sender: TObject);
    procedure UpdateHeaderLabels;
    procedure UpdatePaintBoxBounds;
    procedure WMEraseBkgnd(var AMessage: TWMEraseBkgnd); message WM_ERASEBKGND;
  protected
    procedure AdjustClientRect(var Rect: TRect); override;
    procedure CreateWnd; override;
    procedure Loaded; override;
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ContentRect: TRect;
    function ResolvedBackgroundColor: TAlphaColor;
    procedure Redraw;
  published
    property Align;
    property Anchors;
    property Appearance: TDACContainerAppearance read FAppearance write SetAppearance default mcaSuiteSection;
    property BackgroundColor: TAlphaColor read FBackgroundColor
      write SetBackgroundColor stored IsBackgroundColorStored;
    property HasCustomBackgroundColor: Boolean read FCustomBackgroundColor stored False;
    property BorderColor: TAlphaColor read FBorderColor write SetBorderColor
      stored IsBorderColorStored;
    property BorderRadius: Integer read FBorderRadius write SetBorderRadius
      stored IsBorderRadiusStored;
    property BorderWidth: Integer read FBorderWidth write SetBorderWidth
      default DACContainerDefaultBorderWidth;
    property Color;
    property Constraints;
    property ContentPadding: Integer read FContentPadding write SetContentPadding
      stored IsContentPaddingStored;
    property CornerRadius: Integer read FCornerRadius write SetCornerRadius
      stored IsCornerRadiusStored;
    property Enabled;
    property HeaderHeight: Integer read FHeaderHeight write SetHeaderHeight
      default DACContainerDefaultHeaderHeight;
    property ParentColor;
    property ParentShowHint;
    property PopupMenu;
    property SectionNumber: Integer read FSectionNumber write SetSectionNumber default 0;
    property ShowHeader: Boolean read FShowHeader write SetShowHeader default True;
    property ShowHint;
    property Subtitle: string read FSubtitle write SetSubtitle;
    property SubtitleColor: TAlphaColor read FSubtitleColor
      write SetSubtitleColor stored IsSubtitleColorStored;
    property TabOrder;
    property TabStop default False;
    property Title: string read FTitle write SetTitle;
    property TitleColor: TAlphaColor read FTitleColor write SetTitleColor
      stored IsTitleColorStored;
    property ThemeMode: TDACThemeMode read FThemeMode write SetThemeMode default dtmInherit;
    property Visible;
  end;

implementation

uses
  System.Math,
  System.SysUtils;

procedure TDACContainer.ApplyAppearanceColors;
var
  LTokens: TDACControlTokens;
begin
  LTokens := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls;
  case FAppearance of
    mcaSuiteSection:
      begin
        if not FCustomBackgroundColor then
          FBackgroundColor := LTokens.ContainerSuiteBackground;
        if not FCustomBorderColor then
          FBorderColor := LTokens.ContainerSuiteBorder;
        if not FCustomTitleColor then
          FTitleColor := LTokens.ContainerTitle;
        if not FCustomSubtitleColor then
          FSubtitleColor := LTokens.ContainerSubtitle;
        if not FCustomCornerRadius then
          FCornerRadius := Round(LTokens.ContainerRadius);
        if not FCustomBorderRadius then
          FBorderRadius := Round(LTokens.ContainerRadius);
        if not FCustomContentPadding then
          FContentPadding := Round(LTokens.ContainerPadding);
      end;
    mcaDarkPanel:
      begin
        if not FCustomBackgroundColor then
          FBackgroundColor := LTokens.ContainerDarkBackground;
        if not FCustomBorderColor then
          FBorderColor := LTokens.ContainerDarkBorder;
        if not FCustomTitleColor then
          FTitleColor := LTokens.ContainerDarkTitle;
        if not FCustomSubtitleColor then
          FSubtitleColor := LTokens.ContainerDarkSubtitle;
        if not FCustomCornerRadius then
          FCornerRadius := Round(LTokens.ContainerDarkPanelRadius);
        if not FCustomBorderRadius then
          FBorderRadius := Round(LTokens.ContainerDarkPanelRadius);
        if not FCustomContentPadding then
          FContentPadding := Round(LTokens.ContainerDarkPanelPadding);
      end;
    mcaDarkCard:
      begin
        if not FCustomBackgroundColor then
          FBackgroundColor := LTokens.ContainerDarkCardBackground;
        if not FCustomBorderColor then
          FBorderColor := LTokens.ContainerDarkCardBorder;
        if not FCustomTitleColor then
          FTitleColor := LTokens.ContainerDarkTitle;
        if not FCustomSubtitleColor then
          FSubtitleColor := LTokens.ContainerDarkSubtitle;
        if not FCustomCornerRadius then
          FCornerRadius := Round(LTokens.ContainerDarkCardRadius);
        if not FCustomBorderRadius then
          FBorderRadius := Round(LTokens.ContainerDarkCardRadius);
        if not FCustomContentPadding then
          FContentPadding := Round(LTokens.ContainerDarkCardPadding);
      end;
    mcaTransparent:
      begin
        if not FCustomBackgroundColor then
          FBackgroundColor := LTokens.TransparentSurfaceFallback;
        if not FCustomBorderColor then
          FBorderColor := LTokens.TransparentSurfaceFallback;
        if not FCustomTitleColor then
          FTitleColor := LTokens.ContainerTitle;
        if not FCustomSubtitleColor then
          FSubtitleColor := LTokens.ContainerSubtitle;
        if not FCustomCornerRadius then
          FCornerRadius := Round(LTokens.ContainerRadius);
        if not FCustomBorderRadius then
          FBorderRadius := Round(LTokens.ContainerRadius);
        if not FCustomContentPadding then
          FContentPadding := Round(LTokens.ContainerPadding);
      end;
  end;
end;

constructor TDACContainer.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csAcceptsControls, csOpaque];
  Width := Round(TDACComponentStyle.Resolve(dtmInherit).Tokens.Controls.ContainerDefaultWidth);
  Height := Round(TDACComponentStyle.Resolve(dtmInherit).Tokens.Controls.ContainerDefaultHeight);
  TabStop := False;
  ParentColor := False;
  ParentBackground := False;
  ParentFont := False;
  StyleElements := [];

  FAppearance := mcaSuiteSection;
  FThemeMode := dtmInherit;
  ApplyAppearanceColors;
  FBorderWidth := Round(TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls.ContainerBorderWidth);
  FHeaderHeight := Round(TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls.ContainerHeaderHeight);
  FShowHeader := True;
  if FAppearance = mcaTransparent then
    Color := clNone
  else
    Color := TDACComponentColors.ToVclColor(FBackgroundColor);

  FRenderer := TDACSkiaRenderer.Create;
  FBackgroundPainter := TDACSkiaBackgroundPainter.Create(FRenderer);
  FBorderPainter := TDACSkiaBorderPainter.Create(FRenderer);

  FPaintBox := TSkPaintBox.Create(Self);
  FPaintBox.Parent := Self;
  FPaintBox.SetSubComponent(True);
  FPaintBox.StyleElements := [];
  FPaintBox.OnDraw := PaintBoxDraw;

  FTitleLabel := TDACSystemText.Create(Self);
  FTitleLabel.Parent := Self;
  FTitleLabel.SetSubComponent(True);

  FSubtitleLabel := TDACSystemText.Create(Self);
  FSubtitleLabel.Parent := Self;
  FSubtitleLabel.SetSubComponent(True);
  FTitleLabel.ThemeMode := FThemeMode;
  FSubtitleLabel.ThemeMode := FThemeMode;
  ThemeChanged(Self);
  TDACThemeManager.RegisterListener(Self, ThemeChanged);
end;

function TDACContainer.IsBackgroundColorStored: Boolean;
begin
  Result := FCustomBackgroundColor;
end;

function TDACContainer.IsBorderColorStored: Boolean;
begin
  Result := FCustomBorderColor;
end;

function TDACContainer.IsBorderRadiusStored: Boolean;
begin
  Result := FCustomBorderRadius;
end;

function TDACContainer.IsContentPaddingStored: Boolean;
begin
  Result := FCustomContentPadding;
end;

function TDACContainer.IsCornerRadiusStored: Boolean;
begin
  Result := FCustomCornerRadius;
end;

function TDACContainer.IsSubtitleColorStored: Boolean;
begin
  Result := FCustomSubtitleColor;
end;

function TDACContainer.IsTitleColorStored: Boolean;
begin
  Result := FCustomTitleColor;
end;

destructor TDACContainer.Destroy;
begin
  TDACThemeManager.UnregisterListener(Self);
  FSubtitleLabel.Free;
  FTitleLabel.Free;
  FPaintBox.Free;
  FBorderPainter.Free;
  FBackgroundPainter.Free;
  FRenderer.Free;
  inherited;
end;

procedure TDACContainer.CMParentColorChanged(var AMessage: TMessage);
begin
  inherited;
  { A child with ThemeMode=dtmInherit resolves its palette from this physical
    surface. Rebuild its token-backed appearance, not only the Skia frame,
    whenever the designer or runtime changes the parent theme/color. }
  ThemeChanged(Self);
  RefreshThemeDescendants;
end;

procedure TDACContainer.CMParentFontChanged(var AMessage: TMessage);
begin
  inherited;
  ThemeChanged(Self);
  RefreshThemeDescendants;
end;

procedure TDACContainer.AdjustClientRect(var Rect: TRect);
var
  LHeaderOffset: Integer;
  LPadding: Integer;
begin
  inherited AdjustClientRect(Rect);
  LHeaderOffset := 0;
  if FShowHeader then
    LHeaderOffset := Pixels(FHeaderHeight);
  LPadding := Pixels(FContentPadding);

  Inc(Rect.Left, LPadding);
  Inc(Rect.Top, LPadding + LHeaderOffset);
  Dec(Rect.Right, LPadding);
  Dec(Rect.Bottom, LPadding);

  if Rect.Right < Rect.Left then
    Rect.Right := Rect.Left;
  if Rect.Bottom < Rect.Top then
    Rect.Bottom := Rect.Top;
end;
procedure TDACContainer.CreateWnd;
begin
  inherited;
  UpdateHeaderLabels;
  Redraw;
end;

function TDACContainer.ContentRect: TRect;
begin
  Result := LayoutRect;
end;

function TDACContainer.ResolvedBackgroundColor: TAlphaColor;
begin
  if FAppearance = mcaTransparent then
    Result := ParentSurfaceColor
  else
    Result := TDACComponentColors.Normalize(FBackgroundColor);
end;

function TDACContainer.HeaderText: string;
begin
  Result := FTitle.Trim;
  if FSectionNumber > 0 then
  begin
    if Result = '' then
      Result := FSectionNumber.ToString
    else
      Result := Format('%d. %s', [FSectionNumber, Result]);
  end;
end;

procedure TDACContainer.InvalidateChrome;
begin
  Realign;
  UpdateHeaderLabels;
  Redraw;
  if FPaintBox = nil then
    Invalidate;
end;

procedure TDACContainer.Loaded;
begin
  inherited;
  ThemeChanged(Self);
  { During DFM streaming the container can receive ThemeMode before all child
    controls are loaded. Refresh the completed tree now so inherited children
    resolve the container surface in the designer and at runtime alike. }
  RefreshThemeDescendants;
  SynchronizeNativeLabels;
  UpdatePaintBoxBounds;
  UpdateHeaderLabels;
  Redraw;
end;

procedure TDACContainer.CMControlChange(var AMessage: TMessage);
begin
  inherited;
  { Native labels are painted by Windows above the Skia surface.  A regular
    VCL TLabel otherwise paints its Parent.Color as an opaque rectangle, which
    is not the actual raster colour of a TDACContainer. }
  SynchronizeNativeLabels;
end;

procedure TDACContainer.SynchronizeNativeLabels;
var
  LIndex: Integer;
  LLabel: TLabel;
  LTokens: TDACControlTokens;
begin
  if csDestroying in ComponentState then
    Exit;
  LTokens := TDACComponentStyle.ResolveForSurface(Self,
    FThemeMode).Tokens.Controls;
  for LIndex := 0 to ControlCount - 1 do
    if Controls[LIndex] is TLabel then
    begin
      LLabel := TLabel(Controls[LIndex]);
      LLabel.Transparent := True;
      LLabel.ParentFont := False;
      LLabel.Font.Name := TDACComponentStyle.FontFamily;
      LLabel.Font.Size := Round(LTokens.FieldLabelTextSize);
      LLabel.Font.Style := [];
      LLabel.Font.Color := TDACComponentColors.ToVclColor(
        LTokens.FieldLabelText);
    end;
end;

function TDACContainer.LayoutRect: TRect;
begin
  if HandleAllocated then
    Result := ClientRect
  else
    Result := Rect(0, 0, Width, Height);
  AdjustClientRect(Result);
end;

procedure TDACContainer.PaintBoxDraw(Sender: TObject;
  const ACanvas: ISkCanvas; const ADest: TRectF; const AOpacity: Single);
var
  LBackgroundStyle: TDACBackgroundStyle;
  LBackgroundRect: TRectF;
  LBorderRect: TRectF;
  LBorderStyle: TDACBorderStyle;
  LInset: Single;
  LScale: Single;
  LTokens: TDACControlTokens;
begin
  if ACanvas = nil then
    Exit;

  if (ADest.Width <= 0) or (ADest.Height <= 0) then
    Exit;

  LTokens := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls;
  LScale := LTokens.ContainerBorderWidth;
  LInset := (LTokens.ContainerBorderWidth / 2) / LScale;
  LBorderRect := FRenderer.SnapRect(TRectF.Create(0, 0, ADest.Width,
    ADest.Height), LScale);
  LBackgroundRect := LBorderRect;
  LBackgroundRect.Inflate(-LInset, -LInset);

  ACanvas.Clear(ParentSurfaceColor);

  LBackgroundStyle.Color := FBackgroundColor;
  LBackgroundStyle.Radius := FCornerRadius;
  LBackgroundStyle.Alpha := LTokens.AlphaOpaque;
  if FAppearance = mcaTransparent then
    LBackgroundStyle.Color := LTokens.TransparentSurfaceFallback;
  FBackgroundPainter.Draw(ACanvas, LBackgroundRect, LBackgroundStyle);

  LBorderStyle.Color := FBorderColor;
  LBorderStyle.Radius := FBorderRadius;
  LBorderStyle.Width := FBorderWidth;
  LBorderStyle.Alpha := LTokens.AlphaOpaque;
  if FAppearance = mcaTransparent then
    LBorderStyle.Color := LTokens.TransparentSurfaceFallback;
  FBorderPainter.Draw(ACanvas, LBorderRect, LBorderStyle);
end;

function TDACContainer.ParentSurfaceColor: TAlphaColor;
begin
  { The Skia surface must begin with the actual host surface so the pixels
    outside the rounded card remain transparent from the user's perspective.
    This is also safe in the form designer: ResolveParentSurface walks the
    component tree and never requires a window handle. }
  Result := TDACComponentColors.ResolveParentSurface(Self);
end;

procedure TDACContainer.Redraw;
begin
  if (FPaintBox = nil) or (csLoading in ComponentState) or
    (csDestroying in ComponentState) then
    Exit;

  UpdatePaintBoxBounds;

  { TSkPaintBox is a design-time child as well.  Do not use Handle/ClientRect
    here: the designer may stream a component before any HWND exists. Its
    default raster cache must nevertheless be discarded; Invalidate alone
    retains the previously rendered dark frame when ThemeMode changes. }
  if csDesigning in ComponentState then
  begin
    { TSkPaintBox descends from TGraphicControl. Redraw only clears its Skia
      cache and invalidates the design surface; it does not create a HWND. }
    FPaintBox.Redraw;
    Invalidate;
    Exit;
  end;

  if (Parent = nil) or not HandleAllocated or not Parent.HandleAllocated then
    Exit;

  FPaintBox.Redraw;
end;

procedure TDACContainer.Resize;
begin
  inherited;
  UpdatePaintBoxBounds;
  UpdateHeaderLabels;
  Redraw;
end;

function TDACContainer.Pixels(const AValue: Integer): Integer;
begin
  Result := AValue;
  if (AValue > 0) and (Result < 1) then
    Result := 1;
end;

procedure TDACContainer.SetAppearance(
  const AValue: TDACContainerAppearance);
begin
  if FAppearance = AValue then
    Exit;

  FAppearance := AValue;
  FCustomBackgroundColor := False;
  FCustomBorderColor := False;
  FCustomTitleColor := False;
  FCustomSubtitleColor := False;
  FCustomBorderRadius := False;
  FCustomContentPadding := False;
  FCustomCornerRadius := False;
  ThemeChanged(Self);
end;

procedure TDACContainer.SetThemeMode(const AValue: TDACThemeMode);
begin
  if FThemeMode = AValue then
  begin
    { The designer can re-apply the same streamed value after a component was
      recreated. Refresh descendants so no child keeps a stale Skia raster. }
    ThemeChanged(Self);
    RefreshThemeDescendants;
    Exit;
  end;

  { ThemeMode is an explicit palette decision. Earlier versions streamed the
    default appearance colors into DFM files, which made them indistinguishable
    from an override and prevented the new palette from taking effect. Release
    those appearance values before resolving the newly selected theme. }
  ReleaseThemeAppearanceOverrides;
  FThemeMode := AValue;
  ThemeChanged(Self);
  RefreshThemeDescendants;
end;

procedure TDACContainer.ReleaseThemeAppearanceOverrides;
begin
  FCustomBackgroundColor := False;
  FCustomBorderColor := False;
  FCustomTitleColor := False;
  FCustomSubtitleColor := False;
  FCustomCornerRadius := False;
  FCustomBorderRadius := False;
  FCustomContentPadding := False;
end;

procedure TDACContainer.RefreshThemeDescendants;
begin
  TDACThemeManager.RefreshTree(Self);
end;

procedure TDACContainer.ThemeChanged(Sender: TObject);
begin
  ApplyAppearanceColors;
  if FAppearance = mcaTransparent then
  begin
    ParentColor := True;
    ParentBackground := True;
    Color := clNone;
  end
  else
  begin
    ParentColor := False;
    ParentBackground := False;
    Color := TDACComponentColors.ToVclColor(FBackgroundColor);
  end;
  ParentFont := False;
  Font.Name := TDACComponentStyle.FontFamily;
  Font.Size := TDACComponentStyle.TextSize;
  Font.Style := [];
  Font.Color := TDACComponentColors.ToVclColor(FTitleColor);
  if FTitleLabel <> nil then
    FTitleLabel.ThemeMode := FThemeMode;
  if FSubtitleLabel <> nil then
    FSubtitleLabel.ThemeMode := FThemeMode;
  SynchronizeNativeLabels;
  UpdateHeaderLabels;
  InvalidateChrome;
end;

procedure TDACContainer.SetBackgroundColor(const AValue: TAlphaColor);
var
  LValue: TAlphaColor;
begin
  LValue := TDACComponentColors.Normalize(AValue);
  FCustomBackgroundColor := True;
  if FBackgroundColor = LValue then
    Exit;
  FBackgroundColor := LValue;
  if FAppearance = mcaTransparent then
    Color := clNone
  else
    Color := TDACComponentColors.ToVclColor(FBackgroundColor);
  InvalidateChrome;
end;

procedure TDACContainer.SetBorderColor(const AValue: TAlphaColor);
var
  LValue: TAlphaColor;
begin
  LValue := TDACComponentColors.Normalize(AValue);
  FCustomBorderColor := True;
  if FBorderColor = LValue then
    Exit;
  FBorderColor := LValue;
  InvalidateChrome;
end;

procedure TDACContainer.SetBorderRadius(const AValue: Integer);
begin
  FCustomBorderRadius := True;
  if FBorderRadius = Max(0, AValue) then
    Exit;
  FBorderRadius := AValue;
  if FBorderRadius < 0 then
    FBorderRadius := 0;
  InvalidateChrome;
end;

procedure TDACContainer.SetBorderWidth(const AValue: Integer);
begin
  if FBorderWidth = AValue then
    Exit;
  FBorderWidth := AValue;
  if FBorderWidth < 0 then
    FBorderWidth := 0;
  InvalidateChrome;
end;

procedure TDACContainer.SetContentPadding(const AValue: Integer);
begin
  FCustomContentPadding := True;
  if FContentPadding = Max(0, AValue) then
    Exit;
  FContentPadding := AValue;
  if FContentPadding < 0 then
    FContentPadding := 0;
  InvalidateChrome;
end;

procedure TDACContainer.SetCornerRadius(const AValue: Integer);
var
  LPreviousRadius: Integer;
begin
  LPreviousRadius := FCornerRadius;
  FCustomCornerRadius := True;
  if FBorderRadius = LPreviousRadius then
  begin
    FBorderRadius := Max(0, AValue);
    FCustomBorderRadius := True;
  end;
  if FCornerRadius = Max(0, AValue) then
    Exit;
  FCornerRadius := AValue;
  if FCornerRadius < 0 then
    FCornerRadius := 0;
  InvalidateChrome;
end;

procedure TDACContainer.SetHeaderHeight(const AValue: Integer);
begin
  if FHeaderHeight = AValue then
    Exit;
  FHeaderHeight := AValue;
  if FHeaderHeight < 0 then
    FHeaderHeight := 0;
  InvalidateChrome;
end;

procedure TDACContainer.SetSectionNumber(const AValue: Integer);
begin
  if FSectionNumber = AValue then
    Exit;
  FSectionNumber := AValue;
  if FSectionNumber < 0 then
    FSectionNumber := 0;
  InvalidateChrome;
end;

procedure TDACContainer.SetShowHeader(const AValue: Boolean);
begin
  if FShowHeader = AValue then
    Exit;
  FShowHeader := AValue;
  InvalidateChrome;
end;

procedure TDACContainer.SetSubtitle(const AValue: string);
begin
  if FSubtitle = AValue then
    Exit;
  FSubtitle := AValue;
  InvalidateChrome;
end;

procedure TDACContainer.SetSubtitleColor(const AValue: TAlphaColor);
var
  LValue: TAlphaColor;
begin
  LValue := TDACComponentColors.Normalize(AValue);
  FCustomSubtitleColor := True;
  if FSubtitleColor = LValue then
    Exit;
  FSubtitleColor := LValue;
  UpdateHeaderLabels;
  InvalidateChrome;
end;

procedure TDACContainer.SetTitle(const AValue: string);
begin
  if FTitle = AValue then
    Exit;
  FTitle := AValue;
  UpdateHeaderLabels;
  InvalidateChrome;
end;

procedure TDACContainer.SetTitleColor(const AValue: TAlphaColor);
var
  LValue: TAlphaColor;
begin
  LValue := TDACComponentColors.Normalize(AValue);
  FCustomTitleColor := True;
  if FTitleColor = LValue then
    Exit;
  FTitleColor := LValue;
  UpdateHeaderLabels;
  InvalidateChrome;
end;

procedure TDACContainer.UpdateHeaderLabels;
var
  LContentWidth: Integer;
  LPadding: Integer;
  LText: string;
  LTokens: TDACControlTokens;
begin
  if (FTitleLabel = nil) or (FSubtitleLabel = nil) then
    Exit;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    Exit;

  LPadding := Pixels(FContentPadding);
  LTokens := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls;
  LContentWidth := Width - (LPadding * 2);
  if LContentWidth < 0 then
    LContentWidth := 0;

  LText := HeaderText;

  FTitleLabel.Visible := FShowHeader and (LText <> '');
  FTitleLabel.SetBounds(LPadding, LPadding + Pixels(Round(LTokens.ContainerTitleTopOffset)),
    LContentWidth, Pixels(Round(LTokens.ContainerTitleHeight)));
  FTitleLabel.Text := LText;
  FTitleLabel.Role := mtrSmall;
  FTitleLabel.Bold := True;
  if FCustomTitleColor then
    FTitleLabel.TextColor := FTitleColor
  else if FAppearance in [mcaDarkPanel, mcaDarkCard] then
    FTitleLabel.Tone := mttPrimary
  else
    FTitleLabel.Tone := mttDefault;
  FTitleLabel.HorzAlign := mthaLeft;
  FTitleLabel.VertAlign := mtvaCenter;
  FTitleLabel.MaxLines := 1;

  FSubtitleLabel.Visible := FShowHeader and (FSubtitle.Trim <> '');
  FSubtitleLabel.SetBounds(LPadding, LPadding + Pixels(Round(LTokens.ContainerSubtitleTopOffset)),
    LContentWidth, Pixels(Round(LTokens.ContainerSubtitleHeight)));
  FSubtitleLabel.Text := FSubtitle;
  FSubtitleLabel.Role := mtrCaption;
  FSubtitleLabel.Bold := False;
  if FCustomSubtitleColor then
    FSubtitleLabel.TextColor := FSubtitleColor
  else
    FSubtitleLabel.Tone := mttSecondary;
  FSubtitleLabel.HorzAlign := mthaLeft;
  FSubtitleLabel.VertAlign := mtvaCenter;
  FSubtitleLabel.MaxLines := 1;

end;

procedure TDACContainer.UpdatePaintBoxBounds;
var
  LHeight: Integer;
  LWidth: Integer;
begin
  if (FPaintBox = nil) or (csLoading in ComponentState) or
    (csDestroying in ComponentState) then
    Exit;

  if csDesigning in ComponentState then
  begin
    { Width/Height are valid while a DFM is being streamed.  ClientRect and
      handle allocation are deliberately avoided so the preview uses the
      same rounded Skia painting as runtime without creating a child HWND. }
    LWidth := Width;
    LHeight := Height;
  end
  else
  begin
    if (Parent = nil) or not HandleAllocated or not Parent.HandleAllocated then
      Exit;
    LWidth := ClientWidth;
    LHeight := ClientHeight;
  end;

  if (FPaintBox.Left <> 0) or (FPaintBox.Top <> 0) or
    (FPaintBox.Width <> LWidth) or (FPaintBox.Height <> LHeight) then
    FPaintBox.SetBounds(0, 0, LWidth, LHeight);

end;

procedure TDACContainer.WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
begin
  AMessage.Result := 1;
end;

end.

