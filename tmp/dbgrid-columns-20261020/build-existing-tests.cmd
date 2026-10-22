@echo off
call "C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\rsvars.bat"
"C:\Windows\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe" "Tests/DACDBGridTests.dproj" /t:Rebuild /p:Config=Debug /p:Platform=Win32 /p:DCC_DcuOutput="M:\Delphi Componentes\DAC-DelphiComponents\tmp\dbgrid-columns-20261020\tests-dcu" /p:DCC_ExeOutput="M:\Delphi Componentes\DAC-DelphiComponents\tmp\dbgrid-columns-20261020\tests-exe" /nologo /v:minimal
if errorlevel 1 exit /b %errorlevel%
set "PATH=M:\MaxxSoft\MaxxRural\Desktop\maxxrural\EXE;%PATH%"
"M:\Delphi Componentes\DAC-DelphiComponents\tmp\dbgrid-columns-20261020\tests-exe\DACDBGridTests.exe"
