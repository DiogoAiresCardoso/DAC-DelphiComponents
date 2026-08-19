unit MaxUI.Hooks.Inputs;

{$CODEPAGE 65001}

interface

uses
  Winapi.Messages,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.StdCtrls,
  Vcl.Themes;

type
  TMaxEditStyleHook = class(TEditStyleHook)
  private
    procedure DrawIcons;
  protected
    procedure PaintNC(Canvas: TCanvas); override;
    procedure WndProc(var Message: TMessage); override;
  public
    constructor Create(AControl: TWinControl); override;
  end;

  TMaxMaskedEditStyleHook = class(TStyleHook)
  protected
    procedure PaintNC(Canvas: TCanvas); override;
    procedure WndProc(var Message: TMessage); override;
  public
    constructor Create(AControl: TWinControl); override;
  end;

  TMaxMemoStyleHook = class(TStyleHook)
  protected
    procedure PaintNC(Canvas: TCanvas); override;
    procedure WndProc(var Message: TMessage); override;
  public
    constructor Create(AControl: TWinControl); override;
  end;

implementation

uses
  System.Types,
  Winapi.Windows,
  MaxUI.Controls.Inputs,
  MaxUI.Dpi,
  MaxUI.Icons,
  MaxUI.Painter,
  MaxUI.Theme,
  MaxUI.Types;

function EditState(const Control: TWinControl;
  const ConfiguredState: TMaxFieldState): TMaxFieldState;
begin
  if not Control.Enabled then Exit(mfsDisabled);
  if ConfiguredState = mfsError then Exit(mfsError);
  if Control.Focused then Exit(mfsFocused);
  Result := ConfiguredState;
end;

constructor TMaxEditStyleHook.Create(AControl: TWinControl);
begin
  inherited Create(AControl);
  OverridePaintNC := True;
end;

procedure TMaxEditStyleHook.DrawIcons;
var
  EditControl: TMaxEdit;
  DC: HDC;
  CanvasValue: TCanvas;
  IconSize: Integer;
  R: TRect;
  Padding: Integer;
begin
  EditControl := TMaxEdit(Control);
  if (EditControl.LeadingIcon = mikNone) and
    (EditControl.TrailingIcon = mikNone) then Exit;
  DC := GetDC(Control.Handle);
  if DC = 0 then Exit;
  CanvasValue := TCanvas.Create;
  try
    CanvasValue.Handle := DC;
    IconSize := MaxScale(TMaxTheme.Metrics.IconSmall, Control.CurrentPPI);
    Padding := MaxScale(10, Control.CurrentPPI);
    if EditControl.LeadingIcon <> mikNone then
    begin
      R := Rect(Padding, (Control.Height - IconSize) div 2,
        Padding + IconSize, (Control.Height - IconSize) div 2 + IconSize);
      TMaxIconPainter.Draw(CanvasValue, R, EditControl.LeadingIcon,
        TMaxTheme.Palette.TextSecondary, 1);
    end;
    if EditControl.TrailingIcon <> mikNone then
    begin
      R := EditControl.TrailingIconRect;
      TMaxIconPainter.Draw(CanvasValue, R, EditControl.TrailingIcon,
        TMaxTheme.Palette.TextSecondary, 1);
    end;
    CanvasValue.Handle := 0;
  finally
    CanvasValue.Free;
    ReleaseDC(Control.Handle, DC);
  end;
end;

procedure TMaxEditStyleHook.PaintNC(Canvas: TCanvas);
var
  E: TMaxEdit;
begin
  E := TMaxEdit(Control);
  TMaxPainter.DrawFieldFrame(Canvas, Rect(0, 0, Control.Width, Control.Height),
    EditState(Control, E.FieldState), E.CornerRadius, Control.CurrentPPI);
end;

procedure TMaxEditStyleHook.WndProc(var Message: TMessage);
begin
  inherited WndProc(Message);
  case Message.Msg of
    WM_PAINT:
      DrawIcons;
    WM_SETFOCUS,
    WM_KILLFOCUS,
    CM_ENABLEDCHANGED:
      Control.Invalidate;
  end;
end;

constructor TMaxMaskedEditStyleHook.Create(AControl: TWinControl);
begin
  inherited Create(AControl);
  OverridePaintNC := True;
end;

procedure TMaxMaskedEditStyleHook.PaintNC(Canvas: TCanvas);
var
  E: TMaxMaskedEdit;
begin
  E := TMaxMaskedEdit(Control);
  TMaxPainter.DrawFieldFrame(Canvas, Rect(0, 0, Control.Width, Control.Height),
    EditState(Control, E.FieldState), E.CornerRadius, Control.CurrentPPI);
end;

procedure TMaxMaskedEditStyleHook.WndProc(var Message: TMessage);
begin
  inherited WndProc(Message);
  case Message.Msg of
    WM_SETFOCUS, WM_KILLFOCUS, CM_ENABLEDCHANGED:
      Control.Invalidate;
  end;
end;

constructor TMaxMemoStyleHook.Create(AControl: TWinControl);
begin
  inherited Create(AControl);
  OverridePaintNC := True;
end;

procedure TMaxMemoStyleHook.PaintNC(Canvas: TCanvas);
var
  M: TMaxMemo;
begin
  M := TMaxMemo(Control);
  TMaxPainter.DrawFieldFrame(Canvas, Rect(0, 0, Control.Width, Control.Height),
    EditState(Control, M.FieldState), M.CornerRadius, Control.CurrentPPI);
end;

procedure TMaxMemoStyleHook.WndProc(var Message: TMessage);
begin
  inherited WndProc(Message);
  case Message.Msg of
    WM_SETFOCUS, WM_KILLFOCUS, CM_ENABLEDCHANGED:
      Control.Invalidate;
  end;
end;

end.
