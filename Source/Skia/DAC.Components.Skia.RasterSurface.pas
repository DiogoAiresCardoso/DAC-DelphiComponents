unit DAC.Components.Skia.RasterSurface;

interface

uses
  System.Skia,
  Winapi.Windows;

type
  { One opaque frame: Skia and native text share a top-down DIB, and the
    composed buffer reaches the HWND in one transfer. No visual policy. }
  TDACRasterSurface = class
  private
    FDC: HDC;
    FBitmap: HBITMAP;
    FOldBitmap: HGDIOBJ;
    FSurface: ISkSurface;
    FWidth, FHeight: Integer;
    procedure Release;
  public
    destructor Destroy; override;
    procedure EnsureSize(AWidth, AHeight: Integer);
    function BeginNativeText: HDC;
    procedure Present(const ADC: HDC);
    property Surface: ISkSurface read FSurface;
    property Width: Integer read FWidth;
    property Height: Integer read FHeight;
  end;

implementation

uses
  System.Math,
  System.SysUtils;

procedure TDACRasterSurface.Release;
begin
  FSurface := nil;
  if FDC <> 0 then
  begin
    GdiFlush;
    if (FOldBitmap <> 0) and (FOldBitmap <> HGDI_ERROR) then
      SelectObject(FDC, FOldBitmap);
  end;
  FOldBitmap := 0;
  if FBitmap <> 0 then DeleteObject(FBitmap);
  FBitmap := 0;
  if FDC <> 0 then DeleteDC(FDC);
  FDC := 0;
  FWidth := 0;
  FHeight := 0;
end;

destructor TDACRasterSurface.Destroy;
begin
  Release;
  inherited;
end;

procedure TDACRasterSurface.EnsureSize(AWidth, AHeight: Integer);
var
  LInfo: TBitmapInfo;
  LPixels: Pointer;
begin
  AWidth := Max(1, AWidth);
  AHeight := Max(1, AHeight);
  if (FSurface <> nil) and (FWidth = AWidth) and (FHeight = AHeight) then Exit;
  Release;
  try
    FDC := CreateCompatibleDC(0);
    if FDC = 0 then RaiseLastOSError;
    ZeroMemory(@LInfo, SizeOf(LInfo));
    LInfo.bmiHeader.biSize := SizeOf(TBitmapInfoHeader);
    LInfo.bmiHeader.biWidth := AWidth;
    LInfo.bmiHeader.biHeight := -AHeight;
    LInfo.bmiHeader.biPlanes := 1;
    LInfo.bmiHeader.biBitCount := 32;
    LInfo.bmiHeader.biCompression := BI_RGB;
    LPixels := nil;
    FBitmap := CreateDIBSection(FDC, LInfo, DIB_RGB_COLORS, LPixels, 0, 0);
    if (FBitmap = 0) or (LPixels = nil) then
      raise EOutOfMemory.Create('DAC: raster buffer could not be allocated.');
    FOldBitmap := SelectObject(FDC, FBitmap);
    if (FOldBitmap = 0) or (FOldBitmap = HGDI_ERROR) then RaiseLastOSError;
    FSurface := TSkSurface.MakeRasterDirect(TSkImageInfo.Create(AWidth, AHeight),
      LPixels, NativeUInt(AWidth) * SizeOf(Cardinal));
    if FSurface = nil then
      raise EOutOfMemory.Create('DAC: Skia surface could not be allocated.');
    FWidth := AWidth;
    FHeight := AHeight;
  except
    Release;
    raise;
  end;
end;

function TDACRasterSurface.BeginNativeText: HDC;
begin
  Result := 0;
  if FSurface = nil then Exit;
  FSurface.Flush;
  Result := FDC;
end;

procedure TDACRasterSurface.Present(const ADC: HDC);
begin
  if (ADC = 0) or (FSurface = nil) then Exit;
  FSurface.Flush;
  GdiFlush;
  BitBlt(ADC, 0, 0, FWidth, FHeight, FDC, 0, 0, SRCCOPY);
  GdiFlush;
end;

end.
