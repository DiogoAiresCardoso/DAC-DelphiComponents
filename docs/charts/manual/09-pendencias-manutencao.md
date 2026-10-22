# 09 — Pendências, prioridades e manutenção

[Índice](../README.md) · [Contrato de aceite](08-testes-evidencias.md)

Esta lista é inventário de trabalho, não anúncio de implementação concluída.
Recursos posteriores (zoom, múltiplos eixos, tooltip externo/HTML e novas famílias)
continuam fora do escopo desta etapa. As demais lacunas afetam o aceite solicitado.

A [evolução tipada](11-api-tipada.md) entregou enums/sets, objetos de valor e
validação transacional de schema/valores, incluindo subobjetos. As pendências de
fidelidade e restrições contextuais de desenho continuam separadas dessa entrega.

O espaçamento entre título/subtítulo e área cartesiana foi corrigido e testado com
medição nativa e margem de 12 DIP. Continuam fora dessa correção colisões com legenda,
nomes de eixos, centro/raio de pizza e caixas maiores que o viewport. A comparação
integral ECharts ainda precisa ser reexecutada após essa mudança de layout, com
revisão explícita da adaptação local; não promover os resultados da etapa de tipos.

## Prioridades e definição de pronto

| Prioridade | Trabalho | Evidência necessária para encerrar |
| --- | --- | --- |
| P0 | Captura independente de desktop | Sequência integral com perdas detectadas, sem transientes nos cenários obrigatórios |
| P0 | Gates por elemento | Casos ausentes/extras reprovam; texto/clip/z-order/curvas verificados independentemente |
| P0 | V15 e tipografia | Truncamento resolvido e baseline Windows revisada sem máscaras de layout |
| P1 | Resolver defaults uma única vez | Inspector/JSON/renderer concordam; ausência não materializa override |
| P1 | Ampliar restrições semânticas de desenho | Schema/valores já têm validação central; validar efeitos/combinações por elemento |
| P1 | Rich text/labels/conectores | Caixas e âncoras corretas sob rotação, quebra, padding e colisão |
| P1 | Legenda/páginas/seleção | Testes de nomes extensos, páginas variáveis e single global |
| P1 | Tooltip e mouse parado | Conteúdo, atraso e bounds corretos após dados/resize/ocultação |
| P1 | Animação completa | Entrada/update/remoção/X/reordenação/interrupção sem saltos e com IDs estáveis |
| P1 | Calendário e estilos | Escala de tempo e opções anunciadas reproduzidas ou explicitamente recusadas |
| P1 | Lifecycle/DPI | Monitores reais, recriação com timer de overlay, erros na primeira pintura |
| P2 | Desempenho e caches | Perfil referência passa com cardinalidade comprovada; multi-chart/longo prazo medidos |
| P2 | Publicação/DFM | Efeito e round-trip de toda propriedade; editor nativo sem ambiguidades |

## Opções aceitas com efeito incompleto ou estreito

| Área | Lacuna identificada por leitura do código |
| --- | --- |
| Label | height, align, verticalAlign, overflow, margin não possuem toda a semântica oficial |
| Padding/raios | Caminhos numéricos escalares; arrays não equivalentes |
| Rich text | Blocos e fragmentos sem solver completo de linha/alinhamento |
| Gradiente | Coordenadas relativas implementadas e validadas; modo global rejeitado |
| Cores | Parser CSS limitado ao subconjunto declarado; valores inválidos agora são rejeitados |
| Eixo | Largura de axisLine pode ser sobrescrita; ticks onZero e calendário incompletos |
| Barras | Mistura de larguras e distribuição automática ainda aproximadas |
| Área | Base suavizada/empilhada não segue todas as variantes da referência |
| Pizza/rosca | Colisão/conector, vazio com furo, NULL em soma zero e posição inside estreita |
| Legenda | Default gap divergente, posição direita aproximada e single entre páginas |
| Tooltip | Padding medido e offset pintado podem divergir; altura de linha fixa |
| Animação | Easing parcial, Y predominante, escalas/X sem transição completa |
| Estados | Mistura visual básica não implementa todo focus/blurScope/seleção oficial |

