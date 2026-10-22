unit DAC.Components.Controls.DBGrid.Contracts;

interface

uses
  System.Classes;

type
  TDACDBGridChangedProc = procedure(Sender: TObject) of object;
  TDACDBGridInvalidateProc = procedure of object;
  TDACDBGridErrorProc = procedure(const AMessage: string) of object;

implementation

end.
