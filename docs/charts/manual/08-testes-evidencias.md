# 08 — Testes, evidências e critérios de aceite

[Índice](../README.md) · [Arquivo preservado](../evidence/2026-09-22/README.md)
· [Cenários](catalogo-cenarios.md) · [Roteiro normativo](../echarts-reference/acceptance.md)

## Resultado que pode ser declarado

Execução inicial de 22/09/2026, relida na consolidação documental de 23/09.
A tabela abaixo pertence à execução inicial; as alterações posteriores estão
separadas na seção seguinte e não herdam automaticamente todos os seus resultados.

| Dimensão | Resultado observado | O que não prova |
| --- | --- | --- |
| Compilação | Componente, testes, demo exclusivo e perfis compilaram na etapa de implementação | Todos os projetos de toda a suíte |
| Execução | Demo exclusivo executado; asserts Delphi passaram | Todas as interações manuais e todos os monitores |
| Landmarks geométricos | 29/29 casos passaram | Paths completos, clipping, ordem, todos os elementos |
| Conteúdo textual comparado | 28/29; V15 reprovado | Baseline raster Windows ou âncoras completas |
| Pintura | Imagens/overlays/diffs produzidos | Aprovação global de aparência |
| Quadro de buffer | Sequências verificadas pelo analisador | Continuidade física da tela |
| Desktop | Zero quadros elegíveis no ensaio final | Ausência de flicker; resultado inconclusivo |
| Performance referência | p95 16,976 ms; máximo 21,7541 ms | 30 fps físicos, execução longa ou outros equipamentos |

Não houve recompilação/reexecução do renderer nesta consolidação exclusivamente
documental. Hashes e relatórios preservam o contexto da medição anterior.

## Alterações posteriores à execução inicial

| Etapa | Comprovado no ensaio | Limite |
| --- | --- | --- |
| [API tipada](../evidence/types-2026-09-22/README.md) | 23 famílias de codecs, validação/rollback, RTTI, DFM; seis builds; demo executado; 29 PNGs DAC idênticos aos anteriores | Comparação ECharts 29/29 landmarks, 28/29 textos; V15 continua reprovado |
| [Espaço do título](../evidence/title-spacing-2026-09-22/README.md) | Testes e demo compilados/executados; altura do título/subtítulo + 12 DIP; seis variações × três tamanhos × quatro DPIs, remoção e margem maior | Sem nova comparação integral ECharts, benchmark ou captura física contínua |

`TestChartTypes` está em `Tests/DACComponentsCharts.TypesTests.pas` e
`TestTitleSpacing` em `Tests/DACComponentsCharts.dpr`. A matriz do título verifica
a separação entre o texto registrado no quadro e a marca no limite superior do
eixo. Também assegura que ocultação/remoção restaura a área e que margem maior não
é reduzida. Os quatro DPIs são sintéticos; passagem real entre monitores continua
pendente. Capturas somente de W=720 foram salvas para os seis estilos e quatro DPIs.

Não aplicar o resultado de 29 imagens idênticas da etapa de tipos ao renderer após
a correção de título: a nova regra altera intencionalmente a geometria quando a
margem informada é insuficiente. As referências anteriores não foram sobrescritas.

O [ensaio portátil de 23/09](../portable-startup-2026-09-23.md), posterior a essas
etapas, valida dez condições de inicialização fora do workspace e confirma 29
imagens idênticas à compilação do ajuste de título. Ele usa buffers com janela
oculta e não altera o aceite temporal ou a comparação ECharts.

## Regressões das sete falhas originais

| Falha da auditoria histórica | Mecanismo atual / evidência | Extensão ainda necessária |
| --- | --- | --- |
| X numérico/temporal ordinal | Coord transforma X real; fixtures com espaçamento não uniforme | Calendário e limites automáticos temporais |
| Barra/linha desalinhadas | Centros categóricos compartilhados, C01 | Todas as combinações de gap/stack/largura |
| Última categoria ausente/repetida | Iteração e posições por categorias | Auto interval, rotação e colisão em tamanhos pequenos |
| Clone ignorava filtro | CloneCursor False/False, assert de filtro | Master/detail e índices complexos |
| Campo ausente virava NULL | Erro em linhas objeto e importação transacional testada | Matrizes irregulares e schemas externos |
| Limite Y fixo expandido | Bounds preserva explícitos | Precisão/extremos e todos os tipos |
| Pizza preferia encode Y | Caminho value da pizza separado | Todas as combinações de dimensions/layout |

