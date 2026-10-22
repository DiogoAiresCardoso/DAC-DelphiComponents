unit DAC.Components.Controls.DBGrid.DataLink;

interface

uses
  Data.DB,
  Vcl.DBGrids,
  DAC.Components.Controls.DBGrid.Types;

type
  TDACDBGridDataLink = class(TGridDataLink)
  private
    FOnChanged: TDACDBGridDataLinkNotifyEvent;
    procedure NotifyChanged(AField: TField);
  protected
    procedure ActiveChanged; override;
    procedure DataSetChanged; override;
    procedure DataSetScrolled(Distance: Integer); override;
    procedure LayoutChanged; override;
    procedure RecordChanged(Field: TField); override;
  public
    procedure MoveViewport(const ADistance: Integer);
    property OnChanged: TDACDBGridDataLinkNotifyEvent
      read FOnChanged write FOnChanged;
  end;

implementation

procedure TDACDBGridDataLink.MoveViewport(const ADistance: Integer);
begin
  MoveBy(ADistance);
end;

procedure TDACDBGridDataLink.ActiveChanged;
begin
  inherited;
  NotifyChanged(nil);
end;

procedure TDACDBGridDataLink.DataSetChanged;
begin
  inherited;
  NotifyChanged(nil);
end;

procedure TDACDBGridDataLink.DataSetScrolled(Distance: Integer);
begin
  inherited;
  NotifyChanged(nil);
end;

procedure TDACDBGridDataLink.LayoutChanged;
begin
  inherited;
  NotifyChanged(nil);
end;

procedure TDACDBGridDataLink.NotifyChanged(AField: TField);
begin
  if Assigned(FOnChanged) then
    FOnChanged(Self, AField);
end;

procedure TDACDBGridDataLink.RecordChanged(Field: TField);
begin
  inherited;
  NotifyChanged(Field);
end;

end.
