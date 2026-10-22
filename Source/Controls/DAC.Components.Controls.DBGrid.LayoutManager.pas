unit DAC.Components.Controls.DBGrid.LayoutManager;

interface

uses
  System.Classes,
  Vcl.Controls,
  Vcl.DBGrids,
  Vcl.ExtCtrls,
  DAC.Components.Controls.DBGrid.Columns,
  DAC.Components.Controls.DBGrid.LayoutFileStore,
  DAC.Components.Controls.DBGrid.LayoutOptions,
  DAC.Components.Controls.DBGrid.SortController,
  DAC.Components.Controls.DBGrid.Types;

type
  TDACDBGridLayoutManager = class
  private
    FApplying: Boolean;
    FColumns: TDACDBGridColumns;
    FFileStore: TDACDBGridLayoutFileStore;
    FGrid: TCustomDBGrid;
    FIdentity: string;
    FPixelsPerInch: Integer;
    FInitialCaptured: Boolean;
    FInitialSnapshot: TDACDBGridLayoutSnapshot;
    FLoaded: Boolean;
    FOnError: TDACDBGridErrorEvent;
    FOnRestoreSort: TDACDBGridRestoreSortEvent;
    FOptions: TDACDBGridLayoutOptions;
    FSortController: TDACDBGridSortController;
    FTimer: TTimer;
    procedure ApplySnapshot(const ASnapshot: TDACDBGridLayoutSnapshot);
    function CaptureSnapshot: TDACDBGridLayoutSnapshot;
    function EffectiveFileName: string;
    function FindEntry(const ACatalog: TDACDBGridLayoutCatalog): Integer;
    function FindColumn(const AKey: string): Integer;
    function HasValidKeys: Boolean;
    function LoadCatalog(out ACatalog: TDACDBGridLayoutCatalog): Boolean;
    procedure NotifyError(const AMessage: string);
    procedure TimerTick(Sender: TObject);
  public
    constructor Create(AGrid: TCustomDBGrid; AColumns: TDACDBGridColumns;
      AOptions: TDACDBGridLayoutOptions;
      ASortController: TDACDBGridSortController);
    destructor Destroy; override;
    procedure Flush;
    procedure Load;
    procedure Reload;
    procedure DiscardPendingSave;
    procedure Reset;
    procedure Save;
    procedure ScheduleSave;
    procedure SetIdentity(const AIdentity: string);
    property PixelsPerInch: Integer read FPixelsPerInch write FPixelsPerInch;
    property Applying: Boolean read FApplying;
    property OnRestoreSort: TDACDBGridRestoreSortEvent read FOnRestoreSort write FOnRestoreSort;
    property OnError: TDACDBGridErrorEvent read FOnError write FOnError;
  end;

implementation

uses
  System.Math,
  System.SysUtils,
  Winapi.Windows,
  Vcl.Forms,
  DAC.Components.Controls.DBGrid.Column,
  DAC.Components.Controls.DBGrid.LayoutSerializer;

constructor TDACDBGridLayoutManager.Create(AGrid: TCustomDBGrid;
  AColumns: TDACDBGridColumns; AOptions: TDACDBGridLayoutOptions;
  ASortController: TDACDBGridSortController);
begin
  inherited Create;
  FGrid := AGrid;
  FPixelsPerInch := 96;
  FColumns := AColumns;
  FOptions := AOptions;
  FSortController := ASortController;
  FFileStore := TDACDBGridLayoutFileStore.Create;
  FTimer := TTimer.Create(nil);
  FTimer.Enabled := False;
  FTimer.OnTimer := TimerTick;
end;

destructor TDACDBGridLayoutManager.Destroy;
begin
  Flush;
  FTimer.Free;
  FFileStore.Free;
  inherited;
end;

procedure TDACDBGridLayoutManager.ApplySnapshot(
  const ASnapshot: TDACDBGridLayoutSnapshot);
var
  I: Integer;
  J: Integer;
  LColumnIndex: Integer;
  LLayout: TDACDBGridColumnLayout;
  LOrder: TArray<TDACDBGridColumnLayout>;
  LTemp: TDACDBGridColumnLayout;
  LVisibleCount, TargetIndex: Integer;
  Applied: TStringList;
  RestoreKey, RestoreField: string;
