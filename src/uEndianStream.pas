unit uEndianStream;

interface

uses
  System.Classes;

type

{$SCOPEDENUMS ON}
  TEndian = (Little, Big);
{$SCOPEDENUMS OFF}


  TEndianStream = class (TStream)
    private
      var m_stream: TStream;
      var m_endian: TEndian;
    public
      constructor Create(const stream: TStream; const endian: TEndian = TEndian.Big);
      destructor Destroy; override;

      function Read(var Buffer; Count: Longint): Longint; override;
      function Seek(Offset: Longint; Origin: Word): Longint; overload; override;
      function Seek(const Offset: Int64; Origin: TSeekOrigin): Int64; overload; override;

      function Read2(var Buffer; Count: Longint): Boolean;

      function ReadUInt16(var value: UInt16): Boolean;
      function ReadInt16(var value: Int16): Boolean;
      function ReadUInt32(var value: UInt32): Boolean;
      function ReadInt32(var value: Int32): Boolean;
      function ReadUInt64(var value: UInt64): Boolean;
      function ReadInt64(var value: Int64): Boolean;
      function ReadBoolean(var value: Boolean): Boolean;
      function ReadUInt8(var value: UInt8): Boolean;
      function ReadFloat(var value: single): Boolean;
      procedure ReadZeroTerminatedString(var str: AnsiString);
      function ReadStr(var str: AnsiString): Boolean;
      procedure Align;
      property Endian: TEndian read m_endian;
  end;

implementation

constructor TEndianStream.Create(const stream: TStream; const endian: TEndian = TEndian.Big);
begin
  inherited Create;
  m_stream := stream;
  m_endian := endian;
end;

destructor TEndianStream.Destroy;
begin
  inherited;
end;

function TEndianStream.Read(var Buffer; Count: Integer): Longint;
begin
  Result := m_stream.Read(Buffer, count);
end;

function TEndianStream.Seek(Offset: Integer; Origin: Word): LongInt;
begin
  Result := m_stream.Seek(offset, Origin);
end;

function TEndianStream.Seek(const Offset: Int64; Origin: TSeekOrigin): Int64;
begin
  Result := m_stream.Seek(offset, Origin);
end;

function TEndianStream.Read2(var Buffer; Count: Longint): Boolean;
begin
  Result := Read(Buffer, Count) = Count;
end;

procedure SwapBytes(Var bytes; len: Integer);
Var
  swapped: PAnsiChar;
  i: Integer;
Begin
  GetMem(swapped, len);
  Try
   for i := 0 to len - 1 do
   begin
    swapped[Len-i-1] := PAnsiChar(@bytes)[i];
   end;
   Move(swapped^, bytes, len);
  Finally
   FreeMem(swapped);
  End;
End;

function TEndianStream.ReadUInt16(var value: UInt16): Boolean;
begin
  Result := m_stream.Read(value, 2) = 2;
  if m_endian = TEndian.Big then
  begin
    SwapBytes(value, 2);
  end;
end;

function TEndianStream.ReadInt16(var value: Int16): Boolean;
begin
  Result := m_stream.Read(value, 2) = 2;
  if m_endian = TEndian.Big then
  begin
    SwapBytes(value, 2);
  end;
end;

function TEndianStream.ReadUInt32(var value: UInt32): Boolean;
begin
  Result := m_stream.Read(value, 4) = 4;
  if m_endian = TEndian.Big then
  begin
    SwapBytes(value, 4);
  end;
end;

function TEndianStream.ReadInt32(var value: Int32): Boolean;
begin
  Result := m_stream.Read(value, 4) = 4;
  if m_endian = TEndian.Big then
  begin
    SwapBytes(value, 4);
  end;
end;

function TEndianStream.ReadUInt64(var value: UInt64): Boolean;
begin
  Result := m_stream.Read(value, 8) = 8;
  if m_endian = TEndian.Big then
  begin
    SwapBytes(value, 8);
  end;
end;

function TEndianStream.ReadInt64(var value: Int64): Boolean;
begin
  Result := m_stream.Read(value, 8) = 8;
  if m_endian = TEndian.Big then
  begin
    SwapBytes(value, 8);
  end;
end;

function TEndianStream.ReadBoolean(var value: Boolean): Boolean;
begin
  Result := m_stream.Read(value, 1) = 1;
end;

function TEndianStream.ReadUInt8(var value: UInt8): Boolean;
begin
  Result := Read2(value, 1);
end;

function TEndianStream.ReadFloat(var value: Single): Boolean;
begin
  Result := m_stream.Read(value, 4) = 4;
end;

procedure TEndianStream.ReadZeroTerminatedString(var str: AnsiString);
var
  chr: AnsiChar;
  res: Integer;
begin
  str := '';
  while True do
  begin
    Res := Read(chr, 1);
    if (Res = 0) or (chr = #00) then
    begin
      break;
    end;
    str := str + chr;
  end;
end;

procedure TEndianStream.Align;
var
  cut: Int64;
begin
  cut := High(Int64) - 3;
  Position := (Position + 3) and cut;
end;

function TEndianStream.ReadStr(var str: AnsiString): Boolean;
var
  strLen: UInt32;
begin
  if ReadUInt32(strLen) then
  begin
    SetLength(str, strLen);
    Read(str[1], strLen);
  end;
end;

end.
