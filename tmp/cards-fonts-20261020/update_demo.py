from pathlib import Path
root=Path(r'M:\Delphi Componentes\DAC-DelphiComponents')
p=root/'demo/Demo.Principal.pas'
raw=p.read_bytes()
(root/'tmp/cards-fonts-20261020/Demo.Principal.before.pas').write_bytes(raw)
s=raw.decode('utf-8-sig').replace('\r\n','\n')
needle='    btnUploadAction: TDACButton;'
assert needle in s
s=s.replace(needle,needle+'\n    procedure CardTypographyClick(Sender: TObject);',1)
a=s.index('procedure TForm1.ThemeToggleClick(')
s=s[:a]+'''procedure TForm1.CardTypographyClick(Sender: TObject);
var
  Card: TDACSummaryCard;
  Button: TDACButton;
  Tokens: TDACControlTokens;
begin
  Card := FindComponent('demoSummaryCard') as TDACSummaryCard;
  if (Card = nil) or not (Sender is TDACButton) then Exit;
  Button := TDACButton(Sender);
  if Button.Tag = 0 then
  begin
    Tokens := TDACComponentStyle.Resolve(TDACThemeManager.ApplicationMode).Tokens.Controls;
    Card.TitleFont.Size := 14;
    Card.TitleFont.Style := [fsItalic];
    Card.ValueFont.Size := 30;
    Card.ValueFont.Style := [fsBold, fsUnderline];
    Card.FooterFont.Size := 12;
    Card.FooterFont.Style := [fsItalic];
    Card.FooterFont.Color := TDACComponentColors.ToVclColor(Tokens.SummaryCardDanger);
    Button.Caption := 'Restaurar fontes do card';
    Button.Tag := 1;
  end
  else
  begin
    Card.ResetTextFonts;
    Card.Height := 100;
    Button.Caption := 'Alterar fontes em runtime';
    Button.Tag := 0;
  end;
end;

'''+s[a:]
p.write_bytes(s.replace('\n','\r\n').encode('utf-8'))

p=root/'demo/Demo.Principal.dfm'
raw=p.read_bytes()
(root/'tmp/cards-fonts-20261020/Demo.Principal.before.dfm').write_bytes(raw)
s=raw.decode('utf-8-sig').replace('\r\n','\n')
a=s.index('      object demoSummaryCard: TDACSummaryCard')
b=s.index('    object tsStatus: TTabSheet',a)
s=s[:a]+'''      object btnCardTypography: TDACButton
        Left = 24
        Top = 56
        Width = 260
        Height = 40
        Caption = 'Alterar fontes em runtime'
        TabOrder = 0
        OnClick = CardTypographyClick
      end
      object demoSummaryCard: TDACSummaryCard
        Left = 24
        Top = 112
        Width = 360
        Height = 100
        Title = 'Saldo da conta'
        Value = 'R$ 555.920,56'
        FooterText = 'No inicio do periodo'
        Status = mcsNeutral
        TabOrder = 1
      end
      object demoCardCustomFonts: TDACSummaryCard
        Left = 408
        Top = 112
        Width = 360
        Height = 140
        Title = 'Saidas - fontes definidas no DFM'
        Value = 'R$ -10,00'
        FooterText = 'Rodape personalizado, independente do status'
        Status = mcsDanger
        TitleFont.Size = 11
        TitleFont.Style = [fsItalic]
        ValueFont.Size = 20
        ValueFont.Style = [fsBold]
        ValueFont.Color = clMaroon
        FooterFont.Size = 10
        FooterFont.Style = [fsUnderline]
        FooterFont.Color = clGray
        TabOrder = 2
      end
    end
'''+s[b:]
p.write_bytes(s.replace('\n','\r\n').encode('utf-8'))
