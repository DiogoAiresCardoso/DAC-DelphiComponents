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
  Vcl.Skia,
  DAC.Components.Controls.SystemText,
  DAC.Components.DesignSystem.ColorTokens,
  DAC.Components.DesignSystem.Fonts,
  DAC.Components.Skia.BackgroundPainter,
  DAC.Components.Skia.BorderPainter,
  DAC.Components.Skia.Renderer;

type
  TDACContainerAppearance = (
    mcaSuiteSection,
    mcaDarkPanel,
    mcaTransparent
  );

  TDACContainer = class(TCustomControl)
  private
    FAppearance: TDACContainerAppearance;
    FBackgroundColor: TAlphaColor;
    FBackgroundPainter: TDACSkiaBackgroundPainter;
    FBorderColor: TAlphaColor;
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
    procedure CMParentColorChanged(var AMessage: TMessage); message CM_PARENTCOLORCHANGED;
    function HeaderText: string;
    function LayoutRect: TRect;
    procedure InvalidateChrome;
    procedure PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    function ParentSurfaceColor: TAlphaColor;
    function ScaleFactor: Single;
    function ScaleMetric(const AValue: Integer): Integer;
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
    property Appearance: TDACContainerAppearance read FAppearance write SetAppearance default mcaSuiteSection;
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

constructor TDACContainer.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csAcceptsControls, csOpaque];
  Width := 460;
  Height := 200;
  TabStop := False;
  ParentColor := True;
  StyleElements := [];

  FAppearance := mcaSuiteSection;
  FBackgroundColor := TDACComponentColors.SuiteSectionBackground;
  FBorderColor := TDACComponentColors.ControlBorder;
  FTitleColor := TDACComponentColors.ControlText;
  FSubtitleColor := TDACComponentColors.SuiteSectionSubtitle;
  FBorderRadius := 10;
  FBorderWidth := 1;
  FContentPadding := 16;
  FCornerRadius := 10;
  FHeaderHeight := 42;
  FShowHeader := True;
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
end;

destructor TDACContainer.Destroy;
begin
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
  Redraw;
end;

procedure TDACContainer.AdjustClientRect(var Rect: TRect);
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

procedure TDACContainer.ChangeScale(M, D: Integer);
begin
  inherited;
  UpdateHeaderLabels;
  Redraw;
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
  Invalidate;
end;

procedure TDACContainer.Loaded;
begin
  inherited;
  UpdatePaintBoxBounds;
  UpdateHeaderLabels;
  Redraw;
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

function TDACContainer.ParentSurfaceColor: TAlphaColor;
begin
  Result := TDACComponentColors.ResolveParentSurface(Self);
end;

procedure TDACContainer.Redraw;
begin
  UpdatePaintBoxBounds;
  if (FPaintBox <> nil) and HandleAllocated then
    FPaintBox.Redraw;
end;

procedure TDACContainer.Resize;
begin
  inherited;
  UpdatePaintBoxBounds;
  UpdateHeaderLabels;
  Redraw;
end;

function TDACContainer.ScaleFactor: Single;
begin
  Result := 1;
  if FPaintBox <> nil then
    Result := FPaintBox.ScaleFactor;
  if Result <= 0 then
    Result := 1;
end;

function TDACContainer.ScaleMetric(const AValue: Integer): Integer;
begin
  Result := Round(AValue * ScaleFactor);
  if (AValue > 0) and (Result < 1) then
    Result := 1;
end;

procedure TDACContainer.SetAppearance(
  const AValue: TDACContainerAppearance);
begin
  if FAppearance = AValue then
    Exit;

  FAppearance := AValue;
  case FAppearance of
    mcaSuiteSection:
      begin
        FBackgroundColor := TDACComponentColors.SuiteSectionBackground;
        FBorderColor := TDACComponentColors.SuiteSectionBorder;
        FTitleColor := TDACComponentColors.SuiteSectionTitle;
        FSubtitleColor := TDACComponentColors.SuiteSectionSubtitle;
      end;
    mcaDarkPanel:
      begin
        FBackgroundColor := TDACComponentColors.DarkPanelBackground;
        FBorderColor := TDACComponentColors.DarkPanelBorder;
        FTitleColor := TDACComponentColors.Text;
        FSubtitleColor := TDACComponentColors.TextSecondary;
      end;
    mcaTransparent:
      begin
        FBackgroundColor := TDACComponentColors.Transparent;
        FBorderColor := TDACComponentColors.Transparent;
        FTitleColor := TDACComponentColors.SuiteSectionTitle;
        FSubtitleColor := TDACComponentColors.SuiteSectionSubtitle;
      end;
  end;
  if FAppearance = mcaTransparent then
    Color := clNone
  else
    Color := TDACComponentColors.ToVclColor(FBackgroundColor);
  UpdateHeaderLabels;
  InvalidateChrome;
end;

procedure TDACContainer.SetBackgroundColor(const AValue: TAlphaColor);
var
  LValue: TAlphaColor;
begin
  LValue := TDACComponentColors.Normalize(AValue);
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
  if FBorderColor = LValue then
    Exit;
  FBorderColor := LValue;
  InvalidateChrome;
end;

procedure TDACContainer.SetBorderRadius(const AValue: Integer);
begin
  if FBorderRadius = AValue then
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
  if FContentPadding = AValue then
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
  FTitleLabel.FontFamily := TDACComponentFontInstaller.FontFamily;
  FTitleLabel.FontSize := 10;
  FTitleLabel.Bold := True;
  FTitleLabel.TextColor := FTitleColor;
  FTitleLabel.HorzAlign := mthaLeft;
  FTitleLabel.VertAlign := mtvaCenter;
  FTitleLabel.MaxLines := 1;

  FSubtitleLabel.Visible := FShowHeader and (FSubtitle.Trim <> '');
  FSubtitleLabel.SetBounds(LPadding, LPadding + ScaleMetric(29), LContentWidth, ScaleMetric(17));
  FSubtitleLabel.Text := FSubtitle;
  FSubtitleLabel.FontFamily := TDACComponentFontInstaller.FontFamily;
  FSubtitleLabel.FontSize := 8;
  FSubtitleLabel.Bold := False;
  FSubtitleLabel.TextColor := FSubtitleColor;
  FSubtitleLabel.HorzAlign := mthaLeft;
  FSubtitleLabel.VertAlign := mtvaCenter;
  FSubtitleLabel.MaxLines := 1;

end;

procedure TDACContainer.UpdatePaintBoxBounds;
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

procedure TDACContainer.WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
begin
  AMessage.Result := 1;
end;

end.

