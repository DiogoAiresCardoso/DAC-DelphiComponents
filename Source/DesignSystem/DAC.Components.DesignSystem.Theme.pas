unit DAC.Components.DesignSystem.Theme;

interface

uses
  System.Classes,
  System.Generics.Collections,
  Vcl.Controls,
  DAC.Components.DesignSystem.ChartPalette,
  DAC.Components.DesignSystem.Metrics,
  DAC.Components.DesignSystem.Tokens;

type
  TDACThemeMode = (dtmInherit, dtmDark, dtmLight);
  TDACThemeChangedEvent = procedure(Sender: TObject) of object;

  IDACComponentsTheme = interface
    ['{216C6F89-4EBE-4C7C-B521-50B9B9D47337}']
    function DisplayName: string;
    function Tokens: TDACDesignTokens;
    function Metrics: TDACComponentMetrics;
    function ChartPalette: TDACChartPalette;
  end;

  // Runtime-only manager. It does not know visual controls; registrations are
  // weak (the owner unregisters in Destroy), keeping runtime/design-time clean.
  TDACThemeManager = class sealed
  private type
    TDACThemeListener = record
      Owner: TComponent;
      Event: TDACThemeChangedEvent;
    end;
  private
    class var FApplicationMode: TDACThemeMode;
    class var FListeners: TList<TDACThemeListener>;
    class procedure NotifyListeners; static;
  public
    class function ApplicationMode: TDACThemeMode; static;
    class function IsUiThread: Boolean; static;
    class function ResolveMode(const AMode: TDACThemeMode): TDACThemeMode; static;
    class procedure SetApplicationMode(const AValue: TDACThemeMode); static;
    class procedure RegisterListener(const AOwner: TComponent;
      const AEvent: TDACThemeChangedEvent); static;
    class procedure RefreshListener(const AOwner: TComponent); static;
    { Reapply registered controls in root-to-leaf order without forcing a
      window handle. Local theme hosts use this after a ThemeMode or parent
      surface change so designer and runtime share the same palette. }
    class procedure RefreshTree(const ARoot: TControl); static;
    class procedure UnregisterListener(const AOwner: TComponent); static;
  end;

implementation

uses
  System.Math,
  System.SysUtils,
  Winapi.Windows;

class function TDACThemeManager.ApplicationMode: TDACThemeMode;
begin
  Result := FApplicationMode;
end;

class function TDACThemeManager.IsUiThread: Boolean;
begin
  Result := GetCurrentThreadId = MainThreadID;
end;

class procedure TDACThemeManager.NotifyListeners;
var
  LDepth: Integer;
  LIndex: Integer;
  LListener: TDACThemeListener;
  LListeners: TArray<TDACThemeListener>;
  LMaxDepth: Integer;
  function ListenerDepth(const AOwner: TComponent): Integer;
  var
    LControl: TControl;
  begin
    Result := 0;
    if not (AOwner is TControl) then
      Exit;
    LControl := TControl(AOwner).Parent;
    while LControl <> nil do
    begin
      Inc(Result);
      LControl := LControl.Parent;
    end;
  end;
begin
  if FListeners = nil then
    Exit;

  // Inherited theme resolution reads the already-resolved physical surface of
  // its visual ancestors. Remove dead entries first, then notify a snapshot
  // from roots to leaves so a child never resolves against the previous
  // palette of its parent container.
  for LIndex := FListeners.Count - 1 downto 0 do
  begin
    LListener := FListeners[LIndex];
    if (LListener.Owner = nil) or (csDestroying in LListener.Owner.ComponentState) then
      FListeners.Delete(LIndex);
  end;
  LListeners := FListeners.ToArray;
  LMaxDepth := 0;
  for LIndex := Low(LListeners) to High(LListeners) do
    LMaxDepth := Max(LMaxDepth, ListenerDepth(LListeners[LIndex].Owner));
  for LDepth := 0 to LMaxDepth do
    for LIndex := Low(LListeners) to High(LListeners) do
    begin
      LListener := LListeners[LIndex];
      if (LListener.Owner = nil) or
        (csDestroying in LListener.Owner.ComponentState) or
        (ListenerDepth(LListener.Owner) <> LDepth) then
        Continue;
      if Assigned(LListener.Event) then
        LListener.Event(LListener.Owner);
    end;
end;

class procedure TDACThemeManager.RegisterListener(const AOwner: TComponent;
  const AEvent: TDACThemeChangedEvent);
var
  LListener: TDACThemeListener;
  LIndex: Integer;
begin
  if (AOwner = nil) or not Assigned(AEvent) then
    Exit;
  if FListeners = nil then
    FListeners := TList<TDACThemeListener>.Create;
  for LIndex := 0 to FListeners.Count - 1 do
    if FListeners[LIndex].Owner = AOwner then
      Exit;
  LListener.Owner := AOwner;
  LListener.Event := AEvent;
  FListeners.Add(LListener);
end;

class procedure TDACThemeManager.RefreshListener(const AOwner: TComponent);
var
  LIndex: Integer;
begin
  if (AOwner = nil) or (FListeners = nil) or
    (csDestroying in AOwner.ComponentState) then
    Exit;
  for LIndex := 0 to FListeners.Count - 1 do
    if FListeners[LIndex].Owner = AOwner then
    begin
      if Assigned(FListeners[LIndex].Event) then
        FListeners[LIndex].Event(AOwner);
      Exit;
    end;
end;

class procedure TDACThemeManager.RefreshTree(const ARoot: TControl);
  procedure RefreshChildren(const AParent: TWinControl);
  var
    LChild: TControl;
    LIndex: Integer;
  begin
    for LIndex := 0 to AParent.ControlCount - 1 do
    begin
      LChild := AParent.Controls[LIndex];
      if (LChild = nil) or (csDestroying in LChild.ComponentState) then
        Continue;
      RefreshListener(LChild);
      if LChild is TWinControl then
        RefreshChildren(TWinControl(LChild));
    end;
  end;
begin
  if (ARoot = nil) or (csDestroying in ARoot.ComponentState) then
    Exit;
  RefreshListener(ARoot);
  if ARoot is TWinControl then
    RefreshChildren(TWinControl(ARoot));
end;

class function TDACThemeManager.ResolveMode(const AMode: TDACThemeMode): TDACThemeMode;
begin
  Result := AMode;
  if Result = dtmInherit then
    Result := FApplicationMode;
  if Result = dtmInherit then
    Result := dtmDark;
end;

class procedure TDACThemeManager.SetApplicationMode(const AValue: TDACThemeMode);
var
  LValue: TDACThemeMode;
begin
  if not IsUiThread then
    raise EInvalidOperation.Create(
      'TDACThemeManager.SetApplicationMode deve ser chamado na thread de UI.');
  LValue := AValue;
  if LValue = dtmInherit then
    LValue := dtmDark;
  if FApplicationMode = LValue then
  begin
    { A streamed form or the designer can replay the same application value
      after recreating its visual tree. Refreshing listeners is intentional:
      inherited surfaces may have changed even when the enum did not. }
    NotifyListeners;
    Exit;
  end;
  FApplicationMode := LValue;
  NotifyListeners;
end;

class procedure TDACThemeManager.UnregisterListener(const AOwner: TComponent);
var
  LIndex: Integer;
begin
  if FListeners = nil then
    Exit;
  for LIndex := FListeners.Count - 1 downto 0 do
    if FListeners[LIndex].Owner = AOwner then
      FListeners.Delete(LIndex);
end;

initialization
  TDACThemeManager.FApplicationMode := dtmDark;

finalization
  TDACThemeManager.FListeners.Free;

end.

