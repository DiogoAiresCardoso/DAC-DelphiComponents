"""Documentation inventory only: no Pascal compilation or claim of visual support.

Run from any directory with Python 3: build_catalog.py [--check]. Standard library
only. Extraction intentionally targets this repository's current declaration style.
"""
import argparse
import hashlib
import json
import re
import struct
from collections import defaultdict
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
OUT = ROOT / 'docs/charts/manual'
OPTIONS = 'Source/Controls/DAC.Components.Charts.Options.pas'
TYPES = 'Source/Core/DAC.Components.Charts.Types.pas'
HOST = 'Source/Controls/DAC.Components.Controls.Charts.pas'
FIXTURES = 'Tests/Charts.Visual/fixtures.json'


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def source(path):
    return path.read_text(encoding='cp1252')


def line_of(text, position):
    return text.count('\n', 0, position) + 1


def json_text(value):
    return json.dumps(value, ensure_ascii=False, indent=2) + '\n'


def pascal_calls(text, name):
    """Balanced arguments, including calls in an if/else chain without semicolons."""
    for match in re.finditer(r'(?<!procedure )\b' + name + r'\(', text):
        start = index = match.end()
        depth = 1
        quoted = False
        while index < len(text):
            char = text[index]
            if char == "'":
                if quoted and index + 1 < len(text) and text[index + 1] == "'":
                    index += 2
                    continue
                quoted = not quoted
            elif not quoted:
                depth += (char == '(') - (char == ')')
                if depth == 0:
                    yield match.start(), text[start:index]
                    break
            index += 1


def font_names(path):
    """Read SFNT name table; metadata does not prove installed/resolved GDI face."""
    raw = path.read_bytes()
    count = struct.unpack_from('>H', raw, 4)[0]
    for index in range(count):
        tag, _, offset, _ = struct.unpack_from('>4sIII', raw, 12 + index * 16)
        if tag != b'name':
            continue
        _, records, strings = struct.unpack_from('>HHH', raw, offset)
        names = defaultdict(set)
        for n in range(records):
            platform, encoding, language, name_id, length, location = struct.unpack_from(
                '>HHHHHH', raw, offset + 6 + 12 * n)
            if name_id not in (1, 2, 4, 5, 6):
                continue
            value = raw[offset + strings + location:offset + strings + location + length]
            codec = 'utf-16-be' if platform in (0, 3) else 'mac_roman'
            names[str(name_id)].add(value.decode(codec, errors='replace'))
        return {key: sorted(values) for key, values in sorted(names.items())}
    return {}


def classes(text, file):
    result = []
    for match in re.finditer(r'^  (\w+)\s*=\s*class(?:\(([^)]+)\))?\s*\n(.*?)^  end;', text, re.M | re.S):
        visibility = 'public'
        props = []
        body = match.group(3)
        position = match.start(3)
        for row in body.splitlines(keepends=True):
            stripped = row.strip()
            if stripped in ('published', 'public', 'private', 'protected', 'strict private', 'strict protected'):
                visibility = stripped
            if stripped.startswith('property '):
                name = re.match(r'property (\w+)', stripped).group(1)
                props.append({'name': name, 'visibility': visibility, 'declaration': stripped,
                              'line': line_of(text, position)})
            position += len(row)
        result.append({'name': match.group(1), 'ancestor': match.group(2), 'file': file,
                       'line': line_of(text, match.start()), 'properties': props})
    return result


def leaves(value, prefix=''):
    if isinstance(value, dict):
        if not value and prefix:
            yield prefix, value
        for key, child in value.items():
            yield from leaves(child, f'{prefix}.{key}' if prefix else key)
    elif isinstance(value, list):
        if not value:
            yield prefix, value
        # Data arrays are values; series arrays are structural.
        elif prefix == 'series':
            for child in value:
                yield from leaves(child, 'series[]')
        else:
            yield prefix, value
    else:
        yield prefix, value


