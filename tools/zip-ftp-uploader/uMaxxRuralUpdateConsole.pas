unit uMaxxRuralUpdateConsole;

interface

uses
  System.SysUtils,
  IdComponent;

type
  TConsoleProgress = class
  private
    FLastPercent: Integer;
    FProgressActive: Boolean;
    FTotalBytes: Int64;
    procedure DrawProgress(const CurrentBytes: Int64);
  public
    constructor Create;
    procedure Exibir(const Mensagem: string);
    procedure Status(ASender: TObject; const AStatus: TIdStatus;
      const AStatusText: string);
    procedure WorkBegin(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCountMax: Int64);
    procedure Work(ASender: TObject; AWorkMode: TWorkMode;
      AWorkCount: Int64);
    procedure WorkEnd(ASender: TObject; AWorkMode: TWorkMode);
  end;

implementation

constructor TConsoleProgress.Create;
begin
  inherited Create;
  FLastPercent := -1;
end;

procedure TConsoleProgress.Exibir(const Mensagem: string);
begin
  if FProgressActive then
  begin
    Writeln;
    FProgressActive := False;
  end;
  Writeln('[', FormatDateTime('hh:nn:ss', Now), '] ', Mensagem);
end;

procedure TConsoleProgress.Status(ASender: TObject; const AStatus: TIdStatus;
  const AStatusText: string);
begin
  if AStatusText <> '' then
    Exibir('FTP: ' + AStatusText);
end;

procedure TConsoleProgress.DrawProgress(const CurrentBytes: Int64);
var
  Percent, Filled: Integer;
  Bar: string;
begin
  if FTotalBytes <= 0 then
    Exit;
  Percent := Round((CurrentBytes * 100.0) / FTotalBytes);
  if Percent > 100 then
    Percent := 100;
  if Percent = FLastPercent then
    Exit;

  FLastPercent := Percent;
  Filled := Percent div 5;
  Bar := StringOfChar('#', Filled) + StringOfChar('.', 20 - Filled);
  Write(#13, '[ENVIO] [', Bar, '] ', Percent:3, '%  ', CurrentBytes, '/', FTotalBytes, ' bytes');
  FProgressActive := True;
end;

procedure TConsoleProgress.WorkBegin(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCountMax: Int64);
begin
  if AWorkMode = wmWrite then
  begin
    FTotalBytes := AWorkCountMax;
    FLastPercent := -1;
    Exibir('Transferência iniciada.');
    DrawProgress(0);
  end;
end;

procedure TConsoleProgress.Work(ASender: TObject; AWorkMode: TWorkMode;
  AWorkCount: Int64);
begin
  if AWorkMode = wmWrite then
    DrawProgress(AWorkCount);
end;

procedure TConsoleProgress.WorkEnd(ASender: TObject; AWorkMode: TWorkMode);
begin
  if (AWorkMode = wmWrite) and FProgressActive then
  begin
    DrawProgress(FTotalBytes);
    Writeln;
    FProgressActive := False;
  end;
end;

end.
