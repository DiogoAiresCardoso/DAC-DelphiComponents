program DACDBGridScrollHookTests;

{$APPTYPE CONSOLE}

uses
  System.Classes,
  System.Math,
  System.SysUtils,
  System.UITypes,
  Data.DB,
  Datasnap.DBClient,
  MidasLib,
  Winapi.Messages,
  Winapi.Windows,
  Vcl.DBGrids,
  Vcl.Forms,
  Vcl.Themes,
  DAC.Components.Controls.DBGrid,
  DAC.Components.Controls.DBGrid.Column,
  DAC.Components.Controls.DBGrid.Types,
  DAC.Components.Controls.NativeWindowTheme,
  DAC.Components.DesignSystem.ComponentStyle,
  DAC.Components.DesignSystem.ControlTokens,
  DAC.Components.DesignSystem.Theme,
  DAC.Components.Hooks.DBGridScroll,
  DAC.Components.Skia.ScrollBarRenderer;

type
  TScrollGridAccess = class(TDACDBGrid)
  public
    function GridDefaultRowHeight: Integer;
    function GridHeaderHeight: Integer;
    function GridLeftColumn: Integer;
    function GridPPI: Integer;
    function GridTopRow: Integer;
    procedure RecreateForTest;
    procedure ScaleForTest(const M, D: Integer);
  end;

  TScrollHookAccess = class(TDACDBGridScrollStyleHook)
  public
    procedure PaintAxis(const AVertical: Boolean);
    procedure PaintCorner;
    procedure SeedAxisStates(const AVertical: Boolean;
      const ASliderState, AStartState, AEndState: TThemedScrollBar);
  end;

var
  GHorizontalPaint: TDACScrollHookPaintInfo;
  GHorizontalPaintCount: Integer;
  GVerticalPaint: TDACScrollHookPaintInfo;
  GVerticalPaintCount: Integer;

