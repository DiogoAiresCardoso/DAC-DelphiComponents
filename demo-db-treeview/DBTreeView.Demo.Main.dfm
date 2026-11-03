object DBTreeDemoForm: TDBTreeDemoForm
  Left = 0
  Top = 0
  Caption = 'DAC DBTreeView - exemplo local data-aware'
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
      Left = 112
      Top = 10
      Width = 420
      Height = 25
      TabOrder = 0
      OnChange = SearchChange
    end
    object PreviousButton: TButton
      Left = 16
      Top = 52
      Width = 105
      Height = 30
      Caption = 'Anterior'
      TabOrder = 1
      OnClick = PreviousButtonClick
    end
    object NextButton: TButton
      Left = 129
      Top = 52
      Width = 105
      Height = 30
      Caption = 'Proximo'
      TabOrder = 2
      OnClick = NextButtonClick
    end
    object ExpandButton: TButton
      Left = 250
      Top = 52
      Width = 105
      Height = 30
      Caption = 'Expandir tudo'
      TabOrder = 3
      OnClick = ExpandButtonClick
    end
    object CollapseButton: TButton
      Left = 363
      Top = 52
      Width = 105
      Height = 30
      Caption = 'Recolher tudo'
      TabOrder = 4
      OnClick = CollapseButtonClick
    end
    object ThemeButton: TButton
      Left = 484
      Top = 52
      Width = 105
      Height = 30
      Caption = 'Alternar tema'
      TabOrder = 5
      OnClick = ThemeButtonClick
    end
    object ReadOnlyBox: TCheckBox
      Left = 612
      Top = 58
      Width = 150
      Height = 20
      Caption = 'Somente leitura'
      TabOrder = 6
      OnClick = ReadOnlyBoxClick
    end
    object ShowHeaderBox: TCheckBox
      Left = 560
      Top = 10
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
    Top = 550
    Width = 1020
    Height = 70
    Align = alBottom
    BevelOuter = bvNone
    TabOrder = 2
    object Status: TLabel
      Left = 16
      Top = 10
      Width = 988
      Height = 17
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      Caption = 'Chave atual:'
    end
    object Instructions: TLabel
      Left = 16
      Top = 38
      Width = 988
      Height = 30
      Anchors = [akLeft, akTop, akRight]
      AutoSize = False
      WordWrap = True
      Caption = 'Setas: navegar/expandir. Espaco: marcar. Enter: ativar. Tab/Shift+Tab: sair. Grupos e registros bloqueados nao mostram checkbox.'
    end
  end
  object Tree: TDACDBTreeView
    Left = 0
    Top = 100
    Width = 1020
    Height = 450
    Align = alClient
    TabOrder = 1
    TabStop = True
    ShowHint = True
    DataSource = Source
    KeyField = 'PLANOFINANCE_CODIGO'
    ParentField = 'PLANOFINANCE_CODIGOPAI'
    CheckField = 'SELECIONADO'
    CheckableField = 'SELECIONAVEL'
    ThemeMode = dtmLight
    Columns = <
      item
        FieldName = 'PLANOFINANCE_CODIGOPLANO'
        Caption = 'Codigo'
        Width = 280
        Hint = 'Codigo do plano'
        TitleHint = 'Codigo apresentado pelo consumidor'
      end
      item
        FieldName = 'PLANOFINANCE_DESCRICAO'
        Caption = 'Descricao'
        Width = 650
      end>
    OnBeforeCheckChange = TreeBeforeCheckChange
    OnCheckChanged = TreeCheckChanged
    OnCurrentChanged = TreeCurrentChanged
    OnActivateRecord = TreeActivateRecord
    OnDataError = TreeDataError
  end
  object Source: TDataSource
    DataSet = Data
    Left = 848
    Top = 24
  end
  object Data: TClientDataSet
    Aggregates = <>
    Params = <>
    Left = 920
    Top = 24
  end
end
