unit DAC.Components.Controls.DBGrid.Types;

interface

uses
  System.Classes,
  System.Types,
  System.UITypes,
  Data.DB,
  Vcl.DBGrids,
  Vcl.Graphics;

const
  DACDBGridLayoutVersion = 1;
  DACDBGridDefaultWidth = 760;
  DACDBGridDefaultHeight = 240;
  DACDBGridDefaultSelectionWidth = 36;
  DACDBGridDefaultLayoutDebounce = 750;
  DACDBGridDefaultFontSize = 8;

type
  TDACDBGridPinPosition = (dgpNone, dgpLeft, dgpRight);

  TDACDBGridDensity = (
    dgdCompact,
    dgdStandard,
    dgdComfortable
  );

  TDACDBGridSortDirection = (
    dgsNone,
    dgsAscending,
    dgsDescending
  );

  TDACDBGridBadgeMode = (
    dbmNone,
    dbmBooleanPreset,
    dbmRules
  );

  TDACDBGridSelectionState = (
    dgssUnchecked,
    dgssMixed,
    dgssChecked
  );

  TDACDBGridTextItem = record
    Text: string;
    Bounds: TRect;
    Color: TAlphaColor;
    FontSize: Integer;
    Bold: Boolean;
    Alignment: TAlignment;
    Ellipsis: Boolean;
  end;

  TDACDBGridColumnLayout = record
    Key: string;
    DisplayIndex: Integer;
    LogicalWidth: Integer;
    Visible: Boolean;
  end;

  TDACDBGridLayoutSnapshot = record
    Version: Integer;
    SortKey: string;
    SortFieldName: string;
    SortDirection: TDACDBGridSortDirection;
    Columns: TArray<TDACDBGridColumnLayout>;
  end;

  TDACDBGridLayoutEntry = record
    Identity: string;
    Snapshot: TDACDBGridLayoutSnapshot;
  end;

  TDACDBGridLayoutCatalog = record
    Version: Integer;
    Entries: TArray<TDACDBGridLayoutEntry>;
  end;

  TDACDBGridDataLinkNotifyEvent = procedure(Sender: TObject;
    AField: TField) of object;
  TDACDBGridSortRequestEvent = procedure(Sender: TObject; AColumn: TColumn;
    const AFieldName: string; ADirection: TDACDBGridSortDirection;
    var AAccepted: Boolean) of object;
  TDACDBGridSelectionChangedEvent = procedure(Sender: TObject; AField: TField;
    const AChecked: Boolean) of object;
  TDACDBGridRestoreSortEvent = procedure(const AKey, AFieldName: string;
    const ADirection: TDACDBGridSortDirection) of object;
  TDACDBGridErrorEvent = procedure(Sender: TObject;
    const AMessage: string) of object;

implementation

end.
