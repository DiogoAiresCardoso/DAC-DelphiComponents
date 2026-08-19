unit MaxUI.Theme;

{$CODEPAGE 65001}

interface

uses
  System.Classes,
  Vcl.Controls,
  MaxUI.Types;

type
  TMaxThemeChangedEvent = procedure(Sender: TObject) of object;

  TMaxTheme = class sealed
  strict private
    class var FPalette: TMaxPalette;
    class var FMetrics: TMaxMetrics;
    class var FRevision: Cardinal;
    class constructor Create;
  public
    class function Palette: TMaxPalette; static;
    class function Metrics: TMaxMetrics; static;
    class function Revision: Cardinal; static;
    class procedure ResetLight; static;
    class procedure SetPalette(const AValue: TMaxPalette); static;
    class procedure SetMetrics(const AValue: TMaxMetrics); static;
  end;

  TMaxThemeManager = class(TComponent)
  private
    FOnThemeChanged: TMaxThemeChangedEvent;
    function GetUseSkia: Boolean;
    procedure SetUseSkia(const Value: Boolean);
  public
    procedure ApplyLightTheme;
    procedure ApplyTo(AControl: TControl);
  published
    property UseSkia: Boolean read GetUseSkia write SetUseSkia default True;
    property OnThemeChanged: TMaxThemeChangedEvent read FOnThemeChanged write FOnThemeChanged;
  end;

implementation

uses
  Vcl.Graphics;

class constructor TMaxTheme.Create;
begin
  FPalette := TMaxPalette.Light;
  FMetrics := TMaxMetrics.Defaults;
  FRevision := 1;
end;

class function TMaxTheme.Palette: TMaxPalette;
begin
  Result := FPalette;
end;

class function TMaxTheme.Metrics: TMaxMetrics;
begin
  Result := FMetrics;
end;

class function TMaxTheme.Revision: Cardinal;
begin
  Result := FRevision;
end;

class procedure TMaxTheme.ResetLight;
begin
  FPalette := TMaxPalette.Light;
  FMetrics := TMaxMetrics.Defaults;
  Inc(FRevision);
end;

class procedure TMaxTheme.SetPalette(const AValue: TMaxPalette);
begin
  FPalette := AValue;
  Inc(FRevision);
end;

class procedure TMaxTheme.SetMetrics(const AValue: TMaxMetrics);
begin
  FMetrics := AValue;
  Inc(FRevision);
end;

procedure TMaxThemeManager.ApplyLightTheme;
begin
  TMaxTheme.ResetLight;
  if Assigned(FOnThemeChanged) then
    FOnThemeChanged(Self);
end;

procedure TMaxThemeManager.ApplyTo(AControl: TControl);
begin
  if AControl = nil then
    Exit;
  AControl.Font.Name := 'Inter';
  AControl.Font.Color := TMaxTheme.Palette.Text;
  if AControl is TWinControl then
    TWinControl(AControl).Color := TMaxTheme.Palette.Background;
end;

procedure TMaxThemeManager.SetUseSkia(const Value: Boolean);
begin
  if not Value then
    Exit;
  if Assigned(FOnThemeChanged) then
    FOnThemeChanged(Self);
end;

function TMaxThemeManager.GetUseSkia: Boolean;
begin
  Result := True;
end;

end.
