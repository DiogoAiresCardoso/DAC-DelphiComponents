unit TreeView.Demo.Main;

interface

uses
  System.Classes, System.SysUtils, System.Variants, System.Generics.Collections,
  Vcl.Forms, Vcl.Controls, Vcl.StdCtrls, Vcl.ExtCtrls, Vcl.Graphics,
  DAC.Components.DesignSystem.Theme,
  DAC.Components.Controls.TreeView,
  DAC.Components.Controls.TreeView.Item,
  DAC.Components.Controls.TreeView.Types;

type
  TTreeExampleObject = class
  public
    Key, ParentKey: Variant;
    LabelText, DetailText: string;
    Checked, Checkable: Boolean;
    constructor Create(const AKey, AParentKey: Variant;
      const ALabelText, ADetailText: string; ACheckable: Boolean = True);
  end;

  TTreeDemoForm = class(TForm)
    Header: TPanel;
    Search: TEdit;
    SearchLabel: TLabel;
    LoadObjectsButton: TButton;
    ManualButton: TButton;
    ExpandButton: TButton;
    CollapseButton: TButton;
    ThemeButton: TButton;
    ReadOnlyBox: TCheckBox;
    ShowHeaderBox: TCheckBox;
    Footer: TPanel;
    Status: TLabel;
    Instructions: TLabel;
    Tree: TDACTreeView;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure SearchChange(Sender: TObject);
    procedure LoadObjectsButtonClick(Sender: TObject);
    procedure ManualButtonClick(Sender: TObject);
    procedure ExpandButtonClick(Sender: TObject);
    procedure CollapseButtonClick(Sender: TObject);
    procedure ThemeButtonClick(Sender: TObject);
    procedure ReadOnlyBoxClick(Sender: TObject);
    procedure ShowHeaderBoxClick(Sender: TObject);
    procedure TreeBeforeCheckChange(Sender: TObject; const Key: Variant;
      DataObject: TObject; Checked: Boolean; var Allow: Boolean);
    procedure TreeCheckChanged(Sender: TObject; const Key: Variant;
      DataObject: TObject; Checked: Boolean; Reason: TDACTreeChangeReason);
    procedure TreeCurrentChanged(Sender: TObject; const OldKey, NewKey: Variant;
      DataObject: TObject; Reason: TDACTreeChangeReason);
    procedure TreeActivateRecord(Sender: TObject; const Key: Variant;
      DataObject: TObject);
    procedure TreeDataError(Sender: TObject; const Key: Variant;
      const MessageText: string);
  private
    FObjects: TObjectList<TTreeExampleObject>;
    FActivations: Integer;
    FObjectMode: Boolean;
    procedure UpdateStatus;
    procedure ThemeChanged(Sender: TObject);
  public
    procedure ApplyTheme(Mode: TDACThemeMode);
  end;

implementation

uses DAC.Components.DesignSystem.ComponentStyle,
  DAC.Components.DesignSystem.ColorTokens;

{$R *.dfm}

constructor TTreeExampleObject.Create(const AKey, AParentKey: Variant;
  const ALabelText, ADetailText: string; ACheckable: Boolean);
begin
  inherited Create;
  Key := AKey;
  ParentKey := AParentKey;
  LabelText := ALabelText;
  DetailText := ADetailText;
  Checkable := ACheckable;
end;

procedure TTreeDemoForm.FormCreate(Sender: TObject);
begin
  FObjects := TObjectList<TTreeExampleObject>.Create(True);
  { Deliberately flat and out of hierarchy order: children precede parents. }
  FObjects.Add(TTreeExampleObject.Create('011', '010', 'Teclados',
    'Objeto original: catalogo de teclados'));
  FObjects.Add(TTreeExampleObject.Create('012', '010', 'Monitores',
    'Descricao extensa para verificar hints, reticencias, colunas estreitas e redimensionamento'));
  FObjects.Add(TTreeExampleObject.Create('010', '001', 'Perifericos',
    'Grupo com filhos, sem marcacao', False));
  FObjects.Add(TTreeExampleObject.Create('001', Null, 'Equipamentos',
    'Raiz fornecida pelo consumidor', False));
  FObjects.Add(TTreeExampleObject.Create('021', '020', 'Manuais',
    'Folha de outra raiz'));
  FObjects.Add(TTreeExampleObject.Create('020', '', 'Documentos',
    'Raiz com ParentKey vazio', False));
  FObjects.Add(TTreeExampleObject.Create('022', '020', 'Arquivo bloqueado',
    'Elegibilidade fornecida pelo consumidor', False));
  LoadObjectsButtonClick(nil);
  ApplyTheme(dtmLight);
  TDACThemeManager.RegisterListener(Self,ThemeChanged);
