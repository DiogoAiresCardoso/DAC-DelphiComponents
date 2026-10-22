from pathlib import Path
root=Path(r'M:\MaxxSoft\MaxxRural\Desktop\maxxrural')
def read(p): return p.read_bytes().decode('cp1252').replace('\r\n','\n')
def write(p,s): p.write_bytes(s.replace('\n','\r\n').encode('cp1252'))
p=root/'source/view/View.MovimentoBancario.dfm'
s=read(p)
assert s.count('              LayoutKey = ')==36
s=s.replace('              LayoutKey = ', '              AllowFocus = False\n              LayoutKey = ')
write(p,s)
p=root/'MaxxRural/src/Tests/Teste.MovimentoBancario.ColunasGrid.pas'
s=read(p)
s=s.replace('    [Test] procedure NumerosNulos', '''    [Test] procedure AllowFocusNavegacaoMouseETeclado;
    [Test] procedure AllowFocusSelecaoLinhaEAcoes;
    [Test] procedure AllowFocusNaoDesenhaContornoIndividual;
    [Test] procedure NumerosNulos''',1)
s=s.replace('    Assert.AreEqual(16, Other.Columns[0].MinWidth);', '    Assert.IsTrue(Other.Columns[0].AllowFocus, \'DFM antigo preserva foco.\');\n    C(\'N\').AllowFocus := False;\n    Assert.AreEqual(16, Other.Columns[0].MinWidth);',1)
s=s.replace("    Assert.AreEqual('Numero completo', Other.Columns[0].Hint);", "    Assert.IsFalse(Other.Columns[0].AllowFocus, 'Assign preserva AllowFocus.');\n    Assert.AreEqual('Numero completo', Other.Columns[0].Hint);",1)
s=s.replace("    Assert.AreEqual('Ordenar numero', Other.Columns[0].TitleHint);", "    Assert.IsFalse(Other.Columns[0].AllowFocus, 'Streaming preserva AllowFocus.');\n    Assert.AreEqual('Ordenar numero', Other.Columns[0].TitleHint);",1)
s=s.replace('  G.SetTestPPI(PPI);\n  if Tema = 0 then G.ThemeMode', '  G.SetTestPPI(PPI);\n  G.SetBounds(8, 8, 660, 360);\n  if Tema = 0 then G.ThemeMode',1)
idx=s.index('initialization')
s=s[:idx]+'''procedure TMovimentoBancarioColunasGridTests.AllowFocusNavegacaoMouseETeclado;
var Key: string;
begin
  G.RowSelectionEnabled := False;
  C('DT').AllowFocus := False;
  G.SelectedIndex := C('N').Index;
  G.PressKey(VK_RIGHT); Assert.AreEqual(C('VAL').Index, G.SelectedIndex);
  G.PressKey(VK_LEFT); Assert.AreEqual(C('N').Index, G.SelectedIndex);
  G.PressKey(VK_TAB); Assert.AreEqual(C('VAL').Index, G.SelectedIndex);
  G.PressKey(VK_TAB, [ssShift]); Assert.AreEqual(C('N').Index, G.SelectedIndex);
  Key := D.FieldByName('MOV_COD').AsString;
  G.ClickAt(G.BoundsOf(C('DT').Index, 1).CenterPoint);
  Assert.AreEqual(C('N').Index, G.SelectedIndex, 'Coluna bloqueada nao recebe foco.');
  Assert.AreNotEqual(Key, D.FieldByName('MOV_COD').AsString, 'Linha ainda deve selecionar.');
  C('N').AllowFocus := False;
  G.PressKey(VK_HOME); Assert.AreEqual(C('VAL').Index, G.SelectedIndex);
  C('OPCOES').AllowFocus := False;
  G.PressKey(VK_END); Assert.AreEqual(C('LONG').Index, G.SelectedIndex);
  G.PressKey(VK_TAB); Assert.AreEqual(C('VAL').Index, G.SelectedIndex);
  G.PressKey(VK_TAB, [ssShift]); Assert.AreEqual(C('LONG').Index, G.SelectedIndex);
  C('DT').Index := 3; G.PressKey(VK_HOME);
  Assert.AreEqual(C('VAL').Index, G.SelectedIndex, 'Restricao segue o objeto movido.');
  C('VAL').Visible := False; G.PressKey(VK_HOME);
  Assert.AreEqual(C('TXT').Index, G.SelectedIndex, 'Ocultas tambem sao ignoradas.');
end;

procedure TMovimentoBancarioColunasGridTests.AllowFocusSelecaoLinhaEAcoes;
var I: Integer; Key: string;
begin
  for I := 0 to G.Columns.Count - 1 do G.Columns[I].AllowFocus := False;
  G.RowSelectionEnabled := True;
  G.ClickAt(G.BoundsOf(0, 1).CenterPoint);
  Key := D.FieldByName('MOV_COD').AsString;
  G.PressKey(VK_DOWN);
  Assert.AreNotEqual(Key, D.FieldByName('MOV_COD').AsString);
  Key := D.FieldByName('MOV_COD').AsString;
  C('OPCOES').Index := 0;
  G.PressKey(VK_F2); G.PressKey(VK_RETURN); G.ReleaseKey(VK_RETURN);
  Assert.AreEqual(1, G.Activations);
  Assert.AreEqual(Key, VarToStr(G.LastContext.ValueOf('MOV_COD')));
  Assert.AreEqual('detalhes', G.LastContext.ActionId);
  G.PressKey(VK_ESCAPE);
  G.ClickAt(G.ActionRect(0, G.CurrentVisibleRow, 1).CenterPoint);
  Assert.AreEqual(2, G.Activations); Assert.AreEqual('editar', G.LastContext.ActionId);
  G.RowSelectionEnabled := False;
  G.PressKey(VK_RIGHT); G.PressKey(VK_TAB); // No eligible cell: do not loop or move the record.
  Assert.AreEqual(Key, D.FieldByName('MOV_COD').AsString);
  G.PressKey(VK_DOWN); Assert.AreNotEqual(Key, D.FieldByName('MOV_COD').AsString);
end;

procedure TMovimentoBancarioColunasGridTests.AllowFocusNaoDesenhaContornoIndividual;
var B: TBitmap; R: TRect; Border: TColor;
begin
  G.RowSelectionEnabled := True; G.SelectedIndex := 0;
  G.Perform(CM_MOUSELEAVE, 0, 0);
  B := TBitmap.Create;
  try
    B.SetSize(G.Width, G.Height); G.PaintTo(B.Canvas.Handle, 0, 0);
    R := G.BoundsOf(0, G.CurrentVisibleRow);
    Border := B.Canvas.Pixels[R.Left + 1, R.CenterPoint.Y];
    G.Columns[0].AllowFocus := False; G.PaintTo(B.Canvas.Handle, 0, 0);
    Assert.AreNotEqual(Border, B.Canvas.Pixels[R.Left + 1, R.CenterPoint.Y]);
    Assert.AreEqual(B.Canvas.Pixels[R.Left + 5, R.Top + 5],
      B.Canvas.Pixels[R.Left + 1, R.CenterPoint.Y], 'Selecao da linha permanece, sem caixa individual.');
  finally B.Free; end;
end;

'''+s[idx:]
write(p,s)
p=root/'MaxxRural/src/Tests/Teste.MovimentoBancario.InputGrid.pas'
s=read(p).replace("      G.Layout.Enabled := False;", "      G.Layout.Enabled := False;\n      for I := 0 to G.Columns.Count - 1 do\n        Assert.IsFalse(G.Columns[I].AllowFocus, 'DFM real deve selecionar a linha sem foco individual.');",1)
write(p,s)
