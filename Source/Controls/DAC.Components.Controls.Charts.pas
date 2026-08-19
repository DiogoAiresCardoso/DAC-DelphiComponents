unit DAC.Components.Controls.Charts;

interface

uses
  System.Classes,
  System.Generics.Collections,
  System.Skia,
  System.SysUtils,
  System.Types,
  System.UITypes,
  Data.DB,
  Winapi.Messages,
  Winapi.Windows,
  Vcl.Controls,
  Vcl.Graphics,
  DAC.Components.DesignSystem.ChartPalette,
  DAC.Components.DesignSystem.Theme,
  DAC.Components.Skia.Renderer;

type
  TDACChartType = (
    ctBar,
    ctLine,
    ctArea,
    ctPie,
    ctDoughnut
  );

  TDACChartFillMode = (
    cfSolid,
    cfLinearGradient,
    cfRadialGradient
  );

  TDACChartTooltipMode = (
    ctmNearest,
    ctmAxis,
    ctmSeries
  );

  TDACChartPosition = (
    cpTop,
    cpRight,
    cpBottom,
    cpLeft
  );

  TDACChartOrientation = (
    coHorizontal,
    coVertical
  );

  TDACChartAxisType = (
    catCategory,
    catValue,
    catTime
  );

  TDACChartSeriesLayoutBy = (
    cslRows,
    cslColumns
  );

  TDACChartAppearance = (
    mchaDefault,
    mchaDashboard,
    mchaCustom
  );

  TDACChartDataMode = (
    cdmAuto,
    cdmDataSource,
    cdmManual
  );

  TDACChartAnimationEasing = (
    caeLinear,
    caeCubicIn,
    caeCubicOut,
    caeCubicInOut
  );

  TDACChartPointEvent = procedure(Sender: TObject; const SeriesIndex,
    PointIndex: Integer; const Category: string; const Value: Double) of object;
  TDACChartTooltipFormatEvent = procedure(Sender: TObject; const SeriesIndex,
    PointIndex: Integer; const Category: string; const Value: Double;
    var TooltipText: string) of object;
  TDACChartDataErrorEvent = procedure(Sender: TObject; const Error: Exception) of object;
  TDACChartAnimationEvent = procedure(Sender: TObject) of object;

  EDACChartDataError = class(Exception);

  { Adapter extensivel para leitura. O cursor retornado pertence ao chart e
    deve ser independente do cursor exibido pelo DataSource. }
  TDACChartDataSetAdapter = class
  public
    function Supports(const ADataSet: TDataSet): Boolean; virtual; abstract;
    function CreateReadCursor(const ADataSet: TDataSet): TDataSet; virtual; abstract;
  end;

  TDACChart = class;
  TDACChartMargins = class;
  TDACChartSeries = class;
  TDACChartAnimation = class;

  TDACChartPersistent = class(TPersistent)
  private
    FOwner: TDACChart;
  protected
    procedure Changed;
  public
    constructor Create(AOwner: TDACChart); virtual;
  end;

  TDACChartAnimation = class(TDACChartPersistent)
  private
    FAutoStartOnUpdate: Boolean;
    FDelay: Cardinal;
    FDuration: Cardinal;
    FEasing: TDACChartAnimationEasing;
    FEnabled: Boolean;
    FHoverDuration: Cardinal;
    FRunning: Boolean;
    procedure SetAutoStartOnUpdate(const AValue: Boolean);
    procedure SetDelay(const AValue: Cardinal);
    procedure SetDuration(const AValue: Cardinal);
    procedure SetEasing(const AValue: TDACChartAnimationEasing);
    procedure SetEnabled(const AValue: Boolean);
    procedure SetHoverDuration(const AValue: Cardinal);
  public
    constructor Create(AOwner: TDACChart); override;
    procedure Assign(Source: TPersistent); override;
    procedure Replay;
    procedure SetRunning(const AValue: Boolean);
    procedure Stop;
  published
    property AutoStartOnUpdate: Boolean read FAutoStartOnUpdate
      write SetAutoStartOnUpdate default True;
    property Delay: Cardinal read FDelay write SetDelay default 0;
    property Duration: Cardinal read FDuration write SetDuration default 360;
    property Easing: TDACChartAnimationEasing read FEasing write SetEasing
      default caeCubicOut;
    property Enabled: Boolean read FEnabled write SetEnabled default True;
    property HoverDuration: Cardinal read FHoverDuration write SetHoverDuration
      default 120;
    property Running: Boolean read FRunning stored False;
  end;

  TDACChartDatasetOptions = class(TDACChartPersistent)
  private
    FDimensions: string;
    FSeriesLayoutBy: TDACChartSeriesLayoutBy;
    procedure SetDimensions(const AValue: string);
    procedure SetSeriesLayoutBy(const AValue: TDACChartSeriesLayoutBy);
  public
    procedure Assign(Source: TPersistent); override;
  published
    property Dimensions: string read FDimensions write SetDimensions;
    property SeriesLayoutBy: TDACChartSeriesLayoutBy read FSeriesLayoutBy
      write SetSeriesLayoutBy default cslRows;
  end;

  TDACChartTitle = class(TDACChartPersistent)
  private
    FAlignment: TAlignment;
    FFont: TFont;
    FPosition: TDACChartPosition;
    FSubFont: TFont;
    FSubTextColor: TAlphaColor;
    FSubTextVisible: Boolean;
    FSubText: string;
    FText: string;
    FTextColor: TAlphaColor;
    FTextVisible: Boolean;
    FVisible: Boolean;
    procedure FontChanged(Sender: TObject);
    procedure SetAlignment(const AValue: TAlignment);
    procedure SetFont(const AValue: TFont);
    procedure SetPosition(const AValue: TDACChartPosition);
    procedure SetSubFont(const AValue: TFont);
    procedure SetSubTextColor(const AValue: TAlphaColor);
    procedure SetSubTextVisible(const AValue: Boolean);
    procedure SetSubText(const AValue: string);
    procedure SetText(const AValue: string);
    procedure SetTextColor(const AValue: TAlphaColor);
    procedure SetTextVisible(const AValue: Boolean);
    procedure SetVisible(const AValue: Boolean);
  public
    constructor Create(AOwner: TDACChart); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property Alignment: TAlignment read FAlignment write SetAlignment default taLeftJustify;
    property Font: TFont read FFont write SetFont;
    property Position: TDACChartPosition read FPosition write SetPosition default cpTop;
    property SubFont: TFont read FSubFont write SetSubFont;
    property SubTextColor: TAlphaColor read FSubTextColor write SetSubTextColor default 0;
    property SubTextVisible: Boolean read FSubTextVisible write SetSubTextVisible default True;
    property SubText: string read FSubText write SetSubText;
    property Text: string read FText write SetText;
    property TextColor: TAlphaColor read FTextColor write SetTextColor default 0;
    property TextVisible: Boolean read FTextVisible write SetTextVisible default True;
    property Visible: Boolean read FVisible write SetVisible default False;
  end;

  TDACChartLegend = class(TDACChartPersistent)
  private
    FAllowToggleSeries: Boolean;
    FBackgroundColor: TAlphaColor;
    FBackgroundVisible: Boolean;
    FBorderColor: TAlphaColor;
    FBorderVisible: Boolean;
    FFont: TFont;
    FItemSpacing: Integer;
    FLabelsVisible: Boolean;
    FMarkerSize: Integer;
    FMarkersVisible: Boolean;
    FOrientation: TDACChartOrientation;
    FPadding: Integer;
    FPosition: TDACChartPosition;
    FTextColor: TAlphaColor;
    FVisible: Boolean;
    procedure FontChanged(Sender: TObject);
    procedure SetAllowToggleSeries(const AValue: Boolean);
    procedure SetBackgroundColor(const AValue: TAlphaColor);
    procedure SetBackgroundVisible(const AValue: Boolean);
    procedure SetBorderColor(const AValue: TAlphaColor);
    procedure SetBorderVisible(const AValue: Boolean);
    procedure SetFont(const AValue: TFont);
    procedure SetItemSpacing(const AValue: Integer);
    procedure SetLabelsVisible(const AValue: Boolean);
    procedure SetMarkerSize(const AValue: Integer);
    procedure SetMarkersVisible(const AValue: Boolean);
    procedure SetOrientation(const AValue: TDACChartOrientation);
    procedure SetPadding(const AValue: Integer);
    procedure SetPosition(const AValue: TDACChartPosition);
    procedure SetTextColor(const AValue: TAlphaColor);
    procedure SetVisible(const AValue: Boolean);
  public
    constructor Create(AOwner: TDACChart); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property AllowToggleSeries: Boolean read FAllowToggleSeries
      write SetAllowToggleSeries default True;
    property BackgroundColor: TAlphaColor read FBackgroundColor write SetBackgroundColor default 0;
    property BackgroundVisible: Boolean read FBackgroundVisible write SetBackgroundVisible default False;
    property BorderColor: TAlphaColor read FBorderColor write SetBorderColor default 0;
    property BorderVisible: Boolean read FBorderVisible write SetBorderVisible default False;
    property Font: TFont read FFont write SetFont;
    property ItemSpacing: Integer read FItemSpacing write SetItemSpacing default 12;
    property LabelsVisible: Boolean read FLabelsVisible write SetLabelsVisible default True;
    property MarkersVisible: Boolean read FMarkersVisible write SetMarkersVisible default True;
    property MarkerSize: Integer read FMarkerSize write SetMarkerSize default 10;
    property Orientation: TDACChartOrientation read FOrientation write SetOrientation
      default coHorizontal;
    property Padding: Integer read FPadding write SetPadding default 8;
    property Position: TDACChartPosition read FPosition write SetPosition default cpBottom;
    property TextColor: TAlphaColor read FTextColor write SetTextColor default 0;
    property Visible: Boolean read FVisible write SetVisible default True;
  end;

  TDACChartAxis = class(TDACChartPersistent)
  private
    FAutoScale: Boolean;
    FAxisType: TDACChartAxisType;
    FGridColor: TAlphaColor;
    FGridLines: Boolean;
    FLabelColor: TAlphaColor;
    FLabelFont: TFont;
    FLabelsVisible: Boolean;
    FLabelFormat: string;
    FLineColor: TAlphaColor;
    FLineVisible: Boolean;
    FMax: Double;
    FMin: Double;
    FTicks: Integer;
    FTickMarksVisible: Boolean;
    FTitleColor: TAlphaColor;
    FTitleFont: TFont;
    FTitle: string;
    FTitleVisible: Boolean;
    FVisible: Boolean;
    procedure FontChanged(Sender: TObject);
    procedure SetAutoScale(const AValue: Boolean);
    procedure SetAxisType(const AValue: TDACChartAxisType);
    procedure SetGridColor(const AValue: TAlphaColor);
    procedure SetGridLines(const AValue: Boolean);
    procedure SetLabelColor(const AValue: TAlphaColor);
    procedure SetLabelFont(const AValue: TFont);
    procedure SetLabelsVisible(const AValue: Boolean);
    procedure SetLabelFormat(const AValue: string);
    procedure SetLineColor(const AValue: TAlphaColor);
    procedure SetLineVisible(const AValue: Boolean);
    procedure SetMax(const AValue: Double);
    procedure SetMin(const AValue: Double);
    procedure SetTicks(const AValue: Integer);
    procedure SetTickMarksVisible(const AValue: Boolean);
    procedure SetTitleColor(const AValue: TAlphaColor);
    procedure SetTitleFont(const AValue: TFont);
    procedure SetTitle(const AValue: string);
    procedure SetTitleVisible(const AValue: Boolean);
    procedure SetVisible(const AValue: Boolean);
  public
    constructor Create(AOwner: TDACChart); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property AutoScale: Boolean read FAutoScale write SetAutoScale default True;
    property AxisType: TDACChartAxisType read FAxisType write SetAxisType default catValue;
    property GridColor: TAlphaColor read FGridColor write SetGridColor default 0;
    property GridLines: Boolean read FGridLines write SetGridLines default True;
    property LabelColor: TAlphaColor read FLabelColor write SetLabelColor default 0;
    property LabelFont: TFont read FLabelFont write SetLabelFont;
    property LabelsVisible: Boolean read FLabelsVisible write SetLabelsVisible default True;
    property LabelFormat: string read FLabelFormat write SetLabelFormat;
    property LineColor: TAlphaColor read FLineColor write SetLineColor default 0;
    property LineVisible: Boolean read FLineVisible write SetLineVisible default True;
    property Max: Double read FMax write SetMax;
    property Min: Double read FMin write SetMin;
    property Ticks: Integer read FTicks write SetTicks default 4;
    property TickMarksVisible: Boolean read FTickMarksVisible write SetTickMarksVisible default True;
    property TitleColor: TAlphaColor read FTitleColor write SetTitleColor default 0;
    property TitleFont: TFont read FTitleFont write SetTitleFont;
    property Title: string read FTitle write SetTitle;
    property TitleVisible: Boolean read FTitleVisible write SetTitleVisible default True;
    property Visible: Boolean read FVisible write SetVisible default True;
  end;

  TDACChartGridOptions = class(TDACChartPersistent)
  private
    FLineStyle: TPenStyle;
    FMargins: TDACChartMargins;
    FPadding: Integer;
    FVisible: Boolean;
    procedure SetLineStyle(const AValue: TPenStyle);
    procedure SetPadding(const AValue: Integer);
    procedure SetVisible(const AValue: Boolean);
  public
    constructor Create(AOwner: TDACChart); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property LineStyle: TPenStyle read FLineStyle write SetLineStyle default psSolid;
    property Margins: TDACChartMargins read FMargins write FMargins;
    property Padding: Integer read FPadding write SetPadding default 16;
    property Visible: Boolean read FVisible write SetVisible default True;
  end;

  TDACChartTooltip = class(TDACChartPersistent)
  private
    FBackgroundColor: TAlphaColor;
    FBorderColor: TAlphaColor;
    FEnabled: Boolean;
    FFont: TFont;
    FFollowMouse: Boolean;
    FFormatter: string;
    FMode: TDACChartTooltipMode;
    FPadding: Integer;
    FShowMarker: Boolean;
    FTextColor: TAlphaColor;
    FTitleColor: TAlphaColor;
    FTitleFont: TFont;
    procedure FontChanged(Sender: TObject);
    procedure SetBackgroundColor(const AValue: TAlphaColor);
    procedure SetBorderColor(const AValue: TAlphaColor);
    procedure SetEnabled(const AValue: Boolean);
    procedure SetFont(const AValue: TFont);
    procedure SetFollowMouse(const AValue: Boolean);
    procedure SetFormatter(const AValue: string);
    procedure SetMode(const AValue: TDACChartTooltipMode);
    procedure SetPadding(const AValue: Integer);
    procedure SetShowMarker(const AValue: Boolean);
    procedure SetTextColor(const AValue: TAlphaColor);
    procedure SetTitleColor(const AValue: TAlphaColor);
    procedure SetTitleFont(const AValue: TFont);
  public
    constructor Create(AOwner: TDACChart); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property BackgroundColor: TAlphaColor read FBackgroundColor
      write SetBackgroundColor default 0;
    property BorderColor: TAlphaColor read FBorderColor write SetBorderColor default 0;
    property Enabled: Boolean read FEnabled write SetEnabled default True;
    property Font: TFont read FFont write SetFont;
    property FollowMouse: Boolean read FFollowMouse write SetFollowMouse default True;
    property Formatter: string read FFormatter write SetFormatter;
    property Mode: TDACChartTooltipMode read FMode write SetMode default ctmNearest;
    property Padding: Integer read FPadding write SetPadding default 12;
    property ShowMarker: Boolean read FShowMarker write SetShowMarker default True;
    property TextColor: TAlphaColor read FTextColor write SetTextColor default 0;
    property TitleColor: TAlphaColor read FTitleColor write SetTitleColor default 0;
    property TitleFont: TFont read FTitleFont write SetTitleFont;
  end;

  TDACChartMargins = class(TDACChartPersistent)
  private
    FBottom: Integer;
    FLeft: Integer;
    FRight: Integer;
    FTop: Integer;
    procedure SetBottom(const AValue: Integer);
    procedure SetLeft(const AValue: Integer);
    procedure SetRight(const AValue: Integer);
    procedure SetTop(const AValue: Integer);
  public
    procedure Assign(Source: TPersistent); override;
  published
    property Bottom: Integer read FBottom write SetBottom default 0;
    property Left: Integer read FLeft write SetLeft default 0;
    property Right: Integer read FRight write SetRight default 0;
    property Top: Integer read FTop write SetTop default 0;
  end;

  TDACChartPoint = class(TCollectionItem)
  private
    FCategory: string;
    FIsNull: Boolean;
    FLabelText: string;
    FTooltipText: string;
    FValue: Double;
    FXValue: Double;
    procedure Changed;
    procedure SetCategory(const AValue: string);
    procedure SetIsNull(const AValue: Boolean);
    procedure SetLabelText(const AValue: string);
    procedure SetTooltipText(const AValue: string);
    procedure SetValue(const AValue: Double);
    procedure SetXValue(const AValue: Double);
  public
    procedure Assign(Source: TPersistent); override;
  published
    property Category: string read FCategory write SetCategory;
    property IsNull: Boolean read FIsNull write SetIsNull default False;
    property LabelText: string read FLabelText write SetLabelText;
    property TooltipText: string read FTooltipText write SetTooltipText;
    property Value: Double read FValue write SetValue;
    property XValue: Double read FXValue write SetXValue;
  end;

  TDACChartPointCollection = class(TOwnedCollection)
  private
    FSeries: TDACChartSeries;
    function GetItem(AIndex: Integer): TDACChartPoint;
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TDACChartSeries);
    function Add: TDACChartPoint;
    property Items[AIndex: Integer]: TDACChartPoint read GetItem; default;
  end;

  TDACChartSeries = class(TCollectionItem)
  private
    FChartType: TDACChartType;
    FColor: TAlphaColor;
    FEncodeLabel: string;
    FEncodeSeries: string;
    FEncodeTooltip: string;
    FEncodeValue: string;
    FEncodeX: string;
    FEncodeY: string;
    FFillMode: TDACChartFillMode;
    FGradientAngle: Single;
    FGradientEndColor: TAlphaColor;
    FGradientStartColor: TAlphaColor;
    FName: string;
    FPoints: TDACChartPointCollection;
    FVisible: Boolean;
    procedure Changed;
    procedure SetChartType(const AValue: TDACChartType);
    procedure SetColor(const AValue: TAlphaColor);
    procedure SetEncodeLabel(const AValue: string);
    procedure SetEncodeSeries(const AValue: string);
    procedure SetEncodeTooltip(const AValue: string);
    procedure SetEncodeValue(const AValue: string);
    procedure SetEncodeX(const AValue: string);
    procedure SetEncodeY(const AValue: string);
    procedure SetFillMode(const AValue: TDACChartFillMode);
    procedure SetGradientAngle(const AValue: Single);
    procedure SetGradientEndColor(const AValue: TAlphaColor);
    procedure SetGradientStartColor(const AValue: TAlphaColor);
    procedure SetName(const AValue: string);
    procedure SetVisible(const AValue: Boolean);
  public
    constructor Create(Collection: TCollection); override;
    destructor Destroy; override;
    procedure Assign(Source: TPersistent); override;
  published
    property ChartType: TDACChartType read FChartType write SetChartType default ctBar;
    property Color: TAlphaColor read FColor write SetColor default 0;
    property EncodeLabel: string read FEncodeLabel write SetEncodeLabel;
    property EncodeSeries: string read FEncodeSeries write SetEncodeSeries;
    property EncodeTooltip: string read FEncodeTooltip write SetEncodeTooltip;
    property EncodeValue: string read FEncodeValue write SetEncodeValue;
    property EncodeX: string read FEncodeX write SetEncodeX;
    property EncodeY: string read FEncodeY write SetEncodeY;
    property FillMode: TDACChartFillMode read FFillMode write SetFillMode default cfSolid;
    property GradientAngle: Single read FGradientAngle write SetGradientAngle;
    property GradientEndColor: TAlphaColor read FGradientEndColor
      write SetGradientEndColor default 0;
    property GradientStartColor: TAlphaColor read FGradientStartColor
      write SetGradientStartColor default 0;
    property Name: string read FName write SetName;
    property Points: TDACChartPointCollection read FPoints write FPoints;
    property Visible: Boolean read FVisible write SetVisible default True;
  end;

  TDACChartSeriesCollection = class(TOwnedCollection)
  private
    function GetItem(AIndex: Integer): TDACChartSeries;
    procedure SetItem(AIndex: Integer; const AValue: TDACChartSeries);
  protected
    procedure Update(Item: TCollectionItem); override;
  public
    constructor Create(AOwner: TPersistent);
    function Add: TDACChartSeries;
    property Items[AIndex: Integer]: TDACChartSeries read GetItem write SetItem; default;
  end;

  TDACChartDataLink = class(TDataLink)
  private
    FChart: TDACChart;
  protected
    procedure ActiveChanged; override;
    procedure DataSetChanged; override;
    procedure RecordChanged(Field: TField); override;
  public
    constructor Create(AChart: TDACChart);
  end;

  TDACChartValue = record
    Category: string;
    LabelText: string;
    TooltipText: string;
    Value: Double;
    XValue: Double;
    IsNull: Boolean;
  end;

  TDACChartSeriesSnapshot = record
    Name: string;
    ChartType: TDACChartType;
    FillMode: TDACChartFillMode;
    Color: TAlphaColor;
    GradientStartColor: TAlphaColor;
    GradientEndColor: TAlphaColor;
    GradientAngle: Single;
    Visible: Boolean;
    Values: TArray<TDACChartValue>;
  end;

  TDACChartSnapshot = record
    Series: TArray<TDACChartSeriesSnapshot>;
    CategoryCount: Integer;
    HasData: Boolean;
  end;

  TDACChartHitShape = (chsRectangle, chsCircle, chsPie, chsLegend);

  TDACChartHitArea = record
    Center: TPointF;
    Rect: TRectF;
    InnerRadius: Single;
    OuterRadius: Single;
    StartAngle: Single;
    SweepAngle: Single;
    Shape: TDACChartHitShape;
    SeriesIndex: Integer;
    PointIndex: Integer;
    Category: string;
    Value: Double;
  end;

  TDACChartNativeTextItem = record
    Text: string;
    Family: string;
    Bounds: TRectF;
    Baseline: TPointF;
    Size: Single;
    Color: TAlphaColor;
    Bold: Boolean;
    Centered: Boolean;
    MaxWidth: Single;
  end;

  { The tooltip is presented after every static native text item.  Keep its
    chrome in the same final layer so axis and legend labels can never paint
    over its background while the mouse moves. }
  TDACChartNativeTooltipMarker = record
    Center: TPointF;
    Color: TAlphaColor;
    Radius: Single;
  end;

  TDACChart = class(TCustomControl)
  private
    FAppearance: TDACChartAppearance;
    FAnimation: TDACChartAnimation;
    FAnimationFrame: TDACChartSnapshot;
    FAnimationSurfaceReady: Boolean;
    FAnimationSource: TDACChartSnapshot;
    FAnimationStartTick: Cardinal;
    FBackgroundColor: TAlphaColor;
    FBaseAppearance: TDACChartAppearance;
    FBorderColor: TAlphaColor;
    FChartGrid: TDACChartGridOptions;
    FChartType: TDACChartType;
    FCustomBackgroundColor: Boolean;
    FCustomBorderColor: Boolean;
    FDataLink: TDACChartDataLink;
    FDataMode: TDACChartDataMode;
    FDatasetOptions: TDACChartDatasetOptions;
    FDataSource: TDataSource;
    FDataDirty: Boolean;
    FDataRevision: Integer;
    FEffectiveDpi: Integer;
    FDpiScale: Single;
    FGeometryDirty: Boolean;
    FHasRenderSnapshot: Boolean;
    FHover: TDACChartHitArea;
    FHoverActive: Boolean;
    FHoverAnimating: Boolean;
    FHoverOpacity: Single;
    FHoverRedrawPosted: Boolean;
    FHoverStartTick: Cardinal;
    FHoverTooltip: string;
    FHoverTooltipPointIndex: Integer;
    FHoverTooltipRevision: Integer;
    FHoverTooltipSeriesIndex: Integer;
    FKeyboardHitIndex: Integer;
    FLayoutDirty: Boolean;
    FLegend: TDACChartLegend;
    FOnDataError: TDACChartDataErrorEvent;
    FOnAnimationFinish: TDACChartAnimationEvent;
    FOnAnimationStart: TDACChartAnimationEvent;
    FOnPointClick: TDACChartPointEvent;
    FOnPointHover: TDACChartPointEvent;
    FOnTooltipFormat: TDACChartTooltipFormatEvent;
    FMousePoint: TPointF;
    FNativeFrameTextItems: TList<TDACChartNativeTextItem>;
    FNativeFrameOverlayTextItems: TList<TDACChartNativeTextItem>;
    FNativeFrameOverlayMarkers: TList<TDACChartNativeTooltipMarker>;
    FNativeOverlayTextItems: TList<TDACChartNativeTextItem>;
    FNativeOverlayMarkers: TList<TDACChartNativeTooltipMarker>;
    FNativeStaticTextItems: TList<TDACChartNativeTextItem>;
    FNativeTextQueue: TList<TDACChartNativeTextItem>;
    FNativeTooltipActive: Boolean;
    FNativeTooltipBackground: TAlphaColor;
    FNativeTooltipBorder: TAlphaColor;
    FNativeTooltipMarkerQueue: TList<TDACChartNativeTooltipMarker>;
    FNativeTooltipRect: TRectF;
    FNativeTextWidths: TDictionary<string, Single>;
    FPicture: ISkPicture;
    FPressedHit: TDACChartHitArea;
    FPressedActive: Boolean;
    FClickArmed: Boolean;
    FRenderer: TDACSkiaRenderer;
    FRefreshPosted: Boolean;
    FSeries: TDACChartSeriesCollection;
    FShowFrame: Boolean;
    FSnapshot: TDACChartSnapshot;
    FSurface: ISkSurface;
    FSurfaceHeight: Integer;
    FSurfacePixels: TBytes;
    FSurfaceWidth: Integer;
    FThemeMode: TDACThemeMode;
    FTitle: TDACChartTitle;
    FTooltip: TDACChartTooltip;
    FHitAreas: TList<TDACChartHitArea>;
    FXAxis: TDACChartAxis;
    FYAxis: TDACChartAxis;
    procedure ApplyAppearance;
    procedure ApplyDpi(const ADpi: Integer);
    procedure ApplyFillPaint(const APaint: ISkPaint;
      const ASeries: TDACChartSeriesSnapshot; const ASeriesIndex: Integer;
      const ABounds: TRectF);
    procedure BuildDesignSnapshot(var ASnapshot: TDACChartSnapshot);
    procedure BuildGeometry(const ASnapshot: TDACChartSnapshot);
    procedure BuildManualSnapshot(var ASnapshot: TDACChartSnapshot);
    procedure BuildSnapshotFromDataSet(var ASnapshot: TDACChartSnapshot);
    procedure ChartChanged;
    function ChartContentRect(const ADest: TRectF): TRectF;
    function ChartRect(const ADest: TRectF;
      const ASnapshot: TDACChartSnapshot): TRectF;
    procedure ClearSnapshot(var ASnapshot: TDACChartSnapshot);
    procedure CopySnapshot(const ASource: TDACChartSnapshot;
      out ATarget: TDACChartSnapshot);
    procedure BuildZeroSnapshot(const ATarget: TDACChartSnapshot;
      out AResult: TDACChartSnapshot);
    procedure DrawAxes(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ASnapshot: TDACChartSnapshot; const AMin, AMax: Double);
    procedure DrawBarSeries(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ASnapshot: TDACChartSnapshot; const ASeriesIndex: Integer;
      const AMin, AMax: Double);
    procedure DrawCartesianSeries(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ASnapshot: TDACChartSnapshot; const AMin, AMax: Double);
    procedure DrawChart(const ACanvas: ISkCanvas; const ADest: TRectF;
      const ASnapshot: TDACChartSnapshot);
    procedure DrawEmpty(const ACanvas: ISkCanvas; const ARect: TRectF;
      const AText: string);
    procedure DrawFrame(const ACanvas: ISkCanvas; const ADest: TRectF);
    procedure DrawGrid(const ACanvas: ISkCanvas; const ARect: TRectF);
    procedure DrawLegend(const ACanvas: ISkCanvas; const ADest: TRectF;
      const ASnapshot: TDACChartSnapshot);
    procedure DrawLineOrAreaSeries(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ASeries: TDACChartSeriesSnapshot; const ASeriesIndex: Integer;
      const AMin, AMax: Double; const AArea: Boolean);
    procedure DrawPieSeries(const ACanvas: ISkCanvas; const ARect: TRectF;
      const ASnapshot: TDACChartSnapshot; const ASeriesIndex: Integer;
      const ADoughnut: Boolean);
    procedure DrawTitle(const ACanvas: ISkCanvas; const ADest: TRectF);
    procedure DrawTooltip;
    procedure DrawNativeTextItems(
      const AItems: TList<TDACChartNativeTextItem>);
    procedure DrawNativeTooltipLayer(
      const AMarkers: TList<TDACChartNativeTooltipMarker>);
    procedure EnsureSurface;
    function EffectiveSeriesCount(const ASnapshot: TDACChartSnapshot): Integer;
    function FieldText(const ADataSet: TDataSet; const AFieldName: string;
      const ADefault: string): string;
    function IsBackgroundColorStored: Boolean;
    function IsBorderColorStored: Boolean;
    function EasedProgress(const AProgress: Single): Single;
    function FindSourceValue(const ASource: TDACChartSnapshot;
      const ATargetSeries: TDACChartSeriesSnapshot; const ATargetSeriesIndex,
      ATargetValueIndex: Integer; out AValue: TDACChartValue): Boolean;
    procedure InterpolateSnapshot(const ASource, ATarget: TDACChartSnapshot;
      const AProgress: Single; out AResult: TDACChartSnapshot);
    procedure LegendPanelSize(const AHostRect: TRectF;
      const ASnapshot: TDACChartSnapshot; out AWidth, AHeight: Single);
    function LegendRect(const ADest: TRectF;
      const ASnapshot: TDACChartSnapshot): TRectF;
    function NativeTextHeight(const ASize: Single): Single;
    function NativeTextWidth(const AText, AFamily: string;
      const ASize: Single; const ABold: Boolean): Single;
    function ParentSurfaceColor: TAlphaColor;
    function Pixels(const AValue: Integer): Integer;
    procedure QueueNativeText(const AText, AFamily: string;
      const AX, AY, ASize: Single; const AColor: TAlphaColor;
      const ABold: Boolean = False; const AMaxWidth: Single = 0);
    procedure QueueNativeTextCentered(const AText, AFamily: string;
      const ARect: TRectF; const ASize: Single; const AColor: TAlphaColor;
      const ABold: Boolean = False; const AMaxWidth: Single = 0);
    procedure QueueNativeTooltipMarker(const ACenter: TPointF;
      const AColor: TAlphaColor; const ARadius: Single);
    procedure RefreshDpi;
    function TextPixels(const AValue: Integer): Single;
    procedure PresentSurface;
    procedure RenderAnimationFrame;
    procedure RefreshSnapshot;
    function ResolveFillColor(const ASeries: TDACChartSeriesSnapshot;
      const ASeriesIndex: Integer): TAlphaColor;
    function ResolveGradientEndColor(const ASeries: TDACChartSeriesSnapshot;
      const ASeriesIndex: Integer): TAlphaColor;
    procedure SetAppearance(const AValue: TDACChartAppearance);
    procedure SetAnimation(const AValue: TDACChartAnimation);
    procedure SetBackgroundColor(const AValue: TAlphaColor);
    procedure SetBorderColor(const AValue: TAlphaColor);
    procedure SetChartGrid(const AValue: TDACChartGridOptions);
    procedure SetChartType(const AValue: TDACChartType);
    procedure SetDataSource(const AValue: TDataSource);
    procedure SetDataMode(const AValue: TDACChartDataMode);
    procedure SetDatasetOptions(const AValue: TDACChartDatasetOptions);
    procedure SetLegend(const AValue: TDACChartLegend);
    procedure SetSeries(const AValue: TDACChartSeriesCollection);
    procedure SetShowFrame(const AValue: Boolean);
    procedure SetThemeMode(const AValue: TDACThemeMode);
    procedure SetTitle(const AValue: TDACChartTitle);
    procedure SetTooltip(const AValue: TDACChartTooltip);
    procedure SetXAxis(const AValue: TDACChartAxis);
    procedure SetYAxis(const AValue: TDACChartAxis);
    procedure StartAnimation;
    procedure StartFrameTimer;
    procedure StopAnimation(const ANotify: Boolean);
    procedure StopFrameTimer;
    procedure ThemeChanged(Sender: TObject);
    procedure UpdateDataLink;
    procedure UpdateAnimationFrame;
    procedure UpdateHoverFrame;
    procedure ValidateSnapshot(const ASnapshot: TDACChartSnapshot);
    function TooltipForHit(const AHit: TDACChartHitArea): string;
    function TryHitTest(const APoint: TPointF; out AHit: TDACChartHitArea): Boolean;
    procedure QueueRefresh(const ADataChanged: Boolean);
    procedure QueueHoverRedraw;
    procedure WMDACChartRefresh(var AMessage: TMessage); message WM_APP + $461;
    procedure WMDACChartHoverRedraw(var AMessage: TMessage); message WM_APP + $462;
    procedure WMDpiChanged(var AMessage: TMessage); message WM_DPICHANGED;
    procedure WMEraseBkgnd(var AMessage: TWMEraseBkgnd); message WM_ERASEBKGND;
    procedure WMTimer(var AMessage: TWMTimer); message WM_TIMER;
  protected
    procedure Click; override;
    procedure CreateWnd; override;
    procedure DestroyWnd; override;
    procedure Loaded; override;
    procedure MouseLeave(var Message: TMessage); message CM_MOUSELEAVE;
    procedure KeyDown(var Key: Word; Shift: TShiftState); override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure Notification(AComponent: TComponent; Operation: TOperation); override;
    procedure Paint; override;
    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    property DpiScale: Single read FDpiScale;
    property EffectiveDpi: Integer read FEffectiveDpi;
    function ResolvedAccentColor: TAlphaColor;
    function ResolvedBackgroundColor: TAlphaColor;
    function ResolvedChartPalette: TDACChartPalette;
    function ResolvedDoughnutSeriesColor(const AIndex: Integer): TAlphaColor;
    procedure Redraw;
    procedure RequeryData;
    procedure Replay;
    procedure Stop;
  published
    property Align;
    property Anchors;
    property Appearance: TDACChartAppearance read FAppearance
      write SetAppearance default mchaDefault;
    property Animation: TDACChartAnimation read FAnimation write SetAnimation;
    property BackgroundColor: TAlphaColor read FBackgroundColor
      write SetBackgroundColor stored IsBackgroundColorStored;
    property HasCustomBackgroundColor: Boolean read FCustomBackgroundColor stored False;
    property BorderColor: TAlphaColor read FBorderColor write SetBorderColor
      stored IsBorderColorStored;
    property ChartGrid: TDACChartGridOptions read FChartGrid write SetChartGrid;
    property ChartType: TDACChartType read FChartType write SetChartType default ctBar;
    property Constraints;
    property DataSource: TDataSource read FDataSource write SetDataSource;
    property DataMode: TDACChartDataMode read FDataMode write SetDataMode default cdmAuto;
    property DatasetOptions: TDACChartDatasetOptions read FDatasetOptions
      write SetDatasetOptions;
    property Enabled;
    property Font;
    property Legend: TDACChartLegend read FLegend write SetLegend;
    property ParentFont;
    property ParentShowHint;
    property PopupMenu;
    property Series: TDACChartSeriesCollection read FSeries write SetSeries;
    property ShowFrame: Boolean read FShowFrame write SetShowFrame default True;
    property ShowHint;
    property TabOrder;
    property TabStop default False;
    property ThemeMode: TDACThemeMode read FThemeMode write SetThemeMode default dtmInherit;
    property Title: TDACChartTitle read FTitle write SetTitle;
    property Tooltip: TDACChartTooltip read FTooltip write SetTooltip;
    property Visible;
    property XAxis: TDACChartAxis read FXAxis write SetXAxis;
    property YAxis: TDACChartAxis read FYAxis write SetYAxis;
    property OnClick;
    property OnAnimationFinish: TDACChartAnimationEvent read FOnAnimationFinish
      write FOnAnimationFinish;
    property OnAnimationStart: TDACChartAnimationEvent read FOnAnimationStart
      write FOnAnimationStart;
    property OnDataError: TDACChartDataErrorEvent read FOnDataError write FOnDataError;
    property OnPointClick: TDACChartPointEvent read FOnPointClick write FOnPointClick;
    property OnPointHover: TDACChartPointEvent read FOnPointHover write FOnPointHover;
    property OnTooltipFormat: TDACChartTooltipFormatEvent read FOnTooltipFormat
      write FOnTooltipFormat;
  end;

