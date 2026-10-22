program MaxxCRM;

uses
  Vcl.Forms,
  ufrmPrincipal in 'ufrmPrincipal.pas' {frmPrincipal},
  Base64 in '..\Base64.pas',
  DCPconst in '..\DCPconst.pas',
  DCPcrypt in '..\DCPcrypt.pas',
  IDEA in '..\IDEA.pas',
  Md5 in '..\Md5.pas',
  Sha1 in '..\Sha1.pas',
  U_Cipher in '..\U_Cipher.pas',
  udmMaxxLocal in '..\udmMaxxLocal.pas' {dmMaxxLocal: TDataModule},
  uLib in '..\uLib.pas',
  ufrmAguarde in '..\..\Geral\ufrmAguarde.pas' {frmAguarde},
  ufrmMaster in '..\..\Geral\ufrmMaster.pas' {frmMaster},
  uMensagens in '..\..\Geral\uMensagens.pas' {frmMensagens},
  ufrmMasterCad in '..\ufrmMasterCad.pas' {frmMasterCad},
  ufrmMasterDet in '..\ufrmMasterDet.pas' {frmMasterDet},
  ufrmMasterPes in '..\ufrmMasterPes.pas' {frmMasterPes},
  ufrmMasterRel in '..\ufrmMasterRel.pas' {frmMasterRel},
  uModulos in '..\uModulos.pas',
  uRecError in '..\uRecError.pas' {ReconcileErrorForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfrmPrincipal, frmPrincipal);
  Application.CreateForm(TdmMaxxLocal, dmMaxxLocal);
  Application.CreateForm(TfrmAguarde, frmAguarde);
  Application.CreateForm(TfrmMaster, frmMaster);
  Application.CreateForm(TfrmMensagens, frmMensagens);
  Application.CreateForm(TfrmMasterCad, frmMasterCad);
  Application.CreateForm(TfrmMasterDet, frmMasterDet);
  Application.CreateForm(TfrmMasterPes, frmMasterPes);
  Application.CreateForm(TfrmMasterRel, frmMasterRel);
  Application.Run;
end.
