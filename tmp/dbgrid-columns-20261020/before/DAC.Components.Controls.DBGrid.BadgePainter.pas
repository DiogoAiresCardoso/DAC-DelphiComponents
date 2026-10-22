unit DAC.Components.Controls.DBGrid.BadgePainter;

interface

uses
  System.Classes,
  System.Generics.Collections,
  System.Skia,
  System.Types,
  System.UITypes,
  Winapi.Windows,
  Data.DB,
  DAC.Components.Controls.Badges,
  DAC.Components.Controls.DBGrid.Column,
  DAC.Components.Controls.DBGrid.Types,
  DAC.Components.DesignSystem.ControlTokens,
  DAC.Components.Skia.Renderer;

type
  TDACDBGridBadgePainter = class
  private
    FRenderer: TDACSkiaRenderer;
    procedure ResolveColors(const AStatus: TDACBadgeStatus;
      const AAppearance: TDACBadgeAppearance;
      const ATokens: TDACControlTokens; out ABackground, ABorder,
      AText: TAlphaColor);
  public
    constructor Create;
    destructor Destroy; override;
    function Draw(const ACanvas: ISkCanvas; const ATextDC: HDC;
      const APPI: Integer; const ARect: TRectF; AColumn: TDACDBGridColumn;
      AField: TField;
      const ATokens: TDACControlTokens;
      const ATextItems: TList<TDACDBGridTextItem>): Boolean;
  end;

implementation

uses
  System.Math,
  DAC.Components.Controls.DBGrid.BadgeRule,
  DAC.Components.Controls.DBGrid.FieldText,
  DAC.Components.Controls.DBGrid.NativeText,
  DAC.Components.DesignSystem.ComponentStyle;

constructor TDACDBGridBadgePainter.Create;
begin
  inherited Create;
  FRenderer := TDACSkiaRenderer.Create;
end;

destructor TDACDBGridBadgePainter.Destroy;
begin
  FRenderer.Free;
  inherited;
end;

function TDACDBGridBadgePainter.Draw(const ACanvas: ISkCanvas;
  const ATextDC: HDC; const APPI: Integer; const ARect: TRectF;
  AColumn: TDACDBGridColumn; AField: TField; const ATokens: TDACControlTokens;
  const ATextItems: TList<TDACDBGridTextItem>): Boolean;
var
  LAppearance: TDACBadgeAppearance;
  LAvailableHeight: Single;
  LAvailableWidth: Single;
  LBackground: TAlphaColor;
  LBadgeRect: TRectF;
  LBorder: TAlphaColor;
  LBorderWidth: Single;
  LCaption: string;
  LCellInset: Single;
  LHeight: Single;
  LMinWidth: Single;
  LPPI: Integer;
  LRadius: Single;
  LRule: TDACDBGridBadgeRule;
  LStatus: TDACBadgeStatus;
  LText: TAlphaColor;
  LTextInset: Single;
  LTextItem: TDACDBGridTextItem;
  LTextSize: TSize;
  LVerticalInset: Single;
  LWidth: Single;