procedure RegisterDACChartDataSetAdapter(const AAdapter: TDACChartDataSetAdapter);
procedure UnregisterDACChartDataSetAdapter(const AAdapter: TDACChartDataSetAdapter);

implementation

uses
  System.Math,
  DAC.Components.DesignSystem.ColorTokens,
  DAC.Components.DesignSystem.ComponentStyle,
  DAC.Components.DesignSystem.ControlTokens,
  DAC.Components.DesignSystem.Fonts;

const
  DACChartAnimationTimerId = $DACA;
  DACChartAnimationFrameInterval = 16;
  { Charts are information-dense.  Segoe UI is the Windows UI face used by
    the VCL shell and provides the expected ClearType-compatible proportions
    for axes, legends, titles and tooltips.  Each nested Font property remains
    published and can still be changed in the designer. }
  DACChartDefaultFontFamily = 'Segoe UI';
  DACChartDefaultCategories: array[0..4] of string =
    ('Jan', 'Fev', 'Mar', 'Abr', 'Mai');
  DACChartDefaultValues: array[0..4] of Double =
    (42, 68, 57, 75, 54);

type
  TGetDpiForWindowProc = function(const AWindow: HWND): UINT; stdcall;

var
  GDACChartDataSetAdapters: TList<TDACChartDataSetAdapter>;

procedure RegisterDACChartDataSetAdapter(const AAdapter: TDACChartDataSetAdapter);
begin
  if (AAdapter <> nil) and (GDACChartDataSetAdapters.IndexOf(AAdapter) < 0) then
    GDACChartDataSetAdapters.Add(AAdapter);
end;

procedure UnregisterDACChartDataSetAdapter(const AAdapter: TDACChartDataSetAdapter);
begin
  if GDACChartDataSetAdapters <> nil then
    GDACChartDataSetAdapters.Remove(AAdapter);
end;

function FindDACChartDataSetAdapter(const ADataSet: TDataSet): TDACChartDataSetAdapter;
var
  I: Integer;
begin
  Result := nil;
  if GDACChartDataSetAdapters = nil then
    Exit;
  for I := GDACChartDataSetAdapters.Count - 1 downto 0 do
    if GDACChartDataSetAdapters[I].Supports(ADataSet) then
      Exit(GDACChartDataSetAdapters[I]);
end;

function DACChartColorOrDefault(const AColor, ADefault: TAlphaColor): TAlphaColor;
begin
  if AColor = 0 then
    Result := ADefault
  else
    Result := AColor;
end;

function DACChartFontName(const AFont: TFont): string;
begin
  Result := DACChartDefaultFontFamily;
  if (AFont <> nil) and (AFont.Name <> '') then
    Result := AFont.Name;
end;

function DACChartInterpolateColor(const AStart, AEnd: TAlphaColor;
  const AStep: Single): TAlphaColor;
var
  LA1: Byte;
  LA2: Byte;
  LR1: Byte;
  LR2: Byte;
  LG1: Byte;
  LG2: Byte;
  LB1: Byte;
  LB2: Byte;
  LT: Single;
begin
  LT := EnsureRange(AStep, 0, 1);
  LA1 := Byte((Cardinal(AStart) shr 24) and $FF);
  LR1 := Byte((Cardinal(AStart) shr 16) and $FF);
  LG1 := Byte((Cardinal(AStart) shr 8) and $FF);
  LB1 := Byte(Cardinal(AStart) and $FF);
  LA2 := Byte((Cardinal(AEnd) shr 24) and $FF);
  LR2 := Byte((Cardinal(AEnd) shr 16) and $FF);
  LG2 := Byte((Cardinal(AEnd) shr 8) and $FF);
  LB2 := Byte(Cardinal(AEnd) and $FF);
  Result := TAlphaColor(
    (Round(LA1 + ((LA2 - LA1) * LT)) shl 24) or
    (Round(LR1 + ((LR2 - LR1) * LT)) shl 16) or
    (Round(LG1 + ((LG2 - LG1) * LT)) shl 8) or
    Round(LB1 + ((LB2 - LB1) * LT)));
end;

function DACChartRangeValue(const AValue, AMin, AMax: Double): Double;
begin
  if SameValue(AMax, AMin) then
    Result := 0
  else
    Result := (AValue - AMin) / (AMax - AMin);
  Result := EnsureRange(Result, 0, 1);
end;

{ TDACChartPersistent }

constructor TDACChartPersistent.Create(AOwner: TDACChart);
begin
  inherited Create;
  FOwner := AOwner;
end;

procedure TDACChartPersistent.Changed;
begin
  if FOwner <> nil then
    FOwner.ChartChanged;
end;

{ TDACChartAnimation }

constructor TDACChartAnimation.Create(AOwner: TDACChart);
begin
  inherited Create(AOwner);
  FEnabled := True;
  FAutoStartOnUpdate := True;
  FDuration := 360;
  FDelay := 0;
  FEasing := caeCubicOut;
  FHoverDuration := 120;
end;

procedure TDACChartAnimation.Assign(Source: TPersistent);
begin
  if Source is TDACChartAnimation then
  begin
    FEnabled := TDACChartAnimation(Source).Enabled;
    FAutoStartOnUpdate := TDACChartAnimation(Source).AutoStartOnUpdate;
    FDuration := TDACChartAnimation(Source).Duration;
    FDelay := TDACChartAnimation(Source).Delay;
    FEasing := TDACChartAnimation(Source).Easing;
    FHoverDuration := TDACChartAnimation(Source).HoverDuration;
    Changed;
  end
  else
    inherited;
end;

procedure TDACChartAnimation.SetAutoStartOnUpdate(const AValue: Boolean);
begin
  if FAutoStartOnUpdate = AValue then Exit;
  FAutoStartOnUpdate := AValue;
  Changed;
end;

procedure TDACChartAnimation.SetDelay(const AValue: Cardinal);
begin
  if FDelay = AValue then Exit;
  FDelay := AValue;
  Changed;
end;

procedure TDACChartAnimation.SetDuration(const AValue: Cardinal);
begin
  if FDuration = AValue then Exit;
  FDuration := AValue;
  Changed;
end;

procedure TDACChartAnimation.SetEasing(const AValue: TDACChartAnimationEasing);
begin
  if FEasing = AValue then Exit;
  FEasing := AValue;
  Changed;
end;

procedure TDACChartAnimation.SetEnabled(const AValue: Boolean);
begin
  if FEnabled = AValue then Exit;
  FEnabled := AValue;
  if not FEnabled and (FOwner <> nil) then
    FOwner.Stop;
  Changed;
end;

procedure TDACChartAnimation.Replay;
begin
  if FOwner <> nil then
    FOwner.Replay;
end;

procedure TDACChartAnimation.SetHoverDuration(const AValue: Cardinal);
begin
  if FHoverDuration = AValue then Exit;
  FHoverDuration := AValue;
  Changed;
end;

procedure TDACChartAnimation.SetRunning(const AValue: Boolean);
begin
  FRunning := AValue;
end;

procedure TDACChartAnimation.Stop;
begin
  if FOwner <> nil then
    FOwner.Stop;
end;

{ TDACChartDatasetOptions }

procedure TDACChartDatasetOptions.Assign(Source: TPersistent);
begin
  if Source is TDACChartDatasetOptions then
  begin
    FDimensions := TDACChartDatasetOptions(Source).Dimensions;
    FSeriesLayoutBy := TDACChartDatasetOptions(Source).SeriesLayoutBy;
    Changed;
  end
  else
    inherited;
end;

procedure TDACChartDatasetOptions.SetDimensions(const AValue: string);
begin
  if FDimensions = AValue then
    Exit;
  FDimensions := AValue;
  Changed;
end;

procedure TDACChartDatasetOptions.SetSeriesLayoutBy(
  const AValue: TDACChartSeriesLayoutBy);
begin
  if FSeriesLayoutBy = AValue then
    Exit;
  FSeriesLayoutBy := AValue;
  Changed;
end;

{ TDACChartTitle }

constructor TDACChartTitle.Create(AOwner: TDACChart);
begin
  inherited Create(AOwner);
  FVisible := False;
  FText := '';
  FSubText := '';
  FAlignment := taLeftJustify;
  FPosition := cpTop;
  FTextVisible := True;
  FSubTextVisible := True;
  FFont := TFont.Create;
  FFont.Name := DACChartDefaultFontFamily;
  FFont.Size := TDACComponentStyle.SectionTitleSize + 1;
  if FFont.Size < 14 then
    FFont.Size := 14;
  FFont.Style := [fsBold];
  FFont.OnChange := FontChanged;
  FSubFont := TFont.Create;
  FSubFont.Name := DACChartDefaultFontFamily;
  FSubFont.Size := TDACComponentStyle.CaptionSize;
  FSubFont.OnChange := FontChanged;
end;

destructor TDACChartTitle.Destroy;
begin
  FSubFont.Free;
  FFont.Free;
  inherited;
end;

procedure TDACChartTitle.Assign(Source: TPersistent);
begin
  if Source is TDACChartTitle then
  begin
    FVisible := TDACChartTitle(Source).Visible;
    FText := TDACChartTitle(Source).Text;
    FSubText := TDACChartTitle(Source).SubText;
    FAlignment := TDACChartTitle(Source).Alignment;
    FPosition := TDACChartTitle(Source).Position;
    FTextColor := TDACChartTitle(Source).TextColor;
    FSubTextColor := TDACChartTitle(Source).SubTextColor;
    FTextVisible := TDACChartTitle(Source).TextVisible;
    FSubTextVisible := TDACChartTitle(Source).SubTextVisible;
    FFont.Assign(TDACChartTitle(Source).Font);
    FSubFont.Assign(TDACChartTitle(Source).SubFont);
    Changed;
  end
  else
    inherited;
end;

procedure TDACChartTitle.FontChanged(Sender: TObject);
begin
  Changed;
end;

procedure TDACChartTitle.SetAlignment(const AValue: TAlignment);
begin
  if FAlignment = AValue then
    Exit;
  FAlignment := AValue;
  Changed;
end;

procedure TDACChartTitle.SetFont(const AValue: TFont);
begin
  FFont.Assign(AValue);
end;

procedure TDACChartTitle.SetPosition(const AValue: TDACChartPosition);
begin
  if FPosition = AValue then
    Exit;
  FPosition := AValue;
  Changed;
end;

procedure TDACChartTitle.SetSubFont(const AValue: TFont);
begin
  FSubFont.Assign(AValue);
end;

procedure TDACChartTitle.SetSubTextColor(const AValue: TAlphaColor);
begin
  if FSubTextColor = AValue then
    Exit;
  FSubTextColor := AValue;
  Changed;
end;

procedure TDACChartTitle.SetSubTextVisible(const AValue: Boolean);
begin
  if FSubTextVisible = AValue then
    Exit;
  FSubTextVisible := AValue;
  Changed;
end;

procedure TDACChartTitle.SetSubText(const AValue: string);
begin
  if FSubText = AValue then
    Exit;
  FSubText := AValue;
  Changed;
end;

procedure TDACChartTitle.SetText(const AValue: string);
begin
  if FText = AValue then
    Exit;
  FText := AValue;
  Changed;
end;

procedure TDACChartTitle.SetTextColor(const AValue: TAlphaColor);
begin
  if FTextColor = AValue then
    Exit;
  FTextColor := AValue;
  Changed;
end;

procedure TDACChartTitle.SetTextVisible(const AValue: Boolean);
begin
  if FTextVisible = AValue then
    Exit;
  FTextVisible := AValue;
  Changed;
end;

procedure TDACChartTitle.SetVisible(const AValue: Boolean);
begin
  if FVisible = AValue then
    Exit;
  FVisible := AValue;
  Changed;
end;

{ TDACChartLegend }

constructor TDACChartLegend.Create(AOwner: TDACChart);
begin
  inherited Create(AOwner);
  FVisible := True;
  FPosition := cpBottom;
  FOrientation := coHorizontal;
  FAllowToggleSeries := True;
  FItemSpacing := 12;
  FPadding := 8;
  FMarkerSize := 10;
  FMarkersVisible := True;
  FLabelsVisible := True;
  FFont := TFont.Create;
  FFont.Name := DACChartDefaultFontFamily;
  FFont.Size := TDACComponentStyle.CaptionSize + 1;
  if FFont.Size < 10 then
    FFont.Size := 10;
  FFont.OnChange := FontChanged;
end;

destructor TDACChartLegend.Destroy;
begin
  FFont.Free;
  inherited;
end;

procedure TDACChartLegend.Assign(Source: TPersistent);
begin
  if Source is TDACChartLegend then
  begin
    FVisible := TDACChartLegend(Source).Visible;
    FPosition := TDACChartLegend(Source).Position;
    FOrientation := TDACChartLegend(Source).Orientation;
    FAllowToggleSeries := TDACChartLegend(Source).AllowToggleSeries;
    FItemSpacing := TDACChartLegend(Source).ItemSpacing;
    FPadding := TDACChartLegend(Source).Padding;
    FMarkerSize := TDACChartLegend(Source).MarkerSize;
    FMarkersVisible := TDACChartLegend(Source).MarkersVisible;
    FLabelsVisible := TDACChartLegend(Source).LabelsVisible;
    FBackgroundVisible := TDACChartLegend(Source).BackgroundVisible;
    FBackgroundColor := TDACChartLegend(Source).BackgroundColor;
    FBorderVisible := TDACChartLegend(Source).BorderVisible;
    FBorderColor := TDACChartLegend(Source).BorderColor;
    FTextColor := TDACChartLegend(Source).TextColor;
    FFont.Assign(TDACChartLegend(Source).Font);
    Changed;
  end
  else
    inherited;
