program DACPhysicalQAController;

{$APPTYPE CONSOLE}

uses
  System.Classes,
  System.DateUtils,
  System.Hash,
  System.Math,
  System.SysUtils,
  System.Types,
  Winapi.Messages,
  Winapi.Windows,
  Vcl.Graphics,
  Vcl.Imaging.pngimage;

const
  DemoWindowTitle = 'DAC Componentes - Demo';
  PW_RENDERFULLCONTENT = $00000002;
  MOUSEEVENTF_VIRTUALDESK = $4000;
  DAC_DB033_INPUT_MARKER = $DB033033;
  DACGRID_DIAG_FIRST_ID = 'DAC.DB030.FirstId';
  DACGRID_DIAG_LAST_ID = 'DAC.DB030.LastId';
  DACGRID_DIAG_SELECTED_ID = 'DAC.DB030.SelectedId';
  DACGRID_DIAG_DATASET_RECNO = 'DAC.DB030.DataSetRecNo';
  DACGRID_DIAG_TOP_ROW = 'DAC.DB030.TopRow';
  DACGRID_DIAG_ACTIVE_RECORD = 'DAC.DB030.ActiveRecord';
  DACGRID_DIAG_RECORD_COUNT = 'DAC.DB030.RecordCount';
  DACGRID_DIAG_COMPOSITION_COUNT = 'DAC.DB030.CompositionCount';
  DACGRID_DIAG_HEADER_HEIGHT = 'DAC.DB030.HeaderHeight';
  DACGRID_DIAG_ROW_HEIGHT = 'DAC.DB030.RowHeight';
  DACGRID_DIAG_MOUSE_WHEEL_COUNT = 'DAC.DB030.MouseWheelCount';
  DACGRID_DIAG_GRID_WHEEL_COUNT = 'DAC.DB030.GridWheelCount';
  DACGRID_DIAG_LAST_WHEEL_ROUTE = 'DAC.DB030.LastWheelRoute';
  DACGRID_DIAG_GRID_ROW = 'DAC.DB030.GridRow';
  DACGRID_DIAG_GRID_ROW_COUNT = 'DAC.DB030.GridRowCount';
  DACFORM_DIAG_EXTERNAL_CLIENT = 'DAC.DB030.ExternalClient';
  DACFORM_DIAG_EXTERNAL_SEARCH = 'DAC.DB030.ExternalSearch';
  DACFORM_DIAG_EXTERNAL_DATE = 'DAC.DB030.ExternalDate';
  DACFORM_DIAG_EXTERNAL_SLIDER = 'DAC.DB030.ExternalSlider';
  WM_DEMO_GRID_RESET_INPUT_PROBE = WM_APP + 75;
  WM_DEMO_GRID_DISARM_INPUT_PROBE = WM_APP + 76;
  DACGRID_PROBE_ACTIVE = 'DAC.DB033.Active';
  DACGRID_PROBE_CAPTURE = 'DAC.DB033.Capture';
  DACGRID_PROBE_CELL_CLICK_COUNT = 'DAC.DB033.CellClickCount';
  DACGRID_PROBE_CLICK_COUNT = 'DAC.DB033.ClickCount';
  DACGRID_PROBE_DOWN_COUNT = 'DAC.DB033.DownCount';
  DACGRID_PROBE_DOWN_NESTED_COUNT = 'DAC.DB033.DownNestedCount';
  DACGRID_PROBE_DOWN_OTHER_COUNT = 'DAC.DB033.DownOtherCount';
  DACGRID_PROBE_DOWN_TIME = 'DAC.DB033.DownTime';
  DACGRID_PROBE_DOWN_WPARAM = 'DAC.DB033.DownWParam';
  DACGRID_PROBE_DOWN_X = 'DAC.DB033.DownX';
  DACGRID_PROBE_DOWN_Y = 'DAC.DB033.DownY';
  DACGRID_PROBE_FOCUS = 'DAC.DB033.Focus';
  DACGRID_PROBE_FOREGROUND = 'DAC.DB033.Foreground';
  DACGRID_PROBE_MOVE_COUNT = 'DAC.DB033.MoveCount';
  DACGRID_PROBE_MOVE_NESTED_COUNT = 'DAC.DB033.MoveNestedCount';
  DACGRID_PROBE_MOVE_OTHER_COUNT = 'DAC.DB033.MoveOtherCount';
  DACGRID_PROBE_MOVE_TIME = 'DAC.DB033.MoveTime';
  DACGRID_PROBE_MOVE_WPARAM = 'DAC.DB033.MoveWParam';
  DACGRID_PROBE_MOVE_X = 'DAC.DB033.MoveX';
  DACGRID_PROBE_MOVE_Y = 'DAC.DB033.MoveY';
  DACGRID_PROBE_THREAD = 'DAC.DB033.Thread';
  DACGRID_PROBE_UP_COUNT = 'DAC.DB033.UpCount';
  DACGRID_PROBE_UP_NESTED_COUNT = 'DAC.DB033.UpNestedCount';
  DACGRID_PROBE_UP_OTHER_COUNT = 'DAC.DB033.UpOtherCount';
  DACGRID_PROBE_UP_DATASET_ID = 'DAC.DB033.UpDataSetId';
  DACGRID_PROBE_UP_DATASET_RECNO = 'DAC.DB033.UpDataSetRecNo';
  DACGRID_PROBE_UP_TIME = 'DAC.DB033.UpTime';
  DACGRID_PROBE_UP_WPARAM = 'DAC.DB033.UpWParam';
  DACGRID_PROBE_UP_X = 'DAC.DB033.UpX';
  DACGRID_PROBE_UP_Y = 'DAC.DB033.UpY';

type
  TLocalTokenMandatoryLabel = record
    LabelAndAttributes: TSIDAndAttributes;
  end;

  ELifecycleFailure = class(Exception);
  TLifecycleNegativeMode = (
    lnmNone,
    lnmPostReadyFailure,
    lnmHelperFailure,
    lnmHelperFailureWithSaveFailure,
    lnmFinalSaveFailure,
    lnmEnsureOutputFailure,
    lnmPartialCreateFileFailure,
    lnmAuxiliaryTimeout,
    lnmWerSecondaryWithPrimary,
    lnmWerFailureWithoutPrimary,
    lnmNominalDemoExitWithWerNonZero,
    lnmNominalWerNonZero
  );
  TAuxiliaryInjectionMode = (
    aimNone,
    aimEnsureOutputFailure,
    aimSecondCreateFileFailure,
    aimTimeout
  );

function DacPrintWindow(AWindow: HWND; ADC: HDC; AFlags: UINT): BOOL;
  stdcall; external 'user32.dll' name 'PrintWindow';

var
  GEnumRoot: HWND;
  GFindClientRect: TRect;
  GFindClass: string;
  GFindText: string;
  GFindVisibleBestLeft: Integer;
  GFindVisibleBestRight: Integer;
  GFindVisibleBestTop: Integer;
  GFoundChild: HWND;
  GAuxiliaryCleanupProcessId: DWORD;
  GAuxiliaryGracefulSignalCount: Integer;
  GAuxiliaryInjectionMode: TAuxiliaryInjectionMode;
  GAuxiliaryOutputAcquireCount: Integer;
  GDemoFixtureExitCode: Integer;
  GForceWerNonZeroExit: Boolean;
  GInjectWerFailure: Boolean;
  GLifecycleLog: TStringList;
  GLifecycleLogPath: string;
  GLifecycleInjectSaveFailure: Boolean;
  GLifecycleIsFinalSave: Boolean;
  GLifecycleModalWindow: HWND;
  GLifecycleProcessId: DWORD;
  GLifecycleTarget: HWND;
  GLifecycleTargetCount: Integer;

procedure Fail(const AMessage: string);
begin
  Writeln('FAIL: ' + AMessage);
  Halt(1);
end;

procedure SaveLifecycleLog;
begin
  if GLifecycleInjectSaveFailure then
  begin
    if GLifecycleIsFinalSave then
      raise EInOutError.Create(
        'INJECTED_SAVE_LIFECYCLE_LOG_FAILURE Stage=final')
    else
      raise EInOutError.Create(
        'INJECTED_SAVE_LIFECYCLE_LOG_FAILURE Stage=runtime');
  end;
  if (GLifecycleLog <> nil) and (GLifecycleLogPath <> '') then
    GLifecycleLog.SaveToFile(GLifecycleLogPath, TEncoding.UTF8);
end;

procedure LifecycleLog(const AMessage: string);
begin
  Writeln(AMessage);
  if GLifecycleLog <> nil then
    GLifecycleLog.Add(AMessage);
end;

procedure LifecycleFail(const AMessage: string);
begin
  LifecycleLog('FAIL: ' + AMessage);
  try
    SaveLifecycleLog;
  except
    on E: Exception do
      Writeln('LIFECYCLE_LOG_SAVE_FAILED: ' + E.ClassName + ': ' +
        E.Message);
  end;
  raise ELifecycleFailure.Create(AMessage);
end;

procedure CloseOwnedHandle(var AHandle: THandle);
begin
  if (AHandle <> 0) and (AHandle <> INVALID_HANDLE_VALUE) then
  begin
    CloseHandle(AHandle);
    AHandle := 0;
  end;
end;

function FileSize64(const AFileName: string): Int64;
var
  LStream: TFileStream;
begin
  LStream := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyNone);
  try
    Result := LStream.Size;
  finally
    LStream.Free;
  end;
end;

function Sha256File(const AFileName: string): string;
begin
  if not FileExists(AFileName) then
    Exit('MISSING');
  Result := UpperCase(THashSHA2.GetHashStringFromFile(AFileName));
end;

function SystemTimeToIso8601(const ATime: TSystemTime): string;
begin
  Result := Format('%.4d-%.2d-%.2dT%.2d:%.2d:%.2d.%.3dZ',
    [ATime.wYear, ATime.wMonth, ATime.wDay, ATime.wHour,
     ATime.wMinute, ATime.wSecond, ATime.wMilliseconds]);
end;

function AddSecondsToSystemTime(const ATime: TSystemTime;
  const ASeconds: Integer): TSystemTime;
var
  LFileTime: TFileTime;
  LValue: Int64;
begin
  FillChar(Result, SizeOf(Result), 0);
  if not SystemTimeToFileTime(ATime, LFileTime) then
    LifecycleFail('SystemTimeToFileTime falhou: ' +
      SysErrorMessage(GetLastError));
  Move(LFileTime, LValue, SizeOf(LValue));
  Inc(LValue, Int64(ASeconds) * 10000000);
  Move(LValue, LFileTime, SizeOf(LFileTime));
  if not FileTimeToSystemTime(LFileTime, Result) then
    LifecycleFail('FileTimeToSystemTime falhou: ' +
      SysErrorMessage(GetLastError));
end;

