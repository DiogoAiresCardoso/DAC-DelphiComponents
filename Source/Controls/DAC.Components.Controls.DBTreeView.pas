unit DAC.Components.Controls.DBTreeView;

interface

uses
  System.Classes, System.SysUtils, System.Types, System.Variants,
  System.Generics.Collections, Data.DB, Winapi.Windows, Winapi.Messages,
  Vcl.Controls, Vcl.Graphics,
  DAC.Components.DesignSystem.Theme,
  DAC.Components.Controls.DBTreeView.Types,
  DAC.Components.Controls.DBTreeView.Columns,
  DAC.Components.Controls.DBTreeView.Roots,
  DAC.Components.Controls.DBTreeView.Model,
  DAC.Components.Controls.DBTreeView.DataLink,
  DAC.Components.Controls.DBTreeView.Painter;

type
  TDACDBTreeView = class(TCustomControl)
  private
    FDataLink: TDACDBTreeDataLink;
    FDataSource: TDataSource;
    FDataSet: TDataSet;
    FColumns: TDACDBTreeColumns;
    FRootValues: TDACDBTreeRoots;
    FSearchFields: TStringList;
    FModel: TDACDBTreeModel;
    FPainter: TDACDBTreePainter;
    FExpanded, FLocalChecks, FPreviousChecks: TDictionary<string, Boolean>;
    FPreviousKeys: TDictionary<string, Variant>;
    FKeyField, FParentField, FCheckField, FCheckableField, FSearchText: string;
    FSelectedKey: Variant;
    FSelectedToken, FEditingToken, FLastError: string;
    FNavigationSnapshot: TDACDBTreeNode;
    FCaptureNavigation, FReadingNavigation: Boolean;
    FThemeMode: TDACThemeMode;
    FReadOnly, FValid, FDirty, FPosted, FDestroying, FEditStructural,
      FEndEditNotification, FChecking: Boolean;
    FUpdateCount, FLock, FTopRow, FHorizontalOffset, FHoverRow,
      FDragStart, FDragOffset, FWheelRemainder: Integer;
    FDragKind: TDACDBTreeHitKind;
    FLoadCount, FDataReadCount, FGeneration, FKnownRecordCount: Integer;
    FOnCurrentChanged: TDACDBTreeCurrentEvent;
    FOnBeforeCheckChange: TDACDBTreeBeforeCheckEvent;
    FOnCheckChanged: TDACDBTreeCheckEvent;
    FOnActivateRecord: TDACDBTreeActivateEvent;
    FOnDataError: TDACDBTreeErrorEvent;
    procedure LinkChanged(Sender: TObject; Change: TDACDBTreeLinkChange; Field: TField);
    procedure ObserveDataSet;
    procedure SetDataSource(Value: TDataSource);
    procedure SetKeyField(const Value: string);
    procedure SetParentField(const Value: string);
    procedure SetCheckField(const Value: string);
    procedure SetCheckableField(const Value: string);
    procedure SetColumns(Value: TDACDBTreeColumns);
    procedure SetRootValues(Value: TDACDBTreeRoots);
    procedure SetSearchFields(Value: TStrings);
    function GetSearchFields: TStrings;
    procedure SetSearchText(const Value: string);
    procedure SetReadOnly(Value: Boolean);
    procedure SetThemeMode(Value: TDACThemeMode);
    procedure SetSelectedKey(const Value: Variant);
    function GetCheckedKeys: TArray<Variant>;
    procedure ConfigurationChanged(Sender: TObject);
    procedure ThemeChanged(Sender: TObject);
    procedure RequestRefresh;
    procedure SaveState;
    procedure ClearCatalogue(const Reason: TDACDBTreeChangeReason);
    procedure ReportError(const Key: Variant; const MessageText: string);
    procedure RebuildProjection;
    procedure SyncCurrent(const Reason: TDACDBTreeChangeReason);
    procedure ChangeCurrent(const Key: Variant; const Token: string;
      const Reason: TDACDBTreeChangeReason);
    procedure ReadNode(Node: TDACDBTreeNode; DataSet: TDataSet);
    procedure UpdateCurrentNode;
    function Navigate(const Key: Variant; Reason: TDACDBTreeChangeReason): Boolean;
    function DoSetChecked(const Key: Variant; Checked: Boolean;
      Reason: TDACDBTreeChangeReason): Boolean;
    function CurrentToken: string;
    function EffectiveDpi: Integer;
    procedure ClampScroll;
    procedure EnsureCurrentVisible;
    procedure ActivateCurrent;
    procedure WMRefresh(var M: TMessage); message WM_APP + $632;
    procedure WMGetDlgCode(var M: TMessage); message WM_GETDLGCODE;
    procedure WMEraseBkgnd(var M: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure CMMouseLeave(var M: TMessage); message CM_MOUSELEAVE;
    procedure CMHintShow(var M: TCMHintShow); message CM_HINTSHOW;
    procedure WMCaptureChanged(var M: TMessage); message WM_CAPTURECHANGED;
    procedure CMCancelMode(var M: TCMCancelMode); message CM_CANCELMODE;
  protected
    procedure Paint; override;
    procedure Resize; override;
    procedure Loaded; override;
    procedure CreateWnd; override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    function DoMouseWheel(Shift: TShiftState; WheelDelta: Integer;
      MousePos: TPoint): Boolean; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X,Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X,Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X,Y: Integer); override;
    procedure DoEnter; override;
    procedure DoExit; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Refresh; reintroduce;
    procedure BeginUpdate;
    procedure EndUpdate;
    function TrySetChecked(const Key: Variant; Checked: Boolean;
      Reason: TDACDBTreeChangeReason = tcrProgrammatic): Boolean;
    procedure Expand(const Key: Variant);
    procedure Collapse(const Key: Variant);
    procedure ExpandAll;
    procedure CollapseAll;
    property SelectedKey: Variant read FSelectedKey write SetSelectedKey;
    property CheckedKeys: TArray<Variant> read GetCheckedKeys;
    { Read-only diagnostic surface. Consumers must not modify Model. }
    property Model: TDACDBTreeModel read FModel;
    property LoadCount: Integer read FLoadCount;
    property DataReadCount: Integer read FDataReadCount;
    property IsDataValid: Boolean read FValid;
    property LastError: string read FLastError;
  published
    property DataSource: TDataSource read FDataSource write SetDataSource;
    property KeyField: string read FKeyField write SetKeyField;
    property ParentField: string read FParentField write SetParentField;
    property Columns: TDACDBTreeColumns read FColumns write SetColumns;
    property RootValues: TDACDBTreeRoots read FRootValues write SetRootValues;
    property CheckField: string read FCheckField write SetCheckField;
    property CheckableField: string read FCheckableField write SetCheckableField;
    property ReadOnly: Boolean read FReadOnly write SetReadOnly default False;
    property SearchFields: TStrings read GetSearchFields write SetSearchFields;
    property SearchText: string read FSearchText write SetSearchText;
    property ThemeMode: TDACThemeMode read FThemeMode write SetThemeMode default dtmInherit;
    property Align;
    property Anchors;
    property Constraints;
    property Enabled;
    property Font;
    property ParentFont;
    property ParentShowHint;
    property ShowHint;
    property PopupMenu;
    property TabStop default True;
    property TabOrder;
    property Visible;
    property OnCurrentChanged: TDACDBTreeCurrentEvent read FOnCurrentChanged write FOnCurrentChanged;
    property OnBeforeCheckChange: TDACDBTreeBeforeCheckEvent read FOnBeforeCheckChange write FOnBeforeCheckChange;
    property OnCheckChanged: TDACDBTreeCheckEvent read FOnCheckChanged write FOnCheckChanged;
    property OnActivateRecord: TDACDBTreeActivateEvent read FOnActivateRecord write FOnActivateRecord;
    property OnDataError: TDACDBTreeErrorEvent read FOnDataError write FOnDataError;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseMove;
    property OnMouseUp;
  end;

