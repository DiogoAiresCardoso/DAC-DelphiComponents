unit DAC.Components.Controls.DBTreeView.Painter;
interface
uses Winapi.Windows, Vcl.Graphics,
  DAC.Components.DesignSystem.ControlTokens,
  DAC.Components.Controls.TreeView.Painter,
  DAC.Components.Controls.DBTreeView.Model,
  DAC.Components.Controls.DBTreeView.Columns;
type
  TDACDBTreeHitKind = TDACTreeHitKind;
  TDACDBTreeHit = TDACTreeHit;
  TDACDBTreeLayout = TDACTreeLayout;
  TDACDBTreeText = TDACTreeText;
  TDACDBTreePainter = class(TDACTreePainter)
  public
    function Layout(AWidth, AHeight, ADpi: Integer; AModel: TDACDBTreeModel;
      AColumns: TDACDBTreeColumns; ATopRow: Integer = 0;
      AHorizontalOffset: Integer = 0): TDACDBTreeLayout; reintroduce;
    function HitTest(AX, AY, AWidth, AHeight, ADpi: Integer;
      AModel: TDACDBTreeModel; AColumns: TDACDBTreeColumns;
      ATopRow, AHorizontalOffset: Integer): TDACDBTreeHit; reintroduce;
    procedure Paint(ADC: HDC; AWidth, AHeight, ADpi: Integer;
      const ATokens: TDACControlTokens; AModel: TDACDBTreeModel;
      AColumns: TDACDBTreeColumns; const ASelectedToken: string;
      ATopRow, AHorizontalOffset, AHoverRow: Integer;
      AFocused, AEnabled, AReadOnly: Boolean; const AStatusText: string;
      AFont: TFont = nil); reintroduce;
  end;
const
  thNone = DAC.Components.Controls.TreeView.Painter.thNone;
  thHeader = DAC.Components.Controls.TreeView.Painter.thHeader;
  thRow = DAC.Components.Controls.TreeView.Painter.thRow;
  thExpander = DAC.Components.Controls.TreeView.Painter.thExpander;
  thCheck = DAC.Components.Controls.TreeView.Painter.thCheck;
  thVerticalTrack = DAC.Components.Controls.TreeView.Painter.thVerticalTrack;
  thVerticalThumb = DAC.Components.Controls.TreeView.Painter.thVerticalThumb;
  thHorizontalTrack = DAC.Components.Controls.TreeView.Painter.thHorizontalTrack;
  thHorizontalThumb = DAC.Components.Controls.TreeView.Painter.thHorizontalThumb;
implementation
function TDACDBTreePainter.Layout(AWidth, AHeight, ADpi: Integer;
  AModel: TDACDBTreeModel; AColumns: TDACDBTreeColumns;
  ATopRow, AHorizontalOffset: Integer): TDACDBTreeLayout;
begin
  Result := inherited Layout(AWidth, AHeight, ADpi, AModel, AColumns,
    ATopRow, AHorizontalOffset);
end;
function TDACDBTreePainter.HitTest(AX, AY, AWidth, AHeight, ADpi: Integer;
  AModel: TDACDBTreeModel; AColumns: TDACDBTreeColumns;
  ATopRow, AHorizontalOffset: Integer): TDACDBTreeHit;
begin
  Result := inherited HitTest(AX, AY, AWidth, AHeight, ADpi, AModel,
    AColumns, ATopRow, AHorizontalOffset);
end;
procedure TDACDBTreePainter.Paint(ADC: HDC; AWidth, AHeight, ADpi: Integer;
  const ATokens: TDACControlTokens; AModel: TDACDBTreeModel;
  AColumns: TDACDBTreeColumns; const ASelectedToken: string;
  ATopRow, AHorizontalOffset, AHoverRow: Integer;
  AFocused, AEnabled, AReadOnly: Boolean; const AStatusText: string; AFont: TFont);
begin
  inherited Paint(ADC, AWidth, AHeight, ADpi, ATokens, AModel, AColumns,
    ASelectedToken, ATopRow, AHorizontalOffset, AHoverRow, AFocused,
    AEnabled, AReadOnly, AStatusText, AFont);
end;
end.
