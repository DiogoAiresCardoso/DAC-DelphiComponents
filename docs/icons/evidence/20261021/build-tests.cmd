@echo off
setlocal
call "C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\rsvars.bat"
if errorlevel 1 exit /b %errorlevel%
"C:\Windows\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe" "Tests/DACComponentsInteraction.dproj" /t:Rebuild /p:Config=Debug /p:Platform=Win32 /p:DCC_DcuOutput="M:\Delphi Componentes\DAC-DelphiComponents\tmp\icons-expanded-20261021\tests-dcu" /p:DCC_ExeOutput="M:\Delphi Componentes\DAC-DelphiComponents\tmp\icons-expanded-20261021\tests-exe" /p:DAC_SkiaRuntimeSource="M:\MaxxSoft\MaxxRural\Desktop\maxxrural\EXE\sk4d.dll" /v:minimal /nologo
exit /b %errorlevel%
