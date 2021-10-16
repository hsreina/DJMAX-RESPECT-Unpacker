unit utils;

interface

uses
  System.Classes;

procedure DumpStream(const filename: string; const stream: TStream; const size: Int64); overload;
procedure DumpStream(const filename: string; const stream: TStream); overload;

implementation

procedure DumpStream(const filename: string; const stream: TStream; const size: Int64);
var
  destinationFileStream: TFileStream;
  oldPos: Int64;
begin
  oldPos := stream.Position;
  destinationFileStream := TFileStream.Create(filename, fmCreate);
  destinationFileStream.CopyFrom(stream, size);
  destinationFileStream.Free;
  stream.Position := oldPos;
end;

procedure DumpStream(const filename: string; const stream: TStream);
var
  oldPos: Int64;
begin
  oldPos := stream.Position;
  stream.Position := 0;
  DumpStream(filename, stream, stream.Size);
  stream.Position := oldPos;
end;

end.
