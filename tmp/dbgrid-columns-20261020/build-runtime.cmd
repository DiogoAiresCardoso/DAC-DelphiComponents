@echo off
call "C:\Program Files (x86)\Embarcadero\Studio\19.0\bin\rsvars.bat"
"C:\Windows\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe" "Package/DACSkiaComponents.dproj" /t:Rebuild /p:MainSource=DACSkiaComponentsRuntime.dpk /p:SanitizedProjectName=DACSkiaComponentsRuntime /p:Config=Debug /p:Platform=Win32 /p:DCC_DcuOutput="M:\Delphi Componentes\DAC-DelphiComponents/tmp/dbgrid-columns-20261020/runtime-dcu" /p:DCC_ExeOutput="M:\Delphi Componentes\DAC-DelphiComponents/tmp/dbgrid-columns-20261020/runtime-exe" /p:DCC_BplOutput="M:\Delphi Componentes\DAC-DelphiComponents/tmp/dbgrid-columns-20261020/runtime-bpl" /p:DCC_DcpOutput="M:\Delphi Componentes\DAC-DelphiComponents/tmp/dbgrid-columns-20261020/runtime-dcp" /p:DAC_ProvenanceOutput="M:\Delphi Componentes\DAC-DelphiComponents/tmp/dbgrid-columns-20261020/runtime-provenance" /v:minimal /nologo



