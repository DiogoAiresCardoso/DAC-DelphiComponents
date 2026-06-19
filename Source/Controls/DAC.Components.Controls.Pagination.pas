unit MaxxRural.Components.Controls.Pagination;

interface

uses
  System.Classes,
  Winapi.Messages,
  Vcl.Controls,
  Vcl.Graphics,
  MaxxRural.Components.Controls.Button,
  MaxxRural.Components.Controls.ComboBox,
  MaxxRural.Components.DesignSystem.IconAssets;

type
  TMaxxRuralPagination = class(TCustomControl)
  private
    FButtons: array[0..8] of TMaxxRuralButton;
    FPageCount: Integer;
    FPageIndex: Integer;
    FPageSize: Integer;
    FPageSizeCombo: TMaxxRuralComboBox;
    FPageSizeItems: TStringList;
    FPageSizeText: string;
    FShowPageSize: Boolean;
    FOnChange: TNotifyEvent;
    procedure ButtonClick(Sender: TObject);
    procedure CMEnabledChanged(var AMessage: TMessage); message CM_ENABLEDCHANGED;
    procedure CMShowingChanged(var AMessage: TMessage); message CM_SHOWINGCHANGED;
    procedure ComboChange(Sender: TObject);
    function CreatePaginationButton(const AIndex: Integer): TMaxxRuralButton;
    function ExtractPageSize(const AText: string; const ADefault: Integer): Integer;
    function GetPageSizeItems: TStrings;
    function IsParentChainVisible: Boolean;
    function PageButtonCount: Integer;
    function PageButtonStart: Integer;
    function PageSizeDisplayText(const AValue: Integer): string;
    procedure PageSizeItemsChanged(Sender: TObject);
    procedure RefreshChildren(const AUpdateCombo: Boolean = False);
    procedure SelectButton(const AIndex: Integer);
    procedure SetPageCount(const AValue: Integer);
    procedure SetPageIndex(const AValue: Integer);
    procedure SetPageSize(const AValue: Integer);
    procedure SetPageSizeItems(const AValue: TStrings);
    procedure SetPageSizeText(const AValue: string);
    procedure SetShowPageSize(const AValue: Boolean);
    procedure UpdateButtonState;
    procedure UpdateChildZOrder;
    procedure UpdateComboItems;
    procedure UpdateLayout;
    procedure WMEraseBkgnd(var AMessage: TWMEraseBkgnd); message WM_ERASEBKGND;
  protected
    procedure ChangeScale(M, D: Integer); override;
    procedure CreateWnd; override;
    procedure Loaded; override;
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure Redraw;
  published
    property Align;
    property Anchors;
    property Constraints;
    property Enabled;
    property Hint;
    property PageCount: Integer read FPageCount write SetPageCount default 5;
    property PageIndex: Integer read FPageIndex write SetPageIndex default 1;
    property PageSize: Integer read FPageSize write SetPageSize default 10;
    property PageSizeItems: TStrings read GetPageSizeItems write SetPageSizeItems;
    property PageSizeText: string read FPageSizeText write SetPageSizeText;
    property ParentShowHint;
    property PopupMenu;
    property ShowHint;
    property ShowPageSize: Boolean read FShowPageSize write SetShowPageSize default True;
    property TabOrder;
    property TabStop default True;
    property Visible;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnClick;
    property OnDblClick;
    property OnEnter;
    property OnExit;
    property OnKeyDown;
    property OnKeyPress;
    property OnKeyUp;
    property OnMouseDown;
    property OnMouseEnter;
    property OnMouseLeave;
    property OnMouseMove;
    property OnMouseUp;
  end;

implementation

uses
  System.Math,
  System.SysUtils;

const
  CMaxPageButtons = 5;

