unit DAC.Components.Controls.Tabs;

interface

uses
  System.Classes,
  System.Types,
  System.UITypes,
  Winapi.Messages,
  Vcl.ComCtrls,
  Vcl.Controls,
  Vcl.Graphics;

type
  TDACTabs = class;

  TDACTabHeaderControl = class(TCustomControl)
  private
    FTabs: TDACTabs;
    FHotIndex: Integer;
    function ScaleMetric(const AValue: Integer): Integer;
    function TabRectByOrdinal(const AOrdinal: Integer): TRect;
    function TabAt(const X, Y: Integer): Integer;
  protected
    procedure CMMouseLeave(var AMessage: TMessage); message CM_MOUSELEAVE;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState; X,
      Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure Paint; override;
  public
    constructor CreateForTabs(ATabs: TDACTabs);
  end;

  TDACTabOrientation = (
    mtoHorizontal,
    mtoVertical
  );

  TDACTabAppearance = (
    mtaUnderline,
    mtaPills
  );

  TDACTabs = class(TPageControl)
  private
    FAppearance: TDACTabAppearance;
    FContentColor: TAlphaColor;
    FCornerRadius: Integer;
    FHeader: TDACTabHeaderControl;
    FHotIndex: Integer;
    FShowContentBorder: Boolean;
    function GetActiveIndex: Integer;
    function GetOrientation: TDACTabOrientation;
    function HeaderHeight: Integer;
    procedure SetActiveIndex(const AValue: Integer);
    procedure SetAppearance(const AValue: TDACTabAppearance);
    procedure SetContentColor(const AValue: TAlphaColor);
    procedure SetCornerRadius(const AValue: Integer);
    procedure SetOrientation(const AValue: TDACTabOrientation);
    procedure SetShowContentBorder(const AValue: Boolean);
    procedure CMMouseLeave(var AMessage: TMessage); message CM_MOUSELEAVE;
    procedure WMMouseMove(var AMessage: TWMMouseMove); message WM_MOUSEMOVE;
    function ScaleMetric(const AValue: Integer): Integer;
    function TabCaption(const AIndex: Integer): string;
    function TabTextColor(const AActive, AHot, AEnabled: Boolean): TColor;
    procedure ApplyPageStyle;
    procedure InvalidateTabs;
    procedure UpdateHeaderBounds;
  protected
    procedure Change; override;
    procedure ChangeScale(M, D: Integer; isDpiChange: Boolean); override;
    procedure CreateWnd; override;
    procedure DrawTab(TabIndex: Integer; const Rect: TRect;
      Active: Boolean); override;
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
  Winapi.Windows,
  System.Math,
  Vcl.Forms,
  DAC.Components.DesignSystem.ColorTokens;

constructor TDACTabHeaderControl.CreateForTabs(ATabs: TDACTabs);
begin
  inherited Create(ATabs);
  FTabs := ATabs;
  FHotIndex := -1;
  ControlStyle := ControlStyle + [csOpaque];
  ParentColor := False;
  Color := clWhite;
  SetSubComponent(True);
end;

procedure TDACTabHeaderControl.CMMouseLeave(var AMessage: TMessage);
begin
  inherited;
  if FHotIndex <> -1 then
  begin
    FHotIndex := -1;
    Invalidate;
  end;
end;

