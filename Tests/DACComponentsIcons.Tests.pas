unit DACComponentsIcons.Tests;

interface

type
  TDACComponentsIconTests = class sealed
  public
    class procedure Run; static;
  end;

implementation

uses
  System.Classes, System.SysUtils, System.Types, System.UITypes,
  System.IOUtils, System.TypInfo, System.Skia, Winapi.Windows,
  Vcl.Forms, Vcl.Controls, Vcl.Graphics, Vcl.Skia, Vcl.Imaging.pngimage,
  DAC.Components.Controls.Register,
  DAC.Components.Controls.Button, DAC.Components.Controls.ButtonEdit,
  DAC.Components.Controls.Badges, DAC.Components.Controls.SummaryCard,
  DAC.Components.Controls.DBGrid, DAC.Components.Controls.DBGrid.Action,
  DAC.Components.DesignSystem.IconAssets, DAC.Components.DesignSystem.Theme,
  DAC.Components.DesignSystem.DefaultTheme,
  DAC.Components.Skia.IconPainter, DAC.Components.Skia.Renderer;

procedure Require(const Condition: Boolean; const Message: string);
begin
  if not Condition then raise Exception.Create(Message);
end;

class procedure TDACComponentsIconTests.Run;
const Colors: array[0..2] of TAlphaColor = ($FF3DB82A, $FFFFFFFF, $FFD94A3A);
  TileWidth = 128; TileHeight = 112; Columns = 7;
var Kind: TDACIconKind; Info: TDACIconInfo; Style, Expected: TDACIconStyle;
  Renderer: TDACSkiaRenderer; Painter: TDACSkiaIconPainter;
  Surface, Sheet: ISkSurface; Pixels, SheetPixels: TArray<Cardinal>;
  Paths: TStringList; Source, EnumName, OutputDir, OldDirectory: string;
  I, J, Ink, PeakAlpha, NewCount, SheetWidth, SheetHeight, Index: Integer;
  Bitmap: TBitmap; PNG: TPngImage; BitmapInfo: TBitmapInfo; R: TRect;
  Host: TForm; Button, Copy: TDACButton; Stream: TMemoryStream;
  Badge: TDACBadge; Card: TDACSummaryCard; Edit: TDACButtonEdit;
  Grid: TDACDBGrid; Action: TDACDBGridAction;
  Theme: IDACComponentsTheme; RegisteredPaintBox: Boolean;
