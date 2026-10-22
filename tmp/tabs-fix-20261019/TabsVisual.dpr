program DACComponentsTabs;

{$APPTYPE CONSOLE}

uses
  System.Classes, System.SysUtils, System.Types, System.Math,
  Winapi.Windows, Winapi.Messages, Winapi.CommCtrl,
  Vcl.Controls, Vcl.Forms, Vcl.Graphics, Vcl.ComCtrls, Vcl.StdCtrls,
  DAC.Components.Controls.Tabs,
  DAC.Components.DesignSystem.ComponentStyle,
  DAC.Components.DesignSystem.Theme;

type
  TComponentAccess = class(TComponent)
    procedure Design;
  end;
  TTabsAccess = class(TDACTabs)
    procedure Recreate;
  end;

procedure TComponentAccess.Design;
begin
  SetDesigning(True, True);
end;

procedure TTabsAccess.Recreate;
begin
  RecreateWnd;
end;

procedure Require(Condition: Boolean; const Message: string);
begin
  if not Condition then raise Exception.Create(Message);
end;

function Header(Tabs: TDACTabs): TDACTabHeaderControl;
var I: Integer;
begin
  Result := nil;
  for I := 0 to Tabs.ControlCount - 1 do
    if Tabs.Controls[I] is TDACTabHeaderControl then
      Exit(TDACTabHeaderControl(Tabs.Controls[I]));
end;

procedure AddPage(Tabs: TDACTabs; const Caption: string);
var Page: TTabSheet;
begin
  Page := TTabSheet.Create(Tabs.Owner);
  Page.Caption := Caption;
  Page.PageControl := Tabs;
end;

procedure Pump;
var I: Integer;
begin
  for I := 1 to 8 do Application.ProcessMessages;
end;

procedure CheckCaptions(Tabs: TDACTabs);
var
  Layout: TDACTabLayout;
  B: TBitmap;
  I: Integer;
  R: TRect;
begin
  Require(Header(Tabs) <> nil, 'Header ausente.');
  Layout := Header(Tabs).BuildTabLayout;
  Require(Length(Layout) = Tabs.PageCount, 'Pagina ausente do layout.');
  B := TBitmap.Create;
  try
    B.Canvas.Font.Name := TDACComponentStyle.FontFamily;
    case Tabs.Size of
      mtsSmall: B.Canvas.Font.Height := -12;
      mtsLarge: B.Canvas.Font.Height := -16;
    else B.Canvas.Font.Height := -14;
    end;
    B.Canvas.Font.Style := [fsBold];
    for I := 0 to High(Layout) do
    begin
      R := Rect(0, 0, Floor(Layout[I].TextBounds.Width), 0);
      DrawText(B.Canvas.Handle, PChar(Tabs.Pages[Layout[I].PageIndex].Caption),
        -1, R, DT_CALCRECT or DT_WORDBREAK or DT_NOPREFIX);
      Require(R.Height <= Ceil(Layout[I].TextBounds.Height),
        'Caption sem altura suficiente: ' + Tabs.Pages[Layout[I].PageIndex].Caption);
      Require(R.Width <= Ceil(Layout[I].TextBounds.Width),
        'Caption sem largura suficiente: ' + Tabs.Pages[Layout[I].PageIndex].Caption);
    end;
  finally B.Free; end;
end;

procedure TestParentless;
var T: TDACTabs;
begin
  T := TDACTabs.Create(nil);
  try
    TComponentAccess(T).Design;
    T.Size := mtsLarge;
    T.TabHeight := 52;
    T.TabWidth := 140;
    T.Orientation := mtoVertical;
    T.ThemeMode := dtmDark;
    T.RefreshContentLayout;
    Require(not T.HandleAllocated, 'Parent=nil criou HWND.');
  finally T.Free; end;
  Writeln('Parent=nil / setters / designer: PASS');
end;

procedure TestStandaloneStreaming;
var
  TextStream: TStringStream;
  BinaryStream: TMemoryStream;
  T: TDACTabs;
  F: TForm;
