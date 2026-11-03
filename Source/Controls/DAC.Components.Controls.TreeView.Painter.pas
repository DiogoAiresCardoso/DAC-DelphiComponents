unit DAC.Components.Controls.TreeView.Painter;

interface

uses
  System.Classes, System.Generics.Collections, System.Types, System.UITypes,
  System.Skia, Winapi.Windows, Vcl.Graphics,
  DAC.Components.Controls.TreeView.Model,
  DAC.Components.Controls.TreeView.Columns,
  DAC.Components.DesignSystem.ControlTokens,
  DAC.Components.DesignSystem.DBTreeTokens,
  DAC.Components.Skia.Renderer,
  DAC.Components.Skia.RasterSurface;

type
  TDACTreeHitKind = (thNone, thHeader, thRow, thExpander, thCheck,
    thVerticalTrack, thVerticalThumb, thHorizontalTrack, thHorizontalThumb);

  TDACTreeHit = record
    Kind: TDACTreeHitKind;
    NodeIndex, ColumnIndex, VisibleRow: Integer;
    Bounds: TRect;
  end;

  TDACTreeLayout = record
    ContentRect, HeaderRect: TRect;
    VerticalTrack, VerticalThumb, HorizontalTrack, HorizontalThumb: TRect;
    PageRows, MaxTopRow, MaxHorizontalOffset: Integer;
    TopRow, HorizontalOffset, TotalWidth: Integer;
  end;

  TDACTreeText = record
    Text: string;
    Bounds, Clip: TRect;
    Alignment: TAlignment;
    Color: TAlphaColor;
    Bold: Boolean;
  end;

  { Receives immutable cache values for a frame. This class never navigates
    or reads a dataset, and allocates no VCL control for a node. }
  TDACTreePainter = class
  private
    FShowHeader: Boolean;
    FShowCheckBoxes: Boolean;
    FRenderer: TDACSkiaRenderer;
    FSurface: TDACRasterSurface;
    FText: TList<TDACTreeText>;
    FNormalFont, FBoldFont: HFONT;
    FFontKey: string;
    FPaintedRows, FPaintCount: Integer;
    procedure EnsureFonts(ADpi: Integer; AFont: TFont);
    procedure DrawTextItems;
    procedure QueueText(const AText: string; const ABounds, AClip: TRect;
      AColor: TAlphaColor; AAlignment: TAlignment; ABold: Boolean = False);
    procedure GlyphRects(const ALayout: TDACTreeLayout;
      ANode: TDACTreeModelNode; AVisibleRow, ADpi: Integer;
      out AExpander, ACheck: TRect);
  public
    constructor Create;
    destructor Destroy; override;
    class function HeaderHeight(ADpi: Integer): Integer; static;
    class function RowHeight(ADpi: Integer): Integer; static;
    function Layout(AWidth, AHeight, ADpi: Integer; AModel: TDACTreeModelBase;
      AColumns: TDACTreeColumns; ATopRow: Integer = 0;
      AHorizontalOffset: Integer = 0): TDACTreeLayout;
    function HitTest(AX, AY, AWidth, AHeight, ADpi: Integer;
      AModel: TDACTreeModelBase; AColumns: TDACTreeColumns;
      ATopRow, AHorizontalOffset: Integer): TDACTreeHit;
    procedure Paint(ADC: HDC; AWidth, AHeight, ADpi: Integer;
      const ATokens: TDACControlTokens; AModel: TDACTreeModelBase;
      AColumns: TDACTreeColumns; const ASelectedToken: string;
      ATopRow, AHorizontalOffset, AHoverRow: Integer;
      AFocused, AEnabled, AReadOnly: Boolean; const AStatusText: string;
      AFont: TFont = nil);
    property ShowHeader: Boolean read FShowHeader write FShowHeader;
    property ShowCheckBoxes: Boolean read FShowCheckBoxes write FShowCheckBoxes;
    property PaintedRows: Integer read FPaintedRows;
    property PaintCount: Integer read FPaintCount;
  end;

implementation

uses
  System.Math, System.SysUtils,
  DAC.Components.DesignSystem.ColorTokens,
  DAC.Components.DesignSystem.Fonts;

