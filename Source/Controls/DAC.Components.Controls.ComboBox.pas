unit DAC.Components.Controls.ComboBox;

interface

uses
  System.Classes,
  System.Skia,
  System.Types,
  System.UITypes,
  System.SysUtils,
  Winapi.Messages,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Graphics,
  Vcl.Skia,
  Vcl.StdCtrls,
  DAC.Components.Controls.Edit,
  DAC.Components.DesignSystem.Fonts,
  DAC.Components.DesignSystem.IconAssets,
  DAC.Components.Skia.IconPainter,
  DAC.Components.Skia.BackgroundPainter,
  DAC.Components.Skia.BorderPainter,
  DAC.Components.Skia.Renderer;

type
  TDACComboBox = class(TCustomControl)
  private
    FBackgroundPainter: TDACSkiaBackgroundPainter;
    FBorderPainter: TDACSkiaBorderPainter;
    FCombo: TComboBox;
    FCornerRadius: Integer;
    FCounterText: string;
    FDropDownForm: TForm;
    FDropDownHotIndex: Integer;
    FDropDownPaintBox: TSkPaintBox;
    FHelperText: string;
    FIconPainter: TDACSkiaIconPainter;
    FInputSize: TDACInputSize;
    FLabelText: string;
    FMouseInside: Boolean;
    FOnChange: TNotifyEvent;
    FPaintBox: TSkPaintBox;
    FRenderer: TDACSkiaRenderer;
    FRequired: Boolean;
    FStatus: TDACEditStatus;
    FVariant: TDACInputVariant;
    function BorderAlpha: Byte;
    function BorderColor: TAlphaColor;
    function ControlHeight: Integer;
    procedure CMEnabledChanged(var AMessage: TMessage); message CM_ENABLEDCHANGED;
    procedure CMParentColorChanged(var AMessage: TMessage); message CM_PARENTCOLORCHANGED;
    procedure DoComboChange(Sender: TObject);
    procedure DoComboEnter(Sender: TObject);
    procedure DoComboExit(Sender: TObject);
    procedure DoMouseEnter(Sender: TObject);
    procedure DoMouseLeave(Sender: TObject);
    function ChromeTop: Integer;
    procedure CloseDropDown;
    procedure DropDownDeactivate(Sender: TObject);
    function DropDownItemAt(const AY: Integer): Integer;
    function DropDownItemHeight: Integer;
    procedure DropDownPaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    procedure DropDownPaintBoxMouseLeave(Sender: TObject);
    procedure DropDownPaintBoxMouseMove(Sender: TObject; Shift: TShiftState;
      X, Y: Integer);
    procedure DropDownPaintBoxMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    function DropDownVisible: Boolean;
    procedure EnsureDropDown;
    function GetDropDownCount: Integer;
    function GetItemIndex: Integer;
    function GetItems: TStrings;
    function GetStyle: TComboBoxStyle;
    function GetText: string;
    function HasLabel: Boolean;
    function HasSupportText: Boolean;
    function InputFontSize: Integer;
    procedure PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    procedure PaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    function ParentSurfaceColor: TAlphaColor;
    function ScaleFactor: Single;
    function ScaleMetric(const AValue: Integer): Integer;
    procedure SetCornerRadius(const AValue: Integer);
    procedure SetCounterText(const AValue: string);
    procedure SetDropDownCount(const AValue: Integer);
    procedure SetHelperText(const AValue: string);
    procedure SetInputSize(const AValue: TDACInputSize);
    procedure SetItemIndex(const AValue: Integer);
    procedure SetItems(const AValue: TStrings);
    procedure SetLabelText(const AValue: string);
    procedure SetRequired(const AValue: Boolean);
    procedure SetStatus(const AValue: TDACEditStatus);
    procedure SetStyle(const AValue: TComboBoxStyle);
    procedure SetText(const AValue: string);
    procedure SetVariant(const AValue: TDACInputVariant);
    procedure ShowDropDown;
    function SupportTextColor(const ASurface: TAlphaColor): TAlphaColor;
    procedure UpdateChildBounds;
    procedure UpdateComboStyle;
    procedure UpdatePaintBoxBounds;
    procedure UpdateZOrder;
    procedure WMEraseBkgnd(var AMessage: TWMEraseBkgnd); message WM_ERASEBKGND;
  protected
    procedure ChangeScale(M, D: Integer); override;
    procedure CreateWnd; override;
    procedure Loaded; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Redraw;
    procedure SetFocus; reintroduce;
    property ComboControl: TComboBox read FCombo;
  published
    property Align;
    property Anchors;
    property Constraints;
    property CornerRadius: Integer read FCornerRadius write SetCornerRadius default 8;
    property CounterText: string read FCounterText write SetCounterText;
    property DropDownCount: Integer read GetDropDownCount write SetDropDownCount default 8;
    property Enabled;
    property Font;
    property HelperText: string read FHelperText write SetHelperText;
    property InputSize: TDACInputSize read FInputSize write SetInputSize default misMedium;
    property ItemIndex: Integer read GetItemIndex write SetItemIndex default -1;
    property Items: TStrings read GetItems write SetItems;
    property LabelText: string read FLabelText write SetLabelText;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property Required: Boolean read FRequired write SetRequired default False;
    property ShowHint;
    property Status: TDACEditStatus read FStatus write SetStatus default mesNormal;
    property Style: TComboBoxStyle read GetStyle write SetStyle default csDropDownList;
    property TabOrder;
    property TabStop default True;
    property Text: string read GetText write SetText;
    property Variant: TDACInputVariant read FVariant write SetVariant default mivOutlined;
    property Visible;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnClick;
    property OnDblClick;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
  end;

