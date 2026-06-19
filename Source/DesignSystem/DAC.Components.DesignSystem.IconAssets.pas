unit DAC.Components.DesignSystem.IconAssets;

interface

uses
  System.UITypes;

type
  TDACIconKind = (
    mikNone,
    mikCheck,
    mikSearch,
    mikEye,
    mikClose,
    mikChevronDown,
    mikChevronRight,
    mikUser,
    mikWarning,
    mikDanger,
    mikAdd,
    mikAttachment,
    mikCopy,
    mikDownload,
    mikEdit,
    mikExternalLink,
    mikFilter,
    mikMinus,
    mikMoreHorizontal,
    mikMoreVertical,
    mikPrint,
    mikRefresh,
    mikSave,
    mikTrash,
    mikUpload,
    mikAreaRuler,
    mikBarn,
    mikCloudRain,
    mikFarm,
    mikField,
    mikHarvest,
    mikHerbicide,
    mikLeaf,
    mikLocationPin,
    mikPlot,
    mikSeedling,
    mikSoybean,
    mikSprayer,
    mikTemperature,
    mikTractor,
    mikCheckboxChecked,
    mikCheckboxUnchecked,
    mikClipboardCheck,
    mikDotsLoading,
    mikFlag,
    mikRadioChecked,
    mikRadioUnchecked,
    mikSlider,
    mikSpinner,
    mikTag,
    mikToggleOff,
    mikToggleOn,
    mikChartArea,
    mikChartBar,
    mikChartDonut,
    mikChartLine,
    mikClipboardOrder,
    mikInventoryStack,
    mikList,
    mikMoneyCircle,
    mikPackage,
    mikPercent,
    mikReport,
    mikShoppingCart,
    mikSortAsc,
    mikSortDesc,
    mikTableGrid,
    mikBell,
    mikBookOpen,
    mikCalendar,
    mikClock,
    mikCode,
    mikDocument,
    mikDocumentText,
    mikEyeOff,
    mikHelpCircle,
    mikInfoCircle,
    mikLock,
    mikPalette,
    mikSettings,
    mikStatusConnected,
    mikStatusDisconnected,
    mikSuccessCircle,
    mikThemeMoon,
    mikThemeSun,
    mikUnlock,
    mikUsers,
    mikArrowDown,
    mikArrowLeft,
    mikArrowRight,
    mikArrowUp,
    mikChevronLeft,
    mikChevronUp,
    mikCollapse,
    mikExpand,
    mikFirstPage,
    mikHome,
    mikLastPage,
    mikMenu,
    mikNextPage,
    mikPreviousPage,
    mikFilePdf,
    mikFitPage,
    mikFullscreen,
    mikPageSearch,
    mikZoomIn,
    mikZoomOut
  );

  TDACIconInfo = record
    Category: string;
    Name: string;
    DisplayName: string;
    RelativeFileName: string;
  end;

  TDACIconAssets = class
  public
    class function Info(const AKind: TDACIconKind): TDACIconInfo; static;
    class function SvgSource(const AKind: TDACIconKind;
      const AColor: TAlphaColor; const AAlpha: Byte = 255): string; static;
  end;

const
  DAC_ICON_ACTIONS_ADD = 'actions\add.svg';
  DAC_ICON_ACTIONS_ATTACHMENT = 'actions\attachment.svg';
  DAC_ICON_ACTIONS_CHECK = 'actions\check.svg';
  DAC_ICON_ACTIONS_CLOSE = 'actions\close.svg';
  DAC_ICON_ACTIONS_COPY = 'actions\copy.svg';
  DAC_ICON_ACTIONS_DOWNLOAD = 'actions\download.svg';
  DAC_ICON_ACTIONS_EDIT = 'actions\edit.svg';
  DAC_ICON_ACTIONS_EXTERNAL_LINK = 'actions\external-link.svg';
  DAC_ICON_ACTIONS_FILTER = 'actions\filter.svg';
  DAC_ICON_ACTIONS_MINUS = 'actions\minus.svg';
  DAC_ICON_ACTIONS_MORE_HORIZONTAL = 'actions\more-horizontal.svg';
  DAC_ICON_ACTIONS_MORE_VERTICAL = 'actions\more-vertical.svg';
  DAC_ICON_ACTIONS_PRINT = 'actions\print.svg';
  DAC_ICON_ACTIONS_REFRESH = 'actions\refresh.svg';
  DAC_ICON_ACTIONS_SAVE = 'actions\save.svg';
  DAC_ICON_ACTIONS_SEARCH = 'actions\search.svg';
  DAC_ICON_ACTIONS_TRASH = 'actions\trash.svg';
  DAC_ICON_ACTIONS_UPLOAD = 'actions\upload.svg';
  DAC_ICON_AGRICULTURE_AREA_RULER = 'agriculture\area-ruler.svg';
  DAC_ICON_AGRICULTURE_BARN = 'agriculture\barn.svg';
  DAC_ICON_AGRICULTURE_CLOUD_RAIN = 'agriculture\cloud-rain.svg';
  DAC_ICON_AGRICULTURE_FARM = 'agriculture\farm.svg';
  DAC_ICON_AGRICULTURE_FIELD = 'agriculture\field.svg';
  DAC_ICON_AGRICULTURE_HARVEST = 'agriculture\harvest.svg';
  DAC_ICON_AGRICULTURE_HERBICIDE = 'agriculture\herbicide.svg';
  DAC_ICON_AGRICULTURE_LEAF = 'agriculture\leaf.svg';
  DAC_ICON_AGRICULTURE_LOCATION_PIN = 'agriculture\location-pin.svg';
  DAC_ICON_AGRICULTURE_PLOT = 'agriculture\plot.svg';
  DAC_ICON_AGRICULTURE_SEEDLING = 'agriculture\seedling.svg';
  DAC_ICON_AGRICULTURE_SOYBEAN = 'agriculture\soybean.svg';
  DAC_ICON_AGRICULTURE_SPRAYER = 'agriculture\sprayer.svg';
  DAC_ICON_AGRICULTURE_TEMPERATURE = 'agriculture\temperature.svg';
  DAC_ICON_AGRICULTURE_TRACTOR = 'agriculture\tractor.svg';
  DAC_ICON_CONTROLS_CHECKBOX_CHECKED = 'controls\checkbox-checked.svg';
  DAC_ICON_CONTROLS_CHECKBOX_UNCHECKED = 'controls\checkbox-unchecked.svg';
  DAC_ICON_CONTROLS_CLIPBOARD_CHECK = 'controls\clipboard-check.svg';
  DAC_ICON_CONTROLS_DOTS_LOADING = 'controls\dots-loading.svg';
  DAC_ICON_CONTROLS_FLAG = 'controls\flag.svg';
  DAC_ICON_CONTROLS_RADIO_CHECKED = 'controls\radio-checked.svg';
  DAC_ICON_CONTROLS_RADIO_UNCHECKED = 'controls\radio-unchecked.svg';
  DAC_ICON_CONTROLS_SLIDER = 'controls\slider.svg';
  DAC_ICON_CONTROLS_SPINNER = 'controls\spinner.svg';
  DAC_ICON_CONTROLS_TAG = 'controls\tag.svg';
  DAC_ICON_CONTROLS_TOGGLE_OFF = 'controls\toggle-off.svg';
  DAC_ICON_CONTROLS_TOGGLE_ON = 'controls\toggle-on.svg';
  DAC_ICON_DATA_CHART_AREA = 'data\chart-area.svg';
  DAC_ICON_DATA_CHART_BAR = 'data\chart-bar.svg';
  DAC_ICON_DATA_CHART_DONUT = 'data\chart-donut.svg';
  DAC_ICON_DATA_CHART_LINE = 'data\chart-line.svg';
  DAC_ICON_DATA_CLIPBOARD_ORDER = 'data\clipboard-order.svg';
  DAC_ICON_DATA_INVENTORY_STACK = 'data\inventory-stack.svg';
  DAC_ICON_DATA_LIST = 'data\list.svg';
  DAC_ICON_DATA_MONEY_CIRCLE = 'data\money-circle.svg';
  DAC_ICON_DATA_PACKAGE = 'data\package.svg';
  DAC_ICON_DATA_PERCENT = 'data\percent.svg';
  DAC_ICON_DATA_REPORT = 'data\report.svg';
  DAC_ICON_DATA_SHOPPING_CART = 'data\shopping-cart.svg';
  DAC_ICON_DATA_SORT_ASC = 'data\sort-asc.svg';
  DAC_ICON_DATA_SORT_DESC = 'data\sort-desc.svg';
  DAC_ICON_DATA_TABLE_GRID = 'data\table-grid.svg';
  DAC_ICON_INTERFACE_BELL = 'interface\bell.svg';
  DAC_ICON_INTERFACE_BOOK_OPEN = 'interface\book-open.svg';
  DAC_ICON_INTERFACE_CALENDAR = 'interface\calendar.svg';
  DAC_ICON_INTERFACE_CLOCK = 'interface\clock.svg';
  DAC_ICON_INTERFACE_CODE = 'interface\code.svg';
  DAC_ICON_INTERFACE_DOCUMENT = 'interface\document.svg';
  DAC_ICON_INTERFACE_DOCUMENT_TEXT = 'interface\document-text.svg';
  DAC_ICON_INTERFACE_ERROR_CIRCLE = 'interface\error-circle.svg';
  DAC_ICON_INTERFACE_EYE = 'interface\eye.svg';
  DAC_ICON_INTERFACE_EYE_OFF = 'interface\eye-off.svg';
  DAC_ICON_INTERFACE_HELP_CIRCLE = 'interface\help-circle.svg';
  DAC_ICON_INTERFACE_INFO_CIRCLE = 'interface\info-circle.svg';
  DAC_ICON_INTERFACE_LOCK = 'interface\lock.svg';
  DAC_ICON_INTERFACE_PALETTE = 'interface\palette.svg';
  DAC_ICON_INTERFACE_SETTINGS = 'interface\settings.svg';
  DAC_ICON_INTERFACE_STATUS_CONNECTED = 'interface\status-connected.svg';
  DAC_ICON_INTERFACE_STATUS_DISCONNECTED = 'interface\status-disconnected.svg';
  DAC_ICON_INTERFACE_SUCCESS_CIRCLE = 'interface\success-circle.svg';
  DAC_ICON_INTERFACE_THEME_MOON = 'interface\theme-moon.svg';
  DAC_ICON_INTERFACE_THEME_SUN = 'interface\theme-sun.svg';
  DAC_ICON_INTERFACE_UNLOCK = 'interface\unlock.svg';
  DAC_ICON_INTERFACE_USER = 'interface\user.svg';
  DAC_ICON_INTERFACE_USERS = 'interface\users.svg';
  DAC_ICON_INTERFACE_WARNING_TRIANGLE = 'interface\warning-triangle.svg';
  DAC_ICON_NAVIGATION_ARROW_DOWN = 'navigation\arrow-down.svg';
  DAC_ICON_NAVIGATION_ARROW_LEFT = 'navigation\arrow-left.svg';
  DAC_ICON_NAVIGATION_ARROW_RIGHT = 'navigation\arrow-right.svg';
  DAC_ICON_NAVIGATION_ARROW_UP = 'navigation\arrow-up.svg';
  DAC_ICON_NAVIGATION_CHEVRON_DOWN = 'navigation\chevron-down.svg';
  DAC_ICON_NAVIGATION_CHEVRON_LEFT = 'navigation\chevron-left.svg';
  DAC_ICON_NAVIGATION_CHEVRON_RIGHT = 'navigation\chevron-right.svg';
  DAC_ICON_NAVIGATION_CHEVRON_UP = 'navigation\chevron-up.svg';
  DAC_ICON_NAVIGATION_COLLAPSE = 'navigation\collapse.svg';
  DAC_ICON_NAVIGATION_EXPAND = 'navigation\expand.svg';
  DAC_ICON_NAVIGATION_FIRST_PAGE = 'navigation\first-page.svg';
  DAC_ICON_NAVIGATION_HOME = 'navigation\home.svg';
  DAC_ICON_NAVIGATION_LAST_PAGE = 'navigation\last-page.svg';
  DAC_ICON_NAVIGATION_MENU = 'navigation\menu.svg';
  DAC_ICON_NAVIGATION_NEXT_PAGE = 'navigation\next-page.svg';
  DAC_ICON_NAVIGATION_PREVIOUS_PAGE = 'navigation\previous-page.svg';
  DAC_ICON_REPORT_VIEWER_FILE_PDF = 'report-viewer\file-pdf.svg';
  DAC_ICON_REPORT_VIEWER_FIT_PAGE = 'report-viewer\fit-page.svg';
  DAC_ICON_REPORT_VIEWER_FULLSCREEN = 'report-viewer\fullscreen.svg';
  DAC_ICON_REPORT_VIEWER_PAGE_SEARCH = 'report-viewer\page-search.svg';
  DAC_ICON_REPORT_VIEWER_ZOOM_IN = 'report-viewer\zoom-in.svg';
  DAC_ICON_REPORT_VIEWER_ZOOM_OUT = 'report-viewer\zoom-out.svg';

