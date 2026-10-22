unit DAC.Components.Controls.DBGrid.SurfaceBuffer;

interface

uses
  System.Skia,
  Winapi.Windows;

type
  TDACDBGridSurfaceBuffer = class
  private
    FBitmap: HBITMAP;
    FHeight: Integer;
    FMemoryDC: HDC;
    FOldBitmap: HGDIOBJ;
    FSurface: ISkSurface;
    FWidth: Integer;
    procedure ReleaseBuffer;
  public
    destructor Destroy; override;
    procedure EnsureSize(const AWidth, AHeight: Integer);
    function BeginNativeText: HDC;
    procedure Present(const ADC: HDC);
    property Height: Integer read FHeight;
    property Surface: ISkSurface read FSurface;
    property Width: Integer read FWidth;
  end;

implementation

uses
  System.Math,
  System.SysUtils;

destructor TDACDBGridSurfaceBuffer.Destroy;
begin
  ReleaseBuffer;
  inherited;
end;

procedure TDACDBGridSurfaceBuffer.ReleaseBuffer;
begin
  // Skia must release its view of the DIB before the pixels are freed.
  FSurface := nil;
  if FMemoryDC <> 0 then
  begin
    GdiFlush;
    if (FOldBitmap <> 0) and (FOldBitmap <> HGDI_ERROR) then
      SelectObject(FMemoryDC, FOldBitmap);
  end;
  FOldBitmap := 0;
  if FBitmap <> 0 then DeleteObject(FBitmap);
  FBitmap := 0;
  if FMemoryDC <> 0 then DeleteDC(FMemoryDC);
  FMemoryDC := 0;
  FWidth := 0; FHeight := 0;
end;

procedure TDACDBGridSurfaceBuffer.EnsureSize(const AWidth, AHeight: Integer);
var
  LInfo: TSkImageInfo;
  LBitmapInfo: TBitmapInfo;
  LPixels: Pointer;
  LHeight, LWidth: Integer;
begin
  LWidth := Max(1, AWidth);
  LHeight := Max(1, AHeight);
  if (FSurface <> nil) and (FWidth = LWidth) and (FHeight = LHeight) then
    Exit;
  ReleaseBuffer;
  try
    FWidth := LWidth; FHeight := LHeight;
    FMemoryDC := CreateCompatibleDC(0);
    if FMemoryDC = 0 then RaiseLastOSError;
    ZeroMemory(@LBitmapInfo, SizeOf(LBitmapInfo));
    LBitmapInfo.bmiHeader.biSize := SizeOf(LBitmapInfo.bmiHeader);
    LBitmapInfo.bmiHeader.biWidth := FWidth;
    LBitmapInfo.bmiHeader.biHeight := -FHeight;
    LBitmapInfo.bmiHeader.biPlanes := 1;
    LBitmapInfo.bmiHeader.biBitCount := 32;
    LBitmapInfo.bmiHeader.biCompression := BI_RGB;
    LPixels := nil;
    FBitmap := CreateDIBSection(FMemoryDC, LBitmapInfo, DIB_RGB_COLORS,
      LPixels, 0, 0);
    if (FBitmap = 0) or (LPixels = nil) then
      raise EOutOfMemory.Create('Nao foi possivel criar o buffer da TDACDBGrid.');
    FOldBitmap := SelectObject(FMemoryDC, FBitmap);
    if (FOldBitmap = 0) or (FOldBitmap = HGDI_ERROR) then RaiseLastOSError;
    // The top-down DIB is shared by the Skia chrome and native Windows text.
    // A complete opaque frame is composed before anything reaches the HWND.
    LInfo := TSkImageInfo.Create(FWidth, FHeight);
    FSurface := TSkSurface.MakeRasterDirect(LInfo, LPixels,
      NativeUInt(FWidth * SizeOf(Cardinal)));
    if FSurface = nil then
      raise EOutOfMemory.Create('Nao foi possivel criar a superficie Skia da TDACDBGrid.');
  except
    ReleaseBuffer;
    raise;
  end;
end;

function TDACDBGridSurfaceBuffer.BeginNativeText: HDC;
begin
  Result := 0;
  if FSurface = nil then Exit;
  FSurface.Flush;
  Result := FMemoryDC;
end;

procedure TDACDBGridSurfaceBuffer.Present(const ADC: HDC);
begin
  if (ADC = 0) or (FSurface = nil) or (FMemoryDC = 0) then Exit;
  // Commit native text before the single transfer. Flush the transfer too,
  // since the next Skia frame writes directly into these same pixels.
  GdiFlush;
  BitBlt(ADC, 0, 0, FWidth, FHeight, FMemoryDC, 0, 0, SRCCOPY);
  GdiFlush;
end;

end.
