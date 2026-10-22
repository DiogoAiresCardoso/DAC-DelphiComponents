from pathlib import Path
r=Path(r'M:\Delphi Componentes\DAC-DelphiComponents')
p=r/'Source/Controls/DAC.Components.Controls.DBGrid.pas'
s=p.read_bytes().decode('cp1252').replace('\r\n','\n')
s=s.replace('  Origin := CellRect(0, ARow);', '''  Origin := CellRect(LeftCol, ARow);
  if Origin.Bottom <= Origin.Top then
  begin
    Origin.Top := 0;
    for I := 0 to ARow - 1 do Inc(Origin.Top, RowHeights[I]);
    Origin.Bottom := Origin.Top + RowHeights[ARow];
  end;''',1)
s=s.replace('procedure TDACDBGrid.ChangeScale(M, D: Integer; isDpiChange: Boolean);\nbegin\n  inherited;\n  ThemeChanged(Self);\nend;', '''procedure TDACDBGrid.ChangeScale(M, D: Integer; isDpiChange: Boolean);
var I: Integer; Widths: TArray<Integer>;
begin
  SetLength(Widths, Columns.Count);
  for I := 0 to Columns.Count - 1 do Widths[I] := Columns[I].Width;
  inherited;
  // Frozen columns have zero native scroll width; scale their physical width.
  Columns.BeginUpdate;
  try
    for I := 0 to Min(Length(Widths), Columns.Count) - 1 do
      if Columns[I].PinPosition <> dgpNone then Columns[I].Width := MulDiv(Widths[I], M, D);
  finally Columns.EndUpdate; end;
  ThemeChanged(Self);
end;''',1)
# Native keyboard keeps the data-column anchor; navigation follows physical group order.
a=s.index('function TDACDBGrid.CanGridAcceptKey'); b=s.index('procedure TDACDBGrid.TopLeftChanged',a)
part=s[a:b]
part=part.replace('var I, Step, Target, NavKey: Integer;', 'var I, J, N, Current, Step, Target, NavKey: Integer;\n  Order: TArray<Integer>;\n  Sides: array[0..2] of TDACDBGridPinPosition;')
part=part.replace('  Target := SelectedIndex + Step;', '''  SetLength(Order, Columns.Count);
  Sides[0] := dgpLeft; Sides[1] := dgpNone; Sides[2] := dgpRight;
  N := 0; Current := 0;
  for J := 0 to 2 do
    for I := 0 to Columns.Count - 1 do
      if Columns[I].PinPosition = Sides[J] then
      begin
        Order[N] := I;
        if I = SelectedIndex then Current := N;
        Inc(N);
      end;
  Target := Current + Step;''',1)
part=part.replace('if Columns[Target].Visible and Columns[Target].AllowFocus then', 'if Columns[Order[Target]].Visible and Columns[Order[Target]].AllowFocus then')
part=part.replace('SelectDisplayColumn(Target);', 'SelectDisplayColumn(Order[Target]);')
s=s[:a]+part+s[b:]
p.write_bytes(s.replace('\n','\r\n').encode('cp1252'))
p=Path(r'M:\MaxxSoft\MaxxRural\Desktop\maxxrural\MaxxRural\src\Tests\Teste.MovimentoBancario.ColunasGrid.pas')
s=p.read_bytes().decode('cp1252')
s=s.replace("G.HiddenAction := 'detalhes'; Assert.AreEqual('Editar',G.HintAt(R.CenterPoint));", "G.HiddenAction := 'detalhes'; R := G.ActionRect(0,G.CurrentVisibleRow,1);\r\n  Assert.AreEqual('Editar',G.HintAt(R.CenterPoint));")
p.write_bytes(s.encode('cp1252'))