implementation

uses
  System.SysUtils;

const CCheckSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Confirmar" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <polyline points="20,62 46,86 100,30"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CSearchSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Pesquisar" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <circle cx="50" cy="50" r="28"/><line x1="70" y1="70" x2="100" y2="100"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CEyeSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Visualizar" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <path d="M12 60 C28 34 44 24 60 24 C76 24 92 34 108 60 C92 86 76 96 60 96 C44 96 28 86 12 60 Z"/' +
      '><circle cx="60" cy="60" r="16"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CCloseSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Fechar" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <line x1="26" y1="26" x2="94" y2="94"/><line x1="94" y1="26" x2="26" y2="94"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CChevronDownSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Chevron para baixo" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <polyline points="24,44 60,80 96,44"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CChevronRightSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Chevron para direita" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <polyline points="44,24 80,60 44,96"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CUserSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Usu?rio" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <circle cx="60" cy="38" r="18"/><path d="M24 102 C26 76 40 66 60 66 C80 66 94 76 96 102"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CWarningSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Alerta" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <polygon points="60,16 108,102 12,102"/><line x1="60" y1="44" x2="60" y2="72"/><circle cx="60" c' +
      'y="87" r="4" fill="currentColor" stroke="none"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CDangerSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Erro" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <circle cx="60" cy="60" r="46"/><line x1="40" y1="40" x2="80" y2="80"/><line x1="80" y1="40" x2=' +
      '"40" y2="80"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CAddSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Adicionar" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <line x1="60" y1="24" x2="60" y2="96"/><line x1="24" y1="60" x2="96" y2="60"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CAttachmentSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Anexo" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <path d="M43 62 L70 35 A17 17 0 0 1 94 59 L58 95 A27 27 0 0 1 20 57 L60 17"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CCopySvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Copiar" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <rect x="34" y="34" width="66" height="66" rx="7"/><rect x="20" y="20" width="66" height="66" rx' +
      '="7"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CDownloadSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Baixar / Exportar" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <line x1="60" y1="18" x2="60" y2="72"/><polyline points="38,52 60,74 82,52"/><path d="M24 84 V10' +
      '0 H96 V84"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CEditSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Editar" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <polygon points="24,88 30,66 76,20 100,44 54,90"/><line x1="67" y1="29" x2="91" y2="53"/><line x' +
      '1="30" y1="66" x2="54" y2="90"/><line x1="24" y1="96" x2="54" y2="90"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CExternalLinkSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Abrir externamente" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <rect x="18" y="34" width="68" height="68" rx="5"/><line x1="54" y1="66" x2="100" y2="20"/><poly' +
      'line points="70,20 100,20 100,50"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CFilterSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Filtrar" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <path d="M16 22 H104 L70 62 V94 L50 104 V62 Z"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CMinusSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Remover" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <line x1="24" y1="60" x2="96" y2="60"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CMoreHorizontalSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Mais op??es horizontal" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <circle cx="28" cy="60" r="6" fill="currentColor" stroke="none"/><circle cx="60" cy="60" r="6" f' +
      'ill="currentColor" stroke="none"/><circle cx="92" cy="60" r="6" fill="currentColor" stroke="none"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CMoreVerticalSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Mais op??es vertical" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <circle cx="60" cy="28" r="6" fill="currentColor" stroke="none"/><circle cx="60" cy="60" r="6" f' +
      'ill="currentColor" stroke="none"/><circle cx="60" cy="92" r="6" fill="currentColor" stroke="none"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CPrintSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Imprimir" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <rect x="30" y="16" width="60" height="34" rx="3"/><rect x="24" y="48" width="72" height="40" rx' +
      '="7"/><rect x="34" y="72" width="52" height="30" rx="3"/><circle cx="84" cy="61" r="3" fill="current' +
      'Color" stroke="none"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CRefreshSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Atualizar" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <path d="M94 44 A38 38 0 0 0 28 32"/><polyline points="26,18 26,38 46,38"/><path d="M26 76 A38 3' +
      '8 0 0 0 92 88"/><polyline points="94,102 94,82 74,82"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CSaveSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Salvar" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <path d="M22 18 H82 L98 34 V102 H22 Z"/><rect x="34" y="18" width="42" height="28" rx="2"/><rect' +
      ' x="36" y="68" width="48" height="34" rx="4"/><circle cx="60" cy="85" r="10"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CTrashSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Excluir" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <line x1="24" y1="32" x2="96" y2="32"/><line x1="46" y1="20" x2="74" y2="20"/><path d="M32 32 L3' +
      '8 100 H82 L88 32"/><line x1="50" y1="48" x2="52" y2="84"/><line x1="70" y1="48" x2="68" y2="84"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CUploadSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Enviar" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <line x1="60" y1="100" x2="60" y2="46"/><polyline points="38,66 60,44 82,66"/><path d="M24 34 V1' +
      '8 H96 V34"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CAreaRulerSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="?rea estimada" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <path d="M20 92 H92 V20"/><line x1="32" y1="92" x2="32" y2="82"/><line x1="46" y1="92" x2="46" y' +
      '2="76"/><line x1="60" y1="92" x2="60" y2="82"/><line x1="74" y1="92" x2="74" y2="76"/><line x1="92" ' +
      'y1="32" x2="82" y2="32"/><line x1="92" y1="46" x2="76" y2="46"/><line x1="92" y1="60" x2="82" y2="60' +
      '"/><line x1="92" y1="74" x2="76" y2="74"/><line x1="30" y1="30" x2="76" y2="76"/><polyline points="3' +
      '0,46 30,30 46,30"/><polyline points="60,76 76,76 76,60"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CBarnSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Galp?o / Celeiro" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <polyline points="14,52 60,18 106,52"/><path d="M24 46 V102 H96 V46"/><rect x="44" y="62" width=' +
      '"32" height="40" rx="2"/><line x1="44" y1="62" x2="76" y2="102"/><line x1="76" y1="62" x2="44" y2="1' +
      '02"/><rect x="34" y="48" width="12" height="12" rx="2"/><rect x="74" y="48" width="12" height="12" r' +
      'x="2"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CCloudRainSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Chuva" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <path d="M28 76 H90 A18 18 0 0 0 94 40 A30 30 0 0 0 38 34 A22 22 0 0 0 28 76 Z"/><line x1="38" y' +
      '1="88" x2="32" y2="102"/><line x1="60" y1="88" x2="54" y2="102"/><line x1="82" y1="88" x2="76" y2="1' +
      '02"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CFarmSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Fazenda" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <polyline points="14,54 46,26 78,54"/><path d="M24 48 V100 H68 V48"/><rect x="40" y="72" width="' +
      '16" height="28" rx="2"/><path d="M80 100 V46 H102 V100"/><line x1="80" y1="64" x2="102" y2="64"/><li' +
      'ne x1="80" y1="82" x2="102" y2="82"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CFieldSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Campo" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <line x1="16" y1="36" x2="104" y2="36"/><path d="M18 100 L42 36"/><path d="M46 100 L58 36"/><pat' +
      'h d="M74 100 L74 36"/><path d="M102 100 L90 36"/><line x1="22" y1="74" x2="98" y2="74"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CHarvestSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Colheita" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <line x1="60" y1="102" x2="60" y2="20"/><path d="M60 38 C44 36 34 28 30 18 C44 16 56 24 60 38"/>' +
      '<path d="M60 52 C76 50 86 42 90 32 C76 30 64 38 60 52"/><path d="M60 68 C44 66 34 58 30 48 C44 46 56' +
      ' 54 60 68"/><path d="M60 82 C76 80 86 72 90 62 C76 60 64 68 60 82"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CHerbicideSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Herbicida / Insumo" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <path d="M42 18 H78 V34 L88 48 V102 H32 V48 L42 34 Z"/><line x1="42" y1="34" x2="78" y2="34"/><p' +
      'ath d="M46 76 C48 60 60 52 76 54 C74 70 64 80 48 82"/><line x1="48" y1="82" x2="76" y2="54"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CLeafSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Folha / Cultura" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <path d="M94 20 C54 20 24 42 24 76 C24 94 38 104 54 96 C78 84 90 54 94 20 Z"/><path d="M30 92 C4' +
      '8 70 64 54 88 30"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CLocationPinSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Localiza??o" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <path d="M60 106 C60 106 94 72 94 46 A34 34 0 0 0 26 46 C26 72 60 106 60 106 Z"/><circle cx="60"' +
      ' cy="46" r="12"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CPlotSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Talh?o" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <rect x="16" y="20" width="88" height="80" rx="6"/><path d="M30 88 C40 70 38 48 52 30"/><path d=' +
      '"M58 92 C68 70 66 48 80 26"/><line x1="20" y1="60" x2="100" y2="60"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CSeedlingSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Muda / Plantio" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <line x1="60" y1="98" x2="60" y2="50"/><path d="M60 58 C44 54 32 42 30 26 C48 24 60 34 60 50"/><' +
      'path d="M60 70 C78 68 90 54 92 38 C74 36 62 46 60 62"/><line x1="24" y1="100" x2="96" y2="100"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CSoybeanSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Soja" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <path d="M30 82 C20 60 26 34 46 24 C66 14 88 24 94 44 C100 64 90 88 68 96 C52 102 38 94 30 82 Z"' +
      '/><ellipse cx="48" cy="48" rx="8" ry="10"/><ellipse cx="68" cy="56" rx="8" ry="10"/><ellipse cx="56"' +
      ' cy="76" rx="8" ry="10"/><path d="M20 100 C40 86 56 70 88 34"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CSprayerSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Pulverizador" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <circle cx="38" cy="84" r="14"/><circle cx="82" cy="84" r="14"/><rect x="42" y="42" width="36" h' +
      'eight="30" rx="6"/><line x1="18" y1="54" x2="42" y2="54"/><line x1="78" y1="54" x2="102" y2="54"/><l' +
      'ine x1="18" y1="54" x2="12" y2="68"/><line x1="102" y1="54" x2="108" y2="68"/><line x1="48" y1="72" ' +
      'x2="42" y2="84"/><line x1="72" y1="72" x2="78" y2="84"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CTemperatureSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Temperatura" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <path d="M50 72 V28 A10 10 0 0 1 70 28 V72 A22 22 0 1 1 50 72 Z"/><line x1="60" y1="40" x2="60" ' +
      'y2="82"/><circle cx="60" cy="88" r="8"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CTractorSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Trator" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <circle cx="36" cy="82" r="18"/><circle cx="88" cy="86" r="12"/><path d="M18 82 H22 L30 48 H62 L' +
      '76 68 H98 L104 86 H100"/><path d="M50 48 V30 H76 L84 68"/><line x1="58" y1="30" x2="58" y2="48"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CCheckboxCheckedSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Checkbox marcado" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <rect x="18" y="18" width="84" height="84" rx="10"/><polyline points="34,60 52,78 88,40"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CCheckboxUncheckedSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Checkbox desmarcado" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <rect x="18" y="18" width="84" height="84" rx="10"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CClipboardCheckSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Valida??o" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <rect x="28" y="24" width="64" height="80" rx="6"/><rect x="44" y="14" width="32" height="18" rx' +
      '="5"/><polyline points="42,66 54,78 80,50"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CDotsLoadingSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Carregamento por pontos" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <circle cx="28" cy="60" r="8" fill="currentColor" stroke="none"/><circle cx="60" cy="60" r="8" f' +
      'ill="currentColor" stroke="none"/><circle cx="92" cy="60" r="8" fill="currentColor" stroke="none"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CFlagSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Prioridade" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <line x1="30" y1="16" x2="30" y2="104"/><path d="M30 20 H88 L76 42 L90 64 H30 Z"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CRadioCheckedSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Radio selecionado" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <circle cx="60" cy="60" r="42"/><circle cx="60" cy="60" r="18" fill="currentColor" stroke="none"' +
      '/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CRadioUncheckedSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Radio n?o selecionado" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <circle cx="60" cy="60" r="42"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CSliderSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Slider" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <line x1="18" y1="60" x2="102" y2="60"/><line x1="18" y1="60" x2="70" y2="60" stroke-width="10"/' +
      '><circle cx="70" cy="60" r="14" fill="white"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CSpinnerSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Spinner" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <path d="M60 16 A44 44 0 1 1 22 38"/><polyline points="20,18 20,40 42,40"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CTagSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Tag" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <path d="M18 22 H68 L104 58 L60 102 L18 60 Z"/><circle cx="38" cy="42" r="6"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CToggleOffSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Toggle desativado" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <rect x="14" y="34" width="92" height="52" rx="26"/><circle cx="40" cy="60" r="18" fill="none"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CToggleOnSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Toggle ativado" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <rect x="14" y="34" width="92" height="52" rx="26"/><circle cx="80" cy="60" r="18" fill="current' +
      'Color"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CChartAreaSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Gr?fico de ?rea" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <line x1="18" y1="100" x2="104" y2="100"/><line x1="18" y1="100" x2="18" y2="20"/><path d="M24 8' +
      '2 L44 54 L60 68 L82 34 L100 48 V100 H24 Z" fill="currentColor" fill-opacity="0.18"/><polyline points' +
      '="24,82 44,54 60,68 82,34 100,48"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CChartBarSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Gr?fico de barras" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <line x1="20" y1="100" x2="104" y2="100"/><line x1="20" y1="100" x2="20" y2="20"/><rect x="34" y' +
      '="66" width="14" height="34" rx="2"/><rect x="56" y="46" width="14" height="54" rx="2"/><rect x="78"' +
      ' y="28" width="14" height="72" rx="2"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CChartDonutSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Gr?fico de rosca" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <circle cx="60" cy="60" r="42"/><path d="M60 18 A42 42 0 0 1 100 48"/><line x1="60" y1="60" x2="' +
      '60" y2="18"/><line x1="60" y1="60" x2="100" y2="48"/><circle cx="60" cy="60" r="18"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CChartLineSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Gr?fico de linha" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <line x1="20" y1="100" x2="104" y2="100"/><line x1="20" y1="100" x2="20" y2="20"/><polyline poin' +
      'ts="30,78 48,58 64,68 82,38 100,50"/><circle cx="30" cy="78" r="4" fill="currentColor" stroke="none"' +
      '/><circle cx="48" cy="58" r="4" fill="currentColor" stroke="none"/><circle cx="64" cy="68" r="4" fil' +
      'l="currentColor" stroke="none"/><circle cx="82" cy="38" r="4" fill="currentColor" stroke="none"/><ci' +
      'rcle cx="100" cy="50" r="4" fill="currentColor" stroke="none"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CClipboardOrderSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Ordem de servi?o" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <rect x="28" y="24" width="64" height="80" rx="6"/><rect x="44" y="14" width="32" height="18" rx' +
      '="5"/><line x1="42" y1="50" x2="78" y2="50"/><line x1="42" y1="68" x2="78" y2="68"/><line x1="42" y1' +
      '="86" x2="66" y2="86"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CInventoryStackSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Estoque" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <rect x="22" y="20" width="76" height="24" rx="4"/><rect x="22" y="48" width="76" height="24" rx' +
      '="4"/><rect x="22" y="76" width="76" height="24" rx="4"/><circle cx="34" cy="32" r="3" fill="current' +
      'Color" stroke="none"/><circle cx="34" cy="60" r="3" fill="currentColor" stroke="none"/><circle cx="3' +
      '4" cy="88" r="3" fill="currentColor" stroke="none"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CListSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Lista" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <circle cx="24" cy="32" r="4" fill="currentColor" stroke="none"/><circle cx="24" cy="60" r="4" f' +
      'ill="currentColor" stroke="none"/><circle cx="24" cy="88" r="4" fill="currentColor" stroke="none"/><' +
      'line x1="40" y1="32" x2="102" y2="32"/><line x1="40" y1="60" x2="102" y2="60"/><line x1="40" y1="88"' +
      ' x2="102" y2="88"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CMoneyCircleSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Financeiro" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <circle cx="60" cy="60" r="46"/><path d="M74 40 C68 34 52 34 46 42 C39 52 48 58 60 60 C72 62 81 ' +
      '68 74 80 C68 90 50 88 44 82"/><line x1="60" y1="28" x2="60" y2="92"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CPackageSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Produto / Caixa" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <polygon points="60,16 102,38 60,60 18,38"/><polyline points="18,38 18,82 60,104 60,60"/><polyli' +
      'ne points="102,38 102,82 60,104"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CPercentSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Percentual" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <circle cx="36" cy="36" r="12"/><circle cx="84" cy="84" r="12"/><line x1="30" y1="94" x2="90" y2' +
      '="26"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CReportSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Relat?rio" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <path d="M26 14 H74 L96 36 V106 H26 Z"/><polyline points="74,14 74,36 96,36"/><line x1="42" y1="' +
      '88" x2="42" y2="72"/><line x1="58" y1="88" x2="58" y2="60"/><line x1="74" y1="88" x2="74" y2="48"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CShoppingCartSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Pedidos" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <path d="M18 24 H30 L40 74 H88 L100 40 H36"/><circle cx="48" cy="94" r="7"/><circle cx="82" cy="' +
      '94" r="7"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CSortAscSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Ordenar crescente" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <line x1="28" y1="24" x2="28" y2="96"/><polyline points="16,38 28,24 40,38"/><line x1="56" y1="3' +
      '4" x2="96" y2="34"/><line x1="56" y1="58" x2="86" y2="58"/><line x1="56" y1="82" x2="76" y2="82"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CSortDescSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Ordenar decrescente" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <line x1="28" y1="24" x2="28" y2="96"/><polyline points="16,82 28,96 40,82"/><line x1="56" y1="3' +
      '4" x2="76" y2="34"/><line x1="56" y1="58" x2="86" y2="58"/><line x1="56" y1="82" x2="96" y2="82"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CTableGridSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Tabela / Grid" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <rect x="16" y="20" width="88" height="80" rx="4"/><line x1="16" y1="46" x2="104" y2="46"/><line' +
      ' x1="16" y1="72" x2="104" y2="72"/><line x1="46" y1="20" x2="46" y2="100"/><line x1="76" y1="20" x2=' +
      '"76" y2="100"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CBellSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Notifica??o" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <path d="M28 82 H92 L84 70 V48 A24 24 0 0 0 36 48 V70 Z"/><path d="M50 94 A11 11 0 0 0 70 94"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CBookOpenSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Documenta??o" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <path d="M14 24 C32 20 46 24 60 34 V100 C46 90 32 88 14 92 Z"/><path d="M106 24 C88 20 74 24 60 ' +
      '34 V100 C74 90 88 88 106 92 Z"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CCalendarSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Calend?rio" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <rect x="18" y="24" width="84" height="78" rx="8"/><line x1="18" y1="48" x2="102" y2="48"/><line' +
      ' x1="38" y1="16" x2="38" y2="34"/><line x1="82" y1="16" x2="82" y2="34"/><circle cx="38" cy="68" r="' +
      '4" fill="currentColor" stroke="none"/><circle cx="60" cy="68" r="4" fill="currentColor" stroke="none' +
      '"/><circle cx="82" cy="68" r="4" fill="currentColor" stroke="none"/><circle cx="38" cy="88" r="4" fi' +
      'll="currentColor" stroke="none"/><circle cx="60" cy="88" r="4" fill="currentColor" stroke="none"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CClockSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Rel?gio" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <circle cx="60" cy="60" r="44"/><line x1="60" y1="34" x2="60" y2="62"/><line x1="60" y1="62" x2=' +
      '"82" y2="74"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CCodeSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Exemplos / C?digo" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <polyline points="42,30 18,60 42,90"/><polyline points="78,30 102,60 78,90"/><line x1="68" y1="2' +
      '2" x2="52" y2="98"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CDocumentSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Documento" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <path d="M28 14 H72 L94 36 V106 H28 Z"/><polyline points="72,14 72,36 94,36"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CDocumentTextSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Documento com texto" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <path d="M28 14 H72 L94 36 V106 H28 Z"/><polyline points="72,14 72,36 94,36"/><line x1="42" y1="' +
      '58" x2="80" y2="58"/><line x1="42" y1="74" x2="80" y2="74"/><line x1="42" y1="90" x2="68" y2="90"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CEyeOffSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Ocultar" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <path d="M18 48 C30 32 44 24 60 24 C78 24 94 36 108 60 C102 70 95 78 87 84"/><path d="M74 92 C69' +
      ' 95 65 96 60 96 C42 96 26 84 12 60 C17 52 22 45 28 40"/><path d="M46 46 A18 18 0 0 0 74 74"/><line x' +
      '1="18" y1="18" x2="102" y2="102"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CHelpCircleSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Ajuda" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <circle cx="60" cy="60" r="46"/><path d="M44 46 A17 17 0 0 1 76 54 C76 68 60 68 60 78"/><circle ' +
      'cx="60" cy="92" r="4" fill="currentColor" stroke="none"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CInfoCircleSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Informa??o" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <circle cx="60" cy="60" r="46"/><line x1="60" y1="54" x2="60" y2="84"/><circle cx="60" cy="36" r' +
      '="4" fill="currentColor" stroke="none"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CLockSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Bloqueado" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <rect x="24" y="50" width="72" height="54" rx="8"/><path d="M38 50 V38 A22 22 0 0 1 82 38 V50"/>' +
      '<circle cx="60" cy="76" r="5"/><line x1="60" y1="81" x2="60" y2="92"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CPaletteSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Temas / Paleta" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <path d="M60 18 C34 18 16 36 16 60 C16 84 34 102 56 102 C68 102 72 92 68 84 C64 76 72 70 82 72 C' +
      '96 74 104 66 104 54 C104 34 84 18 60 18 Z"/><circle cx="38" cy="50" r="5" fill="currentColor" stroke' +
      '="none"/><circle cx="56" cy="38" r="5" fill="currentColor" stroke="none"/><circle cx="76" cy="42" r=' +
      '"5" fill="currentColor" stroke="none"/><circle cx="86" cy="58" r="5" fill="currentColor" stroke="non' +
      'e"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CSettingsSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Configura??es" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <circle cx="60" cy="60" r="15"/><path d="M60 18 V30 M60 90 V102 M18 60 H30 M90 60 H102 M30 30 L3' +
      '9 39 M81 81 L90 90 M90 30 L81 39 M39 81 L30 90"/><circle cx="60" cy="60" r="38"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CStatusConnectedSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Conectado" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <circle cx="60" cy="82" r="7" fill="currentColor" stroke="none"/><path d="M34 62 A36 36 0 0 1 86' +
      ' 62"/><path d="M44 72 A22 22 0 0 1 76 72"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CStatusDisconnectedSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Desconectado" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <circle cx="60" cy="82" r="7" fill="currentColor" stroke="none"/><path d="M34 62 A36 36 0 0 1 86' +
      ' 62"/><path d="M44 72 A22 22 0 0 1 76 72"/><line x1="22" y1="22" x2="98" y2="98"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CSuccessCircleSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Sucesso" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <circle cx="60" cy="60" r="46"/><polyline points="34,62 52,80 88,40"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CThemeMoonSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Tema escuro / Lua" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <path d="M86 86 C54 92 30 68 36 36 C40 20 50 14 58 12 C48 34 54 60 74 72 C84 78 94 80 104 78 C10' +
      '0 82 94 85 86 86 Z"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CThemeSunSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Tema claro / Sol" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <circle cx="60" cy="60" r="18"/><line x1="60" y1="14" x2="60" y2="28"/><line x1="60" y1="92" x2=' +
      '"60" y2="106"/><line x1="14" y1="60" x2="28" y2="60"/><line x1="92" y1="60" x2="106" y2="60"/><line ' +
      'x1="28" y1="28" x2="38" y2="38"/><line x1="82" y1="82" x2="92" y2="92"/><line x1="92" y1="28" x2="82' +
      '" y2="38"/><line x1="38" y1="82" x2="28" y2="92"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CUnlockSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Desbloqueado" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <rect x="24" y="50" width="72" height="54" rx="8"/><path d="M82 50 V38 A22 22 0 0 0 40 30"/><cir' +
      'cle cx="60" cy="76" r="5"/><line x1="60" y1="81" x2="60" y2="92"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CUsersSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Usu?rios" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <circle cx="48" cy="38" r="16"/><circle cx="82" cy="44" r="13"/><path d="M16 100 C18 76 30 66 48' +
      ' 66 C66 66 78 76 80 100"/><path d="M72 72 C89 72 100 82 102 100"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CArrowDownSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Seta para baixo" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <line x1="60" y1="20" x2="60" y2="96"/><polyline points="34,70 60,96 86,70"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CArrowLeftSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Seta para esquerda" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <line x1="100" y1="60" x2="24" y2="60"/><polyline points="50,34 24,60 50,86"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CArrowRightSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Seta para direita" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <line x1="20" y1="60" x2="96" y2="60"/><polyline points="70,34 96,60 70,86"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CArrowUpSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Seta para cima" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <line x1="60" y1="100" x2="60" y2="24"/><polyline points="34,50 60,24 86,50"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CChevronLeftSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Chevron para esquerda" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <polyline points="76,24 40,60 76,96"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CChevronUpSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Chevron para cima" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <polyline points="24,76 60,40 96,76"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CCollapseSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Recolher" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <path d="M20 50 H50 V20"/><line x1="50" y1="50" x2="24" y2="24"/><path d="M100 50 H70 V20"/><lin' +
      'e x1="70" y1="50" x2="96" y2="24"/><path d="M20 70 H50 V100"/><line x1="50" y1="70" x2="24" y2="96"/' +
      '><path d="M100 70 H70 V100"/><line x1="70" y1="70" x2="96" y2="96"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CExpandSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Expandir" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <path d="M48 22 H22 V48"/><line x1="22" y1="22" x2="50" y2="50"/><path d="M72 22 H98 V48"/><line' +
      ' x1="98" y1="22" x2="70" y2="50"/><path d="M22 72 V98 H48"/><line x1="22" y1="98" x2="50" y2="70"/><' +
      'path d="M98 72 V98 H72"/><line x1="98" y1="98" x2="70" y2="70"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CFirstPageSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Primeira p?gina" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <line x1="26" y1="24" x2="26" y2="96"/><line x1="92" y1="60" x2="38" y2="60"/><polyline points="' +
      '60,36 36,60 60,84"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CHomeSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="In?cio / Fazenda" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <polyline points="16,56 60,18 104,56"/><path d="M28 50 V102 H92 V50"/><rect x="50" y="70" width=' +
      '"20" height="32" rx="2"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CLastPageSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="?ltima p?gina" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <line x1="94" y1="24" x2="94" y2="96"/><line x1="28" y1="60" x2="82" y2="60"/><polyline points="' +
      '60,36 84,60 60,84"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CMenuSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Menu" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <line x1="22" y1="34" x2="98" y2="34"/><line x1="22" y1="60" x2="98" y2="60"/><line x1="22" y1="' +
      '86" x2="98" y2="86"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CNextPageSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Pr?xima p?gina" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <line x1="26" y1="60" x2="88" y2="60"/><polyline points="66,36 90,60 66,84"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CPreviousPageSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="P?gina anterior" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <line x1="94" y1="60" x2="32" y2="60"/><polyline points="54,36 30,60 54,84"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CFilePdfSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Arquivo PDF" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <path d="M26 14 H72 L96 38 V106 H26 Z"/><polyline points="72,14 72,38 96,38"/><path d="M38 86 V5' +
      '8 H48 A9 9 0 0 1 48 76 H38"/><path d="M58 58 V86 H66 A14 14 0 0 0 66 58 Z"/><path d="M82 86 V58 H98 ' +
      'M82 72 H94"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CFitPageSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Ajustar p?gina" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <rect x="28" y="16" width="64" height="88" rx="4"/><path d="M42 36 H36 V42"/><path d="M78 36 H84' +
      ' V42"/><path d="M42 84 H36 V78"/><path d="M78 84 H84 V78"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CFullscreenSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Tela cheia" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <path d="M18 46 V18 H46"/><path d="M74 18 H102 V46"/><path d="M18 74 V102 H46"/><path d="M74 102' +
      ' H102 V74"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CPageSearchSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Pesquisar no relat?rio" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <path d="M24 14 H68 L88 34 V70"/><polyline points="68,14 68,34 88,34"/><circle cx="70" cy="78" r' +
      '="18"/><line x1="84" y1="92" x2="104" y2="108"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CZoomInSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Aumentar zoom" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <circle cx="48" cy="48" r="28"/><line x1="68" y1="68" x2="100" y2="100"/><line x1="48" y1="34" x' +
      '2="48" y2="62"/><line x1="34" y1="48" x2="62" y2="48"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

