unit MaxxRural.Components.Geometry;

interface

uses
  System.Types;

function MaxxRuralInflateRectF(const ARect: TRectF; const AValue: Single): TRectF;
function MaxxRuralRectCenter(const ARect: TRectF): TPointF;
function MaxxRuralRectContains(const ARect: TRectF; const APoint: TPointF): Boolean;

implementation

function MaxxRuralInflateRectF(const ARect: TRectF; const AValue: Single): TRectF;
begin
  Result := ARect;
  Result.Inflate(AValue, AValue);
end;

function MaxxRuralRectCenter(const ARect: TRectF): TPointF;
begin
  Result := TPointF.Create(ARect.Left + (ARect.Width / 2), ARect.Top + (ARect.Height / 2));
end;

function MaxxRuralRectContains(const ARect: TRectF; const APoint: TPointF): Boolean;
begin
  Result := (APoint.X >= ARect.Left) and (APoint.X <= ARect.Right) and
    (APoint.Y >= ARect.Top) and (APoint.Y <= ARect.Bottom);
end;

end.
