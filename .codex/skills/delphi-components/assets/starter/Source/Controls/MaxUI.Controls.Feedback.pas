unit MaxUI.Controls.Feedback;

{$CODEPAGE 65001}

interface

uses
  System.Classes,
  Winapi.Messages,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.ExtCtrls,
  MaxUI.Types,
  MaxUI.Controls.Buttons;

type
  TMaxPill = class(TGraphicControl)
  private
    FText: string;
    FKind: TMaxPillKind;
    FCloseButton: Boolean;
    FSelected: Boolean;
    FAutoSizePill: Boolean;
    FOnClose: TNotifyEvent;
    procedure SetText(const Value: string);
    procedure SetKind(const Value: TMaxPillKind);
    procedure SetCloseButton(const Value: Boolean);
    procedure SetSelected(const Value: Boolean);
    procedure SetAutoSizePill(const Value: Boolean);
    procedure UpdateAutoSize;
    function CloseRect: TRect;
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Align;
    property Anchors;
    property Font;
    property ParentFont;
    property Hint;
    property ShowHint;
    property Text: string read FText write SetText;
    property Kind: TMaxPillKind read FKind write SetKind default mpkNeutral;
    property CloseButton: Boolean read FCloseButton write SetCloseButton default False;
    property Selected: Boolean read FSelected write SetSelected default False;
    property AutoSizePill: Boolean read FAutoSizePill write SetAutoSizePill default True;
    property OnClick;
    property OnClose: TNotifyEvent read FOnClose write FOnClose;
  end;

  TMaxBadge = class(TMaxPill);
  TMaxChip = class(TMaxPill);
  TMaxTag = class(TMaxPill);

  TMaxLinearProgress = class(TGraphicControl)
  private
    FMinimum: Integer;
    FMaximum: Integer;
    FPosition: Integer;
    FShowValue: Boolean;
    procedure SetMinimum(const Value: Integer);
    procedure SetMaximum(const Value: Integer);
    procedure SetPosition(const Value: Integer);
    procedure SetShowValue(const Value: Boolean);
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Align;
    property Anchors;
    property Font;
    property ParentFont;
    property Minimum: Integer read FMinimum write SetMinimum default 0;
    property Maximum: Integer read FMaximum write SetMaximum default 100;
    property Position: Integer read FPosition write SetPosition default 0;
    property ShowValue: Boolean read FShowValue write SetShowValue default True;
  end;

  TMaxCircularProgress = class(TGraphicControl)
  private
    FMinimum: Integer;
    FMaximum: Integer;
    FPosition: Integer;
    FShowValue: Boolean;
    FStrokeWidth: Integer;
    procedure SetMinimum(const Value: Integer);
    procedure SetMaximum(const Value: Integer);
    procedure SetPosition(const Value: Integer);
    procedure SetShowValue(const Value: Boolean);
    procedure SetStrokeWidth(const Value: Integer);
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Align;
    property Anchors;
    property Font;
    property ParentFont;
    property Minimum: Integer read FMinimum write SetMinimum default 0;
    property Maximum: Integer read FMaximum write SetMaximum default 100;
    property Position: Integer read FPosition write SetPosition default 0;
    property ShowValue: Boolean read FShowValue write SetShowValue default True;
    property StrokeWidth: Integer read FStrokeWidth write SetStrokeWidth default 8;
  end;

  TMaxToast = class(TCustomControl)
  private
    FToastKind: TMaxToastKind;
    FTitle: string;
    FMessageText: string;
    FCloseButton: Boolean;
    FOnClose: TNotifyEvent;
    procedure SetToastKind(const Value: TMaxToastKind);
    procedure SetTitle(const Value: string);
    procedure SetMessageText(const Value: string);
    procedure SetCloseButton(const Value: Boolean);
    function CloseRect: TRect;
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Align;
    property Anchors;
    property Font;
    property ParentFont;
    property ToastKind: TMaxToastKind read FToastKind write SetToastKind default mtkSuccess;
    property Title: string read FTitle write SetTitle;
    property MessageText: string read FMessageText write SetMessageText;
    property CloseButton: Boolean read FCloseButton write SetCloseButton default True;
    property OnClose: TNotifyEvent read FOnClose write FOnClose;
  end;

  TMaxTooltip = class(TGraphicControl)
  private
    FText: string;
    procedure SetText(const Value: string);
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Align;
    property Anchors;
    property Font;
    property ParentFont;
    property Text: string read FText write SetText;
  end;

  TMaxModalPanel = class(TCustomControl)
  private
    FTitle: string;
    FMessageText: string;
    FConfirmCaption: string;
    FCancelCaption: string;
    FConfirmButton: TMaxButton;
    FCancelButton: TMaxButton;
    FOnConfirm: TNotifyEvent;
    FOnCancel: TNotifyEvent;
    procedure SetTitle(const Value: string);
    procedure SetMessageText(const Value: string);
    procedure SetConfirmCaption(const Value: string);
    procedure SetCancelCaption(const Value: string);
    procedure ConfirmClick(Sender: TObject);
    procedure CancelClick(Sender: TObject);
  protected
    procedure Paint; override;
    procedure Resize; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
  public
    constructor Create(AOwner: TComponent); override;
    property ConfirmButton: TMaxButton read FConfirmButton;
    property CancelButton: TMaxButton read FCancelButton;
  published
    property Align;
    property Anchors;
    property Font;
    property ParentFont;
    property TabOrder;
    property TabStop default True;
    property Title: string read FTitle write SetTitle;
    property MessageText: string read FMessageText write SetMessageText;
    property ConfirmCaption: string read FConfirmCaption write SetConfirmCaption;
    property CancelCaption: string read FCancelCaption write SetCancelCaption;
    property OnConfirm: TNotifyEvent read FOnConfirm write FOnConfirm;
    property OnCancel: TNotifyEvent read FOnCancel write FOnCancel;
  end;

  TMaxPagination = class(TCustomControl)
  private
    FCurrentPage: Integer;
    FPageCount: Integer;
    FPageSize: Integer;
    FOnPageChanged: TNotifyEvent;
    procedure SetCurrentPage(const Value: Integer);
    procedure SetPageCount(const Value: Integer);
    procedure SetPageSize(const Value: Integer);
    function VisibleStart: Integer;
    procedure ChangePage(const Value: Integer);
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Align;
    property Anchors;
    property Font;
    property ParentFont;
    property CurrentPage: Integer read FCurrentPage write SetCurrentPage default 1;
    property PageCount: Integer read FPageCount write SetPageCount default 1;
    property PageSize: Integer read FPageSize write SetPageSize default 10;
    property OnPageChanged: TNotifyEvent read FOnPageChanged write FOnPageChanged;
  end;

  TMaxSpinner = class(TGraphicControl)
  private
    FSpinnerStyle: TMaxSpinnerStyle;
    FActive: Boolean;
    FInterval: Cardinal;
    FFrame: Integer;
    FTimer: TTimer;
    procedure SetSpinnerStyle(const Value: TMaxSpinnerStyle);
    procedure SetActive(const Value: Boolean);
    procedure SetInterval(const Value: Cardinal);
    procedure TimerTick(Sender: TObject);
    procedure CMVisibleChanged(var Message: TMessage); message CM_VISIBLECHANGED;
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property Align;
    property Anchors;
    property SpinnerStyle: TMaxSpinnerStyle read FSpinnerStyle write SetSpinnerStyle default mssRing;
    property Active: Boolean read FActive write SetActive default True;
    property Interval: Cardinal read FInterval write SetInterval default 90;
  end;

