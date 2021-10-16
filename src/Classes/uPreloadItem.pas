unit uPreloadItem;

interface

uses uUnityClass, uEndianStream;

type
  TPreloadItem = class (TUnityClass)
    private
      m_FileID: Int32;
      m_PathID: Int64;
    public
      procedure Load(const stream: TEndianStream); overload;
      property FileID: Int32 read m_FileID;
      property PathID: Int64 read m_PathID;
  end;

implementation

procedure TPreloadItem.Load(const stream: TEndianStream);
begin
  stream.ReadInt32(m_FileID);
  stream.ReadInt64(m_PathID);
end;

end.