A [auditoria](../validation-2026-09-22.md) contém evidência da implementação antiga.
Seus números de linha e oito testes originais não descrevem a unit reconstruída.

## O que os asserts Delphi medem

`Tests/DACComponentsCharts.dpr` combina os 14 casos originais e as 15 extensões,
testes de API/lifecycle e capturas. Inclui regressão de parsing decimal; rejeição
de série inválida e encode de campo inexistente; round-trip DFM; setters de título;
ClientDataSet filtrado com NULL, cursor preservado e atualização; mudança visual
sem releitura do dataset.

DPI é exercitado sinteticamente em 96/120/144/192 com dimensões escaladas. Resize
faz 41 mudanças e compara o PNG ao voltar a 720×420. Recursos GDI são medidos após
aquecimento e movimentos, tolerando crescimento limitado. Há espera de término
de animação, recriação de handle e minimizar/restaurar. Esses são ensaios finitos,
não uma prova de ausência de leaks ou flicker em execução prolongada.

Os três quadros da sequência unitária de animação são amostras, não cobertura de
toda a apresentação. `monitors.txt` registra um monitor: não houve passagem real
entre monitores com DPI diferente.

## Comparador geométrico

`compare.py` encontra JSONs C*/V* na pasta de referência e associa marcas pelos
índices de série e dado. Limite de comparação: erro absoluto <=0,5 pixel físico.
O helper Delphi de proximidade usa comparação estrita `<0.5`; normalizar esse
detalhe antes de casos exatamente no limite.

| Família | Valores comparados atualmente | Faltam como gates independentes |
| --- | --- | --- |
| Bar | Quatro bordas do retângulo | Cantos, borda, clip, efeitos, z-order |
| Line | X/Y dos pontos | Controles Bézier, segmentos, símbolos completos, áreas |
| Pie | Raios interno/externo e módulo do sweep | Centro, início, sentido, deslocamento, labels/conectores |
| NULL | Ausência esperada da marca correspondente | Lacuna/path e área entre vizinhos |

O comparador não rejeita toda marca extra inesperada. Também não cruza a lista
de arquivos com a lista obrigatória de fixtures: uma pasta vazia/incompleta pode
reduzir a cobertura sem a falha adequada. A lista explícita de 29 IDs no manifesto
arquivado confirma esta execução, mas o gate deve ser fortalecido para as próximas.

## Comparador de texto e imagem

Texto usa multiconjunto (`Counter`) de strings após strip: respeita multiplicidade,
mas não relaciona cada string à região/âncora correta. Detecta conteúdo esperado
ausente; não rejeita todo conteúdo extra. Usa logs do renderer e não OCR independente.
`clipped` é informação geométrica aproximada gerada pelo próprio engine.

As imagens são convertidas para RGB. O diff usa maior diferença entre canais;
região com diferença >8 contribui para proporção de pixels alterados. Overlay mistura
as duas imagens a 50%; mapa vermelho amplifica o delta por 4, limitado a 255.
Esses números/imagens são diagnósticos, não critério global de aprovação.

`visualReview` e avaliação de layout textual continuam exigindo revisão. Igualdade
entre PNG do DC da janela e PNG do buffer é registrada, mas não reprova/aprova por
si a execução. Uma comparação de conteúdo pode passar com texto na posição errada;
uma diferença raster pode ocorrer com texto corretamente posicionado.

## Analisador de quadros

`analyze-frames.py` verifica IDs consecutivos, existência/dimensão de PNGs e uma
heurística de buffer vazio por amplitude de canais; calcula hashes e intervalos.
Um gráfico estático correto pode ter um único hash em 121 apresentações, como
ocorreu no ensaio final. Contagem de hashes não prova animação suave.

Limites conhecidos:

- Não verifica cobertura temporal anterior ao primeiro e posterior ao último frame.
- Não usa oráculo do conteúdo para identificar rastros ou retorno a estado antigo.
- O critério de imagem uniforme não é geral para gráficos legitimamente vazios.
- `screenFrames` conta flags do log; não valida integralmente cada PNG desktop.
- Perfil de performance confere contagens/DPI, mas não todos os metadados de tamanho
  e seis séries. Igualdade dataCount/visibleMarks é específica da fixture de carga.
- Exit code reprova ausência/falha de buffers; não reprova performance ruim nem
  continuidade inconclusiva. O consumidor deve ler os campos do relatório.

O runner também não transforma `desktopContinuity=inconclusive` em aprovação.
Para aceite automatizado completo, faltam gates explícitos para todas essas dimensões.

## Métricas preservadas

| Ensaio | Pontos | Frames / distintos | p95 produção | Máximo produção | Intervalo máximo capturado |
| --- | --- | --- | --- | --- | --- |
| Final estático, DPI 144 | 996 | 121 / 1 | 16,976 ms | 21,7541 ms | 78 ms |
| Atualização animada 02 | 996 na configuração verificada | 98 / 92 | 18,4645 ms | 23,9607 ms | 94 ms |
| Tentativa desktop 02 | 996 | 51 / 47 | 16,9343 ms | 18,9212 ms | 78 ms |
| Carga adicional 10.000 | 10.000 | 63 / 1 | 119,5739 ms | 135,4148 ms | 156 ms |

A carga 10.000 está fora do perfil obrigatório de até 1.000, mas evidencia limite
de desempenho; não atende 30 fps de produção nesse ambiente. O relatório mais antigo
de animação não tem todos os contadores adicionados depois; conservar essa diferença
de schema, sem preencher medições retroativamente como se tivessem sido registradas.

Ambiente registrado: Windows 11, build 10.0.26200, Delphi Tokyo Win32, ECharts 6.1.0,
Chromium 151.0.7922.34. A consulta CIM foi negada; `os.json` usa identificação por
Python. Não há inventário completo de GPU/driver/CPU na evidência atual.

## Matriz obrigatória para o aceite final

| Grupo | Casos a comprovar | Situação atual |
| --- | --- | --- |
| Dados | Vazio, único, iguais, NULL, sinais, zero, filtro, atualização | Cobertura parcial com asserts/fixtures |
| Opções | Default, alternativa e combinações; efeito de cada published | Catálogo disponível; matriz de efeito incompleta |
| Texto | Longo, acentos, números, %, rich, rotação, quebra, corte | V15 falha; baseline Windows pendente |
| Legenda | Horizontal/vertical, páginas, muitos nomes, seleção/ocultação | Fixtures básicas; interação ampla pendente |
| Tooltip | Item/eixo, bordas, mouse rápido/parado, atrasos | Implementação parcial; automação insuficiente |
| Animação | Entrada/update/saída/reordenação/interrupção | Update Y exercitado; demais incompletos |
| Janela | Resize contínuo, minimizar, cobrir, recriar | Ensaios pontuais; captura temporal pendente |
| DPI/tamanho | 96/120/144/192 × 320×240/720×420/1280×720 | DPI sintético parcial; produto cartesiano não executado |
| Tema | ECharts e DAC | Exemplos; todas as combinações não aprovadas |
| Lifecycle | Parent=nil, DFM, origem destruída, timers | Testes parciais; atrasos pendentes de overlay a ampliar |
| Carga | 996, 10.000, vários charts, longo prazo, repouso | Cargas curtas registradas; múltiplos/longo prazo pendentes |

Cada execução deve produzir resultado por elemento e por dimensão de aceite.
Pendência ambiental é inconclusiva; divergência observada é falha. Não converter
uma em outra nem promover resultado pela média global da imagem.

## Protocolo futuro de captura temporal

Registrar simultaneamente IDs/timestamps do renderer e captura independente da
janela visível, com taxa suficiente e perdas detectáveis. Documentar início/fim,
oclusão, compositor, monitores, resolução, frequência e relógios. Incluir marcador
de sincronização e evento de mudança cujo tempo possa ser correlacionado.

Classificar cada transiente: quadro parcial, limpeza, rastro, salto de identidade,
retorno a estado antigo, pausa. Se houver buracos de captura que possam ocultá-los,
o ensaio é inconclusivo. Amostras imediatamente após Paint não fecham essa lacuna.
