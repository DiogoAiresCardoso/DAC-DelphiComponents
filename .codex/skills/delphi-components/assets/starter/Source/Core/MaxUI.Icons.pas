unit MaxUI.Icons;

{$CODEPAGE 65001}

interface

uses
  System.Types,
  Vcl.Graphics,
  MaxUI.Types;

type
  TMaxIconPainter = class sealed
  public
    class procedure Draw(ACanvas: TCanvas; const ARect: TRect;
      const AKind: TMaxIconKind; const AColor: TColor;
      const ALineWidth: Integer = 1); static;
  end;

implementation

uses
  System.Math,
  Winapi.Windows;

class procedure TMaxIconPainter.Draw(ACanvas: TCanvas; const ARect: TRect;
  const AKind: TMaxIconKind; const AColor: TColor; const ALineWidth: Integer);
var
  R: TRect;
  CX: Integer;
  CY: Integer;
  W: Integer;
  H: Integer;
  S: Integer;
  OldBrush: TBrushStyle;
  OldPenColor: TColor;
  OldPenWidth: Integer;
  OldPenStyle: TPenStyle;

  procedure Line(X1, Y1, X2, Y2: Integer);
  begin
    ACanvas.MoveTo(X1, Y1);
    ACanvas.LineTo(X2, Y2);
  end;

  procedure Circle(const Cx, Cy, Radius: Integer);
  begin
    ACanvas.Ellipse(Cx - Radius, Cy - Radius, Cx + Radius + 1, Cy + Radius + 1);
  end;