function CleanWindowText(const AText: string): string;
begin
  Result := StringReplace(AText, #13, '\r', [rfReplaceAll]);
  Result := StringReplace(Result, #10, '\n', [rfReplaceAll]);
  Result := StringReplace(Result, '"', '""', [rfReplaceAll]);
end;

function FindDemoWindow: HWND;
begin
  Result := FindWindow(nil, PChar(DemoWindowTitle));
end;

function RequireDemoWindow: HWND;
begin
  Result := FindDemoWindow;
  if Result = 0 then
    Fail('Janela "' + DemoWindowTitle + '" nao encontrada.');
end;

procedure ActivateDemo(const AWindow: HWND);
var
  LAttached: Boolean;
  LCurrentThreadId: DWORD;
  LInfo: TGUIThreadInfo;
  LTarget: HWND;
  LWindowThreadId: DWORD;
begin
  LCurrentThreadId := GetCurrentThreadId;
  LWindowThreadId := GetWindowThreadProcessId(AWindow, nil);
  FillChar(LInfo, SizeOf(LInfo), 0);
  LInfo.cbSize := SizeOf(LInfo);
  LTarget := 0;
  if GetGUIThreadInfo(LWindowThreadId, LInfo) then
    LTarget := LInfo.hwndFocus;
  LAttached := (LCurrentThreadId <> LWindowThreadId) and
    AttachThreadInput(LCurrentThreadId, LWindowThreadId, True);
  try
    if IsIconic(AWindow) then
      ShowWindow(AWindow, SW_RESTORE);
    ShowWindow(AWindow, SW_SHOW);
    BringWindowToTop(AWindow);
    SetForegroundWindow(AWindow);
    SetActiveWindow(AWindow);
    if (LTarget <> 0) and IsWindow(LTarget) then
      SetFocus(LTarget);
  finally
    if LAttached then
      AttachThreadInput(LCurrentThreadId, LWindowThreadId, False);
  end;
  Sleep(150);
end;

procedure StartDemo(const AExePath: string);
var
  LExitCode: DWORD;
  I: Integer;
  LProcessInfo: TProcessInformation;
  LStartupInfo: TStartupInfo;
  LWindow: HWND;
begin
  if not FileExists(AExePath) then
    Fail('Executavel nao encontrado: ' + AExePath);
  FillChar(LStartupInfo, SizeOf(LStartupInfo), 0);
  LStartupInfo.cb := SizeOf(LStartupInfo);
  FillChar(LProcessInfo, SizeOf(LProcessInfo), 0);
  if not CreateProcess(PChar(AExePath), nil, nil, nil, False, 0, nil,
    PChar(ExtractFilePath(AExePath)), LStartupInfo, LProcessInfo) then
    Fail('CreateProcess falhou: ' + SysErrorMessage(GetLastError));
  CloseHandle(LProcessInfo.hThread);
  try
    WaitForInputIdle(LProcessInfo.hProcess, 10000);
    for I := 1 to 150 do
    begin
      if WaitForSingleObject(LProcessInfo.hProcess, 0) = WAIT_OBJECT_0 then
      begin
        GetExitCodeProcess(LProcessInfo.hProcess, LExitCode);
        Fail('Demo encerrou antes de mostrar a janela; ExitCode=' +
          IntToStr(LExitCode));
      end;
      LWindow := FindDemoWindow;
      if (LWindow <> 0) and IsWindowVisible(LWindow) then
        Break;
      Sleep(100);
    end;
    if (LWindow = 0) or not IsWindowVisible(LWindow) then
      Fail('Demo iniciou, mas nao apresentou janela visivel em 15 segundos.');
    SetForegroundWindow(LWindow);
    Sleep(2500);
    if WaitForSingleObject(LProcessInfo.hProcess, 0) = WAIT_OBJECT_0 then
    begin
      GetExitCodeProcess(LProcessInfo.hProcess, LExitCode);
      Fail('Demo encerrou apos mostrar a janela; ExitCode=' +
        IntToStr(LExitCode));
    end;
    if not IsWindow(LWindow) or not IsWindowVisible(LWindow) then
      Fail('Janela da Demo desapareceu durante estabilizacao.');
    Writeln('PASS PID=' + IntToStr(LProcessInfo.dwProcessId) +
      ' HWND=' + IntToStr(LWindow));
  finally
    CloseHandle(LProcessInfo.hProcess);
  end;
end;

procedure ResizeClient(const AWindow: HWND; const AWidth, AHeight: Integer);
var
  I: Integer;
  LClient: TRect;
  LExStyle: DWORD;
  LRect: TRect;
  LStyle: DWORD;
  LWindowRect: TRect;
begin
  LRect := Rect(0, 0, AWidth, AHeight);
  LStyle := GetWindowLong(AWindow, GWL_STYLE);
  LExStyle := GetWindowLong(AWindow, GWL_EXSTYLE);
  if not AdjustWindowRectEx(LRect, LStyle, False, LExStyle) then
    Fail('AdjustWindowRectEx falhou: ' + SysErrorMessage(GetLastError));
  if not SetWindowPos(AWindow, 0, 40, 40, LRect.Right - LRect.Left,
    LRect.Bottom - LRect.Top, SWP_NOZORDER or SWP_NOACTIVATE) then
    Fail('SetWindowPos falhou: ' + SysErrorMessage(GetLastError));
  for I := 1 to 3 do
  begin
    GetClientRect(AWindow, LClient);
    if ((LClient.Right - LClient.Left) = AWidth) and
      ((LClient.Bottom - LClient.Top) = AHeight) then
      Break;
    GetWindowRect(AWindow, LWindowRect);
    if not SetWindowPos(AWindow, 0, LWindowRect.Left, LWindowRect.Top,
      (LWindowRect.Right - LWindowRect.Left) +
        AWidth - (LClient.Right - LClient.Left),
      (LWindowRect.Bottom - LWindowRect.Top) +
        AHeight - (LClient.Bottom - LClient.Top),
      SWP_NOZORDER or SWP_NOACTIVATE) then
      Fail('SetWindowPos iterativo falhou: ' +
        SysErrorMessage(GetLastError));
  end;
  ActivateDemo(AWindow);
  Sleep(300);
end;

procedure EnsureOutputDirectory(const AFileName: string);
var
  LDirectory: string;
begin
  LDirectory := ExtractFileDir(ExpandFileName(AFileName));
  if GAuxiliaryInjectionMode = aimEnsureOutputFailure then
    LifecycleFail('INJECTED_ENSURE_OUTPUT_DIRECTORY_FAILURE Path="' +
      LDirectory + '"');
  if (LDirectory <> '') and not DirectoryExists(LDirectory) and
    not ForceDirectories(LDirectory) then
    LifecycleFail('Nao foi possivel criar diretorio: ' + LDirectory);
end;

function CreateInheritedOutputFile(const AFileName: string): THandle;
var
  LSecurity: TSecurityAttributes;
begin
  if GAuxiliaryInjectionMode = aimSecondCreateFileFailure then
  begin
    Inc(GAuxiliaryOutputAcquireCount);
    if GAuxiliaryOutputAcquireCount = 2 then
      LifecycleFail(
        'INJECTED_CREATEFILE_PARTIAL_FAILURE Acquire=2 Path="' +
        AFileName + '"');
  end;
  EnsureOutputDirectory(AFileName);
  FillChar(LSecurity, SizeOf(LSecurity), 0);
  LSecurity.nLength := SizeOf(LSecurity);
  LSecurity.bInheritHandle := True;
  Result := CreateFile(PChar(AFileName), GENERIC_WRITE,
    FILE_SHARE_READ or FILE_SHARE_WRITE, @LSecurity, CREATE_ALWAYS,
    FILE_ATTRIBUTE_NORMAL, 0);
  if Result = INVALID_HANDLE_VALUE then
    LifecycleFail('CreateFile falhou para "' + AFileName + '": ' +
      SysErrorMessage(GetLastError));
end;

function CreateInheritedNullInput: THandle;
var
  LSecurity: TSecurityAttributes;
begin
  FillChar(LSecurity, SizeOf(LSecurity), 0);
  LSecurity.nLength := SizeOf(LSecurity);
  LSecurity.bInheritHandle := True;
  Result := CreateFile('NUL', GENERIC_READ,
    FILE_SHARE_READ or FILE_SHARE_WRITE, @LSecurity, OPEN_EXISTING,
    FILE_ATTRIBUTE_NORMAL, 0);
  if Result = INVALID_HANDLE_VALUE then
    LifecycleFail('CreateFile NUL falhou: ' +
      SysErrorMessage(GetLastError));
end;

function EnumAuxiliaryCleanupWindow(AWindow: HWND;
  AData: LPARAM): BOOL; stdcall;
var
  LMessageResult: DWORD_PTR;
  LProcessId: DWORD;
begin
  Result := True;
  GetWindowThreadProcessId(AWindow, @LProcessId);
  if LProcessId <> GAuxiliaryCleanupProcessId then
    Exit;
  LMessageResult := 0;
  if SendMessageTimeout(AWindow, WM_CLOSE, 0, 0,
    SMTO_ABORTIFHUNG or SMTO_BLOCK, 1000, @LMessageResult) <> 0 then
    Inc(GAuxiliaryGracefulSignalCount);
end;

function RunCapturedProcess(const AApplication, AArguments,
  AWorkingDirectory, AStdoutPath, AStderrPath: string;
  const ATimeout: DWORD): DWORD;
var
  LCommandLine: string;
  LErrorHandle: THandle;
  LInputHandle: THandle;
  LProcessInfo: TProcessInformation;
  LProcessCreated: Boolean;
  LStartupInfo: TStartupInfo;
  LWait: DWORD;
  LOutputHandle: THandle;
begin
  Result := DWORD(-1);
  LOutputHandle := 0;
  LErrorHandle := 0;
  LInputHandle := 0;
  FillChar(LProcessInfo, SizeOf(LProcessInfo), 0);
  LProcessCreated := False;
  LCommandLine := '"' + AApplication + '"';
  if AArguments <> '' then
    LCommandLine := LCommandLine + ' ' + AArguments;
  try
    try
      LOutputHandle := CreateInheritedOutputFile(AStdoutPath);
      LErrorHandle := CreateInheritedOutputFile(AStderrPath);
      LInputHandle := CreateInheritedNullInput;
      FillChar(LStartupInfo, SizeOf(LStartupInfo), 0);
      LStartupInfo.cb := SizeOf(LStartupInfo);
      LStartupInfo.dwFlags := STARTF_USESTDHANDLES;
      LStartupInfo.hStdInput := LInputHandle;
      LStartupInfo.hStdOutput := LOutputHandle;
      LStartupInfo.hStdError := LErrorHandle;
      if not CreateProcess(PChar(AApplication), PChar(LCommandLine), nil,
        nil, True, CREATE_NO_WINDOW, nil, PChar(AWorkingDirectory),
        LStartupInfo, LProcessInfo) then
        LifecycleFail('CreateProcess auxiliar falhou para "' +
          AApplication + '": ' + SysErrorMessage(GetLastError));
      LProcessCreated := True;
    finally
      CloseOwnedHandle(LInputHandle);
      CloseOwnedHandle(LOutputHandle);
      CloseOwnedHandle(LErrorHandle);
    end;
    CloseOwnedHandle(LProcessInfo.hThread);
    LifecycleLog(Format('AUXILIARY_PROCESS PID=%d Application="%s"',
      [LProcessInfo.dwProcessId, AApplication]));
    LWait := WaitForSingleObject(LProcessInfo.hProcess, ATimeout);
    if LWait <> WAIT_OBJECT_0 then
    begin
      LifecycleLog(Format(
        'AUXILIARY_TIMEOUT PID=%d TimeoutMs=%d WaitResult=%d',
        [LProcessInfo.dwProcessId, ATimeout, LWait]));
      GAuxiliaryCleanupProcessId := LProcessInfo.dwProcessId;
      GAuxiliaryGracefulSignalCount := 0;
      try
        EnumWindows(@EnumAuxiliaryCleanupWindow, 0);
        LifecycleLog(Format(
          'AUXILIARY_GRACEFUL_CLEANUP PID=%d Signals=%d WaitMs=1000',
          [LProcessInfo.dwProcessId, GAuxiliaryGracefulSignalCount]));
        if WaitForSingleObject(LProcessInfo.hProcess, 1000) <>
          WAIT_OBJECT_0 then
        begin
          LifecycleLog(Format(
            'INFRASTRUCTURE_CLEANUP AUX_PID=%d Method=TerminateProcess ' +
            'NOT_A_GATE_SUCCESS OriginalFailurePreserved=True',
            [LProcessInfo.dwProcessId]));
          if not TerminateProcess(LProcessInfo.hProcess, DWORD(-1)) then
            LifecycleLog(Format(
              'INFRASTRUCTURE_CLEANUP_FAILED AUX_PID=%d Error="%s" ' +
              'NOT_A_GATE_SUCCESS',
              [LProcessInfo.dwProcessId, SysErrorMessage(GetLastError)]));
          LWait := WaitForSingleObject(LProcessInfo.hProcess, 5000);
          LifecycleLog(Format(
            'INFRASTRUCTURE_CLEANUP_WAIT AUX_PID=%d Result=%d ' +
            'NOT_A_GATE_SUCCESS',
            [LProcessInfo.dwProcessId, LWait]));
        end;
      finally
        GAuxiliaryCleanupProcessId := 0;
      end;
      if WaitForSingleObject(LProcessInfo.hProcess, 0) = WAIT_OBJECT_0 then
        LifecycleLog('AUXILIARY_RESIDUAL_PROCESS_COUNT=0')
      else
        LifecycleLog('AUXILIARY_RESIDUAL_PROCESS_COUNT=1');
      LifecycleFail(Format(
        'Processo auxiliar nao encerrou no timeout: %s; PID=%d',
        [AApplication, LProcessInfo.dwProcessId]));
    end;
    if not GetExitCodeProcess(LProcessInfo.hProcess, Result) then
      LifecycleFail('GetExitCodeProcess auxiliar falhou: ' +
        SysErrorMessage(GetLastError));
  finally
    CloseOwnedHandle(LInputHandle);
    CloseOwnedHandle(LOutputHandle);
    CloseOwnedHandle(LErrorHandle);
    CloseOwnedHandle(LProcessInfo.hThread);
    CloseOwnedHandle(LProcessInfo.hProcess);
    LifecycleLog(Format(
      'AUXILIARY_RESOURCE_CLEANUP ProcessCreated=%s ' +
      'InputHandle=0 OutputHandle=0 ErrorHandle=0 ThreadHandle=0 ProcessHandle=0',
      [BoolToStr(LProcessCreated, True)]));
  end;
end;

function EnumLifecycleWindow(AWindow: HWND; AData: LPARAM): BOOL; stdcall;
var
  LClassName: array[0..255] of Char;
  LClient: TRect;
  LExStyle: NativeInt;
  LIsModal: Boolean;
  LOwner: HWND;
  LProcessId: DWORD;
  LRect: TRect;
  LRootOwner: HWND;
  LTitle: array[0..511] of Char;
  LValidClient: Boolean;
  LWindowClass: string;
  LWindowTitle: string;
begin
  Result := True;
  GetWindowThreadProcessId(AWindow, @LProcessId);
  if LProcessId <> GLifecycleProcessId then
    Exit;

  FillChar(LClassName, SizeOf(LClassName), 0);
  FillChar(LTitle, SizeOf(LTitle), 0);
  FillChar(LRect, SizeOf(LRect), 0);
  FillChar(LClient, SizeOf(LClient), 0);
  GetClassName(AWindow, LClassName, Length(LClassName));
  GetWindowText(AWindow, LTitle, Length(LTitle));
  GetWindowRect(AWindow, LRect);
  GetClientRect(AWindow, LClient);
  LWindowClass := string(LClassName);
  LWindowTitle := string(LTitle);
  LOwner := GetWindow(AWindow, GW_OWNER);
  LRootOwner := GetAncestor(AWindow, GA_ROOTOWNER);
  LExStyle := GetWindowLongPtr(AWindow, GWL_EXSTYLE);
  LValidClient := (LClient.Right > LClient.Left) and
    (LClient.Bottom > LClient.Top);

  LifecycleLog(Format(
    'WINDOW HWND=%d Class="%s" Caption="%s" Visible=%s Enabled=%s ' +
    'Rect=%d,%d,%d,%d Client=%dx%d Owner=%d RootOwner=%d ExStyle=0x%x',
    [NativeInt(AWindow), CleanWindowText(LWindowClass),
     CleanWindowText(LWindowTitle),
     BoolToStr(IsWindowVisible(AWindow), True),
     BoolToStr(IsWindowEnabled(AWindow), True),
     LRect.Left, LRect.Top, LRect.Right, LRect.Bottom,
     LClient.Right - LClient.Left, LClient.Bottom - LClient.Top,
     NativeInt(LOwner), NativeInt(LRootOwner), LExStyle]));

  if SameText(LWindowClass, 'TForm1') and
    SameText(LWindowTitle, DemoWindowTitle) and
    IsWindowVisible(AWindow) and IsWindowEnabled(AWindow) and
    LValidClient then
  begin
    Inc(GLifecycleTargetCount);
    GLifecycleTarget := AWindow;
  end;

  LIsModal := IsWindowVisible(AWindow) and LValidClient and
    (not SameText(LWindowClass, 'TForm1')) and
    (SameText(LWindowClass, '#32770') or
     (((Length(LWindowClass) > 0) and (LWindowClass[1] = 'T')) and
      not SameText(LWindowClass, 'TApplication')) or
     ((LExStyle and WS_EX_DLGMODALFRAME) <> 0));
  if LIsModal and (GLifecycleModalWindow = 0) then
    GLifecycleModalWindow := AWindow;
end;

function EnumerateLifecycleWindows(const AStage: string): HWND;
begin
  GLifecycleTarget := 0;
  GLifecycleTargetCount := 0;
  GLifecycleModalWindow := 0;
  LifecycleLog('WINDOWS_BEGIN Stage=' + AStage);
  SetLastError(ERROR_SUCCESS);
  if not EnumWindows(@EnumLifecycleWindow, 0) and
    (GetLastError <> ERROR_SUCCESS) then
    LifecycleFail('EnumWindows falhou no stage ' + AStage + ': ' +
      SysErrorMessage(GetLastError));
  LifecycleLog(Format(
    'WINDOWS_END Stage=%s TargetCount=%d Target=%d Modal=%d',
    [AStage, GLifecycleTargetCount, NativeInt(GLifecycleTarget),
     NativeInt(GLifecycleModalWindow)]));
  Result := GLifecycleTarget;
end;

procedure RequireNoLifecycleModal(const AStage: string);
begin
  if GLifecycleModalWindow <> 0 then
    LifecycleFail(Format(
      '%s: modal/popup detectado e preservado para captura (HWND=%d).',
      [AStage, NativeInt(GLifecycleModalWindow)]));
end;

procedure RecordLifecycleFile(const ALabel, AFileName: string);
begin
  if FileExists(AFileName) then
    LifecycleLog(Format('%s Path="%s" Size=%d SHA256=%s',
      [ALabel, AFileName, FileSize64(AFileName), Sha256File(AFileName)]))
  else
    LifecycleLog(ALabel + ' Path="' + AFileName + '" MISSING');
end;

procedure CaptureWerEvents(const AStartTime, AEndTime: TSystemTime;
  const AOutputRoot: string);
var
  LArguments: string;
  LEndPlusFive: TSystemTime;
  LErrorPath: string;
  LExitCode: DWORD;
  LOutputPath: string;
  LSystemDirectory: array[0..MAX_PATH] of Char;
  LWevtutil: string;
begin
  if GInjectWerFailure then
    LifecycleFail(
      'INJECTED_WER_DIAGNOSTIC_FAILURE controller-only');
  LEndPlusFive := AddSecondsToSystemTime(AEndTime, 5);
  LOutputPath := IncludeTrailingPathDelimiter(AOutputRoot) +
    'wer-application-events.txt';
  LErrorPath := IncludeTrailingPathDelimiter(AOutputRoot) +
    'wer-query-stderr.txt';
  LSystemDirectory[0] := #0;
  GetSystemDirectory(LSystemDirectory, Length(LSystemDirectory));
  LWevtutil := IncludeTrailingPathDelimiter(string(LSystemDirectory)) +
    'wevtutil.exe';
  LArguments := 'qe Application /q:"*[System[(EventID=1000 or ' +
    'EventID=1001) and TimeCreated[@SystemTime>=''' +
    SystemTimeToIso8601(AStartTime) + ''' and @SystemTime<=''' +
    SystemTimeToIso8601(LEndPlusFive) + ''']]]" /f:text';
  if GForceWerNonZeroExit then
  begin
    LArguments := LArguments + ' /__DAC_CONTROLLER_INVALID_SWITCH__';
    LifecycleLog(
      'WER_REAL_SUBPROCESS_NONZERO_ARMED Application="' + LWevtutil +
      '" InvalidOption=__DAC_CONTROLLER_INVALID_SWITCH__ ' +
      'SubprocessBypassed=False');
  end;
  LifecycleLog('WER_QUERY Command="' + LWevtutil + ' ' +
    LArguments + '"');
  LExitCode := RunCapturedProcess(LWevtutil, LArguments,
    AOutputRoot, LOutputPath, LErrorPath, 30000);
  LifecycleLog('WER_QUERY ExitCode=' + IntToStr(LExitCode) +
    ' Attribution=only-current-UTC-interval');
  RecordLifecycleFile('WER_STDOUT', LOutputPath);
  RecordLifecycleFile('WER_STDERR', LErrorPath);
  if LExitCode <> 0 then
    LifecycleFail(Format(
      'WER_QUERY_FAILED ExitCode=%d ExitHex=0x%s ' +
      'StdoutPath="%s" StderrPath="%s" SubprocessBypassed=False',
      [LExitCode, IntToHex(LExitCode, 8), LOutputPath, LErrorPath]));
end;

procedure CaptureWerEventsSecondary(const AStartTime,
  AEndTime: TSystemTime; const AOutputRoot,
  APrimaryFailure: string);
begin
  try
    CaptureWerEvents(AStartTime, AEndTime, AOutputRoot);
  except
    on E: Exception do
      LifecycleLog(Format(
        'WER_SECONDARY_FAILURE Exception=%s Message="%s" ' +
        'Primary="%s" OriginalFailurePreserved=True',
        [E.ClassName, CleanWindowText(E.Message),
         CleanWindowText(APrimaryFailure)]));
  end;
end;

function FileContainsText(const AFileName, AText: string): Boolean;
var
  LBytes: TBytes;
  LContent: string;
  LStream: TFileStream;
begin
  Result := False;
  if not FileExists(AFileName) then
    Exit;
  LStream := TFileStream.Create(AFileName, fmOpenRead or fmShareDenyNone);
  try
    SetLength(LBytes, LStream.Size);
    if Length(LBytes) > 0 then
      LStream.ReadBuffer(LBytes[0], Length(LBytes));
  finally
    LStream.Free;
  end;
  LContent := TEncoding.UTF8.GetString(LBytes);
  Result := Pos(LowerCase(AText), LowerCase(LContent)) > 0;
  if not Result then
  begin
    LContent := TEncoding.Unicode.GetString(LBytes);
    Result := Pos(LowerCase(AText), LowerCase(LContent)) > 0;
  end;
end;

procedure PreserveCurrentCrashArtifacts(const AExePath, AOutputRoot: string;
  const AStartedLocal: TDateTime; const AExitCode: DWORD);
var
  LCrashDirectory: string;
  LDestination: string;
  LDumpFound: Boolean;
  LMapPath: string;
  LSearch: TSearchRec;
  LWerPath: string;
  LZeroEedFade: Boolean;
begin
  LWerPath := IncludeTrailingPathDelimiter(AOutputRoot) +
    'wer-application-events.txt';
  LZeroEedFade := (AExitCode = $0EEDFADE) or
    FileContainsText(LWerPath, '0x0eedfade') or
    FileContainsText(LWerPath, '0eedfade');
  LifecycleLog('CURRENT_0EEDFADE=' +
    BoolToStr(LZeroEedFade, True));
  if not LZeroEedFade then
    Exit;

  LMapPath := ChangeFileExt(AExePath, '.map');
  if FileExists(LMapPath) then
  begin
    LDestination := IncludeTrailingPathDelimiter(AOutputRoot) +
      ExtractFileName(LMapPath);
    if not CopyFile(PChar(LMapPath), PChar(LDestination), False) then
      LifecycleFail('Falha ao preservar MAP atual: ' +
        SysErrorMessage(GetLastError));
    RecordLifecycleFile('CURRENT_MAP', LDestination);
  end
  else
    LifecycleLog('CURRENT_MAP=MISSING');

  LDumpFound := False;
  LCrashDirectory := IncludeTrailingPathDelimiter(
    GetEnvironmentVariable('LOCALAPPDATA')) + 'CrashDumps';
  if FindFirst(IncludeTrailingPathDelimiter(LCrashDirectory) +
    ExtractFileName(AExePath) + '*.dmp', faAnyFile, LSearch) = 0 then
  try
    repeat
      if (LSearch.Attr and faDirectory = 0) and
        (LSearch.TimeStamp >= AStartedLocal) then
      begin
        LDestination := IncludeTrailingPathDelimiter(AOutputRoot) +
          LSearch.Name;
        if not CopyFile(PChar(IncludeTrailingPathDelimiter(
          LCrashDirectory) + LSearch.Name), PChar(LDestination), False) then
          LifecycleFail('Falha ao preservar dump atual: ' +
            SysErrorMessage(GetLastError));
        RecordLifecycleFile('CURRENT_DUMP', LDestination);
        LDumpFound := True;
      end;
    until FindNext(LSearch) <> 0;
  finally
    System.SysUtils.FindClose(LSearch);
  end;
  if not LDumpFound then
    LifecycleLog('CURRENT_DUMP=MISSING');
end;

procedure SaveBitmapPng(const ABitmap: TBitmap; const AFileName: string);
var
  LPng: TPngImage;
begin
  EnsureOutputDirectory(AFileName);
  LPng := TPngImage.Create;
  try
    LPng.Assign(ABitmap);
    LPng.SaveToFile(AFileName);
  finally
    LPng.Free;
  end;
end;

procedure CapturePrintWindow(const AWindow: HWND; const AFileName: string);
var
  LBitmap: TBitmap;
  LRect: TRect;
begin
  if not GetWindowRect(AWindow, LRect) then
    Fail('GetWindowRect falhou: ' + SysErrorMessage(GetLastError));
  LBitmap := TBitmap.Create;
  try
    LBitmap.PixelFormat := pf32bit;
    LBitmap.SetSize(LRect.Right - LRect.Left, LRect.Bottom - LRect.Top);
    if not DacPrintWindow(AWindow, LBitmap.Canvas.Handle,
      PW_RENDERFULLCONTENT) then
      Fail('PrintWindow retornou False: ' + SysErrorMessage(GetLastError));
    SaveBitmapPng(LBitmap, AFileName);
  finally
    LBitmap.Free;
  end;
end;

procedure CaptureScreenRegion(const AWindow: HWND; const AFileName: string);
var
  LBitmap: TBitmap;
  LDesktopDC: HDC;
  LRect: TRect;
  LSuccess: Boolean;
begin
  if not GetWindowRect(AWindow, LRect) then
    Fail('GetWindowRect falhou: ' + SysErrorMessage(GetLastError));
  LDesktopDC := GetDC(0);
  if LDesktopDC = 0 then
  begin
    Writeln('SCREEN_CAPTURE_FAIL GetDC desktop; fallback=PrintWindow');
    CapturePrintWindow(AWindow, AFileName);
    Exit;
  end;
  LSuccess := False;
  LBitmap := TBitmap.Create;
  try
    LBitmap.PixelFormat := pf32bit;
    LBitmap.SetSize(LRect.Right - LRect.Left, LRect.Bottom - LRect.Top);
    if BitBlt(LBitmap.Canvas.Handle, 0, 0, LBitmap.Width,
      LBitmap.Height, LDesktopDC, LRect.Left, LRect.Top, SRCCOPY) then
    begin
      SaveBitmapPng(LBitmap, AFileName);
      LSuccess := True;
    end
    else
      Writeln('SCREEN_CAPTURE_FAIL BitBlt: ' +
        SysErrorMessage(GetLastError) + '; fallback=PrintWindow');
  finally
    LBitmap.Free;
    ReleaseDC(0, LDesktopDC);
  end;
  if not LSuccess then
    CapturePrintWindow(AWindow, AFileName);
end;

procedure ClientPointToDesktop(const AWindow: HWND; var APoint: TPoint);
begin
  if not ClientToScreen(AWindow, APoint) then
    LifecycleFail('ClientToScreen falhou: ' +
      SysErrorMessage(GetLastError));
end;

procedure ClickClient(const AWindow: HWND; const X, Y: Integer);
var
  LInput: array[0..2] of TInput;
  LPoint: TPoint;
  LTarget: HWND;
begin
  ActivateDemo(AWindow);
  LPoint := Point(X, Y);
  ClientPointToDesktop(AWindow, LPoint);
  FillChar(LInput, SizeOf(LInput), 0);
  LInput[0].Itype := INPUT_MOUSE;
  LInput[0].mi.dx := MulDiv(LPoint.X, 65535,
    GetSystemMetrics(SM_CXSCREEN) - 1);
  LInput[0].mi.dy := MulDiv(LPoint.Y, 65535,
    GetSystemMetrics(SM_CYSCREEN) - 1);
  LInput[0].mi.dwFlags := MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_MOVE;
  LInput[1].Itype := INPUT_MOUSE;
  LInput[1].mi.dwFlags := MOUSEEVENTF_LEFTDOWN;
  LInput[2].Itype := INPUT_MOUSE;
  LInput[2].mi.dwFlags := MOUSEEVENTF_LEFTUP;
  if SendInput(Length(LInput), LInput[0], SizeOf(TInput)) <>
    UINT(Length(LInput)) then
  begin
    Writeln('INPUT_FAIL SendInput click: ' + SysErrorMessage(GetLastError) +
      '; fallback=SendMessage');
    LTarget := WindowFromPoint(LPoint);
    if LTarget = 0 then
      LTarget := AWindow;
    ScreenToClient(LTarget, LPoint);
    SendMessage(LTarget, WM_LBUTTONDOWN, MK_LBUTTON,
      MakeLParam(LPoint.X, LPoint.Y));
    SendMessage(LTarget, WM_LBUTTONUP, 0,
      MakeLParam(LPoint.X, LPoint.Y));
  end;
  Sleep(180);
end;

procedure ClickChildPhysical(const ARoot, AChild: HWND);
var
  LInput: array[0..2] of TInput;
  LRect: TRect;
  LX: Integer;
  LY: Integer;
  LPoint: TPoint;
begin
  if AChild = 0 then
    Fail('ClickChildPhysical recebeu HWND=0.');
  ActivateDemo(ARoot);
  if not GetWindowRect(AChild, LRect) then
    Fail('GetWindowRect child falhou: ' + SysErrorMessage(GetLastError));
  LX := (LRect.Left + LRect.Right) div 2;
  LY := (LRect.Top + LRect.Bottom) div 2;
  FillChar(LInput, SizeOf(LInput), 0);
  LInput[0].Itype := INPUT_MOUSE;
  LInput[0].mi.dx := MulDiv(LX, 65535, GetSystemMetrics(SM_CXSCREEN) - 1);
  LInput[0].mi.dy := MulDiv(LY, 65535, GetSystemMetrics(SM_CYSCREEN) - 1);
  LInput[0].mi.dwFlags := MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_MOVE;
  LInput[1].Itype := INPUT_MOUSE;
  LInput[1].mi.dwFlags := MOUSEEVENTF_LEFTDOWN;
  LInput[2].Itype := INPUT_MOUSE;
  LInput[2].mi.dwFlags := MOUSEEVENTF_LEFTUP;
  if SendInput(Length(LInput), LInput[0], SizeOf(TInput)) <>
    UINT(Length(LInput)) then
  begin
    Writeln('INPUT_FAIL SendInput child click: ' +
      SysErrorMessage(GetLastError) + '; fallback=SendMessage');
    LPoint := Point(LX, LY);
    ScreenToClient(AChild, LPoint);
    SendMessage(AChild, WM_LBUTTONDOWN, MK_LBUTTON,
      MakeLParam(LPoint.X, LPoint.Y));
    SendMessage(AChild, WM_LBUTTONUP, 0,
      MakeLParam(LPoint.X, LPoint.Y));
  end;
  Sleep(220);
end;

procedure WheelClient(const AWindow: HWND; const X, Y, ADelta: Integer);
var
  LInput: array[0..1] of TInput;
  LPoint: TPoint;
  LTarget: HWND;
begin
  ActivateDemo(AWindow);
  LPoint := Point(X, Y);
  ClientPointToDesktop(AWindow, LPoint);
  FillChar(LInput, SizeOf(LInput), 0);
  LInput[0].Itype := INPUT_MOUSE;
  LInput[0].mi.dx := MulDiv(LPoint.X, 65535,
    GetSystemMetrics(SM_CXSCREEN) - 1);
  LInput[0].mi.dy := MulDiv(LPoint.Y, 65535,
    GetSystemMetrics(SM_CYSCREEN) - 1);
  LInput[0].mi.dwFlags := MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_MOVE;
  LInput[1].Itype := INPUT_MOUSE;
  LInput[1].mi.mouseData := DWORD(ADelta);
  LInput[1].mi.dwFlags := MOUSEEVENTF_WHEEL;
  if SendInput(Length(LInput), LInput[0], SizeOf(TInput)) <>
    UINT(Length(LInput)) then
  begin
    Writeln('INPUT_FAIL SendInput wheel: ' + SysErrorMessage(GetLastError) +
      '; fallback=SendMessage');
    LTarget := WindowFromPoint(LPoint);
    if LTarget = 0 then
      LTarget := AWindow;
    SendMessage(LTarget, WM_MOUSEWHEEL, MakeWParam(0, Word(ADelta)),
      MakeLParam(LPoint.X, LPoint.Y));
  end;
  Sleep(180);
end;

function InputTarget(const AWindow: HWND): HWND;
var
  LInfo: TGUIThreadInfo;
  LThreadId: DWORD;
begin
  Result := AWindow;
  LThreadId := GetWindowThreadProcessId(AWindow, nil);
  FillChar(LInfo, SizeOf(LInfo), 0);
  LInfo.cbSize := SizeOf(LInfo);
  if GetGUIThreadInfo(LThreadId, LInfo) and (LInfo.hwndFocus <> 0) then
    Result := LInfo.hwndFocus;
end;

procedure RequireFocusedWindowClass(const AWindow: HWND;
  const AExpectedClass: string);
var
  LClassName: array[0..255] of Char;
  LTarget: HWND;
begin
  LTarget := InputTarget(AWindow);
  LClassName[0] := #0;
  GetClassName(LTarget, LClassName, Length(LClassName));
  if not SameText(string(LClassName), AExpectedClass) then
    LifecycleFail('Foco nao chegou ao controle nativo esperado (HWND=' +
      IntToStr(LTarget) + '; classe="' + string(LClassName) +
      '"; esperado="' + AExpectedClass + '").');
end;

procedure PressVirtualKey(const AWindow: HWND; const AKey: Word);
var
  LInput: array[0..1] of TInput;
  LTarget: HWND;
begin
  ActivateDemo(AWindow);
  FillChar(LInput, SizeOf(LInput), 0);
  LInput[0].Itype := INPUT_KEYBOARD;
  LInput[0].ki.wVk := AKey;
  LInput[1].Itype := INPUT_KEYBOARD;
  LInput[1].ki.wVk := AKey;
  LInput[1].ki.dwFlags := KEYEVENTF_KEYUP;
  if SendInput(Length(LInput), LInput[0], SizeOf(TInput)) <>
    UINT(Length(LInput)) then
  begin
    Writeln('INPUT_FAIL SendInput key: ' + SysErrorMessage(GetLastError) +
      '; fallback=SendMessage');
    LTarget := InputTarget(AWindow);
    SendMessage(LTarget, WM_KEYDOWN, AKey, 0);
    SendMessage(LTarget, WM_KEYUP, AKey, 0);
  end;
  Sleep(160);
end;

procedure TypeUnicodeText(const AWindow: HWND; const AText: string);
var
  I: Integer;
  LInput: array[0..1] of TInput;
  LTarget: HWND;
begin
  ActivateDemo(AWindow);
  for I := 1 to Length(AText) do
  begin
    FillChar(LInput, SizeOf(LInput), 0);
    LInput[0].Itype := INPUT_KEYBOARD;
    LInput[0].ki.wScan := Ord(AText[I]);
    LInput[0].ki.dwFlags := KEYEVENTF_UNICODE;
    LInput[1] := LInput[0];
    LInput[1].ki.dwFlags := KEYEVENTF_UNICODE or KEYEVENTF_KEYUP;
    if SendInput(Length(LInput), LInput[0], SizeOf(TInput)) <>
      UINT(Length(LInput)) then
    begin
      Writeln('INPUT_FAIL SendInput text: ' +
        SysErrorMessage(GetLastError) + '; fallback=SendMessage');
      LTarget := InputTarget(AWindow);
      SendMessage(LTarget, WM_CHAR, Ord(AText[I]), 0);
    end;
  end;
  Sleep(180);
end;

procedure PrintStatus(const AWindow: HWND);
var
  LClient: TRect;
  LFocus: HWND;
  LRect: TRect;
  LTitle: array[0..255] of Char;
begin
  GetWindowRect(AWindow, LRect);
  GetClientRect(AWindow, LClient);
  LFocus := GetFocus;
  LTitle[0] := #0;
  if LFocus <> 0 then
    GetWindowText(LFocus, LTitle, Length(LTitle));
  Writeln('HWND=' + IntToStr(AWindow) +
    ' Window=' + IntToStr(LRect.Right - LRect.Left) + 'x' +
    IntToStr(LRect.Bottom - LRect.Top) +
    ' Client=' + IntToStr(LClient.Right - LClient.Left) + 'x' +
    IntToStr(LClient.Bottom - LClient.Top) +
    ' Visible=' + BoolToStr(IsWindowVisible(AWindow), True) +
    ' Focus=' + IntToStr(LFocus) + ' FocusText=' + string(LTitle));
end;

function EnumChildForStatus(AWindow: HWND; AData: LPARAM): BOOL; stdcall;
var
  LClassName: array[0..127] of Char;
  LPoint: TPoint;
  LRect: TRect;
  LTitle: array[0..255] of Char;
begin
  LClassName[0] := #0;
  LTitle[0] := #0;
  GetClassName(AWindow, LClassName, Length(LClassName));
  GetWindowText(AWindow, LTitle, Length(LTitle));
  GetWindowRect(AWindow, LRect);
  LPoint := Point(LRect.Left, LRect.Top);
  ScreenToClient(GEnumRoot, LPoint);
  Writeln('CHILD HWND=' + IntToStr(AWindow) + ' Parent=' +
    IntToStr(GetParent(AWindow)) + ' Class=' +
    string(LClassName) + ' Text=' + string(LTitle) + ' X=' +
    IntToStr(LPoint.X) + ' Y=' + IntToStr(LPoint.Y) + ' W=' +
    IntToStr(LRect.Right - LRect.Left) + ' H=' +
    IntToStr(LRect.Bottom - LRect.Top) + ' Visible=' +
    BoolToStr(IsWindowVisible(AWindow), True));
  Result := True;
end;

procedure PrintChildWindows(const AWindow: HWND);
begin
  GEnumRoot := AWindow;
  EnumChildWindows(AWindow, @EnumChildForStatus, 0);
end;

function EnumChildFindText(AWindow: HWND; AData: LPARAM): BOOL; stdcall;
var
  LClassName: array[0..127] of Char;
  LTitle: array[0..255] of Char;
begin
  LClassName[0] := #0;
  LTitle[0] := #0;
  GetClassName(AWindow, LClassName, Length(LClassName));
  GetWindowText(AWindow, LTitle, Length(LTitle));
  if SameText(string(LTitle), GFindText) and
    SameText(string(LClassName), 'TDACButton') and
    IsWindowVisible(AWindow) then
  begin
    GFoundChild := AWindow;
    Result := False;
  end
  else
    Result := True;
end;

function FindChildByText(const AWindow: HWND; const AText: string): HWND;
begin
  GFindText := AText;
  GFoundChild := 0;
  EnumChildWindows(AWindow, @EnumChildFindText, 0);
  Result := GFoundChild;
end;

function EnumChildFindClass(AWindow: HWND; AData: LPARAM): BOOL; stdcall;
var
  LClassName: array[0..127] of Char;
begin
  LClassName[0] := #0;
  GetClassName(AWindow, LClassName, Length(LClassName));
  if SameText(string(LClassName), GFindClass) and
    IsWindowVisible(AWindow) then
  begin
    GFoundChild := AWindow;
    Result := False;
  end
  else
    Result := True;
end;

function FindChildByClass(const AWindow: HWND;
  const AClassName: string): HWND;
begin
  GFindClass := AClassName;
  GFoundChild := 0;
  EnumChildWindows(AWindow, @EnumChildFindClass, 0);
  Result := GFoundChild;
end;

function SameOrChildWindow(const AParent, AWindow: HWND): Boolean;
begin
  Result := (AWindow <> 0) and
    ((AWindow = AParent) or IsChild(AParent, AWindow));
end;

function EnumChildFindVisibleClassInClient(AWindow: HWND;
  AData: LPARAM): BOOL; stdcall;
var
  LClassName: array[0..127] of Char;
  LHit: HWND;
  LIntersect: TRect;
  LPoint: TPoint;
  LRect: TRect;
begin
  Result := True;
  LClassName[0] := #0;
  GetClassName(AWindow, LClassName, Length(LClassName));
  if not SameText(string(LClassName), GFindClass) then
    Exit;
  if not IsWindowVisible(AWindow) then
    Exit;
  if not GetWindowRect(AWindow, LRect) then
    Exit;
  if (LRect.Right <= LRect.Left) or (LRect.Bottom <= LRect.Top) then
    Exit;
  if not IntersectRect(LIntersect, LRect, GFindClientRect) then
    Exit;

  LPoint := Point((LIntersect.Left + LIntersect.Right) div 2,
    (LIntersect.Top + LIntersect.Bottom) div 2);
  LHit := WindowFromPoint(LPoint);
  if not SameOrChildWindow(AWindow, LHit) then
    Exit;

  if (GFoundChild = 0) or (LIntersect.Top < GFindVisibleBestTop) or
    ((LIntersect.Top = GFindVisibleBestTop) and
     (LIntersect.Left < GFindVisibleBestLeft)) then
  begin
    GFoundChild := AWindow;
    GFindVisibleBestTop := LIntersect.Top;
    GFindVisibleBestLeft := LIntersect.Left;
  end;
end;

function FindVisibleChildByClassInClient(const AWindow: HWND;
  const AClassName: string): HWND;
var
  LBottomRight: TPoint;
  LClient: TRect;
  LTopLeft: TPoint;
begin
  if not GetClientRect(AWindow, LClient) then
    Fail('GetClientRect falhou: ' + SysErrorMessage(GetLastError));
  LTopLeft := Point(LClient.Left, LClient.Top);
  LBottomRight := Point(LClient.Right, LClient.Bottom);
  ClientToScreen(AWindow, LTopLeft);
  ClientToScreen(AWindow, LBottomRight);
  GFindClientRect := Rect(LTopLeft.X, LTopLeft.Y,
    LBottomRight.X, LBottomRight.Y);
  GFindClass := AClassName;
  GFoundChild := 0;
  GFindVisibleBestTop := High(Integer);
  GFindVisibleBestLeft := High(Integer);
  EnumChildWindows(AWindow, @EnumChildFindVisibleClassInClient, 0);
  Result := GFoundChild;
end;

function EnumChildFindTopRightButton(AWindow: HWND; AData: LPARAM): BOOL;
  stdcall;
var
  LClassName: array[0..127] of Char;
  LIntersect: TRect;
  LRect: TRect;
begin
  Result := True;
  LClassName[0] := #0;
  GetClassName(AWindow, LClassName, Length(LClassName));
  if not SameText(string(LClassName), 'TDACButton') then
    Exit;
  if not IsWindowVisible(AWindow) then
    Exit;
  if not GetWindowRect(AWindow, LRect) then
    Exit;
  if (LRect.Right <= LRect.Left) or (LRect.Bottom <= LRect.Top) then
    Exit;
  if not IntersectRect(LIntersect, LRect, GFindClientRect) then
    Exit;
  if LIntersect.Top > GFindClientRect.Top + 96 then
    Exit;
  if (GFoundChild = 0) or (LIntersect.Right > GFindVisibleBestRight) or
    ((LIntersect.Right = GFindVisibleBestRight) and
     (LIntersect.Top < GFindVisibleBestTop)) then
  begin
    GFoundChild := AWindow;
    GFindVisibleBestRight := LIntersect.Right;
    GFindVisibleBestTop := LIntersect.Top;
  end;
end;

function FindThemeToggleButton(const AWindow: HWND): HWND;
var
  LBottomRight: TPoint;
  LClient: TRect;
  LTopLeft: TPoint;
begin
  Result := FindChildByText(AWindow, 'Tema claro');
  if Result <> 0 then
    Exit;
  Result := FindChildByText(AWindow, 'Tema escuro');
  if Result <> 0 then
    Exit;

  if not GetClientRect(AWindow, LClient) then
    Fail('GetClientRect falhou: ' + SysErrorMessage(GetLastError));
  LTopLeft := Point(LClient.Left, LClient.Top);
  LBottomRight := Point(LClient.Right, LClient.Bottom);
  ClientToScreen(AWindow, LTopLeft);
  ClientToScreen(AWindow, LBottomRight);
  GFindClientRect := Rect(LTopLeft.X, LTopLeft.Y,
    LBottomRight.X, LBottomRight.Y);
  GFoundChild := 0;
  GFindVisibleBestRight := Low(Integer);
  GFindVisibleBestTop := High(Integer);
  EnumChildWindows(AWindow, @EnumChildFindTopRightButton, 0);
  Result := GFoundChild;
end;

function EnumChildFindAnyText(AWindow: HWND; AData: LPARAM): BOOL; stdcall;
var
  LTitle: array[0..255] of Char;
begin
  LTitle[0] := #0;
  GetWindowText(AWindow, LTitle, Length(LTitle));
  if SameText(string(LTitle), GFindText) and IsWindowVisible(AWindow) then
  begin
    GFoundChild := AWindow;
    Result := False;
  end
  else
    Result := True;
end;

function FindVisibleChildByText(const AWindow: HWND;
  const AText: string): HWND;
begin
  GFindText := AText;
  GFoundChild := 0;
  EnumChildWindows(AWindow, @EnumChildFindAnyText, 0);
  Result := GFoundChild;
end;

function DesktopName(const ADesktop: HDESK): string;
var
  LBuffer: array[0..255] of Char;
  LNeeded: DWORD;
begin
  LBuffer[0] := #0;
  LNeeded := 0;
  if not GetUserObjectInformation(ADesktop, UOI_NAME, @LBuffer,
    SizeOf(LBuffer), LNeeded) then
    raise ELifecycleFailure.Create(
      'GetUserObjectInformation(UOI_NAME) falhou: ' +
      SysErrorMessage(GetLastError));
  Result := string(LBuffer);
end;

function ProcessIntegrityRid(const AProcessId: DWORD): DWORD;
var
  LBuffer: TBytes;
  LCount: DWORD;
  LNeeded: DWORD;
  LProcess: THandle;
  LToken: THandle;
  LTokenLabel: ^TLocalTokenMandatoryLabel;
begin
  LProcess := OpenProcess(PROCESS_QUERY_INFORMATION, False, AProcessId);
  if LProcess = 0 then
    raise ELifecycleFailure.CreateFmt(
      'OpenProcess integrity PID=%d falhou: %s',
      [AProcessId, SysErrorMessage(GetLastError)]);
  try
    LToken := 0;
    if not OpenProcessToken(LProcess, TOKEN_QUERY, LToken) then
      raise ELifecycleFailure.CreateFmt(
        'OpenProcessToken integrity PID=%d falhou: %s',
        [AProcessId, SysErrorMessage(GetLastError)]);
    try
      LNeeded := 0;
      GetTokenInformation(LToken, TokenIntegrityLevel, nil, 0, LNeeded);
      if LNeeded = 0 then
        raise ELifecycleFailure.Create(
          'TokenIntegrityLevel nao informou tamanho.');
      SetLength(LBuffer, LNeeded);
      if not GetTokenInformation(LToken, TokenIntegrityLevel,
        @LBuffer[0], LNeeded, LNeeded) then
        raise ELifecycleFailure.Create(
          'GetTokenInformation(TokenIntegrityLevel) falhou: ' +
          SysErrorMessage(GetLastError));
      LTokenLabel := Pointer(@LBuffer[0]);
      LCount := GetSidSubAuthorityCount(
        LTokenLabel^.LabelAndAttributes.Sid)^;
      if LCount = 0 then
        raise ELifecycleFailure.Create(
          'SID de integridade nao possui subauthority.');
      Result := GetSidSubAuthority(
        LTokenLabel^.LabelAndAttributes.Sid, LCount - 1)^;
    finally
      CloseHandle(LToken);
    end;
  finally
    CloseHandle(LProcess);
  end;
end;

procedure ClickScreenPointSendInputSingleShot(const APoint: TPoint);
var
  LInputs: array[0..2] of TInput;
  LSent: UINT;
  LVirtualHeight: Integer;
  LVirtualLeft: Integer;
  LVirtualTop: Integer;
  LVirtualWidth: Integer;
begin
  LVirtualLeft := GetSystemMetrics(SM_XVIRTUALSCREEN);
  LVirtualTop := GetSystemMetrics(SM_YVIRTUALSCREEN);
  LVirtualWidth := GetSystemMetrics(SM_CXVIRTUALSCREEN);
  LVirtualHeight := GetSystemMetrics(SM_CYVIRTUALSCREEN);
  if (LVirtualWidth <= 1) or (LVirtualHeight <= 1) then
    raise ELifecycleFailure.CreateFmt(
      'virtual desktop invalido: left=%d top=%d width=%d height=%d.',
      [LVirtualLeft, LVirtualTop, LVirtualWidth, LVirtualHeight]);
  FillChar(LInputs, SizeOf(LInputs), 0);
  LInputs[0].Itype := INPUT_MOUSE;
  LInputs[0].mi.dx := MulDiv(APoint.X - LVirtualLeft, 65535,
    LVirtualWidth - 1);
  LInputs[0].mi.dy := MulDiv(APoint.Y - LVirtualTop, 65535,
    LVirtualHeight - 1);
  LInputs[0].mi.dwFlags := MOUSEEVENTF_MOVE or
    MOUSEEVENTF_MOVE_NOCOALESCE or MOUSEEVENTF_ABSOLUTE or
    MOUSEEVENTF_VIRTUALDESK;
  LInputs[0].mi.dwExtraInfo := DAC_DB033_INPUT_MARKER;
  LInputs[1].Itype := INPUT_MOUSE;
  LInputs[1].mi.dwFlags := MOUSEEVENTF_LEFTDOWN;
  LInputs[1].mi.dwExtraInfo := DAC_DB033_INPUT_MARKER;
  LInputs[2].Itype := INPUT_MOUSE;
  LInputs[2].mi.dwFlags := MOUSEEVENTF_LEFTUP;
  LInputs[2].mi.dwExtraInfo := DAC_DB033_INPUT_MARKER;
  SetLastError(0);
  LSent := SendInput(Length(LInputs), LInputs[0], SizeOf(TInput));
  if LSent <> UINT(Length(LInputs)) then
    raise ELifecycleFailure.CreateFmt(
      'SendInput single-shot enviou %d/3 inputs; erro=%d "%s".',
      [LSent, GetLastError, SysErrorMessage(GetLastError)]);
end;

procedure ClickScreenPointMouseEventOnly(const ARoot: HWND;
  const APoint: TPoint);
var
  LActual: TPoint;
begin
  ActivateDemo(ARoot);
  SetCursorPos(APoint.X, APoint.Y);
  GetCursorPos(LActual);
  if (Abs(LActual.X - APoint.X) > 2) or
    (Abs(LActual.Y - APoint.Y) > 2) then
    mouse_event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_MOVE,
      MulDiv(APoint.X, 65535, GetSystemMetrics(SM_CXSCREEN) - 1),
      MulDiv(APoint.Y, 65535, GetSystemMetrics(SM_CYSCREEN) - 1), 0, 0);
  Sleep(80);
  mouse_event(MOUSEEVENTF_LEFTDOWN, 0, 0, 0, 0);
  mouse_event(MOUSEEVENTF_LEFTUP, 0, 0, 0, 0);
  Sleep(250);
end;

procedure ClickChildMouseEventOnly(const ARoot, AChild: HWND);
var
  LRect: TRect;
begin
  if (AChild = 0) or not GetWindowRect(AChild, LRect) then
    raise ELifecycleFailure.Create(
      'ClickChildMouseEventOnly nao recebeu um HWND valido.');
  ClickScreenPointMouseEventOnly(ARoot, Point(
    (LRect.Left + LRect.Right) div 2,
    (LRect.Top + LRect.Bottom) div 2));
end;

procedure WheelScreenPointMouseEventOnly(const ARoot: HWND;
  const APoint: TPoint; const ADelta: Integer);
var
  LActual: TPoint;
begin
  ActivateDemo(ARoot);
  SetCursorPos(APoint.X, APoint.Y);
  GetCursorPos(LActual);
  if (Abs(LActual.X - APoint.X) > 2) or
    (Abs(LActual.Y - APoint.Y) > 2) then
    mouse_event(MOUSEEVENTF_ABSOLUTE or MOUSEEVENTF_MOVE,
      MulDiv(APoint.X, 65535, GetSystemMetrics(SM_CXSCREEN) - 1),
      MulDiv(APoint.Y, 65535, GetSystemMetrics(SM_CYSCREEN) - 1), 0, 0);
  Sleep(80);
  // Deliberately no SendMessage/Perform/handler fallback. This legacy system
  // input API injects the same global wheel event used by physical QA.
  mouse_event(MOUSEEVENTF_WHEEL, 0, 0, DWORD(ADelta), 0);
end;

procedure ClickWindowDirect(const AWindow: HWND);
var
  LClient: TRect;
  LX: Integer;
  LY: Integer;
begin
  if AWindow = 0 then
    LifecycleFail('ClickWindowDirect recebeu HWND=0.');
  GetClientRect(AWindow, LClient);
  LX := (LClient.Right - LClient.Left) div 2;
  LY := (LClient.Bottom - LClient.Top) div 2;
  SendMessage(AWindow, WM_LBUTTONDOWN, MK_LBUTTON, MakeLParam(LX, LY));
  SendMessage(AWindow, WM_LBUTTONUP, 0, MakeLParam(LX, LY));
  Sleep(350);
end;

procedure RunDataAwarePhysicalWheelGate(const AExePath,
  AOutputRoot: string);
var
  LBeforeFile: string;
  LButton: HWND;
  LChild: HWND;
  LChildClass: array[0..127] of Char;
  LClientPoint: TPoint;
  LCompositionBefore: NativeInt;
  LCompositionAfterWheel: NativeInt;
  LControllerDesktopName: string;
  LControllerIntegrity: DWORD;
  LCursorPoint: TPoint;
  LFirstId: NativeInt;
  LGrid: HWND;
  LGridRect: TRect;
  LHeaderHeight: NativeInt;
  LHit: HWND;
  LHitClass: array[0..127] of Char;
  LHitTest: NativeInt;
  LLastId: NativeInt;
  LInputDesktop: HDESK;
  LInputDesktopName: string;
  LMouseBefore: NativeInt;
  LObjectId: DWORD;
  LGridWheelBefore: NativeInt;
  LPoint: TPoint;
  LProcessId: DWORD;
  LRecNo: NativeInt;
  LRowHeight: NativeInt;
  LScrollBarInfo: TScrollBarInfo;
  LSelectedId: NativeInt;
  LTargetDesktopName: string;
  LTargetIntegrity: DWORD;
  LTargetThreadId: DWORD;
  LWindow: HWND;
  LAfterFile: string;
  I: Integer;
  procedure RequireGate(const ACondition: Boolean;
    const AMessage: string);
  begin
    if not ACondition then
      raise ELifecycleFailure.Create('MEM-DEL-DB-033: ' + AMessage);
  end;
  function Metric(const AName: string): NativeInt;
  begin
    Result := NativeInt(GetProp(LGrid, PChar(AName)));
  end;
  procedure RequireFrame(const AContext: string;
    const AExpectedSelected, AExpectedRecNo: Integer);
  begin
    LFirstId := Metric(DACGRID_DIAG_FIRST_ID);
    LLastId := Metric(DACGRID_DIAG_LAST_ID);
    LSelectedId := Metric(DACGRID_DIAG_SELECTED_ID);
    LRecNo := Metric(DACGRID_DIAG_DATASET_RECNO);
    RequireGate((LFirstId <= AExpectedSelected) and
      (LLastId >= AExpectedSelected),
      Format('%s viewport=%d..%d nao contem ID%d.',
        [AContext, LFirstId, LLastId, AExpectedSelected]));
    RequireGate(LSelectedId = AExpectedSelected,
      Format('%s highlight=%d, esperado=%d.',
        [AContext, LSelectedId, AExpectedSelected]));
    RequireGate(LRecNo = AExpectedRecNo,
      Format('%s recno=%d, esperado=%d.',
        [AContext, LRecNo, AExpectedRecNo]));
  end;
begin
  if not DirectoryExists(AOutputRoot) and
    not ForceDirectories(AOutputRoot) then
    raise ELifecycleFailure.Create(
      'MEM-DEL-DB-033: nao foi possivel criar output-root.');
  LBeforeFile := IncludeTrailingPathDelimiter(AOutputRoot) +
    'db033-before-wheel-id1008.png';
  LAfterFile := IncludeTrailingPathDelimiter(AOutputRoot) +
    'db033-after-wheel-id1013-idle900.png';
  StartDemo(AExePath);
  LWindow := RequireDemoWindow;
  try
    LTargetThreadId := GetWindowThreadProcessId(LWindow, @LProcessId);
    RequireGate(LTargetThreadId <> 0,
      'GetWindowThreadProcessId da Demo falhou.');
    // Extra horizontal room keeps the grid's native scrollbar from being
    // covered by the outer TDACScrollContainer scrollbar during its own gate.
    ResizeClient(LWindow, 1400, 760);
    LButton := FindChildByText(LWindow, 'Data-Aware');
    RequireGate(LButton <> 0, 'botao Data-Aware nao encontrado.');
    // Page selection is deterministic setup only. The acceptance gesture
    // below remains exclusively global mouse_event input.
    ClickWindowDirect(LButton);
    LGrid := 0;
    for I := 1 to 30 do
    begin
      LGrid := FindChildByClass(LWindow, 'TDACDemoInputProbeGrid');
      if LGrid <> 0 then
        Break;
      Sleep(100);
    end;
    RequireGate(LGrid <> 0,
      'HWND TDACDemoInputProbeGrid nao encontrado/visivel.');
    RequireGate(GetWindowRect(LGrid, LGridRect),
      'GetWindowRect do grid falhou.');
    LHeaderHeight := Metric(DACGRID_DIAG_HEADER_HEIGHT);
    LRowHeight := Metric(DACGRID_DIAG_ROW_HEIGHT);
    RequireGate((LHeaderHeight > 0) and (LRowHeight > 0),
      Format('metricas nativas invalidas header=%d row=%d.',
        [LHeaderHeight, LRowHeight]));

    // Select ID1008 with one SendInput call. All focus/desktop/integrity and
    // hit-test preconditions are established and recorded before this gesture.
    // There is no retry, direct handler fallback or post-failure activation.
    LPoint := Point(LGridRect.Left + 60,
      LGridRect.Top + LHeaderHeight + (7 * LRowHeight) +
      (LRowHeight div 2));
    ActivateDemo(LWindow);
    RequireGate(SetCursorPos(LPoint.X, LPoint.Y),
      'SetCursorPos de preparacao falhou.');
    Sleep(150);
    LControllerIntegrity := ProcessIntegrityRid(GetCurrentProcessId);
    LTargetIntegrity := ProcessIntegrityRid(LProcessId);
    LControllerDesktopName := DesktopName(
      GetThreadDesktop(GetCurrentThreadId));
    LTargetDesktopName := DesktopName(
      GetThreadDesktop(LTargetThreadId));
    LInputDesktop := OpenInputDesktop(0, False, DESKTOP_READOBJECTS);
    RequireGate(LInputDesktop <> 0,
      'OpenInputDesktop falhou: ' + SysErrorMessage(GetLastError));
    try
      LInputDesktopName := DesktopName(LInputDesktop);
    finally
      CloseDesktop(LInputDesktop);
    end;
    RequireGate(LControllerIntegrity = LTargetIntegrity,
      Format('integrity divergente controller=0x%s target=0x%s.',
        [IntToHex(LControllerIntegrity, 8),
         IntToHex(LTargetIntegrity, 8)]));
    RequireGate(SameText(LControllerDesktopName, LInputDesktopName) and
      SameText(LTargetDesktopName, LInputDesktopName),
      Format('desktop divergente controller="%s" target="%s" input="%s".',
        [LControllerDesktopName, LTargetDesktopName,
         LInputDesktopName]));
    RequireGate(GetForegroundWindow = LWindow,
      Format('foreground=%d, esperado root Demo=%d.',
        [NativeInt(GetForegroundWindow), NativeInt(LWindow)]));
    RequireGate(GetCursorPos(LCursorPoint),
      'GetCursorPos da pre-condicao falhou.');
    RequireGate((LCursorPoint.X = LPoint.X) and
      (LCursorPoint.Y = LPoint.Y),
      Format('cursor=%d,%d, esperado=%d,%d.',
        [LCursorPoint.X, LCursorPoint.Y, LPoint.X, LPoint.Y]));
    LHit := WindowFromPoint(LPoint);
    LHitClass[0] := #0;
    if LHit <> 0 then
      GetClassName(LHit, LHitClass, Length(LHitClass));
    LClientPoint := LPoint;
    RequireGate(ScreenToClient(LGrid, LClientPoint),
      'ScreenToClient do alvo fisico falhou.');
    LChild := ChildWindowFromPointEx(LGrid, LClientPoint, CWP_ALL);
    LChildClass[0] := #0;
    if LChild <> 0 then
      GetClassName(LChild, LChildClass, Length(LChildClass));
    LHitTest := SendMessage(LHit, WM_NCHITTEST, 0,
      MakeLParam(LPoint.X, LPoint.Y));
    Writeln(Format(
      'MEM-DEL-DB-033 TRACE environment controllerPID=%d targetPID=%d ' +
      'targetThread=%d integrity=0x%s desktop="%s" foreground=%d root=%d',
      [GetCurrentProcessId, LProcessId, LTargetThreadId,
       IntToHex(LTargetIntegrity, 8), LInputDesktopName,
       NativeInt(GetForegroundWindow), NativeInt(LWindow)]));
    Writeln(Format(
      'MEM-DEL-DB-033 TRACE target screen=%d,%d client=%d,%d ' +
      'hit=%d class=%s parent=%d child=%d childClass=%s ' +
      'grid=%d hitTest=%d rect=%d,%d,%d,%d header=%d row=%d',
      [LPoint.X, LPoint.Y, LClientPoint.X, LClientPoint.Y,
       NativeInt(LHit), string(LHitClass), NativeInt(GetParent(LHit)),
       NativeInt(LChild), string(LChildClass), NativeInt(LGrid), LHitTest,
       LGridRect.Left, LGridRect.Top, LGridRect.Right, LGridRect.Bottom,
       LHeaderHeight, LRowHeight]));
    RequireGate((LHit = LGrid) or IsChild(LGrid, LHit),
      Format('alvo fisico hit=%d class=%s nao pertence ao grid=%d.',
        [NativeInt(LHit), string(LHitClass), NativeInt(LGrid)]));
    RequireGate(LHitTest = HTCLIENT,
      Format('alvo fisico hit-test=%d, esperado HTCLIENT=%d.',
        [LHitTest, HTCLIENT]));
    SendMessage(LGrid, WM_DEMO_GRID_RESET_INPUT_PROBE, 0, 0);
    RequireGate((Metric(DACGRID_PROBE_MOVE_COUNT) = 0) and
      (Metric(DACGRID_PROBE_DOWN_COUNT) = 0) and
      (Metric(DACGRID_PROBE_UP_COUNT) = 0) and
      (Metric(DACGRID_PROBE_MOVE_NESTED_COUNT) = 0) and
      (Metric(DACGRID_PROBE_DOWN_NESTED_COUNT) = 0) and
      (Metric(DACGRID_PROBE_UP_NESTED_COUNT) = 0) and
      (Metric(DACGRID_PROBE_MOVE_OTHER_COUNT) = 0) and
      (Metric(DACGRID_PROBE_DOWN_OTHER_COUNT) = 0) and
      (Metric(DACGRID_PROBE_UP_OTHER_COUNT) = 0) and
      (Metric(DACGRID_PROBE_CLICK_COUNT) = 0) and
      (Metric(DACGRID_PROBE_CELL_CLICK_COUNT) = 0),
      'reset do input probe nao zerou todos os contadores.');
    RequireGate((GetForegroundWindow = LWindow) and
      GetCursorPos(LCursorPoint) and
      (LCursorPoint.X = LPoint.X) and (LCursorPoint.Y = LPoint.Y) and
      (WindowFromPoint(LPoint) = LHit),
      'pre-condicao mudou entre reset do probe e gesto single-shot.');
    ClickScreenPointSendInputSingleShot(LPoint);
    Sleep(350);
    Writeln(Format(
      'MEM-DEL-DB-033 TRACE input move=%d@%d (%d,%d) wp=%d ' +
      'down=%d@%d (%d,%d) wp=%d up=%d@%d (%d,%d) wp=%d ' +
      'click=%d cellClick=%d capture=%d focus=%d foreground=%d ' +
      'active=%d thread=%d nestedMoveDownUp=%d/%d/%d ' +
      'otherMoveDownUp=%d/%d/%d upId=%d upRecNo=%d',
      [Metric(DACGRID_PROBE_MOVE_COUNT),
       Metric(DACGRID_PROBE_MOVE_TIME),
       Metric(DACGRID_PROBE_MOVE_X), Metric(DACGRID_PROBE_MOVE_Y),
       Metric(DACGRID_PROBE_MOVE_WPARAM),
       Metric(DACGRID_PROBE_DOWN_COUNT),
       Metric(DACGRID_PROBE_DOWN_TIME),
       Metric(DACGRID_PROBE_DOWN_X), Metric(DACGRID_PROBE_DOWN_Y),
       Metric(DACGRID_PROBE_DOWN_WPARAM),
       Metric(DACGRID_PROBE_UP_COUNT),
       Metric(DACGRID_PROBE_UP_TIME),
       Metric(DACGRID_PROBE_UP_X), Metric(DACGRID_PROBE_UP_Y),
       Metric(DACGRID_PROBE_UP_WPARAM),
       Metric(DACGRID_PROBE_CLICK_COUNT),
       Metric(DACGRID_PROBE_CELL_CLICK_COUNT),
       Metric(DACGRID_PROBE_CAPTURE), Metric(DACGRID_PROBE_FOCUS),
       Metric(DACGRID_PROBE_FOREGROUND), Metric(DACGRID_PROBE_ACTIVE),
       Metric(DACGRID_PROBE_THREAD),
       Metric(DACGRID_PROBE_MOVE_NESTED_COUNT),
       Metric(DACGRID_PROBE_DOWN_NESTED_COUNT),
       Metric(DACGRID_PROBE_UP_NESTED_COUNT),
       Metric(DACGRID_PROBE_MOVE_OTHER_COUNT),
       Metric(DACGRID_PROBE_DOWN_OTHER_COUNT),
       Metric(DACGRID_PROBE_UP_OTHER_COUNT),
       Metric(DACGRID_PROBE_UP_DATASET_ID),
       Metric(DACGRID_PROBE_UP_DATASET_RECNO)]));
    Writeln(Format(
      'MEM-DEL-DB-033 TRACE baseline-idle350 grid=%d ' +
      'first=%d last=%d selected=%d recno=%d',
      [NativeInt(LGrid), Metric(DACGRID_DIAG_FIRST_ID),
       Metric(DACGRID_DIAG_LAST_ID), Metric(DACGRID_DIAG_SELECTED_ID),
       Metric(DACGRID_DIAG_DATASET_RECNO)]));
    RequireGate((Metric(DACGRID_PROBE_MOVE_COUNT) = 1) and
      (Metric(DACGRID_PROBE_DOWN_COUNT) = 1) and
      (Metric(DACGRID_PROBE_UP_COUNT) = 1) and
      (Metric(DACGRID_PROBE_CLICK_COUNT) = 0) and
      (Metric(DACGRID_PROBE_CELL_CLICK_COUNT) = 1),
      Format('entrega single-shot divergente move/down/up/click/cell=%d/%d/%d/%d/%d.',
        [Metric(DACGRID_PROBE_MOVE_COUNT),
         Metric(DACGRID_PROBE_DOWN_COUNT),
         Metric(DACGRID_PROBE_UP_COUNT),
         Metric(DACGRID_PROBE_CLICK_COUNT),
         Metric(DACGRID_PROBE_CELL_CLICK_COUNT)]));
    RequireGate((Metric(DACGRID_PROBE_UP_DATASET_ID) = 1008) and
      (Metric(DACGRID_PROBE_UP_DATASET_RECNO) = 8),
      Format('selecao ao final do UP divergente id=%d recno=%d.',
        [Metric(DACGRID_PROBE_UP_DATASET_ID),
         Metric(DACGRID_PROBE_UP_DATASET_RECNO)]));
    RequireGate((Metric(DACGRID_PROBE_MOVE_X) = LClientPoint.X) and
      (Metric(DACGRID_PROBE_MOVE_Y) = LClientPoint.Y) and
      (Metric(DACGRID_PROBE_DOWN_X) = LClientPoint.X) and
      (Metric(DACGRID_PROBE_DOWN_Y) = LClientPoint.Y) and
      (Metric(DACGRID_PROBE_UP_X) = LClientPoint.X) and
      (Metric(DACGRID_PROBE_UP_Y) = LClientPoint.Y),
      'coordenadas entregues ao grid divergem do client point.');
    RequireGate((Metric(DACGRID_PROBE_MOVE_WPARAM) = 0) and
      (Metric(DACGRID_PROBE_DOWN_WPARAM) = MK_LBUTTON) and
      (Metric(DACGRID_PROBE_UP_WPARAM) = 0),
      Format('wParam divergente move/down/up=%d/%d/%d.',
        [Metric(DACGRID_PROBE_MOVE_WPARAM),
         Metric(DACGRID_PROBE_DOWN_WPARAM),
         Metric(DACGRID_PROBE_UP_WPARAM)]));
    RequireGate((Metric(DACGRID_PROBE_MOVE_TIME) <=
      Metric(DACGRID_PROBE_DOWN_TIME)) and
      (Metric(DACGRID_PROBE_DOWN_TIME) <=
      Metric(DACGRID_PROBE_UP_TIME)),
      'timestamps move/down/up fora de ordem.');
    RequireGate((Metric(DACGRID_PROBE_CAPTURE) = 0) and
      (Metric(DACGRID_PROBE_FOCUS) = NativeInt(LGrid)) and
      (Metric(DACGRID_PROBE_FOREGROUND) = NativeInt(LWindow)) and
      (Metric(DACGRID_PROBE_ACTIVE) = NativeInt(LWindow)) and
      (Metric(DACGRID_PROBE_THREAD) = NativeInt(LTargetThreadId)),
      Format('estado pos-input capture/focus/foreground/active/thread=%d/%d/%d/%d/%d.',
        [Metric(DACGRID_PROBE_CAPTURE), Metric(DACGRID_PROBE_FOCUS),
         Metric(DACGRID_PROBE_FOREGROUND), Metric(DACGRID_PROBE_ACTIVE),
         Metric(DACGRID_PROBE_THREAD)]));
    RequireFrame('baseline fisico idle350', 1008, 8);
    SendMessage(LGrid, WM_DEMO_GRID_DISARM_INPUT_PROBE, 0, 0);
    CaptureScreenRegion(LWindow, LBeforeFile);

    LCompositionBefore := Metric(DACGRID_DIAG_COMPOSITION_COUNT);
    LMouseBefore := Metric(DACGRID_DIAG_MOUSE_WHEEL_COUNT);
    LGridWheelBefore := Metric(DACGRID_DIAG_GRID_WHEEL_COUNT);
    WheelScreenPointMouseEventOnly(LWindow, LPoint,
      -5 * WHEEL_DELTA);
    Sleep(900);
    Writeln(Format(
      'MEM-DEL-DB-033 TRACE after-wheel first=%d last=%d selected=%d ' +
      'recno=%d top=%d row=%d rowCount=%d active=%d buffer=%d ' +
      'composition=%d mouse=%d ' +
      'grid=%d lastRoute=%d',
      [Metric(DACGRID_DIAG_FIRST_ID), Metric(DACGRID_DIAG_LAST_ID),
       Metric(DACGRID_DIAG_SELECTED_ID),
       Metric(DACGRID_DIAG_DATASET_RECNO),
       Metric(DACGRID_DIAG_TOP_ROW),
       Metric(DACGRID_DIAG_GRID_ROW),
       Metric(DACGRID_DIAG_GRID_ROW_COUNT),
       Metric(DACGRID_DIAG_ACTIVE_RECORD),
       Metric(DACGRID_DIAG_RECORD_COUNT),
       Metric(DACGRID_DIAG_COMPOSITION_COUNT),
       Metric(DACGRID_DIAG_MOUSE_WHEEL_COUNT),
       Metric(DACGRID_DIAG_GRID_WHEEL_COUNT),
       Metric(DACGRID_DIAG_LAST_WHEEL_ROUTE)]));
    RequireFrame('wheel fisico idle900', 1013, 13);
    LCompositionAfterWheel := Metric(DACGRID_DIAG_COMPOSITION_COUNT);
    RequireGate(LCompositionAfterWheel = LCompositionBefore + 1,
      Format('wheel recompôs %d vezes (antes=%d depois=%d).',
        [LCompositionAfterWheel - LCompositionBefore,
         LCompositionBefore, LCompositionAfterWheel]));
    RequireGate((Metric(DACGRID_DIAG_MOUSE_WHEEL_COUNT) >=
      LMouseBefore + 1) and
      (Metric(DACGRID_DIAG_GRID_WHEEL_COUNT) =
      LGridWheelBefore + 1) and
      (Metric(DACGRID_DIAG_LAST_WHEEL_ROUTE) = 1),
      Format('rota fisica divergente mouse=%d/%d grid=%d/%d last=%d.',
        [Metric(DACGRID_DIAG_MOUSE_WHEEL_COUNT), LMouseBefore,
         Metric(DACGRID_DIAG_GRID_WHEEL_COUNT), LGridWheelBefore,
         Metric(DACGRID_DIAG_LAST_WHEEL_ROUTE)]));
    RequireGate((NativeInt(GetProp(LWindow,
      DACFORM_DIAG_EXTERNAL_CLIENT)) = 13) and
      (NativeInt(GetProp(LWindow,
      DACFORM_DIAG_EXTERNAL_SEARCH)) = 13) and
      (NativeInt(GetProp(LWindow,
      DACFORM_DIAG_EXTERNAL_DATE)) = 13) and
      (NativeInt(GetProp(LWindow,
      DACFORM_DIAG_EXTERNAL_SLIDER)) = 13),
      Format('campos externos divergentes client=%d search=%d date=%d slider=%d.',
        [NativeInt(GetProp(LWindow, DACFORM_DIAG_EXTERNAL_CLIENT)),
         NativeInt(GetProp(LWindow, DACFORM_DIAG_EXTERNAL_SEARCH)),
         NativeInt(GetProp(LWindow, DACFORM_DIAG_EXTERNAL_DATE)),
         NativeInt(GetProp(LWindow, DACFORM_DIAG_EXTERNAL_SLIDER))]));
    CaptureScreenRegion(LWindow, LAfterFile);
    RequireGate(Sha256File(LBeforeFile) <> Sha256File(LAfterFile),
      'screenshots antes/depois sao identicos.');

    // Keyboard and native scrollbar are separate physical routes; neither
    // may need a wheel-specific callback to update the chrome.
    LCompositionBefore := LCompositionAfterWheel;
    keybd_event(VK_UP, 0, 0, 0);
    keybd_event(VK_UP, 0, KEYEVENTF_KEYUP, 0);
    Sleep(350);
    RequireFrame('teclado fisico', 1012, 12);
    RequireGate(Metric(DACGRID_DIAG_COMPOSITION_COUNT) =
      LCompositionBefore + 1,
      'teclado nao recompôs exatamente uma vez.');
    LCompositionBefore := Metric(DACGRID_DIAG_COMPOSITION_COUNT);
    FillChar(LScrollBarInfo, SizeOf(LScrollBarInfo), 0);
    LScrollBarInfo.cbSize := SizeOf(LScrollBarInfo);
    LObjectId := $FFFFFFFB;
    RequireGate(GetScrollBarInfo(LGrid, LObjectId,
      LScrollBarInfo), 'GetScrollBarInfo vertical falhou.');
    LPoint := Point(
      (LScrollBarInfo.rcScrollBar.Left +
       LScrollBarInfo.rcScrollBar.Right) div 2,
      Min(LScrollBarInfo.rcScrollBar.Bottom -
        LScrollBarInfo.dxyLineButton - 2,
        LScrollBarInfo.rcScrollBar.Top +
        LScrollBarInfo.xyThumbBottom + 4));
    Writeln(Format(
      'MEM-DEL-DB-033 TRACE scrollbar rect=%d,%d,%d,%d button=%d ' +
      'thumb=%d..%d point=%d,%d hit=%d',
      [LScrollBarInfo.rcScrollBar.Left, LScrollBarInfo.rcScrollBar.Top,
       LScrollBarInfo.rcScrollBar.Right, LScrollBarInfo.rcScrollBar.Bottom,
       LScrollBarInfo.dxyLineButton, LScrollBarInfo.xyThumbTop,
       LScrollBarInfo.xyThumbBottom, LPoint.X, LPoint.Y,
       NativeInt(WindowFromPoint(LPoint))]));
    ClickScreenPointMouseEventOnly(LWindow, LPoint);
    Sleep(350);
    LRecNo := Metric(DACGRID_DIAG_DATASET_RECNO);
    RequireGate(LRecNo > 12,
      Format('scrollbar fisica nao avancou recno12 (recno=%d).',
        [LRecNo]));
    RequireFrame('scrollbar fisica', 1000 + LRecNo, LRecNo);
    RequireGate(Metric(DACGRID_DIAG_COMPOSITION_COUNT) =
      LCompositionBefore + 1,
      'scrollbar nao recompôs exatamente uma vez.');

    Writeln(Format(
      'MEM-DEL-DB-033 PASS PID=%d HWND=%d sendinput=click mouse_event=wheel ' +
      'first=%d last=%d selected=%d recno=%d top=%d active=%d buffer=%d ' +
      'composition=%d beforeSha=%s afterSha=%s edit=Cliente13 search=Busca13',
      [LProcessId, NativeInt(LGrid),
       Metric(DACGRID_DIAG_FIRST_ID), Metric(DACGRID_DIAG_LAST_ID),
       Metric(DACGRID_DIAG_SELECTED_ID),
       Metric(DACGRID_DIAG_DATASET_RECNO),
       Metric(DACGRID_DIAG_TOP_ROW),
       Metric(DACGRID_DIAG_ACTIVE_RECORD),
       Metric(DACGRID_DIAG_RECORD_COUNT),
       Metric(DACGRID_DIAG_COMPOSITION_COUNT),
       Sha256File(LBeforeFile), Sha256File(LAfterFile)]));
  finally
    if (LWindow <> 0) and IsWindow(LWindow) then
      PostMessage(LWindow, WM_CLOSE, 0, 0);
    Sleep(500);
  end;
end;

procedure RunPhysicalMatrix(const AExePath, AOutputRoot: string);
const
  Captions: array[0..15] of string = (
    'Dashboard', 'Botoes', 'Inputs', 'Seletores', 'Controles', 'Tabs',
    'Cards', 'Grid', 'Status', 'Progresso', 'Pills', 'Feedback',
    'Paginacao', 'Loading', 'Charts', 'Report');
  Slugs: array[0..15] of string = (
    'dashboard', 'buttons', 'inputs', 'selectors', 'controls', 'tabs',
    'cards', 'grid', 'status', 'progress', 'pills', 'feedback',
    'pagination', 'loading', 'charts', 'report');
var
  LButton: HWND;
  LInputNative: HWND;
  LWindow: HWND;

  procedure NavigateDirect(const ACaption: string);
  begin
    LButton := FindChildByText(LWindow, ACaption);
    if LButton = 0 then
      Fail('Botao de navegacao nao encontrado: ' + ACaption);
    ClickWindowDirect(LButton);
  end;

  procedure CaptureNamed(const ARelativeName: string;
    const AScreenCapture: Boolean = True);
  var
    LPath: string;
  begin
    LPath := IncludeTrailingPathDelimiter(AOutputRoot) + ARelativeName;
    if AScreenCapture then
      CaptureScreenRegion(LWindow, LPath)
    else
      CapturePrintWindow(LWindow, LPath);
    Writeln('CAPTURE ' + LPath);
  end;

  procedure CaptureAllFamilies(const ASize, ATheme: string;
    const APhysicalMouse: Boolean);
  var
    J: Integer;
  begin
    for J := Low(Captions) to High(Captions) do
    begin
      LButton := FindChildByText(LWindow, Captions[J]);
      if LButton = 0 then
        Fail('Botao nao encontrado: ' + Captions[J]);
      if APhysicalMouse and (J < High(Captions)) then
        ClickChildPhysical(LWindow, LButton)
      else
        ClickWindowDirect(LButton);
      CaptureNamed(ASize + '\' + ATheme + '\' +
        Format('%.2d-%s-t0.png', [J + 1, Slugs[J]]));
    end;
  end;

begin
  StartDemo(AExePath);
  LWindow := RequireDemoWindow;
  ResizeClient(LWindow, 1200, 760);
  CaptureAllFamilies('1200x760', 'dark', True);

  NavigateDirect('Botoes');
  CaptureNamed('1200x760\dark\buttons-wheel-before.png');
  WheelClient(LWindow, 800, 520, -720);
  CaptureNamed('1200x760\dark\buttons-wheel-t0.png');
  WheelClient(LWindow, 800, 520, -2400);
  CaptureNamed('1200x760\dark\buttons-wheel-after.png');
  WheelClient(LWindow, 800, 520, 4000);

  NavigateDirect('Inputs');
  CaptureNamed('1200x760\dark\inputs-before.png');
  LInputNative := FindVisibleChildByClassInClient(LWindow, 'TMaskEdit');
  if LInputNative = 0 then
    Fail('Editor nativo TMaskEdit nao encontrado na pagina Inputs.');
  ClickChildPhysical(LWindow, LInputNative);
  RequireFocusedWindowClass(LWindow, 'TMaskEdit');
  CaptureNamed('1200x760\dark\inputs-after-focus.png');
  PressVirtualKey(LWindow, VK_TAB);
  PressVirtualKey(LWindow, VK_TAB);
  CaptureNamed('1200x760\dark\inputs-after-keyboard.png');

  NavigateDirect('Seletores');
  CaptureNamed('1200x760\dark\selectors-before.png');
  ClickClient(LWindow, 420, 184);
  CaptureNamed('1200x760\dark\selectors-combo-open.png', True);
  PressVirtualKey(LWindow, VK_ESCAPE);
  CaptureNamed('1200x760\dark\selectors-combo-esc.png', True);
  ClickClient(LWindow, 420, 184);
  PressVirtualKey(LWindow, VK_DOWN);
  PressVirtualKey(LWindow, VK_RETURN);
  CaptureNamed('1200x760\dark\selectors-combo-enter.png', True);
  ClickClient(LWindow, 580, 316);
  CaptureNamed('1200x760\dark\selectors-date-open.png', True);
  PressVirtualKey(LWindow, VK_ESCAPE);

  NavigateDirect('Grid');
  CaptureNamed('1200x760\dark\grid-before.png');
  ClickClient(LWindow, 520, 210);
  PressVirtualKey(LWindow, VK_DOWN);
  PressVirtualKey(LWindow, VK_RIGHT);
  PressVirtualKey(LWindow, VK_RETURN);
  TypeUnicodeText(LWindow, 'QA');
  CaptureNamed('1200x760\dark\grid-after-keyboard.png');
  WheelClient(LWindow, 760, 450, -600);
  CaptureNamed('1200x760\dark\grid-after-scroll.png');
  LButton := FindChildByText(LWindow, 'LG');
  if LButton <> 0 then
  begin
    ClickWindowDirect(LButton);
    CaptureNamed('1200x760\dark\grid-density-lg.png');
  end;

  LButton := FindThemeToggleButton(LWindow);
  if LButton = 0 then
    Fail('Toggle Tema claro nao encontrado.');
  ClickWindowDirect(LButton);
  CaptureAllFamilies('1200x760', 'light-requested', False);

  ResizeClient(LWindow, 520, 560);
  CaptureAllFamilies('520x560', 'light-requested', False);
  NavigateDirect('Botoes');
  CaptureNamed('520x560\light-requested\buttons-wheel-before.png');
  WheelClient(LWindow, 410, 470, -720);
  CaptureNamed('520x560\light-requested\buttons-wheel-t0.png');
  WheelClient(LWindow, 410, 470, -2400);
  CaptureNamed('520x560\light-requested\buttons-wheel-after.png');
  NavigateDirect('Seletores');
  ClickClient(LWindow, 390, 180);
  CaptureNamed('520x560\light-requested\selectors-popup-open.png', True);
  PressVirtualKey(LWindow, VK_ESCAPE);
  NavigateDirect('Grid');
  CaptureNamed('520x560\light-requested\grid-before.png');
  ClickClient(LWindow, 390, 205);
  PressVirtualKey(LWindow, VK_DOWN);
  PressVirtualKey(LWindow, VK_RETURN);
  CaptureNamed('520x560\light-requested\grid-after-keyboard.png');

  LButton := FindThemeToggleButton(LWindow);
  if LButton = 0 then
    Fail('Toggle Tema escuro nao encontrado.');
  ClickWindowDirect(LButton);
  CaptureAllFamilies('520x560', 'dark', False);

  PostMessage(LWindow, WM_CLOSE, 0, 0);
  Sleep(300);
  Writeln('PASS MATRIX');
end;

function DemoFixtureWindowProc(AWindow: HWND; AMessage: UINT;
  AWParam: WPARAM; ALParam: LPARAM): LRESULT; stdcall;
begin
  case AMessage of
    WM_CLOSE:
      begin
        DestroyWindow(AWindow);
        Exit(0);
      end;
    WM_DESTROY:
      begin
        PostQuitMessage(GDemoFixtureExitCode);
        Exit(0);
      end;
  end;
  Result := DefWindowProc(AWindow, AMessage, AWParam, ALParam);
end;

function RunDemoExitFixture(const AExitCode: Integer): Integer;
const
  FixtureClassName = 'TForm1';
var
  LAtom: ATOM;
  LMessage: TMsg;
  LWindow: HWND;
  LWindowClass: TWndClass;
begin
  Result := 255;
  GDemoFixtureExitCode := AExitCode;
  FillChar(LWindowClass, SizeOf(LWindowClass), 0);
  LWindowClass.style := CS_HREDRAW or CS_VREDRAW;
  LWindowClass.lpfnWndProc := @DemoFixtureWindowProc;
  LWindowClass.hInstance := HInstance;
  LWindowClass.hCursor := LoadCursor(0, IDC_ARROW);
  LWindowClass.hbrBackground := HBRUSH(COLOR_WINDOW + 1);
  LWindowClass.lpszClassName := FixtureClassName;
  LAtom := RegisterClass(LWindowClass);
  if LAtom = 0 then
  begin
    Writeln(ErrOutput,
      'DEMO_FIXTURE_STDERR RegisterClass failed: ' +
      SysErrorMessage(GetLastError));
    Exit;
  end;
  LWindow := 0;
  try
    LWindow := CreateWindowEx(0, FixtureClassName, DemoWindowTitle,
      WS_OVERLAPPEDWINDOW, 40, 40, 900, 640, 0, 0, HInstance, nil);
    if LWindow = 0 then
    begin
      Writeln(ErrOutput,
        'DEMO_FIXTURE_STDERR CreateWindowEx failed: ' +
        SysErrorMessage(GetLastError));
      Exit;
    end;
    ShowWindow(LWindow, SW_SHOW);
    UpdateWindow(LWindow);
    Writeln(Format(
      'DEMO_FIXTURE_STDOUT PID=%d HWND=%d ExitCode=%d',
      [GetCurrentProcessId, NativeInt(LWindow), AExitCode]));
    Writeln(ErrOutput, Format(
      'DEMO_FIXTURE_STDERR PID=%d PlannedExitCode=%d',
      [GetCurrentProcessId, AExitCode]));
    while GetMessage(LMessage, 0, 0, 0) do
    begin
      TranslateMessage(LMessage);
      DispatchMessage(LMessage);
    end;
    Result := AExitCode;
  finally
    if IsWindow(LWindow) then
      DestroyWindow(LWindow);
    UnregisterClass(FixtureClassName, HInstance);
  end;
end;

procedure RunDemoLifecycle(const AExePath, AOutputRoot: string;
  const AUseSystemClose, AExerciseDataAware: Boolean;
  const ANegativeMode: TLifecycleNegativeMode);
const
  ReadyTimeoutMs = 15000;
  ResponsiveTimeoutMs = 1500;
  StableIntervalMs = 2500;
var
  LCommandLine: string;
  LCloseMessage: UINT;
  LCloseName: string;
  LCloseWParam: WPARAM;
  LDemoBplPath: string;
  LDemoExitFailure: string;
  LEndTime: TSystemTime;
  LErrorHandle: THandle;
  LExitCode: DWORD;
  LFinalSaveError: string;
  LFinalSaveFailed: Boolean;
  LGateName: string;
  LInputHandle: THandle;
  LMapPath: string;
  LMessageResult: DWORD_PTR;
  LGateSucceeded: Boolean;
  LOutputHandle: THandle;
  LPassMessage: string;
  LProcessInfo: TProcessInformation;
  LProcessCreated: Boolean;
  LPrimaryFailure: Boolean;
  LPrimaryFailureText: string;
  LReadyStarted: DWORD;
  LRuntimeBplPath: string;
  LSkiaPath: string;
  LStageTarget: HWND;
  LStartedLocal: TDateTime;
  LStartTime: TSystemTime;
  LStartupInfo: TStartupInfo;
  LStderrPath: string;
  LStdoutPath: string;
  LTarget: HWND;
  LWait: DWORD;
  I: Integer;

  procedure RecordProcessExitAndFail(const AContext: string);
  var
    LPrimaryFailure: string;
  begin
    if not GetExitCodeProcess(LProcessInfo.hProcess, LExitCode) then
      LExitCode := DWORD(-1);
    LPrimaryFailure := AContext + '; ExitCode=' + IntToStr(LExitCode) +
      ' (0x' + IntToHex(LExitCode, 8) + '); StdoutPath="' +
      LStdoutPath + '"; StderrPath="' + LStderrPath + '".';
    GetSystemTime(LEndTime);
    LifecycleLog(Format(
      'PROCESS_EARLY_EXIT Context="%s" ExitCode=%d ExitHex=0x%s EndUtc=%s',
      [AContext, LExitCode, IntToHex(LExitCode, 8),
       SystemTimeToIso8601(LEndTime)]));
    Sleep(5000);
    RecordLifecycleFile('DEMO_STDOUT', LStdoutPath);
    RecordLifecycleFile('DEMO_STDERR', LStderrPath);
    CaptureWerEventsSecondary(LStartTime, LEndTime, AOutputRoot,
      LPrimaryFailure);
    PreserveCurrentCrashArtifacts(AExePath, AOutputRoot,
      LStartedLocal, LExitCode);
    LifecycleFail(LPrimaryFailure);
  end;

  procedure RequireProcessAlive(const AContext: string);
  begin
    if WaitForSingleObject(LProcessInfo.hProcess, 0) = WAIT_OBJECT_0 then
      RecordProcessExitAndFail(AContext);
  end;

  procedure RequireTargetSnapshot(const AStage: string);
  begin
    LStageTarget := EnumerateLifecycleWindows(AStage);
    RequireNoLifecycleModal(AStage);
    if GLifecycleTargetCount <> 1 then
      LifecycleFail(Format(
        '%s: esperado exatamente um TForm1 canonico; encontrados=%d.',
        [AStage, GLifecycleTargetCount]));
    if LStageTarget <> LTarget then
      LifecycleFail(Format(
        '%s: identidade do TForm1 mudou (%d -> %d).',
        [AStage, NativeInt(LTarget), NativeInt(LStageTarget)]));
  end;

  procedure CleanupStartedProcess;
  var
    LCleanupExitCode: DWORD;
    LCleanupMessageResult: DWORD_PTR;
    LCleanupTarget: HWND;
    LCleanupWait: DWORD;
  begin
    if not LProcessCreated or (LProcessInfo.hProcess = 0) then
      Exit;

    LCleanupWait := WaitForSingleObject(LProcessInfo.hProcess, 0);
    if LCleanupWait = WAIT_OBJECT_0 then
    begin
      if GetExitCodeProcess(LProcessInfo.hProcess, LCleanupExitCode) then
        LifecycleLog(Format(
          'CLEANUP_PROCESS_ALREADY_EXITED PID=%d ExitCode=%d GateSucceeded=%s',
          [LProcessInfo.dwProcessId, LCleanupExitCode,
           BoolToStr(LGateSucceeded, True)]))
      else
        LifecycleLog(Format(
          'CLEANUP_PROCESS_ALREADY_EXITED PID=%d ExitCode=UNAVAILABLE Error="%s" GateSucceeded=%s',
          [LProcessInfo.dwProcessId, SysErrorMessage(GetLastError),
           BoolToStr(LGateSucceeded, True)]));
      LifecycleLog('CLEANUP_RESIDUAL_PROCESS_COUNT=0');
      Exit;
    end;

    LifecycleLog(Format(
      'CLEANUP_BEGIN PID=%d GateSucceeded=%s ExactPidPolicy=True',
      [LProcessInfo.dwProcessId, BoolToStr(LGateSucceeded, True)]));
    try
      LCleanupTarget := EnumerateLifecycleWindows('cleanup-graceful');
      if (GLifecycleTargetCount = 1) and (LCleanupTarget <> 0) then
      begin
        LCleanupMessageResult := 0;
        LifecycleLog(Format(
          'CLEANUP_GRACEFUL_BEGIN PID=%d HWND=%d Message=WM_CLOSE TimeoutMs=2000',
          [LProcessInfo.dwProcessId, NativeInt(LCleanupTarget)]));
        if SendMessageTimeout(LCleanupTarget, WM_CLOSE, 0, 0,
          SMTO_ABORTIFHUNG or SMTO_BLOCK, 2000,
          @LCleanupMessageResult) <> 0 then
          LifecycleLog(Format(
            'CLEANUP_GRACEFUL_SIGNALLED PID=%d HWND=%d',
            [LProcessInfo.dwProcessId, NativeInt(LCleanupTarget)]))
        else
          LifecycleLog(Format(
            'CLEANUP_GRACEFUL_SIGNAL_FAILED PID=%d HWND=%d Error="%s"',
            [LProcessInfo.dwProcessId, NativeInt(LCleanupTarget),
             SysErrorMessage(GetLastError)]));
      end
      else
        LifecycleLog(Format(
          'CLEANUP_GRACEFUL_TARGET_UNAVAILABLE PID=%d TargetCount=%d',
          [LProcessInfo.dwProcessId, GLifecycleTargetCount]));
    except
      on E: Exception do
        LifecycleLog(Format(
          'CLEANUP_GRACEFUL_EXCEPTION PID=%d Exception=%s Message="%s"',
          [LProcessInfo.dwProcessId, E.ClassName,
           CleanWindowText(E.Message)]));
    end;

    LCleanupWait := WaitForSingleObject(LProcessInfo.hProcess, 5000);
    if LCleanupWait = WAIT_OBJECT_0 then
      LifecycleLog(Format(
        'CLEANUP_GRACEFUL_EXIT PID=%d WaitMs<=5000 NOT_A_GATE_SUCCESS',
        [LProcessInfo.dwProcessId]))
    else
    begin
      LifecycleLog(Format(
        'INFRASTRUCTURE_CLEANUP PID=%d Method=TerminateProcess ' +
        'Reason=GracefulTimeout NOT_A_GATE_SUCCESS OriginalFailurePreserved=True',
        [LProcessInfo.dwProcessId]));
      if TerminateProcess(LProcessInfo.hProcess, DWORD(-1)) then
      begin
        LCleanupWait := WaitForSingleObject(LProcessInfo.hProcess, 5000);
        LifecycleLog(Format(
          'INFRASTRUCTURE_CLEANUP_WAIT PID=%d Result=%d ' +
          'NOT_A_GATE_SUCCESS OriginalFailurePreserved=True',
          [LProcessInfo.dwProcessId, LCleanupWait]));
      end
      else
        LifecycleLog(Format(
          'INFRASTRUCTURE_CLEANUP_FAILED PID=%d Error="%s" ' +
          'NOT_A_GATE_SUCCESS OriginalFailurePreserved=True',
          [LProcessInfo.dwProcessId, SysErrorMessage(GetLastError)]));
    end;

    if WaitForSingleObject(LProcessInfo.hProcess, 0) = WAIT_OBJECT_0 then
      LifecycleLog('CLEANUP_RESIDUAL_PROCESS_COUNT=0')
    else
      LifecycleLog('CLEANUP_RESIDUAL_PROCESS_COUNT=1');
  end;

begin
  if not FileExists(AExePath) then
    Fail('Executavel nao encontrado: ' + AExePath);
  if not DirectoryExists(AOutputRoot) and
    not ForceDirectories(AOutputRoot) then
    Fail('Nao foi possivel criar output-root: ' + AOutputRoot);

  GLifecycleLog := TStringList.Create;
  GLifecycleLogPath := IncludeTrailingPathDelimiter(AOutputRoot) +
    'lifecycle.log';
  GAuxiliaryInjectionMode := aimNone;
  GAuxiliaryOutputAcquireCount := 0;
  GForceWerNonZeroExit := False;
  GInjectWerFailure := False;
  GLifecycleInjectSaveFailure := False;
  GLifecycleIsFinalSave := False;
  LFinalSaveError := '';
  LFinalSaveFailed := False;
  LDemoExitFailure := '';
  LPassMessage := '';
  LPrimaryFailure := False;
  LPrimaryFailureText := '';
  try
    try
    if ANegativeMode = lnmPostReadyFailure then
      LGateName := 'startlifecyclefail'
    else if ANegativeMode = lnmHelperFailure then
      LGateName := 'startlifecyclehelperfail'
    else if ANegativeMode = lnmHelperFailureWithSaveFailure then
      LGateName := 'startlifecyclesavefailoriginal'
    else if ANegativeMode = lnmFinalSaveFailure then
      LGateName := 'startlifecyclesavefail'
    else if ANegativeMode = lnmEnsureOutputFailure then
      LGateName := 'startlifecycleensureoutputfail'
    else if ANegativeMode = lnmPartialCreateFileFailure then
      LGateName := 'startlifecyclepartialfilefail'
    else if ANegativeMode = lnmAuxiliaryTimeout then
      LGateName := 'startlifecycleauxtimeout'
    else if ANegativeMode = lnmWerSecondaryWithPrimary then
      LGateName := 'startlifecyclewersecondaryfail'
    else if ANegativeMode = lnmWerFailureWithoutPrimary then
      LGateName := 'startlifecyclewerfail'
    else if ANegativeMode = lnmNominalDemoExitWithWerNonZero then
      LGateName := 'startlifecycledemoexitwerfail'
    else if ANegativeMode = lnmNominalWerNonZero then
      LGateName := 'startlifecyclewernonzero'
    else if AExerciseDataAware then
      LGateName := 'startdataawarexclose'
    else if AUseSystemClose then
      LGateName := 'startxclose'
    else
      LGateName := 'startlifecycle';
    if AUseSystemClose then
    begin
      LCloseMessage := WM_SYSCOMMAND;
      LCloseWParam := SC_CLOSE;
      LCloseName := 'WM_SYSCOMMAND/SC_CLOSE';
    end
    else
    begin
      LCloseMessage := WM_CLOSE;
      LCloseWParam := 0;
      LCloseName := 'WM_CLOSE';
    end;
    if ANegativeMode = lnmNominalDemoExitWithWerNonZero then
      LCommandLine := '"' + AExePath + '" demofixture 23'
    else
      LCommandLine := '"' + AExePath + '"';
    GForceWerNonZeroExit := ANegativeMode in
      [lnmNominalDemoExitWithWerNonZero, lnmNominalWerNonZero];
    LifecycleLog('GATE=' + LGateName);
    LifecycleLog('COMMAND_LINE="' + ParamStr(0) + '" ' +
      LGateName + ' "' +
      AExePath + '" "' + AOutputRoot + '"');
    LifecycleLog('DEMO_COMMAND_LINE=' + LCommandLine);
    LifecycleLog('DEMO_WORKING_DIRECTORY="' +
      ExcludeTrailingPathDelimiter(ExtractFilePath(AExePath)) + '"');
    LifecycleLog('TARGET_POLICY=PID+Class(TForm1)+Caption(' +
      DemoWindowTitle + ')+Visible+Enabled+ValidClientRect');
    LifecycleLog('MAIN_WINDOW_HANDLE_POLICY=PROHIBITED');
    LifecycleLog('TERMINATE_PROCESS_SUCCESS_POLICY=PROHIBITED');
    LifecycleLog('FORCED_CLEANUP_SCOPE=CONTROLLER_INFRASTRUCTURE_ONLY');
    if ANegativeMode <> lnmNone then
      LifecycleLog(
        'NEGATIVE_INJECTION_POLICY=CONTROLLER_ONLY_POST_READY_NOT_PRODUCT ' +
        'Mode=' + IntToStr(Ord(ANegativeMode)));
    if GForceWerNonZeroExit then
      LifecycleLog(
        'WER_NONZERO_POLICY=REAL_WEVTUTIL_SUBPROCESS ' +
        'SubprocessBypassed=False');

    LDemoBplPath := IncludeTrailingPathDelimiter(
      ExtractFilePath(AExePath)) + 'DACSkiaComponentsRuntime.bpl';
    LRuntimeBplPath := ExpandFileName(
      'Build\Packages\Win32\Debug\Bpl\DACSkiaComponentsRuntime.bpl');
    LSkiaPath := IncludeTrailingPathDelimiter(
      ExtractFilePath(AExePath)) + 'sk4d.dll';
    LMapPath := ChangeFileExt(AExePath, '.map');
    RecordLifecycleFile('DEMO_EXE', AExePath);
    RecordLifecycleFile('DEMO_RUNTIME_BPL', LDemoBplPath);
    RecordLifecycleFile('BUILD_RUNTIME_BPL', LRuntimeBplPath);
    RecordLifecycleFile('SKIA_RUNTIME', LSkiaPath);
    RecordLifecycleFile('DEMO_MAP', LMapPath);
    if FileExists(LDemoBplPath) and FileExists(LRuntimeBplPath) and
      not SameText(Sha256File(LDemoBplPath),
        Sha256File(LRuntimeBplPath)) then
      LifecycleFail('BPL da Demo diverge da BPL canonica de Build.');

    LStdoutPath := IncludeTrailingPathDelimiter(AOutputRoot) +
      'demo-stdout.txt';
    LStderrPath := IncludeTrailingPathDelimiter(AOutputRoot) +
      'demo-stderr.txt';
    LOutputHandle := 0;
    LErrorHandle := 0;
    LInputHandle := 0;
    FillChar(LProcessInfo, SizeOf(LProcessInfo), 0);
    LProcessCreated := False;
    LGateSucceeded := False;
    GetSystemTime(LStartTime);
    LStartedLocal := Now;
    LifecycleLog('START_UTC=' + SystemTimeToIso8601(LStartTime));
    try
      try
        LOutputHandle := CreateInheritedOutputFile(LStdoutPath);
        LErrorHandle := CreateInheritedOutputFile(LStderrPath);
        LInputHandle := CreateInheritedNullInput;
        FillChar(LStartupInfo, SizeOf(LStartupInfo), 0);
        LStartupInfo.cb := SizeOf(LStartupInfo);
        LStartupInfo.dwFlags := STARTF_USESTDHANDLES;
        LStartupInfo.hStdInput := LInputHandle;
        LStartupInfo.hStdOutput := LOutputHandle;
        LStartupInfo.hStdError := LErrorHandle;
        if not CreateProcess(PChar(AExePath), PChar(LCommandLine), nil, nil,
          True, 0, nil, PChar(ExtractFilePath(AExePath)), LStartupInfo,
          LProcessInfo) then
          LifecycleFail('CreateProcess Demo falhou: ' +
            SysErrorMessage(GetLastError));
        LProcessCreated := True;
      finally
        CloseOwnedHandle(LInputHandle);
        CloseOwnedHandle(LOutputHandle);
        CloseOwnedHandle(LErrorHandle);
      end;
      CloseOwnedHandle(LProcessInfo.hThread);
      GLifecycleProcessId := LProcessInfo.dwProcessId;
      LifecycleLog('PID=' + IntToStr(GLifecycleProcessId));
      LWait := WaitForInputIdle(LProcessInfo.hProcess, 10000);
      LifecycleLog('WAIT_FOR_INPUT_IDLE=' + IntToStr(LWait));
      LTarget := 0;
      LReadyStarted := GetTickCount;
      I := 0;
      repeat
        Inc(I);
        RequireProcessAlive('Demo encerrou antes do ready');
        LTarget := EnumerateLifecycleWindows('ready-' + IntToStr(I));
        RequireNoLifecycleModal('ready-' + IntToStr(I));
        if GLifecycleTargetCount > 1 then
          LifecycleFail('Mais de um TForm1 canonico foi encontrado.');
        if (GLifecycleTargetCount = 1) and (LTarget <> 0) then
          Break;
        Sleep(250);
      until GetTickCount - LReadyStarted >= ReadyTimeoutMs;
      if (LTarget = 0) or (GLifecycleTargetCount <> 1) then
        LifecycleFail('TForm1 canonico nao materializou em 15 segundos.');
      LifecycleLog('READY HWND=' + IntToStr(NativeInt(LTarget)) +
        ' ElapsedMs=' + IntToStr(GetTickCount - LReadyStarted));

      if ANegativeMode = lnmPostReadyFailure then
      begin
        LifecycleLog(
          'NEGATIVE_INJECTION Stage=post-ready Scope=controller-only');
        LifecycleFail(
          'INJECTED_POST_READY_FAILURE controller-only before nominal close');
      end;
      if ANegativeMode in [lnmHelperFailure,
        lnmHelperFailureWithSaveFailure] then
      begin
        LifecycleLog(
          'NEGATIVE_INJECTION Stage=post-ready Route=RequireFocusedWindowClass ' +
          'Scope=controller-only');
        if ANegativeMode = lnmHelperFailureWithSaveFailure then
        begin
          SaveLifecycleLog;
          GLifecycleInjectSaveFailure := True;
          LifecycleLog(
            'SAVE_FAILURE_INJECTION_ARMED WithOriginalFailure=True');
        end;
        RequireFocusedWindowClass(LTarget,
          '__DAC_CONTROLLER_EXPECTED_FOCUS_MISMATCH__');
      end;
      if ANegativeMode = lnmFinalSaveFailure then
      begin
        LifecycleLog(
          'SAVE_FAILURE_INJECTION_ARMED WithOriginalFailure=False ' +
          'Stage=post-ready');
        SaveLifecycleLog;
        GLifecycleInjectSaveFailure := True;
      end;
      if ANegativeMode in [lnmEnsureOutputFailure,
        lnmPartialCreateFileFailure, lnmAuxiliaryTimeout] then
      begin
        GAuxiliaryOutputAcquireCount := 0;
        if ANegativeMode = lnmEnsureOutputFailure then
          GAuxiliaryInjectionMode := aimEnsureOutputFailure
        else if ANegativeMode = lnmPartialCreateFileFailure then
          GAuxiliaryInjectionMode := aimSecondCreateFileFailure
        else
          GAuxiliaryInjectionMode := aimTimeout;
        LifecycleLog(Format(
          'NEGATIVE_INJECTION Stage=post-ready Route=RunCapturedProcess ' +
          'AuxMode=%d Scope=controller-only',
          [Ord(GAuxiliaryInjectionMode)]));
        RunCapturedProcess(ParamStr(0), 'auxwait',
          ExtractFilePath(ParamStr(0)),
          IncludeTrailingPathDelimiter(AOutputRoot) +
            'auxiliary-stdout.txt',
          IncludeTrailingPathDelimiter(AOutputRoot) +
            'auxiliary-stderr.txt', 200);
        LifecycleFail(
          'Gate auxiliar negativo retornou sem a falha esperada.');
      end;
      if ANegativeMode = lnmWerSecondaryWithPrimary then
      begin
        LifecycleLog(
          'NEGATIVE_INJECTION Stage=post-ready Route=CaptureWerEventsSecondary ' +
          'Scope=controller-only');
        GInjectWerFailure := True;
        GetSystemTime(LEndTime);
        CaptureWerEventsSecondary(LStartTime, LEndTime, AOutputRoot,
          'INJECTED_PRIMARY_FAILURE_WITH_WER_DIAGNOSTIC');
        GInjectWerFailure := False;
        LifecycleFail(
          'INJECTED_PRIMARY_FAILURE_WITH_WER_DIAGNOSTIC');
      end;
      if ANegativeMode = lnmWerFailureWithoutPrimary then
      begin
        LifecycleLog(
          'WER_FAILURE_INJECTION_ARMED PrimaryFailure=False ' +
          'Stage=post-ready');
        GInjectWerFailure := True;
      end;

      for I := 1 to 3 do
      begin
        if I > 1 then
          Sleep(StableIntervalMs);
        RequireProcessAlive('Demo encerrou durante estabilidade');
        RequireTargetSnapshot('probe-' + IntToStr(I));
        LMessageResult := 0;
        if SendMessageTimeout(LTarget, WM_NULL, 0, 0,
          SMTO_ABORTIFHUNG or SMTO_BLOCK, ResponsiveTimeoutMs,
          @LMessageResult) = 0 then
          LifecycleFail(Format(
            'probe-%d: TForm1 nao respondeu WM_NULL: %s.',
            [I, SysErrorMessage(GetLastError)]));
        LifecycleLog(Format(
          'RESPONSIVE Probe=%d HWND=%d WM_NULL_Result=%d ElapsedAfterReadyMs=%d',
          [I, NativeInt(LTarget), LMessageResult,
           GetTickCount - LReadyStarted]));
      end;
      if AExerciseDataAware then
      begin
        LifecycleLog('DATA_AWARE_SEQUENCE_BEGIN');
        ClickWindowDirect(FindChildByText(LTarget, 'Data-Aware'));
        Sleep(300);
        RequireTargetSnapshot('data-aware-page');
        // Select the visible ID 1008 row before entering edit mode, mirroring
        // the physical QA regression sequence.
        ClickClient(LTarget, 1040, 458);
        ClickWindowDirect(FindChildByText(LTarget, 'Editar'));
        Sleep(100);
        // Coordinates are relative to the canonical 1204x760 client used by
        // this lifecycle gate. The native Date editor receives focus first;
        // F4 opens its modeless Skia calendar through the real keyboard path.
        ClickClient(LTarget, 360, 385);
        PressVirtualKey(LTarget, VK_F4);
        Sleep(150);
        PressVirtualKey(LTarget, VK_ESCAPE);
        Sleep(100);
        ClickClient(LTarget, 1040, 458);
        PressVirtualKey(LTarget, VK_F2);
        RequireFocusedWindowClass(LTarget, 'TDBGridInplaceEdit');
        TypeUnicodeText(LTarget, 'X');
        LifecycleLog('DATA_AWARE_GRID_F2_EDITOR=VISIBLE_FOCUSED_TYPED');
        ClickWindowDirect(FindChildByText(LTarget, 'Cancelar'));
        Sleep(100);
        RequireTargetSnapshot('data-aware-after-cancel');
        LifecycleLog('DATA_AWARE_SEQUENCE_END');
      end;
      RequireProcessAlive('Demo encerrou antes do ' + LCloseName);
      LifecycleLog('CLOSE_TARGET HWND=' + IntToStr(NativeInt(LTarget)) +
        ' Message=' + LCloseName);
      LMessageResult := 0;
      if SendMessageTimeout(LTarget, LCloseMessage, LCloseWParam, 0,
        SMTO_ABORTIFHUNG or SMTO_BLOCK, 2000, @LMessageResult) = 0 then
        LifecycleFail(LCloseName + ' no TForm1 nao respondeu: ' +
          SysErrorMessage(GetLastError));
      LWait := WaitForSingleObject(LProcessInfo.hProcess, 5000);
      if LWait <> WAIT_OBJECT_0 then
        LifecycleFail('Demo nao encerrou em 5 segundos apos ' + LCloseName +
          '; gate falhou e o cleanup bounded de infraestrutura sera executado ' +
          'sem converter a falha em sucesso.');
      if not GetExitCodeProcess(LProcessInfo.hProcess, LExitCode) then
        LifecycleFail('GetExitCodeProcess Demo falhou: ' +
          SysErrorMessage(GetLastError));
      if IsWindow(LTarget) then
        LifecycleFail('TForm1 continuou valido apos o processo encerrar.');
      GetSystemTime(LEndTime);
      LifecycleLog('END_UTC=' + SystemTimeToIso8601(LEndTime));
      LifecycleLog('EXIT_CODE=' + IntToStr(LExitCode) +
        ' EXIT_HEX=0x' + IntToHex(LExitCode, 8));
      if LExitCode <> 0 then
      begin
        LDemoExitFailure := Format(
          'Demo encerrou por %s com ExitCode=%d ExitHex=0x%s; ' +
          'StdoutPath="%s"; StderrPath="%s".',
          [LCloseName, LExitCode, IntToHex(LExitCode, 8),
           LStdoutPath, LStderrPath]);
        LifecycleLog(
          'PRIMARY_FAILURE_ESTABLISHED Source=Demo Message="' +
          CleanWindowText(LDemoExitFailure) +
          '" BeforeWerDiagnostic=True');
      end;
      Sleep(5000);
      RecordLifecycleFile('DEMO_STDOUT', LStdoutPath);
      RecordLifecycleFile('DEMO_STDERR', LStderrPath);
      if LDemoExitFailure <> '' then
        CaptureWerEventsSecondary(LStartTime, LEndTime, AOutputRoot,
          LDemoExitFailure)
      else
        CaptureWerEvents(LStartTime, LEndTime, AOutputRoot);
      PreserveCurrentCrashArtifacts(AExePath, AOutputRoot,
        LStartedLocal, LExitCode);
      if LDemoExitFailure <> '' then
        LifecycleFail(LDemoExitFailure);
      LifecycleLog(Format(
        'FUNCTIONAL_GATE_COMPLETE Gate=%s PID=%d AwaitingFinalLogSave=True',
        [LGateName, GLifecycleProcessId]));
      LPassMessage := Format(
        'PASS %s PID=%d HWND=%d StableMs=%d ExitCode=0',
        [LGateName, GLifecycleProcessId, NativeInt(LTarget),
         GetTickCount - LReadyStarted]);
      if GLifecycleLog <> nil then
        GLifecycleLog.Add(LPassMessage);
      LGateSucceeded := True;
    finally
      try
        try
          CleanupStartedProcess;
        except
          on E: Exception do
            Writeln('CLEANUP_UNHANDLED_EXCEPTION PID=' +
              IntToStr(LProcessInfo.dwProcessId) + ' Exception=' +
              E.ClassName + ' Message="' + CleanWindowText(E.Message) +
              '" OriginalFailurePreserved=True');
        end;
      finally
        CloseOwnedHandle(LProcessInfo.hThread);
        CloseOwnedHandle(LProcessInfo.hProcess);
      end;
    end;
    except
      on E: Exception do
      begin
        LPrimaryFailure := True;
        LPrimaryFailureText := E.ClassName + ': ' + E.Message;
        raise;
      end;
    end;
  finally
    GLifecycleIsFinalSave := True;
    try
      try
        SaveLifecycleLog;
      except
        on E: Exception do
        begin
          LFinalSaveFailed := True;
          LFinalSaveError := E.ClassName + ': ' + E.Message;
          Writeln('FINAL_LIFECYCLE_LOG_SAVE_FAILED Error="' +
            CleanWindowText(LFinalSaveError) +
            '" PrimaryFailure=' + BoolToStr(LPrimaryFailure, True) +
            ' Primary="' + CleanWindowText(LPrimaryFailureText) +
            '" OriginalFailurePreserved=' +
            BoolToStr(LPrimaryFailure, True) +
            ' CleanupCompleted=True');
        end;
      end;
    finally
      GLifecycleIsFinalSave := False;
      GLifecycleInjectSaveFailure := False;
      GAuxiliaryInjectionMode := aimNone;
      GAuxiliaryOutputAcquireCount := 0;
      GForceWerNonZeroExit := False;
      GInjectWerFailure := False;
      GLifecycleLog.Free;
      GLifecycleLog := nil;
      GLifecycleLogPath := '';
      GLifecycleProcessId := 0;
    end;
  end;
  if LFinalSaveFailed then
    raise ELifecycleFailure.Create(
      'FINAL_LIFECYCLE_LOG_SAVE_FAILURE after cleanup: ' +
      LFinalSaveError);
  if LPassMessage <> '' then
    Writeln(LPassMessage);
end;

procedure CloseCanonicalProcessById(const AProcessId: DWORD);
var
  LExitCode: DWORD;
  LMessageResult: DWORD_PTR;
  LProcess: THandle;
  LTarget: HWND;
begin
  LProcess := OpenProcess(SYNCHRONIZE or PROCESS_QUERY_INFORMATION,
    False, AProcessId);
  if LProcess = 0 then
    Fail('OpenProcess read/synchronize falhou para PID ' +
      IntToStr(AProcessId) + ': ' + SysErrorMessage(GetLastError));
  try
    GLifecycleProcessId := AProcessId;
    LTarget := EnumerateLifecycleWindows('closecanonicalpid');
    RequireNoLifecycleModal('closecanonicalpid');
    if (GLifecycleTargetCount <> 1) or (LTarget = 0) then
      Fail(Format(
        'PID %d nao possui exatamente um TForm1 canonico (count=%d).',
        [AProcessId, GLifecycleTargetCount]));
    LMessageResult := 0;
    if SendMessageTimeout(LTarget, WM_CLOSE, 0, 0,
      SMTO_ABORTIFHUNG or SMTO_BLOCK, 2000, @LMessageResult) = 0 then
      Fail('WM_CLOSE no TForm1 do PID ' + IntToStr(AProcessId) +
        ' falhou: ' + SysErrorMessage(GetLastError));
    if WaitForSingleObject(LProcess, 5000) <> WAIT_OBJECT_0 then
      Fail('PID ' + IntToStr(AProcessId) +
        ' nao encerrou por WM_CLOSE em 5 segundos.');
    if not GetExitCodeProcess(LProcess, LExitCode) then
      Fail('GetExitCodeProcess falhou: ' +
        SysErrorMessage(GetLastError));
    if LExitCode <> 0 then
      Fail('PID ' + IntToStr(AProcessId) +
        ' encerrou com exit code ' + IntToStr(LExitCode) + '.');
  finally
    GLifecycleProcessId := 0;
    CloseHandle(LProcess);
  end;
  Writeln(Format(
    'PASS closecanonicalpid PID=%d HWND=%d ExitCode=0',
    [AProcessId, NativeInt(LTarget)]));
end;

procedure Usage;
begin
  Writeln('Uso: DACPhysicalQAController <comando> [args]');
  Writeln('  start <Demo.exe>');
  Writeln('  startlifecycle <Demo.exe> <output-root>');
  Writeln('  startlifecyclefail <Demo.exe> <output-root>');
  Writeln('  startlifecyclehelperfail <Demo.exe> <output-root>');
  Writeln('  startlifecyclesavefailoriginal <Demo.exe> <output-root>');
  Writeln('  startlifecyclesavefail <Demo.exe> <output-root>');
  Writeln('  startlifecycleensureoutputfail <Demo.exe> <output-root>');
  Writeln('  startlifecyclepartialfilefail <Demo.exe> <output-root>');
  Writeln('  startlifecycleauxtimeout <Demo.exe> <output-root>');
  Writeln('  startlifecyclewersecondaryfail <Demo.exe> <output-root>');
  Writeln('  startlifecyclewerfail <Demo.exe> <output-root>');
  Writeln('  startlifecycledemoexitwerfail <output-root>');
  Writeln('  startlifecyclewernonzero <Demo.exe> <output-root>');
  Writeln('  startxclose <Demo.exe> <output-root>');
  Writeln('  startdataawarexclose <Demo.exe> <output-root>');
  Writeln('  startdataawarewheel <Demo.exe> <output-root>');
  Writeln('  closecanonicalpid <pid>');
  Writeln('  startcapture <Demo.exe> <clientWidth> <clientHeight> <arquivo.png>');
  Writeln('  startinspect <Demo.exe> <clientWidth> <clientHeight>');
  Writeln('  startinspectfamily <Demo.exe> <clientWidth> <clientHeight> <sidebar-caption>');
  Writeln('  startrepaintfamily <Demo.exe> <clientWidth> <clientHeight> <sidebar-caption> <before.png> <after.png>');
  Writeln('  startscreenfamily <Demo.exe> <clientWidth> <clientHeight> <sidebar-caption> <screen.png>');
  Writeln('  startscreenfamilyclick <Demo.exe> <clientWidth> <clientHeight> <sidebar-caption> <x> <y> <screen.png>');
  Writeln('  starttheme <Demo.exe> <clientWidth> <clientHeight> <before.png> <after.png>');
  Writeln('  startthemecycle <Demo.exe> <clientWidth> <clientHeight> <dark-before.png> <light.png> <dark-after.png>');
  Writeln('  status');
  Writeln('  resize <clientWidth> <clientHeight>');
  Writeln('  capture <arquivo.png>');
  Writeln('  screen <arquivo.png>');
  Writeln('  click <x> <y>');
  Writeln('  wheel <x> <y> <delta>');
  Writeln('  key <virtual-key>');
  Writeln('  text <texto>');
  Writeln('  terminatepid <pid>');
  Writeln('  runmatrix <Demo.exe> <output-root>');
end;

procedure TerminateProcessById(const AProcessId: DWORD);
var
  LProcess: THandle;
begin
  LProcess := OpenProcess(PROCESS_TERMINATE or SYNCHRONIZE, False,
    AProcessId);
  if LProcess = 0 then
    Fail('OpenProcess falhou para PID ' + IntToStr(AProcessId) + ': ' +
      SysErrorMessage(GetLastError));
  try
    if not TerminateProcess(LProcess, 0) then
      Fail('TerminateProcess falhou: ' + SysErrorMessage(GetLastError));
    if WaitForSingleObject(LProcess, 5000) <> WAIT_OBJECT_0 then
      Fail('PID nao encerrou em 5 segundos.');
  finally
    CloseHandle(LProcess);
  end;
  Writeln('INFRASTRUCTURE_CLEANUP PID=' + IntToStr(AProcessId) +
    ' Method=TerminateProcess NOT_A_GATE_SUCCESS');
end;

var
  LCommand: string;
  LWindow: HWND;
begin
  try
    if ParamCount = 0 then
    begin
      Usage;
      Halt(2);
    end;
    LCommand := LowerCase(ParamStr(1));
    if LCommand = 'auxwait' then
    begin
      Sleep(30000);
      Halt(0);
    end;
    if LCommand = 'demofixture' then
    begin
      if ParamCount < 2 then
        Fail('Informe o exit code da Demo fixture.');
      Halt(RunDemoExitFixture(StrToInt(ParamStr(2))));
    end;
    if LCommand = 'terminatepid' then
    begin
      if ParamCount < 2 then
        Fail('Informe o PID.');
      TerminateProcessById(StrToInt(ParamStr(2)));
      Halt(0);
    end;
    if LCommand = 'closecanonicalpid' then
    begin
      if ParamCount < 2 then
        Fail('Informe o PID.');
      CloseCanonicalProcessById(StrToInt(ParamStr(2)));
      Halt(0);
    end;
    if LCommand = 'runmatrix' then
    begin
      if ParamCount < 3 then
        Fail('Informe Demo.exe e output-root.');
      RunPhysicalMatrix(ExpandFileName(ParamStr(2)),
        ExpandFileName(ParamStr(3)));
      Halt(0);
    end;
    if LCommand = 'start' then
    begin
      if ParamCount < 2 then
        Fail('Informe o caminho do Demo.exe.');
      StartDemo(ExpandFileName(ParamStr(2)));
      Halt(0);
    end;
    if LCommand = 'startlifecycle' then
    begin
      if ParamCount < 3 then
        Fail('Informe Demo.exe e output-root.');
      RunDemoLifecycle(ExpandFileName(ParamStr(2)),
        ExpandFileName(ParamStr(3)), False, False, lnmNone);
      Halt(0);
    end;
    if LCommand = 'startlifecyclefail' then
    begin
      if ParamCount < 3 then
        Fail('Informe Demo.exe e output-root.');
      RunDemoLifecycle(ExpandFileName(ParamStr(2)),
        ExpandFileName(ParamStr(3)), False, False,
        lnmPostReadyFailure);
      Halt(0);
    end;
    if LCommand = 'startlifecyclehelperfail' then
    begin
      if ParamCount < 3 then
        Fail('Informe Demo.exe e output-root.');
      RunDemoLifecycle(ExpandFileName(ParamStr(2)),
        ExpandFileName(ParamStr(3)), False, False,
        lnmHelperFailure);
      Halt(0);
    end;
    if LCommand = 'startlifecyclesavefailoriginal' then
    begin
      if ParamCount < 3 then
        Fail('Informe Demo.exe e output-root.');
      RunDemoLifecycle(ExpandFileName(ParamStr(2)),
        ExpandFileName(ParamStr(3)), False, False,
        lnmHelperFailureWithSaveFailure);
      Halt(0);
    end;
    if LCommand = 'startlifecyclesavefail' then
    begin
      if ParamCount < 3 then
        Fail('Informe Demo.exe e output-root.');
      RunDemoLifecycle(ExpandFileName(ParamStr(2)),
        ExpandFileName(ParamStr(3)), False, False,
        lnmFinalSaveFailure);
      Halt(0);
    end;
    if LCommand = 'startlifecycleensureoutputfail' then
    begin
      if ParamCount < 3 then
        Fail('Informe Demo.exe e output-root.');
      RunDemoLifecycle(ExpandFileName(ParamStr(2)),
        ExpandFileName(ParamStr(3)), False, False,
        lnmEnsureOutputFailure);
      Halt(0);
    end;
    if LCommand = 'startlifecyclepartialfilefail' then
    begin
      if ParamCount < 3 then
        Fail('Informe Demo.exe e output-root.');
      RunDemoLifecycle(ExpandFileName(ParamStr(2)),
        ExpandFileName(ParamStr(3)), False, False,
        lnmPartialCreateFileFailure);
      Halt(0);
    end;
    if LCommand = 'startlifecycleauxtimeout' then
    begin
      if ParamCount < 3 then
        Fail('Informe Demo.exe e output-root.');
      RunDemoLifecycle(ExpandFileName(ParamStr(2)),
        ExpandFileName(ParamStr(3)), False, False,
        lnmAuxiliaryTimeout);
      Halt(0);
    end;
    if LCommand = 'startlifecyclewersecondaryfail' then
    begin
      if ParamCount < 3 then
        Fail('Informe Demo.exe e output-root.');
      RunDemoLifecycle(ExpandFileName(ParamStr(2)),
        ExpandFileName(ParamStr(3)), False, False,
        lnmWerSecondaryWithPrimary);
      Halt(0);
    end;
    if LCommand = 'startlifecyclewerfail' then
    begin
      if ParamCount < 3 then
        Fail('Informe Demo.exe e output-root.');
      RunDemoLifecycle(ExpandFileName(ParamStr(2)),
        ExpandFileName(ParamStr(3)), False, False,
        lnmWerFailureWithoutPrimary);
      Halt(0);
    end;
    if LCommand = 'startlifecycledemoexitwerfail' then
    begin
      if ParamCount < 2 then
        Fail('Informe output-root.');
      RunDemoLifecycle(ExpandFileName(ParamStr(0)),
        ExpandFileName(ParamStr(2)), False, False,
        lnmNominalDemoExitWithWerNonZero);
      Halt(0);
    end;
    if LCommand = 'startlifecyclewernonzero' then
    begin
      if ParamCount < 3 then
        Fail('Informe Demo.exe e output-root.');
      RunDemoLifecycle(ExpandFileName(ParamStr(2)),
        ExpandFileName(ParamStr(3)), False, False,
        lnmNominalWerNonZero);
      Halt(0);
    end;
    if LCommand = 'startxclose' then
    begin
      if ParamCount < 3 then
        Fail('Informe Demo.exe e output-root.');
      RunDemoLifecycle(ExpandFileName(ParamStr(2)),
        ExpandFileName(ParamStr(3)), True, False, lnmNone);
      Halt(0);
    end;
    if LCommand = 'startdataawarexclose' then
    begin
      if ParamCount < 3 then
        Fail('Informe Demo.exe e output-root.');
      RunDemoLifecycle(ExpandFileName(ParamStr(2)),
        ExpandFileName(ParamStr(3)), True, True, lnmNone);
      Halt(0);
    end;
    if LCommand = 'startdataawarewheel' then
    begin
      if ParamCount < 3 then
        Fail('Informe Demo.exe e output-root.');
      RunDataAwarePhysicalWheelGate(ExpandFileName(ParamStr(2)),
        ExpandFileName(ParamStr(3)));
      Halt(0);
    end;
    if LCommand = 'startcapture' then
    begin
      if ParamCount < 5 then
        Fail('Informe Demo.exe, largura, altura e PNG.');
      StartDemo(ExpandFileName(ParamStr(2)));
      LWindow := RequireDemoWindow;
      ResizeClient(LWindow, StrToInt(ParamStr(3)), StrToInt(ParamStr(4)));
      CapturePrintWindow(LWindow, ExpandFileName(ParamStr(5)));
      PrintStatus(LWindow);
      Writeln('PASS ' + ExpandFileName(ParamStr(5)));
      Halt(0);
    end;
    if LCommand = 'startinspect' then
    begin
      if ParamCount < 4 then
        Fail('Informe Demo.exe, largura e altura.');
      StartDemo(ExpandFileName(ParamStr(2)));
      LWindow := RequireDemoWindow;
      ResizeClient(LWindow, StrToInt(ParamStr(3)), StrToInt(ParamStr(4)));
      PrintStatus(LWindow);
      PrintChildWindows(LWindow);
      Halt(0);
    end;
    if LCommand = 'startinspectfamily' then
    begin
      if ParamCount < 5 then
        Fail('Informe Demo.exe, largura, altura e caption da familia.');
      StartDemo(ExpandFileName(ParamStr(2)));
      LWindow := RequireDemoWindow;
      ResizeClient(LWindow, StrToInt(ParamStr(3)), StrToInt(ParamStr(4)));
      ClickWindowDirect(FindChildByText(LWindow, ParamStr(5)));
      PrintStatus(LWindow);
      PrintChildWindows(LWindow);
      PostMessage(LWindow, WM_CLOSE, 0, 0);
      Sleep(300);
      Halt(0);
    end;
    if LCommand = 'startrepaintfamily' then
    begin
      if ParamCount < 7 then
        Fail('Informe Demo.exe, largura, altura, familia e dois PNGs.');
      StartDemo(ExpandFileName(ParamStr(2)));
      LWindow := RequireDemoWindow;
      ResizeClient(LWindow, StrToInt(ParamStr(3)), StrToInt(ParamStr(4)));
      ClickWindowDirect(FindChildByText(LWindow, ParamStr(5)));
      CapturePrintWindow(LWindow, ExpandFileName(ParamStr(6)));
      RedrawWindow(LWindow, nil, 0, RDW_INVALIDATE or RDW_ERASE or
        RDW_ALLCHILDREN or RDW_UPDATENOW);
      Sleep(200);
      CapturePrintWindow(LWindow, ExpandFileName(ParamStr(7)));
      PostMessage(LWindow, WM_CLOSE, 0, 0);
      Sleep(300);
      Halt(0);
    end;
    if LCommand = 'startscreenfamily' then
    begin
      if ParamCount < 6 then
        Fail('Informe Demo.exe, largura, altura, familia e PNG.');
      StartDemo(ExpandFileName(ParamStr(2)));
      LWindow := RequireDemoWindow;
      ResizeClient(LWindow, StrToInt(ParamStr(3)), StrToInt(ParamStr(4)));
      ClickWindowDirect(FindChildByText(LWindow, ParamStr(5)));
      CaptureScreenRegion(LWindow, ExpandFileName(ParamStr(6)));
      PostMessage(LWindow, WM_CLOSE, 0, 0);
      Sleep(300);
      Halt(0);
    end;
    if LCommand = 'startscreenfamilyclick' then
    begin
      if ParamCount < 8 then
        Fail('Informe Demo.exe, largura, altura, familia, x, y e PNG.');
      StartDemo(ExpandFileName(ParamStr(2)));
      LWindow := RequireDemoWindow;
      ResizeClient(LWindow, StrToInt(ParamStr(3)), StrToInt(ParamStr(4)));
      ClickWindowDirect(FindChildByText(LWindow, ParamStr(5)));
      ClickClient(LWindow, StrToInt(ParamStr(6)), StrToInt(ParamStr(7)));
      CaptureScreenRegion(LWindow, ExpandFileName(ParamStr(8)));
      PostMessage(LWindow, WM_CLOSE, 0, 0);
      Sleep(300);
      Halt(0);
    end;
    if LCommand = 'starttheme' then
    begin
      if ParamCount < 6 then
        Fail('Informe Demo.exe, largura, altura, before.png e after.png.');
      StartDemo(ExpandFileName(ParamStr(2)));
      LWindow := RequireDemoWindow;
      ResizeClient(LWindow, StrToInt(ParamStr(3)), StrToInt(ParamStr(4)));
      CapturePrintWindow(LWindow, ExpandFileName(ParamStr(5)));
      ClickWindowDirect(FindChildByText(LWindow, 'Tema claro'));
      CapturePrintWindow(LWindow, ExpandFileName(ParamStr(6)));
      Writeln('THEME_CHILD_AFTER=' +
        IntToStr(FindChildByText(LWindow, 'Tema escuro')));
      PrintStatus(LWindow);
      Halt(0);
    end;
    if LCommand = 'startthemecycle' then
    begin
      if ParamCount < 7 then
        Fail('Informe Demo.exe, largura, altura e os tres PNGs.');
      StartDemo(ExpandFileName(ParamStr(2)));
      LWindow := RequireDemoWindow;
      ResizeClient(LWindow, StrToInt(ParamStr(3)), StrToInt(ParamStr(4)));
      CapturePrintWindow(LWindow, ExpandFileName(ParamStr(5)));
      ClickWindowDirect(FindChildByText(LWindow, 'Tema claro'));
      CapturePrintWindow(LWindow, ExpandFileName(ParamStr(6)));
      ClickWindowDirect(FindChildByText(LWindow, 'Tema escuro'));
      CapturePrintWindow(LWindow, ExpandFileName(ParamStr(7)));
      PrintStatus(LWindow);
      PostMessage(LWindow, WM_CLOSE, 0, 0);
      Sleep(300);
      Writeln('PASS THEME CYCLE');
      Halt(0);
    end;
    LWindow := RequireDemoWindow;
    if LCommand = 'status' then
      PrintStatus(LWindow)
    else if LCommand = 'resize' then
    begin
      ResizeClient(LWindow, StrToInt(ParamStr(2)), StrToInt(ParamStr(3)));
      PrintStatus(LWindow);
    end
    else if LCommand = 'capture' then
    begin
      CapturePrintWindow(LWindow, ExpandFileName(ParamStr(2)));
      Writeln('PASS ' + ExpandFileName(ParamStr(2)));
    end
    else if LCommand = 'screen' then
    begin
      CaptureScreenRegion(LWindow, ExpandFileName(ParamStr(2)));
      Writeln('PASS ' + ExpandFileName(ParamStr(2)));
    end
    else if LCommand = 'click' then
      ClickClient(LWindow, StrToInt(ParamStr(2)), StrToInt(ParamStr(3)))
    else if LCommand = 'wheel' then
      WheelClient(LWindow, StrToInt(ParamStr(2)), StrToInt(ParamStr(3)),
        StrToInt(ParamStr(4)))
    else if LCommand = 'key' then
      PressVirtualKey(LWindow, StrToInt(ParamStr(2)))
    else if LCommand = 'text' then
      TypeUnicodeText(LWindow, ParamStr(2))
    else
      Fail('Comando desconhecido: ' + LCommand);
  except
    on E: Exception do
      Fail(E.ClassName + ': ' + E.Message);
  end;
end.