procedure Require(const ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create(AMessage);
end;

function ColorLuminance(const AColor: TAlphaColor): Double;
  function Channel(const AValue: Byte): Double;
  begin
    Result := AValue / 255;
    if Result <= 0.04045 then
      Result := Result / 12.92
    else
      Result := Power((Result + 0.055) / 1.055, 2.4);
  end;
begin
  Result := 0.2126 * Channel((AColor shr 16) and $FF) +
    0.7152 * Channel((AColor shr 8) and $FF) +
    0.0722 * Channel(AColor and $FF);
end;

function ContrastRatio(const AFirst, ASecond: TAlphaColor): Double;
var
  LFirst: Double;
  LSecond: Double;
begin
  LFirst := ColorLuminance(AFirst);
  LSecond := ColorLuminance(ASecond);
  Result := (Max(LFirst, LSecond) + 0.05) /
    (Min(LFirst, LSecond) + 0.05);
end;

procedure CaptureScrollPaint(const AInfo: TDACScrollHookPaintInfo);
begin
  if AInfo.Axis = shaVertical then
  begin
    GVerticalPaint := AInfo;
    Inc(GVerticalPaintCount);
  end
  else
  begin
    GHorizontalPaint := AInfo;
    Inc(GHorizontalPaintCount);
  end;
end;

procedure ResetScrollPaint;
begin
  FillChar(GHorizontalPaint, SizeOf(GHorizontalPaint), 0);
  FillChar(GVerticalPaint, SizeOf(GVerticalPaint), 0);
  GHorizontalPaintCount := 0;
  GVerticalPaintCount := 0;
end;

function TScrollGridAccess.GridDefaultRowHeight: Integer;
begin
  Result := DefaultRowHeight;
end;

function TScrollGridAccess.GridHeaderHeight: Integer;
begin
  if (FixedRows > 0) and (RowCount > 0) then
    Result := RowHeights[0]
  else
    Result := 0;
end;

function TScrollGridAccess.GridLeftColumn: Integer;
begin
  Result := LeftCol;
end;

function TScrollGridAccess.GridPPI: Integer;
begin
  Result := FCurrentPPI;
end;

function TScrollGridAccess.GridTopRow: Integer;
begin
  Result := TopRow;
end;

procedure TScrollGridAccess.RecreateForTest;
begin
  RecreateWnd;
end;

procedure TScrollGridAccess.ScaleForTest(const M, D: Integer);
begin
  ChangeScale(M, D, True);
end;

procedure TScrollHookAccess.PaintAxis(const AVertical: Boolean);
var
  LDC: HDC;
begin
  LDC := GetWindowDC(Control.Handle);
  Require(LDC <> 0, 'Nao foi possivel obter o DC non-client da grid.');
  try
    if AVertical then
      DrawVertScroll(LDC)
    else
      DrawHorzScroll(LDC);
  finally
    ReleaseDC(Control.Handle, LDC);
  end;
end;

procedure TScrollHookAccess.PaintCorner;
begin
  DrawBorder;
end;

procedure TScrollHookAccess.SeedAxisStates(const AVertical: Boolean;
  const ASliderState, AStartState, AEndState: TThemedScrollBar);
begin
  if AVertical then
  begin
    VertSliderState := ASliderState;
    VertUpState := AStartState;
    VertDownState := AEndState;
  end
  else
  begin
    HorzSliderState := ASliderState;
    HorzUpState := AStartState;
    HorzDownState := AEndState;
  end;
end;

procedure PopulateDataSet(const ADataSet: TClientDataSet);
var
  I: Integer;
begin
  ADataSet.FieldDefs.Add('ID', ftInteger);
  ADataSet.FieldDefs.Add('NAME', ftString, 80);
  ADataSet.CreateDataSet;
  for I := 1 to 80 do
  begin
    ADataSet.Append;
    ADataSet.FieldByName('ID').AsInteger := I;
    ADataSet.FieldByName('NAME').AsString :=
      'Linha de teste da scrollbar ' + IntToStr(I);
    ADataSet.Post;
  end;
  ADataSet.First;
end;

procedure AddWideColumns(const AGrid: TDACDBGrid);
var
  I: Integer;
  LColumn: TDACDBGridColumn;
begin
  for I := 1 to 8 do
  begin
    LColumn := AGrid.Columns.Add;
    LColumn.FieldName := 'NAME';
    LColumn.LayoutKey := 'name_' + IntToStr(I);
    LColumn.Title.Caption := 'Coluna ' + IntToStr(I);
    LColumn.Width := 150;
  end;
end;

procedure RequireNativeScrollBars(const AGrid: TDACDBGrid);
const
  DACObjectIdHScroll = -6;
  DACObjectIdVScroll = -5;
var
  LHorzInfo: TScrollBarInfo;
  LVertInfo: TScrollBarInfo;
begin
  FillChar(LHorzInfo, SizeOf(LHorzInfo), 0);
  FillChar(LVertInfo, SizeOf(LVertInfo), 0);
  LHorzInfo.cbSize := SizeOf(LHorzInfo);
  LVertInfo.cbSize := SizeOf(LVertInfo);
  Require(GetScrollBarInfo(AGrid.Handle, DACObjectIdHScroll, LHorzInfo) and
    ((LHorzInfo.rgstate[0] and STATE_SYSTEM_INVISIBLE) = 0),
    'A grid de teste nao apresentou scrollbar horizontal nativa.');
  Require(GetScrollBarInfo(AGrid.Handle, DACObjectIdVScroll, LVertInfo) and
    ((LVertInfo.rgstate[0] and STATE_SYSTEM_INVISIBLE) = 0),
    'A grid de teste nao apresentou scrollbar vertical nativa.');
end;

procedure RequireThemePaint(const AGrid: TScrollGridAccess;
  const AHook: TScrollHookAccess; const AMode: TDACThemeMode);
var
  LCornerRect: TRect;
  LTokens: TDACControlTokens;
begin
  AGrid.Enabled := True;
  AGrid.ThemeMode := AMode;
  Application.ProcessMessages;
  LTokens := TDACComponentStyle.ResolveForSurface(AGrid,
    AGrid.ThemeMode).Tokens.Controls;

  if DACScrollHighContrastEnabled then
  begin
    ResetScrollPaint;
    AHook.PaintAxis(False);
    AHook.PaintAxis(True);
    Require((GHorizontalPaintCount = 0) and (GVerticalPaintCount = 0),
      'Em High Contrast o hook deve delegar integralmente ao Windows.');
    Exit;
  end;

  ResetScrollPaint;
  AHook.SeedAxisStates(False, tsThumbBtnHorzNormal,
    tsArrowBtnLeftNormal, tsArrowBtnRightNormal);
  AHook.SeedAxisStates(True, tsThumbBtnVertNormal,
    tsArrowBtnUpNormal, tsArrowBtnDownNormal);
  AHook.PaintAxis(False);
  AHook.PaintAxis(True);
  Require((GHorizontalPaintCount = 1) and (GVerticalPaintCount = 1),
    'O hook deve pintar cada eixo exatamente uma vez.');
  Require((GHorizontalPaint.Source = spsStyleHook) and
    (GVerticalPaint.Source = spsStyleHook) and
    GHorizontalPaint.RenderedWithSkia and GVerticalPaint.RenderedWithSkia,
    'A pintura dos eixos nao foi atribuida ao hook Skia localizado.');
  Require((GHorizontalPaint.Profile = svpMaxxRuralMD) and
    (GVerticalPaint.Profile = svpMaxxRuralMD),
    'O hook da grid nao selecionou exclusivamente o perfil MaxxRural MD.');
  Require((GHorizontalPaint.TrackColor = LTokens.ScrollBarTrack) and
    (GVerticalPaint.TrackColor = LTokens.ScrollBarTrack) and
    (GHorizontalPaint.SliderColor = LTokens.ScrollBarThumb) and
    (GVerticalPaint.SliderColor = LTokens.ScrollBarThumb) and
    (GHorizontalPaint.StartButtonColor = LTokens.ScrollBarArrow) and
    (GHorizontalPaint.EndButtonColor = LTokens.ScrollBarArrow) and
    (GVerticalPaint.StartButtonColor = LTokens.ScrollBarArrow) and
    (GVerticalPaint.EndButtonColor = LTokens.ScrollBarArrow) and
    (GHorizontalPaint.ArrowColor = LTokens.ScrollBarArrow) and
    (GVerticalPaint.BorderColor = LTokens.ScrollBarBorder),
    'A scrollbar nao utilizou os tokens oficiais do tema resolvido.');
  Require((GVerticalPaint.VisualTrackRect.Width = Min(
      MulDiv(Round(LTokens.ScrollBarTrackThickness), AGrid.GridPPI, 96),
      GVerticalPaint.ScrollRect.Width)) and
    (GVerticalPaint.VisualSliderRect.Width = Min(
      MulDiv(Round(LTokens.ScrollBarThumbThickness), AGrid.GridPPI, 96),
      GVerticalPaint.VisualTrackRect.Width)) and
    (GHorizontalPaint.VisualTrackRect.Height = Min(
      MulDiv(Round(LTokens.ScrollBarTrackThickness), AGrid.GridPPI, 96),
      GHorizontalPaint.ScrollRect.Height)) and
    (GHorizontalPaint.VisualSliderRect.Height = Min(
      MulDiv(Round(LTokens.ScrollBarThumbThickness), AGrid.GridPPI, 96),
      GHorizontalPaint.VisualTrackRect.Height)),
    'Track e thumb nao respeitaram a geometria visual MD no PPI atual.');
  Require(ResolveDACScrollCornerRect(GHorizontalPaint.ScrollRect,
    GVerticalPaint.ScrollRect, LCornerRect) and not IsRectEmpty(LCornerRect),
    'O encontro das duas scrollbars nao produziu canto valido.');
  AHook.PaintCorner;

  ResetScrollPaint;
  AHook.SeedAxisStates(True, tsThumbBtnVertHot,
    tsArrowBtnUpHot, tsArrowBtnDownNormal);
  AHook.PaintAxis(True);
  Require((GVerticalPaint.SliderColor = LTokens.ScrollBarThumbHot) and
    (GVerticalPaint.StartButtonColor = LTokens.ScrollBarThumbHot),
    'O estado hover nao utilizou ScrollBarThumbHot.');

  ResetScrollPaint;
  AHook.SeedAxisStates(False, tsThumbBtnHorzPressed,
    tsArrowBtnLeftNormal, tsArrowBtnRightPressed);
  AHook.PaintAxis(False);
  Require((GHorizontalPaint.SliderColor = LTokens.ScrollBarThumbPressed) and
    (GHorizontalPaint.EndButtonColor = LTokens.ScrollBarThumbPressed),
    'O estado pressed nao utilizou ScrollBarThumbPressed.');

  AGrid.Enabled := False;
  ResetScrollPaint;
  AHook.SeedAxisStates(True, tsThumbBtnVertNormal,
    tsArrowBtnUpNormal, tsArrowBtnDownNormal);
  AHook.PaintAxis(True);
  Require((GVerticalPaint.SliderState = tsThumbBtnVertDisabled) and
    not GVerticalPaint.Enabled and
    (GVerticalPaint.SliderColor = LTokens.ScrollBarThumbDisabled) and
    (GVerticalPaint.StartButtonColor = LTokens.ScrollBarThumbDisabled) and
    (GVerticalPaint.DisabledColor = LTokens.ScrollBarThumbDisabled),
    'O estado disabled nao foi encaminhado ao renderer central.');
  AGrid.Enabled := True;

  ResetScrollPaint;
  AHook.SeedAxisStates(True, tsThumbBtnVertDisabled,
    tsArrowBtnUpDisabled, tsArrowBtnDownDisabled);
  AHook.PaintAxis(True);
  Require(IsRectEmpty(GVerticalPaint.VisualSliderRect) and
    (GVerticalPaint.TrackColor = LTokens.ScrollBarThumbDisabled) and
    (GVerticalPaint.StartButtonColor = LTokens.ScrollBarThumbDisabled) and
    (GVerticalPaint.EndButtonColor = LTokens.ScrollBarThumbDisabled),
    'Eixo unavailable deve omitir o thumb e manter setas disabled.');

  Require((ContrastRatio(LTokens.ScrollBarThumb,
      LTokens.ScrollBarTrack) >= 3.0) and
    (ContrastRatio(LTokens.ScrollBarThumbHot,
      LTokens.ScrollBarTrack) >= 3.5) and
    (ContrastRatio(LTokens.ScrollBarThumbPressed,
      LTokens.ScrollBarTrack) >= 4.5),
    'Os tokens da scrollbar nao respeitaram os contrastes minimos.');
end;

procedure TestOfficialScrollTokens;
var
  LDark: TDACControlTokens;
  LLight: TDACControlTokens;
begin
  LDark := TDACComponentStyle.Resolve(dtmDark).Tokens.Controls;
  LLight := TDACComponentStyle.Resolve(dtmLight).Tokens.Controls;
  Require((LDark.ScrollBarTrack = TAlphaColor($FF0F1813)) and
    (LDark.ScrollBarThumb = TAlphaColor($FF4B6B51)) and
    (LDark.ScrollBarThumbHot = TAlphaColor($FF5CC46A)) and
    (LDark.ScrollBarThumbPressed = TAlphaColor($FF88E08F)) and
    (LDark.ScrollBarThumbDisabled = TAlphaColor($FF2A3A30)) and
    (LDark.ScrollBarFocusRing = TAlphaColor($FF5DE26B)),
    'A paleta dark oficial da scrollbar foi alterada.');
  Require((LLight.ScrollBarTrack = TAlphaColor($FFF5F7F5)) and
    (LLight.ScrollBarThumb = TAlphaColor($FF87918A)) and
    (LLight.ScrollBarThumbHot = TAlphaColor($FF6B8A75)) and
    (LLight.ScrollBarThumbPressed = TAlphaColor($FF557A53)) and
    (LLight.ScrollBarThumbDisabled = TAlphaColor($FFD6DDD7)) and
    (LLight.ScrollBarFocusRing = TAlphaColor($FF4AC86A)),
    'A paleta light oficial da scrollbar foi alterada.');
  Require((LDark.ScrollBarTrackThickness = 10) and
    (LDark.ScrollBarThumbThickness = 6) and
    (LDark.ScrollBarTrackRadius = 5) and
    (LDark.ScrollBarThumbRadius = 3),
    'As metricas logicas MD da scrollbar foram alteradas.');
end;

procedure TestDBGridScrollHook;
var
  LAuthorityBefore: Integer;
  LColumnWidth: Integer;
  LDataSet: TClientDataSet;
  LDataSource: TDataSource;
  LDC: HDC;
  LDefaultRowHeight: Integer;
  LForm: TForm;
  LGrid: TScrollGridAccess;
  LHeaderHeight: Integer;
  LHook: TScrollHookAccess;
  LHoverRect: TRect;
  LLeftColumn: Integer;
  LOldCursor: TPoint;
  LPartialRect: TRect;
  LSavedDC: Integer;
  LTopRow: Integer;
  LTokens: TDACControlTokens;
  LWheelDelta: SmallInt;
  LWindowRect: TRect;
begin
  LForm := TForm.Create(nil);
  LDataSet := TClientDataSet.Create(LForm);
  LDataSource := TDataSource.Create(LForm);
  LGrid := TScrollGridAccess.Create(LForm);
  LHook := nil;
  try
    PopulateDataSet(LDataSet);
    LDataSource.DataSet := LDataSet;
    LGrid.Parent := LForm;
    LGrid.SetBounds(8, 8, 360, 190);
    LGrid.Layout.Enabled := False;
    LGrid.DataSource := LDataSource;
    AddWideColumns(LGrid);
    LForm.ClientWidth := 390;
    LForm.ClientHeight := 220;
    LForm.Show;
    Application.ProcessMessages;
    RequireNativeScrollBars(LGrid);
    LColumnWidth := LGrid.Columns[0].Width;
    LDefaultRowHeight := LGrid.GridDefaultRowHeight;
    LHeaderHeight := LGrid.GridHeaderHeight;

    SetDACScrollPaintObserver(CaptureScrollPaint);
    LAuthorityBefore := DACNativeScrollBarHookAuthorityCount(LGrid.Handle);
    LHook := TScrollHookAccess.Create(LGrid);
    Require(DACNativeScrollBarHookAuthorityCount(LGrid.Handle) =
      LAuthorityBefore + 1,
      'O hook da grid nao adquiriu uma autoridade de pintura exclusiva.');
    RequireThemePaint(LGrid, LHook, dtmLight);
    RequireThemePaint(LGrid, LHook, dtmLight);
    RequireThemePaint(LGrid, LHook, dtmDark);
    RequireThemePaint(LGrid, LHook, dtmInherit);

    ResetScrollPaint;
    LDC := GetWindowDC(LGrid.Handle);
    Require(LDC <> 0, 'Nao foi possivel testar o fallback non-client.');
    try
      PaintDACNativeScrollBarTheme(LGrid, LGrid.ThemeMode, LDC, True);
    finally
      ReleaseDC(LGrid.Handle, LDC);
    end;
    Require((GHorizontalPaintCount = 0) and (GVerticalPaintCount = 0),
      'O fallback pintou em duplicidade durante a autoridade do StyleHook.');

    LLeftColumn := LGrid.GridLeftColumn;
    LGrid.Perform(WM_HSCROLL, SB_LINERIGHT, 0);
    Require(LGrid.GridLeftColumn >= LLeftColumn,
      'WM_HSCROLL nao preservou o mecanismo nativo da grid.');
    LTopRow := LGrid.GridTopRow;
    LGrid.Perform(WM_VSCROLL, SB_LINEDOWN, 0);
    Require(LGrid.GridTopRow >= LTopRow,
      'WM_VSCROLL nao preservou o mecanismo nativo da grid.');
    LWheelDelta := -WHEEL_DELTA;
    SendMessage(LGrid.Handle, WM_MOUSEWHEEL,
      MakeWParam(0, Word(LWheelDelta)), 0);
    SendMessage(LGrid.Handle, WM_KEYDOWN, VK_NEXT, 0);
    Require((LGrid.Columns[0].Width = LColumnWidth) and
      (LGrid.GridDefaultRowHeight = LDefaultRowHeight) and
      (LGrid.GridHeaderHeight = LHeaderHeight),
      'A interacao das scrollbars alterou coluna ou densidade da grid.');

    LGrid.Hide;
    LGrid.Show;
    LGrid.SetBounds(8, 8, 420, 210);
    LGrid.ScaleForTest(144, 96);
    Application.ProcessMessages;
    RequireThemePaint(LGrid, LHook, dtmLight);
    LGrid.ScaleForTest(192, 144);
    Application.ProcessMessages;
    RequireThemePaint(LGrid, LHook, dtmDark);
    Require(LGrid.HandleAllocated,
      'Hide/show, resize e DPI invalidaram o HWND da grid.');
    Require((LGrid.Columns[0].Width > 0) and
      (LGrid.GridDefaultRowHeight > 0) and
      (LGrid.GridHeaderHeight > 0),
      'A reaplicacao por DPI invalidou as metricas da grid.');

    LHook.Free;
    LHook := nil;
    Require(DACNativeScrollBarHookAuthorityCount(LGrid.Handle) =
      LAuthorityBefore,
      'A destruicao do hook nao liberou exatamente o proprio ticket.');
    if LAuthorityBefore = 0 then
    begin
      ResetScrollPaint;
      LTokens := TDACComponentStyle.ResolveForSurface(LGrid,
        LGrid.ThemeMode).Tokens.Controls;
      LDC := GetWindowDC(LGrid.Handle);
      try
        if DACScrollHighContrastEnabled then
          Require(PaintDACNativeScrollBarsProfile(LGrid, LDC, LTokens, True,
            svpMaxxRuralMD, LTokens.DataGridBackground) = 0,
            'Em High Contrast o fallback deve delegar ao Windows.')
        else
          Require(PaintDACNativeScrollBarsProfile(LGrid, LDC, LTokens, True,
            svpMaxxRuralMD, LTokens.DataGridBackground) = 3,
            'O fallback nao pintou as duas barras nativas.');
      finally
        ReleaseDC(LGrid.Handle, LDC);
      end;
      if not DACScrollHighContrastEnabled then
      begin
        Require((GHorizontalPaint.Source = spsNativeFallback) and
          (GVerticalPaint.Source = spsNativeFallback) and
          (GHorizontalPaint.Profile = svpMaxxRuralMD) and
          (GVerticalPaint.Profile = svpMaxxRuralMD),
          'O fallback nao declarou sua autoridade de pintura.');

        LPartialRect := GVerticalPaint.ScrollRect;
        LPartialRect.Bottom := LPartialRect.Top +
          Max(1, LPartialRect.Height div 2);
        ResetScrollPaint;
        LDC := GetWindowDC(LGrid.Handle);
        Require(LDC <> 0,
          'Nao foi possivel testar o clip parcial non-client.');
        try
          LSavedDC := SaveDC(LDC);
          try
            IntersectClipRect(LDC, LPartialRect.Left, LPartialRect.Top,
              LPartialRect.Right, LPartialRect.Bottom);
            Require(PaintDACNativeScrollBarsProfile(LGrid, LDC, LTokens,
              True, svpMaxxRuralMD, LTokens.DataGridBackground) = 2,
              'O fallback recusou uma invalidacao parcial da barra vertical.');
          finally
            if LSavedDC <> 0 then
              RestoreDC(LDC, LSavedDC);
          end;
        finally
          ReleaseDC(LGrid.Handle, LDC);
        end;
        Require((GVerticalPaintCount = 1) and
          (GHorizontalPaintCount = 0),
          'O clip parcial pintou fora do eixo non-client solicitado.');

        LHoverRect := GVerticalPaint.VisualSliderRect;
        Require(not IsRectEmpty(LHoverRect),
          'O fallback nao informou a geometria visual do thumb vertical.');
        if not GetWindowRect(LGrid.Handle, LWindowRect) then
          raise Exception.Create(
            'Nao foi possivel resolver a origem da grid para testar hover.');
        if not GetCursorPos(LOldCursor) then
          raise Exception.Create(
            'Nao foi possivel preservar a posicao do cursor.');
        try
          if not SetCursorPos(LWindowRect.Left +
              ((LHoverRect.Left + LHoverRect.Right) div 2),
              LWindowRect.Top +
              ((LHoverRect.Top + LHoverRect.Bottom) div 2)) then
            raise Exception.Create(
              'Nao foi possivel posicionar o cursor sobre o thumb.');
          ResetScrollPaint;
          SendMessage(LGrid.Handle, WM_NCMOUSEMOVE, HTVSCROLL,
            MakeLParam(
              LWindowRect.Left +
                ((LHoverRect.Left + LHoverRect.Right) div 2),
              LWindowRect.Top +
                ((LHoverRect.Top + LHoverRect.Bottom) div 2)));
          Application.ProcessMessages;
          Require((GVerticalPaintCount >= 1) and
            (GVerticalPaint.Source = spsNativeFallback) and
            (GVerticalPaint.Profile = svpMaxxRuralMD),
            'O hover non-client deixou o Windows substituir o perfil MD.');
          Require(GVerticalPaint.SliderColor = LTokens.ScrollBarThumbHot,
            'O hover non-client nao aplicou o token oficial do thumb.');

          if not SetCursorPos(LWindowRect.Left - 8,
              LWindowRect.Top - 8) then
            raise Exception.Create(
              'Nao foi possivel retirar o cursor da scrollbar.');
          ResetScrollPaint;
          SendMessage(LGrid.Handle, WM_NCMOUSELEAVE, 0, 0);
          Application.ProcessMessages;
          Require((GVerticalPaintCount >= 1) and
            (GVerticalPaint.SliderColor = LTokens.ScrollBarThumb),
            'A saida do non-client nao restaurou o estado normal do thumb.');
        finally
          SetCursorPos(LOldCursor.X, LOldCursor.Y);
        end;
      end;
    end;

    LGrid.RecreateForTest;
    Application.ProcessMessages;
    RequireNativeScrollBars(LGrid);
  finally
    LHook.Free;
    SetDACScrollPaintObserver(nil);
    LForm.Free;
  end;
  Require(DACNativeScrollBarHookAuthorityTotalCount = 0,
    'Restou ticket de scrollbar depois da destruicao da grid.');
end;

begin
  try
    Application.Initialize;
    TestOfficialScrollTokens;
    TestDBGridScrollHook;
    Writeln('DACDBGridScrollHookTests: PASS');
  except
    on E: Exception do
    begin
      Writeln('DACDBGridScrollHookTests: FAIL - ' + E.ClassName + ': ' +
        E.Message);
      Halt(1);
    end;
  end;
end.