implementation

uses System.Math, DAC.Components.DesignSystem.ComponentStyle,
  DAC.Components.DesignSystem.DBTreeTokens;

type
  { A scan may outlive a binding change. Track the lifetime of its original
    dataset independently so its controls are always balanced when still alive. }
  TDACDBTreeDataSetWatch = class(TComponent)
  private
    FDataSet: TDataSet;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor CreateFor(ADataSet: TDataSet);
    destructor Destroy; override;
    property DataSet: TDataSet read FDataSet;
  end;

constructor TDACDBTreeDataSetWatch.CreateFor(ADataSet: TDataSet);
begin
  inherited Create(nil);
  FDataSet := ADataSet;
  FDataSet.FreeNotification(Self);
end;
destructor TDACDBTreeDataSetWatch.Destroy;
begin
  if FDataSet <> nil then FDataSet.RemoveFreeNotification(Self);
  inherited;
end;
procedure TDACDBTreeDataSetWatch.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FDataSet) then FDataSet := nil;
end;

constructor TDACDBTreeView.Create(AOwner: TComponent);
var Metrics: TDACDBTreeTokens;
begin
  inherited;
  ControlStyle := ControlStyle + [csOpaque, csCaptureMouse];
  StyleElements := [];
  Metrics := TDACDBTreeTokens.Resolve(TDACComponentStyle.Tokens.Controls);
  Width := Metrics.DefaultWidth;
  Height := Metrics.DefaultHeight;
  ParentFont := False;
  Font.Name := TDACComponentStyle.FontFamily;
  { Defaults are authored at 96 DPI. VCL streaming/parenting applies the
    host's scale once; constructing a point font at Screen.PPI scales twice. }
  Font.PixelsPerInch := 96;
  Font.Size := Metrics.FontSize;
  TabStop := True;
  ShowHint := True;
  FHoverRow := -1;
  FSelectedKey := Null;
  FThemeMode := dtmInherit;
  FModel := TDACDBTreeModel.Create;
  FExpanded := TDictionary<string, Boolean>.Create;
  FLocalChecks := TDictionary<string, Boolean>.Create;
  FPreviousChecks := TDictionary<string, Boolean>.Create;
  FPreviousKeys := TDictionary<string, Variant>.Create;
  FColumns := TDACDBTreeColumns.Create(Self);
  FColumns.OnChange := ConfigurationChanged;
  FRootValues := TDACDBTreeRoots.Create(Self);
  FRootValues.OnChange := ConfigurationChanged;
  FSearchFields := TStringList.Create;
  FSearchFields.OnChange := ConfigurationChanged;
  FPainter := TDACDBTreePainter.Create;
  FDataLink := TDACDBTreeDataLink.Create;
  FDataLink.OnChanged := LinkChanged;
  TDACThemeManager.RegisterListener(Self, ThemeChanged);
end;

destructor TDACDBTreeView.Destroy;
begin
  FDestroying := True;
  TDACThemeManager.UnregisterListener(Self);
  FDataLink.OnChanged := nil;
  FDataLink.DataSource := nil;
  if FDataSet <> nil then FDataSet.RemoveFreeNotification(Self);
  if FDataSource <> nil then FDataSource.RemoveFreeNotification(Self);
  FDataLink.Free;
  FNavigationSnapshot.Free;
  FColumns.OnChange := nil;
  FRootValues.OnChange := nil;
  FSearchFields.OnChange := nil;
  FPainter.Free;
  FModel.Free;
  FSearchFields.Free;
  FColumns.Free;
  FRootValues.Free;
  FExpanded.Free;
  FLocalChecks.Free;
  FPreviousChecks.Free;
  FPreviousKeys.Free;
  inherited;
end;

procedure TDACDBTreeView.ObserveDataSet;
var D: TDataSet;
begin
  D := nil;
  if FDataSource <> nil then D := FDataSource.DataSet;
  if D = FDataSet then Exit;
  if FDataSet <> nil then FDataSet.RemoveFreeNotification(Self);
  FDataSet := D;
  if D <> nil then D.FreeNotification(Self);
  Inc(FGeneration);
  FExpanded.Clear;
  FLocalChecks.Clear;
  FPreviousChecks.Clear;
  FPreviousKeys.Clear;
  FEditingToken := '';
  FEditStructural := False;
  FEndEditNotification := False;
  ClearCatalogue(tcrReset);
end;

procedure TDACDBTreeView.SetDataSource(Value: TDataSource);
begin
  if Value = FDataSource then Exit;
  if FDataSource <> nil then FDataSource.RemoveFreeNotification(Self);
  FDataSource := Value;
  if Value <> nil then Value.FreeNotification(Self);
  FDataLink.DataSource := Value;
  ObserveDataSet;
  RequestRefresh;
end;

procedure TDACDBTreeView.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation <> opRemove) or FDestroying then Exit;
  if AComponent = FDataSource then
  begin
    FDataSource := nil;
    FDataLink.DataSource := nil;
    ObserveDataSet;
  end
  else if AComponent = FDataSet then
  begin
    FDataSet := nil;
    Inc(FGeneration);
    FExpanded.Clear;
    FLocalChecks.Clear;
    FPreviousChecks.Clear;
    FPreviousKeys.Clear;
    ClearCatalogue(tcrReset);
  end;
end;

