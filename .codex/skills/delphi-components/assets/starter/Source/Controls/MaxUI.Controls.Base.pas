unit MaxUI.Controls.Base;

{$CODEPAGE 65001}

interface

uses
  System.Classes,
  System.Types,
  Winapi.Windows,
  Winapi.Messages,
  Vcl.Controls,
  Vcl.Graphics;

type
  TMaxSurface = class(TCustomControl)
  private
    FSurfaceColor: TColor;
    FBorderColor: TColor;
    FCornerRadius: Integer;
    FBorderWidth: Integer;
    procedure SetSurfaceColor(const Value: TColor);
    procedure SetBorderColor(const Value: TColor);
    procedure SetCornerRadius(const Value: Integer);
    procedure SetBorderWidth(const Value: Integer);
  protected
    procedure Paint; override;
    procedure WMEraseBkgnd(var Message: TWMEraseBkgnd); message WM_ERASEBKGND;
  public
    constructor Create(AOwner: TComponent); override;
    function ContentRect: TRect; virtual;
  published
    property Align;
    property Anchors;
    property Constraints;
    property Font;
    property ParentFont;
    property ParentShowHint;
    property ShowHint;
    property TabOrder;
    property TabStop;
    property Visible;
    property SurfaceColor: TColor read FSurfaceColor write SetSurfaceColor;
    property BorderColor: TColor read FBorderColor write SetBorderColor;
    property CornerRadius: Integer read FCornerRadius write SetCornerRadius default 10;
    property BorderWidth: Integer read FBorderWidth write SetBorderWidth default 1;
  end;

  TMaxSection = class(TMaxSurface)
  private
    FSectionIndex: Integer;
    FTitle: string;
    FHeaderHeight: Integer;
    procedure SetSectionIndex(const Value: Integer);
    procedure SetTitle(const Value: string);
    procedure SetHeaderHeight(const Value: Integer);
  protected
    procedure Paint; override;
  public
    constructor Create(AOwner: TComponent); override;
    function ContentRect: TRect; override;
  published
    property SectionIndex: Integer read FSectionIndex write SetSectionIndex default 0;
    property Title: string read FTitle write SetTitle;
    property HeaderHeight: Integer read FHeaderHeight write SetHeaderHeight default 36;
  end;

  TMaxCard = class(TMaxSurface)
  public
    constructor Create(AOwner: TComponent); override;
  end;

implementation

uses
  System.Math,
  System.SysUtils,
  MaxUI.Dpi,
  MaxUI.Painter,
  MaxUI.Theme;

constructor TMaxSurface.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  DoubleBuffered := True;
  ParentBackground := False;
  StyleElements := [seFont];
  FSurfaceColor := TMaxTheme.Palette.Surface;
  FBorderColor := TMaxTheme.Palette.Border;
  FCornerRadius := TMaxTheme.Metrics.RadiusCard;
  FBorderWidth := TMaxTheme.Metrics.BorderWidth;
  Color := FSurfaceColor;
  Font.Name := 'Inter';
  Font.Size := 9;
  Font.Color := TMaxTheme.Palette.Text;
  Width := 240;
  Height := 140;
end;

function TMaxSurface.ContentRect: TRect;
begin
  Result := ClientRect;
  InflateRect(Result, -MaxScale(12, CurrentPPI), -MaxScale(12, CurrentPPI));
end;

procedure TMaxSurface.Paint;
var
  R: TRect;
begin
  R := ClientRect;
  InflateRect(R, -1, -1);
  TMaxPainter.DrawSurface(Canvas, R, FSurfaceColor, FBorderColor,
    MaxScale(FCornerRadius, CurrentPPI), MaxScale(FBorderWidth, CurrentPPI));
end;

procedure TMaxSurface.SetBorderColor(const Value: TColor);
begin
  if FBorderColor = Value then Exit;
  FBorderColor := Value;
  Invalidate;
end;

procedure TMaxSurface.SetBorderWidth(const Value: Integer);
begin
  if FBorderWidth = Value then Exit;
  FBorderWidth := Max(0, Value);
  Invalidate;
end;

procedure TMaxSurface.SetCornerRadius(const Value: Integer);
begin
  if FCornerRadius = Value then Exit;
  FCornerRadius := Max(0, Value);
  Invalidate;
end;

procedure TMaxSurface.SetSurfaceColor(const Value: TColor);
begin
  if FSurfaceColor = Value then Exit;
  FSurfaceColor := Value;
  Color := Value;
  Invalidate;
end;

procedure TMaxSurface.WMEraseBkgnd(var Message: TWMEraseBkgnd);
begin
  Message.Result := 1;
end;

constructor TMaxSection.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FHeaderHeight := 36;
end;

function TMaxSection.ContentRect: TRect;
begin
  Result := inherited ContentRect;
  Inc(Result.Top, MaxScale(FHeaderHeight - 12, CurrentPPI));
end;

procedure TMaxSection.Paint;
var
  CaptionText: string;
  R: TRect;
  Save: Integer;
begin
  inherited;
  CaptionText := FTitle;
  if FSectionIndex > 0 then
    CaptionText := Format('%d.  %s', [FSectionIndex, FTitle]);
  R := ClientRect;
  R.Left := MaxScale(12, CurrentPPI);
  R.Top := MaxScale(5, CurrentPPI);
  R.Right := R.Right - MaxScale(12, CurrentPPI);
  R.Bottom := R.Top + MaxScale(FHeaderHeight - 6, CurrentPPI);
  Save := SaveDC(Canvas.Handle);
  try
    Canvas.Font.Assign(Font);
    Canvas.Font.Style := [fsBold];
    Canvas.Font.Color := TMaxTheme.Palette.PrimaryDark;
    SetBkMode(Canvas.Handle, TRANSPARENT);
    DrawText(Canvas.Handle, PChar(CaptionText), Length(CaptionText), R,
      DT_LEFT or DT_VCENTER or DT_SINGLELINE or DT_END_ELLIPSIS);
  finally
    RestoreDC(Canvas.Handle, Save);
  end;
end;

procedure TMaxSection.SetHeaderHeight(const Value: Integer);
begin
  if FHeaderHeight = Value then Exit;
  FHeaderHeight := Max(24, Value);
  Invalidate;
end;

procedure TMaxSection.SetSectionIndex(const Value: Integer);
begin
  if FSectionIndex = Value then Exit;
  FSectionIndex := Max(0, Value);
  Invalidate;
end;

procedure TMaxSection.SetTitle(const Value: string);
begin
  if FTitle = Value then Exit;
  FTitle := Value;
  Invalidate;
end;

constructor TMaxCard.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  CornerRadius := TMaxTheme.Metrics.RadiusCard;
end;

end.
