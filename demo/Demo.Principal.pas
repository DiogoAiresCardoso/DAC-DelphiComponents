unit Demo.Principal;

interface

uses
  System.Classes,
  System.SysUtils,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Graphics,
  Vcl.StdCtrls,
  DAC.Components.Controls.Button,
  DAC.Components.Controls.GridContainer,
  DAC.Components.Controls.ScrollContainer,
  DAC.Components.Controls.Tabs,
  DAC.Components.DesignSystem.IconAssets;

type
  TForm1 = class(TForm)
  private
    FComponentTabs: TDACTabs;
    function CreateDemoTabPage(const ACaption: string): TDACGridContainer;
  procedure AddButtonSample(
      const AGrid: TDACGridContainer;
      const ACaption: string;
      const AKind: TDACButtonKind;
      const ASize: TDACButtonSize;
      const AEnabled: Boolean;
      const ALoading: Boolean;
      const AShowIcon: Boolean;
      const AIconPosition: TDACButtonIconPosition;
      const AIconKind: TDACIconKind;
      const ACornerRadius: Integer;
      const ASpan: Integer;
      const AIconSize: Integer = 0;
      const ATabStop: Boolean = True);
    procedure AddGridText(const AGrid: TDACGridContainer; const AText: string;
      const ASpan: Integer; const AFontSize: Integer = 9;
      const AFontStyle: TFontStyles = []);
    procedure AddGridSpacer(const AGrid: TDACGridContainer; const ASpan: Integer);
    function ButtonKindName(const AKind: TDACButtonKind): string;
    function ButtonSizeName(const ASize: TDACButtonSize): string;
    procedure BuildButtonsTab(const AGrid: TDACGridContainer);
    procedure BuildPlaceholderTab(const AGrid: TDACGridContainer;
      const ATitle: string; const ADescription: string);
    procedure BuildDemo;
  protected
    constructor Create(AOwner: TComponent); override;
  public
  end;

var
  Form1: TForm1;

implementation

{$R *.dfm}

constructor TForm1.Create(AOwner: TComponent);
begin
  inherited;
  BuildDemo;
end;

function TForm1.ButtonKindName(const AKind: TDACButtonKind): string;
begin
  case AKind of
    mbkPrimary:
      Result := 'Primary';
    mbkSecondary:
      Result := 'Secondary';
    mbkGhost:
      Result := 'Ghost';
    mbkWarning:
      Result := 'Warning';
    mbkDanger:
      Result := 'Danger';
    mbkTransparent:
      Result := 'Transparent';
    mbkInputAction:
      Result := 'InputAction';
  else
    Result := 'Button';
  end;
end;

function TForm1.ButtonSizeName(const ASize: TDACButtonSize): string;
begin
  case ASize of
    mbsSmall:
      Result := 'Small';
    mbsMedium:
      Result := 'Medium';
    mbsLarge:
      Result := 'Large';
  else
    Result := 'Auto';
  end;
end;

procedure TForm1.AddGridSpacer(const AGrid: TDACGridContainer; const ASpan: Integer);
var
  LSpacer: TLabel;
begin
  LSpacer := TLabel.Create(Self);
  LSpacer.Parent := AGrid;
  LSpacer.Tag := ASpan;
  LSpacer.Caption := ' ';
  LSpacer.AutoSize := False;
  LSpacer.WordWrap := False;
  LSpacer.Height := 12;
end;

procedure TForm1.AddGridText(const AGrid: TDACGridContainer; const AText: string;
  const ASpan: Integer; const AFontSize: Integer = 9;
  const AFontStyle: TFontStyles = []);
var
  LText: TLabel;
begin
  LText := TLabel.Create(Self);
  LText.Parent := AGrid;
  LText.Tag := ASpan;
  LText.Caption := AText;
  LText.AutoSize := False;
  LText.WordWrap := True;
  LText.Font.Size := AFontSize;
  LText.Font.Style := AFontStyle;
  LText.Layout := tlTop;
  LText.Alignment := taLeftJustify;
  LText.Margins.Top := 4;
  LText.Margins.Left := 4;
  LText.Margins.Bottom := 4;
end;

procedure TForm1.AddButtonSample(
  const AGrid: TDACGridContainer;
  const ACaption: string;
  const AKind: TDACButtonKind;
  const ASize: TDACButtonSize;
  const AEnabled: Boolean;
  const ALoading: Boolean;
  const AShowIcon: Boolean;
  const AIconPosition: TDACButtonIconPosition;
  const AIconKind: TDACIconKind;
  const ACornerRadius: Integer;
  const ASpan: Integer;
  const AIconSize: Integer = 0;
  const ATabStop: Boolean = True);
var
  LButton: TDACButton;
begin
  LButton := TDACButton.Create(Self);
  LButton.Parent := AGrid;
  LButton.Tag := ASpan;
  LButton.Caption := ACaption;
  LButton.Kind := AKind;
  LButton.Size := ASize;
  LButton.Enabled := AEnabled;
  LButton.Loading := ALoading;
  LButton.ShowIcon := AShowIcon;
  LButton.IconPosition := AIconPosition;
  LButton.CornerRadius := ACornerRadius;
  LButton.IconKind := AIconKind;
  LButton.IconSize := AIconSize;
  LButton.TabStop := ATabStop;