implementation

uses
  DAC.Components.DesignSystem.ColorTokens,
  System.Math,
  Winapi.Windows;

constructor TDACComboBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque, csClickEvents, csCaptureMouse];
  Width := 220;
  Height := 38;
  TabStop := True;
  ParentColor := False;
  StyleElements := [];
  Cursor := crDefault;
  Color := clWhite;
  FCornerRadius := 8;
  FInputSize := misMedium;
  FStatus := mesNormal;
  FVariant := mivOutlined;

  FRenderer := TDACSkiaRenderer.Create;
  FBackgroundPainter := TDACSkiaBackgroundPainter.Create(FRenderer);
  FBorderPainter := TDACSkiaBorderPainter.Create(FRenderer);
  FIconPainter := TDACSkiaIconPainter.Create(FRenderer);

  FCombo := TComboBox.Create(Self);
  FCombo.Parent := Self;
  FCombo.SetSubComponent(True);
  FCombo.Style := csDropDownList;
  FCombo.StyleElements := [];
  FCombo.ParentFont := False;
  FCombo.Visible := False;
  FCombo.TabStop := False;
  FCombo.OnChange := DoComboChange;
  FCombo.OnEnter := DoComboEnter;
  FCombo.OnExit := DoComboExit;
  FCombo.OnMouseEnter := DoMouseEnter;
  FCombo.OnMouseLeave := DoMouseLeave;

  FPaintBox := TSkPaintBox.Create(Self);
  FPaintBox.Parent := Self;
  FPaintBox.SetSubComponent(True);
  FPaintBox.StyleElements := [];
  FPaintBox.OnDraw := PaintBoxDraw;
  FPaintBox.OnMouseDown := PaintBoxMouseDown;
  FPaintBox.OnMouseEnter := DoMouseEnter;
  FPaintBox.OnMouseLeave := DoMouseLeave;

  UpdateComboStyle;
  Resize;
end;

destructor TDACComboBox.Destroy;
begin
  FDropDownForm.Free;
  FCombo.Free;
  FPaintBox.Free;
  FIconPainter.Free;
  FBorderPainter.Free;
  FBackgroundPainter.Free;
  FRenderer.Free;
  inherited;
end;

function TDACComboBox.BorderAlpha: Byte;
begin
  if FVariant = mivUnderlined then
  begin
    if Focused or DropDownVisible or (FStatus <> mesNormal) then
      Exit(255);
    if FMouseInside then
      Exit(220);
    Exit(190);
  end;

  if not Enabled then
    Result := 130
  else if Focused or DropDownVisible then
    Result := 255
  else if FStatus <> mesNormal then
    Result := 215
  else if FMouseInside then
    Result := 210
  else
    Result := 185;
end;

