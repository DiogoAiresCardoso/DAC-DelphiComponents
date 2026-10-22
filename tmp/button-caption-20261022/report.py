from pathlib import Path
import xml.etree.ElementTree as ET, shutil, hashlib, json
r=Path(r'M:\Delphi Componentes\DAC-DelphiComponents')
c=Path(r'M:\MaxxSoft\MaxxRural\Desktop\maxxrural')
e=c/'MaxxRural/src/Tests/Resultados/20261022-button-caption'
x=ET.parse(e/'apitestes-todos.xml').getroot()
b=ET.parse(e/'baseline-estrutura.xml').getroot()
def failed(root):
    return [(n.attrib['name'], ' '.join(n.find('failure/message').itertext()).strip()) for n in root.iter('test-case') if n.find('failure') is not None]
f=failed(x); baseline=failed(b)
summary={'total':x.attrib['total'],'errors':x.attrib['errors'],'failures':x.attrib['failures'],'baseline_failures':baseline,'current_failures':f}
(e/'summary.json').write_text(json.dumps(summary,indent=2,ensure_ascii=False),encoding='utf-8')
for name in ['botao-caption.xml','botao-caption.log','baseline-estrutura.xml','summary.json']:
    shutil.copy2(e/name,r/'docs/buttons/evidence/20261022'/name)
report='''# TDACButton Caption em runtime - 22/10/2026

## Correcao

O handler CM_TEXTCHANGED atualizava somente o texto nativo. O frame Skia conservava o icone calculado para o Caption anterior. Agora Caption e alteracoes de fonte invalidam ambas as camadas. Medicao, posicionamento e texto nativo usam as mesmas metricas de familia, tamanho e negrito. A largura do controle continua sob responsabilidade da aplicacao.

Somente o componente Button, o teste de interacao do componente e os testes do ApiTestes foram alterados nesta entrega. A View e o DFM de importacao OFX nao foram modificados. Nenhuma operacao financeira foi conectada ou executada. Fontes Delphi preservadas com CRLF e codificacao legada.

## Verificacoes executadas

- Reproducao antes da correcao: FAIL ao trocar Caption sem atualizar o frame Skia.
- Componente: 72 transicoes de Caption aprovadas (claro/escuro, esquerda/direita, tres tamanhos, texto longo/curto/vazio e desabilitado), mais fonte, retorno ao preset e ausencia de HWND sem Parent.
- ApiTestes: 2/2 casos especificos aprovados. Streaming do bloco btnImportar do DFM real em execucao, sem handler financeiro; Caption alterado para quantidades 138, 1, 9999 e 0, sem resize ou hover. Somente o OnClick foi removido do fixture.
- Os 169 icones, roundtrips DFM e testes existentes do projeto de interacao passaram.
- Rebuild Debug/Win32 via MSBuild: testes, pacotes runtime/design/compatibilidade, Demo, DACDemoStartup, MaxxRural e ApiTestes aprovados. DACDemoStartup: PASS. Warnings existentes permanecem nos logs.
- Executaveis consumidores mantidos em EXE/MaxxRural.exe e EXE/ApiTestes.exe.
- Ajustes de ResourcePath somente na linha de comando para o ApiTestes encontrar os DFMs das dependencias atuais. Nenhuma configuracao de projeto ou IDE alterada nesta entrega.

## Suite completa e comparacao com a implementacao anterior

'''
report+=f"Resultado atual: {x.attrib['total']} testes; {x.attrib['errors']} erros; {x.attrib['failures']} falhas. XML e log: apitestes-todos.xml/log.\n\n"
report+='Falhas observadas:\n\n'+''.join('- '+name+': '+message+'\n' for name,message in f)
report+='\nA fixture estrutural foi recompilada e executada com o corpo anterior de Button (mantendo as novas declaracoes privadas para compatibilidade dos DCUs). As mesmas cinco falhas de altura do campo OFX e largura HISTORICO ocorreram: baseline-estrutura.xml/log. A fonte final foi restaurada e o ApiTestes recompilado antes desta execucao final. Essas falhas nao foram introduzidas pela correcao de Caption e permanecem fora deste ajuste.\n\n'
report+='A primeira execucao completa teve 21 erros por OFX_REMOCAO_TEST_DIR ausente; preservada em suite-before-env.xml/log. O runner agora fornece diretorios novos isolados para os fixtures, preservando e restaurando as variaveis de ambiente. Os bancos de teste sao criados com nomes unicos; nenhuma base operacional foi utilizada.\n\n'
report+='## Limite da verificacao visual\n\nA imagem do botao real foi capturada e inspecionada em docs/buttons/evidence/20261022/caption-expanded.png no repositorio do componente. Nao foi feita homologacao manual da tela OFX autenticada nem importacao bancaria real.\n'
(e/'README.md').write_text(report,encoding='utf-8')
files=[r/'Source/Controls/DAC.Components.Controls.Button.pas',r/'Tests/DACComponentsButtonLayout.Tests.pas',c/'MaxxRural/src/Tests/Teste.ImportacaoOFX.BotaoCaption.pas',c/'EXE/MaxxRural.exe',c/'EXE/ApiTestes.exe']
(e/'sha256.txt').write_text('\n'.join(hashlib.sha256(p.read_bytes()).hexdigest()+'  '+str(p) for p in files)+'\n',encoding='utf-8')
print(json.dumps(summary,ensure_ascii=False))
