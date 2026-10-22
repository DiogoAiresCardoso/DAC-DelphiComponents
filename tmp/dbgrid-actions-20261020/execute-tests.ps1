$ErrorActionPreference = 'Stop'
$evidenceRoot = $PSScriptRoot
$testDatabase = Join-Path $evidenceRoot ('SUITE-' + [guid]::NewGuid().ToString('N') + '.FDB')
if (Test-Path -LiteralPath $testDatabase) { throw 'O fixture exige um banco novo.' }
$previousDatabase = [Environment]::GetEnvironmentVariable('MOVIMENTACAO_BANCARIA_TEST_DB', 'Process')
try {
    $env:MOVIMENTACAO_BANCARIA_TEST_DB = $testDatabase
    & 'M:\MaxxSoft\MaxxRural\Desktop\maxxrural\EXE\ApiTestes.exe' '--exit:Continue' "--xml:$evidenceRoot\apitestes-todos.xml" *> "$evidenceRoot\apitestes-todos.log"
    $testExit = $LASTEXITCODE
} finally {
    [Environment]::SetEnvironmentVariable('MOVIMENTACAO_BANCARIA_TEST_DB', $previousDatabase, 'Process')
}
Get-Content -LiteralPath "$evidenceRoot\apitestes-todos.log" -Tail 12
exit $testExit
