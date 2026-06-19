unit MaxxRural.Components.Controls.Tabs;

interface

uses
  System.Classes,
  System.Generics.Collections,
  System.Skia,
  System.Types,
  System.UITypes,
  Winapi.Messages,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.Skia,
  MaxxRural.Components.Controls.SystemText,
  MaxxRural.Components.DesignSystem.Fonts,
  MaxxRural.Components.Skia.BackgroundPainter,
  MaxxRural.Components.Skia.BorderPainter,
  MaxxRural.Components.Skia.Renderer;

type
  TMaxxRuralTabOrientation = (
    mtoHorizontal,
    mtoVertical
  );

  TMaxxRuralTabAppearance = (
    mtaUnderline,
    mtaPills
  );

  TMaxxRuralTabItem = class(TCollectionItem)
  private
    FCaption: string;
    FEnabled: Boolean;
    procedure SetCaption(const AValue: string);
    procedure SetEnabled(const AValue: Boolean);
  public
    constructor Create(Collection: TCollection); override;
  published
    property Caption: string read FCaption write SetCaption;
    property Enabled: Boolean read FEnabled write SetEnabled default True;
  end;

  TMaxxRuralTabs = class;

  TMaxxRuralTabItems = class(TCollection)
  private
    FOwner: TPersistent;
    function GetItem(const AIndex: Integer): TMaxxRuralTabItem;
    procedure SetItem(const AIndex: Integer; const AValue: TMaxxRuralTabItem);
  protected
    function GetOwner: TPersistent; override;
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(const AOwner: TPersistent);
    function Add: TMaxxRuralTabItem;
    property Items[const AIndex: Integer]: TMaxxRuralTabItem read GetItem write SetItem; default;
  end;

  TMaxxRuralTabs = class(TCustomControl)
  private
    FActiveIndex: Integer;
    FAppearance: TMaxxRuralTabAppearance;
    FBackgroundPainter: TMaxxRuralSkiaBackgroundPainter;
    FBorderPainter: TMaxxRuralSkiaBorderPainter;
    FContentColor: TAlphaColor;
    FCornerRadius: Integer;
    FHotIndex: Integer;
    FItems: TMaxxRuralTabItems;
    FLabels: TObjectList<TMaxxRuralSystemText>;
    FOrientation: TMaxxRuralTabOrientation;
    FPaintBox: TSkPaintBox;
    FPressedIndex: Integer;
    FRenderer: TMaxxRuralSkiaRenderer;
    FShowContentBorder: Boolean;
    FTabHeight: Integer;
    FTabWidth: Integer;
    FOnChange: TNotifyEvent;
    procedure ApplyContentSurfaceToChild(const AControl: TControl);
    procedure CMControlListChange(var AMessage: TCMControlListChange); message CM_CONTROLLISTCHANGE;
    procedure CMMouseLeave(var AMessage: TMessage); message CM_MOUSELEAVE;
    procedure CMTextChanged(var AMessage: TMessage); message CM_TEXTCHANGED;
    function ContentChromeRect(const AWidth, AHeight: Single): TRectF;
    function ContentOffset: Integer;
    function CursorInside: Boolean;
    procedure DrawPillTab(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ASelected, AHot, APressed, AEnabled: Boolean);
    procedure DrawUnderlineTab(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ASelected, AHot, APressed, AEnabled: Boolean);
    procedure EnsureLabels;
    function FirstEnabledTabIndex: Integer;
    function HitTestTab(const X, Y: Integer): Integer;
    procedure InvalidateTabs;
    procedure ItemsChanged;
    procedure LabelMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure LabelMouseEnter(Sender: TObject);
    procedure LabelMouseLeave(Sender: TObject);
    procedure LabelMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure LabelMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    procedure PaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxMouseEnter(Sender: TObject);
    procedure PaintBoxMouseLeave(Sender: TObject);
    procedure PaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    function ParentSurfaceColor: TAlphaColor;
    procedure NormalizeContentChildren;
    procedure ResetToFirstTab;
    procedure SelectTab(const AIndex: Integer; const ANotify: Boolean = True);
    procedure SetActiveIndex(const AValue: Integer);
    procedure SetAppearance(const AValue: TMaxxRuralTabAppearance);
    procedure SetContentColor(const AValue: TAlphaColor);
    procedure SetCornerRadius(const AValue: Integer);
    procedure SetItems(const AValue: TMaxxRuralTabItems);
    procedure SetOrientation(const AValue: TMaxxRuralTabOrientation);
    procedure SetShowContentBorder(const AValue: Boolean);
    procedure SetTabHeight(const AValue: Integer);
    procedure SetTabWidth(const AValue: Integer);
    function ScaleFactor: Single;
    function ScaleMetric(const AValue: Integer): Integer;
    function TabRect(const AIndex: Integer): TRect;
    function TabRectF(const AIndex: Integer): TRectF;
    function TabTextColor(const AIndex: Integer): TAlphaColor;
    function TabTextBold(const AIndex: Integer): Boolean;
    procedure UpdateCursor;
    procedure UpdateInternalBounds;
    procedure UpdateInternalZOrder;
    procedure UpdateLabels;
    procedure WMEraseBkgnd(var AMessage: TWMEraseBkgnd); message WM_ERASEBKGND;
  protected
    procedure AdjustClientRect(var Rect: TRect); override;
    procedure ChangeScale(M, D: Integer); override;
    procedure CreateWnd; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure Loaded; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Redraw;
  published
    property ActiveIndex: Integer read FActiveIndex write SetActiveIndex default 0;
    property Align;
    property Anchors;
    property Appearance: TMaxxRuralTabAppearance read FAppearance write SetAppearance default mtaUnderline;
    property Constraints;
    property ContentColor: TAlphaColor read FContentColor write SetContentColor;
    property CornerRadius: Integer read FCornerRadius write SetCornerRadius default 8;
    property Enabled;
    property Font;
    property Items: TMaxxRuralTabItems read FItems write SetItems;
    property Orientation: TMaxxRuralTabOrientation read FOrientation write SetOrientation default mtoHorizontal;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property ShowContentBorder: Boolean read FShowContentBorder write SetShowContentBorder default True;
    property ShowHint;
    property TabHeight: Integer read FTabHeight write SetTabHeight default 42;
    property TabOrder;
    property TabStop default True;
    property TabWidth: Integer read FTabWidth write SetTabWidth default 128;
    property Visible;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnClick;
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
  MaxxRural.Components.DesignSystem.ColorTokens,
  System.Math,
  System.TypInfo,
  Winapi.Windows;

