from pathlib import Path
p=Path(r'M:\Delphi Componentes\DAC-DelphiComponents\Source\Controls\DAC.Components.Controls.Button.pas')
s=p.read_bytes().decode('cp1252').replace('\r\n','\n')
s=s.replace('    function ButtonFontSize: Single;', '    function ButtonFontSize: Single;\n    function CaptionFontFamily: string;\n    function CaptionFontBold: Boolean;',1)
s=s.replace('    procedure CMTextChanged(var AMessage: TMessage); message CM_TEXTCHANGED;', '    procedure CMTextChanged(var AMessage: TMessage); message CM_TEXTCHANGED;\n    procedure CMFontChanged(var AMessage: TMessage); message CM_FONTCHANGED;',1)
marker='  LTokens := ResolvedTokens;\n  case FSize of'
pos=s.index('function TDACButton.ButtonFontSize: Single;')
end=s.index('function TDACButton.CanvasBackground(',pos)
block=s[pos:end]
block=block.replace(marker, '''  if not ParentFont then Exit(Max(1, Font.Size));
  LTokens := ResolvedTokens;
  if FKind = mbkInputAction then Exit(LTokens.ButtonInputActionCaptionTextSize);
  case FSize of''',1)
block+='''function TDACButton.CaptionFontFamily: string;
begin
  if not ParentFont and (Trim(Font.Name) <> '') then Result := Font.Name
  else Result := TDACComponentFontInstaller.FontFamily;
end;

function TDACButton.CaptionFontBold: Boolean;
begin
  if not ParentFont then Result := fsBold in Font.Style
  else if FKind = mbkInputAction then Result := True
  else Result := ResolvedTokens.ButtonCaptionBold;
end;

'''
s=s[:pos]+block+s[end:]
s=s.replace('      TDACComponentFontInstaller.FontFamily, Round(ButtonFontSize), True)', '      CaptionFontFamily, Round(ButtonFontSize), CaptionFontBold)')
old='''procedure TDACButton.CMTextChanged(var AMessage: TMessage);
begin
  inherited;
  UpdateLabel;
end;'''
new='''procedure TDACButton.CMTextChanged(var AMessage: TMessage);
begin
  inherited;
  // Both layers depend on caption width. Invalidate the cached Skia frame
  // together with the native label, even if the button bounds stay the same.
  InvalidateButton;
end;

procedure TDACButton.CMFontChanged(var AMessage: TMessage);
begin
  inherited;
  InvalidateButton;
end;'''
assert old in s;s=s.replace(old,new,1)
pos=s.index('procedure TDACButton.UpdateLabel;');end=s.index('procedure TDACButton.UpdatePaintBoxBounds;',pos)
block=s[pos:end].replace('TDACComponentFontInstaller.FontFamily','CaptionFontFamily').replace('Round(LTokens.ButtonInputActionCaptionTextSize)','Round(ButtonFontSize)').replace('FTextLabel.Bold := True;','FTextLabel.Bold := CaptionFontBold;').replace('FTextLabel.Bold := LTokens.ButtonCaptionBold;','FTextLabel.Bold := CaptionFontBold;')
s=s[:pos]+block+s[end:]
p.write_bytes(s.replace('\n','\r\n').encode('cp1252'))
print('Caption/font changes invalidate both layers; measurement and native rendering share font metrics.')
