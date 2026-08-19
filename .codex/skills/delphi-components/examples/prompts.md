# Prompts de exemplo

## Suíte completa

```text
$delphi-vcl-stylehook-design-system
Implemente a suíte MaxUI completa neste projeto VCL usando o starter da skill. Use Skia4Delphi para todo desenho visual, mantenha hooks apenas em TMax*, aplique o design system da Ancoragem e cubra as 15 famílias do escopo. Não crie TreeView/menu lateral nem Toolbar/topbar. Compile e corrija os erros no toolchain disponível.
```

## Completar implementação parcial

```text
$delphi-vcl-stylehook-design-system
Audite a implementação atual contra references/09-implementation-map.md. Complete todas as famílias ausentes, remova stubs/TODOs e atualize a galeria de 15 seções. Preserve a API pública já usada pelo projeto.
```

## Inputs

```text
$delphi-vcl-stylehook-design-system
Implemente TMaxEdit, TMaxSearchEdit, TMaxPasswordEdit, TMaxMaskedEdit e TMaxMemo. Preserve caret, seleção, clipboard, undo/redo e IME; use StyleHook somente para a borda/estado visual.
```

## Grid

```text
$delphi-vcl-stylehook-design-system
Implemente TMaxStringGrid e TMaxDBGrid com header, zebra, hover, selected, status e ações. Não coloque regras de negócio no DrawCell e teste com dataset vazio e muitas linhas.
```

## Review

```text
$delphi-vcl-stylehook-design-system
Revise este diff: hooks localizados, register/unregister, design system Ancoragem, DPI, teclado, timers, Skia obrigatório para desenho visual e ausência das duas famílias fora do escopo. Corrija os problemas e execute as verificações possíveis.
```