procedure RemovePublishedClientStyleElement(const AControl: TControl);
var
  LPropInfo: PPropInfo;
  LStyleElements: TStyleElements;
begin
  if AControl = nil then
    Exit;

  LPropInfo := GetPropInfo(AControl, 'StyleElements');
  if LPropInfo = nil then
    Exit;

  LStyleElements := TStyleElements(Byte(GetOrdProp(AControl, LPropInfo)));
  Exclude(LStyleElements, seClient);
  SetOrdProp(AControl, LPropInfo, Byte(LStyleElements));
end;

procedure SetPublishedOrdProperty(const AObject: TObject; const AName: string;
  const AValue: LongInt);
var
  LPropInfo: PPropInfo;
begin
  if AObject = nil then
    Exit;

  LPropInfo := GetPropInfo(AObject, AName);
  if LPropInfo = nil then
    Exit;

  SetOrdProp(AObject, LPropInfo, AValue);
end;

constructor TMaxxRuralTabItem.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FEnabled := True;
  FCaption := 'Aba';
end;

procedure TMaxxRuralTabItem.SetCaption(const AValue: string);
begin
  if FCaption = AValue then
    Exit;
  FCaption := AValue;
  Changed(False);
end;

procedure TMaxxRuralTabItem.SetEnabled(const AValue: Boolean);
begin
  if FEnabled = AValue then
    Exit;
  FEnabled := AValue;
  Changed(False);
end;

constructor TMaxxRuralTabItems.Create(const AOwner: TPersistent);
begin
  inherited Create(TMaxxRuralTabItem);
  FOwner := AOwner;
end;

function TMaxxRuralTabItems.Add: TMaxxRuralTabItem;
begin
  Result := TMaxxRuralTabItem(inherited Add);
end;

function TMaxxRuralTabItems.GetItem(const AIndex: Integer): TMaxxRuralTabItem;
begin
  Result := TMaxxRuralTabItem(inherited GetItem(AIndex));
end;

function TMaxxRuralTabItems.GetOwner: TPersistent;
begin
  Result := FOwner;
end;

procedure TMaxxRuralTabItems.SetItem(const AIndex: Integer;
  const AValue: TMaxxRuralTabItem);
begin
  inherited SetItem(AIndex, AValue);
end;

procedure TMaxxRuralTabItems.Update(Item: TCollectionItem);
begin
  inherited;
  if FOwner is TMaxxRuralTabs then
    TMaxxRuralTabs(FOwner).ItemsChanged;
