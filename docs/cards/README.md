# TDACSummaryCard: fontes por texto

`TitleFont`, `ValueFont` e `FooterFont` são propriedades `TFont` independentes,
disponíveis no Object Inspector, no DFM e em runtime. Cada uma controla `Name`,
`Size`, `Height`, `Color`, `Style`, `Charset`, `Pitch` e `Quality`. `Size` usa pontos,
como nos demais controles VCL; `Height` usa pixels da fonte nativa.

Os padrões preservam a tipografia Inter e os tamanhos do design system. Skia
desenha fundo, borda e ícone. O texto usa Windows/VCL com a mesma fonte usada
na medição, incluindo negrito, itálico, sublinhado e tachado.

```pascal
Card.TitleFont.Size := 11;
Card.TitleFont.Color := clGray;
Card.ValueFont.Size := 20;
Card.ValueFont.Style := [fsBold];
Card.FooterFont.Size := 10;
Card.FooterFont.Style := [fsItalic];
Card.FooterFont.Color := clRed;
```

As alterações redesenham o card automaticamente. Atribuir outro `TFont` também
funciona: `Card.ValueFont.Assign(MinhaFonte)` ou `Card.ValueFont := MinhaFonte`.
O card copia a configuração; não assume a propriedade da fonte externa.

## Cor automática e tema

O valor inicial de `Color` é `clDefault`. Nesse modo:

- título e valor seguem as respectivas cores do tema;
- rodapé segue `Status` (`mcsNeutral`, `mcsSuccess`, `mcsWarning`, `mcsDanger`).

Uma cor explícita permanece ao mudar `ThemeMode`, `Appearance` ou `Status`.
Alterar apenas tamanho/estilo mantém a cor automática. Para voltar à cor do
tema sem perder o restante da fonte:

```pascal
Card.FooterFont.Color := clDefault;
```

O status continua controlando o destaque semântico do ícone. `AccentColor`
mantém seu contrato anterior e não substitui `FooterFont.Color`.

`ResetTitleFont`, `ResetValueFont` e `ResetFooterFont` restauram uma parte.
`ResetTextFonts` restaura as três, incluindo a cor automática. Fontes padrão
não são gravadas no DFM; fontes personalizadas são preservadas no streaming.

## Layout e altura

O layout mede os textos com suas fontes efetivas e reserva áreas separadas
para título, valor e rodapé. Os três compartilham a mesma coluna após o ícone,
com margens esquerda e direita iguais. O rodapé usa essa mesma largura na
quebra de linhas. Textos podem ocupar várias linhas, inclusive
palavras longas sem espaços, sem substituir caracteres por reticências.

`AutoTextHeight=True` é o padrão: aumenta a altura quando necessário, inclusive
ao estreitar o card. Não reduz uma altura que a aplicação já definiu. Para
restaurar também a altura de uma tela, atribua `Height` após restaurar as fontes.

`AutoTextHeight=False` mantém altura fixa. Nesse caso, o chamador deve reservar
espaço suficiente. Restrições de altura do card ou do container também precisam
acomodar o conteúdo; não é possível garantir texto integral num espaço menor
que a medida necessária. `TextLayout.RequiredHeight` informa a altura requerida.

## Demonstração e regressão

- A página **Cards** da demo tem um botão para alterar/restaurar fontes em runtime
  e outro card com fontes configuradas no DFM. A troca de tema permite conferir
  as cores automáticas e os overrides explícitos.
- `Tests/DACSummaryCardFonts.dproj` testa propriedades sem `Parent`, streaming
  DFM, temas/status, altura, textos longos e cores dos pixels renderizados.
