unit TestSupport.DACDBGridActions;

interface

uses
  System.Classes, System.Types,
  DAC.Components.Controls.DBGrid,
  DAC.Components.Controls.DBGrid.Column,
  DAC.Components.Controls.DBGrid.Action,
  DAC.Components.Controls.DBGrid.ActionTypes,
  DAC.Components.Controls.DBGrid.Types;

type
  TDACActionTestGrid = class(TDACDBGrid)
  public
    Activations, CellClicks, DoubleClicks, StateQueries: Integer;
    HiddenAction, DisabledAction: string;
    LastContext: TDACDBGridActionContext;
    procedure DownAt(const P: TPoint);
    procedure UpAt(const P: TPoint);
    procedure ClickAt(const P: TPoint);
    procedure DoubleAt(const P: TPoint);
    procedure MoveAt(const P: TPoint);
    procedure PressKey(const AKey: Word; const AShift: TShiftState = []);
    procedure ReleaseKey(const AKey: Word);
    function HeaderPoint(const AColumn: Integer): TPoint;
    function CurrentVisibleRow: Integer;
    procedure Recreate;
  published
    procedure GridAcaoEstado(Sender: TObject; AColumn: TDACDBGridColumn;
      AAction: TDACDBGridAction; const AContext: TDACDBGridActionContext;
      var AVisible, AEnabled: Boolean);
    procedure GridAcaoExecutar(Sender: TObject; AColumn: TDACDBGridColumn;
      AAction: TDACDBGridAction; const AContext: TDACDBGridActionContext);
    procedure CellClicked(Column: Vcl.DBGrids.TColumn);
    procedure DoubleClicked(Sender: TObject);
    procedure SortRequested(Sender: TObject; AColumn: Vcl.DBGrids.TColumn;
      const AFieldName: string; ADirection: TDACDBGridSortDirection;
      var AAccepted: Boolean);
  end;

implementation

uses System.SysUtils, System.Variants, Winapi.Windows, Winapi.Messages,
  Datasnap.DBClient;

procedure TDACActionTestGrid.DownAt(const P: TPoint);
begin Perform(WM_LBUTTONDOWN, MK_LBUTTON, MakeLParam(P.X, P.Y)); end;
procedure TDACActionTestGrid.UpAt(const P: TPoint);
begin Perform(WM_LBUTTONUP, 0, MakeLParam(P.X, P.Y)); end;
procedure TDACActionTestGrid.ClickAt(const P: TPoint);
begin DownAt(P); UpAt(P); end;
procedure TDACActionTestGrid.DoubleAt(const P: TPoint);
begin Perform(WM_LBUTTONDBLCLK, MK_LBUTTON, MakeLParam(P.X, P.Y)); UpAt(P); end;
procedure TDACActionTestGrid.MoveAt(const P: TPoint);
begin Perform(WM_MOUSEMOVE, 0, MakeLParam(P.X, P.Y)); end;
procedure TDACActionTestGrid.PressKey(const AKey: Word; const AShift: TShiftState);
var K: Word;
begin K := AKey; KeyDown(K, AShift); end;
procedure TDACActionTestGrid.ReleaseKey(const AKey: Word);
var K: Word;
begin K := AKey; KeyUp(K, []); end;
function TDACActionTestGrid.HeaderPoint(const AColumn: Integer): TPoint;
begin Result := CellRect(DataToRawColumn(AColumn), 0).CenterPoint; end;
function TDACActionTestGrid.CurrentVisibleRow: Integer;
begin Result := Row - FixedRows; end;
procedure TDACActionTestGrid.Recreate;
begin RecreateWnd; end;

procedure TDACActionTestGrid.GridAcaoEstado(Sender: TObject;
  AColumn: TDACDBGridColumn; AAction: TDACDBGridAction;
  const AContext: TDACDBGridActionContext; var AVisible, AEnabled: Boolean);
begin
  Inc(StateQueries);
  if SameText(AContext.ActionId, HiddenAction) then AVisible := False;
  if SameText(AContext.ActionId, DisabledAction) then AEnabled := False;
  // A row-specific rule, exercised with two records sharing MOV_COD.
  if (VarToStr(AContext.ValueOf('COD_EMP')) = '0000000008') and
    SameText(AContext.ActionId, 'editar') then AEnabled := False;
end;

procedure TDACActionTestGrid.GridAcaoExecutar(Sender: TObject;
  AColumn: TDACDBGridColumn; AAction: TDACDBGridAction;
  const AContext: TDACDBGridActionContext);
begin
  Inc(Activations);
  LastContext := AContext;
end;

procedure TDACActionTestGrid.CellClicked(Column: Vcl.DBGrids.TColumn);
begin Inc(CellClicks); end;
procedure TDACActionTestGrid.DoubleClicked(Sender: TObject);
begin Inc(DoubleClicks); end;

procedure TDACActionTestGrid.SortRequested(Sender: TObject;
  AColumn: Vcl.DBGrids.TColumn; const AFieldName: string;
  ADirection: TDACDBGridSortDirection; var AAccepted: Boolean);
begin
  if ADirection = dgsDescending then
    TClientDataSet(DataSource.DataSet).IndexFieldNames := AFieldName + ':D'
  else TClientDataSet(DataSource.DataSet).IndexFieldNames := AFieldName;
  AAccepted := True;
end;

end.