end;

procedure TTreeDemoForm.FormDestroy(Sender: TObject);
begin
  TDACThemeManager.UnregisterListener(Self);
  { Objects outlive all associated tree items. The tree never frees them. }
  Tree.Items.Clear;
  FreeAndNil(FObjects);
end;

procedure TTreeDemoForm.LoadObjectsButtonClick(Sender: TObject);
begin
  FObjectMode := True;
  Search.Clear;
  if Tree.LoadObjects<TTreeExampleObject>(FObjects,
    function(Item: TTreeExampleObject): TDACTreeItemData
    begin
      Result := TDACTreeItemData.Create(Item.Key, Item.ParentKey,
        Item.LabelText, Item.Checkable);
      Result.SubItems := TArray<string>.Create(Item.DetailText);
      Result.Checked := Item.Checked;
    end) then
  begin
    Tree.ExpandAll;
    Tree.SelectedKey := '011';
    UpdateStatus;
  end;
end;

procedure TTreeDemoForm.ManualButtonClick(Sender: TObject);
var Root, Child, Sibling: TDACTreeItem;
begin
  FObjectMode := False;
  Search.Clear;
  Tree.BeginUpdate;
  try
    Tree.Items.Clear;
    Root := Tree.Items.Add(nil, 'Itens criados por Add/AddChild');
    Root.Checkable := False;
    Root.SubItems.Add('Itens internos pertencem ao componente');
    Child := Tree.Items.AddChild(Root, 'Primeiro filho');
    Child.SubItems.Add('AddChild cria um descendente do item informado');
    Sibling := Tree.Items.Add(Child, 'Irmao do primeiro filho');
    Sibling.SubItems.Add('Add com item informado cria um irmao, como na VCL');
    Child := Tree.Items.AddChild(Sibling, 'Neto');
    Child.SubItems.Add('Sem objeto externo associado neste modo');
    Root := Tree.Items.Add(nil, 'Segunda raiz');
    Root.Checkable := False;
    Root.SubItems.Add('Add(nil, Texto) cria uma raiz');
    Child := Tree.Items.AddChild(Root, 'Folha permitida');
    Child.SubItems.Add('Checkbox e estado mantidos pelo item interno');
  finally
    Tree.EndUpdate;
  end;
  Tree.ExpandAll;
  Tree.SelectedKey := Child.Key;
  UpdateStatus;
end;

procedure TTreeDemoForm.SearchChange(Sender: TObject);
begin
  Tree.SearchText := Search.Text;
end;

procedure TTreeDemoForm.ExpandButtonClick(Sender: TObject);
begin Tree.ExpandAll; end;

procedure TTreeDemoForm.CollapseButtonClick(Sender: TObject);
begin Tree.CollapseAll; end;

procedure TTreeDemoForm.ThemeButtonClick(Sender: TObject);
begin
  if Tree.ThemeMode = dtmLight then ApplyTheme(dtmDark)
  else ApplyTheme(dtmLight);
end;