function FloatRect(const R: TRect): TRectF;
begin
  Result := TRectF.Create(R.Left, R.Top, R.Right, R.Bottom);
end;

function TreeMetrics: TDACDBTreeTokens;
begin
  Result := TDACDBTreeTokens.Resolve(Default(TDACControlTokens));
end;

constructor TDACTreePainter.Create;
begin
  inherited Create;
  FShowHeader := True;
  FShowCheckBoxes := True;
  FRenderer := TDACSkiaRenderer.Create;
  FSurface := TDACRasterSurface.Create;
  FText := TList<TDACTreeText>.Create;
end;

destructor TDACTreePainter.Destroy;
begin
  if FNormalFont <> 0 then DeleteObject(FNormalFont);
  if FBoldFont <> 0 then DeleteObject(FBoldFont);
  FText.Free;
  FSurface.Free;
  FRenderer.Free;
  inherited;
end;

class function TDACTreePainter.HeaderHeight(ADpi: Integer): Integer;
begin
  Result := TDACDBTreeTokens.Pixels(TreeMetrics.HeaderHeight, ADpi);
end;

class function TDACTreePainter.RowHeight(ADpi: Integer): Integer;
begin
  Result := TDACDBTreeTokens.Pixels(TreeMetrics.RowHeight, ADpi);
end;

function TDACTreePainter.Layout(AWidth, AHeight, ADpi: Integer;
  AModel: TDACTreeModelBase; AColumns: TDACTreeColumns;
  ATopRow, AHorizontalOffset: Integer): TDACTreeLayout;
var
  I, LRows, LHeader, LRow, LBorder, LScroll, LWidth, LHeight: Integer;
  LTrackSize, LThumbSize, LMinimumThumb: Integer;
  LVertical, LHorizontal: Boolean;
  M: TDACDBTreeTokens;
begin
  Result := Default(TDACTreeLayout);
  M := TreeMetrics;
  LHeader := 0;
  if FShowHeader then LHeader := HeaderHeight(ADpi);
  LRow := RowHeight(ADpi);
  LBorder := TDACDBTreeTokens.Pixels(M.BorderWidth, ADpi);
  LScroll := TDACDBTreeTokens.Pixels(M.ScrollSize, ADpi);
  LMinimumThumb := TDACDBTreeTokens.Pixels(M.MinimumThumb, ADpi);
  LRows := 0;
  if AModel <> nil then LRows := AModel.Visible.Count;
  if AColumns <> nil then
    for I := 0 to AColumns.Count - 1 do
      Inc(Result.TotalWidth, TDACDBTreeTokens.Pixels(AColumns[I].Width, ADpi));
  LWidth := Max(0, AWidth - LBorder * 2);
  LHeight := Max(0, AHeight - LBorder * 2 - LHeader);
  LVertical := Int64(LRows) * LRow > LHeight;
  if LVertical then LWidth := Max(0, LWidth - LScroll);
  LHorizontal := Result.TotalWidth > LWidth;
  if LHorizontal then LHeight := Max(0, LHeight - LScroll);
  if not LVertical and (Int64(LRows) * LRow > LHeight) then
  begin
    LVertical := True;
    LWidth := Max(0, LWidth - LScroll);
  end;
  Result.HeaderRect := Rect(LBorder, LBorder, LBorder + LWidth,
    Min(Max(LBorder, AHeight - LBorder), LBorder + LHeader));
  Result.ContentRect := Rect(LBorder, Result.HeaderRect.Bottom,
    LBorder + LWidth, Result.HeaderRect.Bottom + LHeight);
  Result.PageRows := Max(1, LHeight div Max(1, LRow));
  Result.MaxTopRow := Max(0, LRows - Result.PageRows);
  Result.MaxHorizontalOffset := Max(0, Result.TotalWidth - LWidth);
  Result.TopRow := EnsureRange(ATopRow, 0, Result.MaxTopRow);
  Result.HorizontalOffset := EnsureRange(AHorizontalOffset, 0,
    Result.MaxHorizontalOffset);
  if LVertical then
  begin
    Result.VerticalTrack := Rect(Result.ContentRect.Right, LBorder,
      Result.ContentRect.Right + LScroll, Result.ContentRect.Bottom);
    LTrackSize := Max(0, Result.VerticalTrack.Height);
    LThumbSize := Min(LTrackSize, Max(LMinimumThumb,
      Integer(Int64(LTrackSize) * Min(LRows, Result.PageRows) div Max(1, LRows))));
    I := Integer(Int64(LTrackSize - LThumbSize) * Result.TopRow div
      Max(1, Result.MaxTopRow));
    Result.VerticalThumb := Rect(Result.VerticalTrack.Left,
      Result.VerticalTrack.Top + I, Result.VerticalTrack.Right,
      Result.VerticalTrack.Top + I + LThumbSize);
  end;
  if LHorizontal then
  begin
    Result.HorizontalTrack := Rect(LBorder, Result.ContentRect.Bottom,
      Result.ContentRect.Right, Result.ContentRect.Bottom + LScroll);
    LTrackSize := Max(0, Result.HorizontalTrack.Width);
    LThumbSize := Min(LTrackSize, Max(LMinimumThumb,
      Integer(Int64(LTrackSize) * LWidth div Max(1, Result.TotalWidth))));
    I := Integer(Int64(LTrackSize - LThumbSize) * Result.HorizontalOffset div
      Max(1, Result.MaxHorizontalOffset));
    Result.HorizontalThumb := Rect(Result.HorizontalTrack.Left + I,
      Result.HorizontalTrack.Top, Result.HorizontalTrack.Left + I + LThumbSize,
      Result.HorizontalTrack.Bottom);
  end;