procedure TDACDBTreeView.SetKeyField(const Value: string);
begin if FKeyField <> Value then begin FKeyField := Value; ConfigurationChanged(nil); end; end;
procedure TDACDBTreeView.SetParentField(const Value: string);
begin if FParentField <> Value then begin FParentField := Value; ConfigurationChanged(nil); end; end;
procedure TDACDBTreeView.SetCheckField(const Value: string);
begin
  if FCheckField = Value then Exit;
  FCheckField := Value;
  FLocalChecks.Clear;
  ConfigurationChanged(nil);
end;
procedure TDACDBTreeView.SetCheckableField(const Value: string);
begin if FCheckableField <> Value then begin FCheckableField := Value; ConfigurationChanged(nil); end; end;
procedure TDACDBTreeView.SetColumns(Value: TDACDBTreeColumns);
begin FColumns.Assign(Value); end;
procedure TDACDBTreeView.SetRootValues(Value: TDACDBTreeRoots);
begin FRootValues.Assign(Value); end;
procedure TDACDBTreeView.SetSearchFields(Value: TStrings);
begin FSearchFields.Assign(Value); end;
function TDACDBTreeView.GetSearchFields: TStrings;
begin Result := FSearchFields; end;
procedure TDACDBTreeView.SetReadOnly(Value: Boolean);
begin FReadOnly := Value; Invalidate; end;
procedure TDACDBTreeView.SetThemeMode(Value: TDACThemeMode);
begin FThemeMode := Value; Invalidate; end;
procedure TDACDBTreeView.ThemeChanged(Sender: TObject);
begin Invalidate; end;
procedure TDACDBTreeView.ConfigurationChanged(Sender: TObject);
begin Inc(FGeneration); RequestRefresh; end;
procedure TDACDBTreeView.SetSearchText(const Value: string);
begin
  if FSearchText = Value then Exit;
  FSearchText := Value;
  FTopRow := 0;
  RebuildProjection;
end;

procedure TDACDBTreeView.RequestRefresh;
begin
  FDirty := True;
  if FDestroying or (FLock > 0) or (FUpdateCount > 0) or
    (csLoading in ComponentState) then Exit;
  if HandleAllocated then
  begin
    if not FPosted then
    begin
      FPosted := True;
      PostMessage(Handle, WM_APP + $632, 0, 0);
    end;
  end
  else Refresh;
end;

procedure TDACDBTreeView.WMRefresh(var M: TMessage);
begin
  FPosted := False;
  if FDirty then Refresh;
end;

procedure TDACDBTreeView.CreateWnd;
begin inherited; if FDirty then RequestRefresh; end;
procedure TDACDBTreeView.Loaded;
begin inherited; Refresh; end;
procedure TDACDBTreeView.BeginUpdate;
begin Inc(FUpdateCount); end;
procedure TDACDBTreeView.EndUpdate;
begin
  if FUpdateCount = 0 then raise EInvalidOperation.Create('Unbalanced DBTreeView.EndUpdate');
  Dec(FUpdateCount);
  if FUpdateCount = 0 then
    if FDirty then Refresh else RebuildProjection;
end;

procedure TDACDBTreeView.SaveState;
var N: TDACDBTreeNode;
begin
  if not FValid then Exit;
  for N in FModel.Nodes do
  begin
    FExpanded.AddOrSetValue(N.Token, N.Expanded);
    FPreviousChecks.AddOrSetValue(N.Token, N.Checked);
    FPreviousKeys.AddOrSetValue(N.Token, N.Key);
    if FCheckField = '' then FLocalChecks.AddOrSetValue(N.Token, N.Checked);
  end;
end;

procedure TDACDBTreeView.ClearCatalogue(const Reason: TDACDBTreeChangeReason);
begin
  FValid := False;
  FModel.Clear;
  FTopRow := 0;
  FHorizontalOffset := 0;
  FHoverRow := -1;
  ChangeCurrent(Null, '', Reason);
  Invalidate;
end;

procedure TDACDBTreeView.ReportError(const Key: Variant; const MessageText: string);
begin
  FLastError := MessageText;
  Invalidate;
  if Assigned(FOnDataError) then FOnDataError(Self, Key, MessageText);
end;

procedure TDACDBTreeView.ReadNode(Node: TDACDBTreeNode; DataSet: TDataSet);
var I, Revision: Integer; F: TField;
  procedure CheckStable;
  begin
    if (Revision <> FGeneration) or (DataSet <> FDataSet) then
      raise EInvalidOperation.Create('Dataset or configuration changed while reading a record');
    if not DataSet.Active then raise EInvalidOperation.Create('Dataset closed while reading a record');
    if DBTreeKeyToken(DataSet.FieldByName(FKeyField).Value,
      DBTreeFieldKeyKind(DataSet.FieldByName(FKeyField))) <> Node.Token then
      raise EInvalidOperation.Create('Current record changed while reading display text');
  end;
begin
  Revision := FGeneration;
  Inc(FDataReadCount);
  Node.Key := DataSet.FieldByName(FKeyField).Value;
  Node.ParentKey := DataSet.FieldByName(FParentField).Value;
  Node.Token := DBTreeKeyToken(Node.Key, DBTreeFieldKeyKind(DataSet.FieldByName(FKeyField)));
  if FRootValues.Matches(Node.ParentKey, DBTreeFieldKeyKind(DataSet.FieldByName(FParentField))) then
    Node.ParentToken := ''
  else Node.ParentToken := DBTreeKeyToken(Node.ParentKey, DBTreeFieldKeyKind(DataSet.FieldByName(FParentField)));
  SetLength(Node.Cells, FColumns.Count);
  Node.SearchText := '';
  for I := 0 to FColumns.Count - 1 do
  begin
    F := DataSet.FieldByName(FColumns[I].FieldName);
    Node.Cells[I] := F.DisplayText;
    CheckStable;
    if FSearchFields.Count = 0 then Node.SearchText := Node.SearchText + #0 + Node.Cells[I];
  end;
  for I := 0 to FSearchFields.Count - 1 do
  begin
    Node.SearchText := Node.SearchText + #0 + DataSet.FieldByName(FSearchFields[I]).DisplayText;
    CheckStable;
  end;
  Node.Checkable := True;
  if FCheckableField <> '' then
  begin
    F := DataSet.FieldByName(FCheckableField);
    Node.Checkable := not F.IsNull and F.AsBoolean;
  end;
  if FCheckField <> '' then
  begin
    F := DataSet.FieldByName(FCheckField);
    Node.Checked := not F.IsNull and F.AsBoolean;
  end
  else if not FLocalChecks.TryGetValue(Node.Token, Node.Checked) then Node.Checked := False;
end;

procedure TDACDBTreeView.Refresh;
var
  D: TDataSet; Candidate, Old: TDACDBTreeModel; B: TBookmark;
  N: TDACDBTreeNode; KeyKind: TDACDBTreeKeyKind; I, Generation: Integer;
  Previous, Expanded: Boolean;
  Removed: TArray<string>; Token, ErrorText: string; ErrorKey: Variant;
  Watch: TDACDBTreeDataSetWatch;
