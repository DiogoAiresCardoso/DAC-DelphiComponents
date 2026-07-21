unit DAC.Components.Controls.Tabs;

interface

uses
  System.Classes,
  System.Skia,
  System.Types,
  System.UITypes,
  Winapi.Messages,
  Vcl.ComCtrls,
  Vcl.Controls,
  Vcl.Skia,
  DAC.Components.Skia.Renderer;

type
  TDACTabs = class;

  TDACTabHeaderControl = class(TSkPaintBox)
  private
    FTabs: TDACTabs;
    FHotIndex: Integer;
    FRenderer: TDACSkiaRenderer;
    function ScaleMetric(const AValue: Integer): Integer;
    function TabRectByOrdinal(const AOrdinal: Integer): TRectF;
    function TabAt(const X, Y: Integer): Integer;
    procedure PaintBoxDraw(Sender: TObject; const ACanvas: ISkCanvas;
      const ADest: TRectF; const AOpacity: Single);
    procedure PaintBoxMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure PaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
  protected
    procedure CMMouseLeave(var AMessage: TMessage); message CM_MOUSELEAVE;
  public
    constructor CreateForTabs(ATabs: TDACTabs);
    destructor Destroy; override;
    procedure Redraw;
  end;

  TDACTabOrientation = (mtoHorizontal, mtoVertical);
  TDACTabAppearance = (mtaUnderline, mtaPills);

  TDACTabs = class(TPageControl)
  private
    FAppearance: TDACTabAppearance;
    FContentColor: TAlphaColor;
    FCornerRadius: Integer;
    FHeader: TDACTabHeaderControl;
    FShowContentBorder: Boolean;
    function GetActiveIndex: Integer;
    function GetOrientation: TDACTabOrientation;
    function HeaderExtent: Integer;
    procedure EnsureHeader;
    procedure SetActiveIndex(const AValue: Integer);
    procedure SetAppearance(const AValue: TDACTabAppearance);
    procedure SetContentColor(const AValue: TAlphaColor);
    procedure SetCornerRadius(const AValue: Integer);
    procedure SetOrientation(const AValue: TDACTabOrientation);
    procedure SetShowContentBorder(const AValue: Boolean);
    function ScaleMetric(const AValue: Integer): Integer;
    procedure ApplyPageStyle;
    procedure InvalidateTabs;
    procedure UpdateHeaderBounds;
  protected
    procedure Change; override;
    procedure ChangeScale(M, D: Integer; isDpiChange: Boolean); override;
    procedure CreateWnd; override;
    procedure Loaded; override;
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Redraw;
  published
    property ActiveIndex: Integer read GetActiveIndex write SetActiveIndex default -1;
    property Appearance: TDACTabAppearance read FAppearance write SetAppearance default mtaUnderline;
    property ContentColor: TAlphaColor read FContentColor write SetContentColor;
    property CornerRadius: Integer read FCornerRadius write SetCornerRadius default 8;
    property Orientation: TDACTabOrientation read GetOrientation write SetOrientation default mtoHorizontal;
    property ShowContentBorder: Boolean read FShowContentBorder write SetShowContentBorder default True;
  end;

implementation

uses
  System.Math,
  DAC.Components.DesignSystem.ColorTokens,
  DAC.Components.DesignSystem.Fonts;

constructor TDACTabHeaderControl.CreateForTabs(ATabs: TDACTabs);
begin
  inherited Create(ATabs);
  FTabs := ATabs;
  FHotIndex := -1;
  FRenderer := TDACSkiaRenderer.Create;
  SetSubComponent(True);
  StyleElements := [];
  OnDraw := PaintBoxDraw;
  OnMouseDown := PaintBoxMouseDown;
  OnMouseMove := PaintBoxMouseMove;
end;

destructor TDACTabHeaderControl.Destroy;
begin
  FRenderer.Free;
  inherited;
end;

procedure TDACTabHeaderControl.CMMouseLeave(var AMessage: TMessage);
begin
  inherited;
  if FHotIndex <> -1 then
  begin
    FHotIndex := -1;
    Cursor := crDefault;
    Redraw;
  end;
