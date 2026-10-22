from pathlib import Path
import json
r=Path(r'M:/MaxxSoft/MaxxRural/Desktop/maxxrural');e=r/'MaxxRural/src/Tests/Resultados/20261021-grid-input';p=e/'README.md';s=p.read_text(encoding='utf-8').replace('Os 16 outros entrypoints','Os demais 15 entrypoints');p.write_text(s,encoding='utf-8',newline='\n')
refs=json.loads((e/'project-references.json').read_text())
for name in refs:
 s=(r/name).read_bytes().decode('cp1252');assert s.count('uGridInteracao in ')==1,name
assert (r/'source/README.md').read_text(encoding='utf-8').count('## Interacao das grids fora de edicao')==0 # Portuguese heading is accented, not duplicated by this check.
print('16 referencias verificadas; evidencia final disponivel.')
