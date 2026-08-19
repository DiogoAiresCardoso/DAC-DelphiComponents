unit DAC.Components.Controls.ReportViewer;

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
  DAC.Components.DesignSystem.Theme,
  DAC.Components.Skia.Renderer;

type
  TDACReportViewer = class(TCustomControl)
  private
    FPageCount: Integer;
    FPageIndex: Integer;
    FPaintBox: TSkPaintBox;
    FRenderer: TDACSkiaRenderer;
    FTextOverlay: TDACSystemTextOverlay;
    FThemeMode: TDACThemeMode;
    FZoomPercent: Integer;
    procedure PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    procedure SetPageCount(const AValue: Integer);
    procedure SetPageIndex(const AValue: Integer);
    procedure SetZoomPercent(const AValue: Integer);
    procedure SetThemeMode(const AValue: TDACThemeMode);
    procedure ThemeChanged(Sender: TObject);
    procedure UpdatePaintBoxBounds;
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
    property PageCount: Integer read FPageCount write SetPageCount default 1;
    property PageIndex: Integer read FPageIndex write SetPageIndex default 1;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop default True;
    property ThemeMode: TDACThemeMode read FThemeMode write SetThemeMode default dtmInherit;
    property Visible;
    property ZoomPercent: Integer read FZoomPercent write SetZoomPercent default 100;
  end;

implementation

uses
  System.Math,
  System.SysUtils,
  DAC.Components.DesignSystem.ColorTokens,
  DAC.Components.DesignSystem.Fonts,
  DAC.Components.DesignSystem.ComponentStyle,
  DAC.Components.DesignSystem.ControlTokens;

constructor TDACReportViewer.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  Width := Round(TDACComponentStyle.Resolve(dtmInherit).Tokens.Controls.ReportViewerDefaultWidth);
  Height := Round(TDACComponentStyle.Resolve(dtmInherit).Tokens.Controls.ReportViewerDefaultHeight);
  TabStop := True;
  ParentColor := False;
  StyleElements := [];
  FPageCount := 1;
  FPageIndex := 1;
  FZoomPercent := 100;
  FThemeMode := dtmInherit;
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
  TDACThemeManager.RegisterListener(Self, ThemeChanged);
end;

destructor TDACReportViewer.Destroy;
begin
  TDACThemeManager.UnregisterListener(Self);
  FTextOverlay.Free;
  FPaintBox.Free;
  FRenderer.Free;
  inherited;
end;

procedure TDACReportViewer.CreateWnd;
begin
  inherited;
  UpdatePaintBoxBounds;
  Redraw;
end;

procedure TDACReportViewer.Loaded;
begin
  inherited;
  UpdatePaintBoxBounds;
  Redraw;
end;

procedure TDACReportViewer.PaintBoxDraw(Sender: TObject;
  const ACanvas: ISkCanvas; const ADest: TRectF; const AOpacity: Single);
var
  LPage: TRectF;
  LToolbar: TRectF;
  LTop: Single;
  LTokens: TDACControlTokens;
