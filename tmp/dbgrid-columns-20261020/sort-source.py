from pathlib import Path
p=Path('Source/Controls/DAC.Components.Controls.DBGrid.ClientDataSetSort.pas');s=p.read_bytes().decode('cp1252').replace('\r\n','\n');s=s.replace('uses System.Classes, System.SysUtils;','uses System.Classes, System.SysUtils,\n  DAC.Components.Controls.DBGrid.ClientDataSetSortSource;');s=s.replace('  Index: TIndexDef;','  Index: TIndexDef;\n  HasSource: Boolean;');s=s.replace('  Fields := Field.FieldName;', '''  HasSource := False;
  for I := 0 to ADataSet.ComponentCount - 1 do
    if ADataSet.Components[I] is TDACDBGridClientDataSetSortSource then
    begin HasSource := True; Break; end;
  if not HasSource then TDACDBGridClientDataSetSortSource.Create(ADataSet);
  Fields := Field.FieldName;''');p.write_bytes(s.replace('\n','\r\n').encode('cp1252'))
