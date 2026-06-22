unit DAC.Components.Hooks.Tabs;

interface

uses
  System.Types,
  Winapi.Messages,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.Themes;

type
  TDACPageControlStyleHook = class(TMouseTrackControlStyleHook)
  private
    FHotTabIndex: Integer;
    function ScaleMetric(const AValue: Integer): Integer;
    function TabBarBounds: TRect;
  protected
    procedure Paint(Canvas: TCanvas); override;
    procedure PaintBackground(Canvas: TCanvas); override;
    procedure WndProc(var Message: TMessage); override;
  public
    constructor Create(AControl: TWinControl); override;
  end;

implementation

uses
  System.Math,
  Winapi.Windows,
  Vcl.ComCtrls,
  Vcl.Forms,
  DAC.Components.Controls.Tabs,
  DAC.Components.DesignSystem.ColorTokens;

constructor TDACPageControlStyleHook.Create(AControl: TWinControl);
begin
  inherited Create(AControl);
  FHotTabIndex := -1;
  OverridePaint := True;
  OverrideEraseBkgnd := True;
end;

procedure TDACPageControlStyleHook.Paint(Canvas: TCanvas);
var
  I: Integer;
  LActive: Boolean;
  LBarRect: TRect;
  LCaption: string;
  LContentRect: TRect;
  LEnabled: Boolean;
  LHot: Boolean;
  LIndicatorRect: TRect;
  LPage: TTabSheet;
  LRadius: Integer;
  LRect: TRect;
  LTabs: TDACTabs;
  LTextFlags: Cardinal;
begin
  if not (Control is TDACTabs) then
  begin
    inherited;
    Exit;
  end;

  LTabs := TDACTabs(Control);
  PaintBackground(Canvas);

  LBarRect := TabBarBounds;
  LRadius := ScaleMetric(Max(8, LTabs.CornerRadius));

  if not IsRectEmpty(LBarRect) then
  begin
    Canvas.Brush.Style := bsSolid;
    Canvas.Brush.Color := TDACComponentColors.ToVclColor(TDACComponentColors.White);
    Canvas.Pen.Style := psSolid;
    Canvas.Pen.Width := 1;
    Canvas.Pen.Color := TDACComponentColors.ToVclColor(TDACComponentColors.ControlBorder);
    Canvas.RoundRect(LBarRect.Left, LBarRect.Top, LBarRect.Right,
      LBarRect.Bottom, LRadius, LRadius);
  end;

  for I := 0 to LTabs.PageCount - 1 do
  begin
    LPage := LTabs.Pages[I];
    if not LPage.TabVisible then
      Continue;

    LRect := LTabs.TabRect(LPage.TabIndex);
    InflateRect(LRect, -1, -1);
    LActive := LTabs.ActivePage = LPage;
    LHot := LPage.TabIndex = FHotTabIndex;
    LEnabled := LTabs.Enabled and LPage.Enabled;

    Canvas.Font.Assign(LTabs.Font);
    Canvas.Font.Style := [];
    Canvas.Font.Size := Max(8, Canvas.Font.Size);
    if LActive then
      Canvas.Font.Style := Canvas.Font.Style + [fsBold];

    if not LEnabled then
      Canvas.Font.Color := TDACComponentColors.ToVclColor(TDACComponentColors.ControlTextDisabled)
    else if LActive then
      Canvas.Font.Color := TDACComponentColors.ToVclColor(TDACComponentColors.PrimaryDark)
    else if LHot then
      Canvas.Font.Color := TDACComponentColors.ToVclColor(TDACComponentColors.Primary)
    else
      Canvas.Font.Color := TDACComponentColors.ToVclColor(TDACComponentColors.Alpha(70, 82, 78));

    Canvas.Brush.Style := bsSolid;
    Canvas.Pen.Style := psSolid;
    Canvas.Pen.Width := 1;

    if LTabs.Appearance = mtaPills then
    begin
      InflateRect(LRect, -ScaleMetric(4), -ScaleMetric(5));
      if LActive then
      begin
        Canvas.Brush.Color := TDACComponentColors.ToVclColor(TDACComponentColors.Alpha(232, 247, 228));
        Canvas.Pen.Color := TDACComponentColors.ToVclColor(TDACComponentColors.PrimaryLight);
      end
      else if LHot and LEnabled then
      begin
        Canvas.Brush.Color := TDACComponentColors.ToVclColor(TDACComponentColors.Alpha(244, 250, 244));
        Canvas.Pen.Color := TDACComponentColors.ToVclColor(TDACComponentColors.Alpha(213, 230, 213));
      end
      else
      begin
        Canvas.Brush.Color := TDACComponentColors.ToVclColor(TDACComponentColors.White);
        Canvas.Pen.Color := TDACComponentColors.ToVclColor(TDACComponentColors.White);
      end;

      if LActive or (LHot and LEnabled) then
        Canvas.RoundRect(LRect.Left, LRect.Top, LRect.Right, LRect.Bottom,
          ScaleMetric(20), ScaleMetric(20));
    end
    else
    begin
      if LActive then
        Canvas.Brush.Color := TDACComponentColors.ToVclColor(TDACComponentColors.Alpha(248, 252, 248))
      else if LHot and LEnabled then
        Canvas.Brush.Color := TDACComponentColors.ToVclColor(TDACComponentColors.Alpha(244, 250, 244))
      else
        Canvas.Brush.Color := TDACComponentColors.ToVclColor(TDACComponentColors.White);

      Canvas.Pen.Color := Canvas.Brush.Color;
      Canvas.RoundRect(LRect.Left, LRect.Top, LRect.Right, LRect.Bottom,
        ScaleMetric(8), ScaleMetric(8));

      if LEnabled and (LActive or LHot) then
      begin
        LIndicatorRect := LRect;
        if LTabs.TabPosition in [tpTop, tpBottom] then
        begin
          LIndicatorRect.Left := LIndicatorRect.Left + ScaleMetric(1);
          LIndicatorRect.Right := LIndicatorRect.Right - ScaleMetric(1);
          LIndicatorRect.Top := LIndicatorRect.Bottom - ScaleMetric(3);
        end
        else
        begin
          LIndicatorRect.Top := LIndicatorRect.Top + ScaleMetric(1);
          LIndicatorRect.Bottom := LIndicatorRect.Bottom - ScaleMetric(1);
          LIndicatorRect.Right := LIndicatorRect.Left + ScaleMetric(3);
        end;

        if LActive then
          Canvas.Brush.Color := TDACComponentColors.ToVclColor(TDACComponentColors.PrimaryDark)
        else
          Canvas.Brush.Color := TDACComponentColors.ToVclColor(TDACComponentColors.PrimaryLight);
        Canvas.Pen.Color := Canvas.Brush.Color;
        Canvas.FillRect(LIndicatorRect);
      end;
    end;

    LCaption := LPage.Caption;
    LContentRect := LRect;
    InflateRect(LContentRect, -ScaleMetric(14), 0);
    Canvas.Brush.Style := bsClear;
    LTextFlags := DT_CENTER or DT_VCENTER or DT_SINGLELINE or DT_END_ELLIPSIS;
    DrawText(Canvas.Handle, PChar(LCaption), Length(LCaption), LContentRect,
      LTextFlags);
  end;
