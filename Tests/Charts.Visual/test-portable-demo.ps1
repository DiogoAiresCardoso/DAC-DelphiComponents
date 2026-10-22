param(
    [Parameter(Mandatory=$true)][string]$Distribution,
    [string]$Report = 'tmp/chart-portable-fix/portable-results.json'
)
$ErrorActionPreference = 'Stop'
$distributionPath = (Resolve-Path -LiteralPath $Distribution).Path
$probeRoot = Join-Path ([IO.Path]::GetTempPath()) ('DACCharts-portable-test-' + [guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $probeRoot | Out-Null
$results = @()

function Invoke-Probe([string]$Name, [string]$Fixture, [string]$DllMode, [int]$ExpectedCode, [string]$ExpectedError) {
    $folder = Join-Path $probeRoot $Name
    New-Item -ItemType Directory -Path $folder | Out-Null
    Copy-Item -LiteralPath (Join-Path $distributionPath 'DACChartsDemo.exe') -Destination $folder
    if ($DllMode -eq 'valid') {
        Copy-Item -LiteralPath (Join-Path $distributionPath 'sk4d.dll') -Destination $folder
    } elseif ($DllMode -eq 'invalid') {
        [IO.File]::WriteAllText((Join-Path $folder 'sk4d.dll'), 'not a Windows library')
    }
    if ($Fixture -eq 'valid') {
        Copy-Item -LiteralPath (Join-Path $distributionPath 'reference-cases.json') -Destination $folder
    } elseif ($Fixture -ne 'missing') {
        [IO.File]::WriteAllText((Join-Path $folder 'reference-cases.json'), $Fixture, [Text.Encoding]::UTF8)
    }
    # Start from another empty folder: EXE-local data must not depend on the CWD.
    $cwd = Join-Path $folder 'unrelated-cwd'
    New-Item -ItemType Directory -Path $cwd | Out-Null
    $output = Join-Path $folder 'captures'
    $start = New-Object Diagnostics.ProcessStartInfo
    $start.FileName = Join-Path $folder 'DACChartsDemo.exe'
    $start.Arguments = '--out "' + $output + '" --case all --buffer-only'
    $start.WorkingDirectory = $cwd
    $start.UseShellExecute = $false
    $start.WindowStyle = [Diagnostics.ProcessWindowStyle]::Hidden
    $start.EnvironmentVariables['PATH'] = "$env:SystemRoot\System32;$env:SystemRoot"
    $process = [Diagnostics.Process]::Start($start)
    if (-not $process.WaitForExit(20000)) {
        $process.Kill()
        throw "$Name hung during startup (possibly a modal error or partial form)"
    }
    $code = $process.ExitCode
    $process.Dispose()
    if ($code -ne $ExpectedCode) { throw "$Name exit code $code, expected $ExpectedCode" }
    if ($code -eq 0) {
        if ((Get-Content -LiteralPath (Join-Path $output 'result.txt') -Raw).Trim() -ne 'OK') { throw "$Name missing OK" }
        $cases = (Get-Content -LiteralPath (Join-Path $folder 'reference-cases.json') -Raw | ConvertFrom-Json).cases
        foreach ($case in $cases) {
            foreach ($suffix in @('.png','.json')) {
                if (-not (Test-Path -LiteralPath (Join-Path $output ($case.id + $suffix)))) { throw "Missing $($case.id)$suffix" }
            }
        }
        if (Test-Path -LiteralPath (Join-Path $output 'error.txt')) { throw 'Unexpected error file' }
    } else {
        $errorText = Get-Content -LiteralPath (Join-Path $output 'error.txt') -Raw -Encoding UTF8
        if ($errorText -notlike "*$ExpectedError*") { throw "$Name unexpected error: $errorText" }
        if ($errorText -match 'EAccessViolation') { throw "$Name still produces access violation" }
    }
    [pscustomobject]@{name=$Name; exitCode=$code; passed=$true; directory=$folder}
}

$results += Invoke-Probe 'valid' 'valid' 'valid' 0 ''
$results += Invoke-Probe 'missing-dll' 'valid' 'missing' 1 'sk4d.dll nao encontrada'
$results += Invoke-Probe 'invalid-dll' 'valid' 'invalid' 1 'Falha ao carregar'
$results += Invoke-Probe 'missing-fixtures' 'missing' 'valid' 1 'Arquivo de cenarios nao encontrado'
$results += Invoke-Probe 'malformed-json' '{' 'valid' 1 'objeto raiz'
$results += Invoke-Probe 'missing-cases' '{}' 'valid' 1 'cases deve ser um array'
$results += Invoke-Probe 'wrong-cases-type' '{"cases":{}}' 'valid' 1 'cases deve ser um array'
$results += Invoke-Probe 'empty-cases' '{"cases":[]}' 'valid' 1 'cases nao pode estar vazio'
$results += Invoke-Probe 'missing-option' '{"cases":[{"id":"C01","title":"Test"}]}' 'valid' 1 'option objeto'
$results += Invoke-Probe 'invalid-option' '{"cases":[{"id":"C01","title":"Test","option":{"legend":{"orient":"vertcal"}}}]}' 'valid' 1 'orient'
$reportPath = [IO.Path]::GetFullPath($Report)
[IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($reportPath)) | Out-Null
@{distribution=$distributionPath; tempRoot=$probeRoot; tests=$results; capture='buffers_only_not_physical_flicker'} |
    ConvertTo-Json -Depth 5 | Set-Content -LiteralPath $reportPath -Encoding UTF8
$results | Format-Table name,exitCode,passed
Write-Output "Report: $reportPath"