end;

procedure TDACChartLegend.SetAllowToggleSeries(const AValue: Boolean);
begin
  if FAllowToggleSeries = AValue then
    Exit;
  FAllowToggleSeries := AValue;
  Changed;
end;

procedure TDACChartLegend.SetBackgroundColor(const AValue: TAlphaColor);
begin
  if FBackgroundColor = AValue then Exit;
  FBackgroundColor := AValue;
  Changed;
end;

procedure TDACChartLegend.SetBackgroundVisible(const AValue: Boolean);
begin
  if FBackgroundVisible = AValue then Exit;
  FBackgroundVisible := AValue;
  Changed;
end;

procedure TDACChartLegend.SetBorderColor(const AValue: TAlphaColor);
begin
  if FBorderColor = AValue then Exit;
  FBorderColor := AValue;
  Changed;
end;

procedure TDACChartLegend.SetBorderVisible(const AValue: Boolean);
begin
  if FBorderVisible = AValue then Exit;
  FBorderVisible := AValue;
  Changed;
end;

procedure TDACChartLegend.SetFont(const AValue: TFont);
begin
  FFont.Assign(AValue);
end;

procedure TDACChartLegend.SetItemSpacing(const AValue: Integer);
begin
  if FItemSpacing = AValue then
    Exit;
  FItemSpacing := AValue;
  Changed;
end;

procedure TDACChartLegend.SetLabelsVisible(const AValue: Boolean);
begin
  if FLabelsVisible = AValue then Exit;
  FLabelsVisible := AValue;
  Changed;
end;

procedure TDACChartLegend.SetMarkerSize(const AValue: Integer);
begin
  if FMarkerSize = Max(1, AValue) then Exit;
  FMarkerSize := Max(1, AValue);
  Changed;
end;

procedure TDACChartLegend.SetMarkersVisible(const AValue: Boolean);
begin
  if FMarkersVisible = AValue then Exit;
  FMarkersVisible := AValue;
  Changed;
end;

procedure TDACChartLegend.SetOrientation(const AValue: TDACChartOrientation);
begin
  if FOrientation = AValue then
    Exit;
  FOrientation := AValue;
  Changed;
end;

procedure TDACChartLegend.SetPadding(const AValue: Integer);
begin
  if FPadding = Max(0, AValue) then Exit;
  FPadding := Max(0, AValue);
  Changed;
end;

procedure TDACChartLegend.SetPosition(const AValue: TDACChartPosition);
begin
  if FPosition = AValue then
    Exit;
  FPosition := AValue;
  Changed;
end;

procedure TDACChartLegend.SetTextColor(const AValue: TAlphaColor);
begin
  if FTextColor = AValue then Exit;
  FTextColor := AValue;
  Changed;
end;

procedure TDACChartLegend.SetVisible(const AValue: Boolean);
begin
  if FVisible = AValue then
    Exit;
  FVisible := AValue;
  Changed;
end;

procedure TDACChartLegend.FontChanged(Sender: TObject);
begin
  Changed;
end;

{ TDACChartAxis }

constructor TDACChartAxis.Create(AOwner: TDACChart);
begin
  inherited Create(AOwner);
  FVisible := True;
  FAxisType := catValue;
  FAutoScale := True;
  FGridLines := True;
  FTicks := 4;
  FLineVisible := True;
  FLabelsVisible := True;
  FTickMarksVisible := True;
  FTitleVisible := True;
  FLabelFont := TFont.Create;
  FLabelFont.Name := DACChartDefaultFontFamily;
  FLabelFont.Size := TDACComponentStyle.CaptionSize + 1;
  if FLabelFont.Size < 10 then
    FLabelFont.Size := 10;
  FLabelFont.OnChange := FontChanged;
  FTitleFont := TFont.Create;
  FTitleFont.Name := DACChartDefaultFontFamily;
  FTitleFont.Size := TDACComponentStyle.CaptionSize + 2;
  if FTitleFont.Size < 11 then
    FTitleFont.Size := 11;
  FTitleFont.OnChange := FontChanged;
end;

destructor TDACChartAxis.Destroy;
begin
  FTitleFont.Free;
  FLabelFont.Free;
  inherited;
end;

procedure TDACChartAxis.Assign(Source: TPersistent);
begin
  if Source is TDACChartAxis then
  begin
    FVisible := TDACChartAxis(Source).Visible;
    FAxisType := TDACChartAxis(Source).AxisType;
    FAutoScale := TDACChartAxis(Source).AutoScale;
    FGridLines := TDACChartAxis(Source).GridLines;
    FGridColor := TDACChartAxis(Source).GridColor;
    FLineVisible := TDACChartAxis(Source).LineVisible;
    FLineColor := TDACChartAxis(Source).LineColor;
    FLabelsVisible := TDACChartAxis(Source).LabelsVisible;
    FLabelColor := TDACChartAxis(Source).LabelColor;
    FLabelFont.Assign(TDACChartAxis(Source).LabelFont);
    FTickMarksVisible := TDACChartAxis(Source).TickMarksVisible;
    FMin := TDACChartAxis(Source).Min;
    FMax := TDACChartAxis(Source).Max;
    FTicks := TDACChartAxis(Source).Ticks;
    FTitle := TDACChartAxis(Source).Title;
    FTitleVisible := TDACChartAxis(Source).TitleVisible;
    FTitleColor := TDACChartAxis(Source).TitleColor;
    FTitleFont.Assign(TDACChartAxis(Source).TitleFont);
    FLabelFormat := TDACChartAxis(Source).LabelFormat;
    Changed;
  end
  else
    inherited;
end;

procedure TDACChartAxis.SetAutoScale(const AValue: Boolean);
begin
  if FAutoScale = AValue then
    Exit;
  FAutoScale := AValue;
  Changed;
end;

procedure TDACChartAxis.SetAxisType(const AValue: TDACChartAxisType);
begin
  if FAxisType = AValue then
    Exit;
  FAxisType := AValue;
  Changed;
end;

procedure TDACChartAxis.SetGridColor(const AValue: TAlphaColor);
begin
  if FGridColor = AValue then Exit;
  FGridColor := AValue;
  Changed;
end;

procedure TDACChartAxis.SetGridLines(const AValue: Boolean);
begin
  if FGridLines = AValue then
    Exit;
  FGridLines := AValue;
  Changed;
end;

procedure TDACChartAxis.SetLabelColor(const AValue: TAlphaColor);
begin
  if FLabelColor = AValue then Exit;
  FLabelColor := AValue;
  Changed;
end;

procedure TDACChartAxis.SetLabelFont(const AValue: TFont);
begin
  FLabelFont.Assign(AValue);
end;

procedure TDACChartAxis.SetLabelsVisible(const AValue: Boolean);
begin
  if FLabelsVisible = AValue then Exit;
  FLabelsVisible := AValue;
  Changed;
end;

procedure TDACChartAxis.SetLabelFormat(const AValue: string);
begin
  if FLabelFormat = AValue then
    Exit;
  FLabelFormat := AValue;
  Changed;
end;

procedure TDACChartAxis.SetLineColor(const AValue: TAlphaColor);
begin
  if FLineColor = AValue then Exit;
  FLineColor := AValue;
  Changed;
end;

procedure TDACChartAxis.SetLineVisible(const AValue: Boolean);
begin
  if FLineVisible = AValue then Exit;
  FLineVisible := AValue;
  Changed;
end;

procedure TDACChartAxis.SetMax(const AValue: Double);
begin
  if SameValue(FMax, AValue) then
    Exit;
  FMax := AValue;
  Changed;
end;

procedure TDACChartAxis.SetMin(const AValue: Double);
begin
  if SameValue(FMin, AValue) then
    Exit;
  FMin := AValue;
  Changed;
end;

procedure TDACChartAxis.SetTicks(const AValue: Integer);
begin
  if FTicks = AValue then
    Exit;
  if AValue < 1 then
    FTicks := 1
  else
    FTicks := AValue;
  Changed;
end;

procedure TDACChartAxis.SetTickMarksVisible(const AValue: Boolean);
begin
  if FTickMarksVisible = AValue then Exit;
  FTickMarksVisible := AValue;
  Changed;
end;

procedure TDACChartAxis.SetTitleColor(const AValue: TAlphaColor);
begin
  if FTitleColor = AValue then Exit;
  FTitleColor := AValue;
  Changed;
end;

procedure TDACChartAxis.SetTitleFont(const AValue: TFont);
begin
  FTitleFont.Assign(AValue);
end;

procedure TDACChartAxis.SetTitle(const AValue: string);
begin
  if FTitle = AValue then
    Exit;
  FTitle := AValue;
  Changed;
end;

procedure TDACChartAxis.SetTitleVisible(const AValue: Boolean);
begin
  if FTitleVisible = AValue then Exit;
  FTitleVisible := AValue;
  Changed;
end;

procedure TDACChartAxis.SetVisible(const AValue: Boolean);
begin
  if FVisible = AValue then
    Exit;
  FVisible := AValue;
  Changed;
end;

procedure TDACChartAxis.FontChanged(Sender: TObject);
begin
  Changed;
end;

{ TDACChartGridOptions }

constructor TDACChartGridOptions.Create(AOwner: TDACChart);
begin
  inherited Create(AOwner);
  FVisible := True;
  FLineStyle := psSolid;
  FPadding := 16;
  FMargins := TDACChartMargins.Create(AOwner);
end;

destructor TDACChartGridOptions.Destroy;
begin
  FMargins.Free;
  inherited;
end;

procedure TDACChartGridOptions.Assign(Source: TPersistent);
begin
  if Source is TDACChartGridOptions then
  begin
    FVisible := TDACChartGridOptions(Source).Visible;
    FLineStyle := TDACChartGridOptions(Source).LineStyle;
    FPadding := TDACChartGridOptions(Source).Padding;
    FMargins.Assign(TDACChartGridOptions(Source).Margins);
    Changed;
  end
  else
    inherited;
end;

{ TDACChartMargins }

procedure TDACChartMargins.Assign(Source: TPersistent);
begin
  if Source is TDACChartMargins then
  begin
    FLeft := TDACChartMargins(Source).Left;
    FTop := TDACChartMargins(Source).Top;
    FRight := TDACChartMargins(Source).Right;
    FBottom := TDACChartMargins(Source).Bottom;
    Changed;
  end
  else
    inherited;
end;

procedure TDACChartMargins.SetBottom(const AValue: Integer);
begin
  if FBottom = Max(0, AValue) then Exit;
  FBottom := Max(0, AValue); Changed;
end;

procedure TDACChartMargins.SetLeft(const AValue: Integer);
begin
  if FLeft = Max(0, AValue) then Exit;
  FLeft := Max(0, AValue); Changed;
end;

procedure TDACChartMargins.SetRight(const AValue: Integer);
begin
  if FRight = Max(0, AValue) then Exit;
  FRight := Max(0, AValue); Changed;
end;

procedure TDACChartMargins.SetTop(const AValue: Integer);
begin
  if FTop = Max(0, AValue) then Exit;
  FTop := Max(0, AValue); Changed;
end;

procedure TDACChartGridOptions.SetLineStyle(const AValue: TPenStyle);
begin
  if FLineStyle = AValue then
    Exit;
  FLineStyle := AValue;
  Changed;
end;

procedure TDACChartGridOptions.SetPadding(const AValue: Integer);
begin
  if FPadding = AValue then
    Exit;
  FPadding := Max(0, AValue);
  Changed;
end;

procedure TDACChartGridOptions.SetVisible(const AValue: Boolean);
begin
  if FVisible = AValue then
    Exit;
  FVisible := AValue;
  Changed;
end;

{ TDACChartTooltip }

constructor TDACChartTooltip.Create(AOwner: TDACChart);
begin
  inherited Create(AOwner);
  FEnabled := True;
  FMode := ctmNearest;
  FFollowMouse := True;
  FShowMarker := True;
  FFormatter := '{series}: {value}';
  FPadding := 14;
  FFont := TFont.Create;
  FFont.Name := DACChartDefaultFontFamily;
  FFont.Size := Max(12, TDACComponentStyle.CaptionSize + 3);
  FFont.OnChange := FontChanged;
  FTitleFont := TFont.Create;
  FTitleFont.Name := DACChartDefaultFontFamily;
  FTitleFont.Size := Max(14, FFont.Size + 1);
  FTitleFont.Style := [fsBold];
  FTitleFont.OnChange := FontChanged;
end;

destructor TDACChartTooltip.Destroy;
begin
  FTitleFont.Free;
  FFont.Free;
  inherited;
end;

procedure TDACChartTooltip.Assign(Source: TPersistent);
begin
  if Source is TDACChartTooltip then
  begin
    FBackgroundColor := TDACChartTooltip(Source).BackgroundColor;
    FBorderColor := TDACChartTooltip(Source).BorderColor;
    FEnabled := TDACChartTooltip(Source).Enabled;
    FMode := TDACChartTooltip(Source).Mode;
    FFollowMouse := TDACChartTooltip(Source).FollowMouse;
    FShowMarker := TDACChartTooltip(Source).ShowMarker;
    FFormatter := TDACChartTooltip(Source).Formatter;
    FPadding := TDACChartTooltip(Source).Padding;
    FTextColor := TDACChartTooltip(Source).TextColor;
    FTitleColor := TDACChartTooltip(Source).TitleColor;
    FFont.Assign(TDACChartTooltip(Source).Font);
    FTitleFont.Assign(TDACChartTooltip(Source).TitleFont);
    Changed;
  end
  else
    inherited;
end;

procedure TDACChartTooltip.FontChanged(Sender: TObject);
begin
  Changed;
end;

procedure TDACChartTooltip.SetBackgroundColor(const AValue: TAlphaColor);
begin
  if FBackgroundColor = AValue then
    Exit;
  FBackgroundColor := AValue;
  Changed;
end;

procedure TDACChartTooltip.SetBorderColor(const AValue: TAlphaColor);
begin
  if FBorderColor = AValue then
    Exit;
  FBorderColor := AValue;
  Changed;
end;

procedure TDACChartTooltip.SetFormatter(const AValue: string);
begin
  if FFormatter = AValue then
    Exit;
  FFormatter := AValue;
  Changed;
end;

procedure TDACChartTooltip.SetEnabled(const AValue: Boolean);
begin
  if FEnabled = AValue then
    Exit;
  FEnabled := AValue;
  Changed;
end;

procedure TDACChartTooltip.SetFont(const AValue: TFont);
begin
  FFont.Assign(AValue);
end;

procedure TDACChartTooltip.SetFollowMouse(const AValue: Boolean);
begin
  if FFollowMouse = AValue then
    Exit;
  FFollowMouse := AValue;
  Changed;
end;

procedure TDACChartTooltip.SetMode(const AValue: TDACChartTooltipMode);
begin
  if FMode = AValue then
    Exit;
  FMode := AValue;
  Changed;
end;

procedure TDACChartTooltip.SetPadding(const AValue: Integer);
begin
  if FPadding = Max(4, AValue) then
    Exit;
  FPadding := Max(4, AValue);
  Changed;
end;

procedure TDACChartTooltip.SetShowMarker(const AValue: Boolean);
begin
  if FShowMarker = AValue then
    Exit;
  FShowMarker := AValue;
  Changed;
end;

procedure TDACChartTooltip.SetTextColor(const AValue: TAlphaColor);
begin
  if FTextColor = AValue then
    Exit;
  FTextColor := AValue;
  Changed;
end;

procedure TDACChartTooltip.SetTitleColor(const AValue: TAlphaColor);
begin
  if FTitleColor = AValue then
    Exit;
  FTitleColor := AValue;
  Changed;
end;

procedure TDACChartTooltip.SetTitleFont(const AValue: TFont);
begin
  FTitleFont.Assign(AValue);
end;

{ TDACChartSeries }

{ TDACChartPoint }

procedure TDACChartPoint.Assign(Source: TPersistent);
begin
  if Source is TDACChartPoint then
  begin
    FCategory := TDACChartPoint(Source).Category;
    FXValue := TDACChartPoint(Source).XValue;
    FValue := TDACChartPoint(Source).Value;
    FIsNull := TDACChartPoint(Source).IsNull;
    FLabelText := TDACChartPoint(Source).LabelText;
    FTooltipText := TDACChartPoint(Source).TooltipText;
    Changed;
  end
  else
    inherited;
end;

procedure TDACChartPoint.Changed;
begin
  inherited Changed(False);
end;

procedure TDACChartPoint.SetCategory(const AValue: string);
begin
  if FCategory = AValue then Exit;
  FCategory := AValue; Changed;
end;

procedure TDACChartPoint.SetIsNull(const AValue: Boolean);
begin
  if FIsNull = AValue then Exit;
  FIsNull := AValue; Changed;
end;

procedure TDACChartPoint.SetLabelText(const AValue: string);
begin
  if FLabelText = AValue then Exit;
  FLabelText := AValue; Changed;
end;

procedure TDACChartPoint.SetTooltipText(const AValue: string);
begin
  if FTooltipText = AValue then Exit;
  FTooltipText := AValue; Changed;
end;

procedure TDACChartPoint.SetValue(const AValue: Double);
begin
  if SameValue(FValue, AValue) then Exit;
  FValue := AValue; Changed;
end;

procedure TDACChartPoint.SetXValue(const AValue: Double);
begin
  if SameValue(FXValue, AValue) then Exit;
  FXValue := AValue; Changed;
end;

{ TDACChartPointCollection }

constructor TDACChartPointCollection.Create(AOwner: TDACChartSeries);
begin
  inherited Create(AOwner, TDACChartPoint);
  FSeries := AOwner;
end;

function TDACChartPointCollection.Add: TDACChartPoint;
begin
  Result := inherited Add as TDACChartPoint;
end;

function TDACChartPointCollection.GetItem(AIndex: Integer): TDACChartPoint;
begin
  Result := inherited Items[AIndex] as TDACChartPoint;
end;

procedure TDACChartPointCollection.Update(Item: TCollectionItem);
begin
  inherited;
  if FSeries <> nil then
    FSeries.Changed;
end;

constructor TDACChartSeries.Create(Collection: TCollection);
begin
  inherited Create(Collection);
  FChartType := ctBar;
  FFillMode := cfSolid;
  FVisible := True;
  FGradientAngle := 90;
  FPoints := TDACChartPointCollection.Create(Self);
end;

destructor TDACChartSeries.Destroy;
begin
  FPoints.Free;
  inherited;
end;

procedure TDACChartSeries.Assign(Source: TPersistent);
begin
  if Source is TDACChartSeries then
  begin
    FName := TDACChartSeries(Source).Name;
    FChartType := TDACChartSeries(Source).ChartType;
    FEncodeX := TDACChartSeries(Source).EncodeX;
    FEncodeY := TDACChartSeries(Source).EncodeY;
    FEncodeValue := TDACChartSeries(Source).EncodeValue;
    FEncodeLabel := TDACChartSeries(Source).EncodeLabel;
    FEncodeTooltip := TDACChartSeries(Source).EncodeTooltip;
    FEncodeSeries := TDACChartSeries(Source).EncodeSeries;
    FFillMode := TDACChartSeries(Source).FillMode;
    FColor := TDACChartSeries(Source).Color;
    FGradientStartColor := TDACChartSeries(Source).GradientStartColor;
    FGradientEndColor := TDACChartSeries(Source).GradientEndColor;
    FGradientAngle := TDACChartSeries(Source).GradientAngle;
    FVisible := TDACChartSeries(Source).Visible;
    FPoints.Assign(TDACChartSeries(Source).Points);
    Changed;
  end
  else
    inherited;
end;

procedure TDACChartSeries.Changed;
begin
  inherited Changed(False);
end;

procedure TDACChartSeries.SetChartType(const AValue: TDACChartType);
begin
  if FChartType = AValue then
    Exit;
  FChartType := AValue;
  Changed;
end;

procedure TDACChartSeries.SetColor(const AValue: TAlphaColor);
begin
  if FColor = AValue then
    Exit;
  FColor := AValue;
  Changed;
end;

procedure TDACChartSeries.SetEncodeLabel(const AValue: string);
begin
  if FEncodeLabel = AValue then
    Exit;
  FEncodeLabel := AValue;
  Changed;
end;

procedure TDACChartSeries.SetEncodeSeries(const AValue: string);
begin
  if FEncodeSeries = AValue then
    Exit;
  FEncodeSeries := AValue;
  Changed;
end;

procedure TDACChartSeries.SetEncodeTooltip(const AValue: string);
begin
  if FEncodeTooltip = AValue then
    Exit;
  FEncodeTooltip := AValue;
  Changed;
end;

procedure TDACChartSeries.SetEncodeValue(const AValue: string);
begin
  if FEncodeValue = AValue then
    Exit;
  FEncodeValue := AValue;
  Changed;
end;

procedure TDACChartSeries.SetEncodeX(const AValue: string);
begin
  if FEncodeX = AValue then
    Exit;
  FEncodeX := AValue;
  Changed;
end;

procedure TDACChartSeries.SetEncodeY(const AValue: string);
begin
  if FEncodeY = AValue then
    Exit;
  FEncodeY := AValue;
  Changed;
end;

procedure TDACChartSeries.SetFillMode(const AValue: TDACChartFillMode);
begin
  if FFillMode = AValue then
    Exit;
  FFillMode := AValue;
  Changed;
end;

procedure TDACChartSeries.SetGradientAngle(const AValue: Single);
begin
  if SameValue(FGradientAngle, AValue) then
    Exit;
  FGradientAngle := AValue;
  Changed;
end;

procedure TDACChartSeries.SetGradientEndColor(const AValue: TAlphaColor);
begin
  if FGradientEndColor = AValue then
    Exit;
  FGradientEndColor := AValue;
  Changed;
end;

procedure TDACChartSeries.SetGradientStartColor(const AValue: TAlphaColor);
begin
  if FGradientStartColor = AValue then
    Exit;
  FGradientStartColor := AValue;
  Changed;
end;

procedure TDACChartSeries.SetName(const AValue: string);
begin
  if FName = AValue then
    Exit;
  FName := AValue;
  Changed;
end;

procedure TDACChartSeries.SetVisible(const AValue: Boolean);
begin
  if FVisible = AValue then
    Exit;
  FVisible := AValue;
  Changed;
end;

{ TDACChartSeriesCollection }

constructor TDACChartSeriesCollection.Create(AOwner: TPersistent);
begin
  inherited Create(AOwner, TDACChartSeries);
end;

function TDACChartSeriesCollection.Add: TDACChartSeries;
begin
  Result := inherited Add as TDACChartSeries;
end;

function TDACChartSeriesCollection.GetItem(AIndex: Integer): TDACChartSeries;
begin
  Result := inherited Items[AIndex] as TDACChartSeries;
end;

procedure TDACChartSeriesCollection.SetItem(AIndex: Integer;
  const AValue: TDACChartSeries);
begin
  inherited Items[AIndex] := AValue;
end;

procedure TDACChartSeriesCollection.Update(Item: TCollectionItem);
begin
  inherited;
  if GetOwner is TDACChart then
    TDACChart(GetOwner).ChartChanged;
end;

{ TDACChartDataLink }

constructor TDACChartDataLink.Create(AChart: TDACChart);
begin
  inherited Create;
  FChart := AChart;
end;

procedure TDACChartDataLink.ActiveChanged;
begin
  inherited;
  if FChart <> nil then
    FChart.RequeryData;
end;

procedure TDACChartDataLink.DataSetChanged;
begin
  inherited;
  if FChart <> nil then
    FChart.RequeryData;
end;

procedure TDACChartDataLink.RecordChanged(Field: TField);
begin
  inherited;
  if FChart <> nil then
    FChart.RequeryData;
end;

{ TDACChart }

constructor TDACChart.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque, csCaptureMouse, csClickEvents];
  { The chart already owns a Skia back buffer.  Let VCL buffer the final
    native text/tooltip overlay too, so a mouse move cannot expose a partial
    GDI overlay between frames. }
  DoubleBuffered := True;
  { Charts need enough physical room for axes, title and a non-overlapping
    legend.  Keep these logical dimensions; Pixels() applies the per-window
    DPI only to the rendered metrics. }
  Constraints.MinWidth := 560;
  Constraints.MinHeight := 360;
  Width := Max(Constraints.MinWidth,
    Round(TDACComponentStyle.Resolve(dtmInherit).Tokens.Controls.ChartDefaultWidth));
  Height := Max(Constraints.MinHeight,
    Round(TDACComponentStyle.Resolve(dtmInherit).Tokens.Controls.ChartDefaultHeight));
  TabStop := False;
  ParentColor := False;
  StyleElements := [];
  Font.Name := DACChartDefaultFontFamily;
  Font.Size := TDACComponentStyle.CaptionSize;
  ShowHint := True;

  FRenderer := TDACSkiaRenderer.Create;
  FDatasetOptions := TDACChartDatasetOptions.Create(Self);
  FSeries := TDACChartSeriesCollection.Create(Self);
  FTitle := TDACChartTitle.Create(Self);
  FLegend := TDACChartLegend.Create(Self);
  FXAxis := TDACChartAxis.Create(Self);
  FXAxis.AxisType := catCategory;
  FYAxis := TDACChartAxis.Create(Self);
  FChartGrid := TDACChartGridOptions.Create(Self);
  FTooltip := TDACChartTooltip.Create(Self);
  FAnimation := TDACChartAnimation.Create(Self);
  FHitAreas := TList<TDACChartHitArea>.Create;
  FNativeStaticTextItems := TList<TDACChartNativeTextItem>.Create;
  FNativeOverlayTextItems := TList<TDACChartNativeTextItem>.Create;
  FNativeOverlayMarkers := TList<TDACChartNativeTooltipMarker>.Create;
  FNativeFrameTextItems := TList<TDACChartNativeTextItem>.Create;
  FNativeFrameOverlayTextItems := TList<TDACChartNativeTextItem>.Create;
  FNativeFrameOverlayMarkers := TList<TDACChartNativeTooltipMarker>.Create;
  FNativeTextWidths := TDictionary<string, Single>.Create;

  FThemeMode := dtmInherit;
  FAppearance := mchaDefault;
  FBaseAppearance := mchaDefault;
  FChartType := ctBar;
  FDataMode := cdmAuto;
  FEffectiveDpi := 96;
  FDpiScale := 1;
  FShowFrame := True;
  FDataDirty := True;
  FHoverTooltipPointIndex := -1;
  FHoverTooltipRevision := -1;
  FHoverTooltipSeriesIndex := -1;
  FKeyboardHitIndex := -1;
  FLayoutDirty := True;
  FGeometryDirty := True;
  FHoverOpacity := 1;
  ApplyAppearance;
  Color := TDACComponentColors.ToVclColor(FBackgroundColor);
  TDACThemeManager.RegisterListener(Self, ThemeChanged);