begin
  if FDestroying or (FLock > 0) or (FUpdateCount > 0) or
    (csLoading in ComponentState) then begin FDirty := True; Exit; end;
  ObserveDataSet;
  FDirty := False;
  D := FDataSet;
  if (D = nil) or not D.Active or (FKeyField = '') or (FParentField = '') or
    ((FDataSource <> nil) and not FDataSource.Enabled) then
  begin
    SaveState;
    ClearCatalogue(tcrReset);
    Exit;
  end;
  if D.State <> dsBrowse then begin FDirty := True; Exit; end;
  SaveState;
  Candidate := nil;
  B := nil;
  ErrorText := '';
  ErrorKey := Null;
  Generation := FGeneration;
  Watch := TDACDBTreeDataSetWatch.CreateFor(D);
  Inc(FLock);
  try
    try
      if D.IsUniDirectional then raise EInvalidOperation.Create('DBTreeView requires a bidirectional dataset with bookmarks');
      KeyKind := DBTreeFieldKeyKind(D.FieldByName(FKeyField));
      FRootValues.Validate(KeyKind);
      if KeyKind <> DBTreeFieldKeyKind(D.FieldByName(FParentField)) then
        raise EInvalidOperation.Create('KeyField and ParentField must have compatible types');
      if (FCheckField <> '') and (D.FieldByName(FCheckField).DataType <> ftBoolean) then
        raise EInvalidOperation.Create('CheckField must be boolean');
      if (FCheckableField <> '') and (D.FieldByName(FCheckableField).DataType <> ftBoolean) then
        raise EInvalidOperation.Create('CheckableField must be boolean');
      for I := 0 to FColumns.Count - 1 do D.FieldByName(FColumns[I].FieldName);
      for I := 0 to FSearchFields.Count - 1 do D.FieldByName(FSearchFields[I]);
      Candidate := TDACDBTreeModel.Create(KeyKind);
      if not D.IsEmpty then
      begin
        B := D.GetBookmark;
        if not D.BookmarkValid(B) then raise EInvalidOperation.Create('Dataset cannot preserve its position using bookmarks');
        D.DisableControls;
        try
          D.First;
          while True do
          begin
            if (Watch.DataSet = nil) or (D <> FDataSet) or not D.Active or (D.State <> dsBrowse) or
              (Generation <> FGeneration) then raise EInvalidOperation.Create('Dataset changed while building the catalogue');
            if D.Eof then Break;
            N := TDACDBTreeNode.Create;
            try
              ReadNode(N, D);
              if (Watch.DataSet = nil) or (D <> FDataSet) or
                (Generation <> FGeneration) then
                raise EInvalidOperation.Create('Dataset changed while reading a record');
              ErrorKey := N.Key;
              N.Bookmark := D.GetBookmark;
              Candidate.Add(N);
              N := nil;
            finally N.Free; end;
            D.Next;
          end;
        finally
          try
            if (Watch.DataSet <> nil) and D.Active and (D.State = dsBrowse) and
              D.BookmarkValid(B) then D.GotoBookmark(B);
          finally
            if Watch.DataSet <> nil then D.EnableControls;
          end;
        end;
      end;
      if (Watch.DataSet = nil) or (D <> FDataSet) or not D.Active or
        (D.State <> dsBrowse) or (Generation <> FGeneration) then
        raise EInvalidOperation.Create('Dataset or configuration changed while finalizing the catalogue');
      Candidate.Validate;
      for N in Candidate.Nodes do
      begin
        if FExpanded.TryGetValue(N.Token, Expanded) then N.Expanded := Expanded;
      end;
      Candidate.BuildVisible(FSearchText);
    except
      on E: Exception do
      begin
        ErrorText := E.Message;
        if E is EDACDBTreeDataError then ErrorKey := EDACDBTreeDataError(E).Key;
      end;
    end;
  finally
    if (B <> nil) and (Watch.DataSet <> nil) then D.FreeBookmark(B);
    Watch.Free;
    Dec(FLock);
  end;
  if ErrorText <> '' then
  begin
    Candidate.Free;
    ClearCatalogue(tcrReset);
    ReportError(ErrorKey, ErrorText);
    Exit;
  end;
  Old := FModel;
  FModel := Candidate;
  Old.Free;
  Inc(FLoadCount);
  Inc(FGeneration);
  Generation := FGeneration;
  FValid := True;
  FKnownRecordCount := D.RecordCount;
  FLastError := '';
  FEditStructural := False;
  ClampScroll;
  { Publish a complete catalogue before notifying, and stop if a consumer
    replaces it from an event handler. No node pointer survives an event. }
  Removed := FPreviousChecks.Keys.ToArray;
  for Token in Removed do
    if FModel.FindToken(Token) = nil then
    begin
      Previous := FPreviousChecks[Token];
      ErrorKey := FPreviousKeys[Token];
      FPreviousChecks.Remove(Token);
      FPreviousKeys.Remove(Token);
      FExpanded.Remove(Token);
      FLocalChecks.Remove(Token);
      if Previous and Assigned(FOnCheckChanged) then
        FOnCheckChanged(Self, ErrorKey, False, tcrRemoved);
      if FGeneration <> Generation then Exit;
    end;
  for I := 0 to FModel.Nodes.Count - 1 do
  begin
    N := FModel.Nodes[I];
    ErrorKey := N.Key;
    Token := N.Token;
    Expanded := N.Checked;
    Previous := False;
    FPreviousChecks.TryGetValue(Token, Previous);
    FPreviousChecks.AddOrSetValue(Token, Expanded);
    FPreviousKeys.AddOrSetValue(Token, ErrorKey);
    if (Previous <> Expanded) and Assigned(FOnCheckChanged) then
      FOnCheckChanged(Self, ErrorKey, Expanded, tcrDataSet);
    if FGeneration <> Generation then Exit;
  end;
  SyncCurrent(tcrDataSet);
  Invalidate;
end;

function TDACDBTreeView.CurrentToken: string;
begin
  Result := '';
  if FValid and (FDataSet <> nil) and FDataSet.Active and not FDataSet.IsEmpty then
    Result := DBTreeKeyToken(FDataSet.FieldByName(FKeyField).Value,
      DBTreeFieldKeyKind(FDataSet.FieldByName(FKeyField)));
end;

procedure TDACDBTreeView.ChangeCurrent(const Key: Variant; const Token: string;
  const Reason: TDACDBTreeChangeReason);