implementation

uses
  System.Math,
  System.SysUtils,
  Winapi.Windows,
  MaxUI.Dpi,
  MaxUI.Icons,
  MaxUI.Painter,
  MaxUI.Theme;

constructor TMaxPill.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FText := 'Pill';
  FKind := mpkNeutral;
  FCloseButton := False;
  FSelected := False;
  FAutoSizePill := True;
  Font.Name := 'Inter';
  Font.Size := 8;
  Width := 72;
  Height := 26;
end;

function TMaxPill.CloseRect: TRect;
begin
  Result := Rect(Width - MaxScale(22, CurrentPPI), 0, Width, Height);
end;

procedure TMaxPill.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  if (Button = mbLeft) and FCloseButton and PtInRect(CloseRect, Point(X, Y)) then
  begin
    if Assigned(FOnClose) then FOnClose(Self);
  end
  else if Button = mbLeft then
    Click;
end;

procedure TMaxPill.Paint;
begin
  TMaxPainter.DrawPill(Canvas, ClientRect, FText, Font, FKind, FSelected,
    FCloseButton, CurrentPPI);
end;

procedure TMaxPill.SetAutoSizePill(const Value: Boolean);
begin
  if FAutoSizePill = Value then Exit;
  FAutoSizePill := Value;
  UpdateAutoSize;
end;

procedure TMaxPill.SetCloseButton(const Value: Boolean);
begin
  if FCloseButton = Value then Exit;
  FCloseButton := Value;
  UpdateAutoSize;
  Invalidate;
end;

procedure TMaxPill.SetKind(const Value: TMaxPillKind);
begin
  if FKind = Value then Exit;
  FKind := Value;
  Invalidate;
