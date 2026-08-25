unit DAC.Components.Controls.DateTimePickerPopup;

interface

uses
  System.Classes,
  System.Skia,
  System.SysUtils,
  System.Types,
  System.UITypes,
  Winapi.Windows,
  Vcl.ComCtrls,
  Vcl.Controls,
  Vcl.Forms,
  Vcl.Skia,
  DAC.Components.Controls.SystemText,
  DAC.Components.DesignSystem.ControlTokens,
  DAC.Components.DesignSystem.Theme,
  DAC.Components.Skia.Renderer;

type
  // Borderless, modeless Skia popup. This is deliberately a top-level host
  // window: it has no Parent, stays hidden until ShowFor validates a real
  // runtime control handle, and never appears in the taskbar. The editing
  // window remains the native TDateTimePicker, preserving caret, IME and
  // accessibility semantics.
  TDACDateTimePickerPopup = class(TForm)
  private
    FAccept: TNotifyEvent;
    FClear: TNotifyEvent;
    FMonth: TDateTime;
    FPaintBox: TSkPaintBox;
    FPickerKind: TDateTimeKind;
    FRenderer: TDACSkiaRenderer;
    FTextOverlay: TDACSystemTextOverlay;
    FSelected: TDateTime;
    FThemeMode: TDACThemeMode;
    FTimeStepMinutes: Integer;
    procedure AdjustSelection(const ADays, AHours, AMinutes: Integer);
    procedure DrawCalendar(const ACanvas: ISkCanvas; const ADest: TRectF);
    procedure DrawTime(const ACanvas: ISkCanvas; const ADest: TRectF);
    function FooterActionRect(const AAction: Integer): TRectF;
    procedure PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    procedure PaintBoxMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure SelectDay(const ADay: Integer);
    procedure ThemeChanged(Sender: TObject);
  protected
    procedure CreateParams(var Params: TCreateParams); override;
    procedure Deactivate; override;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure ApplyThemeMode(const AThemeMode: TDACThemeMode);
    function ResolvedBackground: TAlphaColor;
    procedure ShowFor(const AControl: TControl; const AThemeMode: TDACThemeMode;
      const AKind: TDateTimeKind; const AValue: TDateTime;
      const ATimeStepMinutes: Integer);
    procedure SimulateDayClick(const ADay: Integer);
    procedure SimulateKey(const AKey: Word);
    procedure SimulateClick(const X, Y: Integer);
    procedure SimulateFooterAction(const AAction: Integer);
    procedure SimulateExternalDeactivate;
    property OnAccept: TNotifyEvent read FAccept write FAccept;
    property OnClear: TNotifyEvent read FClear write FClear;
    property SelectedDateTime: TDateTime read FSelected;
    property DisplayMonth: TDateTime read FMonth;
    property TimeStepMinutes: Integer read FTimeStepMinutes;
  end;

implementation

uses
  System.DateUtils,
  System.Math,
  Vcl.Graphics,
  DAC.Components.DesignSystem.ComponentStyle,
  DAC.Components.DesignSystem.Fonts;

constructor TDACDateTimePickerPopup.Create(AOwner: TComponent);
var
  LControls: TDACControlTokens;
begin
  inherited CreateNew(AOwner);
  BorderStyle := bsNone;
  Position := poDesigned;
  PopupMode := pmExplicit;
  LControls := TDACComponentStyle.Resolve(dtmInherit).Tokens.Controls;
  Width := Round(LControls.DateTimePopupWidth);
  Height := Round(LControls.DateTimePopupCalendarHeight);
  KeyPreview := True;
  FRenderer := TDACSkiaRenderer.Create;
  FPaintBox := TSkPaintBox.Create(Self);
  FPaintBox.Parent := Self;
  FPaintBox.Align := alClient;
  FPaintBox.OnDraw := PaintBoxDraw;
  FPaintBox.OnMouseUp := PaintBoxMouseUp;
  FTextOverlay := TDACSystemTextOverlay.Create(Self);
  FTextOverlay.Parent := Self;
  FTextOverlay.SetSubComponent(True);
  FTextOverlay.Align := alClient;
  FThemeMode := dtmInherit;
  FTimeStepMinutes := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls.DateTimeTimeStepMinutes;
  TDACThemeManager.RegisterListener(Self, ThemeChanged);
end;

