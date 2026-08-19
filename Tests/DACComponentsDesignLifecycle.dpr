program DACComponentsDesignLifecycle;

{$APPTYPE CONSOLE}

{$IFDEF DAC_STAGE6_ONLY}
  { Stage 6 must rerun the same isolated Lookup/Navigator/Grid lifecycle
    inventory approved in Stage 5, now with the localized hooks linked. }
  {$DEFINE DAC_STAGE5_ONLY}
{$ENDIF}

uses
  System.Classes,
  System.SysUtils,
  System.TypInfo,
  System.UITypes,
  Data.DB,
  Datasnap.DBClient,
  Winapi.Windows,
  Vcl.ComCtrls,
  Vcl.Controls,
  Vcl.DBCtrls,
  Vcl.DBGrids,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.Graphics,
  Vcl.Mask,
  Vcl.Skia,
  Vcl.StdCtrls,
  DAC.Components.Controls.Badges in '..\Source\Controls\DAC.Components.Controls.Badges.pas',
  DAC.Components.Controls.Button in '..\Source\Controls\DAC.Components.Controls.Button.pas',
  DAC.Components.Controls.ButtonEdit in '..\Source\Controls\DAC.Components.Controls.ButtonEdit.pas',
  DAC.Components.Controls.Charts in '..\Source\Controls\DAC.Components.Controls.Charts.pas',
  DAC.Components.Controls.ComboBox in '..\Source\Controls\DAC.Components.Controls.ComboBox.pas',
  DAC.Components.Controls.Container in '..\Source\Controls\DAC.Components.Controls.Container.pas',
  DAC.Components.Controls.DataAware in '..\Source\Controls\DataAware\DAC.Components.Controls.DataAware.pas',
  DAC.Components.Controls.DataAware.Lookup in '..\Source\Controls\DataAware\DAC.Components.Controls.DataAware.Lookup.pas',
  DAC.Components.Controls.DataAware.Navigator in '..\Source\Controls\DataAware\DAC.Components.Controls.DataAware.Navigator.pas',
  DAC.Components.Controls.DataGrid in '..\Source\Controls\DAC.Components.Controls.DataGrid.pas',
  DAC.Components.Controls.DateTimePicker in '..\Source\Controls\DAC.Components.Controls.DateTimePicker.pas',
  DAC.Components.Controls.DateTimePickerPopup in '..\Source\Controls\DAC.Components.Controls.DateTimePickerPopup.pas',
  DAC.Components.Controls.Edit in '..\Source\Controls\DAC.Components.Controls.Edit.pas',
  DAC.Components.Controls.Feedback in '..\Source\Controls\DAC.Components.Controls.Feedback.pas',
  DAC.Components.Controls.GridContainer in '..\Source\Controls\DAC.Components.Controls.GridContainer.pas',
  DAC.Components.Controls.Loading in '..\Source\Controls\DAC.Components.Controls.Loading.pas',
  DAC.Components.Controls.Memo in '..\Source\Controls\DAC.Components.Controls.Memo.pas',
  DAC.Components.Controls.Pagination in '..\Source\Controls\DAC.Components.Controls.Pagination.pas',
  DAC.Components.Controls.Progress in '..\Source\Controls\DAC.Components.Controls.Progress.pas',
  DAC.Components.Controls.ReportViewer in '..\Source\Controls\DAC.Components.Controls.ReportViewer.pas',
  DAC.Components.Controls.ScrollContainer in '..\Source\Controls\DAC.Components.Controls.ScrollContainer.pas',
  DAC.Components.Controls.Selectors in '..\Source\Controls\DAC.Components.Controls.Selectors.pas',
  DAC.Components.Controls.SkiaControl in '..\Source\Controls\DAC.Components.Controls.SkiaControl.pas',
  DAC.Components.Controls.StatusBar in '..\Source\Controls\DAC.Components.Controls.StatusBar.pas',
  DAC.Components.Controls.StatusTimelineChart in '..\Source\Controls\DAC.Components.Controls.StatusTimelineChart.pas',
  DAC.Components.Controls.SummaryCard in '..\Source\Controls\DAC.Components.Controls.SummaryCard.pas',
  DAC.Components.Controls.SystemText in '..\Source\Controls\DAC.Components.Controls.SystemText.pas',
  DAC.Components.Controls.Tabs in '..\Source\Controls\DAC.Components.Controls.Tabs.pas',
  DAC.Components.DesignSystem.AssetResolver in '..\Source\DesignSystem\DAC.Components.DesignSystem.AssetResolver.pas',
  DAC.Components.DesignSystem.ColorTokens in '..\Source\DesignSystem\DAC.Components.DesignSystem.ColorTokens.pas',
  DAC.Components.DesignSystem.ComponentStyle in '..\Source\DesignSystem\DAC.Components.DesignSystem.ComponentStyle.pas',
  DAC.Components.DesignSystem.ControlTokens in '..\Source\DesignSystem\DAC.Components.DesignSystem.ControlTokens.pas',
  DAC.Components.DesignSystem.DefaultTheme in '..\Source\DesignSystem\DAC.Components.DesignSystem.DefaultTheme.pas',
  DAC.Components.DesignSystem.Theme in '..\Source\DesignSystem\DAC.Components.DesignSystem.Theme.pas',
  DAC.Components.Hooks.DataAware in '..\Source\Hooks\DAC.Components.Hooks.DataAware.pas',
  DAC.Components.Hooks.Register in '..\Source\Hooks\DAC.Components.Hooks.Register.pas',
  DAC.Components.Hooks.ScrollContainer in '..\Source\Hooks\DAC.Components.Hooks.ScrollContainer.pas',
  DAC.Components.Skia.BackgroundPainter in '..\Source\Skia\DAC.Components.Skia.BackgroundPainter.pas',
  DAC.Components.Skia.BorderPainter in '..\Source\Skia\DAC.Components.Skia.BorderPainter.pas',
  DAC.Components.Skia.Container in '..\Source\Skia\DAC.Components.Skia.Container.pas',
  DAC.Components.Skia.IconPainter in '..\Source\Skia\DAC.Components.Skia.IconPainter.pas',
  DAC.Components.Skia.Renderer in '..\Source\Skia\DAC.Components.Skia.Renderer.pas',
  DAC.Components.Skia.VisualElement in '..\Source\Skia\DAC.Components.Skia.VisualElement.pas'
{$IFNDEF DAC_STAGE4_ONLY}
{$IFNDEF DAC_STAGE5_ONLY}
  , Demo.Principal in '..\demo\Demo.Principal.pas' {Form1}
{$ENDIF}
{$ENDIF}
  ;

type
  TComponentAccess = class(TComponent)
  public
    procedure SimulateDesignerLoaded;
  end;

  TTabSheetAccess = class(TTabSheet)
  end;

  TExceptionProbe = class
  public
    procedure OnApplicationException(Sender: TObject; E: Exception);
  end;

  TCustomFormLoadedAccess = class(TCustomForm)
  public
    procedure CallBaseLoaded;
  end;

  TWinControlAccess = class(TWinControl)
  public
    procedure ForceRecreateWnd;
  end;

{$IFNDEF DAC_STAGE4_ONLY}
{$IFNDEF DAC_STAGE5_ONLY}
  TForm1NoBuilders = class(TForm1)
  protected
    procedure Loaded; override;
  end;
{$ENDIF}
{$ENDIF}

  TClassSpec = record
    ComponentClass: TComponentClass;
    Family: string;
    Registered: Boolean;
  end;

var
  GSpecs: array of TClassSpec;
  GFailures: Integer;
  GAsyncException: string;
  GExceptionProbe: TExceptionProbe;

const
  GR_GDIOBJECTS = 0;
  GR_USEROBJECTS = 1;

function DacGetGuiResources(const AProcess: THandle;
  const AFlags: DWORD): DWORD; stdcall; external 'user32.dll'
  name 'GetGuiResources';

function BoolText(const AValue: Boolean): string; forward;
function CleanText(const AValue: string): string; forward;
procedure RequireNoAllocatedHandles(const AComponent: TComponent); forward;
procedure RequireNoAllocatedChildHandles(const ARoot: TComponent); forward;

procedure TComponentAccess.SimulateDesignerLoaded;
begin
  SetDesigning(True);
  Loaded;
end;

procedure TExceptionProbe.OnApplicationException(Sender: TObject;
  E: Exception);
begin
  GAsyncException := E.ClassName + ': ' + E.Message;
end;

procedure TCustomFormLoadedAccess.CallBaseLoaded;
begin
  inherited Loaded;
end;

procedure TWinControlAccess.ForceRecreateWnd;
begin
  RecreateWnd;
end;

{$IFNDEF DAC_STAGE4_ONLY}
{$IFNDEF DAC_STAGE5_ONLY}
procedure TForm1NoBuilders.Loaded;
begin
  TCustomFormLoadedAccess(Self).CallBaseLoaded;
end;
{$ENDIF}
{$ENDIF}

function CountThreadWindow(AWindow: HWND; AData: LPARAM): BOOL; stdcall;
begin
  Inc(PInteger(AData)^);
  Result := True;
end;

function ThreadWindowCount: Integer;
begin
  Result := 0;
  EnumThreadWindows(GetCurrentThreadId, @CountThreadWindow,
    LPARAM(@Result));
end;

function CountVisibleThreadWindow(AWindow: HWND; AData: LPARAM): BOOL; stdcall;
begin
  if IsWindowVisible(AWindow) then
    Inc(PInteger(AData)^);
  Result := True;
end;

function VisibleThreadWindowCount: Integer;
begin
  Result := 0;
  EnumThreadWindows(GetCurrentThreadId, @CountVisibleThreadWindow,
    LPARAM(@Result));
end;

function CollectThreadWindow(AWindow: HWND; AData: LPARAM): BOOL; stdcall;
var
  LClassName: array[0..255] of Char;
  LControl: TWinControl;
  LList: TStrings;
  LTitle: array[0..255] of Char;
  LVclControl: string;
begin
  LList := TStrings(Pointer(AData));
  LClassName[0] := #0;
  LTitle[0] := #0;
  GetClassName(AWindow, LClassName, Length(LClassName));
  GetWindowText(AWindow, LTitle, Length(LTitle));
  LControl := FindControl(AWindow);
  if LControl <> nil then
    LVclControl := LControl.ClassName + '(' + LControl.Name + ')'
  else
    LVclControl := 'none';
  LList.Add(string(LClassName) + '{Title=' + string(LTitle) +
    ';Visible=' + BoolText(IsWindowVisible(AWindow)) +
    ';VCL=' + LVclControl + '}');
  Result := True;
end;

function ThreadWindowSnapshot: string;
var
  I: Integer;
  LList: TStringList;
begin
  Result := '';
  LList := TStringList.Create;
  try
    EnumThreadWindows(GetCurrentThreadId, @CollectThreadWindow,
      LPARAM(LList));
    for I := 0 to LList.Count - 1 do
    begin
      if Result <> '' then
        Result := Result + ',';
      Result := Result + LList[I];
    end;
  finally
    LList.Free;
  end;
end;

function AllocatedControlSnapshot(const AComponent: TComponent): string;
var
  I: Integer;
  LChild: string;
  LControl: TWinControl;
begin
  Result := '';
  if (AComponent is TWinControl) and
    TWinControl(AComponent).HandleAllocated then
  begin
    LControl := TWinControl(AComponent);
    Result := LControl.ClassName + '(' + LControl.Name + ')' +
      '{TopLevel=' + BoolText(GetParent(LControl.Handle) = 0) +
      ';Visible=' + BoolText(IsWindowVisible(LControl.Handle)) + '}';
  end;
  for I := 0 to AComponent.ComponentCount - 1 do
  begin
    LChild := AllocatedControlSnapshot(AComponent.Components[I]);
    if LChild = '' then
      Continue;
    if Result <> '' then
      Result := Result + ',';
    Result := Result + LChild;
  end;
end;

function UserObjectCount: DWORD;
begin
  Result := DacGetGuiResources(GetCurrentProcess, GR_USEROBJECTS);
end;

function GdiObjectCount: DWORD;
begin
  Result := DacGetGuiResources(GetCurrentProcess, GR_GDIOBJECTS);
end;

procedure AppendAsyncException(var AError: string);
begin
  Application.ProcessMessages;
  if GAsyncException = '' then
    Exit;
  if AError <> '' then
    AError := AError + ' | ';
  AError := AError + 'Async ' + GAsyncException;
  GAsyncException := '';
