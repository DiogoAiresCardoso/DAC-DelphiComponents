from pathlib import Path
import re,json,hashlib,shutil,difflib,collections

r=Path(r'M:\Delphi Componentes\DAC-DelphiComponents')
tmp=r/'tmp/icons-expanded-20261021'
docs=r/'docs/icons'; out=docs/'evidence/20261021'; out.mkdir(parents=True,exist_ok=True)
old=(tmp/'icons.before.pas').read_bytes().decode('cp1252').replace('\r\n','\n')
new=(r/'Source/DesignSystem/DAC.Components.DesignSystem.IconAssets.pas').read_bytes().decode('cp1252').replace('\r\n','\n')
enums=lambda text:re.findall(r'\bmik\w+\b',re.search(r'TDACIconKind = \((.*?)\n  \);',text,re.S)[1])
oldnames=enums(old); names=enums(new)
assert names[:len(oldnames)]==oldnames and len(names)==170
assert len(set(names))==len(names)
inventory=json.loads((docs/'expanded-catalog.json').read_text('utf8'))
assert len(inventory)==63
counts=dict(collections.Counter(a['category'] for a in inventory))
assert counts=={'files':16,'folders-paths':14,'system':33}
for a in inventory:
    constant='C'+a['kind'][3:]+'Svg'
    value=re.search(r'const '+constant+r' =\n(.*?);\n',new,re.S)[1]
    parts=re.findall(r"'((?:[^']|'')*)'|(#13#10)",value)
    svg=''.join(s.replace("''", "'") if not line else '\n' for s,line in parts)
    master=(r/'assets/svg'/a['path']).read_text('utf-8-sig').replace('\r\n','\n').rstrip('\n')
    assert svg==master,a['path']
for name in ['build-tests.log','tests.log','build-demo.log','build-runtime.log','build-design.log','build-package.log','build-startup.log','startup.log','audit.json','build-tests.cmd','build-demo.cmd','build-startup.cmd']:
    shutil.copy2(tmp/name,out/name)
assert 'DACComponentsInteraction: PASS' in (out/'tests.log').read_text('utf8')
assert 'DACDemoStartup: PASS' in (out/'startup.log').read_text('utf8')
pairs=[('icons.before.pas','Source/DesignSystem/DAC.Components.DesignSystem.IconAssets.pas'),
       ('painter.before.pas','Source/Skia/DAC.Components.Skia.IconPainter.pas'),
       ('demo.before.dfm','demo/Demo.Principal.dfm'),('demo.before.pas','demo/Demo.Principal.pas'),
       ('tests.before.dpr','Tests/DACComponentsInteraction.Current.dpr'),
       ('startup.before.dpr','Tests/DACDemoStartup.Current.dpr')]
diff='';formats={};paths=[]
for before,name in pairs:
    p=r/name; data=p.read_bytes(); paths.append(p)
    formats[name]={'utf8_bom':data.startswith(b'\xef\xbb\xbf'),'bare_lf':data.replace(b'\r\n',b'').count(b'\n')}
    assert not formats[name]['utf8_bom'] and formats[name]['bare_lf']==0
    diff+=''.join(difflib.unified_diff((tmp/before).read_bytes().decode('cp1252').splitlines(True),data.decode('cp1252').splitlines(True),before,name))
paths += [r/'Tests/DACComponentsIcons.Tests.pas',r/'tools/sync_icon_assets.py']
(out/'format-checks.json').write_text(json.dumps(formats,indent=2),encoding='utf8')
(out/'source-sha256.json').write_text(json.dumps({str(p):hashlib.sha256(p.read_bytes()).hexdigest() for p in paths},indent=2),encoding='utf8')
(out/'scoped-changes.diff').write_text(diff,encoding='utf8')
(out/'catalog-checks.json').write_text(json.dumps(dict(old_ordinals_preserved=True,old_icons=106,added=63,total=169,categories=counts,embedded_svgs_equal_to_assets=True),indent=2),encoding='utf8')

