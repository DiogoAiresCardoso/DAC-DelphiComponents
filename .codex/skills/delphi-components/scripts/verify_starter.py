#!/usr/bin/env python3
"""Verifica completude estrutural do starter sem alegar compilação Delphi."""

from __future__ import annotations

import re
from pathlib import Path

EXPECTED_UNITS = [
    "Source/Core/MaxUI.Types.pas",
    "Source/Core/MaxUI.Dpi.pas",
    "Source/Core/MaxUI.Theme.pas",
    "Source/Core/MaxUI.Icons.pas",
    "Source/Core/MaxUI.Painter.pas",
    "Source/Core/MaxUI.Skia.pas",
    "Source/Controls/MaxUI.Controls.Base.pas",
    "Source/Controls/MaxUI.Controls.Buttons.pas",
    "Source/Controls/MaxUI.Controls.Inputs.pas",
    "Source/Controls/MaxUI.Controls.Selectors.pas",
    "Source/Controls/MaxUI.Controls.Choices.pas",
    "Source/Controls/MaxUI.Controls.Tabs.pas",
    "Source/Controls/MaxUI.Controls.Cards.pas",
    "Source/Controls/MaxUI.Controls.Data.pas",
    "Source/Controls/MaxUI.Controls.Feedback.pas",
    "Source/Controls/MaxUI.Controls.Charts.pas",
    "Source/Controls/MaxUI.Controls.Report.pas",
    "Source/Hooks/MaxUI.Hooks.Buttons.pas",
    "Source/Hooks/MaxUI.Hooks.Inputs.pas",
    "Source/Hooks/MaxUI.Hooks.Selectors.pas",
    "Source/Hooks/MaxUI.Hooks.Choices.pas",
    "Source/Hooks/MaxUI.Hooks.Register.pas",
    "Source/DesignTime/MaxUI.Design.Register.pas",
    "Source/Packages/MaxUI.Runtime.dpk",
    "Source/Packages/MaxUI.Design.dpk",
    "Demo/MaxUIDemo.dpr",
    "Demo/MaxUI.Demo.Main.pas",
    "Tests/MaxUI.Smoke.dpr",
]

EXPECTED_CLASSES = [
    "TMaxButton", "TMaxIconButton", "TMaxSplitButton",
    "TMaxEdit", "TMaxSearchEdit", "TMaxPasswordEdit", "TMaxMaskedEdit", "TMaxMemo",
    "TMaxComboBox", "TMaxDatePicker", "TMaxTimePicker", "TMaxSpinField",
    "TMaxCheckBox", "TMaxRadioButton", "TMaxToggleSwitch", "TMaxSlider",
    "TMaxPageControl", "TMaxSummaryCard", "TMaxStringGrid", "TMaxDBGrid", "TMaxStatusBar",
    "TMaxBadge", "TMaxChip", "TMaxTag", "TMaxPill",
    "TMaxLinearProgress", "TMaxCircularProgress", "TMaxToast", "TMaxTooltip",
    "TMaxModalPanel", "TMaxPagination", "TMaxSpinner", "TMaxChart", "TMaxReportViewer",
]

FORBIDDEN = ["TMaxTreeView", "TMaxToolBar", "TMaxToolbar", "TMaxTopBar"]


def main() -> int:
    skill_root = Path(__file__).resolve().parent.parent
    starter = skill_root / "assets" / "starter"
    errors: list[str] = []

    for rel in EXPECTED_UNITS:
        if not (starter / rel).is_file():
            errors.append(f"arquivo ausente: {rel}")

    pascal_files = [p for p in starter.rglob("*") if p.is_file() and p.suffix.lower() in {".pas", ".dpr", ".dpk"}]
    combined = "\n".join(p.read_text(encoding="utf-8", errors="replace") for p in pascal_files)

    for class_name in EXPECTED_CLASSES:
        if not re.search(rf"\b{re.escape(class_name)}\b", combined):
            errors.append(f"classe esperada ausente: {class_name}")

    for class_name in FORBIDDEN:
        if re.search(rf"\b{re.escape(class_name)}\b", combined):
            errors.append(f"classe fora do escopo encontrada: {class_name}")

    register_text = (starter / "Source/Hooks/MaxUI.Hooks.Register.pas").read_text(encoding="utf-8")
    register_pairs = re.findall(r"(?<!Un)RegisterStyleHook\s*\(\s*(T\w+)\s*,\s*(T\w+)\s*\)", register_text, re.I)
    unregister_pairs = re.findall(r"UnRegisterStyleHook\s*\(\s*(T\w+)\s*,\s*(T\w+)\s*\)", register_text, re.I)
    if set((a.lower(), b.lower()) for a, b in register_pairs) != set((a.lower(), b.lower()) for a, b in unregister_pairs):
        errors.append("pares RegisterStyleHook/UnRegisterStyleHook divergentes")
    if len(register_pairs) < 6:
        errors.append(f"poucos hooks registrados: {len(register_pairs)}")

    demo_text = (starter / "Demo/MaxUI.Demo.Main.pas").read_text(encoding="utf-8")
    indices = {int(x) for x in re.findall(r"NewSection\s*\(\s*(\d+)", demo_text)}
    if indices != set(range(1, 16)):
        errors.append(f"galeria não contém exatamente as seções 1..15: {sorted(indices)}")

    # Confere unit declaration nos .pas, sem validar sintaxe Pascal.
    for path in starter.rglob("*.pas"):
        text = path.read_text(encoding="utf-8", errors="replace")
        match = re.search(r"^unit\s+([A-Za-z_][\w.]*)\s*;", text, re.I | re.M)
        if not match:
            errors.append(f"declaração unit ausente: {path.relative_to(starter)}")
        elif match.group(1).lower() != path.stem.lower():
            errors.append(f"unit/arquivo divergente: {path.name} declara {match.group(1)}")

    if errors:
        print("Starter inválido:")
        for error in errors:
            print(f"- {error}")
        return 1

    print("Starter estruturalmente completo para 15 famílias.")
    print(f"Arquivos Pascal/package verificados: {len(pascal_files)}")
    print(f"Hooks pareados: {len(register_pairs)}")
    print("Observação: esta verificação não substitui compilação com o Delphi.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