end;

procedure AddSpec(const AClass: TComponentClass; const AFamily: string;
  const ARegistered: Boolean);
var
  LIndex: Integer;
begin
  LIndex := Length(GSpecs);
  SetLength(GSpecs, LIndex + 1);
  GSpecs[LIndex].ComponentClass := AClass;
  GSpecs[LIndex].Family := AFamily;
  GSpecs[LIndex].Registered := ARegistered;
end;

procedure BuildInventory;
begin
{$IFDEF DAC_STAGE5_ONLY}
  AddSpec(TDACDBLookupComboBox, 'Selectors.DB', True);
  AddSpec(TDACDBNavigator, 'Navigation.DB', True);
  AddSpec(TDACDataGrid, 'Grid', True);
{$ELSE}
{$IFDEF DAC_STAGE4_ONLY}
  AddSpec(TDACDBDateTimePicker, 'Selectors.DB', True);
  AddSpec(TDACDBCheckBox, 'Choices.DB', True);
  AddSpec(TDACDBRadioButton, 'Choices.DB', True);
  AddSpec(TDACDBToggleSwitch, 'Choices.DB', True);
  AddSpec(TDACDBSlider, 'Choices.DB', True);
{$ELSE}
{$IFDEF DAC_STAGE3_ONLY}
  AddSpec(TDACDBEdit, 'Inputs.DB', True);
  AddSpec(TDACDBMemo, 'Inputs.DB', True);
  AddSpec(TDACDBButtonEdit, 'Inputs.DB', True);
  AddSpec(TDACDBText, 'Inputs.DB', True);
  AddSpec(TDACDBComboBox, 'Selectors.DB', True);
{$ELSE}
  AddSpec(TDACButton, 'Buttons', True);
  AddSpec(TDACButtonEdit, 'Inputs', True);
  AddSpec(TDACEdit, 'Inputs', True);
  AddSpec(TDACMemo, 'Inputs', True);
  AddSpec(TDACComboBox, 'Selectors', True);
  AddSpec(TDACDateTimePicker, 'Selectors', True);
  AddSpec(TDACCheckBox, 'Choices', True);
  AddSpec(TDACRadioButton, 'Choices', True);
  AddSpec(TDACToggleSwitch, 'Choices', True);
  AddSpec(TDACSlider, 'Choices', True);
  AddSpec(TDACTabs, 'Tabs', True);
  AddSpec(TDACContainer, 'Cards', True);
  AddSpec(TDACScrollContainer, 'Cards', True);
  AddSpec(TDACGridContainer, 'Cards', True);
  AddSpec(TDACSummaryCard, 'Cards', True);
  AddSpec(TDACDataGrid, 'Grid', True);
  AddSpec(TDACStatusBar, 'Status', True);
  AddSpec(TDACProgress, 'Progress', True);
  AddSpec(TDACBadge, 'Pills', True);
  AddSpec(TDACToast, 'Feedback', True);
  AddSpec(TDACModalDialog, 'Feedback', True);
  AddSpec(TDACTooltip, 'Feedback', True);
  AddSpec(TDACPagination, 'Pagination', True);
  AddSpec(TDACLoading, 'Loading', True);
  AddSpec(TDACChart, 'Charts', True);
  AddSpec(TDACStatusTimelineChart, 'Charts', True);
  AddSpec(TDACReportViewer, 'Report', True);
  AddSpec(TDACDBEdit, 'Inputs.DB', True);
  AddSpec(TDACDBMemo, 'Inputs.DB', True);
  AddSpec(TDACDBButtonEdit, 'Inputs.DB', True);
  AddSpec(TDACDBText, 'Inputs.DB', True);
  AddSpec(TDACDBComboBox, 'Selectors.DB', True);
  AddSpec(TDACDBLookupComboBox, 'Selectors.DB', True);
  AddSpec(TDACDBNavigator, 'Navigation.DB', True);
  AddSpec(TDACDBDateTimePicker, 'Selectors.DB', True);
  AddSpec(TDACDBCheckBox, 'Choices.DB', True);
  AddSpec(TDACDBRadioButton, 'Choices.DB', True);
  AddSpec(TDACDBToggleSwitch, 'Choices.DB', True);
  AddSpec(TDACDBSlider, 'Choices.DB', True);
  AddSpec(TDACSelector, 'Choices.Base', False);
  AddSpec(TDACSkiaControl, 'Foundation', False);
  AddSpec(TDACSystemText, 'Foundation', False);
  AddSpec(TDACTabHeaderControl, 'Tabs.Host', False);
  AddSpec(TDACTabSheetAccess, 'Tabs.Host', False);
  AddSpec(TDACDataGridPaintBox, 'Grid.Host', False);
  AddSpec(TDACDateTimePickerPopup, 'Selectors.Host', False);
{$ENDIF}
{$ENDIF}
{$ENDIF}
end;

procedure RegisterLifecycleClasses;
var
  I: Integer;
  LRegistered: TPersistentClass;

  procedure EnsureRegistered(const AClass: TPersistentClass);
  begin
    LRegistered := System.Classes.GetClass(AClass.ClassName);
    if LRegistered = nil then
      System.Classes.RegisterClass(AClass)
    else if LRegistered <> AClass then
      raise Exception.Create('Classe registrada com tipo divergente: ' +
        AClass.ClassName);
  end;

begin
  for I := 0 to Length(GSpecs) - 1 do
    EnsureRegistered(GSpecs[I].ComponentClass);
  EnsureRegistered(Vcl.StdCtrls.TButton);
  EnsureRegistered(Vcl.StdCtrls.TEdit);
  EnsureRegistered(Vcl.Mask.TMaskEdit);
  EnsureRegistered(Vcl.StdCtrls.TMemo);
  EnsureRegistered(Vcl.StdCtrls.TComboBox);
  EnsureRegistered(Vcl.ComCtrls.TDateTimePicker);
  EnsureRegistered(Vcl.ExtCtrls.TPanel);
  EnsureRegistered(Vcl.StdCtrls.TLabel);
  EnsureRegistered(Vcl.Forms.TForm);
  EnsureRegistered(Vcl.ComCtrls.TPageControl);
  EnsureRegistered(Vcl.ComCtrls.TTabSheet);
  EnsureRegistered(Vcl.Skia.TSkPaintBox);
end;

function WritableProp(const AClass: TComponentClass;
  const AName: string): PPropInfo;
begin
  Result := GetPropInfo(AClass.ClassInfo, AName);
  if (Result <> nil) and (Result^.SetProc = nil) then
    Result := nil;
end;

function BuildStandaloneDfm(const ASpec: TClassSpec): string;
var
  LPropertyCount: Integer;

  procedure AddLine(const AName, AValue: string);
  begin
    Result := Result + '  ' + AName + ' = ' + AValue + sLineBreak;
    Inc(LPropertyCount);
  end;

begin
  LPropertyCount := 0;
  Result := 'object LifecycleProbe: ' + ASpec.ComponentClass.ClassName +
    sLineBreak;
  if WritableProp(ASpec.ComponentClass, 'Tag') <> nil then
    AddLine('Tag', '1701');
  if WritableProp(ASpec.ComponentClass, 'Left') <> nil then
    AddLine('Left', '11');
  if WritableProp(ASpec.ComponentClass, 'Top') <> nil then
    AddLine('Top', '13');
  if WritableProp(ASpec.ComponentClass, 'Width') <> nil then
    AddLine('Width', '173');
  if WritableProp(ASpec.ComponentClass, 'Height') <> nil then
    AddLine('Height', '47');
  if WritableProp(ASpec.ComponentClass, 'ThemeMode') <> nil then
    AddLine('ThemeMode', 'dtmDark');
  if WritableProp(ASpec.ComponentClass, 'Caption') <> nil then
    AddLine('Caption', '''Lifecycle DFM''');
  if WritableProp(ASpec.ComponentClass, 'Text') <> nil then
    AddLine('Text', '''Lifecycle DFM''');
  if WritableProp(ASpec.ComponentClass, 'CornerRadius') <> nil then
    AddLine('CornerRadius', '9');
{$IFDEF DAC_STAGE4_ONLY}
  AddLine('DataField', '''VALUE''');
  if ASpec.ComponentClass = TDACDBDateTimePicker then
  begin
    AddLine('AllowNull', 'True');
    AddLine('FormatString', '''yyyy-MM-dd''');
    AddLine('PickerKind', 'dtkTime');
    AddLine('ReadOnly', 'True');
    AddLine('TimeStepMinutes', '7');
  end
  else if ASpec.ComponentClass = TDACDBCheckBox then
  begin
    AddLine('AllowGrayed', 'True');
    AddLine('ValueChecked', '''Y''');
    AddLine('ValueUnchecked', '''N''');
    AddLine('ValueGrayed', '''G''');
  end
  else if ASpec.ComponentClass = TDACDBRadioButton then
    AddLine('Value', '''Selected''')
  else if ASpec.ComponentClass = TDACDBToggleSwitch then
  begin
    AddLine('ValueOn', '''Y''');
    AddLine('ValueOff', '''N''');
  end
  else if ASpec.ComponentClass = TDACDBSlider then
  begin
    AddLine('Minimum', '10');
    AddLine('Maximum', '90');
    AddLine('ShowValue', 'False');
    AddLine('ValueScale', '0.5');
  end;
{$ENDIF}
{$IFDEF DAC_STAGE5_ONLY}
  if ASpec.ComponentClass = TDACDBLookupComboBox then
  begin
    AddLine('DataField', '''VALUE''');
    AddLine('KeyField', '''ID''');
    AddLine('ListField', '''NAME;CODE''');
    AddLine('ListFieldIndex', '1');
    AddLine('DropDownRows', '9');
    AddLine('DropDownWidth', '240');
    AddLine('ReadOnly', 'True');
  end
  else if ASpec.ComponentClass = TDACDBNavigator then
  begin
    AddLine('ConfirmDelete', 'False');
    AddLine('VisibleButtons', '[nbFirst, nbNext, nbLast]');
  end
  else if ASpec.ComponentClass = TDACDataGrid then
  begin
    AddLine('FooterText', '''Total''');
    AddLine('FooterValue', '''42''');
    AddLine('Loading', 'True');
    AddLine('ShowFooter', 'False');
  end;
{$ENDIF}
  if ASpec.ComponentClass = TDACTabs then
  begin
    AddLine('Appearance', 'mtaSegmented');
    AddLine('Size', 'mtsLarge');
  end;
  Result := Result + 'end' + sLineBreak;
  if LPropertyCount = 0 then
    raise Exception.Create(ASpec.ComponentClass.ClassName +
      ' nao expos propriedade standalone para valor nao-default.');
end;

function DiagnoseStandaloneProperties(const ASpec: TClassSpec): string;
var
  LBinary: TMemoryStream;
  LComponent: TComponent;
  LText: TStringStream;

  procedure Probe(const AName, AValue: string);
  var
    LProbeText: string;
  begin
    if WritableProp(ASpec.ComponentClass, AName) = nil then
      Exit;
    LBinary := nil;
    LComponent := nil;
    LText := nil;
    try
      try
        LProbeText := 'object LifecycleProbe: ' +
          ASpec.ComponentClass.ClassName + sLineBreak + '  ' + AName +
          ' = ' + AValue + sLineBreak + 'end' + sLineBreak;
        LText := TStringStream.Create(LProbeText);
        LBinary := TMemoryStream.Create;
        ObjectTextToBinary(LText, LBinary);
        LBinary.Position := 0;
        LComponent := LBinary.ReadComponent(nil);
      except
        on E: Exception do
        begin
          if Result <> '' then
            Result := Result + ',';
          Result := Result + AName + '=' + E.ClassName;
        end;
      end;
    finally
      LComponent.Free;
      LBinary.Free;
      LText.Free;
    end;
  end;

begin
  Result := '';
  Probe('Tag', '1701');
  Probe('Left', '11');
  Probe('Top', '13');
  Probe('Width', '173');
  Probe('Height', '47');
  Probe('ThemeMode', 'dtmDark');
  Probe('Caption', '''Lifecycle DFM''');
  Probe('Text', '''Lifecycle DFM''');
  Probe('CornerRadius', '9');
end;

function DiagnoseReadableProperties(const AComponent: TComponent): string;
var
  I: Integer;
  LChildResult: string;
  LCount: Integer;
  LObject: TObject;
  LProp: PPropInfo;
  LProps: PPropList;
