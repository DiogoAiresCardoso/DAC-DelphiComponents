@echo off
call "C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\rsvars.bat"
"C:\Windows\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe" "Tests/DACComponentsTabs.dproj" /t:Build /p:Config=Debug /p:Platform=Win32 /p:DCC_DcuOutput="M:\Delphi Componentes\DAC-DelphiComponents/tmp/tabs-fix-20261019/visual-dcu" /p:DCC_ExeOutput="M:\Delphi Componentes\DAC-DelphiComponents/tmp/tabs-fix-20261019/visual-exe" /p:DCC_BplOutput="M:\Delphi Componentes\DAC-DelphiComponents/tmp/tabs-fix-20261019/visual-bpl" /p:DCC_DcpOutput="M:\Delphi Componentes\DAC-DelphiComponents/tmp/tabs-fix-20261019/visual-dcp" /p:DAC_ProvenanceOutput="M:\Delphi Componentes\DAC-DelphiComponents/tmp/tabs-fix-20261019/visual-provenance" /p:DAC_SkiaRuntimeSource="M:\Delphi Componentes\Build\EXE\sk4d.dll" /p:MainSource="M:\Delphi Componentes\DAC-DelphiComponents\tmp\tabs-fix-20261019\TabsVisual.dpr" /v:minimal /nologo