end;

constructor TMaxxRuralTabs.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csAcceptsControls, csOpaque, csClickEvents, csCaptureMouse];
  Width := 420;
  Height := 180;
  TabStop := True;
  DoubleBuffered := True;
  ParentDoubleBuffered := False;
  ParentColor := True;
  StyleElements := [];

  FActiveIndex := 0;
  FAppearance := mtaUnderline;
  FContentColor := TMaxxRuralComponentColors.White;
  FCornerRadius := 8;
  FHotIndex := -1;
  FOrientation := mtoHorizontal;
  FPressedIndex := -1;
  FShowContentBorder := True;
  FTabHeight := 42;
  FTabWidth := 128;

  FItems := TMaxxRuralTabItems.Create(Self);
  FLabels := TObjectList<TMaxxRuralSystemText>.Create(False);
  FRenderer := TMaxxRuralSkiaRenderer.Create;
  FBackgroundPainter := TMaxxRuralSkiaBackgroundPainter.Create(FRenderer);
  FBorderPainter := TMaxxRuralSkiaBorderPainter.Create(FRenderer);

  FPaintBox := TSkPaintBox.Create(Self);
  FPaintBox.Parent := Self;
  FPaintBox.SetSubComponent(True);
  FPaintBox.StyleElements := [];
  FPaintBox.OnDraw := PaintBoxDraw;
  FPaintBox.OnMouseDown := PaintBoxMouseDown;
  FPaintBox.OnMouseEnter := PaintBoxMouseEnter;
  FPaintBox.OnMouseLeave := PaintBoxMouseLeave;
  FPaintBox.OnMouseMove := PaintBoxMouseMove;
  FPaintBox.OnMouseUp := PaintBoxMouseUp;

  with FItems.Add do
    Caption := 'Geral';
  with FItems.Add do
    Caption := 'Detalhes';
  with FItems.Add do
    Caption := 'Historico';

  UpdateCursor;
  UpdateInternalBounds;
  UpdateLabels;
end;

destructor TMaxxRuralTabs.Destroy;
begin
  FLabels.Free;
  FItems.Free;
  FPaintBox.Free;
  FBorderPainter.Free;
  FBackgroundPainter.Free;
  FRenderer.Free;
  inherited;
end;

procedure TMaxxRuralTabs.ApplyContentSurfaceToChild(const AControl: TControl);
var
  LColor: TColor;
begin
  if (AControl = nil) or (AControl.Parent <> Self) then
    Exit;
  if AControl = FPaintBox then
    Exit;
  if (FLabels <> nil) and (AControl is TMaxxRuralSystemText) and
    FLabels.Contains(TMaxxRuralSystemText(AControl)) then
    Exit;

  LColor := TMaxxRuralComponentColors.ToVclColor(FContentColor);
  SetPublishedOrdProperty(AControl, 'ParentColor', Ord(False));
  SetPublishedOrdProperty(AControl, 'Color', LColor);
  RemovePublishedClientStyleElement(AControl);
end;

procedure TMaxxRuralTabs.AdjustClientRect(var Rect: TRect);
var
  LOffset: Integer;
begin
  inherited AdjustClientRect(Rect);
  LOffset := ContentOffset;
  if FOrientation = mtoHorizontal then
    Inc(Rect.Top, LOffset)
  else
    Inc(Rect.Left, LOffset);

  InflateRect(Rect, -ScaleMetric(12), -ScaleMetric(12));
  if Rect.Right < Rect.Left then
    Rect.Right := Rect.Left;
  if Rect.Bottom < Rect.Top then
    Rect.Bottom := Rect.Top;
end;

procedure TMaxxRuralTabs.ChangeScale(M, D: Integer);
begin
  inherited;
  UpdateInternalBounds;
  UpdateLabels;
  Redraw;
end;

procedure TMaxxRuralTabs.CMControlListChange(var AMessage: TCMControlListChange);
begin
  inherited;
  if AMessage.Inserting then
    ApplyContentSurfaceToChild(AMessage.Control);
end;

procedure TMaxxRuralTabs.CMMouseLeave(var AMessage: TMessage);
begin
  inherited;
  if not MouseCapture then
  begin
    FHotIndex := -1;
    FPressedIndex := -1;
    UpdateLabels;
    Redraw;
  end;
end;

procedure TMaxxRuralTabs.CMTextChanged(var AMessage: TMessage);
begin
  inherited;
  UpdateLabels;
end;

function TMaxxRuralTabs.ContentChromeRect(const AWidth, AHeight: Single): TRectF;
var
  LOffset: Single;