procedure TDACDateTimePickerPopup.CreateParams(var Params: TCreateParams);
begin
  inherited;
  Params.ExStyle := (Params.ExStyle or WS_EX_TOOLWINDOW) and
    not WS_EX_APPWINDOW;
end;

destructor TDACDateTimePickerPopup.Destroy;
begin
  TDACThemeManager.UnregisterListener(Self);
  FTextOverlay.Free;
  FPaintBox.Free;
  FRenderer.Free;
  inherited;
end;

procedure TDACDateTimePickerPopup.ApplyThemeMode(const AThemeMode: TDACThemeMode);
begin
  if FThemeMode = AThemeMode then
    Exit;
  FThemeMode := AThemeMode;
  if Visible and (FPaintBox <> nil) and not (csDesigning in ComponentState) and
    not (csDestroying in ComponentState) and (WindowHandle <> 0) then
    FPaintBox.Redraw;
end;

function TDACDateTimePickerPopup.ResolvedBackground: TAlphaColor;
begin
  Result := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls.DateTimePopupBackground;
end;

procedure TDACDateTimePickerPopup.Deactivate;
begin
  inherited;
  if Visible then
    Hide;
end;

procedure TDACDateTimePickerPopup.AdjustSelection(const ADays, AHours,
  AMinutes: Integer);
begin
  FSelected := IncMinute(IncHour(FSelected, AHours), AMinutes) + ADays;
  // Keyboard navigation that crosses a month must leave the calendar header
  // synchronized with the selected day instead of keeping a stale grid.
  FMonth := StartOfTheMonth(FSelected);
end;

procedure TDACDateTimePickerPopup.DrawCalendar(const ACanvas: ISkCanvas;
  const ADest: TRectF);
const
  DayNames: array[0..6] of string = ('D', 'S', 'T', 'Q', 'Q', 'S', 'S');
var
  LCellHeight: Single;
  LCellWidth: Single;
  LCol: Integer;
  LControls: TDACControlTokens;
  LCursor: TDateTime;
  LDay: Integer;
  LDays: Integer;
  LFirstColumn: Integer;
  LMonthText: string;
  LRect: TRectF;
  LRow: Integer;