begin
  if (ACanvas = nil) or (AKind = mikNone) then
    Exit;

  R := ARect;
  W := Max(1, R.Width);
  H := Max(1, R.Height);
  CX := (R.Left + R.Right) div 2;
  CY := (R.Top + R.Bottom) div 2;
  S := Max(2, Min(W, H) div 3);

  OldBrush := ACanvas.Brush.Style;
  OldPenColor := ACanvas.Pen.Color;
  OldPenWidth := ACanvas.Pen.Width;
  OldPenStyle := ACanvas.Pen.Style;
  try
    ACanvas.Brush.Style := bsClear;
    ACanvas.Pen.Style := psSolid;
    ACanvas.Pen.Color := AColor;
    ACanvas.Pen.Width := Max(1, ALineWidth);

    case AKind of
      mikPlus:
        begin
          Line(CX - S, CY, CX + S, CY);
          Line(CX, CY - S, CX, CY + S);
        end;

      mikEdit:
        begin
          Line(CX - S, CY + S, CX + S, CY - S);
          Line(CX - S, CY + S, CX - S + 2, CY + S - 4);
          Line(CX + S - 3, CY - S - 1, CX + S + 1, CY - S + 3);
        end;

      mikCheck:
        begin
          Line(CX - S, CY, CX - 1, CY + S);
          Line(CX - 1, CY + S, CX + S + 2, CY - S);
        end;

      mikWarning:
        begin
          ACanvas.Polygon([
            Point(CX, CY - S - 2),
            Point(CX - S - 2, CY + S + 1),
            Point(CX + S + 2, CY + S + 1)
          ]);
          Line(CX, CY - S + 2, CX, CY + 2);
          Circle(CX, CY + S - 2, 1);
        end;

      mikDelete:
        begin
          ACanvas.Rectangle(CX - S, CY - S + 1, CX + S + 1, CY + S + 2);
          Line(CX - S - 2, CY - S + 1, CX + S + 2, CY - S + 1);
          Line(CX - 2, CY - S - 2, CX + 2, CY - S - 2);
          Line(CX - 2, CY - S - 2, CX - 2, CY - S + 1);
          Line(CX + 2, CY - S - 2, CX + 2, CY - S + 1);
        end;

      mikSearch:
        begin
          Circle(CX - 2, CY - 2, S - 1);
          Line(CX + S - 3, CY + S - 3, CX + S + 3, CY + S + 3);
        end;

      mikEye,
      mikEyeOff:
        begin
          ACanvas.Arc(CX - S - 3, CY - S, CX + S + 3, CY + S,
            CX - S - 2, CY, CX + S + 2, CY);
          ACanvas.Arc(CX - S - 3, CY - S, CX + S + 3, CY + S,
            CX + S + 2, CY, CX - S - 2, CY);
          Circle(CX, CY, Max(1, S div 3));
          if AKind = mikEyeOff then
            Line(CX - S - 3, CY + S + 2, CX + S + 3, CY - S - 2);
        end;

      mikCalendar:
        begin
          ACanvas.Rectangle(CX - S - 2, CY - S, CX + S + 3, CY + S + 3);
          Line(CX - S - 2, CY - S + 4, CX + S + 2, CY - S + 4);
          Line(CX - S + 2, CY - S - 2, CX - S + 2, CY - S + 2);
          Line(CX + S - 2, CY - S - 2, CX + S - 2, CY - S + 2);
        end;

      mikClock:
        begin
          Circle(CX, CY, S + 1);
          Line(CX, CY, CX, CY - S + 2);
          Line(CX, CY, CX + S - 2, CY + 2);
        end;

      mikChevronDown:
        begin
          Line(CX - S, CY - S div 2, CX, CY + S div 2);
          Line(CX, CY + S div 2, CX + S, CY - S div 2);
        end;

      mikChevronLeft:
        begin
          Line(CX + S div 2, CY - S, CX - S div 2, CY);
          Line(CX - S div 2, CY, CX + S div 2, CY + S);
        end;

      mikChevronRight:
        begin
          Line(CX - S div 2, CY - S, CX + S div 2, CY);
          Line(CX + S div 2, CY, CX - S div 2, CY + S);
        end;

      mikInfo:
        begin
          Circle(CX, CY, S + 1);
          Circle(CX, CY - S div 2, 1);
          Line(CX, CY - 1, CX, CY + S div 2 + 2);
        end;

      mikClose:
        begin
          Line(CX - S, CY - S, CX + S, CY + S);
          Line(CX + S, CY - S, CX - S, CY + S);
        end;

      mikCurrency:
        begin
          Circle(CX, CY, S + 2);
          Line(CX, CY - S + 1, CX, CY + S - 1);
          ACanvas.Arc(CX - S div 2, CY - S + 1, CX + S div 2 + 1, CY + 1,
            CX + S div 2, CY - S div 2, CX - S div 2, CY - S div 2);
          ACanvas.Arc(CX - S div 2, CY, CX + S div 2 + 1, CY + S,
            CX - S div 2, CY + S div 2, CX + S div 2, CY + S div 2);
        end;

      mikCart:
        begin
          Line(CX - S - 2, CY - S, CX - S + 1, CY - S);
          Line(CX - S + 1, CY - S, CX - S + 4, CY + S - 1);
          Line(CX - S + 4, CY + S - 1, CX + S + 2, CY + S - 1);
          Line(CX - S + 3, CY - 1, CX + S + 3, CY - 1);
          Circle(CX - S + 5, CY + S + 2, 1);
          Circle(CX + S, CY + S + 2, 1);
        end;

      mikUsers:
        begin
          Circle(CX - 3, CY - S div 2, Max(2, S div 2));
          Circle(CX + S, CY - S div 2 + 1, Max(1, S div 3));
          ACanvas.Arc(CX - S - 2, CY, CX + 4, CY + S + 5,
            CX + 3, CY + S, CX - S - 1, CY + S);
          ACanvas.Arc(CX + 1, CY + 1, CX + S + 5, CY + S + 4,
            CX + S + 3, CY + S, CX + 1, CY + S);
        end;

      mikBox:
        begin
          ACanvas.Polygon([
            Point(CX, CY - S - 2),
            Point(CX + S + 2, CY - 2),
            Point(CX, CY + S + 2),
            Point(CX - S - 2, CY - 2)
          ]);
          Line(CX, CY + S + 2, CX, CY);
          Line(CX, CY, CX + S + 2, CY - 2);
          Line(CX, CY, CX - S - 2, CY - 2);
        end;

      mikDocument:
        begin
          ACanvas.Rectangle(CX - S, CY - S - 2, CX + S + 1, CY + S + 3);
          Line(CX - S + 3, CY - 2, CX + S - 3, CY - 2);
          Line(CX - S + 3, CY + 2, CX + S - 3, CY + 2);
          Line(CX - S + 3, CY + 6, CX + S - 3, CY + 6);
        end;

      mikLock:
        begin
          ACanvas.Rectangle(CX - S, CY - 1, CX + S + 1, CY + S + 3);
          ACanvas.Arc(CX - S + 2, CY - S - 2, CX + S - 1, CY + 3,
            CX + S - 1, CY, CX - S + 2, CY);
        end;

      mikLeaf:
        begin
          ACanvas.Arc(CX - S - 2, CY - S - 2, CX + S + 3, CY + S + 3,
            CX + S + 2, CY - S + 1, CX - S + 1, CY + S + 2);
          Line(CX - S, CY + S, CX + S, CY - S);
        end;
    end;
  finally
    ACanvas.Brush.Style := OldBrush;
    ACanvas.Pen.Color := OldPenColor;
    ACanvas.Pen.Width := OldPenWidth;
    ACanvas.Pen.Style := OldPenStyle;
  end;
end;

end.
