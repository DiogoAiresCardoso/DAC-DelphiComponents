unit MaxxRural.Components.Controls.ReportViewer;

interface

uses
  System.Classes,
  System.Skia,
  System.Types,
  Winapi.Messages,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.Skia,
  MaxxRural.Components.Skia.Renderer;

type
  TMaxxRuralReportViewer = class(TCustomControl)
  private
    FPageCount: Integer;
    FPageIndex: Integer;
    FPaintBox: TSkPaintBox;
    FRenderer: TMaxxRuralSkiaRenderer;
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
  MaxxRural.Components.DesignSystem.ColorTokens,
  MaxxRural.Components.DesignSystem.Fonts;

constructor TMaxxRuralReportViewer.Create(AOwner: TComponent);
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
  FRenderer := TMaxxRuralSkiaRenderer.Create;
  FPaintBox := TSkPaintBox.Create(Self);
  FPaintBox.Parent := Self;
  FPaintBox.SetSubComponent(True);
  FPaintBox.StyleElements := [];
  FPaintBox.OnDraw := PaintBoxDraw;
end;

destructor TMaxxRuralReportViewer.Destroy;
begin
  FPaintBox.Free;
  FRenderer.Free;
  inherited;
end;

procedure TMaxxRuralReportViewer.CreateWnd;
begin
  inherited;
  UpdatePaintBoxBounds;
  Redraw;
end;

procedure TMaxxRuralReportViewer.Loaded;
begin
  inherited;
  UpdatePaintBoxBounds;
  Redraw;
end;

procedure TMaxxRuralReportViewer.PaintBoxDraw(Sender: TObject;
  const ACanvas: ISkCanvas; const ADest: TRectF; const AOpacity: Single);
var
  LPage: TRectF;
  LToolbar: TRectF;
  LTop: Single;
begin
  FRenderer.FillRoundRect(ACanvas, TRectF.Create(0, 0, ADest.Width, ADest.Height),
    TMaxxRuralComponentColors.White, 8, 255);
  FRenderer.StrokeRoundRect(ACanvas, TRectF.Create(0.5, 0.5, ADest.Width - 0.5, ADest.Height - 0.5),
    TMaxxRuralComponentColors.ControlBorder, 8, 1, 255);

  LToolbar := TRectF.Create(0.5, 0.5, ADest.Width - 0.5, 42);
  FRenderer.FillRoundRect(ACanvas, LToolbar, TMaxxRuralComponentColors.Alpha(248, 250, 252), 8, 255);
  FRenderer.Text(ACanvas, Format('%d / %d', [FPageIndex, FPageCount]),
    TMaxxRuralComponentFontInstaller.FontFamily, 24, 26, 11,
    TMaxxRuralComponentColors.ControlText, True, 80);
  FRenderer.Text(ACanvas, Format('%d%%', [FZoomPercent]),
    TMaxxRuralComponentFontInstaller.FontFamily, ADest.Width - 72, 26, 11,
    TMaxxRuralComponentColors.TextSecondary, False, 56);
  ACanvas.ClipRect(TRectF.Create(0, 42, ADest.Width, ADest.Height));
  LPage := TRectF.Create((ADest.Width - 300) / 2, 62, (ADest.Width + 300) / 2,
    ADest.Height - 18);
  FRenderer.FillRoundRect(ACanvas, LPage, TMaxxRuralComponentColors.White, 4, 255);
  FRenderer.StrokeRoundRect(ACanvas, LPage, TMaxxRuralComponentColors.ControlBorder, 4, 1, 255);
  FRenderer.Text(ACanvas, 'Relatorio de Vendas',
    TMaxxRuralComponentFontInstaller.FontFamily, LPage.Left + 24, LPage.Top + 34,
    16, TMaxxRuralComponentColors.ControlText, True, LPage.Width - 48);
  FRenderer.Text(ACanvas, 'Periodo: 01/05/2025 a 24/05/2025',
    TMaxxRuralComponentFontInstaller.FontFamily, LPage.Left + 24, LPage.Top + 56,
    9, TMaxxRuralComponentColors.TextSecondary, False, LPage.Width - 48);
  LTop := LPage.Top + 86;
  FRenderer.FillRoundRect(ACanvas, TRectF.Create(LPage.Left + 24, LTop,
    LPage.Right - 24, LTop + 24), TMaxxRuralComponentColors.Alpha(248, 250, 252), 0, 255);
  FRenderer.Text(ACanvas, 'Produto', TMaxxRuralComponentFontInstaller.FontFamily,
    LPage.Left + 34, LTop + 16, 9, TMaxxRuralComponentColors.ControlText, True, 80);
  FRenderer.Text(ACanvas, 'Valor Total', TMaxxRuralComponentFontInstaller.FontFamily,
    LPage.Right - 112, LTop + 16, 9, TMaxxRuralComponentColors.ControlText, True, 80);
  FRenderer.Text(ACanvas, 'Notebook Dell', TMaxxRuralComponentFontInstaller.FontFamily,
    LPage.Left + 34, LTop + 48, 9, TMaxxRuralComponentColors.ControlText, False, 120);
  FRenderer.Text(ACanvas, 'R$ 48.750,00', TMaxxRuralComponentFontInstaller.FontFamily,
    LPage.Right - 112, LTop + 48, 9, TMaxxRuralComponentColors.ControlText, False, 90);
end;

procedure TMaxxRuralReportViewer.Redraw;
begin
  if (FPaintBox <> nil) and not (csDestroying in ComponentState) and
    ((Parent <> nil) or not (csDesigning in ComponentState)) then
    FPaintBox.Redraw;
  Invalidate;
end;

procedure TMaxxRuralReportViewer.Resize;
begin
  inherited;
  UpdatePaintBoxBounds;
  Redraw;
end;

procedure TMaxxRuralReportViewer.SetPageCount(const AValue: Integer);
begin
  FPageCount := Max(1, AValue);
  if FPageIndex > FPageCount then
    FPageIndex := FPageCount;
  Redraw;
end;

procedure TMaxxRuralReportViewer.SetPageIndex(const AValue: Integer);
begin
  FPageIndex := Max(1, Min(AValue, FPageCount));
  Redraw;
end;

procedure TMaxxRuralReportViewer.SetZoomPercent(const AValue: Integer);
begin
  FZoomPercent := Max(10, Min(AValue, 400));
  Redraw;
end;

procedure TMaxxRuralReportViewer.UpdatePaintBoxBounds;
begin
  if FPaintBox <> nil then
    FPaintBox.SetBounds(0, 0, Width, Height);
end;

procedure TMaxxRuralReportViewer.WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
begin
  AMessage.Result := 1;
end;

end.