end;

procedure TDACTreePainter.GlyphRects(const ALayout: TDACTreeLayout;
  ANode: TDACTreeModelNode; AVisibleRow, ADpi: Integer;
  out AExpander, ACheck: TRect);
var
  X, Y, LExpand, LCheck, LGap: Integer;
  M: TDACDBTreeTokens;
begin
  M := TreeMetrics;
  X := ALayout.ContentRect.Left - ALayout.HorizontalOffset +
    TDACDBTreeTokens.Pixels(M.CellPadding, ADpi) +
    TDACDBTreeTokens.Pixels(M.Indent, ADpi) * ANode.Depth;
  Y := ALayout.ContentRect.Top +
    (AVisibleRow - ALayout.TopRow) * RowHeight(ADpi);
  LExpand := TDACDBTreeTokens.Pixels(M.ExpanderSize, ADpi);
  LCheck := TDACDBTreeTokens.Pixels(M.CheckSize, ADpi);
  LGap := TDACDBTreeTokens.Pixels(M.GlyphGap, ADpi);
  AExpander := Rect(X, Y + (RowHeight(ADpi) - LExpand) div 2,
    X + LExpand, Y + (RowHeight(ADpi) + LExpand) div 2);
  X := AExpander.Right + LGap;
  ACheck := Rect(X, Y + (RowHeight(ADpi) - LCheck) div 2,
    X + LCheck, Y + (RowHeight(ADpi) + LCheck) div 2);
end;

function TDACTreePainter.HitTest(AX, AY, AWidth, AHeight, ADpi: Integer;
  AModel: TDACTreeModelBase; AColumns: TDACTreeColumns;
  ATopRow, AHorizontalOffset: Integer): TDACTreeHit;
var
  L: TDACTreeLayout;
  P: TPoint;
  I, X, W: Integer;
  LNode: TDACTreeModelNode;
  LExpand, LCheck, LCell, LClip: TRect;
