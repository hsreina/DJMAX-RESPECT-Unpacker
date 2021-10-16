unit uUnityFS;

interface

uses uEndianStream, System.Classes, System.SysUtils, Generics.Collections,
  uUnityClass, uUnityType, uAssetBundle, uStreamedResource, uAudioClip;

type

{$SCOPEDENUMS ON}
  TUnityFSCompressionType = (
		None = 0,
		LZMA = 1,
		LZ4 = 2,
		LZ4HZ = 3,
		LZHAM = 4
  );
{$SCOPEDENUMS OFF}

  TUnityFS = class
    private
      var m_version: UInt32;
      var m_assets: TDictionary<UInt64, TUnityClass>;
      var m_bundles: TDictionary<AnsiString, TStream>;
      procedure ExtractContent(const stream: TBytesStream);
      function Debug(const stream: TEndianStream; const unityType: TUnityType): TUnityClass;
      function GetAssetBundle: TAssetBundle;
    public
      constructor Create(const filename: string);
      destructor Destroy; override;
      function LoadAsset<T: TUnityClass>(name: AnsiString): T; overload;
      function LoadAsset(name: AnsiString): TUnityClass; overload;
      procedure ListAssets; overload;
      procedure ListAssets(var assets: TList<AnsiString>); overload;
      procedure SaveAudioClipToFile(const filename: AnsiString; const audioClip: TAudioClip);
  end;

const
  CompressionMask = $3F;
  HasEntryInfo = $40;
  MetadataAtTheEnd = $80;

implementation

uses lz4d, uConsole, UnityFSStringList, utils, uGeneric, uUnityTypeNode,
  uUnityClassId, uUnityClassFactory, uUnityT, uUnityClassMap, uAssetInfo, System.IOUtils,
  uWav;

Function CreateAnotherStream(const stream: TStream; const endianess: UInt32): TEndianStream;
begin
  if endianess = 0 then
  begin
    Result := TEndianStream.Create(stream, TEndian.Little);
  end else
  begin
    Result := TEndianStream.Create(stream, TEndian.Big);
  end;
end;

procedure TUnityFS.ExtractContent(const stream: TBytesStream);
type
  TFileEntry = record
    pathID: UInt64;
    dOffset: UInt32;
    dSize: UInt32;
    typeIndex: UInt32;
  end;
  TAdd = record
    id: Int64;
    unknown: int32;
  end;
var
  metadataSize, fileSize, dataOffset: UInt32;
  endianStream, anotherStream: TEndianStream;
  generation: UInt32;
  endianess: UInt32;


  strVersion: AnsiString;
  _platform: UInt32;
  serializeTypeTrees: Boolean;

  typesCount: UInt32;
  I: Integer;

  count: UInt32;

  entry: TFileEntry;
  entries: TList<TFileEntry>;

  fileStream: TFileStream;
  index: UInt32;

  unityTypes: TList<TUnityType>;
  unityType: TUnityType;

  stringList: TUnityFSStringList;

  numAdds, numRefs: UInt32;
  tmpStream: TMemoryStream;
  endianTmpStream: TEndianStream;
  unityClass: TUnityClass;
  add: TAdd;
  tmpInt32: Int32;
  tmpUInt32: UInt32;
