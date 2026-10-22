unit ufrmMaster;
interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, TypInfo, ComCtrls, ExtCtrls, jpeg, Grids, DBGrids, Mask,
  ActnList, DBCtrls, SQLExpr, Buttons, JvDBUltimGrid, JvDBControls,
  JvMaskEdit, DBClient, ShellApi, JvDBTreeView, JvCombobox,
  JvDBCombobox, JvToolEdit, FMTBcd, DB, ImgList, Menus, JvDBCheckBox, JvExMask,
  JvExStdCtrls, JvBaseEdits, JvExDBGrids, JvDBGrid, frxClass, frxDBSet,
  DateUtils, Datasnap.DSConnect, VclTee.Dbchart, JvTypes, VCLTee.TeEngine, VCLTee.TeeProcs,
  VCLTee.Chart, JvBitBtn, JvExButtons, cxGraphics, cxControls, cxLookAndFeels, cxLookAndFeelPainters,
  cxContainer, cxEdit, cxTextEdit, cxMaskEdit, cxDropDownEdit, cxCalendar, cxDBEdit, JvExComCtrls,
  JvStatusBar, JvCheckBox, JvSpeedButton, JvComponentBase, JvThread, dxStatusBar, cxGridCustomTableView,
  cxGridTableView, cxGridDBTableView, cxGrid, JvGroupBox, cxCustomData, cxStyles, cxTL, cxTLdxBarBuiltInMenu,
  cxInplaceContainer, cxTLData, cxDBTL, RzDBBnEd, RzDBEdit, RzButton, RzDBChk, RzEdit, RzCmboBx, RTTI, RZCommon,
  RzSpnEdt, RzTabs, RzRadChk, StrUtils, RzLstBox, Threading;

type
  TfrmMaster = class(TForm)
    pnlMaster: TPanel;
    pnlPrincipalNOVO: TPanel;
    stbMaster: TdxStatusBar;
    BitBtn2: TBitBtn;
    btnPesquisaImagem: TBitBtn;
    procedure FormShow(Sender: TObject);
//    procedure ChangeComponentColor(Sender: TObject);
    procedure MostrarHint(Sender: TObject);
    procedure FormActivate(Sender: TObject);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormCreate(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure stbMaster1DrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel; const Rect: TRect);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
  private
    { Private declarations }
    procedure WMMove(var Msg: TWMMove); message WM_MOVE;
    procedure AfterPost(DataSet: TDataSet);
    procedure Campo(Index: Integer; NomeCampo, Hint: String);
    procedure FieldEventSetText(Sender: TField; const Text: string);

  public
    { Public declarations }
    Foco: TWinControl;
    ListaComponentesPermitidos, ListaObrigatorios: TStringList;
    procedure CarregarListaComponentesPermitidos(Dados: TClientDataSet);
    procedure PermitirAcessoComponente;
    function DataMaiorQueAtual(Data: TDateTime): Boolean;
    function DataMenorQueAtual(Data: TDateTime): Boolean;
    procedure ValidarDataMovimentacao;
    procedure SalvarLog(Formulario, Modulo: String);
    procedure BeforeDelete(DataSet: TDataSet);
    procedure SetarPropriedadesIniciais;
    procedure VideoAdjust(Form: TForm);
  end;

var
  frmMaster: TfrmMaster;
  ComponentBack: TComponent;
  ComponentColor: TColor;
  ColorDisabledText: Tcolor = clGrayText;   //Cor para os campos desabilitados
  ColorDisabled: TColor;          //Cor do texto para os campos desabilitados
  WhereEmp: string;
  ContEnter : Integer;
  Value : Boolean;
  Fechou : Boolean;
  ConcluirLog : Boolean;
  DataSet : TDataSet;
implementation

uses uMensagens, ufrmPrincipal, udmMaxxLocal, uLib, uLayoutFormulario,
  uConstantes;

{$R *.dfm}

procedure TfrmMaster.CarregarListaComponentesPermitidos(Dados: TClientDataSet);
var
  i : integer;
begin
  try
    Dados.DisableControls;
    if dmMaxxLocal.loginUsuarioUSER_ADMIN.AsString = 'F' then
    begin
      Dados.First;
      ListaComponentesPermitidos.Clear;
      while not Dados.Eof do
      begin
        ListaComponentesPermitidos.Add(Dados.FieldByName('OPCOE_OPCA').AsString);
        Dados.Next;
      end;
    end
    else begin
      for i := 0 to (ComponentCount - 1) do
      begin
        if (IsPublishedProp(Components[i], 'Tag')) then
        begin
          if (TComponent(Components[i]).Tag = 1) then
            ListaComponentesPermitidos.Add(TComponent(Components[i]).Name)
        end;
      end;
    end;
    Dados.EnableControls;
  except
    MessageDebug('CarregarListaComponentesPermitidos');
  end;
end;

procedure TfrmMaster.MostrarHint(Sender: TObject);
begin
//  if not Fechou then
//  begin
   try
     //Tratando erro de access violation na abertura das telas
     if (not Self.Visible) or (not Self.Showing) or
        (Self = nil)  then
       Exit;

     if ((Self.ActiveControl = nil) or (Self.ActiveControl.Name = '')
          or (Self.Name = 'frmMensagens')
          or (Self.ActiveControl is TRzCustomTabControl) or
         (Self.ActiveControl is TCustomButton) or (Self.ActiveControl is TRzTabSheet) or
         (not Self.Visible)) then
         Exit;

      //Setando o hint do campo
      if GetPropInfo(Self.ActiveControl.ClassInfo, 'Hint') <> nil then
      begin
        if GetPropValue(Self.ActiveControl, 'Hint') <> '' then
           stbMaster.Panels[1].Text := GetPropValue(Self.ActiveControl, 'Hint')
        else stbMaster.Panels[1].Text := GetPropValue(Self.ActiveControl, 'Name');
      end;

   except
//    on e : exception do
//        MessageDebug('ChangeComponentColor' + ' ' + Self.Name);
   end;
//  end;
end;

procedure TfrmMaster.FormActivate(Sender: TObject);
begin
   try
//     Screen.OnActiveControlChange := MostrarHint;
     frmPrincipal.FecharMenu;
   except
//     MessageDebug('FormActivate');
   end;
end;

procedure TfrmMaster.FormClose(Sender: TObject; var Action: TCloseAction);
begin

  if Self.Name <> 'frmMasterPes' then
    Fechou := True;

  FreeAndNil(ListaComponentesPermitidos);
  FreeAndNil(ListaObrigatorios);
  LimpaMemoriaAPP;
end;

procedure TfrmMaster.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
  Fechou := True;
end;

procedure TfrmMaster.FormCreate(Sender: TObject);
var
  Evento: TFieldSetTextEvent;
  I: Integer;
begin
//  Application.OnHint :=  DisplayHint;

//  Screen.OnActiveControlChange :=  MostrarHint;

  Self.Visible := False;

  Fechou := False;
  Scaled := False;

  try
    ListaObrigatorios          := TStringList.Create;
    ListaComponentesPermitidos := TStringList.Create;
  except
//    MessageDebug('FormCreate 1');
  end;

  for I := 0 to Pred(ComponentCount) do
  begin
    if Components[I] is TField then
    begin
      if Components[I].ClassType = TStringField then
        TStringField(Components[I]).OnSetText := FieldEventSetText;
      if Components[I].ClassType = TWideStringField then
        TWideStringField(Components[I]).OnSetText := FieldEventSetText;
    end;
  end;
end;

procedure TfrmMaster.Campo(Index: Integer; NomeCampo, Hint: String);
  function LocalizaLabel(Campo: TWinControl): string;
  var
    i: Integer;
  begin
    Result := '';
    for i := 0 to (ComponentCount - 1) do
    begin
      if Components[i] is TLabel then
      begin
        if TLabel(Components[i]).FocusControl = Campo then
           Result := TLabel(Components[i]).Caption;
      end;
    end;
  end;
var
    lb: String;