end;

procedure TMaxPill.SetSelected(const Value: Boolean);
begin
  if FSelected = Value then Exit;
  FSelected := Value;
  Invalidate;
end;

procedure TMaxPill.SetText(const Value: string);
begin
  if FText = Value then Exit;
  FText := Value;
  UpdateAutoSize;
  Invalidate;
end;

procedure TMaxPill.UpdateAutoSize;
var
  Extra: Integer;
begin
  if not FAutoSizePill then Exit;
  Canvas.Font.Assign(Font);
  Extra := MaxScale(20, CurrentPPI);
  if FCloseButton then Inc(Extra, MaxScale(18, CurrentPPI));
  Width := Max(MaxScale(32, CurrentPPI), Canvas.TextWidth(FText) + Extra);
  Height := MaxScale(26, CurrentPPI);
end;

constructor TMaxLinearProgress.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FMinimum := 0;
  FMaximum := 100;
  FPosition := 0;
  FShowValue := True;
  Font.Name := 'Inter';
  Font.Size := 8;
  Width := 220;
  Height := 28;
end;

procedure TMaxLinearProgress.Paint;
var
  R: TRect;
  TextRect: TRect;
  S: string;
  Save: Integer;
begin
  R := ClientRect;
  if FShowValue then Dec(R.Right, MaxScale(42, CurrentPPI));
  R.Top := (Height - MaxScale(8, CurrentPPI)) div 2;
  R.Bottom := R.Top + MaxScale(8, CurrentPPI);
  TMaxPainter.DrawLinearProgress(Canvas, R, FPosition, FMinimum, FMaximum,
    MaxScale(4, CurrentPPI));
  if FShowValue then
  begin
    S := IntToStr(FPosition) + '%';
    TextRect := ClientRect;
    TextRect.Left := R.Right + MaxScale(6, CurrentPPI);
    Save := SaveDC(Canvas.Handle);
    try
      Canvas.Font.Assign(Font);
      Canvas.Font.Color := TMaxTheme.Palette.TextSecondary;
      SetBkMode(Canvas.Handle, TRANSPARENT);
      DrawText(Canvas.Handle, PChar(S), Length(S), TextRect,
        DT_CENTER or DT_VCENTER or DT_SINGLELINE);
    finally
      RestoreDC(Canvas.Handle, Save);
    end;
  end;
end;

procedure TMaxLinearProgress.SetMaximum(const Value: Integer);
begin
  FMaximum := Max(FMinimum + 1, Value);
  Position := FPosition;
  Invalidate;
end;

procedure TMaxLinearProgress.SetMinimum(const Value: Integer);
begin
  FMinimum := Min(Value, FMaximum - 1);
  Position := FPosition;
  Invalidate;
end;

procedure TMaxLinearProgress.SetPosition(const Value: Integer);
var
  V: Integer;
begin
  V := EnsureRange(Value, FMinimum, FMaximum);
  if FPosition = V then Exit;
  FPosition := V;
  Invalidate;
end;

procedure TMaxLinearProgress.SetShowValue(const Value: Boolean);
begin
  if FShowValue = Value then Exit;
  FShowValue := Value;
  Invalidate;
end;

constructor TMaxCircularProgress.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FMinimum := 0;
  FMaximum := 100;
  FPosition := 0;
  FShowValue := True;
  FStrokeWidth := 8;
  Font.Name := 'Inter';
  Font.Size := 10;
  Width := 88;
  Height := 88;
end;

procedure TMaxCircularProgress.Paint;
var
  R: TRect;
  CenterX: Integer;
  CenterY: Integer;
  Radius: Integer;
  EndAngle: Double;
  EndX: Integer;
  EndY: Integer;
  S: string;
  Save: Integer;
begin
  R := ClientRect;
  InflateRect(R, -MaxScale(FStrokeWidth, CurrentPPI),
    -MaxScale(FStrokeWidth, CurrentPPI));
  Canvas.Brush.Style := bsClear;
  Canvas.Pen.Width := MaxScale(FStrokeWidth, CurrentPPI);
  Canvas.Pen.Color := TMaxTheme.Palette.Border;
  Canvas.Ellipse(R);

  CenterX := (R.Left + R.Right) div 2;
  CenterY := (R.Top + R.Bottom) div 2;
  Radius := Min(R.Width, R.Height) div 2;
  EndAngle := -Pi / 2 + 2 * Pi *
    (EnsureRange(FPosition, FMinimum, FMaximum) - FMinimum) /
    Max(1, FMaximum - FMinimum);
  EndX := CenterX + Round(Cos(EndAngle) * Radius);
  EndY := CenterY + Round(Sin(EndAngle) * Radius);
  Canvas.Pen.Color := TMaxTheme.Palette.Primary;
  Canvas.Arc(R.Left, R.Top, R.Right, R.Bottom,
    CenterX, CenterY - Radius, EndX, EndY);
  Canvas.Brush.Style := bsSolid;

  if FShowValue then
  begin
    S := IntToStr(FPosition) + '%';
    Save := SaveDC(Canvas.Handle);
    try
      Canvas.Font.Assign(Font);
      Canvas.Font.Style := [fsBold];
      Canvas.Font.Color := TMaxTheme.Palette.Text;
      SetBkMode(Canvas.Handle, TRANSPARENT);
      DrawText(Canvas.Handle, PChar(S), Length(S), ClientRect,
        DT_CENTER or DT_VCENTER or DT_SINGLELINE);
    finally
      RestoreDC(Canvas.Handle, Save);
    end;
  end;
