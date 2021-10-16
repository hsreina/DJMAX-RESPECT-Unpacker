unit uUnityClassId;

interface

type
{$SCOPEDENUMS ON}
{$Z4}
  TUnityClassId = (
    TextAsset = 49,
    AudioClip = 83,
    AssetBundle = 142
  );
{$Z1}
{$SCOPEDENUMS OFF}

  TUnityClassIdHelper = class
    public
      class function ToString(const classId: TUnityClassId): AnsiString;
  end;

implementation

class function TUnityClassIdHelper.ToString(const classId: TUnityClassId): AnsiString;
begin
  case classId of
    TUnityClassId.TextAsset: Exit('TextAsset');
    TUnityClassId.AudioClip: Exit('AudioClip');
    TUnityClassId.AssetBundle: Exit('AssetBundle');
    else Exit('Unknown');
  end;
end;

end.
