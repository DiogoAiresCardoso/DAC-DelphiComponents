from pathlib import Path
p=Path(r'M:\Delphi Componentes\DAC-DelphiComponents\Source\Controls\DAC.Components.Controls.Tabs.pas')
s=p.read_text(encoding='utf-8').replace('\r\n','\n')
s=s.replace('    TextBounds: TRectF;','    TextBounds: TRectF;\n    Text: string;',1)
s=s.replace('    function CaptionSize(const AText: string; const AWidth: Integer): TSize;',
'''    function CaptionSize(const AText: string; const AWidth: Integer): TSize;
    function WrappedCaption(const AText: string; const AWidth: Integer): string;''',1)
a=s.index('function TDACTabHeaderControl.CaptionSize(')
s=s[:a]+'''function TDACTabHeaderControl.WrappedCaption(const AText: string;
  const AWidth: Integer): string;
var
  I, Count: Integer;
  Word, Glyph: string;
begin
  Result := '';
  Word := '';
  SetTextFont(FMeasureBitmap.Canvas, True);
  I := 1;
  while I <= Length(AText) do
  begin
    Count := 1;
    if (Ord(AText[I]) >= $D800) and (Ord(AText[I]) <= $DBFF) and
      (I < Length(AText)) and (Ord(AText[I + 1]) >= $DC00) and
      (Ord(AText[I + 1]) <= $DFFF) then Count := 2;
    Glyph := Copy(AText, I, Count);
    if AText[I] <= ' ' then
    begin
      Result := Result + Word + Glyph;
      Word := '';
    end
    else
    begin
      if (Word <> '') and
        (FMeasureBitmap.Canvas.TextWidth(Word + Glyph) > Max(1, AWidth)) then
      begin
        Result := Result + Word + sLineBreak;
        Word := '';
      end;
      Word := Word + Glyph;
    end;
    Inc(I, Count);
  end;
  Result := Result + Word;
end;

'''+s[a:]
s=s.replace('  R: TRect;\nbegin\n  // Reserve the bold', '  R: TRect;\n  Text: string;\nbegin\n  // Reserve the bold',1)
s=s.replace('    DrawText(FMeasureBitmap.Canvas.Handle, PChar(AText), Length(AText), R,',
'''    Text := WrappedCaption(AText, AWidth);
    DrawText(FMeasureBitmap.Canvas.Handle, PChar(Text), Length(Text), R,''',1)
s=s.replace('    Result[I].TextBounds.Inflate(-Metrics.PaddingHorizontal, -Metrics.PaddingVertical);',
'''    Result[I].TextBounds.Inflate(-Metrics.PaddingHorizontal, -Metrics.PaddingVertical);
    Result[I].Text := WrappedCaption(FTabs.Pages[Result[I].PageIndex].Caption,
      Floor(Result[I].TextBounds.Width));''',1)
s=s.replace('PChar(Page.Caption), Length(Page.Caption)', 'PChar(Layout[I].Text), Length(Layout[I].Text)')
p.write_bytes(s.replace('\n','\r\n').encode('utf-8'))

p=Path(r'M:\Delphi Componentes\DAC-DelphiComponents\Tests\DACComponentsTabs.dpr')
s=p.read_text(encoding='utf-8-sig').replace('\r\n','\n')
s=s.replace('      DrawText(B.Canvas.Handle, PChar(Tabs.Pages[Layout[I].PageIndex].Caption),\n        -1, R,',
'''      Require(StringReplace(Layout[I].Text, sLineBreak, '', [rfReplaceAll]) =
        Tabs.Pages[Layout[I].PageIndex].Caption, 'Layout descartou caracteres da caption.');
      DrawText(B.Canvas.Handle, PChar(Layout[I].Text),
        -1, R,''',1)
p.write_bytes(s.replace('\n','\r\n').encode('utf-8'))
