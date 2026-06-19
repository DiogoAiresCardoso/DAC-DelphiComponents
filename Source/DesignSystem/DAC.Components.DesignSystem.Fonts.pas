unit DAC.Components.DesignSystem.Fonts;

interface

uses
  System.Skia;

const
  DACComponentFontFamily = 'Inter';

type
  TDACComponentFontInstaller = class sealed
  public
    class function FontFamily: string; static;
    class function InterTypeface: ISkTypeface; static;
    class procedure InstallInter; static;
    class procedure Uninstall; static;
  end;

implementation

uses
  Winapi.Messages,
  Winapi.Windows,
  System.Classes,
  System.IOUtils,
  System.SysUtils;

const
  CInterResourceName = 'DAC_FONT_INTER';
  CInterTempFileName = 'DAC-Components-Inter.ttf';

var
  GInterFontFileName: string;
  GInterFontInstalled: Boolean;
  GInterInstallAttempted: Boolean;
  GInterTypeface: ISkTypeface;

function FindInterFontFile: string;
var
  LBasePath: string;
  LCurrentPath: string;
  LIndex: Integer;

  function CandidateAt(const ABasePath: string): string;
  begin
    Result := TPath.Combine(ABasePath, 'assets\fonts\Inter.ttf');
    if not TFile.Exists(Result) then
      Result := '';
  end;

begin
  Result := '';
  LBasePath := ExtractFilePath(GetModuleName(HInstance));
  if LBasePath = '' then
    LBasePath := ExtractFilePath(ParamStr(0));

  LCurrentPath := TPath.GetFullPath(LBasePath);
  for LIndex := 0 to 8 do
  begin
    Result := CandidateAt(LCurrentPath);
    if Result <> '' then
      Exit;

    Result := CandidateAt(TPath.Combine(LCurrentPath, 'Ancoragem'));
    if Result <> '' then
      Exit;

    if SameText(ExcludeTrailingPathDelimiter(LCurrentPath),
      ExcludeTrailingPathDelimiter(TPath.GetPathRoot(LCurrentPath))) then
      Break;

    LCurrentPath := TPath.GetFullPath(TPath.Combine(LCurrentPath, '..'));
  end;
end;

class function TDACComponentFontInstaller.FontFamily: string;
begin
  InstallInter;
  Result := DACComponentFontFamily;
end;

class function TDACComponentFontInstaller.InterTypeface: ISkTypeface;
begin
  InstallInter;
  Result := GInterTypeface;
end;

class procedure TDACComponentFontInstaller.InstallInter;
var
  LFontDir: string;
  LSourceFile: string;
  LStream: TResourceStream;
begin
  if GInterInstallAttempted then
    Exit;
  GInterInstallAttempted := True;

  try
    LFontDir := TPath.Combine(TPath.GetTempPath, 'DAC\Fonts');
    TDirectory.CreateDirectory(LFontDir);
    GInterFontFileName := TPath.Combine(LFontDir, CInterTempFileName);

    if not TFile.Exists(GInterFontFileName) then
    begin
      try
        LStream := TResourceStream.Create(HInstance, CInterResourceName, RT_RCDATA);
        try
          LStream.SaveToFile(GInterFontFileName);
        finally
          LStream.Free;
        end;
      except
        LSourceFile := FindInterFontFile;
        if LSourceFile <> '' then
          TFile.Copy(LSourceFile, GInterFontFileName, True);
      end;
    end;

    if not TFile.Exists(GInterFontFileName) then
      Exit;

    if GInterTypeface = nil then
      GInterTypeface := TSkTypeface.MakeFromFile(GInterFontFileName);

    GInterFontInstalled := AddFontResourceEx(PChar(GInterFontFileName),
      FR_PRIVATE, nil) > 0;
    if GInterFontInstalled then
      SendMessage(HWND_BROADCAST, WM_FONTCHANGE, 0, 0);
  except
    GInterFontInstalled := False;
  end;
end;

class procedure TDACComponentFontInstaller.Uninstall;
begin
  if not GInterFontInstalled then
    Exit;

  RemoveFontResourceEx(PChar(GInterFontFileName), FR_PRIVATE, nil);
  SendMessage(HWND_BROADCAST, WM_FONTCHANGE, 0, 0);
  GInterFontInstalled := False;
end;

initialization
  TDACComponentFontInstaller.InstallInter;

finalization
  TDACComponentFontInstaller.Uninstall;

end.