function TDACComboBox.BorderColor: TAlphaColor;
var
  LSurface: TAlphaColor;
begin
  LSurface := ParentSurfaceColor;
  case FStatus of
    mesSuccess:
      Result := TDACComponentColors.PrimaryDark;
    mesWarning:
      Result := TDACComponentColors.Warning;
    mesDanger:
      Result := TDACComponentColors.Danger;
  else
    if Focused or DropDownVisible then
      Result := TDACComponentColors.Primary
    else if FMouseInside then
      Result := TDACComponentColors.ControlBorderHoverForSurface(LSurface)
    else
      Result := TDACComponentColors.ControlBorderForSurface(LSurface);
  end;
end;

function TDACComboBox.ControlHeight: Integer;
begin
  case FInputSize of
    misSmall:
      Result := ScaleMetric(32);
    misLarge:
      Result := ScaleMetric(48);
  else
    Result := ScaleMetric(40);
  end;

  if FVariant = mivCompact then
    Result := ScaleMetric(32);
end;

procedure TDACComboBox.CloseDropDown;
begin
  if FDropDownForm <> nil then
    FDropDownForm.Hide;
  FDropDownHotIndex := -1;
  Redraw;
end;

procedure TDACComboBox.ChangeScale(M, D: Integer);
begin
  inherited;
  UpdateChildBounds;
  Redraw;
end;

function TDACComboBox.ChromeTop: Integer;
begin
  Result := 0;
  if HasLabel then
    Result := ScaleMetric(24);
end;

procedure TDACComboBox.CMEnabledChanged(var AMessage: TMessage);
begin
  inherited;
  UpdateComboStyle;
  Redraw;
end;

procedure TDACComboBox.CMParentColorChanged(var AMessage: TMessage);
begin
  inherited;
  UpdateComboStyle;
  Redraw;
end;

procedure TDACComboBox.CreateWnd;
begin
  inherited;
  UpdateZOrder;
  UpdateChildBounds;
  UpdateComboStyle;
  Redraw;
end;

procedure TDACComboBox.DoComboChange(Sender: TObject);
begin
  Redraw;
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TDACComboBox.DoComboEnter(Sender: TObject);
begin
  Redraw;
  if Assigned(OnEnter) then
    OnEnter(Self);
end;

procedure TDACComboBox.DoComboExit(Sender: TObject);
begin
  Redraw;
  if Assigned(OnExit) then
    OnExit(Self);
end;

procedure TDACComboBox.DropDownDeactivate(Sender: TObject);
begin
  CloseDropDown;
end;

function TDACComboBox.DropDownItemAt(const AY: Integer): Integer;
begin
  Result := AY div DropDownItemHeight;
  if (Result < 0) or (Result >= FCombo.Items.Count) then
    Result := -1;
end;

function TDACComboBox.DropDownItemHeight: Integer;
begin
  Result := Max(ScaleMetric(36), ControlHeight);
end;

procedure TDACComboBox.DropDownPaintBoxDraw(Sender: TObject;
  const ACanvas: ISkCanvas; const ADest: TRectF; const AOpacity: Single);
var
  LBackground: TAlphaColor;
  LBorder: TAlphaColor;
  LCheckRect: TRectF;
  LIconStyle: TDACIconStyle;
  LIndex: Integer;
  LItemHeight: Integer;
  LRect: TRectF;
  LRow: TRectF;
  LScale: Single;
  LSurface: TAlphaColor;
  LTextColor: TAlphaColor;
