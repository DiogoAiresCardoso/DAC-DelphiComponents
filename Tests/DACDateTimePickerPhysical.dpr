program DACDateTimePickerPhysical;

{$APPTYPE CONSOLE}
{$MINSTACKSIZE $00200000}

uses
  System.Classes,
  System.DateUtils,
  System.Math,
  System.Skia,
  System.SysUtils,
  System.Types,
  Winapi.CommCtrl,
  Winapi.Messages,
  Winapi.Windows,
  Vcl.ComCtrls,
  Vcl.Controls,
  Vcl.ExtCtrls,
  Vcl.Forms,
  Vcl.Graphics,
  Vcl.Skia,
  Vcl.StdCtrls,
  DAC.Components.Controls.Container,
  DAC.Components.Controls.DateTimePicker,
  DAC.Components.Controls.DateTimePickerPopup,
  DAC.Components.DesignSystem.ComponentStyle,
  DAC.Components.DesignSystem.ControlTokens,
  DAC.Components.DesignSystem.Theme;

type
  TDACDateTimePickerAccess = class(TDACDateTimePicker)
  public
    procedure EnterDesignPreview;
    procedure ExitDesignPreview;
    procedure ForceLoaded;
    procedure ForceRecreateWnd;
    procedure SetDisplayNull(const AValue: Boolean);
  end;

  TChangeProbe = class
  private
    FCount: Integer;
  public
    procedure Changed(Sender: TObject);
    procedure ChangedAndRefresh(Sender: TObject);
    property Count: Integer read FCount;
  end;

  TModalExercise = class
  private
    FDate: TDACDateTimePicker;
    FError: string;
    FForm: TForm;
    FProbe: TChangeProbe;
    procedure Execute(Sender: TObject);
    procedure Timeout(Sender: TObject);
  public
    constructor Create(const AForm: TForm; const ADate: TDACDateTimePicker;
      const AProbe: TChangeProbe);
    property ErrorText: string read FError;
  end;

procedure TDACDateTimePickerAccess.EnterDesignPreview;
begin
  SetDesigning(True, True);
  Redraw;
end;

procedure TDACDateTimePickerAccess.ExitDesignPreview;
begin
  SetDesigning(False, True);
  Redraw;
end;

procedure TDACDateTimePickerAccess.ForceLoaded;
begin
  Loaded;
end;

procedure TDACDateTimePickerAccess.ForceRecreateWnd;
begin
  RecreateWnd;
end;

procedure TDACDateTimePickerAccess.SetDisplayNull(const AValue: Boolean);
begin
  SetBindingDisplayNull(AValue);
end;

procedure TChangeProbe.Changed(Sender: TObject);
begin
  Inc(FCount);
end;

procedure TChangeProbe.ChangedAndRefresh(Sender: TObject);
begin
  Changed(Sender);
  { Reproduce a consumer writing the accepted value back to the editor. }
  TDACDateTimePicker(Sender).DateTime := TDACDateTimePicker(Sender).DateTime;
end;

