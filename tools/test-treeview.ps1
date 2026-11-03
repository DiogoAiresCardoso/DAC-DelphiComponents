param(
    [string]$BdsRoot = 'C:\Program Files (x86)\Embarcadero\Studio\19.0',
    [string]$SkiaRoot = 'M:\Delphi Componentes\Skia4Delphi',
    [switch]$SkipPackages,
    [switch]$SkipRegression,
    [switch]$Physical
)
$ErrorActionPreference = 'Stop'
& (Join-Path $PSScriptRoot 'test-dbtreeview.ps1') -BdsRoot $BdsRoot -SkiaRoot $SkiaRoot `
    -SkipPackages:$SkipPackages -SkipRegression:$SkipRegression -OutputDirectory 'Build\TreeView' -Physical:$Physical