begin
  try
    if NomeCampo <> '' then
    begin
      if dmMaxxLocal.cdsCampos.Locate('CAMPO', VarArrayOf([NomeCampo]), []) then
      begin
        if dmMaxxLocal.cdsCamposLABEL.AsString = '' then
        begin
          if Components[Index].ClassType = TJvDBMaskEdit then
             lb := LocalizaLabel(TJvDBMaskEdit(Components[Index]));
          if Components[Index].ClassType = TJvDBDateEdit then
             lb := LocalizaLabel(TJvDBDateEdit(Components[Index]));
          if Components[Index].ClassType = TJvDBCalcEdit then
             lb := LocalizaLabel(TJvDBCalcEdit(Components[Index]));
          if Components[Index].ClassType = TJvDBCheckBox then
             lb := TJvDBCheckBox(Components[Index]).Caption;
          if Components[Index].ClassType = TJvDBComboBox then
             lb := LocalizaLabel(TJvDBComboBox(Components[Index]));
          if Components[Index].ClassType = TDBMemo then
             lb := LocalizaLabel(TDBMemo(Components[Index]));
          if Components[Index].ClassType = TDBEdit then
             lb := LocalizaLabel(TDBEdit(Components[Index]));
          if Components[Index].ClassType = TDBRadioGroup then
             lb := TDBRadioGroup(Components[Index]).Caption;
          if Components[Index].ClassType = TDBCheckBox then
             lb := TDBCheckBox(Components[Index]).Caption;


          if lb <> '' then
          begin
            if dmMaxxLocal.cdsCampos.State = dsBrowse then
               dmMaxxLocal.cdsCampos.Edit;
            dmMaxxLocal.cdsCamposLABEL.AsString := lb;
          end;
        end;

        if dmMaxxLocal.cdsCamposHINT.AsString = '' then
        begin
          if dmMaxxLocal.cdsCampos.State = dsBrowse then
             dmMaxxLocal.cdsCampos.Edit;
          if Components[Index].ClassType = TJvDBMaskEdit then
             dmMaxxLocal.cdsCamposHINT.AsString := TJvDBMaskEdit(Components[Index]).Hint;
          if Components[Index].ClassType = TJvDBDateEdit then
             dmMaxxLocal.cdsCamposHINT.AsString := TJvDBDateEdit(Components[Index]).Hint;
          if Components[Index].ClassType = TJvDBCalcEdit then
             dmMaxxLocal.cdsCamposHINT.AsString := TJvDBCalcEdit(Components[Index]).Hint;
          if Components[Index].ClassType = TJvDBComboBox then
             dmMaxxLocal.cdsCamposHINT.AsString := TJvDBComboBox(Components[Index]).Hint;
          if Components[Index].ClassType = TJvDBCheckBox then
             dmMaxxLocal.cdsCamposHINT.AsString := TJvDBCheckBox(Components[Index]).Hint;
          if Components[Index].ClassType = TDBMemo then
             dmMaxxLocal.cdsCamposHINT.AsString := TDBMemo(Components[Index]).Hint;
          if Components[Index].ClassType = TDBEdit then
             dmMaxxLocal.cdsCamposHINT.AsString := TDBEdit(Components[Index]).Hint;
          if Components[Index].ClassType = TDBRadioGroup then
             dmMaxxLocal.cdsCamposHINT.AsString := TDBRadioGroup(Components[Index]).Hint;
          if Components[Index].ClassType = TDBCheckBox then
             dmMaxxLocal.cdsCamposHINT.AsString := TDBCheckBox(Components[Index]).Hint;

        end;
//        if dmMaxxLocal.cdsCampos.State = dsEdit then
//        begin
//           dmMaxxLocal.cdsCampos.Post;
//           dmMaxxLocal.cdsCampos.ApplyUpdates(0);
//        end;
      end
      else
      begin
        dmMaxxLocal.cdsCampos.Append;
        dmMaxxLocal.cdsCamposCAMPO.AsString := NomeCampo;

        if Components[Index].ClassType = TJvDBMaskEdit then
           dmMaxxLocal.cdsCamposLABEL.AsString := LocalizaLabel(TJvDBMaskEdit(Components[Index]));
        if Components[Index].ClassType = TJvDBDateEdit then
           dmMaxxLocal.cdsCamposLABEL.AsString := LocalizaLabel(TJvDBDateEdit(Components[Index]));
        if Components[Index].ClassType = TJvDBCalcEdit then
           dmMaxxLocal.cdsCamposLABEL.AsString := LocalizaLabel(TJvDBCalcEdit(Components[Index]));
        if Components[Index].ClassType = TJvDBComboBox then
           dmMaxxLocal.cdsCamposLABEL.AsString := LocalizaLabel(TJvDBComboBox(Components[Index]));
        if Components[Index].ClassType = TJvDBCheckBox then
           dmMaxxLocal.cdsCamposLABEL.AsString := TJvDBCheckBox(Components[Index]).Caption;
        if Components[Index].ClassType = TDBMemo then
           dmMaxxLocal.cdsCamposLABEL.AsString := LocalizaLabel(TDBMemo(Components[Index]));
        if Components[Index].ClassType = TDBEdit then
           dmMaxxLocal.cdsCamposLABEL.AsString := LocalizaLabel(TDBEdit(Components[Index]));
        if Components[Index].ClassType = TDBRadioGroup then
           dmMaxxLocal.cdsCamposLABEL.AsString := TDBRadioGroup(Components[Index]).Caption;
        if Components[Index].ClassType = TDBCheckBox then
           dmMaxxLocal.cdsCamposLABEL.AsString := TDBCheckBox(Components[Index]).Caption;

        dmMaxxLocal.cdsCamposHINT.AsString  := Hint;
      end;
    end;
  except
    on E: Exception do
       TfrmMensagens.Mensagem(NomeCampo + ': ' + E.Message, 'E', Self.Caption, [mbOk]);
  end;
end;

