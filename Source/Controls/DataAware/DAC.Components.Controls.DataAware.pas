unit MaxxRural.Components.Controls.DataAware;

interface

uses
  System.Classes,
  Data.DB,
  Winapi.Messages,
  Vcl.Controls,
  Vcl.DBCtrls,
  MaxxRural.Components.Controls.ComboBox,
  MaxxRural.Components.Controls.DateTimePicker,
  MaxxRural.Components.Controls.Edit,
  MaxxRural.Components.Controls.Memo,
  MaxxRural.Components.Controls.Selectors;

type
  TMaxxRuralDBEdit = class(TMaxxRuralEdit)
  private
    FDataLink: TFieldDataLink;
    FOnChange: TNotifyEvent;
    procedure ControlChange(Sender: TObject);
    procedure DataChange(Sender: TObject);
    procedure EditingChange(Sender: TObject);
    function GetDataField: string;
    function GetDataSource: TDataSource;
    procedure SetDataField(const AValue: string);
    procedure SetDataSource(const AValue: TDataSource);
    procedure UpdateData(Sender: TObject);
    procedure CMExit(var AMessage: TCMExit); message CM_EXIT;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property DataField: string read GetDataField write SetDataField;
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TMaxxRuralDBMemo = class(TMaxxRuralMemo)
  private
    FDataLink: TFieldDataLink;
    FOnChange: TNotifyEvent;
    procedure ControlChange(Sender: TObject);
    procedure DataChange(Sender: TObject);
    procedure EditingChange(Sender: TObject);
    function GetDataField: string;
    function GetDataSource: TDataSource;
    procedure SetDataField(const AValue: string);
    procedure SetDataSource(const AValue: TDataSource);
    procedure UpdateData(Sender: TObject);
    procedure CMExit(var AMessage: TCMExit); message CM_EXIT;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property DataField: string read GetDataField write SetDataField;
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TMaxxRuralDBComboBox = class(TMaxxRuralComboBox)
  private
    FDataLink: TFieldDataLink;
    FOnChange: TNotifyEvent;
    procedure ControlChange(Sender: TObject);
    procedure DataChange(Sender: TObject);
    procedure EditingChange(Sender: TObject);
    function GetDataField: string;
    function GetDataSource: TDataSource;
    procedure SetDataField(const AValue: string);
    procedure SetDataSource(const AValue: TDataSource);
    procedure UpdateData(Sender: TObject);
    procedure CMExit(var AMessage: TCMExit); message CM_EXIT;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property DataField: string read GetDataField write SetDataField;
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TMaxxRuralDBDateTimePicker = class(TMaxxRuralDateTimePicker)
  private
    FDataLink: TFieldDataLink;
    FOnChange: TNotifyEvent;
    procedure ControlChange(Sender: TObject);
    procedure DataChange(Sender: TObject);
    procedure EditingChange(Sender: TObject);
    function GetDataField: string;
    function GetDataSource: TDataSource;
    procedure SetDataField(const AValue: string);
    procedure SetDataSource(const AValue: TDataSource);
    procedure UpdateData(Sender: TObject);
    procedure CMExit(var AMessage: TCMExit); message CM_EXIT;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property DataField: string read GetDataField write SetDataField;
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TMaxxRuralDBCheckBox = class(TMaxxRuralCheckBox)
  private
    FDataLink: TFieldDataLink;
    FOnChange: TNotifyEvent;
    procedure ControlChange(Sender: TObject);
    procedure DataChange(Sender: TObject);
    function GetDataField: string;
    function GetDataSource: TDataSource;
    procedure SetDataField(const AValue: string);
    procedure SetDataSource(const AValue: TDataSource);
    procedure UpdateData(Sender: TObject);
    procedure CMExit(var AMessage: TCMExit); message CM_EXIT;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property DataField: string read GetDataField write SetDataField;
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TMaxxRuralDBRadioButton = class(TMaxxRuralRadioButton)
  private
    FDataLink: TFieldDataLink;
    FOnChange: TNotifyEvent;
    procedure ControlChange(Sender: TObject);
    procedure DataChange(Sender: TObject);
    function GetDataField: string;
    function GetDataSource: TDataSource;
    procedure SetDataField(const AValue: string);
    procedure SetDataSource(const AValue: TDataSource);
    procedure UpdateData(Sender: TObject);
    procedure CMExit(var AMessage: TCMExit); message CM_EXIT;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property DataField: string read GetDataField write SetDataField;
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TMaxxRuralDBToggleSwitch = class(TMaxxRuralToggleSwitch)
  private
    FDataLink: TFieldDataLink;
    FOnChange: TNotifyEvent;
    procedure ControlChange(Sender: TObject);
    procedure DataChange(Sender: TObject);
    function GetDataField: string;
    function GetDataSource: TDataSource;
    procedure SetDataField(const AValue: string);
    procedure SetDataSource(const AValue: TDataSource);
    procedure UpdateData(Sender: TObject);
    procedure CMExit(var AMessage: TCMExit); message CM_EXIT;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property DataField: string read GetDataField write SetDataField;
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

  TMaxxRuralDBSlider = class(TMaxxRuralSlider)
  private
    FDataLink: TFieldDataLink;
    FOnChange: TNotifyEvent;
    procedure ControlChange(Sender: TObject);
    procedure DataChange(Sender: TObject);
    function GetDataField: string;
    function GetDataSource: TDataSource;
    procedure SetDataField(const AValue: string);
    procedure SetDataSource(const AValue: TDataSource);
    procedure UpdateData(Sender: TObject);
    procedure CMExit(var AMessage: TCMExit); message CM_EXIT;
  protected
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  published
    property DataField: string read GetDataField write SetDataField;
    property DataSource: TDataSource read GetDataSource write SetDataSource;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
  end;

