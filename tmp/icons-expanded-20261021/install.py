from pathlib import Path
root=Path(r'M:\Delphi Componentes\DAC-DelphiComponents')
def change(name, old, new):
    p=root/name; s=p.read_bytes().decode('cp1252').replace('\r\n','\n')
    assert old in s, name
    p.write_bytes(s.replace(old,new,1).replace('\n','\r\n').encode('cp1252'))
change('Source/Skia/DAC.Components.Skia.IconPainter.pas','    mikWarning:\n', '    mikWarning,\n    mikFileWarning:\n')
change('Source/Skia/DAC.Components.Skia.IconPainter.pas','    mikCheck,\n', '    mikCheck,\n    mikFileCheck,\n')
change('Tests/DACComponentsInteraction.Current.dpr','  System.Classes,', "  DACComponentsIcons.Tests in 'DACComponentsIcons.Tests.pas',\n  System.Classes,")
change('Tests/DACComponentsInteraction.Current.dpr','  RequireResolverContract;', '  TDACComponentsIconTests.Run;\n  RequireResolverContract;')
change('demo/Demo.Principal.pas','    btnIconDanger: TDACButton;', '    btnIconDanger: TDACButton;\n    btnIconFileJson: TDACButton;\n    btnIconFolderOpen: TDACButton;\n    btnIconDatabase: TDACButton;')
p=root/'demo/Demo.Principal.dfm'; s=p.read_bytes().decode('cp1252').replace('\r\n','\n')
start=s.index('        object gcButtonIcons: TDACGridContainer')
end=s.index('        object lblButtonStates:',start)
block=s[start:end]; marker='        end\n'
assert block.endswith(marker)
children=''
for index,(name,caption,kind) in enumerate([('FileJson','Arquivo JSON','mikFileJson'),('FolderOpen','Pasta aberta','mikFolderOpen'),('Database','Banco de dados','mikDatabase')]):
    children+=f'''          object btnIcon{name}: TDACButton
            Left = {40+index*190}
            Top = 580
            Width = 180
            Height = 46
            Caption = '{caption}'
            Kind = mbkSecondary
            ShowIcon = True
            IconKind = {kind}
            Tag = 3
            TabOrder = {index+6}
          end
'''
s=s[:start]+block[:-len(marker)]+children+marker+s[end:]
p.write_bytes(s.replace('\n','\r\n').encode('cp1252'))
# Keep new Delphi source in the same legacy encoding/line endings.
p=root/'Tests/DACComponentsIcons.Tests.pas'
p.write_bytes(p.read_text('utf8').replace('\r\n','\n').replace('\n','\r\n').encode('cp1252'))
print('Added demo examples, semantic states, and tests to the existing interaction project.')
