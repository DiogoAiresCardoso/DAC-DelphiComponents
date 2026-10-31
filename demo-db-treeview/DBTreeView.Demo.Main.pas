unit DBTreeView.Demo.Main;

interface

uses
  System.Classes, System.SysUtils, System.Variants,
  Vcl.Forms, Vcl.Controls, Vcl.StdCtrls, Vcl.ExtCtrls,
  Data.DB, Datasnap.DBClient,
  DAC.Components.Controls.DBTreeView,
  DAC.Components.Controls.DBTreeView.Types;

type
  TDBTreeDemoForm = class(TForm)
    Header: TPanel;
    Search: TEdit;
    SearchLabel: TLabel;
    PreviousButton: TButton;
    NextButton: TButton;
    ExpandButton: TButton;
    CollapseButton: TButton;
    ThemeButton: TButton;
    ReadOnlyBox: TCheckBox;
    Footer: TPanel;
    Status: TLabel;
    Instructions: TLabel;
    Tree: TDACDBTreeView;
    Source: TDataSource;
    Data: TClientDataSet;
    procedure FormCreate(Sender: TObject);
    procedure SearchChange(Sender: TObject);
    procedure PreviousButtonClick(Sender: TObject);
    procedure NextButtonClick(Sender: TObject);
    procedure ExpandButtonClick(Sender: TObject);
    procedure CollapseButtonClick(Sender: TObject);
    procedure ThemeButtonClick(Sender: TObject);
    procedure ReadOnlyBoxClick(Sender: TObject);
    procedure TreeBeforeCheckChange(Sender: TObject; const Key: Variant;
      const Checked: Boolean; var Allow: Boolean);
    procedure TreeCheckChanged(Sender: TObject; const Key: Variant;
      Checked: Boolean; Reason: TDACDBTreeChangeReason);
    procedure TreeCurrentChanged(Sender: TObject; const OldKey, NewKey: Variant;
      Reason: TDACDBTreeChangeReason);
    procedure TreeActivateRecord(Sender: TObject; const Key: Variant);
    procedure TreeDataError(Sender: TObject; const Key: Variant;
      const MessageText: string);
  private
    FActivations: Integer;
    procedure UpdateStatus;
    procedure Add(const Key, Code, Description: string;
      const Parent: Variant; Selectable: Boolean);
  end;

var DBTreeDemoForm: TDBTreeDemoForm;

implementation

uses DAC.Components.DesignSystem.Theme;

{$R *.dfm}

procedure TDBTreeDemoForm.Add(const Key, Code, Description: string;
  const Parent: Variant; Selectable: Boolean);
begin
  Data.AppendRecord([Key, Parent, Code, Description, False, Selectable]);
end;

procedure TDBTreeDemoForm.FormCreate(Sender: TObject);
begin
  Tree.BeginUpdate;
  try
    Data.FieldDefs.Add('PLANOFINANCE_CODIGO', ftString, 20);
    Data.FieldDefs.Add('PLANOFINANCE_CODIGOPAI', ftString, 20);
    Data.FieldDefs.Add('PLANOFINANCE_CODIGOPLANO', ftString, 30);
    Data.FieldDefs.Add('PLANOFINANCE_DESCRICAO', ftString, 250);
    Data.FieldDefs.Add('SELECIONADO', ftBoolean);
    Data.FieldDefs.Add('SELECIONAVEL', ftBoolean);
    Data.CreateDataSet;
    Add('001', '1', 'Receitas', Null, False);
    Add('010', '1.01', 'Receitas operacionais', '001', False);
    Add('011', '1.01.001', 'Venda de produtos', '010', True);
    Add('012', '1.01.002', 'Prestacao de servicos', '010', True);
    Add('013', '1.01.003', 'Descricao extensa para conferir hints, reticencias e colunas estreitas ao redimensionar a janela de demonstracao', '010', True);
    Add('020', '1.02', 'Receitas nao operacionais', '001', False);
    Add('021', '1.02.001', 'Outras receitas', '020', True);
    Add('100', '2', 'Despesas', Null, False);
    Add('110', '2.01', 'Custos de producao', '100', False);
    Add('111', '2.01.001', 'Insumos', '110', True);
    Add('112', '2.01.002', 'Combustiveis', '110', True);
    Add('113', '2.01.003', 'Manutencao', '110', True);
    Add('200', '3', 'Grupo independente com pai vazio', '', False);
    Add('201', '3.01', 'Registro bloqueado pelo consumidor', '200', False);
    Add('202', '3.02', 'Registro permitido pelo consumidor', '200', True);
    Data.First;
  finally
    Tree.EndUpdate;
  end;
  Tree.ExpandAll;
  UpdateStatus;
end;

procedure TDBTreeDemoForm.SearchChange(Sender: TObject);
begin
  Tree.SearchText := Search.Text;
end;

procedure TDBTreeDemoForm.PreviousButtonClick(Sender: TObject);
begin
  Data.Prior;
end;

procedure TDBTreeDemoForm.NextButtonClick(Sender: TObject);
begin
  Data.Next;
end;

procedure TDBTreeDemoForm.ExpandButtonClick(Sender: TObject);
begin
  Tree.ExpandAll;
end;

procedure TDBTreeDemoForm.CollapseButtonClick(Sender: TObject);
begin
  Tree.CollapseAll;
end;

procedure TDBTreeDemoForm.ThemeButtonClick(Sender: TObject);
begin
  if Tree.ThemeMode = dtmLight then Tree.ThemeMode := dtmDark
  else Tree.ThemeMode := dtmLight;
end;

procedure TDBTreeDemoForm.ReadOnlyBoxClick(Sender: TObject);
begin
  Tree.ReadOnly := ReadOnlyBox.Checked;
end;

procedure TDBTreeDemoForm.TreeBeforeCheckChange(Sender: TObject;
  const Key: Variant; const Checked: Boolean; var Allow: Boolean);
begin
  { The consumer owns Edit/Post. This dataset is local presentation state. }
  Allow := Data.Active and Data.CanModify and
    Data.FieldByName('SELECIONAVEL').AsBoolean;
  if Allow then Data.Edit;
end;

procedure TDBTreeDemoForm.TreeCheckChanged(Sender: TObject; const Key: Variant;
  Checked: Boolean; Reason: TDACDBTreeChangeReason);
begin
  if (Reason in [tcrUser, tcrProgrammatic]) and
     (Data.State in [dsEdit, dsInsert]) then Data.Post;
  UpdateStatus;
end;

procedure TDBTreeDemoForm.TreeCurrentChanged(Sender: TObject;
  const OldKey, NewKey: Variant; Reason: TDACDBTreeChangeReason);
begin
  UpdateStatus;
end;

procedure TDBTreeDemoForm.TreeActivateRecord(Sender: TObject; const Key: Variant);
begin
  Inc(FActivations);
  UpdateStatus;
end;

procedure TDBTreeDemoForm.TreeDataError(Sender: TObject; const Key: Variant;
  const MessageText: string);
begin
  Status.Caption := 'Erro: ' + MessageText;
end;

procedure TDBTreeDemoForm.UpdateStatus;
begin
  if Tree = nil then Exit;
  Status.Caption := Format('Chave atual: %s   Marcados: %d   Ativacoes: %d   DPI: %d',
    [VarToStr(Tree.SelectedKey), Length(Tree.CheckedKeys), FActivations, Screen.PixelsPerInch]);
end;

end.
