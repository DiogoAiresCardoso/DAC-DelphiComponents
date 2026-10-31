unit DAC.Components.Controls.DBTreeView.DataLink;

interface

uses System.Classes, Data.DB;

type
  TDACDBTreeLinkChange = (tlcActive, tlcData, tlcRecord, tlcScroll,
    tlcLayout, tlcEditing);
  TDACDBTreeLinkEvent = procedure(Sender: TObject;
    Change: TDACDBTreeLinkChange; Field: TField) of object;
  TDACDBTreeDataLink = class(TDataLink)
  private
    FOnChanged: TDACDBTreeLinkEvent;
    procedure Changed(Change: TDACDBTreeLinkChange; Field: TField = nil);
  protected
    procedure ActiveChanged; override;
    procedure DataSetChanged; override;
    procedure DataSetScrolled(Distance: Integer); override;
    procedure RecordChanged(Field: TField); override;
    procedure LayoutChanged; override;
    procedure EditingChanged; override;
  public
    constructor Create;
    property OnChanged: TDACDBTreeLinkEvent read FOnChanged write FOnChanged;
  end;

implementation

constructor TDACDBTreeDataLink.Create;
begin
  inherited Create;
  VisualControl := True;
end;

procedure TDACDBTreeDataLink.Changed(Change: TDACDBTreeLinkChange; Field: TField);
begin
  if Assigned(FOnChanged) then FOnChanged(Self, Change, Field);
end;

procedure TDACDBTreeDataLink.ActiveChanged;
begin Changed(tlcActive); end;
procedure TDACDBTreeDataLink.DataSetChanged;
begin Changed(tlcData); end;
procedure TDACDBTreeDataLink.DataSetScrolled(Distance: Integer);
begin
  { TDataLink's inherited implementation calls DataSetChanged. A cursor move
    must never be confused with invalidation of the complete catalogue. }
  Changed(tlcScroll);
end;
procedure TDACDBTreeDataLink.RecordChanged(Field: TField);
begin Changed(tlcRecord, Field); end;
procedure TDACDBTreeDataLink.LayoutChanged;
begin Changed(tlcLayout); end;
procedure TDACDBTreeDataLink.EditingChanged;
begin Changed(tlcEditing); end;

end.
