unit MaxUI.Demo.Main;

{$CODEPAGE 65001}

interface

uses
  System.Classes,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.StdCtrls,
  Vcl.ExtCtrls,
  MaxUI.Controls.Base;

type
  TfrmComponentGallery = class(TForm)
  private
    FHeader: TPanel;
    FScroll: TScrollBox;
    FCanvas: TPanel;
    procedure BuildHeader;
    procedure BuildGallery;
    function NewSection(const AIndex: Integer; const ATitle: string;
      const ALeft, ATop, AWidth, AHeight: Integer): TMaxSection;
    function AddLabel(AParent: TWinControl; const ACaption: string;
      const AX, AY: Integer; const ABold: Boolean = False): TLabel;
    procedure BuildButtons(ASection: TMaxSection);
    procedure BuildInputs(ASection: TMaxSection);
    procedure BuildSelectors(ASection: TMaxSection);
    procedure BuildChoices(ASection: TMaxSection);
    procedure BuildTabs(ASection: TMaxSection);
    procedure BuildCards(ASection: TMaxSection);
    procedure BuildGrid(ASection: TMaxSection);
    procedure BuildStatus(ASection: TMaxSection);
    procedure BuildProgress(ASection: TMaxSection);
    procedure BuildPills(ASection: TMaxSection);
    procedure BuildFeedback(ASection: TMaxSection);
    procedure BuildPagination(ASection: TMaxSection);
    procedure BuildLoading(ASection: TMaxSection);
    procedure BuildCharts(ASection: TMaxSection);
    procedure BuildReport(ASection: TMaxSection);
  public
    constructor Create(AOwner: TComponent); override;
  end;

var
  frmComponentGallery: TfrmComponentGallery;

implementation

uses
  System.Math,
  System.SysUtils,
  Vcl.ComCtrls,
  Vcl.Menus,
  MaxUI.Types,
  MaxUI.Theme,
  MaxUI.Controls.Buttons,
  MaxUI.Controls.Inputs,
  MaxUI.Controls.Selectors,
  MaxUI.Controls.Choices,
  MaxUI.Controls.Tabs,
  MaxUI.Controls.Cards,
  MaxUI.Controls.Data,
  MaxUI.Controls.Feedback,
  MaxUI.Controls.Charts,
  MaxUI.Controls.Report;

constructor TfrmComponentGallery.Create(AOwner: TComponent);
begin
  inherited CreateNew(AOwner);
  Caption := 'Suite de Componentes — Delphi + VCL + Skia';
  ClientWidth := 1420;
  ClientHeight := 900;
  Position := poScreenCenter;
  Color := clWhite;
  ParentBackground := False;
  StyleElements := [seFont, seBorder];
  Font.Name := 'Inter';
  Font.Size := 9;
  DoubleBuffered := True;
  BuildHeader;

  FScroll := TScrollBox.Create(Self);
  FScroll.Parent := Self;
  FScroll.Align := alClient;
  FScroll.Color := clWhite;
  FScroll.ParentBackground := False;
  FScroll.BorderStyle := bsNone;

  FCanvas := TPanel.Create(Self);
  FCanvas.Parent := FScroll;
  FCanvas.SetBounds(0, 0, 1400, 1710);
  FCanvas.BevelOuter := bvNone;
  FCanvas.Color := clWhite;
  FCanvas.ParentBackground := False;
  FCanvas.StyleElements := [seFont];

  BuildGallery;
end;

function TfrmComponentGallery.AddLabel(AParent: TWinControl;
  const ACaption: string; const AX, AY: Integer; const ABold: Boolean): TLabel;
begin
  Result := TLabel.Create(Self);
  Result.Parent := AParent;
  Result.Left := AX;
  Result.Top := AY;
  Result.Caption := ACaption;
  Result.Font.Name := 'Inter';
  Result.Font.Size := 8;
  Result.Font.Color := TMaxTheme.Palette.TextSecondary;
  if ABold then
  begin
    Result.Font.Style := [fsBold];
    Result.Font.Color := TMaxTheme.Palette.Text;
  end;
end;

procedure TfrmComponentGallery.BuildHeader;
var
  TitleLabel: TLabel;
  SubtitleLabel: TLabel;
