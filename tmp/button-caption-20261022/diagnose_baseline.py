from pathlib import Path
import subprocess,hashlib
r=Path(r'M:\Delphi Componentes\DAC-DelphiComponents')
tmp=r/'tmp/button-caption-20261022'
p=r/'Source/Controls/DAC.Components.Controls.Button.pas'
final=p.read_bytes(); (tmp/'button.final.pas').write_bytes(final)
before=(tmp/'button.before.pas').read_bytes().decode('cp1252')
text=final.decode('cp1252')
header=text[:text.index('\r\nimplementation\r\n')]
body=before[before.index('\r\nimplementation\r\n'):]
body=body.replace('function TDACButton.CanvasBackground(','''function TDACButton.CaptionFontFamily: string;
begin Result := TDACComponentFontInstaller.FontFamily; end;

function TDACButton.CaptionFontBold: Boolean;
begin Result := ResolvedTokens.ButtonCaptionBold; end;

procedure TDACButton.CMFontChanged(var AMessage: TMessage);
begin inherited; end;

function TDACButton.CanvasBackground('''.replace('\n','\r\n'),1)
baseline=(header+body).encode('cp1252')
consumer=Path(r'M:\MaxxSoft\MaxxRural\Desktop\maxxrural')
out=consumer/'MaxxRural/src/Tests/Resultados/20261022-button-caption'
p.write_bytes(baseline)
try:
    with (out/'build-baseline.log').open('wb') as log:
        build=subprocess.run(['cmd.exe','/d','/c',str(out/'compilar.cmd')],stdout=log,stderr=subprocess.STDOUT,cwd=r)
    if build.returncode: raise RuntimeError('Baseline build failed; see build-baseline.log')
    with (out/'baseline-estrutura.log').open('wb') as log:
        result=subprocess.run([str(consumer/'EXE/ApiTestes.exe'),
          '--run:Teste.ImportacaoOFX.Estrutura.TImportacaoOFXEstruturaTests',
          '--exit:Continue','--xml:'+str(out/'baseline-estrutura.xml')],stdout=log,stderr=subprocess.STDOUT,cwd=r)
    print('Baseline structural fixture exit:',result.returncode)
finally:
    if p.read_bytes()!=baseline:
        raise RuntimeError('Button source changed concurrently; final source preserved in button.final.pas')
    p.write_bytes(final)
    print('Final button implementation restored:',hashlib.sha256(p.read_bytes()).hexdigest())
