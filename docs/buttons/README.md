# TDACButton: texto e icone em runtime

Ao alterar `Caption`, o componente recalcula o grupo icone/texto e invalida o frame Skia, incluindo a transicao entre texto vazio e preenchido. Nao e necessario chamar `Redraw`, redimensionar o botao ou mover o mouse.

```delphi
btnImportar.Caption := Format('Importar %d registros', [Quantidade]);
```

As alteracoes explicitas de `Font.Name`, `Font.Size` e `Font.Style` (negrito) tambem recalculam o layout. `ParentFont = False` utiliza essas metricas; `ParentFont = True` utiliza novamente os presets do design system. A medicao, o texto nativo e o posicionamento do icone usam as mesmas metricas. As cores continuam seguindo a semantica do botao e do tema.

A largura do controle permanece definida pela aplicacao. `MinimumContentWidth` permite consultar a largura necessaria para o conteudo atual; textos maiores que a area disponivel continuam sujeitos aos limites do botao.

## Evidencias de 22/10/2026

- Falha reproduzida antes da correcao: Caption mudou sem reconstruir o frame Skia (`evidence/20261022/before.log`).
- 72 transicoes de Caption aprovadas: temas claro/escuro, icone a esquerda/direita, tres tamanhos, texto curto/longo/vazio e botao desabilitado. Verificacao adicional de fonte, retorno ao preset e ausencia de HWND sem Parent.
- Caption identico nao reconstruiu o frame desnecessariamente.
- Testes existentes de interacao e dos 169 icones tambem passaram.
- Rebuild Win32 dos testes, pacotes runtime/design/compatibilidade, demo e teste de startup: aprovados.
- `caption-expanded.png` foi capturado do controle real e inspecionado visualmente. Isso nao equivale a homologacao manual do fluxo operacional de importacao OFX.

O teste do componente esta em `Tests/DACComponentsButtonLayout.Tests.pas`, integrado ao projeto de interacao existente. Os testes de integracao do DFM real ficam no ApiTestes oficial do MaxxRural, em `Teste.ImportacaoOFX.BotaoCaption.pas`. Os resultados da integracao ficam em `MaxxRural/src/Tests/Resultados/20261022-button-caption` no repositorio consumidor.