begin
  if (FGrid = nil) or (FColumns = nil) then
    Exit;
  RestoreKey := ASnapshot.SortKey; RestoreField := ASnapshot.SortFieldName;
  if ASnapshot.SortDirection = dgsNone then
  begin RestoreKey := FSortController.Key; RestoreField := FSortController.FieldName; end;
  FApplying := True;
  Applied := TStringList.Create;
  Applied.CaseSensitive := False;
  TargetIndex := 0;
  try
    LOrder := Copy(ASnapshot.Columns);
    for I := 0 to Length(LOrder) - 2 do
      for J := I + 1 to Length(LOrder) - 1 do
        if LOrder[J].DisplayIndex < LOrder[I].DisplayIndex then
        begin
          LTemp := LOrder[I];
          LOrder[I] := LOrder[J];
          LOrder[J] := LTemp;
        end;

    for I := 0 to Length(LOrder) - 1 do
    begin
      LLayout := LOrder[I];
      LColumnIndex := FindColumn(LLayout.Key);
      if (LColumnIndex < 0) or (Applied.IndexOf(LLayout.Key) >= 0) then
        Continue;
      FColumns[LColumnIndex].Width := Max(MulDiv(FColumns[LColumnIndex].MinWidth,
        Max(96, FPixelsPerInch), 96), MulDiv(LLayout.LogicalWidth,
        Max(96, FPixelsPerInch), 96));
      if FColumns[LColumnIndex].UserHideable then
        FColumns[LColumnIndex].Visible := LLayout.Visible;
      FColumns[LColumnIndex].Index := TargetIndex;
      Inc(TargetIndex);
      Applied.Add(LLayout.Key);
    end;

    LVisibleCount := 0;
    for I := 0 to FColumns.Count - 1 do
      if FColumns[I].Visible then
        Inc(LVisibleCount);
    if (LVisibleCount = 0) and (FColumns.Count > 0) then
      FColumns[0].Visible := True;

    FSortController.Clear;
  finally
    Applied.Free;
    FApplying := False;
  end;
  if Assigned(FOnRestoreSort) then
    FOnRestoreSort(RestoreKey, RestoreField, ASnapshot.SortDirection);
end;

function TDACDBGridLayoutManager.CaptureSnapshot: TDACDBGridLayoutSnapshot;
var
  I: Integer;
begin
  Result.Version := DACDBGridLayoutVersion;
  Result.SortKey := FSortController.Key;
  Result.SortFieldName := FSortController.FieldName;
  Result.SortDirection := FSortController.Direction;
  SetLength(Result.Columns, FColumns.Count);
  for I := 0 to FColumns.Count - 1 do
  begin
    Result.Columns[I].Key := FColumns[I].EffectiveLayoutKey;
    Result.Columns[I].DisplayIndex := FColumns[I].Index;
    Result.Columns[I].LogicalWidth := MulDiv(FColumns[I].Width, 96,
      Max(96, FPixelsPerInch));
    Result.Columns[I].Visible := FColumns[I].Visible;
  end;
end;

function TDACDBGridLayoutManager.EffectiveFileName: string;
begin
  Result := FOptions.StorageFileName;
  if Result = '' then
    Result := FFileStore.DefaultFileName;
end;

function TDACDBGridLayoutManager.FindColumn(const AKey: string): Integer;
begin
  for Result := 0 to FColumns.Count - 1 do
    if SameText(FColumns[Result].EffectiveLayoutKey, AKey) then
      Exit;
  Result := -1;
end;

function TDACDBGridLayoutManager.FindEntry(
  const ACatalog: TDACDBGridLayoutCatalog): Integer;
begin
  for Result := 0 to Length(ACatalog.Entries) - 1 do
    if SameText(ACatalog.Entries[Result].Identity, FIdentity) then
      Exit;
  Result := -1;
end;

function TDACDBGridLayoutManager.HasValidKeys: Boolean;
var
  I: Integer;
  J: Integer;
  LKey: string;
begin
  Result := False;
  if FColumns = nil then
    Exit;
  for I := 0 to FColumns.Count - 1 do
  begin
    LKey := Trim(FColumns[I].EffectiveLayoutKey);
    if LKey = '' then
    begin
      NotifyError('Toda coluna persistente deve possuir LayoutKey ou FieldName.');
      Exit;
    end;
    for J := I + 1 to FColumns.Count - 1 do
      if SameText(LKey, Trim(FColumns[J].EffectiveLayoutKey)) then
      begin
        NotifyError(Format(
          'As colunas duplicadas "%s" devem possuir LayoutKey distintos.',
          [LKey]));
        Exit;
      end;
  end;
  Result := True;
end;

procedure TDACDBGridLayoutManager.Flush;
begin
  if (FTimer <> nil) and FTimer.Enabled then
  begin
    FTimer.Enabled := False;
    Save;
  end;
end;

procedure TDACDBGridLayoutManager.DiscardPendingSave;
begin
  FTimer.Enabled := False;
end;

procedure TDACDBGridLayoutManager.Reload;
begin
  DiscardPendingSave;
  FLoaded := False;
  Load;
end;

