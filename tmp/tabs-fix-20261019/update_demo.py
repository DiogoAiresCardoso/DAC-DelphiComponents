from pathlib import Path
root=Path(r'M:\Delphi Componentes\DAC-DelphiComponents')
p=root/'demo/Demo.Principal.pas'
b=p.read_bytes()
encoding='utf-8-sig'
try: s=b.decode(encoding)
except UnicodeDecodeError: encoding='cp1252'; s=b.decode(encoding)
s=s.replace('\r\n','\n')
a=s.index('procedure TForm1.ConfigureTabsLayout;')
z=s.index('procedure TForm1.ConfigureDashboardLayout;',a)
part=s[a:z]
part=part.replace('  LActualPoint: TPoint;\n  LDesiredLeft: Integer;\n  LPage: TTabSheet;\n  LRight: Integer;\n  LTabs: TDACTabs;\n  LText: TDACSystemText;', '''  LHorizontal, LVertical: TDACTabs;
  LAvailable, LColumn, LInset, LGap: Integer;
  LCaption: TLabel;''')
c=part.index('  procedure LayoutActiveVerticalText(')
d=part.index('\nbegin\n  if csDesigning',c)
part=part[:c]+part[d:]
c=part.index("  LTabs := FindComponent('demoTabs')")
part=part[:c]+'''  if GalleryTabs.ActivePage <> tsTabs then Exit;
  LHorizontal := FindComponent('demoTabs') as TDACTabs;
  LVertical := FindComponent('demoVerticalTabs') as TDACTabs;
  LInset := Round(TDACSpacingTokens.Default.S24);
  LGap := LInset;
  LAvailable := Max(0, tsTabs.ClientWidth - 2 * LInset);
  if (LHorizontal <> nil) and (LVertical <> nil) then
  begin
    if LAvailable >= 720 then
    begin
      LColumn := (LAvailable - LGap) div 2;
      LHorizontal.SetBounds(LInset, 56, LColumn, 260);
      LVertical.SetBounds(LInset + LColumn + LGap, 56,
        LAvailable - LColumn - LGap, 260);
    end
    else
    begin
      LHorizontal.SetBounds(LInset, 56, LAvailable, 220);
      LVertical.SetBounds(LInset, LHorizontal.Top + LHorizontal.Height + LGap,
        LAvailable, 260);
    end;
    LHorizontal.RefreshContentLayout;
    LVertical.RefreshContentLayout;
  end;
  LCaption := FindComponent('lblTabs') as TLabel;
  if LCaption <> nil then LCaption.Font.Color := TDACComponentColors.ToVclColor(
    GalleryTabs.ResolvedTokens.ContainerTitle);
end;

'''
s=s[:a]+part+s[z:]
# Preserve original encoding and CRLF; only this layout method is changed.
p.write_bytes(s.replace('\n','\r\n').encode(encoding))

p=root/'Source/Controls/DAC.Components.Controls.Tabs.pas'
s=p.read_text(encoding='utf-8').replace('\r\n','\n')
a=s.index('  // A TSkPaintBox is a TGraphicControl.')
b=s.index('  TDACTabHeaderControl = class',a)
s=s[:a]+'''  // A windowed, owned header keeps Skia chrome and native Windows text
  // together inside TDACTabs. The native TTabSheet layout reserves its bounds
  // in both the VCL designer and runtime; no sibling overlay is required.
'''+s[b:]
s=s.replace('''  { Compatibility value only. The DAC header owns the visible extent and the
    native strip is fixed to one pixel by ApplyNativeTabSize. Keeping this in
    managed state avoids TCustomTabControl.SetTabHeight forcing Handle while a
    parentless DFM root is being read. }''','''  { Store without touching the native tab setter: that setter forces HWND
    creation during standalone DFM reads. ResolveSizeMetrics applies the value
    to the visible header in both the designer and runtime. }''')
s=s.replace('  FActivePageHeaderOnly := AValue;\n  InvalidateTabs;',
            '  FActivePageHeaderOnly := AValue;\n  QueueContentLayout;\n  InvalidateTabs;')
p.write_bytes(s.replace('\n','\r\n').encode('utf-8'))
