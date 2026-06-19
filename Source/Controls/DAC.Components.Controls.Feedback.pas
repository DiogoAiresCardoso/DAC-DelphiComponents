unit MaxxRural.Components.Controls.Feedback;

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
  MaxxRural.Components.DesignSystem.SemanticColors,
  MaxxRural.Components.Skia.Renderer;

type
  TMaxxRuralFeedbackStatus = TMaxxRuralSemanticStatus;

  TMaxxRuralToast = class(TCustomControl)
  private
    FMessageText: string;
    FPaintBox: TSkPaintBox;
    FRenderer: TMaxxRuralSkiaRenderer;
    FStatus: TMaxxRuralFeedbackStatus;
    FTitleText: string;
    procedure PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    procedure SetMessageText(const AValue: string);
    procedure SetStatus(const AValue: TMaxxRuralFeedbackStatus);
    procedure SetTitleText(const AValue: string);
    procedure UpdatePaintBoxBounds;
    procedure WMEraseBkgnd(var AMessage: TWMEraseBkgnd); message WM_ERASEBKGND;
  protected
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
    property Constraints;
    property Enabled;
    property MessageText: string read FMessageText write SetMessageText;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property Status: TMaxxRuralFeedbackStatus read FStatus write SetStatus default mssSuccess;
    property TabOrder;
    property TabStop default False;
    property TitleText: string read FTitleText write SetTitleText;
    property Visible;
  end;

  TMaxxRuralModalDialog = class(TMaxxRuralToast)
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

uses
  MaxxRural.Components.DesignSystem.ColorTokens,
  MaxxRural.Components.DesignSystem.Fonts;

constructor TMaxxRuralToast.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  Width := 260;
  Height := 72;
  TabStop := False;
  ParentColor := False;
  StyleElements := [];
  FStatus := mssSuccess;
  FTitleText := 'Operacao realizada';
  FMessageText := 'Mensagem de feedback.';
  FRenderer := TMaxxRuralSkiaRenderer.Create;
  FPaintBox := TSkPaintBox.Create(Self);
  FPaintBox.Parent := Self;
  FPaintBox.SetSubComponent(True);
  FPaintBox.StyleElements := [];
  FPaintBox.OnDraw := PaintBoxDraw;
end;

destructor TMaxxRuralToast.Destroy;
begin
  FPaintBox.Free;
  FRenderer.Free;
  inherited;
end;

procedure TMaxxRuralToast.ChangeScale(M, D: Integer);
begin
  inherited;
  Redraw;
end;

procedure TMaxxRuralToast.CreateWnd;
begin
  inherited;
  UpdatePaintBoxBounds;
  Redraw;
end;

procedure TMaxxRuralToast.Loaded;
begin
  inherited;
  UpdatePaintBoxBounds;
  Redraw;
end;

procedure TMaxxRuralToast.PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
  const ADest: TRectF; const AOpacity: Single);
var
  LColors: TMaxxRuralSemanticColorSet;
  LPaint: ISkPaint;
  LRect: TRectF;
begin
  LColors := TMaxxRuralSemanticColors.ColorsFor(FStatus);
  LRect := TRectF.Create(0.5, 0.5, ADest.Width - 0.5, ADest.Height - 0.5);
  FRenderer.FillRoundRect(ACanvas, LRect, LColors.AccentDark, 8, 255);
  FRenderer.StrokeRoundRect(ACanvas, LRect, LColors.AccentLight, 8, 1, 150);
  LPaint := TSkPaint.Create(TSkPaintStyle.Fill);
  LPaint.AntiAlias := True;
  LPaint.Color := TMaxxRuralComponentColors.White;
  ACanvas.DrawCircle(24, ADest.Height / 2, 9, LPaint);
  FRenderer.Text(ACanvas, FTitleText, TMaxxRuralComponentFontInstaller.FontFamily,
    46, 30, 12, TMaxxRuralComponentColors.White, True, ADest.Width - 58);
  FRenderer.Text(ACanvas, FMessageText, TMaxxRuralComponentFontInstaller.FontFamily,
    46, 50, 11, TMaxxRuralComponentColors.White, False, ADest.Width - 58);
end;

procedure TMaxxRuralToast.Redraw;
begin
  if (FPaintBox <> nil) and not (csDestroying in ComponentState) and
    ((Parent <> nil) or not (csDesigning in ComponentState)) then
    FPaintBox.Redraw;
  Invalidate;
end;

procedure TMaxxRuralToast.Resize;
begin
  inherited;
  UpdatePaintBoxBounds;
  Redraw;
end;

procedure TMaxxRuralToast.SetMessageText(const AValue: string);
begin
  if FMessageText = AValue then
    Exit;
  FMessageText := AValue;
  Redraw;
end;

procedure TMaxxRuralToast.SetStatus(const AValue: TMaxxRuralFeedbackStatus);
begin
  if FStatus = AValue then
    Exit;
  FStatus := AValue;
  Redraw;
end;

procedure TMaxxRuralToast.SetTitleText(const AValue: string);
begin
  if FTitleText = AValue then
    Exit;
  FTitleText := AValue;
  Redraw;
end;

procedure TMaxxRuralToast.UpdatePaintBoxBounds;
begin
  if FPaintBox <> nil then
    FPaintBox.SetBounds(0, 0, Width, Height);
end;

procedure TMaxxRuralToast.WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
begin
  AMessage.Result := 1;
end;

constructor TMaxxRuralModalDialog.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := 320;
  Height := 180;
  TitleText := 'Confirmacao';
  MessageText := 'Deseja confirmar esta operacao?';
end;

end.
