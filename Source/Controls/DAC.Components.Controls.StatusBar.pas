unit MaxxRural.Components.Controls.StatusBar;

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
  TMaxxRuralStatusBar = class(TCustomControl)
  private
    FLeftText: string;
    FPaintBox: TSkPaintBox;
    FRenderer: TMaxxRuralSkiaRenderer;
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
  MaxxRural.Components.DesignSystem.ColorTokens,
  MaxxRural.Components.DesignSystem.Fonts;

constructor TMaxxRuralStatusBar.Create(AOwner: TComponent);
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
  FRenderer := TMaxxRuralSkiaRenderer.Create;
  FPaintBox := TSkPaintBox.Create(Self);
  FPaintBox.Parent := Self;
  FPaintBox.SetSubComponent(True);
  FPaintBox.StyleElements := [];
  FPaintBox.OnDraw := PaintBoxDraw;
end;

destructor TMaxxRuralStatusBar.Destroy;
begin
  FPaintBox.Free;
  FRenderer.Free;
  inherited;
end;

procedure TMaxxRuralStatusBar.CreateWnd;
begin
  inherited;
  UpdatePaintBoxBounds;
  Redraw;
end;

procedure TMaxxRuralStatusBar.Loaded;
begin
  inherited;
  UpdatePaintBoxBounds;
  Redraw;
end;

procedure TMaxxRuralStatusBar.PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
  const ADest: TRectF; const AOpacity: Single);
var
  LPaint: ISkPaint;
  LRect: TRectF;
begin
  LRect := TRectF.Create(0.5, 0.5, ADest.Width - 0.5, ADest.Height - 0.5);
  FRenderer.FillRoundRect(ACanvas, LRect, TMaxxRuralComponentColors.White, 0, 255);
  FRenderer.StrokeRoundRect(ACanvas, LRect, TMaxxRuralComponentColors.ControlBorder, 0, 1, 255);
  LPaint := TSkPaint.Create(TSkPaintStyle.Fill);
  LPaint.AntiAlias := True;
  LPaint.Color := TMaxxRuralComponentColors.Primary;
  ACanvas.DrawCircle(16, ADest.Height / 2, 4, LPaint);
  FRenderer.Text(ACanvas, FLeftText, TMaxxRuralComponentFontInstaller.FontFamily,
    28, 22, 11, TMaxxRuralComponentColors.ControlText, False,
    (ADest.Width / 2) - 36);
  FRenderer.Text(ACanvas, FRightText, TMaxxRuralComponentFontInstaller.FontFamily,
    ADest.Width / 2, 22, 11, TMaxxRuralComponentColors.TextSecondary, False,
    (ADest.Width / 2) - 16);
end;

procedure TMaxxRuralStatusBar.Redraw;
begin
  if (FPaintBox <> nil) and not (csDestroying in ComponentState) and
    ((Parent <> nil) or not (csDesigning in ComponentState)) then
    FPaintBox.Redraw;
  Invalidate;
end;

procedure TMaxxRuralStatusBar.Resize;
begin
  inherited;
  UpdatePaintBoxBounds;
  Redraw;
end;

procedure TMaxxRuralStatusBar.SetLeftText(const AValue: string);
begin
  if FLeftText = AValue then
    Exit;
  FLeftText := AValue;
  Redraw;
end;

procedure TMaxxRuralStatusBar.SetRightText(const AValue: string);
begin
  if FRightText = AValue then
    Exit;
  FRightText := AValue;
  Redraw;
end;

procedure TMaxxRuralStatusBar.UpdatePaintBoxBounds;
begin
  if FPaintBox <> nil then
    FPaintBox.SetBounds(0, 0, Width, Height);
end;

procedure TMaxxRuralStatusBar.WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
begin
  AMessage.Result := 1;
end;

end.
