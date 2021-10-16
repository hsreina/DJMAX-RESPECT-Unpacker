unit uUnityArray;

interface

uses uUnityClass, uEndianStream;

type
  TUnityArray<T: TUnityClass, constructor> = class (TUnityClass)
    private
      var m_size: UInt32;
    public
      destructor Destroy; override;
      procedure Load(const stream: TEndianStream); override;
      var Data: array of T;
  end;

implementation

destructor TUnityArray<T>.Destroy;
begin
  inherited;
end;

procedure TUnityArray<T>.Load(const stream: TEndianStream);
var
  I: Integer;
  item: T;
begin
  stream.ReadUInt32(m_size);
  SetLength(Data, m_size);
  for I := 0 to m_size do
  begin
    item := T.Create;
    item.Load(stream);
    Data[I] := item;
  end;
end;

end.
