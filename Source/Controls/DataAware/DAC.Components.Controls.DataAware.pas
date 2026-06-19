unit DAC.Components.Controls.DataAware;

interface

uses
  System.Classes,
  Data.DB,
  Winapi.Messages,
  Vcl.Controls,
  Vcl.DBCtrls,
  DAC.Components.Controls.ComboBox,
  DAC.Components.Controls.DateTimePicker,
  DAC.Components.Controls.Edit,
  DAC.Components.Controls.Memo,
  DAC.Components.Controls.Selectors;

type
  TDACDBEdit = class(TDACEdit)
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

  TDACDBMemo = class(TDACMemo)
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

  TDACDBComboBox = class(TDACComboBox)
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

  TDACDBDateTimePicker = class(TDACDateTimePicker)
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

  TDACDBCheckBox = class(TDACCheckBox)
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

  TDACDBRadioButton = class(TDACRadioButton)
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

  TDACDBToggleSwitch = class(TDACToggleSwitch)
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

  TDACDBSlider = class(TDACSlider)
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

{ TDACDBEdit }

constructor TDACDBEdit.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDataLink := TFieldDataLink.Create;
  FDataLink.Control := Self;
  FDataLink.OnDataChange := DataChange;
  FDataLink.OnEditingChange := EditingChange;
  FDataLink.OnUpdateData := UpdateData;
  inherited OnChange := ControlChange;
end;

destructor TDACDBEdit.Destroy;
begin
  FDataLink.Free;
  inherited;
end;

procedure TDACDBEdit.CMExit(var AMessage: TCMExit);
begin
  try
    FDataLink.UpdateRecord;
  finally
    inherited;
  end;
end;

procedure TDACDBEdit.ControlChange(Sender: TObject);
begin
  FDataLink.Modified;
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TDACDBEdit.DataChange(Sender: TObject);
begin
  if FDataLink.Field <> nil then
    Text := FDataLink.Field.DisplayText
  else
    Text := '';
end;

procedure TDACDBEdit.EditingChange(Sender: TObject);
begin
  ReadOnly := not FDataLink.CanModify;
end;

function TDACDBEdit.GetDataField: string;
begin
  Result := FDataLink.FieldName;
end;

function TDACDBEdit.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

procedure TDACDBEdit.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (FDataLink <> nil) and
    (AComponent = FDataLink.DataSource) then
    FDataLink.DataSource := nil;
end;

procedure TDACDBEdit.SetDataField(const AValue: string);
begin
  FDataLink.FieldName := AValue;
end;

procedure TDACDBEdit.SetDataSource(const AValue: TDataSource);
begin
  FDataLink.DataSource := AValue;
  if AValue <> nil then
    AValue.FreeNotification(Self);
end;

procedure TDACDBEdit.UpdateData(Sender: TObject);
begin
  UpdateFieldText(FDataLink.Field, Text);
end;

{ TDACDBMemo }

constructor TDACDBMemo.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDataLink := TFieldDataLink.Create;
  FDataLink.Control := Self;
  FDataLink.OnDataChange := DataChange;
  FDataLink.OnEditingChange := EditingChange;
  FDataLink.OnUpdateData := UpdateData;
  inherited OnChange := ControlChange;
end;

destructor TDACDBMemo.Destroy;
begin
  FDataLink.Free;
  inherited;
end;

procedure TDACDBMemo.CMExit(var AMessage: TCMExit);
begin
  try
    FDataLink.UpdateRecord;
  finally
    inherited;
  end;
end;

procedure TDACDBMemo.ControlChange(Sender: TObject);
begin
  FDataLink.Modified;
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TDACDBMemo.DataChange(Sender: TObject);
begin
  if FDataLink.Field <> nil then
    Text := FDataLink.Field.AsString
  else
    Text := '';
end;

procedure TDACDBMemo.EditingChange(Sender: TObject);
begin
  ReadOnly := not FDataLink.CanModify;
end;

function TDACDBMemo.GetDataField: string;
begin
  Result := FDataLink.FieldName;
end;

function TDACDBMemo.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

procedure TDACDBMemo.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (FDataLink <> nil) and
    (AComponent = FDataLink.DataSource) then
    FDataLink.DataSource := nil;
end;

procedure TDACDBMemo.SetDataField(const AValue: string);
begin
  FDataLink.FieldName := AValue;
end;

procedure TDACDBMemo.SetDataSource(const AValue: TDataSource);
begin
  FDataLink.DataSource := AValue;
  if AValue <> nil then
    AValue.FreeNotification(Self);
end;

procedure TDACDBMemo.UpdateData(Sender: TObject);
begin
  UpdateFieldText(FDataLink.Field, Text);
end;

{ TDACDBComboBox }

constructor TDACDBComboBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDataLink := TFieldDataLink.Create;
  FDataLink.Control := Self;
  FDataLink.OnDataChange := DataChange;
  FDataLink.OnEditingChange := EditingChange;
  FDataLink.OnUpdateData := UpdateData;
  inherited OnChange := ControlChange;
end;

destructor TDACDBComboBox.Destroy;
begin
  FDataLink.Free;
  inherited;
