unit DAC.Components.Hooks.Tabs;

interface

uses
  Winapi.Messages,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.Themes;

type
  TDACPageControlStyleHook = class(TMouseTrackControlStyleHook)
  private
    FHotTabIndex: Integer;
    function ScaleMetric(const AValue: Integer): Integer;
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
  LCaption: string;
  LContentRect: TRect;
  LEnabled: Boolean;
  LHot: Boolean;
  LIndicatorRect: TRect;
  LPage: TTabSheet;
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

  Canvas.Pen.Color := TDACComponentColors.ToVclColor(TDACComponentColors.ControlBorder);
  for I := 0 to LTabs.PageCount - 1 do
  begin
    LPage := LTabs.Pages[I];
    if not LPage.TabVisible then
      Continue;

    LRect := LTabs.TabRect(LPage.TabIndex);
    LActive := LTabs.ActivePage = LPage;
    LHot := LPage.TabIndex = FHotTabIndex;
    LEnabled := LTabs.Enabled and LPage.Enabled;

    Canvas.Font.Assign(LTabs.Font);
    Canvas.Font.Style := [];
    if LActive then
      Canvas.Font.Style := Canvas.Font.Style + [fsBold];

    if not LEnabled then
      Canvas.Font.Color := TDACComponentColors.ToVclColor(TDACComponentColors.ControlTextDisabled)
    else if LTabs.Appearance = mtaPills then
    begin
      if LActive then
        Canvas.Font.Color := TDACComponentColors.ToVclColor(TDACComponentColors.White)
      else if LHot then
        Canvas.Font.Color := TDACComponentColors.ToVclColor(TDACComponentColors.PrimaryDark)
      else
        Canvas.Font.Color := TDACComponentColors.ToVclColor(TDACComponentColors.ControlText);
    end
    else if LActive then
      Canvas.Font.Color := TDACComponentColors.ToVclColor(TDACComponentColors.PrimaryDark)
    else if LHot then
      Canvas.Font.Color := TDACComponentColors.ToVclColor(TDACComponentColors.Primary)
    else
      Canvas.Font.Color := TDACComponentColors.ToVclColor(TDACComponentColors.Alpha(70, 82, 78));

    Canvas.Brush.Style := bsSolid;
    if LTabs.Appearance = mtaPills then
    begin
      InflateRect(LRect, -ScaleMetric(4), -ScaleMetric(4));
      if LActive then
        Canvas.Brush.Color := TDACComponentColors.ToVclColor(TDACComponentColors.Primary)
      else if LHot and LEnabled then
        Canvas.Brush.Color := TDACComponentColors.ToVclColor(TDACComponentColors.Alpha(232, 247, 228))
      else
        Canvas.Brush.Color := TDACComponentColors.ToVclColor(TDACComponentColors.White);

      Canvas.RoundRect(LRect.Left, LRect.Top, LRect.Right, LRect.Bottom,
        ScaleMetric(LTabs.CornerRadius), ScaleMetric(LTabs.CornerRadius));
    end
    else
    begin
      Canvas.Brush.Color := TDACComponentColors.ToVclColor(TDACComponentColors.White);
      Canvas.FillRect(LRect);

      if LActive then
      begin
        LIndicatorRect := LRect;
        if LTabs.TabPosition in [tpTop, tpBottom] then
        begin
          LIndicatorRect.Left := LIndicatorRect.Left + ScaleMetric(8);
          LIndicatorRect.Right := LIndicatorRect.Right - ScaleMetric(8);
          LIndicatorRect.Top := LIndicatorRect.Bottom - ScaleMetric(4);
        end
        else
        begin
          LIndicatorRect.Top := LIndicatorRect.Top + ScaleMetric(8);
          LIndicatorRect.Bottom := LIndicatorRect.Bottom - ScaleMetric(8);
          LIndicatorRect.Right := LIndicatorRect.Left + ScaleMetric(4);
        end;
        Canvas.Brush.Color := TDACComponentColors.ToVclColor(TDACComponentColors.PrimaryDark);
        Canvas.FillRect(LIndicatorRect);
      end
      else if LHot and LEnabled then
      begin
        LIndicatorRect := LRect;
        if LTabs.TabPosition in [tpTop, tpBottom] then
        begin
          LIndicatorRect.Left := LIndicatorRect.Left + ScaleMetric(12);
          LIndicatorRect.Right := LIndicatorRect.Right - ScaleMetric(12);
          LIndicatorRect.Top := LIndicatorRect.Bottom - ScaleMetric(3);
          LIndicatorRect.Bottom := LIndicatorRect.Bottom - ScaleMetric(1);
        end
        else
        begin
          LIndicatorRect.Top := LIndicatorRect.Top + ScaleMetric(12);
          LIndicatorRect.Bottom := LIndicatorRect.Bottom - ScaleMetric(12);
          LIndicatorRect.Right := LIndicatorRect.Left + ScaleMetric(3);
        end;
        Canvas.Brush.Color := TDACComponentColors.ToVclColor(TDACComponentColors.PrimaryLight);
        Canvas.FillRect(LIndicatorRect);
      end;
    end;

    LCaption := LPage.Caption;
    LContentRect := LRect;
    InflateRect(LContentRect, -ScaleMetric(10), 0);
    Canvas.Brush.Style := bsClear;
    LTextFlags := DT_CENTER or DT_VCENTER or DT_SINGLELINE or DT_END_ELLIPSIS;
    DrawText(Canvas.Handle, PChar(LCaption), Length(LCaption), LContentRect,
      LTextFlags);
  end;
end;

procedure TDACPageControlStyleHook.PaintBackground(Canvas: TCanvas);
begin
  Canvas.Brush.Color := TDACComponentColors.ToVclColor(TDACComponentColors.White);
  Canvas.FillRect(Control.ClientRect);
end;

function TDACPageControlStyleHook.ScaleMetric(const AValue: Integer): Integer;
begin
  Result := MulDiv(AValue, Screen.PixelsPerInch, 96);
  if (AValue > 0) and (Result < 1) then
    Result := 1;
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