begin
  LControls := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls;
  LMonthText := FormatDateTime('mmmm yyyy', FMonth);
  FTextOverlay.QueueCenteredText('<', TDACComponentFontInstaller.FontFamily,
    TRectF.Create(LControls.DateTimePopupInset, LControls.DateTimePopupInset,
      LControls.DateTimePopupInset + LControls.DateTimePopupNavigationSize,
      LControls.DateTimePopupInset + LControls.DateTimePopupNavigationSize),
    LControls.DateTimePopupCaptionTextSize, LControls.DateTimePopupHeaderText, True);
  FTextOverlay.QueueCenteredText(LMonthText, TDACComponentFontInstaller.FontFamily,
    TRectF.Create(LControls.DateTimePopupInset + LControls.DateTimePopupNavigationSize + LControls.DateTimePopupHeaderGap,
      LControls.DateTimePopupInset, ADest.Width - LControls.DateTimePopupInset -
      LControls.DateTimePopupNavigationSize - LControls.DateTimePopupHeaderGap, LControls.DateTimePopupHeaderHeight),
    LControls.DateTimePopupCaptionTextSize, LControls.DateTimePopupHeaderText, True);
  FTextOverlay.QueueCenteredText('>', TDACComponentFontInstaller.FontFamily,
    TRectF.Create(ADest.Width - LControls.DateTimePopupInset - LControls.DateTimePopupNavigationSize,
      LControls.DateTimePopupInset, ADest.Width - LControls.DateTimePopupInset,
      LControls.DateTimePopupInset + LControls.DateTimePopupNavigationSize), LControls.DateTimePopupCaptionTextSize,
    LControls.DateTimePopupHeaderText, True);
  LCellWidth := (ADest.Width - (LControls.DateTimePopupInset * 2)) / LControls.DateTimePopupWeekColumns;
  for LCol := 0 to LControls.DateTimePopupWeekColumns - 1 do
    FTextOverlay.QueueCenteredText(DayNames[LCol], TDACComponentFontInstaller.FontFamily,
      TRectF.Create(LControls.DateTimePopupInset + LCol * LCellWidth,
        LControls.DateTimePopupHeaderHeight + LControls.DateTimePopupWeekTopGap,
        LControls.DateTimePopupInset + (LCol + 1) * LCellWidth,
        LControls.DateTimePopupHeaderHeight + LControls.DateTimePopupWeekTopGap + LControls.DateTimePopupWeekHeaderHeight),
      LControls.DateTimePopupBodyTextSize, LControls.DateTimePopupWeekText, True);
  LDays := DaysInAMonth(YearOf(FMonth), MonthOf(FMonth));
  LFirstColumn := DayOfTheWeek(StartOfTheMonth(FMonth)) - 1;
  LCellHeight := LControls.DateTimePopupCalendarCellHeight;
  for LDay := 1 to LDays do
  begin
    LCol := (LFirstColumn + LDay - 1) mod LControls.DateTimePopupWeekColumns;
    LRow := (LFirstColumn + LDay - 1) div LControls.DateTimePopupWeekColumns;
    LRect := TRectF.Create(LControls.DateTimePopupInset + LCol * LCellWidth,
      LControls.DateTimePopupHeaderHeight + LControls.DateTimePopupWeekHeaderHeight + LControls.DateTimePopupCalendarTopGap + LRow * LCellHeight,
      LControls.DateTimePopupInset + (LCol + 1) * LCellWidth,
      LControls.DateTimePopupHeaderHeight + LControls.DateTimePopupWeekHeaderHeight + LControls.DateTimePopupCalendarTopGap + (LRow + 1) * LCellHeight);
    LCursor := EncodeDate(YearOf(FMonth), MonthOf(FMonth), LDay);
    if SameDate(LCursor, FSelected) then
      FRenderer.FillRoundRect(ACanvas, LRect, LControls.DateTimePopupSelectedBackground,
        LControls.DateTimePopupDayRadius, LControls.DateTimePopupSelectedAlpha)
    else if SameDate(LCursor, Date) then
      FRenderer.StrokeRoundRect(ACanvas, LRect, LControls.DateTimePopupTodayBorder,
        LControls.DateTimePopupDayRadius, LControls.DateTimePopupTodayBorderWidth,
        LControls.DateTimePopupTodayAlpha);
    if SameDate(LCursor, FSelected) then
      FTextOverlay.QueueCenteredText(IntToStr(LDay), TDACComponentFontInstaller.FontFamily,
        LRect, LControls.DateTimePopupBodyTextSize, LControls.DateTimePopupSelectedText, True)
    else
      FTextOverlay.QueueCenteredText(IntToStr(LDay), TDACComponentFontInstaller.FontFamily,
        LRect, LControls.DateTimePopupBodyTextSize, LControls.DateTimePopupDayText);
  end;
end;

procedure TDACDateTimePickerPopup.DrawTime(const ACanvas: ISkCanvas;
  const ADest: TRectF);
var
  LControls: TDACControlTokens;
begin
  LControls := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls;
  FTextOverlay.QueueCenteredText('Hora selecionada', TDACComponentFontInstaller.FontFamily,
    TRectF.Create(LControls.DateTimePopupInset, LControls.DateTimePopupInset + LControls.DateTimePopupTimeCaptionOffset,
      ADest.Width - LControls.DateTimePopupInset, LControls.DateTimePopupHeaderHeight + LControls.DateTimePopupHeaderGap),
    LControls.DateTimePopupCaptionTextSize, LControls.DateTimePopupHeaderText, True);
  FTextOverlay.QueueCenteredText(FormatDateTime('hh:nn', FSelected),
    TDACComponentFontInstaller.FontFamily, TRectF.Create(LControls.DateTimePopupInset,
      LControls.DateTimePopupHeaderHeight + LControls.DateTimePopupTimeValueTopOffset, ADest.Width - LControls.DateTimePopupInset,
      LControls.DateTimePopupHeaderHeight + LControls.DateTimePopupTimeValueTopOffset + LControls.DateTimePopupTimeValueHeight), LControls.DateTimePopupTimeTextSize, LControls.DateTimePopupTimeValue, True);
  FTextOverlay.QueueCenteredText('- 1 min', TDACComponentFontInstaller.FontFamily,
    TRectF.Create(LControls.DateTimePopupInset + LControls.DateTimePopupTimeActionInset, LControls.DateTimePopupTimeActionTop,
      ADest.Width / 2 - LControls.DateTimePopupTimeActionGap, LControls.DateTimePopupTimeActionTop + LControls.DateTimePopupTimeActionHeight),
    LControls.DateTimePopupBodyTextSize, LControls.DateTimePopupActionText);
  FTextOverlay.QueueCenteredText('+ 1 min', TDACComponentFontInstaller.FontFamily,
    TRectF.Create(ADest.Width / 2 + LControls.DateTimePopupTimeActionGap, LControls.DateTimePopupTimeActionTop,
      ADest.Width - LControls.DateTimePopupInset - LControls.DateTimePopupTimeActionInset,
      LControls.DateTimePopupTimeActionTop + LControls.DateTimePopupTimeActionHeight),
    LControls.DateTimePopupBodyTextSize, LControls.DateTimePopupActionText);
