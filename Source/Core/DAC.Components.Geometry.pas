unit DAC.Components.Geometry;

interface

uses
  System.Types;

function DACInflateRectF(const ARect: TRectF; const AValue: Single): TRectF;
function DACRectCenter(const ARect: TRectF): TPointF;
function DACRectContains(const ARect: TRectF; const APoint: TPointF): Boolean;

implementation

function DACInflateRectF(const ARect: TRectF; const AValue: Single): TRectF;
begin
  Result := ARect;
  Result.Inflate(AValue, AValue);
end;

function DACRectCenter(const ARect: TRectF): TPointF;
begin
  Result := TPointF.Create(ARect.Left + (ARect.Width / 2), ARect.Top + (ARect.Height / 2));
end;

function DACRectContains(const ARect: TRectF; const APoint: TPointF): Boolean;
begin
  Result := (APoint.X >= ARect.Left) and (APoint.X <= ARect.Right) and
    (APoint.Y >= ARect.Top) and (APoint.Y <= ARect.Bottom);
end;

end.