implementation

uses
  System.SysUtils;

procedure UpdateFieldText(AField: TField; const AText: string);
begin
  if AField = nil then
    Exit;
  if AText = '' then
    AField.Clear
  else
    AField.AsString := AText;
end;

{ TMaxxRuralDBEdit }

constructor TMaxxRuralDBEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDataLink := TFieldDataLink.Create;
  FDataLink.Control := Self;
  FDataLink.OnDataChange := DataChange;
  FDataLink.OnEditingChange := EditingChange;
  FDataLink.OnUpdateData := UpdateData;
  inherited OnChange := ControlChange;
end;

destructor TMaxxRuralDBEdit.Destroy;
begin
  FDataLink.Free;
  inherited;
end;

procedure TMaxxRuralDBEdit.CMExit(var AMessage: TCMExit);
begin
  try
    FDataLink.UpdateRecord;
  finally
    inherited;
  end;
end;

procedure TMaxxRuralDBEdit.ControlChange(Sender: TObject);
begin
  FDataLink.Modified;
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TMaxxRuralDBEdit.DataChange(Sender: TObject);
begin
  if FDataLink.Field <> nil then
    Text := FDataLink.Field.DisplayText
  else
    Text := '';
end;

procedure TMaxxRuralDBEdit.EditingChange(Sender: TObject);
begin
  ReadOnly := not FDataLink.CanModify;
end;

function TMaxxRuralDBEdit.GetDataField: string;
begin
  Result := FDataLink.FieldName;
end;

function TMaxxRuralDBEdit.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

procedure TMaxxRuralDBEdit.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (FDataLink <> nil) and
    (AComponent = FDataLink.DataSource) then
    FDataLink.DataSource := nil;
end;

procedure TMaxxRuralDBEdit.SetDataField(const AValue: string);
begin
  FDataLink.FieldName := AValue;
end;

procedure TMaxxRuralDBEdit.SetDataSource(const AValue: TDataSource);
begin
  FDataLink.DataSource := AValue;
  if AValue <> nil then
    AValue.FreeNotification(Self);
end;

procedure TMaxxRuralDBEdit.UpdateData(Sender: TObject);
begin
  UpdateFieldText(FDataLink.Field, Text);
end;

{ TMaxxRuralDBMemo }

constructor TMaxxRuralDBMemo.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDataLink := TFieldDataLink.Create;
  FDataLink.Control := Self;
  FDataLink.OnDataChange := DataChange;
  FDataLink.OnEditingChange := EditingChange;
  FDataLink.OnUpdateData := UpdateData;
  inherited OnChange := ControlChange;
end;

destructor TMaxxRuralDBMemo.Destroy;
begin
  FDataLink.Free;
  inherited;
end;

procedure TMaxxRuralDBMemo.CMExit(var AMessage: TCMExit);
begin
  try
    FDataLink.UpdateRecord;
  finally
    inherited;
  end;