end;

procedure TDACDBComboBox.CMExit(var AMessage: TCMExit);
begin
  try
    FDataLink.UpdateRecord;
  finally
    inherited;
  end;
end;

procedure TDACDBComboBox.ControlChange(Sender: TObject);
begin
  FDataLink.Modified;
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TDACDBComboBox.DataChange(Sender: TObject);
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

procedure TDACDBComboBox.EditingChange(Sender: TObject);
begin
  Enabled := FDataLink.CanModify;
end;

function TDACDBComboBox.GetDataField: string;
begin
  Result := FDataLink.FieldName;
end;

function TDACDBComboBox.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

procedure TDACDBComboBox.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (FDataLink <> nil) and
    (AComponent = FDataLink.DataSource) then
    FDataLink.DataSource := nil;
end;

procedure TDACDBComboBox.SetDataField(const AValue: string);
begin
  FDataLink.FieldName := AValue;
end;

procedure TDACDBComboBox.SetDataSource(const AValue: TDataSource);
begin
  FDataLink.DataSource := AValue;
  if AValue <> nil then
    AValue.FreeNotification(Self);
end;

procedure TDACDBComboBox.UpdateData(Sender: TObject);
begin
  UpdateFieldText(FDataLink.Field, Text);
end;

{ TDACDBDateTimePicker }

constructor TDACDBDateTimePicker.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDataLink := TFieldDataLink.Create;
  FDataLink.Control := Self;
  FDataLink.OnDataChange := DataChange;
  FDataLink.OnEditingChange := EditingChange;
  FDataLink.OnUpdateData := UpdateData;
  inherited OnChange := ControlChange;
end;

destructor TDACDBDateTimePicker.Destroy;
begin
  FDataLink.Free;
  inherited;
end;

procedure TDACDBDateTimePicker.CMExit(var AMessage: TCMExit);
begin
  try
    FDataLink.UpdateRecord;
  finally
    inherited;
  end;
end;

procedure TDACDBDateTimePicker.ControlChange(Sender: TObject);
begin
  FDataLink.Modified;
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TDACDBDateTimePicker.DataChange(Sender: TObject);
begin
  if (FDataLink.Field <> nil) and not FDataLink.Field.IsNull then
    DateTime := FDataLink.Field.AsDateTime;
end;

procedure TDACDBDateTimePicker.EditingChange(Sender: TObject);
begin
  Enabled := FDataLink.CanModify;
end;

function TDACDBDateTimePicker.GetDataField: string;
begin
  Result := FDataLink.FieldName;
end;

function TDACDBDateTimePicker.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

procedure TDACDBDateTimePicker.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (FDataLink <> nil) and
    (AComponent = FDataLink.DataSource) then
    FDataLink.DataSource := nil;
end;

procedure TDACDBDateTimePicker.SetDataField(const AValue: string);
begin
  FDataLink.FieldName := AValue;
end;

procedure TDACDBDateTimePicker.SetDataSource(const AValue: TDataSource);
begin
  FDataLink.DataSource := AValue;
  if AValue <> nil then
    AValue.FreeNotification(Self);
end;

procedure TDACDBDateTimePicker.UpdateData(Sender: TObject);
begin
  if FDataLink.Field <> nil then
    FDataLink.Field.AsDateTime := DateTime;
end;

{ Boolean controls }

constructor TDACDBCheckBox.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDataLink := TFieldDataLink.Create;
  FDataLink.Control := Self;
  FDataLink.OnDataChange := DataChange;
  FDataLink.OnUpdateData := UpdateData;
  inherited OnChange := ControlChange;
end;

destructor TDACDBCheckBox.Destroy;
begin
  FDataLink.Free;
  inherited;
end;

procedure TDACDBCheckBox.CMExit(var AMessage: TCMExit);
begin
  try
    FDataLink.UpdateRecord;
  finally
    inherited;
  end;
end;

procedure TDACDBCheckBox.ControlChange(Sender: TObject);
begin
  FDataLink.Modified;
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TDACDBCheckBox.DataChange(Sender: TObject);
begin
  Checked := (FDataLink.Field <> nil) and FDataLink.Field.AsBoolean;
end;

function TDACDBCheckBox.GetDataField: string;
begin
  Result := FDataLink.FieldName;
end;

function TDACDBCheckBox.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

procedure TDACDBCheckBox.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (FDataLink <> nil) and
    (AComponent = FDataLink.DataSource) then
    FDataLink.DataSource := nil;
end;

procedure TDACDBCheckBox.SetDataField(const AValue: string);
begin
  FDataLink.FieldName := AValue;
end;

procedure TDACDBCheckBox.SetDataSource(const AValue: TDataSource);
begin
  FDataLink.DataSource := AValue;
  if AValue <> nil then
    AValue.FreeNotification(Self);
end;

procedure TDACDBCheckBox.UpdateData(Sender: TObject);
begin
  if FDataLink.Field <> nil then
    FDataLink.Field.AsBoolean := Checked;
end;

constructor TDACDBRadioButton.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDataLink := TFieldDataLink.Create;
  FDataLink.Control := Self;
  FDataLink.OnDataChange := DataChange;
  FDataLink.OnUpdateData := UpdateData;
  inherited OnChange := ControlChange;