end;

destructor TDACChart.Destroy;
begin
  StopAnimation(False);
  TDACThemeManager.UnregisterListener(Self);
  SetDataSource(nil);
  FNativeFrameOverlayMarkers.Free;
  FNativeFrameOverlayTextItems.Free;
  FNativeFrameTextItems.Free;
  FNativeOverlayMarkers.Free;
  FNativeOverlayTextItems.Free;
  FNativeStaticTextItems.Free;
  FNativeTextWidths.Free;
  FHitAreas.Free;
  FAnimation.Free;
  FTooltip.Free;
  FChartGrid.Free;
  FYAxis.Free;
  FXAxis.Free;
  FLegend.Free;
  FTitle.Free;
  FSeries.Free;
  FDatasetOptions.Free;
  FDataLink.Free;
  FRenderer.Free;
  inherited;
end;

procedure TDACChart.ApplyAppearance;
var
  LAppearance: TDACChartAppearance;
  LTokens: TDACControlTokens;
begin
  LTokens := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls;
  LAppearance := FAppearance;
  if LAppearance = mchaCustom then
    LAppearance := FBaseAppearance;
  case LAppearance of
    mchaDefault:
      begin
        if (FAppearance <> mchaCustom) or not FCustomBackgroundColor then
          FBackgroundColor := LTokens.ContainerSuiteBackground;
        if (FAppearance <> mchaCustom) or not FCustomBorderColor then
          FBorderColor := LTokens.ContainerSuiteBorder;
      end;
    mchaDashboard:
      begin
        if (FAppearance <> mchaCustom) or not FCustomBackgroundColor then
          FBackgroundColor := LTokens.ChartDashboardBackground;
        if (FAppearance <> mchaCustom) or not FCustomBorderColor then
          FBorderColor := LTokens.ChartDashboardBorder;
      end;
  end;
  if FAppearance <> mchaCustom then
  begin
    FCustomBackgroundColor := False;
    FCustomBorderColor := False;
  end;
  Color := TDACComponentColors.ToVclColor(FBackgroundColor);
end;

procedure TDACChart.ApplyFillPaint(const APaint: ISkPaint;
  const ASeries: TDACChartSeriesSnapshot; const ASeriesIndex: Integer;
  const ABounds: TRectF);
var
  LAngle: Double;
  LCenter: TPointF;
  LDirection: TPointF;
  LEnd: TAlphaColor;
  LExtent: Single;
  LStart: TAlphaColor;
begin
  LStart := ASeries.GradientStartColor;
  if LStart = 0 then
    LStart := ResolveFillColor(ASeries, ASeriesIndex);
  LEnd := ResolveGradientEndColor(ASeries, ASeriesIndex);
  APaint.Shader := nil;
  APaint.Color := LStart;
  case ASeries.FillMode of
    cfLinearGradient:
      begin
        LAngle := DegToRad(ASeries.GradientAngle -
          Floor(ASeries.GradientAngle / 360) * 360);
        LCenter := PointF((ABounds.Left + ABounds.Right) / 2,
          (ABounds.Top + ABounds.Bottom) / 2);
        LExtent := Max(ABounds.Width, ABounds.Height) / 2;
        LDirection := PointF(Cos(LAngle) * LExtent, Sin(LAngle) * LExtent);
        APaint.Shader := TSkShader.MakeGradientLinear(
          PointF(LCenter.X - LDirection.X, LCenter.Y - LDirection.Y),
          PointF(LCenter.X + LDirection.X, LCenter.Y + LDirection.Y),
          LStart, LEnd, TSkTileMode.Clamp);
      end;
    cfRadialGradient:
      begin
        LCenter := PointF((ABounds.Left + ABounds.Right) / 2,
          (ABounds.Top + ABounds.Bottom) / 2);
        APaint.Shader := TSkShader.MakeGradientRadial(LCenter,
          Max(1, Max(ABounds.Width, ABounds.Height) / 2), LStart, LEnd,
          TSkTileMode.Clamp);
      end;
  end;
end;

procedure TDACChart.BuildDesignSnapshot(var ASnapshot: TDACChartSnapshot);
var
  I: Integer;
  LSeries: TDACChartSeriesSnapshot;
begin
  ClearSnapshot(ASnapshot);
  SetLength(ASnapshot.Series, 1);
  LSeries.Name := 'Demonstração';
  LSeries.ChartType := FChartType;
  LSeries.FillMode := cfLinearGradient;
  LSeries.Color := 0;
  LSeries.GradientStartColor := 0;
  LSeries.GradientEndColor := 0;
  LSeries.GradientAngle := 90;
  LSeries.Visible := True;
  SetLength(LSeries.Values, Length(DACChartDefaultValues));
  for I := Low(DACChartDefaultValues) to High(DACChartDefaultValues) do
  begin
    LSeries.Values[I].Category := DACChartDefaultCategories[I];
    LSeries.Values[I].Value := DACChartDefaultValues[I];
    LSeries.Values[I].IsNull := False;
  end;
  ASnapshot.Series[0] := LSeries;
  ASnapshot.CategoryCount := Length(DACChartDefaultValues);
  ASnapshot.HasData := True;
end;

procedure TDACChart.BuildManualSnapshot(var ASnapshot: TDACChartSnapshot);
var
  I: Integer;
  J: Integer;
  LPoint: TDACChartPoint;
  LSeries: TDACChartSeries;
begin
  ClearSnapshot(ASnapshot);
  if FSeries.Count = 0 then
    Exit;

  SetLength(ASnapshot.Series, FSeries.Count);
  for I := 0 to FSeries.Count - 1 do
  begin
    LSeries := FSeries[I];
    ASnapshot.Series[I].Name := LSeries.Name;
    ASnapshot.Series[I].ChartType := LSeries.ChartType;
    ASnapshot.Series[I].FillMode := LSeries.FillMode;
    ASnapshot.Series[I].Color := LSeries.Color;
    ASnapshot.Series[I].GradientStartColor := LSeries.GradientStartColor;
    ASnapshot.Series[I].GradientEndColor := LSeries.GradientEndColor;
    ASnapshot.Series[I].GradientAngle := LSeries.GradientAngle;
    ASnapshot.Series[I].Visible := LSeries.Visible;
    SetLength(ASnapshot.Series[I].Values, LSeries.Points.Count);
    for J := 0 to LSeries.Points.Count - 1 do
    begin
      LPoint := LSeries.Points[J];
      ASnapshot.Series[I].Values[J].Category := LPoint.Category;
      ASnapshot.Series[I].Values[J].XValue := LPoint.XValue;
      ASnapshot.Series[I].Values[J].Value := LPoint.Value;
      ASnapshot.Series[I].Values[J].IsNull := LPoint.IsNull;
      ASnapshot.Series[I].Values[J].LabelText := LPoint.LabelText;
      ASnapshot.Series[I].Values[J].TooltipText := LPoint.TooltipText;
    end;
    ASnapshot.CategoryCount := Max(ASnapshot.CategoryCount, LSeries.Points.Count);
  end;
  ASnapshot.HasData := ASnapshot.CategoryCount > 0;
end;

procedure TDACChart.BuildSnapshotFromDataSet(var ASnapshot: TDACChartSnapshot);
var
  I: Integer;
  LAdapter: TDACChartDataSetAdapter;
  LClone: TDataSet;
  LDataSet: TDataSet;
  LDimensions: TStringList;
  LIndex: Integer;
  LLabelField: string;
  LSeries: TDACChartSeries;
  LTooltipField: string;
  LValueField: string;
  LXField: string;
  procedure ParseDimensions;
  var
    LRemoveIndex: Integer;
  begin
    LDimensions.Clear;
    LDimensions.Delimiter := ';';
    LDimensions.StrictDelimiter := True;
    LDimensions.DelimitedText := FDatasetOptions.Dimensions;
    for LRemoveIndex := LDimensions.Count - 1 downto 0 do
    begin
      LDimensions[LRemoveIndex] := Trim(LDimensions[LRemoveIndex]);
      if LDimensions[LRemoveIndex] = '' then
        LDimensions.Delete(LRemoveIndex);
    end;
  end;
  procedure ConfigureSeries(const AIndex: Integer; const ASource: TDACChartSeries;
    const AName: string);
  begin
    ASnapshot.Series[AIndex].Name := AName;
    ASnapshot.Series[AIndex].ChartType := FChartType;
    ASnapshot.Series[AIndex].FillMode := cfSolid;
    ASnapshot.Series[AIndex].Visible := True;
    if ASource <> nil then
    begin
      ASnapshot.Series[AIndex].ChartType := ASource.ChartType;
      ASnapshot.Series[AIndex].FillMode := ASource.FillMode;
      ASnapshot.Series[AIndex].Color := ASource.Color;
      ASnapshot.Series[AIndex].GradientStartColor := ASource.GradientStartColor;
      ASnapshot.Series[AIndex].GradientEndColor := ASource.GradientEndColor;
      ASnapshot.Series[AIndex].GradientAngle := ASource.GradientAngle;
      ASnapshot.Series[AIndex].Visible := ASource.Visible;
    end;
  end;
  procedure AppendDataValue(const ASeriesIndex: Integer; const ACategory,
    AValueField, ALabelField, ATooltipField: string);
  var
    LField: TField;
  begin
    SetLength(ASnapshot.Series[ASeriesIndex].Values, LIndex + 1);
    ASnapshot.Series[ASeriesIndex].Values[LIndex].Category := ACategory;
    ASnapshot.Series[ASeriesIndex].Values[LIndex].XValue := LIndex;
    LField := LDataSet.FindField(AValueField);
    ASnapshot.Series[ASeriesIndex].Values[LIndex].IsNull :=
      (AValueField = '') or (LField = nil) or LField.IsNull;
    if not ASnapshot.Series[ASeriesIndex].Values[LIndex].IsNull then
      ASnapshot.Series[ASeriesIndex].Values[LIndex].Value := LField.AsFloat;
    if ALabelField <> '' then
      ASnapshot.Series[ASeriesIndex].Values[LIndex].LabelText :=
        FieldText(LDataSet, ALabelField, '');
    if ATooltipField <> '' then
      ASnapshot.Series[ASeriesIndex].Values[LIndex].TooltipText :=
        FieldText(LDataSet, ATooltipField, '');
  end;
begin
  ClearSnapshot(ASnapshot);
  if (FDataSource = nil) or (FDataSource.DataSet = nil) or
    not FDataSource.DataSet.Active or FDataSource.DataSet.IsEmpty then
  begin
    if csDesigning in ComponentState then
      BuildDesignSnapshot(ASnapshot);
    Exit;
  end;

  LAdapter := FindDACChartDataSetAdapter(FDataSource.DataSet);
  if LAdapter = nil then
    raise EDACChartDataError.CreateFmt('%s nao possui adapter de leitura registrado.',
      [FDataSource.DataSet.ClassName]);

  LClone := nil;
  LDimensions := TStringList.Create;
  try
    LClone := LAdapter.CreateReadCursor(FDataSource.DataSet);
    if LClone = nil then
      raise EDACChartDataError.CreateFmt('%s retornou um cursor de leitura nulo.',
        [LAdapter.ClassName]);
    LDataSet := LClone;
    ParseDimensions;

    if (FDatasetOptions.SeriesLayoutBy = cslColumns) and
      (LDimensions.Count >= 2) and (FSeries.Count = 0) then
    begin
      { A primeira dimensao e a categoria/X. Cada coluna seguinte cria uma
        serie persistente apenas no snapshot, sem alterar a colecao do chart. }
      SetLength(ASnapshot.Series, LDimensions.Count - 1);
      for I := 0 to High(ASnapshot.Series) do
        ConfigureSeries(I, nil, LDimensions[I + 1]);
    end
    else if FSeries.Count = 0 then
    begin
      SetLength(ASnapshot.Series, 1);
      ConfigureSeries(0, nil, '');
    end
    else
    begin
      SetLength(ASnapshot.Series, FSeries.Count);
      for I := 0 to FSeries.Count - 1 do
      begin
        LSeries := FSeries[I];
        LValueField := LSeries.EncodeY;
        if LValueField = '' then LValueField := LSeries.EncodeValue;
        if LValueField = '' then LValueField := LSeries.EncodeSeries;
        if LValueField = '' then LValueField := LSeries.Name;
        if (LValueField = '') and (FDatasetOptions.SeriesLayoutBy = cslColumns)
          and (I + 1 < LDimensions.Count) then
          LValueField := LDimensions[I + 1];
        if LSeries.Name <> '' then
          ConfigureSeries(I, LSeries, LSeries.Name)
        else
          ConfigureSeries(I, LSeries, LValueField);
      end;
    end;

    LClone.First;
    LIndex := 0;
    while not LClone.Eof do
    begin
      for I := 0 to High(ASnapshot.Series) do
      begin
        LLabelField := '';
        LTooltipField := '';
        if FSeries.Count = 0 then
        begin
          if (FDatasetOptions.SeriesLayoutBy = cslColumns) and
            (LDimensions.Count >= 2) then
          begin
            LXField := LDimensions[0];
            LValueField := LDimensions[I + 1];
          end
          else
          begin
            if LDimensions.Count > 0 then LXField := LDimensions[0] else LXField := '';
            if LDimensions.Count > 1 then LValueField := LDimensions[1] else LValueField := LXField;
          end;
        end
        else
        begin
          LSeries := FSeries[I];
          LXField := LSeries.EncodeX;
          if (LXField = '') and (LDimensions.Count > 0) then
            LXField := LDimensions[0];
          LValueField := LSeries.EncodeY;
          if LValueField = '' then LValueField := LSeries.EncodeValue;
          if LValueField = '' then LValueField := LSeries.EncodeSeries;
          if LValueField = '' then LValueField := LSeries.Name;
          if (LValueField = '') and (FDatasetOptions.SeriesLayoutBy = cslColumns)
            and (I + 1 < LDimensions.Count) then
            LValueField := LDimensions[I + 1];
          LLabelField := LSeries.EncodeLabel;
          LTooltipField := LSeries.EncodeTooltip;
        end;
        AppendDataValue(I, FieldText(LDataSet, LXField, IntToStr(LIndex + 1)),
          LValueField, LLabelField, LTooltipField);
      end;
      Inc(LIndex);
      LClone.Next;
    end;
    ASnapshot.CategoryCount := LIndex;
    ASnapshot.HasData := LIndex > 0;
  finally
    LDimensions.Free;
    LClone.Free;
  end;
end;

procedure TDACChart.BuildGeometry(const ASnapshot: TDACChartSnapshot);
var
  LCanvas: ISkCanvas;
  LRecorder: ISkPictureRecorder;
begin
  ValidateSnapshot(ASnapshot);
  FHitAreas.Clear;
  FNativeStaticTextItems.Clear;
  FNativeTextQueue := FNativeStaticTextItems;
  LRecorder := TSkPictureRecorder.Create;
  try
    LCanvas := LRecorder.BeginRecording(Max(1, Width), Max(1, Height));
    DrawChart(LCanvas, TRectF.Create(0, 0, Max(1, Width), Max(1, Height)),
      ASnapshot);
    FPicture := LRecorder.FinishRecording;
  finally
    FNativeTextQueue := nil;
  end;
  FAnimationFrame := ASnapshot;
  FAnimationSurfaceReady := False;
  FHasRenderSnapshot := True;
end;

procedure TDACChart.ValidateSnapshot(const ASnapshot: TDACChartSnapshot);
var
  I: Integer;
  J: Integer;
  LBase: Integer;
  LPieCount: Integer;
  LCartesian: Boolean;
begin
  LBase := -1;
  LPieCount := 0;
  LCartesian := False;
  for I := 0 to High(ASnapshot.Series) do
    if ASnapshot.Series[I].Visible then
      if ASnapshot.Series[I].ChartType in [ctPie, ctDoughnut] then
        Inc(LPieCount)
      else
      begin
        LCartesian := True;
        if LBase < 0 then
          LBase := I
        else
        begin
          if Length(ASnapshot.Series[I].Values) <>
            Length(ASnapshot.Series[LBase].Values) then
            raise EDACChartDataError.Create(
              'Series cartesianas mistas exigem a mesma sequencia de categorias.');
          for J := 0 to High(ASnapshot.Series[I].Values) do
            if (ASnapshot.Series[I].Values[J].Category <>
              ASnapshot.Series[LBase].Values[J].Category) or
              not SameValue(ASnapshot.Series[I].Values[J].XValue,
                ASnapshot.Series[LBase].Values[J].XValue) then
              raise EDACChartDataError.Create(
                'Series cartesianas mistas exigem a mesma sequencia de categorias.');
        end;
      end;
  if (LPieCount > 0) and (LCartesian or (LPieCount <> 1)) then
    raise EDACChartDataError.Create(
      'Pie e doughnut exigem exatamente uma serie visivel e nao podem ser misturados.');
end;

procedure TDACChart.ChartChanged;
begin
  FLayoutDirty := True;
  FGeometryDirty := True;
  QueueRefresh(True);
end;

function TDACChart.ChartContentRect(const ADest: TRectF): TRectF;
var
  LInset: Single;
  LTitleSize: Single;
  LTitleWidth: Single;
begin
  LInset := Pixels(FChartGrid.Padding);
  Result := ADest;
  if FShowFrame then
    Result.Inflate(-Pixels(8), -Pixels(8));
  if FTitle.Visible and (FTitle.TextVisible or
    (FTitle.SubTextVisible and (FTitle.SubText <> ''))) then
  begin
    if FTitle.Position in [cpTop, cpBottom] then
    begin
      LTitleSize := Pixels(14);
      if FTitle.TextVisible then
        LTitleSize := LTitleSize + NativeTextHeight(TextPixels(FTitle.Font.Size));
      if FTitle.SubTextVisible and (FTitle.SubText <> '') then
        LTitleSize := LTitleSize + Pixels(5) +
          NativeTextHeight(TextPixels(FTitle.SubFont.Size));
      LTitleSize := Max(Pixels(52), LTitleSize);
    end
    else
    begin
      LTitleWidth := 0;
      if FTitle.TextVisible then
        LTitleWidth := NativeTextWidth(FTitle.Text,
          DACChartFontName(FTitle.Font), TextPixels(FTitle.Font.Size),
          fsBold in FTitle.Font.Style);
      if FTitle.SubTextVisible and (FTitle.SubText <> '') then
        LTitleWidth := Max(LTitleWidth, NativeTextWidth(FTitle.SubText,
          DACChartFontName(FTitle.SubFont), TextPixels(FTitle.SubFont.Size),
          fsBold in FTitle.SubFont.Style));
      LTitleSize := Max(Pixels(150), Min(Pixels(220), LTitleWidth + Pixels(24)));
    end;
    case FTitle.Position of
      cpTop: Result.Top := Result.Top + LTitleSize;
      cpRight: Result.Right := Result.Right - LTitleSize;
      cpBottom: Result.Bottom := Result.Bottom - LTitleSize;
      cpLeft: Result.Left := Result.Left + LTitleSize;
    end;
  end;
  Result.Inflate(-LInset, -LInset);
  Result.Left := Result.Left + Pixels(FChartGrid.Margins.Left);
  Result.Top := Result.Top + Pixels(FChartGrid.Margins.Top);
  Result.Right := Result.Right - Pixels(FChartGrid.Margins.Right);
  Result.Bottom := Result.Bottom - Pixels(FChartGrid.Margins.Bottom);
  if Result.Right <= Result.Left then
    Result.Right := Result.Left + 1;
  if Result.Bottom <= Result.Top then
    Result.Bottom := Result.Top + 1;
end;

procedure TDACChart.LegendPanelSize(const AHostRect: TRectF;
  const ASnapshot: TDACChartSnapshot; out AWidth, AHeight: Single);
var
  I: Integer;
  J: Integer;
  LAvailableWidth: Single;
  LColumns: Integer;
  LFamily: string;
  LItemCount: Integer;
  LItemHeight: Single;
  LItemWidth: Single;
  LMaxPanelWidth: Single;
  LMaxItemWidth: Single;
  LNaturalWidth: Single;
  LRows: Integer;
  LRowsPerColumn: Integer;
  function SeriesHasRenderableValue(const ASeriesIndex: Integer): Boolean;
  var
    LValueIndex: Integer;
    LPie: Boolean;
  begin
    Result := False;
    if not ASnapshot.Series[ASeriesIndex].Visible then
      Exit;
    LPie := ASnapshot.Series[ASeriesIndex].ChartType in [ctPie, ctDoughnut];
    for LValueIndex := 0 to High(ASnapshot.Series[ASeriesIndex].Values) do
      if not ASnapshot.Series[ASeriesIndex].Values[LValueIndex].IsNull and
        (not LPie or (ASnapshot.Series[ASeriesIndex].Values[LValueIndex].Value > 0)) then
        Exit(True);
  end;
  procedure AccountItem(const AName: string);
  begin
    LItemWidth := 0;
    if FLegend.MarkersVisible then
      LItemWidth := Pixels(FLegend.MarkerSize) + Pixels(6);
    if FLegend.LabelsVisible then
      LItemWidth := LItemWidth + NativeTextWidth(AName, LFamily,
        TextPixels(FLegend.Font.Size), fsBold in FLegend.Font.Style);
    LItemWidth := Max(LItemWidth, Pixels(FLegend.MarkerSize));
    LMaxItemWidth := Max(LMaxItemWidth, LItemWidth);
    if LItemCount > 0 then
      LNaturalWidth := LNaturalWidth + Pixels(FLegend.ItemSpacing);
    LNaturalWidth := LNaturalWidth + LItemWidth;
    Inc(LItemCount);
  end;
begin
  AWidth := 0;
  AHeight := 0;
  if not FLegend.Visible or not ASnapshot.HasData or
    (Length(ASnapshot.Series) = 0) then
    Exit;

  LFamily := DACChartFontName(FLegend.Font);
  LItemCount := 0;
  LMaxItemWidth := 0;
  LNaturalWidth := 0;
  LItemHeight := Max(TextPixels(FLegend.Font.Size) + Pixels(6),
    Pixels(FLegend.MarkerSize) + Pixels(4));
  for I := 0 to High(ASnapshot.Series) do
    if SeriesHasRenderableValue(I) then
      if ASnapshot.Series[I].ChartType in [ctPie, ctDoughnut] then
      begin
        { Pie and doughnut legends describe the visible slices, not only the
          series container. }
        for J := 0 to High(ASnapshot.Series[I].Values) do
          if not ASnapshot.Series[I].Values[J].IsNull and
            (ASnapshot.Series[I].Values[J].Value > 0) then
            AccountItem(ASnapshot.Series[I].Values[J].Category);
        Break;
      end
      else
        AccountItem(ASnapshot.Series[I].Name);
  if LItemCount = 0 then
    Exit;

  if FLegend.Position in [cpLeft, cpRight] then
  begin
    { Side legends reserve their own panel.  Wrap a long vertical list into
      columns rather than painting beyond the card, but always leave a real
      plot region for the chart itself. }
    LRowsPerColumn := Max(1, Floor((AHostRect.Height - (Pixels(FLegend.Padding) * 2) +
      Pixels(FLegend.ItemSpacing)) / (LItemHeight + Pixels(FLegend.ItemSpacing))));
    LColumns := Max(1, Ceil(LItemCount / LRowsPerColumn));
    LMaxItemWidth := Min(Pixels(150), Max(Pixels(104), LMaxItemWidth));
    LMaxPanelWidth := Max(Pixels(128), AHostRect.Width - Pixels(240));
    AWidth := Min(LMaxPanelWidth,
      (LColumns * LMaxItemWidth) + ((LColumns - 1) * Pixels(FLegend.ItemSpacing)) +
      (Pixels(FLegend.Padding) * 2));
    AWidth := Min(AHostRect.Width - Pixels(8), Max(Pixels(128), AWidth));
    AHeight := AHostRect.Height;
    Exit;
  end;

  AWidth := AHostRect.Width;
  LAvailableWidth := Max(Pixels(1), AWidth - (Pixels(FLegend.Padding) * 2));
  LRows := Max(1, Ceil(LNaturalWidth / LAvailableWidth));
  AHeight := (LRows * LItemHeight) +
    (Max(0, LRows - 1) * Pixels(FLegend.ItemSpacing)) +
    (Pixels(FLegend.Padding) * 2);
  AHeight := Min(AHeight, AHostRect.Height - Pixels(8));
