program DACSummaryCardFonts;

{$APPTYPE CONSOLE}

uses
  System.Classes, System.SysUtils, System.Types, System.Math,
  Winapi.Windows,
  Vcl.Controls, Vcl.Forms, Vcl.Graphics, Vcl.Imaging.pngimage,
  DAC.Components.Controls.SummaryCard,
  DAC.Components.DesignSystem.ColorTokens,
  DAC.Components.DesignSystem.ComponentStyle,
  DAC.Components.DesignSystem.Theme;

type
  TComponentAccess = class(TComponent)
    procedure Design;
  end;

procedure TComponentAccess.Design;
begin
  SetDesigning(True, True);
end;

procedure Require(Condition: Boolean; const Message: string);
begin
  if not Condition then raise Exception.Create(Message);
end;

procedure Pump;
var I: Integer;
begin
  for I := 1 to 6 do Application.ProcessMessages;
end;

procedure CheckLayout(Card: TDACSummaryCard);
var L: TDACSummaryCardTextLayout;
begin
  L := Card.TextLayout;
  Require((L.TitleBounds.Left = L.ValueBounds.Left) and
    (L.ValueBounds.Left = L.FooterBounds.Left), 'Textos sem alinhamento a esquerda.');
  Require((L.TitleBounds.Right = L.ValueBounds.Right) and
    (L.ValueBounds.Right = L.FooterBounds.Right), 'Textos com larguras diferentes.');
  Require(L.TitleBounds.Bottom <= L.ValueBounds.Top, 'Titulo sobrepos valor.');
  Require(L.ValueBounds.Bottom <= L.FooterBounds.Top, 'Valor sobrepos rodape.');
  Require(L.FooterBounds.Bottom <= Card.Height, 'Rodape cortado.');
  Require(L.RequiredHeight <= Card.Height, 'Altura automatica nao foi aplicada.');
  Require(StringReplace(L.TitleText, sLineBreak, '', [rfReplaceAll]) = Card.Title,
    'Titulo perdeu caracteres.');
  Require(StringReplace(L.ValueText, sLineBreak, '', [rfReplaceAll]) = Card.Value,
    'Valor perdeu caracteres.');
  Require(StringReplace(L.FooterText, sLineBreak, '', [rfReplaceAll]) = Card.FooterText,
    'Rodape perdeu caracteres.');
end;

procedure TestParentless;
var Card: TDACSummaryCard;
begin
  Card := TDACSummaryCard.Create(nil);
  try
    TComponentAccess(Card).Design;
    Card.TitleFont.Size := 18;
    Card.ValueFont.Size := 28;
    Card.FooterFont.Style := [fsItalic, fsUnderline];
    Card.FooterFont.Color := clRed;
    Card.Width := 210;
    Card.ThemeMode := dtmDark;
    CheckLayout(Card);
    Require(not Card.HandleAllocated, 'Fontes forcaram HWND com Parent=nil.');
    Card.ResetTextFonts;
    Require(Card.FooterFont.Color = clDefault, 'Reset nao restaurou cor automatica.');
  finally Card.Free; end;
  Writeln('Parent=nil / designer / fontes / reset: PASS');
end;

procedure TestStreaming;
var
  Card, CopyCard: TDACSummaryCard;
  Binary: TMemoryStream;
  Text: TStringStream;
begin
  System.Classes.RegisterClass(TDACSummaryCard);
  Card := TDACSummaryCard.Create(nil);
  Binary := TMemoryStream.Create;
  Text := TStringStream.Create;
  CopyCard := nil;
  try
    Binary.WriteComponent(Card);
    Binary.Position := 0;
    ObjectBinaryToText(Binary, Text);
    Require(Pos('TitleFont.', Text.DataString) = 0, 'DFM padrao gravou fonte customizada.');
    Card.TitleFont.Name := 'Courier New';
    Card.TitleFont.Size := 14;
    Card.TitleFont.Style := [fsBold, fsItalic];
    Card.ValueFont.Size := 24;
    Card.ValueFont.Color := clBlue;
    Card.FooterFont.Style := [fsUnderline, fsStrikeOut];
    Card.FooterFont.Color := clRed;
    Binary.Clear;
    Binary.WriteComponent(Card);
    Binary.Position := 0;
    CopyCard := Binary.ReadComponent(nil) as TDACSummaryCard;
    Require(CopyCard.TitleFont.Name = Card.TitleFont.Name, 'DFM perdeu familia.');
    Require(CopyCard.TitleFont.Size = 14, 'DFM perdeu tamanho.');
    Require(CopyCard.TitleFont.Style = [fsBold, fsItalic], 'DFM perdeu estilos do titulo.');
    Require(CopyCard.ValueFont.Color = clBlue, 'DFM perdeu cor do valor.');
    Require(CopyCard.ValueFont.Size = 24, 'DFM perdeu tamanho do valor.');
    Require(CopyCard.FooterFont.Style = [fsUnderline, fsStrikeOut], 'DFM perdeu estilos do rodape.');
    Require(CopyCard.FooterFont.Color = clRed, 'DFM perdeu cor do rodape.');
    Require(CopyCard.TitleFont.Color = clDefault, 'DFM congelou cor automatica.');
    Require(not CopyCard.HandleAllocated, 'DFM standalone criou HWND.');
    CheckLayout(CopyCard);
  finally
    CopyCard.Free; Card.Free; Binary.Free; Text.Free;
  end;
  Writeln('DFM antigo/default e novas fontes: PASS');
