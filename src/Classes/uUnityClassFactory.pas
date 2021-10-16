unit uUnityClassFactory;

interface

uses uUnityClass, uUnityClassId;

type
  TUnityClassFactory = class
    public
      class function Create(const classId: TUnityClassId): TUnityClass;
  end;

implementation

uses uUnknown, uTextAsset, uAssetBundle, uAudioClip;

class function TUnityClassFactory.Create(const classId: TUnityClassId): TUnityClass;
begin
  case classId of
    TUnityClassId.TextAsset:
      Result := TTextAsset.Create;
    TUnityClassId.AudioClip:
      Result := TAudioClip.Create;
    TUnityClassId.AssetBundle:
      Result := TAssetBundle.Create;
    else
    begin
      Result := TUnknown.Create;
    end;
  end;
end;

end.