begin
  LOffset := ContentOffset;
  if FOrientation = mtoHorizontal then
    Result := TRectF.Create(0, LOffset, AWidth, AHeight)
  else
    Result := TRectF.Create(LOffset, 0, AWidth, AHeight);
end;

function TMaxxRuralTabs.ContentOffset: Integer;
begin
  if FOrientation = mtoHorizontal then
    Result := ScaleMetric(FTabHeight)
  else
    Result := ScaleMetric(FTabWidth);
end;

function TMaxxRuralTabs.CursorInside: Boolean;
var
  LPoint: TPoint;
begin
  Result := False;
  if not HandleAllocated then
    Exit;
  if not GetCursorPos(LPoint) then
    Exit;
  LPoint := ScreenToClient(LPoint);
  Result := PtInRect(Rect(0, 0, Width, Height), LPoint);
end;

procedure TMaxxRuralTabs.CreateWnd;
begin
  inherited;
  NormalizeContentChildren;
  UpdateInternalBounds;
  UpdateLabels;
  UpdateInternalZOrder;
  Redraw;
end;

procedure TMaxxRuralTabs.DrawPillTab(const ACanvas: ISkCanvas;
  const ARect: TRectF; const ASelected, AHot, APressed, AEnabled: Boolean);
var
  LBackground: TMaxxRuralBackgroundStyle;
  LBorder: TMaxxRuralBorderStyle;
  LRect: TRectF;
begin
  LRect := ARect;
  LRect.Inflate(-ScaleMetric(4), -ScaleMetric(4));

  LBackground.Radius := FCornerRadius;
  LBackground.Alpha := 255;
  LBorder.Color := TMaxxRuralComponentColors.ControlBorder;
  LBorder.Radius := FCornerRadius;
  LBorder.Width := 1;
  LBorder.Alpha := 255;

  if ASelected then
  begin
    LBackground.Color := TMaxxRuralComponentColors.Primary;
    LBorder.Color := TMaxxRuralComponentColors.Primary;
  end
  else
  begin
    LBackground.Color := TMaxxRuralComponentColors.White;
    if AHot then
    begin
      LBackground.Color := TMaxxRuralComponentColors.PrimaryDark;
      LBackground.Alpha := 18;
      LBorder.Color := TMaxxRuralComponentColors.PrimaryLight;
    end;
  end;

  if APressed and not ASelected then
  begin
    LBackground.Color := TMaxxRuralComponentColors.PrimaryDark;
    LBackground.Alpha := 34;
  end;
  if not AEnabled then
    LBackground.Alpha := 120;

  FBackgroundPainter.Draw(ACanvas, LRect, LBackground);
  FBorderPainter.Draw(ACanvas, LRect, LBorder);
end;

procedure TMaxxRuralTabs.DrawUnderlineTab(const ACanvas: ISkCanvas;
  const ARect: TRectF; const ASelected, AHot, APressed, AEnabled: Boolean);
var
  LHoverIndicator: TRectF;
  LIndicator: TRectF;
  LRadius: Single;
begin
  LRadius := ScaleMetric(2);

  if ASelected then
  begin
    if FOrientation = mtoHorizontal then
      LIndicator := TRectF.Create(ARect.Left + ScaleMetric(8), ARect.Bottom - ScaleMetric(4),
        ARect.Right - ScaleMetric(8), ARect.Bottom)
    else
      LIndicator := TRectF.Create(ARect.Left, ARect.Top + ScaleMetric(8),
        ARect.Left + ScaleMetric(4), ARect.Bottom - ScaleMetric(8));

    FRenderer.FillRoundRect(ACanvas, LIndicator, TMaxxRuralComponentColors.PrimaryDark,
      LRadius, 255);
    Exit;
  end;

  if not (AHot or APressed) or not AEnabled then
    Exit;

  if FOrientation = mtoHorizontal then
    LHoverIndicator := TRectF.Create(ARect.Left + ScaleMetric(12), ARect.Bottom - ScaleMetric(3),
      ARect.Right - ScaleMetric(12), ARect.Bottom - ScaleMetric(1))
  else
    LHoverIndicator := TRectF.Create(ARect.Left + ScaleMetric(1), ARect.Top + ScaleMetric(12),
      ARect.Left + ScaleMetric(3), ARect.Bottom - ScaleMetric(12));

  if APressed then
    FRenderer.FillRoundRect(ACanvas, LHoverIndicator, TMaxxRuralComponentColors.PrimaryDark,
      LRadius, 160)
  else
    FRenderer.FillRoundRect(ACanvas, LHoverIndicator, TMaxxRuralComponentColors.PrimaryLight,
      LRadius, 130);
