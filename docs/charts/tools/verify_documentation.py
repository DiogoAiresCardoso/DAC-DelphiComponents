"""Verify documentation links, JSON, archived hashes and frame mappings, not renderer fidelity."""
import hashlib
import json
import re
import struct
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
DOCS = ROOT / 'docs/charts'
ARCHIVE = DOCS / 'evidence/2026-09-22'
errors = []
links = 0
for path in sorted(DOCS.rglob('*.md')) + [ROOT / 'demo-charts/README.md', ROOT / 'README.md']:
    text = path.read_text(encoding='utf-8-sig')
    text = re.sub(r'```.*?```', '', text, flags=re.S)
    for match in re.finditer(r'!?\[[^\]\n]*\]\(([^)\n]+)\)', text):
        target = match.group(1).strip().strip('<>')
        if re.match(r'^[a-zA-Z][\w+.-]*://', target) or target.startswith('#'):
            continue
        target = target.split('#', 1)[0]
        if not target:
            continue
        links += 1
        if not (path.parent / target).exists():
            errors.append(f'Broken link {path.relative_to(ROOT)}: {target}')
json_count = 0
for path in DOCS.rglob('*.json'):
    try:
        json.loads(path.read_text(encoding='utf-8-sig'))
        json_count += 1
    except (ValueError, UnicodeError) as exc:
        errors.append(f'Invalid JSON {path}: {exc}')
manifest = json.loads((ARCHIVE / 'manifest.json').read_text(encoding='utf-8'))
for item in manifest['artifacts']:
    path = ARCHIVE / item['archivePath']
    if not path.exists():
        errors.append('Missing artifact: ' + item['archivePath'])
        continue
    data = path.read_bytes()
    if len(data) != item['bytes'] or hashlib.sha256(data).hexdigest() != item['sha256']:
        errors.append('Artifact mismatch: ' + item['archivePath'])
typed_archive = DOCS / 'evidence/types-2026-09-22'
typed_manifest = json.loads((typed_archive / 'manifest.json').read_text(encoding='utf-8'))
for item in typed_manifest['artifacts']:
    path = typed_archive / item['archivePath']
    if not path.exists():
        errors.append('Missing typed API artifact: ' + item['archivePath'])
        continue
    data = path.read_bytes()
    if len(data) != item['bytes'] or hashlib.sha256(data).hexdigest() != item['sha256']:
        errors.append('Typed API artifact mismatch: ' + item['archivePath'])
title_archive = DOCS / 'evidence/title-spacing-2026-09-22'
title_manifest = json.loads((title_archive / 'manifest.json').read_text(encoding='utf-8'))
for item in title_manifest['artifacts']:
    path = title_archive / item['archivePath']
    if not path.exists():
        errors.append('Missing title spacing artifact: ' + item['archivePath'])
        continue
    data = path.read_bytes()
    if len(data) != item['bytes'] or hashlib.sha256(data).hexdigest() != item['sha256']:
        errors.append('Title spacing artifact mismatch: ' + item['archivePath'])
expected_titles = {f'title-{variant}-{dpi}-720.png' for variant in range(6) for dpi in (96,120,144,192)}
if {p.name for p in (title_archive / 'titles').glob('*.png')} != expected_titles:
    errors.append('Title spacing matrix image inventory mismatch')
for name in expected_titles:
    path = title_archive / 'titles' / name
    if path.exists():
        dpi = int(name.split('-')[2])
        data = path.read_bytes()
        if data[:8] != b'\x89PNG\r\n\x1a\n' or struct.unpack('>II', data[16:24]) != (round(720*dpi/96), round(420*dpi/96)):
            errors.append('Title PNG dimensions mismatch: ' + name)
frame_count = 0
for index_path in sorted((ARCHIVE / 'sequences').glob('*/index.json')):
    index = json.loads(index_path.read_text(encoding='utf-8'))
    frames = {f['originalName']: f for f in index['frames']}
    records = [json.loads(s) for s in (index_path.parent / 'frames.jsonl').read_text(encoding='utf-8-sig').splitlines() if s.strip()]
    for record in records:
        name = f"frame-{record['frame']:06}.png"
        if name not in frames:
            errors.append(f'{index_path.parent.name}: missing {name}')
            continue
        item = frames[name]
        data = (index_path.parent / item['blob']).read_bytes()
        if hashlib.sha256(data).hexdigest() != item['sha256']:
            errors.append('Frame hash mismatch: ' + name)
        if data[:8] != b'\x89PNG\r\n\x1a\n' or struct.unpack('>II', data[16:24]) != (record['width'], record['height']):
            errors.append('Frame PNG dimensions mismatch: ' + name)
        frame_count += 1
fixtures = json.loads((ARCHIVE / 'reports/fixtures-at-consolidation.json').read_text(encoding='utf-8'))
report = json.loads((ARCHIVE / 'dac/comparison.json').read_text(encoding='utf-8'))
expected = {c['id'] for c in fixtures['cases']}
actual = {c['id'] for c in report['cases']}
if expected != actual or len(actual) != len(report['cases']):
    errors.append('Historical case inventory mismatch/duplicates')
for case in expected:
    for suffix in ('.png', '.json'):
        if not (title_archive / 'cases' / (case + suffix)).exists():
            errors.append('Missing post-title case: ' + case + suffix)
    for folder, suffixes in [('reference', ('.png', '.json')), ('dac', ('.png', '.json', '-overlay.png', '-diff.png', '-window.png'))]:
        for suffix in suffixes:
            if not (ARCHIVE / folder / (case + suffix)).exists():
                errors.append(f'Missing case evidence {folder}/{case}{suffix}')
catalog = subprocess.run([sys.executable, str(DOCS / 'tools/build_catalog.py'), '--check'], capture_output=True, text=True)
if catalog.returncode:
    errors.append(catalog.stdout + catalog.stderr)
if errors:
    print('\n'.join(errors))
    raise SystemExit(1)
print(json.dumps({'localLinks': links, 'jsonFiles': json_count, 'artifactMappings': len(manifest['artifacts']),
                  'typedArtifactMappings': len(typed_manifest['artifacts']),
                  'titleArtifactMappings': len(title_manifest['artifacts']),
                  'titleMatrixImages': len(expected_titles),
                  'sequenceFrames': frame_count, 'cases': len(expected), 'catalogs': 'current',
                  'rendererExecuted': False, 'historicalAcceptance': 'unchanged'}, indent=2))
