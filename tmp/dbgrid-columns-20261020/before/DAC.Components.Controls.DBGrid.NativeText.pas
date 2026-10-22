unit DAC.Components.Controls.DBGrid.NativeText;

interface

uses
  System.Classes,
  System.Generics.Collections,
  System.Types,
  Winapi.Windows,
  DAC.Components.Controls.DBGrid.Types;

function DACMeasureDBGridText(const ADC: HDC; const AFontFamily,
  AText: string; const AFontSize: Integer; const ABold: Boolean;
  const APPI: Integer): TSize;
procedure DACDrawDBGridTextItems(const ADC: HDC; const AFontFamily: string;
  const APPI: Integer; const AItems: TList<TDACDBGridTextItem>);

implementation

uses
  System.Math,
  System.UITypes,
  Vcl.Graphics,
  DAC.Components.DesignSystem.ColorTokens;

function CreateGridFont(const AFamily: string; const ASize: Integer;
  const ABold: Boolean; const APPI: Integer): HFONT;
var
  LHeight: Integer;
  LWeight: Integer;
begin
  LHeight := -MulDiv(Max(1, ASize), Max(96, APPI), 72);
  if ABold then
    LWeight := FW_BOLD
  else
    LWeight := FW_NORMAL;
  Result := CreateFont(LHeight, 0, 0, 0, LWeight, 0, 0, 0,
    DEFAULT_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS,
    CLEARTYPE_QUALITY, DEFAULT_PITCH or FF_DONTCARE, PChar(AFamily));
end;

function DACMeasureDBGridText(const ADC: HDC; const AFontFamily,
  AText: string; const AFontSize: Integer; const ABold: Boolean;
  const APPI: Integer): TSize;
var
  LFont: HFONT;
  LOldFont: HGDIOBJ;
begin
  Result.cx := 0;
  Result.cy := 0;
  if (ADC = 0) or (AText = '') then
    Exit;
  LFont := CreateGridFont(AFontFamily, AFontSize, ABold, APPI);
  if LFont = 0 then
    Exit;
  LOldFont := SelectObject(ADC, LFont);
  try
    GetTextExtentPoint32(ADC, PChar(AText), Length(AText), Result);
  finally
    SelectObject(ADC, LOldFont);
    DeleteObject(LFont);
  end;
end;

procedure DACDrawDBGridTextItems(const ADC: HDC; const AFontFamily: string;
  const APPI: Integer; const AItems: TList<TDACDBGridTextItem>);
var
  I: Integer;
  LFlags: Cardinal;
  LFont: HFONT;
  LItem: TDACDBGridTextItem;
  LOldFont: HGDIOBJ;
  LRect: TRect;
begin
  if (ADC = 0) or (AItems = nil) then
    Exit;
  SetBkMode(ADC, TRANSPARENT);
  for I := 0 to AItems.Count - 1 do
  begin
    LItem := AItems[I];
    if LItem.Text = '' then
      Continue;
    LFont := CreateGridFont(AFontFamily, LItem.FontSize, LItem.Bold, APPI);
    if LFont = 0 then
      Continue;
    LOldFont := SelectObject(ADC, LFont);
    try
      SetTextColor(ADC, TDACComponentColors.ToVclColor(LItem.Color));
      LFlags := DT_SINGLELINE or DT_VCENTER or DT_NOPREFIX;
      case LItem.Alignment of
        taRightJustify: LFlags := LFlags or DT_RIGHT;
        taCenter: LFlags := LFlags or DT_CENTER;
      else
        LFlags := LFlags or DT_LEFT;
      end;
      if LItem.Ellipsis then
        LFlags := LFlags or DT_END_ELLIPSIS;
      LRect := LItem.Bounds;
      DrawText(ADC, PChar(LItem.Text), Length(LItem.Text), LRect, LFlags);
    finally
      SelectObject(ADC, LOldFont);
      DeleteObject(LFont);
    end;
  end;
end;

end.
