param(
    [string]$BdsRoot = 'C:\Program Files (x86)\Embarcadero\Studio\19.0',
    [string]$SkiaRoot = 'M:\Delphi Componentes\Skia4Delphi',
    [switch]$SkipPackages,
    [switch]$SkipRegression
)
$ErrorActionPreference = 'Stop'
$repo = Split-Path -Parent $PSScriptRoot
$compiler = Join-Path $BdsRoot 'bin\dcc32.exe'
if (!(Test-Path -LiteralPath $compiler)) { throw "Compiler not found: $compiler" }
if (!(Test-Path -LiteralPath (Join-Path $SkiaRoot 'Source\System.Skia.pas'))) { throw 'Skia sources not found' }
$output = Join-Path $repo 'Build\DBTreeView'
$lib = Join-Path $BdsRoot 'lib\win32\release'
$sources = @('Core','DesignSystem','Skia','Controls','Hooks','DesignTime') | ForEach-Object { Join-Path $repo "Source\$_" }
$sources += (Join-Path $SkiaRoot 'Source'), (Join-Path $SkiaRoot 'Source\VCL')
$sources += (Join-Path $repo 'demo-db-treeview'), (Join-Path $repo 'demo')
$sourcePath = $sources -join ';'
New-Item -ItemType Directory -Force -Path $output | Out-Null

function Build-Target([string]$Source, [string]$Name, [string]$ExtraPath = '') {
    $target = Join-Path $output $Name
    $dcu = Join-Path $target 'dcu'
    New-Item -ItemType Directory -Force -Path $target,$dcu | Out-Null
    $unitPath = "$ExtraPath;$sourcePath;$lib"
    $args = @('-B','-Q','-$R+','-NSSystem;Xml;Data;Web;Soap;Vcl;Vcl.Imaging;Winapi',
        "-U$unitPath", "-I$(Join-Path $SkiaRoot 'Source')", "-NU$dcu", "-E$target",
        "-LE$target", "-LN$target", $Source)
    $lines = & $compiler @args 2>&1
    $code = $LASTEXITCODE
    $lines | Set-Content -LiteralPath (Join-Path $target 'build.log') -Encoding UTF8
    if ($code -ne 0) { $lines | Select-Object -Last 18 | Write-Host; throw "Build failed: $Name ($code)" }
    Write-Host "BUILD PASS $Name"
    return $target
}

function Run-Target([string]$Directory, [string]$ExeName, [string[]]$Arguments = @()) {
    $dll = Join-Path $SkiaRoot 'Binary\Shared\Win32\sk4d.dll'
    Copy-Item -LiteralPath $dll -Destination $Directory -Force
    $lines = & (Join-Path $Directory $ExeName) @Arguments 2>&1
    $code = $LASTEXITCODE
    $lines | Set-Content -LiteralPath (Join-Path $Directory 'results.log') -Encoding UTF8
    $lines | Write-Host
    if ($code -ne 0) { throw "Tests failed: $ExeName ($code)" }
}

Push-Location $repo
try {
    if (!$SkipPackages) {
        # Rebuild dependencies locally to avoid incompatible installed Skia DCUs.
        # No file in the installed Skia checkout or IDE configuration is modified.
        $skiaPackages = Join-Path $SkiaRoot 'Packages\RAD Studio 10.2 Tokyo'
        $rtlOut = Build-Target (Join-Path $skiaPackages 'Skia.Package.RTL.dpk') 'SkiaRTL'
        $depPath = "$rtlOut;$(Join-Path $rtlOut 'dcu')"
        $vclOut = Build-Target (Join-Path $skiaPackages 'Skia.Package.VCL.dpk') 'SkiaVCL' $depPath
        $depPath = "$vclOut;$(Join-Path $vclOut 'dcu');$depPath"
        $runtimeOut = Build-Target 'Package\DACSkiaComponentsRuntime.dpk' 'Runtime' $depPath
        $runtimePath = "$runtimeOut;$(Join-Path $runtimeOut 'dcu');$depPath"
        $null = Build-Target 'Package\DACSkiaComponentsDesign.dpk' 'Design' $runtimePath
        $null = Build-Target 'Package\DACSkiaComponents.dpk' 'Combined' $depPath
    }
    $testsOut = Build-Target 'Tests\DACDBTreeViewTests.dpr' 'Tests'
    Run-Target $testsOut 'DACDBTreeViewTests.exe'
    $painterOut = Build-Target 'Tests\DACDBTreeViewPainterTests.dpr' 'Painter'
    Run-Target $painterOut 'DACDBTreeViewPainterTests.exe' @((Join-Path $painterOut 'Evidence'))
    $resources = Join-Path $output 'Resources'
    New-Item -ItemType Directory -Force -Path $resources | Out-Null
    Push-Location (Join-Path $repo 'demo-db-treeview')
    try {
        & (Join-Path $BdsRoot 'bin\brcc32.exe') "-fo$(Join-Path $resources 'DACDBTreeViewDemo.res')" 'DACDBTreeViewDemo.rc' | Out-Null
        if ($LASTEXITCODE -ne 0) { throw 'Demo manifest compilation failed' }
    }
    finally { Pop-Location }
    $demoOut = Build-Target 'demo-db-treeview\DACDBTreeViewDemo.dpr' 'Demo'
    Copy-Item -LiteralPath (Join-Path $SkiaRoot 'Binary\Shared\Win32\sk4d.dll') -Destination $demoOut -Force
    $officialDemoOut = Build-Target 'demo\Demo.dpr' 'OfficialDemo'
    $officialDestination = Join-Path $repo 'Build\Exe\Win32\Debug'
    New-Item -ItemType Directory -Force -Path $officialDestination | Out-Null
    Copy-Item -LiteralPath (Join-Path $officialDemoOut 'Demo.exe') -Destination $officialDestination -Force
    Copy-Item -LiteralPath (Join-Path $SkiaRoot 'Binary\Shared\Win32\sk4d.dll') -Destination $officialDestination -Force
    if (!$SkipRegression) {
        foreach ($name in @('DACComponentsSmoke.Current','DACComponentsInteraction.Current','DACComponentsDesignLifecycle.Current','DACDemoStartup.Current')) {
            $regressionOut = Build-Target "Tests\$name.dpr" $name
            Run-Target $regressionOut "$name.exe"
        }
    }
    Write-Host "Outputs: $output"
}
finally { Pop-Location }