procedure TDACTabHeaderControl.MouseDown(Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  LIndex: Integer;
begin
  inherited;
  if (Button <> mbLeft) or (FTabs = nil) then
    Exit;

  LIndex := TabAt(X, Y);
  if (LIndex >= 0) and (LIndex < FTabs.PageCount) and
    FTabs.Pages[LIndex].Enabled then
  begin
    FTabs.ActivePage := FTabs.Pages[LIndex];
    FTabs.SetFocus;
    Invalidate;
  end;
end;

procedure TDACTabHeaderControl.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LIndex: Integer;
begin
  inherited;
  LIndex := TabAt(X, Y);
  if LIndex <> FHotIndex then
  begin
    FHotIndex := LIndex;
    Invalidate;
  end;
end;

procedure TDACTabHeaderControl.Paint;
var
  I: Integer;
  LActive: Boolean;
  LBarRect: TRect;
  LCaption: string;
  LEnabled: Boolean;
  LHot: Boolean;
  LOrdinal: Integer;
  LPage: TTabSheet;
  LRect: TRect;
  LTextFlags: Cardinal;
  LUnderline: TRect;
begin
  inherited;
  if FTabs = nil then
    Exit;

  Canvas.Brush.Style := bsSolid;
  Canvas.Brush.Color := clWhite;
  Canvas.FillRect(ClientRect);

  LBarRect := ClientRect;
  InflateRect(LBarRect, -ScaleMetric(1), -ScaleMetric(4));
  Canvas.Pen.Color := TDACComponentColors.ToVclColor(TDACComponentColors.ControlBorder);
  Canvas.Pen.Width := 1;
  Canvas.Brush.Color := TDACComponentColors.ToVclColor(TDACComponentColors.White);
  Canvas.RoundRect(LBarRect.Left, LBarRect.Top, LBarRect.Right,
    LBarRect.Bottom, ScaleMetric(10), ScaleMetric(10));

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

    Canvas.Font.Assign(FTabs.Font);
    Canvas.Font.Style := [];
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
    if FTabs.Appearance = mtaPills then
    begin
      InflateRect(LRect, -ScaleMetric(5), -ScaleMetric(8));
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
        Canvas.Brush.Color := clWhite;
        Canvas.Pen.Color := clWhite;
      end;
      if LActive or (LHot and LEnabled) then
        Canvas.RoundRect(LRect.Left, LRect.Top, LRect.Right, LRect.Bottom,
          ScaleMetric(20), ScaleMetric(20));
    end
    else
    begin
      InflateRect(LRect, -ScaleMetric(1), -ScaleMetric(5));
      if LActive then
        Canvas.Brush.Color := TDACComponentColors.ToVclColor(TDACComponentColors.Alpha(248, 252, 248))
      else if LHot and LEnabled then
        Canvas.Brush.Color := TDACComponentColors.ToVclColor(TDACComponentColors.Alpha(244, 250, 244))
      else
        Canvas.Brush.Color := clWhite;

      Canvas.Pen.Color := Canvas.Brush.Color;
      Canvas.RoundRect(LRect.Left, LRect.Top, LRect.Right, LRect.Bottom,
        ScaleMetric(8), ScaleMetric(8));

      if LEnabled and (LActive or LHot) then
      begin
        LUnderline := LRect;
        LUnderline.Top := LUnderline.Bottom - ScaleMetric(3);
        Canvas.Brush.Color := TDACComponentColors.ToVclColor(TDACComponentColors.PrimaryDark);
        if not LActive then
          Canvas.Brush.Color := TDACComponentColors.ToVclColor(TDACComponentColors.PrimaryLight);
        Canvas.FillRect(LUnderline);
      end;
    end;

    LCaption := LPage.Caption;
    InflateRect(LRect, -ScaleMetric(10), 0);
    Canvas.Brush.Style := bsClear;
    LTextFlags := DT_CENTER or DT_VCENTER or DT_SINGLELINE or DT_END_ELLIPSIS;
    DrawText(Canvas.Handle, PChar(LCaption), Length(LCaption), LRect,
      LTextFlags);
  end;
end;

function TDACTabHeaderControl.ScaleMetric(const AValue: Integer): Integer;
begin
  Result := MulDiv(AValue, Screen.PixelsPerInch, 96);
  if (AValue > 0) and (Result < 1) then
    Result := 1;
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
    if PtInRect(TabRectByOrdinal(LOrdinal), Point(X, Y)) then
      Exit(I);
    Inc(LOrdinal);
  end;
end;

function TDACTabHeaderControl.TabRectByOrdinal(const AOrdinal: Integer): TRect;
var
  LCount: Integer;
  LWidth: Integer;
begin
  LCount := Max(1, FTabs.PageCount);
  LWidth := Max(ScaleMetric(76), (ClientWidth - ScaleMetric(2)) div LCount);
  Result := Rect(ScaleMetric(1) + (AOrdinal * LWidth), ScaleMetric(4),
    ScaleMetric(1) + ((AOrdinal + 1) * LWidth), Height - ScaleMetric(4));
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
  FHotIndex := -1;
  FShowContentBorder := True;

  OwnerDraw := False;
  Style := tsTabs;
  TabHeight := 1;
  TabWidth := 1;

  FHeader := TDACTabHeaderControl.CreateForTabs(Self);
  FHeader.Parent := Self;
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
  InvalidateTabs;
end;

procedure TDACTabs.CMMouseLeave(var AMessage: TMessage);
begin
  inherited;
  if FHotIndex <> -1 then
  begin
    FHotIndex := -1;
    InvalidateTabs;
  end;
end;

procedure TDACTabs.CreateWnd;
begin
  inherited;
  ApplyPageStyle;
end;

procedure TDACTabs.DrawTab(TabIndex: Integer; const Rect: TRect;
  Active: Boolean);
var
  LCaption: string;
  LContentRect: TRect;
  LEnabled: Boolean;
  LHot: Boolean;
  LIndicatorRect: TRect;
  LRect: TRect;
  LTextFlags: Cardinal;
begin
  LRect := Rect;
  LEnabled := Enabled and ((TabIndex < PageCount) and Pages[TabIndex].Enabled);
  LHot := TabIndex = FHotIndex;

  Canvas.Font.Assign(Font);
  Canvas.Font.Color := TabTextColor(Active, LHot, LEnabled);
  Canvas.Font.Style := [];
  if Active then
    Canvas.Font.Style := Canvas.Font.Style + [fsBold];

  Canvas.Pen.Color := TDACComponentColors.ToVclColor(TDACComponentColors.ControlBorder);
  Canvas.Brush.Style := bsSolid;

  if FAppearance = mtaPills then
  begin
    InflateRect(LRect, -ScaleMetric(4), -ScaleMetric(4));
    if Active then
      Canvas.Brush.Color := TDACComponentColors.ToVclColor(TDACComponentColors.Primary)
    else if LHot and LEnabled then
      Canvas.Brush.Color := TDACComponentColors.ToVclColor(TDACComponentColors.Alpha(232, 247, 228))
    else
      Canvas.Brush.Color := TDACComponentColors.ToVclColor(TDACComponentColors.White);

    Canvas.RoundRect(LRect.Left, LRect.Top, LRect.Right, LRect.Bottom,
      ScaleMetric(FCornerRadius), ScaleMetric(FCornerRadius));
  end
  else
  begin
    Canvas.Brush.Color := TDACComponentColors.ToVclColor(TDACComponentColors.White);
    Canvas.FillRect(LRect);

    if Active then
    begin
      LIndicatorRect := LRect;
      if TabPosition in [tpTop, tpBottom] then
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
      if TabPosition in [tpTop, tpBottom] then
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

  LCaption := TabCaption(TabIndex);
  LContentRect := LRect;
  InflateRect(LContentRect, -ScaleMetric(10), 0);
  Canvas.Brush.Style := bsClear;
  LTextFlags := DT_CENTER or DT_VCENTER or DT_SINGLELINE or DT_END_ELLIPSIS;
  DrawText(Canvas.Handle, PChar(LCaption), Length(LCaption), LContentRect,
    LTextFlags);
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

function TDACTabs.HeaderHeight: Integer;
begin
  Result := ScaleMetric(52);
end;

procedure TDACTabs.InvalidateTabs;
begin
  if FHeader <> nil then
    FHeader.Invalidate;
  if HandleAllocated then
    Invalidate;
end;

procedure TDACTabs.Loaded;
begin
  inherited;
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
  Result := MulDiv(AValue, Screen.PixelsPerInch, 96);
  if (AValue > 0) and (Result < 1) then
    Result := 1;
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
  if FAppearance = AValue then
    Exit;
  FAppearance := AValue;
  InvalidateTabs;
end;

procedure TDACTabs.SetContentColor(const AValue: TAlphaColor);
var
  LValue: TAlphaColor;
begin
  LValue := TDACComponentColors.Normalize(AValue);
  if FContentColor = LValue then
    Exit;
  FContentColor := LValue;
  ApplyPageStyle;
end;

procedure TDACTabs.SetCornerRadius(const AValue: Integer);
begin
  if FCornerRadius = AValue then
    Exit;
  FCornerRadius := Max(0, AValue);
  InvalidateTabs;
end;

procedure TDACTabs.SetOrientation(const AValue: TDACTabOrientation);
begin
  if AValue = mtoVertical then
    TabPosition := tpLeft
  else
    TabPosition := tpTop;
  InvalidateTabs;
end;

procedure TDACTabs.UpdateHeaderBounds;
var
  I: Integer;
  LPadding: Integer;
begin
  if FHeader <> nil then
  begin
    FHeader.SetBounds(0, 0, Width, HeaderHeight);
    if (not (csLoading in ComponentState)) and HandleAllocated then
      FHeader.BringToFront;
  end;

  LPadding := HeaderHeight + ScaleMetric(4);
  for I := 0 to PageCount - 1 do
    Pages[I].Padding.Top := LPadding;
end;

procedure TDACTabs.SetShowContentBorder(const AValue: Boolean);
begin
  if FShowContentBorder = AValue then
    Exit;
  FShowContentBorder := AValue;
  InvalidateTabs;
end;

function TDACTabs.TabCaption(const AIndex: Integer): string;
begin
  Result := '';
  if (AIndex >= 0) and (AIndex < Tabs.Count) then
    Result := Tabs[AIndex];
end;

function TDACTabs.TabTextColor(const AActive, AHot,
  AEnabled: Boolean): TColor;
begin
  if not AEnabled then
    Exit(TDACComponentColors.ToVclColor(TDACComponentColors.ControlTextDisabled));

  if FAppearance = mtaPills then
  begin
    if AActive then
      Exit(TDACComponentColors.ToVclColor(TDACComponentColors.White));
    if AHot then
      Exit(TDACComponentColors.ToVclColor(TDACComponentColors.PrimaryDark));
    Exit(TDACComponentColors.ToVclColor(TDACComponentColors.ControlText));
  end;

  if AActive then
    Result := TDACComponentColors.ToVclColor(TDACComponentColors.PrimaryDark)
  else if AHot then
    Result := TDACComponentColors.ToVclColor(TDACComponentColors.Primary)
  else
    Result := TDACComponentColors.ToVclColor(TDACComponentColors.Alpha(70, 82, 78));
end;

procedure TDACTabs.WMMouseMove(var AMessage: TWMMouseMove);
var
  LIndex: Integer;
begin
  inherited;
  LIndex := IndexOfTabAt(AMessage.XPos, AMessage.YPos);
  if LIndex <> FHotIndex then
  begin
    FHotIndex := LIndex;
    InvalidateTabs;
  end;
end;

end.
