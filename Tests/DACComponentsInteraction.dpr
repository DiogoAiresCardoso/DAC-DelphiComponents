program DACComponentsInteraction;

{$APPTYPE CONSOLE}

uses
  System.Classes,
  System.Skia,
  System.SysUtils,
  System.Types,
  Data.DB,
  Datasnap.DBClient,
  Winapi.Messages,
  Winapi.Windows,
  Vcl.ComCtrls,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Graphics,
  Vcl.Skia,
  DAC.Components.Dpi in '..\Source\Core\DAC.Components.Dpi.pas',
  DAC.Components.Controls.Badges in '..\Source\Controls\DAC.Components.Controls.Badges.pas',
  DAC.Components.Controls.Button in '..\Source\Controls\DAC.Components.Controls.Button.pas',
  DAC.Components.Controls.Charts in '..\Source\Controls\DAC.Components.Controls.Charts.pas',
  DAC.Components.Controls.DataGrid in '..\Source\Controls\DAC.Components.Controls.DataGrid.pas',
  DAC.Components.Controls.Feedback in '..\Source\Controls\DAC.Components.Controls.Feedback.pas',
  DAC.Components.Controls.GridContainer in '..\Source\Controls\DAC.Components.Controls.GridContainer.pas',
  DAC.Components.Controls.Loading in '..\Source\Controls\DAC.Components.Controls.Loading.pas',
  DAC.Components.Controls.Pagination in '..\Source\Controls\DAC.Components.Controls.Pagination.pas',
  DAC.Components.Controls.Progress in '..\Source\Controls\DAC.Components.Controls.Progress.pas',
  DAC.Components.Controls.ReportViewer in '..\Source\Controls\DAC.Components.Controls.ReportViewer.pas',
  DAC.Components.Controls.Selectors in '..\Source\Controls\DAC.Components.Controls.Selectors.pas',
  DAC.Components.Controls.ScrollContainer in '..\Source\Controls\DAC.Components.Controls.ScrollContainer.pas',
  DAC.Components.Controls.StatusBar in '..\Source\Controls\DAC.Components.Controls.StatusBar.pas',
  DAC.Components.Controls.SummaryCard in '..\Source\Controls\DAC.Components.Controls.SummaryCard.pas',
  DAC.Components.Controls.SystemText in '..\Source\Controls\DAC.Components.Controls.SystemText.pas',
  DAC.Components.Controls.Tabs in '..\Source\Controls\DAC.Components.Controls.Tabs.pas',
  DAC.Components.DesignSystem.ColorTokens in '..\Source\DesignSystem\DAC.Components.DesignSystem.ColorTokens.pas',
  DAC.Components.DesignSystem.IconAssets in '..\Source\DesignSystem\DAC.Components.DesignSystem.IconAssets.pas',
  Demo.Principal in '..\demo\Demo.Principal.pas' {Form1};

var
  UnexpectedException: string;
  ClickCount: Integer;

function NativePrintWindow(const AWindow: HWND; const ADC: HDC;
  const AFlags: UINT): BOOL; stdcall; external 'user32.dll' name 'PrintWindow';

type
  TInteractionProbe = class
  public
    procedure OnApplicationException(Sender: TObject; E: Exception);
    procedure OnButtonClick(Sender: TObject);
  end;

  TFormAccess = class(TForm)
  public
    procedure FocusNext(const AControl: TWinControl);
  end;

