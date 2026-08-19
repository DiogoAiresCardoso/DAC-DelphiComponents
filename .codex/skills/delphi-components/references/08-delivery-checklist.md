# Checklist de entrega

## Estrutura

- [ ] Core/Controls/Hooks/DesignTime/Demo separados
- [ ] packages runtime/design-time ajustados ao Delphi alvo
- [ ] nenhum `DesignIntf` no runtime
- [ ] nenhuma dependência FMX

## Escopo

- [ ] 15 famílias implementadas
- [ ] nenhuma classe de árvore/menu lateral
- [ ] nenhuma barra de ferramentas/topbar reutilizável
- [ ] galeria sem lacunas dessas famílias

## Visual

- [ ] design system Ancoragem aplicado por tokens
- [ ] tokens centralizados
- [ ] foco visível
- [ ] warning/danger/success sem depender só de cor
- [ ] DPI aplicado
- [ ] sem flicker perceptível

## Hooks

- [ ] apenas classes `TMax...`
- [ ] register/unregister pareados
- [ ] registro idempotente
- [ ] comportamento nativo preservado

## Recursos

- [ ] image lists/menus/data sources com `FreeNotification`
- [ ] timers liberados
- [ ] nenhum leak GDI detectável
- [ ] Skia4Delphi obrigatório integrado
- [ ] nenhum fallback GDI para desenho visual novo
- [ ] renderer/container/tema seguem a arquitetura Ancoragem

## Verificação

- [ ] `validate_skill.py`
- [ ] `verify_starter.py`
- [ ] `audit.py --strict`
- [ ] build Win32
- [ ] build Win64 quando suportado
- [ ] smoke test
- [ ] resultado real relatado