procedure TTreeDemoForm.ApplyTheme(Mode: TDACThemeMode);
var Surface, TextColor: TColor;
begin
  Tree.ThemeMode := Mode;
  Surface := TDACComponentColors.ToVclColor(TDACComponentStyle.Resolve(Mode).Tokens.Controls.InputBackground);
  TextColor := TDACComponentColors.ToVclColor(TDACComponentStyle.Resolve(Mode).Tokens.Controls.InputText);
  Header.ParentBackground := False;
  Header.ParentColor := False;
  Header.StyleElements := [];
  Header.Color := Surface;
  Footer.ParentBackground := False;
  Footer.ParentColor := False;
  Footer.StyleElements := [];
  Footer.Color := Surface;
  SearchLabel.Font.Assign(Tree.Font);
  SearchLabel.Font.Color := TextColor;
  Status.Font.Assign(Tree.Font);
  Status.Font.Color := TextColor;
  Instructions.Font.Assign(Tree.Font);
  Instructions.Font.Color := TextColor;
  ReadOnlyBox.StyleElements := ReadOnlyBox.StyleElements - [seFont];
  ReadOnlyBox.Font.Assign(Tree.Font);
  ShowHeaderBox.StyleElements := ShowHeaderBox.StyleElements - [seFont];
  ShowHeaderBox.Font.Assign(Tree.Font);
  ShowHeaderBox.Font.Color := TextColor;
  ReadOnlyBox.Font.Color := TextColor;
  Search.StyleElements := Search.StyleElements - [seFont,seClient];
  Search.Color := Surface;
  Search.Font.Assign(Tree.Font);
  Search.Font.Color := TextColor;
end;

procedure TTreeDemoForm.ThemeChanged(Sender: TObject);
begin
  { The gallery applies a general native-label font before refreshing its
    descendants. Restore this example's own metrics at that boundary. }
  ApplyTheme(Tree.ThemeMode);
end;

procedure TTreeDemoForm.ShowHeaderBoxClick(Sender: TObject);
begin
  Tree.ShowHeader := ShowHeaderBox.Checked;
end;

procedure TTreeDemoForm.ReadOnlyBoxClick(Sender: TObject);
begin Tree.ReadOnly := ReadOnlyBox.Checked; end;

procedure TTreeDemoForm.TreeBeforeCheckChange(Sender: TObject;
  const Key: Variant; DataObject: TObject; Checked: Boolean; var Allow: Boolean);
begin
  { The consumer may veto without teaching the component any domain rule. }
  if DataObject is TTreeExampleObject then
    Allow := TTreeExampleObject(DataObject).Checkable;
end;

procedure TTreeDemoForm.TreeCheckChanged(Sender: TObject; const Key: Variant;
  DataObject: TObject; Checked: Boolean; Reason: TDACTreeChangeReason);
begin
  { Mapping is read-only. Only the consumer applies a requested user change. }
  if (Reason in [tcrUser, tcrProgrammatic]) and
    (DataObject is TTreeExampleObject) then
    TTreeExampleObject(DataObject).Checked := Checked;
  UpdateStatus;
end;

procedure TTreeDemoForm.TreeCurrentChanged(Sender: TObject;
  const OldKey, NewKey: Variant; DataObject: TObject; Reason: TDACTreeChangeReason);
begin UpdateStatus; end;

procedure TTreeDemoForm.TreeActivateRecord(Sender: TObject; const Key: Variant;
  DataObject: TObject);
begin
  Inc(FActivations);
  UpdateStatus;
end;

procedure TTreeDemoForm.TreeDataError(Sender: TObject; const Key: Variant;
  const MessageText: string);
begin Status.Caption := 'Erro: ' + MessageText; end;

procedure TTreeDemoForm.UpdateStatus;
var ObjectName, ModeName: string;
begin
  if Tree = nil then Exit;
  if Tree.SelectedObject <> nil then ObjectName := Tree.SelectedObject.ClassName
  else ObjectName := 'nenhum';
  if FObjectMode then ModeName := 'TObjectList' else ModeName := 'Add/AddChild';
  Status.Caption := Format('%s | Chave: %s | Objeto: %s | Marcados: %d | Ativacoes: %d | DPI: %d',
    [ModeName, VarToStr(Tree.SelectedKey), ObjectName,
      Length(Tree.CheckedKeys), FActivations, Screen.PixelsPerInch]);
end;

end.
