object ChartsDemoForm: TChartsDemoForm
  Left = 0
  Top = 0
  Caption = 'DAC Charts - Skia Demo'
  ClientHeight = 820
  ClientWidth = 1320
  Color = clWhite
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -13
  Font.Name = 'Segoe UI'
  Font.Style = []
  OldCreateOrder = False
  Position = poScreenCenter
  Scaled = False
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 17
  object pnlHeader: TPanel
    Left = 0
    Top = 0
    Width = 1320
    Height = 76
    Align = alTop
    BevelOuter = bvNone
    TabOrder = 0
    object lblTitle: TLabel
      Left = 20
      Top = 12
      Width = 250
      Height = 25
      Caption = 'TDACChart - Galeria Skia'
      Font.Charset = DEFAULT_CHARSET
      Font.Height = -19
      Font.Name = 'Segoe UI'
      Font.Style = [fsBold]
      ParentFont = False
    end
    object lblDescription: TLabel
      Left = 20
      Top = 42
      Width = 650
      Height = 17
      Caption = 'Manual, data-aware, mixed, gradientes, nulos, eixos e interacao'
    end
    object btnTheme: TButton
      Left = 1132
      Top = 20
      Width = 160
      Height = 34
      Caption = 'Usar tema escuro'
      TabOrder = 0
      OnClick = btnThemeClick
    end
    object btnDataMode: TButton
      Left = 952
      Top = 20
      Width = 160
      Height = 34
      Caption = 'Modo: manual'
      TabOrder = 1
      OnClick = btnDataModeClick
    end
  end
  object sbCharts: TScrollBox
    Left = 0
    Top = 76
    Width = 1320
    Height = 744
    Align = alClient
    BorderStyle = bsNone
    TabOrder = 1
  end
end