begin
  FHeader := TPanel.Create(Self);
  FHeader.Parent := Self;
  FHeader.Align := alTop;
  FHeader.Height := 78;
  FHeader.BevelOuter := bvNone;
  FHeader.Color := clWhite;
  FHeader.ParentBackground := False;
  FHeader.StyleElements := [seFont];

  TitleLabel := TLabel.Create(Self);
  TitleLabel.Parent := FHeader;
  TitleLabel.Left := 24;
  TitleLabel.Top := 12;
  TitleLabel.Caption := 'Suite de Componentes — Delphi + VCL + Skia';
  TitleLabel.Font.Name := 'Inter';
  TitleLabel.Font.Size := 18;
  TitleLabel.Font.Style := [fsBold];
  TitleLabel.Font.Color := TMaxTheme.Palette.PrimaryDark;

  SubtitleLabel := TLabel.Create(Self);
  SubtitleLabel.Parent := FHeader;
  SubtitleLabel.Left := 25;
  SubtitleLabel.Top := 48;
  SubtitleLabel.Caption := '15 famílias VCL com StyleHooks localizados, design system Ancoragem e Skia obrigatório';
  SubtitleLabel.Font.Color := TMaxTheme.Palette.TextSecondary;
end;

procedure TfrmComponentGallery.BuildGallery;
var
  Section: TMaxSection;
begin
  Section := NewSection(1, 'BOTÕES', 16, 16, 390, 280);
  BuildButtons(Section);
  Section := NewSection(2, 'CAMPOS DE ENTRADA', 418, 16, 420, 280);
  BuildInputs(Section);
  Section := NewSection(3, 'SELETORES', 850, 16, 270, 280);
  BuildSelectors(Section);
  Section := NewSection(4, 'CONTROLES', 1132, 16, 252, 280);
  BuildChoices(Section);

  Section := NewSection(5, 'TABS', 16, 308, 400, 300);
  BuildTabs(Section);
  Section := NewSection(6, 'CARDS DE RESUMO', 428, 308, 480, 300);
  BuildCards(Section);
  Section := NewSection(7, 'TABELA / DATA GRID', 920, 308, 464, 300);
  BuildGrid(Section);

  Section := NewSection(8, 'STATUS BAR', 16, 620, 388, 340);
  BuildStatus(Section);
  Section := NewSection(9, 'PROGRESSO', 416, 620, 172, 340);
  BuildProgress(Section);
  Section := NewSection(10, 'BADGES, CHIPS, TAGS E PILLS', 600, 620, 288, 340);
  BuildPills(Section);
  Section := NewSection(11, 'TOAST, TOOLTIP E MODAL', 900, 620, 484, 340);
  BuildFeedback(Section);

  Section := NewSection(12, 'PAGINAÇÃO', 16, 972, 430, 270);
  BuildPagination(Section);
  Section := NewSection(13, 'LOADING / SPINNER', 458, 972, 310, 270);
  BuildLoading(Section);
  Section := NewSection(14, 'CHARTS', 780, 972, 604, 270);
  BuildCharts(Section);

  Section := NewSection(15, 'REPORT VIEWER', 16, 1254, 1368, 440);
  BuildReport(Section);
end;

function TfrmComponentGallery.NewSection(const AIndex: Integer;
  const ATitle: string; const ALeft, ATop, AWidth, AHeight: Integer): TMaxSection;
begin
  Result := TMaxSection.Create(Self);
  Result.Parent := FCanvas;
  Result.SetBounds(ALeft, ATop, AWidth, AHeight);
  Result.SectionIndex := AIndex;
  Result.Title := ATitle;
end;

procedure TfrmComponentGallery.BuildButtons(ASection: TMaxSection);
const
  Captions: array[0..4] of string = ('Primário', 'Secundário', 'Sucesso', 'Alerta', 'Perigo');
  Kinds: array[0..4] of TMaxButtonKind = (mbkPrimary, mbkSecondary,
    mbkSuccess, mbkWarning, mbkDanger);
var
  I: Integer;
  B: TMaxButton;
  IB: TMaxIconButton;
  Split: TMaxSplitButton;
  Menu: TPopupMenu;
  Item: TMenuItem;