procedure TfrmMaster.FormKeyPress(Sender: TObject; var Key: Char);
begin
  try
    if Self.ActiveControl <> nil then
    begin
      if (Key = #13) and
         (Self.ActiveControl.ClassType <> TDBMemo) and
         (Self.ActiveControl.ClassType <> TMemo) and
         (not(Self.ActiveControl is TCustomMemo)) and
         (TEdit(Self.ActiveControl).Name <> 'edtCodigo')and
         (TJvDBUltimGrid(Self.ActiveControl).Name <> 'grdIndice') then
      begin
         Perform(CM_DialogKey, VK_TAB, 0);
         Key := #0;
      end
      else
      begin
        //Preenchendo data se digitar T ou D
        if GetPropInfo(Self.ActiveControl.ClassInfo, 'Date') <> nil then
        begin
          if (Key = 'T') or (Key = 'D') or
             (Key = 't') or (Key = 'd') then
          begin
            Key := #0;
            SetPropValue(Self.ActiveControl, 'Date', Now);
  //          Perform(CM_DialogKey, VK_TAB, 0);
          end;
        end;
      end;
    end;
  except
  end;
end;

procedure TfrmMaster.FormShow(Sender: TObject);
var
  I: Integer;
begin
  try
    // Posicionar formulário
    TForm(Self).Top  := 25;
    TForm(Self).Left := 65;
    // Carregar barra de informações
    stbMaster.Panels[0].Text := Self.Name;
    stbMaster.Panels[1].Text := '';

    // ************************* AQUI ESTÁ O ERRO NA ABERTURA DOS FORMS ********************
    //Setando foco componente
    if (Foco <> nil) then
    begin
      if (Foco.Enabled) and (Foco.Visible) then
      begin
        SetarFocoComponente(Foco);
//        Self.FocusControl(Foco);
//        Self.ActiveControl := Foco;
      end;
    end;

    dmMaxxLocal.cdsParametros.Close;
    dmMaxxLocal.cdsParametros.Params[0].AsString := dmMaxxLocal.empresaLogadaCOD_EMP.AsString;
    dmMaxxLocal.cdsParametros.Open;

//    ComponentBack := Self.ActiveControl;
    ComponentBack := nil;
    ColorDisabled := LAYOUT_CORPANEL;//$F8F8FF;

    if AbrirNormal then
      SetarPropriedadesIniciais;

    /////////////////////////////////////////////////////////////////////////////
    ///  Como foi desabilitado o hint, não é preciso rodar esse for acima...  ///
    ///  somente padronizar 1 elemento;                                       ///
    /////////////////////////////////////////////////////////////////////////////
    TdxStatusBarPanelStyle(stbMaster.Panels[0].PanelStyle).Font.Color := $0048641E;
    TdxStatusBarPanelStyle(stbMaster.Panels[0].PanelStyle).Font.Name  := 'Tahoma';
    TdxStatusBarPanelStyle(stbMaster.Panels[0].PanelStyle).Font.Size  := 8;
    TdxStatusBarPanelStyle(stbMaster.Panels[0].PanelStyle).Color      := LAYOUT_CORPANEL;

    if Self.PopupMenu = nil then
      Self.PopupMenu := frmPrincipal.ppOpcoes;

    LimpaMemoriaAPP;
  except
  end;
end;

procedure TfrmMaster.PermitirAcessoComponente;
var
   i: Integer;
begin
  try
    for i := 0 to (ComponentCount - 1) do
    begin
       if (IsPublishedProp(Components[i], 'Tag')) then
       begin
          if (TComponent(Components[i]).Tag = 1) then
          begin
            if ListaComponentesPermitidos <> nil then
            begin
              if (ListaComponentesPermitidos.IndexOf(TComponent(Components[i]).Name) < 0) then
              begin
                TEdit(Components[i]).Enabled := False;
              end;
            end;
          end;
       end;
    end;

  except
    on e : exception do
      ShowMessage('Erro:' + TComponent(Components[i]).Name + '   ' + e.Message);
  end;
end;


procedure TfrmMaster.WMMove(var Msg: TWMMove);
begin
  try
   if Left < 0 then
      Left := 0;
   if Top < 0 then
      Top := 0;
   if Screen.Width - (Left + Width) < 0 then
      Left := Screen.Width - Width;
   if Screen.Height - (Top + Height) < 0 then
      Top := Screen.Height - Height;
  except
  end;
end;

function TfrmMaster.DataMaiorQueAtual(Data: TDateTime): Boolean;
begin
  Result := True;

  if dmMaxxLocal.cdsParametrosPARAM_ABDATA.AsString = 'S' then
  begin
    if Data > dmMaxxLocal.cdsDataHoraDATA_HORA.AsDateTime then
    begin
      tFrmMensagens.Mensagem('Não é permitido lançar movimentação com a data maior que a data atual. '+ #13 +
                             'Data informada:' + DateToStr(Data)+ #13 +
                             'Data atual: ' + DateToStr(dmMaxxLocal.cdsDataHoraDATA_HORA.AsDateTime), 'C', Self.Caption, [mbOk]);
      Result := False;
    end;
  end
  else
  begin
    if dmMaxxLocal.cdsParametrosPARAM_OBGDTMOV.AsString = 'S' then
    begin
      if Data > dmMaxxLocal.cdsParametrosPARAM_DTFIN_OBGDTMOV.AsDateTime then
      begin
        tFrmMensagens.Mensagem('Não é permitido lançar movimentação com a data superior a data máxima permitida.'+ #13 +
                               'Data informada:' + DateToStr(Data)+ #13 +
                               'Data máxima permitida:' + DateToStr(dmMaxxLocal.cdsParametrosPARAM_DTFIN_OBGDTMOV.AsDateTime),
                               'C', Self.Caption, [mbOk]);
        Result := False;
      end;
    end;
  end;
end;

function TfrmMaster.DataMenorQueAtual(Data: TDateTime): Boolean;
begin
  Result := True;

  if dmMaxxLocal.cdsParametrosPARAM_ALDATA.AsString = 'S' then
  begin
    if Data < (dmMaxxLocal.cdsDataHoraDATA_HORA.AsDateTime - 90) then
    begin
      tFrmMensagens.Mensagem('Não é permitido lançar movimentação com a data inferior a 90 dias da data atual.'+ #13 +
                             'Data informada:' + DateToStr(Data)+ #13 +
                             'Data atual: ' + DateToStr(dmMaxxLocal.cdsDataHoraDATA_HORA.AsDateTime), 'C', Self.Caption, [mbOk]);
      Result := False;
    end
    else //verificando se a data é menor que o período permitido de lançamento conforme parametros
    begin
      if dmMaxxLocal.cdsParametrosPARAM_OBGDTMOV.AsString = 'S' then
      begin
        if Data < dmMaxxLocal.cdsParametrosPARAM_DTINI_OBGDTMOV.AsDateTime then
        begin
          tFrmMensagens.Mensagem('Não é permitido lançar movimentação com a data inferior a data mínima permitida.'+ #13 +
                                 'Data informada:' + DateToStr(Data)+ #13 +
                                 'Data mínima permitida:' + DateToStr(dmMaxxLocal.cdsParametrosPARAM_DTINI_OBGDTMOV.AsDateTime),
                                 'C', Self.Caption, [mbOk]);
          Result := False;
        end;
      end;
    end;
  end
  else //verificando se a data é menor que o período permitido de lançamento conforme parametros
  begin
    if dmMaxxLocal.cdsParametrosPARAM_OBGDTMOV.AsString = 'S' then
    begin
      if Data < dmMaxxLocal.cdsParametrosPARAM_DTINI_OBGDTMOV.AsDateTime then
      begin
        tFrmMensagens.Mensagem('Não é permitido lançar movimentação com a data inferior a data mínima permitida.'+ #13 +
                               'Data informada:' + DateToStr(Data)+ #13 +
                               'Data mínima permitida:' + DateToStr(dmMaxxLocal.cdsParametrosPARAM_DTINI_OBGDTMOV.AsDateTime),
                               'C', Self.Caption, [mbOk]);
        Result := False;
      end;
    end;
  end;
end;

procedure TfrmMaster.ValidarDataMovimentacao;
var
  Data : TComponent;
begin
  try
    Data := Screen.ActiveForm.ActiveControl;

    if (ListaObrigatorios.IndexOf(data.name) > 0)  then
    begin
      if Data is TJvDBDateEdit then
      begin
        dmMaxxLocal.cdsDataHora.Open;
        if (TJvDBDateEdit(Data).HelpKeyword = '')  then
        begin
          if ((DataMaiorQueAtual(TJvDBDateEdit(Data).Date) = False) or
             (DataMenorQueAtual(TJvDBDateEdit(Data).Date) = False)) then
          begin
             TJvDBDateEdit(Data).SetFocus;
             abort;
          end;
        end
        else if (TJvDBDateEdit(Data).HelpKeyword = 'NAO')  then
        begin
          if (DataMenorQueAtual(TJvDBDateEdit(Data).Date) = False) then
          begin
             TJvDBDateEdit(Data).SetFocus;
             abort;
          end;
        end;
      end;

      if Data is TRzDateTimeEdit then
      begin
        dmMaxxLocal.cdsDataHora.Open;

        if (TRzDateTimeEdit(Data).HelpKeyword = '')then
        begin
          if ((DataMaiorQueAtual(TRzDateTimeEdit(Data).Date) = False) or
             (DataMenorQueAtual(TRzDateTimeEdit(Data).Date) = False)) then
          begin
             TRzDateTimeEdit(Data).SetFocus;
             abort;
          end;
        end
        else if (TRzDateTimeEdit(Data).HelpKeyword = 'NAO')  then
        begin
          if (DataMenorQueAtual(TRzDateTimeEdit(Data).Date) = False) then
          begin
             TRzDateTimeEdit(Data).SetFocus;
             abort;
          end;
        end;
      end;

      if Data is TRzDBDateTimeEdit then
      begin
        dmMaxxLocal.cdsDataHora.Open;
        if (TRzDBDateTimeEdit(Data).HelpKeyword = '') then
        begin
          if ((DataMaiorQueAtual(TRzDBDateTimeEdit(Data).Date) = False) or
             (DataMenorQueAtual(TRzDBDateTimeEdit(Data).Date) = False)) then
          begin
             TRzDBDateTimeEdit(Data).SetFocus;
             abort;
          end;
        end
        else if (TRzDBDateTimeEdit(Data).HelpKeyword = 'NAO')  then
        begin
          if (DataMenorQueAtual(TRzDBDateTimeEdit(Data).Date) = False) then
          begin
             TRzDBDateTimeEdit(Data).SetFocus;
             abort;
          end;
        end;
      end;

      if Data is TcxDateEdit then
      begin
        dmMaxxLocal.cdsDataHora.Open;
        if (TcxDateEdit(Data).HelpKeyword = '') then
        begin
          if ((DataMaiorQueAtual(TcxDateEdit(Data).Date) = False) or
             (DataMenorQueAtual(TcxDateEdit(Data).Date) = False)) then
          begin
             TcxDateEdit(Data).SetFocus;
             abort;
          end;
        end
        else if (TcxDateEdit(Data).HelpKeyword = 'NAO')  then
        begin
          if (DataMenorQueAtual(TcxDateEdit(Data).Date) = False) then
          begin
             TcxDateEdit(Data).SetFocus;
             abort;
          end;
        end;
      end;

      if Data is TcxDBDateEdit then
      begin
        dmMaxxLocal.cdsDataHora.Open;
        if (TcxDBDateEdit(Data).HelpKeyword = '') then
        begin
          if ((DataMaiorQueAtual(TcxDBDateEdit(Data).Date) = False) or
             (DataMenorQueAtual(TcxDBDateEdit(Data).Date) = False)) then
          begin
             TcxDBDateEdit(Data).SetFocus;
             abort;
          end;
        end
        else if (TcxDBDateEdit(Data).HelpKeyword = 'NAO')  then
        begin
          if (DataMenorQueAtual(TcxDBDateEdit(Data).Date) = False) then
          begin
             TcxDBDateEdit(Data).SetFocus;
             abort;
          end;
        end;
      end;

{      if Data is TJvDBDateEdit then
      begin
        dmMaxxLocal.cdsDataHora.Open;
        if (DataMaiorQueAtual(TJvDBDateEdit(Data).Date) = False) or
           (DataMenorQueAtual(TJvDBDateEdit(Data).Date) = False) then
        begin
           TJvDBDateEdit(Data).SetFocus;
           Abort;
        end;
      end;

      if Data is TRzDBDateTimeEdit then
      begin
        dmMaxxLocal.cdsDataHora.Open;
        if (DataMaiorQueAtual(TRzDBDateTimeEdit(Data).Date) = False) or
           (DataMenorQueAtual(TRzDBDateTimeEdit(Data).Date) = False) then
        begin
           TRzDBDateTimeEdit(Data).SetFocus;
           Abort;
        end;
      end;

      if Data is TcxDBDateEdit then
      begin
        dmMaxxLocal.cdsDataHora.Open;
        if (DataMaiorQueAtual(TcxDBDateEdit(Data).Date) = False) or
           (DataMenorQueAtual(TcxDBDateEdit(Data).Date) = False) then
        begin
           TcxDBDateEdit(Data).SetFocus;
           Abort;
        end;
      end; }
    end;
  finally
    dmMaxxLocal.cdsDataHora.Close;
  end;
end;

procedure TfrmMaster.BeforeDelete(DataSet: TDataSet);
var
  I : Integer;
  Cod, CodDetalhe: String;
begin
  if (Pos(UpperCase('PlanoFinPrev'), UpperCase(DataSet.Name)) <= 0)
    and (Pos(UpperCase('DocOriNotaEntPagar'), UpperCase(DataSet.Name)) <= 0)
    and (Pos(UpperCase('DocOrig'), UpperCase(DataSet.Name)) <= 0)


    then
  begin
    with dmMaxxLocal do
    begin
      //verificando se já existe o cabeçalho do log, caso não exista para esta tela, adiciona novo
      if dmMaxxLocal.cdsParametrosPARAM_GERALOG.AsString = 'S' then
      begin
        cdsTempLog.DisableControls;

        cdsTempLog.Filtered := False;
        cdsTempLog.Filter   := 'FORMULARIO = ' + QuotedStr(Self.Caption);
        cdsTempLog.Filtered := True;

        if not cdsTempLog.IsEmpty then
        begin
          Cod := cdsTempLogLOG_COD.AsString;
        end
        else
        begin

          if Pos('Prev', TClientDataSet(DataSet).Name) = 0 then
          begin
            cdsTempLog.Append;

            cdsTempLogCOD_EMP.AsString    := dmMaxxLocal.empresaLogadaCOD_EMP.AsString;
            cdsTempLogCOD_USU.AsString    := dmMaxxLocal.loginUsuarioCOD_USU.AsString;
            cdsTempLogUSUARIO.AsString    := dmMaxxLocal.loginUsuarioLOGIN_USU.AsString;
            cdsTempLogFORMULARIO.AsString := Self.Caption;
            cdsTempLogMODULO.AsString     := IdSistema;
            cdsTempLogDATA.AsDateTime     := Date;
            cdsTempLogHORA.AsDateTime     := Time;

            dmMaxxLocal.novoCodigo.Params[0].AsString := 'LOG_COD';
            dmMaxxLocal.novoCodigo.Params[1].AsString := dmMaxxLocal.empresaLogadaCOD_EMP.AsString;
            dmMaxxLocal.novoCodigo.ExecuteMethod;

            cdsTempLogLOG_COD.AsString := dmMaxxLocal.novoCodigo.Params[2].AsString;
            dmMaxxLocal.novoCodigo.Close;
            Cod := cdsTempLogLOG_COD.AsString;
            cdsTempLog.Post;
          end
          else Cod := '';
        end;
        cdsTempLog.EnableControls;
        //verificando se não é algum financeiro.
        if Cod <> '' then
        begin
          //adicionando detalhes
          //verificando se não existe detalhe com o mesmo código do log, mesmo código do movimento, evitando duplicidade.
          for I := 0 to DataSet.FieldCount - 1 do
          begin
            if (DataSet.Fields[i].ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]) and
               (DataSet.Fields[i].Name <> 'COD_EMP') then
            begin
               CodDetalhe := DataSet.Fields[i].AsString;
               Break;
            end;
          end;

          cdsTempLogDetalhes.DisableControls;
          cdsTempLogDetalhes.Filtered := False;
          cdsTempLogDetalhes.Filter   := ' TELAMOVIMENTO = '+ QuotedStr(TClientDataSet(DataSet).Name) +
                                         ' AND LOG_COD = '  + QuotedStr(Cod) +
                                         ' AND CODIGO = '   + QuotedStr(CodDetalhe);
          cdsTempLogDetalhes.Filtered := True;

          if not cdsTempLogDetalhes.IsEmpty then
          begin
            cdsTempLogDetalhes.First;
            while not cdsTempLogDetalhes.Eof do
            begin
              cdsTempLogValores.DisableControls;
              cdsTempLogValores.First;
              while not cdsTempLogValores.Eof do
              begin
                cdsTempLogValores.Filtered := False;
                cdsTempLogValores.Filter   := 'LOGDET_COD = ' + QuotedStr(cdsTempLogDetalhesLOGDET_COD.AsString);
                cdsTempLogValores.Filtered := True;

                if not cdsTempLogValores.IsEmpty then
                   cdsTempLogValores.Delete;
              end;
              cdsTempLogDetalhes.Delete;
            end;
            cdsTempLogDetalhes.EnableControls;
          end;
          cdsTempLogValores.Filtered  := False;
          cdsTempLogDetalhes.Filtered := False;

          cdsTempLogDetalhes.Append;
          cdsTempLogDetalhesCOD_EMP.AsString := dmMaxxLocal.empresaLogadaCOD_EMP.AsString;
          cdsTempLogDetalhesLOG_COD.AsString := Cod;

          dmMaxxLocal.novoCodigo.Params[0].AsString := 'LOGDET_COD';
          dmMaxxLocal.novoCodigo.Params[1].AsString := dmMaxxLocal.empresaLogadaCOD_EMP.AsString;
          dmMaxxLocal.novoCodigo.ExecuteMethod;

          cdsTempLogDetalhesLOGDET_COD.AsString := dmMaxxLocal.novoCodigo.Params[2].AsString;
          dmMaxxLocal.novoCodigo.Close;

          cdsTempLogDetalhesTIPO.AsString := 'Exclusão';

          if TClientDataSet(DataSet).Name = 'cdsMaster' then
             cdsTempLogDetalhesTELAMOVIMENTO.AsString   := TClientDataSet(DataSet).ProviderName
          else cdsTempLogDetalhesTELAMOVIMENTO.AsString := TClientDataSet(DataSet).Name;

          cdsTempLogDetalhesCODIGO.AsString        := CodDetalhe;
          cdsTempLogDetalhes.Post;


          for I := 0 to DataSet.FieldCount - 1 do
          begin
            if not(DataSet.Fields[i] is TDataSetField) then
            begin
              if (cdsTempLogDetalhesTIPO.AsString = 'Exclusão') then
              begin
                if (VarType(DataSet.Fields[i].NewValue) <> varEmpty) and
                   (VarType(DataSet.Fields[i].NewValue) <> varNull) then
                begin
                  cdsTempLogValores.Append;

                  dmMaxxLocal.novoCodigo.Params[0].AsString := 'LOGVAL_COD';
                  dmMaxxLocal.novoCodigo.Params[1].AsString := dmMaxxLocal.empresaLogadaCOD_EMP.AsString;
                  dmMaxxLocal.novoCodigo.ExecuteMethod;

                  cdsTempLogValoresLOGVAL_COD.AsString  := dmMaxxLocal.novoCodigo.Params[2].AsString;
                  dmMaxxLocal.novoCodigo.Close;

                  cdsTempLogValoresCOD_EMP.AsString     := dmMaxxLocal.empresaLogadaCOD_EMP.AsString;
                  cdsTempLogValoresLOGDET_COD.AsString  := cdsTempLogDetalhesLOGDET_COD.AsString;
                  cdsTempLogValoresCAMPO.AsString       := DataSet.Fields[I].FieldName;
                  cdsTempLogValoresNEWVALUE.AsString    := VarToStr(DataSet.Fields[i].NewValue);
                  cdsTempLogValoresOLDVALUE.Clear;

                  cdsTempLogValores.Post;
                end;
              end;
            end;
          end;
          if (cdsTempLogValores.IsEmpty) then
             cdsTempLogDetalhes.Delete;
        end;
      end;
    end;
  end;
