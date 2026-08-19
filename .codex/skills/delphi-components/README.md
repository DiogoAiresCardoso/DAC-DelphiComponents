# Delphi VCL StyleHook Design System — Codex Skill v2

Skill para implementar uma suíte VCL com 15 famílias de componentes, `TStyleHook` localizado, desenho sempre via Skia4Delphi e design system alinhado ao NovoMaxxRural/Ancoragem.

Nesta revisão, as famílias de TreeView/menu lateral e Toolbar/topbar foram removidas integralmente. O starter foi ampliado: ele contém código de referência para todas as famílias restantes, packages, demo e smoke test; não é mais apenas uma fundação de botão.

## Instalação no repositório

Copie a pasta para:

```text
<repo>/.agents/skills/delphi-vcl-stylehook-design-system/
```

## Invocação

```text
$delphi-vcl-stylehook-design-system
Implemente a suíte completa neste projeto, mantendo hooks localizados e sem TreeView ou Toolbar.
Use Skia4Delphi para todo desenho visual e siga os tokens já aplicados na Ancoragem.
```

## Validação

```bash
python scripts/validate_skill.py
python scripts/verify_starter.py
python scripts/audit.py --root <repo> --strict
```

## Scaffold

```bash
python scripts/scaffold.py --target <repo> --prefix MaxUI --with-demo --with-tests
```

Os arquivos `.dpk` são modelos: ajuste `requires`, sufixos e plataformas ao RAD Studio detectado antes de compilar.
