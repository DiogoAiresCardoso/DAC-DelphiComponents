unit uGridInteracao;

interface

uses System.Classes;

type
  TGridInteracao = class
  public
    class procedure RestaurarNavegacao(AComponente: TComponent); static;
  end;

implementation

uses System.TypInfo, Vcl.DBGrids;

class procedure TGridInteracao.RestaurarNavegacao(AComponente: TComponent);
begin
  // A grid de consulta precisa continuar recebendo foco e scroll fora da edicao.
  // ReadOnly, regras das acoes e permissoes continuam sob seus fluxos existentes.
  if (AComponente is TCustomDBGrid) and IsPublishedProp(AComponente, 'Enabled') then
    SetOrdProp(AComponente, 'Enabled', Ord(True));
end;

end.
