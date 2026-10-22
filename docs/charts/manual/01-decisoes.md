# 01 — Decisões e contratos

[Índice](../README.md) · [Arquitetura](02-arquitetura.md)

## 1. Escopo e finalidade

O objetivo é um TDACChart configurável para futuros consumidores Delphi, com
comportamento visual fundamentado em ECharts 6.1.0 e verificável por uma bancada.
Fidelidade não significa apenas produzir um gráfico reconhecível. Abrange dados,
escalas, posição, forma, clipping, ordem de desenho, texto, estados, interação e
continuidade entre quadros. Cada dimensão tem aceite próprio.

| Decisão | Motivo | Consequência concreta |
| --- | --- | --- |
| ECharts 6.1.0 é normativo | Biblioteca ainda não tinha adoção nos sistemas | Substituir API antiga, sem camada de compatibilidade obrigatória |
| TDACChart é o host público | Consumidores precisam de um controle VCL único | A lógica essencial não fica no demo |
| Skia desenha geometria/efeitos | Paths, antialiasing, shaders e sombras | Não usar primitivas GDI como fallback de geometria |
| Texto é nativo Windows | Diretriz explícita de texto da aplicação | Fonte, medição, DPI e rasterização precisam de baseline própria |
| ECharts é o tema padrão | Evitar mudança semântica/visual implícita | Tokens DAC não devem substituir defaults automaticamente |
| DAC é override explícito | Permitir identidade da suíte sem alterar escalas | Paleta/fundo/estilos entram na configuração |
| Object Inspector, DFM e JSON compartilham modelo | Evitar três estados independentes | Persistir JSON e manter adapters TPersistent coerentes |
| Domínios fechados usam tipos Delphi | Evitar literais inválidos no consumidor | Enums/sets e objetos de valor; conversão e validação transacional centralizadas em Types |
| Título reserva espaço antes da área cartesiana | Correção visual solicitada após uso do demo | Altura nativa + 12 DIP; `grid.top` é mínimo, sem alteração do JSON salvo |
| Meta de 30 fps | Referência operacional aprovada | p95 de produção ≤33,3 ms no perfil definido |
| Demo independente | Isolar diagnóstico e adoção | Executável, formulário e dados locais próprios |
| Ausência de flicker precisa de captura da tela | Buffer correto não prova apresentação contínua | Falta de observação temporal produz resultado inconclusivo |

## 2. Famílias nesta etapa

| Visual | Representação normativa |
| --- | --- |
| Barras verticais | `series.type="bar"`, eixo X de categoria e Y de valor |
| Barras horizontais | `bar`, eixo Y de categoria e X de valor |
| Empilhadas | Mesmo identificador `stack`; contribuições positivas/negativas separadas |
| Linhas | `series.type="line"` |
| Áreas | `line` com `areaStyle`; mesma geometria superior da linha |
| Pizza | `series.type="pie"` |
| Rosca | `pie` com `radius:[interno,externo]` |
| Mistos | Séries cartesianas compartilhando transformação dos eixos |

Zoom, múltiplos eixos, tooltip externo/HTML, outras famílias e execução de callbacks
JavaScript são posteriores ou fora deste perfil. O fato de o ECharts oferecer um
recurso não o torna automaticamente parte do runtime DAC.

## 3. Precedência de fontes

1. Decisões explícitas do usuário para este componente.
2. Contratos ECharts 6.1.0, confirmados no código da tag e em execução controlada.
3. Manual consolidado para explicar a adaptação Delphi e registrar limitações.
4. Código local para identificar o comportamento realmente implementado.
5. Evidências para delimitar o que foi observado em um ambiente concreto.
6. Documentação legada somente como contexto de migração.

Código que diverge do contrato é uma pendência; não redefine silenciosamente a
norma. Documentação oficial viva pode tratar de uma versão posterior: identificar
a versão antes de transportar exemplos ou defaults. A referência normativa não
deve ser atualizada durante uma correção de desenho sem uma mudança explícita de base.

## 4. O que a adaptação nativa permite

É permitido ter rasterização de glifos diferente do Canvas do Chromium. Não é
permitido usar essa diferença para justificar texto ausente, âncora incorreta,
truncamento arbitrário, clipping ou ocultação de labels. Medir texto com Skia e
desenhar com GDI mistura métricas e quebra esse contrato.

Os callbacks são métodos Delphi, não strings executáveis. O tooltip é um overlay
composto dentro do controle. Exportar PNG não exige DOM, rede ou browser. A bancada
usa Chromium apenas para produzir uma referência externa.

## 5. Aceites que não podem ser fundidos

| Aceite | Pergunta respondida | O que não prova |
| --- | --- | --- |
| Compilação | Fontes e dependências compilam nesse alvo? | Streaming, aparência ou execução |
| Dados | Categorias, valores, identidades e NULL estão corretos? | Posição na tela |
| Geometria | Transformações e landmarks respeitam a referência? | Curvas, raster, textos e overlays completos |
| Pintura | Formas, materiais, clipping e ordem estão corretos? | Interação ou continuidade temporal |
| Texto nativo | Conteúdo, fonte, âncoras e cortes estão corretos? | Equivalência binária ao raster do browser |
| Interação | Hit-test, seleção e tooltip correspondem ao quadro visível? | Desempenho sob carga |
| Continuidade | Não há quadros incompletos, apagamento, rastros ou regressões? | Suporte a todas as propriedades |
| Configuração | Opções têm efeito e round-trip? | Cobertura de combinações não exercitadas |

## 6. Regra de declaração de fidelidade

Toda declaração deve conter versão do renderer, fonte, Windows, DPI, dimensão,
cenários, opções, tipo de captura, métricas e exclusões. “100% fiel”, “sem flicker”
e “pronto para produção” não são conclusões válidas a partir do build ou de um
percentual global de similaridade. O estado atual permanece parcial, conforme
[evidências](08-testes-evidencias.md).