begin
  Result := '';
  if AComponent = nil then
    Exit;
  LCount := GetPropList(AComponent.ClassInfo, tkAny, nil);
  if LCount = 0 then
    Exit;
  GetMem(LProps, LCount * SizeOf(Pointer));
  try
    GetPropList(AComponent.ClassInfo, tkAny, LProps);
    for I := 0 to LCount - 1 do
    begin
      LProp := LProps^[I];
      try
        if not IsStoredProp(AComponent, LProp) then
          Continue;
        case LProp^.PropType^.Kind of
          tkInteger, tkChar, tkEnumeration, tkSet, tkWChar:
            GetOrdProp(AComponent, LProp);
          tkFloat:
            GetFloatProp(AComponent, LProp);
          tkString, tkLString, tkWString, tkUString:
            GetStrProp(AComponent, LProp);
          tkClass:
            begin
              LObject := GetObjectProp(AComponent, LProp);
              if LObject is TStrings then
                TStrings(LObject).Count;
            end;
          tkMethod:
            GetMethodProp(AComponent, LProp);
          tkInt64:
            GetInt64Prop(AComponent, LProp);
          tkVariant:
            GetVariantProp(AComponent, LProp);
        end;
      except
        on E: Exception do
        begin
          if Result <> '' then
            Result := Result + ',';
          Result := Result + string(LProp^.Name) + '=' + E.ClassName;
        end;
      end;
    end;
  finally
    FreeMem(LProps);
  end;
  for I := 0 to AComponent.ComponentCount - 1 do
  begin
    LChildResult := DiagnoseReadableProperties(AComponent.Components[I]);
    if LChildResult = '' then
      Continue;
    if Result <> '' then
      Result := Result + ',';
    Result := Result + AComponent.Components[I].ClassName + '{' +
      LChildResult + '}';
  end;
end;

procedure ValidateStreamedComponent(const AComponent: TComponent;
  const ASpec: TClassSpec);
var
  LProp: PPropInfo;
begin
  if AComponent = nil then
    raise Exception.Create('ReadComponent retornou nil.');
  if AComponent.ClassType <> ASpec.ComponentClass then
    raise Exception.Create('Classe desserializada divergente.');
  if AComponent.Name <> 'LifecycleProbe' then
    raise Exception.Create('Nome do root DFM nao foi preservado.');
  if (AComponent is TControl) and
    (TControl(AComponent).Parent <> nil) then
    raise Exception.Create('Streaming standalone atribuiu Parent.');
  if AComponent is TDACDateTimePickerPopup then
  begin
    if TCustomForm(AComponent).Visible then
      raise Exception.Create('Popup standalone ficou visivel sem Show.');
    if TWinControl(AComponent).HandleAllocated and
      IsWindowVisible(TWinControl(AComponent).Handle) then
      raise Exception.Create('Popup standalone criou top-level visivel.');
  end
  else
    RequireNoAllocatedHandles(AComponent);
  LProp := GetPropInfo(AComponent.ClassInfo, 'ThemeMode');
  if (LProp <> nil) and (GetOrdProp(AComponent, LProp) <> Ord(dtmDark)) then
    raise Exception.Create('ThemeMode nao preservou dtmDark no DFM.');
  LProp := GetPropInfo(AComponent.ClassInfo, 'Tag');
  if (LProp <> nil) and (GetOrdProp(AComponent, LProp) <> 1701) then
    raise Exception.Create('Tag nao preservou valor nao-default no DFM.');
{$IFDEF DAC_STAGE4_ONLY}
  LProp := GetPropInfo(AComponent.ClassInfo, 'DataField');
  if (LProp = nil) or (GetStrProp(AComponent, LProp) <> 'VALUE') then
    raise Exception.Create('DataField Stage4 nao sobreviveu ao DFM.');
  if AComponent is TDACDBDateTimePicker then
  begin
    if not TDACDBDateTimePicker(AComponent).AllowNull or
      (TDACDBDateTimePicker(AComponent).FormatString <> 'yyyy-MM-dd') or
      (TDACDBDateTimePicker(AComponent).PickerKind <> dtkTime) or
      not TDACDBDateTimePicker(AComponent).ReadOnly or
      (TDACDBDateTimePicker(AComponent).TimeStepMinutes <> 7) or
      TDACDBDateTimePicker(AComponent).IsNull = False then
      raise Exception.Create('Contrato DFM do Date Stage4 divergiu.');
  end
  else if AComponent is TDACDBCheckBox then
  begin
    if not TDACDBCheckBox(AComponent).AllowGrayed or
      (TDACDBCheckBox(AComponent).ValueChecked <> 'Y') or
      (TDACDBCheckBox(AComponent).ValueUnchecked <> 'N') or
      (TDACDBCheckBox(AComponent).ValueGrayed <> 'G') then
      raise Exception.Create('Contrato DFM do CheckBox Stage4 divergiu.');
  end
  else if AComponent is TDACDBRadioButton then
  begin
    if TDACDBRadioButton(AComponent).Value <> 'Selected' then
      raise Exception.Create('Contrato DFM do Radio Stage4 divergiu.');
  end
  else if AComponent is TDACDBToggleSwitch then
  begin
    if (TDACDBToggleSwitch(AComponent).ValueOn <> 'Y') or
      (TDACDBToggleSwitch(AComponent).ValueOff <> 'N') then
      raise Exception.Create('Contrato DFM do Toggle Stage4 divergiu.');
  end
  else if AComponent is TDACDBSlider then
  begin
    if (TDACDBSlider(AComponent).Minimum <> 10) or
      (TDACDBSlider(AComponent).Maximum <> 90) or
      TDACDBSlider(AComponent).ShowValue or
      (TDACDBSlider(AComponent).ValueScale <> 0.5) or
      not TDACDBSlider(AComponent).IsNull then
      raise Exception.Create('Contrato DFM do Slider Stage4 divergiu.');
  end;
{$ENDIF}
{$IFDEF DAC_STAGE5_ONLY}
  if AComponent is TDACDBLookupComboBox then
  begin
    if TDACDBLookupComboBox.ClassParent <> TDBLookupComboBox then
      raise Exception.Create('Lookup Stage5 nao e descendente direto nativo.');
    if (TDACDBLookupComboBox(AComponent).LookupControl <> AComponent) or
      (TDACDBLookupComboBox(AComponent).DataField <> 'VALUE') or
      (TDACDBLookupComboBox(AComponent).KeyField <> 'ID') or
      (TDACDBLookupComboBox(AComponent).ListField <> 'NAME;CODE') or
      (TDACDBLookupComboBox(AComponent).ListFieldIndex <> 1) or
      (TDACDBLookupComboBox(AComponent).DropDownRows <> 9) or
      (TDACDBLookupComboBox(AComponent).DropDownWidth <> 240) or
      not TDACDBLookupComboBox(AComponent).ReadOnly then
      raise Exception.Create('Contrato DFM do Lookup Stage5 divergiu.');
  end
  else if AComponent is TDACDBNavigator then
  begin
    if not TDACDBNavigator.InheritsFrom(TDBNavigator) or
      TDACDBNavigator(AComponent).ConfirmDelete or
      (TDACDBNavigator(AComponent).VisibleButtons <>
        [nbFirst, nbNext, nbLast]) then
      raise Exception.Create('Contrato DFM do Navigator Stage5 divergiu.');
  end
  else if AComponent is TDACDataGrid then
  begin
    if not TDACDataGrid.InheritsFrom(TDBGrid) or
      (TDACDataGrid(AComponent).FooterText <> 'Total') or
      (TDACDataGrid(AComponent).FooterValue <> '42') or
      not TDACDataGrid(AComponent).Loading or
      TDACDataGrid(AComponent).ShowFooter then
      raise Exception.Create('Contrato DFM da DataGrid Stage5 divergiu.');
  end;
{$ENDIF}
  if AComponent is TDACTabs then
    if (TDACTabs(AComponent).Appearance <> mtaSegmented) or
      (TDACTabs(AComponent).Size <> mtsLarge) then
      raise Exception.Create(
        'Appearance/Size nao default nao sobreviveram ao round-trip DFM.');
end;

procedure RunStandaloneDfm(const ARound: Integer; const ASpec: TClassSpec);
var
  LBinary: TMemoryStream;
  LClone: TComponent;
  LComponent: TComponent;
  LError: string;
  LStage: string;
  LText: TStringStream;
  LWindowBefore: Integer;
  LWindowAfter: Integer;

  procedure RegisterOwnedClasses(const ARoot: TComponent);
  var
    I: Integer;
    LClass: TPersistentClass;
  begin
    for I := 0 to ARoot.ComponentCount - 1 do
    begin
      LClass := TPersistentClass(ARoot.Components[I].ClassType);
      if System.Classes.GetClass(LClass.ClassName) = nil then
        System.Classes.RegisterClass(LClass);
      RegisterOwnedClasses(ARoot.Components[I]);
    end;
  end;
