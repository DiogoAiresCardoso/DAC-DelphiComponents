from pathlib import Path
r=Path(r'M:/MaxxSoft/MaxxRural/Desktop/maxxrural')
def edit(rel,fn):
 p=r/rel;s=p.read_bytes().decode('cp1252').replace('\r\n','\n');s=fn(s);p.write_bytes(s.replace('\n','\r\n').encode('cp1252'))
def view(s):
 s=s.replace('  DAC.Components.Controls.DBGrid.ActionTypes,','  DAC.Components.Controls.DBGrid.ActionTypes,\n  DAC.Components.Controls.DBGrid.Types,')
 s=s.replace('    procedure btnAplicarClick','    procedure GridOrdenar(Sender: TObject; AColumn: TColumn;\n      const AFieldName: string; ADirection: TDACDBGridSortDirection;\n      var AAccepted: Boolean);\n    procedure btnAplicarClick',1)
 s=s.replace('implementation\n\nuses','implementation\n\nuses\n  DAC.Components.Controls.DBGrid.ClientDataSetSort,')
 s=s.replace('  // Buffers locais e vazios; a carga e a classifica\u00e7\u00e3o dos lan\u00e7amentos ser\u00e3o feitas em outra etapa.','  // Buffers locais vazios; a ordenacao visual usa indices tipados, sem nova consulta.')
 at=s.index('procedure TfrmMovimentoBancarioView.GridAcaoEstado')
 s=s[:at]+'''procedure TfrmMovimentoBancarioView.GridOrdenar(Sender: TObject;
  AColumn: TColumn; const AFieldName: string;
  ADirection: TDACDBGridSortDirection; var AAccepted: Boolean);
var Grid: TDACDBGrid;
begin
  AAccepted := False;
  if not (Sender is TDACDBGrid) then Exit;
  Grid := TDACDBGrid(Sender);
  if (Grid.DataSource = nil) or not (Grid.DataSource.DataSet is TClientDataSet) then Exit;
  AAccepted := TDACDBGridClientDataSetSort.Apply(
    TClientDataSet(Grid.DataSource.DataSet), AFieldName, ADirection, Grid.ActionKeyFields);
end;

'''+s[at:]
 return s
def dfm(s):
 assert s.count('          OnActionState = GridAcaoEstado')==3
 s=s.replace('          OnActionState = GridAcaoEstado','          OnSortRequest = GridOrdenar\n          OnActionState = GridAcaoEstado')
 s=s.replace("              LayoutKey = 'MOV_HISTCOMPL'","              LayoutKey = 'MOV_HISTCOMPL'\n              Sortable = False")
 s=s.replace("              LayoutKey = 'OPCOES'","              LayoutKey = 'OPCOES'\n              MinWidth = 172")
 return s
edit('source/view/View.MovimentoBancario.pas',view)
edit('source/view/View.MovimentoBancario.dfm',dfm)
def helper(s):
 s=s.replace('  public\n','  private\n    FTestPPI: Integer;\n  protected\n    function EffectivePPI: Integer; override;\n    procedure Paint; override;\n  public\n    SortRequests, PaintCount: Integer;\n    RejectSort: Boolean;\n    procedure SetTestPPI(const Value: Integer);\n    procedure DragAt(const P: TPoint);\n    function BoundsOf(const Column: Integer; const VisibleRow: Integer = -1): TRect;\n    function HintAt(const P: TPoint): string;\n',1)
 s=s.replace('    procedure SortRequested','    procedure GridOrdenar(Sender: TObject; AColumn: Vcl.DBGrids.TColumn;\n      const AFieldName: string; ADirection: TDACDBGridSortDirection;\n      var AAccepted: Boolean);\n    procedure SortRequested',1)
 s=s.replace('  Datasnap.DBClient, Data.DB;','  Datasnap.DBClient, Data.DB, DAC.Components.Controls.DBGrid.ClientDataSetSort;')
 start=s.index('procedure TDACActionTestGrid.SortRequested');s=s[:start]+'''function TDACActionTestGrid.EffectivePPI: Integer;
begin
  if FTestPPI > 0 then Result := FTestPPI else Result := inherited;
end;
procedure TDACActionTestGrid.SetTestPPI(const Value: Integer);
var Old: Integer;
begin
  Old := EffectivePPI; FTestPPI := Value; ChangeScale(Value, Old, True);
end;
procedure TDACActionTestGrid.Paint;
begin Inc(PaintCount); inherited; end;
procedure TDACActionTestGrid.DragAt(const P: TPoint);
begin Perform(WM_MOUSEMOVE, MK_LBUTTON, MakeLParam(P.X, P.Y)); end;
function TDACActionTestGrid.BoundsOf(const Column, VisibleRow: Integer): TRect;
begin Result := DisplayCellRect(DataToRawColumn(Column), VisibleRow + 1); end;
function TDACActionTestGrid.HintAt(const P: TPoint): string;
var Info: THintInfo;
begin
  Info := Default(THintInfo); Info.CursorPos := P;
  Perform(CM_HINTSHOW, 0, LPARAM(@Info)); Result := Info.HintStr;
end;
procedure TDACActionTestGrid.GridOrdenar(Sender: TObject;
  AColumn: Vcl.DBGrids.TColumn; const AFieldName: string;
  ADirection: TDACDBGridSortDirection; var AAccepted: Boolean);
begin SortRequested(Sender, AColumn, AFieldName, ADirection, AAccepted); end;
procedure TDACActionTestGrid.SortRequested(Sender: TObject;
  AColumn: Vcl.DBGrids.TColumn; const AFieldName: string;
  ADirection: TDACDBGridSortDirection; var AAccepted: Boolean);
begin
  Inc(SortRequests);
  AAccepted := not RejectSort and TDACDBGridClientDataSetSort.Apply(
    TClientDataSet(DataSource.DataSet), AFieldName, ADirection, ActionKeyFields);
end;

end.
'''
 s=s.replace('Result := CellRect(DataToRawColumn(AColumn), 0).CenterPoint','Result := DisplayCellRect(DataToRawColumn(AColumn), 0).CenterPoint')
 return s
edit('MaxxRural/src/Tests/TestSupport.DACDBGridActions.pas',helper)
e=r/'MaxxRural/src/Tests/Resultados/20261020-grid-colunas';e.mkdir(parents=True,exist_ok=True)
old=e.parent/'20261020-grid-acoes'
for f in ['compilar.cmd','compilar-desktop.cmd','executar-testes.ps1']:
 (e/f).write_bytes((old/f).read_bytes())
print('View, tres DFMs e helper oficial atualizados.')