const CZoomOutSvg =
      '<?xml version="1.0" encoding="UTF-8"?>' + #13#10 +
      '<svg xmlns="http://www.w3.org/2000/svg" width="120" height="120" viewBox="0 0 120 120"' + #13#10 +
      '     fill="none" role="img" aria-label="Reduzir zoom" style="color:#2F9E22">' + #13#10 +
      '  <g stroke="currentColor" stroke-width="6" stroke-linecap="round" stroke-linejoin="round">' + #13#10 +
      '    <circle cx="48" cy="48" r="28"/><line x1="68" y1="68" x2="100" y2="100"/><line x1="34" y1="48" x' +
      '2="62" y2="48"/>' + #13#10 +
      '  </g>' + #13#10 +
      '</svg>';

function AlphaColorToSvg(const AColor: TAlphaColor): string;
begin
  Result := '#' + IntToHex(Cardinal(AColor) and $00FFFFFF, 6);
end;

function SvgOpacity(const AAlpha: Byte): string;
var
  LFormat: TFormatSettings;
begin
  LFormat := TFormatSettings.Create;
  LFormat.DecimalSeparator := '.';
  Result := FloatToStrF(AAlpha / 255, ffFixed, 3, 2, LFormat);
end;

function RawSvg(const AKind: TDACIconKind): string;
begin
  case AKind of
    mikCheck: Result := CCheckSvg;
    mikSearch: Result := CSearchSvg;
    mikEye: Result := CEyeSvg;
    mikClose: Result := CCloseSvg;
    mikChevronDown: Result := CChevronDownSvg;
    mikChevronRight: Result := CChevronRightSvg;
    mikUser: Result := CUserSvg;
    mikWarning: Result := CWarningSvg;
    mikDanger: Result := CDangerSvg;
    mikAdd: Result := CAddSvg;
    mikAttachment: Result := CAttachmentSvg;
    mikCopy: Result := CCopySvg;
    mikDownload: Result := CDownloadSvg;
    mikEdit: Result := CEditSvg;
    mikExternalLink: Result := CExternalLinkSvg;
    mikFilter: Result := CFilterSvg;
    mikMinus: Result := CMinusSvg;
    mikMoreHorizontal: Result := CMoreHorizontalSvg;
    mikMoreVertical: Result := CMoreVerticalSvg;
    mikPrint: Result := CPrintSvg;
    mikRefresh: Result := CRefreshSvg;
    mikSave: Result := CSaveSvg;
    mikTrash: Result := CTrashSvg;
    mikUpload: Result := CUploadSvg;
    mikAreaRuler: Result := CAreaRulerSvg;
    mikBarn: Result := CBarnSvg;
    mikCloudRain: Result := CCloudRainSvg;
    mikFarm: Result := CFarmSvg;
    mikField: Result := CFieldSvg;
    mikHarvest: Result := CHarvestSvg;
    mikHerbicide: Result := CHerbicideSvg;
    mikLeaf: Result := CLeafSvg;
    mikLocationPin: Result := CLocationPinSvg;
    mikPlot: Result := CPlotSvg;
    mikSeedling: Result := CSeedlingSvg;
    mikSoybean: Result := CSoybeanSvg;
    mikSprayer: Result := CSprayerSvg;
    mikTemperature: Result := CTemperatureSvg;
    mikTractor: Result := CTractorSvg;
    mikCheckboxChecked: Result := CCheckboxCheckedSvg;
    mikCheckboxUnchecked: Result := CCheckboxUncheckedSvg;
    mikClipboardCheck: Result := CClipboardCheckSvg;
    mikDotsLoading: Result := CDotsLoadingSvg;
    mikFlag: Result := CFlagSvg;
    mikRadioChecked: Result := CRadioCheckedSvg;
    mikRadioUnchecked: Result := CRadioUncheckedSvg;
    mikSlider: Result := CSliderSvg;
    mikSpinner: Result := CSpinnerSvg;
    mikTag: Result := CTagSvg;
    mikToggleOff: Result := CToggleOffSvg;
    mikToggleOn: Result := CToggleOnSvg;
    mikChartArea: Result := CChartAreaSvg;
    mikChartBar: Result := CChartBarSvg;
    mikChartDonut: Result := CChartDonutSvg;
    mikChartLine: Result := CChartLineSvg;
    mikClipboardOrder: Result := CClipboardOrderSvg;
    mikInventoryStack: Result := CInventoryStackSvg;
    mikList: Result := CListSvg;
    mikMoneyCircle: Result := CMoneyCircleSvg;
    mikPackage: Result := CPackageSvg;
    mikPercent: Result := CPercentSvg;
    mikReport: Result := CReportSvg;
    mikShoppingCart: Result := CShoppingCartSvg;
    mikSortAsc: Result := CSortAscSvg;
    mikSortDesc: Result := CSortDescSvg;
    mikTableGrid: Result := CTableGridSvg;
    mikBell: Result := CBellSvg;
    mikBookOpen: Result := CBookOpenSvg;
    mikCalendar: Result := CCalendarSvg;
    mikClock: Result := CClockSvg;
    mikCode: Result := CCodeSvg;
    mikDocument: Result := CDocumentSvg;
    mikDocumentText: Result := CDocumentTextSvg;
    mikEyeOff: Result := CEyeOffSvg;
    mikHelpCircle: Result := CHelpCircleSvg;
    mikInfoCircle: Result := CInfoCircleSvg;
    mikLock: Result := CLockSvg;
    mikPalette: Result := CPaletteSvg;
    mikSettings: Result := CSettingsSvg;
    mikStatusConnected: Result := CStatusConnectedSvg;
    mikStatusDisconnected: Result := CStatusDisconnectedSvg;
    mikSuccessCircle: Result := CSuccessCircleSvg;
    mikThemeMoon: Result := CThemeMoonSvg;
    mikThemeSun: Result := CThemeSunSvg;
    mikUnlock: Result := CUnlockSvg;
    mikUsers: Result := CUsersSvg;
    mikArrowDown: Result := CArrowDownSvg;
    mikArrowLeft: Result := CArrowLeftSvg;
    mikArrowRight: Result := CArrowRightSvg;
    mikArrowUp: Result := CArrowUpSvg;
    mikChevronLeft: Result := CChevronLeftSvg;
    mikChevronUp: Result := CChevronUpSvg;
    mikCollapse: Result := CCollapseSvg;
    mikExpand: Result := CExpandSvg;
    mikFirstPage: Result := CFirstPageSvg;
    mikHome: Result := CHomeSvg;
    mikLastPage: Result := CLastPageSvg;
    mikMenu: Result := CMenuSvg;
    mikNextPage: Result := CNextPageSvg;
    mikPreviousPage: Result := CPreviousPageSvg;
    mikFilePdf: Result := CFilePdfSvg;
    mikFitPage: Result := CFitPageSvg;
    mikFullscreen: Result := CFullscreenSvg;
    mikPageSearch: Result := CPageSearchSvg;
    mikZoomIn: Result := CZoomInSvg;
    mikZoomOut: Result := CZoomOutSvg;
  else
    Result := '';
  end;
