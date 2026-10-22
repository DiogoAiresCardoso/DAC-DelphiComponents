"""Append unregistered assets/svg masters to the embedded Delphi icon catalog.

Existing enum values and embedded sources are intentionally preserved. Run from
any directory; no runtime dependency on asset files is introduced.
"""
from pathlib import Path
import json
import re
import xml.etree.ElementTree as ET

ROOT = Path(__file__).resolve().parents[1]
UNIT = ROOT / 'Source/DesignSystem/DAC.Components.DesignSystem.IconAssets.pas'
OVERRIDES = {'files/file-pdf.svg': 'mikFilesPdf', 'system/package.svg': 'mikSystemPackage'}


def pascal_name(value):
    return ''.join(part[:1].upper() + part[1:] for part in value.split('-'))


def svg_constant(name, svg):
    expressions = []
    for index, line in enumerate(svg.splitlines()):
        if index:
            expressions.append('#13#10')
        for start in range(0, len(line), 110):
            expressions.append("'" + line[start:start+110].replace("'", "''") + "'")
    return f'const C{name[3:]}Svg =\n      ' + ' +\n      '.join(expressions) + ';\n\n'


def main():
    original = UNIT.read_bytes().decode('cp1252')
    text = original.replace('\r\n', '\n')
    enum = re.search(r'TDACIconKind = \((.*?)\n  \);', text, re.S)
    names = re.findall(r'\bmik\w+\b', enum[1])
    registered = set(path.replace('\\', '/') for path in re.findall(r"Result.RelativeFileName := '([^']+)';", text))
    manifest = json.loads((ROOT / 'assets/maxui-icons-120x120-expanded/manifest.json').read_text('utf-8-sig'))
    labels = {item['file'].removeprefix('svg/'): item['label_pt'] for item in manifest}
    additions = []
    for path in sorted((ROOT / 'assets/svg').glob('*/*.svg')):
        relative = path.relative_to(ROOT / 'assets/svg').as_posix()
        if relative in registered:
            continue
        svg = path.read_text('utf-8-sig').replace('\r\n', '\n').rstrip('\n')
        element = ET.fromstring(svg)
        if element.get('viewBox') != '0 0 120 120':
            raise ValueError(f'Unexpected SVG viewport: {relative}')
        kind = OVERRIDES.get(relative, 'mik' + pascal_name(path.stem))
        if kind in names:
            kind = 'mik' + pascal_name(path.parent.name) + pascal_name(path.stem)
        if kind in names:
            raise ValueError(f'Duplicate enum: {kind}')
        names.append(kind)
        additions.append(dict(kind=kind, category=path.parent.name, name=path.stem,
                              path=relative, label=labels.get(relative, path.stem), svg=svg))
    if not additions:
        print('Icon catalog is up to date.')
        return
    text = text[:enum.start(1)] + enum[1].rstrip() + ',\n' + ',\n'.join('    '+a['kind'] for a in additions) + text[enum.end(1):]
    constants = ''.join("  DAC_ICON_" + a['category'].replace('-', '_').upper() + '_' + a['name'].replace('-', '_').upper() + " = '" + a['path'].replace('/', '\\') + "';\n" for a in additions)
    text = text.replace('\nimplementation\n', '\n'+constants+'\nimplementation\n', 1)
    raw = ''.join(svg_constant(a['kind'], a['svg']) for a in additions)
    text = text.replace('function RawSvg(const AKind:', raw+'function RawSvg(const AKind:', 1)
    start = text.index('function RawSvg(const AKind:')
    end = text.index("  else\n    Result := '';", start)
    cases = ''.join(f"    {a['kind']}: Result := C{a['kind'][3:]}Svg;\n" for a in additions)
    text = text[:end] + cases + text[end:]
    start = text.index('class function TDACIconAssets.Info(')
    end = text.index("  else\n    begin\n      Result.Category := '';", start)
    cases = ''
    for a in additions:
        esc = lambda value: value.replace("'", "''")
        cases += f"    {a['kind']}:\n      begin\n        Result.Category := '{esc(a['category'])}';\n        Result.Name := '{esc(a['name'])}';\n        Result.DisplayName := '{esc(a['label'])}';\n        Result.RelativeFileName := '{esc(a['path'].replace('/', chr(92)))}';\n      end;\n"
    text = text[:end] + cases + text[end:]
    UNIT.write_bytes(text.replace('\n', '\r\n').encode('cp1252'))
    output = ROOT / 'docs/icons'
    output.mkdir(parents=True, exist_ok=True)
    inventory = [{k: v for k, v in a.items() if k != 'svg'} for a in additions]
    (output / 'expanded-catalog.json').write_text(json.dumps(inventory, ensure_ascii=False, indent=2)+'\n', encoding='utf8')
    print(f'Added {len(additions)} icons; {len(names)-1} available plus mikNone. Existing ordinals preserved.')


if __name__ == '__main__':
    main()