end;

procedure TMaxxRuralDBMemo.ControlChange(Sender: TObject);
begin
  FDataLink.Modified;
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TMaxxRuralDBMemo.DataChange(Sender: TObject);
begin
  if FDataLink.Field <> nil then
    Text := FDataLink.Field.AsString
  else
    Text := '';
end;

procedure TMaxxRuralDBMemo.EditingChange(Sender: TObject);
begin
  ReadOnly := not FDataLink.CanModify;
end;

function TMaxxRuralDBMemo.GetDataField: string;
begin
  Result := FDataLink.FieldName;
end;

function TMaxxRuralDBMemo.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

procedure TMaxxRuralDBMemo.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (FDataLink <> nil) and
    (AComponent = FDataLink.DataSource) then
    FDataLink.DataSource := nil;
end;

procedure TMaxxRuralDBMemo.SetDataField(const AValue: string);
begin
  FDataLink.FieldName := AValue;
end;

procedure TMaxxRuralDBMemo.SetDataSource(const AValue: TDataSource);
begin
  FDataLink.DataSource := AValue;
  if AValue <> nil then
    AValue.FreeNotification(Self);
end;

procedure TMaxxRuralDBMemo.UpdateData(Sender: TObject);
begin
  UpdateFieldText(FDataLink.Field, Text);
end;

{ TMaxxRuralDBComboBox }

constructor TMaxxRuralDBComboBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDataLink := TFieldDataLink.Create;
  FDataLink.Control := Self;
  FDataLink.OnDataChange := DataChange;
  FDataLink.OnEditingChange := EditingChange;
  FDataLink.OnUpdateData := UpdateData;
  inherited OnChange := ControlChange;
end;

destructor TMaxxRuralDBComboBox.Destroy;
begin
  FDataLink.Free;
  inherited;
end;

procedure TMaxxRuralDBComboBox.CMExit(var AMessage: TCMExit);
begin
  try
    FDataLink.UpdateRecord;
  finally
    inherited;
  end;
end;

procedure TMaxxRuralDBComboBox.ControlChange(Sender: TObject);
begin
  FDataLink.Modified;
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TMaxxRuralDBComboBox.DataChange(Sender: TObject);
var
  LIndex: Integer;
  LText: string;
begin
  if FDataLink.Field <> nil then
    LText := FDataLink.Field.DisplayText
  else
    LText := '';

  Text := LText;
  LIndex := Items.IndexOf(LText);
  if LIndex >= 0 then
    ItemIndex := LIndex;
end;

procedure TMaxxRuralDBComboBox.EditingChange(Sender: TObject);
begin
  Enabled := FDataLink.CanModify;
end;

function TMaxxRuralDBComboBox.GetDataField: string;
begin
  Result := FDataLink.FieldName;
end;

function TMaxxRuralDBComboBox.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

procedure TMaxxRuralDBComboBox.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (FDataLink <> nil) and
    (AComponent = FDataLink.DataSource) then
    FDataLink.DataSource := nil;
end;

procedure TMaxxRuralDBComboBox.SetDataField(const AValue: string);
begin
  FDataLink.FieldName := AValue;
end;

procedure TMaxxRuralDBComboBox.SetDataSource(const AValue: TDataSource);
begin
  FDataLink.DataSource := AValue;
  if AValue <> nil then
    AValue.FreeNotification(Self);
end;

procedure TMaxxRuralDBComboBox.UpdateData(Sender: TObject);
begin
  UpdateFieldText(FDataLink.Field, Text);
end;

{ TMaxxRuralDBDateTimePicker }

constructor TMaxxRuralDBDateTimePicker.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDataLink := TFieldDataLink.Create;
  FDataLink.Control := Self;
  FDataLink.OnDataChange := DataChange;
  FDataLink.OnEditingChange := EditingChange;
  FDataLink.OnUpdateData := UpdateData;
  inherited OnChange := ControlChange;
end;

destructor TMaxxRuralDBDateTimePicker.Destroy;
begin
  FDataLink.Free;
  inherited;
end;

procedure TMaxxRuralDBDateTimePicker.CMExit(var AMessage: TCMExit);
begin
  try
    FDataLink.UpdateRecord;
  finally
    inherited;
  end;
end;

