unit DAC.Components.Controls.TreeView.Types;

interface

uses
  System.Classes, System.SysUtils, System.Variants;

type
  TDACTreeItemData = record
    Key, ParentKey: Variant;
    Text: string;
    SubItems: TArray<string>;
    Checked, Checkable: Boolean;
    class function Create(const AKey, AParentKey: Variant;
      const AText: string; ACheckable: Boolean = True): TDACTreeItemData; static;
  end;

  TDACTreeChangeReason = (tcrUser, tcrProgrammatic, tcrDataSet, tcrRemoved, tcrReset);
  TDACTreeKeyKind = (tkkText, tkkInteger, tkkGuid, tkkAuto);
  TDACTreeCurrentEvent = procedure(Sender: TObject;
    const OldKey, NewKey: Variant; Reason: TDACTreeChangeReason) of object;
  TDACTreeBeforeCheckEvent = procedure(Sender: TObject;
    const Key: Variant; const Checked: Boolean; var Allow: Boolean) of object;
  TDACTreeCheckEvent = procedure(Sender: TObject;
    const Key: Variant; Checked: Boolean; Reason: TDACTreeChangeReason) of object;
  TDACTreeActivateEvent = procedure(Sender: TObject; const Key: Variant) of object;
  TDACTreeErrorEvent = procedure(Sender: TObject;
    const Key: Variant; const MessageText: string) of object;

  EDACTreeDataError = class(Exception)
  private
    FKey: Variant;
  public
    constructor CreateKey(const AMessage: string; const AKey: Variant);
    property Key: Variant read FKey;
  end;

function TreeKeyToken(const AValue: Variant;
  const AKind: TDACTreeKeyKind): string;

implementation

class function TDACTreeItemData.Create(const AKey, AParentKey: Variant;
  const AText: string; ACheckable: Boolean): TDACTreeItemData;
begin
  Result := Default(TDACTreeItemData);
  Result.Key := AKey;
  Result.ParentKey := AParentKey;
  Result.Text := AText;
  Result.Checkable := ACheckable;
end;

constructor EDACTreeDataError.CreateKey(const AMessage: string; const AKey: Variant);
begin
  inherited Create(AMessage);
  FKey := AKey;
end;

function TreeKeyToken(const AValue: Variant;
  const AKind: TDACTreeKeyKind): string;
var
  LType: TVarType;
  LGuid: TGUID;
  LInteger: Int64;
begin
  if VarIsNull(AValue) or VarIsEmpty(AValue) then
    raise EDACTreeDataError.CreateKey('A record key cannot be null.', AValue);
  LType := VarType(AValue);
  if AKind = tkkAuto then
  begin
    if VarIsStr(AValue) then Exit(TreeKeyToken(AValue, tkkText));
    Exit(TreeKeyToken(AValue, tkkInteger));
  end;
  case AKind of
    tkkText:
      begin
        if not VarIsStr(AValue) then
          raise EDACTreeDataError.CreateKey('A textual key requires a string value.', AValue);
        Result := 'S:' + string(AValue);
      end;
    tkkInteger:
      begin
        if not (LType in [varSmallint, varInteger, varShortInt, varByte,
          varWord, varLongWord, varInt64, varUInt64]) then
          raise EDACTreeDataError.CreateKey('An integer key requires an integer value.', AValue);
        { Delphi 10.2 wraps a UInt64 variant into Int64 without raising. Do not
          allow a large unsigned value to alias a negative record key. }
        if (LType = varUInt64) and (TVarData(AValue).VUInt64 > UInt64(High(Int64))) then
          raise EDACTreeDataError.CreateKey('Integer key is outside the Int64 range.', AValue);
        try
          LInteger := AValue;
          Result := 'I:' + IntToStr(LInteger);
        except
          on E: Exception do
            raise EDACTreeDataError.CreateKey('Integer key is outside the Int64 range.', AValue);
        end;
      end;
    tkkGuid:
      begin
        if not VarIsStr(AValue) then
          raise EDACTreeDataError.CreateKey('A GUID key requires a GUID string.', AValue);
        try
          LGuid := StringToGUID(string(AValue));
        except
          on E: EConvertError do
            raise EDACTreeDataError.CreateKey('Invalid GUID key.', AValue);
        end;
        Result := 'G:' + GUIDToString(LGuid);
      end;
  else
    Result := '';
  end;
end;

end.