end;

procedure TMaxCircularProgress.SetMaximum(const Value: Integer);
begin
  FMaximum := Max(FMinimum + 1, Value);
  Position := FPosition;
  Invalidate;
end;

procedure TMaxCircularProgress.SetMinimum(const Value: Integer);
begin
  FMinimum := Min(Value, FMaximum - 1);
  Position := FPosition;
  Invalidate;
end;

procedure TMaxCircularProgress.SetPosition(const Value: Integer);
var
  V: Integer;
begin
  V := EnsureRange(Value, FMinimum, FMaximum);
  if FPosition = V then Exit;
  FPosition := V;
  Invalidate;
end;

procedure TMaxCircularProgress.SetShowValue(const Value: Boolean);
begin
  if FShowValue = Value then Exit;
  FShowValue := Value;
  Invalidate;
end;

procedure TMaxCircularProgress.SetStrokeWidth(const Value: Integer);
begin
  if FStrokeWidth = Value then Exit;
  FStrokeWidth := Max(2, Value);
  Invalidate;
end;

constructor TMaxToast.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  DoubleBuffered := True;
  ParentBackground := False;
  StyleElements := [seFont];
  FToastKind := mtkSuccess;
  FTitle := 'Sucesso';
  FMessageText := 'Operação realizada com sucesso.';
  FCloseButton := True;
  Font.Name := 'Inter';
  Font.Size := 9;
  Width := 240;
  Height := 72;
end;

function TMaxToast.CloseRect: TRect;
begin
  Result := Rect(Width - MaxScale(28, CurrentPPI), 0, Width, MaxScale(28, CurrentPPI));
end;

procedure TMaxToast.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  if (Button = mbLeft) and FCloseButton and PtInRect(CloseRect, Point(X, Y)) then
    if Assigned(FOnClose) then FOnClose(Self);
end;

procedure TMaxToast.Paint;
var
  FillColor: TColor;
  BorderColor: TColor;
  IconKind: TMaxIconKind;
  IconRect: TRect;
  TextRect: TRect;
  Save: Integer;
begin
  case FToastKind of
    mtkWarning:
      begin FillColor := TMaxPainter.BlendColor(TMaxTheme.Palette.Warning, clWhite, 212);
        BorderColor := TMaxTheme.Palette.Warning; IconKind := mikWarning; end;
    mtkDanger:
      begin FillColor := TMaxPainter.BlendColor(TMaxTheme.Palette.Danger, clWhite, 220);
        BorderColor := TMaxTheme.Palette.Danger; IconKind := mikClose; end;
    mtkInfo:
      begin FillColor := TMaxPainter.BlendColor(TMaxTheme.Palette.Info, clWhite, 220);
        BorderColor := TMaxTheme.Palette.Info; IconKind := mikInfo; end;
  else
    begin FillColor := TMaxTheme.Palette.PrimarySoft;
      BorderColor := TMaxTheme.Palette.Success; IconKind := mikCheck; end;
  end;
  TMaxPainter.DrawSurface(Canvas, ClientRect, FillColor, BorderColor,
    MaxScale(8, CurrentPPI), 1);
  IconRect := Rect(MaxScale(12, CurrentPPI), MaxScale(18, CurrentPPI),
    MaxScale(38, CurrentPPI), MaxScale(44, CurrentPPI));
  TMaxIconPainter.Draw(Canvas, IconRect, IconKind, BorderColor, 2);
  TextRect := Rect(MaxScale(48, CurrentPPI), MaxScale(10, CurrentPPI),
    Width - MaxScale(32, CurrentPPI), Height - MaxScale(8, CurrentPPI));
  Save := SaveDC(Canvas.Handle);
  try
    Canvas.Font.Assign(Font);
    Canvas.Font.Color := TMaxTheme.Palette.Text;
    Canvas.Font.Style := [fsBold];
    SetBkMode(Canvas.Handle, TRANSPARENT);
    DrawText(Canvas.Handle, PChar(FTitle), Length(FTitle), TextRect,
      DT_LEFT or DT_TOP or DT_SINGLELINE or DT_END_ELLIPSIS);
    Inc(TextRect.Top, MaxScale(20, CurrentPPI));
    Canvas.Font.Style := [];
    Canvas.Font.Size := 8;
    DrawText(Canvas.Handle, PChar(FMessageText), Length(FMessageText), TextRect,
      DT_LEFT or DT_TOP or DT_WORDBREAK or DT_END_ELLIPSIS);
  finally
    RestoreDC(Canvas.Handle, Save);
  end;
  if FCloseButton then
  begin
    IconRect := CloseRect;
    InflateRect(IconRect, -MaxScale(8, CurrentPPI), -MaxScale(8, CurrentPPI));
    TMaxIconPainter.Draw(Canvas, IconRect, mikClose,
      TMaxTheme.Palette.TextSecondary, 1);
  end;