end;

procedure TDACTabHeaderControl.PaintBoxDraw(Sender: TObject;
  const ACanvas: ISkCanvas; const ADest: TRectF; const AOpacity: Single);
var
  I: Integer;
  LActive: Boolean;
  LEnabled: Boolean;
  LHot: Boolean;
  LOrdinal: Integer;
  LPage: TTabSheet;
  LRect: TRectF;
  LTextColor: TAlphaColor;
  LUnderline: TRectF;
begin
  if (ACanvas = nil) or (FTabs = nil) then
    Exit;

  ACanvas.Clear(TDACComponentColors.White);
  FRenderer.FillRoundRect(ACanvas, TRectF.Create(0.5, 0.5,
    ADest.Width - 0.5, ADest.Height - 0.5), TDACComponentColors.White,
    ScaleMetric(10));
  FRenderer.StrokeRoundRect(ACanvas, TRectF.Create(0.5, 0.5,
    ADest.Width - 0.5, ADest.Height - 0.5),
    TDACComponentColors.ControlBorder, ScaleMetric(10), 1);

  LOrdinal := 0;
  for I := 0 to FTabs.PageCount - 1 do
  begin
    LPage := FTabs.Pages[I];
    if not LPage.TabVisible then
      Continue;

    LRect := TabRectByOrdinal(LOrdinal);
    Inc(LOrdinal);
    LActive := FTabs.ActivePage = LPage;
    LHot := I = FHotIndex;
    LEnabled := FTabs.Enabled and LPage.Enabled;

    if FTabs.Appearance = mtaPills then
    begin
      LRect.Inflate(-ScaleMetric(5), -ScaleMetric(8));
      if LActive then
      begin
        FRenderer.FillRoundRect(ACanvas, LRect,
          TDACComponentColors.Alpha(232, 247, 228), ScaleMetric(20));
        FRenderer.StrokeRoundRect(ACanvas, LRect,
          TDACComponentColors.PrimaryLight, ScaleMetric(20), 1);
      end
      else if LHot and LEnabled then
        FRenderer.FillRoundRect(ACanvas, LRect,
          TDACComponentColors.Alpha(244, 250, 244), ScaleMetric(20));
    end
    else
    begin
      LRect.Inflate(-ScaleMetric(1), -ScaleMetric(5));
      if LActive then
        FRenderer.FillRoundRect(ACanvas, LRect,
          TDACComponentColors.Alpha(248, 252, 248), ScaleMetric(8))
      else if LHot and LEnabled then
        FRenderer.FillRoundRect(ACanvas, LRect,
          TDACComponentColors.Alpha(244, 250, 244), ScaleMetric(8));

      if LEnabled and (LActive or LHot) then
      begin
        LUnderline := LRect;
        if FTabs.Orientation = mtoHorizontal then
        begin
          LUnderline.Top := LUnderline.Bottom - ScaleMetric(3);
          LUnderline.Left := LUnderline.Left + ScaleMetric(8);
          LUnderline.Right := LUnderline.Right - ScaleMetric(8);
        end
        else
        begin
          LUnderline.Right := LUnderline.Left + ScaleMetric(3);
          LUnderline.Top := LUnderline.Top + ScaleMetric(8);
          LUnderline.Bottom := LUnderline.Bottom - ScaleMetric(8);
        end;
        if LActive then
          FRenderer.FillRoundRect(ACanvas, LUnderline,
            TDACComponentColors.PrimaryDark, ScaleMetric(2))
        else
          FRenderer.FillRoundRect(ACanvas, LUnderline,
            TDACComponentColors.PrimaryLight, ScaleMetric(2));
      end;
    end;

    if not LEnabled then
      LTextColor := TDACComponentColors.ControlTextDisabled
    else if LActive then
      LTextColor := TDACComponentColors.PrimaryDark
    else if LHot then
      LTextColor := TDACComponentColors.Primary
    else
      LTextColor := TDACComponentColors.Alpha(70, 82, 78);
    LRect.Inflate(-ScaleMetric(10), 0);
    FRenderer.TextCentered(ACanvas, LPage.Caption,
      TDACComponentFontInstaller.FontFamily, LRect, ScaleMetric(10),
      LTextColor, LActive);
  end;