def generate():
    options = source(ROOT / OPTIONS)
    types = source(ROOT / TYPES)
    host = source(ROOT / HOST)
    declarations = classes(types, TYPES) + classes(options, OPTIONS) + classes(host, HOST)
    by_class = {c['name']: c for c in declarations}
    getters = {}
    for match in re.finditer(r'^function (\w+\.(?:Get\w+))\b.*?(?=^(?:function|procedure|constructor|destructor) |\Z)', options, re.M | re.S):
        getters[match.group(1)] = {'line': line_of(options, match.start()), 'source': match.group(0).strip()}
    whitelists = []
    for position, call in pascal_calls(types, 'Keys'):
        allowed = re.search(r"('(?:[^']|'')*'(?:\s*\+\s*'(?:[^']|'')*')*)\s*$", call)
        if not allowed:
            raise ValueError('Unrecognized Keys call')
        literals = re.findall(r"'((?:[^']|'')*)'", allowed.group(1))
        whitelists.append({'file': TYPES, 'line': line_of(types, position),
                          'contextExpression': call[:allowed.start()].rstrip(' ,\n'),
                          'keys': ''.join(literals).split('|')})
    assert len(whitelists) >= 20, 'Review extraction after validator structure changes'
    fixture = json.loads((ROOT / FIXTURES).read_text(encoding='utf-8-sig'))
    coverage = defaultdict(set)
    values = defaultdict(set)
    for case in fixture['cases']:
        for path, value in leaves(case['option']):
            coverage[path].add(case['id'])
            # Do not embed complete data arrays repeatedly in the coverage index.
            values[path].add(json.dumps(value, ensure_ascii=False, separators=(',', ':')))
    inventory = {'schema': 1, 'scope': 'static declarations and whitelist; not proof of rendered support',
                 'source': OPTIONS, 'sourceSha256': digest(ROOT / OPTIONS),
                 'validationSource': TYPES, 'validationSourceSha256': digest(ROOT / TYPES),
                 'classes': declarations, 'getters': getters, 'whitelists': whitelists,
                 'fixtureSha256': digest(ROOT / FIXTURES),
                 'explicitFixtureCoverage': {p: {'cases': sorted(coverage[p]), 'distinctExplicitValues': len(values[p])}
                                             for p in sorted(coverage)}}
    api = ['# Catálogo extraído da API', '', '[Índice](../README.md) · [Semântica e limites](03-configuracao-dados.md)', '',
           'Gerado por `../tools/build_catalog.py`. Declarações estáticas, sem RTTI, compilação ou prova de efeito visual.',
           'Propriedades herdadas republicadas são resolvidas apenas entre as classes locais extraídas.', '',
           '## Propriedades published', '']
    for cls in declarations:
        published = [p for p in cls['properties'] if p['visibility'] == 'published']
        if not published:
            continue
        api += [f"### {cls['name']}", '', f"Fonte: [{cls['file']}](../../../{cls['file']}), linha {cls['line']}.", '',
                '| Propriedade | Declaração / origem | Getter |', '| --- | --- | --- |']
        for prop in published:
            resolved = prop
            owner = cls
            while ':' not in resolved['declaration'] and owner.get('ancestor') in by_class:
                owner = by_class[owner['ancestor']]
                resolved = next((p for p in owner['properties'] if p['name'] == prop['name']), resolved)
            getter = re.search(r'\bread\s+(\w+)', resolved['declaration'])
            name = owner['name'] + '.' + getter.group(1) if getter else 'herdado VCL / não extraído'
            declaration = resolved['declaration'].replace('|', '&#124;')
            api.append(f"| `{prop['name']}` | `{declaration}` | `{name}` |")
        api.append('')
    api += ['## Corpos dos getters de opções', '',
            'Os fallbacks abaixo pertencem aos getters. Defaults contextuais do renderer podem divergir; ver capítulo 03.', '']
    for name, info in getters.items():
        api += [f'### {name}', '', f"Linha {info['line']} de Options.pas.", '', '```pascal', info['source'], '```', '']
    scenarios = ['# Catálogo de cenários e cobertura explícita', '', '[Índice](../README.md) · [Interpretação dos testes](08-testes-evidencias.md)', '',
                 f"Fonte executável: [{FIXTURES}](../../../{FIXTURES}); SHA-256 `{digest(ROOT / FIXTURES)}`.", '',
                 'Presença de uma chave na fixture não prova assert específico, alternativas suficientes ou efeito visual.',
                 'Ausência de uma chave pode exercitar default implicitamente, mas não prova que esse default foi comparado.', '',
                 '| ID | Título | Fase | Famílias |', '| --- | --- | --- | --- |']
    for case in fixture['cases']:
        kinds = ', '.join(sorted({s.get('type', 'bar (implícito)') for s in case['option'].get('series', [])}))
        scenarios.append(f"| {case['id']} | {case['title'].replace('|', '&#124;')} | {case.get('phase','')} | {kinds} |")
    scenarios += ['', '## Caminhos explicitamente presentes', '', '| Caminho | Casos | Valores distintos explícitos |', '| --- | --- | --- |']
    for path in sorted(coverage):
        scenarios.append(f"| `{path}` | {', '.join(sorted(coverage[path]))} | {len(values[path])} |")
    scenarios += ['', '## Conteúdo integral por cenário', '', 'Dados e opções canônicos permanecem nas fixtures; expectativas abaixo são metadados de teste, não API.', '']
    for case in fixture['cases']:
        scenarios += [f"### {case['id']} — {case['title']}", '', '```json', json.dumps(case, ensure_ascii=False, indent=2), '```', '']
    files = {ROOT / TYPES, ROOT / OPTIONS, ROOT / HOST, ROOT / FIXTURES}
    for pattern in ('Source/Skia/DAC.Components.Charts.*.pas', 'Tests/DACComponentsCharts*',
                    'Tests/Charts.Visual/*.py', 'Tests/Charts.Visual/*.cjs', 'Tests/Charts.Visual/*.ps1',
                    'Tests/Charts.Visual/package.json', 'demo-charts/*.pas', 'demo-charts/*.dfm',
                    'demo-charts/*.dpr', 'demo-charts/*.dproj', 'Package/DACSkiaComponents*.dpk'):
        files.update(p for p in ROOT.glob(pattern) if p.is_file() and p.suffix != '.res')
    sources = []
    for path in sorted(files):
        item = {'path': path.relative_to(ROOT).as_posix(), 'bytes': path.stat().st_size, 'sha256': digest(path)}
        if path.suffix.lower() == '.pas':
            txt = source(path)
            item['symbols'] = [{'name': m.group(2), 'kind': m.group(1), 'line': line_of(txt, m.start())}
                               for m in re.finditer(r'^(function|procedure|constructor|destructor)\s+(\w+(?:\.\w+)?)', txt, re.M)]
        sources.append(item)
    font_files = [ROOT / 'assets/fonts/Inter.ttf', ROOT / 'DAC/Fonts/DAC-Components-Inter.ttf']
    font_files += sorted(Path('C:/Windows/Fonts').glob('arial*.ttf'))
    fonts = []
    for path in font_files:
        if path.exists():
            fonts.append({'path': path.relative_to(ROOT).as_posix() if path.is_relative_to(ROOT) else path.as_posix(),
                          'bytes': path.stat().st_size, 'sha256': digest(path), 'sfntNameRecords': font_names(path)})
    fonts_catalog = {'schema': 1, 'scope': 'local source and font file inventory; not proof of per-glyph GDI resolution',
                     'sfntNameIds': {'1': 'family', '2': 'subfamily', '4': 'full name', '5': 'version', '6': 'PostScript name'},
                     'sources': sources, 'fontFiles': fonts}
    return {'catalogo-api.md': '\n'.join(api), 'catalogo-cenarios.md': '\n'.join(scenarios),
            'catalogo-opcoes.json': json_text(inventory), 'catalogo-fontes.json': json_text(fonts_catalog)}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--check', action='store_true', help='Compare generated output without writing')
    args = parser.parse_args()
    mismatches = []
    for name, content in generate().items():
        path = OUT / name
        if args.check:
            if not path.exists() or path.read_text(encoding='utf-8') != content:
                mismatches.append(name)
        else:
            OUT.mkdir(parents=True, exist_ok=True)
            path.write_text(content, encoding='utf-8', newline='\n')
    if mismatches:
        raise SystemExit('Catalogs stale: ' + ', '.join(mismatches))
    print('Catalogs verified' if args.check else 'Four documentation catalogs generated')


if __name__ == '__main__':
    main()
