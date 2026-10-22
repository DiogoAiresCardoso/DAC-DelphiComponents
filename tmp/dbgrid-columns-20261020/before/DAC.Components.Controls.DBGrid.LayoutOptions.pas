unit DAC.Components.Controls.DBGrid.LayoutOptions;

interface

uses
  System.Classes,
  DAC.Components.Controls.DBGrid.Types;

type
  TDACDBGridLayoutOptions = class(TPersistent)
  private
    FAutoLoad: Boolean;
    FAutoSave: Boolean;
    FDebounce: Integer;
    FEnabled: Boolean;
    FOnChange: TNotifyEvent;
    FStorageFileName: string;
    procedure Changed;
    procedure SetAutoLoad(const AValue: Boolean);
    procedure SetAutoSave(const AValue: Boolean);
    procedure SetDebounce(const AValue: Integer);
    procedure SetEnabled(const AValue: Boolean);
    procedure SetStorageFileName(const AValue: string);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  published
    property AutoLoad: Boolean read FAutoLoad write SetAutoLoad default True;
    property AutoSave: Boolean read FAutoSave write SetAutoSave default True;
    property Debounce: Integer read FDebounce write SetDebounce
      default DACDBGridDefaultLayoutDebounce;
    property Enabled: Boolean read FEnabled write SetEnabled default True;
    property StorageFileName: string read FStorageFileName
      write SetStorageFileName;
  end;

implementation

uses
  System.Math;

constructor TDACDBGridLayoutOptions.Create;
begin
  inherited Create;
  FAutoLoad := True;
  FAutoSave := True;
  FDebounce := DACDBGridDefaultLayoutDebounce;
  FEnabled := True;
end;

procedure TDACDBGridLayoutOptions.Assign(Source: TPersistent);
var
  LSource: TDACDBGridLayoutOptions;
begin
  if Source is TDACDBGridLayoutOptions then
  begin
    LSource := TDACDBGridLayoutOptions(Source);
    FAutoLoad := LSource.FAutoLoad;
    FAutoSave := LSource.FAutoSave;
    FDebounce := LSource.FDebounce;
    FEnabled := LSource.FEnabled;
    FStorageFileName := LSource.FStorageFileName;
    Changed;
  end
  else
    inherited Assign(Source);
end;

procedure TDACDBGridLayoutOptions.Changed;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TDACDBGridLayoutOptions.SetAutoLoad(const AValue: Boolean);
begin
  if FAutoLoad = AValue then Exit;
  FAutoLoad := AValue;
  Changed;
end;

procedure TDACDBGridLayoutOptions.SetAutoSave(const AValue: Boolean);
begin
  if FAutoSave = AValue then Exit;
  FAutoSave := AValue;
  Changed;
end;

procedure TDACDBGridLayoutOptions.SetDebounce(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(100, AValue);
  if FDebounce = LValue then Exit;
  FDebounce := LValue;
  Changed;
end;

procedure TDACDBGridLayoutOptions.SetEnabled(const AValue: Boolean);
begin
  if FEnabled = AValue then Exit;
  FEnabled := AValue;
  Changed;
end;

procedure TDACDBGridLayoutOptions.SetStorageFileName(const AValue: string);
begin
  if FStorageFileName = AValue then Exit;
  FStorageFileName := AValue;
  Changed;
end;

end.
