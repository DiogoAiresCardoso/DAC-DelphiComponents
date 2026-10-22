inherited frmMovimentoBancarioView: TfrmMovimentoBancarioView
  BorderIcons = [biSystemMenu, biMinimize]
  Caption = 'Movimento banc'#225'rio'
  ClientHeight = 764
  ClientWidth = 1196
  ExplicitWidth = 1212
  ExplicitHeight = 803
  PixelsPerInch = 96
  TextHeight = 13
  inherited pnlMaster: TPanel
    Top = 744
    Width = 1196
    Height = 0
    Visible = False
    ExplicitTop = 744
    ExplicitWidth = 1194
    ExplicitHeight = 0
  end
  inherited pnlPrincipalNOVO: TPanel
    Width = 1196
    Height = 744
    BevelOuter = bvNone
    Color = 16184820
    ExplicitWidth = 1194
    ExplicitHeight = 744
    object pnlAcoes: TRzPanel
      Left = 0
      Top = 694
      Width = 1196
      Height = 50
      Align = alBottom
      BorderOuter = fsFlat
      BorderSides = [sdBottom]
      ParentColor = True
      TabOrder = 0
      ExplicitWidth = 1194
      object btnImportarOFX: TDACButton
        Left = 729
        Top = 6
        Width = 138
        Height = 36
        Cursor = crHandPoint
        Caption = 'Importar OFX'
        IconKind = mikDownload
        IconSize = 20
        Kind = mbkGhost
        ShowIcon = True
        TabOrder = 0
      end
      object btnTransferir: TDACButton
        Left = 873
        Top = 5
        Width = 122
        Height = 36
        Cursor = crHandPoint
        Caption = 'Transferir'
        IconKind = mikRefresh
        IconSize = 20
        Kind = mbkGhost
        ShowIcon = True
        TabOrder = 1
      end
      object btnNovaMovimentacao: TDACButton
        Left = 1001
        Top = 5
        Width = 183
        Height = 36
        Cursor = crHandPoint
        Caption = 'Nova Movimenta'#231#227'o'
        IconKind = mikAdd
        IconSize = 20
        ShowIcon = True
        TabOrder = 2
      end
    end
    object flpFiltros: TFlowPanel
      Left = 0
      Top = 0
      Width = 1196
      Height = 145
      Align = alTop
      BevelOuter = bvNone
      Padding.Left = 6
      Padding.Top = 10
      TabOrder = 1
      ExplicitLeft = 1
      ExplicitTop = -6
      ExplicitWidth = 1274
      object edtCodigoConta: TDACButtonEdit
        AlignWithMargins = True
        Left = 9
        Top = 13
        Width = 160
        Height = 50
        Cursor = crIBeam
        Constraints.MinWidth = 160
        LabelText = 'Conta banc'#225'ria'
        MaxLength = 10
        TabOrder = 0
        Text = ''
        OnChange = edtCodigoContaChange
        OnExit = edtCodigoContaExit
        OnButtonClick = edtCodigoContaButtonClick
      end
      object edtDescricaoConta: TDACEdit
        AlignWithMargins = True
        Left = 175
        Top = 13
        Width = 234
        Height = 50
        Enabled = False
        LabelText = 'Descri'#231#227'o'
        ReadOnly = True
        TabOrder = 1
        Text = ''
      end
      object edtAgencia: TDACEdit
        AlignWithMargins = True
        Left = 415
        Top = 13
        Width = 106
        Height = 50
        Enabled = False
        LabelText = 'Ag'#234'ncia'
        ReadOnly = True
        TabOrder = 2
        Text = ''
      end
      object edtNumeroConta: TDACEdit
        AlignWithMargins = True
        Left = 527
        Top = 13
        Width = 154
        Height = 50
        Enabled = False
        LabelText = 'N'#250'mero da conta'
        ReadOnly = True
        TabOrder = 3
        Text = ''
      end
      object pnlPeriodo: TPanel
        Left = 684
        Top = 10
        Width = 507
        Height = 63
        BevelOuter = bvNone
        TabOrder = 4
        object dtpDataInicial: TDACDateTimePicker
          Left = 34
          Top = 3
          Width = 160
          Height = 50
          Cursor = crIBeam
          Constraints.MinWidth = 160
          EditKind = mekMasked
          EditMask = '!00/00/0000;1;_'
          OnChange = PeriodoChange
          LabelText = 'Data inicial'
          MaxLength = 10
          TabOrder = 0
          Text = '24/05/2025'
          DateTime = 45801.607638888890000000
        end
        object dtpDataFinal: TDACDateTimePicker
          Left = 200
          Top = 3
          Width = 160
          Height = 50
          Cursor = crIBeam
          Constraints.MinWidth = 160
          EditKind = mekMasked
          EditMask = '!00/00/0000;1;_'
          OnChange = PeriodoChange
          LabelText = 'Data final'
          MaxLength = 10
          TabOrder = 1
          Text = '24/05/2025'
          DateTime = 45801.607638888890000000
        end
        object btnAplicar: TDACButton
          Left = 375
          Top = 23
          Width = 125
          Height = 30
          Cursor = crHandPoint
          Caption = 'Aplicar'
          OnClick = btnAplicarClick
          Enabled = False
          Kind = mbkSecondary
          TabOrder = 2
        end
      end
      object edtBanco: TDACEdit
        AlignWithMargins = True
        Left = 9
        Top = 76
        Width = 160
        Height = 50
        Enabled = False
        LabelText = 'Banco'
        ReadOnly = True
        TabOrder = 5
        Text = ''
      end
      object edtDescricaoBanco: TDACEdit
        AlignWithMargins = True
        Left = 175
        Top = 76
        Width = 346
        Height = 50
        Enabled = False
        LabelText = 'Descri'#231#227'o do banco'
        ReadOnly = True
        TabOrder = 6
        Text = ''
      end
      object edtCodigoBanco: TDACEdit
        AlignWithMargins = True
        Left = 527
        Top = 76
        Width = 154
        Height = 50
        Enabled = False
        LabelText = 'C'#243'digo do banco'
        ReadOnly = True
        TabOrder = 7
        Text = ''
      end
      object edtTipoConta: TDACEdit
        AlignWithMargins = True
        Left = 687
        Top = 76
        Width = 194
        Height = 50
        Enabled = False
        LabelText = 'Tipo da conta'
        ReadOnly = True
        TabOrder = 8
        Text = ''
      end
    end
    object pnlSaldos: TPanel
      Left = 0
      Top = 145
      Width = 1196
      Height = 152
      Align = alTop
      BevelOuter = bvNone
      Padding.Left = 10
      Padding.Right = 10
      ParentColor = True
      TabOrder = 2
      ExplicitWidth = 1194
      object cntSaldosConta: TDACContainer
        Left = 10
        Top = 0
        Width = 1176
        Height = 152
        Align = alClient
        BackgroundColor = xFFF6F5F4
        Color = 16053750
        ParentColor = False
        TabOrder = 0
        Title = 'Saldos da conta'
        ExplicitWidth = 1174
        object crdSaldoInicial: TDACSummaryCard
          Left = 69
          Top = 46
          Width = 250
          Height = 90
          FooterText = 'No in'#237'cio do per'#237'odo'
          Status = mcsNeutral
          TabOrder = 0
          Title = 'Saldo inicial'
          Value = '—'
          AutoTextHeight = True
          TitleFont.Name = 'Inter'
          TitleFont.Height = -13
          TitleFont.Color = clDefault
          TitleFont.Style = []
          ValueFont.Name = 'Inter'
          ValueFont.Height = -19
          ValueFont.Color = clDefault
          ValueFont.Style = [fsBold]
          FooterFont.Name = 'Inter'
          FooterFont.Height = -12
          FooterFont.Color = clDefault
          FooterFont.Style = []
        end
        object crdEntradas: TDACSummaryCard
          Left = 328
          Top = 46
          Width = 250
          Height = 90
          FooterText = 'No per'#237'odo selecionado'
          IconKind = mikArrowUp
          Status = mcsNeutral
          TabOrder = 1
          Title = 'Entradas'
          Value = '—'
          AutoTextHeight = True
          TitleFont.Name = 'Inter'
          TitleFont.Height = -13
          TitleFont.Color = clDefault
          TitleFont.Style = []
          ValueFont.Name = 'Inter'
          ValueFont.Height = -19
          ValueFont.Color = clDefault
          ValueFont.Style = [fsBold]
          FooterFont.Name = 'Inter'
          FooterFont.Height = -12
          FooterFont.Color = clDefault
          FooterFont.Style = []
        end
        object crdSaidas: TDACSummaryCard
          Left = 588
          Top = 46
          Width = 250
          Height = 90
          FooterText = 'No per'#237'odo selecionado'
          IconKind = mikArrowDown
          Status = mcsNeutral
          TabOrder = 2
          Title = 'Sa'#237'das'
          Value = '—'
          AutoTextHeight = True
          TitleFont.Name = 'Inter'
          TitleFont.Height = -13
          TitleFont.Color = clDefault
          TitleFont.Style = []
          ValueFont.Name = 'Inter'
          ValueFont.Height = -19
          ValueFont.Color = clDefault
          ValueFont.Style = [fsBold]
          FooterFont.Name = 'Inter'
          FooterFont.Height = -12
          FooterFont.Color = clDefault
          FooterFont.Style = []
        end
        object crdSaldoSistema: TDACSummaryCard
          Left = 849
          Top = 46
          Width = 250
          Height = 90
          FooterText = 'Ao final do per'#237'odo'
          Status = mcsNeutral
          TabOrder = 3
          Title = 'Saldo no sistema'
          Value = '—'
          AutoTextHeight = True
          TitleFont.Name = 'Inter'
          TitleFont.Height = -13
          TitleFont.Color = clDefault
          TitleFont.Style = []
          ValueFont.Name = 'Inter'
          ValueFont.Height = -19
          ValueFont.Color = clDefault
          ValueFont.Style = [fsBold]
          FooterFont.Name = 'Inter'
          FooterFont.Height = -12
          FooterFont.Color = clDefault
          FooterFont.Style = []
        end
      end
    end
    object DACTabs1: TDACTabs
      AlignWithMargins = True
      Align = alClient
      Margins.Left = 10
      Margins.Right = 10
      Left = 10
      Top = 300
      Width = 1174
      Height = 391
      ActivePage = TabSheet1
      DoubleBuffered = True
      Font.Charset = DEFAULT_CHARSET
      Font.Color = 1843992
      Font.Height = -15
      Font.Name = 'Inter'
      Font.Style = []
      ParentDoubleBuffered = False
      ParentFont = False
      TabOrder = 3
      StyleElements = []
      ActiveIndex = 0
      ContentColor = claWhite
      ThemeMode = dtmLight
      object TabSheet1: TTabSheet
        Caption = 'Prontos'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 1843992
        Font.Height = -15
        Font.Name = 'Inter'
        Font.Style = []
        ParentFont = False
        ExplicitLeft = 9
        ExplicitTop = 52
        ExplicitWidth = 1172
        object grdMovimentosProntos: TDACDBGrid
          ActionKeyFields = 'COD_EMP;MOV_COD'
          ShowHint = True
          OnActionState = GridAcaoEstado
          OnActionExecute = GridAcaoExecutar
          AlignWithMargins = True
          Left = 3
          Top = 3
          Width = 1152
          Height = 317
          Align = alClient
          EmptyText = 'Nenhum registro encontrado.'
          TabOrder = 0
          DataSource = dtsMovimentosProntos
          Columns = <
            item
              FieldName = 'MOVIMENTOFECHADO'
              Alignment = taCenter
              ReadOnly = True
              Title.Alignment = taCenter
              Title.Caption = 'Status'
              Width = 90
              Visible = True
              LayoutKey = 'MOVIMENTOFECHADO'
            end
            item
              FieldName = 'MOV_CONS'
              Alignment = taCenter
              ReadOnly = True
              Title.Alignment = taCenter
              Title.Caption = 'Conc'
              Width = 90
              Visible = True
              LayoutKey = 'MOV_CONS'
            end
            item
              FieldName = 'MOV_COD'
              Alignment = taCenter
              ReadOnly = True
              Title.Alignment = taCenter
              Title.Caption = 'Movimento'
              Width = 72
              Visible = True
              LayoutKey = 'MOV_COD'
            end
            item
              FieldName = 'MOV_DATA'
              Alignment = taCenter
              ReadOnly = True
              Title.Alignment = taCenter
              Title.Caption = 'Data'
              Width = 68
              Visible = True
              LayoutKey = 'MOV_DATA'
            end
            item
              FieldName = 'HIST_DESC'
              Alignment = taLeftJustify
              ReadOnly = True
              Title.Alignment = taCenter
              Title.Caption = 'Hist'#243'rico'
              Width = 236
              Visible = True
              LayoutKey = 'HIST_DESC'
            end
            item
              FieldName = 'TPGTO_ABRE'
              Alignment = taLeftJustify
              ReadOnly = True
              Title.Alignment = taCenter
              Title.Caption = 'TPG'
              Width = 73
              Visible = True
              LayoutKey = 'TPGTO_ABRE'
            end
            item
              FieldName = 'MOV_VALOR'
              Alignment = taRightJustify
              ReadOnly = True
              Title.Alignment = taCenter
              Title.Caption = 'Valor'
              Width = 100
              Visible = True
              LayoutKey = 'MOV_VALOR'
            end
            item
              FieldName = 'MOV_TIPO'
              Alignment = taLeftJustify
              ReadOnly = True
              Title.Alignment = taCenter
              Title.Caption = 'Tipo'
              Width = 63
              Visible = True
              LayoutKey = 'MOV_TIPO'
            end
            item
              FieldName = 'MOV_DTCONS'
              Alignment = taCenter
              ReadOnly = True
              Title.Alignment = taCenter
              Title.Caption = 'Dt. Conc.'
              Width = 64
              Visible = True
              LayoutKey = 'MOV_DTCONS'
            end
            item
              FieldName = 'CHEQUE_NUM'
              Alignment = taCenter
              ReadOnly = True
              Title.Alignment = taCenter
              Title.Caption = 'Cheque'
              Width = 58
              Visible = True
              LayoutKey = 'CHEQUE_NUM'
            end
            item
              FieldName = 'MOV_HISTCOMPL'
              Alignment = taLeftJustify
              ReadOnly = True
              Title.Alignment = taCenter
              Title.Caption = 'Complemento'
              Width = 506
              Visible = True
              LayoutKey = 'MOV_HISTCOMPL'
            end
            item
              Alignment = taCenter
              ReadOnly = True
              Title.Alignment = taCenter
              Title.Caption = 'Op'#231#245'es'
              Width = 196
              Visible = True
              LayoutKey = 'OPCOES'
              Actions = <
                item
                  ActionId = 'detalhes'
                  Caption = 'Detalhes'
                  Hint = 'Detalhes do lan'#231'amento'
                  Width = 80
                end
                item
                  ActionId = 'editar'
                  IconKind = mikEdit
                  Hint = 'Editar lan'#231'amento'
                end
                item
                  ActionId = 'excluir'
                  IconKind = mikTrash
                  Hint = 'Excluir lan'#231'amento'
                  Appearance = daaDanger
                end>
              Sortable = False
              UserHideable = False
            end>
        end
      end
      object TabSheet2: TTabSheet
        Caption = 'A Conciliar'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 1843992
        Font.Height = -15
        Font.Name = 'Inter'
        Font.Style = []
        ImageIndex = 1
        ParentFont = False
        ExplicitWidth = 1172
        object grdMovimentosConciliar: TDACDBGrid
          ActionKeyFields = 'COD_EMP;MOV_COD'
          ShowHint = True
          OnActionState = GridAcaoEstado
          OnActionExecute = GridAcaoExecutar
          AlignWithMargins = True
          Left = 3
          Top = 3
          Width = 1152
          Height = 317
          Align = alClient
          EmptyText = 'Nenhum registro encontrado.'
          TabOrder = 0
          DataSource = dtsMovimentosConciliar
          Columns = <
            item
              FieldName = 'MOVIMENTOFECHADO'
              Alignment = taCenter
              ReadOnly = True
              Title.Alignment = taCenter
              Title.Caption = 'Status'
              Width = 90
              Visible = True
              LayoutKey = 'MOVIMENTOFECHADO'
            end
            item
              FieldName = 'MOV_CONS'
              Alignment = taCenter
              ReadOnly = True
              Title.Alignment = taCenter
              Title.Caption = 'Conc'
              Width = 90
              Visible = True
              LayoutKey = 'MOV_CONS'
            end
            item
              FieldName = 'MOV_COD'
              Alignment = taCenter
              ReadOnly = True
              Title.Alignment = taCenter
              Title.Caption = 'Movimento'
              Width = 72
              Visible = True
              LayoutKey = 'MOV_COD'
            end
            item
              FieldName = 'MOV_DATA'
              Alignment = taCenter
              ReadOnly = True
              Title.Alignment = taCenter
              Title.Caption = 'Data'
              Width = 68
              Visible = True
              LayoutKey = 'MOV_DATA'
            end
            item
              FieldName = 'HIST_DESC'
              Alignment = taLeftJustify
              ReadOnly = True
              Title.Alignment = taCenter
              Title.Caption = 'Hist'#243'rico'
              Width = 236
              Visible = True
              LayoutKey = 'HIST_DESC'
            end
            item
              FieldName = 'TPGTO_ABRE'
              Alignment = taLeftJustify
              ReadOnly = True
              Title.Alignment = taCenter
              Title.Caption = 'TPG'
              Width = 73
              Visible = True
              LayoutKey = 'TPGTO_ABRE'
            end
            item
              FieldName = 'MOV_VALOR'
              Alignment = taRightJustify
              ReadOnly = True
              Title.Alignment = taCenter
              Title.Caption = 'Valor'
              Width = 100
              Visible = True
              LayoutKey = 'MOV_VALOR'
            end
            item
              FieldName = 'MOV_TIPO'
              Alignment = taLeftJustify
              ReadOnly = True
              Title.Alignment = taCenter
              Title.Caption = 'Tipo'
              Width = 63
              Visible = True
              LayoutKey = 'MOV_TIPO'
            end
            item
              FieldName = 'MOV_DTCONS'
              Alignment = taCenter
              ReadOnly = True
              Title.Alignment = taCenter
              Title.Caption = 'Dt. Conc.'
              Width = 64
              Visible = True
              LayoutKey = 'MOV_DTCONS'
            end
            item
              FieldName = 'CHEQUE_NUM'
              Alignment = taCenter
              ReadOnly = True
              Title.Alignment = taCenter
              Title.Caption = 'Cheque'
              Width = 58
              Visible = True
              LayoutKey = 'CHEQUE_NUM'
            end
            item
              FieldName = 'MOV_HISTCOMPL'
              Alignment = taLeftJustify
              ReadOnly = True
              Title.Alignment = taCenter
              Title.Caption = 'Complemento'
              Width = 506
              Visible = True
              LayoutKey = 'MOV_HISTCOMPL'
            end
            item
              Alignment = taCenter
              ReadOnly = True
              Title.Alignment = taCenter
              Title.Caption = 'Op'#231#245'es'
              Width = 196
              Visible = True
              LayoutKey = 'OPCOES'
              Actions = <
                item
                  ActionId = 'detalhes'
                  Caption = 'Detalhes'
                  Hint = 'Detalhes do lan'#231'amento'
                  Width = 80
                end
                item
                  ActionId = 'editar'
                  IconKind = mikEdit
                  Hint = 'Editar lan'#231'amento'
                end
                item
                  ActionId = 'excluir'
                  IconKind = mikTrash
                  Hint = 'Excluir lan'#231'amento'
                  Appearance = daaDanger
                end>
              Sortable = False
              UserHideable = False
            end>
        end
      end
      object TabSheet3: TTabSheet
        Caption = 'Importados'
        Font.Charset = DEFAULT_CHARSET
        Font.Color = 1843992
        Font.Height = -15
        Font.Name = 'Inter'
        Font.Style = []
        ImageIndex = 2
        ParentFont = False
        ExplicitWidth = 1172
        object grdMovimentosImportados: TDACDBGrid
          ActionKeyFields = 'COD_EMP;MOV_COD'
          ShowHint = True
          OnActionState = GridAcaoEstado
          OnActionExecute = GridAcaoExecutar
          AlignWithMargins = True
          Left = 3
          Top = 3
          Width = 1152
          Height = 317
          Align = alClient
          EmptyText = 'Nenhum registro encontrado.'
          TabOrder = 0
          DataSource = dtsMovimentosImportados
          Columns = <
            item
              FieldName = 'MOVIMENTOFECHADO'
              Alignment = taCenter
              ReadOnly = True
              Title.Alignment = taCenter
              Title.Caption = 'Status'
              Width = 90
              Visible = True
              LayoutKey = 'MOVIMENTOFECHADO'
            end
            item
              FieldName = 'MOV_CONS'
              Alignment = taCenter
              ReadOnly = True
              Title.Alignment = taCenter
              Title.Caption = 'Conc'
              Width = 90
              Visible = True
              LayoutKey = 'MOV_CONS'
            end
            item
              FieldName = 'MOV_COD'
              Alignment = taCenter
              ReadOnly = True
              Title.Alignment = taCenter
              Title.Caption = 'Movimento'
              Width = 72
              Visible = True
              LayoutKey = 'MOV_COD'
            end
            item
              FieldName = 'MOV_DATA'
              Alignment = taCenter
              ReadOnly = True
              Title.Alignment = taCenter
              Title.Caption = 'Data'
              Width = 68
              Visible = True
              LayoutKey = 'MOV_DATA'
            end
            item
              FieldName = 'HIST_DESC'
              Alignment = taLeftJustify
              ReadOnly = True
              Title.Alignment = taCenter
              Title.Caption = 'Hist'#243'rico'
              Width = 236
              Visible = True
              LayoutKey = 'HIST_DESC'
            end
            item
              FieldName = 'TPGTO_ABRE'
              Alignment = taLeftJustify
              ReadOnly = True
              Title.Alignment = taCenter
              Title.Caption = 'TPG'
              Width = 73
              Visible = True
              LayoutKey = 'TPGTO_ABRE'
            end
            item
              FieldName = 'MOV_VALOR'
              Alignment = taRightJustify
              ReadOnly = True
              Title.Alignment = taCenter
              Title.Caption = 'Valor'
              Width = 100
              Visible = True
              LayoutKey = 'MOV_VALOR'
            end
            item
              FieldName = 'MOV_TIPO'
              Alignment = taLeftJustify
              ReadOnly = True
              Title.Alignment = taCenter
              Title.Caption = 'Tipo'
              Width = 63
              Visible = True
              LayoutKey = 'MOV_TIPO'
            end
            item
              FieldName = 'MOV_DTCONS'
              Alignment = taCenter
              ReadOnly = True
              Title.Alignment = taCenter
              Title.Caption = 'Dt. Conc.'
              Width = 64
              Visible = True
              LayoutKey = 'MOV_DTCONS'
            end
            item
              FieldName = 'CHEQUE_NUM'
              Alignment = taCenter
              ReadOnly = True
              Title.Alignment = taCenter
              Title.Caption = 'Cheque'
              Width = 58
              Visible = True
              LayoutKey = 'CHEQUE_NUM'
            end
            item
              FieldName = 'MOV_HISTCOMPL'
              Alignment = taLeftJustify
              ReadOnly = True
              Title.Alignment = taCenter
              Title.Caption = 'Complemento'
              Width = 506
              Visible = True
              LayoutKey = 'MOV_HISTCOMPL'
            end
            item
              Alignment = taCenter
              ReadOnly = True
              Title.Alignment = taCenter
              Title.Caption = 'Op'#231#245'es'
              Width = 196
              Visible = True
              LayoutKey = 'OPCOES'
              Actions = <
                item
                  ActionId = 'detalhes'
                  Caption = 'Detalhes'
                  Hint = 'Detalhes do lan'#231'amento'
                  Width = 80
                end
                item
                  ActionId = 'editar'
                  IconKind = mikEdit
                  Hint = 'Editar lan'#231'amento'
                end
                item
                  ActionId = 'excluir'
                  IconKind = mikTrash
                  Hint = 'Excluir lan'#231'amento'
                  Appearance = daaDanger
                end>
              Sortable = False
              UserHideable = False
            end>
        end
      end
    end
  end
  inherited stbMaster: TdxStatusBar
    Top = 744
    Width = 1196
    ExplicitTop = 744
    ExplicitWidth = 1194
  end
  object cdsMovimentosProntos: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 40
    Top = 656
    object cdsMovimentosProntosMOV_COD: TStringField
      FieldName = 'MOV_COD'
      Required = True
      Size = 10
      ProviderFlags = []
    end
    object cdsMovimentosProntosCOD_EMP: TStringField
      FieldName = 'COD_EMP'
      Required = True
      Size = 10
      ProviderFlags = []
    end
    object cdsMovimentosProntosMOV_CONTA: TStringField
      FieldName = 'MOV_CONTA'
      Size = 10
      ProviderFlags = []
    end
    object cdsMovimentosProntosMOV_DATA: TDateField
      Alignment = taCenter
      FieldName = 'MOV_DATA'
      DisplayFormat = 'dd/mm/yyyy'
      ProviderFlags = []
    end
    object cdsMovimentosProntosMOV_VALOR: TFMTBCDField
      FieldName = 'MOV_VALOR'
      DisplayFormat = ',0.00'
      Precision = 18
      Size = 5
      ProviderFlags = []
    end
    object cdsMovimentosProntosMOV_TIPO: TStringField
      FieldName = 'MOV_TIPO'
      Size = 10
      ProviderFlags = []
    end
    object cdsMovimentosProntosMOV_CONS: TStringField
      FieldName = 'MOV_CONS'
      Size = 5
      ProviderFlags = []
    end
    object cdsMovimentosProntosMOV_DTCONS: TDateField
      Alignment = taCenter
      FieldName = 'MOV_DTCONS'
      DisplayFormat = 'dd/mm/yyyy'
      ProviderFlags = []
    end
    object cdsMovimentosProntosMOV_HIST: TStringField
      FieldName = 'MOV_HIST'
      Size = 10
      ProviderFlags = []
    end
    object cdsMovimentosProntosHIST_DESC: TStringField
      FieldName = 'HIST_DESC'
      Size = 60
      ProviderFlags = []
    end
    object cdsMovimentosProntosMOV_TIPG: TStringField
      FieldName = 'MOV_TIPG'
      Size = 10
      ProviderFlags = []
    end
    object cdsMovimentosProntosTPGTO_DESC: TStringField
      FieldName = 'TPGTO_DESC'
      Size = 60
      ProviderFlags = []
    end
    object cdsMovimentosProntosMOV_SIT: TStringField
      FieldName = 'MOV_SIT'
      FixedChar = True
      Size = 1
      ProviderFlags = []
    end
    object cdsMovimentosProntosMOV_RELRP: TStringField
      FieldName = 'MOV_RELRP'
      Size = 10
      ProviderFlags = []
    end
    object cdsMovimentosProntosMOV_RELTIPO: TStringField
      FieldName = 'MOV_RELTIPO'
      Size = 16
      ProviderFlags = []
    end
    object cdsMovimentosProntosMOV_HISTCOMPL: TMemoField
      FieldName = 'MOV_HISTCOMPL'
      BlobType = ftMemo
      ProviderFlags = []
    end
    object cdsMovimentosProntosDUMANUT: TSQLTimeStampField
      FieldName = 'DUMANUT'
      ProviderFlags = []
    end
    object cdsMovimentosProntosCOD_USU: TStringField
      FieldName = 'COD_USU'
      Size = 10
      ProviderFlags = []
    end
    object cdsMovimentosProntosMOV_CICLO: TStringField
      FieldName = 'MOV_CICLO'
      Size = 10
      ProviderFlags = []
    end
    object cdsMovimentosProntosMOV_BAIXADOC: TStringField
      FieldName = 'MOV_BAIXADOC'
      FixedChar = True
      Size = 1
      ProviderFlags = []
    end
    object cdsMovimentosProntosMOV_TRANSF: TStringField
      FieldName = 'MOV_TRANSF'
      FixedChar = True
      Size = 1
      ProviderFlags = []
    end
    object cdsMovimentosProntosMOV_TRANSFCOD: TStringField
      FieldName = 'MOV_TRANSFCOD'
      Size = 10
      ProviderFlags = []
    end
    object cdsMovimentosProntosTPGTO_ABRE: TStringField
      FieldName = 'TPGTO_ABRE'
      Size = 16
      ProviderFlags = []
    end
    object cdsMovimentosProntosCHEQUE_NUM: TStringField
      FieldName = 'CHEQUE_NUM'
      Size = 10
      ProviderFlags = []
    end
    object cdsMovimentosProntosMOVIMENTOFECHADO: TStringField
      FieldName = 'MOVIMENTOFECHADO'
      FixedChar = True
      Size = 7
      ProviderFlags = []
    end
  end
  object dtsMovimentosProntos: TDataSource
    AutoEdit = False
    DataSet = cdsMovimentosProntos
    Left = 152
    Top = 656
  end
  object cdsMovimentosConciliar: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 300
    Top = 656
    object cdsMovimentosConciliarMOV_COD: TStringField
      FieldName = 'MOV_COD'
      Required = True
      Size = 10
      ProviderFlags = []
    end
    object cdsMovimentosConciliarCOD_EMP: TStringField
      FieldName = 'COD_EMP'
      Required = True
      Size = 10
      ProviderFlags = []
    end
    object cdsMovimentosConciliarMOV_CONTA: TStringField
      FieldName = 'MOV_CONTA'
      Size = 10
      ProviderFlags = []
    end
    object cdsMovimentosConciliarMOV_DATA: TDateField
      Alignment = taCenter
      FieldName = 'MOV_DATA'
      DisplayFormat = 'dd/mm/yyyy'
      ProviderFlags = []
    end
    object cdsMovimentosConciliarMOV_VALOR: TFMTBCDField
      FieldName = 'MOV_VALOR'
      DisplayFormat = ',0.00'
      Precision = 18
      Size = 5
      ProviderFlags = []
    end
    object cdsMovimentosConciliarMOV_TIPO: TStringField
      FieldName = 'MOV_TIPO'
      Size = 10
      ProviderFlags = []
    end
    object cdsMovimentosConciliarMOV_CONS: TStringField
      FieldName = 'MOV_CONS'
      Size = 5
      ProviderFlags = []
    end
    object cdsMovimentosConciliarMOV_DTCONS: TDateField
      Alignment = taCenter
      FieldName = 'MOV_DTCONS'
      DisplayFormat = 'dd/mm/yyyy'
      ProviderFlags = []
    end
    object cdsMovimentosConciliarMOV_HIST: TStringField
      FieldName = 'MOV_HIST'
      Size = 10
      ProviderFlags = []
    end
    object cdsMovimentosConciliarHIST_DESC: TStringField
      FieldName = 'HIST_DESC'
      Size = 60
      ProviderFlags = []
    end
    object cdsMovimentosConciliarMOV_TIPG: TStringField
      FieldName = 'MOV_TIPG'
      Size = 10
      ProviderFlags = []
    end
    object cdsMovimentosConciliarTPGTO_DESC: TStringField
      FieldName = 'TPGTO_DESC'
      Size = 60
      ProviderFlags = []
    end
    object cdsMovimentosConciliarMOV_SIT: TStringField
      FieldName = 'MOV_SIT'
      FixedChar = True
      Size = 1
      ProviderFlags = []
    end
    object cdsMovimentosConciliarMOV_RELRP: TStringField
      FieldName = 'MOV_RELRP'
      Size = 10
      ProviderFlags = []
    end
    object cdsMovimentosConciliarMOV_RELTIPO: TStringField
      FieldName = 'MOV_RELTIPO'
      Size = 16
      ProviderFlags = []
    end
    object cdsMovimentosConciliarMOV_HISTCOMPL: TMemoField
      FieldName = 'MOV_HISTCOMPL'
      BlobType = ftMemo
      ProviderFlags = []
    end
    object cdsMovimentosConciliarDUMANUT: TSQLTimeStampField
      FieldName = 'DUMANUT'
      ProviderFlags = []
    end
    object cdsMovimentosConciliarCOD_USU: TStringField
      FieldName = 'COD_USU'
      Size = 10
      ProviderFlags = []
    end
    object cdsMovimentosConciliarMOV_CICLO: TStringField
      FieldName = 'MOV_CICLO'
      Size = 10
      ProviderFlags = []
    end
    object cdsMovimentosConciliarMOV_BAIXADOC: TStringField
      FieldName = 'MOV_BAIXADOC'
      FixedChar = True
      Size = 1
      ProviderFlags = []
    end
    object cdsMovimentosConciliarMOV_TRANSF: TStringField
      FieldName = 'MOV_TRANSF'
      FixedChar = True
      Size = 1
      ProviderFlags = []
    end
    object cdsMovimentosConciliarMOV_TRANSFCOD: TStringField
      FieldName = 'MOV_TRANSFCOD'
      Size = 10
      ProviderFlags = []
    end
    object cdsMovimentosConciliarTPGTO_ABRE: TStringField
      FieldName = 'TPGTO_ABRE'
      Size = 16
      ProviderFlags = []
    end
    object cdsMovimentosConciliarCHEQUE_NUM: TStringField
      FieldName = 'CHEQUE_NUM'
      Size = 10
      ProviderFlags = []
    end
    object cdsMovimentosConciliarMOVIMENTOFECHADO: TStringField
      FieldName = 'MOVIMENTOFECHADO'
      FixedChar = True
      Size = 7
      ProviderFlags = []
    end
  end
  object dtsMovimentosConciliar: TDataSource
    AutoEdit = False
    DataSet = cdsMovimentosConciliar
    Left = 412
    Top = 656
  end
  object cdsMovimentosImportados: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 560
    Top = 656
    object cdsMovimentosImportadosMOV_COD: TStringField
      FieldName = 'MOV_COD'
      Required = True
      Size = 10
      ProviderFlags = []
    end
    object cdsMovimentosImportadosCOD_EMP: TStringField
      FieldName = 'COD_EMP'
      Required = True
      Size = 10
      ProviderFlags = []
    end
    object cdsMovimentosImportadosMOV_CONTA: TStringField
      FieldName = 'MOV_CONTA'
      Size = 10
      ProviderFlags = []
    end
    object cdsMovimentosImportadosMOV_DATA: TDateField
      Alignment = taCenter
      FieldName = 'MOV_DATA'
      DisplayFormat = 'dd/mm/yyyy'
      ProviderFlags = []
    end
    object cdsMovimentosImportadosMOV_VALOR: TFMTBCDField
      FieldName = 'MOV_VALOR'
      DisplayFormat = ',0.00'
      Precision = 18
      Size = 5
      ProviderFlags = []
    end
    object cdsMovimentosImportadosMOV_TIPO: TStringField
      FieldName = 'MOV_TIPO'
      Size = 10
      ProviderFlags = []
    end
    object cdsMovimentosImportadosMOV_CONS: TStringField
      FieldName = 'MOV_CONS'
      Size = 5
      ProviderFlags = []
    end
    object cdsMovimentosImportadosMOV_DTCONS: TDateField
      Alignment = taCenter
      FieldName = 'MOV_DTCONS'
      DisplayFormat = 'dd/mm/yyyy'
      ProviderFlags = []
    end
    object cdsMovimentosImportadosMOV_HIST: TStringField
      FieldName = 'MOV_HIST'
      Size = 10
      ProviderFlags = []
    end
    object cdsMovimentosImportadosHIST_DESC: TStringField
      FieldName = 'HIST_DESC'
      Size = 60
      ProviderFlags = []
    end
    object cdsMovimentosImportadosMOV_TIPG: TStringField
      FieldName = 'MOV_TIPG'
      Size = 10
      ProviderFlags = []
    end
    object cdsMovimentosImportadosTPGTO_DESC: TStringField
      FieldName = 'TPGTO_DESC'
      Size = 60
      ProviderFlags = []
    end
    object cdsMovimentosImportadosMOV_SIT: TStringField
      FieldName = 'MOV_SIT'
      FixedChar = True
      Size = 1
      ProviderFlags = []
    end
    object cdsMovimentosImportadosMOV_RELRP: TStringField
      FieldName = 'MOV_RELRP'
      Size = 10
      ProviderFlags = []
    end
    object cdsMovimentosImportadosMOV_RELTIPO: TStringField
      FieldName = 'MOV_RELTIPO'
      Size = 16
      ProviderFlags = []
    end
    object cdsMovimentosImportadosMOV_HISTCOMPL: TMemoField
      FieldName = 'MOV_HISTCOMPL'
      BlobType = ftMemo
      ProviderFlags = []
    end
    object cdsMovimentosImportadosDUMANUT: TSQLTimeStampField
      FieldName = 'DUMANUT'
      ProviderFlags = []
    end
    object cdsMovimentosImportadosCOD_USU: TStringField
      FieldName = 'COD_USU'
      Size = 10
      ProviderFlags = []
    end
    object cdsMovimentosImportadosMOV_CICLO: TStringField
      FieldName = 'MOV_CICLO'
      Size = 10
      ProviderFlags = []
    end
    object cdsMovimentosImportadosMOV_BAIXADOC: TStringField
      FieldName = 'MOV_BAIXADOC'
      FixedChar = True
      Size = 1
      ProviderFlags = []
    end
    object cdsMovimentosImportadosMOV_TRANSF: TStringField
      FieldName = 'MOV_TRANSF'
      FixedChar = True
      Size = 1
      ProviderFlags = []
    end
    object cdsMovimentosImportadosMOV_TRANSFCOD: TStringField
      FieldName = 'MOV_TRANSFCOD'
      Size = 10
      ProviderFlags = []
    end
    object cdsMovimentosImportadosTPGTO_ABRE: TStringField
      FieldName = 'TPGTO_ABRE'
      Size = 16
      ProviderFlags = []
    end
    object cdsMovimentosImportadosCHEQUE_NUM: TStringField
      FieldName = 'CHEQUE_NUM'
      Size = 10
      ProviderFlags = []
    end
    object cdsMovimentosImportadosMOVIMENTOFECHADO: TStringField
      FieldName = 'MOVIMENTOFECHADO'
      FixedChar = True
      Size = 7
      ProviderFlags = []
    end
  end
  object dtsMovimentosImportados: TDataSource
    AutoEdit = False
    DataSet = cdsMovimentosImportados
    Left = 672
    Top = 656
  end
end
