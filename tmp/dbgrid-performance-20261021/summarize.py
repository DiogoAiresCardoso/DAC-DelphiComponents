from pathlib import Path
from collections import defaultdict
import csv, json, statistics, hashlib, shutil, datetime, xml.etree.ElementTree as ET

root = Path(r'M:\MaxxSoft\MaxxRural\Desktop\maxxrural')
tests = root / 'MaxxRural/src/Tests'
out = tests / 'Resultados/20261021-grid-performance'
component = Path(r'M:\Delphi Componentes\DAC-DelphiComponents')
metrics = ['paint', 'vertical_scroll', 'horizontal_scroll', 'hover', 'action', 'action_after_sort']
rows = []
for run in range(1, 4):
    name = f'run{run:02d}'
    report = ET.parse(out / f'{name}.xml').getroot()
    assert report.attrib['total'] == '12', report.attrib
    assert report.attrib['errors'] == report.attrib['failures'] == '0', report.attrib
    files = sorted((out / name).glob('*.json'))
    assert len(files) == 12
    for path in files:
        data = json.loads(path.read_text('utf-8-sig'))
        assert data['assertions_passed']
        assert data['grid_controls_before'] == data['grid_controls_after'] == 0
        assert data['grid_components_before'] == data['grid_components_after'] == 0
        assert data['action_state_queries_one_paint'] == 27
        assert 'jump_last_ms' in data
        flat = {k: v for k, v in data.items() if not isinstance(v, (dict, list))}
        flat['run'] = run
        flat['sort_cold_ms'] = data['sort'][0]['ms']
        flat['sort_warm_max_ms'] = max(x['ms'] for x in data['sort'][2:])
        for metric in metrics:
            assert data[metric]['samples'] == 60
            for stat in ['median_ms', 'p95_ms', 'max_ms']:
                flat[f'{metric}_{stat}'] = data[metric][stat]
        rows.append(flat)

with (out / 'measurements.csv').open('w', newline='', encoding='utf-8-sig') as stream:
    writer = csv.DictWriter(stream, fieldnames=list(rows[0]))
    writer.writeheader(); writer.writerows(rows)

groups = defaultdict(list)
for row in rows:
    groups[(row['rows'], row['checkbox_uniform_false'])].append(row)
summary = []
for (count, checkbox), group in sorted(groups.items()):
    aggregate = dict(rows=count, checkbox=checkbox, scenarios=len(group))
    for key in ['dataset_load_ms', 'attach_first_paint_ms', 'jump_middle_ms', 'jump_last_ms', 'sort_cold_ms', 'sort_warm_max_ms']:
        aggregate[key] = {'min': min(x[key] for x in group), 'max': max(x[key] for x in group)}
    for metric in metrics:
        aggregate[metric] = {
            'median_of_medians_ms': statistics.median(x[f'{metric}_median_ms'] for x in group),
            'worst_p95_ms': max(x[f'{metric}_p95_ms'] for x in group),
            'worst_sample_ms': max(x[f'{metric}_max_ms'] for x in group),
            'samples': len(group) * 60,
        }
    for key in ['working_set_loaded_bytes', 'working_set_after_free_bytes', 'gdi_objects_loaded', 'gdi_objects_after_free', 'user_objects_loaded', 'user_objects_after_free']:
        aggregate[key] = {'min': min(x[key] for x in group), 'max': max(x[key] for x in group)}
    summary.append(aggregate)
(out / 'summary.json').write_text(json.dumps(summary, indent=2), encoding='utf-8')
for row in summary:
    print(row['rows'], 'checkbox=', row['checkbox'], 'paint/v/h p95=',
          *(round(row[m]['worst_p95_ms'], 2) for m in metrics[:3]),
          'attach=', round(row['attach_first_paint_ms']['max'], 2),
          'sort=', round(row['sort_cold_ms']['max'], 2))

paths = [tests / 'Teste.MovimentoBancario.PerformanceGrid.pas', tests / 'ApiTestes.dpr']
legacy = {str(p): {'utf8_bom': p.read_bytes().startswith(b'\xef\xbb\xbf'), 'bare_lf': p.read_bytes().replace(b'\r\n',b'').count(b'\n')} for p in paths}
assert all(not r['utf8_bom'] and r['bare_lf'] == 0 for r in legacy.values())
prior = json.loads((tests / 'Resultados/20261021-grid-gaps/source-sha256.json').read_text('utf8'))
for path, expected in prior.items():
    if path.endswith(('DBGrid.pas', 'DBGrid.CellPainter.pas', 'Teste.MovimentoBancario.ColunasGrid.pas')):
        assert hashlib.sha256(Path(path).read_bytes()).hexdigest() == expected, path
legacy['production_grid_and_existing_fixture_unchanged'] = True
dfm = root / 'source/view/View.MovimentoBancario.dfm'
prior_dfm = json.loads((tests / 'Resultados/20261021-grid-pinned/source-sha256.json').read_text('utf8'))
assert hashlib.sha256(dfm.read_bytes()).hexdigest() == prior_dfm[str(dfm)]
legacy['production_dfm_unchanged'] = True
(out / 'format-checks.json').write_text(json.dumps(legacy, indent=2), encoding='utf8')
paths += [component / 'Source/Controls/DAC.Components.Controls.DBGrid.pas', component / 'Source/Controls/DAC.Components.Controls.DBGrid.SelectionController.pas', dfm]
(out / 'source-sha256.json').write_text(json.dumps({str(p): hashlib.sha256(p.read_bytes()).hexdigest() for p in paths}, indent=2), encoding='utf8')
exes = []
for name in ['ApiTestes.exe', 'MaxxRural.exe']:
    p = root / 'EXE' / name
    exes.append(dict(path=str(p), size=p.stat().st_size, modified=datetime.datetime.fromtimestamp(p.stat().st_mtime).isoformat(), sha256=hashlib.sha256(p.read_bytes()).hexdigest()))
(out / 'executaveis.json').write_text(json.dumps(exes, indent=2), encoding='utf8')
shutil.copy2(component / 'tmp/dbgrid-performance-20261021/audit.json', out / 'audit.json')
if Path(__file__).resolve() != (out / 'consolidar.py').resolve():
    shutil.copy2(__file__, out / 'consolidar.py')
