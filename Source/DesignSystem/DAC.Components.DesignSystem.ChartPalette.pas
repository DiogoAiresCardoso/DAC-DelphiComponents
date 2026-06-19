unit DAC.Components.DesignSystem.ChartPalette;

interface

uses
  System.UITypes;

type
  TDACChartSemanticRole = (
    csrPositive,
    csrNeutral,
    csrWarning,
    csrNegative
  );

  TDACChartPalette = record
    VerdePrincipal: TAlphaColor;
    VerdeMedio: TAlphaColor;
    AmareloAgricola: TAlphaColor;
    AzulInformativo: TAlphaColor;
    LaranjaAtencao: TAlphaColor;
    VermelhoQueda: TAlphaColor;
    CianoComplementar: TAlphaColor;
    VerdeClaroSuave: TAlphaColor;
    FundoGrafico: TAlphaColor;
    Card: TAlphaColor;
    GradePrincipal: TAlphaColor;
    GradeSecundaria: TAlphaColor;
    TextoPrincipal: TAlphaColor;
    TextoSecundario: TAlphaColor;
    LinhaEixo: TAlphaColor;
    class function Default: TDACChartPalette; static;
    function ColorByIndex(const AIndex: Integer): TAlphaColor;
    function ColorByRole(const ARole: TDACChartSemanticRole): TAlphaColor;
  end;

implementation

class function TDACChartPalette.Default: TDACChartPalette;
begin
  Result.VerdePrincipal := TAlphaColor($FF74D64A);
  Result.VerdeMedio := TAlphaColor($FF3DBB2A);
  Result.AmareloAgricola := TAlphaColor($FFF5C842);
  Result.AzulInformativo := TAlphaColor($FF4C8DFF);
  Result.LaranjaAtencao := TAlphaColor($FFF39C3D);
  Result.VermelhoQueda := TAlphaColor($FFE85C4A);
  Result.CianoComplementar := TAlphaColor($FF39C6D6);
  Result.VerdeClaroSuave := TAlphaColor($FFA7E36A);
  Result.FundoGrafico := TAlphaColor($FF0B1A11);
  Result.Card := TAlphaColor($FF102417);
  Result.GradePrincipal := TAlphaColor($FF284133);
  Result.GradeSecundaria := TAlphaColor($FF1B2E23);
  Result.TextoPrincipal := TAlphaColor($FFE8EEE8);
  Result.TextoSecundario := TAlphaColor($FFB8C4B8);
  Result.LinhaEixo := TAlphaColor($FF355241);
end;

function TDACChartPalette.ColorByIndex(const AIndex: Integer): TAlphaColor;
begin
  case AIndex mod 8 of
    0: Result := VerdePrincipal;
    1: Result := VerdeMedio;
    2: Result := AmareloAgricola;
    3: Result := AzulInformativo;
    4: Result := LaranjaAtencao;
    5: Result := VermelhoQueda;
    6: Result := CianoComplementar;
  else
    Result := VerdeClaroSuave;
  end;
end;

function TDACChartPalette.ColorByRole(
  const ARole: TDACChartSemanticRole): TAlphaColor;
begin
  case ARole of
    csrPositive: Result := VerdePrincipal;
    csrWarning: Result := AmareloAgricola;
    csrNegative: Result := VermelhoQueda;
  else
    Result := TextoSecundario;
  end;
end;

end.