var OldKey, StableKey: Variant;
begin
  if Token = FSelectedToken then Exit;
  OldKey := FSelectedKey;
  StableKey := Key;
  FSelectedKey := StableKey;
  FSelectedToken := Token;
  Invalidate;
  if not FDestroying and Assigned(FOnCurrentChanged) then
    FOnCurrentChanged(Self, OldKey, StableKey, Reason);
end;

procedure TDACDBTreeView.SyncCurrent(const Reason: TDACDBTreeChangeReason);
var N: TDACDBTreeNode; Token: string;
begin
  if not FValid then Exit;
  try
    Token := CurrentToken;
    N := FModel.FindToken(Token);
    if N = nil then ChangeCurrent(Null, '', Reason)
    else ChangeCurrent(N.Key, N.Token, Reason);
    EnsureCurrentVisible;
  except on E: Exception do ReportError(Null, E.Message); end;
end;

procedure TDACDBTreeView.UpdateCurrentNode;
var N, Fresh: TDACDBTreeNode; Token, ErrorText: string;
  WasChecked, IsChecked: Boolean; Key: Variant; Revision: Integer;
begin
  if not FValid or (FDataSet = nil) or not FDataSet.Active or FDataSet.IsEmpty then Exit;
  if FLock > 0 then Exit;
  Revision := FGeneration;
  ErrorText := '';
  WasChecked := False;
  IsChecked := False;
  Key := Null;
  Inc(FLock);
  try
    try
      Token := FEditingToken;
      if Token = '' then Token := CurrentToken;
      N := FModel.FindToken(Token);
      if N = nil then begin FDirty := True; Exit; end;
      Fresh := TDACDBTreeNode.Create;
      try
        ReadNode(Fresh, FDataSet);
        if Revision <> FGeneration then raise EInvalidOperation.Create('Catalogue changed while reading the current record');
        N := FModel.FindToken(Token);
        if (N = nil) or (Fresh.Token <> N.Token) or (Fresh.ParentToken <> N.ParentToken) then
        begin FEditStructural := True; FDirty := True; Exit; end;
        WasChecked := N.Checked;
        N.Cells := Fresh.Cells;
        N.SearchText := Fresh.SearchText;
        N.Checked := Fresh.Checked;
        N.Checkable := Fresh.Checkable;
        Key := N.Key;
        IsChecked := N.Checked;
        FPreviousChecks.AddOrSetValue(N.Token, N.Checked);
        FPreviousKeys.AddOrSetValue(N.Token, N.Key);
        if FSearchText <> '' then RebuildProjection else Invalidate;
      finally Fresh.Free; end;
    except on E: Exception do ErrorText := E.Message; end;
  finally
    Dec(FLock);
    if FDirty and (FDataSet <> nil) and FDataSet.Active and
      (FDataSet.State = dsBrowse) then RequestRefresh;
  end;
  if ErrorText <> '' then
  begin
    if Revision = FGeneration then ClearCatalogue(tcrReset);
    ReportError(Key, ErrorText);
    Exit;
  end;
  if (WasChecked <> IsChecked) and Assigned(FOnCheckChanged) then
    FOnCheckChanged(Self, Key, IsChecked, tcrDataSet);
end;

procedure TDACDBTreeView.LinkChanged(Sender: TObject; Change: TDACDBTreeLinkChange; Field: TField);
var Snapshot: TDACDBTreeNode;
begin
  if FDestroying then Exit;
  ObserveDataSet;
  if FLock > 0 then
  begin
    if Change in [tlcActive, tlcLayout] then
    begin Inc(FGeneration); FDirty := True; end;
    if FCaptureNavigation and not FReadingNavigation and (Change = tlcEditing) and
      (FDataSet <> nil) and FDataSet.Active and (FDataSet.State = dsBrowse) then
    begin
      { Post finalizes while GotoBookmark still owns the cursor. Preserve its
        final row values before navigation moves away from the edited row. }
      Snapshot := TDACDBTreeNode.Create;
      FReadingNavigation := True;
      try
        try
          ReadNode(Snapshot, FDataSet);
          FNavigationSnapshot.Free;
          FNavigationSnapshot := Snapshot;
          Snapshot := nil;
        except FDirty := True; end;
      finally
        FReadingNavigation := False;
        Snapshot.Free;
      end;
    end;
    Exit;
  end;
  if Change = tlcActive then
  begin
    if (FDataSet = nil) or not FDataSet.Active then
    begin SaveState; ClearCatalogue(tcrReset); end
    else RequestRefresh;
    Exit;
  end;
  if (FDataSet = nil) or not FDataSet.Active then Exit;
  if FUpdateCount > 0 then begin FDirty := True; Exit; end;
  case Change of
    tlcScroll:
      begin FEndEditNotification := False; SyncCurrent(tcrDataSet); end;
    tlcLayout: RequestRefresh;
    tlcEditing:
      if FDataSet.State in [dsEdit, dsInsert] then
      begin
        FEndEditNotification := False;
        FEditStructural := FDataSet.State = dsInsert;
        if FEditStructural then begin FEditingToken := ''; FDirty := True; end
        else FEditingToken := CurrentToken;
      end
      else
      begin
        FEndEditNotification := True;
        if FEditStructural or FDirty then RequestRefresh else UpdateCurrentNode;
        FEditingToken := '';
      end;
    tlcRecord:
      if FDataSet.State = dsInsert then begin FEditStructural := True; FDirty := True; end
      else if FValid then
      begin
        if (Field <> nil) and ((Field.FieldName = FKeyField) or
          (Field.FieldName = FParentField)) then
        begin FEditStructural := True; RequestRefresh; end
        else UpdateCurrentNode;
      end else RequestRefresh;
    tlcData:
      { First/Last and Refresh use the same VCL event. A move to a known key
        with unchanged size is navigation; a same-key event outside editing
        is a refresh. Opaque replacements that also move the cursor require
        explicit Refresh (or a consumer Begin/EndUpdate group). }
      if not FEditStructural and FValid and not FDirty and
        (FDataSet.RecordCount = FKnownRecordCount) and
        (FEndEditNotification or (CurrentToken <> FSelectedToken) or FDataSet.Bof or FDataSet.Eof) and
        ((FDataSet.IsEmpty and (FModel.Nodes.Count = 0)) or
          (FModel.FindToken(CurrentToken) <> nil)) then
      begin
        FEndEditNotification := False;
        UpdateCurrentNode;
        SyncCurrent(tcrDataSet);
      end
      else RequestRefresh;
  end;
end;

function TDACDBTreeView.Navigate(const Key: Variant; Reason: TDACDBTreeChangeReason): Boolean;
var N: TDACDBTreeNode; D: TDataSet; Token, OldToken, ErrorText: string; B, OldB: TBookmark;
  StableKey, ChangedKey: Variant; Revision: Integer;
  WasChecked, CheckChanged, NewChecked: Boolean;