end;

procedure TMaxxRuralTabs.EnsureLabels;
var
  LLabel: TMaxxRuralSystemText;
begin
  while FLabels.Count < FItems.Count do
  begin
    LLabel := TMaxxRuralSystemText.Create(Self);
    LLabel.Parent := Self;
    LLabel.SetSubComponent(True);
    LLabel.Cursor := crHandPoint;
    LLabel.OnMouseDown := LabelMouseDown;
    LLabel.OnMouseEnter := LabelMouseEnter;
    LLabel.OnMouseLeave := LabelMouseLeave;
    LLabel.OnMouseMove := LabelMouseMove;
    LLabel.OnMouseUp := LabelMouseUp;
    FLabels.Add(LLabel);
  end;

  while FLabels.Count > FItems.Count do
  begin
    LLabel := FLabels[FLabels.Count - 1];
    FLabels.Delete(FLabels.Count - 1);
    LLabel.Free;
  end;
end;

function TMaxxRuralTabs.FirstEnabledTabIndex: Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to FItems.Count - 1 do
  begin
    if FItems[I].Enabled then
      Exit(I);
  end;
end;

function TMaxxRuralTabs.HitTestTab(const X, Y: Integer): Integer;
var
  I: Integer;
begin
  Result := -1;
  for I := 0 to FItems.Count - 1 do
  begin
    if PtInRect(TabRect(I), Point(X, Y)) then
      Exit(I);
  end;
end;

procedure TMaxxRuralTabs.InvalidateTabs;
begin
  UpdateInternalBounds;
  UpdateLabels;
  Redraw;
end;

procedure TMaxxRuralTabs.ItemsChanged;
begin
  if FItems.Count = 0 then
    FActiveIndex := -1
  else if FActiveIndex < 0 then
    FActiveIndex := FirstEnabledTabIndex
  else if FActiveIndex >= FItems.Count then
    FActiveIndex := FirstEnabledTabIndex
  else if not FItems[FActiveIndex].Enabled then
    FActiveIndex := FirstEnabledTabIndex;

  InvalidateTabs;
  Realign;
end;

procedure TMaxxRuralTabs.KeyDown(var Key: Word; Shift: TShiftState);
var
  LNext: Integer;
begin
  inherited;
  if FItems.Count = 0 then
    Exit;

  LNext := FActiveIndex;
  case Key of
    VK_HOME:
      LNext := 0;
    VK_END:
      LNext := FItems.Count - 1;
    VK_LEFT:
      if FOrientation = mtoHorizontal then
        LNext := Max(0, FActiveIndex - 1);
    VK_RIGHT:
      if FOrientation = mtoHorizontal then
        LNext := Min(FItems.Count - 1, FActiveIndex + 1);
    VK_UP:
      if FOrientation = mtoVertical then
        LNext := Max(0, FActiveIndex - 1);
    VK_DOWN:
      if FOrientation = mtoVertical then
        LNext := Min(FItems.Count - 1, FActiveIndex + 1);
  end;

  if (LNext <> FActiveIndex) and FItems[LNext].Enabled then
  begin
    SelectTab(LNext);
    Key := 0;
  end;
end;

procedure TMaxxRuralTabs.LabelMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  LIndex: Integer;
begin
  if Sender is TMaxxRuralSystemText then
  begin
    LIndex := TMaxxRuralSystemText(Sender).Tag;
    MouseDown(Button, Shift, TabRect(LIndex).Left + X, TabRect(LIndex).Top + Y);
  end;
end;

procedure TMaxxRuralTabs.LabelMouseEnter(Sender: TObject);
begin
  PaintBoxMouseEnter(Sender);
end;

procedure TMaxxRuralTabs.LabelMouseLeave(Sender: TObject);
begin
  if not CursorInside then
    PaintBoxMouseLeave(Sender);
end;

procedure TMaxxRuralTabs.LabelMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
var
  LIndex: Integer;
begin
  if Sender is TMaxxRuralSystemText then
  begin
    LIndex := TMaxxRuralSystemText(Sender).Tag;
    MouseMove(Shift, TabRect(LIndex).Left + X, TabRect(LIndex).Top + Y);
  end;
end;

procedure TMaxxRuralTabs.LabelMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  LIndex: Integer;
begin
  if Sender is TMaxxRuralSystemText then
  begin
    LIndex := TMaxxRuralSystemText(Sender).Tag;
    MouseUp(Button, Shift, TabRect(LIndex).Left + X, TabRect(LIndex).Top + Y);
  end;