end;

class function TDACIconAssets.Info(
  const AKind: TDACIconKind): TDACIconInfo;
begin
  case AKind of
    mikCheck:
      begin
        Result.Category := 'actions';
        Result.Name := 'check';
        Result.DisplayName := 'Check';
        Result.RelativeFileName := 'actions\check.svg';
      end;
    mikSearch:
      begin
        Result.Category := 'actions';
        Result.Name := 'search';
        Result.DisplayName := 'Search';
        Result.RelativeFileName := 'actions\search.svg';
      end;
    mikEye:
      begin
        Result.Category := 'interface';
        Result.Name := 'eye';
        Result.DisplayName := 'Eye';
        Result.RelativeFileName := 'interface\eye.svg';
      end;
    mikClose:
      begin
        Result.Category := 'actions';
        Result.Name := 'close';
        Result.DisplayName := 'Close';
        Result.RelativeFileName := 'actions\close.svg';
      end;
    mikChevronDown:
      begin
        Result.Category := 'navigation';
        Result.Name := 'chevron-down';
        Result.DisplayName := 'Chevron Down';
        Result.RelativeFileName := 'navigation\chevron-down.svg';
      end;
    mikChevronRight:
      begin
        Result.Category := 'navigation';
        Result.Name := 'chevron-right';
        Result.DisplayName := 'Chevron Right';
        Result.RelativeFileName := 'navigation\chevron-right.svg';
      end;
    mikUser:
      begin
        Result.Category := 'interface';
        Result.Name := 'user';
        Result.DisplayName := 'User';
        Result.RelativeFileName := 'interface\user.svg';
      end;
    mikWarning:
      begin
        Result.Category := 'interface';
        Result.Name := 'warning-triangle';
        Result.DisplayName := 'Warning Triangle';
        Result.RelativeFileName := 'interface\warning-triangle.svg';
      end;
    mikDanger:
      begin
        Result.Category := 'interface';
        Result.Name := 'error-circle';
        Result.DisplayName := 'Error Circle';
        Result.RelativeFileName := 'interface\error-circle.svg';
      end;
    mikAdd:
      begin
        Result.Category := 'actions';
        Result.Name := 'add';
        Result.DisplayName := 'Add';
        Result.RelativeFileName := 'actions\add.svg';
      end;
    mikAttachment:
      begin
        Result.Category := 'actions';
        Result.Name := 'attachment';
        Result.DisplayName := 'Attachment';
        Result.RelativeFileName := 'actions\attachment.svg';
      end;
    mikCopy:
      begin
        Result.Category := 'actions';
        Result.Name := 'copy';
        Result.DisplayName := 'Copy';
        Result.RelativeFileName := 'actions\copy.svg';
      end;
    mikDownload:
      begin
        Result.Category := 'actions';
        Result.Name := 'download';
        Result.DisplayName := 'Download';
        Result.RelativeFileName := 'actions\download.svg';
      end;
    mikEdit:
      begin
        Result.Category := 'actions';
        Result.Name := 'edit';
        Result.DisplayName := 'Edit';
        Result.RelativeFileName := 'actions\edit.svg';
      end;
    mikExternalLink:
      begin
        Result.Category := 'actions';
        Result.Name := 'external-link';
        Result.DisplayName := 'External Link';
        Result.RelativeFileName := 'actions\external-link.svg';
      end;
    mikFilter:
      begin
        Result.Category := 'actions';
        Result.Name := 'filter';
        Result.DisplayName := 'Filter';
        Result.RelativeFileName := 'actions\filter.svg';
      end;
    mikMinus:
      begin
        Result.Category := 'actions';
        Result.Name := 'minus';
        Result.DisplayName := 'Minus';
        Result.RelativeFileName := 'actions\minus.svg';
      end;
    mikMoreHorizontal:
      begin
        Result.Category := 'actions';
        Result.Name := 'more-horizontal';
        Result.DisplayName := 'More Horizontal';
        Result.RelativeFileName := 'actions\more-horizontal.svg';
      end;
    mikMoreVertical:
      begin
        Result.Category := 'actions';
        Result.Name := 'more-vertical';
        Result.DisplayName := 'More Vertical';
        Result.RelativeFileName := 'actions\more-vertical.svg';
      end;
    mikPrint:
      begin
        Result.Category := 'actions';
        Result.Name := 'print';
        Result.DisplayName := 'Print';
        Result.RelativeFileName := 'actions\print.svg';
      end;
    mikRefresh:
      begin
        Result.Category := 'actions';
        Result.Name := 'refresh';
        Result.DisplayName := 'Refresh';
        Result.RelativeFileName := 'actions\refresh.svg';
      end;
    mikSave:
      begin
        Result.Category := 'actions';
        Result.Name := 'save';
        Result.DisplayName := 'Save';
        Result.RelativeFileName := 'actions\save.svg';
      end;
    mikTrash:
      begin
        Result.Category := 'actions';
        Result.Name := 'trash';
        Result.DisplayName := 'Trash';
        Result.RelativeFileName := 'actions\trash.svg';
      end;
    mikUpload:
      begin
        Result.Category := 'actions';
        Result.Name := 'upload';
        Result.DisplayName := 'Upload';
        Result.RelativeFileName := 'actions\upload.svg';
      end;
    mikAreaRuler:
      begin
        Result.Category := 'agriculture';
        Result.Name := 'area-ruler';
        Result.DisplayName := 'Area Ruler';
        Result.RelativeFileName := 'agriculture\area-ruler.svg';
      end;
    mikBarn:
      begin
        Result.Category := 'agriculture';
        Result.Name := 'barn';
        Result.DisplayName := 'Barn';
        Result.RelativeFileName := 'agriculture\barn.svg';
      end;
    mikCloudRain:
      begin
        Result.Category := 'agriculture';
        Result.Name := 'cloud-rain';
        Result.DisplayName := 'Cloud Rain';
        Result.RelativeFileName := 'agriculture\cloud-rain.svg';
      end;
    mikFarm:
      begin
        Result.Category := 'agriculture';
        Result.Name := 'farm';
        Result.DisplayName := 'Farm';
        Result.RelativeFileName := 'agriculture\farm.svg';
      end;
    mikField:
      begin
        Result.Category := 'agriculture';
        Result.Name := 'field';
        Result.DisplayName := 'Field';
        Result.RelativeFileName := 'agriculture\field.svg';
      end;
    mikHarvest:
      begin
        Result.Category := 'agriculture';
        Result.Name := 'harvest';
        Result.DisplayName := 'Harvest';
        Result.RelativeFileName := 'agriculture\harvest.svg';
      end;
    mikHerbicide:
      begin
        Result.Category := 'agriculture';
        Result.Name := 'herbicide';
        Result.DisplayName := 'Herbicide';
        Result.RelativeFileName := 'agriculture\herbicide.svg';
      end;
    mikLeaf:
      begin
        Result.Category := 'agriculture';
        Result.Name := 'leaf';
        Result.DisplayName := 'Leaf';
        Result.RelativeFileName := 'agriculture\leaf.svg';
      end;
    mikLocationPin:
      begin
        Result.Category := 'agriculture';
        Result.Name := 'location-pin';
        Result.DisplayName := 'Location Pin';
        Result.RelativeFileName := 'agriculture\location-pin.svg';
      end;
    mikPlot:
      begin
        Result.Category := 'agriculture';
        Result.Name := 'plot';
        Result.DisplayName := 'Plot';
        Result.RelativeFileName := 'agriculture\plot.svg';
      end;
    mikSeedling:
      begin
        Result.Category := 'agriculture';
        Result.Name := 'seedling';
        Result.DisplayName := 'Seedling';
        Result.RelativeFileName := 'agriculture\seedling.svg';
      end;
    mikSoybean:
      begin
        Result.Category := 'agriculture';
        Result.Name := 'soybean';
        Result.DisplayName := 'Soybean';
        Result.RelativeFileName := 'agriculture\soybean.svg';
      end;
    mikSprayer:
      begin
        Result.Category := 'agriculture';
        Result.Name := 'sprayer';
        Result.DisplayName := 'Sprayer';
        Result.RelativeFileName := 'agriculture\sprayer.svg';
      end;
    mikTemperature:
      begin
        Result.Category := 'agriculture';
        Result.Name := 'temperature';
        Result.DisplayName := 'Temperature';
        Result.RelativeFileName := 'agriculture\temperature.svg';
      end;
    mikTractor:
      begin
        Result.Category := 'agriculture';
        Result.Name := 'tractor';
        Result.DisplayName := 'Tractor';
        Result.RelativeFileName := 'agriculture\tractor.svg';
      end;
    mikCheckboxChecked:
      begin
        Result.Category := 'controls';
        Result.Name := 'checkbox-checked';
        Result.DisplayName := 'Checkbox Checked';
        Result.RelativeFileName := 'controls\checkbox-checked.svg';
      end;
    mikCheckboxUnchecked:
      begin
        Result.Category := 'controls';
        Result.Name := 'checkbox-unchecked';
        Result.DisplayName := 'Checkbox Unchecked';
        Result.RelativeFileName := 'controls\checkbox-unchecked.svg';
      end;
    mikClipboardCheck:
      begin
        Result.Category := 'controls';
        Result.Name := 'clipboard-check';
        Result.DisplayName := 'Clipboard Check';
        Result.RelativeFileName := 'controls\clipboard-check.svg';
      end;
    mikDotsLoading:
      begin
        Result.Category := 'controls';
        Result.Name := 'dots-loading';
        Result.DisplayName := 'Dots Loading';
        Result.RelativeFileName := 'controls\dots-loading.svg';
      end;
    mikFlag:
      begin
        Result.Category := 'controls';
        Result.Name := 'flag';
        Result.DisplayName := 'Flag';
        Result.RelativeFileName := 'controls\flag.svg';
      end;
    mikRadioChecked:
      begin
        Result.Category := 'controls';
        Result.Name := 'radio-checked';
        Result.DisplayName := 'Radio Checked';
        Result.RelativeFileName := 'controls\radio-checked.svg';
      end;
    mikRadioUnchecked:
      begin
        Result.Category := 'controls';
        Result.Name := 'radio-unchecked';
        Result.DisplayName := 'Radio Unchecked';
        Result.RelativeFileName := 'controls\radio-unchecked.svg';
      end;
    mikSlider:
      begin
        Result.Category := 'controls';
        Result.Name := 'slider';
        Result.DisplayName := 'Slider';
        Result.RelativeFileName := 'controls\slider.svg';
      end;
    mikSpinner:
      begin
        Result.Category := 'controls';
        Result.Name := 'spinner';
        Result.DisplayName := 'Spinner';
        Result.RelativeFileName := 'controls\spinner.svg';
      end;
    mikTag:
      begin
        Result.Category := 'controls';
        Result.Name := 'tag';
        Result.DisplayName := 'Tag';
        Result.RelativeFileName := 'controls\tag.svg';
      end;
    mikToggleOff:
      begin
        Result.Category := 'controls';
        Result.Name := 'toggle-off';
        Result.DisplayName := 'Toggle Off';
        Result.RelativeFileName := 'controls\toggle-off.svg';
      end;
    mikToggleOn:
      begin
        Result.Category := 'controls';
        Result.Name := 'toggle-on';
        Result.DisplayName := 'Toggle On';
        Result.RelativeFileName := 'controls\toggle-on.svg';
      end;
    mikChartArea:
      begin
        Result.Category := 'data';
        Result.Name := 'chart-area';
        Result.DisplayName := 'Chart Area';
        Result.RelativeFileName := 'data\chart-area.svg';
      end;
    mikChartBar:
      begin
        Result.Category := 'data';
        Result.Name := 'chart-bar';
        Result.DisplayName := 'Chart Bar';
        Result.RelativeFileName := 'data\chart-bar.svg';
      end;
    mikChartDonut:
      begin
        Result.Category := 'data';
        Result.Name := 'chart-donut';
        Result.DisplayName := 'Chart Donut';
        Result.RelativeFileName := 'data\chart-donut.svg';
      end;
    mikChartLine:
      begin
        Result.Category := 'data';
        Result.Name := 'chart-line';
        Result.DisplayName := 'Chart Line';
        Result.RelativeFileName := 'data\chart-line.svg';
      end;
    mikClipboardOrder:
      begin
        Result.Category := 'data';
        Result.Name := 'clipboard-order';
        Result.DisplayName := 'Clipboard Order';
        Result.RelativeFileName := 'data\clipboard-order.svg';
      end;
    mikInventoryStack:
      begin
        Result.Category := 'data';
        Result.Name := 'inventory-stack';
        Result.DisplayName := 'Inventory Stack';
        Result.RelativeFileName := 'data\inventory-stack.svg';
      end;
    mikList:
      begin
        Result.Category := 'data';
        Result.Name := 'list';
        Result.DisplayName := 'List';
        Result.RelativeFileName := 'data\list.svg';
      end;
    mikMoneyCircle:
      begin
        Result.Category := 'data';
        Result.Name := 'money-circle';
        Result.DisplayName := 'Money Circle';
        Result.RelativeFileName := 'data\money-circle.svg';
      end;
    mikPackage:
      begin
        Result.Category := 'data';
        Result.Name := 'package';
        Result.DisplayName := 'Package';
        Result.RelativeFileName := 'data\package.svg';
      end;
    mikPercent:
      begin
        Result.Category := 'data';
        Result.Name := 'percent';
        Result.DisplayName := 'Percent';
        Result.RelativeFileName := 'data\percent.svg';
      end;
    mikReport:
      begin
        Result.Category := 'data';
        Result.Name := 'report';
        Result.DisplayName := 'Report';
        Result.RelativeFileName := 'data\report.svg';
      end;
    mikShoppingCart:
      begin
        Result.Category := 'data';
        Result.Name := 'shopping-cart';
        Result.DisplayName := 'Shopping Cart';
        Result.RelativeFileName := 'data\shopping-cart.svg';
      end;
    mikSortAsc:
      begin
        Result.Category := 'data';
        Result.Name := 'sort-asc';
        Result.DisplayName := 'Sort Asc';
        Result.RelativeFileName := 'data\sort-asc.svg';
      end;
    mikSortDesc:
      begin
        Result.Category := 'data';
        Result.Name := 'sort-desc';
        Result.DisplayName := 'Sort Desc';
        Result.RelativeFileName := 'data\sort-desc.svg';
      end;
    mikTableGrid:
      begin
        Result.Category := 'data';
        Result.Name := 'table-grid';
        Result.DisplayName := 'Table Grid';
        Result.RelativeFileName := 'data\table-grid.svg';
      end;
    mikBell:
      begin
        Result.Category := 'interface';
        Result.Name := 'bell';
        Result.DisplayName := 'Bell';
        Result.RelativeFileName := 'interface\bell.svg';
      end;
    mikBookOpen:
      begin
        Result.Category := 'interface';
        Result.Name := 'book-open';
        Result.DisplayName := 'Book Open';
        Result.RelativeFileName := 'interface\book-open.svg';
      end;
    mikCalendar:
      begin
        Result.Category := 'interface';
        Result.Name := 'calendar';
        Result.DisplayName := 'Calendar';
        Result.RelativeFileName := 'interface\calendar.svg';
      end;
    mikClock:
      begin
        Result.Category := 'interface';
        Result.Name := 'clock';
        Result.DisplayName := 'Clock';
        Result.RelativeFileName := 'interface\clock.svg';
      end;
    mikCode:
      begin
        Result.Category := 'interface';
        Result.Name := 'code';
        Result.DisplayName := 'Code';
        Result.RelativeFileName := 'interface\code.svg';
      end;
    mikDocument:
      begin
        Result.Category := 'interface';
        Result.Name := 'document';
        Result.DisplayName := 'Document';
        Result.RelativeFileName := 'interface\document.svg';
      end;
    mikDocumentText:
      begin
        Result.Category := 'interface';
        Result.Name := 'document-text';
        Result.DisplayName := 'Document Text';
        Result.RelativeFileName := 'interface\document-text.svg';
      end;
    mikEyeOff:
      begin
        Result.Category := 'interface';
        Result.Name := 'eye-off';
        Result.DisplayName := 'Eye Off';
        Result.RelativeFileName := 'interface\eye-off.svg';
      end;
    mikHelpCircle:
      begin
        Result.Category := 'interface';
        Result.Name := 'help-circle';
        Result.DisplayName := 'Help Circle';
        Result.RelativeFileName := 'interface\help-circle.svg';
      end;
    mikInfoCircle:
      begin
        Result.Category := 'interface';
        Result.Name := 'info-circle';
        Result.DisplayName := 'Info Circle';
        Result.RelativeFileName := 'interface\info-circle.svg';
      end;
    mikLock:
      begin
        Result.Category := 'interface';
        Result.Name := 'lock';
        Result.DisplayName := 'Lock';
        Result.RelativeFileName := 'interface\lock.svg';
      end;
    mikPalette:
      begin
        Result.Category := 'interface';
        Result.Name := 'palette';
        Result.DisplayName := 'Palette';
        Result.RelativeFileName := 'interface\palette.svg';
      end;
    mikSettings:
      begin
        Result.Category := 'interface';
        Result.Name := 'settings';
        Result.DisplayName := 'Settings';
        Result.RelativeFileName := 'interface\settings.svg';
      end;
    mikStatusConnected:
      begin
        Result.Category := 'interface';
        Result.Name := 'status-connected';
        Result.DisplayName := 'Status Connected';
        Result.RelativeFileName := 'interface\status-connected.svg';
      end;
    mikStatusDisconnected:
      begin
        Result.Category := 'interface';
        Result.Name := 'status-disconnected';
        Result.DisplayName := 'Status Disconnected';
        Result.RelativeFileName := 'interface\status-disconnected.svg';
      end;
    mikSuccessCircle:
      begin
        Result.Category := 'interface';
        Result.Name := 'success-circle';
        Result.DisplayName := 'Success Circle';
        Result.RelativeFileName := 'interface\success-circle.svg';
      end;
    mikThemeMoon:
      begin
        Result.Category := 'interface';
        Result.Name := 'theme-moon';
        Result.DisplayName := 'Theme Moon';
        Result.RelativeFileName := 'interface\theme-moon.svg';
      end;
    mikThemeSun:
      begin
        Result.Category := 'interface';
        Result.Name := 'theme-sun';
        Result.DisplayName := 'Theme Sun';
        Result.RelativeFileName := 'interface\theme-sun.svg';
      end;
    mikUnlock:
      begin
        Result.Category := 'interface';
        Result.Name := 'unlock';
        Result.DisplayName := 'Unlock';
        Result.RelativeFileName := 'interface\unlock.svg';
      end;
    mikUsers:
      begin
        Result.Category := 'interface';
        Result.Name := 'users';
        Result.DisplayName := 'Users';
        Result.RelativeFileName := 'interface\users.svg';
      end;
    mikArrowDown:
      begin
        Result.Category := 'navigation';
        Result.Name := 'arrow-down';
        Result.DisplayName := 'Arrow Down';
        Result.RelativeFileName := 'navigation\arrow-down.svg';
      end;
    mikArrowLeft:
      begin
        Result.Category := 'navigation';
        Result.Name := 'arrow-left';
        Result.DisplayName := 'Arrow Left';
        Result.RelativeFileName := 'navigation\arrow-left.svg';
      end;
    mikArrowRight:
      begin
        Result.Category := 'navigation';
        Result.Name := 'arrow-right';
        Result.DisplayName := 'Arrow Right';
        Result.RelativeFileName := 'navigation\arrow-right.svg';
      end;
    mikArrowUp:
      begin
        Result.Category := 'navigation';
        Result.Name := 'arrow-up';
        Result.DisplayName := 'Arrow Up';
        Result.RelativeFileName := 'navigation\arrow-up.svg';
      end;
    mikChevronLeft:
      begin
        Result.Category := 'navigation';
        Result.Name := 'chevron-left';
        Result.DisplayName := 'Chevron Left';
        Result.RelativeFileName := 'navigation\chevron-left.svg';
      end;
    mikChevronUp:
      begin
        Result.Category := 'navigation';
        Result.Name := 'chevron-up';
        Result.DisplayName := 'Chevron Up';
        Result.RelativeFileName := 'navigation\chevron-up.svg';
      end;
    mikCollapse:
      begin
        Result.Category := 'navigation';
        Result.Name := 'collapse';
        Result.DisplayName := 'Collapse';
        Result.RelativeFileName := 'navigation\collapse.svg';
      end;
    mikExpand:
      begin
        Result.Category := 'navigation';
        Result.Name := 'expand';
        Result.DisplayName := 'Expand';
        Result.RelativeFileName := 'navigation\expand.svg';
      end;
    mikFirstPage:
      begin
        Result.Category := 'navigation';
        Result.Name := 'first-page';
        Result.DisplayName := 'First Page';
        Result.RelativeFileName := 'navigation\first-page.svg';
      end;
    mikHome:
      begin
        Result.Category := 'navigation';
        Result.Name := 'home';
        Result.DisplayName := 'Home';
        Result.RelativeFileName := 'navigation\home.svg';
      end;
    mikLastPage:
      begin
        Result.Category := 'navigation';
        Result.Name := 'last-page';
        Result.DisplayName := 'Last Page';
        Result.RelativeFileName := 'navigation\last-page.svg';
      end;
    mikMenu:
      begin
        Result.Category := 'navigation';
        Result.Name := 'menu';
        Result.DisplayName := 'Menu';
        Result.RelativeFileName := 'navigation\menu.svg';
      end;
    mikNextPage:
      begin
        Result.Category := 'navigation';
        Result.Name := 'next-page';
        Result.DisplayName := 'Next Page';
        Result.RelativeFileName := 'navigation\next-page.svg';
      end;
    mikPreviousPage:
      begin
        Result.Category := 'navigation';
        Result.Name := 'previous-page';
        Result.DisplayName := 'Previous Page';
        Result.RelativeFileName := 'navigation\previous-page.svg';
      end;
    mikFilePdf:
      begin
        Result.Category := 'report-viewer';
        Result.Name := 'file-pdf';
        Result.DisplayName := 'File Pdf';
        Result.RelativeFileName := 'report-viewer\file-pdf.svg';
      end;
    mikFitPage:
      begin
        Result.Category := 'report-viewer';
        Result.Name := 'fit-page';
        Result.DisplayName := 'Fit Page';
        Result.RelativeFileName := 'report-viewer\fit-page.svg';
      end;
    mikFullscreen:
      begin
        Result.Category := 'report-viewer';
        Result.Name := 'fullscreen';
        Result.DisplayName := 'Fullscreen';
        Result.RelativeFileName := 'report-viewer\fullscreen.svg';
      end;
    mikPageSearch:
      begin
        Result.Category := 'report-viewer';
        Result.Name := 'page-search';
        Result.DisplayName := 'Page Search';
        Result.RelativeFileName := 'report-viewer\page-search.svg';
      end;
    mikZoomIn:
      begin
        Result.Category := 'report-viewer';
        Result.Name := 'zoom-in';
        Result.DisplayName := 'Zoom In';
        Result.RelativeFileName := 'report-viewer\zoom-in.svg';
      end;
    mikZoomOut:
      begin
        Result.Category := 'report-viewer';
        Result.Name := 'zoom-out';
        Result.DisplayName := 'Zoom Out';
        Result.RelativeFileName := 'report-viewer\zoom-out.svg';
      end;
  else
    begin
      Result.Category := '';
      Result.Name := '';
      Result.DisplayName := '';
      Result.RelativeFileName := '';
    end;
  end;
end;

class function TDACIconAssets.SvgSource(
  const AKind: TDACIconKind; const AColor: TAlphaColor;
  const AAlpha: Byte): string;
var
  LColor: string;
begin
  Result := RawSvg(AKind);
  if Result = '' then
    Exit;

  LColor := AlphaColorToSvg(AColor);
  Result := StringReplace(Result, 'currentColor', LColor,
    [rfReplaceAll, rfIgnoreCase]);
  Result := StringReplace(Result, 'color:#2F9E22', 'color:' + LColor,
    [rfReplaceAll, rfIgnoreCase]);
  if AAlpha < 255 then
    Result := StringReplace(Result, '<svg ', '<svg opacity="' +
      SvgOpacity(AAlpha) + '" ', []);
end;

end.

