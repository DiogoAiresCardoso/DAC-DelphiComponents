program DACDBGridFieldTextTests;

{$APPTYPE CONSOLE}

uses
  System.SysUtils,
  Data.DB,
  Datasnap.DBClient,
  MidasLib,
  DAC.Components.Controls.DBGrid.FieldText in
    '..\Source\Controls\DAC.Components.Controls.DBGrid.FieldText.pas';

type
  TFieldTextProbe = class
  public
    procedure TrailingMinusGetText(Sender: TField; var Text: string;
      DisplayText: Boolean);
  end;

procedure TFieldTextProbe.TrailingMinusGetText(Sender: TField;
  var Text: string; DisplayText: Boolean);
begin
  Text := '30.000,00-';
end;

procedure Require(const ACondition: Boolean; const AMessage: string);
begin
  if not ACondition then
    raise Exception.Create(AMessage);
end;

procedure TestNegativeSignPresentation;
var
  LDataSet: TClientDataSet;
  LNumericField: TField;
  LProbe: TFieldTextProbe;
begin
  LDataSet := TClientDataSet.Create(nil);
  LProbe := TFieldTextProbe.Create;
  try
    LDataSet.FieldDefs.Add('VALUE', ftCurrency);
    LDataSet.FieldDefs.Add('CODE', ftString, 20);
    LDataSet.CreateDataSet;
    LDataSet.Append;
    LDataSet.FieldByName('VALUE').AsCurrency := -30000;
    LDataSet.FieldByName('CODE').AsString := 'CODIGO-';
    LDataSet.Post;

    LNumericField := LDataSet.FieldByName('VALUE');
    LNumericField.OnGetText := LProbe.TrailingMinusGetText;
    Require(TDACDBGridFieldTextResolver.Resolve(LNumericField) =
      '-30.000,00',
      'Numeric display must move a trailing negative sign to the front.');
    Require(TDACDBGridFieldTextResolver.Resolve(
      LDataSet.FieldByName('CODE')) = 'CODIGO-',
      'Text ending in a hyphen must remain unchanged.');
  finally
    LProbe.Free;
    LDataSet.Free;
  end;
end;

begin
  try
    TestNegativeSignPresentation;
    Writeln('DACDBGridFieldTextTests: PASS');
  except
    on E: Exception do
    begin
      Writeln('DACDBGridFieldTextTests: FAIL - ' + E.ClassName + ': ' +
        E.Message);
      Halt(1);
    end;
  end;
end.
