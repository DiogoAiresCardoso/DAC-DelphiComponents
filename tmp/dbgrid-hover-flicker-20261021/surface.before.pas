unit DAC.Components.Controls.DBGrid.SurfaceBuffer;

interface

uses
  System.Skia,
  Winapi.Windows;

type
  TDACDBGridSurfaceBuffer = class
  private
    FHeight: Integer;
    FPixels: TArray<Cardinal>;
    FSurface: ISkSurface;
    FWidth: Integer;
  public
    procedure EnsureSize(const AWidth, AHeight: Integer);
    procedure Present(const ADC: HDC);
    property Height: Integer read FHeight;
    property Surface: ISkSurface read FSurface;
    property Width: Integer read FWidth;
  end;

implementation

uses
  System.Math,
  System.SysUtils;

procedure TDACDBGridSurfaceBuffer.EnsureSize(const AWidth, AHeight: Integer);
var
  LInfo: TSkImageInfo;
  LHeight: Integer;
  LWidth: Integer;
begin
  LWidth := Max(1, AWidth);
  LHeight := Max(1, AHeight);
  if (FSurface <> nil) and (FWidth = LWidth) and (FHeight = LHeight) then
    Exit;
  FSurface := nil;
  FWidth := LWidth;
  FHeight := LHeight;
  SetLength(FPixels, FWidth * FHeight);
  LInfo := TSkImageInfo.Create(FWidth, FHeight);
  FSurface := TSkSurface.MakeRasterDirect(LInfo, @FPixels[0],
    NativeUInt(FWidth * SizeOf(Cardinal)));
  if FSurface = nil then
    raise EOutOfMemory.Create('Não foi possível criar a superfície Skia do TDACDBGrid.');
end;

procedure TDACDBGridSurfaceBuffer.Present(const ADC: HDC);
var
  LBitmapInfo: TBitmapInfo;
begin
  if (ADC = 0) or (FSurface = nil) or (Length(FPixels) = 0) then
    Exit;
  FSurface.Flush;
  ZeroMemory(@LBitmapInfo, SizeOf(LBitmapInfo));
  LBitmapInfo.bmiHeader.biSize := SizeOf(LBitmapInfo.bmiHeader);
  LBitmapInfo.bmiHeader.biWidth := FWidth;
  LBitmapInfo.bmiHeader.biHeight := -FHeight;
  LBitmapInfo.bmiHeader.biPlanes := 1;
  LBitmapInfo.bmiHeader.biBitCount := 32;
  LBitmapInfo.bmiHeader.biCompression := BI_RGB;
  SetDIBitsToDevice(ADC, 0, 0, FWidth, FHeight, 0, 0, 0, FHeight,
    @FPixels[0], LBitmapInfo, DIB_RGB_COLORS);
end;

end.
