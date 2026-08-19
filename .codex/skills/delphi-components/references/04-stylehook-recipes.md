# Receitas de StyleHook

## Registro localizado

```pascal
TCustomStyleEngine.RegisterStyleHook(TMaxButton, TMaxButtonStyleHook);
TCustomStyleEngine.UnRegisterStyleHook(TMaxButton, TMaxButtonStyleHook);
```

Nunca use a classe VCL global no primeiro argumento.

## Registro idempotente

```pascal
var
  GRegistered: Boolean;

procedure RegisterMaxUIHooks;
begin
  if GRegistered then
    Exit;
  { pares de registro }
  GRegistered := True;
end;
```

## Estado visual

```pascal
function ResolveState(AEnabled, APressed, AHot, AFocused: Boolean): TMaxVisualState;
begin
  if not AEnabled then Exit(mvsDisabled);
  if APressed then Exit(mvsPressed);
  if AHot then Exit(mvsHot);
  if AFocused then Exit(mvsFocused);
  Result := mvsNormal;
end;
```

## Botão

Herde de `TButtonStyleHook` quando disponível. Defina `OverridePaint := True`, acompanhe mouse/capture/foco em `WndProc` e delegue a `TMaxPainter.DrawButton`. Não suprima mensagens que geram `Click` ou ações de teclado.

## Edit

O editor nativo deve pintar texto/caret. Use o hook para borda/foco e margens, preferencialmente em non-client ou com um container. Não redesenhe texto manualmente durante edição. `TMaxEdit` reserva espaço para ícones via `EM_SETMARGINS`.

## Combo

Use `TComboBoxStyleHook` se compatível com a versão alvo. Preserve a lista drop-down e apenas ajuste superfície, borda, botão de seta e foco. Se a assinatura variar, use owner draw para itens e um frame composto externo.

## CheckBox e Radio

Um hook próprio pode pintar todo o client porque o controle continua recebendo foco, teclado e `Checked`. Acompanhe `CM_MOUSEENTER/CM_MOUSELEAVE`, `CM_ENABLEDCHANGED`, `WM_SETFOCUS`, `WM_KILLFOCUS` e invalide apenas quando estado muda.

## Paint vs PaintNC

- `Paint`: conteúdo cliente inteiro;
- `PaintNC`: borda e área não cliente;
- `OverridePaint`: somente quando o hook substitui o cliente;
- `OverridePaintNC`: somente quando substitui a borda.

Não ative os dois sem necessidade.

## VCL Styles desativado

Dependendo da versão/configuração, hooks podem não ser chamados sob o estilo de sistema. A suíte deve ter fallback: controles customizados pintam diretamente; classes nativas mantêm `StyleElements`/cores e podem usar mensagens de borda. Documente o comportamento observado no toolchain real.

## Flicker

- `DoubleBuffered := True` em containers e controles customizados;
- `ControlStyle + [csOpaque]` quando o controle cobre todo o client;
- `WM_ERASEBKGND` retorna 1 somente quando `Paint` cobre tudo;
- evite invalidar o parent inteiro no hover;
- não crie fontes/pens/brushes por frame quando podem ser reutilizados pelo `TCanvas`.

## DPI

O hook usa `Control.CurrentPPI` e passa PPI ao painter. Não misture pixels físicos e lógicos.