begin
  for I := 0 to 4 do
  begin
    B := TMaxButton.Create(Self);
    B.Parent := ASection;
    B.SetBounds(14 + (I mod 3) * 118, 46 + (I div 3) * 54, 108, 36);
    B.Caption := Captions[I];
    B.Kind := Kinds[I];
    if I = 0 then B.IconKind := mikCheck;
  end;
  AddLabel(ASection, 'Ícone only', 14, 150, True);
  for I := 0 to 3 do
  begin
    IB := TMaxIconButton.Create(Self);
    IB.Parent := ASection;
    IB.SetBounds(14 + I * 48, 176, 38, 38);
    IB.IconKind := TMaxIconKind(Ord(mikPlus) + I);
    IB.Kind := TMaxButtonKind(Min(I, Ord(High(TMaxButtonKind))));
    IB.Hint := 'Ação';
    IB.ShowHint := True;
  end;
  Menu := TPopupMenu.Create(Self);
  Item := TMenuItem.Create(Menu); Item.Caption := 'Opção 01'; Menu.Items.Add(Item);
  Item := TMenuItem.Create(Menu); Item.Caption := 'Opção 02'; Menu.Items.Add(Item);
  Split := TMaxSplitButton.Create(Self);
  Split.Parent := ASection;
  Split.SetBounds(220, 176, 150, 38);
  Split.DropDownMenu := Menu;
  B := TMaxButton.Create(Self);
  B.Parent := ASection;
  B.SetBounds(14, 230, 120, 34);
  B.Caption := 'Desabilitado';
  B.Enabled := False;
end;

procedure TfrmComponentGallery.BuildInputs(ASection: TMaxSection);
var
  E: TMaxEdit;
  P: TMaxPasswordEdit;
  S: TMaxSearchEdit;
  M: TMaxMaskedEdit;
  Memo: TMaxMemo;
begin
  AddLabel(ASection, 'Campo de texto', 14, 40);
  E := TMaxEdit.Create(Self);
  E.Parent := ASection;
  E.SetBounds(14, 58, 190, 36);
  E.Placeholder := 'Digite um texto...';

  AddLabel(ASection, 'Masked input', 216, 40);
  M := TMaxMaskedEdit.Create(Self);
  M.Parent := ASection;
  M.SetBounds(216, 58, 188, 36);
  M.EditMask := '(00) 00000-0000;1;_';
  M.Placeholder := '(11) 99999-9999';

  AddLabel(ASection, 'Password', 14, 104);
  P := TMaxPasswordEdit.Create(Self);
  P.Parent := ASection;
  P.SetBounds(14, 122, 190, 36);
  P.Text := 'segredo';

  AddLabel(ASection, 'Search', 216, 104);
  S := TMaxSearchEdit.Create(Self);
  S.Parent := ASection;
  S.SetBounds(216, 122, 188, 36);

  AddLabel(ASection, 'Memo / TextArea', 14, 168);
  Memo := TMaxMemo.Create(Self);
  Memo.Parent := ASection;
  Memo.SetBounds(14, 188, 390, 76);
  Memo.Lines.Text := 'Área para texto com múltiplas linhas.';
end;

procedure TfrmComponentGallery.BuildSelectors(ASection: TMaxSection);
var
  C: TMaxComboBox;
  D: TMaxDatePicker;
  T: TMaxTimePicker;
  S: TMaxSpinField;
begin
  AddLabel(ASection, 'ComboBox', 14, 40);
  C := TMaxComboBox.Create(Self);
  C.Parent := ASection;
  C.SetBounds(14, 58, 240, 36);
  C.Items.Add('Opção 01');
  C.Items.Add('Opção 02');
  C.Items.Add('Opção 03');
  C.ItemIndex := 0;

  AddLabel(ASection, 'DatePicker', 14, 106);
  D := TMaxDatePicker.Create(Self);
  D.Parent := ASection;
  D.SetBounds(14, 124, 126, 36);

  AddLabel(ASection, 'TimePicker', 148, 106);
  T := TMaxTimePicker.Create(Self);
  T.Parent := ASection;
  T.SetBounds(148, 124, 106, 36);

  AddLabel(ASection, 'SpinEdit', 14, 174);
  S := TMaxSpinField.Create(Self);
  S.Parent := ASection;
  S.SetBounds(14, 194, 110, 36);
  S.Position := 25;

  C := TMaxComboBox.Create(Self);
  C.Parent := ASection;
  C.SetBounds(14, 238, 240, 32);
  C.Enabled := False;
end;

