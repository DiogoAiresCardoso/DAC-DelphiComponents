from pathlib import Path
import hashlib
import json
import shutil

root = Path(__file__).resolve().parents[1]
docs = root / 'docs/charts'
run = root / 'tmp/chart-title-spacing'
out = docs / 'evidence/title-spacing-2026-09-22'

def digest_entry(p, base, key):
    data = p.read_bytes()
    return {key: p.relative_to(base).as_posix(), 'bytes': len(data),
            'sha256': hashlib.sha256(data).hexdigest()}

copies = {}
for name in ('build-demo.log', 'tests.log'):
    copies[run / name] = out / 'logs' / name
for p in run.glob('build-*.cmd'):
    copies[p] = out / 'commands' / p.name
copies[run / 'fixture.json'] = out / 'fixture.json'
for p in (run / 'demo-captures').iterdir():
    if p.is_file():
        copies[p] = out / 'demo' / p.name
for p in (run / 'captures').glob('title-*.png'):
    copies[p] = out / 'titles' / p.name
fixtures = json.loads((root / 'Tests/Charts.Visual/fixtures.json').read_text(encoding='utf-8-sig'))
for case in fixtures['cases']:
    for suffix in ('.png', '.json'):
        p = run / 'captures' / (case['id'] + suffix)
        copies[p] = out / 'cases' / p.name
for p, dest in copies.items():
    dest.parent.mkdir(parents=True, exist_ok=True)
    shutil.copy2(p, dest)
assert len(list((out / 'titles').glob('*.png'))) == 24
manifest = {
    'executedAt': '2026-09-22', 'archivedAt': '2026-09-23',
    'origin': 'tmp/chart-title-spacing',
    'rendererRerunDuringConsolidation': False,
    'environment': {'compiler': 'Delphi Tokyo 10.2, dcc32 32.0', 'platform': 'Win32', 'config': 'Debug'},
    'matrix': {'variants': 6, 'logicalWidths': [320,720,1280], 'syntheticDpis': [96,120,144,192],
               'combinations': 72, 'storedMatrixPngs': 24, 'additionalChecks': ['remove title', 'larger grid.top']},
    'results': {'tests': 'pass', 'demo': 'OK', 'testBuildLog': 'not_saved',
                'fullEChartsComparisonAfterTitleChange': 'not_run', 'physicalFlicker': 'not_retested'},
    'sourceHashMeaning': 'Collected on 2026-09-23 from current checkout; not a build-time provenance record.',
    'sourceHashesAtConsolidation': [digest_entry(root / p, root, 'path') for p in (
        'Source/Skia/DAC.Components.Charts.Engine.pas', 'Tests/DACComponentsCharts.dpr',
        'Source/Core/DAC.Components.Charts.Types.pas', 'Source/Controls/DAC.Components.Charts.Options.pas',
        'Source/Controls/DAC.Components.Controls.Charts.pas', 'Source/Skia/DAC.Components.Charts.Surface.pas')],
    'binaryHashesAtConsolidation': [digest_entry(p, root, 'path') for p in sorted(run.rglob('*.exe'))],
    'artifacts': [dict(digest_entry(p, out, 'archivePath'),
                       origin=next((src.relative_to(root).as_posix() for src, dest in copies.items() if dest == p), 'documentation'))
                  for p in sorted(out.rglob('*')) if p.is_file() and p.name != 'manifest.json']
}
(out / 'manifest.json').write_text(json.dumps(manifest, ensure_ascii=False, indent=2)+'\n', encoding='utf-8')

# Historical narrative stays intact; the notice routes new consumers to current contracts.
historic = ['dac-chart-api.md', 'dac-chart-data-sources.md', 'dac-chart-single-component-plan.md',
            'dac-charts-demo.md', 'echarts-property-map.md', 'implementation-2026-09-22.md',
            'validation-2026-09-22.md', 'consolidation-2026-09-22.md']
for name in historic:
    p = docs / name
    s = p.read_text(encoding='utf-8-sig')
    note = '> **Estado atual — 23/09/2026:** consulte a [consolidação atual](consolidation-2026-09-23.md) para API tipada, validação transacional, espaço do título e evidências posteriores. O conteúdo abaixo preserva sua etapa histórica.\n\n'
    p.write_text(note+s, encoding='utf-8')
p = docs / 'echarts-reference/README.md'
s = p.read_text(encoding='utf-8-sig')
s = s.replace('## Implementação atual\n', '## Implementação atual\n\nO [registro de 23/09/2026](../consolidation-2026-09-23.md) consolida as alterações\nposteriores: API Delphi tipada e proteção local de espaço para título. O contrato\nECharts abaixo permanece fixado; a adaptação local de grid está explicitada no manual.\n')
p.write_text(s, encoding='utf-8')
p = docs / 'manual/04-geometria-desenho.md'
s = p.read_text(encoding='utf-8').replace('`Title.ItemGap` é somente', '`title.itemGap` no JSON é somente')
p.write_text(s, encoding='utf-8')
print(json.dumps({'titleArtifacts': len(manifest['artifacts']), 'historicalNotices': len(historic)}))