begin
  if (ACanvas = nil) or (FCombo = nil) then
    Exit;

  LScale := ScaleFactor;
  LSurface := ParentSurfaceColor;
  LBackground := TDACComponentColors.ControlBackgroundForSurface(LSurface);
  LBorder := TDACComponentColors.ControlBorderForSurface(LSurface);

  ACanvas.Clear(TDACComponentColors.Transparent);
  LRect := FRenderer.SnapRect(TRectF.Create(0, 0, ADest.Width, ADest.Height), LScale);
  LRect.Inflate(-0.5 / LScale, -0.5 / LScale);
  FRenderer.FillRoundRect(ACanvas, LRect, LBackground, FCornerRadius, 255);
  FRenderer.StrokeRoundRect(ACanvas, LRect, TDACComponentColors.Primary,
    FCornerRadius, 1, 255);

  LItemHeight := DropDownItemHeight;
  for LIndex := 0 to FCombo.Items.Count - 1 do
  begin
    LRow := TRectF.Create(LRect.Left + 1, LRect.Top + (LIndex * LItemHeight) + 1,
      LRect.Right - 1, LRect.Top + ((LIndex + 1) * LItemHeight) + 1);
    if LRow.Top >= LRect.Bottom then
      Break;

    if LIndex = FCombo.ItemIndex then
      FRenderer.FillRoundRect(ACanvas, LRow, TDACComponentColors.PrimaryLight,
        0, 80)
    else if LIndex = FDropDownHotIndex then
      FRenderer.FillRoundRect(ACanvas, LRow, TDACComponentColors.PrimaryLight,
        0, 42);

    LTextColor := TDACComponentColors.ControlTextForSurface(LSurface);
    if LIndex = FCombo.ItemIndex then
      LTextColor := TDACComponentColors.PrimaryDark;

    FRenderer.Text(ACanvas, FCombo.Items[LIndex],
      TDACComponentFontInstaller.FontFamily, LRow.Left + ScaleMetric(14),
      LRow.Top + (LRow.Height / 2) + ScaleMetric(5), 13, LTextColor,
      False, LRow.Width - ScaleMetric(44));

    if LIndex = FCombo.ItemIndex then
    begin
      LCheckRect := TRectF.Create(LRow.Right - ScaleMetric(28),
        LRow.Top + (LRow.Height - ScaleMetric(16)) / 2,
        LRow.Right - ScaleMetric(12),
        LRow.Top + (LRow.Height + ScaleMetric(16)) / 2);
      LIconStyle.Color := TDACComponentColors.PrimaryDark;
      LIconStyle.Alpha := 255;
      FIconPainter.Draw(ACanvas, LCheckRect, mikCheck, LIconStyle);
    end;

    if LIndex < FCombo.Items.Count - 1 then
      FRenderer.StrokeRoundRect(ACanvas,
        TRectF.Create(LRect.Left + ScaleMetric(12), LRow.Bottom,
          LRect.Right - ScaleMetric(12), LRow.Bottom + 0.5), LBorder, 0, 0.5, 130);
  end;
end;

procedure TDACComboBox.DropDownPaintBoxMouseLeave(Sender: TObject);
begin
  if FDropDownHotIndex = -1 then
    Exit;
  FDropDownHotIndex := -1;
  if FDropDownPaintBox <> nil then
    FDropDownPaintBox.Redraw;
end;

procedure TDACComboBox.DropDownPaintBoxMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  LIndex: Integer;
begin
  LIndex := DropDownItemAt(Y);
  if FDropDownHotIndex = LIndex then
    Exit;
  FDropDownHotIndex := LIndex;
  if FDropDownPaintBox <> nil then
    FDropDownPaintBox.Redraw;
end;

procedure TDACComboBox.DropDownPaintBoxMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  LIndex: Integer;
begin
  if Button <> mbLeft then
    Exit;

  LIndex := DropDownItemAt(Y);
  if LIndex >= 0 then
  begin
    FCombo.ItemIndex := LIndex;
    FCombo.Text := FCombo.Items[LIndex];
    CloseDropDown;
    DoComboChange(Self);
  end
  else
    CloseDropDown;
end;

function TDACComboBox.DropDownVisible: Boolean;
begin
  Result := (FDropDownForm <> nil) and FDropDownForm.Visible;
end;

procedure TDACComboBox.EnsureDropDown;
begin
  if FDropDownForm <> nil then
    Exit;

  FDropDownForm := TForm.CreateNew(nil);
  FDropDownForm.BorderStyle := bsNone;
  FDropDownForm.Position := poDesigned;
  FDropDownForm.StyleElements := [];
  FDropDownForm.Visible := False;
  FDropDownForm.OnDeactivate := DropDownDeactivate;

  FDropDownPaintBox := TSkPaintBox.Create(FDropDownForm);
  FDropDownPaintBox.Parent := FDropDownForm;
  FDropDownPaintBox.Align := alClient;
  FDropDownPaintBox.StyleElements := [];
  FDropDownPaintBox.OnDraw := DropDownPaintBoxDraw;
  FDropDownPaintBox.OnMouseLeave := DropDownPaintBoxMouseLeave;
  FDropDownPaintBox.OnMouseMove := DropDownPaintBoxMouseMove;
  FDropDownPaintBox.OnMouseUp := DropDownPaintBoxMouseUp;