begin
  Require((Ord(mikNone) = 0) and (Ord(mikCheck) = 1) and
    (Ord(mikTrash) = 23) and (Ord(mikZoomOut) = 106), 'Old icon ordinals changed.');
  Require(Ord(High(TDACIconKind)) = 169, 'Expected 169 SVGs plus mikNone.');
  Require(TDACIconAssets.SvgSource(mikNone, Colors[0]) = '', 'mikNone must remain empty.');
  Paths := TStringList.Create; Renderer := TDACSkiaRenderer.Create;
  Painter := TDACSkiaIconPainter.Create(Renderer);
  Host := TForm.CreateNew(nil); Stream := TMemoryStream.Create;
  Button := nil; Copy := nil; Bitmap := nil; PNG := nil;
  OldDirectory := GetCurrentDir;
  RegisteredPaintBox := GetClass('TSkPaintBox') = nil;
  if RegisteredPaintBox then System.Classes.RegisterClass(TSkPaintBox);
  try
    // Runtime SVGs must work without an assets directory in the working path.
    SetCurrentDir(TPath.GetTempPath);
    Paths.Sorted := True; Paths.Duplicates := dupError;
    SetLength(Pixels, 120 * 120);
    Surface := TSkSurface.MakeRasterDirect(TSkImageInfo.Create(120, 120), @Pixels[0], 120 * 4);
    Require(Surface <> nil, 'Cannot create raster surface.');
    Button := TDACButton.Create(nil); Button.Parent := Host; Button.ShowIcon := True;
    for Kind := Succ(Low(TDACIconKind)) to High(TDACIconKind) do
    begin
      Info := TDACIconAssets.Info(Kind);
      Require((Info.Category <> '') and (Info.Name <> '') and
        (Info.DisplayName <> '') and (Info.RelativeFileName <> ''), 'Incomplete icon metadata.');
      Paths.Add(Info.RelativeFileName);
      EnumName := GetEnumName(TypeInfo(TDACIconKind), Ord(Kind));
      Require(GetEnumValue(TypeInfo(TDACIconKind), EnumName) = Ord(Kind), 'Enum RTTI roundtrip failed.');
      for I := Low(Colors) to High(Colors) do
      begin
        Style.Color := Colors[I];
        if I = 2 then Style.Alpha := 128 else Style.Alpha := 255;
        Source := TDACIconAssets.SvgSource(Kind, Style.Color, Style.Alpha);
        Require((Source <> '') and (Pos('currentColor', Source) = 0), 'Unresolved SVG: ' + EnumName);
        Surface.Canvas.Clear(0);
        Painter.Draw(Surface.Canvas, RectF(0,0,120,120), Kind, Style);
        Surface.Flush;
        Ink := 0; PeakAlpha := 0;
        for J := 0 to High(Pixels) do
          if Pixels[J] shr 24 <> 0 then
          begin Inc(Ink); if Integer(Pixels[J] shr 24) > PeakAlpha then PeakAlpha := Pixels[J] shr 24; end;
        Require(Ink > 0, 'SVG rendered no pixels: ' + EnumName);
        if I = 2 then Require(PeakAlpha <= 129, 'SVG ignored opacity: ' + EnumName);
      end;
      // Actual VCL binary streaming exercises the enum property loader.
      Button.IconKind := Kind; Stream.Clear; Stream.WriteComponent(Button); Stream.Position := 0;
      Copy := TDACButton.Create(nil);
      try
        Copy.Parent := Host; Stream.ReadComponent(Copy);
        Require(Copy.IconKind = Kind, 'DFM streaming failed: ' + EnumName);
      finally FreeAndNil(Copy); end;
    end;
    Require(Paths.Count = 169, 'Duplicate or missing asset paths.');
    Require((TDACIconAssets.Info(mikFilePdf).Category = 'report-viewer') and
      (TDACIconAssets.Info(mikFilesPdf).Category = 'files') and
      (TDACIconAssets.Info(mikPackage).Category = 'data') and
      (TDACIconAssets.Info(mikSystemPackage).Category = 'system'), 'Name collisions changed old icons.');

    Badge := TDACBadge.Create(Host); Badge.Parent := Host;
    Card := TDACSummaryCard.Create(Host); Card.Parent := Host;
    Edit := TDACButtonEdit.Create(Host); Edit.Parent := Host;
    Grid := TDACDBGrid.Create(Host); Grid.Parent := Host;
    Action := Grid.Columns.Add.Actions.Add;
    SetEnumProp(Badge, 'IconKind', 'mikFolderOpen');
    SetEnumProp(Card, 'IconKind', 'mikDatabase');
    SetEnumProp(Edit, 'ButtonIconKind', 'mikFileJson');
    SetEnumProp(Action, 'IconKind', 'mikSystemPackage');
    Require((Badge.IconKind = mikFolderOpen) and (Card.IconKind = mikDatabase) and
      (Edit.ButtonIconKind = mikFileJson) and (Action.IconKind = mikSystemPackage),
      'New icons unavailable through published component properties.');
    Theme := TDACDefaultComponentsTheme.NewForMode(dtmLight);
    Style := TDACIconStyle.Semantic(Theme, mikFileWarning);
    Expected := TDACIconStyle.Semantic(Theme, mikWarning);
    Require(Style.Color = Expected.Color, 'File warning lost warning semantics.');
    Style := TDACIconStyle.Semantic(Theme, mikFileCheck);
    Expected := TDACIconStyle.Semantic(Theme, mikCheck);
    Require(Style.Color = Expected.Color, 'File check lost success semantics.');

    // Export the 63 additions through the same painter used by the components.
    NewCount := Ord(High(TDACIconKind)) - Ord(mikZoomOut);
    SheetWidth := Columns * TileWidth;
    SheetHeight := ((NewCount + Columns - 1) div Columns) * TileHeight;
    SetLength(SheetPixels, SheetWidth * SheetHeight);
    Sheet := TSkSurface.MakeRasterDirect(TSkImageInfo.Create(SheetWidth, SheetHeight),
      @SheetPixels[0], SheetWidth * 4);
    Require(Sheet <> nil, 'Cannot create contact sheet.');
    Sheet.Canvas.Clear($FFF5F8F5); Style.Color := Colors[0]; Style.Alpha := 255;
    for Kind := Succ(mikZoomOut) to High(TDACIconKind) do
    begin
      Index := Ord(Kind) - Ord(mikZoomOut) - 1;
      Painter.Draw(Sheet.Canvas, RectF((Index mod Columns) * TileWidth + 36,
        (Index div Columns) * TileHeight + 10, (Index mod Columns) * TileWidth + 92,
        (Index div Columns) * TileHeight + 66), Kind, Style);
    end;
    Sheet.Flush;
    Bitmap := TBitmap.Create; PNG := TPngImage.Create;
    Bitmap.PixelFormat := pf32bit; Bitmap.SetSize(SheetWidth, SheetHeight);
    FillChar(BitmapInfo, SizeOf(BitmapInfo), 0);
    BitmapInfo.bmiHeader.biSize := SizeOf(BitmapInfo.bmiHeader);
    BitmapInfo.bmiHeader.biWidth := SheetWidth; BitmapInfo.bmiHeader.biHeight := -SheetHeight;
    BitmapInfo.bmiHeader.biPlanes := 1; BitmapInfo.bmiHeader.biBitCount := 32;
    BitmapInfo.bmiHeader.biCompression := BI_RGB;
    SetDIBitsToDevice(Bitmap.Canvas.Handle,0,0,SheetWidth,SheetHeight,0,0,0,SheetHeight,
      @SheetPixels[0],BitmapInfo,DIB_RGB_COLORS);
    Bitmap.Canvas.Font.Name := 'Segoe UI'; Bitmap.Canvas.Font.Size := 8;
    Bitmap.Canvas.Font.Color := $00301810; SetBkMode(Bitmap.Canvas.Handle, TRANSPARENT);
    for Kind := Succ(mikZoomOut) to High(TDACIconKind) do
    begin
      Index := Ord(Kind) - Ord(mikZoomOut) - 1;
      R := Rect((Index mod Columns)*TileWidth+2, (Index div Columns)*TileHeight+78,
        (Index mod Columns+1)*TileWidth-2, (Index div Columns+1)*TileHeight-4);
      EnumName := GetEnumName(TypeInfo(TDACIconKind), Ord(Kind));
      DrawText(Bitmap.Canvas.Handle,PChar(EnumName),Length(EnumName),R,
        DT_SINGLELINE or DT_CENTER or DT_VCENTER or DT_NOPREFIX);
    end;
    OutputDir := GetEnvironmentVariable('DAC_ICON_TEST_OUTPUT_DIR');
    if OutputDir = '' then OutputDir := TPath.Combine(TPath.GetTempPath, 'dac-icons');
    ForceDirectories(OutputDir); PNG.Assign(Bitmap);
    PNG.SaveToFile(TPath.Combine(OutputDir, 'expanded-icons.png'));
    Writeln('Icons: 169 SVGs x 3 styles rendered; 169 DFM roundtrips; published consumers: PASS');
  finally
    SetCurrentDir(OldDirectory);
    PNG.Free; Bitmap.Free; Copy.Free; Button.Free; Stream.Free; Host.Free;
    Sheet := nil; Surface := nil; Painter.Free; Renderer.Free; Paths.Free;
    if RegisteredPaintBox then System.Classes.UnRegisterClass(TSkPaintBox);
  end;
end;

end.
