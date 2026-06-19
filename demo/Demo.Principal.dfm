object Form1: TForm1
  Left = 0
  Top = 0
  Caption = 'Demo'
  ClientHeight = 860
  ClientWidth = 1280
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  PixelsPerInch = 96
  TextHeight = 13
  object DemoTabs: TDACTabs
    Left = 0
    Top = 0
    Width = 1280
    Height = 860
    ActiveIndex = 0
    Align = alClient
    Anchors = [akLeft, akTop, akRight, akBottom]
    ShowContentBorder = False
    Items = <
      item
        Caption = 'Botoes'
      end
      item
        Caption = 'Inputs'
      end
      item
        Caption = 'Seletores'
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
        Caption = 'Graficos'
      end
      item
        Caption = 'Report'
      end>
    object TabBotoes: TDACScrollContainer
      Left = 0
      Top = 0
      Width = 1280
      Height = 860
      Align = alClient
      Anchors = [akLeft, akTop, akRight, akBottom]
      AutoScroll = True
      BackgroundColor = $00000000
      BorderColor = $00000000
      BorderStyle = bsNone
      CornerRadius = 0
      ScrollBarMode = msbmAuto
      object GridBotoes: TDACGridContainer
        Left = 0
        Top = 0
        Width = 1248
        Height = 840
        Align = alTop
        Anchors = [akLeft, akTop, akRight]
        AutoLayout = True
        BackgroundColor = $00000000
        BorderColor = $00000000
        Columns = 12
        ContentPadding = 16
        CornerRadius = 0
        Gutter = 16
        RowHeight = 84
        object LblButtonsHeader: TLabel
          AutoSize = False
          Caption = 'DEMO: TDACButton'
          Tag = 12
          Font.Size = 12
          Font.Style = [fsBold]
          Layout = tlTop
          Margins.Left = 4
          Margins.Top = 4
          Margins.Bottom = 4
          WordWrap = True
        end
        object LblButtonsSub: TLabel
          AutoSize = False
          Caption = 'Estados e configuracoes possiveis do botao da biblioteca.'
          Tag = 12
          Font.Style = [fsItalic]
          Layout = tlTop
          Margins.Left = 4
          Margins.Top = 4
          Margins.Bottom = 4
          WordWrap = True
        end
        object LblButtonsPrimary: TLabel
          AutoSize = False
          Caption = 'Kind: mbkPrimary'
          Tag = 12
          Font.Style = [fsBold]
          Layout = tlTop
          Margins.Left = 4
          Margins.Top = 4
          WordWrap = True
        end
        object BtnPrimaryTextSmall: TDACButton
          Caption = 'Texto so'
          Kind = mbkPrimary
          Size = mbsSmall
          Tag = 4
        end
        object BtnPrimaryIconLeft: TDACButton
          Caption = 'Texto + icone esquerda'
          Kind = mbkPrimary
          Size = mbsSmall
          ShowIcon = True
          IconPosition = mipLeft
          IconKind = mikCheck
          Tag = 4
        end
        object BtnPrimaryIconRight: TDACButton
          Caption = 'Texto + icone direita'
          Kind = mbkPrimary
          Size = mbsSmall
          ShowIcon = True
          IconPosition = mipRight
          IconKind = mikArrowRight
          Tag = 4
        end
        object BtnPrimaryIconOnly: TDACButton
          Caption = 'Apenas icone'
          Kind = mbkPrimary
          Size = mbsSmall
          ShowIcon = True
          IconKind = mikInfoCircle
          IconSize = 20
          Tag = 4
        end
        object BtnPrimaryLoading: TDACButton
          Caption = 'Loading'
          Kind = mbkPrimary
          Size = mbsMedium
          Loading = True
          ShowIcon = True
          IconKind = mikSpinner
          Tag = 4
        end
        object BtnPrimaryDisabled: TDACButton
          Caption = 'Disabled'
          Kind = mbkPrimary
          Enabled = False
          Tag = 4
        end
        object BtnPrimaryDisabledLoading: TDACButton
          Caption = 'Disabled + Loading'
          Kind = mbkPrimary
          Enabled = False
          Loading = True
          ShowIcon = True
          IconKind = mikSpinner
          Tag = 4
        end
        object BtnPrimaryRadius0: TDACButton
          Caption = 'Radius 0'
          Kind = mbkPrimary
          CornerRadius = 0
          ShowIcon = True
          IconKind = mikEdit
          Tag = 4
        end
        object BtnPrimaryRadius24: TDACButton
          Caption = 'Radius 24'
          Kind = mbkPrimary
          CornerRadius = 24
          ShowIcon = True
          IconKind = mikSearch
          Tag = 4
        end
        object BtnPrimaryTabStopFalse: TDACButton
          Caption = 'TabStop = False'
          Kind = mbkPrimary
          Size = mbsMedium
          TabStop = False
          ShowIcon = True
          IconKind = mikUser
          Tag = 12
        end
        object LblButtonsSecondary: TLabel
          AutoSize = False
          Caption = 'Kind: mbkSecondary'
          Tag = 12
          Font.Style = [fsBold]
          Layout = tlTop
          Margins.Left = 4
          Margins.Top = 4
          WordWrap = True
        end
        object BtnSecondaryTextSmall: TDACButton
          Caption = 'Texto so'
          Kind = mbkSecondary
          Size = mbsSmall
          Tag = 4
        end
        object BtnSecondaryIconLeft: TDACButton
          Caption = 'Texto + icone esquerda'
          Kind = mbkSecondary
          Size = mbsSmall
          ShowIcon = True
          IconPosition = mipLeft
          IconKind = mikDownload
          Tag = 4
        end
        object BtnSecondaryIconRight: TDACButton
          Caption = 'Texto + icone direita'
          Kind = mbkSecondary
          Size = mbsSmall
          ShowIcon = True
          IconPosition = mipRight
          IconKind = mikUpload
          Tag = 4
        end
        object BtnSecondaryIconOnly: TDACButton
          Caption = 'Apenas icone'
          Kind = mbkSecondary
          Size = mbsMedium
          ShowIcon = True
          IconKind = mikCopy
          IconSize = 20
          Tag = 4
        end
        object BtnSecondaryLoading: TDACButton
          Caption = 'Loading'
          Kind = mbkSecondary
          Size = mbsLarge
          Loading = True
          ShowIcon = True
          IconKind = mikSpinner
          Tag = 4
        end
        object BtnSecondaryDisabled: TDACButton
          Caption = 'Disabled'
          Kind = mbkSecondary
          Enabled = False
          Tag = 4
        end
        object BtnSecondaryDisabledLoading: TDACButton
          Caption = 'Disabled + Loading'
          Kind = mbkSecondary
          Enabled = False
          Loading = True
          ShowIcon = True
          IconKind = mikSpinner
          Tag = 4
        end
        object BtnSecondaryRadius0: TDACButton
          Caption = 'Radius 0'
          Kind = mbkSecondary
          CornerRadius = 0
          ShowIcon = True
          IconKind = mikSave
          Tag = 4
        end
        object BtnSecondaryRadius24: TDACButton
          Caption = 'Radius 24'
          Kind = mbkSecondary
          CornerRadius = 24
          ShowIcon = True
          IconKind = mikTrash
          Tag = 4
        end
        object BtnSecondaryTabStopFalse: TDACButton
          Caption = 'TabStop = False'
          Kind = mbkSecondary
          Size = mbsMedium
          TabStop = False
          ShowIcon = True
          IconKind = mikExternalLink
          Tag = 12
        end
        object LblButtonsGhost: TLabel
          AutoSize = False
          Caption = 'Kind: mbkGhost'
          Tag = 12
          Font.Style = [fsBold]
          Layout = tlTop
          Margins.Left = 4
          Margins.Top = 4
          WordWrap = True
        end
        object BtnGhostTextSmall: TDACButton
          Caption = 'Texto so'
          Kind = mbkGhost
          Size = mbsSmall
          Tag = 4
        end
        object BtnGhostIconLeft: TDACButton
          Caption = 'Texto + icone esquerda'
          Kind = mbkGhost
          Size = mbsSmall
          ShowIcon = True
          IconPosition = mipLeft
          IconKind = mikBell
          Tag = 4
        end
        object BtnGhostIconRight: TDACButton
          Caption = 'Texto + icone direita'
          Kind = mbkGhost
          Size = mbsSmall
          ShowIcon = True
          IconPosition = mipRight
          IconKind = mikCode
          Tag = 4
        end
        object BtnGhostIconOnly: TDACButton
          Caption = 'Apenas icone'
          Kind = mbkGhost
          Size = mbsMedium
          ShowIcon = True
          IconKind = mikCalendar
          IconSize = 20
          Tag = 4
        end
        object BtnGhostLoading: TDACButton
          Caption = 'Loading'
          Kind = mbkGhost
          Size = mbsLarge
          Loading = True
          ShowIcon = True
          IconKind = mikSpinner
          Tag = 4
        end
        object BtnGhostDisabled: TDACButton
          Caption = 'Disabled'
          Kind = mbkGhost
          Enabled = False
          Tag = 4
        end
        object BtnGhostDisabledLoading: TDACButton
          Caption = 'Disabled + Loading'
          Kind = mbkGhost
          Enabled = False
          Loading = True
          ShowIcon = True
          IconKind = mikSpinner
          Tag = 4
        end
        object BtnGhostRadius0: TDACButton
          Caption = 'Radius 0'
          Kind = mbkGhost
          CornerRadius = 0
          ShowIcon = True
          IconKind = mikEdit
          Tag = 4
        end
        object BtnGhostRadius24: TDACButton
          Caption = 'Radius 24'
          Kind = mbkGhost
          CornerRadius = 24
          ShowIcon = True
          IconKind = mikHelpCircle
          Tag = 4
        end
        object BtnGhostTabStopFalse: TDACButton
          Caption = 'TabStop = False'
          Kind = mbkGhost
          Size = mbsMedium
          TabStop = False
          ShowIcon = True
          IconKind = mikInfoCircle
          Tag = 12
        end
        object LblButtonsWarning: TLabel
          AutoSize = False
          Caption = 'Kind: mbkWarning'
          Tag = 12
          Font.Style = [fsBold]
          Layout = tlTop
          Margins.Left = 4
          Margins.Top = 4
          WordWrap = True
        end
        object BtnWarningTextSmall: TDACButton
          Caption = 'Texto so'
          Kind = mbkWarning
          Size = mbsSmall
          Tag = 4
        end
        object BtnWarningIconLeft: TDACButton
          Caption = 'Texto + icone esquerda'
          Kind = mbkWarning
          Size = mbsSmall
          ShowIcon = True
          IconPosition = mipLeft
          IconKind = mikWarning
          Tag = 4
        end
        object BtnWarningIconRight: TDACButton
          Caption = 'Texto + icone direita'
          Kind = mbkWarning
          Size = mbsSmall
          ShowIcon = True
          IconPosition = mipRight
          IconKind = mikWarning
          Tag = 4
        end
        object BtnWarningIconOnly: TDACButton
          Caption = 'Apenas icone'
          Kind = mbkWarning
          Size = mbsMedium
          ShowIcon = True
          IconKind = mikWarning
          IconSize = 20
          Tag = 4
        end
        object BtnWarningLoading: TDACButton
          Caption = 'Loading'
          Kind = mbkWarning
          Size = mbsLarge
          Loading = True
          ShowIcon = True
          IconKind = mikSpinner
          Tag = 4
        end
        object BtnWarningDisabled: TDACButton
          Caption = 'Disabled'
          Kind = mbkWarning
          Enabled = False
          Tag = 4
        end
        object BtnWarningDisabledLoading: TDACButton
          Caption = 'Disabled + Loading'
          Kind = mbkWarning
          Enabled = False
          Loading = True
          ShowIcon = True
          IconKind = mikSpinner
          Tag = 4
        end
        object BtnWarningRadius0: TDACButton
          Caption = 'Radius 0'
          Kind = mbkWarning
          CornerRadius = 0
          ShowIcon = True
          IconKind = mikWarning
          Tag = 4
        end
        object BtnWarningRadius24: TDACButton
          Caption = 'Radius 24'
          Kind = mbkWarning
          CornerRadius = 24
          ShowIcon = True
          IconKind = mikWarning
          Tag = 4
        end
        object BtnWarningTabStopFalse: TDACButton
          Caption = 'TabStop = False'
          Kind = mbkWarning
          Size = mbsMedium
          TabStop = False
          ShowIcon = True
          IconKind = mikWarning
          Tag = 12
        end
        object LblButtonsDanger: TLabel
          AutoSize = False
          Caption = 'Kind: mbkDanger'
          Tag = 12
          Font.Style = [fsBold]
          Layout = tlTop
          Margins.Left = 4
          Margins.Top = 4
          WordWrap = True
        end
        object BtnDangerTextSmall: TDACButton
          Caption = 'Texto so'
          Kind = mbkDanger
          Size = mbsSmall
          Tag = 4
        end
        object BtnDangerIconLeft: TDACButton
          Caption = 'Texto + icone esquerda'
          Kind = mbkDanger
          Size = mbsSmall
          ShowIcon = True
          IconPosition = mipLeft
          IconKind = mikDanger
          Tag = 4
        end
        object BtnDangerIconRight: TDACButton
          Caption = 'Texto + icone direita'
          Kind = mbkDanger
          Size = mbsSmall
          ShowIcon = True
          IconPosition = mipRight
          IconKind = mikDanger
          Tag = 4
        end
        object BtnDangerIconOnly: TDACButton
          Caption = 'Apenas icone'
          Kind = mbkDanger
          Size = mbsMedium
          ShowIcon = True
          IconKind = mikDanger
          IconSize = 20
          Tag = 4
        end
        object BtnDangerLoading: TDACButton
          Caption = 'Loading'
          Kind = mbkDanger
          Size = mbsLarge
          Loading = True
          ShowIcon = True
          IconKind = mikSpinner
          Tag = 4
        end
        object BtnDangerDisabled: TDACButton
          Caption = 'Disabled'
          Kind = mbkDanger
          Enabled = False
          Tag = 4
        end
        object BtnDangerDisabledLoading: TDACButton
          Caption = 'Disabled + Loading'
          Kind = mbkDanger
          Enabled = False
          Loading = True
          ShowIcon = True
          IconKind = mikSpinner
          Tag = 4
        end
        object BtnDangerRadius0: TDACButton
          Caption = 'Radius 0'
          Kind = mbkDanger
          CornerRadius = 0
          ShowIcon = True
          IconKind = mikDanger
          Tag = 4
        end
        object BtnDangerRadius24: TDACButton
          Caption = 'Radius 24'
          Kind = mbkDanger
          CornerRadius = 24
          ShowIcon = True
          IconKind = mikDanger
          Tag = 4
        end
        object BtnDangerTabStopFalse: TDACButton
          Caption = 'TabStop = False'
          Kind = mbkDanger
          Size = mbsMedium
          TabStop = False
          ShowIcon = True
          IconKind = mikDanger
          Tag = 12
        end
        object LblButtonsTransparent: TLabel
          AutoSize = False
          Caption = 'Kind: mbkTransparent'
          Tag = 12
          Font.Style = [fsBold]
          Layout = tlTop
          Margins.Left = 4
          Margins.Top = 4
          WordWrap = True
        end
        object BtnTransparentTextSmall: TDACButton
          Caption = 'Texto so'
          Kind = mbkTransparent
          Size = mbsSmall
          Tag = 4
        end
        object BtnTransparentIconLeft: TDACButton
          Caption = 'Texto + icone esquerda'
          Kind = mbkTransparent
          Size = mbsSmall
          ShowIcon = True
          IconPosition = mipLeft
          IconKind = mikCalendar
          Tag = 4
        end
        object BtnTransparentIconRight: TDACButton
          Caption = 'Texto + icone direita'
          Kind = mbkTransparent
          Size = mbsSmall
          ShowIcon = True
          IconPosition = mipRight
          IconKind = mikClock
          Tag = 4
        end
        object BtnTransparentIconOnly: TDACButton
          Caption = 'Apenas icone'
          Kind = mbkTransparent
          Size = mbsMedium
          ShowIcon = True
          IconKind = mikSearch
          IconSize = 20
          Tag = 4
        end
        object BtnTransparentLoading: TDACButton
          Caption = 'Loading'
          Kind = mbkTransparent
          Size = mbsLarge
          Loading = True
          ShowIcon = True
          IconKind = mikSpinner
          Tag = 4
        end
        object BtnTransparentDisabled: TDACButton
          Caption = 'Disabled'
          Kind = mbkTransparent
          Enabled = False
          Tag = 4
        end
        object BtnTransparentDisabledLoading: TDACButton
          Caption = 'Disabled + Loading'
          Kind = mbkTransparent
          Enabled = False
          Loading = True
          ShowIcon = True
          IconKind = mikSpinner
          Tag = 4
        end
        object BtnTransparentRadius0: TDACButton
          Caption = 'Radius 0'
          Kind = mbkTransparent
          CornerRadius = 0
          ShowIcon = True
          IconKind = mikInfoCircle
          Tag = 4
        end
        object BtnTransparentRadius24: TDACButton
          Caption = 'Radius 24'
          Kind = mbkTransparent
          CornerRadius = 24
          ShowIcon = True
          IconKind = mikInfoCircle
          Tag = 4
        end
        object BtnTransparentTabStopFalse: TDACButton
          Caption = 'TabStop = False'
          Kind = mbkTransparent
          Size = mbsMedium
          TabStop = False
          ShowIcon = True
          IconKind = mikInfoCircle
          Tag = 12
        end
        object LblButtonsInputAction: TLabel
          AutoSize = False
          Caption = 'Kind: mbkInputAction'
          Tag = 12
          Font.Style = [fsBold]
          Layout = tlTop
          Margins.Left = 4
          Margins.Top = 4
          WordWrap = True
        end
        object BtnInputActionTextSmall: TDACButton
          Caption = 'Texto so'
          Kind = mbkInputAction
          Size = mbsSmall
          Tag = 4
        end
        object BtnInputActionIconLeft: TDACButton
          Caption = 'Texto + icone esquerda'
          Kind = mbkInputAction
          Size = mbsSmall
          ShowIcon = True
          IconPosition = mipLeft
          IconKind = mikUser
          Tag = 4
        end
        object BtnInputActionIconRight: TDACButton
          Caption = 'Texto + icone direita'
          Kind = mbkInputAction
          Size = mbsSmall
          ShowIcon = True
          IconPosition = mipRight
          IconKind = mikUsers
          Tag = 4
        end
        object BtnInputActionIconOnly: TDACButton
          Caption = 'Apenas icone'
          Kind = mbkInputAction
          Size = mbsMedium
          ShowIcon = True
          IconKind = mikSearch
          IconSize = 20
          Tag = 4
        end
        object BtnInputActionLoading: TDACButton
          Caption = 'Loading'
          Kind = mbkInputAction
          Size = mbsLarge
          Loading = True
          ShowIcon = True
          IconKind = mikSpinner
          Tag = 4
        end
        object BtnInputActionDisabled: TDACButton
          Caption = 'Disabled'
          Kind = mbkInputAction
          Enabled = False
          Tag = 4
        end
        object BtnInputActionDisabledLoading: TDACButton
          Caption = 'Disabled + Loading'
          Kind = mbkInputAction
          Enabled = False
          Loading = True
          ShowIcon = True
          IconKind = mikSpinner
          Tag = 4
        end
        object BtnInputActionRadius0: TDACButton
          Caption = 'Radius 0'
          Kind = mbkInputAction
          CornerRadius = 0
          ShowIcon = True
          IconKind = mikSearch
          Tag = 4
        end
        object BtnInputActionRadius24: TDACButton
          Caption = 'Radius 24'
          Kind = mbkInputAction
          CornerRadius = 24
          ShowIcon = True
          IconKind = mikSearch
          Tag = 4
        end
        object BtnInputActionTabStopFalse: TDACButton
          Caption = 'TabStop = False'
          Kind = mbkInputAction
          Size = mbsMedium
          TabStop = False
          ShowIcon = True
          IconKind = mikSearch
          Tag = 12
        end
      end
    end
    object TabInputs: TDACScrollContainer
      Left = 0
      Top = 0
      Width = 1280
      Height = 860
      Align = alClient
      Anchors = [akLeft, akTop, akRight, akBottom]
      AutoScroll = True
      BackgroundColor = $00000000
      BorderColor = $00000000
      BorderStyle = bsNone
      CornerRadius = 0
      ScrollBarMode = msbmAuto
      object GridInputs: TDACGridContainer
        Left = 0
        Top = 0
        Width = 1248
        Height = 128
        Align = alTop
        Anchors = [akLeft, akTop, akRight]
        AutoLayout = True
        BackgroundColor = $00000000
        BorderColor = $00000000
        Columns = 12
        ContentPadding = 16
        CornerRadius = 0
        Gutter = 16
        RowHeight = 84
        object LblInputsTitle: TLabel
          AutoSize = False
          Caption = 'DEMO: Inputs'
          Font.Size = 12
          Font.Style = [fsBold]
          Layout = tlTop
          Margins.Left = 4
          Margins.Top = 4
          Margins.Bottom = 4
          Tag = 12
          WordWrap = True
        end
        object LblInputsDesc: TLabel
          AutoSize = False
          Caption = 'Container em design-time para incluir os controles de entrada da biblioteca.'
          Tag = 12
          Font.Style = [fsItalic]
          Layout = tlTop
          Margins.Left = 4
          Margins.Top = 4
          Margins.Bottom = 4
          WordWrap = True
        end
      end
    end
    object TabSeletores: TDACScrollContainer
      Left = 0
      Top = 0
      Width = 1280
      Height = 860
      Align = alClient
      Anchors = [akLeft, akTop, akRight, akBottom]
      AutoScroll = True
      BackgroundColor = $00000000
      BorderColor = $00000000
      BorderStyle = bsNone
      CornerRadius = 0
      ScrollBarMode = msbmAuto
      object GridSeletores: TDACGridContainer
        Left = 0
        Top = 0
        Width = 1248
        Height = 128
        Align = alTop
        Anchors = [akLeft, akTop, akRight]
        AutoLayout = True
        BackgroundColor = $00000000
        BorderColor = $00000000
        Columns = 12
        ContentPadding = 16
        CornerRadius = 0
        Gutter = 16
        RowHeight = 84
        object LblSeletoresTitle: TLabel
          AutoSize = False
          Caption = 'DEMO: Seletores'
          Font.Size = 12
          Font.Style = [fsBold]
          Layout = tlTop
          Margins.Left = 4
          Margins.Top = 4
          Margins.Bottom = 4
          Tag = 12
          WordWrap = True
        end
        object LblSeletoresDesc: TLabel
          AutoSize = False
          Caption = 'Container para mostrar checkbox, radio, toggle, slider e paginacao de selecao.'
          Tag = 12
          Font.Style = [fsItalic]
          Layout = tlTop
          Margins.Left = 4
          Margins.Top = 4
          Margins.Bottom = 4
          WordWrap = True
        end
      end
    end
    object TabContainers: TDACScrollContainer
      Left = 0
      Top = 0
      Width = 1280
      Height = 860
      Align = alClient
      Anchors = [akLeft, akTop, akRight, akBottom]
      AutoScroll = True
      BackgroundColor = $00000000
      BorderColor = $00000000
      BorderStyle = bsNone
      CornerRadius = 0
      ScrollBarMode = msbmAuto
      object GridContainers: TDACGridContainer
        Left = 0
        Top = 0
        Width = 1248
        Height = 128
        Align = alTop
        Anchors = [akLeft, akTop, akRight]
        AutoLayout = True
        BackgroundColor = $00000000
        BorderColor = $00000000
        Columns = 12
        ContentPadding = 16
        CornerRadius = 0
        Gutter = 16
        RowHeight = 84
        object LblContainersTitle: TLabel
          AutoSize = False
          Caption = 'DEMO: Containers'
          Font.Size = 12
          Font.Style = [fsBold]
          Layout = tlTop
          Margins.Left = 4
          Margins.Top = 4
          Margins.Bottom = 4
          Tag = 12
          WordWrap = True
        end
        object LblContainersDesc: TLabel
          AutoSize = False
          Caption = 'Container para demonstrar GridContainer e ScrollContainer.'
          Tag = 12
          Font.Style = [fsItalic]
          Layout = tlTop
          Margins.Left = 4
          Margins.Top = 4
          Margins.Bottom = 4
          WordWrap = True
        end
      end
    end
    object TabTabs: TDACScrollContainer
      Left = 0
      Top = 0
      Width = 1280
      Height = 860
      Align = alClient
      Anchors = [akLeft, akTop, akRight, akBottom]
      AutoScroll = True
      BackgroundColor = $00000000
      BorderColor = $00000000
      BorderStyle = bsNone
      CornerRadius = 0
      ScrollBarMode = msbmAuto
      object GridTabs: TDACGridContainer
        Left = 0
        Top = 0
        Width = 1248
        Height = 128
        Align = alTop
        Anchors = [akLeft, akTop, akRight]
        AutoLayout = True
        BackgroundColor = $00000000
        BorderColor = $00000000
        Columns = 12
        ContentPadding = 16
        CornerRadius = 0
        Gutter = 16
        RowHeight = 84
        object LblTabsTitle: TLabel
          AutoSize = False
          Caption = 'DEMO: Tabs'
          Font.Size = 12
          Font.Style = [fsBold]
          Layout = tlTop
          Margins.Left = 4
          Margins.Top = 4
          Margins.Bottom = 4
          Tag = 12
          WordWrap = True
        end
        object LblTabsDesc: TLabel
          AutoSize = False
          Caption = 'Validar comportamento de aba em execucao: conteudo por indice correto.'
          Tag = 12
          Font.Style = [fsItalic]
          Layout = tlTop
          Margins.Left = 4
          Margins.Top = 4
          Margins.Bottom = 4
          WordWrap = True
        end
      end
    end
    object TabCards: TDACScrollContainer
      Left = 0
      Top = 0
      Width = 1280
      Height = 860
      Align = alClient
      Anchors = [akLeft, akTop, akRight, akBottom]
      AutoScroll = True
      BackgroundColor = $00000000
      BorderColor = $00000000
      BorderStyle = bsNone
      CornerRadius = 0
      ScrollBarMode = msbmAuto
      object GridCards: TDACGridContainer
        Left = 0
        Top = 0
        Width = 1248
        Height = 128
        Align = alTop
        Anchors = [akLeft, akTop, akRight]
        AutoLayout = True
        BackgroundColor = $00000000
        BorderColor = $00000000
        Columns = 12
        ContentPadding = 16
        CornerRadius = 0
        Gutter = 16
        RowHeight = 84
        object LblCardsTitle: TLabel
          AutoSize = False
          Caption = 'DEMO: Cards'
          Font.Size = 12
          Font.Style = [fsBold]
          Layout = tlTop
          Margins.Left = 4
          Margins.Top = 4
          Margins.Bottom = 4
          Tag = 12
          WordWrap = True
        end
        object LblCardsDesc: TLabel
          AutoSize = False
          Caption = 'Container para cards de status e resumo.'
          Tag = 12
          Font.Style = [fsItalic]
          Layout = tlTop
          Margins.Left = 4
          Margins.Top = 4
          Margins.Bottom = 4
          WordWrap = True
        end
      end
    end
    object TabGrid: TDACScrollContainer
      Left = 0
      Top = 0
      Width = 1280
      Height = 860
      Align = alClient
      Anchors = [akLeft, akTop, akRight, akBottom]
      AutoScroll = True
      BackgroundColor = $00000000
      BorderColor = $00000000
      BorderStyle = bsNone
      CornerRadius = 0
      ScrollBarMode = msbmAuto
      object GridGrid: TDACGridContainer
        Left = 0
        Top = 0
        Width = 1248
        Height = 128
        Align = alTop
        Anchors = [akLeft, akTop, akRight]
        AutoLayout = True
        BackgroundColor = $00000000
        BorderColor = $00000000
        Columns = 12
        ContentPadding = 16
        CornerRadius = 0
        Gutter = 16
        RowHeight = 84
        object LblGridTitle: TLabel
          AutoSize = False
          Caption = 'DEMO: Grid'
          Font.Size = 12
          Font.Style = [fsBold]
          Layout = tlTop
          Margins.Left = 4
          Margins.Top = 4
          Margins.Bottom = 4
          Tag = 12
          WordWrap = True
        end
        object LblGridDesc: TLabel
          AutoSize = False
          Caption = 'Container para mostrar grid de dados da biblioteca.'
          Tag = 12
          Font.Style = [fsItalic]
          Layout = tlTop
          Margins.Left = 4
          Margins.Top = 4
          Margins.Bottom = 4
          WordWrap = True
        end
      end
    end
    object TabStatus: TDACScrollContainer
      Left = 0
      Top = 0
      Width = 1280
      Height = 860
      Align = alClient
      Anchors = [akLeft, akTop, akRight, akBottom]
      AutoScroll = True
      BackgroundColor = $00000000
      BorderColor = $00000000
      BorderStyle = bsNone
      CornerRadius = 0
      ScrollBarMode = msbmAuto
      object GridStatus: TDACGridContainer
        Left = 0
        Top = 0
        Width = 1248
        Height = 128
        Align = alTop
        Anchors = [akLeft, akTop, akRight]
        AutoLayout = True
        BackgroundColor = $00000000
        BorderColor = $00000000
        Columns = 12
        ContentPadding = 16
        CornerRadius = 0
        Gutter = 16
        RowHeight = 84
        object LblStatusTitle: TLabel
          AutoSize = False
          Caption = 'DEMO: Status'
          Font.Size = 12
          Font.Style = [fsBold]
          Layout = tlTop
          Margins.Left = 4
          Margins.Top = 4
          Margins.Bottom = 4
          Tag = 12
          WordWrap = True
        end
        object LblStatusDesc: TLabel
          AutoSize = False
          Caption = 'Container para barra de status, badges de estado e indicadores.'
          Tag = 12
          Font.Style = [fsItalic]
          Layout = tlTop
          Margins.Left = 4
          Margins.Top = 4
          Margins.Bottom = 4
          WordWrap = True
        end
      end
    end
    object TabBadges: TDACScrollContainer
      Left = 0
      Top = 0
      Width = 1280
      Height = 860
      Align = alClient
      Anchors = [akLeft, akTop, akRight, akBottom]
      AutoScroll = True
      BackgroundColor = $00000000
      BorderColor = $00000000
      BorderStyle = bsNone
      CornerRadius = 0
      ScrollBarMode = msbmAuto
      object GridBadges: TDACGridContainer
        Left = 0
        Top = 0
        Width = 1248
        Height = 128
        Align = alTop
        Anchors = [akLeft, akTop, akRight]
        AutoLayout = True
        BackgroundColor = $00000000
        BorderColor = $00000000
        Columns = 12
        ContentPadding = 16
        CornerRadius = 0
        Gutter = 16
        RowHeight = 84
        object LblBadgesTitle: TLabel
          AutoSize = False
          Caption = 'DEMO: Badges'
          Font.Size = 12
          Font.Style = [fsBold]
          Layout = tlTop
          Margins.Left = 4
          Margins.Top = 4
          Margins.Bottom = 4
          Tag = 12
          WordWrap = True
        end
        object LblBadgesDesc: TLabel
          AutoSize = False
          Caption = 'Container para chips, tags e badges.'
          Tag = 12
          Font.Style = [fsItalic]
          Layout = tlTop
          Margins.Left = 4
          Margins.Top = 4
          Margins.Bottom = 4
          WordWrap = True
        end
      end
    end
    object TabProgress: TDACScrollContainer
      Left = 0
      Top = 0
      Width = 1280
      Height = 860
      Align = alClient
      Anchors = [akLeft, akTop, akRight, akBottom]
      AutoScroll = True
      BackgroundColor = $00000000
      BorderColor = $00000000
      BorderStyle = bsNone
      CornerRadius = 0
      ScrollBarMode = msbmAuto
      object GridProgress: TDACGridContainer
        Left = 0
        Top = 0
        Width = 1248
        Height = 128
        Align = alTop
        Anchors = [akLeft, akTop, akRight]
        AutoLayout = True
        BackgroundColor = $00000000
        BorderColor = $00000000
        Columns = 12
        ContentPadding = 16
        CornerRadius = 0
        Gutter = 16
        RowHeight = 84
        object LblProgressTitle: TLabel
          AutoSize = False
          Caption = 'DEMO: Progress'
          Font.Size = 12
          Font.Style = [fsBold]
          Layout = tlTop
          Margins.Left = 4
          Margins.Top = 4
          Margins.Bottom = 4
          Tag = 12
          WordWrap = True
        end
        object LblProgressDesc: TLabel
          AutoSize = False
          Caption = 'Container para progressos linear/circular e estados de carregamento.'
          Tag = 12
          Font.Style = [fsItalic]
          Layout = tlTop
          Margins.Left = 4
          Margins.Top = 4
          Margins.Bottom = 4
          WordWrap = True
        end
      end
    end
    object TabPaginacao: TDACScrollContainer
      Left = 0
      Top = 0
      Width = 1280
      Height = 860
      Align = alClient
      Anchors = [akLeft, akTop, akRight, akBottom]
      AutoScroll = True
      BackgroundColor = $00000000
      BorderColor = $00000000
      BorderStyle = bsNone
      CornerRadius = 0
      ScrollBarMode = msbmAuto
      object GridPaginacao: TDACGridContainer
        Left = 0
        Top = 0
        Width = 1248
        Height = 128
        Align = alTop
        Anchors = [akLeft, akTop, akRight]
        AutoLayout = True
        BackgroundColor = $00000000
        BorderColor = $00000000
        Columns = 12
        ContentPadding = 16
        CornerRadius = 0
        Gutter = 16
        RowHeight = 84
        object LblPaginacaoTitle: TLabel
          AutoSize = False
          Caption = 'DEMO: Paginacao'
          Font.Size = 12
          Font.Style = [fsBold]
          Layout = tlTop
          Margins.Left = 4
          Margins.Top = 4
          Margins.Bottom = 4
          Tag = 12
          WordWrap = True
        end
        object LblPaginacaoDesc: TLabel
          AutoSize = False
          Caption = 'Container para navegacao de paginas, pagina anterior e proxima.'
          Tag = 12
          Font.Style = [fsItalic]
          Layout = tlTop
          Margins.Left = 4
          Margins.Top = 4
          Margins.Bottom = 4
          WordWrap = True
        end
      end
    end
    object TabLoading: TDACScrollContainer
      Left = 0
      Top = 0
      Width = 1280
      Height = 860
      Align = alClient
      Anchors = [akLeft, akTop, akRight, akBottom]
      AutoScroll = True
      BackgroundColor = $00000000
      BorderColor = $00000000
      BorderStyle = bsNone
      CornerRadius = 0
      ScrollBarMode = msbmAuto
      object GridLoading: TDACGridContainer
        Left = 0
        Top = 0
        Width = 1248
        Height = 128
        Align = alTop
        Anchors = [akLeft, akTop, akRight]
        AutoLayout = True
        BackgroundColor = $00000000
        BorderColor = $00000000
        Columns = 12
        ContentPadding = 16
        CornerRadius = 0
        Gutter = 16
        RowHeight = 84
        object LblLoadingTitle: TLabel
          AutoSize = False
          Caption = 'DEMO: Loading'
          Font.Size = 12
          Font.Style = [fsBold]
          Layout = tlTop
          Margins.Left = 4
          Margins.Top = 4
          Margins.Bottom = 4
          Tag = 12
          WordWrap = True
        end
        object LblLoadingDesc: TLabel
          AutoSize = False
          Caption = 'Container para placeholders, spinners e estados de aguarde.'
          Tag = 12
          Font.Style = [fsItalic]
          Layout = tlTop
          Margins.Left = 4
          Margins.Top = 4
          Margins.Bottom = 4
          WordWrap = True
        end
      end
    end
    object TabFeedback: TDACScrollContainer
      Left = 0
      Top = 0
      Width = 1280
      Height = 860
      Align = alClient
      Anchors = [akLeft, akTop, akRight, akBottom]
      AutoScroll = True
      BackgroundColor = $00000000
      BorderColor = $00000000
      BorderStyle = bsNone
      CornerRadius = 0
      ScrollBarMode = msbmAuto
      object GridFeedback: TDACGridContainer
        Left = 0
        Top = 0
        Width = 1248
        Height = 128
        Align = alTop
        Anchors = [akLeft, akTop, akRight]
        AutoLayout = True
        BackgroundColor = $00000000
        BorderColor = $00000000
        Columns = 12
        ContentPadding = 16
        CornerRadius = 0
        Gutter = 16
        RowHeight = 84
        object LblFeedbackTitle: TLabel
          AutoSize = False
          Caption = 'DEMO: Feedback'
          Font.Size = 12
          Font.Style = [fsBold]
          Layout = tlTop
          Margins.Left = 4
          Margins.Top = 4
          Margins.Bottom = 4
          Tag = 12
          WordWrap = True
        end
        object LblFeedbackDesc: TLabel
          AutoSize = False
          Caption = 'Container para toast, tooltip e modal da biblioteca.'
          Tag = 12
          Font.Style = [fsItalic]
          Layout = tlTop
          Margins.Left = 4
          Margins.Top = 4
          Margins.Bottom = 4
          WordWrap = True
        end
      end
    end
    object TabGraficos: TDACScrollContainer
      Left = 0
      Top = 0
      Width = 1280
      Height = 860
      Align = alClient
      Anchors = [akLeft, akTop, akRight, akBottom]
      AutoScroll = True
      BackgroundColor = $00000000
      BorderColor = $00000000
      BorderStyle = bsNone
      CornerRadius = 0
      ScrollBarMode = msbmAuto
      object GridGraficos: TDACGridContainer
        Left = 0
        Top = 0
        Width = 1248
        Height = 128
        Align = alTop
        Anchors = [akLeft, akTop, akRight]
        AutoLayout = True
        BackgroundColor = $00000000
        BorderColor = $00000000
        Columns = 12
        ContentPadding = 16
        CornerRadius = 0
        Gutter = 16
        RowHeight = 84
        object LblGraficosTitle: TLabel
          AutoSize = False
          Caption = 'DEMO: Graficos'
          Font.Size = 12
          Font.Style = [fsBold]
          Layout = tlTop
          Margins.Left = 4
          Margins.Top = 4
          Margins.Bottom = 4
          Tag = 12
          WordWrap = True
        end
        object LblGraficosDesc: TLabel
          AutoSize = False
          Caption = 'Container para chart bar, line, area e donut.'
          Tag = 12
          Font.Style = [fsItalic]
          Layout = tlTop
          Margins.Left = 4
          Margins.Top = 4
          Margins.Bottom = 4
          WordWrap = True
        end
      end
    end
    object TabReport: TDACScrollContainer
      Left = 0
      Top = 0
      Width = 1280
      Height = 860
      Align = alClient
      Anchors = [akLeft, akTop, akRight, akBottom]
      AutoScroll = True
      BackgroundColor = $00000000
      BorderColor = $00000000
      BorderStyle = bsNone
      CornerRadius = 0
      ScrollBarMode = msbmAuto
      object GridReport: TDACGridContainer
        Left = 0
        Top = 0
        Width = 1248
        Height = 128
        Align = alTop
        Anchors = [akLeft, akTop, akRight]
        AutoLayout = True
        BackgroundColor = $00000000
        BorderColor = $00000000
        Columns = 12
        ContentPadding = 16
        CornerRadius = 0
        Gutter = 16
        RowHeight = 84
        object LblReportTitle: TLabel
          AutoSize = False
          Caption = 'DEMO: Report'
          Font.Size = 12
          Font.Style = [fsBold]
          Layout = tlTop
          Margins.Left = 4
          Margins.Top = 4
          Margins.Bottom = 4
          Tag = 12
          WordWrap = True
        end
        object LblReportDesc: TLabel
          AutoSize = False
          Caption = 'Container para preview de relatorios e controle de pagina.'
          Tag = 12
          Font.Style = [fsItalic]
          Layout = tlTop
          Margins.Left = 4
          Margins.Top = 4
          Margins.Bottom = 4
          WordWrap = True
        end
      end
    end
  end
end