end;

procedure TDACComboBox.DoMouseEnter(Sender: TObject);
begin
  if FMouseInside then
    Exit;
  FMouseInside := True;
  Redraw;
  if Assigned(OnMouseEnter) then
    OnMouseEnter(Self);
end;

procedure TDACComboBox.DoMouseLeave(Sender: TObject);
var
  LPoint: TPoint;
begin
  if not GetCursorPos(LPoint) then
    Exit;
  LPoint := ScreenToClient(LPoint);
  if PtInRect(ClientRect, LPoint) then
    Exit;

  if not FMouseInside then
    Exit;
  FMouseInside := False;
  Redraw;
  if Assigned(OnMouseLeave) then
    OnMouseLeave(Self);
end;

function TDACComboBox.GetDropDownCount: Integer;
begin
  Result := FCombo.DropDownCount;
end;

function TDACComboBox.GetItemIndex: Integer;
begin
  Result := FCombo.ItemIndex;
end;

function TDACComboBox.GetItems: TStrings;
begin
  Result := FCombo.Items;
end;

function TDACComboBox.GetStyle: TComboBoxStyle;
begin
  Result := FCombo.Style;
end;

function TDACComboBox.GetText: string;
begin
  Result := FCombo.Text;
end;

function TDACComboBox.HasLabel: Boolean;
begin
  Result := FLabelText.Trim <> '';
end;

function TDACComboBox.HasSupportText: Boolean;
begin
  Result := (FHelperText.Trim <> '') or (FCounterText.Trim <> '');
end;

function TDACComboBox.InputFontSize: Integer;
begin
  case FInputSize of
    misSmall:
      Result := 11;
    misLarge:
      Result := 14;
  else
    Result := 12;
  end;
end;

procedure TDACComboBox.Loaded;
begin
  inherited;
  UpdatePaintBoxBounds;
  UpdateChildBounds;
  UpdateComboStyle;
  Redraw;
end;

procedure TDACComboBox.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  inherited;
  if (Button = mbLeft) and Enabled and CanFocus then
    inherited SetFocus;
end;

procedure TDACComboBox.PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
  const ADest: TRectF; const AOpacity: Single);
var
  LArrowRect: TRectF;
  LBackground: TDACBackgroundStyle;
  LBorder: TDACBorderStyle;
  LBorderRect: TRectF;
  LControlBottom: Single;
  LCounterWidth: Single;
  LIconStyle: TDACIconStyle;
  LLabelColor: TAlphaColor;
  LRect: TRectF;
  LScale: Single;
  LSurface: TAlphaColor;
  LSupportColor: TAlphaColor;
  LTextColor: TAlphaColor;
  LTextRect: TRectF;
  LTop: Single;