procedure Require(const ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create(AMessage);
end;

procedure PumpMessages(const AMilliseconds: Cardinal = 100);
var
  LStart: Cardinal;
begin
  LStart := GetTickCount;
  repeat
    Application.ProcessMessages;
  until Cardinal(GetTickCount - LStart) >= AMilliseconds;
end;

procedure RequireVisibleWithin(const AControl: TControl;
  const AExpected: Boolean; const ATimeout: Cardinal; const AMessage: string);
var
  LStart: Cardinal;
begin
  LStart := GetTickCount;
  repeat
    Application.ProcessMessages;
    if AControl.Visible = AExpected then
      Exit;
    Sleep(1);
  until Cardinal(GetTickCount - LStart) >= ATimeout;
  Require(AControl.Visible = AExpected, AMessage);
end;

procedure TInteractionProbe.OnApplicationException(Sender: TObject; E: Exception);
begin
  UnexpectedException := E.ClassName + ': ' + E.Message;
end;

procedure TInteractionProbe.OnButtonClick(Sender: TObject);
begin
  Inc(ClickCount);
end;

procedure TFormAccess.FocusNext(const AControl: TWinControl);
begin
  SelectNext(AControl, True, True);
end;

procedure SendKey(const AControl: TControl; const AKey: Word);
begin
  TWinControl(AControl).SetFocus;
  PumpMessages(20);
  AControl.Perform(WM_KEYDOWN, AKey, 0);
  AControl.Perform(WM_KEYUP, AKey, 0);
  PumpMessages(30);
end;

procedure RequireComponent(const AForm: TForm; const AName: string;
  const AClass: TClass);
var
  LComponent: TComponent;
begin
  LComponent := AForm.FindComponent(AName);
  Require((LComponent <> nil) and LComponent.InheritsFrom(AClass),
    AName + ' nao foi instanciado como ' + AClass.ClassName + '.');
end;

procedure RequireSvgIcon(const AKind: TDACIconKind);
var
  LSource: string;
  LDom: ISkSVGDOM;
begin
  LSource := TDACIconAssets.SvgSource(AKind, $FF1E5F2A);
  Require(LSource <> '', 'SVG ausente: ' + TDACIconAssets.Info(AKind).Name + '.');
  LDom := TSkSVGDOM.Make(LSource);
  Require(LDom <> nil, 'SVG invalido: ' + TDACIconAssets.Info(AKind).Name + '.');
end;

procedure RequireGridWithinViewport(const AGrid: TDACGridContainer;
  const AViewport: TDACScrollContainer; const AMargin: Integer);
var
  I: Integer;
  LChild: TControl;
  LViewportRect: TRect;
begin
  Require(Winapi.Windows.GetClientRect(AViewport.Handle, LViewportRect),
    'Nao foi possivel obter o viewport nativo do scroll.');
  Require((AGrid.Left >= AMargin) and
    (AGrid.Left + AGrid.Width <= LViewportRect.Right - AMargin),
    'A grade excedeu as margens do viewport.');
  for I := 0 to AGrid.ControlCount - 1 do
  begin
    LChild := AGrid.Controls[I];
    if not LChild.Visible or (LChild is TSkPaintBox) then
      Continue;
    Require((LChild.Left >= AGrid.ClientRect.Left) and
      (LChild.Left + LChild.Width <= AGrid.ClientRect.Right - 8) and
      (LChild.Top >= AGrid.ClientRect.Top) and
      (LChild.Top + LChild.Height <= AGrid.ClientRect.Bottom - 8),
      'Filho visivel da grade excedeu o viewport: ' + LChild.Name + '.');
  end;
end;

procedure RequireLongCaptionGridAtScaledWidth(const AOwner: TComponent;
  const AScalePPI: Integer);
const
  LongCaption = 'Acao longa sem truncamento para validar a grade';
var
  LFirst: TDACButton;
  LGrid: TDACGridContainer;
  LSecond: TDACButton;
  LWidth: Integer;
begin
  LGrid := TDACGridContainer.Create(AOwner);
  try
    LGrid.Parent := TWinControl(AOwner);
    LGrid.Columns := 12;
    LFirst := TDACButton.Create(LGrid);
    LFirst.Parent := LGrid;
    LFirst.Caption := LongCaption;
    LFirst.ShowIcon := True;
    LFirst.IconKind := mikSave;
    LFirst.Tag := 3;
    LSecond := TDACButton.Create(LGrid);
    LSecond.Parent := LGrid;
    LSecond.Caption := LongCaption;
    LSecond.ShowIcon := True;
    LSecond.IconKind := mikUpload;
    LSecond.Tag := 3;
    LWidth := DACScale(LFirst.MinimumContentWidth +
      (LGrid.ContentPadding * 2), AScalePPI);
    LGrid.SetBounds(8, 8, LWidth, DACScale(160, AScalePPI));
    PumpMessages(30);
    Require((LFirst.Caption = LongCaption) and
      (LFirst.Width >= LFirst.MinimumContentWidth),
      'Caption longo foi truncado na largura escalada de ' +
      IntToStr(AScalePPI) + '.');
    Require((LSecond.Caption = LongCaption) and
      (LSecond.Width >= LSecond.MinimumContentWidth),
      'Segundo caption longo foi truncado na largura escalada de ' +
      IntToStr(AScalePPI) + '.');
  finally
    LGrid.Free;
  end;
end;

procedure RequireFormWithinMonitorWorkArea(const AForm: TForm);
var
  LMonitor: TMonitor;
  LWorkArea: TRect;
begin
  LMonitor := AForm.Monitor;
  Require(LMonitor <> nil, 'Nao foi possivel localizar o monitor da Demo.');
  LWorkArea := LMonitor.WorkareaRect;
  Require((AForm.Left >= LWorkArea.Left) and (AForm.Top >= LWorkArea.Top) and
    (AForm.Left + AForm.Width <= LWorkArea.Right) and
    (AForm.Top + AForm.Height <= LWorkArea.Bottom),
    'A Demo excedeu a area util do monitor efetivo.');
end;

procedure RequireScrollViewportSurface(const AViewport: TDACScrollContainer;
  const AStage: string);
const
  SampleMargin = 12;
  ColorTolerance = 24;
var
  LClientRect: TRect;
  LDC: HDC;
  LExpected: COLORREF;
  LPixel: COLORREF;
  LSampleX: array[0..1] of Integer;
  LSampleY: array[0..2] of Integer;
  I: Integer;
  function Component(const AColor: COLORREF; const AShift: Integer): Byte;
  begin
    Result := Byte((AColor shr AShift) and $FF);
  end;
  function MatchesSurface(const AColor: COLORREF): Boolean;
  begin
    Result := (Abs(Integer(Component(AColor, 0)) -
      Integer(Component(LExpected, 0))) <= ColorTolerance) and
      (Abs(Integer(Component(AColor, 8)) -
      Integer(Component(LExpected, 8))) <= ColorTolerance) and
      (Abs(Integer(Component(AColor, 16)) -
      Integer(Component(LExpected, 16))) <= ColorTolerance);
  end;
begin
  Require(Winapi.Windows.GetClientRect(AViewport.Handle, LClientRect),
    'Nao foi possivel obter o viewport para validar a surface: ' + AStage);
  Require((LClientRect.Right > SampleMargin * 2) and
    (LClientRect.Bottom > SampleMargin * 2),
    'Viewport insuficiente para validar a surface: ' + AStage);
  LSampleY[0] := SampleMargin;
  LSampleY[1] := LClientRect.Bottom div 2;
  LSampleY[2] := LClientRect.Bottom - SampleMargin;
  LSampleX[0] := SampleMargin;
  LSampleX[1] := LClientRect.Right - SampleMargin;
  LExpected := ColorToRGB(TDACComponentColors.ToVclColor(
    TDACComponentColors.Normalize(AViewport.BackgroundColor)));
  LDC := GetDC(AViewport.Handle);
  try
    Require(LDC <> 0, 'Nao foi possivel acessar pixels do viewport: ' + AStage);
    for I := Low(LSampleY) to High(LSampleY) do
    begin
      LPixel := GetPixel(LDC, LSampleX[0], LSampleY[I]);
      Require((LPixel <> CLR_INVALID) and MatchesSurface(LPixel),
        'Faixa esquerda sem surface/token apos scroll (' + AStage + ').');
      LPixel := GetPixel(LDC, LSampleX[1], LSampleY[I]);
      Require((LPixel <> CLR_INVALID) and MatchesSurface(LPixel),
        'Faixa direita do viewport sem surface/token apos scroll (' +
        AStage + ').');
    end;
  finally
    if LDC <> 0 then
      ReleaseDC(AViewport.Handle, LDC);
  end;
end;

procedure RequireScrollChromeViewport(const AViewport: TDACScrollContainer;
  const AExpectedRange: Integer; const AStage: string);
var
  I: Integer;
  LPaintBox: TSkPaintBox;
begin
  LPaintBox := nil;
  for I := 0 to AViewport.ControlCount - 1 do
    if AViewport.Controls[I] is TSkPaintBox then
    begin
      LPaintBox := TSkPaintBox(AViewport.Controls[I]);
      Break;
    end;
  Require(LPaintBox <> nil, 'Surface Skia do scroll ausente: ' + AStage);
  Require(LPaintBox.Align = alClient,
    'Surface Skia entrou na area rolavel: ' + AStage);
  Require(AViewport.VertScrollBar.Range = AExpectedRange,
    'A surface alterou o range vertical durante o scroll: ' + AStage);
end;

procedure RequirePrintedScrollViewportSurface(const AForm: TForm;
  const AViewport: TDACScrollContainer; const AStage: string);
const
  SampleMargin = 12;
  ColorTolerance = 24;
var
  LBitmap: TBitmap;
  LClientRect: TRect;
  LExpected: COLORREF;
  LFormRect: TRect;
  LPixel: COLORREF;
  LSampleX: array[0..1] of Integer;
  LSampleY: array[0..2] of Integer;
  LViewportRect: TRect;
  I: Integer;
  function Component(const AColor: COLORREF; const AShift: Integer): Byte;
  begin
    Result := Byte((AColor shr AShift) and $FF);
  end;
  function MatchesSurface(const AColor: COLORREF): Boolean;
  begin
    Result := (Abs(Integer(Component(AColor, 0)) -
      Integer(Component(LExpected, 0))) <= ColorTolerance) and
      (Abs(Integer(Component(AColor, 8)) -
      Integer(Component(LExpected, 8))) <= ColorTolerance) and
      (Abs(Integer(Component(AColor, 16)) -
      Integer(Component(LExpected, 16))) <= ColorTolerance);
  end;
begin
  Require(Winapi.Windows.GetClientRect(AViewport.Handle, LClientRect),
    'Nao foi possivel obter o viewport para PrintWindow: ' + AStage);
  Require(Winapi.Windows.GetWindowRect(AForm.Handle, LFormRect) and
    Winapi.Windows.GetWindowRect(AViewport.Handle, LViewportRect),
    'Nao foi possivel obter bounds para PrintWindow: ' + AStage);
  LBitmap := TBitmap.Create;
  try
    LBitmap.PixelFormat := pf32bit;
    LBitmap.SetSize(LFormRect.Width, LFormRect.Height);
    Require(NativePrintWindow(AForm.Handle, LBitmap.Canvas.Handle, 0),
      'PrintWindow falhou: ' + AStage);
    LSampleX[0] := LViewportRect.Left - LFormRect.Left + SampleMargin;
    LSampleX[1] := LViewportRect.Left - LFormRect.Left +
      LClientRect.Right - SampleMargin;
    LSampleY[0] := LViewportRect.Top - LFormRect.Top + SampleMargin;
    LSampleY[1] := LViewportRect.Top - LFormRect.Top +
      LClientRect.Bottom div 2;
    LSampleY[2] := LViewportRect.Top - LFormRect.Top +
      LClientRect.Bottom - SampleMargin;
    LExpected := ColorToRGB(TDACComponentColors.ToVclColor(
      TDACComponentColors.Normalize(AViewport.BackgroundColor)));
    for I := Low(LSampleY) to High(LSampleY) do
    begin
      LPixel := ColorToRGB(LBitmap.Canvas.Pixels[LSampleX[0], LSampleY[I]]);
      Require(MatchesSurface(LPixel),
        'PrintWindow detectou vazamento na borda esquerda: ' + AStage);
      LPixel := ColorToRGB(LBitmap.Canvas.Pixels[LSampleX[1], LSampleY[I]]);
      Require(MatchesSurface(LPixel),
        'PrintWindow detectou vazamento/invasao da barra: ' + AStage);
    end;
  finally
    LBitmap.Free;
  end;
end;

procedure RequireChartBottomRightSurface(const AForm: TForm;
  const AChart: TDACChart; const AName: string);
const
  SampleOffsets: array[0..1] of Integer = (3, 10);
var
  I: Integer;
  LBitmap: TBitmap;
  LChartRect: TRect;
  LFormRect: TRect;
  LPixel: TColor;
  LRed: Byte;
  LGreen: Byte;
  LBlue: Byte;
begin
  Require(Winapi.Windows.GetWindowRect(AForm.Handle, LFormRect) and
    Winapi.Windows.GetWindowRect(AChart.Handle, LChartRect),
    'Nao foi possivel obter bounds do chart: ' + AName);
  LBitmap := TBitmap.Create;
  try
    LBitmap.PixelFormat := pf32bit;
    LBitmap.SetSize(LFormRect.Width, LFormRect.Height);
    Require(NativePrintWindow(AForm.Handle, LBitmap.Canvas.Handle, 0),
      'PrintWindow falhou no chart: ' + AName);
    for I := Low(SampleOffsets) to High(SampleOffsets) do
    begin
      LPixel := ColorToRGB(LBitmap.Canvas.Pixels[
        LChartRect.Right - LFormRect.Left - SampleOffsets[I],
        LChartRect.Bottom - LFormRect.Top - SampleOffsets[I]]);
      LRed := GetRValue(LPixel);
      LGreen := GetGValue(LPixel);
      LBlue := GetBValue(LPixel);
      Require((LRed >= 180) and (LGreen >= 180) and (LBlue >= 180),
        'Canto inferior direito do chart contem artefato escuro: ' +
        AName + '.');
    end;
  finally
    LBitmap.Free;
  end;
end;

procedure RunInteraction;
var
  LBadge: TDACBadge;
  LButton: TDACButton;
  LColumnFirst: TDACButton;
  LColumnSecond: TDACButton;
  LColumnThird: TDACButton;
  LColumnsGrid: TDACGridContainer;
  LCheck: TDACCheckBox;
  LDataSet: TClientDataSet;
  LDataSource: TDataSource;
  LGrid: TDACDataGrid;
  LModal: TDACModalDialog;
  LNavigationButton: TDACButton;
  LNavigation: TDACScrollContainer;
  LPagination: TDACPagination;
  LSlider: TDACSlider;
  LScroll: TDACScrollContainer;
  LScrollRange: Integer;
  LTabPage: TTabSheet;
  LTabs: TDACTabs;
  LToast: TDACToast;
  LTooltip: TDACTooltip;
  LWheelPosition: Integer;
  LWidthBefore: Integer;
  LProbe: TInteractionProbe;
  I: Integer;
  LExpectedRecNo: Integer;
begin
  LProbe := TInteractionProbe.Create;
  try
  RequireSvgIcon(mikSave);
  RequireSvgIcon(mikSearch);
  RequireSvgIcon(mikTrash);
  RequireSvgIcon(mikCheck);
  RequireSvgIcon(mikChevronLeft);
  RequireSvgIcon(mikChevronRight);
  RequireSvgIcon(mikChevronDown);
  RequireSvgIcon(mikSpinner);

  Require(DACScale(36, 96) = 36, 'DPI 96 invalido.');
  Require(DACScale(36, 120) = 45, 'DPI 120 invalido.');
  Require(DACScale(36, 144) = 54, 'DPI 144 invalido.');
  Require(DACScale(36, 192) = 72, 'DPI 192 invalido.');

  Application.CreateForm(TForm1, Form1);
  Form1.Show;
  PumpMessages(150);
  RequireFormWithinMonitorWorkArea(Form1);

  RequireComponent(Form1, 'GalleryTabs', TDACTabs);
  RequireComponent(Form1, 'demoEdit', TControl);
  RequireComponent(Form1, 'demoCombo', TControl);
  RequireComponent(Form1, 'demoCheck', TDACCheckBox);
  RequireComponent(Form1, 'demoSlider', TDACSlider);
  RequireComponent(Form1, 'demoSummaryCard', TDACSummaryCard);
  RequireComponent(Form1, 'demoDataGrid', TDACDataGrid);
  RequireComponent(Form1, 'demoStatusBar', TDACStatusBar);
  RequireComponent(Form1, 'demoProgress', TDACProgress);
  RequireComponent(Form1, 'demoBadge', TDACBadge);
  RequireComponent(Form1, 'demoToast', TDACToast);
  RequireComponent(Form1, 'demoTooltip', TDACTooltip);
  RequireComponent(Form1, 'demoPagination', TDACPagination);
  RequireComponent(Form1, 'demoLoading', TDACLoading);
  RequireComponent(Form1, 'demoBarChart', TDACBarChart);
  RequireComponent(Form1, 'demoReportViewer', TDACReportViewer);
  RequireComponent(Form1, 'demoNavigation', TDACScrollContainer);
  RequireComponent(Form1, 'demoNavigationTitle', TDACSystemText);
  RequireComponent(Form1, 'demoNavButtons', TDACButton);
  RequireComponent(Form1, 'demoNavCharts', TDACButton);

  LNavigationButton := Form1.FindComponent('demoNavCharts') as TDACButton;
  LNavigation := Form1.FindComponent('demoNavigation') as TDACScrollContainer;
  Require(Assigned(LNavigationButton.OnClick),
    'Navegacao interna da Demo nao recebeu acao.');
  LNavigationButton.OnClick(LNavigationButton);
  Require(Form1.GalleryTabs.ActivePage = Form1.tsCharts,
    'Menu interno nao abriu a familia Charts.');
  Require(LNavigationButton.Kind = mbkPrimary,
    'Menu interno nao refletiu a familia ativa.');
  RequireChartBottomRightSurface(Form1,
    Form1.FindComponent('demoBarChart') as TDACChart, 'bar');
  RequireChartBottomRightSurface(Form1,
    Form1.FindComponent('demoDoughnutChart') as TDACChart, 'doughnut');
  Form1.GalleryTabs.ActivePage := Form1.tsButtons;
  PumpMessages(30);

  LScroll := Form1.scrButtons;
  Require(Form1.lblButtonsSubtitle.WordWrap,
    'O subtitulo da Demo nao recebeu quebra responsiva.');
  Require(Form1.lblButtonKinds.Top >= Form1.lblButtonsSubtitle.Top +
    Form1.lblButtonsSubtitle.Height + 12,
    'A secao de variantes sobrepoe o subtitulo refluido.');
  Require(Form1.lblButtonsSubtitle.Top >= Form1.lblButtonsTitle.Top +
    Form1.lblButtonsTitle.Height + 6,
    'O subtitulo esta proximo ou sobreposto ao titulo da Demo.');
  Require(Form1.lblButtonsSubtitle.Left + Form1.lblButtonsSubtitle.Width <=
    LScroll.ClientWidth - 1,
    'O subtitulo excede o viewport fisico da Demo.');
  Require((Form1.btnKindInputAction.Caption = '') and
    Form1.btnKindInputAction.ShowHint and
    (Form1.btnKindInputAction.Hint = 'Acao de input') and
    (Form1.btnKindInputAction.Width >= Form1.btnKindInputAction.Height),
    'A acao de input precisa ser um alvo icon-only deliberado e identificado.');
  Require(LScroll.ControlAtPos(Point(Form1.lblButtonsTitle.Left,
    Form1.lblButtonsTitle.Top), False, False) =
    Form1.lblButtonsTitle,
    'A surface Skia do scroll container cobriu o primeiro filho VCL.');
  RequireGridWithinViewport(Form1.gcButtonKinds, LScroll, 24);
  RequirePrintedScrollViewportSurface(Form1, LScroll, 'padrao-topo');

  LColumnsGrid := TDACGridContainer.Create(Form1);
  LColumnsGrid.Parent := Form1;
  LColumnsGrid.SetBounds(16, 360, 360, 120);
  LColumnFirst := TDACButton.Create(LColumnsGrid);
  LColumnFirst.Parent := LColumnsGrid;
  LColumnSecond := TDACButton.Create(LColumnsGrid);
  LColumnSecond.Parent := LColumnsGrid;
  LColumnThird := TDACButton.Create(LColumnsGrid);
  LColumnThird.Parent := LColumnsGrid;
  LColumnsGrid.Columns := 1;
  PumpMessages(30);
  Require(LColumnSecond.Top > LColumnFirst.Top,
    'Columns=1 nao foi respeitado.');
  LColumnsGrid.Columns := 2;
  PumpMessages(30);
  Require((LColumnSecond.Top = LColumnFirst.Top) and
    (LColumnThird.Top > LColumnFirst.Top), 'Columns=2 nao foi respeitado.');
  LColumnsGrid.Columns := 3;
  PumpMessages(30);
  Require(LColumnThird.Top = LColumnFirst.Top,
    'Columns>=3 nao manteve tres colunas quando havia espaco.');
  LColumnsGrid.Free;
  RequireLongCaptionGridAtScaledWidth(Form1, 96);
  RequireLongCaptionGridAtScaledWidth(Form1, 144);
  RequireLongCaptionGridAtScaledWidth(Form1, 192);

  Form1.btnSplitMain.Caption :=
    'Executar acao composta com descricao completa';
  Form1.SetBounds(Form1.Left, Form1.Top, 521, 560);
  PumpMessages(50);
  Form1.SetBounds(Form1.Left, Form1.Top, 520, 560);
  PumpMessages(100);
  Require(Form1.btnKindGhost.Top > Form1.btnKindPrimary.Top,
    'A grade nao refez as colunas quando a largura ficou reduzida.');
  Require(Form1.lblButtonsSubtitle.Left + Form1.lblButtonsSubtitle.Width <=
    LScroll.ClientWidth - 1,
    'Resize deixou o subtitulo fora do viewport fisico.');
  Require(Form1.lblButtonsSubtitle.Height >
    Form1.lblButtonsSubtitle.Canvas.TextHeight('Ag'),
    'Resize estreito nao aumentou a altura do subtitulo refluido.');
  Require(Form1.lblButtonKinds.Top >= Form1.lblButtonsSubtitle.Top +
    Form1.lblButtonsSubtitle.Height + 12,
    'Resize deixou a secao 1 sobreposta ao subtitulo.');
  Require(not LNavigation.Visible,
    'Caption longa nao colapsou a navegacao no viewport estreito.');
  Require(Form1.GalleryTabs.Left = 0,
    'Galeria nao recuperou a largura da navegacao colapsada.');
  Require(Form1.btnSplitMain.Width >= Form1.btnSplitMain.MinimumContentWidth,
    'Resize truncou a acao composta de caption longa.');
  Require(Form1.btnUploadAction.Width >= Form1.btnUploadAction.MinimumContentWidth,
    'Resize truncou a acao "Enviar arquivo".');
  RequireGridWithinViewport(Form1.gcButtonKinds, LScroll, 24);
  RequireGridWithinViewport(Form1.gcButtonSizes, LScroll, 24);
  LScrollRange := LScroll.VertScrollBar.Range;
  LScroll.Perform(WM_VSCROLL, SB_TOP, 0);
  PumpMessages(80);
  RequireScrollViewportSurface(LScroll, 'topo');
  RequireScrollChromeViewport(LScroll, LScrollRange, 'topo');
  RequirePrintedScrollViewportSurface(Form1, LScroll, 'resize-topo');
  LScroll.Perform(WM_VSCROLL, SB_PAGEDOWN, 0);
  PumpMessages(80);
  RequireScrollViewportSurface(LScroll, 'meio');
  RequireScrollChromeViewport(LScroll, LScrollRange, 'meio');
  RequirePrintedScrollViewportSurface(Form1, LScroll, 'resize-meio');
  LScroll.Perform(WM_VSCROLL, SB_BOTTOM, 0);
  PumpMessages(80);
  RequireScrollViewportSurface(LScroll, 'fim');
  RequireScrollChromeViewport(LScroll, LScrollRange, 'fim');
  RequirePrintedScrollViewportSurface(Form1, LScroll, 'resize-fim');
  LScroll.Perform(WM_VSCROLL, SB_TOP, 0);
  PumpMessages(80);
  LWheelPosition := LScroll.VertScrollBar.Position;
  Form1.btnKindPrimary.Perform(WM_MOUSEWHEEL, WPARAM($FFC40000), 0);
  PumpMessages(40);
  Require(LScroll.VertScrollBar.Position = LWheelPosition,
    'Delta parcial da roda foi aplicado antes de acumular WHEEL_DELTA: ' +
    IntToStr(LWheelPosition) + ' -> ' +
    IntToStr(LScroll.VertScrollBar.Position) + '.');
  Form1.btnKindPrimary.Perform(WM_MOUSEWHEEL, WPARAM($FFC40000), 0);
  PumpMessages(80);
  Require(LScroll.VertScrollBar.Position > LWheelPosition,
    'Roda sobre filho nao deslocou o TDACScrollContainer.');
  LWheelPosition := LScroll.VertScrollBar.Position;
  LScroll.Perform(WM_MOUSEWHEEL, WPARAM($FF880000), 0);
  PumpMessages(80);
  Require(LScroll.VertScrollBar.Position > LWheelPosition,
    'Roda sobre viewport nao deslocou o TDACScrollContainer.');
  Require(Form1.HandleAllocated and Form1.Visible,
    'O scroll destruiu ou ocultou a janela principal.');

  LButton := TDACButton.Create(Form1);
  LButton.Parent := Form1;
  LButton.SetBounds(24, 24, 160, 40);
  LButton.Caption := 'Interaction button';
  LButton.BringToFront;
  LButton.OnClick := LProbe.OnButtonClick;
  SendKey(LButton, VK_RETURN);
  Require(ClickCount = 1, 'Enter nao acionou TDACButton.');
  TFormAccess(Form1).FocusNext(LButton);
  Require(Form1.ActiveControl <> nil, 'Tab nao encontrou proximo controle.');

  LCheck := TDACCheckBox.Create(Form1);
  LCheck.Parent := Form1;
  LCheck.SetBounds(24, 72, 180, 30);
  LCheck.BringToFront;
  LCheck.Checked := False;
  SendKey(LCheck, VK_SPACE);
  Require(LCheck.Checked, 'Space nao alternou TDACCheckBox.');

  LSlider := TDACSlider.Create(Form1);
  LSlider.Parent := Form1;
  LSlider.SetBounds(24, 110, 260, 36);
  LSlider.BringToFront;
  LSlider.Value := 50;
  SendKey(LSlider, VK_RIGHT);
  Require(LSlider.Value = 51, 'Seta direita nao incrementou TDACSlider.');
  SendKey(LSlider, VK_LEFT);
  Require(LSlider.Value = 50, 'Seta esquerda nao decrementou TDACSlider.');

  LTabs := Form1.FindComponent('GalleryTabs') as TDACTabs;
  LTabPage := Form1.FindComponent('tsGrid') as TTabSheet;
  LTabs.ActivePage := LTabPage;
  PumpMessages(80);

  LGrid := Form1.FindComponent('demoDataGrid') as TDACDataGrid;
  LDataSet := TClientDataSet.Create(Form1);
  LDataSource := TDataSource.Create(Form1);
  LDataSet.FieldDefs.Add('ID', ftInteger);
  LDataSet.FieldDefs.Add('STATUS', ftString, 16);
  LDataSet.FieldDefs.Add('ACTIONS', ftString, 16);
  LDataSet.CreateDataSet;
  for I := 1 to 30 do
    LDataSet.AppendRecord([I, 'Ativo', '...']);
  LDataSet.RecNo := 12;
  LDataSource.DataSet := LDataSet;
  LGrid.DataSource := LDataSource;
  LGrid.Columns.Clear;
  PumpMessages(100);
  Require(LGrid.Columns.Count = 3, 'Grid nao gerou colunas automaticas.');
  LGrid.Perform(WM_VSCROLL, SB_LINEDOWN, 0);
  PumpMessages(80);
  LExpectedRecNo := LDataSet.RecNo;
  LGrid.Redraw;
  PumpMessages(50);
  Require(LDataSet.RecNo = LExpectedRecNo,
    'A pintura apos scroll alterou o cursor do dataset.');

  LTooltip := Form1.FindComponent('demoTooltip') as TDACTooltip;
  LTooltip.TargetControl := LButton;
  LTooltip.ShowForTarget;
  RequireVisibleWithin(LTooltip, True, 500, 'Tooltip nao foi exibido.');
  PumpMessages(160);
  Require(LTooltip.Visible,
    'Tooltip programatico foi ocultado pelo rastreador sem HideTooltip.');
  LTooltip.HideTooltip;
  RequireVisibleWithin(LTooltip, False, 500, 'Tooltip nao foi ocultado.');

  LToast := Form1.FindComponent('demoToast') as TDACToast;
  LToast.TitleText := 'Interaction toast';
  LToast.MessageText := 'Feedback validado.';
  LToast.Visible := True;
  Require(LToast.Visible and (LToast.TitleText = 'Interaction toast'),
    'Toast nao respondeu ao feedback.');

  LModal := TDACModalDialog.Create(Form1);
  LModal.Parent := Form1;
  LModal.SetBounds(20, 20, 320, 180);
  LModal.Visible := True;
  SendKey(LModal, VK_ESCAPE);
  Require(not LModal.Visible, 'Escape nao fechou TDACModalDialog.');

  LPagination := Form1.FindComponent('demoPagination') as TDACPagination;
  LPagination.PageIndex := 2;
  Require((LPagination.PageIndex >= 1) and
    (LPagination.PageIndex <= LPagination.PageCount), 'Paginacao fora do limite.');

  LBadge := Form1.FindComponent('demoBadge') as TDACBadge;
  Require(LBadge.Visible, 'Badge nao esta visivel.');
  LWidthBefore := LTabs.Width;
  Form1.SetBounds(Form1.Left, Form1.Top, Form1.Width + 120, Form1.Height + 80);
  PumpMessages(100);
  Require(LTabs.Width <> LWidthBefore, 'Resize nao atualizou o layout das tabs.');
  LTabs.ActivePage := Form1.tsButtons;
  Form1.SetBounds(Form1.Left, Form1.Top, 180, 560);
  PumpMessages(100);
  Require(not LNavigation.Visible,
    'Menu lateral permaneceu visivel abaixo da propria largura.');
  Require((Form1.GalleryTabs.Left = 0) and
    (Form1.GalleryTabs.Width = Form1.ClientWidth),
    'Galeria nao recuperou o viewport quando a navegacao colapsou.');
  Require(UnexpectedException = '', 'Excecao VCL: ' + UnexpectedException);
  finally
    LProbe.Free;
  end;
end;

var
  LExitCode: Integer;
begin
  LExitCode := 0;
  Application.Initialize;
  Application.MainFormOnTaskbar := False;
  with TInteractionProbe.Create do
  try
    Application.OnException := OnApplicationException;
    try
      RunInteraction;
      Writeln('DACComponentsInteraction: PASS');
    except
      on E: Exception do
      begin
        Writeln(E.ClassName + ': ' + E.Message);
        LExitCode := 1;
      end;
    end;
  finally
    Application.OnException := nil;
    Free;
  end;
  Form1.Free;
  ExitCode := LExitCode;
end.