begin
  Result := Default(TDACTreeHit);
  Result.NodeIndex := -1;
  Result.ColumnIndex := -1;
  Result.VisibleRow := -1;
  L := Layout(AWidth, AHeight, ADpi, AModel, AColumns, ATopRow, AHorizontalOffset);
  P := Point(AX, AY);
  if PtInRect(L.VerticalTrack, P) then
  begin
    Result.Kind := thVerticalTrack;
    Result.Bounds := L.VerticalTrack;
    if PtInRect(L.VerticalThumb, P) then
    begin
      Result.Kind := thVerticalThumb;
      Result.Bounds := L.VerticalThumb;
    end;
    Exit;
  end;
  if PtInRect(L.HorizontalTrack, P) then
  begin
    Result.Kind := thHorizontalTrack;
    Result.Bounds := L.HorizontalTrack;
    if PtInRect(L.HorizontalThumb, P) then
    begin
      Result.Kind := thHorizontalThumb;
      Result.Bounds := L.HorizontalThumb;
    end;
    Exit;
  end;
  if PtInRect(L.HeaderRect, P) then Result.Kind := thHeader
  else if PtInRect(L.ContentRect, P) and (AModel <> nil) then
  begin
    Result.VisibleRow := L.TopRow + (AY - L.ContentRect.Top) div RowHeight(ADpi);
    if Result.VisibleRow >= AModel.Visible.Count then Exit;
    Result.NodeIndex := AModel.Visible[Result.VisibleRow];
    Result.Kind := thRow;
  end
  else Exit;
  X := L.ContentRect.Left - L.HorizontalOffset;
  if AColumns <> nil then
    for I := 0 to AColumns.Count - 1 do
    begin
      W := TDACDBTreeTokens.Pixels(AColumns[I].Width, ADpi);
      if (AX >= X) and (AX < X + W) then
      begin
        Result.ColumnIndex := I;
        Result.Bounds := Rect(X, L.HeaderRect.Top, X + W, L.HeaderRect.Bottom);
        if Result.Kind = thRow then
        begin
          Result.Bounds.Top := L.ContentRect.Top +
            (Result.VisibleRow - L.TopRow) * RowHeight(ADpi);
          Result.Bounds.Bottom := Result.Bounds.Top + RowHeight(ADpi);
          if I = 0 then
          begin
            LNode := AModel.Node(Result.NodeIndex);
            GlyphRects(L, LNode, Result.VisibleRow, ADpi, LExpand, LCheck);
            LCell := Result.Bounds;
            IntersectRect(LClip, LCell, L.ContentRect);
            if PtInRect(LClip, P) then
            begin
              if (LNode.Children.Count > 0) and PtInRect(LExpand, P) then
              begin Result.Kind := thExpander; Result.Bounds := LExpand; end
              else if FShowCheckBoxes and LNode.Checkable and PtInRect(LCheck, P) then
              begin Result.Kind := thCheck; Result.Bounds := LCheck; end;
            end;
          end;
        end;
        Exit;
      end;
      Inc(X, W);
    end;
end;

procedure TDACTreePainter.QueueText(const AText: string;
  const ABounds, AClip: TRect; AColor: TAlphaColor;
  AAlignment: TAlignment; ABold: Boolean);
var
  Item: TDACTreeText;
begin
  if (AText = '') or (ABounds.Right <= ABounds.Left) or
    (AClip.Right <= AClip.Left) or (AClip.Bottom <= AClip.Top) then Exit;
  Item.Text := AText;
  Item.Bounds := ABounds;
  Item.Clip := AClip;
  Item.Color := AColor;
  Item.Alignment := AAlignment;
  Item.Bold := ABold;
  FText.Add(Item);
end;

procedure TDACTreePainter.EnsureFonts(ADpi: Integer; AFont: TFont);
var
  LName, LKey: string;
  LSize, LCharset, LWeight: Integer;
  LItalic, LUnderline, LStrikeOut: DWORD;
