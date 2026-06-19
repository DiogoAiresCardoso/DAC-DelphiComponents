object Form1: TForm1
  Left = 0
  Top = 0
  BorderStyle = bsNone
  Caption = 'Demo - Suite de Componentes'
  ClientHeight = 474
  ClientWidth = 1000
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  OnCreate = FormCreate
  StyleElements = [seFont, seBorder]
  PixelsPerInch = 96
  TextHeight = 13
  object SystemBar: TDACContainer
    Left = 0
    Top = 0
    Width = 1000
    Height = 56
    Align = alTop
    Appearance = mcaDarkPanel
    BackgroundColor = xFF07130C
    BorderColor = xFF2B3D31
    BorderRadius = 0
    ContentPadding = 0
    CornerRadius = 0
    HeaderHeight = 0
    ShowHeader = False
    TabOrder = 0
    object SystemIcon: TDACButton
      Left = 18
      Top = 10
      Width = 36
      Height = 36
      Cursor = crHandPoint
      Caption = ''
      IconKind = mikLeaf
      IconSize = 22
      Kind = mbkPrimary
      ShowIcon = True
      TabOrder = 0
    end
    object SystemTitle: TLabel
      Left = 68
      Top = 17
      Width = 220
      Height = 19
      Caption = 'Demo - Suite de Componentes'
      Font.Charset = DEFAULT_CHARSET
      Font.Color = clWhite
      Font.Height = -16
      Font.Name = 'Inter'
      Font.Style = [fsBold]
      ParentFont = False
      Transparent = True
    end
    object WindowMinimizeButton: TDACButton
      Left = 856
      Top = 10
      Width = 40
      Height = 36
      Anchors = [akTop, akRight]
      Cursor = crHandPoint
      Caption = ''
      IconKind = mikMinus
      IconSize = 18
      Kind = mbkTransparent
      ShowIcon = True
      TabOrder = 1
      OnClick = WindowMinimizeButtonClick
    end
    object WindowMaximizeButton: TDACButton
      Left = 902
      Top = 10
      Width = 40
      Height = 36
      Anchors = [akTop, akRight]
      Cursor = crHandPoint
      Caption = ''
      IconKind = mikExpand
      IconSize = 18
      Kind = mbkTransparent
      ShowIcon = True
      TabOrder = 2
      OnClick = WindowMaximizeButtonClick
    end
    object WindowCloseButton: TDACButton
      Left = 948
      Top = 10
      Width = 40
      Height = 36
      Anchors = [akTop, akRight]
      Cursor = crHandPoint
      Caption = ''
      IconKind = mikClose
      IconSize = 18
      Kind = mbkDanger
      ShowIcon = True
      TabOrder = 3
      OnClick = WindowCloseButtonClick
    end
  end
  object MainTabs: TDACTabs
    Left = 0
    Top = 56
    Width = 1000
    Height = 418
    Cursor = crHandPoint
    ActiveIndex = 0
    Align = alClient
    ContentColor = claWhite
    CornerRadius = 10
    Items = <
      item
        Caption = 'Botoes'
      end
      item
        Caption = 'Inputs'
      end
      item
        Caption = 'Controles'
      end
      item
        Caption = 'Containers'
      end
      item
        Caption = 'Tabs'
      end
      item
        Caption = 'Cards'
      end
      item
        Caption = 'Grid'
      end
      item
        Caption = 'Status'
      end
      item
        Caption = 'Badges'
      end
      item
        Caption = 'Progress'
      end
      item
        Caption = 'Paginacao'
      end
      item
        Caption = 'Loading'
      end
      item
        Caption = 'Feedback'
      end
      item
        Caption = 'Charts'
      end
      item
        Caption = 'Report'
      end>
    ShowContentBorder = False
    TabHeight = 46
    TabOrder = 1
    TabWidth = 96
    OnChange = MainTabsChange
    object PageButtons: TDACScrollContainer
      Left = 12
      Top = 58
      Width = 976
      Height = 404
      Align = alClient
      BorderStyle = bsNone
      BackgroundColor = claWhite
      BorderColor = claNull
      CornerRadius = 0
      Color = clWhite
      ParentColor = False
      TabOrder = 0
      StyleElements = [seFont, seBorder]
      object SectionButtons: TDACContainer
        Left = 16
        Top = 16
        Width = 850
        Height = 238
        BackgroundColor = claWhite
        BorderColor = xFFD5DBE6
        ContentPadding = 18
        SectionNumber = 1
        Subtitle = 'Variacoes de botoes da suite organizadas na tab Botoes'
        SubtitleColor = xFF475569
        TabOrder = 0
        Title = 'BOTOES'
        TitleColor = xFF111827
        object ButtonPrimary: TDACButton
          Left = 36
          Top = 88
          Width = 136
          Height = 36
          Cursor = crHandPoint
          Caption = 'Primario'
          IconSize = 18
          ShowIcon = True
          TabOrder = 0
        end
        object ButtonSecondary: TDACButton
          Left = 188
          Top = 88
          Width = 136
          Height = 36
          Cursor = crHandPoint
          Caption = 'Secundario'
          Kind = mbkSecondary
          TabOrder = 1
        end
        object ButtonWarning: TDACButton
          Left = 340
          Top = 88
          Width = 124
          Height = 36
          Cursor = crHandPoint
          Caption = 'Alerta'
          IconKind = mikWarning
          IconSize = 18
          Kind = mbkWarning
          ShowIcon = True
          TabOrder = 2
        end
        object ButtonDanger: TDACButton
          Left = 480
          Top = 88
          Width = 124
          Height = 36
          Cursor = crHandPoint
          Caption = 'Perigo'
          IconKind = mikDanger
          IconSize = 18
          Kind = mbkDanger
          ShowIcon = True
          TabOrder = 3
        end
        object ButtonGhost: TDACButton
          Left = 620
          Top = 88
          Width = 124
          Height = 36
          Cursor = crHandPoint
          Caption = 'Ghost'
          IconKind = mikFilter
          IconSize = 18
          Kind = mbkGhost
          ShowIcon = True
          TabOrder = 4
        end
        object ButtonTransparent: TDACButton
          Left = 760
          Top = 88
          Width = 42
          Height = 36
          Cursor = crHandPoint
          Caption = ''
          IconKind = mikMoreVertical
          IconSize = 18
          Kind = mbkTransparent
          ShowIcon = True
          TabOrder = 5
        end
        object ButtonIconAdd: TDACButton
          Left = 36
          Top = 152
          Width = 42
          Height = 42
          Cursor = crHandPoint
          Caption = 'Botao'
          IconKind = mikAdd
          IconSize = 20
          ShowIcon = True
          TabOrder = 5
        end
        object ButtonIconEdit: TDACButton
          Left = 96
          Top = 152
          Width = 42
          Height = 42
          Cursor = crHandPoint
          Caption = 'Botao'
          IconKind = mikEdit
          IconSize = 20
          Kind = mbkSecondary
          ShowIcon = True
          TabOrder = 6
        end
        object ButtonIconDelete: TDACButton
          Left = 156
          Top = 152
          Width = 42
          Height = 42
          Cursor = crHandPoint
          Caption = 'Botao'
          IconKind = mikTrash
          IconSize = 20
          Kind = mbkDanger
          ShowIcon = True
          TabOrder = 7
        end
      end
    end
    object PageInputs: TDACScrollContainer
      Left = 12
      Top = 58
      Width = 976
      Height = 404
      Align = alClient
      BorderStyle = bsNone
      BackgroundColor = claWhite
      BorderColor = claNull
      CornerRadius = 0
      Color = clWhite
      ParentColor = False
      TabOrder = 1
      Visible = False
      StyleElements = [seFont, seBorder]
      object SectionInputs: TDACContainer
        Left = 16
        Top = 16
        Width = 850
        Height = 720
        BackgroundColor = claWhite
        BorderColor = xFFD5DBE6
        ContentPadding = 18
        SectionNumber = 2
        Subtitle = 'Edits, memo e combobox agrupados na tab Inputs'
        SubtitleColor = xFF475569
        TabOrder = 0
        Title = 'INPUTS'
        TitleColor = xFF111827
        object InputText: TDACEdit
          Left = 36
          Top = 82
          Width = 240
          Height = 82
          Cursor = crIBeam
          HelperText = 'Texto padrao para formularios.'
          LabelText = 'Campo de texto'
          Placeholder = 'Digite um valor'
          TabOrder = 0
          Text = ''
        end
        object InputRequired: TDACEdit
          Left = 306
          Top = 82
          Width = 240
          Height = 82
          Cursor = crIBeam
          LabelText = 'Campo obrigatorio'
          Placeholder = 'Destaque sem asterisco'
          Required = True
          HelperText = 'Informacao valida.'
          Status = mesSuccess
          TabOrder = 1
          Text = ''
        end
        object InputMasked: TDACEdit
          Left = 576
          Top = 82
          Width = 220
          Height = 60
          Cursor = crIBeam
          EditKind = mekMasked
          EditMask = '(99) 99999-9999;0;_'
          LabelText = 'Masked Input'
          MaxLength = 15
          Placeholder = '(11) 99999-9999'
          TabOrder = 2
          Text = '46999999999'
        end
        object InputPassword: TDACEdit
          Left = 36
          Top = 184
          Width = 240
          Height = 60
          Cursor = crIBeam
          EditKind = mekPassword
          LabelText = 'Password'
          PasswordChar = '*'
          Placeholder = 'Senha'
          TabOrder = 3
          Text = '12345678'
        end
        object InputSearch: TDACEdit
          Left = 306
          Top = 184
          Width = 240
          Height = 60
          Cursor = crIBeam
          EditKind = mekSearch
          LabelText = 'Search'
          Placeholder = 'Pesquisar...'
          TabOrder = 4
          Text = ''
        end
        object InputCombo: TDACComboBox
          Left = 576
          Top = 184
          Width = 220
          Height = 82
          ItemIndex = 0
          Items.Strings = (
            'Selecione uma opcao'
            'Fazenda Boa Vista'
            'Talhao 12'
            'Soja')
          HelperText = 'Escolha a opcao que melhor atende ao contexto.'
          LabelText = 'ComboBox'
          Required = True
          Status = mesSuccess
          TabOrder = 6
          Text = 'Selecione uma opcao'
        end
        object InputMemo: TDACMemo
          Left = 36
          Top = 294
          Width = 510
          Height = 90
          Cursor = crIBeam
          LabelText = 'Memo / TextArea'
          Lines.Strings = (
            'Area para texto'
            'com multiplas linhas.'
            'Suporta digitacao de paragrafos completos.')
          TabOrder = 6
          Text =
            'Area para texto'#13#10'com multiplas linhas.'#13#10'Suporta digitacao de par' +
            'agrafos completos.'#13#10
        end
        object InputNumeric: TDACEdit
          Left = 576
          Top = 294
          Width = 220
          Height = 82
          Cursor = crIBeam
          EditKind = mekNumeric
          EditMask = '999.999.999,99;1;_'
          CounterText = '12/120'
          LabelText = 'Mascara numerica'
          Placeholder = '000.000.000,00'
          TabOrder = 7
          Text = '000.001.250,50'
        end
        object InputDate: TDACEdit
          Left = 36
          Top = 404
          Width = 240
          Height = 60
          Cursor = crIBeam
          EditKind = mekDate
          LabelText = 'Data'
          Placeholder = 'dd/mm/aaaa'
          TabOrder = 8
          Text = '24/05/2025'
        end
        object InputTime: TDACEdit
          Left = 306
          Top = 404
          Width = 240
          Height = 60
          Cursor = crIBeam
          EditKind = mekTime
          LabelText = 'Hora'
          Placeholder = 'hh:mm'
          TabOrder = 9
          Text = '14:35'
        end
        object InputDateTimePicker: TDACDateTimePicker
          Left = 576
          Top = 404
          Width = 220
          Height = 60
          FormatString = 'dd/MM/yyyy HH:mm'
          LabelText = 'DateTimePicker'
          Required = True
          Status = mesSuccess
          TabOrder = 10
        end
        object InputButtonEditDefault: TDACButtonEdit
          Left = 36
          Top = 494
          Width = 240
          Height = 82
          ButtonIconKind = mikSearch
          HelperText = 'Informe o nome completo do cliente.'
          LabelText = 'ButtonEdit'
          Placeholder = 'Digite um valor...'
          TabOrder = 11
          Text = ''
        end
        object InputButtonEditCalendar: TDACButtonEdit
          Left = 306
          Top = 494
          Width = 240
          Height = 60
          ButtonIconKind = mikCalendar
          LabelText = 'Com icone'
          Placeholder = 'Selecione uma data...'
          TabOrder = 12
          Text = ''
        end
        object InputButtonEditMore: TDACButtonEdit
          Left = 576
          Top = 494
          Width = 220
          Height = 60
          ButtonIconKind = mikMoreVertical
          LabelText = 'Mais opcoes'
          Placeholder = 'Escolha uma opcao...'
          TabOrder = 13
          Text = ''
        end
        object InputButtonEditOk: TDACButtonEdit
          Left = 36
          Top = 584
          Width = 240
          Height = 60
          ButtonCaption = 'OK'
          ButtonIconKind = mikCheck
          ButtonWidth = 58
          LabelText = 'Texto no botao'
          Placeholder = 'Informe o codigo...'
          ShowButtonIcon = False
          TabOrder = 14
          Text = ''
        end
        object InputButtonEditDropDown: TDACButtonEdit
          Left = 306
          Top = 584
          Width = 240
          Height = 60
          ButtonIconKind = mikChevronDown
          LabelText = 'Com dropdown'
          Placeholder = 'Selecione...'
          TabOrder = 15
          Text = ''
        end
        object InputButtonEditClear: TDACButtonEdit
          Left = 576
          Top = 584
          Width = 220
          Height = 82
          ButtonIconKind = mikClose
          HelperText = 'Informe um valor valido.'
          LabelText = 'Com clear'
          Status = mesDanger
          TabOrder = 16
          Text = 'Valor invalido'
        end
      end
    end
    object PageControls: TDACScrollContainer
      Left = 12
      Top = 58
      Width = 976
      Height = 404
      Align = alClient
      BorderStyle = bsNone
      BackgroundColor = claWhite
      BorderColor = claNull
      CornerRadius = 0
      Color = clWhite
      ParentColor = False
      TabOrder = 2
      Visible = False
      StyleElements = [seFont, seBorder]
      object SectionControls: TDACContainer
        Left = 16
        Top = 16
        Width = 850
        Height = 270
        BackgroundColor = claWhite
        BorderColor = xFFD5DBE6
        ContentPadding = 18
        SectionNumber = 3
        Subtitle = 'Checkbox, radio, toggle e slider desenhados em Skia'
        SubtitleColor = xFF475569
        TabOrder = 0
        Title = 'CONTROLES'
        TitleColor = xFF111827
        object DemoCheckMarked: TDACCheckBox
          Left = 36
          Top = 86
          Width = 220
          Height = 28
          Cursor = crHandPoint
          Caption = 'CheckBox (marcado)'
          Checked = True
          TabOrder = 0
        end
        object DemoCheckUnmarked: TDACCheckBox
          Left = 36
          Top = 124
          Width = 240
          Height = 28
          Cursor = crHandPoint
          Caption = 'CheckBox (desmarcado)'
          TabOrder = 1
        end
        object DemoRadioSelected: TDACRadioButton
          Left = 306
          Top = 86
          Width = 250
          Height = 28
          Cursor = crHandPoint
          Caption = 'RadioButton (selecionado)'
          Checked = True
          TabOrder = 2
        end
        object DemoRadioUnselected: TDACRadioButton
          Left = 306
          Top = 124
          Width = 270
          Height = 28
          Cursor = crHandPoint
          Caption = 'RadioButton (nao selecionado)'
          TabOrder = 3
        end
        object DemoToggleOn: TDACToggleSwitch
          Left = 612
          Top = 82
          Width = 190
          Height = 30
          Cursor = crHandPoint
          Caption = 'Toggle ativo'
          Checked = True
          TabOrder = 4
        end
        object DemoToggleOff: TDACToggleSwitch
          Left = 612
          Top = 122
          Width = 190
          Height = 30
          Cursor = crHandPoint
          Caption = 'Toggle inativo'
          TabOrder = 5
        end
        object DemoSlider: TDACSlider
          Left = 36
          Top = 188
          Width = 360
          Height = 36
          Cursor = crHandPoint
          TabOrder = 7
          Value = 75
        end
      end
    end
    object PageContainers: TDACScrollContainer
      Left = 12
      Top = 58
      Width = 976
      Height = 404
      Align = alClient
      BorderStyle = bsNone
      BackgroundColor = claWhite
      BorderColor = claNull
      CornerRadius = 0
      Color = clWhite
      ParentColor = False
      TabOrder = 3
      Visible = False
      StyleElements = [seFont, seBorder]
      object SectionContainers: TDACContainer
        Left = 0
        Top = 0
        Width = 976
        Height = 404
        Align = alClient
        BackgroundColor = claWhite
        BorderColor = xFFD5DBE6
        ContentPadding = 18
        SectionNumber = 4
        Subtitle = 'Variacoes do container reutilizavel e hospedagem de filhos'
        SubtitleColor = xFF475569
        TabOrder = 0
        Title = 'CONTAINERS'
        TitleColor = xFF111827
        ExplicitLeft = 16
        ExplicitTop = 16
        ExplicitWidth = 850
        ExplicitHeight = 300
        object ContainerSuiteSection: TDACContainer
          Left = 36
          Top = 82
          Width = 230
          Height = 150
          BackgroundColor = claWhite
          BorderColor = xFFD5DBE6
          BorderRadius = 12
          ContentPadding = 14
          CornerRadius = 12
          HeaderHeight = 40
          Subtitle = 'Container claro com borda suave.'
          SubtitleColor = xFF475569
          TabOrder = 0
          Title = 'Suite section'
          TitleColor = xFF111827
        end
        object ContainerDarkPanel: TDACContainer
          Left = 298
          Top = 24
          Width = 230
          Height = 361
          Appearance = mcaDarkPanel
          BackgroundColor = xFF102417
          BorderColor = xFF2B3D31
          BorderRadius = 12
          ContentPadding = 14
          CornerRadius = 12
          HeaderHeight = 40
          Subtitle = 'Painel escuro para destaque.'
          SubtitleColor = xFFB8C4B8
          TabOrder = 1
          Title = 'Dark panel'
          TitleColor = xFFE8EEE8
          object ButtonInsideContainer: TDACButton
            Left = 14
            Top = 96
            Width = 140
            Height = 34
            Cursor = crHandPoint
            Caption = 'Acao'
            IconSize = 16
            ShowIcon = True
            TabOrder = 0
          end
          object DACEdit1: TDACEdit
            Left = 7
            Top = 152
            Width = 220
            Height = 38
            Cursor = crIBeam
            TabOrder = 1
            Text = ''
          end
          object DACMemo1: TDACMemo
            Left = 7
            Top = 196
            Width = 220
            Height = 88
            Cursor = crIBeam
            TabOrder = 2
            Text = ''
          end
          object DACComboBox1: TDACComboBox
            Left = 3
            Top = 300
            Width = 220
            Height = 38
            TabOrder = 3
            Text = ''
          end
        end
        object ContainerTransparent: TDACContainer
          Left = 548
          Top = 82
          Width = 230
          Height = 150
          Appearance = mcaTransparent
          BackgroundColor = claNull
          BorderColor = claNull
          BorderRadius = 12
          BorderWidth = 0
          ContentPadding = 14
          CornerRadius = 12
          HeaderHeight = 40
          Subtitle = 'Area sem chrome para composicao.'
          SubtitleColor = xFF475569
          TabOrder = 2
          Title = 'Transparent'
          TitleColor = xFF0F172A
        end
        object DemoScrollContainer: TDACScrollContainer
          Left = 548
          Top = 248
          Width = 230
          Height = 120
          BackgroundColor = claWhite
          BorderColor = xFFD5DBE6
          CornerRadius = 10
          TabOrder = 3
        end
        object DemoGridContainer: TDACGridContainer
          Left = 36
          Top = 248
          Width = 230
          Height = 120
          BackgroundColor = claWhite
          BorderColor = xFFD5DBE6
          Columns = 3
          ContentPadding = 12
          CornerRadius = 10
          Gutter = 10
          RowHeight = 42
          TabOrder = 4
        end
      end
    end
    object PageTabs: TDACScrollContainer
      Left = 12
      Top = 58
      Width = 976
      Height = 404
      Align = alClient
      BorderStyle = bsNone
      BackgroundColor = claWhite
      BorderColor = claNull
      CornerRadius = 0
      Color = clWhite
      ParentColor = False
      TabOrder = 4
      Visible = False
      StyleElements = [seFont, seBorder]
      object SectionTabs: TDACContainer
        Left = 0
        Top = 0
        Width = 976
        Height = 404
        Align = alClient
        BackgroundColor = claWhite
        BorderColor = xFFD5DBE6
        ContentPadding = 18
        SectionNumber = 5
        Subtitle = 'Abas horizontais, verticais e pills desenhadas em Skia'
        SubtitleColor = xFF475569
        TabOrder = 0
        Title = 'TABS'
        TitleColor = xFF111827
        object DemoHorizontalTabs: TDACTabs
          Left = 36
          Top = 86
          Width = 430
          Height = 162
          Cursor = crHandPoint
          ActiveIndex = 0
          ContentColor = claWhite
          CornerRadius = 8
          Items = <
            item
              Caption = 'Dados gerais'
            end
            item
              Caption = 'Planejamento'
            end
            item
              Caption = 'Recursos'
            end
            item
              Caption = 'Anexos'
            end>
          TabHeight = 38
          TabOrder = 0
          TabWidth = 104
          object DemoHorizontalContent: TDACContainer
            Left = 12
            Top = 50
            Width = 406
            Height = 100
            Align = alClient
            Appearance = mcaTransparent
            BackgroundColor = claNull
            BorderColor = claNull
            BorderWidth = 0
            ContentPadding = 12
            HeaderHeight = 32
            Subtitle = 'Conteudo da aba horizontal selecionada.'
            SubtitleColor = xFF475569
            TabOrder = 0
            Title = 'Dados gerais'
            TitleColor = xFF111827
          end
        end
        object DemoVerticalTabs: TDACTabs
          Left = 506
          Top = 86
          Width = 410
          Height = 162
          Cursor = crHandPoint
          ActiveIndex = 0
          Appearance = mtaPills
          ContentColor = claWhite
          CornerRadius = 8
          Items = <
            item
              Caption = 'Resumo'
            end
            item
              Caption = 'Detalhes'
            end
            item
              Caption = 'Historico'
            end
            item
              Caption = 'Anexos'
            end>
          Orientation = mtoVertical
          TabHeight = 32
          TabOrder = 1
          TabWidth = 124
          object DemoVerticalContent: TDACContainer
            Left = 136
            Top = 12
            Width = 262
            Height = 138
            Align = alClient
            Appearance = mcaTransparent
            BackgroundColor = claNull
            BorderColor = claNull
            BorderWidth = 0
            ContentPadding = 12
            HeaderHeight = 32
            Subtitle = 'Conteudo lateral das abas.'
            SubtitleColor = xFF475569
            TabOrder = 0
            Title = 'Resumo'
            TitleColor = xFF111827
          end
        end
        object DemoPillTabs: TDACTabs
          Left = 36
          Top = 254
          Width = 530
          Height = 132
          Cursor = crHandPoint
          ActiveIndex = 0
          Appearance = mtaPills
          ContentColor = claWhite
          CornerRadius = 8
          Items = <
            item
              Caption = 'Geral'
            end
            item
              Caption = 'Financeiro'
            end
            item
              Caption = 'Vendas'
            end
            item
              Caption = 'Configuracoes'
            end>
          ShowContentBorder = False
          TabHeight = 38
          TabOrder = 2
          TabWidth = 128
          object DemoPillContent: TDACContainer
            Left = 0
            Top = 38
            Width = 530
            Height = 94
            Align = alClient
            Appearance = mcaTransparent
            BackgroundColor = claNull
            BorderColor = claNull
            BorderWidth = 0
            ContentPadding = 10
            HeaderHeight = 28
            Subtitle = 'Estado selecionado em pill.'
            SubtitleColor = xFF475569
            TabOrder = 0
            Title = 'Geral'
            TitleColor = xFF111827
          end
        end
      end
    end
    object PageCards: TDACScrollContainer
      Left = 12
      Top = 58
      Width = 976
      Height = 404
      Align = alClient
      BorderStyle = bsNone
      BackgroundColor = claWhite
      BorderColor = claNull
      CornerRadius = 0
      Color = clWhite
      ParentColor = False
      TabOrder = 5
      Visible = False
      StyleElements = [seFont, seBorder]
      object SectionCards: TDACContainer
        Left = 16
        Top = 16
        Width = 850
        Height = 230
        BackgroundColor = claWhite
        BorderColor = xFFD5DBE6
        ContentPadding = 18
        SectionNumber = 6
        Subtitle = 'Indicadores compactos com icone, valor e variacao'
        SubtitleColor = xFF475569
        TabOrder = 0
        Title = 'CARDS DE RESUMO'
        TitleColor = xFF111827
        object CardRevenue: TDACSummaryCard
          Left = 36
          Top = 86
          Width = 185
          Height = 116
          AccentColor = xFF2F9E22
          FooterText = '+12,5% vs. mes anterior'
          IconKind = mikMoneyCircle
          Status = mcsSuccess
          TabOrder = 0
          Title = 'Receita'
          Value = 'R$ 125.430,50'
        end
        object CardOrders: TDACSummaryCard
          Left = 238
          Top = 86
          Width = 170
          Height = 116
          AccentColor = xFF2B7DE9
          FooterText = '+8,2% vs. mes anterior'
          IconKind = mikShoppingCart
          Status = mcsSuccess
          TabOrder = 1
          Title = 'Pedidos'
          Value = '1.234'
        end
        object CardClients: TDACSummaryCard
          Left = 424
          Top = 86
          Width = 170
          Height = 116
          AccentColor = xFFF5C842
          FooterText = '-2,1% vs. mes anterior'
          IconKind = mikUsers
          Status = mcsDanger
          TabOrder = 2
          Title = 'Clientes'
          Value = '856'
        end
        object CardProducts: TDACSummaryCard
          Left = 610
          Top = 86
          Width = 170
          Height = 116
          AccentColor = xFF8B3DFF
          FooterText = '+5,7% vs. mes anterior'
          IconKind = mikPackage
          Status = mcsSuccess
          TabOrder = 3
          Title = 'Produtos'
          Value = '2.345'
        end
      end
    end
    object PageGrid: TDACScrollContainer
      Left = 12
      Top = 58
      Width = 976
      Height = 404
      Align = alClient
      BorderStyle = bsNone
      BackgroundColor = claWhite
      BorderColor = claNull
      CornerRadius = 0
      Color = clWhite
      ParentColor = False
      TabOrder = 6
      Visible = False
      StyleElements = [seFont, seBorder]
      object SectionGrid: TDACContainer
        Left = 16
        Top = 16
        Width = 850
        Height = 284
        BackgroundColor = claWhite
        BorderColor = xFFD5DBE6
        ContentPadding = 18
        SectionNumber = 7
        Subtitle = 'Tabela desenhada em Skia com status, totais e acoes'
        SubtitleColor = xFF475569
        TabOrder = 0
        Title = 'TABELA / DATA GRID'
        TitleColor = xFF111827
        object DemoDataGrid: TDACDataGrid
          Left = 36
          Top = 86
          Width = 760
          Height = 170
          FooterText = 'Total: 4 registros'
          FooterValue = 'R$ 4.410,75'
          TabOrder = 0
        end
      end
    end
    object PageStatus: TDACScrollContainer
      Left = 12
      Top = 58
      Width = 976
      Height = 404
      Align = alClient
      BorderStyle = bsNone
      BackgroundColor = claWhite
      BorderColor = claNull
      CornerRadius = 0
      Color = clWhite
      ParentColor = False
      TabOrder = 7
      Visible = False
      StyleElements = [seFont, seBorder]
      object SectionStatus: TDACContainer
        Left = 16
        Top = 16
        Width = 850
        Height = 168
        BackgroundColor = claWhite
        BorderColor = xFFD5DBE6
        ContentPadding = 18
        SectionNumber = 10
        Subtitle = 'Barra de status com indicador e informacoes compactas'
        SubtitleColor = xFF475569
        TabOrder = 0
        Title = 'STATUS BAR'
        TitleColor = xFF111827
        object DemoStatusBar: TDACStatusBar
          Left = 36
          Top = 86
          Width = 720
          Height = 34
          LeftText = 'Conectado'
          RightText = 'Usuario: admin    Perfil: Administrador    24/05/2025    14:35'
          TabOrder = 0
        end
      end
    end
    object PageBadges: TDACScrollContainer
      Left = 12
      Top = 58
      Width = 976
      Height = 404
      Align = alClient
      BorderStyle = bsNone
      BackgroundColor = claWhite
      BorderColor = claNull
      CornerRadius = 0
      Color = clWhite
      ParentColor = False
      TabOrder = 8
      Visible = False
      StyleElements = [seFont, seBorder]
      object SectionBadges: TDACContainer
        Left = 16
        Top = 16
        Width = 850
        Height = 238
        BackgroundColor = claWhite
        BorderColor = xFFD5DBE6
        ContentPadding = 18
        SectionNumber = 12
        Subtitle = 'Badges, chips, tags e pills com estados semanticos'
        SubtitleColor = xFF475569
        TabOrder = 0
        Title = 'BADGES, CHIPS, TAGS E PILLS'
        TitleColor = xFF111827
        object BadgeCount: TDACBadge
          Left = 36
          Top = 86
          Width = 48
          Height = 26
          Caption = '8'
          Kind = mbkBadge
          Status = mbsSuccess
          TabOrder = 0
        end
        object BadgePending: TDACBadge
          Left = 100
          Top = 86
          Width = 56
          Height = 26
          Appearance = mbaFilled
          Caption = '23'
          Kind = mbkBadge
          Status = mbsWarning
          TabOrder = 1
        end
        object BadgeDanger: TDACBadge
          Left = 172
          Top = 86
          Width = 64
          Height = 26
          Appearance = mbaFilled
          Caption = '99+'
          Kind = mbkBadge
          Status = mbsDanger
          TabOrder = 2
        end
        object BadgeChipActive: TDACBadge
          Left = 36
          Top = 134
          Width = 96
          Height = 30
          Caption = 'Ativo'
          Kind = mbkChip
          ShowClose = True
          Status = mbsSuccess
          TabOrder = 3
        end
        object BadgeChipFilter: TDACBadge
          Left = 148
          Top = 134
          Width = 110
          Height = 30
          Appearance = mbaOutline
          Caption = 'Filtros'
          Kind = mbkChip
          ShowClose = True
          Status = mbsNeutral
          TabOrder = 4
        end
        object BadgeTagNew: TDACBadge
          Left = 306
          Top = 86
          Width = 90
          Height = 30
          Appearance = mbaFilled
          Caption = 'Novo'
          IconKind = mikTag
          Kind = mbkTag
          ShowIcon = True
          Status = mbsSuccess
          TabOrder = 5
        end
        object BadgeTagPromo: TDACBadge
          Left = 412
          Top = 86
          Width = 118
          Height = 30
          Appearance = mbaFilled
          Caption = 'Promocao'
          IconKind = mikWarning
          Kind = mbkTag
          ShowIcon = True
          Status = mbsWarning
          TabOrder = 6
        end
        object BadgePillOpen: TDACBadge
          Left = 306
          Top = 134
          Width = 112
          Height = 32
          Appearance = mbaFilled
          Caption = 'Em aberto'
          Kind = mbkPill
          Status = mbsNeutral
          TabOrder = 8
        end
        object BadgePillDone: TDACBadge
          Left = 434
          Top = 134
          Width = 118
          Height = 32
          Caption = 'Concluidos'
          Kind = mbkPill
          Status = mbsSuccess
          TabOrder = 8
        end
      end
    end
    object PageProgress: TDACScrollContainer
      Left = 12
      Top = 58
      Width = 976
      Height = 404
      Align = alClient
      BorderStyle = bsNone
      BackgroundColor = claWhite
      BorderColor = claNull
      CornerRadius = 0
      Color = clWhite
      ParentColor = False
      TabOrder = 9
      Visible = False
      StyleElements = [seFont, seBorder]
      object SectionProgress: TDACContainer
        Left = 16
        Top = 16
        Width = 850
        Height = 238
        BackgroundColor = claWhite
        BorderColor = xFFD5DBE6
        ContentPadding = 18
        SectionNumber = 11
        Subtitle = 'Indicadores lineares e circulares desenhados em Skia'
        SubtitleColor = xFF475569
        TabOrder = 0
        Title = 'PROGRESSO'
        TitleColor = xFF111827
        object ProgressLinear: TDACProgress
          Left = 36
          Top = 88
          Width = 300
          Height = 28
          TabOrder = 0
          Value = 68
        end
        object ProgressWarning: TDACProgress
          Left = 36
          Top = 132
          Width = 300
          Height = 28
          Status = mpsWarning
          TabOrder = 1
          Value = 42
        end
        object ProgressCircular: TDACProgress
          Left = 404
          Top = 78
          Width = 96
          Height = 96
          Kind = mpkCircular
          TabOrder = 2
          Value = 68
        end
        object ProgressCircularDanger: TDACProgress
          Left = 540
          Top = 78
          Width = 96
          Height = 96
          Kind = mpkCircular
          Status = mpsDanger
          TabOrder = 3
          Value = 24
        end
      end
    end
    object PagePagination: TDACScrollContainer
      Left = 12
      Top = 58
      Width = 976
      Height = 404
      Align = alClient
      BorderStyle = bsNone
      BackgroundColor = claWhite
      BorderColor = claNull
      CornerRadius = 0
      Color = clWhite
      ParentColor = False
      TabOrder = 10
      Visible = False
      StyleElements = [seFont, seBorder]
      object SectionPagination: TDACContainer
        Left = 16
        Top = 16
        Width = 850
        Height = 238
        BackgroundColor = claWhite
        BorderColor = xFFD5DBE6
        ContentPadding = 18
        SectionNumber = 14
        Subtitle = 'Navegacao paginada desenhada em Skia'
        SubtitleColor = xFF475569
        TabOrder = 0
        Title = 'PAGINACAO'
        TitleColor = xFF111827
        object PaginationMain: TDACPagination
          Left = 36
          Top = 88
          Width = 520
          Height = 40
          Cursor = crHandPoint
          PageCount = 12
          PageIndex = 3
          PageSizeText = '10 / pagina'
          TabOrder = 0
        end
        object PaginationCompact: TDACPagination
          Left = 36
          Top = 148
          Width = 360
          Height = 40
          Cursor = crHandPoint
          PageCount = 4
          PageIndex = 1
          PageSizeText = '25 / pagina'
          ShowPageSize = False
          TabOrder = 1
        end
      end
    end
    object PageLoading: TDACScrollContainer
      Left = 12
      Top = 58
      Width = 976
      Height = 404
      Align = alClient
      BorderStyle = bsNone
      BackgroundColor = claWhite
      BorderColor = claNull
      CornerRadius = 0
      Color = clWhite
      ParentColor = False
      TabOrder = 11
      Visible = False
      StyleElements = [seFont, seBorder]
      object SectionLoading: TDACContainer
        Left = 16
        Top = 16
        Width = 850
        Height = 238
        BackgroundColor = claWhite
        BorderColor = xFFD5DBE6
        ContentPadding = 18
        SectionNumber = 15
        Subtitle = 'Spinner, dots e skeleton desenhados em Skia'
        SubtitleColor = xFF475569
        TabOrder = 0
        Title = 'LOADING / SPINNER'
        TitleColor = xFF111827
        object LoadingSpinner: TDACLoading
          Left = 36
          Top = 88
          Width = 80
          Height = 56
          TabOrder = 0
        end
        object LoadingDots: TDACLoading
          Left = 160
          Top = 88
          Width = 120
          Height = 56
          Kind = mlkDots
          TabOrder = 1
        end
        object LoadingSkeleton: TDACLoading
          Left = 324
          Top = 88
          Width = 260
          Height = 56
          Kind = mlkSkeleton
          TabOrder = 2
        end
      end
    end
    object PageFeedback: TDACScrollContainer
      Left = 12
      Top = 58
      Width = 976
      Height = 404
      Align = alClient
      BorderStyle = bsNone
      BackgroundColor = claWhite
      BorderColor = claNull
      CornerRadius = 0
      Color = clWhite
      ParentColor = False
      TabOrder = 12
      Visible = False
      StyleElements = [seFont, seBorder]
      object SectionFeedback: TDACContainer
        Left = 16
        Top = 16
        Width = 850
        Height = 300
        BackgroundColor = claWhite
        BorderColor = xFFD5DBE6
        ContentPadding = 18
        SectionNumber = 13
        Subtitle = 'Toast e modal de confirmacao desenhados em Skia'
        SubtitleColor = xFF475569
        TabOrder = 0
        Title = 'TOAST, TOOLTIP E MODAL'
        TitleColor = xFF111827
        object ToastSuccess: TDACToast
          Left = 36
          Top = 86
          Width = 260
          Height = 72
          MessageText = 'Com sucesso.'
          Status = mssSuccess
          TabOrder = 0
          TitleText = 'Operacao realizada'
        end
        object ToastWarning: TDACToast
          Left = 36
          Top = 170
          Width = 260
          Height = 72
          MessageText = 'Verifique as informacoes.'
          Status = mssWarning
          TabOrder = 1
          TitleText = 'Atencao'
        end
        object ToastDanger: TDACToast
          Left = 318
          Top = 86
          Width = 260
          Height = 72
          MessageText = 'Tente novamente.'
          Status = mssDanger
          TabOrder = 2
          TitleText = 'Erro ao salvar'
        end
        object ModalPreview: TDACModalDialog
          Left = 596
          Top = 86
          Width = 220
          Height = 156
          MessageText = 'Deseja confirmar esta operacao?'
          Status = mssInfo
          TabOrder = 3
          TitleText = 'Confirmacao'
        end
      end
    end
    object PageCharts: TDACScrollContainer
      Left = 12
      Top = 58
      Width = 976
      Height = 404
      Align = alClient
      BorderStyle = bsNone
      BackgroundColor = claWhite
      BorderColor = claNull
      CornerRadius = 0
      Color = clWhite
      ParentColor = False
      TabOrder = 13
      Visible = False
      StyleElements = [seFont, seBorder]
      object SectionCharts: TDACContainer
        Left = 16
        Top = 16
        Width = 850
        Height = 320
        BackgroundColor = claWhite
        BorderColor = xFFD5DBE6
        ContentPadding = 18
        SectionNumber = 16
        Subtitle = 'Graficos de barra, linha, area e donut em Skia'
        SubtitleColor = xFF475569
        TabOrder = 0
        Title = 'CHARTS'
        TitleColor = xFF111827
        object ChartBars: TDACBarChart
          Left = 36
          Top = 86
          Width = 180
          Height = 150
          TabOrder = 0
          ValuesText = '52;68;74;82;94;60'
        end
        object ChartLine: TDACLineChart
          Left = 236
          Top = 86
          Width = 180
          Height = 150
          TabOrder = 1
          ValuesText = '25;48;40;65;54;82'
        end
        object ChartArea: TDACAreaChart
          Left = 436
          Top = 86
          Width = 180
          Height = 150
          TabOrder = 2
          ValuesText = '42;78;63;72;58;96'
        end
        object ChartDoughnut: TDACDoughnutChart
          Left = 636
          Top = 86
          Width = 150
          Height = 150
          TabOrder = 3
          ValuesText = '45;25;20;10'
        end
      end
    end
    object PageReport: TDACScrollContainer
      Left = 12
      Top = 58
      Width = 976
      Height = 404
      Align = alClient
      BorderStyle = bsNone
      BackgroundColor = claWhite
      BorderColor = claNull
      CornerRadius = 0
      Color = clWhite
      ParentColor = False
      TabOrder = 14
      Visible = False
      StyleElements = [seFont, seBorder]
      object SectionReport: TDACContainer
        Left = 16
        Top = 16
        Width = 850
        Height = 350
        BackgroundColor = claWhite
        BorderColor = xFFD5DBE6
        ContentPadding = 18
        SectionNumber = 17
        Subtitle = 'Viewer de relatorio com preview visual em Skia'
        SubtitleColor = xFF475569
        TabOrder = 0
        Title = 'JANELA DE RELATORIO / REPORT VIEWER'
        TitleColor = xFF111827
        object ReportPreview: TDACReportViewer
          Left = 36
          Top = 86
          Width = 760
          Height = 230
          PageCount = 5
          PageIndex = 1
          TabOrder = 0
          ZoomPercent = 100
        end
      end
    end
  end
end

