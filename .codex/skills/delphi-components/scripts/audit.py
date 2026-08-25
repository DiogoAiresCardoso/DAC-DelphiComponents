#!/usr/bin/env python3
"""Auditoria estática de um repositório Delphi para as regras MaxUI."""

from __future__ import annotations

import argparse
import json
import re
from dataclasses import asdict, dataclass
from pathlib import Path

SOURCE_SUFFIXES = {".pas", ".dpr", ".dpk", ".dfm", ".inc"}
GLOBAL_VCL_CLASSES = {
    "TButton", "TCustomButton", "TEdit", "TCustomEdit", "TMemo",
    "TComboBox", "TCustomComboBox", "TCheckBox", "TRadioButton",
    "TDateTimePicker", "TPageControl", "TStringGrid", "TDBGrid",
}

FAMILIES: dict[int, tuple[str, ...]] = {
    1: ("TMaxButton", "TMaxIconButton", "TMaxSplitButton"),
    2: ("TMaxEdit", "TMaxSearchEdit", "TMaxPasswordEdit", "TMaxMaskedEdit", "TMaxMemo"),
    3: ("TMaxComboBox", "TMaxDatePicker", "TMaxTimePicker", "TMaxSpinField"),
    4: ("TMaxCheckBox", "TMaxRadioButton", "TMaxToggleSwitch", "TMaxSlider"),
    5: ("TMaxPageControl",),
    6: ("TMaxSummaryCard",),
    7: ("TMaxStringGrid", "TMaxDBGrid"),
    8: ("TMaxStatusBar",),
    9: ("TMaxLinearProgress", "TMaxCircularProgress"),
    10: ("TMaxBadge", "TMaxChip", "TMaxTag", "TMaxPill"),
    11: ("TMaxToast", "TMaxTooltip", "TMaxModalPanel"),
    12: ("TMaxPagination",),
    13: ("TMaxSpinner",),
    14: ("TMaxChart",),
    15: ("TMaxReportViewer",),
}

FORBIDDEN_SUITE_CLASSES = {"TMaxTreeView", "TMaxToolBar", "TMaxToolbar", "TMaxTopBar"}


@dataclass
class HookCall:
    file: str
    line: int
    control_class: str
    hook_class: str


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Audita uma suíte Delphi VCL/StyleHook.")
    parser.add_argument("--root", default=".")
    parser.add_argument("--output")
    parser.add_argument("--strict", action="store_true")
    return parser.parse_args()


def line_number(text: str, offset: int) -> int:
    return text.count("\n", 0, offset) + 1


def main() -> int:
    args = parse_args()
    root = Path(args.root).resolve()
    files = [p for p in root.rglob("*") if p.is_file() and p.suffix.lower() in SOURCE_SUFFIXES]
    texts: dict[Path, str] = {}
    risks: list[dict[str, object]] = []
    registers: list[HookCall] = []
    unregisters: list[HookCall] = []
    combined = ""

    hook_pattern = re.compile(
        r"TCustomStyleEngine\.(RegisterStyleHook|UnRegisterStyleHook)\s*\(\s*([A-Za-z_][\w.]*)\s*,\s*([A-Za-z_][\w.]*)\s*\)",
        re.IGNORECASE,
    )

    for path in files:
        try:
            text = path.read_text(encoding="utf-8", errors="replace")
        except OSError:
            continue
        texts[path] = text
        combined += "\n" + text
        rel = str(path.relative_to(root))

        if re.search(r"\bFMX\.", text):
            risks.append({"severity": "error", "file": rel, "message": "dependência FMX encontrada em código auditado"})
        if re.search(r"\bDesignIntf\b|\bDesignEditors\b", text) and "Design" not in rel:
            risks.append({"severity": "warning", "file": rel, "message": "dependência design-time fora de pasta/unit de design"})
        for forbidden in FORBIDDEN_SUITE_CLASSES:
            if re.search(rf"\b{re.escape(forbidden)}\b", text):
                risks.append({"severity": "error", "file": rel, "message": f"classe fora do escopo encontrada: {forbidden}"})
        if "TODO" in text.upper():
            risks.append({"severity": "warning", "file": rel, "message": "TODO encontrado"})

        for match in hook_pattern.finditer(text):
            call = HookCall(rel, line_number(text, match.start()), match.group(2), match.group(3))
            if match.group(1).lower().startswith("unregister"):
                unregisters.append(call)
            else:
                registers.append(call)
                simple_class = call.control_class.split(".")[-1]
                if simple_class in GLOBAL_VCL_CLASSES:
                    risks.append({
                        "severity": "error", "file": rel, "line": call.line,
                        "message": f"hook registrado globalmente em {simple_class}",
                    })

    register_pairs = {(c.control_class.lower(), c.hook_class.lower()) for c in registers}
    unregister_pairs = {(c.control_class.lower(), c.hook_class.lower()) for c in unregisters}
    for pair in sorted(register_pairs - unregister_pairs):
        risks.append({"severity": "error", "message": f"registro sem unregister correspondente: {pair[0]} → {pair[1]}"})
    for pair in sorted(unregister_pairs - register_pairs):
        risks.append({"severity": "warning", "message": f"unregister sem registro correspondente: {pair[0]} → {pair[1]}"})

    family_hits: dict[int, list[str]] = {}
    missing: list[int] = []
    for index, tokens in FAMILIES.items():
        hits = [token for token in tokens if re.search(rf"\b{re.escape(token)}\b", combined)]
        family_hits[index] = hits
        if not hits:
            missing.append(index)
            risks.append({"severity": "error", "message": f"família {index} não detectada"})

    skia_evidence = ("System.Skia" in combined) or ("Vcl.Skia" in combined) or ("TSk" in combined)
    theme_evidence = (
        ("TMaxTheme" in combined)
        or ("DesignSystem" in combined)
        or ("Tokens" in combined)
        or ("#3DB82A" in combined.upper())
        or ("#74D64A" in combined.upper())
    )
    if not skia_evidence:
        risks.append({"severity": "warning", "message": "não foi encontrada evidência simples de Skia4Delphi obrigatório"})
    if not theme_evidence:
        risks.append({"severity": "warning", "message": "não foi encontrada evidência simples de tema/tokens Ancoragem"})

    report = {
        "root": str(root),
        "summary": {
            "files_scanned": len(files),
            "register_count": len(registers),
            "unregister_count": len(unregisters),
            "families_detected": 15 - len(missing),
            "families_missing": missing,
            "risk_count": len(risks),
        },
        "registers": [asdict(x) for x in registers],
        "unregisters": [asdict(x) for x in unregisters],
        "family_hits": {str(k): v for k, v in family_hits.items()},
        "risks": risks,
    }

    if args.output:
        output = Path(args.output)
        if not output.is_absolute():
            output = root / output
        output.parent.mkdir(parents=True, exist_ok=True)
        output.write_text(json.dumps(report, ensure_ascii=False, indent=2) + "\n", encoding="utf-8")
        print(f"Relatório JSON: {output}")

    print(f"Arquivos analisados: {len(files)}")
    print(f"Hooks register/unregister: {len(registers)}/{len(unregisters)}")
    print(f"Famílias detectadas: {15 - len(missing)}/15")
    print(f"Riscos: {len(risks)}")
    for risk in risks:
        location = str(risk.get("file", ""))
        if risk.get("line"):
            location += f":{risk['line']}"
        print(f"[{risk.get('severity', 'info')}] {location} {risk['message']}".strip())

    has_errors = any(r.get("severity") == "error" for r in risks)
    return 2 if args.strict and has_errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