end;

procedure TMaxToast.SetCloseButton(const Value: Boolean);
begin
  if FCloseButton = Value then Exit;
  FCloseButton := Value;
  Invalidate;
end;

procedure TMaxToast.SetMessageText(const Value: string);
begin
  if FMessageText = Value then Exit;
  FMessageText := Value;
  Invalidate;
end;

procedure TMaxToast.SetTitle(const Value: string);
begin
  if FTitle = Value then Exit;
  FTitle := Value;
  Invalidate;
end;

procedure TMaxToast.SetToastKind(const Value: TMaxToastKind);
begin
  if FToastKind = Value then Exit;
  FToastKind := Value;
  Invalidate;
end;

constructor TMaxTooltip.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FText := 'Informação adicional';
  Font.Name := 'Inter';
  Font.Size := 8;
  Font.Color := clWhite;
  Width := 150;
  Height := 48;
end;

procedure TMaxTooltip.Paint;
var
  R: TRect;
  Save: Integer;
begin
  R := ClientRect;
  TMaxPainter.DrawSurface(Canvas, R, TMaxTheme.Palette.PrimaryDeep,
    TMaxTheme.Palette.PrimaryDeep, MaxScale(6, CurrentPPI), 1);
  InflateRect(R, -MaxScale(10, CurrentPPI), -MaxScale(6, CurrentPPI));
  Save := SaveDC(Canvas.Handle);
  try
    Canvas.Font.Assign(Font);
    Canvas.Font.Color := clWhite;
    SetBkMode(Canvas.Handle, TRANSPARENT);
    DrawText(Canvas.Handle, PChar(FText), Length(FText), R,
      DT_CENTER or DT_VCENTER or DT_WORDBREAK or DT_END_ELLIPSIS);
  finally
    RestoreDC(Canvas.Handle, Save);
  end;
end;

procedure TMaxTooltip.SetText(const Value: string);
begin
  if FText = Value then Exit;
  FText := Value;
  Invalidate;
end;

constructor TMaxModalPanel.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  DoubleBuffered := True;
  ParentBackground := False;
  StyleElements := [seFont];
  TabStop := True;
  FTitle := 'Confirmação';
  FMessageText := 'Deseja realmente continuar?';
  FConfirmCaption := 'Confirmar';
  FCancelCaption := 'Cancelar';
  Font.Name := 'Inter';
  Font.Size := 9;
  Width := 300;
  Height := 220;

  FCancelButton := TMaxButton.Create(Self);
  FCancelButton.Parent := Self;
  FCancelButton.SetSubComponent(True);
  FCancelButton.Kind := mbkSecondary;
  FCancelButton.Caption := FCancelCaption;
  FCancelButton.OnClick := CancelClick;

  FConfirmButton := TMaxButton.Create(Self);
  FConfirmButton.Parent := Self;
  FConfirmButton.SetSubComponent(True);
  FConfirmButton.Kind := mbkPrimary;
  FConfirmButton.Caption := FConfirmCaption;
  FConfirmButton.OnClick := ConfirmClick;
end;

procedure TMaxModalPanel.CancelClick(Sender: TObject);
begin
  if Assigned(FOnCancel) then FOnCancel(Self);
end;

procedure TMaxModalPanel.ConfirmClick(Sender: TObject);
begin
  if Assigned(FOnConfirm) then FOnConfirm(Self);
end;

procedure TMaxModalPanel.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited;
  case Key of
    VK_ESCAPE:
      begin CancelClick(Self); Key := 0; end;
    VK_RETURN:
      begin ConfirmClick(Self); Key := 0; end;
  end;
