unit uWav;


interface

uses
  System.Classes, uAudioClip;

type
  TDataHeader = record
    idData: array[0..3] of AnsiChar;
    DataLen: longint;
  end;

  TWaveHeader = record
    idRiff: array[0..3] of AnsiChar;
    RiffLen: longint;
    idWave: array[0..3] of AnsiChar;
    idFmt: array[0..3] of AnsiChar;
    InfoLen: longint;
    WaveType: smallint;
    Ch: smallint;
    Freq: longint;
    BytesPerSec: longint;
    align: smallint;
    Bits: smallint;
    data: TDataHeader;
  end;

{$SCOPEDENUMS ON}
{$Z4}
  TFSBSoundFormat = (
    NONE = 0,
    PCM8 = 1,
    PCM16 = 2,
    PCM24 = 3,
    PCM32 = 4,
    PCMFLOAT = 5,
    GCADPCM = 6,
    IMAADPCM = 7,
    VAG = 8,
    HEVAG = 9,
    XMA = 10,
    MPEG = 11,
    CELT = 12,
    AT9 = 13,
    XWMA = 14,
    VORBIS = 15
  );
{$Z1}
{$SCOPEDENUMS OFF}

  TFSBHeader = packed record
    sign: array [0..3] of AnsiChar;
    version: UInt32;
    numSamples: UInt32;
    sampleHeadersSize: UInt32;
    nameTableSize: UInt32;
    dataSize: UInt32;
    mode: TFSBSoundFormat;
    zero: array [0..7] of AnsiChar;
    hash: array [0..15] of AnsiChar;
    metaData: UInt64;
    size: UInt32;
  end;

procedure ConvertDebug(const filename: AnsiString; const stream: TStream; const audioClip: TAudioClip);

implementation

uses
  System.IOUtils, ACS_Wave, ACS_Vorbis, System.SysUtils, uConsole;

function bits(val: UInt64; start, len: Byte): UInt64;
var
  stop: UInt64;
begin
  stop := start + len;
  Result := val and ((1 shl stop)-1) shr start;
end;

procedure MoveAnsiString(const Source: AnsiString; var Dest; Count: NativeInt);
begin
  Move(Source[1], Dest, count);
end;

procedure ConvertDebug(const filename: AnsiString; const stream: TStream; const audioClip: TAudioClip);
var
  fsbHeader: TFSBHeader;
  wavHeader: TWaveHeader;
  next_chunk, frequency, channels, dataOffset, samples: UInt64;
  fileStream: TFileStream;
  str: AnsiString;
  dataSize: UInt32;
  wave: TWaveIn;
  vorbis: TVorbisOut;
  waveStream: TMemoryStream;
  outputname: AnsiString;
begin
  stream.Read(fsbHeader.sign[0], SizeOf(TFSBHeader));

  next_chunk  := bits(fsbHeader.metaData, 0,        1);
  frequency   := bits(fsbHeader.metaData, 1,        4);
  channels    := bits(fsbHeader.metaData, 1+4,      1)  + 1;
  dataOffset 	:= bits(fsbHeader.metaData, 1+4+1,    28) * 16;
  samples     := bits(fsbHeader.metaData, 1+4+1+28, 30);

  MoveAnsiString('RIFF', wavHeader.idRiff[0], 4);
  MoveAnsiString('data', wavHeader.data.idData[0], 4);
  MoveAnsiString('WAVE', wavHeader.idWave, 4);
  MoveAnsiString('fmt ', wavHeader.idFmt, 4);
  wavheader.InfoLen := $10;
  wavheader.WaveType := 1;
  wavheader.Ch := audioCLip.Channels;
  wavheader.Freq := audioCLip.Frequency;
  wavheader.BytesPerSec := (audioCLip.Frequency * audioCLip.BitsPerSample * audioCLip.Channels) div 8;
  wavheader.align := 4;
  wavheader.Bits := audioCLip.BitsPerSample;

  dataSize := stream.Size - $60;

  wavheader.RiffLen := dataSize + $24;

  wavheader.data.DataLen := dataSize;


  wave := TWaveIn.Create(nil);
  waveStream := TMemoryStream.Create;
  waveStream.Write(wavHeader.idRiff[0], SizeOf(TWaveHeader));
  stream.Position := $60;
  waveStream.CopyFrom(stream, stream.Size - $60);

  waveStream.Position := 0;
  wave.Stream := waveStream;

  Console.Log('Converting %s', [ExtractFileName(filename)]);

  outputname := StringReplace(filename, '.wav', '.ogg', [rfReplaceAll]);
  vorbis := TVorbisOut.Create(nil);
  vorbis.FileName := outputname;
  vorbis.MinimumBitrate := TVorbisBitRate.bitrate192;
  vorbis.DesiredMaximumBitrate := TVorbisBitRate.brAutoSelect;
  vorbis.DesiredNominalBitrate := TVorbisBitRate.brAutoSelect;
  vorbis.Compression := 0;
  vorbis.Input := wave;
  vorbis.BlockingRun;
  vorbis.Free;

  waveStream.Free;
  wave.Free;

  {
  fileStream := TFile.Open(filename, TFileMode.fmCreate);
  fileStream.Write(wavHeader.idRiff[0], SizeOf(TWaveHeader));
  stream.Position := $60;
  fileStream.CopyFrom(stream, stream.Size - $60);
  fileStream.Free;
  }
end;

end.
