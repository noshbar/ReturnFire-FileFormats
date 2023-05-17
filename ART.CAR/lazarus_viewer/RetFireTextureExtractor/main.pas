unit main;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, ExtCtrls,
  Grids, game_palette;

const
  TILE_ZOOM = 6;

type

  TDataHeader = record
    dataHeaderFileOffset: longint;
    dataType : byte;
    length: byte;
    fileOffset: longint;
    headerData: array[0..47] of byte;
    width: longint;
    height: longint;
    data : array of byte;
  end;

  { TfrmMain }

  TfrmMain = class(TForm)
    cboDataHeaders : TComboBox;
    imgOutput : TImage;
    memData : TMemo;
    gridData : TStringGrid;
    ofd : TOpenDialog;
    procedure cboDataHeadersChange(Sender : TObject);
    procedure FormCreate(Sender : TObject);
    procedure imgOutputMouseDown(Sender : TObject; Button : TMouseButton; Shift : TShiftState; X, Y : Integer);
  private
  var
    dataHeaders: array of TDataHeader;
    doubleBuffer: TBitmap;
  public
    procedure LoadArtCar(path: String);
    procedure DrawTile(data : TDataHeader; x : integer; y : integer; zoom : integer; can: TCanvas);
  end;

var
  frmMain : TfrmMain;

implementation

{$R *.lfm}

{ TfrmMain }

procedure TfrmMain.FormCreate(Sender : TObject);
var
  index : integer;
  filepath : string;
begin
  filepath := 'D:\games\returnfire\ART\art.car';
  if not FileExists(filepath) then
  begin
    if not ofd.Execute then
    begin
      Application.Terminate;
      exit;
    end;
    filepath := ofd.FileName;
  end;

  doubleBuffer := TBitmap.Create;
  doubleBuffer.PixelFormat := TPixelFormat.pf32bit;

  LoadArtCar(filepath);
  cboDataHeaders.Clear();
  for index := 0 to Length(dataHeaders)-1 do
  begin
    cboDataHeaders.Items.Add('DataHeader' + IntToStr(index));
  end;
end;

procedure TfrmMain.imgOutputMouseDown(Sender : TObject; Button : TMouseButton; Shift : TShiftState; X, Y : Integer);
var
  choice : TDataHeader;
  selection : TGridRect;
begin
  choice := dataHeaders[cboDataHeaders.ItemIndex];
  X := X div TILE_ZOOM;
  Y := Y div TILE_ZOOM;
  memData.Lines.Add(inttostr( choice.data[X + Y * choice.width] ) );
  selection.Left := x+1;
  selection.top := y+1;
  selection.width := 0;
  selection.height := 0;
  gridData.Selection := selection;
end;

procedure PutPixel(x : integer; y : integer; value: byte; zoom: integer; canvas: TCanvas);
var
  xx, yy : integer;
begin
  for yy := 0 to zoom-1 do
  begin
    for xx := 0 to zoom-1 do
    begin
      canvas.Pixels[x * zoom + xx, y * zoom + yy] := TGamePalette[value];
    end;
  end;
end;

procedure TfrmMain.DrawTile(data : TDataHeader; x : integer; y : integer; zoom : integer; can: TCanvas);
var
  xx, yy : integer;
  src, dest: TRect;
begin
  doubleBuffer.width := data.width * zoom;
  doubleBuffer.height := data.height * zoom;
  doubleBuffer.Canvas.Brush.Color := clBlack;
  doubleBuffer.Canvas.Clear();
  src.left := 0;
  src.top := 0;
  src.width := data.width * zoom;
  src.height := data.height * zoom;

  for yy := 0 to data.height-1 do
  begin
    for xx := 0 to data.width-1 do
    begin
      PutPixel(xx, yy, data.data[xx + yy * data.width], zoom, doubleBuffer.Canvas);
    end;
  end;

  dest.left := x * zoom;
  dest.top := y * zoom;
  dest.width := src.width;
  dest.height := src.height;
  can.CopyRect(dest, doubleBuffer.Canvas, src);
end;

procedure TfrmMain.cboDataHeadersChange(Sender : TObject);
var
  choice : TDataHeader;
  x, y : integer;
  zoom : integer;
  line : string;
begin
  zoom := TILE_ZOOM;

  choice := dataHeaders[cboDataHeaders.ItemIndex];

  imgOutput.Canvas.Brush.Color := clWhite;
  imgOutput.Canvas.Brush.Style := bsSolid;
  imgOutput.Canvas.Clear();
  imgOutput.Width := choice.width * zoom;
  imgOutput.Height := choice.height * zoom;
  imgOutput.Picture.Bitmap.Width := choice.width * zoom;
  imgOutput.Picture.Bitmap.Height := choice.height * zoom;

  DrawTile(choice, 0, 0, zoom, imgOutput.Picture.Bitmap.Canvas);

  memData.Clear;
  gridData.Clear;
  gridData.ColCount := choice.Width+1;
  gridData.RowCount := choice.height+1;

  for y := 0 to choice.height-1 do
  begin
    for x := 0 to choice.width-1 do
    begin
      gridData.Cells[x+1, y+1] := Format('%.*d',[3, choice.data[x+y*choice.width]]);
    end;
  end;
  memData.Lines.Add('');
  memData.Lines.Add('Header pos: ' + inttostr(choice.dataHeaderFileOffset));
  memData.Lines.Add('Data pos: ' + inttostr(choice.fileOffset));
  memData.Lines.Add(inttostr(choice.dataType));
  line := '';
  for x := 0 to 47 do
  begin
    line := line + ' ' + Format('%.*d',[3, choice.headerData[x]]);
    if x mod 8 = 7 then
      begin
        memData.Lines.Add(line);
        line := '';
      end;
  end;
  memData.Lines.Add(line);
end;

procedure TfrmMain.LoadArtCar(path: String);
var
  fileLength : longint;
  dataHeaderCount : longint;
  dataHeaderLength: longint;
  index : integer;
  artStream: TFileStream;
begin
  artStream := TFileStream.Create(path, fmOpenRead);

  // Read header
  artStream.ReadDword(); //magic CCBA
  fileLength := artStream.ReadDword();
  dataHeaderCount := artStream.ReadDword();
  dataHeaderLength := artStream.ReadDword();

  SetLength(dataHeaders, dataHeaderCount);

  for index := 0 to dataHeaderCount-1 do
  begin
    dataHeaders[index].dataHeaderFileOffset := artStream.Position;
    dataHeaders[index].dataType := artStream.ReadByte();
    memData.Lines.Add(inttostr(index) + ': ' + inttostr(dataHeaders[index].dataType));
    artStream.ReadByte(); //length
    artStream.ReadWord(); //unknown
    artStream.ReadDWord(); //zero
    dataHeaders[index].fileOffset := artStream.ReadDword();
    artStream.Read(dataHeaders[index].headerData, 48);
    dataHeaders[index].width := artStream.ReadDword();
    dataHeaders[index].height := artStream.ReadDword();
    SetLength(dataHeaders[index].data, dataHeaders[index].width * dataHeaders[index].height);
  end;

  for index := 0 to dataHeaderCount-1 do
  begin
    artStream.Seek(dataHeaders[index].fileOffset, TSeekOrigin.soBeginning);
    artStream.ReadBuffer(dataHeaders[index].data[0], dataHeaders[index].width * dataHeaders[index].height);
  end;

  artStream.Free();
end;

end.

