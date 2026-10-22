unit DACComponentsButtonLayout.Tests;

interface

uses System.Classes, System.Skia, System.Types;

type
  TDACButtonLayoutTests = class
  private
    FDraws: Integer;
    FOriginal: procedure(Sender: TObject; const Canvas: ISkCanvas;
      const Dest: TRectF; const Opacity: Single) of object;
    procedure Draw(Sender: TObject; const Canvas: ISkCanvas;
      const Dest: TRectF; const Opacity: Single);
  public
    class procedure Run; static;
  end;

implementation

uses System.SysUtils, System.IOUtils, Winapi.Windows, Vcl.Forms,
  Vcl.Controls, Vcl.Graphics, Vcl.Skia, Vcl.Imaging.pngimage,
  DAC.Components.Controls.Button, DAC.Components.Controls.SystemText,
  DAC.Components.DesignSystem.Theme, DAC.Components.DesignSystem.IconAssets;

procedure Require(const Condition: Boolean; const Message: string);
begin
  if not Condition then raise Exception.Create(Message);
end;

procedure Pump;
var I: Integer;
begin for I := 1 to 4 do Application.ProcessMessages; end;

procedure TDACButtonLayoutTests.Draw(Sender: TObject; const Canvas: ISkCanvas;
  const Dest: TRectF; const Opacity: Single);
begin
  Inc(FDraws);
  FOriginal(Sender, Canvas, Dest, Opacity);
end;

class procedure TDACButtonLayoutTests.Run;
var Host: TForm; B, Unparented: TDACButton; Box: TSkPaintBox;
  LabelControl: TDACSystemText; Probe: TDACButtonLayoutTests;
  I, Side, Theme, SizeIndex, Before, OldWidth, Cases: Integer;
  OutputDir: string; Bitmap: TBitmap; PNG: TPngImage;
  procedure ChangeCaption(const Value: string);
  begin
    Before := Probe.FDraws;
    B.Caption := Value; Pump;
    Require(Probe.FDraws > Before, 'Caption mudou sem reconstruir o frame Skia: ' + Value);
    Require(LabelControl.Text = Value, 'Caption e texto nativo divergiram.');
    Inc(Cases);
  end;
begin
  Cases := 0; Unparented := TDACButton.Create(nil);
  try
    Unparented.ShowIcon := True; Unparented.Caption := 'Importar 138 registros';
    Unparented.Font.Size := 15; Unparented.Caption := '';
    Require(not Unparented.HandleAllocated, 'Mudanca de texto/fonte criou HWND sem Parent.');
  finally Unparented.Free; end;
  Host := TForm.CreateNew(nil); Probe := TDACButtonLayoutTests.Create;
  B := nil; Box := nil; LabelControl := nil; Bitmap := nil; PNG := nil;
  try
    Host.SetBounds(50,50,640,180);
    B := TDACButton.Create(Host); B.Parent := Host; B.SetBounds(16,16,560,60);
    B.ShowIcon := True; B.IconKind := mikDownload;
    for I := 0 to B.ControlCount - 1 do
    begin
      if B.Controls[I] is TSkPaintBox then Box := TSkPaintBox(B.Controls[I]);
      if B.Controls[I] is TDACSystemText then LabelControl := TDACSystemText(B.Controls[I]);
    end;
    Require((Box <> nil) and (LabelControl <> nil), 'Camadas do botao ausentes.');
    Probe.FOriginal := Box.OnDraw; Box.OnDraw := Probe.Draw;
    Host.Show; Pump;
    for Theme := 0 to 1 do
      for Side := 0 to 1 do
        for SizeIndex := 0 to 2 do
        begin
          if Theme = 0 then B.ThemeMode := dtmLight else B.ThemeMode := dtmDark;
          B.IconPosition := TDACButtonIconPosition(Side);
          B.Size := TDACButtonSize(SizeIndex); Pump;
          B.Caption := 'Importar registros'; Pump;
          ChangeCaption('Importar 138 registros');
          ChangeCaption('Importar 1 registro');
          ChangeCaption('Importar 123456 registros');
          ChangeCaption('');
          Require(LabelControl.Width = 0, 'Caption vazio reservou largura de texto.');
          ChangeCaption('Importar registros');
          Before := Probe.FDraws;
          B.Caption := B.Caption; Pump;
          Require(Probe.FDraws = Before, 'Caption identico refez o frame sem necessidade.');
          B.Enabled := False; Pump;
          ChangeCaption('Importar 138 registros');
          B.Enabled := True; Pump;
        end;

    B.Size := mbsMedium; B.Caption := 'Importar 138 registros';
    B.Font.Name := 'Segoe UI'; B.Font.Size := 8; B.Font.Style := []; Pump;
    OldWidth := LabelControl.Width; Before := Probe.FDraws;
    B.Font.Size := 14; Pump;
    Require(Probe.FDraws > Before, 'Fonte mudou sem reconstruir o frame Skia.');
    Require(LabelControl.Width > OldWidth, 'Fonte maior nao recalculou a largura do texto.');
    Require(LabelControl.FontSize = 14, 'Fonte medida e fonte nativa divergem.');
    Require(LabelControl.FontFamily = 'Segoe UI', 'Familia da fonte nao aplicada.');
    OldWidth := LabelControl.Width;
    B.Font.Style := [fsBold]; Pump;
    Require(LabelControl.Bold and (LabelControl.Width >= OldWidth), 'Negrito nao participou do layout.');
    B.ParentFont := True; Pump;
    Require(LabelControl.FontSize < 14, 'Retorno ao preset nao recalculou a fonte.');

    OutputDir := GetEnvironmentVariable('DAC_BUTTON_LAYOUT_OUTPUT_DIR');
    if OutputDir <> '' then
    begin
      ForceDirectories(OutputDir); B.Size := mbsLarge; B.ThemeMode := dtmLight;
      B.IconPosition := mipLeft; B.SetBounds(16,16,300,52);
      B.Caption := 'Importar 138 registros'; Pump;
      Bitmap := TBitmap.Create; PNG := TPngImage.Create;
      Bitmap.SetSize(B.Width,B.Height); B.PaintTo(Bitmap.Canvas.Handle,0,0);
      PNG.Assign(Bitmap); PNG.SaveToFile(TPath.Combine(OutputDir,'caption-expanded.png'));
    end;
    Writeln('Button layout: ', Cases, ' runtime caption transitions + font metrics: PASS');
  finally
    if Box <> nil then Box.OnDraw := Probe.FOriginal;
    PNG.Free; Bitmap.Free; Host.Free; Probe.Free;
  end;
end;

end.
