unit DAC.Components.Controls.DBTreeView.Types;

interface

uses
  System.Classes, System.SysUtils, System.Variants, Data.DB;

type
  TDACDBTreeChangeReason = (tcrUser, tcrProgrammatic, tcrDataSet, tcrRemoved, tcrReset);
  TDACDBTreeKeyKind = (tkkText, tkkInteger, tkkGuid);
  TDACDBTreeCurrentEvent = procedure(Sender: TObject;
    const OldKey, NewKey: Variant; Reason: TDACDBTreeChangeReason) of object;
  TDACDBTreeBeforeCheckEvent = procedure(Sender: TObject;
    const Key: Variant; const Checked: Boolean; var Allow: Boolean) of object;
  TDACDBTreeCheckEvent = procedure(Sender: TObject;
    const Key: Variant; Checked: Boolean; Reason: TDACDBTreeChangeReason) of object;
  TDACDBTreeActivateEvent = procedure(Sender: TObject; const Key: Variant) of object;
  TDACDBTreeErrorEvent = procedure(Sender: TObject;
    const Key: Variant; const MessageText: string) of object;

  EDACDBTreeDataError = class(Exception)
  private
    FKey: Variant;
  public
    constructor CreateKey(const AMessage: string; const AKey: Variant);
    property Key: Variant read FKey;
  end;

function DBTreeFieldKeyKind(const AField: TField): TDACDBTreeKeyKind;
function DBTreeKeyToken(const AValue: Variant;
  const AKind: TDACDBTreeKeyKind): string;

implementation

constructor EDACDBTreeDataError.CreateKey(const AMessage: string; const AKey: Variant);
begin
  inherited Create(AMessage);
  FKey := AKey;
end;

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
var
  LType: TVarType;
  LGuid: TGUID;
  LInteger: Int64;
begin
  if VarIsNull(AValue) or VarIsEmpty(AValue) then
    raise EDACDBTreeDataError.CreateKey('A record key cannot be null.', AValue);
  LType := VarType(AValue);
  case AKind of
    tkkText:
      begin
        if not VarIsStr(AValue) then
          raise EDACDBTreeDataError.CreateKey('A textual key requires a string value.', AValue);
        Result := 'S:' + string(AValue);
      end;
    tkkInteger:
      begin
        if not (LType in [varSmallint, varInteger, varShortInt, varByte,
          varWord, varLongWord, varInt64, varUInt64]) then
          raise EDACDBTreeDataError.CreateKey('An integer key requires an integer value.', AValue);
        { Delphi 10.2 wraps a UInt64 variant into Int64 without raising. Do not
          allow a large unsigned value to alias a negative record key. }
        if (LType = varUInt64) and (TVarData(AValue).VUInt64 > UInt64(High(Int64))) then
          raise EDACDBTreeDataError.CreateKey('Integer key is outside the Int64 range.', AValue);
        try
          LInteger := AValue;
          Result := 'I:' + IntToStr(LInteger);
        except
          on E: Exception do
            raise EDACDBTreeDataError.CreateKey('Integer key is outside the Int64 range.', AValue);
        end;
      end;
    tkkGuid:
      begin
        if not VarIsStr(AValue) then
          raise EDACDBTreeDataError.CreateKey('A GUID key requires a GUID string.', AValue);
        try
          LGuid := StringToGUID(string(AValue));
        except
          on E: EConvertError do
            raise EDACDBTreeDataError.CreateKey('Invalid GUID key.', AValue);
        end;
        Result := 'G:' + GUIDToString(LGuid);
      end;
  else
    Result := '';
  end;
end;

end.
