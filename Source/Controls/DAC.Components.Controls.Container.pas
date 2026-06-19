unit MaxxRural.Components.Controls.Container;

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
  MaxxRural.Components.Controls.SystemText,
  MaxxRural.Components.DesignSystem.ColorTokens,
  MaxxRural.Components.DesignSystem.Fonts,
  MaxxRural.Components.Skia.BackgroundPainter,
  MaxxRural.Components.Skia.BorderPainter,
  MaxxRural.Components.Skia.Renderer;

type
  TMaxxRuralContainerAppearance = (
    mcaSuiteSection,
    mcaDarkPanel,
    mcaTransparent
  );

  TMaxxRuralContainer = class(TCustomControl)
  private
    FAppearance: TMaxxRuralContainerAppearance;
    FBackgroundColor: TAlphaColor;
    FBackgroundPainter: TMaxxRuralSkiaBackgroundPainter;
    FBorderColor: TAlphaColor;
    FBorderPainter: TMaxxRuralSkiaBorderPainter;
    FBorderRadius: Integer;
    FBorderWidth: Integer;
    FContentPadding: Integer;
    FCornerRadius: Integer;
    FHeaderHeight: Integer;
    FPaintBox: TSkPaintBox;
    FRenderer: TMaxxRuralSkiaRenderer;
    FSectionNumber: Integer;
    FShowHeader: Boolean;
    FSubtitle: string;
    FSubtitleLabel: TMaxxRuralSystemText;
    FSubtitleColor: TAlphaColor;
    FTitle: string;
    FTitleLabel: TMaxxRuralSystemText;
    FTitleColor: TAlphaColor;
    procedure CMParentColorChanged(var AMessage: TMessage); message CM_PARENTCOLORCHANGED;
    function HeaderText: string;
    function LayoutRect: TRect;
    procedure InvalidateChrome;
    procedure PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    function ParentSurfaceColor: TAlphaColor;
    function ScaleFactor: Single;
    function ScaleMetric(const AValue: Integer): Integer;
    procedure SetAppearance(const AValue: TMaxxRuralContainerAppearance);
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
    procedure UpdateHeaderLabels;
    procedure UpdatePaintBoxBounds;
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
    function ContentRect: TRect;
    procedure Redraw;
  published
    property Align;
    property Anchors;
    property Appearance: TMaxxRuralContainerAppearance read FAppearance write SetAppearance default mcaSuiteSection;
    property BackgroundColor: TAlphaColor read FBackgroundColor write SetBackgroundColor;
    property BorderColor: TAlphaColor read FBorderColor write SetBorderColor;
    property BorderRadius: Integer read FBorderRadius write SetBorderRadius default 10;
    property BorderWidth: Integer read FBorderWidth write SetBorderWidth default 1;
    property Color;
    property Constraints;
    property ContentPadding: Integer read FContentPadding write SetContentPadding default 16;
    property CornerRadius: Integer read FCornerRadius write SetCornerRadius default 10;
    property Enabled;
    property HeaderHeight: Integer read FHeaderHeight write SetHeaderHeight default 42;
    property ParentColor;
    property ParentShowHint;
    property PopupMenu;
    property SectionNumber: Integer read FSectionNumber write SetSectionNumber default 0;
    property ShowHeader: Boolean read FShowHeader write SetShowHeader default True;
    property ShowHint;
    property Subtitle: string read FSubtitle write SetSubtitle;
    property SubtitleColor: TAlphaColor read FSubtitleColor write SetSubtitleColor;
    property TabOrder;
    property TabStop default False;
    property Title: string read FTitle write SetTitle;
    property TitleColor: TAlphaColor read FTitleColor write SetTitleColor;
    property Visible;
  end;

implementation

uses
  System.SysUtils;

constructor TMaxxRuralContainer.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csAcceptsControls, csOpaque];
  Width := 460;
  Height := 200;
  TabStop := False;
  ParentColor := True;
  StyleElements := [];

  FAppearance := mcaSuiteSection;
  FBackgroundColor := TMaxxRuralComponentColors.SuiteSectionBackground;
  FBorderColor := TMaxxRuralComponentColors.ControlBorder;
  FTitleColor := TMaxxRuralComponentColors.ControlText;
  FSubtitleColor := TMaxxRuralComponentColors.SuiteSectionSubtitle;
  FBorderRadius := 10;
  FBorderWidth := 1;
  FContentPadding := 16;
  FCornerRadius := 10;
  FHeaderHeight := 42;
  FShowHeader := True;
  Color := TMaxxRuralComponentColors.ToVclColor(FBackgroundColor);

  FRenderer := TMaxxRuralSkiaRenderer.Create;
  FBackgroundPainter := TMaxxRuralSkiaBackgroundPainter.Create(FRenderer);
  FBorderPainter := TMaxxRuralSkiaBorderPainter.Create(FRenderer);

  FPaintBox := TSkPaintBox.Create(Self);
  FPaintBox.Parent := Self;
  FPaintBox.SetSubComponent(True);
  FPaintBox.StyleElements := [];
  FPaintBox.OnDraw := PaintBoxDraw;

  FTitleLabel := TMaxxRuralSystemText.Create(Self);
  FTitleLabel.Parent := Self;
  FTitleLabel.SetSubComponent(True);

  FSubtitleLabel := TMaxxRuralSystemText.Create(Self);
  FSubtitleLabel.Parent := Self;
  FSubtitleLabel.SetSubComponent(True);
