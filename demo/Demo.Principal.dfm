object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'DAC Componentes - Demo'
  ClientHeight = 760
  ClientWidth = 1200
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
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
    ActivePageHeaderOnly = True
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
        Appearance = mscaViewport
        ScrollBarMode = msbmVertical
        TabOrder = 0
        object dashWelcomeTitle: TDACSystemText
          Left = 24
          Top = 24
          Width = 220
          Height = 40
          Bold = False
          Role = mtrDisplay
          Text = 'Bem-vindo,'
          Tone = mttPrimary
        end
        object dashWelcomeName: TDACSystemText
          Left = 252
          Top = 24
          Width = 500
          Height = 40
          Bold = False
          Role = mtrDisplay
          Text = 'Administrador'
          Tone = mttSuccess
        end
        object dashWelcomeSubtitle: TDACSystemText
          Left = 24
          Top = 66
          Width = 430
          Height = 24
          Bold = False
          Role = mtrSmall
          Text = 'Aqui esta o resumo da sua operacao hoje.'
          Tone = mttSecondary
        end
        object dashDateSummary: TDACContainer
          Left = 960
          Top = 24
          Width = 210
          Height = 72
          Appearance = mcaDarkPanel
          ShowHeader = False
          TabOrder = 1
          object dashDateValue: TDACSystemText
            Left = 20
            Top = 18
            Width = 160
            Height = 20
            Bold = True
            Role = mtrSmall
            Text = '24 de maio de 2025'
            Tone = mttPrimary
          end
          object dashDateWeekday: TDACSystemText
            Left = 20
            Top = 40
            Width = 160
            Height = 20
            Bold = False
            Role = mtrCaption
            Text = 'Sabado'
            Tone = mttSecondary
          end
        end
        object dashKpi1: TDACSummaryCard
          Left = 24
          Top = 96
          Width = 214
          Height = 108
          Appearance = mcsaDashboard
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
          Appearance = mcsaDashboard
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
          Appearance = mcsaDashboard
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
          Appearance = mcsaDashboard
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
          Appearance = mcsaDashboard
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
          Appearance = mcaDarkPanel
          Title = 'Acoes rapidas'
          TabOrder = 2
          object dashQuickActionsGrid: TDACGridContainer
            Left = 20
            Top = 62
            Width = 330
            Height = 142
            Align = alClient
            Columns = 2
            Appearance = mgcaTransparent
            Layout = mgclActionTiles
            TabOrder = 0
            object dashQuickAction1: TDACButton
              Left = 0
              Top = 0
              Width = 159
              Height = 70
              Caption = 'Nova ordem de servico'
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
          Appearance = mcaDarkPanel
          Title = 'Agenda'
          TabOrder = 3
          object dashAgendaLine1: TDACSystemText
            Left = 20
            Top = 70
            Width = 320
            Height = 32
            Role = mtrSmall
            Text = '24 MAI   Aplicacao de Herbicida   Hoje'
            Tone = mttPrimary
          end
          object dashAgendaTodayChip: TDACBadge
            Left = 280
            Top = 16
            Width = 66
            Height = 24
            Caption = 'HOJE'
            Appearance = mbaOutline
            TabOrder = 0
          end
          object dashAgendaLine2: TDACSystemText
            Left = 20
            Top = 110
            Width = 320
            Height = 32
            Role = mtrSmall
            Text = '25 MAI   Irrigacao - Talhao 08   Amanha'
            Tone = mttPrimary
          end
          object dashAgendaLine3: TDACSystemText
            Left = 20
            Top = 150
            Width = 320
            Height = 32
            Role = mtrSmall
            Text = '27 MAI   Manutencao de Equipamentos'
            Tone = mttPrimary
          end
          object dashAgendaFooter: TDACSystemText
            Left = 20
            Top = 190
            Width = 320
            Height = 24
            Bold = True
            Role = mtrSmall
            Text = 'Ver agenda completa  ->'
            Tone = mttAccent
          end
        end
        object dashRecentActivity: TDACContainer
          Left = 796
          Top = 228
          Width = 370
          Height = 224
          Appearance = mcaDarkPanel
          Title = 'Atividades recentes'
          TabOrder = 4
          object dashActivityLine1: TDACSystemText
            Left = 52
            Top = 70
            Width = 320
            Height = 32
            Role = mtrSmall
            Text = 'Entrada de 120 sacas de Sementes de Soja'
            Tone = mttPrimary
          end
          object dashActivityLine2: TDACSystemText
            Left = 52
            Top = 110
            Width = 320
            Height = 32
            Role = mtrSmall
            Text = 'Ordem de servico #OS-1456 concluida'
            Tone = mttPrimary
          end
          object dashActivityLine3: TDACSystemText
            Left = 52
            Top = 150
            Width = 320
            Height = 32
            Role = mtrSmall
            Text = 'Producao lancada: 320 t de Soja'
            Tone = mttPrimary
          end
          object dashActivityIcon1: TDACButton
            Left = 20
            Top = 70
            Width = 24
            Height = 24
            Caption = ''
            Kind = mbkTransparent
            ShowIcon = True
            IconKind = mikPackage
            IconSize = 16
            TabOrder = 0
          end
          object dashActivityIcon2: TDACButton
            Left = 20
            Top = 110
            Width = 24
            Height = 24
            Caption = ''
            Kind = mbkTransparent
            ShowIcon = True
            IconKind = mikTractor
            IconSize = 16
            TabOrder = 1
          end
          object dashActivityIcon3: TDACButton
            Left = 20
            Top = 150
            Width = 24
            Height = 24
            Caption = ''
            Kind = mbkTransparent
            ShowIcon = True
            IconKind = mikSoybean
            IconSize = 16
            TabOrder = 2
          end
          object dashActivityFooter: TDACSystemText
            Left = 20
            Top = 190
            Width = 320
            Height = 24
            Bold = True
            Role = mtrSmall
            Text = 'Ver todas as atividades  ->'
            Tone = mttAccent
          end
        end
        object dashProductivity: TDACContainer
          Left = 24
          Top = 476
          Width = 560
          Height = 270
          Appearance = mcaDarkPanel
          Title = 'Produtividade da safra'
          TabOrder = 5
          object dashProductivityChart: TDACChart
            Left = 20
            Top = 72
            Width = 520
            Height = 178
            Appearance = mchaDashboard
            DataMode = cdmManual
            Series = <
              item
                Name = 'Soja 2024/25'
                ChartType = ctBar
                FillMode = cfLinearGradient
                GradientAngle = 90.000000000000000000
                Points = <
                  item
                    Category = 'Jan'
                    Value = 42.000000000000000000
                  end
                  item
                    Category = 'Fev'
                    Value = 68.000000000000000000
                  end
                  item
                    Category = 'Mar'
                    Value = 57.000000000000000000
                  end
                  item
                    Category = 'Abr'
                    Value = 75.000000000000000000
                  end>
              end>
            TabOrder = 0
          end
          object dashProductivitySelect: TDACButton
            Left = 390
            Top = 16
            Width = 150
            Height = 32
            Caption = 'Soja 2024/25'
            Kind = mbkGhost
            ShowIcon = True
            IconKind = mikChevronDown
            IconPosition = mipRight
            TabOrder = 1
          end
        end
        object dashModules: TDACContainer
          Left = 600
          Top = 476
          Width = 566
          Height = 270
          Appearance = mcaDarkPanel
          Title = 'Modulos'
          TabOrder = 6
          object dashModule1: TDACContainer
            Left = 20
            Top = 56
            Width = 125
            Height = 172
            Appearance = mcaDarkCard
            ShowHeader = False
            TabOrder = 0
            object dashModule1Text: TDACSystemText
              Left = 20
              Top = 52
              Width = 100
              Height = 32
              Bold = True
              Role = mtrBody
              Text = 'Producao'
              Tone = mttPrimary
            end
            object dashModule1Icon: TDACButton
              Left = 16
              Top = 16
              Width = 32
              Height = 32
              Caption = ''
              Kind = mbkTransparent
              ShowIcon = True
              IconKind = mikSoybean
              IconSize = 20
              TabOrder = 0
            end
          end
          object dashModule2: TDACContainer
            Left = 157
            Top = 56
            Width = 125
            Height = 172
            Appearance = mcaDarkCard
            ShowHeader = False
            TabOrder = 1
            object dashModule2Text: TDACSystemText
              Left = 20
              Top = 52
              Width = 100
              Height = 32
              Bold = True
              Role = mtrBody
              Text = 'Estoque'
              Tone = mttPrimary
            end
            object dashModule2Icon: TDACButton
              Left = 16
              Top = 16
              Width = 32
              Height = 32
              Caption = ''
              Kind = mbkTransparent
              ShowIcon = True
              IconKind = mikInventoryStack
              IconSize = 20
              TabOrder = 0
            end
          end
          object dashModule3: TDACContainer
            Left = 294
            Top = 56
            Width = 125
            Height = 172
            Appearance = mcaDarkCard
            ShowHeader = False
            TabOrder = 2
            object dashModule3Text: TDACSystemText
              Left = 20
              Top = 52
              Width = 100
              Height = 32
              Bold = True
              Role = mtrBody
              Text = 'Financeiro'
              Tone = mttPrimary
            end
            object dashModule3Icon: TDACButton
              Left = 16
              Top = 16
              Width = 32
              Height = 32
              Caption = ''
              Kind = mbkTransparent
              ShowIcon = True
              IconKind = mikMoneyCircle
              IconSize = 20
              TabOrder = 0
            end
          end
          object dashModule4: TDACContainer
            Left = 431
            Top = 56
            Width = 125
            Height = 172
            Appearance = mcaDarkCard
            ShowHeader = False
            TabOrder = 3
            object dashModule4Text: TDACSystemText
              Left = 20
              Top = 52
              Width = 100
              Height = 32
              Bold = True
              Role = mtrBody
              Text = 'Relatorios'
              Tone = mttPrimary
            end
            object dashModule4Icon: TDACButton
              Left = 16
              Top = 16
              Width = 32
              Height = 32
              Caption = ''
              Kind = mbkTransparent
              ShowIcon = True
              IconKind = mikReport
              IconSize = 20
              TabOrder = 0
            end
          end
        end
        object dashStatus: TDACContainer
          Left = 24
          Top = 770
          Width = 1142
          Height = 56
          Appearance = mcaDarkPanel
          ShowHeader = False
          TabOrder = 7
          object dashStatusConnection: TDACSystemText
            Left = 20
            Top = 18
            Width = 130
            Height = 20
            Bold = True
            Role = mtrCaption
            Text = 'Conectado'
            Tone = mttSuccess
          end
          object dashStatusFarm: TDACSystemText
            Left = 480
            Top = 18
            Width = 180
            Height = 20
            Role = mtrCaption
            Text = 'Fazenda Boa Vista'
            Tone = mttPrimary
          end
          object dashStatusSeason: TDACSystemText
            Left = 960
            Top = 18
            Width = 150
            Height = 20
            Role = mtrCaption
            Text = 'Safra 2024/25'
            Tone = mttSecondary
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
        Appearance = mscaViewport
        ScrollBarMode = msbmVertical
        TabOrder = 0
        object lblButtonsTitle: TDACSystemText
          Left = 24
          Top = 22
          Width = 193
          Height = 25
          Bold = True
          Role = mtrBody
          Text = 'Botoes DACComponentes'
        end
        object lblButtonsSubtitle: TDACSystemText
          Left = 24
          Top = 53
          Width = 857
          Height = 15
          MaxLines = 4
          Role = mtrSmall
          Text = 'Cenarios declarativos como no designer: Kind, Size, IconKind, IconPosition, Loading, Enabled, TabStop, CornerRadius e variacoes de acao.'
          Tone = mttSecondary
        end
        object lblButtonKinds: TDACSystemText
          Left = 24
          Top = 92
          Width = 150
          Height = 17
          Bold = True
          Role = mtrBody
          Text = '1. Variantes de Kind'
        end
        object gcButtonKinds: TDACGridContainer
          Left = 24
          Top = 116
          Width = 1128
          Height = 148
          Columns = 12
          Layout = mgclDense
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
        object lblButtonSizes: TDACSystemText
          Left = 24
          Top = 288
          Width = 230
          Height = 17
          Bold = True
          Role = mtrBody
          Text = '2. Tamanhos, raio e foco por teclado'
        end
        object gcButtonSizes: TDACGridContainer
          Left = 24
          Top = 312
          Width = 1128
          Height = 148
          Columns = 12
          Layout = mgclCompact
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
            Shape = mbshCompact
            Tag = 3
            TabOrder = 3
          end
          object btnRadiusPill: TDACButton
            Left = 40
            Top = 384
            Width = 180
            Height = 46
            Caption = 'Raio pill'
            Shape = mbshRounded
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
        object lblButtonIcons: TDACSystemText
          Left = 24
          Top = 484
          Width = 218
          Height = 17
          Bold = True
          Role = mtrBody
          Text = '3. Icones, posicao e icon-only'
        end
        object gcButtonIcons: TDACGridContainer
          Left = 24
          Top = 508
          Width = 1128
          Height = 150
          Columns = 12
          Layout = mgclCompact
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
        object lblButtonStates: TDACSystemText
          Left = 24
          Top = 682
          Width = 272
          Height = 17
          Bold = True
          Role = mtrBody
          Text = '4. Estados: normal, hover, foco, pressed, loading e disabled'
        end
        object gcButtonStates: TDACGridContainer
          Left = 24
          Top = 706
          Width = 1128
          Height = 150
          Columns = 12
          Layout = mgclCompact
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
        object lblButtonSpecials: TDACSystemText
          Left = 24
          Top = 880
          Width = 238
          Height = 17
          Bold = True
          Role = mtrBody
          Text = '5. Cenarios compostos de botao'
        end
        object gcButtonSpecials: TDACGridContainer
          Left = 24
          Top = 904
          Width = 1128
          Height = 150
          Columns = 12
          Appearance = mgcaViewport
          Layout = mgclCompact
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
      object scrInputs: TDACScrollContainer
        Left = 0
        Top = 0
        Width = 1192
        Height = 708
        Align = alClient
        AutoScroll = True
        BorderStyle = bsNone
        Appearance = mscaViewport
        ScrollBarMode = msbmVertical
        TabOrder = 0
        object gcInputStates: TDACGridContainer
          AlignWithMargins = True
          Left = 16
          Top = 16
          Width = 1144
          Height = 1140
          Margins.Left = 16
          Margins.Top = 16
          Margins.Right = 16
          Margins.Bottom = 16
          Align = alTop
          AutoContentHeight = True
          Appearance = mgcaTransparent
          Columns = 7
          MinimumColumnWidth = 180
          SizeRowsToContent = True
          TabOrder = 0
          object lblInputs: TDACSystemText
            Left = 12
            Top = 12
            Width = 1120
            Height = 30
            Bold = True
            Role = mtrBody
            Tag = 12
            Text = 'Input e Memo - estados declarativos (hover/foco por interacao real)'
          end
          object lblInputEditStates: TDACSystemText
            Left = 12
            Top = 54
            Width = 1120
            Height = 22
            Bold = True
            Role = mtrBody
            Tag = 12
            Text = 'Edit'
          end
          object demoEdit: TDACEdit
            Left = 12
            Top = 88
            Width = 300
            Height = 64
            Constraints.MinWidth = 180
            LabelText = 'Input / Default'
            Placeholder = 'Digite...'
            TabOrder = 0
          end
          object demoEditFilled: TDACEdit
            Left = 324
            Top = 88
            Width = 300
            Height = 64
            Constraints.MinWidth = 180
            LabelText = 'Input / Filled'
            Text = 'Valor preenchido'
            TabOrder = 1
          end
          object demoEditError: TDACEdit
            Left = 636
            Top = 88
            Width = 300
            Height = 88
            Constraints.MinWidth = 180
            ErrorText = 'Mensagem de erro'
            LabelText = 'Input / Error'
            Status = mesDanger
            Text = 'Valor invalido'
            TabOrder = 2
          end
          object demoEditSuccess: TDACEdit
            Left = 12
            Top = 188
            Width = 300
            Height = 88
            Constraints.MinWidth = 180
            HelperText = 'Mensagem de sucesso'
            LabelText = 'Input / Success'
            Status = mesSuccess
            Text = 'Valor valido'
            TabOrder = 3
          end
          object demoEditDisabled: TDACEdit
            Left = 324
            Top = 188
            Width = 300
            Height = 64
            Constraints.MinWidth = 180
            Enabled = False
            LabelText = 'Input / Disabled'
            Text = 'Desabilitado'
            TabOrder = 4
          end
          object demoEditReadOnly: TDACEdit
            Left = 636
            Top = 188
            Width = 300
            Height = 64
            Constraints.MinWidth = 180
            LabelText = 'Input / ReadOnly'
            ReadOnly = True
            Text = 'Somente leitura'
            TabOrder = 5
          end
          object demoEditLoading: TDACEdit
            Left = 12
            Top = 288
            Width = 300
            Height = 64
            Constraints.MinWidth = 180
            LabelText = 'Input / Loading'
            Loading = True
            Text = 'Carregando...'
            TabOrder = 6
          end
          object lblInputMemoStates: TDACSystemText
            Left = 12
            Top = 364
            Width = 1120
            Height = 22
            Bold = True
            Role = mtrBody
            Tag = 12
            Text = 'Memo'
          end
          object demoMemo: TDACMemo
            Left = 12
            Top = 398
            Width = 300
            Height = 112
            Constraints.MinWidth = 180
            LabelText = 'Memo / Default'
            TabOrder = 7
          end
          object demoMemoFilled: TDACMemo
            Left = 324
            Top = 398
            Width = 300
            Height = 112
            Constraints.MinWidth = 180
            LabelText = 'Memo / Filled'
            Lines.Strings = (
              'Memo com selecao, clipboard e rolagem nativos.')
            TabOrder = 8
          end
          object demoMemoError: TDACMemo
            Left = 636
            Top = 398
            Width = 300
            Height = 136
            Constraints.MinWidth = 180
            ErrorText = 'Mensagem de erro'
            LabelText = 'Memo / Error'
            Lines.Strings = (
              'Valor invalido')
            Status = mesDanger
            TabOrder = 9
          end
          object demoMemoSuccess: TDACMemo
            Left = 12
            Top = 546
            Width = 300
            Height = 136
            Constraints.MinWidth = 180
            HelperText = 'Mensagem de sucesso'
            LabelText = 'Memo / Success'
            Lines.Strings = (
              'Valor valido')
            Status = mesSuccess
            TabOrder = 10
          end
          object demoMemoDisabled: TDACMemo
            Left = 324
            Top = 546
            Width = 300
            Height = 112
            Constraints.MinWidth = 180
            Enabled = False
            LabelText = 'Memo / Disabled'
            Lines.Strings = (
              'Desabilitado')
            TabOrder = 11
          end
          object demoMemoReadOnly: TDACMemo
            Left = 636
            Top = 546
            Width = 300
            Height = 112
            Constraints.MinWidth = 180
            LabelText = 'Memo / ReadOnly'
            Lines.Strings = (
              'Somente leitura')
            ReadOnly = True
            TabOrder = 12
          end
          object demoMemoLoading: TDACMemo
            Left = 12
            Top = 694
            Width = 300
            Height = 112
            Constraints.MinWidth = 180
            LabelText = 'Memo / Loading'
            Lines.Strings = (
              'Carregando...')
            Loading = True
            TabOrder = 13
          end
          object lblInputButtonEditStates: TDACSystemText
            Left = 12
            Top = 818
            Width = 1120
            Height = 22
            Bold = True
            Role = mtrBody
            Tag = 12
            Text = 'ButtonEdit'
          end
          object demoButtonEdit: TDACButtonEdit
            Left = 12
            Top = 852
            Width = 300
            Height = 64
            Constraints.MinWidth = 180
            LabelText = 'ButtonEdit / Default'
            Placeholder = 'Pesquisar...'
            TabOrder = 14
          end
          object demoButtonEditFilled: TDACButtonEdit
            Left = 324
            Top = 852
            Width = 300
            Height = 64
            Constraints.MinWidth = 180
            LabelText = 'ButtonEdit / Filled'
            Text = 'Valor'
            TabOrder = 15
          end
          object demoButtonEditError: TDACButtonEdit
            Left = 636
            Top = 852
            Width = 300
            Height = 88
            Constraints.MinWidth = 180
            ErrorText = 'Mensagem de erro'
            LabelText = 'ButtonEdit / Error'
            Status = mesDanger
            Text = 'Invalido'
            TabOrder = 16
          end
          object demoButtonEditSuccess: TDACButtonEdit
            Left = 12
            Top = 952
            Width = 300
            Height = 88
            Constraints.MinWidth = 180
            HelperText = 'Mensagem de sucesso'
            LabelText = 'ButtonEdit / Success'
            Status = mesSuccess
            Text = 'Valido'
            TabOrder = 17
          end
          object demoButtonEditDisabled: TDACButtonEdit
            Left = 324
            Top = 952
            Width = 300
            Height = 64
            Constraints.MinWidth = 180
            Enabled = False
            LabelText = 'ButtonEdit / Disabled'
            Text = 'Desabilitado'
            TabOrder = 18
          end
          object demoButtonEditReadOnly: TDACButtonEdit
            Left = 636
            Top = 952
            Width = 300
            Height = 64
            Constraints.MinWidth = 180
            LabelText = 'ButtonEdit / ReadOnly'
            ReadOnly = True
            Text = 'Somente leitura'
            TabOrder = 19
          end
          object demoButtonEditLoading: TDACButtonEdit
            Left = 12
            Top = 1052
            Width = 300
            Height = 64
            Constraints.MinWidth = 180
            LabelText = 'ButtonEdit / Loading'
            Loading = True
            Text = 'Carregando...'
            TabOrder = 20
          end
        end
      end
    end
    object tsSelectors: TTabSheet
      Caption = 'Seletores'
      ImageIndex = 2
      object lblSelectors: TLabel
        Left = 24
        Top = 24
        Caption = 'ComboBox e DateTimePicker - estados declarativos'
      end
      object demoCombo: TDACComboBox
        Left = 24
        Top = 88
        Width = 196
        Height = 64
        LabelText = 'Combo / Default'
        Items.Strings = (
          'Opcao A'
          'Opcao B'
          'Opcao C')
        TabOrder = 0
      end
      object demoComboFilled: TDACComboBox
        Left = 236
        Top = 88
        Width = 196
        Height = 64
        Items.Strings = (
          'Opcao A'
          'Opcao B'
          'Opcao C')
        ItemIndex = 0
        LabelText = 'Combo / Filled'
        TabOrder = 1
        Text = 'Opcao A'
      end
      object demoComboError: TDACComboBox
        Left = 24
        Top = 184
        Width = 196
        Height = 88
        ErrorText = 'Mensagem de erro'
        Items.Strings = (
          'Opcao A'
          'Opcao B')
        LabelText = 'Combo / Error'
        Status = mesDanger
        TabOrder = 2
      end
      object demoComboSuccess: TDACComboBox
        Left = 236
        Top = 184
        Width = 196
        Height = 88
        HelperText = 'Mensagem de sucesso'
        Items.Strings = (
          'Opcao A'
          'Opcao B')
        ItemIndex = 0
        LabelText = 'Combo / Success'
        Status = mesSuccess
        TabOrder = 3
        Text = 'Opcao A'
      end
      object demoComboDisabled: TDACComboBox
        Left = 24
        Top = 288
        Width = 196
        Height = 64
        Enabled = False
        LabelText = 'Combo / Disabled'
        TabOrder = 4
      end
      object demoComboReadOnly: TDACComboBox
        Left = 236
        Top = 288
        Width = 196
        Height = 64
        Items.Strings = (
          'Opcao A')
        ItemIndex = 0
        LabelText = 'Combo / ReadOnly'
        ReadOnly = True
        TabOrder = 5
        Text = 'Opcao A'
      end
      object demoComboLoading: TDACComboBox
        Left = 24
        Top = 384
        Width = 196
        Height = 64
        LabelText = 'Combo / Loading'
        Loading = True
        TabOrder = 6
        Text = 'Carregando...'
      end
      object demoDateTime: TDACDateTimePicker
        Left = 520
        Top = 88
        Width = 220
        Height = 64
        LabelText = 'Date / Default'
        TabOrder = 7
      end
      object demoDateTimeFilled: TDACDateTimePicker
        Left = 756
        Top = 88
        Width = 220
        Height = 64
        DateTime = 46067.625000000000000000
        LabelText = 'Date / Filled'
        TabOrder = 8
      end
      object demoDateTimeError: TDACDateTimePicker
        Left = 520
        Top = 184
        Width = 220
        Height = 88
        ErrorText = 'Mensagem de erro'
        LabelText = 'Date / Error'
        Status = mesDanger
        TabOrder = 9
      end
      object demoDateTimeSuccess: TDACDateTimePicker
        Left = 756
        Top = 184
        Width = 220
        Height = 88
        HelperText = 'Mensagem de sucesso'
        LabelText = 'Date / Success'
        Status = mesSuccess
        TabOrder = 10
      end
      object demoDateTimeDisabled: TDACDateTimePicker
        Left = 520
        Top = 288
        Width = 220
        Height = 64
        Enabled = False
        LabelText = 'Date / Disabled'
        TabOrder = 11
      end
      object demoDateTimeReadOnly: TDACDateTimePicker
        Left = 756
        Top = 288
        Width = 220
        Height = 64
        LabelText = 'Date / ReadOnly'
        ReadOnly = True
        TabOrder = 12
      end
      object demoDateTimeLoading: TDACDateTimePicker
        Left = 520
        Top = 384
        Width = 220
        Height = 64
        LabelText = 'Date / Loading'
        Loading = True
        TabOrder = 13
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
        Height = 260
        ActiveIndex = 0
        TabOrder = 0
        object demoTabsFirst: TTabSheet
          Caption = 'Geral'
          object demoTabsFirstText: TDACSystemText
            Left = 20
            Top = 20
            Width = 400
            Height = 52
            Role = mtrBody
            MaxLines = 2
            Text = 'Geral: foco, acoes e dados.'
          end
        end
        object demoTabsSecond: TTabSheet
          Caption = 'Detalhes'
          object demoTabsSecondText: TDACSystemText
            Left = 20
            Top = 20
            Width = 400
            Height = 52
            Role = mtrBody
            MaxLines = 2
            Text = 'Detalhes: painel independente.'
          end
        end
        object demoTabsThird: TTabSheet
          Caption = 'Historico'
          Enabled = False
          object demoTabsThirdText: TDACSystemText
            Left = 20
            Top = 20
            Width = 400
            Height = 52
            Role = mtrBody
            MaxLines = 2
            Text = 'Historico: estado desabilitado.'
          end
        end
      end
      object demoVerticalTabs: TDACTabs
        Left = 608
        Top = 56
        Width = 400
        Height = 260
        ActiveIndex = 0
        Orientation = mtoVertical
        TabOrder = 1
        object demoVerticalTabsFirst: TTabSheet
          Caption = 'Geral'
          object demoVerticalTabsFirstText: TDACSystemText
            Left = 20
            Top = 20
            Width = 190
            Height = 52
            Role = mtrBody
            MaxLines = 2
            Text = 'Geral: painel ativo.'
          end
        end
        object demoVerticalTabsSecond: TTabSheet
          Caption = 'Detalhes'
          object demoVerticalTabsSecondText: TDACSystemText
            Left = 20
            Top = 20
            Width = 190
            Height = 52
            Role = mtrBody
            MaxLines = 2
            Text = 'Detalhes: selecionavel.'
          end
        end
        object demoVerticalTabsThird: TTabSheet
          Caption = 'Historico'
          object demoVerticalTabsThirdText: TDACSystemText
            Left = 20
            Top = 20
            Width = 190
            Height = 52
            Role = mtrBody
            MaxLines = 2
            Text = 'Historico: conteudo proprio.'
          end
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
      object demoModal: TDACModalDialog
        Left = 350
        Top = 56
        Width = 320
        Height = 180
        MessageText = 'Modal declarativo demonstrando foco e fechamento com Escape.'
        TabOrder = 1
        TitleText = 'Confirmacao DAC'
      end
      object btnTooltipTarget: TDACButton
        Left = 24
        Top = 158
        Width = 180
        Height = 42
        Caption = 'Passe o mouse'
        TabOrder = 2
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
      object demoBarChart: TDACChart
        Left = 24
        Top = 56
        Width = 360
        Height = 180
        DataMode = cdmManual
        Title.Visible = True
        Title.Text = 'Manual: barras e linha'
        Series = <
          item
            Name = 'Producao'
            ChartType = ctBar
            FillMode = cfLinearGradient
            Points = <
              item Category = 'Jan' Value = 20.000000000000000000 end
              item Category = 'Fev' Value = 35.000000000000000000 end
              item Category = 'Mar' Value = 27.000000000000000000 end
              item Category = 'Abr' Value = 46.000000000000000000 end>
          end
          item
            Name = 'Meta'
            ChartType = ctLine
            FillMode = cfSolid
            Points = <
              item Category = 'Jan' Value = 28.000000000000000000 end
              item Category = 'Fev' Value = 30.000000000000000000 end
              item Category = 'Mar' Value = 33.000000000000000000 end
              item Category = 'Abr' Value = 39.000000000000000000 end>
          end>
        TabOrder = 0
      end
      object demoDoughnutChart: TDACChart
        Left = 410
        Top = 56
        Width = 230
        Height = 180
        ChartType = ctDoughnut
        DataMode = cdmManual
        Series = <
          item
            Name = 'Culturas'
            ChartType = ctDoughnut
            FillMode = cfRadialGradient
            Points = <
              item Category = 'Soja' Value = 55.000000000000000000 end
              item Category = 'Milho' Value = 30.000000000000000000 end
              item Category = 'Feijao' Value = 15.000000000000000000 end>
          end>
        TabOrder = 1
      end
      object demoLineChart: TDACChart
        Left = 24
        Top = 260
        Width = 360
        Height = 180
        ChartType = ctLine
        DataMode = cdmManual
        Series = <
          item
            Name = 'Umidade'
            ChartType = ctLine
            Points = <
              item Category = 'Jan' Value = 16.000000000000000000 end
              item Category = 'Fev' Value = 22.000000000000000000 end
              item Category = 'Mar' IsNull = True end
              item Category = 'Abr' Value = 18.000000000000000000 end>
          end>
        TabOrder = 2
      end
      object demoAreaChart: TDACChart
        Left = 410
        Top = 260
        Width = 360
        Height = 180
        ChartType = ctArea
        DataMode = cdmManual
        Series = <
          item
            Name = 'Precipitacao'
            ChartType = ctArea
            FillMode = cfLinearGradient
            GradientAngle = 0.000000000000000000
            Points = <
              item Category = 'Jan' Value = 12.000000000000000000 end
              item Category = 'Fev' Value = 30.000000000000000000 end
              item Category = 'Mar' Value = 24.000000000000000000 end
              item Category = 'Abr' Value = 40.000000000000000000 end>
          end>
        TabOrder = 3
      end
      object demoStatusTimeline: TDACStatusTimelineChart
        Left = 24
        Top = 464
        Width = 746
        Height = 180
        CurrentState = stsOnline
        EmptyText = 'Sem dados de status no periodo'
        TabOrder = 4
        WindowFinish = 45870.666666666660000000
        WindowStart = 45869.666666666660000000
        Segments = <
          item
            StartAt = 45869.666666666660000000
            FinishAt = 45870.020833333340000000
            State = stsOnline
          end
          item
            StartAt = 45870.020833333340000000
            FinishAt = 45870.083333333340000000
            State = stsOffline
          end
          item
            StartAt = 45870.083333333340000000
            FinishAt = 45870.416666666660000000
            State = stsOnline
          end
          item
            StartAt = 45870.416666666660000000
            FinishAt = 45870.458333333340000000
            State = stsUnstable
          end
          item
            StartAt = 45870.458333333340000000
            FinishAt = 45870.666666666660000000
            State = stsOnline
          end>
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
