@echo off
call "C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\rsvars.bat"
"C:\Windows\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe" "Tests/DACDemoStartup.dproj" /t:Build /p:Config=Debug /p:Platform=Win32 /p:DCC_DcuOutput="M:\Delphi Componentes\DAC-DelphiComponents/tmp/cards-fonts-20261020/DACDemoStartup-dcu" /p:DCC_ExeOutput="M:\Delphi Componentes\DAC-DelphiComponents/tmp/cards-fonts-20261020/DACDemoStartup-exe" /p:DCC_BplOutput="M:\Delphi Componentes\DAC-DelphiComponents/tmp/cards-fonts-20261020/DACDemoStartup-bpl" /p:DCC_DcpOutput="M:\Delphi Componentes\DAC-DelphiComponents/tmp/cards-fonts-20261020/DACDemoStartup-dcp" /p:DAC_ProvenanceOutput="M:\Delphi Componentes\DAC-DelphiComponents/tmp/cards-fonts-20261020/DACDemoStartup-provenance" /p:DAC_SkiaRuntimeSource="M:\Delphi Componentes\Build\EXE\sk4d.dll" /v:minimal /nologo