end;

function TDACDateTimePickerPopup.FooterActionRect(
  const AAction: Integer): TRectF;
var
  LControls: TDACControlTokens;
  LFooter: TRectF;
begin
  LControls := TDACComponentStyle.ResolveForSurface(Self,
    FThemeMode).Tokens.Controls;
  LFooter := TRectF.Create(LControls.DateTimePopupInset,
    Height - LControls.DateTimePopupFooterHeight -
      LControls.DateTimePopupInset,
    Width - LControls.DateTimePopupInset,
    Height - LControls.DateTimePopupInset);
  case AAction of
    0:
      Result := TRectF.Create(LFooter.Left, LFooter.Top,
        LFooter.Left + LControls.DateTimePopupFooterActionWidth,
        LFooter.Bottom);
    1:
      Result := TRectF.Create(
        LFooter.Left + LControls.DateTimePopupFooterActionWidth +
          LControls.DateTimePopupFooterActionGap,
        LFooter.Top,
        LFooter.Left + (LControls.DateTimePopupFooterActionWidth * 2) +
          LControls.DateTimePopupFooterActionGap,
        LFooter.Bottom);
  else
    Result := TRectF.Create(
      LFooter.Right - LControls.DateTimePopupFooterActionWidth,
      LFooter.Top, LFooter.Right, LFooter.Bottom);
  end;
end;

procedure TDACDateTimePickerPopup.KeyDown(var Key: Word; Shift: TShiftState);
begin
  inherited;
  if FPickerKind = dtkTime then
  begin
    case Key of
      VK_LEFT: AdjustSelection(0, 0, -FTimeStepMinutes);
      VK_RIGHT: AdjustSelection(0, 0, FTimeStepMinutes);
      VK_UP: AdjustSelection(0, 1, 0);
      VK_DOWN: AdjustSelection(0, -1, 0);
    end;
  end
  else
  begin
    case Key of
      VK_LEFT: AdjustSelection(-1, 0, 0);
      VK_RIGHT: AdjustSelection(1, 0, 0);
      VK_UP: AdjustSelection(-7, 0, 0);
      VK_DOWN: AdjustSelection(7, 0, 0);
      VK_PRIOR: FMonth := IncMonth(FMonth, -1);
      VK_NEXT: FMonth := IncMonth(FMonth, 1);
    end;
  end;
  case Key of
    VK_ESCAPE: Hide;
    VK_RETURN:
      begin
        if Assigned(FAccept) then FAccept(Self);
        Hide;
      end;
    Ord('T'):
      begin
        FSelected := Date + Frac(FSelected);
        FMonth := StartOfTheMonth(FSelected);
      end;
  end;
  if (FPaintBox <> nil) and not (csDesigning in ComponentState) and
    not (csDestroying in ComponentState) and (WindowHandle <> 0) then
    FPaintBox.Redraw;
end;

procedure TDACDateTimePickerPopup.SimulateKey(const AKey: Word);
var
  LKey: Word;
begin
  LKey := AKey;
  KeyDown(LKey, []);
end;

procedure TDACDateTimePickerPopup.SimulateClick(const X, Y: Integer);
begin
  PaintBoxMouseUp(FPaintBox, mbLeft, [], X, Y);
end;

procedure TDACDateTimePickerPopup.SimulateDayClick(const ADay: Integer);
var
  LCellWidth: Integer;
  LCol: Integer;
  LControls: TDACControlTokens;
  LFirstColumn: Integer;
  LRow: Integer;
  X: Integer;
  Y: Integer;
