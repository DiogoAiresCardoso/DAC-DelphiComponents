unit DAC.Components.Charts.Surface;

interface

uses System.SysUtils, System.Skia, Winapi.Windows, Vcl.Graphics;

type
  { One top-down, opaque BGRA DIB shared by Skia and native text. No screen DC
    is touched until the owner publishes this complete buffer. }
  TDACChartSurface = class
  private
    FDC: HDC;
    FBitmap, FOldBitmap: HGDIOBJ;
    FPixels: Pointer;
    FWidth, FHeight: Integer;
    FSurface: ISkSurface;
    procedure Release;
  public
    destructor Destroy; override;
    procedure SetSize(W,H: Integer);
    procedure Flush;
    procedure OpaqueRect(const R: TRect);
    procedure Present(ADC: HDC);
    procedure SavePNG(const FileName: string);
    property DC: HDC read FDC;
    property Surface: ISkSurface read FSurface;
    property Width: Integer read FWidth;
    property Height: Integer read FHeight;
  end;

implementation

uses System.Math, Vcl.Imaging.pngimage;

procedure TDACChartSurface.Release;
begin
  FSurface := nil;
  if FDC <> 0 then begin
    SelectObject(FDC,FOldBitmap);
    DeleteObject(FBitmap); DeleteDC(FDC);
  end;
  FDC := 0; FPixels := nil; FWidth := 0; FHeight := 0;
end;
destructor TDACChartSurface.Destroy;
begin Release; inherited; end;
procedure TDACChartSurface.SetSize(W,H: Integer);
var B: TBitmapInfo;
begin
  W := Max(1,W); H := Max(1,H);
  if (W=FWidth) and (H=FHeight) then Exit;
  Release;
  ZeroMemory(@B,SizeOf(B));
  B.bmiHeader.biSize := SizeOf(TBitmapInfoHeader);
  B.bmiHeader.biWidth := W; B.bmiHeader.biHeight := -H;
  B.bmiHeader.biPlanes := 1; B.bmiHeader.biBitCount := 32;
  B.bmiHeader.biCompression := BI_RGB;
  FDC := CreateCompatibleDC(0);
  FBitmap := CreateDIBSection(FDC,B,DIB_RGB_COLORS,FPixels,0,0);
  if (FDC=0) or (FBitmap=0) then begin Release; RaiseLastOSError; end;
  FOldBitmap := SelectObject(FDC,FBitmap);
  FWidth := W; FHeight := H;
  FSurface := TSkSurface.MakeRasterDirect(TSkImageInfo.Create(W,H),FPixels,W*4);
  if FSurface=nil then begin Release; raise EOutOfMemory.Create('Chart: superficie Skia indisponivel'); end;
end;
procedure TDACChartSurface.Flush;
begin if FSurface<>nil then FSurface.Flush; GdiFlush; end;
procedure TDACChartSurface.OpaqueRect(const R: TRect);
var X,Y: Integer; Pixel: PCardinal;
begin
  GdiFlush;
  for Y:=Max(0,R.Top) to Min(FHeight,R.Bottom)-1 do begin
    Pixel:=PCardinal(NativeUInt(FPixels)+NativeUInt((Y*FWidth+Max(0,R.Left))*4));
    for X:=Max(0,R.Left) to Min(FWidth,R.Right)-1 do begin
      Pixel^:=Pixel^ or $FF000000; Inc(Pixel);
    end;
  end;
end;
procedure TDACChartSurface.Present(ADC: HDC);
begin Flush; BitBlt(ADC,0,0,FWidth,FHeight,FDC,0,0,SRCCOPY); end;
procedure TDACChartSurface.SavePNG(const FileName: string);
var B: TBitmap; P: TPngImage;
begin
  Flush; B := TBitmap.Create; P := TPngImage.Create;
  try
    B.PixelFormat := pf24bit; B.SetSize(FWidth,FHeight);
    BitBlt(B.Canvas.Handle,0,0,FWidth,FHeight,FDC,0,0,SRCCOPY);
    P.Assign(B); P.SaveToFile(FileName);
  finally P.Free; B.Free; end;
end;
end.