end;

destructor TMaxxRuralContainer.Destroy;
begin
  FSubtitleLabel.Free;
  FTitleLabel.Free;
  FPaintBox.Free;
  FBorderPainter.Free;
  FBackgroundPainter.Free;
  FRenderer.Free;
  inherited;
end;

procedure TMaxxRuralContainer.CMParentColorChanged(var AMessage: TMessage);
begin
  inherited;
  Redraw;
end;

procedure TMaxxRuralContainer.AdjustClientRect(var Rect: TRect);
var
  LHeaderOffset: Integer;
  LPadding: Integer;
begin
  inherited AdjustClientRect(Rect);
  LHeaderOffset := 0;
  if FShowHeader then
    LHeaderOffset := ScaleMetric(FHeaderHeight);
  LPadding := ScaleMetric(FContentPadding);

  Inc(Rect.Left, LPadding);
  Inc(Rect.Top, LPadding + LHeaderOffset);
  Dec(Rect.Right, LPadding);
  Dec(Rect.Bottom, LPadding);

  if Rect.Right < Rect.Left then
    Rect.Right := Rect.Left;
  if Rect.Bottom < Rect.Top then
    Rect.Bottom := Rect.Top;
end;

procedure TMaxxRuralContainer.ChangeScale(M, D: Integer);
begin
  inherited;
  UpdateHeaderLabels;
  Redraw;
end;

procedure TMaxxRuralContainer.CreateWnd;
begin
  inherited;
  UpdateHeaderLabels;
  Redraw;
end;

function TMaxxRuralContainer.ContentRect: TRect;
begin
  Result := LayoutRect;
end;

function TMaxxRuralContainer.HeaderText: string;
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

procedure TMaxxRuralContainer.InvalidateChrome;
begin
  Realign;
  UpdateHeaderLabels;
  Redraw;
  Invalidate;
end;

procedure TMaxxRuralContainer.Loaded;
begin
  inherited;
  UpdatePaintBoxBounds;
  UpdateHeaderLabels;
  Redraw;
end;

function TMaxxRuralContainer.LayoutRect: TRect;
begin
  if HandleAllocated then
    Result := ClientRect
  else
    Result := Rect(0, 0, Width, Height);
  AdjustClientRect(Result);
end;

procedure TMaxxRuralContainer.PaintBoxDraw(Sender: TObject;
  const ACanvas: ISkCanvas; const ADest: TRectF; const AOpacity: Single);
var
  LBackgroundStyle: TMaxxRuralBackgroundStyle;
  LBackgroundRect: TRectF;
  LBorderRect: TRectF;
  LBorderStyle: TMaxxRuralBorderStyle;
  LInset: Single;
  LScale: Single;
begin
  if ACanvas = nil then
    Exit;

  if (ADest.Width <= 0) or (ADest.Height <= 0) then
    Exit;

  LScale := ScaleFactor;
  LInset := 0.5 / LScale;
  LBorderRect := FRenderer.SnapRect(TRectF.Create(0, 0, ADest.Width,
    ADest.Height), LScale);
  LBackgroundRect := LBorderRect;
  LBackgroundRect.Inflate(-LInset, -LInset);

  ACanvas.Clear(ParentSurfaceColor);

  LBackgroundStyle.Color := FBackgroundColor;
  LBackgroundStyle.Radius := FCornerRadius;
  LBackgroundStyle.Alpha := 255;
  if FAppearance = mcaTransparent then
    LBackgroundStyle.Alpha := 0;
  FBackgroundPainter.Draw(ACanvas, LBackgroundRect, LBackgroundStyle);

  LBorderStyle.Color := FBorderColor;
  LBorderStyle.Radius := FBorderRadius;
  LBorderStyle.Width := FBorderWidth;
  LBorderStyle.Alpha := 255;
  if FAppearance = mcaTransparent then
    LBorderStyle.Alpha := 0;
  FBorderPainter.Draw(ACanvas, LBorderRect, LBorderStyle);