begin
  if ACanvas = nil then
    Exit;
  FRenderer.BeginNativeText(FTextOverlay);
  try
  LTokens := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls;
  FRenderer.FillRoundRect(ACanvas, TRectF.Create(0, 0, ADest.Width, ADest.Height),
    LTokens.ContainerSuiteBackground, LTokens.ReportRadius, LTokens.AlphaOpaque);
  FRenderer.StrokeRoundRect(ACanvas, TRectF.Create(LTokens.ReportBorderWidth / 2, LTokens.ReportBorderWidth / 2, ADest.Width - LTokens.ReportBorderWidth / 2, ADest.Height - LTokens.ReportBorderWidth / 2),
    LTokens.ContainerSuiteBorder, LTokens.ReportRadius, LTokens.ReportBorderWidth,
    LTokens.AlphaOpaque);

  LToolbar := TRectF.Create(LTokens.ReportBorderWidth / 2, LTokens.ReportBorderWidth / 2, ADest.Width - LTokens.ReportBorderWidth / 2, LTokens.ReportToolbarHeight);
  FRenderer.FillRoundRect(ACanvas, LToolbar, LTokens.PopupBackground,
    LTokens.ReportToolbarRadius, LTokens.AlphaOpaque);
  FRenderer.Text(ACanvas, Format('%d / %d', [FPageIndex, FPageCount]),
    TDACComponentStyle.FontFamily, LTokens.ReportToolbarPageX, LTokens.ReportToolbarBaseline, LTokens.ReportToolbarTextSize,
    LTokens.ContainerTitle, True, LTokens.ReportToolbarPageWidth);
  FRenderer.Text(ACanvas, Format('%d%%', [FZoomPercent]),
    TDACComponentStyle.FontFamily, ADest.Width - LTokens.ReportToolbarZoomRight, LTokens.ReportToolbarBaseline, LTokens.ReportToolbarTextSize,
    LTokens.ContainerSubtitle, False, LTokens.ReportToolbarZoomWidth);
  ACanvas.ClipRect(TRectF.Create(0, LTokens.ReportToolbarHeight, ADest.Width, ADest.Height));
  LPage := TRectF.Create((ADest.Width - LTokens.ReportPageWidth) / 2, LTokens.ReportPageTop, (ADest.Width + LTokens.ReportPageWidth) / 2,
    ADest.Height - LTokens.ReportPageBottomInset);
  FRenderer.FillRoundRect(ACanvas, LPage, LTokens.InputBackground,
    LTokens.ReportPageRadius, LTokens.AlphaOpaque);
  FRenderer.StrokeRoundRect(ACanvas, LPage, LTokens.InputBorder,
    LTokens.ReportPageRadius, LTokens.ReportBorderWidth, LTokens.AlphaOpaque);
  FRenderer.Text(ACanvas, 'Relatorio de Vendas',
    TDACComponentStyle.FontFamily, LPage.Left + LTokens.ReportTextInset, LPage.Top + LTokens.ReportTitleTop,
    LTokens.ReportTitleTextSize, LTokens.InputText, True, LPage.Width - (LTokens.ReportTextInset * 2));
  FRenderer.Text(ACanvas, 'Periodo: 01/05/2025 a 24/05/2025',
    TDACComponentStyle.FontFamily, LPage.Left + LTokens.ReportTextInset, LPage.Top + LTokens.ReportSubtitleTop,
    LTokens.ReportBodyTextSize, LTokens.InputHelper, False, LPage.Width - (LTokens.ReportTextInset * 2));
  LTop := LPage.Top + LTokens.ReportRowTop;
  FRenderer.FillRoundRect(ACanvas, TRectF.Create(LPage.Left + LTokens.ReportTextInset, LTop,
    LPage.Right - LTokens.ReportTextInset, LTop + LTokens.ReportRowHeight),
    LTokens.PopupBackground, LTokens.ReportRowRadius, LTokens.AlphaOpaque);
  FRenderer.Text(ACanvas, 'Produto', TDACComponentStyle.FontFamily,
    LPage.Left + LTokens.ReportTextInset + LTokens.ReportColumnInset, LTop + LTokens.ReportToolbarBaseline - LTokens.ReportColumnInset, LTokens.ReportBodyTextSize, LTokens.InputText, True, LTokens.ReportToolbarPageWidth);
  FRenderer.Text(ACanvas, 'Valor Total', TDACComponentStyle.FontFamily,
    LPage.Right - LTokens.ReportValueRight, LTop + LTokens.ReportToolbarBaseline - LTokens.ReportColumnInset, LTokens.ReportBodyTextSize, LTokens.InputText, True, LTokens.ReportToolbarPageWidth);
  FRenderer.Text(ACanvas, 'Notebook Dell', TDACComponentStyle.FontFamily,
    LPage.Left + LTokens.ReportTextInset + LTokens.ReportColumnInset, LTop + LTokens.ReportRowHeight * 2, LTokens.ReportBodyTextSize, LTokens.InputText, False, LTokens.ReportTextWidth);
  FRenderer.Text(ACanvas, 'R$ 48.750,00', TDACComponentStyle.FontFamily,
    LPage.Right - LTokens.ReportValueRight, LTop + LTokens.ReportRowHeight * 2, LTokens.ReportBodyTextSize, LTokens.InputText, False, LTokens.ReportValueWidth);
  finally
    FRenderer.EndNativeText;
  end;
end;

procedure TDACReportViewer.Redraw;
begin
  if (FPaintBox = nil) or (csDestroying in ComponentState) then
    Exit;
  UpdatePaintBoxBounds;
  if csDesigning in ComponentState then
  begin
    if Parent <> nil then
      FPaintBox.Redraw;
    Invalidate;
    Exit;
  end;
  if (Parent <> nil) and HandleAllocated and Parent.HandleAllocated then
    FPaintBox.Redraw;
  if HandleAllocated then
    Invalidate;
end;

function TDACReportViewer.ResolvedBackgroundColor: TAlphaColor;
begin
  Result := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls.ContainerSuiteBackground;
end;

procedure TDACReportViewer.Resize;
begin
  inherited;
  UpdatePaintBoxBounds;
  Redraw;
end;

procedure TDACReportViewer.SetPageCount(const AValue: Integer);
begin
  FPageCount := Max(1, AValue);
  if FPageIndex > FPageCount then
    FPageIndex := FPageCount;
  Redraw;
end;

procedure TDACReportViewer.SetPageIndex(const AValue: Integer);
begin
  FPageIndex := Max(1, Min(AValue, FPageCount));
  Redraw;
end;

procedure TDACReportViewer.SetZoomPercent(const AValue: Integer);
begin
  FZoomPercent := Max(10, Min(AValue, 400));
  Redraw;
end;

procedure TDACReportViewer.SetThemeMode(const AValue: TDACThemeMode);
begin
  if FThemeMode = AValue then Exit;
  FThemeMode := AValue;
  ThemeChanged(Self);
end;

procedure TDACReportViewer.ThemeChanged(Sender: TObject);
begin
  if (FThemeMode = dtmInherit) or (Sender = Self) then
    Redraw;
end;

procedure TDACReportViewer.UpdatePaintBoxBounds;
var
  LHeight: Integer;
  LWidth: Integer;
begin
  if (FPaintBox = nil) or (csLoading in ComponentState) or
    (csDestroying in ComponentState) then
    Exit;
  LWidth := Width;
  LHeight := Height;
  if not (csDesigning in ComponentState) and HandleAllocated then
  begin
    LWidth := ClientWidth;
    LHeight := ClientHeight;
  end;
  FPaintBox.SetBounds(0, 0, LWidth, LHeight);
end;

procedure TDACReportViewer.WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
begin
  AMessage.Result := 1;
end;

end.

