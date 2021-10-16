unit uStreamedResource;

interface

uses uUnityClass, uEndianStream;

type
  TStreamedResource = class (TUnityClass)
    private
      var m_Source: AnsiString;
      var m_Offset: UInt64;
      var m_Size: UInt64;
    public
      procedure Load(const stream: TEndianStream); override;
      property Source: AnsiString read m_Source;
      property Offset: UInt64 read m_Offset;
      property Size: UInt64 read m_size;
  end;

implementation

uses uConsole;

procedure TStreamedResource.Load(const stream: TEndianStream);
begin
  stream.ReadStr(m_Source);
  stream.Align;
  stream.ReadUInt64(m_Offset);
  stream.ReadUInt64(m_Size);
end;

end.