end;

function TMaxxRuralContainer.ParentSurfaceColor: TAlphaColor;
begin
  Result := TMaxxRuralComponentColors.ResolveParentSurface(Self);
end;

procedure TMaxxRuralContainer.Redraw;
begin
  UpdatePaintBoxBounds;
  if (FPaintBox <> nil) and HandleAllocated then
    FPaintBox.Redraw;
end;

procedure TMaxxRuralContainer.Resize;
begin
  inherited;
  UpdatePaintBoxBounds;
  UpdateHeaderLabels;
  Redraw;
end;

function TMaxxRuralContainer.ScaleFactor: Single;
begin
  Result := 1;
  if FPaintBox <> nil then
    Result := FPaintBox.ScaleFactor;
  if Result <= 0 then
    Result := 1;
end;

function TMaxxRuralContainer.ScaleMetric(const AValue: Integer): Integer;
begin
  Result := Round(AValue * ScaleFactor);
  if (AValue > 0) and (Result < 1) then
    Result := 1;
end;

procedure TMaxxRuralContainer.SetAppearance(
  const AValue: TMaxxRuralContainerAppearance);
begin
  if FAppearance = AValue then
    Exit;

  FAppearance := AValue;
  case FAppearance of
    mcaSuiteSection:
      begin
        FBackgroundColor := TMaxxRuralComponentColors.SuiteSectionBackground;
        FBorderColor := TMaxxRuralComponentColors.SuiteSectionBorder;
        FTitleColor := TMaxxRuralComponentColors.SuiteSectionTitle;
        FSubtitleColor := TMaxxRuralComponentColors.SuiteSectionSubtitle;
      end;
    mcaDarkPanel:
      begin
        FBackgroundColor := TMaxxRuralComponentColors.DarkPanelBackground;
        FBorderColor := TMaxxRuralComponentColors.DarkPanelBorder;
        FTitleColor := TMaxxRuralComponentColors.Text;
        FSubtitleColor := TMaxxRuralComponentColors.TextSecondary;
      end;
    mcaTransparent:
      begin
        FBackgroundColor := TMaxxRuralComponentColors.Transparent;
        FBorderColor := TMaxxRuralComponentColors.Transparent;
        FTitleColor := TMaxxRuralComponentColors.SuiteSectionTitle;
        FSubtitleColor := TMaxxRuralComponentColors.SuiteSectionSubtitle;
      end;
  end;
  if FAppearance = mcaTransparent then
    Color := clNone
  else
    Color := TMaxxRuralComponentColors.ToVclColor(FBackgroundColor);
  UpdateHeaderLabels;
  InvalidateChrome;
end;

procedure TMaxxRuralContainer.SetBackgroundColor(const AValue: TAlphaColor);
var
  LValue: TAlphaColor;
begin
  LValue := TMaxxRuralComponentColors.Normalize(AValue);
  if FBackgroundColor = LValue then
    Exit;
  FBackgroundColor := LValue;
  if FAppearance = mcaTransparent then
    Color := clNone
  else
    Color := TMaxxRuralComponentColors.ToVclColor(FBackgroundColor);
  InvalidateChrome;
end;

procedure TMaxxRuralContainer.SetBorderColor(const AValue: TAlphaColor);
var
  LValue: TAlphaColor;
begin
  LValue := TMaxxRuralComponentColors.Normalize(AValue);
  if FBorderColor = LValue then
    Exit;
  FBorderColor := LValue;
  InvalidateChrome;
end;

procedure TMaxxRuralContainer.SetBorderRadius(const AValue: Integer);
begin
  if FBorderRadius = AValue then
    Exit;
  FBorderRadius := AValue;
  if FBorderRadius < 0 then
    FBorderRadius := 0;
  InvalidateChrome;
end;

procedure TMaxxRuralContainer.SetBorderWidth(const AValue: Integer);
begin
  if FBorderWidth = AValue then
    Exit;
  FBorderWidth := AValue;
  if FBorderWidth < 0 then
    FBorderWidth := 0;
  InvalidateChrome;
end;

procedure TMaxxRuralContainer.SetContentPadding(const AValue: Integer);
begin
  if FContentPadding = AValue then
    Exit;
  FContentPadding := AValue;
  if FContentPadding < 0 then
    FContentPadding := 0;
  InvalidateChrome;
end;

procedure TMaxxRuralContainer.SetCornerRadius(const AValue: Integer);
var
  LPreviousRadius: Integer;
begin
  if FCornerRadius = AValue then
    Exit;
  LPreviousRadius := FCornerRadius;
  FCornerRadius := AValue;
  if FCornerRadius < 0 then
    FCornerRadius := 0;
  if FBorderRadius = LPreviousRadius then
    FBorderRadius := FCornerRadius;
  InvalidateChrome;