procedure TfrmComponentGallery.BuildChoices(ASection: TMaxSection);
var
  C: TMaxCheckBox;
  R: TMaxRadioButton;
  T: TMaxToggleSwitch;
  S: TMaxSlider;
begin
  C := TMaxCheckBox.Create(Self);
  C.Parent := ASection;
  C.SetBounds(14, 44, 210, 24);
  C.Caption := 'CheckBox marcado';
  C.Checked := True;
  C := TMaxCheckBox.Create(Self);
  C.Parent := ASection;
  C.SetBounds(14, 72, 210, 24);
  C.Caption := 'CheckBox desmarcado';

  R := TMaxRadioButton.Create(Self);
  R.Parent := ASection;
  R.SetBounds(14, 108, 210, 24);
  R.Caption := 'Radio selecionado';
  R.Checked := True;
  R := TMaxRadioButton.Create(Self);
  R.Parent := ASection;
  R.SetBounds(14, 136, 210, 24);
  R.Caption := 'Radio não selecionado';

  AddLabel(ASection, 'Toggle switch', 14, 174);
  T := TMaxToggleSwitch.Create(Self);
  T.Parent := ASection;
  T.SetBounds(130, 166, 100, 30);
  T.Checked := True;

  AddLabel(ASection, 'Slider', 14, 214);
  S := TMaxSlider.Create(Self);
  S.Parent := ASection;
  S.SetBounds(14, 232, 220, 34);
  S.Position := 75;
end;

procedure TfrmComponentGallery.BuildTabs(ASection: TMaxSection);
var
  P: TMaxPageControl;
  Page: TTabSheet;
  L: TLabel;
begin
  P := TMaxPageControl.Create(Self);
  P.Parent := ASection;
  P.SetBounds(14, 44, 370, 112);
  Page := TTabSheet.Create(P); Page.PageControl := P; Page.Caption := 'Geral';
  L := AddLabel(Page, 'Conteúdo da aba Geral.', 16, 16, True);
  L.Font.Color := TMaxTheme.Palette.Text;
  Page := TTabSheet.Create(P); Page.PageControl := P; Page.Caption := 'Financeiro';
  Page := TTabSheet.Create(P); Page.PageControl := P; Page.Caption := 'Vendas';
  Page := TTabSheet.Create(P); Page.PageControl := P; Page.Caption := 'Configurações';
  P.ActivePageIndex := 0;

  P := TMaxPageControl.Create(Self);
  P.Parent := ASection;
  P.SetBounds(14, 168, 370, 116);
  P.TabPosition := tpLeft;
  Page := TTabSheet.Create(P); Page.PageControl := P; Page.Caption := 'Resumo';
  AddLabel(Page, 'Exibição de dados gerais.', 20, 18, True);
  Page := TTabSheet.Create(P); Page.PageControl := P; Page.Caption := 'Detalhes';
  Page := TTabSheet.Create(P); Page.PageControl := P; Page.Caption := 'Histórico';
  P.ActivePageIndex := 0;
end;

procedure TfrmComponentGallery.BuildCards(ASection: TMaxSection);
const
  Titles: array[0..3] of string = ('Receita', 'Pedidos', 'Clientes', 'Produtos');
  Values: array[0..3] of string = ('R$ 125.430,50', '1.234', '856', '2.345');
  Icons: array[0..3] of TMaxIconKind = (mikCurrency, mikCart, mikUsers, mikBox);
var
  I: Integer;
  Card: TMaxSummaryCard;
begin
  for I := 0 to 3 do
  begin
    Card := TMaxSummaryCard.Create(Self);
    Card.Parent := ASection;
    Card.SetBounds(14 + (I mod 2) * 226, 44 + (I div 2) * 124, 214, 112);
    Card.Title := Titles[I];
    Card.ValueText := Values[I];
    Card.IconKind := Icons[I];
    Card.DeltaText := IntToStr(5 + I * 2) + ',2% vs. mês anterior';
    if I = 2 then Card.DeltaKind := mdkNegative else Card.DeltaKind := mdkPositive;
    case I of
      1: Card.AccentColor := TMaxTheme.Palette.Info;
      2: Card.AccentColor := TMaxTheme.Palette.Warning;
      3: Card.AccentColor := TMaxTheme.Palette.AccentPurple;
    end;
  end;
end;

procedure TfrmComponentGallery.BuildGrid(ASection: TMaxSection);
var
  G: TMaxStringGrid;