end;

function TDACChart.LegendRect(const ADest: TRectF;
  const ASnapshot: TDACChartSnapshot): TRectF;
var
  LHeight: Single;
  LHostRect: TRectF;
  LWidth: Single;
begin
  LHostRect := ChartContentRect(ADest);
  LegendPanelSize(LHostRect, ASnapshot, LWidth, LHeight);
  Result := TRectF.Create(0, 0, 0, 0);
  if (LWidth <= 0) or (LHeight <= 0) then
    Exit;
  case FLegend.Position of
    cpLeft:
      Result := TRectF.Create(LHostRect.Left, LHostRect.Top,
        LHostRect.Left + LWidth, LHostRect.Bottom);
    cpRight:
      Result := TRectF.Create(LHostRect.Right - LWidth, LHostRect.Top,
        LHostRect.Right, LHostRect.Bottom);
    cpTop:
      Result := TRectF.Create(LHostRect.Left, LHostRect.Top,
        LHostRect.Right, LHostRect.Top + LHeight);
  else
    Result := TRectF.Create(LHostRect.Left, LHostRect.Bottom - LHeight,
      LHostRect.Right, LHostRect.Bottom);
  end;
end;

function TDACChart.NativeTextHeight(const ASize: Single): Single;
begin
  { ASize is already adjusted to the chart DPI.  Keep this conversion equal
    to CreateFont() in DrawNativeTextItems so layout and final ClearType text
    use the same vertical metrics. }
  Result := Max(1, MulDiv(Round(ASize), 96, 72));
end;

function TDACChart.NativeTextWidth(const AText, AFamily: string;
  const ASize: Single; const ABold: Boolean): Single;
var
  LDC: HDC;
  LFont: HFONT;
  LFamily: string;
  LHeight: Integer;
  LKey: string;
  LOldFont: HGDIOBJ;
  LSize: TSize;
  LWeight: Integer;
begin
  if AText = '' then
    Exit(0);
  LHeight := Round(NativeTextHeight(ASize));
  if ABold then
    LWeight := FW_BOLD
  else
    LWeight := FW_NORMAL;
  LFamily := AFamily;
  if LFamily = '' then
    LFamily := DACChartDefaultFontFamily;
  LKey := LFamily + #1 + IntToStr(Round(ASize * 100)) + #1 +
    IntToStr(Ord(ABold)) + #1 + AText;
  if (FNativeTextWidths <> nil) and FNativeTextWidths.TryGetValue(LKey, Result) then
    Exit;
  LDC := GetDC(0);
  if LDC = 0 then
    Exit(FRenderer.MeasureText(AText, AFamily, ASize, ABold));
  LFont := CreateFont(-LHeight, 0, 0, 0, LWeight, 0, 0, 0,
    DEFAULT_CHARSET, OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS,
    CLEARTYPE_QUALITY, DEFAULT_PITCH or FF_DONTCARE,
    PChar(LFamily));
  if LFont = 0 then
  begin
    ReleaseDC(0, LDC);
    Exit(FRenderer.MeasureText(AText, AFamily, ASize, ABold));
  end;
  LOldFont := SelectObject(LDC, LFont);
  try
    if GetTextExtentPoint32(LDC, PChar(AText), Length(AText), LSize) then
      Result := LSize.cx
    else
      Result := FRenderer.MeasureText(AText, AFamily, ASize, ABold);
  finally
    SelectObject(LDC, LOldFont);
    DeleteObject(LFont);
    ReleaseDC(0, LDC);
  end;
  if FNativeTextWidths <> nil then
  begin
    if FNativeTextWidths.Count >= 2048 then
      FNativeTextWidths.Clear;
    FNativeTextWidths.AddOrSetValue(LKey, Result);
  end;
end;

function TDACChart.ChartRect(const ADest: TRectF;
  const ASnapshot: TDACChartSnapshot): TRectF;
var
  LBottomReserve: Single;
  LLegendRect: TRectF;
  LLeftReserve: Single;
begin
  Result := ChartContentRect(ADest);
  LLegendRect := LegendRect(ADest, ASnapshot);
  if (LLegendRect.Right > LLegendRect.Left) and
    (LLegendRect.Bottom > LLegendRect.Top) then
    case FLegend.Position of
      cpTop: Result.Top := LLegendRect.Bottom + Pixels(8);
      cpRight: Result.Right := LLegendRect.Left - Pixels(8);
      cpBottom: Result.Bottom := LLegendRect.Top - Pixels(8);
      cpLeft: Result.Left := LLegendRect.Right + Pixels(8);
    end;
  if FXAxis.Visible and (FXAxis.LabelsVisible or FXAxis.TitleVisible or
    FXAxis.TickMarksVisible) then
  begin
    LBottomReserve := Pixels(8);
    if FXAxis.TickMarksVisible then
      LBottomReserve := LBottomReserve + Pixels(4);
    if FXAxis.LabelsVisible then
      LBottomReserve := LBottomReserve +
        NativeTextHeight(TextPixels(FXAxis.LabelFont.Size)) + Pixels(7);
    if FXAxis.TitleVisible and (FXAxis.Title <> '') then
      LBottomReserve := LBottomReserve +
        NativeTextHeight(TextPixels(FXAxis.TitleFont.Size)) + Pixels(7);
    Result.Bottom := Result.Bottom - LBottomReserve;
  end;
  if FYAxis.Visible and (FYAxis.LabelsVisible or FYAxis.TitleVisible or
    FYAxis.TickMarksVisible) then
  begin
    LLeftReserve := Pixels(8);
    if FYAxis.TickMarksVisible then
      LLeftReserve := LLeftReserve + Pixels(4);
    if FYAxis.LabelsVisible then
      LLeftReserve := LLeftReserve + Max(Pixels(48), NativeTextWidth('-000,000.00',
        DACChartFontName(FYAxis.LabelFont), TextPixels(FYAxis.LabelFont.Size),
        fsBold in FYAxis.LabelFont.Style));
    Result.Left := Result.Left + LLeftReserve;
  end;
  if Result.Right <= Result.Left then
    Result.Right := Result.Left + 1;
  if Result.Bottom <= Result.Top then
    Result.Bottom := Result.Top + 1;
end;

procedure TDACChart.ClearSnapshot(var ASnapshot: TDACChartSnapshot);
begin
  SetLength(ASnapshot.Series, 0);
  ASnapshot.CategoryCount := 0;
  ASnapshot.HasData := False;
end;

procedure TDACChart.CopySnapshot(const ASource: TDACChartSnapshot;
  out ATarget: TDACChartSnapshot);
var
  I: Integer;
  J: Integer;
begin
  ClearSnapshot(ATarget);
  ATarget.CategoryCount := ASource.CategoryCount;
  ATarget.HasData := ASource.HasData;
  SetLength(ATarget.Series, Length(ASource.Series));
  for I := 0 to High(ASource.Series) do
  begin
    ATarget.Series[I].Name := ASource.Series[I].Name;
    ATarget.Series[I].ChartType := ASource.Series[I].ChartType;
    ATarget.Series[I].FillMode := ASource.Series[I].FillMode;
    ATarget.Series[I].Color := ASource.Series[I].Color;
    ATarget.Series[I].GradientStartColor := ASource.Series[I].GradientStartColor;
    ATarget.Series[I].GradientEndColor := ASource.Series[I].GradientEndColor;
    ATarget.Series[I].GradientAngle := ASource.Series[I].GradientAngle;
    ATarget.Series[I].Visible := ASource.Series[I].Visible;
    SetLength(ATarget.Series[I].Values, Length(ASource.Series[I].Values));
    for J := 0 to High(ASource.Series[I].Values) do
      ATarget.Series[I].Values[J] := ASource.Series[I].Values[J];
  end;
end;

procedure TDACChart.BuildZeroSnapshot(const ATarget: TDACChartSnapshot;
  out AResult: TDACChartSnapshot);
var
  I: Integer;
  J: Integer;
begin
  CopySnapshot(ATarget, AResult);
  for I := 0 to High(AResult.Series) do
    for J := 0 to High(AResult.Series[I].Values) do
      if not AResult.Series[I].Values[J].IsNull then
        AResult.Series[I].Values[J].Value := 0;
end;

function TDACChart.EasedProgress(const AProgress: Single): Single;
var
  LProgress: Single;
begin
  LProgress := EnsureRange(AProgress, 0, 1);
  case FAnimation.Easing of
    caeCubicIn:
      Result := LProgress * LProgress * LProgress;
    caeCubicOut:
      Result := 1 - Power(1 - LProgress, 3);
    caeCubicInOut:
      if LProgress < 0.5 then
        Result := 4 * LProgress * LProgress * LProgress
      else
        Result := 1 - Power(-2 * LProgress + 2, 3) / 2;
  else
    Result := LProgress;
  end;
end;

function TDACChart.FindSourceValue(const ASource: TDACChartSnapshot;
  const ATargetSeries: TDACChartSeriesSnapshot; const ATargetSeriesIndex,
  ATargetValueIndex: Integer; out AValue: TDACChartValue): Boolean;
var
  I: Integer;
  J: Integer;
  LSeriesIndex: Integer;
  LTarget: TDACChartValue;
begin
  Result := False;
  if (ATargetValueIndex < 0) or
    (ATargetValueIndex >= Length(ATargetSeries.Values)) then
    Exit;
  LSeriesIndex := -1;
  if ATargetSeries.Name <> '' then
    for I := 0 to High(ASource.Series) do
      if SameText(ASource.Series[I].Name, ATargetSeries.Name) then
      begin
        LSeriesIndex := I;
        Break;
      end;
  if (LSeriesIndex < 0) and (ATargetSeriesIndex >= 0) and
    (ATargetSeriesIndex < Length(ASource.Series)) then
    LSeriesIndex := ATargetSeriesIndex;
  if LSeriesIndex < 0 then
    Exit;
  LTarget := ATargetSeries.Values[ATargetValueIndex];
  if LTarget.Category <> '' then
    for J := 0 to High(ASource.Series[LSeriesIndex].Values) do
      if ASource.Series[LSeriesIndex].Values[J].Category = LTarget.Category then
      begin
        AValue := ASource.Series[LSeriesIndex].Values[J];
        Exit(True);
      end;
  for J := 0 to High(ASource.Series[LSeriesIndex].Values) do
    if SameValue(ASource.Series[LSeriesIndex].Values[J].XValue, LTarget.XValue) then
    begin
      AValue := ASource.Series[LSeriesIndex].Values[J];
      Exit(True);
    end;
  if ATargetValueIndex < Length(ASource.Series[LSeriesIndex].Values) then
  begin
    AValue := ASource.Series[LSeriesIndex].Values[ATargetValueIndex];
    Result := True;
  end;
end;

procedure TDACChart.InterpolateSnapshot(const ASource, ATarget: TDACChartSnapshot;
  const AProgress: Single; out AResult: TDACChartSnapshot);
var
  I: Integer;
  J: Integer;
  LSource: TDACChartValue;
  LSourceSeries: Integer;
  LTargetValue: TDACChartValue;
begin
  CopySnapshot(ATarget, AResult);
  for I := 0 to High(AResult.Series) do
  begin
    LSourceSeries := -1;
    if AResult.Series[I].Name <> '' then
      for J := 0 to High(ASource.Series) do
        if SameText(ASource.Series[J].Name, AResult.Series[I].Name) then
        begin
          LSourceSeries := J;
          Break;
        end;
    if (LSourceSeries < 0) and (I < Length(ASource.Series)) then
      LSourceSeries := I;
    if LSourceSeries >= 0 then
    begin
      AResult.Series[I].Color := DACChartInterpolateColor(
        ASource.Series[LSourceSeries].Color, ATarget.Series[I].Color, AProgress);
      AResult.Series[I].GradientStartColor := DACChartInterpolateColor(
        ASource.Series[LSourceSeries].GradientStartColor,
        ATarget.Series[I].GradientStartColor, AProgress);
      AResult.Series[I].GradientEndColor := DACChartInterpolateColor(
        ASource.Series[LSourceSeries].GradientEndColor,
        ATarget.Series[I].GradientEndColor, AProgress);
    end;
    for J := 0 to High(AResult.Series[I].Values) do
    begin
      LTargetValue := ATarget.Series[I].Values[J];
      if not FindSourceValue(ASource, ATarget.Series[I], I, J, LSource) then
      begin
        LSource := LTargetValue;
        LSource.Value := 0;
        LSource.IsNull := False;
      end;
      AResult.Series[I].Values[J].Value := LSource.Value +
        ((LTargetValue.Value - LSource.Value) * AProgress);
      { Null keeps a true gap at the end of the transition. A datum entering
        the target grows from its collapsed value without querying data. }
      AResult.Series[I].Values[J].IsNull := LTargetValue.IsNull and
        (AProgress >= 1);
    end;
  end;
end;

procedure TDACChart.StartFrameTimer;
begin
  if HandleAllocated then
    SetTimer(Handle, DACChartAnimationTimerId, DACChartAnimationFrameInterval, nil);
end;

procedure TDACChart.StopFrameTimer;
begin
  if HandleAllocated then
    KillTimer(Handle, DACChartAnimationTimerId);
end;

procedure TDACChart.StartAnimation;
begin
  if (FAnimation = nil) or not FAnimation.Enabled or not HandleAllocated then
  begin
    BuildGeometry(FSnapshot);
    Exit;
  end;
  if FHasRenderSnapshot then
    CopySnapshot(FAnimationFrame, FAnimationSource)
  else
    BuildZeroSnapshot(FSnapshot, FAnimationSource);
  FAnimationStartTick := GetTickCount;
  FAnimation.SetRunning(True);
  if Assigned(FOnAnimationStart) then
    FOnAnimationStart(Self);
  UpdateAnimationFrame;
  StartFrameTimer;
end;

procedure TDACChart.StopAnimation(const ANotify: Boolean);
var
  LWasRunning: Boolean;
begin
  LWasRunning := (FAnimation <> nil) and FAnimation.Running;
  if FAnimation <> nil then
    FAnimation.SetRunning(False);
  if not FHoverAnimating then
    StopFrameTimer;
  if LWasRunning and ANotify and Assigned(FOnAnimationFinish) then
    FOnAnimationFinish(Self);
end;

procedure TDACChart.UpdateAnimationFrame;
var
  LElapsed: Cardinal;
  LProgress: Single;
begin
  if (FAnimation = nil) or not FAnimation.Running then
    Exit;
  LElapsed := GetTickCount - FAnimationStartTick;
  if LElapsed < FAnimation.Delay then
  begin
    FAnimationFrame := FAnimationSource;
    RenderAnimationFrame;
    Exit;
  end;
  if FAnimation.Duration = 0 then
    LProgress := 1
  else
    LProgress := EnsureRange((LElapsed - FAnimation.Delay) / FAnimation.Duration,
      0, 1);
  InterpolateSnapshot(FAnimationSource, FSnapshot, EasedProgress(LProgress),
    FAnimationFrame);
  RenderAnimationFrame;
  if LProgress >= 1 then
  begin
    StopAnimation(True);
    BuildGeometry(FSnapshot);
  end;
end;

procedure TDACChart.UpdateHoverFrame;
var
  LElapsed: Cardinal;
begin
  if not FHoverAnimating then
    Exit;
  if (FAnimation = nil) or (FAnimation.HoverDuration = 0) then
  begin
    FHoverOpacity := 1;
    FHoverAnimating := False;
    Exit;
  end;
  LElapsed := GetTickCount - FHoverStartTick;
  FHoverOpacity := EasedProgress(EnsureRange(LElapsed / FAnimation.HoverDuration,
    0, 1));
  if LElapsed >= FAnimation.HoverDuration then
  begin
    FHoverOpacity := 1;
    FHoverAnimating := False;
  end;
end;

procedure TDACChart.Click;
begin
  inherited;
  if not FClickArmed then
    Exit;
  FClickArmed := False;
  if FHoverActive and (FHover.Shape = chsLegend) then
  begin
    { A legenda cartesiana representa uma serie. Em pie/doughnut cada item
      representa uma fatia, portanto nao pode ocultar a unica serie inteira. }
    if FLegend.AllowToggleSeries and (FHover.PointIndex < 0) and
      (FHover.SeriesIndex >= 0) and
      (FHover.SeriesIndex < FSeries.Count) then
      FSeries[FHover.SeriesIndex].Visible := not FSeries[FHover.SeriesIndex].Visible;
    Exit;
  end;
  if FHoverActive and Assigned(FOnPointClick) then
    FOnPointClick(Self, FHover.SeriesIndex, FHover.PointIndex, FHover.Category,
      FHover.Value);
end;

procedure TDACChart.KeyDown(var Key: Word; Shift: TShiftState);
var
  I: Integer;
  LCount: Integer;
  LStep: Integer;
begin
  inherited;
  if not Enabled or not TabStop then
    Exit;
  if Key in [VK_LEFT, VK_UP, VK_RIGHT, VK_DOWN, VK_HOME, VK_END] then
  begin
    LCount := 0;
    for I := 0 to FHitAreas.Count - 1 do
      if FHitAreas[I].Shape <> chsLegend then
        Inc(LCount);
    if LCount = 0 then
      Exit;
    if Key = VK_HOME then
      FKeyboardHitIndex := 0
    else if Key = VK_END then
      FKeyboardHitIndex := LCount - 1
    else
    begin
      LStep := Ord(Key in [VK_RIGHT, VK_DOWN]) * 2 - 1;
      FKeyboardHitIndex := (FKeyboardHitIndex + LStep + LCount) mod LCount;
    end;
    LCount := -1;
    for I := 0 to FHitAreas.Count - 1 do
      if FHitAreas[I].Shape <> chsLegend then
      begin
        Inc(LCount);
        if LCount = FKeyboardHitIndex then
        begin
          FHover := FHitAreas[I];
          FHoverActive := True;
          FHoverTooltip := TooltipForHit(FHover);
          FHoverOpacity := 1;
          Break;
        end;
      end;
    Key := 0;
    Redraw;
    Exit;
  end;
  if (Key in [VK_RETURN, VK_SPACE]) and FHoverActive and
    (FHover.Shape <> chsLegend) then
  begin
    if Assigned(FOnPointClick) then
      FOnPointClick(Self, FHover.SeriesIndex, FHover.PointIndex,
        FHover.Category, FHover.Value);
    Key := 0;
  end
  else if Key = VK_ESCAPE then
  begin
    FHoverActive := False;
    FHoverTooltip := '';
    Key := 0;
    Redraw;
  end;
end;

procedure TDACChart.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  LHit: TDACChartHitArea;
begin
  inherited;
  FPressedActive := False;
  FClickArmed := False;
  if Enabled and (Button = mbLeft) and TryHitTest(PointF(X, Y), LHit) then
  begin
    FPressedHit := LHit;
    FPressedActive := True;
  end;
end;

procedure TDACChart.CreateWnd;
begin
  inherited;
  RefreshDpi;
  ApplyAppearance;
  QueueRefresh(True);
end;

procedure TDACChart.DestroyWnd;
begin
  StopAnimation(False);
  FAnimationSurfaceReady := False;
  FHoverAnimating := False;
  StopFrameTimer;
  ApplyDpi(96);
  inherited;
end;

procedure TDACChart.DrawAxes(const ACanvas: ISkCanvas; const ARect: TRectF;
  const ASnapshot: TDACChartSnapshot; const AMin, AMax: Double);
var
  I: Integer;
  LCaption: string;
  LCategoryIndex: Integer;
  LCategoryLabelWidth: Single;
  LLabelWidth: Single;
  LLinePaint: ISkPaint;
  LX: Single;
  LPalette: TDACChartPalette;
  LTickCount: Integer;
  LValue: Double;
  LY: Single;
begin
  LPalette := ResolvedChartPalette;
  LLinePaint := TSkPaint.Create(TSkPaintStyle.Stroke);
  LLinePaint.AntiAlias := True;
  LLinePaint.StrokeWidth := Pixels(1);
  LLinePaint.Color := DACChartColorOrDefault(FYAxis.LineColor,
    LPalette.LinhaEixo);
  if FYAxis.Visible then
  begin
    if FYAxis.LineVisible then
      ACanvas.DrawLine(Round(ARect.Left) + 0.5, Round(ARect.Top),
        Round(ARect.Left) + 0.5, Round(ARect.Bottom), LLinePaint);
    LTickCount := Max(1, FYAxis.Ticks);
    for I := 0 to LTickCount do
    begin
      LValue := AMax - ((AMax - AMin) / LTickCount * I);
      LY := Round(ARect.Top + (ARect.Height / LTickCount * I)) + 0.5;
      if FYAxis.TickMarksVisible then
        ACanvas.DrawLine(Round(ARect.Left - Pixels(3)), LY,
          Round(ARect.Left) + 0.5, LY, LLinePaint);
      if FYAxis.LabelsVisible then
      begin
        if FYAxis.LabelFormat <> '' then
          LCaption := FormatFloat(FYAxis.LabelFormat, LValue)
        else
          LCaption := FormatFloat('0.##', LValue);
        LLabelWidth := NativeTextWidth(LCaption,
          DACChartFontName(FYAxis.LabelFont), TextPixels(FYAxis.LabelFont.Size),
          fsBold in FYAxis.LabelFont.Style);
        QueueNativeText(LCaption, DACChartFontName(FYAxis.LabelFont),
          ARect.Left - Pixels(6) - LLabelWidth, LY + Pixels(4),
          TextPixels(FYAxis.LabelFont.Size),
          DACChartColorOrDefault(FYAxis.LabelColor, LPalette.TextoPrincipal),
          fsBold in FYAxis.LabelFont.Style, LLabelWidth + Pixels(2));
      end;
    end;
  end;
  if FXAxis.Visible then
  begin
    LLinePaint.Color := DACChartColorOrDefault(FXAxis.LineColor,
      LPalette.LinhaEixo);
    if FXAxis.LineVisible then
      ACanvas.DrawLine(Round(ARect.Left), Round(ARect.Bottom) + 0.5,
        Round(ARect.Right), Round(ARect.Bottom) + 0.5, LLinePaint);
    if (Length(ASnapshot.Series) > 0) and
      (Length(ASnapshot.Series[0].Values) > 0) then
    begin
      LCategoryLabelWidth := Max(Pixels(28), ARect.Width /
        Max(1, Min(4, High(ASnapshot.Series[0].Values))) - Pixels(6));
      for I := 0 to Min(4, High(ASnapshot.Series[0].Values)) do
      begin
        if High(ASnapshot.Series[0].Values) = 0 then
          LCategoryIndex := 0
        else
          LCategoryIndex := Round(I * High(ASnapshot.Series[0].Values) / 4);
        case FXAxis.AxisType of
          catTime:
            if FXAxis.LabelFormat <> '' then
              LCaption := FormatDateTime(FXAxis.LabelFormat,
                ASnapshot.Series[0].Values[LCategoryIndex].XValue)
            else
              LCaption := FormatDateTime('dd/mm',
                ASnapshot.Series[0].Values[LCategoryIndex].XValue);
          catValue:
            if FXAxis.LabelFormat <> '' then
              LCaption := FormatFloat(FXAxis.LabelFormat,
                ASnapshot.Series[0].Values[LCategoryIndex].XValue)
            else
              LCaption := FormatFloat('0.##',
                ASnapshot.Series[0].Values[LCategoryIndex].XValue);
        else
          LCaption := ASnapshot.Series[0].Values[LCategoryIndex].Category;
        end;
        LX := Round(ARect.Left + (ARect.Width * LCategoryIndex /
          Max(1, High(ASnapshot.Series[0].Values)))) + 0.5;
        if FXAxis.TickMarksVisible then
          ACanvas.DrawLine(LX, Round(ARect.Bottom), LX,
            Round(ARect.Bottom + Pixels(3)), LLinePaint);
        if FXAxis.LabelsVisible then
          QueueNativeText(LCaption, DACChartFontName(FXAxis.LabelFont),
            LX - (LCategoryLabelWidth / 2), ARect.Bottom + Pixels(18),
            TextPixels(FXAxis.LabelFont.Size),
            DACChartColorOrDefault(FXAxis.LabelColor, LPalette.TextoPrincipal),
            fsBold in FXAxis.LabelFont.Style, LCategoryLabelWidth);
      end;
    end;
    if FXAxis.TitleVisible and (FXAxis.Title <> '') then
      QueueNativeTextCentered(FXAxis.Title, DACChartFontName(FXAxis.TitleFont),
        TRectF.Create(ARect.Left, ARect.Bottom + Pixels(18), ARect.Right,
          ARect.Bottom + Pixels(34)), TextPixels(FXAxis.TitleFont.Size),
        DACChartColorOrDefault(FXAxis.TitleColor, LPalette.TextoSecundario),
        fsBold in FXAxis.TitleFont.Style);
  end;
  if FYAxis.Visible and FYAxis.TitleVisible and (FYAxis.Title <> '') then
    QueueNativeText(FYAxis.Title, DACChartFontName(FYAxis.TitleFont),
      ARect.Left, ARect.Top - Pixels(5), TextPixels(FYAxis.TitleFont.Size),
      DACChartColorOrDefault(FYAxis.TitleColor, LPalette.TextoSecundario),
      fsBold in FYAxis.TitleFont.Style, ARect.Width);
