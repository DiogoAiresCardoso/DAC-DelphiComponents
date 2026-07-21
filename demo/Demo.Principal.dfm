object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'DAC Componentes - Demo'
  ClientHeight = 760
  ClientWidth = 1200
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -12
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  PixelsPerInch = 96
  TextHeight = 15
  object GalleryTabs: TDACTabs
    Left = 0
    Top = 0
    Width = 1200
    Height = 760
    ActivePage = tsDashboard
    Align = alClient
    TabOrder = 0
    TabHeight = 44
    TabWidth = 132
    ActiveIndex = 0
    object tsDashboard: TTabSheet
      Caption = 'Dashboard'
      object scrDashboard: TDACScrollContainer
        Left = 0
        Top = 0
        Width = 1192
        Height = 708
        Align = alClient
        AutoScroll = True
        BorderStyle = bsNone
        CornerRadius = 0
        ScrollBarMode = msbmVertical
        BackgroundColor = -16248051
        BorderColor = 0
        TabOrder = 0
        object dashWelcomeTitle: TDACSystemText
          Left = 24
          Top = 24
          Width = 220
          Height = 32
          Bold = False
          FontSize = 20
          Text = 'Bem-vindo,'
          TextColor = -657163
        end
        object dashWelcomeName: TDACSystemText
          Left = 252
          Top = 24
          Width = 500
          Height = 32
          Bold = False
          FontSize = 20
          Text = 'Administrador'
          TextColor = -12339413
        end
        object dashWelcomeSubtitle: TDACSystemText
          Left = 24
          Top = 58
          Width = 430
          Height = 24
          Bold = False
          FontSize = 10
          Text = 'Aqui esta o resumo da sua operacao hoje.'
          TextColor = -4668998
        end
        object dashDateSummary: TDACContainer
          Left = 960
          Top = 24
          Width = 210
          Height = 72
          ContentPadding = 20
          Appearance = mcaDarkPanel
          BackgroundColor = -435282155
          BorderColor = 486539263
          BorderRadius = 14
          CornerRadius = 14
          TitleColor = -657163
          SubtitleColor = -4668998
          ShowHeader = False
          TabOrder = 1
          object dashDateValue: TDACSystemText
            Left = 20
            Top = 18
            Width = 160
            Height = 20
            Bold = True
            FontSize = 10
            Text = '24 de maio de 2025'
            TextColor = -657163
          end
          object dashDateWeekday: TDACSystemText
            Left = 20
            Top = 40
            Width = 160
            Height = 20
            Bold = False
            FontSize = 9
            Text = 'Sabado'
            TextColor = -4668998
          end
        end
        object dashKpi1: TDACSummaryCard
          Left = 24
          Top = 96
          Width = 214
          Height = 108
          AccentColor = -12339413
          BackgroundColor = -435282155
          BorderColor = 486539263
          CornerRadius = 14
          FooterText = '+ 2 este mes'
          IconKind = mikField
          Title = 'Talhoes'
          Value = '28'
        end
        object dashKpi2: TDACSummaryCard
          Left = 254
          Top = 96
          Width = 214
          Height = 108
          AccentColor = -12339413
          BackgroundColor = -435282155
          BorderColor = 486539263
          CornerRadius = 14
          FooterText = '+ 8,4% vs. safra anterior'
          IconKind = mikLeaf
          Title = 'Producao (safra)'
          Value = '12.540 t'
        end
        object dashKpi3: TDACSummaryCard
          Left = 484
          Top = 96
          Width = 214
          Height = 108
          AccentColor = -12339413
          BackgroundColor = -435282155
          BorderColor = 486539263
          CornerRadius = 14
          FooterText = '12 itens cadastrados'
          IconKind = mikInventoryStack
          Title = 'Estoque'
          Value = '3.680 t'
        end
        object dashKpi4: TDACSummaryCard
          Left = 714
          Top = 96
          Width = 214
          Height = 108
          AccentColor = -12339413
          BackgroundColor = -435282155
          BorderColor = 486539263
          CornerRadius = 14
          FooterText = '5 em andamento'
          IconKind = mikClipboardOrder
          Title = 'Ordens'
          Value = '14'
        end
        object dashKpi5: TDACSummaryCard
          Left = 944
          Top = 96
          Width = 214
          Height = 108
          AccentColor = -12339413
          BackgroundColor = -435282155
          BorderColor = 486539263
          CornerRadius = 14
          FooterText = '+ 12,7% vs. mes anterior'
          IconKind = mikMoneyCircle
          Title = 'Financeiro (mes)'
          Value = 'R$ 568.420'
        end
        object dashQuickActions: TDACContainer
          Left = 24
          Top = 228
          Width = 370
          Height = 224
          ContentPadding = 20
          Appearance = mcaDarkPanel
          BackgroundColor = -435282155
          BorderColor = 486539263
          BorderRadius = 14
          CornerRadius = 14
          SubtitleColor = -4668998
          TitleColor = -657163
          Title = 'Acoes rapidas'
          TabOrder = 2
          object dashQuickActionsGrid: TDACGridContainer
            Left = 20
            Top = 62
            Width = 330
            Height = 142
            Align = alClient
            Columns = 2
            BackgroundColor = 0
            BorderColor = 0
            ContentPadding = 0
            Gutter = 12
            RowHeight = 70
            TabOrder = 0
            object dashQuickAction1: TDACButton
              Left = 0
              Top = 0
              Width = 159
              Height = 70
              Caption = 'Nova ordem de servico'
              CornerRadius = 12
              ShowIcon = True
              IconKind = mikTractor
              IconSize = 22
              Kind = mbkGhost
              TabOrder = 0
            end
            object dashQuickAction2: TDACButton
              Left = 171
              Top = 0
              Width = 159
              Height = 70
              Caption = 'Lancar producao'
              CornerRadius = 12
              ShowIcon = True
              IconKind = mikSoybean
              IconSize = 22
              Kind = mbkGhost
              TabOrder = 1
            end
            object dashQuickAction3: TDACButton
              Left = 0
              Top = 82
              Width = 159
              Height = 70
              Caption = 'Entrada no estoque'
              CornerRadius = 12
              ShowIcon = True
              IconKind = mikPackage
              IconSize = 22
              Kind = mbkGhost
              TabOrder = 2
            end
            object dashQuickAction4: TDACButton
              Left = 171
              Top = 82
              Width = 159
              Height = 70
              Caption = 'Nova despesa'
              CornerRadius = 12
              ShowIcon = True
              IconKind = mikMoneyCircle
              IconSize = 22
              Kind = mbkGhost
              TabOrder = 3
            end
          end
        end
        object dashAgenda: TDACContainer
          Left = 410
          Top = 228
          Width = 370
          Height = 224
          ContentPadding = 20
          Appearance = mcaDarkPanel
          BackgroundColor = -435282155
          BorderColor = 486539263
          BorderRadius = 14
          CornerRadius = 14
          SubtitleColor = -4668998
          TitleColor = -657163
          Title = 'Agenda'
          TabOrder = 3
          object dashAgendaLine1: TDACSystemText
            Left = 20
            Top = 70
            Width = 320
            Height = 32
            FontSize = 10
            Text = '24 MAI   Aplicacao de Herbicida   Hoje'
            TextColor = -657163
          end
          object dashAgendaLine2: TDACSystemText
            Left = 20
            Top = 110
            Width = 320
            Height = 32
            FontSize = 10
            Text = '25 MAI   Irrigacao - Talhao 08   Amanha'
            TextColor = -657163
          end
          object dashAgendaLine3: TDACSystemText
            Left = 20
            Top = 150
            Width = 320
            Height = 32
            FontSize = 10
            Text = '27 MAI   Manutencao de Equipamentos'
            TextColor = -657163
          end
          object dashAgendaFooter: TDACSystemText
            Left = 20
            Top = 190
            Width = 320
            Height = 24
            Bold = True
            FontSize = 10
            Text = 'Ver agenda completa  ->'
            TextColor = -10302406
          end
        end
        object dashRecentActivity: TDACContainer
          Left = 796
          Top = 228
          Width = 370
          Height = 224
          ContentPadding = 20
          Appearance = mcaDarkPanel
          BackgroundColor = -435282155
          BorderColor = 486539263
          BorderRadius = 14
          CornerRadius = 14
          SubtitleColor = -4668998
          TitleColor = -657163
          Title = 'Atividades recentes'
          TabOrder = 4
          object dashActivityLine1: TDACSystemText
            Left = 20
            Top = 70
            Width = 320
            Height = 32
            FontSize = 10
            Text = 'Entrada de 120 sacas de Sementes de Soja'
            TextColor = -657163
          end
          object dashActivityLine2: TDACSystemText
            Left = 20
            Top = 110
            Width = 320
            Height = 32
            FontSize = 10
            Text = 'Ordem de servico #OS-1456 concluida'
            TextColor = -657163
          end
          object dashActivityLine3: TDACSystemText
            Left = 20
            Top = 150
            Width = 320
            Height = 32
            FontSize = 10
            Text = 'Producao lancada: 320 t de Soja'
            TextColor = -657163
          end
          object dashActivityFooter: TDACSystemText
            Left = 20
            Top = 190
            Width = 320
            Height = 24
            Bold = True
            FontSize = 10
            Text = 'Ver todas as atividades  ->'
            TextColor = -10302406
          end
        end
        object dashProductivity: TDACContainer
          Left = 24
          Top = 476
          Width = 560
          Height = 270
          ContentPadding = 20
          Appearance = mcaDarkPanel
          BackgroundColor = -435282155
          BorderColor = 486539263
          BorderRadius = 14
          CornerRadius = 14
          SubtitleColor = -4668998
          TitleColor = -657163
          Title = 'Produtividade da safra'
          TabOrder = 5
          object dashProductivityChart: TDACBarChart
            Left = 20
            Top = 62
            Width = 520
            Height = 188
            Align = alClient
            BackgroundColor = -536077037
            BorderColor = 486539263
            CategoriesText = 'Jan;Fev;Mar;Abr;Mai'
            ValuesText = '42;68;57;75;54'
            TabOrder = 0
          end
        end
        object dashModules: TDACContainer
          Left = 600
          Top = 476
          Width = 566
          Height = 270
          ContentPadding = 20
          Appearance = mcaDarkPanel
          BackgroundColor = -435282155
          BorderColor = 486539263
          BorderRadius = 14
          CornerRadius = 14
          SubtitleColor = -4668998
          TitleColor = -657163
          Title = 'Modulos'
          TabOrder = 6
          object dashModule1: TDACContainer
            Left = 20
            Top = 56
            Width = 125
            Height = 172
            ContentPadding = 12
            Appearance = mcaDarkPanel
            BackgroundColor = -536077037
            BorderColor = -1941719253
            BorderRadius = 12
            CornerRadius = 12
            SubtitleColor = -4668998
            TitleColor = -657163
            ShowHeader = False
            TabOrder = 0
            object dashModule1Text: TDACSystemText
              Left = 20
              Top = 52
              Width = 100
              Height = 32
              Bold = True
              FontSize = 11
              Text = 'Producao'
              TextColor = -657163
            end
          end
          object dashModule2: TDACContainer
            Left = 157
            Top = 56
            Width = 125
            Height = 172
            ContentPadding = 12
            Appearance = mcaDarkPanel
            BackgroundColor = -536077037
            BorderColor = -1941719253
            BorderRadius = 12
            CornerRadius = 12
            SubtitleColor = -4668998
            TitleColor = -657163
            ShowHeader = False
            TabOrder = 1
            object dashModule2Text: TDACSystemText
              Left = 20
              Top = 52
              Width = 100
              Height = 32
              Bold = True
              FontSize = 11
              Text = 'Estoque'
              TextColor = -657163
            end
          end
          object dashModule3: TDACContainer
            Left = 294
            Top = 56
            Width = 125
            Height = 172
            ContentPadding = 12
            Appearance = mcaDarkPanel
            BackgroundColor = -536077037
            BorderColor = -1941719253
            BorderRadius = 12
            CornerRadius = 12
            SubtitleColor = -4668998
            TitleColor = -657163
            ShowHeader = False
            TabOrder = 2
            object dashModule3Text: TDACSystemText
              Left = 20
              Top = 52
              Width = 100
              Height = 32
              Bold = True
              FontSize = 11
              Text = 'Financeiro'
              TextColor = -657163
            end
          end
          object dashModule4: TDACContainer
            Left = 431
            Top = 56
            Width = 125
            Height = 172
            ContentPadding = 12
            Appearance = mcaDarkPanel
            BackgroundColor = -536077037
            BorderColor = -1941719253
            BorderRadius = 12
            CornerRadius = 12
            SubtitleColor = -4668998
            TitleColor = -657163
            ShowHeader = False
            TabOrder = 3
            object dashModule4Text: TDACSystemText
              Left = 20
              Top = 52
              Width = 100
              Height = 32
              Bold = True
              FontSize = 11
              Text = 'Relatorios'
              TextColor = -657163
            end
          end
        end
        object dashStatus: TDACContainer
          Left = 24
          Top = 770
          Width = 1142
          Height = 56
          ContentPadding = 20
          Appearance = mcaDarkPanel
          BackgroundColor = -435282155
          BorderColor = 486539263
          BorderRadius = 14
          CornerRadius = 14
          SubtitleColor = -4668998
          TitleColor = -657163
          ShowHeader = False
          TabOrder = 7
          object dashStatusConnection: TDACSystemText
            Left = 20
            Top = 18
            Width = 130
            Height = 20
            Bold = True
            FontSize = 9
            Text = 'Conectado'
            TextColor = -12205254
          end
          object dashStatusFarm: TDACSystemText
            Left = 480
            Top = 18
            Width = 180
            Height = 20
            FontSize = 9
            Text = 'Fazenda Boa Vista'
            TextColor = -657163
          end
          object dashStatusSeason: TDACSystemText
            Left = 960
            Top = 18
            Width = 150
            Height = 20
            FontSize = 9
            Text = 'Safra 2024/25'
            TextColor = -4668998
          end
        end
      end
    end
    object tsButtons: TTabSheet
      Caption = 'Botoes'
      object scrButtons: TDACScrollContainer
        Left = 0
        Top = 0
        Width = 1192
        Height = 708
        Align = alClient
        AutoScroll = True
        BorderStyle = bsNone
        CornerRadius = 0
        ScrollBarMode = msbmVertical
        TabOrder = 0
        object lblButtonsTitle: TLabel
          Left = 24
          Top = 22
          Width = 193
          Height = 25
          Caption = 'Botoes DACComponentes'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 985605
          Font.Height = -19
          Font.Name = 'Segoe UI Semibold'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object lblButtonsSubtitle: TLabel
          Left = 24
          Top = 53
          Width = 857
          Height = 15
          Caption = 'Cenarios declarativos como no designer: Kind, Size, IconKind, IconPosition, Loading, Enabled, TabStop, CornerRadius e variacoes de acao.'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 5263440
          Font.Height = -12
          Font.Name = 'Segoe UI'
          Font.Style = []
          ParentFont = False
        end
        object lblButtonKinds: TLabel
          Left = 24
          Top = 92
          Width = 150
          Height = 17
          Caption = '1. Variantes de Kind'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 985605
          Font.Height = -13
          Font.Name = 'Segoe UI Semibold'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object gcButtonKinds: TDACGridContainer
          Left = 24
          Top = 116
          Width = 1128
          Height = 148
          Columns = 12
          ContentPadding = 16
          CornerRadius = 10
          Gutter = 10
          RowHeight = 44
          TabOrder = 0
          object btnKindPrimary: TDACButton
            Left = 40
            Top = 132
            Width = 180
            Height = 44
            Caption = 'Primario'
            ShowIcon = True
            IconKind = mikCheck
            Tag = 3
            TabOrder = 0
          end
          object btnKindSecondary: TDACButton
            Left = 230
            Top = 132
            Width = 180
            Height = 44
            Caption = 'Secundario'
            Kind = mbkSecondary
            ShowIcon = True
            IconKind = mikEdit
            Tag = 3
            TabOrder = 1
          end
          object btnKindGhost: TDACButton
            Left = 420
            Top = 132
            Width = 180
            Height = 44
            Caption = 'Ghost'
            Kind = mbkGhost
            ShowIcon = True
            IconKind = mikInfoCircle
            Tag = 3
            TabOrder = 2
          end
          object btnKindWarning: TDACButton
            Left = 610
            Top = 132
            Width = 180
            Height = 44
            Caption = 'Alerta'
            Kind = mbkWarning
            ShowIcon = True
            IconKind = mikWarning
            Tag = 3
            TabOrder = 3
          end
          object btnKindDanger: TDACButton
            Left = 40
            Top = 186
            Width = 180
            Height = 44
            Caption = 'Perigo'
            Kind = mbkDanger
            ShowIcon = True
            IconKind = mikDanger
            Tag = 3
            TabOrder = 4
          end
          object btnKindTransparent: TDACButton
            Left = 230
            Top = 186
            Width = 180
            Height = 44
            Caption = 'Transparente'
            Kind = mbkTransparent
            ShowIcon = True
            IconKind = mikExternalLink
            Tag = 3
            TabOrder = 5
          end
          object btnKindInputAction: TDACButton
            Left = 420
            Top = 186
            Width = 180
            Height = 44
            Caption = ''
            Hint = 'Acao de input'
            Kind = mbkInputAction
            ShowIcon = True
            ShowHint = True
            IconKind = mikSearch
            Tag = 1
            TabOrder = 6
          end
        end
        object lblButtonSizes: TLabel
          Left = 24
          Top = 288
          Width = 230
          Height = 17
          Caption = '2. Tamanhos, raio e foco por teclado'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 985605
          Font.Height = -13
          Font.Name = 'Segoe UI Semibold'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object gcButtonSizes: TDACGridContainer
          Left = 24
          Top = 312
          Width = 1128
          Height = 148
          Columns = 12
          ContentPadding = 16
          CornerRadius = 10
          Gutter = 10
          RowHeight = 46
          TabOrder = 1
          object btnSizeSmall: TDACButton
            Left = 40
            Top = 328
            Width = 180
            Height = 30
            Caption = 'Pequeno'
            Size = mbsSmall
            ShowIcon = True
            IconKind = mikMinus
            Tag = 3
            TabOrder = 0
          end
          object btnSizeMedium: TDACButton
            Left = 230
            Top = 328
            Width = 180
            Height = 36
            Caption = 'Medio'
            ShowIcon = True
            IconKind = mikCheck
            Tag = 3
            TabOrder = 1
          end
          object btnSizeLarge: TDACButton
            Left = 420
            Top = 328
            Width = 180
            Height = 42
            Caption = 'Grande'
            Size = mbsLarge
            ShowIcon = True
            IconKind = mikExpand
            Tag = 3
            TabOrder = 2
          end
          object btnRadiusSoft: TDACButton
            Left = 610
            Top = 328
            Width = 180
            Height = 46
            Caption = 'Raio 4'
            Kind = mbkSecondary
            CornerRadius = 4
            Tag = 3
            TabOrder = 3
          end
          object btnRadiusPill: TDACButton
            Left = 40
            Top = 384
            Width = 180
            Height = 46
            Caption = 'Raio pill'
            CornerRadius = 20
            ShowIcon = True
            IconKind = mikLeaf
            Tag = 3
            TabOrder = 4
          end
          object btnNoTabStop: TDACButton
            Left = 230
            Top = 384
            Width = 180
            Height = 46
            Caption = 'TabStop False'
            Kind = mbkGhost
            TabStop = False
            Tag = 3
            TabOrder = 5
          end
        end
        object lblButtonIcons: TLabel
          Left = 24
          Top = 484
          Width = 218
          Height = 17
          Caption = '3. Icones, posicao e icon-only'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 985605
          Font.Height = -13
          Font.Name = 'Segoe UI Semibold'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object gcButtonIcons: TDACGridContainer
          Left = 24
          Top = 508
          Width = 1128
          Height = 150
          Columns = 12
          ContentPadding = 16
          CornerRadius = 10
          Gutter = 10
          RowHeight = 46
          TabOrder = 2
          object btnIconLeft: TDACButton
            Left = 40
            Top = 524
            Width = 180
            Height = 46
            Caption = 'Icone esquerda'
            ShowIcon = True
            IconKind = mikSave
            Tag = 3
            TabOrder = 0
          end
          object btnIconRight: TDACButton
            Left = 230
            Top = 524
            Width = 180
            Height = 46
            Caption = 'Icone direita'
            Kind = mbkSecondary
            ShowIcon = True
            IconKind = mikChevronRight
            IconPosition = mipRight
            Tag = 3
            TabOrder = 1
          end
          object btnIconOnlyAdd: TDACButton
            Left = 420
            Top = 524
            Width = 84
            Height = 46
            Caption = ''
            ShowIcon = True
            IconKind = mikAdd
            Tag = 1
            TabOrder = 2
          end
          object btnIconOnlyMore: TDACButton
            Left = 514
            Top = 524
            Width = 84
            Height = 46
            Caption = ''
            Kind = mbkSecondary
            ShowIcon = True
            IconKind = mikMoreHorizontal
            Tag = 1
            TabOrder = 3
          end
          object btnIconCustomSize: TDACButton
            Left = 608
            Top = 524
            Width = 180
            Height = 46
            Caption = 'Icone 22'
            Kind = mbkGhost
            ShowIcon = True
            IconKind = mikTractor
            IconSize = 22
            Tag = 3
            TabOrder = 4
          end
          object btnIconDanger: TDACButton
            Left = 798
            Top = 524
            Width = 180
            Height = 46
            Caption = 'Excluir'
            Kind = mbkDanger
            ShowIcon = True
            IconKind = mikTrash
            Tag = 3
            TabOrder = 5
          end
        end
        object lblButtonStates: TLabel
          Left = 24
          Top = 682
          Width = 272
          Height = 17
          Caption = '4. Estados: normal, hover, foco, pressed, loading e disabled'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 985605
          Font.Height = -13
          Font.Name = 'Segoe UI Semibold'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object gcButtonStates: TDACGridContainer
          Left = 24
          Top = 706
          Width = 1128
          Height = 150
          Columns = 12
          ContentPadding = 16
          CornerRadius = 10
          Gutter = 10
          RowHeight = 46
          TabOrder = 3
          object btnStateNormal: TDACButton
            Left = 40
            Top = 722
            Width = 180
            Height = 46
            Caption = 'Normal'
            ShowIcon = True
            IconKind = mikCheck
            Tag = 3
            TabOrder = 0
          end
          object btnStateHover: TDACButton
            Left = 230
            Top = 722
            Width = 180
            Height = 46
            Caption = 'Passe o mouse'
            Kind = mbkSecondary
            ShowIcon = True
            IconKind = mikEye
            Tag = 3
            TabOrder = 1
          end
          object btnStateFocus: TDACButton
            Left = 420
            Top = 722
            Width = 180
            Height = 46
            Caption = 'Tab para foco'
            Kind = mbkGhost
            ShowIcon = True
            IconKind = mikCode
            Tag = 3
            TabOrder = 2
          end
          object btnStatePressed: TDACButton
            Left = 610
            Top = 722
            Width = 180
            Height = 46
            Caption = 'Pressione'
            ShowIcon = True
            IconKind = mikSettings
            Tag = 3
            TabOrder = 3
          end
          object btnStateLoading: TDACButton
            Left = 40
            Top = 778
            Width = 180
            Height = 46
            Caption = 'Carregando'
            Loading = True
            ShowIcon = True
            IconKind = mikSpinner
            Tag = 3
            TabOrder = 4
          end
          object btnStateDisabled: TDACButton
            Left = 230
            Top = 778
            Width = 180
            Height = 46
            Caption = 'Desabilitado'
            Enabled = False
            Kind = mbkSecondary
            ShowIcon = True
            IconKind = mikLock
            Tag = 3
            TabOrder = 5
          end
        end
        object lblButtonSpecials: TLabel
          Left = 24
          Top = 880
          Width = 238
          Height = 17
          Caption = '5. Cenarios compostos de botao'
          Font.Charset = DEFAULT_CHARSET
          Font.Color = 985605
          Font.Height = -13
          Font.Name = 'Segoe UI Semibold'
          Font.Style = [fsBold]
          ParentFont = False
        end
        object gcButtonSpecials: TDACGridContainer
          Left = 24
          Top = 904
          Width = 1128
          Height = 150
          Columns = 12
          ContentPadding = 16
          CornerRadius = 10
          Gutter = 10
          RowHeight = 46
          TabOrder = 4
          object btnSplitMain: TDACButton
            Left = 40
            Top = 920
            Width = 274
            Height = 46
            Caption = 'Split: executar acao'
            ShowIcon = True
            IconKind = mikSave
            Tag = 3
            TabOrder = 0
          end
          object btnSplitMenu: TDACButton
            Left = 324
            Top = 920
            Width = 84
            Height = 46
            Caption = ''
            ShowIcon = True
            IconKind = mikChevronDown
            Tag = 1
            TabOrder = 1
          end
          object btnSearchAction: TDACButton
            Left = 418
            Top = 920
            Width = 180
            Height = 46
            Caption = 'Buscar'
            Kind = mbkInputAction
            ShowIcon = True
            IconKind = mikSearch
            Tag = 2
            TabOrder = 2
          end
          object btnSaveAction: TDACButton
            Left = 608
            Top = 920
            Width = 180
            Height = 46
            Caption = 'Salvar'
            ShowIcon = True
            IconKind = mikSave
            Tag = 2
            TabOrder = 3
          end
          object btnDeleteAction: TDACButton
            Left = 798
            Top = 920
            Width = 180
            Height = 46
            Caption = 'Remover'
            Kind = mbkDanger
            ShowIcon = True
            IconKind = mikTrash
            Tag = 2
            TabOrder = 4
          end
          object btnUploadAction: TDACButton
            Left = 40
            Top = 976
            Width = 180
            Height = 46
            Caption = 'Enviar arquivo'
            Kind = mbkGhost
            ShowIcon = True
            IconKind = mikUpload
            Tag = 3
            TabOrder = 5
          end
        end
      end
    end
    object tsInputs: TTabSheet
      Caption = 'Inputs'
      ImageIndex = 1
      object lblInputs: TLabel
        Left = 24
        Top = 24
        Caption = 'Inputs nativos com chrome Skia, foco e teclado'
      end
      object demoEdit: TDACEdit
        Left = 24
        Top = 56
        Width = 280
        Height = 40
        Text = 'Texto editavel'
        TabOrder = 0
      end
      object demoButtonEdit: TDACButtonEdit
        Left = 320
        Top = 56
        Width = 280
        Height = 40
        TabOrder = 1
      end
      object demoMemo: TDACMemo
        Left = 24
        Top = 116
        Width = 576
        Height = 92
        Lines.Strings = (
          'Memo com selecao, clipboard e rolagem nativos.')
        TabOrder = 2
      end
    end
    object tsSelectors: TTabSheet
      Caption = 'Seletores'
      ImageIndex = 2
      object lblSelectors: TLabel
        Left = 24
        Top = 24
        Caption = 'Seletores e data/hora com interacao nativa'
      end
      object demoCombo: TDACComboBox
        Left = 24
        Top = 56
        Width = 220
        Height = 40
        Items.Strings = (
          'Opcao A'
          'Opcao B'
          'Opcao C')
        ItemIndex = 0
        TabOrder = 0
        Text = 'Opcao A'
      end
      object demoDateTime: TDACDateTimePicker
        Left = 264
        Top = 56
        Width = 220
        Height = 40
        TabOrder = 1
      end
    end
    object tsControls: TTabSheet
      Caption = 'Controles'
      ImageIndex = 3
      object lblControls: TLabel
        Left = 24
        Top = 24
        Caption = 'Escolhas: teclado, foco e estados disabled'
      end
      object demoCheck: TDACCheckBox
        Left = 24
        Top = 58
        Width = 180
        Height = 28
        Caption = 'Checkbox'
        TabOrder = 0
      end
      object demoRadio: TDACRadioButton
        Left = 220
        Top = 58
        Width = 180
        Height = 28
        Caption = 'Radio button'
        TabOrder = 1
      end
      object demoToggle: TDACToggleSwitch
        Left = 416
        Top = 56
        Width = 72
        Height = 32
        TabOrder = 2
      end
      object demoSlider: TDACSlider
        Left = 24
        Top = 108
        Width = 320
        Height = 36
        Position = 60
        TabOrder = 3
      end
    end
    object tsTabs: TTabSheet
      Caption = 'Tabs'
      ImageIndex = 4
      object lblTabs: TLabel
        Left = 24
        Top = 24
        Caption = 'Tabs nativas com header Skia e navegacao por teclado'
      end
      object demoTabs: TDACTabs
        Left = 24
        Top = 56
        Width = 560
        Height = 220
        ActiveIndex = 0
        TabOrder = 0
        object demoTabsFirst: TTabSheet
          Caption = 'Primeira'
        end
        object demoTabsSecond: TTabSheet
          Caption = 'Segunda'
        end
      end
    end
    object tsCards: TTabSheet
      Caption = 'Cards'
      ImageIndex = 5
      object lblCards: TLabel
        Left = 24
        Top = 24
        Caption = 'Card de resumo composto com tokens compartilhados'
      end
      object demoSummaryCard: TDACSummaryCard
        Left = 24
        Top = 56
        Width = 300
        Height = 140
        TabOrder = 0
      end
    end
    object tsGrid: TTabSheet
      Caption = 'Grid'
      ImageIndex = 6
      object lblGrid: TLabel
        Left = 24
        Top = 24
        Caption = 'Grid preserva TDBGrid, dataset, selecao e rolagem'
      end
      object demoDataGrid: TDACDataGrid
        Left = 24
        Top = 56
        Width = 860
        Height = 260
        TabOrder = 0
      end
    end
    object tsStatus: TTabSheet
      Caption = 'Status'
      ImageIndex = 7
      object lblStatus: TLabel
        Left = 24
        Top = 24
        Caption = 'Status bar e feedback de estado'
      end
      object demoStatusBar: TDACStatusBar
        Left = 24
        Top = 56
        Width = 720
        Height = 38
        TabOrder = 0
      end
    end
    object tsProgress: TTabSheet
      Caption = 'Progresso'
      ImageIndex = 8
      object lblProgress: TLabel
        Left = 24
        Top = 24
        Caption = 'Progresso linear e circular'
      end
      object demoProgress: TDACProgress
        Left = 24
        Top = 56
        Width = 320
        Height = 32
        Value = 65
        TabOrder = 0
      end
      object demoCircularProgress: TDACProgress
        Left = 370
        Top = 48
        Width = 84
        Height = 84
        Kind = mpkCircular
        Value = 65
        TabOrder = 1
      end
    end
    object tsPills: TTabSheet
      Caption = 'Pills'
      ImageIndex = 9
      object lblPills: TLabel
        Left = 24
        Top = 24
        Caption = 'Badge, chip, tag e pill'
      end
      object demoBadge: TDACBadge
        Left = 24
        Top = 56
        Width = 130
        Height = 32
        Caption = 'Badge'
        TabOrder = 0
      end
      object demoPill: TDACBadge
        Left = 170
        Top = 56
        Width = 130
        Height = 32
        Caption = 'Pill'
        Kind = mbkPill
        TabOrder = 1
      end
    end
    object tsFeedback: TTabSheet
      Caption = 'Feedback'
      ImageIndex = 10
      object lblFeedback: TLabel
        Left = 24
        Top = 24
        Caption = 'Toast, modal e tooltip com hover'
      end
      object demoToast: TDACToast
        Left = 24
        Top = 56
        Width = 300
        Height = 72
        TabOrder = 0
      end
      object btnTooltipTarget: TDACButton
        Left = 24
        Top = 158
        Width = 180
        Height = 42
        Caption = 'Passe o mouse'
        TabOrder = 1
      end
      object demoTooltip: TDACTooltip
        Left = 24
        Top = 206
        Width = 220
        Height = 36
        TargetControl = btnTooltipTarget
        Text = 'Tooltip declarativo com alvo'
        Visible = False
      end
    end
    object tsPagination: TTabSheet
      Caption = 'Paginacao'
      ImageIndex = 11
      object lblPagination: TLabel
        Left = 24
        Top = 24
        Caption = 'Paginacao com botoes e combo nativos'
      end
      object demoPagination: TDACPagination
        Left = 24
        Top = 56
        Width = 520
        Height = 42
        PageCount = 12
        PageIndex = 3
        TabOrder = 0
      end
    end
    object tsLoading: TTabSheet
      Caption = 'Loading'
      ImageIndex = 12
      object lblLoading: TLabel
        Left = 24
        Top = 24
        Caption = 'Loading, spinner, dots e skeleton'
      end
      object demoLoading: TDACLoading
        Left = 24
        Top = 56
        Width = 260
        Height = 60
        TabOrder = 0
      end
    end
    object tsCharts: TTabSheet
      Caption = 'Charts'
      ImageIndex = 13
      object lblCharts: TLabel
        Left = 24
        Top = 24
        Caption = 'Charts de barra, linha, area e donut'
      end
      object demoBarChart: TDACBarChart
        Left = 24
        Top = 56
        Width = 360
        Height = 230
        TabOrder = 0
      end
      object demoDoughnutChart: TDACDoughnutChart
        Left = 410
        Top = 56
        Width = 230
        Height = 230
        TabOrder = 1
      end
    end
    object tsReport: TTabSheet
      Caption = 'Report'
      ImageIndex = 14
      object lblReport: TLabel
        Left = 24
        Top = 24
        Caption = 'Report viewer com pagina e zoom'
      end
      object demoReportViewer: TDACReportViewer
        Left = 24
        Top = 56
        Width = 760
        Height = 340
        TabOrder = 0
      end
    end
  end
end
