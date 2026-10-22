from pathlib import Path
root=Path(r'M:\MaxxSoft\MaxxRural\Desktop\maxxrural\MaxxRural\src\Tests')
def read(p): return p.read_bytes().decode('cp1252').replace('\r\n','\n')
def write(p,s): p.write_bytes(s.replace('\n','\r\n').encode('cp1252'))
p=root/'Teste.MovimentoBancario.InputGrid.pas'
s=read(p).replace("if GetEnvironmentVariable('DAC_GRID_NATIVE_QA_ROWS') = '2' then RowLimit := 2;", "if (Page = 0) and (GetEnvironmentVariable('DAC_GRID_NATIVE_QA_ROWS') = '2') then RowLimit := 2;")
write(p,s)
p=root/'Teste.MovimentoBancario.ColunasGrid.pas'
s=read(p)
s=s.replace("  G.PressKey(VK_END); Assert.AreEqual(C('LONG').Index, G.SelectedIndex);\n  G.PressKey(VK_TAB);", "  G.PressKey(VK_END); Assert.AreEqual(C('LONG').Index, G.SelectedIndex);\n  Key := D.FieldByName('MOV_COD').AsString;\n  G.PressKey(VK_TAB);")
s=s.replace("  G.PressKey(VK_TAB); Assert.AreEqual(C('VAL').Index, G.SelectedIndex);\n  G.PressKey(VK_TAB, [ssShift]); Assert.AreEqual(C('LONG').Index, G.SelectedIndex);", "  G.PressKey(VK_TAB); Assert.AreEqual(C('VAL').Index, G.SelectedIndex);\n  Assert.AreNotEqual(Key, D.FieldByName('MOV_COD').AsString, 'Tab na borda avanca registro.');\n  G.PressKey(VK_TAB, [ssShift]); Assert.AreEqual(C('LONG').Index, G.SelectedIndex);\n  Assert.AreEqual(Key, D.FieldByName('MOV_COD').AsString, 'Shift+Tab na borda volta registro.');\n  G.PressKey(VK_LEFT, [ssCtrl]); Assert.AreEqual(C('VAL').Index, G.SelectedIndex);\n  G.PressKey(VK_RIGHT, [ssCtrl]); Assert.AreEqual(C('LONG').Index, G.SelectedIndex);")
s=s.replace("  G.PressKey(VK_DOWN); Assert.AreNotEqual(Key, D.FieldByName('MOV_COD').AsString);\nend;\n\nprocedure TMovimentoBancarioColunasGridTests.AllowFocusNao", "  G.PressKey(VK_DOWN); Assert.AreNotEqual(Key, D.FieldByName('MOV_COD').AsString);\n  G.PressKey(VK_F2); G.PressKey(VK_RETURN); G.ReleaseKey(VK_RETURN);\n  Assert.AreEqual(3, G.Activations, 'Botao acessivel mesmo sem nenhuma celula focalizavel.');\nend;\n\nprocedure TMovimentoBancarioColunasGridTests.AllowFocusNao")
write(p,s)
