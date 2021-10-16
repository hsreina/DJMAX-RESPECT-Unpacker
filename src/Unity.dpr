program Unity;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  lz4d in 'libs\lz4-delphi\lz4d.pas',
  lz4d.lz4 in 'libs\lz4-delphi\lz4d.lz4.pas',
  lz4d.lz4s in 'libs\lz4-delphi\lz4d.lz4s.pas',
  lz4d.dependencies in 'libs\lz4-delphi\lz4d.dependencies.pas',
  xxHash in 'libs\lz4-delphi\xxHash.pas',
  uTestApp in 'uTestApp.pas',
  uUnityFS in 'uUnityFS.pas',
  uEndianStream in 'uEndianStream.pas',
  uConsole in 'uConsole.pas',
  UnityFSStringList in 'UnityFSStringList.pas',
  utils in 'utils.pas',
  uGeneric in 'uGeneric.pas',
  uUnityType in 'uUnityType.pas',
  uUnityTypeNode in 'uUnityTypeNode.pas',
  uUnityClassId in 'uUnityClassId.pas',
  uUnityT in 'uUnityT.pas',
  uUnityClassMap in 'uUnityClassMap.pas',
  uAssetBundle in 'Classes\uAssetBundle.pas',
  uAssetInfo in 'Classes\uAssetInfo.pas',
  uAudioClip in 'Classes\uAudioClip.pas',
  uTextAsset in 'Classes\uTextAsset.pas',
  uUnityClass in 'Classes\uUnityClass.pas',
  uUnityClassFactory in 'Classes\uUnityClassFactory.pas',
  uUnknown in 'Classes\uUnknown.pas',
  uPreloadItem in 'Classes\uPreloadItem.pas',
  uUnityArray in 'Classes\uUnityArray.pas',
  uStreamedResource in 'Classes\uStreamedResource.pas',
  uWav in 'uWav.pas',
  _MSAcm in 'libs\newac\_MSAcm.pas',
  ACS_Classes in 'libs\newac\ACS_Classes.pas',
  ACS_Procs in 'libs\newac\ACS_Procs.pas',
  ACS_Tags in 'libs\newac\ACS_Tags.pas',
  ACS_Types in 'libs\newac\ACS_Types.pas',
  ACS_Vorbis in 'libs\newac\ACS_Vorbis.pas',
  ACS_Wave in 'libs\newac\ACS_Wave.pas',
  Codec in 'libs\newac\Codec.pas',
  FastcodeCPUID in 'libs\newac\FastcodeCPUID.pas',
  FastMove in 'libs\newac\FastMove.pas',
  ogg in 'libs\newac\ogg.pas',
  VorbisEnc in 'libs\newac\VorbisEnc.pas',
  VorbisFile in 'libs\newac\VorbisFile.pas',
  WaveConverter in 'libs\newac\WaveConverter.pas';

var
  app: TTestApp;

begin

  ReportMemoryLeaksOnShutdown := DebugHook <> 0;

  try
    { TODO -oUser -cConsole Main : Insert code here }

    app := TTestApp.Create;
    try
      app.Run;
    finally
      app.Free;
    end;

  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