end;

procedure TDACTabHeaderControl.PaintBoxMouseDown(Sender: TObject;
  Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  LIndex: Integer;
begin
  if (Button <> mbLeft) or (FTabs = nil) then
    Exit;
  LIndex := TabAt(X, Y);
  if (LIndex >= 0) and (LIndex < FTabs.PageCount) and FTabs.Pages[LIndex].Enabled then
  begin
    FTabs.ActivePage := FTabs.Pages[LIndex];
    if FTabs.CanFocus then
      FTabs.SetFocus;
    Redraw;
  end;
end;

procedure TDACTabHeaderControl.PaintBoxMouseMove(Sender: TObject;
  Shift: TShiftState; X, Y: Integer);
var
  LIndex: Integer;
begin
  LIndex := TabAt(X, Y);
  if LIndex <> FHotIndex then
  begin
    FHotIndex := LIndex;
    if LIndex >= 0 then
      Cursor := crHandPoint
    else
      Cursor := crDefault;
    Redraw;
  end;
end;

procedure TDACTabHeaderControl.Redraw;
begin
  if (FTabs <> nil) and (FTabs.Parent <> nil) and FTabs.HandleAllocated and
    not (csDestroying in ComponentState) then
    inherited Redraw;
end;

function TDACTabHeaderControl.ScaleMetric(const AValue: Integer): Integer;
begin
  Result := Max(1, Round(AValue * ScaleFactor));
end;

function TDACTabHeaderControl.TabAt(const X, Y: Integer): Integer;
var
  I: Integer;
  LOrdinal: Integer;
begin
  Result := -1;
  if FTabs = nil then
    Exit;
  LOrdinal := 0;
  for I := 0 to FTabs.PageCount - 1 do
  begin
    if not FTabs.Pages[I].TabVisible then
      Continue;
    if TabRectByOrdinal(LOrdinal).Contains(TPointF.Create(X, Y)) then
      Exit(I);
    Inc(LOrdinal);
  end;
end;

function TDACTabHeaderControl.TabRectByOrdinal(const AOrdinal: Integer): TRectF;
var
  LCount: Integer;
  LSize: Single;
begin
  LCount := Max(1, FTabs.PageCount);
  if FTabs.Orientation = mtoVertical then
  begin
    LSize := Max(ScaleMetric(40), Height / LCount);
    Result := TRectF.Create(ScaleMetric(4), ScaleMetric(1) + (AOrdinal * LSize),
      Width - ScaleMetric(4), ScaleMetric(1) + ((AOrdinal + 1) * LSize));
  end
  else
  begin
    LSize := Max(ScaleMetric(76), Width / LCount);
    Result := TRectF.Create(ScaleMetric(1) + (AOrdinal * LSize), ScaleMetric(4),
      ScaleMetric(1) + ((AOrdinal + 1) * LSize), Height - ScaleMetric(4));
  end;
end;

constructor TDACTabs.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Width := 420;
  Height := 180;
  DoubleBuffered := True;
  ParentDoubleBuffered := False;
  TabStop := True;
  FAppearance := mtaUnderline;
  FContentColor := TDACComponentColors.White;
  FCornerRadius := 8;
  FShowContentBorder := True;
  OwnerDraw := False;
  Style := tsTabs;
  TabHeight := 1;
  TabWidth := 1;
  UpdateHeaderBounds;
end;

destructor TDACTabs.Destroy;
begin
  FHeader.Free;
  inherited;
end;

procedure TDACTabs.ApplyPageStyle;
begin
  TabHeight := 1;
  TabWidth := 1;
  UpdateHeaderBounds;
  InvalidateTabs;
end;

procedure TDACTabs.Change;
begin
  inherited;
  InvalidateTabs;
end;

procedure TDACTabs.ChangeScale(M, D: Integer; isDpiChange: Boolean);
begin
  inherited;
  UpdateHeaderBounds;
  InvalidateTabs;
end;

procedure TDACTabs.CreateWnd;
begin
  inherited;
  EnsureHeader;
  ApplyPageStyle;
end;

procedure TDACTabs.EnsureHeader;
begin
  if (FHeader <> nil) or (Parent = nil) or not HandleAllocated or
    not Parent.HandleAllocated then
    Exit;
  FHeader := TDACTabHeaderControl.CreateForTabs(Self);
  FHeader.Parent := Self;
end;

function TDACTabs.GetActiveIndex: Integer;
begin
  Result := TabIndex;
end;

function TDACTabs.GetOrientation: TDACTabOrientation;
begin
  if TabPosition in [tpLeft, tpRight] then
    Result := mtoVertical
  else
    Result := mtoHorizontal;
end;

function TDACTabs.HeaderExtent: Integer;
begin
  Result := ScaleMetric(52);
end;

procedure TDACTabs.InvalidateTabs;
begin
  if FHeader <> nil then
    FHeader.Redraw;
  if HandleAllocated then
    Invalidate;
end;

procedure TDACTabs.Loaded;
begin
  inherited;
  EnsureHeader;
  ApplyPageStyle;
end;

procedure TDACTabs.Redraw;
begin
  InvalidateTabs;
end;

procedure TDACTabs.Resize;
begin
  inherited;
  UpdateHeaderBounds;
  InvalidateTabs;
end;

function TDACTabs.ScaleMetric(const AValue: Integer): Integer;
begin
  if FHeader <> nil then
    Result := Max(1, Round(AValue * FHeader.ScaleFactor))
  else
    Result := Max(1, AValue);
end;

procedure TDACTabs.SetActiveIndex(const AValue: Integer);
begin
  if PageCount = 0 then
    TabIndex := -1
  else
    TabIndex := Max(-1, Min(AValue, PageCount - 1));
end;

procedure TDACTabs.SetAppearance(const AValue: TDACTabAppearance);
begin
  if FAppearance = AValue then Exit;
  FAppearance := AValue;
  InvalidateTabs;
end;

procedure TDACTabs.SetContentColor(const AValue: TAlphaColor);
begin
  if FContentColor = TDACComponentColors.Normalize(AValue) then Exit;
  FContentColor := TDACComponentColors.Normalize(AValue);
  ApplyPageStyle;
end;

procedure TDACTabs.SetCornerRadius(const AValue: Integer);
begin
  if FCornerRadius = Max(0, AValue) then Exit;
  FCornerRadius := Max(0, AValue);
  InvalidateTabs;
end;

procedure TDACTabs.SetOrientation(const AValue: TDACTabOrientation);
begin
  if AValue = mtoVertical then
    TabPosition := tpLeft
  else
    TabPosition := tpTop;
  ApplyPageStyle;
end;

procedure TDACTabs.SetShowContentBorder(const AValue: Boolean);
begin
  if FShowContentBorder = AValue then Exit;
  FShowContentBorder := AValue;
  InvalidateTabs;
end;

procedure TDACTabs.UpdateHeaderBounds;
var
  I: Integer;
  LExtent: Integer;
begin
  LExtent := HeaderExtent;
  if FHeader <> nil then
  begin
    if (FHeader.Parent <> Self) and (Parent <> nil) and HandleAllocated and
      Parent.HandleAllocated then
      FHeader.Parent := Self;
    if Orientation = mtoVertical then
      FHeader.SetBounds(0, 0, LExtent, Height)
    else
      FHeader.SetBounds(0, 0, Width, LExtent);
    if HandleAllocated and (Parent <> nil) and Parent.HandleAllocated and
      not (csDesigning in ComponentState) then
      FHeader.BringToFront;
  end;
  for I := 0 to PageCount - 1 do
  begin
    Pages[I].Padding.Top := 0;
    Pages[I].Padding.Left := 0;
    if Orientation = mtoVertical then
      Pages[I].Padding.Left := LExtent + ScaleMetric(4)
    else
      Pages[I].Padding.Top := LExtent + ScaleMetric(4);
  end;
end;

end.