end;

procedure TMaxxRuralContainer.SetHeaderHeight(const AValue: Integer);
begin
  if FHeaderHeight = AValue then
    Exit;
  FHeaderHeight := AValue;
  if FHeaderHeight < 0 then
    FHeaderHeight := 0;
  InvalidateChrome;
end;

procedure TMaxxRuralContainer.SetSectionNumber(const AValue: Integer);
begin
  if FSectionNumber = AValue then
    Exit;
  FSectionNumber := AValue;
  if FSectionNumber < 0 then
    FSectionNumber := 0;
  InvalidateChrome;
end;

procedure TMaxxRuralContainer.SetShowHeader(const AValue: Boolean);
begin
  if FShowHeader = AValue then
    Exit;
  FShowHeader := AValue;
  InvalidateChrome;
end;

procedure TMaxxRuralContainer.SetSubtitle(const AValue: string);
begin
  if FSubtitle = AValue then
    Exit;
  FSubtitle := AValue;
  InvalidateChrome;
end;

procedure TMaxxRuralContainer.SetSubtitleColor(const AValue: TAlphaColor);
var
  LValue: TAlphaColor;
begin
  LValue := TMaxxRuralComponentColors.Normalize(AValue);
  if FSubtitleColor = LValue then
    Exit;
  FSubtitleColor := LValue;
  UpdateHeaderLabels;
  InvalidateChrome;
end;

procedure TMaxxRuralContainer.SetTitle(const AValue: string);
begin
  if FTitle = AValue then
    Exit;
  FTitle := AValue;
  UpdateHeaderLabels;
  InvalidateChrome;
end;

procedure TMaxxRuralContainer.SetTitleColor(const AValue: TAlphaColor);
var
  LValue: TAlphaColor;
begin
  LValue := TMaxxRuralComponentColors.Normalize(AValue);
  if FTitleColor = LValue then
    Exit;
  FTitleColor := LValue;
  UpdateHeaderLabels;
  InvalidateChrome;
end;

procedure TMaxxRuralContainer.UpdateHeaderLabels;
var
  LContentWidth: Integer;
  LPadding: Integer;
  LText: string;
begin
  if (FTitleLabel = nil) or (FSubtitleLabel = nil) then
    Exit;
  if not HandleAllocated then
    Exit;

  LPadding := ScaleMetric(FContentPadding);
  LContentWidth := Width - (LPadding * 2);
  if LContentWidth < 0 then
    LContentWidth := 0;

  LText := HeaderText;

  FTitleLabel.Visible := FShowHeader and (LText <> '');
  FTitleLabel.SetBounds(LPadding, LPadding + ScaleMetric(5), LContentWidth, ScaleMetric(20));
  FTitleLabel.Text := LText;
  FTitleLabel.FontFamily := TMaxxRuralComponentFontInstaller.FontFamily;
  FTitleLabel.FontSize := 10;
  FTitleLabel.Bold := True;
  FTitleLabel.TextColor := FTitleColor;
  FTitleLabel.HorzAlign := mthaLeft;
  FTitleLabel.VertAlign := mtvaCenter;
  FTitleLabel.MaxLines := 1;

  FSubtitleLabel.Visible := FShowHeader and (FSubtitle.Trim <> '');
  FSubtitleLabel.SetBounds(LPadding, LPadding + ScaleMetric(29), LContentWidth, ScaleMetric(17));
  FSubtitleLabel.Text := FSubtitle;
  FSubtitleLabel.FontFamily := TMaxxRuralComponentFontInstaller.FontFamily;
  FSubtitleLabel.FontSize := 8;
  FSubtitleLabel.Bold := False;
  FSubtitleLabel.TextColor := FSubtitleColor;
  FSubtitleLabel.HorzAlign := mthaLeft;
  FSubtitleLabel.VertAlign := mtvaCenter;
  FSubtitleLabel.MaxLines := 1;

end;

procedure TMaxxRuralContainer.UpdatePaintBoxBounds;
var
  LHeight: Integer;
  LWidth: Integer;
begin
  if FPaintBox = nil then
    Exit;

  if HandleAllocated then
  begin
    LWidth := ClientWidth;
    LHeight := ClientHeight;
  end
  else
  begin
    LWidth := Width;
    LHeight := Height;
  end;

  if (FPaintBox.Left <> 0) or (FPaintBox.Top <> 0) or
    (FPaintBox.Width <> LWidth) or (FPaintBox.Height <> LHeight) then
    FPaintBox.SetBounds(0, 0, LWidth, LHeight);

end;

procedure TMaxxRuralContainer.WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
begin
  AMessage.Result := 1;
end;

end.
