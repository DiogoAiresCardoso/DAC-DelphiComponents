unit DAC.Components.Controls.NativeWindowTheme;

interface

uses
  Winapi.Windows,
  Vcl.Controls,
  Vcl.Graphics,
  DAC.Components.DesignSystem.Theme;

type
  TDACNativeScrollBarHookTicket = NativeUInt;

procedure ApplyDACNativeClientPalette(const AControl: TWinControl;
  const AMode: TDACThemeMode; const ABackground, AText: TColor);
procedure ApplyDACNativeScrollBarTheme(const AControl: TWinControl;
  const AMode: TDACThemeMode);
procedure ResetDACNativeScrollBarTheme(const AControl: TWinControl);
function AcquireDACNativeScrollBarHookAuthority(
  const AControl: TWinControl): TDACNativeScrollBarHookTicket;
procedure ReleaseDACNativeScrollBarHookAuthority(const AWindow: HWND;
  var ATicket: TDACNativeScrollBarHookTicket);
function DACNativeScrollBarHookAuthorityCount(
  const AWindow: HWND): Integer;
function DACNativeScrollBarHookAuthorityTotalCount: Integer;
procedure PaintDACNativeScrollBarTheme(const AControl: TWinControl;
  const AMode: TDACThemeMode; const ADC: HDC);

implementation

uses
  System.Classes,
  System.SysUtils,
  Winapi.UxTheme,
  DAC.Components.DesignSystem.ComponentStyle,
  DAC.Components.Hooks.ScrollRenderer;

type
  TDACNativeControlAccess = class(TControl);

  PDACScrollBarHookAuthority = ^TDACScrollBarHookAuthority;
  TDACScrollBarHookAuthority = record
    Window: HWND;
    Ticket: TDACNativeScrollBarHookTicket;
  end;

var
  GDACScrollBarHookAuthorities: TList;
  GDACScrollBarHookAuthorityLock: TRTLCriticalSection;
  GDACNextScrollBarHookTicket: TDACNativeScrollBarHookTicket;

function DACScrollBarHookTicketExists(
  const ATicket: TDACNativeScrollBarHookTicket): Boolean;
var
  I: Integer;
begin
  Result := False;
  for I := 0 to GDACScrollBarHookAuthorities.Count - 1 do
    if PDACScrollBarHookAuthority(
        GDACScrollBarHookAuthorities[I])^.Ticket = ATicket then
      Exit(True);
end;

function DACNextScrollBarHookTicket: TDACNativeScrollBarHookTicket;
begin
  repeat
    if GDACNextScrollBarHookTicket = High(TDACNativeScrollBarHookTicket) then
      GDACNextScrollBarHookTicket := 1
    else
      Inc(GDACNextScrollBarHookTicket);
  until (GDACNextScrollBarHookTicket <> 0) and
    not DACScrollBarHookTicketExists(GDACNextScrollBarHookTicket);
  Result := GDACNextScrollBarHookTicket;
end;

procedure ApplyDACNativeClientPalette(const AControl: TWinControl;
  const AMode: TDACThemeMode; const ABackground, AText: TColor);
var
  LMode: TDACThemeMode;
begin
  if (AControl = nil) or (csDestroying in AControl.ComponentState) or
    (AControl.Parent = nil) or not AControl.HandleAllocated then
    Exit;
  LMode := TDACThemeManager.ResolveMode(AMode);
  if LMode = dtmDark then
    { Disable only this HWND's system visual theme. Native edit/combo/date
      windows then honor their VCL Color brush while Windows keeps ownership
      of text, selection, caret, IME, clipboard and popup behavior. }
    SetWindowTheme(AControl.Handle, PWideChar(''), PWideChar(''))
  else
    SetWindowTheme(AControl.Handle, nil, nil);
  TDACNativeControlAccess(AControl).ParentColor := False;
  TDACNativeControlAccess(AControl).ParentFont := False;
  TDACNativeControlAccess(AControl).Color := ABackground;
  TDACNativeControlAccess(AControl).Font.Color := AText;
  RedrawWindow(AControl.Handle, nil, 0, RDW_INVALIDATE or RDW_FRAME);
end;

procedure ApplyDACNativeScrollBarTheme(const AControl: TWinControl;
  const AMode: TDACThemeMode);
begin
  if (AControl = nil) or (csDestroying in AControl.ComponentState) or
    (AControl.Parent = nil) or not AControl.HandleAllocated then
    Exit;
  { The system-style fallback is painted after native WM_NCPAINT by the DAC
    control itself. No OS theme, process state or scrollbar subclass changes. }
  RedrawWindow(AControl.Handle, nil, 0, RDW_INVALIDATE or RDW_FRAME);
end;

procedure ResetDACNativeScrollBarTheme(const AControl: TWinControl);
begin
  if (AControl = nil) or not AControl.HandleAllocated then
    Exit;
  RedrawWindow(AControl.Handle, nil, 0, RDW_INVALIDATE or RDW_FRAME);
end;

function AcquireDACNativeScrollBarHookAuthority(
  const AControl: TWinControl): TDACNativeScrollBarHookTicket;
