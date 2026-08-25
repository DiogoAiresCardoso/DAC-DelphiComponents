unit MaxUI.Hooks.Buttons;

{$CODEPAGE 65001}

interface

uses
  System.Classes,
  Winapi.Messages,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.StdCtrls,
  MaxUI.Types;

type
  TMaxButtonStyleHook = class(TButtonStyleHook)
  private
    FPressed: Boolean;
    function VisualState: TMaxVisualState;
  protected
    procedure Paint(Canvas: TCanvas); override;
    procedure WndProc(var Message: TMessage); override;
  public
    constructor Create(AControl: TWinControl); override;
  end;

implementation

uses
  Winapi.Windows,
  MaxUI.Controls.Buttons,
  MaxUI.Painter;

constructor TMaxButtonStyleHook.Create(AControl: TWinControl);
begin
  inherited Create(AControl);
  OverridePaint := True;
  FPressed := False;
end;

function TMaxButtonStyleHook.VisualState: TMaxVisualState;
begin
  if not Control.Enabled then Exit(mvsDisabled);
  if FPressed then Exit(mvsPressed);
  if MouseInControl then Exit(mvsHot);
  if Control.Focused then Exit(mvsFocused);
  Result := mvsNormal;
end;

procedure TMaxButtonStyleHook.Paint(Canvas: TCanvas);
var
  ButtonControl: TMaxButton;
  IconValue: TMaxIconKind;
  SplitWidth: Integer;
begin
  ButtonControl := TMaxButton(Control);
  IconValue := ButtonControl.IconKind;
  if ButtonControl.Loading then IconValue := mikClock;
  SplitWidth := 0;
  if ButtonControl is TMaxSplitButton then
    SplitWidth := TMaxSplitButton(ButtonControl).DropDownWidth;
  TMaxPainter.DrawButton(Canvas, ButtonControl.ClientRect,
    ButtonControl.Caption, ButtonControl.Font, ButtonControl.Kind,
    VisualState, ButtonControl.CornerRadius, ButtonControl.CurrentPPI,
    IconValue, ButtonControl.IconPosition, SplitWidth);
end;

procedure TMaxButtonStyleHook.WndProc(var Message: TMessage);
var
  NeedInvalidate: Boolean;
begin
  NeedInvalidate := False;
  case Message.Msg of
    WM_LBUTTONDOWN:
      if not FPressed then begin FPressed := True; NeedInvalidate := True; end;
    WM_LBUTTONUP,
    WM_CAPTURECHANGED:
      if FPressed then begin FPressed := False; NeedInvalidate := True; end;
    WM_SETFOCUS,
    WM_KILLFOCUS,
    CM_ENABLEDCHANGED,
    CM_TEXTCHANGED:
      NeedInvalidate := True;
  end;
  inherited WndProc(Message);
  if NeedInvalidate then Control.Invalidate;
end;

end.
