#!/usr/bin/env python3
from __future__ import annotations
import argparse
from pathlib import Path
import re

parser = argparse.ArgumentParser(description='Recolore os SVGs MaxUI preservando 120x120.')
parser.add_argument('--source', required=True, type=Path)
parser.add_argument('--target', required=True, type=Path)
parser.add_argument('--color', required=True, help='Cor hexadecimal, por exemplo #FFFFFF')
args = parser.parse_args()

color = args.color.strip()
if not re.fullmatch(r'#[0-9A-Fa-f]{6}', color):
    raise SystemExit('Use uma cor no formato #RRGGBB.')

for src in args.source.rglob('*.svg'):
    rel = src.relative_to(args.source)
    dst = args.target / rel
    dst.parent.mkdir(parents=True, exist_ok=True)
    text = src.read_text(encoding='utf-8')
    text = re.sub(r'style="color:#[0-9A-Fa-f]{6}"', f'style="color:{color}"', text, count=1)
    text = text.replace('currentColor', color)
    dst.write_text(text, encoding='utf-8')

print(f'Arquivos gerados em {args.target}')