end;

procedure TfrmMaster.AfterPost(DataSet : TDataSet);
var
  LogAfterPost : TThread;
  I : Integer;
  Cod, CodDetalhe: String;
begin
  ConcluirLog := false;
  if (Pos(UpperCase('PlanoFinPrev'), UpperCase(DataSet.Name)) <= 0)
    and (Pos(UpperCase('cdsDocOriNotaEntPagar'), UpperCase(DataSet.Name)) <= 0)
    and (Pos(UpperCase('DocOrig'), UpperCase(DataSet.Name)) <= 0)
    and ((Assigned(TClientDataSet(DataSet).DataSetField)) or (TClientDataSet(DataSet).ProviderName <> ''))
    and (TClientDataSet(DataSet).ChangeCount >= 1)
    then
  begin
//  LogAfterPost := TThread.CreateAnonymousThread(procedure ()
//  begin
    with dmMaxxLocal do
    begin
      if cdsParametrosPARAM_GERALOG.AsString = 'S' then
      begin
//        tthread.Synchronize(LogAfterPost,
//        procedure()
//        var
//          I : Integer;
//          Cod, CodDetalhe: String;
//        begin
          //verificando se já existe o cabeçalho do log, caso não exista para esta tela, adiciona novo
          cdsTempLog.DisableControls;

          cdsTempLog.Filtered := False;
          cdsTempLog.Filter   := ' FORMULARIO = ' + QuotedStr(Self.Caption);
          cdsTempLog.Filtered := True;

          if not cdsTempLog.IsEmpty then
            Cod := cdsTempLogLOG_COD.AsString
          else
          begin
            if Pos('Prev', TClientDataSet(DataSet).Name) = 0 then
            begin
              cdsTempLog.Append;

              cdsTempLogCOD_EMP.AsString    := dmMaxxLocal.empresaLogadaCOD_EMP.AsString;
              cdsTempLogCOD_USU.AsString    := dmMaxxLocal.loginUsuarioCOD_USU.AsString;
              cdsTempLogUSUARIO.AsString    := dmMaxxLocal.loginUsuarioLOGIN_USU.AsString;
              cdsTempLogFORMULARIO.AsString := Self.Caption;
              cdsTempLogMODULO.AsString     := IdSistema;
              cdsTempLogDATA.AsDateTime     := Date;
              cdsTempLogHORA.AsDateTime     := Time;

              dmMaxxLocal.novoCodigo.Params[0].AsString := 'LOG_COD';
              dmMaxxLocal.novoCodigo.Params[1].AsString := dmMaxxLocal.empresaLogadaCOD_EMP.AsString;
              dmMaxxLocal.novoCodigo.ExecuteMethod;

              cdsTempLogLOG_COD.AsString := dmMaxxLocal.novoCodigo.Params[2].AsString;
              dmMaxxLocal.novoCodigo.Close;
              Cod := cdsTempLogLOG_COD.AsString;
              cdsTempLog.Post;
            end
            else Cod := '';
          end;
          cdsTempLog.Filtered := False;
          cdsTempLog.EnableControls;

          if Cod <> '' then
          begin
            //adicionando detalhes
            //verificando se não existe detalhe com o mesmo código do log, mesmo código do movimento, evitando duplicidade.
            for I := 0 to DataSet.FieldCount - 1 do
            begin
              if (DataSet.Fields[i].ProviderFlags = [pfInUpdate, pfInWhere, pfInKey]) and
                 (DataSet.Fields[i].Name <> 'COD_EMP') then
              begin
                 CodDetalhe := DataSet.Fields[i].AsString;
                 Break;
              end;
            end;

            cdsTempLogDetalhes.DisableControls;
            cdsTempLogDetalhes.Filtered := False;
            cdsTempLogDetalhes.Filter   := ' TELAMOVIMENTO = '+ QuotedStr(TClientDataSet(DataSet).Name) +
                                           ' AND LOG_COD = '  + QuotedStr(Cod) +
                                           ' AND CODIGO = '   + QuotedStr(CodDetalhe);
            cdsTempLogDetalhes.Filtered := True;

            if not cdsTempLogDetalhes.IsEmpty then
            begin
              cdsTempLogDetalhes.First;
              while not cdsTempLogDetalhes.Eof do
              begin
                cdsTempLogValores.DisableControls;
                cdsTempLogValores.First;
                while not cdsTempLogValores.Eof do
                begin
                  cdsTempLogValores.Filtered := False;
                  cdsTempLogValores.Filter   := 'LOGDET_COD = ' + QuotedStr(cdsTempLogDetalhesLOGDET_COD.AsString);
                  cdsTempLogValores.Filtered := True;

                  if not cdsTempLogValores.IsEmpty then
                     cdsTempLogValores.Delete;
                end;
                cdsTempLogDetalhes.Delete;
              end;
              cdsTempLogDetalhes.EnableControls;
            end;
            cdsTempLogValores.Filtered  := False;
            cdsTempLogDetalhes.Filtered := False;

            cdsTempLogDetalhes.Append;
            cdsTempLogDetalhesCOD_EMP.AsString := dmMaxxLocal.empresaLogadaCOD_EMP.AsString;
            cdsTempLogDetalhesLOG_COD.AsString := Cod;

            dmMaxxLocal.novoCodigo.Params[0].AsString := 'LOGDET_COD';
            dmMaxxLocal.novoCodigo.Params[1].AsString := dmMaxxLocal.empresaLogadaCOD_EMP.AsString;
            dmMaxxLocal.novoCodigo.ExecuteMethod;

            cdsTempLogDetalhesLOGDET_COD.AsString := dmMaxxLocal.novoCodigo.Params[2].AsString;
            dmMaxxLocal.novoCodigo.Close;

            if TClientDataSet(DataSet).UpdateStatus = usInserted then
               cdsTempLogDetalhesTIPO.AsString := 'Inserção'
            else if TClientDataSet(DataSet).UpdateStatus = usModified then
               cdsTempLogDetalhesTIPO.AsString := 'Edição'
            else if TClientDataSet(DataSet).UpdateStatus = usUnmodified then
            begin
              cdsTempLogDetalhes.Cancel;
              ConcluirLog := true;
              Exit;
            end;


            if TClientDataSet(DataSet).Name = 'cdsMaster' then
               cdsTempLogDetalhesTELAMOVIMENTO.AsString   := TClientDataSet(DataSet).ProviderName
            else cdsTempLogDetalhesTELAMOVIMENTO.AsString := TClientDataSet(DataSet).Name;

            cdsTempLogDetalhesCODIGO.AsString        := CodDetalhe;
            cdsTempLogDetalhes.Post;


            for I := 0 to DataSet.FieldCount - 1 do
            begin
              if not(DataSet.Fields[i] is TDataSetField)
                  and (DataSet.Fields[i].ReadOnly = False)
                  and (DataSet.Fields[i].ProviderFlags = [pfInUpdate])   then
              begin
                if (cdsTempLogDetalhesTIPO.AsString = 'Inserção') then
                begin
                  if (VarType(DataSet.Fields[i].NewValue) <> varEmpty) and
                     (VarType(DataSet.Fields[i].NewValue) <> varNull) then
                  begin
                    if DataSet.Fields[I].FieldName <> 'DUMANUT' then
                    begin
                      cdsTempLogValores.Append;

                      dmMaxxLocal.novoCodigo.Params[0].AsString := 'LOGVAL_COD';
                      dmMaxxLocal.novoCodigo.Params[1].AsString := dmMaxxLocal.empresaLogadaCOD_EMP.AsString;
                      dmMaxxLocal.novoCodigo.ExecuteMethod;

                      cdsTempLogValoresLOGVAL_COD.AsString  := dmMaxxLocal.novoCodigo.Params[2].AsString;
                      dmMaxxLocal.novoCodigo.Close;

                      cdsTempLogValoresCOD_EMP.AsString     := dmMaxxLocal.empresaLogadaCOD_EMP.AsString;
                      cdsTempLogValoresLOGDET_COD.AsString  := cdsTempLogDetalhesLOGDET_COD.AsString;
                      cdsTempLogValoresCAMPO.AsString       := DataSet.Fields[I].FieldName;
                      cdsTempLogValoresNEWVALUE.AsString    := VarToStr(DataSet.Fields[i].NewValue);
                      cdsTempLogValoresOLDVALUE.Clear;

                      cdsTempLogValores.Post;
                    end;
                  end;
                end
                else
                if (cdsTempLogDetalhesTIPO.AsString = 'Edição') then
                begin
                  if (VarToStr(DataSet.Fields[i].OldValue) <> VarToStr(DataSet.Fields[i].NewValue)) then
                  begin
                    if DataSet.Fields[I].FieldName <> 'DUMANUT' then
                    begin
                      cdsTempLogValores.Append;

                      dmMaxxLocal.novoCodigo.Params[0].AsString := 'LOGVAL_COD';
                      dmMaxxLocal.novoCodigo.Params[1].AsString := dmMaxxLocal.empresaLogadaCOD_EMP.AsString;
                      dmMaxxLocal.novoCodigo.ExecuteMethod;

                      cdsTempLogValoresLOGVAL_COD.AsString  := dmMaxxLocal.novoCodigo.Params[2].AsString;
                      dmMaxxLocal.novoCodigo.Close;

                      cdsTempLogValoresCOD_EMP.AsString     := dmMaxxLocal.empresaLogadaCOD_EMP.AsString;
                      cdsTempLogValoresLOGDET_COD.AsString  := cdsTempLogDetalhesLOGDET_COD.AsString;
                      cdsTempLogValoresCAMPO.AsString       := DataSet.Fields[I].FieldName;
                      cdsTempLogValoresNEWVALUE.AsString    := VarToStr(DataSet.Fields[i].NewValue);
                      cdsTempLogValoresOLDVALUE.AsString    := VarToStr(DataSet.Fields[i].OldValue);

                      cdsTempLogValores.Post;
                    end;
                  end;
                end;
              end;
            end;
            if (cdsTempLogValores.IsEmpty) then
               cdsTempLogDetalhes.Delete;
          end;
          ConcluirLog := True;
