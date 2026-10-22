from pathlib import Path
import shutil
root=Path(r'M:\MaxxSoft\MaxxRural\Desktop\maxxrural')
tests=root/'MaxxRural/src/Tests'
ev=tests/'Resultados/20261021-grid-scroll-focus'
ev.mkdir(exist_ok=True)
for n in ['compilar.cmd','compilar-desktop.cmd','executar-testes.ps1']:
    shutil.copyfile(tests/'Resultados/20261021-grid-input'/n,ev/n)
p=tests/'Teste.MovimentoBancario.InputGrid.pas'
s=p.read_bytes().decode('cp1252')
s=s.replace('FirstLeft: Integer;', 'FirstLeft, RowLimit: Integer;')
s=s.replace('      for I := 1 to 80 do', "      RowLimit := 80;\r\n      if GetEnvironmentVariable('DAC_GRID_NATIVE_QA_ROWS') = '2' then RowLimit := 2;\r\n      for I := 1 to RowLimit do")
s=s.replace("' foco=' + BoolToStr(G.Focused, True);", "' foco=' + BoolToStr(G.Focused, True) + ' acoes=' + IntToStr(F.Activations);")
p.write_bytes(s.encode('cp1252'))