begin
  if (ACanvas = nil) or (ADest.Width <= 0) or (ADest.Height <= 0) then
    Exit;

  LScale := ScaleFactor;
  LTop := ChromeTop;
  LControlBottom := Min(ADest.Height, LTop + ControlHeight);
  LBorderRect := FRenderer.SnapRect(TRectF.Create(0, LTop, ADest.Width,
    LControlBottom), LScale);
  LRect := LBorderRect;
  LRect.Inflate(-0.5 / LScale, -0.5 / LScale);

  LSurface := ParentSurfaceColor;
  ACanvas.Clear(LSurface);

  if HasLabel then
  begin
    LLabelColor := TDACComponentColors.ControlTextForSurface(LSurface);
    if FRequired then
      LLabelColor := TDACComponentColors.PrimaryDark;
    FRenderer.Text(ACanvas, FLabelText,
      TDACComponentFontInstaller.FontFamily, 0,
      ScaleMetric(15), 12, LLabelColor, FRequired, ADest.Width);
  end;

  LBorder.Color := BorderColor;
  LBorder.Radius := FCornerRadius;
  LBorder.Width := 1;
  if Focused or DropDownVisible then
    LBorder.Width := 1.5;
  LBorder.Alpha := BorderAlpha;
  if FVariant = mivUnderlined then
  begin
    FRenderer.StrokeRoundRect(ACanvas,
      TRectF.Create(LRect.Left, LRect.Bottom - ScaleMetric(1), LRect.Right,
        LRect.Bottom), LBorder.Color, 0, LBorder.Width, LBorder.Alpha);
  end
  else
  begin
    LBackground.Color := TDACComponentColors.ControlBackgroundForSurface(LSurface);
    if not Enabled then
      LBackground.Color := TDACComponentColors.ControlBackgroundDisabledForSurface(LSurface);
    LBackground.Radius := FCornerRadius;
    LBackground.Alpha := 255;
    FBackgroundPainter.Draw(ACanvas, LRect, LBackground);
    FBorderPainter.Draw(ACanvas, LBorderRect, LBorder);
  end;

  LTextColor := TDACComponentColors.ControlTextForSurface(LSurface);
  if not Enabled then
    LTextColor := TDACComponentColors.ControlTextDisabledForSurface(LSurface);

  LTextRect := TRectF.Create(LRect.Left + ScaleMetric(14), LRect.Top,
    LRect.Right - ScaleMetric(38), LRect.Bottom);
  FRenderer.Text(ACanvas, FCombo.Text,
    TDACComponentFontInstaller.FontFamily, LTextRect.Left,
    LTextRect.Top + (LTextRect.Height / 2) + ScaleMetric(5),
    InputFontSize, LTextColor, False, LTextRect.Width);

  LArrowRect := TRectF.Create(LRect.Right - ScaleMetric(28),
    LRect.Top + (LRect.Height - ScaleMetric(16)) / 2,
    LRect.Right - ScaleMetric(12),
    LRect.Top + (LRect.Height + ScaleMetric(16)) / 2);
  LIconStyle.Color := TDACComponentColors.ControlBorderHoverForSurface(LSurface);
  if not Enabled then
    LIconStyle.Color := TDACComponentColors.ControlTextDisabledForSurface(LSurface);
  LIconStyle.Alpha := 255;
  FIconPainter.Draw(ACanvas, LArrowRect, mikChevronDown, LIconStyle);

  if HasSupportText then
  begin
    LSupportColor := SupportTextColor(LSurface);
    if FHelperText.Trim <> '' then
      FRenderer.Text(ACanvas, FHelperText,
        TDACComponentFontInstaller.FontFamily, 0,
        LBorderRect.Bottom + ScaleMetric(18), 11, LSupportColor, False,
        ADest.Width);
    if FCounterText.Trim <> '' then
    begin
      LCounterWidth := FRenderer.MeasureText(FCounterText,
        TDACComponentFontInstaller.FontFamily, 11);
      FRenderer.Text(ACanvas, FCounterText,
        TDACComponentFontInstaller.FontFamily,
        Max(0, ADest.Width - LCounterWidth),
        LBorderRect.Bottom + ScaleMetric(18), 11,
        TDACComponentColors.ControlTextDisabledForSurface(LSurface),
        False, LCounterWidth);
    end;
  end;
end;

procedure TDACComboBox.PaintBoxMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
  MouseDown(Button, Shift, X, Y);
  if Button = mbLeft then
    ShowDropDown;
end;

function TDACComboBox.ParentSurfaceColor: TAlphaColor;
begin
  Result := TDACComponentColors.ResolveParentSurface(Self);
end;

procedure TDACComboBox.Redraw;
begin
  UpdatePaintBoxBounds;
  if (FPaintBox <> nil) and HandleAllocated then
    FPaintBox.Redraw;
end;

procedure TDACComboBox.Resize;
begin
  inherited;
  UpdatePaintBoxBounds;
  UpdateZOrder;
  UpdateChildBounds;
  Redraw;
end;

function TDACComboBox.ScaleFactor: Single;
begin
  Result := 1;
  if FPaintBox <> nil then
    Result := FPaintBox.ScaleFactor;
  if Result <= 0 then
    Result := 1;
end;