begin
  System.Classes.RegisterClass(TDACTabs);
  System.Classes.RegisterClass(TTabSheet);
  TextStream := TStringStream.Create(
    'object Tabs: TDACTabs' + sLineBreak +
    '  Width = 520' + sLineBreak + '  Height = 240' + sLineBreak +
    '  TabHeight = 44' + sLineBreak + '  TabWidth = 132' + sLineBreak +
    '  ActiveIndex = 0' + sLineBreak +
    '  object First: TTabSheet' + sLineBreak + '    Caption = ''Geral''' + sLineBreak + '  end' + sLineBreak +
    '  object Second: TTabSheet' + sLineBreak + '    Caption = ''Detalhes''' + sLineBreak + '  end' + sLineBreak +
    'end');
  BinaryStream := TMemoryStream.Create;
  T := nil;
  F := TForm.Create(nil);
  try
    ObjectTextToBinary(TextStream, BinaryStream);
    BinaryStream.Position := 0;
    T := BinaryStream.ReadComponent(nil) as TDACTabs;
    Require((T.Parent = nil) and not T.HandleAllocated,
      'Streaming standalone deixou HWND antes de receber Parent.');
    Require((T.PageCount = 2) and (T.ActiveIndex = 0), 'Streaming perdeu paginas/selecao.');
    T.Parent := F;
    F.Show;
    Pump;
    T.RefreshContentLayout;
    Require(Header(T).Showing, 'Header sumiu depois do streaming.');
    Require(Header(T).Height = 52, 'TabHeight do DFM nao foi aplicado.');
    Require(SendMessage(T.Handle, TCM_GETITEMCOUNT, 0, 0) = T.PageCount,
      'Streaming divergiu da lista nativa.');
    BinaryStream.Clear;
    BinaryStream.WriteComponent(T);
    Writeln('DFM standalone / paginas nativas / TabHeight: PASS');
  finally
    T.Free;
    F.Free;
    BinaryStream.Free;
    TextStream.Free;
  end;
end;

procedure TestDesignerAndRuntime(Designing: Boolean);
var
  F: TForm;
  T: TDACTabs;
  H: TDACTabHeaderControl;
  L: TLabel;
  Size: TDACTabSize;
  Appearance: TDACTabAppearance;
  NativeCount: Integer;
begin
  F := TForm.Create(nil);
  try
    if Designing then TComponentAccess(F).Design;
    F.SetBounds(40, 40, 900, 650);
    T := TDACTabs.Create(F);
    if Designing then TComponentAccess(T).Design;
    T.Parent := F;
    T.SetBounds(24, 24, 600, 300);
    AddPage(T, 'Geral'); AddPage(T, 'Detalhes'); AddPage(T, 'Historico');
    T.ActiveIndex := 0;
    F.Show;
    Pump;
    T.RefreshContentLayout;
    H := Header(T);
    Writeln('Design=', Designing, ' H=', H <> nil, ' TabsShowing=', T.Showing, ' TabsHandle=', T.HandleAllocated);
    if H <> nil then Writeln('Header visible=', H.Visible, ' showing=', H.Showing, ' handle=', H.HandleAllocated, ' bounds=', H.Left, ',', H.Top, ',', H.Width, ',', H.Height);
    Require((H <> nil) and H.Visible and H.HandleAllocated,
      'Header invisivel depois de inserir o componente.');
    Require(H.Parent = T, 'Header escapou para o formulario.');
    Require(H.Height = 48, 'Altura MD divergente entre designer e runtime.');
    T.ActivePageHeaderOnly := True;
    T.RefreshContentLayout;
    Require((Length(H.BuildTabLayout) = 1) and H.Showing,
      'Modo de cabecalho da galeria perdeu a pagina ativa.');
    T.ActivePageHeaderOnly := False;
    T.Visible := False;
    Pump;
    Require(not H.Showing, 'Header permaneceu visivel com o componente oculto.');
    T.Visible := True;
    Pump;
    T.RefreshContentLayout;
    Require(H.Showing, 'Header nao retornou ao mostrar o componente.');
    L := TLabel.Create(F);
    L.Parent := T.Pages[0];
    L.SetBounds(20, 20, 180, 40);
    L.Caption := 'Conteudo';
    for Size := Low(Size) to High(Size) do
      for Appearance := Low(Appearance) to High(Appearance) do
      begin
        T.Size := Size;
        T.Appearance := Appearance;
        T.ThemeMode := dtmDark;
        T.RefreshContentLayout;
        CheckCaptions(T);
        T.ActiveIndex := 1;
        CheckCaptions(T);
        T.ThemeMode := dtmLight;
        T.RefreshContentLayout;
        CheckCaptions(T);
        T.ActiveIndex := 0;
      end;
    T.Size := mtsMedium;
    T.Appearance := mtaUnderline;
    AddPage(T, 'Configuracoes e permissoes do usuario');
    T.Pages[1].Caption := 'Informacoes complementares e integracoes';
    T.Width := 260;
    Pump;
    T.RefreshContentLayout;
    Require(H.Height > 48, 'Captions longas foram comprimidas em uma linha.');
    CheckCaptions(T);
    T.Width := 600;
    T.Orientation := mtoVertical;
    Pump;
    T.RefreshContentLayout;
    CheckCaptions(T);
    Require((L.Left = 20) and (L.Top = 20), 'Layout alterou coordenadas DFM dos filhos.');
    Require(T.Pages[0].Left >= H.Width, 'Pagina sobrepos header vertical.');
    T.TabHeight := 60;
    T.RefreshContentLayout;
    Require(Header(T).BuildTabLayout[0].Bounds.Height >= 60, 'TabHeight sem efeito.');
    TTabsAccess(T).Recreate;
    Pump;
    T.RefreshContentLayout;
    Require(Header(T).Visible and Header(T).HandleAllocated, 'RecreateWnd perdeu header.');
    NativeCount := SendMessage(T.Handle, TCM_GETITEMCOUNT, 0, 0);
    Require(NativeCount = T.PageCount, 'Lista nativa divergiu das paginas.');
    Writeln('Designer=', Designing, ': altura, 4 appearances, 3 sizes, temas, textos longos, resize, RecreateWnd: PASS');
  finally F.Free; end;
