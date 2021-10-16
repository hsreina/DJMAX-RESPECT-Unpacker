unit uAssetInfo;

interface

uses uUnityClass, uEndianStream, uPreloadItem;

type
  TAssetInfo = class (TUnityClass)
    private
      var preloadIndex: Int32;
      var preloadSize: Int32;
      var asset: TPreloadItem;
      function GetFileID: Int32;
      function GetPathID: Int64;
    public
      constructor Create;
      destructor Destroy; override;
      procedure Load(const stream: TEndianStream); override;
      property FileID: Int32 read GetFileID;
      property PathID: Int64 read GetPathID;
  end;

implementation

uses uConsole;

constructor TAssetInfo.Create;
begin
  inherited;
  asset := TPreloadItem.Create;
end;

destructor TAssetInfo.Destroy;
begin
  asset.Free;
  inherited;
end;

procedure TAssetInfo.Load(const stream: TEndianStream);
begin
  stream.ReadInt32(preloadIndex);
  stream.ReadInt32(preloadSize);
  asset.Load(stream);
end;

function TAssetInfo.GetFileID: Int32;
begin
  Result := asset.FileID;
end;

function TAssetInfo.GetPathID: Int64;
begin
  Result := asset.PathID;
end;

end.
