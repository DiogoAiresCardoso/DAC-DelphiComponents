unit MaxUI.Hooks.Choices;

{$CODEPAGE 65001}

interface

uses
  Winapi.Messages,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.Themes;

type
  TMaxCheckBoxStyleHook = class(TStyleHook)
  private
    FHot: Boolean;
  protected
    procedure Paint(Canvas: TCanvas); override;
    procedure WndProc(var Message: TMessage); override;
  public
    constructor Create(AControl: TWinControl); override;
  end;

  TMaxRadioButtonStyleHook = class(TStyleHook)
  private
    FHot: Boolean;
  protected
    procedure Paint(Canvas: TCanvas); override;
    procedure WndProc(var Message: TMessage); override;
  public
    constructor Create(AControl: TWinControl); override;
  end;

implementation

uses
  System.Types,
  Winapi.Windows,
  Vcl.StdCtrls,
  MaxUI.Controls.Choices,
  MaxUI.Dpi,
  MaxUI.Painter,
  MaxUI.Theme;

procedure DrawChoiceText(Canvas: TCanvas; Control: TButtonControl;
  const GlyphRect: TRect);
var
  R: TRect;
  Save: Integer;
begin
  R := Control.ClientRect;
  R.Left := GlyphRect.Right + MaxScale(8, Control.CurrentPPI);
  Save := SaveDC(Canvas.Handle);
  try
    Canvas.Font.Assign(Control.Font);
    if Control.Enabled then Canvas.Font.Color := TMaxTheme.Palette.Text
    else Canvas.Font.Color := TMaxTheme.Palette.TextDisabled;
    SetBkMode(Canvas.Handle, TRANSPARENT);
    DrawText(Canvas.Handle, PChar(Control.Caption), Length(Control.Caption), R,
      DT_LEFT or DT_VCENTER or DT_SINGLELINE or DT_END_ELLIPSIS);
  finally
    RestoreDC(Canvas.Handle, Save);
  end;
end;

constructor TMaxCheckBoxStyleHook.Create(AControl: TWinControl);
begin
  inherited Create(AControl);
  OverridePaint := True;
  FHot := False;
end;

procedure TMaxCheckBoxStyleHook.Paint(Canvas: TCanvas);
var
  C: TMaxCheckBox;
  SizeValue: Integer;
  R: TRect;
begin
  C := TMaxCheckBox(Control);
  Canvas.Brush.Color := TMaxTheme.Palette.Background;
  Canvas.FillRect(C.ClientRect);
  SizeValue := MaxScale(C.GlyphSize, C.CurrentPPI);
  R := Rect(MaxScale(2, C.CurrentPPI), (C.Height - SizeValue) div 2,
    MaxScale(2, C.CurrentPPI) + SizeValue,
    (C.Height - SizeValue) div 2 + SizeValue);
  TMaxPainter.DrawCheckGlyph(Canvas, R, C.Checked, False, C.Enabled,
    FHot, C.Focused, C.CurrentPPI);
  DrawChoiceText(Canvas, C, R);
end;

procedure TMaxCheckBoxStyleHook.WndProc(var Message: TMessage);
begin
  case Message.Msg of
    CM_MOUSEENTER: begin FHot := True; Control.Invalidate; end;
    CM_MOUSELEAVE: begin FHot := False; Control.Invalidate; end;
    WM_SETFOCUS, WM_KILLFOCUS, CM_ENABLEDCHANGED, BM_SETCHECK:
      Control.Invalidate;
  end;
  inherited WndProc(Message);
end;

constructor TMaxRadioButtonStyleHook.Create(AControl: TWinControl);
begin
  inherited Create(AControl);
  OverridePaint := True;
  FHot := False;
end;

procedure TMaxRadioButtonStyleHook.Paint(Canvas: TCanvas);
var
  C: TMaxRadioButton;
  SizeValue: Integer;
  R: TRect;
begin
  C := TMaxRadioButton(Control);
  Canvas.Brush.Color := TMaxTheme.Palette.Background;
  Canvas.FillRect(C.ClientRect);
  SizeValue := MaxScale(C.GlyphSize, C.CurrentPPI);
  R := Rect(MaxScale(2, C.CurrentPPI), (C.Height - SizeValue) div 2,
    MaxScale(2, C.CurrentPPI) + SizeValue,
    (C.Height - SizeValue) div 2 + SizeValue);
  TMaxPainter.DrawCheckGlyph(Canvas, R, C.Checked, True, C.Enabled,
    FHot, C.Focused, C.CurrentPPI);
  DrawChoiceText(Canvas, C, R);
end;

procedure TMaxRadioButtonStyleHook.WndProc(var Message: TMessage);
begin
  case Message.Msg of
    CM_MOUSEENTER: begin FHot := True; Control.Invalidate; end;
    CM_MOUSELEAVE: begin FHot := False; Control.Invalidate; end;
    WM_SETFOCUS, WM_KILLFOCUS, CM_ENABLEDCHANGED, BM_SETCHECK:
      Control.Invalidate;
  end;
  inherited WndProc(Message);
end;

end.