end;

procedure ShowVisual;
const Captions: array[0..3] of string = ('Underline', 'Pills', 'Filled', 'Segmented');
var
  F: TForm;
  T: TDACTabs;
  L: TLabel;
  I: Integer;
begin
  F := TForm.Create(nil);
  F.Caption := 'TDACTabs - validacao visual';
  F.SetBounds(40, 40, 1100, 820);
  F.Color := $00172410;
  for I := 0 to 3 do
  begin
    L := TLabel.Create(F); L.Parent := F;
    L.SetBounds(24, 12 + I * 180, 400, 20);
    L.Caption := Captions[I]; L.Font.Color := clWhite;
    T := TDACTabs.Create(F); T.Parent := F;
    T.SetBounds(24, 36 + I * 180, 640, 144);
    T.Appearance := TDACTabAppearance(I);
    T.ThemeMode := dtmDark;
    AddPage(T, 'Visao geral'); AddPage(T, 'Historico'); AddPage(T, 'Configuracoes');
    T.ActiveIndex := 0;
  end;
  T := TDACTabs.Create(F); T.Parent := F;
  TComponentAccess(T).Design;
  T.SetBounds(700, 36, 350, 320);
  T.ThemeMode := dtmDark;
  T.Orientation := mtoVertical;
  AddPage(T, 'Geral'); AddPage(T, 'Detalhes'); AddPage(T, 'Configuracoes e permissoes');
  T.ActiveIndex := 0;
  L := TLabel.Create(F); L.Parent := F;
  L.SetBounds(700, 12, 350, 20); L.Caption := 'Designer simulado / vertical'; L.Font.Color := clWhite;
  F.Show;
  Application.Run;
  F.Free;
end;

begin
  try
    Application.Initialize;
    TDACThemeManager.SetApplicationMode(dtmDark);
    if True then ShowVisual
    else
    begin
      TestParentless;
      TestStandaloneStreaming;
      TestDesignerAndRuntime(False);
      TestDesignerAndRuntime(True);
      Writeln('DACComponentsTabs: PASS');
    end;
  except
    on E: Exception do
    begin
      Writeln('DACComponentsTabs: FAIL: ', E.ClassName, ': ', E.Message);
      ExitCode := 1;
    end;
  end;
end.



