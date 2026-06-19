unit DAC.Components.DesignSystem.AssetResolver;

interface

uses
  System.Skia;

type
  TDACComponentAssetResolver = class
  private
    FBasePath: string;
  public
    constructor Create(const ABasePath: string);
    function ResolveFileName(const ARelativeFileName: string): string;
    function SvgFromFile(const ARelativeFileName: string): ISkSVGDOM;
    property BasePath: string read FBasePath;
  end;

implementation

uses
  System.IOUtils,
  System.SysUtils;

constructor TDACComponentAssetResolver.Create(const ABasePath: string);
begin
  inherited Create;
  FBasePath := IncludeTrailingPathDelimiter(Trim(ABasePath));
end;

function TDACComponentAssetResolver.ResolveFileName(
  const ARelativeFileName: string): string;
var
  LFileName: string;
begin
  Result := '';
  if Trim(ARelativeFileName) = '' then
    Exit;

  LFileName := TPath.Combine(FBasePath, ARelativeFileName);
  if TFile.Exists(LFileName) then
    Result := LFileName;
end;

function TDACComponentAssetResolver.SvgFromFile(
  const ARelativeFileName: string): ISkSVGDOM;
var
  LFileName: string;
begin
  Result := nil;
  LFileName := ResolveFileName(ARelativeFileName);
  if LFileName <> '' then
    Result := TSkSVGDOM.Make(TFile.ReadAllText(LFileName, TEncoding.UTF8));
end;

end.

