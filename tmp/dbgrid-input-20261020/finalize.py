from pathlib import Path
import shutil,hashlib,difflib,json,xml.etree.ElementTree as ET
r=Path(r'M:/MaxxSoft/MaxxRural/Desktop/maxxrural');t=Path('tmp/dbgrid-input-20261020');e=r/'MaxxRural/src/Tests/Resultados/20261021-grid-input'
x=ET.parse(e/'apitestes-todos.xml').getroot();assert x.attrib['total']=='253' and x.attrib['errors']=='0' and x.attrib['failures']=='0',x.attrib
for name in ['input-before.log','input-after.log','input-ui.log','build-tests.log','build-desktop.log','project-references.json']:
 shutil.copy2(t/name,e/name)
# Preserve project-local compiler logs emitted by the scripts too.
for name in ['build.log','build-desktop.log']:
 p=r/'MaxxRural/src/Tests/Resultados/20261020-grid-input'/name
 if p.exists():shutil.copy2(p,e/('msbuild-'+name))
readme='''# Correção de interação da TDACDBGrid — 21/10/2026

## Causa confirmada

`TfrmMaster.SetarPropriedadesIniciais` aplicava `Enabled=False` aos controles
ligados a dados fora do modo de edição. Depois restaurava a navegação apenas
para as classes antigas `TDBGrid` e `TJvDBUltimGrid`. A TDACDBGrid permanecia
visível, porém desabilitada, sem foco, clique ou scroll.

A regressão reproduziu o estado de inicialização legado sobre a hierarquia das
três abas extraída do DFM real do Movimento Bancário. Antes da correção, os três
casos falharam no hit test do Windows com `enabled=False`, `visible=True` e
`canfocus=False`; o clique atingia o ancestral, e não a grid. Ver
`input-before.xml`/`input-before.log`.

## Correção e escopo

- `Geral/uGridInteracao.pas`: política compartilhada de navegação para descendentes
  de `TCustomDBGrid`, sem depender de nomes do formulário ou regras bancárias.
- `Geral/ufrmMaster.pas`: invoca a política após o estado genérico dos controles
  ligados a dados. A personalização antiga das grids continua no fluxo existente.
- A política não altera ReadOnly, DataSource, campos, permissões de ações ou
  regras de negócio. Editores continuam desabilitados no estado de consulta.
- O componente continua respeitando uma configuração posterior de Enabled=False.
  Não foi acrescentado mecanismo para ignorar Enabled dentro da TDACDBGrid.
- A unit foi registrada nos 16 DPRs que referenciam o mesmo formulário base
  compartilhado; lista completa em `project-references.json`. Isso evita
  depender de DCU pré-compilada ou alterar search paths/dproj. Os outros módulos
  receberam somente essa referência; seu Rebuild não foi executado nesta revisão.
- Fontes e configurações anteriores foram preservadas. DBGrid e Tabs do
  repositório do componente estão byte a byte iguais ao início desta correção.
  Não houve alteração de dproj, configuração de IDE ou instalação de BPL.

## Testes executados

No ApiTestes oficial, quatro casos novos em
`Teste.MovimentoBancario.InputGrid.pas`, com suporte em
`TestSupport.DACGridHostForm.pas`:

1. Prontos: destino nativo do clique, Enabled/CanFocus, foco, seleção da segunda
   linha, scroll vertical e horizontal.
2. A Conciliar: os mesmos comportamentos na segunda página.
3. Importados: os mesmos comportamentos na terceira página.
4. Estado dos editores e desabilitação explícita da grid preservados.

O fixture lê o bloco completo de TDACTabs com suas três grids do DFM real,
atribui buffers locais de 80 registros sintéticos e reproduz o estado legado de
consulta antes de aplicar a mesma política usada pelo formulário base. O hit
test é obtido com WindowFromPoint antes de enviar o clique ao HWND encontrado;
isso evita o falso positivo de enviar diretamente à grid desabilitada. Os
scrolls automatizados verificam navegação e posição de scrollbar por mensagens
nativas. A janela de teste fica acima das demais apenas para estabilizar o hit
test contra oclusão externa. Essa propriedade não é aplicada à aplicação.

`input-after.xml`: quatro casos aprovados, zero falhas/erros.
**Suíte completa: 253 testes aprovados, zero falhas, erros, ignorados ou
vazamentos reportados pelo executor**, conforme `apitestes-todos.xml` e log.
O resultado de vazamentos é o reportado pelo DUnitX, sem promessa de auditoria
completa de memória/GDI. Os fixtures de banco usaram arquivo Firebird novo e
isolado pelo script, sem base operacional.

Nenhum projeto de teste avulso foi criado.

## Conferência com mouse efetivamente executada

Uma execução opt-in do mesmo ApiTestes, com dados sintéticos e o DFM real das
tabs/grids, foi observada e controlada por Computer Use:

- estado inicial: registro 0000000001, foco False;
- clique real na segunda linha: registro 0000000002, foco True;
- arrasto do thumb vertical: registro 0000000053 e viewport com registros 48–58;
- arrasto do thumb horizontal: cabeçalhos mudaram para TPG, Valor e Complemento.

As capturas dessa interação foram exibidas na conversa. `input-ui.xml` registra
a execução da fixture; não é uma transcrição dos cliques e não substitui as
observações visuais acima. A tentativa de usar F2 após os arrastos ocorreu quando
a janela temporária já havia encerrado; não se declara F2 validado por essa
sessão de mouse. Os testes automatizados anteriores de teclado permaneceram na
suíte completa.

Não foi feita autenticação nem aberta a tela operacional completa do MaxxRural.
A validação visual foi feita na hierarquia real de tabs/grids hospedada pelo
fixture; a confirmação com serviços/dados operacionais continua sendo homologação
separada. Os 16 outros entrypoints não foram todos compilados: o executável
principal validado nesta revisão é o MaxxADM/MaxxRural.

## Compilação

- ApiTestes Debug/Win32: Rebuild concluído por linha de comando.
- MaxxADM/MaxxRural Debug/Win32: Rebuild concluído por linha de comando.
- Executáveis em `M:\\MaxxSoft\\MaxxRural\\Desktop\\maxxrural\\EXE`.
- Avisos legados mantidos nos logs; nenhum erro nos Rebuilds finais.
- A primeira tentativa do MaxxADM apontou a referência ausente da nova unit;
  o DPR foi corrigido antes do Rebuild final. Não houve mudança de opções de
  projeto/IDE para contornar o problema.

Para reproduzir, execute `compilar.cmd`, `executar-testes.ps1` e
`compilar-desktop.cmd` desta pasta. Para inspeção visual opcional, defina
DAC_GRID_NATIVE_QA=1 somente no processo e execute ApiTestes com
`--run:Teste.MovimentoBancario.InputGrid.TMovimentoBancarioInputGridTests`.
A janela da primeira página fecha automaticamente após 90 segundos.

`scoped-changes.diff` contém somente o delta desta correção em relação aos
snapshots tomados antes de cada alteração. `source-sha256.json` identifica as
fontes e os executáveis finais. A revisão não identificou outra falha no escopo
exercitado; isso não representa homologação de toda a aplicação ou de todos os
módulos que compartilham o formulário base.
'''
(e/'README.md').write_text(readme,encoding='utf-8',newline='\n')
p=r/'source/README.md';s=p.read_text(encoding='utf-8');s+='''

## Interação das grids fora de edição — 21/10/2026

A inicialização herdada de TfrmMaster passou a preservar a navegação de todos os
descendentes de TCustomDBGrid por `TGridInteracao.RestaurarNavegacao`. Antes, o
estado genérico dos controles ligados a dados desabilitava as TDACDBGrid e apenas
as classes antigas de grid eram reabilitadas. A correção fica na integração do
consumidor: o componente continua respeitando Enabled=False; editores, ReadOnly
e regras de ações mantêm seus fluxos existentes.

No ApiTestes oficial, quatro regressões novas verificam o HWND atingido pelo
clique, foco, seleção e scroll das três páginas carregadas do DFM real, e a
preservação do estado dos editores. Antes da correção, as três grids falharam com
Enabled=False/CanFocus=False; depois os quatro casos passaram. Suíte completa:
253 testes aprovados, zero falhas/erros/ignorados reportados. Rebuild do ApiTestes
e do MaxxADM concluídos, executáveis em EXE, sem alterar dproj ou IDE.

Foi conferido mouse real no fixture: seleção de linha, foco e arrasto dos dois
scrolls. A tela operacional completa com autenticação/serviços e os demais
módulos continuam fora dessa homologação. Evidências:
`MaxxRural/src/Tests/Resultados/20261021-grid-input/README.md`.
''';p.write_text(s,encoding='utf-8',newline='\n')
paths=[r/'Geral/ufrmMaster.pas',r/'Geral/uGridInteracao.pas',r/'MaxxRural/src/Tests/ApiTestes.dpr',r/'MaxxRural/src/Tests/TestSupport.DACGridHostForm.pas',r/'MaxxRural/src/Tests/Teste.MovimentoBancario.InputGrid.pas']
refs=json.loads((t/'project-references.json').read_text());paths +=[r/name for name in refs]
diff=[]
for p in paths:
 if p.name=='ufrmMaster.pas':old=t/'ufrmMaster.before.pas'
 elif p.name=='ApiTestes.dpr':old=t/'ApiTestes.before.dpr'
 else:old=t/'dpr-before'/p.relative_to(r)
 a=old.read_bytes().decode('cp1252').replace('\r\n','\n').splitlines(True) if old.exists() else []
 data=p.read_bytes();assert b'\n' not in data.replace(b'\r\n',b''),str(p)
 diff.extend(difflib.unified_diff(a,data.decode('cp1252').replace('\r\n','\n').splitlines(True),fromfile='before/'+str(p.relative_to(r)),tofile=str(p.relative_to(r))))
(e/'scoped-changes.diff').write_bytes(''.join(diff).encode('utf-8'))
paths +=[r/'EXE/ApiTestes.exe',r/'EXE/MaxxRural.exe']
(e/'source-sha256.json').write_text(json.dumps({str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in paths},indent=2),encoding='utf-8')
print('Evidencias finais salvas; 253 testes aprovados.')
