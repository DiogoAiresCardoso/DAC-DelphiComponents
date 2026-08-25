unit DAC.Components.Controls.FieldChrome;

{ Responsabilidade: classe base unificada para todos os controles de campo
  de formulario que possuem chrome Skia + editor nativo + labels de texto.

  Controles que herdam de TDACCustomFieldChrome:
    TDACEdit, TDACButtonEdit, TDACComboBox, TDACDateTimePicker, TDACMemo

  SOLID: SRP — esta classe gerencia apenas o chrome (fundo + borda + labels).
  A logica de editor (input, mask, dropdown) fica nos descendentes.
  DRY — elimina a duplicacao de Redraw/SetBounds/WMEraseBkgnd entre controles. }

interface

uses
  System.Classes,
  System.Skia,
  System.Types,
  System.UITypes,
  Winapi.Messages,
  Winapi.Windows,
  Vcl.Controls,
  Vcl.Graphics,
  Vcl.Skia,
  DAC.Components.Controls.FieldSupport,
  DAC.Components.DesignSystem.ComponentStyle,
  DAC.Components.DesignSystem.ControlTokens,
  DAC.Components.DesignSystem.Theme,
  DAC.Components.Skia.BackgroundPainter,
  DAC.Components.Skia.BorderPainter,
  DAC.Components.Skia.IconPainter,
  DAC.Components.Skia.Renderer;

type
  { Classe base para todos os campos de formulario com chrome Skia.
    Gerencia: FPaintBox, FRenderer, painters, FFieldText, FThemeMode,
    bem como Redraw, SetBounds e WMEraseBkgnd padronizados. }
  TDACCustomFieldChrome = class(TCustomControl)
  private
    FBackgroundPainter: TDACSkiaBackgroundPainter;
    FBorderPainter: TDACSkiaBorderPainter;
    FFieldText: TDACFieldTextSupport;
    FIconPainter: TDACSkiaIconPainter;
    FPaintBox: TSkPaintBox;
    FRenderer: TDACSkiaRenderer;
    FThemeMode: TDACThemeMode;
    procedure SetThemeMode(const AValue: TDACThemeMode);
    procedure ThemeChanged(Sender: TObject);
    procedure CMParentColorChanged(var AMessage: TMessage); message CM_PARENTCOLORCHANGED;
    procedure CMParentFontChanged(var AMessage: TMessage); message CM_PARENTFONTCHANGED;
    procedure WMEraseBkgnd(var AMessage: TWMEraseBkgnd); message WM_ERASEBKGND;
  protected
    { Subclasses devem implementar o desenho Skia do chrome. }
    procedure DrawChrome(const ACanvas: ISkCanvas; const ADest: TRectF);
      virtual; abstract;
    { Subclasses devem chamar UpdatePaintBoxBounds em Resize e Loaded. }
    procedure UpdatePaintBoxBounds; virtual; abstract;
    { Subclasses devem chamar UpdateChildBounds em Resize e Loaded. }
    procedure UpdateChildBounds; virtual; abstract;
    { Chamado quando o tema muda. Subclasses devem sobrescrever para
      atualizar painters e re-desenhar. }
    procedure ApplyTheme; virtual;

    { Acesso protegido aos painters e renderer para os descendentes. }
    property BackgroundPainter: TDACSkiaBackgroundPainter read FBackgroundPainter;
    property BorderPainter: TDACSkiaBorderPainter read FBorderPainter;
    property FieldText: TDACFieldTextSupport read FFieldText;
    property IconPainter: TDACSkiaIconPainter read FIconPainter;
    property PaintBox: TSkPaintBox read FPaintBox;
    property Renderer: TDACSkiaRenderer read FRenderer;

    procedure Resize; override;
  public
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
    procedure SetBounds(ALeft, ATop, AWidth, AHeight: Integer); override;

    { Dispara redesenho Skia do chrome. Seguro em design-time e runtime. }
    procedure Redraw; virtual;

    function ResolvedTheme: IDACComponentsTheme;
    function ResolvedTokens: TDACControlTokens;

  published
    property ThemeMode: TDACThemeMode read FThemeMode write SetThemeMode
      default dtmInherit;
  end;

implementation

uses
  System.Math,
  DAC.Components.DesignSystem.ColorTokens;

constructor TDACCustomFieldChrome.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  ControlStyle := ControlStyle + [csOpaque];
  TabStop := True;
  FThemeMode := dtmInherit;
  FRenderer := TDACSkiaRenderer.Create;
  FBackgroundPainter := TDACSkiaBackgroundPainter.Create(FRenderer);
  FBorderPainter := TDACSkiaBorderPainter.Create(FRenderer);
  FIconPainter := TDACSkiaIconPainter.Create(FRenderer);
  FFieldText := TDACFieldTextSupport.Create(Self, Self);
  FPaintBox := TSkPaintBox.Create(Self);
  FPaintBox.Parent := Self;
  FPaintBox.Align := alNone;
  TDACThemeManager.RegisterListener(Self, ThemeChanged);
