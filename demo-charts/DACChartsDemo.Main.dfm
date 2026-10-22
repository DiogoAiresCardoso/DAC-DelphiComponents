object ChartsDemoForm: TChartsDemoForm
  Caption = 'DAC Charts - ECharts / Skia'
  ClientWidth = 1200
  ClientHeight = 800
  Position = poScreenCenter
  Font.Name = 'Segoe UI'
  Font.Height = -13
  OnCreate = FormCreate
  OnDestroy = FormDestroy
  OnShow = FormShow
  object Pages: TPageControl
    Align = alClient
    OnChange = PageChanged
    object GalleryTab: TTabSheet
      Caption = 'Galeria'
      object Gallery: TScrollBox
        Align = alClient
        BorderStyle = bsNone
      end
    end
    object ConfigTab: TTabSheet
      Caption = 'Configuracao'
      object ConfigBar: TPanel
        Align = alTop
        Height = 90
        object Cases: TComboBox
          Left = 10
          Top = 10
          Width = 560
          Height = 25
          Style = csDropDownList
          OnChange = CaseChanged
        end
        object Status: TLabel
          Left = 10
          Top = 70
          Width = 1000
          Height = 16
          Caption = 'Configuracao ECharts 6.1.0'
        end
        object ApplyButton: TButton
          Left = 10
          Top = 39
          Width = 115
          Height = 26
          Caption = 'Aplicar JSON'
          OnClick = ApplyClick
        end
        object ResetButton: TButton
          Left = 135
          Top = 39
          Width = 115
          Height = 26
          Caption = 'Restaurar'
          OnClick = ResetClick
        end
        object ImportButton: TButton
          Left = 260
          Top = 39
          Width = 115
          Height = 26
          Caption = 'Importar'
          OnClick = ImportClick
        end
        object ExportButton: TButton
          Left = 385
          Top = 39
          Width = 115
          Height = 26
          Caption = 'Exportar'
          OnClick = ExportClick
        end
        object CopyButton: TButton
          Left = 510
          Top = 39
          Width = 115
          Height = 26
          Caption = 'Copiar JSON'
          OnClick = CopyClick
        end
      end
      object Editor: TMemo
        Align = alBottom
        Height = 170
        ScrollBars = ssBoth
        WordWrap = False
        Font.Name = 'Consolas'
        Font.Height = -13
      end
      object ChartHost: TPanel
        Align = alClient
        BevelOuter = bvNone
      end
    end
    object VisualTab: TTabSheet
      Caption = 'Elementos visuais'
      object VisualBar: TPanel
        Align = alTop
        Height = 105
        object UnavailableLabel: TLabel
          Left = 10
          Top = 78
          Caption = 'Indisponiveis: zoom, multiplos eixos, tooltip externo/HTML, demais familias. Recursos em validacao: rich text e transicoes de saida.'
        end
        object TitleEdit: TEdit
          Left = 10
          Top = 10
          Width = 380
          Text = 'Titulo configuravel'
          OnChange = VisualChanged
        end
        object LabelsCheck: TCheckBox
          Left = 10
          Top = 45
          Width = 130
          Caption = 'Labels'
          OnClick = VisualChanged
        end
        object LegendCheck: TCheckBox
          Left = 150
          Top = 45
          Width = 130
          Caption = 'Legenda'
          OnClick = VisualChanged
        end
        object TooltipCheck: TCheckBox
          Left = 290
          Top = 45
          Width = 130
          Caption = 'Tooltip'
          OnClick = VisualChanged
        end
        object LegendOrientation: TComboBox
          Left = 620
          Top = 10
          Width = 200
          Style = csDropDownList
          Items.Strings = (
            'Orientacao: padrao'
            'Horizontal'
            'Vertical')
          ItemIndex = 0
          OnChange = VisualChanged
        end
        object ThemeBox: TComboBox
          Left = 420
          Top = 10
          Width = 180
          Style = csDropDownList
          Items.Strings = (
            'ECharts'
            'DAC')
          ItemIndex = 0
          OnChange = VisualChanged
        end
      end
      object VisualHost: TPanel
        Align = alClient
        BevelOuter = bvNone
      end
    end
    object CompareTab: TTabSheet
      Caption = 'Comparacao'
      object CompareBar: TPanel
        Align = alTop
        Height = 80
        object ReferenceDir: TEdit
          Left = 10
          Top = 10
          Width = 440
          Text = 'tmp\chart-implementation\reference'
        end
        object ActualDir: TEdit
          Left = 10
          Top = 43
          Width = 440
          Text = 'tmp\chart-implementation\dac'
        end
        object CompareButton: TButton
          Left = 470
          Top = 10
          Width = 150
          Height = 28
          Caption = 'Carregar imagens'
          OnClick = CompareClick
        end
      end
      object CompareScroll: TScrollBox
        Align = alClient
        object RefCaption: TLabel
          Left = 8
          Top = 8
          Caption = 'ECharts 6.1.0'
        end
        object RefImage: TImage
          Left = 8
          Top = 34
          Width = 720
          Height = 420
        end
        object DACCaption: TLabel
          Left = 738
          Top = 8
          Caption = 'DAC - texto Windows'
        end
        object DACImage: TImage
          Left = 738
          Top = 34
          Width = 720
          Height = 420
        end
        object OverlayCaption: TLabel
          Left = 8
          Top = 463
          Caption = 'Sobreposicao'
        end
        object OverlayImage: TImage
          Left = 8
          Top = 489
          Width = 720
          Height = 420
        end
        object DiffCaption: TLabel
          Left = 738
          Top = 463
          Caption = 'Mapa de diferencas'
        end
        object DiffImage: TImage
          Left = 738
          Top = 489
          Width = 720
          Height = 420
        end
      end
    end
    object StabilityTab: TTabSheet
      Caption = 'Animacao e estabilidade'
      object StabilityBar: TPanel
        Align = alTop
        Height = 52
        object UpdateButton: TButton
          Left = 10
          Top = 10
          Width = 140
          Height = 28
          Caption = 'Atualizar valores'
          OnClick = UpdateClick
        end
        object ReplayButton: TButton
          Left = 160
          Top = 10
          Width = 140
          Height = 28
          Caption = 'Reiniciar animacao'
          OnClick = ReplayClick
        end
        object StopButton: TButton
          Left = 310
          Top = 10
          Width = 140
          Height = 28
          Caption = 'Parar'
          OnClick = StopClick
        end
        object CaptureButton: TButton
          Left = 460
          Top = 10
          Width = 140
          Height = 28
          Caption = 'Capturar PNG'
          OnClick = CaptureClick
        end
        object StressButton: TButton
          Left = 610
          Top = 10
          Width = 140
          Height = 28
          Caption = 'Carga 1.000 pontos'
          OnClick = StressClick
        end
      end
      object Metrics: TMemo
        Align = alBottom
        Height = 110
        ReadOnly = True
        ScrollBars = ssVertical
      end
      object StabilityHost: TPanel
        Align = alClient
        BevelOuter = bvNone
      end
    end
  end
  object MetricsTimer: TTimer
    Enabled = False
    Interval = 250
    OnTimer = MetricsTick
  end
  object OpenDialog: TOpenDialog
    Filter = 'JSON|*.json'
  end
  object SaveDialog: TSaveDialog
    Filter = 'JSON|*.json'
    DefaultExt = 'json'
  end
  object DemoData: TClientDataSet
    Active = False
  end
  object DemoSource: TDataSource
    DataSet = DemoData
  end
  object FilterButton: TButton
    Left = 800
    Top = 0
    Width = 200
    Height = 23
    Caption = 'Alternar filtro data-aware'
    OnClick = FilterClick
  end

end
