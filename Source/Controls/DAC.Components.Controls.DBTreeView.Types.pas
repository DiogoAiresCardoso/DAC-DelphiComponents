unit DAC.Components.Controls.DBTreeView.Types;

interface

uses
  System.Classes, System.SysUtils, System.Variants, Data.DB,
  DAC.Components.Controls.TreeView.Types;

type
  TDACDBTreeChangeReason = TDACTreeChangeReason;
  TDACDBTreeKeyKind = TDACTreeKeyKind;
  TDACDBTreeCurrentEvent = procedure(Sender: TObject;
    const OldKey, NewKey: Variant; Reason: TDACDBTreeChangeReason) of object;
  TDACDBTreeBeforeCheckEvent = procedure(Sender: TObject;
    const Key: Variant; const Checked: Boolean; var Allow: Boolean) of object;
  TDACDBTreeCheckEvent = procedure(Sender: TObject;
    const Key: Variant; Checked: Boolean; Reason: TDACDBTreeChangeReason) of object;
  TDACDBTreeActivateEvent = procedure(Sender: TObject; const Key: Variant) of object;
  TDACDBTreeErrorEvent = procedure(Sender: TObject;
    const Key: Variant; const MessageText: string) of object;

  EDACDBTreeDataError = EDACTreeDataError;

const
  tcrUser = DAC.Components.Controls.TreeView.Types.tcrUser;
  tcrProgrammatic = DAC.Components.Controls.TreeView.Types.tcrProgrammatic;
  tcrDataSet = DAC.Components.Controls.TreeView.Types.tcrDataSet;
  tcrRemoved = DAC.Components.Controls.TreeView.Types.tcrRemoved;
  tcrReset = DAC.Components.Controls.TreeView.Types.tcrReset;
  tkkText = DAC.Components.Controls.TreeView.Types.tkkText;
  tkkInteger = DAC.Components.Controls.TreeView.Types.tkkInteger;
  tkkGuid = DAC.Components.Controls.TreeView.Types.tkkGuid;

function DBTreeFieldKeyKind(const AField: TField): TDACDBTreeKeyKind;
function DBTreeKeyToken(const AValue: Variant;
  const AKind: TDACDBTreeKeyKind): string;

implementation

function DBTreeFieldKeyKind(const AField: TField): TDACDBTreeKeyKind;
begin
  if AField = nil then
    raise EDACDBTreeDataError.CreateKey('Key or parent field was not found.', Null);
  case AField.DataType of
    ftString, ftFixedChar, ftWideString, ftFixedWideChar: Result := tkkText;
    ftSmallint, ftInteger, ftWord, ftAutoInc, ftLargeint,
    ftLongWord, ftShortint, ftByte: Result := tkkInteger;
    ftGuid: Result := tkkGuid;
  else
    raise EDACDBTreeDataError.CreateKey(
      'Unsupported key field type: ' + AField.FieldName, Null);
  end;
end;

function DBTreeKeyToken(const AValue: Variant;
  const AKind: TDACDBTreeKeyKind): string;
begin
  Result := TreeKeyToken(AValue, AKind);
end;

end.