end;

procedure TMaxxRuralTabs.Loaded;
begin
  inherited;
  ResetToFirstTab;
  NormalizeContentChildren;
  UpdateInternalBounds;
  UpdateLabels;
  UpdateInternalZOrder;
  Redraw;
end;

procedure TMaxxRuralTabs.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  LIndex: Integer;
begin
  inherited;
  if Button <> mbLeft then
    Exit;

  LIndex := HitTestTab(X, Y);
  if (LIndex >= 0) and FItems[LIndex].Enabled and Enabled then
  begin
    if CanFocus then
      SetFocus;
    FPressedIndex := LIndex;
    MouseCapture := True;
    Redraw;
  end;
end;

procedure TMaxxRuralTabs.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LIndex: Integer;
begin
  inherited;
  LIndex := HitTestTab(X, Y);
  if LIndex <> FHotIndex then
  begin
    FHotIndex := LIndex;
    UpdateLabels;
    Redraw;
  end;
end;

procedure TMaxxRuralTabs.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  LIndex: Integer;
  LPressedIndex: Integer;
  LSelected: Boolean;
begin
  inherited;
  if Button <> mbLeft then
    Exit;

  LPressedIndex := FPressedIndex;
  FPressedIndex := -1;
  MouseCapture := False;
  LIndex := HitTestTab(X, Y);
  LSelected := (LIndex = LPressedIndex) and (LIndex >= 0) and FItems[LIndex].Enabled;
  if LSelected then
    SelectTab(LIndex);
  if not LSelected then
    Redraw;
end;

procedure TMaxxRuralTabs.PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
  const ADest: TRectF; const AOpacity: Single);
var
  LBackground: TMaxxRuralBackgroundStyle;
  LBorder: TMaxxRuralBorderStyle;
  LContentRect: TRectF;
  LLineRect: TRectF;
  LScale: Single;
  LTabRect: TRectF;
  I: Integer;
begin
  if (ACanvas = nil) or (ADest.Width <= 0) or (ADest.Height <= 0) then
    Exit;

  LScale := ScaleFactor;
  ACanvas.Clear(ParentSurfaceColor);

  LContentRect := FRenderer.SnapRect(ContentChromeRect(ADest.Width, ADest.Height), LScale);
  LBackground.Color := FContentColor;
  LBackground.Radius := FCornerRadius;
  LBackground.Alpha := 255;

  if FShowContentBorder then
  begin
    LBorder.Color := TMaxxRuralComponentColors.ControlBorder;
    LBorder.Radius := FCornerRadius;
    LBorder.Width := 1;
    LBorder.Alpha := 255;
    FBackgroundPainter.Draw(ACanvas, LContentRect, LBackground);
    FBorderPainter.Draw(ACanvas, LContentRect, LBorder);
  end;
  if not FShowContentBorder then
    FRenderer.FillRoundRect(ACanvas, LContentRect, FContentColor, 0, 255);

  if FAppearance = mtaUnderline then
  begin
    if FOrientation = mtoHorizontal then
      LLineRect := TRectF.Create(0, ContentOffset - 1, ADest.Width, ContentOffset)
    else
      LLineRect := TRectF.Create(ContentOffset - 1, 0, ContentOffset, ADest.Height);
    FRenderer.FillRoundRect(ACanvas, LLineRect, TMaxxRuralComponentColors.ControlBorder,
      0, 255);
  end;

  for I := 0 to FItems.Count - 1 do
  begin
    LTabRect := TabRectF(I);
    if FAppearance = mtaPills then
      DrawPillTab(ACanvas, LTabRect, I = FActiveIndex, I = FHotIndex,
        I = FPressedIndex, Enabled and FItems[I].Enabled)
    else
      DrawUnderlineTab(ACanvas, LTabRect, I = FActiveIndex, I = FHotIndex,
        I = FPressedIndex, Enabled and FItems[I].Enabled);
  end;
end;

procedure TMaxxRuralTabs.PaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  MouseDown(Button, Shift, X, Y);
end;

procedure TMaxxRuralTabs.PaintBoxMouseEnter(Sender: TObject);
begin
  UpdateCursor;
end;

procedure TMaxxRuralTabs.PaintBoxMouseLeave(Sender: TObject);
begin
  if not MouseCapture and not CursorInside then
  begin
    FHotIndex := -1;
    FPressedIndex := -1;
    UpdateLabels;
    Redraw;
  end;