end;

destructor TDACDBRadioButton.Destroy;
begin
  FDataLink.Free;
  inherited;
end;

procedure TDACDBRadioButton.CMExit(var AMessage: TCMExit);
begin
  try
    FDataLink.UpdateRecord;
  finally
    inherited;
  end;
end;

procedure TDACDBRadioButton.ControlChange(Sender: TObject);
begin
  FDataLink.Modified;
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TDACDBRadioButton.DataChange(Sender: TObject);
begin
  Checked := (FDataLink.Field <> nil) and FDataLink.Field.AsBoolean;
end;

function TDACDBRadioButton.GetDataField: string;
begin
  Result := FDataLink.FieldName;
end;

function TDACDBRadioButton.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

procedure TDACDBRadioButton.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (FDataLink <> nil) and
    (AComponent = FDataLink.DataSource) then
    FDataLink.DataSource := nil;
end;

procedure TDACDBRadioButton.SetDataField(const AValue: string);
begin
  FDataLink.FieldName := AValue;
end;

procedure TDACDBRadioButton.SetDataSource(const AValue: TDataSource);
begin
  FDataLink.DataSource := AValue;
  if AValue <> nil then
    AValue.FreeNotification(Self);
end;

procedure TDACDBRadioButton.UpdateData(Sender: TObject);
begin
  if FDataLink.Field <> nil then
    FDataLink.Field.AsBoolean := Checked;
end;

constructor TDACDBToggleSwitch.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDataLink := TFieldDataLink.Create;
  FDataLink.Control := Self;
  FDataLink.OnDataChange := DataChange;
  FDataLink.OnUpdateData := UpdateData;
  inherited OnChange := ControlChange;
end;

destructor TDACDBToggleSwitch.Destroy;
begin
  FDataLink.Free;
  inherited;
end;

procedure TDACDBToggleSwitch.CMExit(var AMessage: TCMExit);
begin
  try
    FDataLink.UpdateRecord;
  finally
    inherited;
  end;
end;

procedure TDACDBToggleSwitch.ControlChange(Sender: TObject);
begin
  FDataLink.Modified;
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TDACDBToggleSwitch.DataChange(Sender: TObject);
begin
  Checked := (FDataLink.Field <> nil) and FDataLink.Field.AsBoolean;
end;

function TDACDBToggleSwitch.GetDataField: string;
begin
  Result := FDataLink.FieldName;
end;

function TDACDBToggleSwitch.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

procedure TDACDBToggleSwitch.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (FDataLink <> nil) and
    (AComponent = FDataLink.DataSource) then
    FDataLink.DataSource := nil;
end;

procedure TDACDBToggleSwitch.SetDataField(const AValue: string);
begin
  FDataLink.FieldName := AValue;
end;

procedure TDACDBToggleSwitch.SetDataSource(const AValue: TDataSource);
begin
  FDataLink.DataSource := AValue;
  if AValue <> nil then
    AValue.FreeNotification(Self);
end;

procedure TDACDBToggleSwitch.UpdateData(Sender: TObject);
begin
  if FDataLink.Field <> nil then
    FDataLink.Field.AsBoolean := Checked;
end;

{ TDACDBSlider }

constructor TDACDBSlider.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FDataLink := TFieldDataLink.Create;
  FDataLink.Control := Self;
  FDataLink.OnDataChange := DataChange;
  FDataLink.OnUpdateData := UpdateData;
  inherited OnChange := ControlChange;
end;

destructor TDACDBSlider.Destroy;
begin
  FDataLink.Free;
  inherited;
end;

procedure TDACDBSlider.CMExit(var AMessage: TCMExit);
begin
  try
    FDataLink.UpdateRecord;
  finally
    inherited;
  end;
end;

procedure TDACDBSlider.ControlChange(Sender: TObject);
begin
  FDataLink.Modified;
  if Assigned(FOnChange) then
    FOnChange(Self);
end;

procedure TDACDBSlider.DataChange(Sender: TObject);
begin
  if FDataLink.Field <> nil then
    Value := FDataLink.Field.AsInteger;
end;

function TDACDBSlider.GetDataField: string;
begin
  Result := FDataLink.FieldName;
end;

function TDACDBSlider.GetDataSource: TDataSource;
begin
  Result := FDataLink.DataSource;
end;

procedure TDACDBSlider.Notification(AComponent: TComponent;
  Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (FDataLink <> nil) and
    (AComponent = FDataLink.DataSource) then
    FDataLink.DataSource := nil;
end;

procedure TDACDBSlider.SetDataField(const AValue: string);
begin
  FDataLink.FieldName := AValue;
end;

procedure TDACDBSlider.SetDataSource(const AValue: TDataSource);
begin
  FDataLink.DataSource := AValue;
  if AValue <> nil then
    AValue.FreeNotification(Self);
end;

procedure TDACDBSlider.UpdateData(Sender: TObject);
begin
  if FDataLink.Field <> nil then
    FDataLink.Field.AsInteger := Value;
end;

end.