begin
  LName := TDACComponentFontInstaller.FontFamily;
  LSize := -MulDiv(TreeMetrics.FontSize, Max(96, ADpi), 72);
  LCharset := DEFAULT_CHARSET;
  LWeight := FW_NORMAL;
  LItalic := 0; LUnderline := 0; LStrikeOut := 0;
  if AFont <> nil then
  begin
    LName := AFont.Name;
    { VCL already scales Font.Height with its owner. In Delphi 10.2 it does
      not also change Font.PixelsPerInch, so multiplying Font.Size by ADpi
      would apply scaling twice. Respect the same native height as the host. }
    LSize := AFont.Height;
    LCharset := AFont.Charset;
    if fsBold in AFont.Style then LWeight := FW_BOLD;
    LItalic := Ord(fsItalic in AFont.Style);
    LUnderline := Ord(fsUnderline in AFont.Style);
    LStrikeOut := Ord(fsStrikeOut in AFont.Style);
  end;
  LKey := LName + '|' + IntToStr(LSize) + '|' + IntToStr(LCharset) + '|' +
    IntToStr(LWeight) + '|' + IntToStr(LItalic) + '|' +
    IntToStr(LUnderline) + '|' + IntToStr(LStrikeOut);
  if (LKey = FFontKey) and (FNormalFont <> 0) and (FBoldFont <> 0) then Exit;
  if FNormalFont <> 0 then DeleteObject(FNormalFont);
  if FBoldFont <> 0 then DeleteObject(FBoldFont);
  FNormalFont := CreateFont(LSize, 0, 0, 0, LWeight, LItalic, LUnderline,
    LStrikeOut, LCharset, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS,
    CLEARTYPE_QUALITY, DEFAULT_PITCH or FF_DONTCARE, PChar(LName));
  FBoldFont := CreateFont(LSize, 0, 0, 0, FW_BOLD, LItalic, LUnderline,
    LStrikeOut, LCharset, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS,
    CLEARTYPE_QUALITY, DEFAULT_PITCH or FF_DONTCARE, PChar(LName));
  FFontKey := LKey;
end;

procedure TDACTreePainter.DrawTextItems;
var
  DC: HDC;
  Saved: Integer;
  Item: TDACTreeText;
  Flags: Cardinal;
  R: TRect;
begin
  DC := FSurface.BeginNativeText;
  if DC = 0 then Exit;
  for Item in FText do
  begin
    Saved := SaveDC(DC);
    try
      IntersectClipRect(DC, Item.Clip.Left, Item.Clip.Top,
        Item.Clip.Right, Item.Clip.Bottom);
      if Item.Bold then SelectObject(DC, FBoldFont)
      else SelectObject(DC, FNormalFont);
      SetBkMode(DC, TRANSPARENT);
      SetTextColor(DC, TDACComponentColors.ToVclColor(Item.Color));
      Flags := DT_SINGLELINE or DT_VCENTER or DT_NOPREFIX or DT_END_ELLIPSIS;
      case Item.Alignment of
        taCenter: Flags := Flags or DT_CENTER;
        taRightJustify: Flags := Flags or DT_RIGHT;
      else
        Flags := Flags or DT_LEFT;
      end;
      R := Item.Bounds;
      DrawText(DC, PChar(Item.Text), Length(Item.Text), R, Flags);
    finally
      RestoreDC(DC, Saved);
    end;
  end;
end;

procedure TDACTreePainter.Paint(ADC: HDC; AWidth, AHeight, ADpi: Integer;
  const ATokens: TDACControlTokens; AModel: TDACTreeModelBase;
  AColumns: TDACTreeColumns; const ASelectedToken: string;
  ATopRow, AHorizontalOffset, AHoverRow: Integer;
  AFocused, AEnabled, AReadOnly: Boolean; const AStatusText: string; AFont: TFont);
var
  C: ISkCanvas;
  M: TDACDBTreeTokens;
  L: TDACTreeLayout;
  R, Cell, Clip, Expand, Check, TextRect: TRect;
  RF: TRectF;
  I, J, X, Y, W, Pad, Gap, LLast, LRowHeight, LInset: Integer;
  N: TDACTreeModelNode;
  TextColor, BoxColor: TAlphaColor;
  LSelected: Boolean;
  LCaption: string;
  CX, CY, Stroke: Single;
