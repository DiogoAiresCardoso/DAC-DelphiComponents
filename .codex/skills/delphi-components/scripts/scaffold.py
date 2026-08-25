#!/usr/bin/env python3
"""Copia o starter completo da skill para um repositório Delphi."""

from __future__ import annotations

import argparse
import re
import shutil
import sys
from pathlib import Path

TEXT_SUFFIXES = {".pas", ".dpr", ".dpk", ".inc", ".md", ".txt", ".dfm", ".json", ".xml"}


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Cria a suíte VCL de 15 famílias em um repositório.")
    parser.add_argument("--target", default=".", help="Diretório de destino")
    parser.add_argument("--prefix", default="MaxUI", help="Prefixo de units/packages, ex.: MaxUI ou RuralUI")
    parser.add_argument("--project-name", help="Nome do demo; default: <prefix>Demo")
    parser.add_argument("--with-demo", action="store_true", help="Inclui Demo")
    parser.add_argument("--with-tests", action="store_true", help="Inclui Tests")
    parser.add_argument("--without-design-time", action="store_true", help="Não copia DesignTime/package de design")
    parser.add_argument("--force", action="store_true", help="Sobrescreve arquivos existentes")
    parser.add_argument("--dry-run", action="store_true", help="Lista operações")
    return parser.parse_args()


def identifier(value: str, label: str) -> str:
    if not re.fullmatch(r"[A-Za-z][A-Za-z0-9_]*", value):
        raise ValueError(f"{label} deve ser um identificador Pascal simples: {value!r}")
    return value


def transformed_relative(rel: Path, prefix: str, project_name: str) -> Path:
    if rel == Path("README.md"):
        return Path("docs") / f"{prefix}-STARTER.md"
    parts: list[str] = []
    for part in rel.parts:
        part = part.replace("MaxUIDemo", project_name)
        part = part.replace("MaxUI", prefix)
        parts.append(part)
    return Path(*parts)


def main() -> int:
    args = parse_args()
    try:
        prefix = identifier(args.prefix, "--prefix")
        project_name = identifier(args.project_name or f"{prefix}Demo", "--project-name")
    except ValueError as exc:
        print(f"erro: {exc}", file=sys.stderr)
        return 1

    skill_root = Path(__file__).resolve().parent.parent
    starter = skill_root / "assets" / "starter"
    target = Path(args.target).resolve()
    if not starter.is_dir():
        print(f"erro: starter ausente: {starter}", file=sys.stderr)
        return 1

    operations: list[tuple[Path, Path]] = []
    for source in sorted(starter.rglob("*")):
        if not source.is_file():
            continue
        rel = source.relative_to(starter)
        if rel.parts and rel.parts[0] == "Demo" and not args.with_demo:
            continue
        if rel.parts and rel.parts[0] == "Tests" and not args.with_tests:
            continue
        if args.without_design_time:
            if rel.parts[:2] == ("Source", "DesignTime"):
                continue
            if rel.name == "MaxUI.Design.dpk":
                continue
        destination = target / transformed_relative(rel, prefix, project_name)
        operations.append((source, destination))

    conflicts = [dest for _, dest in operations if dest.exists() and not args.force]
    if conflicts:
        print("erro: arquivos existentes; revise ou use --force:", file=sys.stderr)
        for path in conflicts[:30]:
            print(f"  {path}", file=sys.stderr)
        return 2

    for source, destination in operations:
        print(f"{'CRIARIA' if args.dry_run else 'CRIANDO'} {destination}")
        if args.dry_run:
            continue
        destination.parent.mkdir(parents=True, exist_ok=True)
        if source.suffix.lower() in TEXT_SUFFIXES:
            text = source.read_text(encoding="utf-8")
            text = text.replace("MaxUIDemo", project_name)
            text = text.replace("MaxUI", prefix)
            destination.write_text(text, encoding="utf-8", newline="\n")
        else:
            shutil.copy2(source, destination)

    print(f"{len(operations)} arquivo(s) {'planejados' if args.dry_run else 'criados'} em {target}")
    if not args.dry_run:
        print("Ajuste os packages ao RAD Studio alvo e compile runtime → design-time → demo → smoke test.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