end;

procedure TMaxxRuralTabs.PaintBoxMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  MouseMove(Shift, X, Y);
end;

procedure TMaxxRuralTabs.PaintBoxMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  MouseUp(Button, Shift, X, Y);
end;

procedure TMaxxRuralTabs.NormalizeContentChildren;
var
  I: Integer;
begin
  for I := 0 to ControlCount - 1 do
    ApplyContentSurfaceToChild(Controls[I]);
end;

procedure TMaxxRuralTabs.ResetToFirstTab;
begin
  FActiveIndex := FirstEnabledTabIndex;
  FHotIndex := -1;
  FPressedIndex := -1;
end;

function TMaxxRuralTabs.ParentSurfaceColor: TAlphaColor;
begin
  Result := TMaxxRuralComponentColors.ResolveParentSurface(Self);
end;

procedure TMaxxRuralTabs.Redraw;
begin
  if (FPaintBox <> nil) and HandleAllocated then
    FPaintBox.Redraw;
end;

procedure TMaxxRuralTabs.Resize;
begin
  inherited;
  UpdateInternalBounds;
  UpdateLabels;
  Redraw;
end;

function TMaxxRuralTabs.ScaleFactor: Single;
begin
  Result := 1;
  if FPaintBox <> nil then
    Result := FPaintBox.ScaleFactor;
  if Result <= 0 then
    Result := 1;
end;

function TMaxxRuralTabs.ScaleMetric(const AValue: Integer): Integer;
begin
  Result := Round(AValue * ScaleFactor);
  if (AValue > 0) and (Result < 1) then
    Result := 1;
end;

procedure TMaxxRuralTabs.SelectTab(const AIndex: Integer; const ANotify: Boolean);
begin
  if (AIndex < -1) or (AIndex >= FItems.Count) then
    Exit;
  if (AIndex >= 0) and not FItems[AIndex].Enabled then
    Exit;
  if FActiveIndex = AIndex then
    Exit;

  FActiveIndex := AIndex;
  UpdateInternalBounds;
  UpdateLabels;
  if ANotify and Assigned(FOnChange) then
    FOnChange(Self);
  Redraw;
end;

procedure TMaxxRuralTabs.SetActiveIndex(const AValue: Integer);
begin
  if FItems.Count = 0 then
    SelectTab(-1, False)
  else
    SelectTab(Max(-1, Min(AValue, FItems.Count - 1)), False);
end;

procedure TMaxxRuralTabs.SetAppearance(const AValue: TMaxxRuralTabAppearance);
begin
  if FAppearance = AValue then
    Exit;
  FAppearance := AValue;
  InvalidateTabs;
end;

procedure TMaxxRuralTabs.SetContentColor(const AValue: TAlphaColor);
var
  LValue: TAlphaColor;
begin
  LValue := TMaxxRuralComponentColors.Normalize(AValue);
  if FContentColor = LValue then
    Exit;

  FContentColor := LValue;
  NormalizeContentChildren;
  InvalidateTabs;
end;

procedure TMaxxRuralTabs.SetCornerRadius(const AValue: Integer);
begin
  if FCornerRadius = AValue then
    Exit;
  FCornerRadius := Max(0, AValue);
  InvalidateTabs;
end;

procedure TMaxxRuralTabs.SetItems(const AValue: TMaxxRuralTabItems);
begin
  FItems.Assign(AValue);
  ItemsChanged;
end;

procedure TMaxxRuralTabs.SetOrientation(const AValue: TMaxxRuralTabOrientation);
begin
  if FOrientation = AValue then
    Exit;
  FOrientation := AValue;
  Realign;
  InvalidateTabs;
end;

procedure TMaxxRuralTabs.SetShowContentBorder(const AValue: Boolean);
begin
  if FShowContentBorder = AValue then
    Exit;
  FShowContentBorder := AValue;
  InvalidateTabs;
end;

procedure TMaxxRuralTabs.SetTabHeight(const AValue: Integer);
begin
  if FTabHeight = AValue then
    Exit;
  FTabHeight := Max(24, AValue);
  Realign;
  InvalidateTabs;
end;

procedure TMaxxRuralTabs.SetTabWidth(const AValue: Integer);
begin
  if FTabWidth = AValue then
    Exit;
  FTabWidth := Max(64, AValue);
  Realign;
  InvalidateTabs;
end;

function TMaxxRuralTabs.TabRect(const AIndex: Integer): TRect;
var
  LHeight: Integer;
  LWidth: Integer;
