unit DAC.Components.Controls.DBGrid.SelectionOptions;

interface

uses
  System.Classes,
  DAC.Components.Controls.DBGrid.Types;

type
  TDACDBGridSelectionOptions = class(TPersistent)
  private
    FAllowSelectAll: Boolean;
    FEnabled: Boolean;
    FFieldName: string;
    FOnChange: TNotifyEvent;
    FWidth: Integer;
    procedure Changed;
    procedure SetAllowSelectAll(const AValue: Boolean);
    procedure SetEnabled(const AValue: Boolean);
    procedure SetFieldName(const AValue: string);
    procedure SetWidth(const AValue: Integer);
  public
    constructor Create;
    procedure Assign(Source: TPersistent); override;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  published
    property AllowSelectAll: Boolean read FAllowSelectAll
      write SetAllowSelectAll default True;
    property Enabled: Boolean read FEnabled write SetEnabled default False;
    property FieldName: string read FFieldName write SetFieldName;
    property Width: Integer read FWidth write SetWidth
      default DACDBGridDefaultSelectionWidth;
  end;

implementation

uses
  System.Math;

constructor TDACDBGridSelectionOptions.Create;
begin
  inherited Create;
  FAllowSelectAll := True;
  FWidth := DACDBGridDefaultSelectionWidth;
end;

procedure TDACDBGridSelectionOptions.Assign(Source: TPersistent);
var
  LSource: TDACDBGridSelectionOptions;
begin
  if Source is TDACDBGridSelectionOptions then
  begin
    LSource := TDACDBGridSelectionOptions(Source);
    FAllowSelectAll := LSource.FAllowSelectAll;
    FEnabled := LSource.FEnabled;
    FFieldName := LSource.FFieldName;
    FWidth := LSource.FWidth;
    Changed;
  end
  else
    inherited Assign(Source);
end;

procedure TDACDBGridSelectionOptions.Changed;
begin
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TDACDBGridSelectionOptions.SetAllowSelectAll(const AValue: Boolean);
begin
  if FAllowSelectAll = AValue then Exit;
  FAllowSelectAll := AValue;
  Changed;
end;

procedure TDACDBGridSelectionOptions.SetEnabled(const AValue: Boolean);
begin
  if FEnabled = AValue then Exit;
  FEnabled := AValue;
  Changed;
end;

procedure TDACDBGridSelectionOptions.SetFieldName(const AValue: string);
begin
  if FFieldName = AValue then Exit;
  FFieldName := AValue;
  Changed;
end;

procedure TDACDBGridSelectionOptions.SetWidth(const AValue: Integer);
var
  LValue: Integer;
begin
  LValue := Max(24, AValue);
  if FWidth = LValue then Exit;
  FWidth := LValue;
  Changed;
end;

end.