table='| Categoria | Novos ícones |\n|---|---:|\n'+''.join(f'| `{key}` | {count} |\n' for key,count in counts.items())
entries='| IconKind | Nome | Arquivo mestre |\n|---|---|---|\n'+''.join(f"| `{a['kind']}` | {a['label']} | `assets/svg/{a['path']}` |\n" for a in inventory)
(docs/'README.md').write_text(f'''# Catálogo de ícones DAC

O catálogo contém **169 SVGs**, mais `mikNone`. A ampliação de 21/10/2026 inclui **63 ícones** e mantém os 106 originais com os mesmos nomes, valores ordinais, arquivos e geometrias.

{table}
## Configuração

Os ícones ficam na enumeração `TDACIconKind`, disponível no Object Inspector e por código. Use `IconKind` em `TDACButton`, `TDACBadge`, `TDACSummaryCard` e nas ações de coluna de `TDACDBGrid`; em `TDACButtonEdit`, use `ButtonIconKind`.

```pascal
Botao.ShowIcon := True;
Botao.IconKind := mikFolderOpen;
Botao.IconSize := 20;

Card.IconKind := mikDatabase;
Badge.IconKind := mikFileCheck;
CampoArquivo.ButtonIconKind := mikFileJson;
AcaoDaColuna.IconKind := mikFileSearch;
```

O painter compartilhado continua aplicando cor, opacidade e cache. `mikFileCheck` acompanha a semântica de confirmação; `mikFileWarning`, a de alerta. Controles que fornecem uma cor explícita ao painter mantêm essa escolha. Os novos SVGs estão embutidos na unit IconAssets: não é necessário distribuir a pasta assets com a aplicação.

Para evitar colisões, o novo PDF da categoria `files` usa **`mikFilesPdf`** e o pacote de sistema usa **`mikSystemPackage`**. `mikFilePdf` continua sendo o ícone de `report-viewer`; `mikPackage` continua na categoria `data`. As constantes de caminho também foram adicionadas, com prefixos `DAC_ICON_FILES_`, `DAC_ICON_FOLDERS_PATHS_` e `DAC_ICON_SYSTEM_`.

No demo, a seção Botões → Ícones inclui Arquivo JSON, Pasta aberta e Banco de dados. Os demais valores podem ser selecionados nas mesmas propriedades. Depois de recompilar/recarregar os pacotes usados pela IDE, o Object Inspector enumera os novos nomes; nesta entrega os pacotes foram recompilados, sem instalar ou recarregar pacotes na IDE aberta.

## Catálogo ampliado

![63 novos ícones renderizados pelo painter dos componentes](evidence/20261021/expanded-icons.png)

{entries}
## Sincronizar novos arquivos

Execute `python tools/sync_icon_assets.py`. O script lê os mestres `assets/svg/<categoria>/*.svg`, acrescenta somente os arquivos ainda não registrados e preserva os ordinais existentes. Usa o manifesto do pacote expandido para os rótulos. As cópias `svg-green` são variantes de cor; não representam outros itens do catálogo. A segunda execução sem novos arquivos não altera o catálogo.

Ao ampliar novamente, revise o inventário/documentação e as expectativas de contagem dos testes. Não reordene a enumeração: suas posições também são usadas em dados serializados e no código de aplicações consumidoras. Casos de nomes repetidos entre categorias devem manter o ícone anterior e receber identificador distinto.

## Validação executada em 21/10/2026

- Projeto existente DACComponentsInteraction: **PASS**. Nova unit DACComponentsIcons.Tests renderiza os 169 ícones pelo painter real em três estilos (verde e branco opacos, vermelho com alpha 128), confirma pixels não vazios e limite de opacidade, metadados e caminhos únicos, RTTI e as propriedades publicadas dos componentes consumidores. Trabalha a partir de uma pasta temporária, sem depender de assets em runtime.
- **169 roundtrips DFM binários** de TDACButton com os valores de IconKind. Os testes usam o registro normal das classes da suíte e registram temporariamente TSkPaintBox para serializar o filho interno, restaurando esse registro depois. Os ordinais anteriores e as duas colisões de nomes são verificados explicitamente.
- Projeto existente DACDemoStartup: **PASS**. Carrega o DFM real do demo, confere os três novos ícones, ativa a página Botões e verifica parent e largura mínima do exemplo.
- **Rebuild Debug/Win32** de runtime, design-time, pacote de compatibilidade, demo e dos dois projetos de teste aprovado no Delphi 10.2. Sem alterar dproj, configurações da IDE ou arquivos da aplicação MaxxRural. Warnings/hints existentes de charts permanecem, sem erros finais.
- Os 63 SVGs embutidos foram comparados exatamente com os mestres locais; enumeração anterior preservada e codificação CP1252/CRLF conferida nos arquivos Delphi alterados. O gerador foi executado novamente e informou catálogo atualizado, sem mutação.
- Inspeção visual do PNG produzido pelo painter: todos os 63 desenhos e seus identificadores estão presentes e legíveis. Não foi feita inspeção manual do Object Inspector/recarga do pacote, nem homologação interativa de todos os ícones em cada tema e DPI.

Logs, scripts de build, PNG, hashes, verificações de formato e diff apenas desta entrega em [evidence/20261021](evidence/20261021/). Os builds foram feitos com saídas isoladas em tmp. A auditoria estática mantém 32 pares de hooks e as 15 famílias, com os oito avisos TODO anteriores; ela não substitui os testes de renderização.
''',encoding='utf8')
print('Evidence written. Catalog:',len(names)-1,'New:',counts)
