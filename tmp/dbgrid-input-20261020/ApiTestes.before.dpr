program ApiTestes;

{$IFNDEF TESTINSIGHT}
{$APPTYPE CONSOLE}
{$ENDIF}{$STRONGLINKTYPES ON}
uses
  System.SysUtils,
  {$IFDEF TESTINSIGHT}
  TestInsight.DUnitX,
  {$ENDIF }
  DUnitX.Loggers.Console,
  DUnitX.Loggers.Xml.NUnit,
  DUnitX.TestFramework,
  Teste.Financeiro.MovimentacaoBancaria.Contrato in 'Teste.Financeiro.MovimentacaoBancaria.Contrato.pas',
  Teste.Financeiro.MovimentacaoBancaria.Integracao in 'Teste.Financeiro.MovimentacaoBancaria.Integracao.pas',
  MaxxRuralApi.Financeiro.MovimentacaoBancaria.Types in '..\..\MaxxRuralApi\src\Domain\Financeiro\MaxxRuralApi.Financeiro.MovimentacaoBancaria.Types.pas',
  MaxxRuralApi.Controller.Financeiro.MovimentacaoBancaria.Json in '..\..\MaxxRuralApi\src\Controller\Financeiro\MaxxRuralApi.Controller.Financeiro.MovimentacaoBancaria.Json.pas',
  MaxxRuralApi.Model.DAO.Financeiro.MovimentacaoBancaria in '..\..\MaxxRuralApi\src\Model\DAO\MaxxRuralApi.Model.DAO.Financeiro.MovimentacaoBancaria.pas',
  MaxxRuralApi.Service.Financeiro.MovimentacaoBancaria in '..\..\MaxxRuralApi\src\Service\Financeiro\MaxxRuralApi.Service.Financeiro.MovimentacaoBancaria.pas',
  MaxxRuralApi.Model.DAO.Base in '..\..\MaxxRuralApi\src\Model\DAO\MaxxRuralApi.Model.DAO.Base.pas',
  MaxxRuralApi.Model.CFG in '..\..\MaxxRuralApi\src\Model\MaxxRuralApi.Model.CFG.pas',
  MaxxRural.Base.Consultas in '..\Consultas\MaxxRural.Base.Consultas.pas',
  Teste.MaxxRural.Base.Consultas in 'Teste.MaxxRural.Base.Consultas.pas',
  Teste.NFe.CamposTributarios in 'Teste.NFe.CamposTributarios.pas',
  Teste.StatusServicoNFe.Parser in 'Teste.StatusServicoNFe.Parser.pas',
  Teste.StatusServicoNFe.Coordinator in 'Teste.StatusServicoNFe.Coordinator.pas',
  Teste.StatusServicoNFe.LoadState in 'Teste.StatusServicoNFe.LoadState.pas',
  Teste.MovimentoBancarioNovo in 'Teste.MovimentoBancarioNovo.pas',
  Teste.MaxxRural.CEP in 'Teste.MaxxRural.CEP.pas',
  Teste.Relatorio.FiltrosDependentes in 'Teste.Relatorio.FiltrosDependentes.pas',
  Teste.PlacaVeiculo in 'Teste.PlacaVeiculo.pas',
  Teste.MovimentoBancario.MVC in 'Teste.MovimentoBancario.MVC.pas',
  Teste.MovimentoBancario.Saldos in 'Teste.MovimentoBancario.Saldos.pas',
  Teste.MovimentoBancario.Grids in 'Teste.MovimentoBancario.Grids.pas',
  Teste.MovimentoBancario.Lancamentos in 'Teste.MovimentoBancario.Lancamentos.pas',
  TestSupport.DACDBGridActions in 'TestSupport.DACDBGridActions.pas',
  Teste.MovimentoBancario.ColunasGrid in 'Teste.MovimentoBancario.ColunasGrid.pas',
  Teste.MovimentoBancario.AcoesGrid in 'Teste.MovimentoBancario.AcoesGrid.pas',
  Teste.Cadastros.Consulta in 'Teste.Cadastros.Consulta.pas',
  Entity.MovimentoBancario.Conta in '..\..\..\source\model\entity\Entity.MovimentoBancario.Conta.pas',
  DAO.MovimentoBancario.Conta in '..\..\..\source\model\dao\DAO.MovimentoBancario.Conta.pas',
  DAO.MovimentoBancario.Conta.Api in '..\..\..\source\model\dao\DAO.MovimentoBancario.Conta.Api.pas',
  Service.MovimentoBancario in '..\..\..\source\model\service\Service.MovimentoBancario.pas',
  View.MovimentoBancario.Datasets in '..\..\..\source\view\View.MovimentoBancario.Datasets.pas',
  Controller.MovimentoBancario in '..\..\..\source\controller\Controller.MovimentoBancario.pas',
  MaxxRural.CEP in '..\MaxxRural.CEP.pas',
  MaxxRural.Service.CEP in '..\Service\MaxxRural.Service.CEP.pas',
  uMovimentoBancarioNovoTypes in '..\..\MaxxFIN\uMovimentoBancarioNovoTypes.pas',
  uMovimentoBancarioNovoApi in '..\..\MaxxFIN\uMovimentoBancarioNovoApi.pas',
  uMovimentoBancarioNovoAdapters in '..\..\MaxxFIN\uMovimentoBancarioNovoAdapters.pas',
  uStatusServicoNFeTypes in '..\..\MaxxCOM\uStatusServicoNFeTypes.pas',
  uStatusServicoNFeService in '..\..\MaxxCOM\uStatusServicoNFeService.pas',
  uStatusServicoNFeCoordinator in '..\..\MaxxCOM\uStatusServicoNFeCoordinator.pas',
  uStatusServicoNFeLoadState in '..\..\MaxxCOM\uStatusServicoNFeLoadState.pas',
  uNFeCamposTributarios in '..\..\..\Geral\uNFeCamposTributarios.pas',
  uRelatorioFiltroMultiplo in '..\..\..\Geral\uRelatorioFiltroMultiplo.pas',
  uRelatorioFiltroDependencia in '..\..\..\Geral\uRelatorioFiltroDependencia.pas',
  uPlacaVeiculo in '..\..\..\Geral\uPlacaVeiculo.pas',
  DAO.Cadastro.ConsultaApi in '..\..\..\source\model\dao\DAO.Cadastro.ConsultaApi.pas',
  DTO.Cadastro in '..\..\..\source\model\entity\DTO.Cadastro.pas',
  MaxxRuralApi.Cadastros.Json in '..\..\MaxxRuralApi\src\Domain\Cadastros\MaxxRuralApi.Cadastros.Json.pas',
  MaxxRuralApi.Model.DAO.Cadastros.Consulta in '..\..\MaxxRuralApi\src\Model\DAO\MaxxRuralApi.Model.DAO.Cadastros.Consulta.pas',
  MaxxRuralApi.Service.Cadastros.Consulta in '..\..\MaxxRuralApi\src\Service\Cadastros\MaxxRuralApi.Service.Cadastros.Consulta.pas',
  Entity.MovimentoBancario.Saldos in '..\..\..\source\model\entity\Entity.MovimentoBancario.Saldos.pas',
  DAO.MovimentoBancario.Saldos in '..\..\..\source\model\dao\DAO.MovimentoBancario.Saldos.pas',
  DAO.MovimentoBancario.Saldos.Api in '..\..\..\source\model\dao\DAO.MovimentoBancario.Saldos.Api.pas',
  Entity.MovimentoBancario.Lancamentos in '..\..\..\source\model\entity\Entity.MovimentoBancario.Lancamentos.pas',
  DAO.MovimentoBancario.Lancamentos in '..\..\..\source\model\dao\DAO.MovimentoBancario.Lancamentos.pas',
  DAO.MovimentoBancario.Lancamentos.Api in '..\..\..\source\model\dao\DAO.MovimentoBancario.Lancamentos.Api.pas';

var
  runner : ITestRunner;
  results : IRunResults;
  logger : ITestLogger;
  nunitLogger : ITestLogger;
begin
{$IFDEF TESTINSIGHT}
  TestInsight.DUnitX.RunRegisteredTests;
  exit;
{$ENDIF}
  try
    //Check command line options, will exit if invalid
    TDUnitX.CheckCommandLine;
    //Create the test runner
    runner := TDUnitX.CreateRunner;
    //Tell the runner to use RTTI to find Fixtures
    runner.UseRTTI := True;
    //tell the runner how we will log things
    //Log to the console window
    logger := TDUnitXConsoleLogger.Create(true);
    runner.AddLogger(logger);
    //Generate an NUnit compatible XML File
    nunitLogger := TDUnitXXMLNUnitFileLogger.Create(TDUnitX.Options.XMLOutputFile);
    runner.AddLogger(nunitLogger);
    runner.FailsOnNoAsserts := True;

    //Run tests
    results := runner.Execute;
    if not results.AllPassed then
      System.ExitCode := EXIT_ERRORS;

  except
    on E: Exception do
    begin
      System.Writeln(E.ClassName, ': ', E.Message);
      System.ExitCode := EXIT_ERRORS;
    end;
  end;
end.