end;

procedure TDACChart.DrawBarSeries(const ACanvas: ISkCanvas; const ARect: TRectF;
  const ASnapshot: TDACChartSnapshot; const ASeriesIndex: Integer;
  const AMin, AMax: Double);
var
  I: Integer;
  LBarSeriesOrdinal: Integer;
  LBar: TRectF;
  LBarGroupWidth: Single;
  LBarWidth: Single;
  LCap: TRectF;
  LPaint: ISkPaint;
  LRadius: Single;
  LHit: TDACChartHitArea;
  LSeries: TDACChartSeriesSnapshot;
  LSeriesCount: Integer;
  LTop: Single;
  LZero: Single;
begin
  LSeries := ASnapshot.Series[ASeriesIndex];
  if not LSeries.Visible or (Length(LSeries.Values) = 0) then
    Exit;
  LSeriesCount := EffectiveSeriesCount(ASnapshot);
  LBarGroupWidth := ARect.Width / Max(1, ASnapshot.CategoryCount);
  LBarWidth := Max(Pixels(6), (LBarGroupWidth * 0.74) / Max(1, LSeriesCount));
  LZero := ARect.Bottom - (DACChartRangeValue(0, AMin, AMax) * ARect.Height);
  LBarSeriesOrdinal := 0;
  for I := 0 to ASeriesIndex - 1 do
    if ASnapshot.Series[I].Visible and
      (ASnapshot.Series[I].ChartType = ctBar) then
      Inc(LBarSeriesOrdinal);
  LPaint := TSkPaint.Create(TSkPaintStyle.Fill);
  LPaint.AntiAlias := True;
  for I := 0 to High(LSeries.Values) do
  begin
    if LSeries.Values[I].IsNull then
      Continue;
    LTop := ARect.Bottom -
      (DACChartRangeValue(LSeries.Values[I].Value, AMin, AMax) * ARect.Height);
    LBar := TRectF.Create(
      ARect.Left + (I * LBarGroupWidth) + ((LBarGroupWidth - (LBarWidth * LSeriesCount)) / 2) +
        (LBarSeriesOrdinal * LBarWidth),
      Min(LTop, LZero),
      ARect.Left + (I * LBarGroupWidth) + ((LBarGroupWidth - (LBarWidth * LSeriesCount)) / 2) +
        (LBarSeriesOrdinal * LBarWidth) + (LBarWidth * 0.82),
      Max(LTop, LZero));
    LBar := FRenderer.SnapRect(LBar);
    if LBar.Height < Pixels(2) then
      LBar.Top := LBar.Bottom - Pixels(2);
    ApplyFillPaint(LPaint, LSeries, ASeriesIndex, LBar);
    { A base da barra deve permanecer reta. O acabamento arredondado fica
      somente na extremidade que representa o valor: topo para positivos e
      base para negativos. }
    LRadius := Min(Pixels(5), LBar.Height / 2);
    if LRadius >= 1 then
    begin
      if LSeries.Values[I].Value >= 0 then
      begin
        ACanvas.DrawRect(TRectF.Create(LBar.Left, LBar.Top + LRadius,
          LBar.Right, LBar.Bottom), LPaint);
        LCap := TRectF.Create(LBar.Left, LBar.Top, LBar.Right,
          Min(LBar.Bottom, LBar.Top + (LRadius * 2)));
      end
      else
      begin
        ACanvas.DrawRect(TRectF.Create(LBar.Left, LBar.Top, LBar.Right,
          LBar.Bottom - LRadius), LPaint);
        LCap := TRectF.Create(LBar.Left,
          Max(LBar.Top, LBar.Bottom - (LRadius * 2)), LBar.Right,
          LBar.Bottom);
      end;
      ACanvas.DrawRoundRect(LCap, LRadius, LRadius, LPaint);
    end;
    if LRadius < 1 then
      ACanvas.DrawRect(LBar, LPaint);
    LHit.Rect := LBar;
    LHit.Shape := chsRectangle;
    LHit.SeriesIndex := ASeriesIndex;
    LHit.PointIndex := I;
    LHit.Category := LSeries.Values[I].Category;
    LHit.Value := LSeries.Values[I].Value;
    FHitAreas.Add(LHit);
  end;
end;

procedure TDACChart.DrawCartesianSeries(const ACanvas: ISkCanvas;
  const ARect: TRectF; const ASnapshot: TDACChartSnapshot; const AMin,
  AMax: Double);
var
  I: Integer;
begin
  DrawGrid(ACanvas, ARect);
  DrawAxes(ACanvas, ARect, ASnapshot, AMin, AMax);
  for I := 0 to High(ASnapshot.Series) do
    if ASnapshot.Series[I].Visible and (ASnapshot.Series[I].ChartType = ctArea) then
      DrawLineOrAreaSeries(ACanvas, ARect, ASnapshot.Series[I], I, AMin, AMax, True);
  for I := 0 to High(ASnapshot.Series) do
    if ASnapshot.Series[I].Visible and (ASnapshot.Series[I].ChartType = ctBar) then
      DrawBarSeries(ACanvas, ARect, ASnapshot, I, AMin, AMax);
  for I := 0 to High(ASnapshot.Series) do
    if ASnapshot.Series[I].Visible and (ASnapshot.Series[I].ChartType = ctLine) then
      DrawLineOrAreaSeries(ACanvas, ARect, ASnapshot.Series[I], I, AMin, AMax, False);
end;

procedure TDACChart.DrawChart(const ACanvas: ISkCanvas; const ADest: TRectF;
  const ASnapshot: TDACChartSnapshot);
var
  I: Integer;
  J: Integer;
  LChartRect: TRectF;
  LHasValue: Boolean;
  LIncludeZero: Boolean;
  LMargin: Double;
  LMax: Double;
  LCartesian: Boolean;
  LMin: Double;
  LPie: Boolean;
  LPieCount: Integer;
  LPieIndex: Integer;
begin
  FHitAreas.Clear;
  ACanvas.Clear(ParentSurfaceColor);
  if FShowFrame then
    DrawFrame(ACanvas, ADest)
  else
    FRenderer.FillRoundRect(ACanvas, ADest, FBackgroundColor, 0);
  DrawTitle(ACanvas, ADest);

  if not ASnapshot.HasData then
  begin
    DrawEmpty(ACanvas, ChartRect(ADest, ASnapshot), 'Sem dados para exibir');
    Exit;
  end;

  LChartRect := ChartRect(ADest, ASnapshot);
  LPie := False;
  LCartesian := False;
  LPieCount := 0;
  LPieIndex := -1;
  for I := 0 to High(ASnapshot.Series) do
    if ASnapshot.Series[I].Visible then
      if ASnapshot.Series[I].ChartType in [ctPie, ctDoughnut] then
      begin
        LPie := True;
        Inc(LPieCount);
        LPieIndex := I;
      end
      else
        LCartesian := True;
  if LPie and (LCartesian or (LPieCount <> 1)) then
    raise EDACChartDataError.Create('Pie e doughnut exigem exatamente uma serie visivel e nao podem ser misturados.');
  if LPie then
    DrawPieSeries(ACanvas, LChartRect, ASnapshot, LPieIndex,
      ASnapshot.Series[LPieIndex].ChartType = ctDoughnut)
  else
  begin
    LHasValue := False;
    LIncludeZero := False;
    LMin := 0;
    LMax := 0;
    for I := 0 to High(ASnapshot.Series) do
      if ASnapshot.Series[I].Visible then
      begin
        LIncludeZero := LIncludeZero or
          (ASnapshot.Series[I].ChartType in [ctBar, ctArea]);
      for J := 0 to High(ASnapshot.Series[I].Values) do
        if not ASnapshot.Series[I].Values[J].IsNull then
        begin
          if not LHasValue then
          begin
            LMin := ASnapshot.Series[I].Values[J].Value;
            LMax := LMin;
            LHasValue := True;
          end
          else
          begin
            LMin := Min(LMin, ASnapshot.Series[I].Values[J].Value);
            LMax := Max(LMax, ASnapshot.Series[I].Values[J].Value);
          end;
        end;
      end;
    if LIncludeZero then
    begin
      LMin := Min(LMin, 0);
      LMax := Max(LMax, 0);
    end;
    if not FYAxis.AutoScale then
    begin
      if FYAxis.Min >= FYAxis.Max then
        raise EDACChartDataError.Create('YAxis.Min deve ser menor que YAxis.Max.');
      LMin := FYAxis.Min;
      LMax := FYAxis.Max;
    end;
    if SameValue(LMin, LMax) then
    begin
      LMargin := Max(1, Abs(LMin) * 0.1);
      LMin := LMin - LMargin;
      LMax := LMax + LMargin;
    end
    else if not LIncludeZero then
    begin
      LMargin := (LMax - LMin) * 0.05;
      LMin := LMin - LMargin;
      LMax := LMax + LMargin;
    end;
    DrawCartesianSeries(ACanvas, LChartRect, ASnapshot, LMin, LMax);
  end;
  DrawLegend(ACanvas, ADest, ASnapshot);
end;

procedure TDACChart.DrawEmpty(const ACanvas: ISkCanvas; const ARect: TRectF;
  const AText: string);
begin
  QueueNativeTextCentered(AText, DACChartDefaultFontFamily, ARect,
    TextPixels(TDACComponentStyle.CaptionSize), ResolvedChartPalette.TextoSecundario);
end;

procedure TDACChart.DrawFrame(const ACanvas: ISkCanvas; const ADest: TRectF);
var
  LRect: TRectF;
  LStrokeWidth: Single;
  LTokens: TDACControlTokens;
begin
  LTokens := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls;
  { A two-pixel, pixel-aligned outline keeps the chart card legible on the
    light gallery and avoids the weak half-pixel edge of the former frame. }
  LStrokeWidth := Max(Pixels(2), Pixels(Round(LTokens.ChartBorderWidth)));
  LRect := TRectF.Create(LStrokeWidth / 2, LStrokeWidth / 2,
    ADest.Width - (LStrokeWidth / 2), ADest.Height - (LStrokeWidth / 2));
  FRenderer.FillRoundRect(ACanvas, LRect, FBackgroundColor,
    Pixels(Round(LTokens.ChartRadius)), LTokens.AlphaOpaque);
  FRenderer.StrokeRoundRect(ACanvas, LRect, FBorderColor,
    Pixels(Round(LTokens.ChartRadius)), LStrokeWidth,
    LTokens.AlphaOpaque);
end;

procedure TDACChart.DrawGrid(const ACanvas: ISkCanvas; const ARect: TRectF);
var
  LDash: TArray<Single>;
  I: Integer;
  LPalette: TDACChartPalette;
  LPaint: ISkPaint;
  LTickCount: Integer;
  LX: Single;
  LY: Single;
begin
  if not FChartGrid.Visible or
    (not FYAxis.GridLines and not FXAxis.GridLines) then
    Exit;
  LPalette := ResolvedChartPalette;
  LPaint := TSkPaint.Create(TSkPaintStyle.Stroke);
  LPaint.AntiAlias := True;
  LPaint.StrokeWidth := Pixels(1);
  case FChartGrid.LineStyle of
    psDash: LDash := [Pixels(6), Pixels(4)];
    psDot: LDash := [Pixels(1), Pixels(3)];
    psDashDot: LDash := [Pixels(6), Pixels(3), Pixels(1), Pixels(3)];
    psDashDotDot: LDash := [Pixels(6), Pixels(3), Pixels(1), Pixels(3),
      Pixels(1), Pixels(3)];
  end;
  if Length(LDash) > 0 then
    LPaint.PathEffect := TSkPathEffect.MakeDash(LDash, 0);
  if FYAxis.GridLines then
  begin
    LPaint.Color := DACChartColorOrDefault(FYAxis.GridColor,
      LPalette.GradeSecundaria);
    LTickCount := Max(1, FYAxis.Ticks);
    for I := 0 to LTickCount do
    begin
      LY := Round(ARect.Top + (ARect.Height / LTickCount * I)) + 0.5;
      ACanvas.DrawLine(ARect.Left, LY, ARect.Right, LY, LPaint);
    end;
  end;
  if FXAxis.GridLines then
  begin
    LPaint.Color := DACChartColorOrDefault(FXAxis.GridColor,
      LPalette.GradeSecundaria);
    LTickCount := Max(1, FXAxis.Ticks);
    for I := 0 to LTickCount do
    begin
      LX := Round(ARect.Left + (ARect.Width / LTickCount * I)) + 0.5;
      ACanvas.DrawLine(LX, ARect.Top, LX, ARect.Bottom, LPaint);
    end;
  end;
end;

procedure TDACChart.DrawNativeTextItems(
  const AItems: TList<TDACChartNativeTextItem>);
var
  I: Integer;
  LColor: COLORREF;
  LFlags: Cardinal;
  LFont: HFONT;
  LItem: TDACChartNativeTextItem;
  LOldFont: HGDIOBJ;
  LOldMode: Integer;
  LOldTextColor: COLORREF;
  LRect: TRect;
  LTextHeight: Integer;
  LWeight: Integer;
  LWidth: Integer;
  function NativeColor(const AColor: TAlphaColor): COLORREF;
  begin
    Result := RGB((Cardinal(AColor) shr 16) and $FF,
      (Cardinal(AColor) shr 8) and $FF, Cardinal(AColor) and $FF);
  end;
begin
  if (AItems = nil) or (AItems.Count = 0) or not HandleAllocated then
    Exit;
  for I := 0 to AItems.Count - 1 do
  begin
    LItem := AItems[I];
    if LItem.Text = '' then
      Continue;
    LTextHeight := Max(1, MulDiv(Round(LItem.Size), 96, 72));
    if LItem.Bold then
      LWeight := FW_BOLD
    else
      LWeight := FW_NORMAL;
    LFont := CreateFont(-LTextHeight, 0, 0, 0,
      LWeight, 0, 0, 0, DEFAULT_CHARSET,
      OUT_DEFAULT_PRECIS, CLIP_DEFAULT_PRECIS, CLEARTYPE_QUALITY,
      DEFAULT_PITCH or FF_DONTCARE, PChar(LItem.Family));
    if LFont = 0 then
      Continue;
    LOldFont := SelectObject(Canvas.Handle, LFont);
    LOldMode := SetBkMode(Canvas.Handle, TRANSPARENT);
    LColor := NativeColor(LItem.Color);
    LOldTextColor := SetTextColor(Canvas.Handle, LColor);
    try
      LFlags := DT_SINGLELINE or DT_NOPREFIX or DT_END_ELLIPSIS;
      if LItem.Centered then
      begin
        LRect := Rect(Round(LItem.Bounds.Left), Round(LItem.Bounds.Top),
          Round(LItem.Bounds.Right), Round(LItem.Bounds.Bottom));
        LFlags := LFlags or DT_CENTER or DT_VCENTER;
      end
      else
      begin
        LWidth := Round(LItem.MaxWidth);
        if LWidth <= 0 then
          LWidth := Max(1, Width - Round(LItem.Baseline.X));
        LRect := Rect(Round(LItem.Baseline.X),
          Round(LItem.Baseline.Y - (LItem.Size * 1.34)),
          Round(LItem.Baseline.X) + LWidth,
          Round(LItem.Baseline.Y + (LItem.Size * 0.34)));
        LFlags := LFlags or DT_LEFT or DT_TOP;
      end;
      Winapi.Windows.DrawText(Canvas.Handle, PChar(LItem.Text), Length(LItem.Text),
        LRect, LFlags);
    finally
      SetTextColor(Canvas.Handle, LOldTextColor);
      SetBkMode(Canvas.Handle, LOldMode);
      SelectObject(Canvas.Handle, LOldFont);
      DeleteObject(LFont);
    end;
  end;
end;

procedure TDACChart.DrawNativeTooltipLayer(
  const AMarkers: TList<TDACChartNativeTooltipMarker>);
var
  I: Integer;
  LBrush: HBRUSH;
  LMarker: TDACChartNativeTooltipMarker;
  LOldBrush: HGDIOBJ;
  LOldPen: HGDIOBJ;
  LPen: HPEN;
  LRect: TRect;
  function NativeColor(const AColor: TAlphaColor): COLORREF;
  begin
    Result := RGB((Cardinal(AColor) shr 16) and $FF,
      (Cardinal(AColor) shr 8) and $FF, Cardinal(AColor) and $FF);
  end;
begin
  if not FNativeTooltipActive or not HandleAllocated then
    Exit;

  LRect := Rect(Round(FNativeTooltipRect.Left), Round(FNativeTooltipRect.Top),
    Round(FNativeTooltipRect.Right), Round(FNativeTooltipRect.Bottom));
  LBrush := CreateSolidBrush(NativeColor(FNativeTooltipBackground));
  LPen := CreatePen(PS_SOLID, Max(1, Pixels(1)),
    NativeColor(FNativeTooltipBorder));
  if (LBrush = 0) or (LPen = 0) then
  begin
    if LBrush <> 0 then DeleteObject(LBrush);
    if LPen <> 0 then DeleteObject(LPen);
    Exit;
  end;
  LOldBrush := SelectObject(Canvas.Handle, LBrush);
  LOldPen := SelectObject(Canvas.Handle, LPen);
  try
    RoundRect(Canvas.Handle, LRect.Left, LRect.Top, LRect.Right, LRect.Bottom,
      Pixels(8) * 2, Pixels(8) * 2);
  finally
    SelectObject(Canvas.Handle, LOldPen);
    SelectObject(Canvas.Handle, LOldBrush);
    DeleteObject(LPen);
    DeleteObject(LBrush);
  end;

  if AMarkers = nil then
    Exit;
  LOldPen := SelectObject(Canvas.Handle, GetStockObject(NULL_PEN));
  try
    for I := 0 to AMarkers.Count - 1 do
    begin
      LMarker := AMarkers[I];
      LBrush := CreateSolidBrush(NativeColor(LMarker.Color));
      if LBrush = 0 then
        Continue;
      LOldBrush := SelectObject(Canvas.Handle, LBrush);
      try
        Ellipse(Canvas.Handle, Round(LMarker.Center.X - LMarker.Radius),
          Round(LMarker.Center.Y - LMarker.Radius),
          Round(LMarker.Center.X + LMarker.Radius),
          Round(LMarker.Center.Y + LMarker.Radius));
      finally
        SelectObject(Canvas.Handle, LOldBrush);
        DeleteObject(LBrush);
      end;
    end;
  finally
    SelectObject(Canvas.Handle, LOldPen);
  end;
end;

procedure TDACChart.DrawLegend(const ACanvas: ISkCanvas; const ADest: TRectF;
  const ASnapshot: TDACChartSnapshot);
var
  I: Integer;
  LColor: TAlphaColor;
  LCellWidth: Single;
  LColumns: Integer;
  LFamily: string;
  LHit: TDACChartHitArea;
  LItemCount: Integer;
  LItemHeight: Single;
  LItemWidth: Single;
  LLegendRect: TRectF;
  LMaxItemWidth: Single;
  LName: string;
  LNaturalWidth: Single;
  LPieSeriesIndex: Integer;
  LRowsPerColumn: Integer;
  LSideLegend: Boolean;
  LRect: TRectF;
  LTextColor: TAlphaColor;
  LTextMaxWidth: Single;
  LTextWidth: Single;
  LX: Single;
  LY: Single;
  function SeriesHasRenderableValue(const ASeriesIndex: Integer): Boolean;
  var
    LValueIndex: Integer;
    LPie: Boolean;
  begin
    Result := False;
    LPie := ASnapshot.Series[ASeriesIndex].ChartType in [ctPie, ctDoughnut];
    for LValueIndex := 0 to High(ASnapshot.Series[ASeriesIndex].Values) do
      if not ASnapshot.Series[ASeriesIndex].Values[LValueIndex].IsNull and
        (not LPie or (ASnapshot.Series[ASeriesIndex].Values[LValueIndex].Value > 0)) then
        Exit(True);
  end;
  procedure AccountItem(const AName: string);
  begin
    LItemWidth := 0;
    if FLegend.MarkersVisible then
      LItemWidth := Pixels(FLegend.MarkerSize) + Pixels(6);
    if FLegend.LabelsVisible then
      LItemWidth := LItemWidth + NativeTextWidth(AName, LFamily,
        TextPixels(FLegend.Font.Size), fsBold in FLegend.Font.Style);
    LItemWidth := Max(LItemWidth, Pixels(FLegend.MarkerSize));
    LMaxItemWidth := Max(LMaxItemWidth, LItemWidth);
    if LItemCount > 0 then
      LNaturalWidth := LNaturalWidth + Pixels(FLegend.ItemSpacing);
    LNaturalWidth := LNaturalWidth + LItemWidth;
    Inc(LItemCount);
  end;
  procedure DrawItem(const AName: string; const AColor: TAlphaColor;
    const ASeriesIndex, APointIndex: Integer; const ACategory: string;
    const AValue: Double);
  begin
    LTextWidth := 0;
    if FLegend.LabelsVisible then
      LTextWidth := NativeTextWidth(AName, LFamily, TextPixels(FLegend.Font.Size),
        fsBold in FLegend.Font.Style);
    if LSideLegend then
      LTextMaxWidth := Max(Pixels(8), LCellWidth -
        Ord(FLegend.MarkersVisible) * (Pixels(FLegend.MarkerSize) + Pixels(6)))
    else
      LTextMaxWidth := Max(Pixels(8), LLegendRect.Right - LX - Pixels(FLegend.Padding));
    if FLegend.MarkersVisible then
    begin
      LRect := TRectF.Create(LX, LY - Pixels(FLegend.MarkerSize) + Pixels(1),
        LX + Pixels(FLegend.MarkerSize), LY + Pixels(1));
      FRenderer.FillRoundRect(ACanvas, LRect, AColor, Pixels(3));
    end;
    if FLegend.LabelsVisible then
      QueueNativeText(AName, LFamily,
        LX + Ord(FLegend.MarkersVisible) * (Pixels(FLegend.MarkerSize) + Pixels(6)), LY,
        TextPixels(FLegend.Font.Size), LTextColor, fsBold in FLegend.Font.Style,
        LTextMaxWidth);
    LHit.Rect := TRectF.Create(LX, LY - LItemHeight,
      LX + Ord(FLegend.MarkersVisible) * (Pixels(FLegend.MarkerSize) + Pixels(6)) +
      Max(Min(LTextWidth, LTextMaxWidth), Pixels(FLegend.MarkerSize)), LY + Pixels(4));
    LHit.Shape := chsLegend;
    LHit.SeriesIndex := ASeriesIndex;
    LHit.PointIndex := APointIndex;
    LHit.Category := ACategory;
    LHit.Value := AValue;
    FHitAreas.Add(LHit);
    if FLegend.Orientation = coVertical then
    begin
      LY := LY + LItemHeight + Pixels(FLegend.ItemSpacing);
      if (LY + Pixels(4)) > (LLegendRect.Bottom - Pixels(FLegend.Padding)) then
      begin
        LY := LLegendRect.Top + Pixels(FLegend.Padding) +
          (TextPixels(FLegend.Font.Size) * 1.34);
        LX := LX + LCellWidth + Pixels(FLegend.ItemSpacing);
      end;
    end
    else
    begin
      LX := LX + Ord(FLegend.MarkersVisible) * (Pixels(FLegend.MarkerSize) + Pixels(6)) +
        LTextWidth + Pixels(FLegend.ItemSpacing);
      if LX > (LLegendRect.Right - Pixels(24)) then
      begin
        LX := LLegendRect.Left + Pixels(FLegend.Padding);
        LY := LY + LItemHeight + Pixels(FLegend.ItemSpacing);
      end;
    end;
  end;
