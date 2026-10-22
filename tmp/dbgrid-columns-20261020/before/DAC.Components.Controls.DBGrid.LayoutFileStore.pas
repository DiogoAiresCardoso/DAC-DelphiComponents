unit DAC.Components.Controls.DBGrid.LayoutFileStore;

interface

type
  TDACDBGridLayoutFileStore = class
  public
    function DefaultFileName: string;
    function LoadText(const AFileName: string): string;
    procedure SaveText(const AFileName, AText: string);
  end;

implementation

uses
  System.Classes,
  System.IOUtils,
  System.SysUtils,
  Winapi.Windows;

var
  GLayoutFileLock: TObject;

function TDACDBGridLayoutFileStore.DefaultFileName: string;
var
  LApplication: string;
  LBase: string;
begin
  LBase := GetEnvironmentVariable('LOCALAPPDATA');
  if LBase = '' then
    LBase := TPath.GetHomePath;
  LApplication := ChangeFileExt(ExtractFileName(ParamStr(0)), '');
  if LApplication = '' then
    LApplication := 'Application';
  Result := TPath.Combine(TPath.Combine(TPath.Combine(LBase, 'DAC'),
    LApplication), 'dbgrid-layouts.json');
end;

function TDACDBGridLayoutFileStore.LoadText(
  const AFileName: string): string;
begin
  Result := '';
  if AFileName = '' then
    Exit;
  TMonitor.Enter(GLayoutFileLock);
  try
    if TFile.Exists(AFileName) then
      Result := TFile.ReadAllText(AFileName, TEncoding.UTF8);
  finally
    TMonitor.Exit(GLayoutFileLock);
  end;
end;

procedure TDACDBGridLayoutFileStore.SaveText(const AFileName, AText: string);
var
  LDirectory: string;
  LTemporary: string;
begin
  if AFileName = '' then
    Exit;
  TMonitor.Enter(GLayoutFileLock);
  try
    LDirectory := ExtractFilePath(AFileName);
    if (LDirectory <> '') and not TDirectory.Exists(LDirectory) then
      TDirectory.CreateDirectory(LDirectory);
    LTemporary := AFileName + '.tmp.' + IntToStr(GetCurrentProcessId);
    TFile.WriteAllText(LTemporary, AText, TEncoding.UTF8);
    if not MoveFileEx(PChar(LTemporary), PChar(AFileName),
      MOVEFILE_REPLACE_EXISTING or MOVEFILE_WRITE_THROUGH) then
    begin
      DeleteFile(PChar(LTemporary));
      RaiseLastOSError;
    end;
  finally
    TMonitor.Exit(GLayoutFileLock);
  end;
end;

initialization
  GLayoutFileLock := TObject.Create;

finalization
  GLayoutFileLock.Free;

end.
