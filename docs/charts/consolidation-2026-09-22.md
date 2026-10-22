> **Estado atual — 23/09/2026:** consulte a [consolidação atual](consolidation-2026-09-23.md) para API tipada, validação transacional, espaço do título e evidências posteriores. O conteúdo abaixo preserva sua etapa histórica.

# Consolidação documental — 22/09/2026

[Índice principal](README.md)

## Entrega documental

- Dez capítulos com decisões, arquitetura/ownership, API/DFM/JSON, dados/adapters,
  fórmulas de desenho, estilos, tipografia/DPI, buffers, interação/animação,
  operação, teste/aceite, pendências e referências oficiais.
- Quatro catálogos reproduzíveis: API/getters, 29 cenários completos, whitelist e
  cobertura explícita, símbolos/hashes/arquivos de fontes.
- Arquivo de evidências com 29 comparações e 333 quadros de quatro sequências,
  preservando logs, relatórios e origem/hash. Deduplicação de PNGs não remove frames
  dos índices; sequências podem ser reconstruídas.
- Entradas antigas identificadas como históricas e links de acesso no README da
  suíte, demo e documentos de referência.

## Verificações desta consolidação

O gerador foi executado e depois conferido com `--check`. O verificador conferiu
links locais, JSONs, hashes/tamanhos de 655 mapeamentos de artefatos, dimensões dos
333 PNGs mapeados nas sequências e existência das evidências dos 29 casos.
O restaurador reconstruiu os 98 PNGs da sequência animada em diretório novo.

As imagens preservadas foram mantidas sem edição; a sobreposição V15 foi inspecionada
para conferir a divergência descrita. Os sete hashes registrados no manifesto
histórico (quatro units principais, fixtures e formulário PAS/DFM) continuam iguais
ao conteúdo lido durante esta etapa. Isso não é auditoria de todos os arquivos da
suíte e não atribui alterações preexistentes à consolidação.

Não houve compilação ou execução nova do renderer: a mudança desta etapa é
documental e inclui somente utilitários de inventário/integridade/restauração de
evidências. Compilações, tempos e resultados visuais citados pertencem à execução
histórica identificada no arquivo de evidências.

## Limites preservados

O aceite continua parcial: 29/29 landmarks geométricos e 28/29 conteúdos textuais;
V15 falha. Pintura completa, baseline Windows e ausência de flicker físico não
foram aprovadas. A documentação explicita opções aceitas sem efeito completo,
defaults divergentes e lacunas dos próprios comparadores.

Uma alteração futura de implementação deve atualizar capítulos/catálogos e gerar
nova evidência em diretório próprio. Não sobrescrever o arquivo histórico nem
transformar uma atualização documental em aprovação de baseline.
