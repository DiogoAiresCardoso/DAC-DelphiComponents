unit DAC.Components.Controls.Tabs;

interface

uses
  System.Classes,
  System.Generics.Collections,
  System.Skia,
  System.Types,
  System.UITypes,
  Winapi.CommCtrl,
  Winapi.Messages,
  Winapi.Windows,
  Vcl.ComCtrls,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.Skia,
  DAC.Components.Controls.SystemText,
  DAC.Components.DesignSystem.ControlTokens,
  DAC.Components.DesignSystem.Theme,
  DAC.Components.Skia.Renderer;

const
  WM_DAC_TABS_REFRESH_LAYOUT = WM_APP + 79;

type
  TDACTabs = class;

  TDACTabOrientation = (mtoHorizontal, mtoVertical);
  // mtaUnderline is intentionally retained as the serialized name of Line.
  // Appending values preserves the ordinals of existing DFM resources.
  TDACTabAppearance = (mtaUnderline, mtaPills, mtaFilled, mtaSegmented);
  TDACTabSize = (mtsSmall, mtsMedium, mtsLarge);

  TDACTabLayoutItem = record
    PageIndex: Integer;
    Bounds: TRectF;
    TextBounds: TRectF;
    Text: string;
  end;
  TDACTabLayout = array of TDACTabLayoutItem;

  TDACTabSheetAccess = class(TTabSheet)
  end;

  // A windowed, owned header keeps Skia chrome and native Windows text
  // together inside TDACTabs. The native TTabSheet layout reserves its bounds
  // in both the VCL designer and runtime; no sibling overlay is required.
  TDACTabHeaderControl = class(TCustomControl)
  private
    FPaintBox: TSkPaintBox;
    FTabs: TDACTabs;
    FHotIndex: Integer;
    FRenderer: TDACSkiaRenderer;
    FTextOverlay: TGraphicControl;
    FMeasureBitmap: TBitmap;
    FScrollOffset: Integer;
    procedure DrawNativeText(const ACanvas: TCanvas);
    procedure SetTextFont(const ACanvas: TCanvas; const ABold: Boolean);
    function CaptionSize(const AText: string; const AWidth: Integer): TSize;
    function WrappedCaption(const AText: string; const AWidth: Integer): string;
    function TabAt(const X, Y: Integer): Integer;
    procedure PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    procedure PaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxMouseLeave(Sender: TObject);
    procedure PaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure ClearHot;
  protected
    procedure CMMouseLeave(var AMessage: TMessage); message CM_MOUSELEAVE;
    procedure CMDesignHitTest(var AMessage: TCMDesignHitTest); message CM_DESIGNHITTEST;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
      MousePos: TPoint): Boolean; override;
  public
    constructor CreateForTabs(ATabs: TDACTabs);
    destructor Destroy; override;
    function BuildTabLayout: TDACTabLayout;
    function FocusRectForPage(const APageIndex: Integer): TRectF;
    function HitTestPageAt(const X, Y: Integer): Integer;
    function ResolvedTextColorForPage(const APageIndex: Integer;
      const AHot: Boolean): TAlphaColor;
    function TabRectForPage(const APageIndex: Integer): TRectF;
    procedure Redraw;
  end;

  TDACTabs = class(TPageControl)
  private
    FAppearance: TDACTabAppearance;
    FActivePageHeaderOnly: Boolean;
    FActiveIndex: Integer;
    FContentColor: TAlphaColor;
    FContentLayoutRevision: Cardinal;
    FChangeRevision: Cardinal;
    FCornerRadius: Integer;
    FHeader: TDACTabHeaderControl;
    FHeaderTrailingReserve: Integer;
    FKeyboardFocusVisible: Boolean;
    FNotifiedActiveIndex: Integer;
    FOrientation: TDACTabOrientation;
    FPendingParent: TWinControl;
    FThemeMode: TDACThemeMode;
    FCustomContentColor: Boolean;
    FShowContentBorder: Boolean;
    FSize: TDACTabSize;
    FStreamingHostUsed: Boolean;
    FUpdatingHeader: Boolean;
    FChromePixels: TArray<Cardinal>;
    FChromeSurface: ISkSurface;
    FChromeWidth, FChromeHeight: Integer;
    FChromeRenderer: TDACSkiaRenderer;
    FTabHeightValue: Smallint;
    FTabWidthValue: Smallint;
    function ContentFrameRect: TRect;
    function GetActiveIndex: Integer;
    function GetOrientation: TDACTabOrientation;
    function HeaderExtent: Integer;
    function HeaderShouldBeVisible: Boolean;
    function ResolveSizeMetrics: TDACControlSizeTokens;
    function SelectAdjacentEnabledPage(const AForward: Boolean): Boolean;
    procedure EnsureHeader;
    function IsPageHandleCurrent(const APageIndex: Integer;
      const APageHandle: HWND): Boolean;
    procedure ApplyOrientation;
    procedure ApplyNativeTabSize;
    procedure LayoutPageContent;
    procedure NotifyActivePageShowingChanged;
    procedure NotifyPageDescendantsShowingChanged(const APageIndex: Integer;
      const APageHandle: HWND);
    procedure QueueContentLayout;
    procedure SetActiveIndex(const AValue: Integer);
    procedure SetActivePageHeaderOnly(const AValue: Boolean);
    procedure SetAppearance(const AValue: TDACTabAppearance);
    procedure SetContentColor(const AValue: TAlphaColor);
    procedure SetCornerRadius(const AValue: Integer);
    procedure SetHeaderTrailingReserve(const AValue: Integer);
    procedure SetOrientation(const AValue: TDACTabOrientation);
    procedure SetShowContentBorder(const AValue: Boolean);
    procedure SetSize(const AValue: TDACTabSize);
    procedure SetTabHeightValue(const AValue: Smallint);
    procedure SetTabWidthValue(const AValue: Smallint);
    procedure SetThemeMode(const AValue: TDACThemeMode);
    procedure ThemeChanged(Sender: TObject);
    function Pixels(const AValue: Integer): Integer;
    procedure ApplyPageStyle;
    procedure InvalidateTabs;
    procedure UpdateHeaderBounds;
  protected
    procedure CMDialogKey(var AMessage: TCMDialogKey); message CM_DIALOGKEY;
    procedure CMEnabledChanged(var AMessage: TMessage); message CM_ENABLEDCHANGED;
    procedure CMVisibleChanged(var AMessage: TMessage); message CM_VISIBLECHANGED;
    procedure CMShowingChanged(var AMessage: TMessage); message CM_SHOWINGCHANGED;
    procedure AdjustClientRect(var Rect: TRect); override;
    procedure PaintWindow(DC: HDC); override;
    procedure WMEraseBkgnd(var AMessage: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WndProc(var Message: TMessage); override;
    procedure Change; override;
    procedure CreateParams(var Params: TCreateParams); override;
    procedure CreateWnd; override;
    procedure DestroyWnd; override;
    procedure DoEnter; override;
    procedure DoExit; override;
    function GetClientOrigin: TPoint; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure Loaded; override;
    procedure Resize; override;
    procedure SetParent(AParent: TWinControl); override;
    procedure WMTabsRefreshLayout(var AMessage: TMessage); message WM_DAC_TABS_REFRESH_LAYOUT;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    function ContentInset: Integer;
    function ResolvedTokens: TDACControlTokens;
    procedure RefreshContentLayout;
    procedure Redraw;
  published
    property ActiveIndex: Integer read GetActiveIndex write SetActiveIndex default -1;
    property ActivePageHeaderOnly: Boolean read FActivePageHeaderOnly
      write SetActivePageHeaderOnly default False;
    property Appearance: TDACTabAppearance read FAppearance write SetAppearance default mtaUnderline;
    property ContentColor: TAlphaColor read FContentColor write SetContentColor;
    property CornerRadius: Integer read FCornerRadius write SetCornerRadius
      default DACTabsDefaultCornerRadius;
    property HeaderTrailingReserve: Integer read FHeaderTrailingReserve
      write SetHeaderTrailingReserve default 0;
    property Orientation: TDACTabOrientation read GetOrientation write SetOrientation default mtoHorizontal;
    property ShowContentBorder: Boolean read FShowContentBorder write SetShowContentBorder default True;
    property Size: TDACTabSize read FSize write SetSize default mtsMedium;
    property TabHeight: Smallint read FTabHeightValue write SetTabHeightValue default 0;
    property TabWidth: Smallint read FTabWidthValue write SetTabWidthValue default 0;
    property ThemeMode: TDACThemeMode read FThemeMode write SetThemeMode default dtmInherit;
  end;

implementation

uses
  System.Math,
  System.SysUtils,
  Vcl.ExtCtrls,
  Vcl.StdCtrls,
  DAC.Components.DesignSystem.ColorTokens,
  DAC.Components.DesignSystem.Fonts,
  DAC.Components.DesignSystem.ComponentStyle;

type
  TWinControlAccess = class(TWinControl)
  end;

  TDACTabTextOverlay = class(TGraphicControl)
  private
    FHeader: TDACTabHeaderControl;
  protected
    procedure Paint; override;
  public
    constructor CreateForHeader(AHeader: TDACTabHeaderControl);
  end;

constructor TDACTabTextOverlay.CreateForHeader(AHeader: TDACTabHeaderControl);
begin
  inherited Create(AHeader);
  FHeader := AHeader;
  Enabled := False;
  SetSubComponent(True);
end;

procedure TDACTabTextOverlay.Paint;
begin
  FHeader.DrawNativeText(Canvas);
end;

function CollectTabsDescendantWindow(const AWindow: HWND;
  const AParameter: LPARAM): BOOL; stdcall;
begin
  TList<HWND>(Pointer(AParameter)).Add(AWindow);
  Result := True;
end;

function IsVclDescendantOf(const AControl, ARoot: TWinControl): Boolean;
var
  LParent: TWinControl;
begin
  Result := False;
  if (AControl = nil) or (ARoot = nil) or (AControl = ARoot) then
    Exit;
  LParent := AControl.Parent;
  while LParent <> nil do
  begin
    if LParent = ARoot then
      Exit(True);
    LParent := LParent.Parent;
  end;
end;

constructor TDACTabHeaderControl.CreateForTabs(ATabs: TDACTabs);
begin
  inherited Create(ATabs);
  ControlStyle := ControlStyle + [csOpaque, csDesignInteractive];
  FTabs := ATabs;
  FHotIndex := -1;
  FRenderer := TDACSkiaRenderer.Create;
  FMeasureBitmap := TBitmap.Create;
  SetSubComponent(True);
  StyleElements := [];
  FPaintBox := TSkPaintBox.Create(Self);
  FPaintBox.Parent := Self;
  FPaintBox.Align := alClient;
  FPaintBox.SetSubComponent(True);
  FPaintBox.StyleElements := [];
  FPaintBox.OnDraw := PaintBoxDraw;
  FPaintBox.OnMouseDown := PaintBoxMouseDown;
  FPaintBox.OnMouseLeave := PaintBoxMouseLeave;
  FPaintBox.OnMouseMove := PaintBoxMouseMove;
  FTextOverlay := TDACTabTextOverlay.CreateForHeader(Self);
  FTextOverlay.Parent := Self;
  FTextOverlay.SetSubComponent(True);
  FTextOverlay.Align := alClient;
end;

destructor TDACTabHeaderControl.Destroy;
begin
  // FPaintBox is owned by this component.  TComponent releases owned
  // components after the window hierarchy is dismantled; freeing it here
  // also made its graphic-control removal race the host destruction.
  FTextOverlay.Free;
  FMeasureBitmap.Free;
  FRenderer.Free;
  inherited;
end;

procedure TDACTabHeaderControl.ClearHot;
begin
  if FHotIndex = -1 then
    Exit;
  FHotIndex := -1;
  Cursor := crDefault;
  Redraw;
end;

procedure TDACTabHeaderControl.CMMouseLeave(var AMessage: TMessage);
begin
  inherited;
  ClearHot;
end;

procedure TDACTabHeaderControl.SetTextFont(const ACanvas: TCanvas;
  const ABold: Boolean);
begin
  ACanvas.Font.Name := TDACComponentStyle.FontFamily;
  ACanvas.Font.Height := -Round(FTabs.ResolveSizeMetrics.TextSize);
  if ABold then ACanvas.Font.Style := [fsBold]
  else ACanvas.Font.Style := [];
end;

function TDACTabHeaderControl.WrappedCaption(const AText: string;
  const AWidth: Integer): string;
var
  I, Count: Integer;
  Word, Glyph: string;
begin
  Result := '';
  Word := '';
  SetTextFont(FMeasureBitmap.Canvas, True);
  I := 1;
  while I <= Length(AText) do
  begin
    Count := 1;
    if (Ord(AText[I]) >= $D800) and (Ord(AText[I]) <= $DBFF) and
      (I < Length(AText)) and (Ord(AText[I + 1]) >= $DC00) and
      (Ord(AText[I + 1]) <= $DFFF) then Count := 2;
    Glyph := Copy(AText, I, Count);
    if AText[I] <= ' ' then
    begin
      Result := Result + Word + Glyph;
      Word := '';
    end
    else
    begin
      if (Word <> '') and
        (FMeasureBitmap.Canvas.TextWidth(Word + Glyph) > Max(1, AWidth)) then
      begin
        Result := Result + Word + sLineBreak;
        Word := '';
      end;
      Word := Word + Glyph;
    end;
    Inc(I, Count);
  end;
  Result := Result + Word;
end;

function TDACTabHeaderControl.CaptionSize(const AText: string;
  const AWidth: Integer): TSize;
var
  R: TRect;
  Text: string;
begin
  // Reserve the bold selection font for every page. Measurement and drawing
  // share Windows font metrics; Skia glyph widths cannot size native text.
  SetTextFont(FMeasureBitmap.Canvas, True);
  if AWidth <= 0 then
    Result := FMeasureBitmap.Canvas.TextExtent(AText)
  else
  begin
    R := Rect(0, 0, Max(1, AWidth), 0);
    Text := WrappedCaption(AText, AWidth);
    DrawText(FMeasureBitmap.Canvas.Handle, PChar(Text), Length(Text), R,
      DT_CALCRECT or DT_WORDBREAK or DT_NOPREFIX);
    Result := TSize.Create(R.Width, R.Height);
  end;
end;

function TDACTabHeaderControl.BuildTabLayout: TDACTabLayout;
var
  I, J, N, RowStart: Integer;
  Available, Gap, Inset, X, Y, W, H, RowHeight: Single;
  Metrics: TDACControlSizeTokens;
  TextSize: TSize;
begin
  SetLength(Result, 0);
  if FTabs = nil then Exit;
  Metrics := FTabs.ResolveSizeMetrics;
  Inset := FTabs.ResolvedTokens.TabsHeaderInset;
  Available := Max(1, Width - 2 * Inset);
  if FTabs.Orientation = mtoHorizontal then
    Available := Max(1, Available - FTabs.HeaderTrailingReserve);
  N := 0;
  for I := 0 to FTabs.PageCount - 1 do
    if FTabs.Pages[I].TabVisible and
      (not FTabs.ActivePageHeaderOnly or (FTabs.Pages[I] = FTabs.ActivePage)) then
      Inc(N);
  SetLength(Result, N);
  if N = 0 then Exit;
  Gap := 0;
  if FTabs.Appearance = mtaPills then Gap := FTabs.ResolvedTokens.TabsItemGap;
  X := Inset;
  Y := Inset;
  if FTabs.Orientation = mtoVertical then Y := Y - FScrollOffset;
  N := 0;
  RowStart := 0;
  RowHeight := Metrics.Height;
  for I := 0 to FTabs.PageCount - 1 do
  begin
    if not FTabs.Pages[I].TabVisible or
      (FTabs.ActivePageHeaderOnly and (FTabs.Pages[I] <> FTabs.ActivePage)) then
      Continue;
    TextSize := CaptionSize(FTabs.Pages[I].Caption, 0);
    W := Max(Max(FTabs.ResolvedTokens.TabsHorizontalMinItem, FTabs.TabWidth),
      TextSize.cx + 2 * Metrics.PaddingHorizontal + 2);
    if FTabs.Orientation = mtoVertical then W := Available
    else if FTabs.Appearance = mtaSegmented then W := Available / Length(Result);
    W := Min(Available, W);
    TextSize := CaptionSize(FTabs.Pages[I].Caption,
      Max(1, Floor(W - 2 * Metrics.PaddingHorizontal)));
    H := Max(Metrics.Height, TextSize.cy + 2 * Metrics.PaddingVertical);
    if FTabs.Orientation = mtoVertical then
    begin
      X := Inset;
      RowHeight := H;
    end
    else if (N > RowStart) and (X + W > Inset + Available + 0.01) then
    begin
      for J := RowStart to N - 1 do Result[J].Bounds.Bottom := Y + RowHeight;
      Y := Y + RowHeight + Gap;
      X := Inset;
      RowStart := N;
      RowHeight := Metrics.Height;
    end;
    RowHeight := Max(RowHeight, H);
    Result[N].PageIndex := I;
    Result[N].Bounds := TRectF.Create(X, Y, X + W, Y + H);
    if FTabs.Orientation = mtoVertical then Y := Y + H + Gap
    else X := X + W + Gap;
    Inc(N);
  end;
  if FTabs.Orientation = mtoHorizontal then
    for J := RowStart to N - 1 do Result[J].Bounds.Bottom := Y + RowHeight;
  for I := 0 to N - 1 do
  begin
    Result[I].TextBounds := Result[I].Bounds;
    Result[I].TextBounds.Inflate(-Metrics.PaddingHorizontal, -Metrics.PaddingVertical);
    Result[I].Text := WrappedCaption(FTabs.Pages[Result[I].PageIndex].Caption,
      Floor(Result[I].TextBounds.Width));
  end;
end;

procedure TDACTabHeaderControl.DrawNativeText(const ACanvas: TCanvas);
var
  I, Saved: Integer;
  Layout: TDACTabLayout;
  R, Measured: TRect;
  Flags: Cardinal;
  Page: TTabSheet;
begin
  if FTabs = nil then Exit;
  Layout := BuildTabLayout;
  Saved := SaveDC(ACanvas.Handle);
  try
    IntersectClipRect(ACanvas.Handle, 0, 0, Width, Height);
    SetBkMode(ACanvas.Handle, TRANSPARENT);
    for I := 0 to High(Layout) do
    begin
      Page := FTabs.Pages[Layout[I].PageIndex];
      SetTextFont(ACanvas, Page = FTabs.ActivePage);
      ACanvas.Font.Color := TDACComponentColors.ToVclColor(
        ResolvedTextColorForPage(Layout[I].PageIndex, Layout[I].PageIndex = FHotIndex));
      R := Rect(Ceil(Layout[I].TextBounds.Left), Ceil(Layout[I].TextBounds.Top),
        Floor(Layout[I].TextBounds.Right), Floor(Layout[I].TextBounds.Bottom));
      Flags := DT_WORDBREAK or DT_NOPREFIX;
      if FTabs.Orientation = mtoVertical then Flags := Flags or DT_LEFT
      else Flags := Flags or DT_CENTER;
      Measured := R;
      DrawText(ACanvas.Handle, PChar(Layout[I].Text), Length(Layout[I].Text),
        Measured, Flags or DT_CALCRECT);
      Inc(R.Top, Max(0, (R.Height - Measured.Height) div 2));
      DrawText(ACanvas.Handle, PChar(Layout[I].Text), Length(Layout[I].Text), R, Flags);
    end;
  finally
    RestoreDC(ACanvas.Handle, Saved);
  end;
end;

procedure TDACTabHeaderControl.CMDesignHitTest(var AMessage: TCMDesignHitTest);
begin
  AMessage.Result := Ord(TabAt(AMessage.Pos.X, AMessage.Pos.Y) >= 0);
end;

function TDACTabHeaderControl.DoMouseWheel(Shift: TShiftState;
  WheelDelta: Integer; MousePos: TPoint): Boolean;
var
  Layout: TDACTabLayout;
  Limit: Integer;
begin
  Result := False;
  if FTabs.Orientation <> mtoVertical then Exit;
  Layout := BuildTabLayout;
  if Length(Layout) = 0 then Exit;
  Limit := Max(0, Ceil(Layout[High(Layout)].Bounds.Bottom) + FScrollOffset +
    Round(FTabs.ResolvedTokens.TabsHeaderInset) - Height + FTabs.HeaderTrailingReserve);
  FScrollOffset := EnsureRange(FScrollOffset - Round(WheelDelta / WHEEL_DELTA *
    FTabs.ResolveSizeMetrics.Height), 0, Limit);
  Redraw;
  Result := True;
end;

procedure TDACTabHeaderControl.PaintBoxDraw(Sender: TObject;
  const ACanvas: ISkCanvas; const ADest: TRectF; const AOpacity: Single);
var
  I: Integer;
  LActive: Boolean;
  LDivider: TRectF;
  LEnabled: Boolean;
  LFocused: Boolean;
  LFocusRect: TRectF;
  LHot: Boolean;
  LLayout: TDACTabLayout;
  LMetrics: TDACControlSizeTokens;
  LPage: TTabSheet;
  LRect: TRectF;
  LUnderline: TRectF;
  LTokens: TDACControlTokens;
begin
  if (ACanvas = nil) or (FTabs = nil) then
    Exit;

  LTokens := FTabs.ResolvedTokens;
  LMetrics := FTabs.ResolveSizeMetrics;
  LLayout := BuildTabLayout;
  ACanvas.Clear(LTokens.TabsSurface);
  if FTabs.Appearance = mtaUnderline then
  begin
    if FTabs.Orientation = mtoHorizontal then
      LDivider := TRectF.Create(LTokens.TabsHeaderInset,
        ADest.Height - LTokens.TabsHeaderInset - LTokens.TabsDividerWidth,
        Max(LTokens.TabsHeaderInset, ADest.Width - LTokens.TabsHeaderInset -
          FTabs.FHeaderTrailingReserve),
        ADest.Height - LTokens.TabsHeaderInset)
    else
      LDivider := TRectF.Create(
        ADest.Width - LTokens.TabsHeaderInset - LTokens.TabsDividerWidth,
        LTokens.TabsHeaderInset,
        ADest.Width - LTokens.TabsHeaderInset,
        Max(LTokens.TabsHeaderInset, ADest.Height - LTokens.TabsHeaderInset -
          FTabs.FHeaderTrailingReserve));
    FRenderer.FillRoundRect(ACanvas, LDivider, LTokens.TabsDivider, 0);
  end;

  LFocused := FTabs.Focused and FTabs.FKeyboardFocusVisible;
  for I := 0 to Length(LLayout) - 1 do
  begin
    LPage := FTabs.Pages[LLayout[I].PageIndex];
    LRect := LLayout[I].Bounds;
    LActive := FTabs.ActivePage = LPage;
    LHot := LLayout[I].PageIndex = FHotIndex;
    LEnabled := FTabs.Enabled and LPage.Enabled;

    if LEnabled then
    begin
      case FTabs.Appearance of
        mtaUnderline:
          if LHot then
            FRenderer.FillRoundRect(ACanvas, LRect,
              LTokens.TabsHoverBackground, 0);
        mtaPills:
          if LActive then
            FRenderer.FillRoundRect(ACanvas, LRect,
              LTokens.TabsActiveBackground, LTokens.TabsPillRadius)
          else if LHot then
            FRenderer.FillRoundRect(ACanvas, LRect,
              LTokens.TabsHoverBackground, LTokens.TabsPillRadius);
        mtaFilled:
          if LActive then
            FRenderer.FillRoundRect(ACanvas, LRect,
              LTokens.TabsActiveBackground, LTokens.TabsHeaderRadius)
          else if LHot then
            FRenderer.FillRoundRect(ACanvas, LRect,
              LTokens.TabsHoverBackground, LTokens.TabsHeaderRadius);
        mtaSegmented:
          begin
            if I > 0 then
            begin
              LDivider := TRectF.Create(LRect.Left,
                LRect.Top + LMetrics.PaddingVertical, LRect.Left +
                LTokens.TabsDividerWidth,
                LRect.Bottom - LMetrics.PaddingVertical);
              FRenderer.FillRoundRect(ACanvas, LDivider,
                LTokens.TabsDivider, 0);
            end;
            if LActive then
              FRenderer.FillRoundRect(ACanvas, LRect,
                LTokens.TabsActiveBackground, LTokens.TabsHeaderRadius)
            else if LHot then
              FRenderer.FillRoundRect(ACanvas, LRect,
                LTokens.TabsHoverBackground, LTokens.TabsHeaderRadius);
          end;
      end;
    end;

    if LEnabled and LActive and (FTabs.Appearance = mtaUnderline) then
    begin
      LUnderline := LRect;
      if FTabs.Orientation = mtoHorizontal then
      begin
        LUnderline.Top := LUnderline.Bottom - LTokens.TabsIndicatorWidth;
      end
      else
      begin
        LUnderline.Right := LUnderline.Left + LTokens.TabsIndicatorWidth;
      end;
      FRenderer.FillRoundRect(ACanvas, LUnderline,
        LTokens.TabsIndicator, LTokens.TabsUnderlineRadius);
    end;

    if LEnabled and LActive and LFocused then
    begin
      LFocusRect := FocusRectForPage(LLayout[I].PageIndex);
      FRenderer.StrokeRoundRect(ACanvas, LFocusRect,
        LTokens.TabsFocus, LTokens.TabsFocusRadius,
        LTokens.TabsFocusWidth);
    end;
  end;
  FTextOverlay.Invalidate;
end;

procedure TDACTabHeaderControl.PaintBoxMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  LIndex: Integer;
begin
  if (Button <> mbLeft) or (FTabs = nil) then
    Exit;
  LIndex := TabAt(X, Y);
  if FTabs.Enabled and (LIndex >= 0) and (LIndex < FTabs.PageCount) and
    FTabs.Pages[LIndex].Enabled then
  begin
    FTabs.ActiveIndex := LIndex;
    if FTabs.CanFocus then
      FTabs.SetFocus;
    // Clicking keeps keyboard navigation available but must not draw the
    // keyboard-only focus ring over the selected pill.
    FTabs.FKeyboardFocusVisible := False;
    Redraw;
  end;
end;

procedure TDACTabHeaderControl.PaintBoxMouseLeave(Sender: TObject);
begin
  ClearHot;
end;

procedure TDACTabHeaderControl.PaintBoxMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  LIndex: Integer;
begin
  LIndex := TabAt(X, Y);
  if (LIndex >= 0) and ((FTabs = nil) or not FTabs.Enabled or
    not FTabs.Pages[LIndex].Enabled) then
    LIndex := -1;
  if LIndex <> FHotIndex then
  begin
    FHotIndex := LIndex;
    if LIndex >= 0 then
      Cursor := crHandPoint
    else
      Cursor := crDefault;
    Redraw;
  end;
end;

procedure TDACTabHeaderControl.Redraw;
begin
  if (FTabs = nil) or (csDestroying in ComponentState) then Exit;
  if HandleAllocated and (Parent <> nil) and Parent.HandleAllocated then
    FPaintBox.Redraw
  else
    FPaintBox.Invalidate;
  FTextOverlay.Invalidate;
end;

function TDACTabHeaderControl.TabAt(const X, Y: Integer): Integer;
var
  I: Integer;
  LLayout: TDACTabLayout;
begin
  Result := -1;
  if FTabs = nil then
    Exit;
  LLayout := BuildTabLayout;
  for I := 0 to Length(LLayout) - 1 do
    if LLayout[I].Bounds.Contains(TPointF.Create(X, Y)) then
      Exit(LLayout[I].PageIndex);
end;

function TDACTabHeaderControl.HitTestPageAt(const X, Y: Integer): Integer;
begin
  Result := TabAt(X, Y);
end;

function TDACTabHeaderControl.FocusRectForPage(
  const APageIndex: Integer): TRectF;
var
  LFocusWidth: Single;
begin
  Result := TabRectForPage(APageIndex);
  if (FTabs = nil) or (Result.Width <= 0) or (Result.Height <= 0) then
    Exit;
  // The stroke path is moved half a stroke outside the cell. Its inner edge
  // remains on the cell boundary and its outer edge consumes the reserved
  // header inset.
  LFocusWidth := FTabs.ResolvedTokens.TabsFocusWidth;
  Result.Inflate(LFocusWidth / 2, LFocusWidth / 2);
end;

function TDACTabHeaderControl.ResolvedTextColorForPage(
  const APageIndex: Integer; const AHot: Boolean): TAlphaColor;
var
  LTokens: TDACControlTokens;
begin
  if (FTabs = nil) or (APageIndex < 0) or (APageIndex >= FTabs.PageCount) then
    Exit(Default(TAlphaColor));
  LTokens := FTabs.ResolvedTokens;
  if not (FTabs.Enabled and FTabs.Pages[APageIndex].Enabled) then
    Exit(LTokens.TabsTextDisabled);
  if FTabs.ActivePage = FTabs.Pages[APageIndex] then
    Exit(LTokens.TabsTextActive);
  if AHot then
    Exit(LTokens.TabsTextHover);
  Result := LTokens.TabsTextDefault;
end;

function TDACTabHeaderControl.TabRectForPage(
  const APageIndex: Integer): TRectF;
var
  I: Integer;
  LLayout: TDACTabLayout;
begin
  Result := TRectF.Create(0, 0, 0, 0);
  if (FTabs = nil) or (APageIndex < 0) or (APageIndex >= FTabs.PageCount) or
    not FTabs.Pages[APageIndex].TabVisible then
    Exit;
  LLayout := BuildTabLayout;
  for I := 0 to Length(LLayout) - 1 do
    if LLayout[I].PageIndex = APageIndex then
      Exit(LLayout[I].Bounds);
end;

constructor TDACTabs.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FChromeRenderer := TDACSkiaRenderer.Create;
  Width := Round(TDACComponentStyle.Resolve(dtmInherit).Tokens.Controls.TabsDefaultWidth);
  Height := Round(TDACComponentStyle.Resolve(dtmInherit).Tokens.Controls.TabsDefaultHeight);
  DoubleBuffered := True;
  ParentDoubleBuffered := False;
  ParentColor := False;
  ParentBackground := False;
  ParentFont := False;
  StyleElements := [];
  TabStop := True;
  FAppearance := mtaUnderline;
  FActivePageHeaderOnly := False;
  FActiveIndex := -1;
  FNotifiedActiveIndex := -1;
  FKeyboardFocusVisible := False;
  FOrientation := mtoHorizontal;
  FThemeMode := dtmInherit;
  FContentColor := ResolvedTokens.ContainerSuiteBackground;
  FCornerRadius := Round(ResolvedTokens.TabsContentRadius);
  FShowContentBorder := True;
  FSize := mtsMedium;
  OwnerDraw := False;
  Style := tsTabs;
  EnsureHeader;
  FHeader.SetBounds(0, 0, Width, Round(ResolveSizeMetrics.Height +
    2 * ResolvedTokens.TabsHeaderInset));
  UpdateHeaderBounds;
  TDACThemeManager.RegisterListener(Self, ThemeChanged);
end;

procedure TDACTabs.SetActivePageHeaderOnly(const AValue: Boolean);
begin
  if FActivePageHeaderOnly = AValue then
    Exit;
  FActivePageHeaderOnly := AValue;
  QueueContentLayout;
  InvalidateTabs;
end;

procedure TDACTabs.DoEnter;
begin
  inherited;
  FKeyboardFocusVisible := True;
  InvalidateTabs;
end;

procedure TDACTabs.DoExit;
begin
  FKeyboardFocusVisible := False;
  InvalidateTabs;
  inherited;
end;

procedure TDACTabs.KeyDown(var Key: Word; Shift: TShiftState);
var
  LForward: Boolean;
begin
  FKeyboardFocusVisible := True;
  if (Key = VK_LEFT) or (Key = VK_UP) or (Key = VK_RIGHT) or
    (Key = VK_DOWN) or ((Key = VK_TAB) and (ssCtrl in Shift)) then
  begin
    LForward := (Key = VK_RIGHT) or (Key = VK_DOWN) or
      ((Key = VK_TAB) and not (ssShift in Shift));
    if Enabled then
      SelectAdjacentEnabledPage(LForward);
    Key := 0;
    InvalidateTabs;
    Exit;
  end;
  inherited;
  InvalidateTabs;
end;

procedure TDACTabs.CMEnabledChanged(var AMessage: TMessage);
begin
  inherited;
  if not Enabled and (FHeader <> nil) then
    FHeader.ClearHot;
  InvalidateTabs;
end;

procedure TDACTabs.CMDialogKey(var AMessage: TCMDialogKey);
begin
  if (Focused or Winapi.Windows.IsChild(Handle, Winapi.Windows.GetFocus)) and
    (AMessage.CharCode = VK_TAB) and
    (GetKeyState(VK_CONTROL) < 0) then
  begin
    if Enabled then
      SelectAdjacentEnabledPage(GetKeyState(VK_SHIFT) >= 0);
    AMessage.Result := 1;
  end
  else
    inherited;
end;

destructor TDACTabs.Destroy;
begin
  TDACThemeManager.UnregisterListener(Self);
  // FHeader is owned by this tab control.  Let TComponent dispose it in its
  // normal ownership pass, after the page-control window lifecycle has run.
  FChromeSurface := nil;
  FChromeRenderer.Free;
  inherited;
end;

procedure TDACTabs.ApplyNativeTabSize;
begin
  { Do not use the inherited TabHeight/TabWidth setters here. In particular,
    changing TabWidth between zero and non-zero calls RecreateWnd. CreateWnd
    can itself be entered by TTabStrings.Insert while the first TTabSheet is
    being streamed; recreating at that point loses the pending native item and
    leaves PageCount out of sync with TCM_GETITEMCOUNT. }
  if not HandleAllocated then
    Exit;
  SendMessage(Handle, TCM_SETITEMSIZE, 0, MakeLong(1, 1));
end;

procedure TDACTabs.ApplyOrientation;
begin
  { TabPosition recreates the native tab window.  During DFM loading that can
    happen between TTabSheet insertions, leaving the VCL page list and the
    native tab list temporarily out of sync.  Commit the streamed value only
    after Loaded, when every page already exists. }
  if (csLoading in ComponentState) or (csDestroying in ComponentState) or
    (Parent = nil) or not HandleAllocated or not Parent.HandleAllocated then
    Exit;
  if FOrientation = mtoVertical then
    TabPosition := tpLeft
  else
    TabPosition := tpTop;
end;

procedure TDACTabs.ApplyPageStyle;
var
  I: Integer;
  LPageColor: TColor;
  LRuntimeHostReady: Boolean;
  LTextColor: TColor;
  LTokens: TDACControlTokens;
  procedure RefreshSurface(const AControl: TControl);
  var
    J: Integer;
  begin
    TDACThemeManager.RefreshListener(AControl);
    if AControl is TWinControl then
      for J := 0 to TWinControl(AControl).ControlCount - 1 do
        RefreshSurface(TWinControl(AControl).Controls[J]);
  end;
  procedure RefreshPage(const APage: TTabSheet);
  var
    LCanCommitPaint: Boolean;
  begin
    LCanCommitPaint := LRuntimeHostReady and (APage = ActivePage) and
      APage.HandleAllocated;
    if LCanCommitPaint then
      SendMessage(APage.Handle, WM_SETREDRAW, 0, 0);
    try
      RefreshSurface(APage);
    finally
      if LCanCommitPaint then
      begin
        SendMessage(APage.Handle, WM_SETREDRAW, 1, 0);
        RedrawWindow(APage.Handle, nil, 0, RDW_INVALIDATE or RDW_ERASE or
          RDW_FRAME or RDW_ALLCHILDREN or RDW_ERASENOW or RDW_UPDATENOW);
      end;
    end;
  end;
begin
  if csDestroying in ComponentState then
    Exit;

  LTokens := ResolvedTokens;
  LRuntimeHostReady := not (csLoading in ComponentState) and
    (Parent <> nil) and
    HandleAllocated and Parent.HandleAllocated;

  { TPageControl.Color and native tab metrics can touch Handle on Delphi 10.2.
    Keep the logical page palette current during streaming/designer work, but
    defer native page-control work and physical repaint until the real parent
    chain exists. }
  Font.Name := TDACComponentStyle.FontFamily;
  Font.Size := TDACComponentStyle.TextSize;
  Font.Style := [];
  Font.Color := TDACComponentColors.ToVclColor(LTokens.ContainerTitle);
  if LRuntimeHostReady then
  begin
    Color := TDACComponentColors.ToVclColor(
      LTokens.ContainerSuiteBackground);
    ApplyNativeTabSize;
  end;

  for I := 0 to PageCount - 1 do
  begin
    if FCustomContentColor then
      LPageColor := TDACComponentColors.ToVclColor(FContentColor)
    else
      LPageColor := TDACComponentColors.ToVclColor(
        LTokens.ContainerSuiteBackground);
    TDACTabSheetAccess(Pages[I]).ParentColor := False;
    { Under a custom VCL style these two setters invalidate the styled
      TTabSheet. During DFM streaming the page control still owns its
      transactional popup HWND; touching them there lets the style hook
      process visibility against a native tab list that is being rebuilt.
      Commit them only after the real parent/handle chain is stable. }
    if LRuntimeHostReady then
    begin
      TDACTabSheetAccess(Pages[I]).ParentBackground := False;
      TDACTabSheetAccess(Pages[I]).StyleElements := [];
    end;
    TDACTabSheetAccess(Pages[I]).Color := LPageColor;
    LTextColor := TDACComponentColors.ToVclColor(LTokens.ContainerTitle);
    TDACTabSheetAccess(Pages[I]).ParentFont := False;
    TDACTabSheetAccess(Pages[I]).Font.Name := TDACComponentStyle.FontFamily;
    TDACTabSheetAccess(Pages[I]).Font.Size := TDACComponentStyle.TextSize;
    TDACTabSheetAccess(Pages[I]).Font.Style := [];
    TDACTabSheetAccess(Pages[I]).Font.Color := LTextColor;
    if not (csLoading in ComponentState) and
      not (csDesigning in ComponentState) then
    begin
      TDACNativeThemeScopeApplicator.Apply(Pages[I], LTokens);
      RefreshPage(Pages[I]);
    end;
  end;
  if LRuntimeHostReady then
  begin
    UpdateHeaderBounds;
    InvalidateTabs;
  end;
end;

procedure TDACTabs.Change;
begin
  Inc(FChangeRevision);
  if HandleAllocated then
  begin
    if ActivePage <> nil then
      FActiveIndex := ActivePage.PageIndex
    else
      FActiveIndex := -1;
  end;
  inherited;
  NotifyActivePageShowingChanged;
  ApplyPageStyle;
  { A page containing windowed editors and Skia graphic controls must reach
    its definitive content coordinates inside the selection-change message.
    Posting this layout allowed one native/Skia frame at the streamed DFM
    coordinates, leaving visible imprints when the new page was presented. }
  if HandleAllocated and (Parent <> nil) and Parent.HandleAllocated then
    RefreshContentLayout
  else
  begin
    UpdateHeaderBounds;
    QueueContentLayout;
    InvalidateTabs;
  end;
end;

procedure TDACTabs.CMShowingChanged(var AMessage: TMessage);
begin
  inherited;
  if Showing then
    EnsureHeader;
  UpdateHeaderBounds;
  QueueContentLayout;
  InvalidateTabs;
end;

procedure TDACTabs.CMVisibleChanged(var AMessage: TMessage);
begin
  inherited;
  UpdateHeaderBounds;
  InvalidateTabs;
end;

procedure TDACTabs.CreateParams(var Params: TCreateParams);
var
  LStreamingWithoutHost: Boolean;
begin
  LStreamingWithoutHost :=
    ([csLoading, csReading] * ComponentState <> []) and
    (Parent = nil);
  inherited;
  { TPageControl streams TTabSheet children through its native TTabStrings.
    A standalone ReadComponent therefore needs a HWND even though the public
    VCL Parent must remain nil. A temporary hidden popup avoids constructing a
    WS_CHILD with no VCL parent (several VCL messages still consult Parent).
    Loaded destroys this transactional HWND; assigning a real Parent later
    recreates the ordinary child control and restores the saved native tabs. }
  if LStreamingWithoutHost then
  begin
    Params.Style := (Params.Style and not WS_CHILD) or WS_POPUP;
    Params.ExStyle := Params.ExStyle or WS_EX_TOOLWINDOW or WS_EX_NOACTIVATE;
    Params.WndParent := 0;
    FStreamingHostUsed := True;
  end;
end;

procedure TDACTabs.CreateWnd;
begin
  inherited;
  ApplyOrientation;
  { Handle may be requested by TTabStrings.Insert before its TCM_INSERTITEM.
    Do not inspect pages or select tabs while that streaming transaction is
    incomplete. Loaded commits the pending selection after all pages exist. }
  if not (csLoading in ComponentState) then
  begin
    if PageCount = 0 then
      ActivePage := nil
    else
    begin
      FActiveIndex := Max(-1, Min(FActiveIndex, PageCount - 1));
      if FActiveIndex >= 0 then
        ActivePage := Pages[FActiveIndex]
      else
        ActivePage := nil;
    end;
  end;
  NotifyActivePageShowingChanged;
  ApplyNativeTabSize;
  EnsureHeader;
  ApplyPageStyle;
  QueueContentLayout;
end;

procedure TDACTabs.DestroyWnd;
begin
  // A recreated native page control must refresh the selected page's
  // descendant state even when its logical index did not change.
  FNotifiedActiveIndex := -1;
  inherited;
end;

procedure TDACTabs.EnsureHeader;
begin
  if (FHeader <> nil) or (csDestroying in ComponentState) then Exit;
  FHeader := TDACTabHeaderControl.CreateForTabs(Self);
  // The HWND header is a child of this component, never a designer sibling.
  // AdjustClientRect reserves its area before the native pages are aligned.
  FHeader.Parent := Self;
  FHeader.Visible := True;
end;

function TDACTabs.GetActiveIndex: Integer;
begin
  if HandleAllocated then
  begin
    if ActivePage <> nil then
      FActiveIndex := ActivePage.PageIndex
    else
      FActiveIndex := -1;
  end;
  Result := FActiveIndex;
end;

function TDACTabs.GetClientOrigin: TPoint;
begin
  { Child TTabSheet.Loaded can ask its page control for ClientOrigin before
    the standalone root receives a VCL Parent. The temporary native streaming
    host has origin (0,0); expose that same coordinate without forcing a
    public Parent relationship. }
  if (Parent = nil) and FStreamingHostUsed then
    Result := Point(0, 0)
  else
    Result := inherited GetClientOrigin;
end;

function TDACTabs.GetOrientation: TDACTabOrientation;
begin
  Result := FOrientation;
end;

procedure TDACTabs.NotifyActivePageShowingChanged;
var
  LActiveIndex: Integer;
  LActivePage: TWinControl;
  LActivePageHandle: HWND;
  LPreviousPageHandle: HWND;
  LPreviousIndex: Integer;
begin
  if (csLoading in ComponentState) or (csDestroying in ComponentState) or
    not HandleAllocated then
    Exit;

  if ActivePage <> nil then
    LActiveIndex := ActivePage.PageIndex
  else
    LActiveIndex := -1;
  if FNotifiedActiveIndex = LActiveIndex then
    Exit;
  LPreviousIndex := FNotifiedActiveIndex;
  LPreviousPageHandle := 0;
  if (LPreviousIndex >= 0) and (LPreviousIndex < PageCount) and
    Pages[LPreviousIndex].HandleAllocated then
    LPreviousPageHandle := Pages[LPreviousIndex].Handle;
  LActivePageHandle := 0;
  if (LActiveIndex >= 0) and (LActiveIndex < PageCount) and
    Pages[LActiveIndex].HandleAllocated then
    LActivePageHandle := Pages[LActiveIndex].Handle;
  FNotifiedActiveIndex := LActiveIndex;
  if LPreviousPageHandle <> 0 then
    NotifyPageDescendantsShowingChanged(LPreviousIndex,
      LPreviousPageHandle);

  // A hidden-page callback may remove/reorder pages or trigger another tab
  // change. Never apply the captured active page after that mutation.
  if (csDestroying in ComponentState) or
    (FNotifiedActiveIndex <> LActiveIndex) then
    Exit;
  if (ActivePage = nil) or (ActivePage.PageIndex <> LActiveIndex) or
    not IsPageHandleCurrent(LActiveIndex, LActivePageHandle) then
  begin
    FNotifiedActiveIndex := -1;
    Exit;
  end;
  LActivePage := FindControl(LActivePageHandle);
  if (LActivePage = nil) or
    (csDestroying in LActivePage.ComponentState) then
    Exit;
  // The active page has a showing ancestor chain. One root update uses the
  // normal VCL propagation and avoids revisiting every descendant.
  TWinControlAccess(LActivePage).UpdateControlState;
end;

procedure TDACTabs.NotifyPageDescendantsShowingChanged(
  const APageIndex: Integer; const APageHandle: HWND);
var
  I: Integer;
  LControl: TWinControl;
  LPage: TWinControl;
  LWindows: TList<HWND>;
  LWindow: HWND;
begin
  if not IsPageHandleCurrent(APageIndex, APageHandle) then
    Exit;
  // Callbacks can destroy or reparent siblings. Snapshot stable HWND values,
  // never component pointers, before dispatching the first lifecycle event.
  LWindows := TList<HWND>.Create;
  try
    EnumChildWindows(APageHandle, @CollectTabsDescendantWindow,
      LPARAM(Pointer(LWindows)));
    for I := 0 to LWindows.Count - 1 do
    begin
      LWindow := LWindows[I];
      if not IsPageHandleCurrent(APageIndex, APageHandle) then
        Exit;
      if not IsWindow(LWindow) or not IsChild(APageHandle, LWindow) then
        Continue;
      LPage := FindControl(APageHandle);
      LControl := FindControl(LWindow);
      if (LPage = nil) or (LControl = nil) or
        (csDestroying in LPage.ComponentState) or
        (csDestroying in LControl.ComponentState) or
        not LControl.HandleAllocated or (LControl.Handle <> LWindow) or
        not IsVclDescendantOf(LControl, LPage) then
        Continue;
      TWinControlAccess(LControl).UpdateControlState;
      // Do not access LControl/LPage after the callback. The next iteration
      // resolves and validates both again from their HWNDs.
    end;
  finally
    LWindows.Free;
  end;
end;

function TDACTabs.IsPageHandleCurrent(const APageIndex: Integer;
  const APageHandle: HWND): Boolean;
begin
  Result := (APageHandle <> 0) and IsWindow(APageHandle) and
    (APageIndex >= 0) and (APageIndex < PageCount) and
    (Pages[APageIndex] <> nil) and Pages[APageIndex].HandleAllocated and
    (Pages[APageIndex].Handle = APageHandle) and
    (FindControl(APageHandle) = Pages[APageIndex]) and
    not (csDestroying in Pages[APageIndex].ComponentState);
end;

function TDACTabs.HeaderExtent: Integer;
var
  Layout: TDACTabLayout;
  I: Integer;
  Metrics: TDACControlSizeTokens;
begin
  Metrics := ResolveSizeMetrics;
  if Orientation = mtoVertical then
    Exit(Max(Round(ResolvedTokens.TabsVerticalExtent), FTabWidthValue));
  Result := Round(Metrics.Height + 2 * ResolvedTokens.TabsHeaderInset);
  if FHeader <> nil then
  begin
    Layout := FHeader.BuildTabLayout;
    for I := 0 to High(Layout) do
      Result := Max(Result, Ceil(Layout[I].Bounds.Bottom + ResolvedTokens.TabsHeaderInset));
  end;
end;

function TDACTabs.HeaderShouldBeVisible: Boolean;
begin
  Result := Visible and (Showing or (csDesigning in ComponentState)) and
    not (csDestroying in ComponentState);
end;

function TDACTabs.ContentInset: Integer;
begin
  if Orientation = mtoVertical then
    Result := HeaderExtent + Pixels(Round(ResolvedTokens.TabsContentGutter))
  else
    Result := HeaderExtent + Pixels(Round(ResolvedTokens.TabsContentInset));
end;

procedure TDACTabs.InvalidateTabs;
begin
  if (FHeader <> nil) and FHeader.Visible then FHeader.Redraw;
  if HandleAllocated then Invalidate;
end;

function TDACTabs.ContentFrameRect: TRect;
begin
  Result := Rect(0, 0, Width, Height);
  if Orientation = mtoVertical then
    Result.Left := Min(Width, ContentInset)
  else
    Result.Top := Min(Height, ContentInset);
end;

procedure TDACTabs.AdjustClientRect(var Rect: TRect);
var
  Inset: Integer;
begin
  // Native TTabSheet/alClient and ordinary child coordinates share the same
  // page origin in the designer and at runtime. Never move page contents.
  Rect := ContentFrameRect;
  Inset := 0;
  if FShowContentBorder then Inset := Max(1, FCornerRadius);
  InflateRect(Rect, -Min(Inset, Max(0, Rect.Width div 2)),
    -Min(Inset, Max(0, Rect.Height div 2)));
  Inc(Rect.Left, Padding.Left);
  Inc(Rect.Top, Padding.Top);
  Dec(Rect.Right, Padding.Right);
  Dec(Rect.Bottom, Padding.Bottom);
end;

procedure TDACTabs.PaintWindow(DC: HDC);
var
  Info: TBitmapInfo;
  R: TRectF;
  Tokens: TDACControlTokens;
  FrameColor: TAlphaColor;
begin
  if (DC = 0) or (Width <= 0) or (Height <= 0) or (FChromeRenderer = nil) then Exit;
  if (FChromeSurface = nil) or (FChromeWidth <> Width) or (FChromeHeight <> Height) then
  begin
    FChromeSurface := nil;
    FChromeWidth := Width;
    FChromeHeight := Height;
    SetLength(FChromePixels, Width * Height);
    FChromeSurface := TSkSurface.MakeRasterDirect(TSkImageInfo.Create(Width, Height),
      @FChromePixels[0], Width * SizeOf(Cardinal));
  end;
  if FChromeSurface = nil then Exit;
  Tokens := ResolvedTokens;
  FChromeSurface.Canvas.Clear(Tokens.ContainerSuiteBackground);
  FrameColor := Tokens.ContainerSuiteBackground;
  if FCustomContentColor then FrameColor := FContentColor;
  R := TRectF.Create(ContentFrameRect);
  R.Inflate(-Tokens.TabsDividerWidth / 2, -Tokens.TabsDividerWidth / 2);
  FChromeRenderer.FillRoundRect(FChromeSurface.Canvas, R, FrameColor, FCornerRadius);
  if FShowContentBorder then
    FChromeRenderer.StrokeRoundRect(FChromeSurface.Canvas, R, Tokens.TabsDivider,
      FCornerRadius, Tokens.TabsDividerWidth);
  FChromeSurface.Flush;
  ZeroMemory(@Info, SizeOf(Info));
  Info.bmiHeader.biSize := SizeOf(TBitmapInfoHeader);
  Info.bmiHeader.biWidth := Width;
  Info.bmiHeader.biHeight := -Height;
  Info.bmiHeader.biPlanes := 1;
  Info.bmiHeader.biBitCount := 32;
  Info.bmiHeader.biCompression := BI_RGB;
  SetDIBitsToDevice(DC, 0, 0, Width, Height, 0, 0, 0, Height,
    @FChromePixels[0], Info, DIB_RGB_COLORS);
end;

procedure TDACTabs.WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
begin
  AMessage.Result := 1;
end;

procedure TDACTabs.WndProc(var Message: TMessage);
begin
  inherited;
  // Captions and page visibility can change without resizing the host.
  // Schedule after the native item transaction, never during insertion.
  case Message.Msg of
    TCM_INSERTITEM, TCM_SETITEM, TCM_DELETEITEM, TCM_DELETEALLITEMS, TCM_SETCURSEL:
      QueueContentLayout;
  end;
end;

procedure TDACTabs.LayoutPageContent;
begin
  if (Parent <> nil) and HandleAllocated and Parent.HandleAllocated and
    not (csLoading in ComponentState) then Realign;
end;

procedure TDACTabs.Loaded;
var
  LWasDesigning: Boolean;
  LPendingParent: TWinControl;
begin
  inherited;
  ApplyOrientation;
  SetActiveIndex(FActiveIndex);
  EnsureHeader;
  ApplyPageStyle;
  QueueContentLayout;
  { The application window is only a transactional native host for reading
    child pages. Do not leave a standalone component with an allocated HWND.
    WMDestroy stores the native tabs; assigning a real VCL Parent later
    recreates the window and restores them through the inherited path. }
  if FStreamingHostUsed then
  begin
    FStreamingHostUsed := False;
    if (Parent = nil) and HandleAllocated then
      DestroyWnd;
  end;
  { Restore the VCL hierarchy only after the transactional tab HWND is gone.
    SetParent itself does not need either window handle; a later Show/CreateWnd
    builds the normal WS_CHILD hierarchy under the real form. }
  LPendingParent := FPendingParent;
  FPendingParent := nil;
  if LPendingParent <> nil then
  begin
    { TControl.SetParent performs another runtime geometry adaptation and can
      request the Form handle. The reader has already materialized the saved
      geometry, so suppress that duplicate pass while restoring the deferred
      hierarchy. }
    LWasDesigning := csDesigning in ComponentState;
    if not LWasDesigning then
      SetDesigning(True, False);
    try
      inherited SetParent(LPendingParent);
    finally
      if not LWasDesigning then
        SetDesigning(False, False);
    end;
  end;
end;

procedure TDACTabs.QueueContentLayout;
begin
  if not ((Parent <> nil) and HandleAllocated and Parent.HandleAllocated and
    not (csLoading in ComponentState) and not (csDestroying in ComponentState)) then
    Exit;
  Inc(FContentLayoutRevision);
  PostMessage(Handle, WM_DAC_TABS_REFRESH_LAYOUT, FContentLayoutRevision, 0);
end;

procedure TDACTabs.Redraw;
begin
  InvalidateTabs;
end;

procedure TDACTabs.RefreshContentLayout;
begin
  // This is the synchronous commit path. Older resize/change messages must
  // not apply their coordinates after it has completed.
  Inc(FContentLayoutRevision);
  EnsureHeader;
  UpdateHeaderBounds;
  LayoutPageContent;
  InvalidateTabs;
end;

procedure TDACTabs.Resize;
begin
  inherited;
  UpdateHeaderBounds;
  QueueContentLayout;
  InvalidateTabs;
end;

function TDACTabs.Pixels(const AValue: Integer): Integer;
begin
  Result := AValue;
end;

function TDACTabs.SelectAdjacentEnabledPage(
  const AForward: Boolean): Boolean;
var
  I: Integer;
  LCandidate: Integer;
  LCurrent: Integer;
begin
  Result := False;
  if not Enabled or (PageCount = 0) then
    Exit;

  LCurrent := GetActiveIndex;
  if LCurrent < 0 then
  begin
    if AForward then
      LCurrent := -1
    else
      LCurrent := 0;
  end;
  LCandidate := LCurrent;
  for I := 1 to PageCount do
  begin
    if AForward then
      LCandidate := (LCandidate + 1) mod PageCount
    else
      LCandidate := (LCandidate + PageCount - 1) mod PageCount;
    if Pages[LCandidate].TabVisible and Pages[LCandidate].Enabled then
    begin
      if LCandidate <> LCurrent then
        SetActiveIndex(LCandidate);
      Exit(True);
    end;
  end;
end;

procedure TDACTabs.SetActiveIndex(const AValue: Integer);
var
  LChangeRevision: Cardinal;
  LPreviousActiveIndex: Integer;
  LRedrawDisabled: Boolean;
  LTargetPage: TTabSheet;
begin
  FActiveIndex := AValue;
  if PageCount > 0 then
    FActiveIndex := Max(-1, Min(AValue, PageCount - 1));
  if (Parent <> nil) and HandleAllocated and Parent.HandleAllocated then
  begin
    if PageCount = 0 then
      ActivePage := nil
    else
    begin
      LTargetPage := nil;
      if FActiveIndex >= 0 then
        LTargetPage := Pages[FActiveIndex];
      if ActivePage <> nil then
        LPreviousActiveIndex := ActivePage.PageIndex
      else
        LPreviousActiveIndex := -1;
      LChangeRevision := FChangeRevision;
      LRedrawDisabled := (LTargetPage <> nil) and
        LTargetPage.HandleAllocated and (ActivePage <> LTargetPage);
      if LRedrawDisabled then
        LTargetPage.Perform(WM_SETREDRAW, 0, 0);
      try
        ActivePage := LTargetPage;
        if ActivePage <> nil then
          FActiveIndex := ActivePage.PageIndex
        else
          FActiveIndex := -1;
        { Depending on the TPageControl path used by the current VCL version,
          assigning ActivePage programmatically may update the native selection
          without dispatching Change.  Header, sidebar and keyboard all reach
          this setter, so close that gap here while preserving the native
          notification when it was already emitted. }
        if (LPreviousActiveIndex <> FActiveIndex) and
          (LChangeRevision = FChangeRevision) then
          Change;
      finally
        if LRedrawDisabled then
        begin
          LTargetPage.Perform(WM_SETREDRAW, 1, 0);
          RedrawWindow(LTargetPage.Handle, nil, 0,
            RDW_INVALIDATE or RDW_ERASE or RDW_FRAME or RDW_ALLCHILDREN or
            RDW_ERASENOW or RDW_UPDATENOW);
        end;
      end;
    end;
  end;
end;

procedure TDACTabs.SetAppearance(const AValue: TDACTabAppearance);
begin
  if FAppearance = AValue then Exit;
  FAppearance := AValue;
  QueueContentLayout;
  InvalidateTabs;
end;

procedure TDACTabs.SetContentColor(const AValue: TAlphaColor);
var
  LValue: TAlphaColor;
begin
  LValue := TDACComponentColors.Normalize(AValue);
  if (FContentColor = LValue) and FCustomContentColor then
    Exit;
  FContentColor := LValue;
  FCustomContentColor := True;
  ApplyPageStyle;
end;

function TDACTabs.ResolvedTokens: TDACControlTokens;
begin
  Result := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls;
end;

function TDACTabs.ResolveSizeMetrics: TDACControlSizeTokens;
begin
  case FSize of
    mtsSmall:
      Result := ResolvedTokens.TabsSmall;
    mtsLarge:
      Result := ResolvedTokens.TabsLarge;
  else
    Result := ResolvedTokens.TabsMedium;
  end;
  if FTabHeightValue > 0 then
    Result.Height := Max(FTabHeightValue, Result.TextSize + 2 * Result.PaddingVertical);
end;

procedure TDACTabs.SetThemeMode(const AValue: TDACThemeMode);
begin
  if FThemeMode = AValue then Exit;
  FThemeMode := AValue;
  ThemeChanged(Self);
end;

procedure TDACTabs.ThemeChanged(Sender: TObject);
begin
  if (FThemeMode <> dtmInherit) and (Sender <> Self) then
    Exit;
  if not FCustomContentColor then
    FContentColor := ResolvedTokens.ContainerSuiteBackground;
  ApplyPageStyle;
end;

procedure TDACTabs.SetCornerRadius(const AValue: Integer);
begin
  if FCornerRadius = Max(0, AValue) then Exit;
  FCornerRadius := Max(0, AValue);
  QueueContentLayout;
  InvalidateTabs;
end;

procedure TDACTabs.SetHeaderTrailingReserve(const AValue: Integer);
begin
  if FHeaderTrailingReserve = Max(0, AValue) then
    Exit;
  FHeaderTrailingReserve := Max(0, AValue);
  QueueContentLayout;
  InvalidateTabs;
end;

procedure TDACTabs.SetOrientation(const AValue: TDACTabOrientation);
begin
  if FOrientation = AValue then
    Exit;
  FOrientation := AValue;
  ApplyOrientation;
  ApplyPageStyle;
end;

procedure TDACTabs.SetShowContentBorder(const AValue: Boolean);
begin
  if FShowContentBorder = AValue then Exit;
  FShowContentBorder := AValue;
  QueueContentLayout;
  InvalidateTabs;
end;

procedure TDACTabs.SetSize(const AValue: TDACTabSize);
begin
  if FSize = AValue then
    Exit;
  FSize := AValue;
  UpdateHeaderBounds;
  QueueContentLayout;
  InvalidateTabs;
end;

procedure TDACTabs.SetParent(AParent: TWinControl);
begin
  { TWinControl.HandleNeeded recursively materializes Parent.Handle before
    CreateParams runs. Keep a streamed TDACTabs detached while its TTabSheet
    collection uses the temporary popup HWND, otherwise merely inserting the
    first sheet creates the containing TForm before Show. }
  if (AParent <> nil) and
    ([csLoading, csReading] * ComponentState <> []) and
    not AParent.HandleAllocated then
  begin
    FPendingParent := AParent;
    Exit;
  end;
  FPendingParent := nil;
  inherited SetParent(AParent);
end;

procedure TDACTabs.SetTabHeightValue(const AValue: Smallint);
begin
  if AValue < 0 then
    raise EArgumentOutOfRangeException.Create('TabHeight must be non-negative.');
  { Store without touching the native tab setter: that setter forces HWND
    creation during standalone DFM reads. ResolveSizeMetrics applies the value
    to the visible header in both the designer and runtime. }
  FTabHeightValue := AValue;
  UpdateHeaderBounds;
  QueueContentLayout;
  InvalidateTabs;
end;

procedure TDACTabs.SetTabWidthValue(const AValue: Smallint);
begin
  if AValue < 0 then
    raise EArgumentOutOfRangeException.Create('TabWidth must be non-negative.');
  FTabWidthValue := AValue;
  UpdateHeaderBounds;
  QueueContentLayout;
  InvalidateTabs;
end;

procedure TDACTabs.UpdateHeaderBounds;
var
  I, Extent: Integer;
begin
  if FUpdatingHeader or (csLoading in ComponentState) or
    (csDestroying in ComponentState) or (Parent = nil) or
    not HandleAllocated or not Parent.HandleAllocated then Exit;
  FUpdatingHeader := True;
  try
    EnsureHeader;
    if FHeader = nil then Exit;
    if Orientation = mtoHorizontal then
      FHeader.SetBounds(0, 0, Width, FHeader.Height);
    Extent := HeaderExtent;
    if Orientation = mtoVertical then FHeader.SetBounds(0, 0, Extent, Height)
    else FHeader.SetBounds(0, 0, Width, Extent);
    FHeader.Visible := HeaderShouldBeVisible;
    if FHeader.Visible and Showing then
      TWinControlAccess(FHeader).UpdateControlState;
    for I := 0 to PageCount - 1 do
    begin
      Pages[I].Padding.Top := 0;
      Pages[I].Padding.Left := 0;
    end;
    Realign;
  finally
    FUpdatingHeader := False;
  end;
end;

procedure TDACTabs.WMTabsRefreshLayout(var AMessage: TMessage);
begin
  if (csDestroying in ComponentState) or not HandleAllocated then
    Exit;
  if Cardinal(AMessage.WParam) <> FContentLayoutRevision then
    Exit;
  EnsureHeader;
  UpdateHeaderBounds;
  LayoutPageContent;
  InvalidateTabs;
end;

end.