constructor TMaxxRuralPagination.Create(AOwner: TComponent);
var
  I: Integer;
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csAcceptsControls, csClickEvents];
  Width := 520;
  Height := 40;
  TabStop := True;
  ParentColor := False;
  StyleElements := [];

  FPageCount := 5;
  FPageIndex := 1;
  FPageSize := 10;
  FPageSizeText := PageSizeDisplayText(FPageSize);
  FShowPageSize := True;

  FPageSizeItems := TStringList.Create;
  FPageSizeItems.OnChange := PageSizeItemsChanged;
  FPageSizeItems.Add(PageSizeDisplayText(10));
  FPageSizeItems.Add(PageSizeDisplayText(25));
  FPageSizeItems.Add(PageSizeDisplayText(50));
  FPageSizeItems.Add(PageSizeDisplayText(100));

  for I := Low(FButtons) to High(FButtons) do
    FButtons[I] := CreatePaginationButton(I);

  FPageSizeCombo := TMaxxRuralComboBox.Create(Self);
  FPageSizeCombo.Parent := Self;
  FPageSizeCombo.SetSubComponent(True);
  FPageSizeCombo.StyleElements := [];
  FPageSizeCombo.TabStop := True;
  FPageSizeCombo.OnChange := ComboChange;

  RefreshChildren(True);
end;

destructor TMaxxRuralPagination.Destroy;
begin
  FPageSizeItems.Free;
  inherited;
end;

procedure TMaxxRuralPagination.ButtonClick(Sender: TObject);
begin
  if Sender is TMaxxRuralButton then
    SelectButton(TMaxxRuralButton(Sender).Tag);
end;

procedure TMaxxRuralPagination.ChangeScale(M, D: Integer);
begin
  inherited;
  Redraw;
end;

procedure TMaxxRuralPagination.CMEnabledChanged(var AMessage: TMessage);
begin
  inherited;
  UpdateButtonState;
end;

procedure TMaxxRuralPagination.CMShowingChanged(var AMessage: TMessage);
begin
  inherited;
  if Showing then
    Redraw;
  if not Showing then
    RefreshChildren(False);
end;

procedure TMaxxRuralPagination.ComboChange(Sender: TObject);
begin
  if FPageSizeCombo = nil then
    Exit;

  SetPageSize(ExtractPageSize(FPageSizeCombo.Text, FPageSize));
end;

function TMaxxRuralPagination.CreatePaginationButton(
  const AIndex: Integer): TMaxxRuralButton;
begin
  Result := TMaxxRuralButton.Create(Self);
  Result.Parent := Self;
  Result.SetSubComponent(True);
  Result.Cursor := crHandPoint;
  Result.Kind := mbkSecondary;
  Result.Size := mbsSmall;
  Result.TabStop := True;
  Result.Tag := AIndex;
  Result.OnClick := ButtonClick;
end;

procedure TMaxxRuralPagination.CreateWnd;
begin
  inherited;
  Redraw;
end;

function TMaxxRuralPagination.ExtractPageSize(const AText: string;
  const ADefault: Integer): Integer;
var
  I: Integer;
  LDigits: string;
begin
  LDigits := '';
  for I := 1 to Length(AText) do
  begin
    if CharInSet(AText[I], ['0'..'9']) then
      LDigits := LDigits + AText[I]
    else if LDigits <> '' then
      Break;
  end;

  if not TryStrToInt(LDigits, Result) then
    Result := ADefault;
  Result := Max(1, Result);
end;

function TMaxxRuralPagination.GetPageSizeItems: TStrings;
begin
  Result := FPageSizeItems;
end;

function TMaxxRuralPagination.IsParentChainVisible: Boolean;
var
  LParent: TWinControl;
begin
  Result := Visible;
  LParent := Parent;
  while Result and (LParent <> nil) do
  begin
    Result := LParent.Visible;
    LParent := LParent.Parent;
  end;
end;

procedure TMaxxRuralPagination.Loaded;
begin
  inherited;
  Redraw;
end;

function TMaxxRuralPagination.PageButtonCount: Integer;
begin
  Result := Min(CMaxPageButtons, Max(0, FPageCount));
end;

function TMaxxRuralPagination.PageButtonStart: Integer;
var
  LHalf: Integer;
begin
  if FPageCount <= CMaxPageButtons then
    Exit(1);

  LHalf := CMaxPageButtons div 2;
  Result := FPageIndex - LHalf;
  Result := Max(1, Result);
  Result := Min(Result, FPageCount - CMaxPageButtons + 1);
end;

function TMaxxRuralPagination.PageSizeDisplayText(const AValue: Integer): string;
begin
  Result := Format('%d / pagina', [AValue]);
end;