begin
  if (FPickerKind <> dtkDate) or
    (ADay < 1) or (ADay > DaysInAMonth(YearOf(FMonth), MonthOf(FMonth))) then
    Exit;
  LControls := TDACComponentStyle.ResolveForSurface(Self,
    FThemeMode).Tokens.Controls;
  LCellWidth := Round((Width - (LControls.DateTimePopupInset * 2)) /
    LControls.DateTimePopupWeekColumns);
  LFirstColumn := DayOfTheWeek(StartOfTheMonth(FMonth)) - 1;
  LCol := (LFirstColumn + ADay - 1) mod
    LControls.DateTimePopupWeekColumns;
  LRow := (LFirstColumn + ADay - 1) div
    LControls.DateTimePopupWeekColumns;
  X := Round(LControls.DateTimePopupInset) + (LCol * LCellWidth) +
    (LCellWidth div 2);
  Y := Round(LControls.DateTimePopupHeaderHeight +
    LControls.DateTimePopupWeekHeaderHeight +
    LControls.DateTimePopupCalendarTopGap) +
    (LRow * Round(LControls.DateTimePopupCalendarCellHeight)) +
    (Round(LControls.DateTimePopupCalendarCellHeight) div 2);
  SimulateClick(X, Y);
end;

procedure TDACDateTimePickerPopup.SimulateFooterAction(
  const AAction: Integer);
var
  LRect: TRectF;
begin
  LRect := FooterActionRect(AAction);
  SimulateClick(Round((LRect.Left + LRect.Right) / 2),
    Round((LRect.Top + LRect.Bottom) / 2));
end;

procedure TDACDateTimePickerPopup.SimulateExternalDeactivate;
begin
  Deactivate;
end;

procedure TDACDateTimePickerPopup.PaintBoxDraw(Sender: TObject;
  const ACanvas: ISkCanvas; const ADest: TRectF; const AOpacity: Single);
var
  LControls: TDACControlTokens;
  LAcceptRect: TRectF;
  LClearRect: TRectF;
  LTodayRect: TRectF;
begin
  if ACanvas = nil then Exit;
  FTextOverlay.BeginNativeTextFrame;
  try
  LControls := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls;
  ACanvas.Clear(LControls.DateTimePopupCanvasBackground);
  FRenderer.FillRoundRect(ACanvas, TRectF.Create(0, 0, ADest.Width,
    ADest.Height), LControls.DateTimePopupBackground, LControls.DateTimePopupRadius,
    LControls.DateTimePopupBackgroundAlpha);
  FRenderer.StrokeRoundRect(ACanvas, TRectF.Create(0, 0, ADest.Width,
    ADest.Height), LControls.DateTimePopupBorder, LControls.DateTimePopupRadius,
    LControls.DateTimePopupBorderWidth, LControls.DateTimePopupBorderAlpha);
  if FPickerKind = dtkTime then
    DrawTime(ACanvas, ADest)
  else
    DrawCalendar(ACanvas, ADest);
  LTodayRect := FooterActionRect(0);
  LClearRect := FooterActionRect(1);
  LAcceptRect := FooterActionRect(2);
  FTextOverlay.QueueCenteredText('Hoje', TDACComponentFontInstaller.FontFamily,
    LTodayRect, LControls.DateTimePopupBodyTextSize,
    LControls.DateTimePopupTimeValue, True);
  FTextOverlay.QueueCenteredText('Limpar', TDACComponentFontInstaller.FontFamily,
    LClearRect, LControls.DateTimePopupBodyTextSize,
    LControls.DateTimePopupActionSecondaryText);
  FRenderer.FillRoundRect(ACanvas, LAcceptRect,
    LControls.DateTimePopupAcceptBackground,
    LControls.DateTimePopupRadius, LControls.DateTimePopupActionAlpha);
  FTextOverlay.QueueCenteredText('OK', TDACComponentFontInstaller.FontFamily,
    LAcceptRect, LControls.DateTimePopupBodyTextSize,
    LControls.DateTimePopupAcceptText, True);
  finally
    FTextOverlay.EndNativeTextFrame;
  end;
end;