Lista não exaustiva de valores ausentes. O [catálogo](catalogo-opcoes.json) descreve
o que a whitelist aceita; os capítulos 03–06 explicam os caminhos consumidos.
Uma correção deve acrescentar teste que falhe pelo efeito ausente, não apenas pelo
getter ou pela existência da chave.

## Estratégia de evolução da arquitetura

Preservar `TDACChart` como host público. Extrair progressivamente responsabilidades
internas quando houver contratos e testes: modelo resolvido → snapshot tipado →
escalas → layout → lista de comandos de desenho → apresentação/interação. Evitar
criar uma segunda API independente que volte a divergir do JSON/DFM.

O modelo resolvido deve informar valor, origem (default/override), unidade, tipo,
suporte e identidade. Isso permite mostrar no Inspector o valor efetivo sem
confundir edição com materialização. Uma árvore JSON única por si só não resolve
as uniões `auto|number|percent|callback` da API oficial.

O snapshot de dados deve ser imutável por quadro e versionado. Um layout deve
apontar para a mesma versão/identidades; interação deve consumir o layout realmente
apresentado. Publicar imagens e marcas em momentos diferentes pode criar hover
incoerente mesmo com imagem sem flicker.

Separar métricas de consulta, parsing, layout, texto, Skia, sincronização, BitBlt e
captura. Caches só devem ser introduzidos com chave/versionamento explícitos e
testes de invalidação; um cache rápido mas antigo viola continuidade.

## Rotina para alterar uma propriedade

1. Consultar opção e código oficial na versão fixada; registrar unidades/defaults.
2. Identificar entrada JSON, propriedade publicada e caminho de consumo local.
3. Definir caso default, alternativa, inválido e combinação relevante.
4. Acrescentar fixture compartilhada e controles do demo quando aplicável.
5. Implementar validação antes de publicar suporte no manual.
6. Testar round-trip JSON/DFM e efeito geométrico/visual/interativo.
7. Capturar referência/DAC, revisar diferenças por elemento e registrar ambiente.
8. Atualizar catálogos, capítulo e pendência; manter resultado inconclusivo explícito.

Não usar um teste que apenas replique a fórmula do renderer como única prova.
Combinar caso analítico independente, extração ECharts e imagem revisada. A mudança
de baseline precisa explicar o que mudou e por que a nova saída está correta.

## Atualização da referência ECharts

Alterar versão exige nova decisão: release/tag, licença/NOTICE, bundle/hash,
dependências transitivas, Chromium/Playwright, defaults e extrator de APIs internas.
Gerar evidências paralelas em pasta nova; não sobrescrever 6.1.0. Revisar todos os
casos e atribuições antes de trocar o padrão do projeto.

`echarts-reference/reference-cases.json` é documento histórico de 14 casos;
`Tests/Charts.Visual/fixtures.json` é a fonte executável atual. Não editar um e supor
que o outro ou a cópia junto do EXE foi automaticamente atualizado.

## Conservação de evidência e higiene de código

Preservar fonte Delphi em Windows-1252/CRLF conforme convenção local. Documentação
nova usa UTF-8. Builds e DCUs vão para saídas isoladas. Não alterar código de outros
controles para fazer um relatório de charts parecer aprovado; separar bloqueios
preexistentes, projetos testados e limitações ambientais.

Inventários gerados incluem hashes do código lido. Depois de alterar fonte,
regenerar `tools/build_catalog.py` e revisar a prosa manual. O gerador não compila
Pascal e não infere efeito visual. Registros de evidências são imutáveis por
convenção: se necessário corrigir interpretação, acrescentar nota, preservando o
artefato e o motivo.

## Decisões ainda abertas

- Truncamento nativo deve igualar substring ECharts ou ter adaptação formal específica?
- Como expor `auto`, ausência e unidades com ergonomia no Object Inspector?
- Seleção/visibilidade interativa deve integrar SaveJSON ou ter estado de sessão separado?
- Qual perfil Windows/fontes será baseline oficial, e quais tolerâncias raster por glifo?
- Qual capturador independente terá cobertura temporal verificável no desktop de QA?
- Qual política para timezone de campos Delphi e precisão de BCD/inteiros grandes?

Essas decisões não impedem documentar ou testar o estado atual. Impedem declarar
suporte completo onde o contrato ainda não foi implementado e comprovado.