begin
  if FOrientation = mtoHorizontal then
  begin
    LWidth := ScaleMetric(FTabWidth);
    LHeight := ScaleMetric(FTabHeight);
    Result := Rect(AIndex * LWidth, 0, (AIndex + 1) * LWidth, LHeight);
  end
  else
  begin
    LWidth := ScaleMetric(FTabWidth);
    LHeight := ScaleMetric(FTabHeight);
    Result := Rect(0, AIndex * LHeight, LWidth, (AIndex + 1) * LHeight);
  end;
end;

function TMaxxRuralTabs.TabRectF(const AIndex: Integer): TRectF;
var
  LRect: TRect;
begin
  LRect := TabRect(AIndex);
  Result := TRectF.Create(LRect.Left, LRect.Top, LRect.Right, LRect.Bottom);
end;

function TMaxxRuralTabs.TabTextColor(const AIndex: Integer): TAlphaColor;
begin
  if not Enabled or not FItems[AIndex].Enabled then
    Exit(TMaxxRuralComponentColors.ControlTextDisabled);

  if FAppearance = mtaPills then
  begin
    if AIndex = FActiveIndex then
      Exit(TMaxxRuralComponentColors.White);
    if AIndex = FHotIndex then
      Exit(TMaxxRuralComponentColors.PrimaryDark);
    Exit(TMaxxRuralComponentColors.ControlText);
  end;

  if AIndex = FActiveIndex then
    Result := TMaxxRuralComponentColors.PrimaryDark
  else if AIndex = FHotIndex then
    Result := TMaxxRuralComponentColors.Primary
  else
    Result := TMaxxRuralComponentColors.Alpha(70, 82, 78);
end;

function TMaxxRuralTabs.TabTextBold(const AIndex: Integer): Boolean;
begin
  Result := AIndex = FActiveIndex;
end;

procedure TMaxxRuralTabs.UpdateCursor;
var
  LCursor: TCursor;
begin
  if Enabled then
    LCursor := crHandPoint
  else
    LCursor := crDefault;
  Cursor := LCursor;
  if FPaintBox <> nil then
    FPaintBox.Cursor := LCursor;
end;

procedure TMaxxRuralTabs.UpdateInternalBounds;
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

procedure TMaxxRuralTabs.UpdateInternalZOrder;
begin
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    Exit;
  if csDesigning in ComponentState then
    Exit;
  if not HandleAllocated then
    Exit;
  if (FPaintBox = nil) or (FPaintBox.Parent = nil) or
    not FPaintBox.Parent.HandleAllocated then
    Exit;

  FPaintBox.SendToBack;
end;

procedure TMaxxRuralTabs.UpdateLabels;
var
  I: Integer;
  LCursor: TCursor;
  LInset: Integer;
  LLabel: TMaxxRuralSystemText;
  LRect: TRect;
begin
  if (FLabels = nil) or (FItems = nil) then
    Exit;

  EnsureLabels;
  if Enabled then
    LCursor := crHandPoint
  else
    LCursor := crDefault;

  for I := 0 to FItems.Count - 1 do
  begin
    LLabel := FLabels[I];
    LRect := TabRect(I);
    LInset := ScaleMetric(8);
    if FAppearance = mtaPills then
      InflateRect(LRect, -ScaleMetric(4), -ScaleMetric(4));

    LLabel.BeginUpdate;
    try
      LLabel.Tag := I;
      if not LLabel.Visible then
        LLabel.Visible := True;
      LLabel.Enabled := Enabled and FItems[I].Enabled;
      LLabel.Cursor := LCursor;
      if (LLabel.Left <> LRect.Left + LInset) or
        (LLabel.Top <> LRect.Top) or
        (LLabel.Width <> Max(0, LRect.Width - (LInset * 2))) or
        (LLabel.Height <> LRect.Height) then
        LLabel.SetBounds(LRect.Left + LInset, LRect.Top,
          Max(0, LRect.Width - (LInset * 2)), LRect.Height);
      LLabel.Text := FItems[I].Caption;
      LLabel.FontFamily := TMaxxRuralComponentFontInstaller.FontFamily;
      LLabel.FontSize := 9;
      LLabel.Bold := TabTextBold(I);
      LLabel.TextColor := TabTextColor(I);
      LLabel.HorzAlign := mthaCenter;
      LLabel.VertAlign := mtvaCenter;
      LLabel.MaxLines := 1;
    finally
      LLabel.EndUpdate;
    end;
  end;
end;

procedure TMaxxRuralTabs.WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
begin
  AMessage.Result := 1;
end;

end.