function TDACComboBox.ScaleMetric(const AValue: Integer): Integer;
begin
  Result := Round(AValue * ScaleFactor);
  if (AValue > 0) and (Result < 1) then
    Result := 1;
end;

procedure TDACComboBox.SetCornerRadius(const AValue: Integer);
begin
  if FCornerRadius = AValue then
    Exit;
  FCornerRadius := Max(0, AValue);
  Redraw;
end;

procedure TDACComboBox.SetCounterText(const AValue: string);
var
  LHadSupport: Boolean;
begin
  if FCounterText = AValue then
    Exit;

  LHadSupport := HasSupportText;
  FCounterText := AValue;
  if (not LHadSupport) and HasSupportText and (Height <= ChromeTop + ControlHeight) then
    Height := ChromeTop + ControlHeight + ScaleMetric(24);
  Redraw;
end;

procedure TDACComboBox.SetDropDownCount(const AValue: Integer);
begin
  FCombo.DropDownCount := Max(1, AValue);
  if DropDownVisible and (FDropDownPaintBox <> nil) then
    ShowDropDown;
end;

procedure TDACComboBox.SetHelperText(const AValue: string);
var
  LHadSupport: Boolean;
begin
  if FHelperText = AValue then
    Exit;

  LHadSupport := HasSupportText;
  FHelperText := AValue;
  if (not LHadSupport) and HasSupportText and (Height <= ChromeTop + ControlHeight) then
    Height := ChromeTop + ControlHeight + ScaleMetric(24);
  Redraw;
end;

procedure TDACComboBox.SetInputSize(const AValue: TDACInputSize);
begin
  if FInputSize = AValue then
    Exit;

  FInputSize := AValue;
  if not HasLabel and not HasSupportText then
    Height := ControlHeight
  else
    Height := ChromeTop + ControlHeight + IfThen(HasSupportText, ScaleMetric(24), 0);
  UpdateComboStyle;
  Redraw;
end;

procedure TDACComboBox.SetFocus;
begin
  if CanFocus then
    inherited;
end;

procedure TDACComboBox.SetItemIndex(const AValue: Integer);
begin
  FCombo.ItemIndex := AValue;
  Redraw;
end;

procedure TDACComboBox.SetItems(const AValue: TStrings);
begin
  FCombo.Items.Assign(AValue);
  Redraw;
end;

procedure TDACComboBox.SetLabelText(const AValue: string);
var
  LHadLabel: Boolean;
begin
  if FLabelText = AValue then
    Exit;

  LHadLabel := HasLabel;
  FLabelText := AValue;
  if (not LHadLabel) and HasLabel and (Height <= ControlHeight) then
    Height := ChromeTop + ControlHeight + IfThen(HasSupportText, ScaleMetric(24), 0);
  UpdateChildBounds;
  Redraw;
end;

procedure TDACComboBox.SetRequired(const AValue: Boolean);
begin
  if FRequired = AValue then
    Exit;
  FRequired := AValue;
  Redraw;
end;

procedure TDACComboBox.SetStatus(const AValue: TDACEditStatus);
begin
  if FStatus = AValue then
    Exit;
  FStatus := AValue;
  Redraw;
end;

procedure TDACComboBox.SetStyle(const AValue: TComboBoxStyle);
begin
  if FCombo.Style = AValue then
    Exit;
  FCombo.Style := AValue;
  UpdateChildBounds;
end;

procedure TDACComboBox.SetText(const AValue: string);
begin
  FCombo.Text := AValue;
  Redraw;
end;

procedure TDACComboBox.SetVariant(const AValue: TDACInputVariant);
begin
  if FVariant = AValue then
    Exit;

  FVariant := AValue;
  UpdateComboStyle;
  Redraw;
end;

procedure TDACComboBox.ShowDropDown;
var
  LHeight: Integer;
  LItemCount: Integer;
  LPoint: TPoint;