begin
  G := TMaxStringGrid.Create(Self);
  G.Parent := ASection;
  G.SetBounds(12, 42, 440, 244);
  G.ColCount := 6;
  G.RowCount := 6;
  G.StatusColumn := 3;
  G.ActionColumn := 5;
  G.Cells[0,0] := 'ID'; G.Cells[1,0] := 'Cliente'; G.Cells[2,0] := 'Cidade';
  G.Cells[3,0] := 'Status'; G.Cells[4,0] := 'Valor'; G.Cells[5,0] := 'Ações';
  G.Cells[0,1] := '1001'; G.Cells[1,1] := 'Maria Silva'; G.Cells[2,1] := 'São Paulo'; G.Cells[3,1] := 'Ativo'; G.Cells[4,1] := '1.250,00';
  G.Cells[0,2] := '1002'; G.Cells[1,2] := 'João Santos'; G.Cells[2,2] := 'Rio de Janeiro'; G.Cells[3,2] := 'Ativo'; G.Cells[4,2] := '980,50';
  G.Cells[0,3] := '1003'; G.Cells[1,3] := 'Ana Oliveira'; G.Cells[2,3] := 'Belo Horizonte'; G.Cells[3,3] := 'Pendente'; G.Cells[4,3] := '750,00';
  G.Cells[0,4] := '1004'; G.Cells[1,4] := 'Carlos Lima'; G.Cells[2,4] := 'Curitiba'; G.Cells[3,4] := 'Ativo'; G.Cells[4,4] := '1.430,25';
  G.Cells[0,5] := '1005'; G.Cells[1,5] := 'Fernanda Costa'; G.Cells[2,5] := 'Porto Alegre'; G.Cells[3,5] := 'Cancelado'; G.Cells[4,5] := '320,00';
  G.ColWidths[0] := 42; G.ColWidths[1] := 95; G.ColWidths[2] := 90;
  G.ColWidths[3] := 76; G.ColWidths[4] := 70; G.ColWidths[5] := 58;
end;

procedure TfrmComponentGallery.BuildStatus(ASection: TMaxSection);
var
  Status: TMaxStatusBar;
begin
  AddLabel(ASection, 'Barra de estado clara e independente', 14, 46, True);
  Status := TMaxStatusBar.Create(Self);
  Status.Parent := ASection;
  Status.SetBounds(14, 78, 360, 38);
  AddLabel(ASection, 'Campos: conexão • usuário • perfil • data • hora • segurança',
    14, 132);
end;

procedure TfrmComponentGallery.BuildProgress(ASection: TMaxSection);
var
  L: TMaxLinearProgress;
  C: TMaxCircularProgress;
begin
  AddLabel(ASection, 'Linear', 14, 48, True);
  L := TMaxLinearProgress.Create(Self);
  L.Parent := ASection;
  L.SetBounds(14, 72, 144, 28);
  L.Position := 68;
  AddLabel(ASection, 'Circular', 14, 124, True);
  C := TMaxCircularProgress.Create(Self);
  C.Parent := ASection;
  C.SetBounds(38, 154, 96, 96);
  C.Position := 68;
end;

procedure TfrmComponentGallery.BuildPills(ASection: TMaxSection);
var
  P: TMaxPill;
  I: Integer;
  K: TMaxPillKind;
begin
  AddLabel(ASection, 'Badges', 14, 44, True);
  for I := 0 to 2 do
  begin
    P := TMaxBadge.Create(Self);
    P.Parent := ASection;
    P.SetBounds(14 + I * 58, 64, 48, 26);
    P.Text := IntToStr(8 + I * 15);
    P.Kind := TMaxPillKind(Ord(mpkPrimary) + I);
  end;
  AddLabel(ASection, 'Chips', 14, 104, True);
  for I := 0 to 2 do
  begin
    P := TMaxChip.Create(Self);
    P.Parent := ASection;
    P.SetBounds(14 + I * 86, 124, 80, 26);
    P.Text := 'Filtro ' + IntToStr(I + 1);
    P.CloseButton := True;
  end;
  AddLabel(ASection, 'Tags', 14, 164, True);
  for I := 0 to 2 do
  begin
    P := TMaxTag.Create(Self);
    P.Parent := ASection;
    P.SetBounds(14 + I * 86, 184, 80, 26);
    case I of
      0: begin P.Text := 'Novo'; K := mpkSuccess; end;
      1: begin P.Text := 'Promoção'; K := mpkWarning; end;
    else
      begin P.Text := 'Limitado'; K := mpkDanger; end;
    end;
    P.Kind := K;
  end;
  AddLabel(ASection, 'Pills', 14, 224, True);
  for I := 0 to 2 do
  begin
    P := TMaxPill.Create(Self);
    P.Parent := ASection;
    P.SetBounds(14 + I * 86, 244, 80, 26);
    P.Text := 'Opção ' + IntToStr(I + 1);
    P.Selected := I = 0;
  end;