//        end);
      end;
    end;
//  end);
//  LogAfterPost.start;

  end;
end;

procedure TfrmMaster.SalvarLog(Formulario, Modulo: String);
var
  CodLog, CodDetalhe: String;
  SalvarLogTh : TThread;
begin
  SalvarLogTh := TThread.CreateAnonymousThread(procedure ()
  begin
    with dmMaxxLocal do
    begin
      if cdsParametrosPARAM_GERALOG.AsString = 'S' then
      begin
        tthread.Synchronize(SalvarLogTh,
        procedure()
        begin
          //Cabeçalho do log
          cdsTempLog.DisableControls;
          cdsTempLog.First;
          while not cdsTempLog.Eof do
          begin
            if (cdsTempLogFORMULARIO.AsString = Formulario) and
               (cdsTempLogMODULO.AsString     = Modulo) then
            begin
              CodLog := cdsTempLogLOG_COD.AsString;
              cdsMAXXLOG.Close;
              cdsMAXXLOG.Open;
              cdsMAXXLOG.Append;

              cdsMAXXLOGLOG_COD.AsString    := cdsTempLogLOG_COD.AsString;
              cdsMAXXLOGCOD_EMP.AsString    := cdsTempLogCOD_EMP.AsString;
              cdsMAXXLOGCOD_USU.AsString    := cdsTempLogCOD_USU.AsString;
              cdsMAXXLOGUSUARIO.AsString    := cdsTempLogUSUARIO.AsString;
              cdsMAXXLOGFORMULARIO.AsString := cdsTempLogFORMULARIO.AsString;
              cdsMAXXLOGMODULO.AsString     := cdsTempLogMODULO.AsString;
              cdsMAXXLOGDATA.AsDateTime     := cdsTempLogDATA.AsDateTime;
              cdsMAXXLOGHORA.AsDateTime     := cdsTempLogHORA.AsDateTime;
              cdsMAXXLOG.Post;
              cdsTempLog.Delete;
              Break;
            end;
            cdsTempLog.Next;
          end;
          cdsTempLog.EnableControls;

          //Detalhe do log e valores
          cdsTempLogDetalhes.DisableControls;
          cdsTempLogDetalhes.First;
          while not cdsTempLogDetalhes.Eof do
          begin
            if cdsTempLogDetalhesLOG_COD.AsString = CodLog then
            begin
              CodDetalhe                           := cdsTempLogDetalhesLOGDET_COD.AsString;
              cdsLOGDETALHES.Append;
              cdsLOGDETALHESLOGDET_COD.AsString    := cdsTempLogDetalhesLOGDET_COD.AsString;
              cdsLOGDETALHESCOD_EMP.AsString       := cdsTempLogDetalhesCOD_EMP.AsString;
              cdsLOGDETALHESTIPO.AsString          := cdsTempLogDetalhesTIPO.AsString;
              cdsLOGDETALHESLOG_COD.AsString       := cdsTempLogDetalhesLOG_COD.AsString;
              cdsLOGDETALHESCODIGO.AsString        := cdsTempLogDetalhesCODIGO.AsString;
              cdsLOGDETALHESTELAMOVIMENTO.AsString := cdsTempLogDetalhesTELAMOVIMENTO.AsString;
              cdsLOGDETALHES.Post;
              cdsTempLogDetalhes.Delete;

              cdsTempLogValores.DisableControls;
              cdsTempLogValores.First;
              while not cdsTempLogValores.Eof do
              begin
                if cdsTempLogValoresLOGDET_COD.AsString = CodDetalhe then
                begin
                  cdsLOGVALORES.Append;
                  cdsLOGVALORESLOGVAL_COD.AsString := cdsTempLogValoresLOGVAL_COD.AsString;
                  cdsLOGVALORESLOGDET_COD.AsString := cdsTempLogValoresLOGDET_COD.AsString;
                  cdsLOGVALORESCOD_EMP.AsString    := cdsTempLogValoresCOD_EMP.AsString;
                  cdsLOGVALORESCAMPO.AsString      := cdsTempLogValoresCAMPO.AsString;
                  cdsLOGVALORESNEWVALUE.AsVariant  := cdsTempLogValoresNEWVALUE.AsVariant;
                  cdsLOGVALORESOLDVALUE.AsVariant  := cdsTempLogValoresOLDVALUE.AsVariant;
                  cdsLOGVALORES.Post;
                  cdsTempLogValores.Delete;
                end
                else cdsTempLogValores.Next;
              end;
              cdsTempLogValores.EnableControls;
            end
            else cdsTempLogDetalhes.Next;
          end;
          cdsTempLogDetalhes.EnableControls;

          if not cdsMAXXLOG.IsEmpty then
          begin
            if cdsLOGVALORES.IsEmpty then
            begin
              while cdsLOGDETALHES.Eof = false do
                cdsLOGDETALHES.Delete;
            end;

            if cdsLOGDETALHES.IsEmpty then
               cdsMAXXLOG.Delete
            else cdsMAXXLOG.ApplyUpdates(0);
          end;
        end);
      end;
    end;
  end);
  SalvarLogTh.Start;
