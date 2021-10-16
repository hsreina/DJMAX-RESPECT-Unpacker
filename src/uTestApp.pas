unit uTestApp;

interface

uses uEndianStream, System.Classes, System.SysUtils, Generics.Collections;

type

  TTestApp = class
    private
      procedure UnityFs;
      procedure WaveConvert;
    public
      procedure Run;
  end;

  TArray<T> = class abstract
    protected
      var m_items: array of T;
    public
      constructor Create(const stream: TStream);
  end;

  TCharArray = class (TArray<AnsiChar>)
    public
      constructor Create(const stream: TStream);
  end;

implementation

uses uUnityFS, uConsole, uTextAsset, uUnityClass, uAudioClip, System.IOUtils,
  uStreamedResource, ACS_Wave, ACS_Vorbis;

procedure TTestApp.Run;
begin
  UnityFs;
  // Debug;
  // WaveConvert;
end;

procedure TTestApp.UnityFs;
var
  unityFS: TUnityFS;
  I: Integer;
  assets: TList<AnsiString>;
  asset, newAssetPath: AnsiString;
  textAsset: TTextAsset;
  audioClip: TAudioClip;
  unityClass: TUnityClass;
  directory: string;
  appPath, fullPath: string;
  fileStream: TFileStream;
  streamedResource: TStreamedResource;
begin
  appPath := ExtractFilePath(paramstr(0));
  for I := 1 to ParamCount do
  begin
    unityFS := TUnityFS.Create(paramstr(i));
    assets := TList<AnsiString>.Create;
    unityFS.ListAssets(assets);
    for asset in assets do
    begin
      newAssetPath := StringReplace(asset, '/', '\', [rfReplaceAll]);
      directory := appPath + ExtractFilePath(newAssetPath);
      fullPath := appPath + newAssetPath;
      ForceDirectories(directory);
      unityClass := unityFS.LoadAsset(asset);
      if unityClass is TTextAsset then
      begin
        textAsset := unityClass as TTextAsset;
        fileStream := TFile.Open(fullPath, TFileMode.fmCreate);
        fileStream.Write(textAsset.Script[1], Length(textAsset.Script));
        fileStream.Free;
      end else if unityClass is TAudioClip then
      begin
        audioClip := unityClass as TAudioClip;
        unityFS.SaveAudioClipToFile(fullPath, audioClip);
      end;
    end;
    assets.Free;
    unityFS.Free;
  end;
end;

constructor TArray<T>.Create(const stream: TStream);
var
  itemCount: UInt32;
begin
  stream.Read(itemCount, 4);
  SetLength(m_items, itemCount);
end;

constructor TCharArray.Create(const stream: TStream);
var
  count: Integer;
begin
  inherited;
end;

procedure TTestApp.WaveConvert;
var
  wave: TWaveIn;
  vorbis: TVorbisOut;
  f: TFileStream;
begin
  f := TFileStream.Create('0-fareast.wav', fmOpenRead);

  wave := TWaveIn.Create(nil);
  // wave.FileName := '0-fareast.wav';
  wave.Stream := f;

  vorbis := TVorbisOut.Create(nil);
  vorbis.FileName := '0-fareast.ogg';
  vorbis.Input := wave;
  vorbis.BlockingRun;
  vorbis.Free;

  wave.Free;
  f.Free;
end;

end.
