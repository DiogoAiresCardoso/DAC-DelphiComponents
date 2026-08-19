unit MaxUI.Hooks.Selectors;

{$CODEPAGE 65001}

interface

uses
  Winapi.Messages,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.StdCtrls;

type
  TMaxComboBoxStyleHook = class(TComboBoxStyleHook)
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
  MaxUI.Controls.Selectors,
  MaxUI.Painter,
  MaxUI.Types;

constructor TMaxComboBoxStyleHook.Create(AControl: TWinControl);
begin
  inherited Create(AControl);
  OverridePaintNC := True;
end;

procedure TMaxComboBoxStyleHook.PaintNC(Canvas: TCanvas);
var
  C: TMaxComboBox;
  StateValue: TMaxFieldState;
begin
  C := TMaxComboBox(Control);
  StateValue := C.FieldState;
  if not C.Enabled then StateValue := mfsDisabled
  else if C.Focused then StateValue := mfsFocused;
  TMaxPainter.DrawFieldFrame(Canvas, Rect(0, 0, C.Width, C.Height),
    StateValue, C.CornerRadius, C.CurrentPPI);
end;

procedure TMaxComboBoxStyleHook.WndProc(var Message: TMessage);
begin
  inherited WndProc(Message);
  case Message.Msg of
    WM_SETFOCUS, WM_KILLFOCUS, CM_ENABLEDCHANGED, CM_TEXTCHANGED:
      Control.Invalidate;
  end;
end;

end.