begin

  unityTypes := TList<TUnityType>.Create;
  stringList := TUnityFSStringList.Create;

  endianStream := TEndianStream.Create(stream, TEndian.Big);
  endianStream.ReadUInt32(metadataSize);
  endianStream.ReadUInt32(fileSize);
  endianStream.ReadUInt32(generation);
  endianStream.ReadUInt32(dataOffset);
  if generation >= 9 then
  begin
    endianStream.ReadUInt32(endianess);
  end;
  endianStream.Free;


  anotherStream := CreateAnotherStream(stream, endianess);
  anotherStream.ReadZeroTerminatedString(strVersion);
  anotherStream.ReadUInt32(_platform);
  anotherStream.ReadBoolean(serializeTypeTrees);


  anotherStream.ReadUInt32(typesCount);
  for I := 1 to typesCount do
  begin
    unityType := TUnityType.Create(serializeTypeTrees, generation);
    unityType.Load(anotherStream);
    unityTypes.Add(unityType);
    // unityType.Dump;
  end;

  entries := TList<TFileEntry>.Create;
  anotherStream.ReadUInt32(count);
  Console.Log('Entries count: %d', [count]);
  for I := 1 to count do
  begin
    if generation >= 14 then
    begin
      anotherStream.Align();
      anotherStream.ReadUInt64(entry.pathID);
    end else
    begin
      anotherStream.ReadUInt32(tmpUInt32);
      entry.pathID := tmpUInt32;
    end;
    anotherStream.ReadUInt32(entry.dOffset);
    anotherStream.ReadUInt32(entry.dSize);
    anotherStream.ReadUInt32(entry.typeIndex);

    if generation < 16 then
    begin
      raise Exception.Create('Not implemented');
    end;
    if (generation >= 11) and (generation < 17) then
    begin
      raise Exception.Create('Not implemented');
    end;
    if generation < 11 then
    begin
      raise Exception.Create('Not implemented');
    end;
    if (generation > 15) and (generation < 17) then
    begin
      raise Exception.Create('Not implemented');
    end;
    entries.Add(entry);
  end;

  anotherStream.ReadUInt32(numAdds);
  if numAdds > 0 then
  begin
    raise Exception.Create('Not implemented');
  end;

  anotherStream.ReadUInt32(numRefs);
  if numRefs > 0 then
  begin
    raise Exception.Create('Not implemented');
  end;

  index := 0;
  for entry in entries do
  begin
    //break;
    unityType := unityTypes[entry.typeIndex];
    anotherStream.Position := dataOffset + entry.dOffset;

    tmpStream := TMemoryStream.Create;
    tmpStream.CopyFrom(anotherStream, entry.dSize);
    tmpStream.Position := 0;
    endianTmpStream := TEndianStream.Create(tmpStream, anotherStream.Endian);

    unityClass := Debug(endianTmpStream, unityType);

    m_assets.Add(entry.pathID, unityClass);

    endianTmpStream.Free;

    // break;

    //unityType.Dump;
    // fileStream := TFileStream.Create(String.Format('out/dump%d.dat', [index]), fmCreate);
    // tmpStream.Position := 0;
    // fileStream.CopyFrom(tmpStream, entry.dSize);
    // fileStream.Free;
    tmpStream.Free;
    Inc(index);
  end;

  for unityType in unityTypes do
  begin
    unityType.Free;
  end;
  unityTypes.Free;

    entries.Free;
  stringList.Free;
  anotherStream.Free;
end;

constructor TUnityFS.Create(const filename: string);
type
  TBlock = record
    decompressedSize, compressedSize: UInt32;
    flags: UInt16;
  end;
  TXXX = record
    offset, size: Int64;
    status: UInt32;
    name: AnsiString;
  end;  
var
  stream: TEndianStream;
  sourceFileStream: TFileStream;
  sign, playerVersion, engineVersion: AnsiString;
  // position: Int64;
  compressionType: TUnityFSCompressionType;

  size: UInt64;
  metadataCompressedSize, metadataDecompressedSize, flags: UInt32;

  source, destination: PAnsiChar;

  metadataMemoryStream: TBytesStream;
  metadataEndianStream: TEndianStream;

  count: Int32;

  blockCount: UInt32;

  blocks: TList<TBlock>;
  block: TBlock;

  nodes: TList<TXXX>;
  node: TXXX;
  
  I: Integer;

  blockMemoryStream: TBytesStream;
  tmpStream: TMemoryStream;
