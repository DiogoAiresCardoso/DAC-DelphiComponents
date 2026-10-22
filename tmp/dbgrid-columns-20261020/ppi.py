from pathlib import Path
def edit(suffix,fn):
 p=Path('Source/Controls/DAC.Components.Controls.DBGrid'+suffix+'.pas');s=p.read_bytes().decode('cp1252').replace('\r\n','\n');p.write_bytes(fn(s).replace('\n','\r\n').encode('cp1252'))
def grid(s):
 a=s.index('function TDACDBGrid.EffectivePPI: Integer;');z=s.index('constructor TDACDBGrid.Create',a)
 s=s[:a]+'''function TDACDBGrid.EffectivePPI: Integer;
begin
  // VCL tracks the DPI applied to the parent hierarchy, including monitor changes.
  // LOGPIXELSX from a window DC can still report the system DPI.
  Result := GetParentCurrentDpi;
  if Result <= 0 then Result := Screen.PixelsPerInch;
  if Result <= 0 then Result := 96;
end;

'''+s[z:]
 a=s.index('procedure TDACDBGrid.ApplyDensityMetrics;');z=s.index('\nend;',a)
 body=s[a:z];pos=body.index('begin\n')+len('begin\n');body=body[:pos]+'  if FLayoutManager <> nil then FLayoutManager.PixelsPerInch := EffectivePPI;\n'+body[pos:];s=s[:a]+body+s[z:]
 return s
edit('',grid)
def layout(s):
 s=s.replace('    FIdentity: string;', '    FIdentity: string;\n    FPixelsPerInch: Integer;')
 s=s.replace('    property Applying:', '    property PixelsPerInch: Integer read FPixelsPerInch write FPixelsPerInch;\n    property Applying:')
 a=s.index('function GridPPI(');z=s.index('constructor TDACDBGridLayoutManager.Create',a);s=s[:a]+s[z:]
 s=s.replace('  FGrid := AGrid;', '  FGrid := AGrid;\n  FPixelsPerInch := 96;')
 s=s.replace('GridPPI(FGrid)', 'FPixelsPerInch')
 return s
edit('.LayoutManager',layout)
p=Path('Tests/DACDBGridTests.dpr');s=p.read_bytes().decode('cp1252').replace('\r\n','\n');s=s.replace("LController.NextDirection('name') = dgsNone,\n      'Terceiro ciclo de ordena\u00e7\u00e3o deve remover a ordena\u00e7\u00e3o.'", "LController.NextDirection('name') = dgsAscending,\n      'Terceiro ciclo de ordenacao deve voltar ao sentido ascendente.'");p.write_bytes(s.replace('\n','\r\n').encode('cp1252'))
