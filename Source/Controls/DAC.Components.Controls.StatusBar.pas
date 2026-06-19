unit DAC.Components.Controls.StatusBar;

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
  TDACStatusBar = class(TCustomControl)
  private
    FLeftText: string;
    FPaintBox: TSkPaintBox;
    FRenderer: TDACSkiaRenderer;
    FRightText: string;
    procedure PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    procedure SetLeftText(const AValue: string);
    procedure SetRightText(const AValue: string);
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
    property LeftText: string read FLeftText write SetLeftText;
    property ParentShowHint;
    property PopupMenu;
    property RightText: string read FRightText write SetRightText;
    property ShowHint;
    property TabOrder;
    property TabStop default False;
    property Visible;
  end;

implementation

uses
  DAC.Components.DesignSystem.ColorTokens,
  DAC.Components.DesignSystem.Fonts;

constructor TDACStatusBar.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  Width := 620;
  Height := 34;
  TabStop := False;
  ParentColor := False;
  StyleElements := [];
  FLeftText := 'Conectado';
  FRightText := 'Delphi + VCL + Skia';
  FRenderer := TDACSkiaRenderer.Create;
  FPaintBox := TSkPaintBox.Create(Self);
  FPaintBox.Parent := Self;
  FPaintBox.SetSubComponent(True);
  FPaintBox.StyleElements := [];
  FPaintBox.OnDraw := PaintBoxDraw;
end;

destructor TDACStatusBar.Destroy;
begin
  FPaintBox.Free;
  FRenderer.Free;
  inherited;
end;

procedure TDACStatusBar.CreateWnd;
begin
  inherited;
  UpdatePaintBoxBounds;
  Redraw;
end;

procedure TDACStatusBar.Loaded;
begin
  inherited;
  UpdatePaintBoxBounds;
  Redraw;
end;

procedure TDACStatusBar.PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
  const ADest: TRectF; const AOpacity: Single);
var
  LPaint: ISkPaint;
  LRect: TRectF;
begin
  LRect := TRectF.Create(0.5, 0.5, ADest.Width - 0.5, ADest.Height - 0.5);
  FRenderer.FillRoundRect(ACanvas, LRect, TDACComponentColors.White, 0, 255);
  FRenderer.StrokeRoundRect(ACanvas, LRect, TDACComponentColors.ControlBorder, 0, 1, 255);
  LPaint := TSkPaint.Create(TSkPaintStyle.Fill);
  LPaint.AntiAlias := True;
  LPaint.Color := TDACComponentColors.Primary;
  ACanvas.DrawCircle(16, ADest.Height / 2, 4, LPaint);
  FRenderer.Text(ACanvas, FLeftText, TDACComponentFontInstaller.FontFamily,
    28, 22, 11, TDACComponentColors.ControlText, False,
    (ADest.Width / 2) - 36);
  FRenderer.Text(ACanvas, FRightText, TDACComponentFontInstaller.FontFamily,
    ADest.Width / 2, 22, 11, TDACComponentColors.TextSecondary, False,
    (ADest.Width / 2) - 16);
end;

procedure TDACStatusBar.Redraw;
begin
  if (FPaintBox <> nil) and not (csDestroying in ComponentState) and
    ((Parent <> nil) or not (csDesigning in ComponentState)) then
    FPaintBox.Redraw;
  Invalidate;
end;

procedure TDACStatusBar.Resize;
begin
  inherited;
  UpdatePaintBoxBounds;
  Redraw;
end;

procedure TDACStatusBar.SetLeftText(const AValue: string);
begin
  if FLeftText = AValue then
    Exit;
  FLeftText := AValue;
  Redraw;
end;

procedure TDACStatusBar.SetRightText(const AValue: string);
begin
  if FRightText = AValue then
    Exit;
  FRightText := AValue;
  Redraw;
end;

procedure TDACStatusBar.UpdatePaintBoxBounds;
begin
  if FPaintBox <> nil then
    FPaintBox.SetBounds(0, 0, Width, Height);
end;

procedure TDACStatusBar.WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
begin
  AMessage.Result := 1;
end;

end.