end;

function TForm1.CreateDemoTabPage(const ACaption: string): TDACGridContainer;
var
  LScrollContainer: TDACScrollContainer;
begin
  FComponentTabs.Items.Add.Caption := ACaption;

  LScrollContainer := TDACScrollContainer.Create(Self);
  LScrollContainer.Parent := FComponentTabs;
  LScrollContainer.Align := alClient;
  LScrollContainer.BorderStyle := bsNone;
  LScrollContainer.BackgroundColor := $00000000;
  LScrollContainer.BorderColor := $00000000;
  LScrollContainer.CornerRadius := 0;
  LScrollContainer.ScrollBarMode := msbmAuto;
  LScrollContainer.AutoScroll := True;

  Result := TDACGridContainer.Create(Self);
  Result.Parent := LScrollContainer;
  Result.Align := alTop;
  Result.Anchors := [akLeft, akTop, akRight];
  Result.Columns := 12;
  Result.Gutter := 16;
  Result.ContentPadding := 16;
  Result.RowHeight := 84;
  Result.BackgroundColor := $00000000;
  Result.BorderColor := $00000000;
  Result.CornerRadius := 0;
end;

procedure TForm1.BuildButtonsTab(const AGrid: TDACGridContainer);
var
  LKind: TDACButtonKind;
  LSize: TDACButtonSize;
  LIndex: Integer;
  LIconKinds: array[0..3] of TDACIconKind;
begin
  AddGridText(AGrid, 'DEMO: TDACButton', 12, 12, [fsBold]);
  AddGridText(AGrid,
    'Cobertura completa de estados/propriedades: Kind, Size, Enabled, Loading, ShowIcon, IconPosition, IconKind, IconSize e CornerRadius.',
    12, 9, [fsItalic]);

  LIconKinds[0] := mikCheck;
  LIconKinds[1] := mikSearch;
  LIconKinds[2] := mikInfoCircle;
  LIconKinds[3] := mikArrowRight;

  for LKind := Low(TDACButtonKind) to High(TDACButtonKind) do
  begin
    AddGridText(AGrid, Format('Kind: %s', [ButtonKindName(LKind)]), 12, 11,
      [fsBold]);
    AddGridText(AGrid,
      'Conjunto de estados por tamanho para inspeção completa do botão.',
      12, 9, [fsItalic]);
    AddGridSpacer(AGrid, 12);

    for LSize := Low(TDACButtonSize) to High(TDACButtonSize) do
    begin
      LIndex := (Ord(LKind) * 3 + Ord(LSize)) mod 4;
      AddGridText(AGrid, Format('Tamanho: %s', [ButtonSizeName(LSize)]), 12, 10,
        [fsBold]);

      AddButtonSample(AGrid,
        Format('Texto apenas (%s)', [ButtonSizeName(LSize)]),
        LKind, LSize, True, False, False, mipLeft,
        mikCheck, 8, 4);

      AddButtonSample(AGrid,
        Format('Texto + ícone esquerdo (%s)', [ButtonSizeName(LSize)]),
        LKind, LSize, True, False, True, mipLeft,
        LIconKinds[LIndex], 8, 4);

      AddButtonSample(AGrid,
        Format('Texto + ícone direito (%s)', [ButtonSizeName(LSize)]),
        LKind, LSize, True, False, True, mipRight,
        LIconKinds[(LIndex + 1) mod 4], 8, 4);

      AddButtonSample(AGrid,
        Format('Apenas ícone (%s)', [ButtonSizeName(LSize)]),
        LKind, LSize, True, False, True, mipLeft,
        LIconKinds[(LIndex + 2) mod 4], 12, 3, 20);

      AddButtonSample(AGrid,
        Format('Loading = True (%s)', [ButtonSizeName(LSize)]),
        LKind, LSize, True, True, True, mipLeft,
        mikSpinner, 8, 4);

      AddButtonSample(AGrid,
        Format('Disabled (%s)', [ButtonSizeName(LSize)]),
        LKind, LSize, False, False, False, mipLeft,
        mikClose, 8, 4);

      AddButtonSample(AGrid,
        Format('Disabled + Loading (%s)', [ButtonSizeName(LSize)]),
        LKind, LSize, False, True, True, mipLeft,
        mikSpinner, 8, 4);

      AddButtonSample(AGrid,
        Format('Radius 0 (%s)', [ButtonSizeName(LSize)]),
        LKind, LSize, True, False, True, mipLeft,
        LIconKinds[(LIndex + 3) mod 4], 0, 2);

      AddButtonSample(AGrid,
        Format('Radius 24 (%s)', [ButtonSizeName(LSize)]),
        LKind, LSize, True, False, True, mipLeft,
        LIconKinds[LIndex], 24,
        2);

      AddButtonSample(AGrid,
        Format('TabStop = False (%s)', [ButtonSizeName(LSize)]),
        LKind, LSize, True, False, True, mipLeft,
        LIconKinds[(LIndex + 1) mod 4], 8, 2, False);

      AddGridSpacer(AGrid, 12);
    end;

    AddButtonSample(AGrid, 'Loading sem texto', LKind, mbsMedium, True, True,
      False, mipLeft, mikSpinner, 12, 4);

    AddButtonSample(AGrid, 'Loading + bordas largas', LKind, mbsLarge, True, True,
      True, mipLeft, mikSpinner, 4, 4, 28);

    AddButtonSample(AGrid, 'Loading + IconPosition=Right', LKind, mbsMedium,
      True, True, True, mipRight, mikSpinner, 4, 4);

    AddGridSpacer(AGrid, 16);
  end;

  AddGridSpacer(AGrid, 12);
  AddGridText(AGrid, 'Combinações adicionais por ícone', 12, 11, [fsBold]);
  for LIndex := Low(LIconKinds) to High(LIconKinds) do
  begin
    AddButtonSample(AGrid, Format('Ícone %d normal', [LIndex + 1]), mbkPrimary,
      mbsMedium, True, False, True, mipLeft,
      LIconKinds[LIndex], 6, 2, 16);
    AddButtonSample(AGrid, Format('Ícone %d right', [LIndex + 1]), mbkPrimary,
      mbsMedium, True, False, True, mipRight,
      LIconKinds[LIndex], 6, 2, 16);
  end;

  AddGridSpacer(AGrid, 12);
  AddGridText(AGrid, 'Fim da aba Botoes', 12, 9, [fsItalic]);