end;

function CountColor(Bitmap: TBitmap; const Bounds: TRect; Color: TColor): Integer;
var X, Y: Integer;
begin
  Result := 0;
  for Y := Max(0, Bounds.Top) to Min(Bitmap.Height, Bounds.Bottom) - 1 do
    for X := Max(0, Bounds.Left) to Min(Bitmap.Width, Bounds.Right) - 1 do
      if Bitmap.Canvas.Pixels[X, Y] = ColorToRGB(Color) then Inc(Result);
end;

procedure TestAlignedBankCards;
const
  Titles: array[0..3] of string = ('Saldo inicial', 'Entradas', 'Saidas', 'Saldo no sistema');
  Values: array[0..3] of string = ('R$ 555.920,56', 'R$ 0,00', 'R$ -10,00', 'R$ 555.910,56');
  Footers: array[0..3] of string = ('No inicio do periodo', 'No periodo selecionado',
    'No periodo selecionado', 'Ao final do periodo');
var
  F: TForm;
  Cards: array[0..3] of TDACSummaryCard;
  B: TBitmap;
  P: TPngImage;
  I: Integer;
  L, First: TDACSummaryCardTextLayout;
begin
  F := TForm.Create(nil);
  B := TBitmap.Create;
  P := TPngImage.Create;
  try
    F.ClientWidth := 1072;
    F.ClientHeight := 132;
    for I := 0 to 3 do
    begin
      Cards[I] := TDACSummaryCard.Create(F);
      Cards[I].Parent := F;
      Cards[I].Title := Titles[I];
      Cards[I].Value := Values[I];
      Cards[I].FooterText := Footers[I];
      Cards[I].ThemeMode := dtmLight;
      Cards[I].ValueFont.Size := 14;
      if I = 2 then Cards[I].Status := mcsDanger
      else if I = 1 then Cards[I].Status := mcsSuccess;
      Cards[I].SetBounds(16 + I * 264, 16, 248, 100);
      CheckLayout(Cards[I]);
      L := Cards[I].TextLayout;
      if I = 0 then First := L
      else
        Require((L.TitleBounds.Top = First.TitleBounds.Top) and
          (L.ValueBounds.Top = First.ValueBounds.Top) and
          (L.FooterBounds.Top = First.FooterBounds.Top),
          'Cards equivalentes com linhas em alturas diferentes.');
    end;
    F.Show;
    Pump;
    B.PixelFormat := pf24bit;
    B.SetSize(F.ClientWidth, F.ClientHeight);
    B.Canvas.Brush.Color := clWhite;
    B.Canvas.FillRect(Rect(0, 0, B.Width, B.Height));
    for I := 0 to 3 do Cards[I].PaintTo(B.Canvas.Handle, Cards[I].Left, Cards[I].Top);
    P.Assign(B);
    P.SaveToFile(ExtractFilePath(ParamStr(0)) + 'cards-aligned.png');
  finally P.Free; B.Free; F.Free; end;
  Writeln('Alinhamento titulo / valor / rodape e conjunto de cards: PASS');
end;

procedure TestRuntime;
var
  F: TForm;
  Card: TDACSummaryCard;
  B: TBitmap;
  P: TPngImage;
  L: TDACSummaryCardTextLayout;
  I, PreviousHeight: Integer;
  Output: string;