begin
  LBinary := nil;
  LClone := nil;
  LComponent := nil;
  LText := nil;
  LError := '';
  LStage := 'ObjectTextToBinary';
  GAsyncException := '';
  LWindowBefore := ThreadWindowCount;
  try
    try
      LText := TStringStream.Create(BuildStandaloneDfm(ASpec));
      LBinary := TMemoryStream.Create;
      ObjectTextToBinary(LText, LBinary);
      LBinary.Position := 0;
      LStage := 'ReadComponent';
      LComponent := LBinary.ReadComponent(nil);
      LStage := 'ValidateFirst';
      ValidateStreamedComponent(LComponent, ASpec);
      if LComponent is TDACDBLookupComboBox then
      begin
        { TDBLookupComboBox owns a private TPopupDataList. A standalone
          WriteComponent serializes that native implementation child, unlike
          a form designer stream. Re-read the authored DFM to validate the
          public component contract without treating the VCL popup as ours. }
        LStage := 'ReadSecondAuthoredDFM';
        LText.Free;
        LText := TStringStream.Create(BuildStandaloneDfm(ASpec));
        LBinary.Clear;
        ObjectTextToBinary(LText, LBinary);
        LBinary.Position := 0;
        LClone := LBinary.ReadComponent(nil);
      end
      else
      begin
      LStage := 'WriteComponent';
      RegisterOwnedClasses(LComponent);
      LBinary.Clear;
      LBinary.WriteComponent(LComponent);
      LBinary.Position := 0;
      LStage := 'ReadClone';
      LClone := LBinary.ReadComponent(nil);
      end;
      LStage := 'ValidateClone';
      ValidateStreamedComponent(LClone, ASpec);
    except
      on E: Exception do
      begin
        LError := LStage + ' ' + E.ClassName + ': ' + E.Message;
        if (LStage = 'WriteComponent') and (LComponent <> nil) then
          LError := LError + ' | ReadableProbe=' +
            DiagnoseReadableProperties(LComponent);
      end;
    end;
  finally
    LClone.Free;
    LComponent.Free;
    LBinary.Free;
    LText.Free;
  end;
  AppendAsyncException(LError);
  LWindowAfter := ThreadWindowCount;
  if LWindowAfter > LWindowBefore then
  begin
    if LError <> '' then
      LError := LError + ' | ';
    LError := LError + 'Streaming criou HWND top-level inesperado.';
  end;
  if LError = '' then
    Writeln(IntToStr(ARound) + #9 + ASpec.ComponentClass.ClassName + #9 +
      ASpec.Family + #9 + BoolText(ASpec.Registered) + #9 +
      'StandaloneDFM.RoundTrip' + #9 + 'PASS' + #9 + '')
  else
  begin
    LError := LError + ' | PropertyProbe=' +
      DiagnoseStandaloneProperties(ASpec);
    Inc(GFailures);
    Writeln(IntToStr(ARound) + #9 + ASpec.ComponentClass.ClassName + #9 +
      ASpec.Family + #9 + BoolText(ASpec.Registered) + #9 +
      'StandaloneDFM.RoundTrip' + #9 + 'FAIL' + #9 + CleanText(LError));
  end;
end;

function IsDataAwareClass(const AClass: TComponentClass): Boolean;
begin
  Result := AClass.InheritsFrom(TDACDBEdit) or
    AClass.InheritsFrom(TDACDBMemo) or
    AClass.InheritsFrom(TDACDBButtonEdit) or
    AClass.InheritsFrom(TDACDBText) or
    AClass.InheritsFrom(TDACDBComboBox) or
    AClass.InheritsFrom(TDACDBLookupComboBox) or
    AClass.InheritsFrom(TDACDBNavigator) or
    AClass.InheritsFrom(TDACDBDateTimePicker) or
    AClass.InheritsFrom(TDACDBCheckBox) or
    AClass.InheritsFrom(TDACDBRadioButton) or
    AClass.InheritsFrom(TDACDBToggleSwitch) or
    AClass.InheritsFrom(TDACDBSlider) or
    AClass.InheritsFrom(TDACDataGrid);
end;

procedure PrepareDataSet(const AClass: TComponentClass;
  const ADataSet: TClientDataSet);
begin
  if AClass.InheritsFrom(TDACDBDateTimePicker) then
    ADataSet.FieldDefs.Add('VALUE', ftDateTime)
  else if AClass.InheritsFrom(TDACDBCheckBox) or
    AClass.InheritsFrom(TDACDBRadioButton) or
    AClass.InheritsFrom(TDACDBToggleSwitch) then
    ADataSet.FieldDefs.Add('VALUE', ftBoolean)
  else if AClass.InheritsFrom(TDACDBSlider) then
    ADataSet.FieldDefs.Add('VALUE', ftInteger)
  else if AClass.InheritsFrom(TDACDBLookupComboBox) then
    ADataSet.FieldDefs.Add('VALUE', ftInteger)
  else
    ADataSet.FieldDefs.Add('VALUE', ftString, 64);
  ADataSet.CreateDataSet;
  ADataSet.Append;
  if AClass.InheritsFrom(TDACDBDateTimePicker) then
    ADataSet.FieldByName('VALUE').AsDateTime := EncodeDate(2026, 7, 23)
  else if AClass.InheritsFrom(TDACDBCheckBox) or
    AClass.InheritsFrom(TDACDBRadioButton) or
    AClass.InheritsFrom(TDACDBToggleSwitch) then
    ADataSet.FieldByName('VALUE').AsBoolean := True
  else if AClass.InheritsFrom(TDACDBSlider) then
    ADataSet.FieldByName('VALUE').AsInteger := 37
  else if AClass.InheritsFrom(TDACDBLookupComboBox) then
    ADataSet.FieldByName('VALUE').AsInteger := 1
  else
    ADataSet.FieldByName('VALUE').AsString := 'Lifecycle';
  ADataSet.Post;
end;

procedure RunDataAware(const ARound: Integer; const ASpec: TClassSpec);
var
  LComponent: TComponent;
  LDataSet: TClientDataSet;
  LDataSource: TDataSource;
  LError: string;
  LListDataSet: TClientDataSet;
  LListSource: TDataSource;
  LProp: PPropInfo;
  LSecondDataSource: TDataSource;
  LSecondListSource: TDataSource;
  LStage: string;
begin
  if not IsDataAwareClass(ASpec.ComponentClass) then
    Exit;
  LComponent := nil;
  LDataSet := nil;
  LDataSource := nil;
  LListDataSet := nil;
  LListSource := nil;
  LSecondDataSource := nil;
  LSecondListSource := nil;
  LError := '';
  LStage := 'CreateDataSet';
  GAsyncException := '';
  try
    try
      LDataSet := TClientDataSet.Create(nil);
      LStage := 'PrepareDataSet';
      PrepareDataSet(ASpec.ComponentClass, LDataSet);
      LStage := 'CreateDataSource';
      LDataSource := TDataSource.Create(nil);
      LDataSource.DataSet := LDataSet;
      LStage := 'CreateComponent';
      LComponent := ASpec.ComponentClass.Create(nil);
      LStage := 'SetDataField';
      LProp := GetPropInfo(LComponent.ClassInfo, 'DataField');
      if LProp <> nil then
        SetStrProp(LComponent, LProp, 'VALUE');
      LStage := 'SetDataSource';
      LProp := GetPropInfo(LComponent.ClassInfo, 'DataSource');
      if LProp = nil then
        raise Exception.Create('DataSource nao publicado.');
      SetObjectProp(LComponent, LProp, LDataSource);
      if GetObjectProp(LComponent, LProp) <> LDataSource then
        raise Exception.Create('DataSource/DataField nao foram vinculados.');
      LStage := 'RebindDataSource';
      LSecondDataSource := TDataSource.Create(nil);
      LSecondDataSource.DataSet := LDataSet;
      SetObjectProp(LComponent, LProp, LSecondDataSource);
      if GetObjectProp(LComponent, LProp) <> LSecondDataSource then
        raise Exception.Create('Rebind para o segundo DataSource falhou.');
      LStage := 'BeforeNotification';
      RequireNoAllocatedHandles(LComponent);
      LStage := 'FreePreviousDataSource';
      LDataSource.Free;
      LDataSource := nil;
      if GetObjectProp(LComponent, LProp) <> LSecondDataSource then
        raise Exception.Create('Destroy do DataSource anterior removeu o rebind atual.');
      if ASpec.ComponentClass.InheritsFrom(TDACDBLookupComboBox) then
      begin
        LStage := 'LookupListSourceRebind';
        LListDataSet := TClientDataSet.Create(nil);
        LListDataSet.FieldDefs.Add('ID', ftInteger);
        LListDataSet.FieldDefs.Add('NAME', ftString, 32);
        LListDataSet.FieldDefs.Add('CODE', ftString, 8);
        LListDataSet.CreateDataSet;
        LListDataSet.AppendRecord([1, 'Lifecycle', 'LC']);
        LListSource := TDataSource.Create(nil);
        LListSource.DataSet := LListDataSet;
        LSecondListSource := TDataSource.Create(nil);
        LSecondListSource.DataSet := LListDataSet;
        LProp := GetPropInfo(LComponent.ClassInfo, 'ListSource');
        SetStrProp(LComponent,
          GetPropInfo(LComponent.ClassInfo, 'KeyField'), 'ID');
        SetStrProp(LComponent,
          GetPropInfo(LComponent.ClassInfo, 'ListField'), 'NAME;CODE');
        SetObjectProp(LComponent, LProp, LListSource);
        SetObjectProp(LComponent, LProp, LSecondListSource);
        LListSource.Free;
        LListSource := nil;
        if GetObjectProp(LComponent, LProp) <> LSecondListSource then
          raise Exception.Create('Destroy do ListSource anterior removeu o rebind atual.');
        LSecondListSource.Free;
        LSecondListSource := nil;
        if GetObjectProp(LComponent, LProp) <> nil then
          raise Exception.Create('Notification nao removeu ListSource destruido.');
        LProp := GetPropInfo(LComponent.ClassInfo, 'DataSource');
      end;
      LStage := 'FreeCurrentDataSource';
      LSecondDataSource.Free;
      LSecondDataSource := nil;
      LStage := 'ValidateNotification';
      if GetObjectProp(LComponent, LProp) <> nil then
        raise Exception.Create('Notification nao removeu DataSource destruido.');
      RequireNoAllocatedHandles(LComponent);
    except
      on E: Exception do
        LError := LStage + ' ' + E.ClassName + ': ' + E.Message;
    end;
  finally
    LComponent.Free;
    LSecondListSource.Free;
    LListSource.Free;
    LListDataSet.Free;
    LSecondDataSource.Free;
    LDataSource.Free;
    LDataSet.Free;
  end;
  AppendAsyncException(LError);
  if LError = '' then
    Writeln(IntToStr(ARound) + #9 + ASpec.ComponentClass.ClassName + #9 +
      ASpec.Family + #9 + BoolText(ASpec.Registered) + #9 +
      'DataSource.DataField.Notification' + #9 + 'PASS' + #9 + '')
  else
  begin
    Inc(GFailures);
    Writeln(IntToStr(ARound) + #9 + ASpec.ComponentClass.ClassName + #9 +
      ASpec.Family + #9 + BoolText(ASpec.Registered) + #9 +
      'DataSource.DataField.Notification' + #9 + 'FAIL' + #9 +
      CleanText(LError));
  end;
end;

{$IFDEF DAC_STAGE5_ONLY}
procedure RunStage5WindowLifecycle(const ARound: Integer;
  const ASpec: TClassSpec);
var
  LComponent: TComponent;
  LDataSet: TClientDataSet;
  LDataSource: TDataSource;
  LError: string;
  LHost: TForm;
  LListDataSet: TClientDataSet;
  LListSource: TDataSource;
  LProp: PPropInfo;
begin
  LComponent := nil;
  LDataSet := TClientDataSet.Create(nil);
  LDataSource := TDataSource.Create(nil);
  LHost := TForm.CreateNew(nil);
  LListDataSet := nil;
  LListSource := nil;
  LError := '';
  try
    try
      PrepareDataSet(ASpec.ComponentClass, LDataSet);
      LDataSource.DataSet := LDataSet;
      LComponent := ASpec.ComponentClass.Create(nil);
      LProp := GetPropInfo(LComponent.ClassInfo, 'DataSource');
      SetObjectProp(LComponent, LProp, LDataSource);
      LProp := GetPropInfo(LComponent.ClassInfo, 'DataField');
      if LProp <> nil then
        SetStrProp(LComponent, LProp, 'VALUE');
      if LComponent is TDACDBLookupComboBox then
      begin
        LListDataSet := TClientDataSet.Create(nil);
        LListDataSet.FieldDefs.Add('ID', ftInteger);
        LListDataSet.FieldDefs.Add('NAME', ftString, 32);
        LListDataSet.CreateDataSet;
        LListDataSet.AppendRecord([1, 'Lifecycle']);
        LListSource := TDataSource.Create(nil);
        LListSource.DataSet := LListDataSet;
        TDACDBLookupComboBox(LComponent).KeyField := 'ID';
        TDACDBLookupComboBox(LComponent).ListField := 'NAME';
        TDACDBLookupComboBox(LComponent).ListSource := LListSource;
      end;
      TControl(LComponent).Parent := LHost;
      LHost.Handle;
      TWinControl(LComponent).Handle;
      if not TWinControl(LComponent).HandleAllocated then
        raise Exception.Create('Attach nao materializou HWND.');
      TWinControlAccess(LComponent).ForceRecreateWnd;
      TWinControl(LComponent).Handle;
      if not TWinControl(LComponent).HandleAllocated then
        raise Exception.Create('RecreateWnd perdeu HWND.');
      TControl(LComponent).Parent := nil;
      if TWinControl(LComponent).HandleAllocated then
        raise Exception.Create('Detach preservou HWND filho.');
      TControl(LComponent).Parent := LHost;
      TWinControl(LComponent).Handle;
      LComponent.Free;
      LComponent := nil;
      LListSource.Free;
      LListSource := nil;
      LDataSource.Free;
      LDataSource := nil;
    except
      on E: Exception do
        LError := E.ClassName + ': ' + E.Message;
    end;
  finally
    LComponent.Free;
    LListSource.Free;
    LListDataSet.Free;
    LDataSource.Free;
    LDataSet.Free;
    LHost.Free;
    Application.ProcessMessages;
  end;
  if LError = '' then
    Writeln(IntToStr(ARound) + #9 + ASpec.ComponentClass.ClassName + #9 +
      ASpec.Family + #9 + BoolText(ASpec.Registered) + #9 +
      'Attach.Detach.RecreateWnd.DestroyOrders' + #9 + 'PASS' + #9 + '')
  else
  begin
    Inc(GFailures);
    Writeln(IntToStr(ARound) + #9 + ASpec.ComponentClass.ClassName + #9 +
      ASpec.Family + #9 + BoolText(ASpec.Registered) + #9 +
      'Attach.Detach.RecreateWnd.DestroyOrders' + #9 + 'FAIL' + #9 +
      CleanText(LError));
  end;
end;
{$ENDIF}

procedure WriteFormEvidence(const ARound: Integer; const AClassName,
  AScenario, AError: string; const AHandleAllocated, AVisible: Boolean;
  const ALiveWindowDelta, AFinalWindowDelta: Integer);
var
  LMessage: string;
begin
  LMessage := 'HandleAllocated=' + BoolText(AHandleAllocated) +
    ';Visible=' + BoolText(AVisible) + ';LiveWindowDelta=' +
    IntToStr(ALiveWindowDelta) + ';FinalWindowDelta=' +
    IntToStr(AFinalWindowDelta);
  if AError = '' then
    Writeln(IntToStr(ARound) + #9 + AClassName + #9 +
      'Evidence.Control' + #9 + 'N/A' + #9 + AScenario + #9 + 'PASS' +
      #9 + LMessage)
  else
  begin
    Inc(GFailures);
    Writeln(IntToStr(ARound) + #9 + AClassName + #9 +
      'Evidence.Control' + #9 + 'N/A' + #9 + AScenario + #9 + 'FAIL' +
      #9 + CleanText(AError + ' | ' + LMessage));
  end;
end;

procedure RunNativePageControlEvidence(const ARound: Integer);
var
  LBinary: TMemoryStream;
  LComponent: TComponent;
  LError: string;
  LHandleAllocated: Boolean;
  LText: TStringStream;
  LVisible: Boolean;
  LWindowAfter: Integer;
  LWindowBefore: Integer;
  LWindowLive: Integer;
begin
  LBinary := nil;
  LComponent := nil;
  LError := '';
  LHandleAllocated := False;
  LText := nil;
  LVisible := False;
  LWindowBefore := ThreadWindowCount;
  try
    try
      LText := TStringStream.Create(
        'object NativeForm: TForm' + sLineBreak +
        '  object NativePages: TPageControl' + sLineBreak +
        '    ActivePage = NativeOne' + sLineBreak +
        '    object NativeOne: TTabSheet' + sLineBreak +
        '      Caption = ''One''' + sLineBreak +
        '    end' + sLineBreak +
        '    object NativeTwo: TTabSheet' + sLineBreak +
        '      Caption = ''Two''' + sLineBreak +
        '    end' + sLineBreak +
        '  end' + sLineBreak +
        'end' + sLineBreak);
      LBinary := TMemoryStream.Create;
      ObjectTextToBinary(LText, LBinary);
      LBinary.Position := 0;
      LComponent := LBinary.ReadComponent(nil);
      if not (LComponent is TForm) then
        raise Exception.Create('Controle nativo nao retornou TForm.');
      LHandleAllocated := TForm(LComponent).HandleAllocated;
      LVisible := TForm(LComponent).Visible;
    except
      on E: Exception do
        LError := E.ClassName + ': ' + E.Message;
    end;
    LWindowLive := ThreadWindowCount;
  finally
    LComponent.Free;
    LBinary.Free;
    LText.Free;
  end;
  LWindowAfter := ThreadWindowCount;
  WriteFormEvidence(ARound, 'TForm/TPageControl',
    'Evidence.NativePageControlDFM', LError, LHandleAllocated, LVisible,
    LWindowLive - LWindowBefore, LWindowAfter - LWindowBefore);
end;

{$IFNDEF DAC_STAGE4_ONLY}
{$IFNDEF DAC_STAGE5_ONLY}
procedure RunDemoWithoutBuildersEvidence(const ARound: Integer);
var
  LBinary: TMemoryStream;
  LError: string;
  LFile: TFileStream;
  LForm: TForm1NoBuilders;
  LHandleAllocated: Boolean;
  LPath: string;
  LVisible: Boolean;
  LWindowAfter: Integer;
  LWindowBefore: Integer;
  LWindowLive: Integer;
begin
  LBinary := nil;
  LError := '';
  LFile := nil;
  LForm := nil;
  LHandleAllocated := False;
  LVisible := False;
  LPath := ExpandFileName(ExtractFilePath(ParamStr(0)) +
    '..\..\..\..\..\demo\Demo.Principal.dfm');
  LWindowBefore := ThreadWindowCount;
  try
    try
      if not FileExists(LPath) then
        raise Exception.Create('Demo DFM nao encontrado em ' + LPath);
      LFile := TFileStream.Create(LPath, fmOpenRead or fmShareDenyWrite);
      LBinary := TMemoryStream.Create;
      ObjectTextToBinary(LFile, LBinary);
      LBinary.Position := 0;
      LForm := TForm1NoBuilders.CreateNew(nil);
      LBinary.ReadComponent(LForm);
      LHandleAllocated := LForm.HandleAllocated;
      LVisible := LForm.Visible;
    except
      on E: Exception do
        LError := E.ClassName + ': ' + E.Message;
    end;
    LWindowLive := ThreadWindowCount;
  finally
    LForm.Free;
    LBinary.Free;
    LFile.Free;
  end;
  LWindowAfter := ThreadWindowCount;
  WriteFormEvidence(ARound, 'Demo.Principal.NoBuilders',
    'Evidence.DemoDFMWithoutBuilders', LError, LHandleAllocated, LVisible,
    LWindowLive - LWindowBefore, LWindowAfter - LWindowBefore);
end;

procedure RunFullDemoDfm(const ARound: Integer);
var
  LButtonEditDefault: TDACButtonEdit;
  LButtonEditDisabled: TDACButtonEdit;
  LButtonEditError: TDACButtonEdit;
  LButtonEditFilled: TDACButtonEdit;
  LButtonEditLoading: TDACButtonEdit;
  LButtonEditReadOnly: TDACButtonEdit;
  LButtonEditSuccess: TDACButtonEdit;
  LComboLoading: TDACComboBox;
  LDateDefault: TDACDateTimePicker;
  LDateFilled: TDACDateTimePicker;
  LDateLoading: TDACDateTimePicker;
  LEditLoading: TDACEdit;
  LError: string;
  LForm: TForm1;
  LMemoLoading: TDACMemo;
  LRootHandleAllocated: Boolean;
  LStage: string;
  LTabs: TDACTabs;
  LVisibleAfter: Integer;
  LVisibleBefore: Integer;
  LVisibleLive: Integer;
  LWindowAfter: Integer;
  LWindowBefore: Integer;
  LWindowLive: Integer;
  procedure RequireInputComposition;
  const
    InputNames: array[0..20] of string = (
      'demoEdit', 'demoEditFilled', 'demoEditError', 'demoEditSuccess',
      'demoEditDisabled', 'demoEditReadOnly', 'demoEditLoading',
      'demoMemo', 'demoMemoFilled', 'demoMemoError', 'demoMemoSuccess',
      'demoMemoDisabled', 'demoMemoReadOnly', 'demoMemoLoading',
      'demoButtonEdit', 'demoButtonEditFilled', 'demoButtonEditError',
      'demoButtonEditSuccess', 'demoButtonEditDisabled',
      'demoButtonEditReadOnly', 'demoButtonEditLoading');
  var
    I: Integer;
    LAuthoredCount: Integer;
    LControl: TControl;
    LGrid: TDACGridContainer;
    LScroll: TDACScrollContainer;
  begin
    LScroll := LForm.FindComponent('scrInputs') as TDACScrollContainer;
    LGrid := LForm.FindComponent('gcInputStates') as TDACGridContainer;
    if (LScroll = nil) or (LGrid = nil) or (LGrid.Parent <> LScroll) or
      (LGrid.Align <> alTop) or not LGrid.AutoContentHeight or
      not LGrid.SizeRowsToContent or (LGrid.Columns <> 7) or
      (LGrid.MinimumColumnWidth <> 180) then
      raise Exception.Create(
        'Inputs perdeu composicao DFM Scroll/Grid ou sizing declarativo.');
    LAuthoredCount := 0;
    for I := 0 to LGrid.ControlCount - 1 do
      if not (LGrid.Controls[I] is TSkPaintBox) then
        Inc(LAuthoredCount);
    if LAuthoredCount <> 25 then
      raise Exception.CreateFmt(
        'Grid de Inputs deve conter 21 estados + 4 titulos; actual=%d.',
        [LAuthoredCount]);
    for I := Low(InputNames) to High(InputNames) do
    begin
      LControl := LForm.FindComponent(InputNames[I]) as TControl;
      if (LControl = nil) or (LControl.Parent <> LGrid) or
        not (LControl is TWinControl) or
        (TWinControl(LControl).TabOrder <> I) or
        (LControl.Constraints.MinWidth <> 180) then
        raise Exception.CreateFmt(
          'Input %s perdeu Parent/TabOrder/MinWidth no DFM.',
          [InputNames[I]]);
    end;
    if LGrid.HandleAllocated or LScroll.HandleAllocated then
      raise Exception.Create(
        'Composicao DFM de Inputs alocou HWND antes de Show.');
  end;
  procedure RequireGalleryMode(const AMode: TDACThemeMode);
  var
    I: Integer;
    LExpectedBackground: TColor;
    LExpectedText: TColor;
    LPage: TTabSheet;
    LTokens: TDACControlTokens;
  begin
    TDACThemeManager.SetApplicationMode(AMode);
    TDACThemeManager.RefreshListener(LTabs);
    LTokens := TDACComponentStyle.Resolve(AMode).Tokens.Controls;
    LExpectedBackground := TDACComponentColors.ToVclColor(
      LTokens.ContainerSuiteBackground);
    LExpectedText := TDACComponentColors.ToVclColor(LTokens.ContainerTitle);
    if LTabs.PageCount <> 17 then
      raise Exception.Create(
        'GalleryTabs nao preservou Dashboard + 16 paginas.');
    if LTabs.StyleElements <> [] then
      raise Exception.Create(
        'GalleryTabs nao fixou StyleElements no construtor pre-HWND.');
    for I := 0 to LTabs.PageCount - 1 do
    begin
      LPage := LTabs.Pages[I];
      if TTabSheetAccess(LPage).ParentColor or
        (TTabSheetAccess(LPage).Color <> LExpectedBackground) or
        LPage.ParentFont or
        (LPage.Font.Color <> LExpectedText) then
        raise Exception.Create(Format(
          'Pagina %d/%s nao recebeu theme boundary %d sem handle.',
          [I, LPage.Name, Ord(AMode)]));
      if TTabSheetAccess(LPage).ParentBackground or
        (TTabSheetAccess(LPage).StyleElements <> []) then
        raise Exception.Create(Format(
          'Pagina %d/%s nao aplicou StyleElements/ParentBackground do host real.',
          [I, LPage.Name]));
    end;
    { The full Demo constructor materializes its hidden Data-Aware native
      subtree while binding the DFM-owned TClientDataSet. Standalone
      component/DFM gates above remain the Parent=nil/no-HWND authority; the
      full-form gate instead proves invisible top-level and final teardown. }
  end;
begin
  LError := '';
  LForm := nil;
  LRootHandleAllocated := False;
  LStage := 'CreateForm.ReadDemoDFM';
  GAsyncException := '';
  LVisibleBefore := VisibleThreadWindowCount;
  LWindowBefore := ThreadWindowCount;
  LWindowLive := LWindowBefore;
  try
    try
      LForm := TForm1.Create(nil);
      LStage := 'ValidateComponentCount';
      if LForm.ComponentCount = 0 then
        raise Exception.Create('Demo DFM nao criou componentes.');
      LStage := 'ValidateInputComposition';
      RequireInputComposition;
      LStage := 'ValidateButtonEditMatrix';
      LButtonEditDefault := LForm.FindComponent('demoButtonEdit') as TDACButtonEdit;
      LButtonEditFilled := LForm.FindComponent('demoButtonEditFilled') as TDACButtonEdit;
      LButtonEditError := LForm.FindComponent('demoButtonEditError') as TDACButtonEdit;
      LButtonEditSuccess := LForm.FindComponent('demoButtonEditSuccess') as TDACButtonEdit;
      LButtonEditDisabled := LForm.FindComponent('demoButtonEditDisabled') as TDACButtonEdit;
      LButtonEditReadOnly := LForm.FindComponent('demoButtonEditReadOnly') as TDACButtonEdit;
      LButtonEditLoading := LForm.FindComponent('demoButtonEditLoading') as TDACButtonEdit;
      if (LButtonEditDefault = nil) or (LButtonEditFilled = nil) or
        (LButtonEditError = nil) or (LButtonEditSuccess = nil) or
        (LButtonEditDisabled = nil) or (LButtonEditReadOnly = nil) or
        (LButtonEditLoading = nil) then
        raise Exception.Create('Matriz ButtonEdit incompleta no DFM.');
      if (LButtonEditFilled.Text = '') or
        (LButtonEditError.Status <> mesDanger) or
        (LButtonEditError.ErrorText = '') or
        (LButtonEditSuccess.Status <> mesSuccess) or
        (LButtonEditSuccess.HelperText = '') or
        LButtonEditDisabled.Enabled or
        not LButtonEditReadOnly.ReadOnly or
        not LButtonEditLoading.Loading then
        raise Exception.Create('Matriz ButtonEdit perdeu seus estados declarativos.');
      LStage := 'ValidateDateFilled';
      LDateDefault := LForm.FindComponent('demoDateTime') as TDACDateTimePicker;
      LDateFilled := LForm.FindComponent('demoDateTimeFilled') as TDACDateTimePicker;
      if (LDateDefault = nil) or (LDateFilled = nil) then
        raise Exception.Create('Estados Default/Filled do DateTimePicker ausentes.');
      if LDateFilled.DateTime = LDateDefault.DateTime then
        raise Exception.Create('DateTime Filled nao se distingue do Default.');
      LStage := 'ValidateLoadingTabPolicy';
      LEditLoading := LForm.FindComponent('demoEditLoading') as TDACEdit;
      LMemoLoading := LForm.FindComponent('demoMemoLoading') as TDACMemo;
      LComboLoading := LForm.FindComponent('demoComboLoading') as TDACComboBox;
      LDateLoading := LForm.FindComponent('demoDateTimeLoading') as TDACDateTimePicker;
      if (LEditLoading = nil) or (LMemoLoading = nil) or
        (LComboLoading = nil) or (LDateLoading = nil) then
        raise Exception.Create('Matriz Loading incompleta no DFM.');
      if LEditLoading.TabStop or LButtonEditLoading.TabStop or
        LMemoLoading.TabStop or LComboLoading.TabStop or
        LDateLoading.TabStop then
        raise Exception.Create('Campo Loading permaneceu na ordem de Tab.');
      LEditLoading.Loading := False;
      LButtonEditLoading.Loading := False;
      LMemoLoading.Loading := False;
      LComboLoading.Loading := False;
      LDateLoading.Loading := False;
      if not LEditLoading.TabStop or not LButtonEditLoading.TabStop or
        not LMemoLoading.TabStop or not LComboLoading.TabStop or
        not LDateLoading.TabStop then
        raise Exception.Create('Campo nao restaurou TabStop apos Loading streamed.');
      LStage := 'ValidateFullGalleryThemeBoundary';
      LTabs := LForm.FindComponent('GalleryTabs') as TDACTabs;
      if LTabs = nil then
        raise Exception.Create('GalleryTabs ausente no DFM completo.');
      RequireGalleryMode(dtmLight);
      RequireGalleryMode(dtmDark);
      RequireGalleryMode(dtmLight);
      LStage := 'ValidateParent';
      if LForm.Parent <> nil then
        raise Exception.Create('Demo form recebeu Parent inesperado.');
      LRootHandleAllocated := LForm.HandleAllocated;
      LStage := 'ValidateNotVisible';
      if LForm.Visible then
        raise Exception.Create('Demo form ficou visivel sem Show.');
      if LRootHandleAllocated and IsWindowVisible(LForm.Handle) then
        raise Exception.Create('Root TForm possui janela visivel sem Show.');
      LStage := 'ValidateNativeChildHandlesRemainHidden';
      LStage := 'ValidateNoVisibleTopLevel';
      LVisibleLive := VisibleThreadWindowCount;
      LWindowLive := ThreadWindowCount;
      if LVisibleLive <> LVisibleBefore then
        raise Exception.Create('Janela top-level visivel; VisibleDelta=' +
          IntToStr(LVisibleLive - LVisibleBefore) + ';Windows=' +
          ThreadWindowSnapshot + ';Controls=' +
          AllocatedControlSnapshot(LForm));
    except
      on E: Exception do
        LError := LStage + ' ' + E.ClassName + ': ' + E.Message;
    end;
  finally
    try
      LStage := 'DestroyForm';
      LForm.Free;
    except
      on E: Exception do
      begin
        if LError <> '' then
          LError := LError + ' | ';
        LError := LError + LStage + ' ' + E.ClassName + ': ' + E.Message;
      end;
    end;
  end;
  AppendAsyncException(LError);
  LVisibleAfter := VisibleThreadWindowCount;
  LWindowAfter := ThreadWindowCount;
  if LWindowAfter <> LWindowBefore then
  begin
    if LError <> '' then
      LError := LError + ' | ';
    LError := LError + 'WindowDelta=' +
      IntToStr(LWindowAfter - LWindowBefore);
  end;
  if LVisibleAfter <> LVisibleBefore then
  begin
    if LError <> '' then
      LError := LError + ' | ';
    LError := LError + 'VisibleWindowDeltaAfterFree=' +
      IntToStr(LVisibleAfter - LVisibleBefore);
  end;
  if LError = '' then
    Writeln(IntToStr(ARound) + #9 + 'Demo.Principal.dfm' + #9 +
      'All15Families' + #9 + 'yes' + #9 + 'FullDemoDFM' + #9 +
      'PASS' + #9 +
      'Parent=nil;RootHandleAllowedByNativeBaseline=' +
      BoolText(LRootHandleAllocated) +
      ';NativeDataAwareChildHandlesAllowed=True;LiveWindowDelta=' +
      IntToStr(LWindowLive - LWindowBefore) +
      ';VisibleWindowDelta=0;FinalWindowDelta=0;TopLevelVisible=False')
  else
  begin
    Inc(GFailures);
    Writeln(IntToStr(ARound) + #9 + 'Demo.Principal.dfm' + #9 +
      'All15Families' + #9 + 'yes' + #9 + 'FullDemoDFM' + #9 +
      'FAIL' + #9 + CleanText(LError));
  end;
end;
{$ENDIF}
{$ENDIF}

procedure RunTabsChildrenDfm(const ARound: Integer);
var
  LBinary: TMemoryStream;
  LComponent: TComponent;
  LError: string;
  LStage: string;
  LText: TStringStream;
  LTabs: TDACTabs;
  LWindowAfter: Integer;
  LWindowBefore: Integer;

  function DiagnoseManualChildren: string;
  var
    LManualTabs: TDACTabs;
    LSheet: TTabSheet;
    LStage: string;
  begin
    Result := '';
    LManualTabs := nil;
    LStage := 'CreateTabs';
    try
      try
        LManualTabs := TDACTabs.Create(nil);
        LStage := 'SetTabHeight';
        LManualTabs.TabHeight := 44;
        LStage := 'SetTabWidth';
        LManualTabs.TabWidth := 132;
        LStage := 'CreateFirstSheet';
        LSheet := TTabSheet.Create(LManualTabs);
        LStage := 'AttachFirstSheet';
        LSheet.PageControl := LManualTabs;
        LStage := 'CreateSecondSheet';
        LSheet := TTabSheet.Create(LManualTabs);
        LStage := 'AttachSecondSheet';
        LSheet.PageControl := LManualTabs;
        LStage := 'SetActiveIndex';
        LManualTabs.ActiveIndex := 0;
        LStage := 'Loaded';
        TComponentAccess(LManualTabs).SimulateDesignerLoaded;
        LStage := 'ValidateNoHandles';
        RequireNoAllocatedHandles(LManualTabs);
      except
        on E: Exception do
          Result := LStage + '=' + E.ClassName + ':' + E.Message;
      end;
    finally
      LManualTabs.Free;
    end;
  end;

begin
  LBinary := nil;
  LComponent := nil;
  LError := '';
  LStage := 'ObjectTextToBinary';
  LText := nil;
  LWindowBefore := ThreadWindowCount;
  try
    try
      LText := TStringStream.Create(
        'object LifecycleTabs: TDACTabs' + sLineBreak +
        '  TabHeight = 44' + sLineBreak +
        '  TabWidth = 132' + sLineBreak +
        '  Appearance = mtaSegmented' + sLineBreak +
        '  Size = mtsLarge' + sLineBreak +
        '  ActiveIndex = 0' + sLineBreak +
        '  object TabOne: TTabSheet' + sLineBreak +
        '    Caption = ''One''' + sLineBreak +
        '  end' + sLineBreak +
        '  object TabTwo: TTabSheet' + sLineBreak +
        '    Caption = ''Two''' + sLineBreak +
        '  end' + sLineBreak +
        'end' + sLineBreak);
      LBinary := TMemoryStream.Create;
      ObjectTextToBinary(LText, LBinary);
      LBinary.Position := 0;
      LStage := 'ReadComponent.Loaded';
      LComponent := LBinary.ReadComponent(nil);
      LStage := 'ValidateClass';
      if not (LComponent is TDACTabs) then
        raise Exception.Create('ReadComponent nao retornou TDACTabs.');
      LTabs := TDACTabs(LComponent);
      LStage := 'ValidateParent';
      if LTabs.Parent <> nil then
        raise Exception.Create('ChildTabsDFM atribuiu Parent.');
      LStage := 'ValidatePageCount';
      if LTabs.PageCount <> 2 then
        raise Exception.Create('ChildTabsDFM nao preservou dois TTabSheet.');
      LStage := 'ValidateActiveIndex';
      if LTabs.ActiveIndex <> 0 then
        raise Exception.Create('ChildTabsDFM nao preservou ActiveIndex=0.');
      LStage := 'ValidatePreHandleStyleBoundary';
      if LTabs.StyleElements <> [] then
        raise Exception.Create(
          'TDACTabs nao fixou StyleElements no construtor pre-HWND.');
      if not TTabSheetAccess(LTabs.Pages[0]).ParentBackground or
        not TTabSheetAccess(LTabs.Pages[1]).ParentBackground or
        (TTabSheetAccess(LTabs.Pages[0]).StyleElements = []) or
        (TTabSheetAccess(LTabs.Pages[1]).StyleElements = []) then
        raise Exception.Create(
          'TTabSheet alterou StyleElements/ParentBackground ainda com Parent=nil.');
      LStage := 'ValidateAppearanceAndSize';
      if (Ord(mtaUnderline) <> 0) or (Ord(mtaPills) <> 1) or
        (Ord(mtaFilled) <> 2) or (Ord(mtaSegmented) <> 3) then
        raise Exception.Create('Ordinais de TDACTabAppearance foram alterados.');
      if (LTabs.Appearance <> mtaSegmented) or (LTabs.Size <> mtsLarge) then
        raise Exception.Create(
          'ChildTabsDFM nao preservou Appearance/Size nao default.');
      LStage := 'ValidateParentNilThemeBoundary';
      LTabs.ThemeMode := dtmDark;
      if TTabSheetAccess(LTabs.Pages[0]).Color <>
        TDACComponentColors.ToVclColor(
          TDACComponentStyle.Resolve(dtmDark).Tokens.Controls.
            ContainerSuiteBackground) then
        raise Exception.Create('Tabs Parent=nil nao aplicou pagina dark.');
      LTabs.ThemeMode := dtmLight;
      if TTabSheetAccess(LTabs.Pages[1]).Color <>
        TDACComponentColors.ToVclColor(
          TDACComponentStyle.Resolve(dtmLight).Tokens.Controls.
            ContainerSuiteBackground) then
        raise Exception.Create('Tabs Parent=nil nao aplicou pagina light.');
      LTabs.ThemeMode := dtmInherit;
      if not TTabSheetAccess(LTabs.Pages[0]).ParentBackground or
        not TTabSheetAccess(LTabs.Pages[1]).ParentBackground or
        (TTabSheetAccess(LTabs.Pages[0]).StyleElements = []) or
        (TTabSheetAccess(LTabs.Pages[1]).StyleElements = []) then
        raise Exception.Create(
          'Theme toggle pre-handle alterou StyleElements/ParentBackground das paginas.');
      LStage := 'ValidateNoHandles';
      RequireNoAllocatedHandles(LTabs);
    except
      on E: Exception do
        LError := LStage + ' ' + E.ClassName + ': ' + E.Message;
    end;
  finally
    LComponent.Free;
    LBinary.Free;
    LText.Free;
  end;
  LWindowAfter := ThreadWindowCount;
  if LWindowAfter <> LWindowBefore then
  begin
    if LError <> '' then
      LError := LError + ' | ';
    LError := LError + 'WindowDelta=' +
      IntToStr(LWindowAfter - LWindowBefore);
  end;
  if LError <> '' then
    LError := LError + ' | ManualProbe=' + DiagnoseManualChildren;
  if LError = '' then
    Writeln(IntToStr(ARound) + #9 + 'TDACTabs' + #9 + 'Tabs.Host' + #9 +
      'yes' + #9 + 'ChildTabsDFM.ParentNil.Loaded' + #9 + 'PASS' + #9 +
      'Parent=nil;HandleAllocated=False;WindowDelta=0;TopLevelVisible=False')
  else
  begin
    Inc(GFailures);
    Writeln(IntToStr(ARound) + #9 + 'TDACTabs' + #9 + 'Tabs.Host' + #9 +
      'yes' + #9 + 'ChildTabsDFM.ParentNil.Loaded' + #9 + 'FAIL' + #9 +
      CleanText(LError));
  end;
end;

function BoolText(const AValue: Boolean): string;
begin
  if AValue then
    Result := 'yes'
  else
    Result := 'no';
end;

function CleanText(const AValue: string): string;
begin
  Result := StringReplace(AValue, #9, ' ', [rfReplaceAll]);
  Result := StringReplace(Result, #13, ' ', [rfReplaceAll]);
  Result := StringReplace(Result, #10, ' ', [rfReplaceAll]);
end;

procedure RequireNoAllocatedHandles(const AComponent: TComponent);
var
  I: Integer;
begin
  if (AComponent is TWinControl) and
    TWinControl(AComponent).HandleAllocated then
    raise Exception.Create(AComponent.ClassName +
      ' criou Handle sem Parent.');
  for I := 0 to AComponent.ComponentCount - 1 do
    RequireNoAllocatedHandles(AComponent.Components[I]);
end;

procedure RequireNoAllocatedChildHandles(const ARoot: TComponent);
var
  I: Integer;
  LChild: TComponent;
begin
  for I := 0 to ARoot.ComponentCount - 1 do
  begin
    LChild := ARoot.Components[I];
    if (LChild is TWinControl) and TWinControl(LChild).HandleAllocated and
      not ((LChild is TDACTabs) and SameText(LChild.Name, 'GalleryTabs')) and
      not ((LChild is TTabSheet) and SameText(LChild.Name, 'tsDataAware')) then
      raise Exception.Create(LChild.ClassName + '(' + LChild.Name +
        ') manteve Handle auxiliar apos Loaded.');
    RequireNoAllocatedChildHandles(LChild);
  end;
end;

procedure ApplyThemeModes(const AComponent: TComponent);
var
  LProp: PPropInfo;
begin
  LProp := GetPropInfo(AComponent.ClassInfo, 'ThemeMode');
  if (LProp = nil) or (LProp^.SetProc = nil) then
    Exit;
  TDACThemeManager.SetApplicationMode(dtmLight);
  SetOrdProp(AComponent, LProp, Ord(dtmInherit));
  TDACThemeManager.SetApplicationMode(dtmDark);
  SetOrdProp(AComponent, LProp, Ord(dtmInherit));
  SetOrdProp(AComponent, LProp, Ord(dtmDark));
  SetOrdProp(AComponent, LProp, Ord(dtmLight));
  SetOrdProp(AComponent, LProp, Ord(dtmInherit));
end;

procedure TouchRelevantProperties(const AComponent: TComponent);
const
  StringNames: array[0..17] of string = (
    'Placeholder', 'ErrorText', 'Title', 'Subtitle', 'TitleText',
    'MessageText', 'FooterText', 'FooterValue', 'StatusFieldName',
    'ReportTitle', 'PeriodText', 'EmptyText', 'LoadingText', 'ValueText',
    'DeltaText', 'ButtonCaption', 'Hint', 'DataField');
  BooleanNames: array[0..12] of string = (
    'Loading', 'ShowFooter', 'ShowValue', 'Active', 'ShowLegend',
    'ShowAxes', 'ShowContentBorder', 'Checked', 'Selected', 'Clickable',
    'ReadOnly', 'ShowIcon', 'ClearButtonVisible');
  IntegerNames: array[0..17] of string = (
    'Minimum', 'Maximum', 'Value', 'Position', 'PageCount', 'PageIndex',
    'PageSize', 'Zoom', 'CornerRadius', 'BorderWidth', 'HeaderHeight',
    'ButtonWidth', 'RowHeight', 'ColumnCount', 'RowGap', 'ColumnGap',
    'TimeStepMinutes', 'Interval');
  IntegerValues: array[0..17] of Integer = (
    0, 100, 37, 37, 5, 2, 25, 110, 9, 1, 42, 44, 48, 2, 8, 8, 15, 125);
var
  I: Integer;
  LControl: TControl;
  LObject: TObject;
  LProp: PPropInfo;

  procedure SetStringProperty(const AName, AValue: string);
  begin
    LProp := GetPropInfo(AComponent.ClassInfo, AName);
    if (LProp = nil) or (LProp^.SetProc = nil) or
      not (LProp^.PropType^.Kind in
        [tkString, tkLString, tkWString, tkUString]) then
      Exit;
    try
      SetStrProp(AComponent, LProp, AValue);
    except
      on E: Exception do
        raise Exception.Create(AName + ' ' + E.ClassName + ': ' + E.Message);
    end;
  end;

  procedure SetOrdinalProperty(const AName: string; const AValue: Integer);
  begin
    LProp := GetPropInfo(AComponent.ClassInfo, AName);
    if (LProp = nil) or (LProp^.SetProc = nil) or
      not (LProp^.PropType^.Kind in [tkInteger, tkEnumeration]) then
      Exit;
    try
      SetOrdProp(AComponent, LProp, AValue);
    except
      on E: Exception do
        raise Exception.Create(AName + ' ' + E.ClassName + ': ' + E.Message);
    end;
  end;

begin
  if AComponent is TControl then
  begin
    LControl := TControl(AComponent);
    LControl.SetBounds(7, 11, 173, 47);
    LControl.Enabled := False;
    LControl.Enabled := True;
    if not (AComponent is TCustomForm) then
    begin
      LControl.Visible := False;
      LControl.Visible := True;
    end;
  end;
  SetStringProperty('Caption', 'Lifecycle');
  SetStringProperty('Text', 'Lifecycle');
  for I := Low(StringNames) to High(StringNames) do
    SetStringProperty(StringNames[I], 'Lifecycle ' + StringNames[I]);
  for I := Low(BooleanNames) to High(BooleanNames) do
    SetOrdinalProperty(BooleanNames[I], 1);
  for I := Low(IntegerNames) to High(IntegerNames) do
    SetOrdinalProperty(IntegerNames[I], IntegerValues[I]);
  if not (AComponent is TDACDBLookupComboBox) then
  begin
  LProp := GetPropInfo(AComponent.ClassInfo, 'Font');
  if LProp <> nil then
  begin
    LObject := GetObjectProp(AComponent, LProp);
    if LObject is TFont then
    begin
      try
        TFont(LObject).Name := 'Inter';
        TFont(LObject).Size := 11;
        TFont(LObject).Style := [fsBold];
        TFont(LObject).Style := [];
      except
        on E: Exception do
          raise Exception.Create('Font ' + E.ClassName + ': ' + E.Message);
      end;
    end;
  end;
  end;
  LProp := GetPropInfo(AComponent.ClassInfo, 'Items');
  if LProp <> nil then
  begin
    LObject := GetObjectProp(AComponent, LProp);
    if LObject is TStrings then
    begin
      try
        TStrings(LObject).Clear;
        TStrings(LObject).Add('Lifecycle item');
      except
        on E: Exception do
          raise Exception.Create('Items ' + E.ClassName + ': ' + E.Message);
      end;
    end;
  end;
  LProp := GetPropInfo(AComponent.ClassInfo, 'Lines');
  if LProp <> nil then
  begin
    LObject := GetObjectProp(AComponent, LProp);
    if LObject is TStrings then
    begin
      try
        TStrings(LObject).Clear;
        TStrings(LObject).Add('Lifecycle line');
      except
        on E: Exception do
          raise Exception.Create('Lines ' + E.ClassName + ': ' + E.Message);
      end;
    end;
  end;
  try
    ApplyThemeModes(AComponent);
  except
    on E: Exception do
      raise Exception.Create('ThemeMode ' + E.ClassName + ': ' + E.Message);
  end;
end;

procedure WriteRow(const ARound: Integer; const ASpec: TClassSpec;
  const AResult, AMessage: string);
begin
  Writeln(IntToStr(ARound) + #9 + ASpec.ComponentClass.ClassName + #9 +
    ASpec.Family + #9 + BoolText(ASpec.Registered) + #9 +
    'ParentNil.SetDesigning.Loaded.Theme.Destroy' + #9 + AResult + #9 +
    CleanText(AMessage));
end;

procedure RunSpec(const ARound: Integer; const ASpec: TClassSpec);
var
  LComponent: TComponent;
  LError: string;
  LGdiAfter: DWORD;
  LGdiBefore: DWORD;
  LStage: string;
  LUserAfter: DWORD;
  LUserBefore: DWORD;
  LWindowAfter: Integer;
  LWindowBefore: Integer;
begin
  LComponent := nil;
  LError := '';
  LStage := 'Create';
  GAsyncException := '';
  LGdiBefore := GdiObjectCount;
  LUserBefore := UserObjectCount;
  LWindowBefore := ThreadWindowCount;
  try
    try
      LComponent := ASpec.ComponentClass.Create(nil);
      LStage := 'InitialState';
      if LComponent.Owner <> nil then
        raise Exception.Create('Owner inesperado.');
      if (LComponent is TControl) and
        (TControl(LComponent).Parent <> nil) then
        raise Exception.Create('Parent inesperado.');
      RequireNoAllocatedHandles(LComponent);
      LStage := 'Properties';
      TouchRelevantProperties(LComponent);
      LStage := 'AfterProperties';
      RequireNoAllocatedHandles(LComponent);
      LStage := 'Loaded';
      TComponentAccess(LComponent).SimulateDesignerLoaded;
      LStage := 'AfterLoaded';
      RequireNoAllocatedHandles(LComponent);
    except
      on E: Exception do
        LError := LStage + ' ' + E.ClassName + ': ' + E.Message;
    end;
  finally
    try
      LComponent.Free;
      Application.ProcessMessages;
    except
      on E: Exception do
      begin
        if LError <> '' then
          LError := LError + ' | ';
        LError := LError + 'Destroy ' + E.ClassName + ': ' + E.Message;
      end;
    end;
  end;
  LGdiAfter := GdiObjectCount;
  LUserAfter := UserObjectCount;
  LWindowAfter := ThreadWindowCount;
  if GAsyncException <> '' then
  begin
    if LError <> '' then
      LError := LError + ' | ';
    LError := LError + 'Async ' + GAsyncException;
  end;
  if LWindowAfter > LWindowBefore then
  begin
    if LError <> '' then
      LError := LError + ' | ';
    LError := LError + 'WindowDelta=' +
      IntToStr(LWindowAfter - LWindowBefore);
  end;
  if (ARound > 1) and ((LUserAfter > LUserBefore) or
    (LGdiAfter > LGdiBefore)) then
  begin
    if LError <> '' then
      LError := LError + ' | ';
    LError := LError + 'USER/GDI delta=' +
      IntToStr(Integer(LUserAfter) - Integer(LUserBefore)) + '/' +
      IntToStr(Integer(LGdiAfter) - Integer(LGdiBefore));
  end;
  if LError = '' then
    WriteRow(ARound, ASpec, 'PASS', 'USER/GDI=' +
      IntToStr(Integer(LUserAfter) - Integer(LUserBefore)) + '/' +
      IntToStr(Integer(LGdiAfter) - Integer(LGdiBefore)))
  else
  begin
    Inc(GFailures);
    WriteRow(ARound, ASpec, 'FAIL', LError);
  end;
end;

procedure WriteServiceRows(const ARound: Integer);
const
  Services: array[0..16] of string = (
    'TDACComponentAssetResolver', 'TDACComponentColors',
    'TDACComponentFontInstaller', 'TDACComponentStyle',
    'TDACDataGridColumnResolver', 'TDACDataGridDataLink',
    'TDACDefaultComponentsTheme', 'TDACIconAssets', 'TDACSemanticColors',
    'TDACSkiaBackgroundPainter', 'TDACSkiaBorderPainter',
    'TDACSkiaControlStyleHook', 'TDACSkiaElementContainer',
    'TDACSkiaIconPainter', 'TDACSkiaRenderer', 'TDACSkiaVisualElement',
    'TDACThemeManager');
var
  I: Integer;
begin
  for I := Low(Services) to High(Services) do
    Writeln(IntToStr(ARound) + #9 + Services[I] + #9 +
      'Service' + #9 + 'no' + #9 + 'ParentNil' + #9 + 'N/A' + #9 +
      'Classe nao visual; tera cenario de servico dedicado.');
end;

procedure RunServiceLifecycle(const ARound: Integer);
var
  LAssetResolver: TDACComponentAssetResolver;
  LBackgroundPainter: TDACSkiaBackgroundPainter;
  LBorderPainter: TDACSkiaBorderPainter;
  LContainer: TDACSkiaElementContainer;
  LDataLink: TDACDataGridDataLink;
  LElement: TDACSkiaVisualElement;
  LError: string;
  LGdiAfter: DWORD;
  LGdiBefore: DWORD;
  LIconPainter: TDACSkiaIconPainter;
  LRenderer: TDACSkiaRenderer;
  LTheme: IDACComponentsTheme;
  LUserAfter: DWORD;
  LUserBefore: DWORD;
  LWindowBefore: Integer;
begin
  LAssetResolver := nil;
  LBackgroundPainter := nil;
  LBorderPainter := nil;
  LContainer := nil;
  LDataLink := nil;
  LElement := nil;
  LError := '';
  LIconPainter := nil;
  LRenderer := nil;
  LTheme := nil;
  LUserBefore := UserObjectCount;
  LGdiBefore := GdiObjectCount;
  LWindowBefore := ThreadWindowCount;
  try
    try
      LAssetResolver := TDACComponentAssetResolver.Create('');
      if LAssetResolver.ResolveFileName('missing-lifecycle.svg') <> '' then
        raise Exception.Create('AssetResolver encontrou asset inexistente.');
      LTheme := TDACDefaultComponentsTheme.NewForMode(dtmLight);
      if LTheme = nil then
        raise Exception.Create('DefaultTheme retornou nil.');
      LRenderer := TDACSkiaRenderer.Create;
      LBackgroundPainter := TDACSkiaBackgroundPainter.Create(LRenderer);
      LBorderPainter := TDACSkiaBorderPainter.Create(LRenderer);
      LIconPainter := TDACSkiaIconPainter.Create(LRenderer);
      LElement := TDACSkiaVisualElement.Create('lifecycle-element');
      LContainer := TDACSkiaElementContainer.Create;
      LContainer.Add(LElement);
      LContainer.ApplyTheme(LTheme);
      LDataLink := TDACDataGridDataLink.Create(nil);
      if TDACComponentColors.ContrastRatio(
        TDACComponentStyle.Resolve(dtmLight).Tokens.Colors.Text,
        TDACComponentStyle.Resolve(dtmLight).Tokens.Colors.Background) <= 0 then
        raise Exception.Create('Servicos de cor/tema retornaram contraste invalido.');
    except
      on E: Exception do
        LError := E.ClassName + ': ' + E.Message;
    end;
  finally
    LDataLink.Free;
    LContainer.Free;
    LElement.Free;
    LIconPainter.Free;
    LBorderPainter.Free;
    LBackgroundPainter.Free;
    LRenderer.Free;
    LTheme := nil;
    LAssetResolver.Free;
    Application.ProcessMessages;
  end;
  LUserAfter := UserObjectCount;
  LGdiAfter := GdiObjectCount;
  if ThreadWindowCount > LWindowBefore then
  begin
    if LError <> '' then
      LError := LError + ' | ';
    LError := LError + 'Servico criou HWND inesperado.';
  end;
  if (ARound > 1) and ((LUserAfter > LUserBefore) or
    (LGdiAfter > LGdiBefore)) then
  begin
    if LError <> '' then
      LError := LError + ' | ';
    LError := LError + 'USER/GDI delta=' +
      IntToStr(Integer(LUserAfter) - Integer(LUserBefore)) + '/' +
      IntToStr(Integer(LGdiAfter) - Integer(LGdiBefore));
  end;
  if LError = '' then
    Writeln(IntToStr(ARound) + #9 + 'TDAC service set' + #9 +
      'Service' + #9 + 'no' + #9 + 'ServiceLifecycle' + #9 +
      'PASS' + #9 + 'Parent=N/A; USER/GDI=' +
      IntToStr(Integer(LUserAfter) - Integer(LUserBefore)) + '/' +
      IntToStr(Integer(LGdiAfter) - Integer(LGdiBefore)))
  else
  begin
    Inc(GFailures);
    Writeln(IntToStr(ARound) + #9 + 'TDAC service set' + #9 +
      'Service' + #9 + 'no' + #9 + 'ServiceLifecycle' + #9 +
      'FAIL' + #9 + CleanText(LError));
  end;
end;

procedure WriteHostResult(const ARound: Integer; const AClassName,
  AFamily, AResult, AMessage: string);
begin
  if AResult = 'FAIL' then
    Inc(GFailures);
  Writeln(IntToStr(ARound) + #9 + AClassName + #9 + AFamily + #9 +
    'no' + #9 + 'InternalHost.RealConstructor' + #9 + AResult + #9 +
    CleanText(AMessage));
end;

procedure RunInternalHosts(const ARound: Integer);
var
  LDataLink: TDACDataGridDataLink;
  LError: string;
  LGrid: TDACDataGrid;
  LHeader: TDACTabHeaderControl;
  LPaintBox: TDACDataGridPaintBox;
  LPopup: TDACDateTimePickerPopup;
  LTabs: TDACTabs;
begin
  LDataLink := nil;
  LError := '';
  LGrid := nil;
  try
    try
      LGrid := TDACDataGrid.Create(nil);
      LPaintBox := TDACDataGridPaintBox.Create(LGrid);
      if LPaintBox.Owner <> LGrid then
        raise Exception.Create('PaintBox nao preservou owner grid.');
      RequireNoAllocatedHandles(LGrid);
      LDataLink := TDACDataGridDataLink.Create(LGrid);
    except
      on E: Exception do
        LError := E.ClassName + ': ' + E.Message;
    end;
  finally
    LDataLink.Free;
    LGrid.Free;
  end;
  if LError = '' then
    WriteHostResult(ARound, 'TDACDataGridPaintBox/TDACDataGridDataLink',
      'Grid.Host', 'PASS', '')
  else
    WriteHostResult(ARound, 'TDACDataGridPaintBox/TDACDataGridDataLink',
      'Grid.Host', 'FAIL', LError);

  LError := '';
  LTabs := nil;
  try
    try
      LTabs := TDACTabs.Create(nil);
      LHeader := TDACTabHeaderControl.CreateForTabs(LTabs);
      if LHeader.Owner <> LTabs then
        raise Exception.Create('Header nao preservou owner Tabs.');
      if LHeader.Parent <> nil then
        raise Exception.Create('Header recebeu Parent prematuro.');
      RequireNoAllocatedHandles(LTabs);
    except
      on E: Exception do
        LError := E.ClassName + ': ' + E.Message;
    end;
  finally
    LTabs.Free;
  end;
  if LError = '' then
    WriteHostResult(ARound, 'TDACTabHeaderControl', 'Tabs.Host',
      'PASS', '')
  else
    WriteHostResult(ARound, 'TDACTabHeaderControl', 'Tabs.Host',
      'FAIL', LError);

  LError := '';
  LPopup := nil;
  try
    try
      LPopup := TDACDateTimePickerPopup.Create(nil);
      LPopup.ApplyThemeMode(dtmLight);
      LPopup.ApplyThemeMode(dtmDark);
      LPopup.ApplyThemeMode(dtmInherit);
      if LPopup.Visible then
        raise Exception.Create('Popup ficou visivel sem Show.');
      if LPopup.HandleAllocated and IsWindowVisible(LPopup.Handle) then
        raise Exception.Create('Popup criou top-level visivel sem Show.');
    except
      on E: Exception do
        LError := E.ClassName + ': ' + E.Message;
    end;
  finally
    LPopup.Free;
  end;
  if LError = '' then
    WriteHostResult(ARound, 'TDACDateTimePickerPopup', 'Selectors.Host',
      'PASS', '')
  else
    WriteHostResult(ARound, 'TDACDateTimePickerPopup', 'Selectors.Host',
      'FAIL', LError);
end;

procedure RunAll;
var
  I: Integer;
  LGdiAfter: DWORD;
  LGdiBefore: DWORD;
  LMessage: string;
  LRound: Integer;
  LUserAfter: DWORD;
  LUserBefore: DWORD;
  LWindowAfter: Integer;
  LWindowBefore: Integer;
begin
  Writeln('Round' + #9 + 'Class' + #9 + 'Family' + #9 + 'DesignRegistered' +
    #9 + 'Scenario' + #9 + 'Result' + #9 + 'Message');
  for LRound := 1 to 3 do
  begin
    LGdiBefore := GdiObjectCount;
    LUserBefore := UserObjectCount;
    LWindowBefore := ThreadWindowCount;
    for I := 0 to Length(GSpecs) - 1 do
    begin
      RunSpec(LRound, GSpecs[I]);
      RunStandaloneDfm(LRound, GSpecs[I]);
      RunDataAware(LRound, GSpecs[I]);
{$IFDEF DAC_STAGE5_ONLY}
      RunStage5WindowLifecycle(LRound, GSpecs[I]);
{$ENDIF}
    end;
{$IFNDEF DAC_STAGE3_ONLY}
{$IFNDEF DAC_STAGE4_ONLY}
{$IFNDEF DAC_STAGE5_ONLY}
    RunNativePageControlEvidence(LRound);
    RunDemoWithoutBuildersEvidence(LRound);
    RunTabsChildrenDfm(LRound);
    RunFullDemoDfm(LRound);
    RunInternalHosts(LRound);
    RunServiceLifecycle(LRound);
    WriteServiceRows(LRound);
{$ENDIF}
{$ENDIF}
{$ENDIF}
    Application.ProcessMessages;
    LGdiAfter := GdiObjectCount;
    LUserAfter := UserObjectCount;
    LWindowAfter := ThreadWindowCount;
    LMessage := 'USER/GDI/HWND=' +
      IntToStr(Integer(LUserAfter) - Integer(LUserBefore)) + '/' +
      IntToStr(Integer(LGdiAfter) - Integer(LGdiBefore)) + '/' +
      IntToStr(LWindowAfter - LWindowBefore);
    if (LRound > 1) and ((LUserAfter > LUserBefore) or
      (LGdiAfter > LGdiBefore) or (LWindowAfter > LWindowBefore)) then
    begin
      Inc(GFailures);
      Writeln(IntToStr(LRound) + #9 + 'LifecycleRoundTotals' + #9 +
        'All15Families' + #9 + 'N/A' + #9 +
        'Round.ResourceBaseline' + #9 + 'FAIL' + #9 + LMessage);
    end
    else
      Writeln(IntToStr(LRound) + #9 + 'LifecycleRoundTotals' + #9 +
        'All15Families' + #9 + 'N/A' + #9 +
        'Round.ResourceBaseline' + #9 + 'PASS' + #9 + LMessage);
  end;
end;

begin
  GFailures := 0;
  Application.Initialize;
  Application.MainFormOnTaskbar := False;
  GExceptionProbe := TExceptionProbe.Create;
  Application.OnException := GExceptionProbe.OnApplicationException;
  try
    BuildInventory;
{$IFDEF DAC_STAGE5_ONLY}
    if Length(GSpecs) <> 3 then
    begin
      Writeln('Inventory' + #9 + 'FAIL' + #9 +
        'Esperadas 3 classes visuais da Etapa 5; encontradas ' +
        IntToStr(Length(GSpecs)) + '.');
      ExitCode := 2;
    end
{$ELSE}
{$IFDEF DAC_STAGE4_ONLY}
    if Length(GSpecs) <> 5 then
    begin
      Writeln('Inventory' + #9 + 'FAIL' + #9 +
        'Esperadas 5 classes visuais da Etapa 4; encontradas ' +
        IntToStr(Length(GSpecs)) + '.');
      ExitCode := 2;
    end
{$ELSE}
{$IFDEF DAC_STAGE3_ONLY}
    if Length(GSpecs) <> 5 then
    begin
      Writeln('Inventory' + #9 + 'FAIL' + #9 +
        'Esperadas 5 classes visuais da Etapa 3; encontradas ' +
        IntToStr(Length(GSpecs)) + '.');
      ExitCode := 2;
    end
{$ELSE}
    if Length(GSpecs) <> 46 then
    begin
      Writeln('Inventory' + #9 + 'FAIL' + #9 +
        'Esperadas 46 classes visuais/hosts; encontradas ' +
        IntToStr(Length(GSpecs)) + '.');
      ExitCode := 2;
    end
{$ENDIF}
{$ENDIF}
{$ENDIF}
    else
    begin
      RegisterLifecycleClasses;
      RunAll;
      if GFailures = 0 then
        Writeln('DACComponentsDesignLifecycle: PASS')
      else
        Writeln('DACComponentsDesignLifecycle: FAIL count=' +
          IntToStr(GFailures));
      ExitCode := Ord(GFailures <> 0);
    end;
  finally
    Application.OnException := nil;
    GExceptionProbe.Free;
  end;
end.