procedure TDACDBGridLayoutManager.Load;
var
  LCatalog: TDACDBGridLayoutCatalog;
  LIndex: Integer;
begin
  if FLoaded or (FIdentity = '') or (FColumns = nil) or
    (FColumns.Count = 0) or (FOptions = nil) or not FOptions.Enabled or
    not FOptions.AutoLoad or (FGrid = nil) or
    ([csDesigning, csLoading, csDestroying] * FGrid.ComponentState <> []) then
    Exit;
  if not HasValidKeys then
    Exit;
  try
    if not FInitialCaptured then
    begin
      FInitialSnapshot := CaptureSnapshot;
      FInitialCaptured := True;
    end;
    if LoadCatalog(LCatalog) then
    begin
      LIndex := FindEntry(LCatalog);
      if LIndex >= 0 then
        ApplySnapshot(LCatalog.Entries[LIndex].Snapshot);
    end;
    FLoaded := True;
  except
    on E: Exception do
      NotifyError(E.Message);
  end;
end;

function TDACDBGridLayoutManager.LoadCatalog(
  out ACatalog: TDACDBGridLayoutCatalog): Boolean;
var
  LText: string;
begin
  ACatalog.Version := DACDBGridLayoutVersion;
  SetLength(ACatalog.Entries, 0);
  LText := FFileStore.LoadText(EffectiveFileName);
  Result := TDACDBGridLayoutSerializer.Deserialize(LText, ACatalog);
  if not Result then
    raise EConvertError.Create('O arquivo de layout do TDACDBGrid contém JSON inválido.');
end;

procedure TDACDBGridLayoutManager.NotifyError(const AMessage: string);
begin
  if Assigned(FOnError) then
    FOnError(FGrid, AMessage);
end;

procedure TDACDBGridLayoutManager.Reset;
var
  I: Integer;
  J: Integer;
  LCatalog: TDACDBGridLayoutCatalog;
begin
  FTimer.Enabled := False;
  try
    if LoadCatalog(LCatalog) then
    begin
      I := FindEntry(LCatalog);
      if I >= 0 then
      begin
        for J := I to Length(LCatalog.Entries) - 2 do
          LCatalog.Entries[J] := LCatalog.Entries[J + 1];
        SetLength(LCatalog.Entries, Length(LCatalog.Entries) - 1);
        FFileStore.SaveText(EffectiveFileName,
          TDACDBGridLayoutSerializer.Serialize(LCatalog));
      end;
    end;
    if FInitialCaptured then
      ApplySnapshot(FInitialSnapshot)
    else FSortController.Clear;
    FLoaded := True;
  except
    on E: Exception do
      NotifyError(E.Message);
  end;
end;

procedure TDACDBGridLayoutManager.Save;
var
  LCatalog: TDACDBGridLayoutCatalog;
  LIndex: Integer;
begin
  if FApplying or (FIdentity = '') or (FColumns = nil) or
    (FColumns.Count = 0) or (FOptions = nil) or not FOptions.Enabled or
    (FGrid = nil) or ([csDesigning, csLoading, csDestroying] * FGrid.ComponentState <> []) then
    Exit;
  if not HasValidKeys then
    Exit;
  try
    if not LoadCatalog(LCatalog) then
      Exit;
    LIndex := FindEntry(LCatalog);
    if LIndex < 0 then
    begin
      LIndex := Length(LCatalog.Entries);
      SetLength(LCatalog.Entries, LIndex + 1);
      LCatalog.Entries[LIndex].Identity := FIdentity;
    end;
    LCatalog.Entries[LIndex].Snapshot := CaptureSnapshot;
    FFileStore.SaveText(EffectiveFileName,
      TDACDBGridLayoutSerializer.Serialize(LCatalog));
  except
    on E: Exception do
      NotifyError(E.Message);
  end;
end;

procedure TDACDBGridLayoutManager.ScheduleSave;
begin
  if FApplying or (FOptions = nil) or not FOptions.Enabled or
    not FOptions.AutoSave or (FGrid = nil) or
    ([csDesigning, csLoading, csDestroying] * FGrid.ComponentState <> []) then
    Exit;
  FTimer.Enabled := False;
  FTimer.Interval := Max(100, FOptions.Debounce);
  FTimer.Enabled := True;
end;

procedure TDACDBGridLayoutManager.SetIdentity(const AIdentity: string);
begin
  if SameText(FIdentity, AIdentity) then
    Exit;
  Flush;
  FIdentity := AIdentity;
  FLoaded := False;
  FInitialCaptured := False;
end;

procedure TDACDBGridLayoutManager.TimerTick(Sender: TObject);
begin
  FTimer.Enabled := False;
  Save;
end;

end.