procedure TMaxxRuralPagination.PageSizeItemsChanged(Sender: TObject);
begin
  if csDestroying in ComponentState then
    Exit;

  RefreshChildren(True);
  Redraw;
end;

procedure TMaxxRuralPagination.Resize;
begin
  inherited;
  Redraw;
end;

procedure TMaxxRuralPagination.Redraw;
var
  I: Integer;
begin
  RefreshChildren(False);
  for I := Low(FButtons) to High(FButtons) do
    if FButtons[I] <> nil then
      FButtons[I].Redraw;
  if FPageSizeCombo <> nil then
    FPageSizeCombo.Redraw;
  Invalidate;
end;

procedure TMaxxRuralPagination.SelectButton(const AIndex: Integer);
var
  LPage: Integer;
  LPageCount: Integer;
begin
  LPageCount := PageButtonCount;
  case AIndex of
    0:
      LPage := 1;
    1:
      LPage := FPageIndex - 1;
  else
    if AIndex = 2 + LPageCount then
      LPage := FPageIndex + 1
    else if AIndex = 3 + LPageCount then
      LPage := FPageCount
    else
      LPage := PageButtonStart + (AIndex - 2);
  end;

  SetPageIndex(LPage);
end;

procedure TMaxxRuralPagination.RefreshChildren(const AUpdateCombo: Boolean);
begin
  if csDestroying in ComponentState then
    Exit;

  if AUpdateCombo then
    UpdateComboItems;
  UpdateLayout;
  UpdateButtonState;
  UpdateChildZOrder;
end;