end;

procedure TfrmComponentGallery.BuildFeedback(ASection: TMaxSection);
var
  Toast: TMaxToast;
  Tooltip: TMaxTooltip;
  Modal: TMaxModalPanel;
begin
  Toast := TMaxToast.Create(Self);
  Toast.Parent := ASection;
  Toast.SetBounds(12, 44, 196, 68);
  Toast.ToastKind := mtkSuccess;
  Toast.Title := 'Sucesso';
  Toast.MessageText := 'Operação realizada.';

  Toast := TMaxToast.Create(Self);
  Toast.Parent := ASection;
  Toast.SetBounds(12, 120, 196, 68);
  Toast.ToastKind := mtkWarning;
  Toast.Title := 'Atenção';
  Toast.MessageText := 'Verifique as informações.';

  Toast := TMaxToast.Create(Self);
  Toast.Parent := ASection;
  Toast.SetBounds(12, 196, 196, 68);
  Toast.ToastKind := mtkDanger;
  Toast.Title := 'Erro';
  Toast.MessageText := 'Não foi possível salvar.';

  Tooltip := TMaxTooltip.Create(Self);
  Tooltip.Parent := ASection;
  Tooltip.SetBounds(12, 274, 196, 50);
  Tooltip.Text := 'Informação adicional sobre este item';

  Modal := TMaxModalPanel.Create(Self);
  Modal.Parent := ASection;
  Modal.SetBounds(220, 44, 250, 280);
  Modal.MessageText := 'Deseja realmente excluir este registro?';
end;

procedure TfrmComponentGallery.BuildPagination(ASection: TMaxSection);
var
  P: TMaxPagination;
begin
  AddLabel(ASection, 'Navegação entre páginas', 14, 50, True);
  P := TMaxPagination.Create(Self);
  P.Parent := ASection;
  P.SetBounds(14, 84, 398, 42);
  P.PageCount := 12;
  P.CurrentPage := 3;
  P.PageSize := 10;
end;

procedure TfrmComponentGallery.BuildLoading(ASection: TMaxSection);
var
  S: TMaxSpinner;
begin
  AddLabel(ASection, 'Ring', 14, 52, True);
  S := TMaxSpinner.Create(Self);
  S.Parent := ASection;
  S.SetBounds(14, 78, 74, 54);
  S.SpinnerStyle := mssRing;
  AddLabel(ASection, 'Dots', 104, 52, True);
  S := TMaxSpinner.Create(Self);
  S.Parent := ASection;
  S.SetBounds(104, 78, 74, 54);
  S.SpinnerStyle := mssDots;
  AddLabel(ASection, 'Skeleton', 14, 152, True);
  S := TMaxSpinner.Create(Self);
  S.Parent := ASection;
  S.SetBounds(14, 178, 270, 60);
  S.SpinnerStyle := mssSkeleton;
end;

procedure TfrmComponentGallery.BuildCharts(ASection: TMaxSection);
var
  I: Integer;
  C: TMaxChart;
begin
  for I := 0 to 3 do
  begin
    C := TMaxChart.Create(Self);
    C.Parent := ASection;
    C.SetBounds(10 + I * 146, 44, 138, 210);
    C.ChartKind := TMaxChartKind(I);
    C.ShowLegend := I = 3;
    case I of
      0: C.Title := 'Barras';
      1: C.Title := 'Linha';
      2: C.Title := 'Área';
      3: C.Title := 'Donut';
    end;
  end;
end;

procedure TfrmComponentGallery.BuildReport(ASection: TMaxSection);
var
  Viewer: TMaxReportViewer;
begin
  Viewer := TMaxReportViewer.Create(Self);
  Viewer.Parent := ASection;
  Viewer.SetBounds(12, 42, 1344, 386);
end;

end.