begin
  F := TForm.Create(nil);
  try
    F.SetBounds(20, 20, 900, 760);
    Card := TDACSummaryCard.Create(F);
    Card.Parent := F;
    Card.SetBounds(24, 24, 360, 110);
    Card.Title := 'Saldo da conta';
    Card.Value := 'R$ 555.920,56';
    Card.FooterText := 'No inicio do periodo';
    F.Show;
    Pump;
    PreviousHeight := Card.Height;
    Card.TitleFont.Size := 18;
    Card.TitleFont.Color := clBlue;
    Card.TitleFont.Style := [fsItalic];
    Card.ValueFont.Size := 30;
    Card.ValueFont.Color := clRed;
    Card.ValueFont.Style := [fsBold, fsUnderline];
    Card.FooterFont.Size := 14;
    Card.FooterFont.Color := clGreen;
    Card.FooterFont.Style := [fsItalic];
    Require(Card.Height > PreviousHeight, 'Fontes maiores nao ampliaram a altura.');
    for I := 0 to 3 do
    begin
      if Odd(I) then Card.ThemeMode := dtmDark else Card.ThemeMode := dtmLight;
      Card.Status := TDACSummaryCardStatus(I);
      Card.Appearance := TDACSummaryCardAppearance(I mod 3);
      Pump;
      CheckLayout(Card);
      Require(Card.TitleFont.Color = clBlue, 'Tema perdeu cor do titulo.');
      Require(Card.ValueFont.Color = clRed, 'Tema perdeu cor do valor.');
      Require(Card.FooterFont.Color = clGreen, 'Status perdeu override do rodape.');
      Require(Card.TitleFont.Style = [fsItalic], 'Tema perdeu estilo.');
      Require(Card.ValueFont.Size = 30, 'Tema perdeu tamanho.');
    end;
    B := TBitmap.Create;
    P := TPngImage.Create;
    try
      B.PixelFormat := pf24bit;
      B.SetSize(Card.Width, Card.Height);
      Card.PaintTo(B.Canvas.Handle, 0, 0);
      L := Card.TextLayout;
      Require(CountColor(B, L.TitleBounds, clBlue) > 0, 'Cor nativa do titulo nao foi desenhada.');
      Require(CountColor(B, L.ValueBounds, clRed) > 0, 'Cor nativa do valor nao foi desenhada.');
      Require(CountColor(B, L.FooterBounds, clGreen) > 0, 'Cor nativa do rodape nao foi desenhada.');
      Output := ExtractFilePath(ParamStr(0)) + 'card-runtime-fonts.png';
      P.Assign(B);
      P.SaveToFile(Output);
      Writeln('CAPTURE ', Output);
      Card.FooterFont.Color := clFuchsia;
      Pump;
      Card.PaintTo(B.Canvas.Handle, 0, 0);
      Require(CountColor(B, Card.TextLayout.FooterBounds, clFuchsia) > 0,
        'Mudanca de cor em runtime nao redesenhou.');
      Card.FooterFont.Color := clDefault;
      Card.Status := mcsDanger;
      Card.ThemeMode := dtmLight;
      Pump;
      Card.PaintTo(B.Canvas.Handle, 0, 0);
      Require(CountColor(B, Card.TextLayout.FooterBounds,
        TDACComponentColors.ToVclColor(TDACComponentStyle.Resolve(dtmLight).
          Tokens.Controls.SummaryCardDanger)) > 0,
        'clDefault nao restaurou a cor semantica do rodape.');
    finally P.Free; B.Free; end;
    Card.Title := 'ConfiguracoesDeContaSemEspacosNemSeparadores';
    Card.Width := 180;
    Pump;
    CheckLayout(Card);
    Card.AutoTextHeight := False;
    Card.Height := 90;
    Card.ValueFont.Size := 36;
    Require(Card.Height = 90, 'AutoTextHeight=False nao preservou altura fixa.');
    Card.AutoTextHeight := True;
    CheckLayout(Card);
    Card.ResetTextFonts;
    Require(Card.TitleFont.Color = clDefault, 'Reset titulo falhou.');
    Require(Card.ValueFont.Color = clDefault, 'Reset valor falhou.');
    Require(Card.FooterFont.Color = clDefault, 'Reset rodape falhou.');
  finally F.Free; end;
  Writeln('Runtime / temas / status / layout / pixels / redraw: PASS');
end;

begin
  try
    Application.Initialize;
    TestParentless;
    TestStreaming;
    TestRuntime;
    TestAlignedBankCards;
    Writeln('DACSummaryCardFonts: PASS');
  except
    on E: Exception do
    begin
      Writeln('DACSummaryCardFonts: FAIL: ', E.ClassName, ': ', E.Message);
      ExitCode := 1;
    end;
  end;
end.