procedure TMaxxRuralPagination.SetPageCount(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(1, AValue);
  if FPageCount = LValue then
    Exit;

  FPageCount := LValue;
  if FPageIndex > FPageCount then
    FPageIndex := FPageCount;
  Redraw;
end;

procedure TMaxxRuralPagination.SetPageIndex(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(1, Min(AValue, FPageCount));
  if FPageIndex = LValue then
    Exit;

  FPageIndex := LValue;
  Redraw;
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TMaxxRuralPagination.SetPageSize(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(1, AValue);
  if FPageSize = LValue then
  begin
    FPageSizeText := PageSizeDisplayText(FPageSize);
    RefreshChildren(True);
    Exit;
  end;

  FPageSize := LValue;
  FPageSizeText := PageSizeDisplayText(FPageSize);
  RefreshChildren(True);
  Redraw;
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TMaxxRuralPagination.SetPageSizeItems(const AValue: TStrings);
begin
  FPageSizeItems.Assign(AValue);
  RefreshChildren(True);
  Redraw;
end;

procedure TMaxxRuralPagination.SetPageSizeText(const AValue: string);
begin
  if FPageSizeText = AValue then
    Exit;

  FPageSizeText := AValue;
  FPageSize := ExtractPageSize(AValue, FPageSize);
  RefreshChildren(True);
  Redraw;
end;

procedure TMaxxRuralPagination.SetShowPageSize(const AValue: Boolean);
begin
  if FShowPageSize = AValue then
    Exit;

  FShowPageSize := AValue;
  Redraw;
end;

procedure TMaxxRuralPagination.UpdateButtonState;
var
  I: Integer;
  LEnabled: Boolean;
  LPage: Integer;
  LPageCount: Integer;
begin
  LPageCount := PageButtonCount;

  for I := Low(FButtons) to High(FButtons) do
  begin
    if FButtons[I] = nil then
      Continue;

    LEnabled := Enabled and (FPageCount > 0);
    case I of
      0, 1:
        LEnabled := LEnabled and (FPageIndex > 1);
    else
      if I = 2 + LPageCount then
        LEnabled := LEnabled and (FPageIndex < FPageCount)
      else if I = 3 + LPageCount then
        LEnabled := LEnabled and (FPageIndex < FPageCount)
      else if (I >= 2) and (I < 2 + LPageCount) then
      begin
        LPage := PageButtonStart + (I - 2);
        FButtons[I].Caption := IntToStr(LPage);
        FButtons[I].Kind := mbkSecondary;
        FButtons[I].ShowIcon := False;
        if LPage = FPageIndex then
          FButtons[I].Kind := mbkPrimary;
      end
      else
        LEnabled := False;
    end;

    FButtons[I].Enabled := LEnabled;
  end;

  if FPageSizeCombo <> nil then
    FPageSizeCombo.Enabled := Enabled and FShowPageSize;
end;

procedure TMaxxRuralPagination.UpdateChildZOrder;
var
  I: Integer;
begin
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    Exit;
  if csDesigning in ComponentState then
    Exit;
  if not HandleAllocated then
    Exit;
  if not Showing then
    Exit;

  for I := Low(FButtons) to High(FButtons) do
    if (FButtons[I] <> nil) and FButtons[I].Visible then
      FButtons[I].BringToFront;

  if (FPageSizeCombo <> nil) and FPageSizeCombo.Visible then
    FPageSizeCombo.BringToFront;
end;

procedure TMaxxRuralPagination.UpdateComboItems;
var
  LIndex: Integer;
  LText: string;
begin
  if FPageSizeCombo = nil then
    Exit;

  LText := PageSizeDisplayText(FPageSize);
  FPageSizeText := LText;
  FPageSizeCombo.Items.Assign(FPageSizeItems);
  LIndex := FPageSizeCombo.Items.IndexOf(LText);
  if LIndex < 0 then
  begin
    FPageSizeCombo.Items.Add(LText);
    LIndex := FPageSizeCombo.Items.IndexOf(LText);
  end;
  FPageSizeCombo.ItemIndex := LIndex;
  FPageSizeCombo.Text := LText;
end;

procedure TMaxxRuralPagination.UpdateLayout;
var
  I: Integer;
  LButtonSize: Integer;
  LGap: Integer;
  LLeft: Integer;
  LPage: Integer;
  LPageCount: Integer;
  LShowChildren: Boolean;
  LTop: Integer;
begin
  DisableAlign;
  try
    LButtonSize := 32;
    LGap := 8;
    LTop := Max(0, (Height - LButtonSize) div 2);
    LLeft := 0;
    LPageCount := PageButtonCount;
    LShowChildren := IsParentChainVisible or (csDesigning in ComponentState);

    for I := Low(FButtons) to High(FButtons) do
    begin
      if FButtons[I] = nil then
        Continue;

      if FButtons[I].Parent <> Self then
        FButtons[I].Parent := Self;
      FButtons[I].Visible := LShowChildren and (I < LPageCount + 4);
      if not FButtons[I].Visible then
        Continue;

      FButtons[I].SetBounds(LLeft, LTop, LButtonSize, LButtonSize);
      FButtons[I].ShowIcon := I < 2;
      FButtons[I].IconSize := 14;
      FButtons[I].Kind := mbkSecondary;

      case I of
        0:
          begin
            FButtons[I].Caption := '';
            FButtons[I].IconKind := mikFirstPage;
            FButtons[I].ShowIcon := True;
          end;
        1:
          begin
            FButtons[I].Caption := '';
            FButtons[I].IconKind := mikChevronLeft;
            FButtons[I].ShowIcon := True;
          end;
      else
        if I = 2 + LPageCount then
        begin
          FButtons[I].Caption := '';
          FButtons[I].IconKind := mikChevronRight;
          FButtons[I].ShowIcon := True;
        end
        else if I = 3 + LPageCount then
        begin
          FButtons[I].Caption := '';
          FButtons[I].IconKind := mikLastPage;
          FButtons[I].ShowIcon := True;
        end
        else
        begin
          LPage := PageButtonStart + (I - 2);
          FButtons[I].Caption := IntToStr(LPage);
          FButtons[I].ShowIcon := False;
        end;
      end;

      Inc(LLeft, LButtonSize + LGap);
    end;

    if FPageSizeCombo <> nil then
    begin
      if FPageSizeCombo.Parent <> Self then
        FPageSizeCombo.Parent := Self;
      FPageSizeCombo.Visible := LShowChildren and FShowPageSize;
      if FPageSizeCombo.Visible then
        FPageSizeCombo.SetBounds(Max(LLeft + 16, Width - 132), LTop - 2, 132,
          LButtonSize + 4);
    end;
  finally
    EnableAlign;
  end;
end;

procedure TMaxxRuralPagination.WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
begin
  AMessage.Result := 1;
end;

end.