begin
  inherited Create;

  m_assets := TDictionary<UInt64, TUnityClass>.Create;
  m_bundles := TDictionary<AnsiString, TStream>.Create;

  if not FileExists(filename) then
  begin
    raise Exception.Create('File not found');
  end;


  sourceFileStream := TFileStream.Create(filename, fmOpenRead or fmShareDenyNone);
  stream := TEndianStream.Create(sourceFileStream, TEndian.Big);

  stream.ReadZeroTerminatedString(sign);

  stream.ReadUInt32(m_version);
  stream.ReadZeroTerminatedString(playerVersion);
  stream.ReadZeroTerminatedString(engineVersion);

  Console.Log('m_version: %x', [m_version]);
  Console.Log('playerVersion: %s', [playerVersion]);
  Console.Log('engineVersion: %s', [engineVersion]);

  if not (sign = 'UnityFS') then
  begin
    raise Exception.Create('Invalid sign');
  end;

  if not (m_version = 6) then
  begin
    raise Exception.Create('Unsupported version');
  end;

  stream.ReadUInt64(size);

  stream.ReadUInt32(metadataCompressedSize);
  stream.ReadUInt32(metadataDecompressedSize);
  stream.ReadUInt32(flags);

  metadataMemoryStream := TBytesStream.Create;

  compressionType := TUnityFSCompressionType(flags and CompressionMask);
  case compressionType of
    TUnityFSCompressionType.None:
    begin
      raise Exception.Create('Not implemented');
    end;
    TUnityFSCompressionType.LZMA:
    begin
      raise Exception.Create('Not implemented');
    end;
    TUnityFSCompressionType.LZ4,
    TUnityFSCompressionType.LZ4HZ:
    begin
      GetMem(source, metadataCompressedSize);
      GetMem(destination, metadataDecompressedSize);

      stream.Read(source[0], metadataCompressedSize);

      TLZ4.Decode(@source[0], @destination[0], metadataCompressedSize, metadataDecompressedSize);
      FreeMem(source);

      metadataMemoryStream.Write(destination[0], metadataDecompressedSize);
      metadataMemoryStream.Position := 0;
      FreeMem(destination);
    end;
    TUnityFSCompressionType.LZHAM:
    begin
      raise Exception.Create('Not implemented');
    end;
  end;

  metadataEndianStream := TEndianStream.Create(metadataMemoryStream, TEndian.Big);

  // guid skip
  metadataEndianStream.Position := metadataEndianStream.Position + $10;

  metadataEndianStream.ReadUInt32(blockCount);
  Console.Log('blockCount: %d', [blockCount]);
  
  blocks := TList<TBlock>.Create;
  for I := 1 to blockCount do
  begin
    metadataEndianStream.ReadUInt32(block.decompressedSize);
    metadataEndianStream.ReadUInt32(block.compressedSize);
    metadataEndianStream.ReadUInt16(block.flags);
    blocks.Add(block);
  end;

  metadataEndianStream.ReadInt32(count);

  Console.Log('count: %d', [count]);
  
  nodes := TList<TXXX>.Create;
  for I := 1 to count do
  begin
    metadataEndianStream.ReadInt64(node.offset);
    metadataEndianStream.ReadInt64(node.size);
    metadataEndianStream.ReadUInt32(node.status);
    metadataEndianStream.ReadZeroTerminatedString(node.name);
    Console.Log('dataName: %s', [node.name]);
    nodes.Add(node);
  end;

  // try to extract all blocks
  blockMemoryStream := TBytesStream.Create;
  for block in blocks do
  begin

    compressionType := TUnityFSCompressionType(block.flags and CompressionMask);

    case compressionType of
      TUnityFSCompressionType.None:
      begin
        blockMemoryStream.CopyFrom(stream, block.decompressedSize);
      end;
      TUnityFSCompressionType.LZMA:
      begin
        raise Exception.Create('Not implemented');
      end;
      TUnityFSCompressionType.LZ4,
      TUnityFSCompressionType.LZ4HZ:
      begin
        GetMem(source, block.compressedSize);
        GetMem(destination, block.decompressedSize);

        stream.Read(source[0], block.compressedSize);

        TLZ4.Decode(@source[0], @destination[0], block.compressedSize, block.decompressedSize);
        FreeMem(source);

        blockMemoryStream.Write(destination[0], block.decompressedSize);

        FreeMem(destination);
      end;
    end;
  end;

  // Debug dump
  for node in nodes do
  begin
    blockMemoryStream.Position := node.offset;

    tmpStream := TMemoryStream.Create;
    tmpStream.CopyFrom(blockMemoryStream, node.size);
    self.m_bundles.Add(node.name, tmpStream);

    // blockMemoryStream.Position := node.offset;
    // DumpStream(node.name, blockMemoryStream, node.size);
  end;
  // End of debug dump
  nodes.Free;

  blockMemoryStream.Position := 0;
  ExtractContent(blockMemoryStream);
  blockMemoryStream.Free;
  
  blocks.Free;

  metadataMemoryStream.Free;
  metadataEndianStream.Free;

  stream.Free;
  sourceFileStream.Free;
