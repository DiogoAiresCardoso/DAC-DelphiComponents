from pathlib import Path
root = Path(r'M:\MaxxSoft\MaxxRural\Desktop\maxxrural')
stage = Path(__file__).parent
tests = root / 'MaxxRural/src/Tests'
for name in ['TestSupport.DACDBGridActions.pas', 'Teste.MovimentoBancario.AcoesGrid.pas']:
    p = tests / name
    assert not p.exists(), p
    text = (stage / name).read_text(encoding='utf-8')
    text = text.replace('  System.Classes, System.Types,\n', '  System.Classes, System.Types, Vcl.Controls, Vcl.DBGrids,\n') if name.startswith('TestSupport') else text
    text = text.replace('for Theme := dtmLight to dtmDark do', 'for Theme := dtmDark to dtmLight do')
    p.write_bytes(text.replace('\n', '\r\n').encode('cp1252'))
p = tests / 'ApiTestes.dpr'
b = p.read_bytes()
marker = b"  Teste.MovimentoBancario.Grids in 'Teste.MovimentoBancario.Grids.pas',"
assert b.count(marker) == 1
b = b.replace(marker, marker + b"\r\n  TestSupport.DACDBGridActions in 'TestSupport.DACDBGridActions.pas',\r\n  Teste.MovimentoBancario.AcoesGrid in 'Teste.MovimentoBancario.AcoesGrid.pas',")
p.write_bytes(b)
p = tests / 'Teste.MovimentoBancario.MVC.pas'
b = p.read_bytes()
marker = b'    [Test] procedure NormalizaCodigoEPreservaDadosCadastrais;'
assert b.count(marker) == 1
b = b.replace(marker, marker + b'\r\n    [Test] procedure AcoesRegistramSomenteIntencaoSemConsultarDAO;\r\n    [Test] procedure AcoesRejeitamChaveEmpresaEIdentificadorInvalidos;')
new = '''procedure TMovimentoBancarioMVCTests.AcoesRegistramSomenteIntencaoSemConsultarDAO;
var Estado: Controller.MovimentoBancario.TMovimentoBancarioAcaoEstado;
begin
  for Estado in FController.AcoesDisponiveis('0000000007', '0000000123') do
  begin
    Assert.IsTrue(Estado.Visivel);
    Assert.IsTrue(Estado.Habilitada);
    Assert.IsTrue(FController.SolicitarAcao(Estado.Identificador, '0000000007', '0000000123'));
    Assert.AreEqual(Estado.Identificador, FController.UltimaIntencao.Acao);
    Assert.AreEqual('0000000007', FController.UltimaIntencao.Empresa);
    Assert.AreEqual('0000000123', FController.UltimaIntencao.Movimento);
  end;
  Assert.AreEqual(3, Length(FController.AcoesDisponiveis('0000000007', '0000000123')));
  Assert.AreEqual(0, FDAO.Chamadas);
  Assert.AreEqual(0, FDAO.ChamadasBanco);
end;

procedure TMovimentoBancarioMVCTests.AcoesRejeitamChaveEmpresaEIdentificadorInvalidos;
var Estado: Controller.MovimentoBancario.TMovimentoBancarioAcaoEstado;
begin
  Assert.IsFalse(FController.SolicitarAcao('editar', '0000000008', '0000000123'));
  Assert.IsFalse(FController.SolicitarAcao('excluir', '0000000007', ''));
  Assert.IsFalse(FController.SolicitarAcao('executar-sql', '0000000007', '0000000123'));
  Assert.AreEqual('', FController.UltimaIntencao.Acao);
  for Estado in FController.AcoesDisponiveis('0000000008', '0000000123') do
    Assert.IsFalse(Estado.Habilitada);
  Assert.AreEqual(0, FDAO.Chamadas);
end;

'''.replace('\n', '\r\n').encode('ascii')
marker = b'initialization\r\n'
assert b.count(marker) == 1
b = b.replace(marker, new + marker)
p.write_bytes(b)
results = tests / 'Resultados/20261020-grid-acoes'
results.mkdir(exist_ok=True)
for source, target in [('compilar.cmd','compilar.cmd'), ('compilar-desktop.cmd','compilar-desktop.cmd')]:
    b = (tests / 'Resultados/20261020-grids-logchanges' / source).read_bytes()
    if source == 'compilar.cmd':
        # Adds source directories for this invocation only; project/IDE configuration is untouched.
        paths = (r'M:\Delphi Componentes\DAC-DelphiComponents\Source\Controls;'
                 r'M:\Delphi Componentes\DAC-DelphiComponents\Source\Core;'
                 r'M:\Delphi Componentes\DAC-DelphiComponents\Source\DesignSystem;'
                 r'M:\Delphi Componentes\DAC-DelphiComponents\Source\Skia;'
                 r'M:\Delphi Componentes\DAC-DelphiComponents\Source\Hooks;'
                 r'M:\MaxxSoft\MaxxRural\Desktop\maxxrural\DCU;%DUnitX%;'
                 r'M:\MaxxSoft\MaxxRural\Desktop\maxxrural\MaxxRural\src\Consultas;'
                 r'M:\MaxxSoft\MaxxRural\Desktop\maxxrural\MaxxRural\src;'
                 r'M:\MaxxSoft\MaxxRural\Desktop\maxxrural\MaxxRural\Service;'
                 r'M:\MaxxSoft\MaxxRural\Desktop\maxxrural\Geral')
        b = b.replace(b'/t:Rebuild', ('/t:Rebuild /p:DCC_UnitSearchPath="' + paths + '"').encode('ascii'))
    (results / target).write_bytes(b)
print('Official ApiTestes fixtures and Rebuild scripts installed; project configuration preserved.')