begin
  Result := False;
  StableKey := Key;
  if not FValid or FDirty then Exit;
  N := FModel.Find(StableKey);
  if N = nil then Exit;
  Token := N.Token;
  OldToken := CurrentToken;
  Revision := FGeneration;
  CheckChanged := False;
  ChangedKey := Null;
  NewChecked := False;
  D := FDataSet;
  if (D = nil) or not D.Active then Exit;
  if CurrentToken = Token then begin SyncCurrent(Reason); Exit(True); end;
  B := N.Bookmark;
  OldB := D.GetBookmark;
  ErrorText := '';
  FNavigationSnapshot.Free;
  FNavigationSnapshot := nil;
  FCaptureNavigation := D.State in [dsEdit, dsInsert];
  Inc(FLock);
  try
    try
      { The dataset owns the standard VCL implicit Post/Cancel on movement. }
      if not D.BookmarkValid(B) then raise EInvalidOperation.Create('Record bookmark is no longer valid; refresh the catalogue');
      D.GotoBookmark(B);
      if (Revision <> FGeneration) or (D <> FDataSet) or not FValid or (CurrentToken <> Token) then
        raise EInvalidOperation.Create('Dataset navigation did not select the requested key');
      if FNavigationSnapshot <> nil then
      begin
        N := FModel.FindToken(OldToken);
        if (N = nil) or (N.Token <> FNavigationSnapshot.Token) or
          (N.ParentToken <> FNavigationSnapshot.ParentToken) then
        begin FDirty := True; FEditStructural := True; end
        else
        begin
          WasChecked := N.Checked;
          N.Cells := FNavigationSnapshot.Cells;
          N.SearchText := FNavigationSnapshot.SearchText;
          N.Checked := FNavigationSnapshot.Checked;
          N.Checkable := FNavigationSnapshot.Checkable;
          CheckChanged := WasChecked <> N.Checked;
          NewChecked := N.Checked;
          ChangedKey := N.Key;
          FPreviousChecks.AddOrSetValue(N.Token, N.Checked);
          FPreviousKeys.AddOrSetValue(N.Token, N.Key);
        end;
      end;
      Result := True;
    except on E: Exception do
      begin
        ErrorText := E.Message;
        if (Revision = FGeneration) and (D = FDataSet) and D.Active and
          (D.State = dsBrowse) and D.BookmarkValid(OldB) then
          D.GotoBookmark(OldB);
      end;
    end;
  finally
    if D = FDataSet then D.FreeBookmark(OldB);
    FCaptureNavigation := False;
    FreeAndNil(FNavigationSnapshot);
    Dec(FLock);
  end;
  if Result then
  begin
    FEditingToken := '';
    FEndEditNotification := False;
    if FDirty then Refresh else if FSearchText <> '' then RebuildProjection;
    Result := FValid and (FDataSet = D) and (CurrentToken = Token);
    if not Result then Exit;
    SyncCurrent(Reason);
    if CheckChanged and (Revision = FGeneration) and Assigned(FOnCheckChanged) then
      FOnCheckChanged(Self, ChangedKey, NewChecked, tcrDataSet);
  end
  else ReportError(StableKey, ErrorText);
end;

procedure TDACDBTreeView.SetSelectedKey(const Value: Variant);
begin
  if VarIsNull(Value) or VarIsEmpty(Value) then ChangeCurrent(Null, '', tcrProgrammatic)
  else Navigate(Value, tcrProgrammatic);
end;

function TDACDBTreeView.TrySetChecked(const Key: Variant; Checked: Boolean;
  Reason: TDACDBTreeChangeReason): Boolean;
var StableKey: Variant;
begin
  Result := False;
  if FChecking then Exit;
  StableKey := Key;
  FChecking := True;
  try Result := DoSetChecked(StableKey, Checked, Reason);
  finally FChecking := False; end;
end;

function TDACDBTreeView.DoSetChecked(const Key: Variant; Checked: Boolean;
  Reason: TDACDBTreeChangeReason): Boolean;
var N, Fresh: TDACDBTreeNode; D: TDataSet; F: TField; Allow, OldChecked: Boolean;
  Token, ErrorText: string; Generation: Integer;
begin
  Result := False;
  if FDestroying or (FLock > 0) or not FValid or FDirty or FReadOnly or not Enabled then Exit;
  N := FModel.Find(Key);
  if (N = nil) or not N.Checkable then Exit;
  if N.Checked = Checked then Exit(True);
  Token := N.Token;
  if (FCheckField <> '') and not Navigate(Key, Reason) then Exit;
  D := FDataSet;
  if FCheckField <> '' then
  begin
    if (D = nil) or not D.Active then Exit;
    F := D.FieldByName(FCheckField);
    if not D.CanModify or F.ReadOnly then
    begin ReportError(Key, 'The configured check field cannot be modified'); Exit; end;
  end;
  Generation := FGeneration;
  Allow := True;
  try
    if Assigned(FOnBeforeCheckChange) then FOnBeforeCheckChange(Self, Key, Checked, Allow);
  except on E: Exception do begin ReportError(Key, E.Message); Exit; end; end;
  if not Allow or (Generation <> FGeneration) or (D <> FDataSet) or
    not FValid or FDirty or FReadOnly or not Enabled then Exit;
  N := FModel.FindToken(Token);
  if (N = nil) or not N.Checkable then Exit;
  OldChecked := N.Checked;
  ErrorText := '';
  if FCheckField <> '' then
  begin
    if (D = nil) or not D.Active then Exit;
    F := D.FieldByName(FCheckField);
    if not D.CanModify or F.ReadOnly or not (D.State in [dsEdit, dsInsert]) then
    begin ReportError(Key, 'Consumer must provide an editable boolean field and enter Edit/Insert before checking'); Exit; end;
    if CurrentToken <> Token then
    begin ReportError(Key, 'Consumer changed the current record during the check request'); Exit; end;
    Inc(FLock);
    try
      try
        F.AsBoolean := Checked;
        if (Generation <> FGeneration) or (D <> FDataSet) or not D.Active or not FValid then
          raise EInvalidOperation.Create('Dataset changed while writing the check field');
        F := D.FieldByName(FCheckField);
        N := FModel.FindToken(Token);
        if (N = nil) or (CurrentToken <> Token) then
          raise EInvalidOperation.Create('Record key changed while writing the check field');
        Checked := not F.IsNull and F.AsBoolean;
        Fresh := TDACDBTreeNode.Create;
        try
          ReadNode(Fresh, D);
          if (Generation <> FGeneration) or (D <> FDataSet) or not FValid then
            raise EInvalidOperation.Create('Dataset changed while reading the check result');
          N := FModel.FindToken(Token);
          if (N = nil) or (Fresh.Token <> Token) then
            raise EInvalidOperation.Create('Record changed while reading the check result');
          N.Cells := Fresh.Cells;
          N.SearchText := Fresh.SearchText;
          N.Checkable := Fresh.Checkable;
          N.Checked := Fresh.Checked;
        finally Fresh.Free; end;
      except on E: Exception do ErrorText := E.Message; end;
    finally Dec(FLock); end;
    if ErrorText <> '' then
    begin
      { Read back the authoritative field if a dataset handler raised after
        assigning. Never retain an optimistic mark or switch to local state. }
      UpdateCurrentNode;
      ReportError(Key, ErrorText);
      Exit;
    end;
  end
  else
  begin
    N.Checked := Checked;
    FLocalChecks.AddOrSetValue(Token, Checked);
  end;
  FPreviousChecks.AddOrSetValue(Token, Checked);
  FPreviousKeys.AddOrSetValue(Token, Key);
  FLastError := '';
  Result := True;
  Invalidate;
  if (OldChecked <> Checked) and Assigned(FOnCheckChanged) then
    FOnCheckChanged(Self, Key, Checked, Reason);
