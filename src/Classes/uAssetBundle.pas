unit uAssetBundle;

interface

uses uUnityClass, uEndianStream, uPreloadItem, uUnityArray, Generics.Collections,
  uAssetInfo;

type

  TAssetBundle = class (TUnityClass)
    private
      var m_name: AnsiString;
      var m_PreloadTable: array of TPreloadItem;
      var m_Container: TDictionary<AnsiString, TAssetInfo>;
      var m_MainAsset: TAssetInfo;
      var m_RuntimeCompatibility: UInt32;
      var m_AssetBundleName: AnsiString;
      var m_Dependencies: array of AnsiString;
      var m_IsStreamedSceneAssetBundle: Boolean;
      procedure EmptyLists;
    public
      constructor Create;
      destructor Destroy; override;
      procedure Load(const stream: TEndianStream); override;
      procedure ListAssets; overload;
      procedure ListAssets(var assets: TList<AnsiString>); overload;
      function GetAssetInfoForPath(const path: AnsiString): TAssetInfo;
  end;

implementation

uses uConsole;

constructor TAssetBundle.Create;
begin
  inherited;
  m_MainAsset := TAssetInfo.Create;
  m_Container := TDictionary<AnsiString, TAssetInfo>.Create;
end;

destructor TAssetBundle.Destroy;
begin
  EmptyLists;
  m_Container.Free;
  m_MainAsset.Free;
  inherited;
end;

procedure TAssetBundle.Load(const stream: TEndianStream);
var
  size: UInt32;
  preloadItem: TPreloadItem;
  I: Integer;
  first, dependencyName: AnsiString;
  second: TAssetInfo;
begin
  Console.log('TAssetBundle.Load');
  EmptyLists;

  stream.ReadStr(m_name);
  stream.Align;

  stream.ReadUInt32(size);
  SetLength(m_PreloadTable, size);
  for I := 0 to size - 1 do
  begin
    preloadItem := TPreloadItem.Create;
    preloadItem.Load(stream);
    m_PreloadTable[I] := preloadItem;
  end;

  // Container
  stream.ReadUInt32(size);
  for I := 0 to size - 1 do
  begin
    stream.ReadStr(first);
    stream.Align;
    second := TAssetInfo.Create;
    second.Load(stream);
    m_Container.Add(first, second);
  end;

  m_MainAsset.Load(stream);

  stream.ReadUInt32(m_RuntimeCompatibility);

  stream.ReadStr(m_AssetBundleName);
  stream.Align;

  stream.ReadUInt32(size);
  for I := 0 to size - 1 do
  begin
    stream.ReadStr(dependencyName);
    m_Dependencies[I] := dependencyName;
  end;

  stream.ReadBoolean(m_IsStreamedSceneAssetBundle);
end;

procedure TAssetBundle.EmptyLists;
var
  preloadItem: TPreloadItem;
  pair: TPair<AnsiString, TAssetInfo>;
begin
  for preloadItem in m_PreloadTable do
  begin
    preloadItem.Free;
  end;
  SetLength(m_PreloadTable, 0);

  for pair in m_Container do
  begin
    pair.Value.Free;
  end;
  m_Container.Clear;
end;

procedure TAssetBundle.ListAssets;
var
  pair: TPair<AnsiString, TAssetInfo>;
begin
  for pair in m_Container do
  begin
    Console.Log(pair.Key);
  end;
end;

procedure TAssetBundle.ListAssets(var assets: TList<AnsiString>);
var
  pair: TPair<AnsiString, TAssetInfo>;
begin
  for pair in m_Container do
  begin
    assets.Add(pair.Key);
  end;
end;

function TAssetBundle.GetAssetInfoForPath(const path: AnsiString): TAssetInfo;
begin
  Result := nil;
  m_Container.TryGetValue(path, Result);
end;

end.
