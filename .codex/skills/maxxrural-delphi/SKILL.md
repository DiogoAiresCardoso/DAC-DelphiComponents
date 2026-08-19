---
name: maxxrural-delphi
description: Work in the MaxxRural Delphi workspace. Use when Codex needs to inspect, modify, explain, or validate Delphi/Pascal code in this modular VCL/FMX/Windows Service system, especially MaxxRural modules, FireDAC/Firebird data access, REST/Horse API code, DataSnap-related configuration, project groups, .pas/.dfm/.dpr/.dproj files, reports, or shared MaxxSoft business patterns.
---

# MaxxRural Delphi

## First Pass

Start by reading the files that own the requested behavior. This repository is large and has legacy modules, generated/vendor code, reports, and multiple project groups, so do not infer ownership from a filename alone.

Use these references only as needed:

- For repository layout and project groups, read `references/project-map.md`.
- For the API service, Horse routes, auth, entities, and generic DAO patterns, read `references/api-rest-horse.md`.
- For desktop modules, shared packages, and REST client consumption, read `references/desktop-modules.md`.
- For DataSnap-related configuration and how to verify actual DataSnap code in this checkout, read `references/datasnap-config.md`.
- For `Ancoragem` / `NovoMaxxRural` Skia shell, reusable components, card/chart separation, hover/focus routing, and chart palette, read `references/novomaxxrural-skia.md`.
- For durable NovoMaxxRural Skia decisions and continuity notes, also read `../../memory/novomaxxrural-skia.md` when present.

Prefer `rg` searches scoped to the relevant area before editing. Exclude vendor folders when the task is about product code:

```powershell
rg -n "Termo|Classe|Endpoint" MaxxRural -g "*.pas" -g "*.dfm" -g "!**/modules/**"
```

## Workflow

1. Identify the target surface: API service, desktop module, shared library, configuration, report, updater, login, or legacy service.
2. Read the project file (`.dpr`/`.dproj`/`.groupproj`) plus the owning unit before changing code.
3. Follow existing Portuguese naming and Delphi idioms in the touched area. Preserve uppercase table/field names and current class prefixes.
4. Keep changes narrow. This codebase mixes older VCL patterns with newer generic/RTTI layers, so avoid broad modernization unless the user asks.
5. Validate with the smallest practical check: targeted search, Delphi project build if available, or static inspection of affected units and project includes.

## Editing Rules

- Delphi source/form project text in this workspace uses Windows-1252/ANSI encoding. When reading or rewriting `.pas`, `.dfm`, `.fmx`, `.dpr`, `.inc`, and similar Delphi text files with PowerShell/.NET, use `-Encoding Default` or `[System.Text.Encoding]::GetEncoding(1252)` and preserve that encoding. Do not rewrite Delphi sources as UTF-8 unless the file already explicitly uses UTF-8.
- Do not touch generated/vendor libraries under `MaxxRural\MaxxRuralApi\modules` unless the user explicitly asks.
- Do not rewrite `.dfm`, `.fmx`, `.fr3`, `.res`, `.skincfg`, or binary/document assets unless the task is specifically about those files.
- Do not create nested classes or multiple concrete classes in the same Delphi unit. Each concrete class must have its own specific `.pas` file. The exception is interface declarations: related interfaces may be declared together in one interface unit when that matches the local architecture.
- When adding a Delphi unit, update the owning `.dpr`/`.dproj`/package references if the local pattern requires explicit inclusion.
- When adding an API CRUD endpoint, normally add or update the entity, controller, route registration, and project uses list together.
- When changing connection or auth behavior, inspect both server-side config/auth and desktop REST client code because token and endpoint assumptions are shared.

## Common Searches

```powershell
rg -n "T[A-Za-z0-9_]+Controller|procedure Registry|procedure Registrar" MaxxRural\MaxxRuralApi\src -g "*.pas"
rg -n "\[Tabela|\[Campo|\bPk\b|AutoInc|Alias" MaxxRural\MaxxRuralApi\src\Model\Entity -g "*.pas"
rg -n "DATASNAP|HostDataSnap|PortaDataSnap|TDSServer|TDSHTTP|ServerMethods" -g "*.pas" -g "*.dfm" -g "*.dpr"
rg --files -g "*.dpr" -g "*.dproj" -g "*.groupproj" -g "!**/modules/**"
```
