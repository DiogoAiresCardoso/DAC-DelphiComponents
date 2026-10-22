@echo off
setlocal
call "C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\rsvars.bat"
if errorlevel 1 exit /b %errorlevel%
"C:\Windows\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe" "demo/Demo.dproj" /t:Rebuild /p:Config=Debug /p:Platform=Win32 /p:DCC_DcuOutput="M:\Delphi Componentes\DAC-DelphiComponents\tmp\button-caption-20261022\demo-dcu" /p:DCC_ExeOutput="M:\Delphi Componentes\DAC-DelphiComponents\tmp\button-caption-20261022\demo-exe" /p:DCC_BplOutput="M:\Delphi Componentes\DAC-DelphiComponents\tmp\button-caption-20261022\demo-bpl" /p:DCC_DcpOutput="M:\Delphi Componentes\DAC-DelphiComponents\tmp\button-caption-20261022\demo-dcp" /p:DAC_ProvenanceOutput="M:\Delphi Componentes\DAC-DelphiComponents\tmp\button-caption-20261022\demo-provenance" /p:DAC_SkiaRuntimeSource="M:\MaxxSoft\MaxxRural\Desktop\maxxrural\EXE\sk4d.dll" /v:minimal /nologo
exit /b %errorlevel%
