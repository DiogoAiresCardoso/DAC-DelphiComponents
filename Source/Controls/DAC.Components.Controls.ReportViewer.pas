unit DAC.Components.Controls.ReportViewer;

interface

uses
  System.Classes,
  System.Skia,
  System.Types,
  Winapi.Messages,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.Skia,
  DAC.Components.Skia.Renderer;

type
  TDACReportViewer = class(TCustomControl)
  private
    FPageCount: Integer;
    FPageIndex: Integer;
    FPaintBox: TSkPaintBox;
    FRenderer: TDACSkiaRenderer;
    FZoomPercent: Integer;
    procedure PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    procedure SetPageCount(const AValue: Integer);
    procedure SetPageIndex(const AValue: Integer);
    procedure SetZoomPercent(const AValue: Integer);
    procedure UpdatePaintBoxBounds;
    procedure WMEraseBkgnd(var AMessage: TWMEraseBkgnd); message WM_ERASEBKGND;
  protected
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
    property PageCount: Integer read FPageCount write SetPageCount default 1;
    property PageIndex: Integer read FPageIndex write SetPageIndex default 1;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property TabOrder;
    property TabStop default True;
    property Visible;
    property ZoomPercent: Integer read FZoomPercent write SetZoomPercent default 100;
  end;

implementation

uses
  System.Math,
  System.SysUtils,
  DAC.Components.DesignSystem.ColorTokens,
  DAC.Components.DesignSystem.Fonts;

constructor TDACReportViewer.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  Width := 720;
  Height := 360;
  TabStop := True;
  ParentColor := False;
  StyleElements := [];
  FPageCount := 1;
  FPageIndex := 1;
  FZoomPercent := 100;
  FRenderer := TDACSkiaRenderer.Create;
  FPaintBox := TSkPaintBox.Create(Self);
  FPaintBox.Parent := Self;
  FPaintBox.SetSubComponent(True);
  FPaintBox.StyleElements := [];
  FPaintBox.OnDraw := PaintBoxDraw;
end;

destructor TDACReportViewer.Destroy;
begin
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
begin
  FRenderer.FillRoundRect(ACanvas, TRectF.Create(0, 0, ADest.Width, ADest.Height),
    TDACComponentColors.White, 8, 255);
  FRenderer.StrokeRoundRect(ACanvas, TRectF.Create(0.5, 0.5, ADest.Width - 0.5, ADest.Height - 0.5),
    TDACComponentColors.ControlBorder, 8, 1, 255);

  LToolbar := TRectF.Create(0.5, 0.5, ADest.Width - 0.5, 42);
  FRenderer.FillRoundRect(ACanvas, LToolbar, TDACComponentColors.Alpha(248, 250, 252), 8, 255);
  FRenderer.Text(ACanvas, Format('%d / %d', [FPageIndex, FPageCount]),
    TDACComponentFontInstaller.FontFamily, 24, 26, 11,
    TDACComponentColors.ControlText, True, 80);
  FRenderer.Text(ACanvas, Format('%d%%', [FZoomPercent]),
    TDACComponentFontInstaller.FontFamily, ADest.Width - 72, 26, 11,
    TDACComponentColors.TextSecondary, False, 56);
  ACanvas.ClipRect(TRectF.Create(0, 42, ADest.Width, ADest.Height));
  LPage := TRectF.Create((ADest.Width - 300) / 2, 62, (ADest.Width + 300) / 2,
    ADest.Height - 18);
  FRenderer.FillRoundRect(ACanvas, LPage, TDACComponentColors.White, 4, 255);
  FRenderer.StrokeRoundRect(ACanvas, LPage, TDACComponentColors.ControlBorder, 4, 1, 255);
  FRenderer.Text(ACanvas, 'Relatorio de Vendas',
    TDACComponentFontInstaller.FontFamily, LPage.Left + 24, LPage.Top + 34,
    16, TDACComponentColors.ControlText, True, LPage.Width - 48);
  FRenderer.Text(ACanvas, 'Periodo: 01/05/2025 a 24/05/2025',
    TDACComponentFontInstaller.FontFamily, LPage.Left + 24, LPage.Top + 56,
    9, TDACComponentColors.TextSecondary, False, LPage.Width - 48);
  LTop := LPage.Top + 86;
  FRenderer.FillRoundRect(ACanvas, TRectF.Create(LPage.Left + 24, LTop,
    LPage.Right - 24, LTop + 24), TDACComponentColors.Alpha(248, 250, 252), 0, 255);
  FRenderer.Text(ACanvas, 'Produto', TDACComponentFontInstaller.FontFamily,
    LPage.Left + 34, LTop + 16, 9, TDACComponentColors.ControlText, True, 80);
  FRenderer.Text(ACanvas, 'Valor Total', TDACComponentFontInstaller.FontFamily,
    LPage.Right - 112, LTop + 16, 9, TDACComponentColors.ControlText, True, 80);
  FRenderer.Text(ACanvas, 'Notebook Dell', TDACComponentFontInstaller.FontFamily,
    LPage.Left + 34, LTop + 48, 9, TDACComponentColors.ControlText, False, 120);
  FRenderer.Text(ACanvas, 'R$ 48.750,00', TDACComponentFontInstaller.FontFamily,
    LPage.Right - 112, LTop + 48, 9, TDACComponentColors.ControlText, False, 90);
end;

procedure TDACReportViewer.Redraw;
begin
  if (FPaintBox <> nil) and not (csDestroying in ComponentState) and
    ((Parent <> nil) or not (csDesigning in ComponentState)) then
    FPaintBox.Redraw;
  Invalidate;
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

procedure TDACReportViewer.UpdatePaintBoxBounds;
begin
  if FPaintBox <> nil then
    FPaintBox.SetBounds(0, 0, Width, Height);
end;

procedure TDACReportViewer.WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
begin
  AMessage.Result := 1;
end;

end.

