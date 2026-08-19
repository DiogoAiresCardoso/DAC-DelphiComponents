#!/usr/bin/env python3
"""Validação estrutural da skill Codex."""

from __future__ import annotations

import re
import subprocess
import sys
from pathlib import Path


def main() -> int:
    root = Path(__file__).resolve().parent.parent
    errors: list[str] = []
    skill = root / "SKILL.md"
    text = skill.read_text(encoding="utf-8") if skill.is_file() else ""
    if not text:
        errors.append("SKILL.md ausente")
    frontmatter = re.match(r"\A---\s*\n(.*?)\n---\s*\n", text, re.S)
    if not frontmatter:
        errors.append("front matter inválido")
    else:
        yaml = frontmatter.group(1)
        name = re.search(r"^name:\s*(.+)$", yaml, re.M)
        description = re.search(r"^description:\s*(.+)$", yaml, re.M)
        if not name or not re.fullmatch(r"[a-z0-9-]+", name.group(1).strip()):
            errors.append("name inválido")
        if not description or len(description.group(1).strip()) < 60:
            errors.append("description curta ou ausente")

    required = [
        "README.md", "agents/openai.yaml", "assets/icon.svg",
        "assets/reference/maxxrural-design-system.png",
        "assets/reference/maxxrural-dashboard.png",
        "references/01-architecture.md", "references/02-design-system.md",
        "references/03-component-contracts.md", "references/04-stylehook-recipes.md",
        "references/05-gallery-layout.md", "references/06-skia-integration.md",
        "references/07-testing-and-acceptance.md", "references/08-delivery-checklist.md",
        "references/09-implementation-map.md", "scripts/audit.py",
        "scripts/scaffold.py", "scripts/verify_starter.py",
        "assets/starter/Source/Packages/MaxUI.Runtime.dpk",
        "assets/starter/Demo/MaxUI.Demo.Main.pas",
        "assets/starter/Tests/MaxUI.Smoke.dpr",
    ]
    for rel in required:
        if not (root / rel).exists():
            errors.append(f"arquivo obrigatório ausente: {rel}")

    for rel in re.findall(r"`((?:references|assets|scripts)/[^`\s]+)`", text):
        clean = rel.rstrip(".,;:")
        if not (root / clean).exists():
            errors.append(f"caminho citado inexistente: {clean}")

    if "15 famílias" not in text and "15 famílias" not in (root / "README.md").read_text(encoding="utf-8"):
        errors.append("escopo de 15 famílias não documentado")

    if errors:
        print("Skill inválida:")
        for error in errors:
            print(f"- {error}")
        return 1

    verify = subprocess.run([sys.executable, str(root / "scripts/verify_starter.py")], check=False)
    if verify.returncode != 0:
        return verify.returncode
    print("Skill estruturalmente válida.")
    print(f"Arquivos: {sum(1 for p in root.rglob('*') if p.is_file())}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
