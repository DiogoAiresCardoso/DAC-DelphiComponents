unit DAC.Components.Hooks.SkiaControls;

interface

uses
  Winapi.Messages,
  Vcl.Controls,
  Vcl.Themes;

type
  TDACSkiaControlStyleHook = class(TMouseTrackControlStyleHook)
  protected
    procedure MouseEnter; override;
    procedure MouseLeave; override;
    procedure WndProc(var Message: TMessage); override;
  public
    constructor Create(AControl: TWinControl); override;
  end;

implementation

uses
  Winapi.Windows;

constructor TDACSkiaControlStyleHook.Create(AControl: TWinControl);
begin
  inherited Create(AControl);
  OverridePaint := False;
  OverridePaintNC := False;
  OverrideEraseBkgnd := False;
end;

procedure TDACSkiaControlStyleHook.MouseEnter;
begin
  inherited;
  Invalidate;
end;

procedure TDACSkiaControlStyleHook.MouseLeave;
begin
  inherited;
  Invalidate;
end;

procedure TDACSkiaControlStyleHook.WndProc(var Message: TMessage);
begin
  inherited;

  case Message.Msg of
    CM_ENABLEDCHANGED,
    CM_FONTCHANGED,
    CM_TEXTCHANGED,
    WM_SETFOCUS,
    WM_KILLFOCUS:
      Invalidate;
  end;
end;

end.