begin
  if not FLegend.Visible or not ASnapshot.HasData or
    (Length(ASnapshot.Series) = 0) then
    Exit;
  LFamily := DACChartFontName(FLegend.Font);
  LTextColor := DACChartColorOrDefault(FLegend.TextColor,
    ResolvedChartPalette.TextoPrincipal);
  LItemHeight := Max(TextPixels(FLegend.Font.Size) + Pixels(6),
    Pixels(FLegend.MarkerSize) + Pixels(4));
  LSideLegend := FLegend.Position in [cpLeft, cpRight];

  LPieSeriesIndex := -1;
  for I := 0 to High(ASnapshot.Series) do
    if ASnapshot.Series[I].Visible and
      (ASnapshot.Series[I].ChartType in [ctPie, ctDoughnut]) then
    begin
      LPieSeriesIndex := I;
      Break;
    end;

  LItemCount := 0;
  LMaxItemWidth := 0;
  LNaturalWidth := 0;
  if LPieSeriesIndex >= 0 then
  begin
    for I := 0 to High(ASnapshot.Series[LPieSeriesIndex].Values) do
      if not ASnapshot.Series[LPieSeriesIndex].Values[I].IsNull and
        (ASnapshot.Series[LPieSeriesIndex].Values[I].Value > 0) then
        AccountItem(ASnapshot.Series[LPieSeriesIndex].Values[I].Category);
  end
  else
    for I := 0 to High(ASnapshot.Series) do
      if SeriesHasRenderableValue(I) then
      begin
        LName := ASnapshot.Series[I].Name;
        if LName = '' then
          LName := 'Serie ' + IntToStr(I + 1);
        AccountItem(LName);
      end;
  if LItemCount = 0 then
    Exit;

  { The legend owns a real region in the chart layout.  It is deliberately
    calculated from the same helper as ChartRect, so it never floats over
    bars, lines, axes or pie slices. }
  LLegendRect := LegendRect(ADest, ASnapshot);
  if (LLegendRect.Right <= LLegendRect.Left) or
    (LLegendRect.Bottom <= LLegendRect.Top) then
    Exit;
  if FLegend.BackgroundVisible then
    FRenderer.FillRoundRect(ACanvas, LLegendRect,
      DACChartColorOrDefault(FLegend.BackgroundColor, ResolvedChartPalette.Card), Pixels(6));
  if FLegend.BorderVisible then
    FRenderer.StrokeRoundRect(ACanvas, LLegendRect,
      DACChartColorOrDefault(FLegend.BorderColor, ResolvedChartPalette.LinhaEixo),
      Pixels(6), Pixels(1));
  LX := LLegendRect.Left + Pixels(FLegend.Padding);
  LY := LLegendRect.Top + Pixels(FLegend.Padding) +
    (TextPixels(FLegend.Font.Size) * 1.34);
  LCellWidth := LMaxItemWidth;
  if LSideLegend then
  begin
    LRowsPerColumn := Max(1, Floor((LLegendRect.Height -
      (Pixels(FLegend.Padding) * 2) + Pixels(FLegend.ItemSpacing)) /
      (LItemHeight + Pixels(FLegend.ItemSpacing))));
    LColumns := Max(1, Ceil(LItemCount / LRowsPerColumn));
    LCellWidth := Max(Pixels(104), Min(Pixels(150),
      (LLegendRect.Width - (Pixels(FLegend.Padding) * 2) -
      ((LColumns - 1) * Pixels(FLegend.ItemSpacing))) / LColumns));
  end
  else
    LCellWidth := Max(Pixels(1), LLegendRect.Width - (Pixels(FLegend.Padding) * 2));

  if LPieSeriesIndex >= 0 then
  begin
    for I := 0 to High(ASnapshot.Series[LPieSeriesIndex].Values) do
      if not ASnapshot.Series[LPieSeriesIndex].Values[I].IsNull and
        (ASnapshot.Series[LPieSeriesIndex].Values[I].Value > 0) then
        DrawItem(ASnapshot.Series[LPieSeriesIndex].Values[I].Category,
          ResolvedChartPalette.ColorByIndex(I), LPieSeriesIndex, I,
          ASnapshot.Series[LPieSeriesIndex].Values[I].Category,
          ASnapshot.Series[LPieSeriesIndex].Values[I].Value);
    Exit;
  end;

  for I := 0 to High(ASnapshot.Series) do
  begin
    if not SeriesHasRenderableValue(I) then
      Continue;
    LName := ASnapshot.Series[I].Name;
    if LName = '' then
      LName := 'Série ' + IntToStr(I + 1);
    LColor := ResolveFillColor(ASnapshot.Series[I], I);
    DrawItem(LName, LColor, I, -1, '', 0);
  end;
end;

procedure TDACChart.DrawLineOrAreaSeries(const ACanvas: ISkCanvas;
  const ARect: TRectF; const ASeries: TDACChartSeriesSnapshot;
  const ASeriesIndex: Integer; const AMin, AMax: Double; const AArea: Boolean);
var
  I: Integer;
  LAreaPaint: ISkPaint;
  LHit: TDACChartHitArea;
  LLine: ISkPaint;
  LPath: ISkPath;
  LPathBuilder: ISkPathBuilder;
  LPoint: ISkPaint;
  LSegmentFirstX: Single;
  LSegmentLastX: Single;
  LStarted: Boolean;
  LStep: Single;
  LX: Single;
  LY: Single;
  LZero: Single;
  procedure DrawSegment;
  begin
    if not LStarted then
      Exit;
    LPath := LPathBuilder.Snapshot;
    if AArea then
    begin
      LPathBuilder.LineTo(LSegmentLastX, LZero);
      LPathBuilder.LineTo(LSegmentFirstX, LZero);
      LPathBuilder.Close;
      LAreaPaint := TSkPaint.Create(TSkPaintStyle.Fill);
      LAreaPaint.AntiAlias := True;
      LAreaPaint.Alpha := 96;
      ApplyFillPaint(LAreaPaint, ASeries, ASeriesIndex,
        TRectF.Create(LSegmentFirstX, ARect.Top, LSegmentLastX, ARect.Bottom));
      ACanvas.DrawPath(LPathBuilder.Snapshot, LAreaPaint);
    end;
    ACanvas.DrawPath(LPath, LLine);
  end;
begin
  if not ASeries.Visible or (Length(ASeries.Values) = 0) then
    Exit;
  LStep := ARect.Width / Max(1, Length(ASeries.Values) - 1);
  LZero := ARect.Bottom - (DACChartRangeValue(0, AMin, AMax) * ARect.Height);
  LStarted := False;

  LLine := TSkPaint.Create(TSkPaintStyle.Stroke);
  LLine.AntiAlias := True;
  LLine.StrokeWidth := Pixels(3);
  LLine.StrokeCap := TSkStrokeCap.Round;
  LLine.StrokeJoin := TSkStrokeJoin.Round;
  ApplyFillPaint(LLine, ASeries, ASeriesIndex, ARect);

  LPoint := TSkPaint.Create(TSkPaintStyle.Fill);
  LPoint.AntiAlias := True;
  ApplyFillPaint(LPoint, ASeries, ASeriesIndex, ARect);
  for I := 0 to High(ASeries.Values) do
  begin
    if ASeries.Values[I].IsNull then
    begin
      DrawSegment;
      LStarted := False;
      Continue;
    end;
    LX := ARect.Left + (I * LStep);
    LY := ARect.Bottom -
      (DACChartRangeValue(ASeries.Values[I].Value, AMin, AMax) * ARect.Height);
    if not LStarted then
    begin
      LPathBuilder := TSkPathBuilder.Create;
      LPathBuilder.MoveTo(LX, LY)
      ;
      LSegmentFirstX := LX;
      LStarted := True;
    end
    else
      LPathBuilder.LineTo(LX, LY);
    LSegmentLastX := LX;
    ACanvas.DrawCircle(LX, LY, Pixels(4), LPoint);
    LHit.Rect := TRectF.Create(LX - Pixels(8), LY - Pixels(8),
      LX + Pixels(8), LY + Pixels(8));
    LHit.Center := PointF(LX, LY);
    LHit.OuterRadius := Pixels(8);
    LHit.Shape := chsCircle;
    LHit.SeriesIndex := ASeriesIndex;
    LHit.PointIndex := I;
    LHit.Category := ASeries.Values[I].Category;
    LHit.Value := ASeries.Values[I].Value;
    FHitAreas.Add(LHit);
  end;
  DrawSegment;
end;

procedure TDACChart.DrawPieSeries(const ACanvas: ISkCanvas; const ARect: TRectF;
  const ASnapshot: TDACChartSnapshot; const ASeriesIndex: Integer;
  const ADoughnut: Boolean);
var
  I: Integer;
  LArcRect: TRectF;
  LCenter: TPointF;
  LColor: TAlphaColor;
  LFillSeries: TDACChartSeriesSnapshot;
  LHit: TDACChartHitArea;
  LPaint: ISkPaint;
  LRadius: Single;
  LStart: Single;
  LSum: Double;
  LSweep: Single;
  LValue: Double;
begin
  if (ASeriesIndex < 0) or (ASeriesIndex > High(ASnapshot.Series)) or
    (Length(ASnapshot.Series[ASeriesIndex].Values) = 0) then
    Exit;
  LSum := 0;
  for I := 0 to High(ASnapshot.Series[ASeriesIndex].Values) do
    if not ASnapshot.Series[ASeriesIndex].Values[I].IsNull then
    begin
      if ASnapshot.Series[ASeriesIndex].Values[I].Value < 0 then
        raise EDACChartDataError.Create('Pie e doughnut nao aceitam valores negativos.');
      LSum := LSum + ASnapshot.Series[ASeriesIndex].Values[I].Value;
    end;
  if LSum <= 0 then
  begin
    DrawEmpty(ACanvas, ARect, 'Sem valores positivos');
    Exit;
  end;

  LArcRect := ARect;
  if LArcRect.Width > LArcRect.Height then
  begin
    LArcRect.Left := LArcRect.Left + ((LArcRect.Width - LArcRect.Height) / 2);
    LArcRect.Right := LArcRect.Left + LArcRect.Height;
  end
  else
  begin
    LArcRect.Top := LArcRect.Top + ((LArcRect.Height - LArcRect.Width) / 2);
    LArcRect.Bottom := LArcRect.Top + LArcRect.Width;
  end;
  LArcRect.Inflate(-Pixels(8), -Pixels(8));
  LCenter := PointF((LArcRect.Left + LArcRect.Right) / 2,
    (LArcRect.Top + LArcRect.Bottom) / 2);
  LRadius := Min(LArcRect.Width, LArcRect.Height) / 2;

  LPaint := TSkPaint.Create(TSkPaintStyle.Fill);
  LPaint.AntiAlias := True;
  LStart := -90;
  for I := 0 to High(ASnapshot.Series[ASeriesIndex].Values) do
  begin
    if ASnapshot.Series[ASeriesIndex].Values[I].IsNull or
      (ASnapshot.Series[ASeriesIndex].Values[I].Value <= 0) then
      Continue;
    LValue := ASnapshot.Series[ASeriesIndex].Values[I].Value;
    LSweep := LValue / LSum * 360;
    LColor := ResolvedChartPalette.ColorByIndex(I);
    LFillSeries := ASnapshot.Series[ASeriesIndex];
    LFillSeries.Color := LColor;
    ApplyFillPaint(LPaint, LFillSeries, I, LArcRect);
    if LSweep > 0 then
      ACanvas.DrawArc(LArcRect, LStart, LSweep, True, LPaint);
    LHit.Rect := TRectF.Create(LCenter.X - LRadius, LCenter.Y - LRadius,
      LCenter.X + LRadius, LCenter.Y + LRadius);
    LHit.Center := LCenter;
    LHit.OuterRadius := LRadius;
    if ADoughnut then
      LHit.InnerRadius := LRadius * 0.42
    else
      LHit.InnerRadius := 0;
    LHit.StartAngle := LStart;
    LHit.SweepAngle := LSweep;
    LHit.Shape := chsPie;
    LHit.SeriesIndex := ASeriesIndex;
    LHit.PointIndex := I;
    LHit.Category := ASnapshot.Series[ASeriesIndex].Values[I].Category;
    LHit.Value := ASnapshot.Series[ASeriesIndex].Values[I].Value;
    FHitAreas.Add(LHit);
    LStart := LStart + LSweep;
  end;

  if ADoughnut then
    FRenderer.FillRoundRect(ACanvas, TRectF.Create(LCenter.X - (LRadius * 0.42),
      LCenter.Y - (LRadius * 0.42), LCenter.X + (LRadius * 0.42),
      LCenter.Y + (LRadius * 0.42)), FBackgroundColor, LRadius);
end;

procedure TDACChart.DrawTitle(const ACanvas: ISkCanvas; const ADest: TRectF);
var
  LColor: TAlphaColor;
  LFamily: string;
  LRect: TRectF;
  LSubColor: TAlphaColor;
  LSubY: Single;
  LTextY: Single;
  LX: Single;
  LText: string;
begin
  if not FTitle.Visible then
    Exit;
  case FTitle.Position of
    cpTop: LRect := TRectF.Create(ADest.Left + Pixels(12), ADest.Top + Pixels(6),
      ADest.Right - Pixels(12), ADest.Top + Pixels(44));
    cpRight: LRect := TRectF.Create(ADest.Right - Pixels(144), ADest.Top + Pixels(12),
      ADest.Right - Pixels(8), ADest.Bottom - Pixels(12));
    cpBottom: LRect := TRectF.Create(ADest.Left + Pixels(12), ADest.Bottom - Pixels(42),
      ADest.Right - Pixels(12), ADest.Bottom - Pixels(6));
  else
    LRect := TRectF.Create(ADest.Left + Pixels(8), ADest.Top + Pixels(12),
      ADest.Left + Pixels(144), ADest.Bottom - Pixels(12));
  end;
  LFamily := DACChartFontName(FTitle.Font);
  LColor := DACChartColorOrDefault(FTitle.TextColor,
    ResolvedChartPalette.TextoPrincipal);
  LSubColor := DACChartColorOrDefault(FTitle.SubTextColor,
    ResolvedChartPalette.TextoSecundario);
  LText := FTitle.Text;
  if LText = '' then
    LText := 'Chart';
  {$IFDEF DAC_LEGACY_MOJIBAKE}
  if False then
    LText := 'Gráfico';
  {$ENDIF}
  case FTitle.Alignment of
    taCenter: LX := LRect.Left + (LRect.Width -
      NativeTextWidth(LText, LFamily,
        TextPixels(FTitle.Font.Size), fsBold in FTitle.Font.Style)) / 2;
    taRightJustify: LX := LRect.Right -
      NativeTextWidth(LText, LFamily,
        TextPixels(FTitle.Font.Size), fsBold in FTitle.Font.Style);
  else
    LX := LRect.Left;
  end;
  LTextY := LRect.Top + (TextPixels(FTitle.Font.Size) * 1.34) + Pixels(2);
  if FTitle.TextVisible then
    QueueNativeText(LText, LFamily, LX, LTextY, TextPixels(FTitle.Font.Size), LColor,
      fsBold in FTitle.Font.Style, LRect.Width);
  if FTitle.SubTextVisible and (FTitle.SubText <> '') then
  begin
    LSubY := LTextY + NativeTextHeight(TextPixels(FTitle.Font.Size)) + Pixels(5);
    QueueNativeText(FTitle.SubText, DACChartFontName(FTitle.SubFont),
      LRect.Left, LSubY, TextPixels(FTitle.SubFont.Size), LSubColor,
      fsBold in FTitle.SubFont.Style, LRect.Width);
  end;
end;

procedure TDACChart.DrawTooltip;
var
  LBackground: TAlphaColor;
  LBorderColor: TAlphaColor;
  LContentWidth: Single;
  LDataStart: Integer;
  LDataTextColor: TAlphaColor;
  LFontFamily: string;
  LHasTitle: Boolean;
  LHeight: Single;
  LIndex: Integer;
  LLineHeight: Single;
  LMarkerOffset: Single;
  LPalette: TDACChartPalette;
  LPadding: Single;
  LRect: TRectF;
  LLines: TStringList;
  LMarkerColor: TAlphaColor;
  LName: string;
  LNameWidth: Single;
  LRowY: Single;
  LSeriesIndex: Integer;
  LTextY: Single;
  LTitleColor: TAlphaColor;
  LTitleHeight: Single;
  LTitleWidth: Single;
  LValue: string;
  LValueWidth: Single;
  LWidth: Single;
  LX: Single;
  LY: Single;
  function SeriesIndexForLine(const ALine: string): Integer;
  var
    LSeries: Integer;
    LPrefix: string;
  begin
    Result := -1;
    for LSeries := 0 to High(FAnimationFrame.Series) do
    begin
      LPrefix := FAnimationFrame.Series[LSeries].Name + ':';
      if (LPrefix <> ':') and SameText(Copy(Trim(ALine), 1, Length(LPrefix)),
        LPrefix) then
        Exit(LSeries);
    end;
  end;
  procedure SplitLine(const ALine: string; out AName, AValue: string);
  var
    LSeparator: Integer;
  begin
    AName := Trim(ALine);
    AValue := '';
    LSeparator := LastDelimiter(':', AName);
    if LSeparator <= 0 then
      Exit;
    AValue := Trim(Copy(AName, LSeparator + 1, MaxInt));
    AName := Trim(Copy(AName, 1, LSeparator - 1));
  end;
begin
  FNativeTooltipActive := False;
  if not FTooltip.Enabled or not FHoverActive or (FHoverTooltip = '') then
    Exit;
  LLines := TStringList.Create;
  try
    LLines.Text := FHoverTooltip;
    while (LLines.Count > 0) and (LLines[LLines.Count - 1] = '') do
      LLines.Delete(LLines.Count - 1);
    if LLines.Count = 0 then
      Exit;
    LPalette := ResolvedChartPalette;
    LPadding := Pixels(FTooltip.Padding);
    LFontFamily := DACChartFontName(FTooltip.Font);
    LHasTitle := (FTooltip.Mode in [ctmAxis, ctmSeries]) and
      (LLines.Count > 1);
    LDataStart := Ord(LHasTitle);
    LMarkerOffset := 0;
    if FTooltip.ShowMarker then
      LMarkerOffset := Pixels(16);
    LContentWidth := 0;
    LTitleHeight := 0;
    if LHasTitle then
    begin
      LTitleWidth := NativeTextWidth(LLines[0],
        DACChartFontName(FTooltip.TitleFont), TextPixels(FTooltip.TitleFont.Size),
        fsBold in FTooltip.TitleFont.Style);
      LContentWidth := LTitleWidth;
      LTitleHeight := NativeTextHeight(TextPixels(FTooltip.TitleFont.Size)) + Pixels(10);
    end;
    for LIndex := LDataStart to LLines.Count - 1 do
    begin
      SplitLine(LLines[LIndex], LName, LValue);
      LNameWidth := NativeTextWidth(LName, LFontFamily, TextPixels(FTooltip.Font.Size),
        fsBold in FTooltip.Font.Style);
      LValueWidth := 0;
      if LValue <> '' then
        LValueWidth := NativeTextWidth(LValue, LFontFamily,
          TextPixels(FTooltip.Font.Size), True);
      LContentWidth := Max(LContentWidth, LMarkerOffset + LNameWidth +
        Ord(LValue <> '') * Pixels(20) + LValueWidth);
    end;
    LWidth := Max(Pixels(196), LContentWidth + (LPadding * 2));
    LWidth := Min(LWidth, Max(Pixels(96), Width - Pixels(8)));
    LLineHeight := Max(NativeTextHeight(TextPixels(FTooltip.Font.Size)) +
      Pixels(10), Pixels(22));
    LHeight := (LPadding * 2) + LTitleHeight +
      ((LLines.Count - LDataStart) * LLineHeight);
    if FTooltip.FollowMouse then
    begin
      LX := FMousePoint.X + Pixels(12);
      LY := FMousePoint.Y + Pixels(12);
    end
    else
    begin
      LX := FHover.Rect.Right + Pixels(10);
      LY := FHover.Rect.Top;
    end;
    LX := EnsureRange(LX, 0, Max(0, Width - LWidth));
    LY := EnsureRange(LY, 0, Max(0, Height - LHeight));
    LRect := TRectF.Create(LX, LY, LX + LWidth, LY + LHeight);
    if FTooltip.BackgroundColor = 0 then
      LBackground := LPalette.FundoGrafico
    else
      LBackground := FTooltip.BackgroundColor;
    if FTooltip.BorderColor = 0 then
      LBorderColor := LPalette.LinhaEixo
    else
      LBorderColor := FTooltip.BorderColor;
    if FTooltip.TextColor = 0 then
      LDataTextColor := LPalette.TextoPrincipal
    else
      LDataTextColor := FTooltip.TextColor;
    if FTooltip.TitleColor = 0 then
      LTitleColor := LDataTextColor
    else
      LTitleColor := FTooltip.TitleColor;
    { Native static labels are deliberately drawn after the Skia surface.
      Therefore the complete tooltip chrome is also queued for the final
      native overlay; otherwise labels would cut through the tooltip. }
    FNativeTooltipActive := True;
    FNativeTooltipRect := LRect;
    FNativeTooltipBackground := LBackground;
    FNativeTooltipBorder := LBorderColor;
    LTextY := LRect.Top + LPadding;
    if LHasTitle then
    begin
      LTextY := LTextY + (TextPixels(FTooltip.TitleFont.Size) * 1.34);
      QueueNativeText(LLines[0], DACChartFontName(FTooltip.TitleFont),
        LRect.Left + LPadding, LTextY, TextPixels(FTooltip.TitleFont.Size),
        LTitleColor, fsBold in FTooltip.TitleFont.Style,
        LRect.Width - (LPadding * 2));
      LTextY := LTextY + Pixels(10);
    end;
    for LIndex := LDataStart to LLines.Count - 1 do
    begin
      SplitLine(LLines[LIndex], LName, LValue);
      LRowY := LTextY + (TextPixels(FTooltip.Font.Size) * 1.34);
      LSeriesIndex := SeriesIndexForLine(LLines[LIndex]);
      if FTooltip.ShowMarker and (LSeriesIndex >= 0) then
      begin
        LMarkerColor := ResolveFillColor(FAnimationFrame.Series[LSeriesIndex],
          LSeriesIndex);
        QueueNativeTooltipMarker(TPointF.Create(
          LRect.Left + LPadding + Pixels(4),
          LTextY + (LLineHeight / 2)), LMarkerColor, Pixels(4));
      end;
      QueueNativeText(LName, LFontFamily,
        LRect.Left + LPadding + LMarkerOffset, LRowY, TextPixels(FTooltip.Font.Size),
        LDataTextColor, fsBold in FTooltip.Font.Style,
        LRect.Width - (LPadding * 2) - LMarkerOffset);
      if LValue <> '' then
      begin
        LValueWidth := NativeTextWidth(LValue, LFontFamily,
          TextPixels(FTooltip.Font.Size), True);
        QueueNativeText(LValue, LFontFamily,
          LRect.Right - LPadding - LValueWidth, LRowY, TextPixels(FTooltip.Font.Size),
          LDataTextColor, True, LValueWidth + Pixels(2));
      end;
      LTextY := LTextY + LLineHeight;
    end;
  finally
    LLines.Free;
  end;
end;

function TDACChart.EffectiveSeriesCount(
  const ASnapshot: TDACChartSnapshot): Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to High(ASnapshot.Series) do
    if ASnapshot.Series[I].Visible and
      (ASnapshot.Series[I].ChartType = ctBar) then
      Inc(Result);
  if Result = 0 then
    Result := 1;
end;

function TDACChart.FieldText(const ADataSet: TDataSet; const AFieldName,
  ADefault: string): string;
begin
  Result := ADefault;
  if (ADataSet <> nil) and (AFieldName <> '') and
    (ADataSet.FindField(AFieldName) <> nil) and
    not ADataSet.FieldByName(AFieldName).IsNull then
    Result := ADataSet.FieldByName(AFieldName).DisplayText;
end;

function TDACChart.IsBackgroundColorStored: Boolean;
begin
  Result := (FAppearance = mchaCustom) and FCustomBackgroundColor;
end;

function TDACChart.IsBorderColorStored: Boolean;
begin
  Result := (FAppearance = mchaCustom) and FCustomBorderColor;
end;

procedure TDACChart.Loaded;
begin
  inherited;
  ApplyAppearance;
  QueueRefresh(True);
end;

procedure TDACChart.MouseLeave(var Message: TMessage);
begin
  inherited;
  if FHoverActive then
  begin
    FHoverActive := False;
    FHoverTooltip := '';
    FHoverAnimating := False;
    FHoverOpacity := 1;
    if (FAnimation = nil) or not FAnimation.Running then
      StopFrameTimer;
    QueueHoverRedraw;
  end;
end;

procedure TDACChart.MouseMove(Shift: TShiftState; X, Y: Integer);
var
  LChanged: Boolean;
  LHit: TDACChartHitArea;
begin
  inherited;
  if not Enabled then
    Exit;
  FMousePoint := PointF(X, Y);
  if TryHitTest(FMousePoint, LHit) then
  begin
    LChanged := not FHoverActive or
      (FHover.SeriesIndex <> LHit.SeriesIndex) or
      (FHover.PointIndex <> LHit.PointIndex);
    FHover := LHit;
    FHoverActive := True;
    if LChanged then
    begin
      if FTooltip.Enabled then
        FHoverTooltip := TooltipForHit(LHit);
      { Tooltip text/chrome is finalized by GDI to stay above the native
        axis/legend text. GDI has no alpha composition in this path, so the
        former hover-fade generated redundant 16ms full repaints without an
        observable transition. Keep the tooltip stable instead. }
      FHoverOpacity := 1;
      FHoverAnimating := False;
    end;
    if LChanged and (LHit.Shape <> chsLegend) and Assigned(FOnPointHover) then
      FOnPointHover(Self, LHit.SeriesIndex, LHit.PointIndex, LHit.Category,
        LHit.Value);
    { A fixed tooltip only changes when the datum changes. A follow-mouse
      tooltip is coalesced by QueueHoverRedraw, avoiding a full paint for
      every raw mouse message. }
    if LChanged or (FTooltip.Enabled and FTooltip.FollowMouse) then
      QueueHoverRedraw;
  end
  else if FHoverActive then
  begin
    FHoverActive := False;
    FHoverTooltip := '';
    FHoverAnimating := False;
    FHoverOpacity := 1;
    if (FAnimation = nil) or not FAnimation.Running then
      StopFrameTimer;
    QueueHoverRedraw;
  end;
end;

procedure TDACChart.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
var
  LHit: TDACChartHitArea;