procedure TDACDateTimePickerPopup.PaintBoxMouseUp(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  LCol, LDay, LFirstColumn, LRow: Integer;
  LControls: TDACControlTokens;
  LPoint: TPointF;
begin
  if Button <> mbLeft then Exit;
  LControls := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls;
  LPoint := TPointF.Create(X, Y);
  if FooterActionRect(0).Contains(LPoint) then
    begin FSelected := Date + Frac(FSelected); FMonth := StartOfTheMonth(FSelected); end
  else if FooterActionRect(1).Contains(LPoint) then
    begin if Assigned(FClear) then FClear(Self); Hide; Exit; end
  else if FooterActionRect(2).Contains(LPoint) then
    begin if Assigned(FAccept) then FAccept(Self); Hide; Exit; end
  else if FPickerKind = dtkTime then
  begin
    if (Y >= Round(LControls.DateTimePopupTimeActionTop - LControls.DateTimePopupTimeHitPadding)) and
      (Y <= Round(LControls.DateTimePopupTimeActionTop + LControls.DateTimePopupTimeActionHeight + LControls.DateTimePopupTimeHitPadding)) then
      if X < Width div 2 then FSelected := IncMinute(FSelected, -FTimeStepMinutes)
      else FSelected := IncMinute(FSelected, FTimeStepMinutes);
  end
  else if Y < Round(LControls.DateTimePopupHeaderHeight) then
  begin
    if X < Round(LControls.DateTimePopupInset + LControls.DateTimePopupNavigationSize) then FMonth := IncMonth(FMonth, -1)
    else if X > Width - Round(LControls.DateTimePopupInset + LControls.DateTimePopupNavigationSize) then FMonth := IncMonth(FMonth, 1);
  end
  else if Y >= Round(LControls.DateTimePopupHeaderHeight + LControls.DateTimePopupWeekHeaderHeight + LControls.DateTimePopupCalendarTopGap) then
  begin
    LCol := EnsureRange((X - Round(LControls.DateTimePopupInset)) div
      Round((Width - (LControls.DateTimePopupInset * 2)) / LControls.DateTimePopupWeekColumns), 0,
      LControls.DateTimePopupWeekColumns - 1);
    LRow := (Y - Round(LControls.DateTimePopupHeaderHeight + LControls.DateTimePopupWeekHeaderHeight + LControls.DateTimePopupCalendarTopGap)) div
      Round(LControls.DateTimePopupCalendarCellHeight);
    LFirstColumn := DayOfTheWeek(StartOfTheMonth(FMonth)) - 1;
    LDay := LRow * LControls.DateTimePopupWeekColumns + LCol - LFirstColumn + 1;
    SelectDay(LDay);
  end;
  if (FPaintBox <> nil) and not (csDesigning in ComponentState) and
    not (csDestroying in ComponentState) and (WindowHandle <> 0) then
    FPaintBox.Redraw;
end;

procedure TDACDateTimePickerPopup.SelectDay(const ADay: Integer);
begin
  if (ADay < 1) or (ADay > DaysInAMonth(YearOf(FMonth), MonthOf(FMonth))) then Exit;
  FSelected := EncodeDate(YearOf(FMonth), MonthOf(FMonth), ADay) + Frac(FSelected);
end;

procedure TDACDateTimePickerPopup.ShowFor(const AControl: TControl;
  const AThemeMode: TDACThemeMode; const AKind: TDateTimeKind;
  const AValue: TDateTime; const ATimeStepMinutes: Integer);
var
  LPoint: TPoint;
  LControls: TDACControlTokens;
begin
  if (AControl = nil) or (csDesigning in ComponentState) or
    (csLoading in ComponentState) or (csDestroying in ComponentState) or
    (AControl.Parent = nil) or not TWinControl(AControl).HandleAllocated or
    not AControl.Parent.HandleAllocated then
    Exit;
  FThemeMode := AThemeMode;
  PopupParent := GetParentForm(AControl);
  FPickerKind := AKind;
  FSelected := AValue;
  FMonth := StartOfTheMonth(AValue);
  LControls := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls;
  FTimeStepMinutes := Max(1, ATimeStepMinutes);
  if AKind = dtkTime then Height := Round(LControls.DateTimePopupTimeHeight)
  else Height := Round(LControls.DateTimePopupCalendarHeight);
  LPoint := AControl.ClientToScreen(Point(0, AControl.Height));
  SetBounds(LPoint.X, LPoint.Y + Round(LControls.DateTimePopupOffset),
    Max(Round(LControls.DateTimePopupWidth), AControl.Width), Height);
  Show;
  SetFocus;
  if (FPaintBox <> nil) and not (csDesigning in ComponentState) and
    not (csDestroying in ComponentState) and (WindowHandle <> 0) then
    FPaintBox.Redraw;
end;

procedure TDACDateTimePickerPopup.ThemeChanged(Sender: TObject);
begin
  if Visible and (FPaintBox <> nil) and not (csDesigning in ComponentState) and
    not (csDestroying in ComponentState) and (WindowHandle <> 0) then
    FPaintBox.Redraw;
end;

end.
