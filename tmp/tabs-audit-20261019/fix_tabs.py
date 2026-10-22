from pathlib import Path

root = Path(r'M:\Delphi Componentes\DAC-DelphiComponents')
p = root / 'Source/Controls/DAC.Components.Controls.Tabs.pas'
s = p.read_bytes().decode('utf-8-sig').replace('\r\n', '\n')

def replace(a, b):
    global s
    assert a in s, a[:100]
    s = s.replace(a, b, 1)

def method(start, end, body):
    global s
    a, b = s.index(start), s.index(end, s.index(start) + len(start))
    s = s[:a] + body.strip() + '\n\n' + s[b:]

replace('FTextOverlay: TDACSystemTextOverlay;', 'FTextOverlay: TGraphicControl;\n    FMeasureBitmap: TBitmap;\n    FScrollOffset: Integer;\n    procedure DrawNativeText(const ACanvas: TCanvas);\n    procedure SetTextFont(const ACanvas: TCanvas; const ABold: Boolean);\n    function CaptionSize(const AText: string; const AWidth: Integer): TSize;')
replace('procedure CMMouseLeave(var AMessage: TMessage); message CM_MOUSELEAVE;', 'procedure CMMouseLeave(var AMessage: TMessage); message CM_MOUSELEAVE;\n    procedure CMDesignHitTest(var AMessage: TCMDesignHitTest); message CM_DESIGNHITTEST;\n    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;\n      MousePos: TPoint): Boolean; override;')
replace('    FPageContentBounds: TDictionary<TControl, TRect>;\n', '')
replace('    FStreamingHostUsed: Boolean;', '    FStreamingHostUsed: Boolean;\n    FUpdatingHeader: Boolean;\n    FChromePixels: TArray<Cardinal>;\n    FChromeSurface: ISkSurface;\n    FChromeWidth, FChromeHeight: Integer;\n    FChromeRenderer: TDACSkiaRenderer;\n    function ContentFrameRect: TRect;')
replace('    procedure Change; override;', '    procedure AdjustClientRect(var Rect: TRect); override;\n    procedure PaintWindow(DC: HDC); override;\n    procedure WMEraseBkgnd(var AMessage: TWMEraseBkgnd); message WM_ERASEBKGND;\n    procedure WndProc(var Message: TMessage); override;\n    procedure Change; override;')
replace('  // A TSkPaintBox is a TGraphicControl.', '  // A TSkPaintBox is a TGraphicControl.') # retain historical comment for now
replace('  TWinControlAccess = class(TWinControl)\n  end;', '''  TWinControlAccess = class(TWinControl)
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
end;''')
replace('  ControlStyle := ControlStyle + [csOpaque];', '  ControlStyle := ControlStyle + [csOpaque, csDesignInteractive];')
replace('  FRenderer := TDACSkiaRenderer.Create;', '  FRenderer := TDACSkiaRenderer.Create;\n  FMeasureBitmap := TBitmap.Create;')
replace('  FTextOverlay := TDACSystemTextOverlay.Create(Self);', '  FTextOverlay := TDACTabTextOverlay.CreateForHeader(Self);')
replace('  FTextOverlay.Free;\n  FRenderer.Free;', '  FTextOverlay.Free;\n  FMeasureBitmap.Free;\n  FRenderer.Free;')

method('function TDACTabHeaderControl.BuildTabLayout:', 'procedure TDACTabHeaderControl.PaintBoxDraw', '''
procedure TDACTabHeaderControl.SetTextFont(const ACanvas: TCanvas;
  const ABold: Boolean);
begin
  ACanvas.Font.Name := TDACComponentStyle.FontFamily;
  ACanvas.Font.Height := -Round(FTabs.ResolveSizeMetrics.TextSize);
  if ABold then ACanvas.Font.Style := [fsBold]
  else ACanvas.Font.Style := [];
end;

function TDACTabHeaderControl.CaptionSize(const AText: string;
  const AWidth: Integer): TSize;
var
  R: TRect;
begin
  // Reserve the bold selection font for every page. Measurement and drawing
  // share Windows font metrics; Skia glyph widths cannot size native text.
  SetTextFont(FMeasureBitmap.Canvas, True);
  if AWidth <= 0 then
    Result := FMeasureBitmap.Canvas.TextExtent(AText)
  else
  begin
    R := Rect(0, 0, Max(1, AWidth), 0);
    DrawText(FMeasureBitmap.Canvas.Handle, PChar(AText), Length(AText), R,
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
      DrawText(ACanvas.Handle, PChar(Page.Caption), Length(Page.Caption),
        Measured, Flags or DT_CALCRECT);
      Inc(R.Top, Max(0, (R.Height - Measured.Height) div 2));
      DrawText(ACanvas.Handle, PChar(Page.Caption), Length(Page.Caption), R, Flags);
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
''')