end;

function TDACDBTreeView.GetCheckedKeys: TArray<Variant>;
var N: TDACDBTreeNode; Keys: TList<Variant>;
begin
  Keys := TList<Variant>.Create;
  try
    if FValid then for N in FModel.Nodes do if N.Checked then Keys.Add(N.Key);
    Result := Keys.ToArray;
  finally Keys.Free; end;
end;

procedure TDACDBTreeView.RebuildProjection;
begin
  if FUpdateCount > 0 then Exit;
  FModel.BuildVisible(FSearchText);
  ClampScroll;
  Invalidate;
end;
procedure TDACDBTreeView.Expand(const Key: Variant);
var N: TDACDBTreeNode;
begin
  N := FModel.Find(Key);
  if N = nil then Exit;
  N.Expanded := True;
  FExpanded.AddOrSetValue(N.Token, True);
  RebuildProjection;
end;
procedure TDACDBTreeView.Collapse(const Key: Variant);
var N: TDACDBTreeNode;
begin
  N := FModel.Find(Key);
  if N = nil then Exit;
  N.Expanded := False;
  FExpanded.AddOrSetValue(N.Token, False);
  RebuildProjection;
end;
procedure TDACDBTreeView.ExpandAll;
var N: TDACDBTreeNode;
begin
  for N in FModel.Nodes do begin N.Expanded := True; FExpanded.AddOrSetValue(N.Token, True); end;
  RebuildProjection;
end;
procedure TDACDBTreeView.CollapseAll;
var N: TDACDBTreeNode;
begin
  for N in FModel.Nodes do begin N.Expanded := False; FExpanded.AddOrSetValue(N.Token, False); end;
  RebuildProjection;
end;

function TDACDBTreeView.EffectiveDpi: Integer;
begin
  Result := GetParentCurrentDpi;
  if Result <= 0 then Result := 96;
end;
procedure TDACDBTreeView.ClampScroll;
var L: TDACDBTreeLayout;
begin
  if FPainter = nil then Exit;
  L := FPainter.Layout(Width, Height, EffectiveDpi, FModel, FColumns, FTopRow, FHorizontalOffset);
  FTopRow := L.TopRow;
  FHorizontalOffset := L.HorizontalOffset;
end;
procedure TDACDBTreeView.EnsureCurrentVisible;
var N: TDACDBTreeNode; L: TDACDBTreeLayout;
begin
  if not FValid then Exit;
  N := FModel.FindToken(FSelectedToken);
  if (N = nil) or (N.VisibleIndex < 0) then Exit;
  L := FPainter.Layout(Width, Height, EffectiveDpi, FModel, FColumns, FTopRow, FHorizontalOffset);
  if N.VisibleIndex < FTopRow then FTopRow := N.VisibleIndex
  else if N.VisibleIndex >= FTopRow + L.PageRows then
    FTopRow := N.VisibleIndex - L.PageRows + 1;
  ClampScroll;
end;
procedure TDACDBTreeView.Resize;
begin inherited; ClampScroll; Invalidate; end;
procedure TDACDBTreeView.Paint;
var S: string;
begin
  S := FLastError;
  if FValid then S := '';
  if (S = '') and (csDesigning in ComponentState) and (FModel.Nodes.Count = 0) then
    S := 'TDACDBTreeView - configure DataSource, KeyField, ParentField and Columns';
  FPainter.Paint(Canvas.Handle, ClientWidth, ClientHeight, EffectiveDpi,
    TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls,
    FModel, FColumns, FSelectedToken, FTopRow, FHorizontalOffset, FHoverRow,
    Focused, Enabled, FReadOnly, S, Font);
end;
procedure TDACDBTreeView.WMEraseBkgnd(var M: TWMEraseBkgnd);
begin M.Result := 1; end;
procedure TDACDBTreeView.DoEnter;
begin inherited; Invalidate; end;
procedure TDACDBTreeView.DoExit;
begin inherited; Invalidate; end;
procedure TDACDBTreeView.WMGetDlgCode(var M: TMessage);
begin
  inherited;
  M.Result := M.Result or DLGC_WANTARROWS;
  if (M.LParam <> 0) and (PMsg(M.LParam).wParam in [VK_RETURN, VK_SPACE]) and
    (GetKeyState(VK_CONTROL) >= 0) and (GetKeyState(VK_MENU) >= 0) and
    (GetKeyState(VK_SHIFT) >= 0) then
    M.Result := M.Result or DLGC_WANTMESSAGE;
end;
procedure TDACDBTreeView.ActivateCurrent;
var StableKey: Variant;
begin
  StableKey := FSelectedKey;
  if FValid and (FSelectedToken <> '') and Assigned(FOnActivateRecord) then
    FOnActivateRecord(Self, StableKey);