end;

procedure TDACPageControlStyleHook.PaintBackground(Canvas: TCanvas);
var
  LBarRect: TRect;
  LContentRect: TRect;
  LTabs: TDACTabs;
begin
  Canvas.Brush.Style := bsSolid;
  Canvas.Brush.Color := TDACComponentColors.ToVclColor(TDACComponentColors.White);
  Canvas.FillRect(Control.ClientRect);

  if not (Control is TDACTabs) then
    Exit;

  LTabs := TDACTabs(Control);
  LBarRect := TabBarBounds;
  LContentRect := Control.ClientRect;
  if not IsRectEmpty(LBarRect) then
  begin
    case LTabs.TabPosition of
      tpBottom:
        LContentRect.Bottom := LBarRect.Top;
      tpLeft:
        LContentRect.Left := LBarRect.Right;
      tpRight:
        LContentRect.Right := LBarRect.Left;
    else
      LContentRect.Top := LBarRect.Bottom;
    end;
  end;
  if IsRectEmpty(LContentRect) then
    Exit;

  Canvas.Brush.Color := TDACComponentColors.ToVclColor(TDACComponentColors.Normalize(LTabs.ContentColor));
  Canvas.FillRect(LContentRect);

  if LTabs.ShowContentBorder then
  begin
    Canvas.Pen.Style := psSolid;
    Canvas.Pen.Width := 1;
    Canvas.Pen.Color := TDACComponentColors.ToVclColor(TDACComponentColors.ControlBorder);
    Canvas.Brush.Style := bsClear;
    Canvas.Rectangle(LContentRect.Left, LContentRect.Top, LContentRect.Right,
      LContentRect.Bottom);
  end;
end;

function TDACPageControlStyleHook.ScaleMetric(const AValue: Integer): Integer;
begin
  Result := MulDiv(AValue, Screen.PixelsPerInch, 96);
  if (AValue > 0) and (Result < 1) then
    Result := 1;
end;

function TDACPageControlStyleHook.TabBarBounds: TRect;
var
  I: Integer;
  LPage: TTabSheet;
  LRect: TRect;
  LTabs: TDACTabs;
begin
  Result := Rect(0, 0, 0, 0);
  if not (Control is TDACTabs) then
    Exit;

  LTabs := TDACTabs(Control);
  for I := 0 to LTabs.PageCount - 1 do
  begin
    LPage := LTabs.Pages[I];
    if not LPage.TabVisible then
      Continue;

    LRect := LTabs.TabRect(LPage.TabIndex);
    if IsRectEmpty(Result) then
      Result := LRect
    else
    begin
      Result.Left := Min(Result.Left, LRect.Left);
      Result.Top := Min(Result.Top, LRect.Top);
      Result.Right := Max(Result.Right, LRect.Right);
      Result.Bottom := Max(Result.Bottom, LRect.Bottom);
    end;
  end;

  if not IsRectEmpty(Result) then
    InflateRect(Result, ScaleMetric(1), ScaleMetric(1));
end;

procedure TDACPageControlStyleHook.WndProc(var Message: TMessage);
var
  LHotIndex: Integer;
  LMouseMessage: TWMMouse;
begin
  inherited;

  if not (Control is TDACTabs) then
    Exit;

  case Message.Msg of
    WM_MOUSEMOVE:
      begin
        LMouseMessage := TWMMouse(Message);
        LHotIndex := TDACTabs(Control).IndexOfTabAt(LMouseMessage.XPos,
          LMouseMessage.YPos);
        if LHotIndex <> FHotTabIndex then
        begin
          FHotTabIndex := LHotIndex;
          Invalidate;
        end;
      end;
    CM_MOUSELEAVE:
      if FHotTabIndex <> -1 then
      begin
        FHotTabIndex := -1;
        Invalidate;
      end;
  end;
end;

end.
