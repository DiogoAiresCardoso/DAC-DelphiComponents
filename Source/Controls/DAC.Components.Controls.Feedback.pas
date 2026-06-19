unit DAC.Components.Controls.Feedback;

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
  DAC.Components.DesignSystem.SemanticColors,
  DAC.Components.Skia.Renderer;

type
  TDACFeedbackStatus = TDACSemanticStatus;

  TDACToast = class(TCustomControl)
  private
    FMessageText: string;
    FPaintBox: TSkPaintBox;
    FRenderer: TDACSkiaRenderer;
    FStatus: TDACFeedbackStatus;
    FTitleText: string;
    procedure PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    procedure SetMessageText(const AValue: string);
    procedure SetStatus(const AValue: TDACFeedbackStatus);
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
    property Status: TDACFeedbackStatus read FStatus write SetStatus default mssSuccess;
    property TabOrder;
    property TabStop default False;
    property TitleText: string read FTitleText write SetTitleText;
    property Visible;
  end;

  TDACModalDialog = class(TDACToast)
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

uses
  DAC.Components.DesignSystem.ColorTokens,
  DAC.Components.DesignSystem.Fonts;

constructor TDACToast.Create(AOwner: TComponent);
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
  FRenderer := TDACSkiaRenderer.Create;
  FPaintBox := TSkPaintBox.Create(Self);
  FPaintBox.Parent := Self;
  FPaintBox.SetSubComponent(True);
  FPaintBox.StyleElements := [];
  FPaintBox.OnDraw := PaintBoxDraw;
end;

destructor TDACToast.Destroy;
begin
  FPaintBox.Free;
  FRenderer.Free;
  inherited;
end;

procedure TDACToast.ChangeScale(M, D: Integer);
begin
  inherited;
  Redraw;
end;

procedure TDACToast.CreateWnd;
begin
  inherited;
  UpdatePaintBoxBounds;
  Redraw;
end;

procedure TDACToast.Loaded;
begin
  inherited;
  UpdatePaintBoxBounds;
  Redraw;
end;

procedure TDACToast.PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
  const ADest: TRectF; const AOpacity: Single);
var
  LColors: TDACSemanticColorSet;
  LPaint: ISkPaint;
  LRect: TRectF;
begin
  LColors := TDACSemanticColors.ColorsFor(FStatus);
  LRect := TRectF.Create(0.5, 0.5, ADest.Width - 0.5, ADest.Height - 0.5);
  FRenderer.FillRoundRect(ACanvas, LRect, LColors.AccentDark, 8, 255);
  FRenderer.StrokeRoundRect(ACanvas, LRect, LColors.AccentLight, 8, 1, 150);
  LPaint := TSkPaint.Create(TSkPaintStyle.Fill);
  LPaint.AntiAlias := True;
  LPaint.Color := TDACComponentColors.White;
  ACanvas.DrawCircle(24, ADest.Height / 2, 9, LPaint);
  FRenderer.Text(ACanvas, FTitleText, TDACComponentFontInstaller.FontFamily,
    46, 30, 12, TDACComponentColors.White, True, ADest.Width - 58);
  FRenderer.Text(ACanvas, FMessageText, TDACComponentFontInstaller.FontFamily,
    46, 50, 11, TDACComponentColors.White, False, ADest.Width - 58);
end;

procedure TDACToast.Redraw;
begin
  if (FPaintBox <> nil) and not (csDestroying in ComponentState) and
    ((Parent <> nil) or not (csDesigning in ComponentState)) then
    FPaintBox.Redraw;
  Invalidate;
end;

procedure TDACToast.Resize;
begin
  inherited;
  UpdatePaintBoxBounds;
  Redraw;
end;

procedure TDACToast.SetMessageText(const AValue: string);
begin
  if FMessageText = AValue then
    Exit;
  FMessageText := AValue;
  Redraw;
end;

procedure TDACToast.SetStatus(const AValue: TDACFeedbackStatus);
begin
  if FStatus = AValue then
    Exit;
  FStatus := AValue;
  Redraw;
end;

procedure TDACToast.SetTitleText(const AValue: string);
begin
  if FTitleText = AValue then
    Exit;
  FTitleText := AValue;
  Redraw;
end;

procedure TDACToast.UpdatePaintBoxBounds;
begin
  if FPaintBox <> nil then
    FPaintBox.SetBounds(0, 0, Width, Height);
end;

procedure TDACToast.WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
begin
  AMessage.Result := 1;
end;

constructor TDACModalDialog.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := 320;
  Height := 180;
  TitleText := 'Confirmacao';
  MessageText := 'Deseja confirmar esta operacao?';
end;

end.

