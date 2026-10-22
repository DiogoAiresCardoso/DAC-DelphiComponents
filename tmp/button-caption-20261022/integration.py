from pathlib import Path
import shutil
r=Path(r'M:\MaxxSoft\MaxxRural\Desktop\maxxrural')
t=r/'MaxxRural/src/Tests'; out=t/'Resultados/20261022-button-caption'; out.mkdir(parents=True,exist_ok=True)
for name in ['compilar.cmd','compilar-desktop.cmd','executar-testes.ps1']:
    shutil.copy2(t/'Resultados/20261021-grid-hover-flicker'/name,out/name)
source='''unit Teste.ImportacaoOFX.BotaoCaption;
interface
uses DUnitX.TestFramework, System.Skia, System.Types;
type
  [TestFixture]
  TImportacaoOFXBotaoCaptionTests = class
  private
    FDraws: Integer;
    FOriginal: procedure(Sender: TObject; const Canvas: ISkCanvas;
      const Dest: TRectF; const Opacity: Single) of object;
    procedure Draw(Sender: TObject; const Canvas: ISkCanvas;
      const Dest: TRectF; const Opacity: Single);
  public
    [TestCase('esquerda','0')]
    [TestCase('direita','1')]
    procedure CaptionRecompoeIconeDoDFMReal(const Side: Integer);
  end;
implementation
uses System.Classes, System.SysUtils, System.IOUtils, System.RegularExpressions,
  Vcl.Forms, Vcl.Skia, DAC.Components.Controls.Button,
  DAC.Components.Controls.SystemText;
procedure TImportacaoOFXBotaoCaptionTests.Draw(Sender: TObject;
  const Canvas: ISkCanvas; const Dest: TRectF; const Opacity: Single);
begin Inc(FDraws); FOriginal(Sender,Canvas,Dest,Opacity); end;
procedure TImportacaoOFXBotaoCaptionTests.CaptionRecompoeIconeDoDFMReal(const Side: Integer);
const Counts: array[0..3] of Integer = (138,1,9999,0);
var Host: TForm; B: TDACButton; Box: TSkPaintBox; LabelControl: TDACSystemText;
  Input: TStringStream; Binary: TMemoryStream; M: TMatch;
  Text, Block, Caption: string; I, J, Before, Width: Integer;
  procedure Pump;
  var N: Integer;
  begin for N := 1 to 4 do Application.ProcessMessages; end;
begin
  Application.Initialize; Host := TForm.CreateNew(nil);
  Box := nil; LabelControl := nil; Input := nil; Binary := nil;
  try
    Host.SetBounds(40,40,420,150);
    B := TDACButton.Create(Host); B.Parent := Host;
    Text := TFile.ReadAllText(TPath.GetFullPath(ExtractFilePath(ParamStr(0)) +
      '..\\source\\view\\View.MovimentoBancario.ImportacaoOFX.dfm'), TEncoding.GetEncoding(1252));
    M := TRegEx.Match(Text,'(?ms)^        object btnImportar: TDACButton\\r?\\n.*?^        end\\r?$');
    Assert.IsTrue(M.Success, 'Botao nao encontrado no DFM real.');
    // Presentation fixture: no binding to the real financial click handler.
    Block := TRegEx.Replace(M.Value,'(?m)^\\s*OnClick = [^\\r\\n]+\\r?\\n','');
    Input := TStringStream.Create(Block,TEncoding.UTF8); Binary := TMemoryStream.Create;
    ObjectTextToBinary(Input,Binary); Binary.Position := 0; Binary.ReadComponent(B);
    B.SetBounds(16,16,B.Width,B.Height); B.IconPosition := TDACButtonIconPosition(Side);
    Width := B.Width;
    for I := 0 to B.ControlCount - 1 do
    begin
      if B.Controls[I] is TSkPaintBox then Box := TSkPaintBox(B.Controls[I]);
      if B.Controls[I] is TDACSystemText then LabelControl := TDACSystemText(B.Controls[I]);
    end;
    Assert.IsNotNull(Box); Assert.IsNotNull(LabelControl);
    FOriginal := Box.OnDraw; Box.OnDraw := Draw;
    Host.Show; Pump;
    for J := 0 to High(Counts) do
    begin
      B.Enabled := Counts[J] > 0; Pump;
      Before := FDraws;
      if Counts[J] = 0 then Caption := 'Importar registros'
      else Caption := Format('Importar %d registros',[Counts[J]]);
      B.Caption := Caption; Pump;
      Assert.IsTrue(FDraws > Before, 'Caption deixou o frame do icone em cache.');
      Assert.AreEqual(Caption,LabelControl.Text);
      Assert.AreEqual(Width,B.Width,'Atualizacao nao deve depender de resize.');
    end;
  finally
    if Box <> nil then Box.OnDraw := FOriginal;
    Binary.Free; Input.Free; Host.Free;
  end;
end;
initialization
  TDUnitX.RegisterTestFixture(TImportacaoOFXBotaoCaptionTests);
end.
'''
(t/'Teste.ImportacaoOFX.BotaoCaption.pas').write_bytes(source.replace('\n','\r\n').encode('cp1252'))
p=t/'ApiTestes.dpr';s=p.read_bytes().decode('cp1252')
backup=Path(r'M:\Delphi Componentes\DAC-DelphiComponents\tmp\button-caption-20261022\apitestes.before.dpr')
if not backup.exists():backup.write_bytes(p.read_bytes())
entry="  Teste.ImportacaoOFX.BotaoCaption in 'Teste.ImportacaoOFX.BotaoCaption.pas',"
assert entry not in s
s=s.replace("  Teste.ImportacaoOFX.Estrutura in",entry+'\r\n'+"  Teste.ImportacaoOFX.Estrutura in",1)
p.write_bytes(s.encode('cp1252'))
print(out)