begin
  if (ADC = 0) or (AWidth <= 0) or (AHeight <= 0) then Exit;
  Inc(FPaintCount);
  FPaintedRows := 0;
  FText.Clear;
  M := TDACDBTreeTokens.Resolve(ATokens);
  FSurface.EnsureSize(AWidth, AHeight);
  EnsureFonts(ADpi, AFont);
  C := FSurface.Surface.Canvas;
  C.Clear(M.Background);
  L := Layout(AWidth, AHeight, ADpi, AModel, AColumns, ATopRow, AHorizontalOffset);
  Pad := TDACDBTreeTokens.Pixels(M.CellPadding, ADpi);
  Gap := TDACDBTreeTokens.Pixels(M.GlyphGap, ADpi);
  LInset := TDACDBTreeTokens.Pixels(M.BorderWidth, ADpi);
  LRowHeight := RowHeight(ADpi);
  Stroke := Max(1, ADpi / 96);
  if FShowHeader and not L.HeaderRect.IsEmpty then
  begin
    FRenderer.FillRoundRect(C, FloatRect(L.HeaderRect), M.Header, 0);
    C.Save;
    try
      C.ClipRect(FloatRect(L.HeaderRect));
      X := L.HeaderRect.Left - L.HorizontalOffset;
      if AColumns <> nil then
        for J := 0 to AColumns.Count - 1 do
        begin
          W := TDACDBTreeTokens.Pixels(AColumns[J].Width, ADpi);
          Cell := Rect(X, L.HeaderRect.Top, X + W, L.HeaderRect.Bottom);
          if IntersectRect(Clip, Cell, L.HeaderRect) then
          begin
            TextRect := Cell;
            Inc(TextRect.Left, Pad); Dec(TextRect.Right, Pad);
            LCaption := AColumns[J].DisplayCaption;
            QueueText(LCaption, TextRect, Clip,
              M.HeaderText, AColumns[J].Alignment, True);
            FRenderer.DrawLine(C, PointF(Cell.Right - 0.5, Cell.Top),
              PointF(Cell.Right - 0.5, Cell.Bottom), M.Border, Stroke);
          end;
          Inc(X, W);
        end;
    finally C.Restore; end;
    FRenderer.DrawLine(C, PointF(L.HeaderRect.Left, L.HeaderRect.Bottom - 0.5),
      PointF(L.HeaderRect.Right, L.HeaderRect.Bottom - 0.5), M.Border, Stroke);
  end;

  if (AStatusText <> '') or (AModel = nil) or (AModel.Visible.Count = 0) then
  begin
    TextRect := L.ContentRect;
    InflateRect(TextRect, -Pad, -Pad);
    QueueText(AStatusText, TextRect, L.ContentRect, M.DisabledText, taCenter);
  end
  else
  begin
    C.Save;
    try
      C.ClipRect(FloatRect(L.ContentRect));
      LLast := Min(AModel.Visible.Count - 1, L.TopRow + L.PageRows);
      for I := L.TopRow to LLast do
      begin
        Inc(FPaintedRows);
        N := AModel.Node(AModel.Visible[I]);
        Y := L.ContentRect.Top + (I - L.TopRow) * LRowHeight;
        R := Rect(L.ContentRect.Left, Y, L.ContentRect.Right, Y + LRowHeight);
        LSelected := N.Token = ASelectedToken;
        if N.Checked then
          FRenderer.FillRoundRect(C, FloatRect(R), M.Accent, 0, M.MarkAlpha);
        if I = AHoverRow then
          FRenderer.FillRoundRect(C, FloatRect(R), M.Hover, 0);
        if LSelected then
        begin
          FRenderer.FillRoundRect(C, FloatRect(R), M.Accent, 0, M.SelectionAlpha);
          RF := FloatRect(R);
          RF.Inflate(-Stroke, -Stroke);
          if AFocused then
            FRenderer.StrokeRoundRect(C, RF, M.Accent, 0,
              TDACDBTreeTokens.Pixels(M.FocusWidth, ADpi))
          else FRenderer.StrokeRoundRect(C, RF, M.Border, 0, Stroke);
        end;
        TextColor := M.Text;
        if not AEnabled then TextColor := M.DisabledText;
        X := L.ContentRect.Left - L.HorizontalOffset;
        if AColumns <> nil then
          for J := 0 to AColumns.Count - 1 do
          begin
            W := TDACDBTreeTokens.Pixels(AColumns[J].Width, ADpi);
            Cell := Rect(X, Y, X + W, Y + LRowHeight);
            if IntersectRect(Clip, Cell, L.ContentRect) then
            begin
              TextRect := Cell;
              Inc(TextRect.Left, Pad); Dec(TextRect.Right, Pad);
              if J = 0 then
              begin
                GlyphRects(L, N, I, ADpi, Expand, Check);
                C.Save;
                try
                  C.ClipRect(FloatRect(Clip));
                  if N.Children.Count > 0 then
                  begin
                    CX := (Expand.Left + Expand.Right) / 2;
                    CY := (Expand.Top + Expand.Bottom) / 2;
                    W := Max(2, Expand.Width div 5);
                    if N.EffectiveExpanded then
                    begin
                      FRenderer.DrawLine(C, PointF(CX - W, CY - W / 2),
                        PointF(CX, CY + W / 2), TextColor, Stroke);
                      FRenderer.DrawLine(C, PointF(CX, CY + W / 2),
                        PointF(CX + W, CY - W / 2), TextColor, Stroke);
                    end
                    else
                    begin
                      FRenderer.DrawLine(C, PointF(CX - W / 2, CY - W),
                        PointF(CX + W / 2, CY), TextColor, Stroke);
                      FRenderer.DrawLine(C, PointF(CX + W / 2, CY),
                        PointF(CX - W / 2, CY + W), TextColor, Stroke);
                    end;
                  end;
                  if FShowCheckBoxes and N.Checkable then
                  begin
                    BoxColor := M.Border;
                    if AEnabled and not AReadOnly then BoxColor := M.Accent;
                    RF := FloatRect(Check);
                    if N.Checked then
                      FRenderer.FillRoundRect(C, RF, M.CheckedFill,
                        TDACDBTreeTokens.Pixels(M.CheckRadius, ADpi));
                    FRenderer.StrokeRoundRect(C, RF, BoxColor,
                      TDACDBTreeTokens.Pixels(M.CheckRadius, ADpi), Stroke);
                    if N.Checked then
                    begin
                      FRenderer.DrawLine(C, PointF(RF.Left + RF.Width * 0.2,
                        RF.Top + RF.Height * 0.5), PointF(RF.Left + RF.Width * 0.42,
                        RF.Top + RF.Height * 0.72), M.CheckedText, 2 * Stroke);
                      FRenderer.DrawLine(C, PointF(RF.Left + RF.Width * 0.42,
                        RF.Top + RF.Height * 0.72), PointF(RF.Left + RF.Width * 0.8,
                        RF.Top + RF.Height * 0.25), M.CheckedText, 2 * Stroke);
                    end;
                  end;
                finally C.Restore; end;
                if FShowCheckBoxes then TextRect.Left := Check.Right + Gap
                else TextRect.Left := Expand.Right + Gap;
              end;
              if J < Length(N.Cells) then
                QueueText(N.Cells[J], TextRect, Clip, TextColor,
                  AColumns[J].Alignment);
              W := TDACDBTreeTokens.Pixels(AColumns[J].Width, ADpi);
            end;
            Inc(X, W);
          end;
        FRenderer.DrawLine(C, PointF(R.Left, R.Bottom - 0.5),
          PointF(R.Right, R.Bottom - 0.5), M.Border, Stroke);
      end;
    finally C.Restore; end;
  end;
  if not IsRectEmpty(L.VerticalTrack) then
  begin
    FRenderer.FillRoundRect(C, FloatRect(L.VerticalTrack), M.Track, 0);
    RF := FloatRect(L.VerticalThumb);
    RF.Inflate(-TDACDBTreeTokens.Pixels(M.ThumbInset, ADpi),
      -TDACDBTreeTokens.Pixels(M.ThumbInset, ADpi));
    FRenderer.FillRoundRect(C, RF, M.Thumb,
      TDACDBTreeTokens.Pixels(M.ThumbRadius, ADpi));
  end;
  if not IsRectEmpty(L.HorizontalTrack) then
  begin
    FRenderer.FillRoundRect(C, FloatRect(L.HorizontalTrack), M.Track, 0);
    RF := FloatRect(L.HorizontalThumb);
    RF.Inflate(-TDACDBTreeTokens.Pixels(M.ThumbInset, ADpi),
      -TDACDBTreeTokens.Pixels(M.ThumbInset, ADpi));
    FRenderer.FillRoundRect(C, RF, M.Thumb,
      TDACDBTreeTokens.Pixels(M.ThumbRadius, ADpi));
  end;
  FRenderer.StrokeRoundRect(C, TRectF.Create(LInset / 2, LInset / 2,
    AWidth - LInset / 2, AHeight - LInset / 2), M.Border, 0, LInset);
  DrawTextItems;
  FSurface.Present(ADC);
end;

end.
