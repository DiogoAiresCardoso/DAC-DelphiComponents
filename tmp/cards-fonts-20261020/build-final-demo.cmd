@echo off
call "C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\rsvars.bat"
"C:\Windows\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe" "demo/Demo.dproj" /t:Build /p:Config=Debug /p:Platform=Win32 /p:DCC_DcuOutput="M:\Delphi Componentes\DAC-DelphiComponents/tmp/cards-fonts-20261020/final-demo-dcu" /p:DCC_ExeOutput="M:\Delphi Componentes\DAC-DelphiComponents/tmp/cards-fonts-20261020/final-demo-exe" /p:DCC_BplOutput="M:\Delphi Componentes\DAC-DelphiComponents/tmp/cards-fonts-20261020/final-demo-bpl" /p:DCC_DcpOutput="M:\Delphi Componentes\DAC-DelphiComponents/tmp/cards-fonts-20261020/final-demo-dcp" /p:DAC_ProvenanceOutput="M:\Delphi Componentes\DAC-DelphiComponents/tmp/cards-fonts-20261020/final-demo-provenance" /v:minimal /nologo