end;

procedure TMaxModalPanel.Paint;
var
  R: TRect;
  IconRect: TRect;
  TextRect: TRect;
  Save: Integer;
begin
  R := ClientRect;
  TMaxPainter.DrawSurface(Canvas, R, TMaxTheme.Palette.PrimaryDeep,
    TMaxTheme.Palette.BorderStrong, MaxScale(12, CurrentPPI), 1);
  TextRect := Rect(MaxScale(16, CurrentPPI), MaxScale(12, CurrentPPI),
    Width - MaxScale(16, CurrentPPI), MaxScale(42, CurrentPPI));
  Save := SaveDC(Canvas.Handle);
  try
    Canvas.Font.Assign(Font);
    Canvas.Font.Color := clWhite;
    Canvas.Font.Style := [fsBold];
    SetBkMode(Canvas.Handle, TRANSPARENT);
    DrawText(Canvas.Handle, PChar(FTitle), Length(FTitle), TextRect,
      DT_LEFT or DT_VCENTER or DT_SINGLELINE or DT_END_ELLIPSIS);
    IconRect := Rect((Width - MaxScale(54, CurrentPPI)) div 2,
      MaxScale(54, CurrentPPI), (Width + MaxScale(54, CurrentPPI)) div 2,
      MaxScale(108, CurrentPPI));
    Canvas.Brush.Style := bsClear;
    Canvas.Pen.Color := TMaxTheme.Palette.Primary;
    Canvas.Pen.Width := 2;
    Canvas.Ellipse(IconRect);
    Canvas.Brush.Style := bsSolid;
    InflateRect(IconRect, -MaxScale(15, CurrentPPI), -MaxScale(15, CurrentPPI));
    TMaxIconPainter.Draw(Canvas, IconRect, mikInfo,
      TMaxTheme.Palette.Primary, 2);
    TextRect := Rect(MaxScale(24, CurrentPPI), MaxScale(116, CurrentPPI),
      Width - MaxScale(24, CurrentPPI), Height - MaxScale(58, CurrentPPI));
    Canvas.Font.Style := [];
    Canvas.Font.Size := 9;
    DrawText(Canvas.Handle, PChar(FMessageText), Length(FMessageText), TextRect,
      DT_CENTER or DT_TOP or DT_WORDBREAK or DT_END_ELLIPSIS);
  finally
    RestoreDC(Canvas.Handle, Save);
  end;
end;

procedure TMaxModalPanel.Resize;
var
  ButtonWidth: Integer;
  Gap: Integer;
  Y: Integer;
begin
  inherited;
  ButtonWidth := MaxScale(96, CurrentPPI);
  Gap := MaxScale(8, CurrentPPI);
  Y := Height - MaxScale(48, CurrentPPI);
  FConfirmButton.SetBounds(Width - MaxScale(16, CurrentPPI) - ButtonWidth,
    Y, ButtonWidth, MaxScale(34, CurrentPPI));
  FCancelButton.SetBounds(FConfirmButton.Left - Gap - ButtonWidth,
    Y, ButtonWidth, MaxScale(34, CurrentPPI));
end;

procedure TMaxModalPanel.SetCancelCaption(const Value: string);
begin
  if FCancelCaption = Value then Exit;
  FCancelCaption := Value;
  FCancelButton.Caption := Value;
end;

procedure TMaxModalPanel.SetConfirmCaption(const Value: string);
begin
  if FConfirmCaption = Value then Exit;
  FConfirmCaption := Value;
  FConfirmButton.Caption := Value;
end;

procedure TMaxModalPanel.SetMessageText(const Value: string);
begin
  if FMessageText = Value then Exit;
  FMessageText := Value;
  Invalidate;
end;

procedure TMaxModalPanel.SetTitle(const Value: string);
begin
  if FTitle = Value then Exit;
  FTitle := Value;
  Invalidate;
end;

constructor TMaxPagination.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  DoubleBuffered := True;
  ParentBackground := False;
  StyleElements := [seFont];
  FCurrentPage := 1;
  FPageCount := 1;
  FPageSize := 10;
  Font.Name := 'Inter';
  Font.Size := 9;
  Width := 420;
  Height := 40;
end;

procedure TMaxPagination.ChangePage(const Value: Integer);
begin
  CurrentPage := Value;
end;

procedure TMaxPagination.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  ButtonWidth: Integer;
  Index: Integer;
  StartPage: Integer;
