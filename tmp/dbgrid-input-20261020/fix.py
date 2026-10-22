from pathlib import Path
import shutil
r=Path(r'M:/MaxxSoft/MaxxRural/Desktop/maxxrural');t=Path('tmp/dbgrid-input-20261020')
p=r/'Geral/ufrmMaster.pas';shutil.copy2(p,t/'ufrmMaster.before.pas');s=p.read_bytes().decode('cp1252').replace('\r\n','\n')
s=s.replace('  uConstantes;', '  uConstantes, uGridInteracao;')
needle='          if ((Components[i].ClassType = TJvDBUltimGrid)'
assert s.count(needle)==1
s=s.replace(needle,'''          // A navegacao das grids de consulta independe do modo de edicao.
          // A regra vale tambem para descendentes de TCustomDBGrid, como TDACDBGrid.
          TGridInteracao.RestaurarNavegacao(Components[i]);

'''+needle)
p.write_bytes(s.replace('\n','\r\n').encode('cp1252'))
s=(t/'uGridInteracao.pas').read_text(encoding='utf-8');(r/'Geral/uGridInteracao.pas').write_bytes(s.replace('\n','\r\n').encode('cp1252'))
p=r/'MaxxRural/src/Tests/ApiTestes.dpr';s=p.read_bytes().decode('cp1252').replace('\r\n','\n');s=s.replace('  TestSupport.DACGridHostForm in', "  uGridInteracao in '..\\..\\..\\Geral\\uGridInteracao.pas',\n  TestSupport.DACGridHostForm in",1);p.write_bytes(s.replace('\n','\r\n').encode('cp1252'))
p=r/'MaxxRural/src/Tests/Teste.MovimentoBancario.InputGrid.pas';s=p.read_bytes().decode('cp1252').replace('\r\n','\n');s=s.replace('  TestSupport.DACGridHostForm,', '  uGridInteracao, Vcl.DBCtrls, TestSupport.DACGridHostForm,')
s=s.replace("        SetOrdProp(F.Components[I], 'Enabled', 0);", "        SetOrdProp(F.Components[I], 'Enabled', 0);\n        TGridInteracao.RestaurarNavegacao(F.Components[I]);")
s=s.replace("if GetEnvironmentVariable('DAC_GRID_NATIVE_QA') = '1' then", "if (Page = 0) and (GetEnvironmentVariable('DAC_GRID_NATIVE_QA') = '1') then").replace('while GetTickCount - Started < 60000 do', 'while (GetTickCount - Started < 90000) and F.Visible do')
s=s.replace('  public\n', '  public\n    [Test] procedure EstadoDeEditoresEDesabilitacaoExplicitaPreservados;\n',1)
at=s.index('procedure TMovimentoBancarioInputGridTests.HitTest')
s=s[:at]+'''procedure TMovimentoBancarioInputGridTests.EstadoDeEditoresEDesabilitacaoExplicitaPreservados;
var E: TDBEdit; G: TDACDBGrid;
begin
  E := TDBEdit.Create(nil); G := TDACDBGrid.Create(nil);
  try
    E.Enabled := False; TGridInteracao.RestaurarNavegacao(E);
    Assert.IsFalse(E.Enabled, 'Regra de navegacao nao deve habilitar editores.');
    G.Enabled := False; Assert.IsFalse(G.Enabled);
    TGridInteracao.RestaurarNavegacao(G); Assert.IsTrue(G.Enabled);
    Assert.IsTrue(G.ReadOnly);
    G.Enabled := False; Assert.IsFalse(G.Enabled, 'Enabled continua configuravel pelo consumidor.');
  finally G.Free; E.Free; end;
end;

'''+s[at:];p.write_bytes(s.replace('\n','\r\n').encode('cp1252'))
