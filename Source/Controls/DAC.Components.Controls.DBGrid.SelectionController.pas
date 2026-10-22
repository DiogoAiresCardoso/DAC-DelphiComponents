unit DAC.Components.Controls.DBGrid.SelectionController;

interface

uses
  Data.DB,
  DAC.Components.Controls.DBGrid.SelectionOptions,
  DAC.Components.Controls.DBGrid.Types;

type
  TDACDBGridSelectionController = class
  private
    function ResolveField(ADataSet: TDataSet;
      AOptions: TDACDBGridSelectionOptions): TBooleanField;
    procedure SetCurrentValue(ADataSet: TDataSet; AField: TBooleanField;
      const AValue: Boolean);
  public
    function CalculateState(ADataSet: TDataSet;
      AOptions: TDACDBGridSelectionOptions): TDACDBGridSelectionState;
    function ToggleCurrent(ADataSet: TDataSet;
      AOptions: TDACDBGridSelectionOptions; out AField: TField;
      out AChecked: Boolean): Boolean;
    procedure SetAll(ADataSet: TDataSet;
      AOptions: TDACDBGridSelectionOptions; const AChecked: Boolean);
    procedure Validate(ADataSet: TDataSet;
      AOptions: TDACDBGridSelectionOptions);
  end;

implementation

uses
  System.SysUtils;

function TDACDBGridSelectionController.CalculateState(ADataSet: TDataSet;
  AOptions: TDACDBGridSelectionOptions): TDACDBGridSelectionState;
var
  LBookmark: TBookmark;
  LField: TBooleanField;
  LFoundFalse: Boolean;
  LFoundTrue: Boolean;
begin
  Result := dgssUnchecked;
  if (ADataSet = nil) or not ADataSet.Active or ADataSet.IsEmpty or
    (AOptions = nil) or not AOptions.Enabled then
    Exit;
  if ADataSet.State in dsEditModes then
    Exit(dgssMixed);
  LField := ResolveField(ADataSet, AOptions);
  LFoundFalse := False;
  LFoundTrue := False;
  LBookmark := ADataSet.GetBookmark;
  ADataSet.DisableControls;
  try
    ADataSet.First;
    while not ADataSet.Eof do
    begin
      if LField.AsBoolean then
        LFoundTrue := True
      else
        LFoundFalse := True;
      if LFoundTrue and LFoundFalse then
        Exit(dgssMixed);
      ADataSet.Next;
    end;
    if LFoundTrue then
      Result := dgssChecked;
  finally
    if (Length(LBookmark) > 0) and ADataSet.BookmarkValid(LBookmark) then
      ADataSet.GotoBookmark(LBookmark);
    ADataSet.FreeBookmark(LBookmark);
    ADataSet.EnableControls;
  end;
end;

function TDACDBGridSelectionController.ResolveField(ADataSet: TDataSet;
  AOptions: TDACDBGridSelectionOptions): TBooleanField;
var
  LField: TField;
begin
  if (AOptions = nil) or not AOptions.Enabled then
    raise EDatabaseError.Create('A coluna de seleção não está habilitada.');
  if Trim(AOptions.FieldName) = '' then
    raise EDatabaseError.Create('Selection.FieldName deve ser informado.');
  if (ADataSet = nil) or not ADataSet.Active then
    raise EDatabaseError.Create('A coluna de seleção requer um dataset ativo.');
  LField := ADataSet.FindField(AOptions.FieldName);
  if LField = nil then
    raise EDatabaseError.CreateFmt('O campo de seleção "%s" não existe no dataset.',
      [AOptions.FieldName]);
  if not (LField is TBooleanField) then
    raise EDatabaseError.CreateFmt('O campo de seleção "%s" deve ser Boolean.',
      [AOptions.FieldName]);
  Result := TBooleanField(LField);
end;

procedure TDACDBGridSelectionController.SetAll(ADataSet: TDataSet;
  AOptions: TDACDBGridSelectionOptions; const AChecked: Boolean);
var
  LBookmark: TBookmark;
  LField: TBooleanField;
begin
  LField := ResolveField(ADataSet, AOptions);
  if LField.ReadOnly or not ADataSet.CanModify then
    raise EDatabaseError.CreateFmt('O campo de seleção "%s" não pode ser alterado.',
      [AOptions.FieldName]);
  if ADataSet.IsEmpty then
    Exit;
  if ADataSet.State in dsEditModes then
    raise EDatabaseError.Create(
      'Finalize a edição atual antes de selecionar todos os registros.');
  LBookmark := ADataSet.GetBookmark;
  ADataSet.DisableControls;
  try
    ADataSet.First;
    while not ADataSet.Eof do
    begin
      if LField.AsBoolean <> AChecked then
        SetCurrentValue(ADataSet, LField, AChecked);
      ADataSet.Next;
    end;
  finally
    if (Length(LBookmark) > 0) and ADataSet.BookmarkValid(LBookmark) then
      ADataSet.GotoBookmark(LBookmark);
    ADataSet.FreeBookmark(LBookmark);
    ADataSet.EnableControls;
  end;
end;

procedure TDACDBGridSelectionController.SetCurrentValue(ADataSet: TDataSet;
  AField: TBooleanField; const AValue: Boolean);
var
  LStartedEdit: Boolean;
begin
  if AField.ReadOnly or not ADataSet.CanModify then
    raise EDatabaseError.CreateFmt('O campo de seleção "%s" não pode ser alterado.',
      [AField.FieldName]);
  LStartedEdit := not (ADataSet.State in dsEditModes);
  if LStartedEdit then
    ADataSet.Edit;
  AField.AsBoolean := AValue;
  if LStartedEdit then
    ADataSet.Post;
end;

function TDACDBGridSelectionController.ToggleCurrent(ADataSet: TDataSet;
  AOptions: TDACDBGridSelectionOptions; out AField: TField;
  out AChecked: Boolean): Boolean;
var
  LBooleanField: TBooleanField;
begin
  AField := nil;
  AChecked := False;
  LBooleanField := ResolveField(ADataSet, AOptions);
  if ADataSet.IsEmpty then
    Exit(False);
  AChecked := not LBooleanField.AsBoolean;
  SetCurrentValue(ADataSet, LBooleanField, AChecked);
  AField := LBooleanField;
  Result := True;
end;

procedure TDACDBGridSelectionController.Validate(ADataSet: TDataSet;
  AOptions: TDACDBGridSelectionOptions);
begin
  ResolveField(ADataSet, AOptions);
end;

end.