end;

destructor TUnityFS.Destroy;
var
  assetPair: TPair<UInt64, TUnityClass>;
  bundlePair: TPair<AnsiString, TStream>;
begin

  for assetPair in m_assets do
  begin
    assetPair.Value.Free;
  end;

  for bundlePair in m_bundles do
  begin
    bundlePair.Value.Free;
  end;

  m_bundles.Free;
  m_assets.Free;
  inherited;
end;

function TUnityFS.Debug(const stream: TEndianStream; const unityType: TUnityType): TUnityClass;
var
  mapper: TUnityClassMapper;
  node: TUnityTypeNode;

  t: TUnityT;
begin
  if unityType = nil then
  begin
    Exit(nil);
  end;

  // unityType.Dump;

  Result := TUnityClassFactory.Create(unityType.UnityClassId);
  if Result = nil then
  begin
    Exit(nil);
  end;
  Result.Load(stream);
end;

function TUnityFS.LoadAsset<T>(name: AnsiString): T;
begin
  Result := LoadAsset(name) as T;
end;

function TUnityFS.LoadAsset(name: AnsiString): TUnityClass;
var
  assetBundle: TAssetBundle;
  assetInfo: TAssetInfo;
  unityClass: TUnityClass;
begin
  assetBundle := GetAssetBundle;
  assetInfo := assetBundle.GetAssetInfoForPath(name);
  if assetInfo = nil then
  begin
    Exit(nil);
  end;

  if m_assets.TryGetValue(assetInfo.PathID, unityClass) then
  begin
    Result := unityClass;
  end;
end;

procedure TUnityFS.ListAssets;
var
  assetBundle: TAssetBundle;
begin
  assetBundle := GetAssetBundle;
  assetBundle.ListAssets;
end;

procedure TUnityFS.ListAssets(var assets: TList<AnsiString>);
var
  assetBundle: TAssetBundle;
begin
  assetBundle := GetAssetBundle;
  if assetBundle = nil then
  begin
    raise Exception.Create('AssetBundle not found');
  end;
  assetBundle.ListAssets(assets);
end;

function TUnityFS.GetAssetBundle;
var
  pair: TPair<UInt64, TUnityClass>;
  unityClass: TUnityClass;
begin
  for pair in m_assets do
  begin
    unityClass := pair.Value;
    if unityClass is TAssetBundle then
    begin
      Exit(unityClass as TAssetBundle);
    end;
  end;
  raise Exception.Create('AssetBundle not found');
end;

procedure TUnityFS.SaveAudioClipToFile(const filename: AnsiString; const audioClip: TAudioClip);
var
  stream: TStream;
  streamedResource: TStreamedResource;
  shortName: AnsiString;
  fileStream: TFileStream;
  streamSize: Int64;
  tmpStream: TMemoryStream;
begin
  if audioClip = nil then
  begin
    Exit;
  end;

  streamedResource := audioClip.Resource;
  if streamedResource = nil then
  begin
    Exit;
  end;


  shortName := ExtractFileName(StringReplace(streamedResource.Source, '/', '\', [rfReplaceAll]));

  if not m_bundles.TryGetValue(shortName, stream) then
  begin
    Exit;
  end;

  streamSize := stream.Size;

  tmpStream := TMemoryStream.Create;
  stream.Position := streamedResource.Offset;
  tmpStream.CopyFrom(stream, streamedResource.Size);
  tmpStream.Position := 0;
  ConvertDebug(filename, tmpStream, audioClip);
  tmpStream.Free;


end;

end.
