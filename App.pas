unit App;

interface
  uses
    Windows, Messages, SysUtils, Variants, Classes, Graphics,
    Controls, Forms, Dialogs, StdCtrls, ExtCtrls, XPMAN;

  type
    rgb = record
    r, g, b: byte;
end;

TAppForm = class(TForm)
  ButtonOpen: TButton;
  ButtonFilter: TButton;
  FileDialog: TOpenDialog;
  ImageArea: TImage;

  procedure ButtonFilterClick(Sender: TObject);
  procedure ButtonOpenClick(Sender: TObject);
  function ff(i: integer): rgb;
  function sob(p: rgb): integer;
end;

var
  AppForm: TAppForm;
  pic: TBitmap;

implementation

{$R *.dfm}
function TAppForm.ff(i: integer): rgb;
begin
  result.r := (i and $ff0000) shr 16;
  result.g := (i and $00FF00) shr 8;
  result.b := (i and $0000ff);
end;

function TAppForm.sob(p: rgb): integer;
begin
  result := p.b or (p.g shl 8) or (p.r shl 16);
end;

// Handle file opening
procedure TAppForm.ButtonOpenClick(Sender: TObject);
begin
  pic := TBitmap.Create;
  pic.PixelFormat := pf24bit;

  if FileDialog.Execute then
    pic.LoadFromFile(FileDialog.FileName);

  // clear the old image
  ImageArea.Picture := nil;

  ImageArea.Canvas.draw(0, 0, pic);
end;

// Handle filtering
procedure TAppForm.ButtonFilterClick(Sender: TObject);
type
  pl = record
  l, w, u: integer;
end;
const k = 10;
var
  tempbmp: TBitmap;
  temp: pl;
  buf: rgb;
  h: array[0..2, 0..2] of integer;
  i, j: integer;
  p, q: byte;
  begin
    tempbmp := TBitmap.Create;
    tempbmp.PixelFormat := pf24bit;
    tempbmp := pic;

    // weighted values (convloution filter)
    h[0,0] := 0;
    h[0,1] := -1;
    h[0,2] := 0;
    h[1,0] := -1;
    h[1,1] := 4;
    h[1,2] := -1;
    h[2,0] := 0;
    h[2,1] := -1;
    h[2,2] := 0;

    for i := 0 to pic.width - 1 do
      begin
        for j := 0 to pic.height - 1 do
          begin
            temp.l := 0;
            temp.w := 0;
            temp.u := 0;
            for p := 0 to 2 do
              begin
                for q := 0 to 2 do
                  begin
                    buf := ff(tempbmp.Canvas.Pixels[i + p - 1, j + q - 1]);
                    with temp do
                      begin
                        l := l + (h[p, q] * buf.r);
                        w := w + (h[p, q] * buf.g);
                        u := u + (h[p, q] * buf.b);
                      end;
                  end;
              end;
            with buf do
              begin
                r := trunc(temp.l / k);
                g := trunc(temp.w / k);
                b := trunc(temp.u / k);
              end;
            ImageArea.Canvas.Pixels[i, j] := sob(buf);
          end;
      end;
  end;
end.