procedure TMaxxRuralDBDateTimePicker.ControlChange(Sender: TObject);
begin
  FDataLink.Modified;
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TMaxxRuralDBDateTimePicker.DataChange(Sender: TObject);
begin
  if (FDataLink.Field <> nil) and not FDataLink.Field.IsNull then
    DateTime := FDataLink.Field.AsDateTime;
end;

procedure TMaxxRuralDBDateTimePicker.EditingChange(Sender: TObject);
begin
  Enabled := FDataLink.CanModify;
end;

function TMaxxRuralDBDateTimePicker.GetDataField: string;
begin
  Result := FDataLink.FieldName;
end;

function TMaxxRuralDBDateTimePicker.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

procedure TMaxxRuralDBDateTimePicker.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (FDataLink <> nil) and
    (AComponent = FDataLink.DataSource) then
    FDataLink.DataSource := nil;
end;

procedure TMaxxRuralDBDateTimePicker.SetDataField(const AValue: string);
begin
  FDataLink.FieldName := AValue;
end;

procedure TMaxxRuralDBDateTimePicker.SetDataSource(const AValue: TDataSource);
begin
  FDataLink.DataSource := AValue;
  if AValue <> nil then
    AValue.FreeNotification(Self);
end;

procedure TMaxxRuralDBDateTimePicker.UpdateData(Sender: TObject);
begin
  if FDataLink.Field <> nil then
    FDataLink.Field.AsDateTime := DateTime;
end;

{ Boolean controls }

constructor TMaxxRuralDBCheckBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDataLink := TFieldDataLink.Create;
  FDataLink.Control := Self;
  FDataLink.OnDataChange := DataChange;
  FDataLink.OnUpdateData := UpdateData;
  inherited OnChange := ControlChange;
end;

destructor TMaxxRuralDBCheckBox.Destroy;
begin
  FDataLink.Free;
  inherited;
end;

procedure TMaxxRuralDBCheckBox.CMExit(var AMessage: TCMExit);
begin
  try
    FDataLink.UpdateRecord;
  finally
    inherited;
  end;
end;

procedure TMaxxRuralDBCheckBox.ControlChange(Sender: TObject);
begin
  FDataLink.Modified;
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TMaxxRuralDBCheckBox.DataChange(Sender: TObject);
begin
  Checked := (FDataLink.Field <> nil) and FDataLink.Field.AsBoolean;
end;

function TMaxxRuralDBCheckBox.GetDataField: string;
begin
  Result := FDataLink.FieldName;
end;

function TMaxxRuralDBCheckBox.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

procedure TMaxxRuralDBCheckBox.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (FDataLink <> nil) and
    (AComponent = FDataLink.DataSource) then
    FDataLink.DataSource := nil;
end;

procedure TMaxxRuralDBCheckBox.SetDataField(const AValue: string);
begin
  FDataLink.FieldName := AValue;
end;

procedure TMaxxRuralDBCheckBox.SetDataSource(const AValue: TDataSource);
begin
  FDataLink.DataSource := AValue;
  if AValue <> nil then
    AValue.FreeNotification(Self);
end;

procedure TMaxxRuralDBCheckBox.UpdateData(Sender: TObject);
begin
  if FDataLink.Field <> nil then
    FDataLink.Field.AsBoolean := Checked;
end;

constructor TMaxxRuralDBRadioButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDataLink := TFieldDataLink.Create;
  FDataLink.Control := Self;
  FDataLink.OnDataChange := DataChange;
  FDataLink.OnUpdateData := UpdateData;
  inherited OnChange := ControlChange;
end;

destructor TMaxxRuralDBRadioButton.Destroy;
begin
  FDataLink.Free;
  inherited;
end;

procedure TMaxxRuralDBRadioButton.CMExit(var AMessage: TCMExit);
begin
  try
    FDataLink.UpdateRecord;
  finally
    inherited;
  end;
end;

procedure TMaxxRuralDBRadioButton.ControlChange(Sender: TObject);
begin
  FDataLink.Modified;
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TMaxxRuralDBRadioButton.DataChange(Sender: TObject);
begin
  Checked := (FDataLink.Field <> nil) and FDataLink.Field.AsBoolean;
end;

function TMaxxRuralDBRadioButton.GetDataField: string;
begin
  Result := FDataLink.FieldName;
end;

function TMaxxRuralDBRadioButton.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

