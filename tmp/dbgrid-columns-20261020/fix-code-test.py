from pathlib import Path
p=Path(r'M:/MaxxSoft/MaxxRural/Desktop/maxxrural/MaxxRural/src/Tests/Teste.MovimentoBancario.ColunasGrid.pas');s=p.read_bytes().decode('cp1252').replace('\r\n','\n');s=s.replace('var Previous, Current: string;','var Previous, Current: string; I: Integer;\nconst Codes: array[0..6] of string = (\'2\',\'10\',\'100\',\'002\',\'0002\',\'010\',\'01\');');a=s.index("  D.First; D.Edit; D.FieldByName('CODE')",s.index('procedure TMovimentoBancarioColunasGridTests.TextosAcentuados'));z=s.index('\nend;',a);s=s[:a]+'''  G.RequestSort(C('TXT').Index, dgsNone);
  D.First;
  for I := 0 to High(Codes) do
  begin D.Edit; D.FieldByName('CODE').AsString := Codes[I]; D.Post; D.Next; end;
  G.RequestSort(C('CODE').Index, dgsAscending);
  Assert.AreEqual('0002|002|01|010|10|100|2', Sequence('CODE'));'''+s[z:];p.write_bytes(s.replace('\n','\r\n').encode('cp1252'))