begin
  Result := False;
  if (AColumn = nil) or (AField = nil) or
    (AColumn.BadgeMode = dbmNone) then
    Exit;

  LAppearance := mbaSoft;
  LCaption := '';
  LRule := nil;
  LStatus := mbsNeutral;
  case AColumn.BadgeMode of
    dbmBooleanPreset:
      begin
        if not (AField is TBooleanField) then
          Exit;
        if AField.AsBoolean then
        begin
          LCaption := AColumn.TrueCaption;
          LStatus := AColumn.TrueStatus;
        end
        else
        begin
          LCaption := AColumn.FalseCaption;
          LStatus := AColumn.FalseStatus;
        end;
      end;
    dbmRules:
      begin
        LRule := AColumn.BadgeRules.FindMatch(AField.AsString);
        if LRule = nil then
          Exit;
        LCaption := LRule.Caption;
        if LCaption = '' then
          LCaption := TDACDBGridFieldTextResolver.Resolve(AField);
        LStatus := LRule.Status;
        LAppearance := LRule.Appearance;
      end;
  end;

  ResolveColors(LStatus, LAppearance, ATokens, LBackground, LBorder, LText);
  if (LRule <> nil) and LRule.UseCustomColors then
  begin
    LBackground := LRule.BackgroundColor;
    LBorder := LRule.BorderColor;
    LText := LRule.TextColor;
  end;

  LPPI := Max(96, APPI);
  LCellInset := MulDiv(8, LPPI, 96);
  LTextInset := MulDiv(6, LPPI, 96);
  LVerticalInset := MulDiv(4, LPPI, 96);
  LMinWidth := MulDiv(28, LPPI, 96);
  LAvailableWidth := Max(0, ARect.Width - (LCellInset * 2));
  LAvailableHeight := Max(0, ARect.Height - (LVerticalInset * 2));
  if (LAvailableWidth <= 0) or (LAvailableHeight <= 0) then
    Exit;

  LTextSize := DACMeasureDBGridText(ATextDC,
    TDACComponentStyle.FontFamily, LCaption, DACDBGridDefaultFontSize, True,
    LPPI);
  LWidth := Min(Max(LMinWidth, LTextSize.cx + (LTextInset * 2)),
    LAvailableWidth);
  LHeight := Min(MulDiv(Round(ATokens.BadgeDefaultHeight), LPPI, 96),
    LAvailableHeight);
  case AColumn.Alignment of
    taRightJustify:
      LBadgeRect := TRectF.Create(ARect.Right - LCellInset - LWidth,
        ARect.CenterPoint.Y - (LHeight / 2), ARect.Right - LCellInset,
        ARect.CenterPoint.Y + (LHeight / 2));
    taCenter:
      LBadgeRect := TRectF.Create(ARect.CenterPoint.X - (LWidth / 2),
        ARect.CenterPoint.Y - (LHeight / 2),
        ARect.CenterPoint.X + (LWidth / 2),
        ARect.CenterPoint.Y + (LHeight / 2));
  else
    LBadgeRect := TRectF.Create(ARect.Left + LCellInset,
      ARect.CenterPoint.Y - (LHeight / 2), ARect.Left + LCellInset + LWidth,
      ARect.CenterPoint.Y + (LHeight / 2));
  end;
  LRadius := Min(MulDiv(Round(ATokens.BadgeRadius), LPPI, 96),
    LBadgeRect.Height / 2);
  LBorderWidth := Max(1, MulDiv(1, LPPI, 96));
  FRenderer.FillRoundRect(ACanvas, LBadgeRect, LBackground,
    LRadius);
  FRenderer.StrokeRoundRect(ACanvas, LBadgeRect, LBorder,
    LRadius, LBorderWidth);

  LTextItem.Text := LCaption;
  LTextItem.Bounds := Rect(Round(LBadgeRect.Left + LTextInset),
    Round(LBadgeRect.Top), Round(LBadgeRect.Right - LTextInset),
    Round(LBadgeRect.Bottom));
  LTextItem.Color := LText;
  LTextItem.FontSize := DACDBGridDefaultFontSize;
  LTextItem.Bold := True;
  LTextItem.Alignment := taCenter;
  LTextItem.Ellipsis := True;
  ATextItems.Add(LTextItem);
  Result := True;
end;

procedure TDACDBGridBadgePainter.ResolveColors(const AStatus: TDACBadgeStatus;
  const AAppearance: TDACBadgeAppearance;
  const ATokens: TDACControlTokens; out ABackground, ABorder,
  AText: TAlphaColor);
begin
  case AStatus of
    mbsSuccess:
      begin
        ABackground := ATokens.DataGridStatusBackground;
        ABorder := ATokens.DataGridSuccess;
        AText := ATokens.DataGridStatusText;
      end;
    mbsWarning:
      begin
        ABackground := ATokens.ToastWarningBackground;
        ABorder := ATokens.ToastWarningBackground;
        AText := ATokens.FeedbackText;
      end;
    mbsDanger:
      begin
        ABackground := ATokens.DataGridActionDangerBackground;
        ABorder := ATokens.DataGridError;
        AText := ATokens.FeedbackText;
      end;
    mbsInfo:
      begin
        ABackground := ATokens.ToastInfoBackground;
        ABorder := ATokens.ToastInfoBackground;
        AText := ATokens.FeedbackText;
      end;
  else
    begin
      ABackground := ATokens.BadgeSoftBackground;
      ABorder := ATokens.BadgeBorder;
      AText := ATokens.BadgeText;
    end;
  end;
  case AAppearance of
    mbaFilled:
      begin
        ABackground := ABorder;
        if AStatus <> mbsNeutral then
          AText := ATokens.FeedbackText;
      end;
    mbaOutline:
      ABackground := ATokens.DataGridBackground;
  end;
end;

end.