procedure TMaxxRuralDBRadioButton.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (FDataLink <> nil) and
    (AComponent = FDataLink.DataSource) then
    FDataLink.DataSource := nil;
end;

procedure TMaxxRuralDBRadioButton.SetDataField(const AValue: string);
begin
  FDataLink.FieldName := AValue;
end;

procedure TMaxxRuralDBRadioButton.SetDataSource(const AValue: TDataSource);
begin
  FDataLink.DataSource := AValue;
  if AValue <> nil then
    AValue.FreeNotification(Self);
end;

procedure TMaxxRuralDBRadioButton.UpdateData(Sender: TObject);
begin
  if FDataLink.Field <> nil then
    FDataLink.Field.AsBoolean := Checked;
end;

constructor TMaxxRuralDBToggleSwitch.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDataLink := TFieldDataLink.Create;
  FDataLink.Control := Self;
  FDataLink.OnDataChange := DataChange;
  FDataLink.OnUpdateData := UpdateData;
  inherited OnChange := ControlChange;
end;

destructor TMaxxRuralDBToggleSwitch.Destroy;
begin
  FDataLink.Free;
  inherited;
end;

procedure TMaxxRuralDBToggleSwitch.CMExit(var AMessage: TCMExit);
begin
  try
    FDataLink.UpdateRecord;
  finally
    inherited;
  end;
end;

procedure TMaxxRuralDBToggleSwitch.ControlChange(Sender: TObject);
begin
  FDataLink.Modified;
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TMaxxRuralDBToggleSwitch.DataChange(Sender: TObject);
begin
  Checked := (FDataLink.Field <> nil) and FDataLink.Field.AsBoolean;
end;

function TMaxxRuralDBToggleSwitch.GetDataField: string;
begin
  Result := FDataLink.FieldName;
end;

function TMaxxRuralDBToggleSwitch.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

procedure TMaxxRuralDBToggleSwitch.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (FDataLink <> nil) and
    (AComponent = FDataLink.DataSource) then
    FDataLink.DataSource := nil;
end;

procedure TMaxxRuralDBToggleSwitch.SetDataField(const AValue: string);
begin
  FDataLink.FieldName := AValue;
end;

procedure TMaxxRuralDBToggleSwitch.SetDataSource(const AValue: TDataSource);
begin
  FDataLink.DataSource := AValue;
  if AValue <> nil then
    AValue.FreeNotification(Self);
end;

procedure TMaxxRuralDBToggleSwitch.UpdateData(Sender: TObject);
begin
  if FDataLink.Field <> nil then
    FDataLink.Field.AsBoolean := Checked;
end;

{ TMaxxRuralDBSlider }

constructor TMaxxRuralDBSlider.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDataLink := TFieldDataLink.Create;
  FDataLink.Control := Self;
  FDataLink.OnDataChange := DataChange;
  FDataLink.OnUpdateData := UpdateData;
  inherited OnChange := ControlChange;
end;

destructor TMaxxRuralDBSlider.Destroy;
begin
  FDataLink.Free;
  inherited;
end;

procedure TMaxxRuralDBSlider.CMExit(var AMessage: TCMExit);
begin
  try
    FDataLink.UpdateRecord;
  finally
    inherited;
  end;
end;

procedure TMaxxRuralDBSlider.ControlChange(Sender: TObject);
begin
  FDataLink.Modified;
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TMaxxRuralDBSlider.DataChange(Sender: TObject);
begin
  if FDataLink.Field <> nil then
    Value := FDataLink.Field.AsInteger;
end;

function TMaxxRuralDBSlider.GetDataField: string;
begin
  Result := FDataLink.FieldName;
end;

function TMaxxRuralDBSlider.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

procedure TMaxxRuralDBSlider.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (FDataLink <> nil) and
    (AComponent = FDataLink.DataSource) then
    FDataLink.DataSource := nil;
end;

procedure TMaxxRuralDBSlider.SetDataField(const AValue: string);
begin
  FDataLink.FieldName := AValue;
end;

procedure TMaxxRuralDBSlider.SetDataSource(const AValue: TDataSource);
begin
  FDataLink.DataSource := AValue;
  if AValue <> nil then
    AValue.FreeNotification(Self);
end;

procedure TMaxxRuralDBSlider.UpdateData(Sender: TObject);
begin
  if FDataLink.Field <> nil then
    FDataLink.Field.AsInteger := Value;
end;

end.