end;

procedure TfrmMaster.stbMaster1DrawPanel(StatusBar: TStatusBar; Panel: TStatusPanel; const Rect: TRect);
begin
  if Panel.Index = 0 then
  begin
    StatusBar.Canvas.Font.Color := clBlack;
    StatusBar.Canvas.TextRect(Rect,Rect.Left,Rect.Top, Panel.text);
  end
  else if Panel.Index = 1 then
  begin
    StatusBar.Canvas.Font.Color := LAYOUT_CORBOTAOPADRAO;
    StatusBar.Canvas.TextRect(Rect,Rect.Left,Rect.Top, Panel.text);
  end;
end;

procedure TfrmMaster.VideoAdjust(Form: TForm);
const
  ScreenWidth: LongInt = 1980; // número de pontos usado no desenvolvimento
  ScreenHeight: LongInt = 1024; // número de pontos usado no desenvolvimento
var
  i: integer;
  NewFormWidth, OldFormWidth : Integer;
begin
  with Form do
  begin
    if Screen.Width = ScreenWidth then
      Exit;
    OldFormWidth := Width;

    Scaled := true;
    Height := Longint(height) * Longint(Screen.Height) DIV ScreenHeight;
    Width := Longint(Width) * Longint(Screen.Width) DIV ScreenWidth;
    ScaleBy(Screen.Width, ScreenWidth);

    NewFormWidth := Width;

    // O tamanho da fonte dos objetos que tem essa propriedade deverá ser ajustado
    // Para usar GetPropInfo, deverá ser adicionado Uses TypInfo.
    for i := ComponentCount - 1 downto 0 do
      with components[i] do
        if GetPropInfo(ClassInfo, 'font') <> nil then
          Font.Size := (NewFormWidth DIV OldFormWidth) * Font.Size;
  end; // with
end; // VideoAdjust

procedure TfrmMaster.SetarPropriedadesIniciais;
var
  Contexto: TRttiContext;
  Tipo: TRttiType;
  I, K: Integer;
  Controle : String;
  Fonte: TFont;
//  MemoControle : Tmemo;
begin
 if not value then
   Value := False;

