param(
    [string]$Output = 'tmp/chart-validation',
    [string]$EChartsScript = '',
    [string]$Python = 'python',
    [string]$Node = 'node',
    [string]$Delphi = 'C:\Program Files (x86)\Embarcadero\Studio\19.0'
)
$ErrorActionPreference = 'Stop'
$chartRoot = (Resolve-Path (Join-Path $PSScriptRoot '..\..')).Path
$chartOutput = [IO.Path]::GetFullPath((Join-Path $chartRoot $Output))
if (Test-Path (Join-Path $chartOutput 'demo-captures')) { throw 'Output already contains evidence; choose a new -Output directory.' }
New-Item -ItemType Directory -Force -Path $chartOutput | Out-Null
if (!$EChartsScript) { $EChartsScript = Join-Path $PSScriptRoot 'node_modules\echarts\dist\echarts.min.js' }
$EChartsScript = (Resolve-Path $EChartsScript).Path
$fixtures = Join-Path $PSScriptRoot 'fixtures.json'
Push-Location $chartRoot
try {
    foreach ($target in @(@('tests','Tests\DACComponentsCharts.dproj'), @('demo','demo-charts\DACChartsDemo.dproj'))) {
        $exeOutput = Join-Path $chartOutput ($target[0]+'-exe')
        $dcuOutput = Join-Path $chartOutput ($target[0]+'-dcu')
        $cmd = '@echo off' + "`r`n" + 'call "' + (Join-Path $Delphi 'bin\rsvars.bat') + '"' + "`r`n" +
            '"C:\Windows\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe" "' + $target[1] + '" /t:Build /p:Config=Debug /p:Platform=Win32 /p:DCC_DcuOutput="' + $dcuOutput + '" /p:DCC_ExeOutput="' + $exeOutput + '" /v:minimal /nologo'
        $batch = Join-Path $chartOutput ('build-'+$target[0]+'.cmd')
        [IO.File]::WriteAllText($batch,$cmd,[Text.Encoding]::Default)
        & cmd /c $batch | Tee-Object -FilePath (Join-Path $chartOutput ('build-'+$target[0]+'.log'))
        if ($LASTEXITCODE -ne 0) { throw "Build $($target[0]) failed" }
    }
    & (Join-Path $chartOutput 'tests-exe\DACComponentsCharts.exe') $fixtures (Join-Path $chartOutput 'unit-captures') | Tee-Object -FilePath (Join-Path $chartOutput 'tests.log')
    if ($LASTEXITCODE -ne 0) { throw 'Delphi assertions failed' }
    & $Node (Join-Path $PSScriptRoot 'capture-reference.cjs') $fixtures $EChartsScript (Join-Path $chartOutput 'reference')
    if ($LASTEXITCODE -ne 0) { throw 'Reference capture failed' }
    & (Join-Path $chartOutput 'demo-exe\DACChartsDemo.exe') --fixtures $fixtures --out (Join-Path $chartOutput 'demo-captures') --case all --stress | Out-Null
    if ($LASTEXITCODE -ne 0) { throw 'Demo execution failed' }
    & $Python (Join-Path $PSScriptRoot 'compare.py') (Join-Path $chartOutput 'reference') (Join-Path $chartOutput 'demo-captures')
    $comparisonExit = $LASTEXITCODE
    & $Python (Join-Path $PSScriptRoot 'analyze-frames.py') (Join-Path $chartOutput 'demo-captures\frames')
    if ($LASTEXITCODE -ne 0) { throw 'Incomplete buffer sequence' }
    if ($comparisonExit -ne 0) { throw 'Comparison failed: inspect geometry, textContent and textClipping in comparison.json.' }
    Write-Output "Evidence: $chartOutput. Visual and temporal approval must be reviewed separately."
} finally { Pop-Location }
