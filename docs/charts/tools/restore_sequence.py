"""Restore archived PNG names from a deduplicated evidence sequence; never rerenders."""
import argparse
import hashlib
import json
import shutil
from pathlib import Path

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('sequence', type=Path)
parser.add_argument('output', type=Path)
args = parser.parse_args()
sequence = args.sequence.resolve()
archive = sequence.parents[1]
index = json.loads((sequence / 'index.json').read_text(encoding='utf-8'))
if args.output.exists():
    raise SystemExit('Output already exists; choose a new directory.')
validated = []
for frame in index['frames']:
    source = (sequence / frame['blob']).resolve()
    if not source.is_relative_to(archive):
        raise SystemExit('Blob outside evidence directory')
    name = frame['originalName']
    if Path(name).name != name or Path(name).suffix.lower() != '.png':
        raise SystemExit('Invalid frame filename')
    if hashlib.sha256(source.read_bytes()).hexdigest() != frame['sha256']:
        raise SystemExit('Hash mismatch: ' + name)
    validated.append((source, name))
args.output.mkdir(parents=True, exist_ok=False)
for source, name in validated:
    shutil.copyfile(source, args.output / name)
shutil.copyfile(sequence / 'frames.jsonl', args.output / 'frames.jsonl')
print(f'{len(validated)} PNGs restored; temporal acceptance unchanged.')
