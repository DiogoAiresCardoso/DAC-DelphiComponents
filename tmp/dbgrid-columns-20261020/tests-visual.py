from pathlib import Path
p=Path(r'M:/MaxxSoft/MaxxRural/Desktop/maxxrural/MaxxRural/src/Tests/Teste.MovimentoBancario.ColunasGrid.pas');s=p.read_bytes().decode('cp1252').replace('\r\n','\n');s=s.replace("Assert.IsTrue(Pos('0002|002|010', Sequence('CODE')) > 0);", "Assert.IsTrue(Pos('0002|002|010', Sequence('CODE')) > 0, Sequence('CODE'));").replace("Assert.IsTrue(Pos('002|010', Sequence('CODE')) > 0);", "Assert.IsTrue(Pos('002|010', Sequence('CODE')) > 0, Sequence('CODE'));")
s=s.replace('C(\'OPCOES\').Sortable := False;', "C('OPCOES').Title.Caption := 'Opcoes'; C('OPCOES').Sortable := False;")
s=s.replace('G.ThemeMode := TDACThemeMode(Tema);', 'if Tema = 1 then G.ThemeMode := dtmLight else G.ThemeMode := dtmDark;')
s=s.replace("G.ResetLayout; Assert.AreEqual(0, C('N').Index); Assert.AreEqual(108, C('N').Width);", "G.ResetLayout; Assert.AreEqual(0, C('N').Index); Assert.AreEqual(108, C('N').Width);\n  Assert.AreEqual(dgsNone, G.SortDirection); Assert.AreEqual('', D.IndexName);")
s=s.replace('    Png.Assign(B); FileName :=', '''    Png.Assign(B); FileName :=''',1)
needle='    // Narrow viewport: incomplete actions must never escape their cell/viewport.'
s=s.replace(needle,'''    G.PressKey(VK_ESCAPE);
    G.RequestSort(C('N').Index, dgsAscending); D.First;
    G.MoveAt(G.HeaderPoint(C('N').Index)); G.PaintTo(B.Canvas.Handle, 0, 0);
    Png.Assign(B); Png.SaveToFile(ExtractFilePath(ParamStr(0)) + Format('dbgrid-columns-header-%d-%d.png', [PPI, Tema]));
    G.MoveAt(G.BoundsOf(C('DT').Index, 1).CenterPoint); G.PaintTo(B.Canvas.Handle, 0, 0);
    Png.Assign(B); Png.SaveToFile(ExtractFilePath(ParamStr(0)) + Format('dbgrid-columns-cell-%d-%d.png', [PPI, Tema]));
'''+needle)
p.write_bytes(s.replace('\n','\r\n').encode('cp1252'))
