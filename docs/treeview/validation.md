# Validacao do TDACTreeView

Executada em 31/10/2026, com Delphi 10.2 Tokyo (dcc32 32.0), Win32 e os
fontes de Skia4Delphi ja utilizados pelo repositorio. Branch: `codex/treeview`.

## Compilacao e testes automatizados

Comando completo: `./tools/test-treeview.ps1`. Depois dos ajustes finais do
formulario consumidor, foi repetido `./tools/test-treeview.ps1 -SkipPackages`.
Os pacotes nao receberam alteracoes entre essas duas execucoes.

| Alvo | Resultado |
| --- | --- |
| Pacote runtime, design-time e combinado | Compilados |
| TDACTreeView: itens, objetos, estado, eventos e DFM | 224 verificacoes, zero falhas |
| Painter do TDACTreeView | 140 verificacoes, zero falhas |
| DBTreeView existente | 202 verificacoes, zero falhas |
| Painter do DBTreeView existente | 116 verificacoes, zero falhas |
| Demo oficial e exemplos independentes das duas arvores | Compilados |
| Smoke, interacao e ciclo de vida existentes | Passaram |
| Inicializacao da galeria oficial | Passou, incluindo a pagina TreeView |

Total dos quatro executaveis de arvore/painter: **682 verificacoes**. A
inicializacao da galeria tambem confere carga manual/objetos, referencias do
consumidor, temas e fonte/contraste dos controles do novo exemplo.

A bateria cobre irmaos/filhos, remocao de subarvore, lista vazia, propriedade
externa dos objetos, substituicao de objetos pela mesma chave, preservacao de
estado, falha no mapper, chaves tipadas, sentinelas, duplicatas, pais ausentes,
ciclos, profundidade extrema, busca, veto, somente leitura, callbacks
reentrantes e streaming de itens/colunas/raizes/eventos. O DBTreeView conserva
seus testes de navegacao, edicao, Post implicito, DataLink e ciclo de vida.

Foi verificada a ausencia de `Data.DB` e de dependencias do DBTreeView nas
unidades `TreeView*`. Os painters compartilham modelo, colunas, raizes,
projecao e desenho neutros; bookmarks e DataLink continuam na camada DB.

## Desempenho observado

Ultima execucao automatizada, sem depurador. Tempos em milissegundos; servem
como evidencia local, nao como garantia para qualquer maquina.

| Itens | Carga | 200 movimentos de selecao | Remocao da subarvore |
| ---: | ---: | ---: | ---: |
| 1.000 | 4,016 | 0,199 | 2,200 |
| 10.000 | 33,263 | 0,315 | 19,347 |
| 50.000 | 152,085 | 0,157 | 104,201 |

Os testes instrumentam leituras/cargas, verificam pintura a partir dos caches
e desenho limitado ao viewport. A validacao de hierarquia e a exclusao de
subarvore sao iterativas, inclusive para cadeias profundas.

## Renderizacao e interface real

Os dois painters produziram evidencias em temas claro/escuro e DPI logico
96/144/192. Assercoes conferem geometria, fonte Windows, checkbox opcional,
hit-tests e reutilizacao de recursos GDI. Isso e renderizacao offscreen.

O teste `Tests/DACTreeViewPhysical.dpr` abre a galeria oficial e usa entrada
nativa na propria janela: espaco, Enter sem duplicacao, setas, Tab/Shift+Tab,
foco efetivo e clique de mouse no checkbox. Tambem confere que o evento do
consumidor atualiza o objeto original. Resultado: **67 verificacoes, zero
falhas**. O envio depende de primeiro plano e e recusado se outra janela
estiver ativa.

O sistema estava em **144 DPI**, enquanto a galeria efetivamente renderizou
em **96 DPI**, conforme a politica existente do executavel hospedeiro. Nao
houve validacao fisica da galeria renderizando em 144 ou 192 DPI. O componente
nao altera a politica de DPI de processos consumidores.

A captura real usa o DC da propria janela, pois PrintWindow retornou imagem
uniforme nesse ambiente. A revisao visual da captura motivou ajustes de
contraste e espaco para as legendas do exemplo consumidor.

O servico de computer-use ficou indisponivel por falha de inicializacao dos
assets. A verificacao de interface foi realizada pelo executavel nativo de
teste do repositorio. O sandbox recusou SendInput (erro 5); a execucao fora
dele, autorizada para o teste, passou.

## Artefatos e limites

- Galeria oficial atualizada: `Build/Exe/Win32/Debug/Demo.exe`.
- Logs individuais: `Build/TreeView/<alvo>/build.log` e `results.log`.
- Imagens dos painters: `Build/TreeView/PlainPainter/Evidence` e
  `Build/TreeView/Painter/Evidence`.
- Captura da galeria: `Build/TreeView/Physical/official-tree.png`.
- Log de entrada nativa: `Build/TreeView/PhysicalTest/results.log`.

Os registros runtime e da paleta DAC Skia estao incluidos nos pacotes
compilados. A instalacao manual do BPL na IDE e a insercao do novo componente
pela paleta da IDE nao foram executadas. Streaming e criacao sem Parent foram
executados pelos testes. Nao houve homologacao em aplicacao consumidora nem
integracao no MaxxRural.

As alteracoes preexistentes no projeto do pacote foram preservadas. O teste
fisico do DateTimePicker manteve exatamente o hash SHA-256 registrado antes
do trabalho; seus ajustes pendentes nao fazem parte desta implementacao.
