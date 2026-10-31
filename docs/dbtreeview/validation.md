# Validação executada — TDACDBTreeView

Data: 31/10/2026. Implementação integrada ao checkout oficial, na branch `main`.
A implementação inicial foi validada no worktree `codex/dbtreeview`, base
`944b102`; esta revisão recompilou e executou os testes no projeto oficial.
As alterações pendentes do DateTimePicker foram preservadas e excluídas do
commit de integração. Não houve push, instalação de pacote na IDE ou alteração
de configuração do Windows.

## Compilação e testes automatizados

Comando reproduzível na raiz do worktree:

```powershell
.\tools\test-dbtreeview.ps1
```

Toolchain executado: Delphi 10.2 Tokyo/Win32, `dcc32` 32.0, range checking
habilitado. Skia compilado a partir dos fontes instalados, com todas as saídas
de dependências e da biblioteca sob `Build/DBTreeView`. O script evita reutilizar
DCUs Skia incompatíveis encontrados na instalação e não modifica essa instalação.

| Verificação | Resultado |
| --- | --- |
| Skia RTL/VCL locais | Compilaram |
| Pacotes DAC runtime, design-time e combinado | Compilaram |
| Exemplo local com DFM e manifest de DPI | Compilou |
| Demo oficial `demo/Demo.dproj` / `demo/Demo.dpr` | Compilou e recebeu a aba DBTreeView |
| Inicialização real da galeria oficial | PASS; dados, marcação, bloqueio e busca com ancestrais |
| Dados, DFM, cache, reentrância e ciclo de vida | 202 assertivas, zero falhas |
| Painter e buffer nativo/Skia | 116 assertivas, zero falhas |
| Smoke existente | PASS |
| Interação existente | PASS; inclui 72 transições de botão e 169 ícones/roundtrips DFM |
| Ciclo de vida de designer existente | PASS |

Casos novos incluem troca/destruição de fontes, troca de binding durante leitura,
balanceamento de `DisableControls`, reset reentrante sem transferência de marcas,
veto, falha de validação do campo, ausência de fallback local, Post/Cancel externos,
e alterações de descrição/check/elegibilidade/chave/pai feitas em `BeforePost`
durante navegação VCL implícita. Também cobrem fonte padrão sem escala duplicada,
DFM com sentinelas tipadas e eventos, e pintura repetida sem leitura do dataset.

### Desempenho

Última execução do script completo, em cadeia hierárquica profunda. O teste
confirma **uma carga publicada** e **N leituras de registro** por catálogo.

| Registros | Carga completa | 200 movimentos do dataset |
| ---: | ---: | ---: |
| 1.000 | 4,157 ms | 0,637 ms |
| 10.000 | 38,703 ms | 0,663 ms |
| 50.000 | 222,767 ms | 0,886 ms |

Os movimentos não reconstruíram o catálogo. Expansão integral e busca pelo
último nó mantiveram todos os ancestrais, incluindo 50.000 níveis sem recursão.
Esses tempos descrevem esta máquina/execução, não um limite garantido de latência.

## Renderização e interação em janela real

O teste do painter gerou seis PNGs em 96/144/192 DPI lógico × claro/escuro.
Confere pixels de clipping/texto, hit-tests independentes, scrollbar/viewport e
50 ciclos de criação/pintura/liberação. Isso é evidência offscreen.

O exemplo também foi operado com Computer Use/SendInput e foco real. O build
final declara consciência de DPI no manifest e mostrou **DPI 144** no rodapé.
Foram observados:

- Checkbox por mouse e espaço; grupos bloqueados não exibem checkbox.
- Duas teclas Enter correspondendo a duas ativações, sem ação adicional no espaço.
- Tab da árvore para a busca e Shift+Tab da árvore para o checkbox do formulário,
  com foco confirmado pela árvore de acessibilidade.
- Setas para navegação, esquerda/direita para recolher/expandir, expansor por mouse,
  somente leitura, busca preservando ancestrais e restauração da expansão.
- Temas claro/escuro, textos extensos, redimensionamento e rolagem vertical/horizontal.

Parte da bateria funcional precedeu os ajustes finais de fonte; após o build
final foram reconferidos a fonte em 144 DPI, checkbox, espaço, Enter, Tab/Shift+Tab
e os dois temas. A API de acessibilidade expõe o controle desenhado como painel;
os nós foram conferidos por imagem e os alvos de foco por acessibilidade.

Evidências locais:

- `Build/DBTreeView/Tests/results.log` e `Painter/results.log`.
- `Build/DBTreeView/Painter/Evidence/`: seis imagens offscreen.
- `Build/DBTreeView/Physical/144-light.png` e `144-dark.png`.
- `Build/DBTreeView/Physical/focus-after-tab.txt` e `focus-after-shift-tab.txt`.
- Cada destino compilado mantém seu `build.log` no próprio diretório.

## Limites restantes

- Não foram executados testes físicos de monitor em 96 ou 192 DPI; essas escalas
  passaram apenas nos testes programáticos/offscreen.
- Registro na paleta e pacote design-time compilados, com streaming e criação sem
  Parent testados; instalação efetiva e abertura no designer da IDE permanecem
  sem validação manual nesta entrega.
- Acessibilidade de cada nó por leitor de tela não foi homologada.
- Atualizações opacas de mesmo tamanho que também movem o cursor podem exigir
  `Tree.Refresh` ou `BeginUpdate/EndUpdate`, conforme explicado no manual.
- Nenhuma integração funcional no MaxxRural ou aprovação de tela financeira foi
  realizada. O exemplo usa somente dados locais sintéticos.

## Integração no projeto oficial

O componente, pacotes, registro e documentação estão na raiz oficial da
biblioteca. A aba `DBTreeView` foi adicionada ao DFM da galeria e ao menu
gerado pelas páginas. Ela hospeda o mesmo exemplo consumidor do executável
independente, evitando duplicar regras de configuração e marcação. O `.dproj`
e o `.dpr` oficiais referenciam esse formulário; as units de runtime continuam
sem dependência do exemplo.

O teste `DACDemoStartup.Current` abre o formulário real, seleciona a aba,
confere o catálogo válido, marca uma folha, bloqueia um grupo e pesquisa
conservando ancestrais. O executável oficial atualizado está em
`Build/Exe/Win32/Debug/Demo.exe`.

Também foi aberto esse executável pelo Computer Use: navegação até DBTreeView,
árvore visível, foco real e clique em folha elegível confirmaram a atualização
da chave e do contador de marcados dentro da galeria oficial. A política de DPI
da demo oficial foi preservada (rodapé reportou 96); isso não substitui os
testes físicos anteriores em 144 DPI do exemplo independente. Evidências:
`Build/DBTreeView/Physical/official-demo-treeview.png` e
`official-demo-focus.txt`.
