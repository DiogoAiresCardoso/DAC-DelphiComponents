import hashlib
import json
import shutil
from pathlib import Path

root = Path(__file__).resolve().parents[2]
run = root / 'tmp/chart-types-work'
out = root / 'docs/charts/evidence/types-2026-09-22'
for folder in ('logs', 'commands', 'dac'):
    (out / folder).mkdir(parents=True, exist_ok=True)
for p in run.glob('build-*.log'):
    shutil.copy2(p, out / 'logs' / p.name)
for p in run.glob('build-*.cmd'):
    shutil.copy2(p, out / 'commands' / p.name)
shutil.copy2(run / 'tests-final.log', out / 'logs/tests.log')
shutil.copy2(run / 'demo-captures/result.txt', out / 'logs/demo-result.txt')
shutil.copy2(run / 'pixel-regression.json', out / 'pixel-regression.json')
for p in (run / 'demo-captures').iterdir():
    if p.suffix in ('.png', '.json'):
        shutil.copy2(p, out / 'dac' / p.name)

def entry(p, base, key='path'):
    data = p.read_bytes()
    return {key: p.relative_to(base).as_posix(), 'bytes': len(data),
            'sha256': hashlib.sha256(data).hexdigest()}

sources = [
    'Source/Core/DAC.Components.Charts.Types.pas',
    'Source/Controls/DAC.Components.Charts.Options.pas',
    'Source/Controls/DAC.Components.Controls.Charts.pas',
    'Source/Skia/DAC.Components.Charts.Engine.pas',
    'Source/Skia/DAC.Components.Charts.Surface.pas',
    'Tests/DACComponentsCharts.TypesTests.pas', 'Tests/DACComponentsCharts.dpr',
    'Tests/Charts.Visual/fixtures.json', 'Tests/Charts.Visual/compare.py',
    'demo-charts/DACChartsDemo.Main.pas', 'demo-charts/DACChartsDemo.Main.dfm',
    'Package/DACSkiaComponents.dpk', 'Package/DACSkiaComponents.dproj',
    'Package/DACSkiaComponentsRuntime.dpk'
]
report = json.loads((out / 'dac/comparison.json').read_text(encoding='utf-8'))
regression = json.loads((out / 'pixel-regression.json').read_text(encoding='utf-8'))
assert len(report['cases']) == 29
assert len(regression) == 29 and all(c['unchangedPixels'] for c in regression)
manifest = {
    'executedAt': '2026-09-22',
    'scope': 'typed_api_validation_and_existing_fixture_regression',
    'environment': {'compiler': 'Delphi Tokyo 10.2, dcc32 32.0', 'platform': 'Win32', 'config': 'Debug'},
    'buildExitCodes': {p.stem: 0 for p in sorted(run.glob('build-*.log'))},
    'testExitCode': 0, 'demoExitCode': 0, 'comparisonExitCode': 1,
    'geometryPass': sum(c['geometry'] == 'pass' for c in report['cases']),
    'textContentPass': sum(c['textContent'] == 'pass' for c in report['cases']),
    'unchangedDACImages': 29, 'knownFailure': 'V15 text truncation',
    'physicalFlickerAcceptance': 'inconclusive_not_rerun',
    'automaticVisualApproval': False,
    'sources': [entry(root / p, root) for p in sources],
    'binaries': [entry(p, root) for p in sorted(run.rglob('*')) if p.suffix in ('.exe', '.bpl')],
    'artifacts': [entry(p, out, 'archivePath') for p in sorted(out.rglob('*')) if p.is_file() and p.name != 'manifest.json']
}
(out / 'manifest.json').write_text(json.dumps(manifest, ensure_ascii=False, indent=2) + '\n', encoding='utf-8')
print(json.dumps({k: manifest[k] for k in ('geometryPass', 'textContentPass', 'unchangedDACImages')}))