begin
  if (csDesigning in ComponentState) or not Enabled or (FCombo = nil) then
    Exit;
  if FCombo.Items.Count = 0 then
    Exit;

  if DropDownVisible then
  begin
    CloseDropDown;
    Exit;
  end;

  EnsureDropDown;
  LItemCount := Min(FCombo.Items.Count, Max(1, FCombo.DropDownCount));
  LHeight := LItemCount * DropDownItemHeight;
  LPoint := ClientToScreen(Point(0, ChromeTop + ControlHeight + ScaleMetric(2)));
  FDropDownHotIndex := FCombo.ItemIndex;
  FDropDownForm.Color := TDACComponentColors.ToVclColor(
    TDACComponentColors.ControlBackgroundForSurface(ParentSurfaceColor));
  FDropDownForm.SetBounds(LPoint.X, LPoint.Y, Width, LHeight);
  FDropDownForm.Show;
  FDropDownForm.BringToFront;
  if FDropDownPaintBox <> nil then
    FDropDownPaintBox.Redraw;
  Redraw;
end;

function TDACComboBox.SupportTextColor(const ASurface: TAlphaColor): TAlphaColor;
begin
  case FStatus of
    mesSuccess:
      Result := TDACComponentColors.PrimaryDark;
    mesWarning:
      Result := TDACComponentColors.WarningDark;
    mesDanger:
      Result := TDACComponentColors.Danger;
  else
    Result := TDACComponentColors.ControlTextDisabledForSurface(ASurface);
  end;
end;

procedure TDACComboBox.UpdateChildBounds;
var
  LHorizontalPadding: Integer;
  LInputHeight: Integer;
  LTop: Integer;
begin
  if FCombo = nil then
    Exit;

  LHorizontalPadding := ScaleMetric(8);
  LInputHeight := Min(ControlHeight, Max(0, Height - ChromeTop));
  LTop := ChromeTop + Max(0, (LInputHeight - ScaleMetric(24)) div 2);
  FCombo.SetBounds(LHorizontalPadding, LTop, 0, 0);
end;

procedure TDACComboBox.UpdateComboStyle;
var
  LSurface: TAlphaColor;
  LTextColor: TColor;
begin
  if FCombo = nil then
    Exit;

  LSurface := ParentSurfaceColor;
  FCombo.Enabled := Enabled;
  FCombo.Visible := False;
  FCombo.TabStop := False;
  if FVariant = mivUnderlined then
    FCombo.Color := TDACComponentColors.ToVclColor(LSurface)
  else
    FCombo.Color := TDACComponentColors.ToVclColor(
      TDACComponentColors.ControlBackgroundForSurface(LSurface));
  if not Enabled then
    FCombo.Color := TDACComponentColors.ToVclColor(
      TDACComponentColors.ControlBackgroundDisabledForSurface(LSurface));
  FCombo.Font.Name := TDACComponentFontInstaller.FontFamily;
  FCombo.Font.Size := InputFontSize;
  FCombo.Font.Style := [];
  LTextColor := TDACComponentColors.ToVclColor(
    TDACComponentColors.ControlTextForSurface(LSurface));
  if not Enabled then
    LTextColor := TDACComponentColors.ToVclColor(
      TDACComponentColors.ControlTextDisabledForSurface(LSurface));
  FCombo.Font.Color := LTextColor;
  if not Enabled then
    Cursor := crDefault;
  if FDropDownForm <> nil then
    FDropDownForm.Color := TDACComponentColors.ToVclColor(
      TDACComponentColors.ControlBackgroundForSurface(LSurface));
end;

procedure TDACComboBox.UpdatePaintBoxBounds;
var
  LWidth: Integer;
  LHeight: Integer;
begin
  if FPaintBox = nil then
    Exit;

  LWidth := Width;
  LHeight := Height;
  if HandleAllocated then
  begin
    LWidth := ClientWidth;
    LHeight := ClientHeight;
  end;

  if (FPaintBox.Left <> 0) or (FPaintBox.Top <> 0) or
    (FPaintBox.Width <> LWidth) or (FPaintBox.Height <> LHeight) then
    FPaintBox.SetBounds(0, 0, LWidth, LHeight);
end;

procedure TDACComboBox.UpdateZOrder;
begin
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    Exit;
  if csDesigning in ComponentState then
    Exit;
  if not HandleAllocated then
    Exit;
  if (Parent = nil) or not Parent.HandleAllocated then
    Exit;

  if FPaintBox <> nil then
    FPaintBox.BringToFront;
end;

procedure TDACComboBox.WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
begin
  AMessage.Result := 1;
end;

end.