begin
  inherited;
  if Button <> mbLeft then Exit;
  ButtonWidth := MaxScale(34, CurrentPPI);
  Index := X div ButtonWidth;
  StartPage := VisibleStart;
  case Index of
    0: ChangePage(1);
    1: ChangePage(FCurrentPage - 1);
    2..6: ChangePage(StartPage + Index - 2);
    7: ChangePage(FCurrentPage + 1);
    8: ChangePage(FPageCount);
  end;
end;

procedure TMaxPagination.Paint;
var
  ButtonWidth: Integer;
  I: Integer;
  PageValue: Integer;
  StartPage: Integer;
  R: TRect;
  S: string;
  Save: Integer;

  procedure DrawButton(const Index: Integer; const CaptionValue: string;
    const SelectedValue: Boolean);
  var
    FillColor: TColor;
    BorderColor: TColor;
    TextColor: TColor;
  begin
    R := Rect(Index * ButtonWidth + 1, 3, (Index + 1) * ButtonWidth - 2,
      Height - 3);
    if SelectedValue then
    begin
      FillColor := TMaxTheme.Palette.Primary;
      BorderColor := TMaxTheme.Palette.Primary;
      TextColor := clWhite;
    end
    else
    begin
      FillColor := TMaxTheme.Palette.Surface;
      BorderColor := TMaxTheme.Palette.Border;
      TextColor := TMaxTheme.Palette.TextSecondary;
    end;
    TMaxPainter.DrawSurface(Canvas, R, FillColor, BorderColor,
      MaxScale(6, CurrentPPI), 1);
    Canvas.Font.Color := TextColor;
    DrawText(Canvas.Handle, PChar(CaptionValue), Length(CaptionValue), R,
      DT_CENTER or DT_VCENTER or DT_SINGLELINE);
  end;

begin
  Canvas.Brush.Color := TMaxTheme.Palette.Background;
  Canvas.FillRect(ClientRect);
  ButtonWidth := MaxScale(34, CurrentPPI);
  StartPage := VisibleStart;
  Save := SaveDC(Canvas.Handle);
  try
    Canvas.Font.Assign(Font);
    SetBkMode(Canvas.Handle, TRANSPARENT);
    DrawButton(0, '«', False);
    DrawButton(1, '‹', False);
    for I := 0 to 4 do
    begin
      PageValue := StartPage + I;
      if PageValue <= FPageCount then
        DrawButton(2 + I, IntToStr(PageValue), PageValue = FCurrentPage);
    end;
    DrawButton(7, '›', False);
    DrawButton(8, '»', False);
    S := IntToStr(FPageSize) + ' / página';
    R := Rect(9 * ButtonWidth + MaxScale(8, CurrentPPI), 3,
      Width - 2, Height - 3);
    TMaxPainter.DrawSurface(Canvas, R, TMaxTheme.Palette.Surface,
      TMaxTheme.Palette.Border, MaxScale(6, CurrentPPI), 1);
    Canvas.Font.Color := TMaxTheme.Palette.TextSecondary;
    DrawText(Canvas.Handle, PChar(S), Length(S), R,
      DT_CENTER or DT_VCENTER or DT_SINGLELINE or DT_END_ELLIPSIS);
  finally
    RestoreDC(Canvas.Handle, Save);
  end;
end;

procedure TMaxPagination.SetCurrentPage(const Value: Integer);
var
  V: Integer;
begin
  V := EnsureRange(Value, 1, Max(1, FPageCount));
  if FCurrentPage = V then Exit;
  FCurrentPage := V;
  Invalidate;
  if Assigned(FOnPageChanged) then FOnPageChanged(Self);
end;

procedure TMaxPagination.SetPageCount(const Value: Integer);
begin
  FPageCount := Max(1, Value);
  if FCurrentPage > FPageCount then FCurrentPage := FPageCount;
  Invalidate;
end;

procedure TMaxPagination.SetPageSize(const Value: Integer);
begin
  FPageSize := Max(1, Value);
  Invalidate;
end;

function TMaxPagination.VisibleStart: Integer;
begin
  Result := Max(1, FCurrentPage - 2);
  if Result + 4 > FPageCount then
    Result := Max(1, FPageCount - 4);
end;

constructor TMaxSpinner.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FSpinnerStyle := mssRing;
  FActive := True;
  FInterval := 90;
  FFrame := 0;
  Width := 72;
  Height := 40;
  FTimer := TTimer.Create(Self);
  FTimer.Interval := FInterval;
  FTimer.OnTimer := TimerTick;
  FTimer.Enabled := FActive;
end;

procedure TMaxSpinner.Paint;
var
  R: TRect;
  I: Integer;
  DotSize: Integer;
  X: Integer;
  Shade: TColor;
  StartAngle: Double;
  EndAngle: Double;
  CenterX: Integer;
  CenterY: Integer;
  Radius: Integer;
  SX: Integer;
  SY: Integer;
  EX: Integer;
  EY: Integer;
