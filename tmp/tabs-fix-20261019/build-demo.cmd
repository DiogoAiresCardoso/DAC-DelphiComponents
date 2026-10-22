@echo off
call "C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\rsvars.bat"
"C:\Windows\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe" "demo/Demo.dproj" /t:Build /p:Config=Debug /p:Platform=Win32 /p:DCC_DcuOutput="M:\Delphi Componentes\DAC-DelphiComponents/tmp/tabs-fix-20261019/main-demo-dcu" /p:DCC_ExeOutput="M:\Delphi Componentes\DAC-DelphiComponents/tmp/tabs-fix-20261019/main-demo-exe" /p:DCC_BplOutput="M:\Delphi Componentes\DAC-DelphiComponents/tmp/tabs-fix-20261019/main-demo-bpl" /p:DCC_DcpOutput="M:\Delphi Componentes\DAC-DelphiComponents/tmp/tabs-fix-20261019/main-demo-dcp" /p:DAC_ProvenanceOutput="M:\Delphi Componentes\DAC-DelphiComponents/tmp/tabs-fix-20261019/main-demo-provenance" /v:minimal /nologo


