# Consolidação documental — 23/09/2026

[Índice principal](README.md) · [Consolidação anterior](consolidation-2026-09-22.md)

## Estado consolidado

O manual central reúne a reconstrução do TDACChart, a API tipada e o ajuste de
espaçamento do título. Esta etapa altera documentação e ferramentas de integridade;
não altera Pascal/DFM, não recompila e não executa novamente o renderer.

| Alteração | Contrato atual | Fonte de detalhe |
| --- | --- | --- |
| Tipos | 23 famílias de codecs; enums, sets e objetos persistentes para medidas/limites/preenchimentos | [API tipada](manual/11-api-tipada.md) |
| Conversão e validação | Types centraliza domínios; store valida a cópia antes de trocar o estado; erro informa caminho | [Configuração](manual/03-configuracao-dados.md) |
| Ausência | Enum Default ou Reset remove override; zero/falso/alpha zero são concretos | [Guia rápido](tdacchart-options-api.md) |
| Persistência | JSON canônico no DFM, propriedades derivadas stored False; Assign e BeginUpdate/EndUpdate | [Arquitetura](manual/02-arquitetura.md) |
| Título | Altura medida com fonte Windows + 12 DIP antes da área cartesiana; subtítulo após altura real + itemGap | [Geometria](manual/04-geometria-desenho.md), [tipografia](manual/05-tipografia-dpi.md) |
| Demo | Orientação por enum, JSON público e título calculado no componente; formulário fixo no DFM | [Operação](manual/07-demo-operacao.md) |
| Data-aware | DataSource/DataLink, snapshot e adapter de cursor independente; TClientDataSet no demo | [Dados](manual/03-configuracao-dados.md) |

Textos livres, nomes de campos, nomes de séries e formatadores continuam strings.
Enums não devem simular suporte a recursos não desenhados. `BeginUpdate` agrupa
notificações; não suspende a validação nem cria rollback de um lote de setters.

## Resultados por etapa

| Execução em 22/09 | Evidência preservada | O que permanece aberto |
| --- | --- | --- |
| Reconstrução inicial | 29 casos comparados; 333 quadros indexados; logs e métricas | V15, baseline Windows, continuidade física e matriz completa |
| API tipada | Testes de codecs/rollback/DFM; seis builds; demo executado; 29 imagens DAC idênticas à etapa anterior; comparação 29/29 geometria e 28/29 texto | Fidelidade completa e flicker não aprovados |
| Espaçamento do título | Testes e demo compilados/executados; 72 combinações de texto/tamanho/DPI, remoção e margem maior; imagens e log | Comparação integral ECharts e performance não reexecutadas após o layout novo |

Os três arquivos estão acessíveis pelo [índice de evidências](README.md#conservação-do-conhecimento).
Não transferir o resultado de igualdade de imagens da etapa de tipos para o código
posterior: a proteção contra sobreposição modifica a área útil intencionalmente.
As capturas do título foram copiadas de `tmp/chart-title-spacing` sem edição.

## Organização e integridade

- Onze capítulos sincronizados; guias rápidos, demo e README da suíte apontam para
  o estado atual. Documentos antigos mantêm o conteúdo histórico com aviso de versão.
- Quatro catálogos gerados a partir dos fontes e fixtures locais; conferência com
  `build_catalog.py --check`.
- Evidências de cada etapa separadas, sem sobrescrever imagens, comparações ou
  manifestos anteriores. Novo manifesto do título distingue hashes coletados na
  consolidação de proveniência de build.
- `verify_documentation.py` verifica links, JSONs, hashes/tamanhos dos três arquivos
  e mapeamento dos 333 quadros históricos. Isso mede integridade documental.

Não houve nova pesquisa externa; ECharts permanece fixado em 6.1.0. Referências
normativas permanecem referências, e limites do runtime ficam explícitos nos
[contratos](manual/01-decisoes.md) e [pendências](manual/09-pendencias-manutencao.md).

## Verificação documental concluída

O gerador e o verificador foram executados nesta consolidação. Resultado:
383 links locais, 186 arquivos JSON, 911 mapeamentos de artefatos com hashes e
tamanhos conferidos (655 iniciais + 163 de tipos + 93 de título), 24 PNGs da matriz
de título com dimensões verificadas, 333 quadros históricos e inventário dos 29
cenários. Os quatro catálogos estão atuais. `git diff --check` não encontrou erros
de whitespace no escopo documental; houve apenas aviso de normalização LF/CRLF.

Esses números descrevem integridade dos documentos e arquivos preservados, não
uma execução nova do componente ou aprovação adicional de fidelidade/flicker.