begin
  Canvas.Brush.Color := TMaxTheme.Palette.Background;
  Canvas.FillRect(ClientRect);
  case FSpinnerStyle of
    mssDots:
      begin
        DotSize := MaxScale(8, CurrentPPI);
        X := (Width - (DotSize * 3 + MaxScale(12, CurrentPPI))) div 2;
        for I := 0 to 2 do
        begin
          if I = (FFrame mod 3) then Shade := TMaxTheme.Palette.Primary
          else Shade := TMaxTheme.Palette.BorderStrong;
          Canvas.Brush.Color := Shade;
          Canvas.Pen.Color := Shade;
          Canvas.Ellipse(X + I * (DotSize + MaxScale(6, CurrentPPI)),
            (Height - DotSize) div 2,
            X + I * (DotSize + MaxScale(6, CurrentPPI)) + DotSize,
            (Height + DotSize) div 2);
        end;
      end;
    mssSkeleton:
      begin
        R := Rect(MaxScale(4, CurrentPPI), MaxScale(6, CurrentPPI),
          MaxScale(34, CurrentPPI), Height - MaxScale(6, CurrentPPI));
        TMaxPainter.DrawSurface(Canvas, R, TMaxTheme.Palette.DisabledSurface,
          TMaxTheme.Palette.DisabledSurface, MaxScale(5, CurrentPPI), 1);
        R := Rect(MaxScale(42, CurrentPPI), MaxScale(8, CurrentPPI),
          Width - MaxScale(4, CurrentPPI), MaxScale(17, CurrentPPI));
        TMaxPainter.DrawSurface(Canvas, R, TMaxTheme.Palette.DisabledSurface,
          TMaxTheme.Palette.DisabledSurface, MaxScale(4, CurrentPPI), 1);
        R.Top := MaxScale(23, CurrentPPI);
        R.Bottom := Height - MaxScale(8, CurrentPPI);
        R.Right := Width - MaxScale(22, CurrentPPI);
        TMaxPainter.DrawSurface(Canvas, R, TMaxTheme.Palette.DisabledSurface,
          TMaxTheme.Palette.DisabledSurface, MaxScale(4, CurrentPPI), 1);
      end;
  else
    begin
      R := ClientRect;
      InflateRect(R, -MaxScale(10, CurrentPPI), -MaxScale(5, CurrentPPI));
      if R.Width > R.Height then
      begin
        R.Left := (Width - R.Height) div 2;
        R.Right := R.Left + R.Height;
      end;
      Canvas.Brush.Style := bsClear;
      Canvas.Pen.Width := MaxScale(3, CurrentPPI);
      Canvas.Pen.Color := TMaxTheme.Palette.Border;
      Canvas.Ellipse(R);
      CenterX := (R.Left + R.Right) div 2;
      CenterY := (R.Top + R.Bottom) div 2;
      Radius := R.Width div 2;
      StartAngle := -Pi / 2 + (FFrame mod 12) * Pi / 6;
      EndAngle := StartAngle + Pi * 0.9;
      SX := CenterX + Round(Cos(StartAngle) * Radius);
      SY := CenterY + Round(Sin(StartAngle) * Radius);
      EX := CenterX + Round(Cos(EndAngle) * Radius);
      EY := CenterY + Round(Sin(EndAngle) * Radius);
      Canvas.Pen.Color := TMaxTheme.Palette.Primary;
      Canvas.Arc(R.Left, R.Top, R.Right, R.Bottom, SX, SY, EX, EY);
      Canvas.Brush.Style := bsSolid;
    end;
  end;
end;

procedure TMaxSpinner.SetActive(const Value: Boolean);
begin
  if FActive = Value then Exit;
  FActive := Value;
  FTimer.Enabled := FActive and Visible;
  Invalidate;
end;

procedure TMaxSpinner.SetInterval(const Value: Cardinal);
begin
  if FInterval = Value then Exit;
  if Value < 20 then
    FInterval := 20
  else
    FInterval := Value;
  FTimer.Interval := FInterval;
end;

procedure TMaxSpinner.SetSpinnerStyle(const Value: TMaxSpinnerStyle);
begin
  if FSpinnerStyle = Value then Exit;
  FSpinnerStyle := Value;
  Invalidate;
end;

procedure TMaxSpinner.TimerTick(Sender: TObject);
begin
  Inc(FFrame);
  Invalidate;
end;

procedure TMaxSpinner.CMVisibleChanged(var Message: TMessage);
begin
  inherited;
  FTimer.Enabled := FActive and Visible;
end;

end.