//  MemoControle := TMemo.Create(Self);

  if dmMaxxLocal.cdsParametrosPARAM_GERALOG.AsString = 'S' then
  begin
    for I := 0 to ComponentCount - 1 do
    begin
      tthread.Synchronize(TThread.CurrentThread,
      procedure()
      begin
        if Components[i] is TClientDataSet then
        begin
          if ((Components[i] as TClientDataSet).Name <> 'cdsOpcoes') and
            (Pos('Estoque', (Components[i] as TClientDataSet).Name) = 0) then
          begin
            (Components[i] as TClientDataSet).AfterPost    := AfterPost;

            if ((Self.Caption = 'Nota fiscal de entrada') or (Self.Caption = 'Pedido de compra') or
               (Self.Caption = 'Pedido de compra de grãos')) then
            begin
              if TClientDataSet(Components[i]).Name <> 'cdsMaster' then
                (Components[i] as TClientDataSet).BeforeDelete := BeforeDelete;
            end
            else (Components[i] as TClientDataSet).BeforeDelete := BeforeDelete;
          end;
        end;

        if Components[i].ClassType = TJvDBMaskEdit then
          Campo(i, TJvDBMaskEdit(Components[i]).DataField, TJvDBMaskEdit(Components[i]).Hint);
        if Components[i].ClassType = TJvDBDateEdit then
          Campo(i, TJvDBDateEdit(Components[i]).DataField, TJvDBDateEdit(Components[i]).Hint);
        if Components[i].ClassType = TJvDBCalcEdit then
          Campo(i, TJvDBCalcEdit(Components[i]).DataField, TJvDBCalcEdit(Components[i]).Hint);
        if Components[i].ClassType = TJvDBCheckBox then
        begin
          if (TJvDBCheckBox(Components[i]).Name = 'chbINATIVO') and (TJvDBCheckBox(Components[i]).DataField <> '') then
              Campo(i, TJvDBCheckBox(Components[i]).DataField, TJvDBCheckBox(Components[i]).Hint);
        end;
        if Components[i].ClassType = TJvDBComboBox then
          Campo(i, TJvDBComboBox(Components[i]).DataField, TJvDBComboBox(Components[i]).Hint);
        if Components[i].ClassType = TDBMemo then
          Campo(i, TDBMemo(Components[i]).DataField, TDBMemo(Components[i]).Hint);
        if Components[i].ClassType = TDBEdit then
          Campo(i, TDBEdit(Components[i]).DataField, TDBEdit(Components[i]).Hint);
        if Components[i].ClassType = TDBRadioGroup then
          Campo(i, TDBRadioGroup(Components[i]).DataField, TDBRadioGroup(Components[i]).Hint);
        if Components[i].ClassType = TDBCheckBox then
          Campo(i, TDBCheckBox(Components[i]).DataField, TDBCheckBox(Components[i]).Hint);

        if dmMaxxLocal.cdsCampos.State in [dsEdit, dsInsert] then
        begin
         dmMaxxLocal.cdsCampos.Post;
        end;
        dmMaxxLocal.cdsCampos.ApplyUpdates(0);
      end);
    end;
  end;

  for I := 0 to ComponentCount - 1 do
  begin
    //Componentes permitidos em cados de usuário administrador
    try
      if (Components[i].ClassType <> TfrxReport)    and
         (Components[i].ClassType <> TfrxDBDataset) and
         (Components[i].ClassType <> TPageControl)  then
      begin
        if (IsPublishedProp(Components[i], 'DataSource')) and
          (IsPublishedProp(Components[i], 'Enabled')) then
        begin
          if (IsPublishedProp(Components[i], 'TabStop')) then
          begin
             if TEdit(Components[i]).TabStop then
                TEdit(Components[i]).Enabled := Value
             else TEdit(Components[i]).Enabled := False;
          end
          else TEdit(Components[i]).Enabled := True;


          if (IsPublishedProp(Components[i], 'Scaled')) then
          begin
             TForm(Components[i]).Scaled := False;
          end;

          if Value then
          begin
            if (IsPublishedProp(Components[i], 'TabStop')) then
            begin
               if TEdit(Components[i]).TabStop then
               begin
                  TEdit(Components[i]).Enabled := Value;
               end
               else begin
                 TEdit(Components[i]).Enabled := False;
               end;
            end
          end;

          if (Components[i].ClassType = TGroupBox) then
          begin
            TGroupBox(Components[i]).TabStop := False;
          end;