var
  LAuthority: PDACScrollBarHookAuthority;
  LWindow: HWND;
begin
  Result := 0;
  if (AControl = nil) or not AControl.HandleAllocated then
    Exit;
  LWindow := AControl.Handle;
  if not IsWindow(LWindow) then
    Exit;
  EnterCriticalSection(GDACScrollBarHookAuthorityLock);
  try
    if GDACScrollBarHookAuthorities.Count = MaxInt then
      raise EOutOfMemory.Create(
        'Native scrollbar StyleHook authority registry exhausted.');
    New(LAuthority);
    try
      LAuthority^.Window := LWindow;
      LAuthority^.Ticket := DACNextScrollBarHookTicket;
      GDACScrollBarHookAuthorities.Add(LAuthority);
      Result := LAuthority^.Ticket;
    except
      Dispose(LAuthority);
      raise;
    end;
  finally
    LeaveCriticalSection(GDACScrollBarHookAuthorityLock);
  end;
  RedrawWindow(LWindow, nil, 0, RDW_INVALIDATE or RDW_FRAME);
end;

procedure ReleaseDACNativeScrollBarHookAuthority(const AWindow: HWND;
  var ATicket: TDACNativeScrollBarHookTicket);
var
  LAuthority: PDACScrollBarHookAuthority;
  I: Integer;
begin
  if ATicket = 0 then
    Exit;
  EnterCriticalSection(GDACScrollBarHookAuthorityLock);
  try
    for I := GDACScrollBarHookAuthorities.Count - 1 downto 0 do
    begin
      LAuthority := PDACScrollBarHookAuthority(
        GDACScrollBarHookAuthorities[I]);
      if (LAuthority^.Window = AWindow) and
        (LAuthority^.Ticket = ATicket) then
      begin
        GDACScrollBarHookAuthorities.Delete(I);
        Dispose(LAuthority);
        Break;
      end;
    end;
    { A ticket is single-use even if its HWND was already destroyed or the
      registry entry was no longer present. Releasing it twice can never
      decrement another hook's authority. }
    ATicket := 0;
  finally
    LeaveCriticalSection(GDACScrollBarHookAuthorityLock);
  end;
  if IsWindow(AWindow) then
    RedrawWindow(AWindow, nil, 0, RDW_INVALIDATE or RDW_FRAME);
end;

function DACNativeScrollBarHookAuthorityCount(
  const AWindow: HWND): Integer;
var
  I: Integer;
begin
  Result := 0;
  if AWindow = 0 then
    Exit;
  EnterCriticalSection(GDACScrollBarHookAuthorityLock);
  try
    for I := 0 to GDACScrollBarHookAuthorities.Count - 1 do
      if PDACScrollBarHookAuthority(
          GDACScrollBarHookAuthorities[I])^.Window = AWindow then
      begin
        if Result = MaxInt then
          raise EOutOfMemory.Create(
            'Native scrollbar StyleHook authority count overflow.');
        Inc(Result);
      end;
  finally
    LeaveCriticalSection(GDACScrollBarHookAuthorityLock);
  end;
end;

function DACNativeScrollBarHookAuthorityTotalCount: Integer;
begin
  EnterCriticalSection(GDACScrollBarHookAuthorityLock);
  try
    Result := GDACScrollBarHookAuthorities.Count;
  finally
    LeaveCriticalSection(GDACScrollBarHookAuthorityLock);
  end;
end;

procedure PaintDACNativeScrollBarTheme(const AControl: TWinControl;
  const AMode: TDACThemeMode; const ADC: HDC);
begin
  if (AControl = nil) or (ADC = 0) or
    (csDestroying in AControl.ComponentState) or
    not AControl.HandleAllocated or
    (DACNativeScrollBarHookAuthorityCount(AControl.Handle) <> 0) then
    Exit;
  DAC.Components.Hooks.ScrollRenderer.PaintDACNativeScrollBars(AControl, ADC,
    TDACComponentStyle.ResolveForSurface(AControl, AMode).Tokens.Controls);
end;

procedure ClearDACScrollBarHookAuthorities;
var
  LAuthority: PDACScrollBarHookAuthority;
  I: Integer;
begin
  for I := GDACScrollBarHookAuthorities.Count - 1 downto 0 do
  begin
    LAuthority := PDACScrollBarHookAuthority(
      GDACScrollBarHookAuthorities[I]);
    Dispose(LAuthority);
  end;
  GDACScrollBarHookAuthorities.Clear;
end;

initialization
  InitializeCriticalSection(GDACScrollBarHookAuthorityLock);
  GDACScrollBarHookAuthorities := TList.Create;
  GDACNextScrollBarHookTicket := 0;

finalization
  EnterCriticalSection(GDACScrollBarHookAuthorityLock);
  try
    ClearDACScrollBarHookAuthorities;
  finally
    LeaveCriticalSection(GDACScrollBarHookAuthorityLock);
  end;
  GDACScrollBarHookAuthorities.Free;
  DeleteCriticalSection(GDACScrollBarHookAuthorityLock);

end.