end;

destructor TDACCustomFieldChrome.Destroy;
begin
  TDACThemeManager.UnregisterListener(Self);
  FPaintBox.Free;
  FFieldText.Free;
  FIconPainter.Free;
  FBorderPainter.Free;
  FBackgroundPainter.Free;
  FRenderer.Free;
  inherited;
end;

procedure TDACCustomFieldChrome.ApplyTheme;
begin
  Redraw;
end;

procedure TDACCustomFieldChrome.ThemeChanged(Sender: TObject);
begin
  if (FThemeMode <> dtmInherit) and (Sender <> Self) then
    Exit;
  ApplyTheme;
end;

procedure TDACCustomFieldChrome.CMParentColorChanged(var AMessage: TMessage);
begin
  inherited;
  ApplyTheme;
  TDACThemeManager.RefreshTree(Self);
end;

procedure TDACCustomFieldChrome.CMParentFontChanged(var AMessage: TMessage);
begin
  inherited;
  ApplyTheme;
  TDACThemeManager.RefreshTree(Self);
end;

procedure TDACCustomFieldChrome.Redraw;
begin
  if (FPaintBox = nil) or (csDestroying in ComponentState) then
    Exit;
  if csDesigning in ComponentState then
  begin
    { Design-time: descarta cache Skia e invalida superficie do designer.
      TSkPaintBox e TGraphicControl — Redraw nao cria HWND. }
    FPaintBox.Redraw;
    Invalidate;
    Exit;
  end;
  if (Parent <> nil) and HandleAllocated and Parent.HandleAllocated then
    FPaintBox.Redraw;
end;

procedure TDACCustomFieldChrome.SetBounds(ALeft, ATop, AWidth, AHeight: Integer);
var
  LPreviousBounds: TRect;
  LNewBounds: TRect;
  LChanged: Boolean;
begin
  LPreviousBounds := BoundsRect;
  LChanged := (LPreviousBounds.Left <> ALeft) or (LPreviousBounds.Top <> ATop) or
    (LPreviousBounds.Right <> ALeft + AWidth) or
    (LPreviousBounds.Bottom <> ATop + AHeight);
  inherited SetBounds(ALeft, ATop, AWidth, AHeight);
  if LChanged and (csDesigning in ComponentState) then
  begin
    { Invalida posicao anterior e nova no parent para limpar pixels fantasma
      ao mover o componente no designer. }
    if (Parent <> nil) and Parent.HandleAllocated then
    begin
      LNewBounds := BoundsRect;
      InvalidateRect(Parent.Handle, @LPreviousBounds, True);
      InvalidateRect(Parent.Handle, @LNewBounds, True);
    end;
    UpdatePaintBoxBounds;
    UpdateChildBounds;
    Invalidate;
  end;
end;

procedure TDACCustomFieldChrome.Resize;
begin
  inherited;
  if (csLoading in ComponentState) or (csDestroying in ComponentState) then
    Exit;
  if csDesigning in ComponentState then
  begin
    UpdatePaintBoxBounds;
    UpdateChildBounds;
    Exit;
  end;
  if (Parent = nil) or not HandleAllocated or not Parent.HandleAllocated then
    Exit;
  UpdatePaintBoxBounds;
  UpdateChildBounds;
  Redraw;
end;

procedure TDACCustomFieldChrome.SetThemeMode(const AValue: TDACThemeMode);
begin
  if FThemeMode = AValue then
  begin
    ThemeChanged(Self);
    TDACThemeManager.RefreshTree(Self);
    Exit;
  end;
  FThemeMode := AValue;
  ThemeChanged(Self);
  TDACThemeManager.RefreshTree(Self);
end;

procedure TDACCustomFieldChrome.WMEraseBkgnd(var AMessage: TWMEraseBkgnd);
var
  LBrush: HBRUSH;
  LColor: TColor;
begin
  { Preenche com a cor de superficie do parent para eliminar pixels fantasma
    ao mover o componente no designer e evitar flicker em runtime. }
  LColor := DACFieldVclColor(TDACComponentColors.ResolveParentSurface(Self));
  LBrush := CreateSolidBrush(ColorToRGB(LColor));
  try
    FillRect(AMessage.DC, ClientRect, LBrush);
  finally
    DeleteObject(LBrush);
  end;
  AMessage.Result := 1;
end;

function TDACCustomFieldChrome.ResolvedTheme: IDACComponentsTheme;
begin
  Result := TDACComponentStyle.ResolveForSurface(Self, FThemeMode);
end;

function TDACCustomFieldChrome.ResolvedTokens: TDACControlTokens;
begin
  Result := ResolvedTheme.Tokens.Controls;
end;

end.