end;

procedure TForm1.BuildPlaceholderTab(const AGrid: TDACGridContainer;
  const ATitle: string; const ADescription: string);
var
  LDesc: string;
begin
  AddGridText(AGrid, ATitle, 12, 12, [fsBold]);
  LDesc := Format('Aqui vai ficar a biblioteca de %s.', [ADescription]);
  AddGridText(AGrid, LDesc, 12, 9);
  AddGridText(AGrid,
    'Mantive a estrutura de abas para facilitar a evolucao das demais familias de componentes.',
    12, 9, [fsItalic]);
  AddGridSpacer(AGrid, 12);
  AddButtonSample(AGrid, 'Botao placeholder', mbkGhost,
    mbsMedium, False, False, True,
    mipLeft, mikCalendar, 8, 4);
end;

procedure TForm1.BuildDemo;
var
  LGrid: TDACGridContainer;
begin
  FComponentTabs := TDACTabs.Create(Self);
  FComponentTabs.Parent := Self;
  FComponentTabs.Align := alClient;
  FComponentTabs.Items.Clear;
  FComponentTabs.ActiveIndex := 0;
  FComponentTabs.ShowContentBorder := False;

  LGrid := CreateDemoTabPage('Botoes');
  BuildButtonsTab(LGrid);

  LGrid := CreateDemoTabPage('Inputs');
  BuildPlaceholderTab(LGrid, 'Inputs', 'Input, Masked e DateTime');

  LGrid := CreateDemoTabPage('Seletores');
  BuildPlaceholderTab(LGrid, 'Seletores', 'Checkbox, Radio, Toggle e Slider');

  LGrid := CreateDemoTabPage('Containers');
  BuildPlaceholderTab(LGrid, 'Containers', 'GridContainer, ScrollContainer e derivados');

  LGrid := CreateDemoTabPage('Tabs');
  BuildPlaceholderTab(LGrid, 'Tabs', 'Comportamento de aba e troca de conteudo');

  LGrid := CreateDemoTabPage('Cards');
  BuildPlaceholderTab(LGrid, 'Cards', 'SummaryCard e cards de status/resumo');

  LGrid := CreateDemoTabPage('Grid');
  BuildPlaceholderTab(LGrid, 'Grid', 'DataGrid e layouts tabulares');

  LGrid := CreateDemoTabPage('Status');
  BuildPlaceholderTab(LGrid, 'Status', 'StatusBar e indicadores');

  LGrid := CreateDemoTabPage('Badges');
  BuildPlaceholderTab(LGrid, 'Badges', 'Badges, tags e chips');

  LGrid := CreateDemoTabPage('Progress');
  BuildPlaceholderTab(LGrid, 'Progress', 'Progresso linear, circular e outros');

  LGrid := CreateDemoTabPage('Paginacao');
  BuildPlaceholderTab(LGrid, 'Pagination', 'Paginacao com controles de pagina');

  LGrid := CreateDemoTabPage('Loading');
  BuildPlaceholderTab(LGrid, 'Loading', 'Loading spinners e estados de aguarde');

  LGrid := CreateDemoTabPage('Feedback');
  BuildPlaceholderTab(LGrid, 'Feedback', 'Toasts, tooltip e modal');

  LGrid := CreateDemoTabPage('Graficos');
  BuildPlaceholderTab(LGrid, 'Charts', 'Charts de barra, linha e area');

  LGrid := CreateDemoTabPage('Report');
  BuildPlaceholderTab(LGrid, 'Report', 'ReportViewer e controles de visualizacao');

  if FComponentTabs.Items.Count > 0 then
    FComponentTabs.ActiveIndex := 0;
end;

end.
