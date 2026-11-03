object TreeDemoForm: TTreeDemoForm
  Left = 0
  Top = 0
  Caption = 'DAC TreeView - itens e objetos'
  ClientHeight = 620
  ClientWidth = 1020
  Constraints.MinHeight = 400
  Constraints.MinWidth = 820
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Position = poScreenCenter
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  PixelsPerInch = 96
  TextHeight = 17
  object Header: TPanel
    Left = 0
    Top = 0
    Width = 1020
    Height = 100
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object SearchLabel: TLabel
      Left = 16
      Top = 14
      Width = 88
      Height = 17
      Caption = 'Busca visual:'
    end
    object Search: TEdit
      Left = 152
      Top = 10
      Width = 380
      Height = 25
      TabOrder = 0
      OnChange = SearchChange
    end
    object LoadObjectsButton: TButton
      Left = 16
      Top = 52
      Width = 140
      Height = 30
      Caption = 'Carregar objetos'
      TabOrder = 1
      OnClick = LoadObjectsButtonClick
    end
    object ManualButton: TButton
      Left = 164
      Top = 52
      Width = 140
      Height = 30
      Caption = 'Criar itens manuais'
      TabOrder = 2
      OnClick = ManualButtonClick
    end
    object ExpandButton: TButton
      Left = 312
      Top = 52
      Width = 105
      Height = 30
      Caption = 'Expandir tudo'
      TabOrder = 3
      OnClick = ExpandButtonClick
    end
    object CollapseButton: TButton
      Left = 425
      Top = 52
      Width = 105
      Height = 30
      Caption = 'Recolher tudo'
      TabOrder = 4
      OnClick = CollapseButtonClick
    end
    object ThemeButton: TButton
      Left = 538
      Top = 52
      Width = 105
      Height = 30
      Caption = 'Alternar tema'
      TabOrder = 5
      OnClick = ThemeButtonClick
    end
    object ReadOnlyBox: TCheckBox
      Left = 560
      Top = 10
      Width = 200
      Height = 25
      Caption = 'Somente leitura'
      TabOrder = 6
      OnClick = ReadOnlyBoxClick
    end
    object ShowHeaderBox: TCheckBox
      Left = 660
      Top = 55
      Width = 180
      Height = 25
      Caption = 'Exibir titulos'
      Checked = True
      State = cbChecked
      TabOrder = 7
      OnClick = ShowHeaderBoxClick
    end
  end
  object Footer: TPanel
    Left = 0
    Top = 530
    Width = 1020
    Height = 90
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    object Status: TLabel
      Left = 16
      Top = 8
      Width = 988
      Height = 34
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      WordWrap = True
      Caption = 'Itens e objetos do consumidor'
    end
    object Instructions: TLabel
      Left = 16
      Top = 48
      Width = 988
      Height = 38
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      WordWrap = True
      Caption = 'Setas: navegar/expandir. Espaco: marcar. Enter: ativar. Tab/Shift+Tab: sair. Objetos externos.'
    end
  end
  object Tree: TDACTreeView
    Left = 0
    Top = 100
    Width = 1020
    Height = 430
    Align = alClient
    TabOrder = 1
    TabStop = True
    ShowHint = True
    ShowCheckBoxes = True
    ThemeMode = dtmLight
    Columns = <
      item
        Caption = 'Item'
        Width = 300
      end
      item
        Caption = 'Detalhes'
        Width = 630
      end>
    OnBeforeCheckChange = TreeBeforeCheckChange
    OnCheckChanged = TreeCheckChanged
    OnCurrentChanged = TreeCurrentChanged
    OnActivateRecord = TreeActivateRecord
    OnDataError = TreeDataError
  end
end