end;
procedure TDACDBTreeView.KeyDown(var Key: Word; Shift: TShiftState);
var N: TDACDBTreeNode; Row: Integer; K: Variant; L: TDACDBTreeLayout;
begin
  inherited;
  if (Key = 0) or (Shift <> []) or not FValid then Exit;
  N := FModel.FindToken(FSelectedToken);
  Row := -1;
  if N <> nil then Row := N.VisibleIndex;
  case Key of
    VK_UP, VK_DOWN, VK_HOME, VK_END, VK_PRIOR, VK_NEXT:
      begin
        if FModel.Visible.Count = 0 then Exit;
        L := FPainter.Layout(Width, Height, EffectiveDpi, FModel, FColumns, FTopRow, FHorizontalOffset);
        case Key of
          VK_UP: Dec(Row);
          VK_DOWN: Inc(Row);
          VK_HOME: Row := 0;
          VK_END: Row := FModel.Visible.Count - 1;
          VK_PRIOR: Dec(Row, L.PageRows);
          VK_NEXT: Inc(Row, L.PageRows);
        end;
        Row := EnsureRange(Row, 0, FModel.Visible.Count - 1);
        K := FModel.Nodes[FModel.Visible[Row]].Key;
        Navigate(K, tcrUser);
      end;
    VK_LEFT:
      if N <> nil then
        if N.EffectiveExpanded then Collapse(N.Key)
        else if N.ParentIndex >= 0 then Navigate(FModel.Nodes[N.ParentIndex].Key, tcrUser);
    VK_RIGHT:
      if (N <> nil) and (N.Children.Count > 0) then
        if not N.EffectiveExpanded then Expand(N.Key)
        else if (Row >= 0) and (Row + 1 < FModel.Visible.Count) and
          (FModel.Nodes[FModel.Visible[Row + 1]].Depth > N.Depth) then
          Navigate(FModel.Nodes[FModel.Visible[Row + 1]].Key, tcrUser);
    VK_SPACE: if N <> nil then TrySetChecked(N.Key, not N.Checked, tcrUser);
    VK_RETURN: ActivateCurrent;
    else Exit;
  end;
  Key := 0;
  Invalidate;
end;
function TDACDBTreeView.DoMouseWheel(Shift: TShiftState; WheelDelta: Integer; MousePos: TPoint): Boolean;
begin
  if Shift <> [] then Exit(inherited DoMouseWheel(Shift, WheelDelta, MousePos));
  Inc(FWheelRemainder, WheelDelta);
  FTopRow := FTopRow - (FWheelRemainder div WHEEL_DELTA) * 3;
  FWheelRemainder := FWheelRemainder mod WHEEL_DELTA;
  ClampScroll;
  Invalidate;
  Result := True;
end;
procedure TDACDBTreeView.MouseDown(Button: TMouseButton; Shift: TShiftState; X,Y: Integer);
var H: TDACDBTreeHit; L: TDACDBTreeLayout; N: TDACDBTreeNode; K: Variant; B: Boolean;
begin
  inherited;
  if (Button <> mbLeft) or not Enabled then Exit;
  if CanFocus then SetFocus;
  H := FPainter.HitTest(X,Y,ClientWidth,ClientHeight,EffectiveDpi,FModel,FColumns,FTopRow,FHorizontalOffset);
  L := FPainter.Layout(ClientWidth,ClientHeight,EffectiveDpi,FModel,FColumns,FTopRow,FHorizontalOffset);
  case H.Kind of
    thVerticalTrack:
      if Y < L.VerticalThumb.Top then Dec(FTopRow,L.PageRows) else Inc(FTopRow,L.PageRows);
    thHorizontalTrack:
      if X < L.HorizontalThumb.Left then Dec(FHorizontalOffset,L.ContentRect.Width)
      else Inc(FHorizontalOffset,L.ContentRect.Width);
    thVerticalThumb,thHorizontalThumb:
      begin
        FDragKind := H.Kind;
        MouseCapture := True;
        if H.Kind = thVerticalThumb then begin FDragStart := Y; FDragOffset := FTopRow; end
        else begin FDragStart := X; FDragOffset := FHorizontalOffset; end;
      end;
    thRow,thCheck,thExpander:
      begin
        if not FValid or (H.NodeIndex < 0) then Exit;
        N := FModel.Nodes[H.NodeIndex];
        K := N.Key;
        B := N.Checked;
        case H.Kind of
          thRow: Navigate(K,tcrUser);
          thCheck: TrySetChecked(K,not B,tcrUser);
          thExpander: if N.EffectiveExpanded then Collapse(K) else Expand(K);
        end;
      end;
  end;
  ClampScroll;
  Invalidate;
end;
procedure TDACDBTreeView.MouseMove(Shift: TShiftState; X,Y: Integer);
var L: TDACDBTreeLayout; H: TDACDBTreeHit;
begin
  inherited;
  if not MouseCapture or not (ssLeft in Shift) then FDragKind := thNone;
  L := FPainter.Layout(ClientWidth,ClientHeight,EffectiveDpi,FModel,FColumns,FTopRow,FHorizontalOffset);
  case FDragKind of
    thVerticalThumb:
      FTopRow := FDragOffset + MulDiv(Y-FDragStart,L.MaxTopRow,
        Max(1,L.VerticalTrack.Height-L.VerticalThumb.Height));
    thHorizontalThumb:
      FHorizontalOffset := FDragOffset + MulDiv(X-FDragStart,L.MaxHorizontalOffset,
        Max(1,L.HorizontalTrack.Width-L.HorizontalThumb.Width));
    else
      begin
        H := FPainter.HitTest(X,Y,ClientWidth,ClientHeight,EffectiveDpi,FModel,FColumns,FTopRow,FHorizontalOffset);
        FHoverRow := H.VisibleRow;
      end;
  end;
  ClampScroll;
  Invalidate;
end;
procedure TDACDBTreeView.MouseUp(Button: TMouseButton; Shift: TShiftState; X,Y: Integer);
begin inherited; FDragKind := thNone; MouseCapture := False; end;
procedure TDACDBTreeView.WMCaptureChanged(var M: TMessage);
begin FDragKind := thNone; inherited; end;
procedure TDACDBTreeView.CMCancelMode(var M: TCMCancelMode);
begin FDragKind := thNone; MouseCapture := False; inherited; end;
procedure TDACDBTreeView.CMMouseLeave(var M: TMessage);
begin FHoverRow := -1; Invalidate; end;
procedure TDACDBTreeView.CMHintShow(var M: TCMHintShow);
var H: TDACDBTreeHit; N: TDACDBTreeNode;
begin
  inherited;
  H := FPainter.HitTest(M.HintInfo.CursorPos.X,M.HintInfo.CursorPos.Y,
    ClientWidth,ClientHeight,EffectiveDpi,FModel,FColumns,FTopRow,FHorizontalOffset);
  if (H.ColumnIndex < 0) or (H.ColumnIndex >= FColumns.Count) then Exit;
  if H.Kind = thHeader then M.HintInfo.HintStr := FColumns[H.ColumnIndex].TitleHint
  else if (H.NodeIndex >= 0) and (H.NodeIndex < FModel.Nodes.Count) then
  begin
    N := FModel.Nodes[H.NodeIndex];
    if FColumns[H.ColumnIndex].Hint <> '' then M.HintInfo.HintStr := FColumns[H.ColumnIndex].Hint
    else if H.ColumnIndex < Length(N.Cells) then M.HintInfo.HintStr := N.Cells[H.ColumnIndex];
  end;
  M.HintInfo.CursorRect := H.Bounds;
end;

end.