begin
  if Enabled and (Button = mbLeft) and FPressedActive and
    TryHitTest(PointF(X, Y), LHit) then
    FClickArmed := (LHit.Shape = FPressedHit.Shape) and
      (LHit.SeriesIndex = FPressedHit.SeriesIndex) and
      (LHit.PointIndex = FPressedHit.PointIndex);
  FPressedActive := False;
  inherited;
end;

procedure TDACChart.Notification(AComponent: TComponent; Operation: TOperation);
begin
  inherited;
  if (Operation = opRemove) and (AComponent = FDataSource) then
    SetDataSource(nil);
end;

procedure TDACChart.Paint;
begin
  EnsureSurface;
  if FAnimationSurfaceReady then
  begin
    PresentSurface;
    DrawNativeTextItems(FNativeFrameTextItems);
    DrawNativeTooltipLayer(FNativeFrameOverlayMarkers);
    DrawNativeTextItems(FNativeFrameOverlayTextItems);
    Exit;
  end;
  FSurface.Canvas.Clear(ParentSurfaceColor);
  if Assigned(FPicture) then
    FSurface.Canvas.DrawPicture(FPicture);
  FNativeOverlayTextItems.Clear;
  FNativeOverlayMarkers.Clear;
  FNativeTooltipActive := False;
  FNativeTextQueue := FNativeOverlayTextItems;
  FNativeTooltipMarkerQueue := FNativeOverlayMarkers;
  try
    DrawTooltip;
  finally
    FNativeTextQueue := nil;
    FNativeTooltipMarkerQueue := nil;
  end;
  PresentSurface;
  DrawNativeTextItems(FNativeStaticTextItems);
  DrawNativeTooltipLayer(FNativeOverlayMarkers);
  DrawNativeTextItems(FNativeOverlayTextItems);
end;

procedure TDACChart.EnsureSurface;
var
  LInfo: TSkImageInfo;
  LHeight: Integer;
  LWidth: Integer;
begin
  LWidth := Max(1, Width);
  LHeight := Max(1, Height);
  if Assigned(FSurface) and (FSurfaceWidth = LWidth) and
    (FSurfaceHeight = LHeight) then
    Exit;
  FSurface := nil;
  FSurfaceWidth := LWidth;
  FSurfaceHeight := LHeight;
  SetLength(FSurfacePixels, LWidth * LHeight * 4);
  LInfo := TSkImageInfo.Create(LWidth, LHeight);
  FSurface := TSkSurface.MakeRasterDirect(LInfo, @FSurfacePixels[0],
    NativeUInt(LWidth * 4));
  if not Assigned(FSurface) then
    raise EOutOfMemory.Create('Nao foi possivel criar a superficie Skia do grafico.');
end;

procedure TDACChart.PresentSurface;
var
  LBitmapInfo: TBitmapInfo;
begin
  if Length(FSurfacePixels) = 0 then
    Exit;
  if FSurface <> nil then
    FSurface.Flush;
  ZeroMemory(@LBitmapInfo, SizeOf(LBitmapInfo));
  LBitmapInfo.bmiHeader.biSize := SizeOf(LBitmapInfo.bmiHeader);
  LBitmapInfo.bmiHeader.biWidth := FSurfaceWidth;
  LBitmapInfo.bmiHeader.biHeight := -FSurfaceHeight;
  LBitmapInfo.bmiHeader.biPlanes := 1;
  LBitmapInfo.bmiHeader.biBitCount := 32;
  LBitmapInfo.bmiHeader.biCompression := BI_RGB;
  SetDIBitsToDevice(Canvas.Handle, 0, 0, FSurfaceWidth, FSurfaceHeight,
    0, 0, 0, FSurfaceHeight, @FSurfacePixels[0], LBitmapInfo, DIB_RGB_COLORS);
end;

procedure TDACChart.RenderAnimationFrame;
var
  LHit: TDACChartHitArea;
begin
  if not HandleAllocated then
    Exit;
  EnsureSurface;
  FSurface.Canvas.Clear(ParentSurfaceColor);
  FNativeFrameTextItems.Clear;
  FNativeFrameOverlayTextItems.Clear;
  FNativeFrameOverlayMarkers.Clear;
  FNativeTooltipActive := False;
  FNativeTextQueue := FNativeFrameTextItems;
  try
    DrawChart(FSurface.Canvas, TRectF.Create(0, 0, Max(1, Width),
      Max(1, Height)), FAnimationFrame);
    if FHoverActive and TryHitTest(FMousePoint, LHit) then
    begin
      if (FHover.SeriesIndex <> LHit.SeriesIndex) or
        (FHover.PointIndex <> LHit.PointIndex) then
      begin
        FHover := LHit;
        FHoverTooltipSeriesIndex := -1;
        FHoverTooltipPointIndex := -1;
      end;
      if FTooltip.Enabled and ((FHoverTooltip = '') or
        (FHoverTooltipSeriesIndex <> LHit.SeriesIndex) or
        (FHoverTooltipPointIndex <> LHit.PointIndex)) then
        FHoverTooltip := TooltipForHit(LHit);
    end;
    FNativeTextQueue := FNativeFrameOverlayTextItems;
    FNativeTooltipMarkerQueue := FNativeFrameOverlayMarkers;
    DrawTooltip;
  finally
    FNativeTextQueue := nil;
    FNativeTooltipMarkerQueue := nil;
  end;
  FAnimationSurfaceReady := True;
end;

procedure TDACChart.QueueRefresh(const ADataChanged: Boolean);
begin
  if ADataChanged then
    FDataDirty := True;
  if not HandleAllocated then
    Exit;
  if FRefreshPosted then
    Exit;
  FRefreshPosted := True;
  PostMessage(Handle, WM_APP + $461, 0, 0);
end;

procedure TDACChart.QueueHoverRedraw;
begin
  if not HandleAllocated or FHoverRedrawPosted then
    Exit;
  FHoverRedrawPosted := True;
  PostMessage(Handle, WM_APP + $462, 0, 0);
end;

procedure TDACChart.WMDACChartRefresh(var AMessage: TMessage);
begin
  FRefreshPosted := False;
  if FDataDirty then
  begin
    RefreshSnapshot;
    FGeometryDirty := True;
  end;
  if FLayoutDirty then
    FGeometryDirty := True;
  if FGeometryDirty then
    try
      if (FAnimation <> nil) and FAnimation.Enabled and
        FAnimation.AutoStartOnUpdate and HandleAllocated then
        StartAnimation
      else
      begin
        StopAnimation(False);
        BuildGeometry(FSnapshot);
      end;
    except
      on E: Exception do
      begin
        if Assigned(FOnDataError) then
          FOnDataError(Self, E)
        else if not (csDesigning in ComponentState) then
          raise;
      end;
    end;
  FLayoutDirty := False;
  FGeometryDirty := False;
  Redraw;
end;

procedure TDACChart.WMDACChartHoverRedraw(var AMessage: TMessage);
begin
  FHoverRedrawPosted := False;
  if (FAnimation <> nil) and FAnimation.Running then
    RenderAnimationFrame;
  Redraw;
end;

procedure TDACChart.WMDpiChanged(var AMessage: TMessage);
begin
  ApplyDpi(Word(AMessage.WParam and $FFFF));
  QueueRefresh(False);
end;

procedure TDACChart.WMTimer(var AMessage: TWMTimer);
begin
  inherited;
  if AMessage.TimerID <> DACChartAnimationTimerId then
    Exit;
  UpdateHoverFrame;
  UpdateAnimationFrame;
  if ((FAnimation = nil) or not FAnimation.Running) and not FHoverAnimating then
    StopFrameTimer;
  { Animation frames are already rate-limited by the timer. Mouse movement,
    not animation, is the bursty path and is the one coalesced separately. }
  Redraw;
end;

function TDACChart.ParentSurfaceColor: TAlphaColor;
begin
  Result := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls.PopupBackground;
end;

procedure TDACChart.ApplyDpi(const ADpi: Integer);
var
  LDpi: Integer;
begin
  LDpi := ADpi;
  if (LDpi < 96) or (LDpi > 960) then
    LDpi := 96;
  if (FEffectiveDpi = LDpi) and SameValue(FDpiScale, LDpi / 96) then
    Exit;
  FEffectiveDpi := LDpi;
  FDpiScale := LDpi / 96;
  FLayoutDirty := True;
  FGeometryDirty := True;
  FSurface := nil;
  FAnimationSurfaceReady := False;
end;

function TDACChart.Pixels(const AValue: Integer): Integer;
begin
  Result := Round(AValue * FDpiScale);
  if (AValue > 0) and (Result < 1) then
    Result := 1;
end;

procedure TDACChart.QueueNativeText(const AText, AFamily: string;
  const AX, AY, ASize: Single; const AColor: TAlphaColor;
  const ABold: Boolean; const AMaxWidth: Single);
var
  LItem: TDACChartNativeTextItem;
begin
  if (FNativeTextQueue = nil) or (AText = '') then
    Exit;
  LItem.Text := AText;
  LItem.Family := AFamily;
  LItem.Baseline := TPointF.Create(AX, AY);
  LItem.Bounds := TRectF.Create(0, 0, 0, 0);
  LItem.Size := ASize;
  LItem.Color := AColor;
  LItem.Bold := ABold;
  LItem.Centered := False;
  LItem.MaxWidth := AMaxWidth;
  FNativeTextQueue.Add(LItem);
end;

procedure TDACChart.QueueNativeTextCentered(const AText, AFamily: string;
  const ARect: TRectF; const ASize: Single; const AColor: TAlphaColor;
  const ABold: Boolean; const AMaxWidth: Single);
var
  LItem: TDACChartNativeTextItem;
begin
  if (FNativeTextQueue = nil) or (AText = '') then
    Exit;
  LItem.Text := AText;
  LItem.Family := AFamily;
  LItem.Bounds := ARect;
  LItem.Baseline := TPointF.Create(0, 0);
  LItem.Size := ASize;
  LItem.Color := AColor;
  LItem.Bold := ABold;
  LItem.Centered := True;
  LItem.MaxWidth := AMaxWidth;
  FNativeTextQueue.Add(LItem);
end;

procedure TDACChart.QueueNativeTooltipMarker(const ACenter: TPointF;
  const AColor: TAlphaColor; const ARadius: Single);
var
  LMarker: TDACChartNativeTooltipMarker;
begin
  if FNativeTooltipMarkerQueue = nil then
    Exit;
  LMarker.Center := ACenter;
  LMarker.Color := AColor;
  LMarker.Radius := ARadius;
  FNativeTooltipMarkerQueue.Add(LMarker);
end;

procedure TDACChart.RefreshDpi;
var
  LGetDpiForWindow: TGetDpiForWindowProc;
  LModule: HMODULE;
  LDpi: UINT;
begin
  if not HandleAllocated then
  begin
    ApplyDpi(96);
    Exit;
  end;
  LDpi := 96;
  LModule := GetModuleHandle('user32.dll');
  if LModule <> 0 then
  begin
    @LGetDpiForWindow := Winapi.Windows.GetProcAddress(LModule,
      PAnsiChar(AnsiString('GetDpiForWindow')));
    if Assigned(LGetDpiForWindow) then
      LDpi := LGetDpiForWindow(Handle);
  end;
  ApplyDpi(LDpi);
end;

function TDACChart.TextPixels(const AValue: Integer): Single;
begin
  Result := AValue * FDpiScale;
end;

procedure TDACChart.RefreshSnapshot;
var
  LSnapshot: TDACChartSnapshot;
begin
  ClearSnapshot(LSnapshot);
  try
    case FDataMode of
      cdmManual:
        BuildManualSnapshot(LSnapshot);
      cdmDataSource:
        BuildSnapshotFromDataSet(LSnapshot);
    else
      if FDataSource <> nil then
        BuildSnapshotFromDataSet(LSnapshot)
      else
        BuildManualSnapshot(LSnapshot);
    end;
    if (csDesigning in ComponentState) and not LSnapshot.HasData then
      BuildDesignSnapshot(LSnapshot);
    FSnapshot := LSnapshot;
    Inc(FDataRevision);
    FHoverTooltipRevision := -1;
    FHoverTooltipSeriesIndex := -1;
    FHoverTooltipPointIndex := -1;
  except
    on E: Exception do
    begin
      if Assigned(FOnDataError) then
        FOnDataError(Self, E)
      else if not (csDesigning in ComponentState) then
        raise;
    end;
  end;
  FDataDirty := False;
end;

procedure TDACChart.Redraw;
begin
  if HandleAllocated then
    Invalidate;
end;

procedure TDACChart.RequeryData;
begin
  QueueRefresh(True);
end;

procedure TDACChart.Replay;
begin
  if FDataDirty then
  begin
    QueueRefresh(True);
    Exit;
  end;
  if (FAnimation = nil) or not FAnimation.Enabled or not HandleAllocated then
  begin
    BuildGeometry(FSnapshot);
    Redraw;
    Exit;
  end;
  BuildZeroSnapshot(FSnapshot, FAnimationSource);
  FAnimationStartTick := GetTickCount;
  FAnimation.SetRunning(True);
  if Assigned(FOnAnimationStart) then
    FOnAnimationStart(Self);
  UpdateAnimationFrame;
  StartFrameTimer;
end;

procedure TDACChart.Stop;
begin
  StopAnimation(False);
  if FHasRenderSnapshot then
    BuildGeometry(FSnapshot);
  Redraw;
end;

function TDACChart.ResolveFillColor(const ASeries: TDACChartSeriesSnapshot;
  const ASeriesIndex: Integer): TAlphaColor;
begin
  Result := ASeries.Color;
  if Result = 0 then
    Result := ResolvedChartPalette.ColorByIndex(ASeriesIndex);
end;

function TDACChart.ResolveGradientEndColor(
  const ASeries: TDACChartSeriesSnapshot; const ASeriesIndex: Integer): TAlphaColor;
begin
  Result := ASeries.GradientEndColor;
  if Result = 0 then
    Result := DACChartInterpolateColor(ResolveFillColor(ASeries, ASeriesIndex),
      ResolvedChartPalette.VerdeClaroSuave, 0.45);
end;

procedure TDACChart.Resize;
begin
  inherited;
  FLayoutDirty := True;
  FGeometryDirty := True;
  FSurface := nil;
  FAnimationSurfaceReady := False;
  QueueRefresh(False);
end;

function TDACChart.ResolvedAccentColor: TAlphaColor;
begin
  Result := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls.ChartAccent;
end;

function TDACChart.ResolvedBackgroundColor: TAlphaColor;
var
  LAppearance: TDACChartAppearance;
  LTokens: TDACControlTokens;
begin
  if (FAppearance = mchaCustom) and FCustomBackgroundColor then
    Exit(FBackgroundColor);
  LAppearance := FAppearance;
  if LAppearance = mchaCustom then
    LAppearance := FBaseAppearance;
  LTokens := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).Tokens.Controls;
  if LAppearance = mchaDashboard then
    Result := LTokens.ChartDashboardBackground
  else
    Result := LTokens.ContainerSuiteBackground;
end;

function TDACChart.ResolvedChartPalette: TDACChartPalette;
begin
  Result := TDACComponentStyle.ResolveForSurface(Self, FThemeMode).ChartPalette;
end;

function TDACChart.ResolvedDoughnutSeriesColor(
  const AIndex: Integer): TAlphaColor;
begin
  Result := ResolvedChartPalette.ColorByIndex(AIndex);
end;

procedure TDACChart.SetAppearance(const AValue: TDACChartAppearance);
begin
  if FAppearance = AValue then
  begin
    if AValue <> mchaCustom then
      ApplyAppearance;
    Exit;
  end;
  FAppearance := AValue;
  if AValue <> mchaCustom then
    FBaseAppearance := AValue
  else
  begin
    FCustomBackgroundColor := True;
    FCustomBorderColor := True;
  end;
  ApplyAppearance;
  ChartChanged;
end;

procedure TDACChart.SetAnimation(const AValue: TDACChartAnimation);
begin
  if (AValue <> nil) and (AValue <> FAnimation) then
    FAnimation.Assign(AValue);
end;

procedure TDACChart.SetBackgroundColor(const AValue: TAlphaColor);
begin
  FAppearance := mchaCustom;
  FCustomBackgroundColor := True;
  if FBackgroundColor = AValue then
    Exit;
  FBackgroundColor := AValue;
  Color := TDACComponentColors.ToVclColor(FBackgroundColor);
  Redraw;
end;

procedure TDACChart.SetBorderColor(const AValue: TAlphaColor);
begin
  FAppearance := mchaCustom;
  FCustomBorderColor := True;
  if FBorderColor = AValue then
    Exit;
  FBorderColor := AValue;
  Redraw;
end;

procedure TDACChart.SetChartGrid(const AValue: TDACChartGridOptions);
begin
  FChartGrid.Assign(AValue);
end;

procedure TDACChart.SetChartType(const AValue: TDACChartType);
begin
  if FChartType = AValue then
    Exit;
  FChartType := AValue;
  ChartChanged;
end;

procedure TDACChart.SetDataSource(const AValue: TDataSource);
begin
  if FDataSource = AValue then
    Exit;
  if FDataSource <> nil then
    FDataSource.RemoveFreeNotification(Self);
  FDataSource := AValue;
  if FDataSource <> nil then
    FDataSource.FreeNotification(Self);
  UpdateDataLink;
  RequeryData;
end;

procedure TDACChart.SetDataMode(const AValue: TDACChartDataMode);
begin
  if FDataMode = AValue then
    Exit;
  FDataMode := AValue;
  UpdateDataLink;
  RequeryData;
end;

procedure TDACChart.SetDatasetOptions(const AValue: TDACChartDatasetOptions);
begin
  FDatasetOptions.Assign(AValue);
end;

procedure TDACChart.SetLegend(const AValue: TDACChartLegend);
begin
  FLegend.Assign(AValue);
end;

procedure TDACChart.SetSeries(const AValue: TDACChartSeriesCollection);
begin
  FSeries.Assign(AValue);
end;

procedure TDACChart.SetShowFrame(const AValue: Boolean);
begin
  if FShowFrame = AValue then
    Exit;
  FShowFrame := AValue;
  ChartChanged;
end;

procedure TDACChart.SetThemeMode(const AValue: TDACThemeMode);
begin
  if FThemeMode = AValue then
    Exit;
  FThemeMode := AValue;
  ThemeChanged(Self);
end;

procedure TDACChart.SetTitle(const AValue: TDACChartTitle);
begin
  FTitle.Assign(AValue);
end;

procedure TDACChart.SetTooltip(const AValue: TDACChartTooltip);
begin
  FTooltip.Assign(AValue);
end;

procedure TDACChart.SetXAxis(const AValue: TDACChartAxis);
begin
  FXAxis.Assign(AValue);
end;

procedure TDACChart.SetYAxis(const AValue: TDACChartAxis);
begin
  FYAxis.Assign(AValue);
end;

procedure TDACChart.ThemeChanged(Sender: TObject);
begin
  if (FThemeMode <> dtmInherit) and (Sender <> Self) then
    Exit;
  ApplyAppearance;
  ChartChanged;
end;

procedure TDACChart.UpdateDataLink;
begin
  if (FDataMode = cdmManual) or (FDataSource = nil) then
  begin
    FreeAndNil(FDataLink);
    Exit;
  end;
  if FDataLink = nil then
    FDataLink := TDACChartDataLink.Create(Self);
  FDataLink.DataSource := FDataSource;
end;

function TDACChart.TooltipForHit(const AHit: TDACChartHitArea): string;
var
  I: Integer;
  LValue: TDACChartValue;
  function FormatItem(const ASeriesIndex, APointIndex: Integer): string;
  var
    J: Integer;
    LPercent: Double;
    LSeries: TDACChartSeriesSnapshot;
    LItem: TDACChartValue;
  begin
    LSeries := FAnimationFrame.Series[ASeriesIndex];
    LItem := LSeries.Values[APointIndex];
    Result := FTooltip.Formatter;
    if Result = '' then
      Result := '{series}: {value}';
    LPercent := 0;
    if LSeries.ChartType in [ctPie, ctDoughnut] then
      for J := 0 to High(LSeries.Values) do
        if not LSeries.Values[J].IsNull and (LSeries.Values[J].Value > 0) then
          LPercent := LPercent + LSeries.Values[J].Value;
    if LPercent > 0 then
      LPercent := LItem.Value / LPercent * 100;
    Result := StringReplace(Result, '{series}', LSeries.Name, [rfReplaceAll]);
    Result := StringReplace(Result, '{category}', LItem.Category, [rfReplaceAll]);
    Result := StringReplace(Result, '{x}', FormatFloat('0.##', LItem.XValue), [rfReplaceAll]);
    Result := StringReplace(Result, '{value}', FormatFloat('#,##0.##', LItem.Value), [rfReplaceAll]);
    Result := StringReplace(Result, '{percent}', FormatFloat('0.##', LPercent), [rfReplaceAll]);
    Result := StringReplace(Result, '{label}', LItem.LabelText, [rfReplaceAll]);
    Result := StringReplace(Result, '{tooltip}', LItem.TooltipText, [rfReplaceAll]);
  end;
begin
  if (AHit.SeriesIndex < 0) or (AHit.SeriesIndex >= Length(FAnimationFrame.Series)) or
    (AHit.PointIndex < 0) or
    (AHit.PointIndex >= Length(FAnimationFrame.Series[AHit.SeriesIndex].Values)) then
    Exit('');
  if (FHoverTooltip <> '') and (FHoverTooltipRevision = FDataRevision) and
    (FHoverTooltipSeriesIndex = AHit.SeriesIndex) and
    (FHoverTooltipPointIndex = AHit.PointIndex) then
    Exit(FHoverTooltip);
  LValue := FAnimationFrame.Series[AHit.SeriesIndex].Values[AHit.PointIndex];
  if FTooltip.Mode = ctmAxis then
  begin
    Result := LValue.Category;
    for I := 0 to High(FAnimationFrame.Series) do
      if FAnimationFrame.Series[I].Visible and
        (AHit.PointIndex < Length(FAnimationFrame.Series[I].Values)) and
        not FAnimationFrame.Series[I].Values[AHit.PointIndex].IsNull then
        Result := Result + sLineBreak + FormatItem(I, AHit.PointIndex);
  end
  else if FTooltip.Mode = ctmSeries then
  begin
    Result := FAnimationFrame.Series[AHit.SeriesIndex].Name;
    for I := 0 to High(FAnimationFrame.Series[AHit.SeriesIndex].Values) do
      if not FAnimationFrame.Series[AHit.SeriesIndex].Values[I].IsNull then
        Result := Result + sLineBreak + FormatItem(AHit.SeriesIndex, I);
  end
  else
    Result := FormatItem(AHit.SeriesIndex, AHit.PointIndex);
  if Assigned(FOnTooltipFormat) then
    FOnTooltipFormat(Self, AHit.SeriesIndex, AHit.PointIndex, AHit.Category,
      AHit.Value, Result);
  FHoverTooltipRevision := FDataRevision;
  FHoverTooltipSeriesIndex := AHit.SeriesIndex;
  FHoverTooltipPointIndex := AHit.PointIndex;
end;

function TDACChart.TryHitTest(const APoint: TPointF;
  out AHit: TDACChartHitArea): Boolean;
var
  LAngle: Single;
  LDistance: Single;
  LDelta: Single;
  I: Integer;
  LStart: Single;
begin
  Result := False;
  { A legenda e desenhada sobre a area de plotagem; o hit-test deve respeitar
    essa ordem visual para que a alternancia de serie continue clicavel. }
  for I := FHitAreas.Count - 1 downto 0 do
  begin
    case FHitAreas[I].Shape of
      chsRectangle, chsLegend:
        Result := (APoint.X >= FHitAreas[I].Rect.Left) and
          (APoint.X <= FHitAreas[I].Rect.Right) and
          (APoint.Y >= FHitAreas[I].Rect.Top) and
          (APoint.Y <= FHitAreas[I].Rect.Bottom);
      chsCircle:
        Result := Hypot(APoint.X - FHitAreas[I].Center.X,
          APoint.Y - FHitAreas[I].Center.Y) <= FHitAreas[I].OuterRadius;
      chsPie:
        begin
          LDistance := Hypot(APoint.X - FHitAreas[I].Center.X,
            APoint.Y - FHitAreas[I].Center.Y);
          Result := (LDistance >= FHitAreas[I].InnerRadius) and
            (LDistance <= FHitAreas[I].OuterRadius);
          if Result then
          begin
            LAngle := RadToDeg(ArcTan2(APoint.Y - FHitAreas[I].Center.Y,
              APoint.X - FHitAreas[I].Center.X));
            if LAngle < 0 then
              LAngle := LAngle + 360;
            LStart := FHitAreas[I].StartAngle;
            while LStart < 0 do
              LStart := LStart + 360;
            while LStart >= 360 do
              LStart := LStart - 360;
            LDelta := LAngle - LStart;
            while LDelta < 0 do
              LDelta := LDelta + 360;
            while LDelta >= 360 do
              LDelta := LDelta - 360;
            Result := LDelta <= FHitAreas[I].SweepAngle;
          end;
        end;
    end;
    if Result then
    begin
      AHit := FHitAreas[I];
      Exit(True);
    end;
  end;
end;

procedure TDACChart.WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
begin
  { The Skia surface always covers the full client area. }
  AMessage.Result := 1;
end;

initialization
  GDACChartDataSetAdapters := TList<TDACChartDataSetAdapter>.Create;

finalization
  GDACChartDataSetAdapters.Free;

end.
