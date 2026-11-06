program DACDemoStartupCurrent;

{$APPTYPE CONSOLE}
{$MINSTACKSIZE $00200000}

uses
  System.SysUtils,
  System.Types,
  System.Variants,
  Winapi.Messages,
  Winapi.Windows,
  MidasLib,
  Vcl.ComCtrls,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.StdCtrls,
  Vcl.Styles,
  Vcl.Themes,
  DAC.Components.Controls.ComboBox,
  DAC.Components.Controls.DateTimePicker,
  DAC.Components.Controls.Edit,
  DAC.Components.Controls.NumericEdit,
  DAC.Components.DesignSystem.IconAssets,
  DAC.Components.DesignSystem.ComponentStyle,
  DAC.Components.DesignSystem.ColorTokens,
  DAC.Components.DesignSystem.Theme,
  Vcl.Forms,
  Demo.Principal in '..\demo\Demo.Principal.pas' {Form1};

{$R '..\demo\Demo.res'}

procedure Require(const ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create(AMessage);
end;

procedure VerifyTreeExampleTheme(Mode: TDACThemeMode);
begin
  Require(Form1.TreeDemo.SearchLabel.Font.Height = Form1.TreeDemo.Tree.Font.Height, 'Gallery overwrote search label font.');
  Require(Form1.TreeDemo.Status.Font.Height = Form1.TreeDemo.Tree.Font.Height, 'Gallery overwrote status font.');
  Require(Form1.TreeDemo.Instructions.Font.Height = Form1.TreeDemo.Tree.Font.Height, 'Gallery overwrote instructions font.');
  Require(Form1.TreeDemo.Header.Color = TDACComponentColors.ToVclColor(
    TDACComponentStyle.Resolve(Mode).Tokens.Controls.InputBackground), 'Header did not follow theme surface.');
  Require(Form1.TreeDemo.Status.Font.Color = TDACComponentColors.ToVclColor(
    TDACComponentStyle.Resolve(Mode).Tokens.Controls.InputText), 'Status did not follow theme text contrast.');
end;

procedure VerifyPaintedError(const AField: TDACEdit; const AMessage: string);
var
  I: Integer;
  LBitmap: TBitmap;
  LDC: HDC;
  LDivider: TRect;
  LSupport: TLabel;
  LSuffix: TControl;

  function HasRedInk(const ABounds: TRect): Boolean;
  var
    X, Y: Integer;
    LPixel: COLORREF;
  begin
    for Y := ABounds.Top to ABounds.Bottom - 1 do
      for X := ABounds.Left to ABounds.Right - 1 do
      begin
        LPixel := ColorToRGB(LBitmap.Canvas.Pixels[X, Y]);
        if (GetRValue(LPixel) > GetGValue(LPixel) + 40) and
          (GetRValue(LPixel) > GetBValue(LPixel) + 40) then
          Exit(True);
      end;
    Result := False;
  end;

  function HasRedText(const AControl: TControl): Boolean;
  var
    LBounds: TRect;
  begin
    LBounds := AControl.BoundsRect;
    InflateRect(LBounds, -2, -2);
    Result := HasRedInk(LBounds);
  end;

begin
  (Form1.FindComponent('scrInputs') as TScrollingWinControl).ScrollInView(AField);
  Application.ProcessMessages;
  LSupport := nil;
  for I := 0 to AField.ControlCount - 1 do
    if (AField.Controls[I] is TLabel) and
      (TLabel(AField.Controls[I]).Caption = AMessage) then
      LSupport := TLabel(AField.Controls[I]);
  Require((LSupport <> nil) and LSupport.Visible,
    'Mensagem de erro ausente em ' + AField.Name);

  LBitmap := TBitmap.Create;
  try
    LBitmap.SetSize(AField.Width, AField.Height);
    RedrawWindow(AField.Handle, nil, 0,
      RDW_INVALIDATE or RDW_UPDATENOW or RDW_ALLCHILDREN);
    LDC := GetDC(AField.Handle);
    try
      Require(BitBlt(LBitmap.Canvas.Handle, 0, 0, LBitmap.Width,
        LBitmap.Height, LDC, 0, 0, SRCCOPY), 'Falha ao capturar ' + AField.Name);
    finally
      ReleaseDC(AField.Handle, LDC);
    end;
    Require(HasRedText(LSupport), 'Mensagem pintada sem vermelho em ' + AField.Name);
    Require(HasRedText(AField.NativeLabel), 'Label pintado sem vermelho em ' + AField.Name);
    if AField is TDACNumericEdit then
    begin
      LSuffix := TDACNumericEdit(AField).SuffixControl;
      Require(HasRedText(LSuffix), 'Sufixo pintado sem vermelho em ' + AField.Name);
      LDivider := LSuffix.BoundsRect;
      InflateRect(LDivider, 0, -2);
      if TDACNumericEdit(AField).SuffixPosition = nspLeft then
        LDivider.Left := LDivider.Right
      else
        Dec(LDivider.Left);
      LDivider.Right := LDivider.Left + 1;
      Require(HasRedInk(LDivider), 'Divisor vermelho ausente entre o sufixo e o valor.');
    end;
  finally
    LBitmap.Free;
  end;
end;

procedure VerifyInputExamples;
var
  I: Integer;
  LChild: TControl;
  LEditGrid: TControl;
  LEditError: TDACEdit;
  LEditKinds: set of TDACEditKind;
  LLeftNumber: TDACNumericEdit;
  LNumber: TDACNumericEdit;
  LNumberGrid: TControl;
  LNumberKinds: set of TDACNumericKind;
  LNumberMasks: set of TDACNumericMaskKind;
  LStatesGrid: TControl;
begin
  Form1.GalleryTabs.ActivePage := Form1.tsInputs;
  Application.ProcessMessages;
  LEditGrid := Form1.FindComponent('gcInputEditKinds') as TControl;
  LNumberGrid := Form1.FindComponent('gcInputNumericKinds') as TControl;
  LStatesGrid := Form1.FindComponent('gcInputStates') as TControl;
  Require((LEditGrid <> nil) and (LNumberGrid <> nil) and (LStatesGrid <> nil) and
    (LEditGrid.BoundsRect.Bottom <= LNumberGrid.Top) and
    (LNumberGrid.BoundsRect.Bottom <= LStatesGrid.Top),
    'Secoes de inputs ausentes, fora de ordem ou sobrepostas.');
  LEditKinds := [];
  LNumberKinds := [];
  LNumberMasks := [];
  for I := 0 to Form1.ComponentCount - 1 do
  begin
    if not (Form1.Components[I] is TControl) then
      Continue;
    LChild := TControl(Form1.Components[I]);
    if not Form1.tsInputs.ContainsControl(LChild) then
      Continue;
    if LChild.ClassType = TDACEdit then
      Include(LEditKinds, TDACEdit(LChild).EditKind)
    else if LChild is TDACNumericEdit then
    begin
      LNumber := TDACNumericEdit(LChild);
      Include(LNumberKinds, LNumber.NumericKind);
      Include(LNumberMasks, LNumber.NumericMask);
    end;
  end;
  Require(LEditKinds = [Low(TDACEditKind)..High(TDACEditKind)],
    'Galeria nao demonstrou todos os tipos de TDACEdit.');
  Require((LNumberKinds = [dnkNumber, dnkCurrency, dnkWeight]) and
    (LNumberMasks = [nmkInteger, nmkDecimal]),
    'Galeria nao demonstrou todas as modalidades de TDACNumericEdit.');

  LLeftNumber := Form1.FindComponent('demoNumericCurrencyLeft') as TDACNumericEdit;
  Require((LLeftNumber <> nil) and (LLeftNumber.SuffixPosition = nspLeft) and
    (LLeftNumber.SuffixText = #163) and (LLeftNumber.Value = 5) and
    (Pos(#163, LLeftNumber.Text) = 0) and LLeftNumber.SuffixControl.Visible and
    (LLeftNumber.SuffixControl.BoundsRect.Right <= LLeftNumber.EditControl.Left),
    'Exemplo de moeda perdeu o simbolo fixo a esquerda.');

  LNumber := Form1.FindComponent('demoNumericPercentError') as TDACNumericEdit;
  Require((LNumber <> nil) and LNumber.SuffixControl.Visible and
    (LNumber.SuffixText = '%') and (LNumber.Value = 125) and
    (LNumber.EditControl.BoundsRect.Right <= LNumber.SuffixControl.Left),
    'Exemplo numerico de erro perdeu o valor ou o sufixo fixo.');
  Require((LNumber.Status = mesNormal) and (LNumber.ErrorText = ''),
    'Exemplo numerico exibiu um erro antes da validacao.');
  LEditError := Form1.FindComponent('demoEditError') as TDACEdit;
  LNumber.SetFocus;
  LEditError.SetFocus;
  Application.ProcessMessages;
  Require(LNumber.EditControl.Focused, 'Percentual invalido deixou perder o foco.');
  Require((LNumber.Status = mesDanger) and (LNumber.ErrorText <> '') and
    (LNumber.HelperText <> '') and (LNumber.NativeLabel.Font.Color =
    TDACComponentColors.ToVclColor(TDACComponentStyle.ResolveForSurface(
      LNumber, LNumber.ThemeMode).Tokens.Controls.FieldDangerText)),
    'Exemplo numerico deve destacar o label e usar o texto de ajuda no erro.');

  VerifyPaintedError(LEditError, LEditError.ErrorText);
  VerifyPaintedError(LNumber, LNumber.ErrorText);
  LNumber.SuffixPosition := nspLeft;
  VerifyPaintedError(LNumber, LNumber.ErrorText);
  TDACThemeManager.SetApplicationMode(dtmLight);
  Application.ProcessMessages;
  VerifyPaintedError(LEditError, LEditError.ErrorText);
  VerifyPaintedError(LNumber, LNumber.ErrorText);
  LNumber.SuffixPosition := nspRight;
  VerifyPaintedError(LNumber, LNumber.ErrorText);
  TDACThemeManager.SetApplicationMode(dtmDark);

  LNumber.EditControl.SelectAll;
  SendMessage(LNumber.EditControl.Handle, WM_CHAR, Ord('5'), 1);
  LEditError.SetFocus;
  Application.ProcessMessages;
  Require((LNumber.Value = 5) and (LNumber.Status = mesNormal) and
    LEditError.EditControl.Focused, 'Corrigir o percentual nao liberou o foco.');

  Form1.GalleryTabs.ActivePage := Form1.tsSelectors;
  Application.ProcessMessages;
  Require((Form1.FindComponent('demoComboEditable') as TDACComboBox).Style =
    csDropDown, 'Galeria perdeu o combo editavel.');
  Require((Form1.FindComponent('demoTime') as TDACDateTimePicker).PickerKind =
    dtkTime, 'Galeria perdeu o seletor de hora.');
end;

begin
  try
    Application.Initialize;
    Require(TStyleManager.TrySetStyle('Windows10', False) and
      TStyleManager.IsCustomStyleActive, 'Estilo Windows10 do demo nao carregou.');
    Form1 := TForm1.Create(nil);
    try
      Form1.Show;
      Application.ProcessMessages;
      Require(Form1.HandleAllocated, 'Demo nao criou a janela principal.');
      Require(Form1.GalleryTabs <> nil, 'Demo nao criou a galeria.');
      Require(Form1.GalleryTabs.PageCount > 0, 'Demo iniciou sem paginas.');
      Require((Form1.btnIconFileJson.IconKind = mikFileJson) and
        (Form1.btnIconFolderOpen.IconKind = mikFolderOpen) and
        (Form1.btnIconDatabase.IconKind = mikDatabase), 'Novos icones nao carregaram do DFM real.');
      Form1.GalleryTabs.ActiveIndex := Form1.tsButtons.PageIndex;
      Application.ProcessMessages;
      Require((Form1.btnIconFileJson.Parent = Form1.gcButtonIcons) and
        (Form1.btnIconFolderOpen.Parent = Form1.gcButtonIcons) and
        (Form1.btnIconDatabase.Parent = Form1.gcButtonIcons), 'Exemplos fora da secao de icones.');
      Require(Form1.btnIconDatabase.Width >= Form1.btnIconDatabase.MinimumContentWidth,
        'Exemplo com icone nao recebeu a largura minima de conteudo.');
      VerifyInputExamples;
      Require(Form1.tsDBTreeView <> nil, 'Official DBTreeView gallery page missing.');
      Require(Form1.DBTreeDemo <> nil, 'Official gallery did not create the data-aware example.');
      Require(Form1.DBTreeDemo.Parent = Form1.tsDBTreeView, 'Tree example is outside official gallery.');
      Require(Form1.DBTreeDemo.Tree.IsDataValid, 'Official tree dataset was not loaded.');
      Form1.GalleryTabs.ActivePage := Form1.tsDBTreeView;
      Application.ProcessMessages;
      Require(Form1.DBTreeDemo.Tree.Showing, 'Official tree page is not visible.');
      Require(Form1.DBTreeDemo.Tree.ShowHeader, 'Official DB example header default.');
      Form1.DBTreeDemo.ShowHeaderBox.Checked := False;
      Require(not Form1.DBTreeDemo.Tree.ShowHeader, 'DB example header checkbox not connected.');
      Form1.DBTreeDemo.ShowHeaderBox.Checked := True;
      Require(Form1.DBTreeDemo.Tree.TrySetChecked('011', True), 'Official example check failed.');
      Require(Length(Form1.DBTreeDemo.Tree.CheckedKeys) = 1, 'Official example did not preserve marking.');
      Require(not Form1.DBTreeDemo.Tree.TrySetChecked('001', True), 'Official example allowed a blocked group.');
      Form1.DBTreeDemo.Search.Text := 'produtos';
      Require(Form1.DBTreeDemo.Tree.Model.Visible.Count = 3, 'Official search did not preserve ancestors.');
      Form1.DBTreeDemo.Search.Clear;
      Require(Form1.tsTreeView <> nil, 'Plain TreeView page missing.');
      Require(Form1.TreeDemo <> nil, 'Plain TreeView example missing.');
      Form1.GalleryTabs.ActivePage := Form1.tsTreeView;
      Application.ProcessMessages;
      Require(Form1.TreeDemo.Tree.Showing and Form1.TreeDemo.Tree.IsDataValid, 'Plain TreeView not visible or invalid.');
      Require(Form1.TreeDemo.Tree.ShowHeader, 'Official plain example header default.');
      Form1.TreeDemo.ShowHeaderBox.Checked := False;
      Require(not Form1.TreeDemo.Tree.ShowHeader, 'Plain example header checkbox not connected.');
      Form1.TreeDemo.ShowHeaderBox.Checked := True;
      Require(Form1.TreeDemo.Tree.SelectedObject <> nil, 'Object mapping was not connected.');
      Require(Form1.TreeDemo.Tree.TrySetChecked('011', True), 'Plain tree checking failed.');
      Form1.TreeDemo.ManualButtonClick(nil);
      Require(Form1.TreeDemo.Tree.Items.Count > 0, 'Manual tree items missing.');
      Form1.TreeDemo.LoadObjectsButtonClick(nil);
      Require(Form1.TreeDemo.Tree.SelectedObject <> nil, 'Object reload missing.');
      VerifyTreeExampleTheme(dtmDark);
      Form1.GalleryTabs.ActivePage := Form1.tsButtons;
      Application.ProcessMessages;
      Form1.GalleryTabs.ActivePage := Form1.tsTreeView;
      Application.ProcessMessages;
      VerifyTreeExampleTheme(dtmDark);
      TDACThemeManager.SetApplicationMode(dtmLight);
      Application.ProcessMessages;
      VerifyTreeExampleTheme(dtmLight);
      TDACThemeManager.SetApplicationMode(dtmDark);
      Application.ProcessMessages;
      VerifyTreeExampleTheme(dtmDark);
      Form1.Hide;
      Application.ProcessMessages;
    finally
      Form1.Free;
      Form1 := nil;
    end;
    Writeln('DACDemoStartup: PASS');
    ExitCode := 0;
  except
    on E: Exception do
    begin
      Writeln('DACDemoStartup: FAIL: ', E.ClassName, ': ', E.Message);
      ExitCode := 1;
    end;
  end;
end.