//
          if (Components[i].ClassType = TDBEdit) or
             (Components[i].ClassType = TJvDBMaskEdit) or
             (Components[i].ClassType = TJvDBCalcEdit) or
             (Components[i].ClassType = TDBMemo) or
             (Components[i].ClassType = TcxDBDateEdit) or
             (Components[i].ClassType = TJvDBComboBox) or
             (Components[I].ClassType = TcxDBTreeList) or
             (Components[i] is TJvDBMaskEdit) then
          begin
             TEdit(Components[i]).Enabled := Value;
             if Value then
             begin
                if (IsPublishedProp(Components[i], 'TabStop')) then
                begin
                   if TEdit(Components[i]).TabStop then
                   begin
                      TEdit(Components[i]).Enabled := Value;
                   end
                   else begin
                     TEdit(Components[i]).Enabled := False;
                   end;
                end
             end;

             if TEdit(Components[i]).ReadOnly then
                TEdit(Components[i]).Enabled := False;
          end;

          if ((Components[i].ClassType = TJvDBUltimGrid)
            or (Components[i].ClassType = TDBGrid)) then
          begin
            TJvDBUltimGrid(Components[i]).Enabled := True;
            TJvDBUltimGrid(Components[i]).DotNetHighlighting := true;
            for k := 0 to (TJvDBUltimGrid(Components[i]).Columns.Count - 1) do
            begin
               TJvDBUltimGrid(Components[i]).Columns[k].Title.Alignment := taCenter;
            end;
          end else if (Components[i].ClassType = TJvDBTreeView) then
          begin
            TJvDBTreeView(Components[i]).Enabled := True;
            TJvDBTreeView(Components[i]).DotNetHighlighting := true;
          end
          else if (Components[i].ClassType = TDBRadioGroup) then
          begin
            Controle := TDBRadioGroup(Components[i]).Name;
            if (ListaObrigatorios.IndexOf(Controle) >= 0) then
               TDBRadioGroup(Components[i]).Font.Color := clBlue             // Cor obrigatória
            else
               TDBRadioGroup(Components[i]).Font.Color := clWindowText;   // Cor não obrigatória
          end
          else if (Components[i].ClassType = TJvDBComboBox) then
          begin
            Controle := TJvDBComboBox(Components[i]).Name;
            if (ListaObrigatorios.IndexOf(Controle) >= 0) then
               TJvDBComboBox(Components[i]).Font.Color := clBlue             // Cor obrigatória
            else
            TJvDBComboBox(Components[i]).Font.Color         := clWindowText;   // Cor não obrigatória
            TJvDBComboBox(Components[i]).DotNetHighlighting := true;
          end
          else if ((Components[i] is TJvDBMaskEdit) or
           (Components[i].ClassType = TJvDBComboEdit) or
           (Components[i].ClassType = TJvDBCalcEdit) or
           (Components[i].ClassType = TJvCalcEdit) or
           (Components[i].ClassType = TDBMemo) or
           (Components[i] is TJvMaskEdit)) and (Components[i].ClassType <> TDBMemo) then
          begin
             TJvDBMaskEdit(Components[i]).DisabledColor      := ColorDisabled;
             TJvDBMaskEdit(Components[i]).DisabledTextColor  := ColorDisabledText;
             TJvDBMaskEdit(Components[i]).DotNetHighlighting := true;
             TJvDBMaskEdit(Components[i]).CharCase           := ecUpperCase;
             TJvDBMaskEdit(Components[i]).Color              := clWindow;
             if TJvDBMaskEdit(Components[i]).TabStop then
               TJvDBMaskEdit(Components[i]).Enabled          := Value
             else TJvDBMaskEdit(Components[i]).Enabled       := False;
          end
          else if (Components[i].ClassType = TJvDBDateEdit) then
          begin
             TJvDBDateEdit(Components[i]).CheckOnExit        := True;
             TJvDBDateEdit(Components[i]).DefaultToday       := true;
             TJvDBDateEdit(Components[i]).DisabledColor      := ColorDisabled;
             TJvDBMaskEdit(Components[i]).DisabledTextColor  := ColorDisabledText;
             TJvDBDateEdit(Components[i]).DotNetHighlighting := true;
             if TJvDBDateEdit(Components[i]).TabStop then
               TJvDBDateEdit(Components[i]).Enabled          := Value
             else TJvDBDateEdit(Components[i]).Enabled       := False;
          end;
        end
        // Particularidades
        // else if (Components[i].ClassType = TSpeedButton) then //Alterado por Diogo Cardoso 19/03/2015
        else if (Components[i] is TSpeedButton) then
        begin
          TSpeedButton(Components[i]).Enabled := Value;
        end
        else if (Components[i] is TJvSpeedButton) then
        begin
          TJvSpeedButton(Components[i]).Enabled := Value;
        end
        else if (Components[i].ClassType = TJvMaskEdit) then
        begin
          TEdit(Components[i]).Font.Color := clWindowText;
          if TEdit(Components[i]).TabStop then
            TEdit(Components[i]).Enabled          := Value
          else TEdit(Components[i]).Enabled       := False;
          if (Components[i].ClassType = TJvMaskEdit) or
                (Components[i].ClassType = TJvComboBox) then
            TJvMaskEdit(Components[i]).DotNetHighlighting := True;

          if TJvMaskEdit(Components[i]).name = 'edtCodigo' then
            TJvMaskEdit(Components[i]).Enabled := True;

        end
        else if (Components[i].ClassType = TEdit) or
                (Components[i].ClassType = TJvMaskEdit) or
                (Components[i].ClassType = TJvComboBox) then
        begin
          TEdit(Components[i]).Font.Color := clWindowText;
          if TEdit(Components[i]).TabStop then
           TEdit(Components[i]).Enabled          := Value
          else TEdit(Components[i]).Enabled       := False;
          if (Components[i].ClassType = TJvMaskEdit) or
                (Components[i].ClassType = TJvComboBox) then
            TJvMaskEdit(Components[i]).DotNetHighlighting := True;
        end
        else if ((Components[i].ClassType = TEdit) or
                (Components[i].ClassType = TJvMaskEdit) or
                (Components[i].ClassType = TJvComboBox)) and
                (Components[i].Name <> 'edtCodigo') then
        begin
          TEdit(Components[i]).Font.Color := clWindowText;
          if TEdit(Components[i]).TabStop then
              TEdit(Components[i]).Enabled   := Value
          else TEdit(Components[i]).Enabled  := False;
          if (Components[i].ClassType = TJvMaskEdit) or
                (Components[i].ClassType = TJvComboBox) then
              TJvMaskEdit(Components[i]).DotNetHighlighting := True;
        end
        else if (Components[i].ClassType = TButton)
          or (Components[i].ClassType = TJvExBitBtn)
          or (Components[i].ClassType = TJvBitBtn)
          or (Components[i].ClassType = TBitBtn) then
        begin
          //renomear botão imprimir pra visualizar
          if dmMaxxLocal.cdsParametrosBTIMPR_RENOMEAR.AsString = 'S' then
          begin
            if TButton(Components[i]).Caption = '&Imprimir' then
              TButton(Components[i]).Caption := '&Visualizar';
          end;
        end
        else if (Components[i].ClassType = TMenuItem) then
        begin
         //renomear botão imprimir pra visualizar
         if dmMaxxLocal.cdsParametrosBTIMPR_RENOMEAR.AsString = 'S' then
         begin
            if TMenuItem(Components[i]).Caption = '&Imprimir' then
                  TMenuItem(Components[i]).Caption := '&Visualizar impressão';
         end;
        end
        else if (Components[i].ClassType = TAggregateField) then
        begin
          TAggregateField(Components[i]).Active := True;
          if (TAggregateField(Components[i]).FieldName = 'PECENTUAL_TOTAL') or
              (TAggregateField(Components[i]).FieldName = 'PERCENTUAL_TOTAL')  then
              TAggregateField(Components[i]).DisplayFormat := ',0.0000';
        end
        else if (IsPublishedProp(Components[i], 'Tag')) then
        begin
          if (TComponent(Components[i]).Tag = 1) then
          begin
            if ListaComponentesPermitidos <> nil then
            begin
              if (ListaComponentesPermitidos.IndexOf(TComponent(Components[i]).Name) < 0) then
              begin
                TEdit(Components[i]).Enabled := False;
              end;
            end;
          end;
        end
        else if (Components[i].ClassType = TFMTBCDField) and (TFMTBCDField(Components[i]).FieldName = 'PFRECEBEPAGA_PERC') then
        begin
          TFMTBCDField(Components[i]).DisplayFormat := ',0.0000';
        end
        else if (IsPublishedProp(Components[i], 'FocusColor')) then
         SetPropValue(Components[I], 'FocusColor', LAYOUT_COREDITSELECIONADO);
      end;

      try
        Contexto := TRttiContext.Create;
        Tipo     := Contexto.GetType(Components[i].ClassType);

        if Tipo.GetProperty('Font') <> nil then
        begin
          TFont(Tipo.GetProperty('Font').GetValue(Components[i]).AsObject).Color := LAYOUT_CORLABELPADRAO;
          TFont(Tipo.GetProperty('Font').GetValue(Components[i]).AsObject).Name  := LAYOUT_FONTE;
          TFont(Tipo.GetProperty('Font').GetValue(Components[i]).AsObject).Size  := LAYOUT_FONTESIZE;
        end;

        if Tipo.GetProperty('ParentFont') <> nil then
           Tipo.GetProperty('ParentFont').SetValue(Components[i], False);
        if Tipo.GetProperty('ParentBackground') <> nil then
           Tipo.GetProperty('ParentBackground').SetValue(Components[i], False);
        if Tipo.GetProperty('ParentColor') <> nil      then
           Tipo.GetProperty('ParentColor').SetValue(Components[i], False);
        if Tipo.GetProperty('BeepOnInvalidKey') <> nil then
           Tipo.GetProperty('BeepOnInvalidKey').SetValue(Components[i], False);

        //Atribuindo cores nos labels
        if (Components[i] is TLabel) then
        begin
          TLabel(Components[i]).Font.Color := LAYOUT_CORFONTBOTAO;

          if TLabel(Components[i]).FocusControl <> nil then
          begin
            if ListaObrigatorios <> nil then
            begin
              if ListaObrigatorios.IndexOf(TLabel(Components[i]).FocusControl.Name) > -1 then
              begin
                TLabel(Components[i]).Font.Color := LAYOUT_CORLABELOBRIGATORIO;
                TLabel(Components[i]).Font.Style := [fsBold];
              end
              else TLabel(Components[i]).Font.Color := LAYOUT_CORLABELPADRAO;
            end;
          end;
        end;

        //cxgrids
        if Components[i] is TcxGrid then
        begin
          TcxGrid(Components[i]).LookAndFeel.kind              := lfOffice11;
          TcxGrid(Components[i]).LookAndFeel.NativeStyle       := True;
          TcxGrid(Components[i]).AlignWithMargins              := True;
          TcxGrid(Components[i]).LookAndFeel.TouchScrollUIMode := tsmDisabled;
        end;

        if Components[i] is TcxGridDBColumn then
           TcxGridDBColumn(Components[i]).HeaderAlignmentHorz := taCenter;

        if Components[i] is TCxGridDBTableView then
        begin
          TCxGridDBTableView(Components[I]).OptionsView.GridLines := glNone;
          TCxGridDBTableView(Components[I]).Styles.Content     := dmMaxxLocal.cxStyle1;
          TCxGridDBTableView(Components[I]).Styles.ContentEven := dmMaxxLocal.cxStyle2;
          TCxGridDBTableView(Components[I]).Styles.Inactive    := dmMaxxLocal.cxStyle3;
          TCxGridDBTableView(Components[I]).Styles.Footer      := dmMaxxLocal.cxStyle4;
        end;

        //Configurando Tabs
        if (Tipo is TRttiInstanceType) and (TRttiInstanceType(Tipo).MetaclassType.InheritsFrom(TCustomControl)) then
          PadronizarTabs(Components[i]);

        //Configurando botões
        if (Tipo is TRttiInstanceType) and ((TRttiInstanceType(Tipo).MetaclassType.InheritsFrom(TRzButton)) or
                                            (TRttiInstanceType(Tipo).MetaclassType.InheritsFrom(TRZRapidFireButton))) then
          PadronizarBotao(Components[I]);

        //Configurando edits
        if (Tipo is TRttiInstanceType) and (//(TRttiInstanceType(Tipo).MetaclassType.InheritsFrom(TRzCustomEdit)) or
                                            //(TRttiInstanceType(Tipo).MetaclassType.InheritsFrom(TRzCustomComboBox)) or
                                            (TRttiInstanceType(Tipo).MetaclassType.InheritsFrom(TCustomEdit)) or
                                            (TRttiInstanceType(Tipo).MetaclassType.InheritsFrom(TCustomCombo))) then
//                                              (Components[i] is TRzDBMemo) or (Components[i] is TRzMemo)) then
          PadronizarEdit(Components[I]);

      finally
        Contexto.Free;
      end;

    except
       on e : exception do MessageDebug(e.Message + '  ' + self.Name) ;
    end;
  end;
  Application.ProcessMessages;
end;

procedure TfrmMaster.FieldEventSetText(Sender: TField; const Text: string);
var
  SemAcento: String;
begin
  try
    if dmMaxxLocal.cdsParametrosPARAM_ACENTUACAO.AsString = 'S' then
    begin
      if ((TField(Sender).ClassType = TStringField) or
          (TField(Sender).ClassType = TWideStringField)) then
      begin
        if (Text = 'DÉBITO') or
           (Text = 'CRÉDITO') or
           (Text = 'NÃO') then
           TField(Sender).Value := Text
        else
        begin
          SemAcento := RemoveAcentos(Text);
          TField(Sender).Value := SemAcento;
        end;
      end;
    end
    else TField(Sender).Value := Text;

  except
    on E : Exception do
     OutputDebug('FieldEventSetText: ' + E.Message);
  end;
  inherited;
end;

end.