replace('  LTextColor: TAlphaColor;\n  LTextRect: TRectF;\n', '')
replace('  FRenderer.BeginNativeText(FTextOverlay);\n  try\n\n', '')
a=s.index('    LTextColor := ResolvedTextColorForPage(')
b=s.index('    if LEnabled and LActive and LFocused then', a)
s=s[:a]+s[b:]
replace('  finally\n    FRenderer.EndNativeText;\n  end;\nend;\n\nprocedure TDACTabHeaderControl.PaintBoxMouseDown', '  FTextOverlay.Invalidate;\nend;\n\nprocedure TDACTabHeaderControl.PaintBoxMouseDown')
method('procedure TDACTabHeaderControl.Redraw;', 'function TDACTabHeaderControl.TabAt', '''
procedure TDACTabHeaderControl.Redraw;
begin
  if (FTabs = nil) or (csDestroying in ComponentState) then Exit;
  FPaintBox.Invalidate;
  FTextOverlay.Invalidate;
end;
''')
replace('  FPageContentBounds := TDictionary<TControl, TRect>.Create;', '  FChromeRenderer := TDACSkiaRenderer.Create;')
replace('  FPageContentBounds.Free;', '  FChromeSurface := nil;\n  FChromeRenderer.Free;')
replace('  // A TPageControl paints its native page window above children that share\n  // its client area.  Keep the Skia header as a sibling so it stays visible\n  // over the native page chrome instead of becoming an empty 1px tab strip.\n  FHeader.Parent := Parent;', '  // The HWND header is a child of this component, never a designer sibling.\n  // AdjustClientRect reserves its area before the native pages are aligned.\n  FHeader.Parent := Self;')
replace('(csDestroying in ComponentState) or (csDesigning in ComponentState) or\n    (Parent = nil) or not HandleAllocated or not Parent.HandleAllocated then\n    Exit;\n  FHeader :=', '(csDestroying in ComponentState) or\n    (Parent = nil) or not HandleAllocated or not Parent.HandleAllocated then\n    Exit;\n  FHeader :=')

method('function TDACTabs.HeaderExtent:', 'function TDACTabs.HeaderShouldBeVisible', '''
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
''')
replace('  Result := Visible and Showing and not (csDestroying in ComponentState);', '  Result := Visible and (Showing or (csDesigning in ComponentState)) and\n    not (csDestroying in ComponentState);')
method('procedure TDACTabs.InvalidateTabs;', 'procedure TDACTabs.Loaded;', '''
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
    TCM_INSERTITEM, TCM_SETITEM, TCM_DELETEITEM, TCM_DELETEALLITEMS:
      QueueContentLayout;
  end;
end;

procedure TDACTabs.LayoutPageContent;
begin
  if (Parent <> nil) and HandleAllocated and Parent.HandleAllocated and
    not (csLoading in ComponentState) then Realign;
end;
''')
replace('not (csLoading in ComponentState) and not (csDestroying in ComponentState) and\n    not (csDesigning in ComponentState))', 'not (csLoading in ComponentState) and not (csDestroying in ComponentState))')
replace('    Result := ResolvedTokens.TabsMedium;\n  end;\nend;', '    Result := ResolvedTokens.TabsMedium;\n  end;\n  if FTabHeightValue > 0 then\n    Result.Height := Max(FTabHeightValue, Result.TextSize + 2 * Result.PaddingVertical);\nend;')
replace('  FTabHeightValue := AValue;\nend;', '  FTabHeightValue := AValue;\n  UpdateHeaderBounds;\n  QueueContentLayout;\n  InvalidateTabs;\nend;')
replace('  FTabWidthValue := AValue;\nend;', '  FTabWidthValue := AValue;\n  UpdateHeaderBounds;\n  QueueContentLayout;\n  InvalidateTabs;\nend;')
method('procedure TDACTabs.UpdateHeaderBounds;', 'procedure TDACTabs.WMTabsRefreshLayout', '''
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
''')
# A radius/border change also changes the usable page client rectangle.
replace('  FCornerRadius := Max(0, AValue);\n  InvalidateTabs;', '  FCornerRadius := Max(0, AValue);\n  QueueContentLayout;\n  InvalidateTabs;')
replace('  FShowContentBorder := AValue;\n  InvalidateTabs;', '  FShowContentBorder := AValue;\n  QueueContentLayout;\n  InvalidateTabs;')
replace('  FAppearance := AValue;\n  InvalidateTabs;', '  FAppearance := AValue;\n  QueueContentLayout;\n  InvalidateTabs;')
replace('  FHeaderTrailingReserve := Max(0, AValue);\n  InvalidateTabs;', '  FHeaderTrailingReserve := Max(0, AValue);\n  QueueContentLayout;\n  InvalidateTabs;')
p.write_bytes(s.replace('\n', '\r\n').encode('utf-8'))