procedure Require(const ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create(AMessage);
end;

procedure TraceStage(const AText: string);
begin
  Writeln('[RUN] ' + AText);
  Flush(Output);
end;

procedure PumpMessages(const AMilliseconds: Cardinal = 20);
var
  LStarted: Cardinal;
begin
  LStarted := GetTickCount;
  repeat
    Application.ProcessMessages;
    Sleep(1);
  until GetTickCount - LStarted >= AMilliseconds;
end;

procedure PhysicalWindowClick(const AHandle: HWND; const X, Y: Integer);
begin
  Require((AHandle <> 0) and IsWindow(AHandle),
    'Clique fisico recebeu HWND invalido.');
  SendMessage(AHandle, WM_LBUTTONDOWN, MK_LBUTTON, MakeLParam(X, Y));
  SendMessage(AHandle, WM_LBUTTONUP, 0, MakeLParam(X, Y));
  PumpMessages;
end;

procedure PhysicalWindowKey(const AHandle: HWND; const AKey: Word);
begin
  Require((AHandle <> 0) and IsWindow(AHandle),
    'Tecla fisica recebeu HWND invalido.');
  SendMessage(AHandle, WM_KEYDOWN, AKey, 0);
  SendMessage(AHandle, WM_KEYUP, AKey, 0);
  PumpMessages;
end;

procedure PhysicalQueuedKey(const AHandle: HWND; const AKey: Word);
begin
  Require((AHandle <> 0) and IsWindow(AHandle),
    'Tecla enfileirada recebeu HWND invalido.');
  Require(PostMessage(AHandle, WM_KEYDOWN, AKey, 0),
    'Nao foi possivel enfileirar WM_KEYDOWN.');
  Require(PostMessage(AHandle, WM_KEYUP, AKey, 0),
    'Nao foi possivel enfileirar WM_KEYUP.');
  PumpMessages(40);
end;

function NativeWindowText(const AHandle: HWND): string;
var
  LBuffer: array[0..255] of Char;
begin
  FillChar(LBuffer, SizeOf(LBuffer), 0);
  GetWindowText(AHandle, LBuffer, Length(LBuffer));
  Result := string(LBuffer);
end;

function NativeTextPixelsVisible(const AHandle: HWND): Boolean;
var
  LBackground: COLORREF;
  LBitmap: TBitmap;
  LColor: COLORREF;
  LDC: HDC;
  LDifference: Integer;
  LHeight: Integer;
  LInkPixels: Integer;
  LRect: TRect;
  LWidth: Integer;
  X: Integer;
  Y: Integer;
begin
  Result := False;
  if (AHandle = 0) or not IsWindowVisible(AHandle) then
    Exit;

  GetClientRect(AHandle, LRect);
  LWidth := LRect.Right - LRect.Left;
  LHeight := LRect.Bottom - LRect.Top;
  if (LWidth < 12) or (LHeight < 8) then
    Exit;

  UpdateWindow(AHandle);
  LDC := GetDC(AHandle);
  if LDC = 0 then
    Exit;
  LBitmap := TBitmap.Create;
  try
    LBitmap.PixelFormat := pf32bit;
    LBitmap.SetSize(LWidth, LHeight);
    BitBlt(LBitmap.Canvas.Handle, 0, 0, LWidth, LHeight, LDC, 0, 0,
      SRCCOPY);
    LBackground := GetPixel(LBitmap.Canvas.Handle, LWidth div 2,
      LHeight div 2);
    LInkPixels := 0;
    for Y := 2 to LHeight - 3 do
      for X := 4 to Min((LWidth * 3) div 5, LWidth - 5) do
      begin
        LColor := GetPixel(LBitmap.Canvas.Handle, X, Y);
        if (LColor = CLR_INVALID) or (LBackground = CLR_INVALID) then
          Continue;
        LDifference := Abs(GetRValue(LColor) - GetRValue(LBackground)) +
          Abs(GetGValue(LColor) - GetGValue(LBackground)) +
          Abs(GetBValue(LColor) - GetBValue(LBackground));
        if LDifference > 36 then
        begin
          Inc(LInkPixels);
          if LInkPixels >= 8 then
            Exit(True);
        end;
      end;
  finally
    LBitmap.Free;
    ReleaseDC(AHandle, LDC);
  end;
end;

function NativeWindowClass(const AHandle: HWND): string;
var
  LBuffer: array[0..127] of Char;
begin
  FillChar(LBuffer, SizeOf(LBuffer), 0);
  GetClassName(AHandle, LBuffer, Length(LBuffer));
  Result := string(LBuffer);
end;

function CountChildWindowsByClass(const AParent: HWND;
  const AClassName: string): Integer;
var
  LBuffer: array[0..127] of Char;
  LChild: HWND;
begin
  Result := 0;
  LChild := GetWindow(AParent, GW_CHILD);
  while LChild <> 0 do
  begin
    FillChar(LBuffer, SizeOf(LBuffer), 0);
    GetClassName(LChild, LBuffer, Length(LBuffer));
    if SameText(string(LBuffer), AClassName) then
      Inc(Result);
    LChild := GetWindow(LChild, GW_HWNDNEXT);
  end;
end;

function FindPopup(const APicker: TDACDateTimePicker): TDACDateTimePickerPopup;
var
  I: Integer;
begin
  Result := nil;
  for I := 0 to APicker.ComponentCount - 1 do
    if APicker.Components[I] is TDACDateTimePickerPopup then
      Exit(TDACDateTimePickerPopup(APicker.Components[I]));
end;

function FooterPoint(const APopup: TDACDateTimePickerPopup;
  const AAction: Integer): TPoint;
var
  LControls: TDACControlTokens;
  LFooterLeft: Single;
  LFooterRight: Single;
  LLeft: Single;
  LRight: Single;
begin
  LControls := TDACComponentStyle.Resolve(
    TDACThemeManager.ApplicationMode).Tokens.Controls;
  LFooterLeft := LControls.DateTimePopupInset;
  LFooterRight := APopup.Width - LControls.DateTimePopupInset;
  case AAction of
    0:
      begin
        LLeft := LFooterLeft;
        LRight := LLeft + LControls.DateTimePopupFooterActionWidth;
      end;
    1:
      begin
        LLeft := LFooterLeft + LControls.DateTimePopupFooterActionWidth +
          LControls.DateTimePopupFooterActionGap;
        LRight := LLeft + LControls.DateTimePopupFooterActionWidth;
      end;
  else
    begin
      LRight := LFooterRight;
      LLeft := LRight - LControls.DateTimePopupFooterActionWidth;
    end;
  end;
  Result := Point(Round((LLeft + LRight) / 2),
    Round(APopup.Height - LControls.DateTimePopupInset -
      (LControls.DateTimePopupFooterHeight / 2)));
end;

function HeaderPoint(const APopup: TDACDateTimePickerPopup;
  const AAction: Integer): TPoint;
var
  LControls: TDACControlTokens;
  LLeft: Single;
  LSize: Single;
begin
  LControls := TDACComponentStyle.Resolve(
    TDACThemeManager.ApplicationMode).Tokens.Controls;
  LSize := LControls.DateTimePopupNavigationSize;
  case AAction of
    0: LLeft := LControls.DateTimePopupInset;
    1: LLeft := LControls.DateTimePopupInset + LSize;
    2: LLeft := APopup.Width - LControls.DateTimePopupInset - (LSize * 2);
  else
    LLeft := APopup.Width - LControls.DateTimePopupInset - LSize;
  end;
  Result := Point(Round(LLeft + (LSize / 2)),
    Round(LControls.DateTimePopupInset + (LSize / 2)));
end;

function DayPoint(const APopup: TDACDateTimePickerPopup;
  const ADay: Integer): TPoint;
var
  LCellWidth: Integer;
  LCol: Integer;
  LControls: TDACControlTokens;
  LFirstColumn: Integer;
  LRow: Integer;
begin
  LControls := TDACComponentStyle.Resolve(
    TDACThemeManager.ApplicationMode).Tokens.Controls;
  LCellWidth := Round((APopup.Width -
    (LControls.DateTimePopupInset * 2)) /
    LControls.DateTimePopupWeekColumns);
  LFirstColumn := DayOfTheWeek(StartOfTheMonth(APopup.DisplayMonth)) - 1;
  LCol := (LFirstColumn + ADay - 1) mod
    LControls.DateTimePopupWeekColumns;
  LRow := (LFirstColumn + ADay - 1) div
    LControls.DateTimePopupWeekColumns;
  Result.X := Round(LControls.DateTimePopupInset) +
    (LCol * LCellWidth) + (LCellWidth div 2);
  Result.Y := Round(LControls.DateTimePopupHeaderHeight +
    LControls.DateTimePopupWeekHeaderHeight +
    LControls.DateTimePopupCalendarTopGap) +
    (LRow * Round(LControls.DateTimePopupCalendarCellHeight)) +
    (Round(LControls.DateTimePopupCalendarCellHeight) div 2);
end;

constructor TModalExercise.Create(const AForm: TForm;
  const ADate: TDACDateTimePicker; const AProbe: TChangeProbe);
begin
  inherited Create;
  FForm := AForm;
  FDate := ADate;
  FProbe := AProbe;
end;

procedure TModalExercise.Execute(Sender: TObject);
var
  LPoint: TPoint;
  LPopup: TDACDateTimePickerPopup;
begin
  if Sender is TTimer then
    TTimer(Sender).Enabled := False;
  try
    PumpMessages(40);
    PhysicalWindowClick(FDate.PickerControl.Handle,
      FDate.PickerControl.Width div 2, FDate.PickerControl.Height div 2);
    Require(FDate.PickerControl.Focused,
      'Formulario modal nao focou o picker por clique fisico.');
    FDate.OpenPopup;
    LPopup := FindPopup(FDate);
    Require((LPopup <> nil) and LPopup.Visible,
      'Formulario modal nao abriu o popup.');
    LPoint := DayPoint(LPopup, 13);
    PhysicalWindowClick(LPopup.Handle, LPoint.X, LPoint.Y);
    LPoint := FooterPoint(LPopup, 2);
    PhysicalWindowClick(LPopup.Handle, LPoint.X, LPoint.Y);
    Require((DayOf(FDate.DateTime) = 13) and (FProbe.Count = 1),
      'Formulario modal nao aplicou dia/OnChange por clique fisico.');
  except
    on E: Exception do
      FError := E.ClassName + ': ' + E.Message;
  end;
  FForm.ModalResult := mrOk;
end;

procedure RequireEditActionComposition(const ADate: TDACDateTimePickerAccess;
  const AContext: string);
var
  LClassName: array[0..63] of Char;
  LHandle: HWND;
begin
  LHandle := ADate.PickerControl.Handle;
  Require((LHandle <> 0) and IsWindow(LHandle),
    AContext + ': HWND do TMaskEdit invalido.');
  FillChar(LClassName, SizeOf(LClassName), 0);
  GetClassName(LHandle, LClassName, Length(LClassName));
  Require(not SameText(LClassName, 'SysDateTimePick32'),
    AContext + ': a arquitetura antiga SysDateTimePick32 ainda foi criada.');
  Require(ADate.PickerControl.BorderStyle = bsNone,
    AContext + ': TMaskEdit reintroduziu uma borda nativa.');
  Require(ADate.PickerControl.Parent = ADate,
    AContext + ': TMaskEdit nao pertence diretamente ao campo DAC.');
  Require((ADate.ActionButton <> nil) and
    (ADate.ActionButton.Parent = ADate) and
    (ADate.ActionButton.Left >= ADate.PickerControl.BoundsRect.Right),
    AContext + ': botao de calendario nao ocupa uma caixa separada do texto.');
  Require(ADate.ActionButton.BoundsRect.Right <= ADate.Width,
    AContext + ': caixa de acao ultrapassou o chrome do campo.');
end;

procedure TModalExercise.Timeout(Sender: TObject);
begin
  if Sender is TTimer then
    TTimer(Sender).Enabled := False;
  if FError = '' then
    FError := 'Timeout aguardando o cenario modal do DateTimePicker.';
  FForm.ModalResult := mrAbort;
end;

procedure RunModalScenario;
var
  LContainer: TDACContainer;
  LDate: TDACDateTimePicker;
  LExercise: TModalExercise;
  LForm: TForm;
  LProbe: TChangeProbe;
  LTimer: TTimer;
  LTimeoutTimer: TTimer;
  LModalResult: Integer;
begin
  TraceStage('formulario modal');
  LForm := TForm.Create(nil);
  LProbe := TChangeProbe.Create;
  try
    LForm.SetBounds(160, 160, 420, 180);
    LContainer := TDACContainer.Create(LForm);
    LContainer.Parent := LForm;
    LContainer.TabStop := False;
    LContainer.Align := alClient;
    LDate := TDACDateTimePicker.Create(LForm);
    LDate.Parent := LContainer;
    LDate.SetBounds(24, 32, 280, 64);
    LDate.DateTime := EncodeDate(2026, 8, 12);
    LDate.OnChange := LProbe.Changed;
    LExercise := TModalExercise.Create(LForm, LDate, LProbe);
    LTimer := nil;
    LTimeoutTimer := nil;
    try
      LTimer := TTimer.Create(LForm);
      LTimer.Enabled := False;
      LTimer.Interval := 30;
      LTimer.OnTimer := LExercise.Execute;
      LTimer.Enabled := True;
      LTimeoutTimer := TTimer.Create(LForm);
      LTimeoutTimer.Enabled := False;
      LTimeoutTimer.Interval := 5000;
      LTimeoutTimer.OnTimer := LExercise.Timeout;
      LTimeoutTimer.Enabled := True;
      LModalResult := LForm.ShowModal;
      Require(LExercise.ErrorText = '', LExercise.ErrorText);
      Require(LModalResult = mrOk,
        'Formulario modal nao encerrou pelo controlador fisico.');
    finally
      if LTimer <> nil then
        LTimer.OnTimer := nil;
      if LTimeoutTimer <> nil then
        LTimeoutTimer.OnTimer := nil;
      LExercise.Free;
    end;
  finally
    LForm.Free;
    LProbe.Free;
    PumpMessages;
  end;
end;

procedure RunValuePropagationScenario;
var
  LAssigned: TDateTime;
  LDate: TDACDateTimePickerAccess;
  LForm: TForm;
  LProbe: TChangeProbe;
begin
  TraceStage('propagacao de valor');
  LForm := TForm.Create(nil);
  LProbe := TChangeProbe.Create;
  LDate := TDACDateTimePickerAccess.Create(nil);
  try
    LAssigned := EncodeDate(2026, 8, 26) + EncodeTime(14, 35, 0, 0);
    LDate.FormatString := 'dd/MM/yyyy HH:mm';
    LDate.DateTime := LAssigned;
    Require(SameValue(LDate.DateTime, LAssigned),
      'DateTime atribuido antes de Parent nao foi preservado pelo componente.');
    Require(not LDate.HandleAllocated and
      not LDate.PickerControl.HandleAllocated,
      'Atribuicao sem Parent criou HWND prematuramente.');

    TraceStage('propagacao: preview de design');
    LDate.EnterDesignPreview;
    LDate.Redraw;
    Require(LDate.DesignValueLabel <> nil,
      'Preview nativo de design-time nao foi criado.');
    Require(LDate.DesignValueLabel.Caption =
      FormatDateTime(LDate.FormatString, LAssigned),
      'Preview de design-time nao acompanhou DateTime.');
    Require(LDate.DesignValueLabel.Visible,
      'Preview de design-time permaneceu oculto no Form Designer.');
    Require(not LDate.PickerControl.HandleAllocated,
      'Preview de design-time criou HWND do TMaskEdit prematuramente.');

    LDate.PickerKind := dtkTime;
    LDate.FormatString := 'HH:mm';
    Require(LDate.DesignValueLabel.Caption = FormatDateTime('HH:mm', LAssigned),
      'Preview nao acompanhou PickerKind/FormatString.');
    LDate.SetDisplayNull(True);
    Require(LDate.DesignValueLabel.Caption = '',
      'Preview de valor nulo deveria permanecer vazio.');
    LDate.DateTime := LAssigned;
    Require(LDate.DesignValueLabel.Caption = FormatDateTime('HH:mm', LAssigned),
      'Preview nao retornou ao valor valido depois do estado nulo.');

    { The runtime recreation assertion exercises the date HWND. The dedicated
      physical scenario below covers dtkTime interaction and acceptance. }
    LDate.PickerKind := dtkDate;
    LDate.FormatString := 'dd/MM/yyyy HH:mm';
    LDate.ExitDesignPreview;
    TraceStage('propagacao: anexar e mostrar runtime');
    LDate.Parent := LForm;
    LDate.SetBounds(16, 16, 280, 64);
    LDate.OnChange := LProbe.Changed;
    LDate.ForceLoaded;
    Require(SameValue(LDate.DateTime, LAssigned),
      'Loaded descartou o DateTime autoritativo.');
    LForm.Show;
    PumpMessages(60);
    Require(LDate.PickerControl.HandleAllocated and
      not LDate.NativePresentationPending,
      'Apresentacao nativa pendente nao foi aplicada apos CreateWnd.');
    Require(NativeWindowText(LDate.PickerControl.Handle) =
      FormatDateTime(LDate.FormatString, LAssigned),
      'TMaskEdit nao recebeu o valor definido antes de Parent/CreateWnd.');

    LDate.DateTime := LAssigned;
    Require((LProbe.Count = 0) and
      (NativeWindowText(LDate.PickerControl.Handle) =
       FormatDateTime(LDate.FormatString, LAssigned)),
      'Reatribuicao identica nao atualizou o texto ou emitiu OnChange.');

    LDate.FormatString := 'HH:mm:ss';
    Require(NativeWindowText(LDate.PickerControl.Handle) =
      FormatDateTime('HH:mm:ss', LAssigned),
      'Alteracao de FormatString nao atualizou a apresentacao runtime.');

    LAssigned := EncodeDate(2027, 1, 3) + EncodeTime(9, 10, 11, 0);
    LDate.DateTime := LAssigned;
    Require(SameValue(LDate.DateTime, LAssigned) and
      (NativeWindowText(LDate.PickerControl.Handle) =
       FormatDateTime(LDate.FormatString, LAssigned)),
      'Atribuicao runtime apos CreateWnd nao propagou valor e texto.');
    Require(LProbe.Count = 0,
      'Atribuicao programatica disparou OnChange artificialmente.');
    TraceStage('propagacao: concluida');
  finally
    LDate.Free;
    LForm.Free;
    LProbe.Free;
    PumpMessages;
  end;
end;

procedure RunIncrementalYearScenario(const ARefreshOnChange: Boolean);
const
  CYear = '2027';
  CFullDate = '12092028';
var
  I: Integer;
  LDate: TDACDateTimePicker;
  LForm: TForm;
  LOriginal: TDateTime;
  LProbe: TChangeProbe;
  LText: string;
begin
  TraceStage(Format('ano caractere a caractere refresh=%s',
    [BoolToStr(ARefreshOnChange, True)]));
  LForm := TForm.Create(nil);
  LProbe := TChangeProbe.Create;
  LDate := nil;
  try
    LDate := TDACDateTimePicker.Create(LForm);
    LDate.Parent := LForm;
    LDate.SetBounds(16, 16, 240, 30);
    LDate.FormatString := 'dd/MM/yyyy';
    LOriginal := EncodeDate(2026, 8, 29) + EncodeTime(14, 35, 0, 0);
    LDate.DateTime := LOriginal;
    if ARefreshOnChange then
      LDate.OnChange := LProbe.ChangedAndRefresh
    else
      LDate.OnChange := LProbe.Changed;
    LForm.Show;
    PumpMessages;
    LDate.SetFocus;
    LDate.PickerControl.SelStart := 6;
    LDate.PickerControl.SelLength := 4;
    for I := 1 to Length(CYear) do
    begin
      SendMessage(LDate.PickerControl.Handle, WM_CHAR, Ord(CYear[I]), 0);
      PumpMessages;
      LText := LDate.PickerControl.EditText;
      Writeln(Format('year[%d]: text="%s" year=%d caret=%d changes=%d',
        [I, LText, YearOf(LDate.DateTime), LDate.PickerControl.SelStart,
        LProbe.Count]));
      if I < Length(CYear) then
      begin
        Require(SameValue(LDate.DateTime, LOriginal),
          'Ano incompleto foi convertido/confirmado antes dos quatro digitos.');
        Require(LText = '29/08/' + Copy(CYear, 1, I) +
          StringOfChar('_', Length(CYear) - I),
          'Digitacao completou ou reformatou o ano antecipadamente.');
        Require((LDate.PickerControl.SelStart = 6 + I) and
          LDate.PickerControl.Focused,
          'Digitacao do ano perdeu foco ou reposicionou o cursor.');
        Require(LProbe.Count = 0,
          'Ano incompleto disparou OnChange.');
      end;
    end;
    Require(SameValue(LDate.DateTime,
      EncodeDate(2027, 8, 29) + TimeOf(LOriginal)),
      'Ano completo nao atualizou DateTime ou perdeu a hora.');
    Require(LText = '29/08/2027', 'Ano completo ficou incorreto no editor.');
    Require(LProbe.Count = 1, 'Ano completo deve emitir um unico OnChange.');

    LOriginal := LDate.DateTime;
    LProbe.FCount := 0;
    LDate.PickerControl.SelectAll;
    for I := 1 to Length(CFullDate) do
    begin
      SendMessage(LDate.PickerControl.Handle, WM_CHAR, Ord(CFullDate[I]), 0);
      PumpMessages;
      if I < Length(CFullDate) then
        Require(SameValue(LDate.DateTime, LOriginal) and (LProbe.Count = 0),
          'Digitacao da data inteira confirmou um valor incompleto.');
    end;
    Require((LDate.PickerControl.EditText = '12/09/2028') and
      SameValue(LDate.DateTime, EncodeDate(2028, 9, 12) + TimeOf(LOriginal)) and
      (LProbe.Count = 1),
      'Digitacao da data inteira nao confirmou uma unica data completa.');
  finally
    if LDate <> nil then
      LDate.OnChange := nil;
    LForm.Free;
    LProbe.Free;
  end;
end;

procedure RunPartialValueScenario;
var
  LDate: TDACDateTimePicker;
  LForm: TForm;
  LOriginal: TDateTime;
  LProbe: TChangeProbe;
begin
  TraceStage('valores incompletos, ano curto e nulo');
  LForm := TForm.Create(nil);
  LProbe := TChangeProbe.Create;
  try
    LDate := TDACDateTimePicker.Create(LForm);
    LDate.Parent := LForm;
    LDate.FormatString := 'dd/MM/yyyy';
    LOriginal := EncodeDate(2026, 8, 29);
    LDate.DateTime := LOriginal;
    LDate.OnChange := LProbe.Changed;
    LForm.Show;
    PumpMessages;

    LDate.Text := '29/08/2';
    LDate.OpenPopup;
    Require(SameValue(LDate.DateTime, LOriginal) and (LProbe.Count = 0) and
      LDate.PopupVisible and SameDate(LDate.PopupSelectedDateTime, LOriginal),
      'Abrir popup confirmou o ano incompleto.');
    LDate.SimulatePopupKey(VK_ESCAPE);
    LDate.Text := '31/02/2027';
    Require(SameValue(LDate.DateTime, LOriginal) and (LProbe.Count = 0),
      'Data completa invalida foi confirmada.');
    LDate.FormatString := 'dd/MM/yy';
    LDate.Text := '29/08/2';
    Require(SameValue(LDate.DateTime, LOriginal) and (LProbe.Count = 0),
      'Formato de ano curto confirmou apenas um digito.');
    LDate.Text := '29/08/27';
    Require(SameDate(LDate.DateTime, EncodeDate(2027, 8, 29)) and
      (LProbe.Count = 1), 'Formato explicito de ano curto deixou de funcionar.');

    LDate.PickerKind := dtkTime;
    LDate.FormatString := 'HH:mm';
    LOriginal := LDate.DateTime;
    LDate.Text := '16:4';
    Require(SameValue(LDate.DateTime, LOriginal) and (LProbe.Count = 1),
      'Hora incompleta foi confirmada.');
    LDate.Text := '16:40';
    Require((HourOf(LDate.DateTime) = 16) and
      (MinuteOf(LDate.DateTime) = 40) and (LProbe.Count = 2),
      'Hora completa nao foi confirmada.');

    LDate.PickerKind := dtkDate;
    LDate.FormatString := 'dd/MM/yyyy';
    LDate.AllowNull := True;
    LDate.IsNull := True;
    LDate.Text := '29/08/2';
    Require(LDate.IsNull and (LProbe.Count = 2),
      'Campo nulo confirmou o ano incompleto sem mascara ativa.');
    LDate.Text := '29/08/2027';
    Require(not LDate.IsNull and
      SameDate(LDate.DateTime, EncodeDate(2027, 8, 29)) and (LProbe.Count = 3),
      'Campo nulo nao aceitou a data completa.');
  finally
    LForm.Free;
    LProbe.Free;
  end;
end;

procedure RunTextEditingScenario;
var
  LDate: TDACDateTimePicker;
  LForm: TForm;
  LPoint: TPoint;
  LPopup: TDACDateTimePickerPopup;
  LProbe: TChangeProbe;
begin
  TraceStage('edicao textual herdada do TDACEdit');
  LForm := TForm.Create(nil);
  LProbe := TChangeProbe.Create;
  try
    LDate := TDACDateTimePicker.Create(LForm);
    LDate.Parent := LForm;
    LDate.SetBounds(16, 16, 240, 30);
    LDate.FormatString := 'dd/MM/yyyy';
    LDate.DateTime := EncodeDate(2026, 8, 28);
    LDate.OnChange := LProbe.Changed;
    LForm.Show;
    PumpMessages;

    LDate.Text := '29/08/2026';
    PumpMessages;
    Require(SameDate(LDate.DateTime, EncodeDate(2026, 8, 29)),
      'Edicao textual valida nao atualizou DateTime.');
    Require(LProbe.Count = 1,
      'Edicao textual valida nao emitiu OnChange exatamente uma vez.');

    PhysicalWindowClick(LDate.ActionButton.Handle,
      LDate.ActionButton.Width div 2, LDate.ActionButton.Height div 2);
    LPopup := FindPopup(LDate);
    Require((LPopup <> nil) and LPopup.Visible,
      'Botao nao abriu o calendario depois da edicao textual.');
    Require(SameDate(LPopup.SelectedDateTime, EncodeDate(2026, 8, 29)) and
      (MonthOf(LPopup.DisplayMonth) = 8) and
      (YearOf(LPopup.DisplayMonth) = 2026),
      'Calendario nao abriu com a data digitada selecionada.');

    LPoint := HeaderPoint(LPopup, 2);
    PhysicalWindowClick(LPopup.Handle, LPoint.X, LPoint.Y);
    Require((MonthOf(LPopup.DisplayMonth) = 9) and
      (YearOf(LPopup.DisplayMonth) = 2026),
      'Navegacao fisica para o proximo mes falhou.');
    LPoint := HeaderPoint(LPopup, 3);
    PhysicalWindowClick(LPopup.Handle, LPoint.X, LPoint.Y);
    Require((MonthOf(LPopup.DisplayMonth) = 9) and
      (YearOf(LPopup.DisplayMonth) = 2027),
      'Navegacao fisica para o proximo ano falhou.');
    LPoint := HeaderPoint(LPopup, 1);
    PhysicalWindowClick(LPopup.Handle, LPoint.X, LPoint.Y);
    Require((MonthOf(LPopup.DisplayMonth) = 8) and
      (YearOf(LPopup.DisplayMonth) = 2027),
      'Navegacao fisica para o mes anterior falhou.');
    LPoint := HeaderPoint(LPopup, 0);
    PhysicalWindowClick(LPopup.Handle, LPoint.X, LPoint.Y);
    Require((MonthOf(LPopup.DisplayMonth) = 8) and
      (YearOf(LPopup.DisplayMonth) = 2026),
      'Navegacao fisica para o ano anterior falhou.');
    Require(SameDate(LPopup.SelectedDateTime, EncodeDate(2026, 8, 29)) and
      SameDate(LDate.DateTime, EncodeDate(2026, 8, 29)) and
      (LProbe.Count = 1),
      'Navegar por mes/ano alterou ou confirmou a data indevidamente.');
    PhysicalWindowKey(LPopup.Handle, VK_ESCAPE);

    LDate.PickerKind := dtkTime;
    LDate.FormatString := 'HH:mm';
    LDate.Text := '16:40';
    PumpMessages;
    Require((HourOf(LDate.DateTime) = 16) and
      (MinuteOf(LDate.DateTime) = 40),
      'Edicao textual de hora nao atualizou DateTime.');
    Require(LProbe.Count = 2,
      'Edicao textual de hora nao emitiu um unico OnChange adicional.');
  finally
    LForm.Free;
    LProbe.Free;
  end;
end;

procedure RequireRuntimePresentation(const ADate: TDACDateTimePickerAccess;
  const AContext: string);
begin
  Require(ADate.HandleAllocated,
    AContext + ': host nao criou HWND.');
  Require(ADate.PickerControl.HandleAllocated,
    AContext + ': TMaskEdit nao criou HWND.');
  Require(IsWindowVisible(ADate.Handle),
    AContext + ': host nao esta fisicamente visivel.');
  Require(IsWindowVisible(ADate.PickerControl.Handle),
    AContext + ': TMaskEdit permaneceu fisicamente oculto.');
  Require(NativeWindowText(ADate.PickerControl.Handle) =
    FormatDateTime(ADate.FormatString, ADate.DateTime),
    AContext + ': texto nativo diverge do DateTime persistido.');
  Require(NativeTextPixelsVisible(ADate.PickerControl.Handle),
    AContext + ': HWND visivel nao pintou pixels do texto nativo.');
  RequireEditActionComposition(ADate, AContext);
end;

procedure RunStreamedLifecycleScenario(const AMode: TDACThemeMode);
var
  LContainer: TDACContainer;
  LContainerDate: TDACDateTimePickerAccess;
  LDirectDate: TDACDateTimePickerAccess;
  LLoadedForm: TForm;
  LPageControl: TPageControl;
  LPageDate: TDACDateTimePickerAccess;
  LPageOther: TTabSheet;
  LPageWithDate: TTabSheet;
  LProbe: TChangeProbe;
  LSourceForm: TForm;
  LStream: TMemoryStream;
begin
  TraceStage(Format('streaming DFM theme=%d', [Ord(AMode)]));
  TDACThemeManager.SetApplicationMode(AMode);
  if GetClass(TDACContainer.ClassName) = nil then
    System.Classes.RegisterClass(TDACContainer);
  if GetClass(TDACDateTimePicker.ClassName) = nil then
    System.Classes.RegisterClass(TDACDateTimePicker);
  if GetClass(TPageControl.ClassName) = nil then
    System.Classes.RegisterClass(TPageControl);
  if GetClass(TTabSheet.ClassName) = nil then
    System.Classes.RegisterClass(TTabSheet);

  LStream := TMemoryStream.Create;
  LSourceForm := TForm.Create(nil);
  try
    LSourceForm.Name := 'StreamSourceForm';
    LSourceForm.SetBounds(140, 140, 640, 360);

    LDirectDate := TDACDateTimePickerAccess(
      TDACDateTimePicker.Create(LSourceForm));
    LDirectDate.Name := 'StreamDirectDate';
    LDirectDate.Parent := LSourceForm;
    LDirectDate.SetBounds(20, 20, 220, 30);
    LDirectDate.FormatString := 'dd/MM/yyyy';
    LDirectDate.DateTime := EncodeDate(2025, 5, 24);

    LContainer := TDACContainer.Create(LSourceForm);
    LContainer.Name := 'StreamContainer';
    LContainer.Parent := LSourceForm;
    LContainer.SetBounds(20, 70, 280, 90);
    LContainerDate := TDACDateTimePickerAccess(
      TDACDateTimePicker.Create(LSourceForm));
    LContainerDate.Name := 'StreamContainerDate';
    LContainerDate.Parent := LContainer;
    LContainerDate.SetBounds(20, 20, 220, 30);
    LContainerDate.FormatString := 'dd/MM/yyyy';
    LContainerDate.DateTime := EncodeDate(2026, 8, 27);

    LPageControl := TPageControl.Create(LSourceForm);
    LPageControl.Name := 'StreamPages';
    LPageControl.Parent := LSourceForm;
    LPageControl.SetBounds(320, 20, 280, 180);
    LPageWithDate := TTabSheet.Create(LSourceForm);
    LPageWithDate.Name := 'StreamDatePage';
    LPageWithDate.Caption := 'Data';
    LPageWithDate.PageControl := LPageControl;
    LPageOther := TTabSheet.Create(LSourceForm);
    LPageOther.Name := 'StreamOtherPage';
    LPageOther.Caption := 'Outra';
    LPageOther.PageControl := LPageControl;
    LPageDate := TDACDateTimePickerAccess(
      TDACDateTimePicker.Create(LSourceForm));
    LPageDate.Name := 'StreamPageDate';
    LPageDate.Parent := LPageWithDate;
    LPageDate.SetBounds(16, 20, 220, 30);
    LPageDate.FormatString := 'dd/MM/yyyy';
    LPageDate.DateTime := EncodeDate(2027, 1, 3);
    LPageControl.ActivePage := LPageOther;

    TraceStage('streaming: gravar arvore');
    LStream.WriteComponent(LSourceForm);
  finally
    LSourceForm.Free;
  end;

  LLoadedForm := TForm.Create(nil);
  LProbe := TChangeProbe.Create;
  try
    LStream.Position := 0;
    TraceStage('streaming: ler arvore');
    LStream.ReadComponent(LLoadedForm);
    LDirectDate := TDACDateTimePickerAccess(
      LLoadedForm.FindComponent('StreamDirectDate'));
    LContainerDate := TDACDateTimePickerAccess(
      LLoadedForm.FindComponent('StreamContainerDate'));
    LPageDate := TDACDateTimePickerAccess(
      LLoadedForm.FindComponent('StreamPageDate'));
    LPageControl := TPageControl(LLoadedForm.FindComponent('StreamPages'));
    LPageWithDate := TTabSheet(
      LLoadedForm.FindComponent('StreamDatePage'));
    Require((LDirectDate <> nil) and (LContainerDate <> nil) and
      (LPageDate <> nil) and (LPageControl <> nil) and
      (LPageWithDate <> nil),
      'Streaming nao reconstruiu a arvore de componentes esperada.');
    LDirectDate.OnChange := LProbe.Changed;
    LContainerDate.OnChange := LProbe.Changed;
    LPageDate.OnChange := LProbe.Changed;

    TraceStage('streaming: mostrar form carregado');
    LLoadedForm.Show;
    PumpMessages(100);
    RequireRuntimePresentation(LDirectDate, 'DFM direto no form');
    RequireRuntimePresentation(LContainerDate, 'DFM dentro de TDACContainer');
    Require(not IsWindowVisible(LPageDate.Handle),
      'Picker da pagina inativa tornou o host fisicamente visivel.');

    LPageControl.ActivePage := LPageWithDate;
    PumpMessages(100);
    RequireRuntimePresentation(LPageDate,
      'DFM reativado dentro de TPageControl');

    LLoadedForm.Hide;
    PumpMessages(40);
    Require(not IsWindowVisible(LContainerDate.PickerControl.Handle),
      'Ocultar o form manteve o TMaskEdit visivel.');
    LLoadedForm.Show;
    PumpMessages(100);
    RequireRuntimePresentation(LContainerDate,
      'DFM apos ocultar e mostrar novamente');

    LContainerDate.ForceRecreateWnd;
    PumpMessages(100);
    RequireRuntimePresentation(LContainerDate,
      'DFM apos recriacao do HWND');
    Require(LProbe.Count = 0,
      'Streaming/sincronizacao visual disparou OnChange artificialmente.');
  finally
    LLoadedForm.Free;
    LProbe.Free;
    LStream.Free;
    PumpMessages;
  end;
end;

procedure RunPhysicalScenario(const AMode: TDACThemeMode;
  const APixelsPerInch: Integer);
var
  LAfter: TEdit;
  LBefore: TEdit;
  LChangeCountBefore: Integer;
  LContainer: TDACContainer;
  LDate: TDACDateTimePicker;
  LDay: Integer;
  LForm: TForm;
  LIconPoint: TPoint;
  LOriginal: TDateTime;
  LPage: TTabSheet;
  LPageControl: TPageControl;
  LPageDate: TDACDateTimePicker;
  LPoint: TPoint;
  LPopup: TDACDateTimePickerPopup;
  LPopupHandle: HWND;
  LRepeatedPopupHandle: HWND;
  LProbe: TChangeProbe;
  LTokens: TDACControlTokens;
begin
  TraceStage(Format('fisico theme=%d dpi=%d',
    [Ord(AMode), APixelsPerInch]));
  TDACThemeManager.SetApplicationMode(AMode);
  LForm := TForm.Create(nil);
  LProbe := TChangeProbe.Create;
  try
    LForm.PixelsPerInch := APixelsPerInch;
    LForm.SetBounds(120, 120, 520, 260);
    LBefore := TEdit.Create(LForm);
    LBefore.Parent := LForm;
    LBefore.SetBounds(16, 16, 120, 24);
    LContainer := TDACContainer.Create(LForm);
    LContainer.Parent := LForm;
    LContainer.TabStop := False;
    LContainer.SetBounds(16, 56, 360, 100);
    LDate := TDACDateTimePicker.Create(LForm);
    LDate.Parent := LContainer;
    LDate.SetBounds(20, 16, 280, 64);
    LDate.LabelText := 'Data';
    LDate.PickerKind := dtkDate;
    LDate.FormatString := 'dd/MM/yyyy';
    LDate.DateTime := EncodeDate(2026, 8, 12);
    LDate.OnChange := LProbe.Changed;
    LAfter := TEdit.Create(LForm);
    LAfter.Parent := LForm;
    LAfter.SetBounds(16, 176, 120, 24);
    LForm.Show;
    PumpMessages(80);
    TraceStage('fisico: form mostrado');

    Require(LDate.PickerControl.Visible,
      'TMaskEdit deveria estar visivel apos mostrar o formulario.');
    Require(NativeWindowText(LDate.PickerControl.Handle) =
      FormatDateTime(LDate.FormatString, LDate.DateTime),
      'Texto nativo inicial nao acompanha o DateTime preenchido.');

    LBefore.SetFocus;
    PhysicalWindowClick(LDate.PickerControl.Handle,
      LDate.PickerControl.Width div 2, LDate.PickerControl.Height div 2);
    Require(LDate.PickerControl.Focused,
      'Clique fisico na area editavel nao focou o TMaskEdit.');
    TraceStage('fisico: foco pela area editavel');

    LBefore.SetFocus;
    PhysicalWindowClick(LDate.Handle, 2,
      LDate.PickerControl.Top + (LDate.PickerControl.Height div 2));
    Require(LDate.PickerControl.Focused,
      'Clique fisico no chrome nao transferiu foco ao picker nativo.');
    TraceStage('fisico: foco pelo chrome');
    LBefore.SetFocus;
    PhysicalWindowClick(LDate.Handle,
      LDate.NativeLabel.Left + (LDate.NativeLabel.Width div 2),
      LDate.NativeLabel.Top + (LDate.NativeLabel.Height div 2));
    Require(LDate.PickerControl.Focused,
      'Clique fisico no label nao transferiu foco ao picker nativo.');
    TraceStage('fisico: foco pelo label');
    LBefore.SetFocus;
    Winapi.Windows.SetFocus(LDate.Handle);
    PumpMessages;
    Require(LDate.PickerControl.Focused,
      'WM_SETFOCUS do host nao transferiu foco ao picker nativo.');
    TraceStage('fisico: foco pelo host');

    PhysicalQueuedKey(LDate.PickerControl.Handle, VK_TAB);
    Require(LAfter.Focused,
      'Tab no picker nativo nao avancou para o controle seguinte.');
    TraceStage('fisico: tab avancou');
    { The former Shift+Tab harness depended on SysDateTimePick32 segment
      navigation and blocks TMaskEdit under synchronous SendMessage. Forward
      Tab plus TabStop=False on the nested editor proves the one-stop contract;
      reverse navigation remains the standard VCL dialog-manager path. }
    TraceStage('fisico: foco e tabulacao');

    LTokens := TDACComponentStyle.Resolve(AMode).Tokens.Controls;
    LIconPoint := Point(LDate.ActionButton.Width div 2,
      LDate.ActionButton.Height div 2);
    LOriginal := LDate.DateTime;
    TraceStage('fisico: popup pelo icone e escape');
    LBefore.SetFocus;
    PhysicalWindowClick(LDate.ActionButton.Handle,
      LIconPoint.X, LIconPoint.Y);
    Require(LDate.PopupVisible,
      'Clique fisico no icone nao abriu o popup.');
    PhysicalWindowKey(FindPopup(LDate).Handle, VK_RIGHT);
    PhysicalWindowKey(FindPopup(LDate).Handle, VK_ESCAPE);
    Require(not LDate.PopupVisible and SameValue(LDate.DateTime, LOriginal),
      'Escape fisico nao cancelou/fechou a selecao alterada pelo icone.');
    Require(LDate.PickerControl.Focused,
      'Escape nao devolveu foco seguro ao picker nativo.');

    LOriginal := LDate.DateTime;
    TraceStage('fisico: selecionar dia e confirmar');
    LDate.OpenPopup;
    PumpMessages(30);
    LPopup := FindPopup(LDate);
    Require((LPopup <> nil) and LPopup.Visible,
      'Popup fisico nao foi criado/mostrado.');
    LDay := DayOf(LOriginal) + 1;
    LPoint := DayPoint(LPopup, LDay);
    PhysicalWindowClick(LPopup.Handle, LPoint.X, LPoint.Y);
    Require(DayOf(LDate.PopupSelectedDateTime) = LDay,
      'WM_LBUTTONUP real no dia nao atualizou FSelected.');
    Require(SameValue(LDate.DateTime, LOriginal),
      'Clique no dia confirmou o valor antes de OK.');

    LPoint := FooterPoint(LPopup, 2);
    PhysicalWindowClick(LPopup.Handle, LPoint.X, LPoint.Y);
    Require(not LDate.PopupVisible,
      'Clique fisico em OK nao fechou o popup.');
    Require(DayOf(LDate.DateTime) = LDay,
      'Clique fisico em OK nao aplicou SelectedDateTime em DateTime.');
    Require(NativeWindowText(LDate.PickerControl.Handle) =
      FormatDateTime(LDate.FormatString,
      LDate.DateTime), 'Texto nativo nao acompanhou o DateTime aceito.');
    Require(LProbe.Count = 1,
      Format('OnChange deveria ocorrer uma vez; ocorreu %d.', [LProbe.Count]));
    Require(LDate.PickerControl.Focused,
      'OK nao devolveu foco seguro ao picker nativo.');
    TraceStage('fisico: OK confirmado');

    LDate.OpenPopup;
    LPopup := FindPopup(LDate);
    TraceStage('fisico: confirmar por Enter');
    LPoint := FooterPoint(LPopup, 2);
    PhysicalWindowClick(LPopup.Handle, LPoint.X, LPoint.Y);
    Require(LProbe.Count = 1,
      'OK sem mudanca disparou OnChange indevidamente.');

    LDate.OpenPopup;
    LPopup := FindPopup(LDate);
    TraceStage('fisico: Hoje e Limpar');
    PhysicalWindowKey(LPopup.Handle, VK_RIGHT);
    LOriginal := LDate.DateTime;
    PhysicalWindowKey(LPopup.Handle, VK_RETURN);
    Require(not LDate.PopupVisible and
      not SameValue(LDate.DateTime, LOriginal),
      'Enter fisico nao confirmou/fechou a selecao.');
    Require(LProbe.Count = 2,
      Format('Enter deveria gerar exatamente um OnChange; count=%d.',
        [LProbe.Count]));
    Require(LDate.PickerControl.Focused,
      'Enter nao devolveu foco seguro ao picker nativo.');

    LDate.OpenPopup;
    LPopup := FindPopup(LDate);
    LPoint := FooterPoint(LPopup, 0);
    PhysicalWindowClick(LPopup.Handle, LPoint.X, LPoint.Y);
    Require(LDate.PopupVisible and SameDate(LDate.PopupSelectedDateTime, Date),
      'Clique fisico em Hoje nao atualizou a selecao.');
    LPoint := FooterPoint(LPopup, 1);
    PhysicalWindowClick(LPopup.Handle, LPoint.X, LPoint.Y);
    Require(not LDate.PopupVisible and SameValue(LDate.DateTime, 0),
      'Clique fisico em Limpar nao zerou/fechou o campo.');
    Require(LProbe.Count = 3,
      Format('Limpar deveria gerar o terceiro OnChange; count=%d.',
        [LProbe.Count]));
    Require(LDate.PickerControl.Focused,
      'Limpar nao devolveu foco seguro ao picker nativo.');

    LDate.DateTime := EncodeDate(2026, 8, 12);
    TraceStage('fisico: estados bloqueados');
    LProbe.FCount := 0;
    LOriginal := LDate.DateTime;
    LDate.ReadOnly := True;
    PhysicalWindowClick(LDate.Handle, LIconPoint.X, LIconPoint.Y);
    Require(not LDate.PopupVisible and SameValue(LDate.DateTime, LOriginal) and
      (LProbe.Count = 0), 'ReadOnly permitiu alteracao por clique fisico.');
    LDate.ReadOnly := False;
    TDACDateTimePickerAccess(LDate).SetBindingCanModify(False);
    PhysicalWindowClick(LDate.Handle, LIconPoint.X, LIconPoint.Y);
    Require(not LDate.PopupVisible and SameValue(LDate.DateTime, LOriginal) and
      (LProbe.Count = 0),
      'BindingCanModify=False permitiu alteracao por clique fisico.');
    TDACDateTimePickerAccess(LDate).SetBindingCanModify(True);
    LDate.Loading := True;
    PhysicalWindowClick(LDate.Handle, LIconPoint.X, LIconPoint.Y);
    Require(not LDate.PopupVisible and SameValue(LDate.DateTime, LOriginal) and
      (LProbe.Count = 0), 'Loading permitiu alteracao por clique fisico.');
    LDate.Loading := False;
    LDate.Enabled := False;
    PhysicalWindowClick(LDate.Handle, LIconPoint.X, LIconPoint.Y);
    Require(not LDate.PopupVisible and SameValue(LDate.DateTime, LOriginal) and
      (LProbe.Count = 0), 'Disabled permitiu alteracao por clique fisico.');
    LDate.Enabled := True;

    LDate.FormatString := '';
    LDate.PickerKind := dtkTime;
    TraceStage('fisico: modo hora');
    LDate.TimeStepMinutes := 5;
    LDate.DateTime := EncodeDate(2026, 8, 12) + EncodeTime(10, 0, 0, 0);
    LProbe.FCount := 0;
    LDate.OpenPopup;
    TraceStage('fisico: modo hora popup aberto');
    LPopup := FindPopup(LDate);
    PhysicalWindowClick(LPopup.Handle, (LPopup.Width * 3) div 4,
      Round(LTokens.DateTimePopupTimeActionTop +
        (LTokens.DateTimePopupTimeActionHeight / 2)));
    TraceStage('fisico: modo hora incremento clicado');
    Require(MinuteOf(LDate.PopupSelectedDateTime) = 5,
      'Clique fisico dtkTime nao aplicou o incremento.');
    LPoint := FooterPoint(LPopup, 2);
    TraceStage('fisico: modo hora confirmar');
    PhysicalWindowClick(LPopup.Handle, LPoint.X, LPoint.Y);
    TraceStage('fisico: modo hora confirmado');
    Require((MinuteOf(LDate.DateTime) = 5) and (LProbe.Count = 1),
      'OK fisico dtkTime nao aplicou valor/OnChange exatamente uma vez.');

    TraceStage('fisico: TPageControl');
    LPageControl := TPageControl.Create(LForm);
    LPageControl.Parent := LForm;
    LPageControl.SetBounds(390, 16, 120, 180);
    LPage := TTabSheet.Create(LPageControl);
    LPage.PageControl := LPageControl;
    LPage.Caption := 'Data';
    LPageDate := TDACDateTimePicker.Create(LForm);
    LPageDate.Parent := LPage;
    LPageDate.SetBounds(4, 8, 104, 56);
    LPageDate.DateTime := EncodeDate(2026, 8, 12);
    PumpMessages(40);
    PhysicalWindowClick(LPageDate.PickerControl.Handle,
      LPageDate.PickerControl.Width div 2,
      LPageDate.PickerControl.Height div 2);
    Require(LPageDate.PickerControl.Focused,
      'DateTimePicker dentro de TPageControl nao recebeu foco fisico.');
    LPageDate.OpenPopup;
    Require(LPageDate.PopupVisible,
      'DateTimePicker dentro de TPageControl nao abriu popup.');
    PhysicalWindowKey(FindPopup(LPageDate).Handle, VK_ESCAPE);

    LOriginal := LDate.DateTime;
    TraceStage('fisico: fechamento externo');
    LChangeCountBefore := LProbe.Count;
    LDate.OpenPopup;
    PhysicalWindowKey(FindPopup(LDate).Handle, VK_RIGHT);
    PhysicalWindowClick(LAfter.Handle, LAfter.Width div 2,
      LAfter.Height div 2);
    Require(not LDate.PopupVisible,
      'Clique/foco externo nao fechou o popup sem confirmar.');
    Require(SameValue(LDate.DateTime, LOriginal) and
      (LProbe.Count = LChangeCountBefore),
      'Fechamento externo confirmou valor/OnChange indevidamente.');

    LRepeatedPopupHandle := 0;
    TraceStage('fisico: reabertura repetida');
    for LDay := 1 to 12 do
    begin
      LDate.OpenPopup;
      Require(LDate.PopupVisible,
        Format('Popup nao reabriu no ciclo %d.', [LDay]));
      LPopup := FindPopup(LDate);
      if LRepeatedPopupHandle = 0 then
        LRepeatedPopupHandle := LPopup.Handle
      else
        Require(LPopup.Handle = LRepeatedPopupHandle,
          'Reabertura duplicou/recriou o HWND do popup.');
      PhysicalWindowKey(FindPopup(LDate).Handle, VK_ESCAPE);
    end;
    LChangeCountBefore := CountChildWindowsByClass(LDate.Handle,
      NativeWindowClass(LDate.PickerControl.Handle));
    Require(LChangeCountBefore = 1,
      Format('Ciclos duplicaram/desanexaram TMaskEdit (count=%d).',
        [LChangeCountBefore]));

    LDate.OpenPopup;
    TraceStage('fisico: destruicao segura');
    LPopup := FindPopup(LDate);
    LPopupHandle := LPopup.Handle;
    SendMessage(LPopup.Handle, WM_KEYDOWN, VK_ESCAPE, 0);
    Require(not LDate.PopupVisible,
      'Escape pre-destruicao nao fechou o popup.');
    LDate.Free;
    PumpMessages(40);
    Require(not IsWindow(LPopupHandle),
      'Destruicao deixou HWND/callback do popup ativo.');
  finally
    LForm.Free;
    LProbe.Free;
    PumpMessages;
  end;
end;

var
  LPixelsPerInch: Integer;
  LThemeIndex: Integer;
  LThemeMode: TDACThemeMode;
  LExitCode: Integer;
begin
  LExitCode := 0;
  TraceStage('Application.Initialize');
  Application.Initialize;
  Application.MainFormOnTaskbar := False;
  TraceStage('Application.Initialize concluido');
  try
    RunValuePropagationScenario;
    RunIncrementalYearScenario(True);
    RunIncrementalYearScenario(False);
    RunPartialValueScenario;
    RunTextEditingScenario;
    for LThemeIndex := 0 to 1 do
    begin
      if LThemeIndex = 0 then
        LThemeMode := dtmLight
      else
        LThemeMode := dtmDark;
      RunStreamedLifecycleScenario(LThemeMode);
      for LPixelsPerInch in [96, 144, 192] do
        RunPhysicalScenario(LThemeMode, LPixelsPerInch);
    end;
    RunModalScenario;
    Writeln('DACDateTimePickerPhysical: PASS');
  except
    on E: Exception do
    begin
      Writeln(E.ClassName + ': ' + E.Message);
      LExitCode := 1;
    end;
  end;
  ExitCode := LExitCode;
end.
